# 阶段二：基线调查与跨端契约（Flutter 4.24.0）

- 工作区：`/Users/asterisk/Codes/zuoyu_flutter/im_flutter_sdk/.worktree/4.24.0`，分支 `4.24.0`（从 `flutter2_stable` 切出）
- 依据：`docs/porting/4.24.0/01-api-diff.md`（变更清单）；目标仓库 `AGENTS.md`；skill `references/flutter.md`

## 1. native 依赖 bump（阶段二第一步，已完成）

| 位置 | 改前 | 改后 | 上游可用性核验 |
|---|---|---|---|
| `im_flutter_sdk_ios/ios/im_flutter_sdk_ios.podspec` | `HyphenateChat 4.22.2` | `4.24.1` | `pod trunk info HyphenateChat` 有 4.24.1（2026-08-13）✅ |
| `im_flutter_sdk_ios/ios/im_flutter_sdk_ios/Package.swift` | `exact: "4.22.1"` | `exact: "4.24.1"` | `git ls-remote --tags` HyphenateChat_iOS 有 4.24.1 ✅ |
| `im_flutter_sdk_android/android/build.gradle` | `io.hyphenate:hyphenate-chat:4.22.1` | `4.24.1` | Maven Central `hyphenate-chat-4.24.1.aar` HTTP 200 ✅ |

⚠️ 基线不一致（bump 前现状）：podspec 为 4.22.2、SPM 与 Android 为 4.22.1——KI-101 同类问题在 `flutter2_stable` 上仍存在（known-issues 中标注"4.24 平版时已修复"与现状不符）。本次三处统一 bump 到 4.24.1 后一致，但基线不一致本身记入验收报告问题清单。

## 2. 基线调查结论（模式出处）

- ChatMessage 字符串属性链路：Dart `chat_message.dart`（字段 :83 区域、toJson `putIfNotNull` :926-954、fromJson :956-987）；Android `EMHelper.java` MessageHelper（fromJson :471-477 `if (json.has(...))`、toJson :547-639）；iOS `MessageHelper.m`（fromJson :16-69、toJson :71-122）。
- ChatOptions 链路：Dart `chat_options.dart`（toJson :1430-1481 `putIfNotNull`）；Android `EMHelper.java` OptionsHelper :67-165（⚠️ :98 起 `!enableDNSConfig` 门控块，新属性不得入内）；iOS `OptionsHelper.m` :50-106。
- 参照 API 全链路 `loadConversationMessagesWithKeyword`：三端常量同值；Dart `chat_manager.dart:2523-2552`；Android `ChatManagerWrapper.java:169-171` 分支 + :1328-1358 实现；iOS `ChatManagerWrapper.m:240-242` 分支 + :1595-1617 实现。返回包装 `{<方法名>: object}`。
- PageResult 三端序列化 key 完全一致：`count` + `list`（Dart `chat_page_result.dart:20-33`；Android `PageResultHelper.toJson` `EMHelper.java:1247-1273`；iOS `PageResultHelper.m:10-23`，元素须实现 `ModeToJson`）。
- 枚举：Dart 一律传 `.index`；body 类型 native 经 `EnumTools.messageBodyTypeFromInt`（Android ordinal、iOS switch，双端 Dart MessageType 顺序已对齐）；searchScope 复用既有 `MessageSearchScope`（chat_enums.dart:1122-1149，Content=0/Attribute=1/All=2）。
- iOS 消息 body toJson 多态可用（`[body toJson]`，MessageHelper.m 各子类 category）；Android 无统一"任意 EMMessageBody→json"入口，需新增按类型的分派。
- 常量命名：`static const String xxx = 'xxx'`，常量名=值，小驼峰，按版本注释分组（`// 4.24.0` / `#pragma mark 4.24.0`）。
- iOS `groupMessageDidRead:groupAcks:` 旧实现 `ChatManagerWrapper.m:1474-1483`，负载仅 ack 数组（未用 aMessage），事件 `onGroupMessageRead`；Android 对应监听 `ChatManagerWrapper.java:1226-1231` 无需动。
- 四包 pubspec 当前均 4.22.0 → 同步升 4.24.0；CHANGELOG 中文 `## 版本号` + `- 新增/修复/优化`。
- example 注册表：`example/lib/registry/apis/chat_apis.dart`，新 API 需补 `ApiEntry`。

## 3. 跨端契约（冻结，各层实现唯一对齐依据）

### 3.1 `webhookEnv`（ChatMessage 新增可空 String 属性）

| 层 | 约定 |
|---|---|
| Dart | `ChatMessage.webhookEnv`（`String?`，公开可变字段，与 `deliverOnlineOnly` 等同风格）；toJson `data.putIfNotNull("webhookEnv", webhookEnv)`；fromJson `..webhookEnv = map["webhookEnv"]`（容忍缺 key/null）；双语注释说明 nil/不设=默认回调路由、空串=按未匹配处理 |
| Android | fromJson：`if (json.has("webhookEnv")) message.setWebhookEnv(json.getString("webhookEnv"));`；toJson：`data.put("webhookEnv", message.getWebhookEnv())`（为 null 时 JSONObject 自动去 key，Dart 侧容忍） |
| iOS | fromJson：`msg.webhookEnv = aJson[@"webhookEnv"];`（Dart 只在非 null 时发 key）；toJson：**仅非 nil 时写入**（`if (self.webhookEnv) ret[@"webhookEnv"] = self.webhookEnv;`，避免 NSNull 崩溃） |
| JSON key | `webhookEnv`（三端逐字一致） |

### 3.2 `ntpServers`（ChatOptions 新增可空 List<String>）

| 层 | 约定 |
|---|---|
| Dart | `ChatOptions.ntpServers`（`List<String>?`，构造函数命名参数）；toJson `data.putIfNotNull("ntpServers", ntpServers)`；双语注释（"host" 或 "host:port"，默认端口 123，NTPv4/RFC 5905，仅 init 时生效） |
| Android | OptionsHelper 无门控区（**不得**放入 `!enableDNSConfig` 块）：`if (json.has("ntpServers"))` → JSONArray 循环组 `List<String>` → `options.setNtpServers(list)`（参照 receiverList 解析 `EMHelper.java:535-542`） |
| iOS | `if (aJson[@"ntpServers"] && ![aJson[@"ntpServers"] isKindOfClass:[NSNull class]]) options.ntpServers = aJson[@"ntpServers"];` |
| JSON key | `ntpServers` |

### 3.3 `searchMessagesFromServer`（新增 API，本次主体）

**方法名常量（三端逐字一致）**：`searchMessagesFromServer = "searchMessagesFromServer"`；版本注释 `// 4.24.0` / `#pragma mark 4.24.0`。

**Dart 公开 API**（`chat_manager.dart`）：

```dart
Future<ChatPageResult<ChatSearchServerMessageResult>> searchMessagesFromServer({
  required ChatMessageSearchOption option,
  int pageSize = 20,
  int pageNum = 1,
})
```

请求 JSON（Dart → native）：

```json
{
  "option": { ...ChatMessageSearchOption.toJson()... },
  "pageSize": 20,
  "pageNum": 1
}
```

`option` 子 Map key（三端逐字一致）：

| JSON key | 类型 | 说明 |
|---|---|---|
| `keywordList` | List<String>，必填 | 关键词列表，≤5 个；字符约束双端不一致（见 01-api-diff.md 疑点 1，Dart 不做校验，透传由服务端拒绝） |
| `keywordMatchType` | int | `ChatKeywordListMatchType.index`：OR=0 / AND=1（双端原生枚举顺序一致），缺省 OR |
| `conversationId` | String? | 单聊=对方 ID，群/聊天室=其 ID，缺=搜所有会话 |
| `msgTypes` | List<int>? | 元素为 Dart `MessageType.index`；native 逐元素经 `EnumTools.messageBodyTypeFromInt` 还原（Android ordinal / iOS switch）；不支持 cmd、voice |
| `startTime` / `endTime` | int? | 毫秒时间戳，须成对出现（成对才下发） |
| `searchScope` | int? | 复用 `MessageSearchScope.index`（Content=0/Attribute=1/All=2），缺省 Content |

**返回包装**：`{ "searchMessagesFromServer": { "count": int, "list": [ ... ] } }`（Android `EMValueWrapperCallBack` + PageResult 序列化；iOS `wrapperCallBack:channelName:` + PageResultHelper；Dart `ChatPageResult<ChatSearchServerMessageResult>.fromJson`）。

**list 元素（`ChatSearchServerMessageResult`）JSON key**：

| JSON key | 类型 | 来源/说明 |
|---|---|---|
| `msgId` | String | native `messageId`；命名对齐 ChatMessage JSON 的 `msgId` |
| `body` | Map? | native `body`；iOS `[body toJson]` 多态直用；Android 新增按 `EMMessageBody` 类型的分派（复用 MessageBodyHelper 各类型 toJson）；Dart 复用 ChatMessage 的 body 解析 |
| `attributes` | Map? | native `ext`；命名对齐 ChatMessage JSON 的 `attributes` |
| `from` | String | |
| `to` | String | |
| `convId` | String | native `conversationId`；命名对齐 ChatMessage JSON 的 `convId` |
| `chatType` | int | Android `EnumTools.chatTypeToInt`、iOS `EnumTools chatTypeToInt:`（同消息序列化） |
| `timestamp` | int | 毫秒；本模型自有命名（不套用 ChatMessage 的 `serverTime`），映射记入验收报告 |
| `highlightTexts` | List<String>? | 搜索高亮 |

**新增 Dart 类型**：
- `ChatMessageSearchOption`（`lib/src/models/chat_message_search_option.dart`，`fromJson`/`toJson`，双语注释）
- `ChatSearchServerMessageResult`（`lib/src/models/chat_search_server_message_result.dart`，同上）
- `ChatKeywordListMatchType { OR, AND }`（`lib/src/models/chat_enums.dart`，顺序 OR 先）
- 导出链：`lib/im_flutter_sdk.dart` 必查；被 manager 引用则 `lib/src/internal/inner_headers.dart` 同步。

**Wrapper 实现模式**：照 `loadConversationMessagesWithKeyword` 既有分支模式新增，不跨层跳步。

### 3.4 iOS `groupMessageDidRead` 回调迁移（4.24.1）

- 删除 `ChatManagerWrapper.m` 旧实现 `- groupMessageDidRead:groupAcks:`（:1474-1483），新增 `- (void)groupMessageDidRead:(NSArray<EMGroupMessageAck *> *)aGroupAcks`，方法体不变（序列化 ack 数组 → `ChatOnGroupMessageRead`）。事件名与负载不变，Dart 与 Android **零改动**。只保留新实现，规避新旧双发。

### 3.5 连接错误码 350–354

Flutter `ChatError.code` 为原生 int 透传、无白名单——预期零代码改动，阶段四以 grep 实证。

### 3.6 版本号 / CHANGELOG / example 注册

- 四包 `pubspec.yaml` 同步 `4.24.0`。
- CHANGELOG：主包记新 API 条目 + 依赖升级；android/ios 包记「依赖 SDK 升级到 4.24.1」及新增原生实现；interface 无改动则空标题条目。
- example `chat_apis.dart` 补 `searchMessagesFromServer` 的 `ApiEntry`。

## 4. 未匹配/无法确定项（不猜，进验收报告）

即 `01-api-diff.md` 未匹配清单 1–7，全部保留，其中影响本契约的：keywordList 约束（Dart 不校验，透传）；iOS 单端回调变更（按 3.4 处理）。

## 5. hooks 安装说明（流程强制档）

当前 harness（Kimi Code）无 Codex hooks 机制，按 skill 第三档执行：`gate` 作为每阶段门禁必跑命令、输出附进阶段产物；`pre` 靠纪律自约束（不主动 `git add/commit`），验收报告标注"未提交"。

阶段二门禁 gate 实证（2026-09-08）：

```text
$ echo '{}' | bash hooks/porting_guard.sh gate flutter <worktree>
exit=0   # 无 block 输出
$ git branch --show-current
4.24.0
$ git status --short
 M im_flutter_sdk_android/android/build.gradle        # 本任务 bump
 M im_flutter_sdk_ios/ios/im_flutter_sdk_ios.podspec  # 本任务 bump
 M im_flutter_sdk_ios/ios/im_flutter_sdk_ios/Package.swift  # 本任务 bump
?? docs/                                               # 本任务产物
```
