import pytest

from src.tools import config


@pytest.fixture(autouse=True)
def fixed_yaml_config(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(
        config,
        "load_config",
        lambda: {
            "websocket": {
                "base_url": "ws://remote.example/iov/websocket/dual",
            }
        },
    )


def test_ws_base_url_uses_yaml_when_environment_is_unset(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.delenv("WS_BASE_URL", raising=False)

    assert config.get_ws_base_url() == "ws://remote.example/iov/websocket/dual"


def test_ws_base_url_uses_yaml_when_environment_is_blank(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setenv("WS_BASE_URL", "   ")

    assert config.get_ws_base_url() == "ws://remote.example/iov/websocket/dual"


def test_ws_base_url_prefers_trimmed_environment_value(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setenv(
        "WS_BASE_URL",
        "  ws://127.0.0.1:4000/iov/websocket/dual  ",
    )

    assert config.get_ws_base_url() == "ws://127.0.0.1:4000/iov/websocket/dual"
