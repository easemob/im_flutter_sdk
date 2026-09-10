# 01 - 公开 API Diff（4.24.1 → 4.25.0）

- 源：iOS `emclient-ios` tag `4.24.1 → 4.25.0`；Android `emclient-android` tag `SDK_4.24.1 → SDK_4.25.0`
- 目标：flutter / `im_flutter_sdk`，目标版本 `4.25.0`
- 版本区间核对：`git tag` 列表确认 4.24.1 与 4.25.0 之间无中间小版本 tag（iOS：4.24.0/4.24.1/4.25.0；Android：SDK_4.24.0/SDK_4.24.1/SDK_4.25.0），单次增量覆盖，无跳版。
- diff 范围：iOS `newSDK/HyphenateSDK/**` 公开头文件；Android `hyphenatechatsdk/src/com/hyphenate/`（根包 + `chat/`，`adapter/`、`core/`、`cloud/` 为内部实现不 diff）。

## 变更清单

| id | 类型 | 领域 | iOS 源签名 | Android 源签名 | 决策 | 状态 |
|---|---|---|---|---|---|---|
| `chat_get_conversations_from_db` | new_api | chat | `- (void)getConversationsFromDBWithCursor:(nullable NSString *)cursor pageSize:(NSInteger)pageSize completion:(nonnull void (^)(EMCursorResult<EMConversation *> * _Nullable result, EMError * _Nullable error))completionBlock`（IEMChatManager.h） | `public void asyncGetConversationsFromDB(final String cursor, final int pageSize, final EMValueCallBack<EMCursorResult<EMConversation>> callback)`（EMChatManager.java） | include | pending |
| `options_enable_chatroom_conversation` | new_option | client | `@property(nonatomic) BOOL enableChatroomConversation;`（EMOptions.h，默认 NO） | `setEnableChatroomConversation(boolean)` / `isEnableChatroomConversation()`（EMOptions.java，默认 false） | include | pending |
| `options_use_agora_chat_domain` | new_option | client | `@property (nonatomic) BOOL useAgoraChatDomain;`（EMOptions.h，**无文档注释**） | `setUseAgoraChatDomain(boolean)` / `getUseAgoraChatDomain()` + `@hide isUseAgoraChatDomainConfigured()`（EMOptions.java，Boolean 三态） | **exclude**（用户确认：native 留给跨平台 SDK 的对内品牌开关，国内 easemob 不设置走默认缺省 / 海外 agora 显式指定 true，不面向终端用户，见 KI-107） | done |
| `options_sync_data_ws_removed` | removed_option | client | `EMOptions+PrivateDeploy.h` 删除 `syncDataWSHost` / `syncDataWSPort` 两个属性 | `EMOptions.java` 删除 `setSyncDataWebSocketServer/getSyncDataWebSocketServer/setSyncDataWebSocketPort/getSyncDataWebSocketPort` | include（双端同步删除，Flutter 侧需核对现状后同步移除） | pending |
| `search_keyword_limit_doc` | doc_change | chat | 无（iOS 未检索到对应注释变更） | `EMMessageSearchOption.setKeywordList` 注释：关键词 1-512→1-120 字符，总长 1024→120 | include（仅注释，Flutter 侧如有对应注释同步更新） | pending |
| `internal_ntp_timestamp` | internal | client | 无公开头文件变更 | `EMClient.getCorrectedTimestampMs()` / `EMSessionManager` NTP 校时（包级可见，内部实现） | skip（内部实现，非公开 API） | skip |

## 未匹配清单（语义疑点，宁多勿漏）

| id | 疑点 | 说明 |
|---|---|---|
| UM-1 | ~~`useAgoraChatDomain` 双端语义不完全对齐~~ **已闭环** | 用户确认该接口为 native 留给跨平台 Flutter/RN SDK 的对内品牌开关（国内 easemob 不设置走默认缺省、海外 agora 显式指定 true），不暴露给终端用户。环信侧无需任何代码：Android 默认 `null` 未配置时不下发到底层，iOS `BOOL` 零初始化即缺省。已沉淀为 skill 已知问题 KI-107，Flutter 侧不移植。 |
| UM-2 | `getConversationsFromDB` 依赖 `autoLoadConversations = NO/false` 前置条件 | 双端注释均要求先关闭自动加载会话。Flutter 侧现有 `ChatOptions.autoLoadConversations`（Android 端 `setAutoLoadAllConversations`）是否已在 options 链路暴露需在基线调查确认；新 API 文档需保留该前置说明。 |
| UM-3 | `options_sync_data_ws_removed` Flutter 侧现状未知 | 需 grep 确认 Flutter 4.24.1 基线是否暴露了 syncDataWS 相关 option；若已暴露，本次为**破坏性移除**，需在验收报告显式标注。 |
| UM-4 | `search_keyword_limit_doc` 仅 Android 有注释变更 | iOS 侧无对应注释（可能本就无此说明）。Flutter 侧若有 512/1024 字样注释需同步为 120；若无则无需改动。 |

## 门禁自查

- [x] 每条变更有 id/类型/领域/双端签名/决策
- [x] 版本区间无跳版（git tag 核对）
- [x] 语义疑点全部进未匹配清单（UM-1~UM-4）
- [x] 未匹配清单非空，无需逐条说明空理由
