# 4.25.0 补充：iOS PushKit（VoIP 推送）平版

范围：`01-api-diff.md` ~ `04-verification.md` 与 `acceptance-report.md` 之外的**遗漏项补齐**。PushKit 是 iOS 原生 SDK 长期存在的公开能力，不在 4.24.1 → 4.25.0 的版本 diff 区间内，历次平版均未覆盖，因此单列本文档（与 5.0.0 分支 `docs/porting/5.0.0/05-pushkit.md` 同构，便于两分支对照）。

## 1. 结论

- 4.25.0 分支此前**没有** PushKit 能力：全链路（Dart `im_flutter_sdk/lib`、iOS wrapper、Android wrapper）grep `pushkit|voip` 命中 0（仅 iOS 构建产物 `.build/` 二进制误命中）。
- 本次从 5.0.0 分支最后一次提交 `41d2cf17`（`feat(push): add iOS PushKit APIs and make iOS certificate names init options`）**定向回移**，并按 4.25.0 的兼容要求做了 3 处差异化取舍（见 §2.1）。
- iOS 原生侧能力完整（HyphenateChat 4.25.0 framework 同时具备头文件声明与 Objective-C 实现，见 §4），本次**不改 native**。

## 2. 变更清单（native → Flutter）

| id | 类型 | 领域 | iOS native 签名（HyphenateChat 4.25.0） | Android native | Flutter 决策 | 状态 |
| --- | --- | --- | --- | --- | --- | --- |
| `pushkit_cert_name` | existing_option | push | `@property(nonatomic, copy) NSString *pushKitCertName;`（`EMOptions.h:305`） | 无（iOS 专有） | include → `ChatOptions.pushKitCertName`（初始化时下发，运行时不修改） | implemented |
| `apns_cert_name` | existing_option | push | `@property(nonatomic, copy) NSString *apnsCertName;`（`EMOptions.h:290`） | 无（iOS 专有） | include → `ChatOptions.apnsCertName`（初始化时下发）；**保留** iOS wrapper 在 `bindDeviceToken` 中的运行期写入，二者并存（见 §2.1 D2） | implemented |
| `pushkit_register` | existing_api | push | `- (void)registerPushKitToken:(NSData *_Nullable)aPushToken completion:(void (^_Nullable)(EMError * _Nullable aError))aCompletionBlock;`（`EMClient.h:776`） | 无（iOS 专有） | include → `ChatPushManager.bindPushKitToken({required String deviceToken})`；Android 注册同名 route 并返回 `EMError.OPERATION_UNSUPPORTED`（Dart 非 iOS 不下发） | implemented |
| `pushkit_unregister` | existing_api | push | `- (void)unRegisterPushKitTokenWithCompletion:(void (^_Nullable)(EMError * _Nullable aError))aCompletionBlock;`（`EMClient.h:825`） | 无（iOS 专有） | include → `ChatPushManager.unbindPushKitToken()`；Android 同上 | implemented |
| `pushkit_bind_sync` | existing_api | push | `- (EMError *_Nullable)bindPushKitToken:(NSData *_Nullable)aPushToken;`（`EMClient.h:753`） | 无（iOS 专有） | skip（同步变体不单独暴露：Flutter 方法通道本身即异步，暴露会产生两个语义完全相同的 API，且会阻塞平台线程） | skip |
| `pushkit_unbind_sync` | existing_api | push | `- (EMError *_Nullable)unBindPushKitToken;`（`EMClient.h:802`） | 无（iOS 专有） | skip（同上） | skip |
| `device_token_notifier_name` | signature_change | push | iOS 侧 `notifierName` 语义为 APNs 证书名（可选，非空时覆盖初始化配置） | `EMPushManager.bindDeviceToken(String notifierName, String deviceToken, EMCallBack)`（`notifierName` 非空校验，空则 `EMError.INVALID_PARAM`） | **4.25.0 保持 `required String notifierName` 不变**（见 §2.1 D1），仅补充平台语义文档 | done |

### 2.1 与 5.0.0 的差异化决策（4.25.0 兼容优先）

| id | 5.0.0 做法 | 4.25.0 做法 | 依据 |
| --- | --- | --- | --- |
| D1 | `bindDeviceToken` 的 `notifierName` 由必填改为可选 `String?`（breaking） | **保持 `required`** | 用户确认：4.25 需兼容，改可选会让存量 Dart 调用形态变化，且丢失编译期约束。iOS 侧本就忽略该参数（只读 `options.apnsCertName`），保持必填不影响功能。 |
| D2 | 删除 iOS wrapper 在 `bindDeviceToken` 中的 `options.apnsCertName = notifierName`，只认初始化选项 | **两者都支持**：初始化选项 `ChatOptions.apnsCertName` 为推荐入口；`bindDeviceToken` 传入的非空 `notifierName` 仍会写入，优先级更高 | 用户确认：照搬会让「只靠 `notifierName` 传证书名」的存量 iOS 应用升级后绑定失败（原生返回证书名为空），属 breaking。语义与 native 一致（native 也是绑定时读 `options`），零破坏。 |
| D3 | 未动 example | **新增 example 注册条目** | 用户确认：与仓库既有习惯一致（4.25.0 平版为 `fetchConversationsFromDB` 加过条目），便于人工验证。 |

### 2.2 iOS 证书名取值优先级（4.25.0）

`EMOptions.apnsCertName` 在 4.25.0 上共有 **3** 个来源，优先级从高到低：

1. `ChatPushManager.bindDeviceToken(notifierName:)` 传入的非空 `notifierName` —— 运行期写入（存量路径，`PushManagerWrapper.m`）；
2. `ChatOptions.apnsCertName` —— 初始化下发（本次新增的推荐入口，`OptionsHelper.m fromJson`）；
3. `ChatOptions.enableAPNs(certName)`（已废弃）经由 `pushConfig.apnsCertName` —— 初始化下发（`OptionsHelper.m:77` 既有路径）。

三者都为空时，原生在绑定时返回 `EMErrorUserIllegalArgument`（二进制字符串 `Apns cert name is NULL`）。`pushKitCertName` 只有第 2 类一个入口，为空时返回 `EMErrorUserIllegalArgument`（`pushkit cert name is NULL`）。

## 3. 未匹配清单

| id | 疑点 | 处理 |
| --- | --- | --- |
| UM-1 | Android 端无 PushKit 能力 | 沿用 5.0.0 结论：仅 iOS 支持，非 iOS 调用静默 no-op；Android 仍注册 route 并返回 `OPERATION_UNSUPPORTED`，以满足 `tool/ci/check_contracts.dart` 的三端 key + 路由契约。 |
| UM-2 | native 4 个 PushKit 方法为语义相同的同步/异步两对 | 沿用 5.0.0 结论：只暴露异步一对。 |
| UM-3 | `EMOptions.h:281/296` 注释称 `apnsCertName`/`pushKitCertName`「只能在 `initializeSDKWithOptions` 时设置」，而实现是在绑定 token 时读取 `options` 属性；4.25.0 因 D2 保留了运行期写入，与注释的差距比 5.0.0 更大 | 保留现状（兼容优先），已写入验收报告待决策项；native 注释修订属 emclient-ios 侧事项。 |
| UM-4 | `notifierName` 两端同名不同义（iOS 为证书名、Android 为厂商凭据） | 与 5.0.0 一致：不引入双路径，仅通过文档注明平台语义。 |
| UM-5 | 普通推送 token 只有绑定、没有解绑，PushKit 绑定/解绑成对 | 两者是独立能力，不合并入口。 |
| UM-6 | **本分支新增**：`OptionsHelper.m toJson` 回读未输出 `pushKitCertName`（`apnsCertName` 以 `pushConfig.apnsCertName` 嵌套形式输出） | 经 grep 实证该方法**无任何调用方**（`ClientWrapper.m` 不调用，`PushManagerWrapper.m:125/137` 用的是 `EMPushOptions` 的 `toJson`），属既存死代码；本次为「少即是稳」不动它，记入待决策。 |

## 4. 原生行为依据

验证介质：`https://download-sdk.oss-cn-beijing.aliyuncs.com/downloads/HyphenateChat4_25_0.zip`（由 `HyphenateChat_iOS` SPM tag `4.25.0` 的 `Package.swift` 声明），解包后 `ios-arm64/HyphenateChat.framework`。

```text
$ strings -a HyphenateChat | grep -E "^4\.25\.[0-9]$"
4.25.0
$ strings -a HyphenateChat | grep -i "cert name is NULL"
pushkit cert name is NULL
Apns cert name is NULL
bind device token failed, Apns cert name is NULL
$ otool -oV HyphenateChat | grep -i pushkit | sort -u
            attributes 0x9390e2 T@"NSString",C,N,V_pushKitCertName
            imp     0x460020 -[EMOptions pushKitCertName]
            imp     0x460028 -[EMOptions setPushKitCertName:]
            imp     0x494648 -[EMClient _rebindPushKitToken]
            imp     0x4946e4 -[EMClient _rebindPushKitTokenAfterDelay:]
            imp     0x4948f4 -[EMClient _resetBindPushKitTokenRetryTime]
            imp     0x4949d4 -[EMClient _bindPushKitToken]
            imp     0x4955e4 -[EMClient bindPushKitToken:]
            imp     0x4956e0 -[EMClient registerPushKitToken:completion:]
            imp     0x495894 -[EMClient unBindPushKitToken]
            imp     0x495ac8 -[EMClient unRegisterPushKitTokenWithCompletion:]
            name       0x93897b pushKitCertName
            name      0x938ebe _pushKitCertName
            name      0x93d556 _pushKitTokenLock
            name      0x93d5e4 _bindPushKitTokenRetryTime
            name      0x93d5ff _rebindPushKitTokenTimer
            name      0x93d618 _pushKitTokenBinded
```

结论：

- `registerPushKitToken:completion:` 与 `unRegisterPushKitTokenWithCompletion:` 在 4.25.0 中**真实存在**（`imp` 为方法实现地址），本次接线不依赖任何 5.0.0 独有符号。
- `_rebindPushKitToken` / `_rebindPushKitTokenAfterDelay:` / `_resetBindPushKitTokenRetryTime` / `_pushKitTokenBinded` 等私有符号表明：native 具备「登录后自动重绑 + 失败退避重试」逻辑，与 5.0.0 的 `05-pushkit.md` 记录一致，因此 Dart 文档中「未登录调用会缓存 token、登录后自动绑定」的说明成立。
- `pushkit cert name is NULL` / `Apns cert name is NULL` 证明证书名为空时原生返回非法参数错误，上层**不添加**判空兜底（符合 skill「不擅自添加过滤」规则）。
- ⚠️ 下载 zip 的 sha256 为 `c19b76fe…`，与 SPM `Package.swift` 中的 `checksum`（`aca47bc3…`）不同。两者算法口径不同（SPM 对解包内容做校验，非 zip 文件哈希），且 zip 未提供独立校验值可比对；本次以**包内 framework 自报版本 `4.25.0` + 头文件签名 + ObjC 实现符号**三重证据判定介质正确，checksum 口径差异记入待决策。

## 5. 跨端契约

| 契约要素 | 取值 | 落点 |
| --- | --- | --- |
| 初始化选项 key | `apnsCertName`、`pushKitCertName`（顶层，可选） | Dart `ChatOptions.toJson()` / iOS `OptionsHelper.fromJson` |
| 方法名 key | `bindPushKitToken` / `unbindPushKitToken` | `chat_method_keys.dart` / `MethodKeys.h` / `MethodKey.java`（三端逐字一致） |
| 路由注册 | iOS wrapper 实现；Android wrapper 注册同名 route 并返回 `EMError.OPERATION_UNSUPPORTED` | `PushManagerWrapper.m` / `PushManagerWrapper.java` |
| 请求参数 key | `bindPushKitToken`：`deviceToken`（十六进制字符串）；`bindDeviceToken`：`notifierName` + `deviceToken`（均必填，与 4.24.0 一致） | Dart 组装 / iOS + Android 读取 |
| 返回结构 | `wrapperCallBack` 包装为 `{<方法名>: nil}`，Dart 只取错误 | 与 `syncSilentModels` 等 object 为 nil 的路由一致 |
| 非 iOS 行为 | Dart 侧 `Platform.isIOS` 守卫，静默 no-op（不产生通道调用） | `chat_push_manager.dart` |
| Dart 公开 API | `Future<void> bindPushKitToken({required String deviceToken})` / `Future<void> unbindPushKitToken()` | `ChatPushManager` |

## 6. 实现落点

| 层 | 文件 | 改动 |
| --- | --- | --- |
| Dart 选项 | `im_flutter_sdk/lib/src/models/chat_options.dart` | 新增 `apnsCertName` / `pushKitCertName`（双语注释 + 可选字段）：三个公开构造函数、私有 `_()`、`toJson()`（`// 4.25.0` 段内）全部打通；**未加入 `copyWith` 形参**，由 `copyWith` 内部从 `this` 透传，体现「运行中不可变」 |
| Dart 常量 | `im_flutter_sdk/lib/src/internal/chat_method_keys.dart` | 新增 `bindPushKitToken` / `unbindPushKitToken`（`// 4.25.0`） |
| Dart API | `im_flutter_sdk/lib/src/managers/chat_push_manager.dart` | 新增 `bindPushKitToken({required String deviceToken})` / `unbindPushKitToken()`（双语注释 + `Platform.isIOS` 守卫）；`bindDeviceToken` 双语注释补充两端语义（Android 凭据必填 / iOS 证书名及优先级） |
| iOS 选项 | `im_flutter_sdk_ios/.../OptionsHelper.m` | `fromJson` 读取 `apnsCertName` / `pushKitCertName` 写入 `EMOptions`（带 null 判断，**缺失时不赋值**，以保留 `pushConfig.apnsCertName` 这条已废弃 setter 路径） |
| iOS 常量 | `im_flutter_sdk_ios/.../include/im_flutter_sdk_ios/MethodKeys.h` | 新增 2 个常量（`// 4.25.0`） |
| iOS 实现 | `im_flutter_sdk_ios/.../PushManagerWrapper.m` | 新增 2 条路由 + 2 个实现（`#pragma mark - 4.25.0`）；`bindDeviceToken` 的运行期写入加 `notifierName.length > 0` 守卫（D2），并注明三个来源的优先级 |
| Android | `MethodKey.java`、`PushManagerWrapper.java` | 新增 `bindPushKitToken` / `unbindPushKitToken` 常量（`// 4.25.0`）与两条 route；Android 无 PushKit API，统一返回 `EMError.OPERATION_UNSUPPORTED`（"PushKit is only supported on iOS"），Dart 守卫使其正常不可达，保留注册是为满足跨端契约 |
| example | `im_flutter_sdk/example/lib/registry/apis/push_apis.dart`（新增）、`registry/registry.dart` | 新增 push 分组与 3 条条目（`bindDeviceToken` / `bindPushKitToken` / `unbindPushKitToken`），在 `apiRegistry` 注册 |
| 版本校验器（用户裁决衍生） | `im_flutter_sdk/tool/ci/version_checker.dart`、`check_versions.dart`、`test/ci/version_checker_test.dart` | 版本比对统一为「只比 `major.minor`，忽略 patch」：四包严格相等、iOS 两条集成路径 major.minor 相同、podspec `s.version` 按 major.minor 跟随包版本；补 6 个单测；输出文案同步改写 |
| skill 门禁（用户裁决衍生） | 工作区 `.agents/skills/platform-sdk-porting-v2/hooks/porting_guard.sh`、`references/flutter.md`、`references/known-issues.md` | gate 规则改为忽略 patch 的 major.minor 比对 + Android 依赖与包版本同线；规则写入 flutter.md bump 小节与自检清单；KI-101 限定故障面、新增 KI-113 |

实现说明：

- **token 传参**：Dart 传十六进制字符串，iOS 侧照既有 APNs 路径（`bindFCMToken:`）的方式把字符串交给原生的 `_extractTokenFromRawData:`（同时兼容 `NSData` 与 `NSString`）。未在 wrapper 内做 hex → `NSData` 转换，以避免走 `NSData` 分支的固定 8×4 字节读取。
- **未添加上层判空**：证书名为空由原生返回 `EMErrorUserIllegalArgument`，与既有 `bindDeviceToken` 行为一致，不擅自在上层加过滤。
- **接口包无改动**：`im_flutter_sdk_interface` 只提供通道抽象、无方法名常量，本次不涉及。
- **版本注释**：按仓库惯例标为 `// 4.25.0`（与 `docs/porting/4.25.0/` 目录及四包版本号一致）；若最终以 4.25.1 发布，需同步调整代码注释与 CHANGELOG 版本头（见 §9 待决策 1）。

## 7. 文档更新

- `im_flutter_sdk/CHANGELOG.md`：`## 4.25.0` 段新增 `ChatOptions.apnsCertName`/`pushKitCertName` 与两个 PushKit 接口条目。
- `im_flutter_sdk_ios/CHANGELOG.md`：新增 PushKit 路由、`OptionsHelper` 证书名映射、`bindDeviceToken` 证书名优先级三条。
- `im_flutter_sdk_android/CHANGELOG.md`：新增 iOS-only 方法名 key 注册条目。
- `im_flutter_sdk_interface/CHANGELOG.md`：本次无改动，不加条目。
- 四包 `pubspec.yaml` 版本号保持 `4.25.0`（与 §9 待决策 1 关联）。
- 工作区 `docs/PROGRESS.md` 登记一行。

## 8. 验证记录

| 验证项 | 命令 | 结果 |
| --- | --- | --- |
| Dart 格式化 | `dart format lib/src/models/chat_options.dart lib/src/managers/chat_push_manager.dart lib/src/internal/chat_method_keys.dart example/lib/registry/registry.dart example/lib/registry/apis/push_apis.dart` | ✅ 无改动（已符合格式） |
| 主包静态检查 | `cd im_flutter_sdk && flutter analyze --fatal-infos` | ✅ No issues found（Flutter 3.47.0 / Dart 3.13.0） |
| example 静态检查 | `cd im_flutter_sdk/example && flutter analyze --fatal-infos` | ✅ No issues found |
| 契约检查（CI 同款） | `cd im_flutter_sdk && dart run tool/ci/check_contracts.dart ..` | ✅ MethodChannel contracts are consistent. |
| 版本检查（CI 同款） | `dart run tool/ci/check_versions.dart ..` | ✅ Flutter 4.25.0 / Android Native 4.25.1 / iOS Native 4.25.0 |
| 用例映射检查 | `dart run tool/ci/check_case_mapping.dart .` | ✅ Native-to-Flutter case mapping is valid. |
| 三端方法名 key 逐字比对 | grep Dart / `MethodKeys.h` / `MethodKey.java` | 见 §8.1 |
| 初始化选项 key 比对 | Dart `toJson()` ↔ `OptionsHelper.fromJson` | 见 §8.2 |
| iOS 编译 | `cd im_flutter_sdk/example && flutter build ios --debug --no-codesign` | 见 §8.3 |
| Android 编译 | `cd im_flutter_sdk/example && flutter build apk --debug` | 见 §8.4 |
| porting gate | `echo '{}' \| bash <skill>/hooks/porting_guard.sh gate flutter .` | 见 §8.5 |
| 端到端 VoIP 推送 | 需真机 + PushKit 证书 + 应用侧 `PKPushRegistry` | ⏭️ 当前环境不具备（example 无 `PKPushRegistry`，无法产生真实 PushKit token） |

### 8.1 三端方法名 key 逐字比对

```text
$ grep -n "bindPushKitToken\|unbindPushKitToken" im_flutter_sdk/lib/src/internal/chat_method_keys.dart
428:  static const String bindPushKitToken = 'bindPushKitToken';
429:  static const String unbindPushKitToken = 'unbindPushKitToken';
$ grep -n "bindPushKitToken\|unbindPushKitToken" im_flutter_sdk_ios/.../include/im_flutter_sdk_ios/MethodKeys.h
390:static NSString *const bindPushKitToken = @"bindPushKitToken";
391:static NSString *const unbindPushKitToken = @"unbindPushKitToken";
$ grep -n "bindPushKitToken\|unbindPushKitToken" im_flutter_sdk_android/.../MethodKey.java
368:    static final String bindPushKitToken = "bindPushKitToken";
369:    static final String unbindPushKitToken = "unbindPushKitToken";
$ grep -n "MethodKey.bindPushKitToken\|MethodKey.unbindPushKitToken" im_flutter_sdk_android/.../PushManagerWrapper.java
95:            else if (MethodKey.bindPushKitToken.equals(call.method)) {
98:            else if (MethodKey.unbindPushKitToken.equals(call.method)) {
$ grep -n "bindPushKitToken\|unbindPushKitToken" im_flutter_sdk_ios/.../PushManagerWrapper.m
106:    else if([bindPushKitToken isEqualToString:call.method]) {
109:    else if([unbindPushKitToken isEqualToString:call.method]) {
430:- (void)bindPushKitToken:(NSDictionary *)param
450:- (void)unbindPushKitToken:(NSDictionary *)param
```

✅ 三端 key 值与名称逐字一致，两端路由均注册（Android 路由已在 §8.4 的 dex 中实证）。

### 8.2 初始化选项 key 比对与运行期写入守卫

```text
$ grep -n "apnsCertName\|pushKitCertName" im_flutter_sdk/lib/src/models/chat_options.dart | grep putIfNotNull
1666:    data.putIfNotNull('apnsCertName', apnsCertName);
1667:    data.putIfNotNull('pushKitCertName', pushKitCertName);
$ grep -n "apnsCertName\|pushKitCertName" im_flutter_sdk_ios/.../OptionsHelper.m
 77:    options.apnsCertName = aJson[@"pushConfig"][@"apnsCertName"];      // 已废弃 setter 路径（既有）
119:    if (aJson[@"apnsCertName"] && ![aJson[@"apnsCertName"] isKindOfClass:[NSNull class]]) {
120:        options.apnsCertName = aJson[@"apnsCertName"];                  // 本次新增
122:    if (aJson[@"pushKitCertName"] && ![aJson[@"pushKitCertName"] isKindOfClass:[NSNull class]]) {
123:        options.pushKitCertName = aJson[@"pushKitCertName"];            // 本次新增
$ grep -n "options.apnsCertName\s*=\|options.pushKitCertName\s*=" im_flutter_sdk_ios/.../*.m
OptionsHelper.m:77 / OptionsHelper.m:120 / OptionsHelper.m:123
PushManagerWrapper.m:415:        EMClient.sharedClient.options.apnsCertName = notifierName;
```

✅ Dart 与 iOS 的 key 逐字一致；运行期写入仅剩 `PushManagerWrapper.m:415` 一处，且处于 `notifierName.length > 0` 守卫内（D2），不存在无守卫的运行期覆盖。

### 8.3 iOS 构建结果

```text
$ cd im_flutter_sdk/example && flutter build ios --debug --no-codesign
Warning: Building for device with codesigning disabled. You will have to manually codesign before deploying to device.
Building com.example.example for device (ios)...
Running pod install...                                           1,453ms
Running Xcode build...
Xcode build done.                                           41.5s
✓ Built build/ios/iphoneos/Runner.app
ios_build_exit=0
```

前置：`pod install` 首次失败（`Podfile.lock` 快照仍为 `HyphenateChat 4.24.1`，与 podspec 的 4.25.0 冲突），执行 `pod update HyphenateChat` 后装载 `HyphenateChat (4.25.0)` 通过。

产物校验（证明新增 ObjC 代码确实编进了二进制，而不仅是「构建通过」）：

```text
$ strings -a build/ios/iphoneos/Runner.app/Frameworks/im_flutter_sdk_ios.framework/im_flutter_sdk_ios \
    | grep -iE "pushkitcertname|apnscertname|bindpushkit|unbindpushkit|registerpushkit|unRegisterPushKit" | sort -u
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

其中 `bindPushKitToken:channelName:result:` / `unbindPushKitToken:channelName:result:` 为本次新增的 wrapper 方法；`setApnsCertName:` / `setPushKitCertName:` 来自 `OptionsHelper.fromJson` 的初始化赋值；`registerPushKitToken:completion:` / `unRegisterPushKitTokenWithCompletion:` 为接线调用的原生 API（与 §4 的 native 符号一致）。

### 8.4 Android 构建结果

```text
$ cd im_flutter_sdk/example && flutter build apk --debug
Running Gradle task 'assembleDebug'...                             77.4s
✓ Built build/app/outputs/flutter-apk/app-debug.apk
apk_exit=0
```

仅有仓库既有的 Java 8 / deprecation / unchecked 警告，无错误。

产物校验（证明新增 route 确实编进了 dex）：

```text
$ for d in $(unzip -l build/app/outputs/flutter-apk/app-debug.apk | awk '/classes.*\.dex/{print $4}'); do
    unzip -p build/app/outputs/flutter-apk/app-debug.apk $d | strings -a | grep -E "PushKit"; done | sort -u
 PushKit is only supported on iOS
bindPushKitToken
unbindPushKitToken
unsupportedPushKit
```

三个字符串齐全，说明常量、两条 route 分支与 `unsupportedPushKit` 错误分支均已编译进包。

### 8.5 单元测试

```text
$ cd im_flutter_sdk && flutter test
00:00 +28: All tests passed!
test_exit=0
```

（28 个用例全部通过，与本次改动前一致。）

### 8.5.1 公开 API 文档注释可生成

```text
$ bash im_flutter_sdk/scripts/gen-apidoc.sh cn
Found 36 warnings and 0 errors.
Documented 2 public libraries in 21.2 seconds
Success! Docs generated into .../im_flutter_sdk/output/apidoc-cn
apidoc_exit=0
```

0 errors；36 条 warning 全部来自既有文件（`conversation_fetch_options.dart` 等的 `[1,50]` 类误判引用），本次新增的双语注释未产生新 warning。生成产物 `im_flutter_sdk/output/`（已 gitignore）验证后已删除。

### 8.6 porting gate

命令：`echo '{}' | bash /Users/asterisk/Codes/zuoyu_flutter/.agents/skills/platform-sdk-porting-v2/hooks/porting_guard.sh gate flutter .`（cwd = worktree 根）

```text
$ echo '{}' | bash .../hooks/porting_guard.sh gate flutter .
gate_exit=0
```

无输出 = 通过。

**首次运行曾被 block，按用户裁决改为修检查脚本（而非改依赖版本）**：

- 首次输出：`{"decision": "block", "reason": "…native 依赖版本不一致: podspec:4.25.0  Package.swift:4.25.0  gradle:4.25.1 ；"}`
- 证据：差异由 `d1615120 chore: update android sdk version to 4.25.1` 引入，本次未触碰任何依赖声明（`git status` 无 build.gradle/podspec/Package.swift；`git show HEAD:` 三处现状即 4.25.0/4.25.0/4.25.1）。
- 用户裁决（2026-09-24）：**依赖项版本不必与包版本一致，至少最后一位不必一致；要保证的是四个包的版本强一致性**。需要修改的是检查脚本。
- 用户追加裁决（2026-09-24，第二轮）：**iOS 也忽略最后一位**——假如 iOS 依赖是 4.25.1、四包仍是 4.25.0，不能报错；**Android 不是整体忽略，是忽略最后一位，只要保证是 4.25.x 就行**。即统一口径为「比 `major.minor`，忽略 patch」。
- 落地改动（按最终口径）：
  - `hooks/porting_guard.sh`（工作区 skill 资产）gate 规则改为「**版本比对一律忽略最后一位**」，具体三条：① 四包 pubspec 版本严格相等（不看 minor）；② iOS podspec `HyphenateChat` 与 Package.swift `exact:` 的 **major.minor** 相同；③ Android native 依赖与包版本的 **major.minor** 相同（包 4.25.x ⇒ 依赖必须 4.25.y）；另外 podspec `s.version` 也按 major.minor 跟随包版本。实现为 `minor_of()` 辅助函数（`cut -d. -f1,2` 后去重）。
  - `im_flutter_sdk/tool/ci/version_checker.dart`（仓库 CI，`run_quality.sh` → `check_versions.dart`）同步实现同一口径（`_sameMajorMinor`/`_majorMinor`），并补 6 个单测。
- 规则精准性验证（临时 fixture，已删除）——7 个场景全部符合预期：

```text
现状：包 4.25.0 / iOS 依赖 4.25.0 / Android 依赖 4.25.1          → 放行 exit=0
用户场景：包 4.25.0 / iOS 依赖两处同步升 4.25.1 / Android 4.25.1  → 放行 exit=0
包 4.25.0 / iOS 依赖 4.25.1 / podspec s.version=4.25.1            → 放行 exit=0（忽略最后一位）
iOS 两处 minor 漂移：podspec 4.25.1 vs SPM 4.24.1                 → block（iOS 两条集成路径 major.minor 不一致）
Android 依赖掉到 4.24.x                                          → block（与包版本不在同一 major.minor 线）
podspec s.version 掉到 4.24.0                                    → block（与包版本不在同一 major.minor 线）
四包版本不一致（4.24.0 vs 4.25.0）                                → block（各包 pubspec 版本不一致）
```

- 规则已沉淀：skill `references/flutter.md`（bump 小节 + 验证自检清单）、`references/known-issues.md`（KI-101 限定故障面为 iOS 内部 major.minor 漂移；KI-113 记录本次误报与裁决口径）。
- 实现期间的脚本 bug（已修）：`PROBLEMS+=(... "$pub_minor）...")` 中变量名后紧跟全角 `）`，bash 在 UTF-8 下把变量名吃进后半字节导致 `unbound variable`；已加空格分隔，并全量自查同模式（0 命中）。

### 8.7 版本校验器输出（改动后）

```text
$ cd im_flutter_sdk && dart run tool/ci/check_versions.dart ..
Versions are consistent: Flutter 4.25.0 (four packages identical, podspec on the same major.minor line),
iOS Native 4.25.0 (podspec and Package.swift on the same major.minor line),
Android Native 4.25.1 (independently released, patch digit ignored).
versions_exit=0
$ flutter test test/ci/version_checker_test.dart
00:00 +7: All tests passed!   # 含「忽略最后一位」「同一 major.minor 不同 patch」两个放行用例
```


## 9. 决策结果与遗留项

### 9.1 已裁决（2026-09-24，用户）

1. ~~发布版本号~~ → **不升版本**：4.25.0 尚未发布，继续用 `4.25.0`。四包 pubspec、三份 CHANGELOG 版本头、代码内 `// 4.25.0` 注释、`docs/porting/4.25.0/` 目录名全部不变。
2. ~~native 依赖版本差异~~ → **依赖版本不动**：`im_flutter_sdk_ios` 与 `im_flutter_sdk_android` 的包版本都是 4.25.0，Android 的 native 依赖确实是 4.25.1，这是允许的；依赖项版本不必与包版本一致（至少最后一位不必一致）。要保证的是**四个包的版本强一致性**。需要修改的是检查脚本 → 见 8.6（`porting_guard.sh` 收窄规则 + `check_versions.dart` 新增 iOS 双路径校验）。
3. ~~`example/ios/Podfile.lock` 是否随本次提交~~ → **需要刷新**：HEAD 里的 lock 停在 `HyphenateChat 4.24.1` / `im_flutter_sdk_ios 4.24.0`，与 pubspec/podspec 的 4.25.0 不一致，属既有陈旧状态；本次刷新为 4.25.0 正确，随本次改动一起提交（连带 `ShengwangInfra_iOS` 1.3.5→1.3.16）。

### 9.2 仍待决策

1. **4.25.0 与 5.0.0 的 API 形态差异（D1/D2）**：4.25.0 保留 `notifierName` 必填与 iOS 运行期证书名写入，5.0.0 已改为可选 + 仅初始化配置。两分支长期并存时需确认这是预期差异，若希望 4.25 最终也收敛到 5.0.0 形态，应在一个明确的大版本窗口内做。
2. **native 注释与实现的差距**：`EMOptions.h:281/296` 称证书名「只能在 `initializeSDKWithOptions` 时设置」，实现却是绑定时读 `options`；4.25 因 D2 保留运行期写入后，差距比 5.0.0 更大。是否在 emclient-ios 侧修订注释或实现，属 native 侧事项。
3. **`OptionsHelper.m toJson` 的 `pushKitCertName` 缺席**：该方法经 grep 证实无调用方（死代码），本次按「少即是稳」未动；是否顺手补齐或直接删除该方法请裁决。
4. **example 的 `PKPushRegistry`**：当前 example 未实现 `PKPushRegistry`，注册条目只能手填 token，无法端到端自测 VoIP 推送。是否需要在 example 里补一段 `PKPushRegistry` 接入（工作量与验证价值需权衡）。
5. **下载介质 checksum 口径**：`HyphenateChat4_25_0.zip` 的 sha256 与 SPM `Package.swift` 的 `checksum` 不同（口径差异，见 §4 注）。如你手上有该版本的官方 sha256，可提供以便二次确认介质。

