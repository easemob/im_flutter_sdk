#!/usr/bin/env bash
set -euo pipefail

action="${1:-}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
project_root="$(cd "$script_dir/.." && pwd -P)"
state_dir="${WS_STATE_DIR:-$project_root/.local}"
pid_file="$state_dir/ws-bridge.pid"
env_file="$state_dir/ws-bridge.env"
log_file="$state_dir/ws-bridge.log"
lock_dir="$state_dir/ws-bridge.lock"
lock_owner_file="$lock_dir/pid"
lock_acquired=0
host="${WS_HOST:-127.0.0.1}"
port="${WS_PORT:-4000}"
path="${WS_PATH:-/iov/websocket/dual}"
python_requested="${PY:-python3}"
adb_requested="${ADB:-}"
reverse_script="$script_dir/adb_reverse_ws_bridge.sh"
relay_entrypoint="$project_root/src/tools/ws_relay_server.py"

if [[ "$action" != "up" && "$action" != "down" && "$action" != "check" ]]; then
  echo "用法：$0 up|down|check" >&2
  exit 2
fi

validate_runtime() {
  if [[ ! "$port" =~ ^[0-9]+$ ]] || ((port < 1 || port > 65535)); then
    echo "错误：端口必须是 1..65535，当前值：$port" >&2
    return 1
  fi
  if [[ -z "$host" || "$host" =~ [[:space:]] ]]; then
    echo "错误：WS_HOST 不能为空或包含空白字符" >&2
    return 1
  fi
  if [[ "$path" != /* || "$path" == *\?* || "$path" == *\#* || "$path" =~ [[:space:]] ]]; then
    echo "错误：WS_PATH 必须以 / 开头且不能包含 query、fragment 或空白" >&2
    return 1
  fi
}

release_lifecycle_lock() {
  if ((lock_acquired == 0)); then
    return
  fi
  local owner=""
  if [[ -f "$lock_owner_file" ]]; then
    owner="$(tr -d '[:space:]' <"$lock_owner_file")"
  fi
  if [[ "$owner" == "$$" ]]; then
    rm -f "$lock_owner_file" || true
    rmdir "$lock_dir" 2>/dev/null || true
  fi
  lock_acquired=0
}

try_acquire_lifecycle_lock() {
  if ! mkdir "$lock_dir" 2>/dev/null; then
    return 1
  fi
  if ! printf '%s\n' "$$" >"$lock_owner_file"; then
    rmdir "$lock_dir" 2>/dev/null || true
    return 1
  fi
  lock_acquired=1
  trap release_lifecycle_lock EXIT
}

acquire_lifecycle_lock() {
  local owner=""
  mkdir -p "$state_dir"
  if try_acquire_lifecycle_lock; then
    return 0
  fi

  if [[ -f "$lock_owner_file" ]]; then
    owner="$(tr -d '[:space:]' <"$lock_owner_file")"
  fi
  if [[ "$owner" =~ ^[0-9]+$ ]] && kill -0 "$owner" 2>/dev/null; then
    echo "错误：另一个 WebSocket lifecycle 操作正在执行：pid=$owner" >&2
    return 1
  fi

  echo "警告：回收陈旧 lifecycle 锁：${owner:-unknown}" >&2
  rm -f "$lock_owner_file"
  if ! rmdir "$lock_dir" 2>/dev/null; then
    echo "错误：lifecycle 锁包含未知状态，拒绝回收：$lock_dir" >&2
    return 1
  fi
  if ! try_acquire_lifecycle_lock; then
    echo "错误：另一个 WebSocket lifecycle 操作正在执行" >&2
    return 1
  fi
}

if ! validate_runtime; then
  exit 2
fi

if ! acquire_lifecycle_lock; then
  exit 10
fi

resolve_python() {
  local requested="$1"
  if [[ -x "$requested" ]]; then
    if [[ "$requested" == /* ]]; then
      printf '%s\n' "$requested"
    else
      printf '%s/%s\n' "$project_root" "${requested#./}"
    fi
    return 0
  fi
  if command -v "$requested" >/dev/null 2>&1; then
    command -v "$requested"
    return 0
  fi
  echo "错误：找不到可执行 Python：$requested" >&2
  return 1
}

preflight_python() {
  local python_bin="$1"
  if ! (
    cd "$project_root"
    PYTHONWARNINGS="ignore::DeprecationWarning" \
      "$python_bin" -c "import websockets; import src.tools.ws_relay_server"
  ); then
    echo "错误：Python WebSocket 依赖预检失败：$python_bin" >&2
    return 1
  fi
}

restore_runtime_from_env() {
  local python_bin="$1"
  local runtime restored_host restored_port restored_path
  if [[ ! -f "$env_file" ]]; then
    echo "错误：运行环境文件不存在：$env_file" >&2
    return 1
  fi
  if ! runtime="$("$python_bin" - "$env_file" <<'PY'
from pathlib import Path
import sys
from urllib.parse import urlsplit

env_file = Path(sys.argv[1])
line = next(
    (item for item in env_file.read_text(encoding="utf-8").splitlines()
     if item.startswith("WS_BASE_URL=")),
    None,
)
if line is None:
    print("WS_BASE_URL 缺失", file=sys.stderr)
    raise SystemExit(1)
value = line.split("=", 1)[1].strip()
parsed = urlsplit(value)
try:
    parsed_port = parsed.port
except ValueError as exc:
    print(f"WS_BASE_URL 端口非法: {exc}", file=sys.stderr)
    raise SystemExit(1)
if (
    parsed.scheme != "ws"
    or not parsed.hostname
    or parsed_port is None
    or parsed.username is not None
    or parsed.password is not None
    or not parsed.path.startswith("/")
    or parsed.query
    or parsed.fragment
    or any(char.isspace() for char in parsed.hostname + parsed.path)
):
    print("WS_BASE_URL 格式非法", file=sys.stderr)
    raise SystemExit(1)
print(parsed.hostname, parsed_port, parsed.path, sep="\t")
PY
)"; then
    echo "错误：无法从运行环境文件恢复 relay 参数：$env_file" >&2
    return 1
  fi
  IFS=$'\t' read -r restored_host restored_port restored_path <<<"$runtime"
  host="$restored_host"
  port="$restored_port"
  path="$restored_path"
  validate_runtime
}

read_pid() {
  if [[ ! -f "$pid_file" ]]; then
    return 1
  fi
  local pid
  pid="$(tr -d '[:space:]' <"$pid_file")"
  if [[ ! "$pid" =~ ^[0-9]+$ ]]; then
    return 1
  fi
  printf '%s\n' "$pid"
}

is_managed_pid() {
  local pid="$1"
  local command_line
  if ! kill -0 "$pid" 2>/dev/null; then
    return 1
  fi
  command_line="$(ps -p "$pid" -o command= 2>/dev/null || true)"
  [[ "$command_line" == *"$relay_entrypoint"* ]] &&
    [[ "$command_line" == *"--port $port"* ]] &&
    [[ "$command_line" == *"--path $path"* ]]
}

stop_managed_pid() {
  local pid="$1"
  local attempt
  if ! is_managed_pid "$pid"; then
    return 1
  fi
  kill -TERM "$pid"
  for attempt in {1..60}; do
    if ! kill -0 "$pid" 2>/dev/null; then
      return 0
    fi
    sleep 0.05
  done
  if is_managed_pid "$pid"; then
    kill -KILL "$pid"
  fi
}

run_reverse() {
  local operation="$1"
  ADB="$adb_requested" WS_PORT="$port" bash "$reverse_script" "$operation"
}

wait_for_listener() {
  local python_bin="$1"
  "$python_bin" - "$host" "$port" <<'PY'
import socket
import sys
import time

host = sys.argv[1]
port = int(sys.argv[2])
last_error = None
for _ in range(50):
    try:
        with socket.create_connection((host, port), timeout=0.2):
            raise SystemExit(0)
    except OSError as exc:
        last_error = exc
        time.sleep(0.1)
print(f"relay listener 未就绪: {last_error!r}", file=sys.stderr)
raise SystemExit(1)
PY
}

websocket_health_check() {
  local python_bin="$1"
  "$python_bin" - "$host" "$port" "$path" <<'PY'
import asyncio
import sys

import websockets

host = sys.argv[1]
port = int(sys.argv[2])
path = sys.argv[3]
url = f"ws://{host}:{port}{path}?topic=__ws_bridge_health__"

async def check() -> None:
    async with websockets.connect(url, open_timeout=1, close_timeout=1):
        pass

asyncio.run(check())
PY
}

write_state_file() {
  local target="$1"
  local content="$2"
  local temporary="$target.tmp.$$"
  if [[ -d "$target" ]]; then
    echo "错误：环境文件路径被目录占用：$target" >&2
    return 1
  fi
  umask 077
  if ! printf '%s\n' "$content" >"$temporary"; then
    rm -f "$temporary"
    return 1
  fi
  if ! mv "$temporary" "$target"; then
    rm -f "$temporary"
    return 1
  fi
}

up() {
  local python_bin pid="" started_new=0
  python_bin="$(resolve_python "$python_requested")"
  if ! preflight_python "$python_bin"; then
    exit 4
  fi
  mkdir -p "$state_dir"

  if pid="$(read_pid 2>/dev/null)"; then
    if is_managed_pid "$pid"; then
      echo "[复用] 本地 relay 已运行，pid=$pid"
    elif kill -0 "$pid" 2>/dev/null; then
      echo "错误：PID 文件指向非本项目 relay 进程，拒绝覆盖或终止：$pid" >&2
      exit 5
    else
      rm -f "$pid_file"
      pid=""
    fi
  else
    rm -f "$pid_file"
  fi

  if [[ -z "$pid" ]]; then
    : >"$log_file"
    (
      cd "$project_root"
      nohup "$python_bin" "$relay_entrypoint" \
        --host "$host" --port "$port" --path "$path" \
        >>"$log_file" 2>&1 </dev/null &
      printf '%s\n' "$!"
    ) >"$pid_file.tmp.$$"
    pid="$(tr -d '[:space:]' <"$pid_file.tmp.$$")"
    mv "$pid_file.tmp.$$" "$pid_file"
    chmod 600 "$pid_file"
    started_new=1

    if ! wait_for_listener "$python_bin" || ! is_managed_pid "$pid"; then
      echo "错误：本地 relay 启动失败，请查看 $log_file" >&2
      if is_managed_pid "$pid"; then
        stop_managed_pid "$pid" || true
      fi
      rm -f "$pid_file" "$env_file"
      exit 6
    fi
  fi

  if ! run_reverse add; then
    echo "错误：reverse 配置失败，正在回滚本次启动" >&2
    run_reverse remove >/dev/null 2>&1 || true
    if ((started_new)); then
      stop_managed_pid "$pid" || true
      rm -f "$pid_file" "$env_file"
    fi
    exit 7
  fi

  if ! write_state_file "$env_file" "WS_BASE_URL=ws://$host:$port$path"; then
    echo "错误：本地 WebSocket 环境文件写入失败，正在回滚" >&2
    run_reverse remove >/dev/null 2>&1 || true
    if ((started_new)); then
      stop_managed_pid "$pid" || true
      rm -f "$pid_file"
    fi
    exit 8
  fi
  echo "本地 WebSocket 桥接已就绪："
  echo "  URL: ws://$host:$port$path"
  echo "  PID: $pid"
  echo "  ENV: $env_file"
  echo "  LOG: $log_file"
}

check() {
  local python_bin pid
  python_bin="$(resolve_python "$python_requested")"
  if ! restore_runtime_from_env "$python_bin"; then
    echo "错误：健康检查失败：无法读取受管 relay 状态" >&2
    return 9
  fi
  if ! preflight_python "$python_bin"; then
    echo "错误：健康检查失败：Python WebSocket 依赖不可用" >&2
    return 9
  fi
  if ! pid="$(read_pid 2>/dev/null)"; then
    echo "错误：健康检查失败：PID 文件缺失或非法：$pid_file" >&2
    return 9
  fi
  if ! is_managed_pid "$pid"; then
    echo "错误：健康检查失败：受管 relay 进程不存在或身份不匹配：pid=$pid" >&2
    return 9
  fi
  if ! websocket_health_check "$python_bin"; then
    echo "错误：健康检查失败：WebSocket 握手失败：ws://$host:$port$path" >&2
    return 9
  fi
  echo "本地 WebSocket 桥接健康检查通过：ws://$host:$port$path"
}

down() {
  local python_bin="" pid="" status=0
  mkdir -p "$state_dir"

  if [[ -f "$env_file" ]]; then
    if ! python_bin="$(resolve_python "$python_requested")"; then
      echo "错误：无法读取受管 relay 状态；PID/env 已保留" >&2
      return 1
    fi
    if ! restore_runtime_from_env "$python_bin"; then
      echo "错误：无法读取受管 relay 状态；PID/env 已保留" >&2
      return 1
    fi
  fi

  if ! run_reverse remove; then
    echo "警告：reverse 清理失败，继续停止本地 relay" >&2
    status=1
  fi

  if pid="$(read_pid 2>/dev/null)"; then
    if is_managed_pid "$pid"; then
      if ! stop_managed_pid "$pid"; then
        echo "错误：无法停止受管 relay pid=$pid" >&2
        status=1
      fi
    elif kill -0 "$pid" 2>/dev/null; then
      echo "错误：pid=$pid 不是本项目 relay，未终止该进程" >&2
      status=1
    fi
  elif [[ -e "$pid_file" ]]; then
    echo "错误：PID 文件内容非法，无法确认 relay 状态：$pid_file" >&2
    status=1
  fi

  if ((status == 0)); then
    rm -f "$pid_file" "$env_file"
    echo "本地 WebSocket 桥接已停止；运行日志保留在 $log_file"
  else
    echo "错误：本地 WebSocket 桥接未完全停止或清理；PID/env 已保留，请修复后重试 down" >&2
  fi
  return "$status"
}

if [[ "$action" == "up" ]]; then
  up
elif [[ "$action" == "down" ]]; then
  down
else
  check
fi
