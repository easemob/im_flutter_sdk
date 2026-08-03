"""Group announcement API 正常用例（strict）。"""
from __future__ import annotations

import pytest

from src import Cmd
from tests.group.group_helpers import (
    assert_group_events,
    assert_no_group_event,
    collect_group_events,
    create_group,
    destroy_group,
    new_group_name,
)


pytestmark = [pytest.mark.client, pytest.mark.group]


def _consume_direct_invite_events(device_a, device_b, assert_api, *, group_id: str, user_a: str, user_b: str) -> None:
    member_events = collect_group_events(
        device_b,
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
    owner_events = collect_group_events(
        device_a,
        expected_event_types={"onGroupMembersJoined", "onGroupMemberJoined"},
        group_id=group_id,
        required_all_event_types={"onGroupMembersJoined", "onGroupMemberJoined"},
        timeout=10.0,
    )
    assert_group_events(
        assert_api,
        owner_events,
        expected_event_types={"onGroupMembersJoined", "onGroupMemberJoined"},
        group_id=group_id,
        required_all_event_types={"onGroupMembersJoined", "onGroupMemberJoined"},
        expected_member=user_b,
    )


def test_group_owner_update_announcement_notifies_member(device_a, device_b, assert_api, user_a, user_b):
    """
    前置：A 为群主，B 已入群且双方建群事件已消费。
    步骤：A 调用 updateGroupAnnouncement；B 等待公告变更事件；A 从服务端读取公告。
    预期与断言：同步响应 result=null，服务端公告等于本次动态值；B 收到包含 groupId 和
    announcement 的真实回调，A 在独立等待窗口内不收到同类回调。
    """
    group_id = ""
    group_name = new_group_name("announce_group")
    announcement = new_group_name("announce")
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b],
        )
        _consume_direct_invite_events(
            device_a,
            device_b,
            assert_api,
            group_id=group_id,
            user_a=user_a,
            user_b=user_b,
        )

        resp_update = device_a.call(
            "GroupManager",
            Cmd.updateGroupAnnouncement.value,
            info={"groupId": group_id, "announcement": announcement},
        )
        assert_api.assert_response_matches(
            resp_update,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.updateGroupAnnouncement.value,
                "device": "deviceA",
                "result": None,
            },
            ignore_keys={"sequence"},
        )

        announcement_events = collect_group_events(
            device_b,
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
        assert_no_group_event(
            device_a,
            group_id=group_id,
            event_types={"onGroupAnnouncementChanged"},
        )

        resp_get = device_a.call(
            "GroupManager",
            Cmd.getGroupAnnouncementFromServer.value,
            info={"groupId": group_id},
        )
        assert_api.assert_response_matches(
            resp_get,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.getGroupAnnouncementFromServer.value,
                "device": "deviceA",
                "result": announcement,
            },
            ignore_keys={"sequence"},
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id, device_b=device_b)


def test_group_admin_update_announcement_notifies_owner(device_a, device_b, assert_api, user_a, user_b):
    """
    前置：A 为群主、B 已入群；A 将 B 设置为管理员并消费管理员变更事件。
    步骤：管理员 B 调用 updateGroupAnnouncement；A 等待公告变更事件；A 拉取服务端公告。
    预期与断言：管理员更新成功，服务端公告等于本次动态值；A 收到真实公告事件，B 在
    独立等待窗口内不收到同类回调，从而覆盖群主/管理员双角色方向。
    """
    group_id = ""
    group_name = new_group_name("admin_announce_group")
    announcement = new_group_name("admin_announce")
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b],
        )
        _consume_direct_invite_events(
            device_a,
            device_b,
            assert_api,
            group_id=group_id,
            user_a=user_a,
            user_b=user_b,
        )

        resp_admin = device_a.call(
            "GroupManager",
            Cmd.addAdmin.value,
            info={"groupId": group_id, "admin": user_b},
        )
        assert_api.assert_response_matches(
            resp_admin,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.addAdmin.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )
        admin_events = collect_group_events(
            device_b,
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
        assert_no_group_event(device_a, group_id=group_id, event_types={"onGroupAdminAdded"})

        resp_update = device_b.call(
            "GroupManager",
            Cmd.updateGroupAnnouncement.value,
            info={"groupId": group_id, "announcement": announcement},
        )
        assert_api.assert_response_matches(
            resp_update,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.updateGroupAnnouncement.value,
                "device": "deviceB",
                "result": None,
            },
            ignore_keys={"sequence"},
        )

        announcement_events = collect_group_events(
            device_a,
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
        assert_no_group_event(
            device_b,
            group_id=group_id,
            event_types={"onGroupAnnouncementChanged"},
        )

        resp_get = device_a.call(
            "GroupManager",
            Cmd.getGroupAnnouncementFromServer.value,
            info={"groupId": group_id},
        )
        assert_api.assert_response_matches(
            resp_get,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.getGroupAnnouncementFromServer.value,
                "device": "deviceA",
                "result": announcement,
            },
            ignore_keys={"sequence"},
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id, device_b=device_b)
