import os
from pathlib import Path
import socket
import subprocess
import sys
import time


PROJECT_ROOT = Path(__file__).resolve().parents[2]
RELAY_ENTRYPOINT = PROJECT_ROOT / "src" / "tools" / "ws_relay_server.py"


def _fake_python(tmp_path: Path) -> tuple[Path, Path]:
    executable = tmp_path / "python"
    call_log = tmp_path / "python-call.log"
    executable.write_text(
        """#!/bin/sh
if [ "$1" = "-" ] || [ "$1" = "-c" ]; then
  exec "$REAL_PYTHON" "$@"
fi
printf '%s|%s\n' "${WS_BASE_URL:-}" "$*" > "$FAKE_PY_LOG"
""",
        encoding="utf-8",
    )
    executable.chmod(0o755)
    return executable, call_log


def _start_relay() -> tuple[subprocess.Popen[bytes], int]:
    with socket.socket() as sock:
        sock.bind(("127.0.0.1", 0))
        port = sock.getsockname()[1]
    relay = subprocess.Popen(
        [
            sys.executable,
            str(RELAY_ENTRYPOINT),
            "--host",
            "127.0.0.1",
            "--port",
            str(port),
            "--path",
            "/iov/websocket/dual",
        ],
        cwd=PROJECT_ROOT,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    deadline = time.monotonic() + 3
    while time.monotonic() < deadline:
        if relay.poll() is not None:
            raise RuntimeError("relay exited before test-local setup completed")
        try:
            with socket.create_connection(("127.0.0.1", port), timeout=0.1):
                return relay, port
        except OSError:
            time.sleep(0.02)
    relay.terminate()
    relay.wait(timeout=3)
    raise RuntimeError("relay listener did not become ready")


def test_make_test_local_loads_generated_environment(tmp_path: Path) -> None:
    python, call_log = _fake_python(tmp_path)
    state_dir = tmp_path / "state"
    state_dir.mkdir()
    relay, port = _start_relay()
    (state_dir / "ws-bridge.pid").write_text(f"{relay.pid}\n", encoding="utf-8")
    local_url = f"ws://127.0.0.1:{port}/iov/websocket/dual"
    (state_dir / "ws-bridge.env").write_text(
        f"WS_BASE_URL={local_url}\n",
        encoding="utf-8",
    )
    env = os.environ.copy()
    env.update(
        {
            "FAKE_PY_LOG": str(call_log),
            "REAL_PYTHON": sys.executable,
        }
    )

    try:
        result = subprocess.run(
            [
                "make",
                "test-local",
                f"PY={python}",
                f"WS_STATE_DIR={state_dir}",
                "ARGS=-q tests/tools/test_config.py",
            ],
            cwd=PROJECT_ROOT,
            env=env,
            text=True,
            capture_output=True,
            check=False,
        )
    finally:
        if relay.poll() is None:
            relay.terminate()
            relay.wait(timeout=3)

    assert result.returncode == 0, result.stderr
    assert call_log.read_text(encoding="utf-8") == (
        f"{local_url}|-m pytest -q tests/tools/test_config.py\n"
    )


def test_make_test_local_fails_before_pytest_when_environment_is_missing(
    tmp_path: Path,
) -> None:
    python, call_log = _fake_python(tmp_path)
    state_dir = tmp_path / "missing-state"
    env = os.environ.copy()
    env["FAKE_PY_LOG"] = str(call_log)

    result = subprocess.run(
        [
            "make",
            "test-local",
            f"PY={python}",
            f"WS_STATE_DIR={state_dir}",
        ],
        cwd=PROJECT_ROOT,
        env=env,
        text=True,
        capture_output=True,
        check=False,
    )

    assert result.returncode != 0
    assert "make ws-bridge-up" in (result.stdout + result.stderr)
    assert not call_log.exists()


def test_make_test_local_fails_before_pytest_when_relay_state_is_stale(
    tmp_path: Path,
) -> None:
    python, call_log = _fake_python(tmp_path)
    state_dir = tmp_path / "stale-state"
    state_dir.mkdir()
    (state_dir / "ws-bridge.env").write_text(
        "WS_BASE_URL=ws://127.0.0.1:4567/iov/websocket/dual\n",
        encoding="utf-8",
    )
    env = os.environ.copy()
    env.update(
        {
            "FAKE_PY_LOG": str(call_log),
            "REAL_PYTHON": sys.executable,
        }
    )

    result = subprocess.run(
        [
            "make",
            "test-local",
            f"PY={python}",
            f"WS_STATE_DIR={state_dir}",
        ],
        cwd=PROJECT_ROOT,
        env=env,
        text=True,
        capture_output=True,
        check=False,
    )

    assert result.returncode != 0
    assert "健康检查" in (result.stdout + result.stderr)
    assert not call_log.exists()
