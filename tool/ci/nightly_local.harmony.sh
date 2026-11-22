#!/usr/bin/env bash
# One-command local run of the HarmonyOS nightly suites. Harmony counterpart
# of the 4.25.0 line's nightly_local.sh (which does not exist on this line).
#
# Callers never pass tokens (same contract as the 5.1.0 nightly entry): tokens
# are short-lived, so the runner fetches them itself on every run from
# long-lived credentials. Two supported input styles:
#
#   1. Export the same five long-lived values as the 5.1.0 nightly entry:
#        E2E_APP_KEY E2E_USER_ID E2E_REST_API E2E_CLIENT_ID E2E_CLIENT_SECRET
#      example/tool/env_tool.dart exchanges them for the app token + user token
#      and writes the six E2E_* dart-defines to a temporary file (mode 0600,
#      deleted on exit). No token is ever stored or supplied by the caller.
#
#   2. Local data preparation (no environment variables): fill in the
#      gitignored im_flutter_sdk/example/config.local.json (`make config`) and
#      this wrapper generates the same dart-defines from it.
#
#   E2E_CONFIG_PATH reuses an existing dart-defines JSON instead (optional).
#
# One-time local data preparation (style 2):
#   make config        # creates example/config.local.json from the template
#   $EDITOR im_flutter_sdk/example/config.local.json   # fill in your environment
#   make env-gettoken  # optional: tokens for the manual API pages (env.dart)
#
# Other environment knobs:
#   FLUTTER_BIN          HarmonyOS flutter fork (default: the project .fvm SDK
#                        when present, otherwise flutter on PATH)
#   DART_BIN             dart used to run example/tool/env_tool.dart
#                        (default: the dart next to FLUTTER_BIN, else dart on PATH)
#   OHOS_DEVICE          hdc target (default 127.0.0.1:5555)
#   OHOS_SKIP_CODESIGN   default 1 (requires the fork OHOS_SKIP_CODESIGN patch)
#
# Usage:
#   bash tool/ci/nightly_local.harmony.sh            # all six suites
#   bash tool/ci/nightly_local.harmony.sh harmony    # same
#   bash tool/ci/nightly_local.harmony.sh harmony logged_in_base logged_in_group
#
# Note: run `flutter pub get` with the harmony fork after any official-Flutter
# run_quality run (the official pub get drops `plugins.ohos` from
# example/.flutter-plugins-dependencies, which breaks the ohos hvigor build).
#
# Reports: artifacts/ci/<timestamp>/harmony/summary.md + report.json (merged),
# per-suite raw logs in artifacts/ci/<timestamp>/harmony/<suite>/, console
# output in artifacts/ci/<timestamp>/harmony/runner.log.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
EXAMPLE_DIR="$REPO_ROOT/im_flutter_sdk/example"
PLATFORM="${1:-harmony}"
case "$PLATFORM" in
  harmony)
    shift || true
    ;;
  *)
    echo "usage: bash tool/ci/nightly_local.harmony.sh [harmony] [suite...]" >&2
    exit 2
    ;;
esac

if [ -z "${E2E_CONFIG_PATH:-}" ]; then
  DART_BIN="${DART_BIN:-}"
  if [ -z "$DART_BIN" ]; then
    if [ -n "${FLUTTER_BIN:-}" ] && [ -x "$(dirname "$FLUTTER_BIN")/dart" ]; then
      DART_BIN="$(dirname "$FLUTTER_BIN")/dart"
    elif [ -x "$REPO_ROOT/.fvm/flutter_sdk/bin/dart" ]; then
      DART_BIN="$REPO_ROOT/.fvm/flutter_sdk/bin/dart"
    else
      DART_BIN="dart"
    fi
  fi
  command -v "$DART_BIN" >/dev/null 2>&1 || {
    echo "error: dart executable '$DART_BIN' not found (set DART_BIN)" >&2
    exit 2
  }

  CREDENTIAL_VARS=(E2E_APP_KEY E2E_USER_ID E2E_REST_API E2E_CLIENT_ID E2E_CLIENT_SECRET)
  CREDENTIAL_COUNT=0
  for var in "${CREDENTIAL_VARS[@]}"; do
    if [ -n "${!var:-}" ]; then
      CREDENTIAL_COUNT=$((CREDENTIAL_COUNT + 1))
    fi
  done

  ENV_TOOL="$EXAMPLE_DIR/tool/env_tool.dart"
  CONFIG_LOCAL="$EXAMPLE_DIR/config.local.json"

  if [ "$CREDENTIAL_COUNT" -eq "${#CREDENTIAL_VARS[@]}" ]; then
    # 5.1.0 nightly contract: only long-lived credentials are exported.
    E2E_CONFIG_PATH="$("$DART_BIN" run "$ENV_TOOL" e2e-config \
      --app-key "$E2E_APP_KEY" \
      --user-id "$E2E_USER_ID" \
      --rest-api "$E2E_REST_API" \
      --client-id "$E2E_CLIENT_ID" \
      --client-secret "$E2E_CLIENT_SECRET")"
  elif [ "$CREDENTIAL_COUNT" -ne 0 ]; then
    echo "error: partial credentials exported (${CREDENTIAL_VARS[*]})" >&2
    echo "hint: export all five, or export none and use example/config.local.json." >&2
    exit 2
  elif [ -f "$CONFIG_LOCAL" ]; then
    E2E_CONFIG_PATH="$("$DART_BIN" run "$ENV_TOOL" e2e-config)"
  else
    echo "error: no credentials found" >&2
    echo "hint: export E2E_APP_KEY E2E_USER_ID E2E_REST_API E2E_CLIENT_ID" >&2
    echo "      E2E_CLIENT_SECRET, or run 'make config' and fill in" >&2
    echo "      im_flutter_sdk/example/config.local.json." >&2
    echo "      Tokens are fetched automatically; do not pass E2E_USER_TOKEN." >&2
    exit 2
  fi
  trap 'rm -f "$E2E_CONFIG_PATH"' EXIT
fi
export E2E_CONFIG_PATH

exec bash "$REPO_ROOT/tool/ci/ohos_local.sh" "$@"
