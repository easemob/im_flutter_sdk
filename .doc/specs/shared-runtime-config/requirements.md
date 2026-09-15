# 共享运行时配置（与 im-test-hub schema 对齐）

## User Story

作为 Flutter SDK E2E 维护者，我希望 `im_flutter_test`（被测 App）与 `native-auto-test`（Python 用例端）使用一套与 `im-test-hub` 完全一致的 `app:` 环境配置 schema，以便同一份环境信息可以在两个仓库之间直接复制使用，而不再各自维护互不兼容的 `config.yaml`。

作为 Flutter SDK E2E 维护者，我希望 SDK 初始化中固定不变的开关（autoLogin / debugMode / requireAck / requireDeliveryAck / enableAutoSyncContacts / enableUserInfo）固化在 App 初始化代码里，而随环境变化的地址与 DNS 策略从共享配置派生，以便配置文件只描述"环境"，不再夹杂只在某一个仓库生效的开关。

作为 Flutter SDK E2E 维护者，我希望桥接运行态配置（relay 地址、topic）与含凭据的环境文件分离，并让 Python 端用 `client_id/client_secret` 动态换取 REST token，以便环境文件可跨仓库复制、不混入运行态、也不再依赖容易过期的静态 token。

## Acceptance Criteria（EARS）

### Schema 与文件

1. 环境配置应使用与 `im-test-hub` 一致的根节点 `app:`，至少包含 `cluster`、`appkey`、`wait`、`imm`、`server`、`sdk`、`datasync`、`log` 字段；本仓库保存独立副本，字段格式与 `im-test-hub` 相同。
2. 当把 `im-test-hub` 的 `e2e_scripts/ebs.yaml` 原样作为环境文件使用时，本仓库应能读取 `app.appkey`、`app.server`、`app.sdk`、`app.datasync`，并且不因 `cluster`、`imm`、`wait`、`him*` 等本仓库不消费的字段报错。
3. `native-auto-test/config/` 应提交 `env.yaml.template`（环境模板，仅占位值）与 `bridge.yaml`（桥接默认配置，不含凭据）；真实环境文件 `config/<name>.yaml` 应被 Git 忽略。
4. 环境文件选择优先级应为 `--config <path>` > `IM_TEST_CONFIG` > `native-auto-test/config/config.yaml`；三者都不存在时应在读取配置前非零失败并输出明确原因，不得回退到根目录旧 `config.yaml`。
5. 桥接文件选择优先级应为 `--bridge-config <path>` > `IM_BRIDGE_CONFIG` > `native-auto-test/config/bridge.yaml`；三者都不存在时应非零失败并输出明确原因。
6. 打包进 APK 的 `im_flutter_test/assets/` 不得包含 `appkey`、`client_secret`、token 等业务凭据；`assets/config.yaml` 应为不含凭据的占位文件，`assets/bridge.yaml` 应指向已提交的非敏感桥接默认配置。

### DNS 派生与固定开关

7. 当 `app.sdk.msync.tcp_host` 或 `app.sdk.msync.websocket_host` 去除空白后非空时，App 应以 `enableDNSConfig=false` 初始化 SDK；两者均为空时应以 `enableDNSConfig=true` 初始化。
8. `app.sdk.rest_host`、`app.datasync` 与 `app.server.base_url` 不得影响第 7 条的 DNS 判定结果。
9. App 初始化 SDK 时应固定使用 `autoLogin=true`、`debugMode=true`、`requireAck=true`、`requireDeliveryAck=true`、`enableAutoSyncContacts=false`、`enableUserInfo=true`，且不读取环境文件中的同名键。
10. 第 9 条的固定开关只能影响测试 App 的初始化参数，不得改变发布 SDK 的任何默认值。

### App 侧映射与启动

11. App 应按以下映射构建 `EMOptions`：`app.appkey`→`appKey`；`app.sdk.rest_host`（缺失或为空时回退 `app.server.base_url`）→`restServer`；`app.sdk.msync.tcp_host`/`tcp_port`→`imServer`/`imPort`；`app.sdk.msync.websocket_host`/`websocket_port`→`webSocketServer`/`webSocketPort`；`app.datasync.websocket_host`/`websocket_port`→`syncDataWebSocketServer`/`syncDataWebSocketPort`。
12. 当映射来源字段缺失或为空字符串时，App 应将对应 `EMOptions` 参数置空，而不是传入空字符串。
13. 端口字段应同时接受整数与数字字符串；无法解析为整数时应视为未提供。
14. 当环境配置缺失、YAML 非法或 `app.appkey` 为空时，App 应跳过 SDK 初始化、记录可定位的原因并继续启动 UI 与桥接页面；不得抛出未捕获异常导致进程退出。
15. 当 App 从外部文件加载环境配置时，应优先读取 `/sdcard/Android/data/com.easemob.im_flutter_test/files/config.yaml`，该文件不存在或解析失败时回退到打包的 `assets/config.yaml`。

### 桥接配置

16. 桥接配置应使用顶层 `websocket`（`base_url`、`default_topic`、`connect_timeout`、`response_timeout`、`debug`）与 `topics` 节，语义与现有 `config.yaml` 中的同名节一致。
17. 环境文件不得再包含 `websocket`、`topics`、`rest_api`、`sdk_options` 节。
18. App 读取桥接配置的优先级应为：外部 `bridge.yaml` > 打包 `assets/bridge.yaml`；缺失、空值或非法 YAML 时应回退到内置默认地址与 topic，且不抛异常。
19. 当 App 解析 `topics` 时，应按启动参数传入的 device 名（`deviceA`/`deviceB`/…）取 topic，缺失或为空时回退到 `websocket.default_topic`，再回退到内置默认值。
20. `run.sh` 在推送配置前应为每个 lane 生成桥接配置副本，仅把 `websocket.base_url` 的端口改写为该 lane 的 relay 端口，不得改写环境文件。
21. `run.sh` 应分别把环境文件推送到 App 外部目录的 `config.yaml`，把 lane 桥接文件推送到同一目录的 `bridge.yaml`。
22. `run.sh` 应把本次运行选中的环境文件与桥接文件路径通过 `IM_TEST_CONFIG` 与 `IM_BRIDGE_CONFIG` 传给 pytest 子进程，使 Python 端与 App 使用同一份配置；多 lane 模式下所有 lane 应共享同一份环境文件、各自使用 lane 专属桥接文件。

### Python 端

23. `native-auto-test/src/tools/config.py` 应只从环境文件与桥接文件读取配置，移除对根目录 `config.yaml`、`rest_api`、`sdk_options`、`get_sdk_options`、`get_sdk_app_key` 的依赖。
24. Python 端 REST base URL 应由 `app.server.base_url` 与 `app.appkey`（`org#app`）派生为 `{server.base_url}/{org}/{app}`，不再单独配置；`appkey` 不含 `#` 或 `server.base_url` 为空时应视为 REST 不可用。
25. 当 `app.server.client_id` 与 `app.server.client_secret` 均非空时，Python 端应通过 client_credentials 获取 REST token，并在进程内按 `expires_in` 缓存复用，避免每次请求都换 token。
26. 当 token 获取失败时，Python 端应向调用方暴露明确错误（包含 HTTP 状态或传输错误类别），不得使用空 token 静默发起受保护请求。
27. 当 `app.server.verify_ssl` 为 `false` 时，Python 端 REST 请求应跳过证书校验；缺失时默认校验证书。
28. 当缺少 client 凭据时，`tests/conftest.py` 现有的"通过 WS `createAccount` 预创建用户"兜底路径应保持不变。
29. Python 端读取 `websocket.base_url` 的优先级应保持为：非空 `WS_BASE_URL` 环境变量 > 桥接文件 `websocket.base_url`。
30. 当 App 加载环境配置时，加载结果应记录配置来源（外部文件或打包 asset），并在启动日志中输出，以便区分“读到注入配置”与“回退 asset”。

### Cases 时间配置扩展

初版迁移记录；其中旧场景键/环境变量兼容规则已被下方 Semantic timing vocabulary A 替代。等待位置、数值安全和事件保留要求仍有效。

作为 E2E 维护者，我希望所有业务模块的执行等待集中在环境配置中，且离线操作有独立的稳定窗口，以便调整自动化节奏而不修改测试断言。

- 当业务 cases 读取时间配置时，系统应使用当前环境文件的 `app.case_timing`，所有值以秒计；未配置使用内置默认。
- 当配置普通依赖步骤间隔时，系统应默认使用 1 秒；当配置离线退出后、重登前、重登后稳定等待时，应默认各使用 3 秒。
- 当迁移已有专用等待时，系统应保留原默认值，且优先使用 YAML，其次已有时间环境变量，最后内置默认。
- 当设置 sleep/清理窗口为零时，系统应允许；当超时、轮询、无事件观察窗口非正或任意值为负数、布尔值、非有限数时，应明确报错且不输出配置中的凭据。
- 当登录并启动回调后进行稳定等待时，系统应保留事件队列，不清理待验证的离线事件。
- 当等待目标事件时，系统应保留精确匹配和总预算，收到目标事件立即返回；无事件断言应观察完整配置窗口。
- 当实施本扩展时，系统不得向所有底层 API 调用注入 sleep，不得放宽断言、替换事件或新增业务重试掩盖失败。
- 当盘点业务时间值时，应区分业务输入（时间戳、禁言/订阅期限及非法边界）与执行等待；前者保留并记录，不混入等待参数。
- 本扩展覆盖 tests 下八个真实业务模块、公共 fixtures 和直接依赖的 flow/wait helper；tests/tools 仅作为无设备回归测试，不属于业务迁移范围。

### 文档与验证

31. 当本功能完成时，`native-auto-test/README.md`、`skills/im-flutter-run/SKILL.md`、`config/env.yaml.template` 注释应说明新 schema、环境/桥接文件选择优先级、DNS 派生规则以及固定开关所在位置。
32. 当本功能完成时，`.doc/specs/local-websocket-bridge/` 中引用 `config.yaml`（`websocket`、`topics`）的部分应同步更新为桥接文件，避免 spec 与实际行为漂移。
33. 当本功能完成时，Dart 单元测试应覆盖：固定开关、DNS 派生、地址映射、空值/字符串端口处理、桥接解析与外部文件优先于 asset，且不依赖设备或网络。
34. 当本功能完成时，Python 单元测试应覆盖：环境/桥接文件选择优先级、未知字段容错、REST base URL 派生、client_credentials token 获取与缓存、`verify_ssl` 行为、`WS_BASE_URL` 优先级，且不依赖设备或外部网络。
35. 当本功能完成时，应确认 `cd im_flutter_test && flutter analyze`、`flutter test`、`cd native-auto-test && python -m compileall src tests` 与新增单元测试全部通过，并在交付说明中给出摘要。

## Simplified settling and event-to-operation pacing
User Story: As a case maintainer I want three settling knobs and explicit pacing after validated events.
- WHEN step is a scalar THEN cases shall use it as the ordinary interval.
- WHEN settle.offline/normal/slow are configured THEN related boundaries shall share those settings (defaults 3/5/15 seconds).
- WHEN grouped callbacks have been validated before the next group workflow operation THEN cases shall pause for the ordinary interval without draining events.
- WHILE collecting callbacks from one operation THEN cases shall retain matching and negative observation budgets without inter-callback sleeps.

## Offline operation-to-login boundary audit
User Story: As a case author I need the offline recipient to stay offline briefly after the peer operation succeeds.
- WHEN a peer completes an invitation, approval, contact change or message operation for an offline recipient THEN the recipient shall wait settle.offline before initiating login.
- WHEN a direct sync-relogin case bypasses the shared helper THEN it shall apply the same boundary pauses without changing callback activation or assertions.

## Semantic timing vocabulary (A; supersedes call-site keys and legacy timing environment variables)
User Story: As a maintainer I want a small vocabulary describing wait purposes with an explicit module dimension, so configuration survives case/helper renames.
- WHEN a case resolves timing THEN it shall call seconds(key, module=...) or pause(key, module=...) with a registered semantic key and explicit module (including session/shared).
- WHEN overrides overlap THEN precedence shall be module semantic value > global semantic value > module default > section default > built-in semantic default, uniformly for every section.
- WHEN step is a scalar THEN it shall be equivalent to step.interval; module overrides may use a scalar or a mapping with semantic names/default.
- WHEN migrating THEN existing pause positions, callback matching and numeric budgets shall remain unchanged unless a semantic budget normalization is explicitly recorded and regression-tested; special sorting/download waits shall not be shortened.
- WHEN resolving configuration THEN unknown sections, semantic names, modules and malformed/unsafe values shall fail without exposing credentials; old call-site YAML names are not supported and must fail rather than silently fall back.
- WHEN old *_SETTLE_SECONDS timing environment variables are present THEN they shall no longer affect timing; YAML is the single configurable source (IM_TEST_CONFIG still selects the environment file).
- WHEN classifying waits THEN positive callback timeouts shall not use drain; event receive slices, polling sleeps and algorithmic positive epsilon shall remain distinct. Numeric epsilon is an implementation constant, not a configuration field.
- WHEN shared offline helpers are used THEN callers shall pass their module explicitly; offline settling remains 3 seconds and shall not drain queued events.

## Full business dependency coverage
User Story: As a maintainer I want dependent operations paced even through helpers and branches.
- WHEN a successful mutation or its validated callback batch precedes a dependent business operation THEN cases shall pause step unless an explicit settling pause already covers the boundary.
- WHEN offline cases use nested preparation/relogin helpers THEN the audit shall resolve those helpers rather than rely on test names.
- WHILE receiving callback batches or polling a deadline THEN pacing shall not consume that budget or replace assertions.
