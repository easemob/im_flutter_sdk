from __future__ import annotations

import time
import uuid

import pytest

from src import Cmd, ge, ne
from tests.chat._utils import build_text

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


def _send_with_type(device_a, device_b, assert_api, user_a: str, user_b: str, *, type_key: str, payload: dict) -> tuple[dict, dict, dict]:
    info = {"type": type_key, "payload": payload, "chatType": 0}
    resp = device_a.call("ChatManager", Cmd.sendMessageWithType.value, info=info)
    _fail_if_error(resp, Cmd.sendMessageWithType.value)

    temp_id = ((resp.get("result") or {}).get("msgId"))
    assert temp_id, f"sendMessageWithType 未返回临时 msgId: {resp}"

    evt_success = _wait_message_success(device_a, temp_id)
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
            "cmd": Cmd.sendMessageWithType.value,
            "device": "deviceA",
            "result": {
                "msgId": "{{tempId}}",
                "from": "{{fromUser}}",
                "to": "{{toUser}}",
                "convId": "{{toUser}}",
                "chatType": 0,
                "direction": 0,
                "status": 1,
                "deliverOnlineOnly": False,
                "hasRead": True,
                "hasReadAck": False,
                "hasDeliverAck": False,
                "needGroupAck": False,
                "isThread": False,
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
                    "hasReadAck": False,
                    "hasDeliverAck": False,
                    "needGroupAck": False,
                    "isThread": False,
                    "isContentReplaced": False,
                    "body": body_expected,
                },
            },
        },
        context={"tempId": temp_id, "realId": real_id, "fromUser": user_a, "toUser": user_b},
        ignore_keys=ignore_keys,
    )
    received_msg = _wait_received_message(device_b, real_id, from_user=user_a, to_user=user_b)
    return resp, sent_msg, received_msg


def _send_text_message_with_webhook_env(
    device_a,
    device_b,
    assert_api,
    user_a: str,
    user_b: str,
    *,
    content: str,
    webhook_env: str,
) -> tuple[dict, dict, dict]:
    info = build_text(user_a, user_b, content)
    info["webhookEnv"] = webhook_env
    resp = device_a.call("ChatManager", Cmd.sendMessage.value, info=info)
    _fail_if_error(resp, Cmd.sendMessage.value)

    temp_id = ((resp.get("result") or {}).get("msgId"))
    assert temp_id, f"sendMessage 未返回临时 msgId: {resp}"

    evt_success = _wait_message_success(device_a, temp_id)
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
                "hasReadAck": False,
                "hasDeliverAck": False,
                "needGroupAck": False,
                "isThread": False,
                "isContentReplaced": False,
                "body": {"type": 0, "content": "{{content}}"},
            },
        },
        context={
            "tempId": temp_id,
            "fromUser": user_a,
            "toUser": user_b,
            "content": content,
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
                    "hasReadAck": False,
                    "hasDeliverAck": False,
                    "needGroupAck": False,
                    "isThread": False,
                    "isContentReplaced": False,
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
        },
        ignore_keys=ignore_keys,
    )
    received_msg = _wait_received_message(device_b, real_id, from_user=user_a, to_user=user_b)
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
            "hasReadAck": False,
            "hasDeliverAck": False,
            "needGroupAck": False,
            "isThread": False,
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
    return resp, sent_msg, received_msg


@pytest.mark.parametrize(
    ("webhook_env", "case_name"),
    [
        # ("", "empty"),
        # ("5", "numeric"),
        # ("default", "default"),
        ("dev", "dev"),
        ("default1111", "default"),
    ],
    # ids=["empty", "5", "default", "dev","default1111"],
    ids=["dev","default1111"],
)
def test_send_text_message_with_webhook_env(device_a, device_b, assert_api, user_a, user_b, webhook_env, case_name):
    content = f"s423-webhook-{case_name}-{uuid.uuid4().hex[:6]}"
    _send_text_message_with_webhook_env(
        device_a,
        device_b,
        assert_api,
        user_a,
        user_b,
        content=content,
        webhook_env=webhook_env,
    )


def test_combine_forward_media_inner_attachment_download(device_a, device_b, assert_api, user_a, user_b):
    _, image_sent, _ = _send_with_type(
        device_a,
        device_b,
        assert_api,
        user_a,
        user_b,
        type_key="image",
        payload={"targetId": user_b, "thumbnailLocalPath": ""},
    )
    _, video_sent, _ = _send_with_type(
        device_a,
        device_b,
        assert_api,
        user_a,
        user_b,
        type_key="video",
        payload={"targetId": user_b, "thumbnailLocalPath": ""},
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
        device_a,
        device_b,
        assert_api,
        user_a,
        user_b,
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
        (Cmd.downloadMessageAttachmentInCombine.value, image_inner),
        (Cmd.downloadMessageThumbnailInCombine.value, image_inner),
        (Cmd.downloadMessageAttachmentInCombine.value, video_inner),
        (Cmd.downloadMessageThumbnailInCombine.value, video_inner),
    ):
        resp = device_b.call("ChatManager", cmd, info={"message": message})
        _skip_if_missing_plugin(resp, cmd)
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "ChatManager",
                "cmd": cmd,
                "device": "deviceB",
                "result": None,
            },
            ignore_keys={"sequence"},
        )
    time.sleep(30)
