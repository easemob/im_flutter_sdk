# 好友与单聊离线 Cases

## User Story

作为 Flutter SDK 自动化测试维护者，我希望补齐好友关系和单聊消息在接收方或事件观察方离线时的核心链路，使两台模拟器可以稳定复现“离线前置、对端操作、重新登录、业务事件或最终状态同步”，并以真实 ADB/WebSocket 日志冻结严格预期。

## Acceptance Criteria（EARS）

1. 当 B 在 A 发起好友申请前已经退出登录时，测试应在 B 重新登录后严格断言 `onContactInvited` 的 `userId` 和 `reason`，并确认双方尚未自动建立好友关系。
2. 当 B 上线收到离线好友申请并同意时，测试应严格断言同意响应、A 侧真实接受/联系人新增事件和双方服务端好友列表。
3. 当 B 上线收到离线好友申请并拒绝时，测试应严格断言拒绝响应、A 侧真实拒绝事件和双方非好友状态。
4. 当 A 发出申请后退出登录且 B 同意时，测试应在 A 重新登录后按真实日志断言接受/联系人新增离线事件，并确认双方服务端好友列表一致。
5. 当 A 发出申请后退出登录且 B 拒绝时，测试应在 A 重新登录后按真实日志断言拒绝离线事件，并确认双方保持非好友。
6. 当离线好友申请 case 运行时，接收方应显式使用 `acceptInvitationAlways=false`；无论 case 成功或失败，测试都应恢复两台设备的登录状态和该批次约定的手动处理模式，避免污染其他用例。
7. 当 A 与 B 已建立好友关系且 B 离线时，A 发送文本消息后，测试应断言 A 的同步发送结果和成功事件；B 重新登录后应按真实日志断言目标 `onMessagesReceived` 及消息的 `msgId/from/to/convId/chatType/direction/body/deliverOnlineOnly`。
8. 当 B 离线且 A 分别发送 file、image、video、voice 消息时，测试应按消息类型参数化执行，并严格断言 B 上线后收到的消息类型和稳定媒体业务字段；动态路径、URL、secret、时间和文件大小只能按真实日志最小忽略。
9. 当 B 离线且 A 发送 CMD 消息时，测试应断言 A 侧真实发送终态，并按真实日志确认 B 上线后的 `onCmdMessagesReceived`、本地存储和未读语义，不得套用普通消息回调预期。
10. 当消息设置 `deliverOnlineOnly=true` 且 B 离线时，测试应按真实日志冻结 A 侧发送终态，并通过独立事件等待、未读数或消息查询确认 B 上线后没有离线投递目标消息。
11. 当 A 在 B 离线期间发送多条文本消息时，测试应在 B 上线后关联所有真实消息 ID，断言消息集合、内容、未读数量和最新消息；只有多次日志证明稳定时才断言事件顺序。
12. 当 `requireDeliveryAck=true` 且 B 离线时，测试应记录 A 的 `onMessagesDelivered` 在发送时或 B 上线后的真实触发时机，并严格关联本次消息 ID 与 `hasDeliverAck` 状态。
13. 当 B 已收到消息、A 随后退出登录且 B 发送单条已读回执时，测试应在 A 重新登录后按真实日志断言 `onMessagesRead` 及 `msgId/from/to/hasReadAck/hasDeliverAck`。
14. 当 B 已收到消息后退出登录且 A 撤回消息时，测试应在 B 重新登录后严格断言 `onMessagesRecalledInfo` 的 `recallBy/recallMsgId/convId/msg/ext`、同一消息的 `onMessagesRecalled` 及本地最终状态。
15. 当 B 已收到消息后退出登录且 A 修改消息时，测试应在 B 重新登录后严格断言 `onMessageContentChanged` 的操作者、消息 ID、修改后 body/ext 和最终本地消息内容。
16. 当登录、同步响应或业务事件包含动态字段时，测试只能忽略 `sequence`、时间、设备动态路径、动态 URL、secret 等经日志证明不稳定的字段；不得忽略整个 `result`、`data` 或 `body`，不得使用 actual 自证 expected。
17. 当某离线事件在当前 SDK/服务端未派发或时机不稳定时，测试应保留 discovery/ADB 证据并在模块 deferred 台账记录，不得将偶然缺失固化为无事件契约，也不得通过放宽断言宣称通过。
18. 当实现本批用例时，好友关系 case 应放入 Contact 模块，消息投递和消息后操作 case 应放入 Chat 模块；Python 文件名和测试函数名应显式包含 `offline`，使目录扫描即可识别离线场景。
19. 当实现完成时，Contact/Chat 的 `CASES_RECORD.zh.md` 或 `CASES_DEFERRED.zh.md` 应与新增测试函数逐项对账，并记录真实设备验证结果。
20. 当验证本批改动时，系统应先逐场景 discovery，再运行新增文件 strict 回归、Python 静态检查和项目 speckit 检查；失败必须保留真实原因，不得修改发布 SDK 或原生 Wrapper 规避。
21. 当 A 与 B 已建立好友关系且 B 离线时，A 删除 B 后，测试应在 B 重新登录后严格断言真实 `onContactDeleted` 事件，并确认双方服务端好友列表均不再包含对方。
22. 当 A 与 B 已建立好友关系且 A 离线时，B 删除 A 后，测试应在 A 重新登录后严格断言真实 `onContactDeleted` 事件，并确认双方服务端好友列表均不再包含对方。
23. 当 B 离线且 A 分别发送 location 和 custom 消息时，测试应严格断言发送响应、发送成功事件以及 B 重新登录后的目标消息事件；location 应覆盖经纬度、地址、建筑物名称，custom 应覆盖事件名和参数。
24. 当 B 离线且 A 发送 combine 消息时，测试应使用真实源消息 ID 构造合并消息，并在 B 重新登录后严格断言标题、摘要、兼容文本及服务端返回的稳定业务字段。
25. 当 B 已收到消息、A 随后离线且 B 调用 `ackConversationRead` 时，测试应在 A 重新登录后严格断言真实 `onConversationRead` 事件的 `from/to`，不得兼容多个候选事件名。
26. 当 A 离线且 B 对目标消息添加 Reaction 时，测试应在 A 重新登录后严格断言真实 Reaction 变化事件中的会话、消息、操作者、Reaction、操作类型和聚合状态，并验证最终 Reaction 状态。
27. 当目标消息已有 Reaction、A 随后离线且 B 移除该 Reaction 时，测试应在 A 重新登录后严格断言真实移除事件和最终 Reaction 状态。
28. 当 B 离线且 A 置顶目标消息时，测试应在 B 重新登录后严格断言真实 `onMessagePinChanged` 事件中的消息、会话、操作类型和操作者，并验证最终置顶状态。
29. 当目标消息已置顶、B 随后离线且 A 取消置顶时，测试应在 B 重新登录后严格断言真实取消置顶事件和最终置顶状态。
30. 当实现第二批 P0 cases 时，应继续放入现有 Contact、Chat 离线测试模块；已经标记暂缓的好友自动同步场景不纳入本批实现，也不得为了使 P0 通过而放宽已有严格断言。
