# Allure 报告可读性改造规范

## 目标

让失败报告无需阅读 Python 堆栈或大段原始 JSON，也能回答：

```text
该 Case 测什么 → 执行到哪一步 → 请求和响应是什么 → 收到哪些事件 → 为什么不匹配
```

本规范只约束 `native-auto-test` 的测试报告与测试协议展示，不改变发布 SDK 的对外 API，也不将测试桥接逻辑放入 `im_flutter_sdk`。

## 报告结构

每个业务 Case 应包含以下三层信息：

| 层级 | 手段 | 用途 |
|---|---|---|
| 场景说明 | Python 三引号 docstring | 描述前置条件、操作与验收点。 |
| 执行步骤 | `allure.step` | 展示业务动作及其先后关系。 |
| 证据附件 | `allure.attach` | 保存请求、响应、命中事件、筛选条件和失败诊断 JSON。 |

### Case 说明

每个新增或改造的 Case 均应写 docstring，使用场景与验收点，而非实现细节：

```python
def test_chat_translate_message_recalled_message(...):
    """
    场景：A 向 B 发送文本消息后撤回。

    验证：
    1. A 发送和撤回调用均成功；
    2. B 收到原始消息；
    3. B 收到撤回信息及撤回后的消息本体。
    """
```

### 执行步骤

步骤名称必须使用业务语义，且包含有助于定位的稳定标识（如 `msgId`、`groupId` 或目标用户），不要使用“步骤 1”“调用接口”等泛化名称。

```python
with allure.step("A 发送待撤回的文本消息"):
    ...

with allure.step("B 验证收到原始文本消息"):
    ...

with allure.step(f"A 撤回消息 msgId={msg_id}"):
    ...

with allure.step("B 验证撤回信息 onMessagesRecalledInfo"):
    ...
```

`device.call()` 保持自动附加请求和响应；Case 不应为同一请求重复手工附加相同内容。

## Event 的跨端测试契约

WebSocket Event 的固定信封如下：

```json
{
  "type": "event",
  "eventType": "onMessagesRecalledInfo",
  "data": {},
  "runId": "run-...",
  "runnerId": "android-423-device-b",
  "device": "deviceB",
  "platform": "android",
  "sdkVersion": "4.23.0",
  "timestamp": 0
}
```

Case 应断言 `type`、`eventType` 及 `data` 内的业务字段；`timestamp` 等运行元数据一般不作严格比对。

原生 Android/iOS Wrapper 可直接传递 List 或 Map 参数，但 `im_flutter_test` 的 `EventRouter` 必须将其规范化为稳定的 WebSocket `data` 结构。Case 不得通过 `data.get("infos") or data.get("value")` 兼容内部实现差异。

### 撤回事件

Android 与 iOS Wrapper 对以下两个回调都传递裸列表；这是原生 Channel 参数形式，不是 Case 契约。

| `eventType` | 原生参数元素 | `EventRouter` 后的 `data` 契约 |
|---|---|---|
| `onMessagesRecalled` | `EMMessage` | `{ "messages": [...] }` |
| `onMessagesRecalledInfo` | `RecallMessageInfo` | `{ "infos": [...] }` |

`messages` 表示被撤回的消息本体；`infos` 表示撤回动作信息，元素中包含 `recallMsgId`、`recallBy`、`convId`、`ext`，并可包含 `msg` 消息本体。

因此，`test_chat_translate_message_recalled_message` 应依次验证：

```text
A 发送文本
→ B 收到 onMessagesReceived / data.messages
→ A recallMessage 成功
→ B 收到 onMessagesRecalledInfo / data.infos
→ B 收到 onMessagesRecalled / data.messages
```

若收到 `onMessagesRecalledInfo`，但其数据为 `data.value`，属于测试端 EventRouter 未完成协议规范化；不是 Case 未收到回调，也不能通过修改 Case 接受 `value` 来掩盖。

## 事件等待与失败诊断

事件等待辅助函数必须在失败时以附件保存以下内容：

1. 等待条件：目标 `eventType`、业务 ID、内容等；
2. 超时时间；
3. 已观察的同类型事件（完整 JSON）；
4. 每个候选不命中的原因，例如事件数据路径缺失、`msgId` 不同或内容不同；
5. 若检测到已知的协议错误，提供明确诊断，例如“期望 `data.infos`，实际收到 `data.value`”。

推荐错误文本保持简短，并把完整数据放入 JSON 附件：

```text
未命中目标 onMessagesRecalledInfo：
expected recallMsgId=...，content=...；
已收到 1 条同类型事件，实际数据路径为 data.value，期望为 data.infos。
```

## 改造顺序

### 第一阶段：撤回链路模板

范围：

- `im_flutter_test/lib/bridge/event_router.dart`：规范化两个撤回列表事件；
- `native-auto-test/tests/chat/test_chat_crud.py`：为 `test_chat_translate_message_recalled_message` 添加场景说明、业务步骤与失败附件；
- 对应 EventRouter 单测及撤回相关 Case 回归。

先完成此阶段，确认 Android/iOS 使用完全相同的 Case 契约后，再扩展。

### 第二阶段：Chat 高频链路

按“发送/接收、撤回、已读、翻译、置顶”的顺序，为共用 helper 补充业务步骤和失败诊断。优先改造 helper，避免每个 Case 复制相同的 Allure 代码。

### 第三阶段：其他 Manager

依次覆盖 Contact、Group、ChatRoom、UserInfo。每个模块先冻结 Event `data` 契约，再改造 Case 报告；不要让不同 Case 自行解释同一个 Event 的字段。

## 验收标准

- Allure 中可从 Case 描述理解测试目的；
- 每个关键业务动作都有一个可读步骤；
- 每个 API 调用均可查看请求和响应附件；
- 每个事件等待均可查看筛选条件及命中/未命中证据；
- 同一份 Case 在 Android/iOS 下断言相同的 Event `data` 契约；
- 不因报告改造改变发布 SDK、Android/iOS Wrapper 的业务实现；
- 对协议规范化增加单元测试，并回归受影响 Case。
