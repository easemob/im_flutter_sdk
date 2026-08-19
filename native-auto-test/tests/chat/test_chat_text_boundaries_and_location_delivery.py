from __future__ import annotations

from contextlib import nullcontext
import time
import uuid

import pytest

from src import Cmd
from tests.chat._utils import build_text
from tests.chat.test_chat_message_types_and_delivery import (
    _assert_sender_devices_received_message,
    _send_type_and_receive,
)

pytestmark = [pytest.mark.client, pytest.mark.chat]


def _allure_step(name: str):
    try:
        import allure

        return allure.step(name)
    except ImportError:
        return nullcontext()


def _wait_text_event(device, event_type, *, content, timeout=30.0):
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        event = device.receive_message(match_event_type=event_type, timeout=2.0)
        if event:
            seen.append(event)
        messages = ((event or {}).get("data") or {}).get("messages") or []
        if event_type == Cmd.onMessageSuccess.value:
            message = ((event or {}).get("data") or {}).get("msg") or {}
            if (message.get("body") or {}).get("content") == content:
                return event, message
        else:
            for message in messages:
                if isinstance(message, dict) and (message.get("body") or {}).get("content") == content:
                    return event, message
    pytest.fail(f"未收到目标文本事件: eventType={event_type}, content={content!r}, seen={seen}")


def _send_text_and_assert(topology, assert_api, *, content):
    sender = topology.sender_action_device
    recipients = topology.recipient_devices
    sender_user = topology.sender_user
    recipient_user = topology.recipient_user
    expected_body = {"type": 0, "content": content}

    with _allure_step("清理发送账号和接收账号全部端的历史事件"):
        for device in (*topology.sender_devices, *recipients):
            device.drain_events(timeout=0.5)
    with _allure_step(f"{sender.device_name} 发送文本边界消息"):
        response = sender.call(
            "ChatManager",
            Cmd.sendMessage.value,
            info=build_text(sender_user, recipient_user, content),
        )
    temp_id = ((response.get("result") or {}).get("msgId"))
    assert temp_id, response
    with _allure_step(f"等待 {sender.device_name} 的消息发送成功回调（onMessageSuccess）"):
        success_event, sent = _wait_text_event(
            sender,
            Cmd.onMessageSuccess.value,
            content=content,
        )
    real_id = sent.get("msgId")
    assert real_id, f"onMessageSuccess 未返回真实 msgId: {success_event}"
    with _allure_step("确认文本边界消息已提交"):
        assert_api.assert_response_matches(
            response,
            expected={"manager": "ChatManager", "cmd": Cmd.sendMessage.value, "device": sender.device_name, "result": {
                "msgId": temp_id, "from": sender_user, "to": recipient_user, "convId": recipient_user,
                "chatType": 0, "direction": 0, "hasRead": True,
                "needReadReceipt": False, "isThread": False, "isContentReplaced": False, "body": expected_body,
            }},
            ignore_keys={"sequence", "localTime", "serverTime", "broadcast", "onlineState", "deliverOnlineOnly", "targetLanguages", "translations"},
        )

    with _allure_step("确认文本边界消息发送成功"):
        assert_api.assert_event_matches(
            {"type": success_event.get("type"), "eventType": success_event.get("eventType"), "data": {"messages": [sent]}},
            expected={"type": "event", "eventType": Cmd.onMessageSuccess.value, "data": {"messages": [{
                "msgId": real_id, "from": sender_user, "to": recipient_user, "convId": recipient_user,
                "chatType": 0, "direction": 0, "status": 2, "hasRead": True,
                "needReadReceipt": False, "isThread": False, "isContentReplaced": False, "deliverOnlineOnly": False,
                "body": expected_body,
            }]}},
            ignore_keys={
                "timestamp", "sequence", "localTime", "serverTime",
                "broadcast", "onlineState", "targetLanguages", "translations",
                "data.messages[0].hasDeliverAck",
            },
        )

    _assert_sender_devices_received_message(
        topology,
        assert_api,
        real_id=str(real_id),
        body=expected_body,
        content=content,
    )

    for role, recipient in zip(topology.recipient_roles, recipients):
        with _allure_step(f"接收端 {role} 收到文本边界消息（onMessagesReceived）"):
            received_event, received = _wait_text_event(
                recipient,
                Cmd.onMessagesReceived.value,
                content=content,
            )
        with _allure_step(f"确认接收端 {role} 收到当前文本"):
            assert_api.assert_event_matches(
                {"type": received_event.get("type"), "eventType": received_event.get("eventType"), "data": {"messages": [received]}},
                expected={"type": "event", "eventType": Cmd.onMessagesReceived.value, "data": {"messages": [{
                    "msgId": real_id, "from": sender_user, "to": recipient_user, "convId": sender_user,
                    "chatType": 0, "direction": 1, "status": 2, "hasRead": False,
                    "needReadReceipt": False, "isThread": False, "isContentReplaced": False, "deliverOnlineOnly": False,
                    "body": expected_body,
                }]}},
                ignore_keys={"timestamp", "sequence", "localTime", "serverTime", "broadcast", "onlineState", "targetLanguages", "translations"},
            )

    return real_id


@pytest.mark.parametrize(
    "content",
    [
        "",
        "special-中文-!@#$%^&*()_+-=[]{}|;:',.<>/?\\\n\t-🙂",
        "x" * 250,
    ],
    ids=["empty", "special-characters", "length-250"],
)
@pytest.mark.topology("account_a_to_account_b")
def test_chat_text_content_boundaries(topology, assert_api, content):
    with _allure_step("验证：chat text content boundaries"):
        boundary_name = (
            "空文本"
            if content == ""
            else "长度 250"
            if len(content) == 250
            else "特殊字符与 Unicode 文本"
        )
        try:
            import allure

            allure.dynamic.title(f"文本边界：{boundary_name}")
            allure.dynamic.description(
                f"A 发送{boundary_name}，验证 A 副端同步、B 全部在线端接收及多端送达回执。"
            )
            allure.dynamic.parameter("边界场景", boundary_name)
        except ImportError:
            pass
        _send_text_and_assert(topology, assert_api, content=content)


def test_chat_send_rejects_mismatched_from(device_a, device_b, assert_api, user_a, user_b):
    with _allure_step("验证：chat send rejects mismatched from"):
        content = f"mismatched-from-{uuid.uuid4().hex[:8]}"
        invalid_from = "__not_logged_in_sender__"
        device_a.drain_events()
        response = device_a.call(
            "ChatManager", Cmd.sendMessage.value,
            info=build_text(invalid_from, user_b, content),
        )
        temp_id = ((response.get("result") or {}).get("msgId"))
        assert temp_id, response
        assert_api.assert_response_matches(
            response,
            expected={"manager": "ChatManager", "cmd": Cmd.sendMessage.value, "device": "deviceA", "result": {
                "msgId": temp_id, "from": invalid_from, "to": user_b, "convId": user_b,
                "chatType": 0, "direction": 0, "hasRead": True,
                "needReadReceipt": False, "isThread": False, "isContentReplaced": False,
                "body": {"type": 0, "content": content},
            }},
            ignore_keys={"sequence", "localTime", "serverTime", "broadcast", "onlineState", "deliverOnlineOnly", "targetLanguages", "translations"},
        )
        event = device_a.receive_message(match_event_type=Cmd.onMessageError.value, timeout=20)
        assert_api.assert_response_matches(
            event,
            expected={"type": "event", "eventType": Cmd.onMessageError.value, "data": {
                "msgId": temp_id,
                "msg": {"msgId": temp_id, "from": invalid_from, "to": user_b, "convId": user_b,
                        "chatType": 0, "direction": 0, "hasRead": True,
                        "needReadReceipt": False, "isThread": False, "isContentReplaced": False, "deliverOnlineOnly": False,
                        "body": {"type": 0, "content": content, "translations": {}}},
                "error": {"code": 500, "description": "Message is invalid"},
            }},
            ignore_keys={"timestamp", "sequence", "localTime", "serverTime"},
        )


def test_chat_location_message_delivery_ack(device_a, device_b, assert_api, user_a, user_b):
    with _allure_step("验证：chat location message delivery ack"):
        payload = {
            "targetId": user_b, "latitude": 30.2741, "longitude": 120.1551,
            "address": "location-delivery", "buildingName": "location-delivery-building",
        }
        _, _, _, _, real_id = _send_type_and_receive(
            device_a, device_b, assert_api, user_a, user_b, type_key="location", payload=payload,
            need_read_receipt=True,
        )
        # 5.0 送达回执需发送标记 needReadReceipt=true（服务端才发 DELIVER_ACK）
        event = None
        deadline = time.monotonic() + 30.0
        while time.monotonic() < deadline:
            evt = device_a.receive_message(match_event_type=Cmd.onMessagesDelivered.value, timeout=3.0)
            if evt and any(
                str(m.get("msgId")) == str(real_id)
                for m in ((evt.get("data") or {}).get("messages") or [])
            ):
                event = evt
                break
        assert event is not None, f"未收到送达回执 msgId={real_id}"
        # 同一 msgId 重复出现不是合法的批量行为，必须暴露为失败，不能通过过滤首条掩盖。
        matched = [
            m for m in ((event.get("data") or {}).get("messages") or [])
            if isinstance(m, dict) and str(m.get("msgId")) == str(real_id)
        ]
        assert len(matched) == 1, f"送达事件目标消息重复或缺失: msgId={real_id}, matched={matched}, event={event}"
        assert_api.assert_response_matches(
            {"type": "event", "eventType": event.get("eventType"), "data": {"messages": matched}},
            expected={"type": "event", "eventType": event.get("eventType"), "data": {"messages": [{
                "msgId": real_id, "from": user_a, "to": user_b, "convId": user_b,
                "chatType": 0, "direction": 0, "status": 2, "hasRead": True,
                "needReadReceipt": True, "isPeerRead": False, "readReceiptCount": 0, "hasDeliverAck": True,
                "isThread": False, "isContentReplaced": False, "deliverOnlineOnly": False,
                "body": {"type": 3, "latitude": payload["latitude"], "longitude": payload["longitude"],
                         "address": payload["address"], "buildingName": payload["buildingName"]},
            }]}},
            ignore_keys={"timestamp", "sequence", "localTime", "serverTime"},
        )
