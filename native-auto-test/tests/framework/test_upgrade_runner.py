from __future__ import annotations

from pathlib import Path

from src.orchestrator.config import Artifact, RoleSpec
from src.orchestrator.upgrade_runner import UpgradeRunner


class _FakeDevice:
    def __init__(self) -> None:
        self.installed: list[str] = []
        self.launched: list[str] = []

    def install(self, artifact, *, replace=True):
        assert replace is True
        self.installed.append(artifact.sdk_version)
        return "Success"

    def launch(self, artifact, **kwargs):
        self.launched.append(artifact.sdk_version)
        return "Complete"


class _FakeChannel:
    def __init__(self) -> None:
        self.calls: list[tuple[str, str]] = []
        self.marker = ""

    def call(self, manager, cmd, info=None, **kwargs):
        self.calls.append((manager, cmd))
        if cmd == "createUpgradeMessage":
            self.marker = info["marker"]
            return {
                "result": {
                    "exists": True,
                    "marker": self.marker,
                }
            }
        if cmd == "login":
            return {"result": info["userId"]}
        if cmd == "exportUpgradeSnapshot":
            return {
                "result": {
                    "exists": True,
                    "marker": self.marker,
                    "messageId": self.marker,
                }
            }
        if cmd == "getAllContactsFromServer":
            return {"result": []}
        raise AssertionError(f"unexpected call: {manager}.{cmd}")

    def clear_runner_info(self):
        return None

    def wait_for_hello(self, **kwargs):
        return {
            "runnerId": kwargs["expected_runner_id"],
            "deviceName": kwargs["expected_device_name"],
            "platform": kwargs["expected_platform"],
            "sdkVersion": kwargs["expected_sdk_version"],
        }


def _artifact(version: str, flavor: str) -> Artifact:
    return Artifact(
        platform="android",
        sdk_version=version,
        path=Path(f"{flavor}.apk"),
        flavor=flavor,
        application_id="com.easemob.im_flutter_test",
        activity=".MainActivity",
    )


def test_upgrade_runner_checks_local_data_then_online_sync(monkeypatch):
    monkeypatch.setattr(
        "src.orchestrator.upgrade_runner.time.sleep",
        lambda _: None,
    )
    device = _FakeDevice()
    channel = _FakeChannel()
    runner = UpgradeRunner(
        device=device,
        channel=channel,
        role=RoleSpec(
            role="device_a",
            device_name="deviceA",
            platform="android",
            sdk_version="4.10.0",
            runner_id="android-410-device-a",
        ),
        old_artifact=_artifact("4.10.0", "sdk410"),
        new_artifact=_artifact("4.14.0", "sdk414"),
        topic="phase1-a",
        web_socket_base_url="ws://127.0.0.1:9000/relay",
        startup_timeout=30,
        user_id="user-a",
        password="1",
    )

    result = runner.run_message_retention(marker="upgrade-marker")

    assert device.installed == ["4.14.0"]
    assert device.launched == ["4.14.0"]
    assert result.new_snapshot["messageId"] == "upgrade-marker"
    assert result.post_upgrade_sync == {"result": []}
    assert channel.calls[-1] == (
        "ContactManager",
        "getAllContactsFromServer",
    )
