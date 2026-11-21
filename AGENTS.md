# AGENTS.md

环信 IM Flutter SDK，采用 Federated Plugin 架构。本文档面向 AI Agent，说明项目结构、跨层链路与硬性约定；具体代码细节以仓库实际代码为准。

文档分工：本文档是 AI 的唯一必读文档。环境搭建、数据准备、验证流程等过程性内容见 `CONTRIBUTING.md`（仅当任务涉及时按需阅读）；`im_flutter_sdk/README.md` 面向 SDK 使用者，AI 无需阅读。

## 协作约定

- 排查方向不确定、或同一问题卡住超过几分钟时，先把现象和自己的假设同步给用户，再决定排查方向，不闷头钻到底——用户可能掌握 AI 不知道的背景（环境、历史决策、服务端状态）。

### 工作日志

- 每完成一个任务，或做出重要决策、收到用户纠正时，追加到 `dailylog/YYYY-MM-DD.md`（本地日期），文件不存在则创建。
- 只追加，不修改已有内容。每条格式：`- HH:MM <做了什么/决定了什么>，原因：<…>`。
- 日志可以记录进度和过程。
- `dailylog/` 下的工作日志纳入 Git 版本管理，不加入 `.gitignore`；在执行用户授权的 Git 提交时，将本次日志变更一并提交。记录日志本身不自动触发 commit 或 push。

## 项目架构

| 包 | 职责 |
|---|---|
| `im_flutter_sdk/` | 主包（发布包）：公开 API、Model、Manager；鸿蒙线只声明 HarmonyOS 平台 |
| `im_flutter_sdk_ohos/` | HarmonyOS 平台实现（发布包）：ArkTS Wrapper，基于 `@easemob/chatsdk` 1.15.0 |
| `im_flutter_sdk_interface/` | 平台接口层：MethodChannel 抽象；pub.dev 已发布 4.25.0，**不发布新版本** |
| `im_flutter_sdk_android/` | Android 平台实现；pub.dev 已发布 4.25.0，**不发布新版本** |
| `im_flutter_sdk_ios/` | iOS 平台实现；pub.dev 已发布 4.25.0，**不发布新版本** |

调用链：`Dart API → MethodChannel (interface) → Native / ArkTS Wrapper → HyphenateChat / @easemob/chatsdk`

依赖方向：`im_flutter_sdk` → `im_flutter_sdk_ohos` → `im_flutter_sdk_interface`。interface 是各平台包共享的契约，改动它会波及所有上层包。`im_flutter_sdk_ohos` 的 `pubspec.yaml` 通过 `implements: im_flutter_sdk` 声明平台实现，主包 `flutter.plugin.platforms.ohos.default_package` 指向它，因此使用方只需依赖主包；主包的 `flutter.plugin.platforms` 只声明 `ohos`，Android/iOS 使用 pub.dev 官方发布线。各包的 pubspec 保持发布用的版本依赖；本地开发运行 `make local-deps` 生成被 Git 忽略的 `pubspec_overrides.yaml`，`make deps` 和 CI 会自动执行。override 仅对当前解析的根包生效，example 也需要自己的文件，不会继承依赖包的 override。发布验证方式见 `CONTRIBUTING.md`。

## ohos 分支与鸿蒙线版本规则

- 本仓库的 `ohos` 分支（本 worktree）是环信 IM Flutter SDK 的鸿蒙线：主包 `im_flutter_sdk` 只声明 HarmonyOS 平台，HarmonyOS 实现由 `im_flutter_sdk_ohos` 提供；仓库共 5 个包，其中 2 个发布包、3 个复用包。
- 2 个发布包：主包 `im_flutter_sdk`（文件夹 `im_flutter_sdk/`，按 Git tag 分发）与实现包 `im_flutter_sdk_ohos`（文件夹 `im_flutter_sdk_ohos/`，发布到 pub.dev）；两者版本号必须严格一致，当前 `1.15.0-ohos`。
- 3 个复用包：`im_flutter_sdk_interface`、`im_flutter_sdk_android`、`im_flutter_sdk_ios` 使用 pub.dev 已发布的 **4.25.0**，**不发布新版本**，不参与发布包版本一致性检查；发布包依赖 interface `^4.25.0`。
- 版本号采用 semver 预发布形式 `1.15.0-ohos` 标识鸿蒙线（低于稳定版 `1.15.0`，不会与官方线混淆）；不能写 `ohos-1.15.0`（pub 要求以 `X.Y.Z` 开头）。
- 版本号跟随 HarmonyOS native chatsdk（`@easemob/chatsdk`）：native 1.15.0 对应 Flutter `1.15.0-ohos`；采用 1.x 规则，不再使用 4.x 版本号。
- 发布顺序：先发布实现包 `im_flutter_sdk_ohos 1.15.0-ohos` 到 pub.dev，再打主包 Git tag `1.15.0-ohos`；主包不进 pub.dev（官方同名包已占据 latest，且预发布版本更低）。
- Android/iOS 使用 pub.dev 官方发布线（4.25.0 / 5.0.0），不随本仓库鸿蒙线发布。
- Dart API 与 Flutter 4.25.0 线对齐：`ChatClient` + 8 个 Manager（会话、消息、群组、聊天室、联系人、用户属性、推送、在线状态）。

## 开发环境初始化

项目根目录有 `Makefile`，提供一键初始化：

```bash
make setup   # config + deps + pods
```

| target | 作用 |
|--------|------|
| `make config` | 创建 `example/config.local.json` 与占位 `example/lib/env.dart`（均 gitignore，已存在则跳过），并兼容旧的 `templates/config.example.json` → `scripts/config.json` 拷贝 |
| `make env-gettoken` | 读取 `example/config.local.json`，换取 user token，生成 `example/lib/env.dart`（mode 600，默认 24h 过期） |
| `make local-deps` | 为主包、HarmonyOS 实现包、Android/iOS 实现包和 example 生成本地依赖 override，保留已有文件 |
| `make deps` | 生成本地 override，再在 example 目录执行 `flutter pub get` |
| `make pods` | `pod install`（仅 Podfile/podspec 变更时执行，通过 mtime 检测） |
| `make clean` | 清理 build 产物和 Pods |

修改 podspec 中 native 依赖版本后必须执行 `make pods`，否则 iOS 侧会使用旧版本 native SDK 导致编译错误。这是 Flutter 的已知问题：`flutter run` 的 Fingerprinter 不追踪 podspec 文件，会跳过 `pod install`。

`make setup` 与 `make deps` 使用 PATH 上的 Flutter（官方 3.47.0）；鸿蒙设备构建需使用 fvm `custom_ohos`，见下节。

## 鸿蒙开发环境

- **SDK 分工**：鸿蒙设备构建/测试使用 fvm 的 `custom_ohos`（Flutter 3.41.9+ohos-1.0.2，Dart 3.11.5）；Android/iOS 构建、质量门禁与 `dart format` 使用官方 Flutter 3.47.0。不要用 fork 的 Dart 格式化，结果与 CI 不一致。
- **项目级锁定**：worktree 根 `.fvmrc` 与 `.fvm/flutter_sdk` 指向本机 `custom_ohos`，只在当前仓库生效且已 gitignore；换机器后执行一次 `fvm use custom_ohos --force`。IDE 的 Flutter SDK 指向 `<repo>/.fvm/flutter_sdk`。
- **命令入口**：鸿蒙相关命令统一用 `fvm flutter ...`；`tool/ci/ohos_local.sh`、`smoke_local.harmony.sh`、`nightly_local.harmony.sh` 默认优先 `.fvm/flutter_sdk/bin/flutter`，可用 `FLUTTER_BIN` 覆盖。
- **与官方 Flutter 的冲突**：官方 Flutter 执行 `pub get` 会重写 `example/.flutter-plugins-dependencies`（丢失 `plugins.ohos`），导致鸿蒙 hvigor 构建失败；跑完质量门禁或 Android/iOS 测试后，鸿蒙构建前必须先 `fvm flutter pub get`。
- **OHOS_SKIP_CODESIGN**：本地模拟器使用无签名 hap 时设 `OHOS_SKIP_CODESIGN=1`（鸿蒙脚本默认值）；项目已有真实签名配置时设为 `0`。
- **fork flutter_tools 补丁（仅本机，不在仓库）**：`~/fvm/versions/custom_ohos/packages/flutter_tools/lib/src/ohos/ohos_device.dart` 的 `shouldCodesign` 需读取 `OHOS_SKIP_CODESIGN`，`lib/src/project.dart` 的 `OhosProject.getSignedHapFile` 需使用同一开关。改完源码删除 `bin/cache/flutter_tools.snapshot` 与对应 `.stamp`，再执行 `./bin/flutter --version` 重建快照。
- **模拟器/真机**：DevEco Studio 模拟器已验证 OpenHarmony 5.0.2.125 / API 14（`127.0.0.1:5555`）；真机需在 DevEco 配置签名。`hdc list targets` 确认在线，必要时 `hdc tconn 127.0.0.1:5555`。
- **常用 hdc 命令**：

  ```bash
  hdc list targets
  hdc install im_flutter_sdk/example/build/ohos/hap/entry-default-unsigned.hap
  hdc uninstall com.example.example
  hdc shell aa start -a EntryAbility -b com.example.example
  hdc shell hilog | grep -iE 'im_flutter|easemob'
  ```

## 鸿蒙构建与验证入口

构建 example（在 `im_flutter_sdk/example` 下，使用鸿蒙版 Flutter）：

```bash
fvm flutter pub get
fvm flutter build hap --debug --no-codesign
# 产物：build/ohos/hap/entry-default-unsigned.hap
hdc install build/ohos/hap/entry-default-unsigned.hap
```

| 入口 | 用途 | 凭证 |
|---|---|---|
| `tool/ci/ohos_local.sh [suite...]` | 鸿蒙集成套件：`logged_out` / `logged_in_base` / `logged_in_contact` / `logged_in_group` / `logged_in_user_info` / `logged_in_special`；日志写入 `artifacts/ohos-<suite>.log` | 6 个 `E2E_*` 变量（`E2E_APP_KEY`、`E2E_USER_ID`、`E2E_USER_TOKEN`、`E2E_PEER_ID`、`E2E_REST_API`、`E2E_APP_TOKEN`）或 `E2E_CONFIG_PATH` |
| `testing/single/auto_report.dart --platform ohos`（或 `make auto-report`） | 单设备 auto 脚本（`script_1.16.0_apis_positive/negative.json`），hilog 采集 + 结构化报告 | `FLUTTER_BIN`（fvm custom_ohos）、`OHOS_DEVICE`；登录账号取 `example/lib/env.dart`（`make env-gettoken` 生成） |
| `scripts/multi.sh ...` | 多设备场景（`testing/multi/cases/1.16.0-multi-*`，12 场景其中 2 个 device-sync 永久 skip），编排工具为独立仓 im-test-orchestrator（需 ohos 平台支持） | 依赖 IMTO 的账号/设备配置；入口见 `testing/README.md` |
| `tool/ci/smoke_local.harmony.sh` | 零凭证冒烟，仅跑 `logged_out` 套件 | 不需要 |
| `tool/ci/nightly_local.harmony.sh [suite...]` | 全量鸿蒙套件；token 由脚本现场换取 | 5 个长期凭证，或回退 `example/config.local.json` |
| `tool/ci/ensure_example_env.sh` | 全新检出时生成占位 `example/lib/env.dart` | 不需要 |
| `tool/ci/ohos_cleanup.sh` | 清理测试遗留的 `flutter_ci_group_*` 孤儿群（REST） | `E2E_APP_TOKEN` |

- nightly 的 5 个长期凭证：`E2E_APP_KEY`、`E2E_USER_ID`、`E2E_REST_API`、`E2E_CLIENT_ID`、`E2E_CLIENT_SECRET`；脚本调用 `example/tool/env_tool.dart e2e-config` 换取 app token + user token，写入 mode 600 的临时文件并在退出时删除。
- 数据准备：`make config` 生成 `example/config.local.json`，填写后 `make env-gettoken` 生成 `example/lib/env.dart`（token 默认 24h 过期）。
- 设备默认 `127.0.0.1:5555`，用 `OHOS_DEVICE` 覆盖；`OHOS_SKIP_CODESIGN` 默认 `1`。
- 当前 CI（`.github/workflows/`）只有 Android/iOS 任务，没有 ohos job；鸿蒙验证走上述本机/设备入口。

## 命名约定

- Dart 文件统一 snake_case；Manager 文件为业务名 + `_manager`：`chat_manager.dart`
- 公开 Dart 类统一 `Chat` 前缀：`ChatClient`、`ChatMessage`、`ChatError`（与海外版 agora_chat_sdk 命名一致）
- Manager 类：`Chat{业务}Manager`，如 `ChatGroupManager`；事件处理器：`Chat{业务}EventHandler`
- 原生类统一 `*Wrapper` 后缀：`ChatManagerWrapper.java` / `ChatManagerWrapper.m`；iOS 数据转换类用 `*Helper` 后缀；ArkTS 侧同用 `*Wrapper.ets` / `*Helper.ets`
- Model 文件存在 `chat_` 前缀（`chat_message.dart`）与无前缀（如 `fetch_message_options.dart`）两种风格，新增时参考同类文件、保持类名 `Chat` 前缀即可
- 旧 `EM*` 命名已由 `lib/em_compat.dart` 中的 `@Deprecated` typedef 统一兼容（4.22.0 改名时聚拢，仅为兼容存量用户代码），**新代码不得再使用 `EM*` 名称**，也不得向 em_compat.dart 新增条目
- MethodChannel 统一前缀 `com.chat.im`，格式 `com.chat.im/{manager_name}`：`com.chat.im/chat_manager`

## 代码风格要点

- import 顺序：dart 标准库 → flutter → `im_flutter_sdk` → `im_flutter_sdk_interface`
- Manager 一律通过 `ChatClient.getInstance` 获取，禁止直接实例化
- Model 必须实现 `fromJson` 工厂构造与 `toJson()`；MethodChannel 传输格式为 JSON Map
- MethodChannel 方法名必须使用常量：Dart 侧 `ChatMethodKeys`、Android 侧 `MethodKey.java`、iOS 侧 `MethodKeys.h`、HarmonyOS 侧 `MethodKeys.ets`，禁止在代码中硬编码字符串；原生回调事件名统一定义在 `chat_event_keys.dart`
- 事件处理器以唯一 id 为 key 存于 `Map<String, Handler>`，通过 `addEventHandler(id, handler)` / `removeEventHandler(id)` 管理

## 文档注释规范

代码内的普通注释（实现说明、版本标注等）一律使用英文；唯一的例外是公开 API 的文档注释，必须中英双语。

公开 API 必须使用中英双语注释，以 `~english` / `~chinese` / `~end` 标记分块，两语言块之间空一行：

```dart
/// ~english
/// The message class.
/// ~end
///
/// ~chinese
/// 消息对象类。
/// ~end
```

新增或修改公开 API 时，两种语言必须同步维护。

生成单语 API 文档：运行 `im_flutter_sdk/scripts/gen-apidoc.sh [cn|en]`（默认 `cn`），脚本会在临时副本中剥离另一语言块与标记行后用 `dart doc` 生成 HTML，输出到 `im_flutter_sdk/output/apidoc-<lang>/`（已 gitignore）。

## 新增 API 的标准链路

参照已有 API（如 `loadConversationMessagesWithKeyword`）按以下链路逐层实现，不可跨层跳过：

> 鸿蒙线新增 API 只涉及 Dart 实现与 `im_flutter_sdk_ohos`（HarmonyOS）两侧；表中 Android/iOS 行仅当同步修改复用包（4.25.0 线）时使用，本线不要求四侧同步。

| 层 | 文件 | 动作 |
|---|---|---|
| Dart 实现 | `im_flutter_sdk/lib/src/managers/{业务}_manager.dart` | 新增公开方法与双语注释；可空参数用 `putIfNotNull` 组装请求 Map；用 `ChatError.hasErrorFromResult(result)` 处理错误；返回值转为强类型对象 |
| Dart 常量 | `im_flutter_sdk/lib/src/internal/chat_method_keys.dart` | 新增 `static const String` 方法名常量 |
| Android 常量 | `im_flutter_sdk_android/android/src/main/java/com/easemob/im_flutter_sdk/MethodKey.java` | 新增同名同值常量 |
| Android 实现 | 同目录下 `{业务}Wrapper.java` | `onMethodCall` 注册分支；参数校验与类型/枚举转换；调用 Hyphenate Android SDK 异步 API；回调中经 `updateObject` 返回可序列化结构 |
| iOS 常量 | `im_flutter_sdk_ios/ios/im_flutter_sdk_ios/Sources/im_flutter_sdk_ios/include/im_flutter_sdk_ios/MethodKeys.h` | 新增同名同值常量 |
| iOS 实现 | `im_flutter_sdk_ios/ios/im_flutter_sdk_ios/Sources/im_flutter_sdk_ios/{业务}Wrapper.m` | `handleMethodCall` 注册分支；参数校验与类型/枚举转换；调用 Hyphenate iOS SDK；completion 中经 `wrapperCallBack` 返回 |
| HarmonyOS 常量 | `im_flutter_sdk_ohos/ohos/src/main/ets/components/plugin/MethodKeys.ets` | 新增同名同值常量 |
| HarmonyOS 实现 | 同目录下 `{业务}Wrapper.ets` | `override onMethodCall` 注册分支；参数校验与类型/枚举转换；调用 `@easemob/chatsdk` Promise，经 `Wrapper.handlePromise` / `onSuccess` / `onError` 返回可序列化结构 |

同时还需：

- 按现有风格在新代码附近标注版本注释（如 `// 4.15.2`、`#pragma mark 4.15.2`）
- 更新 CHANGELOG（见下节）

提交前自检：

- [ ] 鸿蒙线（Dart / HarmonyOS）方法名常量的值完全一致（修改复用包时再核对 Android/iOS）
- [ ] Dart 请求参数 key 与原生读取 key 完全一致
- [ ] 枚举索引与原生枚举映射一致
- [ ] 返回结构可被 Dart 正确反序列化（注意 `Map<String, List<String>>` 等泛型）
- [ ] HarmonyOS 路由分支已注册（修改复用包时再核对 Android/iOS）

新增 Model：在 `im_flutter_sdk/lib/src/models/` 建文件，类名 `Chat` 前缀，实现 `fromJson`/`toJson`，在 `im_flutter_sdk/lib/im_flutter_sdk.dart` 导出，写双语注释。

新增事件处理器：在 `im_flutter_sdk/lib/src/handlers/manager_event_handler.dart` 定义 `Chat{业务}EventHandler`，在对应 Manager 实现 `addEventHandler`/`removeEventHandler`，原生事件名加入 `lib/src/internal/chat_event_keys.dart`。

## 版本与 CHANGELOG

- 2 个发布包版本号必须严格一致：`im_flutter_sdk` 与 `im_flutter_sdk_ohos`，当前 `1.15.0-ohos`；3 个复用包保持 pub.dev 已发布的 **4.25.0**，**不发布新版本**，不参与一致性检查。
- 鸿蒙线版本号跟随 HarmonyOS native chatsdk（`@easemob/chatsdk` 1.15.0 → Flutter `1.15.0-ohos`），采用 1.x 规则 + `-ohos` 预发布后缀，不再使用 4.x。
- 主包与实现包 CHANGELOG 当前保留 `1.15.0-ohos`、`1.5.4`、`1.5.3` 三个版本；格式为 `## 版本号` 标题 + `- 新增…` / `- 修复…` / `- 优化…` 条目。
- 新增 API 时：主包与实现包 CHANGELOG 记录对应条目；interface / android / ios 为复用包，不随鸿蒙线改动。

## Git 分支管理

- 本 worktree 位于 `ohos` 分支（鸿蒙线），发布版本使用同名 Git tag（当前 `1.15.0-ohos`），用户按 tag 依赖主包；4.x/5.x 主线「每个版本一个同名分支、不使用 tag」的规则不适用于本线。
- 主线默认分支为 `flutter2_stable`；`alpha`、`dev`、`customMsg` 等为特性或历史分支，勿在其上做版本开发。
- **切换分支前先确认工作区干净**（`git status` 无未提交改动）；不干净则停止操作并告知用户，由用户决定如何处理
- **创建 worktree 时，统一放在仓库根目录的 `.worktree/` 文件夹下**（如 `git worktree add .worktree/agora-1.4.0 agora-1.4.0`），不要放在仓库外部

## 平台支持

本仓库的 `ohos` 分支（鸿蒙线）主包 `im_flutter_sdk` 只声明 HarmonyOS 平台；Android/iOS 请使用 pub.dev 官方发布线。

- 官方线（pub.dev `im_flutter_sdk` 4.25.0 / 5.0.0）：Android minSdk 21（HyphenateChat 4.25.1）、iOS 13.0（HyphenateChat 4.25.0，CocoaPods 与 SPM 共用同一份源码，两条链路原生版本一致）。
- 鸿蒙线（本分支）：HarmonyOS 5.0.0 (API 12) 及以上，原生 SDK `@easemob/chatsdk` 1.15.0；使用鸿蒙版 Flutter `3.41.9+ohos`（fvm `custom_ohos`）构建。

| 平台 | 最低版本 | 原生 SDK |
|---|---|---|
| HarmonyOS | HarmonyOS 5.0.0 (API 12) | @easemob/chatsdk 1.15.0 |
| Dart | >=3.3.0 <4.0.0 | — |
| Flutter | >=3.3.0（鸿蒙构建用 3.41.9+ohos） | — |
