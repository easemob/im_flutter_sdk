"""Group members 正常链路。"""
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
    assert_no_group_event,
    assert_group_events,
    assert_group_members_from_server,
    assert_group_snapshot,
    collect_group_events,
    create_group,
    destroy_group,
    member_count,
    new_group_name,
)


pytestmark = [pytest.mark.client, pytest.mark.group, pytest.mark.agorachat1_4_0]


@pytest.mark.topology("account_a_to_account_b")

def test_group_add_remove_members(assert_api, user_a, user_b, topology):
    """群主添加/移除成员：加入与移除事件同步到收发账号全部在线端。"""
    owner = topology.sender_action_device
    member = topology.recipient_action_device
    group_name = new_group_name("member")
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                owner,
                assert_api,
                owner=user_a,
                group_name=group_name,
                invite_members=[],
            )

        sec_b_devices = tuple(d for d in topology.recipient_devices if d is not topology.recipient_action_device)
        sec_a_devices = tuple(d for d in topology.sender_devices if d is not topology.sender_action_device)

        with _allure_step("A 添加群成员"):
            resp_add = owner.call(
                "GroupManager",
                Cmd.addMembers.value,
                info={"groupId": group_id, "members": [user_b], "welcome": "welcome"},
            )
        with _allure_step("验证 添加群成员返回的关键字段"):
            assert_api.assert_response_matches(
                resp_add,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.addMembers.value,
                    "device": owner.device_name,
                    "result": True,
                },
                ignore_keys={"sequence"},
            )

        expected_add_events = {
            GroupChangeEvent.ON_INVITATION_RECEIVED.value,
            GroupChangeEvent.ON_AUTO_ACCEPT_INVITATION.value,
            "onGroupAutoAcceptInvitation",
            "onGroupWhiteListRemoved",
            "onGroupMemberJoined",
        }
        required_add_events = {
            "onGroupAutoAcceptInvitation",
        }
        with _allure_step("等待并校验目标业务事件"):
            add_events = collect_group_events(
                member,
                expected_event_types=expected_add_events,
                group_id=group_id,
                allow_missing_group_id=True,
                required_all_event_types=required_add_events,
                timeout=10.0,
            )
        with _allure_step("验证 添加群成员返回的关键字段"):
            assert_group_events(
                assert_api,
                add_events,
                expected_event_types=expected_add_events,
                group_id=group_id,
                allow_missing_group_id=True,
                required_all_event_types=required_add_events,
                expected_inviter=user_a,
                expected_member=user_b,
            )

        for sec_b in sec_b_devices:
            with _allure_step(f"接收账号副端 {sec_b.device_name} 同步验证收到事件"):
                sec_add_events = collect_group_events(
                    sec_b,
                    expected_event_types=expected_add_events,
                    group_id=group_id,
                    allow_missing_group_id=True,
                    required_all_event_types=required_add_events,
                    timeout=10.0,
                )
                assert_group_events(
                    assert_api,
                    sec_add_events,
                    expected_event_types=expected_add_events,
                    group_id=group_id,
                    allow_missing_group_id=True,
                    required_all_event_types=required_add_events,
                    expected_inviter=user_a,
                    expected_member=user_b,
                )


        with _allure_step("等待并校验目标业务事件"):
            owner_add_events = collect_group_events(
                owner,
                expected_event_types={
                    "onGroupMembersJoined",
                    "onGroupMemberJoined",
                },
                group_id=group_id,
                # 5.0 只派发批量事件 onGroupMembersJoined（单成员事件不派发）
                required_all_event_types={"onGroupMembersJoined"},
                timeout=10.0,
            )
        with _allure_step("验证 添加群成员返回的关键字段"):
            assert_group_events(
                assert_api,
                owner_add_events,
                expected_event_types={
                    "onGroupMembersJoined",
                    "onGroupMemberJoined",
                },
                group_id=group_id,
                required_all_event_types={"onGroupMembersJoined"},
                expected_member=user_b,
            )

        for sec_a in sec_a_devices:
            with _allure_step(f"发送账号副端 {sec_a.device_name} 同步验证收到事件"):
                owner_sec_add_events = collect_group_events(
                    sec_a,
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
                    owner_sec_add_events,
                    expected_event_types={
                        "onGroupMembersJoined",
                        "onGroupMemberJoined",
                    },
                    group_id=group_id,
                    required_all_event_types={"onGroupMembersJoined"},
                    expected_member=user_b,
                )


        with _allure_step("A 查询服务端群详情"):
            resp_get_after_add = owner.call(
                "GroupManager",
                Cmd.getGroupSpecificationFromServer.value,
                info={"groupId": group_id},
            )
        with _allure_step("验证查询服务端群详情返回的关键字段"):
            assert_group_snapshot(
                assert_api,
                resp_get_after_add,
                cmd=Cmd.getGroupSpecificationFromServer.value,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                member_count_value=2,
            )
        with _allure_step("验证查询服务端群详情返回的关键字段"):
            assert member_count(resp_get_after_add) == 2, f"addMembers 后 memberCount 预期 2: {resp_get_after_add}"
        with _allure_step("验证查询服务端群详情返回的关键字段"):
            assert_group_members_from_server(
                owner,
                assert_api,
                group_id=group_id,
                device_name=owner.device_name,
                expected_members=[user_b],
                err_prefix="addMembers 后",
            )

        with _allure_step("A 移除群成员"):
            resp_remove = owner.call(
                "GroupManager",
                Cmd.removeMembers.value,
                info={"groupId": group_id, "members": [user_b]},
            )
        with _allure_step("验证 移除群成员返回的关键字段"):
            assert_api.assert_response_matches(
                resp_remove,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.removeMembers.value,
                    "device": owner.device_name,
                    "result": True,
                },
                ignore_keys={"sequence"},
            )

        expected_remove_events = {
            GroupChangeEvent.ON_USER_REMOVED.value,
            "onGroupMemberExited",
            "onGroupUserRemoved",
        }
        required_remove_events = {"onGroupUserRemoved"}
        with _allure_step("等待并校验目标业务事件"):
            remove_events = collect_group_events(
                member,
                expected_event_types=expected_remove_events,
                group_id=group_id,
                allow_missing_group_id=True,
                required_all_event_types=required_remove_events,
                timeout=10.0,
            )
        with _allure_step("验证 移除群成员返回的关键字段"):
            assert_group_events(
                assert_api,
                remove_events,
                expected_event_types=expected_remove_events,
                group_id=group_id,
                allow_missing_group_id=True,
                required_all_event_types=required_remove_events,
                expected_member=user_b,
            )

        for sec_b in sec_b_devices:
            with _allure_step(f"接收账号副端 {sec_b.device_name} 同步验证收到事件"):
                sec_remove_events = collect_group_events(
                    sec_b,
                    expected_event_types=expected_remove_events,
                    group_id=group_id,
                    allow_missing_group_id=True,
                    required_all_event_types=required_remove_events,
                    timeout=10.0,
                )
                assert_group_events(
                    assert_api,
                    sec_remove_events,
                    expected_event_types=expected_remove_events,
                    group_id=group_id,
                    allow_missing_group_id=True,
                    required_all_event_types=required_remove_events,
                    expected_member=user_b,
                )


        with _allure_step("等待并校验目标业务事件"):
            owner_remove_events = collect_group_events(
                owner,
                expected_event_types={
                    "onGroupMembersExited",
                    "onGroupMemberExited",
                },
                group_id=group_id,
                required_all_event_types={"onGroupMembersExited"},
                timeout=10.0,
            )
        with _allure_step("验证 移除群成员返回的关键字段"):
            assert_group_events(
                assert_api,
                owner_remove_events,
                expected_event_types={
                    "onGroupMembersExited",
                    "onGroupMemberExited",
                },
                group_id=group_id,
                required_all_event_types={"onGroupMembersExited"},
                expected_member=user_b,
            )

        for sec_a in sec_a_devices:
            with _allure_step(f"发送账号副端 {sec_a.device_name} 同步验证收到事件"):
                owner_sec_remove_events = collect_group_events(
                    sec_a,
                    expected_event_types={
                        "onGroupMembersExited",
                        "onGroupMemberExited",
                    },
                    group_id=group_id,
                    required_all_event_types={"onGroupMembersExited"},
                    timeout=10.0,
                )
                assert_group_events(
                    assert_api,
                    owner_sec_remove_events,
                    expected_event_types={
                        "onGroupMembersExited",
                        "onGroupMemberExited",
                    },
                    group_id=group_id,
                    required_all_event_types={"onGroupMembersExited"},
                    expected_member=user_b,
                )


        with _allure_step("A 查询服务端群详情"):
            resp_get_after_remove = owner.call(
                "GroupManager",
                Cmd.getGroupSpecificationFromServer.value,
                info={"groupId": group_id},
            )
        with _allure_step("验证查询服务端群详情返回的关键字段"):
            assert_group_snapshot(
                assert_api,
                resp_get_after_remove,
                cmd=Cmd.getGroupSpecificationFromServer.value,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                member_count_value=1,
            )
        with _allure_step("验证查询服务端群详情返回的关键字段"):
            assert member_count(resp_get_after_remove) == 1, f"removeMembers 后 memberCount 预期 1: {resp_get_after_remove}"
        with _allure_step("验证查询服务端群详情返回的关键字段"):
            assert_group_members_from_server(
                owner,
                assert_api,
                group_id=group_id,
                device_name=owner.device_name,
                expected_members=[],
                err_prefix="removeMembers 后",
            )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(owner, assert_api, group_id)


@pytest.mark.topology("account_a_to_account_b")
def test_group_join_and_leave_public_group(topology, assert_api):
    """
    多端拓扑：A 建 PublicOpenJoin 公开群，B 加入/退出；成员事件同步到 A 全部在线端，A 全部端查询成员快照一致。
    """
    sender = topology.sender_action_device
    joiner = topology.recipient_action_device
    owner_user = topology.sender_user
    member_user = topology.recipient_user

    group_name = new_group_name("public")
    group_id = ""
    try:
        with _allure_step(f"{sender.device_name} 建 PublicOpenJoin 公开群"):
            group_id, _ = create_group(
                sender,
                assert_api,
                owner=owner_user,
                group_name=group_name,
                invite_members=[],
                style=3,
                # 官方迁移表 6.1：仅 style=1 allowInvites=true；style=3（公开自由加入）→ false
                is_member_allow_to_invite=False,
            )

        with _allure_step(f"{joiner.device_name} 加入公开群"):
            resp_join = joiner.call("GroupManager", Cmd.joinPublicGroup.value, info={"groupId": group_id})
        with _allure_step("确认加入请求已提交"):
            assert_api.assert_response_matches(
                resp_join,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.joinPublicGroup.value,
                    "device": joiner.device_name,
                    "result": None,
                },
                ignore_keys={"sequence"},
            )

        joined_event_types = {"onGroupMembersJoined"}  # 5.0 只派发批量事件
        with _allure_step("A 全部在线端收到成员加入事件"):
            for endpoint in topology.sender_devices:
                owner_join_events = collect_group_events(
                    endpoint,
                    expected_event_types=joined_event_types,
                    group_id=group_id,
                    required_all_event_types={"onGroupMembersJoined"},
                    timeout=10.0,
                )
                owner_join_by_type = {event["eventType"]: event for event in owner_join_events}
                assert_api.assert_response_matches(
                    owner_join_by_type["onGroupMembersJoined"],
                    expected={
                        "type": "event",
                        "eventType": "onGroupMembersJoined",
                        "data": {"groupId": group_id, "userIds": [member_user]},
                    },
                    ignore_keys={"timestamp", "sequence"},
                )
        with _allure_step("A 全部在线端查询成员快照均含 B（账号级服务端状态一致）"):
            for endpoint in topology.sender_devices:
                members_resp = endpoint.call(
                    "GroupManager",
                    Cmd.getGroupMemberListFromServer.value,
                    info={"groupId": group_id, "pageSize": 20, "cursor": ""},
                )
                member_items = (members_resp.get("result") or {}).get("list", [])
                member_ids = [
                    item.get("member") if isinstance(item, dict) else item
                    for item in member_items
                ]
                assert member_user in member_ids, f"加入后成员快照缺少 B: member_user={member_user}, members={member_ids}"

        with _allure_step(f"{joiner.device_name} 退出公开群"):
            resp_leave = joiner.call("GroupManager", Cmd.leaveGroup.value, info={"groupId": group_id})
        with _allure_step("确认退出请求已提交"):
            assert_api.assert_response_matches(
                resp_leave,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.leaveGroup.value,
                    "device": joiner.device_name,
                    "result": True,
                },
                ignore_keys={"sequence"},
            )

        with _allure_step("A 全部在线端收到成员退出事件"):
            for endpoint in topology.sender_devices:
                owner_leave_events = collect_group_events(
                    endpoint,
                    expected_event_types={"onGroupMembersExited"},
                    group_id=group_id,
                    required_all_event_types={"onGroupMembersExited"},
                    timeout=10.0,
                )
                owner_leave_by_type = {event["eventType"]: event for event in owner_leave_events}
                assert_api.assert_response_matches(
                    owner_leave_by_type["onGroupMembersExited"],
                    expected={
                        "type": "event",
                        "eventType": "onGroupMembersExited",
                        "data": {"groupId": group_id, "userIds": [member_user]},
                    },
                    ignore_keys={"timestamp", "sequence"},
                )
        with _allure_step("A 全部在线端查询成员快照均不含 B"):
            for endpoint in topology.sender_devices:
                members_resp = endpoint.call(
                    "GroupManager",
                    Cmd.getGroupMemberListFromServer.value,
                    info={"groupId": group_id, "pageSize": 20, "cursor": ""},
                )
                member_items = (members_resp.get("result") or {}).get("list", [])
                member_ids = [
                    item.get("member") if isinstance(item, dict) else item
                    for item in member_items
                ]
                assert member_user not in member_ids, f"退出后成员快照仍含 B: member_user={member_user}, members={member_ids}"
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(sender, assert_api, group_id)



def test_group_join_public_group_rejects_private_member_invite_group(
    device_a,
    device_b,
    assert_api,
    user_a,
):
    """
    前置：A/B 已登录，A 创建 PrivateMemberCanInvite（style=1）私有群，B 不是成员。
    步骤：B 对该私有群调用 joinPublicGroup。
    预期与断言：接口拒绝加入，严格冻结真实错误码 603 和权限错误描述；该异常用例不等待事件。
    """
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                device_a,
                assert_api,
                owner=user_a,
                group_name=new_group_name("private_join_reject"),
                invite_members=[],
                style=1,
            )
        with _allure_step("B 加入公开群"):
            resp_join = device_b.call("GroupManager", Cmd.joinPublicGroup.value, info={"groupId": group_id})
        with _allure_step("验证加入公开群返回的错误码与错误文案"):
            assert_api.assert_error(resp_join, code=603, description="group member permission is required")
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)


def test_group_members_batch_join_exit_new_events(device_a, device_b, assert_api, user_a, user_b, user_c):
    """
    校验新事件名：
    - onMembersJoinedFromGroup
    - onMembersExitedFromGroup
    """
    group_name = new_group_name("member_batch_evt")
    group_id = ""
    members = [user_b, user_c]
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                device_a,
                assert_api,
                owner=user_a,
                group_name=group_name,
                invite_members=[],
            )

        with _allure_step("A 添加群成员"):
            resp_add = device_a.call(
                "GroupManager",
                Cmd.addMembers.value,
                info={"groupId": group_id, "members": members, "welcome": "welcome"},
            )
        with _allure_step("验证 添加群成员返回的关键字段"):
            assert_api.assert_response_matches(
                resp_add,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.addMembers.value,
                    "device": "deviceA",
                    "result": True,
                },
                ignore_keys={"sequence"},
            )

        expected_joined_events = {"onGroupMembersJoined"}  # 5.0 只派发批量事件
        # 5.0 实测：批量加人只派发 onGroupMembersJoined（单成员事件不派发）→ required 用批量事件
        with _allure_step("等待并校验目标业务事件"):
            joined_events = collect_group_events(
                device_a,
                expected_event_types=expected_joined_events,
                group_id=group_id,
                required_all_event_types={"onGroupMembersJoined"},
                timeout=10.0,
            )
        with _allure_step("验证 添加群成员返回的关键字段"):
            assert_group_events(
                assert_api,
                joined_events,
                expected_event_types=expected_joined_events,
                group_id=group_id,
                required_all_event_types={"onGroupMembersJoined"},
            )
        joined_batch = [evt for evt in joined_events if evt.get("eventType") == "onGroupMembersJoined"]
        if joined_batch:
            # SDK 可能对批量添加逐个触发事件，每个事件只含一个用户；合并所有事件的 userIds
            all_user_ids: list[str] = []
            for evt in joined_batch:
                data_join = (evt.get("data") or {})
                user_ids_join = data_join.get("userIds") or []
                with _allure_step("验证 添加群成员返回的关键字段"):
                    assert isinstance(user_ids_join, list), f"onMembersJoinedFromGroup.userIds 非 list: {evt}"
                all_user_ids.extend(user_ids_join)
            with _allure_step("验证 添加群成员返回的关键字段"):
                assert all(m in all_user_ids for m in members), (
                    f"onMembersJoinedFromGroup.userIds 缺少成员: expected={members}, actual={all_user_ids}"
                )
        else:
            joined_single_members = {
                (evt.get("data") or {}).get("member")
                for evt in joined_events
                if evt.get("eventType") == "onGroupMemberJoined"
            }
            with _allure_step("验证 添加群成员返回的关键字段"):
                assert all(m in joined_single_members for m in members), (
                    "未收到 onMembersJoinedFromGroup，且 onMemberJoinedFromGroup 未覆盖全部成员: "
                    f"expected={members}, actual={sorted(x for x in joined_single_members if isinstance(x, str))}"
                )

        with _allure_step("A 移除群成员"):
            resp_remove = device_a.call(
                "GroupManager",
                Cmd.removeMembers.value,
                info={"groupId": group_id, "members": members},
            )
        with _allure_step("验证 移除群成员返回的关键字段"):
            assert_api.assert_response_matches(
                resp_remove,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.removeMembers.value,
                    "device": "deviceA",
                    "result": True,
                },
                ignore_keys={"sequence"},
            )

        expected_exited_events = {"onGroupMembersExited", "onGroupMemberExited"}
        with _allure_step("等待并校验目标业务事件"):
            exited_events = collect_group_events(
                device_a,
                expected_event_types=expected_exited_events,
                group_id=group_id,
                required_all_event_types={"onGroupMembersExited"},
                timeout=10.0,
            )
        with _allure_step("验证 移除群成员返回的关键字段"):
            assert_group_events(
                assert_api,
                exited_events,
                expected_event_types=expected_exited_events,
                group_id=group_id,
                required_all_event_types={"onGroupMembersExited"},
            )
        exited_batch = [evt for evt in exited_events if evt.get("eventType") == "onGroupMembersExited"]
        if exited_batch:
            # SDK 对批量移除逐个触发事件，合并所有事件的 userIds
            all_exit_ids: list[str] = []
            for evt in exited_batch:
                data_exit = (evt.get("data") or {})
                user_ids_exit = data_exit.get("userIds") or []
                with _allure_step("验证 移除群成员返回的关键字段"):
                    assert isinstance(user_ids_exit, list), f"onMembersExitedFromGroup.userIds 非 list: {evt}"
                all_exit_ids.extend(user_ids_exit)
            with _allure_step("验证 移除群成员返回的关键字段"):
                assert all(m in all_exit_ids for m in members), (
                    f"onMembersExitedFromGroup.userIds 缺少成员: expected={members}, actual={all_exit_ids}"
                )
        else:
            exited_single_members = {
                (evt.get("data") or {}).get("member")
                for evt in exited_events
                if evt.get("eventType") == "onGroupUserRemoved"
            }
            with _allure_step("验证 移除群成员返回的关键字段"):
                assert all(m in exited_single_members for m in members), (
                    "未收到 onMembersExitedFromGroup，且 onUserRemovedFromGroup 未覆盖全部成员: "
                    f"expected={members}, actual={sorted(x for x in exited_single_members if isinstance(x, str))}"
                )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)
