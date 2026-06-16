# ChatRoom 模块 Cases 总记录（按 API）

— 说明
- 本文件记录 ChatRoom 模块已覆盖用例（按 API 组织）。
- 每条 case 以全局序号编号；统计按“当前记录条目数”计算。
- 暂缓与 skip 项统一写 `CASES_DEFERRED.zh.md`。

## createChatRoom

正常 cases
1. `tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_create_and_fetch_from_server`
   使用 REST 创建聊天室后，SDK 拉取详情，校验 `roomId/owner/name/maxUsers/memberCount` 等核心字段。

异常 cases
2. 暂无。

## joinChatRoom

正常 cases
3. `tests/chatroom/test_chatroom_members.py::test_chatroom_join_public_chatroom_success`
   B 加入公开聊天室，校验同步成功响应与 `onMemberJoinedFromChatRoom` 回调关键字段。
4. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_join_room_nonexistent_current_behavior`
   当前实测：传入随机不存在 roomId 仍返回成功 `result=1`，先按现网行为冻结（待产品语义确认）。
5. `tests/chatroom/test_chatroom_member_basics.py::test_chatroom_join_then_get_local_room_and_all_rooms`
   B 加入聊天室后，校验本地单聊天室缓存和本地聊天室列表包含该聊天室。

异常 cases
6. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_join_room_empty_id`
   roomId 为空字符串，冻结错误语义：`code=700`，`description` 包含 `Chat room ID is invalid`。

## leaveChatRoom

正常 cases
7. `tests/chatroom/test_chatroom_member_basics.py::test_chatroom_leave_room_updates_local_cache`
   B 加入后主动离开聊天室，校验 `leaveChatRoom` 返回，并通过成员列表确认 B 已不在聊天室。

异常 cases
8. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_leave_room_nonexistent`
   当前实测：传入随机不存在 roomId 返回成功 `result=null`，先按现网行为冻结。
9. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_leave_room_empty_id`
   roomId 为空字符串，冻结错误语义：`code=700`，`description` 包含 `Chatroom ID invalid`。

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
    加入聊天室后，校验 `getChatRoom` 返回目标聊天室核心字段，`getAllChatRooms` 返回列表且包含目标聊天室。
22. `tests/chatroom/test_chatroom_member_basics.py::test_chatroom_leave_room_updates_local_cache`
    离开聊天室后，通过 `fetchChatRoomMembers` 校验离开成员不再出现在服务端成员列表中。
23. `tests/chatroom/test_chatroom_member_basics.py::test_chatroom_get_local_room_empty_id_returns_none`
    本地查询空 roomId，冻结当前行为：`getChatRoom` 返回 `null`。
24. `tests/chatroom/test_chatroom_member_basics.py::test_chatroom_get_local_room_nonexistent_returns_placeholder`
    本地查询不存在 roomId，冻结当前行为：返回本地占位聊天室对象，`roomId` 为传入值且 `name=""`、`memberCount=0`。
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

## changeChatRoomSubject / changeChatRoomDescription

正常 cases
32. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_change_subject_and_description_success`
    owner 修改聊天室名称和描述，随后拉取聊天室详情确认 `name/desc` 已更新。

异常 cases
33. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[changeChatRoomSubject]`
    不存在 roomId 修改聊天室名称，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
34. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[changeChatRoomDescription]`
    不存在 roomId 修改聊天室描述，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。


## updateChatRoomAnnouncement / fetchChatRoomAnnouncement

正常 cases
35. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_update_and_fetch_announcement_success`
    更新聊天室公告后立即拉取公告，校验 `fetchChatRoomAnnouncement` 返回刚更新的内容。

异常 cases
36. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[updateChatRoomAnnouncement]`
    不存在 roomId 更新聊天室公告，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
37. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[fetchChatRoomAnnouncement]`
    不存在 roomId 拉取聊天室公告，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。

## addMembersToChatRoomWhiteList / removeMembersFromChatRoomWhiteList / fetchChatRoomWhiteListFromServer

正常 cases
38. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_add_fetch_remove_white_list_success`
    B 加入聊天室后，owner 将 B 加入白名单并拉取确认；随后移除 B 并再次拉取确认。
39. `tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_member_white_list_check_reflects_server_state`
    B 加入聊天室后，owner 添加/移除 B 白名单，B 侧调用 `isMemberInChatRoomWhiteListFromServer` 确认状态从 `false -> true -> false`。

异常 cases
40. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[addMembersToChatRoomWhiteList]`
    不存在 roomId 添加聊天室白名单，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
41. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[removeMembersFromChatRoomWhiteList]`
    不存在 roomId 移除聊天室白名单，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
42. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[fetchChatRoomWhiteListFromServer]`
    不存在 roomId 拉取聊天室白名单，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。


## muteChatRoomMembers / unMuteChatRoomMembers / fetchChatRoomMuteList

正常 cases
43. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_mute_fetch_unmute_member_success`
    B 加入聊天室后，owner 禁言 B 并拉取禁言列表确认；随后解除禁言并再次拉取确认。
44. `tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_member_mute_list_check_reflects_server_state`
    B 加入聊天室后，owner 禁言/解除禁言 B，B 侧调用 `isMemberInChatRoomMuteList` 确认状态从 `false -> true -> false`。

异常 cases
45. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[muteChatRoomMembers]`
    不存在 roomId 禁言聊天室成员，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
46. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[unMuteChatRoomMembers]`
    不存在 roomId 解除聊天室成员禁言，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
47. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[fetchChatRoomMuteList]`
    不存在 roomId 拉取聊天室禁言列表，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。

## muteAllChatRoomMembers / unMuteAllChatRoomMembers

正常 cases
48. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_mute_and_unmute_all_members_success`
    owner 设置全员禁言并查询详情确认 `isAllMemberMuted=true`；随后解除全员禁言并确认恢复为 `false`。

异常 cases
49. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[muteAllChatRoomMembers]`
    不存在 roomId 设置聊天室全员禁言，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
50. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[unMuteAllChatRoomMembers]`
    不存在 roomId 解除聊天室全员禁言，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。

## blockChatRoomMembers / unBlockChatRoomMembers / fetchChatRoomBlockList

正常 cases
51. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_block_fetch_unblock_member_success`
    B 加入聊天室后，owner 将 B 加入黑名单并拉取黑名单确认；随后解除黑名单并再次拉取确认。

异常 cases
52. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[blockChatRoomMembers]`
    不存在 roomId 添加聊天室黑名单，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
53. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[unBlockChatRoomMembers]`
    不存在 roomId 移除聊天室黑名单，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
54. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[fetchChatRoomBlockList]`
    不存在 roomId 拉取聊天室黑名单，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。

## addChatRoomAdmin / removeChatRoomAdmin

正常 cases
55. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_add_and_remove_admin_success`
    B 加入聊天室后，owner 添加 B 为管理员并通过详情 `adminList` 确认；随后移除管理员并再次确认。

异常 cases
56. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[addChatRoomAdmin]`
    不存在 roomId 添加聊天室管理员，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
57. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[removeChatRoomAdmin]`
    不存在 roomId 移除聊天室管理员，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。

## changeChatRoomOwner

正常 cases
58. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_change_owner_success`
    owner 将聊天室所有权转移给 B，随后 B 查询聊天室详情，校验 `owner` 已变为 B。

异常 cases
59. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[changeChatRoomOwner]`
    不存在 roomId 转移聊天室 owner，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。

## removeChatRoomMembers

正常 cases
60. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_remove_member_success`
    owner 将已加入聊天室的 B 踢出，并通过 `fetchChatRoomMembers` 确认成员列表不再包含 B。

异常 cases
61. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[removeChatRoomMembers]`
    不存在 roomId 踢出聊天室成员，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。

## setChatRoomAttributes / fetchChatRoomAttributes

正常 cases
62. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_set_and_fetch_attributes_success`
    设置聊天室自定义属性后，按 key 拉取属性并确认返回值与设置值一致。
63. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_fetch_all_attributes_success`
    设置两个聊天室自定义属性后，不传 `keys` 拉取全量属性，确认两个 key/value 均可返回。
64. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_fetch_attributes_by_partial_keys_success`
    设置两个聊天室自定义属性后，仅传入其中一个 key 拉取，确认只返回被请求的 key/value，不返回未请求 key。
65. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_update_attribute_overwrites_previous_value`
    对同一个聊天室属性 key 连续设置旧值和新值，随后按 key 拉取确认返回新值且旧值已被覆盖。

异常 cases
66. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[setChatRoomAttributes]`
    不存在 roomId 设置聊天室自定义属性，冻结现网错误语义：`code=702`。
67. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[fetchChatRoomAttributes]`
    不存在 roomId 拉取聊天室自定义属性，冻结现网错误语义：`code=702`，`description` 包含 `User has not joined the chat room`。

## removeChatRoomAttributes

正常 cases
68. `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_remove_attributes_success`
    设置聊天室自定义属性后删除该 key，再按 key 拉取确认返回空 map。

异常 cases
69. `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[removeChatRoomAttributes]`
    不存在 roomId 删除聊天室自定义属性，冻结现网错误语义：`code=702`。

## isMemberInChatRoomWhiteListFromServer / isMemberInChatRoomMuteList

正常 cases
70. `tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_is_member_in_white_list_and_mute_list_success`
    创建聊天室后分别调用白名单/禁言自查接口，校验返回值为 bool。
71. `tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_member_white_list_check_reflects_server_state`
    B 侧白名单自查能反映 owner 添加/移除白名单后的服务端状态。
72. `tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_member_mute_list_check_reflects_server_state`
    B 侧禁言自查能反映 owner 禁言/解除禁言后的服务端状态。

异常 cases
73. `tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_is_member_in_white_list_and_mute_list_nonexistent_room`
    不存在 roomId 调用白名单/禁言自查接口，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。

## ChatRoom 回调事件

正常 cases
74. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_admin_added_and_removed_callbacks`
    B 加入聊天室后，owner 添加 B 为管理员，B 侧收到 `onAdminAddedFromChatRoom` / `onRoomAdminAdded` 回调并校验 `roomId/admin`。
75. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_admin_added_and_removed_callbacks`
    owner 移除 B 管理员，B 侧收到 `onAdminRemovedFromChatRoom` / `onRoomAdminRemoved` 回调并校验 `roomId/admin`。
76. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_owner_changed_callback`
    owner 将聊天室所有权转移给 B，B 侧收到 `onOwnerChangedFromChatRoom` / `onRoomOwnerChanged` 回调并校验 `roomId/newOwner/oldOwner`。
77. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_all_member_mute_state_callbacks`
    owner 设置全员禁言，B 侧收到 `onAllChatRoomMemberMuteStateChanged` / `onRoomAllMemberMuteStateChanged` 回调并校验禁言状态为 true。
78. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_all_member_mute_state_callbacks`
    owner 解除全员禁言，B 侧收到 `onAllChatRoomMemberMuteStateChanged` / `onRoomAllMemberMuteStateChanged` 回调并校验禁言状态为 false。
79. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_attributes_updated_and_removed_callbacks`
    owner 设置聊天室属性，B 侧收到 `onAttributesUpdated` / `onRoomAttributesDidUpdated` 回调并校验 `roomId/attributes/from`。
80. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_attributes_updated_and_removed_callbacks`
    owner 删除聊天室属性，B 侧收到 `onAttributesRemoved` / `onRoomAttributesDidRemoved` 回调并校验 `roomId/removedKeys|keys/from`。
81. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_announcement_changed_callback`
    owner 更新聊天室公告，B 侧收到 `onAnnouncementChangedFromChatRoom` / `onRoomAnnouncementChanged` 回调并校验 `roomId/announcement`。
82. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_allow_list_added_and_removed_callbacks`
    owner 添加 B 到聊天室白名单，B 侧收到 `onAllowListAddedFromChatRoom` / `onRoomWhiteListAdded` 回调并校验 `roomId/members`。
83. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_allow_list_added_and_removed_callbacks`
    owner 从聊天室白名单移除 B，B 侧收到 `onAllowListRemovedFromChatRoom` / `onRoomWhiteListRemoved` 回调并校验 `roomId/members`。
84. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_mute_list_added_and_removed_callbacks`
    owner 禁言 B，B 侧收到 `onMuteListAddedFromChatRoom` / `onRoomMuteListAdded` 回调并校验 `roomId/mutes`。
85. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_mute_list_added_and_removed_callbacks`
    owner 解除 B 禁言，B 侧收到 `onMuteListRemovedFromChatRoom` / `onRoomMuteListRemoved` 回调并校验 `roomId/mutes`。
86. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_removed_and_destroyed_callbacks`
    owner 将 B 踢出聊天室，B 侧收到 `onRemovedFromChatRoom` / `onRoomRemoved` 回调并校验 `roomId/participant/reason`。
87. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_removed_and_destroyed_callbacks`
    owner 销毁聊天室，B 侧收到 `onChatRoomDestroyed` / `onRoomDestroyed` 回调并校验 `roomId/roomName`。

异常 cases
88. 暂无。

## destroyChatRoom

正常 cases
89. `tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_destroy_room_success`
    删除 REST 创建的聊天室，校验销毁成功响应。
90. `tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_fetch_room_info_from_server_after_destroy`
    删除 REST 创建的聊天室后再次查询，校验销毁后服务端返回不存在错误。

异常 cases
91. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_destroy_room_nonexistent`
    删除随机不存在 roomId，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
92. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_destroy_room_empty_id`
    roomId 为空字符串，冻结错误语义：`code=700`，`description` 包含 `Chat room ID is invalid`。

## 当前统计

- 总计：92 条（其中参数化 case 按参数分别独立统计；跨 API 链路用例会在相关 API 下重复登记；历史 `暂无` 占位已被实际异常 case 替换）
- 可稳定执行并通过：新增 `test_chatroom_member_basics.py` 已 strict 通过（`3 passed`）；新增 `test_chatroom_management_basics.py`、`test_chatroom_management_exceptions.py`、`test_chatroom_membership_checks.py` 已真实网络回归通过（合计 `38 passed`）；`test_chatroom_callbacks.py` 已收集 `8 items`，其中前 4 个回调 case 曾真实网络通过（`4 passed`），本次新增后真实网络在登录阶段因 `adc` topic 残留/并发污染失败，未进入用例执行。
