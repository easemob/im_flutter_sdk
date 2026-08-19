"""Group 角色权限异常用例（strict）。"""
from __future__ import annotations

import pytest
from tests.group.allure_helpers import _allure_step

from src import Cmd
from tests.group.group_helpers import create_group, destroy_group, new_group_name


pytestmark = [pytest.mark.client, pytest.mark.group]


_NONEXISTENT_GROUP_ID = "nonexistent_group_999999"
_NONEXISTENT_USER = "nonexistent_user_999999"



def test_group_add_admin_nonexistent_group(device_a, assert_api, user_b):
    with _allure_step("A 添加群管理员"):
        resp = device_a.call(
            "GroupManager",
            Cmd.addAdmin.value,
            info={"groupId": _NONEXISTENT_GROUP_ID, "admin": user_b},
        )
    with _allure_step("验证 添加群管理员返回的错误码与错误文案"):
        assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_remove_admin_nonexistent_group(device_a, assert_api, user_b):
    with _allure_step("A 移除群管理员"):
        resp = device_a.call(
            "GroupManager",
            Cmd.removeAdmin.value,
            info={"groupId": _NONEXISTENT_GROUP_ID, "admin": user_b},
        )
    with _allure_step("验证 移除群管理员返回的错误码与错误文案"):
        assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_update_owner_nonexistent_group(device_a, assert_api, user_b):
    with _allure_step("A 转让群主"):
        resp = device_a.call(
            "GroupManager",
            Cmd.updateGroupOwner.value,
            info={"groupId": _NONEXISTENT_GROUP_ID, "owner": user_b},
        )
    with _allure_step("验证转让群主返回的错误码与错误文案"):
        assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_add_admin_non_member(device_a, assert_api, user_a):
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                device_a,
                assert_api,
                owner=user_a,
                group_name=new_group_name("ex_add_admin"),
                invite_members=[],
            )
        with _allure_step("A 添加群管理员"):
            resp = device_a.call(
                "GroupManager",
                Cmd.addAdmin.value,
                info={"groupId": group_id, "admin": _NONEXISTENT_USER},
            )
        with _allure_step("验证 添加群管理员返回的错误码与错误文案"):
            assert_api.assert_error(resp, code=600, description="doesn't exist")
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)
