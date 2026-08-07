# 拓扑与断言参考

## topology 约定

在 scenario 声明具名 topology，再用相同名称标记 Case：

```python
@pytest.mark.topology("account_a_to_account_b")
def test_delivery(topology, assert_api):
    sender = topology.sender_action_device
    for recipient in topology.recipient_devices:
        ...
```

- `sender_action_device` 是普通动作唯一的发起端。
- `sender_devices` 的其余同账号端用于验证消息同步、落库或业务相关回调。
- `recipient_devices` 是接收账号当前 scenario 声明的全部在线端点。
- scenario 增减 Android、iOS、Web、Harmony 端时，Case 不修改。
- 多 sender 不是默认拓扑；只有专项验证“多个发送端分别动作”时才增加。

## response 与 event

| 类型 | 含义 | 断言 |
|---|---|---|
| `type=response` | 一次 `manager/cmd` 调用的结果 | `manager`、`cmd`、动作设备和必要业务结果。 |
| `type=event` | SDK 异步回调 | `eventType`、`data` 和业务关联键。 |

单聊消息投递的通用证据：

```text
sendMessage response
onMessageSuccess on action sender (obtain real msgId)
onMessagesReceived + local lookup on every relevant endpoint
onMessagesDelivered on action sender (one record per recipient endpoint)
```

撤回、已读、reaction 先完成上述投递，再按各 API 的语义验证相关端的回调。不同设备之间的事件先后顺序不是断言目标。

## Allure 呈现

- Parameters 汇总场景、账号、动作端、发送/接收端的平台和 SDK；不显示 runner ID 等技术细节。
- 步骤标题表达业务行为，断言嵌入对应步骤；等待事件不单独展示为“收到回调”。
- 断言附件保留请求、实际 response/event、预期、字段差异；事件等待超时还保留已观察事件。
- 清理队列属于稳定性前置，若展示，命名为“测试准备：清理历史事件”。

## 多端送达回执

`onMessagesDelivered.data.messages` 是接收设备粒度，不是接收账号去重后的单条消息：

```text
发送账号 A → 接收账号 B（B 主端 + B 副端在线）
→ A 收到同一 msgId 的两条 delivery 记录
```

- 收集目标 `msgId`，直到记录数等于 `len(topology.recipient_devices)`。
- 少于或多于接收端数均失败；不得写死为 1 或静默丢弃重复记录。
