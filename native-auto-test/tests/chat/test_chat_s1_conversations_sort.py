from __future__ import annotations

import time
import uuid

import pytest

from src import Cmd
from tests.chat._utils import build_text


pytestmark = [pytest.mark.client, pytest.mark.chat, pytest.mark.agorachat1_4_0]


def _send_text_and_get_real_id(
    device_a,
    device_b,
    assert_api,
    user_a: str,
    to_user: str,
    content: str,
    *,
    expect_receive_on_b: bool,
) -> str:
    try:
        device_a.drain_events()
        device_b.drain_events()
    except Exception:
        pass

    resp_send = device_a.call("ChatManager", Cmd.sendMessage.value, info=build_text(user_a, to_user, content))
    send_result = resp_send.get("result") or {}
    send_msg_id = send_result.get("msgId")
    assert isinstance(send_msg_id, str) and send_msg_id, f"sendMessage 未返回有效 msgId: {resp_send}"

    assert_api.assert_response_matches(
        resp_send,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.sendMessage.value,
            "device": "deviceA",
            "result": {
                "from": user_a,
                "to": to_user,
                "convId": to_user,
                "chatType": 0,
                "direction": 0,
                "hasRead": True,
                "needReadReceipt": False, "isThread": False,
                "isContentReplaced": False,
                "body": {"type": 0, "content": content},
            },
        },
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
    assert evt_success is not None, "发送端未收到 onMessageSuccess"
    success_msg = (((evt_success.get("data") or {}).get("msg")) or {})
    real_id = success_msg.get("msgId")
    assert isinstance(real_id, str) and real_id, f"未从 onMessageSuccess 获取真实 msgId: {evt_success}"
    assert_api.assert_response_matches(
        {"type": "event", "eventType": Cmd.onMessageSuccess.value, "data": {"messages": [success_msg]}},
        expected={"type": "event", "eventType": Cmd.onMessageSuccess.value, "data": {"messages": [{
            "msgId": real_id, "from": user_a, "to": to_user, "convId": to_user,
            "chatType": 0, "direction": 0, "status": 2,
            "hasRead": True, "needReadReceipt": False, "isThread": False, "isContentReplaced": False,
            "deliverOnlineOnly": False,
            "body": {"type": 0, "content": content, "translations": {}},
        }]}},
        ignore_keys={"timestamp", "sequence", "localTime", "serverTime", "broadcast", "onlineState",
                     "targetLanguages"},
    )
    if expect_receive_on_b:
        evt_received = device_b.receive_message(match_event_type=Cmd.onMessagesReceived.value, timeout=20.0)
        assert evt_received is not None, "接收端未收到 onMessagesReceived"
        received = next(
            message for message in (((evt_received.get("data") or {}).get("messages")) or [])
            if isinstance(message, dict) and str(message.get("msgId")) == str(real_id)
        )
        assert_api.assert_response_matches(
            {"type": "event", "eventType": Cmd.onMessagesReceived.value, "data": {"messages": [received]}},
            expected={"type": "event", "eventType": Cmd.onMessagesReceived.value, "data": {"messages": [{
                "msgId": real_id, "from": user_a, "to": to_user, "convId": user_a,
                "chatType": 0, "direction": 1, "status": 2,
                "hasRead": False, "needReadReceipt": False, "isThread": False, "isContentReplaced": False,
                "deliverOnlineOnly": False,
                "body": {"type": 0, "content": content, "translations": {}},
            }]}},
            ignore_keys={"timestamp", "sequence", "localTime", "serverTime", "broadcast", "onlineState",
                         "targetLanguages"},
        )

    return real_id


def _extract_conv_ids_in_order(resp: dict) -> list[str]:
    result = resp.get("result")
    if not isinstance(result, list):
        return []
    conv_ids: list[str] = []
    for item in result:
        if not isinstance(item, dict):
            continue
        conv_id = item.get("convId")
        if isinstance(conv_id, str) and conv_id:
            conv_ids.append(conv_id)
    return conv_ids


def test_chat_get_all_conversations_by_sort_orders_latest_first(device_a, device_b, assert_api, user_a, user_b):
    """
    目标：验证 ChatManager#getAllConversationsBySort 返回的会话排序正确（最新消息会话优先）。
    用 A->A 与 A->B 两个会话构造时间先后，再检查排序。
    """
    self_conv_id = user_a
    peer_conv_id = user_b

    _ = device_a.call(
        "ChatManager",
        Cmd.deleteConversation.value,
        info={"convId": self_conv_id, "deleteMessages": True},
    )
    _ = device_a.call(
        "ChatManager",
        Cmd.deleteConversation.value,
        info={"convId": peer_conv_id, "deleteMessages": True},
    )

    _send_text_and_get_real_id(
        device_a,
        device_b,
        assert_api,
        user_a,
        user_a,
        f"s1-sort-self-{uuid.uuid4().hex[:6]}",
        expect_receive_on_b=False,
    )
    time.sleep(1.0)
    _send_text_and_get_real_id(
        device_a,
        device_b,
        assert_api,
        user_a,
        user_b,
        f"s1-sort-peer-{uuid.uuid4().hex[:6]}",
        expect_receive_on_b=True,
    )
    time.sleep(1.5)

    # SDK 原生方法 key 是 loadAllConversations（内部调用 getAllConversationsBySort）
    resp_sorted = device_a.call("ChatManager", Cmd.loadAllConversations.value, info={})

    assert_api.assert_response_matches(
        resp_sorted,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.loadAllConversations.value,
            "device": "deviceA",
        },
        ignore_keys={"sequence", "result"},
    )
    conv_ids = _extract_conv_ids_in_order(resp_sorted)
    assert peer_conv_id in conv_ids, f"排序结果缺少 peer 会话: convId={peer_conv_id}, resp={resp_sorted}"
    assert self_conv_id in conv_ids, f"排序结果缺少 self 会话: convId={self_conv_id}, resp={resp_sorted}"
    assert conv_ids.index(peer_conv_id) < conv_ids.index(self_conv_id), (
        "getAllConversationsBySort 排序不符合预期（最新会话应在前）: "
        f"peer_index={conv_ids.index(peer_conv_id)}, self_index={conv_ids.index(self_conv_id)}, conv_ids={conv_ids}"
    )
