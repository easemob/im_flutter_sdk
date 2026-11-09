# 5.0.0 → 5.1.0 公开 API Diff

日期：2026-11-09。目标：Flutter `im_flutter_sdk`，既有 `5.1.0` worktree；开工 HEAD `33cfc60af9c0683afbb12422230fb994e459ac8c`，开工 `git status --short` 无输出。

## 来源与范围

- iOS：`/Users/asterisk/Codes/zuoyu_native/emclient-ios`，`5.0.0` = `f8f506ccb009db38d47280ab713a65e468287f4b` → `5.1.0` = `e88b1dcc9af41e57fa3d219986addfdc800367a4`。
- Android：`/Users/asterisk/Codes/zuoyu_native/emclient-android`，`SDK_5.0.0` = `8025ecb767e72a5c4623fab457ed269011e773d6` → `SDK_5.1.0` = `a8db682f400e36032c22d675b77fe77d86fbb7cf`。
- 两仓库均实际依次 `git checkout --detach <旧 tag>`、`git checkout --detach <新 tag>`；保留原未跟踪 `dailylog/2026-11-09.md`，未改 native 源码。完成后仍位于新 tag。
- `git tag --list '5.0*'` / `git tag --list 'SDK_5.0*'` 各仅一个 5.0.0；与目标 5.1.0 之间无中间版本 tag，无跳版。
- iOS 对 `newSDK/HyphenateSDK` 的公开 `EM*.h` / `IEM*.h` 做 diff，按 Xcode Public 导出核实；`EMOptions+PrivateDeploy.h` 也是公开头，不能因名称中 Private 而排除。
- Android 扫描根包、chat 和其他公开子包；排除 adapter/core、非 public 的 EMSessionManager、包可见方法、`@hide` 和仅实现变化。异步 API 优先。
- SPM 发布确认：`git ls-remote --tags https://github.com/easemob/HyphenateChat_iOS.git refs/tags/5.1.0` → `2aacd520c3890e3b09d949ace6711db41f11931d refs/tags/5.1.0`。

## 合并变更清单

下表记录实施状态；验证范围与待决策项以 03、04 及验收报告为准。以下 12 个 ID 是本次完整清单（含一个必要的既有能力补齐项）。

| id | 类型 | 领域 | iOS 源签名/契约 | Android 源签名/契约 | 决策 | 状态 |
|---|---|---|---|---|---|---|
| chat_get_conversations_from_db | new_api | chat | `getConversationsFromDBWithCursor:pageSize:completion:` 返回 `EMCursorResult<EMConversation *>` | `asyncGetConversationsFromDB(String cursor, int pageSize, EMValueCallBack<EMCursorResult<EMConversation>> callback)` | include | implemented |
| options_enable_chatroom_conversation | new_property | client | `BOOL enableChatroomConversation`，默认 NO | `setEnableChatroomConversation(boolean)` / `isEnableChatroomConversation()`，默认 false | include | implemented |
| options_auto_load_conversations | prerequisite | client | 既有 `BOOL autoLoadConversations`，默认 YES | 既有 `setAutoLoadAllConversations(boolean)` / `isAutoLoadAllConversations()`，默认 true | include：分页的必要前置，Flutter 尚无配置，补齐；不是新增 native API | implemented |
| options_remove_sync_ws_host | removed | client | 删除 `NSString *syncDataWSHost` | 删除 `setSyncDataWebSocketServer(String)` / `getSyncDataWebSocketServer()` | skip：Flutter 现状未封装，无残留可删 | verified（范围核对） |
| options_remove_sync_ws_port | removed | client | 删除 `int syncDataWSPort` | 删除 `setSyncDataWebSocketPort(int)` / `getSyncDataWebSocketPort()` | skip：Flutter 现状未封装，无残留可删 | verified（范围核对） |
| options_agora_domain | new_property | client | `BOOL useAgoraChatDomain` | `setUseAgoraChatDomain(boolean)` / `getUseAgoraChatDomain()` | skip：KI-107 对内品牌开关，国内保持缺省，不暴露 | verified（范围核对） |
| image_thumbnail_secret_deprecated | deprecated | chat | `thumbnailSecretKey __deprecated_msg("Use secretKey instead for original image")` | 图片 getThumbnailSecret / setThumbnailSecret 在 5.0.0 已标记 @Deprecated，本区间无新增废弃 | defer：不新增封装；Flutter 5.0.0 已删除图片 thumbnailSecret，保留视频独立字段；交验收确认 | verified（现状核对，defer） |
| multi_device_group_update | new_enum | group | 既有 `EMMultiDevicesEventGroupUpdate = 34` | 新增 `GROUP_UPDATE = 34` | include：复用现有映射，更新仅 iOS 的旧描述 | implemented |
| group_invite_need_confirm | new_property | group | 既有 `EMGroup.settings.IsInviteNeedConfirm` | 新增 `boolean EMGroup.isInviteNeedConfirm()` | include：Android `configs.inviteNeedConfirm` 从硬编码 false 改为真实 getter；Dart/iOS 已有 | implemented |
| search_keyword_limits | doc_change | chat | 既有每词 1–120、总计 120、最多 5 个 | `EMMessageSearchOption.setKeywordList(List<String>)` 文档由每词 512/总计 1024 修正到 120/120，最多 5 个 | include：核对现有 Dart 与 example 文档已符合，不加上层过滤 | implemented |
| options_data_sync_default | default_change | client | 既有默认 `EMDataSyncTypeConversations` | `setDataSyncType(EnumSet<EMDataSyncType>)` 文档明确默认 CONVERSATIONS，旧默认 NONE | include：保持可空、不传即 native 默认，补齐默认行为说明 | implemented |
| android_http_timeout_units | doc_change | client | 无对应公开 API | `HttpClientConfig.getTimeout(Map<String,String>)` 文档明确返回毫秒 | skip：低层 HTTP utility 无 Flutter 公共映射，不引入网络工具接口 | verified（范围核对） |

## 双端清单及未匹配项

iOS 4 个公开头变更对应：`chat_get_conversations_from_db`、`options_enable_chatroom_conversation`、`options_remove_sync_ws_host`、`options_remove_sync_ws_port`、`options_agora_domain`、`image_thumbnail_secret_deprecated`。

Android 公开变更对应：`chat_get_conversations_from_db`、`options_enable_chatroom_conversation`、`options_remove_sync_ws_host`、`options_remove_sync_ws_port`、`options_agora_domain`、`multi_device_group_update`、`group_invite_need_confirm`、`search_keyword_limits`、`options_data_sync_default`、`android_http_timeout_units`。`EMClient.VERSION` 的 5.0.0→5.1.0 是版本元数据，依赖升级处理，不新增 Flutter API；`isUseAgoraChatDomainConfigured()` 标注 `@hide`，不封装。

| 项目 | 双端差异/处理依据 | 待决策 |
|---|---|---|
| 图片缩略图 secret 废弃 | 只有 iOS 本次新增废弃标记；Flutter 已在 5.0.0 删除对应图片字段，并使用 secret；不把视频 thumbnailSecret 一并删除 | 确认维持现状 |
| Android HTTP timeout | 仅 Android low-level utility 的文档变化，无 iOS 对等 API | 确认无需跨平台暴露 |
| GROUP_UPDATE | Android 本次补值 34；52 是另一既有 GROUP_METADATA_CHANGED，现有 Flutter 保持原映射，不合并两个事件 | 运行时事件触发范围未在本次实测，记录限制 |
| 自动加载会话配置 | 双端既有，但 Flutter 缺失；分页要求初始化前关闭 | 按必要前置补齐，验收标注推断 |

不将 Android 私有缓存、群回执查库保护、推送内部并发修复、token 计时实现变更计为新公开 API，也不宣称已做这些行为的设备回归；随 native 依赖升级继承，后续覆盖分析可另评估。

## 源码定位（目标 tag）

以下路径相对各 native 仓库根，删除项需 `git show <旧 tag>:<路径>` 阅读旧版。

| 项目 | iOS 文件:行 | Android 文件:行 |
|---|---|---|
| 分页 | `newSDK/HyphenateSDK/ChatManager/IEMChatManager.h:256` | `hyphenatechatsdk/src/com/hyphenate/chat/EMChatManager.java:2455` |
| 聊天室开关 | `newSDK/HyphenateSDK/EMOptions.h:467` | `hyphenatechatsdk/src/com/hyphenate/chat/EMOptions.java:1936`、`:1959` |
| 自动加载前置 | `newSDK/HyphenateSDK/EMOptions.h:452` | `hyphenatechatsdk/src/com/hyphenate/chat/EMOptions.java:1888` |
| 删除同步 WS 地址/端口 | 旧 `newSDK/HyphenateSDK/EMOptions+PrivateDeploy.h:150`、`:166` | 旧 `hyphenatechatsdk/src/com/hyphenate/chat/EMOptions.java:948`、`:971`、`:994`、`:1013` |
| 品牌开关 | `newSDK/HyphenateSDK/EMOptions.h:537` | `hyphenatechatsdk/src/com/hyphenate/chat/EMOptions.java:1077`、`:1096` |
| 图片 secret 废弃 | `newSDK/HyphenateSDK/ChatManager/Body/EMImageMessageBody.h:108` | `hyphenatechatsdk/src/com/hyphenate/chat/EMImageMessageBody.java:337`、`:353`（旧 tag 已废弃） |
| 群更新事件 | `newSDK/HyphenateSDK/EMMultiDevicesDelegate.h:62` | `hyphenatechatsdk/src/com/hyphenate/EMMultiDeviceListener.java:324` |
| 群邀请确认 | `newSDK/HyphenateSDK/GroupManager/EMGroup.h:85`、`EMGroupConfigs.h:61` | `hyphenatechatsdk/src/com/hyphenate/chat/EMGroup.java:223` |
| 关键词限制 | `newSDK/HyphenateSDK/ChatManager/EMMessageSearchOption.h:33` | `hyphenatechatsdk/src/com/hyphenate/chat/EMMessageSearchOption.java:41` |
| 同步默认 | `newSDK/HyphenateSDK/EMOptions.h:529` | `hyphenatechatsdk/src/com/hyphenate/chat/EMOptions.java:2221` |
| HTTP timeout 单位 | 无 | `hyphenatechatsdk/src/com/hyphenate/cloud/HttpClientConfig.java:106` |

## 阶段一门禁证据

命令（worktree 根）：
```sh
printf '{}' | bash /Users/asterisk/Codes/zuoyu_flutter/.agents/skills/platform-sdk-porting-v2/hooks/porting_guard.sh gate flutter "$PWD"
```
实际 stdout/stderr：空；退出码：0（基线 5.0.0 版本与常量门禁通过）。变更清单逐项有 ID/类型/领域/双端签名/决策；未匹配项如上，不为空。下一步读取本文后冻结跨端契约。
