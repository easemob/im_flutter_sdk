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
