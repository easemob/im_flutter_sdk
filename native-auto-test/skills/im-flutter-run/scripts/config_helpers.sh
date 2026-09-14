#!/usr/bin/env bash
# Config resolution/rendering helpers for run.sh. Source-only; no side effects.
#
# 环境文件（app schema）与桥接文件分离，选择优先级：
#   环境：--config > IM_TEST_CONFIG > <root>/config/config.yaml
#   桥接：--bridge-config > IM_BRIDGE_CONFIG > <root>/config/bridge.yaml

# resolve_config_files <root> <cli_config> <cli_bridge>
# 成功时导出 IM_TEST_CONFIG / IM_BRIDGE_CONFIG 并设置 ENV_CONFIG / BRIDGE_CONFIG。
# 失败时打印原因到 stderr 并返回 1。
resolve_config_files() {
  local root="$1" cli_env="$2" cli_bridge="$3"
  local env_cfg bridge_cfg

  if [[ -n "$cli_env" ]]; then
    env_cfg="$cli_env"
  elif [[ -n "${IM_TEST_CONFIG:-}" ]]; then
    env_cfg="$IM_TEST_CONFIG"
  else
    env_cfg="$root/config/config.yaml"
  fi
  if [[ ! -f "$env_cfg" ]]; then
    echo "环境配置文件不存在: ${env_cfg}（用 --config 或 IM_TEST_CONFIG 指定，或放置 config/config.yaml）" >&2
    return 1
  fi
  ENV_CONFIG="$(cd "$(dirname "$env_cfg")" && pwd -P)/$(basename "$env_cfg")"

  if [[ -n "$cli_bridge" ]]; then
    bridge_cfg="$cli_bridge"
  elif [[ -n "${IM_BRIDGE_CONFIG:-}" ]]; then
    bridge_cfg="$IM_BRIDGE_CONFIG"
  else
    bridge_cfg="$root/config/bridge.yaml"
  fi
  if [[ ! -f "$bridge_cfg" ]]; then
    echo "桥接配置文件不存在: ${bridge_cfg}（用 --bridge-config 或 IM_BRIDGE_CONFIG 指定，或放置 config/bridge.yaml）" >&2
    return 1
  fi
  BRIDGE_CONFIG="$(cd "$(dirname "$bridge_cfg")" && pwd -P)/$(basename "$bridge_cfg")"

  export IM_TEST_CONFIG="$ENV_CONFIG"
  export IM_BRIDGE_CONFIG="$BRIDGE_CONFIG"
}

# render_lane_bridge <src> <dst> <port>
# 仅把 websocket.base_url 的 127.0.0.1 端口改写为 <port>，其余内容原样保留。
render_lane_bridge() {
  local src="$1" dst="$2" port="$3"
  sed -E "s#(base_url:[[:space:]]*\"?ws://127\.0\.0\.1:)[0-9]+#\1$port#" "$src" > "$dst"
}
