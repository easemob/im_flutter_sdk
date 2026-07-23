from __future__ import annotations

import time
import uuid

import pytest

from src import Cmd, ne
from tests.chat._utils import build_text
from tests.group.group_helpers import create_group, destroy_group, new_group_name


pytestmark = [pytest.mark.client, pytest.mark.group, pytest.mark.multi_device, pytest.mark.agorachat1_4_0]


def _find_msg_with_id(messages: list, msg_id: str) -> dict | None:
    for item in messages:
        if isinstance(item, dict) and str(item.get("msgId")) == str(msg_id):
            return item
    return None


def test_chat_thread_remove_member_updates_member_list(device_a, device_b, assert_api, user_a, user_b):
    """
    链路：
    1) A 建群并邀请 B
    2) B 在群里发父消息
    3) A 用父消息创建子区并让 B 加入
    4) A 把 B 从子区移除
    5) 查询子区成员，断言 A 仍在且 B 已被移除

    当前 Android 实测 removeMemberFromChatThread 成功后不派发
    onUserKickOutOfChatThread，因此按 SDK 可查询的真实成员状态验收移除结果。
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
        parent_success_msg = ((evt_success_b.get("data") or {}).get("msg") or {})
        parent_msg_id = parent_success_msg.get("msgId")
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
        assert_api.assert_response_matches(
            {"type": "event", "eventType": Cmd.onMessageSuccess.value, "data": {"messages": [parent_success_msg]}},
            expected={
                "type": "event",
                "eventType": Cmd.onMessageSuccess.value,
                "data": {
                    "messages": [
                        {
                            "msgId": "{{parentMsgId}}",
                            "from": "{{userB}}",
                            "to": "{{groupId}}",
                            "convId": "{{groupId}}",
                            "chatType": 1,
                            "direction": 0,
                            "status": 2,
                            "hasRead": True,
                            "hasReadAck": False,
                            "hasDeliverAck": False,
                            "needGroupAck": False,
                            "isThread": False,
                            "isContentReplaced": False,
                            "deliverOnlineOnly": False,
                            "body": {"type": 0, "content": "{{content}}", "translations": {}},
                        }
                    ]
                },
            },
            context={"groupId": group_id, "parentMsgId": parent_msg_id, "userB": user_b, "content": content},
            ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "broadcast", "onlineState",
                         "targetLanguages", "receiverList", "groupAckCount"},
        )

        evt_group_recv = device_a.receive_message(match_event_type=Cmd.onMessagesReceived.value, timeout=20.0)
        messages = ((evt_group_recv.get("data") or {}).get("messages") or [])
        matched = _find_msg_with_id(messages, parent_msg_id)
        assert matched is not None, f"A 端未收到父消息: targetMsgId={parent_msg_id}, evt={evt_group_recv}"
        assert_api.assert_response_matches(
            {"type": "event", "eventType": Cmd.onMessagesReceived.value, "data": {"messages": [matched]}},
            expected={
                "type": "event",
                "eventType": Cmd.onMessagesReceived.value,
                "data": {
                    "messages": [
                        {
                            "msgId": "{{parentMsgId}}",
                            "from": "{{userB}}",
                            "to": "{{groupId}}",
                            "convId": "{{groupId}}",
                            "chatType": 1,
                            "direction": 1,
                            "status": 2,
                            "hasRead": False,
                            "hasReadAck": False,
                            "hasDeliverAck": False,
                            "needGroupAck": False,
                            "isThread": False,
                            "isContentReplaced": False,
                            "deliverOnlineOnly": False,
                            "body": {"type": 0, "content": "{{content}}", "translations": {}},
                        }
                    ]
                },
            },
            context={"groupId": group_id, "parentMsgId": parent_msg_id, "userB": user_b, "content": content},
            ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "broadcast", "onlineState",
                         "targetLanguages", "receiverList", "groupAckCount"},
        )

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

        members_before = device_a.call(
            "ChatThreadManager",
            Cmd.fetchChatThreadMember.value,
            info={"threadId": thread_id, "cursor": "", "pageSize": 20},
        )
        assert_api.assert_response_matches(
            members_before,
            expected={
                "manager": "ChatThreadManager",
                "cmd": Cmd.fetchChatThreadMember.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )
        members_before_result = members_before.get("result") or {}
        before_list = members_before_result.get("list") or []
        assert isinstance(members_before_result.get("cursor"), str), f"加入后成员游标类型异常: {members_before}"
        assert user_a in before_list, f"加入后成员列表缺少 owner: {members_before}"
        assert user_b in before_list, f"joinChatThread 成功后成员列表缺少 B: {members_before}"

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

        members_after = None
        after_list = []
        deadline = time.monotonic() + 20.0
        while time.monotonic() < deadline:
            members_after = device_a.call(
                "ChatThreadManager",
                Cmd.fetchChatThreadMember.value,
                info={"threadId": thread_id, "cursor": "", "pageSize": 20},
            )
            members_after_result = members_after.get("result") or {}
            after_list = members_after_result.get("list") or []
            if user_a in after_list and user_b not in after_list:
                break
            time.sleep(1)

        assert members_after is not None
        assert_api.assert_response_matches(
            members_after,
            expected={
                "manager": "ChatThreadManager",
                "cmd": Cmd.fetchChatThreadMember.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )
        members_after_result = members_after.get("result") or {}
        assert isinstance(members_after_result.get("cursor"), str), f"移除后成员游标类型异常: {members_after}"
        assert user_a in after_list, f"移除 B 后成员列表缺少 owner: {members_after}"
        assert user_b not in after_list, f"removeMemberFromChatThread 成功后 B 仍在成员列表: {members_after}"

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
