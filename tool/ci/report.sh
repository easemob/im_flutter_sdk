#!/usr/bin/env bash
# Report collection only; execution and retry policy belong to the caller.
# Each run writes summary.md, report.json, run.json, runner.log and per-attempt
# Flutter JSON events/logs under artifacts/ci/. All outputs are Git-ignored.
# CI_TEST_NAME optionally selects one test (Flutter --name regex).

ci_report_start() {
  local platform="$1"
  local target="$2"
  local destination="${CI_REPORT_DIR:-}"
  local args=(start --platform "$platform" --target "$target" --name "${CI_TEST_NAME:-}")
  if [[ -n "$destination" ]]; then
    args+=(--output "$destination")
  fi
  report_dir="$(python3 "$repo_root/tool/ci/report.py" "${args[@]}")"
  report_device="unknown"
  report_attempt=0
  report_attempt_recorded=0
  trap 'exit 130' INT
  trap 'exit 143' TERM
  trap 'ci_report_finish $?' EXIT
  # Capture preparation/build diagnostics as well as test output.
  exec > >(tee "$report_dir/runner.log") 2>&1
  echo "CI report directory: $report_dir"
  command -v flutter >/dev/null 2>&1 || { echo "error: flutter not found in PATH" >&2; exit 2; }
  local flutter_version
  flutter_version="$(flutter --version 2>/dev/null | sed -n 's/^Flutter \([^ ]*\).*/\1/p' | head -1)"
  if [[ "$flutter_version" != "3.47.0" ]]; then
    echo "warning: local Flutter is '$flutter_version', CI pins 3.47.0" >&2
  fi
}

ci_report_attempt_start() {
  report_attempt="$1"
  python3 "$repo_root/tool/ci/report.py" attempt --run "$report_dir" \
    --number "$report_attempt"
}

ci_report_attempt() {
  python3 "$repo_root/tool/ci/report.py" attempt --run "$report_dir" \
    --number "$report_attempt" --exit-code "$1"
  report_attempt_recorded="$report_attempt"
}

ci_report_finish() {
  local status="$1"
  trap - EXIT
  if (( report_attempt > report_attempt_recorded )); then
    ci_report_attempt "$status" || status=1
  fi
  python3 "$repo_root/tool/ci/report.py" finish --run "$report_dir" \
    --exit-code "$status" --device "$report_device" || status=1
  exit "$status"
}
