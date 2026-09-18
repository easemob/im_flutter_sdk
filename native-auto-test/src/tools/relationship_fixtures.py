"""Opt-in fixtures; unrelated cases perform no relationship work."""
from contextlib import contextmanager, ExitStack
import time

from src.tools.case_timing import seconds
from src.tools.response_match import _Matcher

import pytest

from src import Cmd
from src.test_flow.offline_test_flow import logout_for_offline, login_preserving_offline_events, restore_user_login
from src.test_flow.relationship_state import RelationshipState
from src.rest_api.user_api import update_user_metadata


def pytest_configure(config):
    config.addinivalue_line('markers', 'no_friend_setup: skip the default Chat A/B friendship setup')


@contextmanager
def relationship_scope(device_a, device_b, assert_api, user_a, user_b, mode):
    state = RelationshipState(device_a, device_b, assert_api, user_a, user_b)
    recovery = state
    try:
        if mode == 'friends':
            state.ensure_present()
            state = RelationshipState(device_a, device_b, assert_api, user_a, user_b)
            # Newly created clean relationships may be reused; pre-existing blocks are restored.
            if not any(recovery.users[1-i] in recovery.blocks[i] for i in range(2)):
                recovery = state
        elif mode == 'nonfriends':
            state.clear_pending()
            state.ensure_absent()
        elif mode == 'change':
            state.clear_pending()
            state.ensure_absent()
            # Relationship-change cases manually accept invitations.
            from src.test_flow.offline_test_flow import set_accept_invitation_always
            set_accept_invitation_always(device_b, assert_api, device_name='deviceB', enabled=False)
        else:
            raise ValueError(mode)
        yield state
    finally:
        recovery.restore()


@pytest.fixture
def friends_ab(device_a, device_b, assert_api, user_a, user_b):
    with relationship_scope(device_a, device_b, assert_api, user_a, user_b, 'friends') as state:
        yield state


@pytest.fixture
def friends_ab_records(friends_ab):
    friends_ab.capture_records()
    return friends_ab


@pytest.fixture
def nonfriends_ab(device_a, device_b, assert_api, user_a, user_b):
    with relationship_scope(device_a, device_b, assert_api, user_a, user_b, 'nonfriends') as state:
        yield state


@pytest.fixture
def relation_ab(device_a, device_b, assert_api, user_a, user_b):
    with relationship_scope(device_a, device_b, assert_api, user_a, user_b, 'change') as state:
        yield state


@contextmanager
def _temporary_login(device, assert_api, device_name, target, original):
    try:
        logout_for_offline(device, assert_api, device_name=device_name, module='contact')
        login_preserving_offline_events(device, assert_api, device_name=device_name,
                                       user_id=target, module='contact')
        yield
    finally:
        restore_user_login(device, user_id=original, module='contact')
        # Do not silently leave C logged in if the best-effort recovery failed.
        response = device.call('Client', Cmd.getCurrentUser.value, info={})
        assert_api.assert_response_matches(
            response, expected={'manager': 'Client', 'cmd': Cmd.getCurrentUser.value,
                                'device': device_name, 'result': original}, ignore_keys={'sequence'})


@pytest.fixture
def nonfriends_ac(device_a, device_b, assert_api, user_a, user_b, user_c):
    with _temporary_login(device_b, assert_api, 'deviceB', user_c, user_b):
        with relationship_scope(device_a, device_b, assert_api, user_a, user_c, 'nonfriends') as state:
            yield state


@pytest.fixture
def friends_ac(ensure_friends, device_a, device_b, assert_api, user_a, user_b, user_c):
    # Defer switching until pagination has finished preparing the A/B conversation.
    with ExitStack() as stack:
        def prepare():
            stack.enter_context(_temporary_login(device_b, assert_api, 'deviceB', user_c, user_b))
            state = RelationshipState(device_a, device_b, assert_api, user_a, user_c)
            stack.callback(state.restore)
            state.ensure_present()
            return state
        yield prepare


@pytest.fixture
def no_pending_bc(device_a, device_b, assert_api, user_a, user_b, user_c):
    with _temporary_login(device_a, assert_api, 'deviceA', user_c, user_a):
        with relationship_scope(device_a, device_b, assert_api, user_c, user_b, 'nonfriends') as state:
            yield state


@pytest.fixture
def restore_peer_nickname(friends_ab, device_b, assert_api, user_b):
    def read_nickname():
        response = device_b.call('UserInfoManager', Cmd.fetchOwnInfo.value, info={})
        assert_api.assert_response_matches(
            response, expected={
                'manager': 'UserInfoManager', 'cmd': Cmd.fetchOwnInfo.value, 'device': 'deviceB',
                'result': _Matcher('userInfo', lambda value, uid: isinstance(value, dict)
                                   and value.get('userId') == uid
                                   and (value.get('nickName') is None or isinstance(value['nickName'], str)), user_b),
            }, ignore_keys={'sequence'},
        )
        return response['result'].get('nickName') or ''
    old_nickname = read_nickname()
    try:
        yield
    finally:
        update_user_metadata(user_b, {'nickname': old_nickname})
        deadline = time.monotonic() + seconds('timeout.friend_ready', module='chat')
        while time.monotonic() < deadline:
            if read_nickname() == old_nickname:
                break
            # 间隔夹在剩余预算内；预算耗尽时 sleep(0) 让循环走到 else 分支报错。
            remaining = max(0.0, deadline - time.monotonic())
            time.sleep(min(seconds('poll.server_state', module='chat'), remaining))
        else:
            raise AssertionError('昵称未恢复到原值')
