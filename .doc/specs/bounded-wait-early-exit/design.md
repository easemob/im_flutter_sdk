# Design：有界等待与提前返回

## Overview

现状（`out/allure-report` 单聊 230 case 实测）：用例累计 51.4 分钟里 step 内真实执行只有 6.0 分钟（12%），31.7 分钟是 step 之间的 `pause()` 空隙，11.0 分钟在首个 step 之前，2.6 分钟在最后 step 之后；此外 `ensure_friends` 每 case 中位 6.14s、累计 17.5 分钟，其中真实的 `getAllContactsFromServer` 只占 0.14s。

框架里已经有正确形态：`receive_message`、`wait_send_success`、`_wait_contact`、`_friend_ready` 都是"上限 + 满足即返回"。本次不是引入新范式，而是把仍在"等满"的等待改成同一形态，并且**不删除**任何等待或超时。

改造分两个层次：

1. 传输/前置层（本 spec 阶段 1–3）：`drain_events`、离线登录登出 settle、既有轮询循环的 sleep 夹紧。这一层无需逐 case 知识，覆盖实测浪费的大头。
2. case 层（阶段 4，分批）：627 个 `pause()` 站点中，凡"等待后紧跟只读查询 + 断言"的，改为用同一预算做有界重试；无探针的保留固定等待。

## Architecture

```
case / fixture
   │  pause(key, module=)                     ← 无探针：保留固定等待（不删）
   │  wait_until(probe, pred, key=, module=)   ← 有探针：立即首探，满足即返回，超上限报错
   ▼
src/tools/case_timing.py
   seconds(key, *, module)   预算解析（不变，权威见 shared-runtime-config 第 13 节）
   pause(key, *, module)     固定等待（不变）
   wait_until(...)           新增：有界等待
   ▼
src/tools/ws_client.py
   receive_message(timeout=) 已是有界 + 提前返回（不变）
   drain_events(timeout=)    改为空闲提前返回，上限不变
```

预算数值全部继续由 `seconds()` 解析，YAML 契约不变，不新增可配置键。`DRAIN_IDLE_SECONDS` 与 `RECEIVE_TIMEOUT_FLOOR`、`POSITIVE_TIMEOUT_EPSILON` 同级，是算法常量，放在 `case_timing_defaults.py`，不进 `DEFAULTS`、不可由 YAML 修改。

## Sequence

改造前（离线重登，预算 3s）：

```
case → pause(3s) ─────────────── 3.000s ──────────────→ 下一步
```

改造后：

```
case → wait_until(getCurrentUser == user, 上限 3s)
          ├ t=0.00 探测 → 命中 → 立即返回（实测量级 0.03–0.10s）
          ├ 未命中 → sleep(min(interval, 剩余)) → 再探
          └ 上限耗尽仍未命中 → AssertionError(语义名, 上限, 探测次数)
```

drain 改造后：

```
drain_events(timeout=3s)
  ├ get(timeout=DRAIN_IDLE_SECONDS) 拿到消息 → 丢弃并继续（刷新空闲窗口）
  ├ get 超时（队列已空闲 0.3s）→ 清空 buffer 并返回     ← 常态路径
  └ 队列一直有货 → 到 3s 上限返回（不报错）
```

## 等待点台账与处置

| 等待点 | 现状 | 处置 |
|---|---|---|
| `ws_client.DeviceConnection.drain_events` | 循环吞掉 `queue.Empty` 继续，**必然烧满 timeout** | 空闲 `DRAIN_IDLE_SECONDS` 即返回，上限不变 |
| `case_timing.pause` | `time.sleep(duration)`，无条件 | 保留不动（断言前等待不删） |
| `case_timing.wait_until` | 不存在 | 新增有界等待助手 |
| `logout_for_offline` 尾部 `settle.offline` | 固定 3s | 探针：`getCurrentUser` 为空 |
| `login_preserving_offline_events` 尾部 `settle.offline` | 固定 3s | 探针：`getCurrentUser == user_id` |
| `login_preserving_offline_events` 首部 `settle.offline` | 固定 3s | **保留固定等待**：等的是服务端把离线消息落库，本地无只读探针 |
| `friendship_setup._friend_ready` | 已提前退出，但 sleep 未夹紧、可越过 deadline | sleep 夹到剩余预算内 |
| `relationship_state.wait_relation` / `assert_pages` | 同上 | 同上 |
| `relationship_fixtures.restore_peer_nickname` | 同上 | 同上 |
| `receive_message` / `wait_send_success` / `_wait_contact` / `_discard_buffered` | 已是有界 + 提前返回 | 不动 |
| `observe.no_event` / `no_delivery` / `no_membership_event` 等 99 处负向观察 | 等满窗口 | **不动**：成功条件就是"没有响应"，提前返回等于废掉断言 |
| `settle.sort_spacing` 1.0 / `settle.cursor_order` 1.1 | 等满 | **不动**：需要真实时间流逝以区分服务端时间戳 |
| `settle.thumbnail_completion` 30 | 观察/完成窗口 | 阶段 4 评估（缩略图完成有下载状态可探） |
| `ws_client.start()` 的 `time.sleep(0.5)` | 连接建立固定等待 | 本次不动，登记为后续项（每进程一次，量级可忽略） |
| 627 个 case 级 `pause()` | 固定 sleep | 阶段 4 分批：紧跟只读查询 + 断言的改 `wait_until`，其余保留 |

## Component design

### `wait_until`

```python
def wait_until(probe, predicate=None, *, key='step.interval', module,
               interval='poll.interval', reason=''):
```

- 上限 `seconds(key, module=module)`，间隔 `seconds(interval, module=module)`；两者都走既有解析链，不新增键。
- 先探测再判断上限：上限为 0 时也会探一次（`step/settle/drain/retry` 允许 0 值）。
- `predicate` 缺省为真值判断；返回探针结果供调用方继续断言，**不替代断言**。
- 失败信息只含 `reason`、语义键、上限秒数、探测次数；不输出探针返回值（可能带消息体、attachment secret、token）。
- 探针必须只读幂等。禁止用 `markAllMessagesAsRead`、`fetchHistoryMessages`（会改本地未读/会话状态）、下载类、发送类做探针。

### `drain_events`

一次 `get(timeout=min(剩余, DRAIN_IDLE_SECONDS))` 同时承担"取消息"和"探测空闲"：超时即证明队列已空闲该时长，直接结束；拿到消息则刷新空闲窗口继续。上限由 `remaining` 保证，`_event_buffer.clear()` 保持在返回前执行。

`DRAIN_IDLE_SECONDS = 0.3`：取值需大于桥接单条事件的到达间隔（实测回调间隔 0.27–0.5s 是端到端往返，同一批积压事件的入队间隔远小于此），小于最小 drain 预算 `drain.buffered=0.001` 之外的所有 drain 预算（0.5–3.0）。

### 离线流程探针

`getCurrentUser` 已被 `restore_user_login`、`_temporary_login` 用作登录态判据，是现成的只读幂等探针。logout 后判"空"沿用 `restore_user_login` 里 `isinstance(current_user, str) and current_user` 的既有语义。

## 跨模块适用性

改造点全部落在共享层，因此其他模块无需重复实现，只是"要不要改 case"的差别：

| 层 | 载体 | 其他模块 |
|---|---|---|
| 传输层 drain | `DeviceConnection.drain_events`（含 `tests/conftest.py` 会话包装器传入的 `drain.generic`） | 自动生效。现有 177 个调用点分布：chat 92、group 61、src/test_flow 10、contact 6、tests/tools 4、conftest 4、client 1 |
| 前置层 | `ensure_friends` → `friendship_setup._drain_events` | chat 自动生效；其他模块凡复用该前置的同样生效 |
| 离线流程 | `offline_test_flow`（`module` 参数由调用方显式传入） | chat / group / contact 的离线 case 自动生效，各自解析自己的 `settle.offline` 预算 |
| 有界等待助手 | `case_timing.wait_until(..., module=)` | 对 10 个模块（chat/group/chatroom/contact/client/presence/push/user_info/session/shared）一视同仁；`module` 是必填关键字并按 `MODULES` 校验 |
| case 级 `pause()` | 627 个站点 | 需要按模块分批改造（阶段 4），规模：group 285、chat 145、chatroom 121、contact 39、presence 10、tools 8、push 5、user_info 4、src/test_flow 4、client 3、src/tools 1 |

即：本轮改完，其他模块**已经**在用同一套机制（drain、离线 settle、轮询夹紧、`wait_until` API），无需各自造轮子；剩下的只是把各模块 case 里的固定 `pause()` 按同一模式逐批换成 `wait_until` + 原断言。按站点数看，阶段 4 收益最大的其实是 group（285 处）而不是 chat（145 处）。

## Constraints / tradeoffs

- **失败路径变慢**：条件不满足时要吃满上限才报错。上限沿用现有语义值（离线 3s、常规 5s），不放大，所以最坏情况不比现在差。
- **"最终一致"风险**：有界重试会把"立即可见"弱化成"上限内可见"。因此上限一律沿用原预算，不给本地投影放大到 30s；本地投影仍是 `settle.local_projection=2`。
- **暴露既有竞态**：原来被固定 sleep 掩盖的时序问题会变成显式失败。这是期望结果，但首轮设备验证需要重复跑以区分"上限给小了"和"真 bug"。
- **drain 提前返回可能漏掉迟到事件**：迟到事件留在队列里会被后续 `receive_message` 读到。对负向断言是偏保守（更容易失败而不是更容易通过），可接受；`login_preserving_offline_events` 不 drain 的约束不变。
- **静态守卫语义微调**：`test_dependency_pacing` / `test_group_step_boundaries` 原本断言"依赖操作前一句必须是 `timing_pause('step.…')`"。阶段 4 改造后允许 `timing_wait('step.…')`，守卫意图（等待没被删）不变。

## Testing strategy

- `tests/tools`（无设备）：drain 空闲提前返回、drain 上限封顶、drain 仍清 buffer、`wait_until` 首探命中/多轮命中/超上限报错/上限 0/sleep 夹紧/错误信息不含探针值；离线流程动作序列改为探针版。
- 假时钟：沿用 `test_chat_friend_setup.py` 的 `monkeypatch.setattr(module, 'time', SimpleNamespace(monotonic=..., sleep=...))` 模式，不引入真实等待。
- 静态守卫：保留"等待不得删除"的 AST 检查，扩展为接受有界等待调用。
- 设备验证（本会话无法执行，需在接了 deviceA/deviceB 的机器上跑）：`pytest tests/chat --alluredir=out/allure-results`，比对 Allure 的 step 内耗时/空隙构成与本 spec 记录的基线（12% / 62% / 21% / 5%），并重复 3 轮确认无新增 flaky。
