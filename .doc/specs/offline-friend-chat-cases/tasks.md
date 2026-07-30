# 好友与单聊离线 Cases Implementation Plan

> **执行方式：** 在当前会话内按 `superpowers:executing-plans` 顺序执行；项目规则禁止维护第二份计划，所有状态只更新本文件。未经用户授权不创建提交。

**Goal:** 使用两台模拟器按已确认批次补齐好友关系与单聊离线 cases；当前执行第三批单聊离线能力覆盖，并根据真实 ADB/WebSocket 日志形成严格业务断言。App 强制停止和网络断开两种真实离线方式不在本批范围内。

**Architecture:** Contact、Chat 投递、Chat 后操作分别使用三个名称显式包含 `offline` 的测试文件；跨模块只共享登录态编排 helper。业务事件断言留在各模块测试中，避免 helper 隐藏真实响应。

**Tech Stack:** Python 3、pytest、现有 `DeviceConnection` WebSocket harness、Flutter SDK 通用 bridge、Android ADB/logcat。

## Global Constraints

- 不修改 `im_flutter_sdk/`、Android/iOS Wrapper 或生产 API。
- 新增 case 只放 `native-auto-test/tests/contact` 和 `native-auto-test/tests/chat`；共享流程放 `native-auto-test/src/test_flow`。
- 同步成功响应使用 `assert_response_matches` 并至少声明 manager/cmd/device/result；事件直接断言原始事件对象。
- 不忽略整个 `result`、`data` 或 `body`；动态字段只按 discovery 证据加入最小忽略集。
- 离线登录后不得 drain 事件；恢复和清理放入 `finally`。
- 每条预期必须来自本轮真实 ADB/WebSocket 日志；不稳定或缺失事件进入 deferred，不放宽成通过。

---

## Task 1：离线登录态编排 helper

**Files:**

- Create: `native-auto-test/src/test_flow/offline_test_flow.py`
- Modify: `native-auto-test/src/test_flow/__init__.py`（仅在当前包通过显式导出组织 helper 时修改）

**Interfaces:**

- Produces `logout_for_offline(device, assert_api, *, device_name: str) -> None`.
- Produces `login_preserving_offline_events(device, assert_api, *, device_name: str, user_id: str, password: str = "1") -> None`.
- Produces `restore_user_login(device, *, user_id: str, password: str = "1") -> None`.
- Produces `set_accept_invitation_always(device, assert_api, *, device_name: str, enabled: bool) -> None`.

- [x] 实现 `logout_for_offline`：操作前清理陈旧事件，调用 `Client.logout(unbindToken=false)`，严格断言 `result=true`，退出后不关闭 WebSocket 连接。
- [x] 实现 `login_preserving_offline_events`：调用 `Client.login` 并严格断言 `result=user_id`，再断言显式 `startCallback result=null`；整个登录完成后不得 drain。
- [x] 实现 `restore_user_login`：仅供 `finally` 尽力恢复，先读取当前用户；不是目标用户时 logout/login/startCallback，最后清理残留事件；恢复异常不得覆盖主体异常。
- [x] 实现 `set_accept_invitation_always`：调用 `Client.acceptInvitationAlways`，严格断言 `result=null`。
- [x] 运行：

```bash
cd native-auto-test
.venv/bin/python -m py_compile src/test_flow/offline_test_flow.py
```

预期：退出码 0。

## Task 2：Contact 离线好友关系 cases

**Files:**

- Create: `native-auto-test/tests/contact/test_contact_offline_friendship.py`
- Use: `native-auto-test/src/test_flow/offline_test_flow.py`
- Use: `native-auto-test/src/sdk_api/event_keys.py`

**Cases:**

- `test_contact_offline_invitation_received_after_login`
- `test_contact_offline_invitation_accept_after_login`
- `test_contact_offline_invitation_decline_after_login`
- `test_contact_offline_requester_receives_accept_after_relogin`
- `test_contact_offline_requester_receives_decline_after_relogin`

- [x] 写公共前置：删除双方历史好友/黑名单，显式设置 B `acceptInvitationAlways=false`，只清理本 case 前的陈旧事件。
- [x] 实现 B 离线后收到好友申请；断言 addContact 响应、B 登录后原始 `onContactInvited` 和双方非好友列表。
- [x] 实现 B 登录后同意；断言 accept 响应、真实 A/B 事件端和双方好友列表。
- [x] 实现 B 登录后拒绝；断言 decline 响应、真实 A/B 事件端和双方非好友列表。
- [x] 实现 A 离线接收同意结果；B 处理后 A 登录，按 discovery 断言离线事件和双方好友列表。
- [x] 实现 A 离线接收拒绝结果；B 处理后 A 登录，按 discovery 断言离线事件和双方非好友列表。
- [x] 每条 case 在 `finally` 恢复 A/B 默认登录、手动邀请模式和联系人清理。
- [x] 先收集和静态检查：

```bash
cd native-auto-test
.venv/bin/python -m py_compile tests/contact/test_contact_offline_friendship.py
.venv/bin/python -m pytest -q tests/contact/test_contact_offline_friendship.py --collect-only
```

预期：收集 5 条测试，无导入或 fixture 错误。

## Task 3：Chat 离线消息投递 cases

**Files:**

- Create: `native-auto-test/tests/chat/test_chat_offline_message_delivery.py`
- Use: `native-auto-test/tests/chat/_utils.py`
- Use: `native-auto-test/src/test_flow/offline_test_flow.py`

**Cases:**

- `test_chat_offline_text_message_received_after_login`
- `test_chat_offline_media_message_received_after_login`，参数 `message_type=[file,image,video,voice]`
- `test_chat_offline_cmd_message_received_after_login`
- `test_chat_offline_deliver_online_only_not_received_after_login`
- `test_chat_offline_multiple_text_messages_and_unread_count`
- `test_chat_offline_delivery_ack_after_recipient_login`

- [x] 写在线好友前置与 `finally` 清理；好友建立后再让 B logout。
- [x] 实现文本离线投递，关联同步响应临时 ID、A `onMessageSuccess` 真实 ID、B `onMessagesReceived`。
- [x] 参数化 file/image/video/voice，使用 `sendMessageWithType` 与 App 内置素材，按每类真实 body 收紧稳定字段。
- [x] 实现 CMD 离线投递，使用 `onCmdMessagesReceived`，不复用普通消息未读预期。
- [x] 实现 `deliverOnlineOnly=true` 负向场景，使用唯一 action/content、独立事件窗口和本地查询共同证明未投递。
- [x] 实现三条文本积压，关联三个真实 ID；重复日志确认单个聚合事件及顺序后，严格断言消息集合、未读数和 latest message。
- [x] 实现离线送达回执，记录发送前后事件窗口，按日志确定 `onMessagesDelivered` 的真实触发点并关联 ID。
- [x] 先收集和静态检查：

```bash
cd native-auto-test
.venv/bin/python -m py_compile tests/chat/test_chat_offline_message_delivery.py
.venv/bin/python -m pytest -q tests/chat/test_chat_offline_message_delivery.py --collect-only
```

预期：6 个测试函数，媒体矩阵展开后共 9 items。

## Task 4：Chat 离线消息后操作 cases

**Files:**

- Create: `native-auto-test/tests/chat/test_chat_offline_message_operations.py`
- Use: `native-auto-test/src/test_flow/offline_test_flow.py`

**Cases:**

- `test_chat_offline_sender_receives_message_read_after_relogin`
- `test_chat_offline_recipient_receives_recall_after_relogin`
- `test_chat_offline_recipient_receives_content_change_after_relogin`

- [x] 写发送并等待接收 helper，直接返回本次真实 msgId 和原始事件，不在 helper 内做宽松断言。
- [x] 实现 A 离线接收 B 的 `ackMessageRead`；按 ADB 断言 A 登录后的 `onMessagesRead` 和消息 read/delivery 状态。
- [x] 实现 B 收到消息后离线、A 撤回；断言撤回响应、B 登录后的 `onMessagesRecalledInfo`、`onMessagesRecalled` 和最终消息状态。
- [x] 实现 B 收到消息后离线、A 修改；断言修改响应、B 登录后的 `onMessageContentChanged` 和 `getMessage` 最终正文/ext。
- [x] 每条 case 在 `finally` 恢复登录并清理好友关系。
- [x] 先收集和静态检查：

```bash
cd native-auto-test
.venv/bin/python -m py_compile tests/chat/test_chat_offline_message_operations.py
.venv/bin/python -m pytest -q tests/chat/test_chat_offline_message_operations.py --collect-only
```

预期：收集 3 条测试。

## Task 5：真实设备 discovery 与 ADB 证据

**Files:**

- Create runtime artifacts under a timestamped `native-auto-test/out/offline_friend_chat_YYYYMMDD_HHMMSS/` directory.
- Modify assertions in the three new test files only from captured evidence.

- [x] 使用 `adb devices` 和当前 WebSocket topic 确认两台模拟器在线。
- [x] 为两台设备清空 logcat，并分别采集到输出目录。
- [x] 按 Contact 5 条、Chat delivery 9 items、Chat operations 3 条逐项运行：

```bash
cd native-auto-test
CASES_DISCOVER=1 WS_DEBUG=1 .venv/bin/python -m pytest -q tests/contact/test_contact_offline_friendship.py -s
CASES_DISCOVER=1 WS_DEBUG=1 .venv/bin/python -m pytest -q tests/chat/test_chat_offline_message_delivery.py -s
CASES_DISCOVER=1 WS_DEBUG=1 .venv/bin/python -m pytest -q tests/chat/test_chat_offline_message_operations.py -s
```

- [x] 对每条日志记录同步 response、实际事件端、eventType、业务 data、未派发事件窗口和最终服务端/本地状态。
- [x] 修改 expected 只使用日志中重复稳定的字段；减少 `ignore_keys`，不得增加多分支兼容预期。

## Task 6：strict 回归与断言审查

- [x] 逐 case 关闭 discovery 运行 strict，先修复单例失败。
- [x] 运行三个新增文件：

```bash
cd native-auto-test
.venv/bin/python -m pytest -q tests/contact/test_contact_offline_friendship.py -s
.venv/bin/python -m pytest -q tests/chat/test_chat_offline_message_delivery.py -s
.venv/bin/python -m pytest -q tests/chat/test_chat_offline_message_operations.py -s
```

- [x] 审查所有同步主断言均声明 manager/cmd/device/result。
- [x] 审查所有事件直接断言 `receive_message` 返回的原始对象，且声明 type/eventType/data 关键字段。
- [x] 审查无 actual 自证、`ne(None)`、仅类型/非空主断言、`result/data/body` 整体忽略。
- [x] 对真实缺失/不稳定能力保留失败证据并写 deferred，不使用 xfail/skip，除非用户另行确认；本批 17 items 均稳定派发，无新增 deferred。

## Task 7：台账、Kiro 状态与规范检查

**Files:**

- Modify: `native-auto-test/docs/agents/contact/CASES_RECORD.zh.md`
- Modify when blocked: `native-auto-test/docs/agents/contact/CASES_DEFERRED.zh.md`
- Modify: `native-auto-test/docs/agents/chat/CASES_RECORD.zh.md`
- Modify when blocked: `native-auto-test/docs/agents/chat/CASES_DEFERRED.zh.md`
- Modify: `.doc/specs/offline-friend-chat-cases/tasks.md`

- [x] 将每个 strict 通过 case 写入对应 RECORD；本批无真实缺失能力，无需新增 DEFERRED。
- [x] 回填逐文件结果、失败/暂缓项和 ADB 输出目录。
- [x] 运行：

```bash
cd /Users/project/im_flutter_sdk
im_flutter_sdk/scripts/speckit.sh check
git diff --check
git status --short
```

- [x] 确认只修改 Kiro spec、Python cases/helper、Contact/Chat 台账，没有修改发布 SDK、Wrapper 或无关文件。

## 验证证据

- 设备：`emulator-5554`、`emulator-5556`。
- 运行证据目录：`native-auto-test/out/offline_friend_chat_20260730/`（git ignore，仅本机保留）。
- discovery：Contact 5 items、Chat delivery 9 items、Chat operations 3 items 均完成；按日志修正媒体 `fileStatus` 和 CMD online-only 字段层级。
- strict：Contact `5 passed`（63.70s）；Chat delivery `9 passed`（325.72s）；Chat operations `3 passed`（118.07s）。
- 审查后单例：三条积压聚合事件去除 actual 自证后 `1 passed`（49.48s）。
- 最终聚合 strict：三个新增文件同一 session `17 passed`（469.21s），0 failed/skip。
- 静态/收集：四个 Python 文件 `py_compile` 退出码 0，新增文件合计 `17 tests collected`。
- 规范：`im_flutter_sdk/scripts/speckit.sh check` 全部 PASS；`git diff --check` 退出码 0。
- 交付边界：未修改 `im_flutter_sdk/` 发布 SDK、Android/iOS Wrapper 或 `im_flutter_test/`。

---

## 第二批 P0：未完成且非暂缓场景

**Goal:** 在不修改 SDK/测试 App 的前提下，继续补齐 10 个好友与单聊 P0 离线再上线 items，并以本轮真实 ADB/WebSocket 日志冻结严格预期。

### Task 8：双向好友删除

- [x] 在 `tests/contact/test_contact_offline_friendship.py` 新增“B 离线时 A 删除 B”。
- [x] 新增“A 离线时 B 删除 A”，两个方向分别建独立 case。
- [x] 严格断言删除命令、离线观察方 `onContactDeleted` 原始事件和双方服务端好友列表。
- [x] discovery 后只忽略 `sequence/timestamp` 等真实动态字段。

### Task 9：location/custom/combine 离线投递

- [x] 在 `tests/chat/test_chat_offline_message_delivery.py` 新增 location 离线投递。
- [x] 新增 custom 离线投递。
- [x] 新增 combine 离线投递，并使用两条真实源消息 ID 构造合并消息。
- [x] 严格断言发送响应、`onMessageSuccess` 和重新登录后的原始接收事件。

### Task 10：会话已读、Reaction 与消息置顶

- [x] 在 `tests/chat/test_chat_offline_message_operations.py` 新增会话级已读回执。
- [x] 分别新增 Reaction 添加和移除两个离线 case。
- [x] 分别新增消息置顶和取消置顶两个离线 case。
- [x] 通过对应查询 API 严格验证 Reaction/置顶最终状态。

### Task 11：真实设备 discovery 与严格断言

- [x] 确认两台模拟器、WebSocket topic 和账号登录态可用。
- [x] 逐一运行第二批 10 个 node，保存 ADB/WebSocket 原始日志。
- [x] 根据日志冻结 command response、eventType、业务 data 和最终查询状态。
- [x] 对未派发或不稳定能力记录真实证据并进入 deferred；本批均稳定派发，无新增 deferred。

### Task 12：回归、台账与规范检查

- [x] 运行第二批 10 items strict。
- [x] 运行三个离线文件全量 strict，确认总计 27 items。
- [x] 执行 `py_compile`、`pytest --collect-only`、断言反模式审查和 `git diff --check`。
- [x] 更新 Contact/Chat 的 RECORD；本批没有真实阻塞，无需更新 DEFERRED。
- [x] 执行 `im_flutter_sdk/scripts/speckit.sh check` 并回填本轮验证证据。

## 第二批 P0 验证证据

- 设备：`emulator-5554`、`emulator-5556`；测试 App 进程均在线。
- discovery/ADB 目录：`native-auto-test/out/offline_p0_20260730_AZaG1M/`（git ignore，仅本机保留）。
- discovery：Contact 删除 2、Chat 投递 3、Chat 后操作 5，共 10 items；全部获取到真实离线回放事件和最终查询状态。
- 日志修正：combine 构造响应/发送成功/离线接收的 `fileStatus=3/1/3`；Reaction 移除事件保留 `count=0` 聚合项，最终查询为空。
- 新增 P0 strict：`10 passed`（317.18s），0 failed/skip。
- 三个离线文件完整 strict：`27 passed`（775.00s），0 failed/skip。
- 静态/收集：三个 Python 文件 `py_compile` 退出码 0，`27 tests collected`。
- 断言审查：无 `assert_success` 主断言、`ne(None)`、actual 自证 expected 或整体忽略 `result/data/body`。
- 规范：`git diff --check` 退出码 0；`im_flutter_sdk/scripts/speckit.sh check` 全部 PASS。
- 交付边界：未修改发布 SDK、Android/iOS Wrapper 或 `im_flutter_test`；暂缓的好友自动同步未纳入。

---

## 第三批：单聊离线能力全覆盖（不含已暂缓和端侧真实离线）

**Goal:** 补齐现有 SDK/测试桥接可稳定驱动的单聊离线业务差异场景，不覆盖 CMD delivery receipt、非 CMD online-only、显式翻译正常结果、强制停止 App、网络断开或现有桥接缺口。

### Task 13：扩展投递与同步状态 cases

**Files:**

- Create: `native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py`
- Use: `native-auto-test/tests/chat/test_chat_offline_message_delivery.py`
- Use: `native-auto-test/src/test_flow/offline_test_flow.py`

- [x] 先为每个候选节点建立最小 discovery 测试骨架，只发送一条唯一业务标识消息，并记录 A 的发送响应、B 的离线回放、A 的送达事件和最终查询结果。
- [x] 基于 discovery 分别实现 file/image/video/voice/location/custom/combine 的离线上线后送达回执参数化矩阵；主断言固定真实 msgId、`hasDeliverAck` 与真实 `onMessagesDelivered` 字段。
- [x] 基于 discovery 实现带 `targetLanguages` 的离线文本自动翻译同步结果；只断言服务端返回的稳定目标语言和翻译正文。
- [x] 基于 B 离线回放的原始消息对象实现 file/image/video/voice 的附件下载，并为 image/video 增加缩略图下载；断言下载命令响应与真实稳定文件状态，不拼装消息对象。
- [x] 实现 text/location/custom/combine 混合积压：以消息 ID 集合接收回放事件，再对 `getMessage`、历史查询、未读数和最新消息做最终一致性断言。

### Task 14：扩展离线后操作 cases

**Files:**

- Create: `native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py`
- Use: `native-auto-test/tests/chat/test_chat_offline_message_delivery.py`
- Use: `native-auto-test/src/test_flow/offline_test_flow.py`

- [x] 先分别 discovery 首次投递前文本撤回与文本修改，确认 B 重登后“原消息、撤回/修改事件、本地最终状态”的实际组合，再冻结单一语义断言。
- [x] 基于 discovery 实现 file/image/video/voice/location/custom/combine 的离线单条已读参数化矩阵；每项关联真实 msgId 与 A 重登后的 `onMessagesRead`。
- [x] 基于 discovery 实现 file/image/video/voice/location/custom/combine 的离线撤回参数化矩阵；每项直接断言 `onMessagesRecalledInfo` 及本地最终状态。
- [x] 基于 discovery 实现 custom body 修改和 file/image/video/voice ext 修改；按类型断言 `onMessageContentChanged` 的真实 body/ext 与 B 本地最终消息。

### Task 15：真实设备 discovery、strict 与台账

- [x] 对 Task 13/14 的差异分支和矩阵代表节点采集双设备 WebSocket/ADB 日志，先 discovery 后 strict；同结构参数节点以全矩阵 strict 验证真实 body，不为相同 schema 重复制造一份日志文件。
- [x] 将真实稳定字段写入 expected；仅保留时间、路径、URL、secret 等最小动态忽略。
- [x] 真实无回调或无稳定能力的 node 不得 xfail/弱化，写入 Chat DEFERRED 并保留日志证据；本批 video 缩略图真实返回 403，作为严格错误语义覆盖，无新增 deferred。
- [x] 更新 Chat RECORD/DEFERRED 和本 tasks 文件，执行扩展文件与既有 27 items 严格回归；扩展投递 13 items 同轮通过，扩展后操作 20/21 同轮通过且唯一修正节点单点通过，既有 27 items 同轮通过。用户确认无需再次完成修正后的 21 items 整文件复跑。
- [x] 执行 `py_compile`、`pytest --collect-only`、断言反模式扫描、`git diff --check` 和 `im_flutter_sdk/scripts/speckit.sh check`。

## 第三批验证证据

- 设备与账号：两台 Android 模拟器 `emulator-5554`、`emulator-5556`，使用 `deviceA/userA` 与 `deviceB/userB` 的 SDK logout/login 离线窗口；未覆盖 App 强停和网络断开。
- 收集与静态：两个扩展文件 `py_compile` 退出码 0，合计 `34 tests collected`；断言反模式扫描未发现 `ne(None)`、`assert_success`、actual 自证 expected、整体忽略 `result/data/body` 或 `is not None` 主断言。
- 扩展投递 strict：`13 passed`（500.05s），包括 7 类送达、自动翻译、4 类附件/缩略图下载和混合积压最终一致性。
- 扩展后操作 strict：整文件首轮 `20 passed, 1 failed`（782.47s）；唯一 voice 撤回失败由真实 `fileStatus=3` 与旧预期 `0` 不符导致，修正后该 node `1 passed`（51.18s）。之后启动的整文件复跑在 `3 passed` 时按用户指示停止，不计作完整通过证据。
- 既有专项回归：Contact + 原 Chat delivery + 原 Chat operations 合计 `27 passed`（779.45s），0 failed/skip。
- 规范：`git diff --check` 退出码 0；`im_flutter_sdk/scripts/speckit.sh check` 的 Android/iOS 依赖检查全部 PASS。
- 真实日志结论：首次接收前撤回只回放无 `msg` 的 recall info 和空 recalled messages；首次接收前修改直接回放最终正文；voice 初收/修改/撤回分别为 `fileStatus=0/1/3`；image 缩略图成功，video 缩略图真实返回 403；历史拉取会重载旧漫游消息，因此混合积压未读数在历史拉取前断言为 4。
- 台账：Chat RECORD 已新增 174-186；本批没有新增 skip/xfail 或能力缺口，既有 CMD delivery、显式翻译正常结果等 deferred 保持不变。
- 交付边界：仅修改 Kiro spec、两个 Python 扩展 case 文件和 Chat 台账；未修改发布 SDK、Android/iOS Wrapper 或 `im_flutter_test`。
