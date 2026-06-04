"""Group block/unblock API 正常用例（strict）。"""
from __future__ import annotations

import pytest

from src import Cmd
from tests.group.group_helpers import create_group, destroy_group, new_group_name


pytestmark = [pytest.mark.client, pytest.mark.group]


def _assert_group_blocked_flag(device_a, assert_api, group_id: str, blocked: bool):
    resp = device_a.call("GroupManager", Cmd.getGroupWithId.value, info={"groupId": group_id})
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.getGroupWithId.value,
            "device": "deviceA",
        },
        ignore_keys={"sequence", "result"},
    )
    result = resp.get("result")
    assert isinstance(result, dict), f"getGroupWithId result 非 dict: {resp}"
    assert "messageBlocked" in result, f"getGroupWithId result 缺少 messageBlocked: {resp}"
    assert result.get("messageBlocked") is blocked, (
        f"messageBlocked 状态不符合预期: expected={blocked}, actual={result.get('messageBlocked')}, resp={resp}"
    )


def test_group_block_then_unblock_success(device_a, assert_api, user_a):
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("block"),
            invite_members=[],
        )

        resp_block = device_a.call("GroupManager", Cmd.blockGroup.value, info={"groupId": group_id})
        assert_api.assert_response_matches(
            resp_block,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.blockGroup.value,
                "device": "deviceA",
                "result": None,
            },
            ignore_keys={"sequence"},
        )
        _assert_group_blocked_flag(device_a, assert_api, group_id, True)

        resp_unblock = device_a.call("GroupManager", Cmd.unblockGroup.value, info={"groupId": group_id})
        assert_api.assert_response_matches(
            resp_unblock,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.unblockGroup.value,
                "device": "deviceA",
                "result": None,
            },
            ignore_keys={"sequence"},
        )
        _assert_group_blocked_flag(device_a, assert_api, group_id, False)
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)

