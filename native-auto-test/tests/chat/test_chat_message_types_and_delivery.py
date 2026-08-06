from __future__ import annotations

from contextlib import nullcontext
import time
import uuid

import pytest

from src import Cmd
from tests.chat._utils import build_text

pytestmark = [pytest.mark.client, pytest.mark.chat]


def _allure_step(name: str):
    try:
        import allure

        return allure.step(name)
    except ImportError:
        return nullcontext()


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


def _wait_delivery_event(device, *, real_id: str, expected_message_count: int = 1, timeout: float = 30.0):
    """收集目标消息的送达记录；多端接收时同一 msgId 会有多条记录。"""
    seen = []
    deadline = time.monotonic() + timeout
    allowed = {Cmd.onMessagesDelivered.value, Cmd.onMessageDeliveryAck.value}
    delivered_messages = []
    ack_messages = []
    while time.monotonic() < deadline:
        evt = device.receive_message(timeout=min(2.0, max(0.1, deadline - time.monotonic())))
        if not evt:
            continue
        seen.append(evt)
        if evt.get("eventType") not in allowed:
            continue
        data = evt.get("data") or {}
        # 不同 SDK 回调的 JSON 形态不同：
        # onMessageDeliveryAck 直接把消息放在 data，
        # onMessagesDelivered 才放在 data.messages[]。
        if evt.get("eventType") == Cmd.onMessageDeliveryAck.value:
            messages = [data] if str(data.get("msgId")) == str(real_id) else []
            ack_messages.extend(
                m for m in messages
                if isinstance(m, dict) and str(m.get("msgId")) == str(real_id)
            )
        else:
            messages = data.get("messages") or []
            delivered_messages.extend(
                m for m in messages
                if isinstance(m, dict) and str(m.get("msgId")) == str(real_id)
            )
        # 两个事件由同一个原生回调派生，列表事件是规范批量结果，不能与
        # 单条 Ack 相加，否则会把同一条消息重复计数。
        if len(delivered_messages) >= expected_message_count:
            return {
                "type": evt.get("type"),
                "eventType": evt.get("eventType"),
                "data": {"messages": delivered_messages},
                "timestamp": evt.get("timestamp"),
            }
    # 某些平台/版本只暴露单条 Ack，列表事件缺失时才使用 Ack 兜底。
    if len(delivered_messages) < expected_message_count and len(ack_messages) >= expected_message_count:
        return {
            "type": "event",
            "eventType": Cmd.onMessageDeliveryAck.value,
            "data": {"messages": ack_messages},
        }
    pytest.fail(
        f"送达回执数量不足：realId={real_id}, "
        f"expected={expected_message_count}, matched={len(delivered_messages)}, "
        f"observedEvents={len(seen)}, seen={seen}"
    )


def _assert_sender_devices_received_message(
    topology,
    assert_api,
    *,
    real_id: str,
    body: dict,
    content: str | None = None,
    chat_type: int = 0,
    body_ignore_keys: set[str] | None = None,
) -> None:
    """验证发送账号的非动作设备同步消息并完成本地落库查询。"""
    sender = topology.sender_action_device
    ignored = {
        "timestamp", "sequence", "serverTime", "localTime",
        "broadcast", "onlineState", "receiverList", "groupAckCount",
        "deliverOnlineOnly", "hasDeliverAck", "targetLanguages", "translations",
        *(body_ignore_keys or set()),
    }
    for role, device in zip(topology.sender_roles, topology.sender_devices):
        if device is sender:
            continue
        with _allure_step(f"发送账号副端 {role} 收到消息同步（onMessagesReceived）"):
            event = _wait_event(
                device,
                Cmd.onMessagesReceived.value,
                predicate=lambda evt: any(
                    isinstance(item, dict)
                    and str(item.get("msgId")) == str(real_id)
                    and (content is None or (item.get("body") or {}).get("content") == content)
                    for item in ((evt.get("data") or {}).get("messages") or [])
                ),
            )
            message = next(
                item for item in ((event.get("data") or {}).get("messages") or [])
                if isinstance(item, dict) and str(item.get("msgId")) == str(real_id)
            )
            assert_api.assert_response_matches(
                {"type": event.get("type"), "eventType": event.get("eventType"), "data": {"messages": [message]}},
                expected={
                    "type": "event",
                    "eventType": Cmd.onMessagesReceived.value,
                    "data": {"messages": [{
                        "msgId": str(real_id),
                        "from": topology.sender_user,
                        "to": topology.recipient_user,
                        "convId": topology.recipient_user,
                        "chatType": chat_type,
                        "direction": 0,
                        "status": 2,
                        "hasRead": True,
                        "hasReadAck": False,
                        "needGroupAck": False,
                        "isThread": False,
                        "isContentReplaced": False,
                        "body": body,
                    }]},
                },
                ignore_keys=ignored,
            )
        with _allure_step(f"发送账号副端 {role} 可从本地消息库查询该消息"):
            lookup = device.call(
                "ChatManager",
                Cmd.getMessage.value,
                info={"msgId": str(real_id)},
            )
            assert_api.assert_response_matches(
                lookup,
                expected={
                    "manager": "ChatManager",
                    "cmd": Cmd.getMessage.value,
                    "device": device.device_name,
                    "result": {
                        "msgId": str(real_id),
                        "from": topology.sender_user,
                        "to": topology.recipient_user,
                        "convId": topology.recipient_user,
                        "chatType": chat_type,
                        "direction": 0,
                        "status": 2,
                        "hasRead": True,
                        "hasReadAck": False,
                        "needGroupAck": False,
                        "isThread": False,
                        "isContentReplaced": False,
                        "body": body,
                    },
                },
                ignore_keys=ignored,
            )


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


@pytest.mark.topology("account_a_to_account_b")
def test_chat_missing_location_message_send_receive(topology, assert_api):
    """A 发送位置消息，验证 A 副端同步以及 B 全部在线端接收相同消息。"""
    sender = topology.sender_action_device
    recipients = topology.recipient_devices
    sender_user = topology.sender_user
    recipient_user = topology.recipient_user
    body = {
        "type": 3,
        "latitude": 30.2741,
        "longitude": 120.1551,
        "address": "batch1-location",
        "buildingName": "batch1",
    }
    message = build_text(sender_user, recipient_user, "")
    message["body"] = body

    with _allure_step("清理发送账号和接收账号全部端的历史事件"):
        for device in (*topology.sender_devices, *recipients):
            device.drain_events(timeout=0.5)

    with _allure_step(f"{sender.device_name} 向接收账号发送位置消息"):
        response = sender.call("ChatManager", Cmd.sendMessage.value, info=message)
    temp_id = ((response.get("result") or {}).get("msgId"))
    assert temp_id, f"sendMessage 未返回临时 msgId: {response}"

    with _allure_step(f"等待 {sender.device_name} 的消息发送成功回调（onMessageSuccess）"):
        success_event = _wait_event(
            sender,
            Cmd.onMessageSuccess.value,
            predicate=lambda event: str((event.get("data") or {}).get("msgId")) == str(temp_id),
        )
    sent = ((success_event.get("data") or {}).get("msg")) or {}
    real_id = sent.get("msgId")
    assert real_id, f"onMessageSuccess 未返回真实 msgId: {success_event}"

    with _allure_step("确认位置消息已提交"):
        assert_api.assert_response_matches(
            response,
            expected={
                "manager": "ChatManager", "cmd": Cmd.sendMessage.value,
                "device": sender.device_name,
                "result": {
                    "msgId": temp_id, "from": sender_user, "to": recipient_user,
                    "convId": recipient_user, "chatType": 0, "direction": 0,
                    "status": 0, "hasRead": True, "hasReadAck": False,
                    "hasDeliverAck": False, "needGroupAck": False, "isThread": False,
                    "isContentReplaced": False, "body": body,
                },
            },
            ignore_keys={"sequence", "serverTime", "localTime", "broadcast", "onlineState", "deliverOnlineOnly"},
        )
    with _allure_step("确认位置消息发送成功"):
        assert_api.assert_response_matches(
            {"type": success_event.get("type"), "eventType": success_event.get("eventType"), "data": {"messages": [sent]}},
            expected={
                "type": "event", "eventType": Cmd.onMessageSuccess.value,
                "data": {"messages": [{
                    "msgId": str(real_id), "from": sender_user, "to": recipient_user,
                    "convId": recipient_user, "chatType": 0, "direction": 0, "status": 2,
                    "hasRead": True, "hasReadAck": False, "hasDeliverAck": False,
                    "needGroupAck": False, "isThread": False, "isContentReplaced": False,
                    "deliverOnlineOnly": False, "body": body,
                }]},
            },
            ignore_keys={
                "timestamp", "sequence", "serverTime", "localTime",
                "broadcast", "onlineState", "data.messages[0].hasDeliverAck",
            },
        )

    _assert_sender_devices_received_message(
        topology,
        assert_api,
        real_id=str(real_id),
        body=body,
    )

    for role, recipient in zip(topology.recipient_roles, recipients):
        with _allure_step(f"接收端 {role} 收到位置消息（onMessagesReceived）"):
            received_event = _wait_event(
                recipient,
                Cmd.onMessagesReceived.value,
                predicate=lambda event: any(
                    isinstance(item, dict) and str(item.get("msgId")) == str(real_id)
                    for item in ((event.get("data") or {}).get("messages") or [])
                ),
            )
            received = next(
                item for item in ((received_event.get("data") or {}).get("messages") or [])
                if isinstance(item, dict) and str(item.get("msgId")) == str(real_id)
            )
        with _allure_step(f"确认接收端 {role} 收到当前位置消息"):
            assert_api.assert_response_matches(
                {"type": received_event.get("type"), "eventType": received_event.get("eventType"), "data": {"messages": [received]}},
                expected={
                    "type": "event", "eventType": Cmd.onMessagesReceived.value,
                    "data": {"messages": [{
                        "msgId": str(real_id), "from": sender_user, "to": recipient_user,
                        "convId": sender_user, "chatType": 0, "direction": 1, "status": 2,
                        "hasRead": False, "hasReadAck": False, "hasDeliverAck": True,
                        "needGroupAck": False, "isThread": False, "isContentReplaced": False,
                        "deliverOnlineOnly": False, "body": body,
                    }]},
                },
                ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "broadcast", "onlineState"},
            )


def test_chat_missing_voice_message_send_receive(device_a, device_b, assert_api, user_a, user_b):
    _send_type_and_receive(
        device_a, device_b, assert_api, user_a, user_b,
        type_key="voice",
        payload={"targetId": user_b, "duration": 1},
    )


@pytest.mark.topology("account_a_to_account_b")
def test_chat_missing_custom_message_send_receive(topology, assert_api):
    """A 发送自定义消息，验证 A 副端同步以及 B 全部在线端接收相同消息。"""
    sender = topology.sender_action_device
    recipients = topology.recipient_devices
    sender_user = topology.sender_user
    recipient_user = topology.recipient_user
    event_name = f"batch1-custom-{uuid.uuid4().hex[:8]}"
    params = {"source": "batch1", "value": "真实日志"}
    message = build_text(sender_user, recipient_user, "")
    message["body"] = {"type": 7, "event": event_name, "params": params}

    with _allure_step("清理发送账号和接收账号全部端的历史事件"):
        for device in (*topology.sender_devices, *recipients):
            device.drain_events(timeout=0.5)

    with _allure_step(f"{sender.device_name} 向接收账号发送自定义消息"):
        response = sender.call(
            "ChatManager",
            Cmd.sendMessage.value,
            info=message,
        )
    temp_id = ((response.get("result") or {}).get("msgId"))
    assert temp_id, f"sendMessage 未返回临时 msgId: {response}"

    with _allure_step(f"等待 {sender.device_name} 的消息发送成功回调（onMessageSuccess）"):
        success_event = _wait_event(
            sender,
            Cmd.onMessageSuccess.value,
            predicate=lambda event: str((event.get("data") or {}).get("msgId")) == str(temp_id),
        )
    sent = ((success_event.get("data") or {}).get("msg")) or {}
    real_id = sent.get("msgId")
    assert real_id, f"onMessageSuccess 未返回真实 msgId: {success_event}"

    with _allure_step("确认自定义消息已提交"):
        assert_api.assert_response_matches(
            response,
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
                    "status": 0,
                    "hasRead": True,
                    "hasReadAck": False,
                    "hasDeliverAck": False,
                    "needGroupAck": False,
                    "isThread": False,
                    "isContentReplaced": False,
                    "body": {"type": 7, "event": event_name, "params": params},
                },
            },
            ignore_keys={
                "sequence", "serverTime", "localTime", "broadcast", "onlineState",
                "deliverOnlineOnly",
            },
        )
    with _allure_step("确认自定义消息发送成功"):
        assert_api.assert_response_matches(
            {"type": success_event.get("type"), "eventType": success_event.get("eventType"), "data": {"messages": [sent]}},
            expected={
                "type": "event",
                "eventType": Cmd.onMessageSuccess.value,
                "data": {"messages": [{
                    "msgId": str(real_id), "from": sender_user, "to": recipient_user,
                    "convId": recipient_user, "chatType": 0, "direction": 0, "status": 2,
                    "hasRead": True, "hasReadAck": False, "hasDeliverAck": False,
                    "needGroupAck": False, "isThread": False, "isContentReplaced": False,
                    "deliverOnlineOnly": False,
                    "body": {"type": 7, "event": event_name, "params": params},
                }]},
            },
            ignore_keys={
                "timestamp", "sequence", "serverTime", "localTime",
                "broadcast", "onlineState", "data.messages[0].hasDeliverAck",
            },
        )

    _assert_sender_devices_received_message(
        topology,
        assert_api,
        real_id=str(real_id),
        body={"type": 7, "event": event_name, "params": params},
    )

    for role, recipient in zip(topology.recipient_roles, recipients):
        with _allure_step(f"接收端 {role} 收到自定义消息（onMessagesReceived）"):
            received_event = _wait_event(
                recipient,
                Cmd.onMessagesReceived.value,
                predicate=lambda event: any(
                    isinstance(item, dict)
                    and str(item.get("msgId")) == str(real_id)
                    and (item.get("body") or {}).get("event") == event_name
                    for item in ((event.get("data") or {}).get("messages") or [])
                ),
            )
            received = next(
                item
                for item in ((received_event.get("data") or {}).get("messages") or [])
                if isinstance(item, dict)
                and str(item.get("msgId")) == str(real_id)
            )
        with _allure_step(f"确认接收端 {role} 收到当前自定义消息"):
            assert_api.assert_response_matches(
                {"type": received_event.get("type"), "eventType": received_event.get("eventType"), "data": {"messages": [received]}},
                expected={
                    "type": "event",
                    "eventType": Cmd.onMessagesReceived.value,
                    "data": {"messages": [{
                        "msgId": str(real_id), "from": sender_user, "to": recipient_user,
                        "convId": sender_user, "chatType": 0, "direction": 1, "status": 2,
                        "hasRead": False, "hasReadAck": False, "hasDeliverAck": True,
                        "needGroupAck": False, "isThread": False, "isContentReplaced": False,
                        "deliverOnlineOnly": False,
                        "body": {"type": 7, "event": event_name, "params": params},
                    }]},
                },
                ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "broadcast", "onlineState"},
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
