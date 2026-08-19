"""Group 共享文件列表正常用例（strict）。"""
from __future__ import annotations

import pytest
from tests.group.allure_helpers import _allure_step

from src import Cmd
from tests.group.group_helpers import create_group, destroy_group, new_group_name


pytestmark = [pytest.mark.client, pytest.mark.group]



def test_group_get_group_file_list_from_server_success(device_a, assert_api, user_a):
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                device_a,
                assert_api,
                owner=user_a,
                group_name=new_group_name("file_list"),
                invite_members=[],
            )

        with _allure_step("A 查询群共享文件列表"):
            resp = device_a.call(
                "GroupManager",
                Cmd.getGroupFileListFromServer.value,
                info={"groupId": group_id, "pageNum": 1, "pageSize": 20},
            )
        with _allure_step("验证查询群共享文件列表返回的关键字段"):
            assert_api.assert_response_matches(
                resp,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.getGroupFileListFromServer.value,
                    "device": "deviceA",
                },
                ignore_keys={"sequence", "result"},
            )

        result = resp.get("result")
        with _allure_step("验证查询群共享文件列表返回的关键字段"):
            assert isinstance(result, list), f"getGroupFileListFromServer result 不是 list: {resp}"
        with _allure_step("验证查询群共享文件列表返回的关键字段"):
            assert result == [], f"新建群共享文件列表预期为空: {resp}"
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)
