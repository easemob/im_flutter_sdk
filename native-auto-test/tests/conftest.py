"""
Pytest fixtures：WebSocket 配置、topic、请求封装等。
全局登录/登出：session 开始时对所有设备登录，session 结束时登出，用例内不需要写 login/logout。
Allure：请求、响应、比对结果会写入报告（需安装 allure-pytest，运行 pytest --alluredir=...）。
"""
from __future__ import annotations

import json
import inspect
import os
import sys
import time
import uuid
from contextlib import nullcontext
from dataclasses import dataclass
from pathlib import Path

import pytest

# 保证能 import src
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from src.tools.config import (
    get_default_topic,
    get_topic,
    get_rest_auth_token,
    get_ws_base_url,
)
from src.rest_api.user_api import create_users, delete_user
from src.tools.ws_client import (
    request as ws_request,
    request_and_wait_for_event as ws_request_and_wait_event,
    MessageListener,
    DeviceConnection,
)
from src.tools import assertions
from src import Cmd
from src.capability import (
    ApiMatrix,
    CapabilityConfigurationError,
    CapabilityResolver,
    UnsupportedCapability,
)
from src.orchestrator import (
    DEVICE_ROLE_NAMES,
    EnvironmentManager,
    ExecutionPlan,
    RunnerRegistry,
    ResourceRegistry,
    UpgradeRunner,
)
from src.ws import ManagedWebSocketServer

# 未配置 REST 用户管理时的回退账号（仅当不创建用户时使用）
SESSION_FALLBACK_USER_A = "test0318user1"
SESSION_FALLBACK_USER_B = "test0318user2"
SESSION_FALLBACK_USER_C = "test0318user3"
SESSION_PWD = "1"
_LAST_CREATE_USERS_ERROR = ""


# ----- Allure 工具 -----

def _allure_step(name: str):
    """安全获取 allure.step context manager；未安装时返回 nullcontext。"""
    try:
        import allure
        return allure.step(name)
    except ImportError:
        return nullcontext()


def _attach_request_response_allure(step_name: str, request_body: dict, response_body: dict) -> None:
    """将请求与响应以 JSON 附件形式写入 Allure 报告。"""
    try:
        import allure
        with allure.step(step_name):
            allure.attach(
                json.dumps(_redact(request_body), ensure_ascii=False, indent=2),
                "请求",
                allure.attachment_type.JSON,
            )
            allure.attach(
                json.dumps(
                    _redact(response_body),
                    ensure_ascii=False,
                    indent=2,
                    default=str,
                ),
                "响应",
                allure.attachment_type.JSON,
            )
    except ImportError:
        pass


_API_ACTION_LABELS = {
    ("Client", "login"): "登录账号",
    ("Client", "logout"): "退出账号",
    ("ChatManager", "sendMessage"): "发送消息",
    ("ChatManager", "getMessage"): "查询本地消息",
    ("ChatManager", "translateMessage"): "请求消息翻译",
    ("ChatManager", "recallMessage"): "撤回消息",
    ("ChatManager", "addReaction"): "添加消息 reaction",
    ("ChatManager", "removeReaction"): "移除消息 reaction",
    ("ChatManager", "ackMessageRead"): "提交消息已读回执",
    ("ChatManager", "modifyMessage"): "修改消息内容",
}


def _api_step_name(
    manager: str,
    cmd: str,
    device: str,
    info: dict | None = None,
) -> str:
    action = _API_ACTION_LABELS.get((manager, cmd), "调用 API")
    details: list[str] = []
    payload = info or {}
    for key in ("msgId", "to", "convId", "reaction"):
        if payload.get(key) is not None:
            details.append(f"{key}={payload[key]}")
    body = payload.get("body")
    if isinstance(body, dict) and body.get("content") is not None:
        content = str(body["content"])
        details.append(f"内容={content[:32]!r}")
    suffix = f"，{', '.join(details)}" if details else ""
    return f"{device} {action}{suffix}（{manager}.{cmd}）"


def _case_description(request) -> str:
    """Return a readable Allure description, with a deterministic fallback."""
    name = str(getattr(request.node, "name", request.node.nodeid))
    parameter_suffix = ""
    if "[" in name and name.endswith("]"):
        parameter_suffix = f"（参数：{name.split('[', 1)[1][:-1]}）"
    description = inspect.getdoc(getattr(request.node, "obj", None))
    if description:
        return description.strip() + parameter_suffix
    case_name = name.split("[", 1)[0].replace("_", " ").strip()
    return f"自动化验证：{case_name}{parameter_suffix}。"


def _display_role(role_spec) -> str:
    platform = str(role_spec.platform).replace("android", "Android").replace(
        "ios", "iOS"
    ).replace("web", "Web")
    return (
        f"{role_spec.device_name}（{platform} · SDK {role_spec.sdk_version}）"
    )


def _direct_case_groups(phase1_scenario, roles: tuple[str, ...]) -> list[list[object]]:
    groups: dict[str, list[object]] = {}
    if phase1_scenario:
        for role in roles:
            spec = phase1_scenario.roles[role]
            groups.setdefault(spec.account, []).append(spec)
    return list(groups.values())


def _direct_case_type(phase1_scenario, roles: tuple[str, ...]) -> str:
    groups = _direct_case_groups(phase1_scenario, roles)
    if not groups:
        return "single_device"
    if len(groups) == 1:
        return "same_account_multi_device" if len(groups[0]) > 1 else "single_device"
    return (
        "cross_account_multi_device"
        if any(len(group) > 1 for group in groups)
        else "cross_account_single_device"
    )


def _attach_case_allure_metadata(request, phase1_scenario, roles: tuple[str, ...]) -> None:
    """Attach a common description and device/platform metadata to every Case.

    Topology cases receive their sender/recipient-specific parameters from the
    topology fixture. Direct-device cases still get the same baseline fields
    (scenario, case type, sender/recipient accounts, and every endpoint).
    """
    try:
        import allure

        allure.dynamic.description(_case_description(request))
        marker = request.node.get_closest_marker("topology")
        topology_names = tuple(str(value) for value in (marker.args if marker else ()))
        direct_names = tuple(
            getattr(getattr(request.node, "_fixtureinfo", None), "argnames", ())
            or ()
        )
        has_topology_fixture = "topology" in direct_names

        # The topology fixture adds the complete sender/recipient/account
        # parameter set. Keep this common hook responsible for the description
        # only in that case, avoiding duplicate Allure parameters.
        if topology_names and has_topology_fixture:
            return

        allure.dynamic.parameter(
            "测试类型",
            "场景拓扑：一发一收账号多端"
            if topology_names
            else "普通 API：直接设备调用",
        )
        allure.dynamic.parameter(
            "测试场景",
            phase1_scenario.name if phase1_scenario else "未指定 scenario",
        )
        specs = [phase1_scenario.roles[role] for role in roles] if phase1_scenario else []
        groups = _direct_case_groups(phase1_scenario, roles)
        sender_specs = groups[0] if groups else []
        recipient_specs = groups[1] if len(groups) > 1 else sender_specs
        allure.dynamic.parameter(
            "发送账号",
            sender_specs[0].account if sender_specs else "未解析",
        )
        allure.dynamic.parameter(
            "接收账号",
            recipient_specs[0].account if recipient_specs else "未解析",
        )
        allure.dynamic.parameter(
            "发送端",
            "；".join(_display_role(spec) for spec in sender_specs) or "未解析",
        )
        allure.dynamic.parameter(
            "接收端",
            "；".join(_display_role(spec) for spec in recipient_specs) or "未解析",
        )
    except ImportError:
        pass


def _redact(value):
    if isinstance(value, dict):
        output = {}
        for key, item in value.items():
            normalized = str(key).lower().replace("_", "")
            if normalized in {
                "password",
                "pwdortoken",
                "token",
                "agoratoken",
                "authtoken",
                "accesstoken",
            }:
                output[key] = "***"
            else:
                output[key] = _redact(item)
        return output
    if isinstance(value, list):
        return [_redact(item) for item in value]
    return value


# ----- 登录前清空回调 -----

def _drain_all_callbacks_before_cases(device: str, idle_timeout: float = 2.0, max_messages: int = 200) -> None:
    """登录后把该设备 topic 上残留的所有回调收掉并丢弃，避免影响后续用例。"""
    listener = MessageListener(topic=get_topic(device), device=device)
    listener.start()
    try:
        received = 0
        while received < max_messages:
            msg = listener.receive_message(timeout=idle_timeout)
            if msg is None:
                break
            received += 1
        listener.drain_buffer()
    finally:
        listener.stop()


# ----- Session 登录 / 登出（抽出为独立函数，结构清晰） -----

def _session_login(
    device_a,
    device_b,
    user_a: str,
    user_b: str,
    password: str = "1",
) -> None:
    """
    所有 test_* cases 执行前调用一次：deviceA 以 user_a、deviceB 以 user_b 登录，并清空该连接上的回调。
    """
    def _do_login():
        ra = device_a.call(
            "Client", Cmd.login.value,
            info={"userId": user_a, "pwdOrToken": password, "isPassword": True},
        )
        rb = device_b.call(
            "Client", Cmd.login.value,
            info={"userId": user_b, "pwdOrToken": password, "isPassword": True},
        )
        return ra, rb

    def _need_create_user(r: dict) -> bool:
        result = r.get("result")
        if result is None:
            return True
        if result == "" or result == {}:
            return True
        if isinstance(result, dict):
            code = result.get("code")
            desc = str(result.get("description", ""))
            if code == 204:
                return True
            if "User does not exist" in desc:
                return True
        return False

    with _allure_step("Session 登录"):
        has_rest_token = bool(get_rest_auth_token())
        # 仅在未配置 REST token 时，走 WS createAccount 预创建
        if not has_rest_token:
            try:
                _, _, user_c = _test_usernames()
                for uid in (user_a, user_b, user_c):
                    create_resp = device_a.call(
                        "Client",
                        Cmd.createAccount.value,
                        info={"userId": uid, "password": password},
                    )
                    _attach_request_response_allure(
                        "WS createAccount warmup",
                        {
                            "manager": "Client",
                            "cmd": Cmd.createAccount.value,
                            "info": {"userId": uid, "password": "***"},
                        },
                        create_resp,
                    )
            except Exception:
                pass
        def _is_transient_login_failure(r: dict) -> bool:
            result = r.get("result")
            if not isinstance(result, dict):
                return False
            code = result.get("code")
            desc = str(result.get("description", "")).lower()
            return code == 350 or "timeout" in desc or "connect timeout" in desc

        def _logout_before_retry() -> None:
            for dev in (device_a, device_b):
                try:
                    dev.call("Client", Cmd.logout.value, info={"unbindToken": False})
                except Exception:
                    pass

        resp_a = resp_b = {}
        for attempt in range(1, 4):
            try:
                resp_a, resp_b = _do_login()
            except TimeoutError:
                if attempt >= 3:
                    raise
                _logout_before_retry()
                time.sleep(float(attempt))
                continue
            if not (_is_transient_login_failure(resp_a) or _is_transient_login_failure(resp_b)):
                break
            if attempt >= 3:
                break
            _logout_before_retry()
            time.sleep(float(attempt))

        # 仅在未配置 REST token 时，允许 WS createAccount 兜底
        if (not has_rest_token) and (_need_create_user(resp_a) or _need_create_user(resp_b)):
            try:
                for uid in (user_a, user_b):
                    create_resp = device_a.call(
                        "Client",
                        Cmd.createAccount.value,
                        info={"userId": uid, "password": password},
                    )
                    _attach_request_response_allure(
                        "WS createAccount fallback",
                        {"manager": "Client", "cmd": Cmd.createAccount.value, "info": {"userId": uid, "password": "***"}},
                        create_resp,
                    )
                # user_c 也补齐，避免后续 group/member 场景再触发不存在
                try:
                    _, _, user_c = _test_usernames()
                    device_a.call("Client", Cmd.createAccount.value, info={"userId": user_c, "password": password})
                except Exception:
                    pass
                resp_a, resp_b = _do_login()
            except Exception:
                # fallback 失败时沿用原登录结果，由下方统一报错
                pass

        def _ok(r: dict) -> bool:
            res = r.get("result")
            # 成功条件：
            # - True/1
            # - 非空字符串用户名
            # - 字典：无 code 字段，或 code==200（已登录）
            if res is True or res == 1:
                return True
            if isinstance(res, str) and res.strip():
                return True
            if isinstance(res, dict):
                code = res.get("code")
                if code is None or int(code) == 200:
                    return True
            return False
        if not (_ok(resp_a) and _ok(resp_b)):
            import pytest as _pytest
            extra = ""
            if _LAST_CREATE_USERS_ERROR:
                extra = f"\n4) REST 自动创建用户失败详情：\n{_LAST_CREATE_USERS_ERROR}\n"
            _pytest.exit(
                "登录失败，已中止本次用例执行。\n"
                f"deviceA: {resp_a}\n"
                f"deviceB: {resp_b}\n"
                "排查建议：\n"
                "1) 确认被测端已创建当天用户名（tests/conftest.py 中 testMMDDuser1/2/3），或在 config.yaml 的 rest_api.auth_token 中配置 token 以自动创建。\n"
                "2) 检查 config.yaml.websocket.base_url 与 topics 是否指向在线集成端。\n"
                "3) 若使用网关鉴权，确认 token/APPKEY 正确。\n"
                f"{extra}"
            )

    device_a.drain_events()
    device_b.drain_events()

    # 某些端需显式开启 Chat 消息回调；若 WS 端未实现可忽略报错
    try:
        device_a.call("Client", Cmd.startCallback.value, info={})
    except Exception:
        pass
    try:
        device_b.call("Client", Cmd.startCallback.value, info={})
    except Exception:
        pass


def _session_logout(device_a, device_b) -> None:
    """
    所有 test_* cases 执行后调用一次：deviceA、deviceB 各登出一次。
    登出失败不阻断 teardown，仅记录到 Allure。
    """
    with _allure_step("Session 登出"):
        for name, dev in [("deviceA", device_a), ("deviceB", device_b)]:
            try:
                dev.call("Client", Cmd.logout.value, info={"unbindToken": False})
            except Exception as e:
                try:
                    import allure
                    allure.attach(str(e), f"登出失败 {name}", allure.attachment_type.TEXT)
                except ImportError:
                    pass


# ----- Fixtures -----

def pytest_addoption(parser):
    parser.addoption(
        "--scenario",
        action="store",
        default="",
        help="Scenario name/path under config/scenarios.",
    )
    parser.addoption(
        "--build",
        action="store_true",
        default=False,
        help="Automatically build the required Android/Web Runner artifacts before running tests.",
    )
    parser.addoption(
        "--manage-runners",
        action="store_true",
        default=False,
        help="Automatically start/select emulators, install artifacts and launch runners.",
    )
    parser.addoption(
        "--no-manage-runners",
        action="store_true",
        default=False,
        help="Use already running external runners even when --scenario is set.",
    )
    parser.addoption(
        "--ws-mode",
        action="store",
        choices=("managed", "external"),
        default="managed",
        help="managed starts the native-auto-test WS server; external uses config base_url.",
    )
    parser.addoption(
        "--artifacts",
        action="store",
        default="config/artifacts.yaml",
        help="Artifact catalog path.",
    )
    parser.addoption(
        "--api-matrix",
        action="store",
        default="config/api_matrix/android.yaml",
        help="API Matrix path.",
    )
    parser.addoption(
        "--ws-debug",
        action="store_true",
        default=False,
        help="Capture and print all WebSocket messages during chat tests for debugging.",
    )
    parser.addoption(
        "--ws-relax-success",
        action="store_true",
        default=False,
        help="When set, do not require exact eventType for onMessageSuccess; accept first incoming event and print its type.",
    )

    parser.addoption(
        "--ws-relax-received",
        action="store_true",
        default=False,
        help="When set, do not require exact eventType for onMessagesReceived; accept first incoming event and print its type.",
    )



    parser.addoption(
        "--ws-relax",
        action="store_true",
        default=False,
        help="Relax all event matching for chat tests (success/received).",
    )


def pytest_collection_modifyitems(config, items):
    """Collect device fixtures declared directly OR via business autouse."""
    scenario = _scenario_for_collection(config)
    fixture_sets: list[tuple[str, ...]] = []
    topology_role_sets: list[tuple[str, ...]] = []
    for item in items:
        fixture_info = getattr(item, "_fixtureinfo", None)
        if fixture_info is None:
            fixture_sets.append(())
            topology_role_sets.append(_topology_roles_for_item(item, scenario))
            continue
        direct_names = tuple(getattr(fixture_info, "argnames", ()) or ())
        initial_names = tuple(getattr(fixture_info, "initialnames", ()) or ())
        # initialnames 含 autouse（如 chat 的 ensure_friends），用它补全
        # 业务 autouse 声明的设备需求；direct argnames 保持"Case 直接声明"。
        fixture_sets.append(tuple(dict.fromkeys((*initial_names, *direct_names))))
        topology_role_sets.append(_topology_roles_for_item(item, scenario))
    plan = ExecutionPlan.from_direct_fixtures(
        fixture_sets,
        required_role_sets=topology_role_sets,
    )
    config._native_required_device_roles = set(plan.required_roles)


def _scenario_for_collection(config):
    value = str(config.getoption("--scenario") or "").strip()
    if not value:
        return None
    from src.orchestrator.config import load_scenario

    return load_scenario(
        _resolve_repo_path(value, folder="config/scenarios")
    )


def _topology_roles_for_item(item, scenario) -> tuple[str, ...]:
    marker = item.get_closest_marker("topology")
    if marker is None:
        return ()
    if scenario is None:
        raise pytest.UsageError(
            f"{item.nodeid} uses @pytest.mark.topology but no --scenario was provided"
        )
    topology_names = tuple(str(name) for name in marker.args)
    if not topology_names:
        raise pytest.UsageError(
            f"{item.nodeid} uses @pytest.mark.topology without a topology name"
        )
    unknown = sorted(set(topology_names).difference(scenario.topologies))
    if unknown:
        raise pytest.UsageError(
            f"{item.nodeid} references undefined topologies {unknown}; "
            f"available={sorted(scenario.topologies)}"
        )
    roles: set[str] = set()
    for topology_name in topology_names:
        topology = scenario.topologies[topology_name]
        roles.update(topology.sender_devices)
        roles.update(topology.recipient_devices)
    return tuple(sorted(roles))


@pytest.fixture(scope="session")
def required_device_roles(request) -> set[str]:
    return set(
        getattr(request.config, "_native_required_device_roles", set())
    )


@pytest.fixture(scope="session")
def test_run_id(request) -> str:
    configured = os.getenv("NATIVE_TEST_RUN_ID", "").strip()
    value = configured or f"run-{uuid.uuid4().hex[:12]}"
    request.config._native_test_run_id = value
    return value


@dataclass(frozen=True)
class _WsRuntime:
    mode: str
    base_url: str
    run_id: str
    topics: dict[str, str]

    def topic_for(self, device_name: str) -> str:
        if self.mode == "managed":
            return ""
        if device_name in self.topics:
            return self.topics[device_name]
        return get_topic(device_name)


@pytest.fixture(scope="session")
def ws_runtime(request, phase1_scenario, test_run_id):
    mode = str(request.config.getoption("--ws-mode"))
    if phase1_scenario is None or mode == "external":
        topics = {}
        if phase1_scenario is not None:
            topics = {
                role.device_name: f"nat-{test_run_id}-{role.role}"
                for role in phase1_scenario.roles.values()
            }
        yield _WsRuntime(
            mode="external",
            base_url=get_ws_base_url(),
            run_id=test_run_id,
            topics=topics,
        )
        return

    server = ManagedWebSocketServer(run_id=test_run_id).start()
    try:
        yield _WsRuntime(
            mode="managed",
            base_url=server.base_url,
            run_id=test_run_id,
            topics={},
        )
    finally:
        server.stop()


@pytest.fixture(scope="session")
def ws_debug(request) -> bool:
    return bool(request.config.getoption("--ws-debug"))

@pytest.fixture(scope="session")
def ws_relax(request) -> bool:
    # unified flag; also respect older fine-grained flags if provided
    return bool(request.config.getoption("--ws-relax")
                or request.config.getoption("--ws-relax-success")
                or request.config.getoption("--ws-relax-received"))

@pytest.fixture(scope="session")
def ws_relax_success(request) -> bool:
    return bool(request.config.getoption("--ws-relax-success"))

@pytest.fixture(scope="session")
def ws_relax_received(request) -> bool:
    return bool(request.config.getoption("--ws-relax-received"))


@pytest.fixture(scope="session")
def ws_topic() -> str:
    """默认 WebSocket topic，与 Flutter 端一致。"""
    return get_default_topic()


@pytest.fixture(scope="session")
def ws_device() -> str | None:
    """多端测试时的设备标识，对应 config 中 topics 的 key。"""
    return None


def _resolve_repo_path(value: str, *, folder: str | None = None) -> Path:
    root = Path(__file__).resolve().parent.parent
    candidate = Path(value)
    if not candidate.suffix and folder:
        candidate = Path(folder) / f"{value}.yaml"
    return candidate if candidate.is_absolute() else (root / candidate).resolve()


@pytest.fixture(scope="session")
def phase1_scenario(request):
    value = str(request.config.getoption("--scenario") or "").strip()
    if not value:
        return None
    from src.orchestrator.config import load_scenario

    path = _resolve_repo_path(value, folder="config/scenarios")
    return load_scenario(path)


@pytest.fixture(scope="session")
def phase1_environment(
    request,
    phase1_scenario,
    required_device_roles,
    ws_runtime,
):
    manage = (
        phase1_scenario is not None
        and not request.config.getoption("--no-manage-runners")
    )
    if not manage:
        yield None
        return
    scenario_value = str(request.config.getoption("--scenario"))
    scenario_path = _resolve_repo_path(
        scenario_value,
        folder="config/scenarios",
    )
    artifacts_path = _resolve_repo_path(str(request.config.getoption("--artifacts")))
    manager = EnvironmentManager(
        scenario_path,
        artifacts_path,
        web_socket_base_url=ws_runtime.base_url,
        topics={
            role.device_name: ws_runtime.topic_for(role.device_name)
            for role in phase1_scenario.roles.values()
        },
        run_id=ws_runtime.run_id,
        managed_web_socket=ws_runtime.mode == "managed",
        active_roles=required_device_roles,
        skip_hash_validation=bool(request.config.getoption("--build")),
    )
    try:
        yield manager.start()
    finally:
        manager.stop()


@pytest.fixture(scope="session")
def capability_resolver(request, phase1_scenario):
    if phase1_scenario is None:
        return None
    path = _resolve_repo_path(str(request.config.getoption("--api-matrix")))
    matrices = {"android": ApiMatrix.load(path)}
    for platform in {role.platform for role in phase1_scenario.roles.values()}:
        candidate = path.parent / f"{platform}.yaml"
        if platform not in matrices and candidate.is_file():
            matrices[platform] = ApiMatrix.load(candidate)
    return CapabilityResolver(matrices)


@pytest.fixture(scope="session")
def runner_registry():
    return RunnerRegistry()


@pytest.fixture(scope="session")
def api(ws_topic: str, ws_device: str | None):
    """
    封装一次请求的 helper：api.call(manager, cmd, info) -> response。
    session 内全局已登录，用例内无需再 login。
    """
    topic = get_topic(ws_device) if ws_device else ws_topic

    def _call(manager: str, cmd: str, info: dict | None = None, **kwargs):
        req = {"manager": manager, "cmd": cmd, "info": info or {}, "topic": topic, "device": ws_device, **kwargs}
        resp = ws_request(manager=manager, cmd=cmd, info=info, topic=topic, device=ws_device, **kwargs)
        _attach_request_response_allure(f"API 请求 {manager}.{cmd}", req, resp)
        return resp

    def _call_and_wait_event(manager: str, cmd: str, info: dict | None = None, *, event_type: str, event_timeout: float = 10.0, **kwargs):
        return ws_request_and_wait_event(
            manager=manager, cmd=cmd, info=info, topic=topic, device=ws_device,
            event_type=event_type, event_timeout=event_timeout, **kwargs,
        )

    class _API:
        call = staticmethod(_call)
        call_and_wait_event = staticmethod(_call_and_wait_event)
    return _API()


def _make_api(device: str):
    """按设备标识构造 api（topic 从 config topics 读取）。"""
    topic = get_topic(device)

    def _call(manager: str, cmd: str, info: dict | None = None, **kwargs):
        req = {"manager": manager, "cmd": cmd, "info": info or {}, "topic": topic, "device": device, **kwargs}
        resp = ws_request(manager=manager, cmd=cmd, info=info, topic=topic, device=device, **kwargs)
        _attach_request_response_allure(_api_step_name(manager, cmd, device, info), req, resp)
        return resp

    class _API:
        call = staticmethod(_call)
    return _API()


@pytest.fixture(scope="session")
def api_device_a():
    """设备 A 的 api（config 中 topics.deviceA）；session 内已以 user_a 登录。"""
    return _make_api("deviceA")


@pytest.fixture(scope="session")
def api_device_b():
    """设备 B 的 api（config 中 topics.deviceB）；session 内已以 user_b 登录。"""
    return _make_api("deviceB")


def _test_usernames(run_id: str | None = None) -> tuple[str, str, str]:
    """Generate Session-unique accounts from runId while preserving fixtures."""
    raw_suffix = os.getenv("NATIVE_TEST_USER_SUFFIX", "")
    source = raw_suffix or run_id or uuid.uuid4().hex[:8]
    suffix = "".join(char for char in source.lower() if char.isalnum())[-12:]
    prefix = f"test{suffix}"
    return f"{prefix}user1", f"{prefix}user2", f"{prefix}user3"


def _scenario_usernames(
    run_id: str | None,
    account_slots: tuple[str, ...],
) -> dict[str, str]:
    """Generate one stable, session-unique username per configured account."""
    raw_suffix = os.getenv("NATIVE_TEST_USER_SUFFIX", "")
    source = raw_suffix or run_id or uuid.uuid4().hex[:8]
    suffix = "".join(char for char in source.lower() if char.isalnum())[-12:]
    prefix = f"test{suffix}"
    return {
        slot: f"{prefix}user{index}"
        for index, slot in enumerate(account_slots, start=1)
    }


@pytest.fixture(scope="session")
def created_test_users(test_run_id, phase1_scenario):
    """Provision scenario accounts while preserving user_a/user_b/user_c."""
    global _LAST_CREATE_USERS_ERROR
    _LAST_CREATE_USERS_ERROR = ""
    keep_users = os.getenv("KEEP_TEST_USERS", "0") in ("1", "true", "True")
    token = get_rest_auth_token()
    configured_slots = (
        tuple(phase1_scenario.accounts)
        if phase1_scenario is not None
        else ()
    )
    # 旧 case 仍会注入 user_c，即使两设备 scenario 只声明 A/B。
    # 新的语义账号场景（例如 user_1/user_2）则不强行创建遗留账号。
    account_slots = (
        tuple(dict.fromkeys(("account_a", "account_b", "account_c", *configured_slots)))
        if {"account_a", "account_b"}.intersection(configured_slots)
        else (configured_slots or ("account_a", "account_b", "account_c"))
    )
    users = _scenario_usernames(test_run_id, account_slots)
    provisions = {slot: "rest" for slot in users}
    passwords = {slot: SESSION_PWD for slot in users}
    if phase1_scenario is not None:
        for slot, account in phase1_scenario.accounts.items():
            provisions[slot] = account.provision
            passwords[slot] = account.password
            if account.provision == "existing":
                if not account.username:
                    pytest.exit(
                        f"Scenario account {slot!r} uses provision=existing "
                        "but has no username",
                        returncode=2,
                    )
                users[slot] = account.username

    to_create = [
        {
            "username": users[slot],
            "password": passwords.get(slot, SESSION_PWD),
        }
        for slot, provision in provisions.items()
        if provision == "rest"
    ]
    if not token or not to_create:
        yield users
        return

    with _allure_step("创建测试用户"):
        create_resp = create_users(to_create)
    if isinstance(create_resp, dict) and create_resp.get("error"):
        _LAST_CREATE_USERS_ERROR = json.dumps(create_resp, ensure_ascii=False, indent=2, default=str)
        try:
            import allure
            allure.attach(
                _LAST_CREATE_USERS_ERROR,
                "REST 创建账号失败",
                allure.attachment_type.TEXT,
            )
        except ImportError:
            pass
        pytest.exit(
            f"Environment Error: REST account provisioning failed\n"
            f"{_LAST_CREATE_USERS_ERROR}",
            returncode=2,
        )

    created_users = [item["username"] for item in to_create]
    time.sleep(5.0)
    try:
        yield users
    finally:
        if not keep_users:
            with _allure_step("删除测试用户"):
                for u in created_users:
                    try:
                        delete_user(u)
                    except Exception as e:
                        try:
                            import allure
                            allure.attach(str(e), f"删除用户 {u}", allure.attachment_type.TEXT)
                        except ImportError:
                            pass


@pytest.fixture(scope="session")
def user_a(created_test_users):
    """设备 A 对应用户名（session 内创建，teardown 删除）。"""
    return created_test_users["account_a"]


@pytest.fixture(scope="session")
def user_b(created_test_users):
    """设备 B 对应用户名（session 内创建，teardown 删除）。"""
    return created_test_users["account_b"]

@pytest.fixture(scope="session")
def user_c(created_test_users):
    """设备 A 对应用户名（session 内创建，teardown 删除）。"""
    return created_test_users["account_c"]

def _account_slot(logical_role: str, phase1_scenario) -> str:
    return (
        phase1_scenario.roles[logical_role].account
        if phase1_scenario is not None
        else f"account_{logical_role.removeprefix('device_')[0]}"
    )


def _account_user(
    logical_role: str,
    phase1_scenario,
    users: dict[str, str],
) -> str:
    account = _account_slot(logical_role, phase1_scenario)
    if account not in users:
        raise RuntimeError(
            f"Unsupported account slot {account!r} for role {logical_role!r}"
        )
    return users[account]


def _account_password(logical_role: str, phase1_scenario) -> str:
    slot = _account_slot(logical_role, phase1_scenario)
    if phase1_scenario is None or slot not in phase1_scenario.accounts:
        return SESSION_PWD
    return phase1_scenario.accounts[slot].password


def _scenario_is_v5(phase1_scenario) -> bool:
    """判断当前 scenario 是否使用 5.x SDK（决定用 token 登录还是密码登录）。"""
    if phase1_scenario is None:
        return False
    for role in phase1_scenario.roles.values():
        if role.platform == "android" and role.sdk_version:
            major = str(role.sdk_version).split(".")[0]
            if major.isdigit() and int(major) >= 5:
                return True
    return False


@pytest.fixture(scope="session")
def sdk_is_v5(phase1_scenario) -> bool:
    """当前场景是否 5.x SDK（用于跨版本 API 响应差异断言，如 ackConversationRead 错误码）。"""
    return _scenario_is_v5(phase1_scenario)


def _login_one(device, user_id: str, password: str, use_token: bool = False) -> None:
    response: dict = {}
    for attempt in range(3):
        try:
            if use_token:
                # 5.0 统一 token 登录：先用账号密码换 token
                from src.rest_api.user_api import fetch_user_token

                tok = fetch_user_token(user_id, password)
                token = tok.get("access_token", "")
                response = device.call(
                    "Client",
                    Cmd.login.value,
                    info={"userId": user_id, "pwdOrToken": token, "isPassword": False},
                )
            else:
                response = device.call(
                    "Client",
                    Cmd.login.value,
                    info={
                        "userId": user_id,
                        "pwdOrToken": password,
                        "isPassword": True,
                    },
                )
        except TimeoutError:
            if attempt == 2:
                raise
            time.sleep(attempt + 1)
            continue
        result = response.get("result")
        if (
            result is True
            or result == 1
            or (isinstance(result, str) and result.strip())
            or (
                isinstance(result, dict)
                and (
                    result.get("code") is None
                    or int(result.get("code")) == 200
                )
            )
        ):
            try:
                device.call("Client", Cmd.startCallback.value, info={})
            except Exception:
                pass
            return
        if attempt < 2:
            time.sleep(attempt + 1)
    pytest.exit(
        f"Session login failed: user={user_id}, response={response}",
        returncode=2,
    )


@pytest.fixture(scope="session", autouse=True)
def global_login_logout(
    required_device_roles,
    phase1_scenario,
    created_test_users,
    device_pool,
):
    """Prepare only the selected logical devices once for the whole Session."""
    roles = sorted(required_device_roles)
    devices = {role: device_pool.get(role) for role in roles}

    if devices and not get_rest_auth_token():
        creator = next(iter(devices.values()))
        accounts_to_create = {
            _account_slot(role, phase1_scenario)
            for role in roles
            if (
                phase1_scenario is None
                or _account_slot(role, phase1_scenario)
                not in phase1_scenario.accounts
                or phase1_scenario.accounts[
                    _account_slot(role, phase1_scenario)
                ].provision == "rest"
            )
        }
        for slot in sorted(accounts_to_create):
            try:
                creator.call(
                    "Client",
                    Cmd.createAccount.value,
                    info={
                    "userId": created_test_users[slot],
                        "password": (
                            phase1_scenario.accounts[slot].password
                            if (
                                phase1_scenario is not None
                                and slot in phase1_scenario.accounts
                            )
                            else SESSION_PWD
                        ),
                    },
                )
            except Exception:
                pass

    with _allure_step("Session 按需登录"):
        _v5 = _scenario_is_v5(phase1_scenario)
        for role, device in devices.items():
            _login_one(
                device,
                _account_user(role, phase1_scenario, created_test_users),
                _account_password(role, phase1_scenario),
                use_token=_v5,
            )
        roles_by_account: dict[str, list[str]] = {}
        for role in roles:
            roles_by_account.setdefault(
                _account_slot(role, phase1_scenario),
                [],
            ).append(role)
        for account, account_roles in roles_by_account.items():
            if len(account_roles) < 2:
                continue
            disconnected: list[dict] = []
            device_ids: dict[str, object] = {}
            for role in account_roles:
                connection = devices[role].call(
                    "Client",
                    Cmd.isConnected.value,
                    info={},
                )
                device_info = devices[role].call(
                    "Client",
                    Cmd.getCurrentDeviceId.value,
                    info={},
                )
                device_ids[role] = device_info.get("result")
                if connection.get("result") is not True:
                    disconnected.append(
                        {"role": role, "response": connection}
                    )
            if disconnected:
                pytest.exit(
                    "Environment Error: same-account concurrent login is not "
                    f"available for {account}. roles={account_roles}, "
                    f"deviceIds={device_ids}, disconnected={disconnected}. "
                    "The Android device IDs are distinct; enable multi-device "
                    "login for the test AppKey/server before running this topology.",
                    returncode=2,
                )

    yield

    with _allure_step("Session 按需登出"):
        for role, device in devices.items():
            try:
                device.call(
                    "Client",
                    Cmd.logout.value,
                    info={"unbindToken": False},
                )
            except Exception as error:
                try:
                    import allure

                    allure.attach(
                        str(error),
                        f"登出失败 {role}",
                        allure.attachment_type.TEXT,
                    )
                except ImportError:
                    pass


@pytest.fixture
def message_listener():
    """
    消息监听器工厂：传入设备标识返回对应的监听器。
    用法：listener = message_listener("deviceB")
    - .receive_message(match_cmd=..., match_event_type=..., timeout=...) 按条件取第一条。
    - 不匹配的消息会进缓冲；drain_buffer() 可一次性取出缓冲。
    - 用例结束自动 stop() 所有创建的监听器。
    """
    listeners = []

    def _create(device: str):
        topic = get_topic(device)
        listener = MessageListener(topic=topic, device=device)
        listener.start()
        listeners.append(listener)
        return listener

    yield _create

    for listener in listeners:
        listener.stop()


def _device_topic(device: str) -> str:
    """与 api_device_a / api_device_b 一致的 topic：根据设备从 config 的 topics 读取。"""
    return get_topic(device)


@pytest.fixture(scope="session")
def listener_a(ws_debug):
    """
    设备 A 的纯接收监听器，与 api_device_a 共用同一 topic（config 中 topics.deviceA）。
    - 发送请求-等待响应：使用 api_device_a.call(...)。
    - 主动获取推送消息：使用本 listener 的 .receive_message(...)。
    """
    topic = _device_topic("deviceA")
    listener = MessageListener(topic=topic, device="deviceA", debug=ws_debug)
    listener.start()
    yield listener
    listener.stop()


@pytest.fixture(scope="session")
def listener_b(ws_debug):
    """
    设备 B 的纯接收监听器，与 api_device_b 共用同一 topic（config 中 topics.deviceB）。
    - 发送请求-等待响应：使用 api_device_b.call(...)。
    - 主动获取推送消息：使用本 listener 的 .receive_message(...)。
    """
    topic = _device_topic("deviceB")
    listener = MessageListener(topic=topic, device="deviceB", debug=ws_debug)
    listener.start()
    yield listener
    listener.stop()


class _AllureEventPayload(dict):
    """Event dict with display-only device metadata kept outside its JSON keys."""

    def __init__(self, value: dict, *, source_device: str):
        super().__init__(value)
        self._allure_source_device = source_device


class _DeviceChannelWrapper:
    """
    对 DeviceConnection 的封装：同一连接上发请求-等响应 + 收推送，并挂 Allure。
    保证 A 的 addContact 与 onFriendRequestAccepted 走同一条连接，能收到回调。
    """

    def __init__(
        self,
        conn: DeviceConnection,
        device: str,
        *,
        resolver: CapabilityResolver | None = None,
        scenario_name: str | None = None,
        account_slot: str | None = None,
        account_user: str | None = None,
    ):
        self._conn = conn
        self._device = device
        self._resolver = resolver
        self._scenario_name = scenario_name
        self._account_slot = account_slot
        self._account_user = account_user
        self.topic = conn.topic

    def call(self, manager: str, cmd: str, info: dict | None = None, **kwargs):
        req = {"manager": manager, "cmd": cmd, "info": info or {}, "device": self._device, **kwargs}
        self.require_capability(manager, cmd)
        resp = self._conn.call(manager, cmd, info, **kwargs)
        report_response = self._conn.last_transport_response or resp
        _attach_request_response_allure(
            _api_step_name(manager, cmd, self._device, info),
            req,
            report_response,
        )
        return resp

    def require_capability(self, manager: str, cmd: str) -> None:
        if manager == "TestControl":
            return
        runner_info = self._conn.runner_info
        if self._resolver is not None:
            if runner_info is None:
                pytest.fail(
                    f"Framework Error: runner hello missing for {self._device}",
                    pytrace=False,
                )
            try:
                decision = self._resolver.require(runner_info, manager, cmd)
                # Successful capability checks are an implementation detail;
                # keep the Allure report focused on business steps. Detailed
                # capability data is still attached for skips/config errors.
            except UnsupportedCapability as error:
                decision = self._resolver.resolve(runner_info, manager, cmd).to_dict()
                _attach_capability_allure(decision)
                _attach_capability_skip_allure(decision)
                pytest.skip(str(error))
            except CapabilityConfigurationError as error:
                _attach_capability_allure(
                    self._resolver.resolve(runner_info, manager, cmd).to_dict()
                )
                pytest.fail(f"Framework/Configuration Error: {error}", pytrace=False)

    def attach_execution_context(self, *, include_parameters: bool = True) -> None:
        _attach_execution_context_allure(
            scenario_name=self._scenario_name,
            device=self._device,
            runner_info=self._conn.runner_info,
            account_slot=self._account_slot,
            account_user=self._account_user,
            include_parameters=include_parameters,
        )

    def receive_message(self, *, match_cmd=None, match_event_type=None, timeout=10.0):
        event = self._conn.receive_message(
            match_cmd=match_cmd,
            match_event_type=match_event_type,
            timeout=timeout,
        )
        if event is not None:
            event = _AllureEventPayload(event, source_device=self._device)
        return event

    def drain_events(self, timeout: float = 2.0) -> None:
        self._conn.drain_events(timeout=timeout)

    def begin_case(self, case_id: str) -> int:
        return self._conn.begin_case(case_id)

    def end_case(self) -> None:
        # Case 结束时把未消费事件写入 Allure，便于定位"等待事件超时"
        # 时到底收到了什么（连接状态变化、推送事件等）。
        pending = self._conn.drain_pending_events()
        if pending:
            try:
                import allure

                allure.attach(
                    json.dumps(
                        [_redact(event) for event in pending],
                        ensure_ascii=False,
                        indent=2,
                        default=str,
                    ),
                    f"Case 未消费事件 (device={self._device}, count={len(pending)})",
                    allure.attachment_type.JSON,
                )
            except ImportError:
                pass
        self._conn.end_case()

    def wait_for_hello(
        self,
        *,
        expected_sdk_version: str | None = None,
        expected_runner_id: str | None = None,
        expected_device_name: str | None = None,
        expected_platform: str | None = None,
        timeout: float = 120.0,
    ):
        return self._conn.wait_for_hello(
            expected_sdk_version=expected_sdk_version,
            expected_runner_id=expected_runner_id,
            expected_device_name=expected_device_name,
            expected_platform=expected_platform,
            timeout=timeout,
        )

    def clear_runner_info(self) -> None:
        self._conn.clear_runner_info()

    @property
    def runner_info(self):
        return self._conn.runner_info

    @property
    def device_name(self) -> str:
        return self._device


@dataclass(frozen=True)
class TopologyContext:
    """Semantic endpoints for one sender/recipient scenario topology."""

    name: str
    sender_user: str
    recipient_user: str
    sender_action_device: _DeviceChannelWrapper
    sender_devices: tuple[_DeviceChannelWrapper, ...]
    recipient_action_device: _DeviceChannelWrapper
    recipient_devices: tuple[_DeviceChannelWrapper, ...]
    sender_roles: tuple[str, ...]
    recipient_roles: tuple[str, ...]


def _attach_topology_allure(
    topology: TopologyContext,
    phase1_scenario,
) -> None:
    try:
        import allure

        def endpoint(role: str, device: _DeviceChannelWrapper) -> dict:
            spec = phase1_scenario.roles[role]
            return {
                "role": role,
                "account": spec.account,
                "platform": spec.platform,
                "sdkVersion": spec.sdk_version,
                "runnerId": spec.runner_id,
                "deviceName": spec.device_name,
                "runner": device.runner_info,
            }

        sender_by_role = dict(zip(topology.sender_roles, topology.sender_devices))
        recipient_by_role = dict(
            zip(topology.recipient_roles, topology.recipient_devices)
        )

        def display_endpoint(role: str) -> str:
            spec = phase1_scenario.roles[role]
            platform = str(spec.platform).replace("android", "Android").replace(
                "ios", "iOS"
            )
            return f"{spec.device_name}（{platform} · SDK {spec.sdk_version}）"

        action_role = next(
            role
            for role, device in sender_by_role.items()
            if device is topology.sender_action_device
        )
        recipient_action_role = next(
            role
            for role, device in recipient_by_role.items()
            if device is topology.recipient_action_device
        )
        sender_account = phase1_scenario.roles[action_role].account
        recipient_account = phase1_scenario.roles[
            topology.recipient_roles[0]
        ].account
        payload = {
            "name": topology.name,
            "sender": {
                "user": topology.sender_user,
                "actionRole": action_role,
                "devices": [
                    endpoint(role, device)
                    for role, device in sender_by_role.items()
                ],
            },
            "recipient": {
                "user": topology.recipient_user,
                "actionRole": recipient_action_role,
                "devices": [
                    endpoint(role, device)
                    for role, device in recipient_by_role.items()
                ],
            },
        }
        allure.dynamic.parameter("caseType", "scenario_topology")
        allure.dynamic.parameter("测试类型", "场景拓扑：一发一收账号多端")
        allure.dynamic.parameter("测试场景", phase1_scenario.name)
        allure.dynamic.parameter("拓扑", topology.name)
        allure.dynamic.parameter("发送账号", sender_account)
        allure.dynamic.parameter("动作发送端", display_endpoint(action_role))
        allure.dynamic.parameter(
            "发送端", "；".join(display_endpoint(role) for role in topology.sender_roles)
        )
        allure.dynamic.parameter("接收账号", recipient_account)
        allure.dynamic.parameter("接收端动作设备", display_endpoint(recipient_action_role))
        allure.dynamic.parameter(
            "接收端", "；".join(display_endpoint(role) for role in topology.recipient_roles)
        )
        allure.attach(
            "\n".join(
                (
                    "场景：一个发送账号动作端 → 一个接收账号全部在线端",
                    f"发送账号：{sender_account} / 动作端 {display_endpoint(action_role)}",
                    "发送账号在线端："
                    + "、".join(
                        display_endpoint(role) for role in topology.sender_roles
                    ),
                    f"接收：{recipient_account} / "
                    + "、".join(
                        display_endpoint(role) for role in topology.recipient_roles
                    ),
                    "预期：接收账号的每个在线端都收到同一条消息；后续接收方动作由指定设备执行。",
                )
            ),
            "拓扑摘要",
            allure.attachment_type.TEXT,
        )
        allure.attach(
            json.dumps(payload, ensure_ascii=False, indent=2, default=str),
            "Topology",
            allure.attachment_type.JSON,
        )
    except ImportError:
        pass


@pytest.fixture
def topology(request, phase1_scenario, device_pool, created_test_users):
    """Resolve the single semantic topology declared on the current case."""
    marker = request.node.get_closest_marker("topology")
    if marker is None or len(marker.args) != 1:
        raise pytest.UsageError(
            f"{request.node.nodeid} must declare exactly one "
            "@pytest.mark.topology('name') to use the topology fixture"
        )
    if phase1_scenario is None:
        raise pytest.UsageError("topology fixture requires --scenario")
    name = str(marker.args[0])
    try:
        spec = phase1_scenario.topologies[name]
    except KeyError as error:
        raise pytest.UsageError(
            f"Topology {name!r} is not defined by scenario "
            f"{phase1_scenario.name!r}"
        ) from error
    context = TopologyContext(
        name=name,
        sender_user=created_test_users[spec.sender_account],
        recipient_user=created_test_users[spec.recipient_account],
        sender_action_device=device_pool.get(spec.sender_action_device),
        sender_devices=tuple(
            device_pool.get(role) for role in spec.sender_devices
        ),
        recipient_action_device=device_pool.get(spec.recipient_action_device),
        recipient_devices=tuple(
            device_pool.get(role) for role in spec.recipient_devices
        ),
        sender_roles=spec.sender_devices,
        recipient_roles=spec.recipient_devices,
    )
    _attach_topology_allure(context, phase1_scenario)
    return context


def _attach_capability_allure(decision: dict) -> None:
    try:
        import allure

        allure.attach(
            json.dumps(decision, ensure_ascii=False, indent=2),
            f"Capability {decision.get('api')}",
            allure.attachment_type.JSON,
        )
    except ImportError:
        pass


def _attach_capability_skip_allure(decision: dict) -> None:
    """Make capability-gated skips understandable in the Allure summary."""
    try:
        import allure

        api = str(decision.get("api") or "未知 API")
        platform = str(decision.get("platform") or "未知平台")
        sdk_version = str(decision.get("sdkVersion") or "未知版本")
        matrix_supported = decision.get("matrixSupported")
        runner_reported = decision.get("runnerReported")
        reason = (
            f"能力前置检查跳过：{api} 未被 {platform} SDK {sdk_version} "
            "的 API Matrix 声明为支持能力。"
        )
        allure.dynamic.parameter("执行结论", "跳过：当前能力矩阵不支持该 API")
        allure.dynamic.parameter("跳过 API", api)
        allure.dynamic.parameter("跳过原因", reason)
        with allure.step(f"能力检查：{api}（不支持，跳过）"):
            allure.attach(
                "\n".join(
                    (
                        reason,
                        f"API Matrix 支持：{matrix_supported}",
                        f"Runner 上报支持：{runner_reported}",
                        "说明：命令未发送到设备；这不是业务回调失败。",
                    )
                ),
                "跳过说明",
                allure.attachment_type.TEXT,
            )
    except ImportError:
        pass


def _attach_execution_context_allure(
    *,
    scenario_name: str | None,
    device: str,
    runner_info: dict | None,
    account_slot: str | None = None,
    account_user: str | None = None,
    include_parameters: bool = True,
) -> None:
    try:
        import allure

        allure.attach(
            json.dumps(
                {
                    "scenario": scenario_name,
                    "logicalDevice": device,
                    "accountSlot": account_slot,
                    "account": account_user,
                    "runner": runner_info,
                },
                ensure_ascii=False,
                indent=2,
            ),
            f"Execution Context {device}",
            allure.attachment_type.JSON,
        )
    except ImportError:
        pass


def _register_runner(
    *,
    conn: DeviceConnection,
    logical_role: str,
    phase1_scenario,
    phase1_environment,
    registry: RunnerRegistry,
    resolver: CapabilityResolver | None,
):
    if phase1_scenario is None:
        return None
    role = phase1_scenario.roles[logical_role]
    hello = conn.wait_for_hello(
        expected_sdk_version=role.sdk_version,
        expected_runner_id=role.runner_id,
        expected_device_name=role.device_name,
        expected_platform=role.platform,
        timeout=phase1_scenario.hello_timeout,
    )
    if phase1_environment is not None:
        artifact = phase1_environment.artifact_for(logical_role)
        serial = phase1_environment.device_for(logical_role).serial or ""
    else:
        from src.orchestrator.config import Artifact

        artifact = Artifact(
            platform=role.platform,
            sdk_version=role.sdk_version,
            path=Path(),
            flavor="external",
            application_id="external",
            activity="external",
        )
        serial = role.serial or "external"
    binding = registry.register(
        role=role,
        artifact=artifact,
        serial=serial,
        hello=hello,
    )
    if resolver is not None:
        matrix = resolver.matrix_for(role.platform)
        if matrix is None:
            raise CapabilityConfigurationError(
                f"no API Matrix for platform={role.platform!r}"
            )
        matrix_capabilities = matrix.apis_for(role.sdk_version)
        if matrix_capabilities is None:
            raise CapabilityConfigurationError(
                f"sdkVersion={role.sdk_version!r} is absent from API Matrix"
            )
        artifact_capabilities = set(artifact.capabilities)
        if artifact_capabilities != {"*"} and artifact_capabilities != matrix_capabilities:
            raise CapabilityConfigurationError(
                "Artifact manifest capabilities conflict with API Matrix: "
                f"role={logical_role}, "
                f"manifestOnly={sorted(artifact_capabilities - matrix_capabilities)}, "
                f"matrixOnly={sorted(matrix_capabilities - artifact_capabilities)}"
            )
    try:
        import allure

        allure.attach(
            json.dumps(binding.hello, ensure_ascii=False, indent=2),
            f"Runner {logical_role}",
            allure.attachment_type.JSON,
        )
    except ImportError:
        pass
    return binding


def _device_channel(
    logical_role,
    ws_debug,
    phase1_environment,
    phase1_scenario,
    capability_resolver,
    runner_registry,
    ws_runtime,
):
    if phase1_scenario is not None:
        if logical_role not in phase1_scenario.roles:
            pytest.fail(
                f"Environment Error: scenario {phase1_scenario.name!r} "
                f"does not define {logical_role}",
                pytrace=False,
            )
        role = phase1_scenario.roles[logical_role]
        device_name = role.device_name
        conn = DeviceConnection(
            device=device_name,
            topic=ws_runtime.topic_for(device_name),
            base_url=ws_runtime.base_url,
            run_id=(
                ws_runtime.run_id
                if ws_runtime.mode == "managed"
                else None
            ),
            target_runner_id=(
                role.runner_id
                if ws_runtime.mode == "managed"
                else None
            ),
            debug=ws_debug,
        )
    else:
        device_name = {
            "device_a": "deviceA",
            "device_a_sec": "deviceASec",
            "device_b": "deviceB",
            "device_b_sec": "deviceBSec",
            "device_c": "deviceC",
            "device_c_sec": "deviceCSec",
        }[logical_role]
        conn = DeviceConnection(device=device_name, debug=ws_debug)
    conn.start()
    try:
        account_slot = _account_slot(logical_role, phase1_scenario)
        generated_users = _scenario_usernames(
            ws_runtime.run_id,
            (
                tuple(phase1_scenario.accounts)
                if phase1_scenario is not None
                else ("account_a", "account_b", "account_c")
            ),
        )
        account_spec = (
            phase1_scenario.accounts.get(account_slot)
            if phase1_scenario is not None
            else None
        )
        account_user = (
            account_spec.username
            if account_spec is not None
            and account_spec.provision == "existing"
            else _account_user(
                logical_role,
                phase1_scenario,
                generated_users,
            )
        )
        _register_runner(
            conn=conn,
            logical_role=logical_role,
            phase1_scenario=phase1_scenario,
            phase1_environment=phase1_environment,
            registry=runner_registry,
            resolver=capability_resolver,
        )
        yield _DeviceChannelWrapper(
            conn,
            device_name,
            resolver=capability_resolver,
            scenario_name=phase1_scenario.name if phase1_scenario else None,
            account_slot=account_slot,
            account_user=account_user,
        )
    finally:
        conn.stop()


class _DevicePool:
    """Session-scoped channels keyed by arbitrary scenario role names."""

    def __init__(
        self,
        *,
        ws_debug,
        phase1_environment,
        phase1_scenario,
        capability_resolver,
        runner_registry,
        ws_runtime,
    ) -> None:
        self._dependencies = {
            "ws_debug": ws_debug,
            "phase1_environment": phase1_environment,
            "phase1_scenario": phase1_scenario,
            "capability_resolver": capability_resolver,
            "runner_registry": runner_registry,
            "ws_runtime": ws_runtime,
        }
        self._channels: dict[str, _DeviceChannelWrapper] = {}
        self._generators: dict[str, object] = {}

    def get(self, role: str) -> _DeviceChannelWrapper:
        if role in self._channels:
            return self._channels[role]
        generator = _device_channel(role, **self._dependencies)
        try:
            channel = next(generator)
        except StopIteration as error:
            raise RuntimeError(f"Device channel {role!r} did not initialize") from error
        self._channels[role] = channel
        self._generators[role] = generator
        return channel

    def close(self) -> None:
        for role, generator in reversed(tuple(self._generators.items())):
            try:
                next(generator)
            except StopIteration:
                pass
            else:
                raise RuntimeError(f"Device channel {role!r} did not finish")
        self._generators.clear()
        self._channels.clear()


@pytest.fixture(scope="session")
def device_pool(
    ws_debug,
    phase1_environment,
    phase1_scenario,
    capability_resolver,
    runner_registry,
    ws_runtime,
):
    """Get an already deployed Runner channel by its scenario role."""
    pool = _DevicePool(
        ws_debug=ws_debug,
        phase1_environment=phase1_environment,
        phase1_scenario=phase1_scenario,
        capability_resolver=capability_resolver,
        runner_registry=runner_registry,
        ws_runtime=ws_runtime,
    )
    try:
        yield pool
    finally:
        pool.close()


@pytest.fixture(scope="session")
def device_a(device_pool):
    return device_pool.get("device_a")


@pytest.fixture(scope="session")
def device_a_sec(device_pool):
    return device_pool.get("device_a_sec")


@pytest.fixture(scope="session")
def device_b(device_pool):
    return device_pool.get("device_b")


@pytest.fixture(scope="session")
def device_b_sec(device_pool):
    return device_pool.get("device_b_sec")


@pytest.fixture(scope="session")
def device_c(device_pool):
    return device_pool.get("device_c")


@pytest.fixture(scope="session")
def device_c_sec(device_pool):
    return device_pool.get("device_c_sec")


@pytest.fixture(autouse=True)
def case_event_context(request, phase1_scenario, device_pool):
    """Create per-Case event cursors and attach common Allure metadata."""
    fixture_info = getattr(request.node, "_fixtureinfo", None)
    direct_names = tuple(getattr(fixture_info, "argnames", ()) or ())
    topology_roles = _topology_roles_for_item(request.node, phase1_scenario)
    initial_names = tuple(getattr(fixture_info, "initialnames", ()) or ())
    legacy_aliases = {
        "api_device_a": "device_a",
        "api_device_b": "device_b",
        "listener_a": "device_a",
        "listener_b": "device_b",
    }
    roles_set = set(DEVICE_ROLE_NAMES.intersection(direct_names))
    for fixture_name, role in legacy_aliases.items():
        if fixture_name in direct_names or fixture_name in initial_names:
            roles_set.add(role)
    roles = sorted(roles_set.union(topology_roles))
    _attach_case_allure_metadata(request, phase1_scenario, tuple(roles))
    devices = [device_pool.get(role) for role in roles]
    case_id = request.node.nodeid
    try:
        import allure

        if not topology_roles:
            allure.dynamic.parameter(
                "caseType",
                _direct_case_type(phase1_scenario, tuple(roles)),
            )
    except ImportError:
        pass
    with _allure_step("测试准备：建立设备事件上下文"):
        for device in devices:
            device.begin_case(case_id)
            device.attach_execution_context(include_parameters=not topology_roles)
    try:
        with _allure_step("测试执行：Case 业务步骤"):
            yield
    finally:
        with _allure_step("测试后置：结束设备事件上下文"):
            for device in devices:
                device.end_case()


@pytest.fixture
def network_control(phase1_environment):
    """Case-scoped network control; always restores every touched Runner."""
    if phase1_environment is None:
        pytest.skip("network_control requires a managed scenario")
    offline_roles: set[str] = set()

    class _NetworkControl:
        @staticmethod
        def offline(role: str) -> None:
            output = phase1_environment.device_for(role).set_network_enabled(
                False
            )
            offline_roles.add(role)
            _attach_network_control_allure(role, False, output)

        @staticmethod
        def online(role: str) -> None:
            output = phase1_environment.device_for(role).set_network_enabled(
                True
            )
            offline_roles.discard(role)
            _attach_network_control_allure(role, True, output)

    try:
        yield _NetworkControl()
    finally:
        for role in sorted(offline_roles):
            try:
                output = phase1_environment.device_for(
                    role
                ).set_network_enabled(True)
                _attach_network_control_allure(role, True, output)
            except Exception as error:
                _attach_network_control_allure(role, True, str(error))


def _attach_network_control_allure(
    role: str,
    enabled: bool,
    output: str,
) -> None:
    try:
        import allure

        allure.attach(
            json.dumps(
                {
                    "logicalDevice": role,
                    "networkEnabled": enabled,
                    "output": output,
                },
                ensure_ascii=False,
                indent=2,
            ),
            f"Network {'online' if enabled else 'offline'} {role}",
            allure.attachment_type.JSON,
        )
    except ImportError:
        pass


@pytest.fixture
def scenario_resources():
    """Case-scoped resource registry; teardown always runs, even after failure."""
    registry = ResourceRegistry()
    try:
        yield registry
    finally:
        results = registry.cleanup_all()
        try:
            import allure

            allure.attach(
                json.dumps(
                    [
                        {
                            "kind": item.kind,
                            "resourceId": item.resource_id,
                            "success": item.success,
                            "error": item.error,
                        }
                        for item in results
                    ],
                    ensure_ascii=False,
                    indent=2,
                ),
                "场景资源清理",
                allure.attachment_type.JSON,
            )
        except ImportError:
            pass


@pytest.fixture
def assert_api():
    """提供断言方法的 fixture：assert_api.assert_success(resp), assert_api.get_result(resp) 等。"""
    return assertions


@pytest.fixture
def upgrade_runner(
    request,
    phase1_environment,
    phase1_scenario,
    device_a,
    user_a,
    ws_runtime,
):
    if phase1_environment is None or phase1_scenario is None:
        pytest.skip("upgrade_runner requires --scenario and --manage-runners")
    role = phase1_scenario.roles["device_a"]
    old_artifact = phase1_environment.artifact_for("device_a")
    new_artifact = next(
        artifact
        for (platform, version), artifact in EnvironmentManager(
            _resolve_repo_path(
                str(request.config.getoption("--scenario")),
                folder="config/scenarios",
            ),
            _resolve_repo_path(str(request.config.getoption("--artifacts"))),
            web_socket_base_url=ws_runtime.base_url,
            topics={},
        ).artifact_catalog.items()
        if platform == "android" and version == "4.14.0"
    )
    return UpgradeRunner(
        device=phase1_environment.device_for("device_a"),
        channel=device_a,
        role=role,
        old_artifact=old_artifact,
        new_artifact=new_artifact,
        topic=ws_runtime.topic_for(role.device_name),
        web_socket_base_url=ws_runtime.base_url,
        startup_timeout=phase1_scenario.startup_timeout,
        user_id=user_a,
        password=SESSION_PWD,
        run_id=ws_runtime.run_id,
        managed_web_socket=ws_runtime.mode == "managed",
    )


def pytest_sessionstart(session):
    """Build the selected platform Runners before running tests if --build is set."""
    if not session.config.getoption("--build", default=False):
        return
    scenario_path = str(session.config.getoption("--scenario") or "")
    if not scenario_path:
        return
    from src.orchestrator.config import load_scenario
    path = _resolve_repo_path(scenario_path, folder="config/scenarios")
    scenario = load_scenario(path)
    flavors = set()
    for role in scenario.roles.values():
        if role.platform != "android":
            continue
        # sdk_version like "4.23.0" → flavor like "sdk423"; "5.0.0" → "sdk500"（minor 补 2 位）
        parts = role.sdk_version.split(".")
        ver = f"{parts[0]}{int(parts[1]):02d}"
        flavors.add(f"sdk{ver}")
    for flavor in sorted(flavors):
        import subprocess, shutil
        flutter_test = Path(__file__).resolve().parent.parent.parent / "im_flutter_test"
        flutter = os.getenv("FLUTTER_BIN") or shutil.which("flutter")
        if not flutter:
            raise RuntimeError("flutter not found; set FLUTTER_BIN")
        subprocess.run(
            [flutter, "build", "apk", "--debug", "--flavor", flavor],
            cwd=flutter_test,
            check=True,
        )
        # build 后 APK hash 必然变化，自动更新对应 Manifest 的
        # artifactSha256，避免下次不带 --build 时 hash 校验失败。
        _refresh_artifact_hash(flavor, flutter_test)

    if any(role.platform == "web" for role in scenario.roles.values()):
        import shutil

        npm = shutil.which("npm")
        if not npm:
            raise RuntimeError("npm not found; Web Runner requires Node.js/npm")
        web_runner = Path(__file__).resolve().parent.parent / "web_runner"
        subprocess.run([npm, "install"], cwd=web_runner, check=True)
        subprocess.run([npm, "run", "build"], cwd=web_runner, check=True)


def _refresh_artifact_hash(flavor: str, flutter_test: Path) -> None:
    """重新计算 flavor APK 的 SHA-256 并写回 Artifact Manifest。"""
    import hashlib
    import json

    apk = flutter_test / "build" / "app" / "outputs" / "flutter-apk" / f"app-{flavor}-debug.apk"
    if not apk.is_file():
        print(f"[build] APK not found after build: {apk}")
        return
    digest = hashlib.sha256(apk.read_bytes()).hexdigest()
    version = flavor.replace("sdk", "")
    # sdk423 → 4.23.0
    dotted = f"{version[0]}.{int(version[1:])}.0"
    manifest_path = (
        Path(__file__).resolve().parent.parent
        / "config" / "artifact_manifests" / f"android-{dotted}.json"
    )
    if not manifest_path.is_file():
        print(f"[build] manifest not found: {manifest_path}")
        return
    data = json.loads(manifest_path.read_text(encoding="utf-8"))
    data["artifactSha256"] = digest
    manifest_path.write_text(
        json.dumps(data, indent=2, ensure_ascii=False),
        encoding="utf-8",
    )
    print(f"[build] updated {manifest_path.name} artifactSha256={digest[:12]}…")


def pytest_configure(config):
    """注册自定义 marker；报告见 README（pytest-html / allure）。"""
    config.addinivalue_line("markers", "client: Client manager API tests")
    config.addinivalue_line("markers", "chat: ChatManager API tests")
    config.addinivalue_line("markers", "group: GroupManager / group API tests")
    config.addinivalue_line("markers", "contact: ContactManager / friend API tests")
    config.addinivalue_line("markers", "presence: PresenceManager / online status tests")
    config.addinivalue_line("markers", "multi_device: tests requiring multiple devices/topics")
    config.addinivalue_line(
        "markers",
        "topology(*names): named scenario topologies required by this case",
    )
    config.addinivalue_line("markers", "agorachat4_23_0: AgoraChat SDK 4.23.0 release coverage tests")
    config.addinivalue_line("markers", "phase1: first-stage multi-version runner acceptance")
    config.addinivalue_line("markers", "upgrade: coverage-install data retention tests")
