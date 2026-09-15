"""Allure evidence presentation only; never mutates protocol objects."""
from contextlib import nullcontext
from functools import wraps
import html
import json
import re
import time

from .allure_steps import business_step, action_title, event_title, expectation_title


SENSITIVE = re.compile(r'password|passwd|token|secret|authorization|cookie|credential', re.I)


def redact(value):
    if isinstance(value, dict):
        return {str(k): '[REDACTED]' if SENSITIVE.search(str(k)) else redact(v)
                for k, v in value.items()}
    if isinstance(value, (list, tuple)):
        return [redact(v) for v in value]
    if isinstance(value, str):
        value = re.sub(r'(?i)(Bearer\s+)\S+', r'\1[REDACTED]', value)
        value = re.sub(r'(?i)((?:password|token|secret|authorization|cookie)[\w-]*\s*[=:]\s*)[^\s&,;]+',
                       r'\1[REDACTED]', value)
        value = re.sub(r'(https?://)[^/@\s]+:[^/@\s]+@', r'\1[REDACTED]@', value)
        return value
    return value


def pretty(value):
    return json.dumps(redact(value), ensure_ascii=False, indent=2, default=str)


def step(title):
    try:
        import allure
        return allure.step(title)
    except ImportError:
        return nullcontext()


def attach(name, value):
    try:
        import allure
        allure.attach(pretty(value), name, allure.attachment_type.JSON)
    except ImportError:
        pass


def identity(value):
    if not isinstance(value, dict):
        return 'response'
    # Only protocol identifiers in titles, never request/response body values.
    return ' | '.join(str(redact(value[k])) for k in ('device', 'manager', 'cmd', 'eventType') if k in value) or 'response'


def comparison(actual, expected, rows, ignored):
    attach('01 期望（条件表达式不是固定值）', expected)
    attach('02 实际响应 / 事件', actual)
    attach('03 字段差异', rows)
    attach('04 比对规则', {'ignored_keys_or_paths': sorted(ignored),
           'rules': '忽略字段不比对值；显式条件匹配仍校验。缺失、多余、类型、列表长度均检查。'})
    def cell(value):
        return '<pre>' + html.escape(pretty(value)) + '</pre>'
    table = ''.join('<tr>' + ''.join('<td>' + cell(r[k]) + '</td>' for k in ('path', 'expected', 'actual', 'difference')) + '</tr>' for r in rows)
    document = ('<!doctype html><meta charset="utf-8"><style>body{font:14px sans-serif} '
                'table{border-collapse:collapse;width:100%}td,th,pre{white-space:pre-wrap;overflow-wrap:anywhere}'
                'td,th{border:1px solid #ccc;padding:8px}pre{margin:4px}</style>'
                '<h2>' + ('比对失败' if rows else '比对通过') + '</h2>'
                '<table><tr><th>字段路径</th><th>期望</th><th>实际</th><th>差异</th></tr>'
                + table
                + '</table><h3>期望</h3>' + cell(expected) + '<h3>实际</h3>' + cell(actual)
                + '<h3>忽略字段 / 路径</h3>' + cell(sorted(ignored)))
    try:
        import allure
        allure.attach(document, '00 排查总览：期望 vs 实际 vs 差异', allure.attachment_type.HTML)
    except ImportError:
        pass


def observe_call(device, manager, cmd, info, invoke, kwargs):
    with business_step(action_title(device, manager, cmd)):
        attach('01 请求', {'device': device, 'manager': manager, 'cmd': cmd, 'info': info, **kwargs})
        start = time.monotonic()
        try:
            response = invoke()
            attach('02 实际响应', response)
            return response
        except Exception as exc:
            attach('02 调用异常（非响应）', {'exception_type': type(exc).__name__})
            raise
        finally:
            attach('03 耗时', {'elapsed_seconds': round(time.monotonic() - start, 4)})


def observe_event(device, filters, invoke):
    with business_step(event_title(device, filters)):
        attach('01 等待条件', {**filters, 'note': '此接口仅提供类型过滤；用户/msgId等条件由上层用例判断'})
        start = time.monotonic()
        try:
            event = invoke()
            with step('等待结束：未收到匹配消息（是否失败由调用方判断）' if event is None else '等待结束：收到消息'):
                attach('02 等待结果', {'outcome': '未收到匹配消息（不自动判定用例失败）' if event is None else '收到消息',
                                 'actual': event})
            return event
        except Exception as exc:
            attach('02 等待异常', {'exception_type': type(exc).__name__})
            raise
        finally:
            attach('03 耗时', {'elapsed_seconds': round(time.monotonic() - start, 4)})


def assertion_evidence(fn):
    @wraps(fn)
    def wrapper(resp, *args, **kwargs):
        requirement = {'assert_success': '校验操作响应为成功',
                       'assert_error': '校验错误码和错误描述符合预期',
                       'assert_result_equals': '校验返回结果等于预期',
                       'assert_result_matches': '校验返回结果的指定字段符合预期'}
        with business_step(expectation_title(resp) + '：' + requirement.get(fn.__name__, fn.__name__)):
            attach('01 校验要求', {'assertion': fn.__name__, 'args': args, 'kwargs': kwargs})
            attach('02 实际响应', resp)
            return fn(resp, *args, **kwargs)
    return wrapper
