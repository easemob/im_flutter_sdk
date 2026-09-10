"""Offline tests; no devices, REST, or backend required."""
from types import SimpleNamespace

import pytest

from src.tools import send_status_wait as subject


class Device:
    def __init__(self, events):
        self.events = list(events)
        self.now = 0.0

    def receive_message(self, *, match_event_type, timeout):
        for i, event in enumerate(self.events):
            if event['eventType'] == match_event_type:
                return self.events.pop(i)
        self.now += timeout


def event(kind, local_id='local', **data):
    return {'type': 'event', 'eventType': kind,
            'data': {'msgId': local_id, **data}}


def setup(monkeypatch, events):
    device = Device(events)
    monkeypatch.setattr(subject, 'time', SimpleNamespace(monotonic=lambda: device.now))
    return device


def test_returns_original_success_with_server_id(monkeypatch):
    success = event('onMessageSuccess', msg={'msgId': 'server'})
    device = setup(monkeypatch, [success])
    assert subject.wait_send_success(device, temp_id='local') is success


def test_error_reports_code_and_status_without_secrets(monkeypatch):
    device = setup(monkeypatch, [event('onMessageError',
        msg={'status': 3, 'body': {'secret': 'PRIVATE'}},
        error={'code': 300, 'description': 'PRIVATE'})])
    with pytest.raises(pytest.fail.Exception) as exc:
        subject.wait_send_success(device, temp_id='local')
    assert '300' in str(exc.value)
    assert "'status': 3" in str(exc.value)
    assert 'PRIVATE' not in str(exc.value)
    assert device.now == 0


def test_unrelated_error_does_not_fail_target(monkeypatch):
    success = event('onMessageSuccess')
    device = setup(monkeypatch, [event('onMessageError', 'other'), success])
    assert subject.wait_send_success(device, temp_id='local') is success


def test_timeout_bounded_and_unrelated_event_preserved(monkeypatch):
    other = event('onMessagesReceived')
    device = setup(monkeypatch, [other])
    with pytest.raises(pytest.fail.Exception, match='诊断=\\[\\]'):
        subject.wait_send_success(device, temp_id='local', timeout=1.2)
    assert device.now == pytest.approx(1.2)
    assert device.events == [other]


def test_error_is_not_hidden_by_buffered_late_success(monkeypatch):
    device = setup(monkeypatch, [event('onMessageSuccess'),
        event('onMessageError', error={'code': 300})])
    with pytest.raises(pytest.fail.Exception, match='300'):
        subject.wait_send_success(device, temp_id='local')


def test_zero_budget_does_not_receive(monkeypatch):
    success = event('onMessageSuccess')
    device = setup(monkeypatch, [success])
    with pytest.raises(pytest.fail.Exception):
        subject.wait_send_success(device, temp_id='local', timeout=0)
    assert device.events == [success]
    assert device.now == 0


def test_success_predicate_not_relaxed(monkeypatch):
    device = setup(monkeypatch, [event('onMessageSuccess')])
    with pytest.raises(pytest.fail.Exception, match='未收到满足断言'):
        subject.wait_send_success(device, temp_id='local', predicate=lambda e: False, timeout=1)
