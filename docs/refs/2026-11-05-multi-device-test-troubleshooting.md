# 多设备协同测试调试与排查手册

日期：2026-11-05。适用于本工作树的 Android、iOS 模拟器及混合设备测试：`testing/scripts` → `tool/flow_runner` → App HTTP agent → Flutter SDK → Native SDK → 服务端。

本文是高频排查入口，记录方法及当前工具边界，不改变用例规范，也不代表下文建议的诊断字段已经实现。正常执行步骤见 [双端测试 Runbook](2026-11-05-dual-device-e2e-testing-runbook.md) 和 [脚本说明](../../testing/scripts/README.md)。

## 1. 先归类：分类依据是证据断在哪一层

同一个故障可以有多个原因。例如服务端通知延后，同时用例匹配了上一轮通知。不要只按终端报错或最后一个失败步骤给问题定性。

| 类别 | 常见表现 | 优先检查 | 能帮助划定边界的证据 |
|---|---|---|---|
| 环境与构建 | 命令找不到、编译失败、依赖错误、权限拒绝 | 实际工具路径/版本、工作目录、依赖路径、构建模式、权限 | 失败发生在安装/业务执行前；构建输出和退出码 |
| 数据与账号状态 | 登录失败、前置 blocked、重复运行不同、旧通知 | 角色账号绑定、Token、appKey/服务环境、关系、权限、历史通知、其他在线端 | REST 查询、原生元消息 ID/生成时间、账号映射 |
| 设备与 App 生命周期 | 设备离线、无凭据、进程消失、端口失效 | UDID/serial、开机状态、安装产物、进程、前后台、崩溃 | simctl/adb、系统崩溃日志、App 启动记录 |
| HTTP 控制与 agent | 401/409/410/422/503、请求无结果 | 端点、转发、凭据、命令 ID、agent 状态、API 注册 | HTTP 状态、错误体、command accepted/finished、命令查询 |
| 解释器与宿主适配 | 乱序、提前放行、错绑定、漏匹配、错误汇总 | YAML 解析、引用结果、分支/屏障、游标、最终判定 | 宿主 trace、原始 HTTP 结果、真实解释器定向回放 |
| 测试用例与断言 | 接口正常却失败、缺事件仍通过、固定 sleep 后才绿 | SDK 契约、前置、因果依赖、事件归属、读本地还是服务端 | 正反对照、实际参数、断言 expected/actual、业务关联 ID |
| Flutter/Native SDK | 注册 API 后调用错误、原生收到但 Dart 未回调、数据转换错 | registry、MethodChannel、Native wrapper、监听注册及门闩、Native SDK | 两层调用参数/结果、原生回调与 Dart 回调时间线 |
| 服务端与业务传输 | 命令成功但对端原生未收、下次登录才到 | 消息生成、目标资源、在线路由、队列、发送/确认、连接变化 | 服务端请求/消息 ID + 收发日志；缺少服务端证据时只能定位边界 |
| 日志与证据采集 | 文件没输出、JSON 截断、事件区间缺失、报告不全 | 采集通道、进程、分页、缓冲溢出、文件路径、报告归档 | App 文件日志与 HTTP 缓冲交叉核对、原始文件大小/尾部 |

## 2. 每次失败都按这个顺序处理

1. **保存现场再重跑。** 保存运行输出、退出码、前置报告、flow 报告、角色映射及两端日志；重启前导出 HTTP 事件。不要先清日志、清数据、卸载或重建环境。
2. **找到第一个阻断业务因果链的异常。** B 没收到邀请 → B 没接受 → A 等接受超时，首先分析 B 的接收；后面的超时不自动算独立缺陷。
3. **核对“谁在跑什么”。** flow/命令库/构建版本、角色→设备→账号→端点必须对齐。记录未提交修改；仅记录 HEAD 不足以复现。
4. **判断是否发出了正确命令。** 从宿主 dispatch 到 agent accepted，再到 SDK 调用与最终结果，检查一条命令是否缺失、重复、参数错误或执行状态未知。
5. **沿回调反向找断点。** 报告 → 宿主匹配记录 → HTTP 事件 → Dart 文件日志 → Native 收包/回调 → 服务端投递。在哪两层之间证据不连续，就先查哪里。
6. **检查事件归属。** 不是只看“有无同名事件”，还要证明是本轮、本账号、本业务对象产生的事件。通过结果同样需要检查。
7. **一次只改变一个因素做对照。** 例如只换真实 HTTP 为可控 AgentClient，或只加日志。每次写清假设、预期证据、实际结果；禁止同时换账号、构建、延时和断言后宣称找到原因。
8. **按影响范围决定继续。** 暂停依赖已失败状态或共享资源的链；独立用例可继续。超时后操作状态未知、设备崩溃或关键证据缺口时，先确认影响范围，不盲目重发有副作用命令。

开始时约定排查时限。连续几分钟没有缩小范围就同步现象与假设；到用户指定时限仍未定位时停止执行，保留现场并汇报剩余证据需求，不通过反复重跑消耗时间。

## 3. 各类问题的快速定位技巧

### 3.1 环境与构建

- 首先确认在 `5.0.0` 工作树执行，构建命令在 example 所属目录执行；用 `command -v flutter dart`、`flutter --version`、`xcode-select -p` 确认实际工具，而不是只看配置文件。
- 检查本地 package overrides 和解析结果，防止只改了工作树却仍链接 hosted 包。iOS 的 Pods/SPM 实际 Native SDK 版本要与目标版本对应。
- agent 必须来自 `API_CONTROL=true` 构建。`--prebuilt` 只复用产物，不保证它包含最新源码；记录产物来源、构建时间与源码状态。
- `Operation not permitted`、CoreSimulator connection invalid 或 `sandbox-exec` 失败先查执行权限。本次双 iOS 经授权运行成功，不能把某个受限环境的失败推广为“自动化一定无法构建 iOS”。
- setup 构建输出可能被命令替换和 `tail -1` 缓冲。先检查构建进程及输出文件进展；无新终端文字不等于死锁。
- shell 脚本显式用 `bash`；macOS bash 3.2 不支持 `mapfile`、关联数组等。文本查找优先 `rg`；被 Git 忽略的日志应显式传文件路径或使用 `rg --no-ignore`。

### 3.2 数据、账号与历史状态

把前置分成四项分别检查：**资源存在、业务关系、设备本地状态、待投递历史事件**。一项成功不能代替其余三项。

- 确认 `$agents.alice.userId`、`$config.userId` 和设备实际登录账号一致；Token、appKey、REST 与 IM 服务指向同一环境。查看字段是否存在和绑定关系即可，不打印 Token。
- 先只读查状态，再按明确前置做重置。联系人用 `contact_state_probe.dart`；群用群信息和成员角色核对。排查过程中的变更要记入当前实验记录。
- REST 删除好友只证明关系变化；不会证明没有待处理邀请。App 重启、清 UI 日志、新 runId 也不等于清空服务端队列。
- 检查是否还有其他设备/任务登录同一账号。在线端存在只是干扰线索，必须找到它的实际操作证据才能归因；不要擅自踢掉其他会话。
- 历史消息用业务 ID、原生 metaId、服务端生成时间判断。新 App seq 只说明“这次被记录”，不代表业务刚发生。
- 新账号对照可以帮助判断历史状态影响，但要注明它改变了前置条件。换账号后通过不是原问题已经修复。

### 3.3 模拟器、设备与 App

- 所有设备命令显式指定 UDID/serial。双端测试不要用隐式 `booted` 或无 `-s` 的 adb 操作，以免装错、抓错日志。
- adb 的 `device` 状态不等于系统已启动完成，检查 `sys.boot_completed`；iOS 使用现有 `device/ios/boot` 等待就绪。
- 检查进程是否仍活着、是否崩溃、是否发生重启或系统挂起；不能把进程退出后的等待超时归为 SDK 未回调。
- 启动已有实例可能没有新 `[AGENT_CONTROL]` 凭据。正常准备脚本会先终止旧实例再启动；排查前先保存旧实例证据。
- iOS 模拟器端点可由宿主直连，Android 需要 adb forward。两端的端口与账号都应独立，不能只确认“一台能连”。当前 loopback 方案不能直接推导为 iOS 真机可远程直连。
- App 重装可能改变数据容器路径；每次取文件重新查询容器。尽量复用同一构建完成复验，避免把代码变化混入时序实验。

### 3.4 HTTP 控制与 agent

先确认宿主请求能到正确 App，再分析 SDK。常见状态需结合返回的 `code/message` 区分：

| 结果 | 优先检查 |
|---|---|
| Connection refused / 连不上 | App 进程、实际监听端口、Android 转发、旧 agents.json、本机代理；不能只从 SocketException 的某个临时端口判断目标配置 |
| 401 | 控制凭据是否来自本次启动；不是 SDK 用户 Token 登录失败 |
| 409 busy / command_conflict | 同一设备是否并发提交、同 commandId 是否复用了不同内容；查询原命令，不自动换 ID 重发 |
| 410 closed | 已 finish；后续业务命令关闭，应在取证后重新准备实例 |
| 410 evidence_gap | 事件缓冲缺口；本轮依赖这些证据的结论不可靠 |
| 422 unknown_api | registry 没注册、API 名错误或安装的是旧构建 |
| 503 uncertain / 证据降级 | 前序命令超时导致执行状态未知，或缓冲溢出；不能当作普通 SDK 业务错误继续依赖链 |
| HTTP 202 | 只代表命令已受理，仍须按原 commandId 查询最终 done/timeout 及业务结果 |

HTTP 错误与 SDK 错误是不同层：SDK 错误通常在已受理命令的 `success/error/failureKind` 中，而非直接体现为 HTTP 4xx/5xx。超时只停止逻辑等待，不证明原生副作用停止。

当前实现需特别注意：

- finish 后业务提交关闭，HTTP 事件仍可读取；不要认为此时必须重启才能取证。
- `[AGENT_CONTROL]` 中的 instanceId 与 `/v1/info` 的 instanceId 当前分别由 ControlServer 和 CommandService 生成，不能假定二者相等。分别记录来源，用同一接口前后变化及设备/进程信息判断重启，避免错误报警。
- 连接本机端点时绕过代理；不要用测试的用户 Token 代替 HTTP 控制 token。

### 3.5 解释器与宿主适配

- 整流程截止时间也要验证报告与退出码，不能只确认终端打印了超时。Presence 用例开发时定向复现了 `flowTimeoutMs` 超时仍退出 0 的问题；修正后记录 `kind: flow / status: timeout`、退出 1，并停止后续命令派发。已在途的 SDK 操作仍须另行确认，见 [2026-11-06 实测](multi-device-testing/2026-11-06-presence-collaboration-verification.md#51-确认并修正整流程超时误报成功解释器宿主层)。
- 对照宿主实际发出的参数，不只看 JSON 模板。核对 `$config`、`$agents`、`$inputs`、`$step`、`$prev` 各自来源及 agent 作用域。
- 分清命令库中的 `id`、流程结果绑定 `as` 和 HTTP `commandId`；它们不是同一标识，也不会自动关联 SDK 回调。
- 对 parallel/barrier/await 争议，记录“进入、到达、放行、命令开始、命令完成”的顺序。同设备并发命令还受 agent 单在途约束；不能用 HTTP busy 证明 SDK 不支持操作。
- 对 wait_event 争议，记录起始游标、每页 seq 范围、候选事件、匹配条件的解析值、未匹配原因、选中 seq。确认没有漏分页、错 source 或取错角色。
- 在本次联系人用例中，启动游标在登录前建立；登录后才补到的旧通知仍会被选择。只按 userId 匹配不足以证明本轮归属。
- **最有效的工具归因方式：** 用原解析器、原解释器、原脚本，加可控 AgentClient 注入事件顺序。不要重写一个“类似解释器”验证自己的想象。
- 回放至少覆盖合法快回调、旧回调、完全无本轮回调、迟到回调、依赖失败等与当前现象有关的情况；确定性缺陷优先定向复现，不靠设备跑几百次碰概率。
- HTTP 成功而报告判断错误时，对比原始响应与 Envelope/expect 转换；退出码和汇总不能代替逐步记录。当前 abort_flow 未执行的尾部步骤不一定各有 skipped 记录，`skipped: 0` 不说明覆盖完整。

### 3.6 用例、因果依赖与断言

- 回调为列表时，不要默认目标在第一项，也不能拿不同元素的字段拼成一个匹配结果。Presence 用例用现有循环遍历，要求同一元素的 publisher 与本轮随机 description 同时符合；用“目标在第二项”“身份和描述分属两项”“只有旧通知”的反例验证。
- 写清被测事实：发送接口成功、对端收到消息、对端发送回执、发送端收到回执是不同断言。必须有合法的依赖关系，不能拿后面的最终状态补证前面的通知归属。
- 登录完成、连接成功、某类数据同步完成是不同事件。屏障名称叫 `both-online` 不代表它实际检查了全部在线条件；也不要未经证明就给所有失败加同步等待。
- 对消息用 messageId，对群用 groupId/成员，对支持携带标识的邀请用本轮 reason。接受通知若只有 userId，应承认信息不足，研究账号/历史隔离，不能虚构回调中存在 runId。
- 回调可能先于命令响应到达，先缓存后匹配是必要能力。把观察起点移动到命令完成后，可能丢掉合法回调；发送开始后仍可能到历史回调，单独用时间窗口也不足够。
- 检查读的是本地缓存还是服务端状态、契约是否保证立即一致、负向用例是否期待特定 SDK 错误。预期错误符合断言时，测试应通过；工具故障不能被当作预期 SDK 错误。
- 做反向验证：移除本轮关键事件或提供错误业务 ID，测试是否必然失败？如果仍全绿，先解决假通过，再统计稳定性。
- 用例确实违反契约时可以提出修正并说明依据；**不得因 SDK 缺陷放宽正确断言、跳过失败或改成永远通过。** 调整超时必须有契约/时延证据，不能当默认修复。

### 3.7 SDK 与 Native wrapper

按调用链分层查：`registry → Dart SDK → MethodChannel → Native wrapper → Native SDK`，回调沿相反方向查。

- 宿主参数正确、registry 实际调用不同：定位 example 的执行入口。Native 返回正确、Dart 结果错误：检查类型、字段名、枚举、转换与过滤，不急于上报原生 SDK。
- 原生已收到并处理事件，Dart 没有：检查 handler 注册时机、channel 名与监听门闩。联系人/群组/聊天室相关事件需确认 `startCallback()`；连接事件正常不能证明其他事件监听也就绪。
- 区分“收到协议包”“触发 Native delegate”“发出 MethodChannel”“Dart handler 记录”四个点；需要时在相邻边界加少量日志，逐段定位。
- 数据断言失败时，先证明等待的是本轮事件，再检查事件前后数据库状态。历史 REMOVE/ACCEPT 交错可能导致列表变化，并非一次接口的结果转换错误。
- 崩溃收集堆栈、对应构建及最后一条命令；不把后续所有连接失败分别报成 SDK 问题。重启复验必须保留原崩溃证据。
- Android/iOS 对照能缩小范围，但只有环境、账号状态、Native 版本及脚本条件一致时才有较强解释力；另一端通过不能单独证明本端 SDK 错误。

### 3.8 服务端与传输链路

- 发送成功通常只证明对应调用成功，不证明对端收到推送。核对 REST/协议返回、服务端消息 ID、目标账号及设备资源。
- 原生未见事件时，先确认日志连续及连接状态，再区分“没生成、没路由、未送达、已到协议层但未分发”。缺少服务端日志时只报告已定位边界。
- 使用请求 ID、metaId/messageId、生成时间和业务对象联合查询发送、入队、路由、确认记录。下一次登录才收到同一消息 ID，是延后投递的强证据，不能据此直接断言具体后台模块有 bug。
- 检查在线替换、断线重连、前后台及其他设备会话。不要将通用连接日志中的某个 warning 单独当成根因，需与失败发生的时间及因果对应。
- 没有服务端追踪能力时，提交最小证据包：时间窗口/时区、环境、收发账号及资源、消息 ID、客户端发送响应和收包缺口。不要上传整份凭据或无关聊天日志。

### 3.9 日志采集与报告问题

- 完整 App 文件也可能跨会话追加，同一个 seq 在不同启动中可重复。先按本轮时间窗口、实例与业务标识筛选，再用 seq 定位；仅搜索事件名会混入历史证据。
- 原生文本日志可能含 NUL，`rg` 会只报 `binary file matches`；确认文件用途后用 `rg -a` 搜索业务标识，不将默认搜索无展开结果误判为没有日志。
- iOS Flutter 输出走 os_log，Android 走 logcat；stdout 重定向为空不能证明 App 没执行。
- 本项目长 `[APITEST]` 日志可能拆成 `[APITEST+序号/总数]`。直接逐行 JSON 解析控制台输出会丢事件；优先 App 的完整 `api_test.log`，或使用具备分片重组能力的读取工具。
- HTTP `/v1/events` 要分页读至当前末尾，且保存采集时间。快照不是持续订阅，不能拿较早快照断言“后面永远没到”。缓冲缺口应明确标记。
- seq 只在同一实例内排序；重启后可以重新编号。跨设备不要比较 seq 大小；跨时钟的毫秒差不要当精确因果，以业务 ID 和命令/消息关系为主。
- 当前事件接口没有输出所有原生日志信息，flow 报告也不是完整 trace。报告找不到的字段不等于底层没有；需要按层取得原证据。
- `run_flow --run-id` 的设备环境 ID 与未显式指定时生成的 `flow-时间戳` 报告 ID 不同。按该次输出的报告路径定位，不使用“目录中最新的一份”代替关联。
- 归档确认应覆盖**本轮**，不能因为 reports 中存在任意其他报告就删除 tmp。首次失败与后续复验各保留一份，不能只留下最后一次成功。

## 4. 常用只读取证命令

以下从工作树根目录执行。先设置本轮真实标识，不复制历史端点；输出放在 Git 忽略目录，不直接提交原始日志。

```bash
diag_run=replace-with-current-run-id
ios_udid=replace-with-selected-udid
android_serial=replace-with-selected-serial
diag_dir="testing/tmp/$diag_run/diagnostics"
mkdir -p "$diag_dir"

# 设备状态与端口映射
xcrun simctl list devices booted
adb devices -l
adb -s "$android_serial" shell getprop sys.boot_completed
adb forward --list

# iOS 完整 App 日志：容器路径需重新查，App 尚未创建文件时可能不存在
ios_app_data=$(xcrun simctl get_app_container "$ios_udid" com.example.example data)
cp "$ios_app_data/Documents/api_test.log" "$diag_dir/ios-api_test.log"
# 此 Native 路径为本次 iOS 构建实测；后续版本不存在时先定位实际日志位置
cp "$ios_app_data/Library/Application Support/HyphenateSDK/easemobLog/easemob.log" \
  "$diag_dir/ios-native.log"

# Android：先导出已有日志，不先 logcat -c
adb -s "$android_serial" logcat -d -v threadtime > "$diag_dir/android-logcat.txt"
adb -s "$android_serial" logcat -b crash -d > "$diag_dir/android-crash.txt"
# debug App 可通过 run-as 检查私有文件位置，再按真实路径导出
adb -s "$android_serial" shell run-as com.example.example ls files
```

多台同平台设备分别执行并使用角色名命名文件，避免覆盖。Android SDK 文件路径应据实际构建查找；不能照搬 iOS 路径，`run-as` 也不适用于所有构建。

检查两端 HTTP 存活与状态，控制凭据从文件读取，不输出：

```bash
python3 - "$diag_run" <<'PY'
import json, sys
from pathlib import Path
from urllib.request import Request, ProxyHandler, build_opener

root = Path('testing/tmp') / sys.argv[1]
opener = build_opener(ProxyHandler({}))
for agent in json.loads((root / 'agents.json').read_text()):
    req = Request(agent['endpoint'] + '/v1/info', headers={
        'Authorization': 'Bearer ' + agent['token']})
    try:
        with opener.open(req, timeout=5) as response:
            info = json.load(response)
        print(agent['role'], agent['udid'], agent['endpoint'], info)
    except Exception as error:
        print(agent['role'], type(error).__name__, str(error))
PY
```

HTTP 事件的分页导出模板见 [双 iOS 取证方法](2026-11-05-dual-ios-contact-add-verification.md#4-如何取证避免误判)。导出后再重启；设备停止或凭据过期时无法靠旧 agents.json 恢复现场。

## 5. 怎样加临时日志才有效

优先补“哪两个相邻环节之间还缺证据”，不要全项目散布 print。临时文件放 `testing/tmp/<诊断ID>/`；如必须在源码加日志，单独列出改动及关闭方式，不夹带逻辑修复。

| 位置 | 推荐记录 | 用于回答 |
|---|---|---|
| 宿主调度 | 运行 ID、节点/分支、逻辑角色、dispatch/result、单调耗时 | 是先发命令还是先满足依赖？有没有重复执行？ |
| HTTP 边界 | 同一 commandId、API、脱敏参数、状态码、最终执行状态、evidence 区间 | 请求是否到正确设备？超时前是否已有副作用？ |
| 事件匹配 | 观察起点、轮询 afterSeq、候选 seq/source、解析后的条件、匹配/拒绝理由 | 为什么选中这个事件？有没有扫过却漏掉？ |
| SDK 桥接 | API/回调名称、对象 ID、关键类型、进入/返回、必要的线程信息 | 参数或回调在哪层改变/丢失？ |
| 原生协议 | 消息 ID、操作类型、生成时间、接收时间、资源标识 | 是本轮新通知、历史通知还是重复投递？ |
| 断言 | expected、actual、判定、引用来源、必要的前置状态 | 是业务失败、数据错误还是判定器错误？ |

这些是**建议诊断字段**；当前宿主日志与 HTTP 协议并未全部具备。不要为了填表伪造来源不明的字段，也不要把业务命令的 token/config 全量输出。结合墙钟关联日志，使用单调时钟度量本进程耗时。

临时日志会改变时序：加日志后不再复现只能说明该条件下没复现，不能视为修复。保留首次原始证据，尝试边界少量日志、离线回放或可控事件顺序；避免用大量同步写盘制造新的竞态。

## 6. 高频症状的最短判断路径

| 症状 | 先做什么 | 然后去哪里 |
|---|---|---|
| SDK API 成功，wait_event 超时 | 检查原始事件流是否包含目标业务 ID，而非只搜索事件名 | 有事件查匹配/游标；Dart 有而 HTTP 无查采集；原生有而 Dart 无查桥接；原生也无查投递链路 |
| 每轮结果不同 | 对齐脚本/构建/账号和事件生成时间，保留每轮输入差异 | 旧通知/前置不足查数据与用例；相同确定输入结果不同才进一步查调度竞态 |
| 全绿但怀疑没真正执行 | 查每个业务断言的本轮触发证据、实际执行节点及最终状态 | 做无本轮关键事件的反向输入；若仍通过，查断言/事件归属 |
| 数据列表偶尔为空 | 确认查询的存储层、真正的本轮通知、查询与写入顺序 | 再区分契约要求、SDK 更新顺序、历史删除、数据转换 |
| HTTP 偶发 409/503 | 查具体错误 code、在途命令及前序超时 | 调度竞争或执行状态未知；不要先重试 SDK 动作 |
| App 日志突然不增长 | 查进程、采集进程、App 文件日志和 HTTP 缓冲 | 区分 App 挂起/崩溃与采集退出，不用空日志证明无事件 |

## 7. 结论、复验与交接模板

每个问题保留以下信息，避免只写“偶现、重跑通过”：

```text
问题类别（允许多个）：
被测事实与预期：
首次异常节点；受影响的后续链：
源码/构建、flow/JSON、环境、设备角色与账号：
首次运行 ID → 报告路径；复验 ID → 各次结果：
最小时间线（标明设备/时钟来源、commandId、seq、业务/原生消息 ID）：
已确认事实：
已排除环节及证据：
假设、单变量实验、结果与限制：
根因或已定位到的边界；还缺哪一层证据：
建议修复（未实施时明确注明）：
复验判据、证据路径、临时日志/进程/资源的保留与清理状态：
```

修复后先验证针对性反例不再误判，再按真实使用方式统计重复执行。测试稳定意味着结果正确、可复现，不意味着把真实 SDK 故障都变成成功。不得排除首次失败、修改正确断言或只统计最后一轮；少量成功不能证明 99% 稳定。

本手册的实测依据：

- [Presence 用例开发与五轮双 iOS 验证](multi-device-testing/2026-11-06-presence-collaboration-verification.md)：复用本手册完成数据准备、用例开发、反例验证、CLI 超时缺陷修正和逐层取证。
- [双 iOS 联系人三轮验证](2026-11-05-dual-ios-contact-add-verification.md)：准备、运行、复验与取证细节。
- [事件归属与延后投递深入排查](2026-11-05-contact-flow-instability-investigation.md)：原生消息时间线、真实解释器定向实验，以及仍需服务端证据的边界。
- [HTTP 控制协议](../../testing/spec/2026-11-04-phase-control.md)、[flow_runner 使用说明](../../tool/flow_runner/README.md)：当前接口和语法入口；遇到文档与实现差异，记录差异，不把旧经验当作不变契约。
