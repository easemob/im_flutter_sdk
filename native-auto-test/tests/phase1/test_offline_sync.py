from __future__ import annotations

import time
import uuid

import pytest

from src import Cmd
from tests.chat._utils import build_text


pytestmark = [pytest.mark.phase1, pytest.mark.multi_device]


def _wait_connected(device, expected: bool, timeout: float = 30) -> None:
    deadline = time.monotonic() + timeout
    latest = None
    while time.monotonic() < deadline:
        latest = device.call("Client", Cmd.isConnected.value, info={})
        if latest.get("result") is expected:
            return
        time.sleep(1)
    pytest.fail(
        f"连接状态未变为 {expected}: runner={device.runner_info}, "
        f"latest={latest}"
    )


def test_offline_message_sync_keeps_case_event_cursor(
    device_a,
    device_b,
    network_control,
    assert_api,
    user_a,
    user_b,
):
    content = f"offline-sync-{uuid.uuid4().hex[:8]}"
    device_a.drain_events(timeout=0.5)
    device_b.drain_events(timeout=0.5)

    network_control.offline("device_a")
    _wait_connected(device_a, False)

    response = device_b.call(
        "ChatManager",
        Cmd.sendMessage.value,
        info=build_text(user_b, user_a, content),
    )
    assert_api.assert_success(response)

    network_control.online("device_a")
    _wait_connected(device_a, True)

    deadline = time.monotonic() + 30
    seen = []
    while time.monotonic() < deadline:
        event = device_a.receive_message(
            match_event_type=Cmd.onMessagesReceived.value,
            timeout=min(2, max(0.1, deadline - time.monotonic())),
        )
        if event:
            seen.append(event)
        messages = ((event or {}).get("data") or {}).get("messages") or []
        if any(
            (message.get("body") or {}).get("content") == content
            and message.get("from") == user_b
            and message.get("to") == user_a
            for message in messages
        ):
            return
    pytest.fail(f"恢复网络后未收到离线消息: content={content}, seen={seen}")
