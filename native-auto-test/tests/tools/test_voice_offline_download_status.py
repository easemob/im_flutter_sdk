"""下载状态独立于发送和离线操作结果，业务字段仍须严格匹配。"""
from copy import deepcopy
from types import SimpleNamespace

import pytest

from src import Cmd
from src.tools.response_match import compare_response
from tests.chat import test_chat_offline_message_delivery as delivery
from tests.chat import test_chat_offline_message_extended_operations as cases


def check(actual, *, expected, ignore_keys):
    ok, diffs = compare_response(actual, expected, ignore_keys=ignore_keys)
    assert ok, diffs


def run_flow(monkeypatch, download_status=3, mutation=None):
    msg = {
        'msgId': 'real', 'from': 'a', 'to': 'b', 'convId': 'b',
        'chatType': 0, 'direction': 0, 'status': 2, 'hasRead': True,
        'hasReadAck': False, 'hasDeliverAck': False, 'needGroupAck': False,
        'isThread': False, 'isContentReplaced': False, 'deliverOnlineOnly': False,
        'body': {'type': 4, 'displayName': 'voice.mp3', 'duration': 1,
                 'fileStatus': download_status},
    }
    initial = deepcopy(msg)
    initial.update(msgId='temp', status=1)
    success = {'type': 'event', 'eventType': Cmd.onMessageSuccess.value,
               'data': {'msgId': 'temp', 'msg': deepcopy(msg)}}
    received = deepcopy(msg)
    received.update(convId='a', direction=1, hasRead=False, hasDeliverAck=True)
    delivered = deepcopy(msg)
    delivered['hasDeliverAck'] = True
    if mutation:
        target, field, value = mutation
        obj = success['data']['msg'] if target == 'success' else received
        if field in ('duration', 'type'):
            obj['body'][field] = value
        else:
            obj[field] = value
    monkeypatch.setattr(delivery, '_wait_success_event', lambda *a, **kw: success)
    def wait(device, event_type, **kwargs):
        message = received if event_type == Cmd.onMessagesReceived.value else delivered
        return {'type': 'event', 'eventType': event_type, 'data': {'messages': [message]}}
    monkeypatch.setattr(cases, '_wait_message_event', wait)
    param = next(p for p in cases._TYPED_OPERATION_CASES if p.id == 'voice')
    payload, sent_body, received_body = cases._case_payload_and_bodies(*param.values, 'b')
    device = SimpleNamespace(call=lambda *a, **kw: {
        'manager': 'ChatManager', 'cmd': Cmd.sendMessageWithType.value,
        'device': 'deviceA', 'result': initial,
    })
    return cases._send_online_typed(
        device, object(), SimpleNamespace(assert_response_matches=check),
        user_a='a', user_b='b', type_key='voice', payload=payload,
        sent_body=sent_body, received_body=received_body,
    )


@pytest.mark.parametrize('download_status', [0, 1, 2, 3])
def test_valid_download_status_is_independent_of_send_success(monkeypatch, download_status):
    assert run_flow(monkeypatch, download_status)[0] == 'real'


@pytest.mark.parametrize('download_status', [None, -1, 4, '3', True])
def test_invalid_download_status_still_fails(monkeypatch, download_status):
    with pytest.raises(AssertionError, match='fileStatus'):
        run_flow(monkeypatch, download_status)


@pytest.mark.parametrize('mutation, field', [
    (('success', 'status', 1), 'status'),
    (('success', 'duration', 99), 'duration'),
    (('success', 'type', 5), 'type'),
    (('received', 'msgId', 'wrong-message'), 'msgId'),
])
def test_business_fields_still_fail(monkeypatch, mutation, field):
    with pytest.raises(AssertionError, match=field):
        run_flow(monkeypatch, mutation=mutation)


@pytest.mark.parametrize('case_name', [
    'test_chat_offline_typed_message_read_after_sender_relogin',
    'test_chat_offline_typed_message_recall_after_recipient_relogin',
    'test_chat_offline_media_attributes_modified_after_recipient_relogin',
])
def test_cases_reuse_friends_and_restore_on_send_failure(monkeypatch, case_name):
    class SendFailure(Exception):
        pass

    restored = []
    monkeypatch.setattr(cases, '_establish_friendship',
                        lambda *a, **kw: pytest.fail('must reuse ensure_friends'), raising=False)
    monkeypatch.setattr(cases, 'timing_pause', lambda *a, **kw: None)
    def fail_send(*args, **kwargs):
        raise SendFailure('send failed')
    monkeypatch.setattr(cases, '_send_online_typed', fail_send)
    monkeypatch.setattr(cases, '_restore_case', lambda *a, **kw: restored.append(kw))
    param = next(p for p in cases._TYPED_OPERATION_CASES if p.id == 'voice')
    with pytest.raises(SendFailure):
        getattr(cases, case_name)(object(), object(), object(), 'a', 'b', *param.values)
    assert restored == [{'user_a': 'a', 'user_b': 'b'}]


def test_restore_recovers_both_sessions_without_deleting_friends(monkeypatch):
    actions = []
    monkeypatch.setattr(delivery, 'restore_user_login',
                        lambda device, **kw: actions.append(('restore', device, kw['user_id'])))
    monkeypatch.setattr(delivery, '_cleanup_relation',
                        lambda *a: pytest.fail('must preserve shared friends'), raising=False)
    delivery._restore_case('device-a', 'device-b', user_a='a', user_b='b')
    assert actions == [('restore', 'device-a', 'a'), ('restore', 'device-b', 'b')]
