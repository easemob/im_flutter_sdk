"""群邀请与入群申请的 SDK logout/login 离线回放。"""
from __future__ import annotations

import pytest
from tests.group.allure_helpers import _allure_step

from src import Cmd
from tests.group.group_helpers import (
    assert_group_snapshot,
    assert_group_members_from_server,
    assert_no_group_event,
    create_group,
    new_group_name,
)
from tests.group.group_offline_helpers import (
    assert_call_result,
    assert_joined_group_projection,
    assert_local_group_permission,
    device_name,
    login_group_account_devices,
    logout_group_account_devices,
    restore_group_users,
    safe_destroy_group,
    set_auto_accept_group_invitation,
    wait_group_event,
)


pytestmark = [
    pytest.mark.client,
    pytest.mark.group,
    pytest.mark.topology("account_a_to_account_b"),
]


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
    is_public: bool = False,
    join_approval_required: bool = False,
) -> None:
    admins: list[str] = []
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
        member_count_value=1 + len(admins) + len(members),
        admin_list_value=admins,
        is_public=is_public,
        join_approval_required=join_approval_required,
    )
    with _allure_step("查询并校验服务端分页普通成员列表"):
        assert_group_members_from_server(
            device_a,
            assert_api,
            group_id=group_id,
            device_name=device_name(device_a),
            expected_members=members,
            err_prefix="离线群组最终状态",
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
        device_name=device_name(device_b),
        result=None,
    )


@pytest.mark.parametrize("action", ["accept", "decline"])

def test_group_offline_invitation_received_and_processed_after_login(
    topology,
    assert_api,
    action,
):
    """B 先离线，重登收到群邀请并接受或拒绝，验证权限和最终成员状态。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    group_id = ""
    group_name = new_group_name(f"offline_invitation_{action}")
    decline_reason = f"offline-decline-{action}"
    try:
        for endpoint in recipient_devices:
            set_auto_accept_group_invitation(
                endpoint,
                assert_api,
                device_name=device_name(endpoint),
                enabled=False,
            )
        with _allure_step("测试准备：切换账号设备在线状态"):
            logout_group_account_devices(recipient_devices, assert_api)
        with _allure_step("测试准备：创建测试群并建立成员前置"):
            group_id = _create_pending_invitation(
                device_a,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                group_name=group_name,
            )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_server_members(
                device_a,
                assert_api,
                group_id=group_id,
                group_name=group_name,
                user_a=user_a,
                members=[],
            )

        with _allure_step("测试准备：切换账号设备在线状态"):
            login_group_account_devices(recipient_devices, assert_api, user_id=user_b)
        for endpoint in recipient_devices:
            with _allure_step("等待并校验目标业务事件"):
                invitation = wait_group_event(
                    endpoint,
                    event_type="onGroupInvitationReceived",
                    group_id=group_id,
                )
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_event(
                    assert_api,
                    invitation,
                    event_type="onGroupInvitationReceived",
                    data={
                        "groupId": group_id,
                        "groupName": group_name,
                        "inviter": user_a,
                        "reason": "",
                    },
                )

        if action == "accept":
            with _allure_step("B 接受入群邀请"):
                response = device_b.call(
                    "GroupManager",
                    Cmd.acceptInvitationFromGroup.value,
                    info={"groupId": group_id, "inviter": user_a},
                )
            with _allure_step("验证接受入群邀请返回的响应 result 与关键字段"):
                assert_group_snapshot(
                    assert_api,
                    response,
                    cmd=Cmd.acceptInvitationFromGroup.value,
                    group_id=group_id,
                    group_name=group_name,
                    owner=user_a,
                    member_count_value=2,
                    permission_type=0,
                    device=device_name(device_b),
                )
            with _allure_step("等待并校验目标业务事件"):
                result_event = wait_group_event(
                    device_a,
                    event_type="onGroupInvitationAccepted",
                    group_id=group_id,
                )
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_event(
                    assert_api,
                    result_event,
                    event_type="onGroupInvitationAccepted",
                    data={"groupId": group_id, "invitee": user_b, "reason": ""},
                )
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_server_members(
                    device_a,
                    assert_api,
                    group_id=group_id,
                    group_name=group_name,
                    user_a=user_a,
                    members=[user_b],
                )
            for endpoint in recipient_devices:
                with _allure_step("验证接受入群邀请返回的响应 result 与关键字段"):
                    assert_local_group_permission(
                        endpoint,
                        assert_api,
                        device_name=device_name(endpoint),
                        group_id=group_id,
                        group_name=group_name,
                        owner=user_a,
                        permission_type=0,
                        member_count=2,
                    )
                with _allure_step("验证接受入群邀请返回的响应 result 与关键字段"):
                    assert_joined_group_projection(
                        endpoint,
                        assert_api,
                        device_name=device_name(endpoint),
                        group_id=group_id,
                        present=True,
                        owner=user_a,
                        permission_type=0,
                        member_count=2,
                    )
        else:
            with _allure_step("B 拒绝入群邀请"):
                response = device_b.call(
                    "GroupManager",
                    Cmd.declineInvitationFromGroup.value,
                    info={
                        "groupId": group_id,
                        "inviter": user_a,
                        "reason": decline_reason,
                    },
                )
            with _allure_step("验证拒绝入群邀请返回的响应 result 与关键字段"):
                assert_call_result(
                    assert_api,
                    response,
                    manager="GroupManager",
                    cmd=Cmd.declineInvitationFromGroup.value,
                    device_name=device_name(device_b),
                    result=None,
                )
            with _allure_step("验证拒绝入群邀请返回的响应 result 与关键字段"):
                assert_no_group_event(
                    device_a,
                    group_id=group_id,
                    event_types={"onGroupInvitationDeclined"},
                    timeout=3.0,
                )
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_server_members(
                    device_a,
                    assert_api,
                    group_id=group_id,
                    group_name=group_name,
                    user_a=user_a,
                    members=[],
                )
            for endpoint in recipient_devices:
                with _allure_step("验证拒绝入群邀请返回的响应 result 与关键字段"):
                    assert_joined_group_projection(
                        endpoint,
                        assert_api,
                        device_name=device_name(endpoint),
                        group_id=group_id,
                        present=False,
                    )
    finally:
        with _allure_step("测试后置：测试准备：切换账号设备在线状态"):
            restore_group_users(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                restore_group_invitation_option=True,
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )
        with _allure_step("测试后置：销毁测试群并恢复环境"):
            safe_destroy_group(device_a, group_id)


@pytest.mark.parametrize("action", ["accept", "decline"])
def test_group_offline_owner_receives_invitation_result_after_relogin(
    topology,
    assert_api,
    action,
):
    """A 在 B 处理邀请时离线，A 重登收到接受或拒绝结果并核验成员状态。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    group_id = ""
    group_name = new_group_name(f"offline_owner_invitation_result_{action}")
    decline_reason = f"owner-offline-decline-{action}"
    try:
        for endpoint in recipient_devices:
            set_auto_accept_group_invitation(
                endpoint,
                assert_api,
                device_name=device_name(endpoint),
                enabled=False,
            )
        with _allure_step("测试准备：创建测试群并建立成员前置"):
            group_id = _create_pending_invitation(
                device_a,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                group_name=group_name,
            )
        with _allure_step("等待并校验目标业务事件"):
            invitation = wait_group_event(
                device_b,
                event_type="onGroupInvitationReceived",
                group_id=group_id,
            )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_event(
                assert_api,
                invitation,
                event_type="onGroupInvitationReceived",
                data={
                    "groupId": group_id,
                    "groupName": group_name,
                    "inviter": user_a,
                    "reason": "",
                },
            )
        with _allure_step("测试准备：切换账号设备在线状态"):
            logout_group_account_devices(sender_devices, assert_api)

        if action == "accept":
            with _allure_step("B 接受入群邀请"):
                response = device_b.call(
                    "GroupManager",
                    Cmd.acceptInvitationFromGroup.value,
                    info={"groupId": group_id, "inviter": user_a},
                )
            with _allure_step("验证接受入群邀请返回的响应 result 与关键字段"):
                assert_group_snapshot(
                    assert_api,
                    response,
                    cmd=Cmd.acceptInvitationFromGroup.value,
                    group_id=group_id,
                    group_name=group_name,
                    owner=user_a,
                    member_count_value=2,
                    permission_type=0,
                    device=device_name(device_b),
                )
            expected_event_type = "onGroupInvitationAccepted"
            expected_data = {"groupId": group_id, "invitee": user_b, "reason": ""}
            members = [user_b]
        else:
            with _allure_step("B 拒绝入群邀请"):
                response = device_b.call(
                    "GroupManager",
                    Cmd.declineInvitationFromGroup.value,
                    info={
                        "groupId": group_id,
                        "inviter": user_a,
                        "reason": decline_reason,
                    },
                )
            with _allure_step("验证拒绝入群邀请返回的响应 result 与关键字段"):
                assert_call_result(
                    assert_api,
                    response,
                    manager="GroupManager",
                    cmd=Cmd.declineInvitationFromGroup.value,
                    device_name=device_name(device_b),
                    result=None,
                )
            expected_event_type = "onGroupInvitationDeclined"
            expected_data = None
            members = []

        with _allure_step("测试准备：切换账号设备在线状态"):
            login_group_account_devices(sender_devices, assert_api, user_id=user_a)
        for endpoint in sender_devices:
            if expected_data is None:
                with _allure_step("验证拒绝入群邀请返回的响应 result 与关键字段"):
                    assert_no_group_event(
                        endpoint,
                        group_id=group_id,
                        event_types={expected_event_type},
                        timeout=3.0,
                    )
            else:
                with _allure_step("等待并校验目标业务事件"):
                    result_event = wait_group_event(
                        endpoint,
                        event_type=expected_event_type,
                        group_id=group_id,
                    )
                with _allure_step("验证群业务状态、事件与关键字段"):
                    _assert_event(
                        assert_api,
                        result_event,
                        event_type=expected_event_type,
                        data=expected_data,
                    )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_server_members(
                device_a,
                assert_api,
                group_id=group_id,
                group_name=group_name,
                user_a=user_a,
                members=members,
            )
    finally:
        with _allure_step("测试后置：测试准备：切换账号设备在线状态"):
            restore_group_users(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                restore_group_invitation_option=True,
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )
        with _allure_step("测试后置：销毁测试群并恢复环境"):
            safe_destroy_group(device_a, group_id)


@pytest.mark.parametrize("action", ["accept", "decline"])
def test_group_offline_owner_receives_join_application_and_processes_after_login(
    topology,
    assert_api,
    action,
):
    """审批群群主 A 先离线，B 申请后 A 重登接收申请并同意或拒绝。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    group_id = ""
    group_name = new_group_name(f"offline_owner_application_{action}")
    request_reason = f"owner-offline-request-{action}"
    decline_reason = f"owner-offline-reject-{action}"
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                device_a,
                assert_api,
                owner=user_a,
                group_name=group_name,
                invite_members=[],
                style=2,
            )
        with _allure_step("测试准备：切换账号设备在线状态"):
            logout_group_account_devices(sender_devices, assert_api)
        _request_join(
            device_b,
            assert_api,
            group_id=group_id,
            reason=request_reason,
        )
        with _allure_step("测试准备：切换账号设备在线状态"):
            login_group_account_devices(sender_devices, assert_api, user_id=user_a)
        for endpoint in sender_devices:
            with _allure_step("等待并校验目标业务事件"):
                request_event = wait_group_event(
                    endpoint,
                    event_type="onGroupRequestToJoinReceived",
                    group_id=group_id,
                )
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_event(
                    assert_api,
                    request_event,
                    event_type="onGroupRequestToJoinReceived",
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
            event_type = "onGroupRequestToJoinAccepted"
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
            event_type = "onGroupRequestToJoinDeclined"
            event_data = {
                "groupId": group_id,
                "decliner": user_a,
                "reason": decline_reason,
                "applicant": user_b,
            }
            members = []
        with _allure_step("A 执行群组业务操作"):
            response = device_a.call("GroupManager", cmd, info=info)
        with _allure_step("验证执行群组业务操作返回的响应 result 与关键字段"):
            assert_call_result(
                assert_api,
                response,
                manager="GroupManager",
                cmd=cmd,
                device_name=device_name(device_a),
                result=None,
            )
        for endpoint in recipient_devices:
            with _allure_step("等待并校验目标业务事件"):
                result_event = wait_group_event(
                    endpoint,
                    event_type=event_type,
                    group_id=group_id,
                )
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_event(
                    assert_api,
                    result_event,
                    event_type=event_type,
                    data=event_data,
                )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_server_members(
                device_a,
                assert_api,
                group_id=group_id,
                group_name=group_name,
                user_a=user_a,
                members=members,
                is_public=True,
                join_approval_required=True,
            )
        for endpoint in recipient_devices:
            with _allure_step("验证执行群组业务操作返回的响应 result 与关键字段"):
                assert_joined_group_projection(
                    endpoint,
                    assert_api,
                    device_name=device_name(endpoint),
                    group_id=group_id,
                    present=action == "accept",
                    owner=user_a if action == "accept" else None,
                    permission_type=0 if action == "accept" else None,
                    member_count=2 if action == "accept" else None,
                )
    finally:
        with _allure_step("测试后置：测试准备：切换账号设备在线状态"):
            restore_group_users(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )
        with _allure_step("测试后置：销毁测试群并恢复环境"):
            safe_destroy_group(device_a, group_id)


@pytest.mark.parametrize("action", ["accept", "decline"])
def test_group_offline_applicant_receives_application_result_after_relogin(
    topology,
    assert_api,
    action,
):
    """B 申请审批群后离线，A 处理；B 重登收到审批结果并验证最终状态。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    group_id = ""
    group_name = new_group_name(f"offline_applicant_result_{action}")
    request_reason = f"applicant-offline-request-{action}"
    decline_reason = f"applicant-offline-reject-{action}"
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
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
        with _allure_step("等待并校验目标业务事件"):
            request_event = wait_group_event(
                device_a,
                event_type="onGroupRequestToJoinReceived",
                group_id=group_id,
            )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_event(
                assert_api,
                request_event,
                event_type="onGroupRequestToJoinReceived",
                data={
                    "groupId": group_id,
                    "groupName": group_name,
                    "applicant": user_b,
                    "reason": request_reason,
                },
            )
        with _allure_step("测试准备：切换账号设备在线状态"):
            logout_group_account_devices(recipient_devices, assert_api)

        if action == "accept":
            cmd = Cmd.acceptJoinApplication.value
            info = {"groupId": group_id, "userId": user_b}
            event_type = "onGroupRequestToJoinAccepted"
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
            event_type = "onGroupRequestToJoinDeclined"
            event_data = {
                "groupId": group_id,
                "decliner": user_a,
                "reason": decline_reason,
                "applicant": user_b,
            }
            members = []
        with _allure_step("A 执行群组业务操作"):
            response = device_a.call("GroupManager", cmd, info=info)
        with _allure_step("验证执行群组业务操作返回的响应 result 与关键字段"):
            assert_call_result(
                assert_api,
                response,
                manager="GroupManager",
                cmd=cmd,
                device_name=device_name(device_a),
                result=None,
            )

        with _allure_step("测试准备：切换账号设备在线状态"):
            login_group_account_devices(recipient_devices, assert_api, user_id=user_b)
        for endpoint in recipient_devices:
            with _allure_step("等待并校验目标业务事件"):
                result_event = wait_group_event(
                    endpoint,
                    event_type=event_type,
                    group_id=group_id,
                )
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_event(
                    assert_api,
                    result_event,
                    event_type=event_type,
                    data=event_data,
                )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_server_members(
                device_a,
                assert_api,
                group_id=group_id,
                group_name=group_name,
                user_a=user_a,
                members=members,
                is_public=True,
                join_approval_required=True,
            )
        for endpoint in recipient_devices:
            with _allure_step("验证执行群组业务操作返回的响应 result 与关键字段"):
                assert_joined_group_projection(
                    endpoint,
                    assert_api,
                    device_name=device_name(endpoint),
                    group_id=group_id,
                    present=action == "accept",
                    owner=user_a if action == "accept" else None,
                    permission_type=0 if action == "accept" else None,
                    member_count=2 if action == "accept" else None,
                )
    finally:
        with _allure_step("测试后置：测试准备：切换账号设备在线状态"):
            restore_group_users(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )
        with _allure_step("测试后置：销毁测试群并恢复环境"):
            safe_destroy_group(device_a, group_id)
