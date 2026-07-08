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
    assert isinstance(send_msg_id, str) and send_msg_id, f"sendMessage 未返回有效 msgId: {resp_send}"
    real_id = send_msg_id

    assert_api.assert_response_matches(
        resp_send,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.sendMessage.value,
            "device": "deviceA",
            "result": {
                "msgId": real_id,
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
        ignore_keys={"sequence", "serverTime", "localTime", "broadcast", "onlineState", "targetLanguages", "translations"},
    )

    evt_success = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
    assert evt_success, "发送端未收到 onMessageSuccess 回调"
    assert_api.assert_response_matches(
        evt_success,
        expected={
            "type": "event",
            "eventType": Cmd.onMessageSuccess.value,
            "data": {
                "msg": {
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
                    "body": {"type": 0, "content": content},
                }
            },
        },
        ignore_keys={
            "timestamp",
            "sequence",
            "serverTime",
            "localTime",
            "translations",
            "broadcast",
            "onlineState",
            "targetLanguages",
            "receiverList",
            "msgId",
            "data.msgId",
            "data.msg.msgId",
        },
    )
    evt_success_msg = ((evt_success.get("data") or {}).get("msg")) or {}
    evt_success_body = evt_success_msg.get("body") or {}
    if (
        evt_success_msg.get("from") == user_a
        and evt_success_msg.get("to") == user_b
        and evt_success_body.get("content") == content
        and evt_success_msg.get("msgId")
    ):
        real_id = str(evt_success_msg.get("msgId"))

    evt_received = device_b.receive_message(match_event_type=Cmd.onMessagesReceived.value, timeout=20.0)
    assert evt_received, "接收端未收到 onMessagesReceived 回调"
    assert_api.assert_response_matches(
        evt_received,
        expected={
            "type": "event",
            "eventType": Cmd.onMessagesReceived.value,
            "data": {
                "messages": [
                    {
                        "from": user_a,
                        "to": user_b,
                        "convId": user_a,
                        "chatType": 0,
                        "direction": 1,
                        "status": 2,
                        "hasRead": False,
                        "hasReadAck": False,
                        "hasDeliverAck": False,
                        "needGroupAck": False,
                        "isThread": False,
                        "isContentReplaced": False,
                        "deliverOnlineOnly": False,
                        "body": {"type": 0, "content": content},
                    }
                ]
            },
        },
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "translations", "receiverList", "msgId"},
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


def test_chat_load_conversation_messages_with_keyword_success(device_a, device_b, assert_api, user_a, user_b):
    keyword = f"kw_{uuid.uuid4().hex[:10]}"
    content = f"s4-keyword-{keyword}"
    real_id = _send_text_and_get_real_id(device_a, device_b, assert_api, user_a, user_b, content)

    info = {
        "keyword": keyword,
        "timestamp": -1,
        "sender": user_a,
        "direction": 1,
        "scope": 2,
    }
    resp = None
    deadline = time.monotonic() + 30.0
    while time.monotonic() < deadline:
        resp = device_a.call("ChatManager", Cmd.loadConversationMessagesWithKeyword.value, info=info)
        result = resp.get("result") if isinstance(resp, dict) else {}
        ids = result.get(user_b) if isinstance(result, dict) else None
        if isinstance(ids, list) and real_id in ids:
            break
        time.sleep(1.0)
    assert resp is not None
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.loadConversationMessagesWithKeyword.value,
            "device": "deviceA",
            "result": {
                user_b: [real_id],
            },
        },
        ignore_keys={"sequence"},
    )


def test_chat_load_conversation_messages_with_keyword_no_hit(device_a, assert_api, user_a):
    keyword = f"kw_no_hit_{uuid.uuid4().hex[:10]}"
    resp = device_a.call(
        "ChatManager",
        Cmd.loadConversationMessagesWithKeyword.value,
        info={
            "keyword": keyword,
            "timestamp": -1,
            "sender": user_a,
            "direction": 0,
            "scope": 2,
        },
    )
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.loadConversationMessagesWithKeyword.value,
            "device": "deviceA",
            "result": {},
        },
        ignore_keys={"sequence"},
    )
