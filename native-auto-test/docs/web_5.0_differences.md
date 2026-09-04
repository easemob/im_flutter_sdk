# Web 5.0 适配记录

本文记录 Web 5.0 与 Android/iOS 5.0 的 API、错误码和返回结构差异。

110 为 sdk参数校验失败的统一错误码，不根据某个参数不对再用不同code区分，所以 110的都没有修改

## UserInfo 模块

| Case | 用例描述 | Android/iOS 预期 | Web 5.0 实测/问题 |
|---|---|---|---|
| `test_user_info_fetch_by_id_empty_user_ids` | 传入空用户 ID 列表。<br>原生 API：`getUserInfoByUserId({userIds: []})` | `205 / userIds is empty` | `110 / params.userIds is required`；未发 HTTP 请求 |
| `test_user_info_fetch_by_id_user_ids_over_100` | 传入超过 100 个用户 ID。<br>原生 API：`getUserInfoByUserId({userIds})` | `900 / The maximum number of user IDs is exceeded` | HTTP `400`：`exceed allowed batch size 100`；SDK 最终返回 `110` |


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
| `test_push_global_silent_mode_flow` | 设置并查询全局免打扰配置。<br>原生 API：`fetchSilentModeForAll` | 返回公共字段并带非空 `convId` | 返回全局 `scope` 和 `rule`；不返回 `convId`、`conversationType`、`startTime`、`endTime`、`expireTs` |
| `test_push_conversation_silent_mode_flow` | 设置、查询并移除单聊免打扰配置。<br>原生 API：`fetchConversationSilentMode`、`removeConversationSilentMode` | 返回 `convId`、`conversationType`、`startTime`、`endTime`、`expireTs` 等公共字段 | 返回 `convId`、`conversationType`；当前提醒类型模式（`remindType=ALL`）查询结果不返回 `startTime`、`endTime`、`expireTs` |

1.不返回 `convId`、`conversationType`、`startTime`、`endTime`、`expireTs` - `全局设置 不需要这些`

2.当前提醒类型模式（`remindType=ALL`）查询结果不返回 `startTime`、`endTime`、`expireTs` - `只有设置了对应的免打扰模式才返回`

## Contact 模块

| Case | 用例描述 | Android 预期 | Web 5.0 实测/问题 |
|---|---|---|---|
| `test_contact_add_empty_user_id`<br>`test_contact_add_self` | 传入空用户 ID，或添加自己为好友。<br>原生 API：`addContact` | `101 / User ID is invalid` | `110` |


## ChatRoom 模块

### 错误码差异

| Case | 用例描述 | Android/iOS 预期 | Web 5.0 实测/问题 |
|---|---|---|---|
| `test_chatroom_fetch_room_info_nonexistent`<br>`test_chatroom_fetch_room_info_from_server_after_destroy`<br>`test_chatroom_fetch_members_nonexistent_room` | 查询不存在或已销毁聊天室的信息、成员。<br>原生 API：`getChatRoomInfo`、`getChatRoomMembers` | `700` | `705` |
| `test_chatroom_leave_room_nonexistent` | 离开不存在的聊天室。<br>原生 API：`leaveChatRoom` | 成功 / `true` | `705 / Chat room does not exist` |



### 返回结构、类型差异

| Case | 用例描述 | Android/iOS 预期 | Web 5.0 实测/问题 |
|---|---|---|---|
| `test_chatroom_admin_added_and_removed_callbacks`（及其余 9 个回调 Case） | 加入聊天室后验证管理员、禁言、白名单、属性、公告、成员退出等事件。<br>原生 API：`joinChatRoom` 及对应聊天室管理 API | Join 成功后继续验证目标回调 | Join 成功但返回结果缺少 `roomId`，在前置断言处失败，回调逻辑未执行 `待定是否加 roomId`|
| `test_chatroom_create_and_fetch_from_server` | 查询服务端创建的聊天室详情。<br>原生 API：`getChatRoomInfo` | 返回完整详情及默认字段 | 缺少 `memberList`、`adminList`、`muteList`、`blockList`、`announcement`、`isAllMemberMuted` 等字段；`permissionType` 类型不一致 `上述字段接口不会返回`|




## Chat 模块

### 错误码差异

| Case | 用例描述 | Android/iOS 预期 | Web 5.0 实测/问题 |
|---|---|---|---|
| `test_chat_recall_message_invalid_id_response` | 使用不存在的消息 ID 撤回消息。<br>原生 Web SDK：`ChatManager.recallMessage` | `code=500`；两端文案可能不同，Case 只断言错误码 | Web 原生返回 `1 / message not exist` |
| `test_chat_add_reaction_invalid_id_response` | 使用不存在的消息 ID 添加 Reaction。<br>原生 Web SDK：`ChatManager.addReaction` | `303 / msgbody is not_found` | Web 原生返回 `210 / Access forbidden` |
| `test_chat_ack_message_read_invalid_msg_id` | 使用不存在的消息 ID 发送单聊已读回执。<br>原生 Web SDK：`ChatManager.sendMessageReadReceipts` | `110 / messages is empty` | Web 原生 sendMessageReadReceipts() 成功后返回 null|
| `test_chat_fetch_history_messages_empty_conv_id`<br>`test_chat_fetch_history_messages_by_options_empty_conv_id` | 使用空会话 ID查询历史消息。<br>原生 Web SDK：`ChatManager.getHistoryMessages` | `110 / Invalid parameter` | Web 原生返回成功结果：`{cursor:"", hasMore:false, list:[]}`，不是包含 `code/description` 的错误对象 |
| `test_chat_ack_conversation_read_invalid_conv_id`<br>`test_chat_ack_conversation_read_empty_conv_id` | 使用无效或空会话 ID 回执会话已读。<br>原生 Web SDK：`ChatManager.clearConversationUnreadMessageCount` | `110 / conversation not found` | Web 原生方法成功结束并返回 `null`，未返回对应错误码和文案 |


### 消息字段差异


| 字段 | 用例描述 | 涉及 API / 事件 | Web 5.0 实测问题 |
|---|---|---|---|
| `hasDeliverAck（web端特例）` | 发送、查询或修改消息后验证送达状态 | API：`sendMessage`、`getHistoryMessages`、`searchMessages`、`modifyMessage`<br>事件：`onMessage`、`onMessageDelivered`、`onMessageUpdated` | API 和事件消息均没有该字段，不能按消息方向构造 |
| `needReadReceipt` | 创建或接收消息时验证是否请求已读回执 | API：`sendMessage`、`getHistoryMessages`<br>事件：`onMessage` | Android 原生 `EMMessage.isNeedReadReceipt()`、iOS 原生 `EMChatMessage.isNeedReadReceipt` 默认均为 `false`；Web 5.0 字段为可选，未设置时可能不返回 |
| `deliverOnlineOnly` | 创建或接收消息时验证是否仅在线投递 | API：`sendMessage`、`getHistoryMessages`<br>事件：`onMessage` | Android/iOS SDK 默认序列化 `deliverOnlineOnly=false`；Web 5.0 字段为可选，未设置时可能不返回 |
| `localTime（web端特例） ` | 验证消息本地时间 | API：`sendMessage`、`getHistoryMessages`、`searchMessages`、`modifyMessage`<br>事件：`onMessage`、`onMessageDelivered`、`onMessageUpdated` | 没有等价字段，仅有事件时间戳 |
| `fileStatus（web端特例）` | 创建或发送媒体消息后验证文件状态 | API：`createImageMessage`、`createVideoMessage`、`createVoiceMessage`、`createFileMessage`、`sendMessage`、`getHistoryMessages`<br>事件：`onMessage` | 没有消息字段；上传回调不是该字段的替代 |
| `thumbnailStatus（web端特例）` | 创建或发送图片/视频后验证缩略图状态 | API：`createImageMessage`、`createVideoMessage`、`sendMessage`、`getHistoryMessages`<br>事件：`onMessage`、`onMessageDelivered`、`onMessageUpdated` | 没有消息字段；缩略图 URL/下载回调不是该字段的替代 |

结果缺失这些字段时，Wrapper 不填充默认值，也不使用其他字段推导伪造字段。

## Group 模块

### 错误码差异

| Case | 用例描述 | Android/iOS 预期 | Web 5.0 实测/问题 |
|---|---|---|---|
| `test_group_upload_shared_file_nonexistent_group` | 向不存在的群上传共享文件。<br>原生 API：`uploadGroupSharedFile` | `600` | `402` |
| `test_group_download_shared_file_nonexistent_group_current_behavior` | 从不存在的群下载共享文件。<br>原生 API：`downloadGroupSharedFile` | `600` | `303` |
| `test_group_is_member_in_white_list_and_mute_list_nonexistent_group`（白名单查询） | 查询不存在群的白名单成员状态。<br>原生 API：`isMemberInWhiteListFromServer` | `600 / do not find this group` | 成功返回 `result=true` |
| `test_group_is_member_in_white_list_and_mute_list_nonexistent_group`（禁言查询） | 查询不存在群的禁言列表成员状态。<br>原生 API：`isMemberInGroupMuteList` | `600 / do not find this group` | `303 / REST business error: checkIfInGroupMuteList failed (group_error)` |
| `test_group_request_to_join_public_group_nonexistent_group` | 申请加入不存在的公开群。<br>原生 API：`requestToJoinPublicGroup` | `600 / do not find this group` | `606` |
| `test_group_accept_join_application_nonexistent_group` | 接受不存在群的入群申请。<br>原生 API：`acceptJoinApplication` | `600 / do not find this group` | `303` |
| `test_group_decline_join_application_nonexistent_group` | 拒绝不存在群的入群申请。<br>原生 API：`declineJoinApplication` | `600 / do not find this group` | `303` |
| `test_group_accept_invitation_from_group_without_pending_invite`<br>`test_group_decline_invitation_from_group_without_pending_invite` | 在没有待处理邀请时接受或拒绝群邀请。<br>原生 API：`acceptInvitationFromGroup`、`declineInvitationFromGroup` | `600 / does not exist` | `303` |
| `test_group_message_ack_boundary_methods` | 使用无效消息 ID 和群 ID 发送群已读回执。<br>原生 API：`ackGroupMessageRead` → `sendMessageReadReceipts` | `110 / messages is empty` | `code=1`；错误码来自 Web 原生 ACK 调用，Wrapper 仅将成功结果映射为 `true` |
| `test_group_update_announcement_nonexistent_group` | 更新不存在群的公告。<br>原生 API：`updateGroupAnnouncement` | `600 / do not find this group` | `303` |
| `test_group_get_announcement_nonexistent_group` | 查询不存在群的公告。<br>原生 API：`getGroupAnnouncement` | `600 / do not find this group` | `606` |
| `test_group_get_group_file_list_from_server_nonexistent_group`（`pageNum/pageSize` 边界） | 查询不存在群的共享文件列表。<br>原生 API：`getGroupFileListFromServer` | `600 / do not find this group` | `606` |
| `test_group_inviter_user_nonexistent_group` | 向不存在的群邀请成员。<br>原生 API：`inviterUser` | `600 / do not find this group` | `603` |
| `test_group_create_group_max_count_less_than_invite_members` | 创建群时邀请成员数超过群容量。<br>原生 API：`createGroup` | `604 / The group member capacity is reached` | `4` |
| `test_group_create_group_invite_members_abnormal_inputs`（包含不存在用户） | 创建群时邀请不存在的用户。<br>原生 API：`createGroup` | `600` | `204` |
| `test_group_destroy_group_nonexistent` | 销毁不存在的群。<br>原生 API：`destroyGroup` | `600 / do not find this group` | `603` |


### 参数差异

| Case | 用例描述 | Android/iOS 预期 | Web 5.0 实测/问题 |
|---|---|---|---|
| 空初始成员相关用例 | 传入 `invite_members=[]`，创建仅包含群主的群。<br>原生 API：`GroupManager.createGroup` | 可以创建只有群主的群 | `110 / params.memberIds is required`；Wrapper 已将 `inviteMembers` 映射为 `memberIds`，Web 原生不接受空初始成员列表。 |

### 返回结构、类型差异

| Case | 用例描述 | Android/iOS 预期 | Web 5.0 实测/问题 |
|---|---|---|---|
| `test_group_member_count_local_then_server_sync`<br>`test_group_create_group`<br>`test_group_get_group`<br>`test_group_get_group_from_server`<br>群元数据、成员列表、成员属性、已加入群列表、服务端列表、角色权限、群主转移及共享文件成功相关用例 | 创建群后验证群详情、成员数量、成员列表或后续群操作。<br>原生 API：`GroupManager.createGroup` | 创建成功响应中可直接校验完整群对象，包括 `name`、`owner`、`desc`、`ext`、`maxUserCount`、`memberCount`、`permissionType` 等字段 | 创建成功结果只包含 `groupId`，其余完整群详情字段不存在。失败发生在公共 `create_group()` 的完整群快照断言，后续业务操作未执行。 |

### `getGroupInfo` 字段缺失

| 涉及用例 | 用例描述 | Android/iOS 返回 | Web 5.0 原生返回 |
|---|---|---|---|
| `test_group_get_group_from_server`<br>`test_group_member_count_local_then_server_sync` | 查询服务端群详情，并校验群公告、成员及群管理列表。<br>原生 API：`GroupManager.getGroupInfo` | `EMGroup` 序列化结果包含 `announcement`、`memberList`、`adminList`、`muteList`、`blockList` | `GroupDetail` 完全没有上述字段，也没有同义字段；Web 原生未在 `getGroupInfo` 返回这些列表或公告内容。 |

Web 原生 `createGroup` 返回的是群 ID，不是完整 `GroupInfo`；完整群详情应通过独立的 `getGroupInfo` 查询验证，不能从 `createGroup` 返回值补造。
