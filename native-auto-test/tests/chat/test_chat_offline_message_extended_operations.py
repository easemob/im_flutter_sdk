"""单聊离线扩展后操作：首次接收前变更、类型化已读与撤回。"""
from __future__ import annotations

import time
import uuid

import pytest

from src import Cmd, gt
from src.test_flow.offline_test_flow import (
    login_account_devices,
    logout_account_devices,
)
from tests.chat.test_chat_offline_message_delivery import (
    _COMBINE_DYNAMIC_KEYS,
    _MEDIA_DYNAMIC_KEYS,
    _MESSAGE_DYNAMIC_KEYS,
    _assert_call,
    _assert_received_message,
    _assert_send_response_and_success,
    _device_name,
    _establish_friendship,
    _offline_endpoints,
    _prepare_offline_friend,
    _restore_case,
    _wait_message_event,
)

# 5.0 已读/送达回执需发送标记 needReadReceipt=true（否则接收端 asyncSendMessageReadReceipts 跳过、服务端不发送达确认）
_DELIVERY_FLAG_KEYS = {"needReadReceipt"}
# 5.0 媒体 body.fileStatus 由 endpoint 本地状态决定；已读/撤回事件也可能返回
# 发送完成或离线回放后的状态，不能把它固定为发送时的 0/1/3。
_MEDIA_BODY_DYNAMIC = {"data.messages[0].body.fileStatus"}
_MEDIA_RECALL_BODY_DYNAMIC = {"data.infos[0].msg.body.fileStatus"}
from tests.chat.test_chat_offline_message_operations import (
    _assert_message_lookup_on_devices,
    _wait_content_changed,
    _wait_recall_info,
)
from tests.allure_helpers import _allure_step


pytestmark = [
    pytest.mark.client,
    pytest.mark.chat,
    pytest.mark.topology("account_a_to_account_b"),
]


def _assert_event_response(assert_api, event, *, expected, ignore_keys=None) -> None:
    events = event if isinstance(event, (tuple, list)) else (event,)
    for endpoint_event in events:
        assert_api.assert_response_matches(
            endpoint_event,
            expected=expected,
            ignore_keys=ignore_keys,
        )


_TYPED_OPERATION_CASES = [
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
    pytest.param(
        "location",
        {
            "targetId": "{{userB}}",
            "latitude": 30.2741,
            "longitude": 120.1551,
            "address": "offline-operation-location",
            "buildingName": "offline-operation-building",
        },
        {
            "type": 3,
            "latitude": 30.2741,
            "longitude": 120.1551,
            "address": "offline-operation-location",
            "buildingName": "offline-operation-building",
        },
        {
            "type": 3,
            "latitude": 30.2741,
            "longitude": 120.1551,
            "address": "offline-operation-location",
            "buildingName": "offline-operation-building",
        },
        id="location",
    ),
    pytest.param(
        "custom",
        {
            "targetId": "{{userB}}",
            "event": "offline-operation-custom",
            "params": {"source": "offline-extended", "value": "operation"},
        },
        {
            "type": 7,
            "event": "offline-operation-custom",
            "params": {"source": "offline-extended", "value": "operation"},
        },
        {
            "type": 7,
            "event": "offline-operation-custom",
            "params": {"source": "offline-extended", "value": "operation"},
        },
        id="custom",
    ),
]


def _case_payload_and_bodies(
    type_key: str,
    payload_template: dict,
    sent_template: dict,
    received_template: dict,
    user_b: str,
) -> tuple[dict, dict, dict]:
    marker = uuid.uuid4().hex[:8]
    payload = {
        key: (user_b if value == "{{userB}}" else value)
        for key, value in payload_template.items()
    }
    sent_body = dict(sent_template)
    received_body = dict(received_template)
    if type_key == "location":
        for key in ("address", "buildingName"):
            payload[key] = f"{payload[key]}-{marker}"
            sent_body[key] = payload[key]
            received_body[key] = payload[key]
    elif type_key == "custom":
        payload["event"] = f"{payload['event']}-{marker}"
        sent_body["event"] = payload["event"]
        received_body["event"] = payload["event"]
    return payload, sent_body, received_body


def _send_online_typed(
    device_a,
    device_b,
    assert_api,
    *,
    user_a: str,
    user_b: str,
    type_key: str,
    payload: dict,
    sent_body: dict,
    received_body: dict,
    need_read_receipt: bool = False,
) -> tuple[str, dict]:
    ignore_keys = _MEDIA_DYNAMIC_KEYS if type_key in {"file", "image", "video", "voice"} else _MESSAGE_DYNAMIC_KEYS
    response_body = dict(sent_body)
    if type_key == "txt":
        response_body.pop("translations", None)
    _, real_id, _ = _assert_send_response_and_success(
        device_a,
        assert_api,
        type_key=type_key,
        payload=payload,
        user_a=user_a,
        user_b=user_b,
        response_body=response_body,
        success_body=sent_body,
        need_read_receipt=need_read_receipt,
        ignore_keys=ignore_keys,
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
        # fileStatus 是 5.0 endpoint 的本地状态；不锁 4.x 或某个平台的固定值。
        ignore_keys=ignore_keys | _DELIVERY_FLAG_KEYS,
    )
    return real_id, received


def _send_online_combine(
    device_a,
    device_b,
    assert_api,
    *,
    user_a: str,
    user_b: str,
    need_read_receipt: bool = False,
) -> tuple[str, dict, dict]:
    marker = uuid.uuid4().hex[:8]
    source_ids: list[str] = []
    for index in range(2):
        content = f"offline-operation-combine-source-{index}-{marker}"
        source_id, _ = _send_online_typed(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            type_key="txt",
            payload={"targetId": user_b, "content": content},
            sent_body={"type": 0, "content": content, "translations": {}},
            received_body={"type": 0, "content": content, "translations": {}},
        )
        source_ids.append(source_id)

    title = f"offline-operation-combine-{marker}"
    summary = "offline operation combine summary"
    compatible_text = "offline operation combine compatible"
    response_body = {
        "type": 8,
        "title": title,
        "summary": summary,
        "compatibleText": compatible_text,
        "fileStatus": 0,
    }
    sender_body = {**response_body, "fileStatus": 1}
    received_body = {**response_body, "fileStatus": 3}
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
        response_body=response_body,
        success_body=sender_body,
        ignore_keys=_COMBINE_DYNAMIC_KEYS,
        need_read_receipt=need_read_receipt,
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
        ignore_keys=_COMBINE_DYNAMIC_KEYS | _DELIVERY_FLAG_KEYS,
    )
    return real_id, sender_body, received_body


def _assert_read_event(
    assert_api,
    event: dict,
    *,
    real_id: str,
    user_a: str,
    user_b: str,
    body: dict,
    ignore_keys: set[str],
) -> None:
    if isinstance(event, (tuple, list)):
        for endpoint_event in event:
            _assert_read_event(
                assert_api,
                endpoint_event,
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
                        "isPeerRead": True,
                        "needReadReceipt": True,
                        "readReceiptCount": 0,
                        "hasDeliverAck": True,
                        "isThread": False,
                        "isContentReplaced": False,
                        "deliverOnlineOnly": False,
                        "body": body,
                    }
                ]
            },
        },
        # 已读事件仍校验消息身份和正文；媒体 fileStatus 不锁固定值。
        ignore_keys=ignore_keys,
    )


def _assert_recall_info(
    assert_api,
    event: dict,
    *,
    real_id: str,
    user_a: str,
    user_b: str,
    body: dict,
    ignore_keys: set[str],
) -> None:
    if isinstance(event, (tuple, list)):
        for endpoint_event in event:
            _assert_recall_info(
                assert_api,
                endpoint_event,
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
                            "isPeerRead": False,
                            "hasDeliverAck": False,
                            "needReadReceipt": False,
                            "isThread": False,
                            "isContentReplaced": False,
                            "deliverOnlineOnly": False,
                            "body": body,
                        },
                        "ext": "",
                    }
                ]
            },
        },
        # 撤回消息的媒体 fileStatus 也由 endpoint 状态机决定。
        ignore_keys=ignore_keys,
    )


def _assert_pre_receive_recall_events(
    assert_api,
    recalled_info: dict,
    *,
    real_id: str,
    user_a: str,
) -> None:
    if isinstance(recalled_info, (tuple, list)):
        for endpoint_event in recalled_info:
            _assert_pre_receive_recall_events(
                assert_api,
                endpoint_event,
                real_id=real_id,
                user_a=user_a,
            )
        return
    assert_api.assert_response_matches(
        recalled_info,
        expected={
            "type": "event",
            "eventType": Cmd.onMessagesRecalledInfo.value,
            "data": {
                "infos": [
                    {
                        "recallBy": user_a,
                        "recallMsgId": real_id,
                        "convId": user_a,
                        "ext": "",
                    }
                ]
            },
        },
        ignore_keys={"timestamp"},
    )


@pytest.mark.parametrize(
    ("type_key", "payload_template", "sent_template", "received_template"),
    _TYPED_OPERATION_CASES,
)
def test_chat_offline_typed_message_read_after_sender_relogin(
    topology,
    assert_api,
    type_key,
    payload_template,
    sent_template,
    received_template,
):
    """A 离线期间 B 已读类型消息；A 重登收到同一 msgId 的已读回执。"""
    with _allure_step("验证：A 离线期间 B 已读类型消息；A 重登收到同一 msgId 的已读回执。"):
        device_a, device_b, user_a, user_b, sender_devices, recipient_devices = _offline_endpoints(topology)
        payload, sent_body, received_body = _case_payload_and_bodies(
            type_key, payload_template, sent_template, received_template, user_b
        )
        ignore_keys = _MEDIA_DYNAMIC_KEYS if type_key in {"file", "image", "video", "voice"} else _MESSAGE_DYNAMIC_KEYS
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
            real_id, _ = _send_online_typed(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                type_key=type_key,
                payload=payload,
                sent_body=sent_body,
                received_body=received_body,
                need_read_receipt=True,
            )
            device_a.drain_events(timeout=0.5)
            logout_account_devices(sender_devices, assert_api)
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
                device_name=_device_name(device_b),
                result=True,
            )
            login_account_devices(sender_devices, assert_api, user_id=user_a)
            read = _wait_message_event(
                sender_devices, Cmd.onMessagesRead.value, real_id=real_id
            )
            _assert_read_event(
                assert_api,
                read,
                real_id=real_id,
                user_a=user_a,
                user_b=user_b,
                body=sent_body,
                ignore_keys=ignore_keys
                | (_MEDIA_BODY_DYNAMIC if "fileStatus" in sent_body else set()),
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
    ("type_key", "payload_template", "sent_template", "received_template"),
    _TYPED_OPERATION_CASES,
)
def test_chat_offline_typed_message_recall_after_recipient_relogin(
    topology,
    assert_api,
    type_key,
    payload_template,
    sent_template,
    received_template,
):
    """B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除。"""
    with _allure_step("验证：B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除。"):
        device_a, device_b, user_a, user_b, sender_devices, recipient_devices = _offline_endpoints(topology)
        payload, sent_body, received_body = _case_payload_and_bodies(
            type_key, payload_template, sent_template, received_template, user_b
        )
        ignore_keys = _MEDIA_DYNAMIC_KEYS if type_key in {"file", "image", "video", "voice"} else _MESSAGE_DYNAMIC_KEYS
        recall_body = received_body
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
            real_id, _ = _send_online_typed(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                type_key=type_key,
                payload=payload,
                sent_body=sent_body,
                received_body=received_body,
            )
            device_b.drain_events(timeout=0.5)
            logout_account_devices(recipient_devices, assert_api)
            recall = device_a.call(
                "ChatManager", Cmd.recallMessage.value, info={"msgId": real_id}
            )
            _assert_call(
                assert_api,
                recall,
                manager="ChatManager",
                cmd=Cmd.recallMessage.value,
                device_name=_device_name(device_a),
                result=True,
            )
            login_account_devices(recipient_devices, assert_api, user_id=user_b)
            recalled_info = _wait_recall_info(recipient_devices, real_id=real_id)
            _assert_recall_info(
                assert_api,
                recalled_info,
                real_id=real_id,
                user_a=user_a,
                user_b=user_b,
                body=recall_body,
                ignore_keys=ignore_keys
                | (_MEDIA_RECALL_BODY_DYNAMIC if "fileStatus" in recall_body else set()),
            )
            _assert_message_lookup_on_devices(
                recipient_devices,
                assert_api,
                msg_id=real_id,
                expected_result=None,
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


def test_chat_offline_combine_message_read_after_sender_relogin(
    topology,
    assert_api,
):
    """A 离线期间 B 已读 combine；A 重登收到同一 msgId 的已读回执。"""
    with _allure_step("验证：A 离线期间 B 已读 combine；A 重登收到同一 msgId 的已读回执。"):
        device_a, device_b, user_a, user_b, sender_devices, recipient_devices = _offline_endpoints(topology)
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
            real_id, sender_body, _ = _send_online_combine(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                need_read_receipt=True,
            )
            device_a.drain_events(timeout=0.5)
            logout_account_devices(sender_devices, assert_api)
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
                device_name=_device_name(device_b),
                result=True,
            )
            login_account_devices(sender_devices, assert_api, user_id=user_a)
            read = _wait_message_event(
                sender_devices, Cmd.onMessagesRead.value, real_id=real_id
            )
            _assert_read_event(
                assert_api,
                read,
                real_id=real_id,
                user_a=user_a,
                user_b=user_b,
                body=sender_body,
                ignore_keys=_COMBINE_DYNAMIC_KEYS | _MEDIA_BODY_DYNAMIC,
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


def test_chat_offline_combine_message_recall_after_recipient_relogin(
    topology,
    assert_api,
):
    """B 已收 combine 后离线；A 撤回后 B 重登收到原 combine 信息。"""
    with _allure_step("验证：B 已收 combine 后离线；A 撤回后 B 重登收到原 combine 信息。"):
        device_a, device_b, user_a, user_b, sender_devices, recipient_devices = _offline_endpoints(topology)
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
            real_id, _, received_body = _send_online_combine(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
            )
            device_b.drain_events(timeout=0.5)
            logout_account_devices(recipient_devices, assert_api)
            recall = device_a.call(
                "ChatManager", Cmd.recallMessage.value, info={"msgId": real_id}
            )
            _assert_call(
                assert_api,
                recall,
                manager="ChatManager",
                cmd=Cmd.recallMessage.value,
                device_name=_device_name(device_a),
                result=True,
            )
            login_account_devices(recipient_devices, assert_api, user_id=user_b)
            recalled_info = _wait_recall_info(recipient_devices, real_id=real_id)
            _assert_recall_info(
                assert_api,
                recalled_info,
                real_id=real_id,
                user_a=user_a,
                user_b=user_b,
                body=received_body,
                ignore_keys=_COMBINE_DYNAMIC_KEYS | _MEDIA_RECALL_BODY_DYNAMIC,
            )
            _assert_message_lookup_on_devices(
                recipient_devices,
                assert_api,
                msg_id=real_id,
                expected_result=None,
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


def test_chat_offline_custom_body_modified_after_recipient_relogin(
    topology,
    assert_api,
):
    """B 已收 custom 后离线；A 修改 body，B 重登收到最终自定义正文。"""
    with _allure_step("验证：B 已收 custom 后离线；A 修改 body，B 重登收到最终自定义正文。"):
        device_a, device_b, user_a, user_b, sender_devices, recipient_devices = _offline_endpoints(topology)
        marker = uuid.uuid4().hex[:8]
        old_event = f"offline-custom-old-{marker}"
        new_event = f"offline-custom-new-{marker}"
        old_params = {"revision": "0", "source": "offline"}
        new_params = {"revision": "1", "source": "offline"}
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
            real_id, _ = _send_online_typed(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                type_key="custom",
                payload={"targetId": user_b, "event": old_event, "params": old_params},
                sent_body={"type": 7, "event": old_event, "params": old_params},
                received_body={"type": 7, "event": old_event, "params": old_params},
            )
            time.sleep(5)
            device_b.drain_events(timeout=0.5)
            logout_account_devices(recipient_devices, assert_api)
            modify = device_a.call(
                "ChatManager",
                Cmd.modifyMessage.value,
                info={
                    "msgId": real_id,
                    "msgBody": {"type": 7, "event": new_event, "params": new_params},
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
                        "isPeerRead": False,
                        "hasDeliverAck": True,
                        "needReadReceipt": False,
                        "isThread": False,
                        "isContentReplaced": False,
                        "body": {
                            "type": 7,
                            "event": new_event,
                            "params": new_params,
                            "operatorId": user_a,
                            "operatorTime": gt(0),
                            "operatorCount": gt(0),
                        },
                    },
                },
                ignore_keys=_MESSAGE_DYNAMIC_KEYS | {"deliverOnlineOnly"},
            )
            login_account_devices(recipient_devices, assert_api, user_id=user_b)
            changed = _wait_content_changed(recipient_devices, real_id=real_id)
            final_body = {"type": 7, "event": new_event, "params": new_params}
            _assert_event_response(
                assert_api,
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
                            "isPeerRead": False,
                            "hasDeliverAck": True,
                            "needReadReceipt": False,
                            "isThread": False,
                            "isContentReplaced": False,
                            "body": final_body,
                        },
                        "operatorId": user_a,
                        "operationTime": gt(0),
                    },
                },
                ignore_keys=_MESSAGE_DYNAMIC_KEYS
                | {"deliverOnlineOnly", "receiverList"},
            )
            _assert_message_lookup_on_devices(
                recipient_devices,
                assert_api,
                msg_id=real_id,
                expected_result={
                    "msgId": real_id,
                    "from": user_a,
                    "to": user_b,
                    "convId": user_a,
                    "chatType": 0,
                    "direction": 1,
                    "status": 2,
                    "hasRead": False,
                    "isPeerRead": False,
                    "hasDeliverAck": True,
                    "needReadReceipt": False,
                    "isThread": False,
                    "isContentReplaced": False,
                    "body": {
                        **final_body,
                        "operatorId": user_a,
                        "operatorTime": gt(0),
                        "operatorCount": gt(0),
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


@pytest.mark.parametrize(
    ("type_key", "payload_template", "sent_template", "received_template"),
    _TYPED_OPERATION_CASES[:4],
)
def test_chat_offline_media_attributes_modified_after_recipient_relogin(
    topology,
    assert_api,
    type_key,
    payload_template,
    sent_template,
    received_template,
):
    """B 已收媒体后离线；A 修改 attributes，B 重登收到并保存扩展。"""
    with _allure_step("验证：B 已收媒体后离线；A 修改 attributes，B 重登收到并保存扩展。"):
        device_a, device_b, user_a, user_b, sender_devices, recipient_devices = _offline_endpoints(topology)
        payload, sent_body, received_body = _case_payload_and_bodies(
            type_key, payload_template, sent_template, received_template, user_b
        )
        attributes = {"offlineMediaEdit": type_key, "revision": "1"}
        changed_body = dict(received_body)
        if type_key == "voice":
            changed_body["fileStatus"] = 1
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
            real_id, _ = _send_online_typed(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                type_key=type_key,
                payload=payload,
                sent_body=sent_body,
                received_body=received_body,
            )
            time.sleep(5)
            device_b.drain_events(timeout=0.5)
            logout_account_devices(recipient_devices, assert_api)
            modify = device_a.call(
                "ChatManager",
                Cmd.modifyMessage.value,
                info={"msgId": real_id, "attributes": attributes},
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
                        "isPeerRead": False,
                        "hasDeliverAck": True,
                        "needReadReceipt": False,
                        "isThread": False,
                        "isContentReplaced": False,
                        "attributes": attributes,
                        "body": {
                            **sent_body,
                            "operatorId": user_a,
                            "operatorTime": gt(0),
                            "operatorCount": gt(0),
                        },
                    },
                },
                ignore_keys=_MEDIA_DYNAMIC_KEYS | {"deliverOnlineOnly"},
            )
            login_account_devices(recipient_devices, assert_api, user_id=user_b)
            changed = _wait_content_changed(recipient_devices, real_id=real_id)
            _assert_event_response(
                assert_api,
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
                            "isPeerRead": False,
                            "hasDeliverAck": True,
                            "needReadReceipt": False,
                            "isThread": False,
                            "isContentReplaced": False,
                            "attributes": attributes,
                            "body": changed_body,
                        },
                        "operatorId": user_a,
                        "operationTime": gt(0),
                    },
                },
                ignore_keys=_MEDIA_DYNAMIC_KEYS
                | {"deliverOnlineOnly", "receiverList"},
            )
            _assert_message_lookup_on_devices(
                recipient_devices,
                assert_api,
                msg_id=real_id,
                expected_result={
                    "msgId": real_id,
                    "from": user_a,
                    "to": user_b,
                    "convId": user_a,
                    "chatType": 0,
                    "direction": 1,
                    "status": 2,
                    "hasRead": False,
                    "isPeerRead": False,
                    "hasDeliverAck": True,
                    "needReadReceipt": False,
                    "isThread": False,
                    "isContentReplaced": False,
                    "attributes": attributes,
                    "body": {
                        **changed_body,
                        "operatorId": user_a,
                        "operatorTime": gt(0),
                        "operatorCount": gt(0),
                    },
                },
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


def test_chat_offline_text_recalled_before_first_recipient_login(
    topology,
    assert_api,
):
    """B 首次接收前 A 已撤回文本；B 重登按真实离线合并语义收到撤回。"""
    with _allure_step("验证：B 首次接收前 A 已撤回文本；B 重登按真实离线合并语义收到撤回。"):
        device_a, device_b, user_a, user_b, sender_devices, recipient_devices = _offline_endpoints(topology)
        content = f"offline-pre-recall-{uuid.uuid4().hex[:8]}"
        body = {"type": 0, "content": content, "translations": {}}
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
                type_key="txt",
                payload={"targetId": user_b, "content": content},
                user_a=user_a,
                user_b=user_b,
                response_body={"type": 0, "content": content},
                success_body=body,
            )
            recall = device_a.call(
                "ChatManager", Cmd.recallMessage.value, info={"msgId": real_id}
            )
            _assert_call(
                assert_api,
                recall,
                manager="ChatManager",
                cmd=Cmd.recallMessage.value,
                device_name=_device_name(device_a),
                result=True,
            )
            login_account_devices(recipient_devices, assert_api, user_id=user_b)
            recalled_info = _wait_recall_info(recipient_devices, real_id=real_id)
            _assert_pre_receive_recall_events(
                assert_api,
                recalled_info,
                real_id=real_id,
                user_a=user_a,
            )
            _assert_message_lookup_on_devices(
                recipient_devices,
                assert_api,
                msg_id=real_id,
                expected_result=None,
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


def test_chat_offline_text_modified_before_first_recipient_login(
    topology,
    assert_api,
):
    """B 首次接收前 A 已修改文本；B 重登直接收到最终正文。"""
    with _allure_step("验证：B 首次接收前 A 已修改文本；B 重登直接收到最终正文。"):
        device_a, device_b, user_a, user_b, sender_devices, recipient_devices = _offline_endpoints(topology)
        marker = uuid.uuid4().hex[:8]
        old_content = f"offline-pre-modify-old-{marker}"
        new_content = f"offline-pre-modify-new-{marker}"
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
                type_key="txt",
                payload={"targetId": user_b, "content": old_content},
                user_a=user_a,
                user_b=user_b,
                response_body={"type": 0, "content": old_content},
                success_body={"type": 0, "content": old_content, "translations": {}},
            )
            modify = device_a.call(
                "ChatManager",
                Cmd.modifyMessage.value,
                info={"msgId": real_id, "msgBody": {"type": 0, "content": new_content}},
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
                        "isPeerRead": False,
                        "hasDeliverAck": False,
                        "needReadReceipt": False,
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
            login_account_devices(recipient_devices, assert_api, user_id=user_b)
            received = _wait_message_event(
                recipient_devices, Cmd.onMessagesReceived.value, real_id=real_id
            )
            final_body = {"type": 0, "content": new_content, "translations": {}}
            _assert_received_message(
                assert_api,
                received,
                event_type=Cmd.onMessagesReceived.value,
                real_id=real_id,
                user_a=user_a,
                user_b=user_b,
                body=final_body,
                ignore_keys=_MESSAGE_DYNAMIC_KEYS,
            )
            _assert_message_lookup_on_devices(
                recipient_devices,
                assert_api,
                msg_id=real_id,
                expected_result={
                    "msgId": real_id,
                    "from": user_a,
                    "to": user_b,
                    "convId": user_a,
                    "chatType": 0,
                    "direction": 1,
                    "status": 2,
                    "hasRead": False,
                    "isPeerRead": False,
                    "hasDeliverAck": True,
                    "needReadReceipt": False,
                    "isThread": False,
                    "isContentReplaced": False,
                    "body": {
                        **final_body,
                        "operatorId": user_a,
                        "operatorTime": gt(0),
                        "operatorCount": gt(0),
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
