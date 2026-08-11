from __future__ import annotations

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
            "hasRead": has_read, "needReadReceipt": False, "isThread": False, "isContentReplaced": False,
            "deliverOnlineOnly": False,
            "body": {"type": 0, "content": content, "translations": {}},
        }]}},
        ignore_keys={"timestamp", "sequence", "localTime", "serverTime", "broadcast", "onlineState",
                     "targetLanguages"},
    )


def _send_text_message(device_a, device_b, assert_api, user_a, user_b, content):
    device_a.drain_events()
    device_b.drain_events()
    response = device_a.call("ChatManager", Cmd.sendMessage.value, info=build_text(user_a, user_b, content))
    temp_id = ((response.get("result") or {}).get("msgId"))
    assert temp_id, response
    assert_api.assert_response_matches(
        response,
        expected={"manager": "ChatManager", "cmd": Cmd.sendMessage.value, "device": "deviceA", "result": {
            "msgId": temp_id, "from": user_a, "to": user_b, "convId": user_b,
            "chatType": 0, "direction": 0, "status": 0, "hasRead": True,
            "needReadReceipt": False, "isThread": False, "isContentReplaced": False,
            "body": {"type": 0, "content": content},
        }},
        ignore_keys={"sequence", "localTime", "serverTime", "broadcast", "onlineState",
                     "deliverOnlineOnly", "targetLanguages", "translations"},
    )
    deadline = time.monotonic() + 30
    while time.monotonic() < deadline:
        event = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=2)
        message = ((event or {}).get("data") or {}).get("msg") or {}
        if message.get("msgId") and (message.get("body") or {}).get("content") == content:
            _assert_text_event(
                assert_api, Cmd.onMessageSuccess.value, message, msg_id=message["msgId"],
                user_a=user_a, user_b=user_b, content=content,
                direction=0, conv_id=user_b, has_read=True, has_deliver_ack=None,
            )
            return message
    pytest.fail(f"未收到文本发送成功事件: {content}")



def test_chat_download_thumbnail_for_text_message(device_a, device_b, assert_api, user_a, user_b):
    content = f"thumbnail-text-{uuid.uuid4().hex[:8]}"
    message = _send_text_message(device_a, device_b, assert_api, user_a, user_b, content)
    response = device_a.call("ChatManager", Cmd.downloadThumbnail.value, info={"message": message})
    assert_api.assert_response_matches(
        response,
        expected={"manager": "ChatManager", "cmd": Cmd.downloadThumbnail.value, "device": "deviceA", "result": {
            "msgId": message["msgId"], "from": user_a, "to": user_b, "convId": user_b,
            "chatType": 0, "direction": 0, "status": 2, "hasRead": True,
            "needReadReceipt": False, "isThread": False, "isContentReplaced": False,
            "body": {"type": 0, "content": content, "targetLanguages": [], "translations": {}},
        }},
        ignore_keys={"sequence", "localTime", "serverTime", "broadcast", "onlineState", "deliverOnlineOnly"},
    )
    event = device_a.receive_message(match_event_type=Cmd.onMessageError.value, timeout=20)
    assert_api.assert_response_matches(
        event,
        expected={"type": "event", "eventType": Cmd.onMessageError.value, "data": {
            "msgId": message["msgId"],
            "msg": {"msgId": message["msgId"], "from": user_a, "to": user_b, "convId": user_b,
                    "chatType": 0, "direction": 0, "status": 2, "hasRead": True,
                    "needReadReceipt": False, "isThread": False, "isContentReplaced": False, "deliverOnlineOnly": False,
                    "body": {"type": 0, "content": content, "translations": {}}},
            "error": {"code": 403, "description": "Failed to download the file"},
        }},
        ignore_keys={"timestamp", "sequence", "localTime", "serverTime"},
    )
    received = _wait_message_list_event(device_b, Cmd.onMessagesReceived.value, msg_id=message["msgId"])
    _assert_text_event(
        assert_api, Cmd.onMessagesReceived.value, received, msg_id=message["msgId"],
        user_a=user_a, user_b=user_b, content=content,
        direction=1, conv_id=user_a, has_read=False, has_deliver_ack=None,
    )
