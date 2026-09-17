"""Bounded wait helper: upper bound, immediate first probe, early exit, no leaks."""
from types import SimpleNamespace

import pytest

from src.tools import case_timing as timing, config


class Clock:
    """Fake clock so budgets are asserted without real waiting."""

    def __init__(self):
        self.now = 0.0
        self.slept = []

    def install(self, monkeypatch):
        monkeypatch.setattr(timing, 'time', SimpleNamespace(
            monotonic=lambda: self.now,
            sleep=self._sleep,
        ))
        return self

    def _sleep(self, duration):
        assert duration >= 0, duration
        self.slept.append(duration)
        self.now += duration


@pytest.fixture
def clock(monkeypatch):
    return Clock().install(monkeypatch)


def configure(monkeypatch, value):
    monkeypatch.setattr(config, 'get_case_timing_config', lambda: value)


def test_satisfied_probe_returns_without_waiting(clock, monkeypatch):
    configure(monkeypatch, {'settle': {'offline': 3}, 'poll': {'interval': 1}})
    probes = []
    result = timing.wait_until(lambda: probes.append(1) or 'user-a',
                               lambda value: value == 'user-a',
                               key='settle.offline', module='chat')
    assert result == 'user-a'
    assert len(probes) == 1
    assert clock.slept == []
    assert clock.now == 0.0


def test_late_condition_returns_as_soon_as_satisfied(clock, monkeypatch):
    configure(monkeypatch, {'settle': {'offline': 10}, 'poll': {'interval': 1}})
    values = [None, None, 'ready']
    result = timing.wait_until(lambda: values.pop(0),
                               key='settle.offline', module='chat')
    assert result == 'ready'
    # Two intervals only: the wait stops at the condition, not at the bound.
    assert clock.slept == [1, 1]
    assert clock.now == 2.0


def test_unsatisfied_probe_fails_at_the_bound(clock, monkeypatch):
    configure(monkeypatch, {'settle': {'offline': 3}, 'poll': {'interval': 2}})
    with pytest.raises(AssertionError) as error:
        timing.wait_until(lambda: None, key='settle.offline', module='chat',
                          reason='deviceB 退出后登录态未清空')
    message = str(error.value)
    assert 'deviceB 退出后登录态未清空' in message
    assert '3' in message and 'settle.offline' in message
    # Sleeps are clamped to the remaining budget instead of overshooting it.
    assert clock.slept == [2, 1]
    assert clock.now == 3.0


def test_zero_bound_still_probes_once(clock, monkeypatch):
    configure(monkeypatch, {'settle': {'offline': 0}, 'poll': {'interval': 1}})
    probes = []
    with pytest.raises(AssertionError):
        timing.wait_until(lambda: probes.append(1) or None,
                          key='settle.offline', module='chat')
    assert probes == [1]
    assert clock.slept == []


def test_zero_bound_returns_when_already_satisfied(clock, monkeypatch):
    configure(monkeypatch, {'settle': {'offline': 0}})
    assert timing.wait_until(lambda: 'ok', key='settle.offline', module='chat') == 'ok'


def test_failure_never_echoes_probe_payload(clock, monkeypatch):
    configure(monkeypatch, {'settle': {'offline': 1}, 'poll': {'interval': 1}})
    secret = {'token': 'DO_NOT_PRINT', 'body': 'attachment-secret'}
    with pytest.raises(AssertionError) as error:
        timing.wait_until(lambda: secret, lambda value: False,
                          key='settle.offline', module='chat', reason='状态未收敛')
    assert 'DO_NOT_PRINT' not in str(error.value)
    assert 'attachment-secret' not in str(error.value)


def test_module_and_interval_keys_are_resolved_per_module(clock, monkeypatch):
    configure(monkeypatch, {'settle': {'offline': 4, 'group': {'offline': 8}},
                            'poll': {'interval': 2, 'group': {'interval': 4}}})
    with pytest.raises(AssertionError):
        timing.wait_until(lambda: None, key='settle.offline', module='group')
    assert clock.slept == [4, 4]


def test_unknown_key_or_module_is_rejected(clock, monkeypatch):
    configure(monkeypatch, {})
    with pytest.raises(ValueError):
        timing.wait_until(lambda: True, key='settle.nope', module='chat')
    with pytest.raises(ValueError):
        timing.wait_until(lambda: True, key='settle.offline', module='nope')
