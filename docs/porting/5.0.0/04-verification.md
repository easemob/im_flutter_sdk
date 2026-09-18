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
| API 脚本回归（Android 15 模拟器） | ❌ 19/21 后崩溃 | 当前提交代码对应运行 `20260918041624-android-emulator-5554`：不存在消息分页触发 native NPE，最后一步未运行；`20260918071416-android-emulator-5554` 的 21/21 仅证明临时 wrapper 判空可规避，相关 Java 修改已按用户决定还原 |
| API 脚本回归（iOS 18.2 模拟器） | ⚠️ 20/21 通过 | 可见窗口运行 `20260918071144-ios-4BEA133B-4B24-430F-96FC-924632C2CF53`；群回执服务正常且 `totalCount=0`；唯一失败为不存在消息分页返回成功空列表 |
| RN 对照修订：`ChatCursorResult.totalCount` | ✅ 通过 | Dart 模型正数/null 单测通过；iOS wrapper 参考 RN 转发 native callback，真实回归确认零值为 `0`；Android 保持 null |
| example 环境工具单测 | ✅ 通过 | 8 个测试覆盖公有集群、唯一 ngi 自动选择与旧 ebs 引用迁移、多集群默认值校验、顶层私有化 `msyncServer→imServer`、私有模式只生成 `env.private.dart`、Dart 渲染、本地 HTTP App/User Token 流程与集群激活 |
| 5.0.0 脚本覆盖测试 | ✅ 通过 | 4 个测试覆盖 `success/errorCode`、依赖失败跳过、conversation 结构化输出、21 个步骤注册与 RN 主链路；example 全量 12 个测试通过 |
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
- Android 自动把脚本推送到 `/sdcard/Android/data/com.example.example/files/`；iOS 使用宿主机绝对路径。
- 只保存 `[APITEST]` 结构化事件与崩溃关键行，写入 Git 忽略的 `reports/5.0.0/<run-id>/`；不保存完整 native stdout，避免密钥/Token/原始网络日志进入报告。
- 每次运行生成 `run.json`、`events.jsonl`、`crash.log`、`steps.json`、`summary.md`、`issues.md`；逐步结果按 `expect` 分类为 `passed/failed/blocked/crashed/not-run`。
- app 端从参数中的 `$step.<id>` 自动识别依赖；生产步骤失败后，依赖步骤输出 `skipped=true/blockedBy=<id>`，不调用 SDK，报告将其归类为 `blocked` 而不是新问题。
- `run.json` 保存 commit、worktree dirty 状态、脚本/runner SHA-256、平台、设备和 cluster，不保存 `clientSecret`、App Token 或 User Token。
- `issues.md` 使用语义化 candidate key 供人工确认，不在运行器中硬编码版本化问题编号；确认结论再同步到本文件和 `acceptance-report.md`。

## 8. 第五轮：正向/反向用例拆分与双端对比（2026-09-18）

用例结构调整：

- 原 `script_500_apis.json`（21 步混合）拆为 `script_500_apis_positive.json`（18 步，只断言成功）与 `script_500_apis_negative.json`（10 步，只断言目标契约错误码）。
- 正向路径覆盖 5.0.0 新增/修改 API 的正常路径：未读数统计与清理、`modifyMessage`（含 attributes）、群配置创建与更新、4 个已读回执 API、设备管理 token 鉴权与 `renewToken`；`sendMessage`/`destroyGroup` 仅用于准备与清理。`kickDevice` 改用 `fetchLoggedInDevices` 返回的真实 resource，会踢掉本端，因此与 `kickAllDevices` 一起固定在正向末尾。
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
| 正向 18 步 | `20260918095219-android-emulator-5554` 18/18 | `20260918095149-ios-4BEA133B-4B24-430F-96FC-924632C2CF53` 18/18 | 双端无崩溃、无 malformed 行；`modifyMessage` 本轮返回成功（消息编辑服务已可用），不再出现 305 |
| 反向 10 步 | `20260918095311-android-emulator-5554` 8 通过 / 2 失败 | `20260918095246-ios-4BEA133B-4B24-430F-96FC-924632C2CF53` 10/10 | 双端无崩溃；Android 两个批量回执 API 返回 1，与目标契约 500 不符 |
| 正向双端对比 | `reports/5.0.0/comparison-positive-20260918095346.md` | 步骤不一致 0 | 仅响应结构差异，见下 |
| 反向双端对比 | `reports/5.0.0/comparison-negative-20260918095346.md` | 错误码不一致 2 | `receipt_missing` / `group_receipt_missing`：Android 1 vs iOS 500 |

反向错误码一致项：非法群成员 600、不存在群 600、缺失修改消息 500、空会话 ID 110、设备管理三方法无效 token 303、`renewToken("")` 104 —— 双端逐项一致。

正向响应结构差异（均为既有字段差异，不是 5.0.0 新增语义）：

- 群对象：Android 额外返回顶层 `maxUserCount`/`ext`，与 `configs` 内同名字段重复；iOS 只返回 `configs`。
- 消息体：Android 返回 `body.translations`，iOS 不返回；iOS 返回 `receiverList`，Android 不返回。
- 群回执分页：Android `totalCount: null`，iOS `0`。

新增发现（交用户决策）：

- Flutter iOS `renewToken("")` 返回 `104 INVALID_TOKEN`，与 Android 一致；RN 记录的「iOS 空 token 成功」差异在 Flutter 侧未复现。
- Android 两个批量回执 API 仍返回 `1 GENERAL_ERROR`，未落实已裁决的 500 目标契约，与本文件第 6 节 003/004 结论一致，仍由 native 统一，Flutter 不保留兜底。
