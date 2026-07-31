"""加载 config.yaml 中的 WebSocket 配置。"""
import os
from pathlib import Path
from typing import Any

import yaml

_CONFIG: dict[str, Any] | None = None
_HERE = Path(__file__).resolve()
# 尝试定位仓库根目录（包含 config.yaml 的目录）
for cand in (_HERE.parent, _HERE.parent.parent, _HERE.parent.parent.parent):
    if (cand / "config.yaml").exists():
        _ROOT = cand
        break
else:
    _ROOT = _HERE.parent.parent  # 回退到 src


def load_config() -> dict[str, Any]:
    global _CONFIG
    if _CONFIG is None:
        config_path = _ROOT / "config.yaml"
        if config_path.exists():
            with open(config_path, encoding="utf-8") as f:
                _CONFIG = yaml.safe_load(f) or {}
        else:
            _CONFIG = {
                "websocket": {
                    "base_url": "ws://140.143.132.6:2000/iov/websocket/dual",
                    "default_topic": "adc",
                    "connect_timeout": 10,
                    "response_timeout": 30,
                }
            }
    return _CONFIG


def get_ws_base_url() -> str:
    override = os.getenv("NATIVE_TEST_WS_BASE_URL", "").strip()
    value = (load_config().get("websocket") or {}).get("base_url")
    return override or str(value or "")


def get_default_topic() -> str:
    return str((load_config().get("websocket") or {}).get("default_topic") or "default")


def get_connect_timeout() -> float:
    return float(load_config()["websocket"].get("connect_timeout", 10))


def get_response_timeout() -> float:
    override = os.getenv("NATIVE_TEST_RESPONSE_TIMEOUT", "").strip()
    if override:
        return float(override)
    return float(load_config()["websocket"].get("response_timeout", 30))


def get_topic(device: str | None = None) -> str:
    """多端测试时可按 device 取不同 topic。"""
    if device:
        override = os.getenv(f"NATIVE_TEST_TOPIC_{device.upper()}", "").strip()
        if override:
            return override
    cfg = load_config()
    topics = cfg.get("topics") or {}
    if device and device in topics:
        return topics[device]
    return str((cfg.get("websocket") or {}).get("default_topic") or "default")


def get_rest_base_url() -> str:
    """REST 用户管理 base URL（创建/删除用户）。"""
    cfg = load_config()
    rest = cfg.get("rest_api") or {}
    return (rest.get("base_url") or "").strip()


def get_rest_auth_token() -> str:
    """REST 用户管理 Bearer token。仅读取 config.yaml -> rest_api.auth_token。"""
    cfg = load_config()
    rest = cfg.get("rest_api") or {}
    return (rest.get("auth_token") or "").strip()


def get_rest_verify_ssl() -> bool:
    """
    REST HTTPS 证书校验开关。
    - True（默认）：校验证书
    - False：跳过证书校验（仅测试环境临时使用）
    """
    cfg = load_config()
    rest = cfg.get("rest_api") or {}
    return bool(rest.get("verify_ssl", True))


def get_sdk_options() -> dict:
    """返回 config.yaml 中的 sdk_options 节（Flutter SDK EMOptions 配置）。"""
    cfg = load_config()
    return cfg.get("sdk_options") or {}


def get_sdk_app_key() -> str:
    """返回 sdk_options.app_key。"""
    return get_sdk_options().get("app_key", "")
