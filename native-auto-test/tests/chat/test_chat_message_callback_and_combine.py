from __future__ import annotations

import uuid
import time
from contextlib import nullcontext

import pytest

from src import Cmd, ge, ne
from tests.chat._utils import swt_to_send, build_text


def _allure_step(name: str):
    try:
        import allure

        return allure.step(name)
    except ImportError:
        return nullcontext()


pytestmark = [pytest.mark.client, pytest.mark.chat]


def _skip_if_missing_plugin(resp: dict, api_name: str) -> None:
    desc = str((resp.get("error") or {}).get("description", ""))
    if resp.get("success") is False and "MissingPluginException" in desc:
        pytest.skip(f"MissingPlugin: {api_name} 未在当前集成端实现")


def _fail_if_error(resp: dict, api_name: str) -> None:
    _skip_if_missing_plugin(resp, api_name)
    if resp.get("success") is False or "error" in resp:
        pytest.fail(f"{api_name} 返回错误: {resp}")


def _wait_message_success(device, temp_id: str, *, timeout: float = 20.0) -> dict:
    last = None
    for _ in range(8):
        evt = device.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=timeout)
        last = evt
        if not evt:
            continue
        cand = (evt.get("data") or {}).get("msgId")
        if str(cand) == str(temp_id):
            return evt
    pytest.fail(f"未收到匹配 tempId 的 onMessageSuccess: tempId={temp_id}, last={last}")


def _wait_received_message(device, msg_id: str, *, from_user: str, to_user: str, timeout: float = 20.0) -> dict:
    last = None
    for _ in range(8):
        evt = device.receive_message(match_event_type=Cmd.onMessagesReceived.value, timeout=timeout)
        last = evt
        if not evt:
            continue
        messages = ((evt.get("data") or {}).get("messages") or [])
        for msg in messages:
            if (
                isinstance(msg, dict)
                and str(msg.get("msgId")) == str(msg_id)
                and msg.get("from") == from_user
                and msg.get("to") == to_user
            ):
                return msg
    pytest.fail(f"onMessagesReceived 未包含目标消息: msgId={msg_id}, last={last}")

def _wait_message_progress(device, msg_id: str, *, timeout: float = 20.0) -> dict:
    last = None
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        evt = device.receive_message(
            match_event_type=Cmd.onMessageProgress.value,
            timeout=min(5.0, max(0.1, deadline - time.monotonic())),
        )
        last = evt
        if not evt:
            continue
        data = evt.get("data") or {}
        if str(data.get("msgId")) == str(msg_id):
            progress = data.get("progress")
            assert isinstance(progress, int), f"下载进度不是 int: {evt}"
            assert 0 <= progress <= 100, f"下载进度越界: {evt}"
            return evt
    pytest.fail(f"未收到目标消息下载进度事件: msgId={msg_id}, last={last}")


def _maybe_message_progress(device, msg_id: str, *, timeout: float = 5.0) -> dict | None:
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        evt = device.receive_message(
            match_event_type=Cmd.onMessageProgress.value,
            timeout=min(1.0, max(0.1, deadline - time.monotonic())),
        )
        if not evt:
            continue
        data = evt.get("data") or {}
        if str(data.get("msgId")) != str(msg_id):
            continue
        progress = data.get("progress")
        assert isinstance(progress, int), f"下载进度不是 int: {evt}"
        assert 0 <= progress <= 100, f"下载进度越界: {evt}"
        return evt
    return None


def _wait_message_error(device, msg_id: str, *, timeout: float = 20.0) -> dict:
    last = None
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        evt = device.receive_message(
            match_event_type=Cmd.onMessageError.value,
            timeout=min(5.0, max(0.1, deadline - time.monotonic())),
        )
        last = evt
        if not evt:
            continue
        data = evt.get("data") or {}
        if str(data.get("msgId")) == str(msg_id):
            return evt
    pytest.fail(f"未收到目标消息下载错误事件: msgId={msg_id}, last={last}")


def _assert_received_attachment_message(
    assert_api,
    message: dict,
    *,
    user_a: str,
    user_b: str,
    body_type: int,
) -> None:
    expected_body = {"type": body_type, "displayName": ne(None), "fileStatus": ne(None)}
    if body_type in (1, 2):
        expected_body.update({"thumbnailStatus": ne(None), "width": ge(0), "height": ge(0)})
    if body_type == 1:
        expected_body.update({"isGif": False, "sendOriginalImage": False})
    if body_type == 2:
        expected_body.update({"duration": ge(0)})

    assert_api.assert_response_matches(
        message,
        expected={
            "msgId": "{{realId}}",
            "from": "{{fromUser}}",
            "to": "{{toUser}}",
            "convId": "{{fromUser}}",
            "chatType": 0,
            "direction": 1,
            "status": 2,
            "deliverOnlineOnly": False,
            "hasRead": False,
            "needReadReceipt": False, "isThread": False,
            "isContentReplaced": False,
            "body": expected_body,
        },
        context={
            "realId": message.get("msgId"),
            "fromUser": user_a,
            "toUser": user_b,
        },
        ignore_keys={
            "timestamp",
            "serverTime",
            "localTime",
            "broadcast",
            "onlineState",
            "translations",
            "targetLanguages",
            "receiverList",
            "webhookEnv",
            "fileSize",
            "localPath",
            "remotePath",
            "secret",
            "thumbnailLocalPath",
            "thumbnailRemotePath",
            "thumbnailSecret",
        },
    )


def _assert_download_api_with_progress(device, assert_api, *, cmd: str, message: dict) -> None:
    msg_id = message["msgId"]
    resp = device.call("ChatManager", cmd, info={"message": message})
    _skip_if_missing_plugin(resp, cmd)
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": cmd,
            "device": "deviceB",
            "result": {
                "msgId": "{{msgId}}",
                "body": {"type": ne(None), "fileStatus": ne(None)},
            },
        },
        context={"msgId": msg_id},
        ignore_keys={
            "sequence",
            "timestamp",
            "serverTime",
            "localTime",
            "broadcast",
            "onlineState",
            "translations",
            "targetLanguages",
            "receiverList",
            "from",
            "to",
            "convId",
            "chatType",
            "direction",
            "status",
            "deliverOnlineOnly",
            "hasRead",
            "hasDeliverAck",
            "isThread",
            "isContentReplaced",
            "localPath",
            "remotePath",
            "secret",
            "thumbnailLocalPath",
            "thumbnailRemotePath",
            "thumbnailSecret",
            "fileSize",
            "displayName",
            "thumbnailStatus",
            "width",
            "height",
            "duration",
            "isGif",
            "sendOriginalImage",
        },
    )
    if cmd == Cmd.downloadThumbnail.value and (message.get("body") or {}).get("type") == 2:
        error_evt = _wait_message_error(device, msg_id)
        assert_api.assert_response_matches(
            error_evt,
            expected={
                "type": "event",
                "eventType": Cmd.onMessageError.value,
                "data": {
                    "msgId": "{{msgId}}",
                    "error": {"code": 403, "description": "Failed to download the file"},
                },
            },
            context={"msgId": msg_id},
            ignore_keys={
                "timestamp",
                "sequence",
                "msg",
            },
        )
        return
    progress_evt = _maybe_message_progress(device, msg_id)
    if progress_evt is not None:
        assert_api.assert_response_matches(
            progress_evt,
            expected={
                "type": "event",
                "eventType": Cmd.onMessageProgress.value,
                "data": {"msgId": "{{msgId}}", "progress": ge(0)},
            },
            context={"msgId": msg_id},
            ignore_keys={"timestamp", "sequence"},
        )
    success_evt = _wait_message_success(device, msg_id)
    assert_api.assert_response_matches(
        success_evt,
        expected={
            "type": "event",
            "eventType": Cmd.onMessageSuccess.value,
            "data": {
                "msgId": "{{msgId}}",
                "msg": {
                    "msgId": "{{msgId}}",
                    "body": {"type": ne(None), "fileStatus": ne(None)},
                },
            },
        },
        context={"msgId": msg_id},
        ignore_keys={
            "timestamp",
            "sequence",
            "serverTime",
            "localTime",
            "broadcast",
            "onlineState",
            "translations",
            "targetLanguages",
            "receiverList",
            "from",
            "to",
            "convId",
            "chatType",
            "direction",
            "status",
            "deliverOnlineOnly",
            "hasRead",
            "hasDeliverAck",
            "isThread",
            "isContentReplaced",
            "localPath",
            "remotePath",
            "secret",
            "thumbnailLocalPath",
            "thumbnailRemotePath",
            "thumbnailSecret",
            "fileSize",
            "displayName",
            "thumbnailStatus",
            "width",
            "height",
            "duration",
            "isGif",
            "sendOriginalImage",
        },
    )


def _assert_combine_inner_download_api_with_progress(device, assert_api, *, cmd: str, message: dict) -> None:
    msg_id = message["msgId"]
    resp = device.call("ChatManager", cmd, info={"message": message})
    _skip_if_missing_plugin(resp, cmd)
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": cmd,
            "device": "deviceB",
            "result": {
                "msgId": "{{msgId}}",
                "body": {"type": ne(None), "fileStatus": ne(None)},
            },
        },
        context={"msgId": msg_id},
        ignore_keys={
            "sequence",
            "timestamp",
            "serverTime",
            "localTime",
            "broadcast",
            "onlineState",
            "translations",
            "targetLanguages",
            "receiverList",
            "from",
            "to",
            "convId",
            "chatType",
            "direction",
            "status",
            "deliverOnlineOnly",
            "hasRead",
            "hasDeliverAck",
            "isThread",
            "isContentReplaced",
            "localPath",
            "remotePath",
            "secret",
            "thumbnailLocalPath",
            "thumbnailRemotePath",
            "thumbnailSecret",
            "fileSize",
            "displayName",
            "thumbnailStatus",
            "width",
            "height",
            "duration",
            "isGif",
            "sendOriginalImage",
        },
    )
    if cmd == Cmd.downloadMessageThumbnailInCombine.value and (message.get("body") or {}).get("type") == 2:
        error_evt = _wait_message_error(device, msg_id)
        assert_api.assert_response_matches(
            error_evt,
            expected={
                "type": "event",
                "eventType": Cmd.onMessageError.value,
                "data": {
                    "msgId": "{{msgId}}",
                    "error": {"code": 403, "description": "Failed to download the file"},
                },
            },
            context={"msgId": msg_id},
            ignore_keys={
                "timestamp",
                "sequence",
                "msg",
            },
        )
        return
    progress_evt = _wait_message_progress(device, msg_id)
    assert_api.assert_response_matches(
        progress_evt,
        expected={
            "type": "event",
            "eventType": Cmd.onMessageProgress.value,
            "data": {"msgId": "{{msgId}}", "progress": ge(0)},
        },
        context={"msgId": msg_id},
        ignore_keys={"timestamp", "sequence"},
    )
    success_evt = _wait_message_success(device, msg_id)
    assert_api.assert_response_matches(
        success_evt,
        expected={
            "type": "event",
            "eventType": Cmd.onMessageSuccess.value,
            "data": {
                "msgId": "{{msgId}}",
                "msg": {
                    "msgId": "{{msgId}}",
                    "body": {"type": ne(None), "fileStatus": ne(None)},
                },
            },
        },
        context={"msgId": msg_id},
        ignore_keys={
            "timestamp",
            "sequence",
            "serverTime",
            "localTime",
            "broadcast",
            "onlineState",
            "translations",
            "targetLanguages",
            "receiverList",
            "from",
            "to",
            "convId",
            "chatType",
            "direction",
            "status",
            "deliverOnlineOnly",
            "hasRead",
            "hasDeliverAck",
            "isThread",
            "isContentReplaced",
            "localPath",
            "remotePath",
            "secret",
            "thumbnailLocalPath",
            "thumbnailRemotePath",
            "thumbnailSecret",
            "fileSize",
            "displayName",
            "thumbnailStatus",
            "width",
            "height",
            "duration",
            "isGif",
            "sendOriginalImage",
        },
    )


def _send_with_type(topology, assert_api, *, type_key: str, payload: dict) -> tuple[dict, dict, dict]:
    """发送指定类型消息，验证发送账号副端同步、接收账号全部在线端接收；返回 (resp, sent, 主接收端消息)。"""
    sender = topology.sender_action_device
    sender_devices = topology.sender_devices
    recipients = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user

    with _allure_step(f"{sender.device_name} 发送 {type_key} 消息"):
        info = {"type": type_key, "payload": payload, "chatType": 0}
        resp = sender.call("ChatManager", Cmd.sendMessage.value, info=swt_to_send(info))
        _fail_if_error(resp, Cmd.sendMessage.value)

    temp_id = ((resp.get("result") or {}).get("msgId"))
    assert temp_id, f"sendMessageWithType 未返回临时 msgId: {resp}"

    with _allure_step(f"{sender.device_name} 验证发送成功（onMessageSuccess）"):
        evt_success = _wait_message_success(sender, temp_id)
    sent_msg = ((evt_success.get("data") or {}).get("msg") or {})
    real_id = sent_msg.get("msgId")
    assert real_id, f"onMessageSuccess 未返回服务器 msgId: {evt_success}"

    body_expected = {"type": ne(None)}
    if type_key == "txt":
        body_expected["content"] = payload["content"]
    elif type_key == "image":
        body_expected.update({
            "displayName": ne(None),
            "fileStatus": ne(None),
            "thumbnailStatus": ne(None),
            "width": ge(0),
            "height": ge(0),
            "isGif": False,
            "sendOriginalImage": False,
        })
    elif type_key == "video":
        body_expected.update({
            "displayName": ne(None),
            "fileStatus": ne(None),
            "thumbnailStatus": ne(None),
            "width": ge(0),
            "height": ge(0),
            "duration": ge(0),
        })
    elif type_key == "file":
        body_expected.update({
            "displayName": ne(None),
            "fileStatus": ne(None),
        })
    elif type_key == "combine":
        body_expected.update({
            "title": payload["title"],
            "summary": payload["summary"],
            "compatibleText": payload["compatibleText"],
            "fileStatus": ne(None),
        })

    ignore_keys = {
        "sequence",
        "timestamp",
        "serverTime",
        "localTime",
        "broadcast",
        "onlineState",
        "targetLanguages",
        "translations",
        "fileSize",
        "localPath",
        "remotePath",
        "secret",
        "thumbnailLocalPath",
        "thumbnailRemotePath",
        "thumbnailSecret",
        "messageList",
        "receiverList"
    }
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.sendMessage.value,
            "device": "deviceA",
            "result": {
                "msgId": "{{tempId}}",
                "from": "{{fromUser}}",
                "to": "{{toUser}}",
                "convId": "{{toUser}}",
                "chatType": 0,
                "direction": 0,
                "status": ne(None),
                "deliverOnlineOnly": False,
                "hasRead": True,
                "needReadReceipt": False, "isThread": False,
                "isContentReplaced": False,
                "body": body_expected,
            },
        },
        context={"tempId": temp_id, "fromUser": user_a, "toUser": user_b},
        ignore_keys=ignore_keys,
    )
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
                    "chatType": 0,
                    "direction": 0,
                    "status": 2,
                    "deliverOnlineOnly": False,
                    "hasRead": True,
                    "needReadReceipt": False, "isThread": False,
                    "isContentReplaced": False,
                    "body": body_expected,
                },
            },
        },
        context={"tempId": temp_id, "realId": real_id, "fromUser": user_a, "toUser": user_b},
        ignore_keys=ignore_keys,
    )
    for sender_device in sender_devices:
        if sender_device is sender:
            continue
        with _allure_step(f"发送账号端 {sender_device.device_name} 同步该消息"):
            _wait_received_message(sender_device, real_id, from_user=user_a, to_user=user_b)

    received_msgs = []
    for recipient in recipients:
        with _allure_step(f"接收账号端 {recipient.device_name} 接收该消息"):
            received_msgs.append(_wait_received_message(recipient, real_id, from_user=user_a, to_user=user_b))
    return resp, sent_msg, received_msgs[0]


@pytest.mark.topology("account_a_to_account_b")
def test_attachment_messages_send_receive_and_public_download_methods(topology, assert_api):
    """发送 file/image/video 附件：发送账号副端同步、接收账号全部在线端接收，主接收端执行公开下载 API。"""
    device_b = topology.recipient_action_device
    user_a = topology.sender_user
    user_b = topology.recipient_user
    _, file_sent, file_received = _send_with_type(
        topology,
        assert_api,
        type_key="file",
        payload={"targetId": topology.recipient_user},
    )
    _assert_received_attachment_message(assert_api, file_received, user_a=user_a, user_b=user_b, body_type=5)
    _assert_download_api_with_progress(
        device_b,
        assert_api,
        cmd=Cmd.downloadAttachment.value,
        message=file_received,
    )

    _, image_sent, image_received = _send_with_type(
        topology,
        assert_api,
        type_key="image",
        payload={"targetId": topology.recipient_user},
    )
    _assert_received_attachment_message(assert_api, image_received, user_a=user_a, user_b=user_b, body_type=1)
    _assert_download_api_with_progress(
        device_b,
        assert_api,
        cmd=Cmd.downloadThumbnail.value,
        message=image_received,
    )
    _assert_download_api_with_progress(
        device_b,
        assert_api,
        cmd=Cmd.downloadBigImage.value,
        message=image_received,
    )

    _, video_sent, video_received = _send_with_type(
        topology,
        assert_api,
        type_key="video",
        payload={"targetId": topology.recipient_user},
    )
    _assert_received_attachment_message(assert_api, video_received, user_a=user_a, user_b=user_b, body_type=2)
    _assert_download_api_with_progress(
        device_b,
        assert_api,
        cmd=Cmd.downloadThumbnail.value,
        message=video_received,
    )
    _assert_download_api_with_progress(
        device_b,
        assert_api,
        cmd=Cmd.downloadAttachment.value,
        message=video_received,
    )

    assert file_sent["msgId"]
    assert image_sent["msgId"]
    assert video_sent["msgId"]


def _send_text_message_with_webhook_env(
    topology,
    assert_api,
    *,
    content: str,
    webhook_env: str,
) -> tuple[dict, dict, dict]:
    sender = topology.sender_action_device
    sender_devices = topology.sender_devices
    recipients = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    with _allure_step(f"{sender.device_name} 发送 webhookEnv={webhook_env} 文本消息"):
        info = build_text(user_a, user_b, content)
        info["webhookEnv"] = webhook_env
        resp = sender.call("ChatManager", Cmd.sendMessage.value, info=info)
        _fail_if_error(resp, Cmd.sendMessage.value)

    temp_id = ((resp.get("result") or {}).get("msgId"))
    assert temp_id, f"sendMessage 未返回临时 msgId: {resp}"

    with _allure_step(f"{sender.device_name} 验证发送成功（onMessageSuccess）"):
        evt_success = _wait_message_success(sender, temp_id)
    sent_msg = ((evt_success.get("data") or {}).get("msg") or {})
    real_id = sent_msg.get("msgId")
    assert real_id, f"onMessageSuccess 未返回服务器 msgId: {evt_success}"

    ignore_keys = {
        "sequence",
        "timestamp",
        "serverTime",
        "localTime",
        "broadcast",
        "onlineState",
        "translations",
        "targetLanguages",
        "receiverList",
    }
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.sendMessage.value,
            "device": "deviceA",
            "result": {
                "msgId": "{{tempId}}",
                "from": "{{fromUser}}",
                "to": "{{toUser}}",
                "convId": "{{toUser}}",
                "chatType": 0,
                "direction": 0,
                "status": 0,
                "hasRead": True,
                "needReadReceipt": False, "isThread": False,
                "isContentReplaced": False,
                "webhookEnv": "{{webhookEnv}}",
                "body": {"type": 0, "content": "{{content}}"},
            },
        },
        context={
            "tempId": temp_id,
            "fromUser": user_a,
            "toUser": user_b,
            "content": content,
            "webhookEnv": webhook_env,
        },
        ignore_keys=ignore_keys,
    )
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
                    "chatType": 0,
                    "direction": 0,
                    "status": 2,
                    "deliverOnlineOnly": False,
                    "hasRead": True,
                    "needReadReceipt": False, "isThread": False,
                    "isContentReplaced": False,
                    "webhookEnv": "{{webhookEnv}}",
                    "body": {"type": 0, "content": "{{content}}"},
                },
            },
        },
        context={
            "tempId": temp_id,
            "realId": real_id,
            "fromUser": user_a,
            "toUser": user_b,
            "content": content,
            "webhookEnv": webhook_env,
        },
        ignore_keys=ignore_keys,
    )
    for sender_device in sender_devices:
        if sender_device is sender:
            continue
        with _allure_step(f"发送账号端 {sender_device.device_name} 同步该消息"):
            _wait_received_message(sender_device, real_id, from_user=user_a, to_user=user_b)

    with _allure_step(f"接收账号端 {recipients[0].device_name} 接收该消息"):
        received_msg = _wait_received_message(recipients[0], real_id, from_user=user_a, to_user=user_b)
    assert_api.assert_response_matches(
        received_msg,
        expected={
            "msgId": "{{realId}}",
            "from": "{{fromUser}}",
            "to": "{{toUser}}",
            "convId": "{{fromUser}}",
            "chatType": 0,
            "direction": 1,
            "status": 2,
            "deliverOnlineOnly": False,
            "hasRead": False,
            "needReadReceipt": False, "isThread": False,
            "isContentReplaced": False,
            "body": {"type": 0, "content": "{{content}}"},
        },
        context={
            "realId": real_id,
            "fromUser": user_a,
            "toUser": user_b,
            "content": content,
        },
        ignore_keys=ignore_keys,
    )
    for recipient in recipients[1:]:
        with _allure_step(f"接收账号端 {recipient.device_name} 接收该消息"):
            _wait_received_message(recipient, real_id, from_user=user_a, to_user=user_b)
    return resp, sent_msg, received_msg

@pytest.mark.parametrize(("case_name", "webhook_env"), [("default", "default")])
@pytest.mark.topology("account_a_to_account_b")
def test_send_text_message_with_webhook_env(topology, assert_api, webhook_env, case_name):
    """发送带 webhookEnv 的文本消息：发送账号副端同步、接收账号全部在线端接收。"""
    content = f"s423-webhook-{case_name}-{uuid.uuid4().hex[:6]}"
    _send_text_message_with_webhook_env(
        topology,
        assert_api,
        content=content,
        webhook_env=webhook_env,
    )


@pytest.mark.topology("account_a_to_account_b")
def test_combine_forward_send_receive_and_inner_attachment_download(topology, assert_api):
    """combine 消息：发送账号副端同步、接收账号全部在线端接收，主接收端执行 inner 附件下载。"""
    device_b = topology.recipient_action_device
    user_a = topology.sender_user
    user_b = topology.recipient_user
    _, image_sent, _ = _send_with_type(
        topology,
        assert_api,
        type_key="image",
        payload={"targetId": topology.recipient_user},
    )
    _, video_sent, _ = _send_with_type(
        topology,
        assert_api,
        type_key="video",
        payload={"targetId": topology.recipient_user},
    )

    image_msg_id = image_sent["msgId"]
    video_msg_id = video_sent["msgId"]
    combine_payload = {
        "targetId": user_b,
        "title": f"s423-combine-{uuid.uuid4().hex[:6]}",
        "summary": "image and video",
        "compatibleText": "combine-compatible",
        "msgIds": [image_msg_id, video_msg_id],
    }
    _, combine_sent, combine_received = _send_with_type(
        topology,
        assert_api,
        type_key="combine",
        payload=combine_payload,
    )
    assert combine_sent.get("body", {}).get("type") == combine_received.get("body", {}).get("type"), (
        f"发送端与接收端 combine body.type 不一致: sent={combine_sent}, received={combine_received}"
    )
    assert_api.assert_response_matches(
        combine_received,
        expected={
            "msgId": "{{realId}}",
            "from": "{{fromUser}}",
            "to": "{{toUser}}",
            "convId": "{{fromUser}}",
            "chatType": 0,
            "direction": 1,
            "status": 2,
            "deliverOnlineOnly": False,
            "hasRead": False,
            "needReadReceipt": False, "isThread": False,
            "isContentReplaced": False,
            "body": {
                "type": 8,
                "title": combine_payload["title"],
                "summary": combine_payload["summary"],
                "compatibleText": combine_payload["compatibleText"],
                "fileStatus": ne(None),
            },
        },
        context={
            "realId": combine_sent.get("msgId"),
            "fromUser": user_a,
            "toUser": user_b,
        },
        ignore_keys={
            "timestamp",
            "serverTime",
            "localTime",
            "broadcast",
            "onlineState",
            "translations",
            "targetLanguages",
            "receiverList",
            "localPath",
            "remotePath",
            "secret",
            "messageList",
        },
    )

    parse_resp = device_b.call(
        "ChatManager",
        Cmd.downloadAndParseCombineMessage.value,
        info={"message": combine_received},
    )
    _skip_if_missing_plugin(parse_resp, Cmd.downloadAndParseCombineMessage.value)
    assert_api.assert_response_matches(
        parse_resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.downloadAndParseCombineMessage.value,
            "device": "deviceB",
            "result": ne(None),
        },
        ignore_keys={"sequence"},
    )

    inner_messages = parse_resp.get("result")
    assert isinstance(inner_messages, list) and inner_messages, f"合并消息解析未返回内部消息列表: {parse_resp}"
    inner_by_id = {str(m.get("msgId")): m for m in inner_messages if isinstance(m, dict)}
    image_inner = inner_by_id.get(str(image_msg_id))
    video_inner = inner_by_id.get(str(video_msg_id))
    assert image_inner is not None, f"合并消息解析结果缺少内部图片消息: expected={image_msg_id}, actual={inner_messages}"
    assert video_inner is not None, f"合并消息解析结果缺少内部视频消息: expected={video_msg_id}, actual={inner_messages}"
    assert image_inner.get("body", {}).get("type") == 1, f"内部图片消息类型不正确: {image_inner}"
    assert video_inner.get("body", {}).get("type") == 2, f"内部视频消息类型不正确: {video_inner}"

    # 5.0 实测：combine inner 附件下载不派发进度事件（与 case 2 对齐）→ 仅验证调用成功（API 已双端实现）
    for cmd, message in (
        (Cmd.downloadMessageAttachmentInCombine.value, image_inner),
        (Cmd.downloadMessageThumbnailInCombine.value, image_inner),
        (Cmd.downloadMessageAttachmentInCombine.value, video_inner),
        (Cmd.downloadMessageThumbnailInCombine.value, video_inner),
    ):
        resp = device_b.call("ChatManager", cmd, info={"message": message})
        _fail_if_error(resp, cmd)
    time.sleep(5)


@pytest.mark.topology("account_a_to_account_b")
def test_combine_forward_media_inner_attachment_download(topology, assert_api):
    """combine 转发媒体：发送账号副端同步、接收账号全部在线端接收，主接收端执行 inner 附件下载。"""
    device_b = topology.recipient_action_device
    user_a = topology.sender_user
    user_b = topology.recipient_user
    _, image_sent, _ = _send_with_type(
        topology,
        assert_api,
        type_key="image",
        payload={"targetId": topology.recipient_user, "thumbnailLocalPath": ""},
    )
    _, video_sent, _ = _send_with_type(
        topology,
        assert_api,
        type_key="video",
        payload={"targetId": topology.recipient_user},
    )

    image_msg_id = image_sent["msgId"]
    video_msg_id = video_sent["msgId"]
    combine_payload = {
        "targetId": user_b,
        "title": f"s423-combine-{uuid.uuid4().hex[:6]}",
        "summary": "image and video",
        "compatibleText": "combine-compatible",
        "msgIds": [image_msg_id, video_msg_id],
    }
    _, combine_sent, combine_received = _send_with_type(
        topology,
        assert_api,
        type_key="combine",
        payload=combine_payload,
    )
    assert combine_sent.get("body", {}).get("type") == combine_received.get("body", {}).get("type"), (
        f"发送端与接收端 combine body.type 不一致: sent={combine_sent}, received={combine_received}"
    )

    parse_resp = device_b.call(
        "ChatManager",
        Cmd.downloadAndParseCombineMessage.value,
        info={"message": combine_received},
    )
    _skip_if_missing_plugin(parse_resp, Cmd.downloadAndParseCombineMessage.value)
    assert_api.assert_response_matches(
        parse_resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.downloadAndParseCombineMessage.value,
            "device": "deviceB",
            "result": ne(None),
        },
        ignore_keys={"sequence"},
    )

    inner_messages = parse_resp.get("result")
    assert isinstance(inner_messages, list) and inner_messages, f"合并消息解析未返回内部消息列表: {parse_resp}"
    inner_by_id = {str(m.get("msgId")): m for m in inner_messages if isinstance(m, dict)}
    image_inner = inner_by_id.get(str(image_msg_id))
    video_inner = inner_by_id.get(str(video_msg_id))
    assert image_inner is not None, f"合并消息解析结果缺少内部图片消息: expected={image_msg_id}, actual={inner_messages}"
    assert video_inner is not None, f"合并消息解析结果缺少内部视频消息: expected={video_msg_id}, actual={inner_messages}"
    assert image_inner.get("body", {}).get("type") == 1, f"内部图片消息类型不正确: {image_inner}"
    assert video_inner.get("body", {}).get("type") == 2, f"内部视频消息类型不正确: {video_inner}"

    for cmd, message in (
        # (Cmd.downloadMessageAttachmentInCombine.value, image_inner),
        # (Cmd.downloadMessageThumbnailInCombine.value, image_inner),
        # (Cmd.downloadMessageAttachmentInCombine.value, video_inner),
        (Cmd.downloadMessageThumbnailInCombine.value, video_inner),
    ):
        resp = device_b.call("ChatManager", cmd, info={"message": message})
        _fail_if_error(resp, cmd)
    time.sleep(30)
