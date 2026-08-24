from __future__ import annotations

import time
import uuid

import pytest

from src import Cmd
from tests.chat._utils import build_text
from tests.allure_helpers import _allure_step


pytestmark = [pytest.mark.client]


@pytest.mark.topology("account_a_to_account_b")
def test_same_account_second_device_sees_user_info_update(topology, assert_api):
    """同账号多端：A 修改服务端属性，A 全部在线端最终读取到同一结果。"""
    sender = topology.sender_action_device
    user_a = topology.sender_user
    nickname = f"same-account-{uuid.uuid4().hex[:8]}"
    with _allure_step("A 更新用户昵称并验证请求成功"):
        response = sender.call(
            "UserInfoManager",
            Cmd.updateOwnUserInfo.value,
            info={"nickName": nickname},
        )
        assert_api.assert_success(response)

    with _allure_step("A 全部在线端查询用户资料并验证昵称同步"):
        for device in topology.sender_devices:
            deadline = time.monotonic() + 20
            latest = None
            while time.monotonic() < deadline:
                latest = device.call(
                    "UserInfoManager",
                    Cmd.fetchOwnInfo.value,
                    info={},
                )
                if (assert_api.get_result(latest) or {}).get("nickName") == nickname:
                    break
                time.sleep(1)

            assert_api.assert_response_matches(
                latest,
                expected={
                    "manager": "UserInfoManager",
                    "cmd": Cmd.fetchOwnInfo.value,
                    "device": device.device_name,
                    "result": {
                        "userId": user_a,
                        "nickName": nickname,
                    },
                },
            ignore_keys={
                "sequence",
                "sign",
                "gender",
                "mail",
                "avatarUrl",
                "phone",
                "birth",
                "ext",
            },
        )


@pytest.mark.topology("account_a_to_account_b")
def test_third_party_message_reaches_both_same_account_devices(topology, assert_api):
    """组合拓扑：B 发给 A，A 的全部在线端都收到同一条消息。"""
    recipient = topology.recipient_action_device
    sender_user = topology.sender_user
    recipient_user = topology.recipient_user
    content = f"third-party-{uuid.uuid4().hex[:8]}"
    with _allure_step("测试准备：清理相关设备的历史事件"):
        for device in (*topology.sender_devices, *topology.recipient_devices):
            device.drain_events(timeout=0.5)

    with _allure_step("B 向 A 发送文本消息并验证发送成功"):
        response = recipient.call(
            "ChatManager",
            Cmd.sendMessage.value,
            info=build_text(recipient_user, sender_user, content),
        )
        assert_api.assert_success(response)

    def wait_target(device):
        deadline = time.monotonic() + 20
        seen = []
        while time.monotonic() < deadline:
            event = device.receive_message(
                match_event_type=Cmd.onMessagesReceived.value,
                timeout=min(2, max(0.1, deadline - time.monotonic())),
            )
            if event:
                seen.append(event)
            for message in ((event or {}).get("data") or {}).get("messages") or []:
                body = message.get("body") or {}
                if (
                    message.get("from") == recipient_user
                    and message.get("to") == sender_user
                    and body.get("content") == content
                ):
                    return message
        pytest.fail(
            f"未收到第三方消息: device={device.runner_info}, "
            f"content={content}, seen={seen}"
        )

    with _allure_step("A 全部在线端分别接收消息并验证 msgId 一致"):
        msg_ids = [wait_target(d)["msgId"] for d in topology.sender_devices]
        assert len(set(msg_ids)) == 1, f"A 各端收到的 msgId 不一致: {msg_ids}"
    def wait_target(device):
        deadline = time.monotonic() + 20
        seen = []
        while time.monotonic() < deadline:
            event = device.receive_message(
                match_event_type=Cmd.onMessagesReceived.value,
                timeout=min(2, max(0.1, deadline - time.monotonic())),
            )
            if event:
                seen.append(event)
            for message in ((event or {}).get("data") or {}).get("messages") or []:
                body = message.get("body") or {}
                if (
                    message.get("from") == user_b
                    and message.get("to") == user_a
                    and body.get("content") == content
                ):
                    return message
        pytest.fail(
            f"未收到第三方消息: device={device.runner_info}, "
            f"content={content}, seen={seen}"
        )

    with _allure_step("A 主端和副端分别接收消息并验证 msgId 一致"):
        message_a = wait_target(device_a)
        message_a_sec = wait_target(device_a_sec)
        assert message_a["msgId"] == message_a_sec["msgId"]
