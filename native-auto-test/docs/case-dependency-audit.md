# 全业务 case 依赖边界盘点

范围：八模块所有 test_* 函数及可解析的本地/导入 helper；参数化分支按源码分支审阅，不代表设备执行结果。依赖审计历史状态见 `.doc/specs/shared-runtime-config/tasks.md` 第 12 节；2026-09-15 删除精简状态见 `.doc/specs/release-test-automation/tasks.md` 的“用例精简”章节。

当前总计 494 个测试函数（不展开参数化组合）：chat=178, chatroom=67, client=11, contact=34, group=177, presence=10, push=6, user_info=11。已删除显式 skip/xfail 项；下方操作链为保留用例的历史静态审计，不表示运行覆盖，离线可达数量需重新审计。

本索引的操作链/边界沿用第 12 节审计；第 13 节仅迁移时间词汇和显式 module，默认预算与操作链不变。下列等待列表是语义标签（包含共享 helper），不是可直接复制的完整调用表达式；配置以 `case-timing-inventory.md` 为准。

## 判定规则

- 普通变更及回调组验证完成，到下一业务操作：step（默认 1 秒）；已有明确稳定等待保留。
- 接收方退出后、对端操作完成到接收方重登前、启动回调后：offline（默认 3 秒），公共 helper 内执行，不在调用点重复加。
- 同一操作的多条回调连续收集；负向观察窗口、deadline 内轮询、纯查询分页、纯错误断言不加通用 sleep。
- server 拉取触发本地缓存同步的场景，server→local 查询边界单独等待。批量发消息/构建合并消息的有限业务循环也保留间隔。
- 清理/finally 不机械插入节奏；测试前依赖清理结果的准备链路可在后续操作前等待。

## 登录入口结论

- Chat/Contact/Group 离线回放通过公共 offline flow；Contact 三条邀请用例经 `_prepare_offline_invitation`，Group 角色/配置/文件经 `_relogin_b`，不能只数测试函数内的直接调用。
- Client 离线同步直接登录已显式暂停；原 Contact 好友同步 xfail 用例已删除；五个 `_switch_user` 是角色/账号切换，退出到登录已有 3 秒，不能额外 drain 离线回放。
- Presence/Push/UserInfo/ChatRoom 无接收方退出重登回放链；检查普通状态传播和加入后角色管理依赖。fixture 初始登录、错误密码/token 边界及 finally 恢复不作为离线回放。

## 每例索引

以下列出调用图内的业务命令与等待键；包含被调用 helper 的备用分支和清理路径，仅用于源码定位，不表示每次运行都会执行所有项。无命令项为纯配置/模型或占位测试。

### `tests/chat/test_chat.py::test_chat_add_reaction_empty_reaction_response`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addReaction`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat.py::test_chat_send_to_self_should_not_succeed`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessage`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_ack_read_strict.py::test_chat_ack_message_read_invalid_msg_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`ackMessageRead`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_ack_read_strict.py::test_chat_ack_message_read_success_with_event`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`ackMessageRead`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_attachment_download_and_history_boundaries.py::test_chat_download_attachment_for_text_message`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`downloadAttachment`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_attachment_download_and_history_boundaries.py::test_chat_fetch_history_page_size_one_cursor`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchHistoryMessagesByOptions`, `sendMessage`。
- 等待：`'step.interval'`, `timing_seconds('settle.normal')`。

### `tests/chat/test_chat_attachment_download_and_history_boundaries.py::test_chat_sender_downloads_image_and_video_attachment`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`downloadAttachment`, `sendMessageWithType`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_conversation_cursor_pagination.py::test_chat_conversation_pinned_and_marked_cursor_pagination`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`acceptInvitation`, `addContact`, `addRemoteAndLocalConversationsMark`, `deleteRemoteAndLocalConversationsMark`, `fetchConversationsByOptions`, `getAllContactsFromServer`, `getConversationsFromServer`, `login`, `logout`, `pinConversation`, `sendMessage`, `startCallback`。
- 等待：`'settle.offline'`, `'step.interval'`, `timing_seconds('poll.interval')`, `timing_seconds('poll.server_state')`, `timing_seconds('settle.cursor_order')`。

### `tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_add_conversation_mark_boundaries`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addRemoteAndLocalConversationsMark`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_conversation_mark_idempotent_and_remove_unmarked`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addRemoteAndLocalConversationsMark`, `deleteRemoteAndLocalConversationsMark`, `fetchConversationsByOptions`, `getConversationsFromServer`, `sendMessage`。
- 等待：`'step.interval'`, `timing_seconds('poll.interval')`, `timing_seconds('poll.server_state')`。

### `tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_delete_conversation_mark_boundaries`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`deleteRemoteAndLocalConversationsMark`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_fetch_conversation_marks_boundaries`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchConversationsByOptions`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_conversation_pin_additional.py::test_chat_conversation_pin_and_unpin_are_idempotent`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchConversationsByOptions`, `getConversationsFromServer`, `pinConversation`, `sendMessage`。
- 等待：`'step.interval'`, `timing_seconds('poll.server_state')`。

### `tests/chat/test_chat_conversation_pin_additional.py::test_chat_fetch_pinned_conversations_page_size_boundaries`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchConversationsByOptions`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_conversation_pin_additional.py::test_chat_pin_conversation_non_boolean_coerces_to_unpin`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getConversation`, `getConversationsFromServer`, `pinConversation`, `sendMessage`。
- 等待：`'step.interval'`, `timing_seconds('poll.server_state')`。

### `tests/chat/test_chat_crud.py::test_chat_ack_conversation_read_invalid_id_response`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`ackConversationRead`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_crud.py::test_chat_ack_message_read_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`ackMessageRead`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_crud.py::test_chat_add_reaction_empty_reaction_response`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addReaction`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_crud.py::test_chat_add_reaction_invalid_id_response`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addReaction`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_crud.py::test_chat_fetch_history_by_options_invalid_conversation`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchHistoryMessagesByOptions`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_crud.py::test_chat_fetch_history_invalid_conversation`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchHistoryMessages`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_crud.py::test_chat_fetch_support_languages_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchSupportLanguages`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_crud.py::test_chat_get_message_invalid_id_returns_none`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getMessage`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_crud.py::test_chat_modify_message_invalid_id_response`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`modifyMessage`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_crud.py::test_chat_pin_conversation_nonexistent_conversation`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`pinConversation`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_crud.py::test_chat_recall_message_invalid_id_response`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`recallMessage`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_crud.py::test_chat_send_and_received`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessage`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_crud.py::test_chat_send_to_self_event`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessage`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_crud.py::test_chat_translate_message_basic`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getMessage`, `sendMessage`, `translateMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_crud.py::test_chat_translate_message_recalled_message`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`recallMessage`, `sendMessage`。
- 等待：`timing_seconds('settle.local_projection')`。

### `tests/chat/test_chat_history_option_filters.py::test_chat_history_filters_direction_time_and_message_types`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`deleteRemoteConversation`, `fetchHistoryMessagesByOptions`, `sendMessage`, `sendMessageWithType`。
- 等待：`'step.interval'`, `timing_seconds('poll.server_state')`, `timing_seconds('settle.normal')`, `timing_seconds('step.interval')`。

### `tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_conversation_marks_and_fetch_options`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addRemoteAndLocalConversationsMark`, `deleteRemoteAndLocalConversationsMark`, `fetchConversationsByOptions`, `getConversationsFromServer`, `sendMessage`。
- 等待：`'step.interval'`, `timing_seconds('poll.server_state')`。

### `tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_delete_all_message_and_conversation_local`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`deleteAllMessageAndConversation`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_message_count_and_search_options_boundaries`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getMessageCount`, `searchMsgsByOptions`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_message_object_boundary_methods`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`importMessages`, `resendMessage`, `updateChatMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_pin_unpin_and_fetch_pinned_messages`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchPinnedMessages`, `pinMessage`, `sendMessage`, `unpinMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_recall_message_receiver_recalled_info_event`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`recallMessage`, `sendMessage`。
- 等待：`timing_seconds('settle.normal')`。

### `tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_send_to_non_friend_current_success_event`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessage`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_cmd_message_is_rejected`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`modifyMessage`, `sendMessageWithType`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_media_attributes`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`modifyMessage`, `sendMessageWithType`, `updateDeliveryAckSetting`。
- 等待：`'step.interval'`, `timing_seconds('settle.normal')`。

### `tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_media_body_is_rejected`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`modifyMessage`, `sendMessageWithType`, `updateDeliveryAckSetting`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_message_empty_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`modifyMessage`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_text_body_and_attributes`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`modifyMessage`, `sendMessage`。
- 等待：`'step.interval'`, `timing_seconds('settle.normal')`。

### `tests/chat/test_chat_message_modification_matrix.py::test_chat_non_sender_cannot_modify_message`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`modifyMessage`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_message_pin_boundaries.py::test_chat_fetch_pinned_messages_invalid_conversation`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchPinnedMessages`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_message_pin_boundaries.py::test_chat_pin_message_empty_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`pinMessage`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_message_pin_boundaries.py::test_chat_pin_message_invalid_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`pinMessage`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_message_pin_boundaries.py::test_chat_pin_recalled_message`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`pinMessage`, `recallMessage`, `sendMessage`。
- 等待：`'step.interval'`, `timing_seconds('settle.normal')`。

### `tests/chat/test_chat_message_pin_boundaries.py::test_chat_pin_recalled_typed_message`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`pinMessage`, `recallMessage`, `sendMessageWithType`。
- 等待：`timing_seconds('step.interval')`, `timing_seconds('settle.normal')`。

### `tests/chat/test_chat_message_pin_boundaries.py::test_chat_unpin_message_empty_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`unpinMessage`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_message_pin_boundaries.py::test_chat_unpin_message_invalid_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`unpinMessage`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_message_send_boundaries.py::test_chat_combine_message_rejects_empty_source_ids`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessageWithType`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_message_send_boundaries.py::test_chat_media_message_rejects_nonexistent_device_path`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessageWithType`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_message_send_boundaries.py::test_chat_message_send_target_boundaries`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessageWithType`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_message_send_boundaries.py::test_chat_message_type_rejects_missing_required_payload`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessageWithType`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_message_translation_boundaries.py::test_chat_translate_custom_message`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessageWithType`, `translateMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_message_translation_boundaries.py::test_chat_translate_message_empty_languages`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessage`, `translateMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_message_translation_boundaries.py::test_chat_translate_message_unsupported_language`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessage`, `translateMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_custom_message_send_receive`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessageWithType`, `updateDeliveryAckSetting`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_location_message_send_receive`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessageWithType`, `updateDeliveryAckSetting`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_message_delivery_ack`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessageWithType`, `updateDeliveryAckSetting`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_voice_message_send_receive`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessageWithType`, `updateDeliveryAckSetting`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_cmd_message_received_after_login`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `clearAllMessages`, `deleteContact`, `getCurrentUser`, `login`, `logout`, `markAllMessagesAsRead`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_combine_message_received_after_login`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `deleteContact`, `getCurrentUser`, `login`, `logout`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_custom_message_received_after_login`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `clearAllMessages`, `deleteContact`, `getCurrentUser`, `login`, `logout`, `markAllMessagesAsRead`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_deliver_online_only_not_received_after_login`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `clearAllMessages`, `deleteContact`, `getCurrentUser`, `getMessage`, `login`, `logout`, `markAllMessagesAsRead`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_delivery_ack_after_recipient_login`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `clearAllMessages`, `deleteContact`, `getCurrentUser`, `login`, `logout`, `markAllMessagesAsRead`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_location_message_received_after_login`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `clearAllMessages`, `deleteContact`, `getCurrentUser`, `login`, `logout`, `markAllMessagesAsRead`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_media_message_received_after_login`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `clearAllMessages`, `deleteContact`, `getCurrentUser`, `login`, `logout`, `markAllMessagesAsRead`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_multiple_text_messages_and_unread_count`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `clearAllMessages`, `deleteContact`, `getCurrentUser`, `getLatestMessage`, `getUnreadMsgCount`, `login`, `logout`, `markAllMessagesAsRead`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_text_message_received_after_login`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `clearAllMessages`, `deleteContact`, `getCurrentUser`, `login`, `logout`, `markAllMessagesAsRead`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_combine_delivery_ack_after_recipient_login`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `deleteContact`, `getCurrentUser`, `login`, `logout`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_mixed_backlog_local_state_after_recipient_login`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `clearAllMessages`, `deleteContact`, `fetchHistoryMessages`, `getCurrentUser`, `getLatestMessage`, `getMessage`, `getUnreadMsgCount`, `login`, `logout`, `markAllMessagesAsRead`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`, `timing_seconds('settle.local_projection')`。

### `tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_received_media_downloads_after_recipient_login`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `clearAllMessages`, `cmd`, `deleteContact`, `getCurrentUser`, `login`, `logout`, `markAllMessagesAsRead`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。


### `tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_typed_delivery_ack_after_recipient_login`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `clearAllMessages`, `deleteContact`, `getCurrentUser`, `login`, `logout`, `markAllMessagesAsRead`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_combine_message_read_after_sender_relogin`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `ackMessageRead`, `addContact`, `deleteContact`, `getCurrentUser`, `login`, `logout`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_combine_message_recall_after_recipient_relogin`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `deleteContact`, `getCurrentUser`, `getMessage`, `login`, `logout`, `recallMessage`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_custom_body_modified_after_recipient_relogin`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `deleteContact`, `getCurrentUser`, `getMessage`, `login`, `logout`, `modifyMessage`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`, `timing_seconds('settle.normal')`。

### `tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_media_attributes_modified_after_recipient_relogin`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `deleteContact`, `getCurrentUser`, `getMessage`, `login`, `logout`, `modifyMessage`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`, `timing_seconds('settle.normal')`。

### `tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_text_modified_before_first_recipient_login`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `clearAllMessages`, `deleteContact`, `getCurrentUser`, `getMessage`, `login`, `logout`, `markAllMessagesAsRead`, `modifyMessage`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_text_recalled_before_first_recipient_login`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `clearAllMessages`, `deleteContact`, `getCurrentUser`, `getMessage`, `login`, `logout`, `markAllMessagesAsRead`, `recallMessage`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_read_after_sender_relogin`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `ackMessageRead`, `addContact`, `deleteContact`, `getCurrentUser`, `login`, `logout`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_recall_after_recipient_relogin`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `deleteContact`, `getCurrentUser`, `getMessage`, `login`, `logout`, `recallMessage`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/chat/test_chat_offline_message_operations.py::test_chat_offline_recipient_receives_content_change_after_relogin`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `deleteContact`, `getCurrentUser`, `getMessage`, `login`, `logout`, `modifyMessage`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/chat/test_chat_offline_message_operations.py::test_chat_offline_recipient_receives_recall_after_relogin`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `deleteContact`, `getCurrentUser`, `getMessage`, `login`, `logout`, `recallMessage`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/chat/test_chat_offline_message_operations.py::test_chat_offline_sender_receives_conversation_read_after_relogin`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `ackConversationRead`, `addContact`, `deleteContact`, `getCurrentUser`, `login`, `logout`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/chat/test_chat_offline_message_operations.py::test_chat_offline_sender_receives_message_read_after_relogin`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `ackMessageRead`, `addContact`, `deleteContact`, `getCurrentUser`, `login`, `logout`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/chat/test_chat_offline_message_operations.py::test_chat_offline_sender_receives_reaction_add_after_relogin`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `addReaction`, `deleteContact`, `fetchReactionList`, `getCurrentUser`, `login`, `logout`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/chat/test_chat_offline_message_operations.py::test_chat_offline_sender_receives_reaction_remove_after_relogin`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `addReaction`, `deleteContact`, `fetchReactionList`, `getCurrentUser`, `login`, `logout`, `removeReaction`, `removeUserFromBlockList`, `sendMessageWithType`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/chat/test_chat_reaction_fetch.py::test_chat_add_reaction_duplicate_reaction`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addReaction`, `sendMessage`。
- 等待：`'step.interval'`, `timing_seconds('settle.normal')`。

### `tests/chat/test_chat_reaction_fetch.py::test_chat_add_reaction_special_char_reaction`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addReaction`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_detail_empty_reaction`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchReactionDetail`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_detail_invalid`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchReactionDetail`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_detail_invalid_page_size`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchReactionDetail`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_detail_oversize_page_size`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchReactionDetail`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_list_empty_msg_ids`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchReactionList`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_list_invalid_chat_type`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchReactionList`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_list_invalid_msg_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchReactionList`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_reaction_fetch.py::test_chat_reaction_change_event_received_by_sender`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addReaction`, `sendMessage`。
- 等待：`timing_seconds('settle.slow')`。

### `tests/chat/test_chat_reaction_fetch.py::test_chat_remove_reaction_invalid_msg_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`removeReaction`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_reaction_fetch.py::test_chat_remove_reaction_not_exists_reaction`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`removeReaction`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_recall_and_message_read_ack.py::test_chat_missing_ack_message_read_boundaries`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`ackMessageRead`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_recall_and_message_read_ack.py::test_chat_missing_recall_empty_message_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`recallMessage`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。


### `tests/chat/test_chat_report_message_boundaries.py::test_chat_report_message_empty_message_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`reportMessage`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_report_message_boundaries.py::test_chat_report_message_empty_reason`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`reportMessage`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_report_message_boundaries.py::test_chat_report_message_empty_tag`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`reportMessage`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_report_message_boundaries.py::test_chat_report_recalled_message`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`recallMessage`, `reportMessage`, `sendMessage`。
- 等待：`timing_seconds('step.interval')`, `timing_seconds('settle.normal')`。

### `tests/chat/test_chat_report_message_boundaries.py::test_chat_report_text_message_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`reportMessage`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_s1_conversations_sort.py::test_chat_get_all_conversations_by_sort_orders_latest_first`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`deleteConversation`, `loadAllConversations`, `sendMessage`。
- 等待：`'step.interval'`, `timing_seconds('settle.sort_spacing')`, `timing_seconds('settle.sort_projection')`。

### `tests/chat/test_chat_s1_local_conversation.py::test_chat_delete_conversation_existing_then_not_found`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`deleteConversation`, `getConversation`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_s1_local_conversation.py::test_chat_delete_conversation_nonexistent_returns_bool`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`deleteConversation`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_s1_local_conversation.py::test_chat_delete_messages_before_timestamp_future_removes_msg`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`deleteMessagesBeforeTimestamp`, `getMessage`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_s1_local_conversation.py::test_chat_delete_messages_before_timestamp_zero_keeps_recent_msg`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`deleteMessagesBeforeTimestamp`, `getMessage`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_s1_local_conversation.py::test_chat_get_conversation_empty_conv_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getConversation`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_s1_local_conversation.py::test_chat_get_conversation_not_exist_without_create`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getConversation`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_s1_local_conversation.py::test_chat_get_conversation_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getConversation`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_s1_local_conversation.py::test_chat_get_unread_count_positive_then_zero`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getUnreadMessageCount`, `markAllChatMsgAsRead`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_s1_local_conversation.py::test_chat_load_all_conversations_contains_then_not_contains`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`deleteConversation`, `loadAllConversations`, `sendMessage`。
- 等待：`'step.interval'`, `timing_seconds('settle.local_projection')`。

### `tests/chat/test_chat_s1_local_conversation.py::test_chat_mark_all_as_read_idempotent`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getUnreadMessageCount`, `markAllChatMsgAsRead`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_s2_server_ops.py::test_chat_delete_remote_conversation_empty_conv_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`deleteRemoteConversation`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_s2_server_ops.py::test_chat_delete_remote_conversation_invalid_type`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`deleteRemoteConversation`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_s2_server_ops.py::test_chat_delete_remote_conversation_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`deleteRemoteConversation`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_s2_server_ops.py::test_chat_fetch_conversations_from_server_with_page_invalid_page_num_zero`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`cmd`, `sendMessage`。
- 等待：`timing_seconds('poll.server_state')`。

### `tests/chat/test_chat_s2_server_ops.py::test_chat_fetch_conversations_from_server_with_page_invalid_page_size_zero`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`cmd`, `sendMessage`。
- 等待：`timing_seconds('poll.server_state')`。

### `tests/chat/test_chat_s2_server_ops.py::test_chat_fetch_conversations_from_server_with_page_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`cmd`, `sendMessage`。
- 等待：`timing_seconds('poll.server_state')`。

### `tests/chat/test_chat_s2_server_ops.py::test_chat_get_conversations_from_server_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`cmd`, `sendMessage`。
- 等待：`timing_seconds('poll.server_state')`。

### `tests/chat/test_chat_s2_server_ops.py::test_chat_get_conversations_from_server_with_cursor_invalid_page_size_negative`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getConversationsFromServerWithCursor`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_s2_server_ops.py::test_chat_get_conversations_from_server_with_cursor_invalid_page_size_zero`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getConversationsFromServerWithCursor`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_s2_server_ops.py::test_chat_get_conversations_from_server_with_cursor_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`cmd`, `sendMessage`。
- 等待：`timing_seconds('poll.server_state')`。

### `tests/chat/test_chat_s2_server_ops.py::test_chat_get_pinned_conversations_from_server_with_cursor_invalid_page_size_negative`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getPinnedConversationsFromServerWithCursor`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_s2_server_ops.py::test_chat_get_pinned_conversations_from_server_with_cursor_invalid_page_size_zero`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getPinnedConversationsFromServerWithCursor`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_s2_server_ops.py::test_chat_get_pinned_conversations_from_server_with_cursor_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getPinnedConversationsFromServerWithCursor`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_msg_ids_empty_msg_ids`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`removeMessagesFromServerWithMsgIds`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_msg_ids_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`removeMessagesFromServerWithMsgIds`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_ts_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`removeMessagesFromServerWithTs`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_ts_timestamp_zero`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`removeMessagesFromServerWithTs`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_s2_server_ops.py::test_chat_report_message_invalid_msg_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`reportMessage`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_s2_server_ops.py::test_chat_report_message_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`reportMessage`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_s3_non_message_ops.py::test_chat_ack_conversation_read_empty_conv_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`ackConversationRead`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_s3_non_message_ops.py::test_chat_ack_conversation_read_invalid_conv_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`ackConversationRead`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_s3_non_message_ops.py::test_chat_ack_conversation_read_success_with_event`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`ackConversationRead`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_by_options_empty_conv_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchHistoryMessagesByOptions`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_by_options_invalid_conv_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchHistoryMessagesByOptions`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_by_options_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchHistoryMessagesByOptions`, `sendMessage`。
- 等待：`timing_seconds('settle.history_projection')`。

### `tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_empty_conv_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchHistoryMessages`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_invalid_conv_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchHistoryMessages`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchHistoryMessages`, `sendMessage`。
- 等待：`timing_seconds('settle.history_projection')`。

### `tests/chat/test_chat_s3_non_message_ops.py::test_chat_pin_conversation_empty_conv_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`pinConversation`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_s3_non_message_ops.py::test_chat_pin_conversation_invalid_conv_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`pinConversation`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_s3_non_message_ops.py::test_chat_pin_conversation_success_toggle`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getConversation`, `pinConversation`。
- 等待：`'step.interval'`, `timing_seconds('poll.interval')`。

### `tests/chat/test_chat_s423_message_callback_and_combine.py::test_attachment_messages_send_receive_and_public_download_methods`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`cmd`, `sendMessageWithType`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_s423_message_callback_and_combine.py::test_combine_forward_media_inner_attachment_download`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`cmd`, `downloadAndParseCombineMessage`, `sendMessageWithType`。
- 等待：`'step.interval'`, `timing_seconds('settle.thumbnail_completion')`。

### `tests/chat/test_chat_s423_message_callback_and_combine.py::test_combine_forward_send_receive_and_inner_attachment_download`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`cmd`, `downloadAndParseCombineMessage`, `sendMessageWithType`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_s423_message_callback_and_combine.py::test_send_text_message_with_webhook_env`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessage`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_s4_load_messages_by_ids.py::test_chat_load_messages_with_ids_empty_ids`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`loadMessagesWithIds`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_s4_load_messages_by_ids.py::test_chat_load_messages_with_ids_single_and_multi_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`loadMessagesWithIds`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_chat_s4_local_keyword_search.py::test_chat_load_conversation_messages_with_keyword_no_hit`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`loadConversationMessagesWithKeyword`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_s4_local_keyword_search.py::test_chat_load_conversation_messages_with_keyword_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`loadConversationMessagesWithKeyword`, `sendMessage`。
- 等待：`timing_seconds('poll.interval')`。

### `tests/chat/test_chat_s4_message_content_changed.py::test_chat_modify_custom_message_content_changed_event`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`modifyMessage`, `sendMessageWithType`。
- 等待：`timing_seconds('settle.normal')`。

### `tests/chat/test_chat_send_with_type.py::test_send_message_with_type_cmd_received_by_cmd_callback`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessageWithType`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_send_with_type.py::test_send_message_with_type_file`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessageWithType`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_send_with_type.py::test_send_message_with_type_image`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessageWithType`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_send_with_type.py::test_send_message_with_type_image_heic`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessageWithType`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_send_with_type.py::test_send_message_with_type_text_basic`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessageWithType`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_send_with_type.py::test_send_message_with_type_text_with_languages`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessageWithType`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_send_with_type.py::test_send_message_with_type_video`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessageWithType`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_text_boundaries_and_location_delivery.py::test_chat_location_message_delivery_ack`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessageWithType`, `updateDeliveryAckSetting`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_text_boundaries_and_location_delivery.py::test_chat_send_rejects_mismatched_from`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessage`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_chat_text_boundaries_and_location_delivery.py::test_chat_text_content_boundaries`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessage`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_delete_local_and_server_messages_by_time`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`conversationDeleteServerMessageWithTime`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_delete_local_and_server_messages_current_behavior`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`conversationDeleteServerMessageWithIds`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_ext_and_count_queries`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`conversationGetLocalMessageCount`, `conversationRemindType`, `messageCount`, `pinMessage`, `pinnedMessages`, `sendMessage`, `syncConversationExt`, `unpinMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_invalid_message_id_boundaries`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`deleteMessageByIds`, `loadMsgWithId`, `markMessageAsRead`。
- 等待：`'step.interval'`。

### `tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_latest_and_last_received_messages`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`clearAllMessages`, `getLatestMessage`, `getLatestMessageFromOthers`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_load_message_and_message_lists`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`cmd`, `loadMsgWithId`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_local_insert_append_update_and_delete`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`clearAllMessages`, `cmd`, `deleteMessagesWithTs`, `loadMsgWithId`, `removeMessage`, `updateConversationMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_read_count_and_mark_read`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getUnreadMsgCount`, `markAllMessagesAsRead`, `markMessageAsRead`, `sendMessage`。
- 等待：`'step.interval'`。

### `tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_type_keyword_and_options_search_current_behavior`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`conversationSearchMsgsByOptions`, `loadMsgWithKeywords`, `loadMsgWithMsgType`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_admin_added_and_removed_callbacks`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addChatRoomAdmin`, `joinChatRoom`, `removeChatRoomAdmin`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_all_member_mute_state_callbacks`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`joinChatRoom`, `muteAllChatRoomMembers`, `unMuteAllChatRoomMembers`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_allow_list_added_and_removed_callbacks`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addMembersToChatRoomWhiteList`, `joinChatRoom`, `removeMembersFromChatRoomWhiteList`。
- 等待：`'step.interval'`。


### `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_attributes_updated_and_removed_callbacks`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`joinChatRoom`, `removeChatRoomAttributes`, `setChatRoomAttributes`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_member_exited_callback`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`joinChatRoom`, `leaveChatRoom`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_mute_list_added_and_removed_callbacks`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`joinChatRoom`, `muteChatRoomMembers`, `unMuteChatRoomMembers`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_owner_changed_callback`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`changeChatRoomOwner`, `joinChatRoom`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_removed_and_destroyed_callbacks`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`destroyChatRoom`, `joinChatRoom`, `removeChatRoomMembers`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_specification_changed_callback`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`changeChatRoomSubject`, `joinChatRoom`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_destroy_room_empty_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`destroyChatRoom`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_destroy_room_nonexistent`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`destroyChatRoom`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_members_empty_room_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchChatRoomMembers`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_members_nonexistent_room`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchChatRoomMembers`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_public_chat_rooms_invalid_paging`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchPublicChatRoomsFromServer`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_room_info_empty_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchChatRoomInfoFromServer`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_room_info_nonexistent`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchChatRoomInfoFromServer`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_join_room_empty_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`joinChatRoom`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_leave_room_empty_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`leaveChatRoom`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_leave_room_nonexistent`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`leaveChatRoom`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_create_and_fetch_from_server`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchChatRoomInfoFromServer`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_create_room_via_sdk_without_permission`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createChatRoom`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_fetch_room_info_from_server_after_destroy`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`destroyChatRoom`, `fetchChatRoomInfoFromServer`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_fetch_room_info_with_members_from_server`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchChatRoomInfoFromServer`, `joinChatRoom`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_add_and_remove_admin_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addChatRoomAdmin`, `fetchChatRoomInfoFromServer`, `joinChatRoom`, `removeChatRoomAdmin`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_add_fetch_remove_white_list_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addMembersToChatRoomWhiteList`, `fetchChatRoomWhiteListFromServer`, `joinChatRoom`, `removeMembersFromChatRoomWhiteList`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_block_fetch_unblock_member_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`blockChatRoomMembers`, `fetchChatRoomBlockList`, `joinChatRoom`, `unBlockChatRoomMembers`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_change_owner_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`changeChatRoomOwner`, `joinChatRoom`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_change_subject_and_description_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`changeChatRoomDescription`, `changeChatRoomSubject`, `fetchChatRoomInfoFromServer`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_fetch_all_attributes_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchChatRoomAttributes`, `setChatRoomAttributes`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_fetch_attributes_by_partial_keys_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchChatRoomAttributes`, `setChatRoomAttributes`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_mute_and_unmute_all_members_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchChatRoomInfoFromServer`, `muteAllChatRoomMembers`, `unMuteAllChatRoomMembers`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_mute_fetch_unmute_member_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchChatRoomMuteList`, `joinChatRoom`, `muteChatRoomMembers`, `unMuteChatRoomMembers`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_remove_attributes_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchChatRoomAttributes`, `removeChatRoomAttributes`, `setChatRoomAttributes`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_remove_member_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchChatRoomMembers`, `joinChatRoom`, `removeChatRoomMembers`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_set_and_fetch_attributes_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchChatRoomAttributes`, `setChatRoomAttributes`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_update_and_fetch_announcement_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchChatRoomAnnouncement`, `updateChatRoomAnnouncement`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_basics.py::test_chatroom_update_attribute_overwrites_previous_value`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchChatRoomAttributes`, `setChatRoomAttributes`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_add_attributes_empty_map`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`setChatRoomAttributes`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_change_description_empty_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`changeChatRoomDescription`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_change_description_too_long`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`changeChatRoomDescription`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_change_subject_empty_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`changeChatRoomSubject`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_change_subject_too_long`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`changeChatRoomSubject`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_fetch_members_invalid_paging`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchChatRoomMembers`, `joinChatRoom`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`cmd`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_non_member`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`cmd`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`cmd`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_self_checks_empty_room_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`cmd`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_remove_attributes_empty_keys`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`removeChatRoomAttributes`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`cmd`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_update_announcement_empty`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`updateChatRoomAnnouncement`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`cmd`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`cmd`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chatroom/test_chatroom_member_basics.py::test_chatroom_fetch_members_after_join_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchChatRoomMembers`, `joinChatRoom`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_member_basics.py::test_chatroom_fetch_members_with_cursor_pagination`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchChatRoomMembers`, `joinChatRoom`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_member_basics.py::test_chatroom_get_all_local_rooms_returns_list`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getAllChatRooms`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chatroom/test_chatroom_member_basics.py::test_chatroom_get_local_room_empty_id_returns_none`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getChatRoom`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chatroom/test_chatroom_member_basics.py::test_chatroom_get_local_room_nonexistent_returns_placeholder`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getChatRoom`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chatroom/test_chatroom_member_basics.py::test_chatroom_join_leave_other_rooms_option_controls_existing_rooms`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchChatRoomMembers`, `getAllChatRooms`, `joinChatRoom`。
- 等待：`'step.interval'`, `timing_seconds('poll.member_state')`。

### `tests/chatroom/test_chatroom_member_basics.py::test_chatroom_join_then_get_local_room_and_all_rooms`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getAllChatRooms`, `getChatRoom`, `joinChatRoom`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_member_basics.py::test_chatroom_leave_room_updates_local_cache`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchChatRoomMembers`, `joinChatRoom`, `leaveChatRoom`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_members.py::test_chatroom_join_public_chatroom_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchChatRoomMembers`, `joinChatRoom`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_members.py::test_chatroom_join_with_ext_member_joined_callback`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`joinChatRoom`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_is_member_in_white_list_and_mute_list_nonexistent_room`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`cmd`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_is_member_in_white_list_and_mute_list_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`isMemberInChatRoomMuteList`, `isMemberInChatRoomWhiteListFromServer`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_member_mute_list_check_reflects_server_state`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`isMemberInChatRoomMuteList`, `joinChatRoom`, `muteChatRoomMembers`, `unMuteChatRoomMembers`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_member_white_list_check_reflects_server_state`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addMembersToChatRoomWhiteList`, `isMemberInChatRoomWhiteListFromServer`, `joinChatRoom`, `removeMembersFromChatRoomWhiteList`。
- 等待：`'step.interval'`。

### `tests/chatroom/test_chatroom_server_state.py::test_chatroom_fetch_public_chat_rooms_from_server_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchPublicChatRoomsFromServer`。
- 等待：`'step.interval'`。

### `tests/client/test_client.py::test_client_change_app_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`changeAppId`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/client/test_client.py::test_client_get_current_user`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getCurrentUser`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/client/test_client.py::test_client_login_invalid_password`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`login`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/client/test_client.py::test_login_then_receive_offline_sync_event`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`login`, `logout`, `startCallback`。
- 等待：`'settle.offline'`, `timing_seconds('step.interval')`。

### `tests/client/test_client_remaining_api_coverage.py::test_client_compress_logs_returns_path`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`compressLogs`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/client/test_client_remaining_api_coverage.py::test_client_connection_state_queries`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`isConnected`, `isLoggedInBefore`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/client/test_client_remaining_api_coverage.py::test_client_create_account_empty_user_boundary`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createAccount`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/client/test_client_remaining_api_coverage.py::test_client_current_token_and_device_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getCurrentDeviceId`, `getToken`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/client/test_client_remaining_api_coverage.py::test_client_init_repeated_call_idempotent`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getCurrentUser`, `init`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`cmd`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`cmd`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/contact/test_contact.py::test_contact_accept_invitation_without_pending`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`acceptInvitation`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/contact/test_contact.py::test_contact_add_empty_user_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addContact`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/contact/test_contact.py::test_contact_add_nonexistent_user`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addContact`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/contact/test_contact.py::test_contact_add_self`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addContact`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/contact/test_contact.py::test_contact_add_user_to_block_list_nonexistent`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addUserToBlockList`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/contact/test_contact.py::test_contact_block_list_flow_then_unblock_restores_friend`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`acceptInvitation`, `addContact`, `addUserToBlockList`, `deleteContact`, `getAllContactsFromServer`, `getBlockListFromServer`, `removeUserFromBlockList`。
- 等待：`'step.interval'`。

### `tests/contact/test_contact.py::test_contact_decline_invitation_without_pending`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`declineInvitation`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/contact/test_contact.py::test_contact_delete_contact_nonexistent_user`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`deleteContact`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/contact/test_contact.py::test_contact_delete_contact_not_friend`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`deleteContact`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/contact/test_contact.py::test_contact_fetch_all_contact_ids`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchAllContactIds`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。


### `tests/contact/test_contact.py::test_contact_fetch_contacts_page_size_exceeds_50`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchContacts`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/contact/test_contact.py::test_contact_fetch_contacts_page_size_negative`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchContacts`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。


### `tests/contact/test_contact.py::test_contact_get_all_contact_ids`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getAllContactIds`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/contact/test_contact.py::test_contact_get_block_list_from_server_returns_list`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getBlockListFromServer`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/contact/test_contact.py::test_contact_remark_empty_string`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`acceptInvitation`, `addContact`, `deleteContact`, `getContact`, `setContactRemark`。
- 等待：`'step.interval'`。

### `tests/contact/test_contact.py::test_contact_remark_not_preserved_after_delete_and_readd`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`acceptInvitation`, `addContact`, `deleteContact`, `getContact`, `setContactRemark`。
- 等待：`'step.interval'`。

### `tests/contact/test_contact.py::test_contact_remark_set_then_list_includes_remark`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`acceptInvitation`, `addContact`, `deleteContact`, `getContact`, `setContactRemark`。
- 等待：`'step.interval'`。

### `tests/contact/test_contact.py::test_contact_remark_special_chars_length_101`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`acceptInvitation`, `addContact`, `deleteContact`, `setContactRemark`。
- 等待：`'step.interval'`。

### `tests/contact/test_contact.py::test_contact_remove_from_block_list_nonexistent_user`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`removeUserFromBlockList`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/contact/test_contact.py::test_contact_remove_from_block_list_when_not_blocked`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`acceptInvitation`, `addContact`, `deleteContact`, `getBlockListFromServer`, `removeUserFromBlockList`。
- 等待：`'step.interval'`。

### `tests/contact/test_contact.py::test_contact_set_contact_remark_non_friend`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`setContactRemark`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/contact/test_contact.py::test_friend_add_accept_and_list`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`acceptInvitation`, `addContact`, `deleteContact`, `getAllContactsFromServer`, `removeUserFromBlockList`。
- 等待：`'step.interval'`。

### `tests/contact/test_contact.py::test_friend_add_decline_and_verify_not_friends`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addContact`, `declineInvitation`, `deleteContact`, `getAllContactsFromServer`, `removeUserFromBlockList`。
- 等待：`'step.interval'`。

### `tests/contact/test_contact_offline_friendship.py::test_contact_offline_invitation_accept_after_login`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `deleteContact`, `getAllContactsFromServer`, `getCurrentUser`, `login`, `logout`, `removeUserFromBlockList`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/contact/test_contact_offline_friendship.py::test_contact_offline_invitation_decline_after_login`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`addContact`, `declineInvitation`, `deleteContact`, `getAllContactsFromServer`, `getCurrentUser`, `login`, `logout`, `removeUserFromBlockList`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/contact/test_contact_offline_friendship.py::test_contact_offline_invitation_received_after_login`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`addContact`, `deleteContact`, `getAllContactsFromServer`, `getCurrentUser`, `login`, `logout`, `removeUserFromBlockList`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/contact/test_contact_offline_friendship.py::test_contact_offline_recipient_receives_delete_after_relogin`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `deleteContact`, `getAllContactsFromServer`, `getCurrentUser`, `login`, `logout`, `removeUserFromBlockList`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/contact/test_contact_offline_friendship.py::test_contact_offline_requester_receives_accept_after_relogin`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `deleteContact`, `getAllContactsFromServer`, `getCurrentUser`, `login`, `logout`, `removeUserFromBlockList`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/contact/test_contact_offline_friendship.py::test_contact_offline_requester_receives_decline_after_relogin`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`addContact`, `declineInvitation`, `deleteContact`, `getAllContactsFromServer`, `getCurrentUser`, `login`, `logout`, `removeUserFromBlockList`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/contact/test_contact_offline_friendship.py::test_contact_offline_requester_receives_peer_delete_after_relogin`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitation`, `addContact`, `deleteContact`, `getAllContactsFromServer`, `getCurrentUser`, `login`, `logout`, `removeUserFromBlockList`, `startCallback`, `updateAcceptInvitationAlways`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/contact/test_contact_remaining_api_coverage.py::test_contact_get_all_contacts_from_db_after_server_sync`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`acceptInvitation`, `addContact`, `deleteContact`, `getAllContactsFromDB`, `getAllContactsFromServer`。
- 等待：`'step.interval'`。

### `tests/contact/test_contact_remaining_api_coverage.py::test_contact_get_block_list_from_db_after_server_sync`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`acceptInvitation`, `addContact`, `addUserToBlockList`, `deleteContact`, `getBlockListFromDB`, `getBlockListFromServer`, `removeUserFromBlockList`。
- 等待：`'step.interval'`。

### `tests/contact/test_contact_remaining_api_coverage.py::test_contact_get_self_ids_on_other_platform_returns_list`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getSelfIdsOnOtherPlatform`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/contact/test_friend_info_sync.py::test_friend_info_sync_on_peer_metadata_change`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`acceptInvitation`, `addContact`, `deleteContact`, `getContact`。
- 等待：`'step.interval'`。

### `tests/group/test_group.py::test_group_member_count_local_then_server_sync`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addMembers`, `createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `getGroupWithId`。
- 等待：`'step.interval'`。

### `tests/group/test_group_announcement.py::test_group_admin_update_announcement_notifies_owner`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addAdmin`, `createGroup`, `destroyGroup`, `getGroupAnnouncementFromServer`, `updateGroupAnnouncement`。
- 等待：`'step.interval'`。

### `tests/group/test_group_announcement.py::test_group_owner_update_announcement_notifies_member`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupAnnouncementFromServer`, `updateGroupAnnouncement`。
- 等待：`'step.interval'`。

### `tests/group/test_group_blocking.py::test_group_block_then_unblock_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`blockGroup`, `createGroup`, `destroyGroup`, `getGroupWithId`, `unblockGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_chat_thread_remaining_api_coverage.py::test_chat_thread_destroy_event_received_by_group_member`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createChatThread`, `createGroup`, `destroyChatThread`, `destroyGroup`, `joinChatThread`, `sendMessage`。
- 等待：`'settle.parent_message'`, `'step.interval'`, `timing_seconds('retry.backoff')`。

### `tests/group/test_group_chat_thread_remaining_api_coverage.py::test_chat_thread_fetch_detail_and_lists`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createChatThread`, `createGroup`, `destroyChatThread`, `destroyGroup`, `fetchChatThreadDetail`, `fetchChatThreadsWithParentId`, `fetchJoinedChatThreads`, `fetchJoinedChatThreadsWithParentId`, `getThreadConversation`, `joinChatThread`, `sendMessage`。
- 等待：`'settle.parent_message'`, `'step.interval'`, `timing_seconds('retry.backoff')`。

### `tests/group/test_group_chat_thread_remaining_api_coverage.py::test_chat_thread_fetch_members_and_latest_message`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createChatThread`, `createGroup`, `destroyChatThread`, `destroyGroup`, `fetchChatThreadMember`, `fetchLastMessageWithChatThreads`, `joinChatThread`, `sendMessage`。
- 等待：`'settle.parent_message'`, `'step.interval'`, `timing_seconds('retry.backoff')`。

### `tests/group/test_group_chat_thread_remaining_api_coverage.py::test_chat_thread_update_name_and_leave`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createChatThread`, `createGroup`, `destroyChatThread`, `destroyGroup`, `fetchChatThreadDetail`, `fetchJoinedChatThreadsWithParentId`, `joinChatThread`, `leaveChatThread`, `sendMessage`, `updateChatThreadSubject`。
- 等待：`'settle.parent_message'`, `'step.interval'`, `timing_seconds('retry.backoff')`。

### `tests/group/test_group_chat_thread_user_removed.py::test_chat_thread_remove_member_updates_member_list`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createChatThread`, `createGroup`, `destroyChatThread`, `destroyGroup`, `fetchChatThreadMember`, `joinChatThread`, `removeMemberFromChatThread`, `sendMessage`。
- 等待：`'settle.parent_message'`, `'step.interval'`, `timing_seconds('poll.interval')`。

### `tests/group/test_group_exceptions_announcement.py::test_group_get_announcement_nonexistent_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getGroupAnnouncementFromServer`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_exceptions_announcement.py::test_group_update_announcement_empty`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupAnnouncementFromServer`, `updateGroupAnnouncement`。
- 等待：`'step.interval'`。

### `tests/group/test_group_exceptions_announcement.py::test_group_update_announcement_nonexistent_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`updateGroupAnnouncement`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_exceptions_blocking.py::test_group_block_idempotent`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`blockGroup`, `createGroup`, `destroyGroup`, `unblockGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_exceptions_blocking.py::test_group_block_nonexistent_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`blockGroup`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_exceptions_blocking.py::test_group_unblock_idempotent`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `unblockGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_exceptions_blocking.py::test_group_unblock_nonexistent_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`unblockGroup`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_exceptions_file_list.py::test_group_get_group_file_list_from_server_nonexistent_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getGroupFileListFromServer`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_exceptions_inviter.py::test_group_inviter_user_empty_members`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `inviterUser`。
- 等待：`'step.interval'`。

### `tests/group/test_group_exceptions_inviter.py::test_group_inviter_user_nonexistent_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`inviterUser`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_exceptions_inviter.py::test_group_inviter_user_nonexistent_user`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `inviterUser`。
- 等待：`'step.interval'`。

### `tests/group/test_group_exceptions_joined_groups.py::test_group_get_joined_groups_from_server_with_extra_info_fields`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getJoinedGroupsFromServer`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_desc_reason_options_abnormal_inputs`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_empty_name`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_invite_members_abnormal_inputs`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_max_count_less_than_invite_members`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_name_and_avatar_abnormal_inputs`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_optional_fields_empty`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_exceptions_lifecycle.py::test_group_destroy_group_empty_group_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`destroyGroup`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_exceptions_lifecycle.py::test_group_destroy_group_nonexistent`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`destroyGroup`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_exceptions_lifecycle.py::test_group_get_group_from_server_nonexistent`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getGroupSpecificationFromServer`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_exceptions_lifecycle.py::test_group_get_group_with_id_nonexistent`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getGroupWithId`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_exceptions_member_attributes.py::test_group_fetch_members_attributes_nonexistent_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchMembersAttributesFromGroup`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_exceptions_member_attributes.py::test_group_set_member_attributes_empty_attributes`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `setMemberAttributesFromGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_exceptions_member_attributes.py::test_group_set_member_attributes_nonexistent_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`setMemberAttributesFromGroup`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_exceptions_member_attributes_remove.py::test_group_remove_member_attributes_empty_keys`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `removeMemberAttributesFromGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_exceptions_member_attributes_remove.py::test_group_remove_member_attributes_nonexistent_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`removeMemberAttributesFromGroup`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_exceptions_member_attributes_remove.py::test_group_remove_member_attributes_nonexistent_key`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `removeMemberAttributesFromGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_invalid_paging`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getGroupMemberListFromServer`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_nonexistent_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getGroupMemberListFromServer`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_exceptions_members.py::test_group_add_members_empty_members`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addMembers`, `createGroup`, `destroyGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_exceptions_members.py::test_group_add_members_nonexistent_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addMembers`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_exceptions_members.py::test_group_add_members_nonexistent_user`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addMembers`, `createGroup`, `destroyGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_exceptions_members.py::test_group_leave_group_non_member`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`leaveGroup`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_exceptions_members.py::test_group_remove_members_non_member`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `removeMembers`。
- 等待：`'step.interval'`。

### `tests/group/test_group_exceptions_metadata.py::test_group_update_description_empty`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `updateDescription`。
- 等待：`'step.interval'`。

### `tests/group/test_group_exceptions_metadata.py::test_group_update_description_nonexistent_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`updateDescription`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_exceptions_metadata.py::test_group_update_description_too_long`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `updateDescription`。
- 等待：`'step.interval'`。

### `tests/group/test_group_exceptions_metadata.py::test_group_update_subject_empty`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `updateGroupSubject`。
- 等待：`'step.interval'`。

### `tests/group/test_group_exceptions_metadata.py::test_group_update_subject_nonexistent_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`updateGroupSubject`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_exceptions_metadata.py::test_group_update_subject_too_long`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `updateGroupSubject`。
- 等待：`'step.interval'`。

### `tests/group/test_group_exceptions_public_groups_count.py::test_group_get_public_groups_from_server_invalid_paging`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getPublicGroupsFromServer`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_exceptions_roles.py::test_group_add_admin_non_member`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addAdmin`, `createGroup`, `destroyGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_exceptions_roles.py::test_group_add_admin_nonexistent_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addAdmin`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_exceptions_roles.py::test_group_remove_admin_nonexistent_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`removeAdmin`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_exceptions_roles.py::test_group_update_owner_nonexistent_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`updateGroupOwner`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_exceptions_server_state_lists.py::test_group_server_state_list_nonexistent_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`cmd`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_file_list.py::test_group_get_group_file_list_from_server_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupFileListFromServer`。
- 等待：`'step.interval'`。

### `tests/group/test_group_invitation_state_matrix.py::test_group_invitation_cannot_be_processed_twice`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `first_cmd`, `getGroupSpecificationFromServer`, `second_cmd`, `updateAutoAcceptGroupInvitationSetting`。
- 等待：`'step.interval'`。

### `tests/group/test_group_invitation_state_matrix.py::test_group_invitation_valid_group_without_pending_is_rejected`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`action`, `createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `updateAutoAcceptGroupInvitationSetting`。
- 等待：`'step.interval'`。

### `tests/group/test_group_inviter.py::test_group_inviter_user_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `inviterUser`。
- 等待：`'step.interval'`。

### `tests/group/test_group_join_application_state_matrix.py::test_group_duplicate_join_application_keeps_single_pending_request`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `declineJoinApplication`, `destroyGroup`, `getGroupSpecificationFromServer`, `requestToJoinPublicGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_join_application_state_matrix.py::test_group_join_application_cannot_be_processed_twice`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `first_cmd`, `getGroupSpecificationFromServer`, `requestToJoinPublicGroup`, `second_cmd`。
- 等待：`'step.interval'`。

### `tests/group/test_group_join_application_state_matrix.py::test_group_join_application_empty_reason_uses_server_default`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `declineJoinApplication`, `destroyGroup`, `getGroupSpecificationFromServer`, `requestToJoinPublicGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_join_application_state_matrix.py::test_group_join_application_processing_permission_by_role`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addAdmin`, `command`, `createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `login`, `logout`, `requestToJoinPublicGroup`, `startCallback`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/group/test_group_join_application_state_matrix.py::test_group_join_application_valid_group_without_pending_is_rejected`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`action`, `createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`。
- 等待：`'step.interval'`。

### `tests/group/test_group_join_application_state_matrix.py::test_group_non_member_cannot_process_join_application`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`command`, `createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `login`, `logout`, `requestToJoinPublicGroup`, `startCallback`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/group/test_group_join_requests_and_invitations.py::test_group_accept_invitation_from_group_without_pending_invite`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`acceptInvitationFromGroup`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_join_requests_and_invitations.py::test_group_accept_join_application_nonexistent_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`acceptJoinApplication`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_join_requests_and_invitations.py::test_group_accept_join_application_nonexistent_user`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`acceptJoinApplication`, `createGroup`, `destroyGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_join_requests_and_invitations.py::test_group_decline_invitation_from_group_without_pending_invite`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`declineInvitationFromGroup`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_join_requests_and_invitations.py::test_group_decline_join_application_nonexistent_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`declineJoinApplication`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_join_requests_and_invitations.py::test_group_invitation_auto_accept_when_confirmation_required`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `updateAutoAcceptGroupInvitationSetting`。
- 等待：`'step.interval'`。

### `tests/group/test_group_join_requests_and_invitations.py::test_group_invitation_explicit_accept_when_auto_accept_disabled`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`acceptInvitationFromGroup`, `createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `updateAutoAcceptGroupInvitationSetting`。
- 等待：`'step.interval'`。

### `tests/group/test_group_join_requests_and_invitations.py::test_group_request_to_join_and_accept_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`acceptJoinApplication`, `createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `requestToJoinPublicGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_join_requests_and_invitations.py::test_group_request_to_join_and_decline_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `declineJoinApplication`, `destroyGroup`, `getGroupSpecificationFromServer`, `requestToJoinPublicGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_join_requests_and_invitations.py::test_group_request_to_join_public_group_nonexistent_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`requestToJoinPublicGroup`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_joined_groups.py::test_group_get_joined_groups_from_server_contains_created_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getJoinedGroupsFromServer`。
- 等待：`'step.interval'`。

### `tests/group/test_group_joined_groups.py::test_group_get_joined_groups_local_contains_created_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getJoinedGroups`。
- 等待：`'step.interval'`。

### `tests/group/test_group_joined_groups.py::test_group_joined_lists_follow_invite_remove_readd_and_member_leave`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addMembers`, `cmd`, `createGroup`, `destroyGroup`, `leaveGroup`, `removeMembers`。
- 等待：`'step.interval'`, `timing_seconds('step.interval')`。

### `tests/group/test_group_lifecycle.py::test_group_create_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_lifecycle.py::test_group_get_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupWithId`。
- 等待：`'step.interval'`。

### `tests/group/test_group_lifecycle.py::test_group_get_group_from_server`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`。
- 等待：`'step.interval'`。

### `tests/group/test_group_lifecycle.py::test_group_get_group_from_server_after_destroy`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`。
- 等待：`'step.interval'`。

### `tests/group/test_group_member_attributes.py::test_group_set_and_fetch_member_attributes_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `fetchMemberAttributesFromGroup`, `fetchMembersAttributesFromGroup`, `setMemberAttributesFromGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_member_attributes_remove.py::test_group_remove_member_attributes_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `fetchMemberAttributesFromGroup`, `fetchMembersAttributesFromGroup`, `removeMemberAttributesFromGroup`, `setMemberAttributesFromGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_member_info.py::test_group_fetch_members_info_contains_updated_own_profile`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `fetchGroupMembersInfo`, `fetchUserInfoById`, `updateOwnUserInfo`。
- 等待：`'step.interval'`。

### `tests/group/test_group_member_list.py::test_group_get_group_member_list_from_server_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupMemberListFromServer`。
- 等待：`'step.interval'`。

### `tests/group/test_group_members.py::test_group_add_remove_members`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addMembers`, `createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `removeMembers`。
- 等待：`'step.interval'`。

### `tests/group/test_group_members.py::test_group_join_and_leave_public_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `joinPublicGroup`, `leaveGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_members.py::test_group_join_public_group_rejects_private_member_invite_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `joinPublicGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_members.py::test_group_members_batch_join_exit_new_events`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addMembers`, `createGroup`, `destroyGroup`, `removeMembers`。
- 等待：`'step.interval'`。

### `tests/group/test_group_membership_checks.py::test_group_is_member_in_white_list_and_mute_list_nonexistent_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`cmd`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_membership_checks.py::test_group_is_member_in_white_list_and_mute_list_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `isMemberInGroupMuteList`, `isMemberInWhiteListFromServer`。
- 等待：`'step.interval'`。

### `tests/group/test_group_message_send.py::test_group_message_ack_boundary_methods`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`ackGroupMessageRead`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_message_send.py::test_group_message_read_ack_updates_count`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`ackGroupMessageRead`, `createGroup`, `destroyGroup`, `groupAckCount`, `sendMessage`。
- 等待：`'step.interval'`, `timing_seconds('poll.interval')`, `timing_seconds('settle.normal')`。

### `tests/group/test_group_message_send.py::test_group_message_send_receive_by_type`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessageWithType`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_message_send.py::test_group_message_send_receive_combine`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessageWithType`。
- 等待：`'step.interval'`。

### `tests/group/test_group_message_send.py::test_group_message_send_rejects_invalid_group_target`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`sendMessageWithType`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_message_send.py::test_group_message_send_rejects_non_member_states`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `leaveGroup`, `removeMembers`, `sendMessageWithType`。
- 等待：`'step.interval'`, `timing_seconds('settle.normal')`。

### `tests/group/test_group_metadata.py::test_group_update_description`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `getGroupWithId`, `updateDescription`。
- 等待：`'step.interval'`。

### `tests/group/test_group_metadata.py::test_group_update_subject`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `getGroupWithId`, `updateGroupSubject`。
- 等待：`'step.interval'`。

### `tests/group/test_group_moderation.py::test_group_add_remove_white_list_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addWhiteList`, `createGroup`, `destroyGroup`, `removeWhiteList`。
- 等待：`'step.interval'`。

### `tests/group/test_group_moderation.py::test_group_block_members_non_member`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`blockMembers`, `createGroup`, `destroyGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_moderation.py::test_group_block_unblock_members_nonexistent_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`cmd`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_moderation.py::test_group_block_unblock_members_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`blockMembers`, `createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `unblockMembers`。
- 等待：`'step.interval'`。

### `tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`cmd`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_moderation.py::test_group_mute_all_unmute_all_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `muteAllMembers`, `unMuteAllMembers`。
- 等待：`'step.interval'`。

### `tests/group/test_group_moderation.py::test_group_mute_unmute_members_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `muteMembers`, `unMuteMembers`。
- 等待：`'step.interval'`。

### `tests/group/test_group_moderation.py::test_group_update_group_ext_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `updateGroupExt`。
- 等待：`'step.interval'`。

### `tests/group/test_group_offline_invitation_application.py::test_group_offline_applicant_receives_application_result_after_relogin`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`cmd`, `createGroup`, `destroyGroup`, `getCurrentUser`, `getGroupSpecificationFromServer`, `login`, `logout`, `requestToJoinPublicGroup`, `startCallback`, `updateAutoAcceptGroupInvitationSetting`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/group/test_group_offline_invitation_application.py::test_group_offline_invitation_received_and_processed_after_login`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitationFromGroup`, `cmd`, `createGroup`, `declineInvitationFromGroup`, `destroyGroup`, `getCurrentUser`, `getGroupSpecificationFromServer`, `getGroupWithId`, `login`, `logout`, `startCallback`, `updateAutoAcceptGroupInvitationSetting`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/group/test_group_offline_invitation_application.py::test_group_offline_owner_receives_invitation_result_after_relogin`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`acceptInvitationFromGroup`, `createGroup`, `declineInvitationFromGroup`, `destroyGroup`, `getCurrentUser`, `getGroupSpecificationFromServer`, `login`, `logout`, `startCallback`, `updateAutoAcceptGroupInvitationSetting`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/group/test_group_offline_invitation_application.py::test_group_offline_owner_receives_join_application_and_processes_after_login`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`cmd`, `createGroup`, `destroyGroup`, `getCurrentUser`, `getGroupSpecificationFromServer`, `login`, `logout`, `requestToJoinPublicGroup`, `startCallback`, `updateAutoAcceptGroupInvitationSetting`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/group/test_group_offline_member_state.py::test_group_offline_group_destroyed_state_after_login`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`cmd`, `createGroup`, `destroyGroup`, `getCurrentUser`, `getGroupWithId`, `login`, `logout`, `startCallback`, `updateAutoAcceptGroupInvitationSetting`。
- 等待：`'settle.offline'`, `'step.interval'`, `timing_seconds('settle.normal')`。

### `tests/group/test_group_offline_member_state.py::test_group_offline_member_blocked_state_after_login`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`blockMembers`, `cmd`, `createGroup`, `destroyGroup`, `getCurrentUser`, `getGroupSpecificationFromServer`, `getGroupWithId`, `joinPublicGroup`, `login`, `logout`, `startCallback`, `updateAutoAcceptGroupInvitationSetting`。
- 等待：`'settle.offline'`, `'step.interval'`, `timing_seconds('settle.normal')`。

### `tests/group/test_group_offline_member_state.py::test_group_offline_member_leave_state_persists_after_relogin`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`cmd`, `createGroup`, `destroyGroup`, `getCurrentUser`, `getGroupSpecificationFromServer`, `getGroupWithId`, `leaveGroup`, `login`, `logout`, `startCallback`, `updateAutoAcceptGroupInvitationSetting`。
- 等待：`'settle.offline'`, `'step.interval'`, `timing_seconds('settle.normal')`。

### `tests/group/test_group_offline_member_state.py::test_group_offline_member_removed_state_after_login`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`cmd`, `createGroup`, `destroyGroup`, `getCurrentUser`, `getGroupSpecificationFromServer`, `getGroupWithId`, `login`, `logout`, `removeMembers`, `startCallback`, `updateAutoAcceptGroupInvitationSetting`。
- 等待：`'settle.offline'`, `'step.interval'`, `timing_seconds('settle.normal')`。

### `tests/group/test_group_offline_message_delivery.py::test_group_offline_cmd_deliver_online_only_not_received_after_login`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`createGroup`, `destroyGroup`, `getCurrentUser`, `getMessage`, `login`, `logout`, `sendMessageWithType`, `startCallback`, `updateAutoAcceptGroupInvitationSetting`。
- 等待：`'settle.offline'`, `'step.interval'`, `timing_seconds('settle.normal')`。

### `tests/group/test_group_offline_message_delivery.py::test_group_offline_message_recalled_before_first_recipient_login`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`createGroup`, `destroyGroup`, `getCurrentUser`, `getMessage`, `login`, `logout`, `recallMessage`, `sendMessageWithType`, `startCallback`, `updateAutoAcceptGroupInvitationSetting`。
- 等待：`'settle.offline'`, `'step.interval'`, `timing_seconds('settle.normal')`。

### `tests/group/test_group_offline_message_delivery.py::test_group_offline_multiple_text_messages_and_conversation_state`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`createGroup`, `destroyGroup`, `getCurrentUser`, `getLatestMessage`, `getUnreadMsgCount`, `login`, `logout`, `sendMessageWithType`, `startCallback`, `updateAutoAcceptGroupInvitationSetting`。
- 等待：`'settle.offline'`, `'step.interval'`, `timing_seconds('settle.normal')`。

### `tests/group/test_group_offline_message_delivery.py::test_group_offline_recipient_receives_content_change_after_relogin`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`createGroup`, `destroyGroup`, `getCurrentUser`, `getMessage`, `login`, `logout`, `modifyMessage`, `sendMessageWithType`, `startCallback`, `updateAutoAcceptGroupInvitationSetting`。
- 等待：`'settle.offline'`, `'step.interval'`, `timing_seconds('settle.normal')`。

### `tests/group/test_group_offline_message_delivery.py::test_group_offline_recipient_receives_recall_after_relogin`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`createGroup`, `destroyGroup`, `getCurrentUser`, `getMessage`, `login`, `logout`, `recallMessage`, `sendMessageWithType`, `startCallback`, `updateAutoAcceptGroupInvitationSetting`。
- 等待：`'settle.offline'`, `'step.interval'`, `timing_seconds('settle.normal')`。

### `tests/group/test_group_offline_message_delivery.py::test_group_offline_sender_reads_ack_count_after_relogin`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`ackGroupMessageRead`, `asyncFetchGroupAcks`, `createGroup`, `destroyGroup`, `getCurrentUser`, `groupAckCount`, `login`, `logout`, `sendMessage`, `startCallback`, `updateAutoAcceptGroupInvitationSetting`。
- 等待：`'settle.offline'`, `'step.interval'`, `timing_seconds('poll.interval')`, `timing_seconds('settle.normal')`, `timing_seconds('settle.ack_projection')`。

### `tests/group/test_group_offline_message_delivery.py::test_group_offline_text_message_received_after_login`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`createGroup`, `destroyGroup`, `getCurrentUser`, `login`, `logout`, `sendMessageWithType`, `startCallback`, `updateAutoAcceptGroupInvitationSetting`。
- 等待：`'settle.offline'`, `timing_seconds('settle.normal')`。

### `tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_admin_add_remove_final_state`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`addAdmin`, `createGroup`, `destroyGroup`, `getCurrentUser`, `getGroupSpecificationFromServer`, `getGroupWithId`, `login`, `logout`, `removeAdmin`, `startCallback`, `updateAutoAcceptGroupInvitationSetting`。
- 等待：`'settle.offline'`, `'step.interval'`, `timing_seconds('settle.normal')`。

### `tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_allow_list_add_remove_final_state`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`cmd`, `createGroup`, `destroyGroup`, `getCurrentUser`, `isMemberInWhiteListFromServer`, `login`, `logout`, `startCallback`, `updateAutoAcceptGroupInvitationSetting`。
- 等待：`'settle.offline'`, `'step.interval'`, `timing_seconds('settle.normal')`。

### `tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_announcement_final_state`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`createGroup`, `destroyGroup`, `getCurrentUser`, `getGroupAnnouncementFromServer`, `login`, `logout`, `startCallback`, `updateAutoAcceptGroupInvitationSetting`, `updateGroupAnnouncement`。
- 等待：`'settle.offline'`, `'step.interval'`, `timing_seconds('settle.normal')`。

### `tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_member_attributes_final_state`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`createGroup`, `destroyGroup`, `fetchMembersAttributesFromGroup`, `getCurrentUser`, `login`, `logout`, `setMemberAttributesFromGroup`, `startCallback`, `updateAutoAcceptGroupInvitationSetting`。
- 等待：`'settle.offline'`, `'step.interval'`, `timing_seconds('settle.normal')`。

### `tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_member_mute_unmute_final_state`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`createGroup`, `destroyGroup`, `getCurrentUser`, `getGroupSpecificationFromServer`, `login`, `logout`, `muteMembers`, `startCallback`, `unMuteMembers`, `updateAutoAcceptGroupInvitationSetting`。
- 等待：`'settle.offline'`, `'step.interval'`, `timing_seconds('settle.normal')`。

### `tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_metadata_final_state`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`cmd`, `createGroup`, `destroyGroup`, `getCurrentUser`, `getGroupSpecificationFromServer`, `login`, `logout`, `startCallback`, `updateAutoAcceptGroupInvitationSetting`。
- 等待：`'settle.offline'`, `'step.interval'`, `timing_seconds('settle.normal')`。

### `tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_mute_all_unmute_all_final_state`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`cmd`, `createGroup`, `destroyGroup`, `getCurrentUser`, `getGroupSpecificationFromServer`, `login`, `logout`, `startCallback`, `updateAutoAcceptGroupInvitationSetting`。
- 等待：`'settle.offline'`, `'step.interval'`, `timing_seconds('settle.normal')`。

### `tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_shared_file_upload_delete_final_state`

- 登录前离线等待：公共 helper 3 秒（包含嵌套入口）。
- 业务命令：`createGroup`, `destroyGroup`, `getCurrentUser`, `getGroupFileListFromServer`, `login`, `logout`, `removeGroupSharedFile`, `startCallback`, `updateAutoAcceptGroupInvitationSetting`, `uploadGroupSharedFile`。
- 等待：`'settle.offline'`, `'step.interval'`, `timing_seconds('settle.normal')`。

### `tests/group/test_group_owner_removal_matrix.py::test_group_batch_remove_ignores_owner_and_non_member_but_removes_valid_member`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `removeMembers`。
- 等待：`'step.interval'`。

### `tests/group/test_group_owner_removal_matrix.py::test_group_non_member_cannot_transfer_ownership`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `login`, `logout`, `startCallback`, `updateGroupOwner`。
- 等待：`'settle.offline'`。

### `tests/group/test_group_owner_removal_matrix.py::test_group_non_owner_cannot_transfer_ownership`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addAdmin`, `createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `updateGroupOwner`。
- 等待：`'step.interval'`。

### `tests/group/test_group_owner_removal_matrix.py::test_group_owner_removes_admin_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addAdmin`, `createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `removeMembers`。
- 等待：`'step.interval'`。

### `tests/group/test_group_owner_removal_matrix.py::test_group_remove_current_owner_is_ignored`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `removeMembers`。
- 等待：`'step.interval'`。

### `tests/group/test_group_owner_removal_matrix.py::test_group_remove_other_member_permission_by_role`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addAdmin`, `createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `removeMembers`。
- 等待：`'step.interval'`。

### `tests/group/test_group_owner_removal_matrix.py::test_group_transfer_owner_target_boundaries`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `updateGroupOwner`。
- 等待：`'step.interval'`。

### `tests/group/test_group_public_groups_count.py::test_group_fetch_joined_group_count_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchJoinedGroupCount`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_public_groups_count.py::test_group_get_public_groups_from_server_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getPublicGroupsFromServer`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_public_groups_count.py::test_group_public_groups_cursor_paginates_two_created_groups`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getPublicGroupsFromServer`。
- 等待：`'step.interval'`, `timing_seconds('settle.cursor_order')`。

### `tests/group/test_group_remaining_api_coverage.py::test_group_clear_all_groups_from_local_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`clearAllGroupsFromDB`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_remaining_api_coverage.py::test_group_fetch_members_info_empty_group_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchGroupMembersInfo`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_remaining_api_coverage.py::test_group_fetch_members_info_invalid_limit`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `fetchGroupMembersInfo`, `fetchUserInfoById`。
- 等待：`'step.interval'`。

### `tests/group/test_group_remaining_api_coverage.py::test_group_update_avatar_abnormal_values`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `updateGroupAvatar`。
- 等待：`'step.interval'`。

### `tests/group/test_group_remaining_api_coverage.py::test_group_update_avatar_empty_group_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`updateGroupAvatar`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_remaining_api_coverage.py::test_group_update_avatar_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `updateGroupAvatar`。
- 等待：`'step.interval'`。

### `tests/group/test_group_role_permission_matrix.py::test_group_allow_list_role_permission_matrix`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addAdmin`, `addWhiteList`, `createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `isMemberInWhiteListFromServer`, `login`, `logout`, `removeWhiteList`, `startCallback`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/group/test_group_role_permission_matrix.py::test_group_blocklist_admin_member_role_matrix`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addAdmin`, `blockMembers`, `cmd`, `createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `unblockMembers`。
- 等待：`'step.interval'`。

### `tests/group/test_group_role_permission_matrix.py::test_group_destroy_owner_only_role_denied`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addAdmin`, `createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`。
- 等待：`'step.interval'`。

### `tests/group/test_group_role_permission_matrix.py::test_group_message_block_role_matrix`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addAdmin`, `blockGroup`, `createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `unblockGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_role_permission_matrix.py::test_group_metadata_admin_member_role_matrix`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addAdmin`, `cmd`, `createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`。
- 等待：`'step.interval'`。

### `tests/group/test_group_role_permission_matrix.py::test_group_mute_all_role_permission_matrix`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addAdmin`, `createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `login`, `logout`, `muteAllMembers`, `startCallback`, `unMuteAllMembers`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/group/test_group_role_permission_matrix.py::test_group_mute_members_role_permission_matrix`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addAdmin`, `createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `login`, `logout`, `muteMembers`, `startCallback`, `unMuteMembers`。
- 等待：`'settle.offline'`, `'step.interval'`。

### `tests/group/test_group_roles.py::test_group_add_admin_and_remove_admin_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addAdmin`, `createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `removeAdmin`。
- 等待：`'step.interval'`。

### `tests/group/test_group_server_state_lists.py::test_group_get_group_block_list_from_server_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupBlockListFromServer`。
- 等待：`'step.interval'`。

### `tests/group/test_group_server_state_lists.py::test_group_get_group_mute_list_from_server_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupMuteListFromServer`。
- 等待：`'step.interval'`。

### `tests/group/test_group_server_state_lists.py::test_group_get_group_white_list_and_member_check_success`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupWhiteListFromServer`, `isMemberInWhiteListFromServer`。
- 等待：`'step.interval'`。

### `tests/group/test_group_shared_files.py::test_group_admin_upload_remove_shared_file_notifies_owner`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addAdmin`, `createGroup`, `destroyGroup`, `getGroupFileListFromServer`, `removeGroupSharedFile`, `uploadGroupSharedFile`。
- 等待：`'step.interval'`。

### `tests/group/test_group_shared_files.py::test_group_download_shared_file_nonexistent_group_current_behavior`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`downloadGroupSharedFile`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_shared_files.py::test_group_owner_upload_remove_shared_file_notifies_member`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupFileListFromServer`, `removeGroupSharedFile`, `uploadGroupSharedFile`。
- 等待：`'step.interval'`。

### `tests/group/test_group_shared_files.py::test_group_remove_shared_file_nonexistent_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`removeGroupSharedFile`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_shared_files.py::test_group_upload_shared_file_explicit_host_path_is_invalid`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `uploadGroupSharedFile`。
- 等待：`'step.interval'`。

### `tests/group/test_group_shared_files.py::test_group_upload_shared_file_invalid_path`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `uploadGroupSharedFile`。
- 等待：`'step.interval'`。

### `tests/group/test_group_shared_files.py::test_group_upload_shared_file_nonexistent_group`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`uploadGroupSharedFile`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/group/test_group_style_membership_matrix.py::test_group_create_group_invites_member_for_each_remaining_style`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`。
- 等待：`'step.interval'`。

### `tests/group/test_group_style_membership_matrix.py::test_group_direct_invite_ignores_auto_accept_disabled_when_confirmation_not_required`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addMembers`, `createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `updateAutoAcceptGroupInvitationSetting`。
- 等待：`'step.interval'`。

### `tests/group/test_group_style_membership_matrix.py::test_group_join_public_group_rejects_every_non_open_style`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `joinPublicGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_style_membership_matrix.py::test_group_member_invitation_permission_depends_on_style`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`addAdmin`, `createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `invite_cmd`。
- 等待：`'step.interval'`。

### `tests/group/test_group_style_membership_matrix.py::test_group_non_member_cannot_invite_user`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `invite_cmd`。
- 等待：`'step.interval'`。

### `tests/group/test_group_style_membership_matrix.py::test_group_owner_can_invite_for_each_remaining_style`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `invite_cmd`。
- 等待：`'step.interval'`。

### `tests/group/test_group_style_membership_matrix.py::test_group_public_open_join_rejects_blocked_user`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`blockMembers`, `createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `joinPublicGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_style_membership_matrix.py::test_group_public_open_join_rejects_duplicate_membership`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `joinPublicGroup`。
- 等待：`'step.interval'`。

### `tests/group/test_group_style_membership_matrix.py::test_group_public_open_join_rejects_when_group_is_full`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `joinPublicGroup`, `login`, `logout`, `startCallback`。
- 等待：`'settle.offline'`。

### `tests/group/test_group_style_membership_matrix.py::test_group_request_to_join_rejects_every_non_approval_style`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`createGroup`, `destroyGroup`, `getGroupSpecificationFromServer`, `requestToJoinPublicGroup`。
- 等待：`'step.interval'`。

### `tests/presence/test_presence.py::test_fetch_subscribed_members_invalid_pagination`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchSubscribedMembersWithPageNum`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/presence/test_presence.py::test_fetch_subscribed_members_pagination`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchSubscribedMembersWithPageNum`, `presenceSubscribe`, `presenceWithDescription`。
- 等待：`'step.interval'`。

### `tests/presence/test_presence.py::test_fetch_subscribed_members_pagination_page_size_one`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchSubscribedMembersWithPageNum`, `presenceSubscribe`, `presenceWithDescription`。
- 等待：`'step.interval'`。

### `tests/presence/test_presence.py::test_presence_publish_128k_desc`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`presenceWithDescription`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/presence/test_presence.py::test_presence_publish_empty_desc_then_fetch`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchPresenceStatus`, `presenceSubscribe`, `presenceWithDescription`。
- 等待：`'step.interval'`。

### `tests/presence/test_presence.py::test_presence_publish_subscribe_query_unsubscribe`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchPresenceStatus`, `fetchSubscribedMembersWithPageNum`, `presenceSubscribe`, `presenceUnsubscribe`, `presenceWithDescription`。
- 等待：`'step.interval'`。

### `tests/presence/test_presence.py::test_presence_subscribe_expiry_over_30_days`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`presenceSubscribe`, `presenceWithDescription`。
- 等待：`'step.interval'`。

### `tests/presence/test_presence.py::test_presence_subscribe_nonexistent_user`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`presenceSubscribe`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/presence/test_presence.py::test_presence_subscribe_over_100_members`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`presenceSubscribe`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/presence/test_presence.py::test_presence_unsubscribe_over_100_members`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`presenceUnsubscribe`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/push/test_push_remaining_api_coverage.py::test_push_conversation_silent_mode_flow`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchConversationSilentMode`, `fetchSilentModeForConversations`, `removeConversationSilentMode`, `setConversationSilentMode`。
- 等待：`'step.interval'`。

### `tests/push/test_push_remaining_api_coverage.py::test_push_fetch_configs_update_nickname_and_style`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`getImPushConfigFromServer`, `updateImPushStyle`, `updatePushNickname`。
- 等待：`'step.interval'`。

### `tests/push/test_push_remaining_api_coverage.py::test_push_global_silent_mode_flow`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchSilentModeForAll`, `setSilentModeForAll`。
- 等待：`'step.interval'`。

### `tests/push/test_push_remaining_api_coverage.py::test_push_preferred_language_and_template`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchPreferredNotificationLanguage`, `getPushTemplate`, `setPreferredNotificationLanguage`, `setPushTemplate`。
- 等待：`'step.interval'`。

### `tests/push/test_push_remaining_api_coverage.py::test_push_sync_conversations_silent_mode_current_environment`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`syncSilentModels`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/push/test_push_remaining_api_coverage.py::test_push_vendor_token_update_current_environment`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`cmd`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/user_info/test_user_info.py::test_user_info_fetch_by_id_empty_user_ids`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchUserInfoById`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/user_info/test_user_info.py::test_user_info_fetch_by_id_normal`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchUserInfoById`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/user_info/test_user_info.py::test_user_info_fetch_by_id_user_ids_over_100`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchUserInfoById`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/user_info/test_user_info.py::test_user_info_fetch_by_id_with_type_normal`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchUserInfoByIdWithType`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/user_info/test_user_info.py::test_user_info_update_own_nickname_empty`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`updateOwnUserInfo`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/user_info/test_user_info.py::test_user_info_update_own_nickname_length_over_64`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`updateOwnUserInfo`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/user_info/test_user_info.py::test_user_info_update_own_set_and_modify`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`updateOwnUserInfo`。
- 等待：`'step.interval'`。

### `tests/user_info/test_user_info.py::test_user_info_update_own_with_type_nickname`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`updateOwnUserInfoWithType`。
- 等待：无独立暂停；单步/纯查询/纯错误路径，事件等待保留。

### `tests/user_info/test_user_info.py::test_user_info_update_then_fetch_own_info`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchOwnInfo`, `updateOwnUserInfo`。
- 等待：`'step.interval'`。

### `tests/user_info/test_user_info.py::test_user_info_update_then_fetch_user_info_by_id`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchUserInfoById`, `updateOwnUserInfo`。
- 等待：`'step.interval'`。

### `tests/user_info/test_user_info.py::test_user_info_update_then_fetch_user_info_by_id_with_type`

- 登录前离线等待：无公共离线重登；直接登录例外见上节。
- 业务命令：`fetchUserInfoByIdWithType`, `updateOwnUserInfo`。
- 等待：`'step.interval'`。
