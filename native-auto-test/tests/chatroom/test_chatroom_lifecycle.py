from __future__ import annotations

import pytest

from src import Cmd, ne
from tests.chatroom.chatroom_helpers import create_chatroom_or_skip, safe_delete_chatroom


pytestmark = [pytest.mark.client, pytest.mark.chatroom, pytest.mark.agorachat1_4_0]


def test_chatroom_create_and_fetch_from_server(device_a, assert_api, user_a):
    room_id, room_name = create_chatroom_or_skip(owner=user_a, name_prefix="create", desc_prefix="create")
    try:
        resp = device_a.call("ChatRoomManager", Cmd.fetchChatRoomInfoFromServer.value, info={"roomId": room_id})
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.fetchChatRoomInfoFromServer.value,
                "device": "deviceA",
                "result": {
                    "roomId": room_id,
                    "owner": user_a,
                    "name": room_name,
                    "maxUsers": 200,
                    "memberCount": 1,
                    "permissionType": 2,
                    "isAllMemberMuted": False,
                    "adminList": [],
                    "muteList": [],
                    "muteExpireTimestamp": -1,
                    "createTimestamp": 0,
                    "memberList": [],
                    "isInWhitelist": False,
                    "blockList": [],
                    "desc": "nothing left here",
                    "announcement": "",
                },
            },
            ignore_keys={"sequence"},
        )
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_fetch_room_info_with_members_from_server(device_a, device_b, assert_api, user_a, user_b):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="fetch_members", desc_prefix="fetch_members")
    try:
        join_resp = device_b.call("ChatRoomManager", Cmd.joinChatRoom.value, info={"roomId": room_id})
        assert_api.assert_response_matches(
            join_resp,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.joinChatRoom.value,
                "device": "deviceB",
                "result": 1,
            },
            ignore_keys={"sequence"},
        )

        resp = device_a.call(
            "ChatRoomManager",
            Cmd.fetchChatRoomInfoFromServer.value,
            info={"roomId": room_id, "fetchMembers": True},
        )
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.fetchChatRoomInfoFromServer.value,
                "device": "deviceA",
                "result": {
                    "roomId": room_id,
                    "owner": user_a,
                    "memberCount": 2,
                    "memberList": ne(None),
                },
            },
            ignore_keys={
                "sequence",
                "name",
                "maxUsers",
                "permissionType",
                "isAllMemberMuted",
                "adminList",
                "muteList",
                "muteExpireTimestamp",
                "createTimestamp",
                "isInWhitelist",
                "blockList",
                "desc",
                "announcement",
            },
        )
        result = resp.get("result")
        assert isinstance(result, dict), f"fetchChatRoomInfoFromServer result 应为 dict: {resp}"
        members = result.get("memberList")
        assert isinstance(members, list), f"fetchMembers=true 时 memberList 应为 list: {resp}"
        assert user_a not in members, f"fetchMembers=true 的普通成员列表不应包含 owner: user_a={user_a}, members={members}"
        assert user_b in members, f"memberList 缺少加入成员: user_b={user_b}, members={members}"
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_destroy_room_success(device_a, assert_api, user_a):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="destroy", desc_prefix="destroy")
    resp = device_a.call("ChatRoomManager", Cmd.destroyChatRoom.value, info={"roomId": room_id})
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatRoomManager",
            "cmd": Cmd.destroyChatRoom.value,
            "device": "deviceA",
            "result": True,
        },
        ignore_keys={"sequence"},
    )


def test_chatroom_fetch_room_info_from_server_after_destroy(device_a, assert_api, user_a):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="destroy_fetch", desc_prefix="destroy_fetch")
    resp_destroy = device_a.call("ChatRoomManager", Cmd.destroyChatRoom.value, info={"roomId": room_id})
    assert_api.assert_response_matches(
        resp_destroy,
        expected={
            "manager": "ChatRoomManager",
            "cmd": Cmd.destroyChatRoom.value,
            "device": "deviceA",
            "result": True,
        },
        ignore_keys={"sequence"},
    )

    resp_fetch = device_a.call("ChatRoomManager", Cmd.fetchChatRoomInfoFromServer.value, info={"roomId": room_id})
    assert_api.assert_error(resp_fetch, code=700, description="do not find this group")
