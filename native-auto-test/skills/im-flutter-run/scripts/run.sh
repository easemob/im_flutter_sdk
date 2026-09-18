#!/usr/bin/env bash
set -euo pipefail

# One-command local release E2E run: build two APKs (deviceA/deviceB) -> boot two emulators ->
# install -> bridge -> pytest -> report. No Android Studio required; reuses make ws-bridge-up / make test-local.

usage() {
  cat <<'EOF'
Usage: run.sh [--build | --refresh-apk] [--repo OWNER/REPO] [--config PATH] [--bridge-config PATH] [--lane N] [--lanes N] [--keep-emulator] [--no-open] [pytest args...]

  --build           Build APK locally instead of downloading from the latest release
  --refresh-apk     Force download after querying latest Release (ignore valid cache)
  APK_PATH          Environment: use an existing APK (single/multi-lane); conflicts with
                    --build and --refresh-apk. Remote mode checks latest on every run.
  --repo OWNER/REPO GitHub repo to download release artifacts from (default: easemob/im_flutter_sdk)
  --config PATH     Environment config file (app: schema). Default: IM_TEST_CONFIG, then
                    native-auto-test/config/config.yaml.
  --bridge-config PATH
                    Bridge config file (websocket/topics). Default: IM_BRIDGE_CONFIG, then
                    native-auto-test/config/bridge.yaml.
  --lane N          Run a single lane (index N); used internally by --lanes, or for manual parallel runs
  --lanes N         Run N lanes in parallel (N*2 emulators), shard selected cases across lanes,
                    merge results into one report (default 1 = single lane, 2 emulators).
                    Stream unmodified pytest output and save unique per-lane logs.
  --keep-emulator   Keep emulators running after the run (shut down by default)
  --no-open         Do not auto-open the report in a browser (use in CI)
  --retries N       Retry failed cases: run the selection once, then rerun only the
                    failed/error cases up to N more times (default 0 = no retry).
                    A single Allure report is generated at the end; each case reflects
                    its last execution (earlier attempts appear as Allure retries).
  Remaining args are passed through to pytest (simple args, e.g. -q tests/chatroom)

Examples:
  run.sh --config config/config.yaml -q tests/client/test_client.py
  run.sh --lanes 2 tests/chatroom
  run.sh --build -q tests/client
  run.sh --config config/ngi.yaml --lanes 2 --retries 2 -v tests
EOF
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
native_auto_test="$(cd "$script_dir/../../.." && pwd -P)"
repo_root="$(cd "$native_auto_test/.." && pwd -P)"
flutter_test="$repo_root/im_flutter_test"

# Enforce for setup, emulators, child lanes, make and pytest on every host.
# Existing ADB servers retain their environment, so also verify their real state.
export ADB_MDNS=0

KEEP_EMULATOR=0
OPEN_REPORT=1
BUILD_LOCAL=0
REFRESH_APK=0
NO_REPORT=0
SKIP_SETUP=0
LANE=0
LANES=1
RETRIES=0
GH_REPO="${GH_REPO:-easemob/im_flutter_sdk}"
CONFIG_ARG=""
BRIDGE_CONFIG_ARG=""
PYTEST_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --build) BUILD_LOCAL=1; shift ;;
    --refresh-apk) REFRESH_APK=1; shift ;;
    --repo) GH_REPO="${2:?--repo requires OWNER/REPO}"; shift 2 ;;
    --config) CONFIG_ARG="${2:?--config requires a path}"; shift 2 ;;
    --bridge-config) BRIDGE_CONFIG_ARG="${2:?--bridge-config requires a path}"; shift 2 ;;
    --lane) LANE="${2:?--lane requires a number}"; shift 2 ;;
    --lanes) LANES="${2:?--lanes requires a number}"; shift 2 ;;
    --retries) RETRIES="${2:?--retries requires a number}"; shift 2 ;;
    --keep-emulator) KEEP_EMULATOR=1; shift ;;
    --no-open) OPEN_REPORT=0; shift ;;
    --no-report) NO_REPORT=1; shift ;;
    --skip-setup) SKIP_SETUP=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) PYTEST_ARGS+=("$1"); shift ;;
  esac
done

fail() { echo "error: $*" >&2; exit 1; }

[[ "$RETRIES" =~ ^[0-9]+$ ]] || fail "--retries requires a non-negative integer"

# ---- 配置选择：环境文件（app schema）与桥接文件分离 ----
# shellcheck source=config_helpers.sh
source "$script_dir/config_helpers.sh"
resolve_config_files "$native_auto_test" "$CONFIG_ARG" "$BRIDGE_CONFIG_ARG" || fail "配置解析失败"
echo "==> 环境配置: $ENV_CONFIG"
echo "==> 桥接配置: $BRIDGE_CONFIG"

detect_sdk_dir() {
  local sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
  if [[ -n "$sdk" && -d "$sdk" ]]; then echo "$sdk"; return 0; fi
  for sdk in "$HOME/Library/Android/sdk" "$HOME/Android/Sdk"; do
    if [[ -d "$sdk" ]]; then echo "$sdk"; return 0; fi
  done
  return 1
}

prepare_adb() {
  SDK_DIR="$(detect_sdk_dir)" || fail "Android SDK not found (set ANDROID_HOME or ANDROID_SDK_ROOT)"
  ADB="$SDK_DIR/platform-tools/adb"
  [[ -x "$ADB" ]] || fail "adb not found: $ADB"
  "$PY" "$script_dir/adb_preflight.py" "$ADB"
}

# Validate APK source before Python/setup/emulator side effects.
if [[ "$REFRESH_APK" == "1" && ( "$BUILD_LOCAL" == "1" || -n "${APK_PATH:-}" ) ]]; then
  fail "--refresh-apk conflicts with --build / APK_PATH"
fi
if [[ -n "${APK_PATH:-}" ]]; then
  [[ "$BUILD_LOCAL" == "0" ]] || fail "APK_PATH conflicts with --build"
  [[ -f "$APK_PATH" && -r "$APK_PATH" && -s "$APK_PATH" ]] || fail "APK_PATH must be a readable nonempty file"
  APK_PATH="$(cd "$(dirname "$APK_PATH")" && pwd -P)/$(basename "$APK_PATH")"
fi

# stdout is the selected path only, so both orchestration modes can reuse it.
obtain_apk() {
  if [[ -n "${APK_PATH:-}" ]]; then
    echo "==> 使用指定 APK: $APK_PATH" >&2
    printf '%s\n' "$APK_PATH"
  elif [[ "$BUILD_LOCAL" == "1" ]]; then
    echo "==> 构建 release APK ..." >&2
    (cd "$flutter_test" && flutter build apk --release) >&2 || return $?
    printf '%s\n' "$flutter_test/build/app/outputs/flutter-apk/app-release.apk"
  elif [[ "$REFRESH_APK" == "1" ]]; then
    "$PY" "$script_dir/release_apk_cache.py" --repo "$GH_REPO" --cache-dir "$native_auto_test/.local/apk-cache" --refresh
  else
    "$PY" "$script_dir/release_apk_cache.py" --repo "$GH_REPO" --cache-dir "$native_auto_test/.local/apk-cache"
  fi
}

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

# Generate (and optionally open) one merged Allure report from accumulated results.
emit_report() {
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
}

# Build the ARGS string for `make test-local`: quote each argument for the recipe
# shell, then escape dollars for make's expansion layer. Joining the raw array would
# split parametrized nodeids at spaces. Always prefixes --alluredir.
build_make_args() {
  "$PY" -c 'import shlex, sys; print(" ".join(shlex.quote(arg) for arg in sys.argv[1:]).replace("$", "$$"))' \
    --alluredir=out/allure-results "$@"
}

# 失败用例自动重试（--retries N > 0）在「单 lane 执行器」的 pytest 步骤内就地进行：
# 复用已启动的模拟器、已安装的 APK 与已就绪的桥接，仅用新的 pytest 进程重跑失败用例，
# 不重启模拟器、不重装 APK、不重启桥接。多 lane 时由编排器把 --retries 透传给每个 lane，
# 各 lane 在各自环境内重试自己的失败分片。报告以每个用例最后一次执行为准（Allure retries 语义）。

# ============ 多 lane 编排模式（--lanes N > 1） ============
if [[ "$LANES" -gt 1 ]]; then
  echo "==> Multi-lane mode: $LANES lanes ($((LANES * 2)) emulators), account g0..g$((LANES - 1)), relay 40100..$((40100 + LANES - 1))"

  RUN_LOG_DIR="$(mktemp -d /tmp/im-flutter-run-session.XXXXXX)"
  echo "Logs: $RUN_LOG_DIR"
  # Let pytest interpret paths and selection options, including its default testpaths.
  if ! (cd "$native_auto_test" && "$PY" "$native_auto_test/scripts/collect_cases.py" ${PYTEST_ARGS[@]+"${PYTEST_ARGS[@]}"}) > "$RUN_LOG_DIR/nodeids.txt" 2> "$RUN_LOG_DIR/collection.log"; then
    fail "pytest collection failed; see $RUN_LOG_DIR/collection.log (no lanes started)"
  fi
  ALL_CASES=()
  while IFS= read -r nodeid; do
    [[ -n "$nodeid" ]] && ALL_CASES+=("$nodeid")
  done < "$RUN_LOG_DIR/nodeids.txt"
  [[ ${#ALL_CASES[@]} -gt 0 ]] || fail "pytest collected no cases (no lanes started)"
  echo "==> Collected ${#ALL_CASES[@]} test cases, sharding across $LANES lanes"
  # Keep pytest arguments intact; select each shard by exact nodeid via a plugin.

  # Prepare each lane env serially (avoid concurrent image download)
  for i in $(seq 0 $((LANES - 1))); do
    echo "==> Preparing lane $i env ..."
    bash "$script_dir/setup_emulator.sh" --lane "$i"
  done

  # Verify before any lane starts; no lane may restart the shared ADB server.
  prepare_adb

  # Clear shared results, merge into one report at the end.
  # With --no-report (e.g. a retry attempt) keep prior results so they accumulate.
  if [[ "$NO_REPORT" == "0" ]]; then
    rm -rf "$native_auto_test/out/allure-results"
  fi

  # 外层仅查询/下载一次；子 lane 通过 APK_PATH 复用确定的文件。
  echo "==> [1/7] 获取共享 APK ..."
  SHARED_APK="$(obtain_apk)"
  [[ -s "$SHARED_APK" ]] || fail "APK missing/empty"

  # Fork each lane in parallel
  pids=()
  for i in $(seq 0 $((LANES - 1))); do
    lane_args=(${PYTEST_ARGS[@]+"${PYTEST_ARGS[@]}"})
    lane_count=0
    : > "$RUN_LOG_DIR/lane$i.nodeids"
    for ((j = i; j < ${#ALL_CASES[@]}; j += LANES)); do
      printf '%s\n' "${ALL_CASES[$j]}" >> "$RUN_LOG_DIR/lane$i.nodeids"
      lane_count=$((lane_count + 1))
    done
    lane_args+=(-p scripts.pytest_lane)
    if (( lane_count == 0 )); then
      echo "[lane $i] 0 cases — skipped"
      pids+=(0)
      continue
    fi
    echo "[lane $i] $lane_count cases — running (log: $RUN_LOG_DIR/lane$i.log)"
    # Pass --retries down: each lane retries its own failed cases in place, reusing its
    # own emulators/bridge/APK (no reboot/reinstall between attempts).
    IM_FLUTTER_LANE_RESULT="$RUN_LOG_DIR/lane$i.result.json" \
      IM_FLUTTER_LANE_NODEIDS="$RUN_LOG_DIR/lane$i.nodeids" APK_PATH="$SHARED_APK" bash "$script_dir/run.sh" --lane "$i" --no-open --no-report --skip-setup --retries "$RETRIES" "${lane_args[@]}" \
      2>&1 | tee "$RUN_LOG_DIR/lane$i.log" &
    pids+=($!)
  done

  exit_code=0
  for i in $(seq 0 $((LANES - 1))); do
    [[ "${pids[$i]}" != 0 ]] || continue
    if wait "${pids[$i]}"; then
      printf '0\n' > "$RUN_LOG_DIR/lane$i.exit"
      echo "[lane $i] PASS"
    else
      lane_exit=$?
      printf '%s\n' "$lane_exit" > "$RUN_LOG_DIR/lane$i.exit"
      echo "[lane $i] FAIL (log: $RUN_LOG_DIR/lane$i.log)"
      exit_code=1
    fi
  done

  # All workers have finished. Count structured pytest outcomes across every shard.
  if ! "$PY" "$script_dir/summarize_lanes.py" "$RUN_LOG_DIR" "$LANES"; then
    exit_code=1
  fi
  if [[ "$exit_code" == 0 ]]; then echo "Overall: PASS"; else echo "Overall: FAIL"; fi

  # Flag cases that only passed after retry as flaky (reran-passed) before reporting.
  if [[ "$RETRIES" -gt 0 ]]; then
    "$PY" "$script_dir/mark_flaky.py" "$native_auto_test/out/allure-results" || true
  fi

  # Merge all lanes into one report (skipped with --no-report).
  if [[ "$NO_REPORT" == "0" ]]; then
    emit_report
  else
    echo "==> --no-report: results in $native_auto_test/out/allure-results/"
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

prepare_adb
EMULATOR="$SDK_DIR/emulator/emulator"
[[ -x "$EMULATOR" ]] || fail "emulator not found: $EMULATOR"

echo "==> Environment ready: PY=$PY AVD_A=$AVD_A AVD_B=$AVD_B SDK=$SDK_DIR"

# ---- Obtain APK: download from latest release (default) or build locally (--build) ----
# 单 APK：device 标识由启动时 intent extra 传入（不区分 deviceA/deviceB 包）。
# 多 lane 模式下，APK_PATH 由编排器预先下载，直接复用。
echo "==> [1/6] 获取 APK ..."
SELECTED_APK="$(obtain_apk)"
[[ -f "$SELECTED_APK" && -s "$SELECTED_APK" ]] || fail "APK missing/empty"
if [[ ! "$SELECTED_APK" -ef /tmp/im-flutter-run-lane$LANE.apk ]]; then
  cp "$SELECTED_APK" /tmp/im-flutter-run-lane$LANE.apk
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

BRIDGE_STARTED=0
LOGCAT_PIDS=()
cleanup() {
  echo "==> Cleaning up ..."
  for log_pid in "${LOGCAT_PIDS[@]}"; do
    kill "$log_pid" 2>/dev/null || true
    wait "$log_pid" 2>/dev/null || true
  done
  if [[ "$BRIDGE_STARTED" == "1" ]]; then
    (cd "$native_auto_test" && SERIALS="$SERIAL_A $SERIAL_B" make ws-bridge-down PY="$PY" ADB="$ADB" WS_PORT="$WS_PORT" WS_STATE_DIR="$WS_STATE_DIR" >/dev/null 2>&1 || true)
  fi
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
DEVICE_LOG_DIR=$(mktemp -d "${TMPDIR:-/tmp}/im-flutter-device-lane${LANE}.XXXXXX")
chmod 700 "$DEVICE_LOG_DIR"
echo "==> Private device logs: $DEVICE_LOG_DIR (may contain sensitive data)"
for serial in "$SERIAL_A" "$SERIAL_B"; do
  (umask 077; exec "$ADB" -s "$serial" logcat -v threadtime > "$DEVICE_LOG_DIR/$serial.log" 2>&1) &
  LOGCAT_PIDS+=("$!")
done
"$PY" "$script_dir/clean_install.py" --adb "$ADB" --serial "$SERIAL_A" --avd "$AVD_A" --apk /tmp/im-flutter-run-lane$LANE.apk
"$PY" "$script_dir/clean_install.py" --adb "$ADB" --serial "$SERIAL_B" --avd "$AVD_B" --apk /tmp/im-flutter-run-lane$LANE.apk

# ---- Bridge (relay + reverse for all emulator-*) ----
echo "==> [4/6] 启动本地 WebSocket 桥接 (port $WS_PORT) ..."
BRIDGE_STARTED=1
(cd "$native_auto_test" && SERIALS="$SERIAL_A $SERIAL_B" make ws-bridge-up PY="$PY" ADB="$ADB" WS_PORT="$WS_PORT" WS_STATE_DIR="$WS_STATE_DIR")

# ---- First launch to create the app's external files dir ----
echo "==> [5/6] 启动 App + 注入配置 ..."
"$ADB" -s "$SERIAL_A" shell am start -n com.easemob.im_flutter_test/.MainActivity --es device "$DEVICE_A" >/dev/null
"$ADB" -s "$SERIAL_B" shell am start -n com.easemob.im_flutter_test/.MainActivity --es device "$DEVICE_B" >/dev/null
sleep 6

# ---- Push runtime config (startup injection; no rebuild needed) ----
# 环境文件原样推送；桥接文件按 lane 改写 websocket.base_url 端口后推送。
CONFIG_DEST="/sdcard/Android/data/com.easemob.im_flutter_test/files/config.yaml"
BRIDGE_DEST="/sdcard/Android/data/com.easemob.im_flutter_test/files/bridge.yaml"
LANE_BRIDGE_CONFIG="/tmp/im-flutter-run-bridge-lane$LANE.yaml"
echo "==> Pushing env config + lane bridge (relay port $WS_PORT) to both emulators ..."
render_lane_bridge "$BRIDGE_CONFIG" "$LANE_BRIDGE_CONFIG" "$WS_PORT"
for serial in "$SERIAL_A" "$SERIAL_B"; do
  "$ADB" -s "$serial" shell am force-stop com.easemob.im_flutter_test
done
for serial in "$SERIAL_A" "$SERIAL_B"; do
  "$ADB" -s "$serial" push "$ENV_CONFIG" "$CONFIG_DEST" >/dev/null
  "$ADB" -s "$serial" push "$LANE_BRIDGE_CONFIG" "$BRIDGE_DEST" >/dev/null
done

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
# Catch a server replaced by another tool during setup before entering pytest.
"$PY" "$script_dir/adb_preflight.py" "$ADB" --check-only

if [[ "$RETRIES" -le 0 ]]; then
  # ---- Default: single pytest run (behavior unchanged) ----
  set +e
  PYTEST_MAKE_ARGS="$(build_make_args ${PYTEST_ARGS[@]+"${PYTEST_ARGS[@]}"})"
  (cd "$native_auto_test" && make test-local PY="$PY" ADB="$ADB" WS_STATE_DIR="$WS_STATE_DIR" ARGS="$PYTEST_MAKE_ARGS")
  PYTEST_EXIT=$?
  set -e
else
  # ---- Retry mode: rerun only failed/error cases on THIS already-prepared environment ----
  # No emulator reboot / APK reinstall / bridge restart between attempts — only new pytest
  # processes. Each attempt appends to allure-results, so Allure shows the last run per case.
  RETRY_DIR="$(mktemp -d "${TMPDIR:-/tmp}/im-flutter-retry-lane$LANE.XXXXXX")"
  CUMULATIVE="$RETRY_DIR/cumulative.json"
  FAIL_FILE="$RETRY_DIR/failing.txt"
  : > "$CUMULATIVE"
  : > "$FAIL_FILE"
  # 重试复用同一套环境（不重启模拟器/不重装 APK/不重启桥接），因此测试账号必须跨尝试存活：
  # created_test_users 是 session fixture，每个新 pytest 进程都会重新创建、teardown 时删除。
  # 账号被删掉重建后，设备上仍是旧账号的登录态，服务端不会把推送投给它 —— 重跑会出现
  # 「好友申请回调收不到」「事件全空」这类与被测功能无关的假失败，也可能因数据全新而假通过。
  # 这里统一接管账号生命周期：所有尝试都保留账号，全部尝试结束后再删一次。
  RETRY_OWNS_TEST_USERS=0
  case "${KEEP_TEST_USERS:-0}" in
    1|true|True) ;;                       # 调用方已显式要求保留，不接管、不清理
    *) export KEEP_TEST_USERS=1; RETRY_OWNS_TEST_USERS=1 ;;
  esac
  TEST_USER_DATE="$(date +%m%d)"          # 与 tests/conftest.py::_test_usernames 一致
  # Multi-lane child: orchestrator already put `-p scripts.pytest_lane` into PYTEST_ARGS and
  # set the shard filter + result path. Top-level single lane must add the plugin itself.
  LANE_RESULT_TARGET="${IM_FLUTTER_LANE_RESULT:-}"
  INITIAL_FILTER="${IM_FLUTTER_LANE_NODEIDS:-}"
  RETRY_PLUGIN_ARGS=()
  [[ -z "$LANE_RESULT_TARGET" ]] && RETRY_PLUGIN_ARGS=(-p scripts.pytest_lane)

  set +e
  # Attempt 0: run the full selection (shard for a lane child, all selected otherwise).
  if [[ -n "$INITIAL_FILTER" ]]; then export IM_FLUTTER_LANE_NODEIDS="$INITIAL_FILTER"; else unset IM_FLUTTER_LANE_NODEIDS; fi
  export IM_FLUTTER_LANE_RESULT="$RETRY_DIR/attempt0.json"
  echo "==> [尝试 1] 运行选定用例 ..."
  PYTEST_MAKE_ARGS="$(build_make_args ${RETRY_PLUGIN_ARGS[@]+"${RETRY_PLUGIN_ARGS[@]}"} ${PYTEST_ARGS[@]+"${PYTEST_ARGS[@]}"})"
  (cd "$native_auto_test" && make test-local PY="$PY" ADB="$ADB" WS_STATE_DIR="$WS_STATE_DIR" ARGS="$PYTEST_MAKE_ARGS")
  PYTEST_EXIT=$?
  "$PY" "$script_dir/retry_merge.py" --cumulative "$CUMULATIVE" --attempt "$RETRY_DIR/attempt0.json" --failures-out "$FAIL_FILE"
  failing="$(wc -l < "$FAIL_FILE" | tr -d ' ')"
  fail_summary="首次: $failing 失败"

  attempt=0
  while [[ "$attempt" -lt "$RETRIES" && "$failing" -gt 0 ]]; do
    attempt=$((attempt + 1))
    echo "==> [重试 $attempt/$RETRIES] 复用已就绪环境，仅重跑 $failing 个失败用例（不重启模拟器/不重装 APK/不重启桥接） ..."
    export IM_FLUTTER_LANE_NODEIDS="$FAIL_FILE"
    export IM_FLUTTER_LANE_RESULT="$RETRY_DIR/attempt$attempt.json"
    PYTEST_MAKE_ARGS="$(build_make_args ${RETRY_PLUGIN_ARGS[@]+"${RETRY_PLUGIN_ARGS[@]}"} ${PYTEST_ARGS[@]+"${PYTEST_ARGS[@]}"})"
    (cd "$native_auto_test" && make test-local PY="$PY" ADB="$ADB" WS_STATE_DIR="$WS_STATE_DIR" ARGS="$PYTEST_MAKE_ARGS")
    PYTEST_EXIT=$?
    "$PY" "$script_dir/retry_merge.py" --cumulative "$CUMULATIVE" --attempt "$RETRY_DIR/attempt$attempt.json" --failures-out "$FAIL_FILE"
    failing="$(wc -l < "$FAIL_FILE" | tr -d ' ')"
    fail_summary="${fail_summary}; 第 $attempt 次重试后: $failing 失败"
  done
  set -e

  # Publish final per-nodeid outcomes for the multi-lane summary (last execution wins).
  [[ -n "$LANE_RESULT_TARGET" ]] && cp "$CUMULATIVE" "$LANE_RESULT_TARGET"

  # 账号由重试模式接管时，这里补上 fixture 被抑制的那次删除（每个 lane 只删自己的账号）。
  if [[ "$RETRY_OWNS_TEST_USERS" == "1" ]]; then
    echo "==> [lane $LANE] 重试结束，清理本 lane 测试账号 test${TEST_USER_DATE}${TEST_USER_PREFIX}user1..3 ..."
    for suffix in 1 2 3; do
      (cd "$native_auto_test" && make delete-user PY="$PY" \
        USERNAME="test${TEST_USER_DATE}${TEST_USER_PREFIX}user${suffix}" >/dev/null) \
        || echo "==> [lane $LANE] 账号 test${TEST_USER_DATE}${TEST_USER_PREFIX}user${suffix} 清理失败（不影响用例结果）"
    done
  fi

  # Final status reflects whether any case still fails after the last attempt.
  if [[ "$failing" -gt 0 ]]; then PYTEST_EXIT=1; else PYTEST_EXIT=0; fi
  echo "==> [lane $LANE] 重试汇总（报告以最后一次执行为准）: $fail_summary"
fi

if [[ "$PYTEST_EXIT" != "0" ]]; then
  echo "==> pytest exited with code $PYTEST_EXIT (report will still be generated)"
fi

# ---- Report ----
if [[ "$NO_REPORT" == "1" ]]; then
  echo "==> --no-report: results written to out/allure-results/ (merge by run-parallel)"
else
  # Flag cases that only passed after retry as flaky (reran-passed) before reporting.
  if [[ "$RETRIES" -gt 0 ]]; then
    "$PY" "$script_dir/mark_flaky.py" "$native_auto_test/out/allure-results" || true
  fi
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
