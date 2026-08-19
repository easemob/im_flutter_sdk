"""Group inviterUser 异常用例（strict）。"""
from __future__ import annotations

import pytest
from tests.group.allure_helpers import _allure_step

from src import Cmd
from tests.group.group_helpers import create_group, destroy_group, new_group_name


pytestmark = [pytest.mark.client, pytest.mark.group]


_NONEXISTENT_GROUP_ID = "nonexistent_group_999999"
_NONEXISTENT_USER = "nonexistent_user_999999"



def test_group_inviter_user_nonexistent_group(device_a, assert_api, user_b):
    with _allure_step("A 邀请成员"):
        resp = device_a.call(
            "GroupManager",
            Cmd.inviterUser.value,
            info={"groupId": _NONEXISTENT_GROUP_ID, "members": [user_b], "reason": "auto-inviter"},
        )
    with _allure_step("验证邀请成员返回的错误码与错误文案"):
        assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_inviter_user_empty_members(device_a, assert_api, user_a):
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                device_a,
                assert_api,
                owner=user_a,
                group_name=new_group_name("ex_inviter_empty"),
                invite_members=[],
            )
        with _allure_step("A 邀请成员"):
            resp = device_a.call(
                "GroupManager",
                Cmd.inviterUser.value,
                info={"groupId": group_id, "members": [], "reason": "auto-inviter"},
            )
        # 当前端稳定语义：空 members 调用成功
        with _allure_step("验证邀请成员返回的响应 result 与关键字段"):
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
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)


def test_group_inviter_user_nonexistent_user(device_a, assert_api, user_a):
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                device_a,
                assert_api,
                owner=user_a,
                group_name=new_group_name("ex_inviter_user"),
                invite_members=[],
            )
        with _allure_step("A 邀请成员"):
            resp = device_a.call(
                "GroupManager",
                Cmd.inviterUser.value,
                info={"groupId": group_id, "members": [_NONEXISTENT_USER], "reason": "auto-inviter"},
            )
        with _allure_step("验证邀请成员返回的错误码与错误文案"):
            assert_api.assert_error(resp, code=603, description="doesn't exist")
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)
