#!/usr/bin/env bash
set -euo pipefail

# One-command local release E2E run: build two APKs (deviceA/deviceB) -> boot two emulators ->
# install -> bridge -> pytest -> report. No Android Studio required; reuses make ws-bridge-up / make test-local.

usage() {
  cat <<'EOF'
Usage: run.sh [--build] [--repo OWNER/REPO] [--keep-emulator] [--no-open] [pytest args...]

  --build           Build APKs locally instead of downloading from the latest release
  --repo OWNER/REPO GitHub repo to download release artifacts from (default: easemob/im_flutter_sdk)
  --keep-emulator   Keep emulators running after the run (shut down by default)
  --no-open         Do not auto-open the report in a browser (use in CI)
  Remaining args are passed through to pytest (simple args, e.g. -q tests/client/test_client.py)

Examples:
  run.sh
  run.sh -q tests/client/test_client.py
  run.sh --build -q tests/client/test_client.py
EOF
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
native_auto_test="$(cd "$script_dir/../../.." && pwd -P)"
repo_root="$(cd "$native_auto_test/.." && pwd -P)"
flutter_test="$repo_root/im_flutter_test"

KEEP_EMULATOR=0
OPEN_REPORT=1
BUILD_LOCAL=0
GH_REPO="${GH_REPO:-easemob/im_flutter_sdk}"
PYTEST_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --build) BUILD_LOCAL=1; shift ;;
    --repo) GH_REPO="${2:?--repo requires OWNER/REPO}"; shift 2 ;;
    --keep-emulator) KEEP_EMULATOR=1; shift ;;
    --no-open) OPEN_REPORT=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) PYTEST_ARGS+=("$1"); shift ;;
  esac
done

fail() { echo "error: $*" >&2; exit 1; }

# ---- Python environment: auto-create venv + install deps (idempotent) ----
ensure_python_env() {
  local venv="$native_auto_test/.venv"
  if [[ ! -x "$venv/bin/python" ]]; then
    command -v python3 >/dev/null 2>&1 || fail "python3 not found; install Python 3.9+"
    echo "==> Creating Python venv ($venv) ..."
    python3 -m venv "$venv"
  fi
  PY="$venv/bin/python"
  if ! "$PY" -c "import websockets, yaml, pytest" 2>/dev/null; then
    echo "==> Installing Python dependencies ..."
    "$PY" -m pip install -q -r "$native_auto_test/requirements.txt"
  fi
  echo "==> Python ready: $PY"
}

detect_sdk_dir() {
  local sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
  if [[ -n "$sdk" && -d "$sdk" ]]; then echo "$sdk"; return 0; fi
  for sdk in "$HOME/Library/Android/sdk" "$HOME/Android/Sdk"; do
    if [[ -d "$sdk" ]]; then echo "$sdk"; return 0; fi
  done
  return 1
}

ensure_python_env
SDK_DIR="$(detect_sdk_dir)" || fail "Android SDK not found (set ANDROID_HOME or ANDROID_SDK_ROOT)"
ADB="$SDK_DIR/platform-tools/adb"
EMULATOR="$SDK_DIR/emulator/emulator"

[[ -x "$ADB" ]] || fail "adb not found: $ADB"
[[ -x "$EMULATOR" ]] || fail "emulator not found: $EMULATOR"

if [[ "$BUILD_LOCAL" == "1" ]]; then
  command -v flutter >/dev/null 2>&1 || fail "flutter not found; install Flutter SDK and add it to PATH (or drop --build to download release APKs)"
else
  command -v curl >/dev/null 2>&1 || fail "curl not found (needed to download release APKs)"
fi

# Ensure two minimal emulators exist (auto-install JDK/cmdline-tools/emulator/image/AVDs if missing, idempotent).
AVD_A="im_flutter_test_a"
AVD_B="im_flutter_test_b"
bash "$script_dir/setup_emulator.sh"

echo "==> Environment ready: PY=$PY AVD_A=$AVD_A AVD_B=$AVD_B SDK=$SDK_DIR"

# ---- Obtain APKs: download from latest release (default) or build locally (--build) ----
if [[ "$BUILD_LOCAL" == "1" ]]; then
  echo "==> Building release APKs locally (deviceA/deviceB) ..."
  (cd "$flutter_test" && flutter build apk --release --dart-define=DEVICE=deviceA)
  cp "$flutter_test/build/app/outputs/flutter-apk/app-release.apk" /tmp/im-flutter-run-deviceA.apk
  (cd "$flutter_test" && flutter build apk --release --dart-define=DEVICE=deviceB)
  cp "$flutter_test/build/app/outputs/flutter-apk/app-release.apk" /tmp/im-flutter-run-deviceB.apk
else
  echo "==> Downloading APKs from latest release ($GH_REPO) ..."
  BASE="https://github.com/$GH_REPO/releases/latest/download"
  curl -fL --max-time 600 -o /tmp/im-flutter-run-deviceA.apk "$BASE/app-release-deviceA.apk"
  curl -fL --max-time 600 -o /tmp/im-flutter-run-deviceB.apk "$BASE/app-release-deviceB.apk"
fi
[[ -s /tmp/im-flutter-run-deviceA.apk ]] || fail "deviceA APK missing/empty"
[[ -s /tmp/im-flutter-run-deviceB.apk ]] || fail "deviceB APK missing/empty"

# ---- Boot two emulators (fixed adb ports) ----
SERIAL_A="emulator-5554"
SERIAL_B="emulator-5556"

echo "==> Booting emulator A ($AVD_A) -> $SERIAL_A ..."
"$EMULATOR" -avd "$AVD_A" -port 5554 -no-window -no-audio -no-boot-anim \
  -gpu swiftshader_indirect -no-snapshot \
  > /tmp/im-flutter-run-emulator-A.log 2>&1 &
EMU_A_PID=$!

echo "==> Booting emulator B ($AVD_B) -> $SERIAL_B ..."
"$EMULATOR" -avd "$AVD_B" -port 5556 -no-window -no-audio -no-boot-anim \
  -gpu swiftshader_indirect -no-snapshot \
  > /tmp/im-flutter-run-emulator-B.log 2>&1 &
EMU_B_PID=$!

cleanup() {
  echo "==> Cleaning up ..."
  (cd "$native_auto_test" && make ws-bridge-down PY="$PY" ADB="$ADB" >/dev/null 2>&1 || true)
  if [[ "$KEEP_EMULATOR" == "0" ]]; then
    "$ADB" -s "$SERIAL_A" emu kill >/dev/null 2>&1 || true
    "$ADB" -s "$SERIAL_B" emu kill >/dev/null 2>&1 || true
    # emulator 命令会 fork 出 qemu 子进程，$EMU_x_PID 未必等于 qemu pid；兜底按 avd 名强杀避免端口残留。
    pkill -f "qemu-system.*-avd $AVD_A" >/dev/null 2>&1 || true
    pkill -f "qemu-system.*-avd $AVD_B" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

wait_boot() {
  local serial="$1"
  "$ADB" -s "$serial" wait-for-device
  while [[ "$("$ADB" -s "$serial" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != "1" ]]; do
    sleep 3
  done
}

wait_boot "$SERIAL_A"
echo "==> Emulator A boot completed"
wait_boot "$SERIAL_B"
echo "==> Emulator B boot completed"

# ---- Install APKs ----
echo "==> Installing release APKs ..."
"$ADB" -s "$SERIAL_A" uninstall com.easemob.im_flutter_test >/dev/null 2>&1 || true
"$ADB" -s "$SERIAL_B" uninstall com.easemob.im_flutter_test >/dev/null 2>&1 || true
"$ADB" -s "$SERIAL_A" install /tmp/im-flutter-run-deviceA.apk
"$ADB" -s "$SERIAL_B" install /tmp/im-flutter-run-deviceB.apk

# ---- Bridge (relay + reverse for all emulator-*) ----
echo "==> Starting local WebSocket bridge ..."
(cd "$native_auto_test" && make ws-bridge-up PY="$PY" ADB="$ADB")

# ---- First launch to create the app's external files dir ----
echo "==> First launch (create app data dir) ..."
"$ADB" -s "$SERIAL_A" shell am start -n com.easemob.im_flutter_test/.MainActivity >/dev/null
"$ADB" -s "$SERIAL_B" shell am start -n com.easemob.im_flutter_test/.MainActivity >/dev/null
sleep 6

# ---- Push runtime config (startup injection; no rebuild needed) ----
CONFIG="$native_auto_test/config.yaml"
CONFIG_DEST="/sdcard/Android/data/com.easemob.im_flutter_test/files/config.yaml"
if [[ -f "$CONFIG" ]]; then
  echo "==> Pushing config.yaml to both emulators ..."
  "$ADB" -s "$SERIAL_A" shell am force-stop com.easemob.im_flutter_test
  "$ADB" -s "$SERIAL_B" shell am force-stop com.easemob.im_flutter_test
  "$ADB" -s "$SERIAL_A" push "$CONFIG" "$CONFIG_DEST" >/dev/null
  "$ADB" -s "$SERIAL_B" push "$CONFIG" "$CONFIG_DEST" >/dev/null
else
  echo "==> config.yaml not found ($CONFIG); App will fall back to bundled asset config"
fi

# ---- Relaunch apps (read external config, auto-connect) ----
echo "==> Relaunching apps (auto-connect) ..."
"$ADB" -s "$SERIAL_A" shell am start -n com.easemob.im_flutter_test/.MainActivity
"$ADB" -s "$SERIAL_B" shell am start -n com.easemob.im_flutter_test/.MainActivity
sleep 8

# ---- Run pytest ----
echo "==> Running pytest ..."
rm -rf "$native_auto_test/out/allure-results"
set +e
(cd "$native_auto_test" && make test-local PY="$PY" ADB="$ADB" ARGS="--alluredir=out/allure-results ${PYTEST_ARGS[*]}")
PYTEST_EXIT=$?
set -e
if [[ "$PYTEST_EXIT" != "0" ]]; then
  echo "==> pytest exited with code $PYTEST_EXIT (report will still be generated)"
fi

# ---- Report ----
echo "==> Generating report ..."
if command -v allure >/dev/null 2>&1; then
  rm -rf "$native_auto_test/out/allure-report"
  (cd "$native_auto_test" && allure generate out/allure-results -o out/allure-report --clean)
  echo "Report: $native_auto_test/out/allure-report/"
  if [[ "$OPEN_REPORT" == "1" ]]; then
    echo "==> Opening report in browser (Ctrl-C to stop the server and finish) ..."
    (cd "$native_auto_test" && allure open out/allure-report)
  else
    echo "Open it manually (HTTP, not file://): (cd $native_auto_test && allure open out/allure-report)"
  fi
else
  echo "allure CLI not found; raw results at: $native_auto_test/out/allure-results/"
  echo "Install allure (e.g. npm i -g allure-commandline), then run:"
  echo "  allure generate out/allure-results -o out/allure-report --clean"
fi

exit "$PYTEST_EXIT"
