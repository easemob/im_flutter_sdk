"""Group 群主转让、权限迁移与成员移除矩阵。"""
from __future__ import annotations

import pytest

from src import Cmd
from tests.group.group_helpers import (
    assert_group_members_exact,
    assert_group_snapshot,
    assert_no_group_event,
    collect_group_events,
    create_group,
    destroy_group,
    new_group_name,
)


pytestmark = [pytest.mark.client, pytest.mark.group]


def _fetch_group(
    device,
    assert_api,
    *,
    group_id: str,
    group_name: str,
    owner: str,
    member_count: int,
    members: list[str],
    admins: list[str] | None = None,
    device_name: str,
) -> dict:
    response = device.call(
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
        owner=owner,
        member_count_value=member_count,
        admin_list_value=admins,
        device=device_name,
    )
    assert_group_members_exact(response, members, err_prefix="群主/成员服务端快照")
    return response


def _assert_true(assert_api, response: dict, *, cmd: str, device: str) -> None:
    assert_api.assert_response_matches(
        response,
        expected={
            "manager": "GroupManager",
            "cmd": cmd,
            "device": device,
            "result": True,
        },
        ignore_keys={"sequence"},
    )


def _assert_owner_changed(assert_api, event: dict, *, group_id: str,
                          new_owner: str, old_owner: str) -> None:
    assert_api.assert_response_matches(
        event,
        expected={
            "type": "event",
            "eventType": "onOwnerChangedFromGroup",
            "data": {
                "groupId": group_id,
                "newOwner": new_owner,
                "oldOwner": old_owner,
            },
        },
        ignore_keys={"timestamp", "sequence"},
    )


def _switch_user(device, assert_api, *, device_name: str, user_id: str) -> None:
    logout = device.call("Client", Cmd.logout.value, info={"unbindToken": False})
    assert_api.assert_response_matches(
        logout,
        expected={
            "manager": "Client",
            "cmd": Cmd.logout.value,
            "device": device_name,
            "result": True,
        },
        ignore_keys={"sequence"},
    )
    login = device.call(
        "Client",
        Cmd.login.value,
        info={"userId": user_id, "pwdOrToken": "1", "isPassword": True},
    )
    assert_api.assert_response_matches(
        login,
        expected={
            "manager": "Client",
            "cmd": Cmd.login.value,
            "device": device_name,
            "result": user_id,
        },
        ignore_keys={"sequence"},
    )
    callback = device.call("Client", Cmd.startCallback.value, info={})
    assert_api.assert_response_matches(
        callback,
        expected={
            "manager": "Client",
            "cmd": Cmd.startCallback.value,
            "device": device_name,
            "result": None,
        },
        ignore_keys={"sequence"},
    )
    device.drain_events()


def test_group_transfer_owner_to_admin_normalizes_roles(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """A 将群主转让给管理员 B 后，B 成为 owner，A 成为普通成员，adminList 清空。"""
    group_id = ""
    group_name = new_group_name("owner_to_admin")
    owner_is_b = False
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b],
        )
        device_a.drain_events()
        device_b.drain_events()
        add_admin = device_a.call(
            "GroupManager",
            Cmd.addAdmin.value,
            info={"groupId": group_id, "admin": user_b},
        )
        assert isinstance(add_admin.get("result"), dict), add_admin
        device_a.drain_events()
        device_b.drain_events()

        response = device_a.call(
            "GroupManager",
            Cmd.updateGroupOwner.value,
            info={"groupId": group_id, "owner": user_b},
        )
        result = response.get("result")
        assert isinstance(result, dict), response
        assert result.get("owner") == user_b, response
        assert result.get("adminList") == [], response
        owner_is_b = True

        events_a = collect_group_events(
            device_a,
            expected_event_types={"onOwnerChangedFromGroup"},
            group_id=group_id,
            required_all_event_types={"onOwnerChangedFromGroup"},
            timeout=10.0,
        )
        events_b = collect_group_events(
            device_b,
            expected_event_types={"onOwnerChangedFromGroup"},
            group_id=group_id,
            required_all_event_types={"onOwnerChangedFromGroup"},
            timeout=10.0,
        )
        _assert_owner_changed(assert_api, events_a[0], group_id=group_id,
                              new_owner=user_b, old_owner=user_a)
        _assert_owner_changed(assert_api, events_b[0], group_id=group_id,
                              new_owner=user_b, old_owner=user_a)
        _fetch_group(
            device_b,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_b,
            member_count=2,
            members=[user_a],
            admins=[],
            device_name="deviceB",
        )
    finally:
        if group_id:
            destroy_group(device_b if owner_is_b else device_a, assert_api, group_id,
                          device_b=device_a if owner_is_b else device_b,
                          device_name="deviceB" if owner_is_b else "deviceA")


@pytest.mark.parametrize(
    ("target_kind", "expected_code"),
    [
        pytest.param("current-owner", None, id="current-owner-idempotent"),
        pytest.param("non-member", 603, id="non-member"),
        pytest.param("nonexistent", 603, id="nonexistent"),
        pytest.param("empty", 600, id="empty"),
    ],
)
def test_group_transfer_owner_target_boundaries(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    user_c,
    target_kind,
    expected_code,
):
    """转让给当前 owner 幂等成功；其他无效目标返回稳定错误且 owner 不变。"""
    group_id = ""
    group_name = new_group_name(f"owner_invalid_{target_kind}")
    target = {
        "current-owner": user_a,
        "non-member": user_c,
        "nonexistent": "nonexistent_user_999999",
        "empty": "",
    }[target_kind]
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b],
        )
        device_a.drain_events()
        device_b.drain_events()
        response = device_a.call(
            "GroupManager",
            Cmd.updateGroupOwner.value,
            info={"groupId": group_id, "owner": target},
        )
        if expected_code is None:
            result = response.get("result")
            assert isinstance(result, dict), response
            assert result.get("owner") == user_a, response
        else:
            assert_api.assert_error(response, code=expected_code)
        _fetch_group(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count=2,
            members=[user_b],
            device_name="deviceA",
        )
        assert_no_group_event(
            device_b,
            group_id=group_id,
            event_types={"onOwnerChangedFromGroup"},
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id, device_b=device_b)


@pytest.mark.parametrize("make_admin", [False, True], ids=["member", "admin"])
def test_group_non_owner_cannot_transfer_ownership(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    user_c,
    make_admin,
):
    """普通成员和管理员都不能调用 owner-only 的 updateGroupOwner。"""
    group_id = ""
    group_name = new_group_name(f"owner_unauthorized_{int(make_admin)}")
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b, user_c],
        )
        device_a.drain_events()
        device_b.drain_events()
        if make_admin:
            add_admin = device_a.call(
                "GroupManager",
                Cmd.addAdmin.value,
                info={"groupId": group_id, "admin": user_b},
            )
            assert isinstance(add_admin.get("result"), dict), add_admin
            device_b.drain_events()
        response = device_b.call(
            "GroupManager",
            Cmd.updateGroupOwner.value,
            info={"groupId": group_id, "owner": user_c},
        )
        assert_api.assert_error(response, code=603, description="permission")
        _fetch_group(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count=3,
            members=[user_c] if make_admin else [user_b, user_c],
            admins=[user_b] if make_admin else [],
            device_name="deviceA",
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id, device_b=device_b)


def test_group_non_member_cannot_transfer_ownership(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    user_c,
):
    """非成员 C 不能把 A 的群转让给成员 B。"""
    group_id = ""
    group_name = new_group_name("owner_nonmember_operator")
    device_b_is_c = False
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b],
        )
        device_a.drain_events()
        device_b.drain_events()
        _switch_user(device_b, assert_api, device_name="deviceB", user_id=user_c)
        device_b_is_c = True
        response = device_b.call(
            "GroupManager",
            Cmd.updateGroupOwner.value,
            info={"groupId": group_id, "owner": user_b},
        )
        assert_api.assert_error(response, code=603, description="group member permission is required")
    finally:
        if device_b_is_c:
            _switch_user(device_b, assert_api, device_name="deviceB", user_id=user_b)
        if group_id:
            _fetch_group(
                device_a,
                assert_api,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                member_count=2,
                members=[user_b],
                device_name="deviceA",
            )
            destroy_group(device_a, assert_api, group_id, device_b=device_b)


def test_group_transfer_then_new_owner_removes_former_owner(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """A 转让给 B 后，A 失去 owner 权限，B 可以将原群主 A 移出群。"""
    group_id = ""
    group_name = new_group_name("remove_former_owner")
    owner_is_b = False
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b],
        )
        device_a.drain_events()
        device_b.drain_events()
        transfer = device_a.call(
            "GroupManager",
            Cmd.updateGroupOwner.value,
            info={"groupId": group_id, "owner": user_b},
        )
        assert isinstance(transfer.get("result"), dict), transfer
        assert transfer["result"].get("owner") == user_b, transfer
        owner_is_b = True
        collect_group_events(
            device_a,
            expected_event_types={"onOwnerChangedFromGroup"},
            group_id=group_id,
            required_all_event_types={"onOwnerChangedFromGroup"},
            timeout=10.0,
        )
        collect_group_events(
            device_b,
            expected_event_types={"onOwnerChangedFromGroup"},
            group_id=group_id,
            required_all_event_types={"onOwnerChangedFromGroup"},
            timeout=10.0,
        )

        former_owner_attempt = device_a.call(
            "GroupManager",
            Cmd.removeMembers.value,
            info={"groupId": group_id, "members": [user_b]},
        )
        assert_api.assert_error(former_owner_attempt, code=603, description="permission")

        remove = device_b.call(
            "GroupManager",
            Cmd.removeMembers.value,
            info={"groupId": group_id, "members": [user_a]},
        )
        _assert_true(assert_api, remove, cmd=Cmd.removeMembers.value, device="deviceB")
        removed_events = collect_group_events(
            device_a,
            expected_event_types={"onUserRemovedFromGroup"},
            group_id=group_id,
            required_all_event_types={"onUserRemovedFromGroup"},
            timeout=10.0,
        )
        assert_api.assert_response_matches(
            removed_events[0],
            expected={
                "type": "event",
                "eventType": "onUserRemovedFromGroup",
                "data": {"groupId": group_id, "groupName": group_name},
            },
            ignore_keys={"timestamp", "sequence"},
        )
        _fetch_group(
            device_b,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_b,
            member_count=1,
            members=[],
            device_name="deviceB",
        )
    finally:
        if group_id and owner_is_b:
            destroy_group(device_b, assert_api, group_id, device_name="deviceB")
        elif group_id:
            destroy_group(device_a, assert_api, group_id, device_b=device_b)


def test_group_remove_current_owner_is_ignored(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """removeMembers 单独传当前群主时返回成功，但 owner 和成员状态不变。"""
    group_id = ""
    group_name = new_group_name("remove_current_owner")
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b],
        )
        device_a.drain_events()
        device_b.drain_events()
        response = device_a.call(
            "GroupManager",
            Cmd.removeMembers.value,
            info={"groupId": group_id, "members": [user_a]},
        )
        _assert_true(assert_api, response, cmd=Cmd.removeMembers.value, device="deviceA")
        _fetch_group(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count=2,
            members=[user_b],
            device_name="deviceA",
        )
        assert_no_group_event(
            device_b,
            group_id=group_id,
            event_types={"onUserRemovedFromGroup", "onMembersExitedFromGroup", "onMemberExitedFromGroup"},
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id, device_b=device_b)


def test_group_owner_removes_admin_success(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """管理员仍是可由群主移除的群成员。"""
    group_id = ""
    group_name = new_group_name("remove_admin_member")
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b],
        )
        device_a.drain_events()
        device_b.drain_events()
        add_admin = device_a.call(
            "GroupManager",
            Cmd.addAdmin.value,
            info={"groupId": group_id, "admin": user_b},
        )
        assert isinstance(add_admin.get("result"), dict), add_admin
        device_a.drain_events()
        device_b.drain_events()
        response = device_a.call(
            "GroupManager",
            Cmd.removeMembers.value,
            info={"groupId": group_id, "members": [user_b]},
        )
        _assert_true(assert_api, response, cmd=Cmd.removeMembers.value, device="deviceA")
        removed_events = collect_group_events(
            device_b,
            expected_event_types={"onUserRemovedFromGroup"},
            group_id=group_id,
            required_all_event_types={"onUserRemovedFromGroup"},
            timeout=10.0,
        )
        assert_api.assert_response_matches(
            removed_events[0],
            expected={
                "type": "event",
                "eventType": "onUserRemovedFromGroup",
                "data": {"groupId": group_id, "groupName": group_name},
            },
            ignore_keys={"timestamp", "sequence"},
        )
        _fetch_group(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count=1,
            members=[],
            admins=[],
            device_name="deviceA",
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


@pytest.mark.parametrize("make_admin", [False, True], ids=["member", "admin"])
def test_group_remove_other_member_permission_by_role(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    user_c,
    make_admin,
):
    """普通成员无权移除其他成员，管理员按原生真实权限可以移除普通成员。"""
    group_id = ""
    group_name = new_group_name(f"remove_unauthorized_{int(make_admin)}")
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b, user_c],
        )
        device_a.drain_events()
        device_b.drain_events()
        if make_admin:
            add_admin = device_a.call(
                "GroupManager",
                Cmd.addAdmin.value,
                info={"groupId": group_id, "admin": user_b},
            )
            assert isinstance(add_admin.get("result"), dict), add_admin
            device_b.drain_events()
        response = device_b.call(
            "GroupManager",
            Cmd.removeMembers.value,
            info={"groupId": group_id, "members": [user_c]},
        )
        if make_admin:
            _assert_true(assert_api, response, cmd=Cmd.removeMembers.value, device="deviceB")
            joined_event_types = {"onMembersExitedFromGroup", "onMemberExitedFromGroup"}
            owner_events = collect_group_events(
                device_a,
                expected_event_types=joined_event_types,
                group_id=group_id,
                required_all_event_types=joined_event_types,
                timeout=10.0,
            )
            admin_events = collect_group_events(
                device_b,
                expected_event_types=joined_event_types,
                group_id=group_id,
                required_all_event_types=joined_event_types,
                timeout=10.0,
            )
            for events in (owner_events, admin_events):
                by_type = {event["eventType"]: event for event in events}
                assert_api.assert_response_matches(
                    by_type["onMembersExitedFromGroup"],
                    expected={
                        "type": "event",
                        "eventType": "onMembersExitedFromGroup",
                        "data": {"groupId": group_id, "userIds": [user_c]},
                    },
                    ignore_keys={"timestamp", "sequence"},
                )
            _fetch_group(
                device_a,
                assert_api,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                member_count=2,
                members=[],
                admins=[user_b],
                device_name="deviceA",
            )
        else:
            assert_api.assert_error(response, code=603, description="permission")
            _fetch_group(
                device_a,
                assert_api,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                member_count=3,
                members=[user_b, user_c],
                admins=[],
                device_name="deviceA",
            )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id, device_b=device_b)


def test_group_owner_must_transfer_before_leaving(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """当前群主不能退群；转让给 B 后，原群主 A 可以正常退出。"""
    group_id = ""
    group_name = new_group_name("owner_leave_after_transfer")
    owner_is_b = False
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b],
        )
        device_a.drain_events()
        device_b.drain_events()
        owner_leave = device_a.call(
            "GroupManager",
            Cmd.leaveGroup.value,
            info={"groupId": group_id},
        )
        assert_api.assert_error(owner_leave, code=603)
        transfer = device_a.call(
            "GroupManager",
            Cmd.updateGroupOwner.value,
            info={"groupId": group_id, "owner": user_b},
        )
        assert isinstance(transfer.get("result"), dict), transfer
        owner_is_b = True
        collect_group_events(
            device_a,
            expected_event_types={"onOwnerChangedFromGroup"},
            group_id=group_id,
            required_all_event_types={"onOwnerChangedFromGroup"},
            timeout=10.0,
        )
        collect_group_events(
            device_b,
            expected_event_types={"onOwnerChangedFromGroup"},
            group_id=group_id,
            required_all_event_types={"onOwnerChangedFromGroup"},
            timeout=10.0,
        )
        former_owner_leave = device_a.call(
            "GroupManager",
            Cmd.leaveGroup.value,
            info={"groupId": group_id},
        )
        _assert_true(assert_api, former_owner_leave, cmd=Cmd.leaveGroup.value, device="deviceA")
        exited_events = collect_group_events(
            device_b,
            expected_event_types={"onMembersExitedFromGroup", "onMemberExitedFromGroup"},
            group_id=group_id,
            required_all_event_types={"onMembersExitedFromGroup", "onMemberExitedFromGroup"},
            timeout=10.0,
        )
        by_type = {event["eventType"]: event for event in exited_events}
        assert_api.assert_response_matches(
            by_type["onMembersExitedFromGroup"],
            expected={
                "type": "event",
                "eventType": "onMembersExitedFromGroup",
                "data": {"groupId": group_id, "userIds": [user_a]},
            },
            ignore_keys={"timestamp", "sequence"},
        )
        _fetch_group(
            device_b,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_b,
            member_count=1,
            members=[],
            device_name="deviceB",
        )
    finally:
        if group_id and owner_is_b:
            destroy_group(device_b, assert_api, group_id, device_name="deviceB")
        elif group_id:
            destroy_group(device_a, assert_api, group_id, device_b=device_b)


def test_group_batch_remove_ignores_owner_and_non_member_but_removes_valid_member(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    user_c,
):
    """混合批量请求返回成功，只移除有效普通成员并忽略 owner 与非成员。"""
    group_id = ""
    group_name = new_group_name("remove_mixed_owner")
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b],
        )
        device_a.drain_events()
        device_b.drain_events()
        response = device_a.call(
            "GroupManager",
            Cmd.removeMembers.value,
            info={"groupId": group_id, "members": [user_a, user_b, user_c]},
        )
        _assert_true(assert_api, response, cmd=Cmd.removeMembers.value, device="deviceA")
        removed_events = collect_group_events(
            device_b,
            expected_event_types={"onUserRemovedFromGroup"},
            group_id=group_id,
            required_all_event_types={"onUserRemovedFromGroup"},
            timeout=10.0,
        )
        assert_api.assert_response_matches(
            removed_events[0],
            expected={
                "type": "event",
                "eventType": "onUserRemovedFromGroup",
                "data": {"groupId": group_id, "groupName": group_name},
            },
            ignore_keys={"timestamp", "sequence"},
        )
        _fetch_group(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count=1,
            members=[],
            device_name="deviceA",
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)
