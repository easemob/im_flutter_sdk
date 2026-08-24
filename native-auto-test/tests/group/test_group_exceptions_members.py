"""Group members 异常用例（strict）。"""
from __future__ import annotations

import pytest
from tests.group.allure_helpers import _allure_step

from src import Cmd
from tests.group.group_helpers import create_group, destroy_group, new_group_name


pytestmark = [pytest.mark.client, pytest.mark.group]


_NONEXISTENT_GROUP_ID = "nonexistent_group_999999"
_NONEXISTENT_USER = "nonexistent_user_999999"



def test_group_add_members_empty_members(device_a, assert_api, user_a):
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(device_a, assert_api, owner=user_a, group_name=new_group_name("ex_mem"), invite_members=[])
        with _allure_step("A 添加群成员"):
            resp = device_a.call("GroupManager", Cmd.addMembers.value, info={"groupId": group_id, "members": []})
        with _allure_step("验证 添加群成员返回的关键字段"):
            assert_api.assert_response_matches(
                resp,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.addMembers.value,
                    "device": "deviceA",
                    "result": True,
                },
                ignore_keys={"sequence"},
            )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)


def test_group_add_members_nonexistent_group(device_a, assert_api):
    with _allure_step("A 添加群成员"):
        resp = device_a.call(
            "GroupManager",
            Cmd.addMembers.value,
            info={"groupId": _NONEXISTENT_GROUP_ID, "members": ["test_user_x"]},
        )
    with _allure_step("验证 添加群成员返回的错误码与错误文案"):
        assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_add_members_nonexistent_user(device_a, assert_api, user_a):
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(device_a, assert_api, owner=user_a, group_name=new_group_name("ex_user"), invite_members=[])
        with _allure_step("A 添加群成员"):
            resp = device_a.call("GroupManager", Cmd.addMembers.value, info={"groupId": group_id, "members": [_NONEXISTENT_USER]})
        with _allure_step("验证 添加群成员返回的错误码与错误文案"):
            assert_api.assert_error(resp, code=603, description="doesn't exist")
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)


def test_group_remove_members_non_member(device_a, assert_api, user_a, user_b):
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(device_a, assert_api, owner=user_a, group_name=new_group_name("ex_rm"), invite_members=[])
        with _allure_step("A 移除群成员"):
            resp = device_a.call("GroupManager", Cmd.removeMembers.value, info={"groupId": group_id, "members": [user_b]})
        with _allure_step("验证 移除群成员返回的错误码与错误文案"):
            assert_api.assert_error(resp, code=603, description="are not members of this group")
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)


def test_group_leave_group_non_member(device_b, assert_api):
    with _allure_step("B 退出群"):
        resp = device_b.call("GroupManager", Cmd.leaveGroup.value, info={"groupId": _NONEXISTENT_GROUP_ID})
    with _allure_step("验证退出群返回的错误码与错误文案"):
        assert_api.assert_error(resp, code=600, description="do not find this group")
