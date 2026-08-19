from __future__ import annotations

import os
import time
import uuid
from contextlib import nullcontext

import pytest

from src import Cmd, gt
from tests.chat._utils import build_text


def _allure_step(name: str):
    try:
        import allure

        return allure.step(name)
    except ImportError:
        return nullcontext()
from tests.chat.test_chat_message_types_and_delivery import _send_type_and_receive
from tests.chat.test_chat_message_callback_and_combine import _send_with_type

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
                        "needReadReceipt": False, 
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
        has_deliver_ack=None,
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
        has_deliver_ack=None,
    )
    return message


def _wait_received(device, msg_id: str, *, from_user: str, to_user: str, content=None, timeout: float = 30.0):
    """等待接收端收到指定 msgId 的消息并返回消息对象。"""
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        event = device.receive_message(match_event_type=Cmd.onMessagesReceived.value, timeout=2)
        for item in (((event or {}).get("data") or {}).get("messages") or []):
            if isinstance(item, dict) and str(item.get("msgId")) == str(msg_id):
                return item
    raise AssertionError(f"接收端未收到消息: msgId={msg_id}, device={device.device_name}")
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


@pytest.mark.topology("account_a_to_account_b")
def test_chat_non_sender_cannot_modify_message(topology, assert_api):
    """非发送者（接收账号端）尝试修改消息被拒绝（无权限）；发送投递到接收账号全部在线端。"""
    sender = topology.sender_action_device
    recipients = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    with _allure_step(f"{sender.device_name} 发送待修改文本消息"):
        message = _send_text(sender, recipients[0], assert_api, user_a, user_b, f"modify-other-{uuid.uuid4().hex[:6]}")
    for extra_recipient in recipients[1:]:
        with _allure_step(f"接收账号端 {extra_recipient.device_name} 接收该消息"):
            _wait_received(extra_recipient, message["msgId"], from_user=user_a, to_user=user_b, content=None)
    with _allure_step(f"非发送者 {recipients[0].device_name} 尝试修改消息（应无权限）"):
        response = recipients[0].call(
            "ChatManager", Cmd.modifyMessage.value,
            info={"msgId": message["msgId"], "msgBody": {"type": 0, "content": "not-owner"}},
        )
    assert_api.assert_response_matches(
        response,
        expected={"manager": "ChatManager", "cmd": Cmd.modifyMessage.value, "device": recipients[0].device_name,
                  "result": {"code": 210, "description": "User has no permission for this operation"}},
        ignore_keys={"sequence"},
    )


def test_chat_modify_cmd_message_is_rejected(device_a, device_b, assert_api, user_a, user_b):
    with _allure_step("验证：chat modify cmd message is rejected"):
        device_a.drain_events()
        device_b.drain_events()
        action = f"modify-cmd-{uuid.uuid4().hex[:6]}"
        response = device_a.call(
            "ChatManager", Cmd.sendMessage.value,
            info={"to": user_b, "chatType": 0, "direction": 0,
                  "body": {"type": 6, "action": action, "deliverOnlineOnly": False}},
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


def _send_media(topology, assert_api, type_key):
    if type_key == "voice":
        _, success, _, _, _ = _send_type_and_receive(
            topology.sender_action_device, topology.recipient_action_device,
            assert_api, topology.sender_user, topology.recipient_user,
            type_key="voice", payload={"targetId": topology.recipient_user, "duration": 1},
        )
        return ((success.get("data") or {}).get("msg") or {})
    _, sent, _ = _send_with_type(
        topology, assert_api,
        type_key=type_key, payload={"targetId": topology.recipient_user},
    )
    return sent


@pytest.mark.parametrize("type_key", ["voice", "image", "video"])
@pytest.mark.topology("account_a_to_account_b")
def test_chat_modify_media_attributes(topology, assert_api, type_key):
    with _allure_step("验证：chat modify media attributes"):
        message = _send_media(topology, assert_api, type_key)
        device_a = topology.sender_action_device
        user_a = topology.sender_user
        user_b = topology.recipient_user

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
                      "device": device_a.device_name, "result": {"msgId": message["msgId"],
                      "from": user_a, "to": user_b, "convId": user_b, "chatType": 0,
                      "direction": 0, "status": 2, "hasRead": True, "needReadReceipt": False,  "isThread": False,
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
                            "hasRead": False, "needReadReceipt": False, "isThread": False, "isContentReplaced": False,
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
@pytest.mark.topology("account_a_to_account_b")
def test_chat_modify_media_body_is_rejected(topology, assert_api, type_key):
    with _allure_step("验证：chat modify media body is rejected"):
        message = _send_media(topology, assert_api, type_key)
        device_a = topology.sender_action_device
        user_a = topology.sender_user
        user_b = topology.recipient_user

        response = device_a.call(
            "ChatManager", Cmd.modifyMessage.value,
            info={"msgId": message["msgId"], "msgBody": message["body"]},
        )
        assert_api.assert_response_matches(
            response,
            expected={"manager": "ChatManager", "cmd": Cmd.modifyMessage.value, "device": device_a.device_name,
                      "result": {"code": 111, "description": "Unsupported operation"}},
            ignore_keys={"sequence"},
        )


def _wait_changed(device, *, msg_id, timeout=30.0):
    """等待消息修改事件（onMessageContentChanged）。"""
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
    """官方结构移植：modifyMessage 修改正文/属性/两者。当前环境实测 305（edit not available，待研发）。"""
    with _allure_step("验证：官方结构移植：modifyMessage 修改正文/属性/两者。当前环境实测 305（edit not available，待研发）。"):
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
            # 5.0：hasReadAck/needGroupAck 无；未设 flag → hasDeliverAck 恒 False
            "hasDeliverAck": False, "needReadReceipt": False, "isPeerRead": False,
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
            "hasDeliverAck": False, "needReadReceipt": False, "isPeerRead": False,
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
    """官方结构移植：modifyMessage 空 msgId → 错误。"""
    with _allure_step("验证：官方结构移植：modifyMessage 空 msgId → 错误。"):
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
