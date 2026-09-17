# 5.0.0 平版 · 阶段一：公开 API Diff（Android）

## 1. Diff 锚点与范围

- 源仓库：`/Users/asterisk/Codes/zuoyu_native/emclient-android`
- diff 锚点：`SDK_4.24.1`（commit `300865ac9cb1813c113199f0b19a65be79c4731a`）→ `SDK_5.0.0`（commit `8025ecb767e72a5c4623fab457ed269011e773d6`）
- 中间 tag 核对：`git tag -l` 显示 `SDK_4.24.1` 与 `SDK_5.0.0` 之间**无任何中间 tag**（无 SDK_4.25.x 等），不存在跳版，直接两端 diff 即可。
- diff 范围：`hyphenatechatsdk/src/com/hyphenate/` 根包公开文件 + `chat/` 子包公开类；`chat/adapter/`、`chat/core/` 为内部实现，未 diff。`cloud/`、`notification/`、`push/`、`util/` 子包在 diff 中仅有 AndroidX import 替换（`android.support.*` → `androidx.*`），无公开 API 变化，未逐条收录。
- 5.0.0 tag 目录结构核对：**无新增公开子包**。`chat/` 下文件级变化：
  - 新增：`EMGroupConfigs.java`、`EMGroupReadReceipt.java`、`EMMessageReadReceipt.java`
  - 删除：`EMCheckType.java`、`EMGroupOptions.java`、`EMGroupReadAck.java`、`EMMessageStatistics.java`、`EMStatisticsManager.java`
- 参考迁移文档：`/Users/asterisk/Codes/zuoyu/easemob-doc/docs/document/android/migration_guide.md`（下称「迁移文档」，引用其章节名）。
- 提取规则：同一能力的同步+异步双方法只收录异步方法（无异步才收录同步）；签名逐字取自 diff / tag 源码。
- 全量统计：4.24.1 → 5.0.0 范围内 `1887 insertions, 4610 deletions`（61 个文件，含内部实现与 AndroidX 迁移）。

## 2. 变更清单

类型说明：new_api / deprecated（本次无新增废弃，4.x 的 @Deprecated 大多直接删除）/ removed / renamed / param_changed / new_type / new_property / new_enum / new_listener / removed_listener / removed_type。

### client（EMClient / 登录与设备）

| id | 类型 | Android 源签名 | 迁移文档依据 | 备注 |
|---|---|---|---|---|
| client_create_account_removed | removed | `public void createAccount(String username, String password) throws HyphenateException` | 密码登录下线 / 其他删除的 API | 无客户端替代，服务端 REST 注册 |
| client_login_password_removed | removed | `public void login(String id, String password, @NonNull final EMCallBack callback)` | 密码登录下线 | 仅保留 `loginWithToken(String, String, EMCallBack)`（签名不变） |
| client_login_with_agora_token_removed | removed | `public void loginWithAgoraToken(String username, String agoraToken, @NonNull final EMCallBack callback)` | 密码登录下线 | 4.x 已废弃，删除；用 `loginWithToken` |
| client_renew_token_no_callback_removed | removed | `public void renewToken(String newAgoraToken)` | 密码登录下线 | 保留 `renewToken(String newToken, @NonNull EMCallBack callback)` |
| client_get_user_token_from_server_removed | removed | `public void getUserTokenFromServer(final String username, final String password, final EMValueCallBack<String> callBack)` | 密码登录下线 | Token 由 App Server 下发 |
| client_is_logged_in_before_removed | removed | `public boolean isLoggedInBefore()` | 自动登录移除 | 替代：`isLoggedIn()` / `isConnected()` / `isDatabaseOpened()` |
| client_statistics_manager_removed | removed | `public EMStatisticsManager statisticsManager()` | 其他删除的 API | 连同 `EMStatisticsManager`、`EMMessageStatistics` 两个类整体删除 |
| client_get_logged_in_devices_pwd_removed | removed | `public List<EMDeviceInfo> getLoggedInDevicesFromServer(String username, String password) throws HyphenateException` | 设备管理与鉴权 | 密码版，无直接替代 |
| client_get_logged_in_devices_token_sync_removed | removed | `public List<EMDeviceInfo> getLoggedInDevicesFromServerWithToken(@NonNull String username, @NonNull String token) throws HyphenateException` | 设备管理与鉴权 | 同步版删除，改为异步（见下条） |
| client_fetch_logged_in_devices_with_token_new | new_api | `public void fetchLoggedInDevicesFromServerWithToken(@NonNull String username, @NonNull String token, EMValueCallBack<List<EMDeviceInfo>> callBack)` | 设备管理与鉴权 | 替代被删的同步版 |
| client_kick_device_pwd_removed | removed | `public void kickDevice(String username, String password, String resource) throws HyphenateException` | 设备管理与鉴权 | `kickDeviceWithToken(String, String, String)` 保留（签名不变） |
| client_kick_all_devices_pwd_removed | removed | `public void kickAllDevices(String username, String password) throws HyphenateException` | 设备管理与鉴权 | `kickAllDevicesWithToken(String, String)` 保留（签名不变） |
| client_check_removed | removed | `public void check(String username, String password, final CheckResultListener listener)` + `public interface CheckResultListener { void onResult(@EMCheckType.CheckType int type, int result, String desc); }` | 密码登录下线 | 连同 `EMCheckType` 类删除 |
| client_is_database_opened_new | new_api | `public boolean isDatabaseOpened()` | 登录与数据库打开解耦 | 4.24.1 中为包私有，5.0.0 提升为 public |
| client_get_device_info_new | new_api | `public JSONObject getDeviceInfo()` | （无） | 疑似内部辅助方法暴露为 public，见疑点清单 |
| client_version_bump | param_changed | `public final static String VERSION = "4.24.1"` → `"5.0.0"` | — | 既有 public 常量值变化 |

### options（EMOptions）

| id | 类型 | Android 源签名 | 迁移文档依据 | 备注 |
|---|---|---|---|---|
| options_auto_login_removed | removed | `public void setAutoLogin(boolean autoLogin)` / `public boolean getAutoLogin()` | 自动登录移除 | 无直接替代 |
| options_require_ack_removed | removed | `public void setRequireAck(boolean requireAck)` / `public boolean getRequireAck()` | 已读回执体系重构 | 改用 `EMMessage#setIsNeedReadReceipt(true)` 按消息设置 |
| options_report_server_removed | removed | `public String getReportServer()` / `public void setReportServer(String reportServer)` | 其他删除的 API | 私有化部署由服务端处理 |
| options_auto_sync_contacts_removed | removed | `public void setEnableAutoSyncContacts(boolean enable)` / `public boolean isEnableAutoSyncContacts()` | 服务端拉取 API 迁移 | 并入 `setDataSyncType` 的 `CONTACTS` 位 |
| options_area_code_int_removed | removed | `public static class AreaCode`（int 常量容器）+ `public static final int AREA_CODE_CN = 1;` 等 7 个常量 + `public void setAreaCode(int code)` | 有替代方式的 API | `getAreaCode()` 仍返回 `int`，签名不变 |
| options_area_code_enum_new | new_enum | `public enum AreaCode { CN(1), NA(2), EU(4), AS(8), JP(16), IN(32), GLOB(-1); public int getValue(); }` | 有替代方式的 API | 配合 `setAreaCode(AreaCode code)` |
| options_set_area_code_param_changed | param_changed | 旧：`public void setAreaCode(int code)` → 新：`public void setAreaCode(AreaCode code)` | 有替代方式的 API | |
| options_data_sync_type_enum_new | new_enum | `public enum EMDataSyncType { NONE(0), CONVERSATIONS(1 << 0), CONTACTS(1 << 1), JOINED_GROUPS(1 << 2); public int getValue(); public static int toNativeMask(EnumSet<EMDataSyncType> types); public static EnumSet<EMDataSyncType> fromNativeMask(int mask); }` | 数据同步 API | 位掩码枚举，可组合 |
| options_data_sync_type_api_new | new_api | `public void setDataSyncType(EnumSet<EMDataSyncType> types)` / `public EnumSet<EMDataSyncType> getDataSyncType()` | 数据同步 API | 须在 `EMClient#init` 前配置，默认 `NONE` |

### connection（EMConnectionListener，根包）

| id | 类型 | Android 源签名 | 迁移文档依据 | 备注 |
|---|---|---|---|---|
| connection_on_logout_int_removed | removed_listener | `default void onLogout(final int errorCode){}` | 监听器回调变化汇总 | 4.x 已废弃 |
| connection_on_logout_int_string_removed | removed_listener | `default void onLogout(final int errorCode,String info)` | 监听器回调变化汇总 | 4.x 已废弃；保留 `onLogout(final int errorCode, EMLoginExtensionInfo info)`（4.24.1 已存在，5.0.0 方法体不再代理旧回调） |
| connection_on_database_opened_new | new_listener | `default void onDatabaseOpened(String username) {}` | 登录与数据库打开解耦 | 本地库就绪即可读本地数据 |
| connection_on_data_sync_start_new | new_listener | `default void onDataSyncStart(EMOptions.EMDataSyncType type){}` | 数据同步 API | |
| connection_on_data_sync_finish_new | new_listener | `default void onDataSyncFinish(EMOptions.EMDataSyncType type, int errorCode){}` | 数据同步 API | `errorCode` 为 `EMError#EM_NO_ERROR` 表示成功 |

### contact（EMContactManager / EMContactListener）

| id | 类型 | Android 源签名 | 迁移文档依据 | 备注 |
|---|---|---|---|---|
| contact_async_get_all_from_server_removed | removed | `public void asyncGetAllContactsFromServer(final EMValueCallBack<List<String>> callback)` | 服务端拉取 API 迁移 | |
| contact_async_fetch_all_from_server_removed | removed | `public void asyncFetchAllContactsFromServer(EMValueCallBack<List<EMContact>> callback)` | 服务端拉取 API 迁移 | |
| contact_async_fetch_all_from_server_paged_removed | removed | `public void asyncFetchAllContactsFromServer(int limit, String cursor, EMValueCallBack<EMCursorResult<EMContact>> callback)` | 服务端拉取 API 迁移 | 分页重载一并删除 |
| contact_on_contact_sync_start_removed | removed_listener | `default void onContactSyncStart() {}`（EMContactListener） | 服务端拉取 API 迁移 | 改用 `EMConnectionListener#onDataSyncStart(CONTACTS)` |
| contact_on_contact_sync_finish_removed | removed_listener | `default void onContactSyncFinishWithError(int errorCode, String error) {}`（EMContactListener） | 服务端拉取 API 迁移 | 改用 `onDataSyncFinish(CONTACTS, int)` |

注：本地读取接口 `getContactsFromLocal()` / `fetchContactFromLocal(String)` / `asyncFetchAllContactsFromLocal(...)` 在 4.24.1 已存在且签名不变。

### chat（EMChatManager / EMConversation / 已读回执体系）

| id | 类型 | Android 源签名 | 迁移文档依据 | 备注 |
|---|---|---|---|---|
| chat_ack_message_read_removed | removed | `public void ackMessageRead(String to, String messageId) throws HyphenateException` | 发送消息已读回执与清除未读数 | 由 `asyncSendMessageReadReceipts` 替代 |
| chat_ack_group_message_read_removed | removed | `public void ackGroupMessageRead(String to, String messageId, String ext) throws HyphenateException` | 发送消息已读回执与清除未读数 | 群聊不再单独逐条回执，不再支持 ext 自定义内容 |
| chat_ack_conversation_read_removed | removed | `public void ackConversationRead(String conversationId) throws HyphenateException` | 发送消息已读回执与清除未读数 | 由 `asyncClearConversationUnreadMessageCount` 替代 |
| chat_mark_all_conversations_as_read_removed | removed | `public boolean markAllConversationsAsRead()` | 发送消息已读回执与清除未读数 | 由 `asyncClearAllConversationUnreadMessageCount` 替代 |
| chat_async_send_message_read_receipts_new | new_api | `public void asyncSendMessageReadReceipts(final List<EMMessage> messages, final EMCallBack callBack)` | 发送消息已读回执与清除未读数 | 批量回执；每次最多 50 条同一会话消息，仅处理 `isNeedReadReceipt()==true` 且未回执的消息 |
| chat_async_clear_conversation_unread_new | new_api | `public void asyncClearConversationUnreadMessageCount(final String conversationId, final EMCallBack callBack)` | 发送消息已读回执与清除未读数 | 仅清本地未读数并同步多设备，不发已读回执 |
| chat_async_clear_all_unread_new | new_api | `public void asyncClearAllConversationUnreadMessageCount(final EMCallBack callBack)` | 发送消息已读回执与清除未读数 | |
| chat_fetch_conversations_from_server_removed | removed | 3 个异步重载：`asyncFetchConversationsFromServer(EMValueCallBack<Map<String, EMConversation>>)`、`asyncFetchConversationsFromServer(int pageNum, int pageSize, EMValueCallBack<Map<String, EMConversation>>)`、`asyncFetchConversationsFromServer(int limit, String cursor, EMValueCallBack<EMCursorResult<EMConversation>>)` | 服务端拉取 API 迁移 | 改 `getAllConversations()`（本地）+ `onDataSyncFinish(CONVERSATIONS)`；迁移文档称 4 个，实际 3 个 |
| chat_async_fetch_pinned_conversations_removed | removed | `public void asyncFetchPinnedConversationsFromServer(final int limit, final String cursor, final EMValueCallBack<EMCursorResult<EMConversation>> callback)` | 服务端拉取 API 迁移 | 置顶随会话同步落地 |
| chat_async_get_conversations_with_cursor_removed | removed | `public void asyncGetConversationsFromServerWithCursor(@NonNull String cursor, @NonNull EMConversationFilter filter, EMValueCallBack<EMCursorResult<EMConversation>> callback)` | 服务端拉取 API 迁移 | 本地查询替代 |
| chat_load_all_conversations_removed | removed | `public boolean loadAllConversations()` | 服务端拉取 API 迁移 | 降为包私有；直接 `getAllConversations()` |
| chat_update_participant_removed | removed | `public boolean updateParticipant(String from, String changeTo)` | 其他删除的 API | 无替代 |
| chat_report_message_removed | removed | `public void asyncReportMessage(String msgId, String tag, String reportReason, EMCallBack callback)` | 其他删除的 API | 举报提交至业务服务器 |
| chat_fetch_group_read_acks_removed | removed | `public void asyncFetchGroupReadAcks(final String msgId, final int pageSize, final String startAckId, final EMValueCallBack<EMCursorResult<EMGroupReadAck>> callBack)` | 回执详情查询 | 由 `asyncFetchGroupMessageReadReceipts` 替代 |
| chat_async_fetch_group_message_read_receipts_new | new_api | `public void asyncFetchGroupMessageReadReceipts(final String msgId, final int pageSize, final String startAckId, final EMValueCallBack<EMCursorResult<EMGroupReadReceipt>> callBack)` | 回执详情查询 | pageSize 1-50 |
| chat_async_get_group_message_read_receipts_new | new_api | `public void asyncGetGroupMessageReadReceipts(final List<EMMessage> messages, final EMValueCallBack<List<EMMessageReadReceipt>> callBack)` | 回执详情查询 | 批量取群消息回执汇总，每次最多 20 条同一会话消息 |
| chat_async_modify_message_param_changed | param_changed | 旧：`public void asyncModifyMessage(String messageId, EMMessageBody messageBodyModified, final EMValueCallBack<EMMessage> callBack)` → 新：`public void asyncModifyMessage(String messageId, @Nullable EMMessageBody messageBodyModified, @Nullable Map<String, Object> ext, final EMValueCallBack<EMMessage> callBack)` | 有替代方式的 API | 新增 `ext` 参数；旧三参数重载删除 |
| chat_fetch_history_messages_removed | removed | `public void asyncFetchHistoryMessage(final String conversationId, final EMConversationType type, final int pageSize, final String startMsgId, ...)` 两个异步重载 | 有替代方式的 API | 4.x 均已 @Deprecated |
| chat_async_fetch_history_messages_new | new_api | `public void asyncFetchHistoryMessages(String conversationId, EMConversationType type, int pageSize, String cursor, EMFetchMessageOption option, final EMValueCallBack<EMCursorResult<EMMessage>> callBack)` | 有替代方式的 API | 统一异步分页接口（方法名由 `asyncFetchHistoryMessage` 变 `asyncFetchHistoryMessages`） |
| chat_async_delete_conversations_new | new_api | `public void asyncDeleteConversations(List<String> conversationIds, boolean deleteMessages, EMCallBack callBack)` | 主要新增 API | 批量删除本地会话 |
| conversation_mark_message_as_read_removed | removed | `public void markMessageAsRead(String messageId)` / `public void markAllMessagesAsRead()`（EMConversation） | 发送消息已读回执与清除未读数 | `EMConversation` 不再提供修改已读状态接口 |
| conversation_get_message_param_changed | param_changed | 旧：`public EMMessage getMessage(String messageId, boolean markAsRead)` → 新：`public EMMessage getMessage(String messageId)`（EMConversation） | 行为变化 4 | 查询不再自动标记已读；旧重载删除 |
| conversation_search_msg_scope_sync_removed | removed | `public List<EMMessage> searchMsgFromDB(String keywords, long timeStamp, int maxCount, String from, EMSearchDirection direction, EMMessageSearchScope searchScope)`（EMConversation，同步） | 有替代方式的 API | 异步 `asyncSearchMsgFromDB(..., List<String> senders, ..., EMMessageSearchScope, EMValueCallBack)` 保留；迁移文档明确「未统一移除所有同步搜索接口」 |
| conversation_get_conversation_name_new | new_api | `public String getConversationName()` / `public String getConversationAvatar()`（EMConversation） | 主要新增 API | 数据未同步时可能返回空字符串 |
| conversation_listener_on_conversation_read_removed | removed_listener | `void onConversationRead(String from, String to)`（EMConversationListener） | 监听器回调变化汇总 | 5.0.0 中该接口仅剩 `void onConversationUpdate()` |
| msg_listener_on_message_read_removed | removed_listener | `default void onMessageRead(List<EMMessage> messages) {}`（EMMessageListener） | 接收消息已读回执 | |
| msg_listener_on_group_message_read_removed | removed_listener | `default void onGroupMessageRead(List<EMGroupReadAck> groupReadAcks) {}`（EMMessageListener） | 接收消息已读回执 | |
| msg_listener_on_read_ack_updated_removed | removed_listener | `default void onReadAckForGroupMessageUpdated() {}`（EMMessageListener） | 监听器回调变化汇总 | 迁移文档称改名为 `onReadReceiptForGroupMessageUpdated()`，**但 5.0.0 源码中不存在该方法**，见疑点清单 |
| msg_listener_on_message_recalled_removed | removed_listener | `default void onMessageRecalled(List<EMMessage> messages){}`（EMMessageListener） | 监听器回调变化汇总 | 4.x 已废弃；保留 `onMessageRecalledWithExt(List<EMRecallMessageInfo>)` |
| msg_listener_on_message_read_receipts_new | new_listener | `default void onMessageReadReceipts(List<EMMessageReadReceipt> receipts) {}`（EMMessageListener） | 接收消息已读回执 | 单聊群聊统一回执回调 |

### message（EMMessage）

| id | 类型 | Android 源签名 | 迁移文档依据 | 备注 |
|---|---|---|---|---|
| message_is_acked_renamed | renamed | 旧：`public boolean isAcked()` / `public void setAcked(boolean isAcked)` → 新：`public boolean isPeerRead()`（+ 包私有 `void setPeerRead(boolean)`） | EMMessage 已读相关方法重命名 | setter 降为包私有，仅供 SDK 内部 |
| message_is_unread_renamed | renamed | 旧：`public boolean isUnread()` / `public void setUnread(boolean unread)` → 新：`public boolean isRead()`（+ 包私有 `void setRead(boolean)`） | EMMessage 已读相关方法重命名 | 语义由「未读」反转为「已读」，**取值取反**，迁移时最易出错 |
| message_need_group_ack_renamed | renamed | 旧：`public boolean isNeedGroupAck()` / `public void setIsNeedGroupAck(boolean need)` → 新：`public boolean isNeedReadReceipt()` / `public void setIsNeedReadReceipt(boolean need)` | EMMessage 已读相关方法重命名 | 单聊群聊均适用 |
| message_group_ack_count_renamed | renamed | 旧：`public int groupAckCount()` / `public void setGroupAckCount(int count)` → 新：`public int readReceiptCount()`（+ 包私有 `void setReadReceiptCount(int)`） | EMMessage 已读相关方法重命名 | |
| message_create_txt_send_message_removed | removed | `public static EMMessage createTxtSendMessage(String content, String username)` | 有替代方式的 API | 用 `createTextSendMessage(String content, String username)`（4.x 已存在） |
| message_get_user_name_removed | removed | `public String getUserName()` | 有替代方式的 API | 用 `getFrom()` |
| message_get_recaller_removed | removed | `public String getRecaller()` | 有替代方式的 API | 用 `EMRecallMessageInfo#getRecallBy()`（经 `onMessageRecalledWithExt`） |

### group（EMGroupManager / EMGroup / 新类型）

| id | 类型 | Android 源签名 | 迁移文档依据 | 备注 |
|---|---|---|---|---|
| group_style_enum_removed | removed_type | `public enum EMGroupStyle { EMGroupStylePrivateOnlyOwnerInvite, EMGroupStylePrivateMemberCanInvite, EMGroupStylePublicJoinNeedApproval, EMGroupStylePublicOpenJoin }`（EMGroupManager 内部枚举） | 群组配置模型重构 | 拆为 EMGroupConfigs 三个布尔字段，对照关系见迁移文档 |
| group_options_class_removed | removed_type | `public class EMGroupOptions { public int maxUsers = 200; public EMGroupManager.EMGroupStyle style; public boolean inviteNeedConfirm = false; public String extField; }` | EMGroupOptions 与 EMGroupConfigs 对照 | |
| group_configs_class_new | new_type | `public class EMGroupConfigs { public int maxUsers = 200; public boolean isPublic = false; public boolean joinApprovalRequired = false; public boolean allowInvites = false; public boolean inviteNeedConfirm = false; public String extField; }` | 群组配置模型重构 | 纯字段袋，无方法 |
| group_configs_type_enum_new | new_enum | `public enum EMGroupConfigsType { IS_PUBLIC(1 << 0), JOIN_APPROVAL_REQUIRED(1 << 1), ALLOW_INVITES(1 << 2), MAX_USERS(1 << 3), INVITE_NEED_CONFIRM(1 << 4), EXT(1 << 5); }`（EMGroupManager 内部枚举，含 `getValue()` / `static int toNativeMask(EnumSet)`） | 相关 API 变化 | 位掩码，用于 `updateGroupConfigs` 指定更新项 |
| group_create_group_without_avatar_removed | removed | `public void asyncCreateGroup(final String groupName, final String desc, final String[] allMembers, final String reason, final EMGroupOptions option, final EMValueCallBack<EMGroup> callback)` | 相关 API 变化 | 无 avatar 异步重载删除 |
| group_create_group_with_avatar_param_changed | param_changed | 旧：`public void asyncCreateGroup(final String groupName, final String avatar, final String desc, final String[] allMembers, final String reason, final EMGroupOptions option, final EMValueCallBack<EMGroup> callback)` → 新：`public void asyncCreateGroup(final String groupName, final String avatar, final String desc, final String[] allMembers, final String reason, final EMGroupConfigs configs, final EMValueCallBack<EMGroup> callback)` | 相关 API 变化 | 5.0.0 仅保留带 avatar 形式 |
| group_update_group_configs_new | new_api | `public void asyncUpdateGroupConfigs(final String groupId, final EnumSet<EMGroupConfigsType> types, final EMGroupConfigs configs, final EMValueCallBack<EMGroup> callback)` | 相关 API 变化 | 建群后按配置类型更新群属性 |
| group_load_all_groups_removed | removed | `public synchronized boolean loadAllGroups()` | 服务端拉取 API 迁移 | 降为包私有；直接 `getAllGroups()` |
| group_get_from_server_fetch_members_removed | param_changed | 旧：`public EMGroup getGroupFromServer(String groupId, boolean fetchMembers) throws HyphenateException` 删除，保留 `public EMGroup getGroupFromServer(String groupId)` | 有替代方式的 API | 成员走独立分页接口 |
| group_get_joined_groups_from_server_removed | removed | `public void asyncGetJoinedGroupsFromServer(final EMValueCallBack<List<EMGroup>> callback)` / `public void asyncGetJoinedGroupsFromServer(final int pageIndex, final int pageSize, boolean needMemberCount, boolean needRole, final EMValueCallBack<List<EMGroup>> callback)` | 服务端拉取 API 迁移 | 改 `getAllGroups()`（本地）+ `onDataSyncFinish(JOINED_GROUPS)` |
| group_get_public_groups_from_server_removed | removed | `public void asyncGetPublicGroupsFromServer(final int pageSize, final String cursor, final EMValueCallBack<EMCursorResult<EMGroupInfo>> callback)` | 其他删除的 API | 群组目录由业务服务维护 |
| group_async_upload_shared_file_overload_removed | removed | `public void asyncUploadGroupSharedFile(final String groupId, final String filePath, final EMCallBack callBack)` | 其他删除的 API | 保留 `asyncUploadGroupSharedFile(String, String, EMValueCallBack<EMMucSharedFile>)` 重载 |
| group_is_member_only_renamed | renamed | 旧：`public boolean isMemberOnly()` → 新：`public boolean isJoinApprovalRequired()`（EMGroup） | 相关 API 变化 | 仅表示公开群是否需审批入群；`isPublic()`、`isMemberAllowToInvite()` 签名不变 |
| group_get_users_new | new_api | `public List<String> getUsers()`（EMGroup） | 主要新增 API | 群主+管理员+成员合并列表，可能含重复 ID |
| group_read_ack_class_removed | removed_type | `public class EMGroupReadAck { getAckId(); getMsgId(); String getFrom(); String getContent(); getCount(); getTimestamp(); }` | 回执详情查询 | 由 EMGroupReadReceipt 替换；`getContent()` 不再下发；`getFrom()` 返回类型由 `String` 变 `EMGroupMemberInfo` |
| group_read_receipt_class_new | new_type | `public class EMGroupReadReceipt extends EMBase<EMAGroupReadReceipt> { public String getAckId(); public String getMsgId(); public EMGroupMemberInfo getFrom(); public int getCount(); public long getTimestamp(); }` | 回执详情查询 | |
| message_read_receipt_class_new | new_type | `public class EMMessageReadReceipt extends EMBase<EMAMessageReadReceipt> { public String getMessageId(); public String getConversationId(); public boolean isPeerReceipt(); public int getReadCount(); }` | 接收消息已读回执 | 统一单聊/群聊回执模型 |
| group_listener_on_member_joined_removed | removed_listener | `void onMemberJoined(final String groupId, final String member)`（EMGroupChangeListener，4.x 已废弃） | 监听器回调变化汇总 | 保留 `default void onMembersJoined(String groupId, List<String> members)`（4.24.1 已存在） |
| group_listener_on_member_exited_removed | removed_listener | `void onMemberExited(final String groupId, final String member)`（EMGroupChangeListener，4.x 已废弃） | 监听器回调变化汇总 | 保留 `default void onMembersExited(String groupId, List<String> members)` |
| group_listener_on_request_declined_4arg_removed | removed_listener | `void onRequestToJoinDeclined(String groupId, String groupName, String decliner, String reason)`（EMGroupChangeListener，4.x 已废弃） | 监听器回调变化汇总 | 保留 5 参版 `onRequestToJoinDeclined(String, String, String, String, String applicant)`（4.24.1 已存在） |

### room（EMChatRoomManager / EMChatRoomChangeListener）

| id | 类型 | Android 源签名 | 迁移文档依据 | 备注 |
|---|---|---|---|---|
| room_create_chat_room_removed | removed | `public void asyncCreateChatRoom(final String subject, final String description, final String welcomeMessage, final int maxUserCount, final List<String> members, final EMValueCallBack<EMChatRoom> callBack)` | 其他删除的 API | 服务端 REST 创建 |
| room_destroy_chat_room_removed | removed | `public void asyncDestroyChatRoom(final String chatRoomId, final EMCallBack callBack)` | 其他删除的 API | 服务端 REST 解散 |
| room_get_all_chat_rooms_removed | removed | `public List<EMChatRoom> getAllChatRooms()` | 其他删除的 API | 按需 `fetchChatRoomFromServer` |
| room_fetch_from_server_fetch_members_removed | param_changed | 旧：`public EMChatRoom fetchChatRoomFromServer(String roomId, boolean fetchMembers) throws HyphenateException` 删除，保留 `public EMChatRoom fetchChatRoomFromServer(String roomId)` | 有替代方式的 API | 成员走独立接口 |
| room_remove_chat_room_listener_removed | renamed | 旧：`public void removeChatRoomListener(EMChatRoomChangeListener listener)` → 新：`public void removeChatRoomChangeListener(EMChatRoomChangeListener listener)` | 有替代方式的 API | 与 `addChatRoomChangeListener` 配套（4.24.1 中两者并存，5.0.0 删旧名） |
| room_listener_on_member_joined_2arg_removed | removed_listener | `default void onMemberJoined(final String roomId, final String participant){}`（EMChatRoomChangeListener，4.x 已废弃） | 监听器回调变化汇总 | 保留 3 参版 `onMemberJoined(String roomId, String participant, String ext)` |
| room_listener_on_mute_list_added_removed | removed_listener | `void onMuteListAdded(final String chatRoomId, final List<String> mutes, final long expireTime)`（EMChatRoomChangeListener，4.x 已废弃） | 监听器回调变化汇总 | 保留 `default void onMuteListAdded(String chatRoomId, Map<String, Long> muteInfo)` |

### multidevice（EMMultiDeviceListener，根包）

| id | 类型 | Android 源签名 | 迁移文档依据 | 备注 |
|---|---|---|---|---|
| multidevice_conversation_unread_cleared_new | new_enum | `int CONVERSATION_UNREAD_MESSAGECOUNT_CLEARED = 65;` | 多设备事件 | 经 `onConversationEvent` 下发，收到后需重新 `getAllConversations()` |
| multidevice_all_conversation_unread_cleared_new | new_enum | `int ALL_CONVERSATION_UNREAD_MESSAGECOUNT_CLEARED = 66;` | 多设备事件 | 同上 |

### statistics（整体移除）

| id | 类型 | Android 源签名 | 迁移文档依据 | 备注 |
|---|---|---|---|---|
| statistics_manager_class_removed | removed_type | `public class EMStatisticsManager extends EMBase<EMAStatisticsManager>`（含 `getMessageStatistics(String)`、`getMessageCount(long, long, EMSearchMessageDirect, EMSearchMessageType)`、`getMessageSize(long, long, EMSearchMessageDirect, EMSearchMessageType)` 及内部枚举 `EMSearchMessageDirect`、`EMSearchMessageType`） | 其他删除的 API | 入口 `EMClient#statisticsManager()` 一并删除 |
| message_statistics_class_removed | removed_type | `public class EMMessageStatistics extends EMBase<EMAMessageStatistics>`（含 `getMsgId()`、`getTo()`、`getFrom()`、`getType()`、`getChatType()`、`getMsgTime()`、`direct()`、`getMsgSize()`、`getAttachmentSize()`、`getThumbnailSize()`） | 其他删除的 API | |

### 其他核对的类型

| id | 类型 | 结论 | 备注 |
|---|---|---|---|
| check_type_class_removed | removed_type | `public class EMCheckType`（常量 `ACCOUNT_VALIDATION=0`、`GET_DNS_LIST_FROM_SERVER=1`、`GET_TOKEN_FROM_SERVER=2`、`DO_LOGIN=3`、`DO_MSG_SEND=4`、`DO_LOGOUT=5` + `@interface CheckType`）随 `EMClient#check` 删除 | 迁移文档「密码登录下线」表 |
| error_codes_unchanged | — | `EMError.java` 在 diff 中**零变化**，无新增/删除错误码 | 迁移文档亦未提及错误码变更 |
| presence_thread_userinfo_push_unchanged | — | `EMPresenceManager`、`EMChatThreadManager`、`EMUserInfoManager`、`EMPushManager`、`EMPushConfigs`、`EMPresenceListener`、`EMChatThreadChangeListener` 无公开 API 签名变化（EMPushManager 仅内部推送 Token 上传判断逻辑变化） | 与迁移文档「行为变化 7」对应 |

## 3. 未匹配 / 疑点清单（宁多勿漏）

1. **`onReadReceiptForGroupMessageUpdated` 不存在**：迁移文档「接收消息已读回执」「监听器回调变化汇总」两处称 `onReadAckForGroupMessageUpdated()` 改名为 `onReadReceiptForGroupMessageUpdated()`，但 `git grep` 在 SDK_5.0.0 全树（含内部包）中均无该方法——旧回调是直接删除，群消息回执状态更新实际由 `onMessageReadReceipts` 承载。Flutter 侧不应平版这个"新回调"。
2. **asyncFetchConversationsFromServer 重载数量不符**：迁移文档称删除「全部 4 个 asyncFetchConversationsFromServer(...) 重载」，SDK_4.24.1 源码中实际只有 3 个（无参 / pageNum+pageSize / limit+cursor）。若算上 `asyncFetchPinnedConversationsFromServer` 与 `asyncGetConversationsFromServerWithCursor` 则为 5 个相关接口。以源码为准：按异步提取规则共删除 5 个服务端会话拉取相关方法。
3. **`EMClient#getDeviceInfo()` 疑似内部 API 暴露**：5.0.0 新增 `public JSONObject getDeviceInfo()`，组装 hid/os/os-version 供内部 `setPresence` 使用，无 javadoc、迁移文档未提及。建议 Flutter 侧不平版，待确认。
4. **`EMGroupConfigsType.toNativeMask(EnumSet)` / `EMDataSyncType.toNativeMask` 和 `fromNativeMask` 为 public static**：是跨 JNI 层的掩码转换工具，语义属内部但修饰符为 public。Flutter 侧无需平版。
5. **迁移文档未提及的删除：`EMConversation#searchMsgFromDB(..., EMMessageSearchScope)` 同步重载**（异步版保留）。文档仅笼统说「部分旧版 searchMsgFromDB 调用方式」调整，未指明是哪个重载，此处给出精确签名。
6. **迁移文档未提及的新增 public API：`EMGroupManager#createGroup` 无 avatar 重载删除**。文档只说旧 `EMGroupOptions` 重载删除，未明确 5.0.0 只保留带 `avatar` 参数的 createGroup/asyncCreateGroup 形式（4.24.1 有带/不带 avatar 各一对）。
7. **行为变化（无签名变化，Flutter 侧需注意）**：
   - `EMChatManager#getUnreadMessageCount` 统计范围收窄：不含聊天室、不含 Thread、仅统计 `EMPushRemindType.ALL` 的单聊群聊会话（迁移文档「行为变化 1」）。
   - `EMConversation#getMessage(String)` 不再自动标记已读（行为变化 4）。
   - `EMClient#init` 自动登录逻辑与 `EMChatService` 旧保活逻辑移除（行为变化，不计入公开 API 表）；`EMPushManager` Token 上传判断不再依赖 `isLoggedInBefore()`/`getAutoLogin()`。
   - 前后台检测改用 AndroidX `ProcessLifecycleOwner`（行为变化 5），SDK 全面迁移 AndroidX——对 Flutter 封装层无 API 影响，但影响 example 工程依赖。
8. **EMOptions 中 `AreaCode` 旧 int 常量全删**：`AREA_CODE_CN` 等 7 个 `public static final int` 一并删除，迁移文档只提了 `setAreaCode(int)` → `setAreaCode(AreaCode)`。若 Flutter 侧把 areaCode 作为 number 透传，需要改为枚举值映射。
9. **`EMLoginExtensionInfo` 未变化**：`onLogout(int, EMLoginExtensionInfo)` 在 4.24.1 已是 default 方法（内部代理到旧回调），5.0.0 仅去掉代理；该类本身 diff 无变化。
10. **根包其余文件**：`EMCallBack`、`EMValueCallBack`、`EMResultCallBack`、`EMLogListener` diff 为空；`EMError` diff 为空（无错误码变更）。`EMSmartHeartBeat`、`EMConversationFilter`、`EMCursorResult`、`EMDeviceInfo`、`EMFetchMessageOption`、`EMGroupInfo`、`EMSessionManager` 仅有内部实现/判空/AndroidX import 调整，无公开 API 变化。

## 4. 统计

| 类型 | 条数 |
|---|---|
| new_api | 14 |
| new_type | 3 |
| new_enum | 5 |
| new_listener | 4 |
| new_property | 0 |
| removed（方法） | 45 |
| removed_type | 6（EMGroupStyle、EMGroupOptions、EMGroupReadAck、EMCheckType、EMStatisticsManager、EMMessageStatistics） |
| removed_listener | 14 |
| renamed | 6（isAcked→isPeerRead、isUnread→isRead、isNeedGroupAck→isNeedReadReceipt、groupAckCount→readReceiptCount、isMemberOnly→isJoinApprovalRequired、removeChatRoomListener→removeChatRoomChangeListener） |
| param_changed | 7 |
| **变更合计** | **104** |

未匹配/疑点清单：**10 条**。另有 2 行无变化核对，因此表格证据总计 106 行。

> 说明：统计按本文件变更表的实际数据行计算；同一能力有同步与异步方法时仅保留异步签名，无异步方法时才保留同步签名。


