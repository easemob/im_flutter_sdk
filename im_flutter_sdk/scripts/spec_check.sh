#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
ANDROID_DIR="$ROOT_DIR/../im_flutter_sdk_android/android"
IOS_DIR="$ROOT_DIR/../im_flutter_sdk_ios/ios"

pass(){ echo "[PASS] $1"; }
fail(){ echo "[FAIL] $1"; return 1; }

check_android(){
  local ok=0
  local base_dir="$ANDROID_DIR/src/main/java"
  local gradle_file="$ANDROID_DIR/build.gradle"

  # 基线 wrapper
  local wrapper_count
  wrapper_count=$(find "$base_dir" -name '*.java' 2>/dev/null | wc -l | tr -d ' ')
  if [[ -d "$base_dir" && "$wrapper_count" -gt 0 ]]; then
    pass "Android 5.0: wrapper 存在: src/main/java ($wrapper_count 个文件)"
  else
    echo "建议：放置 Android 5.0 wrapper 到 src/main/java"; ok=1
  fi

  local jar_dir="$ANDROID_DIR/src/main/libs"
  local jni_dir="$ANDROID_DIR/src/main/jniLibs"
  local jar_count so_count
  jar_count=$(find "$jar_dir" -maxdepth 1 -name 'hyphenatechat_*.jar' 2>/dev/null | wc -l | tr -d ' ')
  so_count=$(find "$jni_dir" -name '*.so' 2>/dev/null | wc -l | tr -d ' ')
  [[ "$jar_count" -gt 0 ]] && pass "Android 5.0: JAR 存在 ($jar_count 个)" || { echo "建议：放置 hyphenatechat_5.0.0.jar 于 src/main/libs"; ok=1; }
  [[ "$so_count" -gt 0 ]] && pass "Android 5.0: jniLibs 存在 ($so_count 个 .so)" || { echo "建议：放置 so 到 src/main/jniLibs"; ok=1; }

  if grep -q "src/main/java" "$gradle_file" && ! grep -q "mergeWrapperSrc\|base500\|sdk423" "$gradle_file"; then
    pass "Android 5.0: build.gradle 使用单一 main source set"
  else
    echo "建议：build.gradle 仅保留 src/main，不要使用 flavor 或 mergeWrapperSrc"; ok=1
  fi

  # 依赖仅启用一种（本地 files 或远程）
  local local_active remote_active
  local_active=$(grep -E "^[[:space:]]*(api|implementation)[[:space:]]+files\(" "$gradle_file" | grep -v "^[[:space:]]*//" | wc -l | tr -d ' ')
  remote_active=$(grep -E "^[[:space:]]*(api|implementation)[[:space:]]+'io\\.hyphenate:hyphenate-chat" "$gradle_file" | grep -v "^[[:space:]]*//" | wc -l | tr -d ' ')
  if [[ "$local_active" -gt 0 && "$remote_active" -eq 0 ]] || [[ "$local_active" -eq 0 && "$remote_active" -gt 0 ]]; then
    pass "Android 5.0: 依赖仅启用一种（本地 或 远程）"
  else
    echo "建议：确保只启用本地或远程其中一种实现"; ok=1
  fi

  return $ok
}

check_ios(){
  local ok=0
  local podspec="$IOS_DIR/im_flutter_sdk_ios.podspec"
  local xc_h="$IOS_DIR/HyphenateChat.xcframework"
  local xc_s="$IOS_DIR/ShengwangInfra_iOS/aosl.xcframework"

  local vendored_active remote_active
  vendored_active=$(grep -E "^[[:space:]]*s\.vendored_frameworks\b" "$podspec" | grep -v "^[[:space:]]*#" | wc -l | tr -d ' ')
  remote_active=$(grep -E "^[[:space:]]*s\.dependency\s+'HyphenateChat'\b" "$podspec" | grep -v "^[[:space:]]*#" | wc -l | tr -d ' ')

  if [[ "$vendored_active" == "1" && "$remote_active" == "0" ]]; then
    pass "iOS: 本地 vendored 方案启用"
    [[ -d "$xc_h" ]] && pass "iOS: HyphenateChat.xcframework 存在" || { echo "建议：放置 $xc_h"; ok=1; }
    [[ -d "$xc_s" ]] && pass "iOS: ShengwangInfra_iOS/aosl.xcframework 存在" || { echo "建议：放置 $xc_s"; ok=1; }
  elif [[ "$vendored_active" == "0" && "$remote_active" == "1" ]]; then
    pass "iOS: 远程依赖方案启用"
  else
    echo "建议：podspec 仅启用 vendored 或远程依赖其中一种"; ok=1
  fi
  return $ok
}

main(){
  local target=${1:-all}
  local err=0
  case "$target" in
    android) check_android || err=1 ;;
    ios)     check_ios     || err=1 ;;
    all)     check_android || err=1; check_ios || err=1 ;;
    *) echo "用法: spec_check.sh [android|ios|all]"; exit 2;;
  esac
  exit $err
}

main "$@"
