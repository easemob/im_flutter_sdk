"""Group 成员属性删除 API 异常用例（strict）。"""
from __future__ import annotations

import pytest
from tests.group.allure_helpers import _allure_step

from src import Cmd
from tests.group.group_helpers import create_group, destroy_group, new_group_name


pytestmark = [pytest.mark.client, pytest.mark.group]


_NONEXISTENT_GROUP_ID = "nonexistent_group_999999"



def test_group_remove_member_attributes_nonexistent_group(device_a, assert_api):
    with _allure_step("A 删除成员属性"):
        resp = device_a.call(
            "GroupManager",
            Cmd.removeMemberAttributesFromGroup.value,
            info={"groupId": _NONEXISTENT_GROUP_ID, "keys": ["k1"]},
        )
    # 按当前端稳定语义：不存在群也返回成功
    with _allure_step("验证删除成员属性返回的关键字段"):
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.removeMemberAttributesFromGroup.value,
                "device": "deviceA",
                "result": None,
            },
            ignore_keys={"sequence"},
        )


def test_group_remove_member_attributes_empty_keys(device_a, assert_api, user_a):
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                device_a,
                assert_api,
                owner=user_a,
                group_name=new_group_name("ex_member_attr_rm"),
                invite_members=[],
            )
        with _allure_step("A 删除成员属性"):
            resp = device_a.call(
                "GroupManager",
                Cmd.removeMemberAttributesFromGroup.value,
                info={"groupId": group_id, "keys": []},
            )
        with _allure_step("验证删除成员属性返回的错误码与错误文案"):
            assert_api.assert_error(resp, code=205, description="Invalid parameter")
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)


def test_group_remove_member_attributes_nonexistent_key(device_a, assert_api, user_a):
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                device_a,
                assert_api,
                owner=user_a,
                group_name=new_group_name("ex_member_attr_rm_key"),
                invite_members=[],
            )
        with _allure_step("A 删除成员属性"):
            resp = device_a.call(
                "GroupManager",
                Cmd.removeMemberAttributesFromGroup.value,
                info={"groupId": group_id, "keys": ["k_not_exists"]},
            )
        # 按当前端稳定语义：删除不存在 key 走成功
        with _allure_step("验证删除成员属性返回的关键字段"):
            assert_api.assert_response_matches(
                resp,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.removeMemberAttributesFromGroup.value,
                    "device": "deviceA",
                    "result": None,
                },
                ignore_keys={"sequence"},
            )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)
