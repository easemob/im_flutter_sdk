# 阶段一：公开 API Diff（4.22.1 → 4.24.1）

- iOS 源：`/Users/asterisk/Codes/zuoyu_native/emclient-ios`，tag `4.22.1 → 4.23.0 → 4.24.0 → 4.24.1`
- Android 源：`/Users/asterisk/Codes/zuoyu_native/emclient-android`，tag `SDK_4.22.1 → SDK_4.23.0 → SDK_4.24.0 → SDK_4.24.1`
- 目标：im_flutter_sdk，Flutter 版本 4.24.0（基线 native 4.22.1）
- diff 范围：iOS `newSDK/HyphenateSDK/` 公开头文件（排除 `*+Internal.h`）；Android `hyphenatechatsdk/src/com/hyphenate/` 公开类（根包 + `chat/`，排除 `adapter/`、`core/`）
- 版本区间核对：双端 `git tag` 列表均为 4.22.1 / 4.23.0 / 4.24.0 / 4.24.1，三个小版本增量逐一覆盖，无跳版。

## 合并变更清单

决策说明：include = 本次平版实施；skip = 无需实施（理由附后）；defer = 推迟。

### 4.22.1 → 4.23.0

| id | 类型 | 领域 | iOS 源签名 | Android 源签名 | 决策 | 状态 |
|---|---|---|---|---|---|---|
| `chat_webhook_env` | new_property | chat | `EMChatMessage.h`：`@property (nonatomic, copy) NSString * _Nullable webhookEnv;`（nil=默认回调路由；`@""`=按未匹配处理） | `EMMessage.java`：`setWebhookEnv(String)` / `getWebhookEnv()`（仅同步，属性读写） | include | implemented |
| `client_use_agora_chat_domain_removed` | removed | client | `EMOptions.h`：`useAgoraChatDomain` 属性直接删除（无 @deprecated 过渡） | `EMOptions.java`：移除 `setUseAgoraChatDomain` / `getUseAgoraChatDomain` / `isUseAgoraChatDomainConfigured` 及私有字段 | skip（Flutter 从未暴露该字段，grep 全仓无 `useAgoraChatDomain`，无操作） | implemented |
| `client_error_connection_350_354` | new_error_code | client | `EMErrorCode.h`：`EMErrorConnectionTimeout=350`、`EMErrorConnectionDNSError=351`、`EMErrorConnectionIOError=352`、`EMErrorConnectionStreamClosed=353`、`EMErrorConnectionProvisionTimeout=354` | `EMError.java`：`CONNECTION_TIMEOUT=350`、`CONNECTION_DNS_ERROR=351`、`CONNECTION_IO_ERROR=352`、`CONNECTION_STREAM_CLOSED=353`、`CONNECTION_PROVISION_TIMEOUT=354`（双端名称与数值一致） | include（Flutter 错误码为原生透传，验证即可，预期无代码改动） | implemented |

### 4.23.0 → 4.24.0

| id | 类型 | 领域 | iOS 源签名 | Android 源签名 | 决策 | 状态 |
|---|---|---|---|---|---|---|
| `chat_search_messages_from_server` | new_api | chat | `IEMChatManager.h`：`- (void)searchMessagesFromServerWithOption:(EMMessageSearchOption *)option pageSize:(NSInteger)pageSize pageNum:(NSInteger)pageNum completion:(void (^)(EMPageResult<EMSearchServerMessageResult*> *result, EMError *aError))completion;`（pageNum 从 1 开始，按相关性排序，需 Console 开通增值服务） | `EMChatManager.java`：`asyncSearchMessagesFromServer(@NonNull EMMessageSearchOption option, int pageSize, int pageNum, EMValueCallBack<EMPageResult<EMSearchServerMessageResult>> callBack)`（pageSize∈[1,100]，pageNum 从 1 开始；无公开同步版） | include | implemented |
| `chat_message_search_option` | new_type | chat | `EMMessageSearchOption.h`（新文件）：`keywordList`(NSArray<NSString*>)、`keywordMatchType`、`conversationId`、`msgTypes`(NSArray<NSNumber*>)，`startTime`/`endTime`（毫秒，须成对）、`searchScope` | `EMMessageSearchOption.java`（新文件）：`setKeywordList(List<String>)`、`setKeywordMatchType`、`setConversationId`、`setMsgTypes(List<EMMessage.Type>)`、`setStartTime(long)`/`setEndTime(long)`、`setSearchScope(EMConversation.EMMessageSearchScope)` | include | implemented |
| `chat_keyword_list_match_type` | new_enum | chat | `EMKeywordListMatchType`：`OR=0, AND=1` | `EMKeywordListMatchType.java`：`OR, AND`（顺序一致） | include | implemented |
| `chat_search_server_message_result` | new_type | chat | `EMSearchServerMessageResult.h`（新文件）：`messageId`、`body`(nullable)、`ext`(nullable)、`from`、`to`、`conversationId`、`chatType`、`timestamp`(毫秒)、`highlightTexts`(nullable) | `EMSearchServerMessageResult.java`（新文件）：`getMessageId()`、`getBody()`、`getExt()`、`getFrom()`、`getTo()`、`getConversationId()`、`getChatType()`、`getTimestamp()`、`getHighlightTexts()` | include | implemented |
| `options_ntp_servers` | new_property | client | `EMOptions.h`：`@property (nonatomic, copy) NSArray<NSString *> *ntpServers;`（"host" 或 "host:port"，默认端口 123，NTPv4/RFC 5905，仅初始化时可设） | `EMOptions.java`：`setNtpServers(List<String>)` / `getNtpServers()`（未设置返回空列表） | include | implemented |
| `group_async_update_group_extension` | new_api | group | iOS 早有 completion 异步版（非本版本增量） | `EMGroupManager.java`：新增 `asyncUpdateGroupExtension(String groupId, String extension, EMValueCallBack<EMGroup> callBack)`（原同步方法的异步版） | skip（Flutter 已有 `updateGroupExtension`：Dart `chat_group_manager.dart` + 双端 wrapper 均在；Android wrapper 内部仍调同步方法，属既有模式，不在公开 API 平版范围） | implemented |
| `push_async_get_push_configs_from_server` | new_api | push | iOS 早有 completion 异步版（非本版本增量） | `EMPushManager.java`：新增 `asyncGetPushConfigsFromServer(EMValueCallBack<EMPushConfigs> callBack)` | skip（Flutter 已有 `getPushConfigsFromServer`：Dart + `PushManagerWrapper.java` 均在，理由同上） | implemented |

### 4.24.0 → 4.24.1

| id | 类型 | 领域 | iOS 源签名 | Android 源签名 | 决策 | 状态 |
|---|---|---|---|---|---|---|
| `chat_group_message_did_read_new` | new_listener | chat | `EMChatManagerDelegate.h`：新增 `- (void)groupMessageDidRead:(NSArray<EMGroupMessageAck *> *)aGroupAcks;`（去掉 aMessage 参数） | 无变更（4.24.0→4.24.1 无公开 API 变化） | include（iOS wrapper 迁移到新回调；Flutter 事件负载本就是 ack 列表，不含 message，行为中性） | implemented |
| `chat_group_message_did_read_old_deprecated` | deprecated | chat | 旧 `- (void)groupMessageDidRead:(EMChatMessage *)aMessage groupAcks:(NSArray *)aGroupAcks` 加 `__deprecated_msg("Use -groupMessageDidRead: instead")` | 无变更 | include（随上条一并处理，删除 wrapper 旧回调实现） | implemented |

## 未匹配清单 / 语义疑点（交用户决策，过程中不停留）

1. **keywordList 约束双端不一致**：iOS 注释为「每个关键词 1–120 字符，总共最大 120 字符，最多 5 个」（5×120>120 自相矛盾）；Android 为「每词 1–512 字符，共 ≤1024，≤5 个」。Flutter 层是否在 Dart 做参数校验、按哪端的约束，待用户确认。默认按不做 Dart 侧校验（透传由服务端拒绝）处理并标 ⚠️。
2. **iOS 4.24.1 `groupMessageDidRead:` 单端变更**：Android 无对应变更。旧回调仅 deprecate 未删除，兼容期内若 wrapper 同时实现新旧两回调可能双发；本次只实现新回调、删除旧实现，规避双发。原生内部是否对新旧 delegate 实现都做派发未逐行核实，标 ⚠️。
3. **Android `EMConversation.getMessage(String, boolean)` Javadoc 语义改写**（4.24.1）：`markAsRead=false` 从「不标为已读」改为「更新为未读」，文档措辞暗示行为变化但未核实实现。Flutter 对应 `ChatManager` 按 msgId 取消息的 API 注释是否同步，待确认。
4. **Android `EMClient.isAutoLogin()` 新增 public 方法**但注释明确 "internal use only"，不平版到 Flutter 公开层（默认 skip，如有异议请指出）。
5. **服务端消息搜索为增值服务**（Console 开通）：未开通时的具体错误码头文件未说明；实机验证若账号未开通会失败，属环境限制，验证时标注。
6. **iOS 搜索返回用 `EMPageResult`（pageNum/pageSize）而非 `EMCursorResult`**：Flutter 复用既有 `ChatPageResult<T>`（room 分页同款），无双端分歧，仅备注。
7. **行为变化（无 API 变化，仅备注）**：Android 4.23.0 `sendMessage` 失败前置校验会置 `Status.FAIL`；4.24.0 登录成功判断收紧、push token 上传失败清空本地 token；4.24.1 附件状态回调改主线程派发、单聊已读 ack 改内存置已读。均无需 Flutter 改动。
