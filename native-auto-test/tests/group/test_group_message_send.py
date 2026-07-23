from __future__ import annotations

import os
import time
import uuid

import pytest

from src import Cmd, GroupChangeEvent, ge
from tests.group.group_helpers import (
    assert_group_events,
    assert_group_snapshot,
    assert_no_group_event,
    collect_group_events,
    create_group,
    destroy_group,
    new_group_name,
)


pytestmark = [pytest.mark.client, pytest.mark.group, pytest.mark.agorachat1_4_0]


_MESSAGE_IGNORE_KEYS = {
    "timestamp",
    "sequence",
    "serverTime",
    "localTime",
    "broadcast",
    "onlineState",
    "targetLanguages",
    "translations",
    "receiverList",
    "fileSize",
    "localPath",
    "remotePath",
    "secret",
    "thumbnailLocalPath",
    "thumbnailRemotePath",
    "thumbnailSecret",
    "messageList",
}


def _drain_devices(device_a, device_b) -> None:
    device_a.drain_events()
    device_b.drain_events()


def _build_group_text(from_user: str, group_id: str, content: str, *, need_group_ack: bool = False) -> dict:
    return {
        "from": from_user,
        "to": group_id,
        "chatType": 1,
        "direction": 0,
        "body": {"type": 0, "content": content},
        "hasReadAck": False,
        "needGroupAck": need_group_ack,
        "isThread": False,
        "deliverOnlineOnly": False,
    }


def _payload_for(type_key: str, group_id: str) -> dict:
    suffix = uuid.uuid4().hex[:8]
    if type_key == "txt":
        return {"targetId": group_id, "content": f"group-txt-{suffix}"}
    if type_key == "file":
        return {"targetId": group_id}
    if type_key == "image":
        return {"targetId": group_id, "thumbnailLocalPath": ""}
    if type_key == "video":
        return {"targetId": group_id, "duration": 1, "thumbnailLocalPath": ""}
    if type_key == "voice":
        return {"targetId": group_id, "duration": 1}
    if type_key == "location":
        return {
            "targetId": group_id,
            "latitude": 30.2741,
            "longitude": 120.1551,
            "address": f"group-location-{suffix}",
            "buildingName": "group-message-building",
        }
    if type_key == "cmd":
        return {"targetId": group_id, "action": f"group-cmd-{suffix}", "deliverOnlineOnly": False}
    if type_key == "custom":
        return {
            "targetId": group_id,
            "event": f"group-custom-{suffix}",
            "params": {"source": "group-message", "value": suffix},
        }
    raise AssertionError(f"不支持的群消息类型: {type_key}")


def _body_expected(type_key: str, payload: dict, *, phase: str) -> dict:
    received = phase == "received"
    file_status = 0 if received and type_key == "voice" else 3
    if type_key == "txt":
        return {"type": 0, "content": payload["content"]}
    if type_key == "image":
        return {
            "type": 1,
            "displayName": "bigPic.jpg",
            "fileStatus": file_status,
            "thumbnailStatus": 0 if received else 3,
            "width": ge(0),
            "height": ge(0),
            "isGif": False,
            "sendOriginalImage": False,
        }
    if type_key == "video":
        return {
            "type": 2,
            "displayName": "video.mov",
            "fileStatus": file_status,
            "thumbnailStatus": 2 if received else 3,
            "width": ge(0),
            "height": ge(0),
            "duration": payload["duration"],
        }
    if type_key == "location":
        return {
            "type": 3,
            "latitude": payload["latitude"],
            "longitude": payload["longitude"],
            "address": payload["address"],
            "buildingName": payload["buildingName"],
        }
    if type_key == "voice":
        return {
            "type": 4,
            "displayName": "voice.mp3",
            "fileStatus": file_status,
            "duration": payload["duration"],
        }
    if type_key == "file":
        return {"type": 5, "displayName": "bigPic.jpg", "fileStatus": file_status}
    if type_key == "cmd":
        return {"type": 6, "action": payload["action"], "deliverOnlineOnly": False}
    if type_key == "custom":
        return {"type": 7, "event": payload["event"], "params": payload["params"]}
    if type_key == "combine":
        return {
            "type": 8,
            "title": payload["title"],
            "summary": payload["summary"],
            "compatibleText": payload["compatibleText"],
            "fileStatus": 1 if phase == "success" else 3,
        }
    raise AssertionError(f"不支持的群消息类型: {type_key}")


def _wait_success(device, *, temp_id: str, timeout: float = 60.0) -> dict:
    seen = []
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        evt = device.receive_message(
            match_event_type=Cmd.onMessageSuccess.value,
            timeout=min(2.0, max(0.1, deadline - time.monotonic())),
        )
        if evt:
            seen.append(evt)
        if str(((evt or {}).get("data") or {}).get("msgId")) == str(temp_id):
            return evt
    pytest.fail(f"A 端未收到目标 onMessageSuccess: tempId={temp_id}, events={seen}")


def _wait_received(device, *, event_type: str, real_id: str, timeout: float = 60.0) -> dict:
    seen = []
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        evt = device.receive_message(
            match_event_type=event_type,
            timeout=min(2.0, max(0.1, deadline - time.monotonic())),
        )
        if evt:
            seen.append(evt)
        messages = (((evt or {}).get("data") or {}).get("messages")) or []
        target = next(
            (msg for msg in messages if isinstance(msg, dict) and str(msg.get("msgId")) == str(real_id)),
            None,
        )
        if target is not None:
            return {
                "type": evt.get("type"),
                "eventType": evt.get("eventType"),
                "data": {"messages": [target]},
                "timestamp": evt.get("timestamp"),
            }
    pytest.fail(f"B 端未收到目标 {event_type}: realId={real_id}, events={seen}")


def _wait_send_terminal(device, *, temp_id: str, timeout: float = 30.0) -> tuple[str, dict]:
    seen = []
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        error_evt = device.receive_message(
            match_event_type=Cmd.onMessageError.value,
            timeout=min(1.0, max(0.1, deadline - time.monotonic())),
        )
        if error_evt:
            seen.append(error_evt)
        if str(((error_evt or {}).get("data") or {}).get("msgId")) == str(temp_id):
            return "error", error_evt
        success_evt = device.receive_message(
            match_event_type=Cmd.onMessageSuccess.value,
            timeout=min(1.0, max(0.1, deadline - time.monotonic())),
        )
        if success_evt:
            seen.append(success_evt)
        if str(((success_evt or {}).get("data") or {}).get("msgId")) == str(temp_id):
            return "success", success_evt
    pytest.fail(f"未收到群消息发送终态: tempId={temp_id}, events={seen}")


def _assert_peer_did_not_receive_group_text(
    device,
    *,
    from_user: str,
    group_id: str,
    content: str,
    timeout: float = 5.0,
) -> None:
    seen = []
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        evt = device.receive_message(
            match_event_type=Cmd.onMessagesReceived.value,
            timeout=min(1.0, max(0.1, deadline - time.monotonic())),
        )
        if evt:
            seen.append(evt)
        messages = (((evt or {}).get("data") or {}).get("messages")) or []
        target = next(
            (
                msg
                for msg in messages
                if isinstance(msg, dict)
                and msg.get("from") == from_user
                and msg.get("to") == group_id
                and ((msg.get("body") or {}).get("content")) == content
            ),
            None,
        )
        assert target is None, f"失败群消息被错误投递: message={target}, events={seen}"


def _send_group_text_expect_error(
    sender,
    observer,
    assert_api,
    *,
    sender_name: str,
    from_user: str,
    group_id: str,
    content: str,
    error_code: int,
    error_description: str,
    error_message_status: int,
) -> tuple[dict, dict]:
    sender.drain_events()
    observer.drain_events()
    resp = sender.call(
        "ChatManager",
        Cmd.sendMessageWithType.value,
        info={
            "type": "txt",
            "payload": {"targetId": group_id, "content": content},
            "chatType": 1,
        },
    )
    temp_id = ((resp.get("result") or {}).get("msgId"))
    assert temp_id, f"失败群消息未返回临时 msgId: groupId={group_id!r}, resp={resp}"
    terminal, terminal_evt = _wait_send_terminal(sender, temp_id=temp_id)
    assert terminal == "error", f"群消息未进入失败终态: groupId={group_id!r}, event={terminal_evt}"
    message = {
        "msgId": temp_id,
        "from": from_user,
        "to": group_id,
        "convId": group_id,
        "chatType": 1,
        "direction": 0,
        "hasRead": True,
        "hasReadAck": False,
        "hasDeliverAck": False,
        "needGroupAck": False,
        "isThread": False,
        "isContentReplaced": False,
        "deliverOnlineOnly": False,
        "body": {"type": 0, "content": content},
    }
    ignore_keys = {
        "timestamp",
        "sequence",
        "serverTime",
        "localTime",
        "broadcast",
        "onlineState",
        "targetLanguages",
        "translations",
    }
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.sendMessageWithType.value,
            "device": sender_name,
            "result": {**message, "status": 1},
        },
        ignore_keys=ignore_keys,
    )
    assert_api.assert_response_matches(
        terminal_evt,
        expected={
            "type": "event",
            "eventType": Cmd.onMessageError.value,
            "data": {
                "msgId": temp_id,
                "msg": {**message, "status": error_message_status},
                "error": {"code": error_code, "description": error_description},
            },
        },
        ignore_keys=ignore_keys,
    )
    _assert_peer_did_not_receive_group_text(
        observer,
        from_user=from_user,
        group_id=group_id,
        content=content,
    )
    return resp, terminal_evt


def _assert_group_message(
    assert_api,
    actual: dict,
    *,
    type_key: str,
    payload: dict,
    user_a: str,
    group_id: str,
    temp_id: str,
    real_id: str,
    phase: str,
) -> None:
    body = _body_expected(type_key, payload, phase=phase)
    message = {
        "msgId": real_id if phase != "response" else temp_id,
        "from": user_a,
        "to": group_id,
        "convId": group_id,
        "chatType": 1,
        "direction": 1 if phase == "received" else 0,
        "status": 2 if phase != "response" else 1,
        "hasRead": phase != "received",
        "hasReadAck": False,
        "hasDeliverAck": False,
        "needGroupAck": False,
        "isThread": False,
        "isContentReplaced": False,
        "deliverOnlineOnly": False,
        "body": body,
    }
    if phase == "response":
        expected = {
            "manager": "ChatManager",
            "cmd": Cmd.sendMessageWithType.value,
            "device": "deviceA",
            "result": message,
        }
    elif phase == "success":
        expected = {
            "type": "event",
            "eventType": Cmd.onMessageSuccess.value,
            "data": {"msgId": temp_id, "msg": message},
        }
    else:
        expected = {
            "type": "event",
            "eventType": Cmd.onCmdMessagesReceived.value if type_key == "cmd" else Cmd.onMessagesReceived.value,
            "data": {"messages": [message]},
        }
    assert_api.assert_response_matches(actual, expected=expected, ignore_keys=_MESSAGE_IGNORE_KEYS)


def _send_group_message(
    device_a,
    device_b,
    assert_api,
    user_a: str,
    group_id: str,
    *,
    type_key: str,
    payload: dict,
) -> str:
    _drain_devices(device_a, device_b)
    resp = device_a.call(
        "ChatManager",
        Cmd.sendMessageWithType.value,
        info={"type": type_key, "payload": payload, "chatType": 1},
    )
    temp_id = ((resp.get("result") or {}).get("msgId"))
    assert temp_id, f"群 {type_key} 消息发送响应未返回临时 msgId: {resp}"
    success_evt = _wait_success(device_a, temp_id=temp_id)
    real_id = ((((success_evt.get("data") or {}).get("msg")) or {}).get("msgId"))
    assert real_id, f"群 {type_key} 消息成功事件未返回真实 msgId: {success_evt}"
    event_type = Cmd.onCmdMessagesReceived.value if type_key == "cmd" else Cmd.onMessagesReceived.value
    received_evt = _wait_received(device_b, event_type=event_type, real_id=real_id)

    _assert_group_message(
        assert_api,
        resp,
        type_key=type_key,
        payload=payload,
        user_a=user_a,
        group_id=group_id,
        temp_id=temp_id,
        real_id=real_id,
        phase="response",
    )
    _assert_group_message(
        assert_api,
        success_evt,
        type_key=type_key,
        payload=payload,
        user_a=user_a,
        group_id=group_id,
        temp_id=temp_id,
        real_id=real_id,
        phase="success",
    )
    _assert_group_message(
        assert_api,
        received_evt,
        type_key=type_key,
        payload=payload,
        user_a=user_a,
        group_id=group_id,
        temp_id=temp_id,
        real_id=real_id,
        phase="received",
    )
    return real_id


@pytest.fixture
def message_group(device_a, device_b, assert_api, user_a, user_b):
    _drain_devices(device_a, device_b)
    group_id, _ = create_group(
        device_a,
        assert_api,
        owner=user_a,
        group_name=new_group_name("message_send"),
        invite_members=[user_b],
    )
    time.sleep(float(os.getenv("GROUP_MESSAGE_MEMBER_SETTLE_SECONDS", "5")))
    try:
        yield group_id
    finally:
        destroy_group(device_a, assert_api, group_id, device_b=device_b)


@pytest.mark.parametrize(
    "type_key",
    ["txt", "file", "image", "video", "voice", "location", "cmd", "custom"],
)
def test_group_message_send_receive_by_type(
    device_a,
    device_b,
    assert_api,
    user_a,
    message_group,
    type_key,
):
    """A 向包含 B 的群发送指定类型消息，严格校验同步响应、A 成功事件和 B 接收事件。"""
    payload = _payload_for(type_key, message_group)
    _send_group_message(
        device_a,
        device_b,
        assert_api,
        user_a,
        message_group,
        type_key=type_key,
        payload=payload,
    )


def test_group_message_send_receive_combine(
    device_a,
    device_b,
    assert_api,
    user_a,
    message_group,
):
    """A 合并同群两条真实文本消息并发送，B 收到关联同一群会话的合并消息。"""
    source_ids = []
    for index in range(2):
        payload = {"targetId": message_group, "content": f"combine-source-{index}-{uuid.uuid4().hex[:8]}"}
        source_ids.append(
            _send_group_message(
                device_a,
                device_b,
                assert_api,
                user_a,
                message_group,
                type_key="txt",
                payload=payload,
            )
        )
    payload = {
        "targetId": message_group,
        "title": "group-combine-title",
        "summary": "group-combine-summary",
        "compatibleText": "group-combine-compatible",
        "msgIds": source_ids,
    }
    _send_group_message(
        device_a,
        device_b,
        assert_api,
        user_a,
        message_group,
        type_key="combine",
        payload=payload,
    )


def test_group_message_ack_boundary_methods(device_a, assert_api):
    """非法群消息 ID 与群 ID 调用群回执 API，冻结当前真实同步返回。"""
    info = {"msgId": "__invalid_group_msg_id__", "group_id": "__invalid_group_id__"}
    resp_ack = device_a.call("ChatManager", Cmd.ackGroupMessageRead.value, info=info)
    assert_api.assert_response_matches(
        resp_ack,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.ackGroupMessageRead.value,
            "device": "deviceA",
            "result": True,
        },
        ignore_keys={"sequence"},
    )


def test_group_message_fetch_acks_success(device_a, device_b, assert_api, user_a, user_b):
    """A 发送需要群回执的文本消息，B 回执后 A 分页查询该消息的群回执。"""
    group_id = ""
    try:
        _drain_devices(device_a, device_b)
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("group_ack"),
            invite_members=[user_b],
        )
        time.sleep(float(os.getenv("GROUP_MESSAGE_MEMBER_SETTLE_SECONDS", "5")))
        content = f"group-ack-{uuid.uuid4().hex[:8]}"
        send_resp = device_a.call(
            "ChatManager",
            Cmd.sendMessage.value,
            info=_build_group_text(user_a, group_id, content, need_group_ack=True),
        )
        temp_id = ((send_resp.get("result") or {}).get("msgId"))
        assert temp_id, f"群消息发送响应未返回临时 msgId: {send_resp}"
        assert_api.assert_response_matches(
            send_resp,
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.sendMessage.value,
                "device": "deviceA",
                "result": {
                    "msgId": temp_id,
                    "from": user_a,
                    "to": group_id,
                    "convId": group_id,
                    "chatType": 1,
                    "direction": 0,
                    "status": 0,
                    "hasRead": True,
                    "hasReadAck": False,
                    "hasDeliverAck": False,
                    "needGroupAck": True,
                    "isThread": False,
                    "isContentReplaced": False,
                    "broadcast": False,
                    "onlineState": True,
                    "body": {"targetLanguages": [], "translations": {}, "type": 0, "content": content},
                },
            },
            ignore_keys={"sequence", "serverTime", "localTime", "deliverOnlineOnly"},
        )
        success_evt = _wait_success(device_a, temp_id=temp_id)
        success_msg = (((success_evt.get("data") or {}).get("msg")) or {})
        real_id = success_msg.get("msgId")
        assert real_id, f"群回执消息成功事件未返回真实 msgId: {success_evt}"
        recv_evt = _wait_received(
            device_b,
            event_type=Cmd.onMessagesReceived.value,
            real_id=str(real_id),
        )
        recv_msg = (((recv_evt.get("data") or {}).get("messages")) or [])[0]
        msg_id = str(recv_msg["msgId"])
        event_message = {
            "msgId": msg_id,
            "from": user_a,
            "to": group_id,
            "convId": group_id,
            "chatType": 1,
            "status": 2,
            "hasReadAck": False,
            "hasDeliverAck": False,
            "needGroupAck": True,
            "isThread": False,
            "isContentReplaced": False,
            "deliverOnlineOnly": False,
            "body": {"type": 0, "content": content},
        }
        assert_api.assert_response_matches(
            success_evt,
            expected={
                "type": "event",
                "eventType": Cmd.onMessageSuccess.value,
                "data": {
                    "msgId": temp_id,
                    "msg": {**event_message, "direction": 0, "hasRead": True},
                },
            },
            ignore_keys=_MESSAGE_IGNORE_KEYS,
        )
        assert_api.assert_response_matches(
            recv_evt,
            expected={
                "type": "event",
                "eventType": Cmd.onMessagesReceived.value,
                "data": {
                    "messages": [{**event_message, "direction": 1, "hasRead": False}],
                },
            },
            ignore_keys=_MESSAGE_IGNORE_KEYS,
        )

        ack_resp = device_b.call(
            "ChatManager",
            Cmd.ackGroupMessageRead.value,
            info={"msgId": msg_id, "group_id": group_id, "content": "read"},
        )
        assert_api.assert_response_matches(
            ack_resp,
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.ackGroupMessageRead.value,
                "device": "deviceB",
                "result": True,
            },
            ignore_keys={"sequence"},
        )

        fetch_resp = device_a.call(
            "ChatManager",
            Cmd.asyncFetchGroupAcks.value,
            info={"msgId": msg_id, "group_id": group_id, "pageSize": 20, "ack_id": None},
        )
        assert_api.assert_response_matches(
            fetch_resp,
            expected={
                "manager": "ChatManager",
                "cmd": Cmd.asyncFetchGroupAcks.value,
                "device": "deviceA",
                "result": {"cursor": "", "list": []},
            },
            ignore_keys={"sequence"},
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id, device_b=device_b)


@pytest.mark.parametrize("target_kind", ["empty", "nonexistent"])
def test_group_message_send_rejects_invalid_group_target(
    device_a,
    device_b,
    assert_api,
    user_a,
    target_kind,
):
    """A 向空或不存在 groupId 发送群文本时应失败，B 不得收到目标消息。"""
    group_id = "" if target_kind == "empty" else f"nonexistent_group_{uuid.uuid4().hex}"
    content = f"invalid-group-{target_kind}-{uuid.uuid4().hex[:8]}"
    _send_group_text_expect_error(
        device_a,
        device_b,
        assert_api,
        sender_name="deviceA",
        from_user=user_a,
        group_id=group_id,
        content=content,
        error_code=500 if target_kind == "empty" else 606,
        error_description="Message is invalid" if target_kind == "empty" else "Group does not exist",
        error_message_status=1 if target_kind == "empty" else 3,
    )


def _assert_owner_member_exited_events(device_a, assert_api, *, group_id: str, member: str) -> None:
    event_types = {"onMembersExitedFromGroup", "onMemberExitedFromGroup"}
    events = collect_group_events(
        device_a,
        expected_event_types=event_types,
        group_id=group_id,
        required_all_event_types=event_types,
        timeout=10.0,
    )
    by_type = {event["eventType"]: event for event in events}
    assert_api.assert_response_matches(
        by_type["onMembersExitedFromGroup"],
        expected={
            "type": "event",
            "eventType": "onMembersExitedFromGroup",
            "data": {"groupId": group_id, "userIds": [member]},
        },
        ignore_keys={"timestamp", "sequence"},
    )
    assert_api.assert_response_matches(
        by_type["onMemberExitedFromGroup"],
        expected={
            "type": "event",
            "eventType": "onMemberExitedFromGroup",
            "data": {"groupId": group_id, "member": member},
        },
        ignore_keys={"timestamp", "sequence"},
    )


@pytest.mark.parametrize("member_state", ["never-member", "left", "removed"])
def test_group_message_send_rejects_non_member_states(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    member_state,
):
    """B 从未入群、主动退出或被移除后发送群文本均应失败，群主 A 不得收到消息。"""
    group_id = ""
    group_name = new_group_name(f"send_{member_state}")
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[] if member_state == "never-member" else [user_b],
        )
        time.sleep(float(os.getenv("GROUP_MESSAGE_MEMBER_SETTLE_SECONDS", "5")))
        device_a.drain_events()
        device_b.drain_events()

        if member_state == "left":
            leave_resp = device_b.call("GroupManager", Cmd.leaveGroup.value, info={"groupId": group_id})
            assert_api.assert_response_matches(
                leave_resp,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.leaveGroup.value,
                    "device": "deviceB",
                    "result": True,
                },
                ignore_keys={"sequence"},
            )
            _assert_owner_member_exited_events(device_a, assert_api, group_id=group_id, member=user_b)
            assert_no_group_event(
                device_b,
                group_id=group_id,
                event_types={"onMembersExitedFromGroup", "onMemberExitedFromGroup"},
            )
        elif member_state == "removed":
            remove_resp = device_a.call(
                "GroupManager",
                Cmd.removeMembers.value,
                info={"groupId": group_id, "members": [user_b]},
            )
            assert_api.assert_response_matches(
                remove_resp,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.removeMembers.value,
                    "device": "deviceA",
                    "result": True,
                },
                ignore_keys={"sequence"},
            )
            removed_event_types = {
                GroupChangeEvent.ON_USER_REMOVED.value,
                "onLeaveFromGroup",
                "onUserRemovedFromGroup",
            }
            removed_events = collect_group_events(
                device_b,
                expected_event_types=removed_event_types,
                group_id=group_id,
                allow_missing_group_id=True,
                required_all_event_types={"onUserRemovedFromGroup"},
                timeout=10.0,
            )
            assert_group_events(
                assert_api,
                removed_events,
                expected_event_types=removed_event_types,
                group_id=group_id,
                allow_missing_group_id=True,
                required_all_event_types={"onUserRemovedFromGroup"},
                expected_member=user_b,
            )
            _assert_owner_member_exited_events(device_a, assert_api, group_id=group_id, member=user_b)

        snapshot = device_a.call(
            "GroupManager",
            Cmd.getGroupSpecificationFromServer.value,
            info={"groupId": group_id, "fetchMembers": True},
        )
        assert_group_snapshot(
            assert_api,
            snapshot,
            cmd=Cmd.getGroupSpecificationFromServer.value,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count_value=1,
            member_list_value=[],
        )

        content = f"non-member-{member_state}-{uuid.uuid4().hex[:8]}"
        _send_group_text_expect_error(
            device_b,
            device_a,
            assert_api,
            sender_name="deviceB",
            from_user=user_b,
            group_id=group_id,
            content=content,
            error_code=602,
            error_description="User has not joined the group",
            error_message_status=3,
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)
