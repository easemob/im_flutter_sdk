#!/usr/bin/env bash
# One-command local run of the single-account nightly test. Mirrors the steps
# of .github/workflows/single-account-nightly.yml so a local run exercises
# exactly what CI runs.
#
# Required environment (same names as the GitHub secrets):
#   E2E_APP_KEY  E2E_USER_ID  E2E_USER_PASSWORD
#
# Usage:
#   E2E_APP_KEY=... E2E_USER_ID=... E2E_USER_PASSWORD=... \
#     bash tool/ci/nightly_local.sh android   # needs a booted emulator (emulator-5554)
#     ... ios                               # boots a simulator if none is booted
#
# The generated config contains real credentials; it is written with mode 0600
# into a mktemp file outside the repo and deleted on exit (trap).
#
# Logs are written to artifacts/{android,ios}-single-account.log.
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

for var in E2E_APP_KEY E2E_USER_ID E2E_USER_PASSWORD; do
  if [ -z "${!var:-}" ]; then
    echo "error: environment variable $var is not set" >&2
    exit 2
  fi
done

command -v flutter >/dev/null 2>&1 || {
  echo "error: flutter not found in PATH" >&2
  exit 2
}
command -v jq >/dev/null 2>&1 || {
  echo "error: jq not found (needed by write_e2e_dart_defines.sh)" >&2
  exit 2
}
flutter_version="$(flutter --version 2>/dev/null | sed -n 's/^Flutter \([^ ]*\).*/\1/p' | head -1)"
if [ "$flutter_version" != "$EXPECTED_FLUTTER_VERSION" ]; then
  echo "warning: local Flutter is '$flutter_version', CI pins $EXPECTED_FLUTTER_VERSION" >&2
fi

CONFIG="$(mktemp "${TMPDIR:-/tmp}/flutter-e2e-config.XXXXXX.json")"
trap 'rm -f "$CONFIG"' EXIT
bash "$REPO_ROOT/tool/ci/write_e2e_dart_defines.sh" "$CONFIG"
export E2E_CONFIG_PATH="$CONFIG"

if [ "$PLATFORM" = "android" ]; then
  adb -s emulator-5554 get-state >/dev/null 2>&1 || {
    echo "error: no Android emulator online at emulator-5554" >&2
    echo "       start one first (e.g. via Android Studio or 'flutter emulators --launch ...')" >&2
    exit 2
  }
  bash "$REPO_ROOT/tool/ci/run_android_emulator_test.sh" \
    integration_test/single_account_local_test.dart android-single-account.log
  exit 0
fi

# ios: run_ios_simulator_test.sh boots an available iPhone simulator itself
# (and retries once on the iOS 26 VM-Service race; see that script's header).
bash "$REPO_ROOT/tool/ci/run_ios_simulator_test.sh" \
  integration_test/single_account_local_test.dart ios-single-account.log
