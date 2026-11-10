# 第一批登录 CI API 补充与验证

日期：2026-11-10。状态：19 个用例已实现；首轮 17 个已接入并执行，15 通过、2 失败；后续 FL-GROUP-011 已修复并定向复验通过，提交 `90b68b0d`；FL-GROUP-014 已定位 core 同秒缓存更新及 iOS 空值转换两层问题，未修复；Presence 2 个用例等待接线确认，未执行。

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
| B1-01 | FL-GROUP-011 | 更新 extension 后 detail.extension 为 null；configs.ext 为正确新值 | 修复前 2 | iOS wrapper 漏字段已修复，复验 1/1 通过，提交 `90b68b0d` |
| B1-02 | FL-GROUP-014 | 同秒删除后保留旧名片；跨秒删除后返回空字符串而非 null | 3 | 已定位 core 时间精度丢失导致缓存更新被忽略，以及 iOS 空字符串未转 nil；停止重跑，未修复 |

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

**B1-01（修复前证据）**：Flutter [ChatGroup](../../im_flutter_sdk/lib/src/models/chat_group.dart) 公开 `extension`，读取顶层 `ext`；[iOS GroupHelper](../../im_flutter_sdk_ios/ios/im_flutter_sdk_ios/Sources/im_flutter_sdk_ios/GroupHelper.m) 原先未输出顶层 `ext`，仅输出 `configs.ext`。Android `EMHelper.java` 输出顶层 `ext`。诊断日志明确显示 `extension=null`、`configs.ext` 为本轮设置值，因此更新动作成功，但公开对象字段断裂；不能把断言迁到 `configs.ext` 就称全部正常。后续修复及验证见下节。

**B1-02（前两轮证据）**：公开 Dart/iOS 契约均规定 null/nil 删除名片。Dart 省略 null 参数，iOS wrapper 取缺失 key 得到 nil 并传给 native，没有发现 Flutter 误传。native iOS tag `5.1.0`（`e88b1dcc9`）将删除转换为空串进入 core，getter 读取本地名片缓存。两次删除 API 成功后仍读到原值，第二次已等待 5 秒。随后诊断 `fetchGroupMembersInfo` 返回的列表没有 owner（打印 `server own namecards=[]`），**这不能证明服务端名片已删除**。后续第三轮使用服务端自身名片接口及跨秒对照，根因见末节。

两次运行均验证本轮测试群删除成功。联系人备注／关系、用户资料 gender、置顶状态及本地夹具均完成恢复；suite logout 成功。没有后续前置或清理方面的严重阻塞。

### 静态验证与范围审查

- 五个新增／修改业务模块格式检查、整个 integration_test 静态分析、映射检查通过。
- 原有 55 个 ID 均保留，新增 19 个 ID，无重复；其中 Presence 2 个仅模块实现，未接入入口。
- 当前已注册清单为 72 个唯一 ID／73 个配置执行项；待 Presence 接入后为 74／75（含原有特殊配置），这只是清单，不是执行通过数。
- 未修改五个稳定入口、特殊入口、共享初始化／support、workflow、tool/ci、SDK 实现，也未提交。后续 Presence 仅拟新增基础入口 import 与一次注册调用，须取得确认后落地及验证。

## FL-GROUP-011 修复与复验（2026-11-10 13:42）

- 用户单独授权修复 B1-01、记录并复验，要求不提交。上文首轮执行范围及统计保留为历史证据。
- 修复：iOS `GroupHelper.m` 的 `EMGroup.toJson` 在已有 settings 分支中增加 `ret[@"ext"] = self.settings.ext`，恢复 Dart `ChatGroup.extension` 所需的顶层字段；保留 `configs.ext`。同步 iOS CHANGELOG，原用例和断言未改，未调整入口或测试架构。
- 使用原群组入口在 iOS 模拟器重新构建并执行 `FL-GROUP-011`，`MAX_ATTEMPTS=1`。结果 **1 总数、1 通过、0 失败**，日志确认 `extension` 与 `configs.ext` 均为本轮设置值；测试群删除及退出登录成功。
- [正式复验报告](../../artifacts/ci/20261110-134124-ios-g2cx8yov/summary.md) · [原始设备日志](../../artifacts/ci/20261110-134124-ios-g2cx8yov/attempt-1.log)。报告由现有 runner 生成，Git 忽略；未覆盖首轮报告。
- 执行命令：`E2E_CONFIG_PATH=<临时配置> MAX_ATTEMPTS=1 CI_TEST_NAME=FL-GROUP-011 bash tool/ci/run_ios_simulator_test.sh integration_test/logged_in_group_test.dart ios-group011-fix.log`。临时凭据文件执行后已删除。
- Android 源码已包含顶层 `ext` 映射，没有发现相同漏字段问题；本轮未执行 Android，不宣称 Android 实测通过。FL-GROUP-014 未改、未重跑。

## FL-GROUP-014 native/core 根因调查（2026-11-10 13:48）

011 修复已按用户要求提交 `90b68b0d`；本节是随后授权的 014 调研，未实施修复。

已创建 native/core 缺陷工单 [HIM-24170](https://j1.private.easemob.com/browse/HIM-24170)，组件 SDK、状态 To Do，未指定处理人。工单包含复现、源码定位、证据边界、修复建议及回归范围，诊断日志摘录附件上传成功；已回读核对正文和附件。截止日期暂填 2026-11-13、预估 2d，正文注明供负责人调整。

### 源码依据

核对 native iOS tag `5.1.0`（`e88b1dcc9af41e57fa3d219986addfdc800367a4`）及 core `emclient-linux` tag `SDK_5.1.0`（`e5d925cb5589e2c7be304d47b0eafc5c7c2b1c60`）。标签源码不等同于已核验 framework 内嵌 core SHA；实际 iOS 5.1.0 framework 行为由下述设备诊断验证。

1. **参数透传正常**：Flutter null → wrapper nil → native `EMGroupManager.mm:2884` → `EMStringUtil.mm:55` 转空字符串 → core `src/emgroupmanager.cpp:2640` 的 `updateSelfNameCard` → `EMMucManager::updateMucSelfNameCard`，发送 `PUT /sdk/chatgroups/<id>/nameCard`。
2. **core 同秒更新被忽略**：`src/emmucmanager.cpp:296/303` 将响应 `update_timestamp`（或顶层 `timestamp`）转为秒，`src/utils/emutils.cpp:551` 实际执行整数除以 1000；`src/emmucmanager.cpp:328` 只在 `existing->updateTime() < updateTime` 时更新缓存。同秒设置和删除被截成同一时间，删除响应成功却不应用到本地，且不返回错误。事后等待不能重新应用已被忽略的响应。问题也可能影响同秒连续修改，不限于删除。
3. **iOS 空值语义不一致**：跨秒时 core 在 `src/emmucmanager.cpp:331–333` 将记录写为空字符串，并未移除记录。`src/emdatabase.cpp:10557` 的 getter 直接读内存缓存；native iOS `EMGroupManager.mm:2902` 发现记录就调用 `EMStringUtil.mm:65` 的 `stdToNSString`，返回 `""`。Flutter wrapper 原样返回，与 Flutter 文档“未设置名片返回 null”不一致。native iOS 文档只承诺“缓存未找到返回 nil”，已有空串记录并非未找到，不能将其表述为 native 文档已保证空串转 nil。
4. **平台差异**：Android JNI `src/android/com_hyphenate_chat_adapter_EMAGroupManager.cpp:1418` 已将空字符串转 Java null。第二层转换差异在 iOS 路径；第一层共享 core 问题同样存在于 Android 源码调用链。本轮未运行 Android。

### 第三轮诊断

复用原群组入口，仅临时在 014 内加入 `GET /sdk/chatgroups/<id>/nameCard?version=v3`（当前用户 token）的独立观察和跨秒对照，保留原 null 断言；对照在原断言失败后执行。全部 GET 返回 HTTP 200，不再用不包含 owner 的成员列表判断服务端名片。

测试群 `330187457757185`，原名片 `ci_330187457757185`：

| 阶段 | 服务端观察 | 本地 getter |
|---|---|---|
| 设置后 | 原名片；update_timestamp=`1794289699232`；GET timestamp=`1794289699308` | 原名片 |
| 紧接着删除后 | 不再返回 name_card；GET timestamp=`1794289699422` | **仍为原名片** |
| 等待 5 秒 | 仍无 name_card；GET timestamp=`1794289704596` | **仍为原名片** |
| 重新设置对照名片 | 原名片加 `_control`；update_timestamp=`1794289704655` | 对照名片 |
| 间隔 1.2 秒再删除 | 不再返回 name_card；GET timestamp=`1794289706032` | **空字符串 `""`** |

GET 时间不是 PUT 原始响应时间，本轮未捕获 PUT 响应；实测从设置完成到删除后观察均处在同一个服务端秒内，跨秒对照恢复本地清空行为，与标签源码的精度截断及严格比较吻合。服务端无名片而本地保留旧值的分歧已经独立验证。

- [诊断报告](../../artifacts/ci/20261110-134742-ios-hr6jvjde/summary.md) · [设备日志](../../artifacts/ci/20261110-134742-ios-hr6jvjde/attempt-1.log) · [临时诊断源码](../../artifacts/diagnostics/20261110-134742-group014/group_cases.diagnostic.dart)，均为 Git 忽略产物。
- 本轮 **1 项、0 通过、1 失败**，014 累计 **3 次失败**后停止。未覆盖前两轮记录，也未宣称修复通过。
- 临时诊断源码已恢复提交版本；测试群删除、退出登录成功，临时凭据已删除。native 两仓库未修改，既有未跟踪 `dailylog/` 保持原状。
- 建议修复 core 时间精度或主动更新成功后的缓存应用规则；不能草率将 `<` 改为 `<=`，否则同秒乱序旧响应仍可能覆盖新值。另需统一 iOS getter 与 Flutter/Android 的空值语义。涉及 core 数据表示／更新规则的方案需另行确认；本轮仅调研，不改 SDK 或架构。
