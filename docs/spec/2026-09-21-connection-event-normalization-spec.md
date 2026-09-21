# 连接事件归一化规格（ConnectionEventHandler）

日期：2026-09-21
状态：已实施（5.0.0 分支工作区，未提交），静态与构建验证见 §9
目标仓库：`/Users/asterisk/Codes/zuoyu_flutter/im_flutter_sdk/.worktree/5.0.0`，分支 `5.0.0`
关联文档：`../porting/5.0.0/02-contract.md`（5.0.0 冻结契约）、`../porting/5.0.0/04-verification.md`（平版验证记录）

## 1. 背景与问题

`ConnectionEventHandler` 目前把「与服务器断开」拆成 9 个回调：一个无参的 `onDisconnected`，加 8 个按原因命名的回调（`onUserDidLoginFromOtherDevice`、`onUserDidRemoveFromServer`、`onUserDidForbidByServer`、`onUserDidChangePassword`、`onUserDidLoginTooManyDevice`、`onUserKickedByOtherDevice`、`onUserAuthenticationFailed`、`onAppActiveNumberReachLimit`）。

现状缺陷：

| 编号 | 问题 | 位置 |
| --- | --- | --- |
| S1 | 事件通道分散：一类原因一个回调，接入方需逐个实现，漏接即丢事件 | `im_flutter_sdk/lib/src/handlers/manager_event_handler.dart:41-281` |
| S2 | 参数被丢弃：Dart 层收到事件却不解析原生传入的参数，原因码无处可查 | `im_flutter_sdk/lib/src/managers/chat_client.dart:82-86` |
| S3 | 转发层缺陷：`_onUserAuthenticationFailed()` 误转发为 `onDisconnected`，该原因被吞掉且伪造一次断开 | `chat_client.dart:124-128` |
| S4 | iOS 侧强制下线回调漏映射活跃数上限（code 8），该原因在 iOS 上收不到 | `im_flutter_sdk_ios/.../ClientWrapper.m:599-614` |
| S5 | iOS 侧 `activeNumbersReachLimitation` 在 5.0 平台头文件中已不存在，属死代码 | `ClientWrapper.m:531-533` |
| S6 | 附加信息序列化对空值不设防；Dart 侧对事件参数使用强制解包 | `LoginExtensionInfoHelper.m:10-17`、`chat_client.dart:27-29` |
| S7 | 监听器句柄清理规则与原因码不对应（206、8、213 不清理） | `im_flutter_sdk_android/.../ClientWrapper.java:441-472` |
| S8 | Android 侧用魔法数字判断原因码，未使用平台的错误码常量 | `ClientWrapper.java:440-490` |

由此产生两个业务问题：

1. **接入方难以判断「我是否被登出了」**。判断退出的依据散落在多个回调里，且缺少文档化的原因码。
2. **原因码没有透出**。即使原生携带了原因码，接入方也拿不到，无法做分支处理或上报。

## 2. 目标与非目标

目标：

- 断开事件收敛为**单一通道**，携带原因码与附加信息。
- 原因码**原样透传**：原生新增、调整原因码时，本 SDK 与接入方无需改动即可收到。
- 明确区分「退出」与「断开」，给出可照抄的退出码表与双通道说明。
- 修掉 §1 的 S2~S8（S1 由本次收敛解决）。

非目标：

- 不改变平台 SDK 的断开行为、重连策略与登出时机。
- **不在 SDK 内部判定「是否需要重新登录」**：判定权交给接入方，依据是本规格 §5 的码表。SDK 只保证码原样送达。
- 不引入连接状态机、不新增连接状态查询 API。

## 3. 术语

| 术语 | 含义 |
| --- | --- |
| 断开（disconnect） | 与服务器的连接中断。SDK 会自动重连，用户通常仍处于登录态 |
| 退出（logout） | 本地登录态失效，必须重新登录。接入方通常需要回到登录页/首页 |
| 原因码（errorCode） | 断开原因，数值与平台 SDK 的 `EMError` 一致 |
| 附加信息（info） | 仅「他端登录」场景携带：踢下线的设备名与扩展信息 |

**断开与退出是两件事**：退出时**会**先产生一次断开事件（token 过期除外，见 §5.2），但断开事件不代表退出。

## 4. 事件契约

### 4.1 Dart 公开 API

```dart
class ConnectionEventHandler {
  final VoidCallback? onConnected;

  /// ~english
  /// Occurs when the SDK disconnects from the chat server.
  ///
  /// Param [errorCode] The reason code, identical to the platform SDK's `EMError`
  /// values. It is `null` when the platform provides no reason.
  ///
  /// Param [info] Present only for the reason code 206.
  /// ~end
  ///
  /// ~chinese
  /// 与 chat 服务器断开连接时触发的回调。
  ///
  /// Param [errorCode] 断开原因码，与平台 `EMError` 数值一致；平台未给出原因时为 `null`。
  ///
  /// Param [info] 仅原因码 206 携带。
  /// ~end
  final void Function(int? errorCode, LoginExtensionInfo? info)? onDisconnected;

  // 其余回调保持不变（onTokenWillExpire / onTokenDidExpire /
  // onOfflineMessageSyncStart / onOfflineMessageSyncFinish /
  // onDataSyncStart / onDataSyncFinish / onDatabaseOpened）
}
```

> 实现时上述注释需按 §7.4 补全：原因码语义、退出码表、双通道、`null` 语义、平台差异。

### 4.2 MethodChannel 负载

事件 key：`onDisconnected`（Dart `ChatMethodKeys` / Android `MethodKey.java` / iOS `MethodKeys.h` 三处逐字一致）。

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `errorCode` | int | 否 | 原因码；缺省表示平台未给出原因 |
| `deviceName` | String | 否 | 仅原因码 206 携带 |
| `ext` | String | 否 | 仅原因码 206 携带 |

Dart 侧组装规则：当且仅当 `deviceName` 为非空字符串时构造 `LoginExtensionInfo`，否则 `info` 为 `null`；`ext` 允许为空。

### 4.3 iOS：回调折算为原因码

iOS 通过不同回调表达断开原因，wrapper 按下表折算（读取平台信息，不改写）：

| iOS 回调 | 折算 `errorCode` | `info` |
| --- | --- | --- |
| `userAccountDidLoginFromOtherDeviceWithInfo:` | `206` | 透传 `deviceName` / `ext` |
| `userAccountDidRemoveFromServer` | `207` | — |
| `userDidForbidByServer` | `305` | — |
| `userAccountDidForcedToLogout:` | `aError.code` 原样透传 | — |
| `connectionStateDidChange:`（断开） | `null`（平台未提供原因） | — |
| `tokenDidExpire:` | 不产生本事件，走 `onTokenDidExpire` | — |

约定：

- **`userAccountDidForcedToLogout:` 不写原因码白名单**：`aError.code` 原样透传，平台新增原因码时自动生效。
- `aError` 为空时仍发出一次 `onDisconnected`，`errorCode` 为 `null` 并记录日志，保持「该回调必产生一次事件」的不变量。
- iOS 上 `206` 与 `220` 使用同一回调，折算为 `206`；两种原因都属于退出，差异仅影响提示文案。

### 4.4 Android：透传与 206 合并

- `onDisconnected(int errorCode)`：`errorCode` **原样透传**，不做映射、不做过滤。
- `onLogout(int errorCode, EMLoginExtensionInfo info)`：仅当 `errorCode == 206` 时用于补齐 `deviceName` / `ext`，与上一条的 206 **合并为同一次事件**（避免同一次强制下线产生两个事件）。`info` 需判空。
- 原因码判断使用 `EMError.*` 常量，禁止魔法数字。

### 4.5 删除项

公开 API 删除 8 个回调；三端同步删除对应的 8 个事件 key：

```text
onUserDidLoginFromOtherDevice
onUserDidRemoveFromServer
onUserDidForbidByServer
onUserDidChangePassword
onUserDidLoginTooManyDevice
onUserKickedByOtherDevice
onUserAuthenticationFailed
onAppActiveNumberReachLimit
```

同时删除 iOS wrapper 的 `activeNumbersReachLimitation`（S5）。

### 4.6 不变项

`onConnected`、`onTokenWillExpire`、`onTokenDidExpire`、`onOfflineMessageSyncStart/Finish`、`onDataSyncStart/Finish`、`onDatabaseOpened` 的签名、key 与行为均不变。

## 5. 业务规则

### 5.1 退出码表（走 `onDisconnected`）

以下原因码表示**本地登录态已失效，接入方应回到登录页/首页**：

```text
8    APP_ACTIVE_NUMBER_REACH_LIMITATION   应用活跃数达到上限
104  INVALID_TOKEN                        token 与登录信息不匹配
110  INVALID_PARAM                        连接参数错误
204  USER_NOT_FOUND                       用户不存在
206  USER_LOGIN_ANOTHER_DEVICE            账号在其他设备登录
207  USER_REMOVED                         账号已被删除
213  USER_BIND_ANOTHER_DEVICE             账号已绑定其他设备
214  USER_LOGIN_TOO_MANY_DEVICES          登录设备数超限
216  USER_KICKED_BY_CHANGE_PASSWORD       密码已修改
217  USER_KICKED_BY_OTHER_DEVICE          账号被其他设备踢下线
220  USER_DEVICE_CHANGED                  登录设备变更，需重新登录
304  SERVER_GET_DNSLIST_FAILED            无可用服务器
305  SERVER_SERVING_DISABLED              服务被禁用
```

判定依据是平台 SDK 是否执行了登出，不是「原因码是否为 2」。**该表由平台行为决定，不是本 SDK 的推断**；平台调整时会同步更新本规格。

### 5.2 退出还有第二个通道：`onTokenDidExpire`

**token 过期同样是退出**（原因码 `108 TOKEN_EXPIRED`），但它**不会**触发 `onDisconnected`，只触发 `onTokenDidExpire`。

> 因此「退出」共有两个事件通道：`onDisconnected(退出码表内的码)` 与 `onTokenDidExpire()`。只监听其中一个会漏场景，接入方必须两个都处理。

### 5.3 非退出码

以下原因码只表示连接层问题，**用户仍在登录态，不需要回到登录页**；SDK 会自动重连：

```text
2    NETWORK_ERROR          网络不可用
4    EXCEED_SERVICE_LIMIT   注册数超限
300  SERVER_NOT_REACHABLE   连接超时 / DNS 失败 / 连接被拒
303  SERVER_UNKNOWN_ERROR   IO 错误 / 流错误
306  SERVER_DECRYPTION_FAILED  传输解密失败
```

未在 §5.1 与 §5.2 中出现的原因码（含平台后续新增的码）一律按「非退出」处理，接入方可自行决定是否上报。

> **注意**：平台在弱网下的常见原因码是 `300` / `303`，而不是 `2`。禁止用「原因码不等于 2 即视为强制下线」这类规则判断退出。

### 5.4 `errorCode == null` 的语义

表示**平台未提供断开原因**。接入方：

- **不要**据此判定为网络断开，也**不要**据此跳转登录页；
- 按「连接层事件」处理即可；如需确认登录态，使用 `ChatClient.isConnected()` 或后续 API 的未登录错误兜底。

### 5.5 时序约定

退出场景下平台是**先派发事件、后完成登出**，且事件为异步派发。因此**事件回调执行时登录态可能尚未或已经翻转**：

- 不要在 `onDisconnected` / `onTokenDidExpire` 内部依赖登录态来做判断；
- 不要在这些回调里发起需要登录态的 API 调用（可能成功也可能失败）。

### 5.6 平台差异（对使用方的承诺）

| 差异 | 对本 SDK 的影响 | 使用方处理 |
| --- | --- | --- |
| iOS 通用断开回调不携带原因码 | `errorCode` 为 `null` | 按 §5.4 |
| iOS 的 206 与 220 共用回调 | 统一折算为 `206` | 两种都是退出，主流程一致 |
| Android 弱网常见码为 `300`/`303` | 原样透传 | 不要用 `!= 2` 判定退出 |
| `8` / `213` 在两端可达性不同 | 原样透传或为 `null` | 以实际收到的码为准，不要按平台硬编码 |
| iOS App 切后台会产生一次断开 | 表现为 `errorCode == null`，回前台自动 `onConnected` | 按 §5.4，无需处理 |

## 6. 使用方接入规格

```dart
/// 收到这些原因码表示已被登出，需要回到登录页/首页。
/// 来源：本规格 §5.1（由平台登出行为决定）。
static const Set<int> kDisconnectLogoutCodes = <int>{
  8, 104, 110, 204, 206, 207, 213, 214, 216, 217, 220, 304, 305,
};

ChatClient.getInstance.addConnectionEventHandler(
  'app',
  ConnectionEventHandler(
    onConnected: () => setConnecting(false),
    onDisconnected: (errorCode, info) {
      if (errorCode != null && kDisconnectLogoutCodes.contains(errorCode)) {
        // 已被登出
        if (errorCode == ChatDisconnectErrorCode.userLoginFromOtherDevice) {
          showKickedByDevice(info?.deviceName);
        }
        backToLogin();
        return;
      }
      // 其余情况：连接层事件，SDK 会自动重连，无需跳转
      setConnecting(true);
    },
    onTokenDidExpire: () {
      // 同样是退出，见 §5.2
      backToLogin();
    },
  ),
);
```

## 7. 实现规格

### 7.1 Dart

| 文件 | 改动 |
| --- | --- |
| `lib/src/internal/chat_method_keys.dart` | 删 8 个事件 key，保留 `onDisconnected` |
| `lib/src/managers/chat_client.dart` | 分发改为 `_onDisconnected(argMap)`；解析 `errorCode` 并按 §4.2 组装 `info`；删 8 个转发方法（含 S3） |
| `lib/src/handlers/manager_event_handler.dart` | 删 8 个字段；`onDisconnected` 改新签名；中英双语注释写明 §5 规则 |
| `lib/src/models/chat_disconnect_error_code.dart` | 新增，`abstract final class` + `static const int`，值 = 平台 `EMError`；**仅供可读性与日志，SDK 内部不用它做判定** |
| `lib/im_flutter_sdk.dart` | 导出上述新文件 |
| `lib/src/models/login_extension_info.dart` | `fromJson` 不再对缺失字段做强断言（S6 的 Dart 侧） |

### 7.2 Android wrapper

| 文件 | 改动 |
| --- | --- |
| `ClientWrapper.java` | `onDisconnected(int)` 原样透传并按退出码表清理监听器句柄；`onLogout(int, info)` 仅处理 206 并合并 `deviceName`/`ext`、判空；魔法数字改 `EMError.*`（S7、S8） |
| `MethodKey.java` | 删 8 个事件 key |

### 7.3 iOS wrapper

| 文件 | 改动 |
| --- | --- |
| `ClientWrapper.m` | 新增 `emitDisconnectedWithCode:params:` 统一出口；按 §4.3 折算表接线；`forcedToLogout` 原样透传原因码（补上 S4 的 8）；`connectionStateDidChange:` 断开发 `null`；删 `activeNumbersReachLimitation`（S5） |
| `MethodKeys.h` | 删 8 个事件 key |
| `LoginExtensionInfoHelper.m` | 空值保护（S6） |

### 7.4 文档注释要求

`onDisconnected` 的中英双语注释必须写明：原因码语义、§5.1 退出码表、§5.2 双通道、§5.4 `null` 语义、§5.6 平台差异。

### 7.5 监听器句柄清理规则

命中 §5.1 退出码表时清理（对 Android 即 `ListenerHandle.clearHandle()`）；网络类断开（§5.3）不清理。
该判定仅用于 SDK 内部资源清理，**不对外暴露语义**。

### 7.6 其他

- `CHANGELOG`：主包记录 breaking（删 8 个回调 + 新签名 + 新增常量组）；android / ios 包按各自 wrapper 改动记录。
- `example/lib/listeners.dart` 同步改造，并按 §6 给出可直接复制的退出码表示例。
- `tool/ci/contract_checker.dart`：删 key 后应自动通过，无需改动。

## 8. 迁移规格（breaking）

| 原用法 | 新用法 |
| --- | --- |
| 实现 8 个原因回调中的任意一个 | 在 `onDisconnected` 内按 `errorCode` 分支 |
| `onUserDidLoginFromOtherDevice(info)` | `errorCode == 206`，读第二个参数 `info` |
| 用 `onDisconnected()` 判断网络断开 | `onDisconnected(errorCode, info)`，`errorCode` 为 `null` / `2` / `300` / `303` / `306` 时按连接事件处理 |
| 只监听 `onDisconnected` 判断退出 | 还需监听 `onTokenDidExpire`（§5.2） |

## 9. 验收标准

- [x] `ConnectionEventHandler` 仅保留一个断开回调，签名为 `(int? errorCode, LoginExtensionInfo? info)`
- [x] 8 个旧回调与 8 个事件 key 在 Dart / Java / ObjC 三处全部删除，`contract_checker` 通过
- [x] 单测覆盖：原因码原样透传、206 携带 info、无码时为 `null`、负载缺字段不抛异常（`im_flutter_sdk/test/handlers/connection_event_test.dart`，6 个用例）
- [x] `flutter analyze`、`flutter test` 通过
- [ ] 真机验证 206：`example` 的 `kickDevice` 步骤触发他端登录，收到 `errorCode == 206` 且 `info.deviceName` 非空
- [ ] 真机验证弱网：断开时 Android 收到原因码而非无码事件，用户未被登出
- [ ] 真机验证 token 过期：只收到 `onTokenDidExpire`，未收到 `onDisconnected`
- [x] 四包 `CHANGELOG` 已更新；`example` 已按 §6 改造

### 9.1 实施记录（2026-09-21）

改动文件：

| 层 | 文件 |
| --- | --- |
| Dart | `lib/src/models/chat_disconnect_error_code.dart`（新增）、`lib/src/models/login_extension_info.dart`、`lib/src/internal/chat_method_keys.dart`、`lib/src/managers/chat_client.dart`、`lib/src/handlers/manager_event_handler.dart`、`lib/im_flutter_sdk.dart` |
| Android | `MethodKey.java`、`ClientWrapper.java`、`EMHelper.java`（删除已无引用的 `LoginExtensionInfoHelper`） |
| iOS | `MethodKeys.h`、`ClientWrapper.m`、删除 `LoginExtensionInfoHelper.{h,m}`（失去唯一引用后成为死代码，按「删除未使用代码」处理，取代原计划的「空值保护」） |
| example | `example/lib/listeners.dart`（含可复制的 `kDisconnectLogoutCodes`） |
| 测试 | `test/handlers/connection_event_test.dart`（新增） |
| CHANGELOG | `im_flutter_sdk`、`im_flutter_sdk_android`、`im_flutter_sdk_ios` |

验证结果：

| 检查 | 命令 | 结果 |
| --- | --- | --- |
| 格式（CI 门禁） | `dart format --output=none --set-exit-if-changed <改动文件>` | ✅ 0 changed |
| 静态检查 | `flutter analyze --fatal-infos`（`im_flutter_sdk`、`im_flutter_sdk/example`） | ✅ No issues found |
| 单元测试 | `flutter test`（`im_flutter_sdk`） | ✅ 40 个测试全部通过（新增 6 个） |
| 三端契约 | `dart run tool/ci/check_contracts.dart ..` | ✅ MethodChannel contracts are consistent |
| 端版本 | `dart run tool/ci/check_versions.dart ..` | ✅ Flutter/Android/iOS 均 5.0.0 |
| 用例映射 | `dart run tool/ci/check_case_mapping.dart .` | ✅ valid |
| Android 编译 | `flutter build apk --debug`（`example`） | ✅ 生成 `app-debug.apk`，仅基线既有 3 个 warning |
| iOS 编译 | `clang -fsyntax-only`（`ClientWrapper.m`，native 5.0 headers） | ✅ exit 0、无 error |

未完成项：上表三条真机验证（206 / 弱网 / token 过期）。这三条依赖设备与服务端环境，按仓库既有流程在真机或模拟器上执行。

## 10. 明确不做

| 项 | 原因 |
| --- | --- |
| 新增 `forcedLogout` 布尔或 `isLogout(code)` 之类的判定入口 | 属于 SDK 代替接入方判定；退出集合由平台行为决定，写进 SDK 会在平台调整时失效 |
| 用 `isLoggedIn` / `isConnected` 推断是否退出 | 与平台登出存在时序竞态，结果不确定（§5.5） |
| 把弱网原因码归一成 `2`，或把其他码改写为退出码 | 违背「原因码原样透传」，会丢失平台信息 |
| 去重标志（吞掉重复的断开事件） | 平台侧各原因回调互斥，不会重复派发；额外标志会误吞合法事件（如 iOS 切后台的断开） |
| 改变平台 SDK 的断开/登出行为 | 超出本仓库范围 |

## 附录 A：原因码数值表

与平台 `EMError`（core `include/emerror.h`、Android `com/hyphenate/EMError.java`、iOS `EMErrorCode.h`）逐值一致：

| 值 | 名称 | 值 | 名称 |
| --- | --- | --- | --- |
| 2 | NETWORK_ERROR | 214 | USER_LOGIN_TOO_MANY_DEVICES |
| 4 | EXCEED_SERVICE_LIMIT | 216 | USER_KICKED_BY_CHANGE_PASSWORD |
| 8 | APP_ACTIVE_NUMBER_REACH_LIMITATION | 217 | USER_KICKED_BY_OTHER_DEVICE |
| 104 | INVALID_TOKEN | 220 | USER_DEVICE_CHANGED |
| 108 | TOKEN_EXPIRED | 300 | SERVER_NOT_REACHABLE |
| 110 | INVALID_PARAM | 303 | SERVER_UNKNOWN_ERROR |
| 202 | USER_AUTHENTICATION_FAILED（5.0 不产生断开事件） | 304 | SERVER_GET_DNSLIST_FAILED |
| 204 | USER_NOT_FOUND | 305 | SERVER_SERVING_DISABLED |
| 206 | USER_LOGIN_ANOTHER_DEVICE | 306 | SERVER_DECRYPTION_FAILED |
| 207 | USER_REMOVED | | |
| 213 | USER_BIND_ANOTHER_DEVICE | | |

## 附录 B：与 React Native SDK 5.0.0 的差异

RN 的 `e6aca8b` 同样把 8 个回调收敛为 `onDisconnected(errorCode?, info?)`，本规格与它的一致点与差异：

| 项 | RN 5.0.0 | 本规格 |
| --- | --- | --- |
| 单一断开通道 + 常量组 | ✅ | ✅ 一致 |
| Android 206 由 `onLogout` 合并 info | ✅ | ✅ 一致 |
| iOS 统一出口折算原因码 | ✅ | ✅ 一致 |
| 「非 2 即强制下线」的文档规则 | 采用 | ❌ 不采用（弱网常见码为 300/303，见 §5.3） |
| `forcedLogoutPending` 去重标志 | 采用 | ❌ 不采用（见 §10） |
| 枚举注释标注「8/213/220 仅某端可达」 | 采用 | ❌ 不采用（按 §5.6 以实际收到的码为准） |

跨 SDK 一致性上，**公开 API 形状与原因码数值保持一致**；判定规则以本规格为准。
