from __future__ import annotations

import time
import uuid

import pytest

from src import Cmd
from tests.chat._utils import build_text

pytestmark = [pytest.mark.client, pytest.mark.chat]


def _assert_call(assert_api, response, *, manager, cmd, device, result):
    assert_api.assert_response_matches(
        response,
        expected={"manager": manager, "cmd": cmd, "device": device, "result": result},
        ignore_keys={"sequence"},
    )


def _switch_user(device, assert_api, *, device_name, user_id):
    logout = device.call("Client", Cmd.logout.value, info={"unbindToken": False})
    _assert_call(assert_api, logout, manager="Client", cmd=Cmd.logout.value, device=device_name, result=True)
    login = device.call(
        "Client", Cmd.login.value,
        info={"userId": user_id, "pwdOrToken": "1", "isPassword": True},
    )
    _assert_call(assert_api, login, manager="Client", cmd=Cmd.login.value, device=device_name, result=user_id)
    callback = device.call("Client", Cmd.startCallback.value, info={})
    _assert_call(assert_api, callback, manager="Client", cmd=Cmd.startCallback.value, device=device_name, result=None)
    device.drain_events()


def _ensure_friend(device_a, device_b, assert_api, *, user_a, peer):
    contacts = device_a.call("ContactManager", Cmd.getAllContactsFromServer.value, info={})
    if peer in (contacts.get("result") or []):
        return
    add = device_a.call(
        "ContactManager", Cmd.addContact.value,
        info={"userId": peer, "reason": "conversation-pagination"},
    )
    _assert_call(assert_api, add, manager="ContactManager", cmd=Cmd.addContact.value,
                 device="deviceA", result=peer)
    device_b.receive_message(match_event_type="onContactInvited", timeout=10)
    accept = device_b.call("ContactManager", Cmd.acceptInvitation.value, info={"userId": user_a})
    _assert_call(assert_api, accept, manager="ContactManager", cmd=Cmd.acceptInvitation.value,
                 device="deviceB", result=user_a)


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


def _assert_text_event(assert_api, event_type, message, *, msg_id, user_a, peer,
                       content, direction, conv_id, has_read, has_deliver_ack):
    assert_api.assert_response_matches(
        {"type": "event", "eventType": event_type, "data": {"messages": [message]}},
        expected={"type": "event", "eventType": event_type, "data": {"messages": [{
            "msgId": msg_id, "from": user_a, "to": peer, "convId": conv_id,
            "chatType": 0, "direction": direction, "status": 2,
            "hasRead": has_read, "hasReadAck": False, "hasDeliverAck": has_deliver_ack,
            "needGroupAck": False, "isThread": False, "isContentReplaced": False,
            "deliverOnlineOnly": False,
            "body": {"type": 0, "content": content, "translations": {}},
        }]}},
        ignore_keys={"timestamp", "sequence", "localTime", "serverTime", "broadcast", "onlineState",
                     "targetLanguages"},
    )


def _send_and_wait_server_conversation(device_a, device_b, assert_api, *, user_a, peer):
    content = f"cursor-conversation-{peer}-{uuid.uuid4().hex[:6]}"
    device_a.drain_events()
    device_b.drain_events()
    response = device_a.call("ChatManager", Cmd.sendMessage.value, info=build_text(user_a, peer, content))
    temp_id = ((response.get("result") or {}).get("msgId"))
    assert temp_id, response
    assert_api.assert_response_matches(
        response,
        expected={"manager": "ChatManager", "cmd": Cmd.sendMessage.value, "device": "deviceA", "result": {
            "msgId": temp_id, "from": user_a, "to": peer, "convId": peer,
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
        assert_api, Cmd.onMessageSuccess.value, sent, msg_id=real_id, user_a=user_a, peer=peer,
        content=content, direction=0, conv_id=peer, has_read=True, has_deliver_ack=False,
    )
    _, received = _wait_text_event(device_b, Cmd.onMessagesReceived.value, content=content)
    _assert_text_event(
        assert_api, Cmd.onMessagesReceived.value, received, msg_id=real_id, user_a=user_a, peer=peer,
        content=content, direction=1, conv_id=user_a, has_read=False, has_deliver_ack=True,
    )
    _, delivered = _wait_text_event(device_a, Cmd.onMessagesDelivered.value, content=content)
    _assert_text_event(
        assert_api, Cmd.onMessagesDelivered.value, delivered, msg_id=real_id, user_a=user_a, peer=peer,
        content=content, direction=0, conv_id=peer, has_read=True, has_deliver_ack=True,
    )
    deadline = time.monotonic() + 60
    while time.monotonic() < deadline:
        conversations = device_a.call("ChatManager", Cmd.getConversationsFromServer.value, info={})
        if any(isinstance(item, dict) and item.get("convId") == peer
               for item in (conversations.get("result") or [])):
            return
        time.sleep(2)
    pytest.fail(f"服务端未建立目标会话: {peer}")


def _page_projection(response):
    return [
        {"convId": item.get("convId"), "type": item.get("type"),
         "isPinned": item.get("isPinned"), "isThread": item.get("isThread"),
         "marks": item.get("marks")}
        for item in ((response.get("result") or {}).get("list") or [])
        if isinstance(item, dict)
    ]


def test_chat_conversation_pinned_and_marked_cursor_pagination(
    device_a, device_b, assert_api, user_a, user_b, user_c,
):
    _send_and_wait_server_conversation(device_a, device_b, assert_api, user_a=user_a, peer=user_b)
    _switch_user(device_b, assert_api, device_name="deviceB", user_id=user_c)
    try:
        _ensure_friend(device_a, device_b, assert_api, user_a=user_a, peer=user_c)
        _send_and_wait_server_conversation(device_a, device_b, assert_api, user_a=user_a, peer=user_c)

        for index, peer in enumerate((user_b, user_c)):
            pin = device_a.call(
                "ChatManager", Cmd.pinConversation.value,
                info={"convId": peer, "isPinned": True},
            )
            _assert_call(assert_api, pin, manager="ChatManager", cmd=Cmd.pinConversation.value,
                         device="deviceA", result=None)
            # 服务端游标按秒级 pinnedTime 翻页；同一秒置顶两条会话会让
            # 第二页漏掉同时间戳记录。真实业务操作也会自然跨时刻，这里显式
            # 拉开置顶时间，保证用例验证的是 cursor，而不是时间戳碰撞。
            if index == 0:
                time.sleep(1.1)

        deadline = time.monotonic() + 30
        pinned_by_peer = {}
        while time.monotonic() < deadline:
            conversations = device_a.call("ChatManager", Cmd.getConversationsFromServer.value, info={})
            pinned_by_peer = {
                item.get("convId"): item
                for item in (conversations.get("result") or [])
                if isinstance(item, dict) and item.get("convId") in {user_b, user_c}
            }
            if len(pinned_by_peer) == 2 and all(item.get("isPinned") is True for item in pinned_by_peer.values()):
                break
            time.sleep(1)
        assert set(pinned_by_peer) == {user_b, user_c}, conversations
        assert all(item["type"] == 0 and item["isThread"] is False for item in pinned_by_peer.values())

        first = device_a.call(
            "ChatManager", Cmd.fetchConversationsByOptions.value,
            info={"pageSize": 1, "cursor": "", "pinned": True},
        )
        first_result = first.get("result") or {}
        assert first_result.get("cursor"), first
        first_page = _page_projection(first)
        assert len(first_page) == 1 and first_page[0]["convId"] in {user_b, user_c}, first
        assert first_page[0]["type"] == 0 and first_page[0]["isPinned"] is True
        second = device_a.call(
            "ChatManager", Cmd.fetchConversationsByOptions.value,
            info={"pageSize": 1, "cursor": first_result["cursor"], "pinned": True},
        )
        second_page = _page_projection(second)
        assert len(second_page) == 1, second
        assert {first_page[0]["convId"], second_page[0]["convId"]} == {user_b, user_c}
        assert second_page[0]["type"] == 0 and second_page[0]["isPinned"] is True

        mark_by_peer = {user_b: 0, user_c: 1}
        for peer, mark in mark_by_peer.items():
            add = device_a.call(
                "ChatManager", Cmd.addRemoteAndLocalConversationsMark.value,
                info={"convIds": [peer], "mark": mark},
            )
            _assert_call(assert_api, add, manager="ChatManager",
                         cmd=Cmd.addRemoteAndLocalConversationsMark.value, device="deviceA", result=None)

        found = {}
        for mark, expected_peer in ((0, user_b), (1, user_c)):
            deadline = time.monotonic() + 30
            response = None
            while time.monotonic() < deadline:
                response = device_a.call(
                    "ChatManager", Cmd.fetchConversationsByOptions.value,
                    info={"mark": mark, "pageSize": 1, "cursor": "", "pinned": False},
                )
                page = _page_projection(response)
                if any(item["convId"] == expected_peer and mark in (item["marks"] or []) for item in page):
                    found[mark] = expected_peer
                    break
                time.sleep(1)
            assert response is not None and found.get(mark) == expected_peer, response
        assert found == {0: user_b, 1: user_c}
    finally:
        for peer in (user_b, user_c):
            device_a.call("ChatManager", Cmd.pinConversation.value, info={"convId": peer, "isPinned": False})
        device_a.call("ChatManager", Cmd.deleteRemoteAndLocalConversationsMark.value,
                      info={"convIds": [user_b], "mark": 0})
        device_a.call("ChatManager", Cmd.deleteRemoteAndLocalConversationsMark.value,
                      info={"convIds": [user_c], "mark": 1})
        _switch_user(device_b, assert_api, device_name="deviceB", user_id=user_b)
