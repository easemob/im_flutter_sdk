"""
好友信息同步（Friend Info Sync）测试：

5.0 原生已移除 onFriendStartSync / onFriendSyncFailed / onFriendSyncFinished 回调（4.24 有、5.0 删，iOS wrapper 死代码已删）。
本文件保留：修改设备 B 用户属性后，A 侧拉取 B 的用户信息校验；以及 5.0
CONTACTS 数据同步开始/完成事件校验。

说明：好友关系建立/删除复用 ContactTestFlow。
"""
from __future__ import annotations

import time
from contextlib import nullcontext

import pytest

from src import Cmd
from src.test_flow import ContactTestFlow
from src.rest_api.user_api import fetch_user_token, update_user_metadata


pytestmark = [pytest.mark.client, pytest.mark.contact]


def _allure_step(name: str):
    try:
        import allure

        return allure.step(name)
    except ImportError:
        return nullcontext()


@pytest.mark.topology("account_a_to_account_b")
def test_friend_info_sync_on_peer_metadata_change(topology, assert_api):
    """
    多端拓扑：REST 修改 B 用户属性后，A 全部在线端拉取 B 的用户信息一致（userId/remark/updatedAt）。
    """
    sender = topology.sender_action_device
    owner_user = topology.sender_user
    member_user = topology.recipient_user

    flow = ContactTestFlow(assert_api)
    with _allure_step(f"{sender.device_name} 与 B 建立好友"):
        flow.establish_friends(sender, topology.recipient_action_device, owner_user, member_user, reason="friend_info_sync_change")

    with _allure_step("测试准备：清理历史事件"):
        sender.drain_events(timeout=1.0)

    with _allure_step("通过 REST 修改 B 的用户元数据"):
        new_nick = f"nick-{int(time.time())}"
        update_user_metadata(member_user, {"nickname": new_nick})

    with _allure_step("A 全部在线端拉取 B 的用户信息一致"):
        for endpoint in topology.sender_devices:
            content_after_readd = endpoint.call(
                "ContactManager",
                Cmd.getContact.value,
                info={"userId": member_user},
            )
            assert_api.assert_response_matches(
                content_after_readd,
                expected={
                    "manager": "ContactManager",
                    "cmd": Cmd.getContact.value,
                    "device": endpoint.device_name,
                    "result": {"userId": member_user, "remark": ""},
                },
                ignore_keys={"sequence", "updatedAt"},
            )
            if "updatedAt" in content_after_readd:
                assert isinstance(content_after_readd["updatedAt"], (int, float)), "updatedAt 应为数值类型"

    flow.delete_friend(sender, member_user)


def test_contact_data_sync_events_after_relogin(
    device_a, device_b, assert_api, user_a, user_b
):
    """
    5.0 Contact 数据同步：配置 CONTACTS 数据同步后重新登录，验证 Client
    层原生数据同步开始/完成事件能够通过测试桥接到达。

    该用例不依赖 4.x 的 onFriendStartSync/onFriendSyncFinished 回调。
    """
    flow = ContactTestFlow(assert_api)
    friend_established = False
    logged_out = False

    with _allure_step("测试准备：建立好友关系并清理历史事件"):
        flow.establish_friends(
            device_a,
            device_b,
            user_a,
            user_b,
            reason="contact_data_sync",
        )
        friend_established = True
        device_a.drain_events(timeout=1.0)

    original_mask = None

    try:
        original_type = device_a.call(
            "Client", Cmd.getDataSyncType.value, info={}
        )
        assert_api.assert_response_matches(
            original_type,
            expected={
                "manager": "Client",
                "cmd": Cmd.getDataSyncType.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence"},
        )
        original_mask = original_type.get("result")
        assert isinstance(original_mask, int), "getDataSyncType 应返回整数位掩码"

        with _allure_step("配置 Contact 数据同步类型（CONTACTS=2）"):
            set_type = device_a.call(
                "Client",
                Cmd.setDataSyncType.value,
                info={"dataSyncType": 2},
            )
            assert_api.assert_response_matches(
                set_type,
                expected={
                    "manager": "Client",
                    "cmd": Cmd.setDataSyncType.value,
                    "device": "deviceA",
                    "result": None,
                },
                ignore_keys={"sequence"},
            )

        with _allure_step("deviceA 退出当前登录会话"):
            logout = device_a.call(
                "Client", Cmd.logout.value, info={"unbindToken": False}
            )
            assert_api.assert_response_matches(
                logout,
                expected={
                    "manager": "Client",
                    "cmd": Cmd.logout.value,
                    "device": "deviceA",
                    "result": True,
                },
                ignore_keys={"sequence"},
            )
            logged_out = True

        device_a.drain_events(timeout=1.0)

        with _allure_step("deviceA 重新登录并触发 Contact 数据同步"):
            token = fetch_user_token(user_a, "1").get("access_token", "")
            assert token, "REST 未返回登录 token"
            login = device_a.call(
                "Client",
                Cmd.login.value,
                info={
                    "userId": user_a,
                    "pwdOrToken": token,
                    "isPassword": False,
                },
            )
            assert_api.assert_response_matches(
                login,
                expected={
                    "manager": "Client",
                    "cmd": Cmd.login.value,
                    "device": "deviceA",
                    "result": user_a,
                },
                ignore_keys={"sequence"},
            )
            logged_out = False

        with _allure_step("验证 Contact 数据同步开始与完成事件"):
            start_event = device_a.receive_message(
                match_event_type=Cmd.onDataSyncStart.value,
                timeout=20.0,
            )
            assert_api.assert_response_matches(
                start_event,
                expected={
                    "type": "event",
                    "eventType": Cmd.onDataSyncStart.value,
                    "data": {"type": 2},
                },
                ignore_keys={"timestamp", "sequence"},
            )

            finish_event = device_a.receive_message(
                match_event_type=Cmd.onDataSyncFinish.value,
                timeout=30.0,
            )
            assert_api.assert_response_matches(
                finish_event,
                expected={
                    "type": "event",
                    "eventType": Cmd.onDataSyncFinish.value,
                    "data": {"type": 2},
                },
                ignore_keys={"timestamp", "sequence"},
            )
            finish_data = finish_event.get("data") or {}
            if "errorCode" in finish_data:
                assert finish_data["errorCode"] == 0, (
                    "Contact 数据同步完成事件 errorCode 应为 0，"
                    f"实际为 {finish_data['errorCode']}"
                )
    finally:
        if logged_out:
            token = fetch_user_token(user_a, "1").get("access_token", "")
            if token:
                device_a.call(
                    "Client",
                    Cmd.login.value,
                    info={
                        "userId": user_a,
                        "pwdOrToken": token,
                        "isPassword": False,
                    },
                )
        if original_mask is not None:
            device_a.call(
                "Client",
                Cmd.setDataSyncType.value,
                info={"dataSyncType": original_mask},
            )
        if friend_established:
            flow.delete_friend(device_a, user_b)
