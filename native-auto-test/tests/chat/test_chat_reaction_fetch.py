from __future__ import annotations

import time
import uuid
import os

from src import Cmd
from tests.chat._utils import build_text


ON_MESSAGE_REACTION_DID_CHANGE = "onMessageReactionDidChange"


def _wait_message_event(device, event_type: str, *, real_id: str, content: str, timeout: float = 30.0) -> dict:
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


def _assert_text_message_event(assert_api, evt: dict, *, event_type: str, real_id: str, user_a: str, user_b: str, content: str, direction: int, conv_id: str, has_read: bool, has_deliver_ack: bool) -> None:
    assert_api.assert_response_matches(
        evt,
        expected={
            "type": "event",
            "eventType": event_type,
            "data": {
                "messages": [
                    {
                        "msgId": str(real_id),
                        "from": user_a,
                        "to": user_b,
                        "convId": conv_id,
                        "chatType": 0,
                        "direction": direction,
                        "status": 2,
                        "hasRead": has_read,
                        "hasReadAck": False,
                        "hasDeliverAck": has_deliver_ack,
                        "needGroupAck": False,
                        "isThread": False,
                        "isContentReplaced": False,
                        "deliverOnlineOnly": False,
                        "body": {"type": 0, "content": content, "translations": {}},
                    }
                ],
            },
        },
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "receiverList", "broadcast", "onlineState"},
    )


def _wait_reaction_change_event(device, *, real_id: str, operator: str, reaction: str, is_added_by_self: bool, timeout: float = 60.0) -> dict:
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        evt = device.receive_message(
            match_event_type=ON_MESSAGE_REACTION_DID_CHANGE,
            timeout=min(2.0, max(0.1, deadline - time.monotonic())),
        )
        if evt:
            seen.append(evt)
        for event in ((evt or {}).get("data") or {}).get("events") or []:
            if not isinstance(event, dict):
                continue
            operations = event.get("operations") or []
            reactions = event.get("reactions") or []
            matched_operation = next(
                (
                    op
                    for op in operations
                    if isinstance(op, dict)
                    and op.get("userId") == operator
                    and op.get("reaction") == reaction
                    and op.get("operate") == 1
                ),
                None,
            )
            matched_reaction = next(
                (
                    item
                    for item in reactions
                    if isinstance(item, dict)
                    and item.get("reaction") == reaction
                    and item.get("count") == 1
                    and item.get("isAddedBySelf") == is_added_by_self
                    and item.get("userList") == [operator]
                ),
                None,
            )
            if str(event.get("msgId")) == str(real_id) and matched_operation and matched_reaction:
                return {
                    "type": evt.get("type"),
                    "eventType": evt.get("eventType"),
                    "data": {
                        "events": [
                            {
                                "convId": event.get("convId"),
                                "msgId": event.get("msgId"),
                                "operations": [matched_operation],
                                "reactions": [matched_reaction],
                            },
                        ],
                    },
                    "timestamp": evt.get("timestamp"),
                }
    raise AssertionError(
        "未收到目标 reaction 事件: "
        f"msgId={real_id}, operator={operator}, reaction={reaction!r}, "
        f"isAddedBySelf={is_added_by_self}, events={seen}"
    )


def _assert_reaction_change_event(assert_api, device, *, conv_id: str, real_id: str, operator: str, reaction: str, is_added_by_self: bool) -> None:
    evt = _wait_reaction_change_event(
        device,
        real_id=real_id,
        operator=operator,
        reaction=reaction,
        is_added_by_self=is_added_by_self,
    )
    assert_api.assert_response_matches(
        evt,
        expected={
            "type": "event",
            "eventType": ON_MESSAGE_REACTION_DID_CHANGE,
            "data": {
                "events": [
                    {
                        "convId": conv_id,
                        "msgId": real_id,
                        "operations": [
                            {"userId": operator, "reaction": reaction, "operate": 1},
                        ],
                        "reactions": [
                            {"reaction": reaction, "count": 1, "isAddedBySelf": is_added_by_self, "userList": [operator]},
                        ],
                    },
                ],
            },
        },
        ignore_keys={"timestamp"},
    )


def _send_text_and_wait_received(device_a, device_b, assert_api, user_a: str, user_b: str, content: str) -> str:
    try:
        device_a.drain_events()
        device_b.drain_events()
    except Exception:
        pass

    resp = device_a.call("ChatManager", Cmd.sendMessage.value, info=build_text(user_a, user_b, content))
    temp_id = ((resp.get("result") or {}).get("msgId"))
    assert temp_id, f"sendMessage 未返回临时 msgId: {resp}"
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.sendMessage.value,
            "device": "deviceA",
            "result": {
                "msgId": str(temp_id),
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
        ignore_keys={"sequence", "serverTime", "localTime", "broadcast", "onlineState", "deliverOnlineOnly", "targetLanguages", "translations"},
    )
    evt_success = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
    real_id = (((evt_success or {}).get("data") or {}).get("msg") or {}).get("msgId")
    assert real_id, f"missing real msgId from onMessageSuccess: {evt_success!r}"
    assert_api.assert_response_matches(
        evt_success,
        expected={
            "type": "event",
            "eventType": Cmd.onMessageSuccess.value,
            "data": {
                "msgId": str(temp_id),
                "msg": {
                    "msgId": str(real_id),
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
                    "body": {"type": 0, "content": content, "translations": {}},
                },
            },
        },
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "broadcast", "onlineState"},
    )

    evt_received = _wait_message_event(device_b, Cmd.onMessagesReceived.value, real_id=real_id, content=content)
    _assert_text_message_event(assert_api, evt_received, event_type=Cmd.onMessagesReceived.value, real_id=real_id, user_a=user_a, user_b=user_b, content=content, direction=1, conv_id=user_a, has_read=False, has_deliver_ack=True)
    evt_delivered = _wait_message_event(device_a, Cmd.onMessagesDelivered.value, real_id=real_id, content=content)
    _assert_text_message_event(assert_api, evt_delivered, event_type=Cmd.onMessagesDelivered.value, real_id=real_id, user_a=user_a, user_b=user_b, content=content, direction=0, conv_id=user_b, has_read=True, has_deliver_ack=True)
    return str(real_id)


def test_chat_reaction_change_event_received_by_sender(device_a, device_b, assert_api, user_a, user_b):
    """addReaction：接收方给单聊消息添加 reaction，发送方和接收方均收到 onMessageReactionDidChange 事件。"""
    reaction = f"r_{uuid.uuid4().hex[:6]}"
    real_id = _send_text_and_wait_received(
        device_a,
        device_b,
        assert_api,
        user_a,
        user_b,
        f"reaction-event-{uuid.uuid4().hex[:8]}",
    )
    time.sleep(float(os.getenv("CHAT_REACTION_SETTLE_SECONDS", "10")))

    resp = device_b.call("ChatManager", Cmd.addReaction.value, info={"reaction": reaction, "msgId": real_id})
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.addReaction.value,
            "device": "deviceB",
            "result": None,
        },
        ignore_keys={"sequence"},
    )

    _assert_reaction_change_event(assert_api, device_a, conv_id=user_b, real_id=real_id, operator=user_b, reaction=reaction, is_added_by_self=False)
    _assert_reaction_change_event(assert_api, device_b, conv_id=user_a, real_id=real_id, operator=user_b, reaction=reaction, is_added_by_self=True)


def test_chat_fetch_reaction_list_invalid_msg_id(device_a, assert_api):
    """fetchReactionList 传入不存在的 msgId 列表；先断言信封。"""
    # Flutter 端签名要求 chatType 必填；请求体键名为 msgIds。
    info = {"msgIds": ["__invalid_msg_id__"], "chatType": 0}
    resp = device_a.call("ChatManager", Cmd.fetchReactionList.value, info=info)
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.fetchReactionList.value,
            "device": "deviceA",
            "result": {"__invalid_msg_id__": []},
        },
        ignore_keys={"sequence"},
    )


def test_chat_fetch_reaction_list_empty_msg_ids(device_a, assert_api):
    """fetchReactionList 传入空 msgIds；应返回参数错误。"""
    info = {"msgIds": [], "chatType": 0}
    resp = device_a.call("ChatManager", Cmd.fetchReactionList.value, info=info)
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.fetchReactionList.value,
            "device": "deviceA",
            "result": {"code": 110, "description": "'messageIdList' can not be null"},
        },
        ignore_keys={"sequence"},
    )


def test_chat_fetch_reaction_list_invalid_chat_type(device_a, assert_api):
    """fetchReactionList 传入非法 chatType；当前实现返回空 reaction 列表映射。"""
    info = {"msgIds": ["__invalid_msg_id__"], "chatType": -1}
    resp = device_a.call("ChatManager", Cmd.fetchReactionList.value, info=info)
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.fetchReactionList.value,
            "device": "deviceA",
            "result": {"__invalid_msg_id__": []},
        },
        ignore_keys={"sequence"},
    )


def test_chat_fetch_reaction_detail_invalid(device_a, assert_api):
    """fetchReactionDetail 使用无效 msgId/reaction；先校验信封。"""
    # 原生 wrapper 将 pageSize 按必填读取（Android: getInt），缺失会直接抛参错。
    info = {"msgId": "__invalid_msg_id__", "reaction": "👍", "pageSize": 20}
    resp = device_a.call("ChatManager", Cmd.fetchReactionDetail.value, info=info)
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.fetchReactionDetail.value,
            "device": "deviceA",
            "result": {"cursor": "", "list": []},
        },
        ignore_keys={"sequence"},
    )


def test_chat_fetch_reaction_detail_invalid_page_size(device_a, device_b, assert_api, user_a, user_b):
    """fetchReactionDetail 非法 pageSize（-1）；应返回参数错误。"""
    try:
        device_a.drain_events()
        device_b.drain_events()
    except Exception:
        pass

    real_id = _send_text_and_wait_received(
        device_a, device_b, assert_api, user_a, user_b, "reaction-detail-invalid-page-size"
    )

    info = {"msgId": real_id, "reaction": "👍", "pageSize": -1}
    resp = device_a.call("ChatManager", Cmd.fetchReactionDetail.value, info=info)
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.fetchReactionDetail.value,
            "device": "deviceA",
            "result": {"code": 303, "description": "Unknown server error"},
        },
        ignore_keys={"sequence"},
    )


def test_chat_fetch_reaction_detail_empty_reaction(device_a, device_b, assert_api, user_a, user_b):
    """fetchReactionDetail 传入空 reaction；应返回参数错误。"""
    try:
        device_a.drain_events()
        device_b.drain_events()
    except Exception:
        pass

    real_id = _send_text_and_wait_received(
        device_a, device_b, assert_api, user_a, user_b, "reaction-detail-empty-reaction"
    )

    info = {"msgId": real_id, "reaction": "", "pageSize": 20}
    resp = device_a.call("ChatManager", Cmd.fetchReactionDetail.value, info=info)
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.fetchReactionDetail.value,
            "device": "deviceA",
            "result": {"code": 110, "description": "'reaction' can not be null"},
        },
        ignore_keys={"sequence"},
    )


def test_chat_fetch_reaction_detail_oversize_page_size(device_a, device_b, assert_api, user_a, user_b):
    """fetchReactionDetail 过大 pageSize（1000）；应返回稳定结果结构。"""
    try:
        device_a.drain_events()
        device_b.drain_events()
    except Exception:
        pass

    real_id = _send_text_and_wait_received(
        device_a, device_b, assert_api, user_a, user_b, "reaction-detail-oversize-page-size"
    )

    info = {"msgId": real_id, "reaction": "👍", "pageSize": 1000}
    resp = device_a.call("ChatManager", Cmd.fetchReactionDetail.value, info=info)
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.fetchReactionDetail.value,
            "device": "deviceA",
            "result": {"code": 110, "description": "Limit exceeds the maximum quantity limit"},
        },
        ignore_keys={"sequence"},
    )


def test_chat_add_reaction_duplicate_reaction(device_a, device_b, assert_api, user_a, user_b):
    """addReaction 重复添加同一 reaction；按被测端实际语义冻结。"""
    try:
        device_a.drain_events()
        device_b.drain_events()
    except Exception:
        pass

    real_id = _send_text_and_wait_received(
        device_a, device_b, assert_api, user_a, user_b, "reaction-duplicate"
    )
    time.sleep(5)

    reaction = "👍"
    resp_add_first = device_a.call("ChatManager", Cmd.addReaction.value, info={"reaction": reaction, "msgId": real_id})
    assert_api.assert_response_matches(
        resp_add_first,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.addReaction.value,
            "device": "deviceA",
            "result": None,
        },
        ignore_keys={"sequence"},
    )
    _assert_reaction_change_event(assert_api, device_a, conv_id=user_b, real_id=real_id, operator=user_a, reaction=reaction, is_added_by_self=True)
    _assert_reaction_change_event(assert_api, device_b, conv_id=user_a, real_id=real_id, operator=user_a, reaction=reaction, is_added_by_self=False)

    resp_add_second = device_a.call("ChatManager", Cmd.addReaction.value, info={"reaction": reaction, "msgId": real_id})
    assert_api.assert_response_matches(
        resp_add_second,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.addReaction.value,
            "device": "deviceA",
            "result": {"code": 1301, "description": "the user is already operation this message"},
        },
        ignore_keys={"sequence"},
    )


def test_chat_remove_reaction_not_exists_reaction(device_a, device_b, assert_api, user_a, user_b):
    """removeReaction 删除不存在的 reaction；按被测端实际语义冻结。"""
    try:
        device_a.drain_events()
        device_b.drain_events()
    except Exception:
        pass

    real_id = _send_text_and_wait_received(
        device_a, device_b, assert_api, user_a, user_b, "reaction-remove-not-exists"
    )

    resp = device_a.call("ChatManager", Cmd.removeReaction.value, info={"reaction": "👍", "msgId": real_id})
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.removeReaction.value,
            "device": "deviceA",
            "result": None,
        },
        ignore_keys={"sequence"},
    )


def test_chat_remove_reaction_invalid_msg_id(device_a, assert_api):
    """removeReaction 使用无效 msgId；按不存在语义冻结。"""
    resp = device_a.call("ChatManager", Cmd.removeReaction.value, info={"reaction": "👍", "msgId": "__invalid_msg_id__"})
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.removeReaction.value,
            "device": "deviceA",
            "result": None,
        },
        ignore_keys={"sequence"},
    )


def test_chat_add_reaction_too_long_reaction(device_a, device_b, assert_api, user_a, user_b):
    """addReaction 超长 reaction；按被测端实际语义冻结。"""
    try:
        device_a.drain_events()
        device_b.drain_events()
    except Exception:
        pass

    real_id = _send_text_and_wait_received(
        device_a, device_b, assert_api, user_a, user_b, "reaction-too-long"
    )

    reaction_128 = "a" * 128
    resp_128 = device_a.call("ChatManager", Cmd.addReaction.value, info={"reaction": reaction_128, "msgId": real_id})
    assert_api.assert_response_matches(
        resp_128,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.addReaction.value,
            "device": "deviceA",
            "result": None,
        },
        ignore_keys={"sequence"},
    )
    _assert_reaction_change_event(assert_api, device_a, conv_id=user_b, real_id=real_id, operator=user_a, reaction=reaction_128, is_added_by_self=True)
    _assert_reaction_change_event(assert_api, device_b, conv_id=user_a, real_id=real_id, operator=user_a, reaction=reaction_128, is_added_by_self=False)

    reaction_256 = "b" * 256
    resp_256 = device_a.call("ChatManager", Cmd.addReaction.value, info={"reaction": reaction_256, "msgId": real_id})
    assert_api.assert_response_matches(
        resp_256,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.addReaction.value,
            "device": "deviceA",
            "result": None,
        },
        ignore_keys={"sequence"},
    )
    _assert_reaction_change_event(assert_api, device_a, conv_id=user_b, real_id=real_id, operator=user_a, reaction=reaction_256, is_added_by_self=True)
    _assert_reaction_change_event(assert_api, device_b, conv_id=user_a, real_id=real_id, operator=user_a, reaction=reaction_256, is_added_by_self=False)


def test_chat_add_reaction_special_char_reaction(device_a, device_b, assert_api, user_a, user_b):
    """addReaction 特殊字符 reaction；按被测端实际语义冻结。"""
    try:
        device_a.drain_events()
        device_b.drain_events()
    except Exception:
        pass

    real_id = _send_text_and_wait_received(
        device_a, device_b, assert_api, user_a, user_b, "reaction-special-char"
    )

    reaction = "\n\t"
    resp = device_a.call("ChatManager", Cmd.addReaction.value, info={"reaction": reaction, "msgId": real_id})
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.addReaction.value,
            "device": "deviceA",
            "result": None,
        },
        ignore_keys={"sequence"},
    )
    _assert_reaction_change_event(assert_api, device_a, conv_id=user_b, real_id=real_id, operator=user_a, reaction=reaction, is_added_by_self=True)
    _assert_reaction_change_event(assert_api, device_b, conv_id=user_a, real_id=real_id, operator=user_a, reaction=reaction, is_added_by_self=False)
