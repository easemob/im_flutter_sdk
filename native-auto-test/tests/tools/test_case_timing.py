"""Timing configuration tests: no device or external service access."""
from types import SimpleNamespace

import pytest

from src.tools import config


def timing_module():
    from src.tools import case_timing
    return case_timing


_REAL_TIMING_CONFIG = config.get_case_timing_config


@pytest.fixture(autouse=True)
def timing_config(monkeypatch, isolated_case_timing):
    monkeypatch.setattr(config, "get_case_timing_config", _REAL_TIMING_CONFIG)
    monkeypatch.setattr(config, "load_env_config", lambda: {"app": {}})


def test_effective_special_defaults():
    timing = timing_module()
    for key, expected in {"step.interval": 1, "settle.offline": 3,
                          "settle.normal": 5, "settle.slow": 15,
                          "settle.parent_message": 5,
                          "settle.thumbnail_completion": 30,
                          "settle.cursor_order": 1.1}.items():
        assert timing.seconds(key, module="group") == expected


@pytest.mark.parametrize("value", [-1, True, False, float("inf"), float("nan"), "bad", None])
def test_invalid_value_is_rejected_without_leaking_config(monkeypatch, value):
    monkeypatch.setattr(config, "load_env_config", lambda: {
        "app": {"server": {"client_secret": "DO_NOT_PRINT"},
                "case_timing": {"step": value}}})
    with pytest.raises(ValueError, match="step.interval") as error:
        timing_module().seconds("step.interval", module="chat")
    assert "DO_NOT_PRINT" not in str(error.value)


@pytest.mark.parametrize("section", [None, [], "invalid"])
def test_invalid_section_is_rejected(monkeypatch, section):
    monkeypatch.setattr(config, "load_env_config", lambda: {
        "app": {"case_timing": section}})
    with pytest.raises(ValueError, match="case_timing"):
        timing_module().seconds("step.interval", module="chat")


@pytest.mark.parametrize("configured", [False, True])
def test_offline_flow_waits_in_order_and_preserves_events(monkeypatch, configured):
    from src.test_flow import offline_test_flow as flow
    timing = timing_module()
    delays = [3, 3, 3]
    drain = 0.5
    if configured:
        delays = [4, 4, 4]
        drain = 0.05
        monkeypatch.setattr(config, "load_env_config", lambda: {"app": {"case_timing": {
            "settle": {"offline": 8, "group": {"offline": 4}},
            "drain": {"offline": drain},
        }}})
    actions = []

    class Device:
        def __init__(self):
            self.events = []
            self.current = "user"

        def drain_events(self, timeout):
            actions.append(("drain", timeout))
            self.events.clear()

        def call(self, manager, cmd, info):
            actions.append(("call", cmd))
            if cmd == "login":
                self.current = "user"
                self.events.append({"eventType": "offline-result"})
            elif cmd == "logout":
                self.current = ""
            result = self.current if cmd == "getCurrentUser" else {
                "logout": True, "login": "user", "startCallback": None}[cmd]
            return {"manager": manager, "cmd": cmd, "device": "deviceB", "result": result}

    from src.tools import assertions
    monkeypatch.setattr(timing.time, "sleep", lambda value: actions.append(("sleep", value)))
    device = Device()
    flow.logout_for_offline(device, assertions, device_name="deviceB", module="group")
    actions.append(("business", "invite"))
    flow.login_preserving_offline_events(device, assertions, device_name="deviceB", user_id="user", module="group")
    # 登出后与重登后的 settle 改为有界等待：探针一次命中即继续，不再消耗预算；
    # 重登前的固定等待保留（无本地只读探针），预算值不变。
    assert actions == [
        ("drain", drain), ("call", "logout"), ("drain", drain), ("call", "getCurrentUser"),
        ("business", "invite"), ("sleep", delays[1]), ("call", "login"),
        ("call", "startCallback"), ("call", "getCurrentUser"),
    ]
    assert device.events == [{"eventType": "offline-result"}]


@pytest.mark.parametrize("stage", ["logout", "login"])
def test_offline_login_state_that_never_settles_fails_at_the_bound(monkeypatch, stage):
    from src.test_flow import offline_test_flow as flow
    timing = timing_module()
    clock = {"now": 0.0}
    slept = []

    def sleep(duration):
        slept.append(duration)
        clock["now"] += duration

    monkeypatch.setattr(timing, "time", SimpleNamespace(
        monotonic=lambda: clock["now"], sleep=sleep))

    class Device:
        def drain_events(self, timeout):
            pass

        def call(self, manager, cmd, info):
            # 登出后仍显示已登录 / 重登后仍为空：都必须在上限处报错，不能静默通过。
            result = {"logout": True, "login": "user", "startCallback": None,
                      "getCurrentUser": "user" if stage == "logout" else ""}[cmd]
            return {"manager": manager, "cmd": cmd, "device": "deviceB", "result": result}

    from src.tools import assertions
    with pytest.raises(AssertionError, match="有界等待超时"):
        if stage == "logout":
            flow.logout_for_offline(Device(), assertions, device_name="deviceB", module="group")
        else:
            flow.login_preserving_offline_events(
                Device(), assertions, device_name="deviceB", user_id="user", module="group")
    # settle.offline=3、poll.interval=1：预算被完整消耗且不越过上限（login 分支含重登前固定 3s）。
    assert sum(slept) == pytest.approx(3 if stage == "logout" else 6)
