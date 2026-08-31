"""
Contact 剩余 API 覆盖用例。

本文件只补充方法级覆盖缺口：getAllContactsFromDB、getBlockListFromDB、
getSelfIdsOnOtherPlatform。每个 case 都先通过真实 SDK 调用准备状态，再对
目标 cmd 的响应信封和业务字段做断言。
"""
from __future__ import annotations

import pytest

from src import Cmd
from src.test_flow import ContactTestFlow
from src.test_flow.offline_test_flow import logout_for_offline, restore_user_login
from tests.allure_helpers import _allure_step


pytestmark = [pytest.mark.client, pytest.mark.contact]


def test_contact_get_all_contacts_from_db_after_server_sync(
    device_a, device_b, assert_api, user_a, user_b
):
    """getAllContactsFromDB：建立好友后，从本地 DB 获取好友 ID 列表（5.0 本地读取；原 getAllContactsFromServer 服务端拉取已移除）。"""
    with _allure_step("测试准备：建立好友关系并完成本地同步"):
        flow = ContactTestFlow(assert_api)
        flow.establish_friends(device_a, device_b, user_a, user_b, reason="local_contacts_db")
    with _allure_step("读取本地联系人 ID 并验证包含 B"):
        local_resp = flow.wait_for_all_contacts_from_db(device_a, [user_b])
        assert_api.assert_response_matches(
            local_resp,
            expected={
                "manager": "ContactManager",
                "cmd": Cmd.getAllContactsFromDB.value,
                "device": device_a.device_name,
                "result": [user_b],
            },
            ignore_keys={"sequence"},
        )
    with _allure_step("测试后置：删除好友关系"):
        flow.delete_friend(device_a, user_b)


def test_contact_get_block_list_from_db_after_server_sync(
    device_a, device_b, assert_api, user_a, user_b
):
    """getBlockListFromDB：拉黑并同步服务端黑名单后，从本地 DB 获取黑名单 ID 列表。"""
    with _allure_step("测试准备：建立好友关系并加入黑名单"):
        flow = ContactTestFlow(assert_api)
        flow.establish_friends(device_a, device_b, user_a, user_b, reason="local_block_db")
        flow.add_to_block_list(device_a, user_b)
    with _allure_step("查询服务端黑名单并验证包含 B"):
        server_resp = device_a.call(
            "ContactManager",
            Cmd.getBlockListFromServer.value,
            info={},
        )
        assert_api.assert_response_matches(
            server_resp,
            expected={
                "manager": "ContactManager",
                "cmd": Cmd.getBlockListFromServer.value,
                "device": device_a.device_name,
                "result": [user_b],
            },
            ignore_keys={"sequence"},
        )
    with _allure_step("读取本地黑名单并验证包含 B"):
        local_resp = device_a.call(
            "ContactManager",
            Cmd.getBlockListFromDB.value,
            info={},
        )
        assert_api.assert_response_matches(
            local_resp,
            expected={
                "manager": "ContactManager",
                "cmd": Cmd.getBlockListFromDB.value,
                "device": device_a.device_name,
                "result": [user_b],
            },
            ignore_keys={"sequence"},
        )
    with _allure_step("测试后置：移出黑名单并删除好友关系"):
        assert_api.assert_success(flow.remove_from_block_list(device_a, user_b))
        flow.delete_friend(device_a, user_b)


def test_contact_get_self_ids_on_other_platform_returns_list(
    device_a,
    assert_api,
    user_a,
    device_pool,
    phase1_scenario,
):
    """getSelfIdsOnOtherPlatform：先确保当前账号只有 deviceA 在线，再严格验证空列表。"""
    secondary = None
    if phase1_scenario is not None and "device_a_sec" in phase1_scenario.roles:
        secondary = device_pool.get("device_a_sec")

    try:
        with _allure_step("测试准备：确保其他平台设备退出登录"):
            if secondary is not None:
                logout_for_offline(
                    secondary,
                    assert_api,
                    device_name=getattr(secondary, "_device", "deviceASec"),
                )
        with _allure_step("查询当前账号其他平台设备并验证列表为空"):
            resp = device_a.call(
                "ContactManager",
                Cmd.getSelfIdsOnOtherPlatform.value,
                info={},
            )
            assert_api.assert_response_matches(
                resp,
                expected={
                    "manager": "ContactManager",
                    "cmd": Cmd.getSelfIdsOnOtherPlatform.value,
                    "device": device_a.device_name,
                    "result": [],
                },
                ignore_keys={"sequence"},
            )
    finally:
        with _allure_step("测试后置：恢复其他平台设备登录"):
            if secondary is not None:
                restore_user_login(secondary, user_id=user_a)
