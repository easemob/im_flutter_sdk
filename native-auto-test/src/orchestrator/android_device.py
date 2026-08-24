from __future__ import annotations

import shutil
import subprocess
import time
import os
from pathlib import Path
from urllib.parse import urlsplit

from .config import Artifact, RoleSpec


class AndroidEnvironmentError(RuntimeError):
    pass


class AndroidDevice:
    def __init__(
        self,
        role: RoleSpec,
        *,
        startup_timeout: float,
        claimed_serials: set[str] | None = None,
        allow_avd_start: bool = True,
    ) -> None:
        self.role = role
        self.startup_timeout = startup_timeout
        self.claimed_serials = claimed_serials if claimed_serials is not None else set()
        self.allow_avd_start = allow_avd_start
        self.adb = _find_android_tool("adb")
        self.emulator = _find_android_tool("emulator")
        self.serial: str | None = None
        self._process: subprocess.Popen[bytes] | None = None

    def ensure_started(self) -> str:
        if not self.adb:
            raise AndroidEnvironmentError("adb is not available on PATH")
        online = self.online_serials()
        if self.role.serial:
            if self.role.serial not in online:
                raise AndroidEnvironmentError(
                    f"configured serial {self.role.serial!r} is not online"
                )
            self.serial = self.role.serial
        else:
            if not self.allow_avd_start:
                raise AndroidEnvironmentError(
                    f"role={self.role.role} requires an online configured serial; "
                    "automatic emulator startup is disabled"
                )
            available = sorted(online - self.claimed_serials)
            if available:
                self.serial = available[0]
            elif self.role.avd:
                self.serial = self._start_avd(self.role.avd, online)
            else:
                raise AndroidEnvironmentError(
                    f"role={self.role.role} has no online serial and no avd configured"
                )
        self.claimed_serials.add(self.serial)
        self._wait_boot_completed()
        return self.serial

    def install(self, artifact: Artifact, *, replace: bool = True) -> str:
        serial = self._require_serial()
        if not artifact.path.is_file():
            raise AndroidEnvironmentError(f"APK does not exist: {artifact.path}")
        if self._installed_artifact_matches(artifact):
            print(
                f"[env] reusing installed {artifact.path.name} on {serial}",
                flush=True,
            )
            return "reused installed artifact"
        command = [self.adb, "-s", serial, "install"]
        if replace:
            command.append("-r")
        command.extend(["-t", str(artifact.path)])
        output = self._run(command, timeout=max(self.startup_timeout, 180))
        # `adb install -r` 返回后，PackageManager 的 package-replaced 广播和
        # 旧任务恢复仍可能继续执行。立即携带 Runner extras 启动时，系统恢复
        # 的旧 Intent 会覆盖新 Intent，导致 App 回到 config.yaml 的默认
        # URL/topic。等待包更新稳定后再由 launch() force-stop + 显式启动。
        time.sleep(3)
        return output

    def _installed_artifact_matches(self, artifact: Artifact) -> bool:
        """Return true only when the device APK hash matches the manifest.

        A failed or unavailable inspection deliberately falls back to install;
        test correctness is more important than reuse speed.
        """
        expected = str(artifact.artifact_sha256 or "").strip().lower()
        if not expected or expected == "runtime":
            return False
        try:
            package_paths = self._run(
                [
                    self.adb,
                    "-s",
                    self._require_serial(),
                    "shell",
                    "pm",
                    "path",
                    artifact.application_id,
                ],
                timeout=20,
            )
            apk_path = next(
                (
                    line.removeprefix("package:").strip()
                    for line in package_paths.splitlines()
                    if line.strip().startswith("package:")
                ),
                "",
            )
            if not apk_path:
                return False
            digest = self._run(
                [
                    self.adb,
                    "-s",
                    self._require_serial(),
                    "shell",
                    "sha256sum",
                    apk_path,
                ],
                timeout=30,
            ).split()[0].strip().lower()
            return digest == expected
        except (AndroidEnvironmentError, IndexError, OSError):
            return False

    def launch(
        self,
        artifact: Artifact,
        *,
        runner_id: str,
        device_name: str,
        topic: str,
        web_socket_base_url: str,
        run_id: str = "",
        logical_device: str = "",
        artifact_id: str = "",
        wrapper_commit: str = "",
        native_sdk_sha256: str = "",
        managed_web_socket: bool = False,
    ) -> str:
        serial = self._require_serial()
        component = f"{artifact.application_id}/{artifact.activity}"
        # Keep force-stop separate. On some emulator images, `am start -S`
        # restarts the previous task's base Intent and silently drops the new
        # runner extras, which can bind a case to the wrong topic/version.
        self._run(
            [
                self.adb,
                "-s",
                serial,
                "shell",
                "am",
                "force-stop",
                artifact.application_id,
            ]
        )
        # force-stop 后旧 task 的 Intent 恢复会与带新参数的 am start 竞争，
        # 恢复的旧 Intent 可能覆盖新 wsUrl/runId。等待系统把旧任务恢复动作
        # 跑完，再显式启动，避免 App 连到旧的 WS/主题。
        time.sleep(2)
        command = [
            self.adb,
            "-s",
            serial,
            "shell",
            "am",
            "start",
            "-W",
            "-f",
            # NEW_TASK(0x10000000) | CLEAR_TASK(0x00004000)：丢弃旧任务栈，
            # 确保 App 使用本次 Intent 携带的 runner 参数，而不是恢复旧任务。
            "0x10004000",
            "-n",
            component,
            "--es",
            "runnerId",
            runner_id,
            "--es",
            "runnerDevice",
            device_name,
            "--es",
            "runnerWsBaseUrl",
            web_socket_base_url,
            "--es",
            "runnerRunId",
            run_id,
            "--es",
            "runnerLogicalDevice",
            logical_device,
            "--es",
            "runnerArtifactId",
            artifact_id,
            "--es",
            "runnerWrapperCommit",
            wrapper_commit,
            "--es",
            "runnerNativeSdkSha256",
            native_sdk_sha256,
            "--es",
            "runnerWsManaged",
            str(managed_web_socket).lower(),
        ]
        if topic:
            command.extend(["--es", "runnerTopic", topic])
        return self._run(command)

    def prepare_web_socket_url(self, value: str) -> str:
        """Expose a host-local relay to this device with an adb reverse tunnel."""
        parsed = urlsplit(value)
        if parsed.hostname not in {"127.0.0.1", "localhost"}:
            return value
        if parsed.port is None:
            raise AndroidEnvironmentError(
                f"local WebSocket URL must include a port: {value}"
            )
        serial = self._require_serial()
        endpoint = f"tcp:{parsed.port}"
        self._run(
            [self.adb, "-s", serial, "reverse", endpoint, endpoint],
            timeout=20,
        )
        return value

    def set_network_enabled(self, enabled: bool) -> str:
        """Toggle emulator/device Internet without clearing app or WS state."""
        serial = self._require_serial()
        mode = "disable" if enabled else "enable"
        try:
            return self._run(
                [
                    self.adb,
                    "-s",
                    serial,
                    "shell",
                    "cmd",
                    "connectivity",
                    "airplane-mode",
                    mode,
                ],
                timeout=20,
            )
        except AndroidEnvironmentError:
            service_mode = "enable" if enabled else "disable"
            wifi = self._run(
                [
                    self.adb,
                    "-s",
                    serial,
                    "shell",
                    "svc",
                    "wifi",
                    service_mode,
                ],
                timeout=20,
            )
            data = self._run(
                [
                    self.adb,
                    "-s",
                    serial,
                    "shell",
                    "svc",
                    "data",
                    service_mode,
                ],
                timeout=20,
            )
            return "\n".join(value for value in (wifi, data) if value)

    def stop_emulator(self) -> None:
        if self.serial and self._process is not None and self.adb:
            try:
                self._run([self.adb, "-s", self.serial, "emu", "kill"], timeout=20)
            except AndroidEnvironmentError:
                self._process.terminate()
        self._process = None

    def online_serials(self) -> set[str]:
        if not self.adb:
            return set()
        output = self._run([self.adb, "devices"], timeout=20)
        serials: set[str] = set()
        for line in output.splitlines()[1:]:
            fields = line.split()
            if len(fields) >= 2 and fields[1] == "device":
                serials.add(fields[0])
        return serials

    def _start_avd(self, avd: str, before: set[str]) -> str:
        if not self.emulator:
            raise AndroidEnvironmentError("emulator is not available on PATH")
        self._process = subprocess.Popen(
            [
                self.emulator,
                "-avd",
                avd,
                "-no-snapshot-save",
                "-no-boot-anim",
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )
        deadline = time.monotonic() + self.startup_timeout
        while time.monotonic() < deadline:
            candidates = self.online_serials() - before - self.claimed_serials
            if candidates:
                return sorted(candidates)[0]
            if self._process.poll() is not None:
                raise AndroidEnvironmentError(f"emulator {avd!r} exited before boot")
            time.sleep(2)
        raise AndroidEnvironmentError(
            f"timed out waiting for emulator {avd!r} after {self.startup_timeout}s"
        )

    def _wait_boot_completed(self) -> None:
        serial = self._require_serial()
        deadline = time.monotonic() + self.startup_timeout
        while time.monotonic() < deadline:
            try:
                output = self._run(
                    [
                        self.adb,
                        "-s",
                        serial,
                        "shell",
                        "getprop",
                        "sys.boot_completed",
                    ],
                    timeout=10,
                )
                if output.strip() == "1":
                    return
            except AndroidEnvironmentError:
                pass
            time.sleep(2)
        raise AndroidEnvironmentError(f"device {serial} did not finish booting")

    def _require_serial(self) -> str:
        if not self.serial:
            raise AndroidEnvironmentError("device has not been started")
        return self.serial

    @staticmethod
    def _run(command: list[str | None], timeout: float = 60) -> str:
        if any(part is None for part in command):
            raise AndroidEnvironmentError(f"invalid command: {command}")
        completed = subprocess.run(
            [str(part) for part in command],
            check=False,
            capture_output=True,
            text=True,
            timeout=timeout,
        )
        output = "\n".join(
            item for item in (completed.stdout.strip(), completed.stderr.strip()) if item
        )
        if completed.returncode != 0:
            raise AndroidEnvironmentError(
                f"command failed ({completed.returncode}): {' '.join(str(x) for x in command)}\n"
                f"{output}"
            )
        return output


def _find_android_tool(name: str) -> str | None:
    direct = shutil.which(name)
    if direct:
        return direct
    roots = [
        os.getenv("ANDROID_HOME"),
        os.getenv("ANDROID_SDK_ROOT"),
        str(Path.home() / "Library/Android/sdk"),
    ]
    folder = "platform-tools" if name == "adb" else "emulator"
    for root in roots:
        if not root:
            continue
        candidate = Path(root) / folder / name
        if candidate.is_file():
            return str(candidate)
    return None
