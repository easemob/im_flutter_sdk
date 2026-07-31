from __future__ import annotations

import uuid

import pytest

from src import Cmd


pytestmark = [pytest.mark.phase1, pytest.mark.group]


def test_fetch_group_members_info_version_capability(device_a, assert_api):
    """同一 case：4.10 在调用前 Skip，4.14 调用真实新增 API 并成功。"""
    device_a.require_capability("GroupManager", "fetchGroupMembersInfo")
    group_name = f"phase1-capability-{uuid.uuid4().hex[:8]}"
    created = device_a.call(
        "GroupManager",
        Cmd.createGroup.value,
        info={
            "groupName": group_name,
            "desc": "phase1 capability validation",
            "inviteMembers": [],
            "inviteReason": "",
            "options": {
                "maxCount": 20,
                "inviteNeedConfirm": False,
                "style": 0,
            },
        },
    )
    assert_api.assert_success(created)
    group = assert_api.get_result(created)
    group_id = group["groupId"]

    try:
        response = device_a.call(
            "GroupManager",
            "fetchGroupMembersInfo",
            info={"groupId": group_id, "cursor": "", "limit": 20},
        )
        assert_api.assert_success(response)
        result = assert_api.get_result(response)
        assert isinstance(result, dict)
        assert isinstance(result.get("cursor"), str)
        assert isinstance(result.get("list"), list)
        for member in result["list"]:
            assert isinstance(member, dict)
            assert isinstance(member.get("memberId"), str)
    finally:
        device_a.call(
            "GroupManager",
            Cmd.destroyGroup.value,
            info={"groupId": group_id},
        )
