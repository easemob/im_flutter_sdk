# Tasks：有界等待与提前返回

约束贯穿全部任务：不删除任何 `pause()` 调用点、断言前等待或超时；上限值一律沿用 `seconds()` 现有解析结果；负向观察窗口与时间戳间隔不改。

## 阶段 0：基线

- [x] 0.1 从 Allure 报告提取耗时构成基线：230 case 全 pass，墙钟 40.1 min（2 进程并行），用例累计 51.4 min = step 内 6.0 min(12%) + step 间空隙 31.7 min(62%) + 首 step 前 11.0 min(21%) + 末 step 后 2.6 min(5%)；`ensure_friends` 中位 6.14s × 149 次 = 17.5 min。
- [x] 0.2 盘点等待点并分类（正向可探 / 负向必须等满 / 时间戳间隔 / 无探针），结果见 design.md 台账。

## 阶段 1：传输层 drain

- [x] 1.1 在 `src/tools/case_timing_defaults.py` 增加算法常量 `DRAIN_IDLE_SECONDS = 0.3`（不进 `DEFAULTS`，不可 YAML 配置）。
- [x] 1.2 改 `src/tools/ws_client.py::DeviceConnection.drain_events`：空闲即返回，上限不变，返回前仍清 `_event_buffer`。
- [x] 1.3 单测覆盖空闲提前返回 / 上限封顶 / 清 buffer：`tests/tools/test_drain_events_early_exit.py`。

## 阶段 2：有界等待助手

- [x] 2.1 在 `src/tools/case_timing.py` 增加 `wait_until(probe, predicate, *, key, module, interval, reason)`：立即首探、满足即返回、sleep 夹到剩余预算、超上限抛 AssertionError 且不回显探针值。
- [x] 2.2 单测覆盖首探命中 / 多轮命中 / 超上限报错 / 上限 0 / sleep 夹紧 / 错误信息不泄漏：`tests/tools/test_bounded_wait.py`。

## 阶段 3：离线边界与既有轮询循环

- [x] 3.1 `src/test_flow/offline_test_flow.py`：logout 尾部与 `startCallback` 尾部的 `settle.offline` 改为 `getCurrentUser` 探针有界等待；"重登前"固定等待保留并注释原因。
- [x] 3.2 sleep 夹到剩余预算内：`friendship_setup._friend_ready`、`relationship_state.wait_relation`、`relationship_state.restore`（备注/黑名单基线恢复循环）、`relationship_fixtures.restore_peer_nickname`。`relationship_state.assert_pages` 的 deadline 循环内没有 sleep，无需改。
- [x] 3.3 更新受影响的既有单测：`tests/tools/test_case_timing.py::test_offline_flow_waits_in_order_and_preserves_events`（动作序列改为探针版）、同文件新增 `test_offline_login_state_that_never_settles_fails_at_the_bound`、`tests/tools/test_offline_login_boundaries.py` 新增 `test_offline_settle_waits_are_bounded_but_never_removed`（守卫"等待不得删除"，形态改为有界等待）。

## 阶段 4：case 级改造（未完成，分批进行）

规模（`pause()` 站点数）：group 285、chat 145、chatroom 121、contact 39、presence 10、tools 8、push 5、user_info 4、src/test_flow 4、client 3、src/tools 1。机制已在共享层就位，各模块直接复用 `wait_until`，无需重复实现（见 design.md 跨模块适用性）。

- [ ] 4.1 用 AST 扫描把 627 个 `pause()` 站点分成三类：紧跟只读查询+断言（可改）、紧跟写操作（需改为探测写操作的可观测效果）、无探针（保留）。产出台账写入本文件。
- [ ] 4.2 chat 模块离线家族（51 case，实测 29 min）先改：把"pause → 查询 → 断言"改为 `wait_until` + 原断言。
- [ ] 4.3 chat 会话/消息本地投影类（`settle.local_projection`）改造。
- [ ] 4.4 `settle.thumbnail_completion=30` 评估是否有下载状态探针。
- [ ] 4.5 扩展 `test_dependency_pacing` / `test_group_step_boundaries` 守卫，接受 `timing_wait('step.…')` 形态。
- [ ] 4.6 group（站点最多）→ chatroom → contact → presence / push / user_info / client 依次改造。

## 阶段 5：验证

- [x] 5.1 `python3 -m pytest tests/tools -q`（无设备）。结果见下方。
- [ ] 5.2 设备验证：`pytest tests/chat --alluredir=out/allure-results`，重复 3 轮，比对耗时构成与 flaky。待执行。
- [x] 5.3 更新 `docs/case-timing-inventory.md` 的早退语义说明（上限语义、`wait_until`、`drain_events` 空闲早退、负向窗口与时间戳间隔不改）。
- [ ] 5.4 设备验证通过后回填实测收益（每 case 节省、整轮墙钟、flaky 对照）。

## 阶段 6：后续修复（未完成）

- [ ] 6.1 `timeout.friend_invitation` 5 → 30（DEFAULTS）。理由：新账号首次建好友走 `addContact` → 等 `onContactInvited` 的冷启动路径，5s 上限偏紧；drain 早退移除了 `addContact` 前约 5.4s 的隐式缓冲，使这个既有紧上限暴露。该上限是早退式的，热路径不付代价。
- [ ] 6.2 `tests/chat/test_chat_crud.py:221` 给 `evt` 判空：当前 `evt` 为 None 时崩在 `.get`，报成 `AttributeError` 而不是"未收到 onMessageSuccess"。
- [ ] 6.3 专门验证 drain 早退不会让迟到事件跨用例串味：`drain_events` 提前返回后，晚于空闲窗口到达的事件会留在队列里，需确认后续同类型断言不会取到上一用例的事件。

## 待用户确认（非本任务改动）

- `tests/user_info/test_user_info.py:120` 的期望值被改成 `'{nickname":"nick-by-type"}'`（缺开头引号、字段从 3 个减到 1 个），不是本 spec 的改动，会让该用例失败。

## 验证记录

- `.venv/bin/python -m pytest tests/tools -q`：**382 passed, 2 failed**，1 个既有 `websockets.legacy` DeprecationWarning。
- 2 个失败为**改造前已存在**：`test_allure_metadata.py::test_repository_registration_and_priority_work_from_another_root` 与 `::test_code_only_copy_needs_no_statistics_documents`（P1 label 缺失，涉及 chat pin 用例的 allure 元数据，与本次时间改造无关）。已用 `git worktree add --detach /tmp/im-head-check HEAD` 在干净 HEAD 上复现：同样 2 failed / 4 passed，随后移除该 worktree。
- 新增单测 15 条：`test_bounded_wait.py` 8 条（首探命中、多轮命中、超上限报错、上限 0 只探一次、上限 0 已满足即返回、错误信息不回显探针值、按模块解析上限与间隔、非法键/模块）、`test_drain_events_early_exit.py` 4 条（空闲提前返回、积压清完提前返回、持续流量按上限封顶、上限 0 立即返回且仍清 buffer）、`test_case_timing.py` 2 条（离线动作序列探针版 ×2 参数）、`test_offline_login_boundaries.py` 1 条（有界等待不得被删除）。
- 设备侧已观察到 `ensure_friends` 从 6.14s 降到 0.66s；整轮收益与 flaky 对照仍需按 5.2 重跑确认。
- 未执行：SDK 构建、推送、远端操作。
- 本轮实测收益范围仅覆盖 drain（`ensure_friends` 每 case 中位 6.14s，其中 6.0s 是两台设备的固定 drain）与离线登录/登出 settle（每次重登循环 9s 中的 6s）；阶段 4 的 627 个 case 级 `pause()` 未改动，所以 31.7 分钟的 step 间空隙本轮**尚未**回收。
