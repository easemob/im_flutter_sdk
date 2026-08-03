"""Group 入群申请与邀请处理（正常 + 异常）。"""
from __future__ import annotations

import pytest

from src import Cmd, GroupChangeEvent
from tests.group.group_helpers import (
    assert_group_events,
    assert_no_group_event,
    assert_group_snapshot,
    collect_group_events,
    create_group,
    destroy_group,
    new_group_name,
)


pytestmark = [pytest.mark.client, pytest.mark.group]


_NONEXISTENT_GROUP_ID = "nonexistent_group_999999"
_NONEXISTENT_USER = "nonexistent_user_999999"


def _assert_exact_group_event(assert_api, event: dict, *, event_type: str, data: dict) -> None:
    assert_api.assert_response_matches(
        event,
        expected={"type": "event", "eventType": event_type, "data": data},
        ignore_keys={"timestamp", "sequence"},
    )


def test_group_invitation_explicit_accept_when_auto_accept_disabled(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """
    前置：A/B 已登录；B 的自动接受邀请基线为 true。
    步骤：
    1. B 将 autoAcceptGroupInvitation 切为 false。
    2. A 创建 inviteNeedConfirm=true 的私有群并邀请 B。
    3. B 收到待处理邀请后显式调用 acceptInvitationFromGroup。
    4. A 接收邀请被接受事件，随后从服务端核验 B 已入群。
    预期与断言：创建时 B 尚未入群；接受响应返回目标群；A/B 的事件类型与字段按真实 ADB
    日志收紧；最终 memberCount=2 且成员列表包含 B；无论结果如何都恢复 B 的自动接受开关。
    """
    group_id = ""
    accepted = False
    try:
        resp_option = device_b.call(
            "Client",
            Cmd.updateAutoAcceptGroupInvitationSetting.value,
            info={"autoAcceptGroupInvitation": False},
        )
        assert_api.assert_response_matches(
            resp_option,
            expected={
                "manager": "Client",
                "cmd": Cmd.updateAutoAcceptGroupInvitationSetting.value,
                "device": "deviceB",
                "result": None,
            },
            ignore_keys={"sequence"},
        )

        group_name = new_group_name("invite_explicit_accept")
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b],
            invite_need_confirm=True,
            expected_member_count=1,
        )

        invitation_events = collect_group_events(
            device_b,
            expected_event_types={
                GroupChangeEvent.ON_INVITATION_RECEIVED.value,
                "onGroupInvitationReceived",
            },
            group_id=group_id,
            required_all_event_types={"onGroupInvitationReceived"},
            timeout=10.0,
        )
        _assert_exact_group_event(
            assert_api,
            invitation_events[0],
            event_type="onGroupInvitationReceived",
            data={
                "groupId": group_id,
                "groupName": group_name,
                "inviter": user_a,
                "reason": "",
            },
        )

        resp_accept = device_b.call(
            "GroupManager",
            Cmd.acceptInvitationFromGroup.value,
            info={"groupId": group_id, "inviter": user_a},
        )
        assert_group_snapshot(
            assert_api,
            resp_accept,
            cmd=Cmd.acceptInvitationFromGroup.value,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count_value=2,
            permission_type=0,
            device="deviceB",
        )
        accepted = True

        accepted_event_types = {
            "onGroupInvitationAccepted",
            "onGroupMembersJoined",
            "onGroupMemberJoined",
        }
        accepted_events = collect_group_events(
            device_a,
            expected_event_types=accepted_event_types,
            group_id=group_id,
            required_all_event_types=accepted_event_types,
            timeout=10.0,
        )
        accepted_by_type = {event["eventType"]: event for event in accepted_events}
        _assert_exact_group_event(
            assert_api,
            accepted_by_type["onGroupInvitationAccepted"],
            event_type="onGroupInvitationAccepted",
            data={"groupId": group_id, "invitee": user_b, "reason": ""},
        )
        _assert_exact_group_event(
            assert_api,
            accepted_by_type["onGroupMembersJoined"],
            event_type="onGroupMembersJoined",
            data={"groupId": group_id, "userIds": [user_b]},
        )
        _assert_exact_group_event(
            assert_api,
            accepted_by_type["onGroupMemberJoined"],
            event_type="onGroupMemberJoined",
            data={"groupId": group_id, "member": user_b},
        )
        assert_no_group_event(
            device_b,
            group_id=group_id,
            event_types=accepted_event_types,
        )

        resp_server = device_a.call(
            "GroupManager",
            Cmd.getGroupSpecificationFromServer.value,
            info={"groupId": group_id},
        )
        assert_group_snapshot(
            assert_api,
            resp_server,
            cmd=Cmd.getGroupSpecificationFromServer.value,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count_value=2,
            member_list_value=[user_b],
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id, device_b=device_b if accepted else None)
        resp_restore = device_b.call(
            "Client",
            Cmd.updateAutoAcceptGroupInvitationSetting.value,
            info={"autoAcceptGroupInvitation": True},
        )
        assert_api.assert_response_matches(
            resp_restore,
            expected={
                "manager": "Client",
                "cmd": Cmd.updateAutoAcceptGroupInvitationSetting.value,
                "device": "deviceB",
                "result": None,
            },
            ignore_keys={"sequence"},
        )


@pytest.mark.skip(
    reason="known Android adapter bug: declineInvitationFromGroup drops inviter",
)
def test_group_invitation_explicit_decline_when_auto_accept_disabled(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """
    前置：A/B 已登录；B 的自动接受邀请基线为 true。
    步骤：
    1. B 将 autoAcceptGroupInvitation 切为 false。
    2. A 创建 inviteNeedConfirm=true 的私有群并邀请 B。
    3. B 收到待处理邀请后显式调用 declineInvitationFromGroup 并传拒绝原因。
    4. A 接收邀请被拒绝事件，随后从服务端核验 B 未入群。
    预期与断言：创建和拒绝后 memberCount 均为 1；A 收到包含 B 与拒绝原因的真实回调；
    A/B 均不收到成员加入事件；无论结果如何都恢复 B 的自动接受开关。
    """
    group_id = ""
    group_name = new_group_name("invite_explicit_decline")
    decline_reason = "explicit-decline"
    joined_event_types = {"onGroupMembersJoined", "onGroupMemberJoined"}
    try:
        resp_option = device_b.call(
            "Client",
            Cmd.updateAutoAcceptGroupInvitationSetting.value,
            info={"autoAcceptGroupInvitation": False},
        )
        assert_api.assert_response_matches(
            resp_option,
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
            invite_members=[user_b],
            invite_need_confirm=True,
            expected_member_count=1,
        )
        invitation_events = collect_group_events(
            device_b,
            expected_event_types={"onGroupInvitationReceived"},
            group_id=group_id,
            required_all_event_types={"onGroupInvitationReceived"},
            timeout=10.0,
        )
        _assert_exact_group_event(
            assert_api,
            invitation_events[0],
            event_type="onGroupInvitationReceived",
            data={
                "groupId": group_id,
                "groupName": group_name,
                "inviter": user_a,
                "reason": "",
            },
        )

        resp_decline = device_b.call(
            "GroupManager",
            Cmd.declineInvitationFromGroup.value,
            info={"groupId": group_id, "inviter": user_a, "reason": decline_reason},
        )
        assert_api.assert_response_matches(
            resp_decline,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.declineInvitationFromGroup.value,
                "device": "deviceB",
                "result": None,
            },
            ignore_keys={"sequence"},
        )

        declined_events: list[dict] = []
        declined_event_error: AssertionError | None = None
        try:
            declined_events = collect_group_events(
                device_a,
                expected_event_types={"onGroupInvitationDeclined"},
                group_id=group_id,
                required_all_event_types={"onGroupInvitationDeclined"},
                timeout=10.0,
            )
        except AssertionError as error:
            declined_event_error = error
        if declined_events:
            _assert_exact_group_event(
                assert_api,
                declined_events[0],
                event_type="onGroupInvitationDeclined",
                data={"groupId": group_id, "invitee": user_b, "reason": decline_reason},
            )
        assert_no_group_event(device_a, group_id=group_id, event_types=joined_event_types)
        assert_no_group_event(device_b, group_id=group_id, event_types=joined_event_types)

        resp_server = device_a.call(
            "GroupManager",
            Cmd.getGroupSpecificationFromServer.value,
            info={"groupId": group_id},
        )
        assert_group_snapshot(
            assert_api,
            resp_server,
            cmd=Cmd.getGroupSpecificationFromServer.value,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count_value=1,
            member_list_value=[],
        )
        if declined_event_error is not None:
            raise AssertionError(
                "显式拒绝邀请回调不符合预期: "
                f"expected=onInvitationDeclinedFromGroup(groupId={group_id}, "
                f"invitee={user_b}, reason={decline_reason!r}), actual=[]; "
                "declineInvitationFromGroup 已返回 result=null，服务端成员仍为 1。"
            ) from declined_event_error
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)
        resp_restore = device_b.call(
            "Client",
            Cmd.updateAutoAcceptGroupInvitationSetting.value,
            info={"autoAcceptGroupInvitation": True},
        )
        assert_api.assert_response_matches(
            resp_restore,
            expected={
                "manager": "Client",
                "cmd": Cmd.updateAutoAcceptGroupInvitationSetting.value,
                "device": "deviceB",
                "result": None,
            },
            ignore_keys={"sequence"},
        )


def test_group_invitation_auto_accept_when_confirmation_required(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """
    前置：A/B 已登录；B 的 autoAcceptGroupInvitation 显式设置为 true。
    步骤：
    1. A 创建 inviteNeedConfirm=true 的私有群并邀请 B。
    2. B 由 SDK 自动接受邀请，不调用 acceptInvitationFromGroup。
    3. 分别收集 A/B 的邀请与成员加入事件，再由 A 拉取服务端群详情。
    预期与断言：B 自动成为成员，服务端 memberCount=2；B 收到自动接受回调；A 收到的
    成员加入事件集合、B 是否额外收到加入事件均按真实 ADB 日志冻结。
    """
    group_id = ""
    joined = False
    group_name = new_group_name("invite_auto_accept")
    try:
        resp_option = device_b.call(
            "Client",
            Cmd.updateAutoAcceptGroupInvitationSetting.value,
            info={"autoAcceptGroupInvitation": True},
        )
        assert_api.assert_response_matches(
            resp_option,
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
            invite_members=[user_b],
            invite_need_confirm=True,
            expected_member_count=1,
        )
        joined = True

        auto_events = collect_group_events(
            device_b,
            expected_event_types={"onGroupAutoAcceptInvitation"},
            group_id=group_id,
            required_all_event_types={"onGroupAutoAcceptInvitation"},
            timeout=10.0,
        )
        _assert_exact_group_event(
            assert_api,
            auto_events[0],
            event_type="onGroupAutoAcceptInvitation",
            data={"groupId": group_id, "inviter": user_a, "inviteMessage": ""},
        )

        owner_event_types = {
            "onGroupInvitationAccepted",
            "onGroupMembersJoined",
            "onGroupMemberJoined",
        }
        owner_events = collect_group_events(
            device_a,
            expected_event_types=owner_event_types,
            group_id=group_id,
            required_all_event_types=owner_event_types,
            timeout=10.0,
        )
        owner_by_type = {event["eventType"]: event for event in owner_events}
        _assert_exact_group_event(
            assert_api,
            owner_by_type["onGroupInvitationAccepted"],
            event_type="onGroupInvitationAccepted",
            data={"groupId": group_id, "invitee": user_b, "reason": ""},
        )
        _assert_exact_group_event(
            assert_api,
            owner_by_type["onGroupMembersJoined"],
            event_type="onGroupMembersJoined",
            data={"groupId": group_id, "userIds": [user_b]},
        )
        _assert_exact_group_event(
            assert_api,
            owner_by_type["onGroupMemberJoined"],
            event_type="onGroupMemberJoined",
            data={"groupId": group_id, "member": user_b},
        )
        assert_no_group_event(device_b, group_id=group_id, event_types=owner_event_types)

        resp_server = device_a.call(
            "GroupManager",
            Cmd.getGroupSpecificationFromServer.value,
            info={"groupId": group_id},
        )
        assert_group_snapshot(
            assert_api,
            resp_server,
            cmd=Cmd.getGroupSpecificationFromServer.value,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count_value=2,
            member_list_value=[user_b],
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id, device_b=device_b if joined else None)


def test_group_request_to_join_and_accept_success(device_a, device_b, assert_api, user_a, user_b):
    group_id = ""
    group_name = new_group_name("public_need_approval")
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[],
            style=2,
        )

        resp_request = device_b.call(
            "GroupManager",
            Cmd.requestToJoinPublicGroup.value,
            info={"groupId": group_id, "reason": "auto-apply-accept"},
        )
        assert_api.assert_response_matches(
            resp_request,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.requestToJoinPublicGroup.value,
                "device": "deviceB",
                "result": None,
            },
            ignore_keys={"sequence"},
        )

        owner_request_events = collect_group_events(
            device_a,
            expected_event_types={
                GroupChangeEvent.ON_REQUEST_TO_JOIN_RECEIVED.value,
                "onGroupRequestToJoinReceived",
                "onGroupRequestToJoinReceived",
            },
            group_id=group_id,
            required_all_event_types={"onGroupRequestToJoinReceived"},
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            owner_request_events,
            expected_event_types={
                GroupChangeEvent.ON_REQUEST_TO_JOIN_RECEIVED.value,
                "onGroupRequestToJoinReceived",
                "onGroupRequestToJoinReceived",
            },
            group_id=group_id,
            required_all_event_types={"onGroupRequestToJoinReceived"},
            expected_member=user_b,
        )

        resp_accept = device_a.call(
            "GroupManager",
            Cmd.acceptJoinApplication.value,
            info={"groupId": group_id, "userId": user_b},
        )
        assert_api.assert_response_matches(
            resp_accept,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.acceptJoinApplication.value,
                "device": "deviceA",
                "result": None,
            },
            ignore_keys={"sequence"},
        )

        applicant_accept_events = collect_group_events(
            device_b,
            expected_event_types={
                GroupChangeEvent.ON_REQUEST_TO_JOIN_ACCEPTED.value,
                GroupChangeEvent.ON_MEMBER_JOINED.value,
                "onGroupRequestToJoinAccepted",
                "onGroupRequestToJoinAccepted",
                "onGroupMemberJoined",
            },
            group_id=group_id,
            allow_missing_group_id=True,
            required_all_event_types={"onGroupRequestToJoinAccepted"},
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            applicant_accept_events,
            expected_event_types={
                GroupChangeEvent.ON_REQUEST_TO_JOIN_ACCEPTED.value,
                GroupChangeEvent.ON_MEMBER_JOINED.value,
                "onGroupRequestToJoinAccepted",
                "onGroupRequestToJoinAccepted",
                "onGroupMemberJoined",
            },
            group_id=group_id,
            allow_missing_group_id=True,
            required_all_event_types={"onGroupRequestToJoinAccepted"},
            expected_member=user_b,
        )

        owner_joined_event_types = {"onGroupMembersJoined", "onGroupMemberJoined"}
        owner_joined_events = collect_group_events(
            device_a,
            expected_event_types=owner_joined_event_types,
            group_id=group_id,
            required_all_event_types=owner_joined_event_types,
            timeout=10.0,
        )
        owner_joined_by_type = {event["eventType"]: event for event in owner_joined_events}
        _assert_exact_group_event(
            assert_api,
            owner_joined_by_type["onGroupMembersJoined"],
            event_type="onGroupMembersJoined",
            data={"groupId": group_id, "userIds": [user_b]},
        )
        _assert_exact_group_event(
            assert_api,
            owner_joined_by_type["onGroupMemberJoined"],
            event_type="onGroupMemberJoined",
            data={"groupId": group_id, "member": user_b},
        )
        assert_no_group_event(device_b, group_id=group_id, event_types=owner_joined_event_types)

        server = device_a.call(
            "GroupManager",
            Cmd.getGroupSpecificationFromServer.value,
            info={"groupId": group_id},
        )
        assert_group_snapshot(
            assert_api,
            server,
            cmd=Cmd.getGroupSpecificationFromServer.value,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count_value=2,
            member_list_value=[user_b],
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_request_to_join_and_decline_success(device_a, device_b, assert_api, user_a, user_b):
    group_id = ""
    group_name = new_group_name("public_need_decline")
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[],
            style=2,
        )

        resp_request = device_b.call(
            "GroupManager",
            Cmd.requestToJoinPublicGroup.value,
            info={"groupId": group_id, "reason": "auto-apply-decline"},
        )
        assert_api.assert_response_matches(
            resp_request,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.requestToJoinPublicGroup.value,
                "device": "deviceB",
                "result": None,
            },
            ignore_keys={"sequence"},
        )

        owner_request_events = collect_group_events(
            device_a,
            expected_event_types={
                GroupChangeEvent.ON_REQUEST_TO_JOIN_RECEIVED.value,
                "onGroupRequestToJoinReceived",
                "onGroupRequestToJoinReceived",
            },
            group_id=group_id,
            required_all_event_types={"onGroupRequestToJoinReceived"},
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            owner_request_events,
            expected_event_types={
                GroupChangeEvent.ON_REQUEST_TO_JOIN_RECEIVED.value,
                "onGroupRequestToJoinReceived",
                "onGroupRequestToJoinReceived",
            },
            group_id=group_id,
            required_all_event_types={"onGroupRequestToJoinReceived"},
            expected_member=user_b,
        )

        resp_decline = device_a.call(
            "GroupManager",
            Cmd.declineJoinApplication.value,
            info={"groupId": group_id, "userId": user_b, "reason": "auto-reject"},
        )
        assert_api.assert_response_matches(
            resp_decline,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.declineJoinApplication.value,
                "device": "deviceA",
                "result": None,
            },
            ignore_keys={"sequence"},
        )

        applicant_decline_events = collect_group_events(
            device_b,
            expected_event_types={
                GroupChangeEvent.ON_REQUEST_TO_JOIN_DECLINED.value,
                "onGroupRequestToJoinDeclined",
                "onGroupRequestToJoinDeclined",
            },
            group_id=group_id,
            allow_missing_group_id=True,
            required_all_event_types={"onGroupRequestToJoinDeclined"},
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            applicant_decline_events,
            expected_event_types={
                GroupChangeEvent.ON_REQUEST_TO_JOIN_DECLINED.value,
                "onGroupRequestToJoinDeclined",
                "onGroupRequestToJoinDeclined",
            },
            group_id=group_id,
            allow_missing_group_id=True,
            required_all_event_types={"onGroupRequestToJoinDeclined"},
            expected_member=user_b,
        )

        joined_event_types = {"onGroupMembersJoined", "onGroupMemberJoined"}
        assert_no_group_event(device_a, group_id=group_id, event_types=joined_event_types)
        assert_no_group_event(device_b, group_id=group_id, event_types=joined_event_types)
        server = device_a.call(
            "GroupManager",
            Cmd.getGroupSpecificationFromServer.value,
            info={"groupId": group_id},
        )
        assert_group_snapshot(
            assert_api,
            server,
            cmd=Cmd.getGroupSpecificationFromServer.value,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count_value=1,
            member_list_value=[],
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_request_to_join_public_group_nonexistent_group(device_b, assert_api):
    resp = device_b.call(
        "GroupManager",
        Cmd.requestToJoinPublicGroup.value,
        info={"groupId": _NONEXISTENT_GROUP_ID, "reason": "auto-reason"},
    )
    assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_accept_join_application_nonexistent_group(device_a, assert_api, user_b):
    resp = device_a.call(
        "GroupManager",
        Cmd.acceptJoinApplication.value,
        info={"groupId": _NONEXISTENT_GROUP_ID, "userId": user_b},
    )
    assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_decline_join_application_nonexistent_group(device_a, assert_api, user_b):
    resp = device_a.call(
        "GroupManager",
        Cmd.declineJoinApplication.value,
        info={"groupId": _NONEXISTENT_GROUP_ID, "userId": user_b, "reason": "auto-reject"},
    )
    assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_accept_join_application_nonexistent_user(device_a, assert_api, user_a):
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("accept_nonexist_user"),
            invite_members=[],
            style=2,
        )
        resp = device_a.call(
            "GroupManager",
            Cmd.acceptJoinApplication.value,
            info={"groupId": group_id, "userId": _NONEXISTENT_USER},
        )
        assert_api.assert_error(resp, code=600, description="doesn't exist")
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_accept_invitation_from_group_without_pending_invite(device_b, assert_api):
    resp = device_b.call(
        "GroupManager",
        Cmd.acceptInvitationFromGroup.value,
        info={"groupId": _NONEXISTENT_GROUP_ID, "inviter": "owner_x"},
    )
    assert_api.assert_error(resp, code=600, description="does not exist")


def test_group_decline_invitation_from_group_without_pending_invite(device_b, assert_api):
    resp = device_b.call(
        "GroupManager",
        Cmd.declineInvitationFromGroup.value,
        info={"groupId": _NONEXISTENT_GROUP_ID, "inviter": "owner_x", "reason": "auto-reject"},
    )
    assert_api.assert_error(resp, code=600, description="does not exist")
