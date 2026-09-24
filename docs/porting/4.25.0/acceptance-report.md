# 验收报告：im_flutter_sdk 4.25.0 平版（native 4.24.1 → 4.25.0）

- 日期：2026-09-09（2026-09-10 按用户评审意见修订）
- 源：iOS `emclient-ios` `4.24.1 → 4.25.0`；Android `emclient-android` `SDK_4.24.1 → SDK_4.25.0`
- 目标：`im_flutter_sdk`，worktree `.worktree/4.25.0`，分支 `4.25.0`（从 `flutter2_stable` 53b88ac7 切出）
- 变更清单全文见同目录 `01-api-diff.md`；契约见 `02-contract.md`；实现记录见 `03-implementation.md`；验证记录见 `04-verification.md`
- **代码状态：未提交**（全部改动在 worktree 工作区；本地依赖覆盖层 LOCAL-DEP-TEST 同样未提交，待人工还原）

## 二维对照表

| 变更项 | iOS 源 | Android 源 | Dart | Android Wrapper | iOS Wrapper | 状态 |
|---|---|---|---|---|---|---|
| `fetchConversationsFromDB`（本地会话分页加载） | `getConversationsFromDBWithCursor:pageSize:completion:` | `asyncGetConversationsFromDB(cursor, pageSize, callback)` | 已实现 | 已实现 | 已实现 | ✅ |
| `enableChatroomConversation`（聊天室消息建会话） | `EMOptions.enableChatroomConversation` | `set/isEnableChatroomConversation` | 已实现（默认 false） | 已实现 | 已实现 | ✅ |
| ~~`useAgoraChatDomain`（域名切换）~~ | 裸 `BOOL` 属性，无文档 | `Boolean` 三态 + `@hide` configured 检查 | **不移植**（评审确认：native 对内品牌开关，国内不设置走缺省/海外显式 true，KI-107） | 不移植 | 不移植 | ✅ 已闭环 |
| `autoLoadConversations`（衍生新增，UM-2） | `EMOptions.autoLoadConversations`（4.24.1 已有） | `setAutoLoadAllConversations`（4.24.1 已有） | 已实现（默认 true，文档强调分页前须关闭及原因） | 已实现 | 已实现 | ✅ 评审确认保留 |
| `ChatOptions.copyWith` 透传修复（评审新增） | - | - | "未传字段不修改"：补 `enableChatroomConversation`/`autoLoadConversations` + 历史遗漏 `ntpServers`/`workPathCopiable` 透传，`loginExtension`/`extSettings` 改 `?? this.x`；`_pushConfig` 由用户手动改造为私有构造参数并透传 | - | - | ✅ |
| `ChatConversation.toJson()`（评审新增） | - | - | 新增公开 `toJson()`（与 fromJson 对称，供调试/测试） | - | - | ✅ |
| syncDataWS host/port 移除 | 已删（EMOptions+PrivateDeploy） | 已删（EMOptions 四个方法） | Flutter 基线未暴露，无改动 | - | - | ✅ 无破坏性 |
| 搜索关键词上限注释（512/1024→120） | 无变更 | 注释变更 | Dart 侧注释已是 120，无需改 | - | - | ✅ |
| NTP 校时（token 有效期计算） | 内部实现 | 内部实现 | skip（非公开 API） | - | - | ✅ skip |

## 验证结果汇总（详见 04-verification.md）

| 验证项 | 结果 | 备注 |
|---|---|---|
| `flutter analyze`（主包 + example） | ✅ | No issues found |
| example 构建 Android APK | ✅ | 实证 APK 含 3 ABI libaosl.so + libhyphenate.so |
| example 构建 iOS CocoaPods | ✅ | Frameworks 含 HyphenateChat.framework + aosl.framework |
| example 构建 iOS SPM | ✅ | 同上；构建后已恢复 flutter SPM 全局配置 |
| API 脚本回归 Android（emulator-5554，3 步） | ✅ | 网络恢复后重跑通过：init（autoLoadConversations=false 链路）+ login + 分页/翻页 + 无效 cursor 错误路径（110 INVALID_PARAM）全部符合预期；新装模拟器本地无会话，list 为空属预期 |
| API 脚本回归 iOS（iPhone 16 Pro 模拟器，3 步） | ✅ | init（autoLoadConversations=false 链路）+ login + 分页/翻页/无效 cursor 错误路径全部符合预期（无效 cursor 返回 110 INVALID_PARAM 为预期断言） |
| 契约要素 grep 抽查（方法名 key / options key / 参数 key / 返回结构 / 版本一致性） | ✅ | 04 附实证输出 |
| porting_guard gate（阶段二/三/四） | ✅ 通过 | 输出已附各阶段产物 |
| 评审修订后复验（2026-09-10）：`flutter analyze` 主包+example、全仓 grep `useAgoraChatDomain` 零残留 | ✅ | 见 04「评审后修订复验」 |

## 未匹配清单处理结果

| id | 疑点 | 处理 |
|---|---|---|
| UM-1 | `useAgoraChatDomain` 双端语义差异（iOS 裸 BOOL 无文档 vs Android 三态） | 评审确认：native 对内品牌开关，不面向终端用户 → Flutter 不移植，已实现代码全部移除；沉淀 KI-107 ✅ |
| UM-2 | 新 API 前置条件 `autoLoadConversations=false` 在 Flutter 基线无入口 | 契约 C4：衍生新增 `ChatOptions.autoLoadConversations`（默认 true）；评审确认保留，文档补充"开启自动加载则分页失去意义"的原因说明 ✅ |
| UM-3 | syncDataWS 移除是否影响 Flutter | 基线 grep 实证未暴露，无影响 ✅ |
| UM-4 | 关键词上限注释仅 Android 变更 | Dart 侧已是 120，无需改 ✅ |

## 问题清单

1. **本地依赖覆盖层未提交、待人工还原**：build.gradle / podspec / Package.swift 三个文件含 LOCAL-DEP-TEST 注释段（bump 4.25.0 与覆盖层同文件共存）；`im_flutter_sdk_android/android/libs/` 与 `im_flutter_sdk_ios/ios/im_flutter_sdk_ios/framework/` 为拷贝目录（已入 .git/info/exclude），其中 libs 下 libhyphenate.so 已用 symbolLibs 真实 so 替换 stub（运行时验证用）。⚠️ 还原时不能直接 `git checkout` 这三个文件——会把 4.25.0 bump 一并回退；需手工剔除 LOCAL-DEP-TEST 注释段后保留 bump，再删两个拷贝目录与 exclude 条目、恢复 example/ios 构建副产物。
2. **远端发布状态未核实**：环境无外网，`HyphenateChat`（CocoaPods）/`HyphenateChat_iOS`（SPM tag 4.25.0）/`io.hyphenate:hyphenate-chat:4.25.0`（maven）是否已发布未经核实；已提交的依赖声明指向 4.25.0，若 SPM tag 尚未发布，SPM 远程集成会失败，需人工核实后再合并。
3. ~~Android 模拟器无外网导致功能回归止步于 init（login 308）~~ —— 用户恢复网络后重跑已通过，双端功能回归均 ✅。
4. `example/pubspec.lock` 被 pub get 连带刷新（4.24.0→4.25.0），属合理连带。
5. 为支持 worktree 流程，工作区资产脚本 `.agents/skills/platform-sdk-porting-v2/scripts/flutter-local-deps.sh` 做了三处兼容性修改（git 检测 rev-parse 化、exclude 路径 `--git-path` 化、dirty guard 增加 `LOCAL_DEPS_ALLOW_DIRTY=1` 放行），该脚本修改可提交（属根仓库管理性内容）。

## 待用户决策项

1. ~~`useAgoraChatDomain` 的 Flutter 语义~~ → 已闭环：确认为对内品牌开关，不移植（KI-107）。
2. ~~`autoLoadConversations` 是否保留~~ → 已闭环：保留，并强调分页前须关闭自动加载（含原因说明）。
3. ~~`ChatOptions.copyWith` 是否补透传~~ → 已闭环：按"未传字段不修改"语义修复——新字段已补，并顺带修复历史遗漏的 `ntpServers`（4.24.0）/`workPathCopiable`（4.10）透传及 `loginExtension`/`extSettings` 被清 null 的问题。
4. 本地依赖覆盖层的还原方式与时机（见问题清单 1），以及远端包可用后是否重跑一次正式源构建验证。
5. ~~example 注册条目手工 map~~ → 已闭环：`ChatConversation` 新增公开 `toJson()`，注册条目已改用。

## 验收闭环后复盘分流（known-issues）

- 已沉淀 **KI-107**：`useAgoraChatDomain` 为 native 对内品牌开关（国内 easemob 不设置走默认缺省、海外 agora 显式指定 true），跨平台 SDK 不暴露、环信侧零代码（Android 默认 null 未配置时不下发底层；iOS BOOL 零初始化即缺省）。
- 候选新条目：worktree 流程下 flutter-local-deps.sh 不兼容（.git 文件判定/git checkout 吞 bump）——脚本已修复，建议标记 resolved 并注明修复落点（工作区 .agents 资产，随脚本现状生效）；restore 在存在未提交 bump 时会吞 bump 的风险可入清单提醒。
- 其余本次问题均为环境/流程性，不入清单。

---

# 验收报告补充：iOS PushKit 回移（4.25.0 兼容版）

- 日期：2026-09-24
- 来源：5.0.0 分支最后一次提交 `41d2cf17`（`feat(push): add iOS PushKit APIs and make iOS certificate names init options`）的**定向回移**，按 4.25 兼容优先做差异化取舍
- 目标：`im_flutter_sdk`，worktree `.worktree/4.25.0`，分支 `4.25.0`
- 变更清单、契约、实现、验证与待决策全文见同目录 `05-pushkit.md`
- **代码状态：未提交**（用户明确要求先审后提交）

## 二维对照表

| 变更项 | iOS 源（HyphenateChat 4.25.0） | Android 源 | Dart | Android Wrapper | iOS Wrapper | 状态 |
|---|---|---|---|---|---|---|
| `pushkit_register`（PushKit 绑定） | `registerPushKitToken:completion:`（`EMClient.h:776`） | 无（iOS 专有） | 新增 `ChatPushManager.bindPushKitToken({required String deviceToken})` + `Platform.isIOS` 守卫 | 注册同名 route → `OPERATION_UNSUPPORTED` | 新增路由 + 实现 | ✅ |
| `pushkit_unregister`（PushKit 解绑） | `unRegisterPushKitTokenWithCompletion:`（`EMClient.h:825`） | 无（iOS 专有） | 新增 `ChatPushManager.unbindPushKitToken()` + `Platform.isIOS` 守卫 | 注册同名 route → `OPERATION_UNSUPPORTED` | 新增路由 + 实现 | ✅ |
| `pushkit_cert_name`（PushKit 证书名） | `EMOptions.pushKitCertName`（`EMOptions.h:305`） | 无（iOS 专有） | `ChatOptions.pushKitCertName`（初始化下发，不入 copyWith 形参） | - | `OptionsHelper.fromJson` 映射 | ✅ |
| `apns_cert_name`（APNs 证书名） | `EMOptions.apnsCertName`（`EMOptions.h:290`） | 无（iOS 专有） | `ChatOptions.apnsCertName`（初始化下发） | - | `OptionsHelper.fromJson` 映射 + `bindDeviceToken` 运行期写入加非空守卫（**与 5.0.0 不同，见 05 D2**） | ✅ 兼容优先 |
| `device_token_notifier_name`（参数形态） | iOS 语义为证书名 | 必填厂商凭据 | **保持 `required`**（**与 5.0.0 不同，见 05 D1**），仅补平台语义文档 | 代码不变 | 代码不变 | ✅ 兼容优先 |
| `pushkit_bind_sync` / `pushkit_unbind_sync` | `bindPushKitToken:` / `unBindPushKitToken`（同步） | 无 | skip（异步变体已覆盖，Flutter 通道本身异步） | - | - | ✅ skip |
| example 注册条目（**新增于 4.25.0**） | - | - | 新增 `push_apis.dart`（3 条）并在 `apiRegistry` 注册 | - | - | ✅ |

## 验证结果汇总（实证输出见 `05-pushkit.md` §8）

| 验证项 | 结果 | 备注 |
|---|---|---|
| `flutter analyze --fatal-infos`（主包 + example） | ✅ | No issues found |
| `flutter test` | ✅ | 28 个用例全部通过 |
| `check_contracts.dart`（CI 同款） | ✅ | MethodChannel contracts are consistent. |
| `check_versions.dart` / `check_case_mapping.dart` | ✅ | 版本与用例映射均通过 |
| 三端方法名 key 逐字 grep | ✅ | Dart / `MethodKeys.h` / `MethodKey.java` 名称与取值一致，两端路由均已注册 |
| 初始化选项 key + 运行期写入守卫 grep | ✅ | key 一致；运行期写入仅剩 1 处且在非空守卫内 |
| iOS 构建 + 产物符号校验 | ✅ | `flutter build ios` 成功；framework 二进制含 `bindPushKitToken:channelName:result:`、`unbindPushKitToken:channelName:result:`、`setApnsCertName:`、`setPushKitCertName:`、`registerPushKitToken:completion:`、`unRegisterPushKitTokenWithCompletion:` |
| Android 构建 + 产物 dex 校验 | ✅ | `flutter build apk --debug` 成功；dex 含 `bindPushKitToken`、`unbindPushKitToken`、`unsupportedPushKit`、`PushKit is only supported on iOS` |
| native 能力证据 | ✅ | 4.25.0 framework 头文件有声明 + ObjC 运行时有实现符号（`otool -oV`），且含证书名空校验字符串 |
| porting_guard gate | ✅ 通过 | 首次报「native 依赖版本不一致」；按用户裁决收窄 gate 规则（iOS 两条集成路径一致即可，Android 依赖版本不参与）后通过，并验证规则仍能拦截 KI-101 类漂移 |
| 版本校验器（仓库 CI） | ✅ | `check_versions.dart` 新增 iOS 双路径校验并通过；新增 2 个单测，`version_checker_test.dart` 4/4 通过 |
| 端到端 VoIP 推送 | ⏭️ 未验证 | 需真机 + PushKit 证书 + 应用侧 `PKPushRegistry`，当前环境不具备 |

## 本次问题清单

1. **`pod install` 前置失败（环境性，已绕过）**：`example/ios/Podfile.lock` 快照停在 `HyphenateChat 4.24.1` / `im_flutter_sdk_ios 4.24.0`，与 pubspec/podspec 的 4.25.0 冲突导致 `pod install` 失败；执行 `pod update HyphenateChat` 后装载 4.25.0 并通过构建。**连带改动**：`im_flutter_sdk/example/ios/Podfile.lock` 刷新为 4.25.0（连带 `ShengwangInfra_iOS` 1.3.5→1.3.16）——用户已裁决「需要刷新」，随本次改动提交。
2. **沙箱需提权（环境性）**：Flutter 启动器需写 `~/fvm/.../bin/cache`、CocoaPods 需写 `~/.cocoapods`，均在会话工作区外，均按策略单次提权后完成；不影响仓库内容。
3. **下载介质 checksum 口径差异**：`HyphenateChat4_25_0.zip` 的 sha256 与 SPM `Package.swift` 的 `checksum` 不同（口径差异），已用「包内版本号 + 头文件 + ObjC 实现符号」三重证据判定介质正确，仍列待决策。
4. **门禁规则过严（已按用户裁决修复）**：`porting_guard.sh` 原把「podspec / Package.swift / gradle 三处 native 依赖版本一致」当硬约束，对「Flutter 4.25.0 + Android native 4.25.1」误报 block。已改为**忽略最后一位、只比 `major.minor`**：四包严格相等、iOS 两条集成路径同线、Android 依赖与包版本同线、podspec `s.version` 跟随包版本；仓库 CI `check_versions.dart` 同步实现并补 6 个单测；规则沉淀进 skill `references/flutter.md` 与 `known-issues.md`（KI-101 限定故障面 + 新增 KI-113）。
5. `OptionsHelper.m toJson` 未输出 `pushKitCertName`（该方法经 grep 证实无调用方，属既存死代码），本次按「少即是稳」未动。

## 本次决策结果与遗留项

已裁决（2026-09-24，详见 `05-pushkit.md` §9.1）：

1. **不升版本**：4.25.0 未发布，四包与 CHANGELOG 版本头维持 4.25.0。
2. **依赖版本不动**：iOS 包/Android 包版本都是 4.25.0，Android native 依赖 4.25.1 允许；iOS 若为 4.25.1 同样允许。统一口径为**版本比对忽略最后一位、只比 `major.minor`**（要保证四包版本强一致，以及 4.25.x 不跨线），改的是检查脚本而非依赖版本。
3. **`Podfile.lock` 随本次提交**。

仍待决策（详见 `05-pushkit.md` §9.2）：

1. 4.25.0 与 5.0.0 的 API 形态差异（D1 参数可选性、D2 证书名运行期写入）是否为长期预期。
2. `EMOptions.h` 证书名注释与实现的差距是否在 native 侧修订。
3. `OptionsHelper.m toJson` 死代码是否补齐 `pushKitCertName` 或直接删除。
4. example 是否补 `PKPushRegistry` 接入以支持端到端自测。
5. `HyphenateChat4_25_0.zip` 的官方 sha256（可选，用于二次确认介质）。

