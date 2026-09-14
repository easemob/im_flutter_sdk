"""共享运行时配置读取测试（环境文件 + 桥接文件，不依赖设备/网络）。"""
from __future__ import annotations

from pathlib import Path

import pytest

from src.tools import config

ENV_YAML = """
app:
  cluster: ebs
  appkey: "easemob#test"
  wait: 3
  imm:
    url: ""
    username: ""
    password: ""
    cluster: ""
  server:
    base_url: "https://a1.easemob.com/"
    client_id: "cid"
    client_secret: "secret"
  sdk:
    user_login_password: "1"
    rest_host: "https://a1.easemob.com"
    msync:
      protocol: websocket
      tcp_host: ""
      tcp_port: ""
      websocket_host: ""
      websocket_port: ""
      enable_lz4: "0"
      compress_algorimth: COMPRESS_ZLIB
      sync_delay: 5000
  datasync:
    websocket_host: ""
    websocket_port: ""
    websocket_path: /ws
    use_ssl: "1"
  log:
    enable_file_log: "1"
    log_dir: log
him23003:
  route_profile: ebs
"""

BRIDGE_YAML = """
websocket:
  base_url: "ws://127.0.0.1:4000/iov/websocket/dual"
  default_topic: "adc"
  connect_timeout: 10
  response_timeout: 30
  debug:
    dump_events: true
    relax_event_match: false
    sniff_seconds: 20
topics:
  deviceA: adc
  deviceB: adc01
"""


@pytest.fixture(autouse=True)
def _clear_cache():
    config._load_yaml_cached.cache_clear()
    yield
    config._load_yaml_cached.cache_clear()


@pytest.fixture
def env_file(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Path:
    path = tmp_path / "env.yaml"
    path.write_text(ENV_YAML, encoding="utf-8")
    monkeypatch.setenv("IM_TEST_CONFIG", str(path))
    return path


@pytest.fixture
def bridge_file(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Path:
    path = tmp_path / "bridge.yaml"
    path.write_text(BRIDGE_YAML, encoding="utf-8")
    monkeypatch.setenv("IM_BRIDGE_CONFIG", str(path))
    return path


# ---------------------------------------------------------------------------
# 文件选择优先级
# ---------------------------------------------------------------------------


def test_env_config_uses_explicit_env_var(env_file: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(config, "_DEFAULT_ENV_FILE", Path("/nonexistent/config.yaml"))
    assert config.resolve_env_config_path() == env_file.resolve()
    assert config.load_env_config()["app"]["cluster"] == "ebs"


def test_env_config_falls_back_to_default(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.delenv("IM_TEST_CONFIG", raising=False)
    default = tmp_path / "config.yaml"
    default.write_text(ENV_YAML, encoding="utf-8")
    monkeypatch.setattr(config, "_DEFAULT_ENV_FILE", default)
    assert config.resolve_env_config_path() == default.resolve()


def test_env_config_missing_raises(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("IM_TEST_CONFIG", str(tmp_path / "missing.yaml"))
    monkeypatch.setattr(config, "_DEFAULT_ENV_FILE", tmp_path / "also-missing.yaml")
    with pytest.raises(RuntimeError, match="IM_TEST_CONFIG"):
        config.resolve_env_config_path()


def test_env_config_nonexistent_override_does_not_fall_back(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    default = tmp_path / "config.yaml"
    default.write_text(ENV_YAML, encoding="utf-8")
    monkeypatch.setattr(config, "_DEFAULT_ENV_FILE", default)
    monkeypatch.setenv("IM_TEST_CONFIG", str(tmp_path / "missing.yaml"))
    with pytest.raises(RuntimeError, match="不存在"):
        config.resolve_env_config_path()


def test_bridge_config_priority_and_missing(
    bridge_file: Path, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.setattr(config, "_DEFAULT_BRIDGE_FILE", tmp_path / "bridge.yaml")
    assert config.resolve_bridge_config_path() == bridge_file.resolve()

    monkeypatch.setenv("IM_BRIDGE_CONFIG", str(tmp_path / "missing.yaml"))
    with pytest.raises(RuntimeError, match="IM_BRIDGE_CONFIG"):
        config.resolve_bridge_config_path()


# ---------------------------------------------------------------------------
# 未知字段容错 / schema
# ---------------------------------------------------------------------------


def test_unknown_fields_are_tolerated(env_file: Path) -> None:
    cfg = config.load_env_config()
    assert cfg["him23003"]["route_profile"] == "ebs"
    assert cfg["app"]["imm"]["cluster"] == ""
    assert cfg["app"]["wait"] == 3


# ---------------------------------------------------------------------------
# 派生访问器
# ---------------------------------------------------------------------------


def test_rest_base_url_derived_from_server_and_appkey(env_file: Path) -> None:
    assert config.get_appkey() == "easemob#test"
    assert config.get_server_base_url() == "https://a1.easemob.com"
    assert config.get_rest_base_url() == "https://a1.easemob.com/easemob/test"


def test_rest_base_url_empty_without_hash_appkey(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    path = tmp_path / "env.yaml"
    path.write_text(
        "app:\n  appkey: \"no-hash\"\n  server:\n    base_url: \"https://a1.easemob.com\"\n",
        encoding="utf-8",
    )
    monkeypatch.setenv("IM_TEST_CONFIG", str(path))
    assert config.get_rest_base_url() == ""


def test_rest_base_url_empty_without_server_base(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    path = tmp_path / "env.yaml"
    path.write_text("app:\n  appkey: \"org#app\"\n", encoding="utf-8")
    monkeypatch.setenv("IM_TEST_CONFIG", str(path))
    assert config.get_rest_base_url() == ""


def test_rest_credentials_and_verify_ssl(env_file: Path) -> None:
    assert config.has_rest_credentials() is True
    assert config.get_client_id() == "cid"
    assert config.get_client_secret() == "secret"
    assert config.get_rest_verify_ssl() is True


def test_verify_ssl_defaults_true_when_absent(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    path = tmp_path / "env.yaml"
    path.write_text(
        "app:\n  appkey: \"org#app\"\n  server:\n    base_url: \"https://a1.easemob.com\"\n",
        encoding="utf-8",
    )
    monkeypatch.setenv("IM_TEST_CONFIG", str(path))
    assert config.get_rest_verify_ssl() is True


def test_verify_ssl_false_is_read(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    path = tmp_path / "env.yaml"
    path.write_text(
        "app:\n  appkey: \"org#app\"\n  server:\n    base_url: \"https://a1.easemob.com\"\n    verify_ssl: false\n",
        encoding="utf-8",
    )
    monkeypatch.setenv("IM_TEST_CONFIG", str(path))
    assert config.get_rest_verify_ssl() is False


# ---------------------------------------------------------------------------
# 桥接访问器与 WS_BASE_URL 优先级
# ---------------------------------------------------------------------------


def test_bridge_values(bridge_file: Path) -> None:
    assert config.get_default_topic() == "adc"
    assert config.get_topic("deviceA") == "adc"
    assert config.get_topic("deviceB") == "adc01"
    assert config.get_topic("deviceC") == "adc"
    assert config.get_topic() == "adc"
    assert config.get_connect_timeout() == 10
    assert config.get_response_timeout() == 30
    assert config.get_ws_debug()["dump_events"] is True


def test_ws_base_url_prefers_environment(
    bridge_file: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.setenv("WS_BASE_URL", "  ws://127.0.0.1:40100/iov/websocket/dual  ")
    assert config.get_ws_base_url() == "ws://127.0.0.1:40100/iov/websocket/dual"


def test_ws_base_url_blank_env_falls_back_to_bridge(
    bridge_file: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.setenv("WS_BASE_URL", "   ")
    assert config.get_ws_base_url() == "ws://127.0.0.1:4000/iov/websocket/dual"


def test_topic_blank_value_falls_back_to_default(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    path = tmp_path / "bridge.yaml"
    path.write_text(
        "websocket:\n  default_topic: \"adc\"\ntopics:\n  deviceA: \"\"\n",
        encoding="utf-8",
    )
    monkeypatch.setenv("IM_BRIDGE_CONFIG", str(path))
    assert config.get_topic("deviceA") == "adc"
