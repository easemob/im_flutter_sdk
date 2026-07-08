"""
REST 聊天室管理辅助。
当前仅保留被测端前置所需的最小能力：创建聊天室、查询聊天室、删除聊天室。
"""
from __future__ import annotations

import json
import socket
import ssl
import time
import urllib.error
import urllib.parse
import urllib.request
from typing import Any

from ..tools.config import get_rest_auth_token, get_rest_base_url, get_rest_verify_ssl


def _authorization_header() -> str:
    token = get_rest_auth_token()
    if not token:
        return ""
    return token if str(token).lower().startswith("bearer ") else f"Bearer {token}"


def _urlopen(req: urllib.request.Request, timeout: float = 30):
    if get_rest_verify_ssl():
        return urllib.request.urlopen(req, timeout=timeout)
    insecure_ctx = ssl._create_unverified_context()
    return urllib.request.urlopen(req, timeout=timeout, context=insecure_ctx)


def _json_request(url: str, method: str, payload: Any | None = None) -> dict[str, Any]:
    token = _authorization_header()
    if not token:
        raise RuntimeError("rest_api.base_url 与 auth_token 需在 config.yaml 的 rest_api 中配置")
    data = None if payload is None else json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=data,
        method=method,
        headers={
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": token,
        },
    )
    last_timeout: TimeoutError | socket.timeout | None = None
    for idx in range(3):
        try:
            with _urlopen(req, timeout=30) as resp:
                raw = resp.read().decode()
                return json.loads(raw) if raw.strip() else {}
        except urllib.error.HTTPError as e:
            body = e.read().decode() if e.fp else ""
            raise RuntimeError(f"聊天室 REST 调用失败 HTTP {e.code}: {body}") from e
        except (TimeoutError, socket.timeout) as e:
            last_timeout = e
            if idx < 2:
                time.sleep(1.0)
                continue
            raise
    raise last_timeout or RuntimeError("聊天室 REST 调用失败")


def create_chat_room(
    *,
    room_name: str,
    owner: str,
    members: list[str] | None = None,
    max_users: int = 200,
    admin_members: list[str] | None = None,
) -> dict[str, Any]:
    """
    创建聊天室。
    说明：这里只提供最小可用前置，具体字段按服务端实际响应冻结。
    """
    base = get_rest_base_url().rstrip("/")
    if not base:
        raise RuntimeError("rest_api.base_url 与 auth_token 需在 config.yaml 的 rest_api 中配置")
    payload: dict[str, Any] = {
        "name": room_name,
        "maxusers": max_users,
        "owner": owner,
        "members": members or [],
    }
    admins = admin_members or []
    if admins:
        payload["roles"] = {"admin": admins}
    return _json_request(f"{base}/chatrooms", "POST", payload)


def fetch_chat_room(room_id: str) -> dict[str, Any]:
    base = get_rest_base_url().rstrip("/")
    if not base:
        raise RuntimeError("rest_api.base_url 与 auth_token 需在 config.yaml 的 rest_api 中配置")
    room_enc = urllib.parse.quote(room_id, safe="")
    return _json_request(f"{base}/chatrooms/{room_enc}", "GET")


def delete_chat_room(room_id: str) -> dict[str, Any]:
    base = get_rest_base_url().rstrip("/")
    if not base:
        raise RuntimeError("rest_api.base_url 与 auth_token 需在 config.yaml 的 rest_api 中配置")
    room_enc = urllib.parse.quote(room_id, safe="")
    return _json_request(f"{base}/chatrooms/{room_enc}", "DELETE")
