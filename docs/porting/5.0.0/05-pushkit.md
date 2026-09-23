# 5.0.0 补充：iOS PushKit（VoIP 推送）平版

范围：`01-api-diff.md` ~ `04-verification.md` 与 `acceptance-report.md` 之外的**遗漏项补齐**。PushKit 是 iOS 原生 SDK 长期存在的公开能力，不在 4.24.1 → 5.0.0 的版本 diff 区间内，历次平版均未覆盖，因此单列本文档。

## 1. 结论

- 5.0.0 分支（以及 4.25.0 分支）此前**没有** PushKit 能力：Dart、iOS wrapper、Android wrapper 全链路无 `PushKit` / `pushKitCertName`（`git grep -i "pushkit\|voip"` 命中 0）。
- 本次只在 **5.0.0 分支**补齐 iOS 专用公开 API，并同时把 iOS 的两个推送证书名改为**初始化配置**；4.25.0 分支本次不动。
- iOS 原生侧能力完整（HyphenateChat 5.0.0 头文件与实现均有），本次不改 native。

## 2. 变更清单（native → Flutter）

| id | 类型 | 领域 | iOS native 签名（HyphenateChat 5.0.0） | Android native | Flutter 决策 | 状态 |
| --- | --- | --- | --- | --- | --- | --- |
| `pushkit_cert_name` | existing_option | push | `@property(nonatomic, copy) NSString *pushKitCertName`（`EMOptions.h`） | 无（iOS 专有） | include → `ChatOptions.pushKitCertName`（初始化时下发，运行时不修改） | implemented |
| `apns_cert_name` | existing_option | push | `@property(nonatomic, copy) NSString *apnsCertName`（`EMOptions.h`） | 无（iOS 专有） | include → `ChatOptions.apnsCertName`（初始化时下发）；同时移除 iOS wrapper 在 `bindDeviceToken` 中的运行期赋值 | implemented |
| `pushkit_register` | existing_api | push | `- (void)registerPushKitToken:(NSData *)aPushToken completion:(void (^)(EMError *))aCompletionBlock` | 无（iOS 专有） | include → `ChatPushManager.bindPushKitToken({required String deviceToken})`；Android 注册同名 route 并返回 `EMError.OPERATION_UNSUPPORTED`（Dart 非 iOS 不下发） | implemented |
| `pushkit_unregister` | existing_api | push | `- (void)unRegisterPushKitTokenWithCompletion:(void (^)(EMError *))aCompletionBlock` | 无（iOS 专有） | include → `ChatPushManager.unbindPushKitToken()`；Android 同上 | implemented |
| `pushkit_bind_sync` | existing_api | push | `- (EMError *)bindPushKitToken:(NSData *)aPushToken` | 无（iOS 专有） | skip（同步变体不单独暴露：Flutter 方法通道本身即异步，暴露会产生两个语义完全相同的 API） | skip |
| `pushkit_unbind_sync` | existing_api | push | `- (EMError *)unBindPushKitToken` | 无（iOS 专有） | skip（同上） | skip |
| `device_token_notifier_name` | signature_change | push | `EMPushManager.bindDeviceToken`（iOS 侧不再使用证书名） | `EMPushManager.bindDeviceToken(String notifierName, String deviceToken, EMCallBack)`（`notifierName` 非空校验，空则 `EMError.INVALID_PARAM`） | `ChatPushManager.bindDeviceToken({required String deviceToken, String? notifierName})`：参数改为可选，iOS 忽略，Android 必填 | implemented |

未匹配清单：

- UM-1：Android 端无 PushKit 能力。用户已确认「仅 iOS 支持，非 iOS 调用静默 no-op」。
- UM-2：native 4 个 PushKit 方法为语义相同的同步/异步两对。用户已确认「只暴露异步一对」。
- UM-3：`EMOptions.h` 注释称 `pushKitCertName`/`apnsCertName`「只能在 `initializeSDKWithOptions` 时设置」，而实现是在绑定 token 时读取 `options` 的属性。本次按文档语义实施（仅初始化设置、运行时不修改），是否修正 native 注释交用户决策。
- UM-4：`notifierName` 在两端同名不同义（iOS 曾是证书名、Android 是厂商凭据）。已通过「改为可选 + 平台语义注释」收敛，不引入双路径。
- UM-5：普通推送 token 只有绑定、没有解绑（`bindDeviceToken`），PushKit 绑定/解绑成对。两者是独立能力，不合并入口。

## 3. 跨端契约

| 契约要素 | 取值 | 落点 |
| --- | --- | --- |
| 初始化选项 key | `apnsCertName`、`pushKitCertName`（顶层，可选） | Dart `ChatOptions.toJson()` / iOS `OptionsHelper.fromJson` |
| 方法名 key | `bindPushKitToken` / `unbindPushKitToken` | `chat_method_keys.dart` / `MethodKeys.h` |
| 路由注册 | iOS wrapper 实现；Android wrapper 注册同名 route 并返回 `EMError.OPERATION_UNSUPPORTED`（仓库契约检查器要求三端方法名 key 与路由齐全） | `PushManagerWrapper.m` / `PushManagerWrapper.java` |
| 请求参数 key | `bindPushKitToken`：`deviceToken`（十六进制字符串）；`bindDeviceToken`：`deviceToken` + `notifierName`（可选，iOS 忽略） | Dart 组装 / iOS 读取 |
| 返回结构 | `wrapperCallBack` 包装为 `{<方法名>: nil}`，Dart 只取错误 | 与 `syncSilentModels` 等 object 为 nil 的路由一致 |
| 非 iOS 行为 | Dart 侧 `Platform.isIOS` 守卫，静默 no-op | `chat_push_manager.dart` |

## 4. 原生行为依据（决定 API 形态的关键证据）

本地 emclient-ios 检出（`fix-ntp-token-expiry`，其 `EMClient.h` PushKit 区段行号与 4.25.0 发布 framework 头一致）与 `easemob/sdk-5.0` 分支实现同构：

- 绑定时读取证书名：`EMClient.mm:1610/1622`（5.0 线 `1592/1604`）读取 `self.options.pushKitCertName`，为空返回 `EMErrorUserIllegalArgument`（"pushkit cert name is NULL"）；`_bindDeviceToken` 对 `options.apnsCertName` 有同样校验（"Apns cert name is NULL"）。
- 解绑时同样读取该属性：`EMClient.mm:1796`（5.0 线 `1778`）。
- 登录后自动重绑：`EMClient.mm:1199-1202`（5.0 线 `1183-1186`）登录成功后自动 `_bindDeviceToken:NO` + `_bindPushKitToken`；token 先写入 keychain（`kBindPushKitToken`），绑定失败按退避重试。
- 登出自动解绑：`EMClient.mm:1436-1440`（5.0 线 `1414-1422`）`logout(YES)` 已同时调用 `unBindPushKitToken`。
- 结论：证书名只要在绑定之前存在于 `options` 上即可生效。原实现的运行期赋值虽然可用，但与 `EMOptions.h` 的「仅初始化可设置」契约冲突，且留下「证书名可能被后续 bind 调用覆盖」的隐患；本次统一改为初始化下发，绑定链路只读不写。
- ⚠️ `EMOptions.h` 的属性注释与实现不一致（注释说仅初始化可设置，实现是绑定时读取）。本次按注释语义实施，注释修订属 native 侧事项。

## 5. 实现落点

| 层 | 文件 | 改动 |
| --- | --- | --- |
| Dart 选项 | `im_flutter_sdk/lib/src/models/chat_options.dart` | 新增 `apnsCertName` / `pushKitCertName`（双语注释 + 可选字段）：三个公开构造函数与私有 `_()`、`toJson()` 全部打通；**未加入 `copyWith`**，以体现「运行中不可变」 |
| Dart 常量 | `im_flutter_sdk/lib/src/internal/chat_method_keys.dart` | 新增 `bindPushKitToken` / `unbindPushKitToken`（`// 5.0.0`） |
| Dart API | `im_flutter_sdk/lib/src/managers/chat_push_manager.dart` | 新增 `bindPushKitToken({required String deviceToken})` / `unbindPushKitToken()`（双语注释 + `Platform.isIOS` 守卫）；`bindDeviceToken` 的 `notifierName` 改为可选并补充平台语义注释（请求 Map 始终带该 key，空值由原生报参数非法错误）；文件顶部新增 `dart:io` import |
| iOS 选项 | `im_flutter_sdk_ios/.../OptionsHelper.m` | `fromJson` 读取 `apnsCertName` / `pushKitCertName` 写入 `EMOptions`（带 null 判断）；`toJson` 回读补上这两个 key |
| iOS 常量 | `im_flutter_sdk_ios/.../include/im_flutter_sdk_ios/MethodKeys.h` | 新增 2 个常量（`// 5.0.0`） |
| iOS 实现 | `im_flutter_sdk_ios/.../PushManagerWrapper.m` | 新增 2 条路由 + 2 个实现（`#pragma mark - 5.0.0`）；**删除运行期赋值**：`bindDeviceToken` 不再写 `options.apnsCertName`，`bindPushKitToken` 不写 `options.pushKitCertName`，两处均改为只读说明注释 |
| Android | `MethodKey.java`、`PushManagerWrapper.java` | 新增 `bindPushKitToken` / `unbindPushKitToken` 两个常量（`// 5.0.0`）与两条 route；因 Android 无 PushKit API，两个 route 统一返回 `EMError.OPERATION_UNSUPPORTED`（"PushKit is only supported on iOS"）。Dart 侧 `Platform.isIOS` 守卫使其正常不可达，保留注册是为满足 `tool/ci/check_contracts.dart` 的跨端契约；`notifierName` 的语义与必填要求不变 |

实现说明：

- **token 传参**：Dart 传十六进制字符串，iOS 侧按既有 APNs 路径（`bindFCMToken:`）同样的方式把字符串交给原生的 `_extractTokenFromRawData:`（`EMClient.mm:1467`，同时兼容 `NSData` 与 `NSString`，后者会去掉 `<>` 与空格）。未在 wrapper 内做 hex → `NSData` 转换，以避免走 `NSData` 分支的固定 8×4 字节读取。
- **未添加上层判空**：证书名为空由原生返回 `EMErrorUserIllegalArgument`，与既有 `bindDeviceToken` 行为一致，不擅自在上层加过滤。
- **行为变更**：iOS 上 `bindDeviceToken(notifierName:)` 不再影响 `options.apnsCertName`。仅依赖旧写法配置 APNs 证书名的应用，升级后必须在 `ChatOptions.apnsCertName` 中配置，否则绑定失败（原生返回证书名为空的非法参数错误）。该变更已写入主包 CHANGELOG 的 Breaking Changes 与迁移指南。
- **版本注释**：按仓库惯例标为 `5.0.0`；若最终以 5.0.1 发布，需同步调整代码注释与 CHANGELOG 版本头。

## 6. 文档更新

- `im_flutter_sdk/CHANGELOG.md`：Breaking Changes 新增「Push Credentials」小节；New Features 新增 `ChatOptions.apnsCertName`/`pushKitCertName` 与 PushKit 接口条目；厂商开关那条补上 iOS 证书名的新归属。
- `im_flutter_sdk_ios/CHANGELOG.md`：新增 PushKit 路由、`OptionsHelper` 证书名映射、`bindDeviceToken` 不再运行期写证书名三条。
- `im_flutter_sdk_interface/CHANGELOG.md`、`im_flutter_sdk_android/CHANGELOG.md`：本次无改动（interface 只提供通道抽象，无方法名常量；Android 无对应实现），故不新增条目。
- 四包 `pubspec.yaml` 版本号未改动，仍为 `5.0.0`（见 §8 待决策 1）。
- `docs/5.0.0-migration-guide/2026-09-23-flutter-migration-guide.md`：「推送与设备 Token」小节重写（4.x 对照表、两处 warning、示例）、新增「PushKit（VoIP 推送）」小节、主要新增 API 表三行、已知限制两行、迁移检查清单三项。

## 7. 验证记录

| 验证项 | 命令 | 结果 |
| --- | --- | --- |
| `flutter analyze` | `cd im_flutter_sdk && flutter analyze` | ✅ No issues found（Flutter 3.47.0 / Dart 3.13.0） |
| 三端方法名 key 逐字比对 | `grep` Dart / `MethodKeys.h` / `MethodKey.java` | ✅ Dart 与 iOS 逐字一致；Android 无该 key（预期，iOS-only） |
| 初始化选项 key 比对 | Dart `toJson()` ↔ `OptionsHelper.fromJson` / `toJson` | ✅ `apnsCertName` / `pushKitCertName` 三处 key 一致 |
| 运行期赋值残留检查 | `grep -n "options.apnsCertName\s*=\|options.pushKitCertName\s*=" PushManagerWrapper.m` | ✅ 无残留（仅 `OptionsHelper.fromJson` 在初始化时赋值） |
| porting gate | `echo '{}' \| bash .agents/skills/platform-sdk-porting-v2/hooks/porting_guard.sh gate flutter <repo>` | ✅ `gate_exit=0`（三端 key 一致，无需白名单） |
| iOS example 构建 | `cd im_flutter_sdk/example && flutter build ios --debug --no-codesign` | 见 §7.1 |
| 契约检查（CI 同款） | `cd im_flutter_sdk && dart run tool/ci/check_contracts.dart ..` | ✅ `MethodChannel contracts are consistent.` |
| 版本检查（CI 同款） | `dart run tool/ci/check_versions.dart ..` | ✅ Flutter 5.0.0 / Android Native 5.0.0 / iOS Native 5.0.0 |
| Android example 构建 | `cd im_flutter_sdk/example && flutter build apk --debug` | 见 §7.2 |
| 端到端 VoIP 推送 | 需真机 + PushKit 证书 + 应用侧 `PKPushRegistry` | ⏭️ 当前环境不具备（example 无 `PKPushRegistry`，无法产生真实 PushKit token） |

### 7.1 iOS 构建结果

```text
$ cd im_flutter_sdk/example && flutter build ios --debug --no-codesign
Warning: Building for device with codesigning disabled. You will have to manually codesign before deploying to device.
Building com.example.example for device (ios)...
Running Xcode build...
Xcode build done.                                           14.0s
✓ Built build/ios/iphoneos/Runner.app
build_exit=0
```

产物校验（证明新增 ObjC 代码确实编进了二进制，而不仅是「构建通过」）：

```text
$ strings -a build/ios/iphoneos/Runner.app/Frameworks/im_flutter_sdk_ios.framework/im_flutter_sdk_ios | grep -iE "pushkitcertname|apnscertname|bindpushkit|unbindpushkit|registerpushkit|unRegisterPushKit" | sort -u
apnsCertName
bindPushKitToken
bindPushKitToken:channelName:result:
pushKitCertName
registerPushKitToken:completion:
setApnsCertName:
setPushKitCertName:
unbindPushKitToken
unbindPushKitToken:channelName:result:
unRegisterPushKitTokenWithCompletion:
```

其中 `bindPushKitToken:channelName:result:` / `unbindPushKitToken:channelName:result:` 为本次新增的 wrapper 方法；
`setApnsCertName:` / `setPushKitCertName:` 来自 `OptionsHelper.fromJson` 的初始化赋值（运行期赋值已删除，此处来源唯一）；
`registerPushKitToken:completion:` / `unRegisterPushKitTokenWithCompletion:` 为接线调用的原生 API。

### 7.2 Android 构建结果

```text
$ cd im_flutter_sdk/example && flutter build apk --debug
Running Gradle task 'assembleDebug'...                             40.5s
✓ Built build/app/outputs/flutter-apk/app-debug.apk
apk_exit=0
```

仅有仓库既有的 Java 8 / deprecation / unchecked 警告，无错误。

### 7.3 仓库 CI 质量门禁（本地复跑 `tool/ci/run_quality.sh`）

```text
$ ./tool/ci/run_quality.sh
All tests passed!                                  # 55 个单元测试
Native-to-Flutter case mapping is valid.
MethodChannel contracts are consistent.            # 本次修复前为 Method key mismatch
Versions are consistent: Flutter 5.0.0, Android Native 5.0.0, iOS Native 5.0.0.
quality_exit=0
```

该脚本依次执行：`ensure_example_env.sh` → 五个包 `flutter pub get` → 变更 Dart 文件 `dart format --set-exit-if-changed` → 五个包 `flutter analyze --fatal-infos` → `flutter test --coverage` → `check_case_mapping.dart` / `check_contracts.dart` / `check_versions.dart`，全部通过。

## 8. 待用户决策

1. **发布版本号**：改动落在 5.0.0 分支、四包 `pubspec.yaml` 仍为 `5.0.0`。随 5.0.0 发布，还是另开 5.0.1？（影响 CHANGELOG 版本头与代码内 `// 5.0.0` 注释）
2. **`porting_guard.sh` 白名单**：Android 侧补齐常量与路由后，三端 key 已一致，工作区脚本里曾加的两个 `PLATFORM_ONLY_KEYS` 条目已回退（无需保留）。
3. **native 注释**：是否在 emclient-ios 侧修正 `EMOptions.h` 中 `apnsCertName` / `pushKitCertName` 的「仅初始化可设置」注释与实现的差异。
4. **example 注册条目**：`example/lib/registry/apis/` 目前没有 push 类条目，且 example 未实现 `PKPushRegistry`；是否需要为 `bindPushKitToken` 增加可手工触发的注册项。
5. **4.25.0 分支**的补齐时间点（本次未动）。
