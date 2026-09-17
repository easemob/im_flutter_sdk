# Flutter 5.0.0 平版验收报告

- 工作目录：`/Users/asterisk/Codes/zuoyu_flutter/im_flutter_sdk/.worktree/5.0.0`
- 分支：`5.0.0`
- 源版本：iOS `4.24.1 → 5.0.0`；Android `SDK_4.24.1 → SDK_5.0.0`
- 目标版本：Flutter `5.0.0`
- 完整源签名与 decision：[`01-api-diff.md`](./01-api-diff.md)
- 契约：[`02-contract.md`](./02-contract.md)
- 实现与验证：[`03-implementation.md`](./03-implementation.md)、[`04-verification.md`](./04-verification.md)
- 代码状态：**未提交**

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
| `options_data_sync_type_enum` | 有 | 有 | 已实现 | 已实现 | 已实现 | ⚠️ 已实现，跨端差异见问题清单 |
| `options_data_sync_type` | 有 | 有 | 已实现 | 已实现 | 已实现 | ⚠️ 已实现，跨端差异见问题清单 |
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
| `chat_fetch_group_message_read_receipts` | 有 | 有 | 已实现 | 已实现 | 已实现 | ⚠️ 已实现，跨端差异见问题清单 |
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
| `group_configs_type` | 有 | 有 | 已实现 | 已实现 | 已实现 | ⚠️ 已实现，跨端差异见问题清单 |
| `group_configs_type_enum` | 有 | 有 | 已实现 | 已实现 | 已实现 | ⚠️ 已实现，跨端差异见问题清单 |
| `group_create_group` | 有 | 有 | 已实现 | 已实现 | 已实现 | ⚠️ 已实现，跨端差异见问题清单 |
| `group_create_group_with_avatar` | 有 | 有 | 已实现 | 已实现 | 已实现 | ⚠️ 已实现，跨端差异见问题清单 |
| `group_update_group_configs` | 有 | 有 | 已实现 | 已实现 | 已实现 | ⚠️ 已实现，跨端差异见问题清单 |
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

统计：✅ 59 / ⚠️ 112 / ❌ 0，共 171 行。⚠️ 包含 102 个按规则 defer 的单端变更，以及已实现但存在明确跨端差异的 include 项；没有缺失的 include 项。

## 2. 未匹配清单

完整证据见 `01-api-diff.md §3`，共 37 条：

- iOS：`i1–i17`。
- Android：`a1–a10`。
- 跨端：`N1–N4`、`N6–N11`（N5 为旧统计问题，修复后移除）。
- 高影响项已冻结：group configs 位值逐端映射；Flutter 默认 `inviteNeedConfirm=false/ext=null`；`dataSyncType` 不设显式统一默认；database opened 的 error 在 Android 为 null；不存在的 `onReadReceiptForGroupMessageUpdated` 不实现。

## 3. 问题清单

1. ⚠️ native 的 group configs 默认值不一致：iOS invite confirm 默认 YES/ext 空串，Android 为 false/null；Flutter 固定 false/null 延续既有 Dart 行为，wrapper 显式赋值。
2. ⚠️ Android `EMGroup` 没有 inviteNeedConfirm getter，读取 `ChatGroup.configs` 时只能输出冻结默认 false。
3. ⚠️ `dataSyncType` 未传时 iOS 默认 conversations、Android 默认 none；Flutter 保留 native 默认差异。
4. ⚠️ iOS 群消息回执分页返回 `totalCount`，Android 不返回；当前沿用 `ChatCursorResult`，不新增 totalCount 字段。
5. ⚠️ Android 群回执分页 native API 没有 groupId 参数；Flutter 为跨端统一仍接收 groupId，Android wrapper 校验读取后不下传。
6. ⚠️ iOS `PushManagerWrapper.m` 存在基线已有的 APNs token NSString→NSData 编译 warning，不阻断构建，本次未扩范围。
7. ⚠️ CocoaPods 首构建受旧 lock 阻断，按固定序列更新后通过；最终 lock 已锁定 5.0.0。
8. ⏭️ API 脚本未实机运行：现有私有 config 仅有 password，无 5.0 必需的 loginToken；已提供 `script_500_apis.json`。
9. ⚠️ Android/群组与聊天室 native 删除 fetchMembers 重载，Flutter 旧 fetchMembers 参数保留但 wrapper 忽略。

## 4. 验证结论

- ✅ `flutter analyze`
- ✅ `flutter test`（28）
- ✅ Android debug APK
- ✅ iOS CocoaPods debug/no-codesign
- ✅ iOS SPM debug/no-codesign
- ✅ guard / contract checker / 旧 API grep / `git diff --check`
- ✅ Flutter 全局 SPM 开关恢复为 false

## 5. 待用户决策

1. 是否接受 Flutter 将 group configs 缺省固定为 `inviteNeedConfirm=false/ext=null`，以延续 4.x Dart 行为。
2. 是否接受 `dataSyncType=null` 时保留双端 native 默认差异；若要完全一致，后续需指定统一默认。
3. 是否需要扩展 `ChatCursorResult` 暴露 iOS-only `totalCount`；当前未为单端信息新增字段。
4. 是否单独修复 iOS APNs token 基线 warning。
5. 提供可用 loginToken 后，是否补跑 `script_500_apis.json` 的双端功能回归。

## 6. 流程说明

按用户“整个任务只在 worktree 中进行”的约束，未修改元工作区 `docs/PROGRESS.md`；本报告即本次人类第二轮统一入口。未执行 `git add`、`git commit` 或 push。

