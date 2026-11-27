# CI 测试操作说明

本目录运行持续回归测试。版本升级的场景测试分别见[单设备](../workbench/single/README.md)和[多设备](../workbench/multi/README.md)（用例目录 `workbench/multi/cases/`；编排工具为独立仓 im-test-orchestrator，经 `workbench/multi/multi.sh` 调用），分类规则见[测试指南](../docs/testing/README.md)。

## 运行前准备

所有命令在业务仓库的 worktree 根目录执行，例如：

```bash
cd /Users/asterisk/Codes/zuoyu_flutter/agora_chat_sdk/.worktree/5.1.0
```

使用 Flutter 3.47.0 及其配套 Dart，宿主机需要 `python3` 生成报告。Android 需要 Android SDK / adb；iOS 需要 macOS / Xcode。首次依赖与环境准备见 [CONTRIBUTING.md](../CONTRIBUTING.md)。

Android 设备入口固定使用已启动的 `emulator-5554`，运行前可用 `adb devices` 确认。iOS 入口会在没有已启动模拟器时启动一个可用的 iPhone 模拟器。以下设备命令任选一个平台执行，按验证范围决定是否补跑另一平台。

## 选择执行范围

| 入口 | 验证范围 | 是否需要账号 |
|---|---|---|
| `run_quality.sh` | 格式、静态分析、SDK 单元测试及映射/契约/版本检查 | 否，无需设备 |
| `smoke_local.sh` | 未登录设备冒烟测试 | 否 |
| `nightly_local.sh` | 单账号设备回归，按基础、群组、联系人、用户资料四类执行 | 是 |

### 质量检查

```bash
FORMAT_BASE_SHA=HEAD bash ci/run_quality.sh
```

`FORMAT_BASE_SHA` 只指定格式检查的 Git 比较基线：检查当前工作区相对该基线变更的已跟踪 Dart 文件；不会切换到那个 commit，也不会选择测试版本。设置为 `HEAD` 且工作区干净时，没有变更文件需要格式检查，其他检查和测试仍照常执行。未设置或基线无效时，脚本尝试使用 `HEAD^`。

测试始终使用当前工作区代码，包含未提交修改。若要测试某个 commit，请先检出对应代码或创建独立 worktree。Smoke 和 Nightly 不执行格式检查，无需传入 `FORMAT_BASE_SHA`。

### 无需登录的冒烟测试

```bash
bash ci/smoke_local.sh android
# 或使用 iOS：
bash ci/smoke_local.sh ios
```

### 登录后的回归测试

首次在当前终端设置以下五项，替换为真实测试环境的值：

```bash
export E2E_APP_KEY='实际 appKey'
export E2E_USER_ID='测试账号'
export E2E_REST_API='REST 服务地址'
export E2E_CLIENT_ID='实际 Client ID'
export E2E_CLIENT_SECRET='实际 Client Secret'

bash ci/nightly_local.sh android
# 或使用 iOS：
bash ci/nightly_local.sh ios
```

自动准备配置还需要 `curl`、`jq`。脚本获取新 Token、准备 peer 账号，生成临时配置并在退出时删除。CI 不会自动读取 workbench 的 `config.local.json`；`make env-gettoken` 用于 workbench 的人工/脚本模式，不能代替这里的配置。

如果已有有效的 CI dart-define JSON，可用 `E2E_CONFIG_PATH=/绝对路径/e2e-config.json` 执行 Nightly，脚本直接使用它并保留文件，不再自动刷新 Token。格式及凭据说明见 [CI 配置](../CONTRIBUTING.md)。

Nightly 通过现有设备 runner 冷启动四个固定登录入口，无需人工逐批操作：

| 入口 | 同步配置 | 用例归属 |
|---|---|---|
| `logged_in_base_test.dart` | 会话 | 认证、消息、会话、本地数据库等基础行为 |
| `logged_in_group_test.dart` | 会话＋已加入群组 | 群组相关 API 和群组列表同步 |
| `logged_in_contact_test.dart` | 会话＋联系人 | 联系人、好友关系和黑名单 |
| `logged_in_user_info_test.dart` | 会话；另开 `enableUserInfo` | 用户资料读写、查询和订阅 |

未登录入口固定为 `logged_out_test.dart`，由 Smoke 执行。基础配置显式开启会话同步，关闭群组、联系人同步和用户资料；其他登录入口只开启对应能力。所有初始化选项显式设置，“基础”不表示依赖 SDK 默认值。

入口表示登录前置与初始化配置，用例仍按业务放在 `modules/`。群消息收发不要求开启群组列表同步，消息测试准备好友关系也不改变其基础类归属。用例可以在验证过程中退出、重新登录。普通新增用例只补对应业务模块的现有注册函数，不修改五个稳定入口、不改变共享配置。若新增业务模块确需修改入口 import 或注册接线，也须先说明原因并取得确认，不能默认豁免。完整配置和编号归属见 [CI 说明](../agora_chat_sdk/docs/ci/flutter-only-ci.md)。

**特殊配置迁移待确认：** FL-CONV-011/012 需要 `autoLoadConversations=false`，FL-CONV-013 还包含 `enableChatroomConversation=true` 的执行项。它们无法直接合并到常规配置，迁移方案未确认前保留原有用例与断言，Nightly 暂时继续在最后执行原有 `conversation_config_test.dart` 三项（当前共五个登录批次）。不将五个稳定入口视为已包含这些特殊执行项，也不将临时保留视为已批准第六个稳定入口。

其中一批失败仍继续后续批次，最终返回失败并汇总各批结果。初始化参数改变后必须重启应用，不能在同一进程中改 options 代替重新初始化。

## 只运行一个用例或套件

用 `CI_TEST_NAME` 按测试名称正则筛选，例如无需登录的 `FL-APP-001`：

```bash
CI_TEST_NAME=FL-APP-001 bash ci/run_android_emulator_test.sh \
  integration_test/logged_out_test.dart

# iOS 对应入口：
CI_TEST_NAME=FL-APP-001 bash ci/run_ios_simulator_test.sh \
  integration_test/logged_out_test.dart
```

参数只有相对 workbench 的测试入口。不传 `CI_TEST_NAME` 则执行该入口的全部用例。

单个登录用例需额外提供完整有效的 `E2E_CONFIG_PATH`，包括 `FL-AUTH-007`；基础入口统一检查账号、peer 和 REST 配置。可以在上述五项环境变量设置后先生成配置，再调用设备 runner：

```bash
mkdir -p artifacts
bash ci/write_e2e_dart_defines.sh "$PWD/artifacts/e2e-config.json"

# 将 <用例ID> 替换成该入口中的实际用例编号。
E2E_CONFIG_PATH="$PWD/artifacts/e2e-config.json" CI_TEST_NAME='<用例ID>' \
  bash ci/run_android_emulator_test.sh \
  integration_test/logged_in_base_test.dart
```

群组、联系人和用户资料用例应将上述入口替换为对应的固定入口；不能用基础入口筛选其他入口内的用例。该配置含凭据，保存在 Git 忽略目录，不要分享；Token 过期后重新生成，用完可自行删除。

## 报告与日志在哪里

全部范围和单用例执行都会生成报告，终端打印本轮路径。产物统一放在 `artifacts/ci/<时间戳>/<平台>/` 下：一次任务一个纯时间戳目录，其下按平台分目录（单平台任务只有其中一个），平台目录内是报告与过程记录，每个套件一个子目录：

| 文件 | 用途 |
|---|---|
| `artifacts/ci/<时间戳>/<平台>/summary.md` | 首先打开：总数、通过、失败、跳过、未完成、未执行及证据链接 |
| 同目录 `report.json` | 机器可读的统计结果 |
| 同目录 `run.json` | 单批次平台、配置、筛选条件及执行信息 |
| 同目录 `runner.log` | 准备、构建及执行过程日志 |
| `<套件>/attempt-N.log` / `attempt-N.events.jsonl` | 各次尝试的原始输出与 Flutter 结构化事件 |
| `<套件>/attempt-N.logcat.log.gz` | Android 全量 native 日志（iOS 无等价通道，不生成） |

单独执行设备 runner（非 Nightly 调度）时，报告在 `artifacts/ci/<时间戳>/<平台>/<套件>/`；质量检查在 `artifacts/ci/<时间戳>/unit/<套件>/`。Nightly 的平台目录汇总本次实际调度的批次，各批次证据放在其子目录。运行产物均被 Git 忽略。

先看报告中的失败用例，再从链接进入原始证据；准备或构建失败不代表业务用例已执行。定向通过只代表选中的范围，历史已知问题仍以本次实际结果呈现。手动裸跑 `flutter test` 不会自动生成这里的正式报告。

报告重建、显式合并多批结果及统计口径见[自动测试报告](../docs/testing/2026-11-09-reports.md)。工具和 workbench 的其他非设备单测入口见[单设备说明](../workbench/single/README.md)与 [workbench README](../workbench/README.md)。
