from __future__ import annotations

import os
import time
import uuid

import pytest

from src import Cmd
from tests.chat._utils import build_text

pytestmark = [pytest.mark.client, pytest.mark.chat]


def _wait_message_list_event(device, event_type, *, msg_id, timeout=30):
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        event = device.receive_message(match_event_type=event_type, timeout=2)
        if event:
            seen.append(event)
        for message in (((event or {}).get("data") or {}).get("messages") or []):
            if isinstance(message, dict) and str(message.get("msgId")) == str(msg_id):
                return message
    pytest.fail(f"未收到消息列表事件: eventType={event_type}, msgId={msg_id}, seen={seen}")


def _assert_text_event(assert_api, event_type, message, *, msg_id, user_a, user_b,
                       content, direction, conv_id, has_read, has_deliver_ack):
    assert_api.assert_response_matches(
        {"type": "event", "eventType": event_type, "data": {"messages": [message]}},
        expected={"type": "event", "eventType": event_type, "data": {"messages": [{
            "msgId": msg_id, "from": user_a, "to": user_b, "convId": conv_id,
            "chatType": 0, "direction": direction, "status": 2,
            "hasRead": has_read, "hasReadAck": False, "hasDeliverAck": has_deliver_ack,
            "needGroupAck": False, "isThread": False, "isContentReplaced": False,
            "deliverOnlineOnly": False,
            "body": {"type": 0, "content": content, "translations": {}},
        }]}},
        ignore_keys={"timestamp", "sequence", "localTime", "serverTime", "broadcast", "onlineState",
                     "targetLanguages"},
    )


def _send_text(device_a, device_b, assert_api, user_a, user_b, content):
    device_a.drain_events(); device_b.drain_events()
    resp = device_a.call("ChatManager", Cmd.sendMessage.value, info=build_text(user_a, user_b, content))
    temp = ((resp.get("result") or {}).get("msgId"))
    assert temp, resp
    assert_api.assert_response_matches(
        resp,
        expected={"manager": "ChatManager", "cmd": Cmd.sendMessage.value, "device": "deviceA", "result": {
            "msgId": temp, "from": user_a, "to": user_b, "convId": user_b,
            "chatType": 0, "direction": 0, "status": 0, "hasRead": True,
            "hasReadAck": False, "hasDeliverAck": False, "needGroupAck": False,
            "isThread": False, "isContentReplaced": False,
            "body": {"type": 0, "content": content},
        }},
        ignore_keys={"sequence", "localTime", "serverTime", "broadcast", "onlineState",
                     "deliverOnlineOnly", "targetLanguages", "translations"},
    )
    deadline = time.monotonic() + 30
    success_msg = None
    while time.monotonic() < deadline:
        evt = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=2)
        msg = ((evt or {}).get("data") or {}).get("msg") or {}
        if str(((evt or {}).get("data") or {}).get("msgId")) == str(temp) and msg.get("msgId"):
            success_msg = msg
            break
    assert success_msg
    real_id = success_msg["msgId"]
    _assert_text_event(
        assert_api, Cmd.onMessageSuccess.value, success_msg, msg_id=real_id,
        user_a=user_a, user_b=user_b, content=content,
        direction=0, conv_id=user_b, has_read=True, has_deliver_ack=False,
    )
    received = _wait_message_list_event(device_b, Cmd.onMessagesReceived.value, msg_id=real_id)
    _assert_text_event(
        assert_api, Cmd.onMessagesReceived.value, received, msg_id=real_id,
        user_a=user_a, user_b=user_b, content=content,
        direction=1, conv_id=user_a, has_read=False, has_deliver_ack=True,
    )
    return real_id


def test_chat_report_text_message_success(device_a, device_b, assert_api, user_a, user_b):
    content = f"report-text-{uuid.uuid4().hex[:8]}"
    msg_id = _send_text(device_a, device_b, assert_api, user_a, user_b, content)
    resp = device_a.call("ChatManager", Cmd.reportMessage.value, info={"msgId": msg_id, "tag": "tag-text", "reason": "reason-text"})
    assert_api.assert_response_matches(resp, expected={"manager": "ChatManager", "cmd": Cmd.reportMessage.value, "device": "deviceA", "result": True}, ignore_keys={"sequence"})
    delivered = _wait_message_list_event(device_a, Cmd.onMessagesDelivered.value, msg_id=msg_id)
    _assert_text_event(
        assert_api, Cmd.onMessagesDelivered.value, delivered, msg_id=msg_id,
        user_a=user_a, user_b=user_b, content=content,
        direction=0, conv_id=user_b, has_read=True, has_deliver_ack=True,
    )


def test_chat_report_message_empty_message_id(device_a, assert_api):
    resp = device_a.call("ChatManager", Cmd.reportMessage.value, info={"msgId": "", "tag": "spam", "reason": "empty-id"})
    assert_api.assert_response_matches(resp, expected={"manager": "ChatManager", "cmd": Cmd.reportMessage.value, "device": "deviceA", "result": {"code": 500, "description": "message id is invalid"}}, ignore_keys={"sequence"})


def test_chat_report_message_empty_tag(device_a, assert_api):
    resp = device_a.call("ChatManager", Cmd.reportMessage.value, info={"msgId": "__invalid_report_msg__", "tag": "", "reason": "empty-tag"})
    assert_api.assert_response_matches(resp, expected={"manager": "ChatManager", "cmd": Cmd.reportMessage.value, "device": "deviceA", "result": {"code": 500, "description": "message id is invalid"}}, ignore_keys={"sequence"})


def test_chat_report_message_empty_reason(device_a, assert_api):
    resp = device_a.call("ChatManager", Cmd.reportMessage.value, info={"msgId": "__invalid_report_msg__", "tag": "spam", "reason": ""})
    assert_api.assert_response_matches(resp, expected={"manager": "ChatManager", "cmd": Cmd.reportMessage.value, "device": "deviceA", "result": {"code": 500, "description": "message id is invalid"}}, ignore_keys={"sequence"})


def test_chat_report_recalled_message(device_a, device_b, assert_api, user_a, user_b):
    content = f"report-recalled-{uuid.uuid4().hex[:8]}"
    msg_id = _send_text(device_a, device_b, assert_api, user_a, user_b, content)
    time.sleep(float(os.getenv("CHAT_RECALL_SETTLE_SECONDS", "5")))
    recall = device_a.call("ChatManager", Cmd.recallMessage.value, info={"msgId": msg_id})
    assert_api.assert_response_matches(recall, expected={"manager": "ChatManager", "cmd": Cmd.recallMessage.value, "device": "deviceA", "result": True}, ignore_keys={"sequence"})
    time.sleep(1)
    resp = device_a.call("ChatManager", Cmd.reportMessage.value, info={"msgId": msg_id, "tag": "spam", "reason": "recalled"})
    assert_api.assert_response_matches(resp, expected={"manager": "ChatManager", "cmd": Cmd.reportMessage.value, "device": "deviceA", "result": {"code": 500, "description": "message id is invalid"}}, ignore_keys={"sequence"})
