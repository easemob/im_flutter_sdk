"""Group 成员白名单/禁言检查接口。"""
from __future__ import annotations

import pytest
from tests.group.allure_helpers import _allure_step

from src import Cmd
from tests.group.group_helpers import create_group, destroy_group, new_group_name


pytestmark = [pytest.mark.client, pytest.mark.group, pytest.mark.agorachat1_4_0]



def test_group_is_member_in_white_list_and_mute_list_success(device_a, assert_api, user_a):
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                device_a,
                assert_api,
                owner=user_a,
                group_name=new_group_name("member_check"),
                invite_members=[],
            )

        with _allure_step("A 查询白名单成员状态"):
            resp_white = device_a.call(
                "GroupManager",
                Cmd.isMemberInWhiteListFromServer.value,
                info={"groupId": group_id},
            )
        with _allure_step("验证查询白名单成员状态返回的关键字段"):
            assert_api.assert_response_matches(
                resp_white,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.isMemberInWhiteListFromServer.value,
                    "device": "deviceA",
                },
                ignore_keys={"sequence", "result"},
            )
        with _allure_step("验证查询白名单成员状态返回的关键字段"):
            assert isinstance(resp_white.get("result"), bool), f"isMemberInWhiteListFromServer result 应为 bool: {resp_white}"

        with _allure_step("A 执行群组业务操作"):
            resp_mute = device_a.call(
                "GroupManager",
                Cmd.isMemberInGroupMuteList.value,
                info={"groupId": group_id},
            )
        with _allure_step("验证执行群组业务操作返回的响应 result 与关键字段"):
            assert_api.assert_response_matches(
                resp_mute,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.isMemberInGroupMuteList.value,
                    "device": "deviceA",
                },
                ignore_keys={"sequence", "result"},
            )
        with _allure_step("验证执行群组业务操作返回的响应 result 与关键字段"):
            assert isinstance(resp_mute.get("result"), bool), f"isMemberInGroupMuteList result 应为 bool: {resp_mute}"
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)


def test_group_is_member_in_white_list_and_mute_list_nonexistent_group(device_a, assert_api):
    group_id = "nonexistent_group_member_check_999999"
    for cmd in (Cmd.isMemberInWhiteListFromServer.value, Cmd.isMemberInGroupMuteList.value):
        with _allure_step("A 执行群组业务操作"):
            resp = device_a.call("GroupManager", cmd, info={"groupId": group_id})
        with _allure_step("验证执行群组业务操作返回的错误码与错误文案"):
            assert_api.assert_error(resp, code=600, description="do not find this group")
