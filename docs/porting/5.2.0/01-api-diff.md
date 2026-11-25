# 01 - 公开 API Diff（5.1.0 → 5.2.0 / SDK_5.1.0 → SDK_5.2.1）

- 任务：im_flutter_sdk 官方线 5.2.0 平版
- iOS 源：`emclient-ios` `5.1.0`(e88b1dcc) → `5.2.0`(ceaeaaf1)，区间内无中间 tag（按 `git tag` 列表核对：5.0.0、5.1.0、5.2.0，无跳版）
- Android 源：`emclient-android` `SDK_5.1.0`(a8db682f) → `SDK_5.2.0` → `SDK_5.2.1`(c5bf77cf)，两跳逐一覆盖（SDK_5.2.0→SDK_5.2.1 仅 `EMClient.VERSION` 字符串 5.2.0→5.2.1，无 API 变更）
- diff 范围：iOS `newSDK/HyphenateSDK/` 公开头文件（排除 `*+Internal.h`）；Android `hyphenatechatsdk/src/com/hyphenate/` 根包 + `chat/` 子包（排除 `adapter/`、`core/`）

## 变更清单

### iOS（5.1.0 → 5.2.0）

| id | 类型 | 领域 | iOS 源签名 | 决策 | 状态 |
|---|---|---|---|---|---|
| `msg_body_type_multibody` | new_enum_value | chat | `EMMessageBodyType` 新增 `EMMessageBodyTypeMultiBody`（非具体消息体类型，仅由 `contentType` 返回，Core 枚举无对应值） | include | pending |
| `msg_bodies` | new_property | chat | `@property (nonatomic, strong) NSArray<EMMessageBody *> * _Nonnull bodies`（完整有序消息体列表，首元素即 `body`） | include | pending |
| `msg_content_type` | new_property | chat | `@property (nonatomic, readonly) EMMessageBodyType contentType`（按消息体数量实时计算；多体→MultiBody，单体→该体类型，无体兜底 Text） | include | pending |
| `msg_append_body` | new_api | chat | `- (void)appendBody:(EMMessageBody * _Nonnull)body`（列表末尾追加，发送前调用） | include | pending |
| `msg_init_with_bodies` | new_api | chat | `- (instancetype _Nullable)initWithConversationID:(NSString *)aConversationId bodies:(NSArray<EMMessageBody *> *)aBodies ext:(NSDictionary * _Nullable)aExt` | include | pending |
| `client_is_connected_deprecated` | deprecated_api | client | `isConnected` 标记 `__deprecated_msg("Use -connectionState instead")`（未删除） | 见未匹配清单 | pending |
| `client_connection_state` | new_property | client | `@property (nonatomic, readonly) EMConnectionState connectionState` | include | pending |
| `connection_state_connecting` | new_enum_value | client | `EMConnectionState` 新增 `EMConnectionConnecting = 2` | include | pending |
| `option_disconnect_notify_threshold` | new_property | client | `@property (nonatomic) NSInteger disconnectNotifyThreshold`（断开通知宽限秒数，默认 10） | include | pending |
| `option_chatroom_conversation_doc` | doc_change | client | `enableChatroomConversation` 语义重定义：由"是否为聊天室消息创建会话"改为"本地会话列表是否包含聊天室会话"（仅文档，签名不变） | include（同步注释） | pending |
| `chat_download_doc` | doc_change | chat | `IEMChatManager` 发送/下载系列方法（sendMessage、downloadThumbnail、downloadAttachment、downloadMessageBigImage）文档补充多消息体语义（仅文档，签名不变） | include（同步注释） | pending |

### Android（SDK_5.1.0 → SDK_5.2.1）

| id | 类型 | 领域 | Android 源签名 | 决策 | 状态 |
|---|---|---|---|---|---|
| `msg_type_multibody` | new_enum_value | chat | `EMMessage.Type` 新增 `MULTIBODY`（非具体消息体类型，Core 枚举无对应值） | include | pending |
| `msg_get_type_changed` | changed_api | chat | `Type getType()` 行为变更：多消息体返回 `MULTIBODY`（原只按首个消息体） | include | pending |
| `msg_get_content_type` | new_api | chat | `Type getContentType()`（委托 `getType()`，行为一致） | include | pending |
| `msg_get_bodies` | new_api | chat | `List<EMMessageBody> getBodies()`（完整有序只读列表，首元素即 `getBody()`） | include | pending |
| `msg_create_multibody` | new_api | chat | `static EMMessage createMultiBodySendMessage(String to, List<EMMessageBody> bodies)`（默认单聊，可 setChatType 改；无 ext 参数） | include | pending |
| `msg_add_body_changed` | changed_api | chat | `void addBody(EMMessageBody)` 行为变更：由"等价 setBody（替换为单体）"改为"追加到列表末尾" | include | pending |
| `msg_set_bodies` | new_api | chat | `void setBodies(List<EMMessageBody> bodies)`（替换整个列表） | include | pending |
| `msg_append_body` | new_api | chat | `void appendBody(EMMessageBody body)`（列表末尾追加） | include | pending |
| `msg_set_body_doc` | doc_change | chat | `setBody(EMMessageBody)` 语义明确为"替换整个列表为单个消息体"（文档，实现同步调整） | include（同步注释） | pending |
| `client_is_connected_deprecated` | deprecated_api | client | `boolean isConnected()` 标记 `@Deprecated`（未删除），指向 `getConnectionState()` | 见未匹配清单 | pending |
| `client_get_connection_state` | new_api | client | `EMConnectionState getConnectionState()` | include | pending |
| `connection_state_enum` | new_class | client | 新增枚举类 `EMConnectionState`（`DISCONNECTED`/`CONNECTING`/`CONNECTED`） | include | pending |
| `option_disconnect_notify_threshold` | new_api | client | `void setDisconnectNotifyThreshold(int seconds)` / `int getDisconnectNotifyThreshold()`（默认 10，≤0 关闭延迟） | include | pending |
| `option_use_push_in_background` | new_api | push | `void setUsePushInBackground(boolean)` / `boolean isUsePushInBackground()`（退后台断长连接走推送通道） | 待决策（见未匹配清单） | pending |
| `option_chatroom_conversation_doc` | doc_change | client | `setEnableChatroomConversation`/`isEnableChatroomConversation` 语义重定义（同 iOS，仅文档） | include（同步注释） | pending |
| `option_userinfo_doc_trim` | doc_change | client | 用户信息自动管理 get/set 方法删除"关闭后的影响"说明列表（仅文档删减） | skip（Flutter 侧无此段说明，无动作） | pending |
| `chat_download_doc` | doc_change | chat | `EMChatManager.AttachmentDownloadType` 及下载方法文档补充多消息体语义（仅文档，无公开签名变更） | include（同步注释） | pending |
| `version_5_2_1` | version_bump | client | `EMClient.VERSION` 5.2.0 → 5.2.1（SDK_5.2.0→SDK_5.2.1 唯一变更） | n/a（依赖 bump 到 5.2.1） | pending |

## 未匹配清单

1. **`option_use_push_in_background`（Android 独有）**：iOS 无对应 API。Android `EMOptions.setUsePushInBackground` 控制退后台断开长连接走推送。是否平版到 Dart 侧（可作为 Android-only option），待用户决策。
2. **`isConnected` 废弃处理**：iOS/Android 均仅标记废弃未删除。Flutter 基线是否已有 `isConnected`、是否同步标记 `@Deprecated` 并引导至新 API，待基线调查后在验收报告列举决策。
3. **连接状态枚举取值两端不一致**：iOS `Connected=0, Disconnected=1, Connecting=2`；Android `DISCONNECTED=0, CONNECTING=1, CONNECTED=2`（枚举 ordinal 即值）。Dart 侧须定义自有枚举并按平台分别映射，不能透传 native 整数值。
4. **复合消息创建入口形态不一致**：iOS 为构造器 `initWithConversationID:bodies:ext:`（带 ext）；Android 为静态工厂 `createMultiBodySendMessage(to, bodies)`（不带 ext，需另行设置属性）。Dart 侧 API 形态需在契约阶段统一（建议跟随 iOS 形态：conversationId/to + bodies + ext）。
5. **iOS `bodies` 为 readwrite property、Android 为 `getBodies()`+`setBodies()`**：取值形态一致（有序列表，首元素即 body），Dart 侧映射无歧义，仅记录。
6. **`EMPushHelper.isPushTokenBound()`**（`push/` 包，超出既定 diff 范围）：5.2.0 新增的公开方法，与 usePushInBackground 配套。是否平版待用户决策，与第 1 条合并处理。

未匹配清单非空，各条理由已列明，随验收报告交用户决策。
