"""logout 离线场景：账号退出登录后，别人发的消息在重新登录时收到。

离线方式 = 账号 logout（退出登录），区别于 network_control 断网（保持登录态）。
重登 = token 登录（5.0 loginWithToken 只接受 token）。
"""
from __future__ import annotations

import time
import uuid

import pytest

from src import Cmd
from tests.chat._utils import build_text
from tests.conftest import _login_one


pytestmark = [pytest.mark.phase1, pytest.mark.multi_device]


def test_offline_message_sync_after_logout(device_a, device_b, assert_api, user_a, user_b):
    """A logout → B 发消息 → A 重新登录 → 收到离线消息（onMessagesReceived）。"""
    content = f"logout-offline-{uuid.uuid4().hex[:8]}"
    device_a.drain_events(timeout=0.5)
    device_b.drain_events(timeout=0.5)

    # 1. A 退出登录（不解绑推送 token）
    assert_api.assert_success(
        device_a.call("Client", Cmd.logout.value, info={"unbindToken": False})
    )

    # 2. B 给 A 发消息（A 离线，服务端暂存为离线消息）
    resp = device_b.call(
        "ChatManager",
        Cmd.sendMessage.value,
        info=build_text(user_b, user_a, content),
    )
    assert_api.assert_success(resp)

    # 3. A 重新登录（5.0 token 登录 + startCallback 事件转发）
    _login_one(device_a, user_a, "1", use_token=True)

    # 4. A 收到离线消息（onMessagesReceived，匹配 content）
    deadline = time.monotonic() + 30
    seen = []
    while time.monotonic() < deadline:
        evt = device_a.receive_message(
            match_event_type=Cmd.onMessagesReceived.value,
            timeout=min(2, max(0.1, deadline - time.monotonic())),
        )
        if evt:
            seen.append(evt)
        messages = ((evt or {}).get("data") or {}).get("messages") or []
        if any(
            (m.get("body") or {}).get("content") == content
            and m.get("from") == user_b
            and m.get("to") == user_a
            for m in messages
        ):
            return
    pytest.fail(f"重新登录后未收到离线消息: content={content}, seen={seen}")
