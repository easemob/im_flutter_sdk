from __future__ import annotations

from contextlib import nullcontext
import json
import time
import uuid
import pytest

from src import Cmd
from src.tools.assertions import get_result
from tests.chat._utils import build_text


def _allure_step(name: str):
    try:
        import allure

        return allure.step(name)
    except ImportError:
        return nullcontext()


def _attach_event_wait_diagnostics(
    *,
    event_type: str,
    expected: dict,
    timeout: float,
    seen: list,
) -> None:
    """Attaches concise, actionable evidence for an event-wait failure."""
    try:
        import allure

        observed_data_paths = sorted(
            {
                f"data.{key}"
                for event in seen
                if isinstance(event, dict)
                and isinstance(event.get("data"), dict)
                for key in event["data"]
            }
        )
        allure.attach(
            json.dumps(
                {
                    "eventType": event_type,
                    "timeoutSeconds": timeout,
                    "expected": expected,
                    "observedDataPaths": observed_data_paths,
                },
                ensure_ascii=False,
                indent=2,
            ),
            "事件等待条件",
            allure.attachment_type.JSON,
        )
        allure.attach(
            json.dumps(seen, ensure_ascii=False, indent=2, default=str),
            f"已观察事件（{event_type}）",
            allure.attachment_type.JSON,
        )
    except ImportError:
        pass


def _wait_message_event(
    device,
    event_type: str,
    *,
    real_id: str,
    content: str,
    expected_message_count: int = 1,
    timeout: float = 20.0,
) -> dict:
    device_name = getattr(device, "device_name", getattr(device, "_device", "unknown"))
    deadline = time.monotonic() + timeout
    seen = []
    matched_messages = []
    while time.monotonic() < deadline:
        evt = device.receive_message(
            match_event_type=event_type,
            timeout=min(2.0, max(0.1, deadline - time.monotonic())),
        )
        if evt:
            seen.append(evt)
        for msg in ((evt or {}).get("data") or {}).get("messages") or []:
            if not isinstance(msg, dict):
                continue
            body = msg.get("body") or {}
            if str(msg.get("msgId")) == str(real_id) and body.get("content") == content:
                matched_messages.append(msg)
        if len(matched_messages) >= expected_message_count:
            filtered_event = {
                "type": evt.get("type"),
                "eventType": evt.get("eventType"),
                "data": {"messages": matched_messages},
                "timestamp": evt.get("timestamp"),
            }
            source_device = getattr(evt, "_allure_source_device", None)
            if source_device:
                return evt.__class__(
                    filtered_event,
                    source_device=source_device,
                )
            return filtered_event
    _attach_event_wait_diagnostics(
        event_type=event_type,
        expected={
            "data.messages[].msgId": real_id,
            "data.messages[].body.content": content,
            "targetMessageCount": expected_message_count,
        },
        timeout=timeout,
        seen=seen,
    )
    pytest.fail(
        f"未命中目标消息事件: device={device_name}, eventType={event_type}, msgId={real_id}, "
        f"content={content!r}, observed={len(seen)}"
    )


def _configured_account_device_count(
    phase1_scenario,
    account_slot: str,
    active_roles: set[str] | None = None,
) -> int:
    """返回本次运行实际启用的该账号在线端数量；旧单设备场景自然返回 1。"""
    if phase1_scenario is None:
        return 1
    role_names = active_roles or set(phase1_scenario.roles)
    count = sum(
        1
        for role_name, role in phase1_scenario.roles.items()
        if role_name in role_names
        if role.account == account_slot
    )
    return count or 1


def _assert_text_message_event(assert_api, evt: dict, *, event_type: str, real_id: str, user_a: str, user_b: str, content: str, direction: int, conv_id: str, has_read: bool, has_read_ack: bool = False, has_deliver_ack: bool | None, expected_message_count: int = 1) -> None:
    message = {
        "msgId": real_id,
        "from": user_a,
        "to": user_b,
        "convId": conv_id,
        "chatType": 0,
        "direction": direction,
        "status": 2,
        "hasRead": has_read,
        "hasReadAck": has_read_ack,
        "needGroupAck": False,
        "isThread": False,
        "isContentReplaced": False,
        "deliverOnlineOnly": False,
        "body": {"type": 0, "content": content},
    }
    ignore_keys = {"timestamp", "sequence", "serverTime", "localTime", "broadcast", "onlineState", "translations"}
    if has_deliver_ack is None:
        ignore_keys.add("hasDeliverAck")
    else:
        message["hasDeliverAck"] = has_deliver_ack
    assert_api.assert_event_matches(
        evt,
        expected={
            "type": "event",
            "eventType": event_type,
            "data": {
                "messages": [
                    message
                    for _ in range(expected_message_count)
                ],
            },
        },
        ignore_keys=ignore_keys,
    )


def _assert_message_lookup(
    assert_api,
    response: dict,
    *,
    device_name: str,
    real_id: str,
    user_a: str,
    user_b: str,
    content: str,
    direction: int,
    conv_id: str,
    has_read: bool,
    has_read_ack: bool = False,
) -> None:
    assert_api.assert_response_matches(
        response,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.getMessage.value,
            "device": device_name,
            "result": {
                "msgId": str(real_id),
                "from": user_a,
                "to": user_b,
                "convId": conv_id,
                "chatType": 0,
                "direction": direction,
                "status": 2,
                "hasRead": has_read,
                "hasReadAck": has_read_ack,
                "needGroupAck": False,
                "isThread": False,
                "isContentReplaced": False,
                "body": {"type": 0, "content": content},
            },
        },
        ignore_keys={
            "sequence", "serverTime", "localTime", "broadcast", "onlineState",
            "deliverOnlineOnly", "targetLanguages", "translations", "hasDeliverAck",
            "groupAckCount", "receiverList",
        },
        allow_extra_fields=True,
    )


def _send_text_and_verify_topology_delivery(
    topology,
    assert_api,
    *,
    content: str,
    purpose: str,
) -> str:
    """发送一条文本，并验证收发账号的全部已声明在线端同步与落库。"""
    sender = topology.sender_action_device
    sender_devices = topology.sender_devices
    recipients = topology.recipient_devices
    sender_user = topology.sender_user
    recipient_user = topology.recipient_user

    with _allure_step("测试准备：清理收发账号全部端的历史事件"):
        for device in (*sender_devices, *recipients):
            device.drain_events(timeout=0.5)

    with _allure_step(f"{sender.device_name} 发送{purpose}文本消息"):
        sent = sender.call(
            "ChatManager",
            Cmd.sendMessage.value,
            info=build_text(sender_user, recipient_user, content),
        )
    temp_id = (sent.get("result") or {}).get("msgId")
    assert temp_id, f"sendMessage 未返回临时消息 ID: {sent}"
    with _allure_step("确认发送请求已提交"):
        assert_api.assert_response_matches(
            sent,
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.sendMessage.value,
                "device": sender.device_name,
                "result": {"msgId": str(temp_id)},
            },
        )

    with _allure_step(f"{sender.device_name} 验证消息发送成功（onMessageSuccess）"):
        success = sender.receive_message(
            match_event_type=Cmd.onMessageSuccess.value,
            timeout=20.0,
        )
        real_id = ((success.get("data") or {}).get("msg") or {}).get("msgId")
        assert real_id, f"onMessageSuccess 未返回真实消息 ID: {success}"
        assert_api.assert_event_matches(
            success,
            expected={
                "type": "event",
                "eventType": Cmd.onMessageSuccess.value,
                "data": {
                    "msgId": str(temp_id),
                    "msg": {
                        "msgId": str(real_id),
                        "from": sender_user,
                        "to": recipient_user,
                        "body": {"type": 0, "content": content},
                    },
                },
            },
        )

    for sender_device in sender_devices:
        if sender_device is sender:
            continue
        with _allure_step(
            f"发送账号端 {sender_device.device_name} 同步该消息并完成本地落库"
        ):
            synced = _wait_message_event(
                sender_device,
                Cmd.onMessagesReceived.value,
                real_id=str(real_id),
                content=content,
            )
            _assert_text_message_event(
                assert_api, synced, event_type=Cmd.onMessagesReceived.value,
                real_id=str(real_id), user_a=sender_user, user_b=recipient_user,
                content=content, direction=0, conv_id=recipient_user,
                has_read=True, has_deliver_ack=None,
            )
            _assert_message_lookup(
                assert_api,
                sender_device.call("ChatManager", Cmd.getMessage.value, info={"msgId": str(real_id)}),
                device_name=sender_device.device_name, real_id=str(real_id),
                user_a=sender_user, user_b=recipient_user, content=content,
                direction=0, conv_id=recipient_user, has_read=True,
            )

    for recipient in recipients:
        with _allure_step(
            f"接收账号端 {recipient.device_name} 接收该消息并完成本地落库"
        ):
            received = _wait_message_event(
                recipient,
                Cmd.onMessagesReceived.value,
                real_id=str(real_id),
                content=content,
            )
            _assert_text_message_event(
                assert_api, received, event_type=Cmd.onMessagesReceived.value,
                real_id=str(real_id), user_a=sender_user, user_b=recipient_user,
                content=content, direction=1, conv_id=sender_user,
                has_read=False, has_deliver_ack=None,
            )
            _assert_message_lookup(
                assert_api,
                recipient.call("ChatManager", Cmd.getMessage.value, info={"msgId": str(real_id)}),
                device_name=recipient.device_name, real_id=str(real_id),
                user_a=sender_user, user_b=recipient_user, content=content,
                direction=1, conv_id=sender_user, has_read=False,
            )

    with _allure_step(
        f"{sender.device_name} 验证 {len(recipients)} 个接收账号端的消息送达回执"
    ):
        delivered = _wait_message_event(
            sender,
            Cmd.onMessagesDelivered.value,
            real_id=str(real_id),
            content=content,
            expected_message_count=len(recipients),
        )
        _assert_text_message_event(
            assert_api, delivered, event_type=Cmd.onMessagesDelivered.value,
            real_id=str(real_id), user_a=sender_user, user_b=recipient_user,
            content=content, direction=0, conv_id=recipient_user,
            has_read=True, has_deliver_ack=True,
            expected_message_count=len(recipients),
        )
    return str(real_id)


def _wait_recall_info_event(device, *, real_id: str, content: str, timeout: float = 20.0) -> dict:
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        evt = device.receive_message(match_event_type=Cmd.onMessagesRecalledInfo.value, timeout=min(2.0, max(0.1, deadline - time.monotonic())))
        if evt:
            seen.append(evt)
        for info in ((evt or {}).get("data") or {}).get("infos") or []:
            if not isinstance(info, dict):
                continue
            msg = info.get("msg") or {}
            body = msg.get("body") or {}
            if str(info.get("recallMsgId")) == str(real_id) and body.get("content") == content:
                return {
                    "type": evt.get("type"),
                    "eventType": evt.get("eventType"),
                    "data": {"infos": [info]},
                    "timestamp": evt.get("timestamp"),
                }
    _attach_event_wait_diagnostics(
        event_type=Cmd.onMessagesRecalledInfo.value,
        expected={
            "data.infos[].recallMsgId": real_id,
            "data.infos[].msg.body.content": content,
        },
        timeout=timeout,
        seen=seen,
    )
    observed_paths = sorted(
        {
            f"data.{key}"
            for event in seen
            if isinstance(event, dict) and isinstance(event.get("data"), dict)
            for key in event["data"]
        }
    )
    pytest.fail(
        "未命中目标撤回信息："
        f"recallMsgId={real_id}, content={content!r}, observed={len(seen)}, "
        f"paths={observed_paths}；期望 data.infos[]。"
    )


# ======================== Create / Send ========================


@pytest.mark.topology("account_a_to_account_b")
def test_chat_send_and_received(topology, assert_api):
    """单聊消息在发送账号多端同步、接收账号全端接收并完成本地落库校验。"""
    action_sender = topology.sender_action_device
    sender_devices = topology.sender_devices
    recipients = topology.recipient_devices
    content = f"topology-delivery-{uuid.uuid4().hex[:8]}"

    with _allure_step("测试准备：清理发送账号和接收账号全部端的历史事件"):
        for device in (*sender_devices, *recipients):
            device.drain_events(timeout=0.5)

    with _allure_step(
        f"发送账号动作端 {action_sender.device_name} 向目标账号发送文本消息"
    ):
        resp_send = action_sender.call(
            "ChatManager",
            Cmd.sendMessage.value,
            info=build_text(
                topology.sender_user,
                topology.recipient_user,
                content,
            ),
        )

    temp_id = ((resp_send.get("result") or {}).get("msgId"))
    assert temp_id, f"sendMessage 未返回临时消息 ID: {resp_send}"
    with _allure_step("确认发送请求已提交"):
        assert_api.assert_response_matches(
            resp_send,
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.sendMessage.value,
                "device": action_sender.device_name,
                "result": {
                    "msgId": str(temp_id),
                    "from": topology.sender_user,
                    "to": topology.recipient_user,
                    "convId": topology.recipient_user,
                    "chatType": 0,
                    "direction": 0,
                    "status": 0,
                    "hasRead": True,
                    "hasReadAck": False,
                    "hasDeliverAck": False,
                    "needGroupAck": False,
                    "isThread": False,
                    "isContentReplaced": False,
                    "body": {"type": 0, "content": content},
                },
            },
            ignore_keys={"sequence", "serverTime", "localTime", "broadcast", "onlineState", "deliverOnlineOnly", "targetLanguages", "translations"},
        )

    with _allure_step("发送端验证 onMessageSuccess 并提取服务端消息 ID"):
        evt_success = action_sender.receive_message(
            match_event_type=Cmd.onMessageSuccess.value,
            timeout=20.0,
        )
        callback_temp_id = (evt_success.get("data") or {}).get("msgId")
        real_id = ((evt_success.get("data") or {}).get("msg") or {}).get("msgId")
        assert callback_temp_id and real_id, f"onMessageSuccess 缺少消息 ID: {evt_success}"
        assert str(callback_temp_id) == str(temp_id), (
            f"sendMessage 与 onMessageSuccess 的临时消息 ID 不一致: "
            f"response={temp_id}, callback={callback_temp_id}"
        )
        context = {
            "tempId": callback_temp_id,
            "realId": real_id,
            "fromUser": topology.sender_user,
            "toUser": topology.recipient_user,
            "content": content,
        }
        assert_api.assert_event_matches(
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
                        "body": {"type": 0, "content": "{{content}}", "translations": {}},
                        "direction": 0,
                        "chatType": 0,
                        "status": 2,
                        "hasRead": True,
                        "hasReadAck": False,
                        "needGroupAck": False,
                        "deliverOnlineOnly": False,
                        "isThread": False,
                        "isContentReplaced": False,
                    },
                },
            },
            context=context,
            ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "data.msg.hasDeliverAck"},
        )

    for _, sender_device in zip(topology.sender_roles, sender_devices):
        if sender_device is action_sender:
            continue
        with _allure_step(f"发送账号副端 {sender_device.device_name} 收到本账号消息同步（onMessagesReceived）"):
            evt_synced = _wait_message_event(
                sender_device,
                Cmd.onMessagesReceived.value,
                real_id=real_id,
                content=content,
            )
            _assert_text_message_event(
                assert_api,
                evt_synced,
                event_type=Cmd.onMessagesReceived.value,
                real_id=real_id,
                user_a=topology.sender_user,
                user_b=topology.recipient_user,
                content=content,
                direction=0,
                conv_id=topology.recipient_user,
                has_read=True,
                has_deliver_ack=None,
            )
        with _allure_step(f"发送账号副端 {sender_device.device_name} 可从本地消息库查询该消息"):
            _assert_message_lookup(
                assert_api,
                sender_device.call("ChatManager", Cmd.getMessage.value, info={"msgId": str(real_id)}),
                device_name=sender_device.device_name,
                real_id=real_id,
                user_a=topology.sender_user,
                user_b=topology.recipient_user,
                content=content,
                direction=0,
                conv_id=topology.recipient_user,
                has_read=True,
            )

    received_roles = []
    for role, recipient in zip(topology.recipient_roles, recipients):
        with _allure_step(f"接收端 {recipient.device_name} 验证 onMessagesReceived: msgId={real_id}"):
            evt_received = _wait_message_event(
                recipient,
                Cmd.onMessagesReceived.value,
                real_id=real_id,
                content=content,
            )
            _assert_text_message_event(
                assert_api,
                evt_received,
                event_type=Cmd.onMessagesReceived.value,
                real_id=real_id,
                user_a=topology.sender_user,
                user_b=topology.recipient_user,
                content=content,
                direction=1,
                conv_id=topology.sender_user,
                has_read=False,
                has_deliver_ack=None,
            )
            received_roles.append(role)
        with _allure_step(f"接收端 {recipient.device_name} 可从本地消息库查询该消息"):
            _assert_message_lookup(
                assert_api,
                recipient.call("ChatManager", Cmd.getMessage.value, info={"msgId": str(real_id)}),
                device_name=recipient.device_name,
                real_id=real_id,
                user_a=topology.sender_user,
                user_b=topology.recipient_user,
                content=content,
                direction=1,
                conv_id=topology.sender_user,
                has_read=False,
            )

    with _allure_step("汇总：目标账号的全部在线端均收到同一服务端消息"):
        assert received_roles == list(topology.recipient_roles)

    with _allure_step(f"发送端验证 {len(recipients)} 个接收端的送达回执: msgId={real_id}"):
        evt_delivered = _wait_message_event(
            action_sender,
            Cmd.onMessagesDelivered.value,
            real_id=real_id,
            content=content,
            expected_message_count=len(recipients),
        )
        _assert_text_message_event(
            assert_api,
            evt_delivered,
            event_type=Cmd.onMessagesDelivered.value,
            real_id=real_id,
            user_a=topology.sender_user,
            user_b=topology.recipient_user,
            content=content,
            direction=0,
            conv_id=topology.recipient_user,
            has_read=True,
            has_deliver_ack=True,
            expected_message_count=len(recipients),
        )


def test_chat_send_to_self_event(device_a, assert_api, user_a):
    try:
        device_a.drain_events()
    except Exception:
        pass
    content = f"self-msg-{uuid.uuid4().hex[:6]}"
    resp_send = device_a.call("ChatManager", Cmd.sendMessage.value, info=build_text(user_a, user_a, content))
    evt = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
    temp_id = (evt.get("data") or {}).get("msgId")
    real_id = ((evt.get("data") or {}).get("msg") or {}).get("msgId")
    assert_api.assert_event_matches(
        evt,
        expected={
            "type": "event",
            "eventType": Cmd.onMessageSuccess.value,
            "data": {
                "msgId": "{{tempId}}",
                "msg": {
                    "msgId": "{{realId}}",
                    "from": "{{user}}",
                    "to": "{{user}}",
                    "convId": "{{user}}",
                    "body": {"type": 0, "content": "{{content}}", "translations": {}},
                    "direction": 0,
                    "chatType": 0,
                    "status": 2,
                    "hasRead": True,
                    "hasReadAck": False,
                    "hasDeliverAck": False,
                    "needGroupAck": False,
                    "deliverOnlineOnly": False,
                    "isThread": False,
                    "isContentReplaced": False,
                },
            },
        },
        context={"tempId": temp_id, "realId": real_id, "user": user_a, "content": content},
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "broadcast", "onlineState", "targetLanguages", "deliverOnlineOnly"},
    )
    assert_api.assert_response_matches(
        resp_send,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.sendMessage.value,
            "device": "deviceA",
            "result": {
                "msgId": "{{tempId}}",
                "from": "{{user}}",
                "to": "{{user}}",
                "convId": "{{user}}",
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
        context={"tempId": temp_id, "user": user_a, "content": content},
        ignore_keys={"sequence", "serverTime", "localTime", "broadcast", "onlineState", "deliverOnlineOnly", "targetLanguages", "translations"},
    )


# ======================== Read ========================


def test_chat_get_message_invalid_id_returns_empty(device_a, assert_api):
    # 新路径直连 Wrapper：无效 msgId 找不到消息时，Wrapper.onSuccess(null)
    # 返回空 Map {}（Dart 业务层此前将其归一化为 null）。
    resp = device_a.call("ChatManager", Cmd.getMessage.value, info={"msgId": "__invalid_msg_id__"})
    assert_api.assert_response_matches(
        resp,
        expected={"manager": "ChatManager", "cmd": Cmd.getMessage.value, "device": "deviceA", "result": {}},
        ignore_keys={"sequence"},
    )


def test_chat_fetch_support_languages_success(device_a, assert_api):
    resp = device_a.call("ChatManager", Cmd.fetchSupportLanguages.value, info={})
    languages = resp.get("result")
    assert isinstance(languages, list) and languages, resp
    assert all(
        isinstance(item, dict)
        and set(item) == {"nativeName", "code", "name"}
        and all(isinstance(item[key], str) and item[key] for key in ("nativeName", "code", "name"))
        for item in languages
    ), resp
    codes = [item["code"] for item in languages]
    assert len(codes) == len(set(codes)), resp
    by_code = {item["code"]: item for item in languages}
    assert by_code["zh-Hans"] == {
        "nativeName": "中文 (简体)",
        "code": "zh-Hans",
        "name": "Chinese Simplified",
    }
    assert by_code["en"] == {"nativeName": "English", "code": "en", "name": "English"}
    assert_api.assert_response_matches(
        {key: value for key, value in resp.items() if key != "result"},
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.fetchSupportLanguages.value,
            "device": "deviceA",
        },
        ignore_keys={"sequence"},
    )


def test_chat_fetch_history_invalid_conversation(device_b, assert_api):
    resp = device_b.call(
        "ChatManager",
        Cmd.fetchHistoryMessages.value,
        info={"convId": "__invalid__", "type": 0, "pageSize": 20, "startMsgId": "", "direction": 0},
    )
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.fetchHistoryMessages.value,
            "device": "deviceB",
            "result": {
                "cursor": "",
                "list": [],
            },
        },
        ignore_keys={"sequence"},
    )


def test_chat_fetch_history_by_options_invalid_conversation(device_a, assert_api):
    resp = device_a.call(
        "ChatManager",
        Cmd.fetchHistoryMessagesByOptions.value,
        info={"convId": "__invalid__", "type": 0, "pageSize": 20, "cursor": ""},
    )
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.fetchHistoryMessagesByOptions.value,
            "device": "deviceA",
            "result": {
                "cursor": "",
                "list": [],
            },
        },
        ignore_keys={"sequence"},
    )


@pytest.mark.skip(reason="MissingPlugin: searchChatMsgFromDB 未在当前集成端实现")
def test_chat_search_chat_msg_from_db_success(device_a, device_b, assert_api, user_a, user_b):
    keyword = f"kw-{uuid.uuid4().hex[:6]}"
    _ = device_a.call("ChatManager", Cmd.sendMessage.value, info=build_text(user_a, user_b, keyword))
    _ = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
    resp = device_a.call("ChatManager", Cmd.searchChatMsgFromDB.value, info={"keywords": keyword})
    assert_api.assert_response_matches(
        resp,
        expected={"manager": "ChatManager", "cmd": Cmd.searchChatMsgFromDB.value, "device": "deviceA"},
        ignore_keys={"sequence"},
    )


# ======================== Update ========================


@pytest.mark.topology("account_a_to_account_b")
def test_chat_translate_message_basic(topology, assert_api):
    """文本消息在收发账号多端同步后，由发送动作端请求翻译并校验返回消息。"""
    content = f"translate-basic-{uuid.uuid4().hex[:8]}"
    real_id = _send_text_and_verify_topology_delivery(
        topology, assert_api, content=content, purpose="待翻译的",
    )
    sender = topology.sender_action_device
    with _allure_step(f"{sender.device_name} 查询待翻译消息"):
        resp_get = sender.call("ChatManager", Cmd.getMessage.value, info={"msgId": real_id})
    msg_obj = get_result(resp_get)
    with _allure_step(f"{sender.device_name} 请求将消息翻译为简体中文"):
        resp_tr = sender.call(
            "ChatManager", Cmd.translateMessage.value,
            info={"message": msg_obj, "targetLanguages": ["zh-Hans"]},
        )
    with _allure_step("确认翻译接口返回当前文本消息"):
        assert_api.assert_response_matches(
            resp_tr,
            expected={
                "manager": "ChatManager", "cmd": Cmd.translateMessage.value,
                "device": sender.device_name,
                "result": {
                    "msgId": str(real_id), "from": topology.sender_user,
                    "to": topology.recipient_user, "convId": topology.recipient_user,
                    "body": {"type": 0, "content": content},
                },
            },
        )


def test_chat_pin_conversation_nonexistent_conversation(device_a, assert_api):
    resp_pin = device_a.call("ChatManager", Cmd.pinConversation.value, info={"conversationId": "__nonexistent_chat_user__", "isPinned": True})
    assert_api.assert_error(resp_pin, code=107, description="Invalid conversation")


def test_chat_modify_message_invalid_id_response(device_a, assert_api):
    resp = device_a.call("ChatManager", Cmd.modifyMessage.value, info={"msgId": "__invalid_msg_id__", "body": {"type": 0, "content": "edit"}})
    assert_api.assert_response_matches(
        resp,
        expected={"manager": "ChatManager", "cmd": Cmd.modifyMessage.value, "device": "deviceA", "result": {"code": 500, "description": "Message is invalid"}},
        ignore_keys={"sequence"},
    )


@pytest.mark.topology("account_a_to_account_b")
def test_chat_translate_message_recalled_message(topology, assert_api):
    """
    场景：发送账号向接收账号发送文本消息后撤回。

    验证：发送账号副端同步原始消息；接收账号的每个在线端均收到原始消息和
    ``onMessagesRecalledInfo`` 撤回信息。该事件是 Android/iOS 通用的撤回契约。
    """
    action_sender = topology.sender_action_device
    sender_devices = topology.sender_devices
    recipients = topology.recipient_devices
    sender_user = topology.sender_user
    recipient_user = topology.recipient_user
    content = f"recalled-translate-{uuid.uuid4().hex[:8]}"

    with _allure_step(f"动作发送端 {action_sender.device_name} 发送待撤回的文本消息"):
        action_sender.call(
            "ChatManager",
            Cmd.sendMessage.value,
            info=build_text(sender_user, recipient_user, content),
        )

    with _allure_step("发送端等待 onMessageSuccess 并提取消息 ID"):
        evt_success = action_sender.receive_message(
            match_event_type=Cmd.onMessageSuccess.value,
            timeout=20.0,
        )
        real_id = (((evt_success or {}).get("data") or {}).get("msg") or {}).get("msgId")
        assert real_id, f"onMessageSuccess 缺少 msgId: {evt_success}"

    for role, device in zip(topology.sender_roles, sender_devices):
        if device is action_sender:
            continue
        with _allure_step(f"发送账号副端 {role} 收到本账号消息同步（onMessagesReceived）"):
            evt_synced = _wait_message_event(
                device,
                Cmd.onMessagesReceived.value,
                real_id=real_id,
                content=content,
            )
            _assert_text_message_event(
                assert_api,
                evt_synced,
                event_type=Cmd.onMessagesReceived.value,
                real_id=real_id,
                user_a=sender_user,
                user_b=recipient_user,
                content=content,
                direction=0,
                conv_id=recipient_user,
                has_read=True,
                has_deliver_ack=None,
            )
        with _allure_step(f"发送账号副端 {role} 可从本地消息库查询该消息"):
            _assert_message_lookup(
                assert_api,
                device.call(
                    "ChatManager",
                    Cmd.getMessage.value,
                    info={"msgId": str(real_id)},
                ),
                device_name=device.device_name,
                real_id=real_id,
                user_a=sender_user,
                user_b=recipient_user,
                content=content,
                direction=0,
                conv_id=recipient_user,
                has_read=True,
            )

    for role, device in zip(topology.recipient_roles, recipients):
        with _allure_step(f"接收端 {role} 验证原始文本消息 msgId={real_id}"):
            evt_received = _wait_message_event(
                device,
                Cmd.onMessagesReceived.value,
                real_id=real_id,
                content=content,
            )
            _assert_text_message_event(
                assert_api,
                evt_received,
                event_type=Cmd.onMessagesReceived.value,
                real_id=real_id,
                user_a=sender_user,
                user_b=recipient_user,
                content=content,
                direction=1,
                conv_id=sender_user,
                has_read=False,
                has_deliver_ack=None,
            )

    with _allure_step(f"发送端验证 {len(recipients)} 个接收端的送达回执: msgId={real_id}"):
        evt_delivered = _wait_message_event(
            action_sender,
            Cmd.onMessagesDelivered.value,
            real_id=real_id,
            content=content,
            expected_message_count=len(recipients),
        )
        _assert_text_message_event(
            assert_api,
            evt_delivered,
            event_type=Cmd.onMessagesDelivered.value,
            real_id=real_id,
            user_a=sender_user,
            user_b=recipient_user,
            content=content,
            direction=0,
            conv_id=recipient_user,
            has_read=True,
            has_deliver_ack=True,
            expected_message_count=len(recipients),
        )

    with _allure_step(f"动作发送端撤回消息 msgId={real_id}"):
        time.sleep(2)
        resp_recall = action_sender.call(
            "ChatManager",
            Cmd.recallMessage.value,
            info={"msgId": real_id},
        )
        assert_api.assert_response_matches(
            resp_recall,
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.recallMessage.value,
                "device": action_sender.device_name,
                "result": True,
            },
            ignore_keys={"sequence"},
        )

    for role, device in zip(topology.sender_roles, sender_devices):
        if device is action_sender:
            continue
        with _allure_step(f"发送账号副端 {role} 验证撤回信息 onMessagesRecalledInfo msgId={real_id}"):
            evt_recall_info = _wait_recall_info_event(
                device,
                real_id=real_id,
                content=content,
            )
            infos = ((evt_recall_info.get("data") or {}).get("infos") or [])
            info = next(
                (
                    item for item in infos
                    if isinstance(item, dict)
                    and str(item.get("recallMsgId")) == str(real_id)
                ),
                None,
            )
            assert info is not None, (
                f"发送账号副端 {role} 的 onMessagesRecalledInfo 缺少目标消息: "
                f"msgId={real_id}, event={evt_recall_info}"
            )
            assert info.get("recallBy") == sender_user, (
                f"发送账号副端 {role} 的撤回人不正确: "
                f"expected={sender_user!r}, actual={info.get('recallBy')!r}"
            )
            recalled_msg = info.get("msg") or {}
            assert str(recalled_msg.get("msgId")) == str(real_id), (
                f"发送账号副端 {role} 的撤回信息 msgId 不一致: "
                f"expected={real_id!r}, actual={recalled_msg.get('msgId')!r}"
            )
            assert (recalled_msg.get("body") or {}).get("content") == content, (
                f"发送账号副端 {role} 的撤回信息内容不一致: "
                f"expected={content!r}, actual={(recalled_msg.get('body') or {}).get('content')!r}"
            )

    for role, device in zip(topology.recipient_roles, recipients):
        with _allure_step(f"接收端 {role} 验证撤回信息 onMessagesRecalledInfo msgId={real_id}"):
            evt_recall_info = _wait_recall_info_event(
                device,
                real_id=real_id,
                content=content,
            )
            assert_api.assert_event_matches(
                evt_recall_info,
                expected={
                    "type": "event",
                    "eventType": Cmd.onMessagesRecalledInfo.value,
                    "data": {
                        "infos": [
                            {
                                "recallMsgId": real_id,
                                "recallBy": sender_user,
                                "convId": sender_user,
                                "ext": "",
                                "msg": {
                                    "msgId": real_id,
                                    "from": sender_user,
                                    "to": recipient_user,
                                    "convId": sender_user,
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
                                        "type": 0,
                                        "content": content,
                                    },
                                },
                            }
                        ]
                    },
                },
                ignore_keys={
                    "timestamp", "sequence", "serverTime", "localTime",
                    "broadcast", "onlineState", "targetLanguages",
                    "deliverOnlineOnly",
                },
            )


@pytest.mark.topology("account_a_to_account_b")
def test_chat_ack_message_read_success(topology, assert_api):
    """A 发送文本，B 的全部在线端接收并发送已读回执；验证 A 主副端已读回调和本地状态同步。"""
    sender = topology.sender_action_device
    recipient_action = topology.recipient_action_device
    recipients = topology.recipient_devices
    sender_user = topology.sender_user
    recipient_user = topology.recipient_user

    with _allure_step("清理发送账号和接收账号全部端的历史事件"):
        for device in (*topology.sender_devices, *recipients):
            device.drain_events(timeout=0.5)

    content = f"ackread-{uuid.uuid4().hex[:6]}"
    with _allure_step(f"{sender.device_name} 向接收账号发送待已读文本消息"):
        resp_send = sender.call(
            "ChatManager",
            Cmd.sendMessage.value,
            info=build_text(sender_user, recipient_user, content),
        )
    with _allure_step(f"等待 {sender.device_name} 的消息发送成功回调（onMessageSuccess）"):
        evt_success = sender.receive_message(
            match_event_type=Cmd.onMessageSuccess.value,
            timeout=20.0,
        )
    temp_id = (evt_success.get("data") or {}).get("msgId")
    sent_real_id = (((evt_success or {}).get("data") or {}).get("msg") or {}).get("msgId")
    assert sent_real_id, f"missing real msgId from onMessageSuccess: {evt_success!r}"
    with _allure_step("确认待已读消息已提交"):
        assert_api.assert_response_matches(
            resp_send,
            expected={"manager": "ChatManager", "cmd": Cmd.sendMessage.value, "device": sender.device_name, "result": {"msgId": temp_id, "from": sender_user, "to": recipient_user, "convId": recipient_user, "chatType": 0, "direction": 0, "status": 0, "hasRead": True, "hasReadAck": False, "hasDeliverAck": False, "needGroupAck": False, "isThread": False, "isContentReplaced": False, "body": {"type": 0, "content": content}}},
            ignore_keys={"sequence", "serverTime", "localTime", "broadcast", "onlineState", "deliverOnlineOnly", "targetLanguages", "translations"},
        )

    for role, sender_device in zip(topology.sender_roles, topology.sender_devices):
        if sender_device is sender:
            continue
        with _allure_step(f"发送账号副端 {role} 收到待已读消息同步（onMessagesReceived）"):
            synced = _wait_message_event(
                sender_device,
                Cmd.onMessagesReceived.value,
                real_id=str(sent_real_id),
                content=content,
            )
            _assert_text_message_event(
                assert_api,
                synced,
                event_type=Cmd.onMessagesReceived.value,
                real_id=str(sent_real_id),
                user_a=sender_user,
                user_b=recipient_user,
                content=content,
                direction=0,
                conv_id=recipient_user,
                has_read=True,
                has_deliver_ack=None,
            )
        with _allure_step(f"发送账号副端 {role} 可从本地消息库查询待已读消息"):
            _assert_message_lookup(
                assert_api,
                sender_device.call(
                    "ChatManager",
                    Cmd.getMessage.value,
                    info={"msgId": str(sent_real_id)},
                ),
                device_name=sender_device.device_name,
                real_id=str(sent_real_id),
                user_a=sender_user,
                user_b=recipient_user,
                content=content,
                direction=0,
                conv_id=recipient_user,
                has_read=True,
            )

    for recipient in recipients:
        with _allure_step(f"接收端 {recipient.device_name} 收到待已读消息（onMessagesReceived）"):
            evt_received = _wait_message_event(
                recipient,
                Cmd.onMessagesReceived.value,
                real_id=str(sent_real_id),
                content=content,
            )
        with _allure_step(f"确认接收端 {recipient.device_name} 收到当前消息"):
            _assert_text_message_event(
                assert_api,
                evt_received,
                event_type=Cmd.onMessagesReceived.value,
                real_id=str(sent_real_id),
                user_a=sender_user,
                user_b=recipient_user,
                content=content,
                direction=1,
                conv_id=sender_user,
                has_read=False,
                has_deliver_ack=None,
            )

    with _allure_step(f"等待 {sender.device_name} 的 {len(recipients)} 条送达回执（onMessagesDelivered）"):
        evt_delivered = _wait_message_event(
            sender,
            Cmd.onMessagesDelivered.value,
            real_id=str(sent_real_id),
            content=content,
            expected_message_count=len(recipients),
        )
    with _allure_step(f"确认同一消息已由接收账号的 {len(recipients)} 个在线端送达"):
        _assert_text_message_event(
            assert_api,
            evt_delivered,
            event_type=Cmd.onMessagesDelivered.value,
            real_id=str(sent_real_id),
            user_a=sender_user,
            user_b=recipient_user,
            content=content,
            direction=0,
            conv_id=recipient_user,
            has_read=True,
            has_deliver_ack=True,
            expected_message_count=len(recipients),
        )

    with _allure_step(f"接收端动作设备 {recipient_action.device_name} 标记消息已读"):
        resp_ack = recipient_action.call(
            "ChatManager",
            Cmd.ackMessageRead.value,
            info={"msgId": str(sent_real_id), "to": sender_user},
        )
    with _allure_step("确认已读回执提交成功"):
        assert_api.assert_response_matches(
            resp_ack,
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.ackMessageRead.value,
                "device": recipient_action.device_name,
                "result": True,
            },
            ignore_keys={"sequence"},
        )

    with _allure_step(f"{sender.device_name} 收到已读回调（onMessagesRead）"):
        evt_read = _wait_message_event(
            sender,
            Cmd.onMessagesRead.value,
            real_id=str(sent_real_id),
            content=content,
        )
    with _allure_step("确认已读回调对应当前消息"):
        assert_api.assert_event_matches(
            evt_read,
        expected={
            "type": "event",
            "eventType": Cmd.onMessagesRead.value,
            "data": {
                "messages": [
                    {
                        "msgId": "{{msgId}}",
                        "from": "{{fromUser}}",
                        "to": "{{toUser}}",
                        "convId": "{{toUser}}",
                        "chatType": 0,
                        "direction": 0,
                        "status": 2,
                        "hasRead": True,
                        "hasReadAck": True,
                        "hasDeliverAck": True,
                        "needGroupAck": False,
                        "isThread": False,
                        "isContentReplaced": False,
                        "deliverOnlineOnly": False,
                        "body": {"type": 0, "content": "{{content}}", "translations": {}},
                    }
                ],
            },
        },
            context={"msgId": str(sent_real_id), "fromUser": sender_user, "toUser": recipient_user, "content": content},
            ignore_keys={"timestamp", "sequence", "serverTime", "localTime"},
        )

    for role, sender_device in zip(topology.sender_roles, topology.sender_devices):
        if sender_device is sender:
            continue
        with _allure_step(f"发送账号副端 {role} 收到已读回调（onMessagesRead）"):
            sender_read_event = _wait_message_event(
                sender_device,
                Cmd.onMessagesRead.value,
                real_id=str(sent_real_id),
                content=content,
            )
            _assert_text_message_event(
                assert_api,
                sender_read_event,
                event_type=Cmd.onMessagesRead.value,
                real_id=str(sent_real_id),
                user_a=sender_user,
                user_b=recipient_user,
                content=content,
                direction=0,
                conv_id=recipient_user,
                has_read=True,
                has_read_ack=True,
                has_deliver_ack=None,
            )
        with _allure_step(f"发送账号副端 {role} 本地消息已同步为已读"):
            _assert_message_lookup(
                assert_api,
                sender_device.call(
                    "ChatManager",
                    Cmd.getMessage.value,
                    info={"msgId": str(sent_real_id)},
                ),
                device_name=sender_device.device_name,
                real_id=str(sent_real_id),
                user_a=sender_user,
                user_b=recipient_user,
                content=content,
                direction=0,
                conv_id=recipient_user,
                has_read=True,
                has_read_ack=True,
            )


# ======================== Delete ========================


def test_chat_recall_message_invalid_id_response(device_a, assert_api):
    resp = device_a.call("ChatManager", Cmd.recallMessage.value, info={"msgId": "__invalid_msg_id__"})
    assert_api.assert_response_matches(
        resp,
        expected={"manager": "ChatManager", "cmd": Cmd.recallMessage.value, "device": "deviceA", "result": {"code": 500, "description": "The message was not found"}},
        ignore_keys={"sequence"},
    )


def test_chat_remove_reaction_invalid_id_response(device_a, assert_api):
    # 新路径直连 Wrapper：无效 msgId 操作失败时返回空 Map {}
    # （Dart 业务层此前将其归一化为 null）。
    resp = device_a.call("ChatManager", Cmd.removeReaction.value, info={"reaction": "👍", "msgId": "__invalid_msg_id__"})
    assert_api.assert_response_matches(
        resp,
        expected={"manager": "ChatManager", "cmd": Cmd.removeReaction.value, "device": "deviceA", "result": {}},
        ignore_keys={"sequence"},
    )


# ======================== Errors / Edge ========================


def test_chat_ack_conversation_read_invalid_id_response(device_b, assert_api, sdk_is_v5):
    resp = device_b.call("ChatManager", Cmd.ackConversationRead.value, info={"convId": "__invalid_conversation_id__"})
    # 5.x 错误码 110/"conversation not found"（4.x 为 500/"Message is invalid"）
    if sdk_is_v5:
        expected_result = {"code": 110, "description": "conversation not found"}
    else:
        expected_result = {"code": 500, "description": "Message is invalid"}
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.ackConversationRead.value,
            "device": "deviceB",
            "result": expected_result,
        },
        ignore_keys={"sequence"},
    )


def test_chat_add_reaction_invalid_id_response(device_a, assert_api):
    resp = device_a.call("ChatManager", Cmd.addReaction.value, info={"reaction": "👍", "msgId": "__invalid_msg_id__"})
    assert_api.assert_response_matches(
        resp,
        expected={"manager": "ChatManager", "cmd": Cmd.addReaction.value, "device": "deviceA", "result": {"code": 303, "description": "msgbody is not_found"}},
        ignore_keys={"sequence"},
    )


@pytest.mark.topology("account_a_to_account_b")
def test_chat_add_reaction_empty_reaction_response(topology, assert_api):
    """消息多端同步后，验证发送动作端提交空 reaction 返回明确业务错误。"""
    content = f"for-reaction-empty-{uuid.uuid4().hex[:8]}"
    real_id = _send_text_and_verify_topology_delivery(
        topology, assert_api, content=content, purpose="待添加 reaction 的",
    )
    sender = topology.sender_action_device
    with _allure_step(f"{sender.device_name} 为消息提交空 reaction"):
        resp = sender.call(
            "ChatManager", Cmd.addReaction.value,
            info={"reaction": "", "msgId": real_id},
        )
    with _allure_step("确认空 reaction 被拒绝且错误码正确"):
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "ChatManager", "cmd": Cmd.addReaction.value,
                "device": sender.device_name,
                "result": {"code": 110, "description": "'reaction' can not be null"},
            },
        )


# ======================== Attachments (invalid) ========================


@pytest.mark.skip(reason="message 对象入参 API 暂缓；避免 MissingPlugin 非被测端语义")
def test_chat_download_attachment_invalid_id_response(device_a, assert_api):
    resp = device_a.call("ChatManager", Cmd.downloadAttachment.value, info={"msgId": "__invalid_msg_id__"})
    assert_api.assert_error(resp, code=500, description="Message is invalid")


@pytest.mark.skip(reason="message 对象入参 API 暂缓；避免 MissingPlugin 非被测端语义")
def test_chat_download_thumbnail_invalid_id_response(device_a, assert_api):
    resp = device_a.call("ChatManager", Cmd.downloadThumbnail.value, info={"msgId": "__invalid_msg_id__"})
    assert_api.assert_error(resp, code=500, description="Message is invalid")
