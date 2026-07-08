"""ChatRoom 成员白名单/禁言检查接口。"""
from __future__ import annotations

import pytest

from src import Cmd
from tests.chatroom.chatroom_helpers import assert_join_chatroom_response, create_chatroom_or_skip, safe_delete_chatroom


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


def test_chatroom_member_white_list_check_reflects_server_state(device_a, device_b, assert_api, user_a, user_b):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="white_check", desc_prefix="white_check")
    try:
        join_resp = device_b.call("ChatRoomManager", Cmd.joinChatRoom.value, info={"roomId": room_id})
        assert_join_chatroom_response(assert_api, join_resp, device="deviceB", room_id=room_id)

        before_resp = device_b.call(
            "ChatRoomManager",
            Cmd.isMemberInChatRoomWhiteListFromServer.value,
            info={"roomId": room_id},
        )
        assert before_resp.get("result") is False, f"加入白名单前 B 不应在白名单: {before_resp}"

        add_resp = device_a.call(
            "ChatRoomManager",
            Cmd.addMembersToChatRoomWhiteList.value,
            info={"roomId": room_id, "members": [user_b]},
        )
        assert_api.assert_response_matches(
            add_resp,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.addMembersToChatRoomWhiteList.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )

        after_add_resp = device_b.call(
            "ChatRoomManager",
            Cmd.isMemberInChatRoomWhiteListFromServer.value,
            info={"roomId": room_id},
        )
        assert after_add_resp.get("result") is True, f"加入白名单后 B 应在白名单: {after_add_resp}"

        remove_resp = device_a.call(
            "ChatRoomManager",
            Cmd.removeMembersFromChatRoomWhiteList.value,
            info={"roomId": room_id, "members": [user_b]},
        )
        assert_api.assert_response_matches(
            remove_resp,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.removeMembersFromChatRoomWhiteList.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )

        after_remove_resp = device_b.call(
            "ChatRoomManager",
            Cmd.isMemberInChatRoomWhiteListFromServer.value,
            info={"roomId": room_id},
        )
        assert after_remove_resp.get("result") is False, f"移除白名单后 B 不应在白名单: {after_remove_resp}"
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_member_mute_list_check_reflects_server_state(device_a, device_b, assert_api, user_a, user_b):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="mute_check", desc_prefix="mute_check")
    try:
        join_resp = device_b.call("ChatRoomManager", Cmd.joinChatRoom.value, info={"roomId": room_id})
        assert_join_chatroom_response(assert_api, join_resp, device="deviceB", room_id=room_id)

        before_resp = device_b.call(
            "ChatRoomManager",
            Cmd.isMemberInChatRoomMuteList.value,
            info={"roomId": room_id},
        )
        assert before_resp.get("result") is False, f"禁言前 B 不应在禁言列表: {before_resp}"

        mute_resp = device_a.call(
            "ChatRoomManager",
            Cmd.muteChatRoomMembers.value,
            info={"roomId": room_id, "muteMembers": [user_b], "duration": 60000},
        )
        assert_api.assert_response_matches(
            mute_resp,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.muteChatRoomMembers.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )

        after_mute_resp = device_b.call(
            "ChatRoomManager",
            Cmd.isMemberInChatRoomMuteList.value,
            info={"roomId": room_id},
        )
        assert after_mute_resp.get("result") is True, f"禁言后 B 应在禁言列表: {after_mute_resp}"

        unmute_resp = device_a.call(
            "ChatRoomManager",
            Cmd.unMuteChatRoomMembers.value,
            info={"roomId": room_id, "unMuteMembers": [user_b]},
        )
        assert_api.assert_response_matches(
            unmute_resp,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.unMuteChatRoomMembers.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )

        after_unmute_resp = device_b.call(
            "ChatRoomManager",
            Cmd.isMemberInChatRoomMuteList.value,
            info={"roomId": room_id},
        )
        assert after_unmute_resp.get("result") is False, f"解除禁言后 B 不应在禁言列表: {after_unmute_resp}"
    finally:
        safe_delete_chatroom(room_id)
