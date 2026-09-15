from __future__ import annotations
from src.tools.case_timing_defaults import RECEIVE_TIMEOUT_FLOOR
from src.tools.case_timing import pause as timing_pause
from src.tools.case_timing import seconds as timing_seconds

import time
import uuid

import pytest

from src import Cmd
from tests.chat.test_chat_recall_and_message_read_ack import _send_typed

pytestmark = [pytest.mark.client, pytest.mark.chat]


def _wait_pin_event(device, *, msg_id, operation, timeout=None):
    timeout = timing_seconds('timeout.message_change', module='chat') if timeout is None else timeout
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        event = device.receive_message(match_event_type=Cmd.onMessagePinChanged.value, timeout=timing_seconds('poll.receive', module='chat'))
        if event:
            seen.append(event)
        data = (event or {}).get("data") or {}
        if str(data.get("messageId")) == str(msg_id) and data.get("pinOperation") == operation:
            return event
    pytest.fail(f"未收到消息置顶事件: msgId={msg_id}, operation={operation}, seen={seen}")


def _assert_no_pin_event(device, *, msg_id, operation, timeout=None):
    timeout = timing_seconds('observe.no_event', module='chat') if timeout is None else timeout
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        event = device.receive_message(
            match_event_type=Cmd.onMessagePinChanged.value,
            timeout=min(timing_seconds('poll.receive_batch', module='chat'), max(RECEIVE_TIMEOUT_FLOOR, deadline - time.monotonic())),
        )
        if event:
            seen.append(event)
        data = (event or {}).get("data") or {}
        if str(data.get("messageId")) == str(msg_id) and data.get("pinOperation") == operation:
            pytest.fail(f"操作者端不应收到消息置顶事件: msgId={msg_id}, operation={operation}, seen={seen}")


def _assert_pin_event(assert_api, event, *, msg_id, conversation_id, operation, operator_id):
    assert_api.assert_response_matches(
        event,
        expected={
            "type": "event",
            "eventType": Cmd.onMessagePinChanged.value,
            "data": {
                "messageId": msg_id,
                "conversationId": conversation_id,
                "pinOperation": operation,
                "pinInfo": {"operatorId": operator_id},
            },
        },
        ignore_keys={"timestamp", "sequence", "pinTime"},
    )


def _assert_pin_delivery_for_actor(
    assert_api,
    *,
    device_a,
    device_b,
    msg_id,
    operation,
    operator_id,
    user_a,
    user_b,
):
    if operator_id == user_a:
        event = _wait_pin_event(device_b, msg_id=msg_id, operation=operation)
        _assert_pin_event(
            assert_api,
            event,
            msg_id=msg_id,
            conversation_id=user_a,
            operation=operation,
            operator_id=operator_id,
        )
        _assert_no_pin_event(device_a, msg_id=msg_id, operation=operation)
        return

    _assert_no_pin_event(device_a, msg_id=msg_id, operation=operation)
    _assert_no_pin_event(device_b, msg_id=msg_id, operation=operation)
