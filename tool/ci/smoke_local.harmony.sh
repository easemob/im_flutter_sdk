#!/usr/bin/env bash
# One-command local run of the HarmonyOS device smoke suite. Mirrors
# tool/ci/smoke_local.sh (android|ios) with the harmony platform added; the
# android/ios entry is intentionally left untouched.
#
# Like the android/ios smoke entry, callers pass no credentials. The logged_out
# suite falls back to the public demo app key in
# im_flutter_sdk/example/integration_test/support/env.dart (the same contract as
# the 5.1.0 smoke entry), and only checks that a login attempt is rejected. The
# wrapper therefore passes an empty dart-defines file to tool/ci/ohos_local.sh
# so the runner does not ask for the E2E_* token fields.
#
# Optional environment:
#   FLUTTER_BIN          HarmonyOS flutter fork (default: the project .fvm SDK
#                        when present, otherwise flutter on PATH)
#   OHOS_DEVICE          hdc target (default 127.0.0.1:5555)
#   OHOS_SKIP_CODESIGN   default 1 (requires the fork OHOS_SKIP_CODESIGN patch)
#
# Usage:
#   bash tool/ci/smoke_local.harmony.sh
#   bash tool/ci/smoke_local.harmony.sh harmony
#
# Logs: artifacts/ci/<timestamp>/harmony/logged_out/flutter.log (written by
# ohos_local.sh).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PLATFORM="${1:-harmony}"
case "$PLATFORM" in
  harmony) ;;
  *)
    echo "usage: bash tool/ci/smoke_local.harmony.sh [harmony]" >&2
    exit 2
    ;;
esac

# An empty JSON object is valid for --dart-define-from-file: every E2E_* value
# keeps its Dart default, which is exactly what the logged-out smoke needs.
# (Dedicated temp dir keeps the .json extension while staying macOS-mktemp-safe.)
TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/flutter-ohos-smoke.XXXXXX")"
TEMP_CONFIG="$TEMP_DIR/defines.json"
printf '{}\n' > "$TEMP_CONFIG"
chmod 600 "$TEMP_CONFIG"
trap 'rm -rf "$TEMP_DIR"' EXIT
export E2E_CONFIG_PATH="$TEMP_CONFIG"

exec bash "$REPO_ROOT/tool/ci/ohos_local.sh" logged_out
