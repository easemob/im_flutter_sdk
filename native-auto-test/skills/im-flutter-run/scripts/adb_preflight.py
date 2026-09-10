#!/usr/bin/env python3
"""Require disabled ADB mDNS before emulator tests; never restart a shared server."""

import argparse
import os
import re
import shlex
import subprocess
import sys


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("adb", help="Path to the Android SDK adb used by the runner")
    parser.add_argument("--check-only", action="store_true", help="Only query server-status")
    args = parser.parse_args()
    environment = {**os.environ, "ADB_MDNS": "0"}
    commands = ["server-status"] if args.check_only else ["start-server", "server-status"]
    for command in commands:
        try:
            result = subprocess.run(
                [args.adb, command], env=environment, capture_output=True,
                text=True, errors="replace", timeout=10,
            )
        except subprocess.TimeoutExpired:
            print(f"error: ADB {command} timeout after 10 seconds; tests stopped.", file=sys.stderr)
            return 1
        except OSError:
            print(f"error: Cannot execute ADB {command}; check the selected SDK adb.", file=sys.stderr)
            return 1
        if result.returncode != 0:
            print(
                f"error: ADB {command} failed (exit {result.returncode}); tests stopped. "
                "Check ADB availability and platform-tools server-status support.",
                file=sys.stderr,
            )
            return 1

    # Inspect the server, not the calling shell: an existing daemon keeps its old env.
    fields = re.findall(r"^[ \t]*mdns_enabled:([^\r\n]*)", result.stdout, re.MULTILINE)
    states = [value.strip() for value in fields]
    if states != ["false"]:
        if states == ["true"]:
            adb = shlex.quote(args.adb)
            print(
                "error: ADB mDNS is enabled; tests stopped before using this server.\n"
                "After other ADB jobs have stopped, restart it once, then rerun:\n"
                f"  {adb} kill-server\n"
                f"  ADB_MDNS=0 {adb} start-server",
                file=sys.stderr,
            )
        else:
            print(
                "error: Cannot verify ADB mdns_enabled: false; tests stopped. "
                "Use platform-tools that supports this server-status field.",
                file=sys.stderr,
            )
        return 1
    print("==> ADB mDNS disabled (server-status verified)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
