#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
ANDROID_DIR="$ROOT_DIR/../im_flutter_sdk_android/android"
IOS_DIR="$ROOT_DIR/../im_flutter_sdk_ios/ios"

pass(){ echo "[PASS] $1"; }
fail(){ echo "[FAIL] $1"; return 1; }

check_android(){
  local ok=0
  local base_dir="$ANDROID_DIR/src/base500/java"
  local gradle_file="$ANDROID_DIR/build.gradle"

  # 基线 wrapper
  local wrapper_count
  wrapper_count=$(find "$base_dir" -name '*.java' 2>/dev/null | wc -l | tr -d ' ')
  if [[ -d "$base_dir" && "$wrapper_count" -gt 0 ]]; then
    pass "Android: 基线 wrapper 存在: src/base500/java ($wrapper_count 个文件)"
  else
    echo "建议：放置 5.0 基线 wrapper 到 src/base500/java"; ok=1
  fi

  # 各 flavor 的 jar + jniLibs（含基线 base500；main 无资产）
  local flavor_dir flavor jar_dir jni_dir jar_count so_count
  for flavor_dir in "$ANDROID_DIR"/src/base500 "$ANDROID_DIR"/src/sdk*/; do
    [[ -d "$flavor_dir" ]] || continue
    flavor=$(basename "$flavor_dir")
    jar_dir="$flavor_dir/libs"
    jni_dir="$flavor_dir/jniLibs"
    jar_count=$(find "$jar_dir" -maxdepth 1 -name 'hyphenatechat_*.jar' 2>/dev/null | wc -l | tr -d ' ')
    so_count=$(find "$jni_dir" -name '*.so' 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$jar_count" -gt 0 ]]; then
      pass "Android: $flavor jar 存在 ($jar_count 个)"
    else
      echo "建议：放置 hyphenatechat_*.jar 于 $flavor/libs"; ok=1
    fi
    if [[ "$so_count" -gt 0 ]]; then
      pass "Android: $flavor jniLibs 存在 ($so_count 个 .so)"
    else
      echo "建议：放置 so 到 $flavor/jniLibs"; ok=1
    fi
  done

  # build.gradle 基线 + merge 机制
  if grep -q "mergeWrapperSrc" "$gradle_file" && grep -q "base500/java" "$gradle_file"; then
    pass "Android: build.gradle 使用基线+merge 拓扑"
  else
    echo "建议：build.gradle 配置 base500 基线 + mergeWrapperSrc"; ok=1
  fi

  # 依赖仅启用一种（本地 files 或远程），每个 flavor 都应满足
  local local_active remote_active
  local_active=$(grep -E "^[[:space:]]*sdk[0-9]+Api[[:space:]]+files\(" "$gradle_file" | grep -v "^[[:space:]]*//" | wc -l | tr -d ' ')
  remote_active=$(grep -E "^[[:space:]]*sdk[0-9]+Api[[:space:]]+'io\\.hyphenate:hyphenate-chat" "$gradle_file" | grep -v "^[[:space:]]*//" | wc -l | tr -d ' ')
  if [[ "$local_active" -gt 0 && "$remote_active" -eq 0 ]] || [[ "$local_active" -eq 0 && "$remote_active" -gt 0 ]]; then
    pass "Android: 依赖仅启用一种（本地 或 远程）"
  else
    echo "建议：确保每个 flavor 只启用本地或远程其中一种实现"; ok=1
  fi

  # 冗余 wrapper 检查
  if "$ROOT_DIR/scripts/check_wrapper_diffs.sh" >/dev/null 2>&1; then
    pass "Android: 无冗余 wrapper 复制"
  else
    echo "建议：清理 flavor 中与基线重复的 wrapper（见 check_wrapper_diffs.sh）"; ok=1
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
