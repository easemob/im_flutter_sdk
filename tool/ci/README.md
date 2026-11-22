# CI 测试操作说明（HarmonyOS）

本目录运行鸿蒙线的持续回归测试。版本升级的场景测试见单设备（`testing/single/auto_report.dart --platform ohos`）与多设备（`testing/multi/cases/`，经 `scripts/multi.sh` 调用，编排工具为独立仓 im-test-orchestrator），入口速查见 [AGENTS.md](../../AGENTS.md) 的「鸿蒙构建与验证入口」表。

## 启动与选择模拟器

任选一种方式启动鸿蒙模拟器：

**DevEco Studio 界面（常用）**：打开 DevEco Studio → 右上角设备选择器（或 Tools → Device Manager）选中虚拟设备（本机已验证 OpenHarmony 5.0.2.125 / API 14）点击启动，等待开机完成。

**命令行**：DevEco 自带的模拟器 CLI 在 `/Applications/DevEco-Studio.app/Contents/tools/emulator/Emulator`：

```bash
EMULATOR=/Applications/DevEco-Studio.app/Contents/tools/emulator/Emulator
"$EMULATOR" -list          # 列出已有实例（如 Huawei_Phone）
"$EMULATOR" -start Huawei_Phone   # 启动；后台运行可加 -noWindow
```

模拟器启动后 hdc 会自动连接；`hdc list targets` 确认在线。已验证的镜像：OpenHarmony 5.0.2.125 / API 14。

## 运行前准备

所有命令在业务仓库的 worktree 根目录执行，例如：

```bash
cd /Users/asterisk/Codes/zuoyu_flutter/im_flutter_sdk/.worktree/ohos-1.16.0
```

鸿蒙构建/测试使用 fvm 的 `custom_ohos`（Flutter 3.41.9+ohos-1.0.2，Dart 3.11.5），worktree 已通过 `.fvmrc` 锁定；鸿蒙命令统一走 `fvm flutter ...`，本目录的 harmony 脚本默认优先使用 `.fvm/flutter_sdk/bin/flutter`，可用 `FLUTTER_BIN` 覆盖。**不要对鸿蒙线使用官方 Flutter 执行 `pub get`**——它会重写 `example/.flutter-plugins-dependencies`（丢失 `plugins.ohos`）导致 hvigor 构建失败；跑完质量门禁或 Android/iOS 命令后，鸿蒙构建前必须先 `fvm flutter pub get`。

设备用 hdc 管理，脚本默认目标 `127.0.0.1:5555`。鸿蒙模拟器的 hdc 端口会漂移（重启模拟器/DevEco 后可能变成 5557、5559 等），**运行前必须先 `hdc list targets` 确认实际端口**：如果列出的不是 `127.0.0.1:5555`，本次运行要用 `OHOS_DEVICE` 显式指定，例如：

```bash
OHOS_DEVICE=127.0.0.1:5559 bash tool/ci/smoke_local.harmony.sh
```

脚本启动时打印 `warning: hdc does not list target '127.0.0.1:5555' (continuing; ...)` 就说明设备不在默认端口——它会继续执行，但 flutter 找不到该设备，套件必然失败（flutter.log 里是 `No supported devices found`）。看到这条警告不要继续跑，先确认 `hdc list targets` 再用 `OHOS_DEVICE` 重跑。本地模拟器使用无签名 hap，脚本默认 `OHOS_SKIP_CODESIGN=1`；项目已有真实签名配置时设为 `0`。

## 选择执行范围

| 入口 | 验证范围 | 是否需要账号 |
|---|---|---|
| `smoke_local.harmony.sh` | 未登录 `logged_out` 冒烟 | 否，无需凭证 |
| `nightly_local.harmony.sh [suite...]` | 全量鸿蒙集成套件，token 由脚本现场换取 | 是，5 个长期凭证 |
| `ohos_local.sh [suite...]` | 指定集成套件，使用显式凭证或已有配置 | 6 个 `E2E_*` 变量或 `E2E_CONFIG_PATH` |

可选套件：`logged_out` / `logged_in_base` / `logged_in_contact` / `logged_in_group` / `logged_in_user_info` / `logged_in_special`；不传则执行入口的默认全集。

### 无需登录的冒烟测试

```bash
bash tool/ci/smoke_local.harmony.sh
```

### 登录后的回归测试

首次在当前终端设置以下五项长期凭证，替换为真实测试环境的值：

```bash
export E2E_APP_KEY='实际 appKey'
export E2E_USER_ID='测试账号'
export E2E_REST_API='REST 服务地址'
export E2E_CLIENT_ID='实际 Client ID'
export E2E_CLIENT_SECRET='实际 Client Secret'

bash tool/ci/nightly_local.harmony.sh
# 只跑部分套件：
bash tool/ci/nightly_local.harmony.sh logged_in_base logged_in_group
```

脚本调用 `example/tool/env_tool.dart e2e-config` 换取 app token + user token，生成 mode 600 的临时 dart-define JSON 并在退出时删除。自动准备配置还需要 `curl`、`jq`。

如果已有有效的 dart-define JSON，可用 `E2E_CONFIG_PATH=/绝对路径/e2e-config.json` 执行，脚本直接使用它并保留文件，不再自动刷新 token。

### 指定套件或显式凭证

`ohos_local.sh` 直接调指定套件，凭证用 6 个 `E2E_*` 变量（在上述五项基础上补 `E2E_USER_TOKEN` 与 `E2E_APP_TOKEN`）或 `E2E_CONFIG_PATH`：

```bash
E2E_CONFIG_PATH=/绝对路径/e2e-config.json bash tool/ci/ohos_local.sh logged_in_base
```

套件内筛选单个用例用 `CI_TEST_NAME`（传给 `flutter test --name` 的正则，与 Android/iOS runner 同契约）：

```bash
CI_TEST_NAME=FL-MSG-010 E2E_CONFIG_PATH=/绝对路径/e2e-config.json \
  bash tool/ci/ohos_local.sh logged_in_base
```

## 报告与日志在哪里

每次执行生成带时间戳的目录，报告层与其他线同构（report.py）：首先打开 `artifacts/ci/<时间戳>/harmony/summary.md`（各套件通过/失败/未完成计数与证据链接），机器可读结果在同目录 `report.json`，控制台过程日志在 `artifacts/ci/<时间戳>/harmony/runner.log`。每个套件一个子目录 `artifacts/ci/<时间戳>/harmony/<套件>/`：

| 文件 | 用途 |
|---|---|
| `summary.md` / `run.json` | 该套件的独立报告与运行信息（初始化、筛选、提交、设备） |
| `attempt-N.log` | 第 N 次尝试的 flutter test 完整输出（含 hvigor 构建输出） |
| `attempt-N.events.jsonl` | 第 N 次尝试的 Flutter 结构化 JSON 事件 |
| `attempt-N.hilog.log.gz` | 第 N 次尝试的鸿蒙 native 原始日志（hdc hilog 关键词过滤：SDK/wrapper、进程生命周期、故障通道；过滤无匹配时保留全量兜底） |

加载阶段失败（hvigor 构建被中断、VM-service 连接失败等导致**零用例完成**）会自动重试一次，两次尝试的证据都保留在套件目录；已有用例完成后的失败是真实结果，不重试。构建或设备类失败不代表业务用例已执行，先看 runner.log 与 attempt-N.log 再定位。运行产物均被 Git 忽略。

测试遗留的 `flutter_ci_group_*` 孤儿群可用 `bash tool/ci/ohos_cleanup.sh` 经 REST 清理（需要 `E2E_APP_TOKEN`）。
