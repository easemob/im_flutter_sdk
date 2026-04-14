#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
ANDROID_DIR="$ROOT_DIR/../im_flutter_sdk_android/android"
IOS_DIR="$ROOT_DIR/../im_flutter_sdk_ios/ios"

pass(){ echo "[PASS] $1"; }
fail(){ echo "[FAIL] $1"; return 1; }

check_android(){
  local ok=0
  local libs_base="$ANDROID_DIR/libs/easemob-sdk"
  local jni_dir="$libs_base/libs"
  local gradle_file="$ANDROID_DIR/build.gradle"

  [[ -d "$libs_base" ]] && pass "Android: 本地目录存在: $libs_base" || { echo "建议：创建不带版本号目录 easemob-sdk/"; ok=1; }
  [[ -d "$jni_dir" ]] && pass "Android: jniLibs 目录存在: $jni_dir" || { echo "建议：将 so 放到 libs/ 下"; ok=1; }

  # jar 检查
  local jar_count
  jar_count=$(find "$jni_dir" -maxdepth 1 -name 'hyphenatechat_*.jar' 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$jar_count" != "0" ]]; then
    pass "Android: 发现 hyphenatechat_*.jar"
  else
    echo "建议：放置 hyphenatechat_<ver>.jar 于 $jni_dir"; ok=1
  fi

  # build.gradle 检查
  if grep -q "jniLibs.srcDirs\s*=\s*\['./libs/easemob-sdk/libs'\]" "$gradle_file"; then
    pass "Android: jniLibs.srcDirs 指向 ./libs/easemob-sdk/libs"
  else
    echo "建议：jniLibs.srcDirs 设为 ['./libs/easemob-sdk/libs']"; ok=1
  fi

  local local_active remote_active
  local_active=$(grep -E "^[[:space:]]*implementation[[:space:]]+files\(" "$gradle_file" | grep -v "^[[:space:]]*//" | wc -l | tr -d ' ')
  remote_active=$(grep -E "^[[:space:]]*implementation[[:space:]]+'io\\.hyphenate:hyphenate-chat" "$gradle_file" | grep -v "^[[:space:]]*//" | wc -l | tr -d ' ')
  if [[ "$local_active" == "1" && "$remote_active" == "0" ]] || [[ "$local_active" == "0" && "$remote_active" == "1" ]]; then
    pass "Android: 依赖仅启用一种（本地 或 远程）"
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
