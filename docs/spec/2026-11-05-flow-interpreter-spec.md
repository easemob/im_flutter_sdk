# 多设备测试控制流解释器规格（YAML 流程语言）

- 日期：2026-11-05
- 状态：核心决策已确认（设备启动边界、目录组织、失败跳过语义），遗留一个事件命名决策点（§13 Q1）；未实现，未设备验证。
- 工作对象：`im_flutter_sdk/.worktree/5.0.0`，分支 `5.0.0`。
- 关联文档：
  - 总体规格：[Example 测试脚本与工具体系规格](2026-11-04-example-testing-spec.md)
  - HTTP 协议草案：[设备命令、状态与事件接口](../../testing/spec/2026-11-04-phase-control.md)（本文引用其接口，不重新定义）
- 路径约定：仓库内相对路径以 `5.0.0` 工作树根目录为基准。

## 1. 背景与定位

单设备测试已经通过 JSON 命令脚本 + AutoMode 执行器跑通：脚本描述"API 调用序列 + 参数引用 + 返回值断言"，example 真实执行。这是顺序模型——一个账号、一条时间线、每步断言主动调用的返回值。

多设备协同用例（如"A 发群消息 → B 收到 → B 已读 → A 收到回执"）引入三个单线模型表达不了的语义：并行（多条设备执行线）、事件等待（被动方等回调而非主动调用的返回值）、跨设备数据流（B 引用 A 产生的东西）。

曾考虑 AI 主代理编排子代理实现，已否决：AI 适合不确定任务，确定性流程应交给程序；且 AI 参与引入成本与不可重复性，回归测试恰恰要求每次执行完全一致。

本工具是一个**通用控制流解释器**：YAML 描述控制流（树），JSON 命令是叶子；解释器只认识"命令"与"结果"两个抽象，不认识任何 IM 业务概念。它在架构上取代此前草案中"AI 主代理"的编排职能；设备侧 HTTP 协议沿用 phase-control 草案，不因本文变更。

## 2. 设计原则与最小契约

核心原则（讨论已确认）：

1. **工具通用，不掺业务**。解释器不知道 `sendMessage` 是什么，它调度的是不透明命令单元。
2. **YAML 对 JSON 命令格式无任何要求**。不做 schema 校验、不理解字段含义。
3. **YAML 只负责流程**：顺序、循环、分支、比较运算；第一版不要求复杂嵌套。

"完全不关注"有一条必须显式化的边界：控制流需要引用命令执行结果（比较运算的操作数、后续命令的输入）。因此约定两个**最小契约**，这是 YAML 与 JSON 之间仅有的接口：

| 契约 | 内容 | 说明 |
|---|---|---|
| 输出信封 | 每条命令执行完毕返回 `{success, status, data, error}` | `status ∈ ok \| error \| timeout`；`data` 内部结构解释器不解析，仅按 path 寻址。现有 AutoMode 结果已是此形状，契约事实上已存在 |
| 输入注入 | 命令可接收外部输入（inputs），值由解释器从流程变量解析 | 注入点由设备脚本声明（phase-control 的 stage inputs 机制），解释器只传值，不改写命令内部结构 |

信封是对"命令"这个抽象的要求，不是对 JSON 格式的要求——两者不矛盾。

## 3. 总体架构

```text
宿主机
┌────────────────────────────────────────────┐
│ flow_runner（纯 Dart CLI，无 Flutter 依赖） │
│  YAML 解析 → AST → 解释执行                  │
│  控制流：顺序 / parallel / if / for / while  │
│  表达式求值、变量表、barrier、超时、报告      │
└──────┬─────────────────────┬───────────────┘
       │ HTTP（phase-control）│
┌──────▼──────┐        ┌──────▼──────┐
│ agent alice │        │ agent bob   │   example app 内嵌 HttpServer
│ iOS 模拟器  │        │ Android 模拟│   session 绑定 / 命令执行 / 事件缓存
└─────────────┘        └─────────────┘
```

职责边界：

- **解释器（flow_runner）**：读 YAML 流程 + 各 agent 的设备脚本；启动时绑定 session；按控制流派发命令、等待事件；维护全局变量表与各 agent 事件游标；产出报告。
- **agent（example 内 HTTP 服务）**：执行命令、返回信封；缓存带 seq 的事件流。实现按 phase-control 草案。
- **设备启动（模拟器、app 构建安装、端口转发）**：**不在解释器内**（2026-11-05 确认）。外部脚本（Makefile / shell）先把模拟器和 app 起好，解释器只连接已就绪的 endpoint。理由：启动是重操作且已有工具链，解释器保持纯控制流。

HTTP 调用映射（全部复用 phase-control，不新增接口）：

| 流程动作 | HTTP |
|---|---|
| 流程启动 | 各 agent `POST /v1/session`（绑定设备脚本） |
| 执行命令 | `POST /v1/commands` → 轮询 `GET /v1/commands/<id>` 至终态 |
| 等待事件 | 轮询 `GET /v1/events?afterSeq=...&waitMs=1000`，按 match 匹配 |
| 流程结束 | 各 agent `POST /v1/session/finish` |

## 4. YAML 流程语言

### 4.1 顶层结构

```yaml
version: 1
name: group-read-receipt        # 用例名，进报告
runId: auto                     # 缺省按时间戳生成

agents:                         # 角色 → 设备 endpoint 映射
  alice:
    endpoint: http://127.0.0.1:8801
    script: scripts/alice_device.json    # 该 agent 绑定的设备脚本（含命令定义）
    meta: {device: ios-sim-a}            # 仅供人和启动工具参考，解释器不使用
  bob:
    endpoint: http://127.0.0.1:8802
    script: scripts/bob_device.json

defaults:
  stepTimeoutMs: 30000
  onFail: continue              # 步骤失败默认策略
  skipOnFailedDeps: true        # 引用失败来源变量的命令默认跳过（步骤级可覆盖）

steps: [ ... ]                  # 顶层流程，默认顺序执行
```

`agents` 的 key 是**角色名**（alice/bob），报告和变量引用都用角色名，不直接暴露设备概念。

### 4.2 步骤类型（step kinds）

| kind | 作用 | 关键字段 |
|---|---|---|
| `cmd` | 在指定 agent 执行一条命令 | `cmd`（命令 id）、`agent`、`inputs`（可选）、`as`（结果绑定变量名）、`timeoutMs`、`onFail`、`skipOnFailedDeps`（可选，覆盖全局跳过设置） |
| `parallel` | 多分支并行，全部分支到达终点（成功或失败）才继续 | 分支为命名 map：`分支名: [子步骤序列]` |
| `wait_event` | 在指定 agent 等待一条匹配事件 | 主值为事件名（SDK 回调方法名）、`agent`、`match`（匹配条件 map）、`as`、`timeoutMs` |
| `barrier` | 同一 parallel 块内的分支在此互相等待 | 主值为 barrier 名 |
| `if` | 条件分支 | 主值为表达式、`then: [步骤]`、`else: [步骤]`（可省） |
| `for` | 循环 | 主值为 `x in $list`（遍历数组）或 `i in 1..5`（范围）；`do: [步骤]` |
| `while` | 条件循环 | 主值为表达式、`do: [步骤]` |
| `set` | 设置变量 | 主值为赋值 map：`{变量名: 值或引用}` |
| `delay` | 等待 | 主值为毫秒数 |

统一语法形态：每个步骤是 `- <kind>: <主值>` 加同级附加字段（如 `- cmd: send_msg` + 同级 `agent`/`inputs`）。`parallel` 的主值为分支 map：`分支名: [子步骤序列]`。

约束：第一版 `parallel` 分支内**不允许再嵌 `parallel`**（"没有复杂嵌套"的决策落地）；其余步骤可在任何序列内使用。

### 4.3 表达式（比较运算）

`if` / `while` / `match` 中的值使用统一表达式语法，够用即可、不做图灵完备：

```text
expr    := and_expr ( 'or' and_expr )*
and_expr := not_expr ( 'and' not_expr )*
not_expr := 'not' not_expr | comparison
comparison := operand ( ('=='|'!='|'>'|'>='|'<'|'<=') operand )?    # 比较可省略，即布尔引用
operand := literal | reference
literal := 数字 | '单引号字符串' | true | false | null
reference := '$' name ( '.' (字段名 | 数字下标) )*                  # 如 $msg_a.data.msgId
```

求值规则：

- 引用即对变量表做 path 寻址（与现有 AutoMode `_dig` 同语义）；路径不存在返回 null，**不报错**。
- 比较宽松模式：跨类型 `==` 为 false；`null == null` 为 true；`>`/`<` 仅数字与字符串各自内部有效，跨类型为 false。宽松失败记入日志，不中断。
- 保留字引用：`$agents` 为内置变量（各 agent 会话信息，如 `$agents.bob.userId`，来自握手 info），解释器自己的元数据，不属于业务。

### 4.4 变量与作用域

- `as: <name>` 把命令信封或匹配到的事件绑定到 `<name>`；事件绑定的是事件 payload。
- 变量表默认**全局**（流程级共享，跨 agent 可见——这是跨设备数据流的载体）；`for` 的循环变量在其 `do` 块内遮蔽同名全局变量。
- 并行分支写同名变量为未定义行为，静态检查给出 warning，不阻止执行。

## 5. 并发与同步语义（决策落地）

- **顺序**：默认。`steps` 逐个执行，上一步完成（含失败按 onFail 处理完）才进下一步。
- **并行**：`parallel` 块内每条分支是一条独立执行线（Dart async 协程），互不阻塞；块语义为 **join-all**：等所有分支结束（无论成败）后才继续后续步骤。分支失败不中断兄弟分支（见 §8）。
- **同步点**：`barrier`。同一 parallel 块内的多条分支执行到同名 barrier 时互相等待，全部到达后放行。用于"双方就绪后再开始交互"的时序，替代盲目 delay。
- 命令级不提供 fire-and-forget：`cmd` 总是等待信封返回（或超时）。"A 发消息不等结果、先去等回执"的场景不存在——发送本身是请求-响应，回执是事件，两者由 §6 的事件机制天然解耦。

## 6. 回调与监听（决策落地）

两类语义严格区分：

| | 回调（callback） | 监听（listener） |
|---|---|---|
| 触发 | 命令引发的 SDK 异步结果 | SDK 长周期自发推送（如 onMessageReceived） |
| 模型 | 请求-响应，一次 | 持续事件流，多次 |
| 解释器行为 | `cmd` 等待信封 | `wait_event` 从事件流中匹配一条 |
| 载体 | HTTP 命令终态 | agent 事件缓存（seq 游标，phase-control §7） |

`wait_event` 语义（防错过的关键设计）：

1. 解释器为每个 agent 维护一个事件游标（agent session 建立后从 `firstAvailableSeq` 起算）。
2. `wait_event` 执行时**先查游标之后的已有缓存事件**，未命中再等待新事件，直到匹配或超时——事件先到、wait 后到也不会错过（对应 phase-control §8 "回调先到、之后才 waitEvent" 故障路径）。
3. `match` 是字段值匹配 map（值可为表达式，与 §4.3 同一套求值）；**每次事件尝试匹配时重新求值**（延迟求值）。引用的变量尚不存在 → 视为不匹配、继续等。这解决了并行分支竞态：bob 的分支开始等消息时，alice 建群的结果 `$group` 可能还没产生，延迟求值保证 match 最终能引用到。
4. 匹配成功：绑定事件 payload 到 `as`，游标推进到该事件之后。
5. 同一事件流上多个 `wait_event` 依次消费、游标单调推进；回看历史第一版不支持。

## 7. 超时语义（决策落地）

三层超时，各自独立配置：

| 层 | 默认 | 触发后 |
|---|---|---|
| 命令超时（`cmd.timeoutMs`） | `defaults.stepTimeoutMs`（30s） | 该步信封置 `{success:false, status:timeout}` |
| 事件等待超时（`wait_event.timeoutMs`） | 同上 | 该步失败（同上信封形状） |
| 整流程超时（顶层 `flowTimeoutMs`） | 无（可选配置） | 兜底终止所有分支，按失败收场，写报告 |

对讨论中两个问题的明确回答：

- **超时是否扔掉返回的结果**：是。迟到结果不投递给流程、不改变已判定的失败；但 agent 侧事件流保留迟到完成记录（phase-control §6 "迟到结果另记"），报告标注 `timeout, late arrival recorded in agent events`。
- **超时是否终止后续行为**：不直接终止。超时等价于该步骤失败，走该步 `onFail` 策略（默认 continue）。与 phase-control 的 `uncertain` 状态衔接：agent 置 uncertain 后会拒绝后续业务命令，此时流程要么显式收尾、要么按失败结束——解释器不试图自动恢复 uncertain 会话。

## 8. 失败传播与报告

- `onFail` 策略（步骤级可覆盖默认）：`continue`（默认，对齐现有 AutoMode"失败不中断"哲学）| `abort_flow`（终止本执行线；在 parallel 分支内即终止该分支）| `abort_all`（终止整个运行，其余分支尽快收尾）。
- 依赖失败跳过（2026-11-05 确认，对齐 AutoMode 既有语义）：变量表同时记录每个 `as` 绑定的来源步骤成败。命令的 `inputs` 引用了失败来源的变量时，该命令标记 `skipped`、不执行、不产生新变量，下游对它的依赖同样级联 `skipped`。该行为由 `skipOnFailedDeps` 控制，**双层配置、局部优先**：
  - 全局：`defaults.skipOnFailedDeps: true`（默认开）；
  - 步骤级：`cmd` 步骤上的同名字段覆盖全局（设 `false` 时按求值语义执行，引用失败来源的值为 null，用于"明知上游失败仍要看实际行为"的探测场景）。
  - `wait_event` 的 `match` 引用失败变量不触发跳过（延迟求值天然兼容，见 §6）。
- 报告：`testing/reports/<run-id>/flow-report.json`。逐步骤记录 `{kind, agent, cmd/event, status, durationMs, envelope 摘要, evidence: {fromSeq, toSeq}}`，末尾汇总 `{total, passed, failed, timeout, skipped}`。断言细节（expect 匹配过程）在 agent 侧证据中，报告只引用区间。

## 9. 命令注册与查找（决策落地）

- YAML 中 `cmd: <id>` 只写命令 id；执行时到**目标 agent 绑定的设备脚本**中查找该 id 的定义（phase-control："命令只能选择绑定脚本中的阶段"）。
- 命令 JSON 保持设备脚本规范定义的格式（现阶段即现有 step 形状 `{api, params, expect}` 的组装），解释器不校验其内部结构。
- 唯一的静态检查：流程加载时校验每个 `cmd` 的 id 在目标 agent 脚本中存在、`agent` 名已声明、`wait_event` 的 `agent` 已声明——这是拼写防护，不是格式理解。
- 命令定义放设备脚本（而非全局命令库）：同一命令在不同设备/角色上参数不同，按 agent 就近定义最自然。全局共享库若将来有需求再议。

## 10. 第一版范围

做：

- 步骤类型：`cmd` / `parallel`（不嵌套）/ `wait_event` / `barrier` / `if` / `for` / `while` / `set` / `delay`
- 表达式：引用、比较、and/or/not，宽松求值
- 三层超时、onFail 三策略、JSON 报告
- 单 YAML 对应一次运行；退出码非 0 表示存在 failed/timeout

不做（有真实需求再议）：

- parallel 嵌套、子流程 include/复用、流程模板参数化（对应 GHA 的 reusable workflow / matrix）
- 算术运算、函数调用、字符串操作
- 事件回看、多游标
- 解释器内设备启动管理
- YAML 内直接内联 JSON 命令体（保持"树引用叶子"的纯净分工）

## 11. 端到端示例：群组已读回执

```yaml
version: 1
name: group-read-receipt

agents:
  alice:
    endpoint: http://127.0.0.1:8801
    script: scripts/alice_device.json
  bob:
    endpoint: http://127.0.0.1:8802
    script: scripts/bob_device.json

defaults: {stepTimeoutMs: 30000, onFail: continue}

steps:
  # 准备段：串行，时序确定的动作
  - cmd: create_group
    agent: alice
    as: group
  - cmd: invite_member
    agent: alice
    inputs: {groupId: $group.data.groupId, member: $agents.bob.userId}
  - cmd: join_group
    agent: bob
    inputs: {groupId: $group.data.groupId}

  # 协同段：并行。barrier 保证双方就绪后开始交互
  - parallel:
      alice_line:
        - barrier: both_ready
        - cmd: send_group_msg          # 命令定义在 alice 设备脚本，含 isNeedReadReceipt
          agent: alice
          inputs: {groupId: $group.data.groupId}
          as: msg_a
        - wait_event: onMessageReadReceipts
          agent: alice
          match: {msgId: $msg_a.data.msgId}
          as: receipt
          timeoutMs: 20000
      bob_line:
        - barrier: both_ready
        - wait_event: onMessageReceived
          agent: bob
          match: {from: $agents.alice.userId}   # 延迟求值：$group 未产生前不匹配，不会误吞别人的消息后卡死
          as: recv
        - cmd: mark_group_read
          agent: bob
          inputs: {conversationId: $recv.conversationId, msgId: $recv.msgId}

  # 断言段
  - if: $receipt.success
    then:
      - cmd: report_ok
        agent: alice
    else:
      - cmd: dump_evidence
        agent: alice
```

（命令 `create_group` / `send_group_msg` 等的定义、参数与 expect 都在各设备脚本 JSON 中，本示例不关心其内部。）

## 12. 模块划分（实现拆分建议）

```text
tool/flow_runner/            # 纯 Dart package，无 Flutter 依赖，便于日后独立成库
  bin/flow_runner.dart       # CLI：flow_runner run <flow.yaml>
  lib/ast.dart               # 流程 AST 节点与步骤定义
  lib/parser.dart            # YAML → AST（含静态检查：id 存在性、agent 存在性）
  lib/expr.dart              # 表达式解析与求值（含 path 寻址）
  lib/interp.dart            # 解释执行：步骤调度、parallel 协程、barrier、onFail
  lib/agent_client.dart      # AgentClient 抽象与信封定义
  lib/http_agent_client.dart # HTTP 客户端：session / commands / events 轮询与游标
  lib/report.dart            # JSON 报告
  test/                      # 解释器单测：用假 agent（MockAgentClient）覆盖控制流语义
```

关键实现依赖：`yaml` 包（解析）、`dart:io`（HTTP）。并发用 async/await + `Future.wait`/`Completer`，无需 isolate。

## 13. 决策记录与遗留问题

已确认（2026-11-05）：

- **设备启动边界**：模拟器 / app / 端口转发由外部脚本负责，解释器只连接已就绪的 agent endpoint。
- **目录组织**：`testing/flows/<name>.yaml` + `testing/flows/scripts/<actor>_device.json`，报告 `testing/reports/<run-id>/`。
- **失败跳过语义**：对齐 AutoMode 的依赖失败跳过，`skipOnFailedDeps` 全局默认 + 步骤级覆盖、局部优先（§8）。
- **事件命名**：`wait_event` 的 `event` 字段直接使用 SDK 事件处理器方法名（如 `onMessageReceived`、`onMessageReadReceipts`）；agent 侧事件流的 payload 携带该名，解释器只做字符串匹配。

约束（长期有效）：

- AI 主／子代理协同方案已废弃（2026-11-05 定论：多设备编排由本解释器承担）。`2026-11-04-example-testing-coordination.md` 已移除；保留文档中的代理叙述已改为宿主运行器表述，`testing/spec/2026-11-04-phase-control.md` 的 HTTP 接口作为本解释器的通道依据。解释器的工作只新增自己的文件；当前 `testing/flows/`、`tool/flow_runner/` 与既有目录无命名冲突，后续若出现占用必要名称的情况，向用户报告后处理。
