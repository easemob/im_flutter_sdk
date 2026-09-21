# 贡献者指南

本文档面向 im_flutter_sdk 的开发与维护者，说明仓库结构、环境准备、验证方式与发布流程。SDK 使用者请阅读 [im_flutter_sdk/README.md](im_flutter_sdk/README.md)。

## 仓库结构

Federated Plugin 架构，四个包通过本地 `path:` 依赖关联：

| 包 | 职责 |
|---|---|
| `im_flutter_sdk/` | 主包：公开 API、Model、Manager，含 `example/` 测试应用 |
| `im_flutter_sdk_interface/` | 平台接口层：MethodChannel 抽象 |
| `im_flutter_sdk_android/` | Android 平台实现 |
| `im_flutter_sdk_ios/` | iOS 平台实现 |

调用链：`Dart API → MethodChannel (interface) → Native Wrapper → HyphenateChat SDK`。改动 interface 会波及所有上层包。

四个包之外，仓库根目录还有：`Makefile`（本地开发入口）、`tool/ci/`（质量门禁与设备测试脚本）、`tool/auto_report.dart`（auto 模式运行器）、`docs/porting/<版本>/`（各版本升级的差异、契约、实现与验收文档）、`reports/`（本地 auto 运行产物，已 gitignore）。

## 环境准备

需要 Flutter、Xcode + CocoaPods（iOS）、Android Studio（Android）。

> **Flutter 版本**：开发本仓库统一使用 **Flutter 3.47.0**（与 CI 的 `.github/workflows/ci.yml` 中 `FLUTTER_VERSION` 一致）。dev 依赖 `flutter_lints 6` 要求 Dart >= 3.8（Flutter >= 3.32），低于该版本无法解析本仓库的开发依赖；各包 `environment` 中声明的 Flutter >= 3.3.0 是给 SDK 使用者的支持下限，两者不要混淆。

项目根目录的 `Makefile` 是本地开发入口，首次介入执行 `make setup` 即可；`make help` 列出全部 target：

| target | 作用 |
|--------|------|
| `make setup` | 依次执行 `config` + `deps` + `pods` |
| `make config` | 生成 `example/config.local.json`（来自 `example/templates/config.local.example.json`）与占位 `example/lib/env.dart`（来自 `example/templates/env.example.dart`），已存在则跳过 |
| `make env-gettoken` | 按 `config.local.json` 在宿主机换取各账号 user token，并直接生成 `example/lib/env.dart`；必填字段缺失或仍是 `TODO` 时退出码非 0 |
| `make deps` | 在 example 目录执行 `flutter pub get`，解析 4 个子包的 path 依赖 |
| `make pods` | 先 `deps`，再按 mtime 判断 Podfile/podspec 是否比 Podfile.lock 新，需要时才在 `example/ios` 执行 `pod install` |
| `make auto-report PLATFORM=<android\|ios> [DEVICE=<id>] [SCRIPT=<json>]` | 跑 5.0.0 auto 脚本，并把可追溯报告写到 `reports/5.0.0/<run-id>/`（Android 会先确保 debug 包已安装，再以 App uid 把脚本写入 App 内部目录） |
| `make auto-compare ANDROID=<run-dir> IOS=<run-dir>` | 对比同一条路径的 Android/iOS 两次运行，步骤不一致时退出码非 0 |
| `make clean` | 清理 example 的 build 产物与 iOS Pods、Podfile.lock |
| `make help` | 查看所有命令 |

> **重要**：修改 `im_flutter_sdk_ios.podspec` 中的 native 依赖版本（如 HyphenateChat）后，必须执行 `make pods`。`flutter run` 不会追踪 podspec 变更，会跳过 pod install，导致 iOS 使用旧版本 native SDK 引发编译错误。

## 测试数据准备

example 的运行数据分两步准备，产物都是本地文件、都不入库：

1. **凭据与测试数据**：`make config` 生成 `im_flutter_sdk/example/config.local.json`，按 `example/templates/config.local.example.json` 里的 `TODO` 占位符填写 `restApi`、`appKey`、`clientId` / `clientSecret`，以及测试账号 `accounts`、群组 `groups`、聊天室 `rooms`。
   - 项目只配置**一个环境**：这份文件描述的就是当前要跑的那个环境。要切换环境就直接改这份文件的值，或在 Git 外自己保存多份副本（如 `config.ngi.json` / `config.ebs.json`）替换过来，工具不做多环境选择。
   - 私有化部署不是另一种模式：把顶层 `enablePrivateConfig` 设为 `true` 并填 `webSocketServer` / `restServer` / `msyncServer`，生成的 `env.dart` 会带上这些 server 字段并强制 `enableDNSConfig=false`。
2. **环境与 token**：`make env-gettoken` 在宿主机用 app token 换取每个账号的 user token，直接写入 `example/lib/env.dart`。app token 与 `clientSecret` 不会写入 env 文件。

`example/config.local.json`、`example/lib/env.dart` 均已 gitignore（见 `im_flutter_sdk/.gitignore` 末尾两条），不要提交。

## 运行与验证

example 是一个可视化 API 测试应用，支持两种模式：

- **人工模式**：初始化 → 登录 → 搜索 API → 填 JSON 参数调用，结果和监听器回调在悬浮日志中查看。
- **脚本模式**（适合 AI / 自动化）：通过 `--dart-define=API_SCRIPT=...` 传入 JSON 脚本顺序执行一批 API，每个事件以 `[APITEST]` 前缀单行 JSON 输出到 stdout 和日志文件。

页面流程、脚本字段（`steps`、`expect`、`$config.*` / `$prev` / `$step.<id>.*` 引用、`timeoutMs`）、日志通道与 Android 路径注意事项见 [im_flutter_sdk/example/README.md](im_flutter_sdk/example/README.md)。手动运行：

```bash
cd im_flutter_sdk/example
flutter run -d <device>                                   # 人工模式
flutter run -d <device> --dart-define=API_SCRIPT=<脚本路径>  # 脚本模式
```

5.0.0 的登录态脚本按正/反两条路径拆分（均为单账号）：

- `example/scripts/script_500_apis_positive.json`：正常路径，20 步全部期望成功，含混入不可解析 message id 的批量接口；
- `example/scripts/script_500_apis_negative.json`：错误路径，10 步全部期望指定错误码；其中 `fetchGroupMessageReadReceipts` 传入缺失 message 会让 Android 原生进程崩溃，因此该步不执行，运行器固定记录一条 `fetch-group-receipt-missing-disabled` 候选。

需要留存证据时用仓库根的运行器（比手敲 `flutter run` 更可复现，自动拉起/激活模拟器、把脚本推进 Android 应用私有目录）：

```bash
make auto-report PLATFORM=android DEVICE=emulator-5554
make auto-report PLATFORM=ios DEVICE=<已启动模拟器的 udid>
make auto-report PLATFORM=android SCRIPT=im_flutter_sdk/example/scripts/script_500_apis_negative.json
make auto-compare ANDROID=reports/5.0.0/<android-run> IOS=reports/5.0.0/<ios-run>
```

每次运行在 `reports/5.0.0/<run-id>/` 写入 `run.json`、`events.jsonl`、`crash.log`、`steps.json`、`summary.md`、`issues.md`；对比则在 `reports/5.0.0/` 写入 `comparison-<路径>-<时间戳>.md`。报告可能含账号与资源标识，因此整个 `reports/` 已 gitignore，只有确认并脱敏后的结论才写进 `docs/porting/`。

### 质量门禁

`tool/ci/run_quality.sh` 就是 CI 的 quality job，本地与 CI 走同一套门禁。它先调用 `tool/ci/ensure_example_env.sh`：`im_flutter_sdk/example/lib/env.dart` 不存在时用 `example/templates/env.example.dart` 生成空占位，已存在则原样保留。该文件已 gitignore，全新检出没有它时 example 根本编译不过，`flutter analyze` 会直接报 `Target of URI doesn't exist: '../env.dart'`；脚本只补这一个文件，**不生成 `example/config.local.json`**——那份文件里的凭据属于使用者自己的环境配置，只由本地 `make env-gettoken` 读取，CI 不替谁造一份。随后按顺序执行：

1. 5 个包依次 `flutter pub get`；
2. `dart format --set-exit-if-changed`：只检查变更的 `.dart` 文件，基准由 `FORMAT_BASE_SHA` 指定（CI 传 PR base / push 前的 sha），本地未设置时回退到 `HEAD^`；
3. 5 个包依次 `flutter analyze --fatal-infos`：`info` 级问题同样算失败；
4. 在 `im_flutter_sdk` 下执行 `flutter test --coverage`；
5. 三个一致性脚本：`tool/ci/check_case_mapping.dart`（native ↔ Flutter 命名映射）、`tool/ci/check_contracts.dart`（MethodChannel 方法名常量与三端路由分支）、`tool/ci/check_versions.dart`（4 个包的 pubspec 版本、iOS podspec 版本，以及 Android `build.gradle` 与 iOS podspec 里声明的 native SDK 版本）。

> 注意：第 4 步只跑 `im_flutter_sdk/test/`，`im_flutter_sdk/example/test/` 不在门禁范围内——改动 example 后请单独执行 `cd im_flutter_sdk/example && flutter test`。

### 废弃 API 扫描

wrapper 代码调用 native 的废弃 API 时，javac / clang 会在编译期给出带文件行号的警告。扫描脚本把两端 wrapper 各重新编译一遍、保留完整构建日志，再从中提取调用点，产出可执行的待办清单：

```bash
make scan-deprecated                # 两端都扫
make scan-deprecated PLATFORM=ios   # 只扫 iOS
```

- 必须**全新编译**：增量构建不会重发未变更文件的警告，所以脚本对每个平台先 `clean`；解析器若发现日志里是复用编译（`UP-TO-DATE` / `FROM-CACHE`），会直接判定扫描失败，而不是报"0 条"。
- 只扫 wrapper 源码（`im_flutter_sdk_android/android/src/main/java`、`im_flutter_sdk_ios/ios`），example 与 Pods / pub cache 里的第三方告警不进报告。
- Android 侧需要 `-Xlint:deprecation`（AGP 默认不开，只打 `Note: ...`、没有文件行号），由 `tool/ci/enable_deprecation_lint.gradle` 以 `-I` 注入，**不改插件自身的 build.gradle**，对使用者的构建没有影响。
- 产物在 `reports/deprecated/`（已 gitignore）：`{android,ios}-raw.log` 原始构建日志、`{android,ios}-deprecated-api.json`、`native-deprecated-api.md` 汇总报告。
- 只报告不拦截：发现废弃调用不会让命令失败，构建失败或日志不可信才失败。解析契约与 CI 复用方案见 [docs/spec/2026-09-21-deprecated-api-scan-spec.md](docs/spec/2026-09-21-deprecated-api-scan-spec.md)。

### 设备集成测试

CI 上的设备任务都有等价的本地脚本，脚本会先比对本地 Flutter 版本与 CI 钉住的 3.47.0（不一致只告警）：

| 工作流 | 触发 | 内容 | 本地等价命令 |
|--------|------|------|--------------|
| `.github/workflows/ci.yml` | PR、push 到 `flutter2_stable` / `4.*` / `5.*`、手工 | 质量门禁 + Android debug 编译 + iOS 模拟器编译 | `bash tool/ci/run_quality.sh` |
| `.github/workflows/device-smoke.yml` | 每天定时 + 手工 | Android / iOS 免登录 Presence 冒烟（`integration_test/no_login_presence_test.dart`，用测试内置的公开 demo appKey，无需凭据） | `bash tool/ci/smoke_local.sh android\|ios` |
| `.github/workflows/single-account-nightly.yml` | 每天定时 + 手工 | Android / iOS 单账号登录 + 本地数据库（`integration_test/single_account_local_test.dart`），需要 `E2E_APP_KEY`、`E2E_USER_ID`、`E2E_REST_API`、`E2E_CLIENT_ID`、`E2E_CLIENT_SECRET`；user token 每次运行由 `tool/ci/fetch_e2e_user_token.sh` 现换（5.0.0 已无密码登录，token 约 24h 过期，不能存 secret） | `E2E_APP_KEY=... E2E_USER_ID=... E2E_REST_API=... E2E_CLIENT_ID=... E2E_CLIENT_SECRET=... bash tool/ci/nightly_local.sh android\|ios` |

> `single-account-nightly.yml` 里的 cron（`37 18 * * *`，比 RN 的 nightly 早一小时）只在**默认分支**（`flutter2_stable`）上生效——GitHub 的定时任务是"跑默认分支最新提交、用默认分支的工作流文件"，所以在该文件落地默认分支之前，5.0.0 分支上的定时触发不会发生，只能手工 dispatch。

Android 侧需要已启动的模拟器（脚本固定连 `emulator-5554`）；iOS 侧由 `run_ios_simulator_test.sh` 自行拉起模拟器，日志写到 `artifacts/*.log`（已 gitignore）。

`ci.yml` 的两个 example 编译 job 与两个 `run_*_test.sh` 都会先调用 `tool/ci/ensure_example_env.sh` 生成 `example/lib/env.dart` 占位（只补这一个文件，不碰 `config.local.json`），所以在全新检出（或 CI）上可以直接跑，不需要先 `make config`；本地已生成的真实环境不会被覆盖，跑哪个环境仍由本地 `config.local.json` + `make env-gettoken` 决定。

两个 `run_*_test.sh` 会在运行前清除设备上该 App 的数据（`adb uninstall` / `xcrun simctl uninstall`，App 不存在时忽略）。原因：`flutter test` 对已安装 App 是覆盖安装、且只在运行结束后卸载，本地设备上残留的登录态会让依赖冷启动的用例（如 `FL-APP-001`）失败；CI 每次都是全新设备，不受影响。

## 编码规范

命名约定、双语注释规范、新增 API 的标准链路（Dart → 常量 → Android → iOS）与提交前自检清单，统一维护在 [AGENTS.md](AGENTS.md) 中，人类开发者同样适用，不再重复列举。

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

- 四个子包的版本号保持一致，禁止只改其中一个。
- CHANGELOG 使用中文，格式为 `## 版本号` 标题 + `- 新增…` / `- 修复…` / `- 优化…` 条目；条目中的公开 API 名字一律使用新命名（`Chat*`），不要出现 `EM*` 旧名。
- 新增 API 时：主包 CHANGELOG 记录新 API 条目；interface / android / ios 的 CHANGELOG 按各自实际改动记录。

## 分支与发布流程

- **4.x 起每个发布版本对应一个同名分支**（如 `4.22.0`），不使用 tag；3.x 遗留 tag 仅属历史。
- 默认分支为 `flutter2_stable`；`alpha`、`dev` 等为特性或历史分支，不在其上做版本开发。
- 版本开发流程：
  1. 确认当前工作区干净后，从 `flutter2_stable` 新建与目标版本同名的分支；
  2. 在该分支上完成开发与验证：`bash tool/ci/run_quality.sh` 过质量门禁，Android/iOS 双端编译运行 example，并用 `script_500_apis_positive.json` / `script_500_apis_negative.json`（或 `make auto-report`）跑通后留存报告；
  3. 验证测试通过后，合并回 `flutter2_stable`。
- 版本升级（对齐 native SDK 新版本的公开 API）有专门的工作流与验收报告模板，见团队工作区的 `platform-sdk-porting-v2` skill 及历次升级报告。
