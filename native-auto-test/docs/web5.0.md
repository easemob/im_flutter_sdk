# Web 5.0 适配记录

## UserInfo 模块

以下 3 个用例属于 Web 5.0 原生边界错误码差异。当前不修改 Case，也不在 Wrapper 中伪造 Android 错误码，待确认 Web 5.0 原生协议后再处理。

| 用例 | Android 预期 | Web 5.0 实测 | 判定 |
|---|---|---|---|
| `test_user_info_update_own_nickname_length_over_64` | `901 / User info exceeds the data length` | `210` | Web 原生超长资料错误码不同 |
| `test_user_info_fetch_by_id_empty_user_ids` | `205 / userIds is empty` | `110 / params.userIds is required` | Web 原生参数校验错误码和文案不同 |
| `test_user_info_fetch_by_id_user_ids_over_100` | `900 / The maximum number of user IDs is exceeded` | `110` | Web 原生参数校验错误码不同 |

这些属于 Web 5.0 原生校验语义差异。

### 批量查询返回集合差异

`fetchUserInfoById` / `fetchUserInfoByIdWithType` 接收用户 ID 数组，三端 Wrapper 都会把完整数组传给原生接口。

| 用例 | Android 预期 | Web 5.0 实测 | 判定 |
|---|---|---|---|
| `test_user_info_fetch_by_id_normal` | Android/iOS 5.0 返回 `user_a`、`user_b` 两个资料对象，至少包含各自 `userId` | 只返回 `user_a`，缺少 `user_b` | Web 原生只返回实际存在资料记录的用户 |
| `test_user_info_fetch_by_id_with_type_normal` | Android/iOS 5.0 返回 `user_a`、`user_b` 两个资料对象，至少包含各自 `userId` | 只返回 `user_a`，缺少 `user_b` | Web 原生按属性查询时未返回无资料记录的用户 |

这不是 Web Wrapper 丢弃了 `user_b`，也不是账号不存在，而是 Web 5.0 原生返回集合语义不同。当前 Wrapper 不补造 `{userId: user_b}`，Case 不改，待 Web 原生接口确认是否需要统一返回结构。

## Presence 模块

以下 3 个用例验证 Presence 参数超限。Web 5.0 原生统一返回
`110 / Invalid request parameters`；Android/iOS 5.0 返回
`1100 / Presence parameter length is exceeded`。

| 用例 | Android 预期 | Web 5.0 实测 | 判定 |
|---|---|---|---|
| `test_presence_publish_128k_desc` | `1100 / Presence parameter length is exceeded` | `110 / Invalid request parameters` | Web 原生错误码和文案不同 |
| `test_presence_subscribe_over_100_members` | `1100 / Presence parameter length is exceeded` | `110 / Invalid request parameters` | Web 原生错误码和文案不同 |
| `test_presence_unsubscribe_over_100_members` | `1100 / Presence parameter length is exceeded` | `110 / Invalid request parameters` | Web 原生错误码和文案不同 |

这是 Web 5.0 原生校验差异，不是多设备投递问题。当前不在 Web Wrapper 中伪造 `1100`；跨平台 Case 若要求统一错误码，应单独定义平台预期或先确认 Web SDK 是否需要修复。

## Client 模块

`renewToken` 在各端都具备原生 API，但空 Token 的错误码不一致：

| 用例 | Android 预期 | Web 5.0 实测 | 判定 |
|---|---|---|---|
| `test_client_session_sensitive_api_boundaries[renewToken-info0-expected_result0]` | `104` | `110 / Validation failed: root: token is required` | Web 原生参数校验错误码和文案不同 |

该失败不是 Wrapper 未实现：Web Wrapper 已调用原生 `ChatClient.renewToken`，当前保留 Web 原生返回值。

## Push 模块

全局免打扰查询的 Web 原生返回对象只有全局作用域和规则信息，不包含真实会话 ID：

| 用例 | Android 预期 | Web 5.0 实测 | 判定 |
|---|---|---|---|
| `test_push_global_silent_mode_flow` | 返回统一免打扰字段，并带有非空 `convId` | 返回 `scope=global` 和 `rule`；没有 `convId` | 全局配置没有对应会话，Wrapper 不伪造 `convId`；该字段是 Web 5.0 与 Android/iOS 的返回结构差异 |

Web Wrapper 只将真实存在的规则字段映射为公共字段；`convId` 仅适用于会话级免打扰查询。

## Contact 模块

以下两个用例验证添加好友时的非法用户场景。Web 5.0 原生
`addContact` 对这两种输入都返回成功，Wrapper 实测只收到成功结果，
并非错误码在 Runner 中丢失。

| 用例 | Android 预期 | Web 5.0 实测 | 判定 |
|---|---|---|---|
| `test_contact_add_nonexistent_user` | `204 / User does not exist` | 成功，`result=nonexistent_contact_user_xyz_999` | Web 原生允许对不存在用户发起申请，语义不同 |
| `test_contact_add_self` | `101 / User ID is invalid` | 成功，`result=<当前用户 ID>` | Web 原生未按 Android 规则拒绝添加自己 |
| `test_contact_add_empty_user_id` | `101 / User ID is invalid` | `110` | Web 原生参数校验错误码不同 |
| `test_contact_delete_contact_nonexistent_user` | `204 / User does not exist` | `303` | Web 原生 REST 错误码不同 |
| `test_contact_remark_special_chars_length_101` | `4` | `223` | Web 原生备注长度错误码不同 |
| `test_contact_set_contact_remark_non_friend` | `221` | `223` | Web 原生非好友备注错误码不同 |


这些差异不能通过 Web Wrapper 伪造 Android 错误码，也不是 Runner
丢失错误字段。若要统一跨端用例，应先确认 Web 5.0 SDK 的产品语义；
在确认前保留该差异记录，不直接修改 Android 预期。`add_self` 和
`add_nonexistent_user` 的 Web 成功结果尤其需要确认服务端产品语义。

## ChatRoom 模块

以下 10 个用例的失败来自 Web 5.0 原生错误语义与 Android/iOS 的差异。当前 Web
Wrapper 没有把这些错误码改写成 Android/iOS 的 `700/705`，因此不应通过伪造错误码
或伪造成功列表来处理。

| 用例 | Android 预期 | Web 5.0 实测 | 判定 |
|---|---|---|---|
| `test_chatroom_fetch_room_info_nonexistent` | `700` | `303` | Web 原生查询不存在聊天室的错误码不同 |
| `test_chatroom_fetch_room_info_from_server_after_destroy` | `700 / do not find this group` | `303` | Web 原生查询已由 REST 销毁的聊天室时返回 REST 业务错误码不同 |
| `test_chatroom_join_room_nonexistent` | `705` | `606` | Web 原生加入不存在聊天室的错误码不同 |
| `test_chatroom_join_room_empty_id` | `700` | `110` | Web 原生空 `roomId` 参数校验错误码不同 |
| `test_chatroom_leave_room_nonexistent` | 成功/`true` | `606 / The group does not exist` | Web 原生不会按 Android 的离开语义返回成功 |
| `test_chatroom_leave_room_empty_id` | `700` | `110` | Web 原生空 `roomId` 参数校验错误码不同 |
| `test_chatroom_fetch_room_info_empty_id` | `700` | `110` | Web 原生空 `roomId` 参数校验错误码不同 |
| `test_chatroom_fetch_members_nonexistent_room` | `700` | `303` | Web 原生查询不存在聊天室的错误码不同 |
| `test_chatroom_fetch_members_empty_room_id` | `700` | `110` | Web 原生空 `roomId` 参数校验错误码不同 |
| `test_chatroom_fetch_public_chat_rooms_invalid_paging[-1-1]` | 成功返回列表 | `110 / Invalid request parameters` | Web 原生拒绝负分页参数；Android/iOS 原生会接受或归一化 |
| `test_chatroom_fetch_public_chat_rooms_invalid_paging[1--1]` | 成功返回列表 | `110 / Invalid request parameters` | Web 原生拒绝负分页参数；Android/iOS 原生会接受或归一化 |

其中前 8 个是错误码/错误语义差异；后 2 个是分页边界行为差异。若后续要求一套
Case 严格覆盖三端，需要在测试协议中明确平台预期，或拆出 Web-only 边界用例；不能
在 Web Wrapper 中把原生 `110/303/606` 强行转换为 `700/705`。

### 加入聊天室返回结构

| 协议/用例 | Android/iOS 5.0 预期 | Web 5.0 实测 | 判定 |
|---|---|---|---|
| `ChatRoomManager.joinChatRoom` | 成功后返回完整 `ChatRoomInfo`，包含 `roomId` 等聊天室字段 | 原生 join 成功，但返回空对象 `{}`，未返回 `ChatRoomInfo` | Web 原生返回结构不完整，属于 Web 5.0 SDK 问题；Wrapper 不通过 `getChatRoomInfo` 补造 join 结果 |

该问题会使依赖加入响应的聊天室回调 Case 在前置断言阶段失败，不能据此判断后续
聊天室事件没有投递。`getChatRoomInfo` 仍是独立的详情查询协议，不作为
`joinChatRoom` 的返回值补偿。

### 全员禁言状态字段

| 用例 | Android 预期 | Web 5.0 实测 | 判定 |
|---|---|---|---|
| `test_chatroom_mute_and_unmute_all_members_success` | 禁言后查询 `isAllMemberMuted=true`，解除后为 `false` | `muteAllMembers`/`unmuteAllMembers` 调用成功，但 `getChatRoomInfo` 未返回全员禁言状态字段 | Web 原生 `getChatRoomInfo` 字段缺口，属于 Web SDK Bug/能力不完整 |

Web 5.0 原生具备全员禁言/解除接口，也提供 `onAllMemberMuteStateChanged` 事件；但
`getChatRoomInfo` 的返回对象没有 `isAllMemberMuted`。这不代表 Web 完全没有全员禁言能力，
而是详情查询接口没有暴露该状态字段。

这不是等待时间或多设备投递问题，也不能通过修改公共 Case 或在 Wrapper 中缓存/伪造
`true`/`false` 解决。正确修复是 Web 原生详情接口补齐 `isAllMembersMuted`，Wrapper 再将
它映射为统一协议字段 `isAllMemberMuted`。在此之前，事件用例可以验证全员禁言状态变化，
但该查询字段用例应记录为 Web 5.0 阻塞项。
