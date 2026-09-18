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
| API 脚本回归（Android 15 模拟器） | ❌ 19/21 后崩溃 | 群回执 happy path 已通过；两个预期错误路径通过；第三个不存在消息的 `fetchGroupMessageReadReceipts` 触发 native 5.0.0 NPE，`kickAllDevices` 未执行且无 `script.done` |
| API 脚本回归（iOS 18.2 模拟器） | ⚠️ 结果波动 | receipt-pass 运行 20/21 通过，唯一失败为不存在消息返回空列表；稍后同配置运行群回执发送再次返回 505，结果为 16 passed / 2 failed / 3 blocked；两次均无崩溃且执行到 `script.done` |
| RN 对照修订：`ChatCursorResult.totalCount` 单元测试 | ⚠️ 模型通过、真实链路缺失 | Dart 模型在字段存在时保留数值、未提供时为 null；真实 iOS 回归发现 wrapper 丢弃 native callback 的 `totalCount`，成功响应仍为 null |
| example 环境工具单测 | ✅ 通过 | 8 个测试覆盖公有集群、唯一 ngi 自动选择与旧 ebs 引用迁移、多集群默认值校验、顶层私有化 `msyncServer→imServer`、私有模式只生成 `env.private.dart`、Dart 渲染、本地 HTTP App/User Token 流程与集群激活 |
| 5.0.0 脚本覆盖测试 | ✅ 通过 | 2 个测试覆盖 `success/errorCode` 预期判断、21 个步骤全部可在注册表解析，以及 RN 主链路关键能力集合 |
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

原构建与静态检查门禁通过；后续可选档真实功能回归发现 Android 崩溃、iOS 错误语义差异和 `totalCount` 丢失，详见下节与验收报告，功能回归不能判定为全通过。

## 6. 真实 auto 模式补充验证（2026-09-18）

- Android：`emulator-5554`，Android 15 / API 35；脚本从应用专属外部目录读取。
- iOS：iPhone 16 Pro simulator，iOS 18.2；脚本从宿主机绝对路径读取。
- 两端均使用生成的 `env.dart`，成功完成 init、Token 登录，并观察到 `onDatabaseOpened`、`onDataSyncStart`、`onDataSyncFinish`。
- 用户确认群回执服务开通后，Android 与一次 iOS 运行的群回执 happy path 均通过；但更晚的 iOS 同配置运行再次返回 505，当前归为服务状态波动/待复核，不能标记为稳定关闭。
- iOS receipt-pass 运行：20 步通过、1 步失败、无崩溃；iOS 后续 505 运行：16 步通过、2 步失败、3 步 blocked；Android权威运行：19 步通过、1 步崩溃、1 步未运行。
- Android 崩溃栈：`EMChatManager.fetchGroupMessageReadReceipts` 对本地不存在的 messageId 解引用空 `EMMessage#getChatType()`。Flutter Android wrapper 当前未在下传前验证消息存在。
- iOS 同一输入不崩溃，返回 `{cursor: "", list: [], totalCount: null}`；该行为与 Android 不一致，也与脚本的错误预期不一致。
- iOS happy path 同样返回 `totalCount: null`。源码核对确认 Flutter iOS wrapper 丢弃 completion 的 `int totalCount`；RN 5.0.0 已显式写入返回 JSON。

## 7. 后续运行报告流程

- 入口：`make auto-report PLATFORM=<android|ios> [DEVICE=<id>]`。
- 运行器显式激活 iOS Simulator；Android 通过 adb 唤醒并尽力将 qemu 窗口置前。
- Android 自动把脚本推送到 `/sdcard/Android/data/com.example.example/files/`；iOS 使用宿主机绝对路径。
- 只保存 `[APITEST]` 结构化事件与崩溃关键行，写入 Git 忽略的 `reports/5.0.0/<run-id>/`；不保存完整 native stdout，避免密钥/Token/原始网络日志进入报告。
- 每次运行生成 `run.json`、`events.jsonl`、`crash.log`、`steps.json`、`summary.md`、`issues.md`；逐步结果按 `expect` 分类为 `passed/failed/blocked/crashed/not-run`。
- `run.json` 保存 commit、worktree dirty 状态、脚本/runner SHA-256、平台、设备和 cluster，不保存 `clientSecret`、App Token 或 User Token。
- `issues.md` 使用语义化 candidate key 供人工确认，不在运行器中硬编码版本化问题编号；确认结论再同步到本文件和 `acceptance-report.md`。
