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

### getCurrentDeviceId（两端原生 API 不同 + 语义不等价）

| 端 | 原生 API | 返回 | 处理 |
|---|---|---|---|
| Android | `EMClient.getDeviceInfo()`（5.0 新构建） | `{hid(用户ID), os, os-version}`（用户/系统信息） | 透传原生（原 wrapper 手动造 DeviceUuidFactory —— 已改为调原生）|
| iOS | `EMClient.getDeviceConfig:` | `{resource, deviceUUID, deviceName}`（设备配置） | 透传原生 |

- 协议 `getCurrentDeviceId`（官方遗留名，不准确）—— 两端原生【没有语义一致对应】：
  - Android = 用户/系统信息（hid/os/os-version，不是设备 ID；原生无"当前设备 UUID"方法）
  - iOS = 设备配置（resource/deviceUUID/deviceName）
- wrapper：两端都透传原生（不再造）—— 返回结构不同 → case 只断"result 非空 dict"
- 文档（protocol-android-ios-5.0-pure-native-map.md）标注：该移出"仅 iOS"段（Android 有 getDeviceInfo 原生）→ "名称可映射，但语义或行为不完全等价"段
- 若要求原生对齐：研发可让两端返回同一语义（设备 ID/信息）

### 移除类空 members（removeChatRoomMembers / unMute / unBlock / removeWhiteList）

| 端 | 原生行为 | 处理 |
|---|---|---|
| Android | 移除类空 members → 【无本地校验】→ 发服务端 → 服务端不可达时慢响应（>60s）/ 最终 300 "Server is unreachable"（WS-DUMP 确认） | 透传（wrapper 无问题）|
| iOS | 未验证 | — |

- 原生校验覆盖【不一致】：添加类空（addWhiteList/mute/block）→ native 层本地校验（110/602，快）；移除类空 → 不发本地校验（发服务端 → 慢/300）
- 定层：原生 SDK 缺陷（移除类空应本地校验 110 "usernames is null or empty!"，同添加类）—— 非环境（其他操作网络通）、非 wrapper（透传）
- case：4 个移除类空 case 期望 300（之前实测网络错误记）—— 原生补校验后 case 期望应改 110（同添加类）
- 给研发：Android 移除类空 members 补本地校验（110）

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

### 群自动接受邀请事件（onGroupAutoAcceptInvitation 只回投主端）

| 端 | 原生 API / event | 行为 |
|---|---|---|
| Android | `EMGroupChangeListener.onAutoAcceptInvitationFromGroup`（wrapper 转发 onGroupAutoAcceptInvitation） | B 设 autoAcceptGroupInvitation=true 后接受邀请：**B 主端收到** onGroupAutoAcceptInvitation；**B 副端（同账号另一设备）收不到**（只有 onGroupInvitationReceived + onGroupMembersJoined）|  
| iOS | 未验证 | — |

- 透传实测（Android WS-DUMP，run-f2506d85eb56）：B 主端 eventId=7 收到 `onGroupAutoAcceptInvitation{groupId, inviter, inviteMessage}`；B 副端全程无该事件（但收到 onGroupMembersJoined）。
- 定层：原生事件派发行为（auto-accept 事件不同步副端；成员加入事件会广播到全部在线端）—— 非 wrapper（wrapper 转发正常）。
- case：副端不再期待 auto-accept 事件，改由成员加入事件验证 auto-accept 生效。
- 若要求原生对齐：研发确认 auto-accept 回执是否应同步到同账号全部在线端（同 onGroupMembersJoined）。

### 环境说明：空 members 成员管理（服务端不可达慢响应）

| 场景 | 现象 | 定层 |
|---|---|---|
| removeChatRoomMembers / unMute / unBlock / removeWhiteList（空 members） | 响应 >60s（服务端不可达 → SDK 重试）→ pytest 30s 超时 | 环境/服务端（原生最终返回 300 "Server is unreachable"，WS-DUMP 确认）|

- 非 SDK 逻辑（原生响应 300 正确）；服务端不可达时 SDK 重试导致响应极慢（>60s，不可控）—— 非原生差异，非 wrapper。

### 送达回执（onMessageDelivered：原生回调在，服务端不发送 DELIVER_ACK）

| 端 | 原生 API / event | 行为 |
|---|---|---|
| Android | `EMMessageListener.onMessageDelivered(List<EMMessage>)`（javap 存在）+ wrapper 转发（ChatManagerWrapper:1247）+ Dart key `onMessagesDelivered` | **服务端不发送 DELIVER_ACK**：离线投递场景实测 60s 未收到（events=[]）；在线场景现有测试实证不触发（设置 requireDeliveryAck 也不触发）|
| iOS | 未验证 | — |

- 5.0 原生回调**保留**（javap 实证）、wrapper 转发正常、Dart key 存在 —— 但服务端不再发送送达回执（DELIVER_ACK），实测不触发。
- 官方 5.0 API 变更文档（第 7 节）只列了已读回执迁移（`onMessageRead` → `onMessageReadReceipts`），**未列送达回执变更** —— 文档遗漏（送达回执实际不可用）。
- 测试：送达回执 case skip（对齐现有测试）；官方 e2e_test 离线测试的 `onMessagesDelivered` 部分已删除/skip。
- 待研发：确认服务端是否下线 DELIVER_ACK 机制，并在 API 变更文档补充说明。

### 群组已知原生缺陷（skip 记录，2026-08-14 实证）

以下 case 设计完整（步骤+预期按规范），因原生缺陷 skip 等待修复；本次逐一去 skip 验证，缺陷均仍存在：

| case（skip） | 原生缺陷（实证） | 建议 |
|---|---|---|
| invitation_state_matrix ×2 | 邀请处理**未校验 inviter**：错误 inviter 能 accept/decline 并消耗邀请，正确 inviter 随后无法处理（expected=错误 inviter 不得处理，actual=已处理） | 原生补 inviter 校验 |
| join_application admin-accept | 群主 admin 接受申请时被**报为 group owner**（owner 字段错误） | 原生修正角色上报 |
| join_requests decline | `declineInvitationFromGroup` 拒绝后邀请方**收不到 onInvitationDeclined 事件**（actual=[]，服务端成员仍 1） | 原生补拒绝事件派发 |
| style public-open | `requestToJoinPublicGroup` 对 PublicOpenJoin 群**自动入群**（不等待审批） | 契约确认 |
| style private-owner-admin ×2 | style 0（PrivateOnlyOwnerInvite）**管理员也能邀请**（expected=603 invite is not allowed，actual=成功入群） | 原生补权限校验 |
| member_count_local（偶发） | `addMembers` 后本地 `memberCount` 与服务端不同步（3 次跑 1 次复现，local_before≠server） | 原生确认本地人数同步时机 |

## 相关文件

```
Android 原生 SDK: im_flutter_sdk_android/android/src/base500/libs/hyphenatechat_5.0.0.jar（javap -c 反编译）
Android native so: /Users/andy_muyu/Documents/5.0/easemob-sdk-5.0.0/libs/armeabi-v7a/libhyphenate.so（strings）
iOS 原生 SDK:     im_flutter_sdk_ios/ios/HyphenateChat.xcframework（strings 提取）
Android wrapper:  im_flutter_sdk_android/android/src/base500/java/com/easemob/im_flutter_sdk/
iOS wrapper:      im_flutter_sdk_ios/ios/Classes/base500/
```
