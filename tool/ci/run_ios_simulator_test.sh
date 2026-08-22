#!/usr/bin/env bash
# Runs a flutter integration test on a booted iOS simulator with a watchdog.
#
# On iOS 26 simulators `flutter test` sometimes never discovers the Dart VM
# Service of the launched app: it prints "0 tests passed." right after the
# Xcode build and then never exits. This is a known race condition in the
# flutter tool: _IOSSimulatorLogReader passes an async function as the
# StreamController.broadcast onListen callback, so the simctl log-stream
# process is not awaited before the app launches. If the app prints its VM
# Service URI before the log process is ready, the URI is missed permanently
# and the test run hangs. Upstream references (issue still open, unfixed on
# master as of 2026-08):
#   issue: https://github.com/flutter/flutter/issues/181771
#   fix PR (closed unmerged on process grounds, direction endorsed by the
#     team): https://github.com/flutter/flutter/pull/183448
#   second fix PR (closed unmerged, stale draft):
#     https://github.com/flutter/flutter/pull/187643
# This watchdog is only a mitigation: it re-rolls the race with a rebooted
# simulator. Remove it once the upstream fix lands in the Flutter version
# pinned by the workflows (FLUTTER_VERSION). Two defenses:
#   1. the attempt is killed as soon as the log shows "0 tests passed."
#      (or when it exceeds WATCHDOG_SECONDS), so the step fails fast instead
#      of hanging until the job timeout;
#   2. a zero-test attempt is retried once with a freshly rebooted simulator.
# If the retry also fails, the step fails normally and the diagnose step in
# the workflow collects evidence.
set -euo pipefail

test_target="${1:?usage: run_ios_simulator_test.sh TEST_TARGET LOG_NAME}"
log_name="${2:?usage: run_ios_simulator_test.sh TEST_TARGET LOG_NAME}"
watchdog_seconds="${WATCHDOG_SECONDS:-720}"
max_attempts="${MAX_ATTEMPTS:-2}"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
mkdir -p "$repo_root/artifacts"
log_file="$repo_root/artifacts/$log_name"

simulator_udid="$("$repo_root/tool/ci/boot_ios_simulator.sh")"
echo "Using iOS simulator $simulator_udid"

cd "$repo_root/im_flutter_sdk/example"
flutter pub get

# Note: keep the array non-empty; expanding an empty array under set -u
# fails on macOS's bash 3.2, which is what the GitHub macOS runners use.
command=(flutter test "$test_target" -d "$simulator_udid")
if [[ -n "${E2E_CONFIG_PATH:-}" ]]; then
  command+=(--dart-define-from-file="$E2E_CONFIG_PATH")
fi

# Runs one attempt in the background and watches its log: kills the test
# when it reports 0 tests (VM service never discovered, process would hang
# forever) or when it exceeds the watchdog timeout.
run_attempt() {
  local attempt_log="$1"
  "${command[@]}" >"$attempt_log" 2>&1 &
  local test_pid=$!
  (
    elapsed=0
    while kill -0 "$test_pid" 2>/dev/null; do
      # Match "0 tests passed." exactly: the VM-service flake ends the line
      # with a period, while a real failure prints "0 tests passed, N failed."
      if grep -qE "0 tests passed\." "$attempt_log" 2>/dev/null; then
        echo "Watchdog: flutter test found 0 tests (VM service not discovered); killing it" >&2
        kill -TERM "$test_pid" 2>/dev/null || true
        sleep 15
        kill -KILL "$test_pid" 2>/dev/null || true
        break
      fi
      if (( elapsed >= watchdog_seconds )); then
        echo "Watchdog: flutter test exceeded ${watchdog_seconds}s; killing it" >&2
        kill -TERM "$test_pid" 2>/dev/null || true
        sleep 15
        kill -KILL "$test_pid" 2>/dev/null || true
        break
      fi
      sleep 5
      elapsed=$((elapsed + 5))
    done
  ) &
  local watchdog_pid=$!
  local status=0
  wait "$test_pid" || status=$?
  # Reap the watchdog so bash does not print a "Terminated" job notice.
  kill "$watchdog_pid" 2>/dev/null || true
  wait "$watchdog_pid" 2>/dev/null || true
  return "$status"
}

status=0
attempt=1
while (( attempt <= max_attempts )); do
  if (( attempt == 1 )); then
    attempt_log="$log_file"
  else
    attempt_log="$log_file.attempt$attempt"
    echo "Rebooting simulator before attempt $attempt" >&2
    xcrun simctl shutdown "$simulator_udid" 2>/dev/null || true
    xcrun simctl boot "$simulator_udid"
    xcrun simctl bootstatus "$simulator_udid" -b >&2
  fi
  echo "Attempt $attempt of $max_attempts"
  status=0
  run_attempt "$attempt_log" || status=$?
  if [[ "$status" -eq 0 ]]; then
    break
  fi
  if (( attempt < max_attempts )) && grep -qE "0 tests passed\." "$attempt_log"; then
    echo "Retrying: attempt $attempt discovered 0 tests (flaky VM service discovery on iOS 26 simulators)" >&2
    attempt=$((attempt + 1))
  else
    break
  fi
done

cat "$log_file"
for extra_log in "$log_file".attempt*; do
  if [[ -e "$extra_log" ]]; then
    echo "=== retry log: $extra_log ==="
    cat "$extra_log"
  fi
done
if [[ "$status" -ne 0 ]]; then
  echo "iOS simulator test failed or was killed by the watchdog" >&2
fi
exit "$status"
