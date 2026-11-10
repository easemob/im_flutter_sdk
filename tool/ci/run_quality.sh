#!/usr/bin/env bash
# Quality diagnostics and SDK unit-test counts: artifacts/ci/<run-id>/summary.md.
# Preparation/static checks are reported separately from business test counts.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$repo_root/tool/ci/report.sh"
ci_report_start unit "im_flutter_sdk/test (quality)"
report_device="host"

bash "$repo_root/tool/use_local_packages.sh"

# im_flutter_sdk/example imports the gitignored lib/env.dart; without it the
# example analysis below fails to resolve the file (see the script's header).
bash "$repo_root/tool/ci/ensure_example_env.sh"

packages=(
  im_flutter_sdk_interface
  im_flutter_sdk_android
  im_flutter_sdk_ios
  im_flutter_sdk
  im_flutter_sdk/example
)

for package in "${packages[@]}"; do
  (
    cd "$repo_root/$package"
    flutter pub get
  )
done

format_base="${FORMAT_BASE_SHA:-}"
if [[ -z "$format_base" || "$format_base" =~ ^0+$ ]] || \
  ! git -C "$repo_root" cat-file -e "${format_base}^{commit}" 2>/dev/null; then
  format_base="$(git -C "$repo_root" rev-parse HEAD^ 2>/dev/null || true)"
fi

format_files=()
if [[ -n "$format_base" ]]; then
  while IFS= read -r file; do
    [[ -n "$file" ]] && format_files+=("$repo_root/$file")
  done < <(
    git -C "$repo_root" diff --name-only --diff-filter=ACMR \
      "$format_base" -- '*.dart'
  )
fi

if (( ${#format_files[@]} > 0 )); then
  dart format --output=none --set-exit-if-changed "${format_files[@]}"
else
  echo "No changed Dart files require format checking."
fi

for package in "${packages[@]}"; do
  (
    cd "$repo_root/$package"
    flutter analyze --fatal-infos
  )
done

ci_report_attempt_start 1
(
  cd "$repo_root/im_flutter_sdk"
  test_command=(flutter test --coverage --file-reporter "json:$report_dir/attempt-1.events.jsonl")
  if [[ -n "${CI_TEST_NAME:-}" ]]; then test_command+=(--name "$CI_TEST_NAME"); fi
  "${test_command[@]}" 2>&1 | tee "$report_dir/attempt-1.log"
)
ci_report_attempt 0
(
  cd "$repo_root/im_flutter_sdk"
  dart run tool/ci/check_case_mapping.dart .
  dart run tool/ci/check_contracts.dart ..
  dart run tool/ci/check_versions.dart ..
)
