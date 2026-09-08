# 阶段三：各层实现记录（Flutter 4.24.0）

- 实现方式：契约（02-contract.md §3）冻结后，Dart / Android wrapper / iOS wrapper 三个 subagent 并行实施，文件不相交；interface 包版本/CHANGELOG 由主 agent 补齐。
- 依据：`docs/porting/4.24.0/01-api-diff.md`（变更清单，状态已全部推进到 implemented / skip）。

## 1. 改动总览

### Dart（主包 + example）

- `chat_message.dart`：新增 `webhookEnv`（String?）字段 + toJson/fromJson（:240/:966/:994），双语注释。
- `chat_options.dart`：新增 `ntpServers`（List<String>?），三个公开构造函数均加命名参数（:452/:830/:1103/:1378/:1452），toJson :1510。
- `chat_enums.dart:1152`：新增 `ChatKeywordListMatchType { OR, AND }`。
- 新建 `chat_message_search_option.dart`：`ChatMessageSearchOption`，toJson 输出契约全部 key，可空缺省不下发，startTime/endTime 成对下发。
- 新建 `chat_search_server_message_result.dart`：`ChatSearchServerMessageResult`（msgId/body/attributes/from/to/convId/chatType/timestamp/highlightTexts）。
- `chat_manager.dart:2657`：`searchMessagesFromServer({required option, pageSize=20, pageNum=1})` → `ChatPageResult<ChatSearchServerMessageResult>`。
- `chat_method_keys.dart:458`：`searchMessagesFromServer` 常量（`// 4.24.0`）。
- 导出链：`im_flutter_sdk.dart:15-16`、`inner_headers.dart:24-25`。
- example `chat_apis.dart:89`：注册 `searchMessagesFromServer` ApiEntry。
- 主包 pubspec → 4.24.0；主包 CHANGELOG 新增 `## 4.24.0` 四条目。
- interface 包 pubspec → 4.24.0、CHANGELOG 空标题条目（主 agent 补）。

### Android wrapper

- `MethodKey.java:396-397`：`searchMessagesFromServer` 常量。
- `EMHelper.java`：OptionsHelper `ntpServers` 解析（:164-172，在 `!enableDNSConfig` 门控块外）；MessageHelper fromJson/toJson `webhookEnv`（:554-557/:623-624）；PageResultHelper 新增 `EMSearchServerMessageResult` 分派（:1286-1289）；新增 `SearchServerMessageResultHelper`（:1297-1355，含全 9 种 body 类型 instanceof 分派）。
- `ChatManagerWrapper.java`：分支 :175-178 + 实现 :1384-1429（option 全 key 解析 → `asyncSearchMessagesFromServer` → `EMValueWrapperCallBack` → PageResult 序列化）。
- pubspec → 4.24.0；CHANGELOG 新增 `## 4.24.0`（依赖升级 + 原生实现）。

### iOS wrapper

- `MethodKeys.h:420-421`：`searchMessagesFromServer` 常量（`// 4.24.0`）。
- `MessageHelper.m`：fromJson :67-69、toJson :121-124（nil 防崩溃，仅非 nil 写入）。
- `OptionsHelper.m:105-108`：`ntpServers`（NSNull 双判空）。
- `ChatManagerWrapper.m`：import :24-25；分支 :248-251；`#pragma mark 4.24.0` 实现 :1649-1692（EMMessageSearchOption 构造 → `searchMessagesFromServerWithOption:` → wrapperCallBack + PageResultHelper）。
- 新增 `SearchServerMessageResultHelper.h/.m`：`EMSearchServerMessageResult (Helper) <ModeToJson>`，key 逐字按契约。
- `groupMessageDidRead` 迁移（:1480-1489）：删除旧 `groupMessageDidRead:groupAcks:`，新增单参数 `groupMessageDidRead:`，方法体/事件名/负载不变，Dart 与 Android 零改动。
- pubspec → 4.24.0；CHANGELOG 新增 `## 4.24.0`。

## 2. 阶段内静态检查

- `flutter analyze`：主包 **No issues found!**；example **No issues found!**（Dart agent 实跑）。
- 三端原生签名与 emclient-ios `4.24.1` / emclient-android `SDK_4.24.1` 源码逐一核对通过（wrapper agents 实证）。
- 门禁 gate：`echo '{}' | bash hooks/porting_guard.sh gate flutter <worktree>` → **exit=0**（方法名 key 双端齐、四包版本一致、native 依赖三处一致）。
- Android/iOS 编译验证留待阶段四真实构建。

## 3. ⚠️ 合理推断项（进验收报告）

1. Dart：`ntpServers` 给 ChatOptions 全部三个公开构造函数都加了参数（契约只写"构造函数命名参数"）。
2. Dart：`ChatSearchServerMessageResult` 非空字段缺 key 回退（`''`/`0`/`ChatType.Chat`），与 ChatMessage.fromJson 容错风格一致。
3. Dart：body 解析复制了 `ChatMessage._bodyFromMap` 的 dispatch（private 无法直接复用），存在双份维护点。
4. Dart：keywordList 长度/字符约束双端不一致（iOS 1–120/总 120 vs Android 1–512/总 1024），按默认决策 Dart 不校验、透传由服务端拒绝，注释写明 ≤5 个。
5. Android：`webhookEnv` toJson 走 HashMap.put，值为 null 时 key 保留为 null（不去 key）；Dart 侧容忍，行为兼容。
6. Android：搜索结果 msgId/from/to/convId 无条件 put（原生可能返回 null，与 MessageHelper 同风格）。
7. iOS：`#pragma mark 4.24.0` 段插在 4.15.2 与 4.22.0 段之间，版本段顺序非单调（位置问题，无功能影响）。
8. iOS：新 helper 命名 `SearchServerMessageResultHelper.*` 按 `GroupMessageAckHelper` 去 EM 前缀惯例推断。
9. iOS：keywordMatchType/searchScope 未判空直接强转——Dart 恒发非 null，缺 key 时 `integerValue`=0 恰为默认值 OR/Content，安全。
10. iOS：原生 4.24.1 对新旧 `groupMessageDidRead` delegate 是否双发未逐行核实；已只保留新实现规避。
11. example/pubspec.lock 因版本 bump 自动更新，予以保留。

## 4. ❌ 未实施项

无。变更清单 12 条全部 implemented / skip（skip 均有理由，见 01-api-diff.md）。

## 5. 门禁 gate 实证

```text
$ echo '{}' | bash hooks/porting_guard.sh gate flutter <worktree>
exit=0   # 无 block 输出
$ grep '^version' 四包 pubspec.yaml
4.24.0 × 4
$ grep HyphenateChat/hyphenate-chat 版本（podspec / Package.swift / build.gradle）
4.24.1 × 3
```

## 6. 第二轮追加改动（2026-09-08 用户决策后）

- 决策 1：`chat_message_search_option.dart` keywordList 双语注释 + example 注册描述改为 iOS 约束口径（≤5 个，每个 1-120 字符、总共最大 120 字符）。
- 决策 5：Android wrapper 两方法迁移到 4.24.0 异步原生 API——`GroupManagerWrapper.updateGroupExt` → `asyncUpdateGroupExtension`；`PushManagerWrapper.getImPushConfigFromServer` → `asyncGetPushConfigsFromServer`（均经 `EMValueWrapperCallBack` + `updateObject`，返回结构不变）。
- 复验：`flutter build apk --debug` ✅（20.8s）、`flutter analyze` ✅ 无问题、gate exit=0。
