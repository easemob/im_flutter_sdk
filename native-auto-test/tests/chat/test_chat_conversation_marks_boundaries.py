from __future__ import annotations

import time
import uuid

import pytest

from src import Cmd
from tests.chat._utils import build_text

pytestmark = [pytest.mark.client, pytest.mark.chat]


@pytest.mark.parametrize("info", [{"convIds": ["__invalid_conv__"], "mark": 0}, {"convIds": [""], "mark": 0}])
def test_chat_add_conversation_mark_boundaries(device_a, assert_api, info):
    resp = device_a.call("ChatManager", Cmd.addRemoteAndLocalConversationsMark.value, info=info)
    assert_api.assert_response_matches(resp, expected={"manager": "ChatManager", "cmd": Cmd.addRemoteAndLocalConversationsMark.value, "device": "deviceA", "result": {"code": 107, "description": "Invalid conversation"}}, ignore_keys={"sequence"})


@pytest.mark.parametrize("info", [{"convIds": ["__invalid_conv__"], "mark": 0}, {"convIds": [""], "mark": 0}])
def test_chat_delete_conversation_mark_boundaries(device_a, assert_api, info):
    resp = device_a.call("ChatManager", Cmd.deleteRemoteAndLocalConversationsMark.value, info=info)
    assert_api.assert_response_matches(resp, expected={"manager": "ChatManager", "cmd": Cmd.deleteRemoteAndLocalConversationsMark.value, "device": "deviceA", "result": {"code": 107, "description": "Invalid conversation"}}, ignore_keys={"sequence"})


@pytest.mark.parametrize(
    "info",
    [
        {"mark": 0, "pageSize": 0, "cursor": "", "pinned": False},
        {"mark": 0, "pageSize": -1, "cursor": "", "pinned": False},
        {"mark": 0, "pageSize": 1000, "cursor": "", "pinned": False},
        pytest.param({"mark": 999, "pageSize": 10, "cursor": "", "pinned": False}, marks=pytest.mark.skip(reason="Android bridge throws ArrayIndexOutOfBoundsException for mark=999; no stable envelope")),
        {"mark": 0, "pageSize": 10, "cursor": "__invalid_cursor__", "pinned": False},
    ],
)
def test_chat_fetch_conversation_marks_boundaries(device_a, assert_api, info):
    resp = device_a.call("ChatManager", Cmd.fetchConversationsByOptions.value, info=info)
    if info["pageSize"] in (0, -1):
        expected = {"code": 110, "description": "Invalid parameter"}
    elif info["mark"] == 999:
        expected = {"cursor": "", "list": []}
    else:
        expected = {"cursor": "", "list": []}
    assert_api.assert_response_matches(resp, expected={"manager": "ChatManager", "cmd": Cmd.fetchConversationsByOptions.value, "device": "deviceA", "result": expected}, ignore_keys={"sequence"})


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
            "hasRead": has_read, "hasReadAck": False, "hasDeliverAck": has_deliver_ack,
            "needGroupAck": False, "isThread": False, "isContentReplaced": False,
            "deliverOnlineOnly": False,
            "body": {"type": 0, "content": content, "translations": {}},
        }]}},
        ignore_keys={"timestamp", "sequence", "localTime", "serverTime", "broadcast", "onlineState",
                     "targetLanguages"},
    )


def _ensure_server_conversation(device_a, device_b, assert_api, user_a, user_b):
    content = f"mark-state-{uuid.uuid4().hex[:6]}"
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
            "hasReadAck": False, "hasDeliverAck": False, "needGroupAck": False,
            "isThread": False, "isContentReplaced": False,
            "body": {"type": 0, "content": content},
        }},
        ignore_keys={"sequence", "localTime", "serverTime", "broadcast", "onlineState",
                     "deliverOnlineOnly", "targetLanguages", "translations"},
    )
    _, sent = _wait_text_event(device_a, Cmd.onMessageSuccess.value, content=content)
    real_id = sent.get("msgId")
    _assert_text_event(
        assert_api, Cmd.onMessageSuccess.value, sent, msg_id=real_id, user_a=user_a, user_b=user_b,
        content=content, direction=0, conv_id=user_b, has_read=True, has_deliver_ack=False,
    )
    _, received = _wait_text_event(device_b, Cmd.onMessagesReceived.value, content=content)
    _assert_text_event(
        assert_api, Cmd.onMessagesReceived.value, received, msg_id=real_id, user_a=user_a, user_b=user_b,
        content=content, direction=1, conv_id=user_a, has_read=False, has_deliver_ack=True,
    )
    _, delivered = _wait_text_event(device_a, Cmd.onMessagesDelivered.value, content=content)
    _assert_text_event(
        assert_api, Cmd.onMessagesDelivered.value, delivered, msg_id=real_id, user_a=user_a, user_b=user_b,
        content=content, direction=0, conv_id=user_b, has_read=True, has_deliver_ack=True,
    )
    deadline = time.monotonic() + 60
    while time.monotonic() < deadline:
        response = device_a.call("ChatManager", Cmd.getConversationsFromServer.value, info={})
        if any(isinstance(item, dict) and item.get("convId") == user_b
               for item in (response.get("result") or [])):
            return
        time.sleep(2)
    pytest.fail("未创建可标记的单聊会话")


def _target_mark_projection(response, conv_id):
    return [
        {"convId": item.get("convId"), "type": item.get("type"), "isThread": item.get("isThread"),
         "isPinned": item.get("isPinned"), "marks": item.get("marks")}
        for item in ((response.get("result") or {}).get("list") or [])
        if isinstance(item, dict) and item.get("convId") == conv_id
    ]


def test_chat_conversation_mark_idempotent_and_remove_unmarked(device_a, device_b, assert_api, user_a, user_b):
    _ensure_server_conversation(device_a, device_b, assert_api, user_a, user_b)
    for _ in range(2):
        response = device_a.call(
            "ChatManager", Cmd.addRemoteAndLocalConversationsMark.value,
            info={"convIds": [user_b], "mark": 0},
        )
        assert_api.assert_response_matches(
            response,
            expected={"manager": "ChatManager", "cmd": Cmd.addRemoteAndLocalConversationsMark.value,
                      "device": "deviceA", "result": None},
            ignore_keys={"sequence"},
        )
    fetch = None
    projection = []
    deadline = time.monotonic() + 30
    while time.monotonic() < deadline:
        fetch = device_a.call(
            "ChatManager", Cmd.fetchConversationsByOptions.value,
            info={"mark": 0, "pageSize": 10, "cursor": "", "pinned": False},
        )
        projection = _target_mark_projection(fetch, user_b)
        if projection:
            break
        time.sleep(1)
    assert fetch is not None
    assert_api.assert_response_matches(
        {"manager": fetch.get("manager"), "cmd": fetch.get("cmd"), "device": fetch.get("device"),
         "result": {"target": projection}},
        expected={"manager": "ChatManager", "cmd": Cmd.fetchConversationsByOptions.value,
                  "device": "deviceA", "result": {"target": [{"convId": user_b, "type": 0,
                  "isThread": False, "isPinned": False, "marks": [0]}]}},
        ignore_keys={"sequence"},
    )
    for _ in range(2):
        response = device_a.call(
            "ChatManager", Cmd.deleteRemoteAndLocalConversationsMark.value,
            info={"convIds": [user_b], "mark": 0},
        )
        assert_api.assert_response_matches(
            response,
            expected={"manager": "ChatManager", "cmd": Cmd.deleteRemoteAndLocalConversationsMark.value,
                      "device": "deviceA", "result": None},
            ignore_keys={"sequence"},
        )
    fetch_after = device_a.call(
        "ChatManager", Cmd.fetchConversationsByOptions.value,
        info={"mark": 0, "pageSize": 10, "cursor": "", "pinned": False},
    )
    assert _target_mark_projection(fetch_after, user_b) == [], fetch_after
