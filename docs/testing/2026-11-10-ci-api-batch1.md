# 第一批登录 CI API 补充与验证

日期：2026-11-10。状态：19 个用例已实现；17 个已接入并执行，15 通过、2 失败；Presence 2 个用例等待接线确认，未执行。

## 范围与执行决策

- 在 5.1.0 worktree、基线 `2a08faf7` 上补充此前提出的 38 个候选 API；本轮为持续 CI 扩充，不是重新执行版本平版覆盖流程。
- 19 个独立业务场景形成读写闭环，不按 API 个数计算用例通过数。保留原有 55 个 ID 和特殊配置遗留项。
- 主/子代理同模型，先完成模块实现与静态检查，再按四种登录配置批量冷启动 iOS。原有三项暂停 FL-MSG-006/007、FL-CONV-006 不运行；特殊配置迁移仍待确认，本轮不改。
- 只增加业务模块用例和映射。Presence 需要基础入口 import + 注册调用，已询问用户；确认前模块不接线、不执行。其他入口、共享初始化、runner、workflow、SDK 业务源码不改。
- 选择 iOS 作为首测平台，复用现有可用模拟器；未验证 Android，不推定双端通过。每个问题最多三次实际失败，初次失败先分类，SDK问题保留正确断言。

## 覆盖表

下列模块均位于 `im_flutter_sdk/example/integration_test/modules/`；入口位于其上级目录。API 列是本批目标 API，准备/清理及辅助观察 API 不额外计入 38。

| 用例 | 目标 API | 模块／注册函数 | 入口 | 初始化依赖 | 核心断言 |
|---|---|---|---|---|---|
| FL-GROUP-009 | ChatGroupManager.updateGroupName | `group_cases.dart`<br>`registerGroupCases` | `logged_in_group_test.dart` | conversations \| joinedGroups | Updated group name is read back without changing description or owner |
| FL-GROUP-010 | ChatGroupManager.updateGroupDesc | `group_cases.dart`<br>`registerGroupCases` | `logged_in_group_test.dart` | conversations \| joinedGroups | Updated description is read back without changing name or owner |
| FL-GROUP-011 | ChatGroupManager.updateGroupExtension | `group_cases.dart`<br>`registerGroupCases` | `logged_in_group_test.dart` | conversations \| joinedGroups | Updated extension is read back without changing name |
| FL-GROUP-012 | ChatGroupManager.updateGroupAnnouncement<br>ChatGroupManager.fetchAnnouncementFromServer | `group_cases.dart`<br>`registerGroupCases` | `logged_in_group_test.dart` | conversations \| joinedGroups | Two successive announcement revisions are read back exactly |
| FL-GROUP-013 | ChatGroupManager.updateGroupAvatar | `group_cases.dart`<br>`registerGroupCases` | `logged_in_group_test.dart` | conversations \| joinedGroups | Avatar update return and server detail contain the requested URL |
| FL-GROUP-014 | ChatGroupManager.updateGroupNamecard<br>ChatGroupManager.getGroupNamecard | `group_cases.dart`<br>`registerGroupCases` | `logged_in_group_test.dart` | conversations \| joinedGroups | Own namecard is read back after setting and is null after removal |
| FL-GROUP-015 | ChatGroupManager.updateGroupConfigs | `group_cases.dart`<br>`registerGroupCases` | `logged_in_group_test.dart` | conversations \| joinedGroups | Only the selected allowInvites field changes; unselected config values are retained |
| FL-GROUP-016 | ChatGroupManager.addMembers<br>ChatGroupManager.removeMembers | `group_cases.dart`<br>`registerGroupCases` | `logged_in_group_test.dart` | conversations \| joinedGroups | Added peer appears in SDK and REST member lists then disappears after removal |
| FL-GROUP-017 | ChatGroupManager.addAdmin<br>ChatGroupManager.removeAdmin | `group_cases.dart`<br>`registerGroupCases` | `logged_in_group_test.dart` | conversations \| joinedGroups | Promoted peer appears in admins, demoted peer leaves admins but remains a member |
| FL-GROUP-018 | ChatGroupManager.fetchGroupMembersInfo | `group_cases.dart`<br>`registerGroupCases` | `logged_in_group_test.dart` | conversations \| joinedGroups | Typed member query returns the peer with Member role and positive joined timestamp without unknown or duplicate IDs |
| FL-GROUP-019 | ChatGroupManager.setMemberAttributes<br>ChatGroupManager.removeMemberAttributes<br>ChatGroupManager.fetchMemberAttributes<br>ChatGroupManager.fetchMembersAttributes | `group_cases.dart`<br>`registerGroupCases` | `logged_in_group_test.dart` | conversations \| joinedGroups | Own and peer attributes are distinct, multi-user key filtering is exact, and selective deletion preserves the other key and user |
| FL-GROUP-020 | ChatGroupManager.blockMembers<br>ChatGroupManager.unblockMembers<br>ChatGroupManager.fetchBlockListFromServer | `group_cases.dart`<br>`registerGroupCases` | `logged_in_group_test.dart` | conversations \| joinedGroups | Blocked peer appears in blocklist and leaves membership; unblock removes only the block entry |
| FL-GROUP-021 | ChatGroupManager.muteMembers<br>ChatGroupManager.unMuteMembers<br>ChatGroupManager.fetchMuteListFromServer | `group_cases.dart`<br>`registerGroupCases` | `logged_in_group_test.dart` | conversations \| joinedGroups | Mute list contains the peer with positive expiry and becomes empty after unmute while membership remains |
| FL-GROUP-022 | ChatGroupManager.addAllowList<br>ChatGroupManager.removeAllowList<br>ChatGroupManager.fetchAllowListFromServer | `group_cases.dart`<br>`registerGroupCases` | `logged_in_group_test.dart` | conversations \| joinedGroups | Allowlist adds the peer and removal restores the original list without changing membership |
| FL-CONTACT-011 | ChatContactManager.setContactRemark | `contact_cases.dart`<br>`registerContactCases` | `logged_in_contact_test.dart` | conversations \| contacts | New remark is read back in contact detail and list; original remark and relationship are restored |
| FL-USERINFO-002 | ChatUserInfoManager.updateUserInfo<br>ChatUserInfoManager.fetchOwnInfo<br>ChatUserInfoManager.fetchUserInfoById<br>ChatUserInfoManager.getLocalUserInfoByIds | `user_info_cases.dart`<br>`registerUserInfoCases` | `logged_in_user_info_test.dart` | conversations; enableUserInfo=true | Updated own gender is returned by update, uncached remote reads and native local query; original value is restored |
| FL-CONV-014 | ChatManager.pinConversation | `conversation_cases.dart`<br>`registerConversationCases` | `logged_in_base_test.dart` | conversations | Pin/unpin state is reread from native detail and list while control and message contents remain unchanged |
| FL-PRESENCE-006 | ChatPresenceManager.publishPresence<br>ChatPresenceManager.fetchPresenceStatus | `presence_cases.dart`<br>`registerLoggedInPresenceCases` | `logged_in_base_test.dart` | conversations; 接线待确认 | Own unique published description is fetched and original description restored |
| FL-PRESENCE-007 | ChatPresenceManager.subscribe<br>ChatPresenceManager.unsubscribe<br>ChatPresenceManager.fetchSubscribedMembers | `presence_cases.dart`<br>`registerLoggedInPresenceCases` | `logged_in_base_test.dart` | conversations; 接线待确认 | Fresh offline peer is returned by subscribe, appears exactly once in paged subscriptions, disappears after unsubscribe, and is deleted |

## 验证记录

实际工具链：Flutter 3.47.0 / Dart 3.13.0；iPhone 16 Pro `4BEA133B-4B24-430F-96FC-924632C2CF53`；本地 Flutter 四包 5.1.0。iOS `example/ios/Podfile.lock` 解析 HyphenateChat 5.1.0（checksum b45227e7765e35980d231bd14f3321f1d72633f1）；所用 simulator framework Info.plist 也为 `CFBundleShortVersionString=5.1.0`（build 1）。当前为 CocoaPods 集成，未运行 SPM 或 Android。

正式报告由现有 runner 生成。统一环境为 `E2E_CONFIG_PATH=<临时 CI 配置>`、`MAX_ATTEMPTS=1`，避免隐式自动重试超出失败预算。以下路径相对仓库根，均为本轮真实执行。

| 范围 | 结果 | 报告 |
|---|---|---|
| 群组完整入口（5 原有＋14 新增；两失败例后补诊断） | 19 总数，17 通过、2 失败 | [首轮报告](../../artifacts/ci/20261110-114429-ios-307yi1ig/summary.md) |
| 联系人完整入口（5 原有＋1 新增） | 6/6 通过，备注及关系恢复成功 | [报告](../../artifacts/ci/20261110-114535-ios-zwwdc89w/summary.md) |
| 用户资料完整入口（1 原有＋1 新增） | 2/2 通过，gender 恢复成功 | [报告](../../artifacts/ci/20261110-114641-ios-c6ck_4vq/summary.md) |
| 基础入口（23 原有＋1 新增，排除既有暂停项） | 24/24 通过，含 pin/unpin | [报告](../../artifacts/ci/20261110-114759-ios-hy76tjpm/summary.md) |
| Presence | 接线待确认，未执行 | 不计通过 |

## 问题与遗留

- 环境准备首次受沙箱 DNS 限制，未执行任何用例；使用获准的网络执行后已生成临时配置，未输出凭据。
- Presence 接线待确认；此项不是 SDK 失败。
- 历史 FL-MSG-006/007、FL-CONV-006 和三项特殊配置执行项沿用既有暂缓决定。

### 本轮问题登记

| 问题 ID | 用例 | 实际现象 | 失败次数 | 状态／归因 |
|---|---|---|---:|---|
| B1-01 | FL-GROUP-011 | 更新 extension 后 detail.extension 为 null；configs.ext 为正确新值 | 2 | 已确认 iOS wrapper 漏字段；非测试夹具错误，未修改 SDK |
| B1-02 | FL-GROUP-014 | namecard:null 删除后读取仍为原名片，5 秒有界等待仍不更新 | 2 | native 行为异常候选；Flutter 参数透传符合契约，core／服务端／本地缓存的具体根因待确认 |

两项的本轮测试群均已通过 REST 删除并验证不存在。失败不影响后续入口前置。

## 当前汇总与可复现操作

- [正式汇总报告](../../artifacts/ci/20261110-115029-api-batch1/summary.md)：四个配置首轮实际执行 **51 项，49 通过、2 失败**，其中新增 17 项为 **15 通过、2 失败**，原有回归 34 项全部通过。
- [群组定向诊断复验](../../artifacts/ci/20261110-114912-ios-80akne4i/summary.md)：2 项再次失败。只改了失败例的诊断／名片有界等待，其他已通过用例未改；每问题累计失败 2 次。没有新假设时不为了凑够 3 次重跑。
- 汇总显式选取四个首轮目录；定向复验单列，不与群组首轮相加，也不让同入口的最新二项选择替换完整的 19 项范围。复验未改变两项失败结论。生成汇总不是再次执行测试。
- 未执行：Presence 两例（5 个目标 API，接线待确认）；Android；历史暂停 3 例及特殊配置 3 项；本轮不涉及单设备平版和多设备场景。计划未执行项不混入 runner 已选测的 51 项统计。
- 目标 38 API 对应 19 个场景；17 个已执行场景覆盖其中 33 API。它不是“38 个用例通过”，也不是完整 API 行为覆盖率。

从仓库根准备 `E2E_CONFIG_PATH` 后执行，配置准备见 [CI 操作说明](../../tool/ci/README.md)。本轮运行命令使用 `MAX_ATTEMPTS=1`；Flutter 在 PATH 中：

```bash
E2E_CONFIG_PATH=/path/to/e2e.json MAX_ATTEMPTS=1 bash tool/ci/run_ios_simulator_test.sh integration_test/logged_in_group_test.dart ios-api-batch1-group.log
E2E_CONFIG_PATH=/path/to/e2e.json MAX_ATTEMPTS=1 bash tool/ci/run_ios_simulator_test.sh integration_test/logged_in_contact_test.dart ios-api-batch1-contact.log
E2E_CONFIG_PATH=/path/to/e2e.json MAX_ATTEMPTS=1 bash tool/ci/run_ios_simulator_test.sh integration_test/logged_in_user_info_test.dart ios-api-batch1-userinfo.log
E2E_CONFIG_PATH=/path/to/e2e.json MAX_ATTEMPTS=1 CI_TEST_NAME='FL-(AUTH-00[12367]|CONV-00[12345789]|CONV-01[034]|MSG-00[1234589]|MSG-010)' bash tool/ci/run_ios_simulator_test.sh integration_test/logged_in_base_test.dart ios-api-batch1-base.log
# 已执行的第二次群组诊断命令；目前不继续重复运行。
E2E_CONFIG_PATH=/path/to/e2e.json MAX_ATTEMPTS=1 CI_TEST_NAME='FL-GROUP-(011|014)' bash tool/ci/run_ios_simulator_test.sh integration_test/logged_in_group_test.dart ios-api-batch1-group-diagnostic.log
```

### 失败归因证据与边界

**B1-01**：Flutter [ChatGroup](../../im_flutter_sdk/lib/src/models/chat_group.dart) 公开 `extension`，读取顶层 `ext`；[iOS GroupHelper](../../im_flutter_sdk_ios/ios/im_flutter_sdk_ios/Sources/im_flutter_sdk_ios/GroupHelper.m) 未输出顶层 `ext`，仅输出 `configs.ext`。Android `EMHelper.java` 输出顶层 `ext`。诊断日志明确显示 `extension=null`、`configs.ext` 为本轮设置值，因此更新动作成功，但公开对象字段断裂；不能把断言迁到 `configs.ext` 就称全部正常。建议后续独立修复 iOS 序列化并复验，当前未改 SDK。

**B1-02**：公开 Dart/iOS 契约均规定 null/nil 删除名片。Dart 省略 null 参数，iOS wrapper 取缺失 key 得到 nil 并传给 native，没有发现 Flutter 误传。只读核对 native iOS tag `5.1.0`（`e88b1dcc9`）：删除转换为空串进入 core，getter 读取本地数据库。两次删除 API 成功后仍读到原值，第二次已等待 5 秒。随后诊断 `fetchGroupMembersInfo` 返回的列表没有 owner（打印 `server own namecards=[]`），**这不能证明服务端名片已删除**。仍需在后续 SDK 排查中区分服务端状态和 core 本地缓存；不猜根因、不放宽 null 断言。建议确认 SDK 排查范围后继续。

两次运行均验证本轮测试群删除成功。联系人备注／关系、用户资料 gender、置顶状态及本地夹具均完成恢复；suite logout 成功。没有后续前置或清理方面的严重阻塞。

### 静态验证与范围审查

- 五个新增／修改业务模块格式检查、整个 integration_test 静态分析、映射检查通过。
- 原有 55 个 ID 均保留，新增 19 个 ID，无重复；其中 Presence 2 个仅模块实现，未接入入口。
- 当前已注册清单为 72 个唯一 ID／73 个配置执行项；待 Presence 接入后为 74／75（含原有特殊配置），这只是清单，不是执行通过数。
- 未修改五个稳定入口、特殊入口、共享初始化／support、workflow、tool/ci、SDK 实现，也未提交。后续 Presence 仅拟新增基础入口 import 与一次注册调用，须取得确认后落地及验证。
