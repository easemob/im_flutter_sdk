# Group 模块 Cases 总记录（按 API）

— 说明
- 本文件记录 Group 模块已覆盖用例（按 API 组织）。
- 每条 case 以全局序号编号；统计按“当前记录条目数”计算。
- 暂缓与 skip 项统一写 `CASES_DEFERRED.zh.md`。

## createGroup

正常 cases
1. `tests/group/test_group_lifecycle.py::test_group_create_group`
   A 创建群并邀请 B；A 侧校验创建响应关键字段，B 侧校验入群相关回调集合与字段，再做清理销毁。

异常 cases
2. `tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_empty_name`
   `groupName=""` 时创建；当前环境可成功创建，断言返回结构完整并可正常销毁清理。
3. `tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_optional_fields_empty`
   非必传字段空值组合（`avatarUrl/desc/inviteMembers/inviteReason/options.ext`）创建，验证空值语义稳定。
4. `tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_max_count_less_than_invite_members`
   `maxCount < inviteMembers`，预期失败；冻结错误码 `604` 与容量上限语义。
5. `tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_name_and_avatar_abnormal_inputs`
   覆盖 `groupName` 空格/控制字符/超长、`avatarUrl` 非 URL/FTP/超长，分别冻结成功或错误语义。
6. `tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_desc_reason_options_abnormal_inputs`
   覆盖 `desc/inviteReason/options.ext` 超长、`options.maxCount` 非法、`options.style` 越界等参数维度。
7. `tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_invite_members_abnormal_inputs`
   覆盖 `inviteMembers` 重复用户与包含不存在用户，冻结当前端“可成功/失败”两类稳定返回。
8. `tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs`
   对 `groupName/desc/inviteReason` 的空格、多行、符号输入做补充覆盖，验证文本类边界在当前端可回显。

## destroyGroup

正常 cases
9. `tests/group/test_group_lifecycle.py::test_group_create_group`（链路内销毁）
   正常创建链路末尾执行销毁，校验销毁成功响应与事件回调。

异常 cases
10. `tests/group/test_group_exceptions_lifecycle.py::test_group_destroy_group_nonexistent`
    销毁不存在群 ID，断言“群不存在”错误语义。
11. `tests/group/test_group_exceptions_lifecycle.py::test_group_destroy_group_empty_group_id`
    传空群 ID，断言参数非法错误语义。

## getGroupWithId

正常 cases
12. `tests/group/test_group_lifecycle.py::test_group_get_group`
    创建群后走本地查询，校验返回快照字段（群名、群主、成员数等）。

异常 cases
13. `tests/group/test_group_exceptions_lifecycle.py::test_group_get_group_with_id_nonexistent`
    查询不存在群，本地返回 `result=null` 语义。

## getGroupSpecificationFromServer

正常 cases
14. `tests/group/test_group_lifecycle.py::test_group_get_group_from_server`
    创建群后走服务端查询，校验返回快照与本地一致性关键字段。

异常 cases
15. `tests/group/test_group_exceptions_lifecycle.py::test_group_get_group_from_server_nonexistent`
    查询不存在群，断言服务端“群不存在”错误语义。

## getJoinedGroups

正常 cases
16. `tests/group/test_group_joined_groups.py::test_group_get_joined_groups_local_contains_created_group`
    创建群后拉取本地已加入群列表，校验包含目标群且 `groupId/owner/name` 一致。

异常 cases
17. `tests/group/test_group_exceptions_joined_groups.py::test_group_get_joined_groups_with_extra_info_fields`
    传入无关参数与边界分页字段，冻结当前端“忽略无关参数并返回稳定列表结构”语义。

## getJoinedGroupsFromServer

正常 cases
18. `tests/group/test_group_joined_groups.py::test_group_get_joined_groups_from_server_contains_created_group`
    创建群后拉取服务端已加入群列表，校验包含目标群且核心字段一致。

异常 cases
19. `tests/group/test_group_exceptions_joined_groups.py::test_group_get_joined_groups_from_server_with_extra_info_fields`
    传入无关参数与边界分页字段，冻结当前端“忽略无关参数并返回稳定列表结构”语义。

## getPublicGroupsFromServer

正常 cases
20. `tests/group/test_group_public_groups_count.py::test_group_get_public_groups_from_server_success`
    以 `pageNum=1,pageSize=20` 拉取公开群列表，校验 `result.cursor/result.list` 与列表项字段结构。

异常 cases
21. `tests/group/test_group_exceptions_public_groups_count.py::test_group_get_public_groups_from_server_invalid_paging[0-20]`
    `pageNum=0` 边界输入，校验当前端稳定返回结构。
22. `tests/group/test_group_exceptions_public_groups_count.py::test_group_get_public_groups_from_server_invalid_paging[-1-20]`
    `pageNum=-1` 非法输入，校验当前端稳定返回结构。
23. `tests/group/test_group_exceptions_public_groups_count.py::test_group_get_public_groups_from_server_invalid_paging[1-0]`
    `pageSize=0` 边界输入，校验当前端稳定返回结构。
24. `tests/group/test_group_exceptions_public_groups_count.py::test_group_get_public_groups_from_server_invalid_paging[1--1]`
    `pageSize=-1` 非法输入，校验当前端稳定返回结构。

## fetchJoinedGroupCount

正常 cases
25. `tests/group/test_group_public_groups_count.py::test_group_fetch_joined_group_count_success`
    拉取已加入群数量，校验响应信封与 `result` 为非负整数。

异常 cases
26. `tests/group/test_group_exceptions_public_groups_count.py::test_group_fetch_joined_group_count_with_extra_info`
    传入无关参数拉取已加入群数量，冻结当前端稳定返回非负整数语义。

## getGroupMemberListFromServer

正常 cases
27. `tests/group/test_group_member_list.py::test_group_get_group_member_list_from_server_success`
    创建群并邀请成员后拉取服务端成员列表，校验包含受邀成员且当前端语义下不包含群主。

异常 cases
28. `tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_nonexistent_group`
    查询不存在群成员列表，冻结“群不存在”错误语义。
29. `tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_invalid_paging[0-20]`
    `pageNum=0` 边界输入，校验当前端稳定错误或结构语义。
30. `tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_invalid_paging[-1-20]`
    `pageNum=-1` 非法输入，校验当前端稳定错误或结构语义。
31. `tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_invalid_paging[1-0]`
    `pageSize=0` 边界输入，校验当前端稳定错误或结构语义。
32. `tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_invalid_paging[1--1]`
    `pageSize=-1` 非法输入，校验当前端稳定错误或结构语义。

## updateGroupAnnouncement / getGroupAnnouncementFromServer

正常 cases
33. `tests/group/test_group_announcement.py::test_group_update_and_get_announcement_success`
    更新群公告后立即服务端读取，校验公告内容与写入值一致。

异常 cases
34. `tests/group/test_group_exceptions_announcement.py::test_group_update_announcement_nonexistent_group`
    更新不存在群公告，冻结“群不存在”错误语义。
35. `tests/group/test_group_exceptions_announcement.py::test_group_get_announcement_nonexistent_group`
    读取不存在群公告，冻结“群不存在”错误语义。
36. `tests/group/test_group_exceptions_announcement.py::test_group_update_announcement_empty`
    更新空公告并读取校验，冻结当前端空值公告语义。

## blockGroup / unblockGroup

正常 cases
37. `tests/group/test_group_blocking.py::test_group_block_then_unblock_success`
    先 block 再 unblock，校验两次响应成功且 `messageBlocked` 状态按预期切换。

异常 cases
38. `tests/group/test_group_exceptions_blocking.py::test_group_block_nonexistent_group`
    对不存在群执行 block，冻结“群不存在”错误语义。
39. `tests/group/test_group_exceptions_blocking.py::test_group_unblock_nonexistent_group`
    对不存在群执行 unblock，冻结“群不存在”错误语义。
40. `tests/group/test_group_exceptions_blocking.py::test_group_block_idempotent`
    连续两次 block 同一群，校验幂等成功语义。
41. `tests/group/test_group_exceptions_blocking.py::test_group_unblock_idempotent`
    连续两次 unblock 同一群，校验幂等成功语义。

## addMembers

正常 cases
42. `tests/group/test_group_members.py::test_group_add_remove_members`
    在已建群中添加成员，校验接口成功、被邀请端回调、服务端成员快照一致。

异常 cases
43. `tests/group/test_group_exceptions_members.py::test_group_add_members_empty_members`
    传空成员列表，按当前端稳定返回语义断言（当前为成功语义）。
44. `tests/group/test_group_exceptions_members.py::test_group_add_members_nonexistent_group`
    向不存在群加人，断言“群不存在”错误。
45. `tests/group/test_group_exceptions_members.py::test_group_add_members_nonexistent_user`
   向群内添加不存在用户，断言用户不存在类错误语义。

补充说明（发版 4.15.0 新事件）
- `tests/group/test_group_members.py::test_group_members_batch_join_exit_new_events`
  专项覆盖新事件名 `onMembersJoinedFromGroup/onMembersExitedFromGroup`，并严格校验 `data.groupId` 与 `data.userIds` 成员集合语义。

## removeMembers

正常 cases
46. `tests/group/test_group_members.py::test_group_add_remove_members`
    从群里移除成员，校验接口成功、被移除端回调、服务端成员快照变化。

异常 cases
47. `tests/group/test_group_exceptions_members.py::test_group_remove_members_non_member`
    移除非成员用户，断言非成员/无效移除错误语义。

## joinPublicGroup

正常 cases
48. 无（当前环境基线下未出现稳定成功语义）。
    说明：当前环境未形成可稳定复现的公开群“成功加入”路径。

异常 cases
49. `tests/group/test_group_members.py::test_group_join_and_leave_public_group`
    在当前环境下加入公开群返回权限相关错误，已冻结错误语义。

## leaveGroup

正常 cases
50. 无（当前环境基线下未出现稳定成功语义）。
    说明：当前环境未形成可稳定复现的“成功退群”链路（依赖加入成功前置）。

异常 cases
51. `tests/group/test_group_members.py::test_group_join_and_leave_public_group`
    与加入公开群同链路，当前端返回权限相关错误语义。
52. `tests/group/test_group_exceptions_members.py::test_group_leave_group_non_member`
    非成员执行退群，断言群不存在/非成员类错误语义。

## updateGroupSubject

正常 cases
53. `tests/group/test_group_metadata.py::test_group_update_subject`
    更新群名称（subject）后，校验接口响应与本地/服务端快照行为一致。

异常 cases
54. `tests/group/test_group_exceptions_metadata.py::test_group_update_subject_empty`
    主题置空场景，按当前端稳定语义断言。
55. `tests/group/test_group_exceptions_metadata.py::test_group_update_subject_too_long`
    超长主题输入，按当前端稳定语义断言。
56. `tests/group/test_group_exceptions_metadata.py::test_group_update_subject_nonexistent_group`
    不存在群更新主题，断言“群不存在”错误。

## updateDescription

正常 cases
57. `tests/group/test_group_metadata.py::test_group_update_description`
    更新群描述后，校验接口响应与本地/服务端快照行为一致。

异常 cases
58. `tests/group/test_group_exceptions_metadata.py::test_group_update_description_empty`
    描述置空场景，按当前端稳定语义断言。
59. `tests/group/test_group_exceptions_metadata.py::test_group_update_description_too_long`
    超长描述输入，按当前端稳定语义断言。
60. `tests/group/test_group_exceptions_metadata.py::test_group_update_description_nonexistent_group`
    不存在群更新描述，断言“群不存在”错误。

## 历史复现（非 API 直连）

正常 cases
61. `tests/group/test_group.py::test_group_member_count_local_then_server_sync`（按条件 skip）
    复现“本地人数与服务端人数不一致”历史问题；若未复现则按条件 skip，不影响主链路回归。

异常 cases
62. 无（复现用例不定义独立异常入参路径）。
    说明：该用例目标是行为复现，不是参数异常校验。


## getGroupBlockListFromServer

正常 cases
63. `tests/group/test_group_server_state_lists.py::test_group_get_group_block_list_from_server_success`
    创建群后拉取服务端 blockList，校验响应信封与空列表语义。

异常 cases
64. `tests/group/test_group_exceptions_server_state_lists.py::test_group_server_state_list_nonexistent_group[getGroupBlockListFromServer]`
    查询不存在群 blockList，冻结“群不存在”错误语义。

## getGroupMuteListFromServer

正常 cases
65. `tests/group/test_group_server_state_lists.py::test_group_get_group_mute_list_from_server_success`
    创建群后拉取服务端 muteList，冻结当前端空场景返回 `{}` 的语义并按空列表处理。

异常 cases
66. `tests/group/test_group_exceptions_server_state_lists.py::test_group_server_state_list_nonexistent_group[getGroupMuteListFromServer]`
    查询不存在群 muteList，冻结“群不存在”错误语义。

## getGroupWhiteListFromServer / isMemberInWhiteListFromServer

正常 cases
67. `tests/group/test_group_server_state_lists.py::test_group_get_group_white_list_and_member_check_success`
    拉取白名单并校验成员白名单状态查询，断言返回结构与布尔语义稳定。

异常 cases
68. `tests/group/test_group_exceptions_server_state_lists.py::test_group_server_state_list_nonexistent_group[getGroupWhiteListFromServer]`
    查询不存在群白名单，冻结“群不存在”错误语义。
69. `tests/group/test_group_exceptions_server_state_lists.py::test_group_server_state_list_nonexistent_group[isMemberInWhiteListFromServer]`
    查询不存在群的白名单成员状态，冻结“群不存在”错误语义。

## addAdmin

正常 cases
70. `tests/group/test_group_roles.py::test_group_add_admin_and_remove_admin_success`
    群主将成员设为管理员，校验同步响应关键字段、被操作者回调（`onAdminAddedFromGroup`）以及服务端群详情中的 `adminList` 变化。

异常 cases
71. `tests/group/test_group_exceptions_roles.py::test_group_add_admin_nonexistent_group`
    对不存在群执行 addAdmin，冻结“群不存在”错误语义。
72. `tests/group/test_group_exceptions_roles.py::test_group_add_admin_non_member`
    对群内不存在用户执行 addAdmin，冻结“用户不存在于群内”错误语义。

## removeAdmin

正常 cases
73. `tests/group/test_group_roles.py::test_group_add_admin_and_remove_admin_success`
    群主移除管理员，校验同步响应关键字段、被操作者回调（`onAdminRemovedFromGroup`）以及服务端 `adminList` 回落。

异常 cases
74. `tests/group/test_group_exceptions_roles.py::test_group_remove_admin_nonexistent_group`
    对不存在群执行 removeAdmin，冻结“群不存在”错误语义。

## updateGroupOwner

正常 cases
75. `tests/group/test_group_roles.py::test_group_update_owner_success`
    群主转让给成员并回切，校验两次同步响应关键字段、`onOwnerChangedFromGroup` 回调与服务端群主字段变化。

异常 cases
76. `tests/group/test_group_exceptions_roles.py::test_group_update_owner_nonexistent_group`
    对不存在群执行 updateGroupOwner，冻结“群不存在”错误语义。

## getGroupFileListFromServer

正常 cases
77. `tests/group/test_group_file_list.py::test_group_get_group_file_list_from_server_success`
    新建群后拉取共享文件列表，校验同步响应信封与空列表语义。

异常 cases
78. `tests/group/test_group_exceptions_file_list.py::test_group_get_group_file_list_from_server_nonexistent_group[1-20]`
    不存在群 ID 拉取共享文件列表（标准分页），冻结“群不存在”错误语义。
79. `tests/group/test_group_exceptions_file_list.py::test_group_get_group_file_list_from_server_nonexistent_group[0-20]`
    不存在群 ID + `pageNum=0` 拉取共享文件列表，冻结“群不存在”错误语义。
80. `tests/group/test_group_exceptions_file_list.py::test_group_get_group_file_list_from_server_nonexistent_group[1-0]`
    不存在群 ID + `pageSize=0` 拉取共享文件列表，冻结“群不存在”错误语义。

## setMemberAttributesFromGroup

正常 cases
81. `tests/group/test_group_member_attributes.py::test_group_set_and_fetch_member_attributes_success`
    成员写入群成员属性，校验同步响应与 `onAttributesChangedOfGroupMember` 回调，并通过单成员/多成员拉取接口交叉验证属性值。

异常 cases
82. `tests/group/test_group_exceptions_member_attributes.py::test_group_set_member_attributes_nonexistent_group`
    对不存在群设置成员属性，冻结当前端返回 `result=null` 的稳定语义。
83. `tests/group/test_group_exceptions_member_attributes.py::test_group_set_member_attributes_empty_attributes`
    对空属性字典设置成员属性，冻结 `205/Invalid parameter` 错误语义。

## fetchMemberAttributesFromGroup

正常 cases
84. `tests/group/test_group_member_attributes.py::test_group_set_and_fetch_member_attributes_success`
    设置成员属性后拉取当前成员属性，校验返回字典中关键键值一致。

异常 cases
85. `tests/group/test_group_exceptions_member_attributes.py::test_group_fetch_member_attributes_nonexistent_group`
    不存在群拉取单成员属性，冻结当前端“返回已有属性字典”的稳定语义。

## fetchMembersAttributesFromGroup

正常 cases
86. `tests/group/test_group_member_attributes.py::test_group_set_and_fetch_member_attributes_success`
    设置成员属性后按 `userIds` 批量拉取，校验目标成员映射及关键键值一致。

异常 cases
87. `tests/group/test_group_exceptions_member_attributes.py::test_group_fetch_members_attributes_nonexistent_group`
    不存在群批量拉取成员属性，冻结当前端“返回请求成员空属性映射”的稳定语义。

## removeMemberAttributesFromGroup

正常 cases
88. `tests/group/test_group_member_attributes_remove.py::test_group_remove_member_attributes_success`
    成员先写入属性再删除指定 key，校验同步响应、删除回调（`onAttributesChangedOfGroupMember`）及单/多成员拉取结果中 key 删除生效。

异常 cases
89. `tests/group/test_group_exceptions_member_attributes_remove.py::test_group_remove_member_attributes_nonexistent_group`
    不存在群删除成员属性，冻结当前端 `result=null` 的稳定语义。
90. `tests/group/test_group_exceptions_member_attributes_remove.py::test_group_remove_member_attributes_empty_keys`
    传空 `keys` 删除成员属性，冻结 `205/Invalid parameter` 错误语义。
91. `tests/group/test_group_exceptions_member_attributes_remove.py::test_group_remove_member_attributes_nonexistent_key`
    删除不存在属性 key，冻结当前端成功返回 `result=null` 的稳定语义。

## inviterUser

正常 cases
92. `tests/group/test_group_inviter.py::test_group_inviter_user_success`
    群主调用 inviterUser 邀请成员，校验同步响应、被邀请端入群回调集合与服务端成员快照变化。

异常 cases
93. `tests/group/test_group_exceptions_inviter.py::test_group_inviter_user_nonexistent_group`
    对不存在群执行 inviterUser，冻结“群不存在”错误语义。
94. `tests/group/test_group_exceptions_inviter.py::test_group_inviter_user_empty_members`
    `members=[]` 调 inviterUser，冻结当前端成功返回语义。
95. `tests/group/test_group_exceptions_inviter.py::test_group_inviter_user_nonexistent_user`
    邀请不存在用户，冻结 `603` + 用户不存在语义。

## requestToJoinPublicGroup

正常 cases
96. `tests/group/test_group_join_requests_and_invitations.py::test_group_request_to_join_and_accept_success`
    B 向公开需审批群发起申请，校验同步响应为群详情结构；A 侧校验申请到达回调，A 同意后 B 侧校验“申请已同意”回调及入群回调。
97. `tests/group/test_group_join_requests_and_invitations.py::test_group_request_to_join_and_decline_success`
    B 向公开需审批群发起申请，A 拒绝后 B 侧校验“申请已拒绝”回调与拒绝原因字段。

异常 cases
98. `tests/group/test_group_join_requests_and_invitations.py::test_group_request_to_join_public_group_nonexistent_group`
    不存在群 ID 发起入群申请，冻结 `600/do not find this group` 错误语义。

## acceptJoinApplication

正常 cases
99. `tests/group/test_group_join_requests_and_invitations.py::test_group_request_to_join_and_accept_success`
    群主同意入群申请，同步响应冻结为 `result=null`；申请人侧必须收到 `onRequestToJoinAcceptedFromGroup` 与入群相关回调。

异常 cases
100. `tests/group/test_group_join_requests_and_invitations.py::test_group_accept_join_application_nonexistent_group`
     不存在群执行同意申请，冻结 `600/do not find this group` 错误语义。
101. `tests/group/test_group_join_requests_and_invitations.py::test_group_accept_join_application_nonexistent_user`
     同意不存在用户的申请，冻结 `600/doesn't exist` 错误语义。

## declineJoinApplication

正常 cases
102. `tests/group/test_group_join_requests_and_invitations.py::test_group_request_to_join_and_decline_success`
     群主拒绝入群申请，同步响应冻结为 `result=null`；申请人侧必须收到 `onRequestToJoinDeclinedFromGroup` 回调并携带拒绝原因。

异常 cases
103. `tests/group/test_group_join_requests_and_invitations.py::test_group_decline_join_application_nonexistent_group`
     不存在群执行拒绝申请，冻结 `600/do not find this group` 错误语义。

## acceptInvitationFromGroup

正常 cases
104. 无（当前基线 options 下邀请默认自动同意，未形成稳定“待处理邀请->手动同意”链路）。

异常 cases
105. `tests/group/test_group_join_requests_and_invitations.py::test_group_accept_invitation_from_group_without_pending_invite`
     对不存在群执行同意邀请，冻结 `600/does not exist` 错误语义。

## declineInvitationFromGroup

正常 cases
106. 无（当前基线 options 下邀请默认自动同意，未形成稳定“待处理邀请->手动拒绝”链路）。

异常 cases
107. `tests/group/test_group_join_requests_and_invitations.py::test_group_decline_invitation_from_group_without_pending_invite`
     对不存在群执行拒绝邀请，冻结 `600/does not exist` 错误语义。

## uploadGroupSharedFile

正常 cases
108. 无（当前环境上传本地文本文件稳定返回 `401 Invalid file`，未形成稳定成功上传链路）。

异常 cases
109. `tests/group/test_group_shared_files.py::test_group_upload_shared_file_current_invalid_file_behavior`
     在真实群中上传文件，冻结当前端稳定错误 `401/Invalid file`。
110. `tests/group/test_group_shared_files.py::test_group_upload_shared_file_nonexistent_group`
     不存在群执行上传，冻结 `600/do not find this group` 错误语义。
111. `tests/group/test_group_shared_files.py::test_group_upload_shared_file_invalid_path`
     传不存在路径执行上传，冻结 `401/Invalid file` 错误语义。

## downloadGroupSharedFile

正常 cases
112. `tests/group/test_group_shared_files.py::test_group_download_shared_file_nonexistent_group_current_behavior`
     当前端对不存在群下载文件稳定返回 `result=true`，已按实际语义冻结。

异常 cases
113. 无（当前环境未观察到稳定错误返回）。

## removeGroupSharedFile

正常 cases
114. 无（当前环境未形成“先上传成功再删除”的稳定链路）。

异常 cases
115. `tests/group/test_group_shared_files.py::test_group_remove_shared_file_nonexistent_group`
     不存在群删除共享文件，冻结 `600/do not find this group` 错误语义。

## moderation

### blockMembers / unblockMembers

正常 cases
116. `tests/group/test_group_moderation.py::test_group_block_unblock_members_success`
     群主先 block 成员再 unblock，校验同步响应、被移除端回调、服务端 blockList 变化与回落。

异常 cases
117. `tests/group/test_group_moderation.py::test_group_block_unblock_members_nonexistent_group[blockMembers]`
     对不存在群执行 blockMembers，冻结 `600/do not find this group` 错误语义。
118. `tests/group/test_group_moderation.py::test_group_block_unblock_members_nonexistent_group[unblockMembers]`
     对不存在群执行 unblockMembers，冻结 `600/do not find this group` 错误语义。
119. `tests/group/test_group_moderation.py::test_group_block_members_non_member`
     对群内非成员执行 blockMembers，冻结 `603/users ... are not members of this group!` 错误语义。

### muteMembers / unMuteMembers

正常 cases
120. `tests/group/test_group_moderation.py::test_group_mute_unmute_members_success`
     群主对成员执行 mute/unMute，校验同步响应、成员回调、服务端 muteList 变化与回落。

异常 cases
121. `tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[muteMembers-info0-600-do not find this group]`
     对不存在群执行 muteMembers，冻结 `600/do not find this group` 错误语义。
122. `tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[unMuteMembers-info1-600-do not find this group]`
     对不存在群执行 unMuteMembers，冻结 `600/do not find this group` 错误语义。

### muteAllMembers / unMuteAllMembers

正常 cases
123. `tests/group/test_group_moderation.py::test_group_mute_all_unmute_all_success`
     群主对全群执行 muteAll/unMuteAll，校验同步响应、全员禁言状态回调与服务端状态变化。

异常 cases
124. `tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[muteAllMembers-info2-600-do not find this group]`
     对不存在群执行 muteAllMembers，冻结 `600/do not find this group` 错误语义。
125. `tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[unMuteAllMembers-info3-600-do not find this group]`
     对不存在群执行 unMuteAllMembers，冻结 `600/do not find this group` 错误语义。

### addWhiteList / removeWhiteList

正常 cases
126. `tests/group/test_group_moderation.py::test_group_add_remove_white_list_success`
     群主对白名单成员执行 addWhiteList/removeWhiteList，校验同步响应、成员回调与服务端白名单变化。

异常 cases
127. `tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[addWhiteList-info4-600-do not find this group]`
     对不存在群执行 addWhiteList，冻结 `600/do not find this group` 错误语义。
128. `tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[removeWhiteList-info5-600-do not find this group]`
     对不存在群执行 removeWhiteList，冻结 `600/do not find this group` 错误语义。

### updateGroupExt

正常 cases
129. `tests/group/test_group_moderation.py::test_group_update_group_ext_success`
     群主更新群扩展信息，校验同步响应与服务端 ext 回显一致。

异常 cases
130. `tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[updateGroupExt-info6-600-do not find this group]`
     对不存在群执行 updateGroupExt，冻结 `600/do not find this group` 错误语义。

## 统计
- 当前记录 case 条目总数：`130`
