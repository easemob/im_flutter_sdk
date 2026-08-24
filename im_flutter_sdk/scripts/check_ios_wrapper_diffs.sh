#!/bin/bash
# 5.0 单版本布局不再有 sdk*/base500 差异目录可比较。
set -euo pipefail
if find im_flutter_sdk_ios/ios/Classes -maxdepth 1 -type d \( -name 'sdk*' -o -name 'base*' \) | grep -q .; then
  echo "ERROR: iOS Classes 下不应保留 sdk*/base* 目录" >&2
  exit 1
fi
echo "OK: iOS 使用 Classes 单版本 wrapper"
