# CI 基础 API 逆向用例

日期：2026-11-07。基线：`testing` / `1b3b46a4`。

依据：[规格](../../spec/2026-11-07-ci-basic-api-tests-spec.md)、[正向 API 清单](2026-11-07-api-selection.md)。新增 19 例，分布在 `integration_test/modules/*_cases.negative.dart`；原有正向用例、编号和五个 Presence 逆向用例保留。两个入口共 47 例：未登录 17 例，登录后 30 例。

当前结果：两端新增逆向均为 **17 通过、2 失败**；两个入口合计均为 **45/47 通过**。失败为 MSG-006、007 的消息状态断言，保留原预期，待人工确认；未修改 SDK，尚不满足全部通过的验收条件。

## 用例与预期

所有错误均断言 `ChatError` 的准确错误码；超时、其他异常或意外成功都使测试失败。消息发送在调用前注册监听，以本次消息 ID 关联最终回调。

| 编号 | 模块／场景 | 预期 |
|---|---|---|
| FL-AUTH-004 | 未登录，空用户 ID 登录 | Android 110，iOS 101；身份仍为空、连接仍断开 |
| FL-AUTH-005 | 未登录，空 Token 登录 | Android 110，iOS 104；身份仍为空、连接仍断开 |
| FL-AUTH-006 | 已登录同一用户再次登录 | 200；原身份和连接保持有效 |
| FL-CONTACT-005、006 | 未登录删除联系人，分别传入两个 `keepConversation` 值 | 201；不追加删除后本地同步或会话断言 |
| FL-CONTACT-007、008、009 | 未登录添加黑名单、移除黑名单、获取远端黑名单 | 分别返回 201 |
| FL-CONTACT-010 | 查询本地不存在的联系人详情 | `null`；查询不向两种本地联系人列表增加该 ID |
| FL-GROUP-003 | 未登录创建群 | 201；意外创建成功仍判失败，记录群 ID 并尝试清理 |
| FL-GROUP-004、005 | 未登录读取远端群详情、销毁群 | 分别返回 201 |
| FL-GROUP-006、007 | 已登录，以空群 ID 读取远端详情、销毁群 | 分别返回 600 |
| FL-CONV-009 | 更新尚未入库的消息 | 500；不能变成插入，原消息正文、ID 集合和数量不变 |
| FL-MSG-006 | 未登录发送消息 | 错误回调 201，回调消息状态为 `FAIL` |
| FL-MSG-007 | 已登录，向空收件人发送消息 | 错误回调 500，回调消息状态为 `FAIL` |
| FL-MSG-008 | 消息管理器查询缺失消息 ID，含混合批量查询 | 单条为 `null`，全缺失批次为空，混合批次只返回已有消息；原消息不变 |
| FL-MSG-009 | 消息管理器更新尚未入库的消息 | 500；不能变成插入，原消息及数量不变 |

空登录参数的差异来源是原生入口校验：Android `SDK_5.0.0` 的 `EMClient.loginWithToken` 统一使用 `INVALID_PARAM`；iOS `5.0.0` 的 `_loginWithUsername:pswdOrToken:isPassword:` 分别使用 `InvalidUsername`、`InvalidToken`。断言按平台选择一个确定值，不接受任意一组错误码。

其他错误依据：原生 `EMError` / `EMErrorCode` 定义未登录 201、重复登录 200、无效消息 500、无效群 ID 600；两端 Flutter wrapper 的 `updateChatMessage` / `updateConversationMessage` 明确将不存在消息映射为 500。缺失消息读取用 `ChatManager.loadMessage`，不混用 `ChatConversation.loadMessage` 的未收敛平台差异。

## 正向 API 逐项对应

下表覆盖正向清单的 52 个方法；`startCallback` 仅为准备方法。无效输入必须有明确返回契约，不能将合法空结果、幂等操作或类型系统已禁止的输入强行定义为错误。

| API | 逆向覆盖或不新增理由 |
|---|---|
| `ChatClient.loginWithToken` | AUTH-004～006 |
| `getCurrentUserId`、`isConnected` | AUTH-004～006 验证失败登录未破坏状态；AUTH-003 已验证退出状态 |
| `init` | 每进程只初始化一次；不在已初始化进程中伪造冷启动失败，当前两个入口均需先成功初始化 |
| `getAccessToken`、`getCurrentDeviceId`、`logout` | 无可控非法参数；退出后状态、重登、设备 ID 稳定性已有正向验证，不猜测空值或重复退出错误 |
| `ChatManager.sendMessage` | MSG-006、007 |
| `loadMessage`、`loadMessagesWithIds`、`updateMessage` | MSG-008、009；验证缺失资源不会返回或改写其他消息 |
| `getConversation`、`loadAllConversations`、`deleteConversation`、`deleteConversations` | CONV-001、007、008 已验证不自动创建、删除后排除、忽略不存在 ID、保留未选资源，不重复新增 |
| `loadMessagesWithKeyword`、`searchMsgsByOptions`、`loadConversationMessagesWithKeyword` | MSG-003～005 已用精确集合验证筛选排除，并验证关键字无匹配结果；不将合法无匹配定义为错误 |
| `importMessages` | 已有独立读回验证；公开前置条件要求归属当前用户，未约定错误归属的具体错误／忽略行为，不猜测 |
| `clearConversationUnreadMessageCount` | 按原范围只保留已有零值幂等边界，不扩量 |
| `ChatConversation.updateMessage` | CONV-009 |
| `loadMessages` | CONV-004 已验证末页、无更多结果、起点排除、跨页无重复 |
| `loadMessagesWithKeyword`、`loadMessagesWithMsgType`、`searchMsgsByOptions`、`loadMessagesFromTime`、`getLocalMessageCount` | CONV-005 已验证不匹配数据的排除、空查询及区间数量；不重复新增 |
| `deleteMessage`、`deleteMessageByIds`、`deleteMessagesWithTs`、`deleteAllMessages` | CONV-003、006 已验证未选消息保留及清空；缺失 ID／反向时间区间没有统一的规定错误，不猜测 |
| `setExt`、`insertMessage`、`appendMessage` | `null` 扩展等合法输入不算逆向；错误类型受 Dart 类型约束，错误会话归属的具体拒绝规则未明确，不用非公开通道绕过类型系统 |
| `loadMessage` | 缺失消息时 iOS 抛错、Android 返回空的历史差异仍待契约确认；不以当前差异定义新契约 |
| `latestMessage`、`lastReceivedMessage`、`messagesCount`、`unreadCount` | 无非法参数；已有确定消息及零未读边界，不为数量补重复空数据库读取 |
| `ChatContactManager.deleteContact`、`addUserToBlockList`、`removeUserFromBlockList`、`fetchBlockIds` | CONTACT-005～009 |
| `getAllContactIds`、`getAllContacts`、`getContact` | CONTACT-001 已验证非好友排除，CONTACT-010 补缺失详情及查询不增加联系人 |
| `getBlockIds` | 无参本地查询，不需要远端登录鉴权；CONTACT-004 已核验添加／移除的准确集合，不套用远端未登录错误 |
| `ChatGroupManager.createGroup`、`fetchGroupInfoFromServer`、`destroyGroup` | GROUP-003～007 |
| `getGroupWithId`、`getJoinedGroups` | 本地对象不证明远端资源存在；iOS 可构造群对象，不将不存在群强断言为两端都返回 `null`。已有本例群的本地查询验证 |

## 数据与清理

未登录用例使用冷安装，不要求账号或真实远端资源；参数在未登录阶段应被拒绝。登录用例沿用两个已存在账号及每轮新取的 Token，没有新增云端配置字段。消息用例显式创建本例会话、插入确定消息并核验准备结果，结束时删除本例会话及消息。原有好友关系、黑名单恢复和临时群回收继续执行。

配置仍通过临时 `E2E_CONFIG_PATH` 传入，文件位于 Git 忽略的 `reports/ci-basic-api/20261107-negative/`。CI workflow 的三字段准备与登录入口六字段输入之间的既有缺口仍存在，本次未修改 `tool/ci` 或云端 workflow。

## 验证记录

设备：Android `emulator-5554`；iOS 18.2 / iPhone 16 Pro `4BEA133B-4B24-430F-96FC-924632C2CF53`。使用原有 Bash 入口，登录账号串行使用。

| 平台 | 入口 | 轮次 | 通过／总数 | 失败 |
|---|---|---|---|---|
| Android、iOS | 未登录 smoke | r1、r2 | 每轮均 16/17 | MSG-006：错误码 201 正确，消息状态 PROGRESS |
| Android、iOS | 登录 full | r1 | 每轮均 26/29 | MSG-007 状态断言；MSG-008、009 准备错误，目标操作未执行 |
| Android | 登录 full | r2 | 28/29 | 修正准备后只剩 MSG-007 |
| iOS | 登录 full | r2 | 29/30 | 修正准备并补 CONTACT-010 后只剩 MSG-007 |
| Android、iOS | 登录 full | r3 | 每轮均 29/30 | MSG-007：错误码 500 正确，消息状态 PROGRESS |

原始日志：`artifacts/ci-negative-<platform>-<smoke|full>-r<轮次>-20261107.log`。逐例 [CSV](2026-11-07-negative-case-results.csv) 共 245 条，保留所有开发验证及复验结果；各平台最终 `smoke-r2 + full-r3` 实际执行编号与映射的 47 个编号完全一致。汇总 JSON：`reports/ci-basic-api/20261107-negative/results.json`。日志及 JSON 被 Git 忽略，CSV 随文档保存。

故障分类：

- **用例准备错误，已修正**：MSG-008、009 原准备代码在 `importMessages` 后直接以 `getConversation(createIfNeed:false)` 获取会话，结果为 `null`；导入接口不保证建立可查询的会话缓存。改为显式创建本例会话、插入消息并独立读回，目标缺失消息的预期不变。修正后双端通过。
- **SDK 状态异常候选，待人工确认**：MSG-006、007 在消息错误回调中获得 `PROGRESS`，与 `FAIL` 预期不符；双端重复复现。回调消息是独立反序列化对象，已排除原发送对象被方法返回修改的测试竞态。调用链及源码边界见[排查记录](../troubleshooting/2026-11-07-send-error-callback-message-status.md)。未修改断言、SDK 或数据准备以绕过此问题。

全部登录轮次中，原有 22 个正向用例通过；好友关系和黑名单恢复、退出检查通过，累计 12 个本轮临时群已核验回收。静态分析、用例映射及差异检查通过。临时 Token 配置已删除，原始日志未包含本轮原始 Token。未运行云端 CI，也不以本轮结果推断长期稳定率。
