# 单设备平版测试入口

场景在 `cases/`，执行与报告工具为 `auto_report.dart`，共用 example 的 API 注册和脚本引擎。设计规则见 [单设备指南](../../docs/testing/2026-11-09-single-device.md)，JSON 语法和配置见 [example](../../im_flutter_sdk/example/README.md#script-mode-ai-friendly)。

## 首次准备

所有命令从业务仓库的 worktree 根目录执行，例如：

```bash
cd /Users/asterisk/Codes/zuoyu_flutter/im_flutter_sdk/.worktree/5.1.0
```

使用 Flutter 3.47.0 及其配套 Dart，宿主机需要 `python3` 生成报告；准备目标平台的 Android SDK 或 macOS / Xcode 及模拟器。首次工具链和依赖安装见 [CONTRIBUTING.md](../../CONTRIBUTING.md)。

先生成本地配置（已有文件不会覆盖）：

```bash
make config
```

填写 Git 忽略的 `im_flutter_sdk/example/config.local.json`：应用凭据、测试账号及所选场景需要的群组、聊天室等资源。然后获取 Token 并生成 example 使用的账号配置：

```bash
make env-gettoken
```

账号或应用配置变更、Token 过期后重新运行 `make env-gettoken`。这里的配置供 example 脚本使用，与 [CI 环境变量](../../tool/ci/README.md)不同。

## 执行一个或多个场景

以 5.1.0 为例，正向与逆向分别运行，每个命令独立生成报告：

```bash
make auto-report PLATFORM=android SCRIPT=testing/single/cases/script_510_apis_positive.json
make auto-report PLATFORM=android SCRIPT=testing/single/cases/script_510_apis_negative.json
```

选择 iOS 时将 `PLATFORM=android` 改为 `PLATFORM=ios`，不必每次把所有场景在两个平台重复执行。工具负责启动模拟器和执行应用；可通过 `DEVICE=<id>` 指定模拟器，例如 Android 的 `DEVICE=emulator-5554` 或 iOS 的 `DEVICE=<模拟器UDID>`。

`SCRIPT=<json>` 选择一个完整场景，不是筛选其中的某个步骤。需要运行多个场景时，分别指定对应脚本执行；已有 5.0.0 场景可将文件名替换为 `script_500_apis_positive.json` 或 `script_500_apis_negative.json`。每次执行的范围以所选 JSON 为准，不等同于整个版本的验收范围。

**不要省略 `SCRIPT` 来表示全部测试**：省略时只运行 5.0.0 正向场景。报告固定在 Git 忽略的 `reports/5.0.0/<run-id>/`，即使运行的是 5.1.0 脚本也使用这个目录。

## 查看报告和日志

每次执行自动生成正式报告，需宿主机有 `python3`（仅标准库，无需安装 Python 包）。终端打印报告完整路径，先打开 `upgrade-report.md`。每个 JSON 文件计一个场景，内部步骤单独统计；逆向步骤满足预期错误即通过。运行开始后的设备准备、构建或执行异常也保留报告，未运行步骤不会算作通过。

| 输出（均在本轮目录，Git 忽略） | 用途 |
|---|---|
| `upgrade-report.md` | 正式版本升级报告：单设备场景及步骤统计、结果、耗时、异常与原始证据链接；未选多设备明确标注未纳入 |
| `upgrade-report.json` | 与正式报告一致的结构化统计、输入批次、历史尝试 |
| `run.json` | 版本标签、脚本哈希、平台/设备、显式初始化选项、时间与执行异常；不保存账号凭据 |
| `steps.json`、`summary.md` | 原始逐步断言结果与执行摘要 |
| `events.jsonl`、`crash.log`、`issues.md` | API 事件、崩溃/超时证据与候选问题 |

单个脚本与多个脚本的每次执行都会产出报告。执行多个脚本后，用显式目录汇总，不自动扫描旧批次：

```bash
python3 testing/report_upgrade.py --version 5.1.0 \
  --single reports/5.0.0/<正向运行目录> \
  --single reports/5.0.0/<逆向运行目录> \
  --multi testing/multi/reports/<多设备运行目录> \
  --output reports/5.1.0/<本轮汇总目录>
```

`--single`、`--multi` 均可重复，仅传其中一类也有效。参数按旧到新排列；同场景、平台、设备及配置的最新一次计入场景结果，历史失败保留，尝试次数另计。`--version` 是目标标签，不替代实际 native 依赖证明。重新执行相同报告命令只重建报告，不运行测试；旧证据缺少的时间、配置显示“未记录”。统计口径见[报告说明](../../docs/testing/2026-11-09-reports.md)。

`make auto-compare ANDROID=<run-dir> IOS=<run-dir>` 仍用于比较相同脚本路径的双端结果。

工具本身的非设备自检可运行 `dart run testing/single/auto_report.dart --self-test`，它不能代替上述设备场景验证。

负向 5.0.0 脚本中的 missing-message 群回执场景因已知 Android native 崩溃停用，报告会保留 candidate；不能把它计作通过。
