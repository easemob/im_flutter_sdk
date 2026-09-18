# 5.0.0 平版 · 阶段三：实现记录

依据：`01-api-diff.md`（69 include / 102 defer）与已冻结的 `02-contract.md`。

## 1. 实现结果

- `01-api-diff.md` 的 69 个 include 项均已推进为 `implemented`。
- 102 个单端 defer 项标为 `deferred`；未新增仅单端存在的 Flutter 公开 API。
- native 5.0.0 导致的编译强制适配已按最小范围完成并单列于下文。
- 5.0.0 基线平版已提交为 `dbab80b3`；RN 对照修订已提交为 `a2f27eff`；token/env 与脚本自动化已提交为 `6d16ce85`；本地运行报告工具与本文档一并提交。

### Dart / public API

- client：只保留 Token 登录；设备管理统一 token；删除注册、密码登录、自动登录状态和全局 read-ack 设置；新增 data sync/database 事件。
- options：删除 `autoLogin/requireAck/enableAutoSyncContacts`，新增可空 `dataSyncType` 位掩码。
- chat/message：删除旧逐条/会话回执与旧回调；新增批量回执、清除未读数、群消息回执查询及统一回执事件。
- model：消息字段改为 `isPeerRead/isRead/isNeedReadReceipt/groupReadReceiptCount`；新增 `ChatMessageReadReceipt`、`ChatGroupReadReceipt`；RN 对照后为 `ChatCursorResult` 新增可空 `totalCount`，承接 iOS-only 群消息回执总数。
- group：删除 `ChatGroupStyle/ChatGroupOptions` 及兼容 typedef；新增 `ChatGroupConfigs/ChatGroupConfigsType` 和 `updateGroupConfigs`。
- conversation/contact/room：删除旧服务端拉取、逐条标记已读、客户端创建/解散聊天室 API；新增 conversation name/avatar。
- example：切换 Token 登录并注册 5.0 新 API；对照 RN 将 `script_500_apis.json` 从 5 步扩充为 21 步（RN 等价主链路 + 3 个不存在消息错误路径），增加 `success/errorCode` 预期判断与脚本—注册表覆盖测试。
- example 凭据流：参考 RN 增加多集群 token 自动获取，生成 Git 忽略的 `env.dart`；人工/自动模式共用环境，移除旧 `config.json` 默认链路；ebs/ngi/私有化为平级互斥模式，私有化只由顶层开关与服务器字段启用，并将 `msyncServer` 映射为 Flutter `imServer`。公有配置只有一个集群时自动选择该集群，缺少可选的 ebs 不报错；旧 `defaultCluster` 对应的账号/资源随唯一集群迁移。
- example 运行报告：新增 `make auto-report`，显式置前模拟器并将逐步期望对照、结构化事件和崩溃证据写入 Git 忽略的 `reports/5.0.0/<run-id>/`；仅将脱敏、人工确认后的结论同步到受版本管理的验收文档。

### Android wrapper

修改 `MethodKey.java`、`ClientWrapper.java`、`ChatManagerWrapper.java`、`ConversationWrapper.java`、`MessageWrapper.java`、`EMHelper.java`、`GroupManagerWrapper.java`、`ContactManagerWrapper.java`、`ChatRoomManagerWrapper.java`、`HelpTool.java`。

- 方法 key、路由、参数 key 与 Dart 契约一致。
- group config 位掩码按 Flutter/iOS 位值逐位映射到 Android 枚举，未直接透传。
- `EMGroup` 无 `inviteNeedConfirm` getter：序列化 `ChatGroup.configs` 时固定输出冻结默认 `false`，标记 ⚠️。
- 5.0 编译强制：AreaCode enum、删除 fetchMembers 重载、旧 listener 重载、旧聊天室缓存路由、群共享文件上传回调等均已适配。

### iOS wrapper

- 新增 `GroupReadReceiptHelper.{h,m}`、`MessageReadReceiptHelper.{h,m}`；删除 `GroupMessageAckHelper.{h,m}`。
- Token 登录/续期/设备 API、data sync/database 回调、统一已读回执、group configs、conversation delegate/name/avatar 均已接线。
- 5.0 编译强制：`resendMessage` 改调 `sendMessage`，push style 改 completion，删除 `EMGroup.isPushNotificationEnabled` 与 `EMChatMessage#getReaction:` 引用。
- group config 默认值由 Flutter JSON 显式赋值，不依赖 iOS native 默认。

## 2. 版本与发布文件

- 四包 `pubspec.yaml`：`5.0.0`。
- iOS podspec `s.version`：`5.0.0`。
- native 依赖：podspec / Package.swift / build.gradle 均为 `5.0.0`。
- 四包 CHANGELOG 已新增 5.0.0 条目。
- example `pubspec.lock` 与 iOS `Podfile.lock` 已更新到本地四包/HyphenateChat 5.0.0。

## 3. 静态检查

| 检查 | 结果 |
| --- | --- |
| `flutter analyze` | ✅ 无问题 |
| `flutter test` | ✅ 30 个测试通过 |
| Android example debug APK | ✅ 通过；仅 Java 8/deprecation/unchecked warning |
| iOS Sources + native 5.0 headers `clang -fsyntax-only` | ✅ 全部通过 |
| `git diff --check` | ✅ |
| 旧 4.x API/类型 grep | ✅ Dart/Android/iOS 有效代码无残留 |

## 4. 阶段三 gate

```text
$ echo '{}' | bash /Users/asterisk/Codes/zuoyu_flutter/.agents/skills/platform-sdk-porting-v2/hooks/porting_guard.sh gate flutter /Users/asterisk/Codes/zuoyu_flutter/im_flutter_sdk/.worktree/5.0.0
（无输出）
gate_exit=0
```

阶段三门禁通过。2026-09-17 对照 RN 5.0.0 后，复用其已裁决结论：`dataSyncType` 不设统一默认、group configs 固定 Flutter/RN 上层默认、群回执 `totalCount` 作为可空字段。iOS 基线 APNs token 类型 warning 经用户裁决接受现状、不修复；登录态功能回归转入后续 token 自动化任务。
