# 拓扑与断言参考

本文件只补充拓扑/离线 Case 的写法；普通单端和普通双端 Case 不需要使用 topology。

## topology

在 scenario 声明 topology，再在 Case 上引用同名标记：

```python
@pytest.mark.topology("account_a_to_account_b")
def test_delivery(topology, assert_api):
    action_device = topology.sender_action_device
    for endpoint in topology.recipient_devices:
        ...
```

角色含义：

- `sender_action_device` / `recipient_action_device`：唯一执行本次业务动作的端点；
- `sender_devices` / `recipient_devices`：该账号在当前 scenario 中的相关端点集合；
- scenario 增加或减少端点时，Case 不修改；
- 不写死 `deviceA/deviceB/deviceASec/deviceBSec`，也不新增 `observer_device` 角色。

只有业务契约要求验证端点集合时，才遍历全部相关端点。其他 Case 可以只验证动作端或最终状态。

## 离线生命周期

```text
确定 topology 角色
→ 按账号让相关端点离线
→ 只在 action_device 执行业务动作一次
→ 逐端恢复登录
→ 用 msgId/groupId 等业务键等待并断言
→ finally 恢复全部端点和测试选项
```

- 副端不重复执行 accept、decline、remove 等业务动作。
- 每个端点的离线队列独立消费，不能用一个端点的事件代表其他端点。
- 如果 SDK 只保证最终状态，其他端点校验本地/服务端状态，不伪造重复事件。
- 事件等待使用带超时的轮询；固定 `sleep` 不能代替业务条件等待。

## response 与 event

| 类型 | 证明内容 | 重点断言 |
|---|---|---|
| response | `manager/cmd` 已处理 | 动作端、必要 result、错误 code |
| event | SDK 异步通知发生 | `eventType`、data、业务关联键 |

response 成功不代表 event 一定已到达；两者要分别验证。事件等待应保留目标业务键和已观察事件，超时时能定位端点和原因。

## 多端送达回执

某些回执是接收端点粒度，而不是接收账号去重后的单条记录。例如 B 有两个在线端点时，A 可能收到同一 `msgId` 的两条 `onMessagesDelivered` 记录。

- 按 SDK 契约决定期望端点数；不要默认断言为 1；
- 也不要无条件去重，避免漏掉真实的多端记录；
- 用 `msgId`、接收端点或回执字段关联记录，再断言数量和内容。

## Allure

- 步骤标题写业务动作和验证目标，不展示 runner ID 等技术细节；
- 等待事件和断言放在同一个业务验证步骤中；
- 失败信息保留端点、业务 ID、预期、实际和已观察事件；
- 清理队列或恢复登录属于“测试准备/测试后置”，不要伪装成产品业务步骤。
