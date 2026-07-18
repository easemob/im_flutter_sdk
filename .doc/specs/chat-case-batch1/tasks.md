# Chat 单聊缺失 Case 第一批任务

- [x] 确认 5556/5558 模拟器对应 deviceA/deviceB WebSocket topic。
- [x] 检查 SDK、桥接和 Python Cmd 已暴露 location、voice、custom、onMessagesDelivered。
- [x] 添加位置消息发送/接收 discovery case。
- [x] 添加语音消息发送/接收 discovery case，并补齐测试 App 默认 voice 素材映射。
- [x] 添加自定义消息发送/接收 discovery case。
- [x] 在文本/CMD/自定义消息链路补充送达事件 discovery 与 strict 断言。
- [x] 根据真实日志收紧稳定字段和最小忽略集。
- [x] strict 回归第一批测试（位置、语音、自定义、文本送达、自定义送达通过）。
- [x] 记录 CMD 送达事件在当前模拟器未派发，暂不固化无事件预期。
- [x] 更新 `native-auto-test/docs/agents/chat/CASES_RECORD.zh.md` 与必要的 deferred 记录。

## 第二批

- [x] 按真实模块语义命名撤回与消息已读 ACK 测试文件：`test_recall_and_message_read_ack.py`。
- [x] discovery 采集位置/自定义撤回及 ACK 边界真实返回。
- [x] strict 回归第二批并回填 Chat 台账。
- [x] 补齐置顶/取消置顶/置顶列表边界，冻结空 ID、无效 ID、撤回消息和无效会话真实错误。
- [x] 补齐举报消息边界；当前类型消息举报真实返回不稳定，保留 skip 并记录原因。
- [x] 补齐会话标记 options 边界，记录 mark=999 的 Android bridge 异常。
- [x] 补齐 translateMessage 空语言、不支持语言和自定义消息错误语义。
- [x] 补齐附件下载与历史分页，严格断言消息业务字段和稳定分页消息体。
- [x] 运行新增模块 strict 回归；动态路径、secret、时间、游标等仅按真实变化字段忽略。

## 文档剩余启用场景

- [x] 补齐文本空内容、特殊字符、250 字符及 from 不一致边界。
- [x] 补齐位置消息送达通知。
- [x] 补齐文本消息接收方举报和其他可稳定举报语义。
- [x] 补齐文本消息缩略图异常语义。
- [x] 补齐位置/自定义消息置顶组合与幂等边界。
- [x] 补齐会话标记剩余稳定状态组合；记录 Flutter API 无对应参数的 Robot/WebIM 场景。
- [x] 补齐消息修改的文本及媒体 ext/body 场景。
- [x] 补齐带 `targetLanguages` 的自动翻译发送/接收严格断言。
- [ ] 补齐显式 `translateMessage` 正常翻译结果；当前调用仍返回空 `translations`，需单独排查，不再归因于总翻译开关未开启。
- [x] 补齐漫游消息 direction、时间范围及 msgTypes 过滤。
- [x] 收紧支持语言列表断言，校验结构、唯一 code 及中英文关键项。
- [x] 记录 moderation 开关、类型举报服务端行为和 Flutter 参数语义差异。
- [x] 完成最终全量 strict 回归、台账与 deferred 更新（88 passed, 5 skipped；翻译开关阻塞项单列保留）。

## 送达回执配置适配

- [x] 诊断 `requireDeliveryAck` 从 YAML、Flutter `EMOptions` 到 Android/iOS 原生 SDK 的完整数据链路。
- [x] 确认当前两台模拟器 APK 的 `assets/config.yaml` 未包含 `require_delivery_ack`，且测试 App 初始化落到默认 `false`。
- [x] 添加 `SdkConfigLoader` 回归测试并确认在适配前因 `requireDeliveryAck=false` 失败。
- [x] 在当前 `native-auto-test/config.yaml` 和模板中显式配置 `require_delivery_ack: true`。
- [x] 将 `require_delivery_ack` 映射到 `EMOptions.withAppKey(requireDeliveryAck: ...)`。
- [x] 运行 Flutter 配置测试和 `flutter analyze`（无 error；2 条既有 deprecated info）。
- [x] 构建 Android debug APK，覆盖安装并重启 5554/5556 两台模拟器。
- [x] 严格复跑送达回执相关 case，核验 `onMessagesDelivered`、真实 msgId 和 `hasDeliverAck`（最终聚合 `19 passed`）。
- [x] 根据真实复跑结果回填 Chat 台账和新环境复跑报告。

## `requireDeliveryAck` 开启后的指定 14 条回归修复

- [x] 严格执行用户指定的 14 条 case，记录 `2 passed / 12 failed` 的 RED 基线。
- [x] 按真实日志确认 7 条失败来自送达后阶段仍预期 `hasDeliverAck=false`。
- [x] 确认两条置顶查询失败来自共享环境历史 pinned message，而非功能开关。
- [x] 确认自动翻译服务已开启，真实返回 `targetLanguages` 和非空 `translations`，旧 `1113` 错误预期已过时。
- [x] 确认自己会话 mark/pin 是稳定边界返回差异，与功能开关无关。
- [x] 按消息生命周期同步 7 条 case 的送达字段断言。
- [x] 将置顶查询改为按本次真实 msgId 投影，并在取消置顶后断言目标不存在。
- [x] 按当前真实返回更新自己会话 mark/pin 边界断言。
- [x] 将 `targetLanguages` case 改为翻译成功链路严格断言。
- [x] 分组严格回归后，同 session 复跑用户指定 14 条（`14 passed`，最终验证 JUnit：`/tmp/requested-chat-14-verified.xml`）。
- [x] 回填 Chat 台账、deferred 和新环境复跑报告。

## WebSocket 登录状态与 Dart `currentUserId` 同步修复

- [x] 从真实日志确认原生登录用户为 `test0716user1`，但 `sendMessageWithType(custom)` 使用旧 Dart 缓存 `from=test0715user2`，最终返回 `500 Message is invalid`。
- [x] 确认普通 `sendMessage` 可显式携带 `from`，而类型便利 API 通过 `EMMessage.createSendMessage` 读取 `EMClient.currentUserId`，因此仅类型消息稳定暴露该问题。
- [x] 添加 bridge 命令级 Flutter RED 测试，复现 WebSocket 登录后 Dart `currentUserId` 未刷新（修复前响应 `new-user`，缓存仍为 `old-user`）。
- [x] 让 bridge 的登录/退出命令走公开 Dart `EMClient` API，并保持登录、退出及 `loginWithAgoraToken` 错误响应 envelope。
- [x] 增强 translation 边界 case 的发送错误终态输出，不将 `500` 或 `300` 固化为翻译预期。
- [x] 运行 Flutter 单测（2 passed）、speckit check、Android debug APK 构建并覆盖安装两台模拟器。
- [x] 真实验证原始问题已修复：类型消息 `from=test0716user1`，收到 `onMessageSuccess`，custom translate 返回 `1 General error`，目标单例通过。
- [ ] 当前隔舱环境连续复跑稳定性：随后两轮类型消息发送被独立的 TCP ACK 超时 `300 Server is unreachable` 阻断；保持环境失败，不作为业务预期。
