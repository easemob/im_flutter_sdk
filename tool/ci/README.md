# CI 测试操作说明（HarmonyOS）

本目录运行鸿蒙线的持续回归测试。版本升级的场景测试见单设备（`testing/single/auto_report.dart --platform ohos`）与多设备（`testing/multi/cases/`，经 `scripts/multi.sh` 调用，编排工具为独立仓 im-test-orchestrator），入口速查见 [AGENTS.md](../../AGENTS.md) 的「鸿蒙构建与验证入口」表。

## 运行前准备

所有命令在业务仓库的 worktree 根目录执行，例如：

```bash
cd /Users/asterisk/Codes/zuoyu_flutter/im_flutter_sdk/.worktree/ohos-1.16.0
```

鸿蒙构建/测试使用 fvm 的 `custom_ohos`（Flutter 3.41.9+ohos-1.0.2，Dart 3.11.5），worktree 已通过 `.fvmrc` 锁定；鸿蒙命令统一走 `fvm flutter ...`，本目录的 harmony 脚本默认优先使用 `.fvm/flutter_sdk/bin/flutter`，可用 `FLUTTER_BIN` 覆盖。**不要对鸿蒙线使用官方 Flutter 执行 `pub get`**——它会重写 `example/.flutter-plugins-dependencies`（丢失 `plugins.ohos`）导致 hvigor 构建失败；跑完质量门禁或 Android/iOS 命令后，鸿蒙构建前必须先 `fvm flutter pub get`。

设备用 hdc 管理，默认目标 `127.0.0.1:5555`（模拟器漂移后用 `OHOS_DEVICE` 覆盖），运行前 `hdc list targets` 确认在线。本地模拟器使用无签名 hap，脚本默认 `OHOS_SKIP_CODESIGN=1`；项目已有真实签名配置时设为 `0`。

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

鸿蒙 runner 暂不支持按用例名筛选（`CI_TEST_NAME` 仅 Android/iOS runner 可用）；最小执行粒度为套件。

## 报告与日志在哪里

每次执行生成带时间戳的目录，遵循与其他线一致的三类产物规范：集成套件产物在 `artifacts/ci/<时间戳>/harmony/<套件>/flutter.log`（设备侧完整输出），控制台过程日志在同目录 `artifacts/ci/<时间戳>/harmony/runner.log`。

先看 runner 输出确认构建与安装成功，再进各套件 flutter.log 定位失败用例；准备或构建失败不代表业务用例已执行。运行产物均被 Git 忽略。

测试遗留的 `flutter_ci_group_*` 孤儿群可用 `bash tool/ci/ohos_cleanup.sh` 经 REST 清理（需要 `E2E_APP_TOKEN`）。
