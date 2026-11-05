# Example HTTP 执行控制协议

- 日期：2026-11-04。
- 状态：草案，尚未实现或设备验证。多设备编排已定由宿主端控制流解释器（`tool/flow_runner`）承担，设计见 [控制流解释器规格](../../docs/spec/2026-11-05-flow-interpreter-spec.md)；本文的会话、命令与事件接口作为其 HTTP 通道依据，字段以解释器规格及其实现为准。执行中途不依赖 AI 决策。人工／自动运行二选一，不增加人工操作锁，人工干预按日志识别；独立脚本冷启动已接受（Q1/Q2 已确认）。
- 依据：[总体规格](../../docs/spec/2026-11-04-example-testing-spec.md)、[本轮审查记录](2026-11-04-http-review.md)。路径均相对 5.0.0 工作树。

## 1. 职责与使用方式

单设备完整脚本、单设备串行多个脚本、多设备分阶段协同共用一个 HTTP 协议和阶段执行器；继续复用 registry、监听、断言及报告能力。

```text
宿主运行器（flow_runner 解释器）：读取流程脚本 → 派发命令 → 核验日志 → 决定下一步
   ↓ HTTP 命令、状态查询、增量日志（每台设备一条连接，直连 App 内控制服务）
example：校验 → 串行执行指定阶段 → SDK 返回／事件／断言
```

单设备与多设备共用同一协议。App 只执行已绑定脚本的阶段，宿主运行器负责跨设备顺序、输出传递和异常分析；多个独立脚本由宿主串行编排，App 不需要知道其他设备的地址。

HTTP 省去设备上的命令投递文件；命令去重、执行状态和事件观察仍需内存数据。宿主机继续保存命令记录、脚本快照、日志和报告，不将“没有命令文件”理解为“不留证据”。

## 2. 启用与设备连接

建议仅 Debug 且显式设置 `API_CONTROL=true` 时启动 `dart:io HttpServer`；默认人工启动不监听。与旧 `API_SCRIPT` 同时设置时拒绝启动双执行入口。服务依附 App 生命周期；第一轮测试在前台执行，不承诺后台常驻或锁屏后持续运行。

默认监听 loopback，使用系统分配的空闲端口。启动时生成随机 sessionId 和控制配对凭据，将连接信息交给本地启动工具或测试界面。HTTP 接口使用 `Authorization: Bearer <control-token>`；该凭据与 IM User Token 不同，不能写入事件或归档报告。

| 设备 | 宿主到 App 的默认连接 | 必要适配 |
|---|---|---|
| Android 模拟器、USB 调试真机 | `adb -s <device> forward tcp:<hostPort> tcp:<appPort>` | 端口分配、设备绑定、断线检查、清理本次转发 |
| iOS 模拟器 | 宿主直连监听端口 | 多模拟器端口隔离、sessionId 核对 |
| iOS USB 调试真机 | `iproxy` 转发至 App loopback | 设备信任／配对、转发进程管理；实际连通性待验证 |

协议不包含平台目录或 adb 指令，适配留在宿主工具。局域网直连需要显式选用设备网络接口及可达 IP，不默认开放所有网卡或增加广播发现；首轮优先上述本机／USB 路由。HTTP 统一协议，但不能消除安装、启动和网络可达性的差异。记录实际测试矩阵，不能把设计支持写成真机已验证。

## 3. 会话、人工模式与脚本隔离

一次执行器启动生成一个 sessionId，只绑定一个 runId、actor、子脚本及环境，绑定后不可修改。所有后续请求和事件携带或核对 sessionId，拒绝旧启动的请求。

**Q1 已确认：** 默认人工流程保留。自动运行持有活动会话时，人工可以看界面和日志；初始化、登录、退出及 registry 调用统一受操作权控制，避免人工插入 SDK 操作。人工已操作 SDK 时拒绝直接接管，准备新的测试启动。结束控制、无未决 native 调用且状态已核实后，才交还人工。单页按钮的 running 状态不能代替全局互斥。

**Q2 已确认：** 同一脚本的阶段保持 App 在线；不同独立脚本默认完整停止并重启 App，复用已构建安装包，不逐脚本重编译。仍支持一次批任务串行执行 A → B → C。冷启动不自动清除数据库或服务端资源，前置条件和清理仍需遵守脚本。

Q2 的源码依据：双端 native 对重复 init 直接返回成功并忽略新 options，Dart 却会更新自己的 options。HTTP 新绑定、logout、Flutter hot restart 都不能当作 native 配置已重置。首轮按“一次启动一份脚本”使用一个 sessionId；若改为同进程复用多个脚本，需补充初始化兼容与启动代次规则，再冻结格式。

| 会话状态 | 含义 |
|---|---|
| unbound | HTTP 可用，未绑定脚本；不隐式初始化或登录 |
| ready | 已绑定，可接受符合前置条件的阶段；SDK 状态单独报告 |
| running | 一个阶段正在执行；查询仍可用，新业务阶段拒绝 |
| blocked | 当前链失败；仅状态明确、无在途调用时允许适用的脚本清理阶段 |
| uncertain | 超时／中断后底层状态未知；停止后续 SDK 操作，先核查 |
| closed | 已结束控制，保留查询直到进程退出，不绑定新脚本 |

HTTP ready 不等于 SDK 监听就绪。状态接口区分执行器已观察状态和真实 SDK 查询结果，不直接把 SdkState 界面快照当作权威登录状态。

## 4. HTTP 接口与命令格式

建议协议前缀 `/v1`，JSON 请求响应。普通 HTTP 请求默认 5 秒；阶段默认 30 秒、最大 120 秒；宿主场景默认 10 分钟。阶段超时约束其中的步骤等待；网络请求超时与 SDK 操作超时分别记录。

| 接口 | 输入与返回 |
|---|---|
| `GET /v1/info` | 返回版本、sessionId、平台、会话状态，用于首次握手 |
| `POST /v1/session` | 输入 sessionId/runId/actor、完整 script、environment；校验后首次绑定 201；相同内容重复绑定 200，不同内容 409；无 SDK 副作用 |
| `GET /v1/session` | 返回绑定、脚本摘要、会话状态、当前命令、日志健康及已观察的 SDK 状态，不返回凭据 |
| `POST /v1/commands` | 接受下方命令返回 202，不等待阶段完成；同 ID 同内容返回 200 和已有状态 |
| `GET /v1/commands/<commandId>` | 返回执行进度或终态；断线恢复先查询原命令 |
| `GET /v1/events?afterSeq=80&limit=200&waitMs=1000` | 返回游标后的事件，最多等待 1 秒；空页、缺口、读取故障明确区分 |
| `POST /v1/session/finish` | 输入 sessionId/collectedThroughSeq；检查无在途调用、清理已完成或明确不适用、必要证据已采集，再关闭控制；不隐式 logout 或取消 native |

已绑定会话的 GET 请求使用 `X-Test-Session` 请求头；POST 请求体携带 sessionId。命令同时核对 runId、actor。script 是完整设备脚本 JSON，environment 只包含 App 必需的选项、User Token 和资源；clientSecret/App Token 留在数据工具。

绑定前校验未知字段、API、阶段、引用及断言；执行前核查动态输入与状态。建议请求体上限 1 MiB，超限拒绝，不将大型附件传输扩充到控制接口。脚本记录确定性内容摘要；重复请求按解析后的 JSON 内容比较，忽略对象键顺序，保留数组顺序。

命令样例：

```json
{
  "sessionId": "session-device2-001",
  "runId": "run-001",
  "commandId": "cmd-004",
  "actor": "device2",
  "stage": "receive_and_receipt",
  "inputs": {"messageId": "m123"},
  "timeoutMs": 30000
}
```

命令只能选择绑定脚本中的阶段，inputs 满足声明且引用已解析；不能在请求里替换步骤或 expect。宿主运行器核查跨设备前置条件，App 核查本设备前置状态。

接受响应（HTTP 202）：

```json
{
  "sessionId": "session-device2-001",
  "runId": "run-001",
  "commandId": "cmd-004",
  "actor": "device2",
  "stage": "receive_and_receipt",
  "status": "accepted"
}
```

最终查询结果（HTTP 200）：

```json
{
  "sessionId": "session-device2-001",
  "runId": "run-001",
  "commandId": "cmd-004",
  "actor": "device2",
  "stage": "receive_and_receipt",
  "status": "passed",
  "outputs": {"messageId": "m123"},
  "evidence": {"fromSeq": 81, "toSeq": 96, "relatedSeqs": [42, 75]}
}
```

accepted/running 是非终态；passed/failed/blocked/skipped 为终态。fromSeq..toSeq 为本命令证据闭区间，relatedSeqs 引用区间外的 watch 起点及早到回调，例如在 42 开始观察、75 收到消息、81 才接受本命令。HTTP 不返回虚构的宿主文件路径；宿主工具落盘后才在归档中增加 evidence.file。

失败结果增加 `failure: {kind, stepId, message}`；kind 区分 assertion/sdk/tool/timeout/evidence，预期和实际值保留在断言事件。SDK 返回错误不等于已经确诊 SDK 缺陷，最终归因须复验。

HTTP 请求错误格式为 `{sessionId, error: {code, message}}`。400 字段错误、401 配对失败、404 未知命令、409 身份／内容冲突或 busy、410 日志区间丢失、413 请求过大、422 脚本能力或前置条件不符、503 执行器／证据通道不可用。SDK 303/500/600 等错误写入命令结果，不映射成 HTTP 状态码；未接受请求没有 SDK 副作用。

## 5. 监听与执行流程

1. 显式测试启动，建立 HTTP 监听及执行证据通道，提供连接信息。日志通道不健康时不调用 SDK。
2. 宿主握手、绑定脚本环境，核对脚本身份；触发 SDK 前启动增量日志采集。
3. App 收到命令，先核对 session 和去重，再检查 busy 与前置条件。先记录接受并取得设备执行权，再开始 SDK 操作。每设备一个在途阶段，不增加隐式队列。
4. 返回 accepted，异步执行阶段，状态／日志查询仍能响应。init 失败不进入 login，login 失败不进入依赖步骤，不继承旧 AutoMode 的无分类登录重试。
5. initialize 后注册监听；watch 建立观察起点并返回 watch.ready。宿主运行器取得证据后才放行 login 或其他设备的触发动作。
6. waitEvent 检查 watch 后已有事件，再等新增事件；按来源和业务 ID 匹配，同一个集合元素的字段必须同时满足。保留原事件 seq；watch 跨阶段保留，步骤临时值通过声明输出传递。
7. 记录 API 返回、断言与终态；宿主运行器采齐证据并独立核验后推进下一阶段。
8. 结束时运行适用的显式清理，宿主归档证据，再 finish、停止测试 App、释放本次端口转发。清理失败与原测试失败分别记录。

## 6. 去重、断线与超时

- 当前 session 内同 commandId 同内容返回已有状态，不同内容拒绝。同一阶段不能换一个 ID 自动再执行；受控复验另建运行并关联原失败。
- POST 响应丢失先查询原 ID；同一 session 确认从未接受该命令后，才重新提交相同命令。连接超时不意味着 SDK 未执行。
- App 重启后 sessionId 改变，内存去重不保留。宿主保留发送前记录及已采集证据，无终态的原操作标为未知，检查业务副作用，不自动重放。
- 阶段超时记录失败、停止后续依赖并置 uncertain。底层调用可能继续，迟到结果另记，不覆盖首次失败，不立即 logout／切账号。恢复连接也不能自动消除 uncertain。
- SDK 返回失败且状态明确时，可以执行适用清理；未执行的依赖为 blocked。其余独立用例在共享设备、账号和资源状态确认不受污染后继续。
- 不提供通用取消／回滚接口。宿主有限等待后可停止本次测试 App，但服务端副作用仍需核查；停止进程不等于完成清理。
- 保持正确预期，按用例／SDK／环境／工具／未确定逐项归因，禁止因 SDK 问题放宽断言。

## 7. 日志、游标与归档

复用 registry/listeners 事件源，执行证据独立于浮动日志的显示列表。人工清空界面不删除测试证据。事件带 sessionId/runId/actor/seq/source/payload；命令操作带 commandId/stage，SDK 自发回调按 watch 和业务 ID 关联，不伪造因果命令标识。

事件查询 afterSeq 为排他游标，每页最多 200 条；返回 firstAvailableSeq、lastSeq、nextAfterSeq。nextAfterSeq 只推进到本页实际取得的最后一条，空页保持原游标。afterSeq 超出最新序号返回无效游标，区间丢失返回 410 evidence_gap，不能当作尚无事件。

```json
{
  "sessionId": "session-device2-001",
  "runId": "run-001",
  "actor": "device2",
  "firstAvailableSeq": 1,
  "lastSeq": 96,
  "nextAfterSeq": 81,
  "events": [
    {
      "sessionId": "session-device2-001",
      "runId": "run-001",
      "actor": "device2",
      "seq": 81,
      "source": "command.accepted",
      "commandId": "cmd-004",
      "stage": "receive_and_receipt",
      "payload": {"status": "accepted"}
    }
  ]
}
```

样例仅展示一条分页记录，后续从 81 继续读取至 96。证据内存必须有界：建议初始上限 10,000 条或 32 MiB，先到者生效；活动 watch 所需事件不能静默丢弃，容量不足明确报告 evidence 故障并停止推进。实现时同时验证宿主持续采集、缓冲保留与缺口检测，不承诺无限断线恢复。

宿主增量写入 `testing/tmp/<run-id>/<actor>/events.jsonl`，报告断线、缺口和写盘失败。宿主运行器核实命令区间与 relatedSeqs 都已落盘、来源一致、断言和输出可追溯后，才放行。HTTP 成功响应不等于证据已经归档。

最终报告及必要证据写入 `testing/reports/<run-id>/`，包含首次失败与复验关系；User Token、控制凭据和 clientSecret 不进入归档。保留原 APITEST 分片重组和 native 崩溃采集，作为 HTTP 无法响应时的补充。报告不依赖 tmp，未采齐证据不能提前清理。

## 8. 必须验证的故障路径

| 情况 | 验收要求 |
|---|---|
| 响应丢失、相同命令重复投递 | 查询原结果，SDK 动作只执行一次 |
| 同 ID 改输入、busy 时新命令 | 明确拒绝，无额外副作用 |
| 非法引用／API、准备失败 | 静态错误在 SDK 操作前拒绝；依赖不推进 |
| 回调先到、之后才 waitEvent | 匹配 watch 后真实事件，保留原 seq |
| 清界面日志、缓冲耗尽、宿主写盘失败 | 不误通过，不将采集故障归为 SDK 未回调 |
| 超时后 native 迟到完成 | 原失败保留，相关链暂停，不自动开始清理 |
| App 重启或地址指向另一设备 | sessionId 不匹配，旧命令不自动重放 |
| 多个独立脚本串行 | 结果隔离，初始化参数按 Q2 最终边界生效 |
| 普通人工启动、自动运行期间人工点击 | 人工模式可独立使用；活动控制遵守 Q1 最终边界 |

按 M2 单聊回执 → M3 群回执 → M1 同账号同步实际验证，记录可用设备的真实组合。本轮仅设计和审查，未实现 HTTP，也未将文档完成视为第一阶段完成。
