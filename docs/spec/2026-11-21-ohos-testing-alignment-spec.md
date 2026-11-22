# ohos 测试框架对齐（自 4.x 迁移）规格

日期：2026-11-21
目标分支：`ohos`（鸿蒙长期线，worktree：`.worktree/ohos`）
源基线：`4.x`（worktree：`.worktree/4.x`）

## 1. 背景与目标

### 1.1 设计原则：三类测试分工

| 类型 | 载体 | 侧重点 | 运行时机 |
|---|---|---|---|
| CI 回归 | integration_test 套件 + `nightly_local.harmony.sh`/`ohos_local.sh` | 已确认行为的防回归，贴近 CI 环境 | 每日 + 本地随手跑 |
| single 平板 | `make auto-report` + JSON 脚本 | 版本平板验收：API 名、参数、错误码逐条过 | 平板开发期 + 发布前 |
| multi 平板 | `scripts/multi.sh` + YAML 场景 | 多端交互语义（双设备账号互验） | 平板开发期 + 发布前 |

三类测试用例可以重叠，但侧重点不同；由此推论：各类型保持**独立入口**，不合并进统一 runner（用户决策 2026-11-22，与 4.x/5.1.0 惯例一致）。

### 1.2 背景与目标

ohos 线的集成套件（integration_test）已经演进为新架构风格（modules + support 结构，
与 4.x 套件入口同名），但三类测试中的另外两类完全缺失：

- 多设备测试（`testing/multi/` + 控制端 `example/lib/agent/`）——ohos 无任何资产
- 单设备 API 脚本测试（`testing/single/auto_report.dart` + API 脚本）——ohos 无任何资产

目标：

1. 将 4.x 的三类测试框架同构到 ohos 线，使鸿蒙具备与 4.x/5.x 对齐的测试能力
2. REST support 层与 4.x 同构（词汇统一），使跨线 case diff 反映真实用例差异
3. 保留 ohos 专有资产，并为"ohos 好的实践反哺 4.x/5.x"留好通道（反哺走独立确认流，不 cross-merge）

## 2. 范围

### 2.1 做

| 项 | 内容 |
|---|---|
| REST 同构 | 以 4.x `rest_fixture.dart` 为基底吸收 ohos `CiRestClient` 写侧方法，两线文件逐字节一致 |
| auto step 引擎 | 移植 `script_values.dart` / `step_dependencies.dart` / `step_expectation.dart`，合并 `auto_mode.dart`（保留 ohos 内联 JSON 特性） |
| agent 控制端 | 覆盖移植 `example/lib/agent/`，`main.dart` 三模式互斥接线 |
| multi 场景 | 覆盖 4.x `testing/multi/` 12 个场景，先出 29 个 API × gap 台账核对表，不可跑场景标 skip + 记录；含 IMTO ohos 平台支持与 `scripts/multi.sh` 封装 |
| single 脚本 | 移植 `auto_report.dart`，新建 `script_1.16.0_apis_positive.json` / `script_1.16.0_apis_negative.json` |
| runner/文档 | harmony 本地 runner 接 multi/single 入口；更新 ohos AGENTS.md 测试一节 |

### 2.2 不做（本次）

- case 文件全量对齐：`client_sync_cases`、各 negative 增量、`chat_room_cases` 等留作后续独立任务
- GitHub CI 接入：runner 无鸿蒙环境，本次只保证本地可跑 + 未来可接入
- 4.x `testing/single/cases/` 旧脚本（4.22/4.24/4.25/5.0.0/5.1.0）迁移——它们是其他线 API 面，与 ohos 无关
- ohos wrapper 本体（`im_flutter_sdk_ohos/`）不做任何改动

### 2.3 ohos 专有资产冻结清单（迁移中绝不触碰）

- `event_callback_cases.dart`（FL-EVENT-201..209）、`event_registration_cases.dart`（FL-EVENT-210 相关）
- `push_cases.dart`、`room_cases.dart`、`no_login_presence_test.dart`、`single_account_local_test.dart`
- `logged_in_special_test.dart` 套件入口
- gap 台账 `docs/porting/ohos-4.25.0/`
- auto 引擎内联 JSON 特性（`API_SCRIPT` 接受内联 JSON）
- REST 写侧方法（`createUser`/`deleteUser`/`publishPresence`/群成员/聊天室管理操作）
- harmony 本地 runner（`tool/ci/*.harmony.sh`）

## 3. 方案

### 3.1 REST support 层同构

- 规范文件：`im_flutter_sdk/example/integration_test/support/rest_fixture.dart`（+ 依赖 `example/tool/rest_resource_client.dart`），方法面 = 4.x 读侧校验方法 + ohos 写侧生命周期方法；2026-11-22 T1 实测修正：ohos `env.dart`/`session.dart`/`login.dart`/`ci_test.dart` 是 ohos 演化的助手层（session.dart 被 16+ 文件使用、ci_test.dart 承载 ohos 专属的 expectCiSuccessOr505/skipCiServerDelay），**保留不删**，仅删除 `support/rest.dart`
- ohos 侧调用点适配（8 个文件，非纯机械）：方法映射 fetchContactIds→contactIds、removeContact→removeContacts（4.x 双侧幂等）、addContacts(list)→addContacts(单 peer)、sendUserTextMessage→sendTextMessage、fetchChatRoomDetail→chatRoomDetail、fetchChatRoomMembers/Admins/Announcement→chatRoomMembers/Admins/Announcement；createChatRoom 需显式补 required 的 description、createGroup 需显式补 isPublic:true（ohos 旧默认 public）、close() 调用删除（新 fixture 无 close）；fixture 构造沿用 env.dart 的 ciRestApi/ciAppKey/ciAppToken（不走 dart-defines 工厂，保留 ohos env 驱动流程）
- 4.x 侧：纯加法（新增 ohos 写侧方法，无调用方），已落 4.x 并走 4 线工作流（4.x → main，2026-11-22）
- 落地后两线 `diff rest_fixture.dart` 与 `diff rest_resource_client.dart` 必须为空，作为同构验收

### 3.2 auto step 引擎

- 新增 `example/lib/auto/script_values.dart`、`step_dependencies.dart`、`step_expectation.dart`（自 4.x 覆盖）
- `auto_mode.dart` 合并 4.x 版本（step 失败跳过 + 依赖 producers 逻辑），保留 ohos 内联 JSON 支持
- multi 的设备侧即该引擎执行 per-agent json 脚本（`"steps": [{id, api, params}]`）

### 3.3 agent 控制端

- 覆盖 `example/lib/agent/`（agent_home_page / agent_mode / command_service / control_server / evidence_store）
- `main.dart` 增加三模式互斥（agent / auto / 普通）接线
- agent 为平台无关 Dart（控制端跑宿主机，app 主动连出）；鸿蒙侧仅要求 fvm `custom_ohos` 构建

### 3.4 multi 场景

- 前置：产出 API 核对表——12 个场景用到的 29 个 API × ohos registry × gap 台账，逐个判定可跑/skip；`ChatManager.modifyMessage`（消息编辑）为首要疑点
- 覆盖 `testing/multi/`（yaml + json + README），场景文件按 ohos 版本命名为 `1.16.0-multi-*`（命名沿用"线版本号-multi-语义"惯例）
- 覆盖 `scripts/multi.sh` 薄封装与 `testing/target-flutter.yaml`（按 IMTO 解析约定）
- **IMTO（im-test-orchestrator，外部仓）增加 ohos 平台支持**：`DevicePlatform.ohos` + hdc 设备发现/安装/启动 + 经项目 `.fvm/flutter_sdk/bin/flutter`（custom_ohos）构建 hap + hilog 日志采集；构建命令必须支持 `FLUTTER_BIN` 覆盖，禁止裸 `flutter`（见 5.3）
- 账号：ohos 前置脚本 REST `createUser` 建临时对端账号（跑完 `deleteUser` 清理），client credentials 经 `env_tool` 换双账号 token，生成 IMTO 所需 `accounts-input.json`；不新增长期凭证
- 不可跑场景：yaml 中标注 skip 并注明 gap 台账依据，不删除
- 验证：本地双鸿蒙设备（模拟器 `127.0.0.1:5555` + 第二设备/真机）实跑通过；**设备不可用则不跑、记录当时环境与现象，后续排查，不做降级冒烟**（用户决策 2026-11-21）

### 3.5 single API 脚本

- 覆盖 `testing/single/auto_report.dart`（与 multi 共用 step 引擎，只移植一次）
- 新建 `script_1.16.0_apis_positive.json` / `script_1.16.0_apis_negative.json`：以 ohos 当前公开 API 面（对齐 4.25.0、剔除 gap 台账中 chatsdk 1.15.0 不支持项）为清单编写；native 1.16.0 落地后刷新脚本内容（升级本身不属于本任务）
- 验证：单鸿蒙设备实跑通过

### 3.6 runner 与文档

- `tool/ci/nightly_local.harmony.sh` **不接** multi/single：与 4.x/5.1.0 惯例一致，三类测试保持独立入口——CI 回归（nightly_local.harmony.sh → ohos_local.sh）、single（`make auto-report`）、multi（`scripts/multi.sh`）（用户决策 2026-11-22，见设计原则 1.1）
- ohos AGENTS.md"鸿蒙构建与验证入口"表补充 multi/single 用法

### 3.7 输出目录结构（用户决策 2026-11-22）

三类测试输出严格落在带时间戳的目录下，与 4.x/5.x 既有设计一致（`testing/single/README.md`、`tool/ci/nightly_local.sh`），一次运行一个时间戳目录、原始日志全量保留、互不覆盖：

| 类型 | 位置 |
|---|---|
| CI 回归 | `artifacts/ci/<时间戳>/harmony/<套件>/flutter.log`（控制台输出在同目录 `runner.log`） |
| single | `artifacts/single/<时间戳>/<平台>/`（run.json、steps.json、events.jsonl、crash.log、device.log 等，由 auto_report 产出） |
| multi | `artifacts/multi/<时间戳>/`（device-*.log 等） |

该结构由脚本执行保证，不靠文档约束；历史扁平日志（`artifacts/ohos-<套件>.log`）为旧布局证据，不再产生。

## 4. 验收

- [ ] `diff 4.x/.../support/rest_fixture.dart ohos/.../support/rest_fixture.dart` 为空；ohos 集成套件本地全量通过
- [ ] ohos 例 app 编译通过（fvm custom_ohos），auto step 脚本可跑
- [ ] agent 模式启动，控制端可对单设备下发 step 脚本
- [ ] 12 个 multi 场景中可跑场景双设备实跑通过；skip 场景有台账依据记录
- [ ] 1.16.0 正反两个 single 脚本实跑通过
- [ ] 质量门通过（官方 Flutter 3.47.0 `dart analyze`/`dart format`；跑完后按 AGENTS.md 要求 `fvm flutter pub get` 恢复鸿蒙构建环境）
- [ ] ohos AGENTS.md 更新

## 5. 分支与提交

- 所有 ohos 改动直接提交 `ohos` 分支（铁律 5：测试框架变更落长期线；ohos 线无版本分支在途）
- 4.x 侧仅 REST 加法一次提交，走 4 线工作流（4.x → main，含 flutter2_stable 镜像）
- ohos 与 4.x 之间禁止 merge，同构靠"两边各自提交等价内容 + diff 校验"
- 每个任务完成即提交并推送双远端（asterisk + easemob），dailylog 随提交（ohos 线格式 `dailylog/YYYY-MM-DD.md`）
- spec/plan 文档首提交先行，进度持久化见 plan 文档"进度记录"一节
- IMTO 改动提交其 `main` 并 push `origin`（该仓无分支铁律）

### 5.3 Flutter 工具链纪律（本机环境陷阱）

- `.zshrc` 将全局 `flutter` 指向 `custom_official`（3.47.0）；**鸿蒙构建/测试一律使用项目 `.fvm/flutter_sdk/bin/flutter`（fvm `custom_ohos`）或显式 `FLUTTER_BIN`**，任何脚本禁止裸 `flutter`
- 质量门（dart analyze / dart format）用官方 3.47.0；门禁后、鸿蒙构建前必须 `fvm flutter pub get`（官方 Flutter 会重写 `.flutter-plugins-dependencies` 导致 hvigor 构建失败，见 ohos AGENTS.md）
- IMTO 的 ohos 平台实现同样遵守 `FLUTTER_BIN` 覆盖约定（与 ohos 仓 `tool/ci/*.harmony.sh` 一致）

## 6. 风险与对策

| 风险 | 对策 |
|---|---|
| `modifyMessage` 等 API 在 chatsdk 1.15.0 缺失 | 核对表前置，场景标 skip + gap 台账记录，不硬适配 |
| 服务端传播时序抽签（已知台账问题）导致 multi 用例偶发 | 沿用 4.x waitForCi 轮询模式；偶发失败记录进现有台账，不用例降级 |
| 官方 Flutter 与 fvm custom_ohos 冲突（`.flutter-plugins-dependencies` 被重写） | 质量门禁后、鸿蒙构建前必须 `fvm flutter pub get`（AGENTS.md 已有约定，照做） |
| 双鸿蒙设备环境不可用 | multi 不跑，记录当时环境与现象，后续排查原因；**不做降级冒烟**（用户决策 2026-11-21），验收以双设备实跑为准 |

## 7. 反哺通道（非本次范围）

ohos 侧以下实践后续可作为反哺候选，反哺须在目标线单独走确认流，禁止 cross-merge：
FL-EVENT 事件用例、`createUser/deleteUser` 自助建号、gap 台账纪律、零凭证套件（no_login_presence / single_account_local）。
