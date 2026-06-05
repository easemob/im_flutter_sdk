"""Group block/unblock API 异常/边界用例（strict）。"""
from __future__ import annotations

import pytest

from src import Cmd
from tests.group.group_helpers import create_group, destroy_group, new_group_name


pytestmark = [pytest.mark.client, pytest.mark.group]


_NONEXISTENT_GROUP_ID = "nonexistent_group_999999"


def test_group_block_nonexistent_group(device_a, assert_api):
    resp = device_a.call("GroupManager", Cmd.blockGroup.value, info={"groupId": _NONEXISTENT_GROUP_ID})
    assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_unblock_nonexistent_group(device_a, assert_api):
    resp = device_a.call("GroupManager", Cmd.unblockGroup.value, info={"groupId": _NONEXISTENT_GROUP_ID})
    assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_block_idempotent(device_a, assert_api, user_a):
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("block_idem"),
            invite_members=[],
        )
        resp1 = device_a.call("GroupManager", Cmd.blockGroup.value, info={"groupId": group_id})
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
        resp2 = device_a.call("GroupManager", Cmd.blockGroup.value, info={"groupId": group_id})
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
                device_a.call("GroupManager", Cmd.unblockGroup.value, info={"groupId": group_id})
            except Exception:
                pass
            destroy_group(device_a, assert_api, group_id)


def test_group_unblock_idempotent(device_a, assert_api, user_a):
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("unblock_idem"),
            invite_members=[],
        )
        resp1 = device_a.call("GroupManager", Cmd.unblockGroup.value, info={"groupId": group_id})
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
        resp2 = device_a.call("GroupManager", Cmd.unblockGroup.value, info={"groupId": group_id})
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
            destroy_group(device_a, assert_api, group_id)

