"""Group public list/count API 用例（strict）。"""
from __future__ import annotations

import time

import pytest

from src import Cmd
from tests.group.group_helpers import create_group, destroy_group, new_group_name


pytestmark = [
    pytest.mark.client,
    pytest.mark.group,
    pytest.mark.skip(reason="5.0 移除服务端拉公开群（getPublicGroupsFromServer 改本地群列表，无分页/cursor 语义）"),
]


def _assert_public_groups_result(result: object, *, resp: dict) -> None:
    assert isinstance(result, dict), f"getPublicGroupsFromServer result 应为 dict: {resp}"
    assert set(result) == {"cursor", "list"}, (
        f"getPublicGroupsFromServer result 字段不匹配: expected={{'cursor', 'list'}}, resp={resp}"
    )
    cursor = result.get("cursor")
    groups = result.get("list")
    assert isinstance(cursor, str), f"getPublicGroupsFromServer cursor 应为 str: {resp}"
    assert isinstance(groups, list), f"getPublicGroupsFromServer list 应为 list: {resp}"
    for idx, item in enumerate(groups):
        assert isinstance(item, dict), f"getPublicGroupsFromServer list[{idx}] 不是 dict: {item!r}"
        assert set(item) == {"groupId", "name"}, (
            f"getPublicGroupsFromServer list[{idx}] 字段不匹配: {item!r}"
        )
        group_id = item.get("groupId")
        name = item.get("name")
        assert isinstance(group_id, str) and group_id, (
            f"getPublicGroupsFromServer list[{idx}].groupId 非法: {item!r}"
        )
        assert isinstance(name, str), f"getPublicGroupsFromServer list[{idx}].name 非法: {item!r}"


def test_group_fetch_joined_group_count_success(device_a, assert_api):
    """
    前置：A 已登录，当前账号可能已加入零个或多个共享环境群组。
    步骤：A 调用 fetchJoinedGroupCount。
    预期与断言：响应信封匹配，result 为当前服务端返回的非负整数计数。
    """
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
    """
    前置：A 已登录，公开群列表允许包含共享环境已有数据。
    步骤：A 使用真实 cursor API 参数 pageSize=20 拉取第一页，不传 pageNum。
    预期与断言：响应严格包含 cursor/list；cursor 为字符串，每个列表项严格只有 groupId/name。
    """
    resp = device_a.call(
        "GroupManager",
        Cmd.getPublicGroupsFromServer.value,
        info={"pageSize": 20},
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


def test_group_public_groups_cursor_paginates_two_created_groups(
    device_a,
    assert_api,
    user_a,
):
    """
    前置：A 已登录；测试依次创建两个名称唯一的 PublicOpenJoin（style=3）公开群。
    步骤：A 以 pageSize=1 从无 cursor 的第一页开始查询；若返回非空 cursor，则将该真实
    cursor 原样传入下一页，最多遍历 100 页，直到找到本次两个动态 groupId。
    预期与断言：每页响应严格只有 cursor/list，每页最多一个且不得重复 groupId；目标群
    出现时必须精确匹配创建时的 groupId/name；找到两个目标前 cursor 不得为空，且连续
    两页 cursor 不得相同；最终两个目标均被真实 cursor 链路找到。
    """
    group_ids: list[str] = []
    group_names: list[str] = []
    try:
        first_name = new_group_name("public_cursor_first")
        first_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=first_name,
            invite_members=[],
            style=3,
        )
        group_ids.append(first_id)
        group_names.append(first_name)

        time.sleep(1.1)
        second_name = new_group_name("public_cursor_second")
        second_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=second_name,
            invite_members=[],
            style=3,
        )
        group_ids.append(second_id)
        group_names.append(second_name)

        expected_targets = {
            first_id: {"groupId": first_id, "name": first_name},
            second_id: {"groupId": second_id, "name": second_name},
        }
        found_targets: dict[str, dict] = {}
        seen_group_ids: set[str] = set()
        previous_cursor: str | None = None

        for _page_index in range(100):
            info: dict[str, object] = {"pageSize": 1}
            if previous_cursor is not None:
                info["cursor"] = previous_cursor
            resp = device_a.call(
                "GroupManager",
                Cmd.getPublicGroupsFromServer.value,
                info=info,
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
            assert isinstance(result, dict)
            page_groups = result["list"]
            cursor = result["cursor"]
            assert len(page_groups) <= 1, f"pageSize=1 但返回超过一个群: {resp}"

            if page_groups:
                item = page_groups[0]
                group_id = item["groupId"]
                assert group_id not in seen_group_ids, f"cursor 分页返回重复 groupId={group_id}: {resp}"
                seen_group_ids.add(group_id)
                if group_id in expected_targets:
                    assert item == expected_targets[group_id], (
                        f"公开群目标项不匹配: expected={expected_targets[group_id]}, actual={item}"
                    )
                    found_targets[group_id] = item

            if set(found_targets) == set(expected_targets):
                break
            assert cursor, (
                "找到本次创建的两个公开群之前 cursor 已为空: "
                f"found={sorted(found_targets)}, expected={sorted(expected_targets)}, resp={resp}"
            )
            assert cursor != previous_cursor, f"连续两页 cursor 未变化: cursor={cursor}, resp={resp}"
            previous_cursor = cursor

        assert found_targets == expected_targets, (
            f"cursor 遍历未找到全部目标群: expected={expected_targets}, actual={found_targets}"
        )
    finally:
        for group_id in reversed(group_ids):
            destroy_group(device_a, assert_api, group_id)
