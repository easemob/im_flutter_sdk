"""REST 动态凭据测试（client_credentials，mock HTTP，不联网）。"""
from __future__ import annotations

import ssl
import urllib.error
import urllib.request

import pytest

from src.rest_api import auth


class _FakeResponse:
    def __init__(self, payload: bytes):
        self._payload = payload

    def read(self) -> bytes:
        return self._payload

    def __enter__(self) -> "_FakeResponse":
        return self

    def __exit__(self, *exc) -> bool:
        return False


@pytest.fixture(autouse=True)
def _reset(monkeypatch: pytest.MonkeyPatch):
    auth.reset_token_cache()
    yield
    auth.reset_token_cache()


@pytest.fixture
def credentials(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(auth, "get_rest_base_url", lambda: "https://a1.example/org/app")
    monkeypatch.setattr(auth, "get_client_id", lambda: "cid")
    monkeypatch.setattr(auth, "get_client_secret", lambda: "sec")


def test_fetch_token_and_cache(credentials: None, monkeypatch: pytest.MonkeyPatch) -> None:
    calls: list[dict] = []

    def fake_urlopen(req, timeout=30):
        calls.append({"url": req.full_url, "data": req.data})
        return _FakeResponse(b'{"access_token": "tok-123456789012", "expires_in": 3600}')

    monkeypatch.setattr(auth, "rest_urlopen", fake_urlopen)

    first = auth.get_rest_token()
    second = auth.get_rest_token()

    assert first == "tok-123456789012"
    assert second == first
    assert len(calls) == 1, "缓存命中后不应再次请求"
    assert calls[0]["url"] == "https://a1.example/org/app/token"
    assert b"client_credentials" in calls[0]["data"]


def test_expired_token_refreshes(credentials: None, monkeypatch: pytest.MonkeyPatch) -> None:
    tokens = iter(["tok-aaaaaaaaaaaa", "tok-bbbbbbbbbbbb"])
    calls = {"n": 0}

    def fake_urlopen(req, timeout=30):
        calls["n"] += 1
        return _FakeResponse(
            ('{"access_token": "%s", "expires_in": 3600}' % next(tokens)).encode()
        )

    monkeypatch.setattr(auth, "rest_urlopen", fake_urlopen)

    assert auth.get_rest_token() == "tok-aaaaaaaaaaaa"
    # 手工把过期时间推到过去，模拟到期
    auth._TOKEN_EXPIRES_AT = 0.0
    assert auth.get_rest_token() == "tok-bbbbbbbbbbbb"
    assert calls["n"] == 2


def test_missing_credentials_raises(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(auth, "get_rest_base_url", lambda: "https://a1.example/org/app")
    monkeypatch.setattr(auth, "get_client_id", lambda: "")
    monkeypatch.setattr(auth, "get_client_secret", lambda: "")
    with pytest.raises(RuntimeError, match="client_id"):
        auth.get_rest_token()


def test_missing_base_url_raises(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(auth, "get_rest_base_url", lambda: "")
    with pytest.raises(RuntimeError, match="base_url"):
        auth.get_rest_token()


def test_http_error_raises_with_status(credentials: None, monkeypatch: pytest.MonkeyPatch) -> None:
    def fake_urlopen(req, timeout=30):
        raise urllib.error.HTTPError(req.full_url, 401, "Unauthorized", {}, None)

    monkeypatch.setattr(auth, "rest_urlopen", fake_urlopen)
    with pytest.raises(RuntimeError, match="401"):
        auth.get_rest_token()


def test_authorization_header_formats_bearer(credentials: None, monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(auth, "rest_urlopen", lambda req, timeout=30: _FakeResponse(
        b'{"access_token": "abc", "expires_in": 3600}'
    ))
    assert auth.authorization_header() == "Bearer abc"


def test_rest_urlopen_skips_verification_when_disabled(monkeypatch: pytest.MonkeyPatch) -> None:
    captured: dict = {}

    def fake_urlopen(req, timeout=30, context=None):
        captured["context"] = context
        return _FakeResponse(b"{}")

    monkeypatch.setattr(auth, "get_rest_verify_ssl", lambda: False)
    monkeypatch.setattr(auth.urllib.request, "urlopen", fake_urlopen)

    req = urllib.request.Request("https://a1.example/x")
    auth.rest_urlopen(req, timeout=5)

    assert isinstance(captured["context"], ssl.SSLContext)
    assert captured["context"].check_hostname is False


def test_rest_urlopen_verifies_by_default(monkeypatch: pytest.MonkeyPatch) -> None:
    captured: dict = {}

    def fake_urlopen(req, timeout=30, **kwargs):
        captured["kwargs"] = kwargs
        return _FakeResponse(b"{}")

    monkeypatch.setattr(auth, "get_rest_verify_ssl", lambda: True)
    monkeypatch.setattr(auth.urllib.request, "urlopen", fake_urlopen)

    req = urllib.request.Request("https://a1.example/x")
    auth.rest_urlopen(req, timeout=5)

    assert "context" not in captured["kwargs"]
