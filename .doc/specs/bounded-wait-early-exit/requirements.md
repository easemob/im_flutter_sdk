# 有界等待与提前返回（bounded wait / early exit）

配置词汇与默认预算的权威仍是 `.doc/specs/shared-runtime-config`（第 13 节语义键 A 方案）与 `native-auto-test/docs/case-timing-inventory.md`。本 spec 只改变**等待如何消耗预算**，不改变预算数值、不删除任何等待或超时调用点。

## User Story

作为跑 native-auto-test 的测试执行者，我希望每个时间预算都只是"上限"：条件一旦满足就立刻进入下一步，只有到达上限仍未满足才失败。这样单聊模块 40 分钟的墙钟时间里那 45 分钟累计空转（Allure 报告实测：step 内真实耗时仅占 12%）不再被无条件烧掉，而用例的覆盖、断言和超时保护一个都不减少。

## 术语

- **正向等待**：在等某个可观测结果出现（响应、回调、服务端状态收敛、队列清空）。成功条件是"出现"。
- **负向观察窗口**：在证明某事没有发生（`observe.no_event` / `observe.no_delivery` 等）。成功条件是"整个窗口内都没出现"。
- **时间戳间隔**：为了让服务端时间戳可区分而必须真实流逝的时间（`settle.sort_spacing`、`settle.cursor_order`）。
- **探针（probe）**：用于判断正向等待是否满足的只读、幂等查询或事件读取。

## Acceptance Criteria（EARS）

### 通用规则

- WHEN 一个正向等待带有可观测条件 THE SYSTEM SHALL 立即做第一次探测，条件满足即返回，不消耗剩余预算。
- WHEN 正向等待的上限耗尽且条件仍未满足 THE SYSTEM SHALL 抛出断言错误并说明等待语义、上限秒数与探测次数。
- THE SYSTEM SHALL NOT 删除、下调或跳过任何既有超时、`pause()` 调用点或断言前等待；上限值一律沿用现有语义键解析结果。
- THE SYSTEM SHALL NOT 在错误信息中输出探针返回值、原始配置或凭据，只输出语义名、上限与次数。
- WHERE 等待是负向观察窗口或时间戳间隔 THE SYSTEM SHALL 保持等满整个窗口，不引入提前返回。
- WHERE 正向等待没有只读幂等探针可用 THE SYSTEM SHALL 保留原固定等待，并在 design.md 中登记原因。

### drain_events

- WHEN 调用 `DeviceConnection.drain_events(timeout=T)` THE SYSTEM SHALL 在接收队列连续空闲达到算法常量 `DRAIN_IDLE_SECONDS` 时立即返回。
- WHILE 队列仍在持续产出消息 THE SYSTEM SHALL 继续清理，但总耗时不超过 T。
- WHEN drain 提前返回 THE SYSTEM SHALL 仍然清空事件缓冲，语义与清理范围与改造前一致。
- IF 队列在上限内始终不空 THEN THE SYSTEM SHALL 到达上限后正常返回，不报错（drain 的成功条件是"没有更多积压"，不是"收到响应"）。

### 有界等待助手

- THE SYSTEM SHALL 提供 `wait_until(probe, predicate, *, key, module, interval, reason)`：上限取自 `seconds(key, module=module)`，轮询间隔取自 `seconds(interval, module=module)`。
- WHEN 上限为 0 THE SYSTEM SHALL 只探测一次，未满足即报错。
- WHILE 轮询 THE SYSTEM SHALL 把每次 sleep 夹在剩余预算内，不越过 deadline。

### 离线登录/登出边界

- WHEN 离线流程在 logout 之后等待 THE SYSTEM SHALL 以"当前登录用户已为空"为探针，满足即继续，上限仍为 `settle.offline`。
- WHEN 离线流程在 `startCallback` 之后等待 THE SYSTEM SHALL 以"当前登录用户等于目标用户"为探针，满足即继续，上限仍为 `settle.offline`。
- WHERE 离线流程在"对端操作完成到重登之前"等待 THE SYSTEM SHALL 保留固定等待（服务端离线存储无本地探针）。
- THE SYSTEM SHALL 保持 `login_preserving_offline_events` 不 drain 事件队列的既有约束。

### 既有轮询循环

- WHILE 既有 deadline 轮询循环（好友就绪、关系状态、昵称恢复）尚未满足条件 THE SYSTEM SHALL 把间隔 sleep 夹到剩余预算内，条件满足后不再进入 sleep。

### 验证

- THE SYSTEM SHALL 通过 `tests/tools` 全量单元测试；受影响的静态守卫改为同时接受 `timing_pause` 与有界等待调用，但仍然禁止删除等待。
- THE SYSTEM SHALL 新增覆盖：drain 空闲提前返回、drain 上限封顶、`wait_until` 首探命中、超上限报错、sleep 夹紧。
