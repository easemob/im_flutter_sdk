# Example HTTP 执行控制协议（v2）

- 日期：2026-11-04；2026-11-05 重写为 v2（演进记录见 §10）。
- 状态：宿主端和设备 agent 均已实现；当前多设备执行与验证记录见 [多设备测试](../../../testing/multi/README.md)。
- 关联：[控制流解释器规格](../../../docs/spec/2026-11-05-flow-interpreter-spec.md)、[设备 Agent 实现](../../../im_flutter_sdk/example/lib/agent/control_server.dart)。

## 1. 职责与模型

单设备完整脚本、单设备串行多个脚本、多设备协同共用一个 HTTP 协议；宿主端控制流解释器（`tool/flow_runner`）是唯一的编排与判断角色：

```text
flow_runner（宿主）：读 YAML 流程 + 设备脚本命令库 → 宿主侧查库、解析引用 →
   发送完整命令（api + 已解析 params）→ 收实际结果 → 宿主侧 expect 判定
   ↓ HTTP（每台设备一条连接，直连 App 内控制服务）
example（agent）：哑执行器 —— 校验 api → runApi → 回实际信封；缓存带 seq 的事件流
```

**职责分界（v2 核心）**：

| 职责 | 归属 |
|---|---|
| 控制流（顺序/循环/分支/并行/等待） | 宿主（YAML） |
| 设备脚本命令库持有与按 id 查找 | 宿主（parser 加载，agent 不接触脚本） |
| 参数引用解析（`$config`/`$inputs`/`$step`/`$prev`） | 宿主（发送前完成，agent 收到的 params 无引用） |
| API 执行与超时守卫 | agent |
| 断言判定（expect） | **宿主**；agent 仅在命令携带 expect 时按兼容通道评估（§4） |
| 事件缓存与游标分页 | agent |

## 2. 启用与连接

- 仅 Debug 且 `--dart-define=API_CONTROL=true` 时启动 `dart:io HttpServer`；默认人工启动不监听。example 三种运行模式（人工 / `API_SCRIPT` 脚本 / `API_CONTROL` 监听交互）同一进程同一时刻只允许一种：`API_SCRIPT` 与 `API_CONTROL` 同时设置时拒绝启动双执行入口，人工模式与其余两者由 dart-define 天然互斥。
- 监听 loopback，端口系统分配。iOS 模拟器宿主直连；Android 经 `adb forward`；iOS USB 真机经 `iproxy`（转发管理在宿主设备工具，不在协议内）。
- 启动时生成随机控制凭据，经普通 `print` 输出 `[AGENT_CONTROL] {"port":…,"token":…}`——不走结构化日志，凭据因此不进入事件流与归档。
- 所有 `/v1` 请求要求 `Authorization: Bearer <token>`；请求体上限 1 MiB。
- **无会话绑定**（v2 删除）：一进程一次运行；`/v1/info` 返回 `{version, platform, instanceId, state}`，宿主以 `instanceId` 变化检测 App 重启。重启后旧命令自然失效，宿主凭发送记录判定"未知"，不自动重放。

## 3. 接口一览

| 接口 | 输入与返回 |
|---|---|
| `GET /v1/info` | `{version, platform, instanceId, state}`；state ∈ accepting \| uncertain \| closed |
| `POST /v1/commands` | 命令对象（§4）→ 202 `{commandId, status: "accepted"}`；同 ID 同内容重投返回 200 + 已有状态；同 ID 不同内容 409；在途时新命令 409 |
| `GET /v1/commands/<commandId>` | 轮询至终态（§5）；断线恢复先查询原命令 |
| `GET /v1/events?afterSeq=&limit=&waitMs=` | 游标分页（§6） |
| `POST /v1/finish` | `{}`；无在途命令则关闭控制（closed），后续命令 410 |

## 4. 命令对象

```json
{
  "commandId": "alice-3",
  "api": "ChatManager.sendMessage",
  "params": {"to": "u-b", "body": {"type": 0, "content": "hi"}},
  "timeoutMs": 30000
}
```

| 字段 | 必要性 | 说明 |
|---|---|---|
| `commandId` | 必须 | 宿主生成的去重键：响应丢失后查询、同 ID 同内容重放、同 ID 不同内容拒绝（409） |
| `api` | 必须 | registry 注册的 API 名；未注册 → 422 |
| `params` | 必须 | **已由宿主解析完成的参数**，agent 不再做任何引用替换 |
| `timeoutMs` | 必须 | agent 侧执行超时守卫；超时 → 结果 `status: timeout` + 服务置 uncertain |
| `expect` | 可选（兼容） | 携带时 agent 按现有断言逻辑评估并返回 `expectMatched`（§5）；宿主主路径不携带、判定在宿主 |

兼容规则：**未知字段一律容忍**（不报错、不使用）——`id`、`expect` 及未来扩展字段均适用；这同时是协议的前向兼容原则。`ChatClient.init` 是唯一的 agent 特例：成功后自动注册监听（复用 AutoMode 行为），参数携带 `config`（环境 map）与 `overrides`，由 App 内现有 options 组装逻辑合并。

## 5. 命令结果（实际信封）

```json
{
  "commandId": "alice-3",
  "status": "done",
  "success": true,
  "data": {"msgId": "m123"},
  "error": null,
  "failureKind": "sdk",
  "expectMatched": true,
  "evidence": {"fromSeq": 81, "toSeq": 96}
}
```

| 字段 | 说明 |
|---|---|
| `status` | `done \| timeout` —— **只描述执行，不含判断**；passed/failed 由宿主 expect 判定后写入报告 |
| `success` / `data` / `error{code,message}` | 即 `runApi` 信封原样；`data` 供宿主 `$var.data.x` 寻址，`error.code` 供逆向用例 `errorCode` 断言 |
| `failureKind` | `sdk \| timeout \| tool`；非 sdk 故障不得被判为 SDK 语义 |
| `expectMatched` | **仅当命令携带了 expect** 才出现（兼容通道的评估结论） |
| `evidence` | `fromSeq..toSeq` 为本命令执行期间的事件 seq 闭区间，供报告对账 |

SDK 错误码（303/500/600…）写入 `error`，不映射为 HTTP 状态码；未接受的请求没有 SDK 副作用。

## 6. 事件与游标

- 事件即结构化日志流：`{seq, source, payload}`；`source` 为 SDK 回调方法名（如 `onMessageReceived`，2026-11-05 决策）。
- `afterSeq` 为排他游标，每页 ≤200 条，长轮询 ≤1s；返回 `{firstAvailableSeq, lastSeq, nextAfterSeq, events[]}`；空页游标不变。
- 证据缓冲有界：10,000 条或 32 MiB 先到为准；溢出推进 `firstAvailableSeq`，`afterSeq < firstAvailableSeq` 返回 410 `evidence_gap`，且服务标记证据降级、拒绝后续业务命令（503）。
- `relatedSeqs` 已删除（v2）：宿主持续轮询全量事件流，游标模型下无区间外引用需求。

## 7. 超时、uncertain 与失败

- 命令超时：记录 timeout 失败，服务置 **uncertain**，业务命令 503；迟到完成作为普通事件进入证据流，不覆盖首次失败。宿主的选择是显式 finish（放弃）或杀进程重启——不提供自动恢复、通用取消或回滚接口。
- 宿主侧判断失败（expect 不匹配）：agent 状态不变（数据真实、执行正常），流程按 onFail 策略处理。
- 同一命令不因换 ID 自动重执行；受控复验由宿主新建运行并关联原失败。

## 8. 必须验证的故障路径

| 情况 | 验收要求 |
|---|---|
| 响应丢失、相同命令重复投递 | 查询原结果，SDK 动作只执行一次 |
| 同 ID 改内容、在途时新命令、未知 api | 明确拒绝（409/422），无额外副作用 |
| 未注册 api、params 类型错误 | 422，无 SDK 副作用 |
| 回调先到、之后才 wait_event | 匹配游标后真实事件，保留原 seq |
| 清界面日志、缓冲溢出、宿主写盘失败 | 不误通过，不将采集故障归为 SDK 未回调 |
| 超时后 native 迟到完成 | 原失败保留，服务 uncertain，不自动开始清理 |
| App 重启或地址指向另一设备 | instanceId 变化，旧命令不自动重放 |
| 携带 expect 的兼容命令 | expectMatched 与实际信封同时返回，宿主可独立判定 |
| 普通人工启动、自动运行期间人工查看 | 人工模式可独立使用（agent 模式独立首页，模式隔离） |

按 M2 单聊回执 → M3 群回执 → M1 同账号同步实际验证，记录可用设备组合。

## 9. expect 语义（宿主判定器）

expect 块来自设备脚本 step（宿主查库时已在手，不上协议）：

| 字段 | 语义 |
|---|---|
| `success` | 断言信封 success 标志 |
| `errorCode` | 断言失败调用且 SDK 错误码匹配（如逆向用例 `{"errorCode": 110}`） |
| `checks` | 对 `data` 的 path 断言，操作符：`equals \| gte \| notEmpty \| containsItem \| length` |

规则（与 AutoMode 完全一致）：缺省/空 expect 即断言 success；`failureKind != sdk` 或 `error.code <= 0` 永不通过；未知 expect 字段在**加载设备脚本时静态拒绝**（拼写防护）。判定器实现：宿主 `tool/flow_runner/lib/expect.dart`（自 example `script_values.dart` + `step_expectation.dart` 移植，语义需保持同步）。

## 10. v1 → v2 演进记录（2026-11-05）

v1 对象模型（脚本绑定 + stage 引用 + inputs 注入 + 会话状态机）成型于 AI 子代理方案：当时子代理持有设备脚本，主代理只报阶段名。解释器接管编排后宿主本来就要读脚本（静态检查），绑定变成两头各维护一份脚本状态，agent 被迫实现引用解析、会话内 stepData、依赖跳过等与解释器重复的逻辑。v2 变更：

| v1 | v2 | 理由 |
|---|---|---|
| `POST /v1/session` 绑定完整脚本与环境 | **删除**；agent 不接触脚本与环境 | 宿主查库、解析后发全量内容 |
| 命令 `{stage, inputs}` | 命令 `{api, params}`，params 已解析 | stage 仅为查找键，改宿主侧；inputs 经 `$inputs` 槽位在宿主合并 |
| 结果 `{status: passed/failed, outputs}` | `{status: done/timeout, success/data/error/failureKind}` | 执行与判断分层；判定归宿主 |
| `relatedSeqs` | 删除 | 游标模型下无区间外引用 |
| watch/`watch.ready` 接口 | 删除（v1 草案阶段即被游标方案取代） | 先到事件进缓冲、wait 先查缓存 |
| 六态会话状态机 | `info.state` 三态（accepting/uncertain/closed） | 一进程一次运行，Q2 边界不变 |
| 命令携带 expect 由 agent 判定 | 保留为兼容通道（可选字段） | 老调用者可用；宿主判定为主路径 |
