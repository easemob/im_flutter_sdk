"""Group announcement API 异常/边界用例（strict）。"""
from __future__ import annotations

import pytest
from tests.group.allure_helpers import _allure_step

from src import Cmd
from tests.group.group_helpers import create_group, destroy_group, new_group_name


pytestmark = [pytest.mark.client, pytest.mark.group]


_NONEXISTENT_GROUP_ID = "nonexistent_group_999999"



def test_group_update_announcement_nonexistent_group(device_a, assert_api):
    with _allure_step("A 更新群公告"):
        resp = device_a.call(
            "GroupManager",
            Cmd.updateGroupAnnouncement.value,
            info={"groupId": _NONEXISTENT_GROUP_ID, "announcement": "a1"},
        )
    with _allure_step("验证更新群公告返回的错误码与错误文案"):
        assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_get_announcement_nonexistent_group(device_a, assert_api):
    with _allure_step("A 查询群公告"):
        resp = device_a.call(
            "GroupManager",
            Cmd.getGroupAnnouncementFromServer.value,
            info={"groupId": _NONEXISTENT_GROUP_ID},
        )
    with _allure_step("验证查询群公告返回的错误码与错误文案"):
        assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_update_announcement_empty(device_a, assert_api, user_a):
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                device_a,
                assert_api,
                owner=user_a,
                group_name=new_group_name("announce_empty"),
                invite_members=[],
            )
        with _allure_step("A 更新群公告"):
            resp_update = device_a.call(
                "GroupManager",
                Cmd.updateGroupAnnouncement.value,
                info={"groupId": group_id, "announcement": ""},
            )
        with _allure_step("验证更新群公告返回的关键字段"):
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

        with _allure_step("A 查询群公告"):
            resp_get = device_a.call(
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
                    "device": "deviceA",
                    "result": "",
                },
                ignore_keys={"sequence"},
            )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)
