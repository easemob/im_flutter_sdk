"""Group list API 用例（strict）。"""
from __future__ import annotations

import time

import pytest

from src import Cmd
from src.tools.group_capacity import get_group_create_max_count
from tests.group.group_helpers import (
    assert_group_events,
    assert_group_list_response,
    assert_no_group_event,
    collect_group_events,
    create_group,
    destroy_group,
    find_group_in_list,
    new_group_name,
)


pytestmark = [pytest.mark.client, pytest.mark.group]


def _joined_group_expected(
    *,
    group_id: str,
    group_name: str,
    owner: str,
    permission_type: int,
    member_count: int,
) -> dict:
    return {
        "owner": owner,
        "ext": "auto-ext",
        "permissionType": permission_type,
        "isAllMemberMuted": False,
        "adminList": [],
        "avatarUrl": "",
        "groupId": group_id,
        "memberCount": member_count,
        "isMemberOnly": True,
        "muteList": [],
        "isMemberAllowToInvite": False,
        "messageBlocked": False,
        "memberList": [],
        "blockList": [],
        "name": group_name,
        "maxUserCount": get_group_create_max_count(),
        "isDisabled": False,
        "desc": "auto-test group",
        "announcement": "",
    }


def _assert_joined_target(
    device,
    assert_api,
    *,
    device_name: str,
    cmd: str,
    group_id: str,
    expected_group: dict | None,
) -> None:
    resp = device.call("GroupManager", cmd, info={})
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "GroupManager",
            "cmd": cmd,
            "device": device_name,
        },
        ignore_keys={"sequence", "result"},
    )
    result = resp.get("result")
    assert isinstance(result, list), f"{cmd} result 不是 list: {resp}"
    target = [item for item in result if isinstance(item, dict) and item.get("groupId") == group_id]
    expected_target = [] if expected_group is None else [expected_group]
    assert target == expected_target, (
        f"{cmd} 目标群投影不匹配: expected={expected_target}, actual={target}, resp={resp}"
    )


def _assert_both_joined_lists(
    device,
    assert_api,
    *,
    group_id: str,
    expected_group: dict | None,
) -> None:
    for cmd in (Cmd.getJoinedGroups.value, Cmd.getJoinedGroupsFromServer.value):
        _assert_joined_target(
            device,
            assert_api,
            device_name="deviceB",
            cmd=cmd,
            group_id=group_id,
            expected_group=expected_group,
        )


def _assert_exact_event(assert_api, event: dict, *, event_type: str, data: dict) -> None:
    assert_api.assert_response_matches(
        event,
        expected={"type": "event", "eventType": event_type, "data": data},
        ignore_keys={"timestamp", "sequence"},
    )


def test_group_get_joined_groups_local_contains_created_group(device_a, assert_api, user_a):
    """
    前置：A 已登录且尚未创建本 case 的目标群。
    步骤：A 创建私有群，随后调用本地 getJoinedGroups 并按动态 groupId 投影。
    预期与断言：目标群存在，owner 与 name 等于创建上下文；接口信封和列表对象结构合法。
    """
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
    """
    前置：A 已登录且尚未创建本 case 的目标群。
    步骤：A 创建私有群，随后调用服务端 getJoinedGroupsFromServer 并按 groupId 投影。
    预期与断言：目标群存在，owner 与 name 等于创建上下文；接口信封和列表对象结构合法。
    """
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


def test_group_joined_lists_follow_invite_remove_readd_and_member_leave(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """
    前置：A 为群主，B 初始不是目标群成员，B 的自动接受邀请开关为 true。
    步骤：
    1. A 建群并直接邀请 B；消费 A/B 入群事件后查询 B 的本地和服务端已加入群列表。
    2. A 移除 B；消费 B 被移除事件和 A 的成员退出事件，等待缓存收敛后再次查询两份列表。
    3. A 重新添加 B；消费双方真实入群事件，等待后查询两份列表。
    4. B 主动 leaveGroup；消费 A 的退出事件并确认 B 无同类事件，再查询两份列表。
    预期与断言：步骤 1/3 的两个列表均包含目标群完整成员视角对象（permissionType=0、
    memberCount=2）；步骤 2/4 的目标群投影均为空；同步响应和每次 A/B 事件字段按真实
    ADB 返回严格匹配。
    """
    group_id = ""
    group_name = new_group_name("joined_transition")
    member_group: dict | None = None
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b],
        )
        member_group = _joined_group_expected(
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            permission_type=0,
            member_count=2,
        )

        initial_member_events = collect_group_events(
            device_b,
            expected_event_types={"onAutoAcceptInvitationFromGroup"},
            group_id=group_id,
            required_all_event_types={"onAutoAcceptInvitationFromGroup"},
            timeout=10.0,
        )
        _assert_exact_event(
            assert_api,
            initial_member_events[0],
            event_type="onAutoAcceptInvitationFromGroup",
            data={"groupId": group_id, "inviter": user_a, "inviteMessage": ""},
        )
        joined_event_types = {"onMembersJoinedFromGroup", "onMemberJoinedFromGroup"}
        initial_owner_events = collect_group_events(
            device_a,
            expected_event_types=joined_event_types,
            group_id=group_id,
            required_all_event_types=joined_event_types,
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            initial_owner_events,
            expected_event_types=joined_event_types,
            group_id=group_id,
            required_all_event_types=joined_event_types,
            expected_member=user_b,
        )
        time.sleep(1.0)
        _assert_both_joined_lists(
            device_b,
            assert_api,
            group_id=group_id,
            expected_group=member_group,
        )

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
        removed_member_events = collect_group_events(
            device_b,
            expected_event_types={"onUserRemovedFromGroup"},
            group_id=group_id,
            required_all_event_types={"onUserRemovedFromGroup"},
            timeout=10.0,
        )
        _assert_exact_event(
            assert_api,
            removed_member_events[0],
            event_type="onUserRemovedFromGroup",
            data={"groupId": group_id, "groupName": group_name},
        )
        exited_event_types = {"onMembersExitedFromGroup", "onMemberExitedFromGroup"}
        removed_owner_events = collect_group_events(
            device_a,
            expected_event_types=exited_event_types,
            group_id=group_id,
            required_all_event_types=exited_event_types,
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            removed_owner_events,
            expected_event_types=exited_event_types,
            group_id=group_id,
            required_all_event_types=exited_event_types,
            expected_member=user_b,
        )
        time.sleep(1.0)
        _assert_both_joined_lists(
            device_b,
            assert_api,
            group_id=group_id,
            expected_group=None,
        )

        rejoin_message = "joined-list-readd"
        resp_readd = device_a.call(
            "GroupManager",
            Cmd.addMembers.value,
            info={"groupId": group_id, "members": [user_b], "welcome": rejoin_message},
        )
        assert_api.assert_response_matches(
            resp_readd,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.addMembers.value,
                "device": "deviceA",
                "result": True,
            },
            ignore_keys={"sequence"},
        )
        readded_member_events = collect_group_events(
            device_b,
            expected_event_types={"onAutoAcceptInvitationFromGroup"},
            group_id=group_id,
            required_all_event_types={"onAutoAcceptInvitationFromGroup"},
            timeout=10.0,
        )
        _assert_exact_event(
            assert_api,
            readded_member_events[0],
            event_type="onAutoAcceptInvitationFromGroup",
            data={"groupId": group_id, "inviter": user_a, "inviteMessage": ""},
        )
        readded_owner_events = collect_group_events(
            device_a,
            expected_event_types=joined_event_types,
            group_id=group_id,
            required_all_event_types=joined_event_types,
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            readded_owner_events,
            expected_event_types=joined_event_types,
            group_id=group_id,
            required_all_event_types=joined_event_types,
            expected_member=user_b,
        )
        time.sleep(1.0)
        _assert_both_joined_lists(
            device_b,
            assert_api,
            group_id=group_id,
            expected_group=member_group,
        )

        resp_leave = device_b.call(
            "GroupManager",
            Cmd.leaveGroup.value,
            info={"groupId": group_id},
        )
        assert_api.assert_response_matches(
            resp_leave,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.leaveGroup.value,
                "device": "deviceB",
                "result": True,
            },
            ignore_keys={"sequence"},
        )
        leave_owner_events = collect_group_events(
            device_a,
            expected_event_types=exited_event_types,
            group_id=group_id,
            required_all_event_types=exited_event_types,
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            leave_owner_events,
            expected_event_types=exited_event_types,
            group_id=group_id,
            required_all_event_types=exited_event_types,
            expected_member=user_b,
        )
        assert_no_group_event(
            device_b,
            group_id=group_id,
            event_types=exited_event_types,
        )
        time.sleep(1.0)
        _assert_both_joined_lists(
            device_b,
            assert_api,
            group_id=group_id,
            expected_group=None,
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)
