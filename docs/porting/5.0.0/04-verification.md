# 5.0.0 平版 · 阶段四：验证记录

## 1. 验证结果

| 验证项 | 结果 | 失败原因/备注 |
| --- | --- | --- |
| `flutter analyze`（主包） | ✅ 通过 | `No issues found` |
| `flutter test`（主包） | ✅ 通过 | 30 个测试全部通过，含 version/contract checker 与 `ChatCursorResult.totalCount` 双场景 |
| example Android：`flutter build apk --debug` | ✅ 通过 | 生成 `app-debug.apk`；3 个 Java 8/deprecation/unchecked warning，不是错误 |
| iOS CocoaPods 首次构建 | ⚠️ 环境预期失败 | Podfile.lock 锁定 HyphenateChat 4.24.1 |
| `pod install --repo-update` → `pod update HyphenateChat` | ✅ 通过 | 安装 HyphenateChat 5.0.0、im_flutter_sdk_ios 5.0.0、ShengwangInfra_iOS 1.3.5 |
| example iOS CocoaPods：`flutter build ios --debug --no-codesign` | ✅ 通过 | 生成 `Runner.app` |
| example iOS SPM：启用 SPM、clean、pub get 后同命令构建 | ✅ 通过 | HyphenateChat_iOS 5.0.0 / ShengwangInfra_iOS 1.3.5；生成 `Runner.app` |
| 恢复 Flutter 全局 SPM 配置 | ✅ 通过 | `enable-swift-package-manager: false`，与任务前一致 |
| iOS wrapper `clang -fsyntax-only`（native 5.0 headers） | ✅ 通过 | 全部 `.m` 通过；基线 APNs token NSString→NSData warning 保留 |
| 三端方法 key / 路由 contract checker | ✅ 通过 | 测试及 `porting_guard.sh gate` 均通过 |
| 新模型 barrel 导出链 | ✅ 通过 | `flutter analyze`/测试实证 |
| 四包版本与 podspec 版本 | ✅ 通过 | 全部 5.0.0 |
| 三处 native 依赖版本 | ✅ 通过 | podspec / Package.swift / build.gradle 全部 5.0.0 |
| API 脚本回归（Android 15 模拟器） | ✅ 通过（第 9 节口径） | 正向 20/20 `20260918111406-android-emulator-5554`、反向 10/10 `20260918111505-android-emulator-5554`；`fetchGroupMessageReadReceipts` 缺失消息用例按用户决定屏蔽（历史崩溃证据 `20260918041624-android-emulator-5554`） |
| API 脚本回归（iOS 18.2 模拟器） | ✅ 通过（第 9 节口径） | 正向 20/20 `20260918111433-ios-4BEA133B-4B24-430F-96FC-924632C2CF53`、反向 10/10 `20260918111526-ios-4BEA133B-4B24-430F-96FC-924632C2CF53`；双端对比步骤与错误码不一致均为 0 |
| RN 对照修订：`ChatCursorResult.totalCount` | ✅ 通过 | Dart 模型正数/null 单测通过；iOS wrapper 参考 RN 转发 native callback，真实回归确认零值为 `0`；Android 保持 null |
| example 环境工具单测 | ✅ 通过 | 8 个测试覆盖公有集群、唯一 ngi 自动选择与旧 ebs 引用迁移、多集群默认值校验、顶层私有化 `msyncServer→imServer`、私有模式只生成 `env.private.dart`、Dart 渲染、本地 HTTP App/User Token 流程与集群激活 |
| 5.0.0 脚本覆盖测试 | ✅ 通过 | 5 个测试覆盖 `success/errorCode`、依赖失败跳过、conversation 结构化输出、正/反脚本注册与可配对 API、断言方向（正向含 mixed 批次用例）；example 全量 13 个测试通过 |
| example `flutter analyze` | ✅ 通过 | `No issues found`，含 env 工具、人工页预填和自动模式默认 env 数据源 |
| example Android env 链路构建 | ✅ 通过 | `make config` 生成/保留占位环境后，`flutter build apk --debug` 成功生成 `app-debug.apk` |

## 2. 契约逐字抽查

以下 key 在 Dart `ChatMethodKeys`、Android `MethodKey.java`、iOS `MethodKeys.h` 中逐字一致，且 contract checker/guard 通过：

```text
sendMessageReadReceipts
clearConversationUnreadMessageCount
clearAllConversationUnreadMessageCount
getGroupMessageReadReceipts
fetchGroupMessageReadReceipts
updateGroupConfigs
onDataSyncStart
onDataSyncFinish
onDatabaseOpened
onMessageReadReceipts
```

JSON 抽查：

- client：`userId/token/resource`。
- read receipts：`msgIds/conversationId/messageId/groupId/cursor/pageSize/receipts`。
- message：`isPeerRead/isRead/isNeedReadReceipt/groupReadReceiptCount`。
- group configs：`maxCount/inviteNeedConfirm/ext/isPublic/joinApprovalRequired/allowInvites`；请求 `groupId/types/configs`。
- conversation：`name/avatar`。
- connection events：`type/error/username`。

## 3. 删除项抽查

Dart public 层与两端有效 wrapper 代码 grep 无以下 4.x 残留：密码/Agora 登录、注册、autoLogin/requireAck/enableAutoSyncContacts、旧逐条/群/会话回执、旧回执事件、`ChatGroupOptions/ChatGroupStyle/ChatGroupMessageAck`、旧服务端会话/联系人/群组拉取、消息举报、聊天室创建/销毁。

## 4. 构建副产物处理

- 保留：example `pubspec.lock` 的四包 5.0.0 更新；iOS `Podfile.lock` 的 HyphenateChat 5.0.0 / im_flutter_sdk_ios 5.0.0 / ShengwangInfra_iOS 1.3.5 更新。
- 还原：SPM 构建造成的 pbxproj CocoaPods phase UUID 变化。
- 删除：两个未跟踪的 SPM `Package.resolved` 构建副产物。
- Flutter 全局 SPM 开关已恢复为 false。

## 5. 最终 gate

```text
$ echo '{}' | bash /Users/asterisk/Codes/zuoyu_flutter/.agents/skills/platform-sdk-porting-v2/hooks/porting_guard.sh gate flutter /Users/asterisk/Codes/zuoyu_flutter/im_flutter_sdk/.worktree/5.0.0
（无输出）
gate_exit=0
```

构建与静态检查门禁通过；真实功能回归已关闭群回执服务、conversation 可检查性和 iOS `totalCount` 问题。Android 崩溃及三项不存在消息错误语义按用户决定不在 Flutter wrapper 修复，转由 iOS/Android native 统一，详见下节与验收报告。

## 6. 真实 auto 模式补充验证（2026-09-18）

- Android：`emulator-5554`，Android 15 / API 35；脚本从应用专属外部目录读取。
- iOS：iPhone 16 Pro simulator，iOS 18.2；脚本从宿主机绝对路径读取。
- 两端均使用生成的 `env.dart`，成功完成 init、Token 登录，并观察到 `onDatabaseOpened`、`onDataSyncStart`、`onDataSyncFinish`。
- 用户确认群回执服务开通后，本轮 Android 与 iOS 的群消息发送、本地回执、服务端分页和批量发送回执全部通过，未再出现 505；先前 505 归为环境状态，当前关闭。
- Android 当前代码权威运行：`20260918041624-android-emulator-5554`，19 步通过后在不存在消息分页路径触发 native NPE，1 步崩溃、1 步未运行。临时 wrapper 判空运行 `20260918071416-android-emulator-5554` 曾达到 21/21，证明问题入口，但 Java 修改已由用户还原，不代表本次提交结果。
- iOS 权威运行：`20260918071144-ios-4BEA133B-4B24-430F-96FC-924632C2CF53`，20/21 通过、无崩溃、`script.done={total:21,failed:1,blocked:0}`。唯一失败仍为不存在消息分页返回成功空列表。
- iOS 群回执 happy path 返回 `{cursor: "", list: [], totalCount: 0}`，证明 wrapper 已转发 native callback；Android native 不提供该字段，保持 null。
- 003/004 复核：两个批量 API 的 native 入参均为消息对象；不存在 ID 在 native 调用前由 Flutter wrapper 查库。Android wrapper 主动构造 `GENERAL_ERROR(1)`，iOS wrapper 主动构造 `MESSAGE_INVALID(500)`。用户决定 Flutter 暂不统一，待 iOS/Android native 明确并修复一致语义后再跟随。
- 005 复核：Android native 只接收 messageId，并从本地消息推导 groupId；iOS native 同时接收 messageId/groupId。不存在消息时 Android NPE、iOS 返回空成功，确属 native API 形态与行为差异；用户决定崩溃和语义均由 native 修复，Flutter 不保留临时判空。
- 原 `emulator-5554` 由其他流程以 `-no-window` 启动，没有可见窗口；关闭后用同一 `Pixel_9` AVD 以窗口模式重启，运行器成功输出 `Activated Android emulator window`。报告工具现会明确识别 headless 进程，不再误报为置前失败。

## 7. 后续运行报告流程

- 入口：`make auto-report PLATFORM=<android|ios> [DEVICE=<id>] [SCRIPT=<json>]`（默认执行正向脚本）与 `make auto-compare ANDROID=<run-dir> IOS=<run-dir>`。
- 运行器显式激活 iOS Simulator；Android 通过 adb 唤醒并尽力将非 headless qemu 窗口置前；若 AVD 以 `-no-window` 启动，会明确提示其没有可激活窗口。
- Android 通过 `adb shell run-as` 把脚本写入 App 内部目录 `/data/data/com.example.example/files/`（`/sdcard/Android/data/...` 在目录由 adb 创建时属 `shell:ext_data_rw`、权限 0770，App 读不到，见第 10.3 节）；iOS 使用宿主机绝对路径。
- 只保存 `[APITEST]` 结构化事件与崩溃关键行，写入 Git 忽略的 `reports/5.0.0/<run-id>/`；不保存完整 native stdout，避免密钥/Token/原始网络日志进入报告。
- 每次运行生成 `run.json`、`events.jsonl`、`crash.log`、`steps.json`、`summary.md`、`issues.md`；逐步结果按 `expect` 分类为 `passed/failed/blocked/crashed/not-run`。
- app 端从参数中的 `$step.<id>` 自动识别依赖；生产步骤失败后，依赖步骤输出 `skipped=true/blockedBy=<id>`，不调用 SDK，报告将其归类为 `blocked` 而不是新问题。
- `run.json` 保存 commit、worktree dirty 状态、脚本/runner SHA-256、平台、设备和 cluster，不保存 `clientSecret`、App Token 或 User Token。
- `issues.md` 使用语义化 candidate key 供人工确认，不在运行器中硬编码版本化问题编号；确认结论再同步到本文件和 `acceptance-report.md`。

## 8. 第五轮：正向/反向用例拆分与双端对比（2026-09-18）

用例结构调整：

- 原 `script_500_apis.json`（21 步混合）拆为 `script_500_apis_positive.json`（20 步，只断言成功）与 `script_500_apis_negative.json`（10 步，只断言错误码）。
- 正向路径覆盖 5.0.0 新增/修改 API 的正常路径：未读数统计与清理、`modifyMessage`（含 attributes）、群配置创建与更新、4 个已读回执 API、设备管理 token 鉴权与 `renewToken`；`sendMessage`/`destroyGroup` 仅用于准备与清理。`kickDevice` 改用 `fetchLoggedInDevices` 返回的真实 resource，会踢掉本端，因此与 `kickAllDevices` 一起固定在正向末尾。
- 正向另含 `group_receipts_local_mixed` / `receipt_group_mixed` 两条「批次混入无法解析 id」用例：回执结果以 native 为准，双端 native 都忽略无法解析的 id 并处理其余消息，因此断言成功。
- 反向路径只使用单账号可稳定构造的非法参数、缺失资源与无效 token；无参数的本地查询没有可控错误输入，不为凑数量机械构造反例。双账号场景（`onMessageReadReceipts`、非空群成员信息）按用户决定仍不纳入本轮。
- `fetchGroupMessageReadReceipts` 的不存在消息场景已确认令 Android native 崩溃，按用户决定不单独出脚本、也不执行：反向脚本屏蔽该步骤，报告固定输出 `fetch-group-receipt-missing-disabled` known-crash 候选项；运行中真实发生的崩溃仍按 `crashed/not-run` 分类写入 `crash.log` 与候选清单。

报告工具改造：

- `make auto-report PLATFORM=... [SCRIPT=...]` 默认执行正向脚本，反向脚本用 `SCRIPT=im_flutter_sdk/example/scripts/script_500_apis_negative.json`；`run.json`/`summary.md` 记录实际脚本路径与路径类型（positive/negative）。
- 新增 `make auto-compare ANDROID=<run-dir> IOS=<run-dir>`：按步骤对比双端状态、结果语义（`success`/`errorCode`）与响应结构，产物为 `reports/5.0.0/comparison-<路径>-<时间戳>.md`；存在步骤不一致时退出码为 1。反向路径额外输出 `## Error codes` 表，逐步给出「脚本期望 / Android / iOS」错误码。
- `issues.md` 按路径类型生成候选项：反向路径固定记录被屏蔽的崩溃用例；`modify_self` 的 305 标注为环境限制；群回执分页 `totalCount` 缺失改为平台无关的 `group-receipt-total-count-missing`。

本轮同时修复一个报告工具缺陷：

- 设备控制台会截断约 1 KB 以上的单行日志，`loadAllConversations` 这类大事件 JSON 被截断后整步丢失（中间运行 `20260918094340-ios-...`、`20260918094448-android-...` 均为 6 通过 / 12 未运行，`crash.log` 可见被截断的原始行）。
- 修复：`LogStore` 把超过 512 字节的事件按 UTF-8 字节切分成 `[APITEST+<index>/<total>]` 有序分片输出，文件副本仍保留完整单行记录；运行器重组分片，并把无法识别的 `[APITEST` 行计入 `summary.md` 的 `Malformed APITEST lines` 与 `apitest-line-not-reassembled` 候选项，不再静默丢弃。

权威运行（同一版 runner；Android 15 / API 35 `emulator-5554`，iOS 18.2 iPhone 16 Pro simulator，集群 ngi）：

| 路径 | Android | iOS | 结论 |
| --- | --- | --- | --- |
| 正向 20 步 | `20260918111406-android-emulator-5554` 20/20 | `20260918111433-ios-4BEA133B-4B24-430F-96FC-924632C2CF53` 20/20 | 双端无崩溃、无 malformed 行；含 mixed 批次用例；`modifyMessage` 返回成功（消息编辑服务已可用），无 305 |
| 反向 10 步 | `20260918111505-android-emulator-5554` 10/10 | `20260918111526-ios-4BEA133B-4B24-430F-96FC-924632C2CF53` 10/10 | 双端无崩溃，双端逐步命中同一错误码 |
| 正向双端对比 | `reports/5.0.0/comparison-positive-20260918111551.md` | 步骤不一致 0 | 仅响应结构差异，见下 |
| 反向双端对比 | `reports/5.0.0/comparison-negative-20260918111552.md` | 步骤不一致 0、错误码不一致 0 | 双端错误码逐项一致 |

反向错误码（双端一致）：非法群成员 600、不存在群 600、缺失修改消息 500、空会话 ID 110、无任何可解析消息的回执批次 110、设备管理三方法无效 token 303、`renewToken("")` 104。

正向响应结构差异（均为既有字段差异，不是 5.0.0 新增语义）：

- 群对象：Android 额外返回顶层 `maxUserCount`/`ext`，与 `configs` 内同名字段重复；iOS 只返回 `configs`。
- 消息体：Android 返回 `body.translations`，iOS 不返回；iOS 返回 `receiverList`，Android 不返回。
- 群回执分页：Android `totalCount: null`，iOS `0`。

## 9. 第六轮：回执批次语义改为完全由 native 决定（2026-09-18）

用户裁决：**回执类 API 的结果以 native 为准，Flutter wrapper 不做任何判空或错误码构造**。据此修改：

- Android `ChatManagerWrapper.messagesFromIds`：从「任一 id 无法解析就整批返回 null」改为「跳过无法解析的 id，把可解析的消息交给 native」（与 iOS `messagesWithIds` 一致），删除 `sendMessageReadReceipts` / `getGroupMessageReadReceipts` 中构造 `GENERAL_ERROR(1)` 的判空分支。
- iOS `ChatManagerWrapper.m`：删除 `sendMessageReadReceipts` / `getGroupMessageReadReceipts` 中构造 `MESSAGE_INVALID(500)` 的判空分支（`invalidMessagesErrorIfNeeded` 因此成为死代码）。

上游依据（grep 实证）：Android native `EMChatManager.sendMessageReadReceipts` / `getGroupMessageReadReceipts`（`EMChatManager.java:987`、`:2893`）对 list 做 `if (messages != null)` 容错；iOS native 用 `for (in aMessages)` 遍历（nil-safe，`EMChatManager.mm:2123`、`:2180`）。两端最终都把「可解析消息集合」交给同一套 core，核心对空集合返回 `110 INVALID_PARAM`（`messages is empty`）。

复验结论：

- 全为无法解析 id 的批次：双端 `110 "messages is empty"`（改动前为 Android 1 / iOS 500，均为 wrapper 构造）。
- 混入无法解析 id 的批次：双端 success，并返回可解析消息的回执（改动前 Android 整批丢弃返回 1、iOS 500 拒绝整批）；该语义已由正向脚本的 `group_receipts_local_mixed` / `receipt_group_mixed` 钉住。
- 正向 20 步、反向 10 步双端全通过，两份对比报告步骤不一致与错误码不一致均为 0。
- 仍未处理：`fetchGroupMessageReadReceipts` 缺失消息在 Android native 触发 NPE，继续按用户决定屏蔽并记录 `fetch-group-receipt-missing-disabled`。
- 顺带修复 Android wrapper 文件的换行符回退：该文件在 HEAD 中为 CRLF 为主 + 118 行裸 LF 的混合结尾，手工编辑时被整体转成 CRLF，已按字节恢复原始结尾，使 `git diff` 只保留上述语义改动。
- 文档更新：`acceptance-report.md` 中「Android 1 / iOS 500、由 native 统一」的旧结论已由本节结论取代；第 6 节 003/004 与第 8 节仍保留当时的事实记录。

## 10. 第七轮：本地 smoke 稳定性、currentUserId 跨端差异、auto 脚本下发（2026-09-20）

### 10.1 本地 no-login smoke 失败原因与修复

现象：`bash tool/ci/smoke_local.sh android` 在 `FL-APP-001 initializes the native SDK while logged out` 失败（`Expected: null` / `Actual: 'zuoyu01'`，退出码 1），同一命令的 iOS 分支通过。

链路与证据（`chat_client.dart:566` 的 `init()` 会调用 `getCurrentUserId()` → native `getCurrentUser`）：

- Android：`ClientWrapper.java:216` → `EMClient.getInstance().getCurrentUser()`，读本地持久化的上次登录用户（SharedPreferences `easemob.chat.loginuser`，per-App，**不区分 appkey**）。受控实验里登录用的是 env 的 `easemob-demo#zuoyu`、smoke 用的是 `easemob#easeim`，仍读到 `zuoyu01`。
- iOS：`ClientWrapper.m:379` → `EMClient.sharedClient.currentUsername`，未恢复该值。受控实验（用 env 账号真实登录 `zuoyu01` 后强杀进程再跑 smoke）仍通过；同 appkey 场景未验证，故记为「已观察到的差异」而非「iOS 免疫保证」。
- 未登录的判据：同一次失败运行中其余 5 个 presence 用例全部以 `201` 通过，说明没有会话，只是残留了身份记录。
- 数据为何还在：`flutter test` 对已安装 App 是覆盖安装（保留 `/data/data`），且只在运行结束后卸载（`--uninstall` 默认 true）。因此任何一次「登录后未登出」的运行（auto-report / nightly / 手工 `flutter run`）都会污染下一次本地 smoke；CI 每次都是全新设备，不受影响。

修复（用户裁决：跑任务前清理，保证测试稳定性）：

- `tool/ci/run_android_emulator_test.sh`：`flutter test` 之前 `adb -s emulator-5554 uninstall com.example.example`（失败忽略）。
- `tool/ci/run_ios_simulator_test.sh`：每次 attempt 之前 `xcrun simctl uninstall <udid> com.example.example`（失败忽略）；重试会重启模拟器但保留 App 数据，故每次都要清。
- 两个脚本都把包名提为顶部常量并注明来源（`build.gradle.kts` 的 `applicationId` / `project.pbxproj` 的 `PRODUCT_BUNDLE_IDENTIFIER`）。App 不存在时 `adb uninstall` 返回非 0、`xcrun simctl uninstall` 返回 0，两者都用 `|| true` 兜底，因此 `device-smoke.yml` 与 `single-account-nightly.yml` 在新设备上的现有调用不受影响（已按 App 不存在的场景本地实测）。
- `no_login_presence_test.dart` 的 `FL-APP-001` 增加注释，说明该断言依赖冷启动前提。

复验：故意用 auto 模式登录 `zuoyu01` 后强杀 App → smoke 稳定失败（`Actual: 'zuoyu01'`）；紧随其后重跑 → 全绿（上一次结束时的卸载已清数据）。加入清理后双端 smoke 均通过（Android `exit 0`、iOS `All tests passed`）。

### 10.2 currentUserId 跨端语义差异（先记录，不在 Flutter 侧修改）

- Android 返回本地持久化的上次登录用户，未登录（无会话）时也可能非空；iOS 未登录时为 nil。同一 Dart API 两端语义不同。
- 影响：调用方不能用 `currentUserId == null` 判断「是否已登录」（当前公开 API 里可用的会话态查询只有 `isConnected()`）；`FL-APP-001` 之所以依赖冷启动，根源即此。
- 用户裁决：先记录，待 iOS/Android native 明确并统一语义后再跟随，处理方式与第 6、9 节的跨端差异一致；Flutter wrapper 保持原样转发。
- 附带待办：`ChatClient.currentUserId`（`chat_client.dart:266`）缺少公开 API 要求的中英双语注释，后续修改该 API 时补齐。

### 10.3 Android auto 脚本下发改用内部目录

- 现象：`make auto-report PLATFORM=android` 在 App 数据被清后失败，App 报 `PathAccessException: Cannot open file, path = '/sdcard/Android/data/com.example.example/files/script_<runId>.json' (OS Error: Permission denied, errno = 13)`。
- 原因：运行器先 `adb shell mkdir -p` 建外部目录再 `adb push`；目录由 shell 创建时属 `shell:ext_data_rw`、权限 `drwxrws---`（实测），App 无法遍历，脚本读不到。此前能成功只是因为该目录已由 App 自己创建过（例如先跑过 `flutter run`）。
- 修复：`tool/auto_report.dart` 改为先确保 debug 包已安装（未安装时 `flutter build apk --debug` + `adb install -r -t`），再用 `adb shell run-as com.example.example sh -c 'cat > /data/data/com.example.example/files/script_<runId>.json'` 以 App uid 写入内部目录，并校验写入字节数（避免半截写入在 App 内表现为难以定位的 `script.error`）；`--dart-define=API_SCRIPT` 相应指向内部路径。`flutter run` 后续的重装会保留内部目录，脚本仍然可用。
- 文档同步：`im_flutter_sdk/example/README.md` 的 Android 手工下发示例改为同一套 `run-as` 写法，并说明 `run-as` 需要 debug 包已安装。

## 11. 第八轮：single-account nightly 凭据链路从密码切到 token（2026-09-20）

### 11.1 根因：测试早已是 token 登录，CI 管线还停在密码

`single-account-nightly.yml` 与 `tool/ci/nightly_local.sh` 都过不去，因为两边的键名对不上，测试在 `setUpAll` 阶段就失败，一条断言都跑不到：

- `integration_test/single_account_local_test.dart:5-7` 读 `E2E_APP_KEY` / `E2E_USER_ID` / `E2E_USER_TOKEN`，`setUpAll` 调 `loginWithToken`；`chat_client.dart:579` 是 5.0.0 唯一的登录入口（`loginWithPassword` 已随 5.0.0 移除，全包只剩改密回调带 password 字样）。
- `tool/ci/write_e2e_dart_defines.sh` 的必填项与输出 JSON 只有 `E2E_USER_PASSWORD`，**从不产出** `E2E_USER_TOKEN` → `requireConfiguration()` 抛 `StateError: Missing dart-defines: E2E_USER_TOKEN`。
- `tool/ci/nightly_local.sh` 同样硬性要求 `E2E_USER_PASSWORD`，本地没有任何地方能产出 token。
- 时间线（`git log -S`）：密码链路来自 4.x 的 `b77bfeff` / `85a9805e`；`dbab80b3`（5.0.0 平版）把测试改成 token 登录却漏改了 CI 管线。该 workflow 只有 `workflow_dispatch`，5.0.0 分支从未被触发，所以一直没暴露；默认分支（4.x）的密码链路在 2026-08-23/24 曾正常跑通。

### 11.2 修复：每个 job 现换一次 user token（对齐 RN 5.0.0）

user token 服务端 TTL 约 24h（本地模板 `tokenTtl: 86400`），不能存成 secret，只能在运行时换取：

- 新增 `tool/ci/fetch_e2e_user_token.sh`：`client_credentials` 换 app token，再带 `Bearer` 用 `grant_type=inherit` + `autoCreateUser=true` 换 user token；流程与 `example/tool/env_tool.dart` 的 `TokenClient` 一致，脚本结构、重试预算（3 次）、间隔（1s）、超时（15s）与输出契约（**stdout 只输出 token**，诊断走 stderr）与 RN 仓库的 `scripts/ci/fetch_e2e_user_token.js` 一一对应，appKey `orgName#appName` 校验、REST 末尾斜杠剥离同样对齐。
- `write_e2e_dart_defines.sh` 的必填项与 JSON 键改为 `E2E_USER_TOKEN`，保持「只做 env→JSON、不联网」的单一职责。
- `nightly_local.sh` 改为要求 `E2E_APP_KEY` / `E2E_USER_ID` / `E2E_REST_API` / `E2E_CLIENT_ID` / `E2E_CLIENT_SECRET`；运行时先换 token 再渲染 dart-define 文件。本地不打 `::add-mask::`——那行命令本身带 token，会把它打到终端。
- `single-account-nightly.yml` 两个 job 的 prepare 步骤改为 5 个 secret + 现换 token + `::add-mask::`，位置仍在模拟器启动之前（认证问题 fail fast）；新增每日 cron `37 18 * * *`，比 RN 的 nightly（`37 19 * * *`）早一小时，与 device-smoke 的 `0 18 * * *` 各自使用独立 runner、且后者不需要凭据，重叠无影响。
- 安全边界：`clientId` / `clientSecret` 只在 runner 上换 token，绝不进 dart-define（因而不进 App 包）；换来的一次性 user token 仍会进 dart-define 文件，该文件 mode 0600、不上传、运行后删除。
- cron 限制：GitHub 的定时任务跑的是**默认分支**最新提交、取默认分支的工作流文件，所以在该文件落地 `flutter2_stable` 之前，5.0.0 分支上的 cron 不会触发，只能手工 dispatch。
- GitHub environment `flutter-single-account`（`easemob/im_flutter_sdk`）新增 `E2E_REST_API` / `E2E_CLIENT_ID` / `E2E_CLIENT_SECRET`；**`E2E_USER_PASSWORD` 保留不动**，默认分支（4.x）的 nightly 仍在用它。

### 11.3 顺带发现的第二个问题：FL-CONV-002 的未读断言没有依据

凭据打通后第一次真正执行断言，`FL-CONV-002 maintains latest and clears unread state` 在 `unreadCount()` 上以 `Expected: <2> / Actual: <0>` 失败，**Android 与 iOS 表现一致**，所以不是跨端差异：

- `ChatConversation.insertMessage` 的公开契约（`chat_conversation.dart:306-322`）只承诺写入本地库并更新 `latestMessage` 等属性，未提及未读数。
- Dart 侧 `ChatMessage.createReceiveMessage` 虽把 `isRead` 置为 false 并随 `toJson` 下发，但两个 wrapper 都没有把它应用到 native 消息上（Android native 的 `setRead` 是包私有，见 `01-api-diff-android.md:117`，wrapper 无法调用），native 按已读落库。
- 追加实验（负结果）：改用 `updateRegradeMessagesAsReadSetting(false)` + `importMessages` 也不行——`messagesCount()` 为 2（导入成功）而 `unreadCount()` 仍为 0，双端一致。即本地产生的消息（insert 或 import）都不涨未读数，只有从另一个客户端真实收到的消息才会。
- 处理：断言改为钉住实测值 `0`，并加注释说明「真实未读需要第二个客户端，属 im-test-hub 阶段」；`clearConversationUnreadMessageCount` 之后仍断言 `0`，覆盖该 API 的调用路径。

### 11.4 复验结果（本地 ngi 集群凭据，走 CI 等价脚本）

- `bash tool/ci/nightly_local.sh android` → `exit 0`，7/7 通过。
- `bash tool/ci/nightly_local.sh ios` → `exit 0`，7/7 通过。
- `FL-AUTH-001` 的四条断言在 token 登录下全部成立：`getCurrentUserId()` 与 `currentUserId` 均等于 `E2E_USER_ID`、`isConnected()` 为 true、`getAccessToken()` 非空。
- `tool/ci/fetch_e2e_user_token.sh` 单独验证：正向取到 token；`clientSecret` 错误 → 退出码 1、stdout 为空、服务端返回 `invalid_grant client_secret does not match`（说明 appKey 与 clientId 的配对由服务端兜底校验，配错会在 prepare 步骤 fail fast，不会拖到设备上才炸）；缺环境变量、appKey 不含 `#` → 退出码 2。
- `bash tool/ci/run_quality.sh` → `exit 0`（format 0 changed、5 个包 analyze 无问题、30 个测试、3 项一致性检查）。
- 未验证边界：CI 的 `E2E_APP_KEY` / `E2E_USER_ID` 是 secret，本地无法比对，因此「CI 那套凭据与本轮本地使用的 ngi 凭据属于同一个 app/账号」只能由第一次 `workflow_dispatch` 确认；若不属同一 app，失败会出现在 prepare 步骤并给出可读错误。

### 11.5 「跑前清空上一次数据」的确认（用户追加要求）

两条链路都会在跑前清理，且实测有效：

- `run_android_emulator_test.sh:29`：`flutter test` 之前 `adb -s emulator-5554 uninstall com.example.example`（原因见该脚本 `:21-28`）；`nightly_local.sh:76` 与 `single-account-nightly.yml` 都经由它。
- `run_ios_simulator_test.sh:111`：在 attempt 循环内、每次 attempt 之前 `xcrun simctl uninstall <udid> com.example.example`（原因见 `:106-110`），因此重试也不会继承上一次的数据。
- 清理效果实测：向 App 内部目录写入 marker → `adb uninstall` → 重新安装后 marker 及其所在目录均不存在；一次 nightly 结束后设备上 App 未安装（Android `pm path` 为空、iOS `get_app_container` 报 no such file），下一次运行天然是干净起点。
- nightly 额外稳健性实测：用 `make auto-report PLATFORM=android` 制造真实残留登录态（`com.example.example_preferences.xml` 中存在 `easemob.chat.loginuser` / `login_with_token` / `login.token`），再**绕过清数据**直接执行 `flutter test integration_test/single_account_local_test.dart -d emulator-5554 --dart-define-from-file=...` → 仍然 7/7 通过。原因是用例每次使用微秒级唯一 conversation ID、`tearDownAll` 会 `logout`，且同一账号重复 `loginWithToken` 不被 native 拒绝。
- 结论：对 nightly 而言「跑前清数据」是兜底而非必需，对 smoke 的 `FL-APP-001` 则是必需（见第 10.1 节）；两条链路共用同一对 wrapper，清理保持在跑前执行即可同时覆盖。

## 12. 第九轮：多设备事件映射缺口导致 iOS 集成测试加载即崩（2026-09-20）

### 12.1 现象

iOS 上手工跑 nightly 时，测试尚未开始就失败：

```
Failed to load ".../integration_test/single_account_local_test.dart": Null check operator used on a null value
  package:im_flutter_sdk/src/managers/chat_client.dart 187:6  ChatClient._onMultiDeviceGroupEvent
```

即 native 在登录后立刻下发了 `onMultiDeviceGroupEvent`，Dart 事件处理器抛异常，异常冒泡到测试框架，导致整套用例在 loading 阶段被判失败。

### 12.2 根因：`convertIntToChatMultiDevicesEvent` 表缺值 + 调用点用 `!` 解包

`chat_client.dart` 的四个多设备处理器都用 `convertIntToChatMultiDevicesEvent(map['event'])!` 解包；而 `chat_transform_tools.dart` 的映射表只覆盖 `-1`、`2-6`、`10-29`、`40-45`、`52`、`60-66`，**缺 30、31、32、33、34**，函数对未知值返回 `null` → `!` 抛 "Null check operator used on a null value"。

native 侧（三份权威来源一致）：

| 值 | iOS HyphenateChat 5.0.0 `EMMultiDevicesEvent` | Android 5.0.0 `EMMultiDeviceListener` | RN 5.0.0 `ChatMultiDeviceEvent` |
|---|---|---|---|
| 30 | `GroupAddWhiteList` | `GROUP_ADD_USER_WHITE_LIST` | `GROUP_ADD_USER_ALLOW_LIST` |
| 31 | `GroupRemoveWhiteList` | `GROUP_REMOVE_USER_WHITE_LIST` | `GROUP_REMOVE_USER_ALLOW_LIST` |
| 32 | `GroupAllBan` | `GROUP_ALL_BAN` | `GROUP_ALL_BAN` |
| 33 | `GroupRemoveAllBan` | `GROUP_REMOVE_ALL_BAN` | `GROUP_REMOVE_ALL_BAN` |
| 34 | `GroupUpdate`（**iOS 独有**） | 无 | 无 |
| 44 / 45 | `ChatThreadUpdate` / `ChatThreadKick` | `THREAD_UPDATE` / `THREAD_KICK` | `THREAD_UPDATE` / `THREAD_KICK` |

- 崩溃值必为 {30, 31, 32, 33, 34} 之一：这是 iOS 5.0.0 枚举与 Dart 表的差集（未逐值抓取，但五者缺失已足以解释，且修复覆盖全部五种）。
- 缺口**不是 5.0.0 引入的**：iOS 4.17.1 / 4.19.1 / 4.24.1 的枚举同样有 30-34 且 34 一直是 `GroupUpdate`，Android 4.22.1 的常量同样有 30-33 —— 自 4.x 起就存在，只是此前没人跑到会触发这些事件的多设备场景。
- 上表 7 个取值（30/31/32/33/34/44/45）在 Dart 枚举中的现状：**6 个成员本已存在**且命名与顺序正确（`GROUP_ADD_USER_ALLOW_LIST`、`GROUP_REMOVE_USER_ALLOW_LIST`、`GROUP_ALL_BAN`、`GROUP_REMOVE_ALL_BAN`、`CHAT_THREAD_UPDATE`、`CHAT_THREAD_KICK`，见 `chat_enums.dart:652-760`），**只有 34 没有成员**。因此 30-33 属纯 switch 漏项，34 需要新增成员（用户裁决：加入枚举）。枚举里另有 `GROUP_DISABLED` / `GROUP_ABLE` 两个成员在上述四版 native 枚举中都不存在（历史遗留，本次不动）。
- 附带发现：**44/45 映射颠倒**（Dart 原为 44→`CHAT_THREAD_KICK`、45→`CHAT_THREAD_UPDATE`），与 iOS/Android/RN 三份来源都相反。它不会崩，只会静默投递错误事件，因此更难发现。
- 另一处跨端差异（交回 native/记录，不在 Flutter 侧裁决）：iOS 用 34 表示「群信息更新」、52 表示「群成员自定义属性变更」；Android 只有 52 且命名为 `GROUP_METADATA_CHANGED`。Dart 按整数映射，只能取一个名字，目前 52 → `GROUP_MEMBER_ATTRIBUTES_CHANGED`（取 iOS 语义），Android 的「群信息更新」因而会以该名字投递；该差异已写进 `GROUP_UPDATE` 的双语注释。
- 同类隐患（用户裁决：先记录不动）：`chat_client.dart` 的 `_onMultiDevicesConversationEvent` 里 `ChatConversationType.values[map['convType']]` 同样是「native 原值直接索引 Dart 枚举」，未知值会抛 `RangeError` 并同样冒泡出处理器。本次不改，留待与 native 确认 `convType` 取值域后再处理。

### 12.3 修复

- `chat_enums.dart`：`ChatMultiDevicesEvent` 新增 `GROUP_UPDATE`（native 34，iOS 群组信息更新），位于 `GROUP_REMOVE_ALL_BAN` 之后以保持 native 数值顺序，带中英双语注释并说明「仅 iOS 上报、Android 用 52」。
- `chat_transform_tools.dart`：补齐 `case 30/31/32/33`、新增 `case 34`；把 44/45 改为 `CHAT_THREAD_UPDATE` / `CHAT_THREAD_KICK`；未知值分支改为写 `ChatLog.d` 诊断日志后返回 `null`（保持该函数**公开签名不变**——它经 `inner_headers.dart` 属于公开 API）。
- `chat_client.dart`：四个处理器（group/contact/thread/conversation）去掉 `!`，改为 `?? ChatMultiDevicesEvent.UnKnow`，与原生「未知事件 = -1」的语义对齐；未知值不再能让 MethodChannel 处理器抛异常。RN 的同类函数在 default 分支同样不抛异常（上报后原值透传）。
- `im_flutter_sdk/CHANGELOG.md`：5.0.0 段补记新增枚举成员与映射修复。
- 新增回归测试 `im_flutter_sdk/test/handlers/multi_device_event_test.dart`：用 `_CapturingClient` 截获 `ChatClient` 注册的 native 事件处理器，按真实 payload 回放
  ① 覆盖 native 声明的全部取值（任一值无映射即失败）；
  ② 钉住 30-34 与 44/45 的语义；
  ③ 99/缺失事件键 → 投递 `UnKnow` 且不抛异常。

### 12.4 复验

- 回归测试在修复前失败、修复后通过，且失败信息与线上一致（`Null check operator used on a null value`、`native value 30`）——已用 `git stash` 临时回退两个源文件实测。
- `run_quality.sh` → `exit 0`（34 个测试，比此前多 4 个；5 个包 analyze 无问题；3 项一致性检查通过）。
- `nightly_local.sh ios` → `exit 0`，7/7 通过；`nightly_local.sh android` → `exit 0`，7/7 通过。
- 未验证边界：本轮没有在线复现「另一台设备触发 30/31/32/33/34 事件」的真实推送（需要同账号第二台在线设备），该路径由单元测试按 native payload 回放覆盖。
