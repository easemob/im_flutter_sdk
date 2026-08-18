"""单聊离线扩展后操作：首次接收前变更、类型化已读与撤回。"""
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

# 5.0 已读/送达回执需发送标记 needReadReceipt=true（否则接收端 asyncSendMessageReadReceipts 跳过、服务端不发送达确认）
_DELIVERY_FLAG_KEYS = {"needReadReceipt"}
# 5.0 在线接收媒体消息 body.fileStatus 实测 0（离线重登接收为 3）→ 接收时机相关，嵌套路径不锁
_MEDIA_BODY_DYNAMIC = {"data.messages[0].body.fileStatus"}
from tests.chat.test_chat_offline_message_operations import (
    _wait_content_changed,
    _wait_recall_info,
)


pytestmark = [pytest.mark.client, pytest.mark.chat]


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
        # B 接收 fileStatus 实测 3（voice 0，received_body 参数已含）→ 锁值，不 ignore
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
        # 已读事件消息为发送方 → body.fileStatus 实测恒 0（sent_body 参数已为 0）→ 锁值
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
        # 撤回消息 body.fileStatus 按撤回信息中的原消息状态断言；voice 实测为 3。
        ignore_keys=ignore_keys,
    )


def _assert_pre_receive_recall_events(
    assert_api,
    recalled_info: dict,
    *,
    real_id: str,
    user_a: str,
) -> None:
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
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    type_key,
    payload_template,
    sent_template,
    received_template,
):
    """A 离线期间 B 已读类型消息；A 重登收到同一 msgId 的已读回执。"""
    payload, sent_body, received_body = _case_payload_and_bodies(
        type_key, payload_template, sent_template, received_template, user_b
    )
    ignore_keys = _MEDIA_DYNAMIC_KEYS if type_key in {"file", "image", "video", "voice"} else _MESSAGE_DYNAMIC_KEYS
    try:
        _establish_friendship(device_a, device_b, assert_api, user_a=user_a, user_b=user_b)
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
            device_a, assert_api, device_name="deviceA", user_id=user_a
        )
        read = _wait_message_event(
            device_a, Cmd.onMessagesRead.value, real_id=real_id
        )
        _assert_read_event(
            assert_api,
            read,
            real_id=real_id,
            user_a=user_a,
            user_b=user_b,
            body=sent_body,
            ignore_keys=ignore_keys,
        )
    finally:
        _restore_case(device_a, device_b, user_a=user_a, user_b=user_b)


@pytest.mark.parametrize(
    ("type_key", "payload_template", "sent_template", "received_template"),
    _TYPED_OPERATION_CASES,
)
def test_chat_offline_typed_message_recall_after_recipient_relogin(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    type_key,
    payload_template,
    sent_template,
    received_template,
):
    """B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除。"""
    payload, sent_body, received_body = _case_payload_and_bodies(
        type_key, payload_template, sent_template, received_template, user_b
    )
    ignore_keys = _MEDIA_DYNAMIC_KEYS if type_key in {"file", "image", "video", "voice"} else _MESSAGE_DYNAMIC_KEYS
    # 撤回信息中的 voice body.fileStatus 实测为 3。
    recall_body = {**sent_body, "fileStatus": 3} if type_key == "voice" else received_body
    try:
        _establish_friendship(device_a, device_b, assert_api, user_a=user_a, user_b=user_b)
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
        logout_for_offline(device_b, assert_api, device_name="deviceB")
        recall = device_a.call(
            "ChatManager", Cmd.recallMessage.value, info={"msgId": real_id}
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
            device_b, assert_api, device_name="deviceB", user_id=user_b
        )
        recalled_info = _wait_recall_info(device_b, real_id=real_id)
        _assert_recall_info(
            assert_api,
            recalled_info,
            real_id=real_id,
            user_a=user_a,
            user_b=user_b,
            body=recall_body,
            ignore_keys=ignore_keys,
        )
        local = device_b.call(
            "ChatManager", Cmd.getMessage.value, info={"msgId": real_id}
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


def test_chat_offline_combine_message_read_after_sender_relogin(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """A 离线期间 B 已读 combine；A 重登收到同一 msgId 的已读回执。"""
    try:
        _establish_friendship(device_a, device_b, assert_api, user_a=user_a, user_b=user_b)
        real_id, sender_body, _ = _send_online_combine(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            need_read_receipt=True,
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
            device_a, assert_api, device_name="deviceA", user_id=user_a
        )
        read = _wait_message_event(
            device_a, Cmd.onMessagesRead.value, real_id=real_id
        )
        _assert_read_event(
            assert_api,
            read,
            real_id=real_id,
            user_a=user_a,
            user_b=user_b,
            body=sender_body,
            ignore_keys=_COMBINE_DYNAMIC_KEYS,
        )
    finally:
        _restore_case(device_a, device_b, user_a=user_a, user_b=user_b)


def test_chat_offline_combine_message_recall_after_recipient_relogin(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """B 已收 combine 后离线；A 撤回后 B 重登收到原 combine 信息。"""
    try:
        _establish_friendship(device_a, device_b, assert_api, user_a=user_a, user_b=user_b)
        real_id, _, received_body = _send_online_combine(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
        )
        device_b.drain_events(timeout=0.5)
        logout_for_offline(device_b, assert_api, device_name="deviceB")
        recall = device_a.call(
            "ChatManager", Cmd.recallMessage.value, info={"msgId": real_id}
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
            device_b, assert_api, device_name="deviceB", user_id=user_b
        )
        recalled_info = _wait_recall_info(device_b, real_id=real_id)
        _assert_recall_info(
            assert_api,
            recalled_info,
            real_id=real_id,
            user_a=user_a,
            user_b=user_b,
            body=received_body,
            ignore_keys=_COMBINE_DYNAMIC_KEYS,
        )
        local = device_b.call(
            "ChatManager", Cmd.getMessage.value, info={"msgId": real_id}
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


def test_chat_offline_custom_body_modified_after_recipient_relogin(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """B 已收 custom 后离线；A 修改 body，B 重登收到最终自定义正文。"""
    marker = uuid.uuid4().hex[:8]
    old_event = f"offline-custom-old-{marker}"
    new_event = f"offline-custom-new-{marker}"
    old_params = {"revision": "0", "source": "offline"}
    new_params = {"revision": "1", "source": "offline"}
    try:
        _establish_friendship(device_a, device_b, assert_api, user_a=user_a, user_b=user_b)
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
        logout_for_offline(device_b, assert_api, device_name="deviceB")
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
        login_preserving_offline_events(
            device_b, assert_api, device_name="deviceB", user_id=user_b
        )
        changed = _wait_content_changed(device_b, real_id=real_id)
        final_body = {"type": 7, "event": new_event, "params": new_params}
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
        local = device_b.call(
            "ChatManager", Cmd.getMessage.value, info={"msgId": real_id}
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
            },
            ignore_keys=_MESSAGE_DYNAMIC_KEYS,
        )
    finally:
        _restore_case(device_a, device_b, user_a=user_a, user_b=user_b)


@pytest.mark.parametrize(
    ("type_key", "payload_template", "sent_template", "received_template"),
    _TYPED_OPERATION_CASES[:4],
)
def test_chat_offline_media_attributes_modified_after_recipient_relogin(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    type_key,
    payload_template,
    sent_template,
    received_template,
):
    """B 已收媒体后离线；A 修改 attributes，B 重登收到并保存扩展。"""
    payload, sent_body, received_body = _case_payload_and_bodies(
        type_key, payload_template, sent_template, received_template, user_b
    )
    attributes = {"offlineMediaEdit": type_key, "revision": "1"}
    changed_body = dict(received_body)
    if type_key == "voice":
        changed_body["fileStatus"] = 1
    try:
        _establish_friendship(device_a, device_b, assert_api, user_a=user_a, user_b=user_b)
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
        logout_for_offline(device_b, assert_api, device_name="deviceB")
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
        login_preserving_offline_events(
            device_b, assert_api, device_name="deviceB", user_id=user_b
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
        local = device_b.call(
            "ChatManager", Cmd.getMessage.value, info={"msgId": real_id}
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
            },
            ignore_keys=_MEDIA_DYNAMIC_KEYS,
        )
    finally:
        _restore_case(device_a, device_b, user_a=user_a, user_b=user_b)


def test_chat_offline_text_recalled_before_first_recipient_login(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """B 首次接收前 A 已撤回文本；B 重登按真实离线合并语义收到撤回。"""
    content = f"offline-pre-recall-{uuid.uuid4().hex[:8]}"
    body = {"type": 0, "content": content, "translations": {}}
    try:
        _prepare_offline_friend(device_a, device_b, assert_api, user_a=user_a, user_b=user_b)
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
            device_name="deviceA",
            result=True,
        )
        login_preserving_offline_events(
            device_b, assert_api, device_name="deviceB", user_id=user_b
        )
        recalled_info = _wait_recall_info(device_b, real_id=real_id)
        _assert_pre_receive_recall_events(
            assert_api,
            recalled_info,
            real_id=real_id,
            user_a=user_a,
        )
        local = device_b.call(
            "ChatManager", Cmd.getMessage.value, info={"msgId": real_id}
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


def test_chat_offline_text_modified_before_first_recipient_login(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """B 首次接收前 A 已修改文本；B 重登直接收到最终正文。"""
    marker = uuid.uuid4().hex[:8]
    old_content = f"offline-pre-modify-old-{marker}"
    new_content = f"offline-pre-modify-new-{marker}"
    try:
        _prepare_offline_friend(device_a, device_b, assert_api, user_a=user_a, user_b=user_b)
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
        login_preserving_offline_events(
            device_b, assert_api, device_name="deviceB", user_id=user_b
        )
        received = _wait_message_event(
            device_b, Cmd.onMessagesReceived.value, real_id=real_id
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
        local = device_b.call(
            "ChatManager", Cmd.getMessage.value, info={"msgId": real_id}
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
            },
            ignore_keys=_MESSAGE_DYNAMIC_KEYS,
        )
    finally:
        _restore_case(device_a, device_b, user_a=user_a, user_b=user_b)
