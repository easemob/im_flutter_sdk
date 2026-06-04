from __future__ import annotations

import uuid

from src import Cmd
from tests.chat._utils import build_text


def test_chat_ack_message_read_invalid_msg_id(device_b, assert_api, user_a):
    """ackMessageRead 使用无效 msgId；按不存在语义冻结。"""
    resp = device_b.call(
        "ChatManager",
        Cmd.ackMessageRead.value,
        info={"msgId": "__invalid_msg_id__", "to": user_a},
    )
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.ackMessageRead.value,
            "device": "deviceB",
            "result": {"code": 500, "description": "Message is invalid"},
        },
        ignore_keys={"sequence"},
    )


def test_chat_ack_message_read_success_with_event(device_a, device_b, assert_api, user_a, user_b):
    """ackMessageRead 正常链路：发送消息后回执并验证读回执事件。"""
    try:
        device_a.drain_events()
        device_b.drain_events()
    except Exception:
        pass

    content = f"ack-read-{uuid.uuid4().hex[:8]}"
    _ = device_a.call("ChatManager", Cmd.sendMessage.value, info=build_text(user_a, user_b, content))
    evt_success = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
    sent_real_id = (((evt_success or {}).get("data") or {}).get("msg") or {}).get("msgId")
    assert sent_real_id, f"missing real msgId from onMessageSuccess: {evt_success!r}"

    evt_received = device_b.receive_message(match_event_type=Cmd.onMessagesReceived.value, timeout=20.0)
    recv_msgs = ((evt_received or {}).get("data") or {}).get("messages") or []
    recv_msg_id = None
    for msg in recv_msgs:
        body = (msg or {}).get("body") or {}
        if (
            (msg or {}).get("from") == user_a
            and (msg or {}).get("to") == user_b
            and body.get("content") == content
            and (msg or {}).get("msgId")
        ):
            recv_msg_id = (msg or {}).get("msgId")
            break
    assert recv_msg_id, f"missing received msgId from onMessagesReceived: {evt_received!r}"

    resp_ack = device_b.call(
        "ChatManager",
        Cmd.ackMessageRead.value,
        info={"msgId": recv_msg_id, "to": user_a},
    )
    assert_api.assert_response_matches(
        resp_ack,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.ackMessageRead.value,
            "device": "deviceB",
            "result": 1,
        },
        ignore_keys={"sequence"},
    )

    assert_api.assert_response_matches(
        device_a.receive_message(match_event_type=Cmd.onMessagesRead.value, timeout=10.0),
        expected={
            "type": "event",
            "eventType": Cmd.onMessagesRead.value,
            "data": {
                "messages": [
                    {
                        "msgId": "{{msgId}}",
                        "from": "{{fromUser}}",
                        "to": "{{toUser}}",
                        "convId": "{{toUser}}",
                        "chatType": 0,
                        "direction": 0,
                        "status": 2,
                        "hasRead": True,
                        "hasReadAck": True,
                        "hasDeliverAck": False,
                        "needGroupAck": False,
                        "isThread": False,
                        "isContentReplaced": False,
                        "deliverOnlineOnly": False,
                        "body": {"type": 0, "content": "{{content}}", "translations": {}},
                    }
                ],
            },
        },
        context={"msgId": str(recv_msg_id), "fromUser": user_a, "toUser": user_b, "content": content},
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime"},
    )
