#!/bin/bash
# 确保测试模拟器上的 im_flutter_test App 在线并连上当前 managed server。
# 每次 pytest 前执行一次：App 重启后才会连上当前 pytest 的新 server 端口。
#
# 用法：
#   bash scripts/ensure_runners.sh                # 重启默认 4 个模拟器上的 App
#   SERIALS="5554 5556" bash scripts/ensure_runners.sh   # 只处理指定模拟器
set -u

ADB=${ADB:-/Users/andy_muyu/Library/Android/sdk/platform-tools/adb}
SERIALS=${SERIALS:-"5554 5556 5558 5560"}
PKG=com.easemob.im_flutter_test

echo "[ensure-runners] 重启模拟器 [$SERIALS] 上的 $PKG ..."
for s in $SERIALS; do
  $ADB -s emulator-$s shell am force-stop $PKG >/dev/null 2>&1
  $ADB -s emulator-$s shell am start -n $PKG/.MainActivity >/dev/null 2>&1
done

echo "[ensure-runners] 等待 App 启动（最多 20s）..."
for _ in $(seq 1 20); do
  missing=0
  for s in $SERIALS; do
    pid=$($ADB -s emulator-$s shell pidof $PKG 2>/dev/null | tr -d '\r')
    [ -z "$pid" ] && missing=1
  done
  [ "$missing" -eq 0 ] && break
  sleep 1
done

echo "[ensure-runners] 完成："
for s in $SERIALS; do
  echo "  emulator-$s: PID=$($ADB -s emulator-$s shell pidof $PKG 2>/dev/null | tr -d '\r')"
done
