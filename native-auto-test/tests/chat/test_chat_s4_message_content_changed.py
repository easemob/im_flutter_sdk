from __future__ import annotations

from contextlib import nullcontext
import os
import time
import uuid

import pytest

from src import Cmd, gt
from tests.chat._utils import build_text


pytestmark = [pytest.mark.client, pytest.mark.chat, pytest.mark.agorachat1_4_0]


def _allure_step(name: str):
    try:
        import allure

        return allure.step(name)
    except ImportError:
        return nullcontext()


def _assert_response_step(assert_api, step_name: str, actual: dict, **kwargs) -> None:
    """Keep strict assertion attachments under a business-readable Allure step."""
    with _allure_step(step_name):
        assert_api.assert_response_matches(actual, **kwargs)


@pytest.mark.topology("account_b_to_account_a")
def test_chat_modify_custom_message_content_changed_event(topology, assert_api):
    """
    覆盖发版项：
    - v4.15.1 修复：修改非文本/自定义消息时，onMessageContentChanged 回调返回内容修复
    """
    action_sender = topology.sender_action_device
    recipients = topology.recipient_devices
    sender_user = topology.sender_user
    recipient_user = topology.recipient_user

    for device in (*topology.sender_devices, *recipients):
        device.drain_events(timeout=0.5)

    old_event = f"custom-old-{uuid.uuid4().hex[:6]}"
    new_event = f"custom-new-{uuid.uuid4().hex[:6]}"
    old_params = {"k1": "v1"}
    new_params = {"k2": "v2", "release": "agorachat1.4.0"}
    custom_message = build_text(sender_user, recipient_user, "")
    custom_message["body"] = {
        "type": 7,
        "event": old_event,
        "params": old_params,
    }

    with _allure_step(f"{action_sender.device_name} 向接收账号发送自定义消息"):
        resp_send = action_sender.call(
            "ChatManager",
            Cmd.sendMessage.value,
            info=custom_message,
        )

    with _allure_step("等待消息发送成功回调（onMessageSuccess）"):
        evt_success = action_sender.receive_message(
            match_event_type=Cmd.onMessageSuccess.value,
            timeout=20.0,
        )
    with _allure_step("取得服务端消息 ID"):
        temp_id = (evt_success.get("data") or {}).get("msgId")
        success_msg = ((evt_success.get("data") or {}).get("msg") or {})
        real_id = success_msg.get("msgId")
        assert isinstance(real_id, str) and real_id, (
            f"发送自定义消息后未获取到真实 msgId: {evt_success}"
        )

    _assert_response_step(
        assert_api,
        "确认自定义消息已提交",
        resp_send,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.sendMessage.value,
            "device": action_sender.device_name,
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
                "body": {
                    "type": 7,
                    "event": "{{oldEvent}}",
                    "params": old_params,
                },
            },
        },
        context={"tempId": temp_id, "oldEvent": old_event, "fromUser": sender_user, "toUser": recipient_user},
        ignore_keys={
            "sequence",
            "serverTime",
            "localTime",
            "broadcast",
            "onlineState",
            "deliverOnlineOnly",
        },
    )
    _assert_response_step(
        assert_api,
        "确认消息发送成功",
        {"type": "event", "eventType": Cmd.onMessageSuccess.value, "data": {"messages": [success_msg]}},
        expected={
            "type": "event",
            "eventType": Cmd.onMessageSuccess.value,
            "data": {
                "messages": [
                    {
                        "msgId": "{{realId}}",
                        "from": "{{fromUser}}",
                        "to": "{{toUser}}",
                        "convId": "{{toUser}}",
                        "chatType": 0,
                        "direction": 0,
                        "status": 2,
                        "hasRead": True,
                        "hasReadAck": False,
                        "hasDeliverAck": False,
                        "needGroupAck": False,
                        "isThread": False,
                        "isContentReplaced": False,
                        "deliverOnlineOnly": False,
                        "body": {"type": 7, "event": "{{oldEvent}}", "params": old_params},
                    }
                ]
            },
        },
        context={"realId": real_id, "fromUser": sender_user, "toUser": recipient_user, "oldEvent": old_event},
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "broadcast", "onlineState"},
    )

    for role, device in zip(topology.recipient_roles, recipients):
        with _allure_step(f"接收端 {role} 收到原始自定义消息（onMessagesReceived）"):
            evt_recv = device.receive_message(
                match_event_type=Cmd.onMessagesReceived.value,
                timeout=20.0,
            )
            assert_api.assert_response_matches(
                evt_recv,
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
                                "chatType": 0,
                                "direction": 1,
                                "status": 2,
                                "hasRead": False,
                                "hasReadAck": False,
                                "hasDeliverAck": True,
                                "needGroupAck": False,
                                "isThread": False,
                                "isContentReplaced": False,
                                "deliverOnlineOnly": False,
                                "body": {
                                    "type": 7,
                                    "event": "{{oldEvent}}",
                                    "params": old_params,
                                },
                            }
                        ]
                    },
                },
                context={
                    "realId": real_id,
                    "fromUser": sender_user,
                    "toUser": recipient_user,
                    "oldEvent": old_event,
                },
                ignore_keys={
                    "timestamp", "sequence", "serverTime", "localTime",
                    "broadcast", "onlineState", "attributes", "targetLanguages",
                    "translations", "receiverList",
                },
            )
    time.sleep(float(os.getenv("CHAT_MODIFY_SETTLE_SECONDS", "5")))

    with _allure_step(f"{action_sender.device_name} 修改自定义消息内容"):
        resp_modify = action_sender.call(
            "ChatManager",
            Cmd.modifyMessage.value,
            info={
                "msgId": real_id,
                "msgBody": {
                    "type": 7,
                    "event": new_event,
                    "params": new_params,
                },
                "attributes": {"editedByCase": "agorachat1.4.0"},
            },
        )
    _assert_response_step(
        assert_api,
        "确认消息内容已修改",
        resp_modify,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.modifyMessage.value,
            "device": action_sender.device_name,
                "result": {
                    "msgId": "{{realId}}",
                "from": "{{fromUser}}",
                "to": "{{toUser}}",
                "convId": "{{toUser}}",
                "chatType": 0,
                "direction": 0,
                "status": 2,
                "hasRead": True,
                "hasReadAck": False,
                "hasDeliverAck": True,
                "needGroupAck": False,
                "isThread": False,
                "isContentReplaced": False,
                "attributes": {"editedByCase": "agorachat1.4.0"},
                "body": {
                    "type": 7,
                    "event": "{{newEvent}}",
                    "params": new_params,
                    "operatorId": "{{operatorId}}",
                    "operatorTime": gt(0),
                    "operatorCount": gt(0),
                },
            },
        },
        context={"realId": real_id, "newEvent": new_event, "fromUser": sender_user, "toUser": recipient_user, "operatorId": sender_user},
        ignore_keys={
            "sequence",
            "serverTime",
            "localTime",
            "broadcast",
            "onlineState",
            "targetLanguages",
            "translations",
        },
    )
    with _allure_step("等待消息送达回调（onMessagesDelivered）"):
        evt_delivered = action_sender.receive_message(
            match_event_type=Cmd.onMessagesDelivered.value,
            timeout=20.0,
        )
    with _allure_step("确认送达回调对应当前消息"):
        delivered_messages = ((evt_delivered or {}).get("data") or {}).get("messages") or []
        delivered = next(
            message for message in delivered_messages
            if isinstance(message, dict) and str(message.get("msgId")) == str(real_id)
        )
    _assert_response_step(
        assert_api,
        "确认消息已送达接收账号",
        {"type": "event", "eventType": Cmd.onMessagesDelivered.value, "data": {"messages": [delivered]}},
        expected={
            "type": "event",
            "eventType": Cmd.onMessagesDelivered.value,
            "data": {
                "messages": [
                    {
                        "msgId": "{{realId}}",
                        "from": "{{fromUser}}",
                        "to": "{{toUser}}",
                        "convId": "{{toUser}}",
                        "chatType": 0,
                        "direction": 0,
                        "status": 2,
                        "hasRead": True,
                        "hasReadAck": False,
                        "hasDeliverAck": True,
                        "needGroupAck": False,
                        "isThread": False,
                        "isContentReplaced": False,
                        "deliverOnlineOnly": False,
                        "body": {"type": 7, "event": "{{oldEvent}}", "params": old_params},
                    }
                ]
            },
        },
        context={"realId": real_id, "fromUser": sender_user, "toUser": recipient_user, "oldEvent": old_event},
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "broadcast", "onlineState"},
    )

    for role, device in zip(topology.recipient_roles, recipients):
        with _allure_step(f"接收端 {role} 收到内容更新通知（onMessageContentChanged）"):
            evt_changed = device.receive_message(
                match_event_type=Cmd.onMessageContentChanged.value,
                timeout=20.0,
            )
            assert_api.assert_response_matches(
                evt_changed,
                expected={
                    "type": "event",
                    "eventType": Cmd.onMessageContentChanged.value,
                    "data": {
                        "message": {
                            "msgId": "{{realId}}",
                            "from": "{{fromUser}}",
                            "to": "{{toUser}}",
                            "convId": "{{fromUser}}",
                            "chatType": 0,
                            "direction": 1,
                            "status": 2,
                            "hasRead": False,
                            "hasReadAck": False,
                            "hasDeliverAck": True,
                            "needGroupAck": False,
                            "isThread": False,
                            "isContentReplaced": False,
                            "body": {
                                "type": 7,
                                "event": "{{newEvent}}",
                                "params": new_params,
                            },
                        },
                        "operatorId": "{{operatorId}}",
                        "operationTime": gt(0),
                    },
                },
                context={
                    "realId": real_id,
                    "newEvent": new_event,
                    "operatorId": sender_user,
                    "fromUser": sender_user,
                    "toUser": recipient_user,
                },
                ignore_keys={
                    "timestamp", "sequence", "serverTime", "localTime",
                    "broadcast", "onlineState", "targetLanguages", "translations",
                    "receiverList", "deliverOnlineOnly", "attributes",
                },
            )
