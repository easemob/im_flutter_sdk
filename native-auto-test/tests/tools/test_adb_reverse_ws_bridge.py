import os
from pathlib import Path
import subprocess

import pytest


PROJECT_ROOT = Path(__file__).resolve().parents[2]
SCRIPT = PROJECT_ROOT / "scripts" / "adb_reverse_ws_bridge.sh"


@pytest.fixture
def fake_adb(tmp_path: Path) -> tuple[Path, Path]:
    executable = tmp_path / "adb"
    call_log = tmp_path / "adb-calls.log"
    executable.write_text(
        """#!/bin/sh
printf '%s\\n' "$*" >> "$FAKE_ADB_LOG"
if [ "$1" = "devices" ]; then
  echo 'List of devices attached'
  if [ "${FAKE_ADB_MODE:-online}" = "online" ]; then
    printf 'emulator-5554\\tdevice\\n'
    printf 'physical-123\\tdevice\\n'
    printf 'emulator-5556\\toffline\\n'
  else
    printf 'physical-123\\tdevice\\n'
    printf 'emulator-5556\\toffline\\n'
  fi
elif [ "$3" = "reverse" ] && [ "$4" = "--list" ]; then
  printf 'host-1 tcp:%s tcp:%s\\n' "$FAKE_EXPECTED_PORT" "$FAKE_EXPECTED_PORT"
fi
""",
        encoding="utf-8",
    )
    executable.chmod(0o755)
    return executable, call_log


def _run_script(
    fake_adb: tuple[Path, Path],
    *,
    action: str = "add",
    mode: str = "online",
    port: str = "4000",
) -> subprocess.CompletedProcess[str]:
    executable, call_log = fake_adb
    env = os.environ.copy()
    env.update(
        {
            "ADB": str(executable),
            "FAKE_ADB_LOG": str(call_log),
            "FAKE_ADB_MODE": mode,
            "FAKE_EXPECTED_PORT": port,
            "WS_PORT": port,
        }
    )
    return subprocess.run(
        ["bash", str(SCRIPT), action],
        cwd=PROJECT_ROOT,
        env=env,
        text=True,
        capture_output=True,
        check=False,
    )


def _run_script_with_environment(env: dict[str, str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["/bin/bash", str(SCRIPT), "add"],
        cwd=PROJECT_ROOT,
        env=env,
        text=True,
        capture_output=True,
        check=False,
    )


def test_reverse_configures_only_online_emulators(
    fake_adb: tuple[Path, Path],
) -> None:
    result = _run_script(fake_adb)

    assert result.returncode == 0, result.stderr
    calls = fake_adb[1].read_text(encoding="utf-8")
    assert "-s emulator-5554 wait-for-device" in calls
    assert "-s emulator-5554 reverse tcp:4000 tcp:4000" in calls
    assert "-s emulator-5554 reverse --list" in calls
    assert "physical-123" not in calls
    assert "emulator-5556" not in calls


def test_reverse_fails_when_no_online_emulator(
    fake_adb: tuple[Path, Path],
) -> None:
    result = _run_script(fake_adb, mode="no-emulator")

    assert result.returncode != 0
    assert "未发现在线 Android 模拟器" in result.stderr


def test_reverse_rejects_invalid_port(fake_adb: tuple[Path, Path]) -> None:
    result = _run_script(fake_adb, port="70000")

    assert result.returncode != 0
    assert "端口必须是 1..65535" in result.stderr


def test_reverse_remove_only_touches_online_emulators(
    fake_adb: tuple[Path, Path],
) -> None:
    result = _run_script(fake_adb, action="remove")

    assert result.returncode == 0, result.stderr
    calls = fake_adb[1].read_text(encoding="utf-8")
    assert "-s emulator-5554 reverse --remove tcp:4000" in calls
    assert "physical-123" not in calls
    assert "emulator-5556" not in calls


def test_reverse_remove_is_safe_without_online_emulator(
    fake_adb: tuple[Path, Path],
) -> None:
    result = _run_script(fake_adb, action="remove", mode="no-emulator")

    assert result.returncode == 0, result.stderr
    assert "没有在线 Android 模拟器" in result.stdout


def test_reverse_fails_before_device_lookup_when_explicit_adb_is_not_executable(
    tmp_path: Path,
) -> None:
    adb = tmp_path / "adb"
    adb.write_text("#!/bin/sh\nexit 99\n", encoding="utf-8")
    adb.chmod(0o644)
    env = os.environ.copy()
    env["ADB"] = str(adb)

    result = _run_script_with_environment(env)

    assert result.returncode != 0
    assert "ADB 指定的命令不可执行" in result.stderr


def test_reverse_fails_when_adb_cannot_be_found(tmp_path: Path) -> None:
    env = {
        "HOME": str(tmp_path),
        "PATH": "/usr/bin:/bin",
        "WS_PORT": "4000",
    }

    result = _run_script_with_environment(env)

    assert result.returncode != 0
    assert "未找到 adb" in result.stderr
