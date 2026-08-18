"""两设备三账号覆盖群主、管理员、普通成员的群组权限矩阵。"""
from __future__ import annotations

import pytest

from src import Cmd
from tests.group.group_helpers import (
    assert_group_members_exact,
    assert_group_snapshot,
    collect_group_events,
    create_group,
    destroy_group,
    new_group_name,
)


pytestmark = [pytest.mark.client, pytest.mark.group]


_ROLE_OWNER = "owner"
_ROLE_ADMIN = "admin"
_ROLE_MEMBER = "member"
_PERMISSION_TYPE = {
    _ROLE_OWNER: 2,
    _ROLE_ADMIN: 1,
    _ROLE_MEMBER: 0,
}
_ADMIN_PERMISSION_ERROR = "you have no permission to do this, group admin permission is required"
_GROUP_FIELDS_PERMISSION_ERROR = (
    "you have no permission to do this,group fields require group admin privileges to be modified"
)
_OWNER_PERMISSION_ERROR = "you have no permission to do this, group owner permission is required"


def _assert_call(assert_api, response: dict, *, manager: str, cmd: str, device: str, result) -> None:
    assert_api.assert_response_matches(
        response,
        expected={
            "manager": manager,
            "cmd": cmd,
            "device": device,
            "result": result,
        },
        ignore_keys={"sequence"},
    )


def _assert_event(assert_api, event: dict, *, event_type: str, data: dict, ignore_keys: set[str] | None = None) -> None:
    assert_api.assert_response_matches(
        event,
        expected={"type": "event", "eventType": event_type, "data": data},
        ignore_keys={"timestamp", "sequence", *(ignore_keys or set())},
    )


def _switch_user(device, assert_api, *, device_name: str, user_id: str) -> None:
    logout = device.call("Client", Cmd.logout.value, info={"unbindToken": False})
    _assert_call(
        assert_api,
        logout,
        manager="Client",
        cmd=Cmd.logout.value,
        device=device_name,
        result=True,
    )
    login = device.call(
        "Client",
        Cmd.login.value,
        info={"userId": user_id, "pwdOrToken": "1", "isPassword": True},
    )
    _assert_call(
        assert_api,
        login,
        manager="Client",
        cmd=Cmd.login.value,
        device=device_name,
        result=user_id,
    )
    callback = device.call("Client", Cmd.startCallback.value, info={})
    _assert_call(
        assert_api,
        callback,
        manager="Client",
        cmd=Cmd.startCallback.value,
        device=device_name,
        result=None,
    )
    device.drain_events()


def _add_admin(
    device_a,
    assert_api,
    *,
    group_id: str,
    group_name: str,
    owner: str,
    admin: str,
) -> None:
    response = device_a.call(
        "GroupManager",
        Cmd.addAdmin.value,
        info={"groupId": group_id, "admin": admin},
    )
    assert_group_snapshot(
        assert_api,
        response,
        cmd=Cmd.addAdmin.value,
        group_id=group_id,
        group_name=group_name,
        owner=owner,
        member_count_value=3,
        admin_list_value=[admin],
        permission_type=2,
    )


def _fetch_group(
    device,
    assert_api,
    *,
    device_name: str,
    group_id: str,
    group_name: str,
    owner: str,
    members: list[str],
    admins: list[str],
    permission_type: int,
    mute_list: list[str] | None = None,
    allow_list: list[str] | None = None,
    block_list: list[str] | None = None,
    is_all_member_muted: bool = False,
    message_blocked: bool = False,
    expected_desc: str = "auto-test group",
    expected_ext: str = "auto-ext",
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
        expected_desc=expected_desc,
        expected_ext=expected_ext,
        member_count_value=1 + len(members) + len(admins),
        admin_list_value=admins,
        mute_list_value=mute_list,
        allow_list_value=allow_list,
        block_list_value=block_list,
        is_all_member_muted=is_all_member_muted,
        message_blocked=message_blocked,
        permission_type=permission_type,
        device=device_name,
    )
    assert_group_members_exact(response, members, err_prefix="角色权限矩阵服务端快照")
    return response


def _assert_server_user_list(
    device,
    assert_api,
    *,
    device_name: str,
    cmd: str,
    group_id: str,
    expected_users: list[str],
) -> None:
    response = device.call("GroupManager", cmd, info={"groupId": group_id})
    _assert_call(
        assert_api,
        response,
        manager="GroupManager",
        cmd=cmd,
        device=device_name,
        result=expected_users,
    )


def _create_role_group(
    device_a,
    device_b,
    assert_api,
    *,
    role: str,
    user_a: str,
    user_b: str,
    user_c: str,
    prefix: str,
) -> tuple[str, str]:
    group_name = new_group_name(f"role_{prefix}_{role}")
    group_id, _ = create_group(
        device_a,
        assert_api,
        owner=user_a,
        group_name=group_name,
        invite_members=[user_b, user_c],
        invite_need_confirm=False,
    )
    if role == _ROLE_ADMIN:
        _add_admin(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            admin=user_b,
        )
    device_a.drain_events()
    device_b.drain_events()
    return group_id, group_name


def _actor_and_target(
    device_a,
    device_b,
    assert_api,
    *,
    role: str,
    user_a: str,
    user_b: str,
    user_c: str,
):
    if role == _ROLE_OWNER:
        return device_a, "deviceA", device_b, user_b, False
    if role == _ROLE_ADMIN:
        _switch_user(device_a, assert_api, device_name="deviceA", user_id=user_c)
        return device_b, "deviceB", device_a, user_c, True
    return device_b, "deviceB", None, user_c, False


def _restore_owner_if_needed(device_a, assert_api, *, switched: bool, user_a: str) -> None:
    if switched:
        _switch_user(device_a, assert_api, device_name="deviceA", user_id=user_a)


@pytest.mark.parametrize("role", [_ROLE_OWNER, _ROLE_ADMIN, _ROLE_MEMBER])
def test_group_mute_members_role_permission_matrix(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    user_c,
    role,
):
    """群主/管理员可禁言与解除禁言；普通成员被拒绝且状态不变。"""
    group_id = ""
    switched = False
    group_name = ""
    try:
        group_id, group_name = _create_role_group(
            device_a,
            device_b,
            assert_api,
            role=role,
            user_a=user_a,
            user_b=user_b,
            user_c=user_c,
            prefix="mute",
        )
        actor, actor_name, target_device, target_user, switched = _actor_and_target(
            device_a,
            device_b,
            assert_api,
            role=role,
            user_a=user_a,
            user_b=user_b,
            user_c=user_c,
        )
        response = actor.call(
            "GroupManager",
            Cmd.muteMembers.value,
            info={"groupId": group_id, "members": [target_user], "duration": 60_000},
        )
        if role == _ROLE_MEMBER:
            assert_api.assert_error(response, code=603, description=_ADMIN_PERMISSION_ERROR)
        else:
            assert_group_snapshot(
                assert_api,
                response,
                cmd=Cmd.muteMembers.value,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                member_count_value=3,
                admin_list_value=[user_b] if role == _ROLE_ADMIN else [],
                mute_list_value=[target_user],
                permission_type=_PERMISSION_TYPE[role],
                device=actor_name,
            )
            event_type = "onMuteListAddedFromGroup"
            events = collect_group_events(
                target_device,
                expected_event_types={event_type},
                group_id=group_id,
                required_all_event_types={event_type},
                timeout=10.0,
            )
            _assert_event(
                assert_api,
                events[0],
                event_type=event_type,
                data={"groupId": group_id, "mutes": [target_user]},
                ignore_keys={"muteExpire"},
            )
            mute_expire = (events[0].get("data") or {}).get("muteExpire")
            assert isinstance(mute_expire, int) and mute_expire > 0, f"禁言回调 muteExpire 非有效时间: {events[0]}"

            response = actor.call(
                "GroupManager",
                Cmd.unMuteMembers.value,
                info={"groupId": group_id, "members": [target_user]},
            )
            assert_group_snapshot(
                assert_api,
                response,
                cmd=Cmd.unMuteMembers.value,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                member_count_value=3,
                admin_list_value=[user_b] if role == _ROLE_ADMIN else [],
                mute_list_value=[],
                permission_type=_PERMISSION_TYPE[role],
                device=actor_name,
            )
            event_type = "onMuteListRemovedFromGroup"
            events = collect_group_events(
                target_device,
                expected_event_types={event_type},
                group_id=group_id,
                required_all_event_types={event_type},
                timeout=10.0,
            )
            _assert_event(
                assert_api,
                events[0],
                event_type=event_type,
                data={"groupId": group_id, "mutes": [target_user]},
            )
        _restore_owner_if_needed(device_a, assert_api, switched=switched, user_a=user_a)
        switched = False
        _fetch_group(
            device_a,
            assert_api,
            device_name="deviceA",
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            members=[user_c] if role == _ROLE_ADMIN else [user_b, user_c],
            admins=[user_b] if role == _ROLE_ADMIN else [],
            permission_type=2,
            mute_list=[],
        )
    finally:
        _restore_owner_if_needed(device_a, assert_api, switched=switched, user_a=user_a)
        if group_id:
            destroy_group(device_a, assert_api, group_id)


@pytest.mark.parametrize("role", [_ROLE_OWNER, _ROLE_ADMIN, _ROLE_MEMBER])
def test_group_mute_all_role_permission_matrix(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    user_c,
    role,
):
    """群主/管理员可切换全员禁言；普通成员被拒绝且状态不变。"""
    group_id = ""
    switched = False
    group_name = ""
    try:
        group_id, group_name = _create_role_group(
            device_a,
            device_b,
            assert_api,
            role=role,
            user_a=user_a,
            user_b=user_b,
            user_c=user_c,
            prefix="mute_all",
        )
        actor, actor_name, observer, _, switched = _actor_and_target(
            device_a,
            device_b,
            assert_api,
            role=role,
            user_a=user_a,
            user_b=user_b,
            user_c=user_c,
        )
        response = actor.call("GroupManager", Cmd.muteAllMembers.value, info={"groupId": group_id})
        if role == _ROLE_MEMBER:
            assert_api.assert_error(response, code=603, description=_ADMIN_PERMISSION_ERROR)
        else:
            assert_group_snapshot(
                assert_api,
                response,
                cmd=Cmd.muteAllMembers.value,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                member_count_value=3,
                admin_list_value=[user_b] if role == _ROLE_ADMIN else [],
                is_all_member_muted=True,
                permission_type=_PERMISSION_TYPE[role],
                device=actor_name,
            )
            event_type = "onAllGroupMemberMuteStateChanged"
            events = collect_group_events(
                observer,
                expected_event_types={event_type},
                group_id=group_id,
                required_all_event_types={event_type},
                timeout=10.0,
            )
            _assert_event(
                assert_api,
                events[0],
                event_type=event_type,
                data={"groupId": group_id, "isAllMuted": True},
            )
            response = actor.call("GroupManager", Cmd.unMuteAllMembers.value, info={"groupId": group_id})
            assert_group_snapshot(
                assert_api,
                response,
                cmd=Cmd.unMuteAllMembers.value,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                member_count_value=3,
                admin_list_value=[user_b] if role == _ROLE_ADMIN else [],
                is_all_member_muted=False,
                permission_type=_PERMISSION_TYPE[role],
                device=actor_name,
            )
            events = collect_group_events(
                observer,
                expected_event_types={event_type},
                group_id=group_id,
                required_all_event_types={event_type},
                timeout=10.0,
            )
            _assert_event(
                assert_api,
                events[0],
                event_type=event_type,
                data={"groupId": group_id, "isAllMuted": False},
            )
        _restore_owner_if_needed(device_a, assert_api, switched=switched, user_a=user_a)
        switched = False
        _fetch_group(
            device_a,
            assert_api,
            device_name="deviceA",
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            members=[user_c] if role == _ROLE_ADMIN else [user_b, user_c],
            admins=[user_b] if role == _ROLE_ADMIN else [],
            permission_type=2,
            is_all_member_muted=False,
        )
    finally:
        _restore_owner_if_needed(device_a, assert_api, switched=switched, user_a=user_a)
        if group_id:
            destroy_group(device_a, assert_api, group_id)


@pytest.mark.parametrize("role", [_ROLE_OWNER, _ROLE_ADMIN, _ROLE_MEMBER])
def test_group_allow_list_role_permission_matrix(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    user_c,
    role,
):
    """群主/管理员可增删白名单；普通成员被拒绝且白名单保持为空。"""
    group_id = ""
    switched = False
    group_name = ""
    try:
        group_id, group_name = _create_role_group(
            device_a,
            device_b,
            assert_api,
            role=role,
            user_a=user_a,
            user_b=user_b,
            user_c=user_c,
            prefix="allow",
        )
        actor, actor_name, target_device, target_user, switched = _actor_and_target(
            device_a,
            device_b,
            assert_api,
            role=role,
            user_a=user_a,
            user_b=user_b,
            user_c=user_c,
        )
        response = actor.call(
            "GroupManager",
            Cmd.addWhiteList.value,
            info={"groupId": group_id, "members": [target_user]},
        )
        if role == _ROLE_MEMBER:
            assert_api.assert_error(response, code=603, description=_ADMIN_PERMISSION_ERROR)
        else:
            _assert_call(
                assert_api,
                response,
                manager="GroupManager",
                cmd=Cmd.addWhiteList.value,
                device=actor_name,
                result=True,
            )
            event_type = "onAllowListAddedFromGroup"
            events = collect_group_events(
                target_device,
                expected_event_types={event_type},
                group_id=group_id,
                required_all_event_types={event_type},
                timeout=10.0,
            )
            _assert_event(
                assert_api,
                events[0],
                event_type=event_type,
                data={"groupId": group_id, "members": [target_user]},
            )
            target_device_name = "deviceB" if role == _ROLE_OWNER else "deviceA"
            response = target_device.call(
                "GroupManager",
                Cmd.isMemberInWhiteListFromServer.value,
                info={"groupId": group_id},
            )
            _assert_call(
                assert_api,
                response,
                manager="GroupManager",
                cmd=Cmd.isMemberInWhiteListFromServer.value,
                device=target_device_name,
                # 当前 Android SDK 在移除回调后仍稳定返回 true，按真实返回冻结。
                result=True,
            )
            response = actor.call(
                "GroupManager",
                Cmd.removeWhiteList.value,
                info={"groupId": group_id, "members": [target_user]},
            )
            _assert_call(
                assert_api,
                response,
                manager="GroupManager",
                cmd=Cmd.removeWhiteList.value,
                device=actor_name,
                result=True,
            )
            event_type = "onAllowListRemovedFromGroup"
            events = collect_group_events(
                target_device,
                expected_event_types={event_type},
                group_id=group_id,
                required_all_event_types={event_type},
                timeout=10.0,
            )
            _assert_event(
                assert_api,
                events[0],
                event_type=event_type,
                data={"groupId": group_id, "members": [target_user]},
            )
        _restore_owner_if_needed(device_a, assert_api, switched=switched, user_a=user_a)
        switched = False
        _fetch_group(
            device_a,
            assert_api,
            device_name="deviceA",
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            members=[user_c] if role == _ROLE_ADMIN else [user_b, user_c],
            admins=[user_b] if role == _ROLE_ADMIN else [],
            permission_type=2,
        )
    finally:
        _restore_owner_if_needed(device_a, assert_api, switched=switched, user_a=user_a)
        if group_id:
            destroy_group(device_a, assert_api, group_id)


@pytest.mark.parametrize("role", [_ROLE_ADMIN, _ROLE_MEMBER])
def test_group_blocklist_admin_member_role_matrix(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    user_c,
    role,
):
    """管理员可增删群黑名单；普通成员返回管理员权限错误且状态不变。"""
    group_id = ""
    group_name = ""
    try:
        group_id, group_name = _create_role_group(
            device_a,
            device_b,
            assert_api,
            role=role,
            user_a=user_a,
            user_b=user_b,
            user_c=user_c,
            prefix="blocklist",
        )
        response = device_b.call(
            "GroupManager",
            Cmd.blockMembers.value,
            info={"groupId": group_id, "members": [user_c]},
        )
        if role == _ROLE_MEMBER:
            assert_api.assert_error(response, code=603, description=_ADMIN_PERMISSION_ERROR)
            _fetch_group(
                device_a,
                assert_api,
                device_name="deviceA",
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                members=[user_b, user_c],
                admins=[],
                permission_type=2,
                block_list=[],
            )
        else:
            _assert_call(
                assert_api,
                response,
                manager="GroupManager",
                cmd=Cmd.blockMembers.value,
                device="deviceB",
                result=True,
            )
            event_types = {"onMembersExitedFromGroup", "onMemberExitedFromGroup"}
            events = collect_group_events(
                device_a,
                expected_event_types=event_types,
                group_id=group_id,
                required_all_event_types=event_types,
                timeout=10.0,
            )
            events_by_type = {event["eventType"]: event for event in events}
            _assert_event(
                assert_api,
                events_by_type["onMembersExitedFromGroup"],
                event_type="onMembersExitedFromGroup",
                data={"groupId": group_id, "userIds": [user_c]},
            )
            _assert_event(
                assert_api,
                events_by_type["onMemberExitedFromGroup"],
                event_type="onMemberExitedFromGroup",
                data={"groupId": group_id, "member": user_c},
            )
            _assert_server_user_list(
                device_b,
                assert_api,
                device_name="deviceB",
                cmd=Cmd.getGroupBlockListFromServer.value,
                group_id=group_id,
                expected_users=[user_c],
            )
            response = device_b.call(
                "GroupManager",
                Cmd.unblockMembers.value,
                info={"groupId": group_id, "members": [user_c]},
            )
            _assert_call(
                assert_api,
                response,
                manager="GroupManager",
                cmd=Cmd.unblockMembers.value,
                device="deviceB",
                result=True,
            )
            _assert_server_user_list(
                device_b,
                assert_api,
                device_name="deviceB",
                cmd=Cmd.getGroupBlockListFromServer.value,
                group_id=group_id,
                expected_users=[],
            )
            _fetch_group(
                device_a,
                assert_api,
                device_name="deviceA",
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                members=[],
                admins=[user_b],
                permission_type=2,
                block_list=[],
            )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


@pytest.mark.parametrize("role", [_ROLE_ADMIN, _ROLE_MEMBER])
def test_group_metadata_admin_member_role_matrix(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    user_c,
    role,
):
    """管理员可修改群名称、描述、扩展；普通成员返回群字段权限错误。"""
    group_id = ""
    group_name = ""
    try:
        group_id, group_name = _create_role_group(
            device_a,
            device_b,
            assert_api,
            role=role,
            user_a=user_a,
            user_b=user_b,
            user_c=user_c,
            prefix="metadata",
        )
        calls = [
            (Cmd.updateGroupSubject.value, {"groupId": group_id, "subject": "denied-name"}),
            (Cmd.updateDescription.value, {"groupId": group_id, "description": "denied-desc"}),
            (Cmd.updateGroupExt.value, {"groupId": group_id, "ext": "denied-ext"}),
        ]
        if role == _ROLE_MEMBER:
            for cmd, info in calls:
                response = device_b.call("GroupManager", cmd, info=info)
                assert_api.assert_error(response, code=603, description=_GROUP_FIELDS_PERMISSION_ERROR)
            _fetch_group(
                device_a,
                assert_api,
                device_name="deviceA",
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                members=[user_b, user_c],
                admins=[],
                permission_type=2,
            )
        else:
            for cmd, info in calls:
                response = device_b.call("GroupManager", cmd, info=info)
                if cmd in {Cmd.updateGroupSubject.value, Cmd.updateDescription.value}:
                    _assert_call(
                        assert_api,
                        response,
                        manager="GroupManager",
                        cmd=cmd,
                        device="deviceB",
                        result=None,
                    )
                else:
                    assert_group_snapshot(
                        assert_api,
                        response,
                        cmd=cmd,
                        group_id=group_id,
                        group_name="",
                        owner=user_a,
                        expected_desc="",
                        expected_ext="denied-ext",
                        member_count_value=3,
                        admin_list_value=[user_b],
                        permission_type=1,
                        device="deviceB",
                    )
                events = collect_group_events(
                    device_a,
                    expected_event_types={"onSpecificationDidUpdate"},
                    group_id=group_id,
                    allow_missing_group_id=True,
                    required_all_event_types={"onSpecificationDidUpdate"},
                    timeout=10.0,
                )
                expected_desc = "auto-test group" if cmd == Cmd.updateGroupSubject.value else ""
                _assert_event(
                    assert_api,
                    events[0],
                    event_type="onSpecificationDidUpdate",
                    data={
                        "group": {
                            "groupId": group_id,
                            "name": "",
                            "avatarUrl": "",
                            "desc": expected_desc,
                            "owner": user_a,
                            "announcement": "",
                            "memberCount": 3,
                            "messageBlocked": False,
                            "isDisabled": False,
                            "isAllMemberMuted": False,
                            "permissionType": 2,
                        }
                    },
                    ignore_keys={"memberList", "adminList"},
                )
            _fetch_group(
                device_a,
                assert_api,
                device_name="deviceA",
                group_id=group_id,
                group_name="",
                owner=user_a,
                members=[user_c],
                admins=[user_b],
                permission_type=2,
                expected_desc="",
                expected_ext="denied-ext",
            )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


@pytest.mark.parametrize("role", [_ROLE_ADMIN, _ROLE_MEMBER])
def test_group_destroy_owner_only_role_denied(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    user_c,
    role,
):
    """管理员和普通成员不能解散群，失败后群仍可由群主查询和清理。"""
    group_id = ""
    group_name = ""
    try:
        group_id, group_name = _create_role_group(
            device_a,
            device_b,
            assert_api,
            role=role,
            user_a=user_a,
            user_b=user_b,
            user_c=user_c,
            prefix="destroy",
        )
        response = device_b.call("GroupManager", Cmd.destroyGroup.value, info={"groupId": group_id})
        assert_api.assert_error(response, code=603, description=_OWNER_PERMISSION_ERROR)
        _fetch_group(
            device_a,
            assert_api,
            device_name="deviceA",
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            members=[user_c] if role == _ROLE_ADMIN else [user_b, user_c],
            admins=[user_b] if role == _ROLE_ADMIN else [],
            permission_type=2,
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


@pytest.mark.parametrize("role", [_ROLE_OWNER, _ROLE_ADMIN, _ROLE_MEMBER])
def test_group_message_block_role_matrix(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    user_c,
    role,
):
    """冻结三种群角色屏蔽/取消屏蔽群消息的真实 SDK 行为。"""
    group_id = ""
    group_name = ""
    try:
        group_id, group_name = _create_role_group(
            device_a,
            device_b,
            assert_api,
            role=role,
            user_a=user_a,
            user_b=user_b,
            user_c=user_c,
            prefix="message_block",
        )
        actor = device_a if role == _ROLE_OWNER else device_b
        actor_name = "deviceA" if role == _ROLE_OWNER else "deviceB"
        response = actor.call("GroupManager", Cmd.blockGroup.value, info={"groupId": group_id})
        _assert_call(
            assert_api,
            response,
            manager="GroupManager",
            cmd=Cmd.blockGroup.value,
            device=actor_name,
            result=None,
        )
        _fetch_group(
            actor,
            assert_api,
            device_name=actor_name,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            members=[user_c] if role == _ROLE_ADMIN else [user_b, user_c],
            admins=[user_b] if role == _ROLE_ADMIN else [],
            permission_type=_PERMISSION_TYPE[role],
            message_blocked=True,
        )
        response = actor.call("GroupManager", Cmd.unblockGroup.value, info={"groupId": group_id})
        _assert_call(
            assert_api,
            response,
            manager="GroupManager",
            cmd=Cmd.unblockGroup.value,
            device=actor_name,
            result=None,
        )
        _fetch_group(
            actor,
            assert_api,
            device_name=actor_name,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            members=[user_c] if role == _ROLE_ADMIN else [user_b, user_c],
            admins=[user_b] if role == _ROLE_ADMIN else [],
            permission_type=_PERMISSION_TYPE[role],
            message_blocked=False,
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)
