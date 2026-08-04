---
name: im-auto-test-case-design
description: 设计、实现或审查 native-auto-test 的 WebSocket API 用例与 Allure 报告。用于新增或改造 tests 下的普通/多端 case、规划 API 覆盖、收紧 response/event 断言，或让 passed、failed、skipped、broken 的业务步骤、原因和原始证据可读可追溯。
---

# 自动化用例与 Allure 可读性设计

仅用于测试侧工作。除非 Runner 未暴露被测能力，否则不要修改被测 App、Wrapper 或 SDK。

## 先阅读

1. 阅读 `native-auto-test/docs/agents/AGENTS.zh.md`；它是权威规范。
2. 阅读目标模块的 `docs/agents/<module>/CASES_RECORD.zh.md` 和 `CASES_DEFERRED.zh.md`。
3. 编写前检查 manager、cmd、事件 key、model、已有 helper 和相关 scenario。
4. 阅读 [references/topology-and-assertions.md](references/topology-and-assertions.md)，据此选择拓扑、断言和 Allure 呈现。

`docs/spec/CASES_SPEC.md` 已退役，仅可用于查看历史示例；不得覆盖当前 Agent 规范和框架行为。

## 设计用例

先明确 API、前置条件、动作、response、预期事件和稳定业务标识。新增 API 覆盖时，每个 API 至少设计一条正常路径和一条有业务意义的异常/边界路径。

先选端点形态，再选 fixture：

| Need | Design |
|---|---|
| 本地/查询 API | 一个逻辑端点；不要增加 topology。 |
| 跨账号命令且有回调 | 一个动作端，加上所需的对端。 |
| 消息投递、撤回、账号级回调传播 | 用 `@pytest.mark.topology(...)` 标记；通过 `topology.sender_action_device` 动作，并检查全部 `topology.recipient_devices`。 |
| 发送账号多端同步 | 不要默认启用。确认 SDK 预期行为后，单独创建拓扑和专项 case。 |

不要按固定数量的接收设备写 case。遍历 topology 的接收端，使同一 case 在该账号增加 Android、iOS、Web 或 Harmony 端时无需修改。

## 设计业务步骤与严格证据

- 发送的 `manager/cmd/info` 必须与权威 API/model 形状一致。
- 命令 response 和异步 event 分开断言：response 证明命令处理，event 证明回调投递。
- 用 `eventType` 和 `msgId`、`groupId`、发送者、接收者、操作等业务标识关联事件；不要假定 event 携带 `requestId`。
- 成功 response 和 event 的信封及关键字段使用 `assert_api.assert_response_matches`；错误使用冻结 `code`、`description` 的 `assert_api.assert_error`。
- 不得把实际结果当作 expected；不得忽略 `result` 或 `error`；`ignore_keys` 只保留已证实不稳定的字段。
- 将每个业务动作和每个业务验证包进独立 `allure.step`。步骤名必须写清“谁动作 / 做什么 / 验证什么”，例如：`接收端 device_a_sec 收到文本消息（onMessagesReceived）`、`确认消息已由 2 个在线端送达`。
- 将 response 断言放在“确认 <业务结果>”步骤内，将 event 断言放在“确认 <端点> 收到 <事件>”步骤内。失败必须落在实际失败的业务步骤，不能只落在泛化的“响应与预期比对”。
- 不要把内部队列清理、runner 元数据、REST 前置写成产品业务步骤。它们可以作为 setup/附件；若清理是稳定性前置，步骤名明确写“测试准备”，不要伪装成用户动作。
- 使用与具体设备/账号无关的步骤描述；遍历 topology 时，步骤名包含逻辑 role、平台/端点由框架参数展示。
- 每个命令、事件等待和断言保留 Allure JSON 附件：请求、实际响应/事件、预期、字段差异或等待期间已观察事件。附件用于诊断，步骤标题用于阅读。

## Allure 结果必须可解释

所有 case（包括普通单端 case）都遵循以下结果契约：

| 结果 | 必须呈现 | 禁止做法 |
|---|---|---|
| passed | 前置、动作、每个关键事件、关键结果均有业务步骤。 | 只显示一个笼统的断言步骤。 |
| failed | 失败步骤名说明哪个业务预期未满足；附预期、实际、字段差异、关联 ID 和已观察事件。 | 只抛“响应不一致”而不说明是哪个动作/回调。 |
| skipped | 明确显示跳过步骤与原因：能力/API、平台、SDK 版本、开关或外部前置；报告描述同步写出恢复条件。 | 仅让 pytest 显示 `Skipped: ...`，不写业务背景。 |
| broken | 标识为运行/基础设施故障：runner 注册、连接、登录、fixture、设备或未捕获异常；附 scenario、逻辑设备、平台、SDK、原始异常。 | 把基础设施错误伪装成业务失败或随意 skip。 |

- `skip` 只用于已确认不具备测试前置的能力/环境；使用 `pytest.skip` 前先写 Allure 步骤与附件。若原因是 feature option 未开启，写明 option 名和恢复条件。
- 业务 response 返回固定错误码时，它是 **failed 还是 passed** 取决于 case 目标：错误/边界 case 应严格断言该错误并 passed；正常路径收到错误必须在“确认 <cmd> 成功”步骤 failed，并附 `code/description`。
- 不要捕获未预期异常后改成 pass、skip 或模糊断言。让它成为 broken，并补充最靠近故障源的运行上下文。
- `xfail` 必须写明已知缺陷、复现条件和恢复条件；不能把未知失败标记为 xfail。

## 普通 case 的渐进改造

不要为了 Allure 可读性强行把单端/双端 case 变成 topology case。按以下顺序改造现有普通 case：

1. 先保留原有 fixture、API 语义和断言范围。
2. 为前置、命令、response、关键 event、最终查询分别补业务步骤和证据附件。
3. 把失败信息收紧到业务语言（API、事件、业务 ID、预期和实际），再运行原 case 回归。
4. 只有验收目标本身是“同账号所有在线端都应看到此消息/回调”时，才改为 topology；完成后同步多端清单。

不要用新增 `sleep`、放宽 `ignore_keys`、跳过事件或只取一条消息来换取报告好看；先说明并验证真实 API/事件语义。

## 多端与记录

topology case 依赖框架的拓扑附件展示端点平台和 SDK 版本。面向阅读者的步骤只写业务行为；原始 runner、账号、事件证据放在附件中。

多端送达回执按接收在线端计数：同一 `msgId` 的 `onMessagesDelivered.data.messages` 记录数必须等于目标账号在线端数量。不要写死为 1，也不要静默丢弃重复记录。

修改模块 case 覆盖后，更新对应 `CASES_RECORD.zh.md`；环境阻塞、未开启 option 或不稳定回调写入 `CASES_DEFERRED.zh.md`，不得靠放宽断言掩盖。

## 验证

默认仅运行修改的单条 case 或文件，并使用用户选择的 scenario。选择仓库命令前先检查 `Makefile`；保留用户已有的 pytest 调用方式，只有需要重新构建/安装 APK 时才使用 `--build`。验证 Allure 时至少检查：失败步骤是否准确、skip/broken 是否有原因和附件、topology 参数是否展示端点平台/SDK。最后执行 `AGENTS.zh.md` 要求的断言审查。
