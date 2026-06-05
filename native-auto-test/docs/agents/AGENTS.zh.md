# 案例编写与执行总规范（cases 端，中文唯一版）

本仓库用于 Flutter API 自动化测试（Android/iOS）。cases 端通过 WebSocket 与 Flutter 集成端通讯；必要时可调用 REST API 做账号/数据前置或校验。为避免“spec / skills”分散，现合并为一份中文规范，作为唯一权威：本文件。

— 适用范围
- 通讯以 WebSocket 为主；REST 仅用于前置/清理/核验且需记录。

— 目录与约束
- 文档：`docs/`。本文件为唯一 Agent 规范；`docs/spec/*` 作为执行与速查规范参考。
- 用例：仅放 `tests/`；严禁在 tests/ 内写文档或调试开关。
- 技能：仓库本地 `skills/`；全局技能 `$CODEX_HOME/skills`；严禁在仓库创建 `.agents/`。
- 统一使用 `Makefile` 命令（`make help` 查看）。

— 对齐源（Source of Truth）
- Dart 与 Python 侧映射，默认 Flutter 源码根路径可按本机调整，例如： im_flutter_sdk/im_flutter_sdk/lib/src
- Dart	用途	Python
- managers/*.dart	对外 API（方法名、参数）	Cmd（src/sdk_api/cmd_keys.py，源 internal/chat_method_keys.dart）；请求里 manager 为类名、cmd 为方法 key、info 为参数字典
- handlers/*.dart	回调 / 事件	src/sdk_api/event_keys.py（源 internal/em_event_keys.dart）；推送 type=event 时用 match_event_type=...
- models/*.dart	数据结构	构造 info、assert_response_matches 的 expected 时字段名与之一致
- 新增 API：先在 Dart 确认 manager/cmd/info，再补枚举，字符串与 Dart 一致。
- 先依据Flutter 源码确认对应模块的manager、handler和model，再在Python端补齐方法/事件键。再编写用例时，严格按照Dart模型构造请求参数和预期结果，确保字段名、类型和默认值一致。
- 方法/事件键：`src/sdk_api/cmd_keys.py`、`src/sdk_api/event_keys.py`。
- 断言工具：`src/tools/assertions.py`、`src/tools/response_match.py`（支持 `eq/ne/gt/...` 与最小忽略集）。

— 编写流程（Discovery → Tighten → Strict）
1) 规划：每个 API 至少 1 条正常 + 1 条错误/边界；明确事件与关键业务字段。
   - 参数覆盖原则：每个 API 的 case 设计需覆盖该 API 的参数维度；对每个参数至少覆盖“有效值 + 无效/边界值”中的一个或多个场景。对于对象参数（如 `options`），其子字段也必须按参数维度拆解覆盖。
   - 先输出“待补充用例清单”（按 API 列出正常/异常项），默认可直接进入实现，无需逐条人工确认。
   - 仅在新增模块/语义不明确/返回不稳定时，再升级为“先确认后实现”。
   - 采用两阶段执行：阶段 1（清单确认）→ 阶段 2（编写测试用例方法）。
2) 对齐：请求 `manager/cmd/info` 字段名/类型/默认值与 Dart 模型一致。
3) 实现：把用例放入 `tests/<domain>/test_<topic>.py`；仅使用 fixtures（`device_a/device_b/assert_api/user_a/user_b`）。
4) 断言：
   - 成功：优先 `assert_api.assert_response_matches`（声明 `manager/cmd/device` 与关键 `result` 字段，manager/cmd/device 在断言实际体里因为是已知的，所以固定写死）。禁止ne(None)，除非返回的就是空值。
   - 失败：优先 `assert_api.assert_error(code=?, description=?)` 或固定错误体模板。
   - 直接对结果进行断言，严格采用一种断言方式，要么成功否则失败。
   - 禁止裸写 `assert_error(resp)`；必须带 `code` 与 `description`（或用固定错误体 `assert_response_matches` 冻结错误结构）。
   - 禁止自证式 result 断言（expected 不得直接引用 actual 的 result）。
   - 禁止仅用弱语义断言作为主断言（如仅 `assert isinstance(result, dict)` / `assert result is not None`）。
   - 允许在主断言后追加补充断言（如包含关系、跨事件 ID 关联）。
   - 事件监听验证仅放在“正常 cmd”用例中；异常用例不以事件回调作为通过条件。
   - 事件主断言需直接对 `receive_message(...)` 返回结果使用 `assert_api.assert_response_matches`；禁止先取值再重组对象（如 `evt_compact`）后断言。
   - 最小忽略：同步响应以 `sequence` 为基线；若存在明确不稳定字段（如时间戳、动态 id、动态 url、端侧漂移辅助字段），可按 case 白名单最小补充。事件可忽略时间类（`timestamp/serverTime/localTime`）与 `sequence`，其他不稳定字段同样需“白名单+最小化”。
   - 分页接口：按实际返回冻结 `result.cursor` 与 `result.list`。若当前 case 实际 `cursor=""`，禁止再写“取下一页”代码；仅当实际 `cursor` 非空时，才允许使用该 `cursor` 请求下一页并继续严格断言。
   - 分页接口禁止宽松条件：禁止 `list: ne(None)`、`cursor: ne(None)`、`ge/gt/lt` 等用于替代真实结果冻结。
   - 发送后查列表（最终一致性场景）：允许在 case 内使用固定短暂停留（如 `sleep(1~2s)`）后再拉取列表；停留后仍须做收紧断言，禁止用宽松断言替代。
   - 必测 API 原则：凡纳入“验证通过”的 API，用例主断言必须是收紧断言（冻结关键结果结构与值）；不得仅做 envelope、类型或存在性断言。
   - 本文件所有断言规则以本条为唯一准绳；其他段落若有冲突，以本条为准。
5) 首跑（发现模式）：`CASES_DISCOVER=1 WS_DEBUG=1 pytest -q <path>::<case> -s`，根据“预期/实际/差异”补齐稳定字段、收窄 `ignore_keys`。
6) 收紧：冻结稳定错误码/文案，减少条件/范围断言。
7) 严格：关闭发现模式，默认仅回归“本次修改影响的用例/文件”（`pytest -q <path>::<case> -s` 或 `pytest -q <path> -s`）；仅在用户明确要求时再跑全量 `pytest -q tests -s`。
8) 代码审查（回归后强制门禁）：
   - 目标：cases 回归通过后，必须逐条检查断言是否严格符合“4) 断言”。
   - 审查项（必须全部满足）：
     - 成功主断言使用 `assert_api.assert_response_matches`，且声明 `manager/cmd/device` 与关键 `result`。禁止ne(None)，除非返回的就是空值。
     - 失败主断言使用 `assert_api.assert_error` 或固定错误体 `assert_response_matches`。
     - 直接对结果进行断言，严格采用一种断言方式，要么成功否则失败。
     - 禁止裸 `assert_error(resp)`；`assert_error` 必须声明 `code` 与 `description`。
     - 禁止自证式 result（expected 中不得引用 actual/result 临时变量作为主断言）。
     - 禁止弱语义主断言（仅 `isinstance`/`is not None`/`assert True`）。
     - 分页 case 禁止宽松断言（如 `list: ne(None)`）；必须按实际冻结 `cursor/list`，并遵守“`cursor` 为空不翻页，非空才翻页”。
     - 必测 API 的主断言必须收紧；仅 envelope/类型断言视为审查不通过。
     - 禁止把 `result` / `error` 放入 `ignore_keys`；忽略集保持最小化。
     - 事件主断言必须直接断言原始事件响应（`receive_message(...)` 返回值），不得重组后再断言。
     - 事件断言仅在正常 cmd 用例中；异常用例不以事件作为通过条件。
   - 结论：审查未通过不得结束该批次；需先修正再回归。
9) Chat 批次补充：
   - 仅对“可稳定返回”的异常参数做 strict 断言；会导致挂起/超时的组合不纳入 strict 批次。
   - `message` 对象入参类 API（如 `updateChatMessage`、`importMessages`）可按阶段暂缓，但需在批次说明中标注“暂缓原因”。
   - 异常 case 设计优先按 API 业务语义定制。
   - 默认覆盖维度（按接口适配）：不存在（可用无效 ID 触发）、枚举越界、长度边界、特殊字符、空字符串、状态/幂等语义。
   - 不再默认新增以下异常类型：必填缺失、类型不匹配（参数类型错误）；仅在用户专项要求时才补。
10) 模块 case 约束（按模块落地到同一流程）：
   - Chat：
     - 文本消息参数按 MessageHelper.fromJson 最小对齐：`from/to/chatType/direction/body{type,content}`，推荐默认：`hasReadAck=false, needGroupAck=false, isThread=false, deliverOnlineOnly=false`。
     - 常用链路：发送并接收（A→B 文本，A 收 `onMessageSuccess`，B 收 `onMessagesReceived`）；翻译（`getMessage`→`translateMessage`）；置顶（`pinConversation`）；异常语义（会话/消息不存在、空字符串、长度边界、特殊字符）。
     - 错误码基线（已冻结）：`ackConversationRead` 无效会话 `500/Message is invalid`；`modifyMessage` 无效消息 `500/Message is invalid`；`recallMessage` 无效消息 `500/The message was not found`；`addReaction` 无效消息 `303/msgbody is not_found`；`addReaction` 空 reaction `110/'reaction' can not be null`；`pinConversation` 无效会话 `107/Invalid conversation`；若能力未启用可返回 `505/Service is not enabled`，需就地断言并终止依赖步骤。
   - Contact：
     - 链路：A 调 `addContact` → B 收 `onContactInvited` → B 调 `acceptInvitation` → 双端 `onContactAdded`。
     - 边界：添加不存在用户、加自己、非好友删除、黑名单增删查；按第 4 条断言规则执行。

— 模块 Case 记录（按模块维护，不在本文件展开）
- 目的：按 API 维度持续记录模块 case 覆盖与暂缓项，后续迭代直接按模块台账推进，不再先读代码反查。
- 维护规则：
  - 每个模块固定 2 个文件：
    - `CASES_RECORD.zh.md`：总记录（按 API 分组，必须写明同一 API 的“正常 cases / 异常 cases”）。
    - `CASES_DEFERRED.zh.md`：暂缓实现清单（按 API 分组，写明暂缓原因、前置条件、恢复条件）。
  - 禁止使用日期命名的记录文件；历史日期文件可迁移后删除。
  - 每次新增/调整/暂缓某模块用例后，必须同步更新上述两个文件之一或全部。
  - `CASES_RECORD.zh.md` 记录通过情况与已覆盖用例；`CASES_DEFERRED.zh.md` 仅记录暂缓/skip/环境阻塞项。
- 模块入口：
- Chat：`docs/agents/chat/CASES_RECORD.zh.md` + `docs/agents/chat/CASES_DEFERRED.zh.md`
- Contact：`docs/agents/contact/CASES_RECORD.zh.md` + `docs/agents/contact/CASES_DEFERRED.zh.md`
- Group：`docs/agents/group/CASES_RECORD.zh.md` + `docs/agents/group/CASES_DEFERRED.zh.md`
- ChatRoom：`docs/agents/chatroom/CASES_RECORD.zh.md` + `docs/agents/chatroom/CASES_DEFERRED.zh.md`
- Presence：`docs/agents/presence/CASES_RECORD.zh.md` + `docs/agents/presence/CASES_DEFERRED.zh.md`
- Client：`docs/agents/client/CASES_RECORD.zh.md` + `docs/agents/client/CASES_DEFERRED.zh.md`
- UserInfo：`docs/agents/user_info/CASES_RECORD.zh.md` + `docs/agents/user_info/CASES_DEFERRED.zh.md`
- Sniff：`docs/agents/sniff/CASES_RECORD.zh.md` + `docs/agents/sniff/CASES_DEFERRED.zh.md`
- 新增模块：在 `docs/agents/<module>/` 下按上述固定双文件创建并维护。

— 事件与语义（强制）
- 事件统一断言 `type="event"` + `eventType`，并校验 `data` 关键字段。
- Chat 会话语义：
  - 发送端：`onMessageSuccess.data.msg.convId == to`。
  - 接收端：`onMessagesReceived.data.messages[i].convId == from`。

— WebSocket vs REST
- WS：覆盖主链路（发送/接收/翻译/撤回/置顶/反应等）。
- REST：仅用于账号/环境前置或必要结果校验。敏感信息用环境变量，记录接口与参数。

— 被测端 SDK Options 约束（新增）
- 若某个功能点在 docs/实现中依赖被测端 SDK options（开关）才能生效，编写/执行该 case 前必须先通知你确认。
- 当前测试基线：仅覆盖 options=`true` 的路径，`false` 路径暂不纳入本轮 case 范围（除非你明确要求）。
- 当前已知基线开关（被测端）：
  - `autoAcceptGroupInvitation: true`
  - `acceptInvitationAlways: true`
  - `requireAck: true`
  - `requireDeliveryAck: true`
  - `deleteMessagesAsExitGroup: true`
  - `deleteMessagesAsExitChatRoom: true`
  - `isChatRoomOwnerLeaveAllowed: true`

— 常用命令
- 单例发现：`CASES_DISCOVER=1 WS_DEBUG=1 pytest -q tests/<domain>/test_<topic>.py::test_<name> -s`
- 变更回归（默认）：`pytest -q tests/<domain>/test_<topic>.py::test_<name> -s` 或 `pytest -q tests/<domain>/test_<topic>.py -s`
- 模块严格（按需）：`pytest -q tests/<domain>/test_<topic>.py -s`
- 全量：`pytest -q tests -s`

— 作者检查清单
- [ ] Manager/Cmd/info 与 Dart 模型一致；字段大小写/取值正确。
- [ ] 至少 1 正常 + 1 错误/边界；错误优先 assert_error。
- [ ] 无裸 `assert_error(resp)`；错误断言已冻结到 `code/description` 或固定错误体。
- [ ] 断言 envelope + 关键业务字段；忽略集最小；无自证式断言。
- [ ] 发现模式跑过并据实收紧；严格模式通过。
- [ ] 仅回归本次修改影响的用例；未做不必要全量回归。
- [ ] 回归后完成“代码审查门禁”，且 4) 断言审查项全部通过。
- [ ] 更新对应模块记录文件（`CASES_RECORD.zh.md` / `CASES_DEFERRED.zh.md`）。
