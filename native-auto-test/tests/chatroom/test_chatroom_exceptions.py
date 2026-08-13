from __future__ import annotations

from uuid import uuid4

import pytest

from src import Cmd
from src.tools.response_match import ge


pytestmark = [pytest.mark.client, pytest.mark.chatroom, pytest.mark.agorachat1_4_0]


def _nonexistent_room_id() -> str:
    return f"nonexistent_chatroom_{uuid4().hex[:12]}"


def test_chatroom_fetch_room_info_nonexistent(device_a, assert_api):
    room_id = _nonexistent_room_id()
    resp = device_a.call("ChatRoomManager", Cmd.fetchChatRoomInfoFromServer.value, info={"roomId": room_id})
    assert_api.assert_error(resp, code=700, description="do not find this group")


@pytest.mark.skip(reason="5.0 移除客户端 destroyChatRoom（残留）")
def test_chatroom_destroy_room_nonexistent(device_a, assert_api):
    room_id = _nonexistent_room_id()
    resp = device_a.call("ChatRoomManager", Cmd.destroyChatRoom.value, info={"roomId": room_id})
    assert_api.assert_error(resp, code=700, description="do not find this group")


def test_chatroom_join_room_nonexistent_current_behavior(device_b, assert_api):
    room_id = _nonexistent_room_id()
    resp = device_b.call("ChatRoomManager", Cmd.joinChatRoom.value, info={"roomId": room_id})
    # 两端实测均为 303 "Unknown server error"（服务端）—— 705 是 4.x 语义，已过时
    assert_api.assert_error(resp, code=303, description="Unknown server error")


def test_chatroom_join_room_empty_id(device_b, assert_api):
    resp = device_b.call("ChatRoomManager", Cmd.joinChatRoom.value, info={"roomId": ""})
    # 只看 errorcode（描述两端不同: "Chatroom id is invalid" vs "Chat room ID is invalid"）
    assert_api.assert_error(resp, code=700, description=None)


def test_chatroom_leave_room_nonexistent(device_b, assert_api):
    room_id = _nonexistent_room_id()
    resp = device_b.call("ChatRoomManager", Cmd.leaveChatRoom.value, info={"roomId": room_id})
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatRoomManager",
            "cmd": Cmd.leaveChatRoom.value,
            "device": "deviceB",
            "result": True,
        },
        ignore_keys={"sequence"},
    )


def test_chatroom_leave_room_empty_id(device_b, assert_api):
    resp = device_b.call("ChatRoomManager", Cmd.leaveChatRoom.value, info={"roomId": ""})
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatRoomManager",
            "cmd": Cmd.leaveChatRoom.value,
            "device": "deviceB",
            "result": True,
        },
        ignore_keys={"sequence"},
    )


def test_chatroom_fetch_room_info_empty_id(device_a, assert_api):
    resp = device_a.call("ChatRoomManager", Cmd.fetchChatRoomInfoFromServer.value, info={"roomId": ""})
    # 只看 errorcode（描述两端不同: "Chatroom id is invalid" vs "Chat room ID is invalid"）
    assert_api.assert_error(resp, code=700, description=None)


def test_chatroom_fetch_members_nonexistent_room(device_a, assert_api):
    room_id = _nonexistent_room_id()
    resp = device_a.call(
        "ChatRoomManager",
        Cmd.fetchChatRoomMembers.value,
        info={"roomId": room_id, "cursor": "", "pageSize": 20},
    )
    assert_api.assert_error(resp, code=700, description="do not find this group")


def test_chatroom_fetch_members_empty_room_id(device_a, assert_api):
    resp = device_a.call(
        "ChatRoomManager",
        Cmd.fetchChatRoomMembers.value,
        info={"roomId": "", "cursor": "", "pageSize": 20},
    )
    # 只看 errorcode（描述两端不同: "Chatroom id is invalid" vs "Chat room ID is invalid"）
    assert_api.assert_error(resp, code=700, description=None)


@pytest.mark.skip(reason="5.0 移除客户端 destroyChatRoom（残留）")
def test_chatroom_destroy_room_empty_id(device_a, assert_api):
    resp = device_a.call("ChatRoomManager", Cmd.destroyChatRoom.value, info={"roomId": ""})
    # 只看 errorcode（描述两端不同: "Chatroom id is invalid" vs "Chat room ID is invalid"）
    assert_api.assert_error(resp, code=700, description=None)


@pytest.mark.parametrize(
    ("page_num", "page_size"),
    [
        (0, 1),
        (-1, 1),
        (1, 0),
        (1, -1),
    ],
)
def test_chatroom_fetch_public_chat_rooms_invalid_paging(device_a, assert_api, page_num, page_size):
    resp = device_a.call(
        "ChatRoomManager",
        Cmd.fetchPublicChatRoomsFromServer.value,
        info={"pageNum": page_num, "pageSize": page_size},
    )
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatRoomManager",
            "cmd": Cmd.fetchPublicChatRoomsFromServer.value,
            "device": "deviceA",
            "result": {
                "count": ge(0),
            },
        },
        ignore_keys={"sequence", "list"},
    )
    result = resp.get("result")
    assert isinstance(result, dict), f"result 应为 dict，实际: {result!r}"
    room_list = result.get("list")
    assert isinstance(room_list, list), f"result.list 应为 list，实际: {room_list!r}"
    if room_list:
        sample = room_list[0]
        assert isinstance(sample, dict), f"聊天室条目应为 dict，实际: {sample!r}"
        required_keys = {
            "roomId",
            "owner",
            "name",
            "maxUsers",
            "permissionType",
            "isAllMemberMuted",
            "adminList",
            "memberCount",
            "muteList",
            "muteExpireTimestamp",
            "createTimestamp",
            "memberList",
            "isInWhitelist",
            "blockList",
            "desc",
            "announcement",
        }
        missing = sorted(required_keys - set(sample.keys()))
        assert not missing, f"聊天室条目缺少关键字段: {missing}, sample={sample!r}"
