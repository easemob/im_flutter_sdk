"""Group lifecycle 正常链路。"""
from __future__ import annotations

import pytest
from contextlib import nullcontext

from src import Cmd, GroupChangeEvent
from tests.group.group_helpers import (
    assert_group_events,
    assert_group_snapshot,
    collect_group_events,
    create_group,
    destroy_group,
    new_group_name,
)


def _allure_step(name: str):
    try:
        import allure

        return allure.step(name)
    except ImportError:
        return nullcontext()

pytestmark = [pytest.mark.client, pytest.mark.group, pytest.mark.agorachat1_4_0]


@pytest.mark.topology("account_a_to_account_b")

def test_group_create_group(topology, assert_api):
    """
    多端拓扑：A 建群并邀请 B；邀请/自动接受事件同步到 B 全部在线端，成员加入事件同步到 A 全部在线端。
    """
    sender = topology.sender_action_device
    recipients = topology.recipient_devices
    owner_user = topology.sender_user
    member_user = topology.recipient_user

    group_name = new_group_name("create")
    group_id = ""
    try:
        with _allure_step(f"{sender.device_name} 建群并邀请 {member_user}"):
            group_id, _ = create_group(
                sender,
                assert_api,
                owner=owner_user,
                group_name=group_name,
                invite_members=[member_user],
            )
        with _allure_step("B 全部在线端收到邀请/自动接受事件"):
            for endpoint in recipients:
                expected_events = {
                    GroupChangeEvent.ON_INVITATION_RECEIVED.value,
                    GroupChangeEvent.ON_AUTO_ACCEPT_INVITATION.value,
                    "onGroupAutoAcceptInvitation",
                    "onGroupWhiteListRemoved",
                    "onGroupMemberJoined",
                }
                required_events = {
                    "onGroupAutoAcceptInvitation",
                }
                events = collect_group_events(
                    endpoint,
                    expected_event_types=expected_events,
                    group_id=group_id,
                    allow_missing_group_id=True,
                    required_all_event_types=required_events,
                    timeout=10.0,
                )
                assert_group_events(
                    assert_api,
                    events,
                    expected_event_types=expected_events,
                    group_id=group_id,
                    allow_missing_group_id=True,
                    required_all_event_types=required_events,
                    expected_inviter=owner_user,
                    expected_member=member_user,
                )
        with _allure_step("A 全部在线端收到成员加入事件"):
            for endpoint in topology.sender_devices:
                owner_events = collect_group_events(
                    endpoint,
                    expected_event_types={
                        "onGroupMembersJoined",
                        "onGroupMemberJoined",
                    },
                    group_id=group_id,
                    required_all_event_types={"onGroupMembersJoined"},  # 5.0 只派发批量事件（无单数 onGroupMemberJoined）
                    timeout=10.0,
                )
                assert_group_events(
                    assert_api,
                    owner_events,
                    expected_event_types={
                        "onGroupMembersJoined",
                        "onGroupMemberJoined",
                    },
                    group_id=group_id,
                    required_all_event_types={"onGroupMembersJoined"},  # 5.0 只派发批量事件（无单数 onGroupMemberJoined）
                    expected_member=member_user,
                )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(sender, assert_api, group_id, device_b=topology.recipient_action_device)


@pytest.mark.topology("account_a_to_account_b")
def test_group_get_group(topology, assert_api):
    """
    多端拓扑：A 建群并邀请 B；A 的主端和副端先消费成员同步事件，
    再分别查询本地群缓存，验证多设备本地状态一致。
    """
    sender = topology.sender_action_device
    owner_user = topology.sender_user
    member_user = topology.recipient_user

    group_name = new_group_name("local")
    group_id = ""
    try:
        with _allure_step(f"{sender.device_name} 建群并邀请 {member_user}"):
            group_id, _ = create_group(
                sender,
                assert_api,
                owner=owner_user,
                group_name=group_name,
                invite_members=[member_user],
            )
        with _allure_step("A 全部在线端消费成员加入同步事件"):
            for endpoint in topology.sender_devices:
                owner_events = collect_group_events(
                    endpoint,
                    expected_event_types={
                        "onGroupMembersJoined",
                        "onGroupMemberJoined",
                    },
                    group_id=group_id,
                    required_all_event_types={"onGroupMembersJoined"},
                    timeout=10.0,
                )
                assert_group_events(
                    assert_api,
                    owner_events,
                    expected_event_types={
                        "onGroupMembersJoined",
                        "onGroupMemberJoined",
                    },
                    group_id=group_id,
                    required_all_event_types={"onGroupMembersJoined"},
                    expected_member=member_user,
                )
        with _allure_step("A 全部在线端查询本地群快照一致"):
            for endpoint in topology.sender_devices:
                resp_get = endpoint.call("GroupManager", Cmd.getGroupWithId.value, info={"groupId": group_id})
                assert_group_snapshot(
                    assert_api,
                    resp_get,
                    cmd=Cmd.getGroupWithId.value,
                    group_id=group_id,
                    group_name=group_name,
                    owner=owner_user,
                    member_count_value=2,
                    device=endpoint.device_name,
                )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(sender, assert_api, group_id, device_b=topology.recipient_action_device)


def test_group_get_group_from_server(device_a, device_b, assert_api, user_a, user_b):
    group_name = new_group_name("server")
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                device_a,
                assert_api,
                owner=user_a,
                group_name=group_name,
                invite_members=[user_b],
            )
        with _allure_step("A 查询服务端群详情"):
            resp = device_a.call(
                "GroupManager",
                Cmd.getGroupSpecificationFromServer.value,
                info={"groupId": group_id},
            )
        with _allure_step("验证查询服务端群详情返回的关键字段"):
            assert_group_snapshot(
                assert_api,
                resp,
                cmd=Cmd.getGroupSpecificationFromServer.value,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                member_count_value=2,
            )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id, device_b=device_b)


def test_group_get_group_from_server_after_destroy(device_a, device_b, assert_api, user_a):
    group_name = new_group_name("server_after_destroy")
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                device_a,
                assert_api,
                owner=user_a,
                group_name=group_name,
                invite_members=[],
            )
        destroyed_group_id = group_id
        # B 不在该群中，销毁时不应强制等待 B 端 onGroupDestroyed 回调。
        group_id = ""
        with _allure_step("测试后置：销毁测试群并恢复群状态"):
            destroy_group(device_a, assert_api, destroyed_group_id)

        with _allure_step("A 查询服务端群详情"):
            resp = device_a.call(
                "GroupManager",
                Cmd.getGroupSpecificationFromServer.value,
                info={"groupId": destroyed_group_id},
            )
        with _allure_step("验证查询服务端群详情返回的错误码与错误文案"):
            assert_api.assert_error(resp, code=600, description="do not find this group")
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id, device_b=device_b)
