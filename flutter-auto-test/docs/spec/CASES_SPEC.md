> [已退役/仅供参考] 本文档不再作为权威规范，请转到：docs/agents/AGENTS.zh.md
---
name: im-sdk-ws-cases-spec
version: 1.0
applies_to: all modules (Client, Contact, Chat, Group, ChatRoom, Presence, Push, UserInfo, Conversation, Thread)
source_of_truth: Dart managers/handlers/models under im_flutter_sdk/lib/src
style_reference: tests/test_contact.py
---

# IM SDK WebSocket 自动化用例规范（通用）

本文档为仓库内**唯一详版**用例规范。

## 目标
- 仅改本仓库（cases/harness）；**不修改被测端**。
- 所有 `tests/` 下用例在“命名、结构、断言、调试开关位置”上统一，覆盖**正常**与**异常/边界**两类。
- 所有请求 `manager/cmd/info` 与 Dart 源严格对齐；事件名与 Dart handler 对齐。

## Dart 与 Python 侧映射（编写前必读）

默认 Flutter 源码根路径可按本机调整，例如：

`im_flutter_sdk/im_flutter_sdk/lib/src`

| Dart | 用途 | Python |
|------|------|--------|
| `managers/*.dart` | 对外 API（方法名、参数） | `Cmd`（`src/sdk_api/cmd_keys.py`，源 `internal/chat_method_keys.dart`）；请求里 `manager` 为类名、`cmd` 为方法 key、`info` 为参数字典 |
| `handlers/*.dart` | 回调 / 事件 | `src/sdk_api/event_keys.py`（源 `internal/em_event_keys.dart`）；推送 `type=event` 时用 `match_event_type=...` |
| `models/*.dart` | 数据结构 | 构造 `info`、`assert_response_matches` 的 `expected` 时字段名与之一致 |

新增 API：先在 Dart 确认 `manager`/`cmd`/`info`，再补枚举，**字符串与 Dart 一致**。

## pytest 与模块标记

- 用例文件：`tests/test_<模块>.py`（模块小写，与 `*_manager.dart` 对应）。
- 收集：函数名 `test_*`；模块级 `pytestmark = [pytest.mark.client, pytest.mark.<领域>]`（markers 见 `pytest.ini` / `conftest.py`）。

## 拓扑与连接
- 双设备：
  - deviceA → topic=adc（Android，被 Cursor 启动）
  - deviceB → topic=adc01（iOS，被 Xcode 启动）
- WebSocket 基础配置：见 `config.yaml.websocket`（base_url、default_topic、topics）。
- 测试层使用：
  - `DeviceConnection`（单连接双工）：同一连接上发请求和收回调，避免漏回调。
  - `MessageListener`（纯被动监听）：仅用于嗅探，不参与断言。

## 案例文件命名
- `tests/test_<模块>.py`（模块小写，对应 Dart `<Module>Manager`）。
- 建议结构：
  - `tests/test_<模块>.py`（同一文件内分区：正常路径小链路 + 异常与边界）
  - 嗅探工具：`tests/test_ws_sniff.py`（仅打印，不断言)

## Fixture 约定
- 统一使用 `tests/conftest.py` 的：`device_a`、`device_b`、`assert_api`、`user_a`、`user_b`。
- Session 级登录/登出、用户创建/清理、好友前置等由 Fixture 负责；用例里不重复登录/登出。
- **调用**：`device_x.call("ManagerName", Cmd.xxx.value, info={...})`；**收事件**：`device_x.receive_message(match_event_type=..., timeout=...)`。
- **`user_a` / `user_b`**：session 内 REST 创建，勿写死固定账号；登录/登出勿写在用例内（由 `global_login_logout` 等统一处理）。

## 断言策略（强制）
- 禁止“自证式 result 断言”：不要在 expected 中写 `result: resp.get("result")` 或同义写法；这会让预期与实际在 result 上完全一致，无法发现“多出/缺失/错误值”。应改为断言 `manager/cmd/device` 等信封字段 + 具有业务意义的 `result` 关键字段，或断言类型/长度/条件，并将不稳定字段放入 `ignore_keys`；必要时先用发现模式观察后再冻结明确形状。
- 成功：优先 **`assert_api.assert_response_matches(resp, expected=..., context=..., ignore_keys=...)`**，对 `manager`、`cmd`、`device`、`result` 等做完整声明；`device` 等可用 `{{key}}` 从 `context` 注入（与 `tests/test_contact.py` 一致）。
- 失败：`assert_api.assert_error(resp, code=?, description=?)` 优先；错误体固定时可用 `assert_response_matches`。
- **避免**：能用 `assert_response_matches` 的成功路径不要先用 `assert_success` 再手写零散 `assert`；异常路径不要用 `assert_response_matches`“冒充”成功（除非错误体为固定 JSON）。
- 事件：`device_x.receive_message(match_event_type=..., timeout=...)`；`ignore_keys` 常含 `timestamp`、`sequence`、`data`。

## Chat 专项规则（已落地并通过，2026-04-01）
- 最小忽略集：
  - 同步响应（`resp`）：仅忽略 `sequence`；不得忽略 `result`、`error`（亦不得忽略 `result.cursor`）。
  - 事件（`type=event`）：可忽略时间/本地时钟类键（如 `timestamp/serverTime/localTime`）与 `sequence`，其余字段严格匹配。
- 去除自证式与条件门：
  - 禁止在 expected 中引用 actual 的 `result`（自证式）。
  - 不写 `if evt is not None:` 等门控；必须收到预期事件，否则用例失败。
- 统一错误码/文案（按实际返回锁定）：
  - `ackConversationRead`（invalid conversationId）：`result = {"code": 500, "description": "Message is invalid"}`。
  - `modifyMessage`（invalid msgId）：`result = {"code": 500, "description": "Message is invalid"}`。
  - `recallMessage`（invalid msgId）：`result = {"code": 500, "description": "The message was not found"}`。
  - `addReaction`（invalid msgId）：`result = {"code": 303, "description": "msgbody is not_found"}`。
  - `addReaction`（空 reaction）：`result = {"code": 110, "description": "'reaction' can not be null"}`。
  - `pinConversation`：当前实现对不存在或未建立会话返回错误，断言 `error code=107, description="Invalid conversation"`，并停止后续步骤。
- 自发消息（send A→A）：
  - 严格断言 `onMessageSuccess.data`（包含 `msgId/from/to/convId/body/chatType/status/hasRead…`）。
  - 严格断言发送响应 `result`（不忽略 `result`），仅忽略 `sequence` 与少量易变键（如 `serverTime/localTime`）。
- 唯一真实返回断言（锁定单一预期，不再分支判断）：
  - `getMessage`（invalid msgId）：`result = None`。
  - `fetchHistoryMessages`（invalid conversationId）：`result = {"code": 205, "description": "Invalid parameter"}`。
  - 以上两例来源于 `WS_DEBUG/WS_RELAX` 发现阶段的实际返回；一旦锁定，恢复严格断言且用例中不保留任何调试分支或打印。

## 覆盖维度（每个 API 至少包含）
- 1 条正常用例（Happy Path）。
- 1 类异常/边界（非法参数/不存在实体/越界分页/权限不足等）。
- 对同一 `cmd`（或紧密相关接口）在文件内用**分区注释**组织（见 `test_contact.py`）。
- 多步重复流程才抽到 `src/test_flow/...`；单步 API 不强制封装。

## 联系人模块覆盖示例（对齐 `tests/test_contact.py`）

| 类型 | 内容 | 断言 |
|------|------|------|
| 正常 | 主流程成功、`result` 形状与业务一致 | `assert_response_matches`（必要时先 `receive_message` 再断言） |
| 边界/异常 | 非法参数、不存在用户、非好友、越界分页等 | 优先 `assert_error`；固定错误体可用 `assert_response_matches` |

要点举例：`addContact`（不存在用户、空 userId、加自己）；`deleteContact`（非好友）；`acceptInvitation` / `declineInvitation`；`setContactRemark` / `getContact`；`fetchContacts` 的 `pageSize` 非法；黑名单与 `getBlockListFromServer`。常量（如 `USER_NONEXISTENT`、边界长度）放在**模块顶部**。

## 多步流程封装（`src/test_flow/model_test_flow.py`）

- **何时封装**：同一测试中**多次重复**的多步操作（如加好友→同意；拉黑→查列表→取消拉黑），抽到 `model_test_flow`（如 `ContactTestFlow`）。
- **何时不封装**：单接口单次 `call` 的用例不要强行封装；直接 `device_x.call` + `assert_response_matches` / `assert_error`。
- **约定**：flow 可只持有 `assert_api`；`device` 在方法参数传入，不绑死 `device_a`。

## 正常 / 异常用例模式（补充）

- **场景**：模块与每个 `test_*` 的 docstring 写清步骤与期望。
- **双端**：`device_a`/`device_b` 与 `user_a`/`user_b`；单端只注入一端。
- **回调**：需要时 `receive_message`，再对 `resp` 做 `assert_response_matches`；`ignore_keys` 常含 `timestamp`、`sequence`。
- **条件匹配**：`src/tools/response_match.py` 与占位符规则；难固定字段可用导出的比较辅助（见 `response_match` / 项目惯例）。
- **错误**：`assert_error`；固定码/文案用 `code` / `description`；边界数据常量放模块顶部。

## 参考文件（本仓库）

| 用途 | 文件 |
|------|------|
| 联系人：分区 + 断言风格 | `tests/test_contact.py` |
| 异常 + 边界 | `tests/test_presence.py` |
| 多步联系人流程 | `src/test_flow/model_test_flow.py` |
| Fixture | `tests/conftest.py` |
| Cmd / 事件 | `src/sdk_api/cmd_keys.py`、`src/sdk_api/event_keys.py` |
| JSON 比对 | `src/tools/response_match.py` |

## 调试开关（仅限 WS 层）
- 原则：**用例文件里不出现任何调试开关**。
- 开关位置：`src/tools/ws_client.py` 接收层。
  - `dump_events`（打印所有 WS JSON）
  - `relax_event_match`（仅用于嗅探：忽略 eventType 过滤，接收第一条事件）
- 配置方法：
  - 环境变量：`WS_DEBUG=1` 开 `dump_events`；`WS_RELAX=1` 开 `relax_event_match`。
  - 或 `config.yaml.websocket.debug`：
    ```yaml
    websocket:
      debug:
        dump_events: false
        relax_event_match: false
        sniff_seconds: 15
    ```

## Chat 附录（消息 JSON 形状，对齐 MessageHelper.fromJson）
- 文本消息（单聊）最小可用 + 推荐默认：
  ```json
  {
    "from": "<userA>",
    "to": "<userB>",
    "chatType": 0,
    "direction": 0,
    "status": 0,
    "body": { "type": 0, "content": "hello" },
    "hasReadAck": false,
    "needGroupAck": false,
    "isThread": false,
    "deliverOnlineOnly": false,
    "localTime": 1700000000000,
    "msgId": "py-<uuid>"
  }
  ```
- 群/聊天室：仅将 `chatType` 改为 1/2，`to` 为群/聊天室 ID。
- 事件名：`onMessageSuccess`、`onMessagesReceived`、`onConversationHasRead`、`onMessagesRead`、`onMessagesRecalled`、`onMessageContentChanged`、`messageReactionDidChange`、`onGroupMessageRead`（或 `onReadAckForGroupMessageUpdated`）。

## 模块速查（原 speckit 合并）

### Chat 单聊（Single Chat）
- 入参最小结构：
  - `from`, `to`, `chatType=0`, `direction=0`
  - `body: {type:0, content}`
  - 建议默认：`hasReadAck=false, needGroupAck=false, isThread=false, deliverOnlineOnly=false`
- 关键事件：
  - `onMessageSuccess`（A 端：`data.msgId` 临时；`data.msg.msgId` 服务端真实）
  - `onMessagesReceived`（B 端）
- 断言要点：
  - A: `msg.convId == to`；B: `messages[i].convId == from`
  - 事件信封：`type="event"` + `eventType`
- 典型用例：
  - A→B 文本发送并接收
  - 翻译链路：`getMessage` → `translateMessage`（按可用语言断言 `body.translations`）
  - 异常：无效消息 ID、无效会话、边界文本

### Chat 群聊（Group Chat）
- 入参：
  - `chatType=1`，`to` 为群 ID，其余字段与单聊一致
- 关键事件：
  - `onMessagesReceived`（群成员）
  - `onGroupMessageRead` / `onReadAckForGroupMessageUpdated`（按端实现）
- 典型用例：
  - 发群消息 → 群成员收到
  - 群读回执事件
  - 异常：不存在群、历史拉取非法分页

### Contact 好友（Friend）
- 目标：
  - 建立/解除好友关系与黑名单链路；作为消息场景前置
- 典型用例：
  - A 加 B → B 收邀请 → B 接受 → 双端好友列表校验
  - 删除好友、拉黑/取消拉黑
  - 异常：不存在用户、重复添加、非法参数
- 断言风格：
  - 成功用 `assert_response_matches`
  - 失败用 `assert_error`
  - 事件严格匹配 `eventType`

## 运行范式
- 正常场景：
  - `pytest -q tests/test_<模块>.py -s`
  - 单条：`pytest -q tests/test_<模块>.py::test_xxx -s`
- 异常场景：
  - `pytest -q tests/test_<模块>.py -s`
- 嗅探：
  - `pytest -q tests/test_ws_sniff.py -s`（可 `SNIFF_SECS=30` 覆盖时长）
- 打开低噪音调试：
  - `WS_DEBUG=1 pytest -q tests/test_<模块>.py -s`
  - `WS_RELAX=1 pytest -q tests/test_ws_sniff.py -s`

## 发现 → 严格（Discovery → Strict）工作流
- 目标：首跑未知返回时不失败，用真实返回补齐断言模板，然后切回严格模式稳定执行。
- 开关：设置环境变量 `CASES_DISCOVER=1` 后，`assert_response_matches`/`assert_error` 只打印对比结果，不抛错。
- 推荐步骤（以 Chat 的 send/receive 为例）：
  1) `CASES_DISCOVER=1 WS_DEBUG=1 pytest -q tests/test_chat.py::test_chat_send_and_received -s`
  2) 观察控制台/Allure 中的“预期/实际/差异”，据实调整断言模板（优先使用 `assert_response_matches`）。
  3) 关闭发现模式：`pytest -q tests/test_chat.py::test_chat_send_and_received -s`，确保严格通过。

## Chat 事件断言要点（ConvId 语义 + 默认字段）
- 会话 ID（convId）语义：
  - 发送端（A）在 `onMessageSuccess` 回调中的 `msg.convId == to（接收人，B）`。
  - 接收端（B）在 `onMessagesReceived` 回调中的 `messages[i].convId == from（发送人，A）`。
- 文本消息默认字段建议纳入断言（按实际返回为准）：
  - `hasRead`, `hasReadAck=false`, `hasDeliverAck=false`, `needGroupAck=false`, `deliverOnlineOnly=false`, `isThread=false`, `isContentReplaced=false`
  - `body.translations={}`（未触发翻译时）

## 编写检查清单（通用）
- [ ] 禁止自证式 result 断言（expected 不得直接引用 actual 的 result）
- [ ] Dart managers/handlers/models 已核对；`Cmd`/事件键已存在或补充。
- [ ] `info` 字段名与类型对齐 Dart；必要默认值已给出（尤其 Chat）。
- [ ] 至少 1 正常 + 1 异常；异常路径用 `assert_error`。
- [ ] 事件断言使用 `match_event_type`；`ignore_keys` 合理。
- [ ] 不在用例里出现调试开关；只在 WS 层读取 `WS_DEBUG/WS_RELAX`。
- [ ] 多步重复逻辑评估是否进入 `src/test_flow/`。
- [ ] 未在用例中重复 login/logout。

## 一致性与参考
- 代码与断言风格以 **`tests/test_contact.py`** 为准。
- **配置**：`config.yaml`；敏感 token 使用环境变量 `REST_AUTH_TOKEN`。
- **与 Flutter demo**：`topics` 等需与 demo 一致，否则多端用例不稳定。
- 若被测端返回 `MissingPluginException` 等桥接异常：**直接暴露**为失败（属被测端问题），不要在用例里规避。
> 重要：本文件已退役（仅供参考）。唯一权威规范请查看：`docs/agents/AGENTS.zh.md`。
