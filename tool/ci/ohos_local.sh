#!/usr/bin/env bash
# One-command local run of the ohos integration suites on a HarmonyOS device or
# emulator. This is the ohos counterpart of the 4.25.0 line's
# tool/ci/nightly_local.sh + run_*_device_test.sh entries: same report layout
# (report.py), same retry policy class (retry once when no test completed,
# i.e. a load-stage failure), plus harmony-specific pieces (hdc hilog capture,
# OHOS_SKIP_CODESIGN).
#
# Required environment (same names as the 5.1.0 E2E dart-defines):
#   E2E_APP_KEY  E2E_USER_ID  E2E_USER_TOKEN  E2E_PEER_ID  E2E_REST_API  E2E_APP_TOKEN
# Alternatively pass E2E_CONFIG_PATH=/path/to/dart-defines.json (a JSON map of
# the six variables, e.g. the output of example/tool/env_tool.dart e2e-config).
# Use tool/ci/nightly_local.harmony.sh to have tokens fetched automatically
# from the five long-lived credentials.
#
# Usage:
#   bash tool/ci/ohos_local.sh                      # all suites
#   bash tool/ci/ohos_local.sh logged_out logged_in_base   # subset
#   CI_TEST_NAME=FL-MSG-010 bash tool/ci/ohos_local.sh logged_in_base
#
# Environment knobs:
#   FLUTTER_BIN   Flutter executable to use. Defaults to the project-pinned
#                 FVM SDK (`.fvm/flutter_sdk/bin/flutter`, created by
#                 `fvm use custom_ohos --force`) when present, otherwise the
#                 `flutter` from PATH. Must be the HarmonyOS fork
#                 (3.41.9+ohos) for ohos device runs.
#   OHOS_DEVICE   hdc target (default: 127.0.0.1:5555).
#   OHOS_SKIP_CODESIGN  Set to 0 when the fork build of the project ships a
#                 real signing configuration; the CI emulator uses unsigned
#                 haps, which requires the fork patch described in
#                 docs/porting/ohos-4.25.0/2026-11-12-test-verification.md.
#   CI_TEST_NAME  Optional regexp selecting a single test within a suite
#                 (passed to `flutter test --name`), same contract as the
#                 Android/iOS runners on the 4.25.0 line.
#
# Run layout follows the shared three-category artifacts convention (same as
# 4.x/5.x): one timestamp directory per invocation, platform directory below
# it, one report directory per suite:
#   artifacts/ci/<timestamp>/harmony/<suite>/run.json
#   artifacts/ci/<timestamp>/harmony/<suite>/summary.md         (per suite)
#   artifacts/ci/<timestamp>/harmony/<suite>/attempt-N.log      (flutter test)
#   artifacts/ci/<timestamp>/harmony/<suite>/attempt-N.events.jsonl
#   artifacts/ci/<timestamp>/harmony/<suite>/attempt-N.hilog.log.gz
#     (HarmonyOS native log via hdc, keyword-filtered; the full capture is
#     kept when the filter matches nothing. Counterpart of the Android
#     logcat artifact; iOS has no equivalent channel.)
# plus artifacts/ci/<timestamp>/harmony/summary.md + report.json + run.json
# (merged by report.py) and artifacts/ci/<timestamp>/harmony/runner.log with
# the console output of this script. Timestamped directories keep every run's
# raw logs; nothing is overwritten by the next run.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
EXAMPLE_DIR="$REPO_ROOT/im_flutter_sdk/example"
# Prefer the project-pinned fvm SDK; see CONTRIBUTING.md "Flutter SDK 版本（fvm）".
if [ -z "${FLUTTER_BIN:-}" ]; then
  if [ -x "$REPO_ROOT/.fvm/flutter_sdk/bin/flutter" ]; then
    FLUTTER_BIN="$REPO_ROOT/.fvm/flutter_sdk/bin/flutter"
  else
    FLUTTER_BIN="flutter"
  fi
fi
OHOS_DEVICE="${OHOS_DEVICE:-127.0.0.1:5555}"
OHOS_SKIP_CODESIGN="${OHOS_SKIP_CODESIGN:-1}"
CI_TEST_NAME="${CI_TEST_NAME:-}"

# Keep the native capture focused: SDK/wrapper logs, process lifecycle and
# fault channels. The full hilog is retained when the filter matches nothing.
HILOG_FILTER='onesdk|easemob|im_flutter|flutter|appspawn|appkit|jsruntime|faultlog|cppcrash|js_error|appfreeze|com\.example'

# lib/env.dart is gitignored: create the placeholder when missing, never
# overwrite a locally generated one.
bash "$REPO_ROOT/tool/ci/ensure_example_env.sh"

ALL_SUITES=(
  logged_out
  logged_in_base
  logged_in_contact
  logged_in_group
  logged_in_user_info
  logged_in_special
)

if [ "$#" -gt 0 ]; then
  SUITES=("$@")
else
  SUITES=("${ALL_SUITES[@]}")
fi

command -v "$FLUTTER_BIN" >/dev/null 2>&1 || {
  echo "error: flutter executable '$FLUTTER_BIN' not found" >&2
  exit 2
}
command -v python3 >/dev/null 2>&1 || {
  echo "error: python3 not found (needed for report.py)" >&2
  exit 2
}
flutter_line="$("$FLUTTER_BIN" --version 2>/dev/null | head -1)"
case "$flutter_line" in
  *ohos*) ;;
  *)
    echo "warning: FLUTTER_BIN does not look like the HarmonyOS fork" \
      "(3.41.9+ohos): $flutter_line" >&2
    ;;
esac

CONFIG_PATH="${E2E_CONFIG_PATH:-}"
TEMP_CONFIG=""
if [ -z "$CONFIG_PATH" ]; then
  for var in E2E_APP_KEY E2E_USER_ID E2E_USER_TOKEN E2E_PEER_ID E2E_REST_API E2E_APP_TOKEN; do
    if [ -z "${!var:-}" ]; then
      echo "error: environment variable $var is not set (or set E2E_CONFIG_PATH)" >&2
      echo "hint: use tool/ci/nightly_local.harmony.sh to fetch tokens from" >&2
      echo "      the five long-lived credentials automatically." >&2
      exit 2
    fi
  done
  TEMP_CONFIG="$(mktemp "${TMPDIR:-/tmp}/flutter-ohos-e2e.XXXXXX.json")"
  chmod 600 "$TEMP_CONFIG"
  cat >"$TEMP_CONFIG" <<EOF
{
  "E2E_APP_KEY": "$E2E_APP_KEY",
  "E2E_USER_ID": "$E2E_USER_ID",
  "E2E_USER_TOKEN": "$E2E_USER_TOKEN",
  "E2E_PEER_ID": "$E2E_PEER_ID",
  "E2E_REST_API": "$E2E_REST_API",
  "E2E_APP_TOKEN": "$E2E_APP_TOKEN"
}
EOF
  CONFIG_PATH="$TEMP_CONFIG"
  trap 'rm -f "$TEMP_CONFIG"' EXIT
fi

if command -v hdc >/dev/null 2>&1; then
  if ! hdc list targets 2>/dev/null | grep -q "$OHOS_DEVICE"; then
    echo "warning: hdc does not list target '$OHOS_DEVICE' (continuing; flutter picks the device)" >&2
  fi
else
  echo "warning: hdc not found in PATH; make sure the HarmonyOS device is online" >&2
fi

stamp="$(date +%Y%m%d%H%M%S)"
run_root="$REPO_ROOT/artifacts/ci/$stamp"
suffix=2
while [[ -e "$run_root" ]]; do
  run_root="$REPO_ROOT/artifacts/ci/$stamp.$suffix"
  suffix=$((suffix + 1))
done
nightly_dir="$run_root/harmony"
mkdir -p "$nightly_dir"
exec > >(tee "$nightly_dir/runner.log") 2>&1

echo "ohos device: $OHOS_DEVICE"
echo "flutter:     $flutter_line"
echo "suites:      ${SUITES[*]}"
[ -n "$CI_TEST_NAME" ] && echo "test filter: $CI_TEST_NAME"
echo "ohos report directory: $nightly_dir"

cd "$EXAMPLE_DIR"
FAILED=()

# Run one suite with up to two attempts. A second attempt is made only when
# the first one completed zero tests (a load-stage failure such as the hvigor
# build being signalled or the VM-service websocket dropping); once real tests
# have run, a failure is a result, not an infra flake, and is kept as-is.
run_suite() {
  local suite="$1"
  local report_dir="$nightly_dir/$suite"
  python3 "$REPO_ROOT/tool/ci/report.py" start --output "$report_dir" \
    --platform harmony --target "integration_test/${suite}_test.dart" \
    --device "$OHOS_DEVICE" --name "$CI_TEST_NAME" >/dev/null

  local attempt=1 status=1 log=""
  while (( attempt <= 2 )); do
    echo "--- attempt $attempt"
    local events="$report_dir/attempt-$attempt.events.jsonl"
    log="$report_dir/attempt-$attempt.log"
    local hilog_raw="$report_dir/attempt-$attempt.hilog.raw.log"
    local hilog_out="$report_dir/attempt-$attempt.hilog.log"
    local hilog_pid=""
    if command -v hdc >/dev/null 2>&1; then
      hdc -t "$OHOS_DEVICE" shell hilog -r >/dev/null 2>&1 || true
      hdc -t "$OHOS_DEVICE" shell hilog > "$hilog_raw" 2>/dev/null &
      hilog_pid=$!
    fi

    status=0
    local test_args=(
      test "integration_test/${suite}_test.dart"
      -d "$OHOS_DEVICE"
      --no-pub
      --dart-define-from-file="$CONFIG_PATH"
      --file-reporter "json:$events"
    )
    if [ -n "$CI_TEST_NAME" ]; then
      test_args+=(--name "$CI_TEST_NAME")
    fi
    OHOS_SKIP_CODESIGN="$OHOS_SKIP_CODESIGN" "$FLUTTER_BIN" "${test_args[@]}" \
      > "$log" 2>&1 || status=$?

    if [ -n "$hilog_pid" ]; then
      kill "$hilog_pid" 2>/dev/null || true
      wait "$hilog_pid" 2>/dev/null || true
      if [ -f "$hilog_raw" ]; then
        grep -iE "$HILOG_FILTER" "$hilog_raw" > "$hilog_out" 2>/dev/null || true
        if [ -s "$hilog_out" ]; then
          rm -f "$hilog_raw"
        else
          # Filter matched nothing: keep the full capture for evidence.
          mv "$hilog_raw" "$hilog_out"
        fi
        gzip -1 -f "$hilog_out" 2>/dev/null || true
      fi
    fi

    python3 "$REPO_ROOT/tool/ci/report.py" attempt --run "$report_dir" \
      --number "$attempt" --exit-code "$status"

    if (( status == 0 )); then
      break
    fi
    if (( attempt == 1 )) && grep -qE '^[0-9]{2}:[0-9]{2} \+[1-9]' "$log"; then
      # Real tests completed before the failure: keep it, do not retry.
      break
    fi
    attempt=$((attempt + 1))
  done

  tail -2 "$log"
  python3 "$REPO_ROOT/tool/ci/report.py" finish --run "$report_dir" \
    --exit-code "$status" --device "$OHOS_DEVICE"
  return "$status"
}

for suite in "${SUITES[@]}"; do
  echo
  echo "=== $suite ==="
  if run_suite "$suite"; then
    :
  else
    FAILED+=("$suite")
    echo "FAILED: $suite (see $nightly_dir/$suite/summary.md)"
    final_log="$nightly_dir/$suite/attempt-2.log"
    [ -f "$final_log" ] || final_log="$nightly_dir/$suite/attempt-1.log"
    grep -E "\[E\]|Expected:|Actual:" "$final_log" | head -10 || true
  fi
done

echo
overall=0
if [ "${#FAILED[@]}" -ne 0 ]; then
  echo "failed suites: ${FAILED[*]}" >&2
  overall=1
fi
merge_args=(merge --output "$nightly_dir" --exit-code "$overall")
runs=0
for suite in "${SUITES[@]}"; do
  if [ -f "$nightly_dir/$suite/run.json" ]; then
    merge_args+=(--run "$nightly_dir/$suite")
    runs=$((runs + 1))
  fi
done
if [ "$runs" -gt 0 ]; then
  python3 "$REPO_ROOT/tool/ci/report.py" "${merge_args[@]}" || overall=1
fi
exit "$overall"
