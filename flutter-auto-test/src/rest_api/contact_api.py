"""
REST 查询用户好友列表（环信 demo 接口）。
对应 curl：
  GET {base_url}/users/{username}/contacts/users?needReturnRemark=true
"""
from __future__ import annotations

import json
import urllib.error
import urllib.parse
import urllib.request
import ssl
from typing import Any

from ..tools.config import get_rest_auth_token, get_rest_base_url, get_rest_verify_ssl


def _authorization_header() -> str:
    token = get_rest_auth_token()
    if not token:
        return ""
    return token if token.lower().startswith("bearer ") else f"Bearer {token}"


def _urlopen(req: urllib.request.Request, timeout: float = 30):
    if get_rest_verify_ssl():
        return urllib.request.urlopen(req, timeout=timeout)
    insecure_ctx = ssl._create_unverified_context()
    return urllib.request.urlopen(req, timeout=timeout, context=insecure_ctx)


def get_user_contacts(
    username: str,
    *,
    need_return_remark: bool = True,
) -> Any:
    """
    查询指定用户的好友列表（HTTP）。

    :param username: 环信用户名，如 test0324user2
    :param need_return_remark: 是否返回备注，对应查询参数 needReturnRemark=true
    :return: 解析后的 JSON（一般为 list 或 dict，依服务端为准）
    """
    base = get_rest_base_url().rstrip("/")
    auth = _authorization_header()
    if not base or not auth:
        raise RuntimeError("rest_api.base_url 与 auth_token 需在 config.yaml 的 rest_api 中配置")

    user_enc = urllib.parse.quote(username, safe="")
    path = f"{base}/users/{user_enc}/contacts/users"
    params: dict[str, str] = {}
    if need_return_remark:
        params["needReturnRemark"] = "true"
    query = urllib.parse.urlencode(params)
    url = f"{path}?{query}" if query else path

    req = urllib.request.Request(
        url,
        method="GET",
        headers={
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": auth,
        },
    )
    try:
        with _urlopen(req, timeout=30) as resp:
            raw = resp.read().decode()
            return json.loads(raw) if raw.strip() else {}
    except urllib.error.HTTPError as e:
        body = e.read().decode() if e.fp else ""
        raise RuntimeError(f"查询好友列表失败 HTTP {e.code}: {body}") from e
