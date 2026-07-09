from __future__ import annotations

import time
import uuid

import pytest

from src import Cmd
from tests.chat._utils import build_text

pytestmark = [pytest.mark.client, pytest.mark.chat, pytest.mark.agorachat1_4_0]


def _send_text_and_get_real_id(device_a, device_b, assert_api, user_a: str, user_b: str, content: str) -> str:
    try:
        device_a.drain_events()
        device_b.drain_events()
    except Exception:
        pass

    resp_send = device_a.call("ChatManager", Cmd.sendMessage.value, info=build_text(user_a, user_b, content))
    send_result = resp_send.get("result") or {}
    send_msg_id = send_result.get("msgId")
    assert send_msg_id, f"missing msgId in sendMessage result: {resp_send!r}"
    assert_api.assert_response_matches(
        {
            "manager": "ChatManager",
            "cmd": Cmd.sendMessage.value,
            "device": "deviceA",
            "result": {
                "msgId": str(send_msg_id),
                "from": send_result.get("from"),
                "to": send_result.get("to"),
                "body": {"content": (send_result.get("body") or {}).get("content")},
            },
        },
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.sendMessage.value,
            "device": "deviceA",
            "result": {
                "msgId": "{{msgId}}",
                "from": "{{fromUser}}",
                "to": "{{toUser}}",
                "body": {"content": "{{content}}"},
            },
        },
        context={"msgId": str(send_msg_id), "fromUser": user_a, "toUser": user_b, "content": content},
        ignore_keys={"sequence"},
    )

    real_id = str(send_msg_id)

    evt_success = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=10.0)
    assert_api.assert_response_matches(
        evt_success,
        expected={
            "type": "event",
            "eventType": Cmd.onMessageSuccess.value,
            "data": {
                "msg": {
                    "from": "{{fromUser}}",
                    "to": "{{toUser}}",
                    "convId": "{{toUser}}",
                    "chatType": 0,
                    "direction": 0,
                    "status": 2,
                    "hasRead": True,
                    "hasReadAck": False,
                    "hasDeliverAck": False,
                    "needGroupAck": False,
                    "deliverOnlineOnly": False,
                    "isThread": False,
                    "isContentReplaced": False,
                    "body": {"type": 0, "content": "{{content}}"},
                }
            },
        },
        context={"fromUser": user_a, "toUser": user_b, "content": content},
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "msgId", "translations", "broadcast", "onlineState", "targetLanguages"},
    )
    evt_msg = ((evt_success.get("data") or {}).get("msg")) or {}
    evt_body = evt_msg.get("body") or {}
    if (
        evt_msg.get("from") == user_a
        and evt_msg.get("to") == user_b
        and evt_body.get("content") == content
        and evt_msg.get("msgId")
    ):
        real_id = str(evt_msg.get("msgId"))

    evt_received = device_b.receive_message(match_event_type=Cmd.onMessagesReceived.value, timeout=10.0)
    assert_api.assert_response_matches(
        evt_received,
        expected={
            "type": "event",
            "eventType": Cmd.onMessagesReceived.value,
            "data": {
                "messages": [
                    {
                        "from": "{{fromUser}}",
                        "to": "{{toUser}}",
                        "convId": "{{fromUser}}",
                        "chatType": 0,
                        "direction": 1,
                        "status": 2,
                        "hasRead": False,
                        "hasReadAck": False,
                        "hasDeliverAck": False,
                        "needGroupAck": False,
                        "deliverOnlineOnly": False,
                        "isThread": False,
                        "isContentReplaced": False,
                        "body": {"type": 0, "content": "{{content}}"},
                    }
                ]
            },
        },
        context={"fromUser": user_a, "toUser": user_b, "content": content},
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "msgId", "translations", "receiverList"},
    )
    data = evt_received.get("data") or {}
    for msg in (data.get("messages") or []):
        body = (msg or {}).get("body") or {}
        if (
            (msg or {}).get("from") == user_a
            and (msg or {}).get("to") == user_b
            and body.get("content") == content
            and (msg or {}).get("msgId")
        ):
            real_id = str(msg.get("msgId"))
            break

    return real_id


def _receive_ack_conversation_event(device, *, from_user: str, to_user: str, timeout: float = 60.0) -> dict:
    expected_types = {
        "onConversationRead",
        Cmd.onConversationHasRead.value,
        Cmd.onMessagesRead.value,
        Cmd.onMessageReadAck.value,
    }
    seen_events = []
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        evt = device.receive_message(timeout=2.0)
        if evt:
            seen_events.append(evt)
        evt_type = (evt or {}).get("eventType")
        data = (evt or {}).get("data") or {}
        if evt_type in expected_types and data.get("from") == from_user and data.get("to") == to_user:
            return evt
    raise AssertionError(f"未收到目标 ackConversationRead 事件: from={from_user}, to={to_user}, events={seen_events}")


def _pin_conversation_after_pending_ops(device, *, conv_id: str, is_pinned: bool, timeout: float = 15.0) -> dict:
    seen_responses = []
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        resp = device.call("ChatManager", Cmd.pinConversation.value, info={"convId": conv_id, "isPinned": is_pinned})
        seen_responses.append(resp)
        result = resp.get("result")
        if result is None:
            return resp
        if (
            isinstance(result, dict)
            and result.get("code") == 303
            and "concurrent operation" in str(result.get("description", ""))
        ):
            time.sleep(1.0)
            continue
        return resp
    raise AssertionError(
        "pinConversation 持续返回 303/concurrent operation are not allowed: "
        f"{seen_responses}"
    )

def _assert_error_with_envelope(
    assert_api,
    resp: dict,
    cmd: str,
    device: str,
    *,
    code: int,
    desc_contains: str,
) -> None:
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": cmd,
            "device": device,
            "result": {"code": code, "description": desc_contains},
        },
        ignore_keys={"sequence"},
    )


def _assert_invalid_conv_returns_cursor(assert_api, resp: dict, cmd: str, device: str = "deviceA") -> None:
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": cmd,
            "device": device,
            "result": {
                "cursor": "",
                "list": [],
            },
        },
        ignore_keys={"sequence"},
    )


def test_chat_ack_conversation_read_success_with_event(device_a, device_b, assert_api, user_a, user_b):
    real_id = _send_text_and_get_real_id(device_a, device_b, assert_api, user_a, user_b, f"s3-ack-conv-{uuid.uuid4().hex[:6]}")
    resp_ack = device_b.call("ChatManager", Cmd.ackConversationRead.value, info={"convId": user_a})
    assert_api.assert_response_matches(
        resp_ack,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.ackConversationRead.value,
            "device": "deviceB",
            "result": True,
        },
        ignore_keys={"sequence"},
    )

    evt = _receive_ack_conversation_event(device_a, from_user=user_b, to_user=user_a, timeout=60.0)
    evt_type = (evt or {}).get("eventType")
    assert evt_type in (
        "onConversationRead",
        Cmd.onConversationHasRead.value,
        Cmd.onMessagesRead.value,
        Cmd.onMessageReadAck.value,
    ), f"unexpected eventType for ackConversationRead: {evt!r}"
    assert_api.assert_response_matches(
        evt,
        expected={
            "type": "event",
            "eventType": "{{eventType}}",
            "data": {
                "from": "{{fromUser}}",
                "to": "{{toUser}}",
            },
        },
        context={"eventType": evt_type, "fromUser": user_b, "toUser": user_a},
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime"},
    )


def test_chat_ack_conversation_read_invalid_conv_id(device_b, assert_api):
    resp = device_b.call("ChatManager", Cmd.ackConversationRead.value, info={"convId": "__invalid_conversation_id__"})
    _assert_error_with_envelope(
        assert_api,
        resp,
        Cmd.ackConversationRead.value,
        "deviceB",
        code=500,
        desc_contains="Message is invalid",
    )


def test_chat_ack_conversation_read_empty_conv_id(device_b, assert_api):
    resp = device_b.call("ChatManager", Cmd.ackConversationRead.value, info={"convId": ""})
    _assert_error_with_envelope(
        assert_api,
        resp,
        Cmd.ackConversationRead.value,
        "deviceB",
        code=500,
        desc_contains="Message is invalid",
    )


def test_chat_pin_conversation_success_toggle(device_a, device_b, assert_api, user_a, user_b):
    resp_prepare = device_a.call("ChatManager", Cmd.getConversation.value, info={"convId": user_b, "type": 0, "createIfNeed": True})
    prepare_conv = resp_prepare.get("result") or {}
    assert_api.assert_response_matches(
        {
            "manager": "ChatManager",
            "cmd": Cmd.getConversation.value,
            "device": "deviceA",
            "result": {
                "convId": prepare_conv.get("convId"),
                "type": prepare_conv.get("type"),
            },
        },
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.getConversation.value,
            "device": "deviceA",
            "result": {
                "convId": "{{convId}}",
                "type": 0,
            },
        },
        context={"convId": user_b},
        ignore_keys={"sequence"},
    )

    cleanup_resp = _pin_conversation_after_pending_ops(device_a, conv_id=user_b, is_pinned=False)
    assert_api.assert_response_matches(
        cleanup_resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.pinConversation.value,
            "device": "deviceA",
            "result": None,
        },
        ignore_keys={"sequence"},
    )

    resp_pin = _pin_conversation_after_pending_ops(device_a, conv_id=user_b, is_pinned=True)
    assert_api.assert_response_matches(
        resp_pin,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.pinConversation.value,
            "device": "deviceA",
            "result": None,
        },
        ignore_keys={"sequence"},
    )

    resp_conv = device_a.call("ChatManager", Cmd.getConversation.value, info={"convId": user_b, "type": 0, "createIfNeed": True})
    conv = resp_conv.get("result") or {}
    assert_api.assert_response_matches(
        {
            "manager": "ChatManager",
            "cmd": Cmd.getConversation.value,
            "device": "deviceA",
            "result": {
                "convId": conv.get("convId"),
                "type": conv.get("type"),
                "isPinned": conv.get("isPinned"),
            },
        },
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.getConversation.value,
            "device": "deviceA",
            "result": {
                "convId": "{{convId}}",
                "type": 0,
                "isPinned": True,
            },
        },
        context={"convId": user_b},
        ignore_keys={"sequence"},
    )

    resp_unpin = _pin_conversation_after_pending_ops(device_a, conv_id=user_b, is_pinned=False)
    assert_api.assert_response_matches(
        resp_unpin,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.pinConversation.value,
            "device": "deviceA",
            "result": None,
        },
        ignore_keys={"sequence"},
    )

    resp_conv2 = device_a.call("ChatManager", Cmd.getConversation.value, info={"convId": user_b, "type": 0, "createIfNeed": True})
    conv2 = resp_conv2.get("result") or {}
    assert_api.assert_response_matches(
        {
            "manager": "ChatManager",
            "cmd": Cmd.getConversation.value,
            "device": "deviceA",
            "result": {
                "convId": conv2.get("convId"),
                "type": conv2.get("type"),
                "isPinned": conv2.get("isPinned"),
            },
        },
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.getConversation.value,
            "device": "deviceA",
            "result": {
                "convId": "{{convId}}",
                "type": 0,
                "isPinned": False,
            },
        },
        context={"convId": user_b},
        ignore_keys={"sequence"},
    )


def test_chat_pin_conversation_invalid_conv_id(device_a, assert_api):
    resp = device_a.call("ChatManager", Cmd.pinConversation.value, info={"convId": "__invalid__", "isPinned": True})
    _assert_error_with_envelope(
        assert_api,
        resp,
        Cmd.pinConversation.value,
        "deviceA",
        code=107,
        desc_contains="Invalid conversation",
    )


def test_chat_pin_conversation_empty_conv_id(device_a, assert_api):
    resp = device_a.call("ChatManager", Cmd.pinConversation.value, info={"convId": "", "isPinned": True})
    _assert_error_with_envelope(
        assert_api,
        resp,
        Cmd.pinConversation.value,
        "deviceA",
        code=107,
        desc_contains="Invalid conversation",
    )


def test_chat_fetch_history_messages_success(device_a, device_b, assert_api, user_a, user_b):
    content = f"s3-history-{uuid.uuid4().hex[:6]}"
    resp_send = device_a.call("ChatManager", Cmd.sendMessage.value, info=build_text(user_a, user_b, content))
    send_result = resp_send.get("result") or {}
    assert_api.assert_response_matches(
        {
            "manager": "ChatManager",
            "cmd": Cmd.sendMessage.value,
            "device": "deviceA",
            "result": {
                "from": send_result.get("from"),
                "to": send_result.get("to"),
                "body": {"content": (send_result.get("body") or {}).get("content")},
            },
        },
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.sendMessage.value,
            "device": "deviceA",
            "result": {"from": "{{fromUser}}", "to": "{{toUser}}", "body": {"content": "{{content}}"}},
        },
        context={"fromUser": user_a, "toUser": user_b, "content": content},
        ignore_keys={"sequence"},
    )
    evt_success = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
    assert_api.assert_response_matches(
        evt_success,
        expected={
            "type": "event",
            "eventType": Cmd.onMessageSuccess.value,
            "data": {
                "msg": {
                    "from": "{{fromUser}}",
                    "to": "{{toUser}}",
                    "convId": "{{toUser}}",
                    "chatType": 0,
                    "direction": 0,
                    "status": 2,
                    "hasRead": True,
                    "hasReadAck": False,
                    "hasDeliverAck": False,
                    "needGroupAck": False,
                    "deliverOnlineOnly": False,
                    "isThread": False,
                    "isContentReplaced": False,
                    "body": {"type": 0, "content": "{{content}}"},
                }
            },
        },
        context={"fromUser": user_a, "toUser": user_b, "content": content},
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "msgId", "translations", "broadcast", "onlineState", "targetLanguages"},
    )
    real_id = (((evt_success.get("data") or {}).get("msg")) or {}).get("msgId")
    assert real_id, f"missing real msgId from onMessageSuccess: {evt_success!r}"
    time.sleep(2)
    info = {"convId": user_b, "type": 0, "pageSize": 20, "startMsgId": "", "direction": 0}
    resp = device_a.call(
        "ChatManager",
        Cmd.fetchHistoryMessages.value,
        info=info,
    )
    result = resp.get("result") or {}
    hits = [
        {"msgId": item.get("msgId"), "convId": item.get("convId")}
        for item in (result.get("list") or [])
        if isinstance(item, dict) and str(item.get("msgId")) == str(real_id)
    ]
    if not hits:
        time.sleep(2)
        resp = device_a.call("ChatManager", Cmd.fetchHistoryMessages.value, info=info)
        result = resp.get("result") or {}
        hits = [
            {"msgId": item.get("msgId"), "convId": item.get("convId")}
            for item in (result.get("list") or [])
            if isinstance(item, dict) and str(item.get("msgId")) == str(real_id)
        ]
    assert_api.assert_response_matches(
        {
            "manager": "ChatManager",
            "cmd": Cmd.fetchHistoryMessages.value,
            "device": "deviceA",
            "result": {
                "list": hits,
            },
        },
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.fetchHistoryMessages.value,
            "device": "deviceA",
            "result": {"list": [{"msgId": "{{msgId}}", "convId": "{{convId}}"}]},
        },
        context={"msgId": str(real_id), "convId": user_b},
        ignore_keys={"sequence"},
    )


def test_chat_fetch_history_messages_invalid_conv_id(device_a, assert_api):
    resp = device_a.call(
        "ChatManager",
        Cmd.fetchHistoryMessages.value,
        info={"convId": "__invalid__", "type": 0, "pageSize": 20, "startMsgId": "", "direction": 0},
    )
    _assert_invalid_conv_returns_cursor(assert_api, resp, Cmd.fetchHistoryMessages.value, "deviceA")


def test_chat_fetch_history_messages_empty_conv_id(device_a, assert_api):
    resp = device_a.call(
        "ChatManager",
        Cmd.fetchHistoryMessages.value,
        info={"convId": "", "type": 0, "pageSize": 20, "startMsgId": "", "direction": 0},
    )
    _assert_error_with_envelope(
        assert_api,
        resp,
        Cmd.fetchHistoryMessages.value,
        "deviceA",
        code=205,
        desc_contains="Invalid parameter",
    )


def test_chat_fetch_history_messages_by_options_success(device_a, device_b, assert_api, user_a, user_b):
    content = f"s3-history-opt-{uuid.uuid4().hex[:6]}"
    resp_send = device_a.call("ChatManager", Cmd.sendMessage.value, info=build_text(user_a, user_b, content))
    send_result = resp_send.get("result") or {}
    assert_api.assert_response_matches(
        {
            "manager": "ChatManager",
            "cmd": Cmd.sendMessage.value,
            "device": "deviceA",
            "result": {
                "from": send_result.get("from"),
                "to": send_result.get("to"),
                "body": {"content": (send_result.get("body") or {}).get("content")},
            },
        },
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.sendMessage.value,
            "device": "deviceA",
            "result": {"from": "{{fromUser}}", "to": "{{toUser}}", "body": {"content": "{{content}}"}},
        },
        context={"fromUser": user_a, "toUser": user_b, "content": content},
        ignore_keys={"sequence"},
    )
    evt_success = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
    assert_api.assert_response_matches(
        evt_success,
        expected={
            "type": "event",
            "eventType": Cmd.onMessageSuccess.value,
            "data": {
                "msg": {
                    "from": "{{fromUser}}",
                    "to": "{{toUser}}",
                    "convId": "{{toUser}}",
                    "chatType": 0,
                    "direction": 0,
                    "status": 2,
                    "hasRead": True,
                    "hasReadAck": False,
                    "hasDeliverAck": False,
                    "needGroupAck": False,
                    "deliverOnlineOnly": False,
                    "isThread": False,
                    "isContentReplaced": False,
                    "body": {"type": 0, "content": "{{content}}"},
                }
            },
        },
        context={"fromUser": user_a, "toUser": user_b, "content": content},
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "msgId", "translations", "broadcast", "onlineState", "targetLanguages"},
    )
    real_id = (((evt_success.get("data") or {}).get("msg")) or {}).get("msgId")
    assert real_id, f"missing real msgId from onMessageSuccess: {evt_success!r}"
    time.sleep(2)
    info = {"convId": user_b, "type": 0, "pageSize": 20, "cursor": ""}
    resp = device_a.call(
        "ChatManager",
        Cmd.fetchHistoryMessagesByOptions.value,
        info=info,
    )
    result = resp.get("result") or {}
    hits = [
        {"msgId": item.get("msgId"), "convId": item.get("convId")}
        for item in (result.get("list") or [])
        if isinstance(item, dict) and str(item.get("msgId")) == str(real_id)
    ]
    if not hits:
        time.sleep(2)
        resp = device_a.call("ChatManager", Cmd.fetchHistoryMessagesByOptions.value, info=info)
        result = resp.get("result") or {}
        hits = [
            {"msgId": item.get("msgId"), "convId": item.get("convId")}
            for item in (result.get("list") or [])
            if isinstance(item, dict) and str(item.get("msgId")) == str(real_id)
        ]
    assert_api.assert_response_matches(
        {
            "manager": "ChatManager",
            "cmd": Cmd.fetchHistoryMessagesByOptions.value,
            "device": "deviceA",
            "result": {
                "list": hits,
            },
        },
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.fetchHistoryMessagesByOptions.value,
            "device": "deviceA",
            "result": {"list": [{"msgId": "{{msgId}}", "convId": "{{convId}}"}]},
        },
        context={"msgId": str(real_id), "convId": user_b},
        ignore_keys={"sequence"},
    )


def test_chat_fetch_history_messages_by_options_invalid_conv_id(device_a, assert_api):
    resp = device_a.call(
        "ChatManager",
        Cmd.fetchHistoryMessagesByOptions.value,
        info={"convId": "__invalid__", "type": 0, "pageSize": 20, "cursor": ""},
    )
    _assert_invalid_conv_returns_cursor(assert_api, resp, Cmd.fetchHistoryMessagesByOptions.value, "deviceA")


def test_chat_fetch_history_messages_by_options_empty_conv_id(device_a, assert_api):
    resp = device_a.call(
        "ChatManager",
        Cmd.fetchHistoryMessagesByOptions.value,
        info={"convId": "", "type": 0, "pageSize": 20, "cursor": ""},
    )
    _assert_invalid_conv_returns_cursor(
        assert_api,
        resp,
        Cmd.fetchHistoryMessagesByOptions.value,
        "deviceA",
    )
