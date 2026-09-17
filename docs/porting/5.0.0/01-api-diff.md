# 5.0.0 平版 · 阶段一：公开 API Diff 双端对照总清单（iOS + Android）

## 1. 头部信息

- **diff 锚点**：
  - iOS（仓库 `/Users/asterisk/Codes/zuoyu_native/emclient-ios`）：`4.24.1` = `ba235111d262f52d0d4aaeb8045a1b25b1ef1929` → `5.0.0` = `f8f506ccb009db38d47280ab713a65e468287f4b`
  - Android（仓库 `/Users/asterisk/Codes/zuoyu_native/emclient-android`）：`SDK_4.24.1` = `300865ac9cb1813c113199f0b19a65be79c4731a` → `SDK_5.0.0` = `8025ecb767e72a5c4623fab457ed269011e773d6`
- **中间 tag 核对结论**：
  - iOS：`4.24.1` 与 `5.0.0` 之间仅有 `4.24.2`（`90bb2d911f6ca2b02355960b581f5703927fbf4a`），且 `4.24.2` 是侧分支 hotfix tag（不在 5.0.0 祖先链上），仅改动 `EMUserInfoManager.mm` 2 行实现代码，**无任何公开头文件变化**。结论：无跳版遗漏，`4.24.1 → 5.0.0` 直接 diff 覆盖全部公开 API 变化。
  - Android：`SDK_4.24.1` 与 `SDK_5.0.0` 之间**无任何中间 tag**，不存在跳版，直接两端 diff。
- **diff 范围**：
  - iOS：`newSDK/HyphenateSDK/` 下公开头文件（`EM*.h`、`IEM*.h`），排除 `*+Private.h` 等内部头文件与 `.mm` 实现；`pushExtension/`、`translate/` 两目录两 tag 间零改动。
  - Android：`hyphenatechatsdk/src/com/hyphenate/` 根包公开文件 + `chat/` 子包公开类；`chat/adapter/`、`chat/core/` 内部实现未 diff；`cloud/`、`notification/`、`push/`、`util/` 子包仅 AndroidX import 替换，无公开 API 变化。
- **参考文档**：
  - iOS 迁移指南：`/Users/asterisk/Codes/zuoyu/easemob-doc/docs/document/ios/migration_guide.md`
  - Android 迁移指南：`/Users/asterisk/Codes/zuoyu/easemob-doc/docs/document/android/migration_guide.md`
  - 单端输入清单：`01-api-diff-ios.md`（151 行条目）、`01-api-diff-android.md`（106 行证据，其中 104 行变更、2 行「无变化核对」）
- **合并口径**：
  - 按语义配对，双端配对成功的条目共用同一 id；仅单端有的条目保留原输入文件 id。
  - 同名重载合并为一条，签名栏注明「含 N 个重载」；跨端配对时一端签名块天然含多个重载的，在签名栏内注明。
  - 签名逐字保留自两份输入文件，未改写。
  - 决策规则：双端都有 → `include`；仅单端有 → `defer`；`useAgoraChatDomain` 相关 → `skip`（**两份输入清单中均未出现该项，本清单 skip 条数为 0**，KI-107 规则备而不用）；Android `EMClient#getDeviceInfo()` 按已知疑点 → `defer`。
  - 状态列已在阶段三回填：include=`implemented`，defer=`deferred`，skip=`skipped`。
  - 行为变化不计入公开 API 行：Android `EMClient#init` 删除自动登录逻辑记录在交叉验证与 CHANGELOG，不计为独立公开 API。

## 2. 总变更清单

类型取值：new_api / removed / renamed / param_changed / new_type / new_property / new_enum / new_listener。renamed 条目的签名栏写「旧 → 新」。

### client

| id | 类型 | 领域 | iOS 源签名 | Android 源签名 | 迁移文档依据 | 决策 | 状态 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| client_register_account | removed | client | `- (EMError *_Nullable)registerWithUsername:(NSString * _Nonnull)aUsername password:(NSString * _Nonnull)aPassword;` 与 `- (void)registerWithUsername:(NSString *_Nonnull)aUsername password:(NSString *_Nonnull)aPassword completion:(void (^_Nullable)(NSString * _Nonnull aUsername, EMError * _Nullable aError))aCompletionBlock;`（含 2 个重载） | `public void createAccount(String username, String password) throws HyphenateException` | 初始化与登录-密码登录下线 / 密码登录下线 | include | implemented |
| client_fetch_token_with_password | removed | client | `- (void)fetchTokenWithUsername:(NSString *_Nonnull)aUsername password:(NSString *_Nonnull)aPassword completion:(void (^_Nullable)(NSString * _Nullable aToken, EMError * _Nullable aError))aCompletionBlock;` | `public void getUserTokenFromServer(final String username, final String password, final EMValueCallBack<String> callBack)` | 同上 | include | implemented |
| client_login_with_password | removed | client | `- (EMError *_Nullable)loginWithUsername:(NSString *_Nonnull)aUsername password:(NSString *_Nonnull)aPassword EM_DEPRECATED_IOS(3_0_0, 4_5_0,"Use -EMClient loginWithUsername:token:completion instead");` 与 `- (void)loginWithUsername:(NSString *_Nonnull)aUsername password:(NSString *_Nonnull)aPassword completion:(void (^_Nullable)(NSString * _Nonnull aUsername, EMError *_Nullable aError))aCompletionBlock EM_DEPRECATED_IOS(3_0_0, 4_5_0,"Use -EMClient loginWithUsername:token:completion instead");`（含 2 个重载） | `public void login(String id, String password, @NonNull final EMCallBack callback)` | 同上 | include | implemented |
| client_login_with_agora_token | removed | client | `- (EMError *_Nullable)loginWithUsername:(NSString *_Nonnull)aUsername agoraToken:(NSString *_Nonnull)aAgoraToken EM_DEPRECATED_IOS(3_8_9, 4_2_0,"Use -EMClient loginWithUsername:token instead");` 与 `- (void)loginWithUsername:(NSString *_Nonnull)aUsername agoraToken:(NSString *_Nonnull)aAgoraToken completion:(void (^_Nullable)(NSString * _Nonnull aUsername, EMError *_Nullable aError))aCompletionBlock EM_DEPRECATED_IOS(3_8_9, 4_2_0,"Use -EMClient loginWithUsername:token:completion instead");`（含 2 个重载） | `public void loginWithAgoraToken(String username, String agoraToken, @NonNull final EMCallBack callback)` | 同上 | include | implemented |
| client_service_check | removed | client | `- (void)serviceCheckWithUsername:(NSString *_Nonnull)aUsername password:(NSString *_Nonnull)aPassword completion:(void (^_Nullable)(EMServerCheckType aType, EMError *_Nullable aError))aCompletionBlock __deprecated_msg("This method is deprecated");` | `public void check(String username, String password, final CheckResultListener listener)` + `public interface CheckResultListener { void onResult(@EMCheckType.CheckType int type, int result, String desc); }` | 同上 | include | implemented |
| client_check_type | removed | client | `typedef NS_ENUM(NSInteger, EMServerCheckType) { EMServerCheckAccountValidation = 0, EMServerCheckGetDNSListFromServer, EMServerCheckGetTokenFromServer, EMServerCheckDoLogin, EMServerCheckDoLogout, };` | `public class EMCheckType`（常量 `ACCOUNT_VALIDATION=0`、`GET_DNS_LIST_FROM_SERVER=1`、`GET_TOKEN_FROM_SERVER=2`、`DO_LOGIN=3`、`DO_MSG_SEND=4`、`DO_LOGOUT=5` + `@interface CheckType`）随 `EMClient#check` 删除 | 同上 | include | implemented |
| client_auto_login_state_query | removed | client | `@property(nonatomic, readonly) BOOL isAutoLogin;`（EMClient） | `public boolean isLoggedInBefore()` | 初始化与登录-自动登录移除 / 自动登录移除 | include | implemented |
| client_statistics_manager | removed | client | `@property (nonatomic, strong, readonly) id<IEMStatisticsManager> _Nullable statisticsManager;` 及 `#import "IEMStatisticsManager.h"` | `public EMStatisticsManager statisticsManager()` | 其他删除的 API-无客户端替代 | include | implemented |
| statistics_module | removed | client | `@protocol IEMStatisticsManager`（`getMessageStatisticsById:`、`getMessageCountWithStart:end:direction:type:`、`getMessageStatisticsSizeWithStart:end:direction:type:`）、`@interface EMStatisticsManager : EMManager<IEMStatisticsManager>`、`@interface EMChatMessageStatistics : NSObject`（10 个只读属性）、`EMMessageStatisticsDirection`、`EMMessageStatisticsType` 两个枚举；`Statistics/` 目录 3 个公开头文件全部删除 | `public class EMStatisticsManager extends EMBase<EMAStatisticsManager>`（含 `getMessageStatistics(String)`、`getMessageCount(long, long, EMSearchMessageDirect, EMSearchMessageType)`、`getMessageSize(long, long, EMSearchMessageDirect, EMSearchMessageType)` 及内部枚举 `EMSearchMessageDirect`、`EMSearchMessageType`）；`public class EMMessageStatistics extends EMBase<EMAMessageStatistics>`（含 `getMsgId()`、`getTo()`、`getFrom()`、`getType()`、`getChatType()`、`getMsgTime()`、`direct()`、`getMsgSize()`、`getAttachmentSize()`、`getThumbnailSize()`） | 同上 | include | implemented |
| client_get_logged_in_devices_with_password | removed | client | `- (NSArray<EMDeviceConfig*> *_Nullable)getLoggedInDevicesFromServerWithUsername:(NSString * _Nonnull)aUsername password:(NSString * _Nonnull)aPassword error:(EMError ** _Nullable)pError;` 与 `- (void)getLoggedInDevicesFromServerWithUsername:(NSString *_Nonnull)aUsername password:(NSString *_Nonnull)aPassword completion:(void (^_Nullable)(NSArray<EMDeviceConfig*> * _Nullable aList, EMError *_Nullable aError))aCompletionBlock;`（含 2 个重载） | `public List<EMDeviceInfo> getLoggedInDevicesFromServer(String username, String password) throws HyphenateException` | 设备管理与鉴权 | include | implemented |
| client_kick_device_with_password | removed | client | `- (EMError *_Nullable)kickDeviceWithUsername:(NSString *_Nonnull)aUsername password:(NSString *_Nonnull)aPassword resource:(NSString *_Nonnull)aResource;` 与 `- (void)kickDeviceWithUsername:(NSString *_Nonnull)aUsername password:(NSString *_Nonnull)aPassword resource:(NSString *_Nonnull)aResource completion:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;`（含 2 个重载） | `public void kickDevice(String username, String password, String resource) throws HyphenateException` | 同上 | include | implemented |
| client_kick_all_devices_with_password | removed | client | `- (EMError *_Nullable)kickAllDevicesWithUsername:(NSString *_Nonnull)aUsername password:(NSString *_Nonnull)aPassword;` 与 `- (void)kickAllDevicesWithUsername:(NSString *_Nonnull)aUsername password:(NSString *_Nonnull)aPassword completion:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;`（含 2 个重载） | `public void kickAllDevices(String username, String password) throws HyphenateException` | 同上 | include | implemented |
| client_delegate_sync_data_start | new_listener | client | `- (void)syncDataStartWithType:(EMDataSyncType)type;`（EMClientDelegate） | `default void onDataSyncStart(EMOptions.EMDataSyncType type){}`（EMConnectionListener） | 数据同步与服务端拉取 API 迁移 / 数据同步 API | include | implemented |
| client_delegate_sync_data_finished | new_listener | client | `- (void)syncDataFinished:(EMError * _Nullable)error type:(EMDataSyncType)type;`（EMClientDelegate） | `default void onDataSyncFinish(EMOptions.EMDataSyncType type, int errorCode){}`（EMConnectionListener） | 同上 | include | implemented |
| client_delegate_on_database_opened | new_listener | client | `- (void)onDatabaseOpened:(EMError * _Nullable)error username:(NSString *_Nonnull)username;`（EMClientDelegate） | `default void onDatabaseOpened(String username) {}`（EMConnectionListener） | 初始化与登录-登录与数据库打开解耦 | include | implemented |
| client_login_with_username_token_sync | removed | client | `- (EMError *_Nullable)loginWithUsername:(NSString *_Nonnull)aUsername token:(NSString *_Nonnull)aToken;` | 无（Android 本无同步 token 登录） | 初始化与登录-密码登录下线 | defer | deferred |
| client_get_device_config | param_changed | client | `- (EMDeviceConfig * _Nullable)getDeviceConfig:(EMError **)pError;`（原 `- (EMDeviceConfig *)getDeviceConfig:(EMError **)pError;`） | 无 | 无（仅 nullability 标注） | defer | deferred |
| client_delegate_auto_login_did_complete | removed | client | `- (void)autoLoginDidCompleteWithError:(EMError * _Nullable)aError;`（EMClientDelegate） | 无（Android 本无该回调） | 监听器回调变化汇总 | defer | deferred |
| client_delegate_user_account_did_login_from_other_device | removed | client | `- (void)userAccountDidLoginFromOtherDevice:(NSString* _Nullable)aDeviceName EM_DEPRECATED_IOS(4_1_0, 4_7_0, "Use userAccountDidLoginFromOtherDeviceWithInfo: instead");` 与 `- (void)userAccountDidLoginFromOtherDevice EM_DEPRECATED_IOS(3_1_0, 4_1_0, "Use userAccountDidLoginFromOtherDevice: instead");`（含 2 个重载） | 无（Android 侧旧回调为 `onLogout` 系列，见下） | 同上 | defer | deferred |
| client_renew_token_no_callback_removed | removed | client | 无（iOS 同步 `renewToken:` 在 5.0.0 保留，diff 未触及） | `public void renewToken(String newAgoraToken)` | 密码登录下线 | defer | deferred |
| client_get_logged_in_devices_token_sync_removed | removed | client | 无（iOS 仅有异步 token 版，4.24.1 已存在且未动） | `public List<EMDeviceInfo> getLoggedInDevicesFromServerWithToken(@NonNull String username, @NonNull String token) throws HyphenateException` | 设备管理与鉴权 | defer | deferred |
| client_fetch_logged_in_devices_with_token_new | new_api | client | 无 | `public void fetchLoggedInDevicesFromServerWithToken(@NonNull String username, @NonNull String token, EMValueCallBack<List<EMDeviceInfo>> callBack)` | 设备管理与鉴权 | defer | deferred |
| client_is_database_opened_new | new_api | client | 无 | `public boolean isDatabaseOpened()` | 登录与数据库打开解耦 | defer | deferred |
| client_get_device_info_new | new_api | client | 无 | `public JSONObject getDeviceInfo()` | （无）疑似内部辅助方法暴露为 public | defer | deferred |
| client_version_bump | param_changed | client | 无 | `public final static String VERSION = "4.24.1"` → `"5.0.0"` | — | defer | deferred |

### options

| id | 类型 | 领域 | iOS 源签名 | Android 源签名 | 迁移文档依据 | 决策 | 状态 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| options_data_sync_type_enum | new_enum | client | `typedef NS_OPTIONS(NSInteger, EMDataSyncType) { EMDataSyncTypeNone = 0, EMDataSyncTypeConversations = 1 << 0, EMDataSyncTypeContacts = 1 << 1, EMDataSyncTypeJoinedGroups = 1 << 2, };` | `public enum EMDataSyncType { NONE(0), CONVERSATIONS(1 << 0), CONTACTS(1 << 1), JOINED_GROUPS(1 << 2); public int getValue(); public static int toNativeMask(EnumSet<EMDataSyncType> types); public static EnumSet<EMDataSyncType> fromNativeMask(int mask); }` | 数据同步与服务端拉取 API 迁移 / 数据同步 API | include | implemented |
| options_data_sync_type | new_property | client | `@property (nonatomic, assign) EMDataSyncType dataSyncType;` | `public void setDataSyncType(EnumSet<EMDataSyncType> types)` / `public EnumSet<EMDataSyncType> getDataSyncType()` | 同上 | include | implemented |
| options_is_auto_login | removed | client | `@property(nonatomic, assign) BOOL isAutoLogin;` | `public void setAutoLogin(boolean autoLogin)` / `public boolean getAutoLogin()` | 初始化与登录-自动登录移除 / 自动登录移除 | include | implemented |
| options_enable_require_read_ack | removed | client | `@property(nonatomic, assign) BOOL enableRequireReadAck;` | `public void setRequireAck(boolean requireAck)` / `public boolean getRequireAck()` | 已读回执体系重构 | include | implemented |
| options_enable_auto_sync_contacts | removed | client | `@property (nonatomic) BOOL enableAutoSyncContacts;` | `public void setEnableAutoSyncContacts(boolean enable)` / `public boolean isEnableAutoSyncContacts()` | 数据同步与服务端拉取 API 迁移 / 服务端拉取 API 迁移 | include | implemented |
| options_report_server_removed | removed | client | 无 | `public String getReportServer()` / `public void setReportServer(String reportServer)` | 其他删除的 API | defer | deferred |
| options_area_code_int_removed | removed | client | 无 | `public static class AreaCode`（int 常量容器）+ `public static final int AREA_CODE_CN = 1;` 等 7 个常量 | 有替代方式的 API | defer | deferred |
| options_area_code_enum_new | new_enum | client | 无 | `public enum AreaCode { CN(1), NA(2), EU(4), AS(8), JP(16), IN(32), GLOB(-1); public int getValue(); }` | 有替代方式的 API | defer | deferred |
| options_set_area_code_param_changed | param_changed | client | 无 | 旧：`public void setAreaCode(int code)` → 新：`public void setAreaCode(AreaCode code)` | 有替代方式的 API | defer | deferred |

### multidevice

| id | 类型 | 领域 | iOS 源签名 | Android 源签名 | 迁移文档依据 | 决策 | 状态 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| multidevice_event_conversation_unread_message_count_cleared | new_enum | client | `EMMultiDevicesEventConversationUnreadMessageCountCleared = 65,` | `int CONVERSATION_UNREAD_MESSAGECOUNT_CLEARED = 65;` | 已读回执体系重构-多设备事件 / 多设备事件 | include | implemented |
| multidevice_event_all_conversation_unread_message_count_cleared | new_enum | client | `EMMultiDevicesEventAllConversationUnreadMessageCountCleared = 66,` | `int ALL_CONVERSATION_UNREAD_MESSAGECOUNT_CLEARED = 66;` | 同上 | include | implemented |

### chat（含已读回执体系）

| id | 类型 | 领域 | iOS 源签名 | Android 源签名 | 迁移文档依据 | 决策 | 状态 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| chat_fetch_conversations_from_server | removed | conversation | `- (void)getConversationsFromServer:(void (^_Nullable)(NSArray<EMConversation *> * _Nullable aConversations, EMError * _Nullable aError))aCompletionBlock EM_DEPRECATED_IOS(4_0_0, ...);`、`- (void)getConversationsFromServerByPage:(NSUInteger)pageNumber pageSize:(NSUInteger)pageSize completion:(void (^_Nullable)(NSArray<EMConversation *> * _Nullable aConversations, EMError * _Nullable aError))aCompletionBlock EM_DEPRECATED_IOS(4_0_0, ...);`、`- (void)getConversationsFromServerWithCursor:(nullable NSString *)cursor pageSize:(UInt8)pageSize completion:(nonnull void (^)(EMCursorResult<EMConversation *> * _Nullable result, EMError * _Nullable error))completionBlock;`（3 个方法） | 3 个异步重载：`asyncFetchConversationsFromServer(EMValueCallBack<Map<String, EMConversation>>)`、`asyncFetchConversationsFromServer(int pageNum, int pageSize, EMValueCallBack<Map<String, EMConversation>>)`、`asyncFetchConversationsFromServer(int limit, String cursor, EMValueCallBack<EMCursorResult<EMConversation>>)` | 服务端拉取 API 迁移 | include | implemented |
| chat_get_pinned_conversations_from_server | removed | conversation | `- (void)getPinnedConversationsFromServerWithCursor:(nullable NSString *)cursor pageSize:(UInt8)limit completion:(nonnull void (^)(EMCursorResult<EMConversation *> * _Nullable result, EMError * _Nullable error))completionBlock;` | `public void asyncFetchPinnedConversationsFromServer(final int limit, final String cursor, final EMValueCallBack<EMCursorResult<EMConversation>> callback)` | 同上 | include | implemented |
| chat_get_conversations_with_cursor_filter | removed | conversation | `- (void)getConversationsFromServerWithCursor:(NSString * _Nullable)cursor filter:(EMConversationFilter* _Nonnull)filter completion:(nonnull void (^)(EMCursorResult<EMConversation *> * _Nullable result, EMError * _Nullable error))completionBlock;` | `public void asyncGetConversationsFromServerWithCursor(@NonNull String cursor, @NonNull EMConversationFilter filter, EMValueCallBack<EMCursorResult<EMConversation>> callback)` | 同上 | include | implemented |
| chat_modify_message | param_changed | chat | `- (void)modifyMessage:(NSString *_Nonnull)messageId body:(EMMessageBody *_Nonnull)body completion:(void (^_Nonnull)(EMError * _Nullable error,EMChatMessage *_Nullable message))completionBlock;`（旧三参数版删除；iOS 四参数版 `modifyMessage:body:ext:completion:` 4.24.1 已存在） | 旧：`public void asyncModifyMessage(String messageId, EMMessageBody messageBodyModified, final EMValueCallBack<EMMessage> callBack)` → 新：`public void asyncModifyMessage(String messageId, @Nullable EMMessageBody messageBodyModified, @Nullable Map<String, Object> ext, final EMValueCallBack<EMMessage> callBack)` | 其他删除的 API-有替代方式 / 有替代方式的 API | include | implemented |
| chat_send_message_read_ack | removed | chat | `- (void)sendMessageReadAck:(NSString * _Nonnull)aMessageId toUser:(NSString * _Nonnull)aUsername completion:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;` | `public void ackMessageRead(String to, String messageId) throws HyphenateException` | 已读回执体系重构 / 发送消息已读回执与清除未读数 | include | implemented |
| chat_send_group_message_read_ack | removed | chat | `- (void)sendGroupMessageReadAck:(NSString * _Nonnull)aMessageId toGroup:(NSString * _Nonnull)aGroupId content:(NSString * _Nullable)aContent completion:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;` | `public void ackGroupMessageRead(String to, String messageId, String ext) throws HyphenateException` | 同上 | include | implemented |
| chat_send_message_read_receipts | new_api | chat | `- (void)sendMessageReadReceipts:(NSArray<EMChatMessage *> * _Nonnull)aMessages completion:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;` | `public void asyncSendMessageReadReceipts(final List<EMMessage> messages, final EMCallBack callBack)` | 同上 | include | implemented |
| chat_ack_conversation_read | removed | conversation | `- (void)ackConversationRead:(NSString * _Nonnull)conversationId completion:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;` | `public void ackConversationRead(String conversationId) throws HyphenateException` | 同上 | include | implemented |
| chat_clear_conversation_unread_message_count | new_api | conversation | `- (void)clearConversationUnreadMessageCount:(NSString * _Nonnull)aConversationId completion:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;` | `public void asyncClearConversationUnreadMessageCount(final String conversationId, final EMCallBack callBack)` | 同上 | include | implemented |
| chat_clear_all_conversation_unread_message_count | new_api | conversation | `- (void)clearAllConversationUnreadMessageCount:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;` | `public void asyncClearAllConversationUnreadMessageCount(final EMCallBack callBack)` | 同上 | include | implemented |
| chat_get_group_message_read_receipts | new_api | chat | `- (void)getGroupMessageReadReceipts:(NSArray<EMChatMessage *> * _Nonnull)aMessages completion:(void (^_Nullable)(NSArray<EMMessageReadReceipt *> *_Nullable aReceipts, EMError *_Nullable aError))aCompletionBlock;` | `public void asyncGetGroupMessageReadReceipts(final List<EMMessage> messages, final EMValueCallBack<List<EMMessageReadReceipt>> callBack)` | 已读回执体系重构-回执详情查询 | include | implemented |
| chat_fetch_history_messages | removed | chat | `- (EMCursorResult<EMChatMessage*> *_Nullable)fetchHistoryMessagesFromServer:(NSString *_Nonnull)aConversationId conversationType:(EMConversationType)aConversationType startMessageId:(NSString *_Nullable)aStartMessageId fetchDirection:(EMMessageFetchHistoryDirection)direction pageSize:(int)aPageSize error:(EMError **_Nullable)pError __deprecated_msg(...)` 及无 `fetchDirection` 的同步重载（共 2 个同步方法）；`- (void)asyncFetchHistoryMessagesFromServer:(NSString *_Nonnull)aConversationId conversationType:(EMConversationType)aConversationType startMessageId:(NSString *_Nullable)aStartMessageId pageSize:(int)aPageSize completion:...` 及带 `fetchDirection:` 的重载（共 2 个异步方法，均 `__deprecated_msg`） | `public void asyncFetchHistoryMessage(final String conversationId, final EMConversationType type, final int pageSize, final String startMsgId, ...)` 两个异步重载 | 其他删除的 API-有替代方式 / 有替代方式的 API | include | implemented |
| chat_fetch_group_message_read_receipts | renamed | chat | 旧：`- (void)asyncFetchGroupMessageAcksFromServer:(NSString *_Nonnull)aMessageId groupId:(NSString *_Nonnull)aGroupId startGroupAckId:(NSString *_Nonnull)aGroupAckId pageSize:(int)aPageSize completion:(void (^_Nullable)(EMCursorResult<EMGroupMessageAck *> *_Nullable aResult, EMError *_Nullable error, int totalCount))aCompletionBlock;` → 新：`- (void)asyncFetchGroupMessageReadUsersFromServer:(NSString *_Nonnull)aMessageId groupId:(NSString *_Nonnull)aGroupId readReceiptId:(NSString *_Nonnull)aReadReceiptId pageSize:(int)aPageSize completion:(void (^_Nullable)(EMCursorResult<EMGroupReadReceipt *> *_Nullable aResult, EMError *_Nullable error, int totalCount))aCompletionBlock;` | 旧：`public void asyncFetchGroupReadAcks(final String msgId, final int pageSize, final String startAckId, final EMValueCallBack<EMCursorResult<EMGroupReadAck>> callBack)` → 新：`public void asyncFetchGroupMessageReadReceipts(final String msgId, final int pageSize, final String startAckId, final EMValueCallBack<EMCursorResult<EMGroupReadReceipt>> callBack)` | 已读回执体系重构-回执详情查询 | include | implemented |
| chat_report_message | removed | chat | `- (void)reportMessageWithId:(NSString *_Nonnull )aMessageId tag:(NSString *_Nonnull)aTag reason:(NSString *_Nonnull)aReason completion:(void(^_Nullable)(EMError* _Nullable error))aCompletion;` | `public void asyncReportMessage(String msgId, String tag, String reportReason, EMCallBack callback)` | 其他删除的 API-无客户端替代 | include | implemented |
| chat_mark_all_conversations_as_read | removed | conversation | `- (EMError*)markAllConversationsAsRead;` | `public boolean markAllConversationsAsRead()` | 已读回执体系重构 | include | implemented |
| chat_delegate_messages_did_read | removed | chat | `- (void)messagesDidRead:(NSArray<EMChatMessage *> * _Nonnull)aMessages;`（EMChatManagerDelegate） | `default void onMessageRead(List<EMMessage> messages) {}`（EMMessageListener） | 监听器回调变化汇总 / 接收消息已读回执 | include | implemented |
| chat_delegate_group_message_did_read | removed | chat | `- (void)groupMessageDidRead:(NSArray<EMGroupMessageAck *> * _Nonnull)aGroupAcks;` 与 `- (void)groupMessageDidRead:(EMChatMessage * _Nonnull)aMessage groupAcks:(NSArray<EMGroupMessageAck *> * _Nonnull)aGroupAcks __deprecated_msg("Use -groupMessageDidRead: instead");`（含 2 个重载） | `default void onGroupMessageRead(List<EMGroupReadAck> groupReadAcks) {}`（EMMessageListener） | 同上 | include | implemented |
| chat_delegate_group_message_ack_has_changed | removed | chat | `- (void)groupMessageAckHasChanged;`（EMChatManagerDelegate） | `default void onReadAckForGroupMessageUpdated() {}`（EMMessageListener） | 同上（Android 文档称改名为 `onReadReceiptForGroupMessageUpdated`，5.0.0 源码不存在，见交叉验证已知矛盾 1） | include | implemented |
| chat_delegate_on_conversation_read | removed | conversation | `- (void)onConversationRead:(NSString * _Nonnull)from to:(NSString * _Nonnull)to;`（EMChatManagerDelegate） | `void onConversationRead(String from, String to)`（EMConversationListener） | 同上 | include | implemented |
| chat_delegate_on_message_read_receipts | new_listener | chat | `- (void)onMessageReadReceipts:(NSArray<EMMessageReadReceipt *> * _Nonnull)aReceipts;`（EMChatManagerDelegate） | `default void onMessageReadReceipts(List<EMMessageReadReceipt> receipts) {}`（EMMessageListener） | 同上 | include | implemented |
| chat_get_unread_message_count | new_api | chat | `- (NSInteger)getUnreadMessageCount;` | 无（Android `getUnreadMessageCount` 4.24.1 已存在，5.0.0 仅统计范围行为变化，双端一致） | 主要新增 API / 行为变化 1 | defer | deferred |
| chat_import_conversations | removed | conversation | `- (void)importConversations:(NSArray<EMConversation *> * _Nullable)aConversations completion:(void (^ _Nullable)(EMError * _Nullable aError))aCompletionBlock;` | 无（Android diff 未提及） | 其他删除的 API-无客户端替代 | defer | deferred |
| chat_resend_message | removed | chat | `- (void)resendMessage:(EMChatMessage *_Nonnull)aMessage progress:(void (^_Nullable)(int progress))aProgressBlock completion:(void (^_Nullable)(EMChatMessage *_Nullable message, EMError *_Nullable error))aCompletionBlock;` | 无 | 其他删除的 API-有替代方式 | defer | deferred |
| chat_load_messages_with_type | removed | chat | `- (NSArray<EMChatMessage *> * _Nullable)loadMessagesWithType:(EMMessageBodyType)aType timestamp:(long long)aTimestamp count:(int)aCount fromUser:(NSString* _Nullable)aUsername searchDirection:(EMMessageSearchDirection)aDirection;` 及 completion 异步重载（IEMChatManager 上共 2 个） | 无 | 同上 | defer | deferred |
| chat_load_messages_with_keyword_legacy | removed | chat | `- (NSArray<EMChatMessage *> *)loadMessagesWithKeyword:(NSString*)aKeywords timestamp:(long long)aTimestamp count:(int)aCount fromUser:(NSString*)aSender searchDirection:(EMMessageSearchDirection)aDirection;` 及对应 completion 重载（无 `scope` 参数的 2 个旧重载） | 无 | 同上 | defer | deferred |
| chat_load_messages_with_keyword_scope | param_changed | chat | `- (void)loadMessagesWithKeyword:(NSString* _Nonnull)aKeywords timestamp:(long long)aTimestamp count:(int)aCount fromUser:(NSString *_Nullable)aSender searchDirection:(EMMessageSearchDirection)aDirection scope:(EMMessageSearchScope)aScope completion:(void (^_Nullable)(NSArray<EMChatMessage *> *_Nullable aMessages, EMError *_Nullable aError))aCompletionBlock;`（仅 nullability 标注收紧，选择器不变） | 无 | 无 | defer | deferred |
| chat_delete_messages_before | param_changed | chat | `- (void)deleteMessagesBefore:(NSUInteger)aTimestamp completion:(void(^_Nullable)(EMError*_Nullable error))aCompletion;`（原 completion 无 nullability 标注） | 无 | 无 | defer | deferred |
| chat_delegate_conversation_list_did_update | removed | conversation | `- (void)conversationListDidUpdate:(NSArray<EMConversation *> * _Nonnull)aConversationList;`（自 EMChatManagerDelegate 删除） | 无（Android 会话更新回调本就在 EMConversationListener） | 监听器回调变化汇总 | defer | deferred |
| chat_add_conversation_delegate | new_api | conversation | `- (void)addConversationDelegate:(id<EMConversationDelegate> _Nullable)aDelegate delegateQueue:(dispatch_queue_t _Nullable)aQueue NS_SWIFT_NAME(addConversation(delegate:queue:));` 与 `- (void)removeConversationDelegate:(id<EMConversationDelegate> _Nonnull)aDelegate NS_SWIFT_NAME(removeConversation(delegate:));` | 无 | 主要新增 API | defer | deferred |
| conversation_delegate_protocol | new_type | conversation | `@protocol EMConversationDelegate <NSObject> @optional - (void)conversationListDidUpdate:(NSArray<EMConversation *> * _Nonnull)aConversationList; @end`（新文件 `EMConversationDelegate.h`） | 无 | 监听器回调变化汇总 | defer | deferred |
| chat_load_all_conversations_removed | removed | conversation | 无 | `public boolean loadAllConversations()` | 服务端拉取 API 迁移 | defer | deferred |
| chat_update_participant_removed | removed | chat | 无 | `public boolean updateParticipant(String from, String changeTo)` | 其他删除的 API | defer | deferred |
| chat_async_fetch_history_messages_new | new_api | chat | 无（iOS 对应 `fetchMessagesFromServerBy:conversationType:cursor:pageSize:option:completion:` 4.24.1 已存在） | `public void asyncFetchHistoryMessages(String conversationId, EMConversationType type, int pageSize, String cursor, EMFetchMessageOption option, final EMValueCallBack<EMCursorResult<EMMessage>> callBack)` | 有替代方式的 API | defer | deferred |
| chat_async_delete_conversations_new | new_api | conversation | 无 | `public void asyncDeleteConversations(List<String> conversationIds, boolean deleteMessages, EMCallBack callBack)` | 主要新增 API | defer | deferred |
| msg_listener_on_message_recalled_removed | removed | chat | 无（iOS diff 未触及撤回回调） | `default void onMessageRecalled(List<EMMessage> messages){}`（EMMessageListener） | 监听器回调变化汇总 | defer | deferred |

### message / conversation 模型

| id | 类型 | 领域 | iOS 源签名 | Android 源签名 | 迁移文档依据 | 决策 | 状态 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| message_is_peer_read | renamed | chat | 旧：`@property (nonatomic) BOOL isReadAcked;` → 新：`@property (nonatomic,readonly) BOOL isPeerRead;` | 旧：`public boolean isAcked()` / `public void setAcked(boolean isAcked)` → 新：`public boolean isPeerRead()`（+ 包私有 `void setPeerRead(boolean)`） | 已读回执体系重构-EMMessage 已读相关方法重命名 | include | implemented |
| message_is_read | renamed | chat | 旧：`@property (nonatomic) BOOL isRead;` → 新：`@property (nonatomic,readonly) BOOL isRead;`（同名，setter 删除） | 旧：`public boolean isUnread()` / `public void setUnread(boolean unread)` → 新：`public boolean isRead()`（+ 包私有 `void setRead(boolean)`）（语义反转，取值取反） | 同上 / 行为变化 4 | include | implemented |
| message_is_need_read_receipt | renamed | chat | 旧：`@property (nonatomic) BOOL isNeedGroupAck;` → 新：`@property (nonatomic) BOOL isNeedReadReceipt;` | 旧：`public boolean isNeedGroupAck()` / `public void setIsNeedGroupAck(boolean need)` → 新：`public boolean isNeedReadReceipt()` / `public void setIsNeedReadReceipt(boolean need)` | 同上 | include | implemented |
| message_group_read_receipt_count | renamed | chat | 旧：`@property (nonatomic, readonly) int groupAckCount;` → 新：`@property (nonatomic, readonly) int groupReadReceiptCount;` | 旧：`public int groupAckCount()` / `public void setGroupAckCount(int count)` → 新：`public int readReceiptCount()`（+ 包私有 `void setReadReceiptCount(int)`） | 同上 | include | implemented |
| conversation_name_avatar | new_api | conversation | `- (NSString* _Nullable)conversationName;` 与 `- (NSString* _Nullable)conversationAvatar;`（EMConversation 实例方法而非属性，2 个方法） | `public String getConversationName()` / `public String getConversationAvatar()`（EMConversation） | 主要新增 API | include | implemented |
| conversation_mark_message_as_read | removed | conversation | `- (void)markMessageAsReadWithId:(NSString *_Nonnull)aMessageId error:(EMError ** _Nullable)pError;` 与 `- (void)markAllMessagesAsRead:(EMError ** _Nullable)pError;`（EMConversation，2 个方法） | `public void markMessageAsRead(String messageId)` / `public void markAllMessagesAsRead()`（EMConversation） | 已读回执体系重构 | include | implemented |
| group_read_receipt_type | renamed | chat | 旧：`@interface EMGroupMessageAck : NSObject`，属性 `messageId`/`readAckId`/`from`(NSString*)/`content`/`readCount`/`timestamp` → 新：`@interface EMGroupReadReceipt : NSObject`，属性 `messageId`/`readReceiptId`/`from`(**EMGroupMemberInfo***)/`readCount`/`timestamp`（`content` 删除；文件改名 `EMGroupMessageAck.h`→`EMGroupReadReceipt.h`） | 旧：`public class EMGroupReadAck { getAckId(); getMsgId(); String getFrom(); String getContent(); getCount(); getTimestamp(); }` → 新：`public class EMGroupReadReceipt extends EMBase<EMAGroupReadReceipt> { public String getAckId(); public String getMsgId(); public EMGroupMemberInfo getFrom(); public int getCount(); public long getTimestamp(); }` | 已读回执体系重构-回执详情查询 | include | implemented |
| message_read_receipt_type | new_type | chat | `@interface EMMessageReadReceipt : NSObject`，只读属性 `messageId`/`conversationId`/`isPeerReceipt`(BOOL)/`readCount`(NSInteger)（新文件 `EMMessageReadReceipt.h`） | `public class EMMessageReadReceipt extends EMBase<EMAMessageReadReceipt> { public String getMessageId(); public String getConversationId(); public boolean isPeerReceipt(); public int getReadCount(); }` | 同上 / 接收消息已读回执 | include | implemented |
| message_get_reaction | removed | chat | `- (EMMessageReaction *_Nullable)getReaction:(NSString * _Nonnull)reaction;` | 无 | 其他删除的 API-有替代方式 | defer | deferred |
| file_message_body_init_with_data | removed | chat | `- (instancetype _Nonnull)initWithData:(NSData *_Nullable)aData displayName:(NSString *_Nullable)aDisplayName;`（EMFileMessageBody） | 无 | 同上 / 行为变化 5 | defer | deferred |
| file_message_body_init_with_local_path | param_changed | chat | `- (instancetype _Nonnull)initWithLocalPath:(NSString * _Nonnull)aLocalPath displayName:(NSString * _Nonnull)aDisplayName;`（原两参数均 `_Nullable`） | 无 | 无（nullability 收紧） | defer | deferred |
| image_message_body_init_with_data | removed | chat | `- (instancetype)initWithData:(NSData *)aData thumbnailData:(NSData *)aThumbnailData __deprecated_msg("Use -initWithLocalPath:displayName: instead");`（EMImageMessageBody） | 无 | 其他删除的 API-有替代方式 | defer | deferred |
| stream_chunk_sequence_number | removed | chat | `@property (nonatomic) long sequenceNumber;`（EMStreamChunk） | 无 | 其他删除的 API-有替代方式 | defer | deferred |
| stream_chunk_is_complete | new_property | chat | `@property (nonatomic, readonly) BOOL isComplete;`（EMStreamChunk） | 无 | 同上 | defer | deferred |
| conversation_get_message_param_changed | param_changed | conversation | 无 | 旧：`public EMMessage getMessage(String messageId, boolean markAsRead)` → 新：`public EMMessage getMessage(String messageId)`（EMConversation） | 行为变化 4 | defer | deferred |
| conversation_search_msg_scope_sync_removed | removed | conversation | 无 | `public List<EMMessage> searchMsgFromDB(String keywords, long timeStamp, int maxCount, String from, EMSearchDirection direction, EMMessageSearchScope searchScope)`（EMConversation，同步） | 有替代方式的 API | defer | deferred |
| message_create_txt_send_message_removed | removed | chat | 无 | `public static EMMessage createTxtSendMessage(String content, String username)` | 有替代方式的 API | defer | deferred |
| message_get_user_name_removed | removed | chat | 无 | `public String getUserName()` | 有替代方式的 API | defer | deferred |
| message_get_recaller_removed | removed | chat | 无 | `public String getRecaller()` | 有替代方式的 API | defer | deferred |

### group

| id | 类型 | 领域 | iOS 源签名 | Android 源签名 | 迁移文档依据 | 决策 | 状态 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| group_options_type | removed | group | `@interface EMGroupOptions : NSObject`（属性 `style`/`maxUsers`/`IsInviteNeedConfirm`/`ext`）（`EMGroupOptions.h` 整文件删除） | `public class EMGroupOptions { public int maxUsers = 200; public EMGroupManager.EMGroupStyle style; public boolean inviteNeedConfirm = false; public String extField; }` | 群组配置模型重构 | include | implemented |
| group_style_enum | removed | group | `typedef NS_ENUM(NSInteger, EMGroupStyle) { EMGroupStylePrivateOnlyOwnerInvite = 0, EMGroupStylePrivateMemberCanInvite, EMGroupStylePublicJoinNeedApproval, EMGroupStylePublicOpenJoin, };` | `public enum EMGroupStyle { EMGroupStylePrivateOnlyOwnerInvite, EMGroupStylePrivateMemberCanInvite, EMGroupStylePublicJoinNeedApproval, EMGroupStylePublicOpenJoin }`（EMGroupManager 内部枚举） | 同上 | include | implemented |
| group_configs_type | new_type | group | `@interface EMGroupConfigs : NSObject`，属性 `maxUsers`/`IsInviteNeedConfirm`/`ext`/`allowInvites`/`joinApprovalRequired`/`isPublic`（新文件 `EMGroupConfigs.h`） | `public class EMGroupConfigs { public int maxUsers = 200; public boolean isPublic = false; public boolean joinApprovalRequired = false; public boolean allowInvites = false; public boolean inviteNeedConfirm = false; public String extField; }` | 同上 | include | implemented |
| group_configs_type_enum | new_enum | group | `typedef NS_OPTIONS(NSUInteger, EMGroupConfigsType) { EMGroupConfigsTypeAllowInvites = 1 << 0, EMGroupConfigsTypeMaxUsers = 1 << 1, EMGroupConfigsTypeInviteNeedConfirm = 1 << 2, EMGroupConfigsTypeJoinApprovalRequired = 1 << 3, EMGroupConfigsTypeIsPublic = 1 << 4, EMGroupConfigsTypeExt = 1 << 5, };` | `public enum EMGroupConfigsType { IS_PUBLIC(1 << 0), JOIN_APPROVAL_REQUIRED(1 << 1), ALLOW_INVITES(1 << 2), MAX_USERS(1 << 3), INVITE_NEED_CONFIRM(1 << 4), EXT(1 << 5); }`（EMGroupManager 内部枚举，含 `getValue()` / `static int toNativeMask(EnumSet)`） | 同上 / 相关 API 变化 | include | implemented |
| group_create_group | removed | group | `- (EMGroup * _Nullable)createGroupWithSubject:(NSString *_Nullable)aSubject description:(NSString *_Nullable)aDescription invitees:(NSArray<NSString *> * _Nullable)aInvitees message:(NSString *_Nullable)aMessage setting:(EMGroupOptions *_Nullable)aSetting error:(EMError **_Nullable)pError;`（同步）与 `- (void)createGroupWithSubject:(NSString *_Nullable)aSubject description:(NSString *_Nullable)aDescription invitees:(NSArray<NSString *> * _Nullable)aInvitees message:(NSString *_Nullable)aMessage setting:(EMGroupOptions *_Nullable)aSetting completion:(void (^_Nullable)(EMGroup *_Nullable aGroup, EMError *_Nullable aError))aCompletionBlock;`（无 avatar 异步版） | `public void asyncCreateGroup(final String groupName, final String desc, final String[] allMembers, final String reason, final EMGroupOptions option, final EMValueCallBack<EMGroup> callback)`（无 avatar 重载删除） | 群组配置模型重构-相关 API 变化 | include | implemented |
| group_create_group_with_avatar | param_changed | group | 旧：`- (void)createGroupWithSubject:avatar:description:invitees:message:setting:(EMGroupOptions *)setting completion:...` → 新：同选择器但 `setting:(EMGroupConfigs *)setting` | 旧：`public void asyncCreateGroup(final String groupName, final String avatar, final String desc, final String[] allMembers, final String reason, final EMGroupOptions option, final EMValueCallBack<EMGroup> callback)` → 新：`public void asyncCreateGroup(final String groupName, final String avatar, final String desc, final String[] allMembers, final String reason, final EMGroupConfigs configs, final EMValueCallBack<EMGroup> callback)` | 同上 | include | implemented |
| group_update_group_configs | new_api | group | `- (void)updateGroupWithId:(NSString *_Nonnull)groupId types:(EMGroupConfigsType)type configs:(EMGroupConfigs *_Nonnull)configs completion:(void (^_Nullable)(EMGroup *_Nullable group, EMError *_Nullable error))aCompletionBlock;` | `public void asyncUpdateGroupConfigs(final String groupId, final EnumSet<EMGroupConfigsType> types, final EMGroupConfigs configs, final EMValueCallBack<EMGroup> callback)` | 同上 / 主要新增 API | include | implemented |
| group_get_public_groups_from_server | removed | group | `- (EMCursorResult<EMGroup*> *_Nullable)getPublicGroupsFromServerWithCursor:(NSString *_Nullable)aCursor pageSize:(NSInteger)aPageSize error:(EMError **_Nullable)pError;` 及 completion 版本 | `public void asyncGetPublicGroupsFromServer(final int pageSize, final String cursor, final EMValueCallBack<EMCursorResult<EMGroupInfo>> callback)` | 其他删除的 API-无客户端替代 | include | implemented |
| group_get_joined_groups_from_server | removed | group | `- (void)getJoinedGroupsFromServerWithPage:(NSInteger)aPageNum pageSize:(NSInteger)aPageSize needMemberCount:(BOOL)aNeedMemberCount needRole:(BOOL)aNeedRole completion:(void (^_Nullable)(NSArray<EMGroup *> *_Nullable aList, EMError *_Nullable aError))aCompletionBlock;` | `public void asyncGetJoinedGroupsFromServer(final EMValueCallBack<List<EMGroup>> callback)` / `public void asyncGetJoinedGroupsFromServer(final int pageIndex, final int pageSize, boolean needMemberCount, boolean needRole, final EMValueCallBack<List<EMGroup>> callback)`（2 个异步重载） | 服务端拉取 API 迁移 | include | implemented |
| group_delegate_join_request_declined | removed | group | `- (void)joinGroupRequestDidDecline:(NSString *_Nonnull)aGroupId reason:(NSString *_Nullable)aReason EM_DEPRECATED_IOS(3_1_0, 4_2_0, "Use -joinGroupRequestDidDecline:reason:applicant: instead");` 与 `- (void)joinGroupRequestDidDecline:(NSString *_Nonnull)aGroupId reason:(NSString *_Nullable)aReason applicant:(NSString* _Nonnull )aApplicant;`（含 2 个重载） | `void onRequestToJoinDeclined(String groupId, String groupName, String decliner, String reason)`（EMGroupChangeListener，4.x 已废弃） | 监听器回调变化汇总 | include | implemented |
| group_delegate_user_did_join_group | removed | group | `- (void)userDidJoinGroup:(EMGroup *_Nonnull)aGroup user:(NSString *_Nonnull)aUsername EM_DEPRECATED_IOS(3_1_0, 4_15_0, "Use -userDidJoinGroup:users: instead");` | `void onMemberJoined(final String groupId, final String member)`（EMGroupChangeListener，4.x 已废弃） | 同上 | include | implemented |
| group_delegate_user_did_leave_group | removed | group | `- (void)userDidLeaveGroup:(EMGroup *_Nonnull)aGroup user:(NSString *_Nonnull)aUsername EM_DEPRECATED_IOS(3_1_0, 4_15_0, "Use -userDidLeaveGroup:users: instead");` | `void onMemberExited(final String groupId, final String member)`（EMGroupChangeListener，4.x 已废弃） | 同上 | include | implemented |
| group_settings_property | param_changed | group | `@property (nonatomic, strong, readonly) EMGroupConfigs *settings;`（原 `EMGroupOptions *settings`，EMGroup；属性名不变，类型改变） | 无（Android diff 未触及 EMGroup 对应访问器） | 群组配置模型重构 | defer | deferred |
| group_is_push_notification_enabled | removed | group | `@property (nonatomic, readonly) BOOL isPushNotificationEnabled;`（EMGroup） | 无 | 其他删除的 API-有替代方式 | defer | deferred |
| group_search_public_group | removed | group | `- (EMGroup * _Nullable)searchPublicGroupWithId:(NSString *_Nonnull)aGroundId error:(EMError **_Nullable)pError;` 及 completion 版本 | 无 | 其他删除的 API-无客户端替代 | defer | deferred |
| group_get_groups_without_push_notification | removed | group | `- (NSArray *)getGroupsWithoutPushNotification:(EMError **)pError EM_DEPRECATED_IOS(3_3_2, 3_8_3, "Use -IEMPushManager::noPushGroups");` | 无 | 其他删除的 API-有替代方式 | defer | deferred |
| group_get_group_specification_sync | removed | group | `- (EMGroup * _Nullable)getGroupSpecificationFromServerWithId:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` 与 `- (EMGroup * _Nullable)getGroupSpecificationFromServerWithId:(NSString *_Nonnull)aGroupId fetchMembers:(BOOL)fetchMembers error:(EMError **_Nullable)pError;`（含 2 个重载） | 无（Android 对应变更见 group_get_from_server_fetch_members_removed） | 同上 | defer | deferred |
| group_get_group_member_list_sync | removed | group | `- (EMCursorResult<NSString*> *)getGroupMemberListFromServerWithId:(NSString *_Nonnull)aGroupId cursor:(NSString *_Nullable)aCursor pageSize:(NSInteger)aPageSize error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_get_group_blacklist_sync | removed | group | `- (NSArray<NSString *> * _Nullable)getGroupBlacklistFromServerWithId:(NSString *_Nonnull)aGroupId pageNumber:(NSInteger)aPageNum pageSize:(NSInteger)aPageSize error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_get_group_mute_list_sync | removed | group | `- (NSArray<NSString *> * _Nullable)getGroupMuteListFromServerWithId:(NSString *_Nonnull)aGroupId pageNumber:(NSInteger)aPageNum pageSize:(NSInteger)aPageSize error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_get_group_file_list_sync | removed | group | `- (NSArray<EMGroupSharedFile *> *_Nullable)getGroupFileListWithId:(NSString *_Nonnull)aGroupId pageNumber:(NSInteger)aPageNum pageSize:(NSInteger)aPageSize error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_get_group_white_list_sync | removed | group | `- (NSArray *)getGroupWhiteListFromServerWithId:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_is_member_in_white_list_sync | removed | group | `- (BOOL)isMemberInWhiteListFromServerWithGroupId:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_get_group_announcement_sync | removed | group | `- (NSString *_Nullable)getGroupAnnouncementWithId:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_add_occupants_sync | removed | group | `- (EMGroup * _Nullable)addOccupants:(NSArray<NSString *> * _Nonnull)aOccupants toGroup:(NSString *_Nonnull)aGroupId welcomeMessage:(NSString *_Nullable)aWelcomeMessage error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_remove_occupants_sync | removed | group | `- (EMGroup * _Nullable)removeOccupants:(NSArray<NSString *> * _Nonnull)aOccupants fromGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_block_occupants_sync | removed | group | `- (EMGroup * _Nullable)blockOccupants:(NSArray<NSString *> * _Nonnull)aOccupants fromGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_unblock_occupants_sync | removed | group | `- (EMGroup * _Nullable)unblockOccupants:(NSArray<NSString *> * _Nonnull)aOccupants forGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_change_group_subject_sync | removed | group | `- (EMGroup * _Nullable)changeGroupSubject:(NSString *_Nullable)aSubject forGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_change_description_sync | removed | group | `- (EMGroup * _Nullable)changeDescription:(NSString *_Nullable)aDescription forGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_leave_group_sync | removed | group | `- (void)leaveGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_destroy_group_sync | removed | group | `- (EMError *)destroyGroup:(NSString *_Nonnull)aGroupId;` | 无 | 同上 | defer | deferred |
| group_block_group_sync | removed | group | `- (EMGroup * _Nullable)blockGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_unblock_group_sync | removed | group | `- (EMGroup * _Nullable)unblockGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_update_group_owner_sync | removed | group | `- (EMGroup * _Nullable)updateGroupOwner:(NSString *_Nonnull)aGroupId newOwner:(NSString *_Nonnull)aNewOwner error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_add_admin_sync | removed | group | `- (EMGroup * _Nullable)addAdmin:(NSString *_Nonnull)aAdmin toGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_remove_admin_sync | removed | group | `- (EMGroup * _Nullable)removeAdmin:(NSString *_Nonnull)aAdmin fromGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_mute_members_sync | removed | group | `- (EMGroup * _Nullable)muteMembers:(NSArray<NSString *> * _Nonnull)aMuteMembers muteMilliseconds:(NSInteger)aMuteMilliseconds fromGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_unmute_members_sync | removed | group | `- (EMGroup * _Nullable)unmuteMembers:(NSArray<NSString *> * _Nonnull)aMembers fromGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_mute_all_members_sync | removed | group | `- (EMGroup * _Nullable)muteAllMembersFromGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_unmute_all_members_sync | removed | group | `- (EMGroup * _Nullable)unmuteAllMembersFromGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_add_white_list_members_sync | removed | group | `- (EMGroup * _Nullable)addWhiteListMembers:(NSArray<NSString *> * _Nonnull)aMembers fromGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_remove_white_list_members_sync | removed | group | `- (EMGroup * _Nullable)removeWhiteListMembers:(NSArray<NSString *> * _Nonnull)aMembers fromGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_remove_group_shared_file_sync | removed | group | `- (EMGroup * _Nullable)removeGroupSharedFileWithId:(NSString *_Nonnull)aGroupId sharedFileId:(NSString *_Nonnull)aSharedFileId error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_update_group_announcement_sync | removed | group | `- (EMGroup * _Nullable)updateGroupAnnouncementWithId:(NSString *_Nonnull)aGroupId announcement:(NSString *_Nullable)aAnnouncement error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_update_group_ext_sync | removed | group | `- (EMGroup * _Nullable)updateGroupExtWithId:(NSString *_Nonnull)aGroupId ext:(NSString *_Nullable)aExt error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_join_public_group_sync | removed | group | `- (EMGroup * _Nullable)joinPublicGroup:(NSString *_Nonnull)aGroupId error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_apply_join_public_group | renamed | group | 旧：`- (EMGroup * _Nullable)applyJoinPublicGroup:(NSString *_Nonnull)aGroupId message:(NSString *_Nullable)aMessage error:(EMError **_Nullable)pError;`（同步）→ 新：`- (void)requestToJoinPublicGroup:(NSString *_Nonnull)aGroupId message:(NSString *_Nullable)aMessage completion:(void (^_Nullable)(EMGroup *_Nullable aGroup, EMError *_Nullable aError))aCompletionBlock;`（4.24.1 已有，5.0.0 仅位置移动） | 无 | 同上 | defer | deferred |
| group_accept_join_application | renamed | group | 旧：`- (EMError *)acceptJoinApplication:(NSString *_Nonnull)aGroupId applicant:(NSString *_Nonnull)aUsername;`（同步，删除）→ 新：`approveJoinGroupRequest:sender:completion:`（4.24.1 已有） | 无 | 同上 | defer | deferred |
| group_decline_join_application | renamed | group | 旧：`- (EMError *)declineJoinApplication:(NSString *_Nonnull)aGroupId applicant:(NSString *_Nonnull)aUsername reason:(NSString *_Nullable)aReason;`（同步，删除）→ 新：`declineJoinGroupRequest:sender:reason:completion:`（4.24.1 已有） | 无 | 同上 | defer | deferred |
| group_accept_invitation_from_group_sync | removed | group | `- (EMGroup * _Nullable)acceptInvitationFromGroup:(NSString *_Nonnull)aGroupId inviter:(NSString *_Nonnull)aUsername error:(EMError **_Nullable)pError;` | 无 | 同上 | defer | deferred |
| group_decline_invitation_from_group | renamed | group | 旧：`- (EMError *)declineInvitationFromGroup:(NSString *_Nonnull)aGroupId inviter:(NSString *_Nonnull)aUsername reason:(NSString *_Nullable)aReason;`（同步，删除）→ 新：`declineGroupInvitation:inviter:reason:completion:`（4.24.1 已有） | 无 | 同上 | defer | deferred |
| group_is_member_only_renamed | renamed | group | 无 | 旧：`public boolean isMemberOnly()` → 新：`public boolean isJoinApprovalRequired()`（EMGroup） | 相关 API 变化 | defer | deferred |
| group_get_users_new | new_api | group | 无（iOS `EMGroup#users` 属性 4.24.1 已存在，diff 未触及；迁移文档误列为新增，见交叉验证已知矛盾 2） | `public List<String> getUsers()`（EMGroup） | 主要新增 API | defer | deferred |
| group_get_from_server_fetch_members_removed | param_changed | group | 无 | 旧：`public EMGroup getGroupFromServer(String groupId, boolean fetchMembers) throws HyphenateException` 删除，保留 `public EMGroup getGroupFromServer(String groupId)` | 有替代方式的 API | defer | deferred |
| group_load_all_groups_removed | removed | group | 无 | `public synchronized boolean loadAllGroups()` | 服务端拉取 API 迁移 | defer | deferred |
| group_async_upload_shared_file_overload_removed | removed | group | 无 | `public void asyncUploadGroupSharedFile(final String groupId, final String filePath, final EMCallBack callBack)` | 其他删除的 API | defer | deferred |

### contact

| id | 类型 | 领域 | iOS 源签名 | Android 源签名 | 迁移文档依据 | 决策 | 状态 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| contact_get_all_contacts_from_server | removed | contact | `- (void)getAllContactsFromServerWithCompletion:(void (^_Nullable)(NSArray<EMContact *>* _Nullable aList, EMError* _Nullable aError))aCompletionBlock;`（EMContact 模型列表） | `public void asyncFetchAllContactsFromServer(EMValueCallBack<List<EMContact>> callback)`（EMContact 模型列表） | 服务端拉取 API 迁移 | include | implemented |
| contact_get_contacts_from_server_with_cursor | removed | contact | `- (void)getContactsFromServerWithCursor:(NSString* _Nullable)cursor pageSize:(NSUInteger)pageSize completion:(void (^_Nonnull)(EMCursorResult<EMContact*> * _Nullable aResult, EMError * _Nullable aError))aCompletionBlock;` | `public void asyncFetchAllContactsFromServer(int limit, String cursor, EMValueCallBack<EMCursorResult<EMContact>> callback)` | 同上 | include | implemented |
| contact_get_contacts_string_list_from_server | removed | contact | `- (void)getContactsFromServerWithCompletion:(void (^)(NSArray<NSString *> *_Nullable aList, EMError *aError_Nullable ))aCompletionBlock;` 与 `- (NSArray<NSString *> *_Nullable )getContactsFromServerWithError:(EMError **_Nullable )pError;`（NSString 列表，含 2 个重载） | `public void asyncGetAllContactsFromServer(final EMValueCallBack<List<String>> callback)` | 同上 | include | implemented |
| contact_delegate_on_friend_sync_start | removed | contact | `- (void)onFriendStartSync;`（EMContactManagerDelegate） | `default void onContactSyncStart() {}`（EMContactListener） | 监听器回调变化汇总 / 服务端拉取 API 迁移 | include | implemented |
| contact_delegate_on_friend_sync_finished | removed | contact | `- (void)onFriendSyncFinished:(EMError * _Nullable)error;`（EMContactManagerDelegate） | `default void onContactSyncFinishWithError(int errorCode, String error) {}`（EMContactListener） | 同上 | include | implemented |
| contact_add_contact_sync | removed | contact | `- (EMError *_Nullable )addContact:(NSString *_Nonnull)aUsername message:(NSString *_Nullable )aMessage;` | 无 | 其他删除的 API-有替代方式 | defer | deferred |
| contact_get_blacklist_from_server_sync | removed | contact | `- (NSArray<NSString *> *_Nullable )getBlackListFromServerWithError:(EMError **_Nullable )pError;` | 无 | 同上 | defer | deferred |
| contact_add_user_to_blacklist_sync | removed | contact | `- (EMError *_Nullable )addUserToBlackList:(NSString *_Nonnull)aUsername;` | 无 | 同上 | defer | deferred |
| contact_remove_user_from_blacklist_sync | removed | contact | `- (EMError *_Nullable )removeUserFromBlackList:(NSString *_Nonnull)aUsername;` | 无 | 同上 | defer | deferred |
| contact_accept_invitation_sync | removed | contact | `- (EMError *_Nullable )acceptInvitationForUsername:(NSString *_Nonnull)aUsername;` | 无 | 同上 | defer | deferred |
| contact_decline_invitation_sync | removed | contact | `- (EMError *_Nullable )declineInvitationForUsername:(NSString *_Nonnull)aUsername;` | 无 | 同上 | defer | deferred |
| contact_get_self_ids_on_other_platform_sync | removed | contact | `- (NSArray<NSString *> *_Nullable )getSelfIdsOnOtherPlatformWithError:(EMError **_Nullable )pError;` | 无 | 同上 | defer | deferred |
| contact_save_black_list | new_api | contact | `- (void)saveBlackList:(NSArray<NSString *> *_Nonnull)aBlackList completion:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;` | 无 | 主要新增 API | defer | deferred |

### room

| id | 类型 | 领域 | iOS 源签名 | Android 源签名 | 迁移文档依据 | 决策 | 状态 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| room_create_chatroom | removed | room | `- (EMChatroom *_Nullable)createChatroomWithSubject:(NSString *_Nullable)aSubject description:(NSString *_Nullable)aDescription invitees:(NSArray<NSString *> *_Nullable)aInvitees message:(NSString *_Nullable)aMessage maxMembersCount:(NSInteger)aMaxMembersCount error:(EMError **_Nullable)pError;` 及 completion 版本（含 2 个重载） | `public void asyncCreateChatRoom(final String subject, final String description, final String welcomeMessage, final int maxUserCount, final List<String> members, final EMValueCallBack<EMChatRoom> callBack)` | 其他删除的 API-无客户端替代 | include | implemented |
| room_destroy_chatroom | removed | room | `- (EMError *_Nullable)destroyChatroom:(NSString *_Nonnull)aChatroomId;` 与 `- (void)destroyChatroom:(NSString *_Nonnull)aChatroomId completion:(void (^_Nullable)(EMError * _Nullable aError))aCompletionBlock;`（含 2 个重载） | `public void asyncDestroyChatRoom(final String chatRoomId, final EMCallBack callBack)` | 同上 | include | implemented |
| room_get_all_chat_rooms_removed | removed | room | 无 | `public List<EMChatRoom> getAllChatRooms()` | 其他删除的 API | defer | deferred |
| room_fetch_from_server_fetch_members_removed | param_changed | room | 无 | 旧：`public EMChatRoom fetchChatRoomFromServer(String roomId, boolean fetchMembers) throws HyphenateException` 删除，保留 `public EMChatRoom fetchChatRoomFromServer(String roomId)` | 有替代方式的 API | defer | deferred |
| room_remove_chat_room_listener_removed | renamed | room | 无 | 旧：`public void removeChatRoomListener(EMChatRoomChangeListener listener)` → 新：`public void removeChatRoomChangeListener(EMChatRoomChangeListener listener)` | 有替代方式的 API | defer | deferred |
| room_listener_on_member_joined_2arg_removed | removed | room | 无 | `default void onMemberJoined(final String roomId, final String participant){}`（EMChatRoomChangeListener，4.x 已废弃） | 监听器回调变化汇总 | defer | deferred |
| room_listener_on_mute_list_added_removed | removed | room | 无 | `void onMuteListAdded(final String chatRoomId, final List<String> mutes, final long expireTime)`（EMChatRoomChangeListener，4.x 已废弃） | 监听器回调变化汇总 | defer | deferred |

### push

| id | 类型 | 领域 | iOS 源签名 | Android 源签名 | 迁移文档依据 | 决策 | 状态 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| push_update_push_display_style_sync | removed | push | `- (EMError *)updatePushDisplayStyle:(EMPushDisplayStyle)pushDisplayStyle;` | 无（Android push 模块无公开 API 变化） | 其他删除的 API-有替代方式 | defer | deferred |
| push_update_push_display_name_sync | removed | push | `- (EMError *_Nullable )updatePushDisplayName:(NSString * _Nonnull)aDisplayName;` | 无 | 同上 | defer | deferred |
| push_get_push_options_from_server_sync | removed | push | `- (EMPushOptions *_Nullable )getPushOptionsFromServerWithError:(EMError *_Nullable *_Nullable)pError;` | 无 | 同上 | defer | deferred |

### error code

| id | 类型 | 领域 | iOS 源签名 | Android 源签名 | 迁移文档依据 | 决策 | 状态 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| error_contact_add_faild_typo | renamed | client | 旧：`EMErrorContactAddFaild = 1000,` → 新：`EMErrorContactAddFailed = 1000,`（拼写修正，值不变） | 无（`EMError.java` 在 diff 中零变化） | 无 | defer | deferred |

## 3. 未匹配 / 疑点清单（合并版）

合并自 `01-api-diff-ios.md` 第 3 节（17 条，编号 i1-i17）与 `01-api-diff-android.md` 第 3 节（10 条，编号 a1-a10），逐条保留；「处理」列标注合并后的去向。末尾 N1-N11（N5 已移除）为本次配对发现的跨端语义不对齐项。

### 3.1 来自 iOS 清单

| 编号 | 现象 | 双端证据 | 处理 / 建议 |
| --- | --- | --- | --- |
| i1 | `EMGroup.users` 并非 5.0.0 新增，迁移文档「主要新增 API」误列 | iOS：`git grep` 确认 4.24.1 `EMGroup.h:212` 已有 `@property (nonatomic, strong, readonly) NSArray<NSString *> *users;`，diff 未触及；Android：`getUsers()` 为 5.0.0 真新增（defer 项 group_get_users_new） | → 已核实，收入交叉验证「已知矛盾 2」；Flutter 侧若已封装 `users` 则无需改动 |
| i2 | `sendMessageReadReceipts:completion:` 注释与签名不符（注释描述 `aConversationId` 参数和 `aResult` 字典回调，签名均无） | iOS 5.0.0 `IEMChatManager.h:544` 实测签名仅 `aMessages` + 单 `aError` 回调；Android 对应 `asyncSendMessageReadReceipts` 文档无此问题 | → 已核实，收入交叉验证「已知矛盾 3」；以签名为准 |
| i3 | `addConversationDelegate:delegateQueue:` 的 delegate 参数标 `_Nullable`，而 `removeConversationDelegate:` 标 `_Nonnull`，疑标注疏漏 | 仅 iOS（该能力 Android 由既有 EMConversationListener 承载） | 保留疑点；对应条目 chat_add_conversation_delegate 维持 defer，不改变 iOS 源 `_Nullable` 可选性，也不新增 Flutter 公开 API |
| i4 | 大量「5.0.0 替代 API」实际在 4.24.1 已存在（`modifyMessage:body:ext:`、`fetchMessagesFromServerBy:`、`approveJoinGroupRequest:` 等 20+ 个） | iOS `git grep` 逐一确认；Android 侧同类情况（如 `kickDeviceWithToken`、`onMembersJoined` 等 4.24.1 已存在） | 结论性说明，无需 defer：Flutter 侧工作以「删除旧封装」为主，「新名字」大多早已存在 |
| i5 | `joinGroupRequestDidReceive:user:reason:` 在 diff 中 +/− 成对、签名一致，仅位置移动 | 仅 iOS | 已确认无 API 变化，不进清单 |
| i6 | `getBlackList`（IEMContactManager）diff 中 −/+ 成对，仅空格/标注格式调整 | 仅 iOS | 已确认无 API 变化，不进清单 |
| i7 | `isMemberInWhiteListFromServerWithGroupId:completion:` 等 7 个 completion 方法 −/+ 成对，仅位置移动或标注微调 | 仅 iOS | 已确认无 API 变化，不进清单 |
| i8 | `EMErrorContactAddFaild → EMErrorContactAddFailed` 拼写修正（值同为 1000）未在迁移文档提及 | 仅 iOS；Android `EMError.java` 零变化 | → 已转为 defer 决策项 error_contact_add_faild_typo；Flutter 侧若按字符串名映射错误码需同步 |
| i9 | 迁移文档称同步 `renewToken:` 在 5.0.0 保留，diff 未触及，与文档一致 | iOS 无变化；Android 反向：无回调版 `renewToken(String)` 被删（defer 项 client_renew_token_no_callback_removed） | 无需动作（iOS）；Android 侧走 defer 决策 |
| i10 | 迁移文档提到的本地读取替代接口（`getAllConversations`、`getJoinedGroups`、`getBlackList`、`isPinned`/`pinnedTime`、`filterConversationsFromDB:`、`disturbType`）均未变 | iOS 4.24.1 已有且 diff 未触及；Android 对应 `getAllConversations()`/`getAllGroups()`/`getContactsFromLocal()` 同样未变 | 无需动作，作为 Flutter 迁移目标接口确认 |
| i11 | `EMClientDelegate.h` 的 import 由 `EMCommonDefs.h` 改为 `EMOptions.h`（因新回调参数用 `EMDataSyncType`） | 仅 iOS | 对 Flutter 封装无直接影响 |
| i12 | `EMCommonDefs.h` 中 `EM_DEPRECATED_IOS` 宏定义改为忽略参数 | 仅 iOS | 内部工程调整，无公开 API 影响 |
| i13 | 聊天室 `IEMChatroomManager.h` 仅删除创建/解散共 4 个方法，其余聊天室 API 未动；迁移文档也只提 create/destroy | 双端一致（Android 同删 create/destroy，另多删 `getAllChatRooms()`） | → 已并入 room_create_chatroom / room_destroy_chatroom 两条 include；Android 独有的 getAllChatRooms 删除已 defer |
| i14 | `EMGroupManagerListener.h`（C++ listener 桥接头文件）删除旧 delegate 转发调用 | 仅 iOS，与公开 delegate 删除一一对应 | 无额外公开 API，无需动作 |
| i15 | `EMConversation` 的 `conversationName`/`conversationAvatar` 是实例方法而非属性 | 仅 iOS（Android 为 `getConversationName()` 方法，形态天然一致） | 注意点已写入 conversation_name_avatar 条目；Flutter 封装按方法调用 |
| i16 | 4.24.2 侧分支 hotfix（`EMUserInfoManager.mm` +2 行）不在 5.0.0 主线 | 仅 iOS | 头部中间 tag 核对已覆盖；实现层非公开 API，若 Flutter 当前基于 4.24.2 平版需注意该 hotfix 在 5.0.0 不存在 |
| i17 | `EMChatMessage+Private.h` +2 行（内部头文件，未纳入清单） | 仅 iOS | 保留提示：Flutter iOS 原生层若直接引用 Private 头需另行核对（正常不应引用） |

### 3.2 来自 Android 清单

| 编号 | 现象 | 双端证据 | 处理 / 建议 |
| --- | --- | --- | --- |
| a1 | `onReadReceiptForGroupMessageUpdated` 不存在：迁移文档两处称 `onReadAckForGroupMessageUpdated()` 改名为它，但 5.0.0 源码全树（含内部包）无该方法 | Android：`git grep onReadReceiptForGroupMessageUpdated SDK_5.0.0` 无命中；SDK 仓库自带 `doc/api_changes_5.0.md` 明确「已删除」；iOS 对应回调 `groupMessageAckHasChanged` 也是直接删除 | → 已核实，收入交叉验证「已知矛盾 1」；以源码为准，Flutter 侧不应平版这个"新回调"，群已读更新由 `onMessageReadReceipts` 承载 |
| a2 | 迁移文档称删除「全部 4 个 `asyncFetchConversationsFromServer(...)` 重载」，SDK_4.24.1 实际只有 3 个 | Android：`git grep` SDK_4.24.1 实测 3 个重载（无参 / pageNum+pageSize / limit+cursor）；算上 pinned 与 filter 版共 5 个异步服务端会话拉取方法被删 | → 已核实；按 Android 提取规则不计同步 `fetchConversationsFromServer()`，以源码为准 |
| a3 | `EMClient#getDeviceInfo()` 疑似内部 API 暴露（无 javadoc、文档未提及，供内部 `setPresence` 用） | 仅 Android | → 已转为 defer 决策项 client_get_device_info_new；建议 Flutter 侧不平版，待确认 |
| a4 | `EMGroupConfigsType.toNativeMask(EnumSet)` / `EMDataSyncType.toNativeMask` / `fromNativeMask` 为 public static，语义属内部 JNI 掩码转换 | 仅 Android | Flutter 侧无需平版；include 条目 options_data_sync_type_enum / group_configs_type_enum 平版时只取枚举值，忽略掩码工具方法 |
| a5 | 迁移文档未精确指明的删除：`EMConversation#searchMsgFromDB(..., EMMessageSearchScope)` 同步重载（异步版保留） | 仅 Android | → 已转为 defer 决策项 conversation_search_msg_scope_sync_removed；交叉验证「diff 有文档无」收录 |
| a6 | 迁移文档未明确：`createGroup`/`asyncCreateGroup` 无 avatar 重载删除，5.0.0 仅保留带 avatar 形式 | 双端一致（iOS 同步版与无 avatar 异步版均删） | → 已并入 include 项 group_create_group / group_create_group_with_avatar；交叉验证收录 |
| a7 | 行为变化（无签名变化）：`getUnreadMessageCount` 统计范围收窄；`getMessage(String)` 不再自动标已读；`EMChatService` 旧保活移除；推送 Token 上传判断变化；前后台检测改用 AndroidX `ProcessLifecycleOwner` | Android 文档「行为变化」节；iOS 侧前两项同样适用（行为变化 1/4） | 前两项已分别落入 defer 项 chat_get_unread_message_count / conversation_get_message_param_changed 备注；保活与前后台检测对 Flutter 封装层无 API 影响，仅影响 example 工程依赖 |
| a8 | `EMOptions` 中 `AreaCode` 旧 int 常量（`AREA_CODE_CN` 等 7 个）全删，文档只提 `setAreaCode(int)` → `setAreaCode(AreaCode)` | 仅 Android | → 已转为 defer 决策项 options_area_code_int_removed 等 3 条；若 Flutter 侧把 areaCode 作 int 透传需改枚举映射 |
| a9 | `EMLoginExtensionInfo` 未变化：`onLogout(int, EMLoginExtensionInfo)` 4.24.1 已是 default 方法，5.0.0 仅去掉代理旧回调 | 仅 Android | 无变化确认；旧回调删除见 defer 项 connection_on_logout_* |
| a10 | 根包其余文件（`EMCallBack`、`EMValueCallBack`、`EMError` 等）diff 为空；`EMSmartHeartBeat`、`EMConversationFilter` 等仅内部调整；`EMPresenceManager`、`EMChatThreadManager`、`EMUserInfoManager`、`EMPushManager` 等无公开 API 签名变化 | Android 核对结论；含输入文件「其他核对的类型」表中 `error_codes_unchanged`、`presence_thread_userinfo_push_unchanged` 两行无变化确认 | 无变化确认，不进变更清单；presence/thread/userinfo/push 四领域双端均无签名变化（iOS 仅 push 同步方法删除 3 条，已 defer） |

### 3.3 配对中新发现的跨端语义不对齐

| 编号 | 现象 | 双端证据 | 建议 |
| --- | --- | --- | --- |
| N1 | 群成员合并列表接口双端引入版本不同：iOS `EMGroup#users` 4.24.1 已有（非新增），Android `EMGroup#getUsers()` 5.0.0 才新增 | i1 + group_get_users_new | Flutter 侧若已封装 `users` 则两端都不用动；否则按 defer 项决策，注意 iOS 无需等 5.0.0 |
| N2 | `isRead` 双端变化不对等：iOS 仅删 setter（同名变只读）；Android 是 `isUnread()` → `isRead()` 改名且**取值取反** | message_is_read 条目双端签名 | Flutter 平版时 Android 侧语义反转最易出错，Dart 模型层若曾映射 `isUnread` 需整体翻转 |
| N3 | iOS 大批量删除群组同步方法（36 条），Android 对应同步方法全部保留 | group 领域 defer 区 | 全部 defer；Flutter 只用异步封装，预计多数无需处理，待用户确认 |
| N4 | iOS 删除 push 同步方法 3 条，Android push 模块零变化 | push 领域 defer 区 | 全部 defer；Flutter 若只用 completion 版则无影响 |
| N6 | `getUnreadMessageCount`：iOS 为 5.0.0 新增 API，Android 4.24.1 已有仅行为变化 | chat_get_unread_message_count 条目 | 已 defer；行为变化双端一致（均不统计聊天室/免打扰会话） |
| N7 | contact 服务端拉取接口双端命名不对称：iOS `getAllContacts...`=EMContact 列表 / `getContacts...`=NSString 列表；Android 相反（`getAllContactsFromServer`=String 列表 / `asyncFetchAllContactsFromServer`=EMContact 列表） | contact 领域 3 条 include | 已按返回类型语义配对（模型列表/分页/字符串列表各一条），Flutter 侧按语义而非名字对齐 |
| N8 | `EMGroupConfigsType` 双端位值顺序不同 | iOS：AllowInvites/MaxUsers/InviteNeedConfirm/JoinApprovalRequired/IsPublic/Ext = 1/2/4/8/16/32；Android：IsPublic/JoinApprovalRequired/AllowInvites/MaxUsers/InviteNeedConfirm/Ext = 1/2/4/8/16/32 | include 保留语义配对；Flutter 契约固定采用 iOS 位值，Android wrapper 必须逐位映射，禁止直接透传 |
| N9 | `EMGroupConfigs` 双端默认值不同 | iOS `IsInviteNeedConfirm=YES`、`ext=@\"\"`；Android `inviteNeedConfirm=false`、`extField=null` | Flutter 固定 `inviteNeedConfirm=false`、`ext=null` 以延续既有 Dart 行为；双端 wrapper 显式赋值，不依赖 native 默认值，验收报告标 ⚠️ |
| N10 | `dataSyncType` 双端默认值不同 | iOS 默认 Conversations；Android 默认 NONE | Flutter 字段为可空；未传时不设置，保留 native 默认差异，并在 CHANGELOG/验收报告明确标 ⚠️ |
| N11 | `onDatabaseOpened` 回调负载不对齐 | iOS 含 `EMError *` 与 username；Android 仅 username | Flutter 公共回调统一暴露可空 error；Android 固定传 null，iOS 透传真实 error |

## 4. 统计

合并后总条数：**171**（双端配对共用一 id；Android 同能力有异步时仅保留异步签名；状态已回填）。

按类型分布：

| 类型 | 条数 |
| --- | --- |
| removed | 117 |
| new_api | 15 |
| renamed | 13 |
| param_changed | 12 |
| new_enum | 5 |
| new_listener | 4 |
| new_type | 3 |
| new_property | 2 |
| **合计** | **171** |

按决策分布：

| 决策 | 条数 | 说明 |
| --- | --- | --- |
| include | 69 | 双端都有，Flutter 侧执行对应新增/删除/改名/参数调整 |
| defer | 102 | 仅单端有（iOS-only 72 条、Android-only 30 条），默认不新增公开 API；编译强制项另记 |
| skip | 0 | 两份输入清单中均未出现 `useAgoraChatDomain` 相关项（KI-107 规则备而不用） |

按领域分布（include / defer）：

| 领域 | include | defer |
| --- | --- | --- |
| client | 22 | 15 |
| chat | 18 | 18 |
| conversation | 10 | 8 |
| message | 17 | 14 |
| group | 12 | 45 |
| contact | 5 | 8 |
| options | 5 | 4 |
| room | 2 | 5 |
| push | 0 | 3 |
| **合计** | **69** | **102** |

覆盖核对：iOS 输入 151 行条目 = 72 行 defer + 79 行并入 include；Android 输入 106 行证据 = 2 行无变化核对（转入未匹配清单 a10）+ 30 行 defer + 74 行并入 include。Android 同能力有异步方法时已剔除同步签名；无条目丢失。

## 5. 迁移文档交叉验证

以两份官方迁移指南为「预期」、git diff 清单为「实际」双向核对。核实命令均为只读：`git show <tag>:<path>` / `git grep <pat> <tag>`，仓库与 tag 见头部。

自动登录行为变化（不计入 171 条公开 API）：Android `EMClient#init` 已移除基于 `getAutoLogin()`/`isLoggedInBefore()` 的自动登录逻辑；Flutter 通过删除相关配置与状态 API、要求应用主动 token 登录完成迁移。\n\n### 5.1 文档有、diff 无（3 条)

| # | 文档说法 | 核实结果 | 结论 |
| --- | --- | --- | --- |
| 1 | iOS 文档「主要新增 API」列 `EMGroup#users` 为 5.0.0 新增 | `git grep` 证实 4.24.1 `EMGroup.h:212` 已有该属性，diff 未触及 | 文档误列新增；非 diff 遗漏。对应 Android 真新增 `getUsers()` 已 defer（group_get_users_new） |
| 2 | Android 文档两处称 `onReadAckForGroupMessageUpdated()` 改名为 `onReadReceiptForGroupMessageUpdated()` | `git grep onReadReceiptForGroupMessageUpdated SDK_5.0.0` 全树（含内部包）零命中；SDK 仓库自带 `doc/api_changes_5.0.md` 与 `doc/sdk-4.x-to-5.0-migration.md` 均写「已删除」 | 文档错误；旧回调是直接删除，以源码为准（详见 5.3 矛盾 1） |
| 3 | Android 文档称删除「全部 4 个 `asyncFetchConversationsFromServer(...)` 重载」 | `git grep` SDK_4.24.1 实测仅 3 个重载（无参 / pageNum+pageSize / limit+cursor） | 文档数量误差；diff 清单已按实际 3 个收录（chat_fetch_conversations_from_server） |

除上述外，两份迁移文档列出的所有删除/改名/新增在 diff 清单中均有对应条目。

### 5.2 diff 有、文档无（10 条，文档未覆盖的隐藏 breaking change）

iOS 侧（5 条）：

| # | 条目 | 说明 |
| --- | --- | --- |
| 1 | error_contact_add_faild_typo | `EMErrorContactAddFaild → EMErrorContactAddFailed` 拼写修正（值 1000 不变）；Flutter 若按字符串名映射错误码必须同步 |
| 2 | client_get_device_config | `getDeviceConfig:` 返回值 nullability 标注变化 |
| 3 | chat_load_messages_with_keyword_scope | `loadMessagesWithKeyword:...scope:completion:` nullability 收紧（选择器不变） |
| 4 | chat_delete_messages_before | `deleteMessagesBefore:completion:` completion 增加 nullability 标注 |
| 5 | file_message_body_init_with_local_path | `initWithLocalPath:displayName:` 两参数由 `_Nullable` 收紧为 `_Nonnull` |

Android 侧（5 条）：

| # | 条目 | 说明 |
| --- | --- | --- |
| 6 | client_get_device_info_new | `EMClient#getDeviceInfo()` 新增 public 方法，无 javadoc、文档未提及，疑似内部方法暴露（已 defer） |
| 7 | client_version_bump | `EMClient.VERSION` 由 `"4.24.1"` 变为 `"5.0.0"` |
| 8 | options_area_code_int_removed | `AreaCode` 旧 int 常量（`AREA_CODE_CN` 等 7 个）全删；文档只提 `setAreaCode(int)` → `setAreaCode(AreaCode)`，未提常量删除 |
| 9 | group_create_group 无 avatar 重载删除 | 文档只说旧 `EMGroupOptions` 重载删除，未明确 5.0.0 仅保留带 avatar 的 createGroup/asyncCreateGroup 形式（iOS 同样删除无 avatar 版） |
| 10 | conversation_search_msg_scope_sync_removed | `EMConversation#searchMsgFromDB(..., EMMessageSearchScope)` 同步重载删除；文档仅笼统提「部分旧版 searchMsgFromDB 调用方式」调整，未指明具体重载 |

### 5.3 已知矛盾（均已用 git 核实，结论以源码为准）

1. **Android `onReadReceiptForGroupMessageUpdated` 不存在**：迁移文档「接收消息已读回执」与「监听器回调变化汇总」两处称 `onReadAckForGroupMessageUpdated()` 仅改名。核实：`git grep onReadReceiptForGroupMessageUpdated SDK_5.0.0` 在整个 tag（含内部包）零命中；`onReadAckForGroupMessageUpdated` 仅残留在 proguard.map 与 SDK 自带 doc 中，且自带文档明确写「已删除；群消息已读状态更新统一经 `onMessageReadReceipts(List<EMMessageReadReceipt>)` 下发」。**以源码为准：旧回调直接删除，无新名；Flutter 侧不应平版该"新回调"**。
2. **iOS `EMGroup.users` 文档误列为新增**：`git grep` 证实 4.24.1 `newSDK/HyphenateSDK/GroupManager/EMGroup.h:212` 已有 `@property (nonatomic, strong, readonly) NSArray<NSString *> *users;`，4.24.1→5.0.0 diff 未触及。**以源码为准：非新增；Flutter 若已封装 `users` 无需改动**。
3. **iOS `sendMessageReadReceipts:completion:` 注释与签名不符**：`git show 5.0.0:.../IEMChatManager.h`（544 行附近）实测：中文注释描述 `@param aConversationId 会话 ID`、回调含 `aResult` 字典（key 为消息 ID），但实际签名仅 `(NSArray<EMChatMessage *> *)aMessages` + 单 `EMError` 回调。**以签名（源码）为准：无 `aConversationId` 参数、无逐消息 `aResult`；怀疑注释拷贝自内部设计稿，Flutter 封装回调只暴露整体 error**。

另记录一处文档小误差（不影响 diff 对应关系）：iOS 文档「已读回执体系重构」表写作 `EMConversation#markMessageAsReadWithId:completion:`，实际签名尾词为 `error:`（见 conversation_mark_message_as_read 条目）。

