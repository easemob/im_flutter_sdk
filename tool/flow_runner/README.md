# flow_runner

通用 YAML 控制流解释器：编排跨多设备（agent）的不透明命令，为多设备协同测试提供程序化的流程执行，不依赖 AI 参与。

完整设计见 `docs/spec/2026-11-05-flow-interpreter-spec.md`（规格文档，含全部语义决策记录）。本 README 是**脚本编写参考**：读完应能独立写出正确的流程 YAML、设备脚本 JSON 与环境文件。

## 使用

```bash
# 前置：各设备上的 app（agent HTTP 服务）已启动并监听（见 phase-control 协议）
dart run tool/flow_runner/bin/flow_runner.dart run testing/flows/<name>.yaml \
    [--report-dir testing/reports] [--agents-file testing/tmp/<run-id>/agents.json] \
    [--no-verify-commands]
```

- 退出码：0 = 全部通过；1 = 存在 failed/timeout；64/65/69/70 = 用法/脚本/agent 不可达/解释器错误。
- 报告输出至 `<report-dir>/<runId>/flow-report.json`。
- `--agents-file`：注入**运行时动态凭据**（agent 端口/token 每次启动随机、账号绑定每次 run 不同），按角色名覆盖 YAML 声明。通常传 `setup_devices` 产出的 `testing/tmp/<run-id>/agents.json`，见下文「agents-file 注入」。
- `--no-verify-commands`：跳过“cmd id 必须存在于设备脚本”的静态检查（草稿期用）。

## 三个输入文件

| 文件 | 角色 | 形态 |
|---|---|---|
| 流程 YAML | 树：控制流（顺序/并行/分支/循环/等待） | 每流程一份 |
| 设备脚本 JSON | 叶子：命令库（每个 agent 一份，按 `id` 被 YAML 引用） | 可多流程复用 |
| 环境 JSON（可选） | 该 agent 的 `$config` 数据源（账号、appkey 等） | 每设备一份 |

工具不含任何业务语义，不限于 IM 测试。协议契约只有两条：命令返回实际信封 `{success, status, data, error, failureKind}`；expect 判定在宿主侧完成。

## 流程 YAML

### 顶层字段

| 字段 | 必要 | 说明 |
|---|---|---|
| `version` | 否 | 当前仅支持 1（缺省即 1） |
| `name` | 是 | 流程名，进报告 |
| `runId` | 否 | 报告目录名；缺省自动生成 |
| `flowTimeoutMs` | 否 | 整流程兜底超时（`while` 防死循环） |
| `agents` | 是 | 非空映射，角色 → 声明 |
| `preconditions` | 否 | 用例前置声明（见下），解释器只校验不执行 |
| `defaults` | 否 | 全局默认（见下） |
| `steps` | 是 | 步骤列表 |

### agents 声明

```yaml
agents:
  alice:
    endpoint: 'http://127.0.0.1:8801'   # 可省（agents-file 提供时）；带了 scheme 校验
    token: 'pairing-token'             # 可选：Bearer 鉴权；agents-file 可覆盖
    script: scripts/alice_device.json   # 命令库路径（开静态校验时必填）
    env: env/alice_env.json             # 可选，$config / $agents.alice 数据源
    meta: {udid: 'SIM-A'}               # 可选，给人/外部工具看的自由信息
```

角色名即后续步骤里 `agent:` 的取值，也是 `$agents.<role>` 的键。

> **路径基准**：`script:` / `env:` 的相对路径相对**本 YAML 文件所在目录**解析（流程与伴生文件可整体移动）；绝对路径原样使用。

### agents-file 注入（--agents-file）

agent 的端口与配对 token 每次 app 启动都是随机的（多设备共享宿主网络栈，固定端口会冲突），账号绑定每次 run 也不同。静态 YAML 写不下这些值，由 `--agents-file` 在运行时注入：

```json
[
  {"role": "alice", "endpoint": "http://127.0.0.1:62001", "token": "…",
   "instanceId": "…", "udid": "…", "env": {"userId": "zuoyu01", "userToken": "…"}},
  {"role": "bob",   "endpoint": "http://127.0.0.1:62002", "token": "…"}
]
```

语义（按角色名与 YAML `agents` 匹配，角色名是静态流程与动态运行之间的连接键）：

| 字段 | 优先级 | 说明 |
|---|---|---|
| `endpoint` | **file > YAML**，两者皆空报错 | agent 控制服务地址 |
| `token` | file > YAML | Bearer 配对凭据（agent 侧 `401` 即此值不对） |
| `env` | 浅合并：file > env 文件 | 注入 `$config`（如 `userId`/`userToken`，供设备脚本 params 引用） |

- file 中出现 YAML 未声明的角色 → **忽略并提示**（agents-file 描述的是本次 run 启动的全部设备，单个 flow 可能只用子集；角色名拼错会表现为该角色缺 endpoint 的报错）；YAML 中无对应 entry 的角色保持原声明。
- 该文件通常由 `setup_devices` 产出（`testing/tmp/<run-id>/agents.json`），编排脚本 `run_flow --run-id` 会自动带上。

### preconditions（用例前置声明）

```yaml
preconditions:
  - contacts: {between: [alice, bob], state: none}    # 保证两角色非好友
  - contacts: {between: [alice, bob], state: friends} # 保证两角色已是好友
```

**分工边界**：flow_runner 只做**解析与形状校验**（kind 白名单、between 恰两个已声明角色、state 枚举），并把声明写进 flow-report.json 作追溯；**执行不在解释器**——前置是业务状态编排，由 testing 侧工具（`testing/tools/data/preconditions.dart`，REST 通道）完成，编排脚本 `run_flow` 在流程启动前调用。前置失败是 **blocked（环境问题）**，不算用例失败。

### defaults

| 字段 | 缺省 | 取值 |
|---|---|---|
| `stepTimeoutMs` | 30000 | 命令/事件等待的默认超时 |
| `onFail` | continue | `continue` \| `abort_flow` \| `abort_all` |
| `skipOnFailedDeps` | true | 依赖失败时跳过（步骤级可覆盖） |

`onFail` 精确语义：

| 值 | 行为 |
|---|---|
| `continue` | 记录失败，继续下一步骤（默认） |
| `abort_flow` | 终止**当前执行线**：在 parallel 分支内 = 只终止该分支；在主线 = 终止整个流程 |
| `abort_all` | 终止**整个运行**：所有分支在下一个步骤边界尽快收尾 |

### 步骤类型（9 种）

> **规则：步骤种类必须是该步骤映射的第一个键**（解析器取首键判断类型），其余字段跟在后面。

**`cmd` — 执行一条命令**（在设备脚本命令库里按 id 查找）

```yaml
- cmd: send_group_msg        # 命令 id（设备脚本 step 的 id）
  agent: alice               # 必填：目标角色
  inputs: {groupId: '$group.data.groupId', text: 'hello'}   # 可选：注入 $inputs 槽位
  as: msg_a                  # 可选：结果信封绑定为流程变量 $msg_a
  timeoutMs: 20000           # 可选：覆盖默认超时
  onFail: abort_flow         # 可选：覆盖默认失败策略
  skipOnFailedDeps: false    # 可选：覆盖默认跳过策略
```

**`wait_event` — 等待一个事件**（事件源为 SDK 回调方法名）

```yaml
- wait_event: onMessageReceived     # SDK 回调方法名
  agent: bob
  match: {from: '$agents.alice.userId', 'body.type': 0}   # 可选：payload 路径 → 期望值
  as: recv                          # 可选：payload 绑定为 $recv
  timeoutMs: 20000
  onFail: continue
```

事件隔离与消费规则（写协同用例前必读）：

| 规则 | 行为 |
|---|---|
| 跨流程隔离 | 流程启动时游标定在事件流当前末尾——**上一流程的遗留事件永远不会被匹配** |
| 防错过 | 流程运行中事件先到、wait 后到：先查缓存再等新事件，不遗漏 |
| 顺序不重复 | 顺序的两个 wait 不会匹配同一事件（后者从前者的匹配点之后开始） |
| 并发独立观察 | 同一 agent 上并发的多个 wait 各自从快照扫描，互不吞事件；确实重叠时**可能匹配同一事件**（各自独立观察，有意设计） |
| 超时不消费 | 超时的 wait 不消费任何事件，后续 wait 仍可匹配其扫过但未匹配的事件 |

**`parallel` — 分支并行**（join-all：所有分支结束才继续；**不可嵌套**）

```yaml
- parallel:
    alice_line:              # 分支名任意
      - barrier: both_ready
      - cmd: send_msg
        agent: alice
    bob_line:
      - barrier: both_ready
      - wait_event: onMessageReceived
        agent: bob
```

> **同 agent 并发命令约束**：agent 协议层同一时刻仅允许一个在途命令（第二个直接 409 工具故障）。并行分支只应对**不同** agent 发命令；同一 agent 的命令天然串行。`$prev` = 该 agent 最近**完成**命令的 data（按完成序）；同一 cmd id 多次执行时 `$step.<id>` 取最新一次结果。

**`barrier` — 跨分支同步点**（只能出现在 parallel 分支内；建议放在分支无条件路径上）

```yaml
- barrier: both_ready
```

**`if` — 条件分支**

```yaml
- if: '$group.success and $group.data.memberCount >= 2'
  then:
    - cmd: send_group_msg
      agent: alice
      inputs: {groupId: '$group.data.groupId'}
  else:
    - cmd: report_degraded
      agent: alice
```

**`for` — 迭代**（列表引用或整数区间，闭区间）

```yaml
- for: item in $group.data.members     # 或: i in 1..5
  do:
    - cmd: send_to_member
      agent: alice
      inputs: {userId: '$item.userId'}
```

**`while` — 循环**（`flowTimeoutMs` 是防死循环兜底）

```yaml
- while: '$poll.success == false'
  do:
    - cmd: fetch_status
      agent: alice
      as: poll
```

**`set` — 绑定流程变量**

```yaml
- set: {attempt: 1, target: '$group.data.groupId'}
```

**`delay` — 静默等待（毫秒）**

```yaml
- delay: 1000
```

## 表达式语法

用于 `if:` / `while:` 条件：

```text
or      := and ('or' and)*
and     := cmp ('and' cmp)*
cmp     := 'not' cmp | '(' or ')' | operand [op operand]
operand := number | 'string' | true | false | null | $ref.path
op      := == != > >= < <=
```

- 字符串字面量用**单引号**：`'hello'`。
- 引用形如 `$msg_a.data.msgId`、`$agents.bob.userId`（点路径，列表用数字下标 `$list.0`）。
- **宽松求值**：引用路径不存在 → null（不报错）；跨类型 `==` 为 false；`>` `<` 等仅同 num 或同 String 有效，否则 false；truthiness：null 与 false 为假，其余为真。

## 变量与引用

两类引用发生在**不同层面**，不要混淆：

| 层面 | 写法 | 解析者 | 举例 |
|---|---|---|---|
| 流程层（YAML） | `$var.path` | 解释器（表达式/inputs/set 值） | `'$group.success'`、`inputs: {x: '$recv.msgId'}` |
| 设备脚本层（JSON params） | `$inputs.*` `$config.*` `$step.<id>.*` `$prev` | 解释器派发前（宿主侧） | `"to": "$inputs.userId"` |

**流程变量来源**：

| 来源 | 绑定内容 | ok 标志（影响跳过级联） |
|---|---|---|
| `cmd` 的 `as` | 完整信封 `{success, status, data, error, failureKind}` | **= expect 判定结果**（见下） |
| `wait_event` 的 `as` | 事件 payload | 恒真 |
| `set` | 解析后的值 | 恒真 |
| `for` 循环变量 | 当前元素（循环内遮蔽同名变量） | 恒真 |
| 内置 `$agents` | 角色 → 该角色 env 文件内容 | 恒真 |

> **逆向用例是 ok 生产者**：ok 跟随 expect 判定而非信封 success。命中预期错误码（`expect: {errorCode: 110}` 且实际返回 110）的步骤是**成功的步骤**——其 `as` 绑定与 `$step` 记录对下游是 ok 的，不会触发依赖跳过；信封完整绑定，`$err.error.code` 可正常引用。只有 expect 不匹配（含超时、工具故障、checks 失败）才使生产者 not ok。注意 `$step.<id>` 寻址的是 **data**（失败调用 data 为 null）——逆向用例的 error 细节请通过 `as` 绑定引用。

**设备脚本参数槽位**（在 step 的 `params` 里使用，派发前由宿主替换为实值）：

| 槽位 | 含义 |
|---|---|
| `$inputs.userId` | YAML `cmd.inputs` 提供的值；**提供了但 params 从未引用的键记入报告 `unusedInputs`**（拼写防呆） |
| `$config.accounts.0.id` | 该 agent env 文件里的数据 |
| `$step.msg_self.msgId` | 同一 agent 上先前命令 id 的 **data** 内路径 |
| `$prev` / `$prev.msgId` | 同一 agent 最近一条命令的 data |

> 替换规则与 AutoMode 一致：**仅整串引用**被替换（`"$ref"` 整个字符串），不做部分插值。

**依赖跳过（skipOnFailedDeps）**：inputs 引用了失败/未绑定的流程变量，或 params 引用了同 agent 上失败命令的 `$step.<id>` → 本步骤记 `skipped` 不执行，级联下游。

## 设备脚本 JSON（命令库）

```json
{
  "steps": [
    {
      "api": "ChatManager.sendMessage",
      "id": "send_hello",
      "params": {
        "to": "$inputs.userId",
        "chatType": 0,
        "body": {"type": 0, "content": "$inputs.text"}
      },
      "expect": {"success": true, "checks": [{"path": "msgId", "notEmpty": true}]}
    }
  ]
}
```

字段规则：

| 字段 | 必要 | 说明 |
|---|---|---|
| `api` | 是 | registry 注册的 API 全名 |
| `id` | 引用需要 | 无 id 的 step 允许存在（AutoMode 直跑会执行），但 YAML 无法引用 |
| `params` | 否 | 可含 `$inputs`/`$config`/`$step`/`$prev` 槽位 |
| `expect` | 否 | 见下节；加载时静态校验，未知字段直接报错 |

顶层 `init`/`login` 块仅 AutoMode 直跑路径使用；HTTP 模式下 init/login 是普通 step（自定 id 供 YAML 引用）。AutoMode 专属字段（如 `delayAfterMs`）被容忍但**不生效**——流程里的等待请用 YAML `delay` 步骤表达。同一脚本内 step id 不得重复。

### expect 断言（宿主判定）

| 字段 | 语义 |
|---|---|
| `success` | 断言信封 success 标志 |
| `errorCode` | 断言失败调用且 SDK 错误码匹配（逆向用例：`{"errorCode": 110}`） |
| `checks` | 对 `data` 的 path 断言，操作符：`equals` \| `gte` \| `notEmpty` \| `containsItem` \| `length` |

规则（与 AutoMode 完全一致）：缺省/空 expect 即断言 success；`failureKind != sdk` 或 `error.code <= 0` 永不通过（工具/超时故障不算 SDK 结论）。**逆向用例命中预期错误码时步骤按通过计**，其绑定对下游是 ok 生产者（见"变量与引用"）。`checks` 每项形如 `{"path": "group.memberCount", "gte": 2}`；`containsItem` 的操作数是字段匹配映射（`{"path": "members", "containsItem": {"role": "owner"}}`）。

## 环境文件（env）

JSON 对象，整份成为该 agent 的 `$config`，同时挂到 `$agents.<role>`：

```json
{
  "appkey": "easemob-demo#easeim",
  "userId": "user1",
  "token": "YWT...",
  "accounts": [{"id": "user1"}, {"id": "user2"}]
}
```

## 关键语义（详见规格 §5-§8）

| 语义 | 行为 |
|---|---|
| 事件隔离 | 流程启动时游标定于事件流末尾，上一流程的遗留事件不匹配 |
| 事件防错过 | agent 缓存事件流（seq 游标），`wait_event` 先查缓存再等新事件 |
| 并发观察 | 同 agent 并发 wait 各自独立扫描（互不吞事件，可能重复匹配同一事件） |
| match 延迟求值 | 引用未产生变量 → 不匹配、继续等，解决并行分支竞态 |
| 超时 | 命令/事件/整流程三层；迟到结果不投递（agent 证据流保留） |
| 失败策略 | `onFail: continue / abort_flow / abort_all`（步骤级覆盖全局默认） |
| 依赖跳过 | `skipOnFailedDeps` 全局默认 + 步骤级覆盖；失败级联 skipped；逆向用例（命中预期错误码）不算失败 |
| join-all | parallel 等所有分支结束（无论成败）；提前退出的分支释放 barrier 不挂死兄弟分支 |

报告判定状态：`passed / failed / timeout / skipped`；failed/timeout 的步骤结果带完整信封 + `expectMatched` + checks 明细 + `unusedInputs`。

## 结构

```text
lib/ast.dart             流程 AST + DeviceScript 命令库
lib/expr.dart            表达式解析/宽松求值/引用替换
lib/expect.dart          expect 判定器（宿主侧判断，自 example 移植）
lib/parser.dart          YAML → AST + 设备脚本/env 加载 + 静态检查
lib/interp.dart          解释执行（查库派发/引用替换/并发/barrier/超时/失败语义）
lib/agent_client.dart    AgentClient 抽象 + 信封（协议 v2）
lib/http_agent_client.dart  HTTP 实现（phase-control v2）
lib/report.dart          JSON 报告
bin/flow_runner.dart     CLI
test/                    单测（MockAgent 覆盖控制流与判定语义）
```

## 开发

```bash
cd tool/flow_runner
dart pub get
dart analyze
dart test
```

纯 Dart package，无 Flutter 依赖；设备启动（模拟器/app/端口转发）由外部脚本负责。iOS 模拟器宿主直连 endpoint；Android 经 `adb forward`（转发管理见 device-management 子文档）。
