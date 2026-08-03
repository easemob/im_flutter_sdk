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


def _wait_message_event(device, event_type: str, *, real_id: str, content: str, timeout: float = 20.0) -> dict:
    deadline = time.monotonic() + timeout
    seen = []
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
                return {
                    "type": evt.get("type"),
                    "eventType": evt.get("eventType"),
                    "data": {"messages": [msg]},
                    "timestamp": evt.get("timestamp"),
                }
    _attach_event_wait_diagnostics(
        event_type=event_type,
        expected={
            "data.messages[].msgId": real_id,
            "data.messages[].body.content": content,
        },
        timeout=timeout,
        seen=seen,
    )
    pytest.fail(
        f"未命中目标消息事件: eventType={event_type}, msgId={real_id}, "
        f"content={content!r}, observed={len(seen)}"
    )


def _assert_text_message_event(assert_api, evt: dict, *, event_type: str, real_id: str, user_a: str, user_b: str, content: str, direction: int, conv_id: str, has_read: bool, has_read_ack: bool = False, has_deliver_ack: bool) -> None:
    assert_api.assert_response_matches(
        evt,
        expected={
            "type": "event",
            "eventType": event_type,
            "data": {
                "messages": [
                    {
                        "msgId": real_id,
                        "from": user_a,
                        "to": user_b,
                        "convId": conv_id,
                        "chatType": 0,
                        "direction": direction,
                        "status": 2,
                        "hasRead": has_read,
                        "hasReadAck": has_read_ack,
                        "hasDeliverAck": has_deliver_ack,
                        "needGroupAck": False,
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


def test_chat_send_and_received(device_a, device_b, assert_api, user_a, user_b):
    try:
        device_a.drain_events()
        device_b.drain_events()
    except Exception:
        pass

    content = "hello-basic"
    resp_send = device_a.call("ChatManager", Cmd.sendMessage.value, info=build_text(user_a, user_b, content))
    evt_success = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
    temp_id = (evt_success.get("data") or {}).get("msgId")
    real_id = ((evt_success.get("data") or {}).get("msg") or {}).get("msgId")
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
        context={"tempId": temp_id, "realId": real_id, "fromUser": user_a, "toUser": user_b, "content": content},
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime"},
    )
    assert_api.assert_response_matches(
        resp_send,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.sendMessage.value,
            "device": "deviceA",
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
                "body": {"type": 0, "content": "{{content}}"},
            },
        },
        context={"tempId": temp_id, "fromUser": user_a, "toUser": user_b, "content": content},
        ignore_keys={"sequence", "serverTime", "localTime", "broadcast", "onlineState", "deliverOnlineOnly", "targetLanguages", "translations"},
    )
    evt_received = device_b.receive_message(match_event_type=Cmd.onMessagesReceived.value, timeout=20.0)
    assert_api.assert_response_matches(
        evt_received,
        expected={
            "type": "event",
            "eventType": Cmd.onMessagesReceived.value,
            "data": {
                "messages": [
                    {
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
                        "deliverOnlineOnly": False,
                        "isThread": False,
                        "isContentReplaced": False,
                        "body": {"type": 0, "content": "{{content}}", "translations": {}},
                        "msgId": "{{realId}}",
                    }
                ]
            },
        },
        context={"fromUser": user_a, "toUser": user_b, "content": content, "realId": real_id},
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "receiverList"},
    )
    evt_delivered = _wait_message_event(device_a, Cmd.onMessagesDelivered.value, real_id=real_id, content=content)
    _assert_text_message_event(
        assert_api,
        evt_delivered,
        event_type=Cmd.onMessagesDelivered.value,
        real_id=real_id,
        user_a=user_a,
        user_b=user_b,
        content=content,
        direction=0,
        conv_id=user_b,
        has_read=True,
        has_deliver_ack=True,
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
    assert_api.assert_response_matches(
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


def test_chat_translate_message_basic(device_a, device_b, assert_api, user_a, user_b):
    try:
        device_a.drain_events()
    except Exception:
        pass
    content = "translate-basic"
    _ = device_a.call("ChatManager", Cmd.sendMessage.value, info=build_text(user_a, user_b, content))
    evt_success = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
    real_id = ((evt_success.get("data") or {}).get("msg") or {}).get("msgId")
    assert real_id, f"missing real msgId from onMessageSuccess: {evt_success!r}"
    evt_received = _wait_message_event(device_b, Cmd.onMessagesReceived.value, real_id=real_id, content=content)
    _assert_text_message_event(assert_api, evt_received, event_type=Cmd.onMessagesReceived.value, real_id=real_id, user_a=user_a, user_b=user_b, content=content, direction=1, conv_id=user_a, has_read=False, has_deliver_ack=True)
    evt_delivered = _wait_message_event(device_a, Cmd.onMessagesDelivered.value, real_id=real_id, content=content)
    _assert_text_message_event(assert_api, evt_delivered, event_type=Cmd.onMessagesDelivered.value, real_id=real_id, user_a=user_a, user_b=user_b, content=content, direction=0, conv_id=user_b, has_read=True, has_deliver_ack=True)
    resp_get = device_a.call("ChatManager", Cmd.getMessage.value, info={"msgId": real_id})
    msg_obj = get_result(resp_get)
    resp_tr = device_a.call("ChatManager", Cmd.translateMessage.value, info={"message": msg_obj, "targetLanguages": ["zh-Hans"]})
    # translateMessage 同步 result 可能回 echo 的整个消息体，也可能只回修改过的 body；统一以 body 为主断言。
    assert_api.assert_response_matches(
        resp_tr,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.translateMessage.value,
            "device": "deviceA",
            "result": {
                "msgId": "{{msgId}}",
                "from": "{{fromUser}}",
                "to": "{{toUser}}",
                "convId": "{{convId}}",
                "chatType": 0,
                "direction": 0,
                "status": 2,
                "hasRead": True,
                "hasReadAck": False,
                "hasDeliverAck": True,
                "needGroupAck": False,
                "isThread": False,
                "isContentReplaced": False,
                "body": {
                    "type": 0,
                    "content": "translate-basic",
                    "translations": {},
                }
            }
        },
        context={"msgId": str(real_id), "fromUser": user_a, "toUser": user_b, "convId": user_b},
        ignore_keys={"sequence", "serverTime", "localTime", "broadcast", "onlineState", "targetLanguages"},
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


def test_chat_translate_message_recalled_message(device_a, device_b, assert_api, user_a, user_b):
    """
    场景：A 向 B 发送文本消息后撤回。

    验证：A 发送和撤回均成功；B 收到原始消息、撤回信息及撤回后的消息本体。
    """
    content = "recalled-translate"
    with _allure_step("A 发送待撤回的文本消息"):
        device_a.call("ChatManager", Cmd.sendMessage.value, info=build_text(user_a, user_b, content))

    with _allure_step("A 等待 onMessageSuccess 并提取消息 ID"):
        evt_success = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
        real_id = (((evt_success or {}).get("data") or {}).get("msg") or {}).get("msgId")
        assert real_id, f"onMessageSuccess 缺少 msgId: {evt_success}"

    with _allure_step(f"B 验证收到原始文本消息 msgId={real_id}"):
        evt_received = _wait_message_event(device_b, Cmd.onMessagesReceived.value, real_id=real_id, content=content)
        _assert_text_message_event(assert_api, evt_received, event_type=Cmd.onMessagesReceived.value, real_id=real_id, user_a=user_a, user_b=user_b, content=content, direction=1, conv_id=user_a, has_read=False, has_deliver_ack=True)

    with _allure_step(f"A 验证送达回执 msgId={real_id}"):
        evt_delivered = _wait_message_event(device_a, Cmd.onMessagesDelivered.value, real_id=real_id, content=content)
        _assert_text_message_event(assert_api, evt_delivered, event_type=Cmd.onMessagesDelivered.value, real_id=real_id, user_a=user_a, user_b=user_b, content=content, direction=0, conv_id=user_b, has_read=True, has_deliver_ack=True)

    with _allure_step(f"A 撤回消息 msgId={real_id}"):
        time.sleep(2)
        resp_recall = device_a.call("ChatManager", Cmd.recallMessage.value, info={"msgId": real_id})
        assert_api.assert_response_matches(
            resp_recall,
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.recallMessage.value,
                "device": "deviceA",
                "result": True,
            },
            ignore_keys={"sequence"},
        )

    with _allure_step(f"B 验证撤回信息 onMessagesRecalledInfo msgId={real_id}"):
        evt_recall_info = _wait_recall_info_event(device_b, real_id=real_id, content=content)
        assert_api.assert_response_matches(
            evt_recall_info,
            expected={
                "type": "event",
                "eventType": Cmd.onMessagesRecalledInfo.value,
                "data": {
                    "infos": [
                        {
                            "recallMsgId": real_id,
                            "recallBy": user_a,
                            "convId": user_a,
                            "ext": "",
                            "msg": {
                                "msgId": real_id,
                                "from": user_a,
                                "to": user_b,
                                "convId": user_a,
                                "chatType": 0,
                                "direction": 1,
                                "status": 2,
                                "hasRead": False,
                                "hasReadAck": False,
                                "hasDeliverAck": True,
                                "needGroupAck": False,
                                "isThread": False,
                                "isContentReplaced": False,
                                "body": {"type": 0, "content": content, "translations": {}},
                            },
                        }
                    ]
                },
            },
            ignore_keys={
                "timestamp", "sequence", "serverTime", "localTime",
                "broadcast", "onlineState", "targetLanguages", "deliverOnlineOnly",
            },
        )

    with _allure_step(f"B 验证撤回消息本体 onMessagesRecalled msgId={real_id}"):
        evt_recalled = _wait_message_event(device_b, Cmd.onMessagesRecalled.value, real_id=real_id, content=content)
        _assert_text_message_event(assert_api, evt_recalled, event_type=Cmd.onMessagesRecalled.value, real_id=real_id, user_a=user_a, user_b=user_b, content=content, direction=1, conv_id=user_a, has_read=False, has_deliver_ack=True)


def test_chat_ack_message_read_success(device_a, device_b, assert_api, user_a, user_b):
    try:
        device_a.drain_events()
        device_b.drain_events()
    except Exception:
        pass
    content = f"ackread-{uuid.uuid4().hex[:6]}"
    resp_send = device_a.call("ChatManager", Cmd.sendMessage.value, info=build_text(user_a, user_b, content))
    evt_success = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
    temp_id = (evt_success.get("data") or {}).get("msgId")
    sent_real_id = (((evt_success or {}).get("data") or {}).get("msg") or {}).get("msgId")
    assert sent_real_id, f"missing real msgId from onMessageSuccess: {evt_success!r}"
    assert_api.assert_response_matches(
        resp_send,
        expected={"manager": "ChatManager", "cmd": Cmd.sendMessage.value, "device": "deviceA", "result": {"msgId": temp_id, "from": user_a, "to": user_b, "convId": user_b, "chatType": 0, "direction": 0, "status": 0, "hasRead": True, "hasReadAck": False, "hasDeliverAck": False, "needGroupAck": False, "isThread": False, "isContentReplaced": False, "body": {"type": 0, "content": content}}},
        ignore_keys={"sequence", "serverTime", "localTime", "broadcast", "onlineState", "deliverOnlineOnly", "targetLanguages", "translations"},
    )

    evt_received = device_b.receive_message(match_event_type=Cmd.onMessagesReceived.value, timeout=20.0)
    recv_msgs = ((evt_received or {}).get("data") or {}).get("messages") or []
    recv_msg_id = None
    for msg in recv_msgs:
        body = (msg or {}).get("body") or {}
        if (
            (msg or {}).get("from") == user_a
            and (msg or {}).get("to") == user_b
            and body.get("content") == content
            and (msg or {}).get("msgId")
        ):
            recv_msg_id = (msg or {}).get("msgId")
            break
    assert recv_msg_id, f"missing received msgId from onMessagesReceived: {evt_received!r}"
    _assert_text_message_event(
        assert_api,
        {"type": evt_received.get("type"), "eventType": evt_received.get("eventType"), "data": {"messages": [msg]}, "timestamp": evt_received.get("timestamp")},
        event_type=Cmd.onMessagesReceived.value,
        real_id=recv_msg_id,
        user_a=user_a,
        user_b=user_b,
        content=content,
        direction=1,
        conv_id=user_a,
        has_read=False,
        has_deliver_ack=True,
    )
    evt_delivered = _wait_message_event(device_a, Cmd.onMessagesDelivered.value, real_id=sent_real_id, content=content)
    _assert_text_message_event(assert_api, evt_delivered, event_type=Cmd.onMessagesDelivered.value, real_id=sent_real_id, user_a=user_a, user_b=user_b, content=content, direction=0, conv_id=user_b, has_read=True, has_deliver_ack=True)

    resp_ack = device_b.call("ChatManager", Cmd.ackMessageRead.value, info={"msgId": recv_msg_id, "to": user_a})
    assert_api.assert_response_matches(
        resp_ack,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.ackMessageRead.value,
            "device": "deviceB",
            "result": True,
        },
        ignore_keys={"sequence"},
    )
    assert_api.assert_response_matches(
        device_a.receive_message(match_event_type=Cmd.onMessagesRead.value, timeout=20.0),
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
        context={"msgId": str(recv_msg_id), "fromUser": user_a, "toUser": user_b, "content": content},
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime"},
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


def test_chat_ack_conversation_read_invalid_id_response(device_b, assert_api):
    resp = device_b.call("ChatManager", Cmd.ackConversationRead.value, info={"convId": "__invalid_conversation_id__"})
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.ackConversationRead.value,
            "device": "deviceB",
            "result": {"code": 500, "description": "Message is invalid"},
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


def test_chat_add_reaction_empty_reaction_response(device_a, device_b, assert_api, user_a, user_b):
    content = "for-reaction-empty"
    _ = device_a.call("ChatManager", Cmd.sendMessage.value, info=build_text(user_a, user_b, content))
    evt_success = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
    real_id = (((evt_success or {}).get("data") or {}).get("msg") or {}).get("msgId")
    evt_received = _wait_message_event(device_b, Cmd.onMessagesReceived.value, real_id=real_id, content=content)
    _assert_text_message_event(assert_api, evt_received, event_type=Cmd.onMessagesReceived.value, real_id=real_id, user_a=user_a, user_b=user_b, content=content, direction=1, conv_id=user_a, has_read=False, has_deliver_ack=True)
    evt_delivered = _wait_message_event(device_a, Cmd.onMessagesDelivered.value, real_id=real_id, content=content)
    _assert_text_message_event(assert_api, evt_delivered, event_type=Cmd.onMessagesDelivered.value, real_id=real_id, user_a=user_a, user_b=user_b, content=content, direction=0, conv_id=user_b, has_read=True, has_deliver_ack=True)
    resp = device_a.call("ChatManager", Cmd.addReaction.value, info={"reaction": "", "msgId": real_id})
    assert_api.assert_response_matches(
        resp,
        expected={"manager": "ChatManager", "cmd": Cmd.addReaction.value, "device": "deviceA", "result": {"code": 110, "description": "'reaction' can not be null"}},
        ignore_keys={"sequence"},
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
