from __future__ import annotations

from pathlib import Path

from src.orchestrator.config import load_artifacts, load_scenario
from src.orchestrator.runner_registry import RunnerRegistry


ROOT = Path(__file__).resolve().parents[2]


def test_phase1_scenario_binds_roles_to_distinct_versions():
    scenario = load_scenario(
        ROOT / "config/scenarios/android_410_414.yaml"
    )

    assert scenario.roles["device_a"].sdk_version == "4.10.0"
    assert scenario.roles["device_b"].sdk_version == "4.14.0"
    assert scenario.roles["device_a"].device_name == "deviceA"
    assert scenario.roles["device_b"].device_name == "deviceB"


def test_new_scenario_supports_six_slots_and_same_account_binding():
    scenario = load_scenario(
        ROOT / "config/scenarios/android_423_multi_device.yaml"
    )

    assert set(scenario.roles) == {
        "device_a",
        "device_a_sec",
        "device_b",
        "device_b_sec",
        "device_c",
        "device_c_sec",
    }
    assert scenario.roles["device_a"].account == "account_a"
    assert scenario.roles["device_a_sec"].account == "account_a"
    assert scenario.roles["device_b"].account == "account_b"
    assert scenario.keep_device_alive is True
    assert scenario.start_emulators is False
    assert scenario.hello_timeout == 30
    topology = scenario.topologies["direct_chat_delivery"]
    assert topology.sender_action_device == "device_b"
    assert topology.sender_devices == ("device_b",)
    assert topology.recipient_devices == ("device_a", "device_a_sec")


def test_scenario_topology_automatically_includes_new_account_devices(tmp_path):
    scenario_file = tmp_path / "cross_platform-topology.yaml"
    scenario_file.write_text(
        """
name: cross-platform-topology
accounts:
  user_1: {provision: rest}
  user_2: {provision: rest}
devices:
  u1_android: {platform: android, sdk_version: 4.23.0, account: user_1}
  u1_ios: {platform: ios, sdk_version: 4.23.0, account: user_1}
  u1_web: {platform: web, sdk_version: 4.23.0, account: user_1}
  u2_android: {platform: android, sdk_version: 4.23.0, account: user_2}
topologies:
  direct_chat_delivery:
    sender: {account: user_2, action_device: u2_android}
    recipient: {account: user_1}
""",
        encoding="utf-8",
    )

    topology = load_scenario(scenario_file).topologies["direct_chat_delivery"]

    assert topology.sender_devices == ("u2_android",)
    assert topology.recipient_devices == (
        "u1_android",
        "u1_ios",
        "u1_web",
    )


def test_scenario_supports_existing_account_without_cleanup(tmp_path):
    scenario_file = tmp_path / "existing.yaml"
    scenario_file.write_text(
        """
name: existing-account
accounts:
  account_a:
    provision: existing
    username: fixed-user
    password: fixed-password
devices:
  device_a:
    platform: android
    sdk_version: 4.23.0
    account: account_a
""",
        encoding="utf-8",
    )

    scenario = load_scenario(scenario_file)

    assert scenario.accounts["account_a"].provision == "existing"
    assert scenario.accounts["account_a"].username == "fixed-user"
    assert scenario.roles["device_a"].device_name == "deviceA"


def test_artifact_catalog_uses_same_application_id_for_upgrade():
    artifacts = load_artifacts(ROOT / "config/artifacts.yaml")
    old = artifacts[("android", "4.10.0")]
    new = artifacts[("android", "4.14.0")]

    assert old.application_id == new.application_id
    assert old.path.name == "app-sdk410-debug.apk"
    assert new.path.name == "app-sdk414-debug.apk"


def test_registry_rejects_reported_version_mismatch(tmp_path):
    scenario = load_scenario(
        ROOT / "config/scenarios/android_410_414.yaml"
    )
    artifact = load_artifacts(ROOT / "config/artifacts.yaml")[
        ("android", "4.10.0")
    ]
    registry = RunnerRegistry()

    try:
        registry.register(
            role=scenario.roles["device_a"],
            artifact=artifact,
            serial="emulator-5554",
            hello={
                "runnerId": "android-410-device-a",
                "deviceName": "deviceA",
                "platform": "android",
                "sdkVersion": "4.14.0",
            },
        )
    except Exception as error:
        assert "does not match scenario" in str(error)
    else:
        raise AssertionError("version mismatch was accepted")


def test_registry_rejects_two_roles_bound_to_same_serial():
    scenario = load_scenario(
        ROOT / "config/scenarios/android_410_414.yaml"
    )
    artifacts = load_artifacts(ROOT / "config/artifacts.yaml")
    registry = RunnerRegistry()
    role_a = scenario.roles["device_a"]
    role_b = scenario.roles["device_b"]

    registry.register(
        role=role_a,
        artifact=artifacts[("android", "4.10.0")],
        serial="emulator-5554",
        hello={
            "runnerId": role_a.runner_id,
            "deviceName": role_a.device_name,
            "logicalDevice": role_a.role,
            "artifactId": artifacts[("android", "4.10.0")].artifact_id,
            "platform": role_a.platform,
            "sdkVersion": role_a.sdk_version,
            "appVersion": artifacts[("android", "4.10.0")].app_version,
            "wrapperCommit": artifacts[("android", "4.10.0")].wrapper_commit,
            "nativeSdkSha256": artifacts[
                ("android", "4.10.0")
            ].native_sdk_sha256,
            "capabilities": list(
                artifacts[("android", "4.10.0")].capabilities
            ),
        },
    )

    try:
        registry.register(
            role=role_b,
            artifact=artifacts[("android", "4.14.0")],
            serial="emulator-5554",
            hello={
                "runnerId": role_b.runner_id,
                "deviceName": role_b.device_name,
                "logicalDevice": role_b.role,
                "artifactId": artifacts[("android", "4.14.0")].artifact_id,
                "platform": role_b.platform,
                "sdkVersion": role_b.sdk_version,
                "appVersion": artifacts[("android", "4.14.0")].app_version,
                "wrapperCommit": artifacts[
                    ("android", "4.14.0")
                ].wrapper_commit,
                "nativeSdkSha256": artifacts[
                    ("android", "4.14.0")
                ].native_sdk_sha256,
                "capabilities": list(
                    artifacts[("android", "4.14.0")].capabilities
                ),
            },
        )
    except Exception as error:
        assert "not unique" in str(error)
        assert "serial" in str(error)
    else:
        raise AssertionError("duplicate serial binding was accepted")
