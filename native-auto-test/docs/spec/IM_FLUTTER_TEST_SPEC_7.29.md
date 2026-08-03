# 跨平台多版本 SDK 自动化测试框架 Spec

## 1. 目标

基于现有 Python 用例，建设一套跨平台、多版本 SDK 自动化测试框架。

框架需要支持：

- 最大程度复用现有 `native-auto-test/tests` 用例。
- 保留 `im_flutter_test` 作为设备端测试执行器。
- 不经过 `im_flutter_sdk` 业务封装层。
- 所有 SDK 调用必须经过 `im_flutter_sdk_interface`。
- 支持 Android、Web，以及后续 iOS、macOS、OHOS。
- 支持不同 SDK 版本、API 差异、能力判断、自动跳过和覆盖安装测试。

---

## 2. 核心约束

- 不修改 `im_flutter_sdk`。
- 不依赖 `im_flutter_sdk` 中的 `EMClient`、`EMMessage` 等业务 API。
- 设备端必须通过 `im_flutter_sdk_interface` 调用平台实现。
- 现有用例继续使用：

```python
device.call(manager, cmd, info)
```

- 普通用例不处理平台和版本差异。
- 只有当前 Runner 明确声明 API 不支持时，才允许自动 Skip。

---

## 3. 总体架构

```text
native-auto-test/tests
        |
        | WebSocket：manager / cmd / info
        v
im_flutter_test
        |
        | Client.instance + Manager.callNativeMethod()
        v
im_flutter_sdk_interface
        |
        v
各平台实现
├── Android
├── Web
├── iOS
├── macOS
└── OHOS
        |
        v
对应平台 SDK
```

各模块职责：

| 模块 | 作用 |
|---|---|
| `native-auto-test` | 用例、断言、调度、报告 |
| `im_flutter_test` | WebSocket、命令路由、事件转发 |
| `im_flutter_sdk_interface` | 平台实例、Manager 入口、Channel 定义 |
| 平台实现 | 调用真实 SDK，统一结果和事件格式 |
| Orchestrator | 启动环境、安装产物、绑定设备角色、管理升级 |

---

## 4. 稳定测试协议

Python 用例继续发送统一协议：

```json
{
  "manager": "ContactManager",
  "cmd": "addContact",
  "info": {
    "userId": "userB",
    "reason": "hello"
  }
}
```

`im_flutter_test` 直接调用 interface：

```dart
Client.instance.contactManager.callNativeMethod(
  cmd,
  info,
);
```

即使底层原生 SDK 的方法名、参数、返回值或回调发生变化，上层测试协议也保持不变。

---

## 5. 多平台支持

每个平台在 interface 下提供自己的实现。

```text
Android：
interface
→ MethodChannel
→ Java/Kotlin
→ Android SDK

Web：
interface
→ Web Adapter / JS Interop
→ Web SDK

iOS：
interface
→ MethodChannel
→ Objective-C/Swift
→ iOS SDK
```

Python 用例只使用逻辑角色：

```python
device_a
device_b
device_c
```

平台和版本由运行场景绑定。

---

## 6. 场景与设备角色

示例场景：

```yaml
roles:
  device_a:
    platform: android
    sdk_version: 4.10.0
    startup: eager

  device_b:
    platform: android
    sdk_version: 4.14.0
    startup: eager

  device_c:
    platform: web
    sdk_version: 4.8.0
    startup: lazy
```

规则：

- `device_a/device_b/device_c` 是业务角色，不是固定平台。
- 场景配置决定每个角色的平台和 SDK 版本。
- `eager`：测试开始前启动。
- `lazy`：第一次有用例需要该角色时启动。
- Runner 启动后持续复用。
- 用例需要的角色未定义时：
  - 普通模式：Skip。
  - 严格模式：环境错误。
- 已配置 Runner 但启动失败、版本不匹配时，必须报错，不能 Skip。

---

## 7. 环境生命周期

普通回归流程：

```text
启动 WebSocket Server
→ 启动所需模拟器和浏览器
→ 安装或打开对应版本 Runner
→ 启动 im_flutter_test
→ 等待 Runner 连接
→ 校验平台、SDK 版本和能力
→ 批量执行用例
→ 复用 Runner
→ Session 结束后统一关闭
```

普通 case 不负责启动模拟器，也不负责安装 App。

Runner 启动后上报：

```json
{
  "runnerId": "android-a",
  "platform": "android",
  "sdkVersion": "4.14.0",
  "deviceId": "emulator-5554",
  "capabilities": {}
}
```

---

## 8. API 版本模型

使用“基础 API 集合 + 每个版本增量”的方式管理。

```text
Base API
+ 新增 API
- 删除 API
~ 变更 API
= 当前版本最终能力表
```

推荐字段：

```yaml
added:
removed:
changed:
deprecated:
```

示例：

```yaml
base_version: 4.10.0

versions:
  4.11.0:
    extends: 4.10.0

    added:
      - ChatManager.pinMessage

    removed:
      - ChatManager.oldFetchMessages

    changed:
      ContactManager.addContact:
        adapter: add_contact_v411
```

Runner 启动时解析当前版本能力，并上报给 Python。

---

## 9. 不同版本 API 差异处理

API 差异必须在 interface 下的平台适配层处理，不能进入普通 case。

### 新增 API

- 新版本标记为支持。
- 旧版本标记为不支持。
- 旧版本运行对应 case 时自动 Skip。

### 删除 API

- 当前版本标记为不支持。
- 记录删除版本和原因。

### 方法名或参数变化

- 测试协议名称保持不变。
- 由版本 Adapter 转换成当前 SDK 的真实调用。

### 返回值或回调变化

- 平台 Adapter 统一转换成稳定 JSON。

### 错误码变化

返回统一错误，同时保留原始错误：

```json
{
  "code": 204,
  "description": "User does not exist",
  "nativeCode": "USER_NOT_FOUND",
  "nativeDescription": "Target user not found"
}
```

---

## 10. Capability 自动 Skip

普通 case 不声明固定 SDK 版本。

调用前由框架判断：

```text
SUPPORTED
→ 正常执行
→ 调用失败则 FAILED

UNSUPPORTED
→ SKIPPED
→ Allure 记录平台、版本、API 和原因

UNKNOWN
→ ERROR / FAILED
→ 不能静默跳过
```

不能把普通运行异常直接当作“不支持”并 Skip。

---

## 11. 构建产物

一个构建产物对应一个平台和一个 SDK 版本。

```text
runner-android-4.10.apk
runner-android-4.14.apk
runner-web-4.8/
```

API 存在编译级差异时，采用构建时选择：

```text
Android：Gradle Flavor / Source Set
iOS：Scheme / Build Configuration
Web：不同版本 Bundle
```

不能在同一份代码里简单通过运行时版本判断，引用另一个版本不存在的类或方法。

---

## 12. 覆盖安装测试

覆盖安装属于特殊测试场景。

```text
安装旧版本 Runner
→ 启动旧 SDK
→ 制造本地和离线数据
→ 导出旧数据快照
→ 停止 App
→ 覆盖安装新版本 Runner
→ 启动新 App
→ 等待 WebSocket 重连
→ 校验新 SDK 版本
→ 导出新数据快照
→ 比较数据
→ 恢复网络并验证同步
```

Android 要求：

- `applicationId` 相同。
- 签名相同。
- 不能卸载。
- 不能清理 App 数据。
- 使用覆盖安装。

覆盖安装动作由 `UpgradeRunner` 实现，case 不直接写 adb 命令。

示例：

```python
def test_message_data_after_upgrade(upgrade_runner):
    old = upgrade_runner.start_old()
    old_snapshot = old.prepare_and_export_data()

    new = upgrade_runner.replace_with_new()
    new_snapshot = new.export_data()

    assert new_snapshot["messageCount"] == old_snapshot["messageCount"]
```

---

## 13. 现有用例复用

现有用例已经通过：

```python
device.call(manager, cmd, info)
device.receive_message(...)
```

与具体平台解耦，因此大多数业务流程可以直接复用。

新框架需要保持：

- 请求结构不变。
- 响应结构不变。
- 事件名不变。
- 统一字段名不变。
- 错误断言格式不变。
- `device_a/device_b/device_c` fixture 不变。
- Allure 附件格式尽量不变。

主要改造点：

- 删除 `im_flutter_test` 对 `im_flutter_sdk` 的调用。
- 增加 interface 路由器。
- 替换依赖 `EMClient` 的回调注册。
- 增加结果、事件、错误标准化。
- 增加 Runner hello 和 capability 上报。
- 增加模拟器、浏览器和升级调度。

---

## 14. 建议目录

```text
native-auto-test/
├── config/
│   ├── scenarios/
│   ├── api_matrix/
│   └── artifacts.yaml
├── src/
│   ├── orchestrator/
│   │   ├── environment_manager.py
│   │   ├── runner_registry.py
│   │   ├── android_device.py
│   │   ├── web_runner.py
│   │   └── upgrade_runner.py
│   ├── capability/
│   │   └── resolver.py
│   └── sdk_api/
└── tests/
    ├── chat/
    ├── contact/
    ├── group/
    └── upgrade/
```

```text
im_flutter_test/lib/
├── bridge/
│   ├── websocket_bridge.dart
│   ├── interface_router.dart
│   └── event_router.dart
├── runner/
│   ├── runner_info.dart
│   └── capability_registry.dart
└── protocol/
    └── response_normalizer.dart
```

---

## 15. 第一阶段目标

先完成 Android 闭环：

1. 复用一个现有联系人 case。
2. 去掉该链路对 `im_flutter_sdk` 的依赖。
3. 改为直接经过 `im_flutter_sdk_interface`。
4. 支持 Android SDK 4.10 和 4.14 两个构建产物。
5. 自动启动两个模拟器。
6. 两个 Runner 自动连接 WebSocket。
7. 同一份 case 在两个版本上运行。
8. 实现 capability 自动 Skip。
9. 完成一条消息或会话数据覆盖安装测试。
10. Allure 中记录平台、SDK 版本、API 能力和升级结果。

## 16. 第一阶段验收标准

### 16.1 验收范围

第一阶段只验收 **Android 多版本闭环**。Web、iOS、macOS、OHOS
以及三端混合场景属于后续阶段，不作为第一阶段交付阻断项。

第一阶段指定版本：

```text
旧版本：Android SDK 4.10
新版本：Android SDK 4.14
```

以下 `AC-P0-*` 项全部通过，第一阶段才可判定为验收通过。
`AC-P1-*` 为质量项，不阻断首次 MVP 验收，但必须记录结果和遗留问题。

### 16.2 P0 阻断验收项

#### AC-P0-01：依赖边界与 Interface 调用链

验收动作：

1. 检查 `im_flutter_test` 的依赖和业务桥接代码。
2. 从 Python 发起一次真实业务调用，并记录完整调用轨迹。

通过条件：

- `im_flutter_test` 不依赖、导入或调用 `im_flutter_sdk`。
- Python 仍通过 `device.call(manager, cmd, info)` 发起调用。
- 每个业务请求都经过：

```text
native-auto-test
→ WebSocket JSON
→ im_flutter_test interface_router
→ im_flutter_sdk_interface
→ Android 版本 Adapter / Wrapper
→ 对应版本真实原生 SDK
```

- 不允许通过反射、测试假实现或直接绕过 interface 调用原生 SDK。
- 至少提供一条包含 `requestId、manager、cmd、platform、sdkVersion`
  的端到端调用日志作为证据。

#### AC-P0-02：协议和现有 Case 兼容

验收动作：

1. 从现有 `tests/` 中选定一条联系人或消息 case 作为基准 case。
2. 基准 case 不增加平台判断或版本判断，分别在 4.10 和 4.14 上执行。

通过条件：

- case 继续使用现有 `device.call(...)`、事件等待和断言方式。
- 不复制出 `test_xxx_410`、`test_xxx_414` 两份版本专用 case。
- 请求字段、成功响应、错误结构和事件名保持向后兼容。
- 如必须修改基准 case，只允许修改 fixture 或公共封装；业务步骤和业务断言不变。
- 4.10 和 4.14 两次执行均通过。

验收记录中必须写明基准 case 的文件路径和测试名。

#### AC-P0-03：两个版本产物可识别、可安装

验收动作：

1. 分别构建 4.10 和 4.14 Runner。
2. 安装、启动后读取 Runner `hello`。

通过条件：

- 生成两个独立、命名可区分的 APK。
- 构建使用的真实原生依赖分别为 4.10 和 4.14，不允许只修改上报字符串。
- `hello.sdkVersion` 与 APK 内实际 SDK 依赖一致。
- 普通多版本并行运行时，两个 Runner 可通过不同设备和
  `runnerId` 唯一识别。
- 产物路径、文件校验值和依赖解析结果作为验收附件保存。

#### AC-P0-04：环境自动调度与 Runner 注册

验收动作：

从干净测试会话启动一次包含两个逻辑角色的场景，不手工启动模拟器、
安装 APK、点击 App 或填写 WebSocket topic。

通过条件：

- Orchestrator 自动完成两个模拟器的选择或启动、APK 安装、App 启动和
  WebSocket 注册。
- 两个 Runner 在配置的启动超时内分别上报 `hello`。
- `hello` 至少包含：
  `runnerId、deviceName、platform、sdkVersion、appVersion、capabilities`。
- `device_a/device_b` 与真实 Runner 的绑定唯一且可在日志中查询。
- 实际平台或 SDK 版本与场景配置不一致时，在执行任何业务步骤前失败，
  结果归类为 Environment Error。
- 普通业务 case 中不存在 `adb`、模拟器启动、APK 安装或 App 启动命令。

#### AC-P0-05：同一 Case 的版本矩阵执行

验收动作：

使用一条测试命令执行基准 case 的 4.10、4.14 版本矩阵。

通过条件：

- 版本由 scenario / pytest 参数 / 运行配置决定，而不是写死在 case 中。
- 测试框架自动生成两条可独立查看的执行结果。
- 两条结果分别记录逻辑角色、设备、平台和实际 SDK 版本。
- 任一版本启动、绑定或执行失败，不得由另一个版本的成功结果掩盖。

#### AC-P0-06：API 版本差异与 Capability 判定

准备一个仅 4.14 支持、4.10 不支持的真实 API，并在 API Matrix 中记录其版本增量。

通过条件：

| 场景 | 预期结果 |
|---|---|
| 4.14 明确支持，调用成功 | Passed |
| 4.14 明确支持，但真实调用失败 | Failed，保留原始错误 |
| 4.10 明确不支持 | Skipped，原因包含平台、版本和 API |
| API Matrix 或 Capability 信息缺失 | Framework/Configuration Error |
| Runner 上报能力与 Matrix 冲突 | Framework/Configuration Error |

附加要求：

- `Unsupported` 只能来自调用前的 Capability 判断。
- 超时、断连、参数错误、原生异常不能转换为 Skip。
- 普通业务 case 不写 `if sdk_version ...`。

#### AC-P0-07：覆盖安装与数据保留

验收动作：

至少完成一条 4.10 → 4.14 的消息或会话数据覆盖安装 case。

通过条件：

- 新旧 APK 的 `applicationId` 和签名一致。
- 先用 4.10 制造可唯一识别的本地或离线数据，并导出升级前快照。
- 使用覆盖安装升级到 4.14；过程中不得卸载 App、清理数据或删除数据库。
- 4.14 启动后重新连接 WebSocket，且 `hello.sdkVersion` 为 4.14。
- 升级后快照中的目标消息或会话存在，关键字段与升级前一致。
- 恢复网络后能够完成一次同步或收发验证。
- Allure 附加安装命令结果、升级前后版本、两个数据快照和差异结果。

覆盖安装任一步骤失败应判定为 Failed 或 Environment Error，不得 Skip。

#### AC-P0-08：Allure 可追溯性

每条矩阵 case 的 Allure 结果至少包含：

- case 名称和 scenario 名称；
- `device_a/device_b/device_c` 到 Runner 的绑定关系；
- 设备名、平台、App 版本、SDK 版本和 `runnerId`；
- 调用的 `manager、cmd、requestId`；
- Capability 来源和判断结果；
- 标准化请求、响应、事件及原始错误；
- Passed、Skipped、Failed 或 Environment Error 的明确原因；
- 覆盖安装 case 的旧/新版本、快照和数据差异。

通过条件：

- 仅查看 Allure，不读取控制台日志，也能定位“在哪个设备、哪个 SDK
  版本、调用哪个 API、为什么得到当前结果”。
- Token、密码等敏感字段必须脱敏。

### 16.3 P1 质量验收项

#### AC-P1-01：Runner 复用与隔离

- 同一测试会话内，健康 Runner 可以被后续 case 复用，不重复冷启动。
- 前一 case 的账号、事件缓存和临时数据不会污染后一 case。
- Runner 断连后，框架能够明确标记失效并重新调度或终止当前场景。

#### AC-P1-02：重复执行稳定性

- Android 4.10/4.14 基准矩阵连续执行 3 次。
- 不允许出现设备串绑、响应串号、事件被错误 case 消费或版本误报。
- 若业务依赖外部服务导致失败，必须保留可定位的原始证据，不得统计为框架通过。

#### AC-P1-03：可扩展性检查

- 新增一个 Android SDK 版本时，普通业务 case 无需修改。
- 变更仅限于新构建配置、版本 Adapter/Wrapper、API Matrix 增量和产物配置。
- 平台路由不存在 Android 业务逻辑硬编码到 Python case 的情况。

### 16.4 最小验收用例集

| ID | 用例 | 版本/设备 | 预期 |
|---|---|---|---|
| AT-01 | 现有联系人或消息基准 case | 4.10 | Passed |
| AT-02 | 同一基准 case | 4.14 | Passed |
| AT-03 | 4.14 新增 API | 4.10 | Skipped，原因准确 |
| AT-04 | 4.14 新增 API | 4.14 | Passed |
| AT-05 | Capability 缺失或冲突 | 任一版本 | Framework/Configuration Error |
| AT-06 | Runner 版本与配置不一致 | 任一版本 | Environment Error，业务调用未执行 |
| AT-07 | 4.10 → 4.14 覆盖安装 | 同一模拟器 | Passed，数据保留 |

### 16.5 验收交付物

验收时必须同时交付：

1. 4.10、4.14 两个 APK 及其校验值。
2. 两个产物的真实 SDK 依赖解析记录。
3. scenario、artifact 和 API Matrix 配置。
4. 最小验收用例集及执行命令。
5. Allure 原始结果目录和生成后的报告。
6. 覆盖安装前后数据快照。
7. 构建日志、测试日志和已知问题清单。

缺少上述任一 P0 证据时，对应验收项不能仅凭口头说明判定通过。
