from __future__ import annotations

from uuid import uuid4

import pytest

from src import Cmd, ne
from src.tools.response_match import ge
from tests.chatroom.chatroom_helpers import _allure_step, assert_join_chatroom_response, create_chatroom_or_skip, safe_delete_chatroom


pytestmark = [pytest.mark.client, pytest.mark.chatroom, pytest.mark.agorachat1_4_0]


@pytest.mark.skip(reason="5.0 移除客户端 createChatRoom（残留，聊天室由服务端创建）")
def test_chatroom_create_room_via_sdk_without_permission(device_a, assert_api):
    room_name = f"sdk_create_{uuid4().hex[:8]}"
    room_desc = f"sdk_desc_{uuid4().hex[:8]}"
    resp = device_a.call(
        "ChatRoomManager",
        Cmd.createChatRoom.value,
        info={
            "subject": room_name,
            "desc": room_desc,
            "welcomeMsg": "welcome",
            "maxUserCount": 200,
            "members": [],
        },
    )
    assert_api.assert_error(resp, code=703, description="you have no permission to do this.")


def test_chatroom_create_and_fetch_from_server(device_a, assert_api, user_a):
    room_id, room_name = create_chatroom_or_skip(owner=user_a, name_prefix="create", desc_prefix="create")
    try:
        with _allure_step("创建聊天室后查询服务端信息并验证 owner 与默认字段"):
            resp = device_a.call("ChatRoomManager", Cmd.fetchChatRoomInfoFromServer.value, info={"roomId": room_id})
            assert_api.assert_response_matches(
                resp,
                expected={
                    "manager": "ChatRoomManager", "cmd": Cmd.fetchChatRoomInfoFromServer.value,
                    "device": device_a.device_name,
                    "result": {
                        "roomId": room_id, "owner": user_a, "name": room_name, "maxUsers": 200, "memberCount": 1,
                        "permissionType": 2, "isAllMemberMuted": False, "adminList": [], "muteList": [],
                        "muteExpireTimestamp": -1, "createTimestamp": ge(0), "memberList": [], "isInWhitelist": False,
                        "blockList": [], "desc": "nothing left here", "announcement": "",
                    },
                },
                ignore_keys={"sequence"},
            )
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_fetch_room_info_with_members_from_server(device_a, device_b, assert_api, user_a, user_b):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="fetch_members", desc_prefix="fetch_members")
    try:
        with _allure_step("B 加入聊天室并验证成员查询前置"):
            join_resp = device_b.call("ChatRoomManager", Cmd.joinChatRoom.value, info={"roomId": room_id})
            assert_join_chatroom_response(assert_api, join_resp, device=device_b.device_name, room_id=room_id)

        with _allure_step("查询聊天室概要并验证成员计数"):
            resp = device_a.call(
                "ChatRoomManager", Cmd.fetchChatRoomInfoFromServer.value, info={"roomId": room_id}
            )
            assert_api.assert_response_matches(
                resp,
                expected={
                    "manager": "ChatRoomManager", "cmd": Cmd.fetchChatRoomInfoFromServer.value,
                    "device": device_a.device_name, "result": {"roomId": room_id, "owner": user_a, "memberCount": 2, "memberList": ne(None)},
                },
                ignore_keys={"sequence", "name", "maxUsers", "permissionType", "isAllMemberMuted", "adminList", "muteList", "muteExpireTimestamp", "createTimestamp", "isInWhitelist", "blockList", "desc", "announcement"},
            )
            result = resp.get("result")
            assert isinstance(result, dict), f"fetchChatRoomInfoFromServer result 应为 dict: {resp}"
            assert isinstance(result.get("memberList"), list), f"fetchChatRoomInfoFromServer memberList 应为 list: {resp}"

        with _allure_step("分页查询聊天室成员并验证 B 在列表中"):
            members_resp = device_a.call(
                "ChatRoomManager", Cmd.fetchChatRoomMembers.value,
                info={"roomId": room_id, "cursor": "", "pageSize": 20},
            )
            assert_api.assert_response_matches(
                members_resp,
                expected={
                    "manager": "ChatRoomManager", "cmd": Cmd.fetchChatRoomMembers.value,
                    "device": device_a.device_name, "result": {"cursor": "", "list": [user_b]},
                },
                ignore_keys={"sequence"},
            )
    finally:
        safe_delete_chatroom(room_id)


@pytest.mark.skip(reason="5.0 移除客户端 destroyChatRoom（残留，聊天室由服务端销毁）")
def test_chatroom_destroy_room_success(device_a, assert_api, user_a):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="destroy", desc_prefix="destroy")
    resp = device_a.call("ChatRoomManager", Cmd.destroyChatRoom.value, info={"roomId": room_id})
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatRoomManager",
            "cmd": Cmd.destroyChatRoom.value,
            "device": device_a.device_name,
            "result": True,
        },
        ignore_keys={"sequence"},
    )


def test_chatroom_fetch_room_info_from_server_after_destroy(device_a, assert_api, user_a):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="destroy_fetch", desc_prefix="destroy_fetch")
    # 5.0 客户端 destroyChatRoom 移除 → REST 服务端销毁
    with _allure_step("测试准备：销毁服务端聊天室"):
        safe_delete_chatroom(room_id)
    with _allure_step("查询已销毁聊天室并验证不存在错误"):
        resp_fetch = device_a.call("ChatRoomManager", Cmd.fetchChatRoomInfoFromServer.value, info={"roomId": room_id})
        assert_api.assert_error(resp_fetch, code=700, description="do not find this group")
