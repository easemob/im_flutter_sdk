from __future__ import annotations

import os
import time
import uuid
from contextlib import nullcontext

import pytest

from src import Cmd
from tests.chat._utils import build_text
from tests.chat.test_chat_recall_and_message_read_ack import _send_typed

pytestmark = [pytest.mark.client, pytest.mark.chat]


def _allure_step(name: str):
    try:
        import allure

        return allure.step(name)
    except ImportError:
        return nullcontext()


def _assert_text_event(assert_api, evt, *, event_type, msg_id, user_a, user_b, content, direction, conv_id, has_read, has_deliver_ack):
    assert_api.assert_response_matches(
        evt,
        expected={
            "type": "event",
            "eventType": event_type,
            "data": {
                "messages": [
                    {
                        "msgId": str(msg_id),
                        "from": user_a,
                        "to": user_b,
                        "convId": conv_id,
                        "chatType": 0,
                        "direction": direction,
                        "status": 2,
                        "hasRead": has_read,
                        "needReadReceipt": False, 
                        "isThread": False,
                        "isContentReplaced": False,
                        "deliverOnlineOnly": False,
                        "body": {"type": 0, "content": content, "translations": {}},
                    }
                ],
            },
        },
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "receiverList", "broadcast", "onlineState"},
    )


def _wait_text_event(device, event_type, *, msg_id, content, timeout=30):
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        evt = device.receive_message(match_event_type=event_type, timeout=min(2.0, max(0.1, deadline - time.monotonic())))
        if evt:
            seen.append(evt)
        for msg in ((evt or {}).get("data") or {}).get("messages") or []:
            if not isinstance(msg, dict):
                continue
            if str(msg.get("msgId")) == str(msg_id) and ((msg.get("body") or {}).get("content") == content):
                return {
                    "type": evt.get("type"),
                    "eventType": evt.get("eventType"),
                    "data": {"messages": [msg]},
                    "timestamp": evt.get("timestamp"),
                }
    raise AssertionError(f"未收到目标消息事件: event={event_type}, msgId={msg_id}, content={content}, events={seen}")


def _send_text(device_a, device_b, assert_api, user_a, user_b, content):
    device_a.drain_events()
    device_b.drain_events()
    resp = device_a.call(
        "ChatManager", Cmd.sendMessage.value,
        info=build_text(user_a, user_b, content),
    )
    temp_id = ((resp.get("result") or {}).get("msgId"))
    assert temp_id, f"sendMessage 未返回临时 msgId: response={resp}"
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.sendMessage.value,
            "device": "deviceA",
            "result": {
                "msgId": str(temp_id),
                "from": user_a,
                "to": user_b,
                "convId": user_b,
                "chatType": 0,
                "direction": 0,
                "hasRead": True,
                "needReadReceipt": False, "isThread": False,
                "isContentReplaced": False,
                "body": {"type": 0, "content": content},
            },
        },
        ignore_keys={"sequence", "serverTime", "localTime", "broadcast", "onlineState", "deliverOnlineOnly", "targetLanguages", "translations"},
    )

    success = None
    # 服务端已确认发送成功后，接收端回调仍可能因最终一致性/重连延迟晚到。
    # 只有收到目标消息后才允许进入撤回步骤，避免撤回早于接收导致误判。
    deadline = time.monotonic() + 60
    while time.monotonic() < deadline:
        evt = device_a.receive_message(
            match_event_type=Cmd.onMessageSuccess.value,
            timeout=min(1.0, max(0.1, deadline - time.monotonic())),
        )
        data = (evt or {}).get("data") or {}
        msg = data.get("msg") or {}
        if (
            str(data.get("msgId")) == str(temp_id)
            and msg.get("msgId")
            and msg.get("to") == user_b
            and (msg.get("body") or {}).get("content") == content
        ):
            success = evt
            break

        error_evt = device_a.receive_message(
            match_event_type=Cmd.onMessageError.value,
            timeout=min(1.0, max(0.1, deadline - time.monotonic())),
        )
        error_data = (error_evt or {}).get("data") or {}
        if str(error_data.get("msgId")) != str(temp_id):
            continue
        error = error_data.get("error") or {}
        raise AssertionError(
            "发送撤回前置消息失败: "
            f"content={content}, tempId={temp_id}, "
            f"code={error.get('code')}, description={error.get('description')}, "
            f"event={error_evt}"
        )

    assert success, (
        f"发送终态超时: content={content}, tempId={temp_id}; "
        "未收到匹配的 onMessageSuccess/onMessageError"
    )
    real_id = (((success.get("data") or {}).get("msg")) or {}).get("msgId")
    assert_api.assert_response_matches(
        success,
        expected={
            "type": "event",
            "eventType": Cmd.onMessageSuccess.value,
            "data": {
                "msgId": str(temp_id),
                "msg": {
                    "msgId": str(real_id),
                    "from": user_a,
                    "to": user_b,
                    "convId": user_b,
                    "chatType": 0,
                    "direction": 0,
                    "status": 2,
                    "hasRead": True,
                    "needReadReceipt": False, "isThread": False,
                    "isContentReplaced": False,
                    "deliverOnlineOnly": False,
                    "body": {"type": 0, "content": content, "translations": {}},
                },
            },
        },
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "broadcast", "onlineState"},
    )
    deadline = time.monotonic() + 30
    while time.monotonic() < deadline:
        evt = device_b.receive_message(match_event_type=Cmd.onMessagesReceived.value, timeout=2)
        target = next(
            (
                m for m in (((evt or {}).get("data") or {}).get("messages") or [])
                if isinstance(m, dict) and str(m.get("msgId")) == str(real_id)
            ),
            None,
        )
        if target is not None:
            _assert_text_event(
                assert_api,
                {"type": evt.get("type"), "eventType": evt.get("eventType"), "data": {"messages": [target]}, "timestamp": evt.get("timestamp")},
                event_type=Cmd.onMessagesReceived.value,
                msg_id=real_id,
                user_a=user_a,
                user_b=user_b,
                content=content,
                direction=1,
                conv_id=user_a,
                has_read=False,
                has_deliver_ack=None,
            )
            return real_id
    raise AssertionError(f"接收端在 60 秒内未收到本次消息: msgId={real_id}, content={content}")


def _wait_recall_event(device_b, msg_id, *, timeout=30):
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        evt = device_b.receive_message(
            match_event_type=Cmd.onMessagesRecalledInfo.value,
            timeout=min(2.0, max(0.1, deadline - time.monotonic())),
        )
        if evt:
            seen.append(evt)
        infos = ((evt or {}).get("data") or {}).get("infos") or []
        if any(
            isinstance(info, dict) and str(info.get("recallMsgId")) == str(msg_id)
            for info in infos
        ):
            return evt
    raise AssertionError(f"接收端未收到本次撤回事件: msgId={msg_id}, events={seen}")


def _assert_error(assert_api, resp, cmd, device, code, description):
    # 只看 errorcode（leader 要求）：description 传 None 时只断 code，不比对描述（两端描述可能不同）
    expected = {"manager": "ChatManager", "cmd": cmd, "device": device, "result": {"code": code}}
    if description is not None:
        expected["result"]["description"] = description
    assert_api.assert_response_matches(
        resp,
        expected=expected,
        ignore_keys={"sequence"},
    )


def test_chat_pin_message_invalid_id(device_a, assert_api):
    with _allure_step("验证：chat pin message invalid id"):
        resp = device_a.call("ChatManager", Cmd.pinMessage.value, info={"msgId": "__invalid_pin_msg__"})
        _assert_error(assert_api, resp, Cmd.pinMessage.value, "deviceA", 500, "Message is invalid")


def test_chat_pin_message_empty_id(device_a, assert_api):
    with _allure_step("验证：chat pin message empty id"):
        resp = device_a.call("ChatManager", Cmd.pinMessage.value, info={"msgId": ""})
        _assert_error(assert_api, resp, Cmd.pinMessage.value, "deviceA", 110, None)


@pytest.mark.topology("account_a_to_account_b")
def test_chat_pin_recalled_message(topology, assert_api):
    """A 发送并撤回消息：验证 B 全部在线端收到撤回通知（onMessagesRecalledInfo），pin 撤回消息报错。"""
    sender = topology.sender_action_device
    recipients = topology.recipient_devices
    sender_user = topology.sender_user
    recipient_user = topology.recipient_user
    content = f"pin-recalled-{uuid.uuid4().hex[:8]}"

    with _allure_step("清理发送与接收账号全部端历史事件"):
        for device in (*topology.sender_devices, *recipients):
            device.drain_events(timeout=0.5)

    with _allure_step(f"{sender.device_name} 发送文本消息"):
        msg_id = _send_text(sender, recipients[0], assert_api, sender_user, recipient_user, content)

    time.sleep(float(os.getenv("CHAT_RECALL_SETTLE_SECONDS", "5")))

    with _allure_step(f"{sender.device_name} 撤回消息"):
        recall = sender.call("ChatManager", Cmd.recallMessage.value, info={"msgId": msg_id})
    assert_api.assert_response_matches(
        recall,
        expected={"manager": "ChatManager", "cmd": Cmd.recallMessage.value,
                  "device": "{{device}}", "result": True},
        context={"device": sender.device_name},
        ignore_keys={"sequence"},
    )

    with _allure_step("B 全部在线端收到撤回通知（onMessagesRecalledInfo）"):
        for recipient in recipients:
            recall_event = _wait_recall_event(recipient, msg_id)
            infos = (recall_event.get("data") or {}).get("infos") or []
            recalled_info = next(
                info for info in infos
                if isinstance(info, dict) and str(info.get("recallMsgId")) == str(msg_id)
            )
            assert_api.assert_response_matches(
                {"type": "event", "eventType": Cmd.onMessagesRecalledInfo.value,
                 "data": {"infos": [recalled_info]}},
                expected={
                    "type": "event",
                    "eventType": Cmd.onMessagesRecalledInfo.value,
                    "data": {"infos": [{
                        "recallBy": sender_user,
                        "recallMsgId": str(msg_id),
                        "convId": sender_user,
                        "msg": {
                            "msgId": str(msg_id), "from": sender_user, "to": recipient_user,
                            "convId": sender_user, "chatType": 0, "direction": 1,
                            "status": 2, "hasRead": False, "needReadReceipt": False, "isThread": False, "isContentReplaced": False,
                            "deliverOnlineOnly": False,
                            "body": {"type": 0, "content": content, "translations": {}},
                        },
                        "ext": "",
                    }]},
                },
                ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "receiverList"},
            )

    with _allure_step(f"{sender.device_name} pin 已撤回消息应报错"):
        resp = sender.call("ChatManager", Cmd.pinMessage.value, info={"msgId": msg_id})
    _assert_error(assert_api, resp, Cmd.pinMessage.value, sender.device_name, 500, "Message is invalid")


@pytest.mark.parametrize(
    ("type_key", "payload"),
    [
        ("location", {"latitude": 30.2741, "longitude": 120.1551,
                      "address": "pin-recalled-location", "buildingName": "pin-recalled"}),
        ("custom", {"event": "pin-recalled-custom", "params": {"case": "recalled"}}),
    ],
)
def test_chat_pin_recalled_typed_message(
    device_a, device_b, assert_api, user_a, user_b, type_key, payload,
):
    with _allure_step("验证：chat pin recalled typed message"):
        _, _, _, msg_id = _send_typed(
            device_a, device_b, assert_api, user_a, user_b, type_key, payload,
        )
        time.sleep(float(os.getenv("CHAT_RECALL_SETTLE_SECONDS", "5")))
        recall = device_a.call("ChatManager", Cmd.recallMessage.value, info={"msgId": msg_id})
        assert_api.assert_response_matches(
            recall,
            expected={"manager": "ChatManager", "cmd": Cmd.recallMessage.value,
                      "device": "deviceA", "result": True},
            ignore_keys={"sequence"},
        )
        time.sleep(1)
        response = device_a.call("ChatManager", Cmd.pinMessage.value, info={"msgId": msg_id})
        _assert_error(assert_api, response, Cmd.pinMessage.value, "deviceA", 500, "Message is invalid")


def test_chat_unpin_message_invalid_id(device_a, assert_api):
    with _allure_step("验证：chat unpin message invalid id"):
        resp = device_a.call("ChatManager", Cmd.unpinMessage.value, info={"msgId": "__invalid_unpin_msg__"})
        _assert_error(assert_api, resp, Cmd.unpinMessage.value, "deviceA", 500, "Message is invalid")


def test_chat_unpin_message_empty_id(device_a, assert_api):
    with _allure_step("验证：chat unpin message empty id"):
        resp = device_a.call("ChatManager", Cmd.unpinMessage.value, info={"msgId": ""})
        _assert_error(assert_api, resp, Cmd.unpinMessage.value, "deviceA", 110, None)


@pytest.mark.parametrize("conv_id", ["", "__invalid_pin_conversation__"])
def test_chat_fetch_pinned_messages_invalid_conversation(device_a, assert_api, conv_id):
    with _allure_step("验证：chat fetch pinned messages invalid conversation"):
        resp = device_a.call("ChatManager", Cmd.fetchPinnedMessages.value, info={"convId": conv_id})
        expected = (110, None) if conv_id == "" else (107, None)
        _assert_error(assert_api, resp, Cmd.fetchPinnedMessages.value, "deviceA", *expected)
