from __future__ import annotations

import uuid

import pytest

from src import Cmd, gt


pytestmark = [pytest.mark.client, pytest.mark.chat, pytest.mark.agorachat1_4_0]


def test_chat_modify_custom_message_content_changed_event(device_a, device_b, assert_api, user_a, user_b):
    """
    覆盖发版项：
    - v4.15.1 修复：修改非文本/自定义消息时，onMessageContentChanged 回调返回内容修复
    """
    try:
        device_a.drain_events()
        device_b.drain_events()
    except Exception:
        pass

    old_event = f"custom-old-{uuid.uuid4().hex[:6]}"
    new_event = f"custom-new-{uuid.uuid4().hex[:6]}"
    old_params = {"k1": "v1"}
    new_params = {"k2": "v2", "release": "agorachat1.4.0"}

    resp_send = device_a.call(
        "ChatManager",
        Cmd.sendMessageWithType.value,
        info={
            "type": "custom",
            "payload": {
                "targetId": user_b,
                "event": old_event,
                "params": old_params,
            },
            "chatType": 0,
        },
    )
    if resp_send.get("success") is False and "MissingPluginException" in str((resp_send.get("error") or {}).get("description", "")):
        pytest.skip("MissingPlugin: sendMessageWithType 未在当前集成端实现")

    evt_success = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
    temp_id = (evt_success.get("data") or {}).get("msgId")
    success_msg = ((evt_success.get("data") or {}).get("msg") or {})
    real_id = success_msg.get("msgId")
    assert isinstance(real_id, str) and real_id, f"发送自定义消息后未获取到真实 msgId: {evt_success}"

    assert_api.assert_response_matches(
        resp_send,
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
                "hasRead": True,
                "hasReadAck": False,
                "hasDeliverAck": False,
                "needGroupAck": False,
                "isThread": False,
                "isContentReplaced": False,
                "deliverOnlineOnly": False,
                "body": {
                    "type": 7,
                    "event": "{{oldEvent}}",
                    "params": old_params,
                },
            },
        },
        context={"tempId": temp_id, "oldEvent": old_event, "fromUser": user_a, "toUser": user_b},
        ignore_keys={
            "sequence",
            "serverTime",
            "localTime",
            "broadcast",
            "onlineState",
        },
    )
    assert_api.assert_response_matches(
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
        context={"realId": real_id, "fromUser": user_a, "toUser": user_b, "oldEvent": old_event},
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "broadcast", "onlineState"},
    )

    evt_recv = device_b.receive_message(match_event_type=Cmd.onMessagesReceived.value, timeout=20.0)
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
        context={"realId": real_id, "fromUser": user_a, "toUser": user_b, "oldEvent": old_event},
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "broadcast", "onlineState", "attributes", "targetLanguages", "translations", "receiverList"},
    )

    resp_modify = device_a.call(
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
    assert_api.assert_response_matches(
        resp_modify,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.modifyMessage.value,
            "device": "deviceA",
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
        context={"realId": real_id, "newEvent": new_event, "fromUser": user_a, "toUser": user_b, "operatorId": user_a},
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
    evt_delivered = device_a.receive_message(match_event_type=Cmd.onMessagesDelivered.value, timeout=20.0)
    delivered_messages = ((evt_delivered or {}).get("data") or {}).get("messages") or []
    delivered = next(
        message for message in delivered_messages
        if isinstance(message, dict) and str(message.get("msgId")) == str(real_id)
    )
    assert_api.assert_response_matches(
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
        context={"realId": real_id, "fromUser": user_a, "toUser": user_b, "oldEvent": old_event},
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "broadcast", "onlineState"},
    )

    evt_changed = device_b.receive_message(match_event_type=Cmd.onMessageContentChanged.value, timeout=20.0)
    assert evt_changed, "接收端未收到 onMessageContentChanged 回调"
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
        context={"realId": real_id, "newEvent": new_event, "operatorId": user_a, "fromUser": user_a, "toUser": user_b},
        ignore_keys={
            "timestamp",
            "sequence",
            "serverTime",
            "localTime",
            "broadcast",
            "onlineState",
            "targetLanguages",
            "translations",
            "receiverList",
            "deliverOnlineOnly",
            "attributes",
        },
    )
