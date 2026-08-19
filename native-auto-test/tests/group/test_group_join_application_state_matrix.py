"""Group 入群申请 pending 状态与处理角色矩阵。"""
from __future__ import annotations

import pytest
from tests.group.allure_helpers import _allure_step

from src import Cmd
from tests.group.group_helpers import (
    assert_group_members_exact,
    assert_group_snapshot,
    assert_no_group_event,
    collect_group_events,
    create_group,
    destroy_group,
    group_style_configs,
    new_group_name,
)


pytestmark = [pytest.mark.client, pytest.mark.group]


def _assert_call(assert_api, response: dict, *, manager: str, cmd: str,
                 device: str, result) -> None:
    assert_api.assert_response_matches(
        response,
        expected={"manager": manager, "cmd": cmd, "device": device, "result": result},
        ignore_keys={"sequence"},
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
    # 5.0 统一 token 登录：密码需先 REST 换 token（loginWithToken 接受 token，直接传密码被拒 202）
    from src.rest_api.user_api import fetch_user_token
    _tok = fetch_user_token(user_id, "1").get("access_token", "")
    login = device.call(
        "Client",
        Cmd.login.value,
        info={"userId": user_id, "pwdOrToken": _tok, "isPassword": False},
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


def _assert_event(assert_api, event: dict, *, event_type: str, data: dict) -> None:
    assert_api.assert_response_matches(
        event,
        expected={"type": "event", "eventType": event_type, "data": data},
        ignore_keys={"timestamp", "sequence"},
    )


def _fetch_group(
    device,
    assert_api,
    *,
    group_id: str,
    group_name: str,
    owner: str,
    members: list[str],
    member_count: int,
    admins: list[str] | None = None,
    permission_type: int = 2,
    style: int,
    device_name: str,
) -> None:
    response = device.call(
        "GroupManager",
        Cmd.getGroupSpecificationFromServer.value,
        info={"groupId": group_id},
    )
    configs = group_style_configs(style)
    assert_group_snapshot(
        assert_api,
        response,
        cmd=Cmd.getGroupSpecificationFromServer.value,
        group_id=group_id,
        group_name=group_name,
        owner=owner,
        member_count_value=member_count,
        admin_list_value=admins,
        permission_type=permission_type,
        is_member_allow_to_invite=configs["allowInvites"],
        is_public=configs["isPublic"],
        join_approval_required=configs["joinApprovalRequired"],
        device=device_name,
    )
    assert_group_members_exact(response, members, err_prefix="入群申请服务端快照")


def _request_join(
    applicant_device,
    owner_device,
    assert_api,
    *,
    applicant_device_name: str,
    group_id: str,
    group_name: str,
    applicant: str,
    reason: str,
) -> None:
    response = applicant_device.call(
        "GroupManager",
        Cmd.requestToJoinPublicGroup.value,
        info={"groupId": group_id, "reason": reason},
    )
    _assert_call(
        assert_api,
        response,
        manager="GroupManager",
        cmd=Cmd.requestToJoinPublicGroup.value,
        device=applicant_device_name,
        result=None,
    )
    request_events = collect_group_events(
        owner_device,
        expected_event_types={"onGroupRequestToJoinReceived"},
        group_id=group_id,
        required_all_event_types={"onGroupRequestToJoinReceived"},
        timeout=10.0,
    )
    _assert_event(
        assert_api,
        request_events[0],
        event_type="onGroupRequestToJoinReceived",
        data={
            "groupId": group_id,
            "groupName": group_name,
            "applicant": applicant,
            "reason": reason,
        },
    )


@pytest.mark.parametrize(
    "action",
    [Cmd.acceptJoinApplication.value, Cmd.declineJoinApplication.value],
    ids=["accept", "decline"],
)

def test_group_join_application_valid_group_without_pending_is_rejected(
    device_a,
    assert_api,
    user_a,
    user_b,
    action,
):
    """有效审批群中不存在 pending 申请时，同意和拒绝都应返回稳定错误。"""
    group_id = ""
    group_name = new_group_name(f"application_no_pending_{action}")
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
        info = {"groupId": group_id, "userId": user_b}
        if action == Cmd.declineJoinApplication.value:
            info["reason"] = "no-pending"
        with _allure_step("A 执行群组业务操作"):
            response = device_a.call("GroupManager", action, info=info)
        with _allure_step("验证执行群组业务操作返回的错误码与错误文案"):
            assert_api.assert_error(response, code=110, description="is not in the apply list")
        _fetch_group(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            members=[],
            member_count=1,
            style=2,
            device_name="deviceA",
        )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)


def test_group_join_application_empty_reason_uses_server_default(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """空申请原因应被服务端规范化，并且 pending 仍可被正常拒绝。"""
    group_id = ""
    group_name = new_group_name("application_empty_reason")
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
        with _allure_step("B 申请加入公开群"):
            response = device_b.call(
                "GroupManager",
                Cmd.requestToJoinPublicGroup.value,
                info={"groupId": group_id, "reason": ""},
            )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_call(
                assert_api,
                response,
                manager="GroupManager",
                cmd=Cmd.requestToJoinPublicGroup.value,
                device="deviceB",
                result=None,
            )
        with _allure_step("等待并校验目标业务事件"):
            request_events = collect_group_events(
                device_a,
                expected_event_types={"onGroupRequestToJoinReceived"},
                group_id=group_id,
                required_all_event_types={"onGroupRequestToJoinReceived"},
                timeout=10.0,
            )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_event(
                assert_api,
                request_events[0],
                event_type="onGroupRequestToJoinReceived",
                data={
                    "groupId": group_id,
                    "groupName": group_name,
                    "applicant": user_b,
                    "reason": "apply to join",
                },
            )
        with _allure_step("A 拒绝入群申请"):
            decline = device_a.call(
                "GroupManager",
                Cmd.declineJoinApplication.value,
                info={"groupId": group_id, "userId": user_b, "reason": "cleanup"},
            )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_call(
                assert_api,
                decline,
                manager="GroupManager",
                cmd=Cmd.declineJoinApplication.value,
                device="deviceA",
                result=None,
            )
        with _allure_step("等待并校验目标业务事件"):
            collect_group_events(
                device_b,
                expected_event_types={"onGroupRequestToJoinDeclined"},
                group_id=group_id,
                required_all_event_types={"onGroupRequestToJoinDeclined"},
                timeout=10.0,
            )
        _fetch_group(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            members=[],
            member_count=1,
            style=2,
            device_name="deviceA",
        )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)


def test_group_duplicate_join_application_keeps_single_pending_request(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """同一用户重复申请时，两次通知可见，但只保留一个可处理的 pending。"""
    group_id = ""
    group_name = new_group_name("application_duplicate")
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
            device_a,
            assert_api,
            applicant_device_name="deviceB",
            group_id=group_id,
            group_name=group_name,
            applicant=user_b,
            reason="first-reason",
        )
        _request_join(
            device_b,
            device_a,
            assert_api,
            applicant_device_name="deviceB",
            group_id=group_id,
            group_name=group_name,
            applicant=user_b,
            reason="second-reason",
        )
        with _allure_step("A 拒绝入群申请"):
            decline = device_a.call(
                "GroupManager",
                Cmd.declineJoinApplication.value,
                info={"groupId": group_id, "userId": user_b, "reason": "cleanup"},
            )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_call(
                assert_api,
                decline,
                manager="GroupManager",
                cmd=Cmd.declineJoinApplication.value,
                device="deviceA",
                result=None,
            )
        with _allure_step("等待并校验目标业务事件"):
            declined_events = collect_group_events(
                device_b,
                expected_event_types={"onGroupRequestToJoinDeclined"},
                group_id=group_id,
                required_all_event_types={"onGroupRequestToJoinDeclined"},
                timeout=10.0,
            )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_event(
                assert_api,
                declined_events[0],
                event_type="onGroupRequestToJoinDeclined",
                data={
                    "groupId": group_id,
                    "decliner": user_a,
                    "reason": "cleanup",
                    "applicant": user_b,
                },
            )
        _fetch_group(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            members=[],
            member_count=1,
            style=2,
            device_name="deviceA",
        )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)


@pytest.mark.parametrize(
    ("first_action", "second_action"),
    [
        pytest.param("accept", "accept", id="accept-twice"),
        pytest.param("decline", "decline", id="decline-twice"),
        pytest.param("accept", "decline", id="accept-then-decline"),
        pytest.param("decline", "accept", id="decline-then-accept"),
    ],
)
def test_group_join_application_cannot_be_processed_twice(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    first_action,
    second_action,
):
    """一个 pending 申请只能处理一次，重复或反向处理不得改变首次结果。"""
    group_id = ""
    group_name = new_group_name(f"application_{first_action}_{second_action}")
    accepted = False
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
            device_a,
            assert_api,
            applicant_device_name="deviceB",
            group_id=group_id,
            group_name=group_name,
            applicant=user_b,
            reason="state-machine",
        )
        first_cmd = (
            Cmd.acceptJoinApplication.value
            if first_action == "accept"
            else Cmd.declineJoinApplication.value
        )
        first_info = {"groupId": group_id, "userId": user_b}
        if first_action == "decline":
            first_info["reason"] = "first-decline"
        with _allure_step("A 执行群组业务操作"):
            first = device_a.call("GroupManager", first_cmd, info=first_info)
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_call(
                assert_api,
                first,
                manager="GroupManager",
                cmd=first_cmd,
                device="deviceA",
                result=None,
            )
        first_event_type = (
            "onGroupRequestToJoinAccepted"
            if first_action == "accept"
            else "onGroupRequestToJoinDeclined"
        )
        with _allure_step("等待并校验目标业务事件"):
            first_events = collect_group_events(
                device_b,
                expected_event_types={first_event_type},
                group_id=group_id,
                required_all_event_types={first_event_type},
                timeout=10.0,
            )
        if first_action == "accept":
            accepted = True
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_event(
                    assert_api,
                    first_events[0],
                    event_type=first_event_type,
                    data={"groupId": group_id, "groupName": group_name, "accepter": user_a},
                )
            device_a.drain_events()
        else:
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_event(
                    assert_api,
                    first_events[0],
                    event_type=first_event_type,
                    data={
                        "groupId": group_id,
                            "decliner": user_a,
                        "reason": "first-decline",
                        "applicant": user_b,
                    },
                )

        second_cmd = (
            Cmd.acceptJoinApplication.value
            if second_action == "accept"
            else Cmd.declineJoinApplication.value
        )
        second_info = {"groupId": group_id, "userId": user_b}
        if second_action == "decline":
            second_info["reason"] = "second-decline"
        with _allure_step("A 执行群组业务操作"):
            second = device_a.call("GroupManager", second_cmd, info=second_info)
        with _allure_step("验证执行群组业务操作返回的错误码与错误文案"):
            assert_api.assert_error(second, code=110, description="is not in the apply list")
        _fetch_group(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            members=[user_b] if accepted else [],
            member_count=2 if accepted else 1,
            style=2,
            device_name="deviceA",
        )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id, device_b=device_b if accepted else None)


@pytest.mark.parametrize(
    ("make_admin", "action"),
    [
        pytest.param(False, "accept", id="member-accept"),
        pytest.param(False, "decline", id="member-decline"),
        pytest.param(
            True,
            "accept",
            marks=pytest.mark.skip(
                reason="known Android SDK bug: admin accepter is reported as group owner",
            ),
            id="admin-accept",
        ),
        pytest.param(True, "decline", id="admin-decline"),
    ],
)
def test_group_join_application_processing_permission_by_role(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    user_c,
    make_admin,
    action,
):
    """普通成员不能处理申请；管理员按原生权限接收并处理申请。"""
    group_id = ""
    group_name = new_group_name(f"application_role_{int(make_admin)}_{action}")
    device_a_is_c = False
    accepted = False
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                device_a,
                assert_api,
                owner=user_a,
                group_name=group_name,
                invite_members=[user_b],
                style=2,
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

        _switch_user(device_a, assert_api, device_name="deviceA", user_id=user_c)
        device_a_is_c = True
        with _allure_step("A 申请加入公开群"):
            request = device_a.call(
                "GroupManager",
                Cmd.requestToJoinPublicGroup.value,
                info={"groupId": group_id, "reason": f"role-{action}"},
            )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_call(
                assert_api,
                request,
                manager="GroupManager",
                cmd=Cmd.requestToJoinPublicGroup.value,
                device="deviceA",
                result=None,
            )
        if make_admin:
            with _allure_step("等待并校验目标业务事件"):
                request_events = collect_group_events(
                    device_b,
                    expected_event_types={"onGroupRequestToJoinReceived"},
                    group_id=group_id,
                    required_all_event_types={"onGroupRequestToJoinReceived"},
                    timeout=10.0,
                )
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_event(
                    assert_api,
                    request_events[0],
                    event_type="onGroupRequestToJoinReceived",
                    data={
                        "groupId": group_id,
                        "groupName": group_name,
                        "applicant": user_c,
                        "reason": f"role-{action}",
                    },
                )
        else:
            with _allure_step("验证 添加群管理员返回的关键字段"):
                assert_no_group_event(
                    device_b,
                    group_id=group_id,
                    event_types={"onGroupRequestToJoinReceived"},
                )

        command = (
            Cmd.acceptJoinApplication.value
            if action == "accept"
            else Cmd.declineJoinApplication.value
        )
        info = {"groupId": group_id, "userId": user_c}
        if action == "decline":
            info["reason"] = "role-decline"
        with _allure_step("B 执行群组业务操作"):
            response = device_b.call("GroupManager", command, info=info)
        if make_admin:
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_call(
                    assert_api,
                    response,
                    manager="GroupManager",
                    cmd=command,
                    device="deviceB",
                    result=None,
                )
            event_type = (
                "onGroupRequestToJoinAccepted"
                if action == "accept"
                else "onGroupRequestToJoinDeclined"
            )
            with _allure_step("等待并校验目标业务事件"):
                result_events = collect_group_events(
                    device_a,
                    expected_event_types={event_type},
                    group_id=group_id,
                    required_all_event_types={event_type},
                    timeout=10.0,
                )
            if action == "accept":
                accepted = True
                with _allure_step("验证群业务状态、事件与关键字段"):
                    _assert_event(
                        assert_api,
                        result_events[0],
                        event_type=event_type,
                        data={"groupId": group_id, "groupName": group_name, "accepter": user_b},
                    )
            else:
                with _allure_step("验证群业务状态、事件与关键字段"):
                    _assert_event(
                        assert_api,
                        result_events[0],
                        event_type=event_type,
                        data={
                            "groupId": group_id,
                                    "decliner": user_b,
                            "reason": "role-decline",
                            "applicant": user_c,
                        },
                    )
        else:
            with _allure_step("验证执行群组业务操作返回的错误码与错误文案"):
                assert_api.assert_error(response, code=603, description="permission")
    finally:
        if device_a_is_c:
            _switch_user(device_a, assert_api, device_name="deviceA", user_id=user_a)
        if group_id:
            _fetch_group(
                device_a,
                assert_api,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                members=([user_c] if accepted else []) if make_admin else [user_b],
                member_count=3 if accepted else 2,
                admins=[user_b] if make_admin else [],
                style=2,
                device_name="deviceA",
            )
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id, device_b=device_b)


@pytest.mark.parametrize("action", ["accept", "decline"], ids=["accept", "decline"])
def test_group_non_member_cannot_process_join_application(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    user_c,
    action,
):
    """非成员不能处理其他用户的有效 pending 申请。"""
    group_id = ""
    group_name = new_group_name(f"application_nonmember_{action}")
    device_a_is_c = False
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
            device_a,
            assert_api,
            applicant_device_name="deviceB",
            group_id=group_id,
            group_name=group_name,
            applicant=user_b,
            reason="nonmember-operator",
        )
        _switch_user(device_a, assert_api, device_name="deviceA", user_id=user_c)
        device_a_is_c = True
        command = (
            Cmd.acceptJoinApplication.value
            if action == "accept"
            else Cmd.declineJoinApplication.value
        )
        info = {"groupId": group_id, "userId": user_b}
        if action == "decline":
            info["reason"] = "nonmember-decline"
        with _allure_step("A 执行群组业务操作"):
            response = device_a.call("GroupManager", command, info=info)
        with _allure_step("验证执行群组业务操作返回的错误码与错误文案"):
            assert_api.assert_error(response, code=602, description="has not joined the group")
        with _allure_step("验证执行群组业务操作返回的响应 result 与关键字段"):
            assert_no_group_event(
                device_b,
                group_id=group_id,
                event_types={"onGroupRequestToJoinAccepted", "onGroupRequestToJoinDeclined"},
            )
    finally:
        if device_a_is_c:
            _switch_user(device_a, assert_api, device_name="deviceA", user_id=user_a)
        if group_id:
            _fetch_group(
                device_a,
                assert_api,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                members=[],
                member_count=1,
                style=2,
                device_name="deviceA",
            )
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)
