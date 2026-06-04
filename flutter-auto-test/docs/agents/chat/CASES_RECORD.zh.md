# Chat 模块 Cases 总记录（按 API）

— 说明
- 本文件记录 Chat 模块已覆盖用例（按 API 组织）。
- 每条 case 以全局序号编号；统计按“当前记录条目数”计算。
- 暂缓与 skip 项统一写 `CASES_DEFERRED.zh.md`。

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
   先制造未读再读取计数并清零，验证未读数变化链路正确。
5. `tests/chat/test_chat_s1_local_conversation.py::test_chat_mark_all_as_read_idempotent`
   连续执行全部已读操作，验证重复调用幂等且不引入副作用。

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
   A 发送消息到 B，双端校验发送成功响应与接收回调字段。
14. `tests/chat/test_chat_send_with_type.py::test_send_message_with_type_text_basic`
   发送基础文本消息，验证普通文本类型发送与接收成功。
15. `tests/chat/test_chat_send_with_type.py::test_send_message_with_type_text_with_languages`
   发送多语言文本内容，验证字符集与内容回传稳定。
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
   对已撤回消息执行翻译，验证异常对象状态下接口返回语义。

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
   对有效消息回执已读，验证同步响应成功语义。
32. `tests/chat/test_chat_ack_read_strict.py::test_chat_ack_message_read_success_with_event`
   已读回执成功后补充校验接收端事件，确保回调链路完整。
33. `tests/chat/test_chat_s3_non_message_ops.py::test_chat_ack_conversation_read_success_with_event`
   会话级已读回执成功并校验事件，验证会话维度已读链路。

异常 cases
34. `tests/chat/test_chat_ack_read_strict.py::test_chat_ack_message_read_invalid_msg_id`
   对非法消息 ID 回执已读，冻结错误语义与关键字段。
35. `tests/chat/test_chat_crud.py::test_chat_ack_conversation_read_invalid_id_response`
   使用无效会话 ID 做会话已读回执，验证异常返回。
36. `tests/chat/test_chat.py::test_chat_ack_conversation_read_invalid_id_response`
   在历史兼容入口复核无效会话 ID 的错误一致性。
37. `tests/chat/test_chat_s3_non_message_ops.py::test_chat_ack_conversation_read_invalid_conv_id`
   明确非法会话 ID 参数时，校验参数错误语义。
38. `tests/chat/test_chat_s3_non_message_ops.py::test_chat_ack_conversation_read_empty_conv_id`
   传空会话 ID 回执会话已读，验证空入参异常语义。

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
56. `tests/chat/test_chat_s3_non_message_ops.py::test_chat_pin_conversation_success_toggle`
   对有效会话执行置顶与取消置顶，验证开关状态切换正确。

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
   对无效会话拉取历史消息，冻结错误语义。
64. `tests/chat/test_chat.py::test_chat_fetch_history_invalid_conversation`
   在兼容入口复核无效会话历史查询错误。
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
   使用 cursor 拉取服务端会话成功，验证游标链路正确。
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

## 统计
- 当前记录 case 条目总数：`107`
