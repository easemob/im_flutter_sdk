"""共享运行时配置读取。

环境信息与桥接运行态分离在两个文件：

- 环境文件（``app:`` schema，与 im-test-hub 一致）：
  ``app.appkey`` / ``app.server.*`` / ``app.sdk.*`` / ``app.datasync.*``。
- 桥接文件：``websocket`` / ``topics``，只描述本机 relay 连接信息。

文件选择优先级：

- 环境：``IM_TEST_CONFIG`` > ``<repo>/config/config.yaml``
- 桥接：``IM_BRIDGE_CONFIG`` > ``<repo>/config/bridge.yaml``

三者都不存在时直接抛 ``RuntimeError``，不再回退到根目录旧 ``config.yaml``。
"""
from __future__ import annotations

import os
from functools import lru_cache
from pathlib import Path
from typing import Any

import yaml

_HERE = Path(__file__).resolve()
# src/tools/config.py -> <repo>
_REPO_ROOT = _HERE.parents[2]

_ENV_VAR = "IM_TEST_CONFIG"
_BRIDGE_VAR = "IM_BRIDGE_CONFIG"
_DEFAULT_ENV_FILE = _REPO_ROOT / "config" / "config.yaml"
_DEFAULT_BRIDGE_FILE = _REPO_ROOT / "config" / "bridge.yaml"

_DEFAULT_BRIDGE_WS: dict[str, Any] = {
    "base_url": "ws://127.0.0.1:4000/iov/websocket/dual",
    "default_topic": "adc",
    "connect_timeout": 10,
    "response_timeout": 30,
}


def _resolve(env_var: str, default: Path, label: str) -> Path:
    override = os.getenv(env_var, "").strip()
    if override:
        candidate = Path(override).expanduser()
        if not candidate.is_absolute():
            candidate = Path.cwd() / candidate
        candidate = candidate.resolve()
        if not candidate.is_file():
            raise RuntimeError(f"{env_var} 指向的{label}文件不存在: {candidate}")
        return candidate
    if default.is_file():
        return default.resolve()
    raise RuntimeError(
        f"未找到{label}文件：请通过 {env_var} 指定，或放置默认文件 {default}"
    )


def resolve_env_config_path() -> Path:
    """环境文件路径：IM_TEST_CONFIG > <repo>/config/config.yaml。"""
    return _resolve(_ENV_VAR, _DEFAULT_ENV_FILE, "环境配置")


def resolve_bridge_config_path() -> Path:
    """桥接文件路径：IM_BRIDGE_CONFIG > <repo>/config/bridge.yaml。"""
    return _resolve(_BRIDGE_VAR, _DEFAULT_BRIDGE_FILE, "桥接配置")


def _load_yaml(path: Path) -> dict[str, Any]:
    with open(path, encoding="utf-8") as f:
        data = yaml.safe_load(f)
    if data is None:
        return {}
    if not isinstance(data, dict):
        raise RuntimeError(f"配置文件根节点必须是映射: {path}")
    return data


@lru_cache(maxsize=8)
def _load_yaml_cached(path: str) -> dict[str, Any]:
    return _load_yaml(Path(path))


def load_env_config() -> dict[str, Any]:
    """读取并缓存环境文件（``app:`` schema）。"""
    return _load_yaml_cached(str(resolve_env_config_path()))


def load_bridge_config() -> dict[str, Any]:
    """读取并缓存桥接文件；含 ``websocket`` / ``topics``。"""
    return _load_yaml_cached(str(resolve_bridge_config_path()))


# ---------------------------------------------------------------------------
# app schema accessors
# ---------------------------------------------------------------------------


def _app() -> dict[str, Any]:
    app = load_env_config().get("app")
    return app if isinstance(app, dict) else {}


def _server() -> dict[str, Any]:
    server = _app().get("server")
    return server if isinstance(server, dict) else {}


def _sdk() -> dict[str, Any]:
    sdk = _app().get("sdk")
    return sdk if isinstance(sdk, dict) else {}


def get_case_timing_config() -> dict[str, Any]:
    """Python cases-only timing section; never expose the rest of the environment."""
    timing = _app().get("case_timing", {})
    if not isinstance(timing, dict):
        raise ValueError("app.case_timing must be a mapping")
    return timing


def get_appkey() -> str:
    return str(_app().get("appkey") or "").strip()


def get_server_base_url() -> str:
    """Server REST 主机（仅协议 + 主机，去尾部斜杠）。"""
    return str(_server().get("base_url") or "").strip().rstrip("/")


def get_client_id() -> str:
    return str(_server().get("client_id") or "").strip()


def get_client_secret() -> str:
    return str(_server().get("client_secret") or "").strip()


def has_rest_credentials() -> bool:
    """是否具备 client_credentials 换取 REST token 的凭据。"""
    return bool(get_client_id() and get_client_secret())


def get_rest_base_url() -> str:
    """由 server.base_url 与 appkey（org#app）派生 REST base URL。

    返回 ``{server.base_url}/{org}/{app}``；任一来源缺失或 appkey 不含 ``#`` 时返回空串。
    """
    base = get_server_base_url()
    appkey = get_appkey()
    if not base or "#" not in appkey:
        return ""
    org, app = appkey.split("#", 1)
    org, app = org.strip(), app.strip()
    if not org or not app:
        return ""
    return f"{base}/{org}/{app}"


def get_rest_verify_ssl() -> bool:
    """REST HTTPS 证书校验开关；缺失默认 ``True``。"""
    return bool(_server().get("verify_ssl", True))


# ---------------------------------------------------------------------------
# bridge accessors
# ---------------------------------------------------------------------------


def _ws() -> dict[str, Any]:
    ws = load_bridge_config().get("websocket")
    return ws if isinstance(ws, dict) else {}


def get_ws_base_url() -> str:
    env_url = os.getenv("WS_BASE_URL", "").strip()
    if env_url:
        return env_url
    value = str(_ws().get("base_url") or "").strip()
    return value or str(_DEFAULT_BRIDGE_WS["base_url"])


def get_default_topic() -> str:
    value = str(_ws().get("default_topic") or "").strip()
    return value or str(_DEFAULT_BRIDGE_WS["default_topic"])


def get_connect_timeout() -> float:
    return float(_ws().get("connect_timeout", _DEFAULT_BRIDGE_WS["connect_timeout"]))


def get_response_timeout() -> float:
    return float(_ws().get("response_timeout", _DEFAULT_BRIDGE_WS["response_timeout"]))


def get_topic(device: str | None = None) -> str:
    """多端测试时可按 device 取不同 topic；缺失/为空回退 default_topic。"""
    topics = load_bridge_config().get("topics") or {}
    if device and isinstance(topics, dict) and device in topics:
        value = str(topics[device] or "").strip()
        if value:
            return value
    return get_default_topic()


def get_ws_debug() -> dict[str, Any]:
    """桥接 ``websocket.debug`` 节；缺失时返回空 dict。"""
    debug = _ws().get("debug")
    return debug if isinstance(debug, dict) else {}
