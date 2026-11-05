# testing/scripts — 阶段脚本入口

对应 [总体规格 §3/§4](../../docs/spec/2026-11-04-example-testing-spec.md)：六步闭环每阶段一个编排脚本，设备操作拆分为**按平台的原子脚本**，编排脚本组合原子脚本复用。所有脚本 `--help` 可查用法。

## 调用关系

```text
smoke_agent（冒烟编排的编排）
├── prepare_data                        # 数据准备
│   ├── make config                     # （首次）导入本地配置
│   ├── make env-gettoken RUN_ID=<id>   # 换 User Token → tmp/<run-id>/main/environment.json
│   └── resources.dart prepare-group    # 临时群 ×N
└── setup_devices                       # 设备准备（--mode control）
    ├── device/ios/list --booted        # ① 选择设备（--devices 可指定）
    ├── device/ios/boot                 # ② 逐台启动 + bootstatus 等就绪
    ├── device/ios/install              # ③ 构建一次（control=API_CONTROL）+ 各台安装
    └── device/ios/launch               # ④ 启动 app + 轮询 [AGENT_CONTROL] 凭据
        └── 产物 tmp/<run-id>/agents.json（role/endpoint/token/instanceId/log）

run_single                              # 单设备直跑（§3.3 路径 1）
└── make auto-report PLATFORM=… SCRIPT=…

run_flow                                # 多设备执行（§3.4）
└── flow_runner run <flow.yaml> --report-dir testing/reports
    （前置：setup_devices --mode control 已产出 agents.json）

collect_report [--run-id]               # 报告摘要（§3.5）
cleanup --run-id                        # 清理：群资源 → tmp（归档检查）→ 进程（§3.6）
```

## 原子脚本（可单独执行，排查时与手动命令一致）

| 脚本 | 作用 | 关键参数 |
|---|---|---|
| `device/ios/list` | 枚举/选择模拟器 | `--booted` `--available` `--json` |
| `device/ios/boot` | 启动并等待就绪 | `--device <udid>` `--timeout <sec>` |
| `device/ios/install` | 构建 + 安装 | `--device` `--mode control\|plain` `--app <path>`（复用产物） |
| `device/ios/launch` | 启动 app、读凭据 | `--device` `--mode control` `--out <log>` |
| `device/android/list` | adb 设备枚举 | `--json` |
| `device/android/install` | 构建 + 安装 APK | `--device` `--mode control\|plain` `--app <apk>`（复用产物） |
| `device/android/launch` | 启动 app、读凭据、转发端口 | `--device` `--mode control` `--out <log>` |
| `device/android/forward` | 端口转发 | `--device` `--port` `--remove` |

Android v1 约束：设备须已在线（`adb devices` 可见）；模拟器开机/批量端口分配表在
device-management 子文档落地后接入。凭据捕获与 iOS 同构：Flutter `print()` 不写
stdout（Android 进 logcat / iOS 进 os_log），launch 脚本经 `adb logcat` 流式捕获
`[AGENT_CONTROL]` 行，再 `adb forward tcp:0 tcp:<app端口>` 得到宿主可达端点。

## Shell 兼容性（bash >= 3.2，运行时强制）

所有脚本在 `set -euo pipefail` 之前 source [`_compat.sh`](_compat.sh)：非 bash（zsh/dash 等）或 bash < 3.2 会**第一行就失败**并给出明确提示，而不是语法错乱或静默退出。

背景：macOS 系统自带 bash 长期停留在 3.2.57（无 mapfile/关联数组），且 `bash -n` 只查语法、查不出内建命令缺失——曾因此翻车。

**新增/修改脚本的规则**：

1. 头部保留 `#!/usr/bin/env bash`，`set -euo pipefail` 之前加 `. "$(dirname "$0")/_compat.sh" || exit 64`（device/ 下两级目录用 `../../_compat.sh`）；
2. 禁用 bash 4+ 特性：`mapfile`/`readarray`、`declare -A`/`local -A`（关联数组）、`&>>`、`|&`、`coproc`、`${var,,}`/`${var^^}`、`${var@Q}` 等——改用 while-read 循环、下标数组、显式重定向；
3. 避开 bash 特殊变量名做自定义变量（如 `GROUPS` 是只读的用户组数组，赋值无效）；
4. grep 锚定外部命令输出时注意行尾空白（如 `simctl list devices` 每行末尾带空格，`\(...\)$` 会失配，且 pipefail 下 grep 无匹配 = 退出 1 = 脚本静默中止）；
5. 命令替换里的管道在 `set -euo pipefail` 下任何一段失败都会中止脚本，必要时 `|| true` 兜底并显式校验结果。

macOS 的 `/bin/sh` 实为 bash 3.2（POSIX 模式），脚本可运行；Linux 下 `/bin/sh` 多为 dash，会被守卫拦截。

## 典型组合

统一用 `bash` 显式调用（脚本使用数组/`[[ ]]`/herestring 等 bash 特性，但**不**用 bash 4+ 特性，兼容 macOS 系统自带 bash 3.2）：

```bash
# 一次 iOS agent 冒烟（全自动断言）
bash testing/scripts/smoke_agent

# Android agent 冒烟（emulator-5554 已在线即可）
bash testing/scripts/smoke_agent --platform android

# 指定设备 / 保留 app 便于人工查看
bash testing/scripts/smoke_agent --platform ios --device <udid> --keep-app

# 多设备准备 + 跑一个流程
bash testing/scripts/prepare_data --run-id m2 --groups 1
bash testing/scripts/setup_devices --platform ios --count 2 --mode control --run-id m2
bash testing/scripts/run_flow --flow 5.0.0-multi-direct-read-receipt-positive.yaml
bash testing/scripts/collect_report
bash testing/scripts/cleanup --run-id m2

# 单设备直跑（旧路径）
bash testing/scripts/run_single --platform ios --script script_500_apis_positive.json

# 排查单台设备时，原子脚本同样用 bash 调用
bash testing/scripts/device/ios/list --booted
bash testing/scripts/device/ios/boot --device <udid>
```

约定：`tmp/<run-id>/` 为运行中间产物（Git 忽略），`reports/<run-id>/` 为最终报告；凭据只出现在 `tmp` 与进程输出，不入报告。
