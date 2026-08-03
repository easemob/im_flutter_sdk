"""
预期响应 JSON 与实际响应比对：支持占位符（从请求/上下文注入）、忽略时间戳等变化字段，不一致时列出差异。
比对结果会写入 Allure 报告（预期、实际、比对结果详情）。

条件断言对象（可在 expected 任意位置使用）：
    eq(v)   — 等于（等价于直接写值）
    ne(v)   — 不等于
    gt(v)   — 大于
    lt(v)   — 小于
    ge(v)   — 大于等于
    le(v)   — 小于等于

示例：
    expected={
        "result": [{"lastTime": gt(0), "statusDescription": eq("online"), "active": ne(False)}]
    }
"""
from __future__ import annotations

import json
import operator
import re
from typing import Any

# 默认忽略的 key（任意层级），时间戳等变化值不参与比对
DEFAULT_IGNORE_KEYS = frozenset({
    "timestamp", "time", "serverTime", "date", "createdAt", "updatedAt",
    "ts", "created_at", "updated_at", "lastModified", "id",
})


# ---------------------------------------------------------------------------
# 条件断言对象
# ---------------------------------------------------------------------------

class _Matcher:
    """在 expected 中表示「条件断言」而非固定值。"""

    _OP_SYMBOLS = {
        "eq": "==", "ne": "!=", "gt": ">", "lt": "<", "ge": ">=", "le": "<=",
    }

    def __init__(self, op_name: str, op_fn, threshold: Any) -> None:
        self._op_name = op_name
        self._op_fn = op_fn
        self._threshold = threshold

    def check(self, actual: Any) -> bool:
        try:
            return bool(self._op_fn(actual, self._threshold))
        except TypeError:
            return False

    def describe(self) -> str:
        sym = self._OP_SYMBOLS.get(self._op_name, self._op_name)
        return f"{sym} {self._threshold!r}"

    def __repr__(self) -> str:
        return f"{self._op_name}({self._threshold!r})"


def eq(value: Any) -> _Matcher:
    """断言字段值 == value。"""
    return _Matcher("eq", operator.eq, value)

def ne(value: Any) -> _Matcher:
    """断言字段值 != value。"""
    return _Matcher("ne", operator.ne, value)

def gt(value: Any) -> _Matcher:
    """断言字段值 > value。"""
    return _Matcher("gt", operator.gt, value)

def lt(value: Any) -> _Matcher:
    """断言字段值 < value。"""
    return _Matcher("lt", operator.lt, value)

def ge(value: Any) -> _Matcher:
    """断言字段值 >= value。"""
    return _Matcher("ge", operator.ge, value)

def le(value: Any) -> _Matcher:
    """断言字段值 <= value。"""
    return _Matcher("le", operator.le, value)


def _get_by_path(obj: Any, path: str) -> Any:
    """从 dict 按点分路径取值，如 'request.info.userId'。"""
    for part in path.split("."):
        if not isinstance(obj, dict):
            return None
        obj = obj.get(part)
    return obj


def _resolve_value(val: Any, context: dict[str, Any]) -> Any:
    """递归解析 expected 中的占位符 {{key}} 或 {{path.to.key}}，用 context 替换。"""
    if isinstance(val, dict):
        return {k: _resolve_value(v, context) for k, v in val.items()}
    if isinstance(val, list):
        return [_resolve_value(v, context) for v in val]
    if isinstance(val, str) and "{{" in val:
        # 支持 {{var}} 或 {{path.to.var}}
        def repl(m: re.Match) -> str:
            key = m.group(1).strip()
            v = _get_by_path(context, key) if "." in key else context.get(key)
            if v is None and key in context:
                v = context[key]
            return str(v) if v is not None else m.group(0)
        return re.sub(r"\{\{\s*([^}]+)\s*\}\}", repl, val)
    return val


def _collect_diffs(
    actual: Any,
    expected: Any,
    path: str = "root",
    ignore_keys: frozenset[str] | None = None,
) -> list[str]:
    """
    递归比对。expected 与 ignore_keys 一起视为「预期全部字段」：
    - 实际缺少 expected 中的字段 → 列出「缺少的字段」
    - 实际多出不在 expected 且不在 ignore_keys 的字段 → 列出「多出的字段」
    - ignore_keys 的字段不比对取值，仅视为允许存在。
    - expected 中的值可以是 _Matcher（如 gt(0)、ne(False)），满足条件则通过，否则列出差异。
    """
    ign = ignore_keys or frozenset()
    diffs: list[str] = []
    path_ignored = path in ign

    if path_ignored and not isinstance(expected, _Matcher):
        return diffs

    # 条件断言对象（_Matcher）：不要求类型一致，直接走 check
    if isinstance(expected, _Matcher):
        if not expected.check(actual):
            diffs.append(
                f"{path}: 条件不满足 — 实际 {actual!r}, 要求 {expected.describe()}"
            )
        return diffs

    # 新路径直连 Wrapper：无返回值 API（update*Setting/unsubscribe 等）
    # 返回空 Map {}，而旧路径（经 Dart 层）返回 None。两者视为等价，
    # 避免大量 Case 因"类型不同"失败。
    if expected is None and actual == {}:
        return diffs

    if type(actual) != type(expected):
        diffs.append(f"{path}: 类型不同 — 预期 {type(expected).__name__!r}, 实际 {type(actual).__name__!r}")
        return diffs

    if isinstance(expected, dict):
        if not isinstance(actual, dict):
            diffs.append(f"{path}: 预期为 dict，实际为 {type(actual).__name__!r}")
            return diffs
        expected_keys = set(expected.keys())
        actual_keys = set(actual.keys())
        # 缺少：在 expected 中但 actual 没有
        for k in expected_keys:
            p = f"{path}.{k}" if path != "root" else k
            if k not in actual:
                if p in ign:
                    continue
                diffs.append(f"{p}: 实际缺少该字段，预期值 = {expected[k]!r}")
            elif (k in ign or p in ign) and not isinstance(expected[k], _Matcher):
                # 在 ignore_keys 中且非条件断言：不比对取值；若写了 gt(0) 等仍会校验
                pass
            else:
                diffs.extend(_collect_diffs(actual[k], expected[k], p, ign))
        # 多出：在 actual 中但不在预期（expected ∪ ignore_keys）
        for k in actual_keys:
            p = f"{path}.{k}" if path != "root" else k
            if k in expected_keys or k in ign or p in ign:
                continue
            diffs.append(f"{p}: 实际多出字段，预期未声明")
    elif isinstance(expected, list):
        if not isinstance(actual, list):
            diffs.append(f"{path}: 预期 list，实际 {type(actual).__name__!r}")
        elif len(actual) != len(expected):
            diffs.append(f"{path}: 列表长度不同 — 预期 {len(expected)}, 实际 {len(actual)}")
        else:
            for i, (a, e) in enumerate(zip(actual, expected)):
                diffs.extend(_collect_diffs(a, e, f"{path}[{i}]", ign))
    else:
        if actual != expected:
            diffs.append(f"{path}: 值不同 — 预期 {expected!r}, 实际 {actual!r}")
    return diffs


def _attach_compare_result_allure(
    actual: dict[str, Any],
    expected_resolved: dict[str, Any],
    match: bool,
    diffs: list[str],
) -> None:
    """将比对结果（预期、实际、一致/差异列表）写入 Allure 报告。"""
    try:
        import allure
        with allure.step("响应与预期比对"):
            allure.attach(
                json.dumps(expected_resolved, ensure_ascii=False, indent=2, default=str),
                "预期响应",
                allure.attachment_type.JSON,
            )
            allure.attach(
                json.dumps(actual, ensure_ascii=False, indent=2, default=str),
                "实际响应",
                allure.attachment_type.JSON,
            )
            if match:
                allure.attach("一致", "比对结果", allure.attachment_type.TEXT)
            else:
                allure.attach(
                    "不一致\n\n" + "\n".join(diffs),
                    "比对结果（差异）",
                    allure.attachment_type.TEXT,
                )
    except ImportError:
        pass


def resolve_expected(expected: dict[str, Any], context: dict[str, Any]) -> dict[str, Any]:
    """
    将预期 JSON 中的占位符 {{key}} / {{path.to.key}} 用 context 替换。
    context 可包含请求参数，如 context={"request": {"info": {"userId": "tst"}}, "userId": "tst"}。
    """
    return _resolve_value(expected, context)


def compare_response(
    actual: dict[str, Any],
    expected: dict[str, Any],
    ignore_keys: set[str] | frozenset[str] | None = None,
) -> tuple[bool, list[str]]:
    """
    比对实际响应与预期响应。expected + ignore_keys 视为「预期全部字段」：
    - 少字段：实际缺少 expected 中某字段 → 列出缺少的字段
    - 多字段：实际存在某字段且不在 expected、也不在 ignore_keys → 列出多出的字段
    - ignore_keys 的 key 不比对取值，仅视为允许存在。
    返回 (是否一致, 差异描述列表)。
    """
    ign = DEFAULT_IGNORE_KEYS | frozenset(ignore_keys or [])
    diffs = _collect_diffs(actual, expected, "root", ign)
    return (len(diffs) == 0, diffs)


def assert_response_matches(
    actual: dict[str, Any],
    expected: dict[str, Any],
    context: dict[str, Any] | None = None,
    ignore_keys: set[str] | frozenset[str] | None = None,
) -> None:
    """
    断言实际响应与预期一致。expected + ignore_keys 共同作为「预期全部字段」：
    - 实际少字段：缺少 expected 中某字段 → 列出「缺少的字段」
    - 实际多字段：存在某字段且不在 expected、也不在 ignore_keys → 列出「多出的字段」
    - ignore_keys 仅表示允许存在且不比对取值（如时间戳）。
    不一致时抛出 AssertionError 并列出上述差异。
    - actual: 实际响应（如 api.call 的返回值）。
    - expected: 预期响应模板，值可用 {{key}} 从 context 注入。
    - context: 占位符取值来源。
    - ignore_keys: 允许存在且不比对取值的 key，默认含 timestamp 等。
    """
    resolved = resolve_expected(expected, context or {})
    ok, diffs = compare_response(actual, resolved, ignore_keys=ignore_keys)
    _attach_compare_result_allure(actual, resolved, ok, diffs)
    if not ok:
        msg = "响应与预期不一致:\n" + "\n".join(f"  - {d}" for d in diffs)
        raise AssertionError(msg)
