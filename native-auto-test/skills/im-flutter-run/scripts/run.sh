#!/usr/bin/env bash
set -euo pipefail

# One-command local release E2E run: build two APKs (deviceA/deviceB) -> boot two emulators ->
# install -> bridge -> pytest -> report. No Android Studio required; reuses make ws-bridge-up / make test-local.

usage() {
  cat <<'EOF'
Usage: run.sh [--build] [--repo OWNER/REPO] [--lane N] [--lanes N] [--keep-emulator] [--no-open] [pytest args...]

  --build           Build APKs locally instead of downloading from the latest release
  --repo OWNER/REPO GitHub repo to download release artifacts from (default: easemob/im_flutter_sdk)
  --lane N          Run a single lane (index N); used internally by --lanes, or for manual parallel runs
  --lanes N         Run N lanes in parallel (N*2 emulators), shard test files across lanes,
                    merge results into one report (default 1 = single lane, 2 emulators)
  --keep-emulator   Keep emulators running after the run (shut down by default)
  --no-open         Do not auto-open the report in a browser (use in CI)
  Remaining args are passed through to pytest (simple args, e.g. -q tests/chatroom)

Examples:
  run.sh -q tests/client/test_client.py
  run.sh --lanes 2 tests/chatroom
  run.sh --build -q tests/client
EOF
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
native_auto_test="$(cd "$script_dir/../../.." && pwd -P)"
repo_root="$(cd "$native_auto_test/.." && pwd -P)"
flutter_test="$repo_root/im_flutter_test"

KEEP_EMULATOR=0
OPEN_REPORT=1
BUILD_LOCAL=0
NO_REPORT=0
SKIP_SETUP=0
LANE=0
LANES=1
GH_REPO="${GH_REPO:-easemob/im_flutter_sdk}"
PYTEST_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --build) BUILD_LOCAL=1; shift ;;
    --repo) GH_REPO="${2:?--repo requires OWNER/REPO}"; shift 2 ;;
    --lane) LANE="${2:?--lane requires a number}"; shift 2 ;;
    --lanes) LANES="${2:?--lanes requires a number}"; shift 2 ;;
    --keep-emulator) KEEP_EMULATOR=1; shift ;;
    --no-open) OPEN_REPORT=0; shift ;;
    --no-report) NO_REPORT=1; shift ;;
    --skip-setup) SKIP_SETUP=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) PYTEST_ARGS+=("$1"); shift ;;
  esac
done

fail() { echo "error: $*" >&2; exit 1; }

# 本地地址不走代理：用户可能设置了 HTTPS_PROXY/HTTP_PROXY 加速 GitHub 下载，
# 但本地 relay/WebSocket（127.0.0.1）不能被代理拦截，否则握手失败。
# 本地地址与 IM 服务域名不走代理：用户可能设置了 HTTPS_PROXY/HTTP_PROXY 加速 GitHub 下载，
# 但本地 relay（127.0.0.1）和 REST/IM 服务（*.easemob.com）不能被代理拦截，否则握手/请求超时。
_NO_PROXY_LOCAL="127.0.0.1,localhost,::1,.easemob.com"
export NO_PROXY="${NO_PROXY:+$NO_PROXY,}$_NO_PROXY_LOCAL"
export no_proxy="${no_proxy:+$no_proxy,}$_NO_PROXY_LOCAL"

# ---- Python environment: auto-create venv + install deps (idempotent) ----
# 提前到多 lane 编排模式之前：收集 cases 需要用到 $PY。
ensure_python_env() {
  local venv="$native_auto_test/.venv"
  if [[ ! -x "$venv/bin/python" ]]; then
    command -v python3 >/dev/null 2>&1 || fail "python3 not found; install Python 3.10+"
    if ! python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)'; then
      fail "Python 3.10+ required (found: $(python3 --version 2>&1))"
    fi
    echo "==> Creating Python venv ($venv) ..."
    python3 -m venv "$venv"
  fi
  PY="$venv/bin/python"
  if ! "$PY" -m pip --version >/dev/null 2>&1; then
    echo "==> Ensuring pip ..."
    "$PY" -m ensurepip --upgrade >/dev/null 2>&1 || true
  fi
  if ! "$PY" -c "import websockets, yaml, pytest, allure" 2>/dev/null; then
    echo "==> Installing Python dependencies ..."
    "$PY" -m pip install -q -r "$native_auto_test/requirements.txt"
  fi
  echo "==> Python ready: $PY"
}

ensure_python_env

# ============ 多 lane 编排模式（--lanes N > 1） ============
if [[ "$LANES" -gt 1 ]]; then
  echo "==> Multi-lane mode: $LANES lanes ($((LANES * 2)) emulators), account g0..g$((LANES - 1)), relay 40100..$((40100 + LANES - 1))"

  # Shard test cases across lanes (round-robin by case, not by file)
  OPTIONS=()
  PATHS=()
  if [[ ${#PYTEST_ARGS[@]} -gt 0 ]]; then
    for arg in "${PYTEST_ARGS[@]}"; do
      if [[ "$arg" == -* ]]; then OPTIONS+=("$arg"); else PATHS+=("$arg"); fi
    done
  fi
  ALL_CASES=()
  if [[ ${#PATHS[@]} -gt 0 ]]; then
    while IFS= read -r nodeid; do
      [[ -n "$nodeid" ]] && ALL_CASES+=("$nodeid")
    done < <("$PY" "$native_auto_test/scripts/collect_cases.py" "${PATHS[@]}" 2>/dev/null)
  fi
  if [[ ${#ALL_CASES[@]} -gt 0 ]]; then
    echo "==> Collected ${#ALL_CASES[@]} test cases, sharding across $LANES lanes"
  else
    echo "==> Cannot collect cases (nodeid/-k?), fall back to full set per lane"
  fi

  # Clear shared results, merge into one report at the end
  rm -rf "$native_auto_test/out/allure-results"

  # Prepare each lane env serially (avoid concurrent image download)
  for i in $(seq 0 $((LANES - 1))); do
    echo "==> Preparing lane $i env ..."
    bash "$script_dir/setup_emulator.sh" --lane "$i"
  done

  # 下载一次共享 APK（两个 lane 共用，进度条干净不交错）
  SHARED_APK="/tmp/im-flutter-run.apk"
  BASE="https://github.com/$GH_REPO/releases/latest/download"
  if [[ "$BUILD_LOCAL" == "1" ]]; then
    echo "==> [1/7] 构建 release APK ..."
    (cd "$flutter_test" && flutter build apk --release)
    cp "$flutter_test/build/app/outputs/flutter-apk/app-release.apk" "$SHARED_APK"
  else
    echo "==> [1/7] 下载 APK ($GH_REPO) ..."
    curl -fL --progress-bar --max-time 600 -o "$SHARED_APK" "$BASE/app-release.apk"
    echo ""
    echo "==> [1/7] APK 下载完成 ($(du -h "$SHARED_APK" | cut -f1))"
  fi
  [[ -s "$SHARED_APK" ]] || fail "APK missing/empty"

  # Fork each lane in parallel
  pids=()
  tail_pids=()
  for i in $(seq 0 $((LANES - 1))); do
    lane_args=()
    if [[ ${#OPTIONS[@]} -gt 0 ]]; then
      lane_args+=("${OPTIONS[@]}")
    fi
    if [[ ${#ALL_CASES[@]} -gt 0 ]]; then
      for ((j = i; j < ${#ALL_CASES[@]}; j += LANES)); do
        lane_args+=("${ALL_CASES[$j]}")
      done
    else
      lane_args+=("${PYTEST_ARGS[@]}")
    fi
    # 先创建空日志文件，确保 tail -f 能立即工作且不重放历史
    : > "/tmp/im-flutter-run-lane$i.log"
    echo "==> Starting lane $i ..."
    APK_PATH="$SHARED_APK" bash "$script_dir/run.sh" --lane "$i" --no-open --no-report --skip-setup "${lane_args[@]}" \
      >> "/tmp/im-flutter-run-lane$i.log" 2>&1 &
    pids+=($!)
    # tail -f -n 0：从文件末尾跟踪，只显示新增内容
    tail -f -n 0 "/tmp/im-flutter-run-lane$i.log" &
    tail_pids+=($!)
  done

  exit_code=0
  for i in $(seq 0 $((LANES - 1))); do
    if wait "${pids[$i]}"; then
      echo "==> lane $i done"
    else
      echo "==> lane $i failed (log: /tmp/im-flutter-run-lane$i.log)"
      exit_code=1
    fi
    kill "${tail_pids[$i]}" 2>/dev/null || true
  done

  # Merge all lanes into one report
  echo "==> Generating merged report ..."
  if command -v allure >/dev/null 2>&1; then
    rm -rf "$native_auto_test/out/allure-report"
    (cd "$native_auto_test" && allure generate out/allure-results -o out/allure-report --clean)
    echo "==> Merged report: $native_auto_test/out/allure-report/"
    if [[ "$OPEN_REPORT" == "1" ]]; then
      echo "==> Opening report in browser (Ctrl-C to stop the server and finish) ..."
      (cd "$native_auto_test" && allure open out/allure-report)
    else
      echo "==> Open manually: (cd $native_auto_test && allure open out/allure-report)"
    fi
  else
    echo "allure CLI not found; raw results at $native_auto_test/out/allure-results/"
  fi

  echo "==> All lanes finished (exit code $exit_code)"
  exit "$exit_code"
fi

# ============ 单 lane 模式 ============

# ---- Lane 推导：端口/relay/账号前缀按 lane 隔离，支持多组并行 ----
PORT_BASE=$((5554 + LANE * 4))
SERIAL_A="emulator-$PORT_BASE"
SERIAL_B="emulator-$((PORT_BASE + 2))"
WS_PORT=$((40100 + LANE))
export TEST_USER_PREFIX="g$LANE"
WS_STATE_DIR="$native_auto_test/.local/lane$LANE"

detect_sdk_dir() {
  local sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
  if [[ -n "$sdk" && -d "$sdk" ]]; then echo "$sdk"; return 0; fi
  for sdk in "$HOME/Library/Android/sdk" "$HOME/Android/Sdk"; do
    if [[ -d "$sdk" ]]; then echo "$sdk"; return 0; fi
  done
  return 1
}

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

# Ensure minimal emulators exist (auto-install JDK/cmdline-tools/emulator/image/AVDs if missing, idempotent).
# 每个 lane 独立 AVD（lane 0 用 im_flutter_test_a/b，lane N 用 *_laneN），避免多组并行时 userdata 冲突。
if [[ "$LANE" == "0" ]]; then
  AVD_A="im_flutter_test_a"
  AVD_B="im_flutter_test_b"
else
  AVD_A="im_flutter_test_a_lane$LANE"
  AVD_B="im_flutter_test_b_lane$LANE"
fi
DEVICE_A="deviceA"
DEVICE_B="deviceB"
if [[ "$SKIP_SETUP" == "0" ]]; then
  bash "$script_dir/setup_emulator.sh" --lane "$LANE"
else
  echo "==> 跳过 setup（多 lane 编排器已统一准备）"
fi

echo "==> Environment ready: PY=$PY AVD_A=$AVD_A AVD_B=$AVD_B SDK=$SDK_DIR"

# ---- Obtain APK: download from latest release (default) or build locally (--build) ----
# 单 APK：device 标识由启动时 intent extra 传入（不区分 deviceA/deviceB 包）。
# 多 lane 模式下，APK_PATH 由编排器预先下载，直接复用。
if [[ -n "${APK_PATH:-}" && -s "$APK_PATH" ]]; then
  echo "==> 使用共享 APK: $APK_PATH"
  cp "$APK_PATH" /tmp/im-flutter-run-lane$LANE.apk
elif [[ "$BUILD_LOCAL" == "1" ]]; then
  echo "==> [1/6] 构建 release APK ..."
  (cd "$flutter_test" && flutter build apk --release)
  cp "$flutter_test/build/app/outputs/flutter-apk/app-release.apk" /tmp/im-flutter-run-lane$LANE.apk
else
  echo "==> [1/6] 下载 APK ($GH_REPO) ..."
  BASE="https://github.com/$GH_REPO/releases/latest/download"
  curl -fL --progress-bar --max-time 600 -o /tmp/im-flutter-run-lane$LANE.apk "$BASE/app-release.apk"
  echo ""
  echo "==> [1/6] APK 下载完成 ($(du -h /tmp/im-flutter-run-lane$LANE.apk | cut -f1))"
fi
[[ -s /tmp/im-flutter-run-lane$LANE.apk ]] || fail "APK missing/empty"

echo "==> [2/6] 启动模拟器 ..."
"$EMULATOR" -avd "$AVD_A" -port "$PORT_BASE" -no-window -no-audio -no-boot-anim \
  -gpu swiftshader_indirect -no-snapshot \
  > /tmp/im-flutter-run-emulator-A-lane$LANE.log 2>&1 &
EMU_A_PID=$!

echo "==> Booting emulator B ($AVD_B) -> $SERIAL_B ..."
"$EMULATOR" -avd "$AVD_B" -port "$((PORT_BASE + 2))" -no-window -no-audio -no-boot-anim \
  -gpu swiftshader_indirect -no-snapshot \
  > /tmp/im-flutter-run-emulator-B-lane$LANE.log 2>&1 &
EMU_B_PID=$!

cleanup() {
  echo "==> Cleaning up ..."
  (cd "$native_auto_test" && SERIALS="$SERIAL_A $SERIAL_B" make ws-bridge-down PY="$PY" ADB="$ADB" WS_PORT="$WS_PORT" WS_STATE_DIR="$WS_STATE_DIR" >/dev/null 2>&1 || true)
  if [[ "$KEEP_EMULATOR" == "0" ]]; then
    "$ADB" -s "$SERIAL_A" emu kill >/dev/null 2>&1 || true
    "$ADB" -s "$SERIAL_B" emu kill >/dev/null 2>&1 || true
    # emulator 命令会 fork 出 qemu 子进程，$EMU_x_PID 未必等于 qemu pid；按端口精确匹配杀（避免 AVD 前缀误杀其他 lane）。
    pkill -f "qemu-system.*-port $PORT_BASE" >/dev/null 2>&1 || true
    pkill -f "qemu-system.*-port $((PORT_BASE + 2))" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

wait_boot() {
  local serial="$1"
  local port="${serial#emulator-}"   # emulator-5554 -> 5554
  local deadline=$((SECONDS + 300))  # 300 秒超时
  "$ADB" -s "$serial" wait-for-device 2>/dev/null &
  local wpid=$!
  while kill -0 "$wpid" 2>/dev/null && (( SECONDS < deadline )); do
    sleep 2
  done
  if (( SECONDS >= deadline )); then
    echo "==> 错误：$serial 等待设备超时（300 秒）" >&2
    return 1
  fi
  while [[ "$("$ADB" -s "$serial" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != "1" ]]; do
    if (( SECONDS >= deadline )); then
      echo "==> 错误：$serial boot 超时（300 秒）" >&2
      return 1
    fi
    if ! pgrep -f "qemu-system.*-port $port" >/dev/null 2>&1; then
      echo "==> 错误：$serial 模拟器进程已退出（可能被误杀）" >&2
      return 1
    fi
    sleep 3
  done
}

wait_boot "$SERIAL_A"
echo "==> Emulator A boot completed"
wait_boot "$SERIAL_B"
echo "==> Emulator B boot completed"

# ---- Install APK (same APK for all devices) ----
echo "==> [3/6] 安装 APK ..."
"$ADB" -s "$SERIAL_A" uninstall com.easemob.im_flutter_test >/dev/null 2>&1 || true
"$ADB" -s "$SERIAL_B" uninstall com.easemob.im_flutter_test >/dev/null 2>&1 || true
"$ADB" -s "$SERIAL_A" install /tmp/im-flutter-run-lane$LANE.apk
"$ADB" -s "$SERIAL_B" install /tmp/im-flutter-run-lane$LANE.apk

# ---- Bridge (relay + reverse for all emulator-*) ----
echo "==> [4/6] 启动本地 WebSocket 桥接 (port $WS_PORT) ..."
(cd "$native_auto_test" && SERIALS="$SERIAL_A $SERIAL_B" make ws-bridge-up PY="$PY" ADB="$ADB" WS_PORT="$WS_PORT" WS_STATE_DIR="$WS_STATE_DIR")

# ---- First launch to create the app's external files dir ----
echo "==> [5/6] 启动 App + 注入配置 ..."
"$ADB" -s "$SERIAL_A" shell am start -n com.easemob.im_flutter_test/.MainActivity --es device "$DEVICE_A" >/dev/null
"$ADB" -s "$SERIAL_B" shell am start -n com.easemob.im_flutter_test/.MainActivity --es device "$DEVICE_B" >/dev/null
sleep 6

# ---- Push runtime config (startup injection; no rebuild needed) ----
# 每个 lane 生成专属 config：websocket.base_url 改为本 lane 的 relay 端口。
CONFIG="$native_auto_test/config.yaml"
CONFIG_DEST="/sdcard/Android/data/com.easemob.im_flutter_test/files/config.yaml"
LANE_CONFIG="/tmp/im-flutter-run-config-lane$LANE.yaml"
if [[ -f "$CONFIG" ]]; then
  echo "==> Pushing lane config.yaml to both emulators (base_url port $WS_PORT) ..."
  sed -E "s#(base_url:[[:space:]]*\"ws://127\.0\.0\.1:)[0-9]+#\1$WS_PORT#" "$CONFIG" > "$LANE_CONFIG"
  "$ADB" -s "$SERIAL_A" shell am force-stop com.easemob.im_flutter_test
  "$ADB" -s "$SERIAL_B" shell am force-stop com.easemob.im_flutter_test
  "$ADB" -s "$SERIAL_A" push "$LANE_CONFIG" "$CONFIG_DEST" >/dev/null
  "$ADB" -s "$SERIAL_B" push "$LANE_CONFIG" "$CONFIG_DEST" >/dev/null
else
  echo "==> config.yaml not found ($CONFIG); App will fall back to bundled asset config"
fi

# ---- Relaunch apps (read external config, auto-connect) ----
echo "==> Relaunching apps (auto-connect) ..."
"$ADB" -s "$SERIAL_A" shell am start -n com.easemob.im_flutter_test/.MainActivity --es device "$DEVICE_A"
"$ADB" -s "$SERIAL_B" shell am start -n com.easemob.im_flutter_test/.MainActivity --es device "$DEVICE_B"
sleep 8

# ---- Run pytest ----
echo "==> [6/6] 运行 pytest ..."
if [[ "$NO_REPORT" == "0" ]]; then
  rm -rf "$native_auto_test/out/allure-results"
fi
set +e
(cd "$native_auto_test" && make test-local PY="$PY" ADB="$ADB" WS_STATE_DIR="$WS_STATE_DIR" ARGS="-v --color=yes --alluredir=out/allure-results ${PYTEST_ARGS[*]}")
PYTEST_EXIT=$?
set -e
if [[ "$PYTEST_EXIT" != "0" ]]; then
  echo "==> pytest exited with code $PYTEST_EXIT (report will still be generated)"
fi

# ---- Report ----
if [[ "$NO_REPORT" == "1" ]]; then
  echo "==> --no-report: results written to out/allure-results/ (merge by run-parallel)"
else
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
fi

exit "$PYTEST_EXIT"
