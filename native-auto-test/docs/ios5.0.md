# iOS 5.0 适配记录

本文只记录 iOS 5.0 原生 SDK 与 Android 5.0/当前测试协议的差异。

原则：Wrapper 透传原生结果；测试 case 保持业务断言，不为了 pass 把 iOS 返回值改成 Android 返回值。下表中的“Bug/差异”在原生修复或确认前保留失败，不改成平台分支绕过。

## Group

### 错误结果/空结果差异

| Case | Android 5.0 预期/实测 | iOS 5.0 实测 | 判定 |
|---|---|---|---|
| `test_group_create_group_max_count_less_than_invite_members` | `604 / The group member capacity is reached` | 创建成功，`maxUserCount=3`，`memberCount=3` | iOS 原生参数归一化差异；应修 SDK/确认协议 |
| `test_group_create_group_desc_reason_options_abnormal_inputs[options_max_count_zero-*]` | `110 / maxUsers should be greater than 0` | 创建成功，`maxUserCount=3` | iOS 原生未按 Android 校验非正 maxCount |
| `test_group_create_group_desc_reason_options_abnormal_inputs[options_max_count_negative-*]` | `110 / maxUsers should be greater than 0` | 创建成功，`maxUserCount=3` | 同上 |
| `test_group_public_open_join_rejects_when_group_is_full` | `maxCount=2` 时 A+B 已满，C 加入返回 `604` | iOS 将容量归一化为 `3`，C 可以加入 | 同一组容量归一化差异；不新增 D 用户绕过，不修改 case 预期 |
| `test_group_get_group_from_server_nonexistent` | `600 / do not find this group` | `result=null` | iOS 原生未返回错误对象 |
| `test_group_get_group_from_server_after_destroy` | `600 / do not find this group` | `result=null` | iOS 原生未返回错误对象 |
| `test_group_download_shared_file_nonexistent_group_current_behavior` | `600 / do not find this group` | `result=null` | iOS 原生未返回错误对象 |

以上 7 个 case 当前不改断言、不在 iOS Wrapper 中伪造错误码；需要 SDK/服务端确认并修复。

其中前 3 个和满员 case 都属于 `maxCount` 参数归一化问题：iOS 5.0 当前把过小、0 或负数容量按最小容量 `3` 处理。测试仍以 Android 5.0 的业务契约为基准，保留原始输入和错误预期，避免通过增加第四个用户或改成 `maxCount=3` 掩盖差异。

### 其他 Group 差异

| 类型 | iOS 5.0 实测 | 处理 |
|---|---|---|
| 成员属性空参数 | `110` | Android 为 `205`；原生参数校验差异，不能随意改 case |
| `style=3` / 公开免审核群入群 | 请求成功并自动入群 | 与 4.x 的 `603` 预期不同；这是 5.0 三布尔语义变化，不是普通错误码差异 |
| 群详情成员列表 | `memberList` 与 `adminList` 的组合可能受原生缓存/操作阶段影响 | 完整成员校验使用 `getGroupMemberListFromServer`，管理员单独校验 |

## Chat

### 动态字段

`status`、`fileStatus`、`thumbnailStatus`、`fileSize` 受发送/同步/下载阶段影响，Android 与 iOS 可能不同。局部媒体字段不固定断言，但继续严格校验 msgId、消息类型、正文、错误码和关键事件；不在 Wrapper 中构造状态值。

### 原生能力/错误差异

消息编辑、历史消息、会话查库、Reaction 边界等失败，先按 iOS 原生结果记录，不把 Android 错误码或成功结果写入 iOS 预期。`modifyMessage` 返回 `305 / Sorry, edit is not available` 时，优先确认 AppKey/服务端能力。

## ChatRoom

| 类型 | iOS 5.0 实测 |
|---|---|
| 加入不存在聊天室 | `303 / Unknown server error`，不是 4.x 的 `705` |
| 空属性 map | `303 / Unknown server error`，不是 Android 的 `110` |
| 成员/退出事件 | 目标成员事件可能不稳定；保留目标成员和目标 ext 的严格匹配 |

## Push

`updateFCMPushToken` 不是 Android-only：

- Android 未配置 FCM notifier：`110 / Notifier name should not be empty!`
- iOS 未配置 APNs cert：`205 / Apns cert name is NULL`

这是两端原生配置/错误码差异，不能在 iOS Wrapper 中改成 `110`。`updateAPNsPushToken` 的 Android MissingPlugin 用例仍是平台独有能力。

## UserInfo

`fetchUserInfoById` 传空 `userIds`：Android 原生返回 `205 / userIds is empty`；iOS 5.0 实测成功返回空结果。该差异需要确认 iOS 原生校验策略，不能把空结果当作有效用户信息查询成功。

## 维护规则

1. 原生返回什么，先记录什么；不要为了跨端 pass 在 Wrapper 中伪造结果。
2. 错误码一致但文案大小写不同：只断言错误码；错误码不同：记录平台差异，不直接放宽成任意值。
3. 事件丢失、消息未读数异常、成员列表不一致：先确认设备投递、缓存和同步时序，再判断 SDK Bug。
4. 原生能力确实不存在时才 skip；原生存在但行为不一致时保留 active case 并记录 Bug。
