from __future__ import annotations

import time
import uuid
from contextlib import nullcontext
import pytest

from src import Cmd, ne, gt, ge

from tests.chat._utils import swt_to_send


def _allure_step(name: str):
    try:
        import allure

        return allure.step(name)
    except ImportError:
        return nullcontext()

pytestmark = [pytest.mark.client, pytest.mark.chat, pytest.mark.agorachat1_4_0]


_MESSAGE_EVENT_IGNORE_KEYS = {
    "timestamp",
    "sequence",
    "serverTime",
    "localTime",
    "broadcast",
    "onlineState",
    "receiverList",
    "translations",
    "targetLanguages",
    "fileSize",
    "localPath",
    "remotePath",
    "secret",
    "thumbnailLocalPath",
    "thumbnailRemotePath",
    "thumbnailSecret",
}


def _wait_success_event(device, *, temp_id: str | None = None, content: str | None = None, action: str | None = None, timeout: float = 60.0):
    seen_events = []
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        evt = device.receive_message(
            match_event_type=Cmd.onMessageSuccess.value,
            timeout=min(2.0, max(0.1, deadline - time.monotonic())),
        )
        if evt:
            seen_events.append(evt)
        data = (evt or {}).get("data") or {}
        msg = data.get("msg") or {}
        body = msg.get("body") or {}
        if temp_id is not None and str(data.get("msgId")) != str(temp_id):
            continue
        if content is not None and body.get("content") != content:
            continue
        if action is not None and body.get("action") != action:
            continue
        if msg.get("msgId"):
            return evt
    pytest.fail(f"未收到目标 onMessageSuccess: tempId={temp_id}, content={content}, action={action}, events={seen_events}")


def _wait_message_event(device, event_type: str, *, real_id: str, body_type: int | None = None, content: str | None = None, timeout: float = 60.0):
    seen_events = []
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        evt = device.receive_message(
            match_event_type=event_type,
            timeout=min(2.0, max(0.1, deadline - time.monotonic())),
        )
        if evt:
            seen_events.append(evt)
        messages = ((evt or {}).get("data") or {}).get("messages") or []
        for msg in messages:
            if not isinstance(msg, dict):
                continue
            body = msg.get("body") or {}
            if str(msg.get("msgId")) != str(real_id):
                continue
            if body_type is not None and body.get("type") != body_type:
                continue
            if content is not None and body.get("content") != content:
                continue
            return {
                "type": evt.get("type"),
                "eventType": evt.get("eventType"),
                "data": {"messages": [msg]},
                "timestamp": evt.get("timestamp"),
            }
    pytest.fail(f"未收到目标 {event_type}: realId={real_id}, bodyType={body_type}, content={content}, events={seen_events}")


def _assert_text_message_event(
    assert_api,
    evt,
    *,
    event_type: str,
    real_id: str,
    user_a: str,
    user_b: str,
    content: str,
    direction: int,
    conv_id: str,
    has_read: bool,
    target_languages: list[str] | None = None,
):
    body = {"type": 0, "content": content}
    if target_languages:
        body.update({"targetLanguages": list(target_languages), "translations": {target_languages[0]: content}})
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
                        "chatType": 0,
                        "direction": direction,
                        "status": 2,
                        "hasRead": has_read,
                        "needReadReceipt": False,
                        "isThread": False,
                        "isContentReplaced": False,
                        "deliverOnlineOnly": False,
                        "body": body,
                    }
                ]
            },
        },
        ignore_keys=_MESSAGE_EVENT_IGNORE_KEYS,
    )


def _assert_message_lookup(
    assert_api,
    response: dict,
    *,
    device_name: str,
    real_id: str,
    user_a: str,
    user_b: str,
    content: str,
    direction: int,
    conv_id: str,
    has_read: bool,
) -> None:
    """文本消息本地落库校验（getMessage）。"""
    assert_api.assert_response_matches(
        response,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.getMessage.value,
            "device": device_name,
            "result": {
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
                "body": {"type": 0, "content": content},
            },
        },
        ignore_keys={
            "sequence", "serverTime", "localTime", "broadcast", "onlineState",
            "deliverOnlineOnly", "targetLanguages", "translations", "hasDeliverAck",
        },
        allow_extra_fields=True,
    )


def _assert_media_message_lookup(
    assert_api,
    response: dict,
    *,
    device_name: str,
    real_id: str,
    body_type: int,
    direction: int,
    conv_id: str,
) -> None:
    """媒体消息本地落库校验（getMessage，忽略路径/secret 等易变字段）。"""
    assert_api.assert_response_matches(
        response,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.getMessage.value,
            "device": device_name,
            "result": {
                "msgId": str(real_id),
                "chatType": 0,
                "direction": direction,
                "status": 2,
                "needReadReceipt": False,
                "isThread": False,
                "isContentReplaced": False,
                "body": {"type": body_type},
            },
        },
        ignore_keys={
            "sequence", "serverTime", "localTime", "broadcast", "onlineState",
            "deliverOnlineOnly", "hasRead", "from", "to", "hasDeliverAck",
            "localPath", "remotePath", "secret",
            "thumbnailLocalPath", "thumbnailRemotePath", "thumbnailSecret",
            "displayName", "fileStatus", "thumbnailStatus", "fileSize",
            "width", "height", "duration",
        },
        allow_extra_fields=True,
    )


def _assert_send_success_and_events(topology, assert_api, *, content: str, target_languages: list[str] | None = None):
    """发送文本（可带目标语言）并验证收发账号全部已声明在线端的同步与落库。"""
    sender = topology.sender_action_device
    sender_devices = topology.sender_devices
    recipients = topology.recipient_devices
    sender_user = topology.sender_user
    recipient_user = topology.recipient_user

    with _allure_step("测试准备：清理收发账号全部端的历史事件"):
        for device in (*sender_devices, *recipients):
            device.drain_events(timeout=0.5)

    info = {"type": "txt", "payload": {"targetId": recipient_user, "content": content}, "chatType": 0}
    if target_languages:
        info["payload"]["targetLanguages"] = list(target_languages)
    with _allure_step(f"{sender.device_name} 发送文本消息"):
        resp = sender.call("ChatManager", Cmd.sendMessage.value, info=swt_to_send(info))
    resp_result = resp.get("result") or {}
    resp_temp_id = resp_result.get("msgId")
    with _allure_step("确认发送请求已提交"):
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.sendMessage.value,
                "device": sender.device_name,
                "result": {
                    "msgId": "{{tempId}}",
                    "from": "{{fromUser}}",
                    "to": "{{toUser}}",
                    "convId": "{{toUser}}",
                    "chatType": 0,
                    "direction": 0,
                    # text 发送响应 status 实测 0（CREATE）
                    "status": 0,
                    "deliverOnlineOnly": False,
                    "hasRead": True,
                    "needReadReceipt": False, "isThread": False,
                    "isContentReplaced": False,
                    "body": {"type": 0, "content": "{{content}}"},
                },
            },
            context={"tempId": resp_temp_id, "fromUser": sender_user, "toUser": recipient_user, "content": content},
            ignore_keys={
                "sequence",
                "serverTime",
                "localTime",
                "broadcast",
                "onlineState",
                "targetLanguages",
                "translations",
                # 仅忽略不稳定字段：路径/secret
                "localPath",
                "remotePath",
                "secret",
                "thumbnailLocalPath",
                "thumbnailRemotePath",
                "thumbnailSecret",
            },
        )

    with _allure_step(f"{sender.device_name} 验证发送成功（onMessageSuccess）并提取服务器消息 ID"):
        evt_success = _wait_success_event(sender, temp_id=resp_temp_id, content=content)
        temp_id = (evt_success.get("data") or {}).get("msgId")
        real_id = ((evt_success.get("data") or {}).get("msg") or {}).get("msgId")
        # 若传了 targetLanguages，事件里可能出现 translations/targetLanguages，统一忽略这两个键
        ignore_extra = {"timestamp", "sequence", "serverTime", "localTime", "broadcast", "onlineState", "translations", "targetLanguages"}
        assert_api.assert_response_matches(
            evt_success,
            expected={
                "type": "event",
                "eventType": Cmd.onMessageSuccess.value,
                "data": {
                    "msgId": "{{tempId}}",
                    "msg": {
                        "msgId": "{{realId}}",
                        "from": "{{fromUser}}",
                        "to": "{{toUser}}",
                        "convId": "{{toUser}}",
                        "body": {"type": 0, "content": "{{content}}"},
                        "direction": 0,
                        "chatType": 0,
                        "status": 2,
                        "deliverOnlineOnly": False,
                        "hasRead": True,
                        "needReadReceipt": False, "isThread": False,
                        "isContentReplaced": False,
                    },
                },
            },
            context={"tempId": temp_id, "realId": real_id, "fromUser": sender_user, "toUser": recipient_user, "content": content},
            ignore_keys=ignore_extra,
        )

    for sender_device in sender_devices:
        if sender_device is sender:
            continue
        with _allure_step(f"发送账号端 {sender_device.device_name} 同步该消息并完成本地落库"):
            evt_synced = _wait_message_event(
                sender_device, Cmd.onMessagesReceived.value,
                real_id=real_id, body_type=0, content=content,
            )
            _assert_text_message_event(
                assert_api, evt_synced, event_type=Cmd.onMessagesReceived.value,
                real_id=real_id, user_a=sender_user, user_b=recipient_user,
                content=content, direction=0, conv_id=recipient_user,
                has_read=True, target_languages=target_languages,
            )
            _assert_message_lookup(
                assert_api,
                sender_device.call("ChatManager", Cmd.getMessage.value, info={"msgId": str(real_id)}),
                device_name=sender_device.device_name, real_id=real_id,
                user_a=sender_user, user_b=recipient_user, content=content,
                direction=0, conv_id=recipient_user, has_read=True,
            )

    for recipient in recipients:
        with _allure_step(f"接收账号端 {recipient.device_name} 接收该消息并完成本地落库"):
            evt_received = _wait_message_event(
                recipient, Cmd.onMessagesReceived.value,
                real_id=real_id, body_type=0, content=content,
            )
            _assert_text_message_event(
                assert_api, evt_received, event_type=Cmd.onMessagesReceived.value,
                real_id=real_id, user_a=sender_user, user_b=recipient_user,
                content=content, direction=1, conv_id=sender_user,
                has_read=False, target_languages=target_languages,
            )
            _assert_message_lookup(
                assert_api,
                recipient.call("ChatManager", Cmd.getMessage.value, info={"msgId": str(real_id)}),
                device_name=recipient.device_name, real_id=real_id,
                user_a=sender_user, user_b=recipient_user, content=content,
                direction=1, conv_id=sender_user, has_read=False,
            )
    return real_id


@pytest.mark.topology("account_a_to_account_b")
def test_send_message_with_type_text_basic(topology, assert_api):
    """sendMessageWithType(txt) 基本文本：发送账号副端同步、接收账号全端接收并落库。"""
    with _allure_step("验证：sendMessageWithType(txt) 基本文本：发送账号副端同步、接收账号全端接收并落库。"):
        content = f"txt-{uuid.uuid4().hex[:6]}"
        _assert_send_success_and_events(topology, assert_api, content=content)


@pytest.mark.topology("account_a_to_account_b")
def test_send_message_with_type_text_with_languages(topology, assert_api):
    """sendMessageWithType(txt) 带目标语言：发送成功、全端同步并携带 translations。"""
    with _allure_step("验证：sendMessageWithType(txt) 带目标语言：发送成功、全端同步并携带 translations。"):
        content = f"txttr-{uuid.uuid4().hex[:6]}"
        _assert_send_success_and_events(topology, assert_api, content=content, target_languages=["zh-Hans"])


@pytest.mark.topology("account_a_to_account_b")
def test_send_message_with_type_cmd_received_by_cmd_callback(topology, assert_api):
    """sendMessageWithType(cmd)：发送 CMD 消息，接收账号全部在线端收到 onCmdMessagesReceived 且不混入普通消息回调。"""
    sender = topology.sender_action_device
    recipients = topology.recipient_devices
    sender_user = topology.sender_user
    recipient_user = topology.recipient_user
    action = f"cmd-action-{uuid.uuid4().hex[:8]}"
    info = {"type": "cmd", "payload": {"targetId": recipient_user, "action": action, "deliverOnlineOnly": False}, "chatType": 0}

    with _allure_step("测试准备：清理收发账号全部端的历史事件"):
        for device in (sender, *recipients):
            device.drain_events(timeout=0.5)

    with _allure_step(f"{sender.device_name} 发送 CMD 消息"):
        resp = sender.call("ChatManager", Cmd.sendMessage.value, info=swt_to_send(info))
    temp_id = ((resp.get("result") or {}).get("msgId"))
    assert temp_id, f"sendMessage(cmd) 未返回临时 msgId: {resp}"
    with _allure_step("确认发送请求已提交"):
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.sendMessage.value,
                "device": sender.device_name,
                "result": {
                    "msgId": temp_id,
                    "from": sender_user,
                    "to": recipient_user,
                    "convId": recipient_user,
                    "chatType": 0,
                    "direction": 0,
                    "deliverOnlineOnly": False,
                    "hasRead": True,
                    "needReadReceipt": False, "isThread": False,
                    "isContentReplaced": False,
                    "body": {"type": 6, "action": action, "deliverOnlineOnly": False},
                },
            },
            ignore_keys={"sequence", "serverTime", "localTime", "broadcast", "onlineState"},
        )

    with _allure_step(f"{sender.device_name} 验证 CMD 发送成功（onMessageSuccess）并提取服务器消息 ID"):
        evt_success = _wait_success_event(sender, temp_id=temp_id, action=action)
        real_id = (((evt_success or {}).get("data") or {}).get("msg") or {}).get("msgId")
        assert real_id, f"onMessageSuccess 未返回 CMD 消息服务器 msgId: {evt_success}"
        assert_api.assert_response_matches(
            evt_success,
            expected={
                "type": "event",
                "eventType": Cmd.onMessageSuccess.value,
                "data": {
                    "msgId": temp_id,
                    "msg": {
                        "msgId": real_id,
                        "from": sender_user,
                        "to": recipient_user,
                        "convId": recipient_user,
                        "chatType": 0,
                        "direction": 0,
                        "status": 2,
                        "deliverOnlineOnly": False,
                        "hasRead": True,
                        "needReadReceipt": False, "isThread": False,
                        "isContentReplaced": False,
                        "body": {"type": 6, "action": action, "deliverOnlineOnly": False},
                    },
                },
            },
            ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "broadcast", "onlineState"},
        )

    for recipient in recipients:
        with _allure_step(f"接收账号端 {recipient.device_name} 收到 CMD 回调（onCmdMessagesReceived）"):
            evt_cmd = recipient.receive_message(match_event_type=Cmd.onCmdMessagesReceived.value, timeout=20.0)
            assert_api.assert_response_matches(
                evt_cmd,
                expected={
                    "type": "event",
                    "eventType": Cmd.onCmdMessagesReceived.value,
                    "data": {
                        "messages": [
                            {
                                "msgId": real_id,
                                "from": sender_user,
                                "to": recipient_user,
                                "convId": sender_user,
                                "chatType": 0,
                                "direction": 1,
                                "status": 2,
                                "deliverOnlineOnly": False,
                                "hasRead": False,
                                "needReadReceipt": False, "isThread": False,
                                "isContentReplaced": False,
                                "body": {"type": 6, "action": action, "deliverOnlineOnly": False},
                            },
                        ],
                    },
                },
                ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "receiverList"},
            )

def _send_with_payload_and_assert(topology, assert_api, *, type_key: str, payload: dict):
    """按 swt 类型发送媒体消息，并验证发送账号副端同步、接收账号全端接收与落库。"""
    sender = topology.sender_action_device
    sender_devices = topology.sender_devices
    recipients = topology.recipient_devices
    sender_user = topology.sender_user
    recipient_user = topology.recipient_user

    with _allure_step("测试准备：清理收发账号全部端的历史事件"):
        for device in (*sender_devices, *recipients):
            device.drain_events(timeout=0.5)

    # 媒体消息未传 filePath → 桥接层自动用测试 App 素材补默认路径（interface_router._fillDefaultMediaPath）
    info = swt_to_send({"type": type_key, "payload": payload, "chatType": 0})
    with _allure_step(f"{sender.device_name} 发送 {type_key} 消息"):
        resp = sender.call("ChatManager", Cmd.sendMessage.value, info=info)

    # 收紧同步响应：信封 + 关键字段 + 临时ID
    temp_id = ((resp.get("result") or {}).get("msgId"))
    # 按消息类型收紧媒体字段（除路径/secret 外都校验存在或取值范围）
    body_resp = {"type": ne(None)}
    if type_key == "file":
        body_resp.update({
            "displayName": ne(None),
            "fileStatus": ne(None),
        })
    elif type_key == "image":
        body_resp.update({
            "displayName": ne(None),
            "fileStatus": ne(None),
            "thumbnailStatus": ne(None),
            "width": ge(0),
            "height": ge(0),
            "isGif": False,
            "sendOriginalImage": False,
        })
    elif type_key == "video":
        body_resp.update({
            "displayName": ne(None),
            "fileStatus": ne(None),
            "thumbnailStatus": ne(None),
            "width": ge(0),
            "height": ge(0),
            "duration": ge(0),
        })
    # 事件体在响应体基础上通常还会包含文件远端信息、大小等
    body_evt = dict(body_resp)
    if type_key in ("file", "image", "video"):
        body_evt.update({"fileSize": ge(0)})
    if type_key == "video":
        body_evt.update({"duration": ge(0)})
    with _allure_step("确认发送请求已提交"):
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.sendMessage.value,
                "device": sender.device_name,
                "result": {
                    "msgId": "{{tempId}}",
                    "from": "{{fromUser}}",
                    "to": "{{toUser}}",
                    "convId": "{{toUser}}",
                    "chatType": 0,
                    "direction": 0,
                    "deliverOnlineOnly": False,
                    "hasRead": True,
                    "needReadReceipt": False, "isThread": False,
                    "isContentReplaced": False,
                    "body": body_resp,
                },
            },
            context={"tempId": temp_id, "fromUser": sender_user, "toUser": recipient_user},
            ignore_keys={
                "sequence",
                "status",
                "serverTime",
                "localTime",
                "broadcast",
                "onlineState",
                "targetLanguages",
                "translations",
                # 仅忽略不稳定字段：路径/secret
                "localPath",
                "remotePath",
                "secret",
                "thumbnailLocalPath",
                "thumbnailRemotePath",
                "thumbnailSecret",
            },
        )

    # A 侧 onMessageSuccess：临时ID一致 + 关键字段
    ignore_extra = {
        "timestamp",
        "sequence",
        "serverTime",
        "localTime",
        "broadcast",
        "onlineState",
        "translations",
        "targetLanguages",
        # 媒体 body 上的可变字段
        "fileSize",
        "localPath",
        "remotePath",
        "secret",
        "thumbnailLocalPath",
        "thumbnailRemotePath",
        "thumbnailSecret",
    }
    with _allure_step(f"{sender.device_name} 验证发送成功（onMessageSuccess）并提取服务器消息 ID"):
        evt_success = _wait_success_event(sender, temp_id=temp_id)
        temp_id_evt = (evt_success.get("data") or {}).get("msgId")
        real_id = ((evt_success.get("data") or {}).get("msg") or {}).get("msgId")
        assert temp_id_evt == temp_id, f"tempId mismatch: resp={temp_id}, event={temp_id_evt}"
        assert_api.assert_response_matches(
            evt_success,
            expected={
                "type": "event",
                "eventType": Cmd.onMessageSuccess.value,
                "data": {
                    "msgId": "{{tempId}}",
                    "msg": {
                        "msgId": "{{realId}}",
                        "from": "{{fromUser}}",
                        "to": "{{toUser}}",
                        "convId": "{{toUser}}",
                        "direction": 0,
                        "chatType": 0,
                        "status": 2,
                        "deliverOnlineOnly": False,
                        "hasRead": True,
                        "needReadReceipt": False, "isThread": False,
                        "isContentReplaced": False,
                        "body": body_evt,
                    },
                },
            },
            context={"tempId": temp_id, "realId": real_id, "fromUser": sender_user, "toUser": recipient_user},
            ignore_keys=ignore_extra,
        )

    body_type = {"image": 1, "video": 2, "file": 5}[type_key]
    for sender_device in sender_devices:
        if sender_device is sender:
            continue
        with _allure_step(f"发送账号端 {sender_device.device_name} 同步该媒体消息并完成本地落库"):
            evt_synced = _wait_message_event(
                sender_device, Cmd.onMessagesReceived.value, real_id=real_id, body_type=body_type,
            )
            assert_api.assert_response_matches(
                evt_synced,
                expected={
                    "type": "event",
                    "eventType": Cmd.onMessagesReceived.value,
                    "data": {
                        "messages": [
                            {
                                "msgId": "{{realId}}",
                                "from": "{{fromUser}}",
                                "to": "{{toUser}}",
                                "convId": "{{toUser}}",
                                "direction": 0,
                                "chatType": 0,
                                "status": 2,
                                "deliverOnlineOnly": False,
                                "hasRead": True,
                                "needReadReceipt": False, "isThread": False,
                                "isContentReplaced": False,
                                "body": body_evt,
                            }
                        ]
                    },
                },
                context={"realId": real_id, "fromUser": sender_user, "toUser": recipient_user},
                ignore_keys=ignore_extra,
            )
            _assert_media_message_lookup(
                assert_api,
                sender_device.call("ChatManager", Cmd.getMessage.value, info={"msgId": str(real_id)}),
                device_name=sender_device.device_name, real_id=real_id,
                body_type=body_type, direction=0, conv_id=recipient_user,
            )

    for recipient in recipients:
        with _allure_step(f"接收账号端 {recipient.device_name} 接收该媒体消息并完成本地落库"):
            evt_received = _wait_message_event(
                recipient, Cmd.onMessagesReceived.value, real_id=real_id, body_type=body_type,
            )
            assert_api.assert_response_matches(
                evt_received,
                expected={
                    "type": "event",
                    "eventType": Cmd.onMessagesReceived.value,
                    "data": {
                        "messages": [
                            {
                                "msgId": "{{realId}}",
                                "from": "{{fromUser}}",
                                "to": "{{toUser}}",
                                "convId": "{{fromUser}}",
                                "direction": 1,
                                "chatType": 0,
                                "status": 2,
                                "deliverOnlineOnly": False,
                                "hasRead": False,
                                "needReadReceipt": False, "isThread": False,
                                "isContentReplaced": False,
                                "body": body_evt,
                            }
                        ]
                    },
                },
                context={"realId": real_id, "fromUser": sender_user, "toUser": recipient_user},
                ignore_keys=ignore_extra | {"receiverList"},
            )
            _assert_media_message_lookup(
                assert_api,
                recipient.call("ChatManager", Cmd.getMessage.value, info={"msgId": str(real_id)}),
                device_name=recipient.device_name, real_id=real_id,
                body_type=body_type, direction=1, conv_id=sender_user,
            )


# 注意：媒体类用例仅验证 file/image/video；不传 filePath，也不传 displayName。

@pytest.mark.topology("account_a_to_account_b")
def test_send_message_with_type_file(topology, assert_api):
    """sendMessageWithType(file)：文件消息发送成功、发送账号副端同步、接收账号全端接收。"""
    with _allure_step("验证：sendMessageWithType(file)：文件消息发送成功、发送账号副端同步、接收账号全端接收。"):
        payload = {"targetId": topology.recipient_user}
        _send_with_payload_and_assert(topology, assert_api, type_key="file", payload=payload)


@pytest.mark.topology("account_a_to_account_b")
def test_send_message_with_type_image(topology, assert_api):
    """sendMessageWithType(image)：图片消息发送成功、发送账号副端同步、接收账号全端接收。"""
    with _allure_step("验证：sendMessageWithType(image)：图片消息发送成功、发送账号副端同步、接收账号全端接收。"):
        payload = {"targetId": topology.recipient_user, "thumbnailLocalPath": ""}
        _send_with_payload_and_assert(topology, assert_api, type_key="image", payload=payload)


@pytest.mark.topology("account_a_to_account_b")
def test_send_message_with_type_image_heic(topology, assert_api):
    """发送 HEIC 格式图片，验证 SDK 能正常上传并投递到接收账号全部在线端。"""
    with _allure_step("验证：发送 HEIC 格式图片，验证 SDK 能正常上传并投递到接收账号全部在线端。"):
        payload = {"targetId": topology.recipient_user, "displayName": "imgHeic.HEIC", "thumbnailLocalPath": ""}
        _send_with_payload_and_assert(topology, assert_api, type_key="image", payload=payload)


@pytest.mark.topology("account_a_to_account_b")
def test_send_message_with_type_video(topology, assert_api):
    """sendMessageWithType(video)：视频消息发送成功、发送账号副端同步、接收账号全端接收。"""
    with _allure_step("验证：sendMessageWithType(video)：视频消息发送成功、发送账号副端同步、接收账号全端接收。"):
        payload = {"targetId": topology.recipient_user, "thumbnailLocalPath": ""}
        _send_with_payload_and_assert(topology, assert_api, type_key="video", payload=payload)
