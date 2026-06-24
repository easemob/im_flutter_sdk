"""ChatRoom 管理类接口异常用例。"""
from __future__ import annotations

import pytest

from src import Cmd


pytestmark = [pytest.mark.client, pytest.mark.chatroom, pytest.mark.agorachat4_23_0]


_NONEXISTENT_CHATROOM_ID = "nonexistent_chatroom_management_999999"

_NONEXISTENT_MANAGEMENT_CASES = [
    (
        Cmd.changeChatRoomSubject.value,
        {"roomId": _NONEXISTENT_CHATROOM_ID, "subject": "subject"},
        700,
        "do not find this group",
    ),
    (
        Cmd.changeChatRoomDescription.value,
        {"roomId": _NONEXISTENT_CHATROOM_ID, "description": "description"},
        700,
        "do not find this group",
    ),
    (
        Cmd.updateChatRoomAnnouncement.value,
        {"roomId": _NONEXISTENT_CHATROOM_ID, "announcement": "announcement"},
        700,
        "do not find this group",
    ),
    (
        Cmd.fetchChatRoomAnnouncement.value,
        {"roomId": _NONEXISTENT_CHATROOM_ID},
        700,
        "do not find this group",
    ),
    (
        Cmd.addMembersToChatRoomWhiteList.value,
        {"roomId": _NONEXISTENT_CHATROOM_ID, "members": ["member"]},
        700,
        "do not find this group",
    ),
    (
        Cmd.removeMembersFromChatRoomWhiteList.value,
        {"roomId": _NONEXISTENT_CHATROOM_ID, "members": ["member"]},
        700,
        "do not find this group",
    ),
    (
        Cmd.fetchChatRoomWhiteListFromServer.value,
        {"roomId": _NONEXISTENT_CHATROOM_ID},
        700,
        "do not find this group",
    ),
    (
        Cmd.muteChatRoomMembers.value,
        {"roomId": _NONEXISTENT_CHATROOM_ID, "muteMembers": ["member"], "duration": 60000},
        700,
        "do not find this group",
    ),
    (
        Cmd.unMuteChatRoomMembers.value,
        {"roomId": _NONEXISTENT_CHATROOM_ID, "unMuteMembers": ["member"]},
        700,
        "do not find this group",
    ),
    (
        Cmd.fetchChatRoomMuteList.value,
        {"roomId": _NONEXISTENT_CHATROOM_ID, "pageNum": 1, "pageSize": 20},
        700,
        "do not find this group",
    ),
    (
        Cmd.muteAllChatRoomMembers.value,
        {"roomId": _NONEXISTENT_CHATROOM_ID},
        700,
        "do not find this group",
    ),
    (
        Cmd.unMuteAllChatRoomMembers.value,
        {"roomId": _NONEXISTENT_CHATROOM_ID},
        700,
        "do not find this group",
    ),
    (
        Cmd.blockChatRoomMembers.value,
        {"roomId": _NONEXISTENT_CHATROOM_ID, "members": ["member"]},
        700,
        "do not find this group",
    ),
    (
        Cmd.unBlockChatRoomMembers.value,
        {"roomId": _NONEXISTENT_CHATROOM_ID, "members": ["member"]},
        700,
        "do not find this group",
    ),
    (
        Cmd.fetchChatRoomBlockList.value,
        {"roomId": _NONEXISTENT_CHATROOM_ID, "pageNum": 1, "pageSize": 20},
        700,
        "do not find this group",
    ),
    (
        Cmd.addChatRoomAdmin.value,
        {"roomId": _NONEXISTENT_CHATROOM_ID, "admin": "member"},
        700,
        "do not find this group",
    ),
    (
        Cmd.removeChatRoomAdmin.value,
        {"roomId": _NONEXISTENT_CHATROOM_ID, "admin": "member"},
        700,
        "do not find this group",
    ),
    (
        Cmd.changeChatRoomOwner.value,
        {"roomId": _NONEXISTENT_CHATROOM_ID, "newOwner": "member"},
        700,
        "do not find this group",
    ),
    (
        Cmd.removeChatRoomMembers.value,
        {"roomId": _NONEXISTENT_CHATROOM_ID, "members": ["member"]},
        700,
        "do not find this group",
    ),
    (
        Cmd.setChatRoomAttributes.value,
        {
            "roomId": _NONEXISTENT_CHATROOM_ID,
            "attributes": {"k": "v"},
            "autoDelete": False,
            "forced": True,
        },
        702,
        None,
    ),
    (
        Cmd.fetchChatRoomAttributes.value,
        {"roomId": _NONEXISTENT_CHATROOM_ID, "keys": ["k"]},
        702,
        "User has not joined the chat room",
    ),
    (
        Cmd.removeChatRoomAttributes.value,
        {"roomId": _NONEXISTENT_CHATROOM_ID, "keys": ["k"], "forced": True},
        702,
        None,
    ),
]

_EMPTY_ROOM_ID_MANAGEMENT_CASES = [
    (
        Cmd.changeChatRoomSubject.value,
        {"roomId": "", "subject": "subject"},
        700,
        "Chat room ID is invalid",
    ),
    (
        Cmd.changeChatRoomDescription.value,
        {"roomId": "", "description": "description"},
        700,
        "Chat room ID is invalid",
    ),
    (
        Cmd.updateChatRoomAnnouncement.value,
        {"roomId": "", "announcement": "announcement"},
        700,
        "Chat room ID is invalid",
    ),
    (
        Cmd.fetchChatRoomAnnouncement.value,
        {"roomId": ""},
        700,
        "Chat room ID is invalid",
    ),
    (
        Cmd.addMembersToChatRoomWhiteList.value,
        {"roomId": "", "members": ["member"]},
        700,
        "Chat room ID is invalid",
    ),
    (
        Cmd.removeMembersFromChatRoomWhiteList.value,
        {"roomId": "", "members": ["member"]},
        700,
        "Chat room ID is invalid",
    ),
    (
        Cmd.fetchChatRoomWhiteListFromServer.value,
        {"roomId": ""},
        700,
        "Chat room ID is invalid",
    ),
    (
        Cmd.muteChatRoomMembers.value,
        {"roomId": "", "muteMembers": ["member"], "duration": 60000},
        700,
        "Chat room ID is invalid",
    ),
    (
        Cmd.unMuteChatRoomMembers.value,
        {"roomId": "", "unMuteMembers": ["member"]},
        700,
        "Chat room ID is invalid",
    ),
    (
        Cmd.fetchChatRoomMuteList.value,
        {"roomId": "", "pageNum": 1, "pageSize": 20},
        700,
        "Chat room ID is invalid",
    ),
    (
        Cmd.muteAllChatRoomMembers.value,
        {"roomId": ""},
        700,
        "Chat room ID is invalid",
    ),
    (
        Cmd.unMuteAllChatRoomMembers.value,
        {"roomId": ""},
        700,
        "Chat room ID is invalid",
    ),
    (
        Cmd.blockChatRoomMembers.value,
        {"roomId": "", "members": ["member"]},
        700,
        "Chat room ID is invalid",
    ),
    (
        Cmd.unBlockChatRoomMembers.value,
        {"roomId": "", "members": ["member"]},
        700,
        "Chat room ID is invalid",
    ),
    (
        Cmd.fetchChatRoomBlockList.value,
        {"roomId": "", "pageNum": 1, "pageSize": 20},
        700,
        "Chat room ID is invalid",
    ),
    (
        Cmd.addChatRoomAdmin.value,
        {"roomId": "", "admin": "member"},
        700,
        "Chat room ID is invalid",
    ),
    (
        Cmd.removeChatRoomAdmin.value,
        {"roomId": "", "admin": "member"},
        700,
        "Chat room ID is invalid",
    ),
    (
        Cmd.changeChatRoomOwner.value,
        {"roomId": "", "newOwner": "member"},
        700,
        "Chat room ID is invalid",
    ),
    (
        Cmd.removeChatRoomMembers.value,
        {"roomId": "", "members": ["member"]},
        700,
        "Chat room ID is invalid",
    ),
    (
        Cmd.setChatRoomAttributes.value,
        {
            "roomId": "",
            "attributes": {"k": "v"},
            "autoDelete": False,
            "forced": True,
        },
        303,
        "",
    ),
    (
        Cmd.fetchChatRoomAttributes.value,
        {"roomId": "", "keys": ["k"]},
        303,
        "Unknown server error",
    ),
    (
        Cmd.removeChatRoomAttributes.value,
        {"roomId": "", "keys": ["k"], "forced": True},
        303,
        "",
    ),
]


@pytest.mark.parametrize(
    ("cmd", "info", "expected_code", "expected_description"),
    _NONEXISTENT_MANAGEMENT_CASES,
    ids=[case[0] for case in _NONEXISTENT_MANAGEMENT_CASES],
)
def test_chatroom_management_api_nonexistent_room(device_a, assert_api, cmd, info, expected_code, expected_description):
    resp = device_a.call("ChatRoomManager", cmd, info=info)
    assert_api.assert_error(resp, code=expected_code, description=expected_description)


@pytest.mark.parametrize(
    ("cmd", "info", "expected_code", "expected_description"),
    _EMPTY_ROOM_ID_MANAGEMENT_CASES,
    ids=[case[0] for case in _EMPTY_ROOM_ID_MANAGEMENT_CASES],
)
def test_chatroom_management_api_empty_room_id(device_a, assert_api, cmd, info, expected_code, expected_description):
    resp = device_a.call("ChatRoomManager", cmd, info=info)
    if expected_description == "":
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "ChatRoomManager",
                "cmd": cmd,
                "device": "deviceA",
                "result": {
                    "code": expected_code,
                    "description": "",
                },
            },
            ignore_keys={"sequence"},
        )
        return
    assert_api.assert_error(resp, code=expected_code, description=expected_description)
