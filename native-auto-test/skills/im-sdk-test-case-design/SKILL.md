---
name: im-sdk-test-case-design
description: 设计、实现或审查 IM SDK 的 native-auto-test 用例。用于判断普通 API 与多端拓扑 Case、补齐 API/回调覆盖、编写跨平台必要字段断言，以及让 Allure 的描述、设备参数、业务步骤和 passed/failed/skipped/broken 证据清晰可追溯。
---

# IM SDK 自动化用例设计

仅用于测试侧工作。除非 Runner 未暴露被测能力，否则不要修改被测 App、Wrapper 或 SDK。

## 先阅读

1. 阅读 `native-auto-test/docs/agents/AGENTS.zh.md`；它是权威规范。
2. 阅读目标模块的 `docs/agents/<module>/CASES_RECORD.zh.md` 和 `CASES_DEFERRED.zh.md`。
3. 检查 manager、cmd、事件 key、model、已有 helper 和相关 scenario。
4. 阅读 [references/topology-and-assertions.md](references/topology-and-assertions.md)。

## 先写设计卡

实现前，用不超过六行明确：

1. 被测 `manager/cmd`、前置条件和业务目标。
2. Case 类型：普通 API 或多端拓扑；说明原因。
3. 动作账号/动作端，以及需要观察的账号端点。
4. response 的必要字段和 event 的业务关联键（如 `msgId`、`groupId`）。
5. 正常、错误或边界的通过条件。
6. Allure 中读者应看到的业务步骤。

语义不明确、原生回调形状未知或平台能力未声明时，先 discovery；不要猜测字段或用忽略字段掩盖问题。

## 选择 Case 类型

每个 API 至少规划一条正常路径和一条有业务意义的错误/边界路径。先选 Case 类型，再写 fixture：

| 被测目标 | 选择 |
|---|---|
| 参数边界、固定错误码、纯查询、单端配置/登录 | 普通 API Case；只声明实际需要的 device fixture。 |
| 消息投递、已读、撤回、reaction、账号级同步或“在线端都应收到” | 多端拓扑 Case；使用 `@pytest.mark.topology(...)` 和 `topology` fixture。 |
| API 只影响当前端，但需要另一账号作为前置 | 普通双端 Case；不要为了设备数量改 topology。 |
| 平台专属能力 | 平台专项 Case；在描述和 skip 中写明平台、SDK 与恢复条件。 |

多端 Case 必须遍历 `topology.sender_devices` 与 `topology.recipient_devices` 中和业务语义相关的端点；不得写死“两个接收端”。同一 Case 在 scenario 增加 Android、iOS、Web、Harmony 端时无需修改。

- 消息投递：动作发送端发送；发送账号其他在线端同步/落库；接收账号全部端接收/落库；送达记录数等于接收账号在线端数。
- 已读、撤回、reaction：先完成消息投递，再按 API 语义检查相关账号的全部在线端回调。
- 发送端多端不是多 sender：通常只有 `sender_action_device` 调用 API；其他发送账号端用于验证同步或回调。

### 离线多端 Case 固定写法

- 离线前按账号下线：遍历 `topology.sender_devices` 或 `topology.recipient_devices`，不要只调用 `logout_for_offline(device_a/device_b)`。
- 恢复时也按 endpoint 逐台调用 `login_preserving_offline_events`；每台设备的离线事件队列独立消费，不能用动作端收到事件代表副端也收到。
- API 动作只在 `sender_action_device` 或 `recipient_action_device` 执行一次，避免副端重复 accept/decline/remove 等业务动作。
- 对账号级离线回放事件，按 SDK 语义在每个重新登录 endpoint 上用 `groupId`/`msgId` 等业务键等待并断言；如果事件是一次性动作结果，则其他 endpoint 至少验证相同的最终本地/服务端状态，不重复执行动作。
- `finally` 必须恢复两个账号的全部 endpoint，并恢复自动接受邀请等账号/客户端选项；清理不能只恢复 `deviceA/deviceB`。
- 统一从 topology 取 `action_device`、`*_devices` 和用户 ID；不得在离线 Case 中写死 `deviceA/deviceB/deviceASec/deviceBSec`。
- 只有整个文件的所有 Case 都使用同一个 topology 时才把 marker 放入模块级 `pytestmark`；混合普通 API 与拓扑 Case 时，marker 放在具体函数前，避免无关 Case 启动全部设备。

## 实现断言与业务步骤

- 请求 `manager/cmd/info` 必须与权威 API/model 一致。
- response 与异步 event 分开验证：response 证明命令被处理；event 证明 SDK 发生回调。
- 使用 `msgId`、`groupId`、用户、操作类型等业务键关联事件；不要假设 event 带 `requestId`。
- `expected` 仅写当前 Case 的必要业务字段。默认允许平台额外字段；必要字段缺失或值不一致必须失败。只有平台专项完整结构验收时才用 `allow_extra_fields=False`。
- 错误/边界 Case 冻结 `code` 与 `description`；不得把实际结果当作 expected，不得忽略 `result` 或错误码。
- `ignore_keys` 仅用于已证实的波动字段或“存在但值不验”的字段；不把它当作跨平台适配手段。
- 每个业务动作和业务验证写独立 `allure.step`。标题写清“谁 / 做什么 / 验证什么”。
- 事件等待是内部机制；不要在报告中另写“收到回调”再写“校验回调”。将等待、关联和断言放在同一个业务验证步骤中。
- `device.call()` 与断言工具自动附请求、实际值、预期值、字段差异；Case 不重复添加同类技术步骤。
- 不要把队列清理、runner 元数据、REST 前置伪装成产品业务步骤；必要时命名为“测试准备”。

## Allure 结果必须可解释

| 结果 | 必须呈现 | 禁止做法 |
|---|---|---|
| passed | docstring、框架参数、动作、关键事件验证、最终结果均可读。 | 只显示笼统断言步骤。 |
| failed | 失败步骤说明哪个业务预期未满足；附预期、实际、字段差异、关联 ID 和已观察事件。 | 只抛“响应不一致”。 |
| skipped | 跳过原因：能力/API、平台、SDK、开关或外部前置；写恢复条件。 | 只显示 pytest 的 `Skipped`。 |
| broken | runner、连接、登录、fixture、设备或未捕获异常；附运行上下文与原始异常。 | 伪装成业务失败或随意 skip。 |

- 普通 Case 的报告参数由框架展示场景、发送/接收账号与端点平台/SDK；拓扑 Case 额外展示动作端、发送端和接收端。不要添加 runner ID、成功 capability 等技术参数。
- 业务 response 返回固定错误码时，是否通过取决于 Case 目标：错误/边界 Case 应严格断言并 passed；正常路径收到错误必须在“确认成功”步骤 failed。
- 不要捕获未预期异常后改成 pass、skip 或模糊断言。让它成为 broken，并补充靠近故障源的运行上下文。

## 改造现有 Case

1. 保留原有 API 语义和断言范围，先补 docstring、业务步骤和证据附件。
2. 将失败信息收紧到业务语言：API、事件、业务 ID、预期与实际。
3. 只有验收目标是“同账号所有在线端都应看到消息/回调”时，改为 topology。
4. 不用新增 `sleep`、放宽 `ignore_keys`、跳过事件或只取一条消息换取通过；先确认真实 API/事件语义。

修改模块覆盖后，更新 `CASES_RECORD.zh.md`；环境阻塞、未开 option 或不稳定回调写入 `CASES_DEFERRED.zh.md`。

## 验证与交付

默认仅运行修改的单条 Case 或文件，并使用用户选择的 scenario。保留用户已有的 pytest 调用方式；仅 SDK/测试 App 代码变更才构建/安装 APK，Python Case 改动不构建。

- [ ] 已选择普通 API 或多端拓扑，并符合业务语义。
- [ ] 多端 Case 未写死设备数量，已遍历相关 topology 端点。
- [ ] docstring、Allure 参数、业务步骤对阅读者可读。
- [ ] response/event 的必要字段、关联 ID、错误码均已验证。
- [ ] failed、skipped、broken 能定位到真实业务或基础设施原因。
- [ ] 仅回归本次受影响 Case，并检查新生成的 Allure results。
- [ ] 已更新对应模块的 Case 记录。
