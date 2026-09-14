"""REST 动态凭据：client_credentials 换取 token 并做进程内缓存。

凭据来源（环境文件 ``app.server``）：

- ``base_url`` + ``appkey``（``org#app``）派生 REST base URL，见 ``config.get_rest_base_url``。
- ``client_id`` / ``client_secret`` 用于 ``POST {base}/token``。

不使用静态 token：缺少 client 凭据时 ``get_rest_token`` 直接报错，调用方按需降级。
"""
from __future__ import annotations

import json
import ssl
import time
import urllib.error
import urllib.request
from typing import Any

from ..tools.config import (
    get_client_id,
    get_client_secret,
    get_rest_base_url,
    get_rest_verify_ssl,
)

_TOKEN: str = ""
_TOKEN_EXPIRES_AT: float = 0.0
_DEFAULT_TTL_SECONDS = 3600.0
_REFRESH_SKEW_SECONDS = 60.0


def _mask(value: Any) -> str:
    s = str(value or "")
    if len(s) <= 12:
        return "***"
    return f"{s[:6]}...{s[-4:]}"


def rest_urlopen(req: urllib.request.Request, timeout: float = 30):
    """按 ``app.server.verify_ssl`` 决定是否校验证书。"""
    if get_rest_verify_ssl():
        return urllib.request.urlopen(req, timeout=timeout)
    insecure_ctx = ssl._create_unverified_context()
    return urllib.request.urlopen(req, timeout=timeout, context=insecure_ctx)


def reset_token_cache() -> None:
    """清空缓存（测试与需要强制刷新时使用）。"""
    global _TOKEN, _TOKEN_EXPIRES_AT
    _TOKEN = ""
    _TOKEN_EXPIRES_AT = 0.0


def _cached_token() -> str:
    if _TOKEN and time.monotonic() < _TOKEN_EXPIRES_AT - _REFRESH_SKEW_SECONDS:
        return _TOKEN
    return ""


def _fetch_token() -> str:
    global _TOKEN, _TOKEN_EXPIRES_AT

    base = get_rest_base_url()
    if not base:
        raise RuntimeError(
            "REST 不可用：app.server.base_url 与 app.appkey 未配置，"
            "或 appkey 不是 org#app 格式"
        )
    client_id = get_client_id()
    client_secret = get_client_secret()
    if not client_id or not client_secret:
        raise RuntimeError(
            "REST 不可用：app.server.client_id / client_secret 未配置"
        )

    url = f"{base}/token"
    body = json.dumps(
        {
            "grant_type": "client_credentials",
            "client_id": client_id,
            "client_secret": client_secret,
        }
    ).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=body,
        method="POST",
        headers={"Accept": "application/json", "Content-Type": "application/json"},
    )
    try:
        with rest_urlopen(req, timeout=30) as resp:
            raw = resp.read().decode()
    except urllib.error.HTTPError as e:
        resp_body = e.read().decode() if e.fp else ""
        raise RuntimeError(f"获取 REST token 失败 HTTP {e.code}: {resp_body}") from e
    except urllib.error.URLError as e:
        raise RuntimeError(f"获取 REST token 失败 URLError: {e.reason!r}") from e

    try:
        parsed = json.loads(raw) if raw.strip() else {}
    except json.JSONDecodeError as e:
        raise RuntimeError("获取 REST token 失败：响应不是合法 JSON") from e

    token = str(parsed.get("access_token") or "").strip()
    if not token:
        raise RuntimeError(f"获取 REST token 失败：响应缺少 access_token ({_mask(raw)})")

    try:
        ttl = float(parsed.get("expires_in", _DEFAULT_TTL_SECONDS))
    except (TypeError, ValueError):
        ttl = _DEFAULT_TTL_SECONDS
    _TOKEN = token
    _TOKEN_EXPIRES_AT = time.monotonic() + max(ttl, 0.0)
    return token


def get_rest_token() -> str:
    """返回可用 REST token；不可用时抛 ``RuntimeError``。"""
    cached = _cached_token()
    if cached:
        return cached
    return _fetch_token()


def authorization_header() -> str:
    """构造 ``Authorization`` 头；token 不可用时抛 ``RuntimeError``。"""
    token = get_rest_token()
    if token.lower().startswith("bearer "):
        return token
    return f"Bearer {token}"
