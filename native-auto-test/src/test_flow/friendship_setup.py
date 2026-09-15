"""按需建立双端好友关系，供 Chat 与 Contact 前置复用。"""
from __future__ import annotations

import time
import uuid

import pytest

from src import Cmd
from src.sdk_api.event_keys import ContactChangeEvent
from src.test_flow.offline_test_flow import set_accept_invitation_always
from src.tools.case_timing import seconds as timing_seconds, pause as timing_pause
from src.tools.response_match import _Matcher

def _wait_friend_invitation(device, assert_api, *, user_a: str, reason: str):
    deadline = time.monotonic() + timing_seconds('timeout.friend_invitation', module='chat')
    while time.monotonic() < deadline:
        event = device.receive_message(
            match_event_type=ContactChangeEvent.INVITED.value,
            timeout=max(0.0, deadline - time.monotonic()),
        )
        data = (event or {}).get('data') or {}
        if not isinstance(data, dict) or data.get('userId') != user_a or data.get('reason') != reason:
            continue
        assert_api.assert_response_matches(
            event,
            expected={
                'type': 'event', 'eventType': ContactChangeEvent.INVITED.value,
                'data': {'userId': user_a, 'reason': reason},
            },
            ignore_keys={'timestamp', 'sequence'},
        )
        return
    pytest.fail(f'前置未收到本次好友申请回调：userId={user_a}, reason={reason}')


def ensure_friendship(device_a, device_b, assert_api, user_a, user_b):
    def _call_with_retry(device, manager, cmd, *, attempts=3):
        for attempt in range(attempts):
            try:
                return device.call(manager, cmd, info={})
            except TimeoutError:
                if attempt + 1 == attempts:
                    raise
                timing_pause('retry.backoff', module='chat')

    def _contact_list(device, device_name):
        response = _call_with_retry(device, 'ContactManager', Cmd.getAllContactsFromServer.value)
        assert_api.assert_response_matches(
            response,
            expected={
                'manager': 'ContactManager', 'cmd': Cmd.getAllContactsFromServer.value,
                'device': device_name,
                'result': _Matcher('type', lambda actual, _: isinstance(actual, list)
                                   and all(isinstance(uid, str) for uid in actual), 'list[str]'),
            },
            ignore_keys={'sequence'},
        )
        return response['result']

    def _friend_ready(timeout):
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            contacts_a = _contact_list(device_a, 'deviceA')
            contacts_b = _contact_list(device_b, 'deviceB')
            if user_b in contacts_a and user_a in contacts_b:
                return True
            time.sleep(timing_seconds('poll.server_state', module='chat'))
        return False

    def _drain_events():
        for device in (device_a, device_b):
            device.drain_events(timeout=timing_seconds('drain.offline', module='chat'))

    if _friend_ready(timing_seconds('timeout.friend_probe', module='chat')):
        _drain_events()
        return

    _drain_events()
    set_accept_invitation_always(
        device_b, assert_api, device_name='deviceB', enabled=False,
    )
    reason = f'chat-setup-{uuid.uuid4().hex}'
    try:
        response = device_a.call(
            'ContactManager', Cmd.addContact.value, info={'userId': user_b, 'reason': reason},
        )
    except TimeoutError:
        # 请求可能已生效：仅查询关系恢复，不再重复发送申请。
        if _friend_ready(timing_seconds('timeout.friend_recovery', module='chat')):
            _drain_events()
            return
        raise
    assert_api.assert_response_matches(
        response,
        expected={'manager': 'ContactManager', 'cmd': Cmd.addContact.value,
                  'device': 'deviceA', 'result': user_b},
        ignore_keys={'sequence'},
    )
    _wait_friend_invitation(device_b, assert_api, user_a=user_a, reason=reason)
    timing_pause('step.interval', module='chat')
    accepted = device_b.call(
        'ContactManager', Cmd.acceptInvitation.value, info={'userId': user_a},
    )
    assert_api.assert_response_matches(
        accepted,
        expected={'manager': 'ContactManager', 'cmd': Cmd.acceptInvitation.value,
                  'device': 'deviceB', 'result': user_a},
        ignore_keys={'sequence'},
    )
    assert _friend_ready(timing_seconds('timeout.friend_ready', module='chat')), (
        'chat 前置好友关系未完成双端服务端可见，不能继续消息用例'
    )
    _drain_events()
