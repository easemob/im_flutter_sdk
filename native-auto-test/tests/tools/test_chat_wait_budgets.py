"""Offline regression tests for chat waits; no SDK/REST/device calls."""
from types import SimpleNamespace

import pytest

from src import Cmd
from src.tools import assertions
from tests.chat import test_chat_reaction_fetch as reaction
from tests.chat import test_chat_offline_message_operations as offline
from tests.chat import test_chat_s423_message_callback_and_combine as combine


class Clock:
    def __init__(self):
        self.now = 0.0

    def monotonic(self):
        return self.now

    def sleep(self, seconds):
        self.now += seconds


class Device:
    def __init__(self, clock, events=()):
        self.clock = clock
        self.events = list(events)

    def receive_message(self, *, timeout, **kwargs):
        if self.events:
            self.clock.now += 0.01
            return self.events.pop(0)
        self.clock.now += timeout
        return None

    def call(self, manager, cmd, info):
        return {"manager": manager, "cmd": cmd, "device": "deviceB",
                "result": {"msgId": "target", "body": {"type": 2, "thumbnailStatus": 0}}}


@pytest.fixture
def clock(monkeypatch):
    clock = Clock()
    for module in (reaction, offline, combine):
        monkeypatch.setattr(module, "time", SimpleNamespace(monotonic=clock.monotonic, sleep=clock.sleep))
    return clock


@pytest.mark.parametrize("name,kwargs", [
    ("_wait_message_success", {"temp_id": "target"}),
    ("_wait_received_message", {"msg_id": "target", "from_user": "a", "to_user": "b"}),
    ("_wait_delivered_message", {"msg_id": "target", "from_user": "a", "to_user": "b"}),
])
def test_combine_wait_restores_eight_rounds(clock, name, kwargs):
    with pytest.raises(pytest.fail.Exception):
        getattr(combine, name)(Device(clock), timeout=2.5, **kwargs)
    assert clock.now == pytest.approx(8 * 2.5)


def test_reaction_default_timeout_is_60_seconds(clock):
    with pytest.raises(AssertionError, match="未收到目标 reaction"):
        reaction._wait_reaction_change_event(Device(clock), real_id="target", operator="a",
                                             reaction="like", is_added_by_self=True)
    assert clock.now == pytest.approx(60.0)


def test_offline_pin_default_timeout_is_60_seconds(clock):
    with pytest.raises(AssertionError, match="未收到离线消息置顶事件"):
        offline._wait_pin_change(Device(clock), real_id="target", operation="pin")
    assert clock.now == pytest.approx(60.0)


def test_offline_pin_returns_immediately_on_matching_event(clock):
    target = {"data": {"messageId": "target", "pinOperation": "pin"}}
    result = offline._wait_pin_change(
        Device(clock, [{"data": {"messageId": "other", "pinOperation": "pin"}}, target]),
        real_id="target", operation="pin",
    )
    assert result is target
    assert clock.now < 0.1


def success_event(status=1, msg_id="target"):
    return {"type": "event", "eventType": Cmd.onMessageSuccess.value,
            "data": {"msgId": msg_id, "msg": {"msgId": msg_id,
                     "body": {"type": 2, "thumbnailStatus": status}}}}


def test_thumbnail_download_returns_only_after_matching_success(clock):
    device = Device(clock, [success_event(msg_id="other"), success_event()])
    combine._assert_combine_thumbnail_download_completed(device, assertions,
        message={"msgId": "target"})
    assert clock.now == pytest.approx(30.02)


def test_thumbnail_download_error_fails_immediately(clock):
    event = {"type": "event", "eventType": Cmd.onMessageError.value,
             "data": {"msgId": "target", "error": {"code": 403, "description": "download failed"}}}
    with pytest.raises(pytest.fail.Exception, match="403"):
        combine._assert_combine_thumbnail_download_completed(Device(clock, [event]), assertions,
            message={"msgId": "target"})
    assert clock.now == pytest.approx(30.01)


def test_thumbnail_download_requires_completed_status(clock):
    with pytest.raises(AssertionError, match="thumbnailStatus"):
        combine._assert_combine_thumbnail_download_completed(Device(clock, [success_event(0)]), assertions,
            message={"msgId": "target"})


def test_thumbnail_download_times_out_without_terminal_event(clock):
    with pytest.raises(pytest.fail.Exception, match="下载完成"):
        combine._assert_combine_thumbnail_download_completed(Device(clock), assertions,
            message={"msgId": "target"}, timeout=3.0)
    assert clock.now == pytest.approx(33.0)
