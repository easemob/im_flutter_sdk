# iOS 5.0 适配记录

本文只记录 iOS 5.0 原生 SDK 与 Android 5.0/当前测试协议的差异。

原则：Wrapper 透传原生结果；测试 case 保持业务断言，不为了 pass 把 iOS 返回值改成 Android 返回值。下表中的“Bug/差异”在原生修复或确认前保留失败，不改成平台分支绕过。

## Group模块

### 错误结果/空结果差异

| Case | Android 5.0 预期/实测 | iOS 5.0 实测 | 判定 |
|---|---|---|---|
| `test_group_create_group_max_count_less_than_invite_members` | `604 / The group member capacity is reached` | 创建成功，`maxUserCount=3`，`memberCount=3` | iOS 原生参数归一化差异；应修 SDK/确认协议 |
| `test_group_create_group_desc_reason_options_abnormal_inputs[options_max_count_zero-*]` | `110 / maxUsers should be greater than 0` | 创建成功，`maxUserCount=3` | iOS 原生未按 Android 校验非正 maxCount |
| `test_group_create_group_desc_reason_options_abnormal_inputs[options_max_count_negative-*]` | `110 / maxUsers should be greater than 0` | 创建成功，`maxUserCount=3` | 同上 |
| `test_group_public_open_join_rejects_when_group_is_full` | 创建快照应为 `maxUserCount=2`，随后满员加入应返回 `604` | 当前在创建快照阶段即返回 `maxUserCount=3`，case 尚未执行 C 加入断言 | iOS 原生容量归一化差异；不新增 D 用户绕过，不修改 case 预期 |
| `test_group_get_group_from_server_nonexistent` | `600 / do not find this group` | `result=null` | iOS 原生未返回错误对象 |
| `test_group_get_group_from_server_after_destroy` | `600 / do not find this group` | `result=null` | iOS 原生未返回错误对象 |
| `test_group_download_shared_file_nonexistent_group_current_behavior` | `600 / do not find this group` | `result=null` | iOS 原生未返回错误对象 |

以上 7 个 case 当前不改断言、不在 iOS Wrapper 中伪造错误码；需要 SDK/服务端确认并修复。

其中前 3 个和满员 case 都属于 `maxCount` 参数归一化问题：iOS 5.0 当前把过小、0 或负数容量按最小容量 `3` 处理。测试仍以 Android 5.0 的业务契约为基准，保留原始输入和错误预期，避免通过增加第四个用户或改成 `maxCount=3` 掩盖差异。

### 其他 Group 差异

| 类型 | iOS 5.0 实测 | 处理 |
|---|---|---|
| `test_group_set_member_attributes_empty_attributes` | `110` | Android 为 `205`；原生参数校验差异，不能随意改 case |
| `test_group_remove_member_attributes_empty_keys` | `110` | Android 为 `205`；原生参数校验差异，不能随意改 case |
| `style=3` / 公开免审核群入群 | 请求成功并自动入群 | 与 4.x 的 `603` 预期不同；这是 5.0 三布尔语义变化，不是普通错误码差异 |
| 群详情成员列表 | `memberList` 与 `adminList` 的组合可能受原生缓存/操作阶段影响 | 完整成员校验使用 `getGroupMemberListFromServer`，管理员单独校验 |

## Chat模块

### 动态字段

当前测试不会把所有状态字段统一放进 `ignore_keys`，而是按字段语义和消息阶段处理。

| 字段 | 所在位置 | 当前断言方式 | 原因 |
|---|---|---|---|
| `status` | 消息外层 | 默认严格断言；成功终态通常校验 `2`，错误事件按业务校验终态。只有发送响应等明确存在竞态的局部 helper 才忽略 | 它代表消息发送/处理状态，属于核心业务结果，不能全局忽略 |
| `fileStatus` | 媒体消息 `body` | 初始构造或明确下载阶段可校验固定值；跨端接收、离线回放、下载完成回调等 endpoint 状态不稳定时，由 `_MEDIA_DYNAMIC_KEYS` 局部忽略 | 状态由本地媒体缓存和下载时序决定 |
| `thumbnailStatus` | 图片/视频消息 `body` | 与 `fileStatus` 相同，在媒体动态断言集合中局部忽略 | 不同设备的缩略图下载进度可能不同 |
| `fileSize` | 媒体消息 `body` | 不作为跨端下载阶段的固定断言字段 | 发送、同步和下载阶段可能尚未填充或取值不同 |

当前代码中的具体规则：

- `_MESSAGE_DYNAMIC_KEYS` 不包含 `status`，所以普通文本、历史消息和稳定终态默认仍会检查 `status`；
- `_MEDIA_DYNAMIC_KEYS` 包含 `fileStatus`、`thumbnailStatus` 及媒体路径/大小等字段，媒体接收和下载 helper 只在这些动态位置忽略；
- 下载响应和 `onMessageSuccess` 下载事件额外局部忽略 `hasRead`，因为本地读取状态可能在下载时已发生变化；
- 初始发送或明确的媒体 body 仍可断言 `fileStatus=0`，不能因为动态场景而全部忽略；
- 不能简单写成 `fileStatus in {0,1,2,3}`，否则只验证“返回了某个枚举值”，无法验证真实业务状态。

已观察到的 iOS 5.0 差异包括：下载响应中 `fileStatus` 出现过预期 `0`、实际 `1`，合并消息送达回执中出现过预期 `1`、实际 `3`。因此这些位置按 endpoint/阶段局部处理，不修改 Wrapper 伪造状态值；消息 ID、类型、正文、错误码和关键事件仍严格校验。

### 原生能力/错误差异

消息编辑、历史消息、会话查库、Reaction 边界等失败，先按 iOS 原生结果记录，不把 Android 错误码或成功结果写入 iOS 预期。`modifyMessage` 返回 `305 / Sorry, edit is not available` 时，优先确认 AppKey/服务端能力。

### 当前 Chat 失败记录

以下差异均基于 iOS 5.0 实测记录，不能统一归类为 iOS Wrapper Bug。Wrapper 当前原则是透传原生结果；只有确认协议字段或序列化错误时才修改 Wrapper。

| Case | iOS 5.0 实测/现象 | 处理结论 |
|---|---|---|
| `test_chat_modify_message_empty_id` | `code=500 / Message is invalid`（Android 为 `code=1 / messageId is empty`） | iOS 原生错误码和文案均不同；先确认统一协议，再决定 Case 只断言 code、做平台差异断言或由 Wrapper 归一化 |
| `test_chat_add_reaction_too_long_reaction` | `addReaction` 响应通过，但未收到 `onReactionChange` | 先确认超长 reaction 是否应被服务端接受；合法则排查事件投递，非法则改为断言错误响应，不能只删除事件断言 |
| `test_chat_add_reaction_special_char_reaction` | 换行/Tab reaction 响应通过，但未收到 `onReactionChange` | 与超长 reaction 同处理，先确认边界语义，不直接判定为多端投递问题 |
| `test_chat_delete_remote_conversation_empty_conv_id` | 预期 `303`，iOS 原生透传 `107` | 原生错误码差异，不是 Wrapper 构造；先确认统一协议，再决定只断言 code 或修 Wrapper 归一化 |
| `test_chat_fetch_history_messages_empty_conv_id` | `110 / Invalid parameter` | 原生回调非空 `EMCursorResult`，Wrapper 序列化为 `result={"cursor":"","list":[]}`，没有 `code`/`description` | 不是 Wrapper 构造错误码，而是 iOS 原生直接返回空分页结果；与 Android 错误语义不同 |
| `test_chat_fetch_history_messages_by_options_empty_conv_id` | `110 / Invalid parameter` | 原生回调非空 `EMCursorResult`，Wrapper 序列化为 `result={"cursor":"","list":[]}`，没有 `code`/`description` | 同上；不能把 iOS 的空结果当成 Android 的 `110` |
| `test_conversation_type_keyword_and_options_search_current_behavior` | 全量运行曾出现空结果预期实际返回 1 条记录；本次 iOS 5.0 单跑通过 | 更像全量运行时的本地数据库/会话残留或时序污染；保留空列表断言，先隔离会话或清理后复测，不直接放宽断言 |
| `test_conversation_invalid_message_id_boundaries` | iOS 原生返回 `code=3 / Database operation failed`；Android 原生 `conversation.getMessage(msgId)` 返回 `null`，Wrapper 再通过 `onSuccess(..., null)` 输出 `result=null` | 已确认的平台原生查询语义和 Wrapper 返回形态均不同；如需跨端统一，在 Wrapper 归一化，否则保留平台差异记录 |



## ChatRoom模块

| 类型 | iOS 5.0 实测 |
|---|---|
| 加入不存在聊天室 | `303 / Unknown server error`，不是 4.x 的 `705` |
| 空属性 map | `303 / Unknown server error`，不是 Android 的 `110` |
| 成员/退出事件 | 目标成员事件可能不稳定；保留目标成员和目标 ext 的严格匹配 |

## Push模块

`updateFCMPushToken` 不是 Android-only：

- Android 未配置 FCM notifier：`110 / Notifier name should not be empty!`
- iOS 未配置 APNs cert：`205 / Apns cert name is NULL`

这是两端原生配置/错误码差异，不能在 iOS Wrapper 中改成 `110`。`updateAPNsPushToken` 的 Android MissingPlugin 用例仍是平台独有能力。

## UserInfo模块

`fetchUserInfoById` 传空 `userIds`：Android 原生返回 `205 / userIds is empty`；iOS 5.0 实测成功返回空结果。该差异需要确认 iOS 原生校验策略，不能把空结果当作有效用户信息查询成功。

## 维护规则

1. 原生返回什么，先记录什么；不要为了跨端 pass 在 Wrapper 中伪造结果。
2. 错误码一致但文案大小写不同：只断言错误码；错误码不同：记录平台差异，不直接放宽成任意值。
3. 事件丢失、消息未读数异常、成员列表不一致：先确认设备投递、缓存和同步时序，再判断 SDK Bug。
4. 原生能力确实不存在时才 skip；原生存在但行为不一致时保留 active case 并记录 Bug。
