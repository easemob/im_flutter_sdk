# Example 测试脚本与工具体系规格

- 日期：2026-11-04 首版；2026-11-05 按解释器定论重写，围绕测试运行生命周期组织。
- 状态：已确认，第一阶段开发中；尚未进行本轮设备验证。
- 工作对象：`im_flutter_sdk/.worktree/5.0.0`，分支 `5.0.0`。
- 统一入口：[testing/README.md](../../testing/README.md)；实施任务见[实施计划](../plan/2026-11-04-example-testing-plan.md)。
- 配套深度设计（本文只做索引与边界约定，不复制其内容）：
  - [HTTP 执行控制协议](../../testing/spec/2026-11-04-phase-control.md) — 设备 agent 的会话、命令与事件接口
  - [控制流解释器规格](2026-11-05-flow-interpreter-spec.md) — 多设备 YAML 流程语言与宿主运行器 `tool/flow_runner`
  - [覆盖映射](../../testing/spec/2026-11-04-coverage.md) — 旧 30 步脚本到新用例的去向
- 路径约定：仓库内相对路径均以 `5.0.0` 工作树根目录为基准。

## 1. 目标与范围

在真实设备（模拟器／真机）上运行 example，完成 SDK 的真实行为验证——不是单元测试。覆盖单设备正向／逆向用例与多设备交互用例；example 同时保持人工操作能力，供用户亲自抽验。

多设备编排由宿主端控制流解释器承担（已定论）：执行全部为固定代码，AI 不参与执行过程。本次不改造 `flutter2_stable`，不安排全仓库测试框架迁移；新旧脚本格式不兼容，旧内容清理在第三阶段另行决策。

与平版的交接：`platform-sdk-porting-v2` 负责平版实现与编译验证；本体系读取 `docs/porting/<版本>/` 的 API diff、契约与验证记录，建立"变更项 → 用例 → 实际结果"映射。未确定语义单列，不猜预期。

## 2. 总体架构与复用原则

```text
宿主机（macOS）
├── 数据工具 testing/tools/data/         账号／Token／群的准备与清理
├── 设备管理（复用 auto_report 能力）    模拟器启动、app 构建安装、端口转发
├── 单设备入口 make auto-report          flutter run + API_SCRIPT + 报告
└── 多设备运行器 tool/flow_runner/       YAML 解释执行，HTTP 直连各设备 agent
         ↓ HTTP（每台设备一条连接，无中间代理）
┌── 设备 1：example（agent HTTP 服务）──┐
└── 设备 2：example（agent HTTP 服务）──┘
```

| 主题 | 权威文档 |
|---|---|
| 生命周期、目录、脚本规范、失败铁律 | 本文 |
| 设备 agent HTTP 接口细节 | phase-control |
| YAML 流程语言与解释器语义 | flow-interpreter-spec |
| 旧步骤覆盖去向 | coverage |
| 实施任务清单与进度 | plan ＋ testing/README |

**复用与修改边界**：现有工具是不够完善，而非不可用。复用优先，但遵守以下边界（2026-11-05 确认）：

1. **不修改 `example/` 与 `tool/` 下的现有文件**——它们同时服务示例应用与 CI，行为变更的副作用不可控。需要改造现有工具的行为时，将其**复制到 `testing/` 体系内**修改演进；仅需调用则用薄入口包装，无需复制。
2. 对 example 的必要扩展（registry 补 API 入口、设备 agent 服务）以**新增文件／纯新增**为主，不改动既有逻辑。
3. 当前过渡期的重复与冗余是接受的阶段；旧入口的移除统一等测试体系完全成熟后再做，不提前清理。

| 现有能力 | 位置 | 本次用途 |
|---|---|---|
| 配置／Token 链路 | `env_tool.dart` → `testing/tools/data/environment.dart` | 环境与运行时数据，薄入口复用原实现 |
| REST 资源操作 | `rest_resource_client.dart` | 群创建清理；扩充走 testing 侧包装 |
| 设备发现、iOS 启动等待、Android 安装确保 | `tool/auto_report.dart` | **复制**设备能力到 testing 体系后扩展批量场景，不改原文件 |
| APITEST 日志分片重组、报告、双端对比 | `tool/auto_report.dart` | 旧入口原样保留；新报告链路在 testing 侧实现 |
| API 注册、监听、顺序执行与断言 | `example/lib/registry`、`lib/auto`、`lib/listeners.dart` | agent 与单设备共用同一调用链；必要扩展以新增为主 |

## 3. 测试运行生命周期

一次完整测试运行按以下六步闭环组织。**每个阶段在 `testing/scripts/` 下有一个可执行脚本入口**（bash 或 dart），把该阶段的准备工作做完——工具脚本集中于该目录，不放数据文件：

| 阶段 | 规划脚本入口（testing/scripts/） | 职责 |
|---|---|---|
| 数据准备 | `prepare_data` | 配置、Token、账号、临时群 |
| 设备准备 | `setup_devices` | 批量起模拟器、构建安装 app、端口转发 |
| 单设备执行 | `run_single` | 直跑单设备用例 + 报告 |
| 多设备执行 | `run_flow` | 调用 flow_runner 执行 YAML 流程 |
| 报告汇总 | `collect_report` | 归档、格式化输出、总结 |
| 清理 | `cleanup` | 资源、临时目录、转发与进程 |

Makefile 保留为快捷入口转发到上述脚本。各阶段现状与设计如下。

### 3.1 环境与数据准备

- `make config`：生成 `testing/config/environment.local.json`（首次自动从旧 example 配置导入，不覆盖），同时生成 `env.dart` 占位。
- `make env-gettoken [RUN_ID=x]`：换取各账号 User Token，写 `example/lib/env.dart`；带 `RUN_ID` 时额外输出隔离的运行时环境 `testing/tmp/<run-id>/main/environment.json`（含 Token，不含 clientSecret）。
- `dart run testing/tools/data/resources.dart prepare-group <run-id>`：创建临时群并记录归属日志，供群场景引用。
- 账号创建、重置等 REST 侧能力按场景需要扩充 `rest_resource_client`，不提前建设。

### 3.2 设备准备

- **模拟器启动管理在解释器外部**（已定论）：由外部脚本／Make 目标负责起模拟器、构建安装 app、建立端口转发；`flow_runner` 只连接已就绪的 agent endpoint。
- **不建通用模拟器操作框架**：`simctl`／`adb` 均为单行命令，直接 `Process.run` 加薄封装（启动、等待就绪、端口转发、清理各一个小函数，含超时与明确报错），保持与手动排查命令一致。结构性日志经 HTTP events 接口读取；模拟器原生日志（logcat／系统日志）仅作为崩溃排查的补充证据，复用现有崩溃采集。
- 复用方式：**复制** `auto_report.dart` 的设备能力（iOS 已启动模拟器枚举 `simctl list`、`bootstatus` 等待、Android 设备指定与 app 安装确保）到 `testing/scripts/setup_devices`，原文件不修改。
- 多设备需补齐：批量启动指定数量模拟器、Android `adb forward` 与 iOS 直连的端口分配与清理、设备角色绑定表（哪个角色用哪台设备）。
- 构建一次、分发安装到各设备，避免并行构建同一产物互相覆盖。

### 3.3 单设备执行

保留两条路径，**均长期有效**：

1. **直跑路径（现有，保留不移除）**：example 启动入参携带脚本 `flutter run --dart-define=API_SCRIPT=<json>`，AutoMode 顺序执行并断言；`make auto-report` 在外包装设备准备与报告。无 HTTP 依赖，最简路径。
2. **会话路径（新）**：经设备 agent HTTP 提交命令，与多设备共用协议；支持长会话与事件等待。

单设备断言已增强：`checks` 数据断言（不只看 success）、`failureKind` 分类（sdk/timeout/tool）、依赖失败跳过 `skipOnFailedDeps`。

### 3.4 多设备执行

- 流程脚本为 YAML（`testing/flows/<name>.yaml`），设备命令脚本为 JSON（`testing/flows/scripts/<actor>_device.json`）；YAML 描述控制流（顺序／循环／分支／并行），JSON 是不透明叶子。
- `flow_runner`（纯 Dart CLI）解释执行：每流程绑定 agent，命令经 HTTP 派发，事件按游标匹配。
- 关键边界（细节见两份配套 spec）：结果信封统一 `{success, status, data, error}`；事件先到后等不丢失；超时后迟到结果丢弃但保留证据；一台设备同一时刻仅一个在途命令；命令带 sessionId/runId/commandId，同 ID 同内容不重复执行。
- 设备启动失败、agent 不可达属于环境问题，报告为阻塞而非用例失败。

### 3.5 报告与总结

- 产物写入 `testing/reports/<run-id>/`：运行元数据、逐步骤结果（含 envelope 摘要与证据 seq 区间）、事件存档、汇总统计；不依赖 `tmp/`，凭据不入报告。
- 判定状态：`passed / failed / blocked / skipped / timeout`。所有必需断言通过才算场景通过；无法运行、证据缺失、存在必需阻塞项时不得报告通过。
- 双端对比（`make auto-compare`）保留，用于 Android/iOS 同路径结果差异检查。

### 3.6 清理

三类清理各自独立记录，清理失败不覆盖原始测试结果：

| 类型 | 工具／位置 | 规则 |
|---|---|---|
| 服务端资源 | `resources.dart cleanup-group` | 只清理本次创建且归属明确的资源；状态未知时停止并要求检查 |
| 临时目录 | `testing/tmp/<run-id>/` | 证据归档到 reports 后才可删除 |
| 本地进程与转发 | 端口转发、`flutter run` 进程、按需关闭模拟器 | 运行结束即释放；模拟器是否关闭由运行参数决定 |

## 4. 目录与产物

```text
testing/
├── README.md                    # 统一入口与当前进度
├── spec/                        # 格式、协议与覆盖说明
├── scripts/                     # 各阶段工具脚本（bash/dart）；只放脚本，不放数据
│   ├── prepare_data             # 数据准备入口
│   ├── setup_devices            # 设备准备入口（模拟器/构建/安装/转发）
│   ├── run_single               # 单设备执行入口
│   ├── run_flow                 # 多设备执行入口（调 flow_runner）
│   ├── collect_report           # 报告归档与汇总
│   ├── cleanup                  # 清理入口
│   └── 5.0.0/
│       └── single/              # 单设备 JSON 用例
├── tools/                       # 被 scripts 调用的 Dart 实现
│   ├── data/                    # 数据准备实现（现有，过渡期保留）
│   ├── logs/                    # 日志读取与事件定位
│   ├── runner/                  # 执行支持与报告
│   └── validate/                # 格式、引用、能力检查
├── flows/                       # 多设备用例（注意 flows/scripts/ 指各角色设备脚本）
│   ├── <name>.yaml              # 流程（控制流）
│   └── scripts/
│       └── <name>-<actor>.json  # 各角色设备命令脚本
├── config/
│   ├── environment.example.json
│   └── environment.local.json   # 本地配置，Git 忽略
├── tmp/<run-id>/                # Git 忽略；main/、<actor>/ 等
└── reports/<run-id>/            # Git 忽略；最终结果及必要证据
```

- skill 目录第四阶段按已跑通流程再建，本轮不创建。
- 依赖 Flutter 和 App 生命周期的执行、监听代码保留在 example 内；宿主机工具集中于 `testing/` 与 `tool/`。Makefile 保留快捷入口，路径随实施更新。
- `tmp/` 接收运行中的脚本副本、中间结果与临时日志，运行中不得清理；本地长期配置不随临时目录清理。

## 5. 脚本规范与命名

- 单设备：`testing/scripts/5.0.0/single/<version>-single-<feature>-<positive|negative>.json`
- 多设备：流程 `testing/flows/<version>-multi-<feature>-<positive|negative>.yaml`，设备脚本同名加角色后缀 `-<actor>.json`。
- `feature` 描述可辨认的功能场景；版本表示用例引入或行为变更版本，后续版本复用未变化用例，不整套复制。

每个用例必须能表达：

| 信息 | 要求 |
|---|---|
| 身份与目的 | 唯一用例标识、版本、功能、正向／逆向、单／多设备 |
| 前置条件 | 账号关系、设备角色、服务能力、初始状态、所需资源及准备方法 |
| 操作 | 唯一步骤标识、SDK API 与参数、顺序和依赖 |
| 引用与输出 | 配置与前序结果用明确引用，不写死运行产生的 ID |
| 预期 | 返回值、错误码、数据状态、事件及顺序约束，写明预期依据 |
| 等待与失败 | 超时、依赖失败处理；不以固定睡眠代替就绪证据 |
| 清理 | 资源归属、结束／失败时的清理动作 |

执行前拒绝未知字段、重复 ID、未定义引用与不合法角色绑定；运行时无法解析的引用明确失败，不悄悄替换为空值。正向用例除调用成功外必须检查可观察业务结果（如未读数归零、消息内容更新）；逆向用例构造可控前置并检查约定错误，超时、脚本错误、未注册 API 或崩溃不能作为"预期失败"通过。

## 6. 第一阶段用例基线

单设备以现有 [`script_500_apis_positive.json`](../../im_flutter_sdk/example/scripts/script_500_apis_positive.json) 的 20 步和 [`script_500_apis_negative.json`](../../im_flutter_sdk/example/scripts/script_500_apis_negative.json) 的 10 步为内容基线，按功能组织新文件，保留覆盖映射（见 coverage）：

- 正向保留未读数查询／清理、消息编辑含 attributes、群配置创建／更新、回执、本地及服务端查询、混合有效／无效消息批次、设备管理和 Token 更新，并补业务结果断言。
- 逆向保留非法群成员／缺失群 600、缺失修改消息 500、空会话及无有效消息回执批次 110、设备管理无效 Token 303、空 Token 更新 104。错误码以当前契约实际执行核对为准。
- `fetchGroupMessageReadReceipts` 缺失消息的已知 Android native 崩溃继续显式屏蔽并报告。

多设备选取三个典型场景（内容依据 [5.0.0 契约](../porting/5.0.0/02-contract.md)、[验证记录](../porting/5.0.0/04-verification.md)）：

| 场景 | 设备／账号 | 主要操作与断言 |
|---|---|---|
| `direct-read-receipt` | 两设备、两账号 | A 发单聊消息，B 确认接收后发已读回执；A 检查 `onMessageReadReceipts` 中本次消息与会话 |
| `group-read-receipt` | 两设备、两账号、同一临时群 | A 发需回执群消息，B 接收并发回执；A 检查回调、本地汇总和服务端详情；尊重 `totalCount` 平台差异 |
| `data-sync` | 两设备、同账号 | A 形成可同步数据，B 建立监听后登录；检查同步事件及实际数据；同步 options mask 须显式设置 |

三个场景先实现正向闭环，逆向按已核实契约补充，不为数量强造。

## 7. 失败处理铁律

> 不得为了让测试通过而修改预期、放宽断言、删除检查或跳过失败用例。只有证据证明用例违反已确认契约或前置条件时才可修正用例，并保留修改依据与原始失败证据。

1. 失败先保存输入、代码与脚本版本、API 返回、事件、断言与设备状态，建立逐项失败清单。
2. 暂停受影响的执行链；无依赖且状态未污染的用例继续。状态是否污染不明确时先暂停相关设备或共享资源上的执行。
3. 逐项受控复验：核实前置条件，关联原始执行与复验记录；不无限重试，不用随后一次成功抹去首次失败。
4. 归因区分用例／SDK／环境／工具／未确定；未确定时记录证据缺口，不强行为结项归因。
5. SDK 缺陷保持正确用例与原定断言，生成可复现记录，修复另行决定；已确认的历史屏蔽项保留为显式例外，不推广为自动跳过规则。
6. 工具验收与 SDK 测试结果分开：执行完成可包含真实 SDK 失败；用例通过必须满足原定断言。工具故障、证据不足是工具验收缺口，真实 SDK 缺陷可带着完整证据交付人工抽验。

## 8. 人工模式

- 未启用自动模式时 example 保持人工操作入口：初始化、登录／退出、搜索 API、编辑参数、调用并查看返回与事件。自动能力的增加不得使人工操作依赖运行器。
- 人工与自动模式使用相同 SDK 调用与结果转换，验证同一实现。本次纳入脚本的 API 同样可从人工入口调用；不承诺 SDK 全量 API 的人工覆盖。
- 删除自动运行的临时目录后，人工模式仍能启动使用。

## 9. 阶段划分

1. **第一阶段（当前）**：实现完整闭环并实际执行——工具、脚本规范、单设备与多设备用例、agent 与运行器；Android／iOS 分别验证，完成三场景实际运行，报告可追溯。
2. **第二阶段**：用户亲自人工抽验，以用户实际反馈为依据。
3. **第三阶段（待议）**：旧内容清理范围另行讨论，不提前删除 CI 工作流或共享工具。
4. **第四阶段**：按已跑通流程沉淀三个 skill，各用一个代表性场景复跑验证（不创建空 SKILL.md）：

| skill | 覆盖流程 |
|---|---|
| 用例生成 | 读版本契约与覆盖映射 → 设计正向／逆向场景（单/多设备）→ 生成 YAML 流程与设备脚本 → 校验 |
| 用例执行 | 数据准备 → 设备准备 → 运行 flow_runner／单设备直跑 → 归档报告 → 清理 |
| 问题排查 | 失败证据保存 → 暂停受影响链 → 逐项复验与归因（用例／SDK／环境／工具）→ 结论与记录 |

验收要点（第一阶段）：监听就绪后才触发、事件匹配、跨设备输出传递、超时／失败阻塞均经实际验证；非法脚本在 SDK 操作前被拒绝；失败仅阻塞受影响链；临时产物被 Git 忽略且删除不破坏报告与人工配置。
