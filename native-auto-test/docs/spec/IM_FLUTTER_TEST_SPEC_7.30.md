# 跨平台多版本 SDK 自动化测试框架 Spec 7.30

## 1. 目标与边界

- 复用 `native-auto-test/tests` 现有 Case。
- 不经过 `im_flutter_sdk` Dart 业务层。
- 业务调用必须经过 `im_flutter_sdk_interface`。
- Android 使用当前 `im_flutter_sdk_android + Android SDK 4.23` 作为基线。
- 后续版本只维护 API 新增、删除和变化。
- 支持单设备、同账号多设备、异账号多设备。
- WebSocket 服务由 `native-auto-test` 提供。
- 支持 REST 数据准备、离线和覆盖安装。

调用链：

```
native-auto-test Case
→ native-auto-test WebSocket Server
→ im_flutter_test
→ InterfaceRouter
→ im_flutter_sdk_interface
→ 版本对应的平台 Wrapper
→ 对应平台原生 SDK
```

模块职责：

| 模块 | 职责 |
|---|---|
| `native-auto-test` | Case、WS、调度、准备数据、能力判断、报告 |
| `im_flutter_test` | WS 客户端、interface 路由、Runner 信息 |
| `im_flutter_sdk_interface` | Client、Manager、Channel |
| 平台 Wrapper | JSON 转换、原生 API 调用、事件回传 |
| 原生 SDK | 真正被测对象 |

测试专用 `TestControlChannel` 只负责 Runner 信息、网络控制和升级快照，
不重复实现登录、联系人、消息、群组等业务 API。

---

## 2. Case 分类与设备槽位

框架固定提供六个逻辑设备槽位：

| 逻辑设备 | 默认账号 | 用途 |
|---|---|---|
| `device_a` | `account_a` | A 账号主设备 |
| `device_a_sec` | `account_a` | A 账号第二设备 |
| `device_b` | `account_b` | B 账号主设备 |
| `device_b_sec` | `account_b` | B 账号第二设备 |
| `device_c` | `account_c` | C 账号主设备 |
| `device_c_sec` | `account_c` | C 账号第二设备 |

六个槽位是可用上限，不是每次必须启动六台设备。pytest 收集本次选中的
Case 后，根据 fixture 名称计算需要的槽位，只启动这些槽位；同一槽位在本次
测试会话中复用。

普通 Case 不再单独填写设备数量、Actor、Observer 或 Case 元数据。其函数参数
就是设备需求，也是框架的自动调度依据。

报告中的 Case 类型也由 fixture 自动推导：

- 只有一个 `device_*`：单设备。
- 同时出现同字母主、次槽位：同账号多设备。
- 同时出现不同字母槽位：异账号多设备。
- 两种关系同时存在：组合多设备。

### 2.1 单设备

一个 Runner 独立完成操作和验证。

```
准备数据 → device_a 登录 account_a → 调用 API → 检查响应或状态
```

适用于查询、本地会话、用户属性和设置类 API。分类依据是“是否需要其他
Runner 参与”，不只根据 API 是否以 `get` 开头判断。

```python
def test_query(device_a):
    ...
```

### 2.2 同账号多设备

只要使用同一账号的主、次槽位，就是同账号多设备：

```
device_a     → account_a
device_a_sec → account_a
```

适用于多设备登录、会话/消息/已读同步和踢下线。两个 Runner 可以使用
不同平台或不同 SDK 版本。

```python
def test_multi_device_sync(device_a, device_a_sec):
    # device_a_sec 先监听，device_a 再操作
    ...
```

同账号多设备 Case 也可以有第三方参与。例如 B 给 A 发消息，再检查 A 的两台
设备是否都收到：

```python
def test_multi_device_receive(
    device_a,
    device_a_sec,
    device_b,
):
    ...
```

需要同时验证两个账号的多设备同步时，可使用
`device_a/device_a_sec/device_b/device_b_sec`。

### 2.3 异账号多设备

使用不同字母的设备槽位表示不同账号：

适用于好友申请、消息收发、群邀请和群成员操作。“异设备”表示账号不同，
不要求平台必须不同。

```python
def test_add_contact(device_a, device_b):
    # device_b 先监听，device_a 再操作
    ...
```

三账号场景直接增加 `device_c`：

```python
def test_group_flow(device_a, device_b, device_c):
    ...
```

若未来一个账号需要三台以上设备，再提供集合式 fixture，例如
`device_a_replicas`；不继续增加 `_third/_fourth` 命名。

---

## 3. Scenario

Runner、Account、Artifact 必须分开建模：

```
Runner != Account
Runner != Artifact
```

同一个 Artifact 可以安装到多个 Runner；同一个 Account 可以登录多个 Runner。
逻辑设备名保持稳定，平台、SDK 版本、物理设备和 Artifact 由 Scenario 绑定。

```yaml
name: android-423-424

accounts:
  account_a:
    provision: rest
  account_b:
    provision: rest
  account_c:
    provision: rest

devices:
  device_a:
    runner_id: android-423-a
    platform: android
    sdk_version: 4.23.0
    account: account_a
    serial: emulator-5554

  device_a_sec:
    runner_id: android-424-a-sec
    platform: android
    sdk_version: 4.24.0
    account: account_a
    serial: emulator-5556

  device_b:
    runner_id: android-424-b
    platform: android
    sdk_version: 4.24.0
    account: account_b
    serial: emulator-5558

  device_b_sec:
    runner_id: web-480-b-sec
    platform: web
    sdk_version: 4.8.0
    account: account_b

  device_c:
    runner_id: ios-423-c
    platform: ios
    sdk_version: 4.23.0
    account: account_c
    serial: simulator-c
```

Scenario 可以声明六个槽位，但只实例化本次 Case 集合实际引用的槽位：

```
单设备：device_a
异账号：device_a + device_b
同账号：device_a + device_a_sec
同账号加第三方：device_a + device_a_sec + device_b
两个账号各双设备：device_a + device_a_sec + device_b + device_b_sec
三个账号：device_a + device_b + device_c
```

现有 Case 的 `device_a/device_b` 参数保持不变。第一阶段新增
`device_a_sec/device_b_sec/device_c/device_c_sec` fixture，不批量修改已有 Case。

### 3.1 设备池与逻辑槽位

Scenario 中的 `device_*` 是 Case 使用的逻辑槽位，不等于固定的一台模拟器。
`native-auto-test` 维护可复用的物理设备池，调度器根据平台、系统版本和状态为
逻辑槽位租用设备：

```
Case fixture → 逻辑槽位 → 设备池租用物理设备 → 安装 Artifact → Runner
```

- 配置了 `serial` 时使用指定设备；未配置时从设备池选择满足条件的空闲设备。
- 一个物理设备同一时间只能绑定一个逻辑槽位。
- 同一测试会话内保持绑定并复用，结束后释放。
- 设备不足、平台不匹配或设备不健康时，在 Case 执行前报告 Environment Error。

设备池至少提供启动器所需的信息：

```yaml
device_pools:
  android:
    - id: android_01
      type: emulator
      avd_name: Pixel_6_API_35
      serial: emulator-5554
  ios:
    - id: ios_01
      type: simulator
      udid: simulator-udid
```

Scenario 配置了 `serial/udid` 时固定使用该设备；否则调度器从对应平台池中自动
选择空闲设备。

### 3.2 自动启动与运行入口

用户只选择 Case 和 Scenario，不手动启动模拟器、不手动安装或启动
`im_flutter_test`：

```bash
pytest tests/user_info/test_user_info.py \
  --scenario config/scenarios/android_423.yaml
```

一次 pytest 运行使用一个 Scenario。`native-auto-test` 的 Orchestrator 负责：

```
读取 Scenario
→ 收集 Case 直接声明的 device fixture
→ 计算设备和 Artifact 并集
→ 启动 WS Server
→ 从设备池租用设备
→ 复用已运行设备或自动启动模拟器
→ 安装对应 Artifact
→ 启动 im_flutter_test
→ 注入 wsUrl、runId、runnerId 和 logicalDevice
→ 等待并校验 Runner Hello
→ 登录账号
→ 执行 Case
```

平台启动责任：

| 平台 | Orchestrator 行为 |
|---|---|
| Android 模拟器 | 自动启动 AVD、等待 ADB、安装 APK、启动 Activity |
| Android 真机 | 校验在线、安装 APK、启动 Activity |
| iOS 模拟器 | 自动 boot、安装并 launch App |
| iOS 真机 | 校验在线、安装并启动已签名 App |
| Web | 启动 Web 服务和浏览器页面 |
| macOS/OHOS | 由对应平台启动器安装并启动 Runner |

模拟器可以自动启动；真机必须提前开机并连接。普通 Case 不执行任何设备启动、
安装或登录命令。

启动策略由 Scenario 配置：

```yaml
runner:
  device_ready_timeout: 120
  hello_timeout: 30
  start_retry: 1
  keep_device_alive: true
```

- 已运行设备优先复用，未运行模拟器自动启动。
- Session 内设备、Runner 和登录状态只准备一次。
- `keep_device_alive: true` 时 Session 结束后释放租约但保留模拟器运行。
- `keep_device_alive: false` 时只关闭本次自动启动的模拟器，不关闭原本已运行的设备。
- 重试后设备或 Hello 仍未就绪时，业务 Case 不执行并报告 Environment Error。

### 3.3 账号生命周期

Scenario 只声明账号槽位，不在普通 Case 中创建账号或填写固定用户名：

```yaml
accounts:
  account_a:
    provision: rest
  account_b:
    provision: rest
```

`provision: rest` 时，Orchestrator 按 `runId + accountSlot` 自动生成用户名和密码，
通过 REST 创建账号，并将凭据提供给现有 `user_a/user_b/user_c` fixture。
同一账号的主、次设备使用同一份凭据：

```
device_a + device_a_sec → account_a
device_b + device_b_sec → account_b
```

Session 结束时只删除本次自动创建的账号及其登记资源。必须使用固定账号时配置
`provision: existing`；框架负责登录但不得删除该账号。账号创建、登录或清理
失败必须写入 Allure，密码和 Token 不得写入日志。

---

## 4. WebSocket

WS Server 由 `native-auto-test` 在测试会话开始时启动、结束时关闭。同一次
pytest Session 中的所有 Case 共用一个 WS Server、一个 `runId` 和已经注册的
Runner；不为每条 Case 重启 WS 或重新连接 Runner。

```
启动 WS Server
→ 启动 Runner
→ Runner 主动连接并发送 Hello
→ Server 按 runnerId 注册
→ pytest 向 targetRunnerId 发请求
```

Hello 至少包含：

```json
{
  "runId": "run-001",
  "runnerId": "android-423-a",
  "logicalDevice": "device_a",
  "accountSlot": "account_a",
  "artifactId": "android-4.23.0-abc1234",
  "platform": "android",
  "sdkVersion": "4.23.0",
  "appVersion": "1.0.0",
  "capabilities": []
}
```

规则：

- `runId` 隔离不同测试会话。
- `runnerId` 唯一定位一个 Runner。
- `logicalDevice` 用于将 Case fixture 映射到 Runner。
- `caseId` 唯一标识一条 Case，`requestId` 唯一标识一次 API 调用。
- 请求按 `targetRunnerId` 精确路由，不能只按 topic 广播。
- Runner 平台或版本与 Scenario 不一致时，业务 Case 不得开始。
- Runner 断线重连后必须使用原 `runId + runnerId` 重新注册。
- 外部 WS 仅作为兼容模式，不作为默认依赖。

### 4.1 WS 地址与 topic

默认使用 `managed` 模式：

```yaml
websocket:
  mode: managed
  bind_host: 0.0.0.0
  port: 0
```

`port: 0` 表示自动选择空闲端口。Orchestrator 启动 WS 后，根据运行平台生成
Runner 可访问的 `wsUrl`，并同时注入 Python 客户端和 `im_flutter_test`：

```
Python 客户端   → 127.0.0.1:实际端口
Android 模拟器  → 10.0.2.2:实际端口
iOS/Web         → 宿主机可访问地址:实际端口
真机            → 宿主机局域网地址:实际端口
```

managed 模式按 `runId + runnerId` 保存连接并精确路由，不使用 topic；用户、
Scenario 和 Case 均不配置 `base_url` 或 topic。

兼容现有外部 WS 时使用：

```yaml
websocket:
  mode: external
  base_url: ws://140.143.132.6:2000/iov/websocket/dual
```

如果外部服务要求 topic，Orchestrator 按 `runId + logicalDevice` 自动生成唯一
topic，并注入测试端和对应 Runner。Case 不读取或拼接 topic。外部 `base_url`
只在 `external` 模式下由环境配置提供。

### 4.2 Request、Response 与 Event

Python 发出的 Request：

```json
{
  "type": "request",
  "protocolVersion": 1,
  "runId": "run-001",
  "caseId": "case-001",
  "requestId": "req-001",
  "targetRunnerId": "android-423-a",
  "manager": "ContactManager",
  "cmd": "addContact",
  "info": {
    "userId": "user-b",
    "reason": "hello"
  }
}
```

Runner 返回的 Response：

```json
{
  "type": "response",
  "protocolVersion": 1,
  "runId": "run-001",
  "caseId": "case-001",
  "requestId": "req-001",
  "runnerId": "android-423-a",
  "success": true,
  "result": {},
  "error": null
}
```

Response 是一次 API 调用的直接结果，通过 `requestId` 与 Request 匹配。Event
是原生 SDK 主动产生的异步回调，例如收到消息、好友申请、群邀请、连接状态和
多设备同步。

Event 至少包含：

```json
{
  "type": "event",
  "runId": "run-001",
  "runnerId": "android-423-a",
  "eventId": 106,
  "eventType": "onMessagesReceived",
  "occurredAt": 1785390000000,
  "data": {
    "messageId": "msg-001",
    "testTraceId": "trace-001"
  }
}
```

`info/result/error/data` 必须是 JSON 可编码类型。平台 Wrapper 负责原生对象与
Map/JSON 的 encode/decode。每个 Request 必须且只能返回一个 Response；SDK
异步回调单独作为 Event 上报。

原生事件不一定携带发起 API 的 `requestId` 或当前 `caseId`。事件断言必须同时
使用本 Case 的事件游标、`eventType` 和业务唯一字段，例如 `messageId`、
`groupId`、`userId` 或测试注入的 `testTraceId`。

---

## 5. 环境准备、场景准备与 Case 流程

### 5.1 会话环境准备

pytest 收集选中的 Case 后，Orchestrator 读取 Case 直接声明的设备 fixture，
计算设备槽位和 Artifact 并集，然后按 Session 执行：

```
收集 Case fixture
→ 计算所需 device_a/b/c 与 _sec 槽位
→ 计算所需 Artifact
→ 自动启动 managed WS，或连接 external WS
→ 准备 Artifact
→ 从设备池租用设备
→ 复用已运行设备或自动启动模拟器
→ 自动安装 Artifact 并启动 im_flutter_test
→ 等待 Hello
→ 校验平台、版本和能力
→ 检查 REST 与 AppKey
→ 按槽位登录对应账号
```

设备不在单条 Case 内冷启动。后续 Case 复用已经注册并登录的 Runner；只有
覆盖安装、进程重启或明确要求重置设备状态的 Case 才触发设备级操作。

环境准备失败属于 `Broken / Environment Error`，不属于 SDK API Failed。

当前 `global_login_logout` 会强制依赖 `device_a/device_b`，导致单设备 Case 也
被识别为需要两台设备。实现时必须改为：收集阶段只统计测试函数直接声明的
`device_*` fixture，Session 开始时对设备并集一次性启动并登录，后续 Case
复用设备、Runner 和登录状态。

主动 logout、覆盖安装、断网或重启进程的 Case 必须独占对应 Runner，并在
teardown 恢复到 Scenario 规定的登录和网络状态，避免污染后续 Case。

### 5.2 Case 场景准备

按 Case 需要，通过 REST 或 SDK 准备：

- 账号、群组、聊天室和成员关系。
- 联系人、黑名单和邀请关系。
- 消息、会话和本地数据。
- 管理员、禁言、白名单和公告。

规则：

1. 查询类 API 优先使用 REST 准备数据。
2. 被测 API 不能用于证明自身正确。
3. 本地数据库数据使用 SDK 或 TestControlChannel 准备。
4. 事件型 Case 必须先建立本 Case 的事件监听上下文，再执行操作。
5. 创建资源必须登记并在 teardown 清理。

### 5.3 事件隔离

每条 Case 在所用 Runner 上记录开始时的事件游标，只消费游标之后的新事件：

```
记录 eventCursor
→ 建立本 Case 的监听条件
→ 操作方执行 API
→ 按 eventId + eventType + 业务唯一字段匹配
→ Case 结束后关闭监听上下文
```

事件隔离只处理 `native-auto-test` 中的回调队列，不删除 SDK 消息、会话或
本地数据库。简单 `drain_events()` 只能作为 MVP；正式实现以事件游标和过滤
条件为准。

离线 Case 必须在断网前建立监听，恢复网络后继续使用原事件游标；恢复网络后
不得清理事件，否则可能丢弃正在验证的离线同步回调。

### 5.4 完整流程

会话级流程：

```
1. pytest 收集选中的 Case
2. 从 fixture 自动推导所需逻辑设备
3. 合并得到设备和 Artifact 并集
4. Orchestrator 自动启动 WS、模拟器和 im_flutter_test
5. 校验 Hello、平台、版本和能力
6. REST 创建所需账号
7. 按逻辑设备槽位登录账号
```

每条 Case 流程：

```
1. 从函数参数取得已就绪的 device fixture
2. REST/SDK 准备业务数据
3. 为接收方建立事件游标和本 Case 的监听条件
4. 操作方执行被测 API
5. 收集响应、事件和最终状态
6. 断言并写入 Allure
7. 清理本 Case 创建的数据
```

现有 Case 继续使用：

```python
device.call(manager, cmd, info)
device.receive_message(...)
```

普通 Case 不处理平台、版本、构建、账号创建和 WS 地址，也不声明设备数量；
直接使用所需的 `device_*` fixture。现有 Case 不读取 `base_url`、topic、用户名
或密码；这些值由 fixture 和 Orchestrator 提供。

---

## 6. API、Wrapper 与构建管理

### 6.1 API Matrix

API Matrix 管理“某版本支持什么 API”：

```yaml
base:
  version: 4.23.0
  apis:
    - Client.login
    - ContactManager.addContact

versions:
  4.24.0:
    added:
      - ChatManager.newApi
    removed:
      - ChatManager.oldApi
    changed:
      ContactManager.addContact:
        adapter: add_contact_v424
```

```
Base + added - removed ~ changed = 当前版本能力
```

| 情况 | 结果 |
|---|---|
| API 支持 | 执行 |
| 明确不支持 | Skip |
| 版本未知 | Framework Error |
| Matrix 与 Runner 冲突 | Framework Error |
| API 真实调用失败 | Failed |

### 6.2 Wrapper

Wrapper 管理“该版本的 API 怎么调用”：

```
JSON → 原生参数/对象 → 原生 SDK → Map/JSON 结果和事件
```

Android 以当前4.23 Wrapper 为基线：

```
4.23 基线
→ 4.24 只维护相对4.23的变化
→ 4.25 只维护相对4.24的变化
```

每个 SDK 版本必须对应一份可编译的 Wrapper 源码状态。不能在同一个 APK
中运行时调用另一个版本不存在的方法。

SDK Diff 用于发现新增、删除、参数和 Model 变化；人工审核后更新 API Matrix
和 Wrapper。

### 6.3 Artifact

一个 Artifact 对应：

```
platform + sdkVersion
```

```
runner-android-4.23.apk
runner-android-4.24.apk
runner-web-4.8/
```

同版本双设备只构建一次、安装到两个 Runner；不同版本或平台使用不同 Artifact。

每个 Artifact 必须生成 Manifest，不能只依赖文件名判断版本：

```json
{
  "artifactId": "android-4.23.0-abc1234",
  "platform": "android",
  "sdkVersion": "4.23.0",
  "appVersion": "1.0.0",
  "wrapperCommit": "abc1234",
  "nativeSdkSha256": "sha256-value",
  "capabilities": [
    "Client.login",
    "ContactManager.addContact"
  ]
}
```

Orchestrator 必须校验 Scenario、Artifact Manifest、Runner Hello 和 API Matrix
四者的平台、SDK 版本及能力一致；任一冲突都在业务 Case 开始前报告
Framework Error。Artifact 缓存键至少包含
`platform + sdkVersion + wrapperCommit + nativeSdkSha256`。

---

## 7. 离线与覆盖安装

离线和覆盖安装是 Case 运行条件，不新增 Case 类型。

离线：

```
Runner 断网
→ 其他 Runner 制造数据
→ 恢复网络
→ 验证离线数据和同步
```

覆盖安装：

```
旧版本制造本地数据
→ 导出快照
→ adb install -r 新版本
→ 不卸载、不清数据
→ 校验新版本 Hello
→ 比较快照
→ 恢复网络验证同步
```

---

## 8. 结果与验收

环境问题在 Allure 中统一记为 `Broken`，并附加
`errorKind=EnvironmentError`，与 SDK 业务失败区分。

| 情况 | 分类 |
|---|---|
| WS、设备、构建、REST 准备失败 | Broken / Environment Error |
| Runner 平台或版本不符 | Broken / Environment Error |
| API 明确不支持 | Skipped |
| Matrix 缺失或冲突 | Framework Error |
| 被测 API 或事件验证失败 | Failed |

Allure 必须记录：

- Case 类型和 Scenario。
- Logical Device、Runner、Account 绑定。
- 平台、SDK 版本和 Capability。
- 请求、响应、事件、requestId、eventId 和事件匹配字段。
- 环境/场景准备和清理结果。
- 离线或升级快照。

第一阶段以 Android 4.23 为基线并接入一个后续版本。以下项目全部通过才算
第一阶段完成；环境失败不能代替功能验收，预期 Skip 只允许用于 Matrix 明确
标记为不支持的 API。

| ID | 验收项 | 必须提供的证据 |
|---|---|---|
| AC-01 | managed WS 自动启动 | 不配置 `base_url/topic` 完成测试；日志包含自动端口、`runId` 和 Runner 注册 |
| AC-02 | WS 复用与精确路由 | 多条 Case 共用同一 WS；向两个 Runner 并发请求，无串响应或串事件 |
| AC-03 | external WS 兼容 | 使用外部 `base_url` 跑通双 Runner；日志证明 topic 按逻辑设备自动生成 |
| AC-04 | 账号生命周期 | REST 自动创建、登录、复用并清理账号；同账号双设备用户名一致，固定账号未被删除 |
| AC-05 | 自动设备调度 | 仅执行 pytest 命令即可自动启动至少两个 Android 模拟器、安装 App、完成 Hello 和登录 |
| AC-06 | 按需启动与复用 | 单设备集合不启动 B；混合集合只启动 fixture 并集；Session 内不重复安装、启动或登录 |
| AC-07 | 现有 Case 兼容 | 未修改业务逻辑的 `test_user_info.py` 和至少一条现有 A/B Case 通过 |
| AC-08 | 三类 Case | 单设备、`device_a + device_a_sec`、`device_a + device_b` 各至少一条通过 |
| AC-09 | 复杂拓扑 | `device_a + device_a_sec + device_b` 第三方参与 Case 通过；六个逻辑槽位均可配置 |
| AC-10 | 协议与事件隔离 | Request 仅有一个 Response；连续事件 Case 不消费历史事件；离线同步事件不被误清理 |
| AC-11 | 多版本 API | 4.23 与后续版本分别验证一个新增、删除、参数变化 API；不支持项按 Matrix Skip |
| AC-12 | Artifact 真实性 | 新旧版本使用独立 Artifact；Manifest、Hello、Matrix 和原生 SDK Hash 校验一致 |
| AC-13 | 场景准备 | REST 自动准备并清理账号、群组等资源；Case 失败后 teardown 仍执行并留下清理结果 |
| AC-14 | 离线与覆盖安装 | 一条离线恢复 Case 和一条 4.23 到后续版本的 `install -r` 覆盖安装 Case 通过 |
| AC-15 | Allure 可诊断 | 报告可定位 Scenario、逻辑设备、Runner、账号、版本、API、请求、响应、事件和失败类型 |

后续扩展 Web、iOS、macOS、OHOS 时，不修改普通业务 Case 和统一协议。
