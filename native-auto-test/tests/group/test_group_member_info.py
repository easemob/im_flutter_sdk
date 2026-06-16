"""Group member info regression cases."""
from __future__ import annotations

import time

import pytest

from src import Cmd
from tests.group.group_helpers import create_group, destroy_group, new_group_name


pytestmark = [pytest.mark.client, pytest.mark.group, pytest.mark.agorachat1_4_0]


def _cursor_list(resp: dict) -> list[dict]:
    result = resp.get("result")
    assert isinstance(result, dict), f"fetchGroupMembersInfo result 不是 dict: {resp}"
    members = result.get("list")
    assert isinstance(members, list), f"fetchGroupMembersInfo result.list 不是 list: {resp}"
    for idx, item in enumerate(members):
        assert isinstance(item, dict), f"fetchGroupMembersInfo list[{idx}] 不是 dict: {item!r}"
    return members


def _find_member(members: list[dict], user_id: str) -> dict:
    for item in members:
        if item.get("userId") == user_id or item.get("memberId") == user_id:
            return item
    raise AssertionError(f"成员信息列表未包含当前用户: user_id={user_id}, members={members}")


def _assert_text_contains(text: str, expected_parts: list[str], *, field_name: str, member: dict) -> None:
    missing = [part for part in expected_parts if part not in text]
    assert not missing, (
        f"{field_name} 未体现预期字段: missing={missing}, text={text!r}, member={member}"
    )


def test_group_fetch_members_info_contains_updated_own_profile(device_a, assert_api, user_a):
    """更新本人昵称/头像后，fetchGroupMembersInfo 返回的本人 EMGroupMemberInfo 字段保持一致。"""
    group_id = ""
    ts = int(time.time() * 1000)
    nickname = f"group-member-nick-{ts}"
    avatar_url = f"https://example.com/avatar/{user_a}-{ts}.png"

    try:
        resp_update = device_a.call(
            "UserInfoManager",
            Cmd.updateOwnUserInfo.value,
            info={"nickName": nickname, "avatarUrl": avatar_url},
        )
        assert_api.assert_response_matches(
            resp_update,
            expected={
                "manager": "UserInfoManager",
                "cmd": Cmd.updateOwnUserInfo.value,
                "device": "deviceA",
                "result": {
                    "userId": user_a,
                    "nickName": nickname,
                    "avatarUrl": avatar_url,
                },
            },
            ignore_keys={"sequence", "ext", "phone", "birth", "gender", "mail", "sign"},
        )

        resp_fetch_user = device_a.call(
            "UserInfoManager",
            Cmd.fetchUserInfoById.value,
            info={"userIds": [user_a]},
        )
        fetched_user = (resp_fetch_user.get("result") or {}).get(user_a)
        assert isinstance(fetched_user, dict), f"fetchUserInfoById 未返回当前用户资料: {resp_fetch_user}"
        assert fetched_user.get("nickName") == nickname, f"昵称未更新成功: {resp_fetch_user}"
        assert fetched_user.get("avatarUrl") == avatar_url, f"头像未更新成功: {resp_fetch_user}"

        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("member_info"),
            invite_members=[],
        )

        resp_member_info = device_a.call(
            "GroupManager",
            Cmd.fetchGroupMembersInfo.value,
            info={"groupId": group_id, "cursor": None, "limit": 50},
        )
        assert_api.assert_response_matches(
            resp_member_info,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.fetchGroupMembersInfo.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )

        members = _cursor_list(resp_member_info)
        own_member = _find_member(members, user_a)
        assert own_member.get("userId") == user_a, f"userId 不匹配: {own_member}"
        assert own_member.get("memberId") == user_a, f"memberId 不匹配: {own_member}"

        join_time = own_member.get("joinTime", own_member.get("joinedTs"))
        assert isinstance(join_time, int) and join_time > 0, f"joinTime/joinedTs 非法: {own_member}"
        assert isinstance(own_member.get("namecard"), str), f"namecard 不可正常获取: {own_member}"
        assert own_member.get("nickname") == nickname, f"成员昵称与用户资料不一致: {own_member}"
        assert own_member.get("avatarUrl") == avatar_url, f"成员头像与用户资料不一致: {own_member}"
        assert own_member.get("role") in (0, 1, 2), f"role 不是有效群角色: {own_member}"

        string_value = own_member.get("string")
        assert isinstance(string_value, str), f"toString 映射字段不是字符串: {own_member}"
        _assert_text_contains(
            string_value,
            [user_a, nickname, avatar_url],
            field_name="toString/string",
            member=own_member,
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)
