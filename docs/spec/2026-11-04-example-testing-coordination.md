# 多代理协同协议与脚本样例

- 日期：2026-11-04
- 状态：已确认的协作规则与设计样例；当前工具尚不支持新增字段，未运行验证。
- 依据：[测试体系规格](2026-11-04-example-testing-spec.md)、[实施计划](../plan/example-testing/2026-11-04-example-testing-plan.md)。
- 路径均相对 `5.0.0` 工作树。本文中的 JSON 为格式设计样例，不投放到当前 `example/scripts/` 或作为已验证用例执行；第一阶段 P1 落实格式校验和具体工具接口。

## 1. 执行分工

主代理读取主脚本，建立角色到子代理、设备和账号的绑定，并逐阶段发命令。子代理只负责自己的设备，调用工具执行子脚本中的阶段，读取日志并主动返回结果。App 内复用现有执行器完成阶段内步骤；阶段结束后保持会话，场景结束或明确终止时才释放。

主代理通过子代理负责设备的结构化执行日志观察进度，核对结果后推进。日志包括命令接收、操作、SDK 结果／回调和断言证据，不依赖子代理聊天文字，更不要求记录代理内部推理。工具按预定义规则匹配证据，主代理负责调度与异常分析。

## 2. 命令、执行与结果规则

| 环节 | 约定 |
|---|---|
| 运行绑定 | 一次运行固定脚本版本或内容摘要、配置引用、角色与设备；角色只由所属子代理操作。设备绑定与进程状态的日志须能查到 |
| 下发 | 命令必须包含 `runId/commandId/actor/stage/inputs/timeoutMs`；阶段存在于绑定脚本，输入引用已解析，前置状态满足 |
| 接收 | 子代理记录接受或拒绝及理由；接受仅说明可以执行，不代表阶段成功。先记录命令再开始操作 |
| 执行 | 只执行指定阶段；操作与断言固定，不自行更换账号、绕过失败或修改预期。阶段内连续操作可由现有执行器顺序完成 |
| 重复命令 | 相同运行内同一命令 ID、相同内容返回已有状态，不重复执行；同 ID 不同内容拒绝。新 ID 也不能用于盲目重试同一有副作用的业务操作 |
| 超时／中断 | 超时不代表底层调用取消。停止受影响链，核查操作状态与设备状态；中断后无法判断是否已经执行时记录状态未知，不能承诺跨进程故障下自动恢复或恰好一次执行 |
| 返回 | 子代理返回运行／命令／角色标识、状态、声明的输出和证据位置；失败额外说明失败步骤、原因与影响，不把 SDK 失败包装成通过 |
| 核验 | 主代理读取对应运行、角色的日志与断言记录，核对证据完整性、业务标识、实际值和输出。子代理报告与日志矛盾、缺证据或读取失败时不得放行依赖阶段 |
| 结束 | 所有必需断言满足才判场景通过；清理结果单独记录。报告归档完成后，证据路径必须指向 reports 中的文件，不能依赖 tmp |

状态语义：`accepted/running` 是非终态；`passed/failed/blocked/skipped` 是结果状态。超时、崩溃、工具错误等通过失败原因细分；没有执行的依赖阶段为 blocked，不是新的 SDK 错误。单个阶段 passed 不意味着整个场景 passed。

### 命令样例

```json
{
  "runId": "run-001",
  "commandId": "cmd-004",
  "actor": "device2",
  "stage": "receive_and_receipt",
  "inputs": {"messageId": "m123"},
  "timeoutMs": 30000
}
```

`timeoutMs` 为本次阶段执行上限，步骤等待还可有自己的上限，实际执行受剩余阶段时间约束。运行与场景还需有有限的等待边界，不能因代理失联永久等待；具体默认值在 P1 明确。

### 子代理结果样例

```json
{
  "runId": "run-001",
  "commandId": "cmd-004",
  "actor": "device2",
  "status": "passed",
  "outputs": {"messageId": "m123"},
  "evidence": {
    "file": "device2/events.jsonl",
    "fromSeq": 81,
    "toSeq": 96
  }
}
```

`file` 相对本次运行产物目录，序号范围为该角色日志的闭区间；本例的输出由下方子脚本声明。主代理必须核实：设备 2 收到的是 m123、回执使用的是该消息、API 调用满足预期。随后仍需让设备 1 验证收到回执，不能用发送方的 API 成功替代另一端的事件证据。

## 3. 日志与观察规则

- 宿主机采集层补充 `runId/actor`，保留 App 的原始序号和来源；阶段命令、API 操作与断言关联 `commandId/stage`。进程重启后不得混用重置的序号，应建立新的采集会话并重新准备观察状态。
- SDK 自发回调不一定携带命令 ID，不能硬说它由当时正在运行的命令触发；通过预先建立的观察位置、事件类型与业务标识关联。
- `watch` 建立本次会话的观察起点并确认日志采集可用；之后发生的事件保留，`waitEvent` 能检查起点之后已经到达的事件，也能继续等待新增事件。
- `matchItem.path` 在事件的 payload 中定位集合，`where` 对同一个集合元素的字段做同时匹配；`saveMatchAs` 保存该匹配元素。不是从各个不相关元素拼出一次匹配。
- `$actor.account` 为绑定的账号配置；`$input` 为本阶段输入；`$step` 为当前阶段成功 API 返回的 data；`$capture` 为当前阶段匹配出的事件元素；`$flow` 为主脚本已核验阶段的声明输出。未定义引用立即报错，凭据不写入日志。
- watch 跨阶段保留；阶段的临时 step/capture 不隐式跨阶段传播，跨阶段数据通过声明输出和输入传递。
- 首次失败与复验分别归档。证据记录关联脚本／代码版本；报告展示预期与实际值，而非只有一个通过标签。

## 4. 双账号单聊已读回执样例

前提：两个专用测试账号、两台设备，单聊回执能力可用；本例仅描述消息与回执的闭环。初始化选项、完整 API／事件字段契约及清理条件在 P1 核实；这些示例不是现有格式的兼容承诺。

### 主脚本

拟用文件名：`5.0.0-multi-direct-read-receipt-positive-main.json`。

```json
{
  "id": "direct-read-receipt-positive",
  "actors": {
    "device1": {
      "script": "5.0.0-multi-direct-read-receipt-positive-device1.json",
      "account": "$config.accounts.0"
    },
    "device2": {
      "script": "5.0.0-multi-direct-read-receipt-positive-device2.json",
      "account": "$config.accounts.1"
    }
  },
  "flow": [
    {"id": "sender_ready", "actor": "device1", "stage": "prepare"},
    {"id": "receiver_ready", "actor": "device2", "stage": "prepare"},
    {
      "id": "sent", "actor": "device1", "stage": "send",
      "inputs": {"to": "$config.accounts.1.id"}
    },
    {
      "id": "receipt_sent", "actor": "device2", "stage": "receive_and_receipt",
      "inputs": {"messageId": "$flow.sent.messageId"}
    },
    {
      "id": "verified", "actor": "device1", "stage": "verify_receipt",
      "inputs": {
        "messageId": "$flow.sent.messageId",
        "conversationId": "$config.accounts.1.id"
      }
    }
  ],
  "onFailure": "stop-dependent-stages",
  "finally": [
    {"actor": "device1", "stage": "cleanup"},
    {"actor": "device2", "stage": "cleanup"}
  ]
}
```

本例 flow 严格顺序执行，所有业务阶段形成一条依赖链。主代理取得当前阶段的核验结果后才发下一条命令；失败则后续依赖阶段 blocked，仍尝试适用的 finally。其他独立用例不因该场景失败而停止；继续前检查设备、账号和资源状态是否受影响。

### 设备 1 子脚本：发送方

拟用文件名：`5.0.0-multi-direct-read-receipt-positive-device1.json`。

```json
{
  "actor": "device1",
  "stages": {
    "prepare": {
      "steps": [
        {"op": "initialize"},
        {"op": "login", "account": "$actor.account"},
        {"op": "watch", "id": "receipts", "event": "ChatEventHandler.onMessageReadReceipts"}
      ]
    },
    "send": {
      "steps": [
        {
          "api": "ChatManager.sendMessage", "id": "message",
          "params": {
            "to": "$input.to", "chatType": 0,
            "direction": 0, "status": 0, "isNeedReadReceipt": true,
            "body": {"type": 0, "content": "read-receipt test"}
          },
          "expect": {"success": true}
        }
      ],
      "outputs": {"messageId": "$step.message.msgId"}
    },
    "verify_receipt": {
      "steps": [
        {
          "op": "waitEvent", "watch": "receipts", "timeoutMs": 30000,
          "matchItem": {
            "path": "receipts",
            "where": {
              "messageId": "$input.messageId",
              "conversationId": "$input.conversationId",
              "isPeerReceipt": true
            }
          }
        }
      ]
    },
    "cleanup": {
      "steps": [
        {"api": "ChatClient.logout", "params": {"unbindDeviceToken": true}, "expect": {"success": true}}
      ]
    }
  }
}
```

### 设备 2 子脚本：接收方

拟用文件名：`5.0.0-multi-direct-read-receipt-positive-device2.json`。

```json
{
  "actor": "device2",
  "stages": {
    "prepare": {
      "steps": [
        {"op": "initialize"},
        {"op": "login", "account": "$actor.account"},
        {"op": "watch", "id": "incoming", "event": "ChatEventHandler.onMessagesReceived"}
      ]
    },
    "receive_and_receipt": {
      "steps": [
        {
          "op": "waitEvent", "watch": "incoming", "timeoutMs": 30000,
          "matchItem": {"path": "messages", "where": {"msgId": "$input.messageId"}},
          "saveMatchAs": "received"
        },
        {
          "api": "ChatManager.sendMessageReadReceipts",
          "params": {"messages": ["$capture.received"]},
          "expect": {"success": true}
        }
      ],
      "outputs": {"messageId": "$capture.received.msgId"}
    },
    "cleanup": {
      "steps": [
        {"api": "ChatClient.logout", "params": {"unbindDeviceToken": true}, "expect": {"success": true}}
      ]
    }
  }
}
```

样例 cleanup 描述已登录路径的退出。实际执行时由准备状态决定哪些清理动作适用：未启动或登录失败不能伪造成功退出，记录不适用及理由；退出本身失败单独报告。具体清理条件字段由 P1 明确。SDK logout 不等于关闭设备会话，工具在证据采集和清理结束后释放会话。

## 5. 失败、复验与继续

例如设备 2 发送回执失败：主代理先核对其日志，设备 1 的验证阶段记为 blocked。其他与该账号／设备状态无依赖的用例继续；相关设备是否可以复用要先确认状态。主代理将失败纳入清单，核实消息是否真实接收、回执参数及服务条件，再安排受控复验。

复验不能覆盖首次结果，也不能无上限自动重试。失败归因分为用例、SDK、环境、工具或尚未确定。只有证据证明用例不符合契约或前置条件，才修正用例；SDK 错误保持正确断言并输出复现记录。禁止把“本来应收到回执”改成“API 成功就算通过”。

如果设备 2 发回执成功，但设备 1 未收到事件，必须保留发送端成功与接收端超时的两份证据，继续分析 SDK、配置或采集链路，不凭任一端的单独回报下结论。

## 6. 后续实现边界

第一阶段实现校验、阶段入口和日志读取工具，并先跑通本例的执行与证据链，再扩展群回执及数据同步。控制传输方式、默认超时、SDK 状态确认和清理条件在 P1 具体设计中落实；不因本示例引入通用工作流引擎或承诺任意崩溃后的自动恢复。

第四阶段才把实际验证后的操作、协议与失败处理铁律写入名称待定的测试 skill，并按 skill 复跑。当前仅沉淀规则和样例。
