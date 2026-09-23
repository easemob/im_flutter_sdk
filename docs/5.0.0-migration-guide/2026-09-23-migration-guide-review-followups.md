# 5.0.0 迁移指南审查：待决策与代码侧跟进项

日期：2026-09-23
关联文档：`2026-09-23-flutter-migration-guide.md`（本次已按审查结论完成文字修正）
审查方式：`4.24.0` ↔ `5.0.0` 两个 worktree 的 Dart 公开 API 全量 diff（方法 / 类 / 字段 / 枚举成员 / 导出文件），逐条回到 Dart、Android wrapper、iOS wrapper 与原生 SDK 源码（`hyphenate-chat-5.0.0-sources.jar`、`HyphenateChat.xcframework` 头文件）验证。

本文件只记录**需要决策或需要改代码**的项；纯文档表述问题已直接改进迁移指南，不在此列。

## 一、需要决策（影响文档口径或接口行为）

### D1 iOS 上 `ChatGroup.maxUserCount` / `ChatGroup.extension` 不再下发（相对 4.x 的回归）

- 事实：4.x `GroupHelper.m:33-37` 在 `settings != nil` 时输出 `maxUserCount`、`ext`；5.0.0 `im_flutter_sdk_ios/.../GroupHelper.m:11-36` 只输出 `isPublic` 与 `configs`/`isJoinApprovalRequired`/`isMemberAllowToInvite`，全仓库 iOS 侧已无 `@"maxUserCount"`，群级 `ext` 也只存在于 `EMGroupConfigs (Helper)` 内。Android `EMHelper.java:186-191` 两者照旧输出。
- 结果：iOS 上 `ChatGroup.maxUserCount`、`ChatGroup.extension` 恒为 `null`，Android 正常。
- 指南现状：已在「群组配置模型重构」的 warning 与「已知限制」中说明，并给出 `configs?.maxCount` / `configs?.ext` 的替代读法。
- 待决策：**修 wrapper**（iOS 补 `ret[@"maxUserCount"] = @(self.settings.maxUsers);`、`ret[@"ext"] = self.settings.ext ?: [NSNull null];`，与 Android 对齐）还是**保持现状**（长期记录为平台差异）。推荐修 wrapper：这两个字段在 4.x 可用，属能力回退，且改动只在序列化层。

### D2 Android 上 `ChatGroup.configs.inviteNeedConfirm` 固定回传 `false`

- 事实：`EMHelper.java:248` 硬编码 `data.put("inviteNeedConfirm", false)`；已核对原生 5.0.0 `EMGroup` 无对应 getter（只有 `isPublic()`、`isMemberAllowToInvite()`、`isJoinApprovalRequired()`、`getMaxUserCount()`、`getExtension()`）。`docs/porting/5.0.0/03-implementation.md:31` 已标 ⚠️。
- 指南现状：已说明该字段读回值不可信，仅在创建 / 更新时作为入参有效。
- 待决策：接受现状（推荐，原生无数据源），或向原生提需求补 getter；若接受现状，建议同步修 `ChatGroupConfigs.inviteNeedConfirm` 的双语注释，注明「读回值在 Android 上恒为 false」。

### D3 迁移指南的 4.x 基线（4.24.0 vs 4.25.0）

- 事实：`5.0.0` 分支的 merge-base 是 4.24.0，`im_flutter_sdk/CHANGELOG.md` 从 5.0.0 直接跳到 4.24.0；`4.25.0` 分支已存在（新增 `fetchConversationsFromDB`、`ChatOptions.enableChatroomConversation`、`ChatOptions.autoLoadConversations`，原生 4.25.0 / 4.25.1），但这三项在 5.0.0 分支中**都不存在**（已 grep 确认）。`flutter2_stable` 当前为 4.24.0，4.25.0 未合入 stable、无 tag。
- 指南现状：已显式声明「本指南的 4.x 对照基线是 4.24.0」。
- 待决策：
  1. 先把 4.25.0 合入 5.0.0（避免 5.0.0 相对 4.25.0 出现能力回退），指南再补一节 4.25.0 差异；或
  2. 明确 5.0.0 不含这三项，在指南中加「从 4.25.0 升级」的告警段落。
- 若 4.25.0 先于 5.0.0 发布而此处不表态，指南的「4.x」列与 API 覆盖会出现缺口。

## 二、代码 / 内部文档跟进（无需决策，建议本轮或下轮处理）

### C1 `chat_enums.dart` 中 `GROUP_UPDATE` 的双语注释与指南不一致

- 现状：注释写「Android SDK 的群组信息变更使用 native 值 52，在 Android 侧命名为 `GROUP_METADATA_CHANGED`」。
- 问题：52 在 Android 为 `GROUP_METADATA_CHANGED`、在 iOS 为 `GroupMemberAttributesChanged`，语义是**群成员自定义属性**变化，不等于群信息变化；Dart 侧 52 映射到 `GROUP_MEMBER_ATTRIBUTES_CHANGED`。
- 建议：改为「Android 无等价事件；跨端感知群信息变化请用 `ChatGroupEventHandler.onSpecificationDidUpdate`」（指南已按此口径修正）。属公开 API 双语注释，改动需保持 `~english` / `~chinese` 同步。

### C2 iOS `ChatManagerWrapper.m:334-341` `invalidMessagesErrorIfNeeded:` 已成死代码

- 移除 wrapper 预校验（commit `5c2c6124`）后无任何调用点，与「回执批次校验交给原生」的实现说明相矛盾，建议删除。

### C3 反向路径自动化在 `5c2c6124` 之后未复跑

- 现有双端错误码对比 `reports/5.0.0/comparison-negative-20260918111552.md` 跑于 09-18 11:15，而移除 wrapper 预校验的提交在 09-18 19:24；其后只有 positive 与 `script_translate_fix` 跑批。
- 「整批无法解析 → `110`」目前只有 `docs/porting/5.0.0/04-verification.md:144/148` 的原生源码静态实证。
- 建议补跑 `script_500_apis_negative.json` 双端各一次，顺带确认 `reports/5.0.0/issues.md` 的 `android-missing-message-crash`（`fetchGroupMessageReadReceipts` 传入本地不存在的 messageId）在当前原生版本上是否仍会崩溃；指南的「已知限制」按结论收敛表述。

### C4 CHANGELOG 口径已修正

- `im_flutter_sdk/CHANGELOG.md` 原写「`modifyMessage` added an optional `attributes`」，但 4.24.0 Dart 已有该参数（`4.24.0/chat_manager.dart:2104-2107`）。已改为在 Bug Fixes 记录真实变化：Android 未传 `attributes` 时由「空 Map 覆盖扩展」修正为「null 不修改」，与 iOS 一致。
- `docs/porting/5.0.0/01-api-diff-android.md:192` 的「不含 Thread」已加注：该说法来自原生迁移文档，与 5.0.0 实现不符，Flutter 侧已按 commit `89e5d1b7` 更正。

## 三、发布相关

- Android 迁移指南链接已补入（`https://doc.easemob.com/document/android/migration_guide.html`，已验证可访问且标题正确）。
- `https://doc.easemob.com/document/flutter/migration_guide.html` 当前不存在；本指南发布到文档站时需在侧边栏注册页面，避免重复 `docs/research/2026-09-09-easemob-doc-pr1809-flutter-4.22-review.md` 中「侧边栏未注册」的问题。
