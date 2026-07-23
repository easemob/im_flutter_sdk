from __future__ import annotations

import os
import time
import uuid

import pytest

from src import Cmd
from tests.chat._utils import build_text
from tests.chat.test_chat_recall_and_message_read_ack import _send_typed

pytestmark = [pytest.mark.client, pytest.mark.chat]


def _assert_text_event(assert_api, evt, *, event_type, msg_id, user_a, user_b, content, direction, conv_id, has_read, has_deliver_ack):
    assert_api.assert_response_matches(
        evt,
        expected={
            "type": "event",
            "eventType": event_type,
            "data": {
                "messages": [
                    {
                        "msgId": str(msg_id),
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
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "receiverList", "broadcast", "onlineState"},
    )


def _wait_text_event(device, event_type, *, msg_id, content, timeout=30):
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        evt = device.receive_message(match_event_type=event_type, timeout=min(2.0, max(0.1, deadline - time.monotonic())))
        if evt:
            seen.append(evt)
        for msg in ((evt or {}).get("data") or {}).get("messages") or []:
            if not isinstance(msg, dict):
                continue
            if str(msg.get("msgId")) == str(msg_id) and ((msg.get("body") or {}).get("content") == content):
                return {
                    "type": evt.get("type"),
                    "eventType": evt.get("eventType"),
                    "data": {"messages": [msg]},
                    "timestamp": evt.get("timestamp"),
                }
    raise AssertionError(f"未收到目标消息事件: event={event_type}, msgId={msg_id}, content={content}, events={seen}")


def _send_text(device_a, device_b, assert_api, user_a, user_b, content):
    device_a.drain_events()
    device_b.drain_events()
    resp = device_a.call(
        "ChatManager", Cmd.sendMessage.value,
        info=build_text(user_a, user_b, content),
    )
    temp_id = ((resp.get("result") or {}).get("msgId"))
    assert temp_id, f"sendMessage 未返回临时 msgId: response={resp}"
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.sendMessage.value,
            "device": "deviceA",
            "result": {
                "msgId": str(temp_id),
                "from": user_a,
                "to": user_b,
                "convId": user_b,
                "chatType": 0,
                "direction": 0,
                "status": 0,
                "hasRead": True,
                "hasReadAck": False,
                "hasDeliverAck": False,
                "needGroupAck": False,
                "isThread": False,
                "isContentReplaced": False,
                "body": {"type": 0, "content": content},
            },
        },
        ignore_keys={"sequence", "serverTime", "localTime", "broadcast", "onlineState", "deliverOnlineOnly", "targetLanguages", "translations"},
    )

    success = None
    # 服务端已确认发送成功后，接收端回调仍可能因最终一致性/重连延迟晚到。
    # 只有收到目标消息后才允许进入撤回步骤，避免撤回早于接收导致误判。
    deadline = time.monotonic() + 60
    while time.monotonic() < deadline:
        evt = device_a.receive_message(
            match_event_type=Cmd.onMessageSuccess.value,
            timeout=min(1.0, max(0.1, deadline - time.monotonic())),
        )
        data = (evt or {}).get("data") or {}
        msg = data.get("msg") or {}
        if (
            str(data.get("msgId")) == str(temp_id)
            and msg.get("msgId")
            and msg.get("to") == user_b
            and (msg.get("body") or {}).get("content") == content
        ):
            success = evt
            break

        error_evt = device_a.receive_message(
            match_event_type=Cmd.onMessageError.value,
            timeout=min(1.0, max(0.1, deadline - time.monotonic())),
        )
        error_data = (error_evt or {}).get("data") or {}
        if str(error_data.get("msgId")) != str(temp_id):
            continue
        error = error_data.get("error") or {}
        raise AssertionError(
            "发送撤回前置消息失败: "
            f"content={content}, tempId={temp_id}, "
            f"code={error.get('code')}, description={error.get('description')}, "
            f"event={error_evt}"
        )

    assert success, (
        f"发送终态超时: content={content}, tempId={temp_id}; "
        "未收到匹配的 onMessageSuccess/onMessageError"
    )
    real_id = (((success.get("data") or {}).get("msg")) or {}).get("msgId")
    assert_api.assert_response_matches(
        success,
        expected={
            "type": "event",
            "eventType": Cmd.onMessageSuccess.value,
            "data": {
                "msgId": str(temp_id),
                "msg": {
                    "msgId": str(real_id),
                    "from": user_a,
                    "to": user_b,
                    "convId": user_b,
                    "chatType": 0,
                    "direction": 0,
                    "status": 2,
                    "hasRead": True,
                    "hasReadAck": False,
                    "hasDeliverAck": False,
                    "needGroupAck": False,
                    "isThread": False,
                    "isContentReplaced": False,
                    "deliverOnlineOnly": False,
                    "body": {"type": 0, "content": content, "translations": {}},
                },
            },
        },
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "broadcast", "onlineState"},
    )
    deadline = time.monotonic() + 30
    while time.monotonic() < deadline:
        evt = device_b.receive_message(match_event_type=Cmd.onMessagesReceived.value, timeout=2)
        target = next(
            (
                m for m in (((evt or {}).get("data") or {}).get("messages") or [])
                if isinstance(m, dict) and str(m.get("msgId")) == str(real_id)
            ),
            None,
        )
        if target is not None:
            _assert_text_event(
                assert_api,
                {"type": evt.get("type"), "eventType": evt.get("eventType"), "data": {"messages": [target]}, "timestamp": evt.get("timestamp")},
                event_type=Cmd.onMessagesReceived.value,
                msg_id=real_id,
                user_a=user_a,
                user_b=user_b,
                content=content,
                direction=1,
                conv_id=user_a,
                has_read=False,
                has_deliver_ack=True,
            )
            delivered = _wait_text_event(device_a, Cmd.onMessagesDelivered.value, msg_id=real_id, content=content)
            _assert_text_event(
                assert_api,
                delivered,
                event_type=Cmd.onMessagesDelivered.value,
                msg_id=real_id,
                user_a=user_a,
                user_b=user_b,
                content=content,
                direction=0,
                conv_id=user_b,
                has_read=True,
                has_deliver_ack=True,
            )
            return real_id
    raise AssertionError(f"接收端在 60 秒内未收到本次消息: msgId={real_id}, content={content}")


def _wait_recall_event(device_b, msg_id, *, timeout=30):
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        evt = device_b.receive_message(
            match_event_type=Cmd.onMessagesRecalledInfo.value,
            timeout=min(2.0, max(0.1, deadline - time.monotonic())),
        )
        if evt:
            seen.append(evt)
        infos = ((evt or {}).get("data") or {}).get("infos") or []
        if any(
            isinstance(info, dict) and str(info.get("recallMsgId")) == str(msg_id)
            for info in infos
        ):
            return evt
    raise AssertionError(f"接收端未收到本次撤回事件: msgId={msg_id}, events={seen}")


def _assert_error(assert_api, resp, cmd, device, code, description):
    assert_api.assert_response_matches(
        resp,
        expected={"manager": "ChatManager", "cmd": cmd, "device": device, "result": {"code": code, "description": description}},
        ignore_keys={"sequence"},
    )


def test_chat_pin_message_invalid_id(device_a, assert_api):
    resp = device_a.call("ChatManager", Cmd.pinMessage.value, info={"msgId": "__invalid_pin_msg__"})
    _assert_error(assert_api, resp, Cmd.pinMessage.value, "deviceA", 500, "Message is invalid")


def test_chat_pin_message_empty_id(device_a, assert_api):
    resp = device_a.call("ChatManager", Cmd.pinMessage.value, info={"msgId": ""})
    _assert_error(assert_api, resp, Cmd.pinMessage.value, "deviceA", 110, "messageId is empty")


def test_chat_pin_recalled_message(device_a, device_b, assert_api, user_a, user_b):
    content = f"pin-recalled-{uuid.uuid4().hex[:8]}"
    msg_id = _send_text(device_a, device_b, assert_api, user_a, user_b, content)
    time.sleep(float(os.getenv("CHAT_RECALL_SETTLE_SECONDS", "5")))
    recall = device_a.call("ChatManager", Cmd.recallMessage.value, info={"msgId": msg_id})
    assert_api.assert_response_matches(recall, expected={"manager": "ChatManager", "cmd": Cmd.recallMessage.value, "device": "deviceA", "result": True}, ignore_keys={"sequence"})
    recall_event = _wait_recall_event(device_b, msg_id)
    infos = (recall_event.get("data") or {}).get("infos") or []
    recalled_info = next(
        info for info in infos
        if isinstance(info, dict) and str(info.get("recallMsgId")) == str(msg_id)
    )
    assert_api.assert_response_matches(
        {"type": "event", "eventType": Cmd.onMessagesRecalledInfo.value,
         "data": {"infos": [recalled_info]}},
        expected={
            "type": "event",
            "eventType": Cmd.onMessagesRecalledInfo.value,
            "data": {"infos": [{
                "recallBy": user_a,
                "recallMsgId": str(msg_id),
                "convId": user_a,
                "msg": {
                    "msgId": str(msg_id), "from": user_a, "to": user_b,
                    "convId": user_a, "chatType": 0, "direction": 1,
                    "status": 2, "hasRead": False, "hasReadAck": False,
                    "hasDeliverAck": True, "needGroupAck": False,
                    "isThread": False, "isContentReplaced": False,
                    "deliverOnlineOnly": False,
                    "body": {"type": 0, "content": content, "translations": {}},
                },
                "ext": "",
            }]},
        },
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "receiverList"},
    )
    resp = device_a.call("ChatManager", Cmd.pinMessage.value, info={"msgId": msg_id})
    _assert_error(assert_api, resp, Cmd.pinMessage.value, "deviceA", 500, "Message is invalid")


@pytest.mark.parametrize(
    ("type_key", "payload"),
    [
        ("location", {"latitude": 30.2741, "longitude": 120.1551,
                      "address": "pin-recalled-location", "buildingName": "pin-recalled"}),
        ("custom", {"event": "pin-recalled-custom", "params": {"case": "recalled"}}),
    ],
)
def test_chat_pin_recalled_typed_message(
    device_a, device_b, assert_api, user_a, user_b, type_key, payload,
):
    _, _, _, msg_id = _send_typed(
        device_a, device_b, assert_api, user_a, user_b, type_key, payload,
    )
    time.sleep(float(os.getenv("CHAT_RECALL_SETTLE_SECONDS", "5")))
    recall = device_a.call("ChatManager", Cmd.recallMessage.value, info={"msgId": msg_id})
    assert_api.assert_response_matches(
        recall,
        expected={"manager": "ChatManager", "cmd": Cmd.recallMessage.value,
                  "device": "deviceA", "result": True},
        ignore_keys={"sequence"},
    )
    time.sleep(1)
    response = device_a.call("ChatManager", Cmd.pinMessage.value, info={"msgId": msg_id})
    _assert_error(assert_api, response, Cmd.pinMessage.value, "deviceA", 500, "Message is invalid")


def test_chat_unpin_message_invalid_id(device_a, assert_api):
    resp = device_a.call("ChatManager", Cmd.unpinMessage.value, info={"msgId": "__invalid_unpin_msg__"})
    _assert_error(assert_api, resp, Cmd.unpinMessage.value, "deviceA", 500, "Message is invalid")


def test_chat_unpin_message_empty_id(device_a, assert_api):
    resp = device_a.call("ChatManager", Cmd.unpinMessage.value, info={"msgId": ""})
    _assert_error(assert_api, resp, Cmd.unpinMessage.value, "deviceA", 110, "messageId is empty")


@pytest.mark.parametrize("conv_id", ["", "__invalid_pin_conversation__"])
def test_chat_fetch_pinned_messages_invalid_conversation(device_a, assert_api, conv_id):
    resp = device_a.call("ChatManager", Cmd.fetchPinnedMessages.value, info={"convId": conv_id})
    expected = (110, "conversationId is empty") if conv_id == "" else (107, "Invalid conversation")
    _assert_error(assert_api, resp, Cmd.fetchPinnedMessages.value, "deviceA", *expected)
