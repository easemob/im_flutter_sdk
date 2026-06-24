"""Group remaining API coverage: normal and boundary cases."""
from __future__ import annotations

import uuid

import pytest

from src import Cmd
from tests.group.group_helpers import create_group, destroy_group, new_group_name


pytestmark = [pytest.mark.client, pytest.mark.group, pytest.mark.agorachat1_4_0]


NONEXISTENT_GROUP_ID = "nonexistent_group_remaining_999999"


def _assert_error_result(assert_api, resp: dict, *, cmd: str, code: int, description: str) -> None:
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "GroupManager",
            "cmd": cmd,
            "device": "deviceA",
            "result": {
                "code": code,
                "description": description,
            },
        },
        ignore_keys={"sequence"},
    )


def test_group_clear_all_groups_from_local_success(device_a, assert_api, user_a):
    """clearAllGroupsFromLocal：清理本地群缓存，实测成功返回 None。"""
    resp = device_a.call("GroupManager", Cmd.clearAllGroupsFromDB.value)
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.clearAllGroupsFromDB.value,
            "device": "deviceA",
            "result": None,
        },
        ignore_keys={"sequence"},
    )


def test_group_fetch_members_info_empty_group_id(device_a, assert_api):
    """fetchGroupMembersInfo：groupId 为空字符串时，冻结真实错误返回。"""
    resp = device_a.call(
        "GroupManager",
        Cmd.fetchGroupMembersInfo.value,
        info={"groupId": "", "cursor": None, "limit": 20},
    )
    _assert_error_result(
        assert_api,
        resp,
        cmd=Cmd.fetchGroupMembersInfo.value,
        code=600,
        description="Group ID is invalid",
    )


def test_group_fetch_members_info_invalid_limit(device_a, assert_api, user_a):
    """fetchGroupMembersInfo：limit=0 的分页边界，并比对成员资料与当前用户资料一致。"""
    group_id = ""
    try:
        resp_user_info = device_a.call(
            "UserInfoManager",
            Cmd.fetchUserInfoById.value,
            info={"userIds": [user_a]},
        )
        assert_api.assert_response_matches(
            resp_user_info,
            expected={
                "manager": "UserInfoManager",
                "cmd": Cmd.fetchUserInfoById.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )
        current_user_info = (resp_user_info.get("result") or {}).get(user_a) or {}
        current_nickname = current_user_info.get("nickName") or ""
        current_avatar_url = current_user_info.get("avatarUrl") or ""

        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("member_info_limit"),
            invite_members=[],
        )
        resp = device_a.call(
            "GroupManager",
            Cmd.fetchGroupMembersInfo.value,
            info={"groupId": group_id, "cursor": None, "limit": 0},
        )
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.fetchGroupMembersInfo.value,
                "device": "deviceA",
                "result": {
                    "cursor": "",
                    "list": [
                        {
                            "namecard": "",
                            "role": 2,
                            "avatarUrl": current_avatar_url,
                            "nickname": current_nickname,
                            "userId": user_a,
                            "memberId": user_a,
                        }
                    ],
                },
            },
            ignore_keys={"sequence", "joinedTs", "joinTime", "string"},
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_update_avatar_success(device_a, assert_api, user_a):
    """updateGroupAvatar：群主更新群头像 URL，返回群对象中 avatarUrl 为新值。"""
    group_id = ""
    avatar_url = f"https://example.com/group-avatar/{uuid.uuid4().hex}.png"
    try:
        group_id, group_resp = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("avatar"),
            invite_members=[],
        )
        group_name = (group_resp.get("result") or {}).get("name")
        resp = device_a.call(
            "GroupManager",
            Cmd.updateGroupAvatar.value,
            info={"groupId": group_id, "avatarUrl": avatar_url},
        )
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.updateGroupAvatar.value,
                "device": "deviceA",
                "result": {
                    "groupId": group_id,
                    "name": group_name,
                    "owner": user_a,
                    "ext": "auto-ext",
                    "avatarUrl": avatar_url,
                    "memberCount": 1,
                    "isMemberOnly": True,
                    "isMemberAllowToInvite": False,
                    "messageBlocked": False,
                    "maxUserCount": 200,
                },
            },
            ignore_keys={
                "sequence",
                "desc",
                "memberList",
                "adminList",
                "blockList",
                "muteList",
                "permissionType",
                "isAllMemberMuted",
                "isDisabled",
                "isMemberOnly",
                "announcement",
                "sharedFiles",
                "options",
            },
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


@pytest.mark.parametrize(
    "avatar_url",
    [
        # updateGroupAvatar：头像 URL 为空字符串，当前实测允许置空并返回群对象。
        "",
        # updateGroupAvatar：头像 URL 超长，当前实测允许写入并返回群对象。
        "https://example.com/" + ("a" * 2048),
    ],
)
def test_group_update_avatar_abnormal_values(
    device_a,
    assert_api,
    user_a,
    avatar_url,
):
    group_id = ""
    try:
        group_id, group_resp = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("avatar_bad"),
            invite_members=[],
        )
        group_name = (group_resp.get("result") or {}).get("name")
        resp = device_a.call(
            "GroupManager",
            Cmd.updateGroupAvatar.value,
            info={"groupId": group_id, "avatarUrl": avatar_url},
        )
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.updateGroupAvatar.value,
                "device": "deviceA",
                "result": {
                    "groupId": group_id,
                    "name": group_name,
                    "owner": user_a,
                    "ext": "auto-ext",
                    "avatarUrl": avatar_url,
                    "memberCount": 1,
                    "isMemberOnly": True,
                    "isMemberAllowToInvite": False,
                    "messageBlocked": False,
                    "maxUserCount": 200,
                },
            },
            ignore_keys={
                "sequence",
                "desc",
                "memberList",
                "adminList",
                "blockList",
                "muteList",
                "permissionType",
                "isAllMemberMuted",
                "isDisabled",
                "announcement",
                "sharedFiles",
                "options",
            },
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_update_avatar_empty_group_id(device_a, assert_api):
    """updateGroupAvatar：groupId 为空字符串时，冻结真实错误返回。"""
    resp = device_a.call(
        "GroupManager",
        Cmd.updateGroupAvatar.value,
        info={"groupId": "", "avatarUrl": "https://example.com/group-avatar/empty.png"},
    )
    _assert_error_result(
        assert_api,
        resp,
        cmd=Cmd.updateGroupAvatar.value,
        code=600,
        description="Group ID is invalid",
    )
