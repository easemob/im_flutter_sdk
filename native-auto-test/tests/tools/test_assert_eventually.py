"""assert_eventually：上限内断言通过即继续，重试不污染 Allure 证据。"""
from types import SimpleNamespace

import pytest

from src.tools import assertions, allure_evidence
from src.tools.allure_steps import business_step, quiet, quiet_evidence
from src.tools import config


@pytest.fixture
def clock(monkeypatch):
    state = SimpleNamespace(now=0.0, slept=[])

    def sleep(duration):
        state.slept.append(duration)
        state.now += duration

    monkeypatch.setattr(assertions, 'time', SimpleNamespace(
        monotonic=lambda: state.now, sleep=sleep))
    return state


def configure(monkeypatch, value):
    monkeypatch.setattr(config, 'get_case_timing_config', lambda: value)


def test_first_attempt_passing_costs_no_wait(clock, monkeypatch):
    configure(monkeypatch, {'step': 3, 'poll': {'interval': 1}})
    probes = []
    assertions.assert_eventually(
        lambda: probes.append('r') or {'result': True},
        lambda actual: None,
        key='step.interval', module='chat')
    assert len(probes) == 1
    assert clock.slept == []


def test_retries_until_the_assertion_passes(clock, monkeypatch):
    configure(monkeypatch, {'step': 10, 'poll': {'interval': 1}})
    values = iter([{'result': None}, {'result': None}, {'result': 'ready'}])

    def check(actual):
        assert actual['result'] == 'ready', 'not ready yet'

    actual = assertions.assert_eventually(lambda: next(values), check,
                                          key='step.interval', module='chat')
    assert actual == {'result': 'ready'}
    assert clock.slept == [1, 1]


def test_bound_exhausted_raises_the_original_assertion(clock, monkeypatch):
    configure(monkeypatch, {'step': 3, 'poll': {'interval': 2}})

    def check(actual):
        raise AssertionError('响应与预期不一致（字段级差异）')

    with pytest.raises(AssertionError, match='字段级差异'):
        assertions.assert_eventually(lambda: {'result': None}, check,
                                     key='step.interval', module='chat')
    # 间隔夹在剩余预算内，不越过上限。
    assert clock.slept == [2, 1]


def test_zero_bound_probes_once(clock, monkeypatch):
    configure(monkeypatch, {'step': 0})
    probes = []

    def check(actual):
        raise AssertionError('boom')

    with pytest.raises(AssertionError, match='boom'):
        assertions.assert_eventually(lambda: probes.append(1) or {}, check,
                                     key='step.interval', module='chat')
    assert probes == [1]
    assert clock.slept == []


def test_probe_is_called_once_per_attempt(clock, monkeypatch):
    """只读探针也不应被同一轮次重复调用（避免额外服务端请求）。"""
    configure(monkeypatch, {'step': 2, 'poll': {'interval': 1}})
    probes = []
    checks = []

    def check(actual):
        checks.append(actual)
        assert len(probes) >= 2, 'still waiting'

    assertions.assert_eventually(lambda: probes.append(1) or {'n': len(probes)},
                                 check, key='step.interval', module='chat')
    assert len(probes) == 2
    # 每次尝试静默校验一次，决定性的那次再记录一次证据。
    assert len(checks) == 3


def test_quiet_evidence_suppresses_steps_and_attachments(monkeypatch):
    recorded = []
    monkeypatch.setattr(allure_evidence, 'step',
                        lambda title: recorded.append(title) or __import__('contextlib').nullcontext())
    with business_step('记录'):
        pass
    with quiet_evidence():
        assert quiet() is True
        with business_step('静默'):
            pass
        allure_evidence.attach('01 请求', {'k': 'v'})
    assert quiet() is False
    assert recorded == ['步骤 1：记录'] or recorded == ['记录'], recorded
    assert len(recorded) == 1, recorded
