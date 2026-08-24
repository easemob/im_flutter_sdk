"""好友单聊离线投递：消息类型、online-only、积压与送达回执。"""
from __future__ import annotations

import time
import uuid

import pytest

from src import Cmd, ne
from src.test_flow.event_waiters import wait_for_message_occurrences as _wait_message_event
from src.sdk_api.event_keys import ContactChangeEvent
from src.test_flow.offline_test_flow import (
    login_account_devices,
    logout_account_devices,
    restore_account_devices,
    set_accept_invitation_always,
)
from tests.chat._utils import swt_to_send
from tests.allure_helpers import _allure_step


pytestmark = [
    pytest.mark.client,
    pytest.mark.chat,
    pytest.mark.topology("account_a_to_account_b"),
]


_MESSAGE_DYNAMIC_KEYS = {
    "timestamp",
    "sequence",
    "serverTime",
    "localTime",
    "broadcast",
    "onlineState",
    "receiverList",
    "targetLanguages",
}

_MEDIA_DYNAMIC_KEYS = _MESSAGE_DYNAMIC_KEYS | {
    # 媒体状态由 endpoint 本地缓存/下载状态决定；消息身份、类型和业务正文仍严格断言。
    "fileStatus",
    "localPath",
    "remotePath",
    "secret",
    "fileSize",
    "thumbnailLocalPath",
    "thumbnailRemotePath",
    "thumbnailSecret",
    "width",
    "height",
    "isGif",
    "sendOriginalImage",
    "thumbnailStatus",
}

_COMBINE_DYNAMIC_KEYS = _MESSAGE_DYNAMIC_KEYS | {
    # combine 的媒体状态同样由 endpoint 本地状态决定。
    "fileStatus",
    "localPath",
    "remotePath",
    "secret",
    "messageList",
}

_MEDIA_CASES = [
    pytest.param(
        "file",
        {"targetId": "{{userB}}"},
        {"type": 5, "displayName": "bigPic.jpg", "fileStatus": 0},
        {"type": 5, "displayName": "bigPic.jpg", "fileStatus": 3},
        id="file",
    ),
    pytest.param(
        "image",
        {"targetId": "{{userB}}", "thumbnailLocalPath": ""},
        {"type": 1, "displayName": "bigPic.jpg", "fileStatus": 0},
        {"type": 1, "displayName": "bigPic.jpg", "fileStatus": 3},
        id="image",
    ),
    pytest.param(
        "video",
        {"targetId": "{{userB}}", "thumbnailLocalPath": ""},
        {"type": 2, "displayName": "video.mov", "fileStatus": 0, "duration": 0},
        {"type": 2, "displayName": "video.mov", "fileStatus": 3, "duration": 0},
        id="video",
    ),
    pytest.param(
        "voice",
        {"targetId": "{{userB}}", "duration": 1},
        {"type": 4, "displayName": "voice.mp3", "fileStatus": 0, "duration": 1},
        {"type": 4, "displayName": "voice.mp3", "fileStatus": 0, "duration": 1},
        id="voice",
    ),
]


def _assert_call(assert_api, response: dict, *, manager: str, cmd: str,
                 device_name: str, result) -> None:
    assert_api.assert_response_matches(
        response,
        expected={
            "manager": manager,
            "cmd": cmd,
            "device": device_name,
            "result": result,
        },
        ignore_keys={"sequence"},
    )


def _device_name(device) -> str:
    return getattr(device, "_device", "device")


def _offline_endpoints(topology):
    """Resolve action endpoints, users, and all account endpoints from topology."""
    return (
        topology.sender_action_device,
        topology.recipient_action_device,
        topology.sender_user,
        topology.recipient_user,
        topology.sender_devices,
        topology.recipient_devices,
    )


def _cleanup_relation(
    device_a,
    device_b,
    user_a: str,
    user_b: str,
    *,
    sender_devices=(),
    recipient_devices=(),
) -> None:
    sender_devices = tuple(sender_devices) or (device_a,)
    recipient_devices = tuple(recipient_devices) or (device_b,)
    for device in sender_devices:
        target = user_b
        try:
            device.call(
                "ContactManager",
                Cmd.deleteContact.value,
                info={"userId": target, "keepConversation": True},
            )
        except Exception:
            pass
        try:
            device.call(
                "ContactManager",
                Cmd.removeUserFromBlockList.value,
                info={"userId": target},
            )
        except Exception:
            pass
    for device in recipient_devices:
        target = user_a
        try:
            device.call(
                "ContactManager",
                Cmd.deleteContact.value,
                info={"userId": target, "keepConversation": True},
            )
        except Exception:
            pass
        try:
            device.call(
                "ContactManager",
                Cmd.removeUserFromBlockList.value,
                info={"userId": target},
            )
        except Exception:
            pass
    for device in (*sender_devices, *recipient_devices):
        device.drain_events(timeout=0.5)


def _establish_friendship(
    device_a,
    device_b,
    assert_api,
    *,
    user_a: str,
    user_b: str,
    sender_devices=(),
    recipient_devices=(),
) -> None:
    sender_devices = tuple(sender_devices) or (device_a,)
    recipient_devices = tuple(recipient_devices) or (device_b,)
    _cleanup_relation(
        device_a,
        device_b,
        user_a,
        user_b,
        sender_devices=sender_devices,
        recipient_devices=recipient_devices,
    )
    for device in recipient_devices:
        set_accept_invitation_always(
            device,
            assert_api,
            device_name=_device_name(device),
            enabled=False,
        )
    reason = f"offline-chat-friend-{uuid.uuid4().hex[:8]}"
    add = device_a.call(
        "ContactManager",
        Cmd.addContact.value,
        info={"userId": user_b, "reason": reason},
    )
    _assert_call(
        assert_api,
        add,
        manager="ContactManager",
        cmd=Cmd.addContact.value,
        device_name=_device_name(device_a),
        result=user_b,
    )
    invited = device_b.receive_message(
        match_event_type=ContactChangeEvent.INVITED.value,
        timeout=20.0,
    )
    assert_api.assert_response_matches(
        invited,
        expected={
            "type": "event",
            "eventType": ContactChangeEvent.INVITED.value,
            "data": {"userId": user_a, "reason": reason},
        },
        ignore_keys={"timestamp", "sequence"},
    )
    accept = device_b.call(
        "ContactManager",
        Cmd.acceptInvitation.value,
        info={"userId": user_a},
    )
    _assert_call(
        assert_api,
        accept,
        manager="ContactManager",
        cmd=Cmd.acceptInvitation.value,
        device_name=_device_name(device_b),
        result=user_a,
    )
    accepted = device_a.receive_message(
        match_event_type=ContactChangeEvent.INVITATION_ACCEPTED.value,
        timeout=20.0,
    )
    assert_api.assert_response_matches(
        accepted,
        expected={
            "type": "event",
            "eventType": ContactChangeEvent.INVITATION_ACCEPTED.value,
            "data": {"userId": user_b},
        },
        ignore_keys={"timestamp", "sequence"},
    )
    added = device_a.receive_message(
        match_event_type=ContactChangeEvent.CONTACT_ADD.value,
        timeout=20.0,
    )
    assert_api.assert_response_matches(
        added,
        expected={
            "type": "event",
            "eventType": ContactChangeEvent.CONTACT_ADD.value,
            "data": {"userId": user_b},
        },
        ignore_keys={"timestamp", "sequence"},
    )
    for device in (*sender_devices, *recipient_devices):
        device.drain_events(timeout=0.5)


def _restore_case(
    device_a,
    device_b,
    *,
    user_a: str,
    user_b: str,
    sender_devices=(),
    recipient_devices=(),
) -> None:
    sender_devices = tuple(sender_devices) or (device_a,)
    recipient_devices = tuple(recipient_devices) or (device_b,)
    restore_account_devices(sender_devices, user_id=user_a)
    restore_account_devices(recipient_devices, user_id=user_b)
    _cleanup_relation(
        device_a,
        device_b,
        user_a,
        user_b,
        sender_devices=sender_devices,
        recipient_devices=recipient_devices,
    )


def _prepare_offline_friend(
    device_a,
    device_b,
    assert_api,
    *,
    user_a: str,
    user_b: str,
    sender_devices=(),
    recipient_devices=(),
) -> None:
    sender_devices = tuple(sender_devices) or (device_a,)
    recipient_devices = tuple(recipient_devices) or (device_b,)
    _establish_friendship(
        device_a,
        device_b,
        assert_api,
        user_a=user_a,
        user_b=user_b,
        sender_devices=sender_devices,
        recipient_devices=recipient_devices,
    )
    for device in recipient_devices:
        conversation = {"convId": user_a, "type": 0}
        clear = device.call(
            "ConversationManager",
            Cmd.clearAllMessages.value,
            info=conversation,
        )
        _assert_call(
            assert_api,
            clear,
            manager="ConversationManager",
            cmd=Cmd.clearAllMessages.value,
            device_name=_device_name(device),
            result=True,
        )
        mark = device.call(
            "ConversationManager",
            Cmd.markAllMessagesAsRead.value,
            info=conversation,
        )
        _assert_call(
            assert_api,
            mark,
            manager="ConversationManager",
            cmd=Cmd.markAllMessagesAsRead.value,
            device_name=_device_name(device),
            result=True,
        )
        # iOS 清理/清未读的调用完成不代表本地 unread cache 已立即刷新。
        # 离线 case 必须从 0 未读开始，否则上一个 case 的消息会污染本次计数。
        unread_response = None
        deadline = time.monotonic() + 5.0
        while time.monotonic() < deadline:
            unread_response = device.call(
                "ConversationManager",
                Cmd.getUnreadMsgCount.value,
                info=conversation,
            )
            if unread_response.get("result") == 0:
                break
            time.sleep(0.25)
        else:
            raise AssertionError(
                f"{_device_name(device)} 离线前置清理后未读数未归零: "
                f"expected=0, actual={unread_response}"
            )
    logout_account_devices(recipient_devices, assert_api)


def _wait_success_event(
    device,
    *,
    temp_id: str,
    timeout: float = 60.0,
) -> dict:
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        event = device.receive_message(
            match_event_type=Cmd.onMessageSuccess.value,
            timeout=min(2.0, max(0.1, deadline - time.monotonic())),
        )
        if event:
            seen.append(event)
        if str(((event or {}).get("data") or {}).get("msgId")) == str(temp_id):
            return event
    raise AssertionError(f"未收到目标 onMessageSuccess: tempId={temp_id}, events={seen}")


def _assert_received_message_on_devices(
    devices,
    assert_api,
    *,
    event_type: str,
    real_id: str,
    user_a: str,
    user_b: str,
    body: dict,
    ignore_keys=None,
) -> None:
    """离线回放按 endpoint 独立消费并断言，不能用主端结果代表副端。"""
    for device in devices:
        event = _wait_message_event(device, event_type, real_id=real_id)
        _assert_received_message(
            assert_api,
            event,
            event_type=event_type,
            real_id=real_id,
            user_a=user_a,
            user_b=user_b,
            body=body,
            ignore_keys=ignore_keys,
        )


def _assert_send_response_and_success(
    device_a,
    assert_api,
    *,
    type_key: str,
    payload: dict,
    user_a: str,
    user_b: str,
    response_body: dict,
    success_body: dict,
    ignore_keys: set[str] | None = None,
    need_read_receipt: bool = False,
) -> tuple[str, str, dict]:
    response = device_a.call(
        "ChatManager",
        Cmd.sendMessage.value,
        info=swt_to_send({"type": type_key, "payload": payload, "chatType": 0, "needReadReceipt": need_read_receipt}),
    )
    temp_id = ((response.get("result") or {}).get("msgId"))
    assert isinstance(temp_id, str) and temp_id, f"发送响应缺少临时 msgId: {response}"
    # 5.0 发送响应的 status/fileStatus 会受媒体处理时序影响；业务字段仍严格断言。
    response_ignored = (
        set(ignore_keys or _MESSAGE_DYNAMIC_KEYS)
        | {"hasDeliverAck", "status", "fileStatus"}
    )
    assert_api.assert_response_matches(
        response,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.sendMessage.value,
            "device": "deviceA",
            "result": {
                "msgId": ne(""),
                "from": user_a,
                "to": user_b,
                "convId": user_b,
                "chatType": 0,
                "direction": 0,
                "hasRead": True,
                "isThread": False,
                "isContentReplaced": False,
                "deliverOnlineOnly": False,
                "body": response_body,
            },
        },
        ignore_keys=response_ignored,
    )
    success = _wait_success_event(device_a, temp_id=temp_id)
    sent_message = ((success.get("data") or {}).get("msg") or {})
    real_id = sent_message.get("msgId")
    assert isinstance(real_id, str) and real_id, f"成功事件缺少真实 msgId: {success}"
    assert_api.assert_response_matches(
        success,
        expected={
            "type": "event",
            "eventType": Cmd.onMessageSuccess.value,
            "data": {
                "msgId": temp_id,
                "msg": {
                    "msgId": ne(""),
                    "from": user_a,
                    "to": user_b,
                    "convId": user_b,
                    "chatType": 0,
                    "direction": 0,
                    "status": 2,
                    "hasRead": True,
                    "needReadReceipt": need_read_receipt,
                    "isThread": False,
                    "isContentReplaced": False,
                    "deliverOnlineOnly": False,
                    "body": success_body,
                },
            },
        },
        # 成功事件不是发送响应快照，status=2 必须严格校验。
        ignore_keys=response_ignored - {"status"},
    )
    return temp_id, str(real_id), success


def _assert_received_message(
    assert_api,
    event: dict,
    *,
    event_type: str,
    real_id: str,
    user_a: str,
    user_b: str,
    body: dict,
    ignore_keys: set[str] | None = None,
) -> None:
    if isinstance(event, (tuple, list)):
        for endpoint_event in event:
            _assert_received_message(
                assert_api,
                endpoint_event,
                event_type=event_type,
                real_id=real_id,
                user_a=user_a,
                user_b=user_b,
                body=body,
                ignore_keys=ignore_keys,
            )
        return
    assert_api.assert_response_matches(
        event,
        expected={
            "type": "event",
            "eventType": event_type,
            "data": {
                "messages": [
                    {
                        "msgId": real_id,
                        "from": user_a,
                        "to": user_b,
                        "convId": user_a,
                        "chatType": 0,
                        "direction": 1,
                        "status": 2,
                        "hasRead": False,
                        "needReadReceipt": False,
                        "isThread": False,
                        "isContentReplaced": False,
                        "deliverOnlineOnly": False,
                        "body": body,
                    }
                ]
            },
        },
        ignore_keys=set(ignore_keys or _MESSAGE_DYNAMIC_KEYS) | {"hasDeliverAck"},
    )


def _send_offline_text(
    device_a,
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
    return real_id


def test_chat_offline_text_message_received_after_login(
    topology,
    assert_api,
):
    """好友 B 离线时 A 发文本；B 登录后收到同一真实消息。"""
    with _allure_step("验证：好友 B 离线时 A 发文本；B 登录后收到同一真实消息。"):
        device_a, device_b, user_a, user_b, sender_devices, recipient_devices = _offline_endpoints(topology)
        content = f"offline-text-{uuid.uuid4().hex[:8]}"
        try:
            _prepare_offline_friend(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )
            real_id = _send_offline_text(
                device_a,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                content=content,
            )
            login_account_devices(recipient_devices, assert_api, user_id=user_b)
            _assert_received_message_on_devices(
                recipient_devices,
                assert_api,
                event_type=Cmd.onMessagesReceived.value,
                real_id=real_id,
                user_a=user_a,
                user_b=user_b,
                body={"type": 0, "content": content, "translations": {}},
            )
        finally:
            _restore_case(
                device_a,
                device_b,
                user_a=user_a,
                user_b=user_b,
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )


@pytest.mark.parametrize(
    ("message_type", "payload_template", "sent_body", "received_body"),
    _MEDIA_CASES,
)
def test_chat_offline_media_message_received_after_login(
    topology,
    assert_api,
    message_type,
    payload_template,
    sent_body,
    received_body,
):
    """好友 B 离线时接收 file/image/video/voice，并保留媒体核心字段。"""
    with _allure_step("验证：好友 B 离线时接收 file/image/video/voice，并保留媒体核心字段。"):
        device_a, device_b, user_a, user_b, sender_devices, recipient_devices = _offline_endpoints(topology)
        payload = {
            key: (user_b if value == "{{userB}}" else value)
            for key, value in payload_template.items()
        }
        try:
            _prepare_offline_friend(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )
            _, real_id, _ = _assert_send_response_and_success(
                device_a,
                assert_api,
                type_key=message_type,
                payload=payload,
                user_a=user_a,
                user_b=user_b,
                response_body=sent_body,
                success_body=sent_body,
                ignore_keys=_MEDIA_DYNAMIC_KEYS,
            )
            login_account_devices(recipient_devices, assert_api, user_id=user_b)
            _assert_received_message_on_devices(
                recipient_devices,
                assert_api,
                event_type=Cmd.onMessagesReceived.value,
                real_id=real_id,
                user_a=user_a,
                user_b=user_b,
                body=received_body,
                ignore_keys=_MEDIA_DYNAMIC_KEYS,
            )
        finally:
            _restore_case(
                device_a,
                device_b,
                user_a=user_a,
                user_b=user_b,
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )


def test_chat_offline_location_message_received_after_login(
    topology,
    assert_api,
):
    """好友 B 离线时 A 发位置消息；B 重登收到完整位置业务字段。"""
    with _allure_step("验证：好友 B 离线时 A 发位置消息；B 重登收到完整位置业务字段。"):
        device_a, device_b, user_a, user_b, sender_devices, recipient_devices = _offline_endpoints(topology)
        address = f"offline-location-{uuid.uuid4().hex[:8]}"
        building_name = "offline-building"
        body = {
            "type": 3,
            "latitude": 30.2741,
            "longitude": 120.1551,
            "address": address,
            "buildingName": building_name,
        }
        try:
            _prepare_offline_friend(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )
            _, real_id, _ = _assert_send_response_and_success(
                device_a,
                assert_api,
                type_key="location",
                payload={
                    "targetId": user_b,
                    "latitude": body["latitude"],
                    "longitude": body["longitude"],
                    "address": address,
                    "buildingName": building_name,
                },
                user_a=user_a,
                user_b=user_b,
                response_body=body,
                success_body=body,
            )
            login_account_devices(recipient_devices, assert_api, user_id=user_b)
            _assert_received_message_on_devices(
                recipient_devices,
                assert_api,
                event_type=Cmd.onMessagesReceived.value,
                real_id=real_id,
                user_a=user_a,
                user_b=user_b,
                body=body,
            )
        finally:
            _restore_case(
                device_a,
                device_b,
                user_a=user_a,
                user_b=user_b,
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )


def test_chat_offline_custom_message_received_after_login(
    topology,
    assert_api,
):
    """好友 B 离线时 A 发自定义消息；B 重登收到事件名和参数。"""
    with _allure_step("验证：好友 B 离线时 A 发自定义消息；B 重登收到事件名和参数。"):
        device_a, device_b, user_a, user_b, sender_devices, recipient_devices = _offline_endpoints(topology)
        custom_event = f"offline-custom-{uuid.uuid4().hex[:8]}"
        params = {"source": "offline-p0", "value": "真实日志"}
        body = {"type": 7, "event": custom_event, "params": params}
        try:
            _prepare_offline_friend(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )
            _, real_id, _ = _assert_send_response_and_success(
                device_a,
                assert_api,
                type_key="custom",
                payload={
                    "targetId": user_b,
                    "event": custom_event,
                    "params": params,
                },
                user_a=user_a,
                user_b=user_b,
                response_body=body,
                success_body=body,
            )
            login_account_devices(recipient_devices, assert_api, user_id=user_b)
            _assert_received_message_on_devices(
                recipient_devices,
                assert_api,
                event_type=Cmd.onMessagesReceived.value,
                real_id=real_id,
                user_a=user_a,
                user_b=user_b,
                body=body,
            )
        finally:
            _restore_case(
                device_a,
                device_b,
                user_a=user_a,
                user_b=user_b,
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )


def test_chat_offline_combine_message_received_after_login(
    topology,
    assert_api,
):
    """好友 B 离线时 A 转发两条真实源消息；B 重登收到合并消息。"""
    with _allure_step("验证：好友 B 离线时 A 转发两条真实源消息；B 重登收到合并消息。"):
        device_a, device_b, user_a, user_b, sender_devices, recipient_devices = _offline_endpoints(topology)
        title = f"offline-combine-{uuid.uuid4().hex[:8]}"
        summary = "two offline source messages"
        compatible_text = "offline combine compatible"
        try:
            _establish_friendship(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )
            source_ids = []
            for index in range(2):
                content = f"offline-combine-source-{index}-{uuid.uuid4().hex[:6]}"
                _, source_id, _ = _assert_send_response_and_success(
                    device_a,
                    assert_api,
                    type_key="txt",
                    payload={"targetId": user_b, "content": content},
                    user_a=user_a,
                    user_b=user_b,
                    response_body={"type": 0, "content": content},
                    success_body={
                        "type": 0,
                        "content": content,
                        "translations": {},
                    },
                )
                source_received = _wait_message_event(
                    device_b,
                    Cmd.onMessagesReceived.value,
                    real_id=source_id,
                )
                _assert_received_message(
                    assert_api,
                    source_received,
                    event_type=Cmd.onMessagesReceived.value,
                    real_id=source_id,
                    user_a=user_a,
                    user_b=user_b,
                    body={"type": 0, "content": content, "translations": {}},
                )
                source_ids.append(source_id)
            device_a.drain_events(timeout=0.5)
            device_b.drain_events(timeout=0.5)
            logout_account_devices(recipient_devices, assert_api)
            _, real_id, _ = _assert_send_response_and_success(
                device_a,
                assert_api,
                type_key="combine",
                payload={
                    "targetId": user_b,
                    "title": title,
                    "summary": summary,
                    "compatibleText": compatible_text,
                    "msgIds": source_ids,
                },
                user_a=user_a,
                user_b=user_b,
                response_body={
                    "type": 8,
                    "title": title,
                    "summary": summary,
                    "compatibleText": compatible_text,
                    "fileStatus": 0,
                },
                success_body={
                    "type": 8,
                    "title": title,
                    "summary": summary,
                    "compatibleText": compatible_text,
                    "fileStatus": 1,
                },
                ignore_keys=_COMBINE_DYNAMIC_KEYS,
            )
            login_account_devices(recipient_devices, assert_api, user_id=user_b)
            _assert_received_message_on_devices(
                recipient_devices,
                assert_api,
                event_type=Cmd.onMessagesReceived.value,
                real_id=real_id,
                user_a=user_a,
                user_b=user_b,
                body={
                    "type": 8,
                    "title": title,
                    "summary": summary,
                    "compatibleText": compatible_text,
                    "fileStatus": 3,
                },
                ignore_keys=_COMBINE_DYNAMIC_KEYS,
            )
        finally:
            _restore_case(
                device_a,
                device_b,
                user_a=user_a,
                user_b=user_b,
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )


def test_chat_offline_cmd_message_received_after_login(
    topology,
    assert_api,
):
    """好友 B 离线时 A 发普通 CMD；B 登录后通过 CMD 专用事件接收。"""
    with _allure_step("验证：好友 B 离线时 A 发普通 CMD；B 登录后通过 CMD 专用事件接收。"):
        device_a, device_b, user_a, user_b, sender_devices, recipient_devices = _offline_endpoints(topology)
        action = f"offline-cmd-{uuid.uuid4().hex[:8]}"
        body = {"type": 6, "action": action, "deliverOnlineOnly": False}
        try:
            _prepare_offline_friend(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )
            _, real_id, _ = _assert_send_response_and_success(
                device_a,
                assert_api,
                type_key="cmd",
                payload={
                    "targetId": user_b,
                    "action": action,
                    "deliverOnlineOnly": False,
                },
                user_a=user_a,
                user_b=user_b,
                response_body=body,
                success_body=body,
            )
            login_account_devices(recipient_devices, assert_api, user_id=user_b)
            _assert_received_message_on_devices(
                recipient_devices,
                assert_api,
                event_type=Cmd.onCmdMessagesReceived.value,
                real_id=real_id,
                user_a=user_a,
                user_b=user_b,
                body=body,
            )
        finally:
            _restore_case(
                device_a,
                device_b,
                user_a=user_a,
                user_b=user_b,
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )


def test_chat_offline_deliver_online_only_not_received_after_login(
    topology,
    assert_api,
):
    """CMD 设置 deliverOnlineOnly=true 时，不进入离线 B 的本地消息库。"""
    with _allure_step("验证：CMD 设置 deliverOnlineOnly=true 时，不进入离线 B 的本地消息库。"):
        device_a, device_b, user_a, user_b, sender_devices, recipient_devices = _offline_endpoints(topology)
        action = f"offline-only-{uuid.uuid4().hex[:8]}"
        body = {"type": 6, "action": action, "deliverOnlineOnly": True}
        try:
            _prepare_offline_friend(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )
            _, real_id, _ = _assert_send_response_and_success(
                device_a,
                assert_api,
                type_key="cmd",
                payload={
                    "targetId": user_b,
                    "action": action,
                    "deliverOnlineOnly": True,
                },
                user_a=user_a,
                user_b=user_b,
                response_body=body,
                success_body=body,
            )
            login_account_devices(recipient_devices, assert_api, user_id=user_b)
            for endpoint in recipient_devices:
                deadline = time.monotonic() + 5.0
                seen_target = []
                while time.monotonic() < deadline:
                    event = endpoint.receive_message(
                        match_event_type=Cmd.onCmdMessagesReceived.value,
                        timeout=min(1.0, max(0.1, deadline - time.monotonic())),
                    )
                    for message in (((event or {}).get("data") or {}).get("messages") or []):
                        if str((message or {}).get("msgId")) == real_id:
                            seen_target.append(event)
                assert seen_target == [], (
                    f"online-only CMD 不应离线投递: endpoint={_device_name(endpoint)}, "
                    f"events={seen_target}"
                )
                local = endpoint.call(
                    "ChatManager",
                    Cmd.getMessage.value,
                    info={"msgId": real_id},
                )
                _assert_call(
                    assert_api,
                    local,
                    manager="ChatManager",
                    cmd=Cmd.getMessage.value,
                    device_name=_device_name(endpoint),
                    result=None,
                )
        finally:
            _restore_case(
                device_a,
                device_b,
                user_a=user_a,
                user_b=user_b,
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )


def test_chat_offline_multiple_text_messages_and_unread_count(
    topology,
    assert_api,
):
    """B 离线期间积压三条文本；上线后消息集合、未读数和最新消息一致。"""
    with _allure_step("验证：B 离线期间积压三条文本；上线后消息集合、未读数和最新消息一致。"):
        device_a, device_b, user_a, user_b, sender_devices, recipient_devices = _offline_endpoints(topology)
        contents = [f"offline-batch-{index}-{uuid.uuid4().hex[:6]}" for index in range(3)]
        try:
            _prepare_offline_friend(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )
            sent_messages = [
                (
                    _send_offline_text(
                        device_a,
                        assert_api,
                        user_a=user_a,
                        user_b=user_b,
                        content=content,
                    ),
                    content,
                )
                for content in contents
            ]
            id_to_content = dict(sent_messages)
            login_account_devices(recipient_devices, assert_api, user_id=user_b)
            expected_messages = [
                {
                    "msgId": message_id,
                    "from": user_a,
                    "to": user_b,
                    "convId": user_a,
                    "chatType": 0,
                    "direction": 1,
                    "status": 2,
                    "hasRead": False,
                    "needReadReceipt": False,
                    "isThread": False,
                    "isContentReplaced": False,
                    "deliverOnlineOnly": False,
                    "body": {
                        "type": 0,
                        "content": content,
                        "translations": {},
                    },
                }
                for message_id, content in sent_messages
            ]
            for endpoint in recipient_devices:
                received = endpoint.receive_message(
                    match_event_type=Cmd.onMessagesReceived.value,
                    timeout=60.0,
                )
                assert received is not None, (
                    f"{_device_name(endpoint)} 登录后未收到三条离线文本的聚合事件"
                )
                assert_api.assert_response_matches(
                    received,
                    expected={
                        "type": "event",
                        "eventType": Cmd.onMessagesReceived.value,
                        "data": {"messages": expected_messages},
                    },
                    ignore_keys=_MESSAGE_DYNAMIC_KEYS | {"hasDeliverAck"},
                )
            for endpoint in recipient_devices:
                unread = endpoint.call(
                "ConversationManager",
                Cmd.getUnreadMsgCount.value,
                info={"convId": user_a, "type": 0},
                )
                _assert_call(
                    assert_api,
                    unread,
                    manager="ConversationManager",
                    cmd=Cmd.getUnreadMsgCount.value,
                    device_name=_device_name(endpoint),
                    result=3,
                )
                latest = endpoint.call(
                "ConversationManager",
                Cmd.getLatestMessage.value,
                info={"convId": user_a, "type": 0},
                )
                assert_api.assert_response_matches(
                    latest,
                    expected={
                    "manager": "ConversationManager",
                    "cmd": Cmd.getLatestMessage.value,
                    "device": _device_name(endpoint),
                    "result": {
                        "msgId": list(id_to_content)[-1],
                        "from": user_a,
                        "to": user_b,
                        "convId": user_a,
                        "chatType": 0,
                        "direction": 1,
                        "body": {
                            "type": 0,
                            "content": contents[-1],
                            "translations": {},
                        },
                    },
                    },
                    ignore_keys=_MESSAGE_DYNAMIC_KEYS
                    | {
                    "status",
                    "hasRead",
                    "hasDeliverAck",
                    "isThread",
                    "isContentReplaced",
                    "deliverOnlineOnly",
                    },
                )
        finally:
            _restore_case(
                device_a,
                device_b,
                user_a=user_a,
                user_b=user_b,
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )


# @pytest.mark.skip(reason="5.0 送达回执机制实际不可用：原生 onMessageDelivered 回调存在但服务端不发送 DELIVER_ACK（离线/在线均实测不触发）")
def test_chat_offline_delivery_ack_after_recipient_login(
    topology,
    assert_api,
):
    """B 离线时发送文本，B 登录投递后 A 收到同一消息的送达回执。"""
    with _allure_step("验证：B 离线时发送文本，B 登录投递后 A 收到同一消息的送达回执。"):
        device_a, device_b, user_a, user_b, sender_devices, recipient_devices = _offline_endpoints(topology)
        content = f"offline-delivery-{uuid.uuid4().hex[:8]}"
        try:
            _prepare_offline_friend(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )
            resp = device_a.call(
                "ChatManager",
                Cmd.sendMessage.value,
                info=swt_to_send({
                    "type": "txt",
                    "payload": {"targetId": user_b, "content": content},
                    "chatType": 0,
                    "needReadReceipt": True,
                }),
            )
            temp_id = ((resp.get("result") or {}).get("msgId"))
            success = _wait_success_event(device_a, temp_id=temp_id)
            real_id = ((success.get("data") or {}).get("msg") or {}).get("msgId")
            assert isinstance(real_id, str) and real_id
            for endpoint in sender_devices:
                early = endpoint.receive_message(
                    match_event_type=Cmd.onMessagesDelivered.value,
                    timeout=3.0,
                )
                assert early is None, (
                    f"B 离线时不应提前收到送达回执: endpoint={_device_name(endpoint)}, "
                    f"event={early}"
                )
            login_account_devices(recipient_devices, assert_api, user_id=user_b)
            _assert_received_message_on_devices(
                recipient_devices,
                assert_api,
                event_type=Cmd.onMessagesReceived.value,
                real_id=real_id,
                user_a=user_a,
                user_b=user_b,
                body={"type": 0, "content": content, "translations": {}},
                ignore_keys={"needReadReceipt"},
            )
            for endpoint in sender_devices:
                delivered = _wait_message_event(
                    endpoint,
                    Cmd.onMessagesDelivered.value,
                    real_id=real_id,
                )
                assert_api.assert_response_matches(
                    delivered,
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
                                # 5.0：hasReadAck/needGroupAck 无此字段；hasDeliverAck 实测 False（DELIVER_ACK 收到后 isDelivered 仍 False）→ ignore
                                "hasDeliverAck": True,
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
            _restore_case(
                device_a,
                device_b,
                user_a=user_a,
                user_b=user_b,
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )
