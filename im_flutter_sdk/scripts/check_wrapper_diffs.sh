#!/bin/bash
# 5.0 单版本布局不再有 flavor/base wrapper 可比较。
set -euo pipefail
if find im_flutter_sdk_android/android/src -maxdepth 1 -type d \( -name 'sdk*' -o -name 'base*' \) | grep -q .; then
  echo "ERROR: Android src 下不应保留 sdk*/base* 目录" >&2
  exit 1
fi
echo "OK: Android 使用 src/main 单版本 wrapper"
