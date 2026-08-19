"""Group announcement API 正常用例（strict）。"""
from __future__ import annotations

from contextlib import nullcontext

import pytest

from src import Cmd


def _allure_step(name: str):
    try:
        import allure

        return allure.step(name)
    except ImportError:
        return nullcontext()
from tests.group.group_helpers import (
    assert_group_events,
    assert_no_group_event,
    collect_group_events,
    create_group,
    destroy_group,
    new_group_name,
)


pytestmark = [pytest.mark.client, pytest.mark.group]


def _consume_direct_invite_events(
    sender_devices,
    recipient_devices,
    assert_api,
    *,
    group_id: str,
    user_a: str,
    user_b: str,
) -> None:
    for endpoint in recipient_devices:
        member_events = collect_group_events(
            endpoint,
            expected_event_types={"onGroupAutoAcceptInvitation", "onGroupMemberJoined"},
            group_id=group_id,
            required_all_event_types={"onGroupAutoAcceptInvitation"},
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            member_events,
            expected_event_types={"onGroupAutoAcceptInvitation", "onGroupMemberJoined"},
            group_id=group_id,
            required_all_event_types={"onGroupAutoAcceptInvitation"},
            expected_inviter=user_a,
            expected_member=user_b,
        )
    for endpoint in sender_devices:
        owner_events = collect_group_events(
            endpoint,
            expected_event_types={"onGroupMembersJoined"},  # 5.0 只派发批量事件
            group_id=group_id,
            required_all_event_types={"onGroupMembersJoined"},  # 5.0 只派发批量事件（无单数 onGroupMemberJoined）
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            owner_events,
            expected_event_types={"onGroupMembersJoined"},  # 5.0 只派发批量事件
            group_id=group_id,
            required_all_event_types={"onGroupMembersJoined"},  # 5.0 只派发批量事件（无单数 onGroupMemberJoined）
            expected_member=user_b,
        )


@pytest.mark.topology("account_a_to_account_b")

def test_group_owner_update_announcement_notifies_member(assert_api, user_a, user_b, topology):
    """
    前置：A 为群主，B 已入群且双方建群事件已消费。
    步骤：A 调用 updateGroupAnnouncement；B 等待公告变更事件；A 从服务端读取公告。
    预期与断言：同步响应 result=null，服务端公告等于本次动态值；B 收到包含 groupId 和
    announcement 的真实回调，A 在独立等待窗口内不收到同类回调。
    """
    sender = topology.sender_action_device
    recipients = topology.recipient_devices
    group_id = ""
    group_name = new_group_name("announce_group")
    announcement = new_group_name("announce")
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                sender,
                assert_api,
                owner=user_a,
                group_name=group_name,
                invite_members=[user_b],
                device_name=sender.device_name,
            )
        with _allure_step("所有拓扑端点消费建群和入群事件"):
            _consume_direct_invite_events(
                topology.sender_devices,
                recipients,
                assert_api,
                group_id=group_id,
                user_a=user_a,
                user_b=user_b,
            )

        with _allure_step(f"{sender.device_name} 更新群公告"):
            resp_update = sender.call(
                "GroupManager",
                Cmd.updateGroupAnnouncement.value,
                info={"groupId": group_id, "announcement": announcement},
            )
        with _allure_step("验证更新群公告返回的关键字段"):
            assert_api.assert_response_matches(
                resp_update,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.updateGroupAnnouncement.value,
                    "device": sender.device_name,
                    "result": None,
                },
                ignore_keys={"sequence"},
            )

        for endpoint in recipients:
            with _allure_step(f"{endpoint.device_name} 收到并校验群公告变更事件"):
                announcement_events = collect_group_events(
                    endpoint,
                    expected_event_types={"onGroupAnnouncementChanged"},
                    group_id=group_id,
                    required_all_event_types={"onGroupAnnouncementChanged"},
                    timeout=10.0,
                )
                assert_api.assert_response_matches(
                    announcement_events[0],
                    expected={
                        "type": "event",
                        "eventType": "onGroupAnnouncementChanged",
                        "data": {"groupId": group_id, "announcement": announcement},
                    },
                    ignore_keys={"timestamp", "sequence"},
                )

        for endpoint in topology.sender_devices:
            with _allure_step(f"{endpoint.device_name} 不收到自己更新的群公告事件"):
                assert_no_group_event(endpoint, group_id=group_id, event_types={"onGroupAnnouncementChanged"})

        with _allure_step(f"{sender.device_name} 查询服务端群公告"):
            resp_get = sender.call(
                "GroupManager",
                Cmd.getGroupAnnouncementFromServer.value,
                info={"groupId": group_id},
            )
        with _allure_step("验证查询群公告返回的关键字段"):
            assert_api.assert_response_matches(
                resp_get,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.getGroupAnnouncementFromServer.value,
                    "device": sender.device_name,
                    "result": announcement,
                },
                ignore_keys={"sequence"},
            )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(sender, assert_api, group_id, device_b=topology.recipient_action_device, device_name=sender.device_name)
                for endpoint in recipients:
                    if endpoint is topology.recipient_action_device:
                        continue
                    with _allure_step(f"测试后置：{endpoint.device_name} 收到群销毁事件"):
                        events = collect_group_events(
                            endpoint,
                            expected_event_types={"onGroupDestroyed"},
                            group_id=group_id,
                            required_all_event_types={"onGroupDestroyed"},
                            timeout=10.0,
                        )
                        assert_group_events(
                            assert_api,
                            events,
                            expected_event_types={"onGroupDestroyed"},
                            group_id=group_id,
                            required_all_event_types={"onGroupDestroyed"},
                        )


@pytest.mark.topology("account_a_to_account_b")
def test_group_admin_update_announcement_notifies_owner(assert_api, user_a, user_b, topology):
    """
    前置：A 为群主、B 已入群；A 将 B 设置为管理员并消费管理员变更事件。
    步骤：管理员 B 调用 updateGroupAnnouncement；A 等待公告变更事件；A 拉取服务端公告。
    预期与断言：管理员更新成功，服务端公告等于本次动态值；A 收到真实公告事件，B 在
    独立等待窗口内不收到同类回调，从而覆盖群主/管理员双角色方向。
    """
    owner = topology.sender_action_device
    admin = topology.recipient_action_device
    group_id = ""
    group_name = new_group_name("admin_announce_group")
    announcement = new_group_name("admin_announce")
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                owner,
                assert_api,
                owner=user_a,
                group_name=group_name,
                invite_members=[user_b],
                device_name=owner.device_name,
            )
        with _allure_step("所有拓扑端点消费建群和入群事件"):
            _consume_direct_invite_events(
                topology.sender_devices,
                topology.recipient_devices,
                assert_api,
                group_id=group_id,
                user_a=user_a,
                user_b=user_b,
            )

        with _allure_step(f"{owner.device_name} 添加群管理员"):
            resp_admin = owner.call(
                "GroupManager",
                Cmd.addAdmin.value,
                info={"groupId": group_id, "admin": user_b},
            )
        with _allure_step("验证 添加群管理员返回的关键字段"):
            assert_api.assert_response_matches(
                resp_admin,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.addAdmin.value,
                    "device": owner.device_name,
                },
                ignore_keys={"sequence", "result"},
            )
        for endpoint in topology.recipient_devices:
            with _allure_step(f"{endpoint.device_name} 收到并校验管理员变更事件"):
                admin_events = collect_group_events(
                    endpoint,
                    expected_event_types={"onGroupAdminAdded"},
                    group_id=group_id,
                    required_all_event_types={"onGroupAdminAdded"},
                    timeout=10.0,
                )
                assert_group_events(
                    assert_api,
                    admin_events,
                    expected_event_types={"onGroupAdminAdded"},
                    group_id=group_id,
                    required_all_event_types={"onGroupAdminAdded"},
                    expected_member=user_b,
                )
        for endpoint in topology.sender_devices:
            with _allure_step(f"{endpoint.device_name} 不收到管理员变更事件"):
                assert_no_group_event(endpoint, group_id=group_id, event_types={"onGroupAdminAdded"})

        with _allure_step(f"{admin.device_name} 更新群公告"):
            resp_update = admin.call(
                "GroupManager",
                Cmd.updateGroupAnnouncement.value,
                info={"groupId": group_id, "announcement": announcement},
            )
        with _allure_step("验证更新群公告返回的关键字段"):
            assert_api.assert_response_matches(
                resp_update,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.updateGroupAnnouncement.value,
                    "device": admin.device_name,
                    "result": None,
                },
                ignore_keys={"sequence"},
            )

        for endpoint in topology.sender_devices:
            with _allure_step(f"{endpoint.device_name} 收到并校验管理员公告变更事件"):
                announcement_events = collect_group_events(
                    endpoint,
                    expected_event_types={"onGroupAnnouncementChanged"},
                    group_id=group_id,
                    required_all_event_types={"onGroupAnnouncementChanged"},
                    timeout=10.0,
                )
                assert_api.assert_response_matches(
                    announcement_events[0],
                    expected={
                        "type": "event",
                        "eventType": "onGroupAnnouncementChanged",
                        "data": {"groupId": group_id, "announcement": announcement},
                    },
                    ignore_keys={"timestamp", "sequence"},
                )

        for endpoint in topology.recipient_devices:
            with _allure_step(f"{endpoint.device_name} 不收到自己更新的群公告事件"):
                assert_no_group_event(endpoint, group_id=group_id, event_types={"onGroupAnnouncementChanged"})

        with _allure_step(f"{owner.device_name} 查询服务端群公告"):
            resp_get = owner.call(
                "GroupManager",
                Cmd.getGroupAnnouncementFromServer.value,
                info={"groupId": group_id},
            )
        with _allure_step("验证查询群公告返回的关键字段"):
            assert_api.assert_response_matches(
                resp_get,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.getGroupAnnouncementFromServer.value,
                    "device": owner.device_name,
                    "result": announcement,
                },
                ignore_keys={"sequence"},
            )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(owner, assert_api, group_id, device_b=admin, device_name=owner.device_name)
                for endpoint in topology.recipient_devices:
                    if endpoint is admin:
                        continue
                    with _allure_step(f"测试后置：{endpoint.device_name} 收到群销毁事件"):
                        events = collect_group_events(
                            endpoint,
                            expected_event_types={"onGroupDestroyed"},
                            group_id=group_id,
                            required_all_event_types={"onGroupDestroyed"},
                            timeout=10.0,
                        )
                        assert_group_events(
                            assert_api,
                            events,
                            expected_event_types={"onGroupDestroyed"},
                            group_id=group_id,
                            required_all_event_types={"onGroupDestroyed"},
                        )
