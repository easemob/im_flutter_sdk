# 第二批 CI 用例补充与验证（全量回归缺口）

日期：2026-11-16。状态：Wave 1/2 与 3 个 P2 用例已实现；Android 跑过完整 nightly，iOS 按选例完成验证；未提交，等待用户最终 review。

## 范围与执行决策

- 依据 2026-11-16 的全量回归缺口分析：除 5.1.0 收口外，补齐持续回归价值最高、可用单设备与服务端夹具证明的行为。
- 新增 20 个 ID：`FL-CONV-015/016/017/018`、`FL-MSG-011/012/013/014/015`、`FL-GROUP-023~028`、`FL-ROOM-001~005`。
- 把已实现但未接线的 `FL-PRESENCE-006/007` 接入基础入口；不新增入口、不改共享初始化、不改 runner/workflow。
- 加固既有用例：`FL-GROUP-021` 增加「自己不在群禁言列表」前提，`FL-GROUP-022` 增加「自己不在群白名单」前提。`FL-CONTACT-002/003` 的本地名册加固尝试后被回退，原因见 B2-08。
- 入口改动仅两处：基础入口 import 并注册新模块 `chat_room_cases.dart`、既有模块 `presence_cases.dart`；`registerConversationCases` 增加 `required String peerId`（016/017/018 需要真实对端会话）。房间用例放在基础入口，因为建房、加成员、公告、禁言、管理员都不依赖特殊同步配置。
- 未按 API 个数计通过；每例是独立业务闭环，失败三次即跳过并登记（本轮实际无跳过）。
- 服务端夹具通过 app token 使用 REST 准备：对端为 owner 的群、公开群、带成员聊天室、单向消息。未输出凭据。

## 用例清单

模块均位于 `im_flutter_sdk/example/integration_test/modules/`；入口在其上级目录。

| 用例 | 目标 API | 模块／注册函数 | 入口 | 核心断言 |
|---|---|---|---|---|
| FL-CONV-015 | ChatManager.getConversationsFromDB、pinConversation | `conversation_cases.dart`<br>`registerConversationPaginationCases` | `conversation_config_test.dart` | 置顶会话在分页遍历中排在首位，其余按时间与 ID 降序；取消置顶后恢复纯时间序 |
| FL-CONV-016 | ChatConversation.unreadCount、ChatManager.getUnreadMessageCount、clearConversationUnreadMessageCount | `conversation_cases.dart`<br>`registerConversationCases` | `logged_in_base_test.dart` | 两条真实入站消息使会话未读为 2、账号未读至少 +2；清除后会话归零且账号总数回到基线 |
| FL-CONV-017 | ChatConversation.deleteLocalAndServerMessages | 同上 | 同上 | 真实消息在本地与服务端历史均存在；按 ID 删除后两处都读不到，且只删除该条 |
| FL-CONV-018 | ChatManager.addRemoteAndLocalConversationsMark、deleteRemoteAndLocalConversationsMark、ChatConversation.marks | 同上 | 同上 | 对端会话初始不含标记；添加后本地会话报出该标记，删除后消失 |
| FL-MSG-011 | ChatMessage.createFileSendMessage、createImageSendMessage、ChatManager.loadMessage | `message_cases.dart`<br>`registerMessageCases` | 同上 | 文件与图片消息终态成功，回读消息带 remotePath/secret/fileSize，图片宽高保持 |
| FL-MSG-012 | ChatManager.downloadAttachment | 同上 | 同上 | 导入的接收方向附件下载终态为 SUCCESS，落盘文件字节与上传内容一致 |
| FL-MSG-013 | ChatManager.fetchHistoryMessagesByOption | 同上 | 同上 | 服务端历史按 pageSize=2 游标分页无重复、可终止，5 条夹具齐全且时间单调 |
| FL-MSG-014 | ChatManager.pinMessage、unpinMessage、fetchPinnedMessages、ChatMessage.pinInfo | 同上 | 同上 | 置顶后服务端置顶列表包含该消息且操作者/时间为本人与本轮；取消后移除 |
| FL-MSG-015 | ChatManager.addReaction、removeReaction、fetchReactionList、fetchReactionDetail、ChatMessage.reactionList | 同上 | 同上 | 添加后服务端列表、详情页与本地消息都报告该 Reaction；移除后服务端不再报告 |
| FL-GROUP-023 | ChatGroupManager.createGroup、addMembers | `group_cases.dart`<br>`registerGroupCases` | `logged_in_group_test.dart` | inviteNeedConfirm=true 时直接添加成员只发邀请，服务端与 SDK 成员列表都不新增 |
| FL-GROUP-024 | ChatGroupManager.muteAllMembers、unMuteAllMembers、fetchGroupInfoFromServer | 同上 | 同上 | 全员禁言标记在服务端为 true 后恢复 false，成员关系不变 |
| FL-GROUP-025 | ChatGroupManager.changeOwner | 同上 | 同上 | 转让后服务端与 SDK 群主都变为对端，成员集合不变 |
| FL-GROUP-026 | ChatGroupManager.leaveGroup、getJoinedGroups | 同上 | 同上 | 对端为 owner 的群在 REST 成员加入后退出，REST 成员只剩 owner，本地加入列表不含该群 |
| FL-GROUP-027 | ChatGroupManager.joinPublicGroup、leaveGroup | 同上 | 同上 | 公开群加入后 REST 成员含本人，退出后只剩 owner |
| FL-GROUP-028 | ChatGroupManager.uploadGroupSharedFile、fetchGroupFileListFromServer、downloadGroupSharedFile、removeGroupSharedFile | 同上 | 同上 | 上传文件出现在列表并带 ID/名称/大小；下载字节一致；移除后列表为空 |
| FL-ROOM-001 | ChatRoomManager.joinChatRoom、leaveChatRoom、fetchChatRoomInfoFromServer、getChatRoomWithId | `chat_room_cases.dart`<br>`registerChatRoomCases` | 同上 | 房间详情与名称正确，成员查询含对端，退出后可重新加入并仍能读到房间 |
| FL-ROOM-002 | ChatRoomManager.updateChatRoomAnnouncement、fetchChatRoomAnnouncement | 同上 | 同上 | 两次公告更新各自读回一致 |
| FL-ROOM-003 | ChatRoomManager.removeChatRoomMembers、blockChatRoomMembers、fetchChatRoomBlockList | 同上 | 同上 | 移除后成员列表不含对端；拉黑后黑名单含对端，解除后不含 |
| FL-ROOM-004 | ChatRoomManager.muteChatRoomMembers、fetchChatRoomMuteList、muteAllChatRoomMembers | 同上 | 同上 | 单人禁言出现在禁言列表，解除后移除；全员禁言标记在详情为 true 后恢复 |
| FL-ROOM-005 | ChatRoomManager.addChatRoomAdmin、removeChatRoomAdmin | 同上 | 同上 | 提升后管理员列表含对端，撤销后不含 |
| FL-PRESENCE-006/007 | 见既有实现 | `presence_cases.dart`<br>`registerLoggedInPresenceCases` | 同上 | 接线后按既有断言执行 |

## 验证记录

工具链：Flutter 3.47.0 / Dart 3.13.0；Android emulator-5554；iOS iPhone 16（iOS 18.1）模拟器；CocoaPods HyphenateChat 5.1.0。所有运行使用 `E2E_CONFIG_PATH=<临时 CI 配置>` 与 `CI_TEST_NAME` 选例；路径相对仓库根。

| 平台 | 范围 | 结果 | 报告 |
|---|---|---|---|
| Android | 基础入口新增 12 例（CONV-016/017、MSG-011/012/013、ROOM-001~005、PRESENCE-006/007） | 首轮 8 通过 4 失败；修复后 4 例定向复验 4/4 通过 | `artifacts/ci/20261116-210220-android-afvd86nh/`、`20261116-210512-android-sj66jkfq/` |
| Android | 基础入口 P2 3 例（CONV-018、MSG-014/015） | 3/3 通过 | `artifacts/ci/20261116-211217-android-x0wjx_bl/` |
| Android | 群组入口新增 8 例（GROUP-021~028） | 首轮 5/8；修复后 8/8 通过 | `20261116-210539-android-eksp5ra3/`、`20261116-210710-android-j15m9yud/` |
| Android | 群组 026/027（计数 oracle 移除后） | 2/2 通过 | `20261116-211548-android-16dgkuxx/` |
| Android | conversation_config FL-CONV-015 | 1/1 通过 | `20261116-210605-android-56ocj05m/` |
| Android | 完整 nightly（5 批次，加固回退前） | 78 项：74 通过、4 失败（历史已知 FL-CONV-006、FL-MSG-007、FL-GROUP-014；本轮 FL-CONTACT-002 加固） | `20261116-211627-nightly-android.Z1cPDW/summary.md` |
| Android | 联系人入口（加固回退后） | 6/6 通过 | `20261116-211954-android-vu1tw8w_/summary.md` |
| iOS | 基础入口新增 12 例 | 12/12 通过 | `20261116-210739-ios-sdy1k4pf/` |
| iOS | 基础入口 P2 3 例 | 3/3 通过 | `20261116-211241-ios-denkxqb9/` |
| iOS | 群组 8 例 | 首轮 7/8（026 失败）；移除计数 oracle 后 026/027 2/2 通过 | `20261116-210847-ios-oeee251y/`、`20261116-211331-ios-qdd35mqj/`、`20261116-211515-ios-qscisrr5/` |
| iOS | conversation_config FL-CONV-015 | 1/1 通过 | `20261116-210954-ios-5uhsgn8u/` |

未运行：iOS 完整 nightly、单设备 JSON 脚本、多设备用例；Android 完整 nightly 仅覆盖上表那次运行（联系人加固回退后只补跑了联系人入口）。本轮结论只覆盖上表选例。

## 问题与设计调整

| 编号 | 用例 | 现象 | 处理 | 性质 |
|---|---|---|---|---|
| B2-01 | FL-MSG-011 | 1x1 PNG 上传后 fileSize 为 762，源文件为 70 | 改为非空且大于 0，保留宽高断言 | native 重新编码图片，源字节数不是上传后大小 |
| B2-02 | FL-MSG-012 | 回调成功且 fileStatus=SUCCESS，但请求路径无文件 | 读取回调消息的 localPath，落到 native 指定路径后再比对字节 | 下载落盘路径由 native 决定，Dart 未接收路径 |
| B2-03 | FL-ROOM-001/003 | `fetchChatRoomMembers` 不返回自己 | 只断言对端成员关系；房间归属用详情 owner 证明 | REST 建房 owner 与成员列表语义不同，native 只转发查询 |
| B2-04 | FL-GROUP-022 | 自己出现在群白名单 | 删除该前提断言，保留白名单快照与增删断言 | owner 被视为 allowed，原前提不成立 |
| B2-05 | FL-GROUP-023 | 成员列表返回空而非自己 | 断言对端不在成员中，且除本人外没有其他成员 | 群成员查询不保证返回请求者 |
| B2-06 | FL-GROUP-028 | 下载返回后立即读文件抛 PathNotFoundException | 轮询目标路径存在后再比对字节 | 群文件下载异步完成，Dart 层无完成回调 |
| B2-07 | FL-GROUP-026/027 | iOS 加入群计数 30s 内不增长；首轮基线被上一轮删除延迟抬高 | 移除加入群计数 oracle，改用 REST 成员集合与退出后的本地列表 | iOS 计数来自缓存，外部 REST 成员变化不触发刷新 |
| B2-08 | FL-CONTACT-002 | 删除成功后 30s 本地联系人列表仍含对端 | 回退该加固断言，只保留 API 完成断言；注释说明本地名册刷新属同步范畴 | keepConversation=true 时 native 不保证同步移除本地名册条目，003 通过不改变该契约 |

## 未实施与遗留

- `FL-MSG-016` 撤回：发送方撤回后的本地状态与服务端历史契约在仓库内无依据，接收方需要第二设备观察，本轮不猜测断言。
- `FL-MSG-017` modifyMessage：依赖服务端消息编辑能力，未验证开通情况。
- `FL-AUTH-009` includeSend：需要给 `client_cases` 增加对端参数并调整入口注册，且关闭路径只能用时间窗口断言，价值低于改动成本。
- `FL-ROOM-006/007` 房间属性与白名单：iOS 缺 `removeChatRoomAttributes`；`isMemberInChatRoomAllowList` 只判断当前用户，自建房间的语义需产品确认。
- `dataSyncType` 省略时的 native 默认值：必须新增冷启动初始化配置，属测试架构变更，等待单独确认。
- `native-case-mapping.json` 已从 74 条更新到 94 条；`flutter-only-ci.md` 的入口计数同步为 94 个 ID、95 个执行项（FL-CONV-013 在基础入口与特殊配置批次各执行一次）。
- 已知历史失败仍按原决定跳过：FL-CONV-006、FL-MSG-006/007、FL-GROUP-014。
