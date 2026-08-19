"""群成员终态在 SDK logout/login 窗口内的离线一致性。"""
from __future__ import annotations

import os
import time

import pytest
from tests.group.allure_helpers import _allure_step

from src import Cmd
from tests.group.group_helpers import assert_group_snapshot, create_group, new_group_name
from tests.group.group_offline_helpers import (
    assert_call_result,
    assert_joined_group_projection,
    device_name,
    login_group_account_devices,
    logout_group_account_devices,
    restore_group_users,
    safe_destroy_group,
    wait_group_event,
)


pytestmark = [
    pytest.mark.client,
    pytest.mark.group,
    pytest.mark.agorachat1_4_0,
    pytest.mark.topology("account_a_to_account_b"),
]


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
    style: int = 0,
) -> None:
    response = device_a.call(
        "GroupManager",
        Cmd.getGroupSpecificationFromServer.value,
        info={"groupId": group_id},
    )
    assert_group_snapshot(
        assert_api,
        response,
        cmd=Cmd.getGroupSpecificationFromServer.value,
        group_id=group_id,
        group_name=group_name,
        owner=user_a,
        block_list_value=block_list,
        is_public=style in (2, 3),
        join_approval_required=style == 2,
        # 5.0 快照不含成员（getGroupFromServer 移除 fetchMembers）→ 成员单独分页拉取验证
    )
    members_resp = device_a.call(
        "GroupManager",
        Cmd.getGroupMemberListFromServer.value,
        info={"groupId": group_id, "pageSize": 20, "cursor": ""},
    )
    member_ids = [m.get("member") if isinstance(m, dict) else m for m in ((members_resp.get("result") or {}).get("list") or [])]
    # 5.0 asyncFetchGroupMembers 返回非 owner 成员（4.x memberCount 含 owner）→ 期望 = member_count - 1
    assert len(member_ids) == member_count - 1, f"成员数不匹配: 预期 {member_count - 1}, 实际 {len(member_ids)}: {member_ids}"


def _assert_member_group_absent(
    device_b,
    assert_api,
    *,
    group_id: str,
) -> None:
    assert_joined_group_projection(
        device_b,
        assert_api,
        device_name=device_name(device_b),
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
        device_name=device_name(device_b),
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
    sender_devices=(),
    recipient_devices=(),
) -> None:
    restore_group_users(
        device_a,
        device_b,
        assert_api,
        user_a=user_a,
        user_b=user_b,
        sender_devices=sender_devices,
        recipient_devices=recipient_devices,
    )
    safe_destroy_group(device_a, group_id)



def test_group_offline_member_removed_state_after_login(
    topology,
    assert_api,
):
    """B 离线期间被移出；重登收到真实终态事件且本地/服务端均不再入群。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    group_id = ""
    group_name = ""
    try:
        with _allure_step("测试准备：创建测试群并建立成员前置"):
            group_id, group_name = _create_member_group(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                name_prefix="offline_member_removed",
            )
        with _allure_step("测试准备：切换账号设备在线状态"):
            logout_group_account_devices(recipient_devices, assert_api)
        with _allure_step("A 移除群成员"):
            removed = device_a.call(
                "GroupManager",
                Cmd.removeMembers.value,
                info={"groupId": group_id, "members": [user_b]},
            )
        with _allure_step("验证 移除群成员返回的关键字段"):
            assert_call_result(
                assert_api,
                removed,
                manager="GroupManager",
                cmd=Cmd.removeMembers.value,
                device_name=device_name(device_a),
                result=True,
            )
        with _allure_step("测试准备：切换账号设备在线状态"):
            login_group_account_devices(recipient_devices, assert_api, user_id=user_b)
        for endpoint in recipient_devices:
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_member_terminal_event(
                    endpoint,
                    assert_api,
                    event_type="onGroupUserRemoved",
                    group_id=group_id,
                    group_name=group_name,
                )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_owner_server_state(
                device_a,
                assert_api,
                group_id=group_id,
                group_name=group_name,
                user_a=user_a,
                member_count=1,
                block_list=[],
            )
        for endpoint in recipient_devices:
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_member_group_absent(endpoint, assert_api, group_id=group_id)
    finally:
        _restore_case(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            group_id=group_id,
            sender_devices=sender_devices,
            recipient_devices=recipient_devices,
        )


def test_group_offline_member_blocked_state_after_login(
    topology,
    assert_api,
):
    """B 离线期间被加入群黑名单；重登后成员移除且服务端黑名单包含 B。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    group_id = ""
    group_name = ""
    try:
        with _allure_step("测试准备：创建测试群并建立成员前置"):
            group_id, group_name = _create_member_group(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                name_prefix="offline_member_blocked",
                style=3,
            )
        with _allure_step("测试准备：切换账号设备在线状态"):
            logout_group_account_devices(recipient_devices, assert_api)
        with _allure_step("A 加入群黑名单"):
            blocked = device_a.call(
                "GroupManager",
                Cmd.blockMembers.value,
                info={"groupId": group_id, "members": [user_b]},
            )
        with _allure_step("验证加入群黑名单返回的关键字段"):
            assert_call_result(
                assert_api,
                blocked,
                manager="GroupManager",
                cmd=Cmd.blockMembers.value,
                device_name=device_name(device_a),
                result=True,
            )
        with _allure_step("测试准备：切换账号设备在线状态"):
            login_group_account_devices(recipient_devices, assert_api, user_id=user_b)
        for endpoint in recipient_devices:
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_member_terminal_event(
                    endpoint,
                    assert_api,
                    event_type="onGroupUserRemoved",
                    group_id=group_id,
                    group_name=group_name,
                )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_owner_server_state(
                device_a,
                assert_api,
                group_id=group_id,
                group_name=group_name,
                user_a=user_a,
                member_count=1,
                block_list=[user_b],
                style=3,
            )
        for endpoint in recipient_devices:
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_member_group_absent(endpoint, assert_api, group_id=group_id)
        with _allure_step("B 加入公开群"):
            rejoin = device_b.call(
                "GroupManager",
                Cmd.joinPublicGroup.value,
                info={"groupId": group_id},
            )
        with _allure_step("验证加入公开群返回的错误码与错误文案"):
            assert_api.assert_error(rejoin, code=613, description="blacklist")
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_owner_server_state(
                device_a,
                assert_api,
                group_id=group_id,
                group_name=group_name,
                user_a=user_a,
                member_count=1,
                block_list=[user_b],
                style=3,
            )
    finally:
        _restore_case(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            group_id=group_id,
            sender_devices=sender_devices,
            recipient_devices=recipient_devices,
        )


def test_group_offline_group_destroyed_state_after_login(
    topology,
    assert_api,
):
    """B 离线期间群被解散；重登收到解散事件且本地/服务端 joined 投影为空。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    group_id = ""
    group_name = ""
    try:
        with _allure_step("测试准备：创建测试群并建立成员前置"):
            group_id, group_name = _create_member_group(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                name_prefix="offline_group_destroyed",
            )
        with _allure_step("测试准备：切换账号设备在线状态"):
            logout_group_account_devices(recipient_devices, assert_api)
        with _allure_step("A 销毁测试群"):
            destroyed = device_a.call(
                "GroupManager",
                Cmd.destroyGroup.value,
                info={"groupId": group_id},
            )
        with _allure_step("验证销毁测试群返回的关键字段"):
            assert_call_result(
                assert_api,
                destroyed,
                manager="GroupManager",
                cmd=Cmd.destroyGroup.value,
                device_name=device_name(device_a),
                result=True,
            )
        with _allure_step("测试准备：切换账号设备在线状态"):
            login_group_account_devices(recipient_devices, assert_api, user_id=user_b)
        for endpoint in recipient_devices:
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_member_terminal_event(
                    endpoint,
                    assert_api,
                    event_type="onGroupDestroyed",
                    group_id=group_id,
                    group_name=group_name,
                )
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_member_group_absent(endpoint, assert_api, group_id=group_id)
        group_id = ""
    finally:
        _restore_case(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            group_id=group_id,
            sender_devices=sender_devices,
            recipient_devices=recipient_devices,
        )


def test_group_offline_member_leave_state_persists_after_relogin(
    topology,
    assert_api,
):
    """B 主动退群后 logout/login；成员数、joined groups 和本地群对象保持退出终态。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    group_id = ""
    group_name = ""
    try:
        with _allure_step("测试准备：创建测试群并建立成员前置"):
            group_id, group_name = _create_member_group(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                name_prefix="offline_member_leave",
            )
        with _allure_step("B 退出群"):
            left = device_b.call(
                "GroupManager",
                Cmd.leaveGroup.value,
                info={"groupId": group_id},
            )
        with _allure_step("验证退出群返回的关键字段"):
            assert_call_result(
                assert_api,
                left,
                manager="GroupManager",
                cmd=Cmd.leaveGroup.value,
                device_name=device_name(device_b),
                result=True,
            )
        with _allure_step("测试准备：切换账号设备在线状态"):
            logout_group_account_devices(recipient_devices, assert_api)
        with _allure_step("测试准备：切换账号设备在线状态"):
            login_group_account_devices(recipient_devices, assert_api, user_id=user_b)
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_owner_server_state(
                device_a,
                assert_api,
                group_id=group_id,
                group_name=group_name,
                user_a=user_a,
                member_count=1,
                block_list=[],
            )
        for endpoint in recipient_devices:
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_member_group_absent(endpoint, assert_api, group_id=group_id)
    finally:
        _restore_case(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            group_id=group_id,
            sender_devices=sender_devices,
            recipient_devices=recipient_devices,
        )
