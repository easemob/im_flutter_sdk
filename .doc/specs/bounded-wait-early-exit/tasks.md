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

## 阶段 4：case 级改造（分批进行）

规模（`pause()` 站点数）：group 285、chat 145、chatroom 121、contact 39、presence 10、tools 8、push 5、user_info 4、src/test_flow 4、client 3、src/tools 1。机制已在共享层就位，各模块直接复用，无需重复实现（见 design.md 跨模块适用性）。

- [x] 4.1 AST 扫描分类（616 个站点，脚本为一次性分析工具，未入库）。台账：

  | 分类 | chat | group | chatroom | contact | 其他 | 合计 |
  |---|---:|---:|---:|---:|---:|---:|
  | `read_probe`：紧跟只读查询，可改 | 42 | 56 | 34 | 11 | 12 | 155 |
  | `write_op`：紧跟写操作，需改为探测前一步的可观测效果 | 56 | 115 | 57 | 9 | 11 | 248 |
  | `already_bounded`：下一句已是 `receive_message`/等待助手 | 9 | 26 | 4 | 8 | 1 | 48 |
  | `other`：下一句是本地 helper（`_fetch_group` 24、`_send_*` 等），需看内部 | 32 | 86 | 26 | 11 | 1 | 156 |
  | `tail`：块内最后一句 | 6 | 2 | 0 | 0 | 1 | 9 |

  额外发现：`read_probe` 必须再切一刀——期望"出现/变化"的可改；期望"不出现/不变化"的是**负向断言**，轮询会在 t=0 立刻通过而使断言失效，必须保留固定等待。chat 离线家族 14 个 `read_probe` 里就有 5 个属于后者（撤回后 `getMessage` 期望 `result=None`）。
- [x] 4.2 新增两个有界断言助手 + chat 离线家族改造 9 个站点：
  - `assertions.assert_eventually(probe, check, *, key, module, interval)`：复用站点原有的本地断言 helper（如 `_assert_call` / `_assert_reaction_state`），重试期间在 `quiet_evidence()` 下静默执行，决定性的那一次才写证据。
  - `assertions.assert_response_eventually(probe, *, expected, ignore_keys, key, module)`：针对"响应 vs expected 字典"的标准形态，重试期间用 `compare_response` 静默判断，`expected` 字典缩进不变，站点 diff 最小。
  - `allure_steps.quiet_evidence()` + `_QUIET` 门控（`business_step` / `attach` / `step` / HTML 总览均遵守）：保证重试不在报告里留下红色中间步骤。
  - 改造站点：`test_chat_offline_message_delivery.py`(1)、`test_chat_offline_message_extended_delivery.py`(2)、`test_chat_offline_message_extended_operations.py`(3)、`test_chat_offline_message_operations.py`(3)。保留的 5 个负向站点已就地注释说明原因。
- [x] 4.3 chat 其余 `read_probe` 站点：标准形态（`pause → var = dev.call(只读) → assert_api.assert_response_matches(var, expected=...)`）用一次性转换脚本改为 `assert_response_eventually`，chat 命中 10 处。转换脚本带两道闸：cmd 必须以 `get/fetch/load/is/search/has` 开头（写操作绝不重试）、`expected` 含 `result: None` 的负向断言跳过。
- [x] 4.4 `settle.thumbnail_completion=30`：原本是"先固定睡 30s，再进有界事件等待"。改为把这 30s 折进后面的 deadline（`timeout + settle.thumbnail_completion`），总上限一字不改，收到 `onMessageSuccess`/`onMessageError` 终态事件即返回。`tests/tools/test_chat_wait_budgets.py` 的两条预算断言从 30.02/30.01 改为 0.02/0.01；`test_thumbnail_download_times_out_without_terminal_event` 仍断言 33.0，证明上限没变。
- [x] 4.5 `write_op` 类（249 个）**决定不做全量改造，降级为按需处理**。依据：
  - 249 个 `write_op` 里 **241 个**、122 个 `helper` 里 **121 个**都由同一个预算键 `step.interval` 控制，即 371 个待改站点中 362 个受一个配置值支配。
  - 写操作前的等待没有可等待的条件：前一步的写响应已被断言（服务端已确认），该 `pause` 是纯节拍。节拍应由配置表达，不该硬编码成 371 个探针。
  - 收益天花板：按 09-16 那份 230 条 chat 基线报告归因，写操作前的等待累计约 700s ≈ 11.7 min（`step: 3.0` 口径）；把 `step` 降到 0.5 可把这 700s 变为约 117s，一行配置拿到约 83% 的收益，且可秒级回滚。
  - 不得重试写调用本身（`addAdmin`、`sendMessage`、`markAllMessagesAsRead`、下载类都不幂等）。
  - 后续只在 soak 暴露出真实竞态的具体站点上加针对性只读探针。
- [x] 4.9 `step` 预算降档：`config/tke.yaml` 与 `config/ngi.yaml` 的 `step` 已是 `0.5`（对齐 `config/ebs.yaml`）。前置条件已满足：只读断言现在会在自己的预算内重试，降档不会让断言变脆——改造前直接降 `step` 会立刻增加 flaky。注意 `config/*.yaml` 被 `native-auto-test/.gitignore` 忽略（含凭据），属于本机配置，不进版本库。
- [x] 4.6 `other`/`helper` 类拆解：分类器改为跳过纯本地语句与本地无副作用调用（`.get`/`len`/`uuid.uuid4`/`isinstance`/`append` 等），把"下一句不是设备调用"的站点解析到真正的设备交互上。其中唯一的大宗只读封装 `_fetch_group`（group 5 个副本中的 4 个、24 个调用点）改为在 helper 内部做有界重试（新增 `wait_key='step.interval'` 参数），调用点的 `timing_pause` 随之移除 25 处；其余 `helper` 家族（`_send_*`、`_join_chatroom_as_b`、`collect_group_events`、`_first_chatroom_event` 等）是写操作或已有界，归入 4.5。
- [x] 4.7 group / contact / presence / push / chatroom 的标准形态站点：同一脚本改造 49 处（group 19、chatroom 14、contact 5、push 4、presence 2，其余分散）。脚本额外支持"`pause` 在 `try` 之外、调用与断言在 `try` 内"的形态（chatroom 全是这种）。`tests/user_info/test_user_info.py` 的 3 处**未改**，因为该文件有用户未提交的改动，避免混在一起。
- [x] 4.8 静态守卫扩展：`test_dependency_pacing.py::test_dependency_operation_has_explicit_pause` 与 `test_group_step_boundaries.py::test_approval_pauses_before_accept_and_server_query` 现在同时接受固定 `timing_pause` 与同预算的有界断言（`assert_response_eventually` / `assert_eventually`）；"依赖操作前的等待不得删除"这一意图不变。

## 阶段 5：验证

- [x] 5.1 `python3 -m pytest tests/tools -q`（无设备）。结果见下方。
- [ ] 5.2 设备验证：`pytest tests/chat --alluredir=out/allure-results`，重复 3 轮，比对耗时构成与 flaky。待执行。改造过程按"每模块抽几条"验证（见下方抽样记录）；整轮 soak 仍需在 `config/tke.yaml` 降档后跑 2–3 轮，确认 `step: 0.5` 没有引入 flaky，若过于激进退到 1.0。
- [x] 5.3 更新 `docs/case-timing-inventory.md` 的早退语义说明（上限语义、`wait_until`、`drain_events` 空闲早退、负向窗口与时间戳间隔不改）。
- [ ] 5.4 设备验证通过后回填实测收益（每 case 节省、整轮墙钟、flaky 对照）。

## 阶段 6：后续修复

- [x] 6.1 `timeout.friend_invitation` 5 → 30（`case_timing_defaults.DEFAULTS`）。理由：新账号首次建好友走 `addContact` → 等 `onContactInvited` 的冷启动路径，5s 上限偏紧；drain 早退移除了 `addContact` 前约 5.4s 的隐式缓冲，使这个既有紧上限暴露。该上限是早退式的（`receive_message` 收到即返回），热路径不付代价。
- [x] 6.2 `tests/chat/test_chat_crud.py` 给 `evt` 判空：`assert evt is not None, f"未收到 onMessageSuccess：content={content}"`，避免 `evt` 为 None 时崩在 `.get` 报成 `AttributeError`。
- [x] 6.3 drain 早退的跨用例语义已用单测固定：`test_events_arriving_after_the_idle_window_stay_queued`——晚于空闲窗口到达的事件留在队列里交给后续断言判断，再次 drain 会清掉；需要吞掉迟到事件的调用方应显式给更大的 timeout，而不是依赖 drain 等满。

## 待用户确认（非本任务改动）

- `tests/user_info/test_user_info.py:120` 的期望值被改成 `'{nickname":"nick-by-type"}'`（缺开头引号、字段从 3 个减到 1 个），不是本 spec 的改动，会让该用例失败。

## 验证记录

- `.venv/bin/python -m pytest tests/tools -q`：**382 passed, 2 failed**，1 个既有 `websockets.legacy` DeprecationWarning。
- 2 个失败为**改造前已存在**：`test_allure_metadata.py::test_repository_registration_and_priority_work_from_another_root` 与 `::test_code_only_copy_needs_no_statistics_documents`（P1 label 缺失，涉及 chat pin 用例的 allure 元数据，与本次时间改造无关）。已用 `git worktree add --detach /tmp/im-head-check HEAD` 在干净 HEAD 上复现：同样 2 failed / 4 passed，随后移除该 worktree。
- 新增单测 15 条：`test_bounded_wait.py` 8 条（首探命中、多轮命中、超上限报错、上限 0 只探一次、上限 0 已满足即返回、错误信息不回显探针值、按模块解析上限与间隔、非法键/模块）、`test_drain_events_early_exit.py` 4 条（空闲提前返回、积压清完提前返回、持续流量按上限封顶、上限 0 立即返回且仍清 buffer）、`test_case_timing.py` 2 条（离线动作序列探针版 ×2 参数）、`test_offline_login_boundaries.py` 1 条（有界等待不得被删除）。
- 设备侧已观察到 `ensure_friends` 从 6.14s 降到 0.66s；整轮收益与 flaky 对照仍需按 5.2 重跑确认。
- 阶段 4.2 设备验证在 `config/ebs.yaml` 上进行，结果见下方"阶段 4.2 ebs 验证"。
- 预算差异提示：`config/ebs.yaml` / `config/tke.yaml` / `config/ngi.yaml` 的 `step` 现均为 `0.5`（配置文件被 gitignore，不入库）。阶段 4 的节省幅度随该预算变化；`step` 越大，改造收益越明显。
- 未执行：SDK 构建、推送、远端操作。

## 阶段 4.2 ebs 验证

命令：`APK_PATH=<本地缓存 APK> bash skills/im-flutter-run/scripts/run.sh --config config/ebs.yaml --keep-emulator --no-open -v <11 个受影响用例>`

结果：**11 passed，139.05s**（用例耗时累计 111.4s）。覆盖全部 9 个改造站点所在的 8 个用例（含 `media_attributes_modified` 的 4 个参数）。

| 用例 | 耗时 | 步骤数 |
|---|---:|---:|
| `test_chat_offline_media_attributes_modified_after_recipient_relogin[×4]` | 11.0–13.5s | 27–31 |
| `test_chat_offline_mixed_backlog_local_state_after_recipient_login` | 12.7s | 68 |
| `test_chat_offline_custom_body_modified_after_recipient_relogin` | 11.2s | 27 |
| `test_chat_offline_sender_receives_reaction_remove_after_relogin` | 9.5s | 31 |
| `test_chat_offline_multiple_text_messages_and_unread_count` | 9.0s | 37 |
| `test_chat_offline_text_modified_before_first_recipient_login` | 7.4s | 29 |
| `test_chat_offline_sender_receives_reaction_add_after_relogin` | 7.2s | 27 |
| `test_chat_offline_recipient_receives_content_change_after_relogin` | 6.3s | 27 |

关键验证点：**11 个用例的 Allure 报告里非 passed 步骤总数为 0**，即 `quiet_evidence()` 生效，重试没有在报告中留下失败的中间步骤；操作步骤与校验步骤成对出现，报告结构与改造前一致。

## 阶段 4.3 / 4.6 / 4.7 ebs 抽样验证

按"每个模块抽几条"而不是跑全模块。命令：本机手工准备（bridge `ws_bridge_local.sh up` + 推 `config/ebs.yaml` 与改写端口后的 `bridge.yaml` + 拉起 App），再 `IM_TEST_CONFIG=config/ebs.yaml pytest -q <6 个 nodeid>`。

结果：**6 passed，43.45s**。覆盖面：

| 模块 | 抽样用例 | 覆盖的改造 |
|---|---|---|
| chat | `test_conversation_read_count_and_mark_read`、`test_conversation_latest_and_last_received_messages` | 标准形态 `assert_response_eventually` |
| group | `test_group_get_group_block_list_from_server_success`、`test_group_get_group_member_list_from_server_success`、`test_group_add_admin_and_remove_admin_success` | 标准形态 + `_fetch_group` 有界重试 |
| contact | `test_contact_remark_set_then_list_includes_remark` | 标准形态 |

站点总数变化：616 →（4.2 后）607 →（4.6 `_fetch_group`）582 →（4.3+4.7 标准形态）537 →（chatroom try 形态）**523**；其中 `read_probe` 从 155 降到 86。

## 阶段 4.4 / 4.7 / 6.x ebs 抽样验证

`IM_TEST_CONFIG=config/ebs.yaml pytest -q <13 条>`：**13 passed，33.39s**。覆盖：

| 抽样用例 | 覆盖的改造 |
|---|---|
| `test_combine_forward_media_inner_attachment_download` | 4.4 缩略图 30s 折进有界等待（该用例基线 44.8s） |
| `test_chat_send_to_self_event` | 6.2 `evt` 判空 |
| `test_chatroom_create_and_fetch_from_server` | 4.7 chatroom `pause + try` 形态 |
| `tests/presence/test_presence.py` | 4.7 presence 标准形态 |

另一轮：`test_chatroom_membership_checks.py` + `test_group_mute_members_role_permission_matrix` + `test_chatroom_lifecycle` 抽样 **8 passed，49.16s**（覆盖 chatroom 转换与 `_fetch_group` 有界重试）。

验证策略：按"每个模块抽几条"执行，不跑全模块。
- 本轮实测收益范围仅覆盖 drain（`ensure_friends` 每 case 中位 6.14s，其中 6.0s 是两台设备的固定 drain）与离线登录/登出 settle（每次重登循环 9s 中的 6s）；阶段 4 的 627 个 case 级 `pause()` 未改动，所以 31.7 分钟的 step 间空隙本轮**尚未**回收。
