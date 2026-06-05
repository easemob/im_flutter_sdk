"""
响应断言：根据 Flutter 端协议判断成功/失败，并对 result 或 error 做断言。
支持预期 JSON 比对、占位符注入、忽略时间戳等，见 assert_response_matches。
发现模式：设置环境变量 CASES_DISCOVER=1 时，所有断言仅打印不失败，便于第一次跑 case 观察真实返回。
"""
from __future__ import annotations

from typing import Any
import os
import json

import pytest

from .response_match import (
    DEFAULT_IGNORE_KEYS,
    compare_response,
    resolve_expected,
)


def _discover_mode() -> bool:
    return os.getenv("CASES_DISCOVER", "0") in ("1", "true", "True")


def _pretty(o: Any) -> str:
    try:
        return json.dumps(o, ensure_ascii=False, indent=2, default=str)
    except Exception:
        return repr(o)


def is_success(resp: dict[str, Any]) -> bool:
    """是否为成功响应（有 result 且无 success: false）。"""
    print("响应内容:", resp)
    return "result" in resp


def get_result(resp: dict[str, Any]) -> Any:
    """取 result 字段；失败时抛 AssertionError。"""
    if not is_success(resp):
        err = resp.get("error") or {}
        code = err.get("code", -1)
        desc = err.get("description", resp.get("error", "Unknown error"))
        pytest.fail(f"API failed: code={code}, description={desc}")
    return resp.get("result")


def get_error(resp: dict[str, Any]) -> dict[str, Any]:
    """取 error 字段；成功时返回空 dict。注意：某些桥接会把错误体放在 result。"""
    result = resp.get("result") or {}
    if isinstance(result, dict) and ("code" in result or "description" in result):
        return {"code": result.get("code"), "description": str(result.get("description", "Unknown"))}
    err = resp.get("error") or {}
    return {"code": err.get("code"), "description": str(err.get("description", "Unknown"))}


def assert_success(resp: dict[str, Any]) -> None:
    """断言为成功响应。"""
    if _discover_mode():
        print("[DISCOVER] assert_success skipped. Actual response:\n" + _pretty(resp))
        return
    if not is_success(resp):
        err = get_error(resp)
        pytest.fail(f"Expected success, got error: {err}")


def assert_error(resp: dict[str, Any], code: int | None = None, description: str | None = None) -> None:
    """断言为错误响应，并可校验 code/description。"""
    if _discover_mode():
        print("[DISCOVER] assert_error skipped. Actual response:\n" + _pretty(resp))
        return
    err = get_error(resp)
    if code is not None and err.get("code") != code:
        pytest.fail(f"Expected error code {code}, got {err.get(code)}")
    if description is not None and description not in str(err.get("description", "")):
        pytest.fail(f"Expected error description containing {description}, got {err}")


def assert_result_equals(resp: dict[str, Any], expected: Any) -> None:
    """断言 result 与 expected 相等。"""
    if _discover_mode():
        print("[DISCOVER] assert_result_equals skipped. Actual response:\n" + _pretty(resp))
        return
    actual = get_result(resp)
    assert actual == expected, f"result: expected {expected!r}, got {actual!r}"


def assert_result_matches(resp: dict[str, Any], **expected_fields: Any) -> None:
    """
    断言 result 为 dict 且包含指定字段与值。
    例：assert_result_matches(resp, userId="user1", logged_in=True)
    """
    actual = get_result(resp)
    if not isinstance(actual, dict):
        pytest.fail(f"Expected result to be dict, got {type(actual).__name__}: {actual!r}")
    for key, expected_val in expected_fields.items():
        assert key in actual, f"result missing key {key!r}"
        assert actual[key] == expected_val, (
            f"result[{key!r}]: expected {expected_val!r}, got {actual[key]!r}"
        )


def get_cmd(resp: dict[str, Any]) -> str | None:
    """响应中的 cmd（方法名）。"""
    return resp.get("cmd")


def get_manager(resp: dict[str, Any]) -> str | None:
    """响应中的 manager。"""
    return resp.get("manager")


def assert_response_matches(
    actual: dict[str, Any],
    expected: dict[str, Any],
    context: dict[str, Any] | None = None,
    ignore_keys: set[str] | frozenset[str] | None = None,
) -> None:
    """
    包装 response_match.assert_response_matches：
    - 正常模式：严格断言
    - 发现模式（CASES_DISCOVER=1）：打印实际/预期与差异，不抛错
    """
    if not _discover_mode():
        from .response_match import assert_response_matches as _raw
        return _raw(actual, expected, context, ignore_keys)
    resolved = resolve_expected(expected, context or {})
    ok, diffs = compare_response(actual, resolved, ignore_keys=ignore_keys)
    print("[DISCOVER] assert_response_matches skipped. Expected vs Actual:")
    print("  - expected:\n" + _pretty(resolved))
    print("  - actual:\n" + _pretty(actual))
    if not ok:
        print("  - diffs:\n  * " + "\n  * ".join(diffs))
