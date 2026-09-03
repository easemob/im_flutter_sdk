## Chat 模块


### 错误码差异

| Case | 用例描述 | Android/iOS 预期 | Web 5.0 实测/问题 |
|---|---|---|---|
| `test_chat_recall_message_invalid_id_response` | 使用不存在的消息 ID 撤回消息。<br>原生 Web SDK：`ChatManager.recallMessage` | `code=500`；两端文案可能不同，Case 只断言错误码 | Web 原生返回 `1 / message not exist` |
| `test_chat_add_reaction_invalid_id_response` | 使用不存在的消息 ID 添加 Reaction。<br>原生 Web SDK：`ChatManager.addReaction` | `303 / msgbody is not_found` | Web 原生返回 `210 / Access forbidden` |
| `test_chat_ack_message_read_invalid_msg_id` | 使用不存在的消息 ID 发送单聊已读回执。<br>原生 Web SDK：`ChatManager.sendMessageReadReceipts` | `110 / messages is empty` | Web 原生 sendMessageReadReceipts() 成功后返回 null|
| `test_chat_fetch_history_messages_empty_conv_id`<br>`test_chat_fetch_history_messages_by_options_empty_conv_id` | 使用空会话 ID查询历史消息。<br>原生 Web SDK：`ChatManager.getHistoryMessages` | `110 / Invalid parameter` | Web 原生返回成功结果：`{cursor:"", hasMore:false, list:[]}`，不是包含 `code/description` 的错误对象 |
| `test_chat_ack_conversation_read_invalid_conv_id`<br>`test_chat_ack_conversation_read_empty_conv_id` | 使用无效或空会话 ID 回执会话已读。<br>原生 Web SDK：`ChatManager.clearConversationUnreadMessageCount` | `110 / conversation not found` | Web 原生方法成功结束并返回 `null`，未返回对应错误码和文案 |


## Group 模块

### 错误码差异

| Case | 用例描述 | Android/iOS 预期 | Web 5.0 实测/问题 |
|---|---|---|---|
| `test_group_upload_shared_file_nonexistent_group` | 向不存在的群上传共享文件。<br>原生 Web SDK：`GroupManager.uploadGroupSharedFile` | `600` | `402` |
| `test_group_download_shared_file_nonexistent_group_current_behavior` | 从不存在的群下载共享文件。<br>原生 Web SDK：`GroupManager.downloadGroupSharedFile` | `600` | `303` |
| `test_group_is_member_in_white_list_and_mute_list_nonexistent_group`（白名单查询） | 查询不存在群的白名单成员状态。<br>原生 Web SDK：`GroupManager.checkIfInGroupAllowList` | `600 / do not find this group` | 成功返回 `result=true` |
| `test_group_is_member_in_white_list_and_mute_list_nonexistent_group`（禁言查询） | 查询不存在群的禁言列表成员状态。<br>原生 Web SDK：`GroupManager.checkIfInGroupMuteList` | `600 / do not find this group` | `303 / REST business error: checkIfInGroupMuteList failed (group_error)` |
| `test_group_request_to_join_public_group_nonexistent_group` | 申请加入不存在的公开群。<br>原生 Web SDK：`GroupManager.joinGroup` | `600 / do not find this group` | `606` |
| `test_group_accept_join_application_nonexistent_group` | 接受不存在群的入群申请。<br>原生 Web SDK：`GroupManager.acceptGroupJoinRequest` | `600 / do not find this group` | `303` |
| `test_group_decline_join_application_nonexistent_group` | 拒绝不存在群的入群申请。<br>原生 Web SDK：`GroupManager.rejectGroupJoinRequest` | `600 / do not find this group` | `303` |
| `test_group_accept_invitation_from_group_without_pending_invite`<br>`test_group_decline_invitation_from_group_without_pending_invite` | 在没有待处理邀请时接受或拒绝群邀请。<br>原生 Web SDK：`GroupManager.acceptInvitation`、`GroupManager.rejectInvitation` | `600 / does not exist` | `303` |
| `test_group_message_ack_boundary_methods` | 使用无效消息 ID 和群 ID 发送群已读回执。<br>原生 Web SDK：`ChatManager.sendMessageReadReceipts` | `110 / messages is empty` | `code=1` |
| `test_group_update_announcement_nonexistent_group` | 更新不存在群的公告。<br>原生 Web SDK：`GroupManager.updateGroupAnnouncement` | `600 / do not find this group` | `303` |
| `test_group_get_announcement_nonexistent_group` | 查询不存在群的公告。<br>原生 Web SDK：`GroupManager.getGroupAnnouncement` | `600 / do not find this group` | `606` |
| `test_group_get_group_file_list_from_server_nonexistent_group`（`pageNum/pageSize` 边界） | 查询不存在群的共享文件列表。<br>原生 Web SDK：`GroupManager.getGroupSharedFileList` | `600 / do not find this group` | `606` |
| `test_group_inviter_user_nonexistent_group` | 向不存在的群邀请成员。<br>原生 Web SDK：`GroupManager.inviteUsersToGroup` | `600 / do not find this group` | `603` |
| `test_group_create_group_max_count_less_than_invite_members` | 创建群时邀请成员数超过群容量。<br>原生 Web SDK：`GroupManager.createGroup` | `604 / The group member capacity is reached` | `4` |
| `test_group_create_group_invite_members_abnormal_inputs`（包含不存在用户） | 创建群时邀请不存在的用户。<br>原生 Web SDK：`GroupManager.createGroup` | `600` | `204` |
| `test_group_destroy_group_nonexistent` | 销毁不存在的群。<br>原生 Web SDK：`GroupManager.destroyGroup` | `600 / do not find this group` | `603` |


### 参数差异

| Case | 用例描述 | Android/iOS 预期 | Web 5.0 实测/问题 |
|---|---|---|---|
| 空初始成员相关用例 | 传入 `invite_members=[]`，创建仅包含群主的群。<br>原生 Web SDK：`GroupManager.createGroup` | 可以创建只有群主的群 | `110 / params.memberIds is required` |

### 返回结构、类型差异

| Case | 用例描述 | Android/iOS 预期 | Web 5.0 实测/问题 |
|---|---|---|---|
| `test_group_member_count_local_then_server_sync`<br>`test_group_create_group`<br>`test_group_get_group`<br>`test_group_get_group_from_server`<br>群元数据、成员列表、成员属性、已加入群列表、服务端列表、角色权限、群主转移及共享文件成功相关用例 | 创建群后验证群详情、成员数量、成员列表或后续群操作。<br>原生 Web SDK：`GroupManager.createGroup`、`GroupManager.getGroup`、`GroupManager.getGroupInfo` | 创建成功响应中可直接校验完整群对象，包括 `name`、`owner`、`desc`、`ext`、`maxUserCount`、`memberCount`、`permissionType` 等字段 | 创建成功结果只包含 `groupId`，其余完整群详情字段不存在。失败发生在公共 `create_group()` 的完整群快照断言，后续业务操作未执行。 |

### `getGroupInfo` 字段缺失

| 涉及用例 | 用例描述 | Android/iOS 返回 | Web 5.0 原生返回 |
|---|---|---|---|
| `test_group_get_group_from_server`<br>`test_group_member_count_local_then_server_sync`<br>其他通过 `GroupManager.getGroupInfo` 做完整群快照校验的用例 | 查询服务端群详情，并校验群公告、成员及群管理列表。<br>原生 Web SDK：`GroupManager.getGroupInfo` | `EMGroup` 序列化结果包含 `announcement`、`memberList`、`adminList`、`muteList`、`blockList` | `GroupDetail` 完全没有上述字段，也没有同义字段；Web 原生未在 `getGroupInfo` 返回这些列表或公告内容 |

Web 原生 `createGroup` 返回的是群 ID，不是完整 `GroupInfo`；完整群详情应通过独立的 `getGroupInfo` 查询验证，不能从 `createGroup` 返回值补造。
