# 多端多设备 Case 改造清单

> 本文件是现有 case 的多端改造台账。每完成一项，必须将 `[ ]` 改为 `[x]`，并写入实际回归结果；环境或契约未确认的项用 `[-]`，不能假装已覆盖。

## 范围和统一规则

- 当前场景：`config/scenarios/android_423_multi_device_default.yaml`。
- 当前设备：账号 A 登录 `device_a`、`device_a_sec`；账号 B 登录 `device_b`。
- 已有拓扑：
  - `account_b_to_account_a`：B 动作，A 的所有在线端是接收端。
  - 后续 reaction 等“B 动作、A 所有端收回调”的 case 可直接使用该拓扑。
  - 需要 A 发给 B 的 case，新增**同一 scenario 内**的反向拓扑 `account_a_to_account_b`；不新增模拟器，不新增 scenario 文件。
- 多端消息主链路：发送成功 → A 每个在线端收到消息 → 发送端收到与 A 在线端数量一致的送达记录。
- `onMessagesDelivered.data.messages` 中，同一 `msgId` 会按接收在线端重复：A 有 2 个在线端时必须严格断言 2 条，而不是只保留第一条。
- 纯查询、分页、无效参数、设备级设置和本地数据库 case 不改成多端 case。
- `sendMessageWithType` 不是当前原生 Wrapper cmd；涉及它的 case 必须先改为原生 `ChatManager.sendMessage` + 原生 body JSON，不能只加 topology marker。

## 当前完成项

### Chat

- [x] `tests/chat/test_chat_crud.py::test_chat_send_and_received`
  - 四 Android：A 主端发送；A 副端收到出站同步回调并可查库；B 主/副端均收到入站消息并可查库；A 主端严格断言 2 条送达记录。
  - 回归：Android 4.23 四端实机通过。
- [x] `tests/chat/test_chat_crud.py::test_chat_translate_message_recalled_message`
  - B 发文本；A 两端均收到原消息、撤回信息和撤回消息；送达记录按 2 个接收端断言。
- [x] `tests/chat/test_chat_crud.py::test_chat_ack_message_read_success`
  - B 发消息；A 两端收到；A 主端发已读回执；B 收到已读事件；送达记录按 2 个接收端断言。
- [x] `tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_custom_message_send_receive`
  - B 用原生 `sendMessage` 发送 custom body；A 两端均收到。Android 4.23 实机通过。
- [x] `tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_location_message_send_receive`
  - B 用原生 `sendMessage` 发送 location body；A 两端均收到。Android 4.23 实机通过。
- [x] `tests/chat/test_chat_text_boundaries_and_location_delivery.py::test_chat_text_content_boundaries[*]`
  - 空文本、特殊字符、250 字符均改为 B → A 两端；严格验证 2 条同一 `msgId` 的送达记录。
  - 回归：`3 passed`（empty / special-characters / length-250）。

### Group

- [x] `tests/group/test_group_message_send.py::test_group_message_fetch_acks_success`
  - A 建群并邀请 B；B 发需群回执消息；A 两端收到；A 主端回执；B 查询群回执。

### Phase1 / 基础设施

- [x] `tests/phase1/test_multi_device.py::test_same_account_second_device_sees_user_info_update`
  - 同账号第二端读取到用户资料最终值。
- [x] `tests/phase1/test_multi_device.py::test_third_party_message_reaches_both_same_account_devices`
  - 第三方发送的消息抵达同账号两个在线端。

### Web 浏览器 Runner

- [x] Web 5.0 基础接入
  - 独立 `web_runner/` 使用官方 `im-sdk-web.iife.js`，不经过 Flutter MethodChannel。
  - Web 5.0 IIFE 固定存放在 `im_flutter_sdk_web/vendor/base500/`；构建产物按 `sdk500` 分目录。
  - 公共协议按 Android 命名，Web 独有 API 使用官方 Web 5.0 方法名。
  - `WebBrowserDevice` 为每个 Web role 启动隔离 Chrome profile，并通过 managed WebSocket 注册为 Runner。
  - 独立 `config/api_matrix/web.yaml` 仅声明已适配的 Web API；不继承 Android/iOS 基线。
  - 新场景：`config/scenarios/web_500_multi_device_default.yaml`；旧的 4.23 场景保留兼容。
- [x] 五端业务回归
  - `test_chat_send_and_received`：Android + iOS + Web strict 通过；B Android、B iOS、B Web 均收到并可查询同一消息，A 收到 3 条送达回执。
  - `test_chat_reaction_change_event_received_by_sender`：Android + iOS + Web strict 通过；三端接收账号均收到自身 reaction 变更事件。

## 待改：Chat

### P0：直接验证多端事件派发

- [x] `tests/chat/test_chat_reaction_fetch.py::test_chat_reaction_change_event_received_by_sender`
  - A 发消息给 B；B 添加 reaction；A 主端和副端均断言 `messageReactionDidChange`；B 断言自己的事件。
  - 已在同一 YAML 增加 `account_a_to_account_b` 反向拓扑，并启用 `sender.include_all_devices=true`；Android 4.23 三端实机通过。
- [ ] `tests/chat/test_chat_s423_message_callback_and_combine.py::test_send_text_message_with_webhook_env`
  - B 发带 `webhookEnv` 的原生文本；A 两端均收到并严格断言 `webhookEnv`。
  - 前置：确认原生 message JSON 的 `webhookEnv` 字段与当前 Wrapper 透传一致。

### P1：已有消息投递 case，需改为原生 body 后再拓扑化

- [ ] `tests/chat/test_chat_send_with_type.py::test_send_message_with_type_text_basic`
- [ ] `tests/chat/test_chat_send_with_type.py::test_send_message_with_type_text_with_languages`
  - 原因：当前调用不存在的 `sendMessageWithType` cmd；改为 `sendMessage` 文本 body 后，B → A 两端收消息与双送达记录。
- [ ] `tests/chat/test_chat_send_with_type.py::test_send_message_with_type_file`
- [ ] `tests/chat/test_chat_send_with_type.py::test_send_message_with_type_image`
- [ ] `tests/chat/test_chat_send_with_type.py::test_send_message_with_type_image_heic`
- [ ] `tests/chat/test_chat_send_with_type.py::test_send_message_with_type_video`
- [ ] `tests/chat/test_chat_s423_message_callback_and_combine.py::test_attachment_messages_send_receive_and_public_download_methods`
  - 原因：媒体 body 和测试 App assets 需要原生 JSON builder；完成后统一做 B → A 两端接收。
- [ ] `tests/chat/test_chat_s423_message_callback_and_combine.py::test_combine_forward_send_receive_and_inner_attachment_download`
- [ ] `tests/chat/test_chat_s423_message_callback_and_combine.py::test_combine_forward_media_inner_attachment_download`
  - 原因：需要先确认 combine body 的原生 JSON 契约。

### P1：多端语义已有覆盖，但需要去重或合并

- [ ] `tests/chat/test_chat_ack_read_strict.py::test_chat_ack_message_read_success_with_event`
  - 与已完成的 `test_chat_ack_message_read_success` 重复；决定合并、删除，或改成不同的边界语义，不能再维护两份同一主链路。
- [ ] `tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_recall_message_receiver_recalled_info_event`
  - 与已完成的多端撤回链路重叠；保留时必须改为不同的 API/边界验收目标，否则合并。

### 暂缓 / 先确认

- [-] `tests/chat/test_chat_s4_message_content_changed.py::test_chat_modify_custom_message_content_changed_event`
  - 已完成多端结构改造；当前真实服务端返回 `305 / Sorry, edit is not available`，消息编辑能力开启后再验证 `onMessageContentChanged` 的 A 两端派发。
- [-] `tests/chat/test_chat_send_with_type.py::test_send_message_with_type_cmd_received_by_cmd_callback`
  - 当前 CMD 接收语义与 `onMessagesDelivered` 不一致；先冻结原生 SDK 对 CMD delivery receipt 的契约。
- [-] `tests/chat/test_chat_message_modification_matrix.py` 中的 cmd/media 修改链路
  - 先补原生 cmd/media body，并解决 `modifyMessage=305` 环境能力。

## 待改：Group

### P1：群消息接收端多端

- [ ] `tests/group/test_group_message_send.py::test_group_message_send_receive_by_type[*]`
  - B 在同一群发各类型消息；A 两端均收到。先补群消息原生 typed body builder（`chatType=1`）。
- [ ] `tests/group/test_group_message_send.py::test_group_message_send_receive_combine`
  - 同上；先确认 combine body 契约。

### P2：群事件是否向同账号所有端派发，先逐项冻结

- [-] `tests/group/test_group_chat_thread_user_removed.py::test_chat_thread_remove_member_updates_member_list`
- [-] `tests/group/test_group_chat_thread_remaining_api_coverage.py::test_chat_thread_destroy_event_received_by_group_member`
- [-] `tests/group/test_group_join_requests_and_invitations.py::test_group_request_to_join_and_accept_success`
- [-] `tests/group/test_group_join_requests_and_invitations.py::test_group_request_to_join_and_decline_success`
- [-] `tests/group/test_group_invitation_state_matrix.py::*`
- [-] `tests/group/test_group_member_attributes*.py::*`
- [-] `tests/group/test_group_moderation.py::*`
- [-] `tests/group/test_group_roles.py::*`
  - 原因：群事件接收者由 owner/admin/member 身份决定；先确认“通知哪个账号”，再将该账号的所有在线端纳入断言。

## 待改：Contact

- [ ] `tests/contact/test_contact.py::test_friend_add_accept_and_list`
  - 邀请、接受后，通知目标账号的 A 主端和副端都验证好友事件或严格最终好友列表。
- [ ] `tests/contact/test_contact.py::test_friend_add_decline_and_verify_not_friends`
  - 拒绝后，邀请方 A 两端都验证拒绝事件或严格最终无好友关系。
- [ ] `tests/contact/test_contact.py::test_contact_remark_set_success`
- [ ] `tests/contact/test_contact.py::test_contact_remark_not_preserved_after_delete_and_readd`
  - 仅在原生事件确实会跨同账号端同步时改；否则保留为服务端最终态双端读取验证。
- [-] `tests/contact/test_friend_info_sync.py::*`
  - 已知重新登录同步回调不稳定；先恢复 `onFriendStartSync/onFriendSyncFinished` 的稳定实测，再做多端回调断言。

## 待改：Chatroom

以下均属于回调 case；是否承诺同账号多端派发尚未冻结，先做一条 discovery 后再逐项改为 A 两端事件断言。

- [-] `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_admin_added_and_removed_callbacks`
- [-] `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_owner_changed_callback`
- [-] `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_all_member_mute_state_callbacks`
- [-] `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_attributes_updated_and_removed_callbacks`
- [-] `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_announcement_changed_callback`
- [-] `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_specification_changed_callback`
- [-] `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_allow_list_added_and_removed_callbacks`
- [-] `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_mute_list_added_and_removed_callbacks`
- [-] `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_member_exited_callback`
- [-] `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_removed_and_destroyed_callbacks`

## 不需要改为多端的模块 / case 类型

- UserInfo：已有 Phase1 跨端同步冒烟；其余更新、查询、长度边界不改。
- Presence、Push、Client：设备级配置、生命周期或纯 API 返回，不以同账号多端事件为验收目标。
- Framework：框架测试不掺入业务拓扑。
- Chat / Group / Contact 中的纯查询、分页、搜索、下载、无效参数和本地 CRUD：保持原样。

## 每次改造的完成条件

1. 使用 topology，不在 case 内硬编码 `deviceA/deviceB`。
2. 对目标账号每个在线端分别等待并断言事件；事件以同一 `msgId` 或业务 ID 关联。
3. 若断言送达：同一 `msgId` 的送达记录数严格等于接收端数量。
4. Allure 步骤写出动作端、每个接收端和业务结果；失败步骤必须显示实际失败业务。
5. 只回归受影响 case；结果填回本文件及对应模块的 `CASES_RECORD.zh.md` / `CASES_DEFERRED.zh.md`。
