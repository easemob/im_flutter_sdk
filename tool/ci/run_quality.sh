#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
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

dart format --output=none --set-exit-if-changed \
  "$repo_root/im_flutter_sdk/lib" \
  "$repo_root/im_flutter_sdk/test" \
  "$repo_root/im_flutter_sdk/tool" \
  "$repo_root/im_flutter_sdk/example/integration_test"

for package in "${packages[@]}"; do
  (
    cd "$repo_root/$package"
    flutter analyze --fatal-infos
  )
done

(
  cd "$repo_root/im_flutter_sdk"
  flutter test --coverage
  dart run tool/ci/check_case_mapping.dart .
  dart run tool/ci/check_contracts.dart ..
  dart run tool/ci/check_versions.dart ..
)
