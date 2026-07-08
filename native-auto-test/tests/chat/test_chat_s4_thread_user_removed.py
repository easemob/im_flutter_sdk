from __future__ import annotations

import time
import uuid

import pytest

from src import Cmd, ne
from tests.chat._utils import build_text
from tests.group.group_helpers import create_group, destroy_group, new_group_name


pytestmark = [pytest.mark.client, pytest.mark.chat, pytest.mark.group, pytest.mark.multi_device, pytest.mark.agorachat1_4_0]


pytestmark.append(pytest.mark.xfail(
    reason="当前 Android 实测 removeMemberFromChatThread 成功后未派发 onUserKickOutOfChatThread，待 SDK/服务端确认。",
    strict=True,
))


def _find_msg_with_id(messages: list, msg_id: str) -> dict | None:
    for item in messages:
        if isinstance(item, dict) and str(item.get("msgId")) == str(msg_id):
            return item
    return None


def test_chat_thread_user_removed_event_type_not_null(device_a, device_b, assert_api, user_a, user_b):
    """
    覆盖发版项：
    - v4.15.0 修复：onChatThreadUserRemoved 的 TYPE 为 null 问题

    链路：
    1) A 建群并邀请 B
    2) B 在群里发父消息
    3) A 用父消息创建子区并让 B 加入
    4) A 把 B 从子区移除
    5) B 收到 onUserKickOutOfChatThread，断言 event.type 非空且可用
    """
    group_id = ""
    thread_id = ""
    parent_msg_id = ""
    try:
        try:
            device_a.drain_events()
            device_b.drain_events()
        except Exception:
            pass

        group_name = new_group_name("thread_remove")
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b],
        )

        content = f"thread-parent-{uuid.uuid4().hex[:6]}"
        resp_parent = device_b.call(
            "ChatManager",
            Cmd.sendMessage.value,
            info=build_text(user_b, group_id, content, chat_type=1),
        )
        send_temp_id = ((resp_parent.get("result") or {}).get("msgId"))
        evt_success_b = device_b.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
        parent_msg_id = ((evt_success_b.get("data") or {}).get("msg") or {}).get("msgId")
        assert isinstance(parent_msg_id, str) and parent_msg_id, f"未拿到群父消息 msgId: {evt_success_b}"

        assert_api.assert_response_matches(
            resp_parent,
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.sendMessage.value,
                "device": "deviceB",
                "result": {
                    "msgId": "{{tempId}}",
                    "from": "{{userB}}",
                    "to": "{{groupId}}",
                    "convId": "{{groupId}}",
                    "chatType": 1,
                    "direction": 0,
                    "status": 0,
                    "hasRead": True,
                    "hasReadAck": False,
                    "hasDeliverAck": False,
                    "needGroupAck": False,
                    "isThread": False,
                    "isContentReplaced": False,
                    "body": {
                        "type": 0,
                        "content": "{{content}}",
                    },
                },
            },
            context={"groupId": group_id, "tempId": send_temp_id, "userB": user_b, "content": content},
            ignore_keys={
                "sequence",
                "serverTime",
                "localTime",
                "broadcast",
                "onlineState",
                "targetLanguages",
                "translations",
                "receiverList",
                "groupAckCount",
                "deliverOnlineOnly",
            },
        )

        evt_group_recv = device_a.receive_message(match_event_type=Cmd.onMessagesReceived.value, timeout=20.0)
        assert_api.assert_response_matches(
            evt_group_recv,
            expected={"type": "event", "eventType": Cmd.onMessagesReceived.value},
            ignore_keys={"timestamp", "sequence", "data"},
        )
        messages = ((evt_group_recv.get("data") or {}).get("messages") or [])
        matched = _find_msg_with_id(messages, parent_msg_id)
        assert matched is not None, f"A 端未收到父消息: targetMsgId={parent_msg_id}, evt={evt_group_recv}"

        thread_name = f"thr-{uuid.uuid4().hex[:8]}"
        resp_create_thread = device_a.call(
            "ChatThreadManager",
            Cmd.createChatThread.value,
            info={
                "name": thread_name,
                "msgId": parent_msg_id,
                "parentId": group_id,
            },
        )
        thread_result = resp_create_thread.get("result") or {}
        thread_id = thread_result.get("threadId")
        assert isinstance(thread_id, str) and thread_id, f"createChatThread 未返回 threadId: {resp_create_thread}"
        assert_api.assert_response_matches(
            resp_create_thread,
            expected={
                "manager": "ChatThreadManager",
                "cmd": Cmd.createChatThread.value,
                "device": "deviceA",
                "result": {
                    "threadId": "{{threadId}}",
                    "threadName": "{{threadName}}",
                    "owner": "{{userA}}",
                    "parentId": "{{groupId}}",
                    "msgId": "{{parentMsgId}}",
                    "createAt": ne(None),
                },
            },
            context={
                "threadId": thread_id,
                "threadName": thread_name,
                "groupId": group_id,
                "parentMsgId": parent_msg_id,
                "userA": user_a,
                "userB": user_b,
                "content": content,
            },
            ignore_keys={
                "sequence",
                "serverTime",
                "localTime",
                "broadcast",
                "onlineState",
                "targetLanguages",
                "translations",
                "memberCount",
                "messageCount",
            },
        )

        resp_join = device_b.call(
            "ChatThreadManager",
            Cmd.joinChatThread.value,
            info={"threadId": thread_id},
        )
        assert_api.assert_response_matches(
            resp_join,
            expected={
                "manager": "ChatThreadManager",
                "cmd": Cmd.joinChatThread.value,
                "device": "deviceB",
                "result": {
                    "threadId": "{{threadId}}",
                    "threadName": "{{threadName}}",
                    "owner": "{{userA}}",
                    "parentId": "{{groupId}}",
                    "msgId": "{{parentMsgId}}",
                    "createAt": ne(None),
                },
            },
            context={
                "threadId": thread_id,
                "threadName": thread_name,
                "groupId": group_id,
                "parentMsgId": parent_msg_id,
                "userA": user_a,
                "content": content,
            },
            ignore_keys={
                "sequence",
                "serverTime",
                "localTime",
                "broadcast",
                "onlineState",
                "targetLanguages",
                "translations",
                "memberCount",
                "messageCount",
            },
        )

        time.sleep(1)
        resp_remove = device_a.call(
            "ChatThreadManager",
            Cmd.removeMemberFromChatThread.value,
            info={"memberId": user_b, "threadId": thread_id},
        )
        assert_api.assert_response_matches(
            resp_remove,
            expected={
                "manager": "ChatThreadManager",
                "cmd": Cmd.removeMemberFromChatThread.value,
                "device": "deviceA",
                "result": True,
            },
            ignore_keys={"sequence"},
        )

        evt_removed = device_b.receive_message(match_event_type=Cmd.onUserKickOutOfChatThread.value, timeout=20.0)
        if evt_removed is None:
            evt_removed = device_a.receive_message(match_event_type=Cmd.onUserKickOutOfChatThread.value, timeout=5.0)
        assert evt_removed is not None, (
            "未收到 onUserKickOutOfChatThread 回调，无法验证 event.type 非空；"
            f"threadId={thread_id}, groupId={group_id}"
        )
        assert_api.assert_response_matches(
            evt_removed,
            expected={
                "type": "event",
                "eventType": Cmd.onUserKickOutOfChatThread.value,
                "data": {
                    "event": {
                        "type": ne(None),
                        "from": "{{operatorId}}",
                        "thread": {
                            "threadId": "{{threadId}}",
                            "threadName": "{{threadName}}",
                            "owner": "{{userA}}",
                            "parentId": "{{groupId}}",
                            "msgId": "{{parentMsgId}}",
                            "createAt": ne(None),
                            "lastMessage": {
                                "msgId": "{{parentMsgId}}",
                                "from": "{{userB}}",
                                "to": "{{groupId}}",
                                "convId": "{{groupId}}",
                                "chatType": 1,
                                "direction": 0,
                                "status": 0,
                                "hasRead": True,
                                "hasReadAck": False,
                                "hasDeliverAck": False,
                                "needGroupAck": False,
                                "isThread": False,
                                "isContentReplaced": False,
                                "deliverOnlineOnly": False,
                                "body": {
                                    "type": 0,
                                    "content": "{{content}}",
                                },
                            },
                        },
                    },
                },
            },
            context={
                "operatorId": user_a,
                "threadId": thread_id,
                "threadName": thread_name,
                "groupId": group_id,
                "parentMsgId": parent_msg_id,
                "userA": user_a,
                "userB": user_b,
                "content": content,
            },
            ignore_keys={
                "timestamp",
                "sequence",
                "serverTime",
                "localTime",
                "broadcast",
                "onlineState",
                "targetLanguages",
                "translations",
                "memberCount",
                "messageCount",
                "lastMessage",
            },
        )

        evt_data = (evt_removed.get("data") or {}).get("event") or {}
        event_type_value = evt_data.get("type")
        assert isinstance(event_type_value, int), f"onUserKickOutOfChatThread.event.type 不是 int: {evt_removed}"
        assert event_type_value >= 0, f"onUserKickOutOfChatThread.event.type 非法: {evt_removed}"

    finally:
        if thread_id:
            resp_destroy_thread = device_a.call(
                "ChatThreadManager",
                Cmd.destroyChatThread.value,
                info={"threadId": thread_id},
            )
            if not (isinstance((resp_destroy_thread.get("result")), bool) and resp_destroy_thread.get("result") is True):
                # 避免清理失败阻断主断言结论
                assert_api.assert_response_matches(
                    resp_destroy_thread,
                    expected={
                        "manager": "ChatThreadManager",
                        "cmd": Cmd.destroyChatThread.value,
                        "device": "deviceA",
                    },
                    ignore_keys={"sequence", "result", "error"},
                )
        if group_id:
            destroy_group(device_a, assert_api, group_id, device_b=device_b)
