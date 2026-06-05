"""Group 成员白名单/禁言检查接口。"""
from __future__ import annotations

import pytest

from src import Cmd
from tests.group.group_helpers import create_group, destroy_group, new_group_name


pytestmark = [pytest.mark.client, pytest.mark.group, pytest.mark.agorachat1_4_0]


def test_group_is_member_in_white_list_and_mute_list_success(device_a, assert_api, user_a):
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("member_check"),
            invite_members=[],
        )

        resp_white = device_a.call(
            "GroupManager",
            Cmd.isMemberInWhiteListFromServer.value,
            info={"groupId": group_id},
        )
        assert_api.assert_response_matches(
            resp_white,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.isMemberInWhiteListFromServer.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )
        assert isinstance(resp_white.get("result"), bool), f"isMemberInWhiteListFromServer result 应为 bool: {resp_white}"

        resp_mute = device_a.call(
            "GroupManager",
            Cmd.isMemberInGroupMuteList.value,
            info={"groupId": group_id},
        )
        assert_api.assert_response_matches(
            resp_mute,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.isMemberInGroupMuteList.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )
        assert isinstance(resp_mute.get("result"), bool), f"isMemberInGroupMuteList result 应为 bool: {resp_mute}"
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_is_member_in_white_list_and_mute_list_nonexistent_group(device_a, assert_api):
    group_id = "nonexistent_group_member_check_999999"
    for cmd in (Cmd.isMemberInWhiteListFromServer.value, Cmd.isMemberInGroupMuteList.value):
        resp = device_a.call("GroupManager", cmd, info={"groupId": group_id})
        assert_api.assert_error(resp, code=600, description="do not find this group")
