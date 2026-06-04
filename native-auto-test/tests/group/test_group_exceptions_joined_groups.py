"""Group list API 异常/边界用例（strict）。"""
from __future__ import annotations

import pytest

from src import Cmd
from tests.group.group_helpers import assert_group_list_response


pytestmark = [pytest.mark.client, pytest.mark.group]


def test_group_get_joined_groups_with_extra_info_fields(device_a, assert_api):
    resp = device_a.call(
        "GroupManager",
        Cmd.getJoinedGroups.value,
        info={"unexpected": "value", "pageNum": 0, "pageSize": -1},
    )
    # 当前端对该接口忽略无关参数并返回稳定列表结构
    assert_group_list_response(
        assert_api,
        resp,
        cmd=Cmd.getJoinedGroups.value,
        device="deviceA",
    )


def test_group_get_joined_groups_from_server_with_extra_info_fields(device_a, assert_api):
    resp = device_a.call(
        "GroupManager",
        Cmd.getJoinedGroupsFromServer.value,
        info={"unexpected": "value", "cursor": "invalid", "pageSize": 0},
    )
    # 当前端对该接口忽略无关参数并返回稳定列表结构
    assert_group_list_response(
        assert_api,
        resp,
        cmd=Cmd.getJoinedGroupsFromServer.value,
        device="deviceA",
    )

