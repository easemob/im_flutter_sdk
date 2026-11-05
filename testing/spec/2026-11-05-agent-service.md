# 设备 Agent HTTP 服务设计（agent-service）

- 日期：2026-11-05；同日按协议 v2 重写（命令自带 step 内容、判定归宿主、会话取消）。
- 状态：代码已实现（`example/lib/agent/` 五文件 + main.dart 路由 + `example/test/agent/` 三件单测，全部通过、analyze 清零）；设备冒烟未做。
- 依据：[HTTP 控制协议 v2](2026-11-04-phase-control.md)、[控制流解释器规格](../../docs/spec/2026-11-05-flow-interpreter-spec.md)、[测试体系规格](../../docs/spec/2026-11-04-example-testing-spec.md)。
- 工作根目录：`.worktree/5.0.0`；路径均相对此目录。
- 定位：第一阶段剩余工作的**子设计文档 1/5**。本文只覆盖"example App 内嵌 HTTP 控制服务（设备 agent）"；设备批量管理、用例迁移、多设备用例、整体验收见各自子文档。

## 1. 目标与边界

把 phase-control v2 协议落成 example 内的真实 HTTP 服务，使 `tool/flow_runner` 能驱动真实设备：握手 → 派发命令（api + 已解析 params）→ 轮询事件 → finish。

**边界**：

- agent 是**哑执行器 + 事件源**：执行 api、回实际信封、缓存事件。不接触设备脚本、不做引用解析、不做依赖判断、不做权威断言——这些全部在宿主（解释器）。
- 只做设备侧；宿主侧（端口发现、模拟器管理）属 device-management 子文档。
- 不改变人工模式与 `API_SCRIPT` 直跑路径的行为（测试体系规格 §2 修改边界）。
- 断言复用 `auto/step_expectation.dart`（仅兼容通道，命令携带 expect 时评估）；执行复用 `registry/` 调用链。
- 第一轮以前台运行为准，不承诺后台常驻、锁屏持续、局域网直连。

## 2. 依赖与前置

| 依赖 | 状态 |
|---|---|
| phase-control v2 协议 | ✅ 已定稿（演进记录见其 §10） |
| flow_runner v0.2（宿主端：查库/解析/判定） | ✅ 已实现，60 单测全绿 |
| registry / listeners / LogStore / SdkState | ✅ 现有能力，零修改复用 |
| 设备脚本 JSON 命令库格式 | 沿用现有 `{init?, login?, steps[]}` 形状，HTTP 模式按 id 引用 steps |

## 3. 总体结构

全部为 example 内**新增文件**（目录 `im_flutter_sdk/example/lib/agent/`）：

```text
lib/agent/
├── agent_mode.dart        # API_CONTROL 入口：enabled 判定、三模式互斥
├── control_server.dart    # HttpServer：路由、Bearer 鉴权、1 MiB 请求上限
├── command_service.dart   # 命令执行：去重表、单在途约束、runApi + 超时守卫
│                          #   （v2 瘦身：原 stage_runner 的查库/解析/stepData/依赖
│                          #    判断全部移除，归宿主）
├── evidence_store.dart    # 证据环形缓冲：订阅 LogStore，独立于界面 clear
└── agent_home_page.dart   # agent 模式首页：服务状态 + 日志查看入口
```

对现有文件的唯一改动：`lib/main.dart` 的 home 路由加一个分支（`AgentMode.enabled` 优先于 `AutoMode.enabled`，约 1 行）。其余现有文件零修改。

组件关系：

```text
flow_runner（宿主：查库/解析/判定） ──HTTP──▶ control_server ──▶ command_service
                                   │                              │
                                   │                              ▼
                                   │                        runApi（registry）
                                   ▼                              │
                            evidence_store ◀──订阅── LogStore ◀── listeners
```

## 4. 启用与连接

example 共支持**三种运行模式**，同一进程同一时刻只允许一种工作，不能也不建议同时启用：

| 模式 | 启用方式 | 首页 | 执行者 |
|---|---|---|---|
| 人工模式（默认） | 不设任何 `--dart-define` | InitPage | 操作者交互调用 |
| 脚本模式（现有） | `--dart-define=API_SCRIPT=<json>` | AutoHomePage | App 内 AutoMode 顺序直跑 |
| 监听交互模式（本设计） | `--dart-define=API_CONTROL=true` | AgentHomePage | 宿主 flow_runner 经 HTTP 派发 |

- 互斥规则：`API_SCRIPT` 与 `API_CONTROL` 同时设置 → 拒绝启动并页面提示（两个执行入口会互抢 SDK 状态与命令序列）；人工模式与其余两者由 dart-define 天然互斥。
- 两个自动模式均为独立首页、不提供 SDK 操作入口，"运行期间人工插手"由模式隔离消除；切换模式以重启 App 为准。
- 仅 Debug 且 `--dart-define=API_CONTROL=true` 时启动监听；默认人工启动不监听任何端口。
- 监听 `InternetAddress.loopbackIPv4`、端口 0（系统分配），绑定后取实际端口。iOS 模拟器宿主直连；Android 经 `adb forward`（转发管理在 device-management）。
- 启动时生成随机控制凭据（64 hex），**经普通 `print` 输出 `[AGENT_CONTROL] {"port":…,"token":…,"instanceId":…}`**——不走 LogStore，凭据因此不进入事件流和归档。`instanceId` 每次启动随机，宿主用于检测 App 重启。
- 所有 `/v1` 请求要求 `Authorization: Bearer <token>`；请求体上限 1 MiB，超限 413。
- **无会话绑定**（协议 v2）：一进程一次运行；`GET /v1/info` 返回 `{version, platform, instanceId, state}`。

## 5. 服务状态（会话状态机已溶解）

| state | 含义 | 允许 |
|---|---|---|
| accepting | 服务可用 | 全部接口 |
| uncertain | 命令超时/中断后底层状态未知 | 仅查询（info/命令查询/事件）；业务命令 503 |
| closed | `POST /v1/finish` 成功 | 仅 info；后续命令 410 |

- 命令去重：`Map<commandId, 记录>`；同 ID 同内容（解析后 JSON 规范比较）返回已有状态 200；同 ID 不同内容 409；在途时新命令 409。
- App 重启 = 新进程 = 新 instanceId；旧命令自然失效，宿主凭发送记录判定"未知"，不自动重放（宿主侧已有语义）。
- Q1 操作权在 v1 的化简：agent 模式独立首页（同 AutoMode 模式形态），不提供 SDK 操作入口，"自动运行期间人工插手"由模式隔离消除；人工模式（不设 API_CONTROL）完全不受影响。

## 6. 命令执行

**命令自带全部内容，agent 不查任何库**：

```json
POST /v1/commands
{"commandId": "alice-3", "api": "ChatManager.sendMessage",
 "params": {"to": "u-b", "body": {"type": 0, "content": "hi"}}, "timeoutMs": 30000}
```

1. 校验：Bearer、`api` 已在 registry 注册（未注册 422）、去重、busy、state。
2. 记录 accepted 事件 + 置单在途，**先应答 202 再执行**；查询/事件接口全程可响应。
3. `runApi(entry, params)` 带超时守卫（命令 `timeoutMs`，缺省 30s）。
4. 终态：`status: done`，附实际信封 `{success, data, error{code,message}, failureKind}` + `evidence: {fromSeq, toSeq}`（执行前后 EvidenceStore 的 seq 闭区间）。
5. 超时：`status: timeout`，服务置 **uncertain**；迟到完成作为普通事件进证据流，不覆盖首次失败。SDK 错误码写进 `error`，不映射 HTTP 状态码。
6. **兼容通道**：命令携带 `expect` 时不报错，用 `stepResultMatchesExpectation` 评估并在结果附 `expectMatched`（+ checks 明细进证据流）——仅供老调用者，宿主判定是权威。**未知字段一律容忍**（`id`、`expect`、未来扩展）。

**唯一特例 `ChatClient.init`**：成功后自动 `registerAllListeners` + `SdkState.markInitialized`（复用 AutoMode 行为）。参数形状 `{"config": <环境 map>, "overrides": {…}}`，由 App 内现有 options 组装逻辑（`chatOptionsJsonFromEnvironment` + 覆盖）合并——业务知识留在 App。登录是普通命令（`ChatClient.loginWithToken` + 已解析的 userId/token），单次尝试不自动重试；4.22 init 后抖动由宿主换 commandId 受控重试。

## 7. 事件与证据

**关键复用**：LogStore 已带全局 `seq` 且是 `ChangeNotifier`——每条结构化日志（`api.*`、监听回调）天然就是事件。EvidenceStore 以监听者身份订阅 LogStore，每次通知读取 `lines.last` 并按 seq 去重追加，**不修改 LogStore**：

- 证据独立于界面：`LogStore.clear()` 只清 UI 列表，EvidenceStore 保留全量。
- 环形缓冲：10,000 条或 32 MiB 先到为准；溢出丢弃最旧并推进 `firstAvailableSeq`，`afterSeq < firstAvailableSeq` 时 `/v1/events` 返回 410 `evidence_gap`；溢出后服务置证据降级，新业务命令 503。
- `GET /v1/events?afterSeq&limit&waitMs`：排他游标、每页 ≤200、长轮询 ≤1s；返回 `{firstAvailableSeq, lastSeq, nextAfterSeq, events: [{seq, source, payload}]}`；空页游标不变。
- `source` 为 SDK 回调方法名（2026-11-05 决策）；宿主自流程启动起持续轮询，先到事件不丢失（无 watch 接口）。

## 8. 与现有代码的边界

| 动作 | 对象 |
|---|---|
| 新增 | `lib/agent/` 五个文件；`example/test/agent/` 配套单测 |
| 最小修改 | `lib/main.dart` home 路由一行（`AgentMode.enabled` 分支） |
| 零修改 | LogStore、listeners、registry、auto/ 全部、AutoMode、页面代码 |
| 待实现时核实 | Android Debug manifest 是否需 `usesCleartextTraffic`（loopback http）；iOS ATS 对 localhost 的豁免——若需改 manifest 记录为必要扩展，向用户报告后执行 |

## 9. flow_runner 侧配套（已随 v0.2 完成）

| 项 | 状态 |
|---|---|
| 命令派发改 `{commandId, api, params, timeoutMs}`、删 bindSession、`POST /v1/finish` | ✅ `http_agent_client.dart` |
| 宿主侧引用替换层（`$inputs`/`$config`/`$step`/`$prev`，AutoMode 整串匹配语义） | ✅ `interp.dart` |
| expect 判定器（自 example 移植，语义保持同步） | ✅ `lib/expect.dart` |
| parser 加载设备脚本为命令库（stepsById）+ env 文件（`$config`/`$agents` 来源）+ expect 静态校验 | ✅ `parser.dart` |
| `$step` 依赖失败跳过与流程变量跳过统一（skipOnFailedDeps 双来源） | ✅ |
| 60 个单测全绿、analyze 零问题 | ✅ |

## 10. 测试与验收

**单测**（example/test/agent/，不触 SDK 的逻辑全测）：三态状态迁移、命令去重/冲突/在途拒绝、EvidenceStore 订阅与 clear 隔离、游标分页与 410、鉴权与 413、未知字段容忍、expect 兼容评估。`ChatClient.init` 特例与 runApi 链路以设备冒烟为准。

**冒烟序列**（手动，iOS 模拟器一台，curl 即可，不需要 flow_runner）：

1. `API_CONTROL=true` 启动 example，控制台读 `[AGENT_CONTROL]` 端口与凭据。
2. `GET /v1/info` → accepting、instanceId；命令 `{"api":"ChatClient.init","params":{"config":{…},"overrides":{}}}` → done，监听注册。
3. `loginWithToken` → done；一条普通 api 命令 → done + 实际信封 + evidence 区间；`GET /v1/events` 可见 api.* 与监听事件。
4. 异常路径：在途再投 → 409；未注册 api → 422；超时命令 → timeout + uncertain 后续 503；携带 expect 的命令 → expectMatched 返回；未知字段 → 容忍；`POST /v1/finish` → closed。

**联 flow_runner 验收**：单 agent YAML（init → login → 数个 step）跑通，报告含 expect 判定与 checks 明细——为 multi-cases 子文档的 M2 做准备。

## 11. 不做什么

- 不做多会话/同进程换脚本（Q2 已定：重启 App）。
- 不做设备脚本绑定、stage 查找、agent 侧引用解析、依赖跳过（v2 已归宿主）。
- 不做 watch 接口、通用取消/回滚、后台常驻、局域网直连、设备间直接通信。
- 不做 App 内测试结果展示增强（报告在宿主侧）。
- 不引入除 `dart:io`/现有依赖之外的新 package。

## 12. 任务清单

- [x] `agent_mode.dart` + `main.dart` 路由分支 + 三模式互斥（`API_SCRIPT`+`API_CONTROL` 同设拒绝启动，ModeConflictPage）
- [x] `control_server.dart`：路由/鉴权/限长/错误格式（phase-control v2 §5 状态码）
- [x] `command_service.dart`：去重/单在途/runApi + 超时/uncertain/init 特例/expect 兼容
- [x] `evidence_store.dart`：LogStore 订阅/环形缓冲/溢出标记（监听事件 source 剥离 handler 前缀——现有 79 个事件裸名零冲突，2026-11-05 核验）
- [x] `agent_home_page.dart`：状态展示（含 production init 装配：config/overrides 合并 + registerAllListeners）
- [x] 单测（§10 清单）全绿（34 个）；example 既有 `flutter test` 不回归（60/60）、analyze 清零
- [ ] 冒烟序列（§10）在 iOS 模拟器实际通过，记录实际端口/凭据获取方式
- [ ] Android 模拟器重复冒烟一次（含 cleartext 核实）
