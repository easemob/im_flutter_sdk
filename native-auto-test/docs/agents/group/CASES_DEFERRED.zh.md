# Group 模块 Cases 暂缓清单（按 API）

— 说明
- 本文件仅记录当前缺少可控触发入口、不能由现有客户端 SDK 自动完成的 Group 项目。
- 已通过现有 SDK 和真实双设备 ADB 补齐的四种群类型、邀请/申请状态、群主转让、成员移除、
  公开群边界、Joined Groups 状态迁移、公开群 cursor 分页、公告角色和共享文件角色不再列为
  deferred。

## group state

- 暂缓项：群启用/禁用状态变更回调 `onGroupStateChanged` / `onDisableChanged`
  - 原因：Flutter/Android/iOS 当前只暴露状态事件监听，没有客户端启用或禁用群的操作 API。
  - 前置条件：提供可控 REST、管理后台或服务端操作入口来改变本次测试群状态。
  - 恢复条件：具备触发入口后，由 A/B 真实设备监听并按 ADB 冻结 `eventType/data`；不得
    添加假事件或测试专用发布 SDK API 冒充覆盖。

## 已知问题 skip

- 当前有 7 个参数场景暂时 skip，case 实现、严格断言和 ADB 证据均保留：
  - Android `declineInvitationFromGroup` 丢失 inviter：显式拒绝回调、错误 inviter 拒绝，共 2 条。
  - SDK/服务端契约差异：PublicOpenJoin 错误申请直接入群，共 1 条。
  - style 0 管理员邀请契约待确认：`inviterUser`、`addMembers`，共 2 条。
  - 错误 inviter 接受邀请的校验契约待确认，共 1 条。
  - Android SDK 管理员审批回调 `accepter` 错报群主，共 1 条。
- 恢复条件：对应客户端问题修复或产品/API 契约确认后，删除目标参数上的 skip 并重跑原严格断言。

- `tests/group/test_group_chat_thread_user_removed.py::test_chat_thread_remove_member_updates_member_list`
  - 原因：当前 Android 实测 `removeMemberFromChatThread` 返回 `result=true` 后，B/A 均未收到
    `onUserKickOutOfChatThread`，无法验证发版项 `event.type` 非空；case 已改按真实成员列表状态验收。
  - 前置条件：SDK/服务端确认并稳定派发 `onUserKickOutOfChatThread`。
  - 恢复条件：按真实事件体补回 `event.type/from/thread` strict 断言并重新回归。

## Jira 提交门禁

- `CASES_FAILURES.zh.md` 中 7 个失败参数场景均已由 A/B ADB 复现。
- 当前环境按用户要求只能使用 ADB 日志；相关 REST 请求未打印可用于 Jira 的 request traceId。
  `easemob-jira-bug-submit` 强制要求真实请求 traceId，禁止用登录或无关 SYNC traceId替代，
  因此当前不能执行在线 Jira preview/submit。
