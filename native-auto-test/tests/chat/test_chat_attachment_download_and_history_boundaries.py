from __future__ import annotations

import os
import time
import uuid

import pytest

from src import Cmd, ne
from tests.chat.test_chat_message_callback_and_combine import _send_with_type
from tests.chat._utils import build_text
from tests.allure_helpers import _allure_step

pytestmark = [pytest.mark.client, pytest.mark.chat]


def _assert_delivery_ack_boolean(message, *, source):
    assert "hasDeliverAck" in message, f"{source} 缺少 hasDeliverAck: {message}"
    assert isinstance(message["hasDeliverAck"], bool), f"{source}.hasDeliverAck 不是 bool: {message}"


def _assert_sender_download(assert_api, response, *, message, user_a, user_b):
    """Assert stable message envelope fields; paths/timestamps remain dynamic."""
    body = message.get("body") or {}
    expected_body = {"type": body.get("type"), "fileStatus": 0}
    if body.get("type") == 1:
        expected_body.update({"isGif": False, "sendOriginalImage": False})
    result = response.get("result") or {}
    _assert_delivery_ack_boolean(result, source="downloadAttachment.result")
    assert_api.assert_response_matches(
        response,
        expected={
            "manager": "ChatManager", "cmd": Cmd.downloadAttachment.value, "device": "deviceA",
            "result": {
                "msgId": "{{msgId}}", "from": user_a, "to": user_b,
                "convId": user_b, "chatType": 0, "direction": 0, "status": 2,
                "hasRead": message.get("hasRead", True), "needReadReceipt": message.get("needReadReceipt", False), "isThread": message.get("isThread", False),
                "isContentReplaced": message.get("isContentReplaced", False),
                "body": expected_body,
            },
        },
        context={"msgId": message.get("msgId")},
        ignore_keys={"sequence", "timestamp", "localTime", "serverTime", "broadcast", "onlineState",
                     "localPath", "remotePath", "secret", "thumbnailLocalPath", "thumbnailRemotePath",
                     "thumbnailSecret", "fileSize", "displayName", "thumbnailStatus", "width", "height",
                     "duration", "translations", "targetLanguages", "hasDeliverAck"},
    )


def _wait_text_event(device, event_type, *, content, timeout=30.0):
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        event = device.receive_message(match_event_type=event_type, timeout=2)
        if event:
            seen.append(event)
        if event_type == Cmd.onMessageSuccess.value:
            message = ((event or {}).get("data") or {}).get("msg") or {}
            if (message.get("body") or {}).get("content") == content:
                return event, message
            continue
        for message in (((event or {}).get("data") or {}).get("messages") or []):
            if isinstance(message, dict) and (message.get("body") or {}).get("content") == content:
                return event, message
    pytest.fail(f"未收到文本消息事件: eventType={event_type}, content={content!r}, seen={seen}")


def _assert_text_event(assert_api, event_type, message, *, msg_id, user_a, user_b,
                       content, direction, conv_id, has_read, has_deliver_ack):
    assert_api.assert_response_matches(
        {"type": "event", "eventType": event_type, "data": {"messages": [message]}},
        expected={"type": "event", "eventType": event_type, "data": {"messages": [{
            "msgId": msg_id, "from": user_a, "to": user_b, "convId": conv_id,
            "chatType": 0, "direction": direction, "status": 2,
            "hasRead": has_read, "needReadReceipt": False, "isThread": False, "isContentReplaced": False,
            "deliverOnlineOnly": False,
            "body": {"type": 0, "content": content, "translations": {}},
        }]}},
        ignore_keys={"timestamp", "sequence", "localTime", "serverTime", "broadcast", "onlineState",
                     "targetLanguages"},
    )


def _send_text_and_assert(device_a, device_b, assert_api, user_a, user_b, content):
    device_a.drain_events()
    device_b.drain_events()
    response = device_a.call("ChatManager", Cmd.sendMessage.value, info=build_text(user_a, user_b, content))
    temp_id = ((response.get("result") or {}).get("msgId"))
    assert temp_id, response
    assert_api.assert_response_matches(
        response,
        expected={"manager": "ChatManager", "cmd": Cmd.sendMessage.value, "device": "deviceA", "result": {
            "msgId": temp_id, "from": user_a, "to": user_b, "convId": user_b,
            "chatType": 0, "direction": 0, "hasRead": True,
            "needReadReceipt": False, "isThread": False, "isContentReplaced": False,
            "body": {"type": 0, "content": content},
        }},
        ignore_keys={"sequence", "localTime", "serverTime", "broadcast", "onlineState",
                     "deliverOnlineOnly", "targetLanguages", "translations"},
    )
    _, sent = _wait_text_event(device_a, Cmd.onMessageSuccess.value, content=content)
    real_id = sent.get("msgId")
    _, received = _wait_text_event(device_b, Cmd.onMessagesReceived.value, content=content)
    _assert_text_event(
        assert_api, Cmd.onMessageSuccess.value, sent, msg_id=real_id, user_a=user_a, user_b=user_b,
        content=content, direction=0, conv_id=user_b, has_read=True, has_deliver_ack=None,
    )
    _assert_text_event(
        assert_api, Cmd.onMessagesReceived.value, received, msg_id=real_id, user_a=user_a, user_b=user_b,
        content=content, direction=1, conv_id=user_a, has_read=False, has_deliver_ack=None,
    )
    return sent


@pytest.mark.topology("account_a_to_account_b")
def test_chat_sender_downloads_image_and_video_attachment(topology, assert_api):
    """发送方下载自己发送的 image/video 附件（发送账号副端同步 + 接收账号全端收由 _send_with_type 内部完成）。"""
    with _allure_step("验证：发送方下载自己发送的 image/video 附件（发送账号副端同步 + 接收账号全端收由 _send_with_type 内部完成）。"):
        device_a = topology.sender_action_device
        user_a = topology.sender_user
        user_b = topology.recipient_user
        _, image_sent, _ = _send_with_type(topology, assert_api, type_key="image", payload={"targetId": user_b})
        response = device_a.call("ChatManager", Cmd.downloadAttachment.value, info={"message": image_sent})
        _assert_sender_download(assert_api, response, message=image_sent, user_a=user_a, user_b=user_b)
        _, video_sent, _ = _send_with_type(topology, assert_api, type_key="video", payload={"targetId": user_b})
        response = device_a.call("ChatManager", Cmd.downloadAttachment.value, info={"message": video_sent})
        _assert_sender_download(assert_api, response, message=video_sent, user_a=user_a, user_b=user_b)


def test_chat_download_attachment_for_text_message(device_a, device_b, assert_api, user_a, user_b):
    with _allure_step("验证：chat download attachment for text message"):
        content = f"download-text-{uuid.uuid4().hex[:8]}"
        msg = _send_text_and_assert(device_a, device_b, assert_api, user_a, user_b, content)
        resp_download = device_a.call("ChatManager", Cmd.downloadAttachment.value, info={"message": msg})
        _assert_delivery_ack_boolean(resp_download.get("result") or {}, source="downloadAttachment(text).result")
        assert_api.assert_response_matches(
            resp_download,
            expected={
                "manager": "ChatManager", "cmd": Cmd.downloadAttachment.value, "device": "deviceA",
                "result": {
                    "msgId": "{{msgId}}", "from": user_a, "to": user_b, "convId": user_b,
                    "chatType": 0, "direction": 0, "status": 2,
                    "hasRead": True, "needReadReceipt": False,  "isThread": False, "isContentReplaced": False,
                    "body": {"type": 0, "content": content, "translations": {}},
                },
            },
            context={"msgId": msg.get("msgId")},
            ignore_keys={"sequence", "timestamp", "localTime", "serverTime", "broadcast", "onlineState",
                         "deliverOnlineOnly", "targetLanguages", "hasDeliverAck"},
        )


def _history_message_expected(msg, *, user_a, user_b):
    return {
        "msgId": "{{msgId}}", "from": user_a, "to": user_b, "convId": user_b,
        "chatType": 0, "direction": 0, "status": 2, "hasRead": True,
        "needReadReceipt": False,
        "isThread": False, "isContentReplaced": False,
        "body": {"type": 0, "content": "{{content}}", "targetLanguages": [], "translations": {}},
    }


def test_chat_fetch_history_page_size_one_cursor(device_a, device_b, assert_api, user_a, user_b):
    with _allure_step("验证：chat fetch history page size one cursor"):
        messages = []
        for content in (f"history-page-a-{uuid.uuid4().hex[:6]}", f"history-page-b-{uuid.uuid4().hex[:6]}"):
            messages.append(_send_text_and_assert(device_a, device_b, assert_api, user_a, user_b, content))
        assert len(messages) == 2
        time.sleep(float(os.getenv("CHAT_HISTORY_SETTLE_SECONDS", "5")))
        first = device_a.call("ChatManager", Cmd.fetchHistoryMessagesByOptions.value, info={"convId": user_b, "type": 0, "pageSize": 1, "cursor": ""})
        result = first.get("result") or {}
        assert result.get("list"), first
        _assert_delivery_ack_boolean(result["list"][0], source="fetchHistoryMessagesByOptions.first.list[0]")
        first_msg = messages[1]
        assert_api.assert_response_matches(
            first,
            expected={"manager": "ChatManager", "cmd": Cmd.fetchHistoryMessagesByOptions.value, "device": "deviceA",
                      "result": {"cursor": ne(""), "list": [_history_message_expected(first_msg, user_a=user_a, user_b=user_b)]}},
            context={"msgId": first_msg.get("msgId"), "content": (first_msg.get("body") or {}).get("content")},
            ignore_keys={"sequence", "timestamp", "localTime", "serverTime", "broadcast", "onlineState", "hasDeliverAck"},
        )
        cursor = result.get("cursor")
        if cursor:
            second = device_a.call("ChatManager", Cmd.fetchHistoryMessagesByOptions.value, info={"convId": user_b, "type": 0, "pageSize": 1, "cursor": cursor})
            second_result = second.get("result") or {}
            assert second_result.get("list"), second
            _assert_delivery_ack_boolean(second_result["list"][0], source="fetchHistoryMessagesByOptions.second.list[0]")
            assert_api.assert_response_matches(
                second,
                expected={"manager": "ChatManager", "cmd": Cmd.fetchHistoryMessagesByOptions.value, "device": "deviceA",
                          "result": {"cursor": ne(""), "list": [_history_message_expected(messages[0], user_a=user_a, user_b=user_b)]}},
                context={"msgId": messages[0].get("msgId"), "content": (messages[0].get("body") or {}).get("content")},
                ignore_keys={"sequence", "timestamp", "localTime", "serverTime", "broadcast", "onlineState", "hasDeliverAck"},
            )
