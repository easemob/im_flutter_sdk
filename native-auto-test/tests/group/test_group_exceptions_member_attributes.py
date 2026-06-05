"""Group 成员属性 API 异常用例（strict）。"""
from __future__ import annotations

import pytest

from src import Cmd
from tests.group.group_helpers import create_group, destroy_group, new_group_name


pytestmark = [pytest.mark.client, pytest.mark.group]


_NONEXISTENT_GROUP_ID = "nonexistent_group_999999"


def test_group_set_member_attributes_nonexistent_group(device_a, assert_api):
    resp = device_a.call(
        "GroupManager",
        Cmd.setMemberAttributesFromGroup.value,
        info={"groupId": _NONEXISTENT_GROUP_ID, "attributes": {"k": "v"}},
    )
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.setMemberAttributesFromGroup.value,
            "device": "deviceA",
            "result": None,
        },
        ignore_keys={"sequence"},
    )


def test_group_fetch_member_attributes_nonexistent_group(device_a, assert_api):
    resp = device_a.call(
        "GroupManager",
        Cmd.fetchMemberAttributesFromGroup.value,
        info={"groupId": _NONEXISTENT_GROUP_ID},
    )
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.fetchMemberAttributesFromGroup.value,
            "device": "deviceA",
        },
        ignore_keys={"sequence", "result"},
    )
    result = resp.get("result")
    assert isinstance(result, dict), f"fetchMemberAttributesFromGroup result 非 dict: {resp}"
    assert "k" in result, f"fetchMemberAttributesFromGroup 当前端返回应包含 k: {resp}"
    assert result.get("k") == "v", f"fetchMemberAttributesFromGroup 当前端返回值不匹配: {resp}"


def test_group_fetch_members_attributes_nonexistent_group(device_a, assert_api):
    resp = device_a.call(
        "GroupManager",
        Cmd.fetchMembersAttributesFromGroup.value,
        info={"groupId": _NONEXISTENT_GROUP_ID, "userIds": ["test_user_x"]},
    )
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.fetchMembersAttributesFromGroup.value,
            "device": "deviceA",
        },
        ignore_keys={"sequence", "result"},
    )
    result = resp.get("result")
    assert isinstance(result, dict), f"fetchMembersAttributesFromGroup result 非 dict: {resp}"
    assert "test_user_x" in result, f"fetchMembersAttributesFromGroup 当前端返回应包含 test_user_x: {resp}"
    user_attrs = result.get("test_user_x")
    assert isinstance(user_attrs, dict), f"fetchMembersAttributesFromGroup 成员属性非 dict: {resp}"
    assert user_attrs == {}, f"fetchMembersAttributesFromGroup 当前端空属性语义应为 {{}}: {resp}"


def test_group_set_member_attributes_empty_attributes(device_a, assert_api, user_a):
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("ex_member_attr"),
            invite_members=[],
        )
        resp = device_a.call(
            "GroupManager",
            Cmd.setMemberAttributesFromGroup.value,
            info={"groupId": group_id, "attributes": {}},
        )
        assert_api.assert_error(resp, code=205, description="Invalid parameter")
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)
