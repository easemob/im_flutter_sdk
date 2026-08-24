"""
REST 用户管理：创建、删除用户（用于 presence 等用例的临时账号）。
对应 curl：
  - 创建: POST {base_url}/users, body [{"username":"xxx","password":"1"}, ...]
  - 删除: DELETE {base_url}/users/{username}
"""
from __future__ import annotations

import json
import urllib.request
import urllib.error
import sys
import ssl
import shlex
from typing import Any

from ..tools.config import get_rest_base_url, get_rest_auth_token, get_rest_verify_ssl
import urllib.parse


def _authorization_header() -> str:
    token = get_rest_auth_token()
    if not token:
        return ""
    return token if str(token).lower().startswith("bearer ") else f"Bearer {token}"


def _urlopen(req: urllib.request.Request, timeout: float = 30):
    if get_rest_verify_ssl():
        return urllib.request.urlopen(req, timeout=timeout)
    # 仅测试环境使用：跳过证书校验
    insecure_ctx = ssl._create_unverified_context()
    return urllib.request.urlopen(req, timeout=timeout, context=insecure_ctx)


def _mask_token(token: str) -> str:
    s = str(token or "")
    if len(s) <= 12:
        return "***"
    return f"{s[:6]}...{s[-4:]}"


def _as_curl(url: str, method: str, headers: dict[str, str], body: bytes | None) -> str:
    parts: list[str] = [
        "curl",
        "-X",
        shlex.quote(method),
        shlex.quote(url),
    ]
    for k, v in headers.items():
        parts.extend(["-H", shlex.quote(f"{k}: {v}")])
    if body is not None:
        try:
            payload = body.decode("utf-8")
        except Exception:
            payload = "<non-utf8-bytes>"
        parts.extend(["--data-raw", shlex.quote(payload)])
    return " ".join(parts)


def _is_duplicate_user_error(body: str) -> bool:
    if not body:
        return False
    try:
        obj = json.loads(body)
        if isinstance(obj, dict) and obj.get("error") == "duplicate_unique_property_exists":
            return True
    except Exception:
        pass
    return "duplicate_unique_property_exists" in body


def _post_create_single_user(base_url: str, token: str, user: dict[str, str]) -> tuple[str, dict[str, Any] | None]:
    """
    单用户创建兜底：
    - created: 新建成功
    - exists: 已存在
    - error: 其他错误
    """
    url = f"{base_url}/users"
    data = json.dumps([user]).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=data,
        method="POST",
        headers={
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": f"{token}",
        },
    )
    try:
        resp = _urlopen(req, timeout=30)
        try:
            raw = resp.read().decode()
        finally:
            resp.close()
        parsed = json.loads(raw) if raw.strip() else {}
        return "created", parsed if isinstance(parsed, dict) else {}
    except urllib.error.HTTPError as e:
        body = e.read().decode() if e.fp else ""
        if e.code == 400 and _is_duplicate_user_error(body):
            return "exists", None
        return (
            "error",
            {
                "error": f"HTTP {e.code}",
                "reason": str(e.reason),
                "body": body,
            },
        )
    except urllib.error.URLError as e:
        return (
            "error",
            {
                "error": "URLError",
                "reason": repr(e.reason),
            },
        )


def update_user_metadata(username: str, form_fields: dict[str, str]) -> dict:
    """
    更新用户元数据（如昵称），等价于示例 curl：
      PUT {base_url}/metadata/user/{username}
      headers: Content-Type: application/x-www-form-urlencoded;charset=utf-8,
               Authorization: Bearer <token>
      body: nickname=xxx（以及其他字段）

    返回解析后的 JSON；失败抛出 RuntimeError。
    """
    base = get_rest_base_url().rstrip("/")
    auth = _authorization_header()
    if not base or not auth:
        raise RuntimeError("rest_api.base_url 与 auth_token 需在 config.yaml 的 rest_api 中配置")

    user_enc = urllib.parse.quote(username, safe="")
    url = f"{base}/metadata/user/{user_enc}"
    data = urllib.parse.urlencode(form_fields or {}).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=data,
        method="PUT",
        headers={
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded;charset=utf-8",
            "Authorization": auth,
        },
    )
    try:
        with _urlopen(req, timeout=30) as resp:
            raw = resp.read().decode()
            return json.loads(raw) if raw.strip() else {}
    except urllib.error.HTTPError as e:
        body = e.read().decode() if e.fp else ""
        raise RuntimeError(f"更新用户元数据失败 HTTP {e.code}: {body}") from e


def create_users(users: list[dict[str, str]]) -> dict:
    """
    批量创建用户。users 如 [{"username": "u1", "password": "1"}, ...]。
    返回 REST 响应 dict。
    失败时不抛异常，打印错误后返回 {"error": ...}。
    """
    base = get_rest_base_url().rstrip("/")
    token = get_rest_auth_token()
    if not base or not token:
        err = "rest_api.base_url 与 auth_token 需在 config.yaml 的 rest_api 中配置"
        print(f"[create_users] {err}", file=sys.stderr, flush=True)
        return {"error": err, "url": base}
    url = f"{base}/users"
    data = json.dumps(users).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=data,
        method="POST",
        headers={
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": f"{token}",
        },
    )
    debug_headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": _mask_token(token),
    }
    debug_curl = _as_curl(url, "POST", debug_headers, data)
    try:
        resp = _urlopen(req, timeout=30)
        try:
            raw = resp.read().decode()
        finally:
            resp.close()
        parsed = json.loads(raw) if raw.strip() else {}
        created = [
            u.get("username")
            for u in users
            if isinstance(u, dict) and isinstance(u.get("username"), str) and u.get("username")
        ]
        return {
            "ok": True,
            "created": created,
            "existing": [],
            "raw": parsed if isinstance(parsed, dict) else {},
        }
    except urllib.error.HTTPError as e:
        body = e.read().decode() if e.fp else ""
        if e.code == 400 and _is_duplicate_user_error(body):
            created_usernames: list[str] = []
            existing_usernames: list[str] = []
            for user in users:
                username = user.get("username") if isinstance(user, dict) else None
                status, detail = _post_create_single_user(base, token, user)
                if status == "created":
                    if isinstance(username, str) and username:
                        created_usernames.append(username)
                    continue
                if status == "exists":
                    if isinstance(username, str) and username:
                        existing_usernames.append(username)
                    continue
                print(
                    "[create_users] fallback create single user failed\n"
                    f"url={url}\n"
                    f"user={username}\n"
                    f"detail={detail}",
                    file=sys.stderr,
                    flush=True,
                )
                return {
                    "error": "create_users_fallback_failed",
                    "url": url,
                    "reason": "single user create fallback failed",
                    "detail": detail or {},
                }

            return {
                "ok": True,
                "created": created_usernames,
                "existing": existing_usernames,
                "raw_error": body,
            }

        print(
            "[create_users] HTTPError\n"
            f"url={url}\n"
            f"curl={debug_curl}\n"
            f"status={e.code}\n"
            f"reason={e.reason}\n"
            f"response_body={body}",
            file=sys.stderr,
            flush=True,
        )
        return {
            "error": f"HTTP {e.code}",
            "url": url,
            "reason": str(e.reason),
            "body": body,
        }
    except urllib.error.URLError as e:
        print(
            "[create_users] URLError\n"
            f"url={url}\n"
            f"curl={debug_curl}\n"
            f"reason={repr(e.reason)}",
            file=sys.stderr,
            flush=True,
        )
        return {
            "error": "URLError",
            "url": url,
            "reason": repr(e.reason),
        }


def delete_user(username: str) -> None:
    """删除指定用户。"""
    base = get_rest_base_url().rstrip("/")
    token = get_rest_auth_token()
    if not base or not token:
        raise RuntimeError("rest_api.base_url 与 auth_token 需在 config.yaml 的 rest_api 中配置")
    url = f"{base}/users/{urllib.request.quote(username, safe='')}"
    req = urllib.request.Request(
        url,
        method="DELETE",
        headers={
            "Accept": "application/json",
            "Authorization": f"{token}",
        },
    )
    try:
        _urlopen(req, timeout=15)
    except urllib.error.HTTPError as e:
        # 404 等视为已删除或不存在，不抛
        if e.code != 404:
            body = e.read().decode() if e.fp else ""
            raise RuntimeError(f"删除用户 {username} 失败 HTTP {e.code}: {body}") from e


def fetch_user_token(username: str, password: str, ttl: int = 0) -> dict:
    """用账号密码换取用户 token（供 5.0 loginWithToken 登录使用）。

    对应 REST: POST {base_url}/token, body {"grant_type":"password","username","password","ttl"}。
    返回 {"access_token": ..., "expires_in": ..., "user": {...}}。
    """
    base = get_rest_base_url().rstrip("/")
    if not base:
        raise RuntimeError("rest_api.base_url 需在 config.yaml 的 rest_api 中配置")
    url = f"{base}/token"
    body = {
        "grant_type": "password",
        "username": username,
        "password": password,
        "ttl": str(ttl),
    }
    req = urllib.request.Request(
        url,
        data=json.dumps(body).encode("utf-8"),
        method="POST",
        headers={
            "Content-Type": "application/json",
            "Accept": "application/json",
        },
    )
    raw = _urlopen(req, timeout=30).read().decode("utf-8")
    return json.loads(raw) if raw.strip() else {}
