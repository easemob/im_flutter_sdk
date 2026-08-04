from __future__ import annotations

import hashlib
from dataclasses import dataclass
from pathlib import Path

from .android_device import AndroidDevice, AndroidEnvironmentError
from .config import Artifact, Scenario, load_artifacts, load_scenario
from .ios_simulator import IOSSimulatorDevice


@dataclass
class EnvironmentRuntime:
    scenario: Scenario
    artifacts: dict[str, Artifact]
    devices: dict[str, AndroidDevice | IOSSimulatorDevice]

    def device_for(self, role: str) -> AndroidDevice | IOSSimulatorDevice:
        return self.devices[role]

    def artifact_for(self, role: str) -> Artifact:
        return self.artifacts[role]


class EnvironmentManager:
    def __init__(
        self,
        scenario_path: str | Path,
        artifacts_path: str | Path,
        *,
        web_socket_base_url: str,
        topics: dict[str, str] | None = None,
        run_id: str = "",
        managed_web_socket: bool = False,
        active_roles: set[str] | None = None,
        skip_hash_validation: bool = False,
    ) -> None:
        self.scenario = load_scenario(scenario_path)
        self.artifact_catalog = load_artifacts(artifacts_path)
        self.web_socket_base_url = web_socket_base_url
        self.topics = topics or {}
        self.run_id = run_id
        self.managed_web_socket = managed_web_socket
        self.active_roles = active_roles
        self.skip_hash_validation = skip_hash_validation
        self.runtime: EnvironmentRuntime | None = None

    def start(self) -> EnvironmentRuntime:
        claimed: set[str] = set()
        devices: dict[str, AndroidDevice | IOSSimulatorDevice] = {}
        artifacts: dict[str, Artifact] = {}
        try:
            selected = (
                set(self.scenario.roles)
                if self.active_roles is None
                else set(self.active_roles)
            )
            missing = sorted(selected - set(self.scenario.roles))
            if missing:
                raise AndroidEnvironmentError(
                    f"scenario {self.scenario.name!r} does not define roles: {missing}"
                )
            for role_name in sorted(selected):
                role = self.scenario.roles[role_name]
                key = (role.platform, role.sdk_version)
                if key not in self.artifact_catalog:
                    raise AndroidEnvironmentError(
                        f"artifact is not configured for {role.platform} {role.sdk_version}"
                    )
                artifact = self.artifact_catalog[key]
                self._validate_artifact(artifact)
                if self.skip_hash_validation:
                    print(f"[env] skipping hash validation for {artifact.path.name}")
                else:
                    self._validate_artifact_hash(artifact)
                if role.platform == "android":
                    device = AndroidDevice(
                        role,
                        startup_timeout=self.scenario.startup_timeout,
                        claimed_serials=claimed,
                        allow_avd_start=self.scenario.start_emulators,
                    )
                elif role.platform == "ios":
                    device = IOSSimulatorDevice(
                        role,
                        startup_timeout=self.scenario.startup_timeout,
                    )
                else:
                    raise AndroidEnvironmentError(
                        f"unsupported platform {role.platform!r}; expected android or ios"
                    )
                last_error: Exception | None = None
                for attempt in range(self.scenario.start_retry + 1):
                    try:
                        device.ensure_started()
                        device.install(artifact, replace=True)
                        last_error = None
                        break
                    except Exception as error:
                        last_error = error
                        if attempt >= self.scenario.start_retry:
                            raise
                if last_error is not None:
                    raise last_error
                runner_web_socket_url = device.prepare_web_socket_url(
                    self.web_socket_base_url
                )
                device.launch(
                    artifact,
                    runner_id=role.runner_id,
                    device_name=role.device_name,
                    topic=self.topics.get(role.device_name, ""),
                    web_socket_base_url=runner_web_socket_url,
                    run_id=self.run_id,
                    logical_device=role.role,
                    artifact_id=artifact.artifact_id,
                    wrapper_commit=artifact.wrapper_commit,
                    native_sdk_sha256=artifact.native_sdk_sha256,
                    managed_web_socket=self.managed_web_socket,
                )
                devices[role_name] = device
                artifacts[role_name] = artifact
        except Exception:
            for device in devices.values():
                if self.scenario.shutdown_on_finish:
                    device.stop_emulator()
            raise
        self.runtime = EnvironmentRuntime(self.scenario, artifacts, devices)
        return self.runtime

    @staticmethod
    def _validate_artifact(artifact: Artifact) -> None:
        if artifact.manifest_path is None:
            raise AndroidEnvironmentError(
                f"artifact manifest is required for "
                f"{artifact.platform} {artifact.sdk_version}"
            )
        if not artifact.path.exists():
            raise AndroidEnvironmentError(
                f"artifact path does not exist: {artifact.path}"
            )
        if not artifact.artifact_sha256:
            raise AndroidEnvironmentError(
                f"artifactSha256 is missing: {artifact.manifest_path}"
            )
        if not artifact.wrapper_commit or not artifact.native_sdk_sha256:
            raise AndroidEnvironmentError(
                f"wrapperCommit/nativeSdkSha256 missing: "
                f"{artifact.manifest_path}"
            )
        if not artifact.capabilities:
            raise AndroidEnvironmentError(
                f"capabilities missing: {artifact.manifest_path}"
            )

    @staticmethod
    def _validate_artifact_hash(artifact: Artifact) -> None:
        if artifact.artifact_sha256 == "runtime":
            return
        if not artifact.artifact_sha256:
            return
        digest = hashlib.sha256(artifact.path.read_bytes()).hexdigest()
        if digest != artifact.artifact_sha256:
            raise AndroidEnvironmentError(
                f"artifact hash mismatch: path={artifact.path}, "
                f"expected={artifact.artifact_sha256}, actual={digest}"
            )
            raise AndroidEnvironmentError(
                f"wrapperCommit/nativeSdkSha256 missing: "
                f"{artifact.manifest_path}"
            )
        if not artifact.capabilities:
            raise AndroidEnvironmentError(
                f"capabilities missing: {artifact.manifest_path}"
            )

    def stop(self) -> None:
        if self.runtime and self.scenario.shutdown_on_finish:
            for device in self.runtime.devices.values():
                device.stop_emulator()
        self.runtime = None
