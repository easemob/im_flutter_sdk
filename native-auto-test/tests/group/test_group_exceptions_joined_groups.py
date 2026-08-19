"""Group list API 异常/边界用例（strict）。"""
from __future__ import annotations

import pytest
from tests.group.allure_helpers import _allure_step

from src import Cmd
from tests.group.group_helpers import assert_group_list_response


pytestmark = [pytest.mark.client, pytest.mark.group]



def test_group_get_joined_groups_with_extra_info_fields(device_a, assert_api):
    with _allure_step("A 查询本地已加入群列表"):
        resp = device_a.call(
            "GroupManager",
            Cmd.getJoinedGroups.value,
            info={"unexpected": "value", "pageNum": 0, "pageSize": -1},
        )
    # 当前端对该接口忽略无关参数并返回稳定列表结构
    with _allure_step("验证查询本地已加入群列表返回的关键字段"):
        assert_group_list_response(
            assert_api,
            resp,
            cmd=Cmd.getJoinedGroups.value,
            device="deviceA",
        )


@pytest.mark.skip(reason="5.0 移除 getJoinedGroupsFromServer（残留，改本地 getJoinedGroups）")
def test_group_get_joined_groups_from_server_with_extra_info_fields(device_a, assert_api):
    with _allure_step("A 查询服务端已加入群列表"):
        resp = device_a.call(
            "GroupManager",
            Cmd.getJoinedGroupsFromServer.value,
            info={"unexpected": "value", "cursor": "invalid", "pageSize": 0},
        )
    # 当前端对该接口忽略无关参数并返回稳定列表结构
    with _allure_step("验证查询服务端已加入群列表返回的关键字段"):
        assert_group_list_response(
            assert_api,
            resp,
            cmd=Cmd.getJoinedGroupsFromServer.value,
            device="deviceA",
        )
