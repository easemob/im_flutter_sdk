# testing/scripts — 阶段脚本入口

数据约定见 [测试动态数据与引用规范](../docs/2026-11-06-dynamic-data-contract.md)。Presence 用例已采用 `$global`；旧联系人命令及单设备直跑仍保留原有引用方式。

执行失败或结果不稳定时，先看 [多设备协同测试排查手册](../../docs/refs/2026-11-05-multi-device-test-troubleshooting.md)。实际验证与证据见 [Presence 订阅/发布/接收](../../docs/refs/multi-device-testing/2026-11-06-presence-collaboration-verification.md)。

## 调用关系与职责

```text
run_flow --flow <yaml> --platform ios|android|mixed [--devices ...]
├── prepare_data --flow <yaml>
│   ├── declaration.dart：用例 JSON 的 data → data-declaration.json
│   ├── environment.dart：配置、账号 Token → main/environment.json
│   ├── roles.dart：角色账号分配、用例数据 → data.json / role-data.json
│   └── preconditions.dart：用例声明的服务端前置条件
├── setup_devices：安装、启动、控制连接 → devices.json（无业务数据）
├── context.dart bind：按角色组合 → global.json / agents.json / flow.yaml
├── flow_runner：执行显式初始化、登录及业务流程，保存结果、事件和引用证据
├── collect_report：汇总本轮报告
└── stop_devices.py：认证本轮 App 后停止；保留运行数据，不删除 tmp

run_single --platform ... --script ... → make auto-report（旧单设备直跑保留）
smoke_agent → prepare_data + setup_devices + 控制接口冒烟
```

- `run_flow` 默认执行完整准备和运行；`--prepared` 使用同一 run-id 已准备的 `data.json`、`devices.json`，仍需上下文尚未绑定。它不恢复执行，也不允许重跑已消费的会话。
- 用例 JSON 的顶级 `data` 保存准备声明，`steps` 保存命令，YAML 保存流程；presence 两角色共用一份 JSON。格式及字段见[容器规则](../docs/2026-11-06-dynamic-data-contract.md#11-用例-json-容器规则)。新增同类用例只改用例文件，不修改设备准备脚本。
- `prepare_data --flow` 自动读取 `agents.*.script` 的 `data`，同一实际文件去重；多份声明拒绝隐式合并。旧相邻 `<flow>.data.json` 仍兼容，但与内嵌声明同时存在会报冲突。显式 `--data <json>` 完整替代自动发现结果；无声明时保留旧默认值。
- `--prebuilt ios=/path/Runner.app` 可复用已确认的控制模式 App；本次用例改造没有变更 App/SDK 源码。
- `--keep-app` 保留 App 便于排查；默认在成功或失败后都尝试停止本轮设备上的 App。清理失败单独记录，不覆盖原测试退出码。
- 设备准备、数据准备均可单独调用。`run_single` 的 HTTP 组合模式未在本次 presence 整改范围内实现。

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

# Presence 双 iOS：完整组合入口（也支持 --platform android）
bash testing/scripts/run_flow \
  --flow 5.0.0-multi-presence-positive.yaml --platform ios \
  --devices <设备A-UDID>,<设备B-UDID> --run-id presence-001
bash testing/scripts/collect_report --run-id presence-001

# 分步排查：相同 run-id，先准备数据，再准备设备，最后执行一次
bash testing/scripts/prepare_data --flow 5.0.0-multi-presence-positive.yaml --run-id presence-002
bash testing/scripts/setup_devices --platform ios --count 2 --roles alice,bob --mode control --run-id presence-002
bash testing/scripts/run_flow --flow 5.0.0-multi-presence-positive.yaml --run-id presence-002 --prepared

# 单设备直跑（旧路径）
bash testing/scripts/run_single --platform ios --script script_500_apis_positive.json

# 排查单台设备时，原子脚本同样用 bash 调用
bash testing/scripts/device/ios/list --booted
bash testing/scripts/device/ios/boot --device <udid>
```

## 本轮数据与证据

所有路径相对工作树根目录。`testing/tmp/<run-id>/` 是项目内的可见临时目录，保留供排查；与 `testing/reports/<run-id>/` 使用同一个运行 ID，两者均被 Git 忽略。

| 文件 | 内容 |
|---|---|
| `data-declaration.json` | 本轮选定的数据准备声明快照（未生成随机值、未填入 Token） |
| `data.json` | 数据工具准备的 account / biz.config / biz.input |
| `devices.json` | 设备角色、平台、设备 ID、控制地址及凭据 |
| `global.json` | 运行器输入：`initial` 初始数据及 `outputRoots` 可写结果区域 |
| `agents.json`、`flow.yaml`、`scripts/` | 本轮控制连接和流程、命令快照；旧命令需要的 env 保留在 agents.json |
| `trace.jsonl` | 实际派发参数、返回值、绑定及事件观察记录 |
| `references.json` | 引用路径、实际值、消费步骤（并行分支各自标注） |
| `global-final.json` | 运行结束后的数据视图，包括 API 结果和已匹配事件 |
| `<role>-events.jsonl` | 从 App 事件历史分页收集的原始事件，包括未匹配记录 |
| `run.log`、`exit.json`、`cleanup.json` | 执行输出、原退出码和独立清理结果 |
| `reports/<run-id>/flow-report.json` | 命令与目标通知的断言结果 |
| `reports/<run-id>/runtime-index.json` | 对应临时目录、文件列表、退出码及清理摘要，不复制凭据 |

原始运行文件包含 Token 等凭据，使用本地受限权限保存；共享报告不包含这些值。需要清理临时目录时先确认本轮证据与资源记录已归档。旧 `cleanup` 入口未在本次迁移中重写，人工调用时使用 `--keep-tmp`，避免删除唯一证据。
