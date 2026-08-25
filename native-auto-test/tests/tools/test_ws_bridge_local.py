import asyncio
import os
from pathlib import Path
import signal
import socket
import subprocess
import sys
import time

import pytest
import websockets


PROJECT_ROOT = Path(__file__).resolve().parents[2]
SCRIPT = PROJECT_ROOT / "scripts" / "ws_bridge_local.sh"


def _free_port() -> int:
    with socket.socket() as sock:
        sock.bind(("127.0.0.1", 0))
        return sock.getsockname()[1]


@pytest.fixture
def lifecycle_env(tmp_path: Path) -> tuple[dict[str, str], Path, Path]:
    fake_adb = tmp_path / "adb"
    adb_log = tmp_path / "adb-calls.log"
    state_dir = tmp_path / "state"
    fake_adb.write_text(
        """#!/bin/sh
printf '%s\\n' "$*" >> "$FAKE_ADB_LOG"
if [ "$1" = "devices" ]; then
  echo 'List of devices attached'
  printf 'emulator-5554\\tdevice\\n'
elif [ "$3" = "reverse" ] && [ "$4" = "--list" ]; then
  printf 'host-1 tcp:%s tcp:%s\\n' "$FAKE_EXPECTED_PORT" "$FAKE_EXPECTED_PORT"
elif [ "$3" = "reverse" ] && [ "$4" = "--remove" ] && [ "$FAKE_ADB_MODE" = "fail-remove" ]; then
  exit 10
elif [ "$3" = "reverse" ] && [ "$FAKE_ADB_MODE" = "fail-add" ] && [ "$4" != "--remove" ]; then
  exit 9
elif [ "$3" = "reverse" ] && [ "$4" != "--list" ] && [ "$4" != "--remove" ] && [ "$FAKE_ADB_MODE" = "slow-add" ]; then
  : > "$FAKE_ADB_HOLD_MARKER"
  sleep 1
fi
""",
        encoding="utf-8",
    )
    fake_adb.chmod(0o755)

    port = _free_port()

    env = os.environ.copy()
    env.update(
        {
            "ADB": str(fake_adb),
            "FAKE_ADB_LOG": str(adb_log),
            "FAKE_ADB_MODE": "online",
            "FAKE_EXPECTED_PORT": str(port),
            "FAKE_ADB_HOLD_MARKER": str(tmp_path / "adb-hold.marker"),
            "PY": sys.executable,
            "WS_HOST": "127.0.0.1",
            "WS_PORT": str(port),
            "WS_PATH": "/iov/websocket/dual",
            "WS_STATE_DIR": str(state_dir),
        }
    )
    return env, state_dir, adb_log


def _run_lifecycle(
    action: str,
    env: dict[str, str],
) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["bash", str(SCRIPT), action],
        cwd=PROJECT_ROOT,
        env=env,
        text=True,
        capture_output=True,
        timeout=10,
        check=False,
    )


def _pid_is_alive(pid: int) -> bool:
    try:
        os.kill(pid, 0)
    except ProcessLookupError:
        return False
    return True


def _wait_for_pid_exit(pid: int, timeout: float = 3.0) -> None:
    deadline = time.monotonic() + timeout
    while _pid_is_alive(pid):
        if time.monotonic() >= deadline:
            pytest.fail(f"relay pid {pid} did not exit within {timeout}s")
        time.sleep(0.02)


def _wait_for_path(path: Path, timeout: float = 3.0) -> None:
    deadline = time.monotonic() + timeout
    while not path.exists():
        if time.monotonic() >= deadline:
            pytest.fail(f"path {path} did not appear within {timeout}s")
        time.sleep(0.02)


def test_up_and_down_manage_relay_reverse_and_local_state(
    lifecycle_env: tuple[dict[str, str], Path, Path],
) -> None:
    env, state_dir, adb_log = lifecycle_env
    up = _run_lifecycle("up", env)
    assert up.returncode == 0, up.stderr

    pid_file = state_dir / "ws-bridge.pid"
    env_file = state_dir / "ws-bridge.env"
    log_file = state_dir / "ws-bridge.log"
    pid = int(pid_file.read_text(encoding="utf-8").strip())
    try:
        assert _pid_is_alive(pid)
        assert env_file.read_text(encoding="utf-8") == (
            f"WS_BASE_URL=ws://127.0.0.1:{env['WS_PORT']}/iov/websocket/dual\n"
        )
        assert log_file.exists()

        async def verify_relay() -> None:
            url = (
                f"ws://127.0.0.1:{env['WS_PORT']}"
                "/iov/websocket/dual?topic=lifecycle"
            )
            async with websockets.connect(url) as sender, websockets.connect(url) as receiver:
                await sender.send("lifecycle-smoke")
                assert await asyncio.wait_for(receiver.recv(), timeout=1) == "lifecycle-smoke"

        asyncio.run(verify_relay())
    finally:
        down = _run_lifecycle("down", env)

    assert down.returncode == 0, down.stderr
    _wait_for_pid_exit(pid)
    assert not pid_file.exists()
    assert not env_file.exists()
    calls = adb_log.read_text(encoding="utf-8")
    assert "-s emulator-5554 reverse tcp:" in calls
    assert "-s emulator-5554 reverse --remove tcp:" in calls


def test_up_is_idempotent_and_keeps_managed_pid(
    lifecycle_env: tuple[dict[str, str], Path, Path],
) -> None:
    env, state_dir, _ = lifecycle_env
    first = _run_lifecycle("up", env)
    assert first.returncode == 0, first.stderr
    first_pid = int((state_dir / "ws-bridge.pid").read_text(encoding="utf-8"))
    try:
        second = _run_lifecycle("up", env)
        assert second.returncode == 0, second.stderr
        second_pid = int((state_dir / "ws-bridge.pid").read_text(encoding="utf-8"))
        assert second_pid == first_pid
    finally:
        down = _run_lifecycle("down", env)

    assert down.returncode == 0, down.stderr
    _wait_for_pid_exit(first_pid)


def test_down_uses_managed_url_when_invocation_port_is_different(
    lifecycle_env: tuple[dict[str, str], Path, Path],
) -> None:
    env, state_dir, adb_log = lifecycle_env
    up = _run_lifecycle("up", env)
    assert up.returncode == 0, up.stderr
    pid = int((state_dir / "ws-bridge.pid").read_text(encoding="utf-8"))
    wrong_port = _free_port()
    while wrong_port == int(env["WS_PORT"]):
        wrong_port = _free_port()
    down_env = env.copy()
    down_env["WS_PORT"] = str(wrong_port)

    try:
        result = _run_lifecycle("down", down_env)

        assert result.returncode == 0, result.stderr
        _wait_for_pid_exit(pid)
        assert not (state_dir / "ws-bridge.pid").exists()
        assert not (state_dir / "ws-bridge.env").exists()
        calls = adb_log.read_text(encoding="utf-8")
        assert f"reverse --remove tcp:{env['WS_PORT']}" in calls
        assert f"reverse --remove tcp:{wrong_port}" not in calls
    finally:
        if _pid_is_alive(pid):
            os.kill(pid, signal.SIGTERM)
            _wait_for_pid_exit(pid)


def test_up_rolls_back_new_process_when_reverse_fails(
    lifecycle_env: tuple[dict[str, str], Path, Path],
) -> None:
    env, state_dir, adb_log = lifecycle_env
    env["FAKE_ADB_MODE"] = "fail-add"

    result = _run_lifecycle("up", env)

    assert result.returncode != 0
    assert "reverse" in result.stderr.lower()
    assert not (state_dir / "ws-bridge.pid").exists()
    assert not (state_dir / "ws-bridge.env").exists()
    with pytest.raises(OSError):
        socket.create_connection(("127.0.0.1", int(env["WS_PORT"])), timeout=0.2)
    assert "reverse --remove tcp:" in adb_log.read_text(encoding="utf-8")


def test_up_rolls_back_when_environment_file_cannot_be_written(
    lifecycle_env: tuple[dict[str, str], Path, Path],
) -> None:
    env, state_dir, adb_log = lifecycle_env
    state_dir.mkdir()
    (state_dir / "ws-bridge.env").mkdir()

    result = _run_lifecycle("up", env)
    leaked_pid = None
    pid_file = state_dir / "ws-bridge.pid"
    if pid_file.exists():
        leaked_pid = int(pid_file.read_text(encoding="utf-8"))
    try:
        assert result.returncode != 0
        assert "环境文件" in result.stderr
        assert not pid_file.exists()
        with pytest.raises(OSError):
            socket.create_connection(("127.0.0.1", int(env["WS_PORT"])), timeout=0.2)
        assert "reverse --remove tcp:" in adb_log.read_text(encoding="utf-8")
    finally:
        if leaked_pid is not None and _pid_is_alive(leaked_pid):
            os.kill(leaked_pid, signal.SIGTERM)
            _wait_for_pid_exit(leaked_pid)


def test_up_fails_fast_when_python_cannot_import_websockets(
    lifecycle_env: tuple[dict[str, str], Path, Path],
    tmp_path: Path,
) -> None:
    env, state_dir, adb_log = lifecycle_env
    python_without_websockets = tmp_path / "python-without-websockets"
    python_without_websockets.write_text(
        """#!/bin/sh
if [ "$1" = "-" ]; then
  exec "$REAL_PYTHON" "$@"
fi
echo "ModuleNotFoundError: No module named 'websockets'" >&2
exit 1
""",
        encoding="utf-8",
    )
    python_without_websockets.chmod(0o755)
    env["PY"] = str(python_without_websockets)
    env["REAL_PYTHON"] = sys.executable

    started = time.monotonic()
    result = _run_lifecycle("up", env)
    elapsed = time.monotonic() - started

    assert result.returncode != 0
    assert elapsed < 2
    assert "No module named 'websockets'" in result.stderr
    assert not (state_dir / "ws-bridge.pid").exists()
    assert not (state_dir / "ws-bridge.env").exists()
    assert not adb_log.exists()


def test_check_verifies_running_managed_relay(
    lifecycle_env: tuple[dict[str, str], Path, Path],
) -> None:
    env, state_dir, _ = lifecycle_env
    up = _run_lifecycle("up", env)
    assert up.returncode == 0, up.stderr
    pid = int((state_dir / "ws-bridge.pid").read_text(encoding="utf-8"))
    try:
        result = _run_lifecycle("check", env)

        assert result.returncode == 0, result.stderr
        assert "健康检查通过" in result.stdout
    finally:
        down = _run_lifecycle("down", env)

    assert down.returncode == 0, down.stderr
    _wait_for_pid_exit(pid)


def test_up_rolls_back_state_when_relay_process_exits_before_listening(
    lifecycle_env: tuple[dict[str, str], Path, Path],
    tmp_path: Path,
) -> None:
    env, state_dir, adb_log = lifecycle_env
    failing_python = tmp_path / "python-relay-start-fails"
    failing_python.write_text(
        """#!/bin/sh
if [ "$1" = "-c" ] || [ "$1" = "-" ]; then
  exec "$REAL_PYTHON" "$@"
fi
echo "relay startup sentinel failure" >&2
exit 42
""",
        encoding="utf-8",
    )
    failing_python.chmod(0o755)
    env["PY"] = str(failing_python)
    env["REAL_PYTHON"] = sys.executable

    result = _run_lifecycle("up", env)

    assert result.returncode != 0
    assert "relay 启动失败" in result.stderr
    assert not (state_dir / "ws-bridge.pid").exists()
    assert not (state_dir / "ws-bridge.env").exists()
    assert not adb_log.exists()


def test_down_is_idempotent_after_managed_relay_is_stopped(
    lifecycle_env: tuple[dict[str, str], Path, Path],
) -> None:
    env, state_dir, _ = lifecycle_env
    up = _run_lifecycle("up", env)
    assert up.returncode == 0, up.stderr
    pid = int((state_dir / "ws-bridge.pid").read_text(encoding="utf-8"))

    first = _run_lifecycle("down", env)
    second = _run_lifecycle("down", env)

    assert first.returncode == 0, first.stderr
    assert second.returncode == 0, second.stderr
    _wait_for_pid_exit(pid)
    assert not (state_dir / "ws-bridge.pid").exists()
    assert not (state_dir / "ws-bridge.env").exists()


def test_concurrent_up_fails_fast_without_overwriting_winner_state(
    lifecycle_env: tuple[dict[str, str], Path, Path],
) -> None:
    env, state_dir, _ = lifecycle_env
    env["FAKE_ADB_MODE"] = "slow-add"
    hold_marker = Path(env["FAKE_ADB_HOLD_MARKER"])
    first = subprocess.Popen(
        ["bash", str(SCRIPT), "up"],
        cwd=PROJECT_ROOT,
        env=env,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    managed_pid = None
    try:
        _wait_for_path(hold_marker)
        started = time.monotonic()
        contender = _run_lifecycle("up", env)
        elapsed = time.monotonic() - started
        first_stdout, first_stderr = first.communicate(timeout=10)

        assert first.returncode == 0, first_stdout + first_stderr
        assert contender.returncode != 0
        assert elapsed < 0.8
        assert "正在执行" in contender.stderr
        managed_pid = int(
            (state_dir / "ws-bridge.pid").read_text(encoding="utf-8").strip()
        )
        assert _pid_is_alive(managed_pid)
        assert (state_dir / "ws-bridge.env").exists()
    finally:
        if first.poll() is None:
            first.terminate()
            first.communicate(timeout=3)
        env["FAKE_ADB_MODE"] = "online"
        if managed_pid is None and (state_dir / "ws-bridge.pid").exists():
            managed_pid = int(
                (state_dir / "ws-bridge.pid").read_text(encoding="utf-8").strip()
            )
        down = _run_lifecycle("down", env)
        if managed_pid is not None and _pid_is_alive(managed_pid):
            if down.returncode == 0:
                _wait_for_pid_exit(managed_pid)
            else:
                os.kill(managed_pid, signal.SIGTERM)
                _wait_for_pid_exit(managed_pid)


def test_up_recovers_lock_owned_by_dead_process(
    lifecycle_env: tuple[dict[str, str], Path, Path],
) -> None:
    env, state_dir, _ = lifecycle_env
    lock_dir = state_dir / "ws-bridge.lock"
    lock_dir.mkdir(parents=True)
    (lock_dir / "pid").write_text("99999999\n", encoding="utf-8")

    up = _run_lifecycle("up", env)
    managed_pid = None
    try:
        assert up.returncode == 0, up.stderr
        assert "回收陈旧 lifecycle 锁" in up.stderr
        assert not lock_dir.exists()
        managed_pid = int(
            (state_dir / "ws-bridge.pid").read_text(encoding="utf-8").strip()
        )
    finally:
        down = _run_lifecycle("down", env)

    assert down.returncode == 0, down.stderr
    if managed_pid is not None:
        _wait_for_pid_exit(managed_pid)


def test_down_does_not_stop_unrelated_pid(
    lifecycle_env: tuple[dict[str, str], Path, Path],
) -> None:
    env, state_dir, _ = lifecycle_env
    state_dir.mkdir()
    unrelated = subprocess.Popen(["sleep", "10"])
    (state_dir / "ws-bridge.pid").write_text(
        f"{unrelated.pid}\n",
        encoding="utf-8",
    )
    (state_dir / "ws-bridge.env").write_text(
        "WS_BASE_URL=ws://127.0.0.1:4000/iov/websocket/dual\n",
        encoding="utf-8",
    )
    try:
        result = _run_lifecycle("down", env)

        assert result.returncode != 0
        assert "不是本项目 relay" in result.stderr
        assert unrelated.poll() is None
        assert (state_dir / "ws-bridge.pid").exists()
        assert (state_dir / "ws-bridge.env").exists()
        assert "已停止" not in result.stdout
    finally:
        if unrelated.poll() is None:
            unrelated.terminate()
            unrelated.wait(timeout=3)


def test_down_preserves_state_when_reverse_cleanup_fails(
    lifecycle_env: tuple[dict[str, str], Path, Path],
) -> None:
    env, state_dir, _ = lifecycle_env
    up = _run_lifecycle("up", env)
    assert up.returncode == 0, up.stderr
    pid = int((state_dir / "ws-bridge.pid").read_text(encoding="utf-8"))
    env["FAKE_ADB_MODE"] = "fail-remove"

    result = _run_lifecycle("down", env)

    assert result.returncode != 0
    assert "已停止" not in result.stdout
    assert (state_dir / "ws-bridge.pid").exists()
    assert (state_dir / "ws-bridge.env").exists()
    _wait_for_pid_exit(pid)

    env["FAKE_ADB_MODE"] = "online"
    cleanup = _run_lifecycle("down", env)
    assert cleanup.returncode == 0, cleanup.stderr
    assert not (state_dir / "ws-bridge.pid").exists()
    assert not (state_dir / "ws-bridge.env").exists()
