from __future__ import annotations

import uuid
from contextlib import nullcontext

import pytest

from src import Cmd
from tests.chat._utils import build_text


def _allure_step(name: str):
    try:
        import allure

        return allure.step(name)
    except ImportError:
        return nullcontext()


def _target_message(event, msg_id=None, *, content=None):
    messages = ((event or {}).get("data") or {}).get("messages") or []
    for msg in messages:
        if not isinstance(msg, dict):
            continue
        body = msg.get("body") or {}
        if msg_id is not None and str(msg.get("msgId")) != str(msg_id):
            continue
        if content is not None and body.get("content") != content:
            continue
        return msg
    return None


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
            "result": {"code": 500, "description": "The message was not found"},
        },
        ignore_keys={"sequence"},
    )


@pytest.mark.topology("account_a_to_account_b")
def test_chat_ack_message_read_success_with_event(topology, assert_api):
    """ackMessageRead 正常链路：发送消息（needReadReceipt）后接收账号全端接收，接收端回执并验证读回执事件。"""
    sender = topology.sender_action_device
    recipients = topology.recipient_devices
    action_recipient = topology.recipient_action_device
    user_a = topology.sender_user
    user_b = topology.recipient_user
    try:
        for device in (sender, *recipients):
            device.drain_events()
    except Exception:
        pass

    content = f"ack-read-{uuid.uuid4().hex[:8]}"
    # 5.0 已读回执需发送时标记 needReadReceipt（否则接收端 asyncSendMessageReadReceipts 跳过）
    msg_info = build_text(user_a, user_b, content)
    msg_info["needReadReceipt"] = True
    with _allure_step(f"{sender.device_name} 发送标记已读回执的文本消息"):
        _ = sender.call("ChatManager", Cmd.sendMessage.value, info=msg_info)
    with _allure_step(f"{sender.device_name} 验证发送成功（onMessageSuccess）"):
        evt_success = sender.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
    sent = ((evt_success or {}).get("data") or {}).get("msg") or {}
    sent_real_id = sent.get("msgId")
    assert sent_real_id, f"missing real msgId from onMessageSuccess: {evt_success!r}"
    assert_api.assert_response_matches(
        evt_success,
        expected={
            "type": "event",
            "eventType": Cmd.onMessageSuccess.value,
            "data": {
                "msgId": "{{tempId}}",
                "msg": {
                    "msgId": "{{msgId}}",
                    "from": "{{fromUser}}",
                    "to": "{{toUser}}",
                    "convId": "{{toUser}}",
                    "chatType": 0,
                    "direction": 0,
                    "status": 2,
                    "hasRead": True,
                    "needReadReceipt": True, "isThread": False,
                    "isContentReplaced": False,
                    "deliverOnlineOnly": False,
                    "body": {"type": 0, "content": "{{content}}", "translations": {}},
                },
            },
        },
        context={
            "tempId": ((evt_success or {}).get("data") or {}).get("msgId"),
            "msgId": str(sent_real_id),
            "fromUser": user_a,
            "toUser": user_b,
            "content": content,
        },
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime"},
    )

    evt_received = action_recipient.receive_message(match_event_type=Cmd.onMessagesReceived.value, timeout=20.0)
    received = _target_message(evt_received, sent_real_id, content=content)
    recv_msg_id = (received or {}).get("msgId")
    assert recv_msg_id, f"missing received msgId from onMessagesReceived: {evt_received!r}"
    for extra_recipient in recipients:
        if extra_recipient is action_recipient:
            continue
        extra_evt = extra_recipient.receive_message(match_event_type=Cmd.onMessagesReceived.value, timeout=20.0)
        extra_received = _target_message(extra_evt, sent_real_id, content=content)
        assert extra_received and extra_received.get("msgId") == recv_msg_id, (
            f"接收账号端 {extra_recipient.device_name} 未收到同一条消息: {extra_evt!r}"
        )
    assert_api.assert_response_matches(
        {"type": "event", "eventType": Cmd.onMessagesReceived.value, "data": {"messages": [received]}},
        expected={
            "type": "event",
            "eventType": Cmd.onMessagesReceived.value,
            "data": {
                "messages": [
                    {
                        "msgId": "{{msgId}}",
                        "from": "{{fromUser}}",
                        "to": "{{toUser}}",
                        "convId": "{{fromUser}}",
                        "chatType": 0,
                        "direction": 1,
                        "status": 2,
                        "hasRead": False,
                        "needReadReceipt": True, "isThread": False,
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

    with _allure_step(f"接收账号动作端 {action_recipient.device_name} 回执已读（ackMessageRead）"):
        resp_ack = action_recipient.call(
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
            "result": True,
        },
        ignore_keys={"sequence"},
    )

    assert_api.assert_response_matches(
        sender.receive_message(match_event_type=Cmd.onMessagesRead.value, timeout=10.0),
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
                        "needReadReceipt": True, "isThread": False,
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
