# 环信 Flutter IM SDK 4.x 到 5.0.0 迁移指南

## 升级总览

Flutter IM SDK 5.0.0 是一次源代码不兼容的大版本升级，主要涉及以下六个方面：

1. **数据同步机制调整**
   登录后，SDK 可自动同步会话、好友和已加入的群组数据，并将数据保存到本地数据库，替代原先由应用主动调用服务端拉取接口。
2. **消息已读回执机制重构**
   已读回执由逐条发送调整为批量发送；清除本地未读数与向消息发送方发送已读回执相互独立；单聊和群聊使用统一的回执模型与回调。
3. **群组配置模型重构**
   `ChatGroupStyle` 枚举和 `ChatGroupOptions` 拆分为 `ChatGroupConfigs` 中的 `isPublic`、`joinApprovalRequired` 和 `allowInvites` 三个独立属性，并支持创建群组后按配置类型更新群组属性。
4. **连接断开事件收敛**
   原先 8 个按原因命名的强制下线回调合并为单一回调 `onDisconnected`，并新增 `ChatDisconnectErrorCode` 原因码常量表。
5. **历史 API 精简**
   移除服务端拉取接口、长期标记为废弃 `@Deprecated` 的接口及部分边缘能力。注册、举报、聊天室创建与解散等能力需由业务服务或服务端 REST API 实现；密码登录接口下线，仅保留 Token 登录。（原生 SDK 同时下线了消息流量统计模块，Flutter 4.x 从未暴露该能力，Flutter 侧无需迁移。）
6. **原生依赖升级**
   iOS 与 Android 原生 SDK 依赖统一升级至 5.0.0（`HyphenateChat 5.0.0` / `HyphenateChat_iOS 5.0.0` / `io.hyphenate:hyphenate-chat:5.0.0`）。

:::tip
**升级要求：** Flutter IM SDK 5.0.0 包含不兼容的 Dart API 变更。更新 SDK 后必须重新执行 `flutter pub get` 并重新编译，重点验证 Token 登录、数据同步、会话未读数、单聊和群聊已读回执、群组创建和配置更新、好友、断开重连处理和推送设置。
:::

:::tip
**与平台迁移指南的关系：** 本指南面向 Flutter 应用层（`im_flutter_sdk` 的 Dart 公开 API）。原生层的改动已由 SDK 内部封装，业务代码不需要直接处理 Objective-C / Java 接口；如需了解原生行为细节，可参考 [环信 iOS IM SDK 4.x 到 5.0.0 迁移指南](https://doc.easemob.com/document/ios/migration_guide.html) 与 [环信 Android IM SDK 4.x 到 5.0.0 迁移指南](https://doc.easemob.com/document/android/migration_guide.html)。
:::

## 版本与依赖升级

| 项 | 4.x | 5.0.0 |
| :--- | :--- | :--- |
| `im_flutter_sdk` | 4.x | `5.0.0` |
| `im_flutter_sdk_interface`、`im_flutter_sdk_android`、`im_flutter_sdk_ios` | 4.x | `5.0.0`（四包版本必须一致） |
| iOS 原生 SDK | HyphenateChat 4.24.1 | `HyphenateChat 5.0.0`（CocoaPods）/ `HyphenateChat_iOS 5.0.0`（SPM） |
| Android 原生 SDK | hyphenate-chat 4.24.1 | `io.hyphenate:hyphenate-chat:5.0.0` |
| Dart / Flutter | `>=3.3.0` | `>=3.3.0`（最低支持版本未变） |
| Android minSdk / iOS 部署目标 | 21 / 13.0 | 21 / 13.0（未变） |

本指南的 4.x 对照基线是 **4.24.0**（当前 `flutter2_stable` 发布版，原生依赖 4.24.1）。若你的项目仍在 4.22.x 或更早版本，请先按对应版本的变更说明升到 4.24.0 的 API 形态，再套用本指南。

升级步骤：

```yaml
# pubspec.yaml
dependencies:
  im_flutter_sdk: ^5.0.0
```

```bash
flutter pub get
# iOS 使用 CocoaPods 集成时，podspec 中原生依赖版本已变更，必须重新执行 pod install
cd ios && pod install && cd ..
```

:::tip
Flutter 的增量构建（Fingerprinter）不追踪 podspec 变化，只改 `pubspec.yaml` 时可能跳过 `pod install`，导致 iOS 侧继续链接旧版本原生 SDK 并出现编译错误。升级后请显式执行一次 `pod install` 或清理构建产物。
:::

使用 Swift Package Manager 集成 iOS 的项目，原生依赖在 `im_flutter_sdk_ios` 的 `Package.swift` 中通过 `exact: "5.0.0"` 固定，升级插件版本后由 Flutter 的 SPM 集成自动解析，无需手工改动。

:::tip
Android 原生 5.0.0 新增了 `androidx.core:1.12.0`、`androidx.annotation:1.6.0`、`androidx.lifecycle:lifecycle-process:2.6.2` 三个传递依赖（4.24.1 没有）。它们要求消费方以 Android API 34 及以上编译，因此应用模块 `android/app/build.gradle` 的 `compileSdk` 需要 ≥ 34，否则会报 `Dependency 'androidx.core:core:1.12.0' requires libraries and applications that depend on it to compile against version 34 or later`。较新的 Flutter 模板默认已满足，老工程需要手动抬一次。
:::

:::warning
本指南只覆盖 iOS 与 Android。鸿蒙（HarmonyOS）由独立仓库 `im_flutter_sdk_oh` 提供，其版本与 iOS/Android 并不同步（当前为 `4.12.0-ohos-beta.x`，尚未提供 5.0.0）。同时构建鸿蒙端的项目不能直接依赖本指南的 API 变更结论，需要以该仓库自身的版本与文档为准。
:::

## 初始化与登录

### 自动登录移除

Flutter SDK 5.0.0 不再提供自动登录配置和自动登录状态查询。应用冷启动后，需要自行管理用户 ID 与 Token，并在适当时机主动调用 `ChatClient.getInstance.loginWithToken`。

| 删除的 API | 替代方式 | 接口说明 |
| :--- | :--- | :--- |
| `ChatOptions.autoLogin` | 无直接替代。应用启动后主动调用 `loginWithToken(userId, token)`。 | 配置 SDK 初始化后是否自动登录。 |
| `ChatClient.getInstance.isLoginBefore()` | 根据业务需要读取 `ChatClient.getInstance.currentUserId` 或 `ChatClient.getInstance.isConnected()`。 | 查询用户是否登录过且未登出。 |

`ChatClient.getInstance.currentUserId` 表示 SDK 记录的当前登录用户 ID，`isConnected()` 表示当前是否连接至聊天服务器。二者都不能替代应用对用户凭证和 Token 生命周期的管理。

:::warning
`currentUserId` 的取值在 iOS 与 Android 上存在差异：Android 返回本地持久化的上次登录用户，未登录时也可能非空；iOS 未登录时为 `null`。**不要用 `currentUserId == null` 判断是否已登录**，需要会话态时使用 `isConnected()`。

它同时是 Dart 侧的**缓存值**：只在 `init()`、`loginWithToken()` 时从原生刷新，在 `logout()` 时清空。被踢下线、Token 过期等退出场景只派发 `onDisconnected` / `onTokenDidExpire`，**不会自动清空该缓存**，此时它仍返回上一个用户 ID。替代 `isLoginBefore()` 时请自行维护登录态：在退出分支里调用 `logout()`（会清空缓存），或改用 `await getCurrentUserId()` 主动拉取；业务侧的用户 ID / Token 仍以应用自己的持久化为准。
:::

### 密码登录下线

Flutter SDK 5.0.0 仅保留 Token 登录方式。用户注册、密码校验和 Token 获取等账号管理操作需要 REST API 或由业务服务器完成。

| 删除的 API | 替代方式 | 接口说明 |
| :--- | :--- | :--- |
| `ChatClient.getInstance.createAccount(userId, password)` | 无客户端替代；通过服务端 REST API 注册 IM 账号。 | 使用用户 ID 和密码注册 IM 账号。 |
| `ChatClient.getInstance.login(userId, pwdOrToken, [isPassword])` | `loginWithToken(userId, token)` | 使用密码或 Token 登录；4.x 中已标记 `@Deprecated`。 |
| `ChatClient.getInstance.loginWithPassword(userId, password)` | `loginWithToken(userId, token)` | 使用密码登录。 |
| `ChatClient.getInstance.loginWithAgoraToken(userId, agoraToken)` | `loginWithToken(userId, token)` | 使用 Agora Token 登录。 |

5.0.0 的登录入口固定走 Token 链路：

```dart
await ChatClient.getInstance.loginWithToken(userId, userToken);
```

Token 续期接口由 `renewAgoraToken` 改名为 `renewToken`：

| 4.x API | 5.0.0 API | 说明 |
| :--- | :--- | :--- |
| `ChatClient.getInstance.renewAgoraToken(String agoraToken)` | `ChatClient.getInstance.renewToken(String token)` | 在 `ConnectionEventHandler.onTokenWillExpire` 中调用，更新当前登录会话的 Token。 |

### 登录与数据库打开解耦

Flutter SDK 5.0.0 新增本地数据库打开回调。数据库打开后即可读取当前账号的本地数据，不必等待会话、好友或已加入群组的服务端同步完成，有助于加快冷启动时的首屏展示。

`ConnectionEventHandler` 新增以下回调，均通过 `ChatClient.getInstance.addConnectionEventHandler(id, handler)` 注册：

- `onDatabaseOpened(String username, ChatError? error)`：当前账号本地数据库打开完成时触发；`error` 为空表示打开成功。
- `onDataSyncStart(int type)`：指定类型的数据开始同步时触发。
- `onDataSyncFinish(int type, ChatError? error)`：指定类型的数据同步完成时触发；`error` 为空表示同步成功。

:::warning
`onDatabaseOpened` 的 `error` 参数在 Android 上固定为 `null`（平台未提供错误信息），iOS 上透传平台错误。两端都应在回调中接受 `error == null` 作为成功语义。
:::

## 数据同步与服务端拉取 API 迁移

### 数据同步 API

Flutter SDK 5.0.0 新增登录后自动数据同步机制。应用应在初始化 SDK 前通过 `ChatOptions.dataSyncType` 指定同步的数据类型，并通过 `ConnectionEventHandler` 监听同步进度。同步完成后，从各模块的本地接口读取数据。

| 所属类 | API 或配置 | 接口说明 |
| :--- | :--- | :--- |
| `ChatDataSyncType` | `none`、`conversations`、`contacts`、`joinedGroups` | 数据同步位掩码常量，取值分别为 `0`、`1 << 0`、`1 << 1`、`1 << 2`；多个类型可使用按位或组合。 |
| `ChatOptions` | `dataSyncType`（`int?`） | 设置登录后自动同步的数据类型；必须在调用 `ChatClient.getInstance.init(options)` 前配置。 |
| `ConnectionEventHandler` | `onDataSyncStart(int type)` | 通知指定类型的数据开始同步。 |
| `ConnectionEventHandler` | `onDataSyncFinish(int type, ChatError? error)` | 通知指定类型的数据同步结束；`error` 为空表示成功。 |
| `ConnectionEventHandler` | `onDatabaseOpened(String username, ChatError? error)` | 通知指定账号的本地数据库已经打开；该事件不表示任何服务端数据已经同步完成。 |

典型配置如下：

```dart
ChatOptions options = ChatOptions.withAppKey(
  'your-appkey',
  dataSyncType: ChatDataSyncType.conversations |
      ChatDataSyncType.contacts |
      ChatDataSyncType.joinedGroups,
);
await ChatClient.getInstance.init(options);
```

:::tip
默认构造函数 `ChatOptions({required String appKey, ...})` 自 4.x 起即为 `@Deprecated`，5.0.0 继续保留但建议改用工厂构造 `ChatOptions.withAppKey(appKey, ...)`；`dataSyncType` 在三个公开构造函数（`ChatOptions(...)`、`withAppKey`、`withAppId`）与 `copyWith` 中均可用。
:::

:::warning
`dataSyncType` 在 Flutter 侧是可空字段，未设置时不在桥接层补默认值，两端原生默认值并不一致：iOS 默认同步会话（等价于 `ChatDataSyncType.conversations`），Android 默认不同步任何类型（等价于 `ChatDataSyncType.none`）。**需要一致行为的应用必须显式配置 `dataSyncType`**，不要依赖平台默认值。
:::

同步完成事件按「位掩码」判断当前同步完成的数据类型：

```dart
onDataSyncFinish: (type, error) {
  if (error != null) return;
  if ((type & ChatDataSyncType.conversations) != 0) {
    // 会话数据已同步，刷新会话列表
  }
  if ((type & ChatDataSyncType.contacts) != 0) {
    // 好友数据已同步，刷新联系人列表
  }
  if ((type & ChatDataSyncType.joinedGroups) != 0) {
    // 已加入的群组数据已同步，刷新群列表
  }
},
```

### 服务端拉取 API 迁移

原先主动拉取会话、好友和已加入群组，并自行刷新数据的方式，统一调整为 **配置数据同步范围、登录后自动同步、读取本地数据，并在 `onDataSyncFinish` 成功后刷新 UI**。

| 类 | 删除的 API | 5.0.0 推荐方式 |
| :--- | :--- | :--- |
| `ChatManager` | `getConversationsFromServer()`、`fetchConversationListFromServer(...)`、`fetchConversation(...)`、`fetchConversationsByOptions(...)` | 这些接口用于从服务器拉取会话列表。改用本地接口 `ChatManager.loadAllConversations()`（加载全部本地会话）与 `getConversation(conversationId, type: ...)`（按 ID 获取单个会话），并在 `onDataSyncFinish` 的 `type` 命中 `ChatDataSyncType.conversations` 位之后刷新。 |
| `ChatManager` | `fetchPinnedConversations(...)` | 该接口用于拉取服务端置顶会话。改为读取本地会话的 `isPinned` / `pinnedTime` 字段；需要以服务端最新置顶状态为准时，在 `onDataSyncFinish`（`type` 命中 `conversations`）成功后再读。 |
| `ChatGroupManager` | `fetchJoinedGroupsFromServer(...)` | 该接口分页拉取已加入群组。改用本地 `ChatGroupManager.getJoinedGroups()`，并在 `onDataSyncFinish` 的 `type` 命中 `ChatDataSyncType.joinedGroups` 位之后刷新。 |
| `ChatContactManager` | `getAllContactsFromServer()`、`fetchAllContacts()`、`fetchContacts(...)`、`fetchAllContactIds()` | 这些接口从服务器拉取好友列表。改用本地 `getAllContacts()`、`getAllContactIds()`、`getContact(userId: ...)`，并在 `onDataSyncFinish` 的 `type` 命中 `ChatDataSyncType.contacts` 位之后刷新。 |
| `ChatOptions` | `enableAutoSyncContacts` | 该配置控制好友自动同步。改为在 `dataSyncType` 中包含 `ChatDataSyncType.contacts`。 |

:::tip
`ChatManager` 的本地会话读取接口为 `loadAllConversations()`（全部本地会话）和 `getConversation(conversationId, type: ...)`（按 ID 获取）。4.x 中标记为「改用 `fetchConversationsByOptions`」的废弃接口与其替代者 `fetchConversationsByOptions` 在 5.0.0 中均已删除，不要再沿用这条迁移路径。
:::

:::warning
`getConversation` 的完整签名是 `getConversation(String conversationId, {ChatConversationType type = ChatConversationType.Chat, bool createIfNeed = true})`。`type` 默认为单聊，**获取群会话或聊天室会话时必须显式传入 `ChatConversationType.GroupChat` / `ChatConversationType.ChatRoom`**，否则会拿到（并因 `createIfNeed` 默认 `true` 而创建）一个同 ID 的单聊会话。不需要创建时可传 `createIfNeed: false`，会话不存在时返回 `null`。
:::

相应地，`ChatContactEventHandler.onContactSyncStart` 和 `onContactSyncFinish` 已删除。请改用 `ConnectionEventHandler.onDataSyncStart` 和 `onDataSyncFinish`，并判断 `type` 是否包含 `ChatDataSyncType.contacts`。详见 [监听器回调变化汇总](#监听器回调变化汇总)。

## 已读回执体系重构

消息已读回执由逐条发送调整为批量发送；是否需要回执通过 `ChatMessage.isNeedReadReceipt` 按消息设置；发送消息已读回执与清理会话未读数相互独立。旧 API 不提供兼容别名，属于不兼容变更。

### 发送消息已读回执与清除未读数

| 删除的 API | 5.0.0 替代 | 说明 |
| :--- | :--- | :--- |
| `ChatManager.sendMessageReadAck(ChatMessage message)` | `sendMessageReadReceipts(List<ChatMessage> messages)` | 批量发送消息已读回执，单聊和群聊统一使用。 |
| `ChatManager.sendGroupMessageReadAck(...)` | `sendMessageReadReceipts(List<ChatMessage> messages)` | 不再为群聊提供单独的逐条已读回执接口，也不再支持为群消息已读回执携带自定义内容。 |
| `ChatManager.sendConversationReadAck(String conversationId)` | `clearConversationUnreadMessageCount(conversationId)`，并按需调用 `sendMessageReadReceipts(messages)` | 旧接口发送会话级已读回执。5.0.0 将清除当前用户未读数与通知消息发送方拆为两个操作。 |
| `ChatManager.markAllConversationsAsRead()` | `clearAllConversationUnreadMessageCount()` | 清除所有本地会话的未读数，并同步至当前用户的其他设备。 |
| `ChatConversation.markMessageAsRead(String messageId)`、`markAllMessagesAsRead()` | `ChatManager.clearConversationUnreadMessageCount(conversationId)` | 通过会话级接口清除本地未读数；不再由 `ChatConversation` 修改消息已读态。 |
| 直接设置 `ChatMessage.hasRead` | 无公开 setter；使用未读数清理接口 | `ChatMessage.isRead` 在 5.0.0 中变为只读属性，由 SDK 内部维护。 |
| `ChatOptions.requireAck`、`ChatClient.getInstance.updateRequireAckSetting(bool)` | 发送前设置 `message.isNeedReadReceipt = true` | 删除全局已读回执开关，改为按消息指定是否需要已读回执。 |

`sendMessageReadReceipts` 每次最多接收 50 条属于同一会话的消息。消息的 `isNeedReadReceipt` 必须为 `true`；该接口不会清除或修改会话的本地未读数。

```dart
// 先清除本地未读数（不通知发送方）
await ChatClient.getInstance.chatManager
    .clearConversationUnreadMessageCount(conversationId);

// 需要通知发送方已读时，再批量发送回执
// 注意：loadMessagesWithIds 单次最多 20 个消息 ID（两端原生限制），
// 要凑足 50 条回执需分批加载，或直接使用会话已加载的消息对象。
final messages = await ChatClient.getInstance.chatManager
    .loadMessagesWithIds(msgIds, conversationId);
await ChatClient.getInstance.chatManager.sendMessageReadReceipts(messages);
```

:::warning
`loadMessagesWithIds(messageIds, conversationId)` 底层对应原生的「按 ID 批量取本地消息」，**单次最多 20 个 ID**（iOS `getMessages:withConversationId:` 与 Android 同口径，均为「一次最多获取 20 条消息」），与回执接口的 50 条上限并不相同。一次传入超过 20 个 ID 会失败，需自行分批。
:::

:::tip
批量接口的校验结果以原生 SDK 为准：批次中无法解析为本地消息的条目会被跳过，可解析的条目正常发送回执；当整批消息都无法解析时返回 `110 INVALID_PARAM`。Flutter 侧只透出**整批的 `ChatError`**（不逐条返回哪条失败），请按该错误处理失败，不要假设整批要么全成功要么全失败；也不要在发送前自行拼「全部有效才发」的前置校验。Android 原生还说明：不需要回执或已经回执过的消息会被跳过，整批无合格消息时为空操作（仍返回成功）。
:::

### 接收消息已读回执

Flutter SDK 5.0.0 将单聊和群聊的实时已读回执统一通过 `ChatEventHandler.onMessageReadReceipts` 回调，不再分别使用单聊和群聊回调。

| 4.x 回调 | 5.0.0 回调 | 说明 |
| :--- | :--- | :--- |
| `ChatEventHandler.onMessagesRead(List<ChatMessage> messages)` | `ChatEventHandler.onMessageReadReceipts(List<ChatMessageReadReceipt> receipts)` | 接收单聊消息的已读回执。 |
| `ChatEventHandler.onGroupMessageRead(List<ChatGroupMessageAck> groupMessageAcks)` | `ChatEventHandler.onMessageReadReceipts(List<ChatMessageReadReceipt> receipts)` | 接收群聊消息的已读回执。 |
| `ChatEventHandler.onReadAckForGroupMessageUpdated()` | `ChatEventHandler.onMessageReadReceipts(List<ChatMessageReadReceipt> receipts)` | 群聊消息已读状态变化通知。 |
| `ChatEventHandler.onConversationRead(String from, String to)` | 无直接替代 | 会话级已读回执不再单独回调；消息级已读结果由 `onMessageReadReceipts` 通知。 |

SDK 5.0.0 新增 `ChatMessageReadReceipt`，用于统一描述消息已读回执：

- `messageId`：消息 ID。
- `conversationId`：会话 ID。
- `isPeerReceipt`：单聊中，对端是否已发送该消息的已读回执。
- `readCount`：群聊中，该消息的已读人数。

### 回执详情查询

| 4.x API | 5.0.0 API | 说明 |
| :--- | :--- | :--- |
| `ChatManager.fetchGroupAcks(msgId, groupId, {startAckId, pageSize = 0})` | `ChatManager.fetchGroupMessageReadReceipts(messageId, groupId, {cursor = '', pageSize = 20})` | 分页获取指定群消息的已读成员详情；返回 `ChatCursorResult<ChatGroupReadReceipt>`。下一页将上一页结果的 `cursor` 传入 `cursor` 参数。 |
| 无 | `ChatManager.getGroupMessageReadReceipts(List<ChatMessage> messages)` | 从服务器批量获取群消息的已读回执汇总；每次最多传入 20 条消息，且所有消息必须属于同一会话，返回 `List<ChatMessageReadReceipt>`。 |

回执详情模型由 `ChatGroupMessageAck` 替换为 `ChatGroupReadReceipt`：

- `messageId`：群消息 ID。
- `receiptId`：已读回执 ID（`String?`，可为空），也用于分页游标（4.x 中字段名为 `ackId`）。
- `from`：发送已读回执的群成员，类型由 `String` 改为 `GroupMemberInfo`；其中 `role` 和 `joinedTs` 在该场景不可用。
- `readCount`：已读回执数量。
- `timestamp`：发送已读回执的时间戳。
- 原 `content` 属性已移除，服务端不再下发 ACK 扩展内容。

:::tip
`fetchGroupMessageReadReceipts` 返回的 `ChatCursorResult.totalCount` 仅在 iOS 上有值，Android 为 `null`。需要展示总已读数的应用应容忍 `null`。
:::

### ChatMessage 已读相关成员变更

| 4.x API | 5.0.0 API | 说明 |
| :--- | :--- | :--- |
| 可读写的 `ChatMessage.hasReadAck` | 只读的 `ChatMessage.isPeerRead` | 判断消息对端是否已读；5.0.0 为只读属性。 |
| 可读写的 `ChatMessage.hasRead` | 只读的 `ChatMessage.isRead` | 属性改名，消息的本地已读状态由 SDK 内部维护。 |
| `ChatMessage.needGroupAck` | `ChatMessage.isNeedReadReceipt` | 单聊和群聊均适用；发送消息前设置是否需要已读回执。 |
| `Future<int> ChatMessage.groupAckCount()` | 只读的 `ChatMessage.groupReadReceiptCount` | 由异步方法改为同步只读属性，获取群聊消息的已读人数。 |

:::warning
`hasRead` / `isRead` 的序列化 key 同步由 `hasRead` 改为 `isRead`，`hasReadAck` / `needGroupAck` 分别改为 `isPeerRead` / `isNeedReadReceipt`，群已读人数新增 key `groupReadReceiptCount`（4.x 为异步方法 `groupAckCount()`，无对应 key）。如果业务代码自行解析 MethodChannel 返回的 Map，需要同步修改字段名。
:::

### 多设备事件

`ChatMultiDevicesEvent` 新增以下枚举成员（括号内为对应的平台事件码，仅用于对照排查）：

- `CONVERSATION_UNREAD_MESSAGE_COUNT_CLEARED`（原生事件码 65）：其他设备清除了指定会话的未读数。
- `ALL_CONVERSATION_UNREAD_MESSAGE_COUNT_CLEARED`（原生事件码 66）：其他设备清除了所有会话的未读数。
- `GROUP_UPDATE`（原生事件码 34，仅 iOS 下发）：群组信息更新，通过 `ChatMultiDeviceEventHandler.onGroupEvent` 送达。Android 没有等价事件码（原生 52 在 Android 为 `GROUP_METADATA_CHANGED`，在 iOS 为 `GroupMemberAttributesChanged`，语义是**群成员自定义属性**变化，不等同于群信息变化，Dart 侧统一映射为 `GROUP_MEMBER_ATTRIBUTES_CHANGED`）。需要跨端感知群信息变化时，请依赖 `ChatGroupEventHandler.onSpecificationDidUpdate(ChatGroup)`，而不要依赖 `GROUP_UPDATE`。

:::tip
Dart 枚举不声明数值，`65`、`66`、`34`、`52` 是平台事件码，由 SDK 内部转换；业务代码只比较枚举成员，不要比较数字。
:::

当前账号在其他设备清除未读数后，当前设备通过 `ChatMultiDeviceEventHandler.onConversationEvent`（会话类多设备事件）收到通知，应重新读取本地会话并刷新 UI。

:::warning
5.0.0 同时修正了多设备事件的映射缺陷：4.x 中 Dart 把 `CHAT_THREAD_KICK` / `CHAT_THREAD_UPDATE` 两个原生事件码映射反了，且群白名单、全员禁言等事件（原生 30-33）没有映射。依赖旧映射行为或在 4.x 上收不到这些事件的业务，升级后的表现会发生变化。
:::

## 群组配置模型重构

Flutter SDK 5.0.0 将群组可见性、入群审批和成员邀请权限从 `ChatGroupStyle` 单一枚举改为 `ChatGroupConfigs` 中的独立属性。**该调整不提供兼容层，升级时需要修改建群和群组配置代码。**

### `ChatGroupStyle` 与 `ChatGroupConfigs` 对照

| 4.x `ChatGroupStyle`（已删除） | 5.0.0 `ChatGroupConfigs` 配置 |
| :--- | :--- |
| `ChatGroupStyle.PrivateOnlyOwnerInvite` | `isPublic = false`，`allowInvites = false` |
| `ChatGroupStyle.PrivateMemberCanInvite` | `isPublic = false`，`allowInvites = true` |
| `ChatGroupStyle.PublicJoinNeedApproval` | `isPublic = true`，`joinApprovalRequired = true` |
| `ChatGroupStyle.PublicOpenJoin` | `isPublic = true`，`joinApprovalRequired = false` |

### `ChatGroupOptions` 与 `ChatGroupConfigs` 对照

| 4.x `ChatGroupOptions`（已删除） | 5.0.0 `ChatGroupConfigs` |
| :--- | :--- |
| `ChatGroupStyle style` | 拆分为 `bool` 类型的 `isPublic`、`joinApprovalRequired` 和 `allowInvites`；三者默认值均为 `false` |
| `int maxCount = 200` | `int maxCount = 200`，字段名与默认值保持不变 |
| `bool inviteNeedConfirm = false` | `bool inviteNeedConfirm = false`，字段名与默认值保持不变 |
| `String? ext` | `String? ext`，字段名保持不变；5.0.0 默认值为 `null` |

:::warning
`ChatGroupConfigs` 的 Dart 默认值固定为 `inviteNeedConfirm = false`，且 `toJson()` 总会显式带上该 key（`ext` 为 `null` 时不下发该 key）；这样做的目的是延续 4.x Dart 行为，而不依赖两端原生默认值（iOS 原生默认 `inviteNeedConfirm = YES`、`ext` 为空字符串）。字段本身仍可由业务显式传 `true`，只是不传时不会变成原生的 `YES`。
:::

### 相关 API 变化

| 4.x API | 5.0.0 API 或适配方式 |
| :--- | :--- |
| `ChatGroupManager.createGroup({groupName, avatarUrl, desc, inviteMembers, inviteReason, options})` | 参数 `options` 改名为 `configs`，类型为 `ChatGroupConfigs`；其余参数不变。 |
| `ChatGroup.settings`（`ChatGroupOptions?`，已废弃） | `ChatGroup.configs`（`ChatGroupConfigs?`），用于读取群组配置；iOS 上可能为 `null`，见下方 warning。 |
| `ChatGroup.isMemberOnly`（**已删除**） | 5.0.0 无同名字段，原生改名为 `isJoinApprovalRequired`，但**语义收窄，不能直接顶替**：4.x `isMemberOnly` 是「非公开群 **或** 入群需审批」的合并语义（等价于 `!(isPublic && !joinApprovalRequired)`，只有公开且无需审批的群才为 `false`）；5.0.0 的 `ChatGroup.isJoinApprovalRequired` 只表示「公开群是否需要审批」（原生说明：私有群下该字段不参与行为，通常为 `false`），而 4.x `isMemberOnly` 对私有群恒为 `true`。按用途选择：判断公开性用 `ChatGroup.isPublic`，判断是否需审批用 `ChatGroup.isJoinApprovalRequired`；需要复现旧 `isMemberOnly` 语义则写 `!(isPublic == true && isJoinApprovalRequired == false)`（两个字段均为可空 `bool?`，需处理 `null`）。 |
| 无 | `ChatGroupManager.updateGroupConfigs({groupId, types, configs})`：创建群组后，按 `types` 指定的字段更新群组配置，返回更新后的 `ChatGroup`。 |
| 无 | `ChatGroupConfigsType`：包含 `allowInvites`、`maxUsers`、`inviteNeedConfirm`、`joinApprovalRequired`、`isPublic` 和 `ext`，可按位或组合。 |

:::warning
从 `ChatGroup` 读回群组配置时存在平台差异，升级后需逐项确认：

- `configs`、`isJoinApprovalRequired`、`isMemberAllowToInvite` 在 iOS 上依赖原生 `settings`，未拉取群详情时可能整体缺失（Dart 侧为 `null`）；Android 上总有值。读取前请先调 `fetchGroupInfoFromServer(groupId)`。
- `maxUserCount` 与 `extension`（群扩展）在 iOS 上**不再下发**，恒为 `null`（4.x 在 `settings` 非空时会下发）；Android 正常。iOS 侧需要这两个值时改读 `group.configs?.maxCount` 与 `group.configs?.ext`。
- `configs.inviteNeedConfirm` 在 Android 上固定回传 `false`（原生 `EMGroup` 未提供该 getter），不要用它判断真实配置；该字段仅在创建 / 更新时作为入参有效。
:::

建群示例：

```dart
// 4.x
final group = await ChatClient.getInstance.groupManager.createGroup(
  groupName: 'test',
  options: ChatGroupOptions(style: ChatGroupStyle.PublicJoinNeedApproval),
);

// 5.0.0
final group = await ChatClient.getInstance.groupManager.createGroup(
  groupName: 'test',
  configs: const ChatGroupConfigs(
    isPublic: true,
    joinApprovalRequired: true,
  ),
);
```

按字段更新群配置：

```dart
await ChatClient.getInstance.groupManager.updateGroupConfigs(
  groupId: groupId,
  types: ChatGroupConfigsType.isPublic |
      ChatGroupConfigsType.joinApprovalRequired,
  configs: const ChatGroupConfigs(
    isPublic: true,
    joinApprovalRequired: false,
  ),
);
```

群名称、描述和头像不属于 `ChatGroupConfigsType`，仍分别使用 `updateGroupName(groupId, name)`、`updateGroupDesc(groupId, desc)` 和 `updateGroupAvatar({groupId, avatarUrl})` 更新。

## 连接断开事件收敛

4.x 时代 `ConnectionEventHandler` 把「与服务器断开」拆成 9 个回调（1 个无参 `onDisconnected` 加 8 个按原因命名的回调），且部分原因在 Dart 层被丢弃或误转发。5.0.0 将断开事件收敛为**单一通道**，原因是 breaking 变更。

### 删除的回调与替代方式

| 4.x 回调 | 5.0.0 替代方式 |
| :--- | :--- |
| `onDisconnected()`（无参） | `onDisconnected(int? errorCode, LoginExtensionInfo? info)` |
| `onUserDidLoginFromOtherDevice(LoginExtensionInfo info)` | `errorCode == ChatDisconnectErrorCode.USER_LOGIN_ANOTHER_DEVICE`（206），设备信息读第二个参数 `info` |
| `onUserDidRemoveFromServer()` | `errorCode == ChatDisconnectErrorCode.USER_REMOVED`（207） |
| `onUserDidForbidByServer()` | `errorCode == ChatDisconnectErrorCode.SERVER_SERVICE_RESTRICTED`（305） |
| `onUserDidChangePassword()` | `errorCode == ChatDisconnectErrorCode.USER_KICKED_BY_CHANGE_PASSWORD`（216） |
| `onUserDidLoginTooManyDevice()` | `errorCode == ChatDisconnectErrorCode.USER_LOGIN_TOO_MANY_DEVICES`（214） |
| `onUserKickedByOtherDevice()` | `errorCode == ChatDisconnectErrorCode.USER_KICKED_BY_OTHER_DEVICE`（217） |
| `onUserAuthenticationFailed()` | 5.0.0 不再为该场景提供独立回调。4.x 的实现把它误转发为无参 `onDisconnected()`，该缺陷已一并修掉。按平台 5.0 的行为，鉴权失败（原因码 `202`）不再产生断开事件，因此 `ChatDisconnectErrorCode` 未保留对应常量；详见下节。 |
| `onAppActiveNumberReachLimit()` | `errorCode == ChatDisconnectErrorCode.APP_ACTIVE_NUMBER_REACH_LIMITATION`（8） |

### 原因码分类

`errorCode` 的数值与平台 `EMError` 一致并原样透传，Flutter 侧不做改写。`ChatDisconnectErrorCode` 提供可读的常量：

**退出原因**（本地登录态已失效，需要重新登录，共 13 个）：

| 常量 | 值 | 说明 |
| :--- | :--- | :--- |
| `APP_ACTIVE_NUMBER_REACH_LIMITATION` | 8 | 应用的日活或月活用户数达到上限 |
| `INVALID_TOKEN` | 104 | Token 与登录信息不匹配 |
| `INVALID_PARAM` | 110 | 建立连接所用的参数无效 |
| `USER_NOT_FOUND` | 204 | 用户不存在 |
| `USER_LOGIN_ANOTHER_DEVICE` | 206 | 当前账号在其他设备登录（唯一携带 `info` 的原因） |
| `USER_REMOVED` | 207 | 当前账号已被服务器删除 |
| `USER_BIND_ANOTHER_DEVICE` | 213 | 账号已与其他设备绑定 |
| `USER_LOGIN_TOO_MANY_DEVICES` | 214 | 登录设备数超过限制 |
| `USER_KICKED_BY_CHANGE_PASSWORD` | 216 | 密码已被修改 |
| `USER_KICKED_BY_OTHER_DEVICE` | 217 | 账号被其他设备踢下线 |
| `USER_DEVICE_CHANGED` | 220 | 登录设备变更，需要重新登录 |
| `SERVER_GET_DNSLIST_FAILED` | 304 | 无法获取可用的服务器地址 |
| `SERVER_SERVICE_RESTRICTED` | 305 | 应用的服务被服务器禁用 |

**连接原因**（用户仍在登录态，SDK 会自动重连，共 5 个）：

| 常量 | 值 | 说明 |
| :--- | :--- | :--- |
| `NETWORK_ERROR` | 2 | 网络不可用 |
| `EXCEED_SERVICE_LIMIT` | 4 | 应用的用户数或服务额度超限 |
| `SERVER_NOT_REACHABLE` | 300 | 连接超时、DNS 解析失败或连接被拒绝（弱网下最常见） |
| `SERVER_UNKNOWN_ERROR` | 303 | IO 错误或连接流异常关闭 |
| `SERVER_DECRYPTION_FAILED` | 306 | 传输解密失败 |

未列出的原因码（含平台后续新增的码）一律按「非退出」处理。

:::warning
`ChatDisconnectErrorCode` 未列出 `202`（用户鉴权失败）。4.x 中它由 `onUserAuthenticationFailed` 单独通知；按平台 5.0 的行为，该场景**不再产生断开事件**（Token 类失败走 `104 INVALID_TOKEN` 与 `onTokenWillExpire` / `onTokenDidExpire`），所以 5.0.0 没有为它保留常量。如果你的业务希望兼容平台后续行为变化，可以把 `202` 作为**防御项**自行加入退出码集合（鉴权失败属于退出），但不要依赖它一定会到达：

```dart
const Set<int> kDisconnectLogoutCodes = <int>{ 202, /* ... 其余退出码 */ };
```
:::

:::warning
不要使用「原因码不等于 2 即视为强制下线」这类规则判断退出：弱网下的常见原因码是 `300` / `303`，而不是 `2`。
:::

### 退出有两个事件通道

Token 过期同样是退出，但它**不会**触发 `onDisconnected`，只触发 `onTokenDidExpire`。因此接入方必须同时处理两个通道，只监听其中一个会漏场景：

```dart
/// 收到这些原因码表示已被登出，需要回到登录页/首页。
const Set<int> kDisconnectLogoutCodes = <int>{
  ChatDisconnectErrorCode.APP_ACTIVE_NUMBER_REACH_LIMITATION,
  ChatDisconnectErrorCode.INVALID_TOKEN,
  ChatDisconnectErrorCode.INVALID_PARAM,
  ChatDisconnectErrorCode.USER_NOT_FOUND,
  ChatDisconnectErrorCode.USER_LOGIN_ANOTHER_DEVICE,
  ChatDisconnectErrorCode.USER_REMOVED,
  ChatDisconnectErrorCode.USER_BIND_ANOTHER_DEVICE,
  ChatDisconnectErrorCode.USER_LOGIN_TOO_MANY_DEVICES,
  ChatDisconnectErrorCode.USER_KICKED_BY_CHANGE_PASSWORD,
  ChatDisconnectErrorCode.USER_KICKED_BY_OTHER_DEVICE,
  ChatDisconnectErrorCode.USER_DEVICE_CHANGED,
  ChatDisconnectErrorCode.SERVER_GET_DNSLIST_FAILED,
  ChatDisconnectErrorCode.SERVER_SERVICE_RESTRICTED,
  202, // USER_AUTHENTICATION_FAILED：无对应常量，平台 5.0 不再下发，此处仅作防御性保留
};

ChatClient.getInstance.addConnectionEventHandler(
  'app',
  ConnectionEventHandler(
    onConnected: () => setConnecting(false),
    onDisconnected: (errorCode, info) {
      if (errorCode != null && kDisconnectLogoutCodes.contains(errorCode)) {
        // 已被登出：回到登录页
        if (errorCode == ChatDisconnectErrorCode.USER_LOGIN_ANOTHER_DEVICE) {
          showKickedByDevice(info?.deviceName);
        }
        backToLogin();
        return;
      }
      // 其余情况：连接层事件，SDK 会自动重连，无需跳转
      setConnecting(true);
    },
    onTokenDidExpire: () {
      // 同样是退出
      backToLogin();
    },
  ),
);
```

### 平台差异与 `null` 语义

| 差异 | Flutter 侧表现 | 接入方处理 |
| :--- | :--- | :--- |
| iOS 通用断开回调不携带原因码 | `errorCode` 为 `null` | 视为「平台未提供原因」，按连接层事件处理，不要据此跳转登录页 |
| iOS 上 206 与 220 共用平台回调 | 统一折算为 `206` | 两种都属于退出，主流程一致 |
| iOS App 切后台会产生一次断开 | `errorCode` 为 `null`，回前台自动 `onConnected` | 按连接层事件处理，无需处理 |
| Android 弱网常见码为 `300` / `303` | 原样透传 | 不要用 `!= 2` 判定退出 |
| `8` / `213` 在两端可达性不同 | 原样透传或为 `null` | 以实际收到的码为准，不要按平台硬编码 |

:::warning
退出场景下平台是**先派发事件、后完成登出**，且事件为异步派发。不要在 `onDisconnected` / `onTokenDidExpire` 内部依赖登录态做判断，也不要在这两个回调里发起需要登录态的 API 调用。
:::

## 设备管理与鉴权

随密码登录下线，基于「用户 ID + 密码」的设备鉴权接口一并移除，5.0.0 保留基于「用户 ID + Token」的异步接口：

| 4.x API | 5.0.0 API | 接口说明 |
| :--- | :--- | :--- |
| `ChatClient.getInstance.getLoggedInDevicesFromServer({userId, password})`（已废弃） | `fetchLoggedInDevices({userId, token})` | 查询指定账号当前已登录的设备列表；已废弃别名与密码参数一并删除。 |
| `ChatClient.getInstance.fetchLoggedInDevices({userId, pwdOrToken, isPwd})` | `fetchLoggedInDevices({userId, token})` | 参数 `pwdOrToken` 改名为 `token`，`isPwd` 参数删除，接口固定走 Token 鉴权。 |
| `ChatClient.getInstance.kickDevice({userId, pwdOrToken, resource, isPwd})` | `kickDevice({userId, token, resource})` | 踢出指定账号的某一登录设备；通过设备列表获取 `resource`。 |
| `ChatClient.getInstance.kickAllDevices({userId, pwdOrToken, isPwd})` | `kickAllDevices({userId, token})` | 踢出指定账号的全部登录设备。 |

调用这些接口所需的目标用户 Token 应由可信的业务服务器提供，不应在客户端保存其他用户的密码。

## 推送与设备 Token

`ChatOptions` 中 8 个厂商推送开关全部删除，推送配置改为「初始化时配置证书名（仅 iOS）+ 运行时绑定设备 Token」：

| 4.x API | 5.0.0 替代方式 |
| :--- | :--- |
| `ChatOptions.enableAPNs(certName)` | `ChatOptions.apnsCertName`（初始化时配置，仅 iOS） |
| `ChatOptions.enableOppoPush(appKey, secret)`、`enableMiPush(appId, appKey)`、`enableMeiZuPush(appId, appKey)`、`enableFCM(appId)`、`enableVivoPush(agreePrivacyStatement)`、`enableHWPush()`、`enableHonorPush()` | `ChatPushManager.bindDeviceToken({required String deviceToken, String? notifierName})`，其中 `notifierName` 传厂商推送凭据（仅 Android 需要） |
| `ChatPushManager.updateHMSPushToken(...)`、`updateFCMPushToken(...)`、`updateAPNsDeviceToken(...)` | `ChatPushManager.bindDeviceToken({deviceToken, notifierName})` |

`ChatOptions` 不再序列化 `pushConfig` 字段，承载厂商推送 appId / appKey 的 `ChatPushConfig` 类已删除（注意：与之名称相近的 `ChatPushConfigs`（推送通知设置）仍存在，两者无关）。iOS 的两个证书名以**独立字段**回到 `ChatOptions`（`apnsCertName`、`pushKitCertName`），与原生 `EMOptions` 的同名属性一一对应，`pushConfig` 不恢复。

:::warning
**iOS 的证书名只能在初始化时设置，运行时不可修改**：`ChatOptions.apnsCertName` 与 `ChatOptions.pushKitCertName` 在调用 `ChatClient.init` 时下发给原生，绑定 token 时由原生直接读取该属性。因此：

- `bindDeviceToken` 的 `notifierName` 在 **iOS 上被忽略**（不再写入证书名）。升级后必须在 `ChatOptions` 中配置 `apnsCertName`，否则绑定失败（原生返回 `EMErrorUserIllegalArgument`，提示证书名为空）；
- 两个字段都是 `ChatClient.init` 的初始化配置，不可通过 `copyWith` 等方法在运行中修改，需要变更只能重新初始化 SDK。
:::

:::warning
`notifierName` 在 **Android 上是必填的厂商推送凭据**，既不是证书名也不是厂商标识串，传空或传错会直接导致推送不可用（原生返回参数非法错误）：

| 平台 / 厂商 | `notifierName` 取值 | 4.x 对应来源 |
| :--- | :--- | :--- |
| iOS | 忽略该参数，证书名见 `ChatOptions.apnsCertName` | `enableAPNs(certName)` 的 `certName` |
| Android FCM | Sender ID | `enableFCM(appId)` 的 `appId` |
| Android 小米 | App ID | `enableMiPush(appId, appKey)` 的 `appId` |
| Android 魅族 | App ID | `enableMeiZuPush(appId, appKey)` 的 `appId` |
| Android OPPO | App Key | `enableOppoPush(appKey, secret)` 的 `appKey` |
| Android 华为 HMS | App ID | 原生工程配置（`enableHWPush()` 无参） |
| Android 荣耀 | App ID | 原生工程配置（`enableHonorPush()` 无参） |
| Android VIVO | `App ID` + `#` + `App Key` | 原生工程配置（`enableVivoPush(agreePrivacyStatement)`） |

`deviceToken` 由厂商推送 SDK 或 APNs 在运行时返回，需业务自行接入对应推送插件获取。
:::

:::warning
厂商推送的**工程侧配置责任转移到业务侧**：Android 的厂商推送依赖与 manifest 配置、iOS 的推送证书与控制台配置都需先在原生工程侧完成，Flutter 侧只负责在 `ChatOptions` 里配置 iOS 证书名、以及在拿到 `deviceToken` 后调用 `bindDeviceToken`。`enableVivoPush(agreePrivacyStatement)` 这类「隐私声明同意」参数在 5.0.0 没有对应入口，需在原生工程配置中处理。
:::

```dart
// iOS：证书名在初始化时配置，绑定时不传 notifierName
final options = ChatOptions.withAppKey(
  appKey,
  apnsCertName: 'your_apns_cert_name', // 控制台配置的 APNs 证书名
);
await ChatClient.getInstance.init(options);
// ...
await ChatClient.getInstance.pushManager.bindDeviceToken(
  deviceToken: apnsDeviceToken,
);

// Android：notifierName 传厂商凭据（下例为 FCM Sender ID）
await ChatClient.getInstance.pushManager.bindDeviceToken(
  deviceToken: fcmToken,
  notifierName: fcmSenderId,
);
```

### PushKit（VoIP 推送）

VoIP 推送使用独立的 PushKit 证书与 PushKit token，与上面的普通推送（APNs / 厂商推送）不是同一套配置：`bindDeviceToken` 只处理普通推送 token，VoIP 推送需要下面这几个 **iOS 专用**入口。

4.x 的 Flutter SDK 未暴露 PushKit 能力（`ChatOptions` 与 `ChatPushManager` 都没有对应入口），5.0.0 新增：

| 新增 API | 接口说明 |
| :--- | :--- |
| `ChatOptions.pushKitCertName` | 控制台配置的 **PushKit 证书名**（不是 APNs 证书名）。与 `apnsCertName` 一样，仅初始化时生效、运行时不可修改。 |
| `ChatPushManager.bindPushKitToken({required String deviceToken})` | 绑定 PushKit token。`deviceToken` 传 `PKPushRegistry` 回调返回的 token（十六进制字符串）。 |
| `ChatPushManager.unbindPushKitToken()` | 解绑 PushKit token。`ChatClient.logout(unbindDeviceToken: true)` 已经会同时解绑，仅在用户保持登录状态、需要单独解绑时才调用。 |

使用要点：

- **仅 iOS 有效**：Dart 接口在其他平台直接返回、不做任何处理，跨平台代码无需自行判断平台；Android 侧的原生 SDK 没有 PushKit API，对应通道路由只会返回「不支持」错误（正常调用路径不可达）。
- PushKit token 需要业务在 iOS 工程侧自行实现 `PKPushRegistry`（`pushRegistry(_:didUpdate:for:)` 回调）拿到，再传入 Flutter 调用；Flutter SDK 不负责申请 VoIP 推送权限，证书也需在控制台与原生工程侧配置完成。
- 原生 SDK 会先缓存 token 再执行绑定：未登录时调用会抛错（用户未登录），但 token 已缓存，登录成功后 SDK 会自动完成绑定并带退避重试。
- 绑定失败最常见的原因是 `ChatOptions.pushKitCertName` 未配置或为空（原生返回 `EMErrorUserIllegalArgument`），其次是未登录（`EMErrorUserNotLogin`）。

```dart
// iOS：初始化时配置 PushKit 证书名
final options = ChatOptions.withAppKey(
  appKey,
  apnsCertName: 'your_apns_cert_name',
  pushKitCertName: 'your_pushkit_cert_name',
);
await ChatClient.getInstance.init(options);
// ...
// 拿到 PKPushRegistry 回调的 token 后绑定；保持登录状态下可单独解绑
await ChatClient.getInstance.pushManager.bindPushKitToken(
  deviceToken: voipPushToken,
);
await ChatClient.getInstance.pushManager.unbindPushKitToken();
```

## 其他删除的 API

### 无客户端替代

| 所属类 | 删除的 API | 接口说明 | 迁移建议 |
| :--- | :--- | :--- | :--- |
| `ChatClient` | `createAccount(userId, password)` | 注册 IM 账号。 | 通过服务端 REST API 完成注册。 |
| `ChatManager` | `reportMessage({messageId, tag, reason})` | 举报消息。 | 将消息 ID、举报类型和原因提交至 App Server。 |
| `ChatRoomManager` | `createChatRoom({...})` | 创建聊天室。 | 通过服务端 REST API 创建聊天室。 |
| `ChatRoomManager` | `destroyChatRoom(roomId)` | 解散聊天室。 | 通过服务端 REST API 解散聊天室。 |
| `ChatGroupManager` | `fetchPublicGroupsFromServer({pageSize, cursor})` | 分页获取服务端公开群组列表。 | 由业务服务维护可发现的群组目录。 |
| `ChatPushConfig` | `ChatOptions.pushConfig` 不再序列化，承载厂商推送 appId / appKey / 证书名的 `ChatPushConfig` 类（及 `EMPushConfig` 兼容 typedef）已删除。 | 初始化时配置厂商推送参数。 | iOS 证书名改由 `ChatOptions.apnsCertName` / `pushKitCertName` 承担，Android 厂商凭据改由 `ChatPushManager.bindDeviceToken` 承担。 |

### 有替代方式

| 4.x API | 5.0.0 API | 接口说明 | 迁移说明 |
| :--- | :--- | :--- | :--- |
| `ChatManager.fetchHistoryMessages({conversationId, type, pageSize, direction, startMsgId})`（已废弃） | `ChatManager.fetchHistoryMessagesByOption(conversationId, type, {options, cursor, pageSize = 50})` | 分页获取服务端历史消息。 | 旧接口删除，该接口是 5.0.0 保留的唯一漫游消息拉取入口，过滤条件改为 `FetchMessageOptions`。 |
| `ChatManager.searchMsgFromDB(...)`（已废弃） | `ChatManager.loadMessagesWithKeyword(...)` | 从本地数据库按关键词检索消息。 | 旧接口删除，改用新命名接口。注意该接口的发送者参数**仍为单个 `sender`**，只有 `ChatConversation.loadMessagesWithKeyword` 改成了 `senders` 列表。 |
| `ChatManager.getUnreadMessageCount()` | 统计范围收窄（见「行为变化」） | 获取本地未读消息总数。 | 签名不变，统计口径变化。 |
| `ChatManager.modifyMessage({messageId, msgBody, attributes})` | 同名同签名 | 修改本地和服务端消息。 | 签名未变（`attributes` 在 4.x 已存在），但 Android 侧的扩展字段行为有修正，见「行为变化」第 11 条；`msgBody` 与 `attributes` 不能同时为 `null`。 |
| `ChatContactManager.getAllContactsFromServer()`、`getAllContactsFromDB()`、`getBlockListFromServer()`、`getBlockListFromDB()`（均已废弃） | `getAllContactIds()`、`fetchBlockIds()`、`getBlockIds()` | 本地好友 ID、服务端黑名单、本地黑名单。 | 旧接口删除，改用新命名接口；`getAllContactsFromServer` 的替代者 `fetchAllContactIds` 本身也已在 5.0.0 删除，应改用本地 `getAllContactIds()`。 |
| `ChatGroupManager.changeGroupName(...)`、`changeGroupDescription(...)`（均已废弃） | `updateGroupName(groupId, name)`、`updateGroupDesc(groupId, desc)` | 修改群名称或群描述。 | 旧接口删除，改用新命名接口。 |
| `ChatEventHandler.onMessagesRecalled(List<ChatMessage>)`（已废弃） | `ChatEventHandler.onMessagesRecalledInfo(List<RecallMessageInfo>)` | 消息撤回回调。 | 回调负载由消息列表改为撤回信息列表。 |
| `ChatGroupEventHandler.onMemberJoinedFromGroup(...)`、`onMemberExitedFromGroup(...)`（参数已废弃） | `onMembersJoinedFromGroup(...)`、`onMembersExitedFromGroup(...)` | 群成员加入、退出回调。 | 使用支持一次通知多名成员的复数版本回调。 |
| `ChatGroup.name`、`ChatGroup.description`（已废弃） | `ChatGroup.groupName`、`ChatGroup.desc` | 群名称、群描述字段。 | 字段与构造参数一并删除，改用新字段名。 |
| `ChatConversation.loadMessagesWithKeyword(..., sender: ...)` 的 `sender` 参数 | `senders` 参数 | 按关键词搜索本地消息。 | 单个发送者改为发送者列表。**仅限 `ChatConversation` 的这个方法**；`ChatManager.loadMessagesWithKeyword` 仍使用单个 `sender`，不要跟着改。 |
| `FetchMessageOptions.from`（已废弃） | `FetchMessageOptions.senders` | 漫游消息的发送者过滤。 | 单个发送者改为发送者列表。 |
| `ChatGroupManager.fetchGroupInfoFromServer(groupId, fetchMembers: ...)`、`ChatRoomManager.fetchChatRoomInfoFromServer(roomId, fetchMembers: ...)` 的 `fetchMembers` 参数 | 同名方法（无 `fetchMembers` 参数） | 获取群组或聊天室详情。 | 参数删除，详情接口不再一并返回成员列表；需要成员时分页调用 `ChatGroupManager.fetchMemberListFromServer(groupId, {pageSize = 200, cursor})` 或 `ChatRoomManager.fetchChatRoomMembers(roomId, {cursor, pageSize = 200})`。 |
| `ChatImageMessageBody.thumbnailSecret` | `ChatImageMessageBody.secret` | 图片消息的附件密钥。 | 图片原图、大图、缩略图共用一个密钥，改用 `secret`；视频消息的 `thumbnailSecret` 未废弃，保持不变。 |
| `ChatMessage.groupAckCount()` | `ChatMessage.groupReadReceiptCount` | 群消息已读人数。 | 由异步方法改为同步只读属性。 |
| `ChatGroupManager.fetchJoinedGroupsFromServer({pageSize, pageNum, needMemberCount, needRole})` | `ChatGroupManager.getJoinedGroups()` | 获取已加入的群组列表。 | 分页服务端拉取接口删除，改用本地接口配合数据同步事件。 |
| 全部厂商推送 Token 接口：`updateHMSPushToken(...)`、`updateFCMPushToken(...)`、`updateAPNsDeviceToken(...)`（均已废弃） | `ChatPushManager.bindDeviceToken({deviceToken, notifierName})` | 上报推送设备 Token。 | 统一为一个入口；`notifierName` 仅 Android 需要（厂商推送凭据，**不是厂商标识串**），iOS 忽略该参数并在初始化时用 `ChatOptions.apnsCertName` 配置证书名，取值见「推送与设备 Token」一节。 |

## 主要新增 API

| 所属类 | 新增 API | 接口说明 |
| :--- | :--- | :--- |
| `ChatOptions` | `dataSyncType`、`ChatDataSyncType` | 配置登录后自动同步会话、好友和已加入群组，可按位组合。 |
| `ConnectionEventHandler` | `onDatabaseOpened`、`onDataSyncStart`、`onDataSyncFinish` | 监听本地数据库打开及自动数据同步的开始和结束。 |
| `ConnectionEventHandler` | `onDisconnected(int? errorCode, LoginExtensionInfo? info)` | 统一接收所有断开原因，并可区分「退出」与「连接断开」。 |
| `ChatDisconnectErrorCode` | 18 个原因码常量（13 个退出原因 + 5 个连接原因） | 断开原因码常量表，数值与平台 `EMError` 一致。 |
| `ChatManager` | `sendMessageReadReceipts(List<ChatMessage> messages)` | 批量发送单聊或群聊消息已读回执；最多 50 条且必须属于同一会话。 |
| `ChatManager` | `clearConversationUnreadMessageCount(conversationId)`、`clearAllConversationUnreadMessageCount()` | 清除指定会话或全部会话的本地未读数，并同步至当前账号其他设备，不向发送方发送消息已读回执。 |
| `ChatManager` | `getGroupMessageReadReceipts(List<ChatMessage> messages)` | 批量查询群消息已读回执汇总；最多 20 条且必须属于同一会话。 |
| `ChatManager` | `fetchGroupMessageReadReceipts(messageId, groupId, {cursor, pageSize})` | 分页获取群消息已读成员详情。 |
| `ChatManager` | `deleteConversations(List<String> conversationIds, {bool deleteMessages = true})` | 批量删除本地会话，可选择是否同时删除会话中的本地消息；不存在的会话 ID 会被忽略。 |
| `ChatConversation` | `name`、`avatar` | 获取会话展示名称和头像；单聊返回对端用户信息，群聊返回群组信息。相关数据未同步时可能为空。 |
| `ChatGroupManager` | `updateGroupConfigs({groupId, types, configs})` | 按 `ChatGroupConfigsType` 指定的字段更新群组配置。 |
| `ChatGroupConfigs`、`ChatGroupConfigsType` | — | 群组配置模型与配置字段位掩码。 |
| `ChatMessageReadReceipt`、`ChatGroupReadReceipt` | — | 统一的消息已读回执与群消息已读详情模型。 |
| `ChatCursorResult` | `totalCount` | 新增可空的分页结果总数；仅 `fetchGroupMessageReadReceipts` 的 iOS 实现返回，Android 为 `null`。 |
| `ChatMultiDevicesEvent` | `GROUP_UPDATE`、`CONVERSATION_UNREAD_MESSAGE_COUNT_CLEARED`、`ALL_CONVERSATION_UNREAD_MESSAGE_COUNT_CLEARED` | 群组更新与多设备未读数清理事件。 |
| `ChatOptions` | `apnsCertName`、`pushKitCertName` | iOS 专用：APNs 与 PushKit 推送证书名，仅初始化时生效、运行时不可修改；承接 4.x `enableAPNs(certName)` 与推送配置里的证书名。 |
| `ChatPushManager` | `bindDeviceToken({deviceToken, notifierName})` | 4.x 已存在的统一入口；5.0.0 起删除厂商推送开关后成为唯一入口，`notifierName` 改为可选且仅 Android 使用，并非新增 API。 |
| `ChatPushManager` | `bindPushKitToken({deviceToken})`、`unbindPushKitToken()` | iOS 专用：绑定与解绑苹果 PushKit（VoIP 推送）token，与普通推送 token 相互独立，详见「推送与设备 Token」一节。 |

## 监听器回调变化汇总

Flutter 侧的回调是事件处理器构造函数的命名参数：传入已删除的参数名会直接编译失败，未实现的回调则不会有任何提示。升级时应逐项检查事件处理器的构造位置，不要依赖「编译通过就说明没漏」。

| 监听器 | 4.x 回调 | 5.0.0 回调 | 回调说明 |
| :--- | :--- | :--- | :--- |
| `ConnectionEventHandler` | `onDisconnected()` | `onDisconnected(int? errorCode, LoginExtensionInfo? info)` | 断开回调签名变更，携带原因码。 |
| `ConnectionEventHandler` | `onUserDidLoginFromOtherDevice`、`onUserDidRemoveFromServer`、`onUserDidForbidByServer`、`onUserDidChangePassword`、`onUserDidLoginTooManyDevice`、`onUserKickedByOtherDevice`、`onUserAuthenticationFailed`、`onAppActiveNumberReachLimit` | 无（统一由 `onDisconnected` 承载） | 8 个按原因命名的回调全部删除，改为在 `onDisconnected` 内按 `errorCode` 分支。 |
| `ConnectionEventHandler` | 无 | `onDataSyncStart(int type)`、`onDataSyncFinish(int type, ChatError? error)`、`onDatabaseOpened(String username, ChatError? error)` | 数据同步与本地数据库打开通知。 |
| `ChatContactEventHandler` | `onContactSyncStart`、`onContactSyncFinish(ChatError?)` | `ConnectionEventHandler.onDataSyncStart`、`onDataSyncFinish` | 好友同步回调统一迁移至连接事件，并通过 `ChatDataSyncType.contacts` 识别类型。 |
| `ChatEventHandler` | `onMessagesRead(List<ChatMessage>)` | `onMessageReadReceipts(List<ChatMessageReadReceipt>)` | 统一接收单聊和群聊的消息已读回执。 |
| `ChatEventHandler` | `onGroupMessageRead(List<ChatGroupMessageAck>)` | `onMessageReadReceipts(List<ChatMessageReadReceipt>)` | 群聊消息已读回执。 |
| `ChatEventHandler` | `onReadAckForGroupMessageUpdated()` | `onMessageReadReceipts(List<ChatMessageReadReceipt>)` | 群聊消息已读回执状态变化通知。 |
| `ChatEventHandler` | `onConversationRead(String from, String to)` | 无直接替代 | 会话级已读回执回调已删除，按消息处理 `onMessageReadReceipts`。 |
| `ChatEventHandler` | `onMessagesRecalled(List<ChatMessage>)` | `onMessagesRecalledInfo(List<RecallMessageInfo>)` | 消息撤回回调的负载类型变更。 |
| `ChatGroupEventHandler` | `onMemberJoinedFromGroup(...)`、`onMemberExitedFromGroup(...)` | `onMembersJoinedFromGroup(...)`、`onMembersExitedFromGroup(...)` | 由单个成员参数改为成员列表，一次可通知多名成员变动。 |

:::tip
建议在升级后清理并重新注册全部事件处理器，避免残留的旧命名参数被静默忽略。事件处理器通过唯一 id 管理，重复注册同一 id 会覆盖旧实例：

```dart
ChatClient.getInstance.addConnectionEventHandler('app', ConnectionEventHandler(...));
ChatClient.getInstance.removeConnectionEventHandler('app');
```
:::

## 行为变化

以下变化多数不会触发编译错误，但会影响业务逻辑（第 4 条例外，赋值只读属性会直接编译失败）：

1. **未读消息总数的统计范围发生变化**

   `ChatManager.getUnreadMessageCount()` 获取本地单聊和群聊会话的未读消息总数。该接口的统计范围如下：

   - 不统计聊天室会话。
   - 不统计推送通知方式为 `ChatPushRemindType.MENTION_ONLY` 或 `ChatPushRemindType.NONE` 的会话。这些会话即使存在未读消息，也不纳入统计。
   - 仅统计推送通知方式为 `ChatPushRemindType.ALL` 的单聊和群聊会话。
   - 消息话题（Thread）会话**不在排除范围内**，其未读数按普通会话规则参与统计（若其提醒方式为 `ALL`）。

   如果业务需要其他统计口径，应遍历本地会话并根据会话类型和免打扰设置（`ChatConversation.remindType()`）自行累加未读数。

2. **清除未读数不会发送消息已读回执**

   `clearConversationUnreadMessageCount(conversationId)` 只清除指定会话的本地未读数，并将结果同步至当前账号的其他设备，不会向消息发送方发送已读回执。如需通知发送方，还需对消息调用 `sendMessageReadReceipts(messages)`。

3. **初始化后不再自动登录**

   `ChatClient.getInstance.init(options)` 完成后，SDK 不会依据历史登录记录自动登录。应用需要安全保存和更新 Token，并在适当时机主动调用 `loginWithToken(userId, token)`。

4. **消息已读状态不再允许应用直接修改**

   `ChatMessage.isRead` 与 `ChatMessage.isPeerRead` 在 5.0.0 中为只读属性（4.x 的公开可写字段 `hasRead` / `hasReadAck` 已删除，给新属性赋值会**编译失败**），`ChatConversation` 的逐条和全量标记已读接口也已删除。业务应使用会话未读数清理接口；消息已读回执则通过独立的批量回执接口发送。

5. **回执批次校验结果以原生 SDK 为准**

   5.0.0 不再由 Flutter 桥接层对回执批次做整体校验：批次中无法解析为本地消息的条目会被跳过，可解析的条目正常发送回执；当整批消息都无法解析时返回 `110 INVALID_PARAM`。业务不应假设整批操作原子成功或原子失败。

6. **自动同步完成前，本地列表可能不完整**

   `onDatabaseOpened` 只表示数据库可以访问。若 `dataSyncType` 包含相应类型，需要等待 `onDataSyncFinish` 成功（`error == null`）后，再将会话、好友或已加入群组的本地查询结果视为本次登录后的最新数据。

7. **登录成功与数据同步完成是两个阶段**

   `loginWithToken` 返回成功仅表示登录完成，不代表会话、好友或群组数据已经就绪。首屏展示应结合 `onDatabaseOpened`（读本地缓存）与 `onDataSyncFinish`（数据已更新）设计加载状态。

8. **群配置更新按字段生效**

   `updateGroupConfigs` 只更新 `types` 位掩码中包含的字段，未包含的字段保持服务端原值。提交前应明确本次要修改的字段，避免误以为未提交的字段会被重置为默认值。

9. **两个公开签名补齐了显式类型**

   4.x 中这两个成员的类型由初始化式隐式推断，5.0.0 补上了显式类型；依赖 dynamic 调用的代码需要同步调整：

   | 成员 | 4.x | 5.0.0 | 影响 |
   | :--- | :--- | :--- | :--- |
   | `ChatError.hasErrorFromResult(Map map)` | 返回类型隐式为 `dynamic` | `static void hasErrorFromResult(Map map)` | 把返回值赋给变量或参与表达式的写法会编译失败；正常情况下只作为语句调用。 |
   | `ChatPageResult.pageCount` | `get pageCount`（隐式 `dynamic`） | `int? get pageCount` | 赋给非空 `int` 变量或直接参与算术运算的写法需要通过 `??` 兜底。 |

10. **断开事件中的 `info` 以 `null` 表示「无设备信息」**

    `LoginExtensionInfo.fromJson` 不再对缺失字段做强断言（4.x 会因强制转换抛异常）。但 `onDisconnected` 的分发逻辑是：**当原生未携带 `deviceName`（或为空字符串）时，`info` 直接为 `null`**，不会交付一个 `deviceName == ''` 的对象。因此判断「是否有设备信息」只看 `info == null`，不要写 `info?.deviceName.isEmpty` 这类判断；`deviceName` 仍为非空 `String` 类型，非 `null` 时可直接使用。

11. **`modifyMessage` 不传 `attributes` 时不再清空消息扩展（Android）**

    原生语义是「`ext` 会覆盖原有扩展，传 `null` 表示不修改」。4.x 的 Android 桥接层在未传 `attributes` 时下发的是**空 Map**（相当于把消息扩展清空），iOS 下发的是 `nil`（不修改），两端不一致；5.0.0 两端统一为**不传则不修改**。如果业务曾依赖「只改 `msgBody` 顺手清掉扩展」的 Android 旧行为，升级后需显式传 `attributes: {}`。

## 已知限制与注意事项

下列行为已确认为当前版本的实际表现，接入时应避开而不是依赖：

- **不要用回执 / 已读详情接口探测消息是否存在**。传入本地不存在的 `messageId` 时两端行为不一致：`sendMessageReadReceipts` / `getGroupMessageReadReceipts` 会跳过无法解析的条目（整批都无法解析时返回 `110`）；`fetchGroupMessageReadReceipts` 在 iOS 上返回成功且结果集为空，在 Android 上由原生根据本地消息推导群 ID，消息不存在时可能直接崩溃（原生层空指针，Dart 侧 `try/catch` 无法拦住；该问题属原生侧，Flutter 层未做兜底）。请先用 `loadMessagesWithIds` 或会话消息列表确认消息在本地存在。
- **`ChatCursorResult.totalCount` 仅 iOS 有值**，Android 恒为 `null`，展示总已读数时需兜底。
- **PushKit 接口仅 iOS 有效**：`bindPushKitToken` / `unbindPushKitToken` 在 Dart 层对非 iOS 平台是空实现（Android 原生 SDK 没有对应的 PushKit 能力，其通道路由返回「不支持」错误）；VoIP 推送的证书申请、`PKPushRegistry` 注册与 token 获取都由业务侧 iOS 工程承担，Flutter SDK 只负责在初始化时下发证书名（`ChatOptions.pushKitCertName`），并把运行时拿到的 token 交给原生 SDK 绑定。
- **iOS 推送证书名不支持运行时修改**：`ChatOptions.apnsCertName` / `pushKitCertName` 只在 `ChatClient.init` 时下发给原生，`copyWith` 等运行期入口不会更新它们；`bindDeviceToken` 的 `notifierName` 在 iOS 上也不生效。
- **群字段读取存在平台差异**：iOS 上 `ChatGroup.maxUserCount` / `extension` 不下发（改读 `configs?.maxCount` / `configs?.ext`），`configs` 本身也可能为 `null`；Android 上 `configs.inviteNeedConfirm` 固定回传 `false`。详见「群组配置模型重构」一节的 warning。
- **`onMessageReadReceipts` 需要双账号场景才能观察到**：自己发、自己读不会产生已读回执事件，联调时请用另一个账号读取消息。
- **退出事件与登出存在时序竞态**：平台先派发事件、后完成登出，不要在 `onDisconnected` / `onTokenDidExpire` 里发起依赖登录态的调用（包括用 `isConnected()` / `getCurrentUserId()` 反推是否已退出）。

## 迁移检查清单

- [ ] 确认 `pubspec.yaml` 使用 `im_flutter_sdk: ^5.0.0`，并已重新执行 `flutter pub get`
- [ ] iOS 已重新执行 `pod install`（或使用 SPM 时确认解析到 `HyphenateChat_iOS 5.0.0`）
- [ ] 登录链路已全部切换为 `loginWithToken`，删除注册、密码登录与自动登录相关代码
- [ ] 应用自行管理 Token 的获取、缓存、过期与续期（`renewToken`）
- [ ] 已按需显式配置 `ChatOptions.dataSyncType`，不依赖两端不同的默认值
- [ ] 已在 `ConnectionEventHandler` 中实现 `onDisconnected` 分支与 `onTokenDidExpire`，并接入 `ChatDisconnectErrorCode`
- [ ] 会话、好友、群组列表改用本地接口读取，并挂接到 `onDataSyncFinish`；按 ID 取会话时已正确传入 `getConversation` 的 `type`
- [ ] 已读回执改用 `sendMessageReadReceipts`，未读数清理改用 `clearConversationUnreadMessageCount` / `clearAllConversationUnreadMessageCount`；按 ID 加载消息时已注意 `loadMessagesWithIds` 单次 20 条上限
- [ ] 群组创建与配置更新改用 `ChatGroupConfigs` 与 `updateGroupConfigs`，`ChatGroupStyle` / `ChatGroupOptions` / `ChatGroup.isMemberOnly` 引用已清理，并已处理群字段的可空与平台差异
- [ ] 设备管理与踢下线接口改为 Token 参数形式
- [ ] 推送配置改为 `ChatPushManager.bindDeviceToken`，已删除厂商推送开关引用；确认 `notifierName` 仅在 Android 使用、值为厂商凭据
- [ ] iOS 已在 `ChatOptions` 初始化时配置 `apnsCertName`（需要 VoIP 推送时还有 `pushKitCertName`），且未依赖运行期修改证书名
- [ ] 需要 VoIP 推送时，iOS 侧已实现 `PKPushRegistry` 并改用 `ChatPushManager.bindPushKitToken({deviceToken})`（与普通推送 token 相互独立，其他平台调用为空实现）
- [ ] Android 应用模块 `compileSdk` ≥ 34（原生 5.0.0 新增 androidx 传递依赖）
- [ ] 清理全部 `@Deprecated` 公开 API 的调用（推荐全局搜索 `EM` 前缀类型名与废弃方法名；`em_compat.dart` 中的 65 个 `EM*` typedef 本次仍保留，只有 `EMPushConfig` 随 `ChatPushConfig` 删除，改用 `Chat*` 名称属于长期建议而非本次强制项）
