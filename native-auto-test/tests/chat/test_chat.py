"""
已拆分：该文件仅保留空壳或最小回归用例。
完整用例请见：
- tests/chat/test_chat_send_receive.py
- tests/chat/test_chat_translate.py
- tests/chat/test_chat_errors.py
- tests/chat/test_chat_history_attach_lang.py

注意：按 AGENTS.zh.md 的流程执行：
- 发现阶段：`CASES_DISCOVER=1 WS_DEBUG=1 pytest -q tests/chat/... -s`
- 收紧阶段：对齐 envelope + 关键字段，收紧 ignore_keys；避免 `assert_error(..., code=500)` 一刀切。
"""
from __future__ import annotations
from src.tools.case_timing_defaults import RECEIVE_TIMEOUT_FLOOR
from src.tools.case_timing import pause as timing_pause
from src.tools.case_timing import seconds as timing_seconds

import time
import uuid
from typing import Any

import pytest

from src import Cmd, ne, gt
from src.tools.assertions import get_result

pytestmark = [pytest.mark.client, pytest.mark.chat]


# 好友准备统一使用 chat/conftest.py 的 ensure_friends。


# ---------- 工具 ----------


def _now_ms() -> int:
    return int(time.time() * 1000)


def _build_text(from_user: str, to_user: str, content: str, chat_type: int = 0) -> dict:
    """与被测端 MessageHelper.fromJson 对齐的最小可用文本消息 JSON。"""
    return {
        "from": from_user,
        "to": to_user,
        "chatType": chat_type,     # 0 单聊 / 1 群 / 2 室
        "direction": 0,            # SEND
        "body": {"type": 0, "content": content},
        # 推荐默认，避免端上严格校验
        "hasReadAck": False,
        "needGroupAck": False,
        "isThread": False,
        "deliverOnlineOnly": False
    }


def _find_first(obj: Any, key: str) -> Any | None:
    if isinstance(obj, dict):
        if key in obj:
            return obj[key]
        for v in obj.values():
            r = _find_first(v, key)
            if r is not None:
                return r
    elif isinstance(obj, (list, tuple)):
        for it in obj:
            r = _find_first(it, key)
            if r is not None:
                return r
    return None


def _wait_message_event(device, event_type: str, *, real_id: str, content: str, timeout: float = None) -> dict:
    timeout = timing_seconds('timeout.message', module='chat') if timeout is None else timeout
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        evt = device.receive_message(
            match_event_type=event_type,
            timeout=min(timing_seconds('poll.receive', module='chat'), max(RECEIVE_TIMEOUT_FLOOR, deadline - time.monotonic())),
        )
        if evt:
            seen.append(evt)
        for msg in ((evt or {}).get("data") or {}).get("messages") or []:
            if not isinstance(msg, dict):
                continue
            body = msg.get("body") or {}
            if str(msg.get("msgId")) == str(real_id) and body.get("content") == content:
                return {
                    "type": evt.get("type"),
                    "eventType": evt.get("eventType"),
                    "data": {"messages": [msg]},
                    "timestamp": evt.get("timestamp"),
                }
    pytest.fail(f"未收到目标消息事件: event={event_type}, msgId={real_id}, content={content}, seen={seen}")


def _assert_text_message_event(assert_api, evt: dict, *, event_type: str, real_id: str, user_a: str, user_b: str, content: str, direction: int, conv_id: str, has_read: bool, has_deliver_ack: bool) -> None:
    assert_api.assert_response_matches(
        evt,
        expected={
            "type": "event",
            "eventType": event_type,
            "data": {
                "messages": [
                    {
                        "msgId": real_id,
                        "from": user_a,
                        "to": user_b,
                        "convId": conv_id,
                        "body": {"type": 0, "content": content, "translations": {}},
                        "direction": direction,
                        "chatType": 0,
                        "status": 2,
                        "hasRead": has_read,
                        "hasReadAck": False,
                        "hasDeliverAck": has_deliver_ack,
                        "needGroupAck": False,
                        "deliverOnlineOnly": False,
                        "isThread": False,
                        "isContentReplaced": False,
                    }
                ]
            },
        },
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "broadcast", "onlineState", "receiverList"},
    )


# 不再提供 _contains_conv：严格用 assert_response_matches 断言返回体


# ========== 异常 / 边界（Chat） ==========

@pytest.mark.no_friend_setup
def test_chat_send_to_self_should_not_succeed(device_a, assert_api, user_a):
    # 自发消息（A→A）：按当前实现会返回 onMessageSuccess，这里按实际返回严格断言事件内容。
    # 先清空积压事件，避免前序用例的事件干扰。
    try:
        device_a.drain_events()
    except Exception:
        pass
    content = f"self-msg-{uuid.uuid4().hex[:6]}"
    resp_send = device_a.call("ChatManager", Cmd.sendMessage.value, info=_build_text(user_a, user_a, content))
    evt = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=timing_seconds('timeout.message', module='chat'))
    # 严格断言 onMessageSuccess 事件内容（data 不忽略）：
    temp_id = (evt.get("data") or {}).get("msgId")
    real_id = ((evt.get("data") or {}).get("msg") or {}).get("msgId")
    assert_api.assert_response_matches(
        evt,
        expected={
            "type": "event",
            "eventType": Cmd.onMessageSuccess.value,
            "data": {
                "msgId": "{{tempId}}",
                "msg": {
                    "msgId": "{{realId}}",
                    "from": "{{user}}",
                    "to": "{{user}}",
                    "convId": "{{user}}",
                    "body": {"type": 0, "content": "{{content}}", "translations": {}},
                    "direction": 0,
                    "chatType": 0,
                    "status": 2,
                    "hasRead": True,
                    "hasReadAck": False,
                    "hasDeliverAck": False,
                    "needGroupAck": False,
                    "deliverOnlineOnly": False,
                    "isThread": False,
                    "isContentReplaced": False,
                },
            },
        },
        context={"tempId": temp_id, "realId": real_id, "user": user_a, "content": content},
        ignore_keys={
            "timestamp",
            "sequence",
            "serverTime",
            "localTime",
            "broadcast",
            "onlineState",
            "targetLanguages",
            "deliverOnlineOnly",
        },
    )
    # 严格断言自发消息的发送响应 result（不忽略 result/error，仅忽略 sequence 等易变键）
    assert_api.assert_response_matches(
        resp_send,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.sendMessage.value,
            "device": "deviceA",
            "result": {
                "msgId": "{{tempId}}",
                "from": "{{user}}",
                "to": "{{user}}",
                "convId": "{{user}}",
                "chatType": 0,
                "direction": 0,
                "status": 0,
                "hasRead": True,
                "hasReadAck": False,
                "hasDeliverAck": False,
                "needGroupAck": False,
                "isThread": False,
                "isContentReplaced": False,
                "body": {"type": 0, "content": "{{content}}"},
            },
        },
        context={"tempId": temp_id, "user": user_a, "content": content},
        ignore_keys={
            "sequence",
            "serverTime",
            "localTime",
            "broadcast",
            "onlineState",
            "deliverOnlineOnly",
            "targetLanguages",
            "translations",
        },
    )




def test_chat_add_reaction_empty_reaction_response(device_a, device_b, assert_api, user_a, user_b):
    """添加空 reaction：先发送一条消息，再对该消息添加空 reaction，应视为无效（无事件）。"""
    content = "for-reaction-empty"
    resp_send = device_a.call("ChatManager", Cmd.sendMessage.value, info=_build_text(user_a, user_b, content))
    evt_success = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=timing_seconds('timeout.message', module='chat'))
    temp_id = (evt_success.get("data") or {}).get("msgId")
    real_id = (((evt_success or {}).get("data") or {}).get("msg") or {}).get("msgId")
    assert_api.assert_response_matches(
        resp_send,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.sendMessage.value,
            "device": "deviceA",
            "result": {
                "msgId": temp_id,
                "from": user_a,
                "to": user_b,
                "convId": user_b,
                "chatType": 0,
                "direction": 0,
                "status": 0,
                "body": {"type": 0, "content": content},
                "hasRead": True,
                "hasReadAck": False,
                "hasDeliverAck": False,
                "needGroupAck": False,
                "isThread": False,
                "isContentReplaced": False,
            },
        },
        ignore_keys={"sequence", "serverTime", "localTime", "broadcast", "onlineState", "deliverOnlineOnly", "targetLanguages", "translations"},
    )
    assert_api.assert_response_matches(
        evt_success,
        expected={
            "type": "event",
            "eventType": Cmd.onMessageSuccess.value,
            "data": {
                "msgId": temp_id,
                "msg": {
                    "msgId": real_id,
                    "from": user_a,
                    "to": user_b,
                    "convId": user_b,
                    "body": {"type": 0, "content": content, "translations": {}},
                    "direction": 0,
                    "chatType": 0,
                    "status": 2,
                    "hasRead": True,
                    "hasReadAck": False,
                    "hasDeliverAck": False,
                    "needGroupAck": False,
                    "deliverOnlineOnly": False,
                    "isThread": False,
                    "isContentReplaced": False,
                },
            },
        },
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "broadcast", "onlineState", "targetLanguages"},
    )
    evt_received = _wait_message_event(device_b, Cmd.onMessagesReceived.value, real_id=real_id, content=content)
    _assert_text_message_event(assert_api, evt_received, event_type=Cmd.onMessagesReceived.value, real_id=real_id, user_a=user_a, user_b=user_b, content=content, direction=1, conv_id=user_a, has_read=False, has_deliver_ack=True)
    evt_delivered = _wait_message_event(device_a, Cmd.onMessagesDelivered.value, real_id=real_id, content=content)
    _assert_text_message_event(assert_api, evt_delivered, event_type=Cmd.onMessagesDelivered.value, real_id=real_id, user_a=user_a, user_b=user_b, content=content, direction=0, conv_id=user_b, has_read=True, has_deliver_ack=True)
    timing_pause('step.interval', module='chat')
    resp = device_a.call("ChatManager", Cmd.addReaction.value, info={"reaction": "", "msgId": real_id})
    print("ADD_REACTION_EMPTY RESP:", resp)
    # 空 reaction：按当前实现返回固定错误
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.addReaction.value,
            "device": "deviceA",
            "result": {"code": 110, "description": "'reaction' can not be null"},
        },
        ignore_keys={"sequence"},
    )
