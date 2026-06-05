"""Group inviterUser 异常用例（strict）。"""
from __future__ import annotations

import pytest

from src import Cmd
from tests.group.group_helpers import create_group, destroy_group, new_group_name


pytestmark = [pytest.mark.client, pytest.mark.group]


_NONEXISTENT_GROUP_ID = "nonexistent_group_999999"
_NONEXISTENT_USER = "nonexistent_user_999999"


def test_group_inviter_user_nonexistent_group(device_a, assert_api, user_b):
    resp = device_a.call(
        "GroupManager",
        Cmd.inviterUser.value,
        info={"groupId": _NONEXISTENT_GROUP_ID, "members": [user_b], "reason": "auto-inviter"},
    )
    assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_inviter_user_empty_members(device_a, assert_api, user_a):
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("ex_inviter_empty"),
            invite_members=[],
        )
        resp = device_a.call(
            "GroupManager",
            Cmd.inviterUser.value,
            info={"groupId": group_id, "members": [], "reason": "auto-inviter"},
        )
        # 当前端稳定语义：空 members 调用成功
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.inviterUser.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_inviter_user_nonexistent_user(device_a, assert_api, user_a):
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("ex_inviter_user"),
            invite_members=[],
        )
        resp = device_a.call(
            "GroupManager",
            Cmd.inviterUser.value,
            info={"groupId": group_id, "members": [_NONEXISTENT_USER], "reason": "auto-inviter"},
        )
        assert_api.assert_error(resp, code=603, description="doesn't exist")
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)
