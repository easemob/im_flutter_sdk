"""好友单聊后操作的离线事件：已读、撤回和消息修改。"""
from __future__ import annotations

import time
import uuid

import pytest

from src import Cmd, gt
from src.test_flow.offline_test_flow import (
    login_preserving_offline_events,
    logout_for_offline,
)
from tests.chat.test_chat_offline_message_delivery import (
    _MESSAGE_DYNAMIC_KEYS,
    _assert_call,
    _assert_received_message,
    _assert_send_response_and_success,
    _establish_friendship,
    _restore_case,
    _wait_message_event,
)


pytestmark = [pytest.mark.client, pytest.mark.chat]

_REACTION_EVENT_TYPE = "onMessageReactionDidChange"


def _assert_delivered_text(
    assert_api,
    event: dict,
    *,
    real_id: str,
    user_a: str,
    user_b: str,
    content: str,
) -> None:
    assert_api.assert_response_matches(
        event,
        expected={
            "type": "event",
            "eventType": Cmd.onMessagesDelivered.value,
            "data": {
                "messages": [
                    {
                        "msgId": real_id,
                        "from": user_a,
                        "to": user_b,
                        "convId": user_b,
                        "chatType": 0,
                        "direction": 0,
                        "status": 2,
                        "hasRead": True,
                        "hasReadAck": False,
                        "hasDeliverAck": True,
                        "needGroupAck": False,
                        "isThread": False,
                        "isContentReplaced": False,
                        "deliverOnlineOnly": False,
                        "body": {
                            "type": 0,
                            "content": content,
                            "translations": {},
                        },
                    }
                ]
            },
        },
        ignore_keys=_MESSAGE_DYNAMIC_KEYS,
    )


def _send_online_text(
    device_a,
    device_b,
    assert_api,
    *,
    user_a: str,
    user_b: str,
    content: str,
) -> str:
    _, real_id, _ = _assert_send_response_and_success(
        device_a,
        assert_api,
        type_key="txt",
        payload={"targetId": user_b, "content": content},
        user_a=user_a,
        user_b=user_b,
        response_body={"type": 0, "content": content},
        success_body={"type": 0, "content": content, "translations": {}},
    )
    received = _wait_message_event(
        device_b,
        Cmd.onMessagesReceived.value,
        real_id=real_id,
    )
    _assert_received_message(
        assert_api,
        received,
        event_type=Cmd.onMessagesReceived.value,
        real_id=real_id,
        user_a=user_a,
        user_b=user_b,
        body={"type": 0, "content": content, "translations": {}},
    )
    delivered = _wait_message_event(
        device_a,
        Cmd.onMessagesDelivered.value,
        real_id=real_id,
    )
    _assert_delivered_text(
        assert_api,
        delivered,
        real_id=real_id,
        user_a=user_a,
        user_b=user_b,
        content=content,
    )
    return real_id


def _wait_recall_info(device, *, real_id: str, timeout: float = 60.0) -> dict:
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        event = device.receive_message(
            match_event_type=Cmd.onMessagesRecalledInfo.value,
            timeout=min(2.0, max(0.1, deadline - time.monotonic())),
        )
        if event:
            seen.append(event)
        infos = (((event or {}).get("data") or {}).get("infos") or [])
        if any(
            isinstance(info, dict)
            and str(info.get("recallMsgId")) == str(real_id)
            for info in infos
        ):
            return event
    raise AssertionError(f"未收到离线撤回事件: msgId={real_id}, events={seen}")


def _wait_content_changed(device, *, real_id: str, timeout: float = 60.0) -> dict:
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        event = device.receive_message(
            match_event_type=Cmd.onMessageContentChanged.value,
            timeout=min(2.0, max(0.1, deadline - time.monotonic())),
        )
        if event:
            seen.append(event)
        message = ((event or {}).get("data") or {}).get("message") or {}
        if str(message.get("msgId")) == str(real_id):
            return event
    raise AssertionError(f"未收到离线修改事件: msgId={real_id}, events={seen}")


def _wait_conversation_read(
    device,
    *,
    from_user: str,
    to_user: str,
    timeout: float = 60.0,
) -> dict:
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        event = device.receive_message(
            match_event_type="onConversationRead",
            timeout=min(2.0, max(0.1, deadline - time.monotonic())),
        )
        if event:
            seen.append(event)
        data = ((event or {}).get("data") or {})
        if data.get("from") == from_user and data.get("to") == to_user:
            return event
    raise AssertionError(
        "未收到离线会话已读事件: "
        f"from={from_user}, to={to_user}, events={seen}"
    )


def _wait_reaction_change(
    device,
    *,
    real_id: str,
    operate: int,
    timeout: float = 60.0,
) -> dict:
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        event = device.receive_message(
            match_event_type=_REACTION_EVENT_TYPE,
            timeout=min(2.0, max(0.1, deadline - time.monotonic())),
        )
        if event:
            seen.append(event)
        for change in (((event or {}).get("data") or {}).get("events") or []):
            if not isinstance(change, dict) or str(change.get("msgId")) != str(real_id):
                continue
            operations = change.get("operations") or []
            if any(
                isinstance(operation, dict)
                and operation.get("operate") == operate
                for operation in operations
            ):
                return event
    raise AssertionError(
        f"未收到离线 Reaction 事件: msgId={real_id}, operate={operate}, events={seen}"
    )


def _assert_reaction_change(
    assert_api,
    event: dict,
    *,
    conv_id: str,
    real_id: str,
    operator_id: str,
    reaction: str,
    operate: int,
    reactions: list[dict],
) -> None:
    assert_api.assert_response_matches(
        event,
        expected={
            "type": "event",
            "eventType": _REACTION_EVENT_TYPE,
            "data": {
                "events": [
                    {
                        "convId": conv_id,
                        "msgId": real_id,
                        "operations": [
                            {
                                "userId": operator_id,
                                "reaction": reaction,
                                "operate": operate,
                            }
                        ],
                        "reactions": reactions,
                    }
                ]
            },
        },
        ignore_keys={"timestamp", "sequence"},
    )


def _wait_pin_change(
    device,
    *,
    real_id: str,
    operation: str,
    timeout: float = 60.0,
) -> dict:
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        event = device.receive_message(
            match_event_type=Cmd.onMessagePinChanged.value,
            timeout=min(2.0, max(0.1, deadline - time.monotonic())),
        )
        if event:
            seen.append(event)
        data = ((event or {}).get("data") or {})
        if (
            str(data.get("messageId")) == str(real_id)
            and data.get("pinOperation") == operation
        ):
            return event
    raise AssertionError(
        "未收到离线消息置顶事件: "
        f"msgId={real_id}, operation={operation}, events={seen}"
    )


def _assert_pin_change(
    assert_api,
    event: dict,
    *,
    real_id: str,
    conversation_id: str,
    operation: str,
    operator_id: str,
) -> None:
    assert_api.assert_response_matches(
        event,
        expected={
            "type": "event",
            "eventType": Cmd.onMessagePinChanged.value,
            "data": {
                "messageId": real_id,
                "conversationId": conversation_id,
                "pinOperation": operation,
                "pinInfo": {"operatorId": operator_id},
            },
        },
        ignore_keys={"timestamp", "sequence", "pinTime"},
    )


def _wait_pinned_messages(
    device,
    *,
    conv_id: str,
    real_id: str,
    present: bool,
    timeout: float = 30.0,
) -> dict:
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        response = device.call(
            "ChatManager",
            Cmd.fetchPinnedMessages.value,
            info={"convId": conv_id},
        )
        seen.append(response)
        result = response.get("result")
        if isinstance(result, list):
            contains_target = any(
                isinstance(message, dict)
                and str(message.get("msgId")) == str(real_id)
                for message in result
            )
            if contains_target is present:
                return response
        time.sleep(1.0)
    raise AssertionError(
        "置顶消息最终状态未同步: "
        f"convId={conv_id}, msgId={real_id}, present={present}, responses={seen}"
    )


def _clear_pinned_messages(device, peer_device, *, conv_id: str) -> None:
    try:
        response = device.call(
            "ChatManager",
            Cmd.fetchPinnedMessages.value,
            info={"convId": conv_id},
        )
        for message in response.get("result") or []:
            msg_id = (message or {}).get("msgId")
            if msg_id:
                device.call(
                    "ChatManager",
                    Cmd.unpinMessage.value,
                    info={"msgId": str(msg_id)},
                )
        time.sleep(2.0)
    except Exception:
        pass
    device.drain_events(timeout=0.5)
    peer_device.drain_events(timeout=0.5)


def _assert_reaction_state(
    assert_api,
    response: dict,
    *,
    device_name: str,
    real_id: str,
    reactions: list[dict],
) -> None:
    assert_api.assert_response_matches(
        response,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.fetchReactionList.value,
            "device": device_name,
            "result": {real_id: reactions},
        },
        ignore_keys={"sequence"},
    )


def _assert_pinned_text_state(
    assert_api,
    response: dict,
    *,
    real_id: str,
    user_a: str,
    user_b: str,
    content: str,
) -> None:
    assert_api.assert_response_matches(
        response,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.fetchPinnedMessages.value,
            "device": "deviceB",
            "result": [
                {
                    "msgId": real_id,
                    "from": user_a,
                    "to": user_b,
                    "convId": user_a,
                    "chatType": 0,
                    "direction": 1,
                    "status": 2,
                    "hasRead": False,
                    "hasReadAck": False,
                    "hasDeliverAck": True,
                    "needGroupAck": False,
                    "isThread": False,
                    "isContentReplaced": False,
                    "body": {
                        "type": 0,
                        "content": content,
                        "translations": {},
                    },
                }
            ],
        },
        ignore_keys=_MESSAGE_DYNAMIC_KEYS | {"deliverOnlineOnly"},
    )


def test_chat_offline_sender_receives_message_read_after_relogin(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """A 离线期间 B 回执单条已读；A 重登收到目标 onMessagesRead。"""
    content = f"offline-read-{uuid.uuid4().hex[:8]}"
    try:
        _establish_friendship(
            device_a, device_b, assert_api, user_a=user_a, user_b=user_b
        )
        real_id = _send_online_text(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            content=content,
        )
        device_a.drain_events(timeout=0.5)
        logout_for_offline(device_a, assert_api, device_name="deviceA")
        ack = device_b.call(
            "ChatManager",
            Cmd.ackMessageRead.value,
            info={"msgId": real_id, "to": user_a},
        )
        _assert_call(
            assert_api,
            ack,
            manager="ChatManager",
            cmd=Cmd.ackMessageRead.value,
            device_name="deviceB",
            result=True,
        )
        login_preserving_offline_events(
            device_a,
            assert_api,
            device_name="deviceA",
            user_id=user_a,
        )
        read = _wait_message_event(
            device_a,
            Cmd.onMessagesRead.value,
            real_id=real_id,
        )
        assert_api.assert_response_matches(
            read,
            expected={
                "type": "event",
                "eventType": Cmd.onMessagesRead.value,
                "data": {
                    "messages": [
                        {
                            "msgId": real_id,
                            "from": user_a,
                            "to": user_b,
                            "convId": user_b,
                            "chatType": 0,
                            "direction": 0,
                            "status": 2,
                            "hasRead": True,
                            "hasReadAck": True,
                            "hasDeliverAck": True,
                            "needGroupAck": False,
                            "isThread": False,
                            "isContentReplaced": False,
                            "deliverOnlineOnly": False,
                            "body": {
                                "type": 0,
                                "content": content,
                                "translations": {},
                            },
                        }
                    ]
                },
            },
            ignore_keys=_MESSAGE_DYNAMIC_KEYS,
        )
    finally:
        _restore_case(device_a, device_b, user_a=user_a, user_b=user_b)


def test_chat_offline_recipient_receives_recall_after_relogin(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """B 已收消息后离线，A 撤回；B 重登收到目标撤回信息。"""
    content = f"offline-recall-{uuid.uuid4().hex[:8]}"
    try:
        _establish_friendship(
            device_a, device_b, assert_api, user_a=user_a, user_b=user_b
        )
        real_id = _send_online_text(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            content=content,
        )
        device_b.drain_events(timeout=0.5)
        logout_for_offline(device_b, assert_api, device_name="deviceB")
        recall = device_a.call(
            "ChatManager",
            Cmd.recallMessage.value,
            info={"msgId": real_id},
        )
        _assert_call(
            assert_api,
            recall,
            manager="ChatManager",
            cmd=Cmd.recallMessage.value,
            device_name="deviceA",
            result=True,
        )
        login_preserving_offline_events(
            device_b,
            assert_api,
            device_name="deviceB",
            user_id=user_b,
        )
        recalled = _wait_recall_info(device_b, real_id=real_id)
        assert_api.assert_response_matches(
            recalled,
            expected={
                "type": "event",
                "eventType": Cmd.onMessagesRecalledInfo.value,
                "data": {
                    "infos": [
                        {
                            "recallBy": user_a,
                            "recallMsgId": real_id,
                            "convId": user_a,
                            "msg": {
                                "msgId": real_id,
                                "from": user_a,
                                "to": user_b,
                                "convId": user_a,
                                "chatType": 0,
                                "direction": 1,
                                "status": 2,
                                "hasRead": False,
                                "hasReadAck": False,
                                "hasDeliverAck": True,
                                "needGroupAck": False,
                                "isThread": False,
                                "isContentReplaced": False,
                                "deliverOnlineOnly": False,
                                "body": {
                                    "type": 0,
                                    "content": content,
                                    "translations": {},
                                },
                            },
                            "ext": "",
                        }
                    ]
                },
            },
            ignore_keys=_MESSAGE_DYNAMIC_KEYS,
        )
        recalled_messages = _wait_message_event(
            device_b,
            Cmd.onMessagesRecalled.value,
            real_id=real_id,
        )
        _assert_received_message(
            assert_api,
            recalled_messages,
            event_type=Cmd.onMessagesRecalled.value,
            real_id=real_id,
            user_a=user_a,
            user_b=user_b,
            body={"type": 0, "content": content, "translations": {}},
        )
        local = device_b.call(
            "ChatManager",
            Cmd.getMessage.value,
            info={"msgId": real_id},
        )
        _assert_call(
            assert_api,
            local,
            manager="ChatManager",
            cmd=Cmd.getMessage.value,
            device_name="deviceB",
            result=None,
        )
    finally:
        _restore_case(device_a, device_b, user_a=user_a, user_b=user_b)


def test_chat_offline_recipient_receives_content_change_after_relogin(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """B 已收消息后离线，A 修改正文；B 重登收到修改事件和最终正文。"""
    old_content = f"offline-modify-old-{uuid.uuid4().hex[:6]}"
    new_content = f"offline-modify-new-{uuid.uuid4().hex[:6]}"
    try:
        _establish_friendship(
            device_a, device_b, assert_api, user_a=user_a, user_b=user_b
        )
        real_id = _send_online_text(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            content=old_content,
        )
        device_b.drain_events(timeout=0.5)
        logout_for_offline(device_b, assert_api, device_name="deviceB")
        modify = device_a.call(
            "ChatManager",
            Cmd.modifyMessage.value,
            info={
                "msgId": real_id,
                "msgBody": {"type": 0, "content": new_content},
            },
        )
        assert_api.assert_response_matches(
            modify,
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.modifyMessage.value,
                "device": "deviceA",
                "result": {
                    "msgId": real_id,
                    "from": user_a,
                    "to": user_b,
                    "convId": user_b,
                    "chatType": 0,
                    "direction": 0,
                    "status": 2,
                    "hasRead": True,
                    "hasReadAck": False,
                    "hasDeliverAck": True,
                    "needGroupAck": False,
                    "isThread": False,
                    "isContentReplaced": False,
                    "body": {
                        "type": 0,
                        "content": new_content,
                        "operatorId": user_a,
                        "operatorTime": gt(0),
                        "operatorCount": gt(0),
                    },
                },
            },
            ignore_keys=_MESSAGE_DYNAMIC_KEYS | {"deliverOnlineOnly", "translations"},
        )
        login_preserving_offline_events(
            device_b,
            assert_api,
            device_name="deviceB",
            user_id=user_b,
        )
        changed = _wait_content_changed(device_b, real_id=real_id)
        assert_api.assert_response_matches(
            changed,
            expected={
                "type": "event",
                "eventType": Cmd.onMessageContentChanged.value,
                "data": {
                    "message": {
                        "msgId": real_id,
                        "from": user_a,
                        "to": user_b,
                        "convId": user_a,
                        "chatType": 0,
                        "direction": 1,
                        "status": 2,
                        "hasRead": False,
                        "hasReadAck": False,
                        "hasDeliverAck": True,
                        "needGroupAck": False,
                        "isThread": False,
                        "isContentReplaced": False,
                        "body": {"type": 0, "content": new_content},
                    },
                    "operatorId": user_a,
                    "operationTime": gt(0),
                },
            },
            ignore_keys=_MESSAGE_DYNAMIC_KEYS | {"deliverOnlineOnly", "translations"},
        )
        local = device_b.call(
            "ChatManager",
            Cmd.getMessage.value,
            info={"msgId": real_id},
        )
        assert_api.assert_response_matches(
            local,
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.getMessage.value,
                "device": "deviceB",
                "result": {
                    "msgId": real_id,
                    "from": user_a,
                    "to": user_b,
                    "convId": user_a,
                    "chatType": 0,
                    "direction": 1,
                    "body": {"type": 0, "content": new_content},
                },
            },
            ignore_keys=_MESSAGE_DYNAMIC_KEYS
            | {
                "status",
                "hasRead",
                "hasReadAck",
                "hasDeliverAck",
                "needGroupAck",
                "isThread",
                "isContentReplaced",
                "deliverOnlineOnly",
                "translations",
                "operatorId",
                "operatorTime",
                "operatorCount",
            },
        )
    finally:
        _restore_case(device_a, device_b, user_a=user_a, user_b=user_b)


def test_chat_offline_sender_receives_conversation_read_after_relogin(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """A 离线期间 B 回执会话已读；A 重登只接受 onConversationRead。"""
    content = f"offline-conversation-read-{uuid.uuid4().hex[:8]}"
    try:
        _establish_friendship(
            device_a, device_b, assert_api, user_a=user_a, user_b=user_b
        )
        _send_online_text(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            content=content,
        )
        device_a.drain_events(timeout=0.5)
        logout_for_offline(device_a, assert_api, device_name="deviceA")
        acknowledged = device_b.call(
            "ChatManager",
            Cmd.ackConversationRead.value,
            info={"convId": user_a},
        )
        _assert_call(
            assert_api,
            acknowledged,
            manager="ChatManager",
            cmd=Cmd.ackConversationRead.value,
            device_name="deviceB",
            result=True,
        )
        login_preserving_offline_events(
            device_a,
            assert_api,
            device_name="deviceA",
            user_id=user_a,
        )
        read = _wait_conversation_read(
            device_a,
            from_user=user_b,
            to_user=user_a,
        )
        assert_api.assert_response_matches(
            read,
            expected={
                "type": "event",
                "eventType": "onConversationRead",
                "data": {"from": user_b, "to": user_a},
            },
            ignore_keys={"timestamp", "sequence"},
        )
    finally:
        _restore_case(device_a, device_b, user_a=user_a, user_b=user_b)


def test_chat_offline_sender_receives_reaction_add_after_relogin(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """A 离线期间 B 添加 Reaction；A 重登收到添加事件和最终聚合状态。"""
    reaction = f"offline_add_{uuid.uuid4().hex[:6]}"
    content = f"offline-reaction-add-{uuid.uuid4().hex[:8]}"
    try:
        _establish_friendship(
            device_a, device_b, assert_api, user_a=user_a, user_b=user_b
        )
        real_id = _send_online_text(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            content=content,
        )
        device_a.drain_events(timeout=0.5)
        logout_for_offline(device_a, assert_api, device_name="deviceA")
        added = device_b.call(
            "ChatManager",
            Cmd.addReaction.value,
            info={"reaction": reaction, "msgId": real_id},
        )
        _assert_call(
            assert_api,
            added,
            manager="ChatManager",
            cmd=Cmd.addReaction.value,
            device_name="deviceB",
            result=None,
        )
        login_preserving_offline_events(
            device_a,
            assert_api,
            device_name="deviceA",
            user_id=user_a,
        )
        changed = _wait_reaction_change(device_a, real_id=real_id, operate=1)
        expected_reactions = [
            {
                "reaction": reaction,
                "count": 1,
                "isAddedBySelf": False,
                "userList": [user_b],
            }
        ]
        _assert_reaction_change(
            assert_api,
            changed,
            conv_id=user_b,
            real_id=real_id,
            operator_id=user_b,
            reaction=reaction,
            operate=1,
            reactions=expected_reactions,
        )
        fetched = device_a.call(
            "ChatManager",
            Cmd.fetchReactionList.value,
            info={"msgIds": [real_id], "chatType": 0},
        )
        _assert_reaction_state(
            assert_api,
            fetched,
            device_name="deviceA",
            real_id=real_id,
            reactions=expected_reactions,
        )
    finally:
        _restore_case(device_a, device_b, user_a=user_a, user_b=user_b)


def test_chat_offline_sender_receives_reaction_remove_after_relogin(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """消息已有 Reaction，A 离线期间 B 移除；A 重登收到移除事件。"""
    reaction = f"offline_remove_{uuid.uuid4().hex[:6]}"
    content = f"offline-reaction-remove-{uuid.uuid4().hex[:8]}"
    try:
        _establish_friendship(
            device_a, device_b, assert_api, user_a=user_a, user_b=user_b
        )
        real_id = _send_online_text(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            content=content,
        )
        added = device_b.call(
            "ChatManager",
            Cmd.addReaction.value,
            info={"reaction": reaction, "msgId": real_id},
        )
        _assert_call(
            assert_api,
            added,
            manager="ChatManager",
            cmd=Cmd.addReaction.value,
            device_name="deviceB",
            result=None,
        )
        add_event = _wait_reaction_change(device_a, real_id=real_id, operate=1)
        expected_added = [
            {
                "reaction": reaction,
                "count": 1,
                "isAddedBySelf": False,
                "userList": [user_b],
            }
        ]
        _assert_reaction_change(
            assert_api,
            add_event,
            conv_id=user_b,
            real_id=real_id,
            operator_id=user_b,
            reaction=reaction,
            operate=1,
            reactions=expected_added,
        )
        device_a.drain_events(timeout=0.5)
        device_b.drain_events(timeout=0.5)
        logout_for_offline(device_a, assert_api, device_name="deviceA")
        removed = device_b.call(
            "ChatManager",
            Cmd.removeReaction.value,
            info={"reaction": reaction, "msgId": real_id},
        )
        _assert_call(
            assert_api,
            removed,
            manager="ChatManager",
            cmd=Cmd.removeReaction.value,
            device_name="deviceB",
            result=None,
        )
        login_preserving_offline_events(
            device_a,
            assert_api,
            device_name="deviceA",
            user_id=user_a,
        )
        changed = _wait_reaction_change(device_a, real_id=real_id, operate=0)
        _assert_reaction_change(
            assert_api,
            changed,
            conv_id=user_b,
            real_id=real_id,
            operator_id=user_b,
            reaction=reaction,
            operate=0,
            reactions=[
                {
                    "reaction": reaction,
                    "count": 0,
                    "isAddedBySelf": False,
                    "userList": [],
                }
            ],
        )
        fetched = device_a.call(
            "ChatManager",
            Cmd.fetchReactionList.value,
            info={"msgIds": [real_id], "chatType": 0},
        )
        _assert_reaction_state(
            assert_api,
            fetched,
            device_name="deviceA",
            real_id=real_id,
            reactions=[],
        )
    finally:
        _restore_case(device_a, device_b, user_a=user_a, user_b=user_b)


def test_chat_offline_recipient_receives_message_pin_after_relogin(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """B 离线期间 A 置顶消息；B 重登收到置顶事件和最终置顶消息。"""
    content = f"offline-pin-{uuid.uuid4().hex[:8]}"
    real_id = None
    try:
        _establish_friendship(
            device_a, device_b, assert_api, user_a=user_a, user_b=user_b
        )
        _clear_pinned_messages(device_a, device_b, conv_id=user_b)
        real_id = _send_online_text(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            content=content,
        )
        device_b.drain_events(timeout=0.5)
        logout_for_offline(device_b, assert_api, device_name="deviceB")
        pinned = device_a.call(
            "ChatManager",
            Cmd.pinMessage.value,
            info={"msgId": real_id},
        )
        _assert_call(
            assert_api,
            pinned,
            manager="ChatManager",
            cmd=Cmd.pinMessage.value,
            device_name="deviceA",
            result=None,
        )
        login_preserving_offline_events(
            device_b,
            assert_api,
            device_name="deviceB",
            user_id=user_b,
        )
        changed = _wait_pin_change(
            device_b,
            real_id=real_id,
            operation="MessagePinOperation.Pin",
        )
        _assert_pin_change(
            assert_api,
            changed,
            real_id=real_id,
            conversation_id=user_a,
            operation="MessagePinOperation.Pin",
            operator_id=user_a,
        )
        fetched = _wait_pinned_messages(
            device_b,
            conv_id=user_a,
            real_id=real_id,
            present=True,
        )
        _assert_pinned_text_state(
            assert_api,
            fetched,
            real_id=real_id,
            user_a=user_a,
            user_b=user_b,
            content=content,
        )
    finally:
        if real_id:
            try:
                device_a.call(
                    "ChatManager",
                    Cmd.unpinMessage.value,
                    info={"msgId": real_id},
                )
            except Exception:
                pass
        _restore_case(device_a, device_b, user_a=user_a, user_b=user_b)


def test_chat_offline_recipient_receives_message_unpin_after_relogin(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """消息已置顶，B 离线期间 A 取消置顶；B 重登收到取消事件。"""
    content = f"offline-unpin-{uuid.uuid4().hex[:8]}"
    try:
        _establish_friendship(
            device_a, device_b, assert_api, user_a=user_a, user_b=user_b
        )
        _clear_pinned_messages(device_a, device_b, conv_id=user_b)
        real_id = _send_online_text(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            content=content,
        )
        pinned = device_a.call(
            "ChatManager",
            Cmd.pinMessage.value,
            info={"msgId": real_id},
        )
        _assert_call(
            assert_api,
            pinned,
            manager="ChatManager",
            cmd=Cmd.pinMessage.value,
            device_name="deviceA",
            result=None,
        )
        pin_event = _wait_pin_change(
            device_b,
            real_id=real_id,
            operation="MessagePinOperation.Pin",
        )
        _assert_pin_change(
            assert_api,
            pin_event,
            real_id=real_id,
            conversation_id=user_a,
            operation="MessagePinOperation.Pin",
            operator_id=user_a,
        )
        initial_state = _wait_pinned_messages(
            device_b,
            conv_id=user_a,
            real_id=real_id,
            present=True,
        )
        _assert_pinned_text_state(
            assert_api,
            initial_state,
            real_id=real_id,
            user_a=user_a,
            user_b=user_b,
            content=content,
        )
        device_b.drain_events(timeout=0.5)
        logout_for_offline(device_b, assert_api, device_name="deviceB")
        unpinned = device_a.call(
            "ChatManager",
            Cmd.unpinMessage.value,
            info={"msgId": real_id},
        )
        _assert_call(
            assert_api,
            unpinned,
            manager="ChatManager",
            cmd=Cmd.unpinMessage.value,
            device_name="deviceA",
            result=None,
        )
        login_preserving_offline_events(
            device_b,
            assert_api,
            device_name="deviceB",
            user_id=user_b,
        )
        changed = _wait_pin_change(
            device_b,
            real_id=real_id,
            operation="MessagePinOperation.Unpin",
        )
        _assert_pin_change(
            assert_api,
            changed,
            real_id=real_id,
            conversation_id=user_a,
            operation="MessagePinOperation.Unpin",
            operator_id=user_a,
        )
        fetched = _wait_pinned_messages(
            device_b,
            conv_id=user_a,
            real_id=real_id,
            present=False,
        )
        _assert_call(
            assert_api,
            fetched,
            manager="ChatManager",
            cmd=Cmd.fetchPinnedMessages.value,
            device_name="deviceB",
            result=[],
        )
    finally:
        _restore_case(device_a, device_b, user_a=user_a, user_b=user_b)
