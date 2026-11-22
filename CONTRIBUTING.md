# 贡献者指南

本文档面向 im_flutter_sdk 的开发与维护者，说明仓库结构、环境准备、验证方式与发布流程。SDK 使用者请阅读 [im_flutter_sdk/README.md](im_flutter_sdk/README.md)。

## 仓库结构

Federated Plugin 架构，各包的 pubspec 使用发布用的版本依赖，本地开发通过被 Git 忽略的 override 切换为 `path:` 依赖：

| 包 | 职责 |
|---|---|
| `im_flutter_sdk/` | 主包（发布包）：公开 API、Model、Manager，含 `example/` 测试应用；只声明 HarmonyOS 平台 |
| `im_flutter_sdk_ohos/` | HarmonyOS 平台实现（发布包）：ArkTS Wrapper，基于 `@easemob/chatsdk` 1.16.0 |
| `im_flutter_sdk_interface/` | 平台接口层：MethodChannel 抽象；pub.dev 已发布 4.25.0，**不发布新版本** |
| `im_flutter_sdk_android/` | Android 平台实现；pub.dev 已发布 4.25.0，**不发布新版本** |
| `im_flutter_sdk_ios/` | iOS 平台实现；pub.dev 已发布 4.25.0，**不发布新版本** |

调用链：`Dart API → MethodChannel (interface) → Native / ArkTS Wrapper → HyphenateChat / @easemob/chatsdk`。改动 interface 会波及所有上层包。依赖方向为 `im_flutter_sdk` → `im_flutter_sdk_ohos` → `im_flutter_sdk_interface`；`im_flutter_sdk_ohos` 通过 `implements: im_flutter_sdk` 声明平台实现，并在主包 `flutter.plugin.platforms.ohos.default_package` 中登记，使用方只需依赖主包。主包只声明 ohos 平台，`im_flutter_sdk_android` / `im_flutter_sdk_ios` 为 4.25.0 复用包，不参与鸿蒙线依赖。

## 环境准备

需要 Flutter（>= 3.3.0）。质量门禁与 `dart format` 使用官方 Flutter 3.47.0；Android/iOS 复用包如需构建，使用官方 Flutter + Xcode / Android Studio；鸿蒙开发另需 DevEco Studio、hdc/ohpm（随 DevEco 安装）和 fvm 管理的鸿蒙版 Flutter，见[下方 fvm 章节](#flutter-sdk-版本fvm鸿蒙)。

项目根目录提供了 Makefile，一键初始化：

```bash
make setup   # 依次执行 config + deps + pods
```

| target | 作用 |
|--------|------|
| `make config` | 创建本地环境文件：`im_flutter_sdk/example/config.local.json` + 占位 `example/lib/env.dart`（已存在则跳过），并保留旧的 `templates/config.example.json` → `scripts/config.json` 拷贝 |
| `make env-gettoken` | 读取 `example/config.local.json`，为每个账号换取 user token，生成被 gitignore 的 `example/lib/env.dart`（mode 600，默认 24h 过期） |
| `make local-deps` | 为主包、HarmonyOS 实现包、Android/iOS 实现包和 example 生成被 Git 忽略的本地依赖 override，保留已有文件 |
| `make deps` | 先执行 `make local-deps`，再在 example 目录执行 `flutter pub get` |
| `make pods` | 在 `example/ios` 执行 `pod install`（仅 Podfile/podspec 变更时执行，mtime 检测） |
| `make clean` | 清理 build 产物和 Pods |
| `make help` | 查看所有命令 |

新增 API 不改初始化方式时，日常验证只需 `make config` → 编辑 `config.local.json` → `make env-gettoken`；已有 `example/lib/env.dart`（例如本地已生成）时 `make config` 不会覆盖它。

> **重要**：修改 `im_flutter_sdk_ios.podspec` 中的 native 依赖版本（如 HyphenateChat）后，必须执行 `make pods`。`flutter run` 不会追踪 podspec 变更，会跳过 pod install，导致 iOS 使用旧版本 native SDK 引发编译错误。

### Flutter SDK 版本（fvm，鸿蒙）

质量门禁使用官方 Flutter 3.47.0；鸿蒙设备构建/测试使用 fork `3.41.9+ohos`（Android/iOS 复用包可按各自流程使用官方 Flutter）。两者用 fvm 管理，缓存在 `~/fvm/versions/`（本机版本名 `custom_official`、`custom_ohos`）。

```bash
# 只需在本 worktree 执行一次；custom_ohos 不是语义化版本，fvm 会打印可忽略的 WARN
cd im_flutter_sdk/.worktree/ohos
fvm use custom_ohos --force

# 之后用 fvm 跑任意命令（会读取 .fvmrc）
fvm flutter --version        # Flutter 3.41.9+ohos-1.0.2
fvm flutter pub get
fvm flutter test integration_test/logged_out_test.dart -d 127.0.0.1:5555
```

- `fvm use` 会在 worktree 根生成 `.fvmrc` 和 `.fvm/flutter_sdk` 软链；两者已在 `.gitignore` 中（指向本机路径，不可移植，不入库）。换机器或新同事需要各自执行一次 `fvm use custom_ohos --force`。
- IDE 把 Flutter SDK 指向 `im_flutter_sdk/.worktree/ohos/.fvm/flutter_sdk` 即可获得同样的项目级锁定。
- `tool/ci/ohos_local.sh`（及 `smoke_local.harmony.sh` / `nightly_local.harmony.sh`）默认优先使用 `.fvm/flutter_sdk/bin/flutter`，因此配好 `.fvmrc` 后直接 `bash tool/ci/ohos_local.sh` 即可，无需手动改 `PATH`；仍可用 `FLUTTER_BIN` 覆盖，例如 `FLUTTER_BIN="$(fvm which flutter)"`。
- 如果希望**普通的 `flutter` 命令**在该项目内也使用锁定 SDK（而不是只输入 `fvm flutter`），可以在 `~/.zshrc` 加一个项目级包装函数（可选、本机生效）：进入 git 工作树后向上查找 `.fvm/flutter_sdk/bin`，命中则直接执行其中的 `flutter`/`dart`，否则回退到 PATH 上的全局版本。**只搜索到 git 仓库根为止**，避免 `$HOME` 等父目录的 `.fvm` 配置泄漏到其他项目；`command flutter` / `\flutter` 可临时使用全局版本。

  ```zsh
  function _fvm_sdk_bin() {
    local dir="${PWD:A}"
    while [[ "$dir" != "/" ]]; do
      if [[ -x "$dir/.fvm/flutter_sdk/bin/flutter" ]]; then
        print -r -- "$dir/.fvm/flutter_sdk/bin"
        return 0
      fi
      if [[ -e "$dir/.git" ]]; then return 1; fi   # 项目锁定按仓库生效
      dir="${dir:h}"
    done
    return 1
  }
  function flutter() {
    local sdk_bin
    if sdk_bin="$(_fvm_sdk_bin)"; then "$sdk_bin/flutter" "$@"; else command flutter "$@"; fi
  }
  ```

  注意：shell 函数只对交互式终端生效，Makefile、CI 与脚本不会继承；脚本内请用显式路径或 `FLUTTER_BIN`（`tool/ci/ohos_local.sh` 已默认优先 `.fvm/flutter_sdk/bin/flutter`）。`dart` 命令不包装：fork 的 Dart 3.11 格式化结果与 CI 使用的官方 3.47 不一致，`dart format` 请用 PATH 上的官方 `dart`，否则会破坏 format 门禁。

- 若确实想把 fork 设为**机器全局默认**：`fvm global custom_ohos`，并把 `$HOME/fvm/default/bin` 放在 `PATH` 中。注意这会影响所有项目——5.1.0 等需要官方 3.47 的工作树应各自执行 `fvm use custom_official --force`；日常优先用项目级锁定，全局保持官方 3.47。
- 不要在 `$HOME` 等父目录执行 `fvm use`：它会留下 `~/.fvmrc`/`~/.fvm`，被 shell 包装函数或 fvm 当成"项目锁定"，污染所有子目录。已经有的话删除或改名即可（`.fvmrc`、`.fvm`）。
- 官方 Flutter 跑过 `pub get` 会重写 `example/.flutter-plugins-dependencies`（丢失 `plugins.ohos` 段），之后做鸿蒙设备测试前先执行一次 `fvm flutter pub get` 恢复。

### 本地依赖与发布

运行 `make local-deps`（或 `bash tool/use_local_packages.sh`），会在主包、HarmonyOS 实现包、Android/iOS 实现包和 example 的 pubspec 旁生成 `pubspec_overrides.yaml`。interface 没有其他子包依赖，无需 override。仓库 `.gitignore` 已在所有层级忽略这些文件，生成脚本纳入版本管理，已有 override 文件不会被覆盖。

override 只对当前解析的根包生效，不会从依赖包继承。因此，example 虽然已经通过 `path: ../` 依赖主包，仍需要自己的文件覆盖 interface 与 HarmonyOS 实现包。`make deps`、CI 质量检查、各平台构建和设备测试入口都会在依赖解析前生成本地文件。

发布配置为鸿蒙线 `1.16.0-ohos`：主包精确依赖 `im_flutter_sdk_ohos` `1.16.0-ohos` 与 interface `^4.25.0`；实现包依赖 interface `^4.25.0` 与 native `@easemob/chatsdk 1.16.0`。`im_flutter_sdk_interface`、`im_flutter_sdk_android`、`im_flutter_sdk_ios` 使用 pub.dev 已发布的 **4.25.0**，**不发布新版本**；2 个发布包版本号必须严格一致。本地 override 则统一使用当前工作树中的五个包。

发布验证应在没有 override 的检出目录执行，或先将 override 移出工作树，检查后再恢复。在主包与实现包内运行 `dart pub publish --dry-run`，期间不要调用本地开发初始化入口。有 override 时解析成功，不能证明正式版本依赖可解析。发布顺序：先把实现包 `im_flutter_sdk_ohos 1.16.0-ohos` 发布到 pub.dev，再打主包 Git tag `1.16.0-ohos`；主包不发布到 pub.dev（官方同名包已占据 latest，且预发布版本低于稳定版）；已发布的版本不能重复上传。

注意：用户即使按 Git tag 依赖主包，pub 仍会按版本号解析 `im_flutter_sdk_ohos` 与 interface；发布鸿蒙线版本前，需确认它们在 pub 可解析，否则用户 `pub get` 会失败。

## 测试数据准备

example 应用把测试环境集中在一个本地文件里（均不入库）：

1. `make config` — 生成 `im_flutter_sdk/example/config.local.json`（含 restApi、appKey、clientId、clientSecret、accounts、groups、rooms、chatOptions 占位）和占位 `example/lib/env.dart`；
2. 编辑 `config.local.json` 填真实 appKey 与账号（1.16.0 的 Dart API 与 Flutter 4.25.0 线对齐，没有 `dataSyncType`，`chatOptions` 使用 `debugMode` / `enableUserInfo` / `enableAutoSyncContacts` / `autoLoadConversations` / `enableChatroomConversation` 等开关）；
3. `make env-gettoken` — 用 clientId/clientSecret 换 app token，再为每个账号换 user token，生成 `example/lib/env.dart`（`chmod 600`，token 默认 24h 过期，过期后重新执行）。

`example/lib/env.dart` 是 `const Map<String, Object?> environment`，包含 appKey、每个账号的 id+token、群组/聊天室引用；人工模式页面会用它预填初始化参数和登录账号（第一个 account 的 id+token），脚本模式以其为 base config，`API_CONFIG` 可逐键覆盖。

旧机制 `im_flutter_sdk/example/scripts/config.json`（AutoMode 脚本用，同样 gitignore）仍兼容：`make config` 在缺少时继续从 `templates/config.example.json` 创建。

全新检出与 CI 不需要真实凭证：`tool/ci/ensure_example_env.sh` 在 `lib/env.dart` 缺失时复制空占位模板，`tool/use_local_packages.sh` 与 `tool/ci/ohos_local.sh` 都会调用它。

鸿蒙入口使用 `tool/ci` 下的专用脚本：**调用者永远不需要提供 token**（token 每次由脚本现场获取）。`tool/ci/smoke_local.harmony.sh` 零凭证即可运行（`logged_out` 套件使用公开演示 appKey，登录只做失败断言）；`tool/ci/nightly_local.harmony.sh` 接受 5 个长期凭证 `E2E_APP_KEY E2E_USER_ID E2E_REST_API E2E_CLIENT_ID E2E_CLIENT_SECRET`，未导出时回退 `example/config.local.json`，随后调用 `example/tool/env_tool.dart e2e-config` 现场换取六个 `E2E_*` dart-defines（临时文件 mode 600，退出即删）。`E2E_CONFIG_PATH` 仅作可选覆盖；直接跑 `tool/ci/ohos_local.sh` 时仍需 `E2E_CONFIG_PATH` 或六个变量。`ohos_local.sh` 可只跑指定套件（`logged_out` / `logged_in_base` / `logged_in_contact` / `logged_in_group` / `logged_in_user_info` / `logged_in_special`），也可用 `CI_TEST_NAME=<regexp>` 在套件内筛选单个用例；加载阶段失败（零用例完成）自动重试一次。报告与原始证据写入 `artifacts/ci/<时间戳>/harmony/`（report.py 的 summary.md / report.json / run.json，每套件 attempt-N.log / attempt-N.events.jsonl / attempt-N.hilog.log.gz，控制台输出在 harmony/runner.log）。本线没有 Android/iOS 的 `smoke_local.sh` / `nightly_local.sh`，对应能力由上述 harmony wrapper 提供。

## 运行与验证

example 是一个可视化 API 测试应用，支持两种模式：

- **人工模式**：初始化 → 登录 → 搜索 API → 填 JSON 参数调用，结果和监听器回调在悬浮日志中查看。
- **脚本模式**（适合 AI / 自动化）：通过 `--dart-define=API_SCRIPT=...` 传入 JSON 脚本顺序执行一批 API，日志以 `[APITEST]` 前缀单行 JSON 输出到 stdout 和日志文件。

详细用法见 [im_flutter_sdk/example/README.md](im_flutter_sdk/example/README.md)；覆盖 4.22 新增 API 的完整脚本示例见 `example/scripts/script_422_apis.json`。

### 鸿蒙设备验证

鸿蒙设备/模拟器上的验证统一走 `tool/ci` 下的入口（默认设备 `127.0.0.1:5555`，可用 `OHOS_DEVICE` 覆盖）：

```bash
# 零凭证冒烟（仅 logged_out 套件）
bash tool/ci/smoke_local.harmony.sh

# 全量套件：5 个长期凭证，或回退 example/config.local.json，token 由脚本现场换取
bash tool/ci/nightly_local.harmony.sh

# 指定套件：需要 6 个 E2E_* 变量或 E2E_CONFIG_PATH
bash tool/ci/ohos_local.sh logged_in_base
```

全新检出先执行 `tool/ci/ensure_example_env.sh` 生成占位 `example/lib/env.dart`；凭证口径与套件列表见[测试数据准备](#测试数据准备)。构建产物为 `build/ohos/hap/entry-default-unsigned.hap`，用 `hdc install` 安装。

## 编码规范

命名约定、双语注释规范、新增 API 的标准链路（Dart → 常量 → Android/iOS/HarmonyOS）与提交前自检清单，统一维护在 [AGENTS.md](AGENTS.md) 中，人类开发者同样适用，不再重复列举。

## 命名与兼容约定

- 4.22.0 起公开 API 统一为 `Chat` 前缀命名（与海外版 agora_chat_sdk 对齐）；
- 旧 `EM*` 名字通过 `im_flutter_sdk/lib/em_compat.dart` 中的 `@Deprecated` typedef 保留兼容，新代码不要再使用旧名；`em_compat.dart` 由脚本统一生成，不要手工添加条目；
- 少量无法 typedef 的名字（`ChatLog`、`ChatTools`、`ChatGroupPermissionTypeExtension` 等）没有旧名兼容，引用时注意。

## 生成 API 文档

主包公开 API 使用中英双语注释（`~english` / `~chinese` / `~end` 标记块，格式见 AGENTS.md「文档注释规范」）。修改注释或新增 API 后，应重新生成 API 文档检查渲染效果：

```bash
cd im_flutter_sdk
scripts/gen-apidoc.sh        # 中文版 → output/apidoc-cn/
scripts/gen-apidoc.sh en     # 英文版 → output/apidoc-en/
```

- 脚本在临时副本中剥离另一语言块与标记行后运行 `dart doc`，不修改源码；`im_flutter_sdk/output/` 已 gitignore，生成物不进仓库；
- 侧边导航由 JS 动态加载，必须通过 HTTP 访问，直接双击 `index.html`（file:// 协议）侧边栏会是空白。本地预览：

  ```bash
  cd im_flutter_sdk/output/apidoc-cn && python3 -m http.server 8765
  # 浏览器打开 http://localhost:8765/
  ```

- 部署时将 `output/apidoc-cn/im_flutter_sdk/` 目录内容作为站点根（类页面需挂在根路径下）；
- `dart doc` 会对注释中 `[xxx]` 形式的文本报 unresolved doc reference 警告，属既有写法问题，不影响生成。

## 版本号与 CHANGELOG

- 2 个发布包的版本号必须严格一致：`im_flutter_sdk` 与 `im_flutter_sdk_ohos`，当前 `1.16.0-ohos`；3 个复用包 `im_flutter_sdk_interface`、`im_flutter_sdk_android`、`im_flutter_sdk_ios` 保持 pub.dev 已发布的 **4.25.0**，**不发布新版本**。
- 鸿蒙线版本号跟随 HarmonyOS native chatsdk（`@easemob/chatsdk`）：native `1.16.0` 对应 Flutter `1.16.0-ohos`，采用 1.x 规则 + `-ohos` 预发布后缀，不再使用 4.x 版本号。
- 主包与实现包 CHANGELOG 当前保留 `1.16.0-ohos`、`1.15.0-ohos`、`1.5.4`、`1.5.3` 四个版本；格式为 `## 版本号` 标题 + `- 新增…` / `- 修复…` / `- 优化…` 条目；条目中的公开 API 名字一律使用新命名（`Chat*`），不要出现 `EM*` 旧名。
- 新增 API 时：主包与实现包 CHANGELOG 记录对应条目；interface / android / ios 为复用包，不随鸿蒙线改动。

## 分支与发布流程

- 本仓库的 `ohos` 分支（当前 worktree）是鸿蒙线，发布使用与版本号同名的 Git tag（当前 `1.16.0-ohos`），用户按 tag 依赖主包；4.x/5.x 主线「每个版本一个同名分支、不使用 tag」的规则不适用于本线。
- 默认分支为 `flutter2_stable`；`ohos` 为鸿蒙线开发分支；`alpha`、`dev` 等为特性或历史分支，不在其上做版本开发。
- 版本开发流程：
  1. 确认当前工作区干净后，在 `ohos` 分支完成开发与验证（鸿蒙设备 smoke/nightly + example 脚本验证）；
  2. 2 个发布包版本号统一改为目标版本（如 `1.16.0-ohos`），更新主包与实现包 CHANGELOG；3 个复用包版本保持 pub.dev 已发布的 4.25.0 不变；
  3. 验证通过后先发布实现包到 pub.dev，再打同名 Git tag（如 `1.16.0-ohos`）并推送；
  4. 需要合入主线时按团队流程合并回 `flutter2_stable`。
- 版本升级（对齐 native SDK 新版本的公开 API）有专门的工作流与验收报告模板，见团队工作区的 `platform-sdk-porting-v2` skill 及历次升级报告。
