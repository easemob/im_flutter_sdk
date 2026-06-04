from __future__ import annotations

import pytest

from src import Cmd
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
