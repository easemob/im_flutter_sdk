"""Group inviterUser 正常用例（strict）。"""
from __future__ import annotations

import pytest
from tests.group.allure_helpers import _allure_step

from src import Cmd, GroupChangeEvent
from tests.group.group_helpers import (
    assert_group_events,
    assert_group_members_exact,
    collect_group_events,
    create_group,
    destroy_group,
    member_count,
    new_group_name,
)


pytestmark = [pytest.mark.client, pytest.mark.group]



def test_group_inviter_user_success(device_a, device_b, assert_api, user_a, user_b):
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                device_a,
                assert_api,
                owner=user_a,
                group_name=new_group_name("inviter"),
                invite_members=[],
            )

        with _allure_step("A 邀请成员"):
            resp_invite = device_a.call(
                "GroupManager",
                Cmd.inviterUser.value,
                info={"groupId": group_id, "members": [user_b], "reason": "auto-inviter"},
            )
        with _allure_step("验证邀请成员返回的响应 result 与关键字段"):
            assert_api.assert_response_matches(
                resp_invite,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.inviterUser.value,
                    "device": "deviceA",
                },
                ignore_keys={"sequence", "result"},
            )

        with _allure_step("等待并校验目标业务事件"):
            invite_events = collect_group_events(
                device_b,
                expected_event_types={
                    GroupChangeEvent.ON_INVITATION_RECEIVED.value,
                    GroupChangeEvent.ON_AUTO_ACCEPT_INVITATION.value,
                    "onGroupAutoAcceptInvitation",
                    "onGroupWhiteListRemoved",
                    "onGroupMemberJoined",
                },
                group_id=group_id,
                allow_missing_group_id=True,
                required_all_event_types={"onGroupAutoAcceptInvitation"},
                timeout=10.0,
            )
        with _allure_step("验证邀请成员返回的响应 result 与关键字段"):
            assert_group_events(
                assert_api,
                invite_events,
                expected_event_types={
                    GroupChangeEvent.ON_INVITATION_RECEIVED.value,
                    GroupChangeEvent.ON_AUTO_ACCEPT_INVITATION.value,
                    "onGroupAutoAcceptInvitation",
                    "onGroupWhiteListRemoved",
                    "onGroupMemberJoined",
                },
                group_id=group_id,
                allow_missing_group_id=True,
                required_all_event_types={"onGroupAutoAcceptInvitation"},
                expected_inviter=user_a,
                expected_member=user_b,
            )

        with _allure_step("A 查询服务端群详情"):
            resp_group = device_a.call(
                "GroupManager",
                Cmd.getGroupSpecificationFromServer.value,
                info={"groupId": group_id},
            )
        result = resp_group.get("result")
        with _allure_step("验证查询服务端群详情返回的关键字段"):
            assert isinstance(result, dict), f"getGroupSpecificationFromServer result 非 dict: {resp_group}"
        with _allure_step("验证查询服务端群详情返回的关键字段"):
            assert member_count(resp_group) == 2, f"inviterUser 后 memberCount 应为 2: {resp_group}"
        with _allure_step("验证查询服务端群详情返回的关键字段"):
            assert_group_members_exact(resp_group, [user_b], err_prefix="inviterUser 后")
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)
