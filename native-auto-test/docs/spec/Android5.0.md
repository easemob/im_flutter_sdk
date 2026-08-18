# Android 5.0 测试结果记录

> 只记录当前仍需跟踪的 FAILED / SKIPPED；已通过用例不在此展开。

## Chat 模块（2026-08-18）

```text
本轮全量结果：26 failed / 195 passed / 40 skipped / 3 warnings
耗时：2956.44s（49m16s）
```

### FAILED（26）

#### 1. `modifyMessage` 不可用（14）

5.0 返回：`code=305, description='Sorry, edit is not available'`。

- `tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_media_attributes[voice|image|video]`（3）
- `tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_text_body_and_attributes[body|attributes|body-and-attributes]`（3）
- `tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_custom_body_modified_after_recipient_relogin`（1）
- `tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_media_attributes_modified_after_recipient_relogin[file|image|video|voice]`（4）
- `tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_text_modified_before_first_recipient_login`（1）
- `tests/chat/test_chat_offline_message_operations.py::test_chat_offline_recipient_receives_content_change_after_relogin`（1）
- `tests/chat/test_chat_s4_message_content_changed.py::test_chat_modify_custom_message_content_changed_event`（1）

#### 2. 送达/离线回放时序异常（3）

- `tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_delivery_ack_after_recipient_login`
  B 尚未重新登录时，A 已收到 `onMessagesDelivered`；用例预期该事件只能在 B 重登后出现。
- `tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_combine_delivery_ack_after_recipient_login`
  B 重登后未收到目标 combine 的 `onMessagesReceived`；此前该链路曾通过，需单跑确认是否为时序/环境波动。
- `tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_recall_after_recipient_relogin[voice]`
  撤回信息中的 voice `fileStatus` 本轮实际为 `1`，此前曾出现 `3`，值不稳定，不能锁死单值。

#### 3. 离线 Reaction / Pin 事件未派发（4）

- `tests/chat/test_chat_offline_message_operations.py::test_chat_offline_sender_receives_reaction_add_after_relogin`
- `tests/chat/test_chat_offline_message_operations.py::test_chat_offline_sender_receives_reaction_remove_after_relogin`
- `tests/chat/test_chat_offline_message_operations.py::test_chat_offline_recipient_receives_message_pin_after_relogin`
- `tests/chat/test_chat_offline_message_operations.py::test_chat_offline_recipient_receives_message_unpin_after_relogin`

操作请求成功，但离线重登后未收到对应事件。Wrapper 已有回调转发，需继续确认 5.0 原生/服务端是否同步最终状态；不能删除事件断言。

#### 4. Reaction 边界事件未派发（2）

- `tests/chat/test_chat_reaction_fetch.py::test_chat_add_reaction_too_long_reaction`
- `tests/chat/test_chat_reaction_fetch.py::test_chat_add_reaction_special_char_reaction`

`addReaction` 请求成功，但未收到目标 `messageReactionDidChange` 事件；超长和特殊字符场景均需 SDK/服务端确认。

#### 5. 本地会话删除返回值差异（3）

- `tests/chat/test_chat_s1_local_conversation.py::test_chat_load_all_conversations_contains_then_not_contains`
- `tests/chat/test_chat_s1_local_conversation.py::test_chat_delete_conversation_existing_then_not_found`
- `tests/chat/test_chat_s1_local_conversation.py::test_chat_delete_conversation_nonexistent_returns_bool`

官方 4.x 预期 `deleteConversation.result=True`，Android 5.0 原生返回 `False`；Wrapper 仅透传。删除后的本地列表/查询状态需单独验证。

### SKIPPED（40）

- 5.0 已移除能力：`reportMessage`、服务端会话拉取、`fetchConversationMarks` 等。
- 5.0 已废弃语义：会话级已读回执、部分服务端分页/拉取接口。
- 5.0 原生缺陷：无效消息 ID 下载附件/缩略图、不存在消息翻译等。
- 当前桥接/参数契约未完成：缺少必填参数、服务端删除消息参数边界等。

Skip 不计入通过；如对应 5.0 替代 API 或原生修复完成，再恢复为严格用例。

## status / fileStatus 实测口径

5.0 相比官方 4.x E2E，消息状态不能再按 4.x 的固定发送响应值统一断言；要按
消息类型和消息所处阶段断言。这里的差异是原生 5.0 状态机/上传时序变化，不是
Wrapper 为了通过测试改写字段。

`status` 和 `fileStatus` 不是同一层状态：

- `status` 是消息生命周期状态，离线接收不会产生一套新的 `status`，接收消息仍为 `2`。
- `fileStatus` 是媒体文件传输/下载状态，只有媒体消息有意义；location/custom 不应添加该字段。
- 官方 4.x E2E 将发送响应、发送成功、离线接收复用同一个 body；5.0 必须拆开断言。

### status

| 阶段 | 官方 4.x E2E | Android 5.0 实测 |
|---|---:|---|
| 发送响应 | 统一按 `1`（INPROGRESS） | text/file/voice/combine=`0`（CREATE）；image/video/cmd=`1`（INPROGRESS） |
| 发送成功事件 | `2` | `2` |
| 接收事件（在线/离线重登） | `2` | `2` |
| 下载附件响应/成功事件 | `2` / `2` | `2` / `2` |

### fileStatus

枚举含义按原生 `EMDownloadStatus`：`0=DOWNLOADING`、`1=SUCCESSED`、
`2=FAILED`、`3=PENDING`。

| 消息/阶段 | 官方 4.x E2E | Android 5.0 实测 |
|---|---:|---:|
| file/image/video 发送响应 | `3` | `0` |
| file/image/video 发送成功事件 | `3` | `0` |
| file/image/video 接收事件（在线/离线重登） | `3` | `3` |
| voice 发送响应/成功事件 | `3` / `3` | `0` / `0` |
| voice 接收事件（在线/离线重登） | `0` | `0` |
| combine 发送响应 | `3` | `0` |
| combine 发送成功事件 | `1` | `1` |
| combine 接收事件（在线/离线重登） | `3` | `3` |
| 下载附件响应 | 未单独拆分 | `0` |
| 下载附件成功事件 | 未单独拆分 | `1` |
| location/custom | 无此字段 | 无此字段 |

### 离线场景单独口径

离线不是另一套 `status/fileStatus`，字段值与在线接收一致；需要单独验证的是事件时序：

1. A 发送时，B 是否在线不改变 A 发送响应/发送成功阶段的断言。
2. B 离线重登后收到 `onMessagesReceived`：`status=2`；file/image/video 的 `fileStatus=3`，voice 保持 `fileStatus=0`，与在线接收相同。
3. 媒体执行 `downloadAttachment` 时，无论消息之前是否离线接收，下载接口本身是响应 `fileStatus=0`、成功事件 `fileStatus=1`；这是下载阶段，不是离线特有状态。
4. image 的缩略图下载单独验证；video 缩略图当前按用例验证失败事件 `403`，不能套用附件下载的 `0→1`。
5. 离线送达回执需要 `needReadReceipt=true`；当前 5.0 实测既出现 B 重登后触发，也出现 B 尚未重登时提前触发，时序仍需确认。

6. 撤回离线回放当前以 `onMessagesRecalledInfo` 为准；5.0 未稳定派发 4.x 的 `onMessagesRecalled`。

断言规则：

- 发送响应的 `status` 按消息类型断言，不使用 4.x 的统一 `1`。
- 发送响应的 `fileStatus` 按 5.0 发送方状态断言为 `0`。
- 发送成功事件 `status=2`；普通媒体发送成功阶段 `fileStatus=0`，下载附件成功阶段才是 `fileStatus=1`。
- 在线/离线接收事件 `status=2`，媒体 `fileStatus` 按上表断言。
- 撤回信息中的媒体 `fileStatus` 目前按场景实测，voice 已出现 `1` 与 `3` 两种值，暂不作为稳定单值契约。
- combine 必须区分三个阶段：发送响应 `0`、发送成功 `1`、接收 `3`。
- 不把 `status` / `fileStatus` 放入全局 `ignore_keys`；如果某个接口尚未确认阶段值，应单独记录为待确认，不用忽略字段掩盖。

该状态机差异未出现在官方 5.0 API 变更说明中，属于 Android 5.0 原生实测差异。

## Conversation / `deleteConversation` 实测差异

这 3 个用例验证的是本地会话删除，不是服务端会话删除：

- `test_chat_load_all_conversations_contains_then_not_contains`：创建会话、加载会话列表、删除会话、再次确认列表中消失。
- `test_chat_delete_conversation_existing_then_not_found`：删除已存在会话后，`getConversation(createIfNeed=false)` 应返回空。
- `test_chat_delete_conversation_nonexistent_returns_bool`：删除不存在会话，验证返回布尔值。

| 场景 | 官方 4.x E2E | Android 5.0 实测 |
|---|---:|---:|
| 删除已存在本地会话 | `True` | `False` |
| 删除不存在本地会话 | `True` | `False` |

Android 5.0 Wrapper 仅透传原生 `EMChatManager.deleteConversation()` 的 boolean，`False` 来自原生 SDK，不是 Wrapper 构造。当前失败发生在返回值断言处，删除后的列表/查询状态尚未在这些失败用例中继续验证，因此暂不将其判断为“删除一定失败”；需单独记录返回值与删除后的本地状态。

## 运行备注

- 全量耗时较长，失败日志中反复出现 managed-ws runner 注册，需另行排查设备连接/重连耗时。
- `PytestReturnNotNoneWarning`：两个测试函数返回了字符串，应清理测试代码，但不影响本次结果统计。
