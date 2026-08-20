"""Group 入群邀请 pending、inviter 与重复处理状态矩阵。"""
from __future__ import annotations

import pytest
from tests.group.allure_helpers import _allure_step

from src import Cmd
from tests.group.group_helpers import (
    assert_group_members_from_server,
    assert_group_snapshot,
    assert_no_group_event,
    collect_group_events,
    create_group,
    destroy_group,
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


def _set_auto_accept(device_b, assert_api, value: bool) -> None:
    response = device_b.call(
        "Client",
        Cmd.updateAutoAcceptGroupInvitationSetting.value,
        info={"autoAcceptGroupInvitation": value},
    )
    _assert_call(
        assert_api,
        response,
        manager="Client",
        cmd=Cmd.updateAutoAcceptGroupInvitationSetting.value,
        device="deviceB",
        result=None,
    )


def _create_pending_invitation(
    device_a,
    device_b,
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
    invitation_events = collect_group_events(
        device_b,
        expected_event_types={"onGroupInvitationReceived"},
        group_id=group_id,
        required_all_event_types={"onGroupInvitationReceived"},
        timeout=10.0,
    )
    assert_api.assert_response_matches(
        invitation_events[0],
        expected={
            "type": "event",
            "eventType": "onGroupInvitationReceived",
            "data": {
                "groupId": group_id,
                "groupName": group_name,
                "inviter": user_a,
                "reason": "",
            },
        },
        ignore_keys={"timestamp", "sequence"},
    )
    return group_id


def _fetch_group(device_a, assert_api, *, group_id: str, group_name: str,
                 owner: str, members: list[str]) -> None:
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
        owner=owner,
        member_count_value=1 + len(members),
    )
    assert_group_members_from_server(
        device_a,
        assert_api,
        group_id=group_id,
        device_name="deviceA",
        expected_members=members,
        err_prefix="邀请状态",
    )


@pytest.mark.parametrize(
    "action",
    [Cmd.acceptInvitationFromGroup.value, Cmd.declineInvitationFromGroup.value],
    ids=["accept", "decline"],
)

def test_group_invitation_valid_group_without_pending_is_rejected(
    device_a,
    device_b,
    assert_api,
    user_a,
    action,
):
    """有效群中没有待处理邀请时，接受和拒绝都返回稳定错误。"""
    group_id = ""
    group_name = new_group_name(f"invitation_no_pending_{action}")
    try:
        _set_auto_accept(device_b, assert_api, False)
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                device_a,
                assert_api,
                owner=user_a,
                group_name=group_name,
                invite_members=[],
                style=0,
                invite_need_confirm=True,
            )
        info = {"groupId": group_id, "inviter": user_a}
        if action == Cmd.declineInvitationFromGroup.value:
            info["reason"] = "no-pending"
        with _allure_step("B 执行群组业务操作"):
            response = device_b.call("GroupManager", action, info=info)
        with _allure_step("验证执行群组业务操作返回的错误码与错误文案"):
            assert_api.assert_error(response, code=603, description="is not in the invitee list")
        _fetch_group(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            members=[],
        )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)
        _set_auto_accept(device_b, assert_api, True)


@pytest.mark.parametrize("action", ["accept", "decline"], ids=["accept", "decline"])
@pytest.mark.skip(
    reason="known inviter handling gap; decline path also has Android adapter key mismatch",
)
def test_group_invitation_wrong_inviter_does_not_consume_pending(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    user_c,
    action,
):
    """错误 inviter 处理邀请应失败，随后正确 inviter 仍可接受同一 pending。"""
    group_id = ""
    group_name = new_group_name(f"invitation_wrong_inviter_{action}")
    accepted = False
    try:
        _set_auto_accept(device_b, assert_api, False)
        with _allure_step("测试准备：创建测试群并建立成员前置"):
            group_id = _create_pending_invitation(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                group_name=group_name,
            )
        command = (
            Cmd.acceptInvitationFromGroup.value
            if action == "accept"
            else Cmd.declineInvitationFromGroup.value
        )
        info = {"groupId": group_id, "inviter": user_c}
        if action == "decline":
            info["reason"] = "wrong-inviter"
        with _allure_step("B 执行群组业务操作"):
            wrong = device_b.call("GroupManager", command, info=info)
        wrong_result = wrong.get("result")
        wrong_inviter_rejected = (
            isinstance(wrong_result, dict)
            and wrong_result.get("code") == 603
            and "inviter" in str(wrong_result.get("description", ""))
        )

        with _allure_step("B 接受入群邀请"):
            correct = device_b.call(
                "GroupManager",
                Cmd.acceptInvitationFromGroup.value,
                info={"groupId": group_id, "inviter": user_a},
            )
        if not wrong_inviter_rejected:
            if action == "accept":
                accepted = True
                with _allure_step("验证接受入群邀请返回的错误码与错误文案"):
                    assert_api.assert_error(correct, code=601, description="already joined")
                actual_members = [user_b]
            else:
                with _allure_step("验证接受入群邀请返回的错误码与错误文案"):
                    assert_api.assert_error(correct, code=603, description="is not in the invitee list")
                actual_members = []
            _fetch_group(
                device_a,
                assert_api,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                members=actual_members,
            )
            raise AssertionError(
                "邀请接口未校验 inviter: "
                f"action={action}, expected=错误 inviter 不得处理或消耗邀请, "
                f"actual=错误 inviter 已处理邀请且正确 inviter 随后无法接受"
            )
        result = correct.get("result")
        with _allure_step("验证接受入群邀请返回的响应 result 与关键字段"):
            assert isinstance(result, dict), correct
        with _allure_step("验证接受入群邀请返回的响应 result 与关键字段"):
            assert result.get("groupId") == group_id, correct
        accepted = True
        with _allure_step("等待并校验目标业务事件"):
            accepted_events = collect_group_events(
                device_a,
                expected_event_types={
                    "onGroupInvitationAccepted",
                    "onGroupMembersJoined",
                    "onGroupMemberJoined",
                },
                group_id=group_id,
                required_all_event_types={
                    "onGroupInvitationAccepted",
                    "onGroupMembersJoined",
                },  # 5.0 只派发批量事件（无单数 onGroupMemberJoined）
                timeout=10.0,
            )
        by_type = {event["eventType"]: event for event in accepted_events}
        with _allure_step("验证接受入群邀请返回的响应 result 与关键字段"):
            assert_api.assert_response_matches(
                by_type["onGroupInvitationAccepted"],
                expected={
                    "type": "event",
                    "eventType": "onGroupInvitationAccepted",
                    "data": {"groupId": group_id, "invitee": user_b, "reason": ""},
                },
                ignore_keys={"timestamp", "sequence"},
            )
        _fetch_group(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            members=[user_b],
        )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id, device_b=device_b if accepted else None)
        _set_auto_accept(device_b, assert_api, True)


@pytest.mark.parametrize(
    ("first_action", "second_action"),
    [
        pytest.param("accept", "accept", id="accept-twice"),
        pytest.param("decline", "decline", id="decline-twice"),
        pytest.param("accept", "decline", id="accept-then-decline"),
        pytest.param("decline", "accept", id="decline-then-accept"),
    ],
)
def test_group_invitation_cannot_be_processed_twice(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    first_action,
    second_action,
):
    """邀请首次处理后 pending 消失，重复或反向处理应失败且不改变首次结果。"""
    group_id = ""
    group_name = new_group_name(f"invitation_{first_action}_{second_action}")
    accepted = False
    try:
        _set_auto_accept(device_b, assert_api, False)
        with _allure_step("测试准备：创建测试群并建立成员前置"):
            group_id = _create_pending_invitation(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                group_name=group_name,
            )
        first_cmd = (
            Cmd.acceptInvitationFromGroup.value
            if first_action == "accept"
            else Cmd.declineInvitationFromGroup.value
        )
        first_info = {"groupId": group_id, "inviter": user_a}
        if first_action == "decline":
            first_info["reason"] = "first-decline"
        with _allure_step("B 执行群组业务操作"):
            first = device_b.call("GroupManager", first_cmd, info=first_info)
        if first_action == "accept":
            result = first.get("result")
            with _allure_step("验证执行群组业务操作返回的响应 result 与关键字段"):
                assert isinstance(result, dict), first
            with _allure_step("验证执行群组业务操作返回的响应 result 与关键字段"):
                assert result.get("groupId") == group_id, first
            accepted = True
            with _allure_step("等待并校验目标业务事件"):
                collect_group_events(
                    device_a,
                    expected_event_types={
                        "onGroupInvitationAccepted",
                        "onGroupMembersJoined",
                        "onGroupMemberJoined",
                    },
                    group_id=group_id,
                    required_all_event_types={
                        "onGroupInvitationAccepted",
                        "onGroupMembersJoined",
                    },  # 5.0 只发复数事件
                    timeout=10.0,
                )
        else:
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_call(
                    assert_api,
                    first,
                    manager="GroupManager",
                    cmd=Cmd.declineInvitationFromGroup.value,
                    device="deviceB",
                    result=None,
                )
            with _allure_step("验证执行群组业务操作返回的响应 result 与关键字段"):
                assert_no_group_event(
                    device_a,
                    group_id=group_id,
                    event_types={"onGroupMembersJoined"},  # 5.0 只派发批量事件
                )

        second_cmd = (
            Cmd.acceptInvitationFromGroup.value
            if second_action == "accept"
            else Cmd.declineInvitationFromGroup.value
        )
        second_info = {"groupId": group_id, "inviter": user_a}
        if second_action == "decline":
            second_info["reason"] = "second-decline"
        with _allure_step("B 执行群组业务操作"):
            second = device_b.call("GroupManager", second_cmd, info=second_info)
        if accepted:
            with _allure_step("验证执行群组业务操作返回的错误码与错误文案"):
                assert_api.assert_error(second, code=601, description="already joined")
        else:
            with _allure_step("验证执行群组业务操作返回的错误码与错误文案"):
                assert_api.assert_error(second, code=603, description="is not in the invitee list")
        _fetch_group(
            device_a,
            assert_api,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            members=[user_b] if accepted else [],
        )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id, device_b=device_b if accepted else None)
        _set_auto_accept(device_b, assert_api, True)
