"""Semantic execution timing; YAML is the only configurable value source.

Module ownership is explicit, never inferred from a case or function name.
Only business boundaries call pause(); the transport never injects pacing.
"""
from __future__ import annotations

import math
import time

from src.tools import config
from src.tools.case_timing_defaults import DEFAULTS, MODULES

_NAMES = {}
for _key in DEFAULTS:
    _section, _name = _key.split('.')
    _NAMES.setdefault(_section, set()).add(_name)


def _number(raw, section: str, path: str) -> float:
    try:
        if isinstance(raw, bool) or not isinstance(raw, (int, float, str)):
            raise ValueError
        value = float(raw)
        if not math.isfinite(value) or value < 0:
            raise ValueError
        if section in {'timeout', 'observe', 'poll'} and value == 0:
            raise ValueError
    except (TypeError, ValueError, OverflowError):
        raise ValueError(f'Invalid seconds for {path}') from None
    return value


def _validated_options(options: dict) -> dict:
    """Validate all timing fields, including currently unused override branches."""
    if not isinstance(options, dict):
        raise ValueError('app.case_timing must be a mapping')
    result = {}
    for section, group in options.items():
        # Never echo arbitrary unknown keys/values: they may contain credentials.
        if section not in _NAMES:
            raise ValueError('Unknown section in app.case_timing')
        path = f'app.case_timing.{section}'
        if section == 'step' and not isinstance(group, dict):
            group = {'interval': group}
        if not isinstance(group, dict):
            raise ValueError(f'{path} must be a mapping')
        result[section] = {}
        for name, raw in group.items():
            if name in MODULES:
                overrides = raw if isinstance(raw, dict) else {'default': raw}
                normalized = {}
                for semantic, value in overrides.items():
                    if semantic not in _NAMES[section] and semantic != 'default':
                        raise ValueError(f'Unknown semantic name in {path}.{name}')
                    normalized[semantic] = _number(value, section, f'{path}.{name}.{semantic}')
                result[section][name] = normalized
            elif name in _NAMES[section] or name == 'default':
                result[section][name] = _number(raw, section, f'{path}.{name}')
            else:
                raise ValueError(f'Unknown semantic name or module in {path}')
    return result


def seconds(key: str, *, module: str) -> float:
    """module.name > global name > module.default > global default > built-in.

    Numeric module entries mean module.default; scalar step means step.interval.
    Resolve on every call, without loading configuration during module import.
    """
    if not isinstance(key, str) or key not in DEFAULTS:
        raise ValueError('Unknown case timing key')
    if not isinstance(module, str) or module not in MODULES:
        raise ValueError('Unknown case timing module')
    section, name = key.split('.')
    group = _validated_options(config.get_case_timing_config()).get(section, {})
    local = group.get(module, {})
    for mapping, candidate in ((local, name), (group, name),
                               (local, 'default'), (group, 'default')):
        if candidate in mapping:
            return mapping[candidate]
    return float(DEFAULTS[key])


def pause(key: str = 'step.interval', *, module: str) -> None:
    """Sleep at an explicit boundary; never read or drain callback queues."""
    duration = seconds(key, module=module)
    if duration:
        time.sleep(duration)


def wait_until(probe, predicate=None, *, key: str = 'step.interval', module: str,
               interval: str = 'poll.interval', reason: str = ''):
    """Bounded wait: probe now, return as soon as satisfied, fail at the bound.

    The budget behind `key` becomes an upper bound instead of a fixed sleep;
    the wait itself is never skipped and the caller still asserts afterwards.
    `probe` must be read-only and idempotent (no send/read-ack/download/history
    calls, which mutate local state). Failures report the semantic name, the
    bound and the attempt count only: probe payloads may carry message bodies,
    attachment secrets or tokens.
    """
    budget = seconds(key, module=module)
    step = seconds(interval, module=module)
    deadline = time.monotonic() + budget
    attempts = 0
    while True:
        attempts += 1
        value = probe()
        if predicate(value) if predicate else bool(value):
            return value
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            raise AssertionError(
                f'有界等待超时：{reason or key}；上限 {budget}s（{key}, module={module}），'
                f'探测 {attempts} 次仍未满足条件'
            )
        time.sleep(min(step, remaining))
