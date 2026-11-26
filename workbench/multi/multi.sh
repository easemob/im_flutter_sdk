#!/usr/bin/env bash
# Thin wrapper around the im-test-orchestrator multi CLI.
#
# Tool resolution order (D13):
#   1. $IMTO_PATH: path to an im-test-orchestrator checkout
#   2. Local checkout at /Users/asterisk/Codes/zuoyu/im-test-orchestrator
#   3. Clone pinned by workbench/multi/multi-tool.json into
#      workbench/multi/.im-test-orchestrator
#      (gitignored; inactive until the pin file carries a real URL and ref)
#
# Usage:
#   workbench/multi/multi.sh generate --platform ios [--case <name>] [--instance <id>] ...
#       Runs scripts/generate_cases.dart; defaults --cases-dir to
#       workbench/multi/cases.
#   workbench/multi/multi.sh prepare|devices|build|launch|run|report|clean|all ...
#       Runs bin/cli.dart; defaults --app-dir to workbench.
# Example:
#   workbench/multi/multi.sh all --cases <IMTO>/multi/config/cases.json
#   workbench/multi/multi.sh prepare workbench/multi/cases/5.0.0-multi-presence-positive.yaml \
#       --cases <IMTO>/multi/config/cases.json
# Relative path arguments are resolved against this repository root.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PIN_FILE="$REPO_ROOT/workbench/multi/multi-tool.json"
LOCAL_CHECKOUT="/Users/asterisk/Codes/zuoyu/im-test-orchestrator"
CLONE_DIR="$REPO_ROOT/workbench/multi/.im-test-orchestrator"

resolve_tool() {
  if [[ -n "${IMTO_PATH:-}" && -d "$IMTO_PATH/multi" ]]; then
    echo "$IMTO_PATH"
    return
  fi
  if [[ -d "$LOCAL_CHECKOUT/multi" ]]; then
    echo "$LOCAL_CHECKOUT"
    return
  fi
  if [[ -f "$PIN_FILE" ]]; then
    local url ref
    url="$(sed -n 's/.*"repo"[^"]*"\([^"]*\)".*/\1/p' "$PIN_FILE" | head -1)"
    ref="$(sed -n 's/.*"ref"[^"]*"\([^"]*\)".*/\1/p' "$PIN_FILE" | head -1)"
    if [[ "$url" == http* && -n "$ref" ]]; then
      git clone --depth 1 --branch "$ref" "$url" "$CLONE_DIR" >&2
      echo "$CLONE_DIR"
      return
    fi
  fi
  echo "error: im-test-orchestrator not found; set IMTO_PATH or fill in $PIN_FILE" >&2
  return 1
}

IMTO="$(resolve_tool)"
MULTI="$IMTO/multi"

command="${1:-}"
if [[ -z "$command" || "$command" == "-h" || "$command" == "--help" ]]; then
  sed -n '2,20p' "${BASH_SOURCE[0]}"
  exit 0
fi
shift

entry="bin/cli.dart"
args=()
if [[ "$command" == "generate" ]]; then
  entry="scripts/generate_cases.dart"
else
  args+=("$command")
fi

path_flags=(--cases-dir --app-dir --cases --data-input --build-result --target)
expect_path=0
has_cases_dir=0
has_app_dir=0
for arg in "$@"; do
  if [[ $expect_path -eq 1 && "$arg" != /* ]]; then
    arg="$REPO_ROOT/$arg"
  fi
  expect_path=0
  for flag in "${path_flags[@]}"; do
    if [[ "$arg" == "$flag" ]]; then
      expect_path=1
    fi
  done
  [[ "$arg" == "--cases-dir" ]] && has_cases_dir=1
  [[ "$arg" == "--app-dir" ]] && has_app_dir=1
  if [[ "$arg" == *.yaml && "$arg" != /* ]]; then
    arg="$REPO_ROOT/$arg"
  fi
  args+=("$arg")
done

if [[ "$command" == "generate" && $has_cases_dir -eq 0 ]]; then
  args+=(--cases-dir "$REPO_ROOT/workbench/multi/cases")
fi
# Only commands whose CLI accepts --app-dir get the default (build/all).
if [[ "$command" == "build" || "$command" == "all" ]] && [[ $has_app_dir -eq 0 ]]; then
  args+=(--app-dir "$REPO_ROOT/workbench")
fi

cd "$MULTI"
exec dart run "$entry" "${args[@]}"
