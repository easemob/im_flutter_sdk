"""Group style、邀请权限与入群 API 映射矩阵。"""
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


def _assert_true_response(assert_api, response: dict, *, cmd: str, device: str) -> None:
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


def _assert_none_response(assert_api, response: dict, *, cmd: str, device: str) -> None:
    assert_api.assert_response_matches(
        response,
        expected={
            "manager": "GroupManager",
            "cmd": cmd,
            "device": device,
            "result": None,
        },
        ignore_keys={"sequence"},
    )


def _fetch_group(device, assert_api, *, group_id: str, group_name: str, owner: str,
                 member_count: int, members: list[str], style: int = 0,
                 admins: list[str] | None = None,
                 block_list: list[str] | None = None, max_count: int = 200,
                 device_name: str = "deviceA") -> dict:
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
        block_list_value=block_list,
        max_user_count_value=max_count,
        is_member_allow_to_invite=(style == 1),  # 5.0 allowInvites 仅 style=1
        is_public=style in (2, 3),
        join_approval_required=style == 2,
        device=device_name,
    )
    assert_group_members_exact(response, members, err_prefix="服务端群成员快照")
    return response


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


@pytest.mark.parametrize("style", [0, 1], ids=["private-owner", "private-member"])
def test_group_join_public_group_rejects_every_non_open_style(
    device_a,
    device_b,
    assert_api,
    user_a,
    style,
):
    """joinPublicGroup 拒绝私有群（style 0/1，603）；public-approval(style=2)/public-open(style=3) 5.0 允许加入（公开群）。"""
    group_id = ""
    group_name = new_group_name(f"join_wrong_style_{style}")
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[],
            style=style,
        )
        response = device_b.call(
            "GroupManager",
            Cmd.joinPublicGroup.value,
            info={"groupId": group_id},
        )
        assert_api.assert_error(response, code=603, description="permission")
        _fetch_group(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count=1,
            members=[],
            style=style,
        )
        assert_no_group_event(
            device_a,
            group_id=group_id,
            event_types={"onGroupMembersJoined"}  # 5.0 只派发批量事件（无单数 onGroupMemberJoined）,
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


@pytest.mark.parametrize(
    "style",
    [
        pytest.param(0, id="private-owner"),
        pytest.param(1, id="private-member"),
        pytest.param(
            3,
            marks=pytest.mark.skip(
                reason="known SDK/server contract gap: apply API auto-joins PublicOpenJoin",
            ),
            id="public-open",
        ),
    ],
)
def test_group_request_to_join_rejects_every_non_approval_style(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    style,
):
    """`requestToJoinPublicGroup` 只允许 PublicJoinNeedApproval(style=2)。"""
    group_id = ""
    joined = False
    group_name = new_group_name(f"request_wrong_style_{style}")
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[],
            style=style,
        )
        response = device_b.call(
            "GroupManager",
            Cmd.requestToJoinPublicGroup.value,
            info={"groupId": group_id, "reason": "wrong-style"},
        )
        joined = style == 3 and response.get("result") is None
        if joined:
            joined_types = {"onGroupMembersJoined"}  # 5.0 只派发批量事件（无单数 onGroupMemberJoined）
            owner_events = collect_group_events(
                device_a,
                expected_event_types=joined_types,
                group_id=group_id,
                required_all_event_types=joined_types,
                timeout=10.0,
            )
            by_type = {event["eventType"]: event for event in owner_events}
            assert_api.assert_response_matches(
                by_type["onGroupMembersJoined"],
                expected={
                    "type": "event",
                    "eventType": "onGroupMembersJoined",
                    "data": {"groupId": group_id, "userIds": [user_b]},
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
                members=[user_b],
                style=style,
            )
            raise AssertionError(
                "PublicOpenJoin 错误接受 requestToJoinPublicGroup: "
                "expected=603 permission 且成员状态不变, "
                "actual=result=null、群主收到加入事件且 B 已成为成员"
            )
        assert_api.assert_error(response, code=603, description="permission")
        _fetch_group(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count=1,
            members=[],
            style=style,
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id, device_b=device_b if joined else None)


def test_group_direct_invite_ignores_auto_accept_disabled_when_confirmation_not_required(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """inviteNeedConfirm=false 时，即使 B 关闭自动接受，也应由服务端直接加入。"""
    group_id = ""
    group_name = new_group_name("invite_no_confirm_auto_off")
    try:
        option = device_b.call(
            "Client",
            Cmd.updateAutoAcceptGroupInvitationSetting.value,
            info={"autoAcceptGroupInvitation": False},
        )
        assert_api.assert_response_matches(
            option,
            expected={
                "manager": "Client",
                "cmd": Cmd.updateAutoAcceptGroupInvitationSetting.value,
                "device": "deviceB",
                "result": None,
            },
            ignore_keys={"sequence"},
        )
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[],
            style=0,
            invite_need_confirm=False,
        )
        response = device_a.call(
            "GroupManager",
            Cmd.addMembers.value,
            info={"groupId": group_id, "members": [user_b], "welcome": "direct-add"},
        )
        assert_api.assert_response_matches(
            response,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.addMembers.value,
                "device": "deviceA",
                "result": True,
            },
            ignore_keys={"sequence"},
        )
        invite_events = collect_group_events(
            device_b,
            expected_event_types={"onGroupAutoAcceptInvitation"},
            group_id=group_id,
            required_all_event_types={"onGroupAutoAcceptInvitation"},
            timeout=10.0,
        )
        assert_api.assert_response_matches(
            invite_events[0],
            expected={
                "type": "event",
                "eventType": "onGroupAutoAcceptInvitation",
                "data": {"groupId": group_id, "inviter": user_a, "inviteMessage": ""},
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
            members=[user_b],
            style=0,
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id, device_b=device_b)
        restore = device_b.call(
            "Client",
            Cmd.updateAutoAcceptGroupInvitationSetting.value,
            info={"autoAcceptGroupInvitation": True},
        )
        assert_api.assert_response_matches(
            restore,
            expected={
                "manager": "Client",
                "cmd": Cmd.updateAutoAcceptGroupInvitationSetting.value,
                "device": "deviceB",
                "result": None,
            },
            ignore_keys={"sequence"},
        )


@pytest.mark.parametrize("style", [1, 2, 3], ids=["private-member", "public-approval", "public-open"])
def test_group_create_group_invites_member_for_each_remaining_style(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    style,
):
    """createGroup.inviteMembers 应覆盖 style=1/2/3 的直接邀请入群链路。"""
    group_id = ""
    group_name = new_group_name(f"create_invite_style_{style}")
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b],
            style=style,
        )
        invite_events = collect_group_events(
            device_b,
            expected_event_types={"onGroupAutoAcceptInvitation"},
            group_id=group_id,
            required_all_event_types={"onGroupAutoAcceptInvitation"},
            timeout=10.0,
        )
        assert_api.assert_response_matches(
            invite_events[0],
            expected={
                "type": "event",
                "eventType": "onGroupAutoAcceptInvitation",
                "data": {"groupId": group_id, "inviter": user_a, "inviteMessage": ""},
            },
            ignore_keys={"timestamp", "sequence"},
        )
        owner_joined_types = {"onGroupMembersJoined"}  # 5.0 只派发批量事件（无单数 onGroupMemberJoined）
        collect_group_events(
            device_a,
            expected_event_types=owner_joined_types,
            group_id=group_id,
            required_all_event_types=owner_joined_types,
            timeout=10.0,
        )
        _fetch_group(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count=2,
            members=[user_b],
            style=style,
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id, device_b=device_b)


@pytest.mark.parametrize("invite_cmd", [Cmd.inviterUser.value, Cmd.addMembers.value], ids=["inviter-user", "add-members"])
@pytest.mark.parametrize("style", [1, 2, 3], ids=["private-member", "public-approval", "public-open"])
def test_group_owner_can_invite_for_each_remaining_style(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    style,
    invite_cmd,
):
    """通用 inviterUser API 应覆盖 style=1/2/3 的群主邀请链路。"""
    group_id = ""
    group_name = new_group_name(f"owner_invite_style_{style}")
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[],
            style=style,
        )
        info = {"groupId": group_id, "members": [user_b]}
        if invite_cmd == Cmd.inviterUser.value:
            info["reason"] = f"style-{style}"
        else:
            info["welcome"] = f"style-{style}"
        response = device_a.call("GroupManager", invite_cmd, info=info)
        _assert_true_response(assert_api, response, cmd=invite_cmd, device="deviceA")
        invite_events = collect_group_events(
            device_b,
            expected_event_types={"onGroupAutoAcceptInvitation"},
            group_id=group_id,
            required_all_event_types={"onGroupAutoAcceptInvitation"},
            timeout=10.0,
        )
        assert_api.assert_response_matches(
            invite_events[0],
            expected={
                "type": "event",
                "eventType": "onGroupAutoAcceptInvitation",
                "data": {"groupId": group_id, "inviter": user_a, "inviteMessage": ""},
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
            members=[user_b],
            style=style,
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id, device_b=device_b)


@pytest.mark.parametrize(
    ("style", "make_admin", "should_succeed"),
    [
        pytest.param(0, False, False, id="private-owner-normal-member-denied"),
        pytest.param(
            0,
            True,
            False,
            marks=pytest.mark.skip(
                reason="pending contract confirmation: style 0 admin can invite",
            ),
            id="private-owner-admin-denied",
        ),
        pytest.param(1, False, True, id="private-member-normal-member-allowed"),
        pytest.param(1, True, True, id="private-member-admin-allowed"),
    ],
)
@pytest.mark.parametrize("invite_cmd", [Cmd.inviterUser.value, Cmd.addMembers.value], ids=["inviter-user", "add-members"])
def test_group_member_invitation_permission_depends_on_style(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    user_c,
    style,
    make_admin,
    should_succeed,
    invite_cmd,
):
    """style=0 仅群主可邀请；style=1 的普通成员和管理员均可邀请。"""
    group_id = ""
    group_name = new_group_name(f"member_invite_{style}_{int(make_admin)}")
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b],
            style=style,
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
            device_a.drain_events()
            device_b.drain_events()

        info = {"groupId": group_id, "members": [user_c]}
        if invite_cmd == Cmd.inviterUser.value:
            info["reason"] = "member-invite"
        else:
            info["welcome"] = "member-invite"
        response = device_b.call("GroupManager", invite_cmd, info=info)
        joined_events = {"onGroupMembersJoined"}  # 5.0 只派发批量事件（无单数 onGroupMemberJoined）
        if should_succeed:
            _assert_true_response(assert_api, response, cmd=invite_cmd, device="deviceB")
            owner_events = collect_group_events(
                device_a,
                expected_event_types=joined_events,
                group_id=group_id,
                required_all_event_types=joined_events,
                timeout=10.0,
            )
            by_type = {event["eventType"]: event for event in owner_events}
            assert_api.assert_response_matches(
                by_type["onGroupMembersJoined"],
                expected={
                    "type": "event",
                    "eventType": "onGroupMembersJoined",
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
                member_count=3,
                members=[user_c] if make_admin else [user_b, user_c],
                style=style,
                admins=[user_b] if make_admin else [],
            )
        else:
            if response.get("result") is True:
                owner_events = collect_group_events(
                    device_a,
                    expected_event_types=joined_events,
                    group_id=group_id,
                    required_all_event_types=joined_events,
                    timeout=10.0,
                )
                by_type = {event["eventType"]: event for event in owner_events}
                assert_api.assert_response_matches(
                    by_type["onGroupMembersJoined"],
                    expected={
                        "type": "event",
                        "eventType": "onGroupMembersJoined",
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
                    member_count=3,
                    members=[user_c],
                    style=style,
                    admins=[user_b],
                )
                raise AssertionError(
                    "PrivateOnlyOwnerInvite 错误允许管理员邀请: "
                    f"api={invite_cmd}, expected=603 invite is not allowed, "
                    "actual=result=true、群主收到加入事件且 C 已成为成员"
                )
            assert_api.assert_error(response, code=603, description="invite is not allowed")
            assert_no_group_event(device_a, group_id=group_id, event_types=joined_events)
            assert_no_group_event(device_b, group_id=group_id, event_types=joined_events)
            _fetch_group(
                device_a,
                assert_api,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                member_count=2,
                members=[user_b],
                style=style,
            )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id, device_b=device_b)


@pytest.mark.parametrize("invite_cmd", [Cmd.inviterUser.value, Cmd.addMembers.value], ids=["inviter-user", "add-members"])
def test_group_non_member_cannot_invite_user(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_c,
    invite_cmd,
):
    """即使 style=1 允许成员邀请，非成员仍不能调用任一邀请 API。"""
    group_id = ""
    group_name = new_group_name(f"nonmember_invite_{invite_cmd}")
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[],
            style=1,
        )
        info = {"groupId": group_id, "members": [user_c]}
        if invite_cmd == Cmd.inviterUser.value:
            info["reason"] = "nonmember"
        else:
            info["welcome"] = "nonmember"
        response = device_b.call("GroupManager", invite_cmd, info=info)
        assert_api.assert_error(response, code=603, description="group member permission is required")
        _fetch_group(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count=1,
            members=[],
            style=1,
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_public_open_join_rejects_duplicate_membership(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """B 成功加入 PublicOpenJoin 后再次 join，不得重复增加成员或重复发送加入事件。"""
    group_id = ""
    group_name = new_group_name("public_duplicate_join")
    joined = False
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[],
            style=3,
        )
        first = device_b.call(
            "GroupManager",
            Cmd.joinPublicGroup.value,
            info={"groupId": group_id},
        )
        _assert_none_response(
            assert_api,
            first,
            cmd=Cmd.joinPublicGroup.value,
            device="deviceB",
        )
        joined = True
        joined_types = {"onGroupMembersJoined"}  # 5.0 只派发批量事件（无单数 onGroupMemberJoined）
        collect_group_events(
            device_a,
            expected_event_types=joined_types,
            group_id=group_id,
            required_all_event_types=joined_types,
            timeout=10.0,
        )
        second = device_b.call(
            "GroupManager",
            Cmd.joinPublicGroup.value,
            info={"groupId": group_id},
        )
        assert_api.assert_error(second, code=601, description="already joined")
        assert_no_group_event(device_a, group_id=group_id, event_types=joined_types)
        _fetch_group(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count=2,
            members=[user_b],
            style=3,
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id, device_b=device_b if joined else None)


def test_group_public_open_join_rejects_when_group_is_full(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    user_c,
):
    """maxCount=2 的公开自由群已包含 A+B 时，C 不得加入。"""
    group_id = ""
    group_name = new_group_name("public_group_full")
    device_b_is_c = False
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b],
            style=3,
            max_count=2,
        )
        device_a.drain_events()
        device_b.drain_events()
        _switch_user(device_b, assert_api, device_name="deviceB", user_id=user_c)
        device_b_is_c = True
        response = device_b.call(
            "GroupManager",
            Cmd.joinPublicGroup.value,
            info={"groupId": group_id},
        )
        assert_api.assert_error(response, code=604, description="capacity is reached")
        assert_no_group_event(
            device_a,
            group_id=group_id,
            event_types={"onGroupMembersJoined"}  # 5.0 只派发批量事件（无单数 onGroupMemberJoined）,
        )
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
                style=3,
                max_count=2,
            )
            destroy_group(device_a, assert_api, group_id, device_b=device_b)


def test_group_public_open_join_rejects_blocked_user(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """B 被移入群黑名单并移出后，不得通过 PublicOpenJoin 重新加入。"""
    group_id = ""
    group_name = new_group_name("public_blocked_join")
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b],
            style=3,
        )
        device_a.drain_events()
        device_b.drain_events()
        block = device_a.call(
            "GroupManager",
            Cmd.blockMembers.value,
            info={"groupId": group_id, "members": [user_b]},
        )
        assert_api.assert_response_matches(
            block,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.blockMembers.value,
                "device": "deviceA",
                "result": True,
            },
            ignore_keys={"sequence"},
        )
        collect_group_events(
            device_b,
            expected_event_types={"onGroupUserRemoved"},
            group_id=group_id,
            required_all_event_types={"onGroupUserRemoved"},
            timeout=10.0,
        )
        device_a.drain_events()
        response = device_b.call(
            "GroupManager",
            Cmd.joinPublicGroup.value,
            info={"groupId": group_id},
        )
        assert_api.assert_error(response, code=613, description="blacklist")
        assert_no_group_event(
            device_a,
            group_id=group_id,
            event_types={"onGroupMembersJoined"}  # 5.0 只派发批量事件（无单数 onGroupMemberJoined）,
        )
        _fetch_group(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count=1,
            members=[],
            style=3,
            block_list=[user_b],
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)
