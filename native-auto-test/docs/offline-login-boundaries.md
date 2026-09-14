# Offline operation to login audit

All entries below use login_preserving_offline_events: peer operation/assertions -> settle.offline (3s default) -> login -> startCallback -> settle.offline. No post-login drain. A pause is not proof of server persistence.

Direct login review: Client offline sync already has a pre-login pause; Contact friend-info sync now has before/after pauses. Other direct paths are fixture setup/retry/teardown, final cleanup, invalid-password testing and _switch_user account-role setup, not recipient offline-operation replay. Their existing semantics are retained.

| File | Scenario | Login helper line |
|---|---|---:|
| `tests/contact/test_contact_offline_friendship.py` | `_prepare_offline_invitation` | 167 |
| `tests/contact/test_contact_offline_friendship.py` | `test_contact_offline_requester_receives_accept_after_relogin` | 453 |
| `tests/contact/test_contact_offline_friendship.py` | `test_contact_offline_requester_receives_decline_after_relogin` | 516 |
| `tests/contact/test_contact_offline_friendship.py` | `test_contact_offline_recipient_receives_delete_after_relogin` | 577 |
| `tests/contact/test_contact_offline_friendship.py` | `test_contact_offline_requester_receives_peer_delete_after_relogin` | 638 |
| `tests/chat/test_chat_offline_message_extended_operations.py` | `test_chat_offline_typed_message_read_after_sender_relogin` | 451 |
| `tests/chat/test_chat_offline_message_extended_operations.py` | `test_chat_offline_typed_message_recall_after_recipient_relogin` | 517 |
| `tests/chat/test_chat_offline_message_extended_operations.py` | `test_chat_offline_combine_message_read_after_sender_relogin` | 590 |
| `tests/chat/test_chat_offline_message_extended_operations.py` | `test_chat_offline_combine_message_recall_after_recipient_relogin` | 639 |
| `tests/chat/test_chat_offline_message_extended_operations.py` | `test_chat_offline_custom_body_modified_after_recipient_relogin` | 749 |
| `tests/chat/test_chat_offline_message_extended_operations.py` | `test_chat_offline_media_attributes_modified_after_recipient_relogin` | 895 |
| `tests/chat/test_chat_offline_message_extended_operations.py` | `test_chat_offline_text_recalled_before_first_recipient_login` | 1000 |
| `tests/chat/test_chat_offline_message_extended_operations.py` | `test_chat_offline_text_modified_before_first_recipient_login` | 1088 |
| `tests/chat/test_chat_offline_message_delivery.py` | `test_chat_offline_text_message_received_after_login` | 472 |
| `tests/chat/test_chat_offline_message_delivery.py` | `test_chat_offline_media_message_received_after_login` | 531 |
| `tests/chat/test_chat_offline_message_delivery.py` | `test_chat_offline_location_message_received_after_login` | 593 |
| `tests/chat/test_chat_offline_message_delivery.py` | `test_chat_offline_custom_message_received_after_login` | 646 |
| `tests/chat/test_chat_offline_message_delivery.py` | `test_chat_offline_combine_message_received_after_login` | 749 |
| `tests/chat/test_chat_offline_message_delivery.py` | `test_chat_offline_cmd_message_received_after_login` | 808 |
| `tests/chat/test_chat_offline_message_delivery.py` | `test_chat_offline_deliver_online_only_not_received_after_login` | 860 |
| `tests/chat/test_chat_offline_message_delivery.py` | `test_chat_offline_multiple_text_messages_and_unread_count` | 921 |
| `tests/chat/test_chat_offline_message_delivery.py` | `test_chat_offline_delivery_ack_after_recipient_login` | 1044 |
| `tests/chat/test_chat_offline_message_extended_delivery.py` | `test_chat_offline_typed_delivery_ack_after_recipient_login` | 321 |
| `tests/chat/test_chat_offline_message_extended_delivery.py` | `test_chat_offline_received_media_downloads_after_recipient_login` | 381 |
| `tests/chat/test_chat_offline_message_extended_delivery.py` | `test_chat_offline_combine_delivery_ack_after_recipient_login` | 556 |
| `tests/chat/test_chat_offline_message_extended_delivery.py` | `test_chat_offline_text_automatic_translation_after_recipient_login` | 630 |
| `tests/chat/test_chat_offline_message_extended_delivery.py` | `test_chat_offline_mixed_backlog_local_state_after_recipient_login` | 824 |
| `tests/chat/test_chat_offline_message_operations.py` | `test_chat_offline_sender_receives_message_read_after_relogin` | 466 |
| `tests/chat/test_chat_offline_message_operations.py` | `test_chat_offline_recipient_receives_recall_after_relogin` | 550 |
| `tests/chat/test_chat_offline_message_operations.py` | `test_chat_offline_recipient_receives_content_change_after_relogin` | 690 |
| `tests/chat/test_chat_offline_message_operations.py` | `test_chat_offline_sender_receives_conversation_read_after_relogin` | 802 |
| `tests/chat/test_chat_offline_message_operations.py` | `test_chat_offline_sender_receives_reaction_add_after_relogin` | 863 |
| `tests/chat/test_chat_offline_message_operations.py` | `test_chat_offline_sender_receives_reaction_remove_after_relogin` | 974 |
| `tests/chat/test_chat_offline_message_operations.py` | `test_chat_offline_recipient_receives_message_pin_after_relogin` | 1052 |
| `tests/chat/test_chat_offline_message_operations.py` | `test_chat_offline_recipient_receives_message_unpin_after_relogin` | 1175 |
| `tests/group/test_group_offline_message_delivery.py` | `test_group_offline_text_message_received_after_login` | 340 |
| `tests/group/test_group_offline_message_delivery.py` | `test_group_offline_multiple_text_messages_and_conversation_state` | 406 |
| `tests/group/test_group_offline_message_delivery.py` | `test_group_offline_cmd_deliver_online_only_not_received_after_login` | 582 |
| `tests/group/test_group_offline_message_delivery.py` | `test_group_offline_sender_reads_ack_count_after_relogin` | 742 |
| `tests/group/test_group_offline_message_delivery.py` | `test_group_offline_message_recalled_before_first_recipient_login` | 831 |
| `tests/group/test_group_offline_message_delivery.py` | `test_group_offline_recipient_receives_recall_after_relogin` | 946 |
| `tests/group/test_group_offline_message_delivery.py` | `test_group_offline_recipient_receives_content_change_after_relogin` | 1099 |
| `tests/group/test_group_offline_invitation_application.py` | `test_group_offline_invitation_received_and_processed_after_login` | 145 |
| `tests/group/test_group_offline_invitation_application.py` | `test_group_offline_owner_receives_invitation_result_after_relogin` | 360 |
| `tests/group/test_group_offline_invitation_application.py` | `test_group_offline_owner_receives_join_application_and_processes_after_login` | 436 |
| `tests/group/test_group_offline_invitation_application.py` | `test_group_offline_applicant_receives_application_result_after_relogin` | 615 |
| `tests/group/test_group_offline_roles_and_configuration.py` | `_relogin_b` | 86 |
| `tests/group/test_group_offline_roles_and_configuration.py` | `test_group_offline_member_attributes_final_state` | 955 |
| `tests/group/test_group_offline_member_state.py` | `test_group_offline_member_removed_state_after_login` | 195 |
| `tests/group/test_group_offline_member_state.py` | `test_group_offline_member_blocked_state_after_login` | 263 |
| `tests/group/test_group_offline_member_state.py` | `test_group_offline_group_destroyed_state_after_login` | 348 |
| `tests/group/test_group_offline_member_state.py` | `test_group_offline_member_leave_state_persists_after_relogin` | 407 |
