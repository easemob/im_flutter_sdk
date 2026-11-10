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
# The runner also writes artifacts/ci/<run-id>/summary.md and report.json,
# including preparation failures; it prints the report path on exit.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PLATFORM="${1:-}"
case "$PLATFORM" in
  android|ios) ;;
  *)
    echo "usage: bash tool/ci/smoke_local.sh <android|ios>" >&2
    exit 2
    ;;
esac

if [ "$PLATFORM" = "android" ]; then
  # Runners check prerequisites after creating the report directory.
  exec bash "$REPO_ROOT/tool/ci/run_android_emulator_test.sh" \
    integration_test/no_login_presence_test.dart android-no-login-smoke.log
fi

# ios: run_ios_simulator_test.sh boots an available iPhone simulator itself
# (and retries once on the iOS 26 VM-Service race; see that script's header).
exec bash "$REPO_ROOT/tool/ci/run_ios_simulator_test.sh" \
  integration_test/no_login_presence_test.dart ios-no-login-smoke.log
