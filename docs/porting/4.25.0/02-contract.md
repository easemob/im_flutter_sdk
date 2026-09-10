# 02 - 基线调查与跨端契约（Flutter 4.25.0）

## 基线调查结论

- 分支：worktree `.worktree/4.25.0`，分支 `4.25.0`，从 `flutter2_stable`（53b88ac7）切出，`git status` 干净。
- 现状版本：四包 pubspec `4.24.0`；native 依赖三处 `4.24.1`（podspec `HyphenateChat 4.24.1`、SPM `HyphenateChat_iOS exact: 4.24.1`、gradle `io.hyphenate:hyphenate-chat:4.24.1`），互相一致（KI-101 的 pod/SPM 不一致已不存在）。
- **UM-3 结论**：Flutter 基线从未暴露 `syncDataWS*` 选项（全仓 grep 无匹配）→ native 侧移除对 Flutter 无影响，无破坏性变更。
- **UM-2 结论**：Flutter 基线未暴露 `autoLoadConversations`（grep 无匹配）。新 API `getConversationsFromDB` 的前置条件（autoLoadConversations=false）无法在 Flutter 侧满足 → 契约新增 `options_auto_load_conversations` 一并平版（native 双端 4.24.1 基线已具备该选项：Android `setAutoLoadAllConversations` / iOS `autoLoadConversations`，默认均为 true）。
- 同类实现参照：`fetchPinnedConversations`（Dart）/ `getPinnedConversationsFromServerWithCursor`（三端 key）/ Android `ChatManagerWrapper.getPinnedConversationsFromServerWithCursor`（EMValueWrapperCallBack + CursorResultHelper.toJson）/ iOS `ChatManagerWrapper.m getPinnedConversationsFromServerWithCursor:`（wrapperCallBack + [ret toJson]）。
- Options 链路：Dart `chat_options.dart`（公开构造 → `ChatOptions._` → `toJson`，putIfNotNull 组装）→ Android `EMHelper.java`（`json.has(...)` 判空）→ iOS `OptionsHelper.m`（bool 直接赋值，对象/数组仿 `ntpServers` 判空）。
- 版本注释风格：Dart/Java/ObjC 均用 `// 4.x.x` 行注释（如 `// 4.24.0`）。
- example 注册表：新 API 需在 `example/lib/registry/apis/` 补 `ApiEntry` 注册条目。

## 已知问题清单规避

- KI-101（pod/SPM 版本不一致）：本次三处同步 bump 至 4.25.0，互核一致。
- KI-106（example 注册名 EM→Chat 改名）：新注册条目使用 `ChatManager.*` 命名。
- 其余条目（KI-001~004、102~105）本次不命中。

## native 依赖 bump（阶段二第一步，已完成）

| 位置 | 旧 | 新 |
|---|---|---|
| `im_flutter_sdk_ios/ios/im_flutter_sdk_ios.podspec` `s.dependency 'HyphenateChat'` | 4.24.1 | 4.25.0 |
| `im_flutter_sdk_ios/ios/im_flutter_sdk_ios/Package.swift` `exact:` | 4.24.1 | 4.25.0 |
| `im_flutter_sdk_android/android/build.gradle` `io.hyphenate:hyphenate-chat` | 4.24.1 | 4.25.0 |
| podspec `s.version`（第四处对齐项） | 4.24.0 | 4.25.0 |

注：远端 4.25.0 包本次不可拉取（maven/CocoaPods/SPM 均不可用），编译验证用本地包替换（LOCAL-DEP-TEST 覆盖层，不提交）；SPM tag `4.25.0` 是否已发布未经 `git ls-remote` 核实（无网络），记入验收报告待确认。

## 跨端契约（冻结，实现唯一对齐依据）

### C1 `chat_get_conversations_from_db`（new_api / chat）

- 方法名 key（Dart `ChatMethodKeys` / Java `MethodKey` / ObjC `MethodKeys.h` 三端逐字一致）：**`getConversationsFromDBWithCursor`**
- Dart 公开 API（`chat_manager.dart`，照 `fetchPinnedConversations` 模式）：
  `Future<ChatCursorResult<ChatConversation>> fetchConversationsFromDB({String? cursor, int pageSize = 20})`
- 请求 JSON：`{"cursor": string（可省，putIfNotNull）, "pageSize": int}`
- 返回包装：`{getConversationsFromDBWithCursor: ChatCursorResult JSON}`，Dart 读 `result[ChatMethodKeys.getConversationsFromDBWithCursor]` 后 `ChatCursorResult.fromJson(..., dataItemCallback: ChatConversation.fromJson)`
- Android：`EMClient.getInstance().chatManager().asyncGetConversationsFromDB(cursor, pageSize, new EMValueWrapperCallBack<EMCursorResult<EMConversation>>(result, channelName){...CursorResultHelper.toJson(object)...})`
- iOS：`[EMClient.sharedClient.chatManager getConversationsFromDBWithCursor:cursor pageSize:pageSize completion:^(EMCursorResult<EMConversation *> *ret, EMError *error){ wrapperCallBack ... [ret toJson] }]`（pageSize 为 NSInteger，无需 UInt8 转换）
- Dart 文档双语，必须含前置条件说明：调用前需将 `ChatOptions.autoLoadConversations` 设为 `false`，并说明原因（开启自动加载时 SDK 初始化即全量加载会话到内存，分页加载失去意义）；取值范围 pageSize [1,100]；无效 cursor 抛 `ChatError`（INVALID_PARAM）。
- 版本注释 `// 4.25.0`。

### C2 `options_enable_chatroom_conversation`（new_option / client）

- Dart：`ChatOptions.enableChatroomConversation`，`bool`，默认 `false`；公开构造 + `ChatOptions._` + 文档 Param 条目同步增加；`toJson` key **`enableChatroomConversation`**（putIfNotNull，非空恒发送）。
- Android `EMHelper.java`：`if (json.has("enableChatroomConversation")) { options.setEnableChatroomConversation(json.getBoolean("enableChatroomConversation")); }`
- iOS `OptionsHelper.m`：`options.enableChatroomConversation = [aJson[@"enableChatroomConversation"] boolValue];`（key 恒存在，直接赋值安全，与 enableUserInfo 同模式）
- 版本注释 `// 4.25.0`。

### C3 `options_use_agora_chat_domain`（new_option / client，UM-1）→ **不移植（评审后修订）**

- 初版契约曾定为 `bool?` 可空透传并已实现；评审时用户确认该接口是 native 留给跨平台 Flutter/RN SDK 的**对内品牌开关**（国内 easemob 不设置走默认缺省、海外 agora 显式指定 true），不面向终端用户 → Flutter 侧不暴露、不保留 wrapper 代码（已全部移除）。
- 环信侧正确性依据（国内不设置、走默认缺省，而非显式设 false）：Android 默认 `null`（未配置时 `EMChatConfigPrivate` 不下发到底层，走 native 缺省）；iOS `BOOL` 零初始化即缺省。不设置即为正确行为。
- 已沉淀为 skill 已知问题 **KI-107**，后续平版（含 RN、agora_chat_sdk）遇到直接跳过。

### C4 `options_auto_load_conversations`（new_option / client，UM-2 衍生新增）

- Dart：`ChatOptions.autoLoadConversations`，`bool`，默认 `true`（与 native 默认一致）；`toJson` key **`autoLoadConversations`**（恒发送）。
- Android：`if (json.has("autoLoadConversations")) { options.setAutoLoadAllConversations(json.getBoolean("autoLoadConversations")); }`
- iOS：`options.autoLoadConversations = [aJson[@"autoLoadConversations"] boolValue];`（恒存在，直接赋值安全）
- 版本注释 `// 4.25.0`。

### C5 `options_sync_data_ws_removed` → Flutter 无改动（基线未暴露，见上）。

### C6 `search_keyword_limit_doc` → 检查 Dart 侧搜索关键词注释是否含 512/1024 字样，有则同步改为 120；无则不改。实现时核实并在 03 中记录结论。

### C7 `internal_ntp_timestamp` → skip（内部实现）。

## 收尾项（按包，阶段三完成）

- 四包 `pubspec.yaml` version：`4.24.0` → `4.25.0`（含无 wrapper 改动的 interface 包）。
- CHANGELOG（中文）：主包记 C1/C2/C4 + native 依赖升级条目；android 包记 C1 wrapper + C2/C4 helper + 依赖升级；ios 包同；interface 包无实质改动按先例处理。
- example 注册表补 `fetchConversationsFromDB` 条目（`ChatManager.*` 命名）。

## 评审后修订（2026-09-10，用户反馈）

- C3 撤销：`useAgoraChatDomain` 确认为对内品牌开关，不移植（见上，KI-107）。
- `ChatOptions.copyWith` 修复为"未传字段不修改"语义：补 `enableChatroomConversation`、`autoLoadConversations` 透传，顺带补历史遗漏的 `ntpServers`（4.24.0）、`workPathCopiable`（4.10）透传，并把 `loginExtension`、`extSettings` 从直接赋值改为 `?? this.x`——原实现调用 `copyWith` 会使未传字段回落构造默认值或被清为 null，丢失用户自定义值（用户指出并确认）。
- `_pushConfig` 改造（用户手动修改）：字段去掉内联初始化，`ChatOptions._` 新增私有参数 `ChatPushConfig? pushConfig`（`_pushConfig = pushConfig ?? ChatPushConfig()`），copyWith 传 `pushConfig: _pushConfig`——修复 copyWith 后 push 配置（miPush/oppoPush 等经 deprecated setter 写入的内容）被重置为全新默认对象的问题。
- `ChatConversation` 新增公开 `toJson()`（与 `fromJson` 对称：convId/type/isThread/isPinned/pinnedTime/ext/marks），供调试与测试；example 注册条目返回值改用手工 map → `e.toJson()`。

## hooks 安装说明

本 harness（Kimi Code CLI）无 Codex hooks 契约的挂载点，按 skill「无 hooks 能力的 agent」档执行：`gate` 作为每阶段必跑命令、输出附进阶段产物；`pre` 靠纪律自约束（本任务全程不执行 git 提交类命令）。

## 阶段二门禁 gate 输出

（见下方命令输出留痕）

命令：`echo '{}' | bash /Users/asterisk/Codes/zuoyu_flutter/.agents/skills/platform-sdk-porting-v2/hooks/porting_guard.sh gate flutter .`（cwd = worktree 根）

```
（首次运行）{"decision": "block", "reason": "平版门禁检查未过（修复后再收尾；确认为合理差异时，说明理由后可结束）：podspec s.version(4.25.0) 与包版本(4.24.0) 不一致；"}
→ 修复：四包 pubspec 4.24.0 → 4.25.0
（二次运行）无输出 = 通过（exit=0）
```

## 门禁自查

- [x] native 依赖 bump 完成，四处版本互核一致（4.25.0）
- [x] 契约 C1~C7 逐项定死，无"待猜"项
- [x] `git status` 干净、分支 `4.25.0` 正确（bump 改动前已确认；bump 后仅有预期改动）
- [x] known-issues 已浏览并规避命中项（KI-101/KI-106）
- [x] hooks：无挂载能力 harness，gate 改流程强制（输出见上）
