# Android 5.0 测试结果记录

> 只记录当前仍需跟踪的 FAILED / SKIPPED；已通过用例不在此展开。

## Chat 模块

### FAILED

#### 1. `modifyMessage` 不可用（14）

5.0 返回：`code=305, description='Sorry, edit is not available'`。

- `tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_media_attributes[voice|image|video]`（3）
- `tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_text_body_and_attributes[body|attributes|body-and-attributes]`（3）
- `tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_custom_body_modified_after_recipient_relogin`（1）
- `tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_media_attributes_modified_after_recipient_relogin[file|image|video|voice]`（4）
- `tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_text_modified_before_first_recipient_login`（1）
- `tests/chat/test_chat_offline_message_operations.py::test_chat_offline_recipient_receives_content_change_after_relogin`（1）
- `tests/chat/test_chat_s4_message_content_changed.py::test_chat_modify_custom_message_content_changed_event`（1）

#### 2. 离线 Reaction / Pin 事件未派发（4）

- `tests/chat/test_chat_offline_message_operations.py::test_chat_offline_sender_receives_reaction_add_after_relogin`
- `tests/chat/test_chat_offline_message_operations.py::test_chat_offline_sender_receives_reaction_remove_after_relogin`
- `tests/chat/test_chat_offline_message_operations.py::test_chat_offline_recipient_receives_message_pin_after_relogin`
- `tests/chat/test_chat_offline_message_operations.py::test_chat_offline_recipient_receives_message_unpin_after_relogin`

操作请求成功，但离线重登后未收到对应事件。Wrapper 已有回调转发，需继续确认 5.0 原生/服务端是否同步最终状态；不能删除事件断言。

#### 3. Reaction 边界事件未派发（2）

- `tests/chat/test_chat_reaction_fetch.py::test_chat_add_reaction_too_long_reaction`

`addReaction` 请求成功，但未收到目标 `messageReactionDidChange` 事件；超长和特殊字符场景均需 SDK/服务端确认。


### SKIPPED（40）

- 5.0 已移除能力：`reportMessage`、服务端会话拉取、`fetchConversationMarks` 等。
- 5.0 已废弃语义：会话级已读回执、部分服务端分页/拉取接口。
- 5.0 原生缺陷：无效消息 ID 下载附件/缩略图、不存在消息翻译等。
- 当前桥接/参数契约未完成：缺少必填参数、服务端删除消息参数边界等。

Skip 不计入通过；如对应 5.0 替代 API 或原生修复完成，再恢复为严格用例。

## Chatroom 模块

```text
本轮全量结果：3 failed / 134 passed / 7 skipped / 1 warning
耗时：403.25s（6m43s）
```

### FAILED（3）

1. `tests/chatroom/test_chatroom_callbacks.py::test_chatroom_member_exited_callback`
   B 离开聊天室后，A 未收到 `onRoomMemberExited`。A 已显式加入聊天室，保留失败，待 5.0 原生 SDK/服务端确认。

2. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_join_room_nonexistent`
   官方 4.x 预期 `code=705`（`Chat room does not exist`），Android 5.0 实际返回 `code=303`；保留严格错误码断言，待确认 5.0 错误码基线。

3. `tests/chatroom/test_chatroom_members.py::test_chatroom_join_with_ext_member_joined_callback`
   A 加入成功且 wrapper 已传递 ext，但 B 未收到 A 携带 ext 的 `onRoomMemberJoined`，仅收到聊天室初始成员 `user3/ext=""` 事件。严格保留目标成员和 ext 断言，待 5.0 原生 SDK/服务端确认。

### SKIPPED（7）

- 5.0 已移除客户端 `createChatRoom` / `destroyChatRoom`：
  `test_chatroom_create_room_via_sdk_without_permission`、
  `test_chatroom_destroy_room_nonexistent`、
  `test_chatroom_destroy_room_empty_id`、
  `test_chatroom_destroy_room_success`。
- 5.0 不支持 `ChatRoomManager.getAllChatRooms`：
  `test_chatroom_join_then_get_local_room_and_all_rooms`、
  `test_chatroom_get_all_local_rooms_returns_list`、
  `test_chatroom_join_leave_other_rooms_option_controls_existing_rooms`。

以上 skip 属于 5.0 API 移除/不支持，不计入通过，也不通过放宽断言处理。

## Client 模块

```text
本轮结果：2 failed / 23 passed / 2 skipped / 1 warning
耗时：21.59s
```

### FAILED（2）

- `tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries[getLoggedInDevicesFromServer-info2-expected_result2]`
- `tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries[kickAllDevices-info4-expected_result4]`

5.0 wrapper 已改用 token 原生 API：

- `fetchLoggedInDevicesFromServerWithToken`
- `kickAllDevicesWithToken`

用例中的 `isPwd` 已移除，但原断言仍保留 4.x 的 `204/User does not exist`。5.0 实测非法用户/非法 token 返回：
`303/Unknown server error`。wrapper 仅透传原生 SDK 错误，不构造 `303`。

临时 discovery 结果：

- 不存在用户 + 有效 token：`303/Unknown server error`
- 存在用户 + 非法 token：`303/Unknown server error`
- 存在用户 + 有效 token：正常返回设备列表
- `kickAllDevices` 的非法凭证场景：`303/Unknown server error`
- 本轮未观察到 5.0 token API 返回 `204/User does not exist`。

因此 `204` 仍是 SDK 错误码定义，但当前两个 case 实际冻结的是 4.x 密码 API 语义；5.0 应按 token API 重新定义边界预期，不能忽略错误码。

### SKIPPED（2）

- `test_client_create_account_empty_user_boundary`：5.0 移除客户端 `createAccount`，账号预创建走 REST。
- `test_client_session_sensitive_api_boundaries[loginWithAgoraToken-info5-expected_result5]`：5.0 API Matrix 标记 `Client.loginWithAgoraToken` 为 removed/unsupported。

## Contact 模块

```text
本轮结果：31 passed / 6 skipped / 0 failed / 1 warning
耗时：199.27s（3m19s）
```

### SKIPPED（6）

- `tests/contact/test_contact.py::test_contact_remark_not_preserved_after_delete_and_readd`
  5.0 的 `getContact` 使用本地联系人缓存，删除并重新添加后的备注清理语义暂不稳定。
- `tests/contact/test_contact.py::test_contact_fetch_all_contact_ids`
  5.0 移除 `fetchAllContactIds`。
- `tests/contact/test_contact.py::test_contact_get_all_contact_ids`
  Android 5.0 不支持 `getAllContactIds`。
- `tests/contact/test_contact.py::test_contact_fetch_contacts_page_size_zero`
- `tests/contact/test_contact.py::test_contact_fetch_contacts_page_size_exceeds_50`
- `tests/contact/test_contact.py::test_contact_fetch_contacts_page_size_negative`
  5.0 移除 `fetchContacts` 分页接口，参数边界不再适用。

以上 skip 均为 5.0 API 移除/不支持或本地缓存语义未稳定，不通过放宽断言处理。

### 本轮适配确认

- `setContactRemark` 按 5.0 原生成功响应严格断言；`getContact` 使用本地 `fetchContactFromLocal`，实测不稳定返回已设置的 remark，因此不把本地备注回读作为该 API 的成功条件。
- 离线好友关系用 topology 统一下线、恢复同账号全部设备。
- `getAllContactsFromDB` 只校验当前目标好友关系存在/不存在，并保留真实响应与列表类型断言；不再要求本地 DB 整体只能有当前 case 的联系人，避免历史联系人造成误报。

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
| 下载附件响应 | 未单独拆分 | `0` 或 `1`（本地已缓存时直接返回 `1`） |
| 下载附件成功事件 | 未单独拆分 | `1` |
| location/custom | 无此字段 | 无此字段 |

### 离线场景单独口径

离线不是另一套 `status/fileStatus`，字段值与在线接收一致；需要单独验证的是事件时序：

1. A 发送时，B 是否在线不改变 A 发送响应/发送成功阶段的断言。
2. B 离线重登后收到 `onMessagesReceived`：`status=2`；file/image/video 的 `fileStatus=3`，voice 保持 `fileStatus=0`，与在线接收相同。
3. 媒体执行 `downloadAttachment` 时，下载接口响应 `fileStatus` 允许为 `0` 或 `1`：未完成下载时为 `0`，本地缓存已完成时可直接为 `1`；成功事件固定为 `fileStatus=1`。这是下载阶段，不是离线特有状态。
4. image 的缩略图下载单独验证；video 缩略图当前按用例验证失败事件 `403`，不能套用附件下载的 `0→1`。
5. 离线送达回执需要 `needReadReceipt=true`；当前 5.0 实测既出现 B 重登后触发，也出现 B 尚未重登时提前触发，时序仍需确认。

6. 撤回离线回放当前以 `onMessagesRecalledInfo` 为准；5.0 未稳定派发 4.x 的 `onMessagesRecalled`。

断言规则：

- 发送响应的 `status` 按消息类型断言，不使用 4.x 的统一 `1`。
- 发送响应的 `fileStatus` 按 5.0 发送方状态断言为 `0`；下载接口响应严格断言为 `0` 或 `1`，不能直接忽略。
- 发送成功事件 `status=2`；普通媒体发送成功阶段 `fileStatus=0`，下载附件成功阶段才是 `fileStatus=1`。
- 在线/离线接收事件 `status=2`，媒体 `fileStatus` 按上表断言。
- 撤回信息中的媒体 `fileStatus` 目前按场景实测，voice 已出现 `1` 与 `3` 两种值，暂不作为稳定单值契约。
- combine 必须区分三个阶段：发送响应 `0`、发送成功 `1`、接收 `3`。
- `onMessagesDelivered` 中的 combine 消息实测出现过 `fileStatus=1` 和 `3`；用例严格限制为 `{1,3}` 并记录实际值，不能放入全局 `ignore_keys`。
- 不把 `status` / `fileStatus` 放入全局 `ignore_keys`；如果某个接口尚未确认阶段值，应单独记录为待确认，不用忽略字段掩盖。

该状态机差异未出现在官方 5.0 API 变更说明中，属于 Android 5.0 原生实测差异。

## Group 模块

### 仍需跟踪：`style=3 / PublicOpenJoin` 入群申请语义

用例：

```text
tests/group/test_group_style_membership_matrix.py::test_group_request_to_join_rejects_every_non_approval_style[public-open]
```

4.x E2E 将 `style=3` 按“非审批群不允许申请”处理，预期：

```text
requestToJoinPublicGroup -> code=603 permission
```

Android 5.0 实测行为为：

```text
isPublic=True
joinApprovalRequired=False
requestToJoinPublicGroup -> result=null
B 直接成为成员，A 收到 onGroupMembersJoined
```

`result=null` 表示该无返回值 API 调用成功，不是失败响应。

结论：这是 4.x E2E 与 Android 5.0 原生/服务端的行为契约差异，不是 wrapper 字段断言问题。
不能把预期强行改成 `603`，也不能忽略加入事件；该 case 要么重写为 5.0 正向用例，要么继续作为唯一待确认项保留。
