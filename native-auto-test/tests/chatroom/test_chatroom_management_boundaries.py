"""ChatRoom 管理类接口边界/异常用例。"""
from __future__ import annotations

import pytest

from src import Cmd, ne
from tests.chatroom.chatroom_helpers import _allure_step, create_chatroom_or_skip, safe_delete_chatroom
from tests.chatroom.test_chatroom_management_basics import _join_chatroom_as_b


pytestmark = [pytest.mark.client, pytest.mark.chatroom, pytest.mark.agorachat4_23_0]


NONEXISTENT_USER = "nonexistent_chatroom_user_999999"
SUBJECT_TOO_LONG = "s" * 1025
DESCRIPTION_TOO_LONG = "d" * 4097


def _assert_error_result(
    assert_api,
    resp: dict,
    *,
    cmd: str,
    code: int,
    description: str | None,
    device: str = "deviceA",
) -> None:
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatRoomManager",
            "cmd": cmd,
            "device": device,
            "result": {"code": code},
        },
        ignore_keys={"sequence"},
    )


def _assert_room_result(
    assert_api,
    resp: dict,
    *,
    cmd: str,
    room_id: str,
    owner: str,
    name: str,
    desc: str = "nothing left here",
    permission_type: int = 2,
    member_list: list[str] | None = None,
) -> None:
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatRoomManager",
            "cmd": cmd,
            "device": "deviceA",
            "result": {
                "owner": owner,
                "maxUsers": 200,
                "permissionType": permission_type,
                "isAllMemberMuted": False,
                "adminList": [],
                "memberCount": 1,
                "muteList": [],
                "muteExpireTimestamp": -1,
                "roomId": room_id,
                "createTimestamp": 0,
                "memberList": member_list or [],
                "isInWhitelist": False,
                "blockList": [],
                "name": name,
                "desc": desc,
                "announcement": "",
            },
        },
        ignore_keys={"sequence"},
    )


def test_chatroom_change_subject_empty_success(device_a, assert_api, user_a):
    """changeChatRoomSubject：聊天室名称允许置为空，实测返回完整聊天室对象且 name 为空字符串。"""
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="meta_boundary", desc_prefix="meta_boundary")
    try:
        with _allure_step("将聊天室名称置空并验证返回的聊天室状态"):
            resp = device_a.call(
                "ChatRoomManager", Cmd.changeChatRoomSubject.value,
                info={"roomId": room_id, "subject": ""},
            )
            _assert_room_result(assert_api, resp, cmd=Cmd.changeChatRoomSubject.value, room_id=room_id, owner=user_a, name="")
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_change_subject_too_long(device_a, assert_api, user_a):
    """changeChatRoomSubject：名称超过 1024 字符，实测返回 703/title cannot exceed to 1024。"""
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="meta_boundary", desc_prefix="meta_boundary")
    try:
        with _allure_step("提交超长聊天室名称并验证长度错误"):
            resp = device_a.call(
                "ChatRoomManager", Cmd.changeChatRoomSubject.value,
                info={"roomId": room_id, "subject": SUBJECT_TOO_LONG},
            )
            _assert_error_result(assert_api, resp, cmd=Cmd.changeChatRoomSubject.value, code=703, description="title cannot exceed to 1024")
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_change_description_empty_success(device_a, assert_api, user_a):
    """changeChatRoomDescription：聊天室描述允许置为空，实测返回完整聊天室对象且 desc 为空字符串。"""
    room_id, room_name = create_chatroom_or_skip(
        owner=user_a,
        name_prefix="meta_boundary",
        desc_prefix="meta_boundary",
    )
    try:
        with _allure_step("将聊天室描述置空并验证返回状态"):
            resp = device_a.call(
                "ChatRoomManager", Cmd.changeChatRoomDescription.value,
                info={"roomId": room_id, "description": ""},
            )
            _assert_room_result(
                assert_api, resp, cmd=Cmd.changeChatRoomDescription.value,
                room_id=room_id, owner=user_a, name=room_name, desc="",
            )
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_change_description_too_long(device_a, assert_api, user_a):
    """changeChatRoomDescription：描述超过 4096 字符，实测返回 703/desc cannot exceed to 4096。"""
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="meta_boundary", desc_prefix="meta_boundary")
    try:
        with _allure_step("提交超长聊天室描述并验证长度错误"):
            resp = device_a.call(
                "ChatRoomManager", Cmd.changeChatRoomDescription.value,
                info={"roomId": room_id, "description": DESCRIPTION_TOO_LONG},
            )
            _assert_error_result(assert_api, resp, cmd=Cmd.changeChatRoomDescription.value, code=703, description="desc cannot exceed to 4096")
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_update_announcement_empty(device_a, assert_api, user_a):
    """updateChatRoomAnnouncement：公告允许置为空，实测返回 True。"""
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="announcement_empty", desc_prefix="announcement_empty")
    try:
        with _allure_step("将聊天室公告置空并验证返回成功"):
            resp = device_a.call(
                "ChatRoomManager", Cmd.updateChatRoomAnnouncement.value,
                info={"roomId": room_id, "announcement": ""},
            )
            assert_api.assert_response_matches(
                resp,
                expected={"manager": "ChatRoomManager", "cmd": Cmd.updateChatRoomAnnouncement.value, "device": "deviceA", "result": True},
                ignore_keys={"sequence"},
            )
    finally:
        safe_delete_chatroom(room_id)


@pytest.mark.parametrize(
    ("cmd", "member_key", "expected_code", "expected_description"),
    [
        # addMembersToChatRoomWhiteList：验证白名单添加空 members 的参数边界。
        (Cmd.addMembersToChatRoomWhiteList.value, "members", 110, "usernames is null or empty!"),
        # removeMembersFromChatRoomWhiteList：验证白名单移除空 members 的参数边界。
        (Cmd.removeMembersFromChatRoomWhiteList.value, "members", 300, "Server is unreachable"),
        # muteChatRoomMembers：验证禁言空 muteMembers 的参数边界。
        (Cmd.muteChatRoomMembers.value, "muteMembers", 602, "users [] are not members of this group!"),
        # unMuteChatRoomMembers：验证解除禁言空 unMuteMembers 的参数边界。
        (Cmd.unMuteChatRoomMembers.value, "unMuteMembers", 300, "Server is unreachable"),
        # blockChatRoomMembers：验证黑名单添加空 members 的参数边界。
        (Cmd.blockChatRoomMembers.value, "members", 110, "usernames is null or empty!"),
        # unBlockChatRoomMembers：验证黑名单移除空 members 的参数边界。
        (Cmd.unBlockChatRoomMembers.value, "members", 300, "Server is unreachable"),
        # removeChatRoomMembers：验证踢人空 members 的参数边界。
        (Cmd.removeChatRoomMembers.value, "members", 300, "Server is unreachable"),
    ],
)
def test_chatroom_member_management_empty_members(
    device_a,
    assert_api,
    user_a,
    cmd,
    member_key,
    expected_code,
    expected_description,
):
    """成员管理接口：成员列表为空时，逐方法锁定真实错误码与错误描述。"""
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="empty_members", desc_prefix="empty_members")
    try:
        with _allure_step("提交空成员列表管理请求并验证当前错误响应"):
            info = {"roomId": room_id, member_key: []}
            if cmd == Cmd.muteChatRoomMembers.value:
                info["duration"] = 60000
            resp = device_a.call("ChatRoomManager", cmd, info=info)
            _assert_error_result(assert_api, resp, cmd=cmd, code=expected_code, description=expected_description)
    finally:
        safe_delete_chatroom(room_id)


@pytest.mark.parametrize(
    ("cmd", "info", "expected"),
    [
        # addChatRoomAdmin：添加不存在用户为管理员，验证用户不存在错误。
        (Cmd.addChatRoomAdmin.value, {"admin": NONEXISTENT_USER}, (700, f"username {NONEXISTENT_USER} doesn't exist!")),
        # removeChatRoomAdmin：移除不存在用户管理员身份，验证非管理员错误。
        (
            Cmd.removeChatRoomAdmin.value,
            {"admin": NONEXISTENT_USER},
            (703, f"user:{NONEXISTENT_USER} is not admin of group:{{room_id}}"),
        ),
        # changeChatRoomOwner：转让 owner 给不存在用户，验证用户不存在错误。
        (Cmd.changeChatRoomOwner.value, {"newOwner": NONEXISTENT_USER}, (700, f"username {NONEXISTENT_USER} doesn't exist!")),
        # addMembersToChatRoomWhiteList：添加不存在用户进白名单，验证非聊天室成员错误。
        (
            Cmd.addMembersToChatRoomWhiteList.value,
            {"members": [NONEXISTENT_USER]},
            (703, f"users [{NONEXISTENT_USER}] are not members of this group!"),
        ),
        # removeMembersFromChatRoomWhiteList：移除不存在用户白名单，验证当前幂等成功语义。
        (Cmd.removeMembersFromChatRoomWhiteList.value, {"members": [NONEXISTENT_USER]}, None),
        # muteChatRoomMembers：禁言不存在用户，验证非聊天室成员错误。
        (
            Cmd.muteChatRoomMembers.value,
            {"muteMembers": [NONEXISTENT_USER], "duration": 60000},
            (602, f"users [{NONEXISTENT_USER}] are not members of this group!"),
        ),
        # unMuteChatRoomMembers：解除不存在用户禁言，验证当前幂等成功语义。
        (Cmd.unMuteChatRoomMembers.value, {"unMuteMembers": [NONEXISTENT_USER]}, "room"),
        # blockChatRoomMembers：拉黑不存在用户，验证非聊天室成员错误。
        (
            Cmd.blockChatRoomMembers.value,
            {"members": [NONEXISTENT_USER]},
            (703, f"users [{NONEXISTENT_USER}] are not members of this group!"),
        ),
        # unBlockChatRoomMembers：解除不存在用户黑名单，验证当前幂等成功语义。
        (Cmd.unBlockChatRoomMembers.value, {"members": [NONEXISTENT_USER]}, "room"),
        # removeChatRoomMembers：踢出不存在用户，验证非聊天室成员错误。
        (
            Cmd.removeChatRoomMembers.value,
            {"members": [NONEXISTENT_USER]},
            (703, f"users [{NONEXISTENT_USER}] are not members of this group!"),
        ),
    ],
)
def test_chatroom_member_management_nonexistent_user(device_a, assert_api, user_a, cmd, info, expected):
    """成员管理接口：传入不存在用户时，逐方法锁定真实错误或幂等成功响应。"""
    room_id, room_name = create_chatroom_or_skip(owner=user_a, name_prefix="bad_member", desc_prefix="bad_member")
    try:
        with _allure_step("提交不存在用户的成员管理请求并验证真实响应"):
            payload = {"roomId": room_id, **info}
            resp = device_a.call("ChatRoomManager", cmd, info=payload)
            if expected is None:
                assert_api.assert_response_matches(
                    resp,
                    expected={"manager": "ChatRoomManager", "cmd": cmd, "device": "deviceA", "result": ne(None)},
                    ignore_keys={"sequence"},
                )
                return
            if expected == "room":
                _assert_room_result(assert_api, resp, cmd=cmd, room_id=room_id, owner=user_a, name=room_name)
                return
            code, description = expected
            _assert_error_result(assert_api, resp, cmd=cmd, code=code, description=description.replace("{room_id}", room_id))
    finally:
        safe_delete_chatroom(room_id)


@pytest.mark.parametrize(
    ("cmd", "info", "expected"),
    [
        # addChatRoomAdmin：真实 user_b 未加入聊天室时添加管理员，验证当前返回聊天室对象语义。
        (Cmd.addChatRoomAdmin.value, {"admin": "{{user_b}}"}, "room"),
        # removeChatRoomAdmin：真实 user_b 未加入且不是管理员时移除管理员，验证非管理员错误。
        (
            Cmd.removeChatRoomAdmin.value,
            {"admin": "{{user_b}}"},
            (703, "user:{{user_b}} is not admin of group:{{room_id}}"),
        ),
        # changeChatRoomOwner：真实 user_b 未加入聊天室时转让 owner，验证当前允许转让语义。
        (Cmd.changeChatRoomOwner.value, {"newOwner": "{{user_b}}"}, "owner_changed"),
        # removeChatRoomMembers：真实 user_b 未加入聊天室时踢出，验证非聊天室成员错误。
        (
            Cmd.removeChatRoomMembers.value,
            {"members": ["{{user_b}}"]},
            (703, "users [{{user_b}}] are not members of this group!"),
        ),
    ],
)
def test_chatroom_member_management_non_member(device_a, assert_api, user_a, user_b, cmd, info, expected):
    """成员管理接口：真实用户未加入聊天室时，逐方法锁定当前成功/失败语义。"""
    room_id, room_name = create_chatroom_or_skip(owner=user_a, name_prefix="non_member", desc_prefix="non_member")
    try:
        with _allure_step("对未加入成员执行聊天室管理操作并验证成功或错误语义"):
            payload = {"roomId": room_id}
            for key, value in info.items():
                if isinstance(value, str):
                    payload[key] = value.replace("{{user_b}}", user_b)
                else:
                    payload[key] = [item.replace("{{user_b}}", user_b) for item in value]
            resp = device_a.call("ChatRoomManager", cmd, info=payload)
            if expected == "room":
                _assert_room_result(assert_api, resp, cmd=cmd, room_id=room_id, owner=user_a, name=room_name)
                return
            if expected == "owner_changed":
                _assert_room_result(
                    assert_api, resp, cmd=cmd, room_id=room_id, owner=user_b, name=room_name,
                    permission_type=0, member_list=[user_a],
                )
                return
            code, description = expected
            _assert_error_result(
                assert_api, resp, cmd=cmd, code=code,
                description=description.replace("{{user_b}}", user_b).replace("{{room_id}}", room_id),
            )
    finally:
        safe_delete_chatroom(room_id)


@pytest.mark.parametrize(
    ("page_num", "page_size"),
    [
        # pageNum=0：验证成员分页页码为 0 时的当前容错返回。
        (0, 20),
        # pageNum=-1：验证成员分页页码为负数时的当前容错返回。
        (-1, 20),
        # pageSize=0：验证成员分页大小为 0 时的当前容错返回。
        (1, 0),
        # pageSize=-1：验证成员分页大小为负数时的当前容错返回。
        (1, -1),
    ],
)
def test_chatroom_fetch_members_invalid_paging(device_a, device_b, assert_api, user_a, user_b, page_num, page_size):
    """fetchChatRoomMembers：非法 pageNum/pageSize 当前仍返回 cursor 结构与成员列表。"""
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="members_page_bad", desc_prefix="members_page_bad")
    try:
        with _allure_step("B 加入聊天室并验证非法成员分页参数仍返回成员列表"):
            _join_chatroom_as_b(device_b, assert_api, room_id)
            resp = device_a.call(
                "ChatRoomManager", Cmd.fetchChatRoomMembers.value,
                info={"roomId": room_id, "cursor": "", "pageSize": page_size, "pageNum": page_num},
            )
            assert_api.assert_response_matches(
                resp,
                expected={
                    "manager": "ChatRoomManager", "cmd": Cmd.fetchChatRoomMembers.value, "device": "deviceA",
                    "result": {"cursor": "", "list": [user_b]},
                },
                ignore_keys={"sequence"},
            )
    finally:
        safe_delete_chatroom(room_id)


@pytest.mark.parametrize(
    ("cmd", "page_num", "page_size"),
    [
        # fetchChatRoomMuteList pageNum=0：验证禁言列表页码为 0 时的当前容错返回。
        (Cmd.fetchChatRoomMuteList.value, 0, 20),
        # fetchChatRoomMuteList pageNum=-1：验证禁言列表页码为负数时的当前容错返回。
        (Cmd.fetchChatRoomMuteList.value, -1, 20),
        # fetchChatRoomMuteList pageSize=0：验证禁言列表分页大小为 0 时的当前容错返回。
        (Cmd.fetchChatRoomMuteList.value, 1, 0),
        # fetchChatRoomMuteList pageSize=-1：验证禁言列表分页大小为负数时的当前容错返回。
        (Cmd.fetchChatRoomMuteList.value, 1, -1),
        # fetchChatRoomBlockList pageNum=0：验证黑名单列表页码为 0 时的当前容错返回。
        (Cmd.fetchChatRoomBlockList.value, 0, 20),
        # fetchChatRoomBlockList pageNum=-1：验证黑名单列表页码为负数时的当前容错返回。
        (Cmd.fetchChatRoomBlockList.value, -1, 20),
        # fetchChatRoomBlockList pageSize=0：验证黑名单列表分页大小为 0 时的当前容错返回。
        (Cmd.fetchChatRoomBlockList.value, 1, 0),
        # fetchChatRoomBlockList pageSize=-1：验证黑名单列表分页大小为负数时的当前容错返回。
        (Cmd.fetchChatRoomBlockList.value, 1, -1),
    ],
)
def test_chatroom_server_member_list_invalid_paging(device_a, assert_api, user_a, cmd, page_num, page_size):
    """fetchChatRoomMuteList/fetchChatRoomBlockList：非法分页参数当前容错返回空列表。"""
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="list_page_bad", desc_prefix="list_page_bad")
    try:
        with _allure_step("使用非法分页参数查询聊天室成员名单并验证空列表响应"):
            resp = device_a.call(
                "ChatRoomManager", cmd,
                info={"roomId": room_id, "pageNum": page_num, "pageSize": page_size},
            )
            assert_api.assert_response_matches(
                resp,
                expected={"manager": "ChatRoomManager", "cmd": cmd, "device": "deviceA", "result": []},
                ignore_keys={"sequence"},
            )
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_add_attributes_empty_map(device_a, assert_api, user_a):
    """setChatRoomAttributes：attributes 为空 map 时，实测返回 110 且 description 为空字符串。"""
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="attr_empty", desc_prefix="attr_empty")
    try:
        with _allure_step("提交空聊天室属性 map 并验证参数错误"):
            resp = device_a.call(
                "ChatRoomManager", Cmd.setChatRoomAttributes.value,
                info={"roomId": room_id, "attributes": {}, "autoDelete": False, "forced": True},
            )
            _assert_error_result(assert_api, resp, cmd=Cmd.setChatRoomAttributes.value, code=110, description="")
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_remove_attributes_empty_keys(device_a, assert_api, user_a):
    """removeChatRoomAttributes：keys 为空列表时，实测返回 110 且 description 为空字符串。"""
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="attr_keys_empty", desc_prefix="attr_keys_empty")
    try:
        with _allure_step("提交空聊天室属性 key 列表并验证参数错误"):
            resp = device_a.call(
                "ChatRoomManager", Cmd.removeChatRoomAttributes.value,
                info={"roomId": room_id, "keys": [], "forced": True},
            )
            _assert_error_result(assert_api, resp, cmd=Cmd.removeChatRoomAttributes.value, code=110, description="")
    finally:
        safe_delete_chatroom(room_id)


@pytest.mark.parametrize(
    "cmd",
    [
        # isMemberInChatRoomWhiteListFromServer：验证白名单自查空 roomId 参数错误。
        Cmd.isMemberInChatRoomWhiteListFromServer.value,
        # isMemberInChatRoomMuteList：验证禁言自查空 roomId 参数错误。
        Cmd.isMemberInChatRoomMuteList.value,
    ],
)
def test_chatroom_member_self_checks_empty_room_id(device_a, assert_api, cmd):
    """白名单/禁言自查接口：roomId 为空时返回 700；description 由平台 SDK 决定。"""
    with _allure_step("使用空聊天室 ID 查询成员状态并验证参数错误"):
        resp = device_a.call("ChatRoomManager", cmd, info={"roomId": ""})
        _assert_error_result(assert_api, resp, cmd=cmd, code=700, description=None)
