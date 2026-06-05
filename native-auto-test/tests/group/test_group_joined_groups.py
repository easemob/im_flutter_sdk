"""Group list API 用例（strict）。"""
from __future__ import annotations

import pytest

from src import Cmd
from tests.group.group_helpers import (
    assert_group_list_response,
    create_group,
    destroy_group,
    find_group_in_list,
    new_group_name,
)


pytestmark = [pytest.mark.client, pytest.mark.group]


def test_group_get_joined_groups_local_contains_created_group(device_a, assert_api, user_a):
    group_name = new_group_name("joined_local")
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[],
        )
        resp = device_a.call("GroupManager", Cmd.getJoinedGroups.value, info={})
        groups = assert_group_list_response(
            assert_api,
            resp,
            cmd=Cmd.getJoinedGroups.value,
            device="deviceA",
        )
        matched = find_group_in_list(groups, group_id)
        assert matched is not None, f"getJoinedGroups 未包含新建群: groupId={group_id}, resp={resp}"
        assert matched.get("owner") == user_a, f"getJoinedGroups owner 不匹配: expected={user_a}, actual={matched}"
        assert matched.get("name") == group_name, f"getJoinedGroups name 不匹配: expected={group_name}, actual={matched}"
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_get_joined_groups_from_server_contains_created_group(device_a, assert_api, user_a):
    group_name = new_group_name("joined_server")
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[],
        )
        resp = device_a.call("GroupManager", Cmd.getJoinedGroupsFromServer.value, info={})
        groups = assert_group_list_response(
            assert_api,
            resp,
            cmd=Cmd.getJoinedGroupsFromServer.value,
            device="deviceA",
        )
        matched = find_group_in_list(groups, group_id)
        assert matched is not None, (
            f"getJoinedGroupsFromServer 未包含新建群: groupId={group_id}, resp={resp}"
        )
        assert matched.get("owner") == user_a, (
            f"getJoinedGroupsFromServer owner 不匹配: expected={user_a}, actual={matched}"
        )
        assert matched.get("name") == group_name, (
            f"getJoinedGroupsFromServer name 不匹配: expected={group_name}, actual={matched}"
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)

