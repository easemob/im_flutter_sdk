"""Exercise the shared fixture with delayed/stale callbacks and server visibility."""
from types import SimpleNamespace

import pytest

from src import Cmd
from src.tools.response_match import compare_response
from src.test_flow import friendship_setup as setup
from tests.chat import test_chat_offline_message_delivery as offline


class World:
    def __init__(self, ready=False):
        self.contacts = {'a': ['b'] if ready else [], 'b': ['a'] if ready else []}
        self.calls = []
        self.events = []
        self.drained = []
        self.now = 0.0
        self.only_stale = False
        self.one_sided = False
        self.add_timeout = False
        self.recover_timeout = False
        self.bad_accept = False
        self.query_timeouts = 0
        self.query_error = False

    def device(self, uid):
        name = 'deviceA' if uid == 'a' else 'deviceB'
        def call(manager, cmd, info):
            self.calls.append((uid, cmd, info))
            if cmd == Cmd.getAllContactsFromServer.value:
                if self.query_timeouts:
                    self.query_timeouts -= 1
                    raise TimeoutError('query timeout')
                result = None if self.query_error else list(self.contacts[uid])
            elif cmd == Cmd.updateAcceptInvitationAlways.value:
                assert info == {'acceptInvitationAlways': False}
                result = None
            elif cmd == Cmd.addContact.value:
                if self.add_timeout:
                    if self.recover_timeout:
                        self.contacts = {'a': ['b'], 'b': ['a']}
                    raise TimeoutError('add timeout')
                reason = info['reason']
                self.events = [self.invite('a', 'chat-setup'), self.invite('c', reason)]
                if not self.only_stale:
                    self.events.append(self.invite('a', reason))
                result = 'b'
            elif cmd == Cmd.acceptInvitation.value:
                self.contacts['a'] = ['b']
                if not self.one_sided:
                    self.contacts['b'] = ['a']
                result = {} if self.bad_accept else 'a'
            else:
                pytest.fail(f'unexpected friend operation: {cmd}')
            return {'manager': manager, 'cmd': cmd, 'device': name, 'result': result}
        def receive(**kwargs):
            self.now += 0.1
            if self.events:
                return self.events.pop(0)
            self.now += kwargs['timeout']
        return SimpleNamespace(call=call, receive_message=receive,
                               drain_events=lambda **kw: self.drained.append(uid))

    @staticmethod
    def invite(uid, reason):
        return {'type': 'event', 'eventType': 'onContactInvited',
                'data': {'userId': uid, 'reason': reason}}

    def pause(self, *args, **kwargs):
        self.now += 0.25

    def run(self, monkeypatch):
        monkeypatch.setattr(setup, 'time', SimpleNamespace(monotonic=lambda: self.now, sleep=lambda duration: self.pause()))
        monkeypatch.setattr(setup, 'timing_pause', self.pause)
        monkeypatch.setattr(setup, 'timing_seconds', lambda *a, **kw: 1.0)
        def check(actual, *, expected, ignore_keys):
            ok, diffs = compare_response(actual, expected, ignore_keys=ignore_keys)
            assert ok, diffs
        setup.ensure_friendship(
            self.device('a'), self.device('b'),
            SimpleNamespace(assert_response_matches=check), 'a', 'b',
        )

    def count(self, cmd):
        return sum(call[1] == cmd for call in self.calls)


def test_existing_relation_never_sends_invitation(monkeypatch):
    world = World(ready=True)
    world.run(monkeypatch)
    assert world.count(Cmd.addContact.value) == 0
    assert world.count(Cmd.acceptInvitation.value) == 0
    assert world.drained == ['a', 'b']


def test_stale_and_other_user_invites_are_not_accepted(monkeypatch):
    world = World()
    world.run(monkeypatch)
    assert world.count(Cmd.addContact.value) == 1
    assert world.count(Cmd.acceptInvitation.value) == 1
    assert world.events == []
    assert world.contacts == {'a': ['b'], 'b': ['a']}
    assert world.drained[-2:] == ['a', 'b']


def test_only_stale_invites_fail_without_accepting(monkeypatch):
    world = World()
    world.only_stale = True
    with pytest.raises(pytest.fail.Exception, match='本次好友申请'):
        world.run(monkeypatch)
    assert world.count(Cmd.acceptInvitation.value) == 0


def test_one_sided_relation_does_not_finish_setup(monkeypatch):
    world = World()
    world.one_sided = True
    with pytest.raises(AssertionError, match='双端服务端可见'):
        world.run(monkeypatch)


def test_bad_accept_response_cannot_prove_itself(monkeypatch):
    world = World()
    world.bad_accept = True
    with pytest.raises(AssertionError, match='result'):
        world.run(monkeypatch)


@pytest.mark.parametrize('recover', [False, True])
def test_add_timeout_never_reissues_invitation(monkeypatch, recover):
    world = World()
    world.add_timeout = True
    world.recover_timeout = recover
    if recover:
        world.run(monkeypatch)
    else:
        with pytest.raises(TimeoutError, match='add timeout'):
            world.run(monkeypatch)
    assert world.count(Cmd.addContact.value) == 1


def test_query_timeout_retries_without_creating_relation(monkeypatch):
    world = World(ready=True)
    world.query_timeouts = 1
    world.run(monkeypatch)
    assert world.count(Cmd.addContact.value) == 0
    assert world.count(Cmd.getAllContactsFromServer.value) == 3


def test_invalid_contact_query_is_not_treated_as_empty(monkeypatch):
    world = World()
    world.query_error = True
    with pytest.raises(AssertionError, match='result'):
        world.run(monkeypatch)
    assert world.count(Cmd.addContact.value) == 0


def test_offline_preparation_keeps_conversation_and_logout_steps(monkeypatch):
    calls = []
    def call(manager, cmd, info):
        calls.append((manager, cmd, info))
        return {'manager': manager, 'cmd': cmd, 'device': 'deviceB', 'result': True}
    def check(actual, **kwargs):
        ok, diffs = compare_response(actual, kwargs['expected'], ignore_keys=kwargs['ignore_keys'])
        assert ok, diffs
    monkeypatch.setattr(offline, 'timing_pause', lambda *a, **kw: None)
    monkeypatch.setattr(offline, 'logout_for_offline', lambda *a, **kw: calls.append(('logout',)))
    offline._prepare_offline_friend(
        object(), SimpleNamespace(call=call), SimpleNamespace(assert_response_matches=check),
        user_a='a', user_b='b',
    )
    assert calls == [
        ('ConversationManager', Cmd.clearAllMessages.value, {'convId': 'a', 'type': 0}),
        ('ConversationManager', Cmd.markAllMessagesAsRead.value, {'convId': 'a', 'type': 0}),
        ('logout',),
    ]
