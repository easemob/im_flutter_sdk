from __future__ import annotations

import time
import uuid

import pytest

from src import Cmd, ne
from src.tools.assertions import assert_error
from tests.chat._utils import build_text, now_ms
from tests.allure_helpers import _allure_step


def _assert_chat_response(assert_api, resp: dict, cmd: str, device: str = "deviceA", result_expected=ne(None)) -> None:
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": cmd,
            "device": device,
            "result": result_expected,
        },
        ignore_keys={"sequence"},
    )


def _assert_text_message_event(assert_api, evt: dict, *, event_type: str, real_id: str, user_a: str, user_b: str, content: str, direction: int, conv_id: str, has_read: bool, has_deliver_ack: bool | None = None) -> None:
    assert_api.assert_response_matches(
        evt,
        expected={
            "type": "event",
            "eventType": event_type,
            "data": {
                "messages": [
                    {
                        "msgId": str(real_id),
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
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "receiverList", "broadcast", "onlineState", "hasDeliverAck"},
    )


def _send_text_and_get_real_id(device_a, device_b, assert_api, user_a: str, user_b: str, content: str) -> str:
    try:
        device_a.drain_events()
        device_b.drain_events()
    except Exception:
        pass

    resp_send = device_a.call("ChatManager", Cmd.sendMessage.value, info=build_text(user_a, user_b, content))
    _assert_chat_response(assert_api, resp_send, Cmd.sendMessage.value, "deviceA", ne(None))
    send_result = resp_send.get("result") or {}
    assert str(send_result.get("from")) == str(user_a)
    assert str(send_result.get("to")) == str(user_b)
    assert str(((send_result.get("body") or {}).get("content"))) == str(content)

    evt_success = None
    seen_success = []
    deadline = time.monotonic() + 60.0
    while time.monotonic() < deadline and evt_success is None:
        evt = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=2.0)
        if evt:
            seen_success.append(evt)
        msg = ((evt or {}).get("data") or {}).get("msg") or {}
        body = msg.get("body") or {}
        if msg.get("from") == user_a and msg.get("to") == user_b and body.get("content") == content:
            evt_success = evt
    assert evt_success is not None, f"未收到目标 onMessageSuccess: content={content}, events={seen_success}"

    real_id = (((evt_success.get("data") or {}).get("msg")) or {}).get("msgId")
    assert real_id, f"missing real msgId from onMessageSuccess: {evt_success!r}"
    assert_api.assert_response_matches(
        evt_success,
        expected={
            "type": "event",
            "eventType": Cmd.onMessageSuccess.value,
            "data": {
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
                }
            },
        },
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "msgId", "broadcast", "onlineState", "targetLanguages"},
    )

    seen_received = []
    deadline = time.monotonic() + 60.0
    while time.monotonic() < deadline:
        evt_received = device_b.receive_message(match_event_type=Cmd.onMessagesReceived.value, timeout=2.0)
        if evt_received:
            seen_received.append(evt_received)
        messages = ((evt_received or {}).get("data") or {}).get("messages") or []
        target = next((msg for msg in messages if isinstance(msg, dict) and msg.get("msgId") == real_id), None)
        if target is not None:
            _assert_text_message_event(
                assert_api,
                {"type": evt_received.get("type"), "eventType": evt_received.get("eventType"), "data": {"messages": [target]}, "timestamp": evt_received.get("timestamp")},
                event_type=Cmd.onMessagesReceived.value,
                real_id=str(real_id),
                user_a=user_a,
                user_b=user_b,
                content=content,
                direction=1,
                conv_id=user_a,
                has_read=False,
                has_deliver_ack=None,
            )
            return str(real_id)
    raise AssertionError(f"未收到目标 onMessagesReceived: msgId={real_id}, events={seen_received}")


def _project_server_conversations(result, user_b: str) -> list[dict]:
    if not isinstance(result, list):
        return []
    return [
        {"convId": item.get("convId"), "type": item.get("type")}
        for item in result
        if isinstance(item, dict) and str(item.get("convId")) == str(user_b)
    ]


def _wait_server_conversation_projection(device, cmd: str, info: dict, user_b: str, *, cursor_result: bool = False) -> tuple[dict, list[dict]]:
    last_resp = None
    last_projection: list[dict] = []
    deadline = time.monotonic() + 30.0
    while time.monotonic() < deadline:
        resp = device.call("ChatManager", cmd, info=info)
        result = resp.get("result") or {}
        # 5.0 移除 cursor 分页：会话查询返回纯 list（无 {list, cursor} dict）→ 统一按 list 处理
        projection = _project_server_conversations(result, user_b)
        if projection:
            return resp, projection
        last_resp, last_projection = resp, projection
        time.sleep(2.0)
    return last_resp or {}, last_projection


def test_chat_load_all_conversations_contains_target_conversation(device_a, device_b, assert_api, user_a, user_b):
    """5.0 会话改本地读取（loadAllConversations）：发消息后本地会话列表含目标会话（原 getConversationsFromServer 服务端拉取已移除）。"""
    with _allure_step("验证：5.0 会话改本地读取（loadAllConversations）：发消息后本地会话列表含目标会话（原 getConversationsFromServer 服务端拉取已移除）。"):
        _ = _send_text_and_get_real_id(device_a, device_b, assert_api, user_a, user_b, f"s2-get-server-{uuid.uuid4().hex[:6]}")
        resp, projected = _wait_server_conversation_projection(device_a, Cmd.loadAllConversations.value, {}, user_b)
        assert_api.assert_response_matches(
            {
                "manager": "ChatManager",
                "cmd": Cmd.loadAllConversations.value,
                "device": "deviceA",
                "result": projected,
            },
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.loadAllConversations.value,
                "device": "deviceA",
                "result": [{"convId": "{{convId}}", "type": 0}],
            },
            context={"convId": user_b},
            ignore_keys={"sequence"},
        )


@pytest.mark.skip(reason="5.0 移除服务端拉会话（改用本地列表，无服务端/分页语义）")
def test_chat_get_conversations_from_server_with_cursor_success(device_a, device_b, assert_api, user_a, user_b):
    _ = _send_text_and_get_real_id(device_a, device_b, assert_api, user_a, user_b, f"s2-get-server-cursor-{uuid.uuid4().hex[:6]}")
    info = {"cursor": "", "pageSize": 20}
    resp, projected = _wait_server_conversation_projection(
        device_a,
        Cmd.getConversationsFromServerWithCursor.value,
        info,
        user_b,
        cursor_result=True,
    )
    result = resp.get("result") or {}
    assert_api.assert_response_matches(
        {
            "manager": "ChatManager",
            "cmd": Cmd.getConversationsFromServerWithCursor.value,
            "device": "deviceA",
            # 5.0 返回纯 list（无 {list, cursor} dict）
            "result": projected,
        },
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.getConversationsFromServerWithCursor.value,
            "device": "deviceA",
            "result": [{"convId": "{{convId}}", "type": 0}],
        },
        context={"convId": user_b},
        ignore_keys={"sequence"},
    )


@pytest.mark.skip(reason="5.0 移除 cursor 分页（会话查询返回纯 list，无 pageSize 校验）")
@pytest.mark.skip(reason="5.0 移除服务端拉会话（改用本地列表，无服务端/分页语义）")
def test_chat_get_conversations_from_server_with_cursor_invalid_page_size_zero(device_a, assert_api):
    info = {"cursor": "", "pageSize": 0}
    resp = device_a.call(
        "ChatManager",
        Cmd.getConversationsFromServerWithCursor.value,
        info=info,
    )
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.getConversationsFromServerWithCursor.value,
            "device": "deviceA",
            "result": {
                "cursor": "",
                "list": [],
            },
        },
        ignore_keys={"sequence"},
    )


@pytest.mark.skip(reason="5.0 移除 cursor 分页（会话查询返回纯 list，无 pageSize 校验）")
@pytest.mark.skip(reason="5.0 移除服务端拉会话（改用本地列表，无服务端/分页语义）")
def test_chat_get_conversations_from_server_with_cursor_invalid_page_size_negative(device_a, assert_api):
    info = {"cursor": "", "pageSize": -1}
    resp = device_a.call(
        "ChatManager",
        Cmd.getConversationsFromServerWithCursor.value,
        info=info,
    )
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.getConversationsFromServerWithCursor.value,
            "device": "deviceA",
            "result": {
                "cursor": "",
                "list": [],
            },
        },
        ignore_keys={"sequence"},
    )


@pytest.mark.skip(reason="5.0 移除服务端拉会话（改用本地列表，无服务端/分页语义）")
def test_chat_fetch_conversations_from_server_with_page_success(device_a, device_b, assert_api, user_a, user_b):
    _ = _send_text_and_get_real_id(device_a, device_b, assert_api, user_a, user_b, f"s2-fetch-page-{uuid.uuid4().hex[:6]}")
    resp, projected = _wait_server_conversation_projection(
        device_a,
        Cmd.fetchConversationsFromServerWithPage.value,
        {"pageNum": 1, "pageSize": 20},
        user_b,
    )
    assert_api.assert_response_matches(
        {
            "manager": "ChatManager",
            "cmd": Cmd.fetchConversationsFromServerWithPage.value,
            "device": "deviceA",
            "result": projected,
        },
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.fetchConversationsFromServerWithPage.value,
            "device": "deviceA",
            "result": [{"convId": "{{convId}}", "type": 0}],
        },
        context={"convId": user_b},
        ignore_keys={"sequence"},
    )


@pytest.mark.skip(reason="5.0 移除服务端拉会话（改用本地列表，无服务端/分页语义）")
def test_chat_fetch_conversations_from_server_with_page_invalid_page_num_zero(device_a, device_b, assert_api, user_a, user_b):
    _ = _send_text_and_get_real_id(device_a, device_b, assert_api, user_a, user_b, f"s2-fetch-page-num0-{uuid.uuid4().hex[:6]}")
    resp, projected = _wait_server_conversation_projection(
        device_a,
        Cmd.fetchConversationsFromServerWithPage.value,
        {"pageNum": 0, "pageSize": 20},
        user_b,
    )
    assert_api.assert_response_matches(
        {
            "manager": "ChatManager",
            "cmd": Cmd.fetchConversationsFromServerWithPage.value,
            "device": "deviceA",
            "result": projected,
        },
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.fetchConversationsFromServerWithPage.value,
            "device": "deviceA",
            "result": [{"convId": "{{convId}}", "type": 0}],
        },
        context={"convId": user_b},
        ignore_keys={"sequence"},
    )


@pytest.mark.skip(reason="5.0 移除服务端拉会话（改用本地列表，无服务端/分页语义）")
def test_chat_fetch_conversations_from_server_with_page_invalid_page_size_zero(device_a, device_b, assert_api, user_a, user_b):
    _ = _send_text_and_get_real_id(device_a, device_b, assert_api, user_a, user_b, f"s2-fetch-page-size0-{uuid.uuid4().hex[:6]}")
    resp, projected = _wait_server_conversation_projection(
        device_a,
        Cmd.fetchConversationsFromServerWithPage.value,
        {"pageNum": 1, "pageSize": 0},
        user_b,
    )
    assert_api.assert_response_matches(
        {
            "manager": "ChatManager",
            "cmd": Cmd.fetchConversationsFromServerWithPage.value,
            "device": "deviceA",
            "result": projected,
        },
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.fetchConversationsFromServerWithPage.value,
            "device": "deviceA",
            "result": [{"convId": "{{convId}}", "type": 0}],
        },
        context={"convId": user_b},
        ignore_keys={"sequence"},
    )


@pytest.mark.skip(reason="5.0 移除服务端拉会话（改用本地列表，无服务端/分页语义）")
def test_chat_get_pinned_conversations_from_server_with_cursor_success(device_a, assert_api):
    info = {"cursor": "", "pageSize": 20}
    resp = device_a.call(
        "ChatManager",
        Cmd.getPinnedConversationsFromServerWithCursor.value,
        info=info,
    )
    # 5.0 返回纯 list（本地缓存，数量不定）→ 锁类型，不整体忽略 result
    pinned_result = resp.get("result")
    assert isinstance(pinned_result, list), f"getPinned 返回非 list: {resp}"
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.getPinnedConversationsFromServerWithCursor.value,
            "device": "deviceA",
        },
        ignore_keys={"sequence"},
    )


@pytest.mark.skip(reason="5.0 移除 cursor 分页（会话查询返回纯 list，无 pageSize 校验）")
@pytest.mark.skip(reason="5.0 移除服务端拉会话（改用本地列表，无服务端/分页语义）")
def test_chat_get_pinned_conversations_from_server_with_cursor_invalid_page_size_zero(device_a, assert_api):
    info = {"cursor": "", "pageSize": 0}
    resp = device_a.call(
        "ChatManager",
        Cmd.getPinnedConversationsFromServerWithCursor.value,
        info=info,
    )
    # 5.0 返回纯 list（本地缓存，数量不定）→ 锁类型，不整体忽略 result
    pinned_result = resp.get("result")
    assert isinstance(pinned_result, list), f"getPinned 返回非 list: {resp}"
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.getPinnedConversationsFromServerWithCursor.value,
            "device": "deviceA",
        },
        ignore_keys={"sequence"},
    )


@pytest.mark.skip(reason="5.0 移除 cursor 分页（会话查询返回纯 list，无 pageSize 校验）")
@pytest.mark.skip(reason="5.0 移除服务端拉会话（改用本地列表，无服务端/分页语义）")
def test_chat_get_pinned_conversations_from_server_with_cursor_invalid_page_size_negative(device_a, assert_api):
    info = {"cursor": "", "pageSize": -1}
    resp = device_a.call(
        "ChatManager",
        Cmd.getPinnedConversationsFromServerWithCursor.value,
        info=info,
    )
    # 5.0 返回纯 list（本地缓存，数量不定）→ 锁类型，不整体忽略 result
    pinned_result = resp.get("result")
    assert isinstance(pinned_result, list), f"getPinned 返回非 list: {resp}"
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.getPinnedConversationsFromServerWithCursor.value,
            "device": "deviceA",
        },
        ignore_keys={"sequence"},
    )


def test_chat_delete_remote_conversation_success(device_a, device_b, assert_api, user_a, user_b):
    with _allure_step("验证：chat delete remote conversation success"):
        _ = _send_text_and_get_real_id(device_a, device_b, assert_api, user_a, user_b, f"s2-del-remote-{uuid.uuid4().hex[:6]}")
        resp = device_a.call(
            "ChatManager",
            Cmd.deleteRemoteConversation.value,
            info={"convId": user_b, "conversationType": 0, "isDeleteRemoteMessage": False},
        )
        _assert_chat_response(assert_api, resp, Cmd.deleteRemoteConversation.value, "deviceA", None)


def test_chat_delete_remote_conversation_empty_conv_id(device_a):
    with _allure_step("验证：chat delete remote conversation empty conv id"):
        resp = device_a.call(
            "ChatManager",
            Cmd.deleteRemoteConversation.value,
            info={"convId": "", "conversationType": 0, "isDeleteRemoteMessage": False},
        )
        assert_error(resp, code=303, description="field channel cannot be null or empty")


def test_chat_delete_remote_conversation_invalid_type(device_a, assert_api):
    with _allure_step("验证：chat delete remote conversation invalid type"):
        resp = device_a.call(
            "ChatManager",
            Cmd.deleteRemoteConversation.value,
            info={"convId": "__invalid_conv__", "conversationType": 2, "isDeleteRemoteMessage": False},
        )
        _assert_chat_response(assert_api, resp, Cmd.deleteRemoteConversation.value, "deviceA", None)


def test_chat_remove_messages_from_server_with_msg_ids_success(device_a, device_b, assert_api, user_a, user_b):
    with _allure_step("验证：chat remove messages from server with msg ids success"):
        real_id = _send_text_and_get_real_id(device_a, device_b, assert_api, user_a, user_b, f"s2-rm-server-ids-{uuid.uuid4().hex[:6]}")
        resp = device_a.call(
            "ChatManager",
            Cmd.removeMessagesFromServerWithMsgIds.value,
            info={"convId": user_b, "type": 0, "msgIds": [real_id]},
        )
        _assert_chat_response(assert_api, resp, Cmd.removeMessagesFromServerWithMsgIds.value, "deviceA", None)


@pytest.mark.skip(reason="必填缺失类 case 暂缓；当前端易返回 MissingPlugin 非被测端语义")
def test_chat_remove_messages_from_server_with_msg_ids_missing_msg_ids(device_a, user_b):
    resp = device_a.call(
        "ChatManager",
        Cmd.removeMessagesFromServerWithMsgIds.value,
        info={"convId": user_b, "type": 0},
    )
    assert_error(resp, code=-1, description="MissingPluginException")


def test_chat_remove_messages_from_server_with_msg_ids_empty_msg_ids(device_a, user_b):
    with _allure_step("验证：chat remove messages from server with msg ids empty msg ids"):
        resp = device_a.call(
            "ChatManager",
            Cmd.removeMessagesFromServerWithMsgIds.value,
            info={"convId": user_b, "type": 0, "msgIds": []},
        )
        assert_error(resp, code=110)


@pytest.mark.skip(reason="必填缺失类 case 暂缓；当前端易返回 MissingPlugin 非被测端语义")
def test_chat_remove_messages_from_server_with_msg_ids_missing_conv_id(device_a):
    resp = device_a.call(
        "ChatManager",
        Cmd.removeMessagesFromServerWithMsgIds.value,
        info={"type": 0, "msgIds": ["__invalid_msg_id__"]},
    )
    assert_error(resp, code=-1, description="MissingPluginException")


def test_chat_remove_messages_from_server_with_ts_success(device_a, assert_api, user_b):
    with _allure_step("验证：chat remove messages from server with ts success"):
        resp = device_a.call(
            "ChatManager",
            Cmd.removeMessagesFromServerWithTs.value,
            info={"convId": user_b, "type": 0, "timestamp": now_ms()},
        )
        _assert_chat_response(assert_api, resp, Cmd.removeMessagesFromServerWithTs.value, "deviceA", None)


@pytest.mark.skip(reason="必填缺失类 case 暂缓；按规则不纳入 strict 批次")
def test_chat_remove_messages_from_server_with_ts_missing_timestamp(device_a, user_b):
    resp = device_a.call(
        "ChatManager",
        Cmd.removeMessagesFromServerWithTs.value,
        info={"convId": user_b, "type": 0},
    )
    assert_error(resp, code=110, description="Invalid parameter")


def test_chat_remove_messages_from_server_with_ts_timestamp_zero(device_a, user_b):
    with _allure_step("验证：chat remove messages from server with ts timestamp zero"):
        resp = device_a.call(
            "ChatManager",
            Cmd.removeMessagesFromServerWithTs.value,
            info={"convId": user_b, "type": 0, "timestamp": 0},
        )
        assert_error(resp, code=110)


@pytest.mark.skip(reason="必填缺失类 case 暂缓；当前端易返回 MissingPlugin 非被测端语义")
def test_chat_remove_messages_from_server_with_ts_missing_conv_id(device_a):
    resp = device_a.call(
        "ChatManager",
        Cmd.removeMessagesFromServerWithTs.value,
        info={"type": 0, "timestamp": now_ms()},
    )
    assert_error(resp, code=-1, description="MissingPluginException")


@pytest.mark.skip(reason="5.0 移除 reportMessage（残留）")
def test_chat_report_message_success(device_a, device_b, assert_api, user_a, user_b):
    real_id = _send_text_and_get_real_id(device_a, device_b, assert_api, user_a, user_b, f"s2-report-{uuid.uuid4().hex[:6]}")
    resp = device_a.call(
        "ChatManager",
        Cmd.reportMessage.value,
        info={"msgId": real_id, "tag": "spam", "reason": "s2-report-message"},
    )
    _assert_chat_response(assert_api, resp, Cmd.reportMessage.value, "deviceA", True)


@pytest.mark.skip(reason="5.0 移除 reportMessage（残留）")
def test_chat_report_message_invalid_msg_id(device_a):
    resp = device_a.call(
        "ChatManager",
        Cmd.reportMessage.value,
        info={"msgId": "__invalid_msg_id__", "tag": "spam", "reason": "invalid-message"},
    )
    assert_error(resp, code=500, description="message id is invalid")


@pytest.mark.skip(reason="必填缺失类 case 暂缓；当前端易返回 MissingPlugin 非被测端语义")
@pytest.mark.skip(reason="5.0 移除 reportMessage（残留）")
def test_chat_report_message_missing_tag(device_a):
    resp = device_a.call(
        "ChatManager",
        Cmd.reportMessage.value,
        info={"msgId": "__invalid_msg_id__", "reason": "missing-tag"},
    )
    assert_error(resp, code=-1, description="MissingPluginException")


@pytest.mark.skip(reason="必填缺失类 case 暂缓；当前端易返回 MissingPlugin 非被测端语义")
@pytest.mark.skip(reason="5.0 移除 reportMessage（残留）")
def test_chat_report_message_missing_reason(device_a):
    resp = device_a.call(
        "ChatManager",
        Cmd.reportMessage.value,
        info={"msgId": "__invalid_msg_id__", "tag": "spam"},
    )
    assert_error(resp, code=-1, description="MissingPluginException")
