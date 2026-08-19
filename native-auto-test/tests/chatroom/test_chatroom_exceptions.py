from __future__ import annotations

from uuid import uuid4

import pytest

from src import Cmd
from src.tools.response_match import ge
from tests.chatroom.chatroom_helpers import _allure_step


pytestmark = [pytest.mark.client, pytest.mark.chatroom, pytest.mark.agorachat1_4_0]


def _nonexistent_room_id() -> str:
    return f"nonexistent_chatroom_{uuid4().hex[:12]}"


def test_chatroom_fetch_room_info_nonexistent(device_a, assert_api):
    room_id = _nonexistent_room_id()
    with _allure_step("查询不存在聊天室并验证不存在错误"):
        resp = device_a.call("ChatRoomManager", Cmd.fetchChatRoomInfoFromServer.value, info={"roomId": room_id})
        assert_api.assert_error(resp, code=700, description="do not find this group")


@pytest.mark.skip(reason="5.0 移除客户端 destroyChatRoom（残留）")
def test_chatroom_destroy_room_nonexistent(device_a, assert_api):
    room_id = _nonexistent_room_id()
    resp = device_a.call("ChatRoomManager", Cmd.destroyChatRoom.value, info={"roomId": room_id})
    assert_api.assert_error(resp, code=700, description="do not find this group")


def test_chatroom_join_room_nonexistent(device_b, assert_api):
    room_id = _nonexistent_room_id()
    with _allure_step("加入不存在聊天室并验证聊天室不存在错误"):
        resp = device_b.call("ChatRoomManager", Cmd.joinChatRoom.value, info={"roomId": room_id})
        # 官网/官方契约：join 不存在的聊天室应返回 705 CHATROOM_NOT_EXIST
        # （5.0 服务端实测返回 303 "Unknown server error" —— 服务端缺陷，待研发修）
        assert_api.assert_error(resp, code=705, description="Chat room does not exist")


def test_chatroom_join_room_empty_id(device_b, assert_api):
    with _allure_step("使用空聊天室 ID 加入并验证参数错误码"):
        resp = device_b.call("ChatRoomManager", Cmd.joinChatRoom.value, info={"roomId": ""})
        # 只看 errorcode（描述两端不同: "Chatroom id is invalid" vs "Chat room ID is invalid"）
        assert_api.assert_error(resp, code=700, description=None)


def test_chatroom_leave_room_nonexistent(device_b, assert_api):
    room_id = _nonexistent_room_id()
    with _allure_step("离开不存在聊天室并验证幂等成功语义"):
        resp = device_b.call("ChatRoomManager", Cmd.leaveChatRoom.value, info={"roomId": room_id})
        assert_api.assert_response_matches(
            resp,
            expected={"manager": "ChatRoomManager", "cmd": Cmd.leaveChatRoom.value, "device": "deviceB", "result": True},
            ignore_keys={"sequence"},
        )


def test_chatroom_leave_room_empty_id(device_b, assert_api):
    with _allure_step("使用空聊天室 ID 离开并验证幂等成功语义"):
        resp = device_b.call("ChatRoomManager", Cmd.leaveChatRoom.value, info={"roomId": ""})
        assert_api.assert_response_matches(
            resp,
            expected={"manager": "ChatRoomManager", "cmd": Cmd.leaveChatRoom.value, "device": "deviceB", "result": True},
            ignore_keys={"sequence"},
        )


def test_chatroom_fetch_room_info_empty_id(device_a, assert_api):
    with _allure_step("使用空聊天室 ID 查询信息并验证参数错误码"):
        resp = device_a.call("ChatRoomManager", Cmd.fetchChatRoomInfoFromServer.value, info={"roomId": ""})
        # 只看 errorcode（描述两端不同: "Chatroom id is invalid" vs "Chat room ID is invalid"）
        assert_api.assert_error(resp, code=700, description=None)


def test_chatroom_fetch_members_nonexistent_room(device_a, assert_api):
    room_id = _nonexistent_room_id()
    with _allure_step("查询不存在聊天室的成员并验证不存在错误"):
        resp = device_a.call(
            "ChatRoomManager", Cmd.fetchChatRoomMembers.value,
            info={"roomId": room_id, "cursor": "", "pageSize": 20},
        )
        assert_api.assert_error(resp, code=700, description="do not find this group")


def test_chatroom_fetch_members_empty_room_id(device_a, assert_api):
    with _allure_step("使用空聊天室 ID 查询成员并验证参数错误码"):
        resp = device_a.call(
            "ChatRoomManager", Cmd.fetchChatRoomMembers.value,
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
    with _allure_step(f"使用 pageNum={page_num}, pageSize={page_size} 查询公开聊天室并验证分页响应"):
        resp = device_a.call(
            "ChatRoomManager", Cmd.fetchPublicChatRoomsFromServer.value,
            info={"pageNum": page_num, "pageSize": page_size},
        )
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "ChatRoomManager", "cmd": Cmd.fetchPublicChatRoomsFromServer.value,
                "device": "deviceA", "result": {"count": ge(0)},
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
