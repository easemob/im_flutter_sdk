from __future__ import annotations

import time
import uuid

import pytest

from src import Cmd
from tests.chat._utils import build_text


pytestmark = [pytest.mark.client]


def test_same_account_second_device_sees_user_info_update(
    device_a,
    device_a_sec,
    assert_api,
    user_a,
):
    """同账号双设备：A 修改服务端属性，A_sec 最终读取到同一结果。"""
    nickname = f"same-account-{uuid.uuid4().hex[:8]}"
    response = device_a.call(
        "UserInfoManager",
        Cmd.updateOwnUserInfo.value,
        info={"nickName": nickname},
    )
    assert_api.assert_success(response)

    deadline = time.monotonic() + 20
    latest = None
    while time.monotonic() < deadline:
        latest = device_a_sec.call(
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
            "device": "deviceASec",
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


def test_third_party_message_reaches_both_same_account_devices(
    device_a,
    device_a_sec,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """组合拓扑：B 发给 A，A 的主、次设备都收到同一条消息。"""
    content = f"third-party-{uuid.uuid4().hex[:8]}"
    for device in (device_a, device_a_sec, device_b):
        device.drain_events(timeout=0.5)

    response = device_b.call(
        "ChatManager",
        Cmd.sendMessage.value,
        info=build_text(user_b, user_a, content),
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
                    message.get("from") == user_b
                    and message.get("to") == user_a
                    and body.get("content") == content
                ):
                    return message
        pytest.fail(
            f"未收到第三方消息: device={device.runner_info}, "
            f"content={content}, seen={seen}"
        )

    message_a = wait_target(device_a)
    message_a_sec = wait_target(device_a_sec)
    assert message_a["msgId"] == message_a_sec["msgId"]
