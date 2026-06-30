from __future__ import annotations

import time
import pytest
from uuid import uuid4

from src import Cmd, ge, ne
from tests.chatroom.chatroom_helpers import (
    assert_chatroom_event,
    collect_chatroom_events,
    create_chatroom_or_skip,
    safe_delete_chatroom,
)


pytestmark = [pytest.mark.client, pytest.mark.chatroom, pytest.mark.agorachat4_23_0]


CHATROOM_IGNORE_KEYS = {
    "sequence",
    "timestamp",
    "serverTime",
    "localTime",
    "createTimestamp",
    "desc",
    "announcement",
    "adminList",
    "memberList",
    "blockList",
    "muteList",
    "muteExpireTimestamp",
    "permissionType",
    "isInWhitelist",
    "isAllMemberMuted",
    "name",
    "owner",
}


def _join_room(
    device,
    assert_api,
    *,
    room_id: str,
    device_name: str = "deviceB",
    leave_other_rooms: bool | None = None,
) -> dict:
    info = {"roomId": room_id}
    if leave_other_rooms is not None:
        info["leaveOtherRooms"] = leave_other_rooms
    resp = device.call("ChatRoomManager", Cmd.joinChatRoom.value, info=info)
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatRoomManager",
            "cmd": Cmd.joinChatRoom.value,
            "device": device_name,
            "result": 1,
        },
        ignore_keys={"sequence"},
    )
    return resp


def _fetch_room_members(device, assert_api, *, room_id: str, device_name: str) -> list[str]:
    resp = device.call(
        "ChatRoomManager",
        Cmd.fetchChatRoomMembers.value,
        info={"roomId": room_id, "cursor": "", "pageSize": 20},
    )
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatRoomManager",
            "cmd": Cmd.fetchChatRoomMembers.value,
            "device": device_name,
            "result": {
                "cursor": ne(None),
                "list": ne(None),
            },
        },
        ignore_keys={"sequence"},
    )
    result = resp.get("result")
    assert isinstance(result, dict), f"fetchChatRoomMembers result 应为 dict: {resp}"
    members = result.get("list")
    assert isinstance(members, list), f"fetchChatRoomMembers result.list 应为 list: {resp}"
    return members


def _wait_for_member_state(
    device,
    assert_api,
    *,
    room_id: str,
    user_id: str,
    should_contain: bool,
    device_name: str,
    context: str = "",
    timeout: float = 8.0,
) -> list[str]:
    deadline = time.monotonic() + timeout
    last_members: list[str] = []
    while time.monotonic() < deadline:
        last_members = _fetch_room_members(device, assert_api, room_id=room_id, device_name=device_name)
        if (user_id in last_members) is should_contain:
            return last_members
        time.sleep(0.5)
    expectation = "包含" if should_contain else "不包含"
    prefix = f"{context}：" if context else ""
    raise AssertionError(f"{prefix}成员列表未达到预期：roomId={room_id} 应{expectation} {user_id}, members={last_members}")


def _assert_local_rooms(
    device,
    assert_api,
    *,
    present: set[str],
    device_name: str = "deviceB",
) -> None:
    resp = device.call("ChatRoomManager", Cmd.getAllChatRooms.value, info={})
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatRoomManager",
            "cmd": Cmd.getAllChatRooms.value,
            "device": device_name,
            "result": ne(None),
        },
        ignore_keys={"sequence"},
    )
    rooms = resp.get("result")
    assert isinstance(rooms, list), f"getAllChatRooms result 应为 list: {resp}"
    room_ids = {room.get("roomId") for room in rooms if isinstance(room, dict)}
    missing = present - room_ids
    assert not missing, f"本地聊天室列表缺少预期房间: missing={missing}, rooms={rooms}"


def test_chatroom_join_then_get_local_room_and_all_rooms(device_a, device_b, assert_api, user_a, user_b):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="local_room", desc_prefix="local_room")
    try:
        _join_room(device_b, assert_api, room_id=room_id)

        local_resp = device_b.call("ChatRoomManager", Cmd.getChatRoom.value, info={"roomId": room_id})
        assert_api.assert_response_matches(
            local_resp,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.getChatRoom.value,
                "device": "deviceB",
                "result": {
                    "roomId": room_id,
                    "maxUsers": ge(0),
                    "memberCount": ge(1),
                },
            },
            ignore_keys=CHATROOM_IGNORE_KEYS,
        )

        all_resp = device_b.call("ChatRoomManager", Cmd.getAllChatRooms.value, info={})
        assert_api.assert_response_matches(
            all_resp,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.getAllChatRooms.value,
                "device": "deviceB",
                "result": ne(None),
            },
            ignore_keys={"sequence"},
        )
        rooms = all_resp.get("result")
        assert isinstance(rooms, list), f"getAllChatRooms result 应为 list: {all_resp}"
        assert any(isinstance(room, dict) and room.get("roomId") == room_id for room in rooms), (
            f"getAllChatRooms 未包含已加入聊天室: roomId={room_id}, rooms={rooms}"
        )

        events = collect_chatroom_events(
            device_b,
            expected_event_types={"onMemberJoinedFromChatRoom"},
            chatroom_id=room_id,
            timeout=10.0,
        )
        for evt in events:
            assert_chatroom_event(
                assert_api,
                evt,
                event_type="onMemberJoinedFromChatRoom",
                room_id=room_id,
                participant=user_a,
                ext="",
            )
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_get_local_room_empty_id_returns_none(device_b, assert_api):
    resp = device_b.call("ChatRoomManager", Cmd.getChatRoom.value, info={"roomId": ""})
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatRoomManager",
            "cmd": Cmd.getChatRoom.value,
            "device": "deviceB",
            "result": None,
        },
        ignore_keys={"sequence"},
    )


def test_chatroom_get_local_room_nonexistent_returns_placeholder(device_b, assert_api):
    room_id = f"nonexistent_local_room_{uuid4().hex[:8]}"
    resp = device_b.call("ChatRoomManager", Cmd.getChatRoom.value, info={"roomId": room_id})
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatRoomManager",
            "cmd": Cmd.getChatRoom.value,
            "device": "deviceB",
            "result": {
                "roomId": room_id,
                "name": "",
                "maxUsers": 0,
                "memberCount": 0,
                "permissionType": -1,
                "isAllMemberMuted": False,
                "adminList": [],
                "muteList": [],
                "muteExpireTimestamp": -1,
                "createTimestamp": 0,
                "isInWhitelist": False,
                "blockList": [],
                "desc": "",
                "announcement": "",
            },
        },
        ignore_keys={"sequence"},
    )


def test_chatroom_get_all_local_rooms_returns_list(device_b, assert_api):
    resp = device_b.call("ChatRoomManager", Cmd.getAllChatRooms.value, info={})
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatRoomManager",
            "cmd": Cmd.getAllChatRooms.value,
            "device": "deviceB",
            "result": ne(None),
        },
        ignore_keys={"sequence"},
    )
    rooms = resp.get("result")
    assert isinstance(rooms, list), f"getAllChatRooms result 应为 list: {resp}"
    for room in rooms:
        assert isinstance(room, dict), f"getAllChatRooms item 应为 dict: {room!r}"
        assert "roomId" in room, f"getAllChatRooms item 缺少 roomId: {room!r}"


def test_chatroom_fetch_members_after_join_success(device_a, device_b, assert_api, user_a, user_b):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="members", desc_prefix="members")
    try:
        _join_room(device_b, assert_api, room_id=room_id)

        resp = device_b.call(
            "ChatRoomManager",
            Cmd.fetchChatRoomMembers.value,
            info={"roomId": room_id, "cursor": "", "pageSize": 20},
        )
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.fetchChatRoomMembers.value,
                "device": "deviceB",
                "result": {
                    "cursor": ne(None),
                    "list": ne(None),
                },
            },
            ignore_keys={"sequence"},
        )
        result = resp.get("result")
        assert isinstance(result, dict), f"fetchChatRoomMembers result 应为 dict: {resp}"
        members = result.get("list")
        assert isinstance(members, list), f"fetchChatRoomMembers result.list 应为 list: {resp}"
        assert user_b in members, f"聊天室成员列表缺少加入成员: user_b={user_b}, members={members}"
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_fetch_members_with_cursor_pagination(device_a, device_b, assert_api, user_a, user_b):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="members_page", desc_prefix="members_page")
    try:
        _join_room(device_b, assert_api, room_id=room_id)

        first_resp = device_a.call(
            "ChatRoomManager",
            Cmd.fetchChatRoomMembers.value,
            info={"roomId": room_id, "cursor": "", "pageSize": 1},
        )
        assert_api.assert_response_matches(
            first_resp,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.fetchChatRoomMembers.value,
                "device": "deviceA",
                "result": {
                    "cursor": ne(None),
                    "list": ne(None),
                },
            },
            ignore_keys={"sequence"},
        )
        first_result = first_resp.get("result")
        assert isinstance(first_result, dict), f"fetchChatRoomMembers result 应为 dict: {first_resp}"
        first_members = first_result.get("list")
        assert isinstance(first_members, list), f"fetchChatRoomMembers result.list 应为 list: {first_resp}"
        assert len(first_members) <= 1, f"pageSize=1 时首屏成员数量不应超过 1: {first_members}"

        cursor = first_result.get("cursor")
        all_members = list(first_members)
        if cursor:
            second_resp = device_a.call(
                "ChatRoomManager",
                Cmd.fetchChatRoomMembers.value,
                info={"roomId": room_id, "cursor": cursor, "pageSize": 20},
            )
            assert_api.assert_response_matches(
                second_resp,
                expected={
                    "manager": "ChatRoomManager",
                    "cmd": Cmd.fetchChatRoomMembers.value,
                    "device": "deviceA",
                    "result": {
                        "cursor": ne(None),
                        "list": ne(None),
                    },
                },
                ignore_keys={"sequence"},
            )
            second_result = second_resp.get("result")
            assert isinstance(second_result, dict), f"fetchChatRoomMembers second result 应为 dict: {second_resp}"
            second_members = second_result.get("list")
            assert isinstance(second_members, list), f"fetchChatRoomMembers second list 应为 list: {second_resp}"
            all_members.extend(second_members)

        assert user_a not in all_members, f"聊天室普通成员分页列表不应包含 owner: user_a={user_a}, members={all_members}"
        assert user_b in all_members, f"分页成员列表缺少加入成员: user_b={user_b}, members={all_members}"
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_join_leave_other_rooms_option_controls_existing_rooms(device_a, device_b, assert_api, user_a, user_b):
    """joinChatRoom：leaveOtherRooms=false 保留其他聊天室，leaveOtherRooms=true 退出其他聊天室。"""
    # false 分支：B 先加入 room_keep_a，再以 leaveOtherRooms=false 加入 room_keep_b，预期两个房间都保留 B。
    room_keep_a, _ = create_chatroom_or_skip(owner=user_a, name_prefix="leave_other_false_a", desc_prefix="leave_other_false")
    room_keep_b, _ = create_chatroom_or_skip(owner=user_a, name_prefix="leave_other_false_b", desc_prefix="leave_other_false")
    # true 分支：B 先加入 room_drop_a，再以 leaveOtherRooms=true 加入 room_drop_b，预期从 room_drop_a 自动退出。
    room_drop_a, _ = create_chatroom_or_skip(owner=user_a, name_prefix="leave_other_true_a", desc_prefix="leave_other_true")
    room_drop_b, _ = create_chatroom_or_skip(owner=user_a, name_prefix="leave_other_true_b", desc_prefix="leave_other_true")
    created_room_ids = [room_keep_a, room_keep_b, room_drop_a, room_drop_b]
    try:
        _join_room(device_b, assert_api, room_id=room_keep_a, leave_other_rooms=False)
        _join_room(device_b, assert_api, room_id=room_keep_b, leave_other_rooms=False)

        _wait_for_member_state(
            device_a,
            assert_api,
            room_id=room_keep_a,
            user_id=user_b,
            should_contain=True,
            device_name="deviceA",
            context="leaveOtherRooms=false 应保留旧聊天室",
        )
        _wait_for_member_state(
            device_a,
            assert_api,
            room_id=room_keep_b,
            user_id=user_b,
            should_contain=True,
            device_name="deviceA",
            context="leaveOtherRooms=false 应加入新聊天室",
        )
        _assert_local_rooms(
            device_b,
            assert_api,
            present={room_keep_a, room_keep_b},
        )

        _join_room(device_b, assert_api, room_id=room_drop_a, leave_other_rooms=False)
        _wait_for_member_state(
            device_a,
            assert_api,
            room_id=room_drop_a,
            user_id=user_b,
            should_contain=True,
            device_name="deviceA",
            context="leaveOtherRooms=true 前置条件应先加入旧聊天室",
        )

        _join_room(device_b, assert_api, room_id=room_drop_b, leave_other_rooms=True)
        _wait_for_member_state(
            device_a,
            assert_api,
            room_id=room_drop_a,
            user_id=user_b,
            should_contain=False,
            device_name="deviceA",
            context="leaveOtherRooms=true 应退出旧聊天室",
        )
        _wait_for_member_state(
            device_a,
            assert_api,
            room_id=room_drop_b,
            user_id=user_b,
            should_contain=True,
            device_name="deviceA",
            context="leaveOtherRooms=true 应加入新聊天室",
        )
        _assert_local_rooms(
            device_b,
            assert_api,
            present={room_drop_b},
        )
    finally:
        for room_id in created_room_ids:
            safe_delete_chatroom(room_id)


def test_chatroom_leave_room_updates_local_cache(device_a, device_b, assert_api, user_a, user_b):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="leave", desc_prefix="leave")
    try:
        _join_room(device_b, assert_api, room_id=room_id)

        leave_resp = device_b.call("ChatRoomManager", Cmd.leaveChatRoom.value, info={"roomId": room_id})
        assert_api.assert_response_matches(
            leave_resp,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.leaveChatRoom.value,
                "device": "deviceB",
                "result": None,
            },
            ignore_keys={"sequence"},
        )

        members_resp = device_a.call(
            "ChatRoomManager",
            Cmd.fetchChatRoomMembers.value,
            info={"roomId": room_id, "cursor": "", "pageSize": 20},
        )
        assert_api.assert_response_matches(
            members_resp,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.fetchChatRoomMembers.value,
                "device": "deviceA",
                "result": {
                    "cursor": ne(None),
                    "list": ne(None),
                },
            },
            ignore_keys={"sequence"},
        )
        result = members_resp.get("result")
        assert isinstance(result, dict), f"fetchChatRoomMembers result 应为 dict: {members_resp}"
        members = result.get("list")
        assert isinstance(members, list), f"fetchChatRoomMembers result.list 应为 list: {members_resp}"
        assert user_b not in members, f"leaveChatRoom 后成员列表仍包含离开成员: user_b={user_b}, members={members}"
    finally:
        safe_delete_chatroom(room_id)
