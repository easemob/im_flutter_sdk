# ChatRoom 模块 Cases 暂缓清单（按 API）

— 说明
- 本文件仅记录“暂缓实现 / 暂不收紧 / 环境阻塞”的 ChatRoom 项目。

## createChatRoom

- 暂缓项 1：SDK 直接创建聊天室的完整正向链路
  - 原因：官方前提要求超级管理员身份；当前普通 session 用户直调 SDK `createChatRoom` 实测返回 `code=703`、`description=you have no permission to do this.`，已补充异常 case 冻结该语义，正向链路继续以 REST 预创建作为前置。
  - 前置条件：确认被测端支持以当前 session 用户直接创建聊天室，或提供 super-admin 前置。
  - 恢复条件：前置可用后补齐 SDK 直接创建 case。

- 暂缓项 2（已解除）：REST 预创建聊天室权限阻塞
  - 原因：旧 token 对 `/chatrooms` 无授权（401）。
  - 处理：已更新 `config.yaml -> rest_api.auth_token` 并按实测 `curl` 字段(`name/maxusers/owner/members/roles`) 对齐。
  - 当前状态：阻塞解除，`tests/chatroom/` 严格模式已通过。

## joinChatRoom

- 暂缓项 1：join 不存在 roomId 的产品语义确认
  - 实测现象：`test_chatroom_join_room_nonexistent_current_behavior` 中，随机不存在 roomId 调用 `joinChatRoom` 返回成功 `result=1`，未返回错误。
  - 风险：该行为与“无效聊天室应报错”直觉不一致，可能是服务端容错或房间自动创建/映射策略。
  - 恢复条件：待产品/服务端确认后，决定保留成功语义或改为错误语义并收紧断言。

- 暂缓项 2：加入失败异常矩阵扩展
  - 原因：当前已覆盖空 roomId 异常；其余失败场景（重复加入、权限不足、封禁/白名单）需可控环境。
  - 前置条件：提供对应环境开关与账号角色。
  - 恢复条件：前置就绪后按 API 参数维度补齐。

## fetchPublicChatRoomsFromServer

- 暂缓项：分页语义规范确认（非法分页参数）
  - 实测现象：`pageNum<=0` 或 `pageSize<=0` 仍返回成功列表结构，而非错误码。
  - 前置条件：确认 SDK/服务端对非法分页入参的最终规范（容错返回 vs 抛错）。
  - 恢复条件：规范确定后，调整异常用例归属（保留在异常用例或迁移到容错行为用例）。

## ChatRoom 回调事件

- 暂缓项：成员加入回调 `onMemberJoinedFromChatRoom` 的加入方 ext 透传
  - 实测现象：`joinChatRoom` 携带 ext 同步返回聊天室对象，但观察端与加入方均未收到 `onMemberJoinedFromChatRoom`；当前用例已标记 xfail，避免把未派发回调当作 SDK 成功语义。
  - 前置条件：确认 SDK/服务端是否应派发聊天室成员加入事件，尤其是携带 ext 时是否需要广播给其他在线成员。
  - 恢复条件：事件可稳定派发后，将 `test_chatroom_join_with_ext_member_joined_callback` 去掉 xfail 并按真实事件体收紧断言。

- 暂缓项：公告变更回调 `onAnnouncementChangedFromChatRoom` / `onRoomAnnouncementChanged`
  - 实测现象：B 已加入聊天室且 `updateChatRoomAnnouncement` 返回 `result=true` 后，A/B 两端均未收到公告变更回调；当前用例已标记 xfail，避免误判整套回调回归。
  - 前置条件：确认 SDK/服务端是否应派发聊天室公告变更事件，或确认仅同步接口与 `fetchChatRoomAnnouncement` 可验证公告更新。
  - 恢复条件：事件可稳定派发后，将 `test_chatroom_announcement_changed_callback` 去掉 xfail 并按真实事件体收紧断言。
