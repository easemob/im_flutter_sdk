"""Relationship state isolation, real fixture lifecycles, and list baselines."""
from copy import deepcopy
from types import SimpleNamespace

import pytest

from src import Cmd
from src.test_flow import relationship_state as module
from src.tools import relationship_fixtures as fixtures
from src.tools.response_match import compare_response
from tests.chat import conftest as chat


class World:
    def __init__(self):
        self.contacts = {u: set() for u in 'abcd'}
        self.blocks = {u: set() for u in 'abcd'}
        self.remarks = {}
        self.pending = set()
        self.logged = ['a', 'b']
        self.calls = []
        self.pages = None
        self.devices = [self.device(i) for i in range(2)]
        self.api = SimpleNamespace(assert_response_matches=self.check)

    def add(self, a, b):
        self.contacts[a].add(b)
        self.contacts[b].add(a)

    @staticmethod
    def check(actual, *, expected, ignore_keys):
        ok, diffs = compare_response(actual, expected, ignore_keys=ignore_keys)
        assert ok, diffs

    def device(self, side):
        def call(manager, cmd, info):
            uid = self.logged[side]
            peer = info.get('userId')
            self.calls.append((uid, cmd, deepcopy(info)))
            if cmd == Cmd.updateAcceptInvitationAlways.value:
                result = None
            elif cmd == Cmd.getCurrentUser.value:
                result = uid
            elif cmd == Cmd.getAllContactsFromServer.value:
                result = sorted(self.contacts[uid])
            elif cmd == Cmd.getBlockListFromServer.value:
                result = sorted(self.blocks[uid])
            elif cmd == Cmd.getContact.value:
                result = {'userId': peer, 'remark': self.remarks.get((uid, peer), '')}
            elif cmd == Cmd.setContactRemark.value:
                self.remarks[uid, peer] = info['remark']
                result = None
            elif cmd == Cmd.deleteContact.value:
                self.contacts[uid].discard(peer)
                self.contacts[peer].discard(uid)
                self.remarks.pop((uid, peer), None)
                self.remarks.pop((peer, uid), None)
                result = peer
            elif cmd == Cmd.declineInvitation.value:
                self.pending.discard((peer, uid))
                result = peer
            elif cmd == Cmd.addUserToBlockList.value:
                self.blocks[uid].add(peer)
                result = peer
            elif cmd == Cmd.removeUserFromBlockList.value:
                self.blocks[uid].discard(peer)
                result = peer
            elif cmd == Cmd.fetchAllContacts.value:
                result = [{'userId': u, 'remark': self.remarks.get((uid, u), '')}
                          for u in sorted(self.contacts[uid])]
            elif cmd == Cmd.fetchContacts.value:
                records = self.pages if self.pages is not None else [
                    {'userId': u, 'remark': self.remarks.get((uid, u), '')}
                    for u in sorted(self.contacts[uid])]
                index = int(info['cursor'] or 0)
                end = index + info['pageSize']
                result = {'list': records[index:end], 'cursor': str(end) if end < len(records) else ''}
            else:
                pytest.fail(f'Unexpected command: {cmd}')
            return {'manager': manager, 'cmd': cmd, 'device': ('deviceA', 'deviceB')[side], 'result': result}
        return SimpleNamespace(call=call, drain_events=lambda **kw: None, side=side)

    def install(self, monkeypatch):
        monkeypatch.setattr(module, 'ensure_friendship', lambda a, b, api, ua, ub: self.add(ua, ub))
        monkeypatch.setattr(module, 'seconds', lambda *a, **kw: 0.05)
        def restore(device, *, user_id, **kwargs):
            self.logged[device.side] = user_id
        monkeypatch.setattr(module, 'restore_user_login', restore)
        monkeypatch.setattr(fixtures, 'restore_user_login', restore)
        monkeypatch.setattr(fixtures, 'logout_for_offline', lambda *a, **kw: None)
        monkeypatch.setattr(fixtures, 'login_preserving_offline_events',
                            lambda device, *a, user_id, **kw: restore(device, user_id=user_id))
        return self

    def scope(self, mode):
        return fixtures.relationship_scope(*self.devices, self.api, 'a', 'b', mode)


@pytest.mark.parametrize('mode', ['change', 'nonfriends'])
def test_failure_restores_original_friends_remarks_and_blocks(monkeypatch, mode):
    world = World().install(monkeypatch)
    world.add('a', 'b'); world.add('a', 'c')
    world.blocks['a'] = {'b', 'd'}
    world.remarks['a', 'b'] = 'old-a'
    world.remarks['b', 'a'] = 'old-b'
    before = deepcopy((world.contacts, world.blocks, world.remarks))
    with pytest.raises(RuntimeError, match='business failed'):
        with world.scope(mode):
            assert 'b' not in world.contacts['a']
            assert 'a' not in world.contacts['b']
            world.add('a', 'b')
            world.remarks['a', 'b'] = 'changed'
            world.blocks['b'].add('a')
            raise RuntimeError('business failed')
    assert (world.contacts, world.blocks, world.remarks) == before


def test_change_case_restores_absence_and_cancels_its_pending_requests(monkeypatch):
    world = World().install(monkeypatch)
    world.add('a', 'c')
    with pytest.raises(RuntimeError):
        with world.scope('change'):
            world.pending.add(('a', 'b'))
            world.add('a', 'b')
            raise RuntimeError()
    assert world.contacts['a'] == {'c'}
    assert world.contacts['b'] == set()
    assert world.pending == set()


def test_reusable_friends_keep_relation_but_restore_remark_on_failure(monkeypatch):
    world = World().install(monkeypatch)
    with pytest.raises(RuntimeError):
        with world.scope('friends'):
            world.remarks['a', 'b'] = 'changed'
            raise RuntimeError()
    assert world.contacts['a'] == {'b'}
    assert world.remarks['a', 'b'] == ''


def test_prepare_failure_also_runs_cleanup(monkeypatch):
    world = World().install(monkeypatch)
    def fail(*args):
        world.add('a', 'b')
        raise RuntimeError('prepare failed')
    monkeypatch.setattr(module, 'ensure_friendship', fail)
    with pytest.raises(RuntimeError, match='prepare failed'):
        with world.scope('friends'):
            pytest.fail('must not enter case')
    assert world.contacts['a'] == set()


def test_unrelated_friend_loss_is_not_hidden_by_recovery(monkeypatch):
    world = World().install(monkeypatch)
    world.add('a', 'c')
    with pytest.raises(AssertionError, match='result'):
        with world.scope('nonfriends'):
            world.contacts['a'].remove('c')


def test_no_friend_marker_does_not_request_devices(monkeypatch):
    request = SimpleNamespace(node=SimpleNamespace(get_closest_marker=lambda name: True),
                              getfixturevalue=lambda name: pytest.fail('unneeded fixture'))
    chat.ensure_friends.__wrapped__(request)


def test_pagination_preserves_other_contacts_and_rejects_omission(monkeypatch):
    world = World().install(monkeypatch)
    world.add('a', 'c')
    with world.scope('friends') as state:
        state.capture_records()
        world.remarks['a', 'b'] = 'new'
        state.assert_pages('new', page_size=1)
        world.pages = [{'userId': 'b', 'remark': 'new'}]
        with pytest.raises(AssertionError, match='分页好友列表'):
            state.assert_pages('new', page_size=1)


def test_exact_items_rejects_duplicates_and_preserves_order_independence():
    matcher = module.ExactItems(['b', 'c'])
    assert matcher.check(['c', 'b'])
    assert not matcher.check(['b', 'b'])
    assert not matcher.check(['b'])


def test_pagination_switch_is_deferred_and_original_login_restored(monkeypatch):
    world = World().install(monkeypatch)
    world.add('a', 'b')
    fixture = fixtures.friends_ac.__wrapped__(None, *world.devices, world.api, 'a', 'b', 'c')
    prepare = next(fixture)
    assert world.logged == ['a', 'b']
    prepare()
    assert world.logged == ['a', 'c']
    assert world.contacts['a'] == {'b', 'c'}
    fixture.close()
    assert world.logged == ['a', 'b']
    assert world.contacts['a'] == {'b'}


def test_no_pending_fixture_keeps_third_party_contacts(monkeypatch):
    world = World().install(monkeypatch)
    world.add('a', 'c')
    world.pending = {('b', 'c'), ('c', 'b')}
    fixture = fixtures.no_pending_bc.__wrapped__(*world.devices, world.api, 'a', 'b', 'c')
    state = next(fixture)
    assert world.logged == ['c', 'b']
    assert world.pending == set()
    assert state.ids(0, friends=False).check(['a'])
    fixture.close()
    assert world.logged == ['a', 'b']
    assert world.contacts['c'] == {'a'}


def test_default_chat_setup_still_requires_shared_friends(monkeypatch):
    calls = []
    monkeypatch.setattr(chat, 'ensure_friendship', lambda *args: calls.append(args))
    request = SimpleNamespace(node=SimpleNamespace(get_closest_marker=lambda name: None),
                              getfixturevalue=lambda name: name)
    chat.ensure_friends.__wrapped__(request)
    assert calls == [('device_a', 'device_b', 'assert_api', 'user_a', 'user_b')]


@pytest.mark.parametrize('original', ['original-nickname', ''])
def test_nickname_finalizer_restores_value_without_swallowing_failure(monkeypatch, original):
    values = {'nickName': original}
    def call(manager, cmd, info):
        return {'manager': manager, 'cmd': cmd, 'device': 'deviceB',
                'result': {'userId': 'b', 'nickName': values['nickName']}}
    monkeypatch.setattr(fixtures, 'update_user_metadata',
                        lambda user, info: values.update(nickName=info['nickname']))
    fixture = fixtures.restore_peer_nickname.__wrapped__(
        object(), SimpleNamespace(call=call), SimpleNamespace(assert_response_matches=World.check), 'b')
    next(fixture)
    values['nickName'] = 'changed'
    with pytest.raises(RuntimeError, match='business failed'):
        fixture.throw(RuntimeError('business failed'))
    assert values['nickName'] == original


def test_contact_pagination_accepts_sdk_nullable_end_cursor(monkeypatch):
    world = World().install(monkeypatch)
    with world.scope('friends') as state:
        state.capture_records()
        original_call = state.devices[0].call
        def call(manager, cmd, info):
            response = original_call(manager, cmd, info)
            if cmd == Cmd.fetchContacts.value and response['result']['cursor'] == '':
                response['result']['cursor'] = None
            return response
        monkeypatch.setattr(state.devices[0], 'call', call)
        state.assert_pages('')
