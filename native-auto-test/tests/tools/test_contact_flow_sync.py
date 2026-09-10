from types import SimpleNamespace

import pytest

from src.test_flow.model_test_flow import ContactTestFlow


class Device:
    def __init__(self):
        self.events = []
        self.hook = lambda cmd, info: None
        self.calls = []

    def call(self, manager, cmd, info):
        self.calls.append(cmd)
        self.hook(cmd, info)
        return {'result': True}

    def receive_message(self, *, match_event_type, timeout):
        assert 0 < timeout <= 10
        for i, event in enumerate(self.events):
            if event['eventType'] == match_event_type:
                return self.events.pop(i)
        return None


def event(kind, user='b', **data):
    return {'eventType': kind, 'data': {'userId': user, **data}}


def flow():
    return ContactTestFlow(SimpleNamespace(assert_success=lambda response: None), synchronize=True)


def test_add_waits_for_new_matching_events():
    a, b = Device(), Device()
    a.events = [event('onContactAdded'), event('onFriendRequestAccepted')]
    def invite(cmd, info):
        b.events.extend([event('onContactInvited', 'a', reason='old'),
                         event('onContactInvited', 'a', reason=info['reason'])])
    a.hook = invite
    def accept(cmd, info):
        a.events.extend([event('onContactAdded', 'other'), event('onContactAdded'),
                         event('onFriendRequestAccepted')])
        b.events.append(event('onContactAdded', 'a'))
    b.hook = accept
    flow().establish_friends(a, b, 'a', 'b')
    assert not a.events and not b.events


def test_stale_add_cannot_complete_new_accept():
    a, b = Device(), Device()
    a.events = [event('onContactAdded'), event('onFriendRequestAccepted')]
    a.hook = lambda cmd, info: b.events.append(event('onContactInvited', 'a', reason=info['reason']))
    with pytest.raises(AssertionError, match='onFriendRequestAccepted'):
        flow().establish_friends(a, b, 'a', 'b')


def test_delete_rejects_old_and_wrong_user_events_without_resending():
    a = Device()
    a.events = [event('onContactDeleted')]
    a.hook = lambda cmd, info: a.events.append(event('onContactDeleted', 'other'))
    with pytest.raises(AssertionError, match='onContactDeleted'):
        flow().delete_friend(a, 'b')
    assert a.calls == ['deleteContact']


def test_accept_callbacks_share_one_deadline(monkeypatch):
    from src.test_flow import model_test_flow as module
    clock = [100.0]
    monkeypatch.setattr(module.time, 'monotonic', lambda: clock[0])
    a, b = Device(), Device()
    a.hook = lambda cmd, info: b.events.append(event('onContactInvited', 'a', reason=info['reason']))
    def accept(cmd, info):
        a.events.extend([event('onFriendRequestAccepted'), event('onContactAdded')])
        b.events.append(event('onContactAdded', 'a'))
    b.hook = accept
    original = a.receive_message
    budgets = []
    def receive(**kwargs):
        result = original(**kwargs)
        if result is not None:
            budgets.append(kwargs['timeout'])
            clock[0] += 3.0
        return result
    a.receive_message = receive
    flow().establish_friends(a, b, 'a', 'b')
    assert budgets == [10.0, 7.0]


def test_delete_accepts_matching_new_event():
    a = Device()
    a.hook = lambda cmd, info: a.events.append(event('onContactDeleted'))
    flow().delete_friend(a, 'b')
    assert a.calls == ['deleteContact']
