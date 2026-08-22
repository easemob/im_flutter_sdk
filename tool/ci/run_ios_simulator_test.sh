#!/usr/bin/env bash
# Runs a flutter integration test on a booted iOS simulator with a watchdog.
# `flutter test` can hang forever while discovering the Dart VM Service (seen
# on iOS 26 simulators), so the test process is killed after WATCHDOG_SECONDS
# and the step fails normally, letting the diagnose step collect evidence
# instead of the whole job timing out with nothing.
set -euo pipefail

test_target="${1:?usage: run_ios_simulator_test.sh TEST_TARGET LOG_NAME}"
log_name="${2:?usage: run_ios_simulator_test.sh TEST_TARGET LOG_NAME}"
watchdog_seconds="${WATCHDOG_SECONDS:-720}"

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

"${command[@]}" >"$log_file" 2>&1 &
test_pid=$!
(
  sleep "$watchdog_seconds"
  echo "Watchdog: flutter test exceeded ${watchdog_seconds}s, killing it" >&2
  kill -TERM "$test_pid" 2>/dev/null || true
  sleep 15
  kill -KILL "$test_pid" 2>/dev/null || true
) &
watchdog_pid=$!

status=0
wait "$test_pid" || status=$?
# Reap the watchdog so bash does not print a "Terminated" job notice.
kill "$watchdog_pid" 2>/dev/null || true
wait "$watchdog_pid" 2>/dev/null || true

cat "$log_file"
if [[ "$status" -ne 0 ]]; then
  echo "iOS simulator test failed or was killed by the ${watchdog_seconds}s watchdog" >&2
fi
exit "$status"
