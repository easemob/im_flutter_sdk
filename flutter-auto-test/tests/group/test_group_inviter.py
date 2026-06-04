"""Group inviterUser 正常用例（strict）。"""
from __future__ import annotations

import pytest

from src import Cmd, GroupChangeEvent
from tests.group.group_helpers import (
    assert_group_events,
    assert_group_members_exact,
    collect_group_events,
    create_group,
    destroy_group,
    member_count,
    new_group_name,
)


pytestmark = [pytest.mark.client, pytest.mark.group]


def test_group_inviter_user_success(device_a, device_b, assert_api, user_a, user_b):
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("inviter"),
            invite_members=[],
        )

        resp_invite = device_a.call(
            "GroupManager",
            Cmd.inviterUser.value,
            info={"groupId": group_id, "members": [user_b], "reason": "auto-inviter"},
        )
        assert_api.assert_response_matches(
            resp_invite,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.inviterUser.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )

        invite_events = collect_group_events(
            device_b,
            expected_event_types={
                GroupChangeEvent.ON_INVITATION_RECEIVED.value,
                GroupChangeEvent.ON_AUTO_ACCEPT_INVITATION.value,
                "onAutoAcceptInvitationFromGroup",
                "onAllowListRemovedFromGroup",
                "onMemberJoinedFromGroup",
            },
            group_id=group_id,
            allow_missing_group_id=True,
            required_all_event_types={"onAutoAcceptInvitationFromGroup", "onMemberJoinedFromGroup"},
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            invite_events,
            expected_event_types={
                GroupChangeEvent.ON_INVITATION_RECEIVED.value,
                GroupChangeEvent.ON_AUTO_ACCEPT_INVITATION.value,
                "onAutoAcceptInvitationFromGroup",
                "onAllowListRemovedFromGroup",
                "onMemberJoinedFromGroup",
            },
            group_id=group_id,
            allow_missing_group_id=True,
            required_all_event_types={"onAutoAcceptInvitationFromGroup", "onMemberJoinedFromGroup"},
            expected_inviter=user_a,
            expected_member=user_b,
        )

        resp_group = device_a.call(
            "GroupManager",
            Cmd.getGroupSpecificationFromServer.value,
            info={"groupId": group_id, "fetchMembers": True},
        )
        result = resp_group.get("result")
        assert isinstance(result, dict), f"getGroupSpecificationFromServer result 非 dict: {resp_group}"
        assert member_count(resp_group) == 2, f"inviterUser 后 memberCount 应为 2: {resp_group}"
        assert_group_members_exact(resp_group, [user_b], err_prefix="inviterUser 后")
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)
