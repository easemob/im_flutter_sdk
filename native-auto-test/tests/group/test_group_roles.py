"""Group 角色权限正常用例（strict）。"""
from __future__ import annotations

import time

import pytest

from src import Cmd, GroupChangeEvent
from tests.group.group_helpers import (
    assert_group_events,
    collect_group_events,
    create_group,
    destroy_group,
    new_group_name,
)


pytestmark = [pytest.mark.client, pytest.mark.group]


def _assert_no_group_event(
    device,
    *,
    group_id: str,
    event_types: set[str],
    timeout: float = 3.0,
) -> None:
    deadline = time.monotonic() + timeout
    seen: list[dict] = []
    while time.monotonic() < deadline:
        remaining = max(0.1, deadline - time.monotonic())
        evt = device.receive_message(timeout=min(1.0, remaining))
        if not isinstance(evt, dict):
            continue
        if evt.get("type") != "event":
            continue
        evt_type = evt.get("eventType")
        if evt_type not in event_types:
            continue
        data = evt.get("data")
        if isinstance(data, dict) and data.get("groupId") == group_id:
            seen.append(evt)
            break
    assert not seen, f"操作者端不应收到这些群组回调: groupId={group_id}, seen={seen}"


@pytest.mark.topology("account_a_to_account_b")
def test_group_add_admin_and_remove_admin_success(topology, assert_api):
    """
    多端拓扑：A 添加/移除 B 为管理员；admin 事件同步到 B 全部在线端，A 全部端不收 admin 事件（原生语义）。
    """
    sender = topology.sender_action_device
    recipients = topology.recipient_devices
    owner_user = topology.sender_user
    member_user = topology.recipient_user

    group_id = ""
    group_name = new_group_name("role_admin")
    try:
        with _allure_step(f"{sender.device_name} 建群并邀请 {member_user}"):
            group_id, _ = create_group(
                sender,
                assert_api,
                owner=owner_user,
                group_name=group_name,
                invite_members=[member_user],
            )

        with _allure_step(f"{sender.device_name} 添加 {member_user} 为管理员"):
            resp_add_admin = sender.call(
                "GroupManager",
                Cmd.addAdmin.value,
                info={"groupId": group_id, "admin": member_user},
            )
        with _allure_step("确认添加管理员请求已提交（result 含 adminList）"):
            assert_api.assert_response_matches(
                resp_add_admin,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.addAdmin.value,
                    "device": sender.device_name,
                },
                ignore_keys={"sequence", "result"},
            )
            add_admin_result = resp_add_admin.get("result")
            assert isinstance(add_admin_result, dict), f"addAdmin result 非 dict: {resp_add_admin}"
            assert add_admin_result.get("groupId") == group_id, f"addAdmin groupId 不匹配: {resp_add_admin}"
            assert add_admin_result.get("owner") == owner_user, f"addAdmin owner 不匹配: {resp_add_admin}"
            assert add_admin_result.get("memberCount") == 2, f"addAdmin memberCount 不匹配: {resp_add_admin}"
            admin_list_add = add_admin_result.get("adminList")
            assert isinstance(admin_list_add, list), f"addAdmin adminList 非 list: {resp_add_admin}"
            assert member_user in admin_list_add, f"addAdmin adminList 不包含 {member_user}: {resp_add_admin}"

        with _allure_step("B 全部在线端收到管理员添加事件"):
            for endpoint in recipients:
                admin_added_events = collect_group_events(
                    endpoint,
                    expected_event_types={
                        GroupChangeEvent.ON_ADMIN_ADDED.value,
                        "onGroupAdminAdded",
                    },
                    group_id=group_id,
                    required_all_event_types={"onGroupAdminAdded"},
                    timeout=10.0,
                )
                assert_group_events(
                    assert_api,
                    admin_added_events,
                    expected_event_types={
                        GroupChangeEvent.ON_ADMIN_ADDED.value,
                        "onGroupAdminAdded",
                    },
                    group_id=group_id,
                    required_all_event_types={"onGroupAdminAdded"},
                    expected_member=member_user,
                )
        with _allure_step("A 全部在线端不收管理员添加事件（原生语义：admin 事件仅 B 收）"):
            for endpoint in topology.sender_devices:
                _assert_no_group_event(
                    endpoint,
                    group_id=group_id,
                    event_types={
                        GroupChangeEvent.ON_ADMIN_ADDED.value,
                        "onGroupAdminAdded",
                    },
                )

        with _allure_step("A 全部在线端查询群规格 adminList 含 B（账号级服务端状态一致）"):
            for endpoint in topology.sender_devices:
                resp_get_admin_added = endpoint.call(
                    "GroupManager",
                    Cmd.getGroupSpecificationFromServer.value,
                    info={"groupId": group_id},
                )
                assert_api.assert_response_matches(
                    resp_get_admin_added,
                    expected={
                        "manager": "GroupManager",
                        "cmd": Cmd.getGroupSpecificationFromServer.value,
                        "device": endpoint.device_name,
                    },
                    ignore_keys={"sequence", "result"},
                )
                result_get_admin_added = resp_get_admin_added.get("result")
                assert isinstance(result_get_admin_added, dict), f"getGroupSpecificationFromServer result 非 dict: {resp_get_admin_added}"
                assert result_get_admin_added.get("groupId") == group_id, f"groupId 不匹配: {resp_get_admin_added}"
                assert result_get_admin_added.get("owner") == owner_user, f"owner 不匹配: {resp_get_admin_added}"
                assert result_get_admin_added.get("memberCount") == 2, f"memberCount 不匹配: {resp_get_admin_added}"
                admin_list = result_get_admin_added.get("adminList")
                assert isinstance(admin_list, list), f"adminList 不是 list: {resp_get_admin_added}"
                assert member_user in admin_list, f"addAdmin 后 adminList 缺少 {member_user}: {resp_get_admin_added}"

        with _allure_step(f"{sender.device_name} 移除 {member_user} 的管理员"):
            resp_remove_admin = sender.call(
                "GroupManager",
                Cmd.removeAdmin.value,
                info={"groupId": group_id, "admin": member_user},
            )
        with _allure_step("确认移除管理员请求已提交（result 含 adminList）"):
            assert_api.assert_response_matches(
                resp_remove_admin,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.removeAdmin.value,
                    "device": sender.device_name,
                },
                ignore_keys={"sequence", "result"},
            )
            remove_admin_result = resp_remove_admin.get("result")
            assert isinstance(remove_admin_result, dict), f"removeAdmin result 非 dict: {resp_remove_admin}"
            assert remove_admin_result.get("groupId") == group_id, f"removeAdmin groupId 不匹配: {resp_remove_admin}"
            assert remove_admin_result.get("owner") == owner_user, f"removeAdmin owner 不匹配: {resp_remove_admin}"
            assert remove_admin_result.get("memberCount") == 2, f"removeAdmin memberCount 不匹配: {resp_remove_admin}"
            admin_list_remove = remove_admin_result.get("adminList")
            assert isinstance(admin_list_remove, list), f"removeAdmin adminList 非 list: {resp_remove_admin}"
            assert member_user not in admin_list_remove, f"removeAdmin adminList 仍包含 {member_user}: {resp_remove_admin}"

        with _allure_step("B 全部在线端收到管理员移除事件"):
            for endpoint in recipients:
                admin_removed_events = collect_group_events(
                    endpoint,
                    expected_event_types={
                        GroupChangeEvent.ON_ADMIN_REMOVED.value,
                        "onGroupAdminRemoved",
                    },
                    group_id=group_id,
                    required_all_event_types={"onGroupAdminRemoved"},
                    timeout=10.0,
                )
                assert_group_events(
                    assert_api,
                    admin_removed_events,
                    expected_event_types={
                        GroupChangeEvent.ON_ADMIN_REMOVED.value,
                        "onGroupAdminRemoved",
                    },
                    group_id=group_id,
                    required_all_event_types={"onGroupAdminRemoved"},
                    expected_member=member_user,
                )
        with _allure_step("A 全部在线端不收管理员移除事件（原生语义）"):
            for endpoint in topology.sender_devices:
                _assert_no_group_event(
                    endpoint,
                    group_id=group_id,
                    event_types={
                        GroupChangeEvent.ON_ADMIN_REMOVED.value,
                        "onGroupAdminRemoved",
                    },
                )

        with _allure_step("A 全部在线端查询群规格 adminList 均不含 B"):
            for endpoint in topology.sender_devices:
                resp_get_admin_removed = endpoint.call(
                    "GroupManager",
                    Cmd.getGroupSpecificationFromServer.value,
                    info={"groupId": group_id},
                )
                admin_list_after_remove = resp_get_admin_removed.get("result", {}).get("adminList")
                assert isinstance(admin_list_after_remove, list), f"adminList 不是 list: {resp_get_admin_removed}"
                assert member_user not in admin_list_after_remove, (
                    f"removeAdmin 后 adminList 仍包含 {member_user}: {resp_get_admin_removed}"
                )
    finally:
        if group_id:
            destroy_group(sender, assert_api, group_id)


@pytest.mark.topology("account_a_to_account_b")
def test_group_update_owner_success(topology, assert_api):
    """
    多端拓扑：A 转让群 owner 给 B；owner 变更事件同步到 A/B 全部在线端，B 全部端查询群 owner 一致。
    """
    sender = topology.sender_action_device
    recipients = topology.recipient_devices
    owner_user = topology.sender_user
    member_user = topology.recipient_user

    group_id = ""
    group_name = new_group_name("role_owner")
    try:
        with _allure_step(f"{sender.device_name} 建群并邀请 {member_user}"):
            group_id, _ = create_group(
                sender,
                assert_api,
                owner=owner_user,
                group_name=group_name,
                invite_members=[member_user],
            )

        with _allure_step(f"{sender.device_name} 转让群 owner 给 {member_user}"):
            resp_update_owner = sender.call(
                "GroupManager",
                Cmd.updateGroupOwner.value,
                info={"groupId": group_id, "owner": member_user},
            )
        with _allure_step("确认转让请求已提交（result 含 owner）"):
            assert_api.assert_response_matches(
                resp_update_owner,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.updateGroupOwner.value,
                    "device": sender.device_name,
                },
                ignore_keys={"sequence", "result"},
            )
            owner_result = resp_update_owner.get("result")
            assert isinstance(owner_result, dict), f"updateGroupOwner result 非 dict: {resp_update_owner}"
            assert owner_result.get("groupId") == group_id, f"updateGroupOwner groupId 不匹配: {resp_update_owner}"
            assert owner_result.get("owner") == member_user, f"updateGroupOwner owner 不匹配: {resp_update_owner}"
            assert owner_result.get("memberCount") == 2, f"updateGroupOwner memberCount 不匹配: {resp_update_owner}"
            assert owner_result.get("isPublic") is False, f"updateGroupOwner isPublic 不匹配: {resp_update_owner}"

        with _allure_step("B 全部在线端收到 owner 变更事件"):
            for endpoint in recipients:
                owner_changed_events = collect_group_events(
                    endpoint,
                    expected_event_types={
                        GroupChangeEvent.ON_OWNER_CHANGED.value,
                        "onGroupOwnerChanged",
                    },
                    group_id=group_id,
                    required_all_event_types={"onGroupOwnerChanged"},
                    timeout=10.0,
                )
                assert_group_events(
                    assert_api,
                    owner_changed_events,
                    expected_event_types={
                        GroupChangeEvent.ON_OWNER_CHANGED.value,
                        "onGroupOwnerChanged",
                    },
                    group_id=group_id,
                    required_all_event_types={"onGroupOwnerChanged"},
                )
        with _allure_step("A 全部在线端也收到 owner 变更事件"):
            for endpoint in topology.sender_devices:
                owner_changed_a_events = collect_group_events(
                    endpoint,
                    expected_event_types={
                        GroupChangeEvent.ON_OWNER_CHANGED.value,
                        "onGroupOwnerChanged",
                    },
                    group_id=group_id,
                    required_all_event_types={"onGroupOwnerChanged"},
                    timeout=10.0,
                )
                assert_group_events(
                    assert_api,
                    owner_changed_a_events,
                    expected_event_types={
                        GroupChangeEvent.ON_OWNER_CHANGED.value,
                        "onGroupOwnerChanged",
                    },
                    group_id=group_id,
                    required_all_event_types={"onGroupOwnerChanged"},
                )

        with _allure_step("B 全部在线端查询群规格 owner 均为 B（账号级服务端状态一致）"):
            for endpoint in recipients:
                resp_get_after_owner_change = endpoint.call(
                    "GroupManager",
                    Cmd.getGroupSpecificationFromServer.value,
                    info={"groupId": group_id},
                )
                result = resp_get_after_owner_change.get("result")
                assert isinstance(result, dict), f"getGroupSpecificationFromServer result 非 dict: {resp_get_after_owner_change}"
                assert result.get("owner") == member_user, f"owner 变更后群 owner 不匹配: {resp_get_after_owner_change}"
    finally:
        if group_id:
            destroy_group(sender, assert_api, group_id, device_b=topology.recipient_action_device)
