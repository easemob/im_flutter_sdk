from __future__ import annotations

import json
import shutil
import subprocess
from urllib.parse import urlsplit

from .config import Artifact, RoleSpec


class IOSSimulatorError(RuntimeError):
    pass


class IOSSimulatorDevice:
    """Lifecycle adapter for a user-started iOS Simulator."""

    def __init__(self, role: RoleSpec, *, startup_timeout: float) -> None:
        self.role = role
        self.startup_timeout = startup_timeout
        self.xcrun = shutil.which("xcrun")
        self.serial: str | None = None

    def ensure_started(self) -> str:
        if not self.xcrun:
            raise IOSSimulatorError("xcrun is not available on PATH")
        if not self.role.serial:
            raise IOSSimulatorError(
                f"role={self.role.role} requires serial to be an iOS Simulator UDID"
            )
        devices = json.loads(
            self._run([self.xcrun, "simctl", "list", "devices", self.role.serial, "-j"])
        ).get("devices", {})
        matching = [item for values in devices.values() for item in values if item.get("udid") == self.role.serial]
        if not matching or matching[0].get("state") != "Booted":
            raise IOSSimulatorError(
                f"configured iOS Simulator {self.role.serial!r} is not booted"
            )
        self.serial = self.role.serial
        return self.serial

    def install(self, artifact: Artifact, *, replace: bool = True) -> str:
        del replace
        serial = self._require_serial()
        if not artifact.path.is_dir():
            raise IOSSimulatorError(f"Runner.app does not exist: {artifact.path}")
        return self._run([self.xcrun, "simctl", "install", serial, str(artifact.path)])

    def launch(self, artifact: Artifact, *, runner_id: str, device_name: str, topic: str, web_socket_base_url: str, run_id: str = "", logical_device: str = "", artifact_id: str = "", wrapper_commit: str = "", native_sdk_sha256: str = "", managed_web_socket: bool = False) -> str:
        serial = self._require_serial()
        values = {
            "runnerId": runner_id,
            "runnerDevice": device_name,
            "runnerWsBaseUrl": web_socket_base_url,
            "runnerRunId": run_id,
            "runnerLogicalDevice": logical_device,
            "runnerArtifactId": artifact_id,
            "runnerWrapperCommit": wrapper_commit,
            "runnerNativeSdkSha256": native_sdk_sha256,
            "runnerWsManaged": str(managed_web_socket).lower(),
        }
        if topic:
            values["runnerTopic"] = topic
        return self._run(
            [self.xcrun, "simctl", "launch", "--terminate-running-process", serial, artifact.application_id]
            + [f"{key}={value}" for key, value in values.items()]
        )

    def prepare_web_socket_url(self, value: str) -> str:
        parsed = urlsplit(value)
        if parsed.hostname in {"127.0.0.1", "localhost"} and parsed.port is None:
            raise IOSSimulatorError(f"local WebSocket URL must include a port: {value}")
        return value

    def stop_emulator(self) -> None:
        return None

    def _require_serial(self) -> str:
        if not self.serial:
            raise IOSSimulatorError("device has not been started")
        return self.serial

    @staticmethod
    def _run(command: list[str], timeout: float = 120) -> str:
        completed = subprocess.run(command, check=False, capture_output=True, text=True, timeout=timeout)
        output = "\n".join(value for value in (completed.stdout.strip(), completed.stderr.strip()) if value)
        if completed.returncode != 0:
            raise IOSSimulatorError(f"command failed ({completed.returncode}): {' '.join(command)}\n{output}")
        return output
