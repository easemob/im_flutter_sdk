# 多设备协同测试用例规格

## 1. 范围与产物

在 `testing_v2` 中完成以下独立正向用例。每例选择一个平台的两台模拟器验证，固定用例后连续完整执行三轮。先补齐场景契约并由子代理审查，再逐例开发、验证，主代理验收。无法解决的场景先记录问题并暂停，继续不受影响的下一例，不为此增加辅助脚本。

| 序号 | 场景 | 用例标识／文件主名 |
|---|---|---|
| 1 | 单聊消息送达确认 | `5.0.0-multi-message-delivery-positive` |
| 2 | 单聊消息已读回执 | `5.0.0-multi-message-read-receipt-positive` |
| 3 | 联系人申请与接受 | `5.0.0-multi-contact-add-positive` |
| 4 | 公开群入群通知 | `5.0.0-multi-group-member-join-positive` |
| 5 | Presence 订阅与发布 | `5.0.0-multi-presence-positive` |
| 6 | 同账号双设备消息同步 | `5.0.0-multi-message-device-sync-positive` |
| 7 | 消息内容编辑通知 | `5.0.0-multi-message-edit-positive` |
| 8 | 消息撤回通知（暂停执行） | `5.0.0-multi-message-recall-positive` |
| 9 | 群成员退出通知 | `5.0.0-multi-group-member-leave-positive` |
| 10 | 用户资料订阅更新 | `5.0.0-multi-user-info-subscribe-positive` |
| 11 | 群名片更新通知 | `5.0.0-multi-group-namecard-positive` |
| 12 | 同账号双设备建群同步 | `5.0.0-multi-group-create-device-sync-positive` |

每例在 `data/` 下对应同名 YAML、JSON；Presence 完善现有文件。YAML 保存控制流，JSON 的 `steps` 保存完整命令和参数，`data` 保存业务输入，`requiredBindings` 声明必要验证。用文件主名关联报告，不另设一套用例编号。

各例实现、验证结果及暂缓原因见[验证记录](2026-11-07-multi-device-cases-verification.md)。

本任务复用现有执行工具。若编写或验证需要新增测试用例以外的独立脚本（含临时辅助脚本），须先说明用途、必要性及现有工具不能满足的原因，取得用户确认后再创建或执行。

example 可按场景需要注册 SDK 已有公开 API、补齐通知的结构化记录；仅透传实际参数和结果，不增加业务编排。模型序列化由 SDK 的 `toJson()` 提供，公共转换函数不按模型类型特判，不改动解释器契约。

本规格遵循 [规则与边界](../spec.md)、[编写用例](2026-11-06-test-case-authoring.md)、[执行规格](../../docs/spec/2026-11-06-testing-v2-spec.md)及 [flow_runner 语法](../../tool/flow_runner/README.md)。本次不扩展逆向场景、单设备用例或 CI 测试，不使用 `testing/`。

## 2. 共同规则

| 项目 | 要求 |
|---|---|
| 独立性 | 单独选择任意一例即可执行，不消费其他用例产生的消息、群组或关系；初始化、登录、前置准备和收尾完整。 |
| 账号与设备 | 使用明确授权的测试账号；选择文件分别提供账号编号和设备映射，登录命令选择账号，不在用例中硬编码账号、Token、设备 ID。执行期间账号和设备不被其他任务占用。 |
| 前置状态 | 数据模块按声明准备并核验联系人关系；初始化、登录及被测 SDK 操作由用例执行。准备不能提前完成被测行为。环境不满足时报告具体缺项，不能作为通过。 |
| 初始化 | 每次执行重新启动 App，按本例配置初始化并注册回调；初始化参数不能在登录后临时修改。双方登录及连接检查成功后才发送业务命令。 |
| 数据归属 | 使用既有 `$global` 读写规则；正文、申请理由、群名称及状态描述按需使用 `data.unique`。复验生成新的唯一值，不复用上次业务结果。 |
| 消息结果 | `sendMessage` 必须取得对应消息的发送成功回调及服务器消息 ID；方法返回、HTTP 接收成功、本地消息创建均不能替代最终发送结果。 |
| 事件断言 | 按事件类型、角色及业务标识匹配；列表中的同一元素必须满足全部条件。禁止默认取数组首项、只判断事件非空或使用历史通知凑齐结果。 |
| 顺序与并发 | 只约束业务因果，不假定跨设备事件到达顺序。等待条件依赖命令结果时，先取得结果，再查事件缓存；同一设备上可能乱序的不同通知应独立观察，不能因顺序消费游标而漏掉目标。 |
| 超时 | 命令、事件及整例均有明确上限；发送步骤的上限须覆盖执行端等待发送回调的时间。以结果或事件驱动下一步，不用固定 sleep 代替就绪条件，不自动重发结果未知的业务命令。 |
| 必要验证 | 所有决定通过的命令和事件均有明确 `as`，列入 `requiredBindings`；未执行、跳过、超时或缺少证据不能算通过。查询只作辅助，不能代替本例要求的通知。 |
| 清理 | 只处理本例创建或明确允许改动的资源。失败后也须根据已确认产生的资源尝试收尾；不能认为 YAML 尾部命令必然执行，也不能用 HTTP `finish` 代替业务清理。结果未知时先查证再处置。 |

消息用例允许保留已发送的测试消息及自然产生的会话，以业务 ID 记录归属，不为清理而删除账号历史数据。联系人、群组、订阅等可回收资源须按各例要求处理。清理故障单独记录；影响下一例前置状态时停止依赖执行。

## 3. 场景契约

每例实现前先落实关键步骤：执行角色、API、关键参数及来源、依赖关系、预期结果／事件和失败收尾。用例实现遵循该流程；账号、业务 ID 等值在运行时产生，测试流程和通过标准不在运行时临时决定。

### 3.1 消息送达确认

**角色与输入**：`alice` 为设备 A／账号 A，`bob` 为设备 B／账号 B，两个账号不同、互不拉黑。JSON 声明 `data.unique.messageContent`，本次正文通过 `$global.biz.input.messageContent` 读取。本例“确认”指 SDK 已送达回执，不包含 B 的业务回复。

| 步骤 | 执行端 | API／事件及关键输入 | 完成条件与后续依赖 |
|---|---|---|---|
| 1. 初始化 | A、B | `ChatClient.init`：`config = $global.biz.config.initConfig`；B 的 `overrides.requireDeliveryAck = true` | 各端初始化成功，执行端完成 `startCallback()` 和监听注册；本端才可登录。 |
| 2. 登录 | A、B | `ChatClient.loginWithToken`：A 使用 `$global.account.account1`，B 使用 `$global.account.account2`；各自的 `userId`、`userToken` 分别传入命令参数 `userId`、`token` | 各端登录成功；本端才可检查连接。两端的步骤 1–3 可并行，本端内部串行。 |
| 3. 确认连接 | A、B | `ChatClient.isConnected`，无参数 | 两端均返回 `true`，才允许 A 发送消息。 |
| 4. 发送 | A | `ChatManager.sendMessage`：`to = $global.account.account2.userId`、`chatType = 0`、`isNeedReadReceipt = true`、`body.type = 0`、`body.content = $global.biz.input.messageContent` | 收到对应消息的发送成功回调；完整命令结果绑定到 `global.biz.result.sent`，其 `data.msgId` 为非空服务器消息 ID。 |
| 5a. 验证接收 | B | 等待 `onMessagesReceived`；检查 `messages` 中同一元素的 `msgId`、`from`、`to`、`body.type`、`body.content` | 分别等于 `$global.biz.result.sent.data.msgId`、A 账号、B 账号、`0`、本次正文；事件绑定到 `global.biz.event.received`。 |
| 5b. 验证送达回执 | A | 等待 `onMessagesDelivered`；检查 `messages` 中的 `msgId` | 包含 `$global.biz.result.sent.data.msgId`；事件绑定到 `global.biz.event.delivered`。 |
| 6. 退出 | 已登录的 A、B | `ChatClient.logout`：`unbindDeviceToken = true` | 分别保存退出结果；一端退出失败不跳过另一端。 |

**依赖与通过标准**：步骤 4 成功后并行执行 5a、5b；两者先查流程启动后缓存的事件，再等待新事件，因此事件可早于发送结果返回，不要求 5a、5b 的到达顺序。步骤 1–5 的结果均列入 `requiredBindings`；发送成功、目标消息接收、同一消息的送达回执三项证据缺一不可。B 自动发送送达回执，不额外调用已读回执 API。

Native 5.0.0 的自动送达回执路径也要求消息 `isNeedReadReceipt: true`，本例显式设置该字段；它不代表 B 已阅读消息，也不改变送达事件的验证目标。

**失败处理**：初始化、登录或连接检查失败时停止依赖的业务步骤，仍尝试已登录端退出；发送失败时不继续读取缺失的服务器消息 ID，也不自动重发。5a 或 5b 失败时保留另一项观察结果，再进入退出及工具收尾。通信或整流程超时导致无法退出时，记录未完成的收尾及在途状态，按现有执行模块规则保留证据，不追加独立清理脚本。

### 3.2 消息已读回执

**角色与输入**：`alice/bob` 分别绑定不同账号 A/B。初始化使用公共 `initConfig`、无额外覆盖；登录和连接检查与 §3.1 相同。JSON `data.unique.messageContent` 提供正文。

| 顺序 | 执行端 | API／事件与参数 | 断言与依赖 |
|---|---|---|---|
| 1 | A | `ChatManager.sendMessage`：`to=B`、`chatType=0`、`isNeedReadReceipt=true`、文本 body | 发送回调成功、`sent.data.msgId` 非空；超时 45 秒。 |
| 2 | B | `onMessagesReceived`，检查 `messages` | 同一元素匹配目标 ID、A、B、正文和 `body.type=0`。 |
| 3 | B | `ChatManager.loadMessage`：`messageId=sent.data.msgId` | 仅在目标接收通过后执行；结果 ID、from、to、正文均匹配目标。 |
| 4 | B | `ChatManager.sendMessageReadReceipts`：`messages=[loaded.data]` | 仅使用已核验的目标消息对象；调用成功，void 返回不要求 data 非空。 |
| 5 | A | `onMessageReadReceipts`，检查 `receipts` | 同一元素满足 `messageId=目标ID`、`conversationId=B`、`isPeerReceipt=true`；允许通知先于命令响应缓存。 |
| 6 | 已登录的 A、B | `ChatClient.logout` | 两端独立尝试退出。 |

步骤 1–5 及初始化、登录、连接、正常退出均列入必要绑定。业务段失败停止其依赖，外层仍执行退出；不重发消息，不附加未读数或会话断言。

### 3.3 联系人申请与接受

**角色与前置**：`alice/bob` 为专用 A/B 账号，互不拉黑，执行期间独占。YAML `preconditions` 与 JSON `data.prepare` 均声明 `contacts: {between: [account1, account2], state: none}`；通过既有 `--data-input` 准备并核验双方非好友。两端初始化覆盖 `acceptInvitationAlways: false`。

| 顺序 | 执行端 | API／事件与参数 | 断言与依赖 |
|---|---|---|---|
| 1 | A | `ChatContactManager.addContact`：`userId=B`、`reason=$global.biz.input.inviteReason` | reason 由 `data.unique.inviteReason` 生成；调用成功。 |
| 2 | B | `onContactInvited` | 同时匹配 `userId=A` 和本轮 reason，才允许接受。 |
| 3 | B | `ChatContactManager.acceptInvitation`：`userId=A` | 调用成功；不能预先由 REST 建立关系。 |
| 4 | A | `onFriendRequestAccepted` | `userId=B`，结合步骤 1–3 的本轮邀请链路判定。 |
| 5 | A、B | `ChatContactManager.getAllContactIds` | 收到接受通知后，分别检查 A 的本地联系人列表包含 B、B 的本地联系人列表包含 A；任一检查失败不阻止另一端检查及收尾。 |
| 6 | A | `ChatContactManager.deleteContact`：`userId=B`、`keepConversation=true` | 接受已成功时，无论通知或联系人检查是否通过都尝试解除关系；仅以调用成功判断清理。 |
| 7 | 已登录的 A、B | `ChatClient.logout` | 两端独立退出。 |

数据模块只能证明非好友，不能证明没有历史待处理申请。使用专用账号、唯一 reason 和先邀请后接受的完整证据链；发现历史申请干扰或上一轮结果未知时，记录后暂停本例，不能将无法观测的状态记为已核验。已收到本轮邀请但未尝试接受时，可对 A 调用 `declineInvitation` 清理该申请；写操作结果未知时不盲目重发，记录待处置状态。

初始化、登录、连接、申请、邀请事件、接受、接受事件、双方本地联系人包含对方、解除关系和正常退出均列入必要绑定。不追加添加前或删除后的本地联系人检查、会话或 REST 删除后断言；下一次执行仍核验非好友前置。

### 3.4 公开群入群通知

**角色与前置**：`alice=A` 为入群者、`bob=B` 为群主，双方登录并连接；B 有建群权限及配额。`data.unique.groupName` 生成群名称。

| 顺序 | 执行端 | API／事件与参数 | 断言与依赖 |
|---|---|---|---|
| 1 | B | `ChatGroupManager.createGroup`：本轮 `groupName`；`configs={maxCount:200,isPublic:true,joinApprovalRequired:false,inviteNeedConfirm:false,allowInvites:true}` | 不传邀请成员，返回 `groupId` 非空。 |
| 2 | A | `ChatGroupManager.joinPublicGroup`：`groupId=created.data.groupId` | 使用本轮群 ID，void 调用成功。 |
| 3 | B | `onMembersJoinedFromGroup` | `match.groupId=本轮群ID`；`checks: [{path:userIds, contains:A}]`，不假定数组下标或长度。 |
| 4 | B | `ChatGroupManager.destroyGroup`：`groupId=本轮群ID` | 一旦已取得群 ID，加入或通知失败仍尝试解散；记录结果。 |
| 5 | 已登录的 A、B | `ChatClient.logout` | 两端独立退出。 |

初始化、登录、连接、建群、加入、通知、解散及正常退出列入必要绑定。建群结果未知时保留群名称、群主及命令证据，不重复创建。事件成员列表使用现有 `contains` 检查；example 通过 `ChatGroupManager.joinPublicGroup` 注册入口直接调用 SDK 公开接口。

### 3.5 Presence 订阅与发布

**角色与前置**：`alice=A` 为订阅者，`bob=B` 为发布者；环境支持 Presence，账号无需保留 A→B 既有订阅。双方登录并连接。

| 顺序 | 执行端 | API／事件与参数 | 断言与依赖 |
|---|---|---|---|
| 1 | A | `ChatPresenceManager.unsubscribe`：`members=[B]` | 解除本账号对测试订阅成功。 |
| 2 | B | `ChatPresenceManager.fetchPresenceStatus`：`members=[B]` | 列表含 publisher=B；按 publisher 遍历选取原 `statusDescription` 并保存，未找到不得发布。 |
| 3 | A | `ChatPresenceManager.subscribe`：`members=[B]`、`expiry=600` | 返回列表包含 B；有效期覆盖 240 秒流程上限。 |
| 4 | B | `ChatPresenceManager.publishPresence`：`desc=$global.biz.input.presenceDescription` | 由 `data.unique.presenceDescription` 生成；发布成功。 |
| 5 | A | `onPresenceStatusChanged` | `list` 同一元素的 publisher=B、statusDescription=本轮描述；不得以订阅初始值替代。 |
| 6 | A | `ChatPresenceManager.fetchPresenceStatus`：`members=[B]` | 辅助核对 B 的新描述；不替代步骤 5。 |
| 7 | A、B | A `unsubscribe(members=[B])`；B `publishPresence(desc=原描述)` | 分别清理，不受另一端清理失败影响。 |
| 8 | 已登录的 A、B | `ChatClient.logout` | 分别退出。 |

以上正常路径命令与通知均列入必要绑定。初始化及业务失败只终止依赖分支，保留外层收尾。派发前保存订阅／发布尝试标记；即使命令结果未知，仍尝试退订、恢复已确认的原描述，不重新发布测试状态。

### 3.6 同账号双设备消息同步

**角色与输入**：`a1/a2` 为不同模拟器，两端登录命令均引用 `account1`；环境允许同账号双端在线及消息同步。收件人 B 使用 `account2`，不占第三台设备，无需填写业务占位值或制作私有用例副本。账号映射须包含两个不同账号，必要绑定缺失不能通过。

| 顺序 | 执行端 | API／事件与参数 | 断言与依赖 |
|---|---|---|---|
| 1 | a1、a2 | 初始化；a2 覆盖 `messagesReceiveCallbackIncludeSend=true`；按 a1 → a2 顺序登录 A | 两端分别保存登录结果，随后核验并存。 |
| 2 | a1、a2 | `ChatClient.getCurrentDeviceId` | SDK UUID 非空且不同；相同则禁止发送。 |
| 3 | a1 | `ChatClient.fetchLoggedInDevices`：`userId=A`、`token=A的Token` | 返回列表分别包含两端 UUID（`deviceUUID`）；证明同账号设备身份与并存。 |
| 4 | a1、a2 | `ChatClient.isConnected` | 第二端登录后两端均为 true，才进入业务。 |
| 5 | a1 | `ChatManager.sendMessage`：`to=$global.account.account2.userId`、单聊文本、本轮唯一正文 | 45 秒内取得发送成功回调及服务器 ID。 |
| 6 | a2 | `onMessagesReceived` | messages 同一元素匹配 msgId、from=A、to=B、body.type=0、正文；允许从缓存匹配。 |
| 7 | 已登录的 a1、a2 | `ChatClient.logout` | 两端分别退出，不使用 kickAllDevices。 |

初始化、登录、设备 UUID、在线列表、连接、发送、同步通知及正常退出列入必要绑定；SDK UUID 不同的条件控制发送，未满足时不得靠其余查询通过。本例不验证 B 接收，也不用 `ChatMultiDeviceEventHandler` 的联系人／群组通知替代消息同步。被踢下线、身份不符或同步能力缺失记录实际证据并暂停，不修改服务端开关绕过结果。

### 3.7 消息内容编辑通知

**角色与输入**：A/B 不同账号，双方初始化、登录和连接成功；`data.unique` 分别生成原正文、编辑正文及扩展标识。

| 顺序 | 执行端 | API／事件 | 必要断言 |
|---|---|---|---|
| 1 | A | `sendMessage`，单聊文本发往 B | 发送成功回调，服务器消息 ID 非空。 |
| 2 | B | `onMessagesReceived` | 同一消息元素匹配本轮 ID、A、B、原正文及文本类型。 |
| 3 | A | `modifyMessage(messageId, msgBody, attributes)`，example 参数为 `messageId/content/attributes` | 使用本轮消息 ID，返回同一 ID、新正文和扩展标识。 |
| 4 | B | `onMessageContentChanged` | `message.msgId`、正文、扩展标识及 `operatorId=A` 同时匹配。 |
| 5 | A、B | `logout` | 双方独立退出。 |

只在已确认 B 收到原消息后编辑；不使用本地 `updateMessage` 替代服务端修改。发送、接收、修改、编辑通知及公共前后置均为必要绑定。失败停止依赖步骤，仍退出双方；不重发或反复编辑结果未知的消息。

### 3.8 消息撤回通知

**执行状态**：2026-11-08 按用户要求暂停，不纳入当前执行清单；保留用例、断言和历史证据，待用户明确通知恢复后再执行。

**角色与输入**：A/B 不同账号，公共前后置同 §3.7；环境须支持所请求的撤回能力，本轮正文和撤回 `ext` 均为唯一值，操作须在服务端允许的撤回窗口内完成。返回 `505: Service is not enabled` 时保留失败证据并暂停，不擅自开通服务或删除断言绕过。

| 顺序 | 执行端 | API／事件 | 必要断言 |
|---|---|---|---|
| 1 | A | `sendMessage`，单聊文本发往 B | 发送回调成功，取得服务器消息 ID。 |
| 2 | B | `onMessagesReceived` | 同一元素匹配本轮消息 ID、A、B、正文。 |
| 3 | A | `recallMessage(messageId, ext)` | 撤回本轮消息，API 成功返回。 |
| 4 | B | `onMessagesRecalledInfo` | `recallMessageInfos` 同一元素匹配 `recallMsgId=本轮ID`、`recallBy=A`、`ext=本轮值`。 |
| 5 | A、B | `logout` | 双方独立退出。 |

`RecallMessageInfo.toJson()` 输出 `recallMsgId/recallBy/convId/msg/ext`，与 `fromJson()` 一致；允许 `msg` 为 null，不将可选原消息对象作为通过条件。撤回失败或通知超时不能算通过，不盲目重试撤回；保留原消息证据，仍退出双方。

### 3.9 群成员退出通知

**角色与前置**：B 群主，A 成员。按 §3.4 创建本轮无审批公开群、A 主动加入，先验证 B 收到匹配本群及 A 的入群通知。

| 顺序 | 执行端 | API／事件 | 必要断言 |
|---|---|---|---|
| 1 | A | `leaveGroup(groupId)` | 使用本轮群 ID，调用成功。 |
| 2 | B | `onMembersExitedFromGroup` | 本轮 `groupId`，`userIds contains A`；不假定数组顺序。 |
| 3 | B | `destroyGroup(groupId)` | 取得有效群 ID 后，前置加入、退出或通知失败仍尝试解散。 |
| 4 | A、B | `logout` | 双方独立退出。 |

建群、入群及其通知、退出及其通知、解散和公共前后置均为必要绑定。创建结果未知时不重建、不以未知 ID 清理。

### 3.10 用户资料订阅更新

**角色与前置**：A 订阅者、B 资料提供者，使用专用账号，环境支持用户资料订阅；两端初始化 `enableUserInfo=true`。只修改 B 的昵称；原值必须可以准确恢复，不能把缺失/null 等同于空字符串。

| 顺序 | 执行端 | API／事件 | 必要断言 |
|---|---|---|---|
| 1 | B | `fetchOwnInfo(expireTime: 0)` | 取得 B 的资料，保存可恢复的 `nickName` 及 `gender`；不满足则禁止修改。 |
| 2 | A | `unsubscribeUsersInfo([B])`、`subscribeUsersInfo([B])` | 专用订阅先归零，再订阅成功；不提前修改资料。 |
| 3 | B | `updateUserInfo(nickname: 本轮唯一值, gender: 原值)` | 只传目标昵称与原性别；返回 `userId=B`、`nickName=本轮值`。 |
| 4 | A | `onUserInfoUpdate` | `userInfos` 同一元素匹配 B 与本轮 `nickName`。 |
| 5 | A、B | A 退订；B 恢复原昵称及性别 | 发布前记录尝试标记，修改结果未知或通知失败仍尝试恢复；两项清理独立执行。 |
| 6 | A、B | `logout` | 双方独立退出。 |

订阅、更新及准确通知缺一不可；资料查询不替代通知。恢复命令必须带原始字符串，不能传 null 假装清理成功。原资料不可恢复时记录前置缺项并暂停该例，不擅自预置账号资料或改工具取值规则。

### 3.11 群名片更新通知

**角色与前置**：B 创建本轮无审批公开群，A 主动加入；先验证 B 的入群通知。使用本轮群 ID 字符串作为名片值，保持每轮唯一且长度明确。

| 顺序 | 执行端 | API／事件 | 必要断言 |
|---|---|---|---|
| 1 | A | `updateGroupNamecard(groupId, namecard)` | 本轮群 ID、唯一名片，调用成功。 |
| 2 | B | `onUserGroupNamecardChanged` | 同时匹配本轮 `groupId`、`userId=A`、本轮 `namecard`。 |
| 3 | B | `destroyGroup(groupId)` | 已创建的群始终尝试解散；该群名片随群回收。 |
| 4 | A、B | `logout` | 双方独立退出。 |

公共前后置、建群、入群及通知、名片更新及通知、解散均为必要绑定。`getGroupNamecard` 为本地查询，不能替代对端通知或充当服务端确认。

### 3.12 同账号双设备建群同步

**角色与前置**：a1/a2 使用不同模拟器，两端登录命令均引用 account1，环境允许同时在线。按 §3.6 核验不同 SDK UUID、在线列表包含两端，第二端登录后双方连接仍正常。无需第三账号或消息同步专用选项。

| 顺序 | 执行端 | API／事件 | 必要断言 |
|---|---|---|---|
| 1 | a1 | `createGroup`，本轮唯一群名称、无邀请成员 | 返回非空群 ID。 |
| 2 | a2 | `ChatMultiDeviceEventHandler.onGroupEvent` | `event=GROUP_CREATE`、`groupId=本轮群ID` 同时匹配；不要求未定义的 `userIds` 内容。 |
| 3 | a1 | `destroyGroup(groupId)` | 创建成功后即使同步通知失败也尝试解散本群。 |
| 4 | a1、a2 | `logout` | 双方独立退出。 |

身份与在线核验、建群、同步通知、解散及公共前后置均为必要绑定。不能用普通 `ChatGroupEventHandler` 的群通知替代同账号同步通知；创建未知、被踢下线或多设备能力缺失均保留证据并暂停，不改服务端开关绕过。

## 4. 逐例实施与验收

规格经子代理审查后，每例按以下顺序完成；设备和账号由主代理独占调度：

1. **落实细节**：核对 API、事件字段、前置状态、数据改动范围和清理路径。保持目标和核心断言正确的参数、前置调整可依据证据自行修正规格；重大变更、缺失执行端命令及新增独立脚本仍按各自确认规则处理。
2. **编写与静态检查**：完成 YAML、JSON，解析通过；检查引用依赖、事件游标、必要绑定和失败收尾。修改执行端或工具时运行对应分析和针对性测试。
3. **设备调试**：每例选一个平台的两台模拟器，当前优先双 Android；设备验证串行，避免共享账号互相影响。失败按用例、执行端、工具、SDK、设备、环境或数据归因，不预设为网络问题。
4. **重复验证**：用例及相关实现固定后，在所选平台连续完整执行 3 轮，每轮重新准备本例前置状态和启动 App；全部必要断言通过，清理、报告无未处理故障。该检查用于发现可重复性问题，不证明达到 99% 稳定率；另一平台不计为已验证。
5. **记录并推进**：保留全部轮次及失败。正式失败按既有规则显式复验，复验通过不覆盖首次失败；修正后重新验证受影响用例。无法解决或需确认的事项先记录问题、证据和待处理点，暂停本例，继续不受影响的其他场景；不得新增辅助脚本绕行。

本次验收以各例三轮记录为准，不额外要求双平台或全套连续验证。主代理核对原始事件、必要绑定和清理结果；不将子代理口头结论代替报告。

报告沿用 `reports/<runId>/summary.md`、`statistics.csv`、`process.json`；原始命令、事件及设备日志保留在本轮 `tmp/<runId>/`。每次结果能定位用例、平台、账号角色、执行序号、预期与实际、关键业务 ID 和证据文件；敏感信息脱敏。值得复用的故障结论按[故障沉淀规则](2026-11-06-test-execution-troubleshooting.md#故障沉淀)记录。

## 5. 实施前需处理的具体事项

以下事项逐例处理，不据此预先扩展框架。

| 涉及场景 | 源码事实／待核验事项 | 处理要求 |
|---|---|---|
| 消息相关 | [发送执行端](../../im_flutter_sdk/example/lib/registry/apis/chat_apis.dart) 在发送前注册回调，用原始消息 ID 关联结果，并在结束时移除监听。 | 回归覆盖早于方法返回的成功／错误回调、原生调用失败和超时后的迟到事件；不能只等待方法返回。 |
| 消息送达 | 共享 Native 5.0.0 对送达也检查 `isNeedReadReceipt`，只启用接收端自动送达开关不足，见[排查记录](../troubleshooting/2026-11-07-delivery-receipt-read-flag.md)。 | 发送时显式设置 `isNeedReadReceipt: true`，保留消息接收与送达事件断言；保留未设置时的失败证据。 |
| 联系人 | 现有数据模块可准备非好友关系；非好友不等于无历史待处理申请。 | 依赖专用账号、本轮唯一邀请理由及因果链；发现历史干扰／未知写结果先记录暂停，不声称已查询待处理列表。 |
| 入群 | [公开 API](../../im_flutter_sdk/lib/src/managers/chat_group_manager.dart) 与 [example 注册表](../../im_flutter_sdk/example/lib/registry/apis/group_apis.dart) 均提供 `joinPublicGroup`。 | 直接调用公开接口，不新增 SDK API；命令成功和群主收到目标成员通知分别验证。 |
| 入群 | 事件 `userIds` 是字符串列表；现有 `expect.dart` 和测试已实现 `contains`。 | 直接使用列表元素相等检查，无需扩展解释器。 |
| 同账号同步 | 两端命令可引用同一账号编号；并发登录与消息同步取决于服务端配置。 | 每轮通过 SDK UUID、账号在线设备列表及双端连接核验前置；被踢下线或缺少同步能力须如实报告。 |

事件字段依据 [example 回调记录](../../im_flutter_sdk/example/lib/listeners.dart)，初始化选项依据 [ChatOptions](../../im_flutter_sdk/lib/src/models/chat_options.dart)，消息回执依据 [ChatManager](../../im_flutter_sdk/lib/src/managers/chat_manager.dart)。执行端不得替 SDK 伪造通知或业务成功结果。
