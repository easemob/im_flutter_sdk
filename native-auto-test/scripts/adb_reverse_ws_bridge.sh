#!/usr/bin/env bash
set -euo pipefail

port="${WS_PORT:-4000}"
action="${1:-add}"

if [[ ! "$port" =~ ^[0-9]+$ ]] || ((port < 1 || port > 65535)); then
  echo "错误：端口必须是 1..65535，当前值：$port" >&2
  exit 2
fi

if [[ "$action" != "add" && "$action" != "remove" ]]; then
  echo "错误：操作必须是 add 或 remove，当前值：$action" >&2
  exit 2
fi

resolve_adb() {
  local requested="${ADB:-}"
  local candidate

  if [[ -n "$requested" ]]; then
    if [[ -x "$requested" ]]; then
      printf '%s\n' "$requested"
      return 0
    fi
    if command -v "$requested" >/dev/null 2>&1; then
      command -v "$requested"
      return 0
    fi
    echo "错误：ADB 指定的命令不可执行：$requested" >&2
    return 1
  fi

  for candidate in \
    "${ANDROID_HOME:-}/platform-tools/adb" \
    "${ANDROID_SDK_ROOT:-}/platform-tools/adb" \
    "$HOME/Library/Android/sdk/platform-tools/adb"; do
    if [[ "$candidate" != "/platform-tools/adb" && -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  if command -v adb >/dev/null 2>&1; then
    command -v adb
    return 0
  fi

  echo "错误：未找到 adb；请设置 ADB、ANDROID_HOME 或 ANDROID_SDK_ROOT" >&2
  return 1
}

adb_bin="$(resolve_adb)"
emulators=()

while read -r serial state _; do
  if [[ "$serial" == emulator-* && "$state" == "device" ]]; then
    emulators+=("$serial")
  fi
done < <("$adb_bin" devices | tail -n +2)

if ((${#emulators[@]} == 0)); then
  if [[ "$action" == "remove" ]]; then
    echo "没有在线 Android 模拟器，无需删除 tcp:$port reverse 映射。"
    exit 0
  fi
  echo "错误：未发现在线 Android 模拟器；请先启动模拟器并确认 adb devices 状态为 device" >&2
  exit 3
fi

for serial in "${emulators[@]}"; do
  "$adb_bin" -s "$serial" wait-for-device
  if [[ "$action" == "add" ]]; then
    echo "[配置] $serial reverse tcp:$port tcp:$port"
    "$adb_bin" -s "$serial" reverse "tcp:$port" "tcp:$port"
    reverse_list="$("$adb_bin" -s "$serial" reverse --list)"
    if ! grep -Fq "tcp:$port tcp:$port" <<<"$reverse_list"; then
      echo "错误：$serial 未回读到 tcp:$port reverse 映射" >&2
      exit 4
    fi
  else
    reverse_list="$("$adb_bin" -s "$serial" reverse --list)"
    if grep -Fq "tcp:$port tcp:$port" <<<"$reverse_list"; then
      echo "[删除] $serial reverse tcp:$port"
      "$adb_bin" -s "$serial" reverse --remove "tcp:$port"
    else
      echo "[跳过] $serial 没有 tcp:$port reverse 映射"
    fi
  fi
done

if [[ "$action" == "add" ]]; then
  echo "已完成 ${#emulators[@]} 台模拟器的 tcp:$port reverse 映射。"
else
  echo "已清理 ${#emulators[@]} 台模拟器的 tcp:$port reverse 映射。"
fi
