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

## translateMessage
- 已覆盖：空语言、不支持语言、自定义消息、支持语言列表结构，以及带 `targetLanguages` 的自动翻译发送/接收结果。
- 自动翻译现状：当前 AppKey 已开启该能力；发送方和接收方均返回 `targetLanguages=[zh-Hans]` 及非空 `translations`，旧环境 `1113 Failed to translate the message` 不再作为预期。
- 未覆盖：显式调用 `translateMessage` 后得到非空正常翻译结果。
- 当前现象：`test_chat_translate_message_basic` 的显式调用仍返回空 `translations`；由于同一环境自动翻译已成功，不能继续笼统归因于 AppKey 总翻译开关未开启。
- 恢复条件：单独确认显式翻译接口的消息状态、源/目标语言和服务配置后，采集真实非空结果并收紧 strict 断言。

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

## 已标记 skip（关联 API）
- `downloadAttachment.invalid_id`、`downloadThumbnail.invalid_id`
  - 文件：`tests/chat/test_chat_crud.py`
  - 原因：`message` 对象入参 + MissingPlugin 风险。
- `removeMessagesFromServerWithMsgIds`（缺失必填）、`removeMessagesFromServerWithTs`（缺失必填）、`reportMessage`（缺失必填）
  - 文件：`tests/chat/test_chat_s2_server_ops.py`
  - 原因：当前端缺失必填路径可能返回 MissingPlugin（非被测端语义）。

## 第二批单聊边界补充
- `tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_cmd_message_delivery_ack`
  - 原因：CMD 仅收到 `onCmdMessagesReceived`，未收到 `onMessagesDelivered`。
- `tests/chat/test_chat_report_message_boundaries.py::test_chat_report_message_typed_success[*]`
  - 原因：位置/自定义实测返回 `501 Message contains illegal content`，CMD 返回 `500 message id is invalid`，当前没有稳定成功语义。
- `tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_fetch_conversations_invalid_mark`
  - 原因：Android bridge 对 `mark=999` 抛 `ArrayIndexOutOfBoundsException` 原始异常，无稳定业务 envelope。
- `tests/chat/test_chat_message_translation_boundaries.py::test_chat_translate_custom_message`
  - 原因：自定义消息翻译实测返回 `result={code:1,description:'General error'}`，按当前真实错误语义 strict；待后端支持自定义消息翻译后重新 discovery。
- `tests/chat/test_chat_message_translation_boundaries.py::test_chat_translate_message_unsupported_language`
  - 说明：当前端对不支持语言静默返回原消息、`targetLanguages=[]`、`translations={}`，已按兼容行为 strict，不视为翻译成功。

## 文档启用场景的功能开关与接口差异

- moderation 敏感词分支
  - 普通特殊字符的发送、接收和送达已 strict 覆盖。
  - 文档仅在 moderation 开启并命中敏感词时要求失败；当前 AppKey 未开启该能力，因此未将“未审核直接发送成功”当作审核功能预期。
  - 恢复条件：开启内容审核后提供可命中的测试词，再按真实审核错误和收发事件补充条件分支。
- Flutter 会话 API 与 Robot/WebIM 参数差异
  - `pinConversation` 公开 API 只有 `conversationId/isPinned`，没有 `conversationType`。
  - `addRemoteAndLocalConversationsMark` / `deleteRemoteAndLocalConversationsMark` 只有 `conversationIds/mark`，没有 `conversationType`。
  - `pinMessage` / `unpinMessage` 以消息 ID 操作，没有 Robot 模板中的额外 conversationType 参数。
  - 因此文档中仅改变 `conversationType` 的参数行无法在 Flutter 公共语义上独立映射；未向 generic bridge 塞入会被忽略的无效字段冒充覆盖。
- 类型消息举报
  - 位置/自定义实测返回 `501 Message contains illegal content`，CMD 返回 `500 message id is invalid`；这不是已知功能开关关闭态，但当前也没有成功语义。
  - 恢复条件：服务端确认这三类消息允许举报并提供可成功环境后重新 discovery；当前保持 skip，不把错误当成功预期。

## 当前环境阻塞

### 隔舱 TCP 消息 ACK 间歇超时

- 现象：`easemob-demo#qatest` 通过 `test.isolation.qa.easemob.com:4300` 发送消息时，SDK可登录、PROVISION、写出 `SYNC(meta)`，但部分时段连续两次未收到服务端消息 ACK，最终 `onMessageError(code=300, Server is unreachable)`。
- 与 case 的边界：同步 `sendMessage` 返回本地临时消息不代表服务端成功；case 必须等待匹配临时 msgId 的异步成功/错误终态。`300` 是发送前置环境失败，不是翻译、撤回、置顶业务预期。
- 2026-07-16 登录缓存修复后：类型消息 `from` 已稳定等于当天登录用户，不再出现旧用户导致的 `500 Message is invalid`；目标 custom translation case 曾完整通过，随后复跑才被 `300` 阻断。
- 恢复条件：隔舱 TCP 4300 上行能够稳定返回消息 ACK/server_id 后，复跑依赖新消息的 strict cases；无需开启业务功能开关。

### 第一批单聊基础消息补充
- `tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_cmd_message_delivery_ack`
  - 原因：已在 5556/5558 开启 `requireDeliveryAck=true`；文本和自定义消息收到 `onMessagesDelivered`，但 CMD 真实日志只收到 `onCmdMessagesReceived`，未收到送达事件。
  - 处理：不把“无事件”写成断言，case 暂时 skip。
  - 恢复条件：原生端/服务端明确 CMD 是否支持 delivery receipt，并能提供稳定真实事件后重新 discovery。
- `tests/chat/test_chat_s4_thread_user_removed.py::test_chat_thread_user_removed_event_type_not_null`
  - 原因：当前 Android 实测 `removeMemberFromChatThread` 返回 `result=true` 后，B/A 均未收到 `onUserKickOutOfChatThread`，无法验证发版项“event.type 非空”。
  - 前置条件：SDK/服务端确认并稳定派发 `onUserKickOutOfChatThread`。
  - 恢复条件：去掉 xfail，按真实事件体收紧 `event.type/from/thread` 断言并严格回归。
- `tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_delete_local_and_server_messages_by_time_bridge_missing`
  - 原因：当前 Android direct cmd `conversationDeleteServerMessageWithTime` 返回 `MissingPluginException`，属于桥接缺口，不作为 SDK 业务预期。
  - 前置条件：桥接/native method 补齐。
  - 恢复条件：按补齐后的真实返回重新 discovery，并改为 strict 断言。
