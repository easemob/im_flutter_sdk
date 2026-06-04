"""Group public list/count API 用例（strict）。"""
from __future__ import annotations

import pytest

from src import Cmd


pytestmark = [pytest.mark.client, pytest.mark.group]


def _assert_public_groups_result(result: object, *, resp: dict) -> None:
    assert isinstance(result, dict), f"getPublicGroupsFromServer result 应为 dict: {resp}"
    assert "cursor" in result, f"getPublicGroupsFromServer result 缺少 cursor: {resp}"
    assert "list" in result, f"getPublicGroupsFromServer result 缺少 list: {resp}"
    cursor = result.get("cursor")
    groups = result.get("list")
    assert isinstance(cursor, str), f"getPublicGroupsFromServer cursor 应为 str: {resp}"
    assert isinstance(groups, list), f"getPublicGroupsFromServer list 应为 list: {resp}"
    for idx, item in enumerate(groups):
        assert isinstance(item, dict), f"getPublicGroupsFromServer list[{idx}] 不是 dict: {item!r}"
        group_id = item.get("groupId")
        name = item.get("name")
        assert isinstance(group_id, str) and group_id, (
            f"getPublicGroupsFromServer list[{idx}].groupId 非法: {item!r}"
        )
        assert isinstance(name, str), f"getPublicGroupsFromServer list[{idx}].name 非法: {item!r}"


def test_group_fetch_joined_group_count_success(device_a, assert_api):
    resp = device_a.call("GroupManager", Cmd.fetchJoinedGroupCount.value, info={})
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
    assert isinstance(result, int), f"fetchJoinedGroupCount result 应为 int: {resp}"
    assert result >= 0, f"fetchJoinedGroupCount result 应>=0: {resp}"


def test_group_get_public_groups_from_server_success(device_a, assert_api):
    resp = device_a.call(
        "GroupManager",
        Cmd.getPublicGroupsFromServer.value,
        info={"pageNum": 1, "pageSize": 20},
    )
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.getPublicGroupsFromServer.value,
            "device": "deviceA",
        },
        ignore_keys={"sequence", "result"},
    )
    result = resp.get("result")
    _assert_public_groups_result(result, resp=resp)
