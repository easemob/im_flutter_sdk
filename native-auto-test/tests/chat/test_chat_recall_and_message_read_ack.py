from __future__ import annotations

import time
import uuid

import pytest

from src import Cmd
from tests.chat._utils import swt_to_send

pytestmark = [pytest.mark.client, pytest.mark.chat]


def _event(device, event_type, predicate=None, timeout=30.0):
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        evt = device.receive_message(match_event_type=event_type, timeout=2.0)
        if evt:
            seen.append(evt)
            if predicate is None or predicate(evt):
                return evt
    pytest.fail(f"未收到 {event_type}: seen={seen}")


def _send_typed(device_a, device_b, assert_api, user_a, user_b, type_key, payload):
    device_a.drain_events(); device_b.drain_events()
    resp = device_a.call("ChatManager", Cmd.sendMessage.value, info=swt_to_send({"type": type_key, "payload": {"targetId": user_b, **payload}, "chatType": 0}))
    result = resp.get("result") or {}
    temp_id = result.get("msgId")
    assert temp_id, resp
    success = _event(device_a, Cmd.onMessageSuccess.value, lambda e: ((e.get("data") or {}).get("msg") or {}).get("msgId"))
    sent = (success.get("data") or {}).get("msg") or {}
    real_id = sent.get("msgId")
    received = _event(device_b, Cmd.onMessagesReceived.value, lambda e: any(str(m.get("msgId")) == str(real_id) for m in ((e.get("data") or {}).get("messages") or []) if isinstance(m, dict)))
    return resp, success, received, real_id


def test_chat_missing_recall_empty_message_id(device_a, assert_api):
    resp = device_a.call("ChatManager", Cmd.recallMessage.value, info={"msgId": ""})
    assert_api.assert_response_matches(resp, expected={"manager": "ChatManager", "cmd": Cmd.recallMessage.value, "device": "deviceA", # 只看 errorcode（leader 要求）：描述两端不同，code 一致 500
"result": {"code": 500}}, ignore_keys={"sequence"})


@pytest.mark.parametrize("info", [{"msgId": "", "to": "test0714user1"}, {"msgId": "__invalid_msg_id__", "to": ""}, {"msgId": "__invalid_msg_id__", "to": "__invalid_user__"}])
def test_chat_missing_ack_message_read_boundaries(device_b, assert_api, info):
    resp = device_b.call("ChatManager", Cmd.ackMessageRead.value, info=info)
    # 5.0 ackMessageRead 走 asyncSendMessageReadReceipts；原生实际：两端一致 110 "messages is empty"
    assert_api.assert_response_matches(resp, expected={"manager": "ChatManager", "cmd": Cmd.ackMessageRead.value, "device": "deviceB", "result": {"code": 110, "description": "messages is empty"}}, ignore_keys={"sequence"})
