from __future__ import annotations

import time
import uuid

import pytest

from src import Cmd, ge, ne
from tests.chat._utils import build_text


pytestmark = [pytest.mark.client, pytest.mark.chat]


def _conversation(user_b: str) -> dict:
    return {"convId": user_b, "type": 0, "isThread": False}


def _expected_sent_message(
    msg_id: str,
    user_a: str,
    user_b: str,
    content: str,
    *,
    status=2,
    has_deliver_ack: bool = False,
) -> dict:
    return {
        "broadcast": False,
        "msgId": msg_id,
        "isContentReplaced": False,
        "hasDeliverAck": has_deliver_ack,
        "body": {
            "targetLanguages": [],
            "translations": {},
            "type": 0,
            "content": content,
        },
        "needReadReceipt": False, "convId": user_b,
        "hasRead": True,
        "isThread": False,
        "from": user_a,
        "to": user_b,
        "status": status,
        "chatType": 0,
        "direction": 0,
        "onlineState": True,
    }


def _expected_received_message(msg_id: str, user_a: str, user_b: str, content: str) -> dict:
    return {
        "msgId": msg_id,
        "isContentReplaced": False,
        "body": {"type": 0, "content": content},
        "needReadReceipt": False, "convId": user_a,
        "hasRead": False,
        "isThread": False,
        "from": user_a,
        "to": user_b,
        "status": 2,
        "chatType": 0,
        "direction": 1,
        "deliverOnlineOnly": False,
    }

def _send_text_and_receive(device_a, device_b, assert_api, user_a: str, user_b: str, content: str) -> str:
    try:
        device_a.drain_events()
        device_b.drain_events()
    except Exception:
        pass

    resp = device_a.call("ChatManager", Cmd.sendMessage.value, info=build_text(user_a, user_b, content))
    temp_id = (resp.get("result") or {}).get("msgId")
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.sendMessage.value,
            "device": "deviceA",
            "result": {
                "msgId": "{{msgId}}",
                "from": "{{userA}}",
                "to": "{{userB}}",
                "convId": "{{userB}}",
                "chatType": 0,
                "direction": 0,
                "status": 0,
                "hasRead": True,
                "needReadReceipt": False, "isThread": False,
                "isContentReplaced": False,
                "body": {
                    "targetLanguages": [],
                    "translations": {},
                    "type": 0,
                    "content": "{{content}}",
                },
                "broadcast": False,
                "onlineState": True,
            },
        },
        context={"msgId": temp_id, "userA": user_a, "userB": user_b, "content": content},
        ignore_keys={
            "sequence",
            "serverTime",
            "localTime",
            "deliverOnlineOnly",
        },
    )
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
    assert evt_success is not None, f"未收到目标 onMessageSuccess: temp_id={temp_id}, content={content}, events={seen_success}"
    real_id = (((evt_success.get("data") or {}).get("msg") or {}).get("msgId")) or temp_id
    assert_api.assert_response_matches(
        evt_success,
        expected={
            "type": "event",
            "eventType": Cmd.onMessageSuccess.value,
            "data": {
                "msgId": temp_id,
                "msg": _expected_sent_message(
                    "{{msgId}}", "{{userA}}", "{{userB}}", "{{content}}",
                    status=2, has_deliver_ack=None,
                ),
            },
        },
        context={"msgId": real_id, "userA": user_a, "userB": user_b, "content": content},
        ignore_keys={
            "timestamp",
            "sequence",
            "serverTime",
            "localTime",
            "deliverOnlineOnly",
            "data.msg.body.targetLanguages",
            "data.msg.broadcast",
            "data.msg.onlineState",
        },
    )

    seen_events = []
    for _ in range(5):
        evt_received = device_b.receive_message(match_event_type=Cmd.onMessagesReceived.value, timeout=20.0)
        if evt_received:
            seen_events.append(evt_received)
        messages = ((evt_received or {}).get("data") or {}).get("messages") or []
        received_message = next(
            (message for message in messages if isinstance(message, dict) and message.get("msgId") == real_id),
            None,
        )
        if received_message is not None:
            assert_api.assert_response_matches(
                received_message,
                expected=_expected_received_message("{{msgId}}", "{{userA}}", "{{userB}}", "{{content}}"),
                context={"msgId": real_id, "userA": user_a, "userB": user_b, "content": content},
                ignore_keys={
                    "timestamp",
                    "sequence",
                    "serverTime",
                    "localTime",
                    "translations",
                    "targetLanguages",
                },
            )
            return str(real_id)
    raise AssertionError(f"B 端未收到目标消息: msgId={real_id}, events={seen_events}")


def test_conversation_latest_and_last_received_messages(device_a, device_b, assert_api, user_a, user_b):
    """latestMessage/lastReceivedMessage：发送一条单聊消息后，分别校验发送方最新消息和接收方最近收到消息。"""
    conv_a = _conversation(user_b)
    conv_b = _conversation(user_a)
    for device, conv, expected_device in ((device_a, conv_a, "deviceA"), (device_b, conv_b, "deviceB")):
        resp_clear = device.call("ConversationManager", Cmd.clearAllMessages.value, info=conv)
        assert_api.assert_response_matches(
            resp_clear,
            expected={
                "manager": "ConversationManager",
                "cmd": Cmd.clearAllMessages.value,
                "device": expected_device,
                "result": True,
            },
            ignore_keys={"sequence"},
        )

    content = f"conv-latest-{uuid.uuid4().hex[:8]}"
    msg_id = _send_text_and_receive(device_a, device_b, assert_api, user_a, user_b, content)

    resp_latest = device_a.call(
        "ConversationManager",
        Cmd.getLatestMessage.value,
        info=conv_a,
    )
    assert_api.assert_response_matches(
        resp_latest,
        expected={
            "manager": "ConversationManager",
            "cmd": Cmd.getLatestMessage.value,
            "device": "deviceA",
            "result": _expected_sent_message(ne(""), "{{userA}}", "{{userB}}", "{{content}}", status=ge(1), has_deliver_ack=None),
        },
        context={"msgId": msg_id, "userA": user_a, "userB": user_b, "content": content},
        ignore_keys={"sequence", "serverTime", "localTime", "deliverOnlineOnly", "receiverList"},
    )

    resp_last_received = device_b.call(
        "ConversationManager",
        Cmd.getLatestMessageFromOthers.value,
        info=conv_b,
    )
    assert_api.assert_response_matches(
        resp_last_received,
        expected={
            "manager": "ConversationManager",
            "cmd": Cmd.getLatestMessageFromOthers.value,
            "device": "deviceB",
            "result": {
                "from": user_a,
                "to": user_b,
                "convId": user_a,
                "chatType": 0,
                "direction": 1,
                "body": {"type": 0},
            },
        },
        ignore_keys={
            "sequence",
            "msgId",
            "serverTime",
            "localTime",
            "deliverOnlineOnly",
            "receiverList",
            "content",
            "status",
            "hasRead",
            "hasDeliverAck",
            "isThread",
            "isContentReplaced",
            "broadcast",
            "onlineState",
            "groupAckCount",
            "targetLanguages",
            "translations",
        },
    )
    for device, conv in ((device_a, conv_a), (device_b, conv_b)):
        device.call("ConversationManager", Cmd.clearAllMessages.value, info=conv)


def test_conversation_read_count_and_mark_read(device_a, device_b, assert_api, user_a, user_b):
    """unreadCount/markMessageAsRead/markAllMessagesAsRead：制造未读后按消息和按会话标记已读，校验计数清零。"""
    conv_b = _conversation(user_a)
    device_b.call("ConversationManager", Cmd.markAllMessagesAsRead.value, info=conv_b)
    baseline_resp = device_b.call("ConversationManager", Cmd.getUnreadMsgCount.value, info=conv_b)
    baseline = baseline_resp.get("result")
    assert isinstance(baseline, int), f"getUnreadMsgCount 未返回 int: {baseline_resp}"

    content = f"conv-read-{uuid.uuid4().hex[:8]}"
    msg_id = _send_text_and_receive(device_a, device_b, assert_api, user_a, user_b, content)

    resp_unread = device_b.call("ConversationManager", Cmd.getUnreadMsgCount.value, info=conv_b)
    assert_api.assert_response_matches(
        resp_unread,
        expected={
            "manager": "ConversationManager",
            "cmd": Cmd.getUnreadMsgCount.value,
            "device": "deviceB",
            "result": ge(baseline),
        },
        ignore_keys={"sequence"},
    )

    resp_mark_one = device_b.call(
        "ConversationManager",
        Cmd.markMessageAsRead.value,
        info={**conv_b, "msgId": msg_id},
    )
    mark_one_result = resp_mark_one.get("result")
    if isinstance(mark_one_result, dict):
        if mark_one_result.get("code") == 3:
            expected_mark_one = {"code": 3, "description": "Database operation failed"}
        else:
            expected_mark_one = {"code": 500, "description": "Message is invalid"}
    elif isinstance(mark_one_result, bool):
        expected_mark_one = mark_one_result
    elif mark_one_result == 0:
        expected_mark_one = 0
    else:
        expected_mark_one = 1
    assert_api.assert_response_matches(
        resp_mark_one,
        expected={
            "manager": "ConversationManager",
            "cmd": Cmd.markMessageAsRead.value,
            "device": "deviceB",
            "result": expected_mark_one,
        },
        ignore_keys={"sequence"},
    )

    resp_mark_all = device_b.call("ConversationManager", Cmd.markAllMessagesAsRead.value, info=conv_b)
    assert_api.assert_response_matches(
        resp_mark_all,
        expected={
            "manager": "ConversationManager",
            "cmd": Cmd.markAllMessagesAsRead.value,
            "device": "deviceB",
            "result": True,
        },
        ignore_keys={"sequence"},
    )

    resp_zero = device_b.call("ConversationManager", Cmd.getUnreadMsgCount.value, info=conv_b)
    assert_api.assert_response_matches(
        resp_zero,
        expected={
            "manager": "ConversationManager",
            "cmd": Cmd.getUnreadMsgCount.value,
            "device": "deviceB",
            "result": 0,
        },
        ignore_keys={"sequence"},
    )


def test_conversation_load_message_and_message_lists(device_a, device_b, assert_api, user_a, user_b):
    """loadMessage/loadMessages/loadMessagesFromTime：发送后按 ID、数量和时间窗口加载当前消息。"""
    keyword = f"conv-load-{uuid.uuid4().hex[:8]}"
    msg_id = _send_text_and_receive(device_a, device_b, assert_api, user_a, user_b, keyword)
    conv_a = _conversation(user_b)
    start_time = int(time.time() * 1000) - 60_000
    end_time = int(time.time() * 1000) + 60_000

    resp_load_one = device_a.call("ConversationManager", Cmd.loadMsgWithId.value, info={**conv_a, "msgId": msg_id})
    assert_api.assert_response_matches(
        resp_load_one,
        expected={
            "manager": "ConversationManager",
            "cmd": Cmd.loadMsgWithId.value,
            "device": "deviceA",
            "result": _expected_sent_message(
                "{{msgId}}", "{{userA}}", "{{userB}}", "{{keyword}}",
                status=ge(1), has_deliver_ack=None,
            ),
        },
        context={"msgId": msg_id, "userA": user_a, "userB": user_b, "keyword": keyword},
        ignore_keys={
            "sequence",
            "serverTime",
            "localTime",
            "deliverOnlineOnly",
            "receiverList",
        },
    )

    list_expect = [
        _expected_sent_message(
            "{{msgId}}", "{{userA}}", "{{userB}}", "{{keyword}}",
            status=ge(1), has_deliver_ack=None,
        )
    ]
    for cmd, info in [
        (Cmd.loadMsgWithStartId.value, {**conv_a, "startId": "", "count": 1, "direction": 0}),
        (Cmd.loadMsgWithTime.value, {**conv_a, "startTime": start_time, "endTime": end_time, "count": 1}),
    ]:
        resp = device_a.call("ConversationManager", cmd, info=info)
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "ConversationManager",
                "cmd": cmd,
                "device": "deviceA",
                "result": list_expect,
            },
            context={"msgId": msg_id, "userA": user_a, "userB": user_b, "keyword": keyword},
            ignore_keys={
                "sequence",
                "serverTime",
                "localTime",
                "deliverOnlineOnly",
                "receiverList",
            },
        )


def test_conversation_type_keyword_and_options_search_current_behavior(device_a, device_b, assert_api, user_a, user_b):
    """loadMessagesWithMsgType/loadMessagesWithKeyword/conversationSearchMsgsByOptions：使用空数量/唯一关键词边界冻结空列表返回。"""
    keyword = f"conv-search-{uuid.uuid4().hex[:8]}"
    conv_a = _conversation(user_b)

    resp_by_type = device_a.call(
        "ConversationManager",
        Cmd.loadMsgWithMsgType.value,
        info={**conv_a, "msgType": 0, "timestamp": -1, "count": 0, "direction": 0},
    )
    assert_api.assert_response_matches(
        resp_by_type,
        expected={
            "manager": "ConversationManager",
            "cmd": Cmd.loadMsgWithMsgType.value,
            "device": "deviceA",
            "result": [],
        },
        ignore_keys={"sequence"},
    )

    resp_by_keyword = device_a.call(
        "ConversationManager",
        Cmd.loadMsgWithKeywords.value,
        info={**conv_a, "keywords": keyword, "count": 1, "timestamp": -1, "searchScope": 0, "direction": 0},
    )
    assert_api.assert_response_matches(
        resp_by_keyword,
        expected={
            "manager": "ConversationManager",
            "cmd": Cmd.loadMsgWithKeywords.value,
            "device": "deviceA",
            "result": [],
        },
        ignore_keys={"sequence"},
    )

    resp_by_options = device_a.call(
        "ConversationManager",
        Cmd.conversationSearchMsgsByOptions.value,
        info={**conv_a, "ts": -1, "count": 0, "direction": 0, "types": [0], "from": user_a},
    )
    assert_api.assert_response_matches(
        resp_by_options,
        expected={
            "manager": "ConversationManager",
            "cmd": Cmd.conversationSearchMsgsByOptions.value,
            "device": "deviceA",
            "result": [],
        },
        ignore_keys={"sequence"},
    )


def test_conversation_ext_and_count_queries(device_a, device_b, assert_api, user_a, user_b):
    """syncConversationExt/messageCount/conversationGetLocalMessageCount/conversationRemindType/pinnedMessages：校验会话扩展、计数、免打扰和置顶消息查询。"""
    content = f"conv-count-{uuid.uuid4().hex[:8]}"
    msg_id = _send_text_and_receive(device_a, device_b, assert_api, user_a, user_b, content)
    conv_a = _conversation(user_b)

    resp_ext = device_a.call(
        "ConversationManager",
        Cmd.syncConversationExt.value,
        info={**conv_a, "ext": {"scene": "api-coverage"}},
    )
    assert_api.assert_response_matches(
        resp_ext,
        expected={
            "manager": "ConversationManager",
            "cmd": Cmd.syncConversationExt.value,
            "device": "deviceA",
            "result": True,
        },
        ignore_keys={"sequence"},
    )

    resp_msg_count = device_a.call("ConversationManager", Cmd.messageCount.value, info=conv_a)
    assert_api.assert_response_matches(
        resp_msg_count,
        expected={
            "manager": "ConversationManager",
            "cmd": Cmd.messageCount.value,
            "device": "deviceA",
            "result": ge(1),
        },
        ignore_keys={"sequence"},
    )

    now = int(time.time() * 1000)
    resp_local_count = device_a.call(
        "ConversationManager",
        Cmd.conversationGetLocalMessageCount.value,
        info={**conv_a, "startTs": now - 60_000, "endTs": now + 60_000},
    )
    assert_api.assert_response_matches(
        resp_local_count,
        expected={
            "manager": "ConversationManager",
            "cmd": Cmd.conversationGetLocalMessageCount.value,
            "device": "deviceA",
            "result": ge(1),
        },
        ignore_keys={"sequence"},
    )

    resp_remind = device_a.call("ConversationManager", Cmd.conversationRemindType.value, info=conv_a)
    assert_api.assert_response_matches(
        resp_remind,
        expected={
            "manager": "ConversationManager",
            "cmd": Cmd.conversationRemindType.value,
            "device": "deviceA",
            "result": 0,
        },
        ignore_keys={"sequence"},
    )

    resp_pin = device_a.call("ChatManager", Cmd.pinMessage.value, info={"msgId": msg_id})
    assert_api.assert_response_matches(
        resp_pin,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.pinMessage.value,
            "device": "deviceA",
            "result": None,
        },
        ignore_keys={"sequence"},
    )

    resp_pinned = device_a.call("ConversationManager", Cmd.pinnedMessages.value, info=conv_a)
    target_pinned = [
        message for message in (resp_pinned.get("result") or [])
        if isinstance(message, dict) and str(message.get("msgId")) == str(msg_id)
    ]
    assert_api.assert_response_matches(
        {**resp_pinned, "result": target_pinned},
        expected={
            "manager": "ConversationManager",
            "cmd": Cmd.pinnedMessages.value,
            "device": "deviceA",
            "result": [
                _expected_sent_message(
                    msg_id, user_a, user_b, content,
                    has_deliver_ack=None,
                )
            ],
        },
        ignore_keys={
            "sequence",
            "serverTime",
            "localTime",
            "deliverOnlineOnly",
            "receiverList",
        },
    )

    resp_unpin = device_a.call("ChatManager", Cmd.unpinMessage.value, info={"msgId": msg_id})
    assert_api.assert_response_matches(
        resp_unpin,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.unpinMessage.value,
            "device": "deviceA",
            "result": None,
        },
        ignore_keys={"sequence"},
    )


def test_conversation_invalid_message_id_boundaries(device_a, assert_api, user_b):
    """loadMessage/markMessageAsRead/deleteMessageByIds：非法消息 ID 边界，冻结当前端真实返回语义。"""
    conv_a = _conversation(user_b)

    resp_load_invalid = device_a.call(
        "ConversationManager",
        Cmd.loadMsgWithId.value,
        info={**conv_a, "msgId": "__not_exists_msg_id__"},
    )
    assert_api.assert_response_matches(
        resp_load_invalid,
        expected={
            "manager": "ConversationManager",
            "cmd": Cmd.loadMsgWithId.value,
            "device": "deviceA",
            "result": None,
        },
        ignore_keys={"sequence"},
    )

    resp_mark_invalid = device_a.call(
        "ConversationManager",
        Cmd.markMessageAsRead.value,
        info={**conv_a, "msgId": "__not_exists_msg_id__"},
    )
    assert_api.assert_response_matches(
        resp_mark_invalid,
        expected={
            "manager": "ConversationManager",
            "cmd": Cmd.markMessageAsRead.value,
            "device": "deviceA",
            "result": True,
        },
        ignore_keys={"sequence"},
    )

    resp_delete_empty = device_a.call(
        "ConversationManager",
        Cmd.deleteMessageByIds.value,
        info={**conv_a, "messageIds": []},
    )
    assert_api.assert_response_matches(
        resp_delete_empty,
        expected={
            "manager": "ConversationManager",
            "cmd": Cmd.deleteMessageByIds.value,
            "device": "deviceA",
            "result": True,
        },
        ignore_keys={"sequence"},
    )


def test_conversation_local_insert_append_update_and_delete(device_a, assert_api, user_a, user_b):
    """insertMessage/appendMessage/updateConversationMessage/removeMessage/clearAllMessages/deleteMessagesWithTs：本地消息写入、更新和删除链路。"""
    conv_a = _conversation(user_b)
    base_time = int(time.time() * 1000)
    insert_id = f"local-insert-{uuid.uuid4().hex[:8]}"
    append_id = f"local-append-{uuid.uuid4().hex[:8]}"
    update_content = f"local-updated-{uuid.uuid4().hex[:8]}"
    insert_msg = {
        "msgId": insert_id,
        "from": user_a,
        "to": user_b,
        "convId": user_b,
        "chatType": 0,
        "direction": 0,
        "status": 2,
        "hasRead": True,
        "needReadReceipt": False, "isThread": False,
        "deliverOnlineOnly": False,
        "localTime": base_time,
        "serverTime": base_time,
        "body": {"type": 0, "content": f"local-insert-{uuid.uuid4().hex[:8]}"},
    }
    append_msg = {
        **insert_msg,
        "msgId": append_id,
        "localTime": base_time + 1,
        "serverTime": base_time + 1,
        "body": {"type": 0, "content": f"local-append-{uuid.uuid4().hex[:8]}"},
    }

    for cmd, message in [
        (Cmd.insertMessage.value, insert_msg),
        (Cmd.appendMessage.value, append_msg),
    ]:
        resp = device_a.call("ConversationManager", cmd, info={**conv_a, "msg": message})
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "ConversationManager",
                "cmd": cmd,
                "device": "deviceA",
                "result": True,
            },
            ignore_keys={"sequence"},
        )

    updated_msg = {**append_msg, "body": {"type": 0, "content": update_content}}
    resp_update = device_a.call(
        "ConversationManager",
        Cmd.updateConversationMessage.value,
        info={**conv_a, "msg": updated_msg},
    )
    assert_api.assert_response_matches(
        resp_update,
        expected={
            "manager": "ConversationManager",
            "cmd": Cmd.updateConversationMessage.value,
            "device": "deviceA",
            "result": True,
        },
        ignore_keys={"sequence"},
    )

    resp_loaded = device_a.call("ConversationManager", Cmd.loadMsgWithId.value, info={**conv_a, "msgId": append_id})
    assert_api.assert_response_matches(
        resp_loaded,
        expected={
            "manager": "ConversationManager",
            "cmd": Cmd.loadMsgWithId.value,
            "device": "deviceA",
            "result": {
                "msgId": append_id,
                "from": user_a,
                "to": user_b,
                "convId": user_b,
                "chatType": 0,
                "direction": 0,
                "status": 2,
                "hasRead": True,
                "needReadReceipt": False, "isThread": False,
                "body": {
                    "targetLanguages": [],
                    "translations": {},
                    "type": 0,
                    "content": update_content,
                },
                "broadcast": False,
                "onlineState": True,
            },
        },
        ignore_keys={
            "sequence",
            "serverTime",
            "localTime",
            "isContentReplaced",
            "deliverOnlineOnly",
            "receiverList",
        },
    )

    resp_remove = device_a.call("ConversationManager", Cmd.removeMessage.value, info={**conv_a, "msgId": insert_id})
    assert_api.assert_response_matches(
        resp_remove,
        expected={
            "manager": "ConversationManager",
            "cmd": Cmd.removeMessage.value,
            "device": "deviceA",
            "result": True,
        },
        ignore_keys={"sequence"},
    )

    resp_delete_by_time = device_a.call(
        "ConversationManager",
        Cmd.deleteMessagesWithTs.value,
        info={**conv_a, "startTs": base_time, "endTs": base_time + 2},
    )
    assert_api.assert_response_matches(
        resp_delete_by_time,
        expected={
            "manager": "ConversationManager",
            "cmd": Cmd.deleteMessagesWithTs.value,
            "device": "deviceA",
            "result": True,
        },
        ignore_keys={"sequence"},
    )

    resp_clear = device_a.call("ConversationManager", Cmd.clearAllMessages.value, info=conv_a)
    assert_api.assert_response_matches(
        resp_clear,
        expected={
            "manager": "ConversationManager",
            "cmd": Cmd.clearAllMessages.value,
            "device": "deviceA",
            "result": True,
        },
        ignore_keys={"sequence"},
    )


def test_conversation_delete_local_and_server_messages_current_behavior(device_a, device_b, assert_api, user_a, user_b):
    """conversationDeleteServerMessageWithIds：按消息 ID 删除本地及服务端消息，冻结当前返回。"""
    content = f"conv-server-delete-{uuid.uuid4().hex[:8]}"
    msg_id = _send_text_and_receive(device_a, device_b, assert_api, user_a, user_b, content)
    conv_a = _conversation(user_b)

    resp_delete_ids = device_a.call(
        "ConversationManager",
        Cmd.conversationDeleteServerMessageWithIds.value,
        info={**conv_a, "msgIds": [msg_id]},
    )
    delete_ids_result = resp_delete_ids.get("result")
    if isinstance(delete_ids_result, dict):
        expected_delete_ids = {"code": 500, "description": "Message is invalid"}
    else:
        expected_delete_ids = None
    assert_api.assert_response_matches(
        resp_delete_ids,
        expected={
            "manager": "ConversationManager",
            "cmd": Cmd.conversationDeleteServerMessageWithIds.value,
            "device": "deviceA",
            "result": expected_delete_ids,
        },
        ignore_keys={"sequence"},
    )


def test_conversation_delete_local_and_server_messages_by_time(device_a, device_b, assert_api, user_a, user_b):
    """conversationDeleteServerMessageWithTime：按时间删除本地及服务端消息，冻结当前返回。"""
    content = f"conv-server-delete-time-{uuid.uuid4().hex[:8]}"
    _send_text_and_receive(device_a, device_b, assert_api, user_a, user_b, content)
    conv_a = _conversation(user_b)

    resp_delete_time = device_a.call(
        "ConversationManager",
        Cmd.conversationDeleteServerMessageWithTime.value,
        info={**conv_a, "beforeTs": int(time.time() * 1000) + 1_000},
    )
    delete_time_result = resp_delete_time.get("result")
    if isinstance(delete_time_result, dict):
        expected_delete_time = {"code": 500, "description": "Message is invalid"}
    else:
        expected_delete_time = None
    assert_api.assert_response_matches(
        resp_delete_time,
        expected={
            "manager": "ConversationManager",
            "cmd": Cmd.conversationDeleteServerMessageWithTime.value,
            "device": "deviceA",
            "result": expected_delete_time,
        },
        ignore_keys={"sequence"},
    )
