# Flutter SDK API 自动化测试（Cases 端）

通过 WebSocket 与 Flutter Runner 通信，对原生 SDK API 做自动化测试。默认的
`--ws-mode managed` 会由 pytest 启动本地 WebSocket Server，并按
`runId + runnerId + requestId` 路由，不需要手工配置 topic。

## 团队与 AI Agent 速查

进行原生 SDK 升级、Wrapper 适配、Scenario/API Matrix 配置或 pytest 回归前先读本节。

### 调用链与配置职责

```text
pytest → Scenario → Artifact → API Matrix → im_flutter_test
       → interface.callNativeMethod → Wrapper → 原生 SDK
```

| 文件/目录 | 作用 |
|---|---|
| `config/scenarios/*.yaml` | 选择账号、设备、平台、SDK 版本和拓扑 |
| `config/artifacts.yaml` | 将 `platform + sdk_version` 映射到 APK/Runner、flavor 和 manifest |
| `config/api_matrix/*.yaml` | 定义各版本支持的 `Manager.cmd`；unsupported 在调用前 skip |
| `config/artifact_manifests/*.json` | 记录 SDK/Wrapper/Artifact 身份和 capability |
| `im_flutter_test/` | 被测 Runner 与 WebSocket/Event 桥接 |
| `im_flutter_sdk_android/`、`im_flutter_sdk_ios/` | 统一协议到原生 SDK 的 Wrapper |

case 不写平台或版本判断；版本由 Scenario 的 `sdk_version` 决定。账号默认按 pytest
session 创建和清理，编排器只启动本次 case fixture/topology 实际需要的设备。

### Android 版本基线（重要）

当前 Java 合并关系：

```text
sdk500 = base500
sdk501 = base500 + sdk501 相对 5.0 的累计差异
sdk502 = base500 + sdk502 相对 5.0 的累计差异
```

flavor 使用“主版本 + 两位 minor”：5.0 → `sdk500`、5.1 → `sdk501`、
5.2 → `sdk502`。`sdk502` 不会自动继承 `sdk501`。如果 5.1 新增 C，5.2
保留 C 并新增 D，`sdk502` 的差异 Wrapper 必须同时包含 C 和 D。通常复制
`sdk501` 的差异文件到 `sdk502`，再按 5.2 修改。每个版本目录还要放该版本完整 JAR 和 so。

API Matrix 与代码不同，按版本顺序做增量：

```yaml
versions:
  5.1.0:
    added: [ChatManager.apiC]
  5.2.0:
    added: [ChatManager.apiD]
    removed: []
```

因此 5.2 的 Matrix 能力集合会自动包含 C 和 D。

### Wrapper 规则

- API 使用 `dispatchMethodCall + if/else`，禁止恢复 `register/registerAll`。
- 不覆盖公共 `Wrapper.onMethodCall`；已处理分支必须 `return true`。
- 同一调用只能回复一次；未知命令交给 `super` 返回 `notImplemented`。
- Event 不走 API 路由；`registerEaseListener/unRegisterEaseListener` 必须成对。
- 不用本地 API 冒充服务端 API，也不伪造原生不存在的成功结果。
- Matrix supported 但 Wrapper 未路由：修 Wrapper；Wrapper 已实现但 Matrix 未收录：修 Matrix。

### 新版本接入清单

1. 对比上一版本的原生 API、Event、参数、模型和错误码。
2. 新建 `sdkXXX`，放完整 JAR/so 和“相对 base500 的累计差异 Wrapper”。
3. 在 Android `build.gradle` 增加 flavor、SourceSet 和依赖。
4. 适配 API 的 if/else 路由以及 Event 注册、移除和 payload。
5. 更新 API Matrix（相对上一版本的 `added/removed/changed`）。
6. 更新 `artifacts.yaml`、artifact manifest 和 Scenario。
7. 构建新版本及旧基线；先跑受影响单例，再跑模块回归。

真实且需要向 App 开发者公开的能力才修改发布 SDK/interface/iOS；仅测试便利逻辑放
`im_flutter_test`。

### 最小运行命令

```bash
# 仓库根目录：构建 Runner
cd im_flutter_test
flutter build apk --flavor sdk500 --debug

# 复用 artifacts.yaml 指向的已有 APK（不加 --build）
cd ../native-auto-test
.venv/bin/python -m pytest -q \
  tests/chat/test_xxx.py::test_xxx \
  --scenario android_500_multi_device_default -s

# Wrapper/JAR/so 有变化时：先构建 Scenario 所需 flavor，再安装并运行
.venv/bin/python -m pytest -q \
  tests/chat/test_xxx.py::test_xxx \
  --scenario android_500_multi_device_default --build -s

# 发现模式；确认输出后去掉两个环境变量严格复跑
CASES_DISCOVER=1 WS_DEBUG=1 .venv/bin/python -m pytest -q \
  tests/chat/test_xxx.py::test_xxx \
  --scenario android_500_multi_device_default -s
```

Scenario 可传文件名（省略 `.yaml`）或完整路径。完整环境准备、报告和多端运行方式见
本文后续章节。

`--build` 在 pytest session 开始前读取 Scenario：Android 对每个不同的
`sdk_version` 执行对应 flavor 的 `flutter build apk --debug`，并刷新 Android
artifact manifest 的 APK hash；Web 会执行 npm 构建。iOS 当前执行默认
`merge_ios_sdk.sh` 后构建模拟器，非默认 iOS flavor 应先手工完成对应 merge。
不加 `--build` 则直接复用 `artifacts.yaml` 指向的现有产物并执行 hash 校验。
改过 Wrapper、JAR、so 或 Runner 后使用 `--build`；只重复跑 case 时通常不加。

提交前至少执行：

```bash
# 仓库根目录
im_flutter_sdk/scripts/speckit.sh check
python3 im_flutter_sdk/scripts/check_protocol_consistency.py
im_flutter_sdk/scripts/check_wrapper_diffs.sh
git diff --check
```

## Android 多版本 MVP

正式版本管理以 Android SDK 5.0.0 为基线：

- 自动选择或启动两个模拟器；
- 按 scenario 安装对应 flavor APK；
- 通过 Runner Hello 校验设备、版本和能力；
- 使用 Base API + 版本增量判断 Capability；
- 不支持的 API 在调用前 Skip，缺失或冲突按框架配置错误处理；
- 默认由 `native-auto-test` 启动 managed WebSocket，并通过
  `runId + runnerId + requestId` 精确路由；
- 支持六个逻辑槽位，并只启动所选 Case 直接声明的槽位；
- 支持同 applicationId 的覆盖安装和本地消息快照校验；
- 请求、响应、Runner、Capability 和升级快照写入 Allure。

4.23 使用正式 `im_flutter_sdk_android` Wrapper，业务调用经过
`im_flutter_sdk_interface`，不经过 `im_flutter_sdk` Dart 业务层。
4.10/4.14 仅用于 MVP 的历史覆盖安装机制验证，使用独立 legacy API Matrix。

完整矩阵（脚本默认先构建所需 APK）：

```bash
NATIVE_TEST_AVD_A=Pixel_5 \
NATIVE_TEST_AVD_B=Pixel_5_2 \
python scripts/run_phase1_matrix.py
```

完整矩阵只复用已构建 APK：

```bash
python scripts/run_phase1_matrix.py --no-build
```

版本由 `config/scenarios/*.yaml` 决定，普通 case 中不写版本判断。
真实登录、联系人、群组和消息在线用例仍需能访问被测 IM 服务；公司网络
或 VPN 不可用时，构建和本地框架测试可执行，但在线 P0 项不能判定通过。

## WebSocket 两种用法

1. **请求/响应**：`api.call(manager, cmd, info)` — 发一条请求，等一条对应响应（按 id/sequence 匹配），适合单次调用、结果断言。
2. **纯接收（主动下发）**：`MessageListener` — 连接后只收不发，用于拿服务端主动推送的消息（如事件、多端回调）。
   - `message_listener.start()` 后，用 `receive_message(match_cmd=..., match_event_type=..., timeout=...)` 按条件取**第一条匹配**消息。
   - **多条/不匹配**：未匹配到的消息会进缓冲，下次 `receive_message` 会先查缓冲（可换条件或 `match_cmd`/`match_event_type` 都不传取任意一条）；`drain_buffer()` 可一次性取出当前缓冲并清空。

## 协议说明

- **请求**：`{ "manager", "cmd", "info", "id"? | "sequence"? }`，可选 `type`、`objId`、`device`（多端）。
- **成功响应**：原请求体带回 `result`，去掉 `info`，即含 `cmd`、`manager`、`result`。
- **失败响应**：`{ "success": false, "error": { "code", "description" }, "id"? }`。

## 快速开始（从零到第一条用例）

> 跑测试**不需要 Flutter**（复用已有构建产物，pytest 直接 `adb install` 安装 APK）；
> 只有构建/改动测试 App（wrapper、桥接、新事件转发）才需要 Flutter。

### 1. 环境依赖（分层）

**必备（只跑测试）**

- Python 3.9+，创建虚拟环境并装依赖：
  ```bash
  python3 -m venv .venv
  .venv/bin/pip install -r requirements.txt
  ```
- Android SDK `platform-tools`（`adb`，用于安装 APK / 断网控制），确认 `adb devices` 可用
- 4 台 Android 模拟器（AVD）：`Pixel_5_2`、`Pixel_5_3`、`Pixel_5_5`、`Pixel_5_6`
- 已有构建产物：`config/artifacts.yaml` 指向的 APK（如 `im_flutter_test/build/app/outputs/flutter-apk/app-sdk500-debug.apk`）；
  产物不存在时首次需先构建（见下）

**可选（构建 / 开发测试 App）**

- Flutter ≥ 3.3（Dart ≥ 3.5.4，本仓库验证于 Flutter 3.24.5）
- Android SDK（构建 APK）／ Xcode（iOS 模拟器场景，AVD 名 `iosa/iosb/iosc/iosd`）

### 2. 启动模拟器

```bash
$ANDROID_SDK/emulator/emulator -avd Pixel_5_2 -no-snapshot -no-boot-anim &
$ANDROID_SDK/emulator/emulator -avd Pixel_5_3 -no-snapshot -no-boot-anim &
$ANDROID_SDK/emulator/emulator -avd Pixel_5_5 -no-snapshot -no-boot-anim &
$ANDROID_SDK/emulator/emulator -avd Pixel_5_6 -no-snapshot -no-boot-anim &
adb wait-for-device
```

> **首次需核对 scenario 的设备序列号**：`config/scenarios/android_500_multi_device_default.yaml`
> 里的 `serial`（默认 `emulator-5554/5556/5558/5560`）按本机 `adb devices` 的
> 实际序列号核对；不一致时改 yaml（模拟器默认从 5554 开始分配，通常一致）。
> serial 对不上会报 `AndroidEnvironmentError: configured serial ... is not online`。

### 3. 配置（首次）

```bash
cp config.yaml.template config.yaml
```

### 4. 跑第一条用例

```bash
# 复用已有 APK（不加 --build）
.venv/bin/python -m pytest --scenario android_500_multi_device_default \
  tests/group/test_group_metadata.py::test_group_update_subject -q

# 产物不存在 / 改过 Wrapper 后：先构建再装（加 --build）
.venv/bin/python -m pytest --build --scenario android_500_multi_device_default \
  tests/group/test_group_metadata.py::test_group_update_subject -q
```

期望输出：`1 passed`（模拟器在线、APK 安装成功、服务端可达时）。

## 环境

- Python 3.9+（推荐 venv，见上）
- 跑测试：Android SDK `platform-tools`（adb）+ 模拟器 + 已有 APK；构建需 Flutter（见快速开始）

## 配置

`cp config.yaml.template config.yaml`
- 使用 Scenario（推荐）时默认是 managed WebSocket，本地 Server、Runner 地址和路由由 pytest 自动管理。
- managed 多端测试不要配置或修改 topic，也不要重写 `ws_topic/ws_device` fixture。

## 运行用例

```bash
# 使用 managed WebSocket 运行全部用例
pytest --scenario android_500_multi_device_default

# 只跑 Client 相关
pytest -m client --scenario android_500_multi_device_default

# 生成 HTML 报告
pytest --scenario android_500_multi_device_default \
  --html=out/report.html --self-contained-html

# 单文件
pytest tests/test_client.py --scenario android_500_multi_device_default -v
```

## 报告

- **HTML 报告**：`pytest --html=out/report.html --self-contained-html`，用浏览器打开 `out/report.html`。
- **Allure**（推荐）：依赖已写入 `requirements.txt`。运行后报告会包含请求、响应、比对结果等详情。
  ```bash
  pytest --alluredir=out/allure-results
  allure serve out/allure-results
  ```
  **报告中会输出：**
  - **请求**：每次 `api.call` 的请求体和路由上下文（manager、cmd、info、device、runId/runnerId/requestId；外部模式另含 topic）以 JSON 附件挂在对应 step 下。
  - **响应**：该次调用的完整响应 JSON 附件。
  - **比对结果**：调用 `assert_response_matches` 时，会附加「预期响应」「实际响应」「比对结果」；不一致时为「比对结果（差异）」并列出缺少/多出/值不同的字段。

## 多端测试（Scenario + managed WebSocket）

- 在 `config/scenarios/*.yaml` 的 `devices` 声明设备/账号，在 `topologies` 声明发送端和接收端。
- case 使用设备 fixture 或 `@pytest.mark.topology("...")` 声明需要的角色；编排器只启动这些 Runner。
- pytest 自动启动一个 managed WebSocket Server，并通过 Runner Hello 注册和三元 ID 精确路由；多设备之间不靠不同 topic 隔离。

## 项目结构

```
native-auto-test/
├── config.yaml           # IM/REST 配置；外部 WS 模式配置
├── pyproject.toml
├── requirements.txt
├── pytest.ini
├── src/
│   ├── config.py         # 读取 config.yaml
│   ├── tools/ws_client.py # WebSocket 请求/响应
│   ├── assertions.py    # 成功/失败、result 断言
│   └── response_match.py # 预期 JSON 比对、占位符、忽略时间戳
└── tests/
    ├── conftest.py      # Scenario、Runner、API、能力门禁等 fixture
    ├── test_client.py   # Client 登录/登出等
    └── test_client_init.py
```
## Specs & Testing System

- 文档入口：
  - 用例规范（通用 + 模块速查）：`docs/spec/CASES_SPEC.md`
  - 依赖升级：`docs/spec/DEPS_SPEC.md`
  - Agent 执行总规范：`docs/agents/AGENTS.zh.md`
  - 用例风格以 `docs/spec/CASES_SPEC.md` 为准（其他模块请按该规范收敛：最小忽略集、禁止自证式 result、稳定后锁定唯一真实返回、不再分支判断）。

- 断言收敛（长期稳定）：
  - 仅使用两类断言：assert_api.assert_response_matches、assert_api.assert_error
  - 成功体必须断言 result 全结构；未知时先发现（CASES_DISCOVER=1）后冻结
  - 最小忽略集：sequence/id、所有时间类、broadcast/onlineState、偶发 receiverList；翻译 targetLanguages/deliverOnlineOnly 暂忽略

- 发现 → 严格：
  - 发现单例：CASES_DISCOVER=1 WS_DEBUG=1 pytest -q tests/test_chat.py::test_chat_send_and_received -s
  - 严格复跑：pytest -q tests/test_chat.py::test_chat_send_and_received -s
  - 全量（排除已知 bug）：pytest -q tests/test_chat.py -s -k 'not test_chat_translate_message_nonexistent_message'

- 依赖升级（4.19.1）：
  - cd im_flutter_sdk && HY_CHAT_VERSION=4.19.1 ./scripts/update_hyphenate.sh all --build
  - 详见 docs/spec/DEPS_SPEC.md

## 断言用法

- `assert_api.assert_success(resp)`：要求成功。
- `assert_api.assert_error(resp, code=..., description=...)`：要求失败并校验错误。
- `assert_api.assert_result_equals(resp, expected)`：`result == expected`。
- `assert_api.assert_result_matches(resp, key=value, ...)`：`result` 为 dict 且包含指定键值。

### 预期 JSON 比对（占位符 + 忽略时间戳）

- `assert_api.assert_response_matches(actual, expected, context=None, ignore_keys=None)`：用预期 JSON 与 actual 比对，**不一致时列出所有差异**。
- **占位符**：在 expected 里用 `{{key}}` 或 `{{path.to.key}}`，从 `context` 取值替换（如请求里的 userId 可带入预期）。
- **忽略字段**：时间戳等变化字段默认不参与比对（见 `response_match.DEFAULT_IGNORE_KEYS`）；可传 `ignore_keys` 追加。
- **比对规则**：只校验 expected 中出现的键；actual 多出的键不报错；列表按顺序逐项比对。

示例：

```python
# 请求参数已知，带入预期
context = {"userId": USER_B, "request": {"info": {"userId": USER_B}}}
assert_api.assert_response_matches(
    resp_add,
    expected={"manager": "ContactManager", "cmd": "addContact", "result": "{{userId}}"},
    context=context,
)
# 需额外忽略的 key
assert_api.assert_response_matches(actual, expected, ignore_keys={"requestId"})
```


from src import gt, lt, ne, ge, le, eq
assert_api.assert_response_matches(
    resp_status,
    expected={
        "manager": "PresenceManager",
        "cmd": Cmd.fetchPresenceStatus.value,
        "result": [
            {
                "statusDescription": eq("online"),   # 等于字符串
                "publisher":         "{{publisher}}", # 占位符，同之前
                "lastTime":          gt(0),           # 大于 0
                "expiryTime":        gt(0),           # 大于 0
                "active":            ne(False),       # 不等于 false
            }
        ],
    },
    context={"publisher": USER_A},
    ignore_keys={"statusDetails"},
)

## Repo-local Skills

This repository includes Codex skills under `skills/` following the create-skill guidelines:

- `skills/im-ws` — WebSocket request/response and event listening helpers.
  - Scripts: `scripts/ws_call.py`, `scripts/ws_wait.py`
- `skills/im-rest-users` — REST user provisioning helpers.
  - Scripts: `scripts/create_users.py`, `scripts/delete_user.py`
- `skills/im-contact-flow` — High-level contact flows built on WS.
  - Scripts: `scripts/contact_flow.py`

Usage examples can be found in each skill's `SKILL.md`. Make sure `config.yaml` is configured before using them.

## Make Tasks

- Show help
  - `make help`
- WebSocket
  - Call once: `make ws-call MANAGER=ContactManager CMD=addContact INFO='{"userId":"u2"}' [DEVICE=device_a]`
  - Call and wait for event: `make ws-call MANAGER=ContactManager CMD=addContact INFO='{"userId":"u2"}' EVENT=CONTACT_INVITED`
  - Wait for first matching event: `make ws-wait EVENT=CONTACT_INVITED [DEVICE=device_b] [TIMEOUT=15]`
- REST users
  - Create: `make create-users USERS='uA uB' [PASSWORD=1]`
  - Create from file: `make create-users FROM_FILE=users.json`
  - Delete: `make delete-user USERNAME=uA`
- Contact flow
  - Establish friends: `make contact-establish INITIATOR_DEVICE=device_a PEER_DEVICE=device_b USER_A=uA USER_B=uB [REASON=flow]`
  - Delete friend: `make contact-delete INITIATOR_DEVICE=device_a FRIEND_USER_ID=uB [KEEP_CONVERSATION=1]`
  - Block/Unblock: `make contact-block DEVICE=device_a USER_ID=uB` / `make contact-unblock DEVICE=device_a USER_ID=uB`

Tips
- JSON 参数请用单引号包裹（避免 shell 转义）。
- 运行前确保 `config.yaml` 配置正确；REST 需 `rest_api.base_url` 与 `rest_api.auth_token`。
- 校验技能目录：`make skills-validate`。

pytest -q tests -s --alluredir=out/allure-results
allure generate out/allure-results -o out/allure-report --clean
open out/allure-report/index.html
