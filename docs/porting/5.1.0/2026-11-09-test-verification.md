# 5.1.0 升级测试验证

> 2026-11-10 入口归类更新：下文旧入口名称、初始化矩阵和执行证据保留为历史记录。当前五个稳定入口及特殊配置迁移状态见 [CI 设计规则](../../testing/2026-11-09-ci.md) 和 [操作说明](../../../tool/ci/README.md)；历史通过结果不代表新入口已验证。

- 日期：2026-11-09；阶段：按用户确认的显式初始化批次整理用例，迁移后选测全部通过；已知失败继续跳过，M1/M3 历史结果保留，M2 暂缓。
- 覆盖表：[变更到测试的覆盖表](2026-11-09-test-coverage.md)。
- 目标：`im_flutter_sdk/.worktree/5.1.0`，分支 `5.1.0`，基线 `adf9764b`；本轮测试与文档改动未提交，SDK 业务代码未修改。
- 工具链：Flutter 3.47.0、Dart 3.13.0；Android Pixel_9 / `emulator-5554`，iOS 18.2 / iPhone 16 Pro / `4BEA133B-4B24-430F-96FC-924632C2CF53`。
- SDK：Flutter 四包 5.1.0、本地 overrides；Android Maven 声明 5.1.0；iOS CocoaPods lock 为 HyphenateChat 5.1.0、ShengwangInfra_iOS 1.3.16。本轮 iOS 使用 CocoaPods，未验证 SPM 设备集成。
- 范围：新增 CI 与单设备场景、已批准的 M1/M3 多设备场景、适用回归及工具单测。4.22/4.24 旧脚本、撤回及已停用的缺失消息回执崩溃场景不自动恢复。
- 原始证据：除另注明外，日志名相对 `reports/5.1.0/test-coverage/`；单设备工具仍输出到 `reports/5.0.0/`，目录名不代表本轮 native 版本。凭据不进入本文。

## 当前布局：显式初始化与迁移复验

用户确认保留需要不同初始化参数的独立套件，其余用例归入业务模块。所有批次显式设置 dataSyncType、autoLoadConversations、enableChatroomConversation、enableUserInfo；具体矩阵见 [CI 说明](../../../im_flutter_sdk/docs/ci/flutter-only-ci.md)。`native_defaults_test.dart` 沿用文件名，但当前 FL-AUTH-007 验证显式 conversations=1，不再验证省略参数的默认行为。历史消息用例移入 message 模块；分页两例只由 conversation_config 套件注册；聊天室关闭/开启分别由常规/特殊批次验证。

`nightly_local.sh` 是本地和 workflow 共用总入口，直接循环四个套件，每批由原设备 runner 冷启动；删除多余调度脚本。本轮没有跑完整 nightly，因为用户已要求跳过 CONV-006、MSG-006/007；使用现有 runner 和 Flutter 选例参数验证受影响范围，不改变框架或添加跳过机制。

| 选测项 | 平台/入口 | 当前结果 | 证据 |
|---|---|---|---|
| AUTH-001、CONV-010/013(false)、GROUP-008、MSG-010 | Android，single_account_local_test；按上述5个 ID 定向选择 | 5/5 通过；REST 群、聊天室、本地会话清理及登出成功 | `relocation-standard-android.log` |
| CONV-011/012/013(true) | Android，conversation_config_test | 3/3 通过，资源清理及登出成功 | 根 `artifacts/relocation-conversation-config-android.log` |
| AUTH-007，显式 conversations=1 | Android，native_defaults_test | 1/1 通过，start/finish=1 且 error=null，登出成功 | 根 `artifacts/relocation-explicit-sync-android.log` |
| USERINFO-001，显式 enableUserInfo=true | iOS，user_info_subscription_test | 1/1 通过，订阅/取消关系正确，临时账号清理及登出完成 | 根 `artifacts/relocation-userinfo-ios.log` |
| 单设备正向脚本 | Android，script_510_apis_positive.json | 5/5 步骤通过，destroy_group 成功 | `reports/5.0.0/20261109110147-android-emulator-5554/summary.md`；`relocation-single-positive.log` |
| 单设备逆向脚本 | iOS，script_510_apis_negative.json | 1/1 步骤通过，非法 cursor 返回110，无创建资源 | `reports/5.0.0/20261109110242-ios-4BEA133B-4B24-430F-96FC-924632C2CF53/summary.md`；`relocation-single-negative.log` |
| example 单元测试 | Dart，flutter test test | 131/131 通过 | `relocation-example-tests.log` |
| example 静态分析、case mapping | Flutter/Dart | 通过 | `relocation-analyze.log`；mapping 命令终端输出 |
| nightly 循环与 workflow | bash / YAML / 临时 stub | 通过：双平台均调用4批，单批失败仍继续并返回1；调用者配置保留，自建配置清理 | 本轮执行记录，stub 未归档；不是设备业务通过 |

本轮迁移复验汇总：CI 设备4批、10次用例执行全部通过（9个不同 ID，CONV-013 在两个配置下各执行一次）；单设备2个脚本、共6步全部通过；example 131项单元测试通过。静态分析、映射、格式、shell/YAML和循环分支检查通过；无新增SDK失败。未执行所有平台组合或完整 nightly，既有失败继续跳过。

正向与逆向 JSON 分别独立初始化、运行；原六步断言与清理均保留。特殊批次通过不证明其他平台通过。下文旧统计和旧路径是迁移前证据，保留供追溯，不能作为当前布局已经执行的证明。

## 迁移前执行统计

按“用例 ID/测试名 + 平台”去重，结果列互斥；复验不增加总数。“后续跳过”是处理决定，不与通过/失败等结果相加。以下旧批次均属于本次覆盖任务、暂停前已执行，非升级阶段的历史通过数。恢复后不重复双端全量运行。

| 类别 | 平台/组合 | 单位 | 计划总数 | 通过 | 失败 | 阻塞 | 未执行 | 暂停 | 后续跳过（另计） |
|---|---|---|---:|---:|---:|---:|---:|---:|---|
| CI 单元/契约 | Dart，SDK | 测试 | 76 | 76 | 0 | 0 | 0 | 0 | 0 |
| example 单元 | Dart | 测试 | 131 | 131 | 0 | 0 | 0 | 0 | 0 |
| CI 设备 | Android | 用例 | 54 | 51 | 3 | 0 | 0 | 0 | 3：CONV-006、MSG-006/007 |
| CI 设备 | iOS | 用例 | 54 | 51 | 3 | 0 | 0 | 0 | 3：CONV-006、MSG-006/007 |
| 单设备平版 | Android | JSON 场景 | 1 | 1 | 0 | 0 | 0 | 0 | 0 |
| 单设备平版 | iOS | JSON 场景 | 1 | 1 | 0 | 0 | 0 | 0 | 0 |
| 多设备业务 M1 | iOS 发起 / Android 观察 | 场景 | 1 | 1 | 0 | 0 | 0 | 0 | 0 |
| 多设备业务 M3 | Android 群主 / iOS 受邀人 | 场景 | 1 | 1 | 0 | 0 | 0 | 0 | 0 |
| flow_runner 工具 | Dart | 测试 | 91 | 91 | 0 | 0 | 0 | 0 | 0 |
| multi 工具 | Dart | 测试 | 251 | 251 | 0 | 0 | 0 | 0 | 0 |
| 单设备报告器 | Dart | self-test 命令 | 1 | 1 | 0 | 0 | 0 | 0 | 0 |
| quality | Dart/仓库 | 检查流程 | 1 | 1 | 0 | 0 | 0 | 0 | 0 |
| CI 入口补充检查 | shell/YAML/stub/format | 检查类别 | 4 | 4 | 0 | 0 | 0 | 0 | 0 |

- 迁移前非设备单元/工具测试合计 549 项通过：SDK 76、example 131、flow_runner 91、multi 251；不与场景/步骤相加。
- 迁移前 CI 设备：计划 108 个用例×平台项，已执行 108，102 通过、6 失败、0 未执行。共 55 个不同已执行 ID，不能说成 108 种业务场景。
- example 暂停前 123 项通过；之后增加 5 项 REST 缺失资源判据测试和 3 项用户 fixture 测试，恢复后全部 131 项通过（`example-tests-final.log`）。最终 quality 已通过，SDK 76 项、五处 analyze、映射、契约与版本检查通过（`quality-final-r2.log`）。
- 单设备：同一 JSON 场景分别在两端各执行一次，均 6/6 步骤通过、0 失败、0 阻塞；共 12 个步骤执行，不计成 12 个场景。群配置回读不能证明完整群邀请接受流程。
- 多设备：用户已批准 M1 群信息更新事件（iOS 发起 / Android 观察）、M3 群邀请接受（Android 群主 / iOS 受邀人），各一组组合；共 2 个选测场景，轮次 `20261109-181640-batch-9d9de4de` 已完成，2/2 场景首次通过，0 失败、0 未执行、0 未完成、0 任务故障；M1 17/17、M3 15/15 步骤通过（共 32 个步骤执行，含清理）。单次通过只证明本轮成功，不证明长期稳定或未选设备组合。M2 会话免打扰同步已确认暂缓，不计选测通过。multi 工具单测不能计作多设备业务通过。

### 迁移前恢复阶段的最小选测清单

| 选择 | 平台/入口 | 状态 | 原因与补测条件 |
|---|---|---|---|
| FL-MSG-010 服务端历史保存更新 latestMessage | Android，`integration_test/history_last_message_test.dart` | 通过，1/1 | Android 发布说明修复；先验证 Android，不默认补 iOS |
| FL-USERINFO-001 订阅列表 | iOS，`integration_test/user_info_subscription_test.dart` | 通过，1/1 | iOS 发布说明修复；新建独占非好友 peer，订阅/查列表/取消订阅/清理；不默认补 Android |
| 最终 quality | 根 `FORMAT_BASE_SHA=HEAD bash tool/ci/run_quality.sh` | 通过 | `quality-final.log` 因暂停前诊断代码格式失败；纯格式修正后 `quality-final-r2.log` 通过 |
| example 全部单测 | `im_flutter_sdk/example`：`flutter test --reporter expanded` | 通过，131/131 | fixture 有后续修改；实际日志 `example-tests-final.log` |
| M1 群信息更新事件 | iOS 发起 / Android 观察，`5.0.0-multi-group-create-device-sync-positive` | 首次通过，17/17 步骤 | 同账号双设备，关联本轮 GROUP_CREATE / GROUP_UPDATE，并核对更新后的群名 |
| M3 群邀请接受 | Android 群主 / iOS 受邀人，`5.1.0-multi-group-invite-confirm-positive` | 首次通过，15/15 步骤 | 本轮邀请事件关联 groupId 与 inviter，接受后双方成员列表包含受邀人 |

设备执行入口在仓库根：`E2E_CONFIG_PATH=<忽略的配置文件> bash tool/ci/run_android_emulator_test.sh integration_test/history_last_message_test.dart resume-history-android.log`；iOS 对应 `run_ios_simulator_test.sh integration_test/user_info_subscription_test.dart resume-userinfo-ios.log`。两项均首次运行通过，无重试；日志见下表。上述两个用例另一平台不在本轮选测范围；出现具体跨端差异或用户要求时再补。

### 本轮多设备执行入口

在 `testing/multi/` 通过仅包含 M1/M3 的选择文件执行 `dart run bin/cli.dart all --cases config/cases-510-approved.json`。轮次 `20261109-181640-batch-9d9de4de`，runner 日志 `multi-approved-runner.log`，退出码 0。汇总为 [`summary.md`](../../../testing/multi/reports/20261109-181640-batch-9d9de4de/summary.md)，逐步业务结果见下表。

## 迁移前已执行结果与证据

| 行为/用例 | 平台 | 真实入口与状态 | 核心预期与实际 | 日志/报告 | 清理 |
|---|---|---|---|---|---|
| M1 同账号群更新事件 | iOS 发起 / Android 观察 | 多设备 CLI 本轮第 1 次；17/17 步骤通过 | GROUP_CREATE / GROUP_UPDATE 关联本轮 groupId；更新调用与群名详情一致 | `testing/multi/reports/20261109-181640-batch-9d9de4de/5.0.0-multi-group-create-device-sync-positive/1/flow-report.json` | destroy 与两端 logout 均通过 |
| M3 群邀请接受 | Android 群主 / iOS 受邀人 | 多设备 CLI 本轮第 1 次；15/15 步骤通过 | 邀请事件同一条内匹配本轮 groupId 与 inviter；受邀人接受成功；双方 fetch_members 的 data.list 均包含受邀人 | `testing/multi/reports/20261109-181640-batch-9d9de4de/5.1.0-multi-group-invite-confirm-positive/1/flow-report.json` | destroy 与两端 logout 均通过 |
| Nightly 全部 35 例 | Android | 根 `bash tool/ci/nightly_local.sh android`；首轮 32 通过/3 失败，复验 33/2 | 失败详情见问题表；新 CONV-010/011/012/013(false)、GROUP-008 均通过 | `nightly-android.log`、`nightly-android-r2.log` | 首轮 room 缺失判据失败，修复后核查删除成功；suite logout 成功 |
| Nightly 全部 35 例 | iOS | 根 `bash tool/ci/nightly_local.sh ios`；33 通过/2 失败 | MSG-007 状态失败；CONV-006 首轮被诊断查询打断，随后单例确认原计数失败；其他新例通过 | `nightly-ios.log`、`conv006-ios-diagnostic.log` | fixture 与 suite logout 完成 |
| Smoke 全部 17 例 | Android/iOS 各一次 | 根 `bash tool/ci/smoke_local.sh android` / `ios`；各 16 通过/1 失败 | FL-MSG-006 error=201 正确，但最终回调状态 PROGRESS，预期 FAIL | `smoke-android.log`、`smoke-ios.log` | 无本轮远端资源 |
| FL-USERINFO-001 | iOS | 根 `run_ios_simulator_test.sh integration_test/user_info_subscription_test.dart resume-userinfo-ios.log`；1/1 | 订阅本轮独占离线非好友 peer 后列表包含一次，取消后不再包含 | `artifacts/resume-userinfo-ios.log`（仓库根） | fixture cleanup 完成、logout 完成 |
| FL-MSG-010 | Android | 根 `run_android_emulator_test.sh integration_test/history_last_message_test.dart resume-history-android.log`；1/1 | `needSave=true` 拉取本轮服务端消息，latestMessage 从旧 sentinel 更新到同一 REST 消息 ID | `artifacts/resume-history-android.log`（仓库根） | 本轮 REST 群、本地会话清理验证成功，logout 完成 |
| FL-AUTH-007 | Android/iOS 各一次 | `run_android_emulator_test.sh` / `run_ios_simulator_test.sh` 运行 `integration_test/native_defaults_test.dart`；各 1/1 | 未传 dataSyncType，实际 start/finish type=1，error=null；不宣称验证了服务端历史内容 | `default-sync-android.log`、`default-sync-ios.log` | 两端均 `cleanup verified: logged out` |
| FL-CONV-013，显式 enableChatroomConversation=true | Android/iOS 各一次 | `single_account_local_test.dart` 定向 `--plain-name FL-CONV-013`，配置 E2E_CHATROOM_CONVERSATION=true；各 1/1 | 真实 send 的关联最终 SUCCESS，列表包含本轮 room；与 nightly 默认 false 排除一起覆盖开关 | `chatroom-true-android.log`、`chatroom-true-ios.log` | 两端均远端 room、本地会话清理成功 |
| FL-CONV-006 诊断 | Android 两次、iOS 一次 | `single_account_local_test.dart` 定向 `--plain-name FL-CONV-006` | Android autoLoad=false 独立通过一次，true 失败；iOS false 计数失败。不能用单例通过覆盖全量失败 | `conv006-android-autoload-false.log`、`conv006-android-autoload-true.log`、`conv006-ios-diagnostic.log` | suite logout 完成 |
| 群配置 true→false、非法分页游标 | Android | 根 `make auto-report PLATFORM=android DEVICE=emulator-5554 SCRIPT=testing/single/cases/script_510_group_config.json`；6/6 步骤 | create/fetch true，update/fetch false；invalid cursor 精确 110 | `reports/5.0.0/20261109093008-android-emulator-5554/summary.md`；`single-android.log` | destroy_group 成功 |
| 同一 JSON 场景 | iOS | 根 `make auto-report PLATFORM=ios DEVICE=4BEA133B-4B24-430F-96FC-924632C2CF53 SCRIPT=testing/single/cases/script_510_group_config.json`；6/6 步骤 | 同上 | `reports/5.0.0/20261109093201-ios-4BEA133B-4B24-430F-96FC-924632C2CF53/summary.md`；`single-ios.log` | destroy_group 成功 |
| 仓库 quality | Dart | 根 `FORMAT_BASE_SHA=HEAD bash tool/ci/run_quality.sh`；初轮 lint 失败，复验通过；恢复首轮 format 失败，最终复验通过 | 五处 analyze 无问题，SDK 76 项、mapping/contracts/version 检查通过 | `quality.log`、`quality-r2.log`、`quality-final.log`、`quality-final-r2.log` | 不适用 |
| example 单元 | Dart | `im_flutter_sdk/example`：`flutter test --reporter expanded`；最新 131 项通过 | 暂停前 123 项、恢复后新增 8 项均通过 | `example-tests.log`、`example-tests-final.log` | 不适用 |
| flow_runner | Dart | `tool/flow_runner`：`dart analyze`、`dart test`；91 项通过 | 工具能力与现有单测通过 | `flow-analyze.log`、`flow-tests.log` | 不适用 |
| multi 工具 | Dart | `testing/multi`：`dart analyze`、`dart test`；原 243 项通过，新增场景回归后完整 251 项通过 | 工具单测通过，不替代 SDK 多设备业务结论 | `multi-analyze.log`、`multi-tests.log`、`multi-tests-final-r3.log` | 不适用 |
| 单设备报告器 | Dart | 根 `dart run testing/single/auto_report.dart --self-test`；通过 | 报告判定自测 | `single-self-test.log` | 不适用 |

### 迁移前 CI 入口补充检查

- `bash -n tool/ci/run_nightly_suites.sh tool/ci/nightly_local.sh` 通过；workflow 用 Python `yaml.safe_load` 解析通过。
- 临时 stub 验证：首套返回失败后，Android 的 3 套、iOS 的 2 套仍全部被调用，最终退出码为 1，失败不被后续成功掩盖。该检查验证入口编排，不是新增一轮 SDK 设备测试。临时 stub 的原始输出未归档，结论来自本次执行记录，证据完整性弱于已留日志的设备结果。
- 多设备所需 `group_apis.dart` 注册静态分析通过；example `test/scenario_api_registry_test.dart` 12/12 通过（本次终端输出，未单独归档；属于已有 131 项内的定向复验，不增加去重数量）。
- 三份新独立集成测试文件 Dart format 检查通过；case mapping 通过证据在 `quality-final-r2.log`。CI 入口的 shell/YAML/stub/format 四类检查不并入业务用例数。本轮多设备改动相关三份 Dart 文件 format 检查 0 变化，`git diff --check` 通过。

### 已执行选择与次数核对

- Nightly：AUTH-001/002/003/006，CONTACT-001/002/003/004/010，CONV-001～013，GROUP-001/002/006/007/008，MSG-001～005/007/008/009；共 35 个 ID。
- Smoke：APP-001，PRESENCE-001～005，AUTH-004/005，CONTACT-005～009，GROUP-003～005，MSG-006；共 17 个 ID。
- 另加 AUTH-007；上述每个 ID 均有 Android、iOS 证据。CONV-013 的 true/false 分支分开留证，但不重复增加 ID×平台数量。
- 恢复前 CI 设备共 12 次命令执行：nightly 3 次、smoke 2 次、AUTH-007 2 次、CONV-006 诊断 3 次、CONV-013 true 2 次。共 146 次用例尝试，135 次通过、11 次失败；这是尝试数，不是最新去重结果。恢复后 MSG-010 Android、USERINFO-001 iOS 首次运行均通过，累计 14 次设备命令、148 次用例尝试（137 通过、11 失败）。
- 多设备本批 1 次 CLI 全流程命令，2 个场景各首次执行 1 次，均通过，共 32 个步骤执行；未追加换向或其他组合。
- 单设备 JSON 2 次；quality 已启动 4 次（初轮 lint 与恢复后首轮格式检查失败均未进入 SDK 测试，最终复验已通过）；example 单测 2 次，flow、multi 单测各 1 次；报告器 self-test 1 次。本轮多设备实现后另有 34 项相关工具测试通过；完整工具测试启动三次，首轮缓存权限阻止启动，第二轮本机端口权限导致 4 项失败，第三轮完整 251 项通过。example 注册相关 12 项定向复验通过。静态分析与设备业务计数不相加。

## 失败、三次上限与最终确认

用户已要求“这俩问题先记录吧，跳过，继续”，沿用为会话计数问题与消息失败状态问题。新 skill 的三次上限从恢复后严格执行；旧批次实际超过三次的证据如实保留，不抹除或重置。下面不把尚未确定同根因的 MSG-006/007 强行合并计数。

| 问题 ID / 用例 | 阶段与预期/实际 | 实际未通过次数与证据 | 归因及确定程度 | 处理与待确认 |
|---|---|---|---|---|
| P-CONV-COUNT / FL-CONV-006，双端 | deleteAllMessages 后预期 count=0；实际 count=1，但 ids=[]；Android last=null，iOS lastLookup=error:3 | 4 次计数失败：`nightly-android.log`、`nightly-android-r2.log`、`conv006-android-autoload-true.log`、`conv006-ios-diagnostic.log`。Android false 单例另有一次通过；iOS 首轮诊断异常另列 | SDK 计数/缓存不一致为候选；公开清除契约与读取结果不一致，具体 native 根因未知。不能归因 autoLoad=false，true 也失败 | 用户已决定跳过；不重跑、不弱化断言。待用户确认是否另开 SDK 定位任务；详见 [分析记录](../../refs/troubleshooting/2026-11-09-conversation-count-after-clear.md) |
| P-SEND-EMPTY / FL-MSG-007，双端 | 空 target 最终错误回调 code=500，但 status=PROGRESS，预期 FAIL | 3 次：`nightly-android.log`、`nightly-android-r2.log`、`nightly-ios.log` | 回调错误与消息状态分开观察；状态传递/native 行为问题候选，确切层次未知 | 用户已要求跳过，且达到三次；保留失败，待确认是否单独定位 |
| P-SEND-LOGOUT / FL-MSG-006，双端 | 未登录最终错误回调 code=201，但 status=PROGRESS，预期 FAIL | 2 次：`smoke-android.log`、`smoke-ios.log` | 与 MSG-007 现象相似，尚无证据认定根因相同 | 用户要求提前跳过，不为凑三次再跑；待确认与 MSG-007 是否合并定位 |
| P-CONV-DIAGNOSTIC / iOS FL-CONV-006 | 临时诊断 loadMessage 读取已删消息抛 code=3，中断原 count 断言 | 1 次：`nightly-ios.log` | 已确认诊断代码问题；改为捕获并记录缺失读取错误，保留原 count/list 断言 | 修正后的 `conv006-ios-diagnostic.log` 已到达原 count 断言并失败，归入 P-CONV-COUNT；不能把诊断修好记为用例通过 |
| P-ROOM-CLEANUP / FL-CONV-013 | 首轮业务通过，但 room 删除后 GET 缺失判据不接受服务端 group 文案 | 1 次：`nightly-android.log` | 已确认测试 fixture 判据问题；严格匹配请求 room ID 的缺失响应，未放宽业务断言 | 已修正，`nightly-android-r2.log` 及双端 true 运行均清理成功；[记录](../../refs/troubleshooting/2026-11-09-chatroom-rest-missing-response.md) |
| P-MULTI-CACHE / multi 工具单测启动 | Flutter 启动脚本无法写 SDK cache/engine.stamp，测试未启动 | 1 次：`multi-tests-final.log` | 已确认沙箱权限问题；未运行 SDK 设备用例 | 使用直接 Dart 执行；不计业务失败 |
| P-MULTI-LOOPBACK / multi 工具单测 | 本机 HTTP 监听被沙箱拒绝，4 个工具测试失败，其余 247 通过 | 1 次：`multi-tests-final-r2.log` | 已确认本地端口权限问题；无源码修补 | 申请本地端口执行后 `multi-tests-final-r3.log` 251/251 通过；不计 SDK 设备失败 |
| P-FORMAT / 恢复后 quality | 暂停前 CONV-006 诊断代码未符合 Dart format | 1 次：`quality-final.log` | 已确认测试代码格式问题，无业务改动 | 纯格式修正，`quality-final-r2.log` 复验通过 |
| P-LINT / quality | 新增 if 缺少 braces，lint 不通过 | 1 次：`quality.log` | 已确认测试代码问题 | 修复后 `quality-r2.log` 通过；最终新增文件检查已通过 |

业务失败、准备失败和清理失败分别记录。没有出现需要擅改 SDK 架构才能推进的情况。

## 未验证范围与交付边界

- `FL-GROUP-008` 与单设备 JSON 仅证明群配置字段回读；真实 A 邀请 B → B 接受 → 成员关系检查由 M3 单独验证，本轮 Android 群主 / iOS 受邀人组合首次通过；不将字段回读与业务结论混为一项。
- 数据库分页已验证非置顶排序、连续性、集合完整性及非法 cursor；置顶优先级未独立验证。
- 附件最终回调、搜索服务边界、NTP/数据库并发/网络故障注入、事件顺序、私有部署、空入站消息等缺口及理由见覆盖表，不把普通成功调用算作缺陷回归。
- 当前未达到“所有测试无问题”：CI 已知 6 个平台用例项失败，后续跳过；本轮已批准的 CI、单设备和 M1/M3 多设备验证均已完成；本次多设备验证未发现新的 SDK 失败。
- 遗留项：M2 按确认暂缓；附件最终回调等契约缺口继续保留。会话计数与失败消息状态问题已记录，遵守用户跳过决定；需要恢复定位时再明确范围，不擅改 SDK 或执行器架构。
- 清理：本轮设备 fixture 清理完成；M1/M3 本轮群销毁与双方登出均通过，工具汇总无任务故障；临时含凭据文件 `reports/5.1.0/test-coverage/e2e-config.json` 已删除，未提交凭据。
- 提交状态：未提交、未推送。
