from __future__ import annotations

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
                "needReadReceipt": False, "isThread": False,
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
                    "needReadReceipt": False, "isThread": False,
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
                        "needReadReceipt": False, "isThread": False,
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


def _assert_loaded_messages_contains_ids(resp: dict, expected_ids: list[str], user_a: str, user_b: str) -> None:
    result = resp.get("result")
    assert isinstance(result, list), f"loadMessagesWithIds result 预期为 list: {resp}"

    id_set = set(expected_ids)
    hit: dict[str, dict] = {}
    for item in result:
        if not isinstance(item, dict):
            continue
        msg_id = item.get("msgId")
        if isinstance(msg_id, str) and msg_id in id_set:
            hit[msg_id] = item

    missing = [mid for mid in expected_ids if mid not in hit]
    assert not missing, f"loadMessagesWithIds 未命中预期消息: missing={missing}, resp={resp}"

    for mid in expected_ids:
        msg = hit[mid]
        assert msg.get("from") == user_a, f"msg.from 不匹配: expected={user_a}, msg={msg}"
        assert msg.get("to") == user_b, f"msg.to 不匹配: expected={user_b}, msg={msg}"
        assert msg.get("chatType") == 0, f"msg.chatType 不匹配: {msg}"
        assert msg.get("convId") == user_b, f"msg.convId 不匹配: expected={user_b}, msg={msg}"
        assert msg.get("direction") == 0, f"msg.direction 不匹配: {msg}"
        assert msg.get("status") == 2, f"msg.status 不匹配: {msg}"
        assert msg.get("hasRead") is True, f"msg.hasRead 不匹配: {msg}"
        assert msg.get("needReadReceipt") is False, f"msg.needReadReceipt 不匹配: {msg}"
        # 5.0 无送达回执机制 → hasDeliverAck 恒 False
        assert msg.get("hasDeliverAck") is False, f"msg.hasDeliverAck 不匹配: {msg}"
        assert msg.get("needReadReceipt") is False, f"msg.needReadReceipt 不匹配: {msg}"
        assert msg.get("isThread") is False, f"msg.isThread 不匹配: {msg}"
        assert msg.get("isContentReplaced") is False, f"msg.isContentReplaced 不匹配: {msg}"
        if "deliverOnlineOnly" in msg:
            assert msg.get("deliverOnlineOnly") is False, f"msg.deliverOnlineOnly 不匹配: {msg}"


def test_chat_load_messages_with_ids_single_and_multi_success(device_a, device_b, assert_api, user_a, user_b):
    content_1 = f"s4-load-by-ids-{uuid.uuid4().hex[:8]}-1"
    content_2 = f"s4-load-by-ids-{uuid.uuid4().hex[:8]}-2"
    msg_id_1 = _send_text_and_get_real_id(device_a, device_b, assert_api, user_a, user_b, content_1)
    msg_id_2 = _send_text_and_get_real_id(device_a, device_b, assert_api, user_a, user_b, content_2)

    # 单 ID
    resp_single = device_a.call(
        "ChatManager",
        Cmd.loadMessagesWithIds.value,
        info={
            "messageIds": [msg_id_1],
            "conversationId": user_b,
        },
    )
    assert_api.assert_response_matches(
        resp_single,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.loadMessagesWithIds.value,
            "device": "deviceA",
        },
        ignore_keys={"sequence", "result"},
    )
    _assert_loaded_messages_contains_ids(resp_single, [msg_id_1], user_a, user_b)

    # 多 ID（含不存在 ID，验证稳定忽略语义）
    resp_multi = device_a.call(
        "ChatManager",
        Cmd.loadMessagesWithIds.value,
        info={
            "messageIds": [msg_id_1, msg_id_2, "__not_exists_msg_id__"],
            "conversationId": user_b,
        },
    )
    assert_api.assert_response_matches(
        resp_multi,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.loadMessagesWithIds.value,
            "device": "deviceA",
        },
        ignore_keys={"sequence", "result"},
    )
    _assert_loaded_messages_contains_ids(resp_multi, [msg_id_1, msg_id_2], user_a, user_b)


def test_chat_load_messages_with_ids_empty_ids(device_a, assert_api, user_b):
    resp = device_a.call(
        "ChatManager",
        Cmd.loadMessagesWithIds.value,
        info={
            "messageIds": [],
            "conversationId": user_b,
        },
    )
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.loadMessagesWithIds.value,
            "device": "deviceA",
            "result": {"code": 110, "description": "Invalid parameter"},
        },
        ignore_keys={"sequence"},
    )
