#!/usr/bin/env bash
set -euo pipefail

# API Adapt Agent — 依据 CHANGELOG 对新增/变更 API 与回调进行适配核对（只检查，不改代码）
#
# 用法示例：
#   im_flutter_sdk/scripts/agents/api_adapt_agent.sh check

ROOT_DIR=$(cd "$(dirname "$0")/../.." && pwd)
RG="rg -n --no-heading -S"

list_changelog_keys(){
  echo "[api-adapt] 从 CHANGELOG 汇总关键词："
  $RG "getCurrentDeviceId|loadConversationMessagesWithKeyword|loadMessagesWithIds|onStreamMessagesReceived" \
    "$ROOT_DIR/../im_flutter_sdk_android/CHANGELOG.md" \
    "$ROOT_DIR/../im_flutter_sdk_ios/CHANGELOG.md" || true
}

check_dart_side(){
  echo "\n[api-adapt] 检查 Dart 侧实现/导出/事件："
  $RG "getCurrentDeviceId|loadConversationMessagesWithKeyword|loadMessagesWithIds|onStreamMessagesReceived|EMStreamChunk" \
    "$ROOT_DIR/../im_flutter_sdk" || true
}

check_android_side(){
  echo "\n[api-adapt] 检查 Android Wrapper："
  $RG "getCurrentDeviceId|loadConversationMessagesWithKeyword|loadMessagesWithIds|onStreamMessagesReceived" \
    "$ROOT_DIR/../im_flutter_sdk_android/android/src/main/java/com/easemob/im_flutter_sdk" || true
}

check_ios_side(){
  echo "\n[api-adapt] 检查 iOS Wrapper："
  $RG "getCurrentDeviceId|loadConversationMessagesWithKeyword|loadMessagesWithIds|onStreamMessagesReceived" \
    "$ROOT_DIR/../im_flutter_sdk_ios/ios/Classes" || true
}

main(){
  case "${1:-check}" in
    check)
      list_changelog_keys
      check_dart_side
      check_android_side
      check_ios_side
      ;;
    *) echo "用法: api_adapt_agent.sh check"; exit 2;;
  esac
}

main "$@"

