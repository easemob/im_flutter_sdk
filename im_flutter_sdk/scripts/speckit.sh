#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
usage(){
  cat <<USAGE
Usage: speckit <android|ios|build-all|check>

- android: 构建 Android 示例（依赖切换在 im_flutter_sdk_android/android/build.gradle 手动注释/取消注释）
- ios:     在 example/ios 执行 'pod install'（依赖切换在 podspec 手动注释/取消注释）
- build-all: 先 android 再 ios
- check: 运行规范检查（本地/远程依赖设置与资源完整性）
USAGE
}

cmd=${1:-}
case "$cmd" in
  android)
    # 构建示例 App（避免直接构建插件库缺少 Flutter 依赖导致失败）
    cd "$ROOT_DIR/example/android"
    ./gradlew assembleDebug
    ;;
  ios)
    pushd "$ROOT_DIR/example/ios" >/dev/null
    LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 pod install
    popd >/dev/null
    ;;
  ios-build)
    pushd "$ROOT_DIR/example/ios" >/dev/null
    LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug -destination 'generic/platform=iOS Simulator' build
    popd >/dev/null
    ;;
  build-all)
    "$ROOT_DIR/scripts/speckit.sh" android
    "$ROOT_DIR/scripts/speckit.sh" ios
    "$ROOT_DIR/scripts/speckit.sh" ios-build
    ;;
  check)
    "$ROOT_DIR/scripts/spec_check.sh" all
    ;;
  *) usage; exit 1;;
esac
