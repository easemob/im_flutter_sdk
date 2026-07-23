from __future__ import annotations

import time
import uuid

import pytest

from src import Cmd
from tests.chat.test_chat_recall_and_message_read_ack import _send_typed

pytestmark = [pytest.mark.client, pytest.mark.chat]


def _wait_pin_event(device, *, msg_id, operation, timeout=30.0):
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        event = device.receive_message(match_event_type=Cmd.onMessagePinChanged.value, timeout=2)
        if event:
            seen.append(event)
        data = (event or {}).get("data") or {}
        if str(data.get("messageId")) == str(msg_id) and data.get("pinOperation") == operation:
            return event
    pytest.fail(f"未收到消息置顶事件: msgId={msg_id}, operation={operation}, seen={seen}")


def _assert_no_pin_event(device, *, msg_id, operation, timeout=3.0):
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        event = device.receive_message(
            match_event_type=Cmd.onMessagePinChanged.value,
            timeout=min(1.0, max(0.1, deadline - time.monotonic())),
        )
        if event:
            seen.append(event)
        data = (event or {}).get("data") or {}
        if str(data.get("messageId")) == str(msg_id) and data.get("pinOperation") == operation:
            pytest.fail(f"操作者端不应收到消息置顶事件: msgId={msg_id}, operation={operation}, seen={seen}")


def _assert_pin_event(assert_api, event, *, msg_id, conversation_id, operation, operator_id):
    assert_api.assert_response_matches(
        event,
        expected={
            "type": "event",
            "eventType": Cmd.onMessagePinChanged.value,
            "data": {
                "messageId": msg_id,
                "conversationId": conversation_id,
                "pinOperation": operation,
                "pinInfo": {"operatorId": operator_id},
            },
        },
        ignore_keys={"timestamp", "sequence", "pinTime"},
    )


def _assert_pin_delivery_for_actor(
    assert_api,
    *,
    device_a,
    device_b,
    msg_id,
    operation,
    operator_id,
    user_a,
    user_b,
):
    if operator_id == user_a:
        event = _wait_pin_event(device_b, msg_id=msg_id, operation=operation)
        _assert_pin_event(
            assert_api,
            event,
            msg_id=msg_id,
            conversation_id=user_a,
            operation=operation,
            operator_id=operator_id,
        )
        _assert_no_pin_event(device_a, msg_id=msg_id, operation=operation)
        return

    _assert_no_pin_event(device_a, msg_id=msg_id, operation=operation)
    _assert_no_pin_event(device_b, msg_id=msg_id, operation=operation)


@pytest.mark.parametrize(
    ("type_key", "payload"),
    [
        ("location", {"latitude": 30.2741, "longitude": 120.1551, "address": "pin-location", "buildingName": "pin-building"}),
        ("custom", {"event": "pin-custom", "params": {"case": "typed-pin"}}),
    ],
)
@pytest.mark.parametrize("pin_actor", ["sender", "receiver"])
def test_chat_typed_message_pin_and_cross_user_unpin(
    device_a, device_b, assert_api, user_a, user_b, type_key, payload, pin_actor,
):
    payload = dict(payload)
    if type_key == "custom":
        payload["event"] = f"pin-custom-{uuid.uuid4().hex[:6]}"
    _, _, _, real_id = _send_typed(
        device_a, device_b, assert_api, user_a, user_b, type_key, payload,
    )
    if pin_actor == "sender":
        pin_device, pin_name, pin_user = device_a, "deviceA", user_a
        unpin_device, unpin_name = device_b, "deviceB"
    else:
        pin_device, pin_name, pin_user = device_b, "deviceB", user_b
        unpin_device, unpin_name = device_a, "deviceA"

    pin_response = pin_device.call("ChatManager", Cmd.pinMessage.value, info={"msgId": real_id})
    assert_api.assert_response_matches(
        pin_response,
        expected={"manager": "ChatManager", "cmd": Cmd.pinMessage.value, "device": pin_name, "result": None},
        ignore_keys={"sequence"},
    )
    _assert_pin_delivery_for_actor(
        assert_api,
        device_a=device_a,
        device_b=device_b,
        msg_id=real_id,
        operation="MessagePinOperation.Pin",
        operator_id=pin_user,
        user_a=user_a,
        user_b=user_b,
    )

    time.sleep(2)
    fetch_response = pin_device.call(
        "ChatManager", Cmd.fetchPinnedMessages.value,
        info={"convId": user_b if pin_actor == "sender" else user_a},
    )
    result = fetch_response.get("result") or []
    target = next((message for message in result if str(message.get("msgId")) == str(real_id)), None)
    assert target, fetch_response
    expected_body = (
        {"type": 3, "latitude": payload["latitude"], "longitude": payload["longitude"],
         "address": payload["address"], "buildingName": payload["buildingName"]}
        if type_key == "location"
        else {"type": 7, "event": payload["event"], "params": payload["params"]}
    )
    if pin_actor == "sender":
        direction, has_read, has_delivery, conv_id = 0, True, True, user_b
    else:
        direction, has_read, has_delivery, conv_id = 1, False, True, user_a
    assert_api.assert_response_matches(
        target,
        expected={"msgId": real_id, "from": user_a, "to": user_b,
                  "convId": conv_id, "chatType": 0, "direction": direction, "status": 2,
                  "hasRead": has_read, "hasReadAck": False, "hasDeliverAck": has_delivery,
                  "needGroupAck": False, "isThread": False, "isContentReplaced": False,
                  "broadcast": False, "onlineState": True, "body": expected_body},
        ignore_keys={"localTime", "serverTime", "deliverOnlineOnly", "receiverList"},
    )

    unpin_response = unpin_device.call("ChatManager", Cmd.unpinMessage.value, info={"msgId": real_id})
    assert_api.assert_response_matches(
        unpin_response,
        expected={"manager": "ChatManager", "cmd": Cmd.unpinMessage.value, "device": unpin_name, "result": None},
        ignore_keys={"sequence"},
    )
    unpin_user = user_b if pin_actor == "sender" else user_a
    _assert_pin_delivery_for_actor(
        assert_api,
        device_a=device_a,
        device_b=device_b,
        msg_id=real_id,
        operation="MessagePinOperation.Unpin",
        operator_id=unpin_user,
        user_a=user_a,
        user_b=user_b,
    )
    time.sleep(2)
    fetch_empty = unpin_device.call(
        "ChatManager", Cmd.fetchPinnedMessages.value,
        info={"convId": user_a if pin_actor == "sender" else user_b},
    )
    remaining_target_ids = [
        str(message.get("msgId"))
        for message in (fetch_empty.get("result") or [])
        if isinstance(message, dict) and str(message.get("msgId")) == str(real_id)
    ]
    assert_api.assert_response_matches(
        {"manager": fetch_empty.get("manager"), "cmd": fetch_empty.get("cmd"),
         "device": fetch_empty.get("device"), "result": {"targetMsgIds": remaining_target_ids}},
        expected={"manager": "ChatManager", "cmd": Cmd.fetchPinnedMessages.value,
                  "device": unpin_name, "result": {"targetMsgIds": []}},
        ignore_keys={"sequence"},
    )
