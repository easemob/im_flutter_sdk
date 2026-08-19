from __future__ import annotations

import os
import uuid
import time
from contextlib import nullcontext

import pytest

from src import Cmd, ge
from tests.chat._utils import build_text


def _allure_step(name: str):
    try:
        import allure

        return allure.step(name)
    except ImportError:
        return nullcontext()


pytestmark = [pytest.mark.client, pytest.mark.chat]


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
                "msgId": temp_id,
                "from": user_a,
                "to": user_b,
                "convId": user_b,
                "chatType": 0,
                "direction": 0,
                "hasRead": True,
                "needReadReceipt": False, "isThread": False,
                "isContentReplaced": False,
                "broadcast": False,
                "onlineState": True,
                "body": {"targetLanguages": [], "translations": {}, "type": 0, "content": content},
            },
        },
        ignore_keys={"sequence", "serverTime", "localTime", "deliverOnlineOnly"},
    )
    success_evt = _wait_message_success_for_content(device_a, content=content, to=user_b, timeout=60.0)
    real_id = (((success_evt.get("data") or {}).get("msg") or {}).get("msgId")) or temp_id
    assert_api.assert_response_matches(
        success_evt,
        expected={
            "type": "event",
            "eventType": Cmd.onMessageSuccess.value,
            "data": {
                "msgId": temp_id,
                "msg": {
                    "msgId": real_id,
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
    seen_events = []
    for _ in range(5):
        received_evt = device_b.receive_message(match_event_type=Cmd.onMessagesReceived.value, timeout=20.0)
        if received_evt:
            seen_events.append(received_evt)
        messages = ((received_evt or {}).get("data") or {}).get("messages") or []
        target = next((m for m in messages if isinstance(m, dict) and m.get("msgId") == real_id), None)
        if target is not None:
            assert_api.assert_response_matches(
                {
                    "type": received_evt.get("type"),
                    "eventType": received_evt.get("eventType"),
                    "data": {"messages": [target]},
                    "timestamp": received_evt.get("timestamp"),
                },
                expected={
                    "type": "event",
                    "eventType": Cmd.onMessagesReceived.value,
                    "data": {
                        "messages": [
                            {
                                "msgId": real_id,
                                "from": user_a,
                                "to": user_b,
                                "convId": user_a,
                                "chatType": 0,
                                "direction": 1,
                                "status": 2,
                                "hasRead": False,
                                "needReadReceipt": False, "isThread": False,
                                "isContentReplaced": False,
                                "deliverOnlineOnly": False,
                                "body": {"type": 0, "content": content, "translations": {}},
                            }
                        ]
                    },
                },
                ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "receiverList", "broadcast", "onlineState"},
            )
            return str(real_id)
    raise AssertionError(f"B 端未收到目标消息: msgId={real_id}, events={seen_events}")


def _wait_message_success_for_content(device, *, content: str, to: str, timeout: float = 60.0) -> dict:
    seen_events = []
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        evt = device.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=2.0)
        if evt:
            seen_events.append(evt)
        msg = ((evt or {}).get("data") or {}).get("msg") or {}
        body = msg.get("body") or {}
        if msg.get("to") == to and body.get("content") == content and msg.get("msgId"):
            return evt
    raise AssertionError(f"未收到目标 onMessageSuccess: to={to}, content={content}, events={seen_events}")


def _wait_message_event(device, event_type: str, *, real_id: str, content: str, timeout: float = 60.0) -> dict:
    seen_events = []
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        evt = device.receive_message(match_event_type=event_type, timeout=2.0)
        if evt:
            seen_events.append(evt)
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
    raise AssertionError(f"未收到目标消息事件: event={event_type}, msgId={real_id}, content={content}, events={seen_events}")


def _assert_text_message_event(assert_api, evt: dict, *, event_type: str, real_id: str, user_a: str, user_b: str, content: str, direction: int, conv_id: str, has_read: bool, has_deliver_ack: bool) -> None:
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
                        "needReadReceipt": False, "hasDeliverAck": has_deliver_ack,
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


def _wait_pin_changed(device, *, msg_id: str, operation: str, timeout: float = 20.0) -> dict:
    seen_events = []
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        evt = device.receive_message(match_event_type=Cmd.onMessagePinChanged.value, timeout=2.0)
        if evt:
            seen_events.append(evt)
        data = (evt or {}).get("data") or {}
        operation_int = {"MessagePinOperation.Pin": 0, "MessagePinOperation.Unpin": 1}.get(operation, operation)
        if str(data.get("msgId")) == str(msg_id) and data.get("pinOperation") == operation_int:
            return evt
    raise AssertionError(f"未收到目标 onMessagePinChanged: msgId={msg_id}, operation={operation}, events={seen_events}")


def _assert_no_pin_changed(device, *, msg_id: str, operation: str, timeout: float = 3.0) -> None:
    seen_events = []
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        evt = device.receive_message(
            match_event_type=Cmd.onMessagePinChanged.value,
            timeout=min(1.0, max(0.1, deadline - time.monotonic())),
        )
        if evt:
            seen_events.append(evt)
        data = (evt or {}).get("data") or {}
        operation_int = {"MessagePinOperation.Pin": 0, "MessagePinOperation.Unpin": 1}.get(operation, operation)
        if str(data.get("msgId")) == str(msg_id) and data.get("pinOperation") == operation_int:
            raise AssertionError(
                f"操作者端不应收到 onMessagePinChanged: msgId={msg_id}, operation={operation}, events={seen_events}"
            )


def _assert_pin_changed(assert_api, evt: dict, *, msg_id: str, conversation_id: str, operation: str, operator_id: str) -> None:
    assert_api.assert_response_matches(
        evt,
        expected={
            "type": "event",
            "eventType": Cmd.onMessagePinChanged.value,
            "data": {
                # 5.0 事件字段：msgId/convId（非 messageId/conversationId）；pinOperation 为 int（PIN=0/UNPIN=1）
                "msgId": msg_id,
                "convId": conversation_id,
                "pinOperation": {"MessagePinOperation.Pin": 0, "MessagePinOperation.Unpin": 1}.get(operation, operation),
                "pinInfo": {"operatorId": operator_id},
            },
        },
        ignore_keys={"timestamp", "pinTime"},
    )


def _wait_conversation_on_server(device, *, conv_id: str, timeout: float = 60.0) -> dict:
    seen_responses = []
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        resp = device.call("ChatManager", Cmd.loadAllConversations.value, info={})
        seen_responses.append(resp)
        result = resp.get("result")
        if isinstance(result, list):
            match = next((item for item in result if isinstance(item, dict) and item.get("convId") == conv_id), None)
            if match is not None:
                return match
        time.sleep(2.0)
    raise AssertionError(f"服务端会话列表未出现目标会话: convId={conv_id}, responses={seen_responses}")


def test_chat_manager_pin_unpin_and_fetch_pinned_messages(device_a, device_b, assert_api, user_a, user_b):
    """pinMessage/unpinMessage/fetchPinnedMessages：发送消息后置顶、拉取置顶列表、取消置顶并确认列表清空。"""
    with _allure_step("验证：pinMessage/unpinMessage/fetchPinnedMessages：发送消息后置顶、拉取置顶列表、取消置顶并确认列表清空。"):
        content = f"chat-pin-msg-{uuid.uuid4().hex[:8]}"
        msg_id = _send_text_and_receive(device_a, device_b, assert_api, user_a, user_b, content)

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
        pin_evt_b = _wait_pin_changed(device_b, msg_id=msg_id, operation="MessagePinOperation.Pin")
        _assert_pin_changed(assert_api, pin_evt_b, msg_id=msg_id, conversation_id=user_a, operation="MessagePinOperation.Pin", operator_id=user_a)
        _assert_no_pin_changed(device_a, msg_id=msg_id, operation="MessagePinOperation.Pin")

        resp_fetch = device_a.call("ChatManager", Cmd.fetchPinnedMessages.value, info={"convId": user_b})
        target_pinned = [
            message for message in (resp_fetch.get("result") or [])
            if isinstance(message, dict) and str(message.get("msgId")) == str(msg_id)
        ]
        assert_api.assert_response_matches(
            {**resp_fetch, "result": target_pinned},
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.fetchPinnedMessages.value,
                "device": "deviceA",
                "result": [
                    {
                        "msgId": msg_id,
                        "from": user_a,
                        "to": user_b,
                        "convId": user_b,
                        "chatType": 0,
                        "direction": 0,
                        "status": 2,
                        "hasRead": True,
                        "needReadReceipt": False, "isThread": False,
                        "isContentReplaced": False,
                        "body": {"targetLanguages": [], "translations": {}, "type": 0, "content": content},
                    }
                ],
            },
            ignore_keys={"sequence", "serverTime", "localTime", "broadcast", "onlineState", "deliverOnlineOnly", "receiverList"},
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
        unpin_evt_b = _wait_pin_changed(device_b, msg_id=msg_id, operation="MessagePinOperation.Unpin")
        _assert_pin_changed(assert_api, unpin_evt_b, msg_id=msg_id, conversation_id=user_a, operation="MessagePinOperation.Unpin", operator_id=user_a)
        _assert_no_pin_changed(device_a, msg_id=msg_id, operation="MessagePinOperation.Unpin")

        resp_fetch_empty = device_a.call("ChatManager", Cmd.fetchPinnedMessages.value, info={"convId": user_b})
        target_after_unpin = [
            message for message in (resp_fetch_empty.get("result") or [])
            if isinstance(message, dict) and str(message.get("msgId")) == str(msg_id)
        ]
        assert_api.assert_response_matches(
            {**resp_fetch_empty, "result": target_after_unpin},
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.fetchPinnedMessages.value,
                "device": "deviceA",
                "result": [],
            },
            ignore_keys={"sequence"},
        )


@pytest.mark.topology("account_a_to_account_b")
def test_chat_manager_recall_message_receiver_recalled_info_event(topology, assert_api):
    """recallMessage：发送方撤回已送达单聊消息，接收账号全部在线端收到 onMessagesRecalledInfo 并携带撤回消息 ID。"""
    sender = topology.sender_action_device
    recipients = topology.recipient_devices
    sender_user = topology.sender_user
    recipient_user = topology.recipient_user
    content = f"chat-recall-event-{uuid.uuid4().hex[:8]}"
    with _allure_step(f"{sender.device_name} 发送待撤回文本消息"):
        msg_id = _send_text_and_receive(sender, recipients[0], assert_api, sender_user, recipient_user, content)
    time.sleep(float(os.getenv("CHAT_RECALL_SETTLE_SECONDS", "5")))

    with _allure_step(f"{sender.device_name} 撤回该消息（recallMessage）"):
        resp = sender.call("ChatManager", Cmd.recallMessage.value, info={"msgId": msg_id})
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.recallMessage.value,
            "device": sender.device_name,
            "result": True,
        },
        ignore_keys={"sequence"},
    )

    for recipient in recipients:
        with _allure_step(f"接收账号端 {recipient.device_name} 收到撤回通知（onMessagesRecalledInfo）"):
            evt = recipient.receive_message(match_event_type=Cmd.onMessagesRecalledInfo.value, timeout=20.0)
            assert_api.assert_response_matches(
                evt,
                expected={
                    "type": "event",
                    "eventType": Cmd.onMessagesRecalledInfo.value,
                    "data": {
                        "infos": [
                            {
                                "recallBy": sender_user,
                                "recallMsgId": msg_id,
                                "convId": sender_user,
                                "msg": {
                                    "msgId": msg_id,
                                    "from": sender_user,
                                    "to": recipient_user,
                                    "convId": sender_user,
                                    "chatType": 0,
                                    "direction": 1,
                                    "status": 2,
                                    "hasRead": False,
                                    "needReadReceipt": False, "isThread": False,
                                    "isContentReplaced": False,
                                    "deliverOnlineOnly": False,
                                    "body": {"type": 0, "content": content},
                                },
                                "ext": "",
                            },
                        ],
                    },
                },
                ignore_keys={"timestamp", "serverTime", "localTime", "translations", "receiverList"},
            )


def test_chat_manager_send_to_non_friend_current_success_event(device_a, assert_api, user_a, user_c):
    """sendMessage：向 user_c 发送单聊消息，按当前真实返回冻结为成功回调。"""
    with _allure_step("验证：sendMessage：向 user_c 发送单聊消息，按当前真实返回冻结为成功回调。"):
        try:
            device_a.drain_events()
        except Exception:
            pass

        content = f"chat-error-non-friend-{uuid.uuid4().hex[:8]}"
        resp = device_a.call("ChatManager", Cmd.sendMessage.value, info=build_text(user_a, user_c, content))
        temp_id = ((resp.get("result") or {}).get("msgId"))
        assert temp_id, f"sendMessage 未返回临时 msgId: {resp}"
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.sendMessage.value,
                "device": "deviceA",
                "result": {
                    "msgId": temp_id,
                    "from": user_a,
                    "to": user_c,
                    "convId": user_c,
                    "chatType": 0,
                    "direction": 0,
                    "hasRead": True,
                    "needReadReceipt": False, "isThread": False,
                    "isContentReplaced": False,
                    "broadcast": False,
                    "onlineState": True,
                    "body": {"targetLanguages": [], "translations": {}, "type": 0, "content": content},
                },
            },
            ignore_keys={"sequence", "serverTime", "localTime", "deliverOnlineOnly"},
        )

        evt = _wait_message_success_for_content(device_a, content=content, to=user_c, timeout=20.0)
        real_id = (((evt.get("data") or {}).get("msg") or {}).get("msgId")) or temp_id
        assert_api.assert_response_matches(
            evt,
            expected={
                "type": "event",
                "eventType": Cmd.onMessageSuccess.value,
                "data": {
                    "msgId": temp_id,
                    "msg": {
                        "msgId": real_id,
                        "from": user_a,
                        "to": user_c,
                        "convId": user_c,
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
            ignore_keys={"timestamp", "serverTime", "localTime"},
        )


def test_chat_manager_conversation_marks_and_fetch_options(device_a, device_b, assert_api, user_a, user_b):
    """addRemoteAndLocalConversationsMark/deleteRemoteAndLocalConversationsMark/fetchConversationsByOptions：添加会话标记后按 options 查询，再移除标记。"""
    with _allure_step("验证：addRemoteAndLocalConversationsMark/deleteRemoteAndLocalConversationsMark/fetchConversationsByOptions：添加会话标记后按 options"):
        _send_text_and_receive(device_a, device_b, assert_api, user_a, user_b, f"chat-mark-{uuid.uuid4().hex[:8]}")
        _wait_conversation_on_server(device_a, conv_id=user_b)

        resp_add = device_a.call(
            "ChatManager",
            Cmd.addRemoteAndLocalConversationsMark.value,
            info={"convIds": [user_b], "mark": 0},
        )
        assert_api.assert_response_matches(
            resp_add,
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.addRemoteAndLocalConversationsMark.value,
                "device": "deviceA",
                "result": None,
            },
            ignore_keys={"sequence"},
        )

        fetch_info = {"mark": 0, "pageSize": 10, "cursor": "", "pinned": False}
        resp_fetch_marked = None
        deadline = time.monotonic() + 30.0
        while time.monotonic() < deadline:
            resp_fetch_marked = device_a.call("ChatManager", Cmd.loadAllConversations.value, info=fetch_info)
            # 5.0 fetchConversationsByOptions 返回纯 list（无 {list, cursor} dict）
            marked_list = resp_fetch_marked.get("result") or []
            if any(isinstance(item, dict) and item.get("convId") == user_b and 0 in (item.get("marks") or []) for item in marked_list):
                break
            time.sleep(2.0)
        assert resp_fetch_marked is not None
        # 5.0 fetchConversationsByOptions 返回全部会话（不按 mark 过滤）→ 过滤出目标会话再断言
        marked_target = [
            item for item in (resp_fetch_marked.get("result") or [])
            if isinstance(item, dict) and item.get("convId") == user_b
        ]
        assert_api.assert_response_matches(
            {**resp_fetch_marked, "result": marked_target},
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.loadAllConversations.value,
                "device": "deviceA",
                "result": [
                    {
                        "convId": user_b,
                        "type": 0,
                        "isThread": False,
                        "isPinned": False,
                        "pinnedTime": 0,
                        "marks": [0],
                    }
                ],
            },
            ignore_keys={"sequence", "ext"},
        )

        resp_delete = device_a.call(
            "ChatManager",
            Cmd.deleteRemoteAndLocalConversationsMark.value,
            info={"convIds": [user_b], "mark": 0},
        )
        assert_api.assert_response_matches(
            resp_delete,
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.deleteRemoteAndLocalConversationsMark.value,
                "device": "deviceA",
                "result": None,
            },
            ignore_keys={"sequence"},
        )


def test_chat_manager_message_count_and_search_options_boundaries(device_a, assert_api, user_a):
    """getMessageCount/searchMsgsByOptions：校验全量消息计数返回数值，以及 count=0 搜索边界返回空列表。
    前置清理本地残留消息（避免全量跑时前面 case 的数据影响 count=0 边界断言）。"""
    with _allure_step("验证：getMessageCount/searchMsgsByOptions：校验全量消息计数返回数值，以及 count=0 搜索边界返回空列表。"):
        device_a.call("ChatManager", Cmd.deleteAllMessageAndConversation.value, info={"clearServerData": False})
        resp_count = device_a.call("ChatManager", Cmd.getMessageCount.value, info={})
        assert_api.assert_response_matches(
            resp_count,
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.getMessageCount.value,
                "device": "deviceA",
                "result": ge(0),
            },
            ignore_keys={"sequence"},
        )

        resp_search = device_a.call(
            "ChatManager",
            Cmd.searchMsgsByOptions.value,
            info={"ts": -1, "count": 0, "direction": 0, "types": [0], "from": user_a},
        )
        assert_api.assert_response_matches(
            resp_search,
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.searchMsgsByOptions.value,
                "device": "deviceA",
                "result": [],
            },
            ignore_keys={"sequence"},
        )


def test_chat_manager_delete_all_message_and_conversation_local(device_a, device_b, assert_api, user_a, user_b):
    """deleteAllMessageAndConversation：本地清空所有会话与消息，冻结 clearServerData=False 当前返回。"""
    with _allure_step("验证：deleteAllMessageAndConversation：本地清空所有会话与消息，冻结 clearServerData=False 当前返回。"):
        _send_text_and_receive(device_a, device_b, assert_api, user_a, user_b, f"chat-clear-all-{uuid.uuid4().hex[:8]}")
        resp_delete = device_a.call(
            "ChatManager",
            Cmd.deleteAllMessageAndConversation.value,
            info={"clearServerData": False},
        )
        assert_api.assert_response_matches(
            resp_delete,
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.deleteAllMessageAndConversation.value,
                "device": "deviceA",
                "result": None,
            },
            ignore_keys={"sequence"},
        )


def test_chat_manager_message_object_boundary_methods(device_a, assert_api, user_a, user_b):
    """resendMessage/updateChatMessage/importMessages：使用本地构造消息对象覆盖重发、更新和导入的边界/当前返回。"""
    with _allure_step("验证：resendMessage/updateChatMessage/importMessages：使用本地构造消息对象覆盖重发、更新和导入的边界/当前返回。"):
        msg_id = f"chat-object-{uuid.uuid4().hex[:8]}"
        original_body = {"type": 0, "content": f"chat-object-{uuid.uuid4().hex[:8]}"}
        message = {
            "msgId": msg_id,
            "from": user_a,
            "to": user_b,
            "convId": user_b,
            "chatType": 0,
            "direction": 0,
            "status": 3,
            "hasRead": True,
            "needReadReceipt": False, "isThread": False,
            "deliverOnlineOnly": False,
            "body": original_body,
        }

        resp_import = device_a.call("ChatManager", Cmd.importMessages.value, info={"messages": [message]})
        assert_api.assert_response_matches(
            resp_import,
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.importMessages.value,
                "device": "deviceA",
                "result": True,
            },
            ignore_keys={"sequence"},
        )

        updated_body = {"type": 0, "content": f"chat-object-updated-{uuid.uuid4().hex[:8]}"}
        updated = {**message, "status": 2, "body": updated_body}
        resp_update = device_a.call("ChatManager", Cmd.updateChatMessage.value, info={"message": updated})
        assert_api.assert_response_matches(
            resp_update,
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.updateChatMessage.value,
                "device": "deviceA",
                "result": {
                    "msgId": msg_id,
                    "from": user_a,
                    "to": user_b,
                    "convId": user_b,
                    "chatType": 0,
                    "direction": 0,
                    "body": updated_body,
                },
            },
            ignore_keys={
                "sequence",
                "serverTime",
                "localTime",
                "status",
                "hasRead",
                "hasDeliverAck",
                "isThread",
                "isContentReplaced",
                "broadcast",
                "onlineState",
                "deliverOnlineOnly",
                "targetLanguages",
                "translations",
            },
        )

        resp_resend = device_a.call("ChatManager", Cmd.resendMessage.value, info=message)
        assert_api.assert_response_matches(
            resp_resend,
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.resendMessage.value,
                "device": "deviceA",
                "result": {
                    "msgId": msg_id,
                    "from": user_a,
                    "to": user_b,
                    "convId": user_b,
                    "chatType": 0,
                    "direction": 0,
                    "body": updated_body,
                },
            },
            ignore_keys={
                "sequence",
                "serverTime",
                "localTime",
                "status",
                "hasRead",
                "hasDeliverAck",
                "isThread",
                "isContentReplaced",
                "broadcast",
                "onlineState",
                "deliverOnlineOnly",
                "targetLanguages",
                "translations",
            },
        )
