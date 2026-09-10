"""Exercise module wait paths with a virtual clock; never connect to devices."""
import pytest

from src import Cmd
from src.tools import assertions
from tests.client import test_client as client
from tests.group import group_helpers as group
from tests.group import test_group_message_send as send
from tests.group import test_group_offline_member_state as members
from tests.group import test_group_offline_roles_and_configuration as config
from tests.group import test_group_offline_message_delivery as delivery
from tests.chatroom import chatroom_helpers as room
from tests.chatroom import test_chatroom_members as room_members


class Clock:
    def __init__(self):
        self.now = 0.0

    def monotonic(self):
        return self.now

    def sleep(self, seconds):
        self.now += seconds


class Device:
    """Scheduled queue with the same retain-unmatched filtering as DeviceClient."""
    def __init__(self, clock, events=(), name="deviceB"):
        self.clock = clock
        self.events = list(events)
        self.name = name

    def receive_message(self, *, timeout, match_event_type=None):
        deadline = self.clock.now + timeout
        for index, (at, event) in enumerate(self.events):
            if at > deadline:
                continue
            if match_event_type is not None and event.get("eventType") != match_event_type:
                continue
            self.clock.now = max(self.clock.now, at)
            self.events.pop(index)
            return event
        self.clock.now = deadline
        return None

    def drain_events(self, timeout=2.0):
        self.clock.sleep(timeout)
        self.events = [(at, evt) for at, evt in self.events if at > self.clock.now]

    def call(self, manager, cmd, info):
        return {"manager": manager, "cmd": cmd, "device": self.name, "result": None}


@pytest.fixture
def clock(monkeypatch):
    clock = Clock()
    for name in ("GROUP_OFFLINE_MEMBER_SETTLE_SECONDS", "GROUP_OFFLINE_CONFIG_SETTLE_SECONDS", "GROUP_MESSAGE_MEMBER_SETTLE_SECONDS"):
        monkeypatch.delenv(name, raising=False)
    for module in (client, group, send, members, config, delivery, room, room_members):
        monkeypatch.setattr(module, "time", clock, raising=False)
    return clock


def event(kind, **data):
    return {"type": "event", "eventType": kind, "data": data}


@pytest.mark.parametrize("kind", [Cmd.onOfflineMessageSyncStart.value, Cmd.onOfflineMessageSyncFinish.value])
def test_client_accepts_either_sync_event_without_waiting_for_other(clock, kind):
    target = event(kind)
    result = client._wait_offline_sync_event(Device(clock, [(0.05, target)]))
    assert result is target
    assert clock.now == pytest.approx(0.05)


def test_client_sync_restores_15_second_budget(clock):
    with pytest.raises(AssertionError, match="离线同步"):
        client._wait_offline_sync_event(Device(clock, [(0, event("unrelated"))]))
    assert clock.now == pytest.approx(15)


@pytest.mark.parametrize("kind,label", [(Cmd.onMessageSuccess.value, "success"), (Cmd.onMessageError.value, "error")])
def test_group_send_terminal_returns_first_matching_outcome(clock, kind, label):
    target = event(kind, msgId="target")
    result = send._wait_send_terminal(Device(clock, [
        (0, event(kind, msgId="other")), (0.05, target),
    ]), temp_id="target")
    assert result == (label, target)
    assert clock.now == pytest.approx(0.05)


def test_group_send_terminal_does_not_overrun_fractional_budget(clock):
    with pytest.raises(pytest.fail.Exception, match="发送终态"):
        send._wait_send_terminal(Device(clock), temp_id="target", timeout=0.25)
    assert clock.now == pytest.approx(0.25)


def test_group_collection_restores_one_second_polling(clock):
    first = event("one", groupId="g")
    second = event("two", groupId="g")
    result = group.collect_group_events(Device(clock, [(0, first), (0.3, second)]),
        expected_event_types={"one", "two"}, required_all_event_types={"one", "two"},
        group_id="g", idle_grace_window=0.8)
    assert result == [first, second]
    assert clock.now == pytest.approx(1.3)


def test_group_collection_cannot_finish_before_all_required_types(clock):
    first = event("one", groupId="g")
    with pytest.raises(AssertionError, match="群组回调未满足"):
        group.collect_group_events(Device(clock, [(0, first)]),
            expected_event_types={"one", "two"}, required_all_event_types={"one", "two"},
            group_id="g", timeout=2.5)
    assert clock.now == pytest.approx(2.5)


def test_group_negative_observation_keeps_full_window(clock):
    group.assert_no_group_event(Device(clock), group_id="g", event_types={"one"}, timeout=2.5)
    assert clock.now == pytest.approx(2.5)


def test_group_negative_observation_rejects_late_event(clock):
    with pytest.raises(AssertionError, match="不应收到群事件"):
        group.assert_no_group_event(Device(clock, [(2.4, event("one", groupId="g"))]),
            group_id="g", event_types={"one"}, timeout=2.5)


def invitation(group_id="g", inviter="a"):
    return event("onAutoAcceptInvitationFromGroup", groupId=group_id, inviter=inviter, inviteMessage="")


def test_group_readiness_ignores_other_groups_and_returns_on_target(clock):
    group.wait_member_auto_joined(Device(clock, [(0, invitation("other")), (0.05, invitation())]),
        assertions, group_id="g", inviter="a")
    assert clock.now == pytest.approx(0.05)


def test_group_readiness_requires_strict_inviter(clock):
    with pytest.raises(AssertionError, match="inviter"):
        group.wait_member_auto_joined(Device(clock, [(0, invitation(inviter="wrong"))]),
            assertions, group_id="g", inviter="a")


def test_group_readiness_times_out_instead_of_silently_sleeping(clock):
    with pytest.raises(AssertionError, match="自动入群"):
        group.wait_member_auto_joined(Device(clock), assertions, group_id="g", inviter="a", timeout=3)
    assert clock.now == pytest.approx(3)


@pytest.mark.parametrize("module,helper,drain_budget", [
    (members, "_create_member_group", 2.0),
    (config, "_create_config_group", 2.0),
    (delivery, "_create_message_group", 2.0),
])
def test_offline_group_setup_restores_sleep_and_keeps_readiness(clock, monkeypatch, module, helper, drain_budget):
    a, b = Device(clock, name="deviceA"), Device(clock)

    def create(*args, **kwargs):
        b.events.append((clock.now + 0.05, invitation()))
        return "g", {}

    monkeypatch.setattr(module, "create_group", create)
    monkeypatch.setattr(module, "new_group_name", lambda prefix: "name")
    result = getattr(module, helper)(a, b, assertions, user_a="a", user_b="b", name_prefix="test")
    assert result == ("g", "name")
    settle = 5.0 if module is delivery else 3.0
    assert clock.now == pytest.approx(drain_budget + settle)


def test_chatroom_ext_observer_restores_half_second_collection(clock, monkeypatch):
    target = event("onMemberJoinedFromChatRoom", roomId="r", participant="a", ext="avatar")
    observer = Device(clock, [(0.05, target)])
    monkeypatch.setattr(room_members, "_assert_join_response", lambda *args, **kwargs: None)
    room_members._assert_joiner_ext_delivered_to_observer(assertions,
        room_id="r", observer_device=observer, observer_device_name="deviceB",
        observer_join_result_shape="unused", observer_user="b",
        joiner_device=Device(clock, name="deviceA"), joiner_device_name="deviceA",
        joiner_result_shape="unused", joiner_user="a", ext="avatar")
    assert clock.now == pytest.approx(0.5)


@pytest.mark.parametrize("module,helper", [
    (members, "_create_member_group"),
    (config, "_create_config_group"),
    (delivery, "_create_message_group"),
])
def test_offline_group_setup_cleans_up_if_readiness_fails(clock, monkeypatch, module, helper):
    a, b = Device(clock, name="deviceA"), Device(clock)
    destroyed = []
    monkeypatch.setattr(module, "create_group", lambda *args, **kwargs: ("g", {}))
    monkeypatch.setattr(module, "new_group_name", lambda prefix: "name")
    monkeypatch.setattr(module, "safe_destroy_group", lambda device, group_id: destroyed.append(group_id))
    with pytest.raises(AssertionError, match="自动入群"):
        getattr(module, helper)(a, b, assertions, user_a="a", user_b="b", name_prefix="test")
    assert destroyed == ["g"]


def test_chatroom_ext_nonmatching_events_do_not_exhaust_retry_count(clock, monkeypatch):
    unrelated = event("onMemberJoinedFromChatRoom", roomId="r", participant="other", ext="avatar")
    target = event("onMemberJoinedFromChatRoom", roomId="r", participant="a", ext="avatar")
    observer = Device(clock, [(0.5 * i, unrelated) for i in range(18)] + [(9.5, target)])
    monkeypatch.setattr(room_members, "_assert_join_response", lambda *args, **kwargs: None)
    room_members._assert_joiner_ext_delivered_to_observer(assertions,
        room_id="r", observer_device=observer, observer_device_name="deviceB",
        observer_join_result_shape="unused", observer_user="b",
        joiner_device=Device(clock, name="deviceA"), joiner_device_name="deviceA",
        joiner_result_shape="unused", joiner_user="a", ext="avatar")
    assert clock.now <= 10


def test_chatroom_full_collection_still_observes_entire_window(clock):
    target = event("onMemberJoinedFromChatRoom", roomId="r", participant="a", ext="avatar")
    result = room.collect_chatroom_events(Device(clock, [(0.05, target)]),
        expected_event_types={"onMemberJoinedFromChatRoom"}, chatroom_id="r", timeout=2.0)
    assert result == [target]
    assert clock.now == pytest.approx(2.0)
