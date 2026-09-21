#!/usr/bin/env bash
# Scans the Flutter wrapper sources for calls to deprecated HyphenateChat APIs.
#
# How it works: the wrappers are compiled against the native SDK, so javac and
# clang report every deprecated API they still call. Each platform is cleaned and
# compiled from scratch because an incremental build skips unchanged files and
# re-emits none of their warnings; the full log is kept under
# reports/<version>/deprecated/ and parsed by
# im_flutter_sdk/tool/ci/check_deprecated_api.dart.
#
# The scan only reports: findings do not fail the run. It fails when the build
# fails or when the log shows a reused compile, since either makes an empty
# result meaningless (see docs/spec/2026-09-21-deprecated-api-scan-spec.md).
#
# Usage:
#   bash tool/ci/scan_deprecated.sh            # both platforms
#   bash tool/ci/scan_deprecated.sh android    # Android wrapper only
#   bash tool/ci/scan_deprecated.sh ios        # iOS wrapper only
#
# Output (gitignored; <version> is the current branch, e.g. 5.0.0):
#   reports/<version>/deprecated/{android,ios}-raw.log
#   reports/<version>/deprecated/{android,ios}-deprecated-api.json
#   reports/<version>/deprecated/native-deprecated-api.md
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
EXAMPLE_DIR="$REPO_ROOT/im_flutter_sdk/example"
IOS_DIR="$EXAMPLE_DIR/ios"
CHECKER="$REPO_ROOT/im_flutter_sdk/tool/ci/check_deprecated_api.dart"
LINT_INIT="$REPO_ROOT/tool/ci/enable_deprecation_lint.gradle"

# CocoaPods compiles the iOS wrapper as a target of the example's Pods project.
IOS_POD_TARGET="im_flutter_sdk_ios"
# The Android wrapper is a Gradle subproject of the example app.
ANDROID_MODULE=":im_flutter_sdk_android"

PLATFORM="${1:-all}"
case "$PLATFORM" in
  all | android | ios) ;;
  *)
    echo "usage: bash tool/ci/scan_deprecated.sh [all|android|ios]" >&2
    exit 2
    ;;
esac

for command in dart flutter git; do
  command -v "$command" >/dev/null 2>&1 || {
    echo "error: $command not found in PATH" >&2
    exit 2
  }
done

# The reports are version-scoped local evidence, and the version is the current
# branch (see AGENTS.md "Git 分支管理"): branch 5.0.0 writes reports/5.0.0/
# deprecated/, next to the auto-mode reports.
if ! VERSION_BRANCH="$(git -C "$REPO_ROOT" symbolic-ref --short -q HEAD)"; then
  echo "error: HEAD is not on a branch, so the report directory is unknown." >&2
  echo "       check out the version branch (e.g. 5.0.0) and re-run the scan." >&2
  exit 2
fi
REPORT_DIR="$REPO_ROOT/reports/$VERSION_BRANCH/deprecated"

mkdir -p "$REPORT_DIR"

# Resolves the example's plugins: Gradle needs .flutter-plugins-dependencies and
# CocoaPods needs Flutter/Generated.xcconfig, both written by pub get.
resolve_dependencies() {
  (
    cd "$EXAMPLE_DIR"
    flutter pub get
  )
}

scan_android() {
  resolve_dependencies
  local raw_log="$REPORT_DIR/android-raw.log"
  echo "Android: compiling $ANDROID_MODULE (log: $raw_log)..."
  if ! (
    cd "$EXAMPLE_DIR/android"
    ./gradlew \
      "$ANDROID_MODULE:clean" \
      "$ANDROID_MODULE:compileDebugJavaWithJavac" \
      -I "$LINT_INIT" \
      --console=plain
  ) >"$raw_log" 2>&1; then
    echo "error: the Android build failed, so the scan found nothing usable." >&2
    echo "       full log: $raw_log" >&2
    tail -n 20 "$raw_log" >&2
    exit 1
  fi
}

scan_ios() {
  resolve_dependencies
  if [[ ! -d "$IOS_DIR/Pods/Pods.xcodeproj" ]]; then
    echo "iOS: Pods are missing, running pod install..."
    (
      cd "$IOS_DIR"
      pod install
    )
  fi
  if ! xcodebuild -list -project "$IOS_DIR/Pods/Pods.xcodeproj" -json |
    grep -q "\"$IOS_POD_TARGET\""; then
    echo "error: target '$IOS_POD_TARGET' is missing from Pods.xcodeproj." >&2
    echo "       hint: the iOS plugin may no longer be integrated with CocoaPods." >&2
    exit 1
  fi

  local raw_log="$REPORT_DIR/ios-raw.log"
  echo "iOS: compiling $IOS_POD_TARGET (log: $raw_log)..."
  # -quiet keeps warnings and errors only, which is exactly what the scan needs.
  if ! (
    cd "$IOS_DIR"
    xcodebuild \
      -project Pods/Pods.xcodeproj \
      -target "$IOS_POD_TARGET" \
      -configuration Debug \
      -sdk iphonesimulator \
      -quiet clean build \
      CODE_SIGNING_ALLOWED=NO \
      CODE_SIGNING_REQUIRED=NO
  ) >"$raw_log" 2>&1; then
    echo "error: the iOS build failed, so the scan found nothing usable." >&2
    echo "       full log: $raw_log" >&2
    tail -n 20 "$raw_log" >&2
    exit 1
  fi
}

checker_arguments=(--out-dir="$REPORT_DIR")

if [[ "$PLATFORM" == "all" || "$PLATFORM" == "android" ]]; then
  scan_android
  checker_arguments+=(--android-raw-log="$REPORT_DIR/android-raw.log")
fi

if [[ "$PLATFORM" == "all" || "$PLATFORM" == "ios" ]]; then
  scan_ios
  checker_arguments+=(--ios-raw-log="$REPORT_DIR/ios-raw.log")
fi

dart "$CHECKER" "${checker_arguments[@]}"
