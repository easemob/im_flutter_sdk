from __future__ import annotations

import time
import uuid

import pytest

from src import Cmd
from tests.chat._utils import build_text

pytestmark = [pytest.mark.client, pytest.mark.chat]


def _wait_send_success(device_a, *, temp_id, description, predicate, timeout=30):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        success = device_a.receive_message(
            match_event_type=Cmd.onMessageSuccess.value,
            timeout=min(1.0, max(0.1, deadline - time.monotonic())),
        )
        success_data = (success or {}).get("data") or {}
        success_msg = success_data.get("msg") or {}
        if str(success_data.get("msgId")) == str(temp_id) and predicate(success_msg):
            return success_msg

        error_event = device_a.receive_message(
            match_event_type=Cmd.onMessageError.value,
            timeout=min(1.0, max(0.1, deadline - time.monotonic())),
        )
        error_data = (error_event or {}).get("data") or {}
        if str(error_data.get("msgId")) != str(temp_id):
            continue
        error = error_data.get("error") or {}
        raise AssertionError(
            f"{description}发送失败: tempId={temp_id}, "
            f"code={error.get('code')}, description={error.get('description')}, "
            f"event={error_event}"
        )
    raise AssertionError(
        f"{description}发送终态超时: tempId={temp_id}; "
        "未收到匹配的 onMessageSuccess/onMessageError"
    )


def _wait_message_list_event(device, event_type, *, msg_id, timeout=30):
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        event = device.receive_message(match_event_type=event_type, timeout=2)
        if event:
            seen.append(event)
        for message in (((event or {}).get("data") or {}).get("messages") or []):
            if isinstance(message, dict) and str(message.get("msgId")) == str(msg_id):
                return message
    pytest.fail(f"未收到消息列表事件: eventType={event_type}, msgId={msg_id}, seen={seen}")


def _assert_message_event(assert_api, event_type, message, *, msg_id, user_a, user_b,
                          body, direction, conv_id, has_read, has_deliver_ack):
    assert_api.assert_response_matches(
        {"type": "event", "eventType": event_type, "data": {"messages": [message]}},
        expected={"type": "event", "eventType": event_type, "data": {"messages": [{
            "msgId": msg_id, "from": user_a, "to": user_b, "convId": conv_id,
            "chatType": 0, "direction": direction, "status": 2,
            "hasRead": has_read,
            "isThread": False, "isContentReplaced": False,
            "deliverOnlineOnly": False, "body": body,
        }]}},
        ignore_keys={"timestamp", "sequence", "localTime", "serverTime", "broadcast", "onlineState",
                     "targetLanguages"},
    )


def _text_message(device_a, device_b, assert_api, user_a, user_b, content):
    device_a.drain_events(); device_b.drain_events()
    resp = device_a.call("ChatManager", Cmd.sendMessage.value, info=build_text(user_a, user_b, content))
    temp_id = ((resp.get("result") or {}).get("msgId"))
    assert temp_id, resp
    assert_api.assert_response_matches(
        resp,
        expected={"manager": "ChatManager", "cmd": Cmd.sendMessage.value, "device": "deviceA",
                  "result": {"msgId": temp_id, "from": user_a, "to": user_b, "convId": user_b,
                             "chatType": 0, "direction": 0, "status": 0, "hasRead": True,
                             "hasDeliverAck": False,
                             "isThread": False, "isContentReplaced": False,
                             "body": {"type": 0, "content": content}}},
        ignore_keys={"sequence", "localTime", "serverTime", "broadcast", "onlineState",
                     "deliverOnlineOnly", "targetLanguages", "translations"},
    )
    msg = _wait_send_success(
        device_a,
        temp_id=temp_id,
        description=f"文本消息 content={content}",
        predicate=lambda msg: (
            bool(msg.get("msgId"))
            and msg.get("from") == user_a
            and msg.get("to") == user_b
            and (msg.get("body") or {}).get("content") == content
        ),
    )
    body = {"type": 0, "content": content, "translations": {}}
    _assert_message_event(
        assert_api, Cmd.onMessageSuccess.value, msg, msg_id=msg["msgId"], user_a=user_a, user_b=user_b,
        body=body, direction=0, conv_id=user_b, has_read=True, has_deliver_ack=False,
    )
    received = _wait_message_list_event(device_b, Cmd.onMessagesReceived.value, msg_id=msg["msgId"])
    _assert_message_event(
        assert_api, Cmd.onMessagesReceived.value, received, msg_id=msg["msgId"], user_a=user_a, user_b=user_b,
        body=body, direction=1, conv_id=user_a, has_read=False, has_deliver_ack=True,
    )
    return msg


def _custom_message(device_a, device_b, assert_api, user_a, user_b):
    event_name = "translate-custom"
    params = {"k": "v"}
    body = {"type": 7, "event": event_name, "params": params}
    device_a.drain_events(); device_b.drain_events()
    resp_send = device_a.call(
        "ChatManager",
        Cmd.sendMessage.value,
        info={"to": user_b, "chatType": 0, "direction": 0,
              "body": {"type": 7, "event": event_name, "params": params}},
    )
    temp_id = ((resp_send.get("result") or {}).get("msgId"))
    assert temp_id, resp_send
    assert_api.assert_response_matches(
        resp_send,
        expected={"manager": "ChatManager", "cmd": Cmd.sendMessage.value, "device": "deviceA",
                  "result": {"msgId": temp_id, "from": user_a, "to": user_b, "convId": user_b,
                             "chatType": 0, "direction": 0,  "hasRead": True,
                             "hasDeliverAck": False,
                             "isThread": False, "isContentReplaced": False, "body": body}},
        ignore_keys={"sequence", "localTime", "serverTime", "broadcast", "onlineState", "deliverOnlineOnly"},
    )
    msg = _wait_send_success(
        device_a,
        temp_id=temp_id,
        description="自定义翻译前置消息",
        predicate=lambda candidate: (
            bool(candidate.get("msgId"))
            and candidate.get("from") == user_a
            and candidate.get("to") == user_b
            and (candidate.get("body") or {}).get("type") == 7
            and (candidate.get("body") or {}).get("event") == event_name
            and (candidate.get("body") or {}).get("params") == params
        ),
    )
    _assert_message_event(
        assert_api, Cmd.onMessageSuccess.value, msg, msg_id=msg["msgId"], user_a=user_a, user_b=user_b,
        body=body, direction=0, conv_id=user_b, has_read=True, has_deliver_ack=False,
    )
    received = _wait_message_list_event(device_b, Cmd.onMessagesReceived.value, msg_id=msg["msgId"])
    _assert_message_event(
        assert_api, Cmd.onMessagesReceived.value, received, msg_id=msg["msgId"], user_a=user_a, user_b=user_b,
        body=body, direction=1, conv_id=user_a, has_read=False, has_deliver_ack=True,
    )
    return msg


def _translate(device_a, assert_api, msg, languages):
    return device_a.call("ChatManager", Cmd.translateMessage.value, info={"message": msg, "targetLanguages": languages})


def _expected_translated_message(msg, *, languages):
    body = msg.get("body") or {}
    return {
        "manager": "ChatManager",
        "cmd": Cmd.translateMessage.value,
        "device": "deviceA",
        "result": {
            "msgId": "{{msgId}}", "from": msg.get("from"), "to": msg.get("to"),
            "convId": msg.get("convId"), "chatType": msg.get("chatType"),
            "direction": msg.get("direction"), "status": msg.get("status"),
            "hasRead": msg.get("hasRead"),
            "hasDeliverAck": msg.get("hasDeliverAck"),
            "isThread": msg.get("isThread"), "isContentReplaced": msg.get("isContentReplaced"),
            "body": {**body, "targetLanguages": languages, "translations": {}},
        },
    }


def _assert_translation_result(assert_api, resp, msg, languages):
    expected_languages = languages if languages != ["xx-INVALID"] else []
    assert_api.assert_response_matches(
        resp,
        expected=_expected_translated_message(msg, languages=expected_languages),
        context={"msgId": msg.get("msgId")},
        ignore_keys={"sequence", "timestamp", "localTime", "serverTime", "broadcast", "onlineState", "deliverOnlineOnly"},
    )


def test_chat_translate_message_empty_languages(device_a, device_b, assert_api, user_a, user_b):
    msg = _text_message(device_a, device_b, assert_api, user_a, user_b, f"translate-empty-{uuid.uuid4().hex[:6]}")
    resp = _translate(device_a, assert_api, msg, [])
    _assert_translation_result(assert_api, resp, msg, [])


def test_chat_translate_message_unsupported_language(device_a, device_b, assert_api, user_a, user_b):
    msg = _text_message(device_a, device_b, assert_api, user_a, user_b, f"translate-unsupported-{uuid.uuid4().hex[:6]}")
    resp = _translate(device_a, assert_api, msg, ["xx-INVALID"])
    _assert_translation_result(assert_api, resp, msg, ["xx-INVALID"])


def test_chat_translate_custom_message(device_a, device_b, assert_api, user_a, user_b):
    msg = _custom_message(device_a, device_b, assert_api, user_a, user_b)
    resp = _translate(device_a, assert_api, msg, ["zh-Hans"])
    assert_api.assert_response_matches(resp, expected={"manager": "ChatManager", "cmd": Cmd.translateMessage.value, "device": "deviceA", "result": {"code": 1, "description": "General error"}}, ignore_keys={"sequence"})
