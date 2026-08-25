# Flutter SDK API 自动化测试（Cases 端）

通过 WebSocket 与 Flutter demo 端通信，对环信 Flutter SDK 的 API 做自动化测试。Flutter 端需连接**同一 WebSocket 服务**且使用**相同 topic**。

## WebSocket 两种用法

1. **请求/响应**：`api.call(manager, cmd, info)` — 发一条请求，等一条对应响应（按 id/sequence 匹配），适合单次调用、结果断言。
2. **纯接收（主动下发）**：`MessageListener` — 连接后只收不发，用于拿服务端主动推送的消息（如事件、多端回调）。
   - `message_listener.start()` 后，用 `receive_message(match_cmd=..., match_event_type=..., timeout=...)` 按条件取**第一条匹配**消息。
   - **多条/不匹配**：未匹配到的消息会进缓冲，下次 `receive_message` 会先查缓冲（可换条件或 `match_cmd`/`match_event_type` 都不传取任意一条）；`drain_buffer()` 可一次性取出当前缓冲并清空。

## 协议说明

- **请求**：`{ "manager", "cmd", "info", "id"? | "sequence"? }`，可选 `type`、`objId`、`device`（多端）。
- **成功响应**：原请求体带回 `result`，去掉 `info`，即含 `cmd`、`manager`、`result`。
- **失败响应**：`{ "success": false, "error": { "code", "description" }, "id"? }`。

## 环境

- Python 3.9+
- 安装依赖：`pip install -r requirements.txt`

`requirements.txt` 将 `websockets` 限制为 `>=11.0,<17.0`。当前 relay 和现有
`ws_client.py` 都依赖 legacy API；在两者一起迁移到新 asyncio API 前，不要移除该
上限，否则重建虚拟环境可能安装已删除 legacy API 的版本。

## 配置

`cp config.yaml.template config.yaml`
- `websocket.base_url`：WS 服务地址（与 Flutter 端一致）。
- `websocket.default_topic`：默认 topic（与 Flutter 端 `IMWebSocketBridge.instance.start(topic: '...')` 一致）。
- 多端测试时可在 `topics` 下为不同 device 配置不同 topic。

## 本地 WebSocket 桥接

仓库内置按 topic 转发的本地 WebSocket relay，可让 pytest 与本机 Android
模拟器中的 `im_flutter_test` 通讯，不依赖公共桥接服务器。它只替代测试控制桥，
不替代 MSync、Gateway 或 SDK 的 `syncDataWebSocketServer`，也不提供 TLS、鉴权、
消息持久化或离线队列。

### 1. 一键启动

进入 Python 虚拟环境后，在 `native-auto-test` 中执行：

```bash
source .flutter-vnev/bin/activate
make ws-bridge-up
```

该命令会一次完成：

- 验证当前 Python 能够导入 `websockets` 和本地 relay 模块；
- 后台启动本地 relay，默认监听 `127.0.0.1:4000`；
- 扫描所有在线的 `emulator-*` Android 模拟器；
- 为每台模拟器设置并回读 `adb reverse tcp:4000 tcp:4000`；
- 生成仅供本机使用的 `.local/ws-bridge.env`，供 pytest 临时加载本地地址。

这里的“一键”覆盖 Python/control 侧前置，不会自动操作 Flutter App 页面。App 的
URL、topic、device 和“连接”动作仍按下一节手工配置。

默认桥接地址为：

```text
ws://127.0.0.1:4000/iov/websocket/dual
```

`.local/` 已加入 Git ignore，运行状态包括：

| 文件 | 用途 |
|---|---|
| `.local/ws-bridge.pid` | 当前项目启动的 relay PID |
| `.local/ws-bridge.env` | 唯一覆盖项 `WS_BASE_URL` |
| `.local/ws-bridge.log` | relay 运行日志，不记录消息正文 |
| `.local/ws-bridge.lock/` | lifecycle 操作期间的临时互斥锁，命令结束后自动删除 |

脚本不会修改 `config.yaml`、App 页面配置、REST 配置或业务账号。如果 `adb` 不在
PATH 中，可以显式提供其路径：

```bash
make ws-bridge-up \
  ADB="$HOME/Library/Android/sdk/platform-tools/adb"
```

需要自定义端口时，启动、App 地址和停止命令都使用同一个 `WS_PORT`：

```bash
make ws-bridge-up WS_PORT=5000
```

### 2. 连接 Flutter 测试 App

先断开旧连接，再在两台 App 的“WebSocket 桥接配置”页面填写。topic 必须与
本机 `config.yaml` 的 `topics.deviceA/deviceB` 完全一致：

| 设备 | URL | Topic | Device |
|---|---|---|---|
| A | `ws://127.0.0.1:4000/iov/websocket/dual` | `topics.deviceA` 的值 | `deviceA` |
| B | `ws://127.0.0.1:4000/iov/websocket/dual` | `topics.deviceB` 的值 | `deviceB` |

两台 App 都显示“已连接并注册事件处理器”后再运行 pytest。

### 3. 运行本地桥接用例

使用 `make test-local` 自动加载 `.local/ws-bridge.env`，无需导出环境变量，也不会
写回 `config.yaml`：

```bash
make test-local ARGS="-q 'tests/group/test_group_lifecycle.py::test_group_create_group'"
```

参数化 nodeid 也应保留单引号，例如：

```bash
make test-local ARGS="-q 'tests/group/test_file.py::test_case[value]'"
```

`test-local` 会在 pytest 前验证 env、PID、受管进程身份和真实 WebSocket 握手。
环境文件缺失、relay 已退出或握手失败时会明确失败，不会继续运行 pytest。

### 4. 一键停止

```bash
make ws-bridge-down
```

该命令会删除在线模拟器的对应 reverse，只停止 PID 和命令身份都匹配当前项目 relay
的进程，并删除 env/PID 文件；日志保留在 `.local/ws-bridge.log`。重复执行安全，不会
终止 PID 文件偶然指向的其他进程。down 会从 `.local/ws-bridge.env` 自动恢复实际
host、port 和 path，因此使用自定义 `WS_PORT` 启动后，无需在 down 时重复传入端口。

如果 reverse 清理失败、PID 身份不匹配或 relay 无法停止，down 会非零退出并保留
PID/env 管理文件，不会打印“已停止”。修复错误后再次执行 down 即可继续清理。使用过
自定义 `ADB` 路径时仍应在 down 中提供同一个 `ADB`，因为该路径不写入环境文件。

`up`、`down`、`check` 会互斥访问同一个 `.local/` 状态目录。如果另一条 lifecycle
命令仍在运行，竞争命令会立即报出持锁 PID 并退出，不会覆盖 PID/env 或回滚对方状态。
如果上一次命令异常退出，后续命令确认持锁 PID 已不存在后会自动回收陈旧锁；持锁 PID
仍存活时不会强制删除锁。

恢复远程桥接时，在 Flutter App 中断开本地地址并填写远程 URL，然后正常执行 pytest
即可；`test-local` 只影响它启动的 pytest 子进程，不会污染父 shell。

### 5. 手工诊断

日常流程不需要下面两个命令。只有排查 relay 或 reverse 某一层时，才分别使用：

```bash
# 前台启动 relay，按 Ctrl-C 停止
make ws-bridge-local

# 只添加模拟器 reverse，不启动 relay
make ws-bridge-reverse WS_PORT=4000
```

常见只读检查：

```bash
# Mac 是否监听 4000
lsof -nP -iTCP:4000 -sTCP:LISTEN

# 模拟器是否在线
adb devices

# 模拟器是否映射本地 relay
adb -s emulator-5554 reverse --list

# 后台 relay 日志
tail -f .local/ws-bridge.log
```

如果 pytest 连接成功但 App 没反应，依次核对：本地 listener、每台模拟器的
reverse、App URL、App topic/device 和 `config.yaml` 的 A/B topic；不要把 relay
连接问题归因到 IM 服务链路。

### 6. 无设备工具测试

本地桥接的回归测试不需要模拟器、测试账号或外部 WebSocket：

```bash
./.flutter-vnev/bin/python -m pytest -q tests/tools
```

当本次收集的用例全部位于 `tests/tools` 时，根级 session fixture 会显式跳过设备登录
和测试用户创建；该隔离不再依赖 tools 目录中的同名 fixture 覆盖。如果同一 pytest
session 同时收集业务 E2E 和 tools 用例，仍会按业务 E2E 要求执行一次 session 登录。

## 运行用例

```bash
# 运行全部用例
pytest

# 只跑 Client 相关
pytest -m client

# 生成 HTML 报告
pytest --html=out/report.html --self-contained-html

# 指定 topic（覆盖 config 中的 default_topic 需在代码里通过 fixture 或环境变量扩展，当前以 config 为准）
pytest tests/test_client.py -v
```

## 报告

- **HTML 报告**：`pytest --html=out/report.html --self-contained-html`，用浏览器打开 `out/report.html`。
- **Allure**（推荐）：依赖已写入 `requirements.txt`。运行后报告会包含请求、响应、比对结果等详情。
  ```bash
  pytest --alluredir=out/allure-results
  allure serve out/allure-results
  ```
  **报告中会输出：**
  - **请求**：每次 `api.call` 的请求体（manager、cmd、info、topic、device 等）以 JSON 附件挂在对应 step 下。
  - **响应**：该次调用的完整响应 JSON 附件。
  - **比对结果**：调用 `assert_response_matches` 时，会附加「预期响应」「实际响应」「比对结果」；不一致时为「比对结果（差异）」并列出缺少/多出/值不同的字段。

## 多端测试（多 topic）

- 在 `config.yaml` 中配置 `topics.device_1`、`topics.device_2` 等。
- 在 `conftest.py` 中为不同测试或参数化提供不同 `ws_device`（或重写 `ws_topic` fixture），即可在不同 topic 上跑同一套用例，实现多端测试。

## 项目结构

```
flutter-auto-test/
├── config.yaml           # WebSocket 与 topic 配置
├── pyproject.toml
├── requirements.txt
├── pytest.ini
├── src/
│   ├── config.py         # 读取 config.yaml
│   ├── ws_client.py     # WebSocket 请求/响应、多 topic
│   ├── assertions.py    # 成功/失败、result 断言
│   └── response_match.py # 预期 JSON 比对、占位符、忽略时间戳
└── tests/
    ├── conftest.py      # api、assert_api、ws_topic 等 fixture
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
