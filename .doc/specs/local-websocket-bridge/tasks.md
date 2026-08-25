# 本地 WebSocket 测试桥接服务实施计划

> **执行要求：** 按本文件逐项实施，使用 TDD 红—绿—重构；本文件是唯一任务状态来源，不创建额外 implementation plan。未经用户明确要求，不提交、不推送 Git。

**目标：** 在 `native-auto-test` 中提供团队可复用的本地 topic WebSocket relay、独立 Android 模拟器 reverse 命令和无文件改写的 pytest 地址覆盖。

**架构：** Python relay 使用项目现有 `websockets.legacy.server` API，在进程内维护 `topic -> connections` 并透明转发帧。Makefile 提供全自动 up/down/test-local 主流程，并保留前台启动和独立 reverse 入口用于诊断；Flutter App 保持运行时手动配置，pytest 通过 Git 忽略的环境文件临时覆盖 YAML 地址。

**技术栈：** Python 3.9+、`websockets>=11.0`、pytest、pytest-asyncio、Bash、GNU/BSD Make。

## 全局约束

- 默认服务地址固定为 `127.0.0.1:4000`，默认 path 固定为 `/iov/websocket/dual`。
- 不增加 Node、Docker 或新的 Python 生产依赖。
- 不修改 `im_flutter_sdk` 发布层或 Flutter 测试 App 默认地址。
- 不自动修改 `config.yaml`、App 页面配置、REST 配置或业务账号。
- 服务日志不得输出 WebSocket 帧正文或业务载荷。
- `ws-bridge-reverse` 默认仅操作状态为 `device` 的 `emulator-*`，不得操作物理设备。

---

## Task 1：Relay 无设备失败测试

**Files**

- Create: `native-auto-test/tests/tools/test_ws_relay_server.py`
- Create later: `native-auto-test/src/tools/ws_relay_server.py`

**Interfaces**

- Consumes: `websockets.connect(url)` 和 pytest-asyncio。
- Produces: 后续实现必须提供 `TopicRelay(path: str)`、`start_relay(host: str, port: int, path: str) -> tuple[WebSocketServer, TopicRelay]`，并可通过 `TopicRelay.connection_counts` 只读查看 `{topic: count}`。

- [x] 新增异步 fixture，在 loopback 临时端口调用尚不存在的 `start_relay()`，测试结束时执行 `server.close()` 与 `await server.wait_closed()`。
- [x] 新增同 topic 文本转发测试：连接 sender/receiver，sender 发送 `"hello"`，receiver 应原样收到。
- [x] 新增二进制帧测试：发送 `b"\x00\x01"`，接收类型和值均保持 `bytes`。
- [x] 新增发送者无回显测试：receiver 收到后，sender 在短超时内 `recv()` 应超时。
- [x] 新增跨 topic 隔离测试：topic A 发送后 topic B 在短超时内不得收到。
- [x] 新增非法 path、缺失 topic、空 topic 测试：连接应以关闭码 `1008` 和不含业务数据的原因被拒绝使用。
- [x] 新增断开清理测试：关闭最后一个客户端后，轮询直到 `connection_counts == {}`，最长等待 1 秒。
- [x] 运行：

  ```bash
  cd native-auto-test
  ./.flutter-vnev/bin/python -m pytest -q tests/tools/test_ws_relay_server.py
  ```

  预期：测试 collection 因 `src.tools.ws_relay_server` 不存在而失败，证明测试先于实现。

## Task 2：Relay 最小实现与 CLI

**Files**

- Create: `native-auto-test/src/tools/ws_relay_server.py`
- Test: `native-auto-test/tests/tools/test_ws_relay_server.py`

**Interfaces**

- `TopicRelay.__init__(path: str = "/iov/websocket/dual")`
- `TopicRelay.handle(websocket: WebSocketServerProtocol) -> None`，从 `websocket.path` 读取请求路径。
- `TopicRelay.connection_counts -> dict[str, int]`
- `start_relay(host: str = "127.0.0.1", port: int = 4000, path: str = "/iov/websocket/dual") -> tuple[WebSocketServer, TopicRelay]`
- `main(argv: Optional[Sequence[str]] = None) -> int`

- [x] 实现 `_normalize_path()`：必须以 `/` 开头且不得包含 query/fragment；非法时抛出 `ValueError`。
- [x] 实现 `_topic_from_request_path()`：使用 `urllib.parse.urlsplit/parse_qs`，只接受唯一、去除空白后非空的 topic。
- [x] 实现 `TopicRelay` 注册和 finally 清理；`connection_counts` 返回副本，不向调用方暴露可变集合。
- [x] 实现透明广播：逐个向同 topic 的其他连接发送原始 `str`/`bytes`；失败连接从注册表清理；不回显给 sender。
- [x] 实现非法 path/topic 的 `close(code=1008, reason=...)`；reason 只描述 path/topic 错误。
- [x] 实现 `start_relay()`，使用 `websockets.legacy.server.serve` 以兼容项目声明的 `websockets>=11.0`。
- [x] 实现 CLI 参数 `--host`、`--port`、`--path`，端口限制为 1..65535；启动时仅打印监听地址，`Ctrl-C` 返回 0 并关闭 server。
- [x] 重跑 Task 1 测试：

  ```bash
  ./.flutter-vnev/bin/python -m pytest -q tests/tools/test_ws_relay_server.py
  ```

  预期：全部通过。
- [x] 验证 CLI 和语法：

  ```bash
  ./.flutter-vnev/bin/python -m src.tools.ws_relay_server --help
  ./.flutter-vnev/bin/python -m compileall -q src/tools/ws_relay_server.py
  ```

## Task 3：`WS_BASE_URL` 配置覆盖 TDD

**Files**

- Create: `native-auto-test/tests/tools/test_config.py`
- Modify: `native-auto-test/src/tools/config.py`

**Interfaces**

- Consumes: 现有 `load_config()`。
- Produces: `get_ws_base_url() -> str`，优先级为非空且 strip 后的环境变量 > YAML。

- [x] 新增测试，monkeypatch `load_config()` 为固定远程 URL，并分别验证：环境变量未设置时回退、空白值回退、非空值 strip 后覆盖。
- [x] 仅运行新增配置测试，确认非空环境变量用例在修改前失败：

  ```bash
  ./.flutter-vnev/bin/python -m pytest -q tests/tools/test_config.py
  ```
- [x] 在 `config.py` 导入 `os`，将 `get_ws_base_url()` 改为读取 `os.getenv("WS_BASE_URL", "").strip()`；结果非空则返回，否则调用现有 `load_config()`。
- [x] 重跑配置测试并确认全部通过。

## Task 4：Make 启动入口与独立 ADB reverse

**Files**

- Modify: `native-auto-test/Makefile`
- Create: `native-auto-test/scripts/adb_reverse_ws_bridge.sh`
- Create: `native-auto-test/tests/tools/test_adb_reverse_ws_bridge.py`

**Interfaces**

- `make ws-bridge-local PY=<python> WS_HOST=<host> WS_PORT=<port> WS_PATH=<path>`
- `make ws-bridge-reverse ADB=<adb> WS_PORT=<port>`

- [x] 先用临时 fake adb 新增无设备测试，验证只操作在线 `emulator-*`、不操作物理设备、无模拟器失败和非法端口失败；运行并确认脚本不存在导致预期红灯。
- [x] 在 Makefile 增加默认变量 `WS_HOST ?= 127.0.0.1`、`WS_PORT ?= 4000`、`WS_PATH ?= /iov/websocket/dual` 和两个 `.PHONY` target。
- [x] `ws-bridge-local` 前台执行：

  ```make
  $(PY) -m src.tools.ws_relay_server --host "$(WS_HOST)" --port "$(WS_PORT)" --path "$(WS_PATH)"
  ```
- [x] 实现 Bash 脚本：按 `ADB` 环境变量、Android SDK 常见路径、PATH 的顺序查找 adb；校验端口 1..65535。
- [x] 脚本解析 `adb devices`，只收集第二列为 `device` 且序列号匹配 `^emulator-` 的条目；为空时打印修复提示并非零退出。
- [x] 对每台模拟器执行 `wait-for-device`、`reverse tcp:$WS_PORT tcp:$WS_PORT`，再用 `reverse --list` 验证映射存在；任一步失败应显示 serial 并非零退出。
- [x] `ws-bridge-reverse` 仅调用脚本，不依赖或启动 `ws-bridge-local`。
- [x] 验证：

  ```bash
  ./.flutter-vnev/bin/python -m pytest -q tests/tools/test_adb_reverse_ws_bridge.py
  bash -n scripts/adb_reverse_ws_bridge.sh
  make help
  make -n ws-bridge-local
  make -n ws-bridge-reverse
  ```

## Task 5：文档、总验证和任务回填

**Files**

- Modify: `native-auto-test/README.md`
- Modify: `.doc/specs/local-websocket-bridge/tasks.md`
- Modify if implementation diverges: `.doc/specs/local-websocket-bridge/requirements.md`, `.doc/specs/local-websocket-bridge/design.md`

- [x] README 增加“本地 WebSocket 桥接”章节：安装依赖、两个 Make 命令、A/B 的 URL/topic/device 表格、`WS_BASE_URL=... pytest ...`、listener/reverse 检查、Ctrl-C 停止和取消环境变量恢复远程地址。
- [x] README 明确 relay 只替代测试控制桥，不替代 MSync、Gateway 或 `syncDataWebSocketServer`，也不提供离线队列和公网服务。
- [x] 运行完整无设备验证：

  ```bash
  ./.flutter-vnev/bin/python -m pytest -q tests/tools/test_ws_relay_server.py tests/tools/test_config.py
  ./.flutter-vnev/bin/python -m compileall -q src/tools/ws_relay_server.py src/tools/config.py
  bash -n scripts/adb_reverse_ws_bridge.sh
  make -n ws-bridge-local
  make -n ws-bridge-reverse
  git diff --check
  ```
- [x] 如果当前连接着模拟器，只做 `adb devices` 和已有 reverse 的只读检查；真实写入 reverse 和业务 smoke case 需用户另行明确授权。只读结果：`emulator-5554`、`emulator-5556` 在线，均未配置 `tcp:4000`。
- [x] 对照 requirements 1..12 回填本文件状态和验证结果；实现未偏离 requirements/design。

## 验证记录

- Relay 测试红灯：`ModuleNotFoundError: src.tools.ws_relay_server`；实现后 8 条通过。
- 配置测试红灯：非空 `WS_BASE_URL` 仍返回 YAML 地址；实现后 3 条通过。
- ADB 脚本测试红灯：目标脚本不存在；实现后 3 条通过。
- 完整无设备验证：14 passed，另有项目现存 `websockets.legacy` 弃用警告 1 条。
- 进程级 smoke：`make ws-bridge-local WS_PORT=43999` 启动成功，同 topic 双客户端转发成功；直接 CLI 收到 SIGINT 后关闭 server 且返回 0。
- 未执行真实 `make ws-bridge-reverse` 或业务 E2E case；这两步会修改模拟器状态或共享测试环境，需要用户另行明确授权。

## Task 6：全自动生命周期失败测试

**Files**

- Modify: `native-auto-test/tests/tools/test_adb_reverse_ws_bridge.py`
- Create: `native-auto-test/tests/tools/test_ws_bridge_local.py`
- Create later: `native-auto-test/scripts/ws_bridge_local.sh`

- [x] 先扩展 fake adb，覆盖 `remove` 只操作在线模拟器、删除指定端口和无在线模拟器时安全完成；运行确认当前脚本不支持导致红灯。
- [x] 使用临时 state 目录、fake adb 和真实 Python relay 新增 lifecycle 测试：up 创建可用进程、PID/env/log，写入唯一 `WS_BASE_URL`，调用 reverse add；down 调用 reverse remove、停止进程并删除 PID/env。
- [x] 新增幂等 up 测试，确认第二次 up 保持原 PID；新增 reverse/环境文件写入失败测试，确认新启动进程、reverse 和状态文件被回滚；新增 down 不终止无关 PID 测试。
- [x] 运行新增测试并确认红灯：10 条目标测试中 7 failed、3 passed，失败点分别为 remove 不受支持、lifecycle 脚本不存在和 Make target 不存在。

## Task 7：实现全自动 up/down 与 Make 入口

**Files**

- Modify: `native-auto-test/.gitignore`
- Modify: `native-auto-test/Makefile`
- Modify: `native-auto-test/scripts/adb_reverse_ws_bridge.sh`
- Create: `native-auto-test/scripts/ws_bridge_local.sh`

- [x] 将 `.local/` 加入 Git ignore；生命周期持久状态固定为 env、pid、log 三个文件，不存业务凭据（Task 16 后增加命令期间临时存在的 lock 目录）。
- [x] 为 reverse 脚本增加 `add|remove` 参数；add 保持现有严格失败语义，remove 幂等且无在线模拟器时成功。
- [x] 实现 lifecycle `up`：解析/校验参数、识别已有受管进程、启动后台 relay、轮询端口、配置 reverse、原子写 env/pid，并在失败时回滚本次新建进程、reverse 和状态文件。
- [x] 实现 lifecycle `down`：remove reverse、仅停止身份匹配的 PID、删除 env/pid；重复执行安全。
- [x] 新增 `make ws-bridge-up`、`make ws-bridge-down`、`make test-local`；后者缺少 env 文件时不得运行 pytest。
- [x] 重跑 Task 6 和已有工具测试，确认 23 条全部通过。

## Task 8：全自动文档与最终验证

- [x] 将 README 主流程调整为 `make ws-bridge-up` → App 连接 → `make test-local ARGS=...` → `make ws-bridge-down`；保留前台启动和独立 reverse 作为诊断方式。
- [x] 验证 `make help`、三个新 target dry-run、shell 语法、compileall、完整工具测试和 `git diff --check`。
- [x] 使用 fake adb 完成无设备进程级 up/down smoke；未修改当前真实模拟器 reverse。
- [x] 回填本文件 Task 6..8 结果，并确认 requirements 13..20 均有实现与验证证据。

## 全自动验证记录

- 全自动红灯：目标测试初次运行 7 failed、3 passed；失败证据覆盖 remove 未实现、lifecycle 脚本缺失、Make target 缺失。
- 环境文件异常红灯：目标路径被目录占用时 up 曾错误返回 0；修复后会输出环境文件错误并回滚 relay 与 reverse。
- 完整无设备测试：23 passed，另有项目现存 `websockets.legacy` 弃用警告 1 条。
- 静态验证：`compileall`、两个 Bash 脚本 `bash -n`、`make help`、`ws-bridge-up/down/test-local` dry-run 和 `git diff --check` 均通过。
- 进程级 lifecycle smoke 使用真实临时 relay + fake adb，验证同 topic 转发、PID/env/log、幂等 up、对称 down、失败回滚和无关 PID 保护。
- 未执行真实 `make ws-bridge-up/down` 或业务 E2E case，因此未修改真实模拟器 reverse 或共享测试环境。

## Task 9：第一批可靠性修复红灯测试

**Files**

- Modify: `native-auto-test/tests/tools/test_ws_bridge_local.py`
- Modify: `native-auto-test/tests/tools/test_make_local.py`

- [x] 新增自定义端口 up 后以不同 `WS_PORT` down 的 lifecycle 测试；旧实现返回 1、relay 仍存活且 PID/env 被错误删除。
- [x] 修改无关 PID down 测试，要求失败时 PID/env 保留且 stdout 不包含“已停止”；旧实现因删除状态和打印成功消息而失败。
- [x] 新增 Python 缺少 `websockets` 的 up 测试，要求快速失败、直接包含导入错误且 fake adb 未被调用；旧实现等待 listener 后才失败。
- [x] 新增 lifecycle check 与 `make test-local` stale relay 测试，要求健康检查失败时 fake pytest 不运行；旧 Makefile 仅检查 env，因此错误运行 pytest。
- [x] 运行上述目标测试并记录红灯：12 条目标测试中 6 failed、6 passed；失败点与上述缺失行为一一对应。

## Task 10：运行状态恢复与安全 down

**Files**

- Modify: `native-auto-test/scripts/ws_bridge_local.sh`
- Test: `native-auto-test/tests/tools/test_ws_bridge_local.py`

- [x] 实现从 `.local/ws-bridge.env` 安全解析 `WS_BASE_URL` 并恢复 host/port/path；down/check 以该状态覆盖调用参数。
- [x] down 仅在 reverse 清理、进程身份验证和停止全部成功时删除 PID/env；失败时保留状态并输出“未完全停止/清理”。
- [x] 仅在 status=0 时打印“已停止”；参数不匹配 down 可停止原端口实例。
- [x] 运行 Task 9 lifecycle 测试确认转绿；lifecycle + Make 目标测试 12 passed。

## Task 11：依赖预检与 test-local 健康检查

**Files**

- Modify: `native-auto-test/scripts/ws_bridge_local.sh`
- Modify: `native-auto-test/Makefile`
- Test: `native-auto-test/tests/tools/test_ws_bridge_local.py`
- Test: `native-auto-test/tests/tools/test_make_local.py`

- [x] up 在后台启动前使用所选 Python 导入 `websockets` 和 `src.tools.ws_relay_server`；失败立即退出且不调用 adb。
- [x] lifecycle 增加 `check`，验证 env、PID、受管进程身份并完成 `/iov/websocket/dual?topic=<health-topic>` WebSocket 握手。
- [x] `make test-local` 在 source env 和运行 pytest 前调用 lifecycle check；失败时不得调用 pytest。
- [x] 运行 Task 9 健康检查测试确认转绿，并重跑全部 tools 测试：28 passed。

## Task 12：文档与最终验证

**Files**

- Modify: `native-auto-test/README.md`
- Modify: `.doc/specs/local-websocket-bridge/requirements.md`
- Modify: `.doc/specs/local-websocket-bridge/design.md`
- Modify: `.doc/specs/local-websocket-bridge/tasks.md`

- [x] README 明确 down 自动使用 env 中真实端口、失败会保留状态、test-local 会先做 relay 健康检查，以及“一键”只覆盖 Python/control 侧。
- [x] 执行完整 tools pytest、两个 Bash 语法检查、Python compileall、Make dry-run、speckit check 和 `git diff --check`。
- [x] 回填 Task 9..12 与 requirements 21..24 的验证证据；未执行真实 reverse 或业务 E2E。

## 第一批可靠性修复验证记录

- TDD 红灯：`test_ws_bridge_local.py + test_make_local.py` 共 12 条，旧实现结果为 6 failed、6 passed；确认 down 参数错配、错误状态清理、依赖预检、check 和 stale relay 阻断均能被新测试捕获。
- 目标绿灯：相同 12 条测试全部通过。
- 完整 tools 回归：28 passed；仍有 1 条既有 `websockets.legacy` 弃用警告，该依赖迁移不属于本批修复。
- 所有 lifecycle 测试使用临时端口、真实本地 relay 与 fake adb，未读取或修改真实模拟器 reverse。
- 静态与仓库验证：两个 Bash `bash -n`、Python `compileall`、`make help`、三个 Make target dry-run、`speckit check`、工作区与暂存区 `git diff --check` 均通过。

## Task 13：第二批兼容性与验收缺口红灯

**Files**

- Modify: `native-auto-test/requirements.txt`
- Modify: `native-auto-test/tests/tools/test_ws_relay_server.py`
- Modify: `native-auto-test/tests/tools/test_adb_reverse_ws_bridge.py`
- Modify: `native-auto-test/tests/tools/test_ws_bridge_local.py`

- [x] 将 `websockets` 依赖上限的预期写入 requirements，并确认当前无上限声明不符合 requirement 25。
- [x] 新增 relay 日志载荷泄漏测试，使用唯一文本和二进制敏感标记并捕获真实 logger。
- [x] 新增显式不可执行 ADB 与完全找不到 adb 的脚本测试，断言未调用设备命令。
- [x] 新增 relay 子进程启动失败回滚测试和连续两次 down 的幂等测试。
- [x] 运行第二批目标测试，记录实现前失败点；已有正确行为只补回归保护，不为了制造红灯修改生产代码。实现前 32 条目标测试为 4 failed、28 passed，失败均来自依赖上限和 CLI 校验。

## Task 14：统一 CLI 校验并修复第二批行为

**Files**

- Modify: `native-auto-test/requirements.txt`
- Modify: `native-auto-test/src/tools/ws_relay_server.py`
- Test: `native-auto-test/tests/tools/test_ws_relay_server.py`

- [x] 将依赖约束改为 `websockets>=11.0,<17.0`，保留项目当前 legacy API 兼容面。
- [x] 提取并复用 host/path 校验，确保 CLI 在启动监听前拒绝空白 host、含空白/query/fragment 的 path；内部 `start_relay(port=0)` 测试能力保持不变。
- [x] 运行 relay 与 CLI 目标测试并确认转绿：第二批目标测试 32 passed。

## Task 15：工具测试隔离与生命周期并发红灯

**Files**

- Modify: `native-auto-test/tests/conftest.py`
- Delete: `native-auto-test/tests/tools/conftest.py`
- Modify: `native-auto-test/tests/tools/test_ws_bridge_local.py`

- [x] 删除 tools 同名影子 fixture，直接运行最小 tools 测试并记录根 fixture 错误解析设备/用户依赖的红灯：3 条配置测试在 session setup 超过 30 秒未进入断言，终止该次复现进程。
- [x] 将根 `global_login_logout` 改为通过 `request.getfixturevalue()` 延迟解析 E2E fixture，并对 `tests/tools` 显式短路；相同 3 条测试 0.08 秒通过。
- [x] 新增两个并发 up 的 lifecycle 测试：阻塞 fake adb 使锁竞争可复现，要求竞争者快速报锁冲突且赢家状态可正常 down。
- [x] 新增陈旧锁恢复测试，要求锁所有者不存在时后续操作可接管并清理。
- [x] 运行隔离与并发目标测试并记录实现前失败点：无锁实现 2 failed，表现为两个 up 均成功且陈旧锁未被识别。

## Task 16：生命周期互斥锁实现

**Files**

- Modify: `native-auto-test/scripts/ws_bridge_local.sh`
- Test: `native-auto-test/tests/tools/test_ws_bridge_local.py`

- [x] 在任何 PID/env/reverse 状态访问前原子获取 `ws-bridge.lock` 目录锁，记录 shell PID，并用 `EXIT` trap 释放本人持有的锁。
- [x] 存活持锁者存在时快速失败且不触碰状态；非法或死亡 PID 的陈旧锁仅允许一个竞争者回收并重试一次。
- [x] 运行 lifecycle 目标测试并确认并发、陈旧锁及现有 up/down/check 全部通过：锁目标 2 passed，lifecycle + Make 16 passed。

## Task 17：文档与第二、三批总验证

**Files**

- Modify: `native-auto-test/README.md`
- Modify: `.doc/specs/local-websocket-bridge/requirements.md`
- Modify: `.doc/specs/local-websocket-bridge/design.md`
- Modify: `.doc/specs/local-websocket-bridge/tasks.md`

- [x] README 说明依赖上限、生命周期锁冲突/陈旧锁恢复和工具测试隔离边界。
- [x] 运行完整 `tests/tools`、shell 语法、Python compileall、Make dry-run、`speckit.sh check` 与 staged/unstaged `git diff --check`。
- [x] 对照 requirements 25..33 回填本文件状态与验证证据；不执行真实 adb reverse、业务 E2E、commit 或 push。

## 第二、三批必须修复项验证记录

- 兼容性/CLI 红灯：32 条目标测试中 4 failed、28 passed；依赖无上限、空白 host、空白 path 和带 query 的 path 分别触发预期失败。实现后同一组 32 passed。
- 日志、ADB、回滚和 down 幂等在实现前已有正确行为；新增真实 logger、隔离环境和进程级测试作为 requirements 26..29 的回归保护。
- fixture 隔离红灯：删除影子 fixture 后，`tests/tools/test_config.py` 在 session setup 超过 30 秒仍未进入断言；修复根 fixture 后 3 passed in 0.08s。
- lifecycle 并发红灯：无锁实现下两个并发 up 均返回成功，陈旧锁未识别；实现后锁目标 2 passed，完整 lifecycle + Make 16 passed。
- 完整无设备 tools 回归：40 passed；当前已安装 websockets 16 仍产生 1 条 legacy 弃用警告，requirements 上限保证不会解析到 17.0+，新 asyncio API 迁移不在本批范围。
- `pip check` 返回 `No broken requirements found`，并验证版本集合包含 11/16、不包含 17。
- 静态与项目检查：Python compileall、两个 Bash `bash -n`、Make help/dry-run、`speckit.sh check`、staged/unstaged `git diff --check` 全部返回 0。
- 两次标准独立审查代理在限定窗口内未返回，快速审查模型入口不可用；未将其记录为审查通过。已完成人工逐行 diff 与 requirements 25..33 对照检查，未发现 Critical/Important。
- 未执行真实 adb reverse、业务 E2E、commit 或 push；现有用户工作区和暂存状态保留。
