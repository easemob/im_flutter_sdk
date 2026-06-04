# Group 模块 Cases 暂缓清单（按 API）

— 说明
- 本文件仅记录“暂缓实现 / 暂不收紧 / 环境阻塞”的 Group 项目。
- 每条按 API 归类，并写明原因、前置条件、恢复条件。

## createGroup

- 暂缓项：`options=false` 路径相关 cases
  - 原因：当前被测端基线仅覆盖 options=`true` 路径。
  - 前置条件：需要你确认并切换被测端 SDK options。
  - 恢复条件：收到你明确指令后补齐并冻结 strict 断言。

## joinPublicGroup / leaveGroup

- 暂缓项：成功语义链路（正常成功 case）
  - 原因：当前环境稳定返回权限错误（603），暂不具备成功链路前置。
  - 前置条件：被测端/服务端开放可加入公开群的权限路径。
  - 恢复条件：环境支持成功路径后补充正常 case 并保留现有异常 case。

## getJoinedGroups / getJoinedGroupsFromServer

- 暂缓项：本地/服务端“深度一致性专项”
  - 原因：当前已完成基础存在性与结构断言，但尚未覆盖跨端多轮状态迁移一致性（如加/退群后的同步时序）。
  - 前置条件：明确进入“列表一致性专项”，允许增加多步骤链路与必要等待窗口。
  - 恢复条件：专项启动后按 API 拆正常/异常并冻结更细粒度一致性断言。

## getPublicGroupsFromServer

- 暂缓项：分页游标翻页专项（cursor 驱动多页一致性）
  - 原因：本轮已覆盖 pageNum/pageSize 参数维度与返回结构，未展开 cursor 连续翻页一致性。
  - 前置条件：明确要求分页专项，并固定可复现的公开群数据基线。
  - 恢复条件：专项启动后补充“cursor 非空继续翻页、cursor 为空停止”的 strict 断言链路。

## updateGroupAnnouncement

- 暂缓项：回调事件 `onGroupAnnouncementChanged` 严格校验
  - 原因：当前环境实测更新公告后未稳定收到该回调；API 同步返回与公告拉取语义已稳定。
  - 前置条件：被测端确认并恢复该回调下发（或提供当前版本的公告回调事件名）。
- 恢复条件：事件稳定后补充正常用例中的回调主断言，并冻结 `eventType/data` 关键字段。
