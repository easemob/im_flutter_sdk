"""Group lifecycle 正常链路。"""
from __future__ import annotations

import pytest

from src import Cmd, GroupChangeEvent
from tests.group.group_helpers import (
    assert_group_events,
    assert_group_snapshot,
    collect_group_events,
    create_group,
    destroy_group,
    new_group_name,
)


pytestmark = [pytest.mark.client, pytest.mark.group, pytest.mark.agorachat1_4_0]


def test_group_create_group(device_a, device_b, assert_api, user_a, user_b):
    group_name = new_group_name("create")
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b],
        )
        expected_events = {
            GroupChangeEvent.ON_INVITATION_RECEIVED.value,
            GroupChangeEvent.ON_AUTO_ACCEPT_INVITATION.value,
            "onAutoAcceptInvitationFromGroup",
            "onAllowListRemovedFromGroup",
            "onMemberJoinedFromGroup",
        }
        required_events = {
            "onAutoAcceptInvitationFromGroup",
        }
        events = collect_group_events(
            device_b,
            expected_event_types=expected_events,
            group_id=group_id,
            allow_missing_group_id=True,
            required_all_event_types=required_events,
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            events,
            expected_event_types=expected_events,
            group_id=group_id,
            allow_missing_group_id=True,
            required_all_event_types=required_events,
            expected_inviter=user_a,
            expected_member=user_b,
        )

        owner_events = collect_group_events(
            device_a,
            expected_event_types={
                "onMembersJoinedFromGroup",
                "onMemberJoinedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onMembersJoinedFromGroup", "onMemberJoinedFromGroup"},
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            owner_events,
            expected_event_types={
                "onMembersJoinedFromGroup",
                "onMemberJoinedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onMembersJoinedFromGroup", "onMemberJoinedFromGroup"},
            expected_member=user_b,
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id, device_b=device_b)


def test_group_get_group(device_a, device_b, assert_api, user_a, user_b):
    group_name = new_group_name("local")
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b],
        )
        resp_get = device_a.call("GroupManager", Cmd.getGroupWithId.value, info={"groupId": group_id})
        assert_group_snapshot(
            assert_api,
            resp_get,
            cmd=Cmd.getGroupWithId.value,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count_value=2,
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id, device_b=device_b)


def test_group_get_group_from_server(device_a, device_b, assert_api, user_a, user_b):
    group_name = new_group_name("server")
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b],
        )
        resp = device_a.call(
            "GroupManager",
            Cmd.getGroupSpecificationFromServer.value,
            info={"groupId": group_id, "fetchMembers": True},
        )
        assert_group_snapshot(
            assert_api,
            resp,
            cmd=Cmd.getGroupSpecificationFromServer.value,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count_value=2,
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id, device_b=device_b)


def test_group_get_group_from_server_after_destroy(device_a, device_b, assert_api, user_a):
    group_name = new_group_name("server_after_destroy")
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[],
        )
        destroyed_group_id = group_id
        # B 不在该群中，销毁时不应强制等待 B 端 onGroupDestroyed 回调。
        group_id = ""
        destroy_group(device_a, assert_api, destroyed_group_id)

        resp = device_a.call(
            "GroupManager",
            Cmd.getGroupSpecificationFromServer.value,
            info={"groupId": destroyed_group_id, "fetchMembers": True},
        )
        assert_api.assert_error(resp, code=600, description="do not find this group")
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id, device_b=device_b)
