# 拓扑与断言参考

## 当前 topology 约定

在 scenario 声明具名 topology，再用相同名称标记 case：

```python
@pytest.mark.topology("account_b_to_account_a")
def test_delivery(topology, assert_api):
    sender = topology.sender_action_device
    for role, receiver in zip(topology.recipient_roles, topology.recipient_devices):
        ...
```

- `sender_action_device` 是普通动作唯一的发起端。
- `sender_devices` 可用于前置/证据，但普通投递 case 不要求全部发送端动作。
- `recipient_devices` 包含以接收账号登录的全部已配置端点。
- scenario 增减接收端平台时，不需要重写 case。

不得把多 sender 当作默认行为。只有 case 的明确主题是“发送账号各端同步”时才测试它。

## event 与 response

| 消息类型 | 含义 | 断言 |
|---|---|---|
| `type=response` | 一次 `manager/cmd` 调用的结果 | 断言 manager、cmd、逻辑设备和业务结果。 |
| `type=event` | 原生异步回调 | 断言 eventType、data 和业务关联键。 |

单聊投递的典型证据：

```text
sendMessage response
onMessageSuccess on action sender (obtain real msgId)
onMessagesReceived on every recipient endpoint (same real msgId)
onMessagesDelivered on action sender
```

撤回时，每个接收端都必须独立检查所需撤回事件，并关联同一被撤回消息 ID。不同设备之间的事件先后顺序不是断言目标。

## Allure 规则

- Parameters 汇总 topology、动作端、接收端、平台和 SDK 版本。
- 附上原始 topology、runner、请求/响应、已观察事件作为诊断证据。
- 不得把队列 drain 展示为产品业务步骤；它是传输层准备。若报告必须展示，命名为“测试准备：清理历史事件”。
- 每个业务步骤应回答：谁动作、发生什么、哪个端点验证什么；将断言嵌在对应业务步骤中。
- failed：失败步骤必须是实际失败的命令或事件验证，附件包含预期、实际、字段差异、业务 ID 与已观察事件。
- skipped：增加“跳过原因”步骤和附件，说明 API/能力、平台、SDK、开关或外部前置，以及恢复条件。
- broken：保留原始异常；增加 scenario、逻辑设备、runner、平台、SDK 和连接/登录上下文，不能改造成业务断言失败。
- 普通单端 case 也采用同一步骤和附件规则；不需要 topology 才能改善 Allure。

## 送达回执的多端规则

`onMessagesDelivered.data.messages` 是接收设备粒度的记录列表，不是接收账号去重后的单条消息：

```text
B 发送给账号 A（A 主端 + A 副端在线）
→ A 主端送达确认
→ A 副端送达确认
→ B 收到同一 msgId 的两条 delivery 记录
```

- 收集目标 `msgId` 的所有 delivery 记录，直到数量等于 `len(topology.recipient_devices)`。
- 逐条断言关键业务字段；数量少于或多于接收端数都应失败。
- Allure 步骤写明期望数量，例如“等待 deviceB 的 2 条送达回执”。

## 历史规范

`native-auto-test/docs/spec/CASES_SPEC.md` 可用于查看历史字段示例和“发现→严格”流程，但它已经退役且假定设备固定为 A/B。不得把其中 fixture/topology 规则复制到新 case；冲突时以 `native-auto-test/docs/agents/AGENTS.zh.md` 和当前 scenario/config 代码为准。
