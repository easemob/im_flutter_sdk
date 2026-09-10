"""Clean installation for explicitly identified test emulators only."""
import argparse
import re
import shlex
import subprocess
from pathlib import Path

PACKAGE = "com.easemob.im_flutter_test"


def clean_install(adb, serial, avd, apk, run=subprocess.run):
    if not re.fullmatch(r"emulator-\d+", serial):
        raise RuntimeError("Only explicit emulator serials are supported")
    if not re.fullmatch(r"im_flutter_test_[ab](?:_lane[0-9]+)?", avd):
        raise RuntimeError("Unexpected test AVD name")
    if not Path(apk).is_file() or Path(apk).stat().st_size == 0:
        raise RuntimeError("APK missing or empty")

    def call(*args):
        try:
            result = run([adb, "-s", serial, *args], capture_output=True,
                         text=True, timeout=120)
        except subprocess.TimeoutExpired:
            raise RuntimeError(f"{serial}: {args[0]} timed out") from None
        if result.returncode:
            # Do not print arbitrary adb output, which may contain private data.
            raise RuntimeError(f"{serial}: {args[0]} failed (exit {result.returncode})")
        return result.stdout.strip()

    identity = call("emu", "avd", "name").splitlines()
    if not identity or identity[0].strip() != avd:
        raise RuntimeError(f"{serial}: AVD identity mismatch; no data deleted")

    def installed():
        output = call("shell", "pm", "list", "packages", PACKAGE)
        lines = output.splitlines()
        if any(not line.startswith("package:") for line in lines):
            raise RuntimeError(f"{serial}: ambiguous package query")
        return f"package:{PACKAGE}" in lines

    if installed():
        if call("uninstall", PACKAGE) != "Success":
            raise RuntimeError(f"{serial}: uninstall not confirmed")
    if installed():
        raise RuntimeError(f"{serial}: package remains after uninstall")
    storage = call("shell", "printenv", "EXTERNAL_STORAGE")
    if not re.fullmatch(r"/storage/emulated/[0-9]+|/sdcard", storage):
        raise RuntimeError(f"{serial}: unknown external storage; no directory deleted")
    target = shlex.quote(f"{storage}/Android/data/{PACKAGE}")
    # -f permits an absent directory, but permission errors remain fatal.
    call("shell", f"rm -rf -- {target} && test ! -e {target} && test ! -L {target}")
    if call("install", str(apk)).splitlines()[-1:] != ["Success"]:
        raise RuntimeError(f"{serial}: installation not confirmed")
    if not installed():
        raise RuntimeError(f"{serial}: installed package missing")
    print(f"{serial}: clean installation verified")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("adb", "serial", "avd", "apk"):
        parser.add_argument("--" + name, required=True)
    args = parser.parse_args()
    try:
        clean_install(args.adb, args.serial, args.avd, args.apk)
    except (RuntimeError, OSError) as exc:
        parser.exit(1, f"Clean installation failed: {exc}\n")


if __name__ == "__main__":
    main()
