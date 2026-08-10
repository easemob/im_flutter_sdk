"""
Pytest fixtures：WebSocket 配置、topic、请求封装等。
全局登录/登出：session 开始时对所有设备登录，session 结束时登出，用例内不需要写 login/logout。
Allure：请求、响应、比对结果会写入报告（需安装 allure-pytest，运行 pytest --alluredir=...）。
"""
from __future__ import annotations

import json
import os
import sys
import time
from contextlib import nullcontext
from pathlib import Path

import pytest

# 保证能 import src
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from src.tools.config import get_default_topic, get_topic, get_rest_auth_token
from src.rest_api.user_api import create_users, delete_user
from src.tools.ws_client import (
    request as ws_request,
    request_and_wait_for_event as ws_request_and_wait_event,
    MessageListener,
    DeviceConnection,
)
from src.tools import assertions
from src.tools.group_capacity import (
    configure_group_create_max_count,
    reset_group_create_max_count,
)
from src import Cmd

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
                json.dumps(request_body, ensure_ascii=False, indent=2),
                "请求",
                allure.attachment_type.JSON,
            )
            allure.attach(
                json.dumps(response_body, ensure_ascii=False, indent=2, default=str),
                "响应",
                allure.attachment_type.JSON,
            )
    except ImportError:
        pass


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
    def positive_int(value: str) -> int:
        parsed = int(value)
        if parsed <= 0:
            raise ValueError("must be a positive integer")
        return parsed

    parser.addoption(
        "--group-create-max-count",
        action="store",
        type=positive_int,
        default=200,
        metavar="COUNT",
        help="Maximum members for ordinary Group create requests; default: 200.",
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
        _attach_request_response_allure(f"API 请求 {manager}.{cmd} (device={device})", req, resp)
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


def _test_usernames() -> tuple[str, str, str]:
    """生成测试用例用的两个用户名：test + 月日 + user1/user2。"""
    from datetime import datetime
    mmdd = datetime.now().strftime("%m%d")
    return f"test{mmdd}user1", f"test{mmdd}user2", f"test{mmdd}user3"


@pytest.fixture(scope="session")
def created_test_users():
    """
    Session 内创建两名用户供所有测试用例使用，teardown 时删除。
    若未配置 REST auth_token（config.yaml -> rest_api.auth_token），则不创建/不删除，直接使用日期用户名。
    返回 (user_a, user_b)。
    """
    global _LAST_CREATE_USERS_ERROR
    _LAST_CREATE_USERS_ERROR = ""
    keep_users = os.getenv("KEEP_TEST_USERS", "0") in ("1", "true", "True")
    token = get_rest_auth_token()
    # 优先使用日期用户名，避免固定回退账号与被测端不一致
    user_a, user_b, user_c = _test_usernames()
    if not token:
        # 无 REST token：直接使用日期用户名，不创建
        yield user_a, user_b, user_c
        return
    with _allure_step("创建测试用户"):
        create_resp = create_users([
            {"username": user_a, "password": SESSION_PWD},
            {"username": user_b, "password": SESSION_PWD},
            {"username": user_c, "password": SESSION_PWD},
        ])
    if isinstance(create_resp, dict) and create_resp.get("error"):
        _LAST_CREATE_USERS_ERROR = json.dumps(create_resp, ensure_ascii=False, indent=2, default=str)
        print(
            "[created_test_users] REST 自动创建用户失败，已降级为直接使用日期用户名。\n"
            f"{_LAST_CREATE_USERS_ERROR}",
            file=sys.stderr,
            flush=True,
        )
        try:
            import allure
            allure.attach(
                _LAST_CREATE_USERS_ERROR,
                "创建用户失败，降级使用日期用户名",
                allure.attachment_type.TEXT,
            )
        except ImportError:
            pass
        created = False
    else:
        created = True
        # REST 创建成功后等待服务端用户数据完成可见，再开始登录和执行 cases。
        time.sleep(5.0)
    try:
        yield user_a, user_b, user_c
    finally:
        if created and not keep_users:
            with _allure_step("删除测试用户"):
                for u in (user_a, user_b, user_c):
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
    return created_test_users[0]


@pytest.fixture(scope="session")
def user_b(created_test_users):
    """设备 B 对应用户名（session 内创建，teardown 删除）。"""
    return created_test_users[1]

@pytest.fixture(scope="session")
def user_c(created_test_users):
    """设备 A 对应用户名（session 内创建，teardown 删除）。"""
    return created_test_users[2]

@pytest.fixture(scope="session", autouse=True)
def global_login_logout(device_a, device_b, created_test_users):
    """
    全 session 只执行一次（autouse=True）：
    - setup：用 created_test_users 的两人在 device_a/device_b 上登录并清空回调。
    - teardown：登出两设备。用户删除由 created_test_users 的 teardown 负责。
    """
    user_a, user_b, user_c = created_test_users
    _session_login(device_a, device_b, user_a, user_b, SESSION_PWD)
    yield
    _session_logout(device_a, device_b)


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


class _DeviceChannelWrapper:
    """
    对 DeviceConnection 的封装：同一连接上发请求-等响应 + 收推送，并挂 Allure。
    保证 A 的 addContact 与 onFriendRequestAccepted 走同一条连接，能收到回调。
    """

    def __init__(self, conn: DeviceConnection, device: str):
        self._conn = conn
        self._device = device
        self.topic = conn.topic

    def call(self, manager: str, cmd: str, info: dict | None = None, **kwargs):
        req = {"manager": manager, "cmd": cmd, "info": info or {}, "device": self._device, **kwargs}
        resp = self._conn.call(manager, cmd, info, **kwargs)
        _attach_request_response_allure(
            f"API 请求 {manager}.{cmd} (device={self._device})",
            req,
            resp,
        )
        return resp

    def receive_message(self, *, match_cmd=None, match_event_type=None, timeout=10.0):
        return self._conn.receive_message(
            match_cmd=match_cmd,
            match_event_type=match_event_type,
            timeout=timeout,
        )

    def drain_events(self, timeout: float = 2.0) -> None:
        self._conn.drain_events(timeout=timeout)


@pytest.fixture(scope="session")
def device_a(ws_debug):
    """
    设备 A 的单连接双工通道：同一 WebSocket 上 .call() 发请求、.receive_message() 收推送。
    登录、addContact、onFriendRequestAccepted 等均走该连接，保证能收到服务端回调。
    """
    conn = DeviceConnection(device="deviceA")
    conn.start()
    try:
        yield _DeviceChannelWrapper(conn, "deviceA")
    finally:
        conn.stop()


@pytest.fixture(scope="session")
def device_b(ws_debug):
    """
    设备 B 的单连接双工通道：同一 WebSocket 上 .call() 发请求、.receive_message() 收推送。
    """
    conn = DeviceConnection(device="deviceB")
    conn.start()
    try:
        yield _DeviceChannelWrapper(conn, "deviceB")
    finally:
        conn.stop()


@pytest.fixture
def assert_api():
    """提供断言方法的 fixture：assert_api.assert_success(resp), assert_api.get_result(resp) 等。"""
    return assertions


def pytest_configure(config):
    """注册自定义 marker；报告见 README（pytest-html / allure）。"""
    configure_group_create_max_count(config.getoption("--group-create-max-count"))
    config.addinivalue_line("markers", "client: Client manager API tests")
    config.addinivalue_line("markers", "chat: ChatManager API tests")
    config.addinivalue_line("markers", "group: GroupManager / group API tests")
    config.addinivalue_line("markers", "contact: ContactManager / friend API tests")
    config.addinivalue_line("markers", "presence: PresenceManager / online status tests")
    config.addinivalue_line("markers", "multi_device: tests requiring multiple devices/topics")
    config.addinivalue_line("markers", "agorachat4_23_0: AgoraChat SDK 4.23.0 release coverage tests")


def pytest_unconfigure(config):
    """pytest 结束后清空本进程的容量场景，便于嵌入式重复运行。"""
    reset_group_create_max_count()
