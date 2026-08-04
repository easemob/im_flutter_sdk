"""群邀请与入群申请的 SDK logout/login 离线回放。"""
from __future__ import annotations

import pytest

from src import Cmd
from src.test_flow.offline_test_flow import (
    login_preserving_offline_events,
    logout_for_offline,
)
from tests.group.group_helpers import (
    assert_group_snapshot,
    assert_no_group_event,
    create_group,
    new_group_name,
)
from tests.group.group_offline_helpers import (
    assert_call_result,
    assert_joined_group_projection,
    assert_local_group_permission,
    restore_group_users,
    safe_destroy_group,
    set_auto_accept_group_invitation,
    wait_group_event,
)


pytestmark = [pytest.mark.client, pytest.mark.group]


def _assert_event(assert_api, event: dict, *, event_type: str, data: dict) -> None:
    assert_api.assert_response_matches(
        event,
        expected={"type": "event", "eventType": event_type, "data": data},
        ignore_keys={"timestamp", "sequence"},
    )


def _assert_server_members(
    device_a,
    assert_api,
    *,
    group_id: str,
    group_name: str,
    user_a: str,
    members: list[str],
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
        member_count_value=1 + len(members),
        member_list_value=members,
    )


def _create_pending_invitation(
    device_a,
    assert_api,
    *,
    user_a: str,
    user_b: str,
    group_name: str,
) -> str:
    group_id, _ = create_group(
        device_a,
        assert_api,
        owner=user_a,
        group_name=group_name,
        invite_members=[user_b],
        style=0,
        invite_need_confirm=True,
        expected_member_count=1,
    )
    return group_id


def _request_join(
    device_b,
    assert_api,
    *,
    group_id: str,
    reason: str,
) -> None:
    response = device_b.call(
        "GroupManager",
        Cmd.requestToJoinPublicGroup.value,
        info={"groupId": group_id, "reason": reason},
    )
    assert_call_result(
        assert_api,
        response,
        manager="GroupManager",
        cmd=Cmd.requestToJoinPublicGroup.value,
        device_name="deviceB",
        result=None,
    )


@pytest.mark.parametrize("action", ["accept", "decline"])
def test_group_offline_invitation_received_and_processed_after_login(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    action,
):
    """B 先离线，重登收到群邀请并接受或拒绝，验证权限和最终成员状态。"""
    group_id = ""
    group_name = new_group_name(f"offline_invitation_{action}")
    decline_reason = f"offline-decline-{action}"
    try:
        set_auto_accept_group_invitation(
            device_b, assert_api, device_name="deviceB", enabled=False
        )
        logout_for_offline(device_b, assert_api, device_name="deviceB")
        group_id = _create_pending_invitation(
            device_a,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            group_name=group_name,
        )
        _assert_server_members(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            user_a=user_a,
            members=[],
        )

        login_preserving_offline_events(
            device_b,
            assert_api,
            device_name="deviceB",
            user_id=user_b,
        )
        invitation = wait_group_event(
            device_b,
            event_type="onInvitationReceivedFromGroup",
            group_id=group_id,
        )
        _assert_event(
            assert_api,
            invitation,
            event_type="onInvitationReceivedFromGroup",
            data={
                "groupId": group_id,
                "groupName": group_name,
                "inviter": user_a,
                "reason": "",
            },
        )

        if action == "accept":
            response = device_b.call(
                "GroupManager",
                Cmd.acceptInvitationFromGroup.value,
                info={"groupId": group_id, "inviter": user_a},
            )
            assert_group_snapshot(
                assert_api,
                response,
                cmd=Cmd.acceptInvitationFromGroup.value,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                member_count_value=2,
                permission_type=0,
                device="deviceB",
            )
            result_event = wait_group_event(
                device_a,
                event_type="onInvitationAcceptedFromGroup",
                group_id=group_id,
            )
            _assert_event(
                assert_api,
                result_event,
                event_type="onInvitationAcceptedFromGroup",
                data={"groupId": group_id, "invitee": user_b, "reason": ""},
            )
            _assert_server_members(
                device_a,
                assert_api,
                group_id=group_id,
                group_name=group_name,
                user_a=user_a,
                members=[user_b],
            )
            assert_local_group_permission(
                device_b,
                assert_api,
                device_name="deviceB",
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                permission_type=0,
                member_count=2,
            )
            assert_joined_group_projection(
                device_b,
                assert_api,
                device_name="deviceB",
                group_id=group_id,
                present=True,
                owner=user_a,
                permission_type=0,
                member_count=2,
            )
        else:
            response = device_b.call(
                "GroupManager",
                Cmd.declineInvitationFromGroup.value,
                info={
                    "groupId": group_id,
                    "inviter": user_a,
                    "reason": decline_reason,
                },
            )
            assert_call_result(
                assert_api,
                response,
                manager="GroupManager",
                cmd=Cmd.declineInvitationFromGroup.value,
                device_name="deviceB",
                result=None,
            )
            assert_no_group_event(
                device_a,
                group_id=group_id,
                event_types={"onInvitationDeclinedFromGroup"},
                timeout=3.0,
            )
            _assert_server_members(
                device_a,
                assert_api,
                group_id=group_id,
                group_name=group_name,
                user_a=user_a,
                members=[],
            )
            assert_joined_group_projection(
                device_b,
                assert_api,
                device_name="deviceB",
                group_id=group_id,
                present=False,
            )
    finally:
        restore_group_users(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            restore_group_invitation_option=True,
        )
        safe_destroy_group(device_a, group_id)


@pytest.mark.parametrize("action", ["accept", "decline"])
def test_group_offline_owner_receives_invitation_result_after_relogin(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    action,
):
    """A 在 B 处理邀请时离线，A 重登收到接受或拒绝结果并核验成员状态。"""
    group_id = ""
    group_name = new_group_name(f"offline_owner_invitation_result_{action}")
    decline_reason = f"owner-offline-decline-{action}"
    try:
        set_auto_accept_group_invitation(
            device_b, assert_api, device_name="deviceB", enabled=False
        )
        group_id = _create_pending_invitation(
            device_a,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            group_name=group_name,
        )
        invitation = wait_group_event(
            device_b,
            event_type="onInvitationReceivedFromGroup",
            group_id=group_id,
        )
        _assert_event(
            assert_api,
            invitation,
            event_type="onInvitationReceivedFromGroup",
            data={
                "groupId": group_id,
                "groupName": group_name,
                "inviter": user_a,
                "reason": "",
            },
        )
        logout_for_offline(device_a, assert_api, device_name="deviceA")

        if action == "accept":
            response = device_b.call(
                "GroupManager",
                Cmd.acceptInvitationFromGroup.value,
                info={"groupId": group_id, "inviter": user_a},
            )
            assert_group_snapshot(
                assert_api,
                response,
                cmd=Cmd.acceptInvitationFromGroup.value,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                member_count_value=2,
                permission_type=0,
                device="deviceB",
            )
            expected_event_type = "onInvitationAcceptedFromGroup"
            expected_data = {"groupId": group_id, "invitee": user_b, "reason": ""}
            members = [user_b]
        else:
            response = device_b.call(
                "GroupManager",
                Cmd.declineInvitationFromGroup.value,
                info={
                    "groupId": group_id,
                    "inviter": user_a,
                    "reason": decline_reason,
                },
            )
            assert_call_result(
                assert_api,
                response,
                manager="GroupManager",
                cmd=Cmd.declineInvitationFromGroup.value,
                device_name="deviceB",
                result=None,
            )
            expected_event_type = "onInvitationDeclinedFromGroup"
            expected_data = None
            members = []

        login_preserving_offline_events(
            device_a,
            assert_api,
            device_name="deviceA",
            user_id=user_a,
        )
        if expected_data is None:
            assert_no_group_event(
                device_a,
                group_id=group_id,
                event_types={expected_event_type},
                timeout=3.0,
            )
        else:
            result_event = wait_group_event(
                device_a,
                event_type=expected_event_type,
                group_id=group_id,
            )
            _assert_event(
                assert_api,
                result_event,
                event_type=expected_event_type,
                data=expected_data,
            )
        _assert_server_members(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            user_a=user_a,
            members=members,
        )
    finally:
        restore_group_users(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            restore_group_invitation_option=True,
        )
        safe_destroy_group(device_a, group_id)


@pytest.mark.parametrize("action", ["accept", "decline"])
def test_group_offline_owner_receives_join_application_and_processes_after_login(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    action,
):
    """审批群群主 A 先离线，B 申请后 A 重登接收申请并同意或拒绝。"""
    group_id = ""
    group_name = new_group_name(f"offline_owner_application_{action}")
    request_reason = f"owner-offline-request-{action}"
    decline_reason = f"owner-offline-reject-{action}"
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[],
            style=2,
        )
        logout_for_offline(device_a, assert_api, device_name="deviceA")
        _request_join(
            device_b,
            assert_api,
            group_id=group_id,
            reason=request_reason,
        )
        login_preserving_offline_events(
            device_a,
            assert_api,
            device_name="deviceA",
            user_id=user_a,
        )
        request_event = wait_group_event(
            device_a,
            event_type="onRequestToJoinReceivedFromGroup",
            group_id=group_id,
        )
        _assert_event(
            assert_api,
            request_event,
            event_type="onRequestToJoinReceivedFromGroup",
            data={
                "groupId": group_id,
                "groupName": group_name,
                "applicant": user_b,
                "reason": request_reason,
            },
        )

        if action == "accept":
            cmd = Cmd.acceptJoinApplication.value
            info = {"groupId": group_id, "userId": user_b}
            event_type = "onRequestToJoinAcceptedFromGroup"
            event_data = {
                "groupId": group_id,
                "groupName": group_name,
                "accepter": user_a,
            }
            members = [user_b]
        else:
            cmd = Cmd.declineJoinApplication.value
            info = {
                "groupId": group_id,
                "userId": user_b,
                "reason": decline_reason,
            }
            event_type = "onRequestToJoinDeclinedFromGroup"
            event_data = {
                "groupId": group_id,
                "groupName": None,
                "decliner": user_a,
                "reason": decline_reason,
                "applicant": user_b,
            }
            members = []
        response = device_a.call("GroupManager", cmd, info=info)
        assert_call_result(
            assert_api,
            response,
            manager="GroupManager",
            cmd=cmd,
            device_name="deviceA",
            result=None,
        )
        result_event = wait_group_event(
            device_b,
            event_type=event_type,
            group_id=group_id,
        )
        _assert_event(
            assert_api,
            result_event,
            event_type=event_type,
            data=event_data,
        )
        _assert_server_members(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            user_a=user_a,
            members=members,
        )
        assert_joined_group_projection(
            device_b,
            assert_api,
            device_name="deviceB",
            group_id=group_id,
            present=action == "accept",
            owner=user_a if action == "accept" else None,
            permission_type=0 if action == "accept" else None,
            member_count=2 if action == "accept" else None,
        )
    finally:
        restore_group_users(
            device_a, device_b, assert_api, user_a=user_a, user_b=user_b
        )
        safe_destroy_group(device_a, group_id)


@pytest.mark.parametrize("action", ["accept", "decline"])
def test_group_offline_applicant_receives_application_result_after_relogin(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    action,
):
    """B 申请审批群后离线，A 处理；B 重登收到审批结果并验证最终状态。"""
    group_id = ""
    group_name = new_group_name(f"offline_applicant_result_{action}")
    request_reason = f"applicant-offline-request-{action}"
    decline_reason = f"applicant-offline-reject-{action}"
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[],
            style=2,
        )
        _request_join(
            device_b,
            assert_api,
            group_id=group_id,
            reason=request_reason,
        )
        request_event = wait_group_event(
            device_a,
            event_type="onRequestToJoinReceivedFromGroup",
            group_id=group_id,
        )
        _assert_event(
            assert_api,
            request_event,
            event_type="onRequestToJoinReceivedFromGroup",
            data={
                "groupId": group_id,
                "groupName": group_name,
                "applicant": user_b,
                "reason": request_reason,
            },
        )
        logout_for_offline(device_b, assert_api, device_name="deviceB")

        if action == "accept":
            cmd = Cmd.acceptJoinApplication.value
            info = {"groupId": group_id, "userId": user_b}
            event_type = "onRequestToJoinAcceptedFromGroup"
            event_data = {
                "groupId": group_id,
                "groupName": group_name,
                "accepter": user_a,
            }
            members = [user_b]
        else:
            cmd = Cmd.declineJoinApplication.value
            info = {
                "groupId": group_id,
                "userId": user_b,
                "reason": decline_reason,
            }
            event_type = "onRequestToJoinDeclinedFromGroup"
            event_data = {
                "groupId": group_id,
                "groupName": None,
                "decliner": user_a,
                "reason": decline_reason,
                "applicant": user_b,
            }
            members = []
        response = device_a.call("GroupManager", cmd, info=info)
        assert_call_result(
            assert_api,
            response,
            manager="GroupManager",
            cmd=cmd,
            device_name="deviceA",
            result=None,
        )

        login_preserving_offline_events(
            device_b,
            assert_api,
            device_name="deviceB",
            user_id=user_b,
        )
        result_event = wait_group_event(
            device_b,
            event_type=event_type,
            group_id=group_id,
        )
        _assert_event(
            assert_api,
            result_event,
            event_type=event_type,
            data=event_data,
        )
        _assert_server_members(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            user_a=user_a,
            members=members,
        )
        assert_joined_group_projection(
            device_b,
            assert_api,
            device_name="deviceB",
            group_id=group_id,
            present=action == "accept",
            owner=user_a if action == "accept" else None,
            permission_type=0 if action == "accept" else None,
            member_count=2 if action == "accept" else None,
        )
    finally:
        restore_group_users(
            device_a, device_b, assert_api, user_a=user_a, user_b=user_b
        )
        safe_destroy_group(device_a, group_id)
