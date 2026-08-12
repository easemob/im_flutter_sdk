from __future__ import annotations

import time
import uuid

import pytest

from src import Cmd
from tests.chat._utils import build_text

pytestmark = [pytest.mark.client, pytest.mark.chat]


def _wait_text_event(device, event_type, *, content, timeout=30.0):
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        event = device.receive_message(match_event_type=event_type, timeout=2)
        if event:
            seen.append(event)
        if event_type == Cmd.onMessageSuccess.value:
            message = ((event or {}).get("data") or {}).get("msg") or {}
            if (message.get("body") or {}).get("content") == content:
                return event, message
            continue
        for message in (((event or {}).get("data") or {}).get("messages") or []):
            if isinstance(message, dict) and (message.get("body") or {}).get("content") == content:
                return event, message
    pytest.fail(f"未收到文本消息事件: eventType={event_type}, content={content!r}, seen={seen}")


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


def _prepare_conversation(device_a, device_b, assert_api, user_a, user_b):
    content = f"conversation-pin-{uuid.uuid4().hex[:6]}"
    device_a.drain_events()
    device_b.drain_events()
    response = device_a.call("ChatManager", Cmd.sendMessage.value, info=build_text(user_a, user_b, content))
    temp_id = ((response.get("result") or {}).get("msgId"))
    assert temp_id, response
    assert_api.assert_response_matches(
        response,
        expected={"manager": "ChatManager", "cmd": Cmd.sendMessage.value, "device": "deviceA", "result": {
            "msgId": temp_id, "from": user_a, "to": user_b, "convId": user_b,
            "chatType": 0, "direction": 0, "hasRead": True,
            "needReadReceipt": False, "isThread": False, "isContentReplaced": False,
            "body": {"type": 0, "content": content},
        }},
        ignore_keys={"sequence", "localTime", "serverTime", "broadcast", "onlineState",
                     "deliverOnlineOnly", "targetLanguages", "translations"},
    )
    _, sent = _wait_text_event(device_a, Cmd.onMessageSuccess.value, content=content)
    real_id = sent.get("msgId")
    _assert_text_event(
        assert_api, Cmd.onMessageSuccess.value, sent, msg_id=real_id, user_a=user_a, user_b=user_b,
        content=content, direction=0, conv_id=user_b, has_read=True, has_deliver_ack=None,
    )
    _, received = _wait_text_event(device_b, Cmd.onMessagesReceived.value, content=content)
    _assert_text_event(
        assert_api, Cmd.onMessagesReceived.value, received, msg_id=real_id, user_a=user_a, user_b=user_b,
        content=content, direction=1, conv_id=user_a, has_read=False, has_deliver_ack=None,
    )
    deadline = time.monotonic() + 60
    while time.monotonic() < deadline:
        conversations = device_a.call("ChatManager", Cmd.getConversationsFromServer.value, info={})
        if any(isinstance(item, dict) and item.get("convId") == user_b
               for item in (conversations.get("result") or [])):
            return
        time.sleep(2)
    pytest.fail("未准备好服务端单聊会话")


def _target_pinned(response, conv_id):
    return [
        {"convId": item.get("convId"), "type": item.get("type"), "isPinned": item.get("isPinned"),
         "isThread": item.get("isThread")}
        # 5.0 fetchPinnedConversations 返回纯 list（无 {list, cursor} dict）
        for item in (response.get("result") or [])
        if isinstance(item, dict) and item.get("convId") == conv_id
    ]


def test_chat_conversation_pin_and_unpin_are_idempotent(device_a, device_b, assert_api, user_a, user_b):
    _prepare_conversation(device_a, device_b, assert_api, user_a, user_b)
    for is_pinned in (False, True, True):
        response = device_a.call(
            "ChatManager", Cmd.pinConversation.value,
            info={"convId": user_b, "isPinned": is_pinned},
        )
        assert_api.assert_response_matches(
            response,
            expected={"manager": "ChatManager", "cmd": Cmd.pinConversation.value,
                      "device": "deviceA", "result": None},
            ignore_keys={"sequence"},
        )
    fetch = device_a.call(
        "ChatManager", Cmd.fetchConversationsByOptions.value,
        info={"pageSize": 20, "cursor": "", "pinned": True},
    )
    assert_api.assert_response_matches(
        {"manager": fetch.get("manager"), "cmd": fetch.get("cmd"), "device": fetch.get("device"),
         "result": {"target": _target_pinned(fetch, user_b)}},
        expected={"manager": "ChatManager", "cmd": Cmd.fetchConversationsByOptions.value,
                  "device": "deviceA", "result": {"target": [{"convId": user_b,
                  "type": 0, "isPinned": True, "isThread": False}]}},
        ignore_keys={"sequence"},
    )
    for _ in range(2):
        response = device_a.call(
            "ChatManager", Cmd.pinConversation.value,
            info={"convId": user_b, "isPinned": False},
        )
        assert_api.assert_response_matches(
            response,
            expected={"manager": "ChatManager", "cmd": Cmd.pinConversation.value,
                      "device": "deviceA", "result": None},
            ignore_keys={"sequence"},
        )
    fetch_after = device_a.call(
        "ChatManager", Cmd.fetchConversationsByOptions.value,
        info={"pageSize": 20, "cursor": "", "pinned": True},
    )
    # 5.0 fetchConversationsByOptions 返回全部会话（不按 pinned 过滤）→ 改为验证该会话 isPinned=False
    proj_after = _target_pinned(fetch_after, user_b)
    assert proj_after and proj_after[0].get("isPinned") is False, f"取消置顶后 isPinned 应为 False: {fetch_after}"

def test_chat_pin_conversation_non_boolean_coerces_to_unpin(
    device_a, device_b, assert_api, user_a, user_b,
):
    """Generic bridge 实测 Android 会将非布尔 isPinned 按 false 处理。"""
    _prepare_conversation(device_a, device_b, assert_api, user_a, user_b)
    pin = device_a.call(
        "ChatManager", Cmd.pinConversation.value,
        info={"convId": user_b, "isPinned": True},
    )
    assert_api.assert_response_matches(
        pin,
        expected={"manager": "ChatManager", "cmd": Cmd.pinConversation.value,
                  "device": "deviceA", "result": None},
        ignore_keys={"sequence"},
    )
    response = device_a.call(
        "ChatManager", Cmd.pinConversation.value,
        info={"convId": user_b, "isPinned": "not-a-boolean"},
    )
    assert_api.assert_response_matches(
        response,
        expected={"manager": "ChatManager", "cmd": Cmd.pinConversation.value,
                  "device": "deviceA", "result": None},
        ignore_keys={"sequence"},
    )
    conversation = device_a.call(
        "ChatManager", Cmd.getConversation.value,
        info={"convId": user_b, "type": 0, "createIfNeed": True},
    )
    result = conversation.get("result") or {}
    assert_api.assert_response_matches(
        {"manager": conversation.get("manager"), "cmd": conversation.get("cmd"),
         "device": conversation.get("device"),
         "result": {"convId": result.get("convId"), "type": result.get("type"),
                    "isPinned": result.get("isPinned")}},
        expected={"manager": "ChatManager", "cmd": Cmd.getConversation.value,
                  "device": "deviceA", "result": {"convId": user_b, "type": 0,
                  "isPinned": False}},
        ignore_keys={"sequence"},
    )


@pytest.mark.parametrize(
    ("page_size", "expected"),
    [
        (0, {"cursor": "", "list": []}),
        (-1, {"cursor": "", "list": []}),
        (1000, {"cursor": "", "list": []}),
    ],
)
@pytest.mark.skip(reason="5.0 移除 cursor 分页（fetchPinnedConversations 返回纯 list，无 pageSize 校验）")
def test_chat_fetch_pinned_conversations_page_size_boundaries(
    device_a, assert_api, page_size, expected,
):
    response = device_a.call(
        "ChatManager", Cmd.fetchConversationsByOptions.value,
        info={"pageSize": page_size, "cursor": "", "pinned": True},
    )
    assert_api.assert_response_matches(
        response,
        expected={"manager": "ChatManager", "cmd": Cmd.fetchConversationsByOptions.value,
                  "device": "deviceA", "result": expected},
        ignore_keys={"sequence"},
    )
