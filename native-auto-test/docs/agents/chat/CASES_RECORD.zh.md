# Chat 模块 Cases 总记录（按 API）

— 说明
- 本文件记录 Chat 模块已覆盖用例（按 API 组织）。
- ChatThread API 属于群组场景，相关 5 个 cases 已迁移到 `tests/group/`；本台账仅保留单聊 ChatManager 与单聊消息公共 API，不重复记录 Thread 用例。
- 每条 case 以全局序号编号；统计按“当前记录条目数”计算。
- 暂缓与 skip 项统一写 `CASES_DEFERRED.zh.md`。
- Allure：Chat 活动用例已补充按业务目标命名的步骤；消息/回调/离线用例保留原有断言与拓扑流程，跳过项继续展示明确原因。

## getConversation

正常 cases
1. `tests/chat/test_chat_s1_local_conversation.py::test_chat_get_conversation_success`
   先创建会话再查询会话，校验返回会话核心字段完整且可用于后续链路。

异常 cases
2. `tests/chat/test_chat_s1_local_conversation.py::test_chat_get_conversation_not_exist_without_create`
   未预先创建会话直接查询，验证返回“未命中会话”语义稳定。
3. `tests/chat/test_chat_s1_local_conversation.py::test_chat_get_conversation_empty_conv_id`
   传空会话 ID 查询，验证空入参场景的返回结构与错误语义。

## getUnreadCount / markAllMessagesAsRead

正常 cases
4. `tests/chat/test_chat_s1_local_conversation.py::test_chat_get_unread_count_positive_then_zero`
   先制造未读再读取计数并清零，按当前 Android 实测冻结 `markAllChatMsgAsRead result=True` 与未读数变化。
5. `tests/chat/test_chat_s1_local_conversation.py::test_chat_mark_all_as_read_idempotent`
   连续执行全部已读操作，按当前 Android 实测冻结幂等返回 `result=True` 且未读数保持为 0。

异常 cases
6. 无（当前未单独覆盖错误入参）。
   该组 API 目前以主链路行为验证为主，异常入参待补充到 deferred 计划。

## loadAllConversations / deleteConversation / deleteMessagesBeforeTimestamp

正常 cases
7. `tests/chat/test_chat_s1_local_conversation.py::test_chat_load_all_conversations_contains_then_not_contains`
   拉取本地会话列表，验证目标会话在创建后可见、删除后不可见。
8. `tests/chat/test_chat_s1_local_conversation.py::test_chat_delete_conversation_existing_then_not_found`
   删除已存在会话并再次查询，验证删除结果与后置状态一致。
9. `tests/chat/test_chat_s1_local_conversation.py::test_chat_delete_conversation_nonexistent_returns_bool`
   删除不存在会话，验证当前端返回布尔语义稳定。
10. `tests/chat/test_chat_s1_local_conversation.py::test_chat_delete_messages_before_timestamp_future_removes_msg`
   以前瞻时间戳删除消息，验证命中范围消息被正确清理。
11. `tests/chat/test_chat_s1_local_conversation.py::test_chat_delete_messages_before_timestamp_zero_keeps_recent_msg`
   以零时间戳删除消息，验证不应误删近期消息。

异常 cases
12. 无（当前未单独覆盖错误入参）。
   当前重点覆盖本地会话维护主路径，错误参数待后续补齐。

## sendMessage / onMessageSuccess / onMessagesReceived

正常 cases
13. `tests/chat/test_chat_crud.py::test_chat_send_and_received`
   场景拓扑：动作发送端发送；发送账号的其他在线端收到 `direction=0` 的同账号出站同步并可 `getMessage` 查询（`hasDeliverAck` 在该同步事件中端侧返回不稳定，不作为契约）；接收账号的全部在线端均收到 `direction=1` 的入站消息并可查询；动作发送端严格断言与接收在线端数量一致的送达回执。Android 4.23 四端实机通过。
14. `tests/chat/test_chat_send_with_type.py::test_send_message_with_type_text_basic`
   发送基础文本消息，验证普通文本类型发送与接收成功。
15. `tests/chat/test_chat_send_with_type.py::test_send_message_with_type_text_with_languages`
   发送带 `targetLanguages=[zh-Hans]` 的文本内容；当前 Android 实测发送成功，发送方与接收方消息 body 均返回目标语言及非空 `translations`，按真实消息 ID 严格断言完整翻译链路。
16. `tests/chat/test_chat_send_with_type.py::test_send_message_with_type_file`
   发送文件消息，校验文件消息类型和关键元数据字段。
17. `tests/chat/test_chat_send_with_type.py::test_send_message_with_type_image`
   发送图片消息，校验图片消息体字段与接收事件一致。
18. `tests/chat/test_chat_send_with_type.py::test_send_message_with_type_video`
   发送视频消息，校验视频类型消息在双端链路可用。

异常 cases
19. `tests/chat/test_chat.py::test_chat_send_to_self_should_not_succeed`
   向自己发送消息，验证该异常路径不应按普通成功语义通过。
20. `tests/chat/test_chat_crud.py::test_chat_send_to_self_event`
   向自己发送消息时，补充校验事件侧返回是否符合当前端行为。

## getMessage / translateMessage

正常 cases
21. `tests/chat/test_chat_crud.py::test_chat_translate_message_basic`
   对有效消息执行翻译，验证翻译接口成功与翻译结果字段存在。

异常 cases
22. `tests/chat/test_chat_crud.py::test_chat_get_message_invalid_id_returns_none`
   以无效消息 ID 查询消息，验证返回空结果语义稳定。
23. `tests/chat/test_chat.py::test_chat_get_message_invalid_id_returns_none_or_error`
   兼容端差异校验无效消息 ID 可返回空或错误的稳定语义。
24. `tests/chat/test_chat.py::test_chat_translate_message_nonexistent_message`（当前可为 skip/环境语义，暂缓细节见 deferred）
   不存在消息执行翻译，当前环境可能 skip，语义冻结在 deferred 中维护。
25. `tests/chat/test_chat_crud.py::test_chat_translate_message_recalled_message`
   接收账号全部在线端收到原消息、撤回信息和撤回消息本体，验证已撤回消息的回调传播语义。

## recallMessage / modifyMessage

正常 cases
26. 无（当前记录以异常语义为主）。
   当前阶段优先冻结非法消息 ID 的错误基线，正常链路后续再补。

异常 cases
27. `tests/chat/test_chat_crud.py::test_chat_recall_message_invalid_id_response`
   撤回不存在消息，冻结错误码与错误文案关键字段。
28. `tests/chat/test_chat.py::test_chat_recall_message_invalid_id_response`
   以另一测试入口复核撤回非法 ID 的响应一致性。
29. `tests/chat/test_chat_crud.py::test_chat_modify_message_invalid_id_response`
   修改不存在消息，验证接口返回错误而非误判成功。
30. `tests/chat/test_chat.py::test_chat_modify_message_invalid_id_response`
   跨文件复核修改非法 ID 的错误语义一致。

## ackMessageRead / ackConversationRead

正常 cases
31. `tests/chat/test_chat_crud.py::test_chat_ack_message_read_success`
   场景拓扑：B 发消息后，A 主/副端均收到；A 主端回执已读，B 断言 `onMessagesRead`。5.0 使用 `needReadReceipt` 表示请求已读回执、`isPeerRead` 表示对方是否已读；当前修改待 Android 5.0 实机回归。
32. `tests/chat/test_chat_ack_read_strict.py::test_chat_ack_message_read_success_with_event`
   已读回执成功后按当前 Android 实测冻结同步响应 `result=True`，并补充校验发送方已读事件。
33. `tests/chat/test_chat_s3_non_message_ops.py::test_chat_ack_conversation_read_success_with_event`
   会话级已读回执成功，按当前 Android 实测冻结同步响应 `result=True`，并校验会话维度已读事件。

异常 cases
34. `tests/chat/test_chat_ack_read_strict.py::test_chat_ack_message_read_invalid_msg_id`
   对非法消息 ID 回执已读，当前 Android 实测返回 `result=True`，按现状语义冻结。
35. `tests/chat/test_chat_crud.py::test_chat_ack_conversation_read_invalid_id_response`
   使用无效会话 ID 做会话已读回执，按 SDK 参数 `convId` 调用并冻结业务错误 `500/Message is invalid`。
36. `tests/chat/test_chat.py::test_chat_ack_conversation_read_invalid_id_response`
   在历史兼容入口复核无效会话 ID 的业务错误一致性。
37. `tests/chat/test_chat_s3_non_message_ops.py::test_chat_ack_conversation_read_invalid_conv_id`
   明确非法会话 ID 参数时，按 SDK 参数 `convId` 调用并冻结业务错误 `500/Message is invalid`。
38. `tests/chat/test_chat_s3_non_message_ops.py::test_chat_ack_conversation_read_empty_conv_id`
   传空会话 ID 回执会话已读，按 SDK 参数 `convId` 调用并冻结业务错误 `500/Message is invalid`。

## addReaction / removeReaction / fetchReactionList / fetchReactionDetail

正常 cases
39. `tests/chat/test_chat_reaction_fetch.py::test_chat_add_reaction_duplicate_reaction`
   对同一消息重复添加相同 reaction，验证当前端容忍与返回稳定。
40. `tests/chat/test_chat_reaction_fetch.py::test_chat_remove_reaction_not_exists_reaction`
   删除不存在的 reaction，验证接口可稳定返回且不影响主流程。
41. `tests/chat/test_chat_reaction_fetch.py::test_chat_add_reaction_special_char_reaction`
   reaction 使用特殊字符，验证字符边界输入的兼容性。

异常 cases
42. `tests/chat/test_chat_crud.py::test_chat_add_reaction_invalid_id_response`
   对非法消息 ID 添加 reaction，冻结错误码与错误描述。
43. `tests/chat/test_chat.py::test_chat_add_reaction_invalid_id_response`
   在兼容入口复核非法 ID 添加 reaction 的错误语义。
44. `tests/chat/test_chat_crud.py::test_chat_add_reaction_empty_reaction_response`
   reaction 为空字符串时调用，验证参数非法语义。
45. `tests/chat/test_chat.py::test_chat_add_reaction_empty_reaction_response`
   跨文件复核空 reaction 入参的错误一致性。
46. `tests/chat/test_chat_crud.py::test_chat_remove_reaction_invalid_id_response`
   对非法消息 ID 删除 reaction，验证错误语义稳定。
47. `tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_list_invalid_msg_id`
   以非法消息 ID 批量拉取 reaction 列表，验证错误返回。
48. `tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_list_empty_msg_ids`
   消息 ID 列表为空时拉取 reaction 列表，验证参数校验语义。
49. `tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_list_invalid_chat_type`
   chatType 非法时拉取 reaction 列表，验证枚举边界错误语义。
50. `tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_detail_invalid`
   以非法组合参数拉取 reaction 明细，冻结错误基线。
51. `tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_detail_invalid_page_size`
   pageSize 非法时拉取明细，验证分页参数错误语义。
52. `tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_detail_empty_reaction`
   reaction 为空时查询明细，验证空入参处理符合预期。
53. `tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_detail_oversize_page_size`
   pageSize 过大时查询明细，验证上限边界语义。
54. `tests/chat/test_chat_reaction_fetch.py::test_chat_remove_reaction_invalid_msg_id`
   另一入口覆盖非法消息 ID 删除 reaction 的异常链路。
55. `tests/chat/test_chat_reaction_fetch.py::test_chat_add_reaction_too_long_reaction`
   reaction 超长输入，验证长度边界错误语义。

## pinConversation

正常 cases
56. 无（当前 Android 实测有效会话置顶持续返回 `303/concurrent operation are not allowed`，成功 toggle 链路移入 `CASES_DEFERRED.zh.md`）。

异常 cases
57. `tests/chat/test_chat_crud.py::test_chat_pin_conversation_nonexistent_conversation`
   对不存在会话置顶，验证错误返回语义。
58. `tests/chat/test_chat.py::test_chat_pin_conversation_nonexistent_conversation`
   兼容入口复核不存在会话置顶的错误一致性。
59. `tests/chat/test_chat_s3_non_message_ops.py::test_chat_pin_conversation_invalid_conv_id`
   会话 ID 非法格式时置顶，验证参数异常语义。
60. `tests/chat/test_chat_s3_non_message_ops.py::test_chat_pin_conversation_empty_conv_id`
   会话 ID 为空时置顶，验证空值入参校验。

## fetchHistoryMessages / fetchHistoryMessagesByOptions

正常 cases
61. `tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_success`
   拉取会话历史消息，验证基础历史查询链路成功。
62. `tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_by_options_success`
   按 options 条件拉取历史消息，验证过滤参数生效。

异常 cases
63. `tests/chat/test_chat_crud.py::test_chat_fetch_history_invalid_conversation`
   对无效会话拉取历史消息，按 SDK 参数 `convId/type/startMsgId/direction` 调用并冻结当前返回空 `cursor/list` 语义。
64. `tests/chat/test_chat.py::test_chat_fetch_history_invalid_conversation`
   在兼容入口复核无效会话历史查询返回空 `cursor/list` 的一致性。
65. `tests/chat/test_chat_crud.py::test_chat_fetch_history_by_options_invalid_conversation`
   使用 options 接口查询无效会话，验证异常返回。
66. `tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_invalid_conv_id`
   非法会话 ID 拉取历史消息，验证参数异常语义。
67. `tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_empty_conv_id`
   空会话 ID 拉取历史消息，验证空入参语义。
68. `tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_by_options_invalid_conv_id`
   options 接口中会话 ID 非法，验证错误语义。
69. `tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_by_options_empty_conv_id`
   options 接口中会话 ID 为空，验证空入参语义。

## getConversationsFromServer / getConversationsFromServerWithCursor

正常 cases
70. `tests/chat/test_chat_s2_server_ops.py::test_chat_get_conversations_from_server_success`
   服务端拉取会话列表成功，验证分页结果结构可用。
71. `tests/chat/test_chat_s2_server_ops.py::test_chat_get_conversations_from_server_with_cursor_success`
   使用 cursor 拉取服务端会话成功，先制造目标会话并按目标 `convId` 过滤校验，避免历史服务端会话污染空列表预期。
72. `tests/chat/test_chat_s2_server_ops.py::test_chat_get_conversations_from_server_with_cursor_invalid_page_size_zero`（当前端返回成功语义）
   pageSize=0 时当前端仍返回成功结构，冻结现状语义用于回归。
73. `tests/chat/test_chat_s2_server_ops.py::test_chat_get_conversations_from_server_with_cursor_invalid_page_size_negative`（当前端返回成功语义）
   pageSize<0 时当前端仍返回成功结构，作为兼容语义基线。

异常 cases
74. 无（当前端该组异常入参返回成功结构）。
   该组异常参数在当前端表现为成功语义，待端策略明确后再收紧。

## fetchConversationsFromServerWithPage

正常 cases
75. `tests/chat/test_chat_s2_server_ops.py::test_chat_fetch_conversations_from_server_with_page_success`
   按页码与页大小拉取会话成功，验证分页返回字段。
76. `tests/chat/test_chat_s2_server_ops.py::test_chat_fetch_conversations_from_server_with_page_invalid_page_num_zero`（当前端返回成功语义）
   pageNum=0 场景当前端返回成功，冻结该兼容语义。
77. `tests/chat/test_chat_s2_server_ops.py::test_chat_fetch_conversations_from_server_with_page_invalid_page_size_zero`（当前端返回成功语义）
   pageSize=0 场景当前端返回成功，冻结该兼容语义。

异常 cases
78. 无（当前端该组异常入参返回成功结构）。
   该 API 当前无稳定异常返回分支，后续随端行为更新。

## getPinnedConversationsFromServerWithCursor

正常 cases
79. `tests/chat/test_chat_s2_server_ops.py::test_chat_get_pinned_conversations_from_server_with_cursor_success`
   服务端拉取置顶会话列表成功，验证 cursor 分页结构。
80. `tests/chat/test_chat_s2_server_ops.py::test_chat_get_pinned_conversations_from_server_with_cursor_invalid_page_size_zero`（当前端返回成功语义）
   pageSize=0 时当前端仍成功返回，冻结兼容语义。
81. `tests/chat/test_chat_s2_server_ops.py::test_chat_get_pinned_conversations_from_server_with_cursor_invalid_page_size_negative`（当前端返回成功语义）
   pageSize<0 时当前端仍成功返回，冻结兼容语义。

异常 cases
82. 无（当前端该组异常入参返回成功结构）。
   当前端将该组异常参数按成功结构处理，暂不拆分独立异常链路。

## deleteRemoteConversation

正常 cases
83. `tests/chat/test_chat_s2_server_ops.py::test_chat_delete_remote_conversation_success`
   删除服务端会话成功，验证同步响应与后续可见性变化。
84. `tests/chat/test_chat_s2_server_ops.py::test_chat_delete_remote_conversation_invalid_type`（当前端返回成功语义）
   会话类型非法时当前端仍返回成功，冻结兼容语义。

异常 cases
85. `tests/chat/test_chat_s2_server_ops.py::test_chat_delete_remote_conversation_empty_conv_id`
   空会话 ID 删除服务端会话，验证参数错误语义。

## removeMessagesFromServerWithMsgIds

正常 cases
86. `tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_msg_ids_success`
   按消息 ID 集合删除服务端消息成功，验证接口主链路。

异常 cases
87. `tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_msg_ids_empty_msg_ids`
   消息 ID 列表为空时删除，验证空集合参数语义。
88. `tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_msg_ids_missing_msg_ids`（skip）
   缺少 msgIds 参数场景当前为 skip，记录为待环境或端能力补齐。
89. `tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_msg_ids_missing_conv_id`（skip）
   缺少 convId 参数场景当前为 skip，保留异常设计位。

## removeMessagesFromServerWithTs

正常 cases
90. `tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_ts_success`
   按时间戳删除服务端消息成功，验证时间维度清理链路。

异常 cases
91. `tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_ts_timestamp_zero`
   时间戳为 0 时删除消息，验证边界时间入参语义。
92. `tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_ts_missing_timestamp`（skip）
   缺失 timestamp 参数当前为 skip，保留为待补充异常链路。
93. `tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_ts_missing_conv_id`（skip）
   缺失 convId 参数当前为 skip，保留为待补充异常链路。

## reportMessage

正常 cases
94. `tests/chat/test_chat_s2_server_ops.py::test_chat_report_message_success`
   举报有效消息成功，验证举报主流程返回结构。

异常 cases
95. `tests/chat/test_chat_s2_server_ops.py::test_chat_report_message_invalid_msg_id`
   举报非法消息 ID，冻结错误码与错误文案语义。
96. `tests/chat/test_chat_s2_server_ops.py::test_chat_report_message_missing_tag`（skip）
   缺失 tag 参数当前为 skip，保留为待补充参数异常场景。
97. `tests/chat/test_chat_s2_server_ops.py::test_chat_report_message_missing_reason`（skip）
   缺失 reason 参数当前为 skip，保留为待补充参数异常场景。

## searchChatMsgFromDB

正常 cases
98. `tests/chat/test_chat_search_db.py::test_chat_search_chat_msg_from_db_success`
   使用数据库检索接口查询消息，验证搜索主链路成功。
99. `tests/chat/test_chat_crud.py::test_chat_search_chat_msg_from_db_success`
   在 CRUD 套件中复核数据库检索成功语义一致。

异常 cases
100. 无（当前测试集中未单独覆盖该 API 的错误入参）。
   当前仅覆盖成功链路，异常参数场景后续补充。

## fetchSupportLanguages

正常 cases
101. `tests/chat/test_chat_crud.py::test_chat_fetch_support_languages_success`
   拉取翻译支持语言列表成功，验证返回列表字段可用。

异常 cases
102. 无（当前测试集中未单独覆盖该 API 的错误入参）。
   当前端主要覆盖成功语义，异常参数场景待后续补齐。

## loadConversationMessagesWithKeyword

正常 cases
103. `tests/chat/test_chat_s4_local_keyword_search.py::test_chat_load_conversation_messages_with_keyword_success`
   发送消息后按关键字检索本地会话消息，冻结返回 Map 中 `convId -> msgId[]` 的命中语义。
104. `tests/chat/test_chat_s4_local_keyword_search.py::test_chat_load_conversation_messages_with_keyword_no_hit`
   使用不存在关键字检索，冻结无命中返回空 Map 语义。

异常 cases
105. 无（当前批次以该 API 的稳定“无命中”边界语义替代不稳定错误入参）。
   当前环境下“参数错误”语义受端差异影响，暂不纳入 strict 通过门禁。

## loadMessagesWithIds

正常 cases
106. `tests/chat/test_chat_s4_load_messages_by_ids.py::test_chat_load_messages_with_ids_single_and_multi_success`
   按单 ID 与多 ID（含不存在 ID）加载本地消息，冻结“命中返回消息实体、未命中自动忽略”的稳定语义。

异常 cases
107. `tests/chat/test_chat_s4_load_messages_by_ids.py::test_chat_load_messages_with_ids_empty_ids`
   传空 `messageIds`，冻结返回空列表语义。

## sendMessageWithType / downloadAttachment / downloadBigImage / downloadThumbnail / combine

正常 cases
108. `tests/chat/test_chat_s423_message_callback_and_combine.py::test_attachment_messages_send_receive_and_public_download_methods`
   覆盖文件、图片、视频消息发送与接收，并验证 `downloadAttachment`、`downloadBigImage`、`downloadThumbnail` 的同步响应；文件/图片下载按进度与成功事件断言，视频缩略图按当前实测 `onMessageError 403/Failed to download the file` 断言。
109. `tests/chat/test_chat_s423_message_callback_and_combine.py::test_combine_forward_send_receive_and_inner_attachment_download`
   覆盖图片/视频合并转发消息发送、接收、解析，并验证合并消息内部附件下载和缩略图下载；内部下载进度事件当前实测不是稳定必发，若派发则校验范围，最终成功事件仍 strict 断言；视频内部缩略图按当前实测 `onMessageError 403/Failed to download the file` 断言。

异常 cases
110. `tests/chat/test_chat_crud.py::test_chat_download_attachment_invalid_id_response`
   无效消息 ID 下载附件，冻结错误语义。
111. `tests/chat/test_chat_crud.py::test_chat_download_thumbnail_invalid_id_response`
   无效消息 ID 下载缩略图，冻结错误语义。

## EMConversation 本地会话方法

正常 cases
112. `tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_latest_and_last_received_messages`
   发送单聊消息后校验 `latestMessage` 与 `lastReceivedMessage`，覆盖最新消息与最近收到消息查询；接收消息体按当前端返回兼容 `targetLanguages/translations`。
113. `tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_read_count_and_mark_read`
   制造未读消息后校验 `unreadCount`，并覆盖 `markMessageAsRead`、`markAllMessagesAsRead` 的已读清零链路；按 discovery 冻结当前返回 `result=true`。
114. `tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_load_message_and_message_lists`
   覆盖 `loadMsgWithId`、`loadMsgWithStartId`、`loadMsgWithTime`，按 ID、起始消息 ID 和时间窗口加载本地消息。
115. `tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_ext_and_count_queries`
   覆盖 `setExt`、`messagesCount`、`getLocalMessageCount`、`remindType`、`loadPinnedMessages`，校验会话扩展、计数、免打扰和置顶消息查询。
116. `tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_local_insert_append_update_and_delete`
   覆盖 `insertMessage`、`appendMessage`、`updateConversationMessage`、`removeMessage`、`deleteMessagesWithTs`、`clearAllMessages`，验证本地消息写入、更新和删除链路。
117. `tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_delete_local_and_server_messages_current_behavior`
   覆盖 `deleteLocalAndServerMessages`，按消息 ID 删除本地及服务端消息，冻结当前返回 `result=None` 或实测业务错误。

异常/边界 cases
118. `tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_type_keyword_and_options_search_current_behavior`
   覆盖 `loadMessagesWithMsgType`、`loadMessagesWithKeyword`、`searchMsgsByOptions`，使用 `count=0` 和唯一关键词冻结当前空列表边界返回。
119. `tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_invalid_message_id_boundaries`
   覆盖 `loadMessage` 不存在消息 ID、`markMessageAsRead` 不存在消息 ID、`deleteMessageByIds` 空列表，冻结当前端边界返回。
120. `tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_delete_local_and_server_messages_by_time_bridge_missing`
   `deleteLocalAndServerMessagesByTime` 当前 Android 端 direct cmd 返回 `MissingPluginException`，记录为桥接缺口并 xfail；不作为 SDK 业务异常语义。

## EMChatManager 方法级补齐

正常 cases
121. `tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_pin_unpin_and_fetch_pinned_messages`
   覆盖 `pinMessage`、`unpinMessage`、`fetchPinnedMessages`，发送消息后置顶、拉取置顶列表，再取消置顶并确认列表清空；同时断言接收方 `onMessagePinChanged` 置顶/取消置顶事件。
122. `tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_recall_message_receiver_recalled_info_event`
   覆盖 `recallMessage` 正常撤回链路，发送方撤回已送达单聊消息后，接收方收到 `onMessagesRecalledInfo` 事件；按真实模拟器返回断言 `recallMsgId`、`convId`、`msg` 与 `ext`，消息体兼容 `translations` 且 `receiverList` 可选。
123. `tests/chat/test_chat_reaction_fetch.py::test_chat_reaction_change_event_received_by_sender`
   场景拓扑：动作发送端发送消息后，发送账号其他在线端同步原消息并可 `getMessage` 查询，接收账号全部在线端收到消息；接收动作端添加 reaction 后，发送账号与接收账号的全部在线端均收到 `messageReactionDidChange`。严格断言 `convId`、`msgId`、`operations`、`reactions` 与 `isAddedBySelf`；Android 4.23 四端实机通过。
124. `tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_conversation_marks_and_fetch_options`
   覆盖 `addRemoteAndLocalConversationsMark`、`deleteRemoteAndLocalConversationsMark`、`fetchConversationsByOptions`，标记会话后按 options 拉取并校验 mark，再删除标记。
125. `tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_message_count_and_search_options_boundaries`
   覆盖 `getMessageCount` 与 `searchMsgsByOptions`，冻结当前消息总数非负与 `count=0` 搜索返回空列表的边界语义。
126. `tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_delete_all_message_and_conversation_local`
   覆盖 `deleteAllMessageAndConversation`，以 `clearServerData=false` 清理本地消息和会话，冻结实测返回 `result=null`。
127. `tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_message_object_boundary_methods`
   覆盖 `importMessages`、`updateMessage`、`resendMessage`，使用本地构造文本消息导入、更新正文、重发，并冻结更新后消息对象返回。
128. `tests/chat/test_chat_send_with_type.py::test_send_message_with_type_cmd_received_by_cmd_callback`
   覆盖 `sendMessageWithType(type=cmd)` 正常链路，发送 CMD 消息后接收方收到 `onCmdMessagesReceived`；按真实模拟器返回断言 `body.type=6`、`action`、`convId`、`direction` 与消息 ID，`receiverList` 按当前端可选字段处理。

异常/边界 cases
群消息回执的正常与边界 case 已迁移到 `tests/group/test_group_message_send.py`，Chat 模块不再重复统计。

## 统计
- 当前记录 case 条目总数：`132`

## 单聊发送类型覆盖审计（2026-07-23）

| 发送类型 | 正常发送/接收 case | 覆盖状态 |
|---|---|---|
| `txt` | `test_send_message_with_type_text_basic`、`test_send_message_with_type_text_with_languages` | 已覆盖 |
| `file` | `test_send_message_with_type_file` | 已覆盖 |
| `image` | `test_send_message_with_type_image`、`test_send_message_with_type_image_heic` | 已覆盖 |
| `video` | `test_send_message_with_type_video` | 已覆盖 |
| `voice` | `test_chat_missing_voice_message_send_receive` | 已覆盖 |
| `location` | `test_chat_missing_location_message_send_receive` | 已覆盖 |
| `cmd` | `test_send_message_with_type_cmd_received_by_cmd_callback` | 已覆盖 |
| `custom` | `test_chat_missing_custom_message_send_receive` | 已覆盖 |
| `combine` | `test_combine_forward_send_receive_and_inner_attachment_download` | 已覆盖 |

- 正常消息类型覆盖：`9/9`；发送响应、A 端成功事件和 B 端接收事件均已有真实双设备 case。
- 已有发送边界：空文本、特殊字符、250 字符、请求 `from` 与登录用户不一致、发给自己、非好友发送。
- 空/不存在 `targetId`、类型必填 payload 和媒体路径边界已在下节补齐。Dart 静态类型在正常 App 调用中无法传入的任意动态错误类型不计为 SDK 业务 case。

## 单聊发送异常矩阵补齐（2026-07-23）

129. `tests/chat/test_chat_message_send_boundaries.py::test_chat_message_send_target_boundaries`
   展开空目标与动态不存在用户两项。空目标文本消息严格返回 `onMessageError 500/Message is invalid`；不存在用户使用 CMD 避开文本审核干扰，当前真实语义为服务端接受并返回 `onMessageSuccess` 和真实 msgId。两项均确认 deviceB 未误收。
130. `tests/chat/test_chat_message_send_boundaries.py::test_chat_message_type_rejects_missing_required_payload`
   展开 `txt.content`、`location.latitude/longitude`、`cmd.action`、`custom.event` 五项缺失必填字段，bridge 调用公开 Dart 构造 API 后严格返回 `code=-1` 和对应 Null 类型错误。
131. `tests/chat/test_chat_message_send_boundaries.py::test_chat_combine_message_rejects_empty_source_ids`
   `combine.msgIds=[]` 返回异步 `onMessageError 110/The count of combined messages must be between 1 and 300.`，错误消息 envelope 和 B 端无误投递均严格断言；同步响应 `status` 与图片路径错误相同存在 `1/3` 竞态，仅忽略 `result.status` 精确路径。
132. `tests/chat/test_chat_message_send_boundaries.py::test_chat_media_message_rejects_nonexistent_device_path`
   展开 `file/image/video/voice` 四种不存在 Android 路径。四项均返回 `401`；file/voice 文案为 `File movement error.`，image/video 为 `File not exists or can not be read`。图片同步响应的瞬时 `status` 实测在 `1/3` 间竞态，仅忽略 `result.status` 精确路径；最终 `onMessageError.status=3` 及完整消息严格断言。

- 本节共 `4` 个测试函数、`12 items`；真实双设备 strict 同 session 结果为 `12 passed`。
- 不存在用户文本连续发送曾触发服务端 `1200/MODERATION_001`，因此目标语义改用 CMD 冻结；不把审核开关错误当作用户存在性契约。

## 单聊缺失 Case 第一批（5556/5558 实测）

正常 cases
131. `tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_location_message_send_receive`
   场景拓扑：B 通过原生 `sendMessage` 发送 `body.type=3` 位置消息，A 主/副端均断言经纬度、地址和建筑名；本轮 Android 4.23 真实设备通过。
132. `tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_voice_message_send_receive`
   5556 发送语音消息，5558 收到语音消息；按真实日志断言 `body.type=4`、`displayName=voice.mp3`、发送端 `fileStatus=3`、接收端 `fileStatus=0` 和 `duration=1`。动态路径、secret、remotePath、fileSize 不写死。
133. `tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_custom_message_send_receive`
   场景拓扑：B 通过原生 `sendMessage` 发送 `body.type=7` 自定义消息，A 主/副端均断言真实 `event` 和 `params`；本轮 Android 4.23 真实设备通过。
134. `tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_message_delivery_ack[txt-payload0]`
   开启 `requireDeliveryAck=true` 后，文本消息收到 `onMessagesDelivered`，断言真实消息 ID、发送方、接收方、会话和文本 body。
135. `tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_message_delivery_ack[custom-payload1]`
   开启 `requireDeliveryAck=true` 后，自定义消息收到 `onMessagesDelivered`，断言真实消息 ID、参与者和自定义 body。

暂缓 cases
136. `tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_cmd_message_delivery_ack`（skip）
   5556/5558 已开启 `requireDeliveryAck=true`，但当前真实日志只收到 `onCmdMessagesReceived`，未收到 CMD 的 `onMessagesDelivered`；不固化“无事件”预期。

## 单聊缺失 Case 第二批（5556/5558 实测）

137. `tests/chat/test_chat_recall_and_message_read_ack.py::test_chat_missing_recall_typed_message[*]`
   位置/自定义消息撤回；断言撤回结果及接收方 `onMessagesRecalledInfo` 的 recallBy、recallMsgId、convId、msg 和 ext，消息状态字段保留。
138. `tests/chat/test_chat_recall_and_message_read_ack.py::test_chat_missing_recall_empty_message_id`
   空消息 ID 返回 `result={code:500,description:'The message was not found'}`。
139. `tests/chat/test_chat_recall_and_message_read_ack.py::test_chat_missing_ack_message_read_boundaries[*]`
   空/非法消息或接收方参数当前均返回 `result=true`。
140. `tests/chat/test_chat_message_pin_boundaries.py::*`
   置顶、取消置顶及置顶列表无效 ID/空 ID/撤回消息/无效会话边界，冻结 110/107/500 错误。
141. `tests/chat/test_chat_report_message_boundaries.py::test_chat_report_message_empty_*`、`test_chat_report_recalled_message`
   举报参数和撤回消息当前返回 `500 message id is invalid`；类型消息成功场景暂缓，见 deferred。
142. `tests/chat/test_chat_conversation_marks_boundaries.py::*`
   会话标记无效会话返回 107，pageSize 0/-1 返回 110，1000 返回空列表；mark=999 bridge 原始异常暂缓。
143. `tests/chat/test_chat_message_translation_boundaries.py::*`
   空语言和不支持语言返回原消息并保留 `targetLanguages/translations`；自定义消息返回 `1 General error`。
144. `tests/chat/test_chat_attachment_download_and_history_boundaries.py::*`
   发送方图片/视频下载、文本下载和 pageSize=1 历史分页；严格断言消息主体、会话、方向、状态及文本内容，路径/时间等动态字段单独忽略。

## 单聊文档启用场景补齐（5556/5558 实测）

145. `tests/chat/test_chat_text_boundaries_and_location_delivery.py::*`
   覆盖空文本、特殊字符、250 字符、请求 `from` 与登录用户不一致，以及位置消息送达回执。文本边界 case 场景拓扑改造中：B 发文本后 A 主/副端均收并验证送达；其余断言保持原有参与者、会话、方向、状态、已读/送达字段及完整 body；待本轮 Android 4.23 真实设备回归。不匹配 `from` 实测异步返回 `500 Message is invalid`。
146. `tests/chat/test_chat_typed_message_pin_flows.py::*` 与 `tests/chat/test_chat_message_pin_boundaries.py::*`
   覆盖位置/自定义消息由收发双方交叉置顶和取消置顶，以及类型消息撤回后置顶边界；按真实模拟器返回，原始发送方执行 pin/unpin 时仅接收方收到 `onMessagePinChanged`，接收方执行 pin/unpin 当前不产生该回调；通过 `fetchPinnedMessages` 校验最终服务端状态，并保留消息类型、方向、状态、已读/送达等字段。
147. `tests/chat/test_chat_report_and_thumbnail_additional.py::test_chat_receiver_reports_text_message` 与 `test_chat_report_text_message_parameter_boundaries[*]`
   覆盖接收方举报文本消息，并使用有效消息 ID 验证空 `tag`、空 `reason`、异常非空 `tag`：实测分别返回 `205 Invalid parameter`、`true`、`true`，避免被无效消息 ID 的前置错误掩盖。
148. `tests/chat/test_chat_report_and_thumbnail_additional.py::test_chat_download_thumbnail_for_text_message`
   文本消息调用缩略图下载时，同步结果返回完整原消息，随后发送端收到 `onMessageError 403/Failed to download the file`；两段均按真实消息 ID 和完整稳定业务字段断言。
149. `tests/chat/test_chat_conversation_pin_additional.py::*`
   覆盖会话重复置顶/取消置顶、自己会话、非布尔 `isPinned`、pageSize 0/-1/1000。Android generic bridge 实测非布尔值按 `false` 处理，三种 pageSize 均返回空页。
150. `tests/chat/test_chat_conversation_cursor_pagination.py::*`
   创建两个真实单聊会话，置顶后以 pageSize=1 和真实 cursor 分页，并覆盖两个 mark 值查询。服务端 cursor 依赖秒级 `pinnedTime`，用例在两次置顶间拉开时间且先确认两条服务端状态，避免同秒时间戳碰撞漏页。
151. `tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_conversation_mark_idempotent_and_remove_unmarked` 与 `test_chat_conversation_mark_self_current_behavior`
   覆盖重复标记、重复取消、取消未标记、标记自己；正常场景通过目标会话投影断言 `type/isPinned/isThread/marks`，当前环境标记自己会话实测返回 `result=null`。
152. `tests/chat/test_chat_message_modification_matrix.py::*` 与 `tests/chat/test_chat_s4_message_content_changed.py::test_chat_modify_custom_message_content_changed_event`
   覆盖文本 body/ext/同时修改、空 ID、不存在 ID、非发送者、自定义内容、CMD 不支持、语音/图片/视频 ext 与 body 不支持。自定义消息 case 额外验证接收账号的全部在线端都收到原消息及内容变更回调；修改成功结果及回调保留 operator、attributes、类型、方向、状态及送达字段。
153. `tests/chat/test_chat_crud.py::test_chat_fetch_support_languages_success`
   获取真实支持语言列表；严格校验每项恰好包含非空 `nativeName/code/name`、code 唯一，并固定校验 `zh-Hans` 与 `en` 的真实三字段内容，不再使用 `result != None` 弱断言。
154. `tests/chat/test_chat_attachment_download_and_history_boundaries.py::*` 与 `tests/chat/test_chat_s423_message_callback_and_combine.py::test_attachment_messages_send_receive_and_public_download_methods`
   覆盖图片/视频发送方与接收方附件下载、图片/视频缩略图及文本附件/缩略图异常；动态路径、secret、时间和文件大小单独处理，消息 envelope 的稳定字段全部保留。
155. `tests/chat/test_chat_history_option_filters.py::*`
   覆盖 direction=DOWN、start/end 时间范围和 msgTypes `[1]`、`[0,1]`、`[7]`、`[0,7]`。先等待目标消息进入漫游存储，再以真实 ID 验证筛选结果，避免把服务端归档延迟误判为过滤行为。
156. `tests/chat/test_chat_recall_and_message_read_ack.py::*`、`tests/chat/test_chat_ack_read_strict.py::*` 与 `tests/chat/test_chat_s3_non_message_ops.py::test_chat_ack_conversation_read_*`
   覆盖文档启用的消息/会话已读 ACK 正常和边界链路；在 `requireDeliveryAck=true` 环境中保留并按阶段断言真实 `hasDeliverAck`，不将该重要字段加入忽略集。

### 本轮严格回归口径

- 相关模块共收集 93 个 pytest node；首轮为 `83 passed, 5 skipped, 5 failed`；第二轮为 `85 passed, 5 skipped, 3 failed`。失败均由送达状态时序或服务端删除/归档一致性导致，已通过显式等待目标送达事件和清理完成窗口消除竞争，失败项逐项复跑通过。
- 最终同轮 strict 回归结果：`88 passed, 5 skipped`，耗时 `280.14s`。
- 5 个 skip 分别为 CMD 送达、3 种类型消息举报和非法 mark bridge 崩溃；原因与恢复条件见 `CASES_DEFERRED.zh.md`。
- 带 `targetLanguages` 的自动翻译已按当前开启环境的成功结果严格覆盖；显式 `translateMessage` 正常翻译仍返回空 `translations`，保留为独立待排查项。moderation 敏感词分支仍依赖 AppKey 功能开关，未把关闭态返回固化为预期。

### `requireDeliveryAck` 测试 App 配置适配（5554/5556）

- 根因：`im_flutter_test` 的 `SdkConfigLoader` 只映射了 `require_ack`，未映射 `require_delivery_ack`；`EMOptions.requireDeliveryAck` 因此使用默认值 `false`。发布 SDK、Android/iOS Wrapper 和 `onMessagesDelivered` 事件桥接本身均已具备支持。
- 适配：在共享 `sdk_options` 配置和模板中显式设置 `require_delivery_ack: true`，并映射到 `EMOptions.withAppKey(requireDeliveryAck: true)`；新增 Flutter asset 配置回归测试。
- 真实日志：重新构建安装后，两台 App 初始化日志均显示 `requireDeliveryAck: true`；发送端收到 `onMessagesDelivered`，事件消息使用真实服务端 msgId 且 `hasDeliverAck=true`，后续 `onMessagesRead` 同样保留 `hasDeliverAck=true`。
- 断言同步：本地会话、按 ID 加载及关键字检索的公共消息准备断言由旧环境的 `false` 收紧为 `true`，没有忽略该字段。`loadMessagesWithIds` 在查询前显式等待每条消息对应的送达事件，消除连续发消息时本地状态尚未刷新的竞争。
- 验证：原始 `test_chat_ack_message_read_success_with_event` 单例严格通过；最终受影响范围同 session 聚合回归 `19 passed, 0 failed, 0 skipped`。CMD 送达 case 仍维持原有 skip，恢复条件不变。

### 5.0 离线消息的多端前置

- `test_chat_offline_message_delivery.py`、`test_chat_offline_message_operations.py`、`test_chat_offline_message_extended_delivery.py`、`test_chat_offline_message_extended_operations.py` 均通过 `account_a_to_account_b` topology 取得账号全部端点，不再写死 `deviceB/deviceBSec`。
- 账号进入离线阶段时，统一调用 `logout_account_devices(topology.sender_devices/recipient_devices)`，同账号所有端点必须同时下线；否则副端仍可能先收到消息、回执或操作事件，污染“尚未重新登录”的前置条件。
- 用例业务步骤只恢复 topology 指定的动作端，用于验证“动作端重新登录后的离线事件”；`finally` 统一调用 `restore_account_devices` 恢复发送/接收账号全部端点，并清理好友与消息状态，避免影响下一个 case。
- 媒体 `status/fileStatus/thumbnailStatus` 仍按消息阶段断言：发送阶段与离线重登接收阶段不混用；仅对已确认的 5.0 时序差异做局部忽略，不能用离线断言掩盖在线行为问题。

### 指定 14 条回归修复（2026-07-15，5556/5558）

- RED 基线：`2 passed, 12 failed`。原本通过的是“向非好友发送错误事件”和“接收方置顶自定义消息后跨用户取消置顶”。
- 失败分类：7 条仍按旧环境断言送达后 `hasDeliverAck=false`；2 条假设共享服务端置顶列表只含本次消息或必然为空；2 条自己会话 mark/pin 预期与当前稳定返回不一致；1 条自动翻译仍等待旧环境 `1113` 错误。
- 断言处理：按同步发送、发送成功、接收/送达/已读/撤回/查询阶段分别冻结 `hasDeliverAck`；置顶结果只按本次真实 msgId 投影，但投影内消息 envelope 仍完整严格断言；自己会话 mark 冻结 `result=null`，pin 冻结 `303 params [to,from] must be unequal`；自动翻译严格校验发送方和接收方 `targetLanguages`、`translations`。
- 重要字段：本轮没有把 `hasDeliverAck`、参与者、会话、方向、状态、消息类型或 body 加入宽松忽略集；仅忽略真实动态的时间、序列、服务端时间、局部路径或 SDK 阶段不返回的字段。
- 开关结论：两台测试 App 初始化均为 `requireDeliveryAck=true`；自动翻译已经返回非空翻译结果；14 条中未出现 `505 Service is not enabled`，没有需要用户补开的服务开关。
- GREEN 结果：最终同一 session 严格复跑 `14 passed, 0 failed, 0 skipped`，耗时 `61.76s`，JUnit 证据为 `/tmp/requested-chat-14-verified.xml`。

### WebSocket 登录状态与类型消息发送人同步（2026-07-16）

- 根因日志：deviceA 原生登录结果为 `test0716user1`，但 generic bridge 未更新 Dart `EMClient.currentUserId`，`sendMessageWithType(custom)` 因而使用旧缓存 `from=test0715user2`，原生立即返回 `500 Message is invalid`。
- 修复边界：仅在测试 App bridge 中将 `Client.login`、`loginWithAgoraToken`、`logout` 分发到公开 Dart `EMClient` API；发布 SDK和原生 Wrapper 未改。登录后继续启动 callback，退出后同步清空 Dart 用户缓存。
- 兼容性：保持原 WebSocket envelope；`loginWithAgoraToken` 兼容既有 `agora_token` 入参，原生 `EMError` 继续映射为 `response.result={code,description}`。
- case 诊断：translation 边界消息准备按同步临时 msgId 同时等待 `onMessageSuccess/onMessageError`；错误时输出真实 code、description 和事件，不再只报空 `msg`。
- RED/GREEN：Flutter bridge 测试修复前得到 `Expected new-user, Actual old-user`；修复后登录缓存、类型消息 `from`、logout 清理和 token 错误 envelope 均通过。
- 真实验证：新 APK覆盖安装 5554/5556 后，custom 同步消息 `from=test0716user1`，收到 `onMessageSuccess`（服务端 msgId `1574540571509260289`），随后 `translateMessage` 返回 `1 General error`，目标 case 通过；同轮 translation 文件 `3 passed`。
- 环境说明：随后两次复跑消息 `from` 仍正确，但隔舱 TCP 发送连续两次等不到服务端 ACK，最终返回独立的 `300 Server is unreachable`。该环境错误不属于登录缓存修复，也未固化为翻译预期。
