# Presence 双设备用例：开发、验证与排查手册检验

日期：2026-11-06。工作目录：`im_flutter_sdk/.worktree/5.0.0`。

结论：A 订阅 B、B 发布状态、A 收到对应通知的用例已完成 `$global` 数据引用整改。设备、账号与业务数据分开准备，run_flow 自动组合执行；当前用法见 §3，原五轮证据保留在 §4，新版验证见 §7。未修改 SDK、原生桥接或 example 的人工入口。

这是对[多设备排查手册](../2026-11-05-multi-device-test-troubleshooting.md)的一次实际检验。五轮通过说明本次条件下可重复，不构成 99% 稳定性证明；本次没有运行 Android。

## 1. 文件与前置

| 内容 | 位置 |
|---|---|
| 控制流 | [5.0.0-multi-presence-positive.yaml](../../../testing/flows/5.0.0-multi-presence-positive.yaml) |
| 命令库（两角色共用） | [5.0.0-multi-presence-positive.json](../../../testing/flows/scripts/5.0.0-multi-presence-positive.json) |
| 本轮数据准备 | 上述 JSON 的 `data` 节点 + [declaration.dart](../../../testing/tools/data/declaration.dart) + [roles.dart](../../../testing/tools/data/roles.dart) |
| 用例反例验证 | [presence_flow_test.dart](../../../testing/tests/presence_flow_test.dart) |
| 超时回归 | [cli_timeout_test.dart](../../../tool/flow_runner/test/cli_timeout_test.dart)、[interp_stop_test.dart](../../../tool/flow_runner/test/interp_stop_test.dart) |

- 环境准备复用 `prepare_data`；账号与角色绑定归数据工具；设备安装、启动复用 `setup_devices`；执行复用 `run_flow`。
- 使用两个不同的测试账号，角色固定为 `alice`（A）、`bob`（B），设备可交换。账号必须具备 presence 服务权限。
- 用例显式取消 A 对 B 的旧订阅，再订阅 120 秒；不要求两人是好友，不重置联系人关系。只操作这对测试账号的订阅关系，不移除 A 的其他订阅。
- 结束时取消 A 对 B 的测试订阅、恢复 B 原来的状态描述、双方退出登录。原来的 A→B 订阅不会恢复，因此须使用允许重置该关系的测试账号。
- 数据工具在设备启动前生成本轮唯一 `presenceDescription`，位于 `data.json` 的 `biz.input`；`global.json` 组合设备信息与数据，执行时引用 `$global.biz.input.presenceDescription`。每轮采用新运行 ID，重用准备数据或会话会被拒绝。

## 2. 流程与通过判据

```text
A/B 并行初始化、登录并检查连接
→ A 取消旧订阅 → A 订阅 B，断言返回列表包含 B
→ B 查询自己的原始状态（供清理恢复）
→ 并行：B 发布本轮唯一描述 / A 读取 presence 回调
→ A 查询 B 的当前状态，核对本轮描述
→ A 取消订阅 → B 恢复原始描述 → A/B 退出
```

关键规则：

1. 发布步骤位于订阅成功之后；准备失败停止依赖链，不靠固定 sleep 建立依赖。
2. 回调形状为 `{"list": [{"publisher": "...", "statusDescription": "...", ...}]}`。YAML 用 `wait_event.checks` 的 `containsItem` 对原始数组匹配，要求**同一个元素**的 publisher=B 且 description=本轮标识，不假设第一个元素就是 B。语义与原来的 while/for/if 一致，原始未匹配事件仍保留。
3. 不匹配的自身状态、历史描述和其他用户通知仅被扫描，不结束事件等待。正常情况下没有新事件时 20 秒超时；持续无关事件不能无限拖延，整流程上限 120 秒。
4. 命令成功、通知收到、查询结果正确是三个事实。查询正确不能补救通知超时；未收到通知仍必须失败。
5. 观察从流程启动开始，合法的快回调可以先于宿主取得发布结果。不能将游标简单移到命令完成之后。
6. 接收分支超时只停止该分支，后续独立查询与清理继续；整体超时会停止后续派发，需要保存现场后人工检查尚在执行的操作与清理状态。

所有命令和参数保留在 JSON；执行顺序、并发、判断与等待在 YAML。两角色共享命令库，登录命令明确区分角色，恢复状态单独引用 original 结果。

## 3. 可复制的执行步骤

从工作树根目录执行。每次用新运行 ID；`--devices` 顺序对应 YAML 的角色顺序，账号由 JSON `data.accounts` 显式绑定到角色。

```bash
presence_run="presence-ios-$(date +%Y%m%d-%H%M%S)"
presence_a=5AEB6771-C566-4E06-BA98-A5230C0AA1C2
presence_b=14BDE43F-F2E8-4755-A81D-2EDD72D525C0
bash testing/scripts/run_flow \
  --flow 5.0.0-multi-presence-positive.yaml --platform ios \
  --devices "$presence_a,$presence_b" --run-id "$presence_run"
presence_exit=$?
echo "flow exit=$presence_exit"
```

组合入口在准备失败时停止后续执行，正常结束或执行失败都会组织本轮设备清理。报告固定为 `testing/reports/<run-id>/flow-report.json`，运行数据固定为 `testing/tmp/<run-id>/`，不再使用两个不同的运行 ID。分步排查与各文件用途见 [脚本说明](../../../testing/scripts/README.md)。

复验可以给 `setup_devices` 增加以下参数，复用**已经确认包含当前源码的**控制模式构建：

```bash
--prebuilt "ios=$PWD/im_flutter_sdk/example/build/ios/iphonesimulator/Runner.app"
```

工作区受限执行环境若不能写 Flutter 缓存或访问 CoreSimulator，需要运行环境授予相应权限。纯 Dart 检查可直接使用 SDK 内的 Dart 可执行文件，避免 Flutter 包装器刷新缓存。

定向反例从工作树根目录执行（根 `pubspec.yaml` 是现有测试工具依赖入口，本次补入 `test` 开发依赖），工具回归在工具包内执行；无需设备或 SDK 凭据：

```bash
dart pub get
dart test testing/tests
(cd tool/flow_runner && dart test && dart analyze)
```

CLI 超时回归测试需要绑定本机 loopback HTTP 端口；环境的网络沙箱需允许本机测试服务。

## 4. 初版双 iOS 实测证据（整改前）

基线：开发前全部旧修改已提交为 `909d092f`。第一轮重新构建控制模式 App，后四轮复用该构建；本次 App/SDK 源码未改。

- 模拟器一：iPhone 16 / iOS 18.1，`5AEB6771-C566-4E06-BA98-A5230C0AA1C2`。
- 模拟器二：iPhone 16 / iOS 18.2，`14BDE43F-F2E8-4755-A81D-2EDD72D525C0`。
- 账号：A=`zuoyu01`、B=`zuoyu02`；r1–r3 为一=A、二=B，r4–r5 为二=A、一=B。

| 设备环境 ID | 报告目录（位于 `testing/reports/`） | 结果 | A 的目标事件 seq |
|---|---|---|---|
| presence-ios-20261106-r1 | flow-2026-11-06T09-51-50-760930 | 17 passed | 29 |
| presence-ios-20261106-r2 | flow-2026-11-06T09-54-22-768797 | 17 passed | 29 |
| presence-ios-20261106-r3 | flow-2026-11-06T09-54-37-588048 | 17 passed | 29 |
| presence-ios-20261106-r4 | flow-2026-11-06T09-54-51-514742 | 17 passed | 30 |
| presence-ios-20261106-r5 | flow-2026-11-06T09-55-05-244613 | 17 passed | 29 |

各轮 failed/timeout/skipped 都是 0。17 条记录为 15 条 API 命令 + 2 条回调观察；第一条是 A 自身的状态，第二条才是本轮 B 的状态。报告的 `wait_event passed` 在这个循环中只表示读到了一批回调，业务匹配要结合循环、本轮标识和后续步骤完整性判断，不能单看这一条。

第一轮 App 日志时间线（Asia/Shanghai）：

| 时间 | 证据 |
|---|---|
| 09:51:52.251 | A 的 subscribe 返回成功 |
| 09:51:52.601 | B 接受 publish 命令，参数含本轮随机描述 |
| 09:51:52.677 | B App 记录 publish 命令完成 |
| 09:51:52.706 | A Dart 记录 B 的本轮描述，seq=29；HTTP 事件与报告也包含它 |
| 09:51:52.844 | A 查询 B 返回同一描述 |
| 09:51:53.055 / .300 | A 取消订阅完成 / B 恢复原始描述完成 |

宿主每 200ms 轮询命令结果，因此报告中 A 接收成功记录早于 B 发布成功记录；这不表示 B 尚未发出命令。A 原生日志存在携带同一本轮描述的 NOTIFY presence 包，首轮 metaId=`1616475850553688480`。不要将服务端生成时间与设备时间的毫秒差当作严格因果顺序。

归档：`testing/reports/presence-ios-validation-20261106/` 含五轮报告、命中事件、presence 时间线、角色映射、最终源码/构建散列和回归日志。r1 使用修正前运行器，r2–r5 使用超时修正后的版本；最终格式化未改变逻辑。原始全量日志、HTTP 事件与凭据留在 `testing/tmp/presence-ios-20261106-rN/`，不提交。应用已 finish、正常清理步骤全部通过；取证后已终止两端 App，模拟器保持启动。

## 5. 排查手册发现的问题及处理

### 5.1 确认并修正：整流程超时误报成功（解释器宿主层）

按手册“不能只看全绿，做无关键结果反例”的原则，检查 `flowTimeoutMs`。原 CLI 的 `Future.timeout(onTimeout: ...)` 只写 stderr，既不增加失败记录，也不停止底层解释器继续派发。退出码只检查已有报告中的 failed/timeout，因而可能为 0。

用真实 CLI、本机可控 HTTP agent、30ms 整体时限和 150ms delay 定向复现：stderr 已打印超时，报告却是 `passed:0, failed:0, timeout:0, skipped:0`，退出 0。失败日志归档为 `timeout-before-fix.log`。

修正仅涉及运行器：超时新增 `kind: flow / name: flowTimeoutMs / status: timeout` 报告记录并返回 1；通知解释器停止后续派发，不接受迟到命令结果或回调污染报告。已发出的原生操作仍可能继续，未宣称能取消 SDK 副作用。保留原 `abort_all` 的在途结果语义，宿主 stop 使用单独状态。

三项回归验证：真实 CLI 超时应退出 1 且不派发后续命令；停止后忽略在途命令迟到结果；停止后忽略在途 poll 迟到的匹配事件。新用例与旧解释器检查合计 89 项通过。

### 5.2 用例层：列表、历史事件与查询不能替代通知

八项定向验证使用原 YAML/JSON、真实 Parser/Interpreter 与可控 AgentClient，只有测试环境的单步超时缩短至 100ms：

- 正常通知可早于发布命令返回，并完成状态恢复。
- 登录后到达的历史描述不能满足本轮条件。
- 完全缺少通知，即使查询状态正确也必须超时失败。
- B 位于回调列表第二项仍能识别。
- B 的身份和正确描述分属两个列表元素时不能通过。
- 订阅失败后不再发布。
- 发布失败被保留，接收超时后仍执行独立清理。
- 数据工具每轮生成新标识，拒绝重复准备和同账号双角色。

这些是工具层注入的反例，不是实际 SDK 故障记录。五轮设备执行未发现 SDK presence 失败。

### 5.3 日志层：日志文件跨会话追加、原生日志含 NUL

本次设备 `Documents/api_test.log` 中仍有以前运行的内容，同一个 seq 可以在不同会话重复。导出文件后必须先按本轮 `startedAt/finishedAt`、设备实例及业务标识筛选，再使用 seq，不能只搜索事件名。

原生 `easemob.log` 含 NUL，普通 `rg` 只显示 `binary file matches`。确认它是日志文本后用 `rg -a` 搜索本轮随机描述；这不代表事件缺失或日志完全不可读。

## 6. 经验文档是否好用

有效：按“数据归属 → 调度依赖 → 回调逐层证据 → 反例 → 重复执行”推进，可以在设备实测前防住列表误判和历史通知误通过，并通过 CLI 反例发现独立的工具缺陷。取证同时使用 HTTP、完整 Dart 文件和原生日志，避免只凭报告判断。

补充回手册的经验：整体截止时间也必须有失败记录和非零退出码；批量通知按同一元素匹配；完整文件日志也可能混有旧会话；原生日志可含 NUL。后续复验应首先运行这些反例，再统计设备结果，不需要重复靠猜测排查。

## 7. 统一动态数据引用整改验证（2026-11-06）

整改后的可执行用例使用 `$global.account`、`$global.biz.config/input/result/event`，每次 API 调用及目标通知都有独立的 `as` 路径。设备信息由 `setup_devices` 单独准备，账号与初始化配置、随机标识由 `prepare_data` 准备；`run_flow` 组合两者。原来的 presence 专用准备工具已由数据声明和通用 roles 工具替代。

事件判据保持不变：同一数组元素的 publisher 与本轮随机描述必须同时匹配。现在 `wait_event.checks.containsItem` 在匹配目标通知后才通过，因此新版是 **15 个命令 + 1 个目标通知 = 16 项**；初版 §4 的 17 项包含一条仅用于扫描的自身通知，两者不能直接按总数比较。原始未匹配通知仍可在 `<role>-events.jsonl` 查找。

| 运行 ID（tmp 与 reports 相同） | 角色分配 | 结果 | 目标事件 seq |
|---|---|---|---|
| presence-global-ios-20261106-r1 | A=iOS 18.1，B=iOS 18.2 | 16 passed，其他 0 | 29 |
| presence-global-ios-20261106-r2 | A=iOS 18.2，B=iOS 18.1 | 16 passed，其他 0 | 29 |
| presence-global-ios-20261106-r3 | A=iOS 18.1，B=iOS 18.2 | 16 passed，其他 0 | 29 |

三轮均通过完整组合入口执行，分别重新获取 Token、生成随机标识、启动 App；复用同一份已验证的控制模式构建。目标通知早于宿主取得发布命令响应，均能正确匹配。订阅取消、原状态恢复、双方退出、认证后停止两个 App 均成功。

每轮核查：

- `devices.json` 没有账号、初始化配置或业务 env。
- `global-final.json` 有 15 个独立调用结果和 1 个目标事件绑定；数据只在对应调用完成或事件匹配后进入绑定。
- `references.json` 有 19 次实际引用读取，包含路径、值和消费步骤；`trace.jsonl` 保存实际派发参数。
- 恢复命令的实际参数等于 original 查询结果中的原始状态描述；查询结果与目标事件均包含本轮标识。
- 数据、设备凭据、trace 和引用文件权限为 600；共享 flow-report 不含本轮 User Token。
- `cleanup.json` 两角色均 stopped=true，`exit.json` 为 0；第三轮还验证了 `runtime-index.json` 指向正确 tmp 目录和文件。

回归验证：**91 项解释器测试 + 11 项数据／用例测试 + 4 项 Shell 组合测试，共 106 项通过**。两处 Dart analyze 无问题，Bash 语法、文档链接、diff 检查通过。新覆盖包括：缺失与合法 null、提前读取、只读初始数据、重复／并发绑定、失败依赖跳过、账号按角色绑定、准备失败不启动设备、绑定失败不执行命令、执行失败保留原退出码和证据。

归档：`testing/reports/presence-global-validation-20261106/` 保存三轮报告副本、角色映射与清理摘要、测试日志、最终工具源码散列。原始数据保留在 `testing/tmp/presence-global-ios-20261106-rN/`。最后一次源码调整仅规范引用错误分支的工具错误信封，额外定向回归通过；真实设备成功路径未变。

本次没有运行 Android，也未执行人工抽验。三轮通过验证当前整改链路，不作为 99% 稳定性统计。其他用例的旧引用、单设备直跑和 CI 保留；重复循环结果的索引语法未扩展，重复写同一路径明确报错。

## 8. JSON 数据容器合并验证（2026-11-06）

准备声明已合并到 `testing/flows/scripts/5.0.0-multi-presence-positive.json` 的顶级 `data`，`steps` 的命令、参数及断言不变，相邻独立 `.data.json` 已移除。`prepare_data` 通过 `declaration.dart` 选择唯一声明，先存为本轮 `data-declaration.json`，再生成 `data.json`；解释器实现不需要增加业务处理。格式及兼容规则见[动态数据规范 §1.1](../../../testing/docs/2026-11-06-dynamic-data-contract.md#11-用例-json-容器规则)。

验证结果：

- 91 项解释器测试、19 项数据／用例测试、8 项准备／组合入口测试通过，共 **118 项**。其中新增覆盖：多角色共享同一声明、旧 `steps/init/login` 与自定义顶级数据共存、旧相邻声明与显式覆盖、多声明冲突、非法声明，以及准备入口实际生成数据与拒绝重用。
- Dart 静态分析、Bash 语法、文档链接及 diff 检查通过。解释器 HTTP 超时回归需本地端口权限，沙箱内被拒绝后在允许监听的环境补跑通过。
- 完整双 iOS 复验 `presence-json-ios-20261106-r1`：A=iOS 18.1、B=iOS 18.2，使用 §7 同一份控制模式构建；**16 passed，failed/timeout/skipped 均为 0**，退出码 0。
- 运行中的准备声明快照与用例 JSON 的 `data` 相同；随机标识正确生成，通知同一元素的 publisher 和 description 匹配本轮数据，查询佐证通过。15 个命令结果和 1 个事件分别绑定，取消订阅、恢复状态、退出登录及两个 App 的停止均成功。
- 本轮 `data-declaration.json`、`data.json`、`global.json` 权限均为 600。证据保存在 `testing/tmp/presence-json-ios-20261106-r1/`，报告位于 `testing/reports/presence-json-ios-20261106-r1/`，组合入口日志为 `testing/tmp/presence-json-ios-20261106-r1.wrapper.log`。

本节没有新增 Android 或人工验证；旧格式兼容性由自动化回归验证。
