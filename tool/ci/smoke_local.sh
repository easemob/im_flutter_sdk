#!/usr/bin/env bash
# One-command local run of the device smoke test. Mirrors the steps of
# .github/workflows/device-smoke.yml so a local run exercises exactly what
# CI runs (the actual test execution lives in run_{android,ios}_*_test.sh,
# which the workflows also call).
#
# No credentials needed: the no-login test uses the public demo app key
# built into the test as its default.
#
# Usage:
#   bash tool/ci/smoke_local.sh android   # needs a booted emulator (emulator-5554)
#   bash tool/ci/smoke_local.sh ios       # boots a simulator if none is booted
#
# Logs are written to artifacts/{android,ios}-no-login-smoke.log.
set -euo pipefail

# Keep in sync with FLUTTER_VERSION in .github/workflows/*.yml.
EXPECTED_FLUTTER_VERSION="3.47.0"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PLATFORM="${1:-}"
case "$PLATFORM" in
  android|ios) ;;
  *)
    echo "usage: bash tool/ci/smoke_local.sh <android|ios>" >&2
    exit 2
    ;;
esac

command -v flutter >/dev/null 2>&1 || {
  echo "error: flutter not found in PATH" >&2
  exit 2
}
flutter_version="$(flutter --version 2>/dev/null | sed -n 's/^Flutter \([^ ]*\).*/\1/p' | head -1)"
if [ "$flutter_version" != "$EXPECTED_FLUTTER_VERSION" ]; then
  echo "warning: local Flutter is '$flutter_version', CI pins $EXPECTED_FLUTTER_VERSION" >&2
fi

if [ "$PLATFORM" = "android" ]; then
  # run_android_emulator_test.sh hardcodes -d emulator-5554 (the serial the
  # emulator-runner action uses on CI, and the default for the first local
  # emulator too).
  adb -s emulator-5554 get-state >/dev/null 2>&1 || {
    echo "error: no Android emulator online at emulator-5554" >&2
    echo "       start one first (e.g. via Android Studio or 'flutter emulators --launch ...')" >&2
    exit 2
  }
  exec bash "$REPO_ROOT/tool/ci/run_android_emulator_test.sh" \
    integration_test/no_login_presence_test.dart android-no-login-smoke.log
fi

# ios: run_ios_simulator_test.sh boots an available iPhone simulator itself
# (and retries once on the iOS 26 VM-Service race; see that script's header).
exec bash "$REPO_ROOT/tool/ci/run_ios_simulator_test.sh" \
  integration_test/no_login_presence_test.dart ios-no-login-smoke.log
