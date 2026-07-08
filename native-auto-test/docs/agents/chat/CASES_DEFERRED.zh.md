# Chat 模块 Cases 暂缓清单（按 API）

— 说明
- 本文件仅记录暂缓实现、skip、环境阻塞项。
- 每条按 API 归类，并写明暂缓原因、前置条件、恢复条件。

## updateChatMessage
- 原因：`message` 对象入参，当前批次暂缓。
- 前置条件：message 对象构造与端侧语义稳定。
- 恢复条件：专项开启后补齐正常/异常并 strict 冻结。

## importMessages
- 原因：`message` 对象入参，当前批次暂缓。
- 前置条件：同上。
- 恢复条件：同上。

## modifyMessage
- 原因：端差异影响稳定性，暂缓。
- 前置条件：统一端差异语义。
- 恢复条件：冻结单一语义后恢复。

## translateMessage
- 原因：`message` 对象入参，暂缓。
- 前置条件：翻译链路语义稳定。
- 恢复条件：恢复实现并 strict。

## ackGroupMessageRead / asyncFetchGroupAcks
- 原因：群组语义链路，当前批次暂缓。
- 前置条件：群组专项启用。
- 恢复条件：按群组前置补齐。

## getThreadConversation
- 原因：thread 语义链路，当前批次暂缓。
- 前置条件：thread 专项启用。
- 恢复条件：恢复实现并 strict。

## resendMessage
- 原因：依赖失败消息前置构造，暂缓。
- 前置条件：可稳定构造失败消息。
- 恢复条件：补齐正常/异常链路。

## searchChatMsgFromDB
- 原因：历史存在 MissingPlugin 风险。
- 前置条件：桥接能力稳定。
- 恢复条件：移除 skip 并 strict。

## fetchSupportLanguages
- 原因：`result` 为超长语言列表；近期执行出现登录偶发超时。
- 前置条件：环境登录稳定。
- 恢复条件：一次性冻结完整 strict 断言。

## 已标记 skip（关联 API）
- `downloadAttachment.invalid_id`、`downloadThumbnail.invalid_id`
  - 文件：`tests/chat/test_chat_crud.py`
  - 原因：`message` 对象入参 + MissingPlugin 风险。
- `removeMessagesFromServerWithMsgIds`（缺失必填）、`removeMessagesFromServerWithTs`（缺失必填）、`reportMessage`（缺失必填）
  - 文件：`tests/chat/test_chat_s2_server_ops.py`
  - 原因：当前端缺失必填路径可能返回 MissingPlugin（非被测端语义）。

## 当前环境阻塞
- `tests/chat/test_chat_s3_non_message_ops.py::test_chat_pin_conversation_success_toggle`
  - 原因：当前 Android 实测对有效会话调用 `pinConversation` 持续返回 `303/concurrent operation are not allowed`，无法验证置顶/取消置顶成功状态切换；该返回记录为当前环境阻塞，不作为成功语义。
  - 前置条件：SDK/服务端确认并允许有效会话置顶操作完成。
  - 恢复条件：去掉 xfail，按真实成功返回和 `getConversation.isPinned` 状态收紧 strict 断言。
- `tests/chat/test_chat_s4_thread_user_removed.py::test_chat_thread_user_removed_event_type_not_null`
  - 原因：当前 Android 实测 `removeMemberFromChatThread` 返回 `result=true` 后，B/A 均未收到 `onUserKickOutOfChatThread`，无法验证发版项“event.type 非空”。
  - 前置条件：SDK/服务端确认并稳定派发 `onUserKickOutOfChatThread`。
  - 恢复条件：去掉 xfail，按真实事件体收紧 `event.type/from/thread` 断言并严格回归。
- `tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_delete_local_and_server_messages_by_time_bridge_missing`
  - 原因：当前 Android direct cmd `conversationDeleteServerMessageWithTime` 返回 `MissingPluginException`，属于桥接缺口，不作为 SDK 业务预期。
  - 前置条件：桥接/native method 补齐。
  - 恢复条件：按补齐后的真实返回重新 discovery，并改为 strict 断言。
