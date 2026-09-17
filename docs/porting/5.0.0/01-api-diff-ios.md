# iOS 公开 API Diff：4.24.1 → 5.0.0

## 1. 头部信息

- **diff 锚点**：
  - `4.24.1` = `ba235111d262f52d0d4aaeb8045a1b25b1ef1929`
  - `5.0.0` = `f8f506ccb009db38d47280ab713a65e468287f4b`
- **中间 tag 核对**：`git tag -l` 显示 4.24.1 与 5.0.0 之间仅有 `4.24.2`（`90bb2d911f6ca2b02355960b581f5703927fbf4a`）。核对结论：
  - `4.24.1 → 4.24.2` 仅改动 `UserInfoManager/EMUserInfoManager.mm`（+2 行实现代码），**无任何公开头文件变化**。
  - `4.24.2` 不在 5.0.0 的祖先链上（`git merge-base --is-ancestor 4.24.2 5.0.0` 为否，merge-base 为 `4141d8db6`），即 4.24.2 是侧分支 hotfix tag；其唯一改动在 5.0.0 主线中不存在（`4.24.2 → 5.0.0` 的 diff 显示该 2 行被"减回去"）。
  - 结论：**无跳版遗漏**，`4.24.1 → 5.0.0` 的直接 diff 覆盖全部公开 API 变化。
- **diff 范围**：`newSDK/HyphenateSDK/` 下公开头文件（`EM*.h`、`IEM*.h`），排除 `*+Private.h` / `EMChatMessage+Private.h` 等内部头文件与所有 `.mm` 实现文件。已用 `git ls-tree` 分别列出 4.24.1 与 5.0.0 的全部头文件并比对，5.0.0 目录结构无新增公开目录；`pushExtension/`、`translate/` 两个目录（含公开头文件）在两 tag 间**零改动**，不在本清单内。
- **迁移文档**：`/Users/asterisk/Codes/zuoyu/easemob-doc/docs/document/ios/migration_guide.md`（下表"迁移文档依据"列引用其章节名）。
- **总体规模**：58 个文件变更，+1022 / −4667 行（含实现）。公开头文件层面：新增 4 个头文件（`EMConversationDelegate.h`、`EMMessageReadReceipt.h`、`EMMessageReadReceipt+Private.h`(内部)、`EMGroupConfigs.h`），删除 4 个头文件（`EMGroupOptions.h`、`Statistics/` 下 3 个），改名 1 个（`EMGroupMessageAck.h` → `EMGroupReadReceipt.h`）。

## 2. 变更清单

### client（EMClient.h / EMClientDelegate.h）

| id | 类型 | iOS 源签名 | 迁移文档依据 | 备注 |
| --- | --- | --- | --- | --- |
| client_register_with_username | removed | `- (EMError *_Nullable)registerWithUsername:(NSString * _Nonnull)aUsername password:(NSString * _Nonnull)aPassword;` | 初始化与登录-密码登录下线 | 同步注册 |
| client_register_with_username_completion | removed | `- (void)registerWithUsername:(NSString *_Nonnull)aUsername password:(NSString *_Nonnull)aPassword completion:(void (^_Nullable)(NSString * _Nonnull aUsername, EMError * _Nullable aError))aCompletionBlock;` | 同上 | 异步注册；改用服务端 REST |
| client_fetch_token_with_username_password | removed | `- (void)fetchTokenWithUsername:(NSString *_Nonnull)aUsername password:(NSString *_Nonnull)aPassword completion:(void (^_Nullable)(NSString * _Nullable aToken, EMError * _Nullable aError))aCompletionBlock;` | 同上 | |
| client_login_with_username_password | removed | `- (EMError *_Nullable)loginWithUsername:(NSString *_Nonnull)aUsername password:(NSString *_Nonnull)aPassword EM_DEPRECATED_IOS(3_0_0, 4_5_0,"Use -EMClient loginWithUsername:token:completion instead");` | 同上 | 4.x 已 deprecated |
| client_login_with_username_password_completion | removed | `- (void)loginWithUsername:(NSString *_Nonnull)aUsername password:(NSString *_Nonnull)aPassword completion:(void (^_Nullable)(NSString * _Nonnull aUsername, EMError *_Nullable aError))aCompletionBlock EM_DEPRECATED_IOS(3_0_0, 4_5_0,"Use -EMClient loginWithUsername:token:completion instead");` | 同上 | |
| client_login_with_username_token_sync | removed | `- (EMError *_Nullable)loginWithUsername:(NSString *_Nonnull)aUsername token:(NSString *_Nonnull)aToken;` | 同上 | 同步 token 登录；5.0.0 仅保留 `loginWithUsername:token:completion:` |
| client_login_with_username_agora_token | removed | `- (EMError *_Nullable)loginWithUsername:(NSString *_Nonnull)aUsername agoraToken:(NSString *_Nonnull)aAgoraToken EM_DEPRECATED_IOS(3_8_9, 4_2_0,"Use -EMClient loginWithUsername:token instead");` | 同上 | |
| client_login_with_username_agora_token_completion | removed | `- (void)loginWithUsername:(NSString *_Nonnull)aUsername agoraToken:(NSString *_Nonnull)aAgoraToken completion:(void (^_Nullable)(NSString * _Nonnull aUsername, EMError *_Nullable aError))aCompletionBlock EM_DEPRECATED_IOS(3_8_9, 4_2_0,"Use -EMClient loginWithUsername:token:completion instead");` | 同上 | |
| client_service_check | removed | `- (void)serviceCheckWithUsername:(NSString *_Nonnull)aUsername password:(NSString *_Nonnull)aPassword completion:(void (^_Nullable)(EMServerCheckType aType, EMError *_Nullable aError))aCompletionBlock __deprecated_msg("This method is deprecated");` | 同上 | 连同 `EMServerCheckType` 枚举（5 个值）一起删除 |
| client_server_check_type_enum | removed | `typedef NS_ENUM(NSInteger, EMServerCheckType) { EMServerCheckAccountValidation = 0, EMServerCheckGetDNSListFromServer, EMServerCheckGetTokenFromServer, EMServerCheckDoLogin, EMServerCheckDoLogout, };` | 同上 | |
| client_is_auto_login | removed | `@property(nonatomic, readonly) BOOL isAutoLogin;` | 初始化与登录-自动登录移除 | |
| client_statistics_manager | removed | `@property (nonatomic, strong, readonly) id<IEMStatisticsManager> _Nullable statisticsManager;` 及 `#import "IEMStatisticsManager.h"` | 其他删除的 API-无客户端替代 | 整个 Statistics 模块删除 |
| client_get_logged_in_devices_username_password | removed | `- (NSArray<EMDeviceConfig*> *_Nullable)getLoggedInDevicesFromServerWithUsername:(NSString * _Nonnull)aUsername password:(NSString * _Nonnull)aPassword error:(EMError ** _Nullable)pError;` 与 `- (void)getLoggedInDevicesFromServerWithUsername:(NSString *_Nonnull)aUsername password:(NSString *_Nonnull)aPassword completion:(void (^_Nullable)(NSArray<EMDeviceConfig*> * _Nullable aList, EMError *_Nullable aError))aCompletionBlock;` | 设备管理与鉴权 | 替代 `getLoggedInDevicesFromServerWithUserId:token:completion:`（4.24.1 已存在） |
| client_kick_device_username_password | removed | `- (EMError *_Nullable)kickDeviceWithUsername:(NSString *_Nonnull)aUsername password:(NSString *_Nonnull)aPassword resource:(NSString *_Nonnull)aResource;` 与 `- (void)kickDeviceWithUsername:(NSString *_Nonnull)aUsername password:(NSString *_Nonnull)aPassword resource:(NSString *_Nonnull)aResource completion:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;` | 同上 | 替代 `kickDeviceWithUserId:token:resource:completion:`（已存在） |
| client_kick_all_devices_username_password | removed | `- (EMError *_Nullable)kickAllDevicesWithUsername:(NSString *_Nonnull)aUsername password:(NSString *_Nonnull)aPassword;` 与 `- (void)kickAllDevicesWithUsername:(NSString *_Nonnull)aUsername password:(NSString *_Nonnull)aPassword completion:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;` | 同上 | 替代 `kickAllDevicesWithUserId:token:completion:`（已存在） |
| client_get_device_config | param_changed | `- (EMDeviceConfig * _Nullable)getDeviceConfig:(EMError **)pError;`（原 `- (EMDeviceConfig *)getDeviceConfig:(EMError **)pError;`） | | 仅 nullability 标注 |
| client_delegate_auto_login_did_complete | removed | `- (void)autoLoginDidCompleteWithError:(EMError * _Nullable)aError;`（EMClientDelegate） | 监听器回调变化汇总 | |
| client_delegate_user_account_did_login_from_other_device | removed | `- (void)userAccountDidLoginFromOtherDevice:(NSString* _Nullable)aDeviceName EM_DEPRECATED_IOS(4_1_0, 4_7_0, "Use userAccountDidLoginFromOtherDeviceWithInfo: instead");` 与 `- (void)userAccountDidLoginFromOtherDevice EM_DEPRECATED_IOS(3_1_0, 4_1_0, "Use userAccountDidLoginFromOtherDevice: instead");` | 同上 | 替代 `userAccountDidLoginFromOtherDeviceWithInfo:`（4.24.1 已存在） |
| client_delegate_sync_data_start | new_listener | `- (void)syncDataStartWithType:(EMDataSyncType)type;`（EMClientDelegate） | 数据同步与服务端拉取 API 迁移 | |
| client_delegate_sync_data_finished | new_listener | `- (void)syncDataFinished:(EMError * _Nullable)error type:(EMDataSyncType)type;`（EMClientDelegate） | 同上 | |
| client_delegate_on_database_opened | new_listener | `- (void)onDatabaseOpened:(EMError * _Nullable)error username:(NSString *_Nonnull)username;`（EMClientDelegate） | 初始化与登录-登录与数据库打开解耦 | |

### options（EMOptions.h）

| id | 类型 | iOS 源签名 | 迁移文档依据 | 备注 |
| --- | --- | --- | --- | --- |
| options_data_sync_type_enum | new_enum | `typedef NS_OPTIONS(NSInteger, EMDataSyncType) { EMDataSyncTypeNone = 0, EMDataSyncTypeConversations = 1 << 0, EMDataSyncTypeContacts = 1 << 1, EMDataSyncTypeJoinedGroups = 1 << 2, };` | 数据同步与服务端拉取 API 迁移 | |
| options_data_sync_type | new_property | `@property (nonatomic, assign) EMDataSyncType dataSyncType;` | 同上 | 默认值 `EMDataSyncTypeConversations`；须在 initialize 前配置 |
| options_is_auto_login | removed | `@property(nonatomic, assign) BOOL isAutoLogin;` | 初始化与登录-自动登录移除 | |
| options_enable_require_read_ack | removed | `@property(nonatomic, assign) BOOL enableRequireReadAck;` | 已读回执体系重构 | 全局已读回执开关，改为按消息 `isNeedReadReceipt` |
| options_enable_auto_sync_contacts | removed | `@property (nonatomic) BOOL enableAutoSyncContacts;` | 数据同步与服务端拉取 API 迁移 | 由 `dataSyncType` 取代（同一位置改写） |

### multidevices（EMMultiDevicesDelegate.h）

| id | 类型 | iOS 源签名 | 迁移文档依据 | 备注 |
| --- | --- | --- | --- | --- |
| multidevice_event_conversation_unread_message_count_cleared | new_enum | `EMMultiDevicesEventConversationUnreadMessageCountCleared = 65,` | 已读回执体系重构-多设备事件 | |
| multidevice_event_all_conversation_unread_message_count_cleared | new_enum | `EMMultiDevicesEventAllConversationUnreadMessageCountCleared = 66,` | 同上 | |

### chat（IEMChatManager.h / EMChatManagerDelegate.h / EMConversationDelegate.h）

| id | 类型 | iOS 源签名 | 迁移文档依据 | 备注 |
| --- | --- | --- | --- | --- |
| chat_add_conversation_delegate | new_api | `- (void)addConversationDelegate:(id<EMConversationDelegate> _Nullable)aDelegate delegateQueue:(dispatch_queue_t _Nullable)aQueue NS_SWIFT_NAME(addConversation(delegate:queue:));` 与 `- (void)removeConversationDelegate:(id<EMConversationDelegate> _Nonnull)aDelegate NS_SWIFT_NAME(removeConversation(delegate:));` | 主要新增 API | delegate 参数标 `_Nullable` 不寻常，见疑点清单 |
| chat_get_unread_message_count | new_api | `- (NSInteger)getUnreadMessageCount;` | 主要新增 API / 行为变化 1 | 不统计聊天室与免打扰会话 |
| chat_get_conversations_from_server | removed | `- (void)getConversationsFromServer:(void (^_Nullable)(NSArray<EMConversation *> * _Nullable aConversations, EMError * _Nullable aError))aCompletionBlock EM_DEPRECATED_IOS(4_0_0, ...);` | 服务端拉取 API 迁移 | |
| chat_get_conversations_from_server_by_page | removed | `- (void)getConversationsFromServerByPage:(NSUInteger)pageNumber pageSize:(NSUInteger)pageSize completion:(void (^_Nullable)(NSArray<EMConversation *> * _Nullable aConversations, EMError * _Nullable aError))aCompletionBlock EM_DEPRECATED_IOS(4_0_0, ...);` | 同上 | |
| chat_get_conversations_from_server_with_cursor | removed | `- (void)getConversationsFromServerWithCursor:(nullable NSString *)cursor pageSize:(UInt8)pageSize completion:(nonnull void (^)(EMCursorResult<EMConversation *> * _Nullable result, EMError * _Nullable error))completionBlock;` | 同上 | |
| chat_get_pinned_conversations_from_server | removed | `- (void)getPinnedConversationsFromServerWithCursor:(nullable NSString *)cursor pageSize:(UInt8)limit completion:(nonnull void (^)(EMCursorResult<EMConversation *> * _Nullable result, EMError * _Nullable error))completionBlock;` | 同上 | 改读本地 `EMConversation.isPinned`/`pinnedTime`（4.24.1 已有） |
| chat_get_conversations_from_server_with_cursor_filter | removed | `- (void)getConversationsFromServerWithCursor:(NSString * _Nullable)cursor filter:(EMConversationFilter* _Nonnull)filter completion:(nonnull void (^)(EMCursorResult<EMConversation *> * _Nullable result, EMError * _Nullable error))completionBlock;` | 同上 | 本地替代 `filterConversationsFromDB:filter:`（4.24.1 已有） |
| chat_import_conversations | removed | `- (void)importConversations:(NSArray<EMConversation *> * _Nullable)aConversations completion:(void (^ _Nullable)(EMError * _Nullable aError))aCompletionBlock;` | 其他删除的 API-无客户端替代 | |
| chat_modify_message_body | removed | `- (void)modifyMessage:(NSString *_Nonnull)messageId body:(EMMessageBody *_Nonnull)body completion:(void (^_Nonnull)(EMError * _Nullable error,EMChatMessage *_Nullable message))completionBlock;` | 其他删除的 API-有替代方式 | 替代 `modifyMessage:body:ext:completion:`（4.24.1 已存在，非 5.0.0 新增） |
| chat_send_message_read_ack | removed | `- (void)sendMessageReadAck:(NSString * _Nonnull)aMessageId toUser:(NSString * _Nonnull)aUsername completion:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;` | 已读回执体系重构 | 由 `sendMessageReadReceipts:completion:` 取代 |
| chat_send_group_message_read_ack | removed | `- (void)sendGroupMessageReadAck:(NSString * _Nonnull)aMessageId toGroup:(NSString * _Nonnull)aGroupId content:(NSString * _Nullable)aContent completion:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;` | 同上 | 群回执不再支持 `content` 自定义内容 |
| chat_send_message_read_receipts | new_api | `- (void)sendMessageReadReceipts:(NSArray<EMChatMessage *> * _Nonnull)aMessages completion:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;` | 同上 | 批量（≤50 条、同会话）；单聊群聊统一；注释与签名不一致，见疑点 |
| chat_ack_conversation_read | removed | `- (void)ackConversationRead:(NSString * _Nonnull)conversationId completion:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;` | 同上 | 拆为 clear unread + send receipts 两步 |
| chat_clear_conversation_unread_message_count | new_api | `- (void)clearConversationUnreadMessageCount:(NSString * _Nonnull)aConversationId completion:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;` | 同上 | 清本地未读并同步多设备，不发回执 |
| chat_clear_all_conversation_unread_message_count | new_api | `- (void)clearAllConversationUnreadMessageCount:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;` | 同上 | 取代 `markAllConversationsAsRead` |
| chat_get_group_message_read_receipts | new_api | `- (void)getGroupMessageReadReceipts:(NSArray<EMChatMessage *> * _Nonnull)aMessages completion:(void (^_Nullable)(NSArray<EMMessageReadReceipt *> *_Nullable aReceipts, EMError *_Nullable aError))aCompletionBlock;` | 已读回执体系重构-回执详情查询 | ≤20 条、同会话 |
| chat_resend_message | removed | `- (void)resendMessage:(EMChatMessage *_Nonnull)aMessage progress:(void (^_Nullable)(int progress))aProgressBlock completion:(void (^_Nullable)(EMChatMessage *_Nullable message, EMError *_Nullable error))aCompletionBlock;` | 其他删除的 API-有替代方式 | 改用 `sendMessage:progress:completion:` |
| chat_fetch_history_messages_from_server | removed | `- (EMCursorResult<EMChatMessage*> *_Nullable)fetchHistoryMessagesFromServer:(NSString *_Nonnull)aConversationId conversationType:(EMConversationType)aConversationType startMessageId:(NSString *_Nullable)aStartMessageId fetchDirection:(EMMessageFetchHistoryDirection)direction pageSize:(int)aPageSize error:(EMError **_Nullable)pError __deprecated_msg(...)` 及无 `fetchDirection` 的同步重载（共 2 个同步方法） | 同上 | 替代 `fetchMessagesFromServerBy:conversationType:cursor:pageSize:option:completion:`（4.24.1 已存在） |
| chat_async_fetch_history_messages_from_server | removed | `- (void)asyncFetchHistoryMessagesFromServer:(NSString *_Nonnull)aConversationId conversationType:(EMConversationType)aConversationType startMessageId:(NSString *_Nullable)aStartMessageId pageSize:(int)aPageSize completion:...` 及带 `fetchDirection:` 的重载（共 2 个异步方法，均 `__deprecated_msg`） | 同上 | |
| chat_fetch_group_message_acks | renamed | 旧：`- (void)asyncFetchGroupMessageAcksFromServer:(NSString *_Nonnull)aMessageId groupId:(NSString *_Nonnull)aGroupId startGroupAckId:(NSString *_Nonnull)aGroupAckId pageSize:(int)aPageSize completion:(void (^_Nullable)(EMCursorResult<EMGroupMessageAck *> *_Nullable aResult, EMError *_Nullable error, int totalCount))aCompletionBlock;` → 新：`- (void)asyncFetchGroupMessageReadUsersFromServer:(NSString *_Nonnull)aMessageId groupId:(NSString *_Nonnull)aGroupId readReceiptId:(NSString *_Nonnull)aReadReceiptId pageSize:(int)aPageSize completion:(void (^_Nullable)(EMCursorResult<EMGroupReadReceipt *> *_Nullable aResult, EMError *_Nullable error, int totalCount))aCompletionBlock;` | 已读回执体系重构-回执详情查询 | 方法名 + 参数名 + 泛型类型全变 |
| chat_report_message | removed | `- (void)reportMessageWithId:(NSString *_Nonnull )aMessageId tag:(NSString *_Nonnull)aTag reason:(NSString *_Nonnull)aReason completion:(void(^_Nullable)(EMError* _Nullable error))aCompletion;` | 其他删除的 API-无客户端替代 | 举报功能下线，走 App Server |
| chat_load_messages_with_type | removed | `- (NSArray<EMChatMessage *> * _Nullable)loadMessagesWithType:(EMMessageBodyType)aType timestamp:(long long)aTimestamp count:(int)aCount fromUser:(NSString* _Nullable)aUsername searchDirection:(EMMessageSearchDirection)aDirection;` 及 completion 异步重载（IEMChatManager 上共 2 个） | 其他删除的 API-有替代方式 | `EMConversation` 上的同名同步+异步方法两个 tag 均存在，未动 |
| chat_load_messages_with_keyword_legacy | removed | `- (NSArray<EMChatMessage *> *)loadMessagesWithKeyword:(NSString*)aKeywords timestamp:(long long)aTimestamp count:(int)aCount fromUser:(NSString*)aSender searchDirection:(EMMessageSearchDirection)aDirection;` 及对应 completion 重载（无 `scope` 参数的 2 个旧重载） | 同上 | 保留带 `scope:` 的版本 |
| chat_load_messages_with_keyword_scope | param_changed | `- (void)loadMessagesWithKeyword:(NSString* _Nonnull)aKeywords timestamp:(long long)aTimestamp count:(int)aCount fromUser:(NSString *_Nullable)aSender searchDirection:(EMMessageSearchDirection)aDirection scope:(EMMessageSearchScope)aScope completion:(void (^_Nullable)(NSArray<EMChatMessage *> *_Nullable aMessages, EMError *_Nullable aError))aCompletionBlock;` | | 仅 nullability 标注收紧（选择器不变） |
| chat_mark_all_conversations_as_read | removed | `- (EMError*)markAllConversationsAsRead;` | 已读回执体系重构 | 由 `clearAllConversationUnreadMessageCount:` 取代 |
| chat_delete_messages_before | param_changed | `- (void)deleteMessagesBefore:(NSUInteger)aTimestamp completion:(void(^_Nullable)(EMError*_Nullable error))aCompletion;`（原 completion 无 nullability 标注） | | 仅标注变化 |
| chat_delegate_conversation_list_did_update | removed | `- (void)conversationListDidUpdate:(NSArray<EMConversation *> * _Nonnull)aConversationList;`（自 EMChatManagerDelegate 删除） | 监听器回调变化汇总 | 迁移到新协议 `EMConversationDelegate` |
| chat_delegate_messages_did_read | removed | `- (void)messagesDidRead:(NSArray<EMChatMessage *> * _Nonnull)aMessages;` | 同上 | 由 `onMessageReadReceipts:` 取代 |
| chat_delegate_group_message_did_read | removed | `- (void)groupMessageDidRead:(NSArray<EMGroupMessageAck *> * _Nonnull)aGroupAcks;` 与 `- (void)groupMessageDidRead:(EMChatMessage * _Nonnull)aMessage groupAcks:(NSArray<EMGroupMessageAck *> * _Nonnull)aGroupAcks __deprecated_msg("Use -groupMessageDidRead: instead");` | 同上 | 两个重载均删 |
| chat_delegate_group_message_ack_has_changed | removed | `- (void)groupMessageAckHasChanged;` | 同上 | |
| chat_delegate_on_conversation_read | removed | `- (void)onConversationRead:(NSString * _Nonnull)from to:(NSString * _Nonnull)to;` | 同上 | 无直接替代 |
| chat_delegate_on_message_read_receipts | new_listener | `- (void)onMessageReadReceipts:(NSArray<EMMessageReadReceipt *> * _Nonnull)aReceipts;`（EMChatManagerDelegate） | 同上 | 单聊群聊统一回执回调 |
| conversation_delegate_protocol | new_type | `@protocol EMConversationDelegate <NSObject> @optional - (void)conversationListDidUpdate:(NSArray<EMConversation *> * _Nonnull)aConversationList; @end`（新文件 `EMConversationDelegate.h`） | 监听器回调变化汇总 | 通过 `addConversationDelegate:delegateQueue:` 注册 |

### message / conversation 模型（EMChatMessage.h / EMConversation.h / Body / EMStreamChunk.h）

| id | 类型 | iOS 源签名 | 迁移文档依据 | 备注 |
| --- | --- | --- | --- | --- |
| message_is_read_acked | renamed | 旧：`@property (nonatomic) BOOL isReadAcked;` → 新：`@property (nonatomic,readonly) BOOL isPeerRead;` | 已读回执体系重构-EMMessage 已读相关方法重命名 | 同时变为只读 |
| message_is_need_group_ack | renamed | 旧：`@property (nonatomic) BOOL isNeedGroupAck;` → 新：`@property (nonatomic) BOOL isNeedReadReceipt;` | 同上 | 语义从群聊扩展为单群聊通用，默认 NO |
| message_group_ack_count | renamed | 旧：`@property (nonatomic, readonly) int groupAckCount;` → 新：`@property (nonatomic, readonly) int groupReadReceiptCount;` | 同上 | |
| message_is_read | param_changed | `@property (nonatomic,readonly) BOOL isRead;`（原 `@property (nonatomic) BOOL isRead;`） | 同上 / 行为变化 4 | setter 删除，应用不可再直接改已读态 |
| message_get_reaction | removed | `- (EMMessageReaction *_Nullable)getReaction:(NSString * _Nonnull)reaction;` | 其他删除的 API-有替代方式 | 改遍历 `reactionList` |
| conversation_name | new_api | `- (NSString* _Nullable)conversationName;`（EMConversation 方法而非属性） | 主要新增 API | 单聊返回对方昵称，群聊返回群名称 |
| conversation_avatar | new_api | `- (NSString* _Nullable)conversationAvatar;`（EMConversation 方法） | 同上 | |
| conversation_mark_message_as_read | removed | `- (void)markMessageAsReadWithId:(NSString *_Nonnull)aMessageId error:(EMError ** _Nullable)pError;` | 已读回执体系重构 | |
| conversation_mark_all_messages_as_read | removed | `- (void)markAllMessagesAsRead:(EMError ** _Nullable)pError;` | 同上 | |
| file_message_body_init_with_data | removed | `- (instancetype _Nonnull)initWithData:(NSData *_Nullable)aData displayName:(NSString *_Nullable)aDisplayName;`（EMFileMessageBody） | 同上 / 行为变化 5 | 附件不再接受 NSData 初始化 |
| file_message_body_init_with_local_path | param_changed | `- (instancetype _Nonnull)initWithLocalPath:(NSString * _Nonnull)aLocalPath displayName:(NSString * _Nonnull)aDisplayName;`（原两参数均 `_Nullable`） | | nullability 收紧为 nonnull |
| image_message_body_init_with_data | removed | `- (instancetype)initWithData:(NSData *)aData thumbnailData:(NSData *)aThumbnailData __deprecated_msg("Use -initWithLocalPath:displayName: instead");`（EMImageMessageBody） | 其他删除的 API-有替代方式 | |
| stream_chunk_sequence_number | removed | `@property (nonatomic) long sequenceNumber;`（EMStreamChunk） | 其他删除的 API-有替代方式 | 不再暴露分片序号 |
| stream_chunk_is_complete | new_property | `@property (nonatomic, readonly) BOOL isComplete;`（EMStreamChunk） | 同上 | 改为暴露流式分片是否完成 |
| group_message_ack_type | renamed | 旧：`@interface EMGroupMessageAck : NSObject`，属性 `messageId`/`readAckId`/`from`(NSString*)/`content`/`readCount`/`timestamp` → 新：`@interface EMGroupReadReceipt : NSObject`，属性 `messageId`/`readReceiptId`/`from`(**EMGroupMemberInfo***)/`readCount`/`timestamp`（`content` 删除） | 已读回执体系重构-回执详情查询 | 文件改名 `EMGroupMessageAck.h`→`EMGroupReadReceipt.h`；`from` 由字符串改为对象 |
| message_read_receipt_type | new_type | `@interface EMMessageReadReceipt : NSObject`，只读属性 `messageId`/`conversationId`/`isPeerReceipt`(BOOL)/`readCount`(NSInteger)（新文件 `EMMessageReadReceipt.h`） | 同上 | 统一单群聊回执模型 |

### group（EMGroup.h / EMGroupConfigs.h / EMGroupOptions.h / IEMGroupManager.h / EMGroupManagerDelegate.h）

| id | 类型 | iOS 源签名 | 迁移文档依据 | 备注 |
| --- | --- | --- | --- | --- |
| group_options_type | removed | `@interface EMGroupOptions : NSObject`（属性 `style`/`maxUsers`/`IsInviteNeedConfirm`/`ext`）及 `typedef NS_ENUM(NSInteger, EMGroupStyle) { EMGroupStylePrivateOnlyOwnerInvite = 0, EMGroupStylePrivateMemberCanInvite, EMGroupStylePublicJoinNeedApproval, EMGroupStylePublicOpenJoin, };`（`EMGroupOptions.h` 整文件删除） | 群组配置模型重构 | 由 `EMGroupConfigs` 取代，无兼容层 |
| group_configs_type | new_type | `@interface EMGroupConfigs : NSObject`，属性 `maxUsers`/`IsInviteNeedConfirm`/`ext`/`allowInvites`/`joinApprovalRequired`/`isPublic`（新文件 `EMGroupConfigs.h`） | 同上 | style 枚举拆为 3 个 BOOL；默认 isPublic=NO/joinApprovalRequired=NO/allowInvites=NO/maxUsers=200/IsInviteNeedConfirm=YES/ext=@"" |
| group_configs_type_enum | new_enum | `typedef NS_OPTIONS(NSUInteger, EMGroupConfigsType) { EMGroupConfigsTypeAllowInvites = 1 << 0, EMGroupConfigsTypeMaxUsers = 1 << 1, EMGroupConfigsTypeInviteNeedConfirm = 1 << 2, EMGroupConfigsTypeJoinApprovalRequired = 1 << 3, EMGroupConfigsTypeIsPublic = 1 << 4, EMGroupConfigsTypeExt = 1 << 5, };` | 同上 | 供 `updateGroupWithId:types:configs:completion:` 按位指定更新字段 |
| group_settings_property | param_changed | `@property (nonatomic, strong, readonly) EMGroupConfigs *settings;`（原 `EMGroupOptions *settings`，EMGroup） | 同上 | 属性名不变，类型改变 |
| group_is_push_notification_enabled | removed | `@property (nonatomic, readonly) BOOL isPushNotificationEnabled;`（EMGroup） | 其他删除的 API-有替代方式 | 改查 `EMConversation.disturbType` 或 `getSilentModeForConversation:...` |
| group_create_group_sync | removed | `- (EMGroup * _Nullable)createGroupWithSubject:(NSString *_Nullable)aSubject description:(NSString *_Nullable)aDescription invitees:(NSArray<NSString *> * _Nullable)aInvitees message:(NSString *_Nullable)aMessage setting:(EMGroupOptions *_Nullable)aSetting error:(EMError **_Nullable)pError;` | 群组配置模型重构-相关 API 变化 | |
| group_create_group_completion_no_avatar | removed | `- (void)createGroupWithSubject:(NSString *_Nullable)aSubject description:(NSString *_Nullable)aDescription invitees:(NSArray<NSString *> * _Nullable)aInvitees message:(NSString *_Nullable)aMessage setting:(EMGroupOptions *_Nullable)aSetting completion:(void (^_Nullable)(EMGroup *_Nullable aGroup, EMError *_Nullable aError))aCompletionBlock;` | 同上 | 无 avatar 参数的异步版删除 |
| group_create_group_with_avatar | param_changed | `- (void)createGroupWithSubject:... avatar:... setting:(EMGroupConfigs *)setting completion:...`（选择器不变，`setting` 类型 EMGroupOptions* → EMGroupConfigs*） | 同上 | |
| group_update_group_with_id | new_api | `- (void)updateGroupWithId:(NSString *_Nonnull)groupId types:(EMGroupConfigsType)type configs:(EMGroupConfigs *_Nonnull)configs completion:(void (^_Nullable)(EMGroup *_Nullable group, EMError *_Nullable error))aCompletionBlock;` | 同上 / 主要新增 API | 建群后按字段更新群配置 |
| group_get_public_groups_from_server | removed | `- (EMCursorResult<EMGroup*> *_Nullable)getPublicGroupsFromServerWithCursor:(NSString *_Nullable)aCursor pageSize:(NSInteger)aPageSize error:(EMError **_Nullable)pError;` 及 completion 版本 | 其他删除的 API-无客户端替代 | |
| group_search_public_group | removed | `- (EMGroup * _Nullable)searchPublicGroupWithId:(NSString *_Nonnull)aGroundId error:(EMError **_Nullable)pError;` 及 completion 版本 | 同上 | |
| group_get_joined_groups_from_server_with_page | removed | `- (void)getJoinedGroupsFromServerWithPage:(NSInteger)aPageNum pageSize:(NSInteger)aPageSize needMemberCount:(BOOL)aNeedMemberCount needRole:(BOOL)aNeedRole completion:(void (^_Nullable)(NSArray<EMGroup *> *_Nullable aList, EMError *_Nullable aError))aCompletionBlock;` | 服务端拉取 API 迁移 | 改读本地 `getJoinedGroups` |
| group_get_groups_without_push_notification | removed | `- (NSArray *)getGroupsWithoutPushNotification:(EMError **)pError EM_DEPRECATED_IOS(3_3_2, 3_8_3, "Use -IEMPushManager::noPushGroups");` | 其他删除的 API-有替代方式 | |
| group_get_group_specification_sync | removed | `- (EMGroup * _Nullable)getGroupSpecificationFromServerWithId:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` 与 `- (EMGroup * _Nullable)getGroupSpecificationFromServerWithId:(NSString *_Nonnull)aGroupId fetchMembers:(BOOL)fetchMembers error:(EMError **_Nullable)pError;` | 同上 | completion 版本已存在 |
| group_get_group_member_list_sync | removed | `- (EMCursorResult<NSString*> *)getGroupMemberListFromServerWithId:(NSString *_Nonnull)aGroupId cursor:(NSString *_Nullable)aCursor pageSize:(NSInteger)aPageSize error:(EMError **_Nullable)pError;` | 同上 | |
| group_get_group_blacklist_sync | removed | `- (NSArray<NSString *> * _Nullable)getGroupBlacklistFromServerWithId:(NSString *_Nonnull)aGroupId pageNumber:(NSInteger)aPageNum pageSize:(NSInteger)aPageSize error:(EMError **_Nullable)pError;` | 同上 | |
| group_get_group_mute_list_sync | removed | `- (NSArray<NSString *> * _Nullable)getGroupMuteListFromServerWithId:(NSString *_Nonnull)aGroupId pageNumber:(NSInteger)aPageNum pageSize:(NSInteger)aPageSize error:(EMError **_Nullable)pError;` | 同上 | |
| group_get_group_file_list_sync | removed | `- (NSArray<EMGroupSharedFile *> *_Nullable)getGroupFileListWithId:(NSString *_Nonnull)aGroupId pageNumber:(NSInteger)aPageNum pageSize:(NSInteger)aPageSize error:(EMError **_Nullable)pError;` | 同上 | |
| group_get_group_white_list_sync | removed | `- (NSArray *)getGroupWhiteListFromServerWithId:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 同上 | |
| group_is_member_in_white_list_sync | removed | `- (BOOL)isMemberInWhiteListFromServerWithGroupId:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 同上 | completion 版本保留（仅位置/格式微调） |
| group_get_group_announcement_sync | removed | `- (NSString *_Nullable)getGroupAnnouncementWithId:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 同上 | completion 版本保留 |
| group_add_occupants_sync | removed | `- (EMGroup * _Nullable)addOccupants:(NSArray<NSString *> * _Nonnull)aOccupants toGroup:(NSString *_Nonnull)aGroupId welcomeMessage:(NSString *_Nullable)aWelcomeMessage error:(EMError **_Nullable)pError;` | 同上 | 替代 `addMembers:toGroup:message:completion:`（4.24.1 已有） |
| group_remove_occupants_sync | removed | `- (EMGroup * _Nullable)removeOccupants:(NSArray<NSString *> * _Nonnull)aOccupants fromGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 同上 | |
| group_block_occupants_sync | removed | `- (EMGroup * _Nullable)blockOccupants:(NSArray<NSString *> * _Nonnull)aOccupants fromGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 同上 | |
| group_unblock_occupants_sync | removed | `- (EMGroup * _Nullable)unblockOccupants:(NSArray<NSString *> * _Nonnull)aOccupants forGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 同上 | |
| group_change_group_subject_sync | removed | `- (EMGroup * _Nullable)changeGroupSubject:(NSString *_Nullable)aSubject forGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 同上 | 替代 `updateGroupSubject:forGroup:completion:`（已有） |
| group_change_description_sync | removed | `- (EMGroup * _Nullable)changeDescription:(NSString *_Nullable)aDescription forGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 同上 | 替代 `updateDescription:forGroup:completion:`（已有） |
| group_leave_group_sync | removed | `- (void)leaveGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 同上 | |
| group_destroy_group_sync | removed | `- (EMError *)destroyGroup:(NSString *_Nonnull)aGroupId;` | 同上 | 替代 `destroyGroup:finishCompletion:`（已有） |
| group_block_group_sync | removed | `- (EMGroup * _Nullable)blockGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 同上 | |
| group_unblock_group_sync | removed | `- (EMGroup * _Nullable)unblockGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 同上 | |
| group_update_group_owner_sync | removed | `- (EMGroup * _Nullable)updateGroupOwner:(NSString *_Nonnull)aGroupId newOwner:(NSString *_Nonnull)aNewOwner error:(EMError **_Nullable)pError;` | 同上 | |
| group_add_admin_sync | removed | `- (EMGroup * _Nullable)addAdmin:(NSString *_Nonnull)aAdmin toGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 同上 | |
| group_remove_admin_sync | removed | `- (EMGroup * _Nullable)removeAdmin:(NSString *_Nonnull)aAdmin fromGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 同上 | |
| group_mute_members_sync | removed | `- (EMGroup * _Nullable)muteMembers:(NSArray<NSString *> * _Nonnull)aMuteMembers muteMilliseconds:(NSInteger)aMuteMilliseconds fromGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 同上 | |
| group_unmute_members_sync | removed | `- (EMGroup * _Nullable)unmuteMembers:(NSArray<NSString *> * _Nonnull)aMembers fromGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 同上 | completion 版本保留（仅标注微调） |
| group_mute_all_members_sync | removed | `- (EMGroup * _Nullable)muteAllMembersFromGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 同上 | |
| group_unmute_all_members_sync | removed | `- (EMGroup * _Nullable)unmuteAllMembersFromGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 同上 | |
| group_add_white_list_members_sync | removed | `- (EMGroup * _Nullable)addWhiteListMembers:(NSArray<NSString *> * _Nonnull)aMembers fromGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 同上 | |
| group_remove_white_list_members_sync | removed | `- (EMGroup * _Nullable)removeWhiteListMembers:(NSArray<NSString *> * _Nonnull)aMembers fromGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 同上 | |
| group_remove_group_shared_file_sync | removed | `- (EMGroup * _Nullable)removeGroupSharedFileWithId:(NSString *_Nonnull)aGroupId sharedFileId:(NSString *_Nonnull)aSharedFileId error:(EMError **_Nullable)pError;` | 同上 | |
| group_update_group_announcement_sync | removed | `- (EMGroup * _Nullable)updateGroupAnnouncementWithId:(NSString *_Nonnull)aGroupId announcement:(NSString *_Nullable)aAnnouncement error:(EMError **_Nullable)pError;` | 同上 | |
| group_update_group_ext_sync | removed | `- (EMGroup * _Nullable)updateGroupExtWithId:(NSString *_Nonnull)aGroupId ext:(NSString *_Nullable)aExt error:(EMError **_Nullable)pError;` | 同上 | |
| group_join_public_group_sync | removed | `- (EMGroup * _Nullable)joinPublicGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 同上 | completion 版本保留（仅位置移动） |
| group_apply_join_public_group | renamed | 旧：`- (EMGroup * _Nullable)applyJoinPublicGroup:(NSString *_Nonnull)aGroupId message:(NSString *_Nullable)aMessage error:(EMError **_Nullable)pError;`（同步）→ 新：`- (void)requestToJoinPublicGroup:(NSString *_Nonnull)aGroupId message:(NSString *_Nullable)aMessage completion:(void (^_Nullable)(EMGroup *_Nullable aGroup, EMError *_Nullable aError))aCompletionBlock;`（4.24.1 已有，5.0.0 仅位置移动） | 同上 | 同步旧版删除，异步新版名字不同且早已存在 |
| group_accept_join_application | renamed | 旧：`- (EMError *)acceptJoinApplication:(NSString *_Nonnull)aGroupId applicant:(NSString *_Nonnull)aUsername;`（同步，删除）→ 新：`approveJoinGroupRequest:sender:completion:`（4.24.1 已有） | 同上 | |
| group_decline_join_application | renamed | 旧：`- (EMError *)declineJoinApplication:(NSString *_Nonnull)aGroupId applicant:(NSString *_Nonnull)aUsername reason:(NSString *_Nullable)aReason;`（同步，删除）→ 新：`declineJoinGroupRequest:sender:reason:completion:`（4.24.1 已有） | 同上 | |
| group_accept_invitation_from_group_sync | removed | `- (EMGroup * _Nullable)acceptInvitationFromGroup:(NSString *_Nonnull)aGroupId inviter:(NSString *_Nonnull)aUsername error:(EMError **_Nullable)pError;` | 同上 | completion 版本已有 |
| group_decline_invitation_from_group | renamed | 旧：`- (EMError *)declineInvitationFromGroup:(NSString *_Nonnull)aGroupId inviter:(NSString *_Nonnull)aUsername reason:(NSString *_Nullable)aReason;`（同步，删除）→ 新：`declineGroupInvitation:inviter:reason:completion:`（4.24.1 已有） | 同上 | |
| group_delegate_join_group_request_did_decline_2param | removed | `- (void)joinGroupRequestDidDecline:(NSString *_Nonnull)aGroupId reason:(NSString *_Nullable)aReason EM_DEPRECATED_IOS(3_1_0, 4_2_0, "Use -joinGroupRequestDidDecline:reason:applicant: instead");` | 监听器回调变化汇总 | 保留 `joinGroupRequestDidDecline:reason:decliner:applicant:`（4.24.1 已有） |
| group_delegate_join_group_request_did_decline_3param | removed | `- (void)joinGroupRequestDidDecline:(NSString *_Nonnull)aGroupId reason:(NSString *_Nullable)aReason applicant:(NSString* _Nonnull )aApplicant;` | 同上 | |
| group_delegate_user_did_join_group_single | removed | `- (void)userDidJoinGroup:(EMGroup *_Nonnull)aGroup user:(NSString *_Nonnull)aUsername EM_DEPRECATED_IOS(3_1_0, 4_15_0, "Use -userDidJoinGroup:users: instead");` | 同上 | 保留 `userDidJoinGroup:users:`（已有） |
| group_delegate_user_did_leave_group_single | removed | `- (void)userDidLeaveGroup:(EMGroup *_Nonnull)aGroup user:(NSString *_Nonnull)aUsername EM_DEPRECATED_IOS(3_1_0, 4_15_0, "Use -userDidLeaveGroup:users: instead");` | 同上 | 保留 `userDidLeaveGroup:users:`（已有） |

### contact（IEMContactManager.h / EMContactManagerDelegate.h）

| id | 类型 | iOS 源签名 | 迁移文档依据 | 备注 |
| --- | --- | --- | --- | --- |
| contact_get_all_contacts_from_server | removed | `- (void)getAllContactsFromServerWithCompletion:(void (^_Nullable)(NSArray<EMContact *>* _Nullable aList, EMError* _Nullable aError))aCompletionBlock;` | 服务端拉取 API 迁移 | 改读本地 `getAllContacts`/`getContacts`/`getContact:` |
| contact_get_contacts_from_server_with_cursor | removed | `- (void)getContactsFromServerWithCursor:(NSString* _Nullable)cursor pageSize:(NSUInteger)pageSize completion:(void (^_Nonnull)(EMCursorResult<EMContact*> * _Nullable aResult, EMError * _Nullable aError))aCompletionBlock;` | 同上 | |
| contact_get_contacts_from_server_completion | removed | `- (void)getContactsFromServerWithCompletion:(void (^)(NSArray<NSString *> *_Nullable aList, EMError *aError_Nullable ))aCompletionBlock;` | 同上 | |
| contact_get_contacts_from_server_sync | removed | `- (NSArray<NSString *> *_Nullable )getContactsFromServerWithError:(EMError **_Nullable )pError;` | 同上 | |
| contact_add_contact_sync | removed | `- (EMError *_Nullable )addContact:(NSString *_Nonnull)aUsername message:(NSString *_Nullable )aMessage;` | 其他删除的 API-有替代方式 | completion 版本已有 |
| contact_get_blacklist_from_server_sync | removed | `- (NSArray<NSString *> *_Nullable )getBlackListFromServerWithError:(EMError **_Nullable )pError;` | 同上 | 替代 `getBlackListFromServerWithCompletion:`（已有） |
| contact_add_user_to_blacklist_sync | removed | `- (EMError *_Nullable )addUserToBlackList:(NSString *_Nonnull)aUsername;` | 同上 | |
| contact_remove_user_from_blacklist_sync | removed | `- (EMError *_Nullable )removeUserFromBlackList:(NSString *_Nonnull)aUsername;` | 同上 | |
| contact_accept_invitation_sync | removed | `- (EMError *_Nullable )acceptInvitationForUsername:(NSString *_Nonnull)aUsername;` | 同上 | 替代 `approveFriendRequestFromUser:completion:`（已有） |
| contact_decline_invitation_sync | removed | `- (EMError *_Nullable )declineInvitationForUsername:(NSString *_Nonnull)aUsername;` | 同上 | 替代 `declineFriendRequestFromUser:completion:`（已有） |
| contact_get_self_ids_on_other_platform_sync | removed | `- (NSArray<NSString *> *_Nullable )getSelfIdsOnOtherPlatformWithError:(EMError **_Nullable )pError;` | 同上 | 替代 `getSelfIdsOnOtherPlatformWithCompletion:`（已有） |
| contact_save_black_list | new_api | `- (void)saveBlackList:(NSArray<NSString *> *_Nonnull)aBlackList completion:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;` | 主要新增 API | 批量加黑名单 |
| contact_delegate_on_friend_start_sync | removed | `- (void)onFriendStartSync;`（EMContactManagerDelegate） | 监听器回调变化汇总 | 由 `EMClientDelegate#syncDataStartWithType:` 取代 |
| contact_delegate_on_friend_sync_finished | removed | `- (void)onFriendSyncFinished:(EMError * _Nullable)error;`（EMContactManagerDelegate） | 同上 | 由 `syncDataFinished:type:` 取代 |

### chatroom（IEMChatroomManager.h）

| id | 类型 | iOS 源签名 | 迁移文档依据 | 备注 |
| --- | --- | --- | --- | --- |
| chatroom_create_chatroom | removed | `- (EMChatroom *_Nullable)createChatroomWithSubject:(NSString *_Nullable)aSubject description:(NSString *_Nullable)aDescription invitees:(NSArray<NSString *> *_Nullable)aInvitees message:(NSString *_Nullable)aMessage maxMembersCount:(NSInteger)aMaxMembersCount error:(EMError **_Nullable)pError;` 及 completion 版本 | 其他删除的 API-无客户端替代 | 改用服务端 REST 创建聊天室 |
| chatroom_destroy_chatroom | removed | `- (EMError *_Nullable)destroyChatroom:(NSString *_Nonnull)aChatroomId;` 与 `- (void)destroyChatroom:(NSString *_Nonnull)aChatroomId completion:(void (^_Nullable)(EMError * _Nullable aError))aCompletionBlock;` | 同上 | |

### push（IEMPushManager.h）

| id | 类型 | iOS 源签名 | 迁移文档依据 | 备注 |
| --- | --- | --- | --- | --- |
| push_update_push_display_style_sync | removed | `- (EMError *)updatePushDisplayStyle:(EMPushDisplayStyle)pushDisplayStyle;` | 其他删除的 API-有替代方式 | completion 版本已有 |
| push_update_push_display_name_sync | removed | `- (EMError *_Nullable )updatePushDisplayName:(NSString * _Nonnull)aDisplayName;` | 同上 | |
| push_get_push_options_from_server_sync | removed | `- (EMPushOptions *_Nullable )getPushOptionsFromServerWithError:(EMError *_Nullable *_Nullable)pError;` | 同上 | 替代 `getPushNotificationOptionsFromServerWithCompletion:`（已有） |

### statistics（Statistics/ 整模块删除）

| id | 类型 | iOS 源签名 | 迁移文档依据 | 备注 |
| --- | --- | --- | --- | --- |
| statistics_manager_module | removed | `@protocol IEMStatisticsManager`（`getMessageStatisticsById:`、`getMessageCountWithStart:end:direction:type:`、`getMessageStatisticsSizeWithStart:end:direction:type:`）、`@interface EMStatisticsManager : EMManager<IEMStatisticsManager>`、`@interface EMChatMessageStatistics : NSObject`（10 个只读属性）、`EMMessageStatisticsDirection`、`EMMessageStatisticsType` 两个枚举；`Statistics/` 目录 3 个公开头文件全部删除 | 其他删除的 API-无客户端替代 | 消息流量统计功能整体下线 |

### error code（EMErrorCode.h）

| id | 类型 | iOS 源签名 | 迁移文档依据 | 备注 |
| --- | --- | --- | --- | --- |
| error_contact_add_faild_typo | renamed | 旧：`EMErrorContactAddFaild = 1000,` → 新：`EMErrorContactAddFailed = 1000,` | 无 | 拼写修正，值不变；Flutter 侧若按名字映射需同步改名 |

## 3. 未匹配 / 疑点清单

1. **`EMGroup.users` 并非 5.0.0 新增**：迁移文档「主要新增 API」列出 `EMGroup#users`，但 `git grep` 确认 4.24.1 的 `EMGroup.h:212` 已存在 `@property (nonatomic, strong, readonly) NSArray<NSString *> *users;`，且 diff 未触及该属性。可能是语义/文档口径变化（按角色合并不去重），Flutter 侧若已封装 `users` 则无需改动。
2. **`sendMessageReadReceipts:completion:` 注释与签名不符**：IEMChatManager.h 新增方法的中文注释描述 `@param aConversationId 会话 ID`、回调含 `aResult` 字典（key 为消息 ID），但实际签名只有 `aMessages` + 单 `aError` 回调，无 `aConversationId` 参数、无 `aResult`。以签名为准；怀疑注释拷贝自内部设计稿。
3. **`addConversationDelegate:delegateQueue:` 的 delegate 参数标为 `_Nullable`**（`- (void)addConversationDelegate:(id<EMConversationDelegate> _Nullable)aDelegate ...`），而 `removeConversationDelegate:` 标 `_Nonnull`，疑为标注疏漏。
4. **大量「5.0.0 替代 API」实际在 4.24.1 已存在**：迁移文档表格中的多数替代接口（`modifyMessage:body:ext:completion:`、`fetchMessagesFromServerBy:...`、`approveJoinGroupRequest:sender:completion:`、`declineJoinGroupRequest:sender:reason:completion:`、`acceptInvitationFromGroup:inviter:completion:`、`declineGroupInvitation:inviter:reason:completion:`、`addMembers:/removeMembers:/blockMembers:/unblockMembers:`、`updateGroupSubject:/updateDescription:`、`addContact:message:completion:`、`approveFriendRequestFromUser:`、`declineFriendRequestFromUser:`、`getSelfIdsOnOtherPlatformWithCompletion:`、`getBlackListFromServerWithCompletion:`、`getLoggedInDevicesFromServerWithUserId:token:completion:`、`kickDeviceWithUserId:token:resource:completion:`、`kickAllDevicesWithUserId:token:completion:`、`updatePushDisplayStyle:completion:`、`updatePushDisplayName:completion:`、`getPushNotificationOptionsFromServerWithCompletion:`、`userAccountDidLoginFromOtherDeviceWithInfo:`、`userDidJoinGroup:users:`、`userDidLeaveGroup:users:`、EMConversation 版 `loadMessagesWithType:...completion:`、`requestToJoinPublicGroup:message:completion:`）经 `git grep` 逐一确认在 4.24.1 与 5.0.0 均存在。**含义：Flutter 侧工作主要是「删除旧封装」，少量「新增封装」（见类型为 new_api/new_type/new_listener/new_enum/new_property 的行），不存在「改名后需要新增的新接口」——新名字大多早已存在。**
5. **`joinGroupRequestDidReceive:user:reason:`（EMGroupManagerDelegate）在 diff 中同时出现 +/−，签名完全一致**：仅为文件内位置移动（从 deprecated 区附近移到文件顶部），无 API 变化。
6. **`getBlackList`（IEMContactManager）在 diff 中同时 −/+**：仅空格/标注格式调整（`*_Nullable )getBlackList;` → `*_Nullable)getBlackList;`），无变化。
7. **`isMemberInWhiteListFromServerWithGroupId:completion:`、`isMemberInMuteListFromServerWithGroupId:completion:`、`getGroupAnnouncementWithId:completion:`、`joinPublicGroup:completion:`、`unmuteMembers:...completion:`、`muteAllMembersFromGroup:completion:`、`unmuteAllMembersFromGroup:completion:`**：diff 中 −/+ 成对出现，仅位置移动或 nullability 标注微调，选择器不变。
8. **`EMErrorContactAddFaild → EMErrorContactAddFailed` 拼写修正未在迁移文档中提及**（值同为 1000）。Flutter 侧若用字符串名映射错误码需同步。
9. **迁移文档称「同步 `renewToken:` 仍在 5.0.0 公共头文件中保留」**：diff 未触及 renewToken 任何版本，与文档一致，无需动作。
10. **迁移文档提到的本地读取替代接口均未变**：`getAllConversations`/`getAllConversations:`、`getJoinedGroups`、`getBlackList`、`EMConversation.isPinned`/`pinnedTime`、`filterConversationsFromDB:filter:`、`EMConversation.disturbType` 在 4.24.1 均已有且 diff 未触及。
11. **`EMClientDelegate.h` 的 import 由 `EMCommonDefs.h` 改为 `EMOptions.h`**：因新回调参数使用 `EMDataSyncType`；对 Flutter 封装无直接影响。
12. **`EMCommonDefs.h` 中 `EM_DEPRECATED_IOS` 宏定义改为忽略参数**（`__attribute__((deprecated("")))`），属内部工程调整。
13. **聊天室 `IEMChatroomManager.h` 仅删除创建/解散共 4 个方法**（123 行变更全为删除及 pragma 注释），其余聊天室 API（加入/退出/成员管理等）未动；注意迁移文档只提了 create/destroy。
14. **`EMGroupManagerListener.h`（C++ listener 桥接头文件）中删除了对旧 delegate 回调的转发调用**（`joinGroupRequestDidDecline:reason:` 两参/三参、`userDidJoinGroup:user:`、`userDidLeaveGroup:user:`），与公开 delegate 删除一一对应，无额外公开 API。
15. **`EMConversation` 的 `conversationName`/`conversationAvatar` 是实例方法而非属性**（`- (NSString* _Nullable)conversationName;`），Flutter 封装时注意调用形式。
16. **4.24.2 侧分支hotfix（`EMUserInfoManager.mm` +2 行）不在 5.0.0 主线**：若 Flutter 当前基于 4.24.2 平版，需注意该 hotfix 内容在 5.0.0 中不存在（实现层，非公开 API）。
17. **`EMChatMessage+Private.h` +2 行**：内部头文件，未纳入清单；如 Flutter iOS 原生层直接引用了 Private 头需另行核对（正常不应引用）。

## 4. 统计

| 类型 | 条数 |
| --- | --- |
| removed | 111 |
| new_api | 10 |
| new_type | 3 |
| new_enum | 4 |
| new_property | 2 |
| new_listener | 4 |
| renamed | 10 |
| param_changed | 7 |
| **合计** | **151** |

备注：统计按本文件变更表的实际数据行计算；重载是否合并以表中现有行口径为准。


