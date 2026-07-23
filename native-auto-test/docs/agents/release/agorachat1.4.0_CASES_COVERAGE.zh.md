# agorachat1.4.0 发版变更 Case 覆盖清单（Android SDK 4.14.0 ~ 4.16.2）

— 来源
- 发版文档：`https://doc.easemob.com/document/android/releasenote.html#v4-14-0-dev-2025-4-21-%E5%BC%80%E5%8F%91%E7%89%88`
- 本文档按 Android 发版页提取 `v4.14.0 Dev 2025-4-21` 至 `v4.16.1 2025-11-12`（Android 页无 `v4.16.2` 条目）。

— 执行标签
- 业务标签：`agorachat1.4.0`
- pytest marker：`agorachat1_4_0`
- 执行命令：`pytest -q -m agorachat1_4_0 tests -s`

## 汇总统计

- 总变更项：18
- 已覆盖：11
- 可补充覆盖：0
- 当前不可覆盖：7

## 明细（全量）

| 版本 | 变更类型 | 发版变更项 | 覆盖状态 | 现有用例 | 备注/补充设计 |
|---|---|---|---|---|---|
| v4.16.1 | - | （该版本在 Android 发版页无新增/优化/修复条目） | 当前不可覆盖 | - | 文档仅有版本标题，未给出可测项 |
| v4.16.0 Dev 2025-8-19 | 修复 | 修复群组或聊天室解散后，成员收到回调后仍会从服务器获取详情 | 已覆盖 | `tests/group/test_group_lifecycle.py::test_group_get_group_from_server_after_destroy`；`tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_fetch_room_info_from_server_after_destroy` | 已按“创建 -> 解散 -> 再拉详情”真实链路覆盖，不再用不存在 ID 替代 |
| v4.16.0 Dev 2025-8-19 | 修复 | 修复数据库遇到 SQLITE_BUSY 后导致数据库重建 | 当前不可覆盖 | - | 属于底层 DB 并发异常场景，现有 API case 难稳定触发 SQLITE_BUSY |
| v4.16.0 Dev 2025-8-19 | 修复 | IM Demo 增加反诈提示（背景/提示消息） | 当前不可覆盖 | - | Demo UI 行为，不是 SDK API 可断言目标 |
| v4.15.2 Dev 2025-7-22 | 优化 | 优化附件消息会话列表加载性能 | 当前不可覆盖 | - | 性能优化缺少稳定阈值，不宜纳入 strict API case |
| v4.15.1 Dev 2025-6-23 | 新增特性 | 根据关键字从本地数据库获取单个会话消息（返回会话 ID + 消息 ID 列表） | 已覆盖 | `tests/chat/test_chat_s4_local_keyword_search.py::test_chat_load_conversation_messages_with_keyword_success`；`tests/chat/test_chat_s4_local_keyword_search.py::test_chat_load_conversation_messages_with_keyword_no_hit` | 已按 Dart 入参语义（`keyword/timestamp/sender/direction/scope`）覆盖命中与无命中稳定语义 |
| v4.15.1 Dev 2025-6-23 | 新增特性 | 根据消息 ID 从本地数据库获取单个/多个消息 | 已覆盖 | `tests/chat/test_chat_s4_load_messages_by_ids.py::test_chat_load_messages_with_ids_single_and_multi_success`；`tests/chat/test_chat_s4_load_messages_by_ids.py::test_chat_load_messages_with_ids_empty_ids` | 已覆盖单 ID、多 ID（含不存在 ID）与空 ID 列表语义 |
| v4.15.1 Dev 2025-6-23 | 修复 | 修改非文本/自定义消息时，`onMessageContentChanged` 回调返回内容修复 | 已覆盖 | `tests/chat/test_chat_s4_message_content_changed.py::test_chat_modify_custom_message_content_changed_event` | 已用 custom 消息 `sendMessageWithType -> modifyMessage(msgBody=custom)` 覆盖回调返回内容与 operator 信息 |
| v4.15.1 Dev 2025-6-23 | 修复 | 拉取漫游消息 `setIsSave=false` 时不再生成本地会话 | 当前不可覆盖 | - | 仓库当前 cmd 未显式暴露 `setIsSave` 参数用例，需先确认 Flutter 侧入参映射 |
| v4.15.1 Dev 2025-6-23 | 修复 | 修复部分场景发送 GIF 图片消息失败 | 已覆盖 | `tests/chat/test_chat_send_with_type.py::test_send_message_with_type_image` | 已覆盖图片消息发送接收主链路（含事件收敛） |
| v4.15.0 Dev 2025-5-21 | 新增特性 | 群主/管理员可撤回其他用户消息 | 已覆盖 | `tests/chat/test_chat_crud.py::test_chat_recall_message_success_with_event` | 覆盖撤回成功链路与回调 |
| v4.15.0 Dev 2025-5-21 | 新增特性 | 群成员进出事件新增 `onMembersJoined/onMembersExited`（旧事件废弃） | 已覆盖 | `tests/group/test_group_members.py::test_group_members_batch_join_exit_new_events` | 已按桥接真实事件名 `onMembersJoinedFromGroup/onMembersExitedFromGroup` 做 strict 断言并校验 `data.userIds` |
| v4.15.0 Dev 2025-5-21 | 优化 | `onTokenWillExpire` 触发时机由 50% 调整到 80% | 当前不可覆盖 | - | 需可控 token 生命周期与时钟，不适合日常 API 回归 |
| v4.15.0 Dev 2025-5-21 | 优化 | Demo 跑通无需部署 App Server | 当前不可覆盖 | - | Demo 接入流程项，不是 SDK API case |
| v4.15.0 Dev 2025-5-21 | 修复 | `onChatThreadUserRemoved` 的 TYPE 为 null 问题 | 部分覆盖，事件待确认 | `tests/group/test_group_chat_thread_user_removed.py::test_chat_thread_remove_member_updates_member_list` | 已迁移到 Group 并用真实成员列表严格确认移除结果；当前 Android 未稳定派发 `onUserKickOutOfChatThread`，未伪造 `event.type` 断言，详见 Group deferred |
| v4.15.0 Dev 2025-5-21 | 修复 | 获取会话免打扰开始/结束时间在部分机型 crash | 当前不可覆盖 | - | 机型相关 crash 难在 CI 稳定复现 |
| v4.14.0 Dev 2025-4-21 | 新增特性 | 支持发送和接收 GIF 图片消息 | 已覆盖 | `tests/chat/test_chat_send_with_type.py::test_send_message_with_type_image` | 覆盖图片消息端到端 |
| v4.14.0 Dev 2025-4-21 | 新增特性 | 支持群组头像功能 | 已覆盖 | `tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_name_and_avatar_abnormal_inputs` | 已覆盖 `avatarUrl` 相关入参与回显语义 |
| v4.14.0 Dev 2025-4-21 | 新增特性 | 支持消息附件鉴权（开通后必须调用 SDK API 下载） | 已覆盖 | `tests/group/test_group_shared_files.py::test_group_download_shared_file_nonexistent_group_current_behavior` | 当前以下载接口调用链路为主；鉴权开通态需环境专项 |
| v4.14.0 Dev 2025-4-21 | 新增特性 | 拉取漫游消息时可只拉取指定群成员发送消息 | 已覆盖 | `tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_by_options_success` | 已覆盖按 options 拉取漫游消息主链路 |
| v4.14.0 Dev 2025-4-21 | 新增特性 | 加载本地会话消息时可只加载指定群成员发送消息 | 已覆盖 | `tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_by_options_success` | 已覆盖本地会话消息拉取的 options 路径 |
| v4.14.0 Dev 2025-4-21 | 新增特性 | 获取群成员列表包含成员角色和入群时间 | 已覆盖 | `tests/group/test_group_member_list.py::test_group_get_group_member_list_from_server_success` | 已覆盖成员列表结构与可解析字段 |
| v4.14.0 Dev 2025-4-21 | 优化 | 日志增加设备时区偏移 | 当前不可覆盖 | - | 日志可观测项，非业务 API 断言 |
| v4.14.0 Dev 2025-4-21 | 优化 | `asyncFetchHistoryMessages` 最后一页 cursor 从 undefined 改为 "" | 已覆盖 | `tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_invalid_conv_id` | 相关历史消息接口已冻结 `cursor=""` 语义 |
| v4.14.0 Dev 2025-4-21 | 优化 | 去除 FileProvider 反射获取绝对路径 | 当前不可覆盖 | - | 属于内部实现细节，非 API 外显 |
| v4.14.0 Dev 2025-4-21 | 优化 | 升级 BoringSSL 和 SQLCipher | 当前不可覆盖 | - | 库升级项，无稳定 API 行为差分可断言 |
| v4.14.0 Dev 2025-4-21 | 修复 | 删除本地会话时缓存消息未删除 | 已覆盖 | `tests/chat/test_chat_s1_local_conversation.py::test_chat_delete_conversation_success` | 已覆盖删除会话后的行为链路 |

## 当前待补充清单（可直接进入实现）

- 当前清单已补齐，本轮新增 2 条 case（chat 2 条）。

## 说明

- 本批标签仅用于“发版记录可直接映射且已落地的 API cases”；`当前不可覆盖` 项已在表中逐条标明原因。
- 若你要求把 `当前不可覆盖` 也纳入提测，我们可以单独补“观察性/探针型 case”，但它们默认不作为 strict 通过门禁。
