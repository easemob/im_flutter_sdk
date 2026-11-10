#!/usr/bin/env bash
# One-command local run of the single-account nightly test. Mirrors the steps
# of .github/workflows/single-account-nightly.yml so a local run exercises
# exactly what CI runs.
#
# Without E2E_CONFIG_PATH, required environment (same names as GitHub secrets;
# the user token is fetched fresh by tool/ci/fetch_e2e_user_token.sh):
#   E2E_APP_KEY  E2E_USER_ID  E2E_REST_API  E2E_CLIENT_ID  E2E_CLIENT_SECRET
#
# Usage:
#   E2E_APP_KEY=... E2E_USER_ID=... E2E_REST_API=... \
#   E2E_CLIENT_ID=... E2E_CLIENT_SECRET=... \
#     bash tool/ci/nightly_local.sh android   # needs a booted emulator (emulator-5554)
#     ... ios                                 # boots a simulator if none is booted
#
# The generated config contains real credentials; it is written with mode 0600
# into a mktemp file outside the repo and deleted on exit (trap). An existing
# E2E_CONFIG_PATH belongs to its caller and is preserved on exit.
#
# Logs remain under artifacts/. Each invocation also generates a Git-ignored
# artifacts/ci/<run-id>/summary.md with per-case counts and evidence links.
# Individual suites/tests use the existing device runner with CI_TEST_NAME.
set -euo pipefail

# Keep in sync with FLUTTER_VERSION in .github/workflows/*.yml.
EXPECTED_FLUTTER_VERSION="3.47.0"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PLATFORM="${1:-}"
case "$PLATFORM" in
  android|ios) ;;
  *)
    echo "usage: bash tool/ci/nightly_local.sh <android|ios>" >&2
    exit 2
    ;;
esac

targets=(
  logged_in_base_test
  logged_in_group_test
  logged_in_contact_test
  logged_in_user_info_test
  # Retain the existing special batch until its migration is confirmed.
  conversation_config_test
)
logs=(base group contact user-info conversation-config)
mkdir -p "$REPO_ROOT/artifacts/ci"
nightly_dir="$(mktemp -d "$REPO_ROOT/artifacts/ci/$(date +%Y%m%d-%H%M%S)-nightly-$PLATFORM.XXXXXX")"
CONFIG=""
finish_nightly() {
  local result="$?"
  local report_args=(merge --output "$nightly_dir")
  local target
  trap - EXIT
  if [[ -n "$CONFIG" ]]; then rm -f "$CONFIG"; fi
  for target in "${targets[@]}"; do
    report_args+=(--run "$nightly_dir/$target")
  done
  python3 "$REPO_ROOT/tool/ci/report.py" "${report_args[@]}" || result=1
  exit "$result"
}
trap finish_nightly EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
exec > >(tee "$nightly_dir/runner.log") 2>&1
echo "Nightly report directory: $nightly_dir"

command -v flutter >/dev/null 2>&1 || {
  echo "error: flutter not found in PATH" >&2
  exit 2
}
flutter_version="$(flutter --version 2>/dev/null | sed -n 's/^Flutter \([^ ]*\).*/\1/p' | head -1)"
if [ "$flutter_version" != "$EXPECTED_FLUTTER_VERSION" ]; then
  echo "warning: local Flutter is '$flutter_version', CI pins $EXPECTED_FLUTTER_VERSION" >&2
fi

if [ -n "${E2E_CONFIG_PATH:-}" ]; then
  if [ ! -r "$E2E_CONFIG_PATH" ]; then
    echo "error: E2E_CONFIG_PATH is not readable" >&2
    exit 2
  fi
  # Runners change directory to the example; resolve relative caller paths now.
  export E2E_CONFIG_PATH="$(cd "$(dirname "$E2E_CONFIG_PATH")" && pwd)/$(basename "$E2E_CONFIG_PATH")"
else
  for var in E2E_APP_KEY E2E_USER_ID E2E_REST_API E2E_CLIENT_ID E2E_CLIENT_SECRET; do
    if [ -z "${!var:-}" ]; then
      echo "error: environment variable $var is not set" >&2
      exit 2
    fi
  done
  for dependency in jq curl; do
    command -v "$dependency" >/dev/null 2>&1 || {
      echo "error: $dependency not found (needed to prepare E2E configuration)" >&2
      exit 2
    }
  done
  CONFIG="$(mktemp "${TMPDIR:-/tmp}/flutter-e2e-config.XXXXXX.json")"
  bash "$REPO_ROOT/tool/ci/write_e2e_dart_defines.sh" "$CONFIG"
  export E2E_CONFIG_PATH="$CONFIG"
fi

if [ "$PLATFORM" = "android" ]; then
  adb -s emulator-5554 get-state >/dev/null 2>&1 || {
    echo "error: no Android emulator online at emulator-5554" >&2
    echo "       start one first (e.g. via Android Studio or 'flutter emulators --launch ...')" >&2
    exit 2
  }
fi

# Each existing device runner cold-starts the app before SDK initialization.
# Keep all initialization-dependent suites here for both local and hosted CI.
if [ "$PLATFORM" = "android" ]; then
  runner="$REPO_ROOT/tool/ci/run_android_emulator_test.sh"
else
  runner="$REPO_ROOT/tool/ci/run_ios_simulator_test.sh"
fi
status=0
passed=0
failed=0
for index in "${!targets[@]}"; do
  if CI_REPORT_DIR="$nightly_dir/${targets[$index]}" bash "$runner" "integration_test/${targets[$index]}.dart" \
      "$PLATFORM-${logs[$index]}.log"; then
    echo "PASS $PLATFORM ${targets[$index]}"
    passed=$((passed + 1))
  else
    echo "FAIL $PLATFORM ${targets[$index]}" >&2
    failed=$((failed + 1))
    status=1
  fi
done
echo "Nightly suites: passed=$passed failed=$failed total=${#targets[@]}"
exit "$status"
