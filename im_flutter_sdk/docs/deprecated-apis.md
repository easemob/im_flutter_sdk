# im_flutter_sdk 已作废（@Deprecated）API 清单报告

- 扫描范围：`im_flutter_sdk/lib/`（主包 Dart 公开 API 层）
- 扫描分支：`5.0.0`（worktree）
- 扫描方式：全量检索 `@Deprecated` / `@deprecated` 注解，共 11 个文件、97 处命中，逐条人工核对声明与替代 API
- 生成日期：2026-09-21

## 处理结果（5.0.0 分支，2026-09-21）

按「5.0.0 为主版本，不保留 `@Deprecated` 残壳」的口径删除下列 Dart 公开 API。改动范围仅 `im_flutter_sdk/lib`（另含 CHANGELOG 与本文件）；`ChatMethodKeys`/`chat_event_keys` 常量与 native 三端（interface/android/ios）未改动。

| 章节 | 处理 |
|---|---|
| 一、方法级作废（9 个） | 全部删除 |
| 二、字段 / 属性作废（5 项） | 删除 `ChatEventHandler.onMessagesRecalled`、`ChatGroup.name`、`ChatGroup.description`、`FetchMessageOptions.from`（第 5 项为同一构造参数，随之删除） |
| 三、构造函数 / 参数级作废 | 删除 `fetchMembers`（群组、聊天室）、`ChatGroup` 的 `name`/`description` 构造参数、`FetchMessageOptions` 的 `from` 构造参数、`ChatConversation.loadMessagesWithKeyword` 的 `sender` 参数、`ChatGroupEventHandler` 的 `onMemberExitedFromGroup`/`onMemberJoinedFromGroup` 参数 |
| 四、`ChatOptions` 推送开关（8 个） | 全部删除，统一改用 `ChatPushManager.bindDeviceToken` |
| 五、`em_compat.dart` 兼容层（66 个 typedef） | **保留 65 个**；`EMPushConfig` 随 `ChatPushConfig` 类删除而一并删除 |

保留项：`ChatOptions({required String appKey, ...})` 默认构造函数与 `em_compat.dart` 的 66 个 `EM*` typedef 仍带 `@Deprecated`，留待后续大版本处理。

行为变化提醒：

- `ChatGroup` 反序列化仍从 native 的 `name`/`desc` 取值，只是不再写入已删除的 `name`/`description` 字段；`toJson` 输出 key 不变。
- `fetchGroupInfoFromServer`/`fetchChatRoomInfoFromServer` 不再下发 `fetchMembers`，与 Android 端原有行为（本就忽略该参数）对齐。
- `loadMessagesWithKeyword` 只下发 `senders`，不再下发 `from`；native 侧 `from`/`sender` 兜底分支保留未动，成为不可达分支。
- `ChatOptions` 不再能配置厂商推送的 appId/appKey/证书名，也不再序列化 `pushConfig` 字段（native 侧读取分支保留未动，成为不可达分支）；承载这些配置的 `ChatPushConfig` 类连同 `lib/src/internal/chat_push_config.dart`、`inner_headers.dart` 的导出与 `em_compat.dart` 的 `EMPushConfig` typedef 一并删除。
- 随本轮 wrapper 废弃调用清理，`FetchMessageOptions` 删除后遗留的 native 侧分支也已移除：Android `EMFetchMessageOption.setFrom`、iOS `EMFetchServerMessagesOption.from`（native 5.0.0 均标记废弃，替代分别是 `setFromIds` / `fromIds`）。Android 图片消息的缩略图密钥（`thumbnailSecret`）本轮**保持现状**：替代 `getSecret` / `setSecret` 会改变取值，待确认使用方影响。详见 `docs/spec/2026-09-21-deprecated-api-scan-spec.md` §9.3。

本报告「附」中列的 3 类注解缺陷随 API 删除一并消失（`ChatGroup.name` 的替代写错、`onMemberExitedFromGroup` 自引用、两处 `fetchMembers` 空消息），无需再单独修正文案。

## 概览

| 分类 | 数量 | 位置 |
|---|---|---|
| 旧 `EM*` 命名兼容 typedef | 66 | `lib/em_compat.dart` |
| 公开方法（整个方法作废） | 9 | 各 Manager / Model |
| 字段 / 属性 | 5 | 各 Model / EventHandler |
| 构造函数 / 构造函数参数 / 方法参数 | 7 | 各 Model / Manager |

## 一、方法级作废（9 个）

| 作废 API | 位置 | 替代 API | 说明 |
|---|---|---|---|
| `ChatManager.searchMsgFromDB` | `lib/src/managers/chat_manager.dart:1177` | `ChatManager.loadMessagesWithKeyword` | 从本地数据库按关键词检索消息 |
| `ChatContactManager.getAllContactsFromDB` | `lib/src/managers/chat_contact_manager.dart:196` | `getAllContactIds` | 从本地数据库获取好友 ID 列表 |
| `ChatContactManager.getBlockListFromServer` | `lib/src/managers/chat_contact_manager.dart:321` | `fetchBlockIds` | 从服务器获取黑名单 |
| `ChatContactManager.getBlockListFromDB` | `lib/src/managers/chat_contact_manager.dart:388` | `getBlockIds` | 从本地数据库获取黑名单 |
| `ChatGroupManager.changeGroupName` | `lib/src/managers/chat_group_manager.dart:935` | `updateGroupName` | 修改群名称 |
| `ChatGroupManager.changeGroupDescription` | `lib/src/managers/chat_group_manager.dart:981` | `updateGroupDesc` | 修改群描述 |
| `ChatPushManager.updateHMSPushToken` | `lib/src/managers/chat_push_manager.dart:104` | `bindDeviceToken` | 更新华为推送 token |
| `ChatPushManager.updateFCMPushToken` | `lib/src/managers/chat_push_manager.dart:136` | `bindDeviceToken` | 更新 FCM 推送 token |
| `ChatPushManager.updateAPNsDeviceToken` | `lib/src/managers/chat_push_manager.dart:164` | `bindDeviceToken` | 更新 APNs 推送 token |

## 二、字段 / 属性作废（5 个）

| 作废字段 | 所属类 | 位置 | 替代字段 |
|---|---|---|---|
| `onMessagesRecalled` | `ChatEventHandler` | `lib/src/handlers/manager_event_handler.dart:417` | `onMessagesRecalledInfo`（回调负载由 `List<ChatMessage>` 变为 `List<RecallMessageInfo>`） |
| `name` | `ChatGroup` | `lib/src/models/chat_group.dart:50` | `groupName` |
| `description` | `ChatGroup` | `lib/src/models/chat_group.dart:95` | `desc` |
| `from` | `FetchMessageOptions` | `lib/src/models/fetch_message_options.dart:77` | `senders`（单个发送者 → 发送者列表） |
| `onMessagesRecalled`（构造参数同名） | — | 见上 | 同上 |

## 三、构造函数 / 参数级作废（7 处）

| 作废项 | 所属 API | 位置 | 替代 |
|---|---|---|---|
| `ChatOptions({required String appKey, ...})` 默认构造函数 | `ChatOptions` | `lib/src/models/chat_options.dart:1082` | `ChatOptions.withAppKey` 工厂构造 |
| 参数 `fetchMembers` | `ChatGroupManager.fetchGroupInfoFromServer` | `lib/src/managers/chat_group_manager.dart:459` | 无（`@Deprecated('')` 空消息，未指明替代） |
| 参数 `fetchMembers` | `ChatRoomManager.fetchChatRoomInfoFromServer` | `lib/src/managers/chat_room_manager.dart:365` | 无（`@Deprecated('')` 空消息，未指明替代） |
| 构造参数 `name` | `ChatGroup(...)` | `lib/src/models/chat_group.dart:17` | `groupName` |
| 构造参数 `description` | `ChatGroup(...)` | `lib/src/models/chat_group.dart:20` | `desc` |
| 构造参数 `from` | `FetchMessageOptions(...)` | `lib/src/models/fetch_message_options.dart:68` | `senders` |
| 参数 `sender` | `ChatConversation.loadMessagesWithKeyword` | `lib/src/models/chat_conversation.dart:699` | `senders` |

`ChatGroupEventHandler` 构造函数中还有两个作废的回调参数：

| 作废参数 | 位置 | 替代参数 |
|---|---|---|
| `onMemberExitedFromGroup` | `lib/src/handlers/manager_event_handler.dart:1560` | `onMembersExitedFromGroup` |
| `onMemberJoinedFromGroup` | `lib/src/handlers/manager_event_handler.dart:1562` | `onMembersJoinedFromGroup` |

## 四、ChatOptions 推送开关方法（8 个，统一替代为 `ChatPushManager.bindDeviceToken`）

位置均为 `lib/src/models/chat_options.dart`，作废消息均为 `Use [ChatPushManager.bindDeviceToken] instead.`：

| 作废方法 | 行号 | 用途 |
|---|---|---|
| `enableOppoPush(appKey, secret)` | 436 | OPPO 推送 |
| `enableMiPush(appId, appKey)` | 459 | 小米推送 |
| `enableMeiZuPush(appId, appKey)` | 482 | 魅族推送 |
| `enableFCM(appId)` | 500 | FCM 推送 |
| `enableVivoPush(agreePrivacyStatement)` | 518 | vivo 推送 |
| `enableHWPush()` | 532 | 华为推送 |
| `enableAPNs(certName)` | 545 | APNs 推送 |
| `enableHonorPush()` | 563 | 荣耀推送 |

## 五、`em_compat.dart` 旧命名兼容层（扫描时 66 个 typedef，现余 65 个）

`lib/em_compat.dart` 是 4.22.0 改名（`EM*` → `Chat*`，对齐海外版 agora_chat_sdk）时聚拢的兼容层，全部为 `@Deprecated('Use [Chat*] instead') typedef EM* = Chat*`，仅为兼容存量用户代码，将在未来大版本移除。清单如下：

| 旧名（作废） | 新名 |
|---|---|
| `EMChatEventHandler` | `ChatEventHandler` |
| `EMChatManager` | `ChatManager` |
| `EMChatRoom` | `ChatRoom` |
| `EMChatRoomEvent` | `ChatRoomEvent` |
| `EMChatRoomEventHandler` | `ChatRoomEventHandler` |
| `EMChatRoomManager` | `ChatRoomManager` |
| `EMChatRoomPermissionType` | `ChatRoomPermissionType` |
| `EMChatThread` | `ChatThread` |
| `EMChatThreadEvent` | `ChatThreadEvent` |
| `EMChatThreadEventHandler` | `ChatThreadEventHandler` |
| `EMChatThreadManager` | `ChatThreadManager` |
| `EMChatThreadOperation` | `ChatThreadOperation` |
| `EMClient` | `ChatClient` |
| `EMCmdMessageBody` | `ChatCmdMessageBody` |
| `EMCombineMessageBody` | `CombineMessageBody` |
| `EMConnectionEventHandler` | `ConnectionEventHandler` |
| `EMContact` | `ChatContact` |
| `EMContactChangeEvent` | `ChatContactChangeEvent` |
| `EMContactEventHandler` | `ChatContactEventHandler` |
| `EMContactManager` | `ChatContactManager` |
| `EMConversation` | `ChatConversation` |
| `EMConversationType` | `ChatConversationType` |
| `EMCursorResult<T>` | `ChatCursorResult<T>` |
| `EMCustomMessageBody` | `ChatCustomMessageBody` |
| `EMDeviceInfo` | `ChatDeviceInfo` |
| `EMDownloadCallback` | `ChatDownloadCallback` |
| `EMError` | `ChatError` |
| `EMFileMessageBody` | `ChatFileMessageBody` |
| `EMGroup` | `ChatGroup` |
| `EMGroupChangeEvent` | `ChatGroupChangeEvent` |
| `EMGroupEventHandler` | `ChatGroupEventHandler` |
| `EMGroupInfo` | `ChatGroupInfo` |
| `EMGroupManager` | `ChatGroupManager` |
| `EMGroupPermissionType` | `ChatGroupPermissionType` |
| `EMGroupSharedFile` | `ChatGroupSharedFile` |
| `EMImageMessageBody` | `ChatImageMessageBody` |
| `EMLocationMessageBody` | `ChatLocationMessageBody` |
| `EMMessage` | `ChatMessage` |
| `EMMessageBody` | `ChatMessageBody` |
| `EMMessageReaction` | `ChatMessageReaction` |
| `EMMessageReactionEvent` | `ChatMessageReactionEvent` |
| `EMMessageSenderInfo` | `ChatMessageSenderInfo` |
| `EMMultiDeviceEventHandler` | `ChatMultiDeviceEventHandler` |
| `EMMultiDevicesEvent` | `ChatMultiDevicesEvent` |
| `EMOptions` | `ChatOptions` |
| `EMPageResult<T>` | `ChatPageResult<T>` |
| `EMPresence` | `ChatPresence` |
| `EMPresenceEventHandler` | `ChatPresenceEventHandler` |
| `EMPresenceManager` | `ChatPresenceManager` |
| `EMPresenceStatusDetail` | `ChatPresenceStatusDetail` |
| `EMPushConfig`（本次已删除） | `ChatPushConfig`（本次已删除） |
| `EMPushConfigs` | `ChatPushConfigs` |
| `EMPushManager` | `ChatPushManager` |
| `EMSearchDirection` | `ChatSearchDirection` |
| `EMStreamChunk` | `ChatStreamChunk` |
| `EMStreamStatus` | `ChatStreamStatus` |
| `EMTextMessageBody` | `ChatTextMessageBody` |
| `EMTranslateLanguage` | `ChatTranslateLanguage` |
| `EMUserInfo` | `ChatUserInfo` |
| `EMUserInfoChangeEvent` | `ChatUserInfoChangeEvent` |
| `EMUserInfoEventHandler` | `ChatUserInfoEventHandler` |
| `EMUserInfoManager` | `ChatUserInfoManager` |
| `EMVideoMessageBody` | `ChatVideoMessageBody` |
| `EMVoiceFormat` | `ChatVoiceFormat` |
| `EMVoiceMessageBody` | `ChatVoiceMessageBody` |
| `EMVoiceParam` | `ChatVoiceParam` |

另有 4 个名称无法用 typedef 兼容，已在 4.22.0 直接改名（破坏性变更，无 `@Deprecated` 过渡），记录于 `em_compat.dart:4-8` 文件头注释：

| 旧名 | 新名 | 类型 |
|---|---|---|
| `convertIntToEMMultiDevicesEvent` | `convertIntToChatMultiDevicesEvent` | 函数 |
| `EMGroupPermissionTypeExtension` | `ChatGroupPermissionTypeExtension` | extension |
| `EMLog` | `ChatLog` | 类 |
| `EMTools` | `ChatTools` | 类 |

## 附：扫描中发现的问题（非作废清单本身，供参考）

1. **`ChatGroup.name` 字段的作废消息疑似笔误**（`lib/src/models/chat_group.dart:50`）：写的是 `Use [desc] instead`，但 `name` 的正确替代是 `groupName`（其构造函数参数处的注解 `lib/src/models/chat_group.dart:17` 写的就是 `Use [groupName] instead`）。
2. **`ChatGroupEventHandler.onMemberExitedFromGroup` 的作废消息自引用**（`lib/src/handlers/manager_event_handler.dart:1560`）：写的是 `Use onMemberExitedFromGroup instead`，指向了自己；实际替代参数是 `onMembersExitedFromGroup`（复数）。
3. **两处 `fetchMembers` 参数的作废消息为空**（`@Deprecated('')`）：`chat_group_manager.dart:459` 和 `chat_room_manager.dart:365`，使用者无法从注解得知替代方案，建议补充说明。
