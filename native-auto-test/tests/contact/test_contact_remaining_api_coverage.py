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


pytestmark = [pytest.mark.client, pytest.mark.contact]


def test_contact_get_all_contacts_from_db_after_server_sync(
    device_a, device_b, assert_api, user_a, user_b
):
    """getAllContactsFromDB：建立好友后，从本地 DB 获取好友 ID 列表（5.0 本地读取；原 getAllContactsFromServer 服务端拉取已移除）。"""
    flow = ContactTestFlow(assert_api)
    flow.establish_friends(device_a, device_b, user_a, user_b, reason="local_contacts_db")

    local_resp = device_a.call(
        "ContactManager",
        Cmd.getAllContactsFromDB.value,
        info={},
    )
    assert_api.assert_response_matches(
        local_resp,
        expected={
            "manager": "ContactManager",
            "cmd": Cmd.getAllContactsFromDB.value,
            "device": "deviceA",
            "result": [user_b],
        },
        ignore_keys={"sequence"},
    )

    flow.delete_friend(device_a, user_b)


def test_contact_get_block_list_from_db_after_server_sync(
    device_a, device_b, assert_api, user_a, user_b
):
    """getBlockListFromDB：拉黑并同步服务端黑名单后，从本地 DB 获取黑名单 ID 列表。"""
    flow = ContactTestFlow(assert_api)
    flow.establish_friends(device_a, device_b, user_a, user_b, reason="local_block_db")
    flow.add_to_block_list(device_a, user_b)

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
            "device": "deviceA",
            "result": [user_b],
        },
        ignore_keys={"sequence"},
    )

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
            "device": "deviceA",
            "result": [user_b],
        },
        ignore_keys={"sequence"},
    )

    assert_api.assert_success(flow.remove_from_block_list(device_a, user_b))
    flow.delete_friend(device_a, user_b)


def test_contact_get_self_ids_on_other_platform_returns_list(device_a, assert_api):
    """getSelfIdsOnOtherPlatform：获取当前账号其它平台登录 ID，当前单设备登录应返回空列表。"""
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
            "device": "deviceA",
            "result": [],
        },
        ignore_keys={"sequence"},
    )
