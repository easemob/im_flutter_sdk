# 5.0.0 平版 · 阶段二：Flutter 基线调查与跨端契约

- 目标仓库：`/Users/asterisk/Codes/zuoyu_flutter/im_flutter_sdk/.worktree/5.0.0`
- 分支：`5.0.0`，基线 `flutter2_stable@53b88ac7`
- Flutter 目标版本：`5.0.0`
- 输入：`01-api-diff.md`（171 项：include 70 / defer 101）及两端 migration guide
- 规则：5.0.0 为主版本；native 已删除的公开 API 在 Flutter 同步删除，不保留 deprecated 残壳。

## 1. native 依赖 bump 与发布核验

| 位置 | 原版本 | 目标版本 | 状态 |
| --- | --- | --- | --- |
| `im_flutter_sdk_ios/ios/im_flutter_sdk_ios.podspec` | `HyphenateChat 4.24.1` | `5.0.0` | 已修改 |
| `im_flutter_sdk_ios/ios/im_flutter_sdk_ios/Package.swift` | `HyphenateChat_iOS 4.24.1` | `5.0.0` | 已修改 |
| `im_flutter_sdk_android/android/build.gradle` | `hyphenate-chat 4.24.1` | `5.0.0` | 已修改 |

三处修改前一致，修改后也一致。SPM 发布仓库已用
`git ls-remote --tags https://github.com/easemob/HyphenateChat_iOS.git refs/tags/5.0.0 refs/tags/5.0.0^{}`
核实 tag 存在（tag object `8a199671`，peeled commit `172f3e8a`）。CocoaPods 与 Maven 可用性由阶段四真实构建继续实证。

## 2. 基线与已知问题

- 四包当前版本均为 `4.24.0`，阶段三统一升为 `5.0.0`；iOS podspec `s.version` 同步修改。
- 桥接链路固定为 `Dart API → ChatMethodKeys → MethodChannel → Android/iOS MethodKey → Wrapper → native SDK`，不改架构。
- 方法返回继续使用 `{<方法名 key>: object}`；事件继续使用现有聚合 channel + 事件 key。
- JSON 沿用 Flutter 现有 camelCase 习惯，不采用 React Native 的 snake_case。
- KI-108/KI-109 命中：密码登录、注册、自动登录同步删除。
- KI-110 命中：Flutter 仍保持 CocoaPods/SPM 双集成；5.x 推荐 SPM，但不在插件内替用户切换。
- KI-107 未命中：`useAgoraChatDomain` 不作为公开配置项。
- KI-111 已规避：替代 API 均以 tag 源码 grep 为准；不存在的 `onReadReceiptForGroupMessageUpdated` 不实现。

## 3. 冻结契约

### 3.1 client / options

删除公开 Dart API 及三端残留路由：

- `createAccount`、密码版 `login`/`loginWithPassword`、`loginWithAgoraToken`；`loginWithToken` 保留，底层固定走 token 登录。
- `isLoggedInBefore`；初始化后不再自动登录。
- 密码获取 token、service check、statistics 模块：Flutter 基线无公开封装，grep 关闭为无代码动作。
- `ChatOptions.autoLogin`、`requireAck`、`enableAutoSyncContacts`，以及 `ChatClient.updateRequireAckSetting`。

保留并调整：

- `renewAgoraToken` 改名为 `renewToken(String token)`；MethodChannel key 仍为 `renewToken`。
- `fetchLoggedInDevices`、`kickDevice`、`kickAllDevices` 只接收 token，删除 `isPassword`/密码分支；payload key 固定为 `userId`、`token`、可选 `resource`。
- Android `areaCode` 由 int 显式映射到 `EMOptions.AreaCode`；Dart 公开 `ChatAreaCode` 常量值保持不变。

新增数据同步配置：

```dart
class ChatDataSyncType {
  static const int none = 0;
  static const int conversations = 1;
  static const int contacts = 2;
  static const int joinedGroups = 4;
}
```

- `ChatOptions.dataSyncType` 类型为 `int?`，允许按位或；JSON key 为 `dataSyncType`。
- 未传时不主动补默认值，保留 native 差异（iOS 默认 conversations，Android 默认 none）。
- Android 用 `EMDataSyncType.fromNativeMask(int)`；iOS 直接赋 `EMOptions.dataSyncType`。

连接事件新增到 `ConnectionEventHandler`：

| 事件 key | Dart 回调 | 负载 |
| --- | --- | --- |
| `onDataSyncStart` | `onDataSyncStart(int type)` | `{type}` |
| `onDataSyncFinish` | `onDataSyncFinish(int type, ChatError? error)` | `{type, error}`；Android errorCode 转 ChatError，iOS error 直接序列化 |
| `onDatabaseOpened` | `onDatabaseOpened(String username, ChatError? error)` | `{username, error}`；Android成功时 error 缺省 |

### 3.2 已读回执与消息模型

删除三端旧 API/路由/事件：

- `sendMessageReadAck`、`sendGroupMessageReadAck`、`sendConversationReadAck`、`markAllConversationsAsRead`。
- `ChatConversation.markMessageAsRead`、`markAllMessagesAsRead`。
- `fetchGroupAcks`、消息 `groupAckCount` 查询路由。
- `onMessagesRead`、`onGroupMessageRead`、`onConversationRead`、`onReadAckForGroupMessageUpdated`。
- 不实现 migration guide 中不存在于 tag 的 `onReadReceiptForGroupMessageUpdated`。

新增方法名 key（三端逐字一致）及 Dart API：

| key / Dart API | 请求 JSON | 返回 JSON |
| --- | --- | --- |
| `sendMessageReadReceipts(List<ChatMessage> messages)` | `{msgIds: [String]}`，wrapper 按 id 从本地库取 native message；≤50、同一会话 | void |
| `clearConversationUnreadMessageCount(String conversationId)` | `{conversationId}` | void |
| `clearAllConversationUnreadMessageCount()` | `{}` | void |
| `getGroupMessageReadReceipts(List<ChatMessage> messages)` | `{msgIds: [String]}`；≤20、同一会话 | `{getGroupMessageReadReceipts: [receipt...]}` |
| `fetchGroupMessageReadReceipts(messageId, groupId, {pageSize=20, cursor=''})` | `{messageId, groupId, pageSize, cursor}` | `{fetchGroupMessageReadReceipts: {cursor, list, totalCount?}}`；`ChatCursorResult.totalCount` 为可空字段，仅 iOS 返回，Android 为 null |

事件：`onMessageReadReceipts`，负载 `{receipts: [...]}`，Dart 回调
`ChatEventHandler.onMessageReadReceipts(List<ChatMessageReadReceipt>)`。

JSON 模型契约：

- `ChatMessageReadReceipt`：`messageId`、`conversationId`、`isPeerReceipt`、`readCount`。
- `ChatGroupMessageAck` 删除，新增 `ChatGroupReadReceipt`：字段 `messageId/receiptId/from/readCount/timestamp`；JSON key 为 `msgId/ack_id/from/count/timestamp`，其中 `from` 是 `GroupMemberInfo` 对象，`content` 删除。
- `ChatMessage.hasReadAck/hasRead/needGroupAck/groupAckCount` 改为
  `isPeerRead/isRead/isNeedReadReceipt/groupReadReceiptCount`，JSON key 同名。
- `isPeerRead`、`isRead`、`groupReadReceiptCount` 只读；反序列化 native message 时不调用 native setter。`isNeedReadReceipt` 是唯一保留的可写 read-receipt 属性。
- Android `isRead()` 为正向语义，禁止沿用旧 `!isUnread()` 取反逻辑。

### 3.3 conversation / chat

删除服务端旧拉取与旧历史消息 API：

- `fetchAllConversations`、分页/游标/置顶服务端会话拉取及 `fetchConversationsByOptions`（native 5.0.0 已删除对应服务端 filter API）；改用本地会话和数据同步事件。
- 旧 `fetchHistoryMessages`；保留 `fetchHistoryMessagesByOption`。
- `reportMessage`；举报交给业务服务。

保留/调整：

- `modifyMessage` 增加可选 `Map<String, dynamic>? attributes`，JSON key `attributes`；native body 与 ext 至少一个非 null。
- `resendMessage` Dart API 保留；iOS wrapper 改调 `sendMessage`（native 已删除 resend API）。
- `ChatConversation` 新增只读 `name`、`avatar`，JSON key 同名；iOS 调实例方法 `conversationName`/`conversationAvatar`，Android 调 getter。
- iOS 会话列表回调改由 `EMConversationDelegate` 注册，Dart `onConversationsUpdate` 不变。
- `getUnreadMessageCount` Dart 已有，签名不变；5.0.0 新统计范围写入 CHANGELOG。

### 3.4 group

删除 `ChatGroupStyle`、`ChatGroupOptions`、旧 `settings/options` JSON 与兼容 typedef；新增：

```dart
class ChatGroupConfigs {
  final int maxCount;                 // 200
  final bool inviteNeedConfirm;
  final String? ext;
  final bool isPublic;                // false
  final bool joinApprovalRequired;    // false
  final bool allowInvites;            // false
}

class ChatGroupConfigsType {
  static const int allowInvites = 1;
  static const int maxUsers = 2;
  static const int inviteNeedConfirm = 4;
  static const int joinApprovalRequired = 8;
  static const int isPublic = 16;
  static const int ext = 32;
}
```

- configs JSON key：`maxCount/inviteNeedConfirm/ext/isPublic/joinApprovalRequired/allowInvites`。
- 双端 native 默认值不一致；Flutter 固定默认 `inviteNeedConfirm=false`、`ext=null` 以延续 4.x Dart 行为，wrapper 显式赋值，不依赖 native 默认值。RN 5.0.0 采用同一上层默认，2026-09-17 对照后复用该结论。
- `ChatGroup.configs` 使用 JSON key `configs`；顶层保留 `isDisabled`。
- `isMemberOnly` 改为 `isJoinApprovalRequired`；`isPublic`、`isMemberAllowToInvite` 继续为顶层只读字段。
- `createGroup` 参数 `options` 改为 `configs`，请求 key 同步改为 `configs`，继续携带 avatar。
- 新增 `updateGroupConfigs(groupId, types, configs)`；key `updateGroupConfigs`，payload `{groupId, types, configs}`，返回 `ChatGroup`。
- iOS configs type 掩码可直传；Android 枚举位序不同，必须逐位映射，禁止把 Dart/iOS 掩码直接传给 `toNativeMask`。
- 删除 `fetchJoinedGroupsFromServer`、`fetchPublicGroupsFromServer`。
- `onRequestToJoinDeclinedFromGroup` 负载增加 `applicant`；Dart 回调参数固定为 `(groupId, groupName, decliner, reason, applicant)`。
- 旧单成员 join/leave native 回调删除，继续使用现有多成员回调。

### 3.5 contact / room / multi-device

- contact 删除 `getAllContactsFromServer`、`fetchAllContacts`、`fetchContacts`；保留本地联系人 API。
- contact 删除 `onContactSyncStart/onContactSyncFinish`，统一使用连接级 data sync 事件。
- room 删除 `createChatRoom/destroyChatRoom`；Android `getAllChatRooms` 若仅为无公开 Dart 调用的残余路由则同步清除。
- `ChatMultiDevicesEvent` 增加会话未读数清理事件值 65、全部会话未读数清理事件值 66；现有事件负载不变。

## 4. defer 与编译强制项

- `01-api-diff.md` 的 101 个单端 defer 默认不新增 Flutter 公开 API。
- native 5.0.0 删除导致现有 wrapper 无法编译时，允许做最小强制适配，并在 `03-implementation.md` 逐项记录；典型项包括 iOS resend/conversation delegate/push completion、Android areaCode/getAllChatRooms/监听器旧重载。
- Android-only `getDeviceInfo`、`asyncDeleteConversations` 等不平版；iOS-only大批同步方法不平版。
- 所有无法自动确认的语义进入验收报告，不在实现过程中暂停。

## 5. 导出、版本和 example

- 新模型加入 `im_flutter_sdk.dart` 与 `inner_headers.dart` 所需导出链；删除模型移除导出及 `em_compat.dart` typedef。
- 四包 `pubspec.yaml` 和 iOS podspec `s.version` 同步为 `5.0.0`。
- 四包 CHANGELOG 用中文；主包明确列出密码/自动登录、回执、群配置、服务端拉取删除等 breaking changes。
- example 注册新增 API；删除 API 的注册项和 token/password 配置路径同步清理。功能脚本仅在已有 config 可安全复制/使用时执行。

## 6. hooks 与阶段二门禁

已安装 `.codex/hooks.json`，脚本绝对路径为
`/Users/asterisk/Codes/zuoyu_flutter/.agents/skills/platform-sdk-porting-v2/hooks/porting_guard.sh`。
需在 Codex `/hooks` 审查并信任；本次同时手动执行相同 gate。

```text
$ echo '{}' | bash /Users/asterisk/Codes/zuoyu_flutter/.agents/skills/platform-sdk-porting-v2/hooks/porting_guard.sh gate flutter /Users/asterisk/Codes/zuoyu_flutter/im_flutter_sdk/.worktree/5.0.0
（无输出）
gate_exit=0
$ git branch --show-current
5.0.0
```

阶段二开始前主工作区干净；当前 `git status` 仅包含本任务的依赖 bump、hooks 与阶段文档。契约至此冻结，无“待猜”项。
