"""单聊离线扩展投递：类型化送达回执与自动翻译。"""
from __future__ import annotations

import uuid
import time

import pytest

# 5.0：hasDeliverAck = isDelivered()（值场景相关：离线收、下载后均不恒定）→ 统一进 ignore
_DELIVERY_SKIP_KEYS = {"hasDeliverAck"}
# 5.0 送达回执需发送时标记 needReadReceipt=true（否则服务端不发送达确认）→ 接收/断言需忽略默认 False 锁值
_DELIVERY_FLAG_KEYS = {"needReadReceipt"}

from src import Cmd
from src.test_flow.offline_test_flow import (
    login_preserving_offline_events,
    logout_for_offline,
)
from tests.chat.test_chat_offline_message_delivery import (
    _COMBINE_DYNAMIC_KEYS,
    _MEDIA_DYNAMIC_KEYS,
    _MESSAGE_DYNAMIC_KEYS,
    _assert_call,
    _assert_received_message,
    _assert_send_response_and_success,
    _establish_friendship,
    _prepare_offline_friend,
    _restore_case,
    _wait_message_event,
)


pytestmark = [pytest.mark.client, pytest.mark.chat]


_TYPED_DELIVERY_CASES = [
    pytest.param(
        "file",
        {"targetId": "{{userB}}"},
        {"type": 5, "displayName": "bigPic.jpg", "fileStatus": 0},
        _MEDIA_DYNAMIC_KEYS,
        id="file",
    ),
    pytest.param(
        "image",
        {"targetId": "{{userB}}", "thumbnailLocalPath": ""},
        {"type": 1, "displayName": "bigPic.jpg", "fileStatus": 0},
        _MEDIA_DYNAMIC_KEYS,
        id="image",
    ),
    pytest.param(
        "video",
        {"targetId": "{{userB}}", "thumbnailLocalPath": ""},
        {"type": 2, "displayName": "video.mov", "fileStatus": 0, "duration": 0},
        _MEDIA_DYNAMIC_KEYS,
        id="video",
    ),
    pytest.param(
        "voice",
        {"targetId": "{{userB}}", "duration": 1},
        {"type": 4, "displayName": "voice.mp3", "fileStatus": 0, "duration": 1},
        _MEDIA_DYNAMIC_KEYS,
        id="voice",
    ),
    pytest.param(
        "location",
        {
            "targetId": "{{userB}}",
            "latitude": 30.2741,
            "longitude": 120.1551,
            "address": "offline-delivery-location",
            "buildingName": "offline-delivery-building",
        },
        {
            "type": 3,
            "latitude": 30.2741,
            "longitude": 120.1551,
            "address": "offline-delivery-location",
            "buildingName": "offline-delivery-building",
        },
        _MESSAGE_DYNAMIC_KEYS,
        id="location",
    ),
    pytest.param(
        "custom",
        {
            "targetId": "{{userB}}",
            "event": "offline-delivery-custom",
            "params": {"source": "offline-extended", "value": "delivery"},
        },
        {
            "type": 7,
            "event": "offline-delivery-custom",
            "params": {"source": "offline-extended", "value": "delivery"},
        },
        _MESSAGE_DYNAMIC_KEYS,
        id="custom",
    ),
]

_OFFLINE_DOWNLOAD_CASES = [
    pytest.param(
        "file",
        {"targetId": "{{userB}}"},
        {"type": 5, "displayName": "bigPic.jpg", "fileStatus": 0},
        {"type": 5, "displayName": "bigPic.jpg", "fileStatus": 0},
        {"type": 5, "displayName": "bigPic.jpg", "fileStatus": 3},
        [Cmd.downloadAttachment.value],
        id="file-attachment",
    ),
    pytest.param(
        "image",
        {"targetId": "{{userB}}", "thumbnailLocalPath": ""},
        {"type": 1, "displayName": "bigPic.jpg", "fileStatus": 0},
        {"type": 1, "displayName": "bigPic.jpg", "fileStatus": 0},
        {"type": 1, "displayName": "bigPic.jpg", "fileStatus": 3},
        [Cmd.downloadAttachment.value, Cmd.downloadThumbnail.value],
        id="image-attachment-thumbnail",
    ),
    pytest.param(
        "video",
        {"targetId": "{{userB}}", "thumbnailLocalPath": ""},
        {"type": 2, "displayName": "video.mov", "fileStatus": 0, "duration": 0},
        {"type": 2, "displayName": "video.mov", "fileStatus": 0, "duration": 0},
        {"type": 2, "displayName": "video.mov", "fileStatus": 3, "duration": 0},
        [Cmd.downloadAttachment.value, Cmd.downloadThumbnail.value],
        id="video-attachment-thumbnail",
    ),
    pytest.param(
        "voice",
        {"targetId": "{{userB}}", "duration": 1},
        {"type": 4, "displayName": "voice.mp3", "fileStatus": 0, "duration": 1},
        {"type": 4, "displayName": "voice.mp3", "fileStatus": 0, "duration": 1},
        {"type": 4, "displayName": "voice.mp3", "fileStatus": 0, "duration": 1},
        [Cmd.downloadAttachment.value],
        id="voice-attachment",
    ),
]


def _body_for_case(type_key: str, payload: dict, expected_body: dict, marker: str) -> dict:
    body = dict(expected_body)
    if type_key == "location":
        body["address"] = f"{expected_body['address']}-{marker}"
        body["buildingName"] = f"{expected_body['buildingName']}-{marker}"
        payload["address"] = body["address"]
        payload["buildingName"] = body["buildingName"]
    elif type_key == "custom":
        body["event"] = f"{expected_body['event']}-{marker}"
        payload["event"] = body["event"]
    return body


def _assert_delivered_message(
    assert_api,
    event: dict,
    *,
    real_id: str,
    user_a: str,
    user_b: str,
    body: dict,
    ignore_keys: set[str],
) -> None:
    # 5.0：hasReadAck/needGroupAck 无此字段（已删）；送达回执需 needReadReceipt=true；实证字段值：
    # needReadReceipt=True、isPeerRead=False（��达时对方未读）、readReceiptCount=0、hasDeliverAck=True
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
                        "hasDeliverAck": True,
                        "needReadReceipt": True,
                        "isPeerRead": False,
                        "readReceiptCount": 0,
                        "isThread": False,
                        "isContentReplaced": False,
                        "deliverOnlineOnly": False,
                        "body": body,
                    }
                ]
            },
        },
        # 发送方消息 body.fileStatus 实测恒 0（官方 4.x 锁 3，5.0 状态机变化已记录）→ 锁 0（body 参数已为 0）
        ignore_keys=ignore_keys,
    )


def _message_from_event(event: dict, *, real_id: str) -> dict:
    for message in (((event.get("data") or {}).get("messages")) or []):
        if isinstance(message, dict) and str(message.get("msgId")) == str(real_id):
            return message
    raise AssertionError(f"事件缺少目标消息: msgId={real_id}, event={event}")


def _wait_download_event(device, event_type: str, *, real_id: str, timeout: float = 60.0) -> dict:
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        event = device.receive_message(
            match_event_type=event_type,
            timeout=min(2.0, max(0.1, deadline - time.monotonic())),
        )
        if event:
            seen.append(event)
        if str(((event or {}).get("data") or {}).get("msgId")) == str(real_id):
            return event
    raise AssertionError(
        f"未收到下载终态事件: eventType={event_type}, msgId={real_id}, events={seen}"
    )


def _assert_download_response(
    assert_api,
    response: dict,
    *,
    cmd: str,
    real_id: str,
    user_a: str,
    user_b: str,
    body: dict,
) -> None:
    assert_api.assert_response_matches(
        response,
        expected={
            "manager": "ChatManager",
            "cmd": cmd,
            "device": "deviceB",
            "result": {
                "msgId": real_id,
                "from": user_a,
                "to": user_b,
                "convId": user_a,
                "chatType": 0,
                "direction": 1,
                "status": 2,
                "hasRead": False,
                "isThread": False,
                "isContentReplaced": False,
                "body": body,
            },
        },
        # 5.0：hasReadAck/needGroupAck 无此字段（已删）；hasDeliverAck=isDelivered() 下载后仍 False（场景相关）→ ignore
        ignore_keys=_MEDIA_DYNAMIC_KEYS | {"sequence", "hasDeliverAck"},
    )


def _assert_download_success_event(
    assert_api,
    event: dict,
    *,
    real_id: str,
    user_a: str,
    user_b: str,
    body: dict,
) -> None:
    assert_api.assert_response_matches(
        event,
        expected={
            "type": "event",
            "eventType": Cmd.onMessageSuccess.value,
            "data": {
                "msgId": real_id,
                "msg": {
                    "msgId": real_id,
                    "from": user_a,
                    "to": user_b,
                    "convId": user_a,
                    "chatType": 0,
                    "direction": 1,
                    "status": 2,
                    "hasRead": False,
                    "isThread": False,
                    "isContentReplaced": False,
                    "deliverOnlineOnly": False,
                    "body": body,
                },
            },
        },
        # 5.0：hasReadAck/needGroupAck 无此字段；hasDeliverAck 下载后仍 False（场景相关）→ ignore
        ignore_keys=_MEDIA_DYNAMIC_KEYS | {"hasDeliverAck"},
    )


@pytest.mark.parametrize(("type_key", "payload_template", "expected_body", "ignore_keys"), _TYPED_DELIVERY_CASES)
def test_chat_offline_typed_delivery_ack_after_recipient_login(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    type_key,
    payload_template,
    expected_body,
    ignore_keys,
):
    """B 离线时的类型消息仅在重登接收后触发 A 的真实送达回执（需发送标记 needReadReceipt）。"""
    marker = uuid.uuid4().hex[:8]
    payload = {
        key: (user_b if value == "{{userB}}" else value)
        for key, value in payload_template.items()
    }
    body = _body_for_case(type_key, payload, expected_body, marker)
    # 发送侧媒体状态与接收侧离线回放状态不同；location/custom 不包含 fileStatus。
    if type_key in {"file", "image", "video"}:
        received_body = {**body, "fileStatus": 3}
    elif type_key == "voice":
        received_body = {**body, "fileStatus": 0}
    else:
        received_body = body
    try:
        _prepare_offline_friend(device_a, device_b, assert_api, user_a=user_a, user_b=user_b)
        _, real_id, _ = _assert_send_response_and_success(
            device_a,
            assert_api,
            type_key=type_key,
            payload=payload,
            user_a=user_a,
            user_b=user_b,
            response_body=body,
            success_body=body,
            ignore_keys=ignore_keys,
            need_read_receipt=True,
        )
        login_preserving_offline_events(device_b, assert_api, device_name="deviceB", user_id=user_b)
        received = _wait_message_event(device_b, Cmd.onMessagesReceived.value, real_id=real_id)
        _assert_received_message(
            assert_api,
            received,
            event_type=Cmd.onMessagesReceived.value,
            real_id=real_id,
            user_a=user_a,
            user_b=user_b,
            body=received_body,
            ignore_keys=ignore_keys | _DELIVERY_FLAG_KEYS,
        )
        delivered = _wait_message_event(device_a, Cmd.onMessagesDelivered.value, real_id=real_id)
        _assert_delivered_message(
            assert_api,
            delivered,
            real_id=real_id,
            user_a=user_a,
            user_b=user_b,
            body=body,
            ignore_keys=ignore_keys,
        )
    finally:
        _restore_case(device_a, device_b, user_a=user_a, user_b=user_b)


@pytest.mark.parametrize(
    (
        "type_key",
        "payload_template",
        "response_body",
        "success_body",
        "received_body",
        "download_cmds",
    ),
    _OFFLINE_DOWNLOAD_CASES,
)
def test_chat_offline_received_media_downloads_after_recipient_login(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    type_key,
    payload_template,
    response_body,
    success_body,
    received_body,
    download_cmds,
):
    """B 使用离线回放的原始媒体消息下载附件；图片/视频同时覆盖缩略图。"""
    payload = {
        key: (user_b if value == "{{userB}}" else value)
        for key, value in payload_template.items()
    }
    try:
        _prepare_offline_friend(device_a, device_b, assert_api, user_a=user_a, user_b=user_b)
        _, real_id, _ = _assert_send_response_and_success(
            device_a,
            assert_api,
            type_key=type_key,
            payload=payload,
            user_a=user_a,
            user_b=user_b,
            response_body=response_body,
            success_body=success_body,
            ignore_keys=_MEDIA_DYNAMIC_KEYS,
        )
        login_preserving_offline_events(
            device_b, assert_api, device_name="deviceB", user_id=user_b
        )
        received = _wait_message_event(
            device_b, Cmd.onMessagesReceived.value, real_id=real_id
        )
        _assert_received_message(
            assert_api,
            received,
            event_type=Cmd.onMessagesReceived.value,
            real_id=real_id,
            user_a=user_a,
            user_b=user_b,
            body=received_body,
            ignore_keys=_MEDIA_DYNAMIC_KEYS,
        )
        raw_message = _message_from_event(received, real_id=real_id)
        current_body = dict(received_body)
        for cmd in download_cmds:
            response = device_b.call(
                "ChatManager", cmd, info={"message": raw_message}
            )
            if cmd == Cmd.downloadThumbnail.value and type_key == "video":
                assert_api.assert_response_matches(
                    response,
                    expected={
                        "manager": "ChatManager",
                        "cmd": Cmd.downloadThumbnail.value,
                        "device": "deviceB",
                        "result": {
                            "msgId": real_id,
                            "from": user_a,
                            "to": user_b,
                            "convId": user_a,
                            "chatType": 0,
                            "direction": 1,
                            "body": current_body,
                        },
                    },
                    ignore_keys=_MEDIA_DYNAMIC_KEYS
                    | {
                        "sequence",
                        "status",
                        "hasRead",
                        "hasDeliverAck",
                        "isThread",
                        "isContentReplaced",
                        "deliverOnlineOnly",
                    },
                )
                error = _wait_download_event(
                    device_b, Cmd.onMessageError.value, real_id=real_id
                )
                assert_api.assert_response_matches(
                    error,
                    expected={
                        "type": "event",
                        "eventType": Cmd.onMessageError.value,
                        "data": {
                            "msgId": real_id,
                            "error": {
                                "code": 403,
                                "description": "Failed to download the file",
                            },
                        },
                    },
                    ignore_keys={"timestamp", "sequence", "msg"},
                )
                continue
            response_body = dict(current_body)
            success_body = dict(current_body)
            if cmd == Cmd.downloadAttachment.value:
                response_body["fileStatus"] = 0
                success_body["fileStatus"] = 1
            _assert_download_response(
                assert_api,
                response,
                cmd=cmd,
                real_id=real_id,
                user_a=user_a,
                user_b=user_b,
                body=response_body,
            )
            success = _wait_download_event(
                device_b, Cmd.onMessageSuccess.value, real_id=real_id
            )
            _assert_download_success_event(
                assert_api,
                success,
                real_id=real_id,
                user_a=user_a,
                user_b=user_b,
                body=success_body,
            )
            raw_message = ((success.get("data") or {}).get("msg") or raw_message)
            current_body = success_body
    finally:
        _restore_case(device_a, device_b, user_a=user_a, user_b=user_b)


def test_chat_offline_combine_delivery_ack_after_recipient_login(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """真实源消息组成 combine；B 离线重登接收后 A 才收到送达回执（源消息与 combine 均需标记 needReadReceipt）。"""
    marker = uuid.uuid4().hex[:8]
    title = f"offline-delivery-combine-{marker}"
    summary = "offline combine delivery summary"
    compatible_text = "offline combine delivery compatible"
    try:
        _establish_friendship(device_a, device_b, assert_api, user_a=user_a, user_b=user_b)
        source_ids = []
        for index in range(2):
            content = f"offline-delivery-source-{index}-{marker}"
            _, source_id, _ = _assert_send_response_and_success(
                device_a,
                assert_api,
                type_key="txt",
                payload={"targetId": user_b, "content": content},
                user_a=user_a,
                user_b=user_b,
                response_body={"type": 0, "content": content},
                success_body={"type": 0, "content": content, "translations": {}},
                need_read_receipt=True,
            )
            received_source = _wait_message_event(
                device_b, Cmd.onMessagesReceived.value, real_id=source_id
            )
            _assert_received_message(
                assert_api,
                received_source,
                event_type=Cmd.onMessagesReceived.value,
                real_id=source_id,
                user_a=user_a,
                user_b=user_b,
                body={"type": 0, "content": content, "translations": {}},
                ignore_keys=_DELIVERY_FLAG_KEYS,
            )
            _wait_message_event(device_a, Cmd.onMessagesDelivered.value, real_id=source_id)
            source_ids.append(source_id)
        device_a.drain_events(timeout=0.5)
        device_b.drain_events(timeout=0.5)
        logout_for_offline(device_b, assert_api, device_name="deviceB")
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
            need_read_receipt=True,
        )
        login_preserving_offline_events(
            device_b, assert_api, device_name="deviceB", user_id=user_b
        )
        received = _wait_message_event(
            device_b, Cmd.onMessagesReceived.value, real_id=real_id
        )
        received_body = {
            "type": 8,
            "title": title,
            "summary": summary,
            "compatibleText": compatible_text,
            "fileStatus": 3,
        }
        _assert_received_message(
            assert_api,
            received,
            event_type=Cmd.onMessagesReceived.value,
            real_id=real_id,
            user_a=user_a,
            user_b=user_b,
            body=received_body,
            ignore_keys=_COMBINE_DYNAMIC_KEYS | _DELIVERY_FLAG_KEYS,
        )
        delivered = _wait_message_event(
            device_a, Cmd.onMessagesDelivered.value, real_id=real_id
        )
        _assert_delivered_message(
            assert_api,
            delivered,
            real_id=real_id,
            user_a=user_a,
            user_b=user_b,
            body={
                "type": 8,
                "title": title,
                "summary": summary,
                "compatibleText": compatible_text,
                "fileStatus": 1,
            },
            ignore_keys=_COMBINE_DYNAMIC_KEYS,
        )
    finally:
        _restore_case(device_a, device_b, user_a=user_a, user_b=user_b)


def test_chat_offline_text_automatic_translation_after_recipient_login(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """带 targetLanguages 的文本在 B 离线期间发送，重登后保留真实翻译结果。"""
    # 翻译引擎会把内容中的英文后缀转大写（实测）→ 后缀用数字保证翻译结果可预测
    suffix = str(int(time.time_ns() % 100000000))
    content = f"offline-translation-{suffix}"
    body = {
        "type": 0,
        "content": content,
        "targetLanguages": ["zh-Hans"],
        "translations": {"zh-Hans": f"离线翻译-{suffix}"},
    }
    try:
        _prepare_offline_friend(device_a, device_b, assert_api, user_a=user_a, user_b=user_b)
        _, real_id, _ = _assert_send_response_and_success(
            device_a,
            assert_api,
            type_key="txt",
            payload={"targetId": user_b, "content": content, "targetLanguages": ["zh-Hans"]},
            user_a=user_a,
            user_b=user_b,
            response_body={"type": 0, "content": content, "targetLanguages": ["zh-Hans"]},
            success_body=body,
            ignore_keys=_MESSAGE_DYNAMIC_KEYS - {"targetLanguages"},
        )
        login_preserving_offline_events(device_b, assert_api, device_name="deviceB", user_id=user_b)
        received = _wait_message_event(device_b, Cmd.onMessagesReceived.value, real_id=real_id)
        _assert_received_message(
            assert_api,
            received,
            event_type=Cmd.onMessagesReceived.value,
            real_id=real_id,
            user_a=user_a,
            user_b=user_b,
            body=body,
            ignore_keys=_MESSAGE_DYNAMIC_KEYS,
        )
    finally:
        _restore_case(device_a, device_b, user_a=user_a, user_b=user_b)


def test_chat_offline_mixed_backlog_local_state_after_recipient_login(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """B 离线积压四类消息；按 ID 集合核对回放、本地、历史、未读和最新消息。"""
    marker = uuid.uuid4().hex[:8]
    text_body = {
        "type": 0,
        "content": f"offline-mixed-text-{marker}",
        "translations": {},
    }
    location_body = {
        "type": 3,
        "latitude": 30.2741,
        "longitude": 120.1551,
        "address": f"offline-mixed-location-{marker}",
        "buildingName": "offline-mixed-building",
    }
    custom_body = {
        "type": 7,
        "event": f"offline-mixed-custom-{marker}",
        "params": {"source": "offline-mixed", "revision": "1"},
    }
    title = f"offline-mixed-combine-{marker}"
    combine_sender_body = {
        "type": 8,
        "title": title,
        "summary": "offline mixed combine summary",
        "compatibleText": "offline mixed combine compatible",
        "fileStatus": 1,
    }
    combine_received_body = {**combine_sender_body, "fileStatus": 3}
    try:
        _establish_friendship(device_a, device_b, assert_api, user_a=user_a, user_b=user_b)
        source_ids: list[str] = []
        for index in range(2):
            source_content = f"offline-mixed-source-{index}-{marker}"
            _, source_id, _ = _assert_send_response_and_success(
                device_a,
                assert_api,
                type_key="txt",
                payload={"targetId": user_b, "content": source_content},
                user_a=user_a,
                user_b=user_b,
                response_body={"type": 0, "content": source_content},
                success_body={
                    "type": 0,
                    "content": source_content,
                    "translations": {},
                },
            )
            source_received = _wait_message_event(
                device_b, Cmd.onMessagesReceived.value, real_id=source_id
            )
            _assert_received_message(
                assert_api,
                source_received,
                event_type=Cmd.onMessagesReceived.value,
                real_id=source_id,
                user_a=user_a,
                user_b=user_b,
                body={
                    "type": 0,
                    "content": source_content,
                    "translations": {},
                },
            )
            source_ids.append(source_id)

        cleared = device_b.call(
            "ConversationManager",
            Cmd.clearAllMessages.value,
            info={"convId": user_a, "type": 0},
        )
        _assert_call(
            assert_api,
            cleared,
            manager="ConversationManager",
            cmd=Cmd.clearAllMessages.value,
            device_name="deviceB",
            result=True,
        )
        marked = device_b.call(
            "ConversationManager",
            Cmd.markAllMessagesAsRead.value,
            info={"convId": user_a, "type": 0},
        )
        _assert_call(
            assert_api,
            marked,
            manager="ConversationManager",
            cmd=Cmd.markAllMessagesAsRead.value,
            device_name="deviceB",
            result=True,
        )
        device_a.drain_events(timeout=0.5)
        device_b.drain_events(timeout=0.5)
        logout_for_offline(device_b, assert_api, device_name="deviceB")

        messages: list[tuple[str, dict, set[str]]] = []
        _, text_id, _ = _assert_send_response_and_success(
            device_a,
            assert_api,
            type_key="txt",
            payload={"targetId": user_b, "content": text_body["content"]},
            user_a=user_a,
            user_b=user_b,
            response_body={"type": 0, "content": text_body["content"]},
            success_body=text_body,
        )
        messages.append((text_id, text_body, _MESSAGE_DYNAMIC_KEYS | _DELIVERY_SKIP_KEYS))
        _, location_id, _ = _assert_send_response_and_success(
            device_a,
            assert_api,
            type_key="location",
            payload={"targetId": user_b, **{k: v for k, v in location_body.items() if k != "type"}},
            user_a=user_a,
            user_b=user_b,
            response_body=location_body,
            success_body=location_body,
        )
        messages.append((location_id, location_body, _MESSAGE_DYNAMIC_KEYS | _DELIVERY_SKIP_KEYS))
        _, custom_id, _ = _assert_send_response_and_success(
            device_a,
            assert_api,
            type_key="custom",
            payload={"targetId": user_b, "event": custom_body["event"], "params": custom_body["params"]},
            user_a=user_a,
            user_b=user_b,
            response_body=custom_body,
            success_body=custom_body,
        )
        messages.append((custom_id, custom_body, _MESSAGE_DYNAMIC_KEYS | _DELIVERY_SKIP_KEYS))
        _, combine_id, _ = _assert_send_response_and_success(
            device_a,
            assert_api,
            type_key="combine",
            payload={
                "targetId": user_b,
                "title": title,
                "summary": combine_sender_body["summary"],
                "compatibleText": combine_sender_body["compatibleText"],
                "msgIds": source_ids,
            },
            user_a=user_a,
            user_b=user_b,
            response_body={**combine_sender_body, "fileStatus": 0},
            success_body=combine_sender_body,
            ignore_keys=_COMBINE_DYNAMIC_KEYS,
        )
        messages.append((combine_id, combine_received_body, _COMBINE_DYNAMIC_KEYS | _DELIVERY_SKIP_KEYS))
        expected_by_id = {
            message_id: {
                "msgId": message_id,
                "from": user_a,
                "to": user_b,
                "convId": user_a,
                "chatType": 0,
                "direction": 1,
                "status": 2,
                "hasRead": False,
                "isThread": False,
                "isContentReplaced": False,
                "deliverOnlineOnly": False,
                "body": body,
            }
            for message_id, body, _ in messages
        }

        login_preserving_offline_events(
            device_b, assert_api, device_name="deviceB", user_id=user_b
        )
        pending = set(expected_by_id)
        deadline = time.monotonic() + 60.0
        while pending and time.monotonic() < deadline:
            event = device_b.receive_message(
                match_event_type=Cmd.onMessagesReceived.value, timeout=3.0
            )
            if not event:
                continue
            actual_messages = ((event.get("data") or {}).get("messages") or [])
            actual_ids = [
                str(item.get("msgId"))
                for item in actual_messages
                if isinstance(item, dict)
            ]
            target_ids = [message_id for message_id in actual_ids if message_id in expected_by_id]
            if not target_ids:
                continue
            assert len(target_ids) == len(actual_ids), f"离线混合回放夹带非目标消息: {event}"
            assert_api.assert_response_matches(
                event,
                expected={
                    "type": "event",
                    "eventType": Cmd.onMessagesReceived.value,
                    "data": {"messages": [expected_by_id[mid] for mid in actual_ids]},
                },
                ignore_keys=_COMBINE_DYNAMIC_KEYS | _DELIVERY_SKIP_KEYS,
            )
            pending.difference_update(target_ids)
        assert pending == set(), f"B 上线后缺少混合离线消息: {sorted(pending)}"

        for message_id, body, ignore_keys in messages:
            local = device_b.call(
                "ChatManager", Cmd.getMessage.value, info={"msgId": message_id}
            )
            local_expected = dict(expected_by_id[message_id])
            local_expected.pop("deliverOnlineOnly")
            assert_api.assert_response_matches(
                local,
                expected={
                    "manager": "ChatManager",
                    "cmd": Cmd.getMessage.value,
                    "device": "deviceB",
                    "result": local_expected,
                },
                ignore_keys=ignore_keys,
            )

        unread = device_b.call(
            "ConversationManager",
            Cmd.getUnreadMsgCount.value,
            info={"convId": user_a, "type": 0},
        )
        _assert_call(
            assert_api,
            unread,
            manager="ConversationManager",
            cmd=Cmd.getUnreadMsgCount.value,
            device_name="deviceB",
            result=4,
        )
        latest_expected = dict(expected_by_id[combine_id])
        latest_expected.pop("deliverOnlineOnly")
        latest = device_b.call(
            "ConversationManager",
            Cmd.getLatestMessage.value,
            info={"convId": user_a, "type": 0},
        )
        assert_api.assert_response_matches(
            latest,
            expected={
                "manager": "ConversationManager",
                "cmd": Cmd.getLatestMessage.value,
                "device": "deviceB",
                "result": latest_expected,
            },
            ignore_keys=_COMBINE_DYNAMIC_KEYS,
        )

        history = None
        history_ids: set[str] = set()
        for _ in range(5):
            history = device_b.call(
                "ChatManager",
                Cmd.fetchHistoryMessages.value,
                info={
                    "convId": user_a,
                    "type": 0,
                    "pageSize": 50,
                    "startMsgId": "",
                    "direction": 0,
                },
            )
            history_ids = {
                str(item.get("msgId"))
                for item in (((history.get("result") or {}).get("list")) or [])
                if isinstance(item, dict) and str(item.get("msgId")) in expected_by_id
            }
            if history_ids == set(expected_by_id):
                break
            time.sleep(2)
        assert_api.assert_response_matches(
            {
                "manager": (history or {}).get("manager"),
                "cmd": (history or {}).get("cmd"),
                "device": (history or {}).get("device"),
                "result": {"targetIds": sorted(history_ids)},
            },
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.fetchHistoryMessages.value,
                "device": "deviceB",
                "result": {"targetIds": sorted(expected_by_id)},
            },
        )

    finally:
        _restore_case(device_a, device_b, user_a=user_a, user_b=user_b)
