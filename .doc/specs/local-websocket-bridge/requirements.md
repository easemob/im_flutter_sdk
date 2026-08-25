# 本地 WebSocket 测试桥接服务

## User Story

作为 Flutter SDK E2E 测试维护者，我希望在 `native-auto-test` 中通过一个明确命令启动本地 WebSocket 桥接服务，从而让 Python cases 与本机 Android 模拟器上的 `im_flutter_test` 通讯，不依赖公共服务器 `ws://140.143.132.6:4000`。

作为仓库协作者，我希望本地桥接服务复用项目现有 Python 环境、提供独立的模拟器端口映射命令和完整使用文档，从而可以在自己的开发机上重复搭建相同测试链路，而不被脚本自动修改账号、REST、App 或 pytest 配置。

## Acceptance Criteria（EARS）

1. 当开发者在 `native-auto-test` 中执行 `make ws-bridge-local` 时，系统应使用当前 Python 环境启动本地 WebSocket 桥接服务，默认监听 `127.0.0.1:4000` 并接受 `/iov/websocket/dual?topic=<topic>` 连接。
2. 当开发者通过 `WS_HOST` 或 `WS_PORT` 启动服务时，系统应使用显式提供的监听地址或端口；未提供时应保持默认值。
3. 当两个或多个客户端连接同一个非空 topic 时，一个客户端发送的文本帧或二进制帧应原样转发给同 topic 的其他客户端，且发送者不应收到自身消息回显。
4. 当客户端连接不同 topic 时，任一 topic 的消息不得转发到其他 topic。
5. 当连接路径不是 `/iov/websocket/dual` 或缺少非空 `topic` 查询参数时，服务应拒绝该连接并给出可定位的关闭原因。
6. 当客户端断开或服务收到终止信号时，服务应清理连接与 topic 状态，不遗留后台任务；`Ctrl-C` 应正常停止进程。
7. 当服务记录运行日志时，日志应仅包含监听地址、连接生命周期、topic 和连接数量，不得打印消息正文、账号、token 或其他业务载荷。
8. 当开发者执行 `make ws-bridge-reverse` 时，系统应仅为处于 `device` 状态且序列号以 `emulator-` 开头的 Android 模拟器设置 `adb reverse tcp:<port> tcp:<port>`；该命令不得启动服务、修改 App URL、修改 `config.yaml` 或操作业务账号。
9. 当未发现可用 Android 模拟器或找不到 `adb` 时，端口映射命令应非零退出并给出明确修复提示，不得静默成功。
10. 当运行 pytest 时，如果设置了 `WS_BASE_URL`，Python WebSocket 客户端应优先使用该值；未设置或值为空时，应继续使用 `config.yaml.websocket.base_url`，保持现有远程服务器行为。
11. 当其他开发者按 README 操作时，文档应明确说明服务启动、端口映射、设备 A/B 的 URL/topic/device 配置、Python 地址覆盖、连接验证和恢复远程服务器的方法。
12. 当本功能完成时，自动化测试应覆盖同 topic 转发、跨 topic 隔离、无发送者回显、文本与二进制帧、非法路径、缺失 topic、断开清理以及 `WS_BASE_URL` 配置优先级，且测试不得依赖 Android 设备或外部服务器。
13. 当开发者执行 `make ws-bridge-up` 时，系统应以后台进程启动本地 relay、扫描在线 Android 模拟器、配置 `adb reverse`，并生成 Git 忽略的 `.local/ws-bridge.env`；一个命令成功后应具备运行本地 pytest 的全部 Python/control 侧桥接前置。Flutter App 的 URL、topic、device 和连接动作仍由开发者在 App 中配置。
14. 当 `make ws-bridge-up` 成功时，系统应将 relay PID 写入 `.local/ws-bridge.pid`、将非业务运行日志写入 `.local/ws-bridge.log`，并将唯一 Python 覆盖项 `WS_BASE_URL=ws://127.0.0.1:<port>/iov/websocket/dual` 写入环境文件；不得改写 `config.yaml`。
15. 当 relay 已由当前项目启动且仍存活时，重复执行 `make ws-bridge-up` 应保持同一进程、补齐 reverse 和环境文件并成功退出，不得启动重复服务。
16. 当自动启动、端口监听、reverse 配置或环境文件写入任一步失败时，系统应非零退出并回滚本次新建的 relay、reverse 和状态文件，不得留下部分成功状态，也不得终止非本项目管理的进程。
17. 当开发者执行 `make test-local ARGS=<pytest args>` 时，系统应从 `.local/ws-bridge.env` 加载 `WS_BASE_URL` 后运行 pytest；环境文件缺失时应在运行 pytest 前明确失败。
18. 当开发者执行 `make ws-bridge-down` 时，系统应删除在线模拟器对应端口的 reverse、仅停止 PID 文件所指且命令身份匹配本地 relay 的进程，并只在全部停止和清理动作成功时删除 `.local/ws-bridge.env` 与 `.local/ws-bridge.pid`；重复执行应安全完成。
19. 当自动化状态写入 `.local/` 时，该目录应被 Git 忽略，内容不得包含账号、token、REST 配置或消息正文。
20. 当本功能完成时，无设备自动化测试还应覆盖 reverse 删除、仅操作在线模拟器、自动 up/down 生命周期、幂等启动、失败回滚、环境文件内容和 `test-local` 的环境加载。
21. 当 `.local/ws-bridge.env` 存在时，`down` 和健康检查应从其中解析实际 relay host、port 与 path，并以该运行状态为准；调用者传入不同的 `WS_PORT` 或 `WS_PATH` 不得导致受管 relay 变成孤儿进程。
22. 当 reverse 清理失败、受管 PID 身份不匹配或 relay 无法停止时，`down` 应非零退出、保留 PID/env 管理文件并输出未停止或未完全清理的信息；不得打印成功的“已停止”消息。
23. 当执行 `make ws-bridge-up` 时，系统应在启动后台进程前验证所选 Python 能够导入 `websockets` 和本地 relay 模块；预检失败时应立即非零退出并显示直接原因，不得启动 relay 或配置 reverse。
24. 当执行 `make test-local` 时，系统应在 pytest 前验证 env、PID、受管进程身份以及本地 WebSocket 握手；任一检查失败时应明确失败且不得运行 pytest。
25. 当协作者安装 Python 依赖时，`websockets` 应被限制在仍提供项目现有 `websockets.legacy` API 的兼容版本范围内，避免重新安装环境后因上游删除 legacy API 导致 relay 或现有 WebSocket 客户端无法导入。
26. 当 relay 处理包含敏感标记的文本或二进制帧时，服务日志不得包含帧正文或其字符串表示；自动化测试应验证该约束。
27. 当 `ADB` 指向不存在或不可执行的文件，或在默认搜索位置和 `PATH` 中均找不到 adb 时，reverse 命令应在调用设备命令前非零退出并给出明确提示。
28. 当 relay 子进程在监听端口前退出时，`make ws-bridge-up` 应非零退出并清理本次创建的 PID/env/reverse 状态，不得遗留受管状态文件。
29. 当本地桥接已经停止后，重复执行 `make ws-bridge-down` 应成功完成，不得重新创建 PID/env 或误报残留进程。
30. 当 relay CLI 收到越界端口、包含 query/fragment/空白的 path，或空白 host 时，应在启动监听器前非零退出，并与 lifecycle 入口遵循相同的校验语义。
31. 当运行 `tests/tools` 时，根级登录 fixture 应显式识别工具测试并跳过设备、用户和登录 fixture；不得依赖同名 fixture 覆盖来阻止外部网络与设备操作。
32. 当两个 lifecycle 操作并发访问同一 `WS_STATE_DIR` 时，系统应通过该目录内的互斥锁保证最多一个操作修改 PID/env/reverse 状态；竞争操作应快速、明确失败，不得覆盖或删除另一个操作的状态。
33. 当 lifecycle 操作异常退出并遗留互斥锁时，后续操作应在确认锁所有者进程已不存在后回收陈旧锁；不得回收仍由存活进程持有的锁。
