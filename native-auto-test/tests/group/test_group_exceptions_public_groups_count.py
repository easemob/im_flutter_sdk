"""Group public list/count API 异常/边界用例（strict）。"""
from __future__ import annotations

import pytest
from tests.group.allure_helpers import _allure_step

from src import Cmd
from tests.group.test_group_public_groups_count import _assert_public_groups_result


pytestmark = [
    pytest.mark.client,
    pytest.mark.group,
]


@pytest.mark.skip(reason="5.0 移除服务端拉公开群（getPublicGroupsFromServer 残留，无公开群列表）")
@pytest.mark.parametrize(
    ("page_num", "page_size"),
    [
        (0, 20),
        (-1, 20),
        (1, 0),
        (1, -1),
    ],
)

def test_group_get_public_groups_from_server_invalid_paging(device_a, assert_api, page_num, page_size):
    with _allure_step("A 查询公开群列表"):
        resp = device_a.call(
            "GroupManager",
            Cmd.getPublicGroupsFromServer.value,
            info={"pageNum": page_num, "pageSize": page_size},
        )
    with _allure_step("验证查询公开群列表返回的关键字段"):
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.getPublicGroupsFromServer.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )
    with _allure_step("验证群业务状态、事件与关键字段"):
        _assert_public_groups_result(resp.get("result"), resp=resp)


def test_group_fetch_joined_group_count_with_extra_info(device_a, assert_api):
    with _allure_step("A 查询已加入群数量"):
        resp = device_a.call(
            "GroupManager",
            Cmd.fetchJoinedGroupCount.value,
            info={"unexpected": "value", "pageSize": 0},
        )
    with _allure_step("验证查询已加入群数量返回的关键字段"):
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.fetchJoinedGroupCount.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )
    result = resp.get("result")
    with _allure_step("验证查询已加入群数量返回的关键字段"):
        assert isinstance(result, int), f"fetchJoinedGroupCount result 应为 int: {resp}"
    with _allure_step("验证查询已加入群数量返回的关键字段"):
        assert result >= 0, f"fetchJoinedGroupCount result 应>=0: {resp}"
