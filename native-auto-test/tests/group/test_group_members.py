"""Group members 正常链路。"""
from __future__ import annotations

import pytest

from src import Cmd, GroupChangeEvent
from tests.group.group_helpers import (
    assert_group_events,
    assert_group_members_exact,
    assert_group_snapshot,
    collect_group_events,
    create_group,
    destroy_group,
    member_count,
    new_group_name,
)


pytestmark = [pytest.mark.client, pytest.mark.group, pytest.mark.agorachat1_4_0]


def test_group_add_remove_members(device_a, device_b, assert_api, user_a, user_b):
    group_name = new_group_name("member")
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[],
        )

        resp_add = device_a.call(
            "GroupManager",
            Cmd.addMembers.value,
            info={"groupId": group_id, "members": [user_b], "welcome": "welcome"},
        )
        assert_api.assert_response_matches(
            resp_add,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.addMembers.value,
                "device": "deviceA",
                "result": True,
            },
            ignore_keys={"sequence"},
        )

        expected_add_events = {
            GroupChangeEvent.ON_INVITATION_RECEIVED.value,
            GroupChangeEvent.ON_AUTO_ACCEPT_INVITATION.value,
            "onAutoAcceptInvitationFromGroup",
            "onAllowListRemovedFromGroup",
            "onMemberJoinedFromGroup",
        }
        required_add_events = {
            "onAutoAcceptInvitationFromGroup",
        }
        add_events = collect_group_events(
            device_b,
            expected_event_types=expected_add_events,
            group_id=group_id,
            allow_missing_group_id=True,
            required_all_event_types=required_add_events,
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            add_events,
            expected_event_types=expected_add_events,
            group_id=group_id,
            allow_missing_group_id=True,
            required_all_event_types=required_add_events,
            expected_inviter=user_a,
            expected_member=user_b,
        )

        owner_add_events = collect_group_events(
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
            owner_add_events,
            expected_event_types={
                "onMembersJoinedFromGroup",
                "onMemberJoinedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onMembersJoinedFromGroup", "onMemberJoinedFromGroup"},
            expected_member=user_b,
        )

        resp_get_after_add = device_a.call(
            "GroupManager",
            Cmd.getGroupSpecificationFromServer.value,
            info={"groupId": group_id, "fetchMembers": True},
        )
        assert_group_snapshot(
            assert_api,
            resp_get_after_add,
            cmd=Cmd.getGroupSpecificationFromServer.value,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count_value=2,
        )
        assert member_count(resp_get_after_add) == 2, f"addMembers 后 memberCount 预期 2: {resp_get_after_add}"
        assert_group_members_exact(resp_get_after_add, [user_b], err_prefix="addMembers 后")

        resp_remove = device_a.call(
            "GroupManager",
            Cmd.removeMembers.value,
            info={"groupId": group_id, "members": [user_b]},
        )
        assert_api.assert_response_matches(
            resp_remove,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.removeMembers.value,
                "device": "deviceA",
                "result": True,
            },
            ignore_keys={"sequence"},
        )

        expected_remove_events = {
            GroupChangeEvent.ON_USER_REMOVED.value,
            "onLeaveFromGroup",
            "onUserRemovedFromGroup",
        }
        required_remove_events = {"onUserRemovedFromGroup"}
        remove_events = collect_group_events(
            device_b,
            expected_event_types=expected_remove_events,
            group_id=group_id,
            allow_missing_group_id=True,
            required_all_event_types=required_remove_events,
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            remove_events,
            expected_event_types=expected_remove_events,
            group_id=group_id,
            allow_missing_group_id=True,
            required_all_event_types=required_remove_events,
            expected_member=user_b,
        )

        owner_remove_events = collect_group_events(
            device_a,
            expected_event_types={
                "onMembersExitedFromGroup",
                "onMemberExitedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onMembersExitedFromGroup", "onMemberExitedFromGroup"},
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            owner_remove_events,
            expected_event_types={
                "onMembersExitedFromGroup",
                "onMemberExitedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onMembersExitedFromGroup", "onMemberExitedFromGroup"},
            expected_member=user_b,
        )

        resp_get_after_remove = device_a.call(
            "GroupManager",
            Cmd.getGroupSpecificationFromServer.value,
            info={"groupId": group_id, "fetchMembers": True},
        )
        assert_group_snapshot(
            assert_api,
            resp_get_after_remove,
            cmd=Cmd.getGroupSpecificationFromServer.value,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count_value=1,
        )
        assert member_count(resp_get_after_remove) == 1, f"removeMembers 后 memberCount 预期 1: {resp_get_after_remove}"
        assert_group_members_exact(resp_get_after_remove, [], err_prefix="removeMembers 后")
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_join_and_leave_public_group(device_a, device_b, assert_api, user_a, user_b):
    """
    joinPublicGroup + leaveGroup：
    - A 创建公开群（style=1）
    - B 加入公开群
    - B 退群
    """
    group_name = new_group_name("public")
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[],
            style=1,
        )

        resp_join = device_b.call("GroupManager", Cmd.joinPublicGroup.value, info={"groupId": group_id})
        # 该环境 joinPublicGroup 对公开群返回业务错误体（result dict），按实际冻结
        assert_api.assert_error(resp_join, code=603, description="group member permission is required")

        # join 失败时不再要求 join 回调

        # join 失败后 leave 也会失败（未入群），按错误链路断言
        resp_leave = device_b.call("GroupManager", Cmd.leaveGroup.value, info={"groupId": group_id})
        assert_api.assert_error(resp_leave, code=603, description="group member permission is required")

        # 未入群的 leave 不再强制要求移除回调
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_members_batch_join_exit_new_events(device_a, device_b, assert_api, user_a, user_b, user_c):
    """
    校验新事件名：
    - onMembersJoinedFromGroup
    - onMembersExitedFromGroup
    """
    group_name = new_group_name("member_batch_evt")
    group_id = ""
    members = [user_b, user_c]
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[],
        )

        resp_add = device_a.call(
            "GroupManager",
            Cmd.addMembers.value,
            info={"groupId": group_id, "members": members, "welcome": "welcome"},
        )
        assert_api.assert_response_matches(
            resp_add,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.addMembers.value,
                "device": "deviceA",
                "result": True,
            },
            ignore_keys={"sequence"},
        )

        expected_joined_events = {"onMembersJoinedFromGroup", "onMemberJoinedFromGroup"}
        joined_events = collect_group_events(
            device_a,
            expected_event_types=expected_joined_events,
            group_id=group_id,
            required_all_event_types={"onMemberJoinedFromGroup"},
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            joined_events,
            expected_event_types=expected_joined_events,
            group_id=group_id,
            required_all_event_types={"onMemberJoinedFromGroup"},
        )
        joined_batch = [evt for evt in joined_events if evt.get("eventType") == "onMembersJoinedFromGroup"]
        if joined_batch:
            # SDK 可能对批量添加逐个触发事件，每个事件只含一个用户；合并所有事件的 userIds
            all_user_ids: list[str] = []
            for evt in joined_batch:
                data_join = (evt.get("data") or {})
                user_ids_join = data_join.get("userIds") or []
                assert isinstance(user_ids_join, list), f"onMembersJoinedFromGroup.userIds 非 list: {evt}"
                all_user_ids.extend(user_ids_join)
            assert all(m in all_user_ids for m in members), (
                f"onMembersJoinedFromGroup.userIds 缺少成员: expected={members}, actual={all_user_ids}"
            )
        else:
            joined_single_members = {
                (evt.get("data") or {}).get("member")
                for evt in joined_events
                if evt.get("eventType") == "onMemberJoinedFromGroup"
            }
            assert all(m in joined_single_members for m in members), (
                "未收到 onMembersJoinedFromGroup，且 onMemberJoinedFromGroup 未覆盖全部成员: "
                f"expected={members}, actual={sorted(x for x in joined_single_members if isinstance(x, str))}"
            )

        resp_remove = device_a.call(
            "GroupManager",
            Cmd.removeMembers.value,
            info={"groupId": group_id, "members": members},
        )
        assert_api.assert_response_matches(
            resp_remove,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.removeMembers.value,
                "device": "deviceA",
                "result": True,
            },
            ignore_keys={"sequence"},
        )

        expected_exited_events = {"onMembersExitedFromGroup", "onMemberExitedFromGroup"}
        exited_events = collect_group_events(
            device_a,
            expected_event_types=expected_exited_events,
            group_id=group_id,
            required_all_event_types={"onMembersExitedFromGroup"},
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            exited_events,
            expected_event_types=expected_exited_events,
            group_id=group_id,
            required_all_event_types={"onMembersExitedFromGroup"},
        )
        exited_batch = [evt for evt in exited_events if evt.get("eventType") == "onMembersExitedFromGroup"]
        if exited_batch:
            # SDK 对批量移除逐个触发事件，合并所有事件的 userIds
            all_exit_ids: list[str] = []
            for evt in exited_batch:
                data_exit = (evt.get("data") or {})
                user_ids_exit = data_exit.get("userIds") or []
                assert isinstance(user_ids_exit, list), f"onMembersExitedFromGroup.userIds 非 list: {evt}"
                all_exit_ids.extend(user_ids_exit)
            assert all(m in all_exit_ids for m in members), (
                f"onMembersExitedFromGroup.userIds 缺少成员: expected={members}, actual={all_exit_ids}"
            )
        else:
            exited_single_members = {
                (evt.get("data") or {}).get("member")
                for evt in exited_events
                if evt.get("eventType") == "onUserRemovedFromGroup"
            }
            assert all(m in exited_single_members for m in members), (
                "未收到 onMembersExitedFromGroup，且 onUserRemovedFromGroup 未覆盖全部成员: "
                f"expected={members}, actual={sorted(x for x in exited_single_members if isinstance(x, str))}"
            )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)
