from __future__ import annotations

import time
import uuid
import os
from contextlib import nullcontext

import pytest

from src import Cmd
from tests.chat._utils import build_text


ON_MESSAGE_REACTION_DID_CHANGE = Cmd.onMessageReactionDidChange.value


def _allure_step(name: str):
    try:
        import allure

        return allure.step(name)
    except ImportError:
        return nullcontext()


def _wait_message_event(device, event_type: str, *, real_id: str, content: str, expected_message_count: int = 1, timeout: float = 30.0) -> dict:
    deadline = time.monotonic() + timeout
    seen = []
    matched_messages = []
    while time.monotonic() < deadline:
        evt = device.receive_message(match_event_type=event_type, timeout=min(2.0, max(0.1, deadline - time.monotonic())))
        if evt:
            seen.append(evt)
        for msg in ((evt or {}).get("data") or {}).get("messages") or []:
            if not isinstance(msg, dict):
                continue
            if str(msg.get("msgId")) == str(real_id) and ((msg.get("body") or {}).get("content") == content):
                matched_messages.append(msg)
        if len(matched_messages) >= expected_message_count:
            filtered_event = {
                "type": evt.get("type"),
                "eventType": evt.get("eventType"),
                "data": {"messages": matched_messages},
                "timestamp": evt.get("timestamp"),
            }
            source_device = getattr(evt, "_allure_source_device", None)
            if source_device:
                return evt.__class__(
                    filtered_event,
                    source_device=source_device,
                )
            return filtered_event
    raise AssertionError(f"未收到目标消息事件: event={event_type}, msgId={real_id}, content={content}, events={seen}")


def _assert_text_message_event(assert_api, evt: dict, *, event_type: str, real_id: str, user_a: str, user_b: str, content: str, direction: int, conv_id: str, has_read: bool, has_deliver_ack: bool | None, expected_message_count: int = 1) -> None:
    message = {
        "msgId": str(real_id),
        "from": user_a,
        "to": user_b,
        "convId": conv_id,
        "chatType": 0,
        "direction": direction,
        "status": 2,
        "hasRead": has_read,
        "needReadReceipt": False,
        "isThread": False,
        "isContentReplaced": False,
        "deliverOnlineOnly": False,
        "body": {"type": 0, "content": content},
    }
    ignore_keys = {"timestamp", "sequence", "serverTime", "localTime", "broadcast", "onlineState", "translations"}
    if has_deliver_ack is None:
        ignore_keys.add("hasDeliverAck")
    else:
        message["hasDeliverAck"] = has_deliver_ack
    assert_api.assert_event_matches(
        evt,
        expected={
            "type": "event",
            "eventType": event_type,
            "data": {
                "messages": [
                    message
                    for _ in range(expected_message_count)
                ],
            },
        },
        ignore_keys=ignore_keys,
    )


def _assert_message_lookup(assert_api, response: dict, *, device_name: str, real_id: str, user_a: str, user_b: str, content: str, direction: int, conv_id: str, has_read: bool) -> None:
    assert_api.assert_response_matches(
        response,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.getMessage.value,
            "device": device_name,
            "result": {
                "msgId": str(real_id), "from": user_a, "to": user_b,
                "convId": conv_id, "chatType": 0, "direction": direction,
                "status": 2, "hasRead": has_read, "needReadReceipt": False,  "isThread": False, "isContentReplaced": False,
                "body": {"type": 0, "content": content},
            },
        },
        ignore_keys={
            "sequence", "serverTime", "localTime", "broadcast", "onlineState",
            "deliverOnlineOnly", "targetLanguages", "translations", "hasDeliverAck",
            "receiverList", "groupAckCount",
        },
        allow_extra_fields=True,
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
            "device": sender.device_name,
            "result": {
                "msgId": str(temp_id),
                "from": user_a,
                "to": user_b,
                "convId": user_b,
                "chatType": 0,
                "direction": 0,
                "hasRead": True,
                "needReadReceipt": False, "isThread": False,
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
                    "needReadReceipt": False, "isThread": False,
                    "isContentReplaced": False,
                    "deliverOnlineOnly": False,
                    "body": {"type": 0, "content": content, "translations": {}},
                },
            },
        },
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "broadcast", "onlineState"},
    )

    evt_received = _wait_message_event(device_b, Cmd.onMessagesReceived.value, real_id=real_id, content=content)
    _assert_text_message_event(assert_api, evt_received, event_type=Cmd.onMessagesReceived.value, real_id=real_id, user_a=user_a, user_b=user_b, content=content, direction=1, conv_id=user_a, has_read=False, has_deliver_ack=None)
    return str(real_id)


@pytest.mark.topology("account_a_to_account_b")
def test_chat_reaction_change_event_received_by_sender(topology, assert_api):
    """单聊消息与 reaction 在收发账号多端同步，并校验各在线端的变更回调。"""
    sender = topology.sender_action_device
    sender_devices = topology.sender_devices
    recipient_action = topology.recipient_action_device
    recipients = topology.recipient_devices
    sender_user = topology.sender_user
    recipient_user = topology.recipient_user
    content = f"reaction-event-{uuid.uuid4().hex[:8]}"
    reaction = f"r_{uuid.uuid4().hex[:6]}"

    with _allure_step("测试准备：清理动作账号和接收账号的历史事件"):
        for device in (*sender_devices, *topology.recipient_devices):
            device.drain_events(timeout=0.5)

    with _allure_step(f"{sender.device_name} 向接收账号发送待 reaction 的文本消息"):
        response = sender.call(
            "ChatManager",
            Cmd.sendMessage.value,
            info=build_text(sender_user, recipient_user, content),
        )
    temp_id = ((response.get("result") or {}).get("msgId"))
    assert temp_id, f"sendMessage 未返回临时 msgId: {response}"
    with _allure_step("确认文本消息已提交"):
        assert_api.assert_response_matches(
            response,
            expected={
                "manager": "ChatManager", "cmd": Cmd.sendMessage.value,
                "device": sender.device_name,
                "result": {
                    "msgId": str(temp_id), "from": sender_user, "to": recipient_user,
                    "convId": recipient_user, "chatType": 0, "direction": 0,
                    "hasRead": True, "needReadReceipt": False,  "isThread": False,
                    "isContentReplaced": False, "body": {"type": 0, "content": content},
                },
            },
            ignore_keys={"sequence", "serverTime", "localTime", "broadcast", "onlineState", "deliverOnlineOnly", "targetLanguages", "translations", "result.hasDeliverAck"},
        )

    with _allure_step(f"等待 {sender.device_name} 的发送成功回调（onMessageSuccess）"):
        success = sender.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
    real_id = (((success or {}).get("data") or {}).get("msg") or {}).get("msgId")
    assert real_id, f"onMessageSuccess 未返回真实 msgId: {success!r}"
    with _allure_step("确认文本消息发送成功"):
        assert_api.assert_response_matches(
            success,
            expected={
                "type": "event", "eventType": Cmd.onMessageSuccess.value,
                "data": {"msgId": str(temp_id), "msg": {
                    "msgId": str(real_id), "from": sender_user, "to": recipient_user,
                    "convId": recipient_user, "chatType": 0, "direction": 0,
                    "status": 2, "hasRead": True, "needReadReceipt": False,  "isThread": False,
                    "isContentReplaced": False, "deliverOnlineOnly": False,
                    "body": {"type": 0, "content": content, "translations": {}},
                }},
            },
            ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "broadcast", "onlineState", "data.msg.hasDeliverAck"},
        )

    for role, sender_device in zip(topology.sender_roles, sender_devices):
        if sender_device is sender:
            continue
        with _allure_step(f"发送账号端 {sender_device.device_name} 同步原消息（onMessagesReceived）"):
            synced = _wait_message_event(
                sender_device,
                Cmd.onMessagesReceived.value,
                real_id=str(real_id),
                content=content,
            )
        with _allure_step(f"确认发送账号端 {sender_device.device_name} 已同步原消息"):
            _assert_text_message_event(
                assert_api, synced, event_type=Cmd.onMessagesReceived.value,
                real_id=str(real_id), user_a=sender_user, user_b=recipient_user,
                content=content, direction=0, conv_id=recipient_user,
                has_read=True, has_deliver_ack=None,
            )
        with _allure_step(f"发送账号端 {sender_device.device_name} 从本地消息库查询原消息"):
            _assert_message_lookup(
                assert_api,
                sender_device.call("ChatManager", Cmd.getMessage.value, info={"msgId": str(real_id)}),
                device_name=sender_device.device_name, real_id=str(real_id),
                user_a=sender_user, user_b=recipient_user, content=content,
                direction=0, conv_id=recipient_user, has_read=True,
            )

    for role, recipient in zip(topology.recipient_roles, recipients):
        with _allure_step(f"接收账号端 {recipient.device_name} 收到待 reaction 的文本（onMessagesReceived）"):
            received = _wait_message_event(
                recipient,
                Cmd.onMessagesReceived.value,
                real_id=str(real_id),
                content=content,
            )
        with _allure_step(f"确认接收账号端 {recipient.device_name} 收到当前文本"):
            _assert_text_message_event(
                assert_api, received, event_type=Cmd.onMessagesReceived.value,
                real_id=str(real_id), user_a=sender_user, user_b=recipient_user,
                content=content, direction=1, conv_id=sender_user,
                has_read=False, has_deliver_ack=None,
            )

    time.sleep(float(os.getenv("CHAT_REACTION_SETTLE_SECONDS", "10")))

    with _allure_step(f"接收账号动作端 {recipient_action.device_name} 为消息添加 reaction {reaction!r}"):
        response = recipient_action.call(
            "ChatManager", Cmd.addReaction.value,
            info={"reaction": reaction, "msgId": str(real_id)},
        )
    with _allure_step("确认添加 reaction 成功"):
        assert_api.assert_response_matches(
            response,
            expected={
                "manager": "ChatManager", "cmd": Cmd.addReaction.value,
                "device": recipient_action.device_name, "result": None,
            },
            ignore_keys={"sequence"},
        )

    for role, device in zip(topology.sender_roles, sender_devices):
        with _allure_step(f"发送账号端 {device.device_name} 收到 reaction 变更（onMessageReactionDidChange）"):
            _assert_reaction_change_event(
                assert_api, device, conv_id=recipient_user, real_id=str(real_id),
                operator=recipient_user, reaction=reaction, is_added_by_self=False,
            )

    for role, recipient in zip(topology.recipient_roles, recipients):
        with _allure_step(f"接收账号端 {recipient.device_name} 收到自身 reaction 变更（messageReactionDidChange）"):
            _assert_reaction_change_event(
                assert_api, recipient, conv_id=sender_user, real_id=str(real_id),
                operator=recipient_user, reaction=reaction, is_added_by_self=True,
            )


def test_chat_fetch_reaction_list_invalid_msg_id(device_a, assert_api):
    """fetchReactionList 传入不存在的 msgId 列表；先断言信封。"""
    with _allure_step("验证：fetchReactionList 传入不存在的 msgId 列表；先断言信封。"):
        # Flutter 端签名要求 chatType 必填；请求体键名为 msgIds。
        info = {"msgIds": ["__invalid_msg_id__"], "chatType": 0}
        resp = device_a.call("ChatManager", Cmd.fetchReactionList.value, info=info)
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.fetchReactionList.value,
                "device": sender.device_name,
                "result": {"__invalid_msg_id__": []},
            },
            ignore_keys={"sequence"},
        )


def test_chat_fetch_reaction_list_empty_msg_ids(device_a, assert_api):
    """fetchReactionList 传入空 msgIds；应返回参数错误。"""
    with _allure_step("验证：fetchReactionList 传入空 msgIds；应返回参数错误。"):
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
    with _allure_step("验证：fetchReactionList 传入非法 chatType；当前实现返回空 reaction 列表映射。"):
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
    with _allure_step("验证：fetchReactionDetail 使用无效 msgId/reaction；先校验信封。"):
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
    with _allure_step("验证：fetchReactionDetail 非法 pageSize（-1）；应返回参数错误。"):
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
    with _allure_step("验证：fetchReactionDetail 传入空 reaction；应返回参数错误。"):
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
    with _allure_step("验证：fetchReactionDetail 过大 pageSize（1000）；应返回稳定结果结构。"):
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


@pytest.mark.topology("account_a_to_account_b")
def test_chat_add_reaction_duplicate_reaction(topology, assert_api):
    """addReaction 重复添加同一 reaction；接收账号全部在线端收到 reaction 变更事件。"""
    sender = topology.sender_action_device
    recipients = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    try:
        for device in (sender, *recipients):
            device.drain_events()
    except Exception:
        pass

    with _allure_step(f"{sender.device_name} 发送消息并等待接收端接收"):
        real_id = _send_text_and_wait_received(
            sender, recipients[0], assert_api, user_a, user_b, "reaction-duplicate"
        )
    time.sleep(5)

    reaction = "👍"
    with _allure_step(f"{sender.device_name} 添加 reaction（首次）"):
        resp_add_first = sender.call("ChatManager", Cmd.addReaction.value, info={"reaction": reaction, "msgId": real_id})
    assert_api.assert_response_matches(
        resp_add_first,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.addReaction.value,
            "device": sender.device_name,
            "result": None,
        },
        ignore_keys={"sequence"},
    )
    _assert_reaction_change_event(assert_api, sender, conv_id=user_b, real_id=real_id, operator=user_a, reaction=reaction, is_added_by_self=True)
    for recipient in recipients:
        _assert_reaction_change_event(assert_api, recipient, conv_id=user_a, real_id=real_id, operator=user_a, reaction=reaction, is_added_by_self=False)

    resp_add_second = sender.call("ChatManager", Cmd.addReaction.value, info={"reaction": reaction, "msgId": real_id})
    assert_api.assert_response_matches(
        resp_add_second,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.addReaction.value,
            "device": sender.device_name,
            "result": {"code": 1301, "description": "the user is already operation this message"},
        },
        ignore_keys={"sequence"},
    )


@pytest.mark.topology("account_a_to_account_b")
def test_chat_remove_reaction_not_exists_reaction(topology, assert_api):
    """removeReaction 删除不存在的 reaction；接收账号全部在线端收到消息投递。"""
    sender = topology.sender_action_device
    recipients = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    try:
        for device in (sender, *recipients):
            device.drain_events()
    except Exception:
        pass

    with _allure_step(f"{sender.device_name} 发送消息并等待接收端接收"):
        real_id = _send_text_and_wait_received(
            sender, recipients[0], assert_api, user_a, user_b, "reaction-remove-not-exists"
        )

    with _allure_step(f"{sender.device_name} 删除不存在的 reaction"):
        resp = sender.call("ChatManager", Cmd.removeReaction.value, info={"reaction": "👍", "msgId": real_id})
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.removeReaction.value,
            "device": sender.device_name,
            "result": None,
        },
        ignore_keys={"sequence"},
    )


def test_chat_remove_reaction_invalid_msg_id(device_a, assert_api):
    """removeReaction 使用无效 msgId；按不存在语义冻结。"""
    with _allure_step("验证：removeReaction 使用无效 msgId；按不存在语义冻结。"):
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
    with _allure_step("验证：addReaction 超长 reaction；按被测端实际语义冻结。"):
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
    with _allure_step("验证：addReaction 特殊字符 reaction；按被测端实际语义冻结。"):
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
