# flow_runner

通用 YAML 控制流解释器：编排跨多设备（agent）的不透明命令，为多设备协同测试提供程序化的流程执行，不依赖 AI 参与。

完整设计见 `docs/spec/2026-11-05-flow-interpreter-spec.md`（规格文档，含全部语义决策记录）。

## 定位

- **YAML 是树（控制流）**：顺序、并行、分支、循环、比较运算。
- **JSON 是叶子（命令）**：YAML 引用命令 id，到目标 agent 绑定的设备脚本中查找；命令内部格式对解释器不透明。
- 两个最小契约：命令输出信封 `{success, status, data, error}`；命令输入 `inputs` 由解释器注入。
- 工具不含任何业务语义，不限于 IM 测试。

## 使用

```bash
# 前置：各设备上的 app（agent HTTP 服务）已启动并监听（见 phase-control 协议）
dart run tool/flow_runner/bin/flow_runner.dart run testing/flows/<name>.yaml \
    [--report-dir testing/reports] [--no-verify-commands]
```

- 退出码：0 = 全部通过；1 = 存在 failed/timeout；64/65/69/70 = 用法/脚本/agent 不可达/解释器错误。
- 报告输出至 `<report-dir>/<runId>/flow-report.json`。
- `--no-verify-commands`：跳过“cmd id 必须存在于设备脚本”的静态检查（草稿期用）。

## 流程语言速览

```yaml
agents:
  alice: {endpoint: 'http://127.0.0.1:8801', script: scripts/alice_device.json}
  bob:   {endpoint: 'http://127.0.0.1:8802', script: scripts/bob_device.json}

steps:
  - cmd: create_group          # 命令 id（叶子，定义在设备脚本）
    agent: alice
    as: group                  # 结果信封绑定到 $group
  - parallel:                  # 分支并行，join-all
      alice_line:
        - barrier: both_ready  # 跨分支同步点
        - cmd: send_group_msg
          agent: alice
          inputs: {groupId: '$group.data.groupId'}
          as: msg_a
        - wait_event: onMessageReadReceipts   # SDK 回调方法名
          agent: alice
          match: {msgId: '$msg_a.data.msgId'} # 延迟求值
          timeoutMs: 20000
      bob_line:
        - barrier: both_ready
        - wait_event: onMessageReceived
          agent: bob
          match: {from: '$agents.alice.userId'}
          as: recv
        - cmd: mark_group_read
          agent: bob
          inputs: {msgId: '$recv.msgId'}
  - if: $group.success
    then: [{cmd: report_ok, agent: alice}]
    else: [{cmd: dump_evidence, agent: alice}]
```

步骤类型：`cmd` / `parallel`（不嵌套）/ `wait_event` / `barrier` / `if` / `for` / `while` / `set` / `delay`。

关键语义（详见规格 §5-§8）：

| 语义 | 行为 |
|---|---|
| 事件防错过 | agent 缓存事件流（seq 游标），`wait_event` 先查缓存再等新事件 |
| match 延迟求值 | 引用未产生变量 → 不匹配、继续等，解决并行分支竞态 |
| 超时 | 命令/事件/整流程三层；迟到结果不投递（agent 证据流保留） |
| 失败策略 | `onFail: continue / abort_flow / abort_all`（步骤级覆盖全局默认） |
| 依赖跳过 | `skipOnFailedDeps` 全局默认 + 步骤级覆盖；失败级联 skipped |

## 结构

```text
lib/ast.dart             流程 AST
lib/expr.dart            表达式解析/宽松求值/引用替换
lib/parser.dart          YAML → AST + 静态检查
lib/interp.dart          解释执行（并发/barrier/超时/失败语义）
lib/agent_client.dart    AgentClient 抽象 + 信封
lib/http_agent_client.dart  HTTP 实现（phase-control 协议）
lib/report.dart          JSON 报告
bin/flow_runner.dart     CLI
test/                    单测（MockAgent 覆盖全部控制流语义）
```

## 开发

```bash
cd tool/flow_runner
dart pub get
dart analyze
dart test
```

纯 Dart package，无 Flutter 依赖；设备启动（模拟器/app/端口转发）由外部脚本负责。
