# release APK 测试自动化实施计划

## Clean installation tasks
- [x] Reproduced stale-UID cleanup denial on `im_flutter_test_a`: package absent, external directory owned by an old UID, shell removal denied. Verified same-APK install → pm clear → uninstall removes the residual directory. Added bounded recovery and safe operation diagnostics; new regressions first failed (9 failed, 10 passed), then `test_clean_install.py`, `test_im_flutter_run_apk.py`, and `test_lane_summary.py` passed (76 passed). Updated helper recovered the still-affected `im_flutter_test_a_lane1` and verified clean installation; lane 0 normal installation also passed. Diagnostic emulators stopped; unrelated lane 2 devices untouched. `git diff --check` passed. Business E2E cases were not rerun.
- [x] Implement clean_install.py with identity, uninstall, safe residual cleanup and timeout checks.
- [x] Integrate clean installation and private logcat retention into run.sh; update SKILL.md.
- [x] Offline regression: test_clean_install.py + test_im_flutter_run_apk.py + test_lane_summary.py: 67 passed (one existing websockets deprecation warning). Updated fake runner to include the new helper and model package state. bash -n and git diff --check passed. No device E2E; App-identity writability and real-device recurrence remain unverified.

## ADB mDNS 防护增量任务（当前）

目标：所有安装本 skill 的机器均由运行器强制禁用并验证 mDNS。方案、范围与验收以 requirements/design 中同名增量章节为准；本节为唯一状态来源。

### M-T1：回归测试（TDD）

Files: `native-auto-test/tests/tools/test_im_flutter_run_apk.py`

- [x] 扩展 runner fixture 复制 `adb_preflight.py`，fake adb 区分已有状态与启动时 `ADB_MDNS`；为 setup/emulator/make 记录环境。
- [x] 新增单/多 lane 门禁测试：无 server、安全 server、环境强制覆盖、已启用、未知/重复字段、start/status 失败、10 秒超时、pytest 前状态变更。
- [x] 执行 `cd native-auto-test && .venv/bin/python -m pytest --noconftest -q tests/tools/test_im_flutter_run_apk.py -k mdns`，旧实现 18 failed：未执行预检/启动，unsafe 状态仍成功运行，挂起 adb 触发测试框架的 20 秒超时。

### M-T2：实现与接入

Files: `native-auto-test/skills/im-flutter-run/scripts/adb_preflight.py`、`scripts/run.sh`

- [x] helper 使用 `subprocess.run([adb, command], env={**os.environ, "ADB_MDNS": "0"}, timeout=10, capture_output=True, text=True)`；仅接受唯一关闭字段，不回显原始输出，不执行 kill-server。
- [x] runner 强制导出环境；复用 SDK 解析，setup 后调用 helper；多 lane 派发前和每 lane 均检查；pytest 前调用 `--check-only`。
- [x] 重跑 M-T1 全部目标至通过：18 passed in 23.16s。追加首次 SDK 安装（含空格路径）、子 lane 重新验证父层检查后的状态漂移测试。

### M-T3：文档与交付验证

Files: `native-auto-test/skills/im-flutter-run/SKILL.md`、本 Kiro 三件套

回归中发现上一批 reverse 清理新增 `get-state` 后，`native-auto-test/tests/tools/test_adb_reverse_ws_bridge.py` 的 fake adb 未实现该响应。本批仅补齐测试替身，不修改 reverse 生产脚本。

- [x] 文档补充完整 scripts 安装、防护、已有共享 server 一次性处理和保证边界。
- [x] 运行 runner、APK 缓存、lane 选择、reverse/lifecycle 工具回归：114 passed in 66.47s；`bash -n`、skill quick_validate、`bash im_flutter_sdk/scripts/speckit.sh check` 和 `git diff --check` 均通过。
- [x] 当前本机 ADB 36.0.2 执行 helper 默认模式与 `--check-only` 均返回 0，输出 `ADB mDNS disabled (server-status verified)`；未执行业务 E2E。
- [x] 逐项自审 M1–M8 覆盖，回填证据，交付未提交 diff；本批不 commit/push。

验证命令（在 `native-auto-test`）：`.venv/bin/python -m pytest --noconftest -q tests/tools/test_im_flutter_run_apk.py tests/tools/test_release_apk_cache.py tests/tools/test_pytest_lane.py tests/tools/test_adb_reverse_ws_bridge.py tests/tools/test_ws_bridge_local.py --tb=short`。

自审补充：重复字段中夹带非法多词值曾被最初解析器漏过，新增单/多 lane 复现均为红灯（2 failed）；改为收集每个同名字段的整行值后，最终回归全部通过。M1/M2 由环境传播及首次安装测试覆盖，M3/M4 由不安全/未知/失败/超时测试覆盖，M5/M6 由父子与 pytest 前状态变化测试覆盖，M7/M8 由隔离回归及 skill 文档覆盖。未运行真实业务用例、Android/iOS 构建；本次无 SDK/App 二进制变化。

> 原始 Task 1–6 和多设备 Backlog 保留历史记录，其中部分描述已落后于当前代码。APK 缓存状态由文末缓存增量任务记录；当前 ADB mDNS 防护状态由文首同名增量任务记录，需求和设计以对应增量章节为准。

> **执行要求：** 按本文件逐项实施，本文件是唯一任务状态来源，不创建额外 implementation plan。未经用户明确要求，不提交、不推送 Git。

**目标：** 让 `im_flutter_test` 以 release 模式稳定构建运行并启动自动连接，提供 repo-local 一键 skill 串起「构建→模拟器→安装→桥接→pytest→报告」。

**架构：** release 通过 proguard keep 规则保留环信 SDK；App 复用 `rootBundle` 读 config.yaml 的 `websocket` 节并在 initState 自动连接；skill 复用 `make ws-bridge-up` / `make test-local`，仅编排新增的构建、模拟器、安装、报告步骤。

**技术栈：** Flutter/Dart 3.5、Android Gradle R8、Bash、Python pytest、allure。

## 全局约束

- 只改 `im_flutter_test`（测试端）与 `native-auto-test`（skill），不修改 `im_flutter_sdk` 发布层。
- 不引入新生产依赖；不自动修改 `config.yaml`、REST 配置或业务账号。
- 自动连接默认单端 `deviceA`；多端自动连接不在本 spec。
- release 保留 debug 签名（沿用现有 `signingConfig = signingConfigs.debug`），仅用于内部测试。
- 未经用户明确要求，不执行 `git commit`/`push`。

---

## Task 1：release 构建支持（proguard keep 规则）

**Files**

- Create: `im_flutter_test/android/app/proguard-rules.pro`
- Edit: `im_flutter_test/android/app/build.gradle`

**Interfaces**

- 新增 `-dontwarn` 忽略厂商推送（OPPO/魅族/vivo/小米）可选依赖。
- 新增 `-keep class com.hyphenate.** { *; }` 与 `-keep class internal.com.getkeepsafe.relinker.** { *; }`。
- release buildType 引用 `proguard-rules.pro`。

- [x] 创建 `proguard-rules.pro`，含厂商推送 `-dontwarn` 与环信/ReLinker `-keep` 规则。
- [x] `build.gradle` release buildType 增加 `proguardFiles`。
- [x] `flutter build apk --release` 构建通过（58.9MB）。
- [x] 模拟器验证：无 `ClassNotFoundException`/`FATAL`，`hyphenate SDK is initialized with version: 4.23.0` 日志正常。

---

## Task 2：App 自动连接（读 config.yaml 的 websocket 节）

**Files**

- Edit: `im_flutter_test/lib/sdk_config_loader.dart`
- Edit: `im_flutter_test/lib/websocket_config_page.dart`
- Create: `im_flutter_test/test/sdk_config_loader_websocket_test.dart`（如可无设备测）

**Interfaces**

- `SdkConfigLoader` 新增读取 `websocket.base_url` / `websocket.default_topic` 的方法，缺失回退 `kDefaultBridgeWebSocketBaseUrl` / `kDefaultBridgeWebSocketTopic`。
- `WebSocketConfigPage.initState` 异步读取配置、填充 controller 并自动 `_connect()`；保留手动连接/断开。

- [x] 在 `sdk_config_loader.dart` 新增 `loadWebSocketConfig()` + `parseWebSocketConfig()`（纯函数），空值回退默认常量。
- [x] 在 `websocket_config_page.dart` 的 `initState` 异步加载配置、填充 controller、自动触发一次 `_connect()`（device 默认 `deviceA`）。
- [x] 连接失败沿用现有 SnackBar 提示，不阻塞手动重连。
- [x] 为配置读取与回退逻辑补充单元测试（缺失节、空字符串、正常值、非法 yaml、去空白）。
- [x] `flutter analyze` 通过（仅 2 个既有 deprecation info）。
- [x] 模拟器冒烟：release APK 启动后自动以 topic=adc 连接 relay，探针请求返回响应（isLoggedInBefore -> false）。

---

## Task 3：一键 skill

**Files**

- Create: `native-auto-test/skills/im-flutter-run/SKILL.md`
- Create: `native-auto-test/skills/im-flutter-run/scripts/run.sh`

**Interfaces**

- `run.sh` 步骤：检测环境 → 构建 release APK → 启动模拟器 → 安装 → `make ws-bridge-up` → 启动 App → `make test-local ARGS=...` → `allure generate`。
- 环境检测项：flutter、adb、emulator、python、至少一个 AVD；缺失时非零退出并提示。

- [x] 编写 `run.sh`：环境检测（command -v + `emulator -list-avds`），失败快速退出并给出修复提示。
- [x] 构建步骤：`cd im_flutter_test && flutter build apk --release`。
- [x] 模拟器步骤：`emulator -avd <avd> -no-window -no-audio -no-boot-anim -gpu swiftshader_indirect -no-snapshot`，等待 `sys.boot_completed=1`。
- [x] 安装步骤：`adb install -r app-release.apk`。
- [x] 桥接步骤：复用 `make ws-bridge-up`（relay + reverse + env）。
- [x] 启动 App：`adb shell am start -n com.easemob.im_flutter_test/.MainActivity`（App 自动连接）。
- [x] 用例步骤：复用 `make test-local ARGS="$@"`，并自动加 `--alluredir=out/allure-results`。
- [x] 报告步骤：`allure generate out/allure-results -o out/allure-report --clean` 并输出路径。
- [x] 编写 `SKILL.md`（英文）与 `openai.yaml`：最小依赖（无需 Android Studio）、用法、config 生效规则。
- [x] skill 校验：`quick_validate.py` 通过（Skill is valid!）。
- [x] `run.sh` 全英文化，无中文残留；`bash -n` 语法检查通过。

---

## Task 4：验证与文档

- [x] 本地一键 `run.sh` 全流程跑通（build→模拟器→安装→桥接→pytest→报告），无需手动操作 App、无需 Android Studio。
- [x] 验证 `make ws-bridge-up/down/test-local` 行为不变；`tests/tools` 无设备测试仍通过（40 passed）。
- [x] 回归确认 `flutter build apk --debug` 未受影响（构建通过）。
- [x] 更新 `native-auto-test/README.md` 补充 skill 入口。
- [x] 更新本 tasks.md 完成状态。

---

## Task 5：双端支持（deviceA/deviceB）

**Files**

- Edit: `im_flutter_test/lib/sdk_config_loader.dart`
- Edit: `im_flutter_test/lib/websocket_config_page.dart`
- Edit: `im_flutter_test/test/sdk_config_loader_websocket_test.dart`
- Edit: `native-auto-test/skills/im-flutter-run/scripts/run.sh`

**Interfaces**

- 设备标识通过 `String.fromEnvironment('DEVICE', defaultValue: 'deviceA')` 确定。
- topic 解析优先级：`topics[device]` > `websocket.default_topic` > 默认常量。
- `run.sh` 构建两个 APK（`--dart-define=DEVICE=deviceA/deviceB`）并启动两台模拟器分别安装。

- [x] `sdk_config_loader.dart` 新增 `loadTopicForDevice(device)` / `parseTopicForDevice(content, device)`。
- [x] `websocket_config_page.dart` 用 `DEVICE` 编译常量决定 device，按 device 解析 topic，自动连接。
- [x] 补充 `parseTopicForDevice` 单元测试（6 个新用例：有值/缺失/空/非法 yaml/去空白）。
- [x] `run.sh` 支持两台模拟器：构建两个 APK，分别安装到 AVD1/AVD2（固定 adb 端口 5554/5556）。
- [x] `flutter analyze`（仅 2 个既有 info）与 `flutter test`（12 个用例）通过。

---

## Task 6：业务 cases 端到端验收

- [x] 启动两台模拟器，分别安装 deviceA/deviceB APK，确认均自动连接对应 topic。
- [x] 跑真实业务 case `tests/client/test_client.py::test_client_get_current_user`，session 双端登录成功、case 通过（1 passed）。
- [x] 确认 `make ws-bridge-up` 对两台模拟器均完成 reverse（emulator-5554 + emulator-5556）。

---

## 验收对照

对应 requirements.md 的 EARS 1-15 条，逐项确认后在本节勾选。

---

## 后续工作（Backlog）：多设备（n 个模拟器）并行

> 目标：从当前 2 模拟器（1 组双端）扩展到 4/6/8/n 个模拟器（多 lane 并行），并隔离每组账号。
> 状态：**未开始**；App 层已预留兼容（单 APK + intent extra），run.sh 仅做了 device 变量化半预留。

### 已完成的兼容基础
- [x] App 单 APK + intent extra `--es device`（`MainActivity.kt` MethodChannel + `websocket_config_page.dart`），一个 APK 通吃任意设备，后续加设备 App/APK 零改动。
- [x] `run.sh` 的 `DEVICE_A`/`DEVICE_B` 变量化（半预留，尚未循环化）。

### 后续待做（按依赖顺序）
- [ ] `conftest.py`：`_test_usernames()` 支持 `TEST_USER_PREFIX` 环境变量，账号隔离（当前同天所有 lane 共用 testMMDDuser1/2/3，并行会互踢/污染状态）。
- [ ] `run.sh`：从 A/B 写死改为设备列表数组循环（`DEVICES=(deviceA deviceB ...)`，端口 5554+2*i，AVD/安装/启动/push 全部循环）。
- [ ] `setup_emulator.sh`：支持创建 n 个 AVD（当前写死 im_flutter_test_a/b）。
- [ ] relay 隔离：每组独立 `WS_PORT`（当前写死 4000）；topic 靠独立 relay 端口隔离或独立前缀。
- [ ] 编排脚本 `run-parallel.sh`：fork 多个 run.sh（每组一个 lane，独立端口/账号前缀/报告目录）。
- [ ] 报告按 lane 归档（当前 `out/allure-report` 会被覆盖）。

### 硬件参考（实测单模拟器 3.7GB RSS / 空闲 CPU 4%）
| 规模 | 模拟器 | 内存需求 |
|---|---|---|
| 2 组（4 模拟器） | 4 | ~18GB（24GB 机器上限） |
| 3 组（6 模拟器） | 6 | ~27GB（需 32GB） |
| 4 组（8 模拟器） | 8 | ~30GB+（需 48-64GB） |

## Release APK 缓存增量任务

### 当前执行边界

用户已确认按照 spec 实现。本会话依 writing-plans / executing-plans / TDD 顺序执行以下唯一 checklist，不另建实现计划；不运行真实设备业务测试。保持设备卸载重装，不增加卸载后包存在性检查。

### S1：设计与 spec 整理

- [x] 检查项目规则、当前 run.sh、Release 工作流及已有 release-test-automation spec。
- [x] 更新 requirements.md：补充 User Stories、EARS C1–C13、缓存/设备/服务端数据边界及非目标。
- [x] 更新 design.md：补充架构、时序、缓存数据、失败策略、并发边界和测试策略。
- [x] 将历史双 APK/编译期设备标识/配置需重建等描述标注为历史，明确本次增量章节优先；不扩展为无关历史文档迁移。
- [x] 形成下方可执行实现与验证任务；本次不修改运行脚本或 SDK。
- [x] spec 自检：范围一致、无待定占位内容，C1–C13 均有对应实现/验证任务；修正文件尾多余空行后 `git diff --check` 通过。
- [x] 用户审阅并确认 spec，授权进入实现。

### S6：认证查询增量（已授权）

- [x] 更新 C14–C17 需求与安全传递、HTTP 诊断设计。
- [x] 添加认证安全与诊断测试，首跑 9 failed / 1 passed，证实缺少认证传递、环境隔离及 HTTP 诊断。
- [x] 修改 `release_apk_cache.py`：stdin 认证头、清理 curl 子进程环境、HTTP 响应解析及白名单诊断；不改变缓存回退策略。
- [x] 更新 SKILL.md 的 token 使用说明和安全边界。
- [x] 两个工具测试文件共 59 passed（47 helper + 12 runner）；bash -n、speckit check 和 git diff --check 通过。Agent 未使用真实 token，未跑设备或真实网络。
- [x] 用户反馈本地实际运行已验证缓存命中；未据此宣称所有业务用例或全部真实网络失败路径通过。
- [x] 用户授权提交本次缓存与认证修改；仅本地 commit，不推送。

### S2：先补工具测试（待授权后执行）

**Files**
- Create: `native-auto-test/tests/tools/test_release_apk_cache.py`
- Create: `native-auto-test/tests/tools/test_im_flutter_run_apk.py`

- [x] 阅读现有 tests/tools 的 fixture 与子进程 stub 约定，确保测试无需真实 GitHub、Android 或 IM 服务。
- [x] 为 C1–C3/C7/C8 编写首次下载、命中、附件变化、确定 URL、仓库隔离、文件与元数据损坏、digest 校验及并发发布测试。
- [x] 为 C4–C6 编写刷新、查询失败/限流/非法元数据、下载中断/大小错误、发布失败与旧缓存保留测试。
- [x] 为 C9–C12 编写 run.sh 单/多 lane 编排、本地来源、冲突参数、无效 APK_PATH、自复制及卸载安装顺序测试，断言 API/下载调用次数。
- [x] 运行新增测试确认缺少 helper、缓存/冲突处理未实现等预期失败；helper 首跑为 26 个 fixture 缺实现错误，runner 首跑 12 失败（其中无参数 Bash 既有错误改用 -q 隔离）。刷新后错误选回旧 generation 的回归测试也观察到真实失败后修复。

### S3：实现缓存 helper

**File**: Create `native-auto-test/skills/im-flutter-run/scripts/release_apk_cache.py`

- [x] 实现 CLI、repo/元数据严格校验、60 秒 latest 查询、目标附件唯一选择及诊断错误处理。（C1/C5/C11）
- [x] 实现稳定身份 key、metadata schema、本地大小/SHA-256 校验、可用远端 digest 校验。（C2/C3/C7）
- [x] 实现确定 tag 的附件 URL 下载、600 秒超时、`--refresh`、失败不回退。（C3–C6）
- [x] 实现仓库锁、60 秒锁等待、同文件系统临时 generation、完整目录原子发布与失败清理。（C7/C8）
- [x] stdout 只返回绝对包路径，日志/进度写 stderr；不输出敏感响应或重定向签名 URL。（C11）
- [x] 运行 helper 测试至通过，覆盖同内容强制刷新和并发已有路径不被改写。

### S4：接入 run.sh 与使用文档

**Files**
- Edit: `native-auto-test/skills/im-flutter-run/scripts/run.sh`
- Edit: `native-auto-test/skills/im-flutter-run/SKILL.md`

- [x] 解析并在 help 中说明 `--refresh-apk`；在环境准备前检查本地来源与 refresh 互斥，校验显式 APK_PATH。（C4/C10）
- [x] 单 lane 远端模式调用 helper，使用 `.local/apk-cache/`，保留既有临时安装副本及卸载/安装/配置步骤。（C1/C12）
- [x] 多 lane 外层统一解析 APK 来源，仅调用一次 helper，通过 APK_PATH 向子 lane 分发；不传 refresh/build 来源选项。（C9/C10）
- [x] 本地构建与显式包绕过远端缓存；源目标相同时不自复制。（C10）
- [x] 更新 SKILL.md：默认在线确认、缓存目录、刷新示例、网络失败停止、APK_PATH 单/多 lane 用法及参数冲突；解释 APK 缓存不保留设备用户数据。
- [x] 运行 run.sh stub 测试至通过，确认下载失败不进入设备安装。

### S5：验证与交付

所有命令从仓库根目录执行；pytest 使用 `--noconftest` 隔离业务会话 fixture，工具测试自行定义所需 fixture，不调用 session 登录。

- [x] 执行 `bash -n native-auto-test/skills/im-flutter-run/scripts/run.sh`。
- [x] 执行 `native-auto-test/.venv/bin/python -m pytest --noconftest -q native-auto-test/tests/tools/test_release_apk_cache.py native-auto-test/tests/tools/test_im_flutter_run_apk.py`。（C13）
- [x] 执行 `bash im_flutter_sdk/scripts/speckit.sh check`：Android/iOS 本地依赖检查全部 PASS，未修改构建文件。
- [x] 审查 diff：仅缓存 helper、run.sh、工具测试、SKILL.md 与本 spec 变化；检查失败不回退、并发发布与敏感日志边界。
- [x] 执行 `git diff --check`。
- [x] 回填测试命令与证据；design.md 补充原子 current 指针，避免刷新后历史 generation 被重新选中。
- [x] 交付变更列表、验证摘要及未执行项，不提交、不推送、不发布。

**验证证据与边界**：实现后两个工具测试文件合计 49 项通过（37 helper + 12 runner），包括并发锁、失败保留、current 损坏与单/多 lane；`bash -n`、`speckit.sh check`、`git diff --check` 均通过。未执行真实 GitHub 下载、模拟器业务用例、Android assembleDebug、iOS pod install 或模拟器 build；不宣称二进制全构建通过。

**发现但未扩大范围修复**：macOS 自带 Bash 3.2 下，既有 run.sh 在不传任何 pytest 参数时存在空数组 `unbound variable`；本次 runner 验证均传 `-q`（与用户原命令一致）。设备卸载错误忽略仍保持原样。缓存历史 generation 不自动清理。

## IM 业务优先级 Allure 展示增量（2026-09-14，按用户修正）

用户明确修正：保留模块/名称，标题仅加等级；统计文档可删除；参考 Test body 实际业务步骤。此前方案由本段替代。

- [x] 读取样例、参考项目步骤和当前公共入口，修正本 spec。
- [x] 修改隔离测试，确认原标题/分组、无统计依赖和步骤结构预期失败。
- [x] 固化业务等级代码表，简化 metadata hook，移除中文重命名/重分组/统计解析。
- [x] 实现实际调用的编号步骤、事件等待和预期校验，接入公共 API fixtures。
- [x] 运行报告/证据/lane、双进程、不同 rootdir、collect-only、speckit、diff 检查。
- [x] 更新 README，生成合成报告检查模块/标题/Test body，回填证据；不提交、不跑设备业务测试。


### 验证证据（修正版）

- 首轮新要求测试：4 failed / 1 passed，明确发现旧名称/说明重写、代码等级表缺失；步骤测试因缺少步骤模块失败。修正后报告、证据与 lane 工具验证共26项通过。
- 命令：`native-auto-test/.venv/bin/python -m pytest -q native-auto-test/tests/tools/test_allure_metadata.py native-auto-test/tests/tools/test_allure_evidence.py native-auto-test/tests/tools/test_lane_summary.py native-auto-test/tests/tools/test_pytest_lane.py`（等价从 native-auto-test 执行）。仅已有 websockets.legacy 弃用警告。
- 固化794个完整业务节点：P0=324、P1=283、P2=187。一次性迁移逐键/值核对一致；运行代码不读取统计文档，独立 Python 文件副本且无 docs 目录的生成验证通过。
- 真实插件对照验证原分组、description、status、参数、fullName/historyId；双进程保持4个独立结果；真实静态 skip 从其他 cwd/rootdir 正确显示原名及P1。
- 公共步骤模拟验证操作/等待/校验的1起始编号、fixture前置/清理、嵌套、失败步骤、空等待保留原判定及凭据脱敏；4条公共API路径的调用次数、参数对象、返回对象及等待参数保持。
- `pytest --collect-only -q tests --alluredir=/tmp/im-allure-corrected-collection`：801 tests collected；speckit check 全部PASS，git diff --check通过。
- 生成14项合成结果并实际查看页面：保留 tests.chat/group/tools 和文件模块，标题为原名称加等级，Test body 显示4个真实模拟执行步骤及附件。报告标明非 IM 业务回归。
- 未运行设备/真实业务、未构建App、未提交；本次仅修改报告公共层及对应验证/文档，其他并行的业务用例改动保留。

## 用例精简（2026-09-15）

- [x] 明确删除20个节点的清单，检查规则、文档和等级引用。
- [x] 保存基线，删除目标函数/文件，同步等级表。
- [x] 更新相关模块台账、依赖审计、README与数量口径。
- [x] 核对收集集合差、tools收集与报告相关回归，回填结果；不提交、不跑设备。

### 已删除范围（历史记录，不再是可执行节点）

- `tests/chat/test_chat.py::test_chat_translate_recall_smoke_exists`。
- `tests/chat/test_chat.py::test_chat_history_attach_lang_smoke_exists`。
- `tests/chat/test_chat.py::test_chat_pin_conversation_nonexistent_conversation`。
- `tests/chat/test_chat.py::test_chat_ack_conversation_read_invalid_id_response`。
- `tests/chat/test_chat.py::test_chat_modify_message_invalid_id_response`。
- `tests/chat/test_chat.py::test_chat_recall_message_invalid_id_response`。
- `tests/chat/test_chat.py::test_chat_add_reaction_invalid_id_response`。
- `tests/chat/test_chat.py::test_chat_fetch_history_invalid_conversation`。
- `tests/chat/test_chat.py::test_chat_get_message_invalid_id_returns_none_or_error`。
- `tests/chat/test_chat_crud.py::test_chat_remove_reaction_invalid_id_response`。
- `tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_destroy_room_success`。
- `tests/user_info/test_user_info.py::test_user_info_update_then_all_fetch_paths_in_one_flow`。
- `tests/group/test_group_capacity.py::test_group_capacity_defaults_to_200_and_accepts_3100_override`。
- `tests/group/test_group_capacity.py::test_group_capacity_rejects_non_positive_values`：含 `[0]`、`[-1]` 两个节点。
- `tests/group/test_group_capacity.py::test_group_options_use_active_capacity_unless_boundary_value_is_explicit`。
- `tests/group/test_group_capacity.py::test_group_snapshot_default_uses_active_capacity`。
- `tests/group/test_group_exceptions_joined_groups.py::test_group_get_joined_groups_with_extra_info_fields`。
- `tests/group/test_group_exceptions_public_groups_count.py::test_group_fetch_joined_group_count_with_extra_info`。
- `tests/push/test_push_remaining_api_coverage.py::test_push_apns_token_update_android_missing_plugin`。

### 验证结果

- 删除前801条，删除后781条；集合差与授权清单的20条完全一致，无意外新增/删除。源码函数543→524。
- 当前模块：Chat251、Group293、ChatRoom143、Contact37、Client28、Presence10、Push8、UserInfo11。tools单独收集312条，未迁移被删除用例。
- 等级表删掉13个已评级条目（其余7个原本为占位/容量契约，无等级），与剩余781个业务节点完全一致：P0=322、P1=278、P2=181。
- 启用Allure的业务collect-only成功；Group容量3100模式收集293条成功；容量0在执行前以退出码4拒绝。容量实现未删。
- 报告元数据、执行证据、lane汇总与lane分配相关工具回归26 passed；仅已有websockets.legacy弃用提示。
- 模块台账、APNs缺口说明、依赖索引、README和相关spec同步；历史执行证据不改写为当前结果。未跑设备业务，未提交代码。

- 最终静态核对：涉及删除的7个保留文件中，所有剩余函数和helper的AST与原实现一致；已删除节点在现行台账/依赖索引无残留；`git diff --check`通过。

### 后续精简与本次提交前验证（2026-09-15）

- [x] 按用户最新要求删除离线自动翻译、好友服务端/分页/本地复合查询、好友分页 pageSize=0，以及入群申请 accept-then-decline 参数，共 4 个节点。群组同一函数的 decline-twice、decline-then-accept 保留。
- [x] 与本次开始时的 744 个节点对比，仅减少上述 4 条，没有意外新增或删除；当前共 740 条、496 个测试函数。
- [x] 合并之前已授权的用例精简，清除 37 个残留等级索引；代码等级表与 740 个当前节点完全一致：P0=304、P1=266、P2=170。README、模块台账、依赖审计和离线边界文档同步。
- [x] 全量 tests/tools：364 passed，85.59 秒；仅已有 websockets.legacy 弃用提示。业务 collect-only 成功，未运行设备端业务回归。
- [x] speckit check：Android/iOS 依赖规范检查通过；git diff --check 通过。
- 用户本次明确授权将所有当前修改一起 commit，包含此前好友前置隔离、语音/离线好友断言、Allure 等级与步骤输出、用例精简及相关文档；不推送远端。

## 失败用例自动重试增量任务（2026-09-15）

需求与设计以 requirements.md / design.md 中同名「失败用例自动重试增量」章节为准；本节为该增量唯一状态来源，不另建实现计划。未经用户明确要求不提交、不推送。

### RT-1：失败清单收集器

Files: Create `native-auto-test/skills/im-flutter-run/scripts/emit_failures.py`

- [x] 读取一个或多个 lane 结果 JSON（schema_version 1），去重输出 failed/error nodeid 到 `--out`；缺失/非法输入跳过不报错。（T2/T3/T8）

### RT-2：run.sh 重试编排与失败捕获

Files: Edit `native-auto-test/skills/im-flutter-run/scripts/run.sh`

- [x] 新增 `--retries N` 解析与 usage 说明；校验非负整数，`0`/未传等价关闭。（T1/T11）
- [x] 新增 `run_with_retries`：循环前一次性获取 APK 并复用；清空一次 `out/allure-results`；循环内部运行（`--retries 0 --no-report --no-open`、`IM_FLUTTER_RETRY_CHILD=1`、`IM_FLUTTER_FAILURES_OUT`）；读取失败清单驱动收敛。（T2–T4/T6/T7）
- [x] 抽出 `emit_report`；全部重试结束后统一出报告一次并按 `OPEN_REPORT` 决定是否打开。（T5）
- [x] 多 lane：`rm -rf out/allure-results` 与报告生成受 `NO_REPORT` 守卫；`IM_FLUTTER_FAILURES_OUT` 存在时汇总各 lane 结果调用 `emit_failures.py`。（T5/T7）
- [x] 单 lane：`IM_FLUTTER_FAILURES_OUT` 存在时加载 `-p scripts.pytest_lane` + `IM_FLUTTER_LANE_RESULT` 捕获逐 nodeid 结果并调用 `emit_failures.py`；不设置 nodeid 筛选。（T2/T3）
- [x] 编排层打印分次失败汇总与最终失败列表；基础设施失败停止重试仍出报告并非零退出。（T8/T9）
- [x] Bash 3.2 兼容：不使用 mapfile，沿用空数组惯用法。

### RT-3：文档

Files: Edit `native-auto-test/skills/im-flutter-run/SKILL.md`

- [x] 增补 `--retries` 用法、"报告以最后一次执行为准" 语义、opt-in 且不改默认流程的说明。（T5/T11）

### RT-4：离线回归与验证

Files: Edit `native-auto-test/tests/tools/test_im_flutter_run_apk.py`

- [x] 新增单/多 lane 重试收敛、上限仍失败、默认行为不变、APK 一次性测试。（T10）
- [x] 运行新增与既有 runner 测试；执行 `bash -n run.sh`。

### RT-5：改为就地复用环境重试（按用户反馈，2026-09-15）

用户反馈：初版重试每轮都 re-invoke run.sh，会重启模拟器/重装 APK/重启桥接，浪费时间。改为在第一次已准备好的环境上就地重试（仅重跑 pytest），需求见 requirements 的 T12/T13，设计见 design 同名章节的修订说明。

- [x] 移除最外层 `run_with_retries` 编排与 `emit_failures.py`；新增 `build_make_args`，保留 `emit_report`。
- [x] 把重试下沉到单 lane 执行器的 pytest 步骤：`RETRIES>0` 时在 boot/install/bridge 之后就地循环重跑失败集合（新 pytest 进程，不重启/不重装/不重启桥接）；`RETRIES=0` 保持原单次调用不变。
- [x] 新增 `scripts/retry_merge.py`：合并每次 attempt 结果（后写覆盖，得每用例最后一次执行）并导出仍失败 nodeid；累计结果写回 `laneN.result.json` 供 `summarize_lanes` 读取。
- [x] 多 lane 编排器把 `--retries N` 透传给各 lane；各 lane 就地重试自己的分片；结束后统一 `emit_report` 一次。
- [x] 修复 Bash 3.2 下 `$fail_summary` 后紧跟中文全角分号被并入变量名导致的 `unbound variable`（改用 `${fail_summary}` 定界）。
- [x] 重写离线回归：多 lane 收敛/达上限、单 lane 收敛、默认无重试；断言每模拟器仅一次 install（证明环境复用）、报告仅一份、APK 仅获取一次。
- [x] 验证：`bash -n` 通过；`native-auto-test/.venv/bin/python -m pytest --noconftest -q tests/tools/test_im_flutter_run_apk.py` 全绿（51 passed，约 66s，仅既有 websockets.legacy 弃用告警）。文档 SKILL.md / README 同步为「就地复用环境」。未跑真实设备业务用例、未提交。

### RT-6：报告标记「重跑通过」用例为 flaky（按用户反馈，2026-09-15）

用户反馈：希望在最终 Allure 报告中体现哪些用例是重跑后才通过的，便于定位不稳定业务。需求见 requirements T14，设计见 design 同名章节。

- [x] 新增 `scripts/mark_flaky.py`：按 historyId 分组，对「较早失败/broken、最后一次通过」的用例标记最后一次结果 `statusDetails.flaky=true` + `reran-passed` 标签 + 说明；单次通过与始终失败不改。
- [x] run.sh 出报告前调用（`RETRIES>0`）：多 lane 在 `emit_report` 前统一调用，单 lane 在自身报告前调用；lane 子进程（`--no-report`）不调用，由编排器集中处理。
- [x] 新增 `mark_flaky.py` 单元测试（构造 allure-results 断言仅重跑通过用例被标记）；加入假工具树 copy 列表。
- [x] 验证：`bash -n` 通过；`pytest --noconftest -q tests/tools/test_im_flutter_run_apk.py` 全绿（52 passed，约 65s）。SKILL.md / README 同步说明 flaky 标记与 `reran-passed` 标签。未跑真实设备业务用例、未提交。
