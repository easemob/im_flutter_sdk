from __future__ import annotations

import os
import time
import uuid

import pytest

from src import Cmd, gt
from tests.chat._utils import build_text
from tests.chat.test_chat_message_types_and_delivery import _send_type_and_receive
from tests.chat.test_chat_s423_message_callback_and_combine import _send_with_type

pytestmark = [pytest.mark.client, pytest.mark.chat]


def _assert_delivery_ack_boolean(message, *, source):
    assert "hasDeliverAck" in message, f"{source} 缺少 hasDeliverAck: {message}"
    assert isinstance(message["hasDeliverAck"], bool), f"{source}.hasDeliverAck 不是 bool: {message}"


def _wait_success(device, *, content, timeout=30.0):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        event = device.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=2)
        message = ((event or {}).get("data") or {}).get("msg") or {}
        if message.get("msgId") and (message.get("body") or {}).get("content") == content:
            return event, message
    pytest.fail(f"未收到文本发送成功事件: {content}")


def _assert_text_message_event(
    assert_api,
    event_type,
    message,
    *,
    msg_id,
    user_a,
    user_b,
    content,
    direction,
    conv_id,
    has_read,
    has_deliver_ack,
):
    assert_api.assert_response_matches(
        {"type": "event", "eventType": event_type, "data": {"messages": [message]}},
        expected={
            "type": "event",
            "eventType": event_type,
            "data": {
                "messages": [
                    {
                        "msgId": msg_id,
                        "from": user_a,
                        "to": user_b,
                        "convId": conv_id,
                        "chatType": 0,
                        "direction": direction,
                        "status": 2,
                        "hasRead": has_read,
                        "hasReadAck": False,
                        "hasDeliverAck": has_deliver_ack,
                        "needGroupAck": False,
                        "isThread": False,
                        "isContentReplaced": False,
                        "deliverOnlineOnly": False,
                        "body": {"type": 0, "content": content, "translations": {}},
                    }
                ],
            },
        },
        ignore_keys={"timestamp", "sequence", "localTime", "serverTime", "broadcast", "onlineState"},
    )


def _send_text(device_a, device_b, assert_api, user_a, user_b, content):
    device_a.drain_events()
    device_b.drain_events()
    response = device_a.call("ChatManager", Cmd.sendMessage.value, info=build_text(user_a, user_b, content))
    assert ((response.get("result") or {}).get("msgId")), response
    _, message = _wait_success(device_a, content=content)
    _assert_text_message_event(
        assert_api=assert_api,
        event_type=Cmd.onMessageSuccess.value,
        message=message,
        msg_id=message["msgId"],
        user_a=user_a,
        user_b=user_b,
        content=content,
        direction=0,
        conv_id=user_b,
        has_read=True,
        has_deliver_ack=False,
    )
    deadline = time.monotonic() + 30
    received_message = None
    while time.monotonic() < deadline:
        event = device_b.receive_message(match_event_type=Cmd.onMessagesReceived.value, timeout=2)
        for item in (((event or {}).get("data") or {}).get("messages") or []):
            if isinstance(item, dict) and str(item.get("msgId")) == str(message["msgId"]):
                received_message = item
                break
        if received_message:
            break
    assert received_message, f"接收端未收到待修改文本消息: msgId={message['msgId']}"
    _assert_text_message_event(
        assert_api=assert_api,
        event_type=Cmd.onMessagesReceived.value,
        message=received_message,
        msg_id=message["msgId"],
        user_a=user_a,
        user_b=user_b,
        content=content,
        direction=1,
        conv_id=user_a,
        has_read=False,
        has_deliver_ack=True,
    )
    deadline = time.monotonic() + 30
    delivered_message = None
    while time.monotonic() < deadline:
        event = device_a.receive_message(match_event_type=Cmd.onMessagesDelivered.value, timeout=2)
        for item in (((event or {}).get("data") or {}).get("messages") or []):
            if isinstance(item, dict) and str(item.get("msgId")) == str(message["msgId"]):
                delivered_message = item
                break
        if delivered_message:
            break
    assert delivered_message, f"发送端未收到待修改文本消息送达事件: msgId={message['msgId']}"
    _assert_text_message_event(
        assert_api=assert_api,
        event_type=Cmd.onMessagesDelivered.value,
        message=delivered_message,
        msg_id=message["msgId"],
        user_a=user_a,
        user_b=user_b,
        content=content,
        direction=0,
        conv_id=user_b,
        has_read=True,
        has_deliver_ack=True,
    )
    return message


def _wait_changed(device, *, msg_id, timeout=30.0):
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        event = device.receive_message(match_event_type=Cmd.onMessageContentChanged.value, timeout=2)
        if event:
            seen.append(event)
        message = ((event or {}).get("data") or {}).get("message") or {}
        if str(message.get("msgId")) == str(msg_id):
            return event
    pytest.fail(f"未收到消息修改事件: msgId={msg_id}, seen={seen}")


@pytest.mark.parametrize("mode", ["body", "attributes", "body-and-attributes"])
def test_chat_modify_text_body_and_attributes(device_a, device_b, assert_api, user_a, user_b, mode):
    old_content = f"modify-text-old-{uuid.uuid4().hex[:6]}"
    message = _send_text(device_a, device_b, assert_api, user_a, user_b, old_content)
    time.sleep(float(os.getenv("CHAT_MODIFY_SETTLE_SECONDS", "5")))
    new_content = f"modify-text-new-{uuid.uuid4().hex[:6]}"
    attributes = {"editMode": mode, "revision": "1"}
    info = {"msgId": message["msgId"]}
    if mode != "attributes":
        info["msgBody"] = {"type": 0, "content": new_content}
    if mode != "body":
        info["attributes"] = attributes
    response = device_a.call("ChatManager", Cmd.modifyMessage.value, info=info)
    expected_content = old_content if mode == "attributes" else new_content
    expected_result = {
        "msgId": message["msgId"], "from": user_a, "to": user_b, "convId": user_b,
        "chatType": 0, "direction": 0, "status": 2, "hasRead": True,
        "hasReadAck": False, "hasDeliverAck": True, "needGroupAck": False,
        "isThread": False, "isContentReplaced": False,
        "body": {"type": 0, "content": expected_content, "operatorId": user_a,
                 "operatorTime": gt(0), "operatorCount": gt(0)},
    }
    if mode != "body":
        expected_result["attributes"] = attributes
    assert_api.assert_response_matches(
        response,
        expected={"manager": "ChatManager", "cmd": Cmd.modifyMessage.value,
                  "device": "deviceA", "result": expected_result},
        ignore_keys={"sequence", "localTime", "serverTime", "broadcast", "onlineState",
                     "deliverOnlineOnly", "targetLanguages", "translations"},
    )
    event = _wait_changed(device_b, msg_id=message["msgId"])
    expected_received = {
        "msgId": message["msgId"], "from": user_a, "to": user_b, "convId": user_a,
        "chatType": 0, "direction": 1, "status": 2, "hasRead": False,
        "hasReadAck": False, "hasDeliverAck": True, "needGroupAck": False,
        "isThread": False, "isContentReplaced": False,
        "body": {"type": 0, "content": expected_content},
    }
    if mode != "body":
        expected_received["attributes"] = attributes
    assert_api.assert_response_matches(
        event,
        expected={"type": "event", "eventType": Cmd.onMessageContentChanged.value,
                  "data": {"message": expected_received, "operatorId": user_a, "operationTime": gt(0)}},
        ignore_keys={"timestamp", "sequence", "localTime", "serverTime", "broadcast", "onlineState",
                     "deliverOnlineOnly", "targetLanguages", "translations", "receiverList"},
    )


def test_chat_modify_message_empty_id(device_a, assert_api):
    response = device_a.call(
        "ChatManager", Cmd.modifyMessage.value,
        info={"msgId": "", "msgBody": {"type": 0, "content": "empty-id"}},
    )
    assert_api.assert_response_matches(
        response,
        expected={"manager": "ChatManager", "cmd": Cmd.modifyMessage.value,
                  "device": "deviceA", "result": {"code": 1, "description": "messageId is empty"}},
        ignore_keys={"sequence"},
    )


def test_chat_non_sender_cannot_modify_message(device_a, device_b, assert_api, user_a, user_b):
    message = _send_text(device_a, device_b, assert_api, user_a, user_b, f"modify-other-{uuid.uuid4().hex[:6]}")
    response = device_b.call(
        "ChatManager", Cmd.modifyMessage.value,
        info={"msgId": message["msgId"], "msgBody": {"type": 0, "content": "not-owner"}},
    )
    assert_api.assert_response_matches(
        response,
        expected={"manager": "ChatManager", "cmd": Cmd.modifyMessage.value, "device": "deviceB",
                  "result": {"code": 210, "description": "User has no permission for this operation"}},
        ignore_keys={"sequence"},
    )


def test_chat_modify_cmd_message_is_rejected(device_a, device_b, assert_api, user_a, user_b):
    device_a.drain_events()
    device_b.drain_events()
    action = f"modify-cmd-{uuid.uuid4().hex[:6]}"
    response = device_a.call(
        "ChatManager", Cmd.sendMessageWithType.value,
        info={"type": "cmd", "payload": {"targetId": user_b, "action": action,
        "deliverOnlineOnly": False}, "chatType": 0},
    )
    assert ((response.get("result") or {}).get("msgId")), response
    deadline = time.monotonic() + 30
    message = None
    while time.monotonic() < deadline:
        event = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=2)
        candidate = ((event or {}).get("data") or {}).get("msg") or {}
        if candidate.get("msgId") and (candidate.get("body") or {}).get("action") == action:
            message = candidate
            break
    assert message, "未收到 CMD 发送成功事件"
    modify = device_a.call(
        "ChatManager", Cmd.modifyMessage.value,
        info={"msgId": message["msgId"], "attributes": {"cmdEdit": True}},
    )
    assert_api.assert_response_matches(
        modify,
        expected={"manager": "ChatManager", "cmd": Cmd.modifyMessage.value,
                  "device": "deviceA", "result": {"code": 500,
                  "description": "Message is invalid"}},
        ignore_keys={"sequence"},
    )


def _send_media(device_a, device_b, assert_api, user_a, user_b, type_key):
    if type_key == "voice":
        _, success, _, _, _ = _send_type_and_receive(
            device_a, device_b, assert_api, user_a, user_b,
            type_key="voice", payload={"targetId": user_b, "duration": 1},
        )
        return ((success.get("data") or {}).get("msg") or {})
    _, sent, _ = _send_with_type(
        device_a, device_b, assert_api, user_a, user_b,
        type_key=type_key, payload={"targetId": user_b},
    )
    return sent


@pytest.mark.parametrize("type_key", ["voice", "image", "video"])
def test_chat_modify_media_attributes(device_a, device_b, assert_api, user_a, user_b, type_key):
    message = _send_media(device_a, device_b, assert_api, user_a, user_b, type_key)
    time.sleep(float(os.getenv("CHAT_MODIFY_SETTLE_SECONDS", "5")))
    attributes = {"mediaEdit": type_key, "revision": "1"}
    response = device_a.call(
        "ChatManager", Cmd.modifyMessage.value,
        info={"msgId": message["msgId"], "attributes": attributes},
    )
    _assert_delivery_ack_boolean(response.get("result") or {}, source=f"modifyMessage({type_key}).result")
    assert_api.assert_response_matches(
        response,
        expected={"manager": "ChatManager", "cmd": Cmd.modifyMessage.value,
                  "device": "deviceA", "result": {"msgId": message["msgId"],
                  "from": user_a, "to": user_b, "convId": user_b, "chatType": 0,
                  "direction": 0, "status": 2, "hasRead": True, "hasReadAck": False,
                  "needGroupAck": False, "isThread": False,
                  "isContentReplaced": False, "attributes": attributes,
                  "body": {"type": (message.get("body") or {}).get("type"),
                           "operatorId": user_a, "operatorTime": gt(0), "operatorCount": gt(0)}}},
        ignore_keys={"sequence", "localTime", "serverTime", "broadcast", "onlineState", "deliverOnlineOnly",
                     "localPath", "remotePath", "secret", "fileSize", "displayName", "fileStatus",
                     "thumbnailLocalPath", "thumbnailRemotePath", "thumbnailSecret", "thumbnailStatus",
                     "width", "height", "duration", "isGif", "sendOriginalImage", "hasDeliverAck"},
    )
    event = _wait_changed(device_b, msg_id=message["msgId"])
    changed = ((event.get("data") or {}).get("message") or {})
    assert_api.assert_response_matches(
        event,
        expected={"type": "event", "eventType": Cmd.onMessageContentChanged.value, "data": {
            "message": {"msgId": message["msgId"], "from": user_a, "to": user_b,
                        "convId": user_a, "chatType": 0, "direction": 1, "status": 2,
                        "hasRead": False, "hasReadAck": False, "hasDeliverAck": True,
                        "needGroupAck": False, "isThread": False, "isContentReplaced": False,
                        "attributes": attributes,
                        "body": {"type": (message.get("body") or {}).get("type")}},
            "operatorId": user_a, "operationTime": gt(0),
        }},
        ignore_keys={"timestamp", "sequence", "localTime", "serverTime", "broadcast", "onlineState",
                     "deliverOnlineOnly", "localPath", "remotePath", "secret", "fileSize", "displayName",
                     "fileStatus", "thumbnailLocalPath", "thumbnailRemotePath", "thumbnailSecret",
                     "thumbnailStatus", "width", "height", "duration", "isGif", "sendOriginalImage",
                     "receiverList"},
    )


@pytest.mark.parametrize("type_key", ["voice", "image", "video"])
def test_chat_modify_media_body_is_rejected(device_a, device_b, assert_api, user_a, user_b, type_key):
    message = _send_media(device_a, device_b, assert_api, user_a, user_b, type_key)
    response = device_a.call(
        "ChatManager", Cmd.modifyMessage.value,
        info={"msgId": message["msgId"], "msgBody": message["body"]},
    )
    assert_api.assert_response_matches(
        response,
        expected={"manager": "ChatManager", "cmd": Cmd.modifyMessage.value, "device": "deviceA",
                  "result": {"code": 111, "description": "Unsupported operation"}},
        ignore_keys={"sequence"},
    )
