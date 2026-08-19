"""Group 入群申请与邀请处理（正常 + 异常）。"""
from __future__ import annotations

from contextlib import nullcontext

import pytest

from src import Cmd, GroupChangeEvent


def _allure_step(name: str):
    try:
        import allure

        return allure.step(name)
    except ImportError:
        return nullcontext()
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


def _assert_event_on_other_endpoints(
    endpoints,
    excluded,
    *,
    group_id: str,
    expected_event_types: set[str],
    required_all_event_types: set[str],
    event_label: str,
) -> None:
    """Consume and require a business event on every topology endpoint except the action endpoint."""
    for endpoint in endpoints:
        if endpoint is excluded:
            continue
        events = collect_group_events(
            endpoint,
            expected_event_types=expected_event_types,
            group_id=group_id,
            required_all_event_types=required_all_event_types,
            timeout=10.0,
        )
        assert events, f"{endpoint.device_name} 未收到{event_label}: {events}"


@pytest.mark.topology("account_a_to_account_b")

def test_group_invitation_explicit_accept_when_auto_accept_disabled(
    assert_api,
    user_a,
    user_b,
    topology,
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
    sender = topology.sender_action_device
    recipient = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    group_id = ""
    accepted = False
    try:
        with _allure_step("B 关闭自动接受群邀请"):
            resp_option = recipient.call(
                "Client",
                Cmd.updateAutoAcceptGroupInvitationSetting.value,
                info={"autoAcceptGroupInvitation": False},
            )
        with _allure_step("验证自动接受群邀请设置已更新"):
            assert_api.assert_response_matches(
                resp_option,
                expected={
                    "manager": "Client",
                    "cmd": Cmd.updateAutoAcceptGroupInvitationSetting.value,
                    "device": recipient.device_name,
                    "result": None,
                },
                ignore_keys={"sequence"},
            )

        group_name = new_group_name("invite_explicit_accept")
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                sender,
                assert_api,
                owner=user_a,
                group_name=group_name,
                invite_members=[user_b],
                invite_need_confirm=True,
                expected_member_count=1,
            )

        with _allure_step("等待并校验目标业务事件"):
            invitation_events = collect_group_events(
                recipient,
                expected_event_types={
                    GroupChangeEvent.ON_INVITATION_RECEIVED.value,
                    "onGroupInvitationReceived",
                },
                group_id=group_id,
                required_all_event_types={"onGroupInvitationReceived"},
                timeout=10.0,
            )
        with _allure_step("接收账号全部在线端同步验证收到邀请事件"):
            _assert_event_on_other_endpoints(
                recipient_devices,
                recipient,
                group_id=group_id,
                expected_event_types={GroupChangeEvent.ON_INVITATION_RECEIVED.value, "onGroupInvitationReceived"},
                required_all_event_types={"onGroupInvitationReceived"},
                event_label="邀请事件",
            )

        with _allure_step("验证群业务状态、事件与关键字段"):
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

        with _allure_step("B 接受入群邀请"):
            resp_accept = recipient.call(
                "GroupManager",
                Cmd.acceptInvitationFromGroup.value,
                info={"groupId": group_id, "inviter": user_a},
            )
        with _allure_step("验证接受入群邀请返回的响应 result 与关键字段"):
            assert_group_snapshot(
                assert_api,
                resp_accept,
                cmd=Cmd.acceptInvitationFromGroup.value,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                member_count_value=2,
                permission_type=0,
                device=recipient.device_name,
            )
        accepted = True

        accepted_event_types = {
            "onGroupInvitationAccepted",
            "onGroupMembersJoined",
        }
        with _allure_step("等待并校验目标业务事件"):
            accepted_events = collect_group_events(
                sender,
                expected_event_types=accepted_event_types,
                group_id=group_id,
                required_all_event_types=accepted_event_types,
                timeout=10.0,
            )
        accepted_by_type = {event["eventType"]: event for event in accepted_events}
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_exact_group_event(
                assert_api,
                accepted_by_type["onGroupInvitationAccepted"],
                event_type="onGroupInvitationAccepted",
                data={"groupId": group_id, "invitee": user_b, "reason": ""},
            )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_exact_group_event(
                assert_api,
                accepted_by_type["onGroupMembersJoined"],
                event_type="onGroupMembersJoined",
                data={"groupId": group_id, "userIds": [user_b]},
            )
        with _allure_step("发送账号全部在线端同步验证邀请接受和成员加入事件"):
            _assert_event_on_other_endpoints(
                sender_devices,
                sender,
                group_id=group_id,
                expected_event_types=accepted_event_types,
                required_all_event_types=accepted_event_types,
                event_label="邀请接受/成员加入事件",
            )
        # B 接受邀请入群后，B 端会收到成员加入事件（onGroupMembersJoined），
        # 但不会收到"邀请被接受"通知（那是发给邀请方 A 的）。
        with _allure_step("验证接受入群邀请返回的响应 result 与关键字段"):
            assert_no_group_event(
                recipient,
                group_id=group_id,
                event_types={"onGroupInvitationAccepted"},
            )

        with _allure_step("A 查询服务端群详情"):
            resp_server = sender.call(
                "GroupManager",
                Cmd.getGroupSpecificationFromServer.value,
                info={"groupId": group_id},
            )
        with _allure_step("验证查询服务端群详情返回的关键字段"):
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
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(sender, assert_api, group_id, device_b=recipient if accepted else None, device_name=sender.device_name)
        with _allure_step("测试后置：恢复 B 的自动接受群邀请设置"):
            resp_restore = recipient.call(
                "Client",
                Cmd.updateAutoAcceptGroupInvitationSetting.value,
                info={"autoAcceptGroupInvitation": True},
            )
        with _allure_step("测试后置：验证 API 响应的关键字段与错误语义"):
            assert_api.assert_response_matches(
                resp_restore,
                expected={
                    "manager": "Client",
                    "cmd": Cmd.updateAutoAcceptGroupInvitationSetting.value,
                    "device": recipient.device_name,
                    "result": None,
                },
                ignore_keys={"sequence"},
            )


@pytest.mark.skip(
    reason="known Android adapter bug: declineInvitationFromGroup drops inviter",
)
@pytest.mark.topology("account_a_to_account_b")
def test_group_invitation_explicit_decline_when_auto_accept_disabled(
    assert_api,
    user_a,
    user_b,
    topology,
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
    sender = topology.sender_action_device
    recipient = topology.recipient_action_device
    recipient_devices = topology.recipient_devices
    group_id = ""
    group_name = new_group_name("invite_explicit_decline")
    decline_reason = "explicit-decline"
    joined_event_types = {"onGroupMembersJoined"}  # 5.0 只派发批量事件
    try:
        with _allure_step("B 关闭自动接受群邀请"):
            resp_option = recipient.call(
                "Client",
                Cmd.updateAutoAcceptGroupInvitationSetting.value,
                info={"autoAcceptGroupInvitation": False},
            )
        with _allure_step("验证自动接受群邀请设置已更新"):
            assert_api.assert_response_matches(
                resp_option,
                expected={
                    "manager": "Client",
                    "cmd": Cmd.updateAutoAcceptGroupInvitationSetting.value,
                    "device": recipient.device_name,
                    "result": None,
                },
                ignore_keys={"sequence"},
            )

        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                sender,
                assert_api,
                owner=user_a,
                group_name=group_name,
                invite_members=[user_b],
                invite_need_confirm=True,
                expected_member_count=1,
            )
        with _allure_step("等待并校验目标业务事件"):
            invitation_events = collect_group_events(
                recipient,
                expected_event_types={"onGroupInvitationReceived"},
                group_id=group_id,
                required_all_event_types={"onGroupInvitationReceived"},
                timeout=10.0,
            )
        with _allure_step("接收账号全部在线端同步验证收到邀请事件"):
            _assert_event_on_other_endpoints(
                recipient_devices,
                recipient,
                group_id=group_id,
                expected_event_types={"onGroupInvitationReceived"},
                required_all_event_types={"onGroupInvitationReceived"},
                event_label="邀请事件",
            )

        with _allure_step("验证群业务状态、事件与关键字段"):
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

        with _allure_step("B 拒绝入群邀请"):
            resp_decline = recipient.call(
                "GroupManager",
                Cmd.declineInvitationFromGroup.value,
                info={"groupId": group_id, "inviter": user_a, "reason": decline_reason},
            )
        with _allure_step("验证拒绝入群邀请返回的响应 result 与关键字段"):
            assert_api.assert_response_matches(
                resp_decline,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.declineInvitationFromGroup.value,
                    "device": recipient.device_name,
                    "result": None,
                },
                ignore_keys={"sequence"},
            )

        declined_events: list[dict] = []
        declined_event_error: AssertionError | None = None
        try:
            with _allure_step("等待并校验目标业务事件"):
                declined_events = collect_group_events(
                    sender,
                    expected_event_types={"onGroupInvitationDeclined"},
                    group_id=group_id,
                    required_all_event_types={"onGroupInvitationDeclined"},
                    timeout=10.0,
                )
        except AssertionError as error:
            declined_event_error = error
        if declined_events:
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_exact_group_event(
                    assert_api,
                    declined_events[0],
                    event_type="onGroupInvitationDeclined",
                    data={"groupId": group_id, "invitee": user_b, "reason": decline_reason},
                )
        with _allure_step("验证拒绝入群邀请返回的响应 result 与关键字段"):
            assert_no_group_event(sender, group_id=group_id, event_types=joined_event_types)
        with _allure_step("验证拒绝入群邀请返回的响应 result 与关键字段"):
            assert_no_group_event(recipient, group_id=group_id, event_types=joined_event_types)

        with _allure_step("A 查询服务端群详情"):
            resp_server = sender.call(
                "GroupManager",
                Cmd.getGroupSpecificationFromServer.value,
                info={"groupId": group_id},
            )
        with _allure_step("验证查询服务端群详情返回的关键字段"):
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
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(sender, assert_api, group_id, device_name=sender.device_name)
        with _allure_step("测试后置：恢复 B 的自动接受群邀请设置"):
            resp_restore = recipient.call(
                "Client",
                Cmd.updateAutoAcceptGroupInvitationSetting.value,
                info={"autoAcceptGroupInvitation": True},
            )
        with _allure_step("测试后置：验证 API 响应的关键字段与错误语义"):
            assert_api.assert_response_matches(
                resp_restore,
                expected={
                    "manager": "Client",
                    "cmd": Cmd.updateAutoAcceptGroupInvitationSetting.value,
                    "device": recipient.device_name,
                    "result": None,
                },
                ignore_keys={"sequence"},
            )


@pytest.mark.topology("account_a_to_account_b")
def test_group_invitation_auto_accept_when_confirmation_required(
    assert_api,
    user_a,
    user_b,
    topology,
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
    sender = topology.sender_action_device
    recipient = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    group_id = ""
    joined = False
    group_name = new_group_name("invite_auto_accept")
    try:
        with _allure_step("B 开启自动接受群邀请"):
            resp_option = recipient.call(
                "Client",
                Cmd.updateAutoAcceptGroupInvitationSetting.value,
                info={"autoAcceptGroupInvitation": True},
            )
        with _allure_step("验证自动接受群邀请设置已更新"):
            assert_api.assert_response_matches(
                resp_option,
                expected={
                    "manager": "Client",
                    "cmd": Cmd.updateAutoAcceptGroupInvitationSetting.value,
                    "device": recipient.device_name,
                    "result": None,
                },
                ignore_keys={"sequence"},
            )

        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                sender,
                assert_api,
                owner=user_a,
                group_name=group_name,
                invite_members=[user_b],
                invite_need_confirm=True,
                expected_member_count=1,
            )
        joined = True

        with _allure_step("等待并校验目标业务事件"):
            auto_events = collect_group_events(
                recipient,
                expected_event_types={"onGroupAutoAcceptInvitation"},
                group_id=group_id,
                required_all_event_types={"onGroupAutoAcceptInvitation"},
                timeout=10.0,
            )
        with _allure_step("接收账号全部在线端同步验证成员加入事件"):
            # 5.0 实测：onGroupAutoAcceptInvitation 只回投到设置账号的主端，不同步副端；
            # 副端通过成员加入事件 onGroupMembersJoined（广播到全部在线端）验证 auto-accept 生效。
            _assert_event_on_other_endpoints(
                recipient_devices,
                recipient,
                group_id=group_id,
                expected_event_types={"onGroupMembersJoined"},
                required_all_event_types={"onGroupMembersJoined"},
                event_label="成员加入事件",
            )

        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_exact_group_event(
                assert_api,
                auto_events[0],
                event_type="onGroupAutoAcceptInvitation",
                data={"groupId": group_id, "inviter": user_a, "inviteMessage": ""},
            )

        owner_event_types = {
            "onGroupInvitationAccepted",
            "onGroupMembersJoined",
        }
        with _allure_step("等待并校验目标业务事件"):
            owner_events = collect_group_events(
                sender,
                expected_event_types=owner_event_types,
                group_id=group_id,
                required_all_event_types=owner_event_types,
                timeout=10.0,
            )
        owner_by_type = {event["eventType"]: event for event in owner_events}
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_exact_group_event(
                assert_api,
                owner_by_type["onGroupInvitationAccepted"],
                event_type="onGroupInvitationAccepted",
                data={"groupId": group_id, "invitee": user_b, "reason": ""},
            )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_exact_group_event(
                assert_api,
                owner_by_type["onGroupMembersJoined"],
                event_type="onGroupMembersJoined",
                data={"groupId": group_id, "userIds": [user_b]},
            )
        with _allure_step("发送账号全部在线端同步验证邀请接受和成员加入事件"):
            _assert_event_on_other_endpoints(
                sender_devices,
                sender,
                group_id=group_id,
                expected_event_types=owner_event_types,
                required_all_event_types=owner_event_types,
                event_label="邀请接受/成员加入事件",
            )
        # 邀请被接受通知只发给邀请方 A；B 端不应收到 onGroupInvitationAccepted
        # （B 端会收到 onGroupMembersJoined，故只对邀请接受事件断言 no-event）
        with _allure_step("接收账号全部在线端不收到邀请接受通知"):
            for endpoint in recipient_devices:
                assert_no_group_event(endpoint, group_id=group_id, event_types={"onGroupInvitationAccepted"})

        with _allure_step("A 查询服务端群详情"):
            resp_server = sender.call(
                "GroupManager",
                Cmd.getGroupSpecificationFromServer.value,
                info={"groupId": group_id},
            )
        with _allure_step("验证查询服务端群详情返回的关键字段"):
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
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(sender, assert_api, group_id, device_b=recipient if joined else None, device_name=sender.device_name)


@pytest.mark.topology("account_a_to_account_b")
def test_group_request_to_join_and_accept_success(assert_api, user_a, user_b, topology):
    """成员申请入群并由群主同意：申请/同意事件同步到收发账号全部在线端。"""
    owner = topology.sender_action_device
    applicant = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    group_id = ""
    group_name = new_group_name("public_need_approval")
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                owner,
                assert_api,
                owner=user_a,
                group_name=group_name,
                invite_members=[],
                style=2,
            )

        with _allure_step("B 申请加入公开群"):
            resp_request = applicant.call(
                "GroupManager",
                Cmd.requestToJoinPublicGroup.value,
                info={"groupId": group_id, "reason": "auto-apply-accept"},
            )
        with _allure_step("验证申请加入公开群返回的响应 result 与关键字段"):
            assert_api.assert_response_matches(
                resp_request,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.requestToJoinPublicGroup.value,
                    "device": applicant.device_name,
                    "result": None,
                },
                ignore_keys={"sequence"},
            )

        with _allure_step("等待并校验目标业务事件"):
            owner_request_events = collect_group_events(
                owner,
                expected_event_types={
                    GroupChangeEvent.ON_REQUEST_TO_JOIN_RECEIVED.value,
                    "onGroupRequestToJoinReceived",
                    "onGroupRequestToJoinReceived",
                },
                group_id=group_id,
                required_all_event_types={"onGroupRequestToJoinReceived"},
                timeout=10.0,
            )
        with _allure_step("验证申请加入公开群返回的响应 result 与关键字段"):
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
        with _allure_step("发送账号全部在线端同步验证入群申请事件"):
            _assert_event_on_other_endpoints(
                sender_devices,
                owner,
                group_id=group_id,
                expected_event_types={GroupChangeEvent.ON_REQUEST_TO_JOIN_RECEIVED.value, "onGroupRequestToJoinReceived"},
                required_all_event_types={"onGroupRequestToJoinReceived"},
                event_label="入群申请事件",
            )

        with _allure_step("A 同意入群申请"):
            resp_accept = owner.call(
                "GroupManager",
                Cmd.acceptJoinApplication.value,
                info={"groupId": group_id, "userId": user_b},
            )
        with _allure_step("验证同意入群申请返回的响应 result 与关键字段"):
            assert_api.assert_response_matches(
                resp_accept,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.acceptJoinApplication.value,
                    "device": owner.device_name,
                    "result": None,
                },
                ignore_keys={"sequence"},
            )

        with _allure_step("等待并校验目标业务事件"):
            applicant_accept_events = collect_group_events(
                applicant,
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
        with _allure_step("接收账号全部在线端同步验证申请通过事件"):
            _assert_event_on_other_endpoints(
                recipient_devices,
                applicant,
                group_id=group_id,
                expected_event_types={
                    GroupChangeEvent.ON_REQUEST_TO_JOIN_ACCEPTED.value,
                    GroupChangeEvent.ON_MEMBER_JOINED.value,
                    "onGroupRequestToJoinAccepted",
                    "onGroupMemberJoined",
                },
                required_all_event_types={"onGroupRequestToJoinAccepted"},
                event_label="申请通过事件",
            )

        with _allure_step("验证同意入群申请返回的响应 result 与关键字段"):
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

        owner_joined_event_types = {"onGroupMembersJoined"}  # 5.0 只派发批量事件
        with _allure_step("等待并校验目标业务事件"):
            owner_joined_events = collect_group_events(
                owner,
                expected_event_types=owner_joined_event_types,
                group_id=group_id,
                required_all_event_types=owner_joined_event_types,
                timeout=10.0,
            )
        owner_joined_by_type = {event["eventType"]: event for event in owner_joined_events}
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_exact_group_event(
                assert_api,
                owner_joined_by_type["onGroupMembersJoined"],
                event_type="onGroupMembersJoined",
                data={"groupId": group_id, "userIds": [user_b]},
            )
        with _allure_step("发送账号全部在线端同步验证成员加入事件"):
            _assert_event_on_other_endpoints(
                sender_devices,
                owner,
                group_id=group_id,
                expected_event_types=owner_joined_event_types,
                required_all_event_types=owner_joined_event_types,
                event_label="成员加入事件",
            )
        with _allure_step("验证同意入群申请返回的响应 result 与关键字段"):
            for endpoint in recipient_devices:
                assert_no_group_event(endpoint, group_id=group_id, event_types=owner_joined_event_types)

        with _allure_step("A 查询服务端群详情"):
            server = owner.call(
                "GroupManager",
                Cmd.getGroupSpecificationFromServer.value,
                info={"groupId": group_id},
            )
        with _allure_step("验证查询服务端群详情返回的关键字段"):
            assert_group_snapshot(
                assert_api,
                server,
                cmd=Cmd.getGroupSpecificationFromServer.value,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                member_count_value=2,
                member_list_value=[user_b],
                # 官方迁移表 6.1：style=2（公开需审批）allowInvites=false
                is_member_allow_to_invite=False,
                is_public=True,
                join_approval_required=True,
            )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(owner, assert_api, group_id)


@pytest.mark.topology("account_a_to_account_b")
def test_group_request_to_join_and_decline_success(assert_api, user_a, user_b, topology):
    """成员申请入群并由群主拒绝：申请/拒绝事件同步到收发账号全部在线端。"""
    owner = topology.sender_action_device
    applicant = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    group_id = ""
    group_name = new_group_name("public_need_decline")
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                owner,
                assert_api,
                owner=user_a,
                group_name=group_name,
                invite_members=[],
                style=2,
            )

        with _allure_step("B 申请加入公开群"):
            resp_request = applicant.call(
                "GroupManager",
                Cmd.requestToJoinPublicGroup.value,
                info={"groupId": group_id, "reason": "auto-apply-decline"},
            )
        with _allure_step("验证申请加入公开群返回的响应 result 与关键字段"):
            assert_api.assert_response_matches(
                resp_request,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.requestToJoinPublicGroup.value,
                    "device": applicant.device_name,
                    "result": None,
                },
                ignore_keys={"sequence"},
            )

        with _allure_step("等待并校验目标业务事件"):
            owner_request_events = collect_group_events(
                owner,
                expected_event_types={
                    GroupChangeEvent.ON_REQUEST_TO_JOIN_RECEIVED.value,
                    "onGroupRequestToJoinReceived",
                    "onGroupRequestToJoinReceived",
                },
                group_id=group_id,
                required_all_event_types={"onGroupRequestToJoinReceived"},
                timeout=10.0,
            )
        with _allure_step("验证申请加入公开群返回的响应 result 与关键字段"):
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
        with _allure_step("发送账号全部在线端同步验证入群申请事件"):
            _assert_event_on_other_endpoints(
                sender_devices,
                owner,
                group_id=group_id,
                expected_event_types={GroupChangeEvent.ON_REQUEST_TO_JOIN_RECEIVED.value, "onGroupRequestToJoinReceived"},
                required_all_event_types={"onGroupRequestToJoinReceived"},
                event_label="入群申请事件",
            )

        with _allure_step("A 拒绝入群申请"):
            resp_decline = owner.call(
                "GroupManager",
                Cmd.declineJoinApplication.value,
                info={"groupId": group_id, "userId": user_b, "reason": "auto-reject"},
            )
        with _allure_step("验证拒绝入群申请返回的响应 result 与关键字段"):
            assert_api.assert_response_matches(
                resp_decline,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.declineJoinApplication.value,
                    "device": owner.device_name,
                    "result": None,
                },
                ignore_keys={"sequence"},
            )

        with _allure_step("等待并校验目标业务事件"):
            applicant_decline_events = collect_group_events(
                applicant,
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
        with _allure_step("接收账号全部在线端同步验证申请拒绝事件"):
            _assert_event_on_other_endpoints(
                recipient_devices,
                applicant,
                group_id=group_id,
                expected_event_types={
                    GroupChangeEvent.ON_REQUEST_TO_JOIN_DECLINED.value,
                    "onGroupRequestToJoinDeclined",
                },
                required_all_event_types={"onGroupRequestToJoinDeclined"},
                event_label="申请拒绝事件",
            )

        with _allure_step("验证拒绝入群申请返回的响应 result 与关键字段"):
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

        joined_event_types = {"onGroupMembersJoined"}  # 5.0 只派发批量事件
        with _allure_step("验证拒绝入群申请返回的响应 result 与关键字段"):
            for endpoint in (*sender_devices, *recipient_devices):
                assert_no_group_event(endpoint, group_id=group_id, event_types=joined_event_types)
        with _allure_step("A 查询服务端群详情"):
            server = owner.call(
                "GroupManager",
                Cmd.getGroupSpecificationFromServer.value,
                info={"groupId": group_id},
            )
        with _allure_step("验证查询服务端群详情返回的关键字段"):
            assert_group_snapshot(
                assert_api,
                server,
                cmd=Cmd.getGroupSpecificationFromServer.value,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                member_count_value=1,
                member_list_value=[],
                # 官方迁移表 6.1：style=2（公开需审批）allowInvites=false
                is_member_allow_to_invite=False,
                is_public=True,
                join_approval_required=True,
            )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(owner, assert_api, group_id)


def test_group_request_to_join_public_group_nonexistent_group(device_b, assert_api):
    with _allure_step("B 申请加入公开群"):
        resp = device_b.call(
            "GroupManager",
            Cmd.requestToJoinPublicGroup.value,
            info={"groupId": _NONEXISTENT_GROUP_ID, "reason": "auto-reason"},
        )
    with _allure_step("验证申请加入公开群返回的错误码与错误文案"):
        assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_accept_join_application_nonexistent_group(device_a, assert_api, user_b):
    with _allure_step("A 同意入群申请"):
        resp = device_a.call(
            "GroupManager",
            Cmd.acceptJoinApplication.value,
            info={"groupId": _NONEXISTENT_GROUP_ID, "userId": user_b},
        )
    with _allure_step("验证同意入群申请返回的错误码与错误文案"):
        assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_decline_join_application_nonexistent_group(device_a, assert_api, user_b):
    with _allure_step("A 拒绝入群申请"):
        resp = device_a.call(
            "GroupManager",
            Cmd.declineJoinApplication.value,
            info={"groupId": _NONEXISTENT_GROUP_ID, "userId": user_b, "reason": "auto-reject"},
        )
    with _allure_step("验证拒绝入群申请返回的错误码与错误文案"):
        assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_accept_join_application_nonexistent_user(device_a, assert_api, user_a):
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                device_a,
                assert_api,
                owner=user_a,
                group_name=new_group_name("accept_nonexist_user"),
                invite_members=[],
                style=2,
            )
        with _allure_step("A 同意入群申请"):
            resp = device_a.call(
                "GroupManager",
                Cmd.acceptJoinApplication.value,
                info={"groupId": group_id, "userId": _NONEXISTENT_USER},
            )
        with _allure_step("验证同意入群申请返回的错误码与错误文案"):
            assert_api.assert_error(resp, code=600, description="doesn't exist")
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)


def test_group_accept_invitation_from_group_without_pending_invite(device_b, assert_api):
    with _allure_step("B 接受入群邀请"):
        resp = device_b.call(
            "GroupManager",
            Cmd.acceptInvitationFromGroup.value,
            info={"groupId": _NONEXISTENT_GROUP_ID, "inviter": "owner_x"},
        )
    with _allure_step("验证接受入群邀请返回的错误码与错误文案"):
        assert_api.assert_error(resp, code=600, description="does not exist")


def test_group_decline_invitation_from_group_without_pending_invite(device_b, assert_api):
    with _allure_step("B 拒绝入群邀请"):
        resp = device_b.call(
            "GroupManager",
            Cmd.declineInvitationFromGroup.value,
            info={"groupId": _NONEXISTENT_GROUP_ID, "inviter": "owner_x", "reason": "auto-reject"},
        )
    with _allure_step("验证拒绝入群邀请返回的错误码与错误文案"):
        assert_api.assert_error(resp, code=600, description="does not exist")
