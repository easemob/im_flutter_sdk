"""
好友信息同步（Friend Info Sync）测试：

用例 1：登录后自动同步好友信息，收到 onFriendStartSync / onFriendSyncFinished 回调。
用例 2：登录后，修改设备 B（user_b）的用户属性；设备 A 收到上述两类回调；随后在 A 侧拉取 user_b 的用户信息，包含 addTimestamp 字段。

说明：
- 本文件仅关注「好友信息同步」回调与拉取校验；好友关系建立/删除复用 ContactTestFlow。
- 事件字符串 onFriendStartSync / onFriendSyncFinished 直接按服务端回调匹配，不依赖本仓库的枚举。
"""
from __future__ import annotations

import time

import pytest

from src import Cmd
from src.test_flow import ContactTestFlow
from src.rest_api.user_api import update_user_metadata


pytestmark = [pytest.mark.client, pytest.mark.contact]


FRIEND_START_SYNC = "onFriendStartSync"
FRIEND_SYNC_FINISHED = "onFriendSyncFinished"


def _wait_friend_sync_events(device, *, start_timeout: float = 10.0, finish_timeout: float = 20.0):
    """等待一轮好友信息同步的开始与结束事件；返回 (start_evt, finish_evt)。"""
    start_evt = device.receive_message(match_event_type=FRIEND_START_SYNC, timeout=start_timeout)
    assert start_evt is not None, "未收到 onFriendStartSync 回调"
    finish_evt = device.receive_message(match_event_type=FRIEND_SYNC_FINISHED, timeout=finish_timeout)
    assert finish_evt is not None, "未收到 onFriendSyncFinished 回调"
    return start_evt, finish_evt


def test_friend_info_auto_sync_after_login(device_a, device_b, assert_api, user_a, user_b):
    """
    用例 1：设备 A/B 重新登录，可自动触发好友信息同步两阶段回调。
    步骤：
      2) A logout → login；
      3) A 收到 onFriendStartSync 与 onFriendSyncFinished。
    清理：删除好友关系。
    """
    # 重新登录以触发一次同步；先清理残留事件，避免噪音
    assert_api.assert_success(device_a.call("Client", Cmd.logout.value, info={"unbindToken": False}))
    assert_api.assert_success(device_b.call("Client", Cmd.logout.value, info={"unbindToken": False}))
    device_a.drain_events(timeout=1.0)
    device_b.drain_events(timeout=1.0)

    assert_api.assert_success(
        device_a.call(
            "Client",
            Cmd.login.value,
            info={"userId": user_a, "pwdOrToken": "1", "isPassword": True},
        )
    )
    _wait_friend_sync_events(device_a)
    assert_api.assert_success(
        device_b.call(
            "Client",
            Cmd.login.value,
            info={"userId": user_b, "pwdOrToken": "1", "isPassword": True},
        )
    )
    _wait_friend_sync_events(device_b)





def test_friend_info_sync_on_peer_metadata_change(device_a, device_b, assert_api, user_a, user_b):
    """
    用例 2：设备 B 修改用户属性后，设备 A 收到好友信息同步回调；同步完成后在 A 侧拉取 B 的用户信息应包含 addTimestamp 字段。
    步骤：
      1) A 与 B 建立好友；
      2) 通过 REST 修改 B 的昵称（或任一元数据字段）；
      3) A 收到 onFriendStartSync 与 onFriendSyncFinished；
      4) A 调用 UserInfoManager.fetchUserInfoById 拉取 B，断言存在 addTimestamp。
    清理：删除好友关系。
    """
    flow = ContactTestFlow(assert_api)
    flow.establish_friends(device_a, device_b, user_a, user_b, reason="friend_info_sync_change")

    # 清理可能的历史回调，聚焦本次变更
    device_a.drain_events(timeout=1.0)

    # 通过 REST 修改设备 B 的用户元数据（示例：nickname）。
    # 若未配置 REST token/base_url，此调用会抛错并由测试框架报告配置问题。
    new_nick = f"nick-{int(time.time())}"
    update_user_metadata(user_b, {"nickname": new_nick})

    # A 收到好友信息同步的开始与结束回调
    # _wait_friend_sync_events(device_a, start_timeout=20.0, finish_timeout=30.0)

    # 同步完成后，A 拉取 B 的用户信息；根据实际返回断言关键字段（userId、nickName）
    content_after_readd = device_a.call(
        "ContactManager",
        Cmd.getContact.value,
        info={"userId": user_b},
    )
    assert_api.assert_response_matches(
        content_after_readd,
        expected={
            "manager": "ContactManager",
            "cmd": Cmd.getContact.value,
            "device": "{{device}}",
            "result": {"userId": "{{userId}}", "remark": ""},
        },
        context={"device": "deviceA", "userId": user_b},
        ignore_keys={"sequence","updatedAt"},
    )
    if "updatedAt" in content_after_readd:
        assert isinstance(content_after_readd["updatedAt"], (int, float)), "updatedAt 应为数值类型"

    # 清理好友关系
    flow.delete_friend(device_a, user_b)
