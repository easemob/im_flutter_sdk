# iOS vs Android 5.0 原生 SDK 差异清单

> 目标：iOS 5.0 与 Android 5.0 原生 SDK 对同一 API/事件应返回一致。
> 依据：原生包静态确认（javap 反编译 Android jar / strings 提取 iOS framework）+ wrapper 透传实测（wrapper 已全透传，返回即原生行为）。
> 差异 = 两端原生 SDK（环信）行为不同 → 研发修原生 SDK。
> 2026-08-12

## 已确认的原生差异

### media 发送失败 thumbnailSecret（video/image）

| 端 | 原生值 / wrapper | 处理 |
|---|---|---|
| Android | `EMVideoMessageBody.getThumbnailSecret()` 发送失败 = `''`（原生空串） | 透传（wrapper 无条件 put `thumbnailSecret`）|
| iOS | `EMVideoMessageBody.thumbnailSecretKey` 发送失败 = `nil` | **wrapper 修 2 处**：① toJson 字段名 `thumbnailSecretKey` → `thumbnailSecret`（原输出字段名错，与 fromJson 读的 `thumbnailSecret`/Android/case 断言不对称）；② nil → `?: @""`（原生 nil → JSON 空串）|

- iOS EMVideoMessageBody toJson 原输出 `thumbnailSecretKey`（字段名错）→ case 断言 `thumbnailSecret` 缺 → 实为字段名不对称 bug + nil 序列化；已修（字段名对齐 + 补空串）。
- EMImageMessageBody 输出 `thumbnailSecret`（字段名本就对，仅补 nil → `""`）。
- 若要求原生对齐：研发可让 iOS 原生发送失败返回空串（同 Android）。

### fetchReactionDetail（invalid msgId/reaction）

| 端 | 原生行为 | 处理 |
|---|---|---|
| Android | `asyncGetReactionDetail` invalid → 成功返回 `{list, cursor}`（`EMCursorResult`） | 透传（wrapper 无条件 toJson）|
| iOS | `getReactionDetail:reaction:cursor:pageSize:completion:` invalid → 成功（无 error）但 reaction 为 nil | **wrapper 补**：`error == nil && reaction == nil` 时构造空 `EMCursorResult`（`{list:[], cursor:""}`，对齐 Android 输出）|

- 实测确认：iOS invalid 返回 `{"success": true, "result": {}}`（成功、无 error、result 空）→ wrapper 原先 `cursorResult = nil` → `[nil toJson]` → 缺 list/cursor；补空结构后输出 `{list:[], cursor:""}`。
- 若要求原生对齐：研发可让 iOS 原生 invalid 返回空 `EMMessageReaction` 结构（同 Android `EMCursorResult`）。

## 原生行为差异（待研发，透传实测：Android 单独跑通过=行为基准 / iOS 单独跑失败）

### deleteRemoteConversation（空 convId）

| 端 | 原生 API | 行为 |
|---|---|---|
| Android | `EMChatManager.deleteConversationFromServer(String, EMConversationType, boolean, EMCallBack)`（javap 确认） | 发请求 → 服务端返回 **303** "field channel cannot be null or empty"（channel 参数校验；错误字符串不在 native .so，判定为服务端返回） |
| iOS | `EMChatManager deleteServerConversation:conversationType:isDeleteServerMessages:completion:`（IEMChatManager.h:375） | 发 REST 请求（framework strings 含 `Rest_DeleteServerConversation`）→ 服务端返回**成功**（无错误，None） |

- 两端都发服务端请求，但服务端对两端请求的响应不同：Android 请求带空 channel 被 303 拒；iOS 请求服务端容忍/返回成功（或 iOS 请求构造不同）。
- wrapper 均透传（iOS 无错误 / Android 303），非 wrapper 差异。
- 待研发确认：服务端对两端请求行为不同，还是 iOS 原生请求构造/参数处理不同。

### updateMessage（改内容后查询）

| 端 | 原生 API | 行为 |
|---|---|---|
| Android | `EMChatManager.updateMessage(EMMessage)`（javap） | `getMessage` 返回**新** content（原生生效）|
| iOS | `EMChatManager updateMessage:completion:`（IEMChatManager.h:480） | `getMessage` 仍返回**旧** content（原生未生效/DB 未更新）|

- 透传实测：Android updateMessage 后查询返回新内容；iOS updateMessage 返回成功（completion 无 error）但后续 `getMessage` 仍是旧内容。
- 待研发确认：iOS 原生 updateMessage 未真正更新本地 DB，还是测试时序（update 后立即查未刷新）问题。

### media voice 发送失败 fileSize

| 端 | 原生 API | 行为 |
|---|---|---|
| Android | `EMVoiceMessageBody.getFileSize()`（javap） | 发送失败 = `0` |
| iOS | `EMVoiceMessageBody.fileLength`（原生属性） | 发送失败 = `-1`（默认 -1）|

- 透传实测：发送失败（文件不存在）时，Android body `fileSize=0`；iOS body `fileSize=-1`（原生 `fileLength` 构造默认 -1）。
- case 断言按 Android（`0`）→ iOS 挂；待研发确认 iOS 原生发送失败 `fileLength` 默认值应为 0（同 Android）。

### loadMessagesWithType count=0 边界

| 端 | 原生 API | 行为 |
|---|---|---|
| Android | `EMConversation.searchMsgFromDB(type, ts, count, sender, direction)` | `count=0` → 返回**空列表** |
| iOS | `EMConversation loadMessagesWithType:timestamp:count:fromUser:searchDirection:completion:`（EMConversation.h:551） | `count=0` → 返回**本地全部消息**（= 不限制数量）|

- 透传实测：`count=0` 时 Android 返回空列表；iOS 返回本地全部消息（本地有残留消息时返回 1 条）。
- case 断言按 Android（空列表）→ iOS 挂；待研发确认 `count=0` 官方语义（0 条 vs 不限制）。

### loadMessageWithId 无效 ID

| 端 | 原生 API | 行为 |
|---|---|---|
| Android | `EMConversation.getMessage(String)` | 无效 ID → 返回 **null**（成功，无错误）|
| iOS | `EMConversation loadMessageWithId:error:` | 无效 ID → 报 **code 3 "Database operation failed"**（原生 DB 错误）|

- 透传实测（重建后确认）：iOS 无效 ID → code 3（DB 操作失败）；Android 无效 ID → null（成功）。
- **两端均为 Conversation 级原生 API**（协议 cmd loadMsgWithId 归属 ConversationManager，语义会话级）：iOS wrapper 用 `Conversation.loadMessageWithId`；Android wrapper 曾用 `ChatManager.getMessage`已改为 `Conversation.getMessage` 对齐 cmd 语义。
- 差异 = 原生（iOS `loadMessageWithId` 无效报 DB error / Android `getMessage` 返回 null）→ 待研发确认 iOS 无效应返回 nil（同 Android）。

### leaveChatRoom（不存在/空 roomId）

| 端 | 原生 API | 行为 |
|---|---|---|
| Android | `EMChatRoomManager.leaveChatRoom(String)`（void，javap）+ `leaveChatRoom(String, EMCallBack)`（回调版） | 空/不存在 → **成功**（回调版反编译：`errCode==0 或 705 → onSuccess` —— **705"聊天室不存在"故意当成功**，幂等语义）|
| iOS | `EMChatroomManager leaveChatroom:completion:` | 空/不存在 → 报 **code 700 "Chatroom ID invalid"** |

- 原生差异（非 wrapper）：Android SDK 对"leave 不存在的聊天室"为**幂等成功**（705 当成功，回调版反编译确认）；iOS 报 700。
- Android wrapper 用 void 版（无回调，直接 `true`）—— 与回调版（705 → onSuccess）结果一致（都成功）；iOS wrapper 透传原生 error（700）。
- 待研发确认：iOS 空/不存在 leave 是否应幂等成功（同 Android），或确认官方语义（705 当成功 vs 700 报错）。

### 聊天室成员加入/退出事件（重新 join / participant 字段）

| 端 | 原生 API / event | 行为 |
|---|---|---|
| Android | `EMChatRoomManagerDelegate.onMemberJoined(String roomId, String participant, String ext)`（ChatRoomManager 回调，wrapper 透传 participant） | 被移除后**重新 join → 无 onRoomMemberJoined**；主动 leaveChatRoom → **无 onRoomMemberExited**（只有被移除 removeChatRoomMembers 才有）；join 事件 participant 为 owner/其他（原生给值，非加入者）|
| iOS | `EMChatroomManagerDelegate userDidJoinChatroom:user:ext:`（ChatroomManager 回调，wrapper 透传 participant=aUsername） | 同 Android：重新 join 无事件；participant 为原生回调值 |

- 透传实测（Android WS-DUMP）：重新 join 无 onRoomMemberJoined；B 主动 leave 无 onRoomMemberExited（被移除才有）；participant 字段为原生给值（第一次 join 显示 owner）。
- wrapper 事件转发均存在（Android onMemberJoined / iOS userDidJoinChatroom），participant 透传原生参数——非 wrapper 问题，原生事件行为差异。

### 聊天室属性空 map（setChatRoomAttributes attributes={}）

| 端 | 原生 API | 行为 |
|---|---|---|
| Android | `EMChatRoomManager asyncSetChatRoomAttributes` | 空 map → **code 110**（原生拒绝）|
| iOS | `EMChatroomManager setChatRoomAttributes` | 空 map → **code 303 "Unknown server error"**（服务端返回）|

- 透传实测：Android 空 map 返回 110（case 通过）；iOS 空 map 返回 303（Unknown server error，服务端）。
- 两端原生/服务端行为不同（110 vs 303），wrapper 均透传——非 wrapper 问题。

### 聊天室操作返回（room vs null）—— wrapper 已修

| 操作 | Android wrapper 返回 | iOS wrapper 处理 |
|---|---|---|
| changeOwner / changeSubject / changeDesc / addAdmin / removeAdmin / removeMembers / block / unblock / mute / unmute | `onSuccess(room toJson)`（返回原生 room） | **已修**：透传原生 `aChatroom toJson`（之前 object:nil 漏透传）|
| addMembersToChatRoomWhiteList / removeMembersFromChatRoomWhiteList | `updateObject(null)`（返回 null） | **已修**：object:nil（之前误透传 room，已对齐 Android null）|

- wrapper 差异（非原生）：iOS 操作返回与 Android 对齐（room 类操作透传原生 room；whiteList 类返回 null）。
- 原生均返回 `EMChatroom`（completion/同步返回），差异在两端 wrapper 的返回策略（Android room/null 分操作），iOS 已对齐。

## 相关文件

```
Android 原生 SDK: im_flutter_sdk_android/android/src/base500/libs/hyphenatechat_5.0.0.jar（javap -c 反编译）
Android native so: /Users/andy_muyu/Documents/5.0/easemob-sdk-5.0.0/libs/armeabi-v7a/libhyphenate.so（strings）
iOS 原生 SDK:     im_flutter_sdk_ios/ios/HyphenateChat.xcframework（strings 提取）
Android wrapper:  im_flutter_sdk_android/android/src/base500/java/com/easemob/im_flutter_sdk/
iOS wrapper:      im_flutter_sdk_ios/ios/Classes/base500/
```
