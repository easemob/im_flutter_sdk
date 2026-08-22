#!/usr/bin/env bash
# Runs a flutter integration test on the Android emulator started by
# reactivecircus/android-emulator-runner. The runner does not preserve
# multi-line `script:` input as one shell session (each line can end up in
# its own `sh -c`, so `cd` does not stick), so the workflows invoke this
# wrapper with a single-line script instead.
set -euo pipefail

test_target="${1:?usage: run_android_emulator_test.sh TEST_TARGET LOG_NAME}"
log_name="${2:?usage: run_android_emulator_test.sh TEST_TARGET LOG_NAME}"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
mkdir -p "$repo_root/artifacts"

cd "$repo_root/im_flutter_sdk/example"
flutter pub get

extra_args=()
if [[ -n "${E2E_CONFIG_PATH:-}" ]]; then
  extra_args+=(--dart-define-from-file="$E2E_CONFIG_PATH")
fi

set -o pipefail
flutter test "$test_target" -d emulator-5554 "${extra_args[@]}" 2>&1 | tee "$repo_root/artifacts/$log_name"
