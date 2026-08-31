# IM Flutter SDK 5.0 自动化测试

## 这个项目做什么

用一套 Python pytest 用例，验证 Android、iOS、Web 5.0 的：

**API 响应 · 事件回调 · 本地状态 · 多设备 · 离线恢复**

## 项目建设内容

- 以 SDK 5.0 为基准，整理三端统一业务协议和 Wrapper 映射；
- 把 Case 统一为单端、双端、多设备拓扑、离线四类；
- 增加 `sender`、`recipient`、同账号副端等角色，验证事件实际投递端；
- 覆盖 Chat、Group、Chatroom、Contact、Push、UserInfo 等主要模块；
- 记录 Android/iOS 原生差异，区分 Case、Wrapper、SDK/服务端问题。

## 测试流程

```mermaid
flowchart LR
    A[Scenario: 设备/账号] --> B[测试 App 或 Web Runner]
    B --> C[WebSocket 桥接]
    C --> D[pytest 发送统一协议]
    D --> E[平台 Wrapper 调用原生 SDK]
    E --> F[校验响应、事件、最终状态]
```

## 代表性 Case

### 1. Chat 离线消息

代表用例：`test_chat_offline_multiple_text_messages_and_unread_count`

**测试目标：**验证接收端离线期间的消息是否能够完整恢复，而不是只验证发送接口成功。

- **前置：**A、B 建立好友关系；B 账号的全部接收设备清理目标会话的本地消息并退出登录。
- **操作：**A 连续发送多条文本消息，确认每条消息都成功发送并记录真实 `msgId`。
- **恢复：**B 账号的全部接收设备重新登录，分别等待离线消息同步和 `onMessagesReceived` 事件。
- **断言：**逐设备校验消息数量、内容、顺序、真实 `msgId`、会话未读数以及恢复后的本地会话状态。
- **价值：**覆盖离线消息补投、批量消息同步和未读数更新，能够发现消息漏投或历史状态污染。

### 2. 多设备已读回执

代表用例：`test_chat_offline_combine_message_read_after_sender_relogin`

**测试目标：**验证同一账号多设备在离线期间产生的已读回执，重新登录后是否正确同步到发送方设备。

- **前置：**A、B 可以各自配置多个设备；B 账号的一个或多个设备收到需要已读回执的合并消息；A 账号的全部设备退出登录。
- **操作：**B 调用发送已读回执接口，确认回执请求成功。
- **恢复：**A 账号的全部设备重新登录，分别监听每个设备，而不是只检查动作设备。
- **断言：**逐设备校验 `onMessagesRead` 的消息 ID、发送方、接收方、会话 ID、已读状态和消息正文。
- **价值：**覆盖离线回执同步和同账号多端事件投递，能区分“回执接口成功”和“目标设备真正收到事件”。

### 3. Chat 普通多设备消息收发

代表用例：`test_chat_missing_location_message_send_receive`

**测试目标：**验证 A、B 两个账号的全部在线设备，在普通在线发送场景下是否都能收到正确的消息同步；

- **前置：**A、B 建立好友关系；Scenario 为 A、B 分别配置一个或多个在线设备，并清空所有设备的历史事件。
- **操作：**A 账号选择一个动作设备发送位置消息，记录发送响应中的临时 ID 和 `onMessageSuccess` 中的真实 `msgId`。
- **A 账号校验：**动作设备校验 `sendMessage` 和 `onMessageSuccess`；A 账号的其他全部设备逐一校验 `onMessagesReceived`，并通过本地消息查询确认消息已经落库。
- **B 账号校验：**B 账号的全部接收设备逐一校验 `onMessagesReceived`，确认每个设备都收到同一个真实 `msgId` 和相同的位置内容。
- **价值：**验证“发送端动作设备、发送端其他设备、接收端全部设备”三类端点，避免只验证 A→B 的单条链路。

> 文档中的 A、B、C 表示账号，不表示设备数量。每个账号实际包含多少设备由 Scenario 决定；Case 使用 `sender_devices`、`recipient_devices` 等设备集合逐端验证。

这些 Case 不只验证“接口返回 true”，还验证了跨端事件、离线恢复、本地状态和最终业务结果。

## 成员只需记住

```text
先选 Scenario
→ 明确单端/双端/拓扑/离线
→ 写清前置、动作、事件、状态、清理
→ 统一协议，平台 Wrapper 映射原生 API
→ 不为了 pass 伪造原生结果
```

详细运行方式看 `README.md`，平台差异看 `docs/Android5.0.md` 和 `docs/ios5.0.md`，Case 清单看 `docs/test-case-report/现有Case说明.md`。
