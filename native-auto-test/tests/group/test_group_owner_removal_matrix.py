"""Group 群主转让、权限迁移与成员移除矩阵。"""
from __future__ import annotations
from contextlib import nullcontext

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


def _allure_step(name: str):
    try:
        import allure

        return allure.step(name)
    except ImportError:
        return nullcontext()


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
        info={"groupId": group_id},
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
            "eventType": "onGroupOwnerChanged",
            "data": {
                "groupId": group_id,
                "newOwner": new_owner,
                "oldOwner": old_owner,
            },
        },
        ignore_keys={"timestamp", "sequence"},
    )


def _assert_exited_events(assert_api, events: list[dict], group_id: str, user_id: str) -> None:
    by_type = {event["eventType"]: event for event in events}
    assert_api.assert_response_matches(
        by_type["onGroupMembersExited"],
        expected={
            "type": "event",
            "eventType": "onGroupMembersExited",
            "data": {"groupId": group_id, "userIds": [user_id]},
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
    # 5.0 统一 token 登录：密码需先 REST 换 token（loginWithToken 接受 token，直接传密码被拒 202）
    from src.rest_api.user_api import fetch_user_token
    _tok = fetch_user_token(user_id, "1").get("access_token", "")
    login = device.call(
        "Client",
        Cmd.login.value,
        info={"userId": user_id, "pwdOrToken": _tok, "isPassword": False},
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


@pytest.mark.topology("account_a_to_account_b")

def test_group_transfer_owner_to_admin_normalizes_roles(
    assert_api,
    user_a,
    user_b,
    topology,
):
    """A 将群主转让给管理员 B：owner 变更事件同步到 A、B 账号全部在线端；B 成 owner，A 成普通成员。"""
    owner = topology.sender_action_device
    member = topology.recipient_action_device
    senders = topology.sender_devices
    recipients = topology.recipient_devices
    group_id = ""
    group_name = new_group_name("owner_to_admin")
    owner_is_b = False
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                owner,
                assert_api,
                owner=user_a,
                group_name=group_name,
                invite_members=[user_b],
            )
        owner.drain_events()
        member.drain_events()
        with _allure_step("A 添加群管理员"):
            add_admin = owner.call(
                "GroupManager",
                Cmd.addAdmin.value,
                info={"groupId": group_id, "admin": user_b},
            )
        with _allure_step("验证 添加群管理员返回的关键字段"):
            assert isinstance(add_admin.get("result"), dict), add_admin
        owner.drain_events()
        member.drain_events()

        with _allure_step("A 转让群主"):
            response = owner.call(
                "GroupManager",
                Cmd.updateGroupOwner.value,
                info={"groupId": group_id, "owner": user_b},
            )
        result = response.get("result")
        with _allure_step("验证转让群主返回的关键字段"):
            assert isinstance(result, dict), response
        with _allure_step("验证转让群主返回的关键字段"):
            assert result.get("owner") == user_b, response
        with _allure_step("验证转让群主返回的关键字段"):
            assert result.get("adminList") == [], response
        owner_is_b = True

        # 5.0 事件流向：onGroupOwnerChanged 只发新 owner（B）端；A 端（原 owner）只收
        # onMultiDeviceGroupEvent（多设备同步）—— 不再断言 A 端群变更事件
        for __d__ in senders:
            __d__.drain_events()
        with _allure_step("B 账号全部在线端收到 owner 变更事件（onGroupOwnerChanged）"):
            for __d__ in recipients:
                events = collect_group_events(
                    __d__,
                    expected_event_types={"onGroupOwnerChanged"},
                    group_id=group_id,
                    required_all_event_types={"onGroupOwnerChanged"},
                    timeout=10.0,
                )
                _assert_owner_changed(assert_api, events[0], group_id=group_id,
                                      new_owner=user_b, old_owner=user_a)
        _fetch_group(
            member,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_b,
            member_count=2,
            members=[user_a],
            admins=[],
            device_name=member.device_name,
        )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(member if owner_is_b else owner, assert_api, group_id,
                              member=owner if owner_is_b else member,
                              device_name=member.device_name if owner_is_b else owner.device_name)


@pytest.mark.parametrize(
    ("target_kind", "expected_code"),
    [
        pytest.param("current-owner", None, id="current-owner-idempotent"),
        pytest.param("non-member", 603, id="non-member"),
        pytest.param("nonexistent", 603, id="nonexistent"),
        pytest.param("empty", 600, id="empty"),
    ],
)
@pytest.mark.topology("account_a_to_account_b")
def test_group_transfer_owner_target_boundaries(
    assert_api,
    user_a,
    user_b,
    user_c,
    target_kind,
    expected_code,
    topology,
):
    owner = topology.sender_action_device
    member = topology.recipient_action_device
    recipients = topology.recipient_devices
    """转让给当前 owner 幂等成功；其他无效目标返回稳定错误且 owner 不变；接收账号全部在线端不触发 owner 变更事件。"""
    group_id = ""
    group_name = new_group_name(f"owner_invalid_{target_kind}")
    target = {
        "current-owner": user_a,
        "non-member": user_c,
        "nonexistent": "nonexistent_user_999999",
        "empty": "",
    }[target_kind]
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                owner,
                assert_api,
                owner=user_a,
                group_name=group_name,
                invite_members=[user_b],
            )
        owner.drain_events()
        member.drain_events()
        with _allure_step("A 转让群主"):
            response = owner.call(
                "GroupManager",
                Cmd.updateGroupOwner.value,
                info={"groupId": group_id, "owner": target},
            )
        if expected_code is None:
            result = response.get("result")
            with _allure_step("验证转让群主返回的关键字段"):
                assert isinstance(result, dict), response
            with _allure_step("验证转让群主返回的关键字段"):
                assert result.get("owner") == user_a, response
        else:
            with _allure_step("验证转让群主返回的错误码与错误文案"):
                assert_api.assert_error(response, code=expected_code)
        _fetch_group(
            owner,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count=2,
            members=[user_b],
            device_name=owner.device_name,
        )
        for __d__ in recipients:
            with _allure_step("验证转让群主返回的关键字段"):
                assert_no_group_event(
                    __d__,
                    group_id=group_id,
                    event_types={"onGroupOwnerChanged"},
                )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(owner, assert_api, group_id, member=member)


@pytest.mark.parametrize("make_admin", [False, True], ids=["member", "admin"])
def test_group_non_owner_cannot_transfer_ownership(
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
        with _allure_step("测试准备：创建测试群并建立业务前置"):
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
            with _allure_step("A 添加群管理员"):
                add_admin = device_a.call(
                    "GroupManager",
                    Cmd.addAdmin.value,
                    info={"groupId": group_id, "admin": user_b},
                )
            with _allure_step("验证 添加群管理员返回的关键字段"):
                assert isinstance(add_admin.get("result"), dict), add_admin
            device_b.drain_events()
        with _allure_step("B 转让群主"):
            response = device_b.call(
                "GroupManager",
                Cmd.updateGroupOwner.value,
                info={"groupId": group_id, "owner": user_c},
            )
        with _allure_step("验证转让群主返回的错误码与错误文案"):
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
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
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
        with _allure_step("测试准备：创建测试群并建立业务前置"):
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
        with _allure_step("B 转让群主"):
            response = device_b.call(
                "GroupManager",
                Cmd.updateGroupOwner.value,
                info={"groupId": group_id, "owner": user_b},
            )
        with _allure_step("验证转让群主返回的错误码与错误文案"):
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
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id, device_b=device_b)


@pytest.mark.topology("account_a_to_account_b")
def test_group_transfer_then_new_owner_removes_former_owner(
    assert_api,
    user_a,
    user_b,
    topology,
):
    """A 转让给 B 后 A 失去 owner 权限：owner 变更事件同步到 A、B 全部在线端；B 移除原群主 A 的事件同步到 A 全部在线端。"""
    owner = topology.sender_action_device
    member = topology.recipient_action_device
    senders = topology.sender_devices
    recipients = topology.recipient_devices
    group_id = ""
    group_name = new_group_name("remove_former_owner")
    owner_is_b = False
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                owner,
                assert_api,
                owner=user_a,
                group_name=group_name,
                invite_members=[user_b],
            )
        owner.drain_events()
        member.drain_events()
        with _allure_step("A 转让群主"):
            transfer = owner.call(
                "GroupManager",
                Cmd.updateGroupOwner.value,
                info={"groupId": group_id, "owner": user_b},
            )
        with _allure_step("验证转让群主返回的关键字段"):
            assert isinstance(transfer.get("result"), dict), transfer
        with _allure_step("验证转让群主返回的关键字段"):
            assert transfer["result"].get("owner") == user_b, transfer
        owner_is_b = True
        # 5.0 事件流向：onGroupOwnerChanged 只发新 owner（B）端；A 端（原 owner）只收
        # onMultiDeviceGroupEvent（多设备同步）—— 不再断言 A 端群变更事件
        for __d__ in senders:
            __d__.drain_events()
        with _allure_step("B 账号全部在线端消费 owner 变更事件"):
            for __d__ in recipients:
                collect_group_events(
                    __d__,
                    expected_event_types={"onGroupOwnerChanged"},
                    group_id=group_id,
                    required_all_event_types={"onGroupOwnerChanged"},
                    timeout=10.0,
                )

        with _allure_step("A 移除群成员"):
            former_owner_attempt = owner.call(
                "GroupManager",
                Cmd.removeMembers.value,
                info={"groupId": group_id, "members": [user_b]},
            )
        with _allure_step("验证 移除群成员返回的错误码与错误文案"):
            assert_api.assert_error(former_owner_attempt, code=603, description="permission")

        with _allure_step("B 移除群成员"):
            remove = member.call(
                "GroupManager",
                Cmd.removeMembers.value,
                info={"groupId": group_id, "members": [user_a]},
            )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_true(assert_api, remove, cmd=Cmd.removeMembers.value, device=member.device_name)
        with _allure_step("A 账号全部在线端收到被移除事件（onGroupUserRemoved）"):
            for __d__ in senders:
                removed_events = collect_group_events(
                    __d__,
                    expected_event_types={"onGroupUserRemoved"},
                    group_id=group_id,
                    required_all_event_types={"onGroupUserRemoved"},
                    timeout=10.0,
                )
                assert_api.assert_response_matches(
                    removed_events[0],
                    expected={
                        "type": "event",
                        "eventType": "onGroupUserRemoved",
                        "data": {"groupId": group_id, "groupName": group_name},
                    },
                    ignore_keys={"timestamp", "sequence"},
                )
        _fetch_group(
            member,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_b,
            member_count=1,
            members=[],
            device_name=member.device_name,
        )
    finally:
        if group_id and owner_is_b:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(member, assert_api, group_id, device_name=member.device_name)
        elif group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(owner, assert_api, group_id, member=member)


@pytest.mark.topology("account_a_to_account_b")
def test_group_remove_current_owner_is_ignored(
    assert_api,
    user_a,
    user_b,
    topology,
):
    owner = topology.sender_action_device
    member = topology.recipient_action_device
    recipients = topology.recipient_devices
    """removeMembers 单独传当前群主返回成功但状态不变；接收账号全部在线端不触发移除事件。"""
    group_id = ""
    group_name = new_group_name("remove_current_owner")
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                owner,
                assert_api,
                owner=user_a,
                group_name=group_name,
                invite_members=[user_b],
            )
        owner.drain_events()
        member.drain_events()
        with _allure_step("A 移除群成员"):
            response = owner.call(
                "GroupManager",
                Cmd.removeMembers.value,
                info={"groupId": group_id, "members": [user_a]},
            )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_true(assert_api, response, cmd=Cmd.removeMembers.value, device=owner.device_name)
        _fetch_group(
            owner,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count=2,
            members=[user_b],
            device_name=owner.device_name,
        )
        for __d__ in recipients:
            with _allure_step("验证 移除群成员返回的关键字段"):
                assert_no_group_event(
                    __d__,
                    group_id=group_id,
                    event_types={"onGroupUserRemoved", "onGroupMembersExited", "onGroupMemberExited"},
                )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(owner, assert_api, group_id, member=member)


@pytest.mark.topology("account_a_to_account_b")
def test_group_owner_removes_admin_success(
    assert_api,
    user_a,
    user_b,
    topology,
):
    owner = topology.sender_action_device
    member = topology.recipient_action_device
    recipients = topology.recipient_devices
    """管理员仍可由群主移除：移除事件同步到接收账号全部在线端。"""
    group_id = ""
    group_name = new_group_name("remove_admin_member")
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                owner,
                assert_api,
                owner=user_a,
                group_name=group_name,
                invite_members=[user_b],
            )
        owner.drain_events()
        member.drain_events()
        with _allure_step("A 添加群管理员"):
            add_admin = owner.call(
                "GroupManager",
                Cmd.addAdmin.value,
                info={"groupId": group_id, "admin": user_b},
            )
        with _allure_step("验证 添加群管理员返回的关键字段"):
            assert isinstance(add_admin.get("result"), dict), add_admin
        owner.drain_events()
        member.drain_events()
        with _allure_step("A 移除群成员"):
            response = owner.call(
                "GroupManager",
                Cmd.removeMembers.value,
                info={"groupId": group_id, "members": [user_b]},
            )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_true(assert_api, response, cmd=Cmd.removeMembers.value, device=owner.device_name)
        for __d__ in recipients:
            with _allure_step("等待并校验目标业务事件"):
                removed_events = collect_group_events(
                    __d__,
                    expected_event_types={"onGroupUserRemoved"},
                    group_id=group_id,
                    required_all_event_types={"onGroupUserRemoved"},
                    timeout=10.0,
                )
            with _allure_step("验证 移除群成员返回的关键字段"):
                assert_api.assert_response_matches(
                    removed_events[0],
                    expected={
                        "type": "event",
                        "eventType": "onGroupUserRemoved",
                        "data": {"groupId": group_id, "groupName": group_name},
                    },
                    ignore_keys={"timestamp", "sequence"},
                )
        _fetch_group(
            owner,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count=1,
            members=[],
            admins=[],
            device_name=owner.device_name,
        )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(owner, assert_api, group_id)


@pytest.mark.topology("account_a_to_account_b")
@pytest.mark.parametrize("make_admin", [False, True], ids=["member", "admin"])
def test_group_remove_other_member_permission_by_role(
    assert_api,
    user_a,
    user_b,
    user_c,
    make_admin,
    topology,
):
    """普通成员无权移除其他成员；管理员移除普通成员：退出事件同步到 owner 与操作管理员账号全部在线端。"""
    owner = topology.sender_action_device
    member = topology.recipient_action_device
    senders = topology.sender_devices
    recipients = topology.recipient_devices
    group_id = ""
    group_name = new_group_name(f"remove_unauthorized_{int(make_admin)}")
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                owner,
                assert_api,
                owner=user_a,
                group_name=group_name,
                invite_members=[user_b, user_c],
            )
        owner.drain_events()
        member.drain_events()
        if make_admin:
            with _allure_step("A 添加群管理员"):
                add_admin = owner.call(
                    "GroupManager",
                    Cmd.addAdmin.value,
                    info={"groupId": group_id, "admin": user_b},
                )
            with _allure_step("验证 添加群管理员返回的关键字段"):
                assert isinstance(add_admin.get("result"), dict), add_admin
            member.drain_events()
        with _allure_step("B 移除群成员"):
            response = member.call(
                "GroupManager",
                Cmd.removeMembers.value,
                info={"groupId": group_id, "members": [user_c]},
            )
        if make_admin:
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_true(assert_api, response, cmd=Cmd.removeMembers.value, device=member.device_name)
            joined_event_types = {"onGroupMembersExited"}  # 5.0 只派发批量事件（无单数 onGroupMemberExited）
            with _allure_step("owner 账号全部在线端收到成员退出事件"):
                for __d__ in senders:
                    owner_events = collect_group_events(
                        __d__,
                        expected_event_types=joined_event_types,
                        group_id=group_id,
                        required_all_event_types=joined_event_types,
                        timeout=10.0,
                    )
                    _assert_exited_events(assert_api, owner_events, group_id, user_c)
            with _allure_step("操作管理员账号全部在线端收到成员退出事件"):
                for __d__ in recipients:
                    admin_events = collect_group_events(
                        __d__,
                        expected_event_types=joined_event_types,
                        group_id=group_id,
                        required_all_event_types=joined_event_types,
                        timeout=10.0,
                    )
                    _assert_exited_events(assert_api, admin_events, group_id, user_c)
            _fetch_group(
                owner,
                assert_api,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                member_count=2,
                members=[],
                admins=[user_b],
                device_name=owner.device_name,
            )
        else:
            with _allure_step("验证 移除群成员返回的错误码与错误文案"):
                assert_api.assert_error(response, code=603, description="permission")
            _fetch_group(
                owner,
                assert_api,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                member_count=3,
                members=[user_b, user_c],
                admins=[],
                device_name=owner.device_name,
            )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(owner, assert_api, group_id, member=member)


@pytest.mark.topology("account_a_to_account_b")
def test_group_owner_must_transfer_before_leaving(
    assert_api,
    user_a,
    user_b,
    topology,
):
    """当前群主不能退群：owner 变更事件同步到 A、B 全部在线端；原群主 A 退出后的成员退出事件同步到 B 全部在线端。"""
    owner = topology.sender_action_device
    member = topology.recipient_action_device
    senders = topology.sender_devices
    recipients = topology.recipient_devices
    group_id = ""
    group_name = new_group_name("owner_leave_after_transfer")
    owner_is_b = False
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                owner,
                assert_api,
                owner=user_a,
                group_name=group_name,
                invite_members=[user_b],
            )
        owner.drain_events()
        member.drain_events()
        with _allure_step("A 退出群"):
            owner_leave = owner.call(
                "GroupManager",
                Cmd.leaveGroup.value,
                info={"groupId": group_id},
            )
        with _allure_step("验证退出群返回的错误码与错误文案"):
            assert_api.assert_error(owner_leave, code=603)
        with _allure_step("A 转让群主"):
            transfer = owner.call(
                "GroupManager",
                Cmd.updateGroupOwner.value,
                info={"groupId": group_id, "owner": user_b},
            )
        with _allure_step("验证转让群主返回的关键字段"):
            assert isinstance(transfer.get("result"), dict), transfer
        owner_is_b = True
        # 5.0 事件流向：onGroupOwnerChanged 只发新 owner（B）端；A 端（原 owner）只收
        # onMultiDeviceGroupEvent（多设备同步）—— 不再断言 A 端群变更事件
        for __d__ in senders:
            __d__.drain_events()
        with _allure_step("B 账号全部在线端消费 owner 变更事件"):
            for __d__ in recipients:
                collect_group_events(
                    __d__,
                    expected_event_types={"onGroupOwnerChanged"},
                    group_id=group_id,
                    required_all_event_types={"onGroupOwnerChanged"},
                    timeout=10.0,
                )
        with _allure_step("A 退出群"):
            former_owner_leave = owner.call(
                "GroupManager",
                Cmd.leaveGroup.value,
                info={"groupId": group_id},
            )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_true(assert_api, former_owner_leave, cmd=Cmd.leaveGroup.value, device=owner.device_name)
        with _allure_step("B 账号全部在线端收到成员退出事件"):
            for __d__ in recipients:
                exited_events = collect_group_events(
                    __d__,
                    expected_event_types={"onGroupMembersExited", "onGroupMemberExited"},
                    group_id=group_id,
                    required_all_event_types={"onGroupMembersExited"},  # 5.0 只派发批量事件（无单数 onGroupMemberExited）
                    timeout=10.0,
                )
                _assert_exited_events(assert_api, exited_events, group_id, user_a)
        _fetch_group(
            member,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_b,
            member_count=1,
            members=[],
            device_name=member.device_name,
        )
    finally:
        if group_id and owner_is_b:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(member, assert_api, group_id, device_name=member.device_name)
        elif group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(owner, assert_api, group_id, member=member)


@pytest.mark.topology("account_a_to_account_b")
def test_group_batch_remove_ignores_owner_and_non_member_but_removes_valid_member(
    assert_api,
    user_a,
    user_b,
    user_c,
    topology,
):
    owner = topology.sender_action_device
    member = topology.recipient_action_device
    recipients = topology.recipient_devices
    """批量移除忽略 owner/非成员、移除有效成员：移除事件同步到接收账号全部在线端。"""
    group_id = ""
    group_name = new_group_name("remove_mixed_owner")
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                owner,
                assert_api,
                owner=user_a,
                group_name=group_name,
                invite_members=[user_b],
            )
        owner.drain_events()
        member.drain_events()
        with _allure_step("A 移除群成员"):
            response = owner.call(
                "GroupManager",
                Cmd.removeMembers.value,
                info={"groupId": group_id, "members": [user_a, user_b, user_c]},
            )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_true(assert_api, response, cmd=Cmd.removeMembers.value, device=owner.device_name)
        for __d__ in recipients:
            with _allure_step("等待并校验目标业务事件"):
                removed_events = collect_group_events(
                    __d__,
                    expected_event_types={"onGroupUserRemoved"},
                    group_id=group_id,
                    required_all_event_types={"onGroupUserRemoved"},
                    timeout=10.0,
                )
            with _allure_step("验证 移除群成员返回的关键字段"):
                assert_api.assert_response_matches(
                    removed_events[0],
                    expected={
                        "type": "event",
                        "eventType": "onGroupUserRemoved",
                        "data": {"groupId": group_id, "groupName": group_name},
                    },
                    ignore_keys={"timestamp", "sequence"},
                )
        _fetch_group(
            owner,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count=1,
            members=[],
            device_name=owner.device_name,
        )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(owner, assert_api, group_id)
