"""群成员终态在 SDK logout/login 窗口内的离线一致性。"""
from __future__ import annotations

import os
import time

import pytest

from src import Cmd
from src.test_flow.offline_test_flow import (
    login_preserving_offline_events,
    logout_for_offline,
)
from tests.group.group_helpers import assert_group_snapshot, create_group, new_group_name
from tests.group.group_offline_helpers import (
    assert_call_result,
    assert_joined_group_projection,
    restore_group_users,
    safe_destroy_group,
    wait_group_event,
)


pytestmark = [pytest.mark.client, pytest.mark.group, pytest.mark.agorachat1_4_0]


def _create_member_group(
    device_a,
    device_b,
    assert_api,
    *,
    user_a: str,
    user_b: str,
    name_prefix: str,
    style: int = 0,
) -> tuple[str, str]:
    device_a.drain_events(timeout=0.5)
    device_b.drain_events(timeout=0.5)
    group_name = new_group_name(name_prefix)
    group_id, _ = create_group(
        device_a,
        assert_api,
        owner=user_a,
        group_name=group_name,
        invite_members=[user_b],
        style=style,
    )
    time.sleep(float(os.getenv("GROUP_OFFLINE_MEMBER_SETTLE_SECONDS", "3")))
    device_a.drain_events(timeout=0.5)
    device_b.drain_events(timeout=0.5)
    return group_id, group_name


def _assert_owner_server_state(
    device_a,
    assert_api,
    *,
    group_id: str,
    group_name: str,
    user_a: str,
    member_count: int,
    block_list: list[str],
    is_member_only: bool = True,
) -> None:
    response = device_a.call(
        "GroupManager",
        Cmd.getGroupSpecificationFromServer.value,
        info={"groupId": group_id, "fetchMembers": True},
    )
    assert_group_snapshot(
        assert_api,
        response,
        cmd=Cmd.getGroupSpecificationFromServer.value,
        group_id=group_id,
        group_name=group_name,
        owner=user_a,
        member_count_value=member_count,
        block_list_value=block_list,
        is_member_only=is_member_only,
    )


def _assert_member_group_absent(
    device_b,
    assert_api,
    *,
    group_id: str,
) -> None:
    assert_joined_group_projection(
        device_b,
        assert_api,
        device_name="deviceB",
        group_id=group_id,
        present=False,
    )
    local = device_b.call(
        "GroupManager",
        Cmd.getGroupWithId.value,
        info={"groupId": group_id},
    )
    assert_call_result(
        assert_api,
        local,
        manager="GroupManager",
        cmd=Cmd.getGroupWithId.value,
        device_name="deviceB",
        result=None,
    )


def _assert_member_terminal_event(
    device_b,
    assert_api,
    *,
    event_type: str,
    group_id: str,
    group_name: str,
) -> None:
    event = wait_group_event(
        device_b,
        event_type=event_type,
        group_id=group_id,
        timeout=30.0,
    )
    assert_api.assert_response_matches(
        event,
        expected={
            "type": "event",
            "eventType": event_type,
            "data": {"groupId": group_id, "groupName": group_name},
        },
        ignore_keys={"timestamp", "sequence"},
    )


def _restore_case(
    device_a,
    device_b,
    assert_api,
    *,
    user_a: str,
    user_b: str,
    group_id: str,
) -> None:
    restore_group_users(
        device_a,
        device_b,
        assert_api,
        user_a=user_a,
        user_b=user_b,
    )
    safe_destroy_group(device_a, group_id)


def test_group_offline_member_removed_state_after_login(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """B 离线期间被移出；重登收到真实终态事件且本地/服务端均不再入群。"""
    group_id = ""
    group_name = ""
    try:
        group_id, group_name = _create_member_group(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            name_prefix="offline_member_removed",
        )
        logout_for_offline(device_b, assert_api, device_name="deviceB")
        removed = device_a.call(
            "GroupManager",
            Cmd.removeMembers.value,
            info={"groupId": group_id, "members": [user_b]},
        )
        assert_call_result(
            assert_api,
            removed,
            manager="GroupManager",
            cmd=Cmd.removeMembers.value,
            device_name="deviceA",
            result=True,
        )
        login_preserving_offline_events(
            device_b,
            assert_api,
            device_name="deviceB",
            user_id=user_b,
        )
        _assert_member_terminal_event(
            device_b,
            assert_api,
            event_type="onUserRemovedFromGroup",
            group_id=group_id,
            group_name=group_name,
        )
        _assert_owner_server_state(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            user_a=user_a,
            member_count=1,
            block_list=[],
        )
        _assert_member_group_absent(device_b, assert_api, group_id=group_id)
    finally:
        _restore_case(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            group_id=group_id,
        )


def test_group_offline_member_blocked_state_after_login(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """B 离线期间被加入群黑名单；重登后成员移除且服务端黑名单包含 B。"""
    group_id = ""
    group_name = ""
    try:
        group_id, group_name = _create_member_group(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            name_prefix="offline_member_blocked",
            style=3,
        )
        logout_for_offline(device_b, assert_api, device_name="deviceB")
        blocked = device_a.call(
            "GroupManager",
            Cmd.blockMembers.value,
            info={"groupId": group_id, "members": [user_b]},
        )
        assert_call_result(
            assert_api,
            blocked,
            manager="GroupManager",
            cmd=Cmd.blockMembers.value,
            device_name="deviceA",
            result=True,
        )
        login_preserving_offline_events(
            device_b,
            assert_api,
            device_name="deviceB",
            user_id=user_b,
        )
        _assert_member_terminal_event(
            device_b,
            assert_api,
            event_type="onUserRemovedFromGroup",
            group_id=group_id,
            group_name=group_name,
        )
        _assert_owner_server_state(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            user_a=user_a,
            member_count=1,
            block_list=[user_b],
            is_member_only=False,
        )
        _assert_member_group_absent(device_b, assert_api, group_id=group_id)
        rejoin = device_b.call(
            "GroupManager",
            Cmd.joinPublicGroup.value,
            info={"groupId": group_id},
        )
        assert_api.assert_error(rejoin, code=613, description="blacklist")
        _assert_owner_server_state(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            user_a=user_a,
            member_count=1,
            block_list=[user_b],
            is_member_only=False,
        )
    finally:
        _restore_case(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            group_id=group_id,
        )


def test_group_offline_group_destroyed_state_after_login(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """B 离线期间群被解散；重登收到解散事件且本地/服务端 joined 投影为空。"""
    group_id = ""
    group_name = ""
    try:
        group_id, group_name = _create_member_group(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            name_prefix="offline_group_destroyed",
        )
        logout_for_offline(device_b, assert_api, device_name="deviceB")
        destroyed = device_a.call(
            "GroupManager",
            Cmd.destroyGroup.value,
            info={"groupId": group_id},
        )
        assert_call_result(
            assert_api,
            destroyed,
            manager="GroupManager",
            cmd=Cmd.destroyGroup.value,
            device_name="deviceA",
            result=True,
        )
        login_preserving_offline_events(
            device_b,
            assert_api,
            device_name="deviceB",
            user_id=user_b,
        )
        _assert_member_terminal_event(
            device_b,
            assert_api,
            event_type="onGroupDestroyed",
            group_id=group_id,
            group_name=group_name,
        )
        _assert_member_group_absent(device_b, assert_api, group_id=group_id)
        group_id = ""
    finally:
        _restore_case(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            group_id=group_id,
        )


def test_group_offline_member_leave_state_persists_after_relogin(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """B 主动退群后 logout/login；成员数、joined groups 和本地群对象保持退出终态。"""
    group_id = ""
    group_name = ""
    try:
        group_id, group_name = _create_member_group(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            name_prefix="offline_member_leave",
        )
        left = device_b.call(
            "GroupManager",
            Cmd.leaveGroup.value,
            info={"groupId": group_id},
        )
        assert_call_result(
            assert_api,
            left,
            manager="GroupManager",
            cmd=Cmd.leaveGroup.value,
            device_name="deviceB",
            result=True,
        )
        logout_for_offline(device_b, assert_api, device_name="deviceB")
        login_preserving_offline_events(
            device_b,
            assert_api,
            device_name="deviceB",
            user_id=user_b,
        )
        _assert_owner_server_state(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            user_a=user_a,
            member_count=1,
            block_list=[],
        )
        _assert_member_group_absent(device_b, assert_api, group_id=group_id)
    finally:
        _restore_case(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            group_id=group_id,
        )
