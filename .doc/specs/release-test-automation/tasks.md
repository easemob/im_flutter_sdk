# release APK 测试自动化实施计划

> 原始 Task 1–6 和多设备 Backlog 保留历史记录，其中部分描述已落后于当前代码，不代表本次待办。本次仅以文末「Release APK 缓存增量任务」跟踪状态；需求和设计以对应文档的缓存增量章节为准。

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
