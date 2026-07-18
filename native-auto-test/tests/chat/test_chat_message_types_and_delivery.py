from __future__ import annotations

import time
import uuid

import pytest

from src import Cmd

pytestmark = [pytest.mark.client, pytest.mark.chat]


def _wait_event(device, event_type: str, *, predicate=None, timeout: float = 30.0):
    seen = []
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        evt = device.receive_message(
            match_event_type=event_type,
            timeout=min(2.0, max(0.1, deadline - time.monotonic())),
        )
        if not evt:
            continue
        seen.append(evt)
        if predicate is None or predicate(evt):
            return evt
    pytest.fail(f"未收到 {event_type} 目标事件，seen={seen}")


def _wait_delivery_event(device, *, real_id: str, timeout: float = 30.0):
    """兼容当前桥接可能使用的 delivery 回调命名，只接受目标真实 msgId。"""
    seen = []
    deadline = time.monotonic() + timeout
    allowed = {Cmd.onMessagesDelivered.value, Cmd.onMessageDeliveryAck.value}
    while time.monotonic() < deadline:
        evt = device.receive_message(timeout=min(2.0, max(0.1, deadline - time.monotonic())))
        if not evt:
            continue
        seen.append(evt)
        if evt.get("eventType") not in allowed:
            continue
        messages = ((evt.get("data") or {}).get("messages")) or []
        if any(isinstance(m, dict) and str(m.get("msgId")) == str(real_id) for m in messages):
            return evt
    pytest.fail(f"未收到 delivery 目标事件，realId={real_id}, seen={seen}")


def _send_type_and_receive(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    *,
    type_key: str,
    payload: dict,
):
    device_a.drain_events()
    device_b.drain_events()
    resp = device_a.call(
        "ChatManager",
        Cmd.sendMessageWithType.value,
        info={"type": type_key, "payload": payload, "chatType": 0},
    )
    for device in (device_a, device_b):
        setting = device.call("Client", Cmd.updateDeliveryAckSetting.value, info={"requireDeliveryAck": True})
        assert_api.assert_response_matches(
            setting,
            expected={"manager": "Client", "cmd": Cmd.updateDeliveryAckSetting.value, "device": getattr(device, "_device", "deviceA"), "result": None},
            ignore_keys={"sequence"},
        )
    if resp.get("success") is False and "MissingPluginException" in str((resp.get("error") or {}).get("description", "")):
        pytest.skip(f"MissingPlugin: sendMessageWithType({type_key})")
    result = resp.get("result") or {}
    temp_id = result.get("msgId")
    assert temp_id, f"sendMessageWithType({type_key}) 未返回临时 msgId: {resp}"
    success_evt = _wait_event(
        device_a,
        Cmd.onMessageSuccess.value,
        predicate=lambda e: str((e.get("data") or {}).get("msgId")) == str(temp_id)
        and str(((e.get("data") or {}).get("msg") or {}).get("msgId")) != "",
    )
    sent = ((success_evt.get("data") or {}).get("msg")) or {}
    real_id = sent.get("msgId")
    assert real_id, f"onMessageSuccess 未返回真实 msgId: {success_evt}"

    body = sent.get("body") or {}
    if type_key == "location":
        expected_body = {
            "type": 3,
            "latitude": payload["latitude"],
            "longitude": payload["longitude"],
            "address": payload["address"],
            "buildingName": payload["buildingName"],
        }
        body_ignore = set()
    elif type_key == "custom":
        expected_body = {
            "type": 7,
            "event": payload["event"],
            "params": payload["params"],
        }
        body_ignore = set()
    elif type_key == "voice":
        expected_body = {
            "type": 4,
            "displayName": "voice.mp3",
            "fileStatus": 3,
            "duration": payload["duration"],
        }
        body_ignore = {"localPath", "remotePath", "secret", "fileSize"}
    elif type_key == "cmd":
        expected_body = {
            "type": 6,
            "action": payload["action"],
            "deliverOnlineOnly": payload["deliverOnlineOnly"],
        }
        body_ignore = set()
    else:
        expected_body = {"type": 0, "content": payload["content"]}
        body_ignore = {"translations", "targetLanguages"}

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
                "hasRead": True,
                "hasReadAck": False,
                "hasDeliverAck": False,
                "needGroupAck": False,
                "isThread": False,
                "isContentReplaced": False,
                "deliverOnlineOnly": False,
                "body": expected_body,
            },
        },
        context={"tempId": temp_id, "fromUser": user_a, "toUser": user_b},
        ignore_keys={
            "sequence", "serverTime", "localTime", "broadcast", "onlineState",
            *body_ignore,
        },
    )

    assert_api.assert_response_matches(
        success_evt,
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
                    "hasRead": True,
                    "hasReadAck": False,
                    "hasDeliverAck": sent.get("hasDeliverAck"),
                    "needGroupAck": False,
                    "isThread": False,
                    "isContentReplaced": False,
                    "deliverOnlineOnly": False,
                    "body": expected_body,
                },
            },
        },
        context={"tempId": temp_id, "realId": real_id, "fromUser": user_a, "toUser": user_b},
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "broadcast", "onlineState", *body_ignore},
    )

    received_evt = _wait_event(
        device_b,
        Cmd.onMessagesReceived.value if type_key != "cmd" else Cmd.onCmdMessagesReceived.value,
        predicate=lambda e: any(
            isinstance(m, dict) and str(m.get("msgId")) == str(real_id)
            for m in (((e.get("data") or {}).get("messages")) or [])
        ),
    )
    received = next(
        m for m in (((received_evt.get("data") or {}).get("messages")) or [])
        if isinstance(m, dict) and str(m.get("msgId")) == str(real_id)
    )
    receive_body = received.get("body") or {}
    receive_expected_body = dict(expected_body)
    if type_key == "voice":
        receive_expected_body["fileStatus"] = 0
    assert_api.assert_response_matches(
        {"type": "event", "eventType": received_evt.get("eventType"), "data": {"messages": [received]}},
        expected={
            "type": "event",
            "eventType": received_evt.get("eventType"),
            "data": {
                "messages": [{
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
                    "body": receive_expected_body,
                }],
            },
        },
        context={"realId": real_id, "fromUser": user_a, "toUser": user_b},
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", *body_ignore},
    )
    return resp, success_evt, received_evt, temp_id, real_id


def test_chat_missing_location_message_send_receive(device_a, device_b, assert_api, user_a, user_b):
    _send_type_and_receive(
        device_a, device_b, assert_api, user_a, user_b,
        type_key="location",
        payload={
            "targetId": user_b,
            "latitude": 30.2741,
            "longitude": 120.1551,
            "address": "batch1-location",
            "buildingName": "batch1",
        },
    )


def test_chat_missing_voice_message_send_receive(device_a, device_b, assert_api, user_a, user_b):
    _send_type_and_receive(
        device_a, device_b, assert_api, user_a, user_b,
        type_key="voice",
        payload={"targetId": user_b, "duration": 1},
    )


def test_chat_missing_custom_message_send_receive(device_a, device_b, assert_api, user_a, user_b):
    _send_type_and_receive(
        device_a, device_b, assert_api, user_a, user_b,
        type_key="custom",
        payload={
            "targetId": user_b,
            "event": f"batch1-custom-{uuid.uuid4().hex[:8]}",
            "params": {"source": "batch1", "value": "真实日志"},
        },
    )


@pytest.mark.parametrize(
    ("type_key", "payload"),
    [
        ("txt", {"content": "batch1-delivery-text"}),
        ("custom", {"event": "batch1-delivery-custom", "params": {"k": "v"}}),
    ],
)
def test_chat_missing_message_delivery_ack(device_a, device_b, assert_api, user_a, user_b, type_key, payload):
    setting = device_a.call("Client", Cmd.updateDeliveryAckSetting.value, info={"requireDeliveryAck": True})
    assert_api.assert_response_matches(
        setting,
        expected={"manager": "Client", "cmd": Cmd.updateDeliveryAckSetting.value, "device": "deviceA", "result": None},
        ignore_keys={"sequence"},
    )
    setting_b = device_b.call("Client", Cmd.updateDeliveryAckSetting.value, info={"requireDeliveryAck": True})
    assert_api.assert_response_matches(
        setting_b,
        expected={"manager": "Client", "cmd": Cmd.updateDeliveryAckSetting.value, "device": "deviceB", "result": None},
        ignore_keys={"sequence"},
    )
    payload = {"targetId": user_b, **payload}
    _, _, _, _, real_id = _send_type_and_receive(
        device_a,
        device_b,
        assert_api,
        user_a,
        user_b,
        type_key=type_key,
        payload=payload,
    )
    delivery_evt = _wait_delivery_event(device_a, real_id=real_id)
    if type_key == "txt":
        delivery_body = {"type": 0, "content": payload["content"]}
        delivery_ignore = {"translations", "targetLanguages"}
    else:
        delivery_body = {"type": 7, "event": payload["event"], "params": payload["params"]}
        delivery_ignore = set()
    assert_api.assert_response_matches(
        delivery_evt,
        expected={
            "type": "event", "eventType": "{{deliveryEvent}}",
            "data": {"messages": [{
                "msgId": "{{realId}}", "from": "{{fromUser}}", "to": "{{toUser}}", "convId": "{{toUser}}",
                "chatType": 0, "direction": 0, "status": 2, "hasDeliverAck": True, "body": delivery_body,
                "hasRead": True, "hasReadAck": False, "needGroupAck": False, "isThread": False,
                "isContentReplaced": False, "deliverOnlineOnly": False,
            }]},
        },
        context={"realId": real_id, "deliveryEvent": delivery_evt.get("eventType"), "fromUser": user_a, "toUser": user_b},
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", *delivery_ignore},
    )
