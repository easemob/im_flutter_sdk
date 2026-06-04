"""ChatRoom 成员白名单/禁言检查接口。"""
from __future__ import annotations

import pytest

from src import Cmd
from tests.chatroom.chatroom_helpers import create_chatroom_or_skip, safe_delete_chatroom


pytestmark = [pytest.mark.client, pytest.mark.chatroom, pytest.mark.agorachat1_4_0]


def test_chatroom_is_member_in_white_list_and_mute_list_success(device_a, assert_api, user_a):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="member_check", desc_prefix="member_check")
    try:
        resp_white = device_a.call(
            "ChatRoomManager",
            Cmd.isMemberInChatRoomWhiteListFromServer.value,
            info={"roomId": room_id},
        )
        assert_api.assert_response_matches(
            resp_white,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.isMemberInChatRoomWhiteListFromServer.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )
        assert isinstance(resp_white.get("result"), bool), (
            f"isMemberInChatRoomWhiteListFromServer result 应为 bool: {resp_white}"
        )

        resp_mute = device_a.call(
            "ChatRoomManager",
            Cmd.isMemberInChatRoomMuteList.value,
            info={"roomId": room_id},
        )
        assert_api.assert_response_matches(
            resp_mute,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.isMemberInChatRoomMuteList.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )
        assert isinstance(resp_mute.get("result"), bool), f"isMemberInChatRoomMuteList result 应为 bool: {resp_mute}"
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_is_member_in_white_list_and_mute_list_nonexistent_room(device_a, assert_api):
    room_id = "nonexistent_chatroom_member_check_999999"
    for cmd in (Cmd.isMemberInChatRoomWhiteListFromServer.value, Cmd.isMemberInChatRoomMuteList.value):
        resp = device_a.call("ChatRoomManager", cmd, info={"roomId": room_id})
        assert_api.assert_error(resp, code=700, description="do not find this group")
