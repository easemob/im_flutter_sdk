from __future__ import annotations

import pytest

from src import Cmd
from tests.chatroom.chatroom_helpers import create_chatroom_or_skip, safe_delete_chatroom


pytestmark = [pytest.mark.client, pytest.mark.chatroom]


def test_chatroom_fetch_public_chat_rooms_from_server_success(device_a, assert_api, user_a):
    room_id = ""
    room_name = ""
    try:
        room_id, room_name = create_chatroom_or_skip(owner=user_a, name_prefix="public", desc_prefix="public")
        resp = device_a.call("ChatRoomManager", Cmd.fetchPublicChatRoomsFromServer.value, info={"pageNum": 1, "pageSize": 1})
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.fetchPublicChatRoomsFromServer.value,
                "device": "deviceA",
                "result": {
                    "count": 1,
                    "list": [
                        {
                            "roomId": room_id,
                            "owner": user_a,
                            "name": room_name,
                            "maxUsers": 0,
                            "permissionType": -1,
                            "isAllMemberMuted": False,
                            "adminList": [],
                            "memberCount": 0,
                            "muteList": [],
                            "muteExpireTimestamp": -1,
                            "createTimestamp": 0,
                            "memberList": [],
                            "isInWhitelist": False,
                            "blockList": [],
                            "desc": "",
                            "announcement": "",
                        }
                    ],
                },
            },
            ignore_keys={"sequence"},
        )
    finally:
        if room_id:
            safe_delete_chatroom(room_id)
