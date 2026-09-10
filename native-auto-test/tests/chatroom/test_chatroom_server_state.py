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
        # Public listings are shared across lanes/users. No contract guarantees
        # that our newly created room occupies the first slot.
        for page_num in range(1, 101):
            resp = device_a.call(
                "ChatRoomManager", Cmd.fetchPublicChatRoomsFromServer.value,
                info={"pageNum": page_num, "pageSize": 1},
            )
            result = resp.get("result")
            assert isinstance(result, dict), f"Invalid public-room result: {result!r}"
            rooms = result.get("list")
            assert isinstance(rooms, list), "Public-room result.list must be a list"
            assert len(rooms) <= 1, "Public-room page exceeds requested pageSize=1"
            assert_api.assert_response_matches(
                resp,
                expected={
                    "manager": "ChatRoomManager",
                    "cmd": Cmd.fetchPublicChatRoomsFromServer.value,
                    "device": "deviceA",
                    "result": {"count": len(rooms)},
                },
                # Validate variable room identities separately below.
                ignore_keys={"sequence", "list"},
            )
            for room in rooms:
                assert isinstance(room, dict), "Public-room entry must be an object"
                assert isinstance(room.get("roomId"), str) and room["roomId"], "Missing roomId"
            if any(room["roomId"] == room_id for room in rooms):
                break
            if not rooms:
                pytest.fail(f"Created public room {room_id} not found before end of listing (page {page_num})")
        else:
            pytest.fail(f"Created public room {room_id} not found within 100 pages")
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
