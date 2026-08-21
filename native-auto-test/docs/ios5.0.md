# iOS 5.0 测试结果记录

> 只记录当前仍需跟踪的 FAILED / SKIPPED；已通过用例不展开。
> 本文记录 iOS 5.0 原生 SDK 的实测行为，不作为跨版本规范。

## ChatRoom 模块

本轮结果：`4 failed / 131 passed / 9 skipped / 1 warning`

### FAILED

#### 1. 成员主动退出事件未收到

用例：

```text
tests/chatroom/test_chatroom_callbacks.py::test_chatroom_member_exited_callback
```

B 调用 `leaveChatRoom` 成功，但 A 未收到 `onRoomMemberExited`。

iOS wrapper 已实现 `userDidLeaveChatroom` 回调转发，当前协议名为 `onRoomMemberExited`；保留严格事件断言，待确认 iOS 5.0 原生 SDK/服务端是否实际触发该事件。

#### 2. 加入不存在聊天室的错误码差异

用例：

```text
tests/chatroom/test_chatroom_exceptions.py::test_chatroom_join_room_nonexistent
```

官方 4.x E2E 预期：

```text
705 / Chat room does not exist
```

iOS 5.0 实测：

```text
303 / Unknown server error
```

iOS wrapper 透传原生错误，没有构造 `303`。不能通过忽略错误码掩盖；待确认 iOS 5.0 原生/服务端错误码基线。

#### 3. 空属性 map 错误码差异

用例：

```text
tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_add_attributes_empty_map
```

请求：

```json
{"attributes": {}}
```

官方 4.x E2E 预期 `110`；iOS 5.0 实测：

```text
303 / Unknown server error
```

iOS wrapper 将空 map 传给原生属性接口，并透传原生错误；没有构造 `303`。该用例属于 4.x 与 iOS 5.0 返回语义差异，待确认 5.0 跨平台基线。

#### 4. 加入成员 ext 未按目标事件到达

用例：

```text
tests/chatroom/test_chatroom_members.py::test_chatroom_join_with_ext_member_joined_callback
```

观察端收到了聊天室初始成员事件：

```text
participant=user3
ext=""
```

但没有收到目标加入方 `user1` 携带指定 `ext` 的事件。

iOS wrapper 的 `joinChatroom:ext:leaveOtherRooms:completion:` 已传入 ext，且事件回调包含 ext 字段；不能改成匹配任意成员或空 ext。保留失败，待确认 iOS 5.0 原生/服务端是否广播加入方 ext。

### SKIPPED

- 5.0 已移除客户端 `createChatRoom` / `destroyChatRoom` 的相关用例。
- 5.0 不支持 `getAllChatRooms` 的相关用例。

这些 skip 是 API 能力差异，不通过放宽断言处理。

## iOS 5.0 wrapper 口径

- `leaveChatRoom`：原生成功返回 `true`，原生失败透传错误码。
- `setChatRoomAttributes` / `removeChatRoomAttributes`：属性参数和错误由原生 SDK 处理，wrapper 不构造 `110` 或 `303`。
- 聊天室成员事件当前协议名为 `onRoomMemberJoined`、`onRoomMemberExited`。
- `description` 不作为跨平台稳定断言字段；错误码和目标事件仍需严格校验。

## Chat 与 Android 5.0 的字段差异

以下差异来自 iOS/Android 5.0 全量 Chat 实测，wrapper 均透传原生状态，没有人为改写：

| 字段 | Android 5.0 实测 | iOS 5.0 实测 | 处理 |
|---|---:|---:|---|
| 发送响应 `status` | `0` | `1` | 不固定断言发送瞬间状态；`onMessageSuccess` 仍校验最终成功状态 |
| voice `fileStatus` | `0` | `1` | 不固定断言发送/接收瞬间状态，媒体内容和成功事件仍严格校验 |
| 无效媒体路径 `fileSize` | `0` | `-1` | 只校验发送失败、错误码和对端未收到，不断言具体大小 |


这些字段差异属于原生状态时序或无效文件的表示差异，不等同于业务失败。不能用“允许任意值”掩盖消息内容、msgId、成功/失败事件等核心断言。
