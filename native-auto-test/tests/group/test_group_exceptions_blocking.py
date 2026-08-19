"""Group block/unblock API 异常/边界用例（strict）。"""
from __future__ import annotations

import pytest
from tests.group.allure_helpers import _allure_step

from src import Cmd
from tests.group.group_helpers import create_group, destroy_group, new_group_name


pytestmark = [pytest.mark.client, pytest.mark.group]


_NONEXISTENT_GROUP_ID = "nonexistent_group_999999"



def test_group_block_nonexistent_group(device_a, assert_api):
    with _allure_step("A 屏蔽群消息"):
        resp = device_a.call("GroupManager", Cmd.blockGroup.value, info={"groupId": _NONEXISTENT_GROUP_ID})
    with _allure_step("验证屏蔽群消息返回的错误码与错误文案"):
        assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_unblock_nonexistent_group(device_a, assert_api):
    with _allure_step("A 取消屏蔽群消息"):
        resp = device_a.call("GroupManager", Cmd.unblockGroup.value, info={"groupId": _NONEXISTENT_GROUP_ID})
    with _allure_step("验证取消屏蔽群消息返回的错误码与错误文案"):
        assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_block_idempotent(device_a, assert_api, user_a):
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                device_a,
                assert_api,
                owner=user_a,
                group_name=new_group_name("block_idem"),
                invite_members=[],
            )
        with _allure_step("A 屏蔽群消息"):
            resp1 = device_a.call("GroupManager", Cmd.blockGroup.value, info={"groupId": group_id})
        with _allure_step("验证屏蔽群消息返回的关键字段"):
            assert_api.assert_response_matches(
                resp1,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.blockGroup.value,
                    "device": "deviceA",
                    "result": None,
                },
                ignore_keys={"sequence"},
            )
        with _allure_step("A 屏蔽群消息"):
            resp2 = device_a.call("GroupManager", Cmd.blockGroup.value, info={"groupId": group_id})
        with _allure_step("验证屏蔽群消息返回的关键字段"):
            assert_api.assert_response_matches(
                resp2,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.blockGroup.value,
                    "device": "deviceA",
                    "result": None,
                },
                ignore_keys={"sequence"},
            )
    finally:
        if group_id:
            # 若仍 blocked，先解封再销毁，避免端侧状态影响销毁
            try:
                with _allure_step("测试后置：A 取消屏蔽群消息"):
                    device_a.call("GroupManager", Cmd.unblockGroup.value, info={"groupId": group_id})
            except Exception:
                pass
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)


def test_group_unblock_idempotent(device_a, assert_api, user_a):
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                device_a,
                assert_api,
                owner=user_a,
                group_name=new_group_name("unblock_idem"),
                invite_members=[],
            )
        with _allure_step("A 取消屏蔽群消息"):
            resp1 = device_a.call("GroupManager", Cmd.unblockGroup.value, info={"groupId": group_id})
        with _allure_step("验证取消屏蔽群消息返回的关键字段"):
            assert_api.assert_response_matches(
                resp1,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.unblockGroup.value,
                    "device": "deviceA",
                    "result": None,
                },
                ignore_keys={"sequence"},
            )
        with _allure_step("A 取消屏蔽群消息"):
            resp2 = device_a.call("GroupManager", Cmd.unblockGroup.value, info={"groupId": group_id})
        with _allure_step("验证取消屏蔽群消息返回的关键字段"):
            assert_api.assert_response_matches(
                resp2,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.unblockGroup.value,
                    "device": "deviceA",
                    "result": None,
                },
                ignore_keys={"sequence"},
            )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)
