# Flutter 5.0.0 平版验收报告

- 工作目录：`/Users/asterisk/Codes/zuoyu_flutter/im_flutter_sdk/.worktree/5.0.0`
- 分支：`5.0.0`
- 源版本：iOS `4.24.1 → 5.0.0`；Android `SDK_4.24.1 → SDK_5.0.0`
- 目标版本：Flutter `5.0.0`
- 完整源签名与 decision：[`01-api-diff.md`](./01-api-diff.md)
- 契约：[`02-contract.md`](./02-contract.md)
- 实现与验证：[`03-implementation.md`](./03-implementation.md)、[`04-verification.md`](./04-verification.md)
- 代码状态：5.0.0 基线平版、RN 对照修订、token/env 自动化、运行报告工具已分别提交为 `dbab80b3`、`a2f27eff`、`6d16ce85`、`4c555667`；本轮复验修订与本文档一并提交，均未 push。

## 1. 二维对照

| 变更项 | iOS 源 | Android 源 | Dart | Android Wrapper | iOS Wrapper | 状态 |
| --- | --- | --- | --- | --- | --- | --- |
| `client_register_account` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `client_fetch_token_with_password` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `client_login_with_password` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `client_login_with_agora_token` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `client_service_check` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `client_check_type` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `client_auto_login_state_query` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `client_statistics_manager` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `statistics_module` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `client_get_logged_in_devices_with_password` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `client_kick_device_with_password` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `client_kick_all_devices_with_password` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `client_delegate_sync_data_start` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `client_delegate_sync_data_finished` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `client_delegate_on_database_opened` | 有 | 有 | 已实现 | 已实现 | 已实现 | ⚠️ 已实现，跨端差异见问题清单 |
| `client_login_with_username_token_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `client_get_device_config` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `client_delegate_auto_login_did_complete` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `client_delegate_user_account_did_login_from_other_device` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `client_renew_token_no_callback_removed` | 有 | 无 | 已有异步公开 API | 强制适配 | - | ⚠️ 单端变更，按契约 defer |
| `client_get_logged_in_devices_token_sync_removed` | 有 | 无 | 改用异步 API | 强制适配 | - | ⚠️ 单端变更，按契约 defer |
| `client_fetch_logged_in_devices_with_token_new` | 无 | 有 | 已使用 | 强制适配 | - | ⚠️ 单端变更，按契约 defer |
| `client_is_database_opened_new` | 无 | 有 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `client_get_device_info_new` | 无 | 有 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `client_version_bump` | 无 | 有 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `options_data_sync_type_enum` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 已接受 native 默认差异，与 RN 5.0.0 一致 |
| `options_data_sync_type` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 已接受 native 默认差异，与 RN 5.0.0 一致 |
| `options_is_auto_login` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `options_enable_require_read_ack` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `options_enable_auto_sync_contacts` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `options_report_server_removed` | 无 | 有 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `options_area_code_int_removed` | 无 | 有 | 保持 int 常量 | 强制映射 enum | - | ⚠️ 单端变更，按契约 defer |
| `options_area_code_enum_new` | 无 | 有 | 保持 int 常量 | 强制映射 enum | - | ⚠️ 单端变更，按契约 defer |
| `options_set_area_code_param_changed` | 无 | 有 | 保持 int 常量 | 强制映射 enum | - | ⚠️ 单端变更，按契约 defer |
| `multidevice_event_conversation_unread_message_count_cleared` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `multidevice_event_all_conversation_unread_message_count_cleared` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `chat_fetch_conversations_from_server` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `chat_get_pinned_conversations_from_server` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `chat_get_conversations_with_cursor_filter` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `chat_modify_message` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `chat_send_message_read_ack` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `chat_send_group_message_read_ack` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `chat_send_message_read_receipts` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `chat_ack_conversation_read` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `chat_clear_conversation_unread_message_count` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `chat_clear_all_conversation_unread_message_count` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `chat_get_group_message_read_receipts` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `chat_fetch_history_messages` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `chat_fetch_group_message_read_receipts` | 有 | 有 | 已实现（`totalCount?`） | 已实现（无 totalCount） | 已实现（含 totalCount） | ✅ 平台差异由可空字段承接，与 RN 5.0.0 一致 |
| `chat_report_message` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `chat_mark_all_conversations_as_read` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `chat_delegate_messages_did_read` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `chat_delegate_group_message_did_read` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `chat_delegate_group_message_ack_has_changed` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `chat_delegate_on_conversation_read` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `chat_delegate_on_message_read_receipts` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `chat_get_unread_message_count` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `chat_import_conversations` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `chat_resend_message` | 有 | 无 | API 保留 | - | 强制改调 sendMessage | ⚠️ 单端变更，按契约 defer |
| `chat_load_messages_with_type` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `chat_load_messages_with_keyword_legacy` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `chat_load_messages_with_keyword_scope` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `chat_delete_messages_before` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `chat_delegate_conversation_list_did_update` | 有 | 无 | 事件保持 | - | 强制迁移 delegate | ⚠️ 单端变更，按契约 defer |
| `chat_add_conversation_delegate` | 有 | 无 | 不新增公开 API | - | 内部注册 | ⚠️ 单端变更，按契约 defer |
| `conversation_delegate_protocol` | 有 | 无 | 不新增公开类型 | - | 内部采用 | ⚠️ 单端变更，按契约 defer |
| `chat_load_all_conversations_removed` | 无 | 有 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `chat_update_participant_removed` | 无 | 有 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `chat_async_fetch_history_messages_new` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `chat_async_delete_conversations_new` | 无 | 有 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `msg_listener_on_message_recalled_removed` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `message_is_peer_read` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `message_is_read` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `message_is_need_read_receipt` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `message_group_read_receipt_count` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `conversation_name_avatar` | 有 | 有 | 已实现 | 已实现 | 已实现 | ⚠️ 已实现，跨端差异见问题清单 |
| `conversation_mark_message_as_read` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `group_read_receipt_type` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `message_read_receipt_type` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `message_get_reaction` | 有 | 无 | 现有列表 API 不变 | - | 删除失效直接调用 | ⚠️ 单端变更，按契约 defer |
| `file_message_body_init_with_data` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `file_message_body_init_with_local_path` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `image_message_body_init_with_data` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `stream_chunk_sequence_number` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `stream_chunk_is_complete` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `conversation_get_message_param_changed` | 无 | 有 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `conversation_search_msg_scope_sync_removed` | 无 | 有 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `message_create_txt_send_message_removed` | 无 | 有 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `message_get_user_name_removed` | 无 | 有 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `message_get_recaller_removed` | 无 | 有 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_options_type` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `group_style_enum` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `group_configs_type` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 上层默认与 RN 5.0.0 一致 |
| `group_configs_type_enum` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 位值逐端映射 |
| `group_create_group` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 上层默认与 RN 5.0.0 一致 |
| `group_create_group_with_avatar` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 上层默认与 RN 5.0.0 一致 |
| `group_update_group_configs` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 上层默认与 RN 5.0.0 一致 |
| `group_get_public_groups_from_server` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `group_get_joined_groups_from_server` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `group_delegate_join_request_declined` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `group_delegate_user_did_join_group` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `group_delegate_user_did_leave_group` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `group_settings_property` | 有 | 无 | 已并入 configs | 已适配 | 已适配 | ⚠️ 单端变更，按契约 defer |
| `group_is_push_notification_enabled` | 有 | 无 | 未新增 | - | 删除失效序列化 | ⚠️ 单端变更，按契约 defer |
| `group_search_public_group` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_get_groups_without_push_notification` | 有 | 无 | 未新增 | - | 删除失效路由 | ⚠️ 单端变更，按契约 defer |
| `group_get_group_specification_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_get_group_member_list_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_get_group_blacklist_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_get_group_mute_list_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_get_group_file_list_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_get_group_white_list_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_is_member_in_white_list_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_get_group_announcement_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_add_occupants_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_remove_occupants_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_block_occupants_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_unblock_occupants_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_change_group_subject_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_change_description_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_leave_group_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_destroy_group_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_block_group_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_unblock_group_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_update_group_owner_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_add_admin_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_remove_admin_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_mute_members_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_unmute_members_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_mute_all_members_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_unmute_all_members_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_add_white_list_members_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_remove_white_list_members_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_remove_group_shared_file_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_update_group_announcement_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_update_group_ext_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_join_public_group_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_apply_join_public_group` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_accept_join_application` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_decline_join_application` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_accept_invitation_from_group_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_decline_invitation_from_group` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_is_member_only_renamed` | 无 | 有 | 改为 isJoinApprovalRequired | 已适配 | 已适配 | ⚠️ 单端变更，按契约 defer |
| `group_get_users_new` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_get_from_server_fetch_members_removed` | 无 | 有 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `group_load_all_groups_removed` | 无 | 有 | 本地 API 保留 | 强制改用 getAllGroups | - | ⚠️ 单端变更，按契约 defer |
| `group_async_upload_shared_file_overload_removed` | 无 | 有 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `contact_get_all_contacts_from_server` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `contact_get_contacts_from_server_with_cursor` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `contact_get_contacts_string_list_from_server` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `contact_delegate_on_friend_sync_start` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `contact_delegate_on_friend_sync_finished` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `contact_add_contact_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `contact_get_blacklist_from_server_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `contact_add_user_to_blacklist_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `contact_remove_user_from_blacklist_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `contact_accept_invitation_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `contact_decline_invitation_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `contact_get_self_ids_on_other_platform_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `contact_save_black_list` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `room_create_chatroom` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `room_destroy_chatroom` | 有 | 有 | 已实现 | 已实现 | 已实现 | ✅ 一致 |
| `room_get_all_chat_rooms_removed` | 无 | 有 | 无公开 API | 删除残余路由 | - | ⚠️ 单端变更，按契约 defer |
| `room_fetch_from_server_fetch_members_removed` | 无 | 有 | 旧参数忽略 | 强制适配 | - | ⚠️ 单端变更，按契约 defer |
| `room_remove_chat_room_listener_removed` | 无 | 有 | 事件 API 不变 | 强制改用新名 | - | ⚠️ 单端变更，按契约 defer |
| `room_listener_on_member_joined_2arg_removed` | 无 | 有 | 事件 API 不变 | 强制清理旧回调 | - | ⚠️ 单端变更，按契约 defer |
| `room_listener_on_mute_list_added_removed` | 无 | 有 | 事件 API 不变 | 强制采用 Map 回调 | - | ⚠️ 单端变更，按契约 defer |
| `push_update_push_display_style_sync` | 有 | 无 | 公开 API 不变 | - | 强制改 completion | ⚠️ 单端变更，按契约 defer |
| `push_update_push_display_name_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `push_get_push_options_from_server_sync` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |
| `error_contact_add_faild_typo` | 有 | 无 | 未实施（defer） | - | - | ⚠️ 单端变更，按契约 defer |

统计：✅ 67 / ⚠️ 104 / ❌ 0，共 171 行。⚠️ 包含 102 个按规则 defer 的单端变更，以及 2 个仍保留明确跨端差异的 include 项；没有缺失的 include 项。

## 2. 未匹配清单

完整证据见 `01-api-diff.md §3`，共 37 条：

- iOS：`i1–i17`。
- Android：`a1–a10`。
- 跨端：`N1–N4`、`N6–N11`（N5 为旧统计问题，修复后移除）。
- 高影响项已冻结：group configs 位值逐端映射；Flutter 默认 `inviteNeedConfirm=false/ext=null`；`dataSyncType` 不设显式统一默认；database opened 的 error 在 Android 为 null；不存在的 `onReadReceiptForGroupMessageUpdated` 不实现。

## 3. 问题清单

1. ✅ group configs 默认值差异已关闭：RN 5.0.0 同样固定上层 `inviteNeedConfirm=false`、`ext` 可空；Flutter 保持 `false/null`，不依赖 native 默认。
2. ✅ Android `EMGroup` 没有 inviteNeedConfirm getter 的差异已关闭：RN 同样在字段缺失时回落上层默认 false；Flutter 当前输出 false，行为一致。
3. ✅ `dataSyncType` 默认值差异已关闭：复用 RN 5.0.0 已裁决方案，上层不设显式默认，遵循各端 native 默认。
4. ✅ iOS-only `totalCount` 已关闭：Dart 模型保留可空字段，Flutter iOS wrapper 已参考 RN 5.0.0 转发 native callback；真实回归确认零值返回 `0`，Android 保持 null。
5. ✅ Android 群回执分页无 groupId 已关闭：复用 RN 5.0.0 已裁决方案，统一 API 保留 groupId，Android 接收但不下传。
6. ✅ iOS APNs token 类型 warning 已关闭：用户决定接受基线现状，保留 `NSString *`→`NSData *` 调用，不修复。
7. ✅ CocoaPods 旧 lock 问题已关闭：按固定序列更新后构建通过，最终 lock 已锁定 5.0.0；RN 侧也已确认 CocoaPods/SPM 5.0.0 发布可用。
8. ⚠️ API 脚本真实模拟器回归仍有 native 待修项：当前 Android wrapper 在不存在消息分页路径会触发 native NPE；iOS 可见窗口运行 20/21 通过，唯一失败为同一输入返回成功空列表。两端群回执 happy path 均通过，未再出现 505。Android 临时 wrapper 判空曾验证 21/21，但该 Java 修改已按用户决定还原。
9. ✅ Android `fetchMembers` 重载差异已关闭：RN 5.0.0 同样保留上层参数、Android wrapper 忽略不下传；Flutter 当前行为一致。

## 4. 验证结论

- ✅ `flutter analyze`
- ✅ `flutter test`（30，含 `ChatCursorResult.totalCount` 双场景）
- ✅ example `flutter analyze` 与环境/5.0.0 脚本覆盖测试（12）
- ✅ Android debug APK
- ✅ iOS CocoaPods debug/no-codesign
- ✅ iOS SPM debug/no-codesign
- ✅ guard / contract checker / 旧 API grep / `git diff --check`
- ✅ Flutter 全局 SPM 开关恢复为 false
- ❌ Android auto 模式当前未完成：不存在消息分页触发 native NPE；临时 wrapper 判空的 21/21 结果不属于最终提交代码
- ⚠️ iOS auto 模式完成：20/21 通过，唯一失败为不存在消息分页返回成功空列表

## 5. RN 对照结论与剩余待用户决策

已直接复用 RN 5.0.0 的已裁决方案：

1. group configs 固定上层默认 `inviteNeedConfirm=false`、`ext` 可空。
2. `dataSyncType=null` 时不设统一默认，遵循双端 native 默认。
3. `ChatCursorResult.totalCount` 作为可空字段承接 iOS-only 返回值；Flutter iOS wrapper 已参考 RN 完成真实转发。
4. 群回执分页统一 API 保留 groupId，Android 接收但不下传。

用户决策（2026-09-17）：

1. iOS APNs token 基线 warning 不修复，保留现有 `NSString *`→`NSData *` 调用。
2. 已参考 RN 实现多集群 token 自动获取、默认/唯一集群激活、Git 忽略的 `env.dart`、私有化配置与脚本结构化引用迁移；`script_500_apis.json` 已由 5 步扩为 21 步并完成双端真实模拟器回归。

复验处理结果（2026-09-18）：

1. ⚠️ Android `fetchGroupMessageReadReceipts` 的临时 wrapper 判空已由用户还原；当前 native 5.0.0 对不存在消息仍会 NPE。用户决定由 Android native 修复崩溃，不在 Flutter wrapper 兜底。
2. ⚠️ iOS 对同一不存在 messageId 返回成功空列表。Android native 依赖本地消息推导 groupId，iOS native 直接接收 groupId；用户决定由 iOS/Android native 统一行为，Flutter 后续跟随 native 结论。
3. ✅ iOS wrapper 已转发群回执分页 `totalCount`；真实回归返回 `0`。
4. ⚠️ `sendMessageReadReceipts` / `getGroupMessageReadReceipts` 的不存在消息错误码仍为 Android 1、iOS 500。源码确认非法 ID 当前由 Flutter wrapper 在 native 调用前拦截；用户决定本轮不在 Flutter 统一，待 native 双端修复并明确一致契约后再调整 wrapper。
5. ✅ example 的 `loadAllConversations` 已输出结构化 `id/type/name/avatar`，真实双端结果可检查。
6. ✅ 群消息发送失败时，引用该步骤结果的后续步骤会直接标记 `blocked/skipped`，不再调用 SDK；覆盖测试通过。
7. ⏭️ `onMessageReadReceipts` 按用户决定暂不测试，不纳入本轮通过条件；后续如恢复验证，需要双账号协作场景。
8. ✅ 模拟器窗口问题已关闭：iOS Simulator 与窗口模式 Android Emulator 均成功置前；原不可见实例实际由其他流程以 `-no-window` 启动，并非窗口被隐藏。

## 6. 流程说明

按用户“整个任务只在 worktree 中进行”的约束，未修改元工作区 `docs/PROGRESS.md`；本报告即本次人类第二轮统一入口。基线平版、RN 对照修订、token/env 与脚本自动化已分别提交为 `dbab80b3`、`a2f27eff`、`6d16ce85`，均未 push；本地运行报告工具与本文档一并提交，原始证据与可协作问题台账位于被 Git 忽略的 `reports/5.0.0/`。
