#!/usr/bin/env bash
# One-command local run of the ohos integration suites on a HarmonyOS device or
# emulator. This is the ohos-only counterpart of smoke_local.sh /
# nightly_local.sh: it does not change the Android/iOS CI entries, it only adds
# an ohos device target for the local verification gate (decision D14/D15 of
# docs/decisions/im-flutter-sdk-ohos-merge/2026-11-11-ohos-merge-key-decisions.md).
#
# Required environment (same names as the 5.1.0 E2E dart-defines):
#   E2E_APP_KEY  E2E_USER_ID  E2E_USER_TOKEN  E2E_PEER_ID  E2E_REST_API  E2E_APP_TOKEN
# Alternatively pass E2E_CONFIG_PATH=/path/to/dart-defines.json (a JSON map of
# the six variables, e.g. the output of the 5.1.0
# tool/ci/fetch_e2e_user_token.sh --json).
#
# Usage:
#   E2E_APP_KEY=... E2E_USER_ID=... E2E_USER_TOKEN=... \
#   E2E_PEER_ID=... E2E_REST_API=... E2E_APP_TOKEN=... \
#     bash tool/ci/ohos_local.sh
#
#   bash tool/ci/ohos_local.sh logged_out logged_in_base   # subset
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
#
# Run layout follows the shared three-category artifacts convention (same as
# 4.x/5.x): one timestamp directory per invocation, platform directory below
# it, one raw log directory per suite:
#   artifacts/ci/<timestamp>/harmony/<suite>/flutter.log
# plus artifacts/ci/<timestamp>/harmony/runner.log with the console output of
# this script. Timestamped directories keep every run's raw logs; nothing is
# overwritten by the next run.
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

CONFIG_PATH="${E2E_CONFIG_PATH:-}"
TEMP_CONFIG=""
if [ -z "$CONFIG_PATH" ]; then
  for var in E2E_APP_KEY E2E_USER_ID E2E_USER_TOKEN E2E_PEER_ID E2E_REST_API E2E_APP_TOKEN; do
    if [ -z "${!var:-}" ]; then
      echo "error: environment variable $var is not set (or set E2E_CONFIG_PATH)" >&2
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
echo "flutter:     $("$FLUTTER_BIN" --version 2>/dev/null | head -1)"
echo "suites:      ${SUITES[*]}"
echo "ohos report directory: $nightly_dir"

cd "$EXAMPLE_DIR"
FAILED=()
for suite in "${SUITES[@]}"; do
  echo
  echo "=== $suite ==="
  suite_dir="$nightly_dir/$suite"
  mkdir -p "$suite_dir"
  if OHOS_SKIP_CODESIGN="$OHOS_SKIP_CODESIGN" "$FLUTTER_BIN" test \
    "integration_test/${suite}_test.dart" \
    -d "$OHOS_DEVICE" \
    --no-pub \
    --dart-define-from-file="$CONFIG_PATH" \
    > "$suite_dir/flutter.log" 2>&1; then
    tail -2 "$suite_dir/flutter.log"
  else
    FAILED+=("$suite")
    echo "FAILED: $suite (see $suite_dir/flutter.log)"
    grep -E "\[E\]|Expected:|Actual:" "$suite_dir/flutter.log" | head -10 || true
  fi
done

echo
if [ "${#FAILED[@]}" -ne 0 ]; then
  echo "failed suites: ${FAILED[*]}" >&2
  exit 1
fi
echo "all ohos suites passed"
