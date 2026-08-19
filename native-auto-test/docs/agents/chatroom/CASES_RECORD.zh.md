# ChatRoom 模块 Cases 总记录（按 API）

— 说明
- 本文件记录 ChatRoom 模块已覆盖用例（按 API 组织）。
- 每条 case 以全局序号编号；统计按“当前记录条目数”计算。
- 暂缓与 skip 项统一写 `CASES_DEFERRED.zh.md`。
- Allure：ChatRoom 活动用例已覆盖准备、管理动作或查询、结果/事件验证等业务步骤；5.0 移除的客户端创建/销毁用例保留明确 skip 原因。

## createChatRoom

正常 cases
1. `tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_create_and_fetch_from_server`
   使用 REST 创建聊天室后，SDK 拉取详情，校验 `roomId/owner/name/maxUsers/memberCount` 等核心字段。

异常 cases
2. `tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_create_room_via_sdk_without_permission`
   当前普通 session 用户直调 SDK `createChatRoom` 返回无权限错误，冻结实测语义：`code=703`，`description` 包含 `you have no permission to do this.`。

## joinChatRoom

正常 cases
3. `tests/chatroom/test_chatroom_members.py::test_chatroom_join_public_chatroom_success`
   B 加入公开聊天室，当前同步响应返回聊天室对象（`roomId/memberCount/isAllMemberMuted/isInWhitelist`），随后通过服务端成员列表确认 B 已加入。
4. `tests/chatroom/test_chatroom_members.py::test_chatroom_join_with_ext_member_joined_callback`
   当前已标记 xfail：`user_c` 创建聊天室，B 先进入聊天室保持在线，A 随后携带 ext 加入；实测两端均未收到 `onMemberJoinedFromChatRoom`，暂不作为通过覆盖。
5. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_join_room_nonexistent_current_behavior`
   当前实测：传入随机不存在 roomId 返回 `705/Chat room does not exist`，按现网行为冻结。
6. `tests/chatroom/test_chatroom_member_basics.py::test_chatroom_join_then_get_local_room_and_all_rooms`
   B 加入聊天室后，校验本地单聊天室缓存返回目标聊天室核心字段；`getAllChatRooms` 当前仅冻结返回 list 语义。
7. `tests/chatroom/test_chatroom_member_basics.py::test_chatroom_join_leave_other_rooms_option_controls_existing_rooms`
   覆盖 `joinChatRoom.leaveOtherRooms` 语义：`false` 时 B 加入新聊天室后仍保留旧聊天室；`true` 时 B 加入新聊天室后应退出旧聊天室。通过服务端成员列表断言旧/新房间成员关系；`getAllChatRooms` 当前仅冻结 list 结构。

异常 cases
8. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_join_room_empty_id`
   roomId 为空字符串，冻结错误语义：`code=700`，`description` 包含 `Chat room ID is invalid`。

## leaveChatRoom

正常 cases
7. `tests/chatroom/test_chatroom_member_basics.py::test_chatroom_leave_room_updates_local_cache`
   B 加入后主动离开聊天室，校验 `leaveChatRoom` 返回，并通过成员列表确认 B 已不在聊天室。

异常 cases
8. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_leave_room_nonexistent`
   当前实测：传入随机不存在 roomId 返回成功 `result=true`，先按现网行为冻结。
9. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_leave_room_empty_id`
   roomId 为空字符串，当前真实返回成功 `result=true`。

## fetchPublicChatRoomsFromServer

正常 cases
10. `tests/chatroom/test_chatroom_server_state.py::test_chatroom_fetch_public_chat_rooms_from_server_success`
   拉取公开聊天室列表，校验返回结构 `result.count/result.list`。

异常 cases
11. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_public_chat_rooms_invalid_paging[0-1]`
    `pageNum=0`，当前行为为成功返回公开列表结构，校验 `count>=0` 与列表条目关键字段集合。
12. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_public_chat_rooms_invalid_paging[-1-1]`
    `pageNum=-1`，当前行为为成功返回公开列表结构，校验同上。
13. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_public_chat_rooms_invalid_paging[1-0]`
    `pageSize=0`，当前行为为成功返回公开列表结构，校验同上。
14. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_public_chat_rooms_invalid_paging[1--1]`
    `pageSize=-1`，当前行为为成功返回公开列表结构，校验同上。

## fetchChatRoomInfoFromServer

正常 cases
15. `tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_create_and_fetch_from_server`
    创建后立即查询详情，校验返回与创建结果一致。
16. `tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_fetch_room_info_from_server_after_destroy`
    删除聊天室后再次查询详情，冻结销毁后的服务端不可查语义。
17. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_change_subject_and_description_success`
    修改聊天室名称与描述后查询详情，校验 `name/desc` 与刚更新值一致。
18. `tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_fetch_room_info_with_members_from_server`
    B 加入聊天室后，owner 使用 `fetchMembers=true` 拉取聊天室详情，校验 `memberCount=2`、`memberList` 返回普通成员且包含 B、不包含 owner。

异常 cases
19. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_room_info_nonexistent`
    查询随机不存在 roomId，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
20. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_room_info_empty_id`
    roomId 为空字符串，冻结错误语义：`code=700`，`description` 包含 `Chat room ID is invalid`。

## getChatRoom / getAllChatRooms

正常 cases
21. `tests/chatroom/test_chatroom_member_basics.py::test_chatroom_join_then_get_local_room_and_all_rooms`
    加入聊天室后，校验 `getChatRoom` 返回目标聊天室核心字段，`getAllChatRooms` 当前返回 list。
22. `tests/chatroom/test_chatroom_member_basics.py::test_chatroom_leave_room_updates_local_cache`
    离开聊天室后，通过 `fetchChatRoomMembers` 校验离开成员不再出现在服务端成员列表中。
23. `tests/chatroom/test_chatroom_member_basics.py::test_chatroom_get_local_room_empty_id_returns_none`
    本地查询空 roomId，冻结当前行为：`getChatRoom` 返回 `null`。
24. `tests/chatroom/test_chatroom_member_basics.py::test_chatroom_get_local_room_nonexistent_returns_placeholder`
    本地查询不存在 roomId，冻结当前行为：`getChatRoom` 返回 `null`。
25. `tests/chatroom/test_chatroom_member_basics.py::test_chatroom_get_all_local_rooms_returns_list`
    未指定房间时调用 `getAllChatRooms`，校验返回 list，且已有条目均包含 `roomId`。

异常 cases
26. 暂无。

## fetchChatRoomMembers

正常 cases
27. `tests/chatroom/test_chatroom_member_basics.py::test_chatroom_fetch_members_after_join_success`
    B 加入聊天室后拉取成员列表，校验 cursor result 结构，并确认加入成员在 `result.list` 中。
28. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_remove_member_success`
    B 加入聊天室后，owner 将 B 踢出，并通过成员列表确认 B 已不在聊天室。
29. `tests/chatroom/test_chatroom_member_basics.py::test_chatroom_fetch_members_with_cursor_pagination`
    B 加入聊天室后，使用 `pageSize=1` 拉取成员分页，校验首屏数量不超过 1，并确认普通成员列表包含 B、不包含 owner。

异常 cases
30. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_members_nonexistent_room`
    随机不存在 roomId 拉取聊天室成员，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
31. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_members_empty_room_id`
    roomId 为空字符串拉取聊天室成员，冻结错误语义：`code=700`，`description` 包含 `Chat room ID is invalid`。
32. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_fetch_members_invalid_paging[0-20]`
    `fetchChatRoomMembers` 传入 `pageNum=0/pageSize=20`，冻结实测容错语义：仍返回 cursor 结构且成员列表包含已加入的 B。
33. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_fetch_members_invalid_paging[-1-20]`
    `fetchChatRoomMembers` 传入 `pageNum=-1/pageSize=20`，冻结实测容错语义：仍返回 cursor 结构且成员列表包含已加入的 B。
34. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_fetch_members_invalid_paging[1-0]`
    `fetchChatRoomMembers` 传入 `pageNum=1/pageSize=0`，冻结实测容错语义：仍返回 cursor 结构且成员列表包含已加入的 B。
35. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_fetch_members_invalid_paging[1--1]`
    `fetchChatRoomMembers` 传入 `pageNum=1/pageSize=-1`，冻结实测容错语义：仍返回 cursor 结构且成员列表包含已加入的 B。

## changeChatRoomSubject / changeChatRoomDescription

正常 cases
36. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_change_subject_and_description_success`
    owner 修改聊天室名称和描述，随后拉取聊天室详情确认 `name/desc` 已更新。
37. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_change_subject_empty_success`
    `changeChatRoomSubject` 传入空字符串名称，冻结实测边界：允许置空，返回完整聊天室对象且 `name=""`。
38. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_change_description_empty_success`
    `changeChatRoomDescription` 传入空字符串描述，冻结实测边界：允许置空，返回完整聊天室对象且 `desc=""`。

异常 cases
39. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[changeChatRoomSubject]`
    不存在 roomId 修改聊天室名称，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
40. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[changeChatRoomDescription]`
    不存在 roomId 修改聊天室描述，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
41. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_change_subject_too_long`
    `changeChatRoomSubject` 传入 1025 字符名称，冻结模拟器实测返回：`code=703`，`description=title cannot exceed to 1024`。
42. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_change_description_too_long`
    `changeChatRoomDescription` 传入 4097 字符描述，冻结模拟器实测返回：`code=703`，`description=desc cannot exceed to 4096`。


## updateChatRoomAnnouncement / fetchChatRoomAnnouncement

正常 cases
43. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_update_and_fetch_announcement_success`
    更新聊天室公告后立即拉取公告，校验 `fetchChatRoomAnnouncement` 返回刚更新的内容。
44. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_update_announcement_empty`
    `updateChatRoomAnnouncement` 传入空字符串公告，冻结实测边界：允许置空，返回 `result=True`。

异常 cases
45. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[updateChatRoomAnnouncement]`
    不存在 roomId 更新聊天室公告，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
46. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[fetchChatRoomAnnouncement]`
    不存在 roomId 拉取聊天室公告，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。

## addMembersToChatRoomWhiteList / removeMembersFromChatRoomWhiteList / fetchChatRoomWhiteListFromServer

正常 cases
47. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_add_fetch_remove_white_list_success`
    B 加入聊天室后，owner 将 B 加入白名单并拉取确认；随后移除 B 并再次拉取确认。
48. `tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_member_white_list_check_reflects_server_state`
    B 加入聊天室后，owner 添加/移除 B 白名单，B 侧调用 `isMemberInChatRoomWhiteListFromServer` 确认状态从 `false -> true -> false`。

异常 cases
49. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[addMembersToChatRoomWhiteList]`
    不存在 roomId 添加聊天室白名单，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
50. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[removeMembersFromChatRoomWhiteList]`
    不存在 roomId 移除聊天室白名单，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
51. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[fetchChatRoomWhiteListFromServer]`
    不存在 roomId 拉取聊天室白名单，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
52. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[addMembersToChatRoomWhiteList-members-110-usernames is null or empty!]`
    `addMembersToChatRoomWhiteList` 传入空成员列表，冻结模拟器实测返回：`code=110`，`description=usernames is null or empty!`。
53. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[removeMembersFromChatRoomWhiteList-members-300-Server is unreachable]`
    `removeMembersFromChatRoomWhiteList` 传入空成员列表，冻结模拟器实测返回：`code=300`，`description=Server is unreachable`。
54. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[addMembersToChatRoomWhiteList-info3-expected3]`
    `addMembersToChatRoomWhiteList` 传入不存在用户，冻结模拟器实测返回：`code=703`，`description=users [nonexistent_chatroom_user_999999] are not members of this group!`。
55. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[removeMembersFromChatRoomWhiteList-info4-None]`
    `removeMembersFromChatRoomWhiteList` 传入不存在用户，冻结实测幂等语义：返回 `result=None`。


## muteChatRoomMembers / unMuteChatRoomMembers / fetchChatRoomMuteList

正常 cases
56. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_mute_fetch_unmute_member_success`
    B 加入聊天室后，owner 禁言 B 并拉取禁言列表确认；随后解除禁言并再次拉取确认。
57. `tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_member_mute_list_check_reflects_server_state`
    B 加入聊天室后，owner 禁言/解除禁言 B，B 侧调用 `isMemberInChatRoomMuteList` 确认状态从 `false -> true -> false`。

异常 cases
58. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[muteChatRoomMembers]`
    不存在 roomId 禁言聊天室成员，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
59. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[unMuteChatRoomMembers]`
    不存在 roomId 解除聊天室成员禁言，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
60. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[fetchChatRoomMuteList]`
    不存在 roomId 拉取聊天室禁言列表，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
61. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[muteChatRoomMembers-muteMembers-602-users [] are not members of this group!]`
    `muteChatRoomMembers` 传入空禁言成员列表，冻结模拟器实测返回：`code=602`，`description=users [] are not members of this group!`。
62. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[unMuteChatRoomMembers-unMuteMembers-300-Server is unreachable]`
    `unMuteChatRoomMembers` 传入空解除禁言成员列表，冻结模拟器实测返回：`code=300`，`description=Server is unreachable`。
63. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[muteChatRoomMembers-info5-expected5]`
    `muteChatRoomMembers` 传入不存在用户，冻结模拟器实测返回：`code=602`，`description=users [nonexistent_chatroom_user_999999] are not members of this group!`。
64. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[unMuteChatRoomMembers-info6-room]`
    `unMuteChatRoomMembers` 传入不存在用户，冻结实测幂等语义：返回完整聊天室对象。
65. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomMuteList-0-20]`
    `fetchChatRoomMuteList` 传入 `pageNum=0/pageSize=20`，冻结实测容错语义：返回空列表。
66. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomMuteList--1-20]`
    `fetchChatRoomMuteList` 传入 `pageNum=-1/pageSize=20`，冻结实测容错语义：返回空列表。
67. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomMuteList-1-0]`
    `fetchChatRoomMuteList` 传入 `pageNum=1/pageSize=0`，冻结实测容错语义：返回空列表。
68. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomMuteList-1--1]`
    `fetchChatRoomMuteList` 传入 `pageNum=1/pageSize=-1`，冻结实测容错语义：返回空列表。

## muteAllChatRoomMembers / unMuteAllChatRoomMembers

正常 cases
69. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_mute_and_unmute_all_members_success`
    owner 设置全员禁言并查询详情确认 `isAllMemberMuted=true`；随后解除全员禁言并确认恢复为 `false`。

异常 cases
70. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[muteAllChatRoomMembers]`
    不存在 roomId 设置聊天室全员禁言，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
71. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[unMuteAllChatRoomMembers]`
    不存在 roomId 解除聊天室全员禁言，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。

## blockChatRoomMembers / unBlockChatRoomMembers / fetchChatRoomBlockList

正常 cases
72. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_block_fetch_unblock_member_success`
    B 加入聊天室后，owner 将 B 加入黑名单并拉取黑名单确认；随后解除黑名单并再次拉取确认。

异常 cases
73. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[blockChatRoomMembers]`
    不存在 roomId 添加聊天室黑名单，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
74. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[unBlockChatRoomMembers]`
    不存在 roomId 移除聊天室黑名单，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
75. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[fetchChatRoomBlockList]`
    不存在 roomId 拉取聊天室黑名单，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
76. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[blockChatRoomMembers-members-110-usernames is null or empty!]`
    `blockChatRoomMembers` 传入空成员列表，冻结模拟器实测返回：`code=110`，`description=usernames is null or empty!`。
77. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[unBlockChatRoomMembers-members-300-Server is unreachable]`
    `unBlockChatRoomMembers` 传入空成员列表，冻结模拟器实测返回：`code=300`，`description=Server is unreachable`。
78. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[blockChatRoomMembers-info7-expected7]`
    `blockChatRoomMembers` 传入不存在用户，冻结模拟器实测返回：`code=703`，`description=users [nonexistent_chatroom_user_999999] are not members of this group!`。
79. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[unBlockChatRoomMembers-info8-room]`
    `unBlockChatRoomMembers` 传入不存在用户，冻结实测幂等语义：返回完整聊天室对象。
80. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomBlockList-0-20]`
    `fetchChatRoomBlockList` 传入 `pageNum=0/pageSize=20`，冻结实测容错语义：返回空列表。
81. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomBlockList--1-20]`
    `fetchChatRoomBlockList` 传入 `pageNum=-1/pageSize=20`，冻结实测容错语义：返回空列表。
82. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomBlockList-1-0]`
    `fetchChatRoomBlockList` 传入 `pageNum=1/pageSize=0`，冻结实测容错语义：返回空列表。
83. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomBlockList-1--1]`
    `fetchChatRoomBlockList` 传入 `pageNum=1/pageSize=-1`，冻结实测容错语义：返回空列表。

## addChatRoomAdmin / removeChatRoomAdmin

正常 cases
84. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_add_and_remove_admin_success`
    B 加入聊天室后，owner 添加 B 为管理员并通过详情 `adminList` 确认；随后移除管理员并再次确认。

异常 cases
85. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[addChatRoomAdmin]`
    不存在 roomId 添加聊天室管理员，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
86. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[removeChatRoomAdmin]`
    不存在 roomId 移除聊天室管理员，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
87. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[addChatRoomAdmin-info0-expected0]`
    `addChatRoomAdmin` 传入不存在用户，冻结模拟器实测返回：`code=700`，`description=username nonexistent_chatroom_user_999999 doesn't exist!`。
88. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[removeChatRoomAdmin-info1-expected1]`
    `removeChatRoomAdmin` 传入不存在用户，冻结模拟器实测返回：`code=703`，`description=user:nonexistent_chatroom_user_999999 is not admin of group:<roomId>`。
89. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_non_member[addChatRoomAdmin-info0-room]`
    `addChatRoomAdmin` 传入真实但未加入聊天室的 user_b，冻结实测语义：返回完整聊天室对象。
90. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_non_member[removeChatRoomAdmin-info1-expected1]`
    `removeChatRoomAdmin` 传入真实但未加入聊天室的 user_b，冻结实测返回：`code=703`，`description=user:<user_b> is not admin of group:<roomId>`。

## changeChatRoomOwner

正常 cases
91. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_change_owner_success`
    owner 将聊天室所有权转移给 B，随后 B 查询聊天室详情，校验 `owner` 已变为 B。

异常 cases
92. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[changeChatRoomOwner]`
    不存在 roomId 转移聊天室 owner，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
93. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[changeChatRoomOwner-info2-expected2]`
    `changeChatRoomOwner` 传入不存在用户，冻结模拟器实测返回：`code=700`，`description=username nonexistent_chatroom_user_999999 doesn't exist!`。
94. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_non_member[changeChatRoomOwner-info2-owner_changed]`
    `changeChatRoomOwner` 传入真实但未加入聊天室的 user_b，冻结实测语义：转让成功，返回聊天室对象且 `owner=user_b`。

## removeChatRoomMembers

正常 cases
95. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_remove_member_success`
    owner 将已加入聊天室的 B 踢出，并通过 `fetchChatRoomMembers` 确认成员列表不再包含 B。

异常 cases
96. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[removeChatRoomMembers]`
    不存在 roomId 踢出聊天室成员，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
97. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[removeChatRoomMembers-members-300-Server is unreachable]`
    `removeChatRoomMembers` 传入空成员列表，冻结模拟器实测返回：`code=300`，`description=Server is unreachable`。
98. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[removeChatRoomMembers-info9-expected9]`
    `removeChatRoomMembers` 传入不存在用户，冻结模拟器实测返回：`code=703`，`description=users [nonexistent_chatroom_user_999999] are not members of this group!`。
99. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_non_member[removeChatRoomMembers-info3-expected3]`
    `removeChatRoomMembers` 传入真实但未加入聊天室的 user_b，冻结模拟器实测返回：`code=703`，`description=users [<user_b>] are not members of this group!`。

## setChatRoomAttributes / fetchChatRoomAttributes

正常 cases
100. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_set_and_fetch_attributes_success`
    设置聊天室自定义属性后，按 key 拉取属性并确认返回值与设置值一致。
101. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_fetch_all_attributes_success`
    设置两个聊天室自定义属性后，不传 `keys` 拉取全量属性，确认两个 key/value 均可返回。
102. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_fetch_attributes_by_partial_keys_success`
    设置两个聊天室自定义属性后，仅传入其中一个 key 拉取，确认只返回被请求的 key/value，不返回未请求 key。
103. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_update_attribute_overwrites_previous_value`
    对同一个聊天室属性 key 连续设置旧值和新值，随后按 key 拉取确认返回新值且旧值已被覆盖。

异常 cases
104. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[setChatRoomAttributes]`
    不存在 roomId 设置聊天室自定义属性，冻结现网错误语义：`code=702`。
105. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[fetchChatRoomAttributes]`
    不存在 roomId 拉取聊天室自定义属性，冻结现网错误语义：`code=702`，`description` 包含 `User has not joined the chat room`。
106. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[setChatRoomAttributes]`
    roomId 为空字符串设置聊天室自定义属性，冻结实测错误语义：`code=303`。
107. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[fetchChatRoomAttributes]`
    roomId 为空字符串拉取聊天室自定义属性，冻结实测错误语义：`code=303`，`description` 包含 `Unknown server error`。
108. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_add_attributes_empty_map`
    `setChatRoomAttributes` 传入空 `attributes={}`，冻结模拟器实测返回：`code=110`，`description=""`。

## removeChatRoomAttributes

正常 cases
109. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_remove_attributes_success`
    设置聊天室自定义属性后删除该 key，再按 key 拉取确认返回空 map。

异常 cases
110. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[removeChatRoomAttributes]`
    不存在 roomId 删除聊天室自定义属性，冻结现网错误语义：`code=702`。
111. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[removeChatRoomAttributes]`
    roomId 为空字符串删除聊天室自定义属性，冻结实测错误语义：`code=303`。
112. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_remove_attributes_empty_keys`
    `removeChatRoomAttributes` 传入空 `keys=[]`，冻结模拟器实测返回：`code=110`，`description=""`。

## isMemberInChatRoomWhiteListFromServer / isMemberInChatRoomMuteList

正常 cases
113. `tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_is_member_in_white_list_and_mute_list_success`
    创建聊天室后分别调用白名单/禁言自查接口，校验返回值为 bool。
114. `tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_member_white_list_check_reflects_server_state`
    B 侧白名单自查能反映 owner 添加/移除白名单后的服务端状态。
115. `tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_member_mute_list_check_reflects_server_state`
    B 侧禁言自查能反映 owner 禁言/解除禁言后的服务端状态。

异常 cases
116. `tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_is_member_in_white_list_and_mute_list_nonexistent_room`
    不存在 roomId 调用白名单/禁言自查接口，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
117. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_self_checks_empty_room_id[isMemberInChatRoomWhiteListFromServer]`
    `isMemberInChatRoomWhiteListFromServer` 传入空 roomId，冻结模拟器实测返回：`code=700`，`description=Chat room ID is invalid`。
118. `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_self_checks_empty_room_id[isMemberInChatRoomMuteList]`
    `isMemberInChatRoomMuteList` 传入空 roomId，冻结模拟器实测返回：`code=700`，`description=Chat room ID is invalid`。

## ChatRoom 回调事件

正常 cases
119. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_admin_added_and_removed_callbacks`
    B 加入聊天室后，owner 添加 B 为管理员，B 侧收到 `onAdminAddedFromChatRoom` / `onRoomAdminAdded` 回调并校验 `roomId/admin`。
120. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_admin_added_and_removed_callbacks`
    owner 移除 B 管理员，B 侧收到 `onAdminRemovedFromChatRoom` / `onRoomAdminRemoved` 回调并校验 `roomId/admin`。
121. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_owner_changed_callback`
    owner 将聊天室所有权转移给 B，B 侧收到 `onOwnerChangedFromChatRoom` / `onRoomOwnerChanged` 回调并校验 `roomId/newOwner/oldOwner`。
122. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_all_member_mute_state_callbacks`
    owner 设置全员禁言，B 侧收到 `onAllChatRoomMemberMuteStateChanged` / `onRoomAllMemberMuteStateChanged` 回调并校验禁言状态为 true。
123. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_all_member_mute_state_callbacks`
    owner 解除全员禁言，B 侧收到 `onAllChatRoomMemberMuteStateChanged` / `onRoomAllMemberMuteStateChanged` 回调并校验禁言状态为 false。
124. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_attributes_updated_and_removed_callbacks`
    owner 设置聊天室属性，B 侧收到 `onAttributesUpdated` / `onRoomAttributesDidUpdated` 回调并校验 `roomId/attributes/from`。
125. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_attributes_updated_and_removed_callbacks`
    owner 删除聊天室属性，B 侧收到 `onAttributesRemoved` / `onRoomAttributesDidRemoved` 回调并校验 `roomId/removedKeys|keys/from`。
126. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_specification_changed_callback`
    owner 修改聊天室名称触发规格变更，B 侧收到 `onSpecificationChanged` / `onRoomSpecificationChanged` 回调并校验 `room.roomId/name`。
127. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_member_exited_callback`
    B 主动离开聊天室，A 侧收到 `onMemberExitedFromChatRoom` / `onRoomMemberExited` 回调并校验 `roomId/roomName/participant`。
128. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_allow_list_added_and_removed_callbacks`
    owner 添加 B 到聊天室白名单，B 侧收到 `onAllowListAddedFromChatRoom` / `onRoomWhiteListAdded` 回调并校验 `roomId/members`。
129. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_allow_list_added_and_removed_callbacks`
    owner 从聊天室白名单移除 B，B 侧收到 `onAllowListRemovedFromChatRoom` / `onRoomWhiteListRemoved` 回调并校验 `roomId/members`。
130. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_mute_list_added_and_removed_callbacks`
    owner 禁言 B，B 侧收到 `onMuteListAddedFromChatRoom` / `onRoomMuteListAdded` 回调并校验 `roomId/mutes`。
131. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_mute_list_added_and_removed_callbacks`
    owner 解除 B 禁言，B 侧收到 `onMuteListRemovedFromChatRoom` / `onRoomMuteListRemoved` 回调并校验 `roomId/mutes`。
132. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_removed_and_destroyed_callbacks`
    owner 将 B 踢出聊天室，B 侧收到 `onRemovedFromChatRoom` / `onRoomRemoved` 回调并校验 `roomId/participant/reason`。
133. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_removed_and_destroyed_callbacks`
    owner 销毁聊天室，B 侧收到 `onChatRoomDestroyed` / `onRoomDestroyed` 回调并校验 `roomId/roomName`。

异常 cases
暂无。

## destroyChatRoom

正常 cases
134. `tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_destroy_room_success`
    删除 REST 创建的聊天室，校验销毁成功响应。
135. `tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_fetch_room_info_from_server_after_destroy`
    删除 REST 创建的聊天室后再次查询，校验销毁后服务端返回不存在错误。

异常 cases
136. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_destroy_room_nonexistent`
    删除随机不存在 roomId，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
137. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_destroy_room_empty_id`
    roomId 为空字符串，冻结错误语义：`code=700`，`description` 包含 `Chat room ID is invalid`。

## 当前统计

- 总计：137 条（其中参数化 case 按参数分别独立统计；跨 API 链路用例会在相关 API 下重复登记；`暂无` 占位不计入总数）
- 本轮新增边界/异常：`test_chatroom_management_boundaries.py` 已先用 `CASES_DISCOVER=1 WS_DEBUG=1` 采集真实模拟器返回，再切 strict 通过（`42 passed`）。
- 既有补充验证：`test_chatroom_lifecycle.py`、`test_chatroom_management_exceptions.py` 已在本轮新增后纳入组合回归；`test_chatroom_callbacks.py` 仍按既有记录保留，未在本轮改动。
