from __future__ import annotations

import argparse
import importlib.util
import os
from pathlib import Path
import shutil
import socket
import subprocess
import sys
import time


ROOT = Path(__file__).resolve().parents[1]
PROJECT_ROOT = ROOT.parent
FLUTTER_TEST = PROJECT_ROOT / "im_flutter_test"


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Build and run the Android 4.10/4.14 phase-1 matrix."
    )
    parser.add_argument("--no-build", action="store_true")
    parser.add_argument("--alluredir", default="allure-results/phase1")
    parser.add_argument(
        "--external-relay",
        action="store_true",
        help="Use websocket.base_url from config.yaml instead of a local relay.",
    )
    args = parser.parse_args()

    if not args.no_build:
        flutter = os.getenv("FLUTTER_BIN") or shutil.which("flutter")
        if not flutter:
            raise SystemExit("flutter not found; set FLUTTER_BIN")
        for flavor in ("sdk410", "sdk414"):
            _run(
                [flutter, "build", "apk", "--debug", "--flavor", flavor],
                cwd=FLUTTER_TEST,
            )

    base = [
        sys.executable,
        "-m",
        "pytest",
        "-q",
        "--manage-runners",
        "--api-matrix",
        "config/api_matrix/android_legacy.yaml",
    ]
    if importlib.util.find_spec("allure_pytest") is not None:
        base.append(f"--alluredir={args.alluredir}")

    common_cases = [
        "tests/contact/test_contact.py::test_friend_add_accept_and_list",
        "tests/phase1/test_version_capability.py::test_fetch_group_members_info_version_capability",
    ]
    relay = None
    relay_env: dict[str, str] = {}
    if not args.external_relay:
        port = _free_port()
        relay = subprocess.Popen(
            [sys.executable, "scripts/local_ws_relay.py", "--port", str(port)],
            cwd=ROOT,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
        )
        ready = relay.stdout.readline().strip() if relay.stdout is not None else ""
        if "local WebSocket relay listening" not in ready:
            raise RuntimeError(f"local WebSocket relay failed to start: {ready}")
        print(ready, flush=True)
        relay_env["NATIVE_TEST_WS_BASE_URL"] = (
            f"ws://127.0.0.1:{port}/iov/websocket/dual"
        )
        relay_env["NATIVE_TEST_RESPONSE_TIMEOUT"] = "90"

    try:
        token = f"phase1-{int(time.time())}-{os.getpid()}"
        first_env = {
            **os.environ,
            **relay_env,
            "NATIVE_TEST_TOPIC_DEVICEA": f"{token}-first-a",
            "NATIVE_TEST_TOPIC_DEVICEB": f"{token}-first-b",
            "NATIVE_TEST_USER_SUFFIX": f"{os.getpid()}a",
        }
        _run(
            [
                *base,
                "--scenario",
                "android_410_414",
                *common_cases,
                "tests/phase1/test_upgrade.py::test_message_data_after_410_to_414_upgrade",
            ],
            cwd=ROOT,
            env=first_env,
        )
        second_env = {
            **os.environ,
            **relay_env,
            "NATIVE_TEST_TOPIC_DEVICEA": f"{token}-second-a",
            "NATIVE_TEST_TOPIC_DEVICEB": f"{token}-second-b",
            "NATIVE_TEST_USER_SUFFIX": f"{os.getpid()}b",
        }
        _run(
            [
                *base,
                "--scenario",
                "android_414_410",
                *common_cases,
            ],
            cwd=ROOT,
            env=second_env,
        )
    finally:
        if relay is not None:
            relay.terminate()
            try:
                relay.wait(timeout=5)
            except subprocess.TimeoutExpired:
                relay.kill()
    return 0


def _run(
    command: list[str],
    *,
    cwd: Path,
    env: dict[str, str] | None = None,
) -> None:
    print("+", " ".join(command), flush=True)
    subprocess.run(command, cwd=cwd, check=True, env=env)


def _free_port() -> int:
    with socket.socket() as sock:
        sock.bind(("127.0.0.1", 0))
        return int(sock.getsockname()[1])


if __name__ == "__main__":
    raise SystemExit(main())
