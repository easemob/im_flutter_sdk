# Web 5.0 适配记录

本文记录 Web 5.0 与 Android/iOS 5.0 的 API、错误码和返回结构差异。


说明：除了error code 为 110 的没有注明修改，其他项在表格最后加上了修改说明，或者不修改的原因。110 为 sdk参数校验失败的统一错误码，不根据某个参数不对再用不同code区分，所以 110的都没有修改。
## UserInfo 模块

| Case | 用例描述 | Android/iOS 预期 | Web 5.0 实测/问题 |
|---|---|---|---|
| `test_user_info_update_own_nickname_length_over_64` | 更新当前用户的超长昵称，验证长度边界错误。<br>原生 API：`updateOwnInfo` → `PUT /metadata/user/{userId}` | `901 / User info exceeds the data length` | HTTP `403`：metadata size exceeds `2048Bytes`；SDK 最终返回 `210` `已修复 901` |
| `test_user_info_fetch_by_id_normal` | 批量查询 A、B 的完整资料。<br>原生 API：`getUserInfoByUserId` → `POST /metadata/user/get` | 返回 A、B 两个资料对象 | 只返回 A；Web 原生只返回实际存在的资料，不补充仅含 userId 的对象。 `已修复`|
| `test_user_info_fetch_by_id_with_type_normal` | 按属性类型批量查询 A、B。<br>原生 API：`getUserInfoByAttribute` → `POST /metadata/user/get` | 返回 A、B 两个资料对象 | 只返回 A；Web 原生只返回实际存在的资料，不补充仅含 userId 的对象。 `已修复`|
| `test_user_info_fetch_by_id_empty_user_ids` | 传入空用户 ID 列表。<br>原生 API：`getUserInfoByUserId({userIds: []})` | `205 / userIds is empty` | `110 / params.userIds is required`；未发 HTTP 请求 |
| `test_user_info_fetch_by_id_user_ids_over_100` | 传入超过 100 个用户 ID。<br>原生 API：`getUserInfoByUserId({userIds})` | `900 / The maximum number of user IDs is exceeded` | HTTP `400`：`exceed allowed batch size 100`；SDK 最终返回 `110` |

Wrapper 只做协议字段和结果结构转换，不构造错误码，也不补造缺失的用户资料。

## Presence 模块

| Case | 用例描述 | Android/iOS 预期 | Web 5.0 实测/问题 |
|---|---|---|---|
| `test_presence_publish_128k_desc` | 发布超过限制长度的 Presence 描述。<br>原生 API：`publishPresence` | `1100 / Presence parameter length is exceeded` | `110 / Invalid request parameters` |
| `test_presence_subscribe_over_100_members` | 订阅超过 100 个用户。<br>原生 API：`subscribePresence` | `1100 / Presence parameter length is exceeded` | `110 / Invalid request parameters` |
| `test_presence_unsubscribe_over_100_members` | 取消订阅超过 100 个用户。<br>原生 API：`unsubscribePresence` | `1100 / Presence parameter length is exceeded` | `110 / Invalid request parameters` |

## Client 模块

| Case | 用例描述 | Android 预期 | Web 5.0 实测/问题 |
|---|---|---|---|
| `test_client_session_sensitive_api_boundaries[renewToken-info0-expected_result0]` | 传入空 Token 更新登录 Token。<br>原生 API：`ChatClient.renewToken` | `104` | `110 / Validation failed: root: token is required` |

## Push 模块

| Case | 用例描述 | Android/iOS 预期 | Web 5.0 实测/问题 |
|---|---|---|---|
| `test_push_global_silent_mode_flow` | 设置并查询全局免打扰配置。<br>原生 API：`fetchSilentModeForAll` | 返回公共字段并带非空 `convId` | 返回全局 `scope` 和 `rule`；不返回 `convId`、`conversationType`、`startTime`、`endTime`、`expireTs` - `全局设置 不需要这些`|
| `test_push_conversation_silent_mode_flow` | 设置、查询并移除单聊免打扰配置。<br>原生 API：`fetchConversationSilentMode`、`removeConversationSilentMode` | 返回 `convId`、`conversationType`、`startTime`、`endTime`、`expireTs` 等公共字段 | 返回 `convId`、`conversationType`；当前提醒类型模式（`remindType=ALL`）查询结果不返回 `startTime`、`endTime`、`expireTs` - `只有设置了对应的免打扰模式才返回`|

## Contact 模块

| Case | 用例描述 | Android 预期 | Web 5.0 实测/问题 |
|---|---|---|---|
| `test_contact_add_nonexistent_user` | 向不存在的用户发起好友申请。<br>原生 API：`addContact` | `204 / User does not exist` | 成功，返回目标用户 ID `已修复 204`|
| `test_contact_add_self` | 添加自己为好友。<br>原生 API：`addContact` | `101 / User ID is invalid` | 成功，返回当前用户 ID `已修复 110`|
| `test_contact_add_empty_user_id` | 传入空用户 ID。<br>原生 API：`addContact` | `101 / User ID is invalid` | `110` |
| `test_contact_delete_contact_nonexistent_user` | 删除不存在的好友。<br>原生 API：`deleteContact` | `204 / User does not exist` | `303` `已修复 204`|
| `test_contact_remark_special_chars_length_101` | 设置长度超限的好友备注。<br>原生 API：`setContactRemark` | `4` | `223` `已修复 4`|
| `test_contact_set_contact_remark_non_friend` | 给非好友设置备注。<br>原生 API：`setContactRemark` | `221` | `223` `已修复 221`|

## ChatRoom 模块

本次 Web 5.0 完整运行：144 个用例中 23 个通过、112 个失败、9 个跳过。失败主要集中在 Join 返回结构、聊天室详情字段和错误码差异；多个回调用例因 Join 前置失败而级联失败。

| Case | 用例描述 | Android/iOS 预期 | Web 5.0 实测/问题 |
|---|---|---|---|
| `test_chatroom_admin_added_and_removed_callbacks`（及其余 9 个回调 Case） | 加入聊天室后验证管理员、禁言、白名单、属性、公告、成员退出等事件。<br>原生 API：`joinChatRoom` 及对应聊天室管理 API | Join 成功后继续验证目标回调 | Join 成功但返回结果缺少 `roomId`，在前置断言处失败，回调逻辑未执行 `待定是否加 roomId`|
| `test_chatroom_fetch_room_info_with_members_from_server` | 加入聊天室并查询聊天室详情及成员。<br>原生 API：`joinChatRoom`、`getChatRoomInfo` | 返回完整聊天室对象 | Join 返回结果缺少 `roomId`；详情结果还缺少部分公共字段，`permissionType` 类型为字符串 `permissionType为联合类型，需要指出哪些必须的字段`|
| `test_chatroom_create_and_fetch_from_server` | 查询服务端创建的聊天室详情。<br>原生 API：`getChatRoomInfo` | 返回完整详情及默认字段 | 缺少 `memberList`、`adminList`、`muteList`、`blockList`、`announcement`、`isAllMemberMuted` 等字段；`permissionType` 类型不一致 `上述字段接口不会返回`|
| `test_chatroom_fetch_public_chat_rooms_from_server_success` | 查询公开聊天室列表。<br>原生 API：`getChatRoomList` | 返回完整聊天室列表 | 列表对象缺少多项公共字段，`memberCount` 实测为 `1`，预期为 `0` `已接口实际返回为准，接口返回没有其他公共字段了`|
| `test_chatroom_fetch_room_info_nonexistent` | 查询不存在的聊天室。<br>原生 API：`getChatRoomInfo` | `700` | `303` - `修改成 705`|
| `test_chatroom_fetch_room_info_from_server_after_destroy` | 销毁后从服务端查询聊天室。<br>原生 API：`getChatRoomInfo` | `700 / do not find this group` | `303` - `修改成 705`|
| `test_chatroom_join_room_nonexistent` | 加入不存在的聊天室。<br>原生 API：`joinChatRoom` | `705` | `606`  - `修改成 705`|
| `test_chatroom_join_room_empty_id` | 使用空 ID 加入聊天室。<br>原生 API：`joinChatRoom` | `700` | `110` |
| `test_chatroom_leave_room_nonexistent` | 离开不存在的聊天室。<br>原生 API：`leaveChatRoom` | 成功/`true` | `606 / The group does not exist`  - `修改成 705`|
| `test_chatroom_leave_room_empty_id` | 使用空 ID 离开聊天室。<br>原生 API：`leaveChatRoom` | `700` | `110` |
| `test_chatroom_fetch_room_info_empty_id` | 使用空 ID 查询聊天室。<br>原生 API：`getChatRoomInfo` | `700` | `110` |
| `test_chatroom_fetch_members_nonexistent_room` | 查询不存在聊天室的成员。<br>原生 API：`getChatRoomMembers` | `700` | `303`  - `修改成 705`|
| `test_chatroom_fetch_members_empty_room_id` | 使用空 ID 查询成员。<br>原生 API：`getChatRoomMembers` | `700` | `110` |
| `test_chatroom_fetch_public_chat_rooms_invalid_paging[0-1]`<br>`[-1-1]`<br>`[1-0]`<br>`[1--1]` | 使用 `pageSize=0` 或负数分页参数查询公开聊天室。<br>原生 API：`getChatRoomList` | 成功返回列表 | 均返回 `110 / Invalid request parameters` `结果复合预期`|
| `test_chatroom_mute_and_unmute_all_members_success` | 全员禁言后查询状态，再解除禁言。<br>原生 API：`muteAllMembers`、`unmuteAllMembers`、`getChatRoomInfo` | 查询到 `isAllMemberMuted=true/false` | 详情对象没有该字段，但状态变化事件存在 `增加muteAllMembers`|
| `test_chatroom_change_owner_success` | 转移聊天室所有者。<br>原生 API：聊天室所有者变更接口 | 成功完成转移 | Web 5.0 没有对应原生 API `暂不提供`|

## Chat / Message 模块

| 字段 | 用例描述 | 涉及 API / 事件 | Web 5.0 实测问题 |
|---|---|---|---|
| `hasDeliverAck` | 发送、查询或修改消息后验证送达状态 | API：`sendMessage`、`getHistoryMessages`、`searchMessages`、`modifyMessage`<br>事件：`onMessage`、`onMessageDelivered`、`onMessageUpdated` | API 和事件消息均没有该字段，不能按消息方向构造 `web端特例`|
| `localTime` | 验证消息本地时间 | API：`sendMessage`、`getHistoryMessages`、`searchMessages`、`modifyMessage`<br>事件：`onMessage`、`onMessageDelivered`、`onMessageUpdated` | 没有等价字段，仅有事件时间戳 `web端特例`|
| `fileStatus` | 创建或发送媒体消息后验证文件状态 | API：`createImageMessage`、`createVideoMessage`、`createVoiceMessage`、`createFileMessage`、`sendMessage`、`getHistoryMessages`<br>事件：`onMessage` | 没有消息字段；上传回调不是该字段的替代 `web端特例`|
| `thumbnailStatus` | 创建或发送图片/视频后验证缩略图状态 | API：`createImageMessage`、`createVideoMessage`、`sendMessage`、`getHistoryMessages`<br>事件：`onMessage`、`onMessageDelivered`、`onMessageUpdated` | 没有消息字段；缩略图 URL/下载回调不是该字段的替代 `web端特例`|

Push 结果缺失这些字段时，Wrapper 不填充默认值，也不使用其他字段推导伪造字段。
