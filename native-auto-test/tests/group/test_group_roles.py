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


def test_group_add_admin_and_remove_admin_success(device_a, device_b, assert_api, user_a, user_b):
    group_id = ""
    group_name = new_group_name("role_admin")
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b],
        )

        resp_add_admin = device_a.call(
            "GroupManager",
            Cmd.addAdmin.value,
            info={"groupId": group_id, "admin": user_b},
        )
        assert_api.assert_response_matches(
            resp_add_admin,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.addAdmin.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )
        add_admin_result = resp_add_admin.get("result")
        assert isinstance(add_admin_result, dict), f"addAdmin result 非 dict: {resp_add_admin}"
        assert add_admin_result.get("groupId") == group_id, f"addAdmin groupId 不匹配: {resp_add_admin}"
        assert add_admin_result.get("owner") == user_a, f"addAdmin owner 不匹配: {resp_add_admin}"
        assert add_admin_result.get("memberCount") == 2, f"addAdmin memberCount 不匹配: {resp_add_admin}"
        admin_list_add = add_admin_result.get("adminList")
        assert isinstance(admin_list_add, list), f"addAdmin adminList 非 list: {resp_add_admin}"
        assert user_b in admin_list_add, f"addAdmin adminList 不包含 {user_b}: {resp_add_admin}"

        admin_added_events = collect_group_events(
            device_b,
            expected_event_types={
                GroupChangeEvent.ON_ADMIN_ADDED.value,
                "onAdminAddedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onAdminAddedFromGroup"},
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            admin_added_events,
            expected_event_types={
                GroupChangeEvent.ON_ADMIN_ADDED.value,
                "onAdminAddedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onAdminAddedFromGroup"},
            expected_member=user_b,
        )
        _assert_no_group_event(
            device_a,
            group_id=group_id,
            event_types={
                GroupChangeEvent.ON_ADMIN_ADDED.value,
                "onAdminAddedFromGroup",
            },
        )

        resp_get_admin_added = device_a.call(
            "GroupManager",
            Cmd.getGroupSpecificationFromServer.value,
            info={"groupId": group_id, "fetchMembers": True},
        )
        assert_api.assert_response_matches(
            resp_get_admin_added,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.getGroupSpecificationFromServer.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )
        result_get_admin_added = resp_get_admin_added.get("result")
        assert isinstance(result_get_admin_added, dict), f"getGroupSpecificationFromServer result 非 dict: {resp_get_admin_added}"
        assert result_get_admin_added.get("groupId") == group_id, f"groupId 不匹配: {resp_get_admin_added}"
        assert result_get_admin_added.get("owner") == user_a, f"owner 不匹配: {resp_get_admin_added}"
        assert result_get_admin_added.get("memberCount") == 2, f"memberCount 不匹配: {resp_get_admin_added}"
        admin_list = result_get_admin_added.get("adminList")
        assert isinstance(admin_list, list), f"adminList 不是 list: {resp_get_admin_added}"
        assert user_b in admin_list, f"addAdmin 后 adminList 缺少 {user_b}: {resp_get_admin_added}"

        resp_remove_admin = device_a.call(
            "GroupManager",
            Cmd.removeAdmin.value,
            info={"groupId": group_id, "admin": user_b},
        )
        assert_api.assert_response_matches(
            resp_remove_admin,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.removeAdmin.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )
        remove_admin_result = resp_remove_admin.get("result")
        assert isinstance(remove_admin_result, dict), f"removeAdmin result 非 dict: {resp_remove_admin}"
        assert remove_admin_result.get("groupId") == group_id, f"removeAdmin groupId 不匹配: {resp_remove_admin}"
        assert remove_admin_result.get("owner") == user_a, f"removeAdmin owner 不匹配: {resp_remove_admin}"
        assert remove_admin_result.get("memberCount") == 2, f"removeAdmin memberCount 不匹配: {resp_remove_admin}"
        admin_list_remove = remove_admin_result.get("adminList")
        assert isinstance(admin_list_remove, list), f"removeAdmin adminList 非 list: {resp_remove_admin}"
        assert user_b not in admin_list_remove, f"removeAdmin adminList 仍包含 {user_b}: {resp_remove_admin}"

        admin_removed_events = collect_group_events(
            device_b,
            expected_event_types={
                GroupChangeEvent.ON_ADMIN_REMOVED.value,
                "onAdminRemovedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onAdminRemovedFromGroup"},
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            admin_removed_events,
            expected_event_types={
                GroupChangeEvent.ON_ADMIN_REMOVED.value,
                "onAdminRemovedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onAdminRemovedFromGroup"},
            expected_member=user_b,
        )
        _assert_no_group_event(
            device_a,
            group_id=group_id,
            event_types={
                GroupChangeEvent.ON_ADMIN_REMOVED.value,
                "onAdminRemovedFromGroup",
            },
        )

        resp_get_admin_removed = device_a.call(
            "GroupManager",
            Cmd.getGroupSpecificationFromServer.value,
            info={"groupId": group_id, "fetchMembers": True},
        )
        admin_list_after_remove = resp_get_admin_removed.get("result", {}).get("adminList")
        assert isinstance(admin_list_after_remove, list), f"adminList 不是 list: {resp_get_admin_removed}"
        assert user_b not in admin_list_after_remove, (
            f"removeAdmin 后 adminList 仍包含 {user_b}: {resp_get_admin_removed}"
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_update_owner_success(device_a, device_b, assert_api, user_a, user_b):
    group_id = ""
    group_name = new_group_name("role_owner")
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b],
        )

        resp_update_owner = device_a.call(
            "GroupManager",
            Cmd.updateGroupOwner.value,
            info={"groupId": group_id, "owner": user_b},
        )
        assert_api.assert_response_matches(
            resp_update_owner,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.updateGroupOwner.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )
        owner_result = resp_update_owner.get("result")
        assert isinstance(owner_result, dict), f"updateGroupOwner result 非 dict: {resp_update_owner}"
        assert owner_result.get("groupId") == group_id, f"updateGroupOwner groupId 不匹配: {resp_update_owner}"
        assert owner_result.get("owner") == user_b, f"updateGroupOwner owner 不匹配: {resp_update_owner}"
        assert owner_result.get("memberCount") == 2, f"updateGroupOwner memberCount 不匹配: {resp_update_owner}"
        assert owner_result.get("isMemberOnly") is True, f"updateGroupOwner isMemberOnly 不匹配: {resp_update_owner}"

        owner_changed_events = collect_group_events(
            device_b,
            expected_event_types={
                GroupChangeEvent.ON_OWNER_CHANGED.value,
                "onOwnerChangedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onOwnerChangedFromGroup"},
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            owner_changed_events,
            expected_event_types={
                GroupChangeEvent.ON_OWNER_CHANGED.value,
                "onOwnerChangedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onOwnerChangedFromGroup"},
        )
        owner_changed_a_events = collect_group_events(
            device_a,
            expected_event_types={
                GroupChangeEvent.ON_OWNER_CHANGED.value,
                "onOwnerChangedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onOwnerChangedFromGroup"},
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            owner_changed_a_events,
            expected_event_types={
                GroupChangeEvent.ON_OWNER_CHANGED.value,
                "onOwnerChangedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onOwnerChangedFromGroup"},
        )

        resp_get_after_owner_change = device_b.call(
            "GroupManager",
            Cmd.getGroupSpecificationFromServer.value,
            info={"groupId": group_id, "fetchMembers": True},
        )
        result = resp_get_after_owner_change.get("result")
        assert isinstance(result, dict), f"getGroupSpecificationFromServer result 非 dict: {resp_get_after_owner_change}"
        assert result.get("owner") == user_b, f"群主未切换为新群主: {resp_get_after_owner_change}"
        resp_owner_back = device_b.call(
            "GroupManager",
            Cmd.updateGroupOwner.value,
            info={"groupId": group_id, "owner": user_a},
        )
        assert_api.assert_response_matches(
            resp_owner_back,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.updateGroupOwner.value,
                "device": "deviceB",
            },
            ignore_keys={"sequence", "result"},
        )
        owner_back_result = resp_owner_back.get("result")
        assert isinstance(owner_back_result, dict), f"owner 回切 result 非 dict: {resp_owner_back}"
        assert owner_back_result.get("groupId") == group_id, f"owner 回切 groupId 不匹配: {resp_owner_back}"
        assert owner_back_result.get("owner") == user_a, f"owner 回切 owner 不匹配: {resp_owner_back}"
        assert owner_back_result.get("memberCount") == 2, f"owner 回切 memberCount 不匹配: {resp_owner_back}"
        assert owner_back_result.get("isMemberOnly") is True, f"owner 回切 isMemberOnly 不匹配: {resp_owner_back}"

        owner_back_a_events = collect_group_events(
            device_a,
            expected_event_types={
                GroupChangeEvent.ON_OWNER_CHANGED.value,
                "onOwnerChangedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onOwnerChangedFromGroup"},
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            owner_back_a_events,
            expected_event_types={
                GroupChangeEvent.ON_OWNER_CHANGED.value,
                "onOwnerChangedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onOwnerChangedFromGroup"},
        )
        owner_back_b_events = collect_group_events(
            device_b,
            expected_event_types={
                GroupChangeEvent.ON_OWNER_CHANGED.value,
                "onOwnerChangedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onOwnerChangedFromGroup"},
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            owner_back_b_events,
            expected_event_types={
                GroupChangeEvent.ON_OWNER_CHANGED.value,
                "onOwnerChangedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onOwnerChangedFromGroup"},
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)
