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
from typing import Any

from ..tools.config import get_rest_base_url
from .auth import authorization_header, rest_urlopen as _urlopen


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
    if not base:
        raise RuntimeError(
            "REST 不可用：app.server.base_url 与 app.appkey（org#app）需在环境文件中配置"
        )
    auth = authorization_header()

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
