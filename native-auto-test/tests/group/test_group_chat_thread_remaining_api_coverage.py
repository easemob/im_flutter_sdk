"""
群组 ChatThread 剩余 API 覆盖用例。

本文件补充 ChatThreadManager 的查询、更新、离开类方法覆盖。前置链路统一为：
A 建群并邀请 B、B 发送群父消息、A 基于父消息创建子区、B 加入子区。
"""
from __future__ import annotations

import uuid
import time

from contextlib import nullcontext

import pytest

from src import Cmd


def _allure_step(name: str):
    try:
        import allure

        return allure.step(name)
    except ImportError:
        return nullcontext()
from tests.chat._utils import build_text
from tests.group.group_helpers import create_group, destroy_group, new_group_name


pytestmark = [pytest.mark.client, pytest.mark.group, pytest.mark.multi_device]


def _find_msg_with_id(messages: list, msg_id: str) -> dict | None:
    for item in messages:
        if isinstance(item, dict) and str(item.get("msgId")) == str(msg_id):
            return item
    return None


def _wait_chat_thread_event(device, event_type: str, thread_id: str, *, timeout: float = 20.0) -> dict:
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        evt = device.receive_message(
            match_event_type=event_type,
            timeout=min(2.0, max(0.1, deadline - time.monotonic())),
        )
        if evt:
            seen.append(evt)
        thread = ((((evt or {}).get("data") or {}).get("event") or {}).get("thread") or {})
        if isinstance(thread, dict) and str(thread.get("threadId")) == str(thread_id):
            return evt
    pytest.fail(f"未收到目标 thread 事件: event={event_type}, threadId={thread_id}, events={seen}")


def _assert_thread_lifecycle_event(
    assert_api,
    evt: dict,
    *,
    event_type: str,
    type_value: int,
    from_user: str,
    thread_id: str,
    thread_name: str,
    group_id: str,
    parent_msg_id: str,
    create_at,
) -> None:
    assert_api.assert_response_matches(
        evt,
        expected={
            "type": "event",
            "eventType": event_type,
            "data": {
                "event": {
                    "type": type_value,
                    "from": from_user,
                    "thread": {
                        "threadId": thread_id,
                        "threadName": thread_name,
                        "owner": "",
                        "parentId": group_id,
                        "msgId": parent_msg_id,
                        "memberCount": 0,
                        "messageCount": 0,
                        "createAt": create_at,
                    },
                },
            },
        },
        ignore_keys={"timestamp"},
    )


def _create_thread_context(device_a, device_b, assert_api, user_a: str, user_b: str):
    group_id = ""
    thread_id = ""
    try:
        device_a.drain_events()
        device_b.drain_events()
    except Exception:
        pass

    last_group_error: AssertionError | None = None
    for attempt in range(2):
        try:
            group_id, _ = create_group(
                device_a,
                assert_api,
                owner=user_a,
                group_name=new_group_name("thread_api"),
                invite_members=[user_b],
            )
            break
        except AssertionError as exc:
            last_group_error = exc
            if "Server is unreachable" not in str(exc) or attempt == 1:
                raise
            time.sleep(1)
    if not group_id and last_group_error is not None:
        raise last_group_error

    thread_name = f"thr-{uuid.uuid4().hex[:8]}"
    content = ""
    parent_msg_id = ""
    resp_create = {}
    for attempt in range(2):
        content = f"thread-parent-{uuid.uuid4().hex[:8]}"
        resp_parent = device_b.call(
            "ChatManager",
            Cmd.sendMessage.value,
            info=build_text(user_b, group_id, content, chat_type=1),
        )
        assert_api.assert_response_matches(
            resp_parent,
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.sendMessage.value,
                "device": "deviceB",
            },
            ignore_keys={"sequence", "result"},
        )
        evt_success = device_b.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
        parent_msg_id = ((evt_success or {}).get("data") or {}).get("msg", {}).get("msgId")
        assert isinstance(parent_msg_id, str) and parent_msg_id, f"未拿到群父消息 msgId: {evt_success}"
        assert_api.assert_response_matches(
            evt_success,
            expected={
                "type": "event",
                "eventType": Cmd.onMessageSuccess.value,
                "data": {
                    "msgId": resp_parent.get("result", {}).get("msgId"),
                    "msg": {
                        "msgId": parent_msg_id,
                        "from": user_b,
                        "to": group_id,
                        "convId": group_id,
                        "chatType": 1,
                        "direction": 0,
                        "status": 2,
                        "hasRead": True,
                        "needReadReceipt": False, "deliverOnlineOnly": False,
                        "isThread": False,
                        "isContentReplaced": False,
                        "body": {"type": 0, "content": content},
                    },
                },
            },
            ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "translations", "broadcast", "onlineState", "targetLanguages"},
        )

        evt_group_recv = device_a.receive_message(match_event_type=Cmd.onMessagesReceived.value, timeout=20.0)
        messages = ((evt_group_recv or {}).get("data") or {}).get("messages") or []
        parent_received = _find_msg_with_id(messages, parent_msg_id)
        assert parent_received is not None, (
            f"A 端未收到父消息: targetMsgId={parent_msg_id}, evt={evt_group_recv}"
        )
        assert_api.assert_response_matches(
            parent_received,
            expected={
                "msgId": parent_msg_id,
                "from": user_b,
                "to": group_id,
                "convId": group_id,
                "chatType": 1,
                "direction": 1,
                "status": 2,
                "hasRead": False,
                "needReadReceipt": False, "deliverOnlineOnly": False,
                "isThread": False,
                "isContentReplaced": False,
                "body": {"type": 0, "content": content},
            },
            ignore_keys={"timestamp", "sequence", "serverTime", "localTime", "translations", "receiverList"},
        )

        resp_create = device_a.call(
            "ChatThreadManager",
            Cmd.createChatThread.value,
            info={"name": thread_name, "msgId": parent_msg_id, "parentId": group_id},
        )
        thread = resp_create.get("result") or {}
        thread_id = thread.get("threadId") if isinstance(thread, dict) else None
        if isinstance(thread_id, str) and thread_id:
            break
        if attempt == 0:
            time.sleep(1)
    thread = resp_create.get("result") or {}
    thread_id = thread.get("threadId") if isinstance(thread, dict) else None
    if not isinstance(thread_id, str) or not thread_id:
        # 305 = thread not open：测试 appKey 服务端未开通子区（thread）功能 → 外部前置不满足
        if isinstance(thread, dict) and thread.get("code") == 305:
            pytest.skip("测试 appKey 服务端未开通子区（thread）功能（createChatThread 305 thread not open）")
        raise AssertionError(f"createChatThread 未返回 threadId: {resp_create}")
    assert_api.assert_response_matches(
        resp_create,
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
            "userA": user_a,
            "groupId": group_id,
            "parentMsgId": parent_msg_id,
        },
        ignore_keys={"sequence", "memberCount", "messageCount", "lastMessage"},
    )

    create_evt_a = _wait_chat_thread_event(device_a, Cmd.onChatThreadCreate.value, thread_id)
    _assert_thread_lifecycle_event(
        assert_api,
        create_evt_a,
        event_type=Cmd.onChatThreadCreate.value,
        type_value=1,
        from_user=user_a,
        thread_id=thread_id,
        thread_name=thread_name,
        group_id=group_id,
        parent_msg_id=parent_msg_id,
        create_at=ne(None),
    )
    create_evt_b = _wait_chat_thread_event(device_b, Cmd.onChatThreadCreate.value, thread_id)
    _assert_thread_lifecycle_event(
        assert_api,
        create_evt_b,
        event_type=Cmd.onChatThreadCreate.value,
        type_value=1,
        from_user=user_a,
        thread_id=thread_id,
        thread_name=thread_name,
        group_id=group_id,
        parent_msg_id=parent_msg_id,
        create_at=ne(None),
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
            "userA": user_a,
            "groupId": group_id,
            "parentMsgId": parent_msg_id,
        },
        ignore_keys={"sequence", "memberCount", "messageCount", "lastMessage"},
    )

    return {
        "group_id": group_id,
        "thread_id": thread_id,
        "thread_name": thread_name,
        "parent_msg_id": parent_msg_id,
        "content": content,
    }


def _cleanup_thread_context(device_a, device_b, assert_api, context: dict):
    thread_id = context.get("thread_id")
    group_id = context.get("group_id")
    if thread_id:
        resp_destroy = device_a.call(
            "ChatThreadManager",
            Cmd.destroyChatThread.value,
            info={"threadId": thread_id},
        )
        assert_api.assert_response_matches(
            resp_destroy,
            expected={
                "manager": "ChatThreadManager",
                "cmd": Cmd.destroyChatThread.value,
                "device": "deviceA",
                "result": True,
            },
            ignore_keys={"sequence"},
        )
    if group_id:
        destroy_group(device_a, assert_api, group_id, device_b=device_b)


def _assert_cursor_contains_thread(resp: dict, *, thread_id: str, cmd: str):
    assert resp.get("manager") == "ChatThreadManager"
    assert resp.get("cmd") == cmd
    result = resp.get("result")
    assert isinstance(result, dict), f"{cmd} result 应为 cursor dict: {resp}"
    items = result.get("list")
    assert isinstance(items, list), f"{cmd} result.list 应为 list: {resp}"
    assert any(isinstance(item, dict) and item.get("threadId") == thread_id for item in items), (
        f"{cmd} 未返回目标 threadId={thread_id}: {resp}"
    )


def test_chat_thread_fetch_detail_and_lists(device_a, device_b, assert_api, user_a, user_b):
    """fetchChatThreadDetail/getThreadConversation/joined/parent 列表：创建并加入子区后校验详情、线程会话和列表。"""
    context: dict = {}
    try:
        context = _create_thread_context(device_a, device_b, assert_api, user_a, user_b)
        thread_id = context["thread_id"]
        group_id = context["group_id"]

        detail_resp = device_a.call(
            "ChatThreadManager",
            Cmd.fetchChatThreadDetail.value,
            info={"threadId": thread_id},
        )
        assert_api.assert_response_matches(
            detail_resp,
            expected={
                "manager": "ChatThreadManager",
                "cmd": Cmd.fetchChatThreadDetail.value,
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
                "threadName": context["thread_name"],
                "userA": user_a,
                "groupId": group_id,
                "parentMsgId": context["parent_msg_id"],
            },
            ignore_keys={"sequence", "memberCount", "messageCount", "lastMessage"},
        )

        conversation_resp = device_a.call(
            "ChatManager",
            Cmd.getThreadConversation.value,
            info={"convId": thread_id},
        )
        assert_api.assert_response_matches(
            conversation_resp,
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.getThreadConversation.value,
                "device": "deviceA",
                "result": {
                    "convId": thread_id,
                    "type": 1,
                    "isThread": True,
                },
            },
            ignore_keys={
                "sequence",
                "ext",
                "isPinned",
                "pinnedTime",
                "marks",
                "latestMessage",
                "lastReceivedMessage",
            },
        )

        joined_resp = device_b.call(
            "ChatThreadManager",
            Cmd.fetchJoinedChatThreads.value,
            info={"cursor": "", "pageSize": 20},
        )
        assert_api.assert_response_matches(
            joined_resp,
            expected={
                "manager": "ChatThreadManager",
                "cmd": Cmd.fetchJoinedChatThreads.value,
                "device": "deviceB",
            },
            ignore_keys={"sequence", "result"},
        )
        _assert_cursor_contains_thread(
            joined_resp,
            thread_id=thread_id,
            cmd=Cmd.fetchJoinedChatThreads.value,
        )

        parent_resp = device_a.call(
            "ChatThreadManager",
            Cmd.fetchChatThreadsWithParentId.value,
            info={"parentId": group_id, "cursor": "", "pageSize": 20},
        )
        assert_api.assert_response_matches(
            parent_resp,
            expected={
                "manager": "ChatThreadManager",
                "cmd": Cmd.fetchChatThreadsWithParentId.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )
        _assert_cursor_contains_thread(
            parent_resp,
            thread_id=thread_id,
            cmd=Cmd.fetchChatThreadsWithParentId.value,
        )

        joined_parent_resp = device_b.call(
            "ChatThreadManager",
            Cmd.fetchJoinedChatThreadsWithParentId.value,
            info={"parentId": group_id, "cursor": "", "pageSize": 20},
        )
        assert_api.assert_response_matches(
            joined_parent_resp,
            expected={
                "manager": "ChatThreadManager",
                "cmd": Cmd.fetchJoinedChatThreadsWithParentId.value,
                "device": "deviceB",
            },
            ignore_keys={"sequence", "result"},
        )
        _assert_cursor_contains_thread(
            joined_parent_resp,
            thread_id=thread_id,
            cmd=Cmd.fetchJoinedChatThreadsWithParentId.value,
        )
    finally:
        _cleanup_thread_context(device_a, device_b, assert_api, context)


def test_chat_thread_fetch_members_and_latest_message(device_a, device_b, assert_api, user_a, user_b):
    """fetchChatThreadMember / fetchLastMessageWithChatThreads：成员列表包含 A/B，新建子区未发线程消息时最新消息映射为空。"""
    context: dict = {}
    try:
        context = _create_thread_context(device_a, device_b, assert_api, user_a, user_b)
        thread_id = context["thread_id"]

        members_resp = device_a.call(
            "ChatThreadManager",
            Cmd.fetchChatThreadMember.value,
            info={"threadId": thread_id, "cursor": "", "pageSize": 20},
        )
        assert_api.assert_response_matches(
            members_resp,
            expected={
                "manager": "ChatThreadManager",
                "cmd": Cmd.fetchChatThreadMember.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )
        members_result = members_resp.get("result") or {}
        members = members_result.get("list") or []
        assert user_a in members
        assert user_b in members

        latest_resp = device_a.call(
            "ChatThreadManager",
            Cmd.fetchLastMessageWithChatThreads.value,
            info={"threadIds": [thread_id]},
        )
        assert_api.assert_response_matches(
            latest_resp,
            expected={
                "manager": "ChatThreadManager",
                "cmd": Cmd.fetchLastMessageWithChatThreads.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )
        latest = latest_resp.get("result") or {}
        assert latest == {}, f"新建子区未发送线程内消息时最新消息映射应为空: {latest_resp}"
    finally:
        _cleanup_thread_context(device_a, device_b, assert_api, context)


@pytest.mark.topology("account_a_to_account_b")
def test_chat_thread_update_name_and_leave(device_a, device_b, assert_api, user_a, user_b, topology):
    """updateChatThreadSubject / leaveChatThread：更新子区名称后，收发账号全部在线端收到事件，B 退出子区。"""
    thread_devices = (*topology.sender_devices, *topology.recipient_devices)
    context: dict = {}
    try:
        context = _create_thread_context(device_a, device_b, assert_api, user_a, user_b)
        thread_id = context["thread_id"]
        group_id = context["group_id"]
        new_name = f"thr-new-{uuid.uuid4().hex[:6]}"

        update_resp = device_a.call(
            "ChatThreadManager",
            Cmd.updateChatThreadSubject.value,
            info={"threadId": thread_id, "name": new_name},
        )
        assert_api.assert_response_matches(
            update_resp,
            expected={
                "manager": "ChatThreadManager",
                "cmd": Cmd.updateChatThreadSubject.value,
                "device": "deviceA",
                "result": True,
            },
            ignore_keys={"sequence"},
        )

        with _allure_step("全部在线端验证收到子区事件"):
            update_evt = _wait_chat_thread_event(device, Cmd.onChatThreadUpdate.value, thread_id)
            _assert_thread_lifecycle_event(
                assert_api,
                update_evt,
                event_type=Cmd.onChatThreadUpdate.value,
                type_value=2,
                from_user=user_a,
                thread_id=thread_id,
                thread_name=new_name,
                group_id=group_id,
                parent_msg_id=context["parent_msg_id"],
                create_at=0,
            )


        detail_resp = device_a.call(
            "ChatThreadManager",
            Cmd.fetchChatThreadDetail.value,
            info={"threadId": thread_id},
        )
        assert_api.assert_response_matches(
            detail_resp,
            expected={
                "manager": "ChatThreadManager",
                "cmd": Cmd.fetchChatThreadDetail.value,
                "device": "deviceA",
                "result": {
                    "threadId": thread_id,
                    "threadName": new_name,
                    "parentId": group_id,
                },
            },
            ignore_keys={"sequence", "owner", "msgId", "createAt", "memberCount", "messageCount", "lastMessage"},
        )

        leave_resp = device_b.call(
            "ChatThreadManager",
            Cmd.leaveChatThread.value,
            info={"threadId": thread_id},
        )
        assert_api.assert_response_matches(
            leave_resp,
            expected={
                "manager": "ChatThreadManager",
                "cmd": Cmd.leaveChatThread.value,
                "device": "deviceB",
                "result": True,
            },
            ignore_keys={"sequence"},
        )

        joined_parent_resp = device_b.call(
            "ChatThreadManager",
            Cmd.fetchJoinedChatThreadsWithParentId.value,
            info={"parentId": group_id, "cursor": "", "pageSize": 20},
        )
        assert_api.assert_response_matches(
            joined_parent_resp,
            expected={
                "manager": "ChatThreadManager",
                "cmd": Cmd.fetchJoinedChatThreadsWithParentId.value,
                "device": "deviceB",
            },
            ignore_keys={"sequence", "result"},
        )
        items = (joined_parent_resp.get("result") or {}).get("list") or []
        assert not any(isinstance(item, dict) and item.get("threadId") == thread_id for item in items)
    finally:
        _cleanup_thread_context(device_a, device_b, assert_api, context)


@pytest.mark.topology("account_a_to_account_b")
def test_chat_thread_destroy_event_received_by_group_member(device_a, device_b, assert_api, user_a, user_b, topology):
    """destroyChatThread：子区创建后由 owner 解散，收发账号全部在线端收到 onChatThreadDestroy 事件。"""
    thread_devices = (*topology.sender_devices, *topology.recipient_devices)
    context: dict = {}
    try:
        context = _create_thread_context(device_a, device_b, assert_api, user_a, user_b)
        thread_id = context["thread_id"]

        destroy_resp = device_a.call(
            "ChatThreadManager",
            Cmd.destroyChatThread.value,
            info={"threadId": thread_id},
        )
        assert_api.assert_response_matches(
            destroy_resp,
            expected={
                "manager": "ChatThreadManager",
                "cmd": Cmd.destroyChatThread.value,
                "device": "deviceA",
                "result": True,
            },
            ignore_keys={"sequence"},
        )

        with _allure_step("全部在线端验证收到子区事件"):
            destroy_evt = _wait_chat_thread_event(device, Cmd.onChatThreadDestroy.value, thread_id)
            _assert_thread_lifecycle_event(
                assert_api,
                destroy_evt,
                event_type=Cmd.onChatThreadDestroy.value,
                type_value=3,
                from_user=user_a,
                thread_id=thread_id,
                thread_name=context["thread_name"],
                group_id=context["group_id"],
                parent_msg_id=context["parent_msg_id"],
                create_at=0,
            )

        context["thread_id"] = ""
    finally:
        _cleanup_thread_context(device_a, device_b, assert_api, context)
