# Group 模块 Agent 规范（设计与落地）

> 主入口与唯一总规范：`docs/agents/AGENTS.zh.md`
> 
> 本文件仅定义 Group 模块的落地边界、拆分方式与执行清单；若与总规范冲突，以 `AGENTS.zh.md` 为准。

## 1. 目标与范围

用于 Group 模块 cases 的全量重构与长期维护，覆盖：
- 正常链路：`createGroup`、`destroyGroup`、`getGroupWithId`、`getGroupSpecificationFromServer`、`addMembers`、`removeMembers`、`joinPublicGroup`、`leaveGroup`、`updateGroupSubject`、`updateDescription`、`blockMembers`、`unblockMembers`、`muteMembers`、`unMuteMembers`、`muteAllMembers`、`unMuteAllMembers`、`addWhiteList`、`removeWhiteList`、`updateGroupExt`。
- 异常链路：参数非法、对象不存在、权限不足、状态不满足等稳定可复现错误。

### 1.1 被测端 SDK options 前置约束（新增）
- 若 Group 某条 case 依赖被测端 SDK options（开关）状态，执行前必须先通知并与你确认。
- 当前 Group 用例默认基线：仅按 options=`true` 路径设计与断言；`false` 路径暂不覆盖（除非你明确要求）。
- 当前已知被测端开关基线：
  - `autoAcceptGroupInvitation: true`
  - `acceptInvitationAlways: true`
  - `deleteMessagesAsExitGroup: true`

## 2. 断言基线（强制）

严格采用 `docs/agents/AGENTS.zh.md` 第 4 节与第 8 节门禁要求：
- 成功主断言：`assert_api.assert_response_matches`，冻结 `manager/cmd/device` + 关键 `result` 字段。
- 失败主断言：`assert_api.assert_error(code=?, description=?)` 或固定错误体模板。
- 禁止裸 `assert_error(resp)`。
- 禁止 `ne(None)` 作为宽松主断言（除非返回语义本身就是空值）。
- 禁止自证式 result 断言、弱语义主断言。
- 事件主断言必须直接对 `receive_message(...)` 原始返回体做 `assert_response_matches`。
- 忽略集最小化：同步响应以 `sequence` 为基线；若存在明确不稳定字段（时间戳、动态 id、动态 url、端侧漂移辅助字段），可按 case 白名单最小补充。事件以时间类与 `sequence` 为基线，其他字段同样遵循白名单最小补充。

## 3. 文件拆分（按 API 语义）

`tests/group/` 目标结构：
- `group_helpers.py`
  - 建群/销群辅助
  - 群快照断言
  - 事件收集与逐条断言
  - 成员列表断言
- `test_group_lifecycle.py`
  - 正常：`create/destroy/get/getFromServer`
- `test_group_members.py`
  - 正常：`add/remove/join/leave`
- `test_group_metadata.py`
  - 正常：`updateGroupSubject/updateDescription`
- `test_group_moderation.py`
  - 正常 + 异常：`block/unblock/mute/unMute/muteAll/unMuteAll/addWhiteList/removeWhiteList/updateGroupExt`
- `test_group_exceptions_lifecycle.py`
  - 异常：生命周期相关
- `test_group_exceptions_members.py`
  - 异常：成员管理相关
- `test_group_exceptions_metadata.py`
  - 异常：元数据更新相关

## 4. 事件断言策略（严格且可复现）

### 4.1 收集策略
- 在“单次操作窗口”内收集候选事件，不允许“随机命中一个合法事件即通过”。
- 多回调场景：期望事件必须全部出现（以 `required_all_event_types` 为准），不采用“命中其一即可通过”策略。
- 单回调场景：以成功主断言为准，直接对原始事件响应使用 `assert_api.assert_response_matches` 进行严格断言。
- 支持回调顺序不稳定，但不放松事件集合与关键字段断言。

### 4.2 逐条断言策略
每条事件都要校验：
- envelope：`type=event`、`eventType`。
- `data`：必须存在且为 `dict`。
- `groupId`：按场景严格匹配（仅在确认该事件缺失 groupId 时允许白名单放宽）。
- 关键业务字段：按 `eventType` 断言（如 `inviter/member/groupName/allowList`）。

## 5. 用例矩阵（strict）

### 5.0 参数级覆盖要求（新增）
- 每个 Group API 的 case 设计必须覆盖参数维度，不仅是“接口级正常/异常”。
- 对于可选参数：至少覆盖“未传/空值/合法值”中的关键组合。
- 对于对象参数：必须展开到子字段维度（如 `options`）。
- 覆盖优先级：先稳定可复现参数，再补环境相关参数（如 URL 可达性、端能力差异）。

#### createGroup 参数矩阵（按 Flutter `group_manager.dart` 与官方文档）
- 入参：`groupName`、`avatarUrl`、`desc`、`inviteMembers`、`inviteReason`、`options`（`EMGroupOptions`）。
- 参数级 case 设计要求：
- `groupName`
  - 合法名称（默认）
  - 空字符串
  - 超长字符串（边界）
  - 特殊字符/多语言字符
- `avatarUrl`
  - 未传
  - 合法 URL
  - 非法 URL/空串
- `desc`
  - 合法描述（默认）
  - 空字符串
  - 超长描述（边界）
- `inviteMembers`
  - 空列表
  - 单成员
  - 多成员
  - 包含不存在用户
  - 包含重复用户（若端侧可返回稳定语义则冻结）
- `inviteReason`
  - 未传/空字符串
  - 合法文案
  - 超长文案（边界）
- `options`（子字段展开）
  - `style`：私有/公开（至少覆盖 0/1）
  - `maxCount`：默认值、最小值、超范围值（可稳定返回时）
  - `inviteNeedConfirm`：`true/false`
  - `ext`：空串、合法值、超长值（可稳定返回时）

## 5.1 lifecycle
- 正常：
  - `createGroup` 成功 + 回调断言
  - `destroyGroup` 成功 + 回调断言
  - `getGroupWithId` 本地详情
  - `getGroupSpecificationFromServer` 服务端详情
- 异常（多条）：
  - `createGroup` 空/非法参数
  - `destroyGroup` 空/不存在 groupId
  - `getGroupWithId` 空/不存在 groupId
  - `getGroupSpecificationFromServer` 空/不存在 groupId

## 5.2 members
- 正常：
  - `addMembers` 成功 + 回调断言 + 服务端成员校验
  - `removeMembers` 成功 + 回调断言 + 服务端成员校验
  - `joinPublicGroup` 成功 + 回调断言（环境支持时）
  - `leaveGroup` 成功 + 回调断言
- 异常（多条）：
  - `addMembers` 空 members / 不存在用户 / 无权限
  - `removeMembers` 非成员 / 不存在用户 / 无权限
  - `joinPublicGroup` 不存在群 / 条件不满足
  - `leaveGroup` 非成员退群

## 5.3 metadata
- 正常：
  - `updateGroupSubject` 更新后本地/服务端一致
  - `updateDescription` 更新后本地/服务端一致
- 异常（多条）：
  - 空值、超长值
  - 不存在群
  - 无权限修改

## 6. 实施步骤（分阶段）

1. 先抽 `group_helpers.py`（不改语义）。
2. 拆正常用例文件并逐文件回归。
3. 拆异常用例文件；每条异常先 discovery，再 strict 冻结错误码与文案。
4. 更新 `docs/agents/group/CASES_RECORD.zh.md`（按 API 记录正常/异常）与 `docs/agents/group/CASES_DEFERRED.zh.md`（暂缓/阻塞）。

## 7. 执行与回归命令

- 单例发现：
  - `CASES_DISCOVER=1 WS_DEBUG=1 pytest -q tests/group/<file>.py::<case> -s`
- 严格单例：
  - `pytest -q tests/group/<file>.py::<case> -s`
- 严格文件：
  - `pytest -q tests/group/<file>.py -s`
- 严格模块：
  - `pytest -q tests/group -s`
- 全量（仅明确要求时）：
  - `pytest -q tests -s`

## 8. 评审清单（模块门禁）

- [ ] 成功主断言均为 `assert_response_matches`，并冻结关键业务字段。
- [ ] 失败主断言均为 `assert_error(code, description)` 或固定错误体。
- [ ] 无 `ne(None)` 宽松主断言（除语义允许的空值）。
- [ ] 事件断言均直接断言原始事件响应。
- [ ] 同步响应 `ignore_keys` 以 `sequence` 为基线；新增忽略项必须有“明确不稳定性”依据（如时间戳/动态 id/url/端侧漂移字段）且保持最小化。
- [ ] 事件响应 `ignore_keys` 以时间类（`timestamp/serverTime/localTime`）与 `sequence` 为基线；额外忽略项必须走白名单并说明理由。
- [ ] 多回调场景必须全部出现并逐条通过断言；单回调场景以 `assert_response_matches` 主断言通过为准。
- [ ] 回归后同步更新 `CASES_RECORD.zh.md` 与 `CASES_DEFERRED.zh.md`。
