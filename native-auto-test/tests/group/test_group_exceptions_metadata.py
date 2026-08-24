"""Group metadata 异常用例（strict）。"""
from __future__ import annotations

import pytest
from tests.group.allure_helpers import _allure_step

from src import Cmd
from tests.group.group_helpers import create_group, destroy_group, new_group_name


pytestmark = [pytest.mark.client, pytest.mark.group]


_NONEXISTENT_GROUP_ID = "nonexistent_group_999999"
SUBJECT_TOO_LONG = "s" * 1025
DESC_TOO_LONG = "d" * 4097



def test_group_update_subject_empty(device_a, assert_api, user_a):
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(device_a, assert_api, owner=user_a, group_name=new_group_name("ex_subject"), invite_members=[])
        with _allure_step("A 更新群名称"):
            resp = device_a.call("GroupManager", Cmd.updateGroupSubject.value, info={"groupId": group_id, "subject": ""})
        with _allure_step("验证更新群名称返回的关键字段"):
            assert_api.assert_response_matches(
                resp,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.updateGroupSubject.value,
                    "device": "deviceA",
                    "result": None,
                },
                ignore_keys={"sequence"},
            )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)


def test_group_update_subject_too_long(device_a, assert_api, user_a):
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(device_a, assert_api, owner=user_a, group_name=new_group_name("ex_subject_len"), invite_members=[])
        with _allure_step("A 更新群名称"):
            resp = device_a.call(
                "GroupManager",
                Cmd.updateGroupSubject.value,
                info={"groupId": group_id, "subject": SUBJECT_TOO_LONG},
            )
        with _allure_step("验证更新群名称返回的关键字段"):
            assert_api.assert_response_matches(
                resp,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.updateGroupSubject.value,
                    "device": "deviceA",
                    "result": None,
                },
                ignore_keys={"sequence"},
            )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)


def test_group_update_description_empty(device_a, assert_api, user_a):
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(device_a, assert_api, owner=user_a, group_name=new_group_name("ex_desc"), invite_members=[])
        with _allure_step("A 执行群组业务操作"):
            resp = device_a.call("GroupManager", Cmd.updateDescription.value, info={"groupId": group_id, "description": ""})
        with _allure_step("验证执行群组业务操作返回的响应 result 与关键字段"):
            assert_api.assert_response_matches(
                resp,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.updateDescription.value,
                    "device": "deviceA",
                    "result": None,
                },
                ignore_keys={"sequence"},
            )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)


def test_group_update_description_too_long(device_a, assert_api, user_a):
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(device_a, assert_api, owner=user_a, group_name=new_group_name("ex_desc_len"), invite_members=[])
        with _allure_step("A 执行群组业务操作"):
            resp = device_a.call(
                "GroupManager",
                Cmd.updateDescription.value,
                info={"groupId": group_id, "description": DESC_TOO_LONG},
            )
        with _allure_step("验证执行群组业务操作返回的响应 result 与关键字段"):
            assert_api.assert_response_matches(
                resp,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.updateDescription.value,
                    "device": "deviceA",
                    "result": None,
                },
                ignore_keys={"sequence"},
            )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)


def test_group_update_subject_nonexistent_group(device_a, assert_api):
    with _allure_step("A 更新群名称"):
        resp = device_a.call(
            "GroupManager",
            Cmd.updateGroupSubject.value,
            info={"groupId": _NONEXISTENT_GROUP_ID, "subject": "new_subject"},
        )
    with _allure_step("验证更新群名称返回的错误码与错误文案"):
        assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_update_description_nonexistent_group(device_a, assert_api):
    with _allure_step("A 执行群组业务操作"):
        resp = device_a.call(
            "GroupManager",
            Cmd.updateDescription.value,
            info={"groupId": _NONEXISTENT_GROUP_ID, "description": "new_desc"},
        )
    with _allure_step("验证执行群组业务操作返回的错误码与错误文案"):
        assert_api.assert_error(resp, code=600, description="do not find this group")
