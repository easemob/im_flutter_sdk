# Case 修改记录

本文件记录测试用例、断言契约和运行行为的调整。按日期追加，日期使用 `YYYY-MM-DD`。

## 2026-08-06

### 多平台字段差异处理规则

适用平台：Android、iOS，后续可扩展 Web/HarmonyOS。

#### 1. Wrapper 负责协议归一化

各平台 Wrapper 负责把原生 SDK 的回调转换成统一的 WebSocket 事件格式：

```text
原生 SDK 回调
  → 平台 Wrapper
  → Dart Map
  → WebSocket JSON
  → Python event
```

Wrapper 应统一：

- `eventType` 名称；
- 公共容器结构，例如 `data.messages`、`data.infos`；
- 公共字段名称，例如 `msgId`、`from`、`to`、`body`；
- 原生对象到 JSON 的序列化。

Wrapper 不应为了迁就某一个 case 强行补造 SDK 没有返回的业务字段。

#### 2. 跨平台事件只断言必要业务字段

跨平台事件统一使用：

```python
assert_api.assert_event_matches(
    actual,
    expected={...},
)
```

事件断言规则：

- 期望中声明的字段必须存在；
- 期望字段值不一致仍然失败；
- 平台额外返回的字段允许存在；
- 不是业务必需的可选字段，不写进公共 `expected`；
- `ignore_keys` 不能解决“实际缺少字段”，因此不能用它掩盖必需字段缺失。

例如 `body.translations` 在 Android 可能返回、iOS 可能不返回，不能作为撤回事件的公共必需字段；而 `recallMsgId`、`recallBy`、`convId` 和 `msg` 属于撤回语义，必须断言。

#### 3. 普通 API response 继续严格断言

普通请求/响应仍使用：

```python
assert_api.assert_response_matches(
    actual,
    expected={...},
)
```

规则不变：

- 缺少字段失败；
- 字段值错误失败；
- 多出字段默认失败；
- 只有确认属于平台非业务字段时，才显式允许额外字段。

这样不会因为跨平台兼容而放过服务端 API 返回结构错误。

#### 4. 平台特有能力单独建 case

如果某字段或回调只属于某个平台能力，不放进跨平台公共 case：

```text
公共 case：验证 Android/iOS/Web 都应具备的行为
平台专项 case：验证 Android-only、iOS-only 或 Web-only 能力
```

例如：

- `onMessagesRecalledInfo`：跨平台撤回公共事件；
- `onMessagesRecalled`：旧版兼容回调，单独做兼容性验证；
- Android 特有字段：放 Android 专项 case；
- Web 不支持的 API：通过 capability/event 能力声明跳过，并在 Allure 中说明原因。

#### 5. 判断一个字段是否应进入公共契约

按以下顺序判断：

1. 该字段是否表达本 case 的核心业务结果？
2. Android、iOS、Web 的 SDK 是否都保证返回？
3. 没有该字段时，是否仍能判断业务成功？

结论：

- 核心业务结果 + 各平台保证返回 → 写入公共 `expected`；
- 非核心字段或平台不保证返回 → 从公共 `expected` 移除；
- 仅某平台保证 → 单独平台 case；
- 只是多出来的诊断/实现字段 → 由事件断言兼容，不影响公共 case。

### 跨平台事件断言与多设备计数

涉及文件：

- `src/tools/response_match.py`
- `src/tools/assertions.py`
- `tests/chat/test_chat_crud.py`
- `tests/chat/test_chat_message_types_and_delivery.py`
- `tests/chat/test_chat_reaction_fetch.py`
- `tests/chat/test_chat_s4_message_content_changed.py`
- `tests/chat/test_chat_text_boundaries_and_location_delivery.py`
- `tests/group/test_group_message_send.py`

修改内容：

1. 新增 `assert_event_matches`，用于跨平台事件 JSON 的必要字段断言。
2. 事件允许平台额外字段；缺少必要字段或字段值错误仍然失败。
3. 普通 API response 继续使用严格断言，不因跨平台字段差异而放宽。
4. 多设备送达数量按本次 pytest 实际启用的角色并集计算，不按所有在线模拟器动态计算。
5. 事件等待失败信息增加具体设备名，便于区分 `device_a`、`device_a_sec` 等端。

设备数量规则：

```text
普通 case：只声明 device_a、device_b → 只验证这两个端
拓扑 case：由 topology.sender_devices/recipient_devices 决定参与端
额外在线但未被本次测试选中的设备 → 不计入断言
```

这样可以避免同一个普通 case 因为用户额外启动了模拟器而改变期望消息数量。

### `test_chat_translate_message_recalled_message` 撤回回调调整

文件：

- `tests/chat/test_chat_crud.py`

修改内容：

1. 保留跨平台通用的 `onMessagesRecalledInfo` 断言。
2. 删除发送账号副端对旧版 `onMessagesRecalled` 的强制等待和断言。
3. 删除接收账号各在线端对旧版 `onMessagesRecalled` 的强制等待和断言。
4. 更新用例描述，明确撤回验证以 `onMessagesRecalledInfo` 为公共契约。
5. 未修改 Android/iOS Wrapper，也未改变 WebSocket 传输协议。

原因：

`onMessagesRecalled` 在 Dart API 中已标记为废弃，官方声明为：

```dart
@Deprecated('Use [onMessagesRecalledInfo] instead')
```

Android 和 iOS Wrapper 仍保留旧回调兼容映射，但不同平台或 SDK 版本不保证撤回时同时触发两个回调。当前 iOS 实测能够收到 `onMessagesRecalledInfo`，但不会稳定触发 `onMessagesRecalled`。因此，跨平台用例不能把旧回调作为必选条件。

当前公共验证契约：

```text
发送端撤回消息
  → 发送账号副端收到 onMessagesRecalledInfo
  → 接收账号每个在线端收到 onMessagesRecalledInfo
  → 校验 recallMsgId、recallBy、convId、msg
```

保留策略：

- `onMessagesRecalledInfo`：跨 Android/iOS/Web 的通用撤回事件，公共 case 必须验证。
- `onMessagesRecalled`：旧版兼容 API，不在跨平台公共 case 中强制验证；如需覆盖，单独建立平台或版本兼容性 case。

补充校准：

- 撤回信息中的 `msg.body.translations` 不是 Android/iOS 都保证返回的字段。
- 已从公共 expected 契约中移除；如果平台实际返回该字段，事件断言仍允许其作为额外字段存在。
- 不使用 `ignore_keys` 处理该问题，因为 `ignore_keys` 不能把“实际缺少的必需字段”变成通过。

验证：

```bash
.venv/bin/python -m py_compile tests/chat/test_chat_crud.py
git diff --check
```

运行用例：

```bash
.venv/bin/python -m pytest -q \
  --scenario android_ios_423_multi_device_default \
  tests/chat/test_chat_crud.py::test_chat_translate_message_recalled_message \
  -v --tb=short \
  --alluredir=allure-results/chat-recalled
```
