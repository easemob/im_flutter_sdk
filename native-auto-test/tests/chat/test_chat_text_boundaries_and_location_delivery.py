from __future__ import annotations

import time
import uuid

import pytest

from src import Cmd
from tests.chat._utils import build_text
from tests.chat.test_chat_message_types_and_delivery import _send_type_and_receive, _wait_delivery_event

pytestmark = [pytest.mark.client, pytest.mark.chat]


def _wait_text_event(device, event_type, *, content, timeout=30.0):
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        event = device.receive_message(match_event_type=event_type, timeout=2.0)
        if event:
            seen.append(event)
        messages = ((event or {}).get("data") or {}).get("messages") or []
        if event_type == Cmd.onMessageSuccess.value:
            message = ((event or {}).get("data") or {}).get("msg") or {}
            if (message.get("body") or {}).get("content") == content:
                return event, message
        else:
            for message in messages:
                if isinstance(message, dict) and (message.get("body") or {}).get("content") == content:
                    return event, message
    pytest.fail(f"未收到目标文本事件: eventType={event_type}, content={content!r}, seen={seen}")


def _send_text_and_assert(device_a, device_b, assert_api, user_a, user_b, *, content, from_user=None):
    device_a.drain_events()
    device_b.drain_events()
    info = build_text(from_user if from_user is not None else user_a, user_b, content)
    response = device_a.call("ChatManager", Cmd.sendMessage.value, info=info)
    temp_id = ((response.get("result") or {}).get("msgId"))
    assert temp_id, response
    success_event, sent = _wait_text_event(device_a, Cmd.onMessageSuccess.value, content=content)
    received_event, received = _wait_text_event(device_b, Cmd.onMessagesReceived.value, content=content)
    real_id = sent.get("msgId")
    expected_body = {"type": 0, "content": content}
    assert_api.assert_response_matches(
        response,
        expected={"manager": "ChatManager", "cmd": Cmd.sendMessage.value, "device": "deviceA", "result": {
            "msgId": temp_id, "from": user_a, "to": user_b, "convId": user_b,
            "chatType": 0, "direction": 0, "status": 0, "hasRead": True,
            "hasReadAck": False, "hasDeliverAck": False, "needGroupAck": False,
            "isThread": False, "isContentReplaced": False, "body": expected_body,
        }},
        ignore_keys={"sequence", "localTime", "serverTime", "broadcast", "onlineState", "deliverOnlineOnly", "targetLanguages", "translations"},
    )
    for event, message, direction, conv_id, has_read, has_delivery in (
        (success_event, sent, 0, user_b, True, False),
        (received_event, received, 1, user_a, False, True),
    ):
        assert_api.assert_response_matches(
            {"type": "event", "eventType": event.get("eventType"), "data": {"messages": [message]}},
            expected={"type": "event", "eventType": event.get("eventType"), "data": {"messages": [{
                "msgId": real_id, "from": user_a, "to": user_b, "convId": conv_id,
                "chatType": 0, "direction": direction, "status": 2,
                "hasRead": has_read, "hasReadAck": False, "hasDeliverAck": has_delivery,
                "needGroupAck": False, "isThread": False, "isContentReplaced": False,
                "deliverOnlineOnly": False, "body": expected_body,
            }]}},
            ignore_keys={"timestamp", "sequence", "localTime", "serverTime", "broadcast", "onlineState", "targetLanguages", "translations"},
        )
    delivery = _wait_delivery_event(device_a, real_id=real_id)
    assert_api.assert_response_matches(
        delivery,
        expected={"type": "event", "eventType": delivery.get("eventType"), "data": {"messages": [{
            "msgId": real_id, "from": user_a, "to": user_b, "convId": user_b,
            "chatType": 0, "direction": 0, "status": 2, "hasRead": True,
            "hasReadAck": False, "hasDeliverAck": True, "needGroupAck": False,
            "isThread": False, "isContentReplaced": False, "deliverOnlineOnly": False,
            "body": expected_body,
        }]}},
        ignore_keys={"timestamp", "sequence", "localTime", "serverTime", "targetLanguages", "translations"},
    )
    return real_id


@pytest.mark.parametrize(
    "content",
    [
        "",
        "special-中文-!@#$%^&*()_+-=[]{}|;:',.<>/?\\\n\t-🙂",
        "x" * 250,
    ],
    ids=["empty", "special-characters", "length-250"],
)
def test_chat_text_content_boundaries(device_a, device_b, assert_api, user_a, user_b, content):
    _send_text_and_assert(device_a, device_b, assert_api, user_a, user_b, content=content)


def test_chat_send_rejects_mismatched_from(device_a, device_b, assert_api, user_a, user_b):
    content = f"mismatched-from-{uuid.uuid4().hex[:8]}"
    invalid_from = "__not_logged_in_sender__"
    device_a.drain_events()
    response = device_a.call(
        "ChatManager", Cmd.sendMessage.value,
        info=build_text(invalid_from, user_b, content),
    )
    temp_id = ((response.get("result") or {}).get("msgId"))
    assert temp_id, response
    assert_api.assert_response_matches(
        response,
        expected={"manager": "ChatManager", "cmd": Cmd.sendMessage.value, "device": "deviceA", "result": {
            "msgId": temp_id, "from": invalid_from, "to": user_b, "convId": user_b,
            "chatType": 0, "direction": 0, "status": 0, "hasRead": True,
            "hasReadAck": False, "hasDeliverAck": False, "needGroupAck": False,
            "isThread": False, "isContentReplaced": False,
            "body": {"type": 0, "content": content},
        }},
        ignore_keys={"sequence", "localTime", "serverTime", "broadcast", "onlineState", "deliverOnlineOnly", "targetLanguages", "translations"},
    )
    event = device_a.receive_message(match_event_type=Cmd.onMessageError.value, timeout=20)
    assert_api.assert_response_matches(
        event,
        expected={"type": "event", "eventType": Cmd.onMessageError.value, "data": {
            "msgId": temp_id,
            "msg": {"msgId": temp_id, "from": invalid_from, "to": user_b, "convId": user_b,
                    "chatType": 0, "direction": 0, "status": 0, "hasRead": True,
                    "hasReadAck": False, "hasDeliverAck": False, "needGroupAck": False,
                    "isThread": False, "isContentReplaced": False, "deliverOnlineOnly": False,
                    "body": {"type": 0, "content": content, "translations": {}}},
            "error": {"code": 500, "description": "Message is invalid"},
        }},
        ignore_keys={"timestamp", "sequence", "localTime", "serverTime"},
    )


def test_chat_location_message_delivery_ack(device_a, device_b, assert_api, user_a, user_b):
    payload = {
        "targetId": user_b, "latitude": 30.2741, "longitude": 120.1551,
        "address": "location-delivery", "buildingName": "location-delivery-building",
    }
    _, _, _, _, real_id = _send_type_and_receive(
        device_a, device_b, assert_api, user_a, user_b, type_key="location", payload=payload,
    )
    event = _wait_delivery_event(device_a, real_id=real_id)
    assert_api.assert_response_matches(
        event,
        expected={"type": "event", "eventType": event.get("eventType"), "data": {"messages": [{
            "msgId": real_id, "from": user_a, "to": user_b, "convId": user_b,
            "chatType": 0, "direction": 0, "status": 2, "hasRead": True,
            "hasReadAck": False, "hasDeliverAck": True, "needGroupAck": False,
            "isThread": False, "isContentReplaced": False, "deliverOnlineOnly": False,
            "body": {"type": 3, "latitude": payload["latitude"], "longitude": payload["longitude"],
                     "address": payload["address"], "buildingName": payload["buildingName"]},
        }]}},
        ignore_keys={"timestamp", "sequence", "localTime", "serverTime"},
    )
