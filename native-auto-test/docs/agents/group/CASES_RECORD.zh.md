# Group 模块 Cases 总记录（按 API）

— 说明
- 本文件记录 Group 模块已覆盖用例（按 API 组织）。
- 每条 case 以全局序号编号；统计按“当前记录条目数”计算。
- 暂缓与 skip 项统一写 `CASES_DEFERRED.zh.md`。

## 常规建群容量场景

- 默认场景：`cd native-auto-test && .venv/bin/python -m pytest -q tests/group`；未传参数时，常规 `createGroup.options.maxCount` 为 `200`。
- 扩容场景：`cd native-auto-test && .venv/bin/python -m pytest -q --group-create-max-count=3100 tests/group`；复用同一套 case，常规建群和相关 `maxUserCount` 严格断言均为 `3100`。
- 容量边界豁免：专门验证容量语义的 `maxCount=0/-1/1/2` 保持显式值，不受场景参数覆盖。
- 静态验证（2026-08-13）：无设备容量契约测试待按 3100 场景复验；`--group-create-max-count=0 --collect-only` 仍应以参数错误拒绝。尚未执行会创建真实群的 3100 discovery/strict 回归。

## createGroup

正常 cases
1. `tests/group/test_group_lifecycle.py::test_group_create_group`
   A 创建群并邀请 B；A 侧校验创建响应关键字段，并按真实日志断言 A 收到 `onMembersJoinedFromGroup/onMemberJoinedFromGroup`，B 侧校验入群相关回调集合与字段，再做清理销毁。

异常 cases
2. `tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_empty_name`
   `groupName=""` 时创建；当前环境可成功创建，断言返回结构完整并可正常销毁清理。
3. `tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_optional_fields_empty`
   非必传字段空值组合（`avatarUrl/desc/inviteMembers/inviteReason/options.ext`）创建，验证空值语义稳定。
4. `tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_max_count_less_than_invite_members`
   `maxCount < inviteMembers`，预期失败；冻结错误码 `604` 与容量上限语义。
5. `tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_name_and_avatar_abnormal_inputs`
   覆盖 `groupName` 空格/控制字符/超长、`avatarUrl` 非 URL/FTP/超长；其中 `groupName` 256/512 超长当前真实返回 `300/Server is unreachable`，其余按实测成功或错误语义冻结。
6. `tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_desc_reason_options_abnormal_inputs`
   覆盖 `desc/inviteReason/options.ext` 超长、`options.maxCount` 非法、`options.style` 越界等参数维度。
7. `tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_invite_members_abnormal_inputs`
   覆盖 `inviteMembers` 重复用户与包含不存在用户，冻结当前端“可成功/失败”两类稳定返回；重复用户成功创建时稳定语义为 `memberCount=owner+去重成员数`，`memberList` 当前实测可能为空或返回去重成员，不作为 strict 字段。
8. `tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs`
   对 `groupName/desc/inviteReason` 的空格、多行、符号输入做补充覆盖，验证文本类边界在当前端可回显。

## destroyGroup

正常 cases
9. `tests/group/test_group_lifecycle.py::test_group_create_group`（链路内销毁）
   正常创建链路末尾执行销毁，校验销毁成功响应，并在 B 已入群时断言 B 收到 `onGroupDestroyed`。

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
15. `tests/group/test_group_lifecycle.py::test_group_get_group_from_server_after_destroy`
    创建群后销毁，再次走服务端查询，冻结销毁后“群不存在”错误语义。

异常 cases
16. `tests/group/test_group_exceptions_lifecycle.py::test_group_get_group_from_server_nonexistent`
    查询不存在群，断言服务端“群不存在”错误语义。

## getJoinedGroups

正常 cases
17. `tests/group/test_group_joined_groups.py::test_group_get_joined_groups_local_contains_created_group`
    创建群后拉取本地已加入群列表，校验包含目标群且 `groupId/owner/name` 一致。

异常 cases
18. `tests/group/test_group_exceptions_joined_groups.py::test_group_get_joined_groups_with_extra_info_fields`
    传入无关参数与边界分页字段，冻结当前端“忽略无关参数并返回稳定列表结构”语义。

## getJoinedGroupsFromServer

正常 cases
19. `tests/group/test_group_joined_groups.py::test_group_get_joined_groups_from_server_contains_created_group`
    创建群后拉取服务端已加入群列表，校验包含目标群且核心字段一致。

异常 cases
20. `tests/group/test_group_exceptions_joined_groups.py::test_group_get_joined_groups_from_server_with_extra_info_fields`
    传入无关参数与边界分页字段，冻结当前端“忽略无关参数并返回稳定列表结构”语义。

## getPublicGroupsFromServer

正常 cases
21. `tests/group/test_group_public_groups_count.py::test_group_get_public_groups_from_server_success`
    以真实 cursor API 参数 `pageSize=20` 拉取第一页，严格校验 `result` 仅含
    `cursor/list`，列表项仅含 `groupId/name`。

异常 cases
22. `tests/group/test_group_exceptions_public_groups_count.py::test_group_get_public_groups_from_server_invalid_paging[0-20]`
    `pageNum=0` 边界输入，校验当前端稳定返回结构。
23. `tests/group/test_group_exceptions_public_groups_count.py::test_group_get_public_groups_from_server_invalid_paging[-1-20]`
    `pageNum=-1` 非法输入，校验当前端稳定返回结构。
24. `tests/group/test_group_exceptions_public_groups_count.py::test_group_get_public_groups_from_server_invalid_paging[1-0]`
    `pageSize=0` 边界输入，校验当前端稳定返回结构。
25. `tests/group/test_group_exceptions_public_groups_count.py::test_group_get_public_groups_from_server_invalid_paging[1--1]`
    `pageSize=-1` 非法输入，校验当前端稳定返回结构。

## fetchJoinedGroupCount

正常 cases
26. `tests/group/test_group_public_groups_count.py::test_group_fetch_joined_group_count_success`
    拉取已加入群数量，校验响应信封与 `result` 为非负整数。

异常 cases
27. `tests/group/test_group_exceptions_public_groups_count.py::test_group_fetch_joined_group_count_with_extra_info`
    传入无关参数拉取已加入群数量，冻结当前端稳定返回非负整数语义。

## getGroupMemberListFromServer

正常 cases
28. `tests/group/test_group_member_list.py::test_group_get_group_member_list_from_server_success`
    创建群并邀请成员后拉取服务端成员列表，校验包含受邀成员且当前端语义下不包含群主。

异常 cases
29. `tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_nonexistent_group`
    查询不存在群成员列表，冻结“群不存在”错误语义。
30. `tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_invalid_paging[0-20]`
    `pageNum=0` 边界输入，校验当前端稳定错误或结构语义。
31. `tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_invalid_paging[-1-20]`
    `pageNum=-1` 非法输入，校验当前端稳定错误或结构语义。
32. `tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_invalid_paging[1-0]`
    `pageSize=0` 边界输入，校验当前端稳定错误或结构语义。
33. `tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_invalid_paging[1--1]`
    `pageSize=-1` 非法输入，校验当前端稳定错误或结构语义。

## updateGroupAnnouncement / getGroupAnnouncementFromServer

正常 cases
34. `tests/group/test_group_announcement.py::test_group_owner_update_announcement_notifies_member`
    群主 A 更新公告，B 收到精确 `onAnnouncementChangedFromGroup`，A 不收到同类事件，
    服务端读取值与写入值一致。

异常 cases
35. `tests/group/test_group_exceptions_announcement.py::test_group_update_announcement_nonexistent_group`
    更新不存在群公告，冻结“群不存在”错误语义。
36. `tests/group/test_group_exceptions_announcement.py::test_group_get_announcement_nonexistent_group`
    读取不存在群公告，冻结“群不存在”错误语义。
37. `tests/group/test_group_exceptions_announcement.py::test_group_update_announcement_empty`
    更新空公告并读取校验，冻结当前端空值公告语义。

## blockGroup / unblockGroup

正常 cases
38. `tests/group/test_group_blocking.py::test_group_block_then_unblock_success`
    先 block 再 unblock，校验两次响应成功且 `messageBlocked` 状态按预期切换。

异常 cases
39. `tests/group/test_group_exceptions_blocking.py::test_group_block_nonexistent_group`
    对不存在群执行 block，冻结“群不存在”错误语义。
40. `tests/group/test_group_exceptions_blocking.py::test_group_unblock_nonexistent_group`
    对不存在群执行 unblock，冻结“群不存在”错误语义。
41. `tests/group/test_group_exceptions_blocking.py::test_group_block_idempotent`
    连续两次 block 同一群，校验幂等成功语义。
42. `tests/group/test_group_exceptions_blocking.py::test_group_unblock_idempotent`
    连续两次 unblock 同一群，校验幂等成功语义。

## addMembers

正常 cases
43. `tests/group/test_group_members.py::test_group_add_remove_members`
    在已建群中添加成员，校验接口成功、被邀请端回调、群主侧 `onMembersJoinedFromGroup/onMemberJoinedFromGroup`，以及服务端成员快照一致；移除成员时同样断言群主侧 `onMembersExitedFromGroup/onMemberExitedFromGroup`。

异常 cases
44. `tests/group/test_group_exceptions_members.py::test_group_add_members_empty_members`
    传空成员列表，按当前端稳定返回语义断言（当前为成功语义）。
45. `tests/group/test_group_exceptions_members.py::test_group_add_members_nonexistent_group`
    向不存在群加人，断言“群不存在”错误。
46. `tests/group/test_group_exceptions_members.py::test_group_add_members_nonexistent_user`
   向群内添加不存在用户，断言用户不存在类错误语义。

补充说明（发版 4.15.0 新事件）
- `tests/group/test_group_members.py::test_group_members_batch_join_exit_new_events`
  专项覆盖新事件名 `onMembersJoinedFromGroup/onMembersExitedFromGroup`，并严格校验 `data.groupId` 与 `data.userIds` 成员集合语义。

## removeMembers

正常 cases
47. `tests/group/test_group_members.py::test_group_add_remove_members`
    从群里移除成员，校验接口成功、被移除端回调、服务端成员快照变化。

异常 cases
48. `tests/group/test_group_exceptions_members.py::test_group_remove_members_non_member`
    移除非成员用户，断言非成员/无效移除错误语义。

## joinPublicGroup

正常 cases
49. `tests/group/test_group_members.py::test_group_join_and_leave_public_group`
    A 创建真实 `PublicOpenJoin(style=3)` 群，B 加入成功；A 收到批量/单成员加入事件，
    B 不收到同类事件，服务端成员快照为 2 且包含 B。

异常 cases
50. `tests/group/test_group_members.py::test_group_join_public_group_rejects_private_member_invite_group`
    B 对 `style=1` 私有群调用 join，冻结真实错误 `603/group member permission is required`。

## leaveGroup

正常 cases
51. `tests/group/test_group_members.py::test_group_join_and_leave_public_group`
    B 加入 `style=3` 群后主动退出，返回 `result=true`；A 收到批量/单成员退出事件，
    B 不收到同类事件，服务端成员快照恢复为仅群主。

事件 cases
52. `tests/group/test_group_members.py::test_group_join_and_leave_public_group`
    同一退出链路独立确认操作者 B 在等待窗口内不收到成员退出事件。

异常 cases
53. `tests/group/test_group_exceptions_members.py::test_group_leave_group_non_member`
    非成员执行退群，断言群不存在/非成员类错误语义。

## updateGroupSubject

正常 cases
54. `tests/group/test_group_metadata.py::test_group_update_subject`
    更新群名称（subject）后，按真实 ADB 日志断言成员 B 收到 `onSpecificationDidUpdate`，并确认群主 A 不收到该回调，再校验接口响应与本地/服务端快照行为一致。

异常 cases
55. `tests/group/test_group_exceptions_metadata.py::test_group_update_subject_empty`
    主题置空场景，按当前端稳定语义断言。
56. `tests/group/test_group_exceptions_metadata.py::test_group_update_subject_too_long`
    超长主题输入，按当前端稳定语义断言。
57. `tests/group/test_group_exceptions_metadata.py::test_group_update_subject_nonexistent_group`
    不存在群更新主题，断言“群不存在”错误。

## updateDescription

正常 cases
58. `tests/group/test_group_metadata.py::test_group_update_description`
    更新群描述后，按真实 ADB 日志断言成员 B 收到 `onSpecificationDidUpdate`，并确认群主 A 不收到该回调，再校验接口响应与本地/服务端快照行为一致。

异常 cases
59. `tests/group/test_group_exceptions_metadata.py::test_group_update_description_empty`
    描述置空场景，按当前端稳定语义断言。
60. `tests/group/test_group_exceptions_metadata.py::test_group_update_description_too_long`
    超长描述输入，按当前端稳定语义断言。
61. `tests/group/test_group_exceptions_metadata.py::test_group_update_description_nonexistent_group`
    不存在群更新描述，断言“群不存在”错误。

## 历史复现（非 API 直连）

正常 cases
62. `tests/group/test_group.py::test_group_member_count_local_then_server_sync`（按条件 skip）
    复现“本地人数与服务端人数不一致”历史问题；若未复现则按条件 skip，不影响主链路回归。

异常 cases
63. 无（复现用例不定义独立异常入参路径）。
    说明：该用例目标是行为复现，不是参数异常校验。


## getGroupBlockListFromServer

正常 cases
64. `tests/group/test_group_server_state_lists.py::test_group_get_group_block_list_from_server_success`
    创建群后拉取服务端 blockList，校验响应信封与空列表语义。

异常 cases
65. `tests/group/test_group_exceptions_server_state_lists.py::test_group_server_state_list_nonexistent_group[getGroupBlockListFromServer]`
    查询不存在群 blockList，冻结“群不存在”错误语义。

## getGroupMuteListFromServer

正常 cases
66. `tests/group/test_group_server_state_lists.py::test_group_get_group_mute_list_from_server_success`
    创建群后拉取服务端 muteList，冻结当前端空场景返回 `{}` 的语义并按空列表处理。

异常 cases
67. `tests/group/test_group_exceptions_server_state_lists.py::test_group_server_state_list_nonexistent_group[getGroupMuteListFromServer]`
    查询不存在群 muteList，冻结“群不存在”错误语义。

## getGroupWhiteListFromServer / isMemberInWhiteListFromServer

正常 cases
68. `tests/group/test_group_server_state_lists.py::test_group_get_group_white_list_and_member_check_success`
    拉取白名单并校验成员白名单状态查询，断言返回结构与布尔语义稳定。

异常 cases
69. `tests/group/test_group_exceptions_server_state_lists.py::test_group_server_state_list_nonexistent_group[getGroupWhiteListFromServer]`
    查询不存在群白名单，冻结“群不存在”错误语义。
70. `tests/group/test_group_exceptions_server_state_lists.py::test_group_server_state_list_nonexistent_group[isMemberInWhiteListFromServer]`
    查询不存在群的白名单成员状态，冻结“群不存在”错误语义。

## isMemberInWhiteListFromServer / isMemberInGroupMuteList

正常 cases
71. `tests/group/test_group_membership_checks.py::test_group_is_member_in_white_list_and_mute_list_success`
    创建群后分别调用白名单/禁言自查接口，校验两者返回值均为 bool。

异常 cases
72. `tests/group/test_group_membership_checks.py::test_group_is_member_in_white_list_and_mute_list_nonexistent_group`
    对不存在群分别调用白名单/禁言自查接口，冻结“群不存在”错误语义。

## addAdmin

正常 cases
73. `tests/group/test_group_roles.py::test_group_add_admin_and_remove_admin_success`
    群主将成员设为管理员，校验同步响应关键字段、被操作者 B 收到 `onAdminAddedFromGroup`，并按真实 ADB 日志确认群主 A 不收到 admin 变更回调，服务端 `adminList` 同步变化。

异常 cases
74. `tests/group/test_group_exceptions_roles.py::test_group_add_admin_nonexistent_group`
    对不存在群执行 addAdmin，冻结“群不存在”错误语义。
75. `tests/group/test_group_exceptions_roles.py::test_group_add_admin_non_member`
    对群内不存在用户执行 addAdmin，冻结“用户不存在于群内”错误语义。

## removeAdmin

正常 cases
76. `tests/group/test_group_roles.py::test_group_add_admin_and_remove_admin_success`
    群主移除管理员，校验同步响应关键字段、被操作者 B 收到 `onAdminRemovedFromGroup`，并按真实 ADB 日志确认群主 A 不收到 admin 变更回调，服务端 `adminList` 回落。

异常 cases
77. `tests/group/test_group_exceptions_roles.py::test_group_remove_admin_nonexistent_group`
    对不存在群执行 removeAdmin，冻结“群不存在”错误语义。

## updateGroupOwner

正常 cases
78. `tests/group/test_group_roles.py::test_group_update_owner_success`
    群主转让给成员并回切，按真实 ADB 日志断言 A/B 双端都收到 `onOwnerChangedFromGroup`，再校验两次同步响应关键字段与服务端群主字段变化。

异常 cases
79. `tests/group/test_group_exceptions_roles.py::test_group_update_owner_nonexistent_group`
    对不存在群执行 updateGroupOwner，冻结“群不存在”错误语义。

## getGroupFileListFromServer

正常 cases
80. `tests/group/test_group_file_list.py::test_group_get_group_file_list_from_server_success`
    新建群后拉取共享文件列表，校验同步响应信封与空列表语义。

异常 cases
81. `tests/group/test_group_exceptions_file_list.py::test_group_get_group_file_list_from_server_nonexistent_group[1-20]`
    不存在群 ID 拉取共享文件列表（标准分页），冻结“群不存在”错误语义。
82. `tests/group/test_group_exceptions_file_list.py::test_group_get_group_file_list_from_server_nonexistent_group[0-20]`
    不存在群 ID + `pageNum=0` 拉取共享文件列表，冻结“群不存在”错误语义。
83. `tests/group/test_group_exceptions_file_list.py::test_group_get_group_file_list_from_server_nonexistent_group[1-0]`
    不存在群 ID + `pageSize=0` 拉取共享文件列表，冻结“群不存在”错误语义。

## setMemberAttributesFromGroup

正常 cases
84. `tests/group/test_group_member_attributes.py::test_group_set_and_fetch_member_attributes_success`
    成员写入群成员属性，校验同步响应与 `onAttributesChangedOfGroupMember` 回调，并通过单成员/多成员拉取接口交叉验证属性值。

异常 cases
85. `tests/group/test_group_exceptions_member_attributes.py::test_group_set_member_attributes_nonexistent_group`
    对不存在群设置成员属性，冻结当前端返回 `result=null` 的稳定语义。
86. `tests/group/test_group_exceptions_member_attributes.py::test_group_set_member_attributes_empty_attributes`
    对空属性字典设置成员属性，冻结 `205/Invalid parameter` 错误语义。

## fetchMemberAttributesFromGroup

正常 cases
87. `tests/group/test_group_member_attributes.py::test_group_set_and_fetch_member_attributes_success`
    设置成员属性后拉取当前成员属性，校验返回字典中关键键值一致。

异常 cases
88. `tests/group/test_group_exceptions_member_attributes.py::test_group_fetch_member_attributes_nonexistent_group`
    不存在群拉取单成员属性，冻结当前端“返回已有属性字典”的稳定语义。

## fetchMembersAttributesFromGroup

正常 cases
89. `tests/group/test_group_member_attributes.py::test_group_set_and_fetch_member_attributes_success`
    设置成员属性后按 `userIds` 批量拉取，校验目标成员映射及关键键值一致。

异常 cases
90. `tests/group/test_group_exceptions_member_attributes.py::test_group_fetch_members_attributes_nonexistent_group`
    不存在群批量拉取成员属性，冻结当前端“返回请求成员空属性映射”的稳定语义。

## removeMemberAttributesFromGroup

正常 cases
91. `tests/group/test_group_member_attributes_remove.py::test_group_remove_member_attributes_success`
    成员先写入属性再删除指定 key，校验同步响应、删除回调（`onAttributesChangedOfGroupMember`）及单/多成员拉取结果中 key 删除生效。

异常 cases
92. `tests/group/test_group_exceptions_member_attributes_remove.py::test_group_remove_member_attributes_nonexistent_group`
    不存在群删除成员属性，冻结当前端 `result=null` 的稳定语义。
93. `tests/group/test_group_exceptions_member_attributes_remove.py::test_group_remove_member_attributes_empty_keys`
    传空 `keys` 删除成员属性，冻结 `205/Invalid parameter` 错误语义。
94. `tests/group/test_group_exceptions_member_attributes_remove.py::test_group_remove_member_attributes_nonexistent_key`
    删除不存在属性 key，冻结当前端成功返回 `result=null` 的稳定语义。

## inviterUser

正常 cases
95. `tests/group/test_group_inviter.py::test_group_inviter_user_success`
    群主调用 inviterUser 邀请成员，校验同步响应、被邀请端入群回调集合与服务端成员快照变化。

异常 cases
96. `tests/group/test_group_exceptions_inviter.py::test_group_inviter_user_nonexistent_group`
    对不存在群执行 inviterUser，冻结“群不存在”错误语义。
97. `tests/group/test_group_exceptions_inviter.py::test_group_inviter_user_empty_members`
    `members=[]` 调 inviterUser，冻结当前端成功返回语义。
98. `tests/group/test_group_exceptions_inviter.py::test_group_inviter_user_nonexistent_user`
    邀请不存在用户，冻结 `603` + 用户不存在语义。

## requestToJoinPublicGroup

正常 cases
99. `tests/group/test_group_join_requests_and_invitations.py::test_group_request_to_join_and_accept_success`
    B 向公开需审批群发起申请，当前同步响应冻结为 `result=null`；A 侧校验申请到达回调，A 同意后 B 侧校验“申请已同意”回调及入群回调。
100. `tests/group/test_group_join_requests_and_invitations.py::test_group_request_to_join_and_decline_success`
    B 向公开需审批群发起申请，当前同步响应冻结为 `result=null`；A 拒绝后 B 侧校验“申请已拒绝”回调与拒绝原因字段。

异常 cases
101. `tests/group/test_group_join_requests_and_invitations.py::test_group_request_to_join_public_group_nonexistent_group`
    不存在群 ID 发起入群申请，冻结 `600/do not find this group` 错误语义。

## acceptJoinApplication

正常 cases
102. `tests/group/test_group_join_requests_and_invitations.py::test_group_request_to_join_and_accept_success`
    群主同意入群申请，同步响应冻结为 `result=null`；申请人侧必须收到 `onRequestToJoinAcceptedFromGroup` 与入群相关回调。

异常 cases
103. `tests/group/test_group_join_requests_and_invitations.py::test_group_accept_join_application_nonexistent_group`
     不存在群执行同意申请，冻结 `600/do not find this group` 错误语义。
104. `tests/group/test_group_join_requests_and_invitations.py::test_group_accept_join_application_nonexistent_user`
     同意不存在用户的申请，冻结 `600/doesn't exist` 错误语义。

## declineJoinApplication

正常 cases
105. `tests/group/test_group_join_requests_and_invitations.py::test_group_request_to_join_and_decline_success`
     群主拒绝入群申请，同步响应冻结为 `result=null`；申请人侧必须收到 `onRequestToJoinDeclinedFromGroup` 回调并携带拒绝原因。

异常 cases
106. `tests/group/test_group_join_requests_and_invitations.py::test_group_decline_join_application_nonexistent_group`
     不存在群执行拒绝申请，冻结 `600/do not find this group` 错误语义。

## acceptInvitationFromGroup

正常 cases
107. `tests/group/test_group_join_requests_and_invitations.py::test_group_invitation_explicit_accept_when_auto_accept_disabled`
     B 设置 `autoAcceptGroupInvitation=false`，A 以 `inviteNeedConfirm=true` 邀请 B；B 收到
     待处理邀请并显式接受，A 收到接受事件及两类加入事件，最终服务端成员为 2。

异常 cases
108. `tests/group/test_group_join_requests_and_invitations.py::test_group_accept_invitation_from_group_without_pending_invite`
     对不存在群执行同意邀请，冻结 `600/does not exist` 错误语义。


## declineInvitationFromGroup

正常 cases
109. `tests/group/test_group_join_requests_and_invitations.py::test_group_invitation_explicit_decline_when_auto_accept_disabled`
     B 收到待处理邀请后显式拒绝，API 返回 `result=null` 且服务端成员仍为 1；邀请方 A
     未按预期收到 `onInvitationDeclinedFromGroup`，该 case 当前按已知 Android 适配问题 skip，并记录于
     `CASES_FAILURES.zh.md`。

异常 cases
110. `tests/group/test_group_join_requests_and_invitations.py::test_group_decline_invitation_from_group_without_pending_invite`
     对不存在群执行拒绝邀请，冻结 `600/does not exist` 错误语义。

## uploadGroupSharedFile

正常 cases
111. `tests/group/test_group_shared_files.py::test_group_owner_upload_remove_shared_file_notifies_member`
     B 作为群主上传 Android 本地默认素材并删除；A 收到新增/删除事件，B 不收到同类事件；
     事件名称为 `{b62:...}`、列表名称为 `bigPic.jpg`，fileId 与完整元数据跨接口关联。

异常 cases
112. `tests/group/test_group_shared_files.py::test_group_upload_shared_file_explicit_host_path_is_invalid`
     显式传入 Android 不可读的 macOS `/private/tmp/...` 路径，冻结 `401/Invalid file`；
     bridge 只为缺省路径准备设备素材，不替换显式异常路径。
113. `tests/group/test_group_shared_files.py::test_group_upload_shared_file_nonexistent_group`
     不存在群执行上传，冻结 `600/do not find this group` 错误语义。
114. `tests/group/test_group_shared_files.py::test_group_upload_shared_file_invalid_path`
     传不存在路径执行上传，冻结 `401/Invalid file` 错误语义。

## downloadGroupSharedFile

正常 cases
115. `tests/group/test_group_shared_files.py::test_group_download_shared_file_nonexistent_group_current_behavior`
     当前端对不存在群下载文件稳定返回 `result=true`，已按实际语义冻结。

异常 cases
116. 无（当前环境未观察到稳定错误返回）。

## removeGroupSharedFile

正常 cases
117. `tests/group/test_group_shared_files.py::test_group_owner_upload_remove_shared_file_notifies_member`
     群主按上传事件/服务端列表关联得到的字符串 fileId 删除文件，成员收到精确删除事件，
     删除后服务端文件列表为空；管理员删除组合由 case 146 覆盖。

异常 cases
118. `tests/group/test_group_shared_files.py::test_group_remove_shared_file_nonexistent_group`
     不存在群删除共享文件，冻结 `600/do not find this group` 错误语义。

## moderation

### blockMembers / unblockMembers

正常 cases
119. `tests/group/test_group_moderation.py::test_group_block_unblock_members_success`
     群主先 block 成员再 unblock，校验同步响应、被移除端回调、服务端 blockList 变化与回落；当前实测 `onUserRemovedFromGroup` 的 `groupName` 字段可能为空字符串，仅校验字段存在与 groupId。

异常 cases
120. `tests/group/test_group_moderation.py::test_group_block_unblock_members_nonexistent_group[blockMembers]`
     对不存在群执行 blockMembers，冻结 `600/do not find this group` 错误语义。
121. `tests/group/test_group_moderation.py::test_group_block_unblock_members_nonexistent_group[unblockMembers]`
     对不存在群执行 unblockMembers，冻结 `600/do not find this group` 错误语义。
122. `tests/group/test_group_moderation.py::test_group_block_members_non_member`
     对群内非成员执行 blockMembers，冻结 `603/users ... are not members of this group!` 错误语义。

### muteMembers / unMuteMembers

正常 cases
123. `tests/group/test_group_moderation.py::test_group_mute_unmute_members_success`
     群主对成员执行 mute/unMute，校验同步响应、成员回调、服务端 muteList 变化与回落。

异常 cases
124. `tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[muteMembers-info0-600-do not find this group]`
     对不存在群执行 muteMembers，冻结 `600/do not find this group` 错误语义。
125. `tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[unMuteMembers-info1-600-do not find this group]`
     对不存在群执行 unMuteMembers，冻结 `600/do not find this group` 错误语义。

### muteAllMembers / unMuteAllMembers

正常 cases
126. `tests/group/test_group_moderation.py::test_group_mute_all_unmute_all_success`
     群主对全群执行 muteAll/unMuteAll，校验同步响应、全员禁言状态回调与服务端状态变化。

异常 cases
127. `tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[muteAllMembers-info2-600-do not find this group]`
     对不存在群执行 muteAllMembers，冻结 `600/do not find this group` 错误语义。
128. `tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[unMuteAllMembers-info3-600-do not find this group]`
     对不存在群执行 unMuteAllMembers，冻结 `600/do not find this group` 错误语义。

### addWhiteList / removeWhiteList

正常 cases
129. `tests/group/test_group_moderation.py::test_group_add_remove_white_list_success`
     群主对白名单成员执行 addWhiteList/removeWhiteList，校验同步响应、成员回调与服务端白名单变化。

异常 cases
130. `tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[addWhiteList-info4-600-do not find this group]`
     对不存在群执行 addWhiteList，冻结 `600/do not find this group` 错误语义。
131. `tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[removeWhiteList-info5-600-do not find this group]`
     对不存在群执行 removeWhiteList，冻结 `600/do not find this group` 错误语义。

### updateGroupExt

正常 cases
132. `tests/group/test_group_moderation.py::test_group_update_group_ext_success`
     群主更新群扩展信息，校验同步响应与服务端 ext 回显一致。

异常 cases
133. `tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[updateGroupExt-info6-600-do not find this group]`
     对不存在群执行 updateGroupExt，冻结 `600/do not find this group` 错误语义。

## fetchGroupMembersInfo

正常 cases
134. `tests/group/test_group_member_info.py::test_group_fetch_members_info_contains_updated_own_profile`
     当前用户更新 `nickName/avatarUrl` 后创建群并拉取 `fetchGroupMembersInfo`，校验返回成员列表包含当前用户，且 `userId/memberId/joinTime/namecard/nickname/avatarUrl/role/string` 字段可正常获取，其中 `nickname/avatarUrl` 与 `fetchUserInfoById` 最新结果一致。
135. `tests/group/test_group_remaining_api_coverage.py::test_group_fetch_members_info_invalid_limit`
     `limit=0` 拉取群成员详情，冻结当前容错语义：返回 `cursor=""` 且列表包含 owner 的成员详情。

异常 cases
136. `tests/group/test_group_remaining_api_coverage.py::test_group_fetch_members_info_empty_group_id`
     `groupId=""` 拉取群成员详情，冻结实测错误：`code=600`，`description=Group ID is invalid`。

## clearAllGroupsFromLocal

正常 cases
137. `tests/group/test_group_remaining_api_coverage.py::test_group_clear_all_groups_from_local_success`
     调用 `clearAllGroupsFromLocal`/`clearAllGroupsFromDB` 清理本地群缓存，冻结实测成功返回 `result=None`。

异常 cases
无（该接口无业务入参，本轮未观察到稳定异常路径）。

## updateGroupAvatar

正常 cases
138. `tests/group/test_group_remaining_api_coverage.py::test_group_update_avatar_success`
     群主更新群头像 URL，冻结返回群对象中的 `groupId/name/owner/avatarUrl` 等关键字段。
139. `tests/group/test_group_remaining_api_coverage.py::test_group_update_avatar_abnormal_values[]`
     `avatarUrl=""` 更新群头像，冻结当前容错语义：成功返回群对象且 `avatarUrl=""`。
140. `tests/group/test_group_remaining_api_coverage.py::test_group_update_avatar_abnormal_values[https://example.com/...超长]`
     超长 `avatarUrl` 更新群头像，冻结当前容错语义：成功返回群对象且 `avatarUrl` 为传入值。

异常 cases
141. `tests/group/test_group_remaining_api_coverage.py::test_group_update_avatar_empty_group_id`
     `groupId=""` 更新群头像，冻结实测错误：`code=600`，`description=Group ID is invalid`。

## 本批新增组合场景

正常 cases
142. `tests/group/test_group_joined_groups.py::test_group_joined_lists_follow_invite_remove_readd_and_member_leave`
     B 经历邀请加入、群主移除、再次加入和主动退出四阶段；每阶段分别查询本地/服务端列表，
     目标群存在时严格匹配完整成员对象，不存在时目标 groupId 投影必须为空。
143. `tests/group/test_group_public_groups_count.py::test_group_public_groups_cursor_paginates_two_created_groups`
     创建两个 `style=3` 公开群，以 `pageSize=1` 使用真实 cursor 连续翻页，精确找到两个
     动态 `groupId/name`，并断言 cursor 变化和 groupId 不重复。
144. `tests/group/test_group_announcement.py::test_group_admin_update_announcement_notifies_owner`
     B 被提升为管理员后更新公告，群主 A 收到精确回调，操作者 B 不收到同类事件，
     服务端公告值一致。
145. `tests/group/test_group_join_requests_and_invitations.py::test_group_invitation_auto_accept_when_confirmation_required`
     B 保持 `autoAcceptGroupInvitation=true`，A 分别创建 style 0/1/2/3 且
     `inviteNeedConfirm=true` 的群并邀请 B；四种 style 的创建快照均先返回 `memberCount=1`，
     B 收到自动接受事件，A 收到接受事件及两类加入事件，最终服务端 `memberCount=2` 且
     `memberList=[B]`。4 条真实双设备 strict case 全部通过；结合 `inviteNeedConfirm=false`
     的四种 style 用例，创建参数组合已覆盖 8/8。
146. `tests/group/test_group_shared_files.py::test_group_admin_upload_remove_shared_file_notifies_owner`
     B 被提升为管理员后上传/删除 Android 本地素材，群主 A 收到新增/删除事件，操作者 B
     不收到同类事件，最终文件列表为空。

## 第二阶段：群类型、邀请/申请状态与群主权限矩阵

以下 29 个测试函数展开为 `66 items`，均使用真实 A/B 设备；同步响应之外，同时断言事件接收端、
无事件等待窗口和服务端最终状态。严格失败仅指 SDK 实际行为与 API 契约不一致，详见
`CASES_FAILURES.zh.md`。

| 编号 | 测试函数 | 展开场景 | Items | 结果 |
|---|---|---|---:|---|
| 147 | `test_group_join_public_group_rejects_every_non_open_style` | `joinPublicGroup` 对 style 0/1/2 均拒绝 | 3 | 通过 |
| 148 | `test_group_request_to_join_rejects_every_non_approval_style` | `requestToJoinPublicGroup` 对 style 0/1/3 均应拒绝 | 3 | 2 通过，style 3 已知问题 skip |
| 149 | `test_group_direct_invite_ignores_auto_accept_disabled_when_confirmation_not_required` | `inviteNeedConfirm=false + autoAccept=false` 仍直接入群 | 1 | 通过 |
| 150 | `test_group_create_group_invites_member_for_each_remaining_style` | `createGroup.inviteMembers` 覆盖 style 1/2/3 | 3 | 通过 |
| 151 | `test_group_owner_can_invite_for_each_remaining_style` | 群主分别用 `inviterUser/addMembers` 邀请 style 1/2/3 | 6 | 通过 |
| 152 | `test_group_member_invitation_permission_depends_on_style` | style 0/1 × 普通成员/管理员 × 两个邀请 API | 8 | 6 通过，style 0 管理员两条 skip |
| 153 | `test_group_non_member_cannot_invite_user` | 非成员分别调用 `inviterUser/addMembers` | 2 | 通过 |
| 154 | `test_group_public_open_join_rejects_duplicate_membership` | style 3 重复加入 | 1 | 通过，`601` |
| 155 | `test_group_public_open_join_rejects_when_group_is_full` | style 3 达到 `maxCount` 后加入 | 1 | 通过，`604` |
| 156 | `test_group_public_open_join_rejects_blocked_user` | style 3 黑名单用户重新加入 | 1 | 通过，`613` |
| 157 | `test_group_join_application_valid_group_without_pending_is_rejected` | 有效审批群无 pending 时同意/拒绝 | 2 | 通过，`110` |
| 158 | `test_group_join_application_empty_reason_uses_server_default` | 空申请原因回调规范化为 `apply to join`，pending 可正常处理 | 1 | 通过 |
| 159 | `test_group_duplicate_join_application_keeps_single_pending_request` | 同一用户重复申请，仅一个 pending 可处理 | 1 | 通过 |
| 160 | `test_group_join_application_cannot_be_processed_twice` | 同意两次、拒绝两次、同意后拒绝、拒绝后同意 | 4 | 通过 |
| 161 | `test_group_join_application_processing_permission_by_role` | 普通成员/管理员 × 同意/拒绝 | 4 | 3 通过，管理员同意回调字段已知问题 skip |
| 162 | `test_group_non_member_cannot_process_join_application` | 非成员同意/拒绝申请 | 2 | 通过，`603` |
| 163 | `test_group_invitation_valid_group_without_pending_is_rejected` | 有效群无 pending 时同意/拒绝邀请 | 2 | 通过，`603` |
| 164 | `test_group_invitation_wrong_inviter_does_not_consume_pending` | 错误 inviter 同意/拒绝后再由正确 inviter 接受 | 2 | 2 条已知问题 skip |
| 165 | `test_group_invitation_cannot_be_processed_twice` | 同意两次、拒绝两次、同意后拒绝、拒绝后同意 | 4 | 通过 |
| 166 | `test_group_transfer_owner_to_admin_normalizes_roles` | 转让给管理员后角色列表和双方事件归一化 | 1 | 通过 |
| 167 | `test_group_transfer_owner_target_boundaries` | 转给自己、非成员、不存在用户、空用户 | 4 | 通过 |
| 168 | `test_group_non_owner_cannot_transfer_ownership` | 普通成员/管理员越权转让 | 2 | 通过，`603` |
| 169 | `test_group_non_member_cannot_transfer_ownership` | 非成员越权转让 | 1 | 通过，`603` |
| 170 | `test_group_transfer_then_new_owner_removes_former_owner` | 转让后新群主移除原群主 | 1 | 通过 |
| 171 | `test_group_remove_current_owner_is_ignored` | 成员列表包含现任群主时不得移除群主 | 1 | 通过，状态不变 |
| 172 | `test_group_owner_removes_admin_success` | 群主移除管理员 | 1 | 通过 |
| 173 | `test_group_remove_other_member_permission_by_role` | 普通成员越权、管理员移普通成员 | 2 | 通过 |
| 174 | `test_group_owner_must_transfer_before_leaving` | 群主直接退群失败，转让后原群主可退出 | 1 | 通过 |
| 175 | `test_group_batch_remove_ignores_owner_and_non_member_but_removes_valid_member` | 批量名单混合群主、有效成员、非成员 | 1 | 通过，仅移除有效成员 |

## 第三阶段：群消息发送与群回执归档

| 编号 | 测试函数 | 展开场景 | Items | 结果 |
|---|---|---|---:|---|
| 176 | `test_group_message_send_receive_by_type` | `txt/file/image/video/voice/location/cmd/custom` 八种群消息；A 发送、B 接收 | 8 | 真实双设备严格通过 |
| 177 | `test_group_message_send_receive_combine` | 同群两条真实文本作为来源，再发送/接收 `combine` | 1 | 真实双设备严格通过 |
| 178 | `test_group_message_ack_boundary_methods` | 非法群消息 ID/群 ID 调用 `ackGroupMessageRead` | 1 | 真实设备严格通过 |
| 179 | `test_group_message_read_ack_updates_count` | 真实群文本消息；B read-ack；A 统计 `groupAckCount` | 1 | 真实双设备严格通过，最终 `groupAckCount=1` |
| 180 | `test_group_message_send_rejects_invalid_group_target` | 空 groupId、不存在 groupId | 2 | 真实双设备严格通过；分别为 `500`、`606` |
| 181 | `test_group_message_send_rejects_non_member_states` | 从未入群、主动退出、被群主移除后发送 | 3 | 真实双设备严格通过；均为 `602` |

### 群消息发送类型覆盖审计

- 正常消息类型覆盖：`9/9`。发送同步响应、A 端 `onMessageSuccess`、B 端 `onMessagesReceived` 或 `onCmdMessagesReceived` 均严格关联本次临时/真实 msgId，并冻结 `chatType=1`、`to/convId=groupId`。
- 群回执正常和非法 ID case 已从 Chat 模块迁移到本文件对应测试，不再重复归入 Chat。
- 按用户最新范围，正常群 read-ack case 仅验证 A 端同一真实 `msgId` 的 `groupAckCount=1`，不等待回调或查询回执明细。
- ChatThread 的群父消息与 ChatThread API case 已统一归档到 Group；父消息只作为 thread 前置，不计为独立群消息发送覆盖。
- 空/不存在 groupId、从未入群、主动退出和被移除后的发送边界均已补齐；类型构造和媒体路径异常由同一 `ChatManager.sendMessageWithType` 的 Chat 公共矩阵覆盖，不再按 chatType 重复。
- 真实错误：空 groupId 为 `500/Message is invalid`；不存在群为 `606/Group does not exist`；三种非成员状态均为 `602/User has not joined the group`。失败消息均确认未投递给另一真实设备。

## 第四阶段：ChatThread 群组归档

| 编号 | 测试函数 | 展开场景 | Items | 结果 |
|---|---|---|---:|---|
| 182 | `test_chat_thread_remove_member_updates_member_list` | A 创建群父消息和 thread，B 加入后由 A 移除，查询成员列表确认 B 消失；当前 Android 未稳定派发 `onUserKickOutOfChatThread`，不伪造回调断言 | 1 | 按真实成员状态断言 |
| 183 | `test_chat_thread_fetch_detail_and_lists` | thread 详情、线程会话、当前用户已加入列表、指定群 thread 列表和指定群已加入列表 | 1 | 已覆盖 |
| 184 | `test_chat_thread_fetch_members_and_latest_message` | thread 成员列表和未发送线程消息时的最新消息映射 | 1 | 已覆盖 |
| 185 | `test_chat_thread_update_name_and_leave` | 更新 thread 名称、双方更新事件、B 退出及已加入列表变化 | 1 | 已覆盖 |
| 186 | `test_chat_thread_destroy_event_received_by_group_member` | 解散 thread，群成员收到销毁事件并校验稳定字段 | 1 | 已覆盖 |

## 第五阶段：群主、管理员、普通成员权限矩阵

以下 `7` 个测试函数展开为 `18 items`。使用两台真实 Android 模拟器和三个 REST 测试账号：
群主 A 常驻 deviceA、成员/管理员 B 常驻 deviceB；管理员操作需要目标成员回调时，将 deviceA
临时从 A 切换为 C，完成回调断言后恢复 A，再由 A 查询服务端最终状态并销群。

| 编号 | 测试函数 | 展开场景 | Items | 结果 |
|---|---|---|---:|---|
| 187 | `test_group_mute_members_role_permission_matrix` | 群主/管理员禁言与解除禁言成功；普通成员返回 `603/group admin permission is required` | 3 | 真实双设备严格通过 |
| 188 | `test_group_mute_all_role_permission_matrix` | 群主/管理员切换全员禁言成功并收到 `isAllMuted=true/false`；普通成员返回 `603` | 3 | 真实双设备严格通过 |
| 189 | `test_group_allow_list_role_permission_matrix` | 群主/管理员增删白名单成功并收到精确成员回调；普通成员返回 `603` | 3 | 真实双设备严格通过 |
| 190 | `test_group_blocklist_admin_member_role_matrix` | 当前真实 SDK 允许管理员增删黑名单并移出成员；普通成员返回 `603` | 2 | 真实双设备严格通过 |
| 191 | `test_group_metadata_admin_member_role_matrix` | 当前真实 SDK 允许管理员修改名称、描述、扩展并通知群主；普通成员三个 API 均返回稳定 `603` | 2 | 真实双设备严格通过 |
| 192 | `test_group_destroy_owner_only_role_denied` | 管理员、普通成员均不能销群，返回 `603/group owner permission is required`，群保持可查询 | 2 | 真实双设备严格通过 |
| 193 | `test_group_message_block_role_matrix` | 群主、管理员、普通成员均可屏蔽/取消屏蔽群消息，分别冻结 `messageBlocked=true/false` | 3 | 真实双设备严格通过 |

### 第五阶段真实返回补充

- `blockMembers` 与群资料修改的管理员路径在当前 Android SDK 均成功，与 `group_manager.dart`
  中部分“仅群主”注释不一致；本矩阵按真实 ADB/WS 返回冻结。
- `blockGroup/unblockGroup` 的群主、管理员、普通成员三种角色均成功；群主成功行为与
  “群主不能屏蔽群消息”的 SDK 注释不一致。
- `removeWhiteList` 返回 `result=true` 且目标端收到
  `onAllowListRemovedFromGroup.members=[target]`；但随后目标账号调用
  `isMemberInWhiteListFromServer` 仍稳定返回 `true`，本 case 按真实返回断言并保留该语义差异。
- 群资料变更回调的 `memberList/adminList` 会随端侧缓存时机出现/缺失；事件严格断言稳定的
  `groupId/name/desc/owner/memberCount/permissionType`，成员与管理员列表由最终服务端群快照精确断言。

## 第六阶段：群组离线再上线专项

以下 `24` 个测试函数展开为 `31 items`。仅使用 A/B 两台 Android 模拟器：A 固定承担群主或
发送方，B 承担受邀者、申请人、群成员或观察方；离线统一使用 SDK `logout/login` 窗口。

### 群邀请与入群申请

| 编号 | 测试函数 | 展开场景 | Items | 结果 |
|---|---|---|---:|---|
| 194 | `test_group_offline_invitation_received_and_processed_after_login` | B 离线收到邀请；上线后分别接受、拒绝 | 2 | 真实双设备严格通过 |
| 195 | `test_group_offline_owner_receives_invitation_result_after_relogin` | A 离线期间 B 接受、拒绝邀请；A 重登验证结果与成员终态 | 2 | 真实双设备严格通过 |
| 196 | `test_group_offline_owner_receives_join_application_and_processes_after_login` | A 离线收到 B 的入群申请；上线后分别同意、拒绝 | 2 | 真实双设备严格通过 |
| 197 | `test_group_offline_applicant_receives_application_result_after_relogin` | B 申请后离线；A 同意、拒绝；B 重登验证结果与 joined 状态 | 2 | 真实双设备严格通过 |

### 群聊消息离线投递

| 编号 | 测试函数 | 场景 | Items | 结果 |
|---|---|---|---:|---|
| 198 | `test_group_offline_text_message_received_after_login` | B 离线时 A 发送群文本；B 重登按真实服务端 msgId 接收并查询本地消息 | 1 | 严格通过 |
| 199 | `test_group_offline_multiple_text_messages_and_conversation_state` | B 离线积压 3 条文本；重登验证消息集合、未读数 3 和最新消息 | 1 | 严格通过 |
| 200 | `test_group_offline_cmd_deliver_online_only_not_received_after_login` | CMD `deliverOnlineOnly=true`；B 重登后无目标事件且本地查不到消息 | 1 | 严格通过 |
| 201 | `test_group_offline_sender_reads_ack_count_after_relogin` | A 离线期间 B read-ack；A 重登同步服务端回执状态后只断言 `groupAckCount=1` | 1 | 严格通过 |
| 202 | `test_group_offline_message_recalled_before_first_recipient_login` | B 首次接收前 A 撤回；重登验证撤回语义和本地终态 | 1 | 严格通过 |
| 203 | `test_group_offline_recipient_receives_recall_after_relogin` | B 已接收后离线，A 撤回；B 重登验证撤回和本地终态 | 1 | 严格通过 |
| 204 | `test_group_offline_recipient_receives_content_change_after_relogin` | B 离线期间 A 修改群消息；B 重登验证修改事件与最终正文 | 1 | 严格通过 |

### 成员终态变化

| 编号 | 测试函数 | 场景 | Items | 结果 |
|---|---|---|---:|---|
| 205 | `test_group_offline_member_removed_state_after_login` | B 离线被移出；重登验证移出事件、成员列表和 joined 清理 | 1 | 严格通过 |
| 206 | `test_group_offline_member_blocked_state_after_login` | B 离线被加入黑名单；重登验证非成员、blockList、joined 清理及重新加入返回 `613/blacklist` | 1 | 严格通过 |
| 207 | `test_group_offline_group_destroyed_state_after_login` | B 离线期间群被解散；重登验证销群事件、本地群与服务端群均不存在 | 1 | 严格通过 |
| 208 | `test_group_offline_member_leave_state_persists_after_relogin` | B 主动退出后 logout/login；验证退出终态保持 | 1 | 严格通过 |

### 角色与群配置

| 编号 | 测试函数 | 展开场景 | Items | 结果 |
|---|---|---|---:|---|
| 209 | `test_group_offline_admin_add_remove_final_state` | B 离线期间添加、移除管理员 | 1 | 严格通过 |
| 210 | `test_group_offline_owner_transfer_final_state` | B 离线期间成为群主；验证 owner 与权限迁移 | 1 | 严格通过 |
| 211 | `test_group_offline_metadata_final_state` | 名称、描述、头像、扩展字段分别修改 | 4 | 真实返回严格通过 |
| 212 | `test_group_offline_announcement_final_state` | B 离线期间修改公告 | 1 | 严格通过 |
| 213 | `test_group_offline_member_mute_unmute_final_state` | B 离线期间禁言、解除禁言 | 1 | 严格通过 |
| 214 | `test_group_offline_mute_all_unmute_all_final_state` | B 离线期间全员禁言、解除 | 1 | 严格通过 |
| 215 | `test_group_offline_allow_list_add_remove_final_state` | B 离线期间加入、移出白名单 | 1 | 严格通过 |
| 216 | `test_group_offline_member_attributes_final_state` | B 修改成员属性时 A 离线；A 重登查询最终属性 | 1 | 严格通过 |
| 217 | `test_group_offline_shared_file_upload_delete_final_state` | B 离线期间上传、删除共享文件；重登查询最终列表 | 1 | 严格通过 |

### 第六阶段真实返回补充

- 邀请拒绝接口成功且成员终态正确，但当前 Android 链路没有向邀请方回放拒绝结果事件；case
  使用独立负向事件窗口和最终成员状态验收，不伪造回调。
- A 重登后直接查询离线 read-ack 的 `groupAckCount` 稳定为 `0`；调用
  `asyncFetchGroupAcks` 同步服务端回执后 count 为 `1`。case 不断言回执详情，只保留用户要求的
  read-ack 后 count 业务结果。
- 当前 Android 实测名称和描述更新后的服务端字段为空字符串；头像和扩展字段返回请求值，均按
  本轮日志冻结，没有用请求值自证预期。
- B 重登后的白名单成员检查为加入后 `true`、移出后 `false`；群主端白名单列表始终包含群主，
  因此分别为 `[A,B]` 和 `[A]`。
- 共享文件事件中的名称可能为编码值，而服务端列表名称为 `bigPic.jpg`；跨设备最终列表按同一
  `fileId/owner/createTime/fileSize` 严格关联，删除后列表为空。
- 补齐真实离线回放事件断言后的四文件联合严格结果：
  `31 passed, 1 warning in 391.78s`；证据目录为
  `out/group_offline_20260730_185752/`。

## 统计
- 当前记录测试函数条目：`217`；第二阶段新增 `29` 个函数、展开 `66 items`；第三阶段累计 `6` 个函数、展开 `16 items`；第四阶段迁移 `5` 个 ChatThread 函数、展开 `5 items`；第五阶段新增 `7` 个函数、展开 `18 items`；第六阶段新增 `24` 个函数、展开 `31 items`。
- 第二阶段逐文件严格结果：`60 passed, 6 failed`；原邀请/申请文件为 `10 passed, 1 failed`。
- 当前 pytest 收集：`297 items`。
- 已完成的 Group 全量（补空原因 case 前）：`215 passed, 7 failed, 1 skipped, 1 warning in 718.82s`，
  共 `223 items`；随后新增的空原因 case 单独实跑为 `1 passed`，因此当前代码全部 case 的已验证
  合并统计为 `216 passed, 7 failed, 1 skipped`。
- 按用户指令不再重复全量；已启动的第二次回归在 `47 passed, 1 skipped` 时停止，该阶段无新增失败。
- 当前 7 个历史失败参数已改为精确 skip；定向执行结果为 `7 skipped`，未重跑 Group 全量。
- 第二阶段真实 ADB 证据目录：`out/group_matrix_20260723/`。
- 第三阶段 11 个 items 已分批完成真实双设备 strict 验证；初次媒体状态差异按真实值收紧后，失败项复跑通过，群回执双端事件补强后单条复跑通过。按用户要求未重复完整 Group 模块回归。
- 第三阶段新增 5 个发送边界 items：真实双设备同 session strict 为 `5 passed`；未重复原 11 个正常/回执 items。
- 第五阶段 discovery 后按真实返回收紧；新增文件严格结果为
  `18 passed, 1 warning in 151.67s`，未重复 Group 全模块回归。
- 第六阶段四文件联合 strict 为 `31 passed, 1 warning in 391.78s`；`py_compile`、
  `31 tests collected`、断言反模式扫描、`git diff --check` 和 speckit 均通过。
