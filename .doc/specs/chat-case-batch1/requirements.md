# Chat 单聊缺失 Case 第一批

## User Story

作为 Chat 自动化测试维护者，我希望补齐基础单聊消息类型与送达通知场景，使测试能够覆盖位置、语音、自定义消息以及文本/CMD/自定义消息的送达回调，并以 5556/5558 两个模拟器的真实 WebSocket 日志冻结断言。

## Acceptance Criteria（EARS）

1. 当发送位置消息时，测试应校验发送端成功响应、发送成功事件和接收端消息事件中的真实消息类型及关键业务字段。
2. 当发送语音消息时，测试应校验发送端成功响应、发送成功事件和接收端消息事件中的真实消息类型及稳定媒体字段。
3. 当发送自定义消息时，测试应校验发送端成功响应、发送成功事件和接收端消息事件中的真实 event/params 字段。
4. 当文本、CMD 或自定义消息送达时，测试应监听并校验 `onMessagesDelivered`，且消息 ID 必须与本次发送的真实消息 ID 关联。
5. 当真实设备日志中的字段具有动态性时，测试只能将时间戳、序列号、动态路径、secret 等明确不稳定字段加入最小忽略集，不得用 `result is not None` 等弱断言替代业务断言。
6. 当模拟器或桥接未提供稳定能力时，测试应保留 discovery 证据并标记暂缓，不得编写无法由真实日志支持的固定预期。
7. 当补齐文档中其余启用的单聊场景时，测试应按模块语义覆盖文本边界、置顶、举报、会话标记、已读 ACK、修改、翻译、附件及漫游消息，并将 WebIM/Mobile 的相同业务场景合并统计。
8. 当翻译、内容审核等依赖服务端开关的能力未开启时，测试不得把“功能关闭”的错误返回固化为功能预期，应记录所需开关并提示开启后继续验证。
9. 当稳定业务字段存在时，测试应显式断言参与者、会话、消息类型、方向、状态、已读/送达标记及业务 body；只有时间、序列、动态路径、secret、游标等确实不稳定字段可以进入忽略集。
10. 当测试 App 从 `native-auto-test/config.yaml` 初始化 SDK 时，系统应将 `sdk_options.require_delivery_ack` 映射到 `EMOptions.requireDeliveryAck`，且当前送达回执测试基线必须显式配置为 `true`。
11. 当 `requireDeliveryAck=true` 且单聊消息到达接收端时，发送端应收到与本次真实服务端消息 ID 关联的 `onMessagesDelivered`，后续已读回调中的消息应保留真实的 `hasDeliverAck=true`。
12. 当适配送达回执开关时，修改范围应限制在测试 App 配置加载及其配置源，不得修改发布 SDK、Android/iOS Wrapper 或通过放宽 case 断言规避缺失回调。
13. 当 `requireDeliveryAck=true` 时，case 应按消息生命周期分别断言送达状态：同步发送和早期发送成功阶段保留真实 `false`，接收、送达、已读、撤回及送达后查询阶段断言真实 `true`。
14. 当共享测试环境可能存在其他置顶消息时，case 应按本次真实 msgId 投影并严格断言目标消息存在或不存在，不得假设整个置顶列表长度固定为 1 或必然为空。
15. 当当前 AppKey 已返回 `targetLanguages` 和非空 `translations` 时，自动翻译 case 应验证成功发送、接收和翻译字段，不得继续等待旧环境的 `onMessageError 1113`。
16. 当自己会话的 mark/pin 边界在当前环境返回稳定结果时，case 应冻结当前真实返回；若出现 `505 Service is not enabled`，应停止依赖步骤并提示开启对应能力，不得将关闭态错误写成业务预期。
17. 当测试端通过 WebSocket bridge 执行 Client 登录或退出时，bridge 应调用公开 Dart `EMClient` API，使 Dart `currentUserId` 与原生登录状态同步；随后 `sendMessageWithType` 创建的消息 `from` 必须等于本次登录用户。
18. 当发送前置消息收到 `onMessageError` 时，case 应按本次临时消息 ID 报告真实错误事件，不得仅以“未收到 onMessageSuccess”或空对象掩盖发送失败；该错误不得被改写为翻译、撤回或置顶业务预期。
