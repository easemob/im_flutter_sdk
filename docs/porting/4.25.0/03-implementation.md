# 03 - 分层实现记录（Flutter 4.25.0）

契约冻结后三个 subagent（与主 agent 同级别大模型）并行实施，范围互不重叠：Dart 层 / Android wrapper / iOS wrapper。

## 实现落点

### C1 `fetchConversationsFromDB`（chat_get_conversations_from_db）

| 层 | 文件 | 要点 |
|---|---|---|
| Dart 常量 | `im_flutter_sdk/lib/src/internal/chat_method_keys.dart` | `getConversationsFromDBWithCursor`，`// 4.25.0` |
| Dart API | `im_flutter_sdk/lib/src/managers/chat_manager.dart` | `fetchConversationsFromDB({String? cursor, int pageSize = 20})`，照 `fetchPinnedConversations` 模式；双语注释含前置条件（autoLoadConversations=false）、排序规则、pageSize [1,100]、INVALID_PARAM |
| Android 常量 | `MethodKey.java:106-107` | 同值常量 |
| Android 实现 | `ChatManagerWrapper.java:131-132,1025-1035` | `asyncGetConversationsFromDB` + `CursorResultHelper.toJson` |
| iOS 常量 | `MethodKeys.h:118-119` | 同值常量 |
| iOS 实现 | `ChatManagerWrapper.m:204-205,1223-1237` | `getConversationsFromDBWithCursor:pageSize:completion:`（NSInteger）+ `[ret toJson]` |

### C2/C4 ChatOptions 两配置项（C3 评审后撤销）

| 层 | 文件 | 要点 |
|---|---|---|
| Dart | `im_flutter_sdk/lib/src/models/chat_options.dart` | `enableChatroomConversation bool=false`、`autoLoadConversations bool=true`；三个公开构造 + 私有构造 + 文档 Param 条目 + `toJson` `// 4.25.0` 段 |
| Android | `EMHelper.java:173-179` | 两 key 均 `json.has` 判空；分别映射 `setEnableChatroomConversation` / `setAutoLoadAllConversations` |
| iOS | `OptionsHelper.m:109-111` | 两 key 直接赋值（Dart 恒发送） |

### 评审后修订（2026-09-10，用户反馈）

- C3 `useAgoraChatDomain` 全部移除（Dart 字段/构造/文档/toJson、EMHelper.java、OptionsHelper.m、example options_codec、三处 CHANGELOG），依据见 02「评审后修订」与 KI-107。
- `ChatOptions.copyWith` 修复为"未传字段不修改"语义：补 `enableChatroomConversation`、`autoLoadConversations` 透传，顺带补历史遗漏的 `ntpServers`、`workPathCopiable` 透传，`loginExtension`、`extSettings` 改为 `?? this.x`（原实现 copyWith 后未传字段回落构造默认值或被清 null，丢失用户自定义值）。`_pushConfig` 由用户手动改造：去掉字段内联初始化，`ChatOptions._` 加私有参数 `pushConfig`（缺省 `?? ChatPushConfig()`），copyWith 透传 `_pushConfig`，修复 copyWith 后 push 配置被重置的问题。
- `ChatConversation` 新增公开 `toJson()`（与 `fromJson` 对称，含 ext/isPinned/pinnedTime/marks），`_toJson()` 保留不变（native 请求映射用途）；example 注册条目返回值改用 `e.toJson()`。
- `fetchConversationsFromDB` 双语注释补充关闭自动加载的原因说明（开启自动加载则全量入内存，分页失去意义）。

### C5 sync_data_ws 移除 → Flutter 基线未暴露，无改动（已在 02 定案）。
### C6 搜索关键词注释 → 无需改动：Dart 侧 `chat_message_search_option.dart` 注释已是 1-120/120（grep 实证：`lib/` 下无 512 匹配，1024 仅命中 loginExtension）。
### C7 NTP 校时 → skip（内部实现）。

## 收尾项

- 四包 pubspec version → 4.25.0（阶段二随门禁修复完成，含 interface 包）。
- CHANGELOG：主包（新 API + 两配置项 + 依赖升级）、android、ios 均加 `## 4.25.0` 段；interface 加裸标题（照 4.24.0 先例）。
- example 注册表：`im_flutter_sdk/example/lib/registry/apis/chat_apis.dart` 新增 `ChatManager.fetchConversationsFromDB` 条目（照 `searchMessagesFromServer` 模式，cursor 空串归一化为 null）。

## ⚠️/❌ 汇总

- ~~⚠️ UM-1 `useAgoraChatDomain`~~ → 已闭环：用户确认为对内品牌开关，不移植，已全部移除（KI-107）。
- ~~⚠️ example 注册条目手工 map~~ → 已闭环：`ChatConversation` 新增公开 `toJson()`，注册条目改用之。
- ~~ℹ️ `ChatOptions.copyWith` 未透传新字段~~ → 已修复为"未传字段不修改"：新字段及历史遗漏的 `ntpServers`/`workPathCopiable` 补透传，`loginExtension`/`extSettings` 改 `?? this.x`。
- ⚠️ `example/pubspec.lock` 被 `flutter pub get` 连带刷新（path 依赖版本 4.24.0→4.25.0），属 bump 合理连带。
- ❌ 无。

## 静态检查

- 主包 `flutter analyze`：No issues found!（Dart subagent 执行）
- example `flutter analyze`：No issues found!

## 阶段三门禁 gate 输出

命令：`echo '{}' | bash /Users/asterisk/Codes/zuoyu_flutter/.agents/skills/platform-sdk-porting-v2/hooks/porting_guard.sh gate flutter .`（cwd = worktree 根）

```
无输出 = 通过（exit=0）
```

## 门禁自查

- [x] 变更清单每条推进到 implemented 或显式 skip（C7 skip）
- [x] 方法名 key 三端同值（subagent 互核 + 阶段四 grep 复核）
- [x] 各包版本一致、native 依赖三处一致（gate 通过）
- [x] 无 git 提交类操作
