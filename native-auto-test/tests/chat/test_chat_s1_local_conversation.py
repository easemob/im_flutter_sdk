from __future__ import annotations

import time
import uuid

from src import Cmd
from tests.chat._utils import build_text, now_ms


def _assert_chat_response(assert_api, resp: dict, cmd: str, device: str, result_expected) -> None:
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": cmd,
            "device": device,
            "result": result_expected,
        },
        ignore_keys={"sequence"},
    )


def _wait_text_event(device, event_type: str, *, real_id: str, content: str, timeout: float = 30.0) -> dict:
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        evt = device.receive_message(match_event_type=event_type, timeout=min(2.0, max(0.1, deadline - time.monotonic())))
        if evt:
            seen.append(evt)
        for msg in ((evt or {}).get("data") or {}).get("messages") or []:
            if not isinstance(msg, dict):
                continue
            if str(msg.get("msgId")) == str(real_id) and ((msg.get("body") or {}).get("content") == content):
                return {
                    "type": evt.get("type"),
                    "eventType": evt.get("eventType"),
                    "data": {"messages": [msg]},
                    "timestamp": evt.get("timestamp"),
                }
    raise AssertionError(f"未收到目标消息事件: event={event_type}, msgId={real_id}, content={content}, events={seen}")


def _send_text_and_get_real_id(device_a, device_b, assert_api, user_a: str, user_b: str, content: str) -> str:
    try:
        device_a.drain_events()
        device_b.drain_events()
    except Exception:
        pass

    resp_send = device_a.call("ChatManager", Cmd.sendMessage.value, info=build_text(user_a, user_b, content))
    assert_api.assert_response_matches(
        resp_send,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.sendMessage.value,
            "device": "deviceA",
            "result": {
                "from": "{{fromUser}}",
                "to": "{{toUser}}",
                "convId": "{{toUser}}",
                "chatType": 0,
                "direction": 0,
                "status": 0,
                "hasRead": True,
                "needReadReceipt": False, "isThread": False,
                "isContentReplaced": False,
                "body": {"type": 0, "content": "{{content}}"},
            },
        },
        context={"fromUser": user_a, "toUser": user_b, "content": content},
        ignore_keys={
            "sequence",
            "msgId",
            "serverTime",
            "localTime",
            "broadcast",
            "onlineState",
            "deliverOnlineOnly",
            "targetLanguages",
            "translations",
        },
    )

    evt_success = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
    evt_received = device_b.receive_message(match_event_type=Cmd.onMessagesReceived.value, timeout=20.0)
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
                    "needReadReceipt": False, "deliverOnlineOnly": False,
                    "isThread": False,
                    "isContentReplaced": False,
                    "body": {"type": 0, "content": "{{content}}"},
                }
            },
        },
        context={"fromUser": user_a, "toUser": user_b, "content": content},
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "msgId", "translations", "broadcast", "onlineState", "targetLanguages"},
    )
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
                        "needReadReceipt": False, "deliverOnlineOnly": False,
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

    real_id = (((evt_success.get("data") or {}).get("msg")) or {}).get("msgId")
    assert real_id, f"missing real msgId from onMessageSuccess: {evt_success!r}"
    return str(real_id)


def test_chat_get_conversation_success(device_a, device_b, assert_api, user_a, user_b):
    _ = _send_text_and_get_real_id(device_a, device_b, assert_api, user_a, user_b, f"s1-get-conv-{uuid.uuid4().hex[:6]}")
    resp = device_a.call(
        "ChatManager",
        Cmd.getConversation.value,
        info={"convId": user_b, "type": 0, "createIfNeed": True},
    )
    result = resp.get("result") or {}
    assert_api.assert_response_matches(
        {
            "manager": "ChatManager",
            "cmd": Cmd.getConversation.value,
            "device": "deviceA",
            "result": {
                "convId": result.get("convId"),
                "type": result.get("type"),
            },
        },
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.getConversation.value,
            "device": "deviceA",
            "result": {"convId": "{{convId}}", "type": 0},
        },
        context={"convId": user_b},
        ignore_keys={"sequence"},
    )


def test_chat_get_conversation_not_exist_without_create(device_a, assert_api):
    resp = device_a.call(
        "ChatManager",
        Cmd.getConversation.value,
        info={"convId": "__nonexistent_conv__", "type": 0, "createIfNeed": False},
    )
    _assert_chat_response(assert_api, resp, Cmd.getConversation.value, "deviceA", None)


def test_chat_get_conversation_empty_conv_id(device_a, assert_api):
    resp = device_a.call(
        "ChatManager",
        Cmd.getConversation.value,
        info={"convId": "", "type": 0, "createIfNeed": False},
    )
    _assert_chat_response(assert_api, resp, Cmd.getConversation.value, "deviceA", None)


def test_chat_get_unread_count_positive_then_zero(device_a, device_b, assert_api, user_a, user_b):
    resp_mark = device_b.call("ChatManager", Cmd.markAllChatMsgAsRead.value, info={})
    assert_api.assert_response_matches(
        resp_mark,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.markAllChatMsgAsRead.value,
            "device": "deviceB",
            "result": True,
        },
        ignore_keys={"sequence"},
    )

    _ = _send_text_and_get_real_id(device_a, device_b, assert_api, user_a, user_b, f"s1-unread-{uuid.uuid4().hex[:6]}")

    resp_unread = device_b.call("ChatManager", Cmd.getUnreadMessageCount.value, info={})
    assert_api.assert_response_matches(
        resp_unread,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.getUnreadMessageCount.value,
            "device": "deviceB",
            "result": 1,
        },
        ignore_keys={"sequence"},
    )

    resp_mark_2 = device_b.call("ChatManager", Cmd.markAllChatMsgAsRead.value, info={})
    assert_api.assert_response_matches(
        resp_mark_2,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.markAllChatMsgAsRead.value,
            "device": "deviceB",
            "result": True,
        },
        ignore_keys={"sequence"},
    )

    resp_unread_after = device_b.call("ChatManager", Cmd.getUnreadMessageCount.value, info={})
    _assert_chat_response(assert_api, resp_unread_after, Cmd.getUnreadMessageCount.value, "deviceB", 0)


def test_chat_mark_all_as_read_idempotent(device_b, assert_api):
    resp_1 = device_b.call("ChatManager", Cmd.markAllChatMsgAsRead.value, info={})
    assert_api.assert_response_matches(
        resp_1,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.markAllChatMsgAsRead.value,
            "device": "deviceB",
            "result": True,
        },
        ignore_keys={"sequence"},
    )

    resp_2 = device_b.call("ChatManager", Cmd.markAllChatMsgAsRead.value, info={})
    assert_api.assert_response_matches(
        resp_2,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.markAllChatMsgAsRead.value,
            "device": "deviceB",
            "result": True,
        },
        ignore_keys={"sequence"},
    )

    resp_unread = device_b.call("ChatManager", Cmd.getUnreadMessageCount.value, info={})
    _assert_chat_response(assert_api, resp_unread, Cmd.getUnreadMessageCount.value, "deviceB", 0)


def test_chat_load_all_conversations_contains_then_not_contains(device_a, device_b, assert_api, user_a, user_b):
    _ = device_a.call(
        "ChatManager",
        Cmd.deleteConversation.value,
        info={"convId": user_b, "deleteMessages": True},
    )
    _ = _send_text_and_get_real_id(device_a, device_b, assert_api, user_a, user_b, f"s1-load-all-{uuid.uuid4().hex[:6]}")
    time.sleep(2)

    resp_load = device_a.call("ChatManager", Cmd.loadAllConversations.value, info={})
    result = resp_load.get("result")
    projected: list[dict] = []
    if isinstance(result, list):
        projected = [
            {"convId": item.get("convId"), "type": item.get("type")}
            for item in result
            if isinstance(item, dict) and str(item.get("convId")) == str(user_b)
        ]
    assert_api.assert_response_matches(
        {
            "manager": "ChatManager",
            "cmd": Cmd.loadAllConversations.value,
            "device": "deviceA",
            "result": projected,
        },
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.loadAllConversations.value,
            "device": "deviceA",
            "result": [{"convId": "{{convId}}", "type": 0}],
        },
        context={"convId": user_b},
        ignore_keys={"sequence"},
    )

    resp_delete = device_a.call(
        "ChatManager",
        Cmd.deleteConversation.value,
        info={"convId": user_b, "deleteMessages": True},
    )
    assert_api.assert_response_matches(
        resp_delete,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.deleteConversation.value,
            "device": "deviceA",
            "result": True,
        },
        ignore_keys={"sequence"},
    )

    resp_load_after = device_a.call("ChatManager", Cmd.loadAllConversations.value, info={})
    result_after = resp_load_after.get("result")
    projected_after = [
        {"convId": item.get("convId"), "type": item.get("type")}
        for item in (result_after if isinstance(result_after, list) else [])
        if isinstance(item, dict) and str(item.get("convId")) == str(user_b)
    ]
    assert_api.assert_response_matches(
        {
            "manager": "ChatManager",
            "cmd": Cmd.loadAllConversations.value,
            "device": "deviceA",
            "result": projected_after,
        },
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.loadAllConversations.value,
            "device": "deviceA",
            "result": [],
        },
        ignore_keys={"sequence"},
    )


def test_chat_delete_conversation_existing_then_not_found(device_a, device_b, assert_api, user_a, user_b):
    _ = _send_text_and_get_real_id(device_a, device_b, assert_api, user_a, user_b, f"s1-del-conv-{uuid.uuid4().hex[:6]}")

    resp_delete = device_a.call(
        "ChatManager",
        Cmd.deleteConversation.value,
        info={"convId": user_b, "deleteMessages": True},
    )
    _assert_chat_response(assert_api, resp_delete, Cmd.deleteConversation.value, "deviceA", True)

    resp_get = device_a.call(
        "ChatManager",
        Cmd.getConversation.value,
        info={"convId": user_b, "type": 0, "createIfNeed": False},
    )
    _assert_chat_response(assert_api, resp_get, Cmd.getConversation.value, "deviceA", None)


def test_chat_delete_conversation_nonexistent_returns_bool(device_a, assert_api):
    resp = device_a.call(
        "ChatManager",
        Cmd.deleteConversation.value,
        info={"convId": "__nonexistent_conv__", "deleteMessages": True},
    )
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.deleteConversation.value,
            "device": "deviceA",
            "result": True,
        },
        ignore_keys={"sequence"},
    )


def test_chat_delete_messages_before_timestamp_future_removes_msg(device_a, device_b, assert_api, user_a, user_b):
    real_id = _send_text_and_get_real_id(device_a, device_b, assert_api, user_a, user_b, f"s1-del-before-future-{uuid.uuid4().hex[:6]}")
    resp_del = device_a.call(
        "ChatManager",
        Cmd.deleteMessagesBeforeTimestamp.value,
        info={"timestamp": now_ms() + 1000},
    )
    _assert_chat_response(assert_api, resp_del, Cmd.deleteMessagesBeforeTimestamp.value, "deviceA", None)

    resp_get = device_a.call("ChatManager", Cmd.getMessage.value, info={"msgId": real_id})
    _assert_chat_response(assert_api, resp_get, Cmd.getMessage.value, "deviceA", None)


def test_chat_delete_messages_before_timestamp_zero_keeps_recent_msg(device_a, device_b, assert_api, user_a, user_b):
    real_id = _send_text_and_get_real_id(device_a, device_b, assert_api, user_a, user_b, f"s1-del-before-zero-{uuid.uuid4().hex[:6]}")
    resp_del = device_a.call(
        "ChatManager",
        Cmd.deleteMessagesBeforeTimestamp.value,
        info={"timestamp": 0},
    )
    _assert_chat_response(assert_api, resp_del, Cmd.deleteMessagesBeforeTimestamp.value, "deviceA", None)

    resp_get = device_a.call("ChatManager", Cmd.getMessage.value, info={"msgId": real_id})
    result_get = resp_get.get("result") or {}
    assert_api.assert_response_matches(
        {
            "manager": "ChatManager",
            "cmd": Cmd.getMessage.value,
            "device": "deviceA",
            "result": {"msgId": result_get.get("msgId")},
        },
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.getMessage.value,
            "device": "deviceA",
            "result": {"msgId": "{{msgId}}"},
        },
        context={"msgId": str(real_id)},
        ignore_keys={"sequence"},
    )
