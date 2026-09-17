# 5.0.0 平版 · 阶段四：验证记录

## 1. 验证结果

| 验证项 | 结果 | 失败原因/备注 |
| --- | --- | --- |
| `flutter analyze`（主包） | ✅ 通过 | `No issues found` |
| `flutter test`（主包） | ✅ 通过 | 28 个测试全部通过，含 version/contract checker |
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
| API 脚本回归 | ⏭️ 未执行 | 主 checkout 的 config 只有 `loginPassword`，没有 native 5.0 必需的 `loginToken`；未复制无效凭据。已新增 `script_500_apis.json` 供取得 token 后运行 |

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

阶段四门禁通过；环境限制与跨端语义差异进入验收报告，不作为 SDK 编译缺陷。
