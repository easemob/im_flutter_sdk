# 5.2.0 升级测试覆盖

- 日期：2026-11-25。
- 目标：`im_flutter_sdk/.worktree/5.2.0`，分支 `5.2.0`，基线 `d503710a`（平版代码已提交，工作区干净）。
- 阶段：CI 与单设备用例实施完成、静态与单测验证完成；设备执行因 worktree 无 `config.local.json` 凭据阻塞，待有凭据后按验证记录选测清单执行；多设备场景用户本轮已明确批准（1 个：发送多 body、接收多 body），用例文件已落地，执行同样待凭据与环境。
- 验证记录：[执行统计与问题表](2026-11-25-test-verification.md)。
- 范围说明：本轮只补用户指定的用例——CI/单设备各 2 个多 body 发送用例（文本、附件）、多设备 1 个收发用例；连接状态用户明确本轮不补。其余行为按「暂缓/不适用」如实记录缺口，不扩大范围。

## 输入核验

| 文件/章节 | 版本与实质内容核验 | 提取用途/冲突处理 |
|---|---|---|
| [01-api-diff.md](01-api-diff.md) | iOS 5.1.0→5.2.0、Android SDK_5.1.0→SDK_5.2.1；双端清单与未匹配清单齐备 | 全量输入；含 6 条未匹配清单（usePushInBackground、isConnected 废弃、连接枚举取值、复合消息入口形态、bodies 形态、isPushTokenBound） |
| [02-contract.md](02-contract.md) | Dart 自有 `ChatConnectionState`（connected=0/disconnected=1/connecting=2，两端显式映射）、多 body 契约（`bodies` 只读、`body` setter 语义、空列表抛 `ArgumentError`） | 定义预期；Dart 枚举不透传 native 整数值 |
| [03-implementation.md](03-implementation.md) | 各 ID 落点与未实施项（usePushInBackground/isPushTokenBound 未实施）明确 | 区分新 API 与行为变更 |
| [04-verification.md](04-verification.md) | 平版阶段 analyze/单测/双端构建证据齐备 | 历史证据只作背景，设备行为本轮才算 |
| [acceptance-report.md](acceptance-report.md) | 用户三项决策已回填：1) usePushInBackground/isPushTokenBound 不平板；2) isConnected 废弃口径维持；3) bodies 只读 getter 维持 | 不平板项进排除表；不重复索要决策 |

五份必需文档均存在且包含实质内容；无额外拆分清单需要追读。`contentType` 不在 `ChatMessage.toJson` 输出中，设备/脚本侧只能通过 `bodies` 数组与 `body`（首体）间接观测多 body 语义，覆盖表如实记录该限制。

## 既有组织方式与修改边界

- CI：业务断言放 `im_flutter_sdk/example/integration_test/modules/message_cases.dart` 既有 `registerMessageCases` 注册函数，由 `logged_in_base_test.dart` 承载（基础配置：会话同步开、群组/联系人同步关、用户资料关）。不修改五个稳定入口与共享初始化；FL-MSG-016/017 沿用模块内 `sendAndAwait`（关联 localId 等最终回调）与 FL-MSG-001 的好友前置/恢复模式。
- 单设备：沿用版本脚本组织，正向用例进入 `testing/single/cases/script_520_apis_positive.json`；本轮无明确逆向契约，不建 `script_520_apis_negative.json`（不猜测错误码），如实现 `ArgumentError` 路径的稳定错误表达可后续补。
- 多设备：沿用 `testing/multi/cases/` YAML/JSON 配对组织，新场景以引入版本冠名 `5.2.0-multi-message-multibody-positive`；只使用 example 已注册 API（`ChatManager.sendMessage` 已支持 `bodies`，平版阶段注册）。
- 现有能力限制：`contentType` 不可经 JSON 观测；断言语法 `equals/gte/notEmpty/containsItem/length` 支持点分列表下标（`bodies.0.type`），足够表达有序双体断言。
- 入口/架构改动授权：无。未改任何入口、workflow、运行脚本、执行器。

## 变更到用例的覆盖表

| 行为 ID | 来源变更 ID及文档章节 | Flutter 修改与预期（含平台） | 现有覆盖及缺口 | CI 动作/用例定位/理由 | 单设备动作/用例定位/理由 | 多设备候选及确认状态/理由 | 执行证据 |
|---|---|---|---|---|---|---|---|
| multibody-text-send | `msg_create_multibody`、`msg_init_with_bodies`、`msg_append_body`、`msg_get_bodies`/`msg_bodies`、`msg_type_multibody` | 双端：`createMultiBodySendMessage` 建两个文本体的消息，发送最终回调成功后服务器回写消息保持 bodies 有序（首元素即 body） | 平版阶段仅契约测试加了发送 JSON `bodies` 双键；无设备发送行为覆盖 | 新增 `modules/message_cases.dart` FL-MSG-016（`logged_in_base_test`）：好友前置后双文本体发送，断言最终回调 SUCCESS、回写消息 `bodies.length==2`、顺序与内容保持、`contentType==MULTIBODY`、本地 loadMessage 可读 | 新增 `script_520_apis_positive.json` / `send_multi_body_text`：`bodies` 双文本体发送，断言 `data.bodies` 长度 2 及两个 content | 见 multibody-receive 行，发送+接收一个流程 | 未执行/设备凭据缺失 |
| multibody-attachment-send | 同上行（附件体路径）；`chat_download_doc` 文档语义 | 双端：文本+文件体的复合消息，附件体经本地文件真实上传，最终回调后附件体带服务器 remotePath/secret | FL-MSG-011 只覆盖单附件消息；复合消息附件路径无覆盖 | 新增同模块 FL-MSG-017：文本+文件体（临时目录真实文件）发送，断言 SUCCESS、bodies 长度 2、文件体服务器字段（remotePath/secret/fileSize）存在且与本地一致 | 新增 `script_520_apis_positive.json` / `send_multi_body_attachment`：先 `TestUtil.writeBase64File` 造文件，再文本+文件体发送，断言 `bodies.1.type==5`、`bodies.1.remotePath` 非空 | 附件下载等接收侧行为沿用既有 FL-MSG-012/多设备 delivery，本轮不重复建设 | 未执行/设备凭据缺失 |
| multibody-receive | `msg_get_type_changed`、`msg_get_content_type`、`msg_body_type_multibody` | 双端：对端收到复合消息时，消息带完整有序 bodies（首元素即 body），多体时类型为 MULTIBODY | 无任何接收侧覆盖；`contentType` 不在 toJson，接收侧只能断言语义等价字段 | 不适用：发送端回调不能证明对端收到完整 bodies | 不适用：单客户端无法观察对端接收 | **已批准**（用户本轮指定）：`5.2.0-multi-message-multibody-positive`：alice 双文本体发送、bob `onMessagesReceived` 断言 msgId/from/to 及 `bodies.0/1` 的内容与顺序；复用既有登录/登出框架 | 未执行/账号与环境缺失 |
| body-replace-semantics | `msg_set_body_doc`、`msg_add_body_changed` | Dart `body` setter 语义为「替换首个消息体」（与 Android setBody 不同，文档已写明）；Dart 无 addBody 既有 API | 无行为用例；属存量行为变更，外部 diff 不显眼 | 暂缓（用户范围外）：如需覆盖，优先在 `im_flutter_sdk/test/` 加纯 Dart 单测锁 setter 语义，不依赖设备 | 暂缓同因 | 不适用：本地语义 | 未执行/本轮范围外 |
| connection-state | `client_connection_state`、`connection_state_enum`、`connection_state_connecting`、`client_is_connected_deprecated` | 双端 `getConnectionState` 返回三态；Dart 自有枚举两端显式映射；`isConnected` 废弃但可用 | 无行为用例；integration_test 调用点已迁移编译通过 | 暂缓（用户明确「不好测试」）：如需最低成本覆盖，可 mock 通道锁 int↔enum 映射契约，不证明真实连接迁移 | 暂缓同因 | 不适用：连接迁移不依赖对端客户端 | 未执行/用户决定本轮不补 |
| disconnect-notify-threshold | `option_disconnect_notify_threshold` | 双端 options 字段，默认 10，≤0 关闭延迟；真实「断开宽限通知」行为需制造断连抖动 | 无覆盖 | 暂缓：无明确可观察契约与可控断连手段，不猜测；options 序列化可离线补但不等价于行为 | 暂缓同因 | 不适用 | 未执行/契约与手段缺失 |
| supp-bodies-contract | 平版阶段 `chat_message_send_contract_test.dart` 扩展 | 发送通道 JSON 同时携带 `body` 与有序 `bodies` | 平版阶段已改契约测试并随 76 单测通过 | 复用：契约测试已断言双键，无需新增 | 不适用：纯编解码 | 不适用 | 平版 04-verification 单测全绿（历史证据，本轮见验证记录） |

## 不纳入实施的变更

| 变更 ID | 升级决策 | 本次结论及证据 |
|---|---|---|
| `option_use_push_in_background` | 待决策 1 → 用户决定不平板 | 不适用：未暴露公共 API，无 Flutter 行为；含 `isPushTokenBound`（diff 范围外发现，同一决策） |
| `msg_set_bodies` | 待决策 3 → 用户决定收窄为只读 getter | 不适用：Dart 有意不暴露 setBodies（验收报告待决策 3） |
| `option_userinfo_doc_trim` | skip | 不适用：Flutter 侧无该段说明，doc-only 删减 |
| `version_5_2_1` | n/a（依赖 bump） | 不适用：构建解析版本已由平版阶段 Android APK / iOS 双构建实证 |
| `option_chatroom_conversation_doc`、`chat_download_doc`、`msg_set_body_doc`（文档部分） | include（同步注释/doc-only） | 不适用：仅文档语义修订，无公开签名变化；多 body 语义的行为覆盖见 multibody-* 各行 |

## 最小场景与平台选择

| 场景/用例 ID | 目标与覆盖层次 | 角色/在线客户端 | 前置→操作→核心断言 | 清理 | 分类及理由 | 首测平台/设备组合及理由 | 另一端补测条件/未选测范围 |
|---|---|---|---|---|---|---|---|
| FL-MSG-016 | 业务流程：复合消息（双文本体）发送与回写 | 发送端在线；对端为离线好友（REST 准备好友关系） | 解除双向拉黑+加好友→双文本体 `createMultiBodySendMessage`→sendMessage 并关联 localId 等最终回调→断言 SUCCESS、`bodies.length==2`、顺序内容、`contentType==MULTIBODY`、loadMessage 回读一致 | 恢复好友关系与双向拉黑原状；不删对端会话历史（沿用 FL-MSG-001 口径） | CI：依赖服务器回写与本地库 | Android（首个用例选 Android；iOS 仅当出现跨端差异或用户要求时补测） | iOS 未选，不计通过 |
| FL-MSG-017 | 业务流程：复合消息（文本+文件体）附件上传 | 同上 | 同前置→临时目录写真实文件→文本+文件体发送→断言 SUCCESS、bodies 长度 2、文件体 remotePath/secret/fileSize 与本地一致、loadMessage 回读一致 | 同上行；临时目录 addTearDown 删除 | CI：附件上传依赖 native 真实传输 | iOS（与 016 交叉分配；附件栈两端实现不同，交叉选端） | Android 未选，不计通过 |
| send_multi_body_text | 字段契约+业务流程：脚本侧双文本体发送 | 单客户端 | init（显式 dataSyncType=6 等）→`ChatManager.sendMessage`（bodies 双文本体）→断言 success、`data.bodies` 长度 2、两 content | 无服务端资源创建 | 单设备：一个客户端可完成 | Android | iOS 未选 |
| send_multi_body_attachment | 字段契约+业务流程：脚本侧文本+附件体发送 | 单客户端 | `TestUtil.writeBase64File` 造文件→发送→断言 `bodies.1.type==5`、`bodies.1.remotePath` 非空 | 脚本资源由工具目录管理 | 单设备 | Android | iOS 未选 |
| 5.2.0-multi-message-multibody | 业务流程：复合消息对端接收完整 bodies | alice（发送）、bob（接收）双客户端双账号 | 双端 init+login+connected→alice `sendMessage`（bodies 双文本体）→bob `wait_event onMessagesReceived` 断言 msgId/from/to 及 `bodies.0.content`/`bodies.1.content` 顺序内容→双端 logout | 无服务端资源创建；logout 收尾 | 多设备：核心断言必须对端在线 | Android alice → iOS bob（最小跨端组合；不遍历全组合） | 同端组合未选，不计通过 |

## 完整性核对

- 原始变更：01-api-diff 双端清单去重后 25 个 ID（client/chat/push 三类，含 iOS-only 与 Android-only 条目）；include 为主，`option_userinfo_doc_trim` skip，`version_5_2_1` n/a，`option_use_push_in_background` 待决策（已由用户裁决不平板）。
- 追加变更：无 `supp-*`（本轮没有验收报告追加变更需要补录；`supp-bodies-contract` 行为行来源是平版阶段契约测试扩展，属已有覆盖登记）。
- 行为行：7（multibody-text-send、multibody-attachment-send、multibody-receive、body-replace-semantics、connection-state、disconnect-notify-threshold、supp-bodies-contract）；不是用例数也不是通过数。
- 未关联至行为行或排除行的原始 ID：无（排除表 5 项覆盖其余）。
- 文档冲突：无；`contentType` 不可 JSON 观测的限制已记录并体现在断言设计上。
- 实际 diff 范围核查：本轮改动仅限 `message_cases.dart`（模块内追加两个用例）、`native-case-mapping.json`（两条登记）、`testing/single/cases/script_520_apis_positive.json`（新增）、`testing/multi/cases/5.2.0-multi-message-multibody-positive.{yaml,json}`（新增）及本文档/验证记录；未触碰任何设备入口、workflow、运行脚本、共享初始化。

## 多设备第二轮确认

- CI/单设备执行状态：用例实现完成；静态检查（analyze/format）与离线单测通过；设备执行因 worktree 缺 `im_flutter_sdk/example/config.local.json`（应用凭据与测试账号）阻塞，待用户提供凭据后按验证记录选测清单执行。
- 候选场景：**1 个，用户本轮已明确指定**（「多设备协同补充一个：发送多body，接收多body」），无需再确认。核心断言：bob 收到 alice 的复合消息后 `bodies` 数组完整有序（双文本体内容与顺序），msgId/from/to 关联本轮发送。已按确认范围实施用例文件；执行同样待凭据与环境（im-test-orchestrator + 双模拟器）。
