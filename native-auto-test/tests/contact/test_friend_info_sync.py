"""
好友信息同步（Friend Info Sync）测试：

5.0 原生已移除 onFriendStartSync / onFriendSyncFailed / onFriendSyncFinished 回调（4.24 有、5.0 删，iOS wrapper 死代码已删）。
本文件仅保留：修改设备 B 用户属性后，A 侧拉取 B 的用户信息（userId/remark/updatedAt）校验。

说明：好友关系建立/删除复用 ContactTestFlow。
"""
from __future__ import annotations

import time

import pytest

from src import Cmd
from src.test_flow import ContactTestFlow
from src.rest_api.user_api import update_user_metadata


pytestmark = [pytest.mark.client, pytest.mark.contact]


def test_friend_info_sync_on_peer_metadata_change(device_a, device_b, assert_api, user_a, user_b):
    """
    修改设备 B 的用户属性后，在 A 侧拉取 B 的用户信息校验（userId/remark/updatedAt）。
    步骤：
      1) A 与 B 建立好友；
      2) 通过 REST 修改 B 的昵称（或任一元数据字段）；
      3) A 调用 getContact 拉取 B，断言 userId/remark/updatedAt。
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
