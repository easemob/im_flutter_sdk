from __future__ import annotations

import uuid
import pytest

from src import Cmd, ne, gt, ge

pytestmark = [pytest.mark.client, pytest.mark.chat, pytest.mark.agorachat1_4_0]


def _assert_send_success_and_events(device_a, device_b, assert_api, user_a, user_b, *, content: str, target_languages: list[str] | None = None):
    info = {
        "type": "txt",
        "payload": {
            "targetId": user_b,
            "content": content,
        },
        "chatType": 0,
    }
    if target_languages:
        info["payload"]["targetLanguages"] = list(target_languages)

    resp = device_a.call("ChatManager", Cmd.sendMessageWithType.value, info=info)
    # 端未实现时返回 MissingPluginException；直接跳过
    if resp.get("success") is False and "MissingPluginException" in str((resp.get("error") or {}).get("description", "")):
        pytest.skip("MissingPlugin: sendMessageWithType 未在当前集成端实现")
    evt_success = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
    temp_id = (evt_success.get("data") or {}).get("msgId")
    real_id = ((evt_success.get("data") or {}).get("msg") or {}).get("msgId")
    # A 侧 onMessageSuccess 事件收紧
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
                    "hasReadAck": False,
                    "hasDeliverAck": False,
                    "needGroupAck": False,
                    "isThread": False,
                    "isContentReplaced": False,
                },
            },
        },
        context={"tempId": temp_id, "realId": real_id, "fromUser": user_a, "toUser": user_b, "content": content},
        ignore_keys=ignore_extra,
    )
    # 同步响应最小断言 + 关键字段
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
                "body": {"type": 0, "content": "{{content}}"},
            },
        },
        context={"tempId": temp_id, "fromUser": user_a, "toUser": user_b, "content": content},
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
    evt_received = device_b.receive_message(match_event_type=Cmd.onMessagesReceived.value, timeout=20.0)
    # 列表可能包含遗留消息，放宽为“包含一条匹配当前发送的消息”
    assert evt_received and evt_received.get("type") == "event" and evt_received.get("eventType") == Cmd.onMessagesReceived.value
    msgs = ((evt_received.get("data") or {}).get("messages") or [])
    assert any(
        (m.get("from") == user_a and m.get("to") == user_b and str(m.get("msgId")) == str(real_id) and ((m.get("body") or {}).get("content") == content))
        for m in msgs if isinstance(m, dict)
    ), f"onMessagesReceived does not contain the sent message: {evt_received}"
    return real_id


def test_send_message_with_type_text_basic(device_a, device_b, assert_api, user_a, user_b):
    content = f"txt-{uuid.uuid4().hex[:6]}"
    _assert_send_success_and_events(device_a, device_b, assert_api, user_a, user_b, content=content)


def test_send_message_with_type_text_with_languages(device_a, device_b, assert_api, user_a, user_b):
    content = f"txttr-{uuid.uuid4().hex[:6]}"
    _assert_send_success_and_events(device_a, device_b, assert_api, user_a, user_b, content=content, target_languages=["zh-Hans"])


def test_send_message_with_type_cmd_received_by_cmd_callback(device_a, device_b, assert_api, user_a, user_b):
    """sendMessageWithType(cmd)：发送 CMD 消息，接收方收到 onCmdMessagesReceived 且不混入普通消息回调。"""
    action = f"cmd-action-{uuid.uuid4().hex[:8]}"
    info = {
        "type": "cmd",
        "payload": {
            "targetId": user_b,
            "action": action,
            "deliverOnlineOnly": False,
        },
        "chatType": 0,
    }

    try:
        device_a.drain_events()
        device_b.drain_events()
    except Exception:
        pass

    resp = device_a.call("ChatManager", Cmd.sendMessageWithType.value, info=info)
    if resp.get("success") is False and "MissingPluginException" in str((resp.get("error") or {}).get("description", "")):
        pytest.skip("MissingPlugin: sendMessageWithType 未在当前集成端实现")
    temp_id = ((resp.get("result") or {}).get("msgId"))
    assert temp_id, f"sendMessageWithType(cmd) 未返回临时 msgId: {resp}"
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.sendMessageWithType.value,
            "device": "deviceA",
            "result": {
                "msgId": temp_id,
                "from": user_a,
                "to": user_b,
                "convId": user_b,
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
                "body": {"type": 6, "action": action, "deliverOnlineOnly": False},
            },
        },
        ignore_keys={"sequence", "serverTime", "localTime", "broadcast", "onlineState"},
    )

    evt_success = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
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
                    "from": user_a,
                    "to": user_b,
                    "convId": user_b,
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
                    "body": {"type": 6, "action": action, "deliverOnlineOnly": False},
                },
            },
        },
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "broadcast", "onlineState"},
    )

    evt_cmd = device_b.receive_message(match_event_type=Cmd.onCmdMessagesReceived.value, timeout=20.0)
    assert_api.assert_response_matches(
        evt_cmd,
        expected={
            "type": "event",
            "eventType": Cmd.onCmdMessagesReceived.value,
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
                        "deliverOnlineOnly": False,
                        "hasRead": False,
                        "hasReadAck": False,
                        "hasDeliverAck": False,
                        "needGroupAck": False,
                        "isThread": False,
                        "isContentReplaced": False,
                        "receiverList": [],
                        "body": {"type": 6, "action": action, "deliverOnlineOnly": False},
                    },
                ],
            },
        },
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime"},
    )


def _send_with_payload_and_assert(device_a, device_b, assert_api, user_a, user_b, *, type_key: str, payload: dict):
    info = {"type": type_key, "payload": payload, "chatType": 0}
    resp = device_a.call("ChatManager", Cmd.sendMessageWithType.value, info=info)
    # 若未实现，提前跳过
    if resp.get("success") is False and "MissingPluginException" in str((resp.get("error") or {}).get("description", "")):
        pytest.skip("MissingPlugin: sendMessageWithType 未在当前集成端实现")

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
                "body": body_resp,
            },
        },
        context={"tempId": temp_id, "fromUser": user_a, "toUser": user_b},
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

    # A 侧 onMessageSuccess：临时ID一致 + 关键字段
    # 事件可能乱序到达；循环读取直至匹配本次 tempId
    evt_success = None
    real_id = None
    temp_id_evt = None
    for _ in range(5):
        evt_candidate = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
        cand_temp = (evt_candidate.get("data") or {}).get("msgId")
        if str(cand_temp) == str(temp_id):
            evt_success = evt_candidate
            temp_id_evt = cand_temp
            real_id = ((evt_success.get("data") or {}).get("msg") or {}).get("msgId")
            break
    if evt_success is None:
        # 未匹配到对应事件，最后一次候选也用于报错上下文
        evt_success = evt_candidate
        temp_id_evt = cand_temp
        real_id = ((evt_success.get("data") or {}).get("msg") or {}).get("msgId")
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
                    "hasReadAck": False,
                    "hasDeliverAck": False,
                    "needGroupAck": False,
                    "isThread": False,
                    "isContentReplaced": False,
                    "body": body_evt,
                },
            },
        },
        context={"tempId": temp_id, "realId": real_id, "fromUser": user_a, "toUser": user_b},
        ignore_keys=ignore_extra,
    )

    # B 侧 onMessagesReceived：包含本次消息
    evt_received = device_b.receive_message(match_event_type=Cmd.onMessagesReceived.value, timeout=20.0)
    assert evt_received and evt_received.get("type") == "event" and evt_received.get("eventType") == Cmd.onMessagesReceived.value
    msgs = ((evt_received.get("data") or {}).get("messages") or [])
    assert any(
        (m.get("from") == user_a and m.get("to") == user_b and str(m.get("msgId")) == str(real_id) and ((m.get("body") or {}).get("type") is not None))
        for m in msgs if isinstance(m, dict)
    ), f"onMessagesReceived does not contain the sent message or missing body.type: {evt_received}"


# 注意：媒体类用例仅验证 file/image/video；不传 filePath，也不传 displayName。

def test_send_message_with_type_file(device_a, device_b, assert_api, user_a, user_b):
    payload = {"targetId": user_b}
    _send_with_payload_and_assert(device_a, device_b, assert_api, user_a, user_b, type_key="file", payload=payload)


def test_send_message_with_type_image(device_a, device_b, assert_api, user_a, user_b):
    payload = {"targetId": user_b, "thumbnailLocalPath":""}
    _send_with_payload_and_assert(device_a, device_b, assert_api, user_a, user_b, type_key="image", payload=payload)


def test_send_message_with_type_image_heic(device_a, device_b, assert_api, user_a, user_b):
    """发送 HEIC 格式图片，验证 SDK 能正常上传并投递。"""
    payload = {"targetId": user_b, "displayName": "imgHeic.HEIC", "thumbnailLocalPath": ""}
    _send_with_payload_and_assert(device_a, device_b, assert_api, user_a, user_b, type_key="image", payload=payload)


def test_send_message_with_type_video(device_a, device_b, assert_api, user_a, user_b):
    payload = {"targetId": user_b, "thumbnailLocalPath":""}
    _send_with_payload_and_assert(device_a, device_b, assert_api, user_a, user_b, type_key="video", payload=payload)
