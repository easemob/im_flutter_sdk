#!/usr/bin/env bash
# Runs a flutter integration test on the Android emulator started by
# reactivecircus/android-emulator-runner. The runner does not preserve
# multi-line `script:` input as one shell session (each line can end up in
# its own `sh -c`, so `cd` does not stick), so the workflows invoke this
# wrapper with a single-line script instead.
set -euo pipefail

test_target="${1:?usage: run_android_emulator_test.sh TEST_TARGET LOG_NAME}"
log_name="${2:?usage: run_android_emulator_test.sh TEST_TARGET LOG_NAME}"
# Keep in sync with applicationId in
# im_flutter_sdk/example/android/app/build.gradle.kts.
app_id="com.example.example"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$repo_root/tool/ci/report.sh"
ci_report_start android "$test_target"
report_device="emulator-5554"
adb -s emulator-5554 get-state >/dev/null 2>&1 || {
  echo "error: no Android emulator online at emulator-5554" >&2
  exit 2
}
bash "$repo_root/tool/use_local_packages.sh"
mkdir -p "$repo_root/artifacts"
log_file="$repo_root/artifacts/$log_name"
echo "Test log: $log_file"

# The example app only compiles with the gitignored lib/env.dart in place.
bash "$repo_root/tool/ci/ensure_example_env.sh"

cd "$repo_root/im_flutter_sdk/example"
flutter pub get

# Integration tests assume a cold app. `flutter test` installs over any existing
# installation (which keeps /data/data) and only uninstalls after the run, so a
# login left on the device by an earlier `flutter run` / auto-report / nightly
# run survives into this run: FL-APP-001 in logged_out_test.dart failed
# with 'zuoyu01' this way, because the Android SDK reports its persisted
# last-login user from SharedPreferences. CI always starts from a fresh
# emulator, so there this is a no-op (the uninstall of an absent package fails,
# which is ignored on purpose).
adb -s emulator-5554 uninstall "$app_id" >/dev/null 2>&1 || true

# Keep the array non-empty: expanding an empty array under set -u fails
# on bash 3.2 (e.g. when this script is run locally on macOS).
command=(flutter test "$test_target" -d emulator-5554)
ci_report_attempt_start 1
command+=(--file-reporter "json:$report_dir/attempt-1.events.jsonl")
if [[ -n "${CI_TEST_NAME:-}" ]]; then
  command+=(--name "$CI_TEST_NAME")
fi
if [[ "${GITHUB_ACTIONS:-}" != "true" ]]; then
  command+=(--reporter expanded)
fi
if [[ -n "${E2E_CONFIG_PATH:-}" ]]; then
  command+=(--dart-define-from-file="$E2E_CONFIG_PATH")
fi

set -o pipefail
status=0
"${command[@]}" 2>&1 | tee "$log_file" "$report_dir/attempt-1.log" || status=$?
ci_report_attempt "$status"
exit "$status"
