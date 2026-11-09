# 5.1.0 基线与跨端契约

日期：2026-11-09。实施前已读取 [01-api-diff.md](01-api-diff.md)。12 项清单为唯一范围，未匹配项保留至验收。

## 基线与门禁

- 目标既有 `5.1.0` 分支，基线 `33cfc60a`；开工 `git status --short` 为空。阶段产物和依赖 bump 属本任务授权改动，不为满足“干净”而提交或隐藏改动。
- 保留已有 `loadAllConversations({bool isSort = true})` 和重组后的测试目录。
- 已读 skill `references/flutter.md`、`references/known-issues.md`、项目 AGENTS/README/docs README/CONTRIBUTING。按 KI-107 不暴露品牌开关；KI-112 不增加参数过滤/错误码兜底；双集成版本按 KI-101/113 核对。
- 四包 `pubspec.yaml` 均改为 `5.1.0`；主包 Android/iOS hosted 依赖同步 5.1.0；既有 interface `^4.15.0+1` 兼容约束不变（接口实现未变），本地 overrides 指向 worktree 四包。
- Android Maven `io.hyphenate:hyphenate-chat:5.1.0`；iOS podspec dependency `HyphenateChat 5.1.0`、SPM exact `5.1.0`；podspec `s.version = 5.1.0`。
- `.codex/hooks.json` 已按 skill 模板渲染。信任状态无法代用户确认，因此每阶段还必须手动执行 gate；不执行 git add/commit/push。

## 冻结契约

| 范围 | Dart / MethodChannel | Android | iOS |
|---|---|---|---|
| 本地会话分页 | `Future<ChatCursorResult<ChatConversation>> getConversationsFromDB({String? cursor, int pageSize = 20})`；key 三端统一 `getConversationsFromDB`；请求 `{pageSize, cursor?}` | `asyncGetConversationsFromDB(cursor, pageSize, callback)` | `getConversationsFromDBWithCursor:pageSize:completion:` |
| 分页返回 | `{getConversationsFromDB: {cursor, list: [conversation JSON]}}`；复用 ChatCursorResult/ChatConversation，无客户端排序或过滤 | 复用 CursorResultHelper 和 ConversationHelper | 复用 CursorResultHelper 和 ConversationHelper |
| 自动加载配置 | `ChatOptions.autoLoadConversations` bool 默认 true；JSON key `autoLoadConversations` | `setAutoLoadAllConversations`；旧调用缺 key 时保留 native 默认 | `autoLoadConversations`；旧调用缺 key 时保留 native 默认 |
| 聊天室会话配置 | `ChatOptions.enableChatroomConversation` bool 默认 false；JSON 同名 key | `setEnableChatroomConversation` | `enableChatroomConversation` |
| 配置构造入口 | withAppKey、withAppId、默认构造、私有构造、toJson、copyWith 均贯通；example 公用 options_codec 解析同名键 | 仅初始化时设置 | 仅初始化时设置；OptionsHelper toJson 也返回配置 |
| 群邀请确认 | 复用 `ChatGroup.configs.inviteNeedConfirm`，无需新增顶层属性/路由 | `GroupConfigsHelper.toJson` 调 `group.isInviteNeedConfirm()`，替换硬编码 false | 保持 settings.IsInviteNeedConfirm |
| 群更新事件 | 复用 `ChatMultiDevicesEvent.GROUP_UPDATE` 与 34 映射、既有 onGroupEvent 负载；修正文档和旧测试注释 | 原有整数事件透传 | 原有整数事件透传 |
| 同步默认 | `dataSyncType` 仍可空；null 不下传。文档说明 native 5.1.0 双端默认 conversations | 继承新 native 默认 | 保留已有默认 |

分页规则：调用前初始化 `autoLoadConversations: false`；null/空 cursor 为首页，结果空 cursor 为末页；pageSize 有效范围 1–100；顺序为置顶状态、最新消息服务器时间、忽略大小写的会话 ID 各自降序。Flutter 的可选 pageSize=20 沿用分页习惯（skill 允许），不宣称 native 自带默认值。非法输入原样下传，原生错误原样返回（含 invalid cursor 的 110），不在 wrapper 中裁剪或纠错。

## 各项实施落点

- `chat_get_conversations_from_db`：Dart manager/key、Android wrapper/key、iOS wrapper/key、example `ChatManager.getConversationsFromDB` 注册；example 输出 `{cursor, list}`，会话复用 `conversationToScriptJson`。
- `options_enable_chatroom_conversation`、`options_auto_load_conversations`：Dart Options、双端 options helper、example options codec 与初始化模板/说明。
- `group_invite_need_confirm`：Android GroupConfigsHelper；Dart/iOS 既有数据结构保持。
- `multi_device_group_update`：Dart 事件文档、既有映射测试注释；不添加重复事件。
- `options_data_sync_default`：公开默认值文档和 CHANGELOG；不强制下传一个默认 mask。
- `search_keyword_limits`：已为 120/120/5，核对保留。
- 两个移除项：全文检索确认当前 SDK 未暴露，被删除的 native 字段无桥接引用。
- `options_agora_domain`：skip，国内不设置。
- `image_thumbnail_secret_deprecated`：defer，既有图片字段已删除、视频字段不动；验收列出。
- `android_http_timeout_units`：skip，低层工具不引入 Flutter API。
- 四包 CHANGELOG 由主代理统一收尾；保留 5.1.0 已有 isSort 条目。

## 验证计划与推断

增加必要的契约回归：分页默认/显式参数、native 错误透传和会话反序列化；Options 各构造入口/复制/序列化；example codec 的 false/true 传递。运行仓库 quality、example 单测和 Android/iOS CocoaPods/iOS SPM 构建；iOS 两模式串行并恢复原全局配置。不自动进入后续 coverage skill 的多设备场景确认流程。

⚠️ 自动加载配置虽不是本区间 native 新增，但缺少它使分页前置条件不可达，因此作为必要依赖补齐。该判断、pageSize=20 的 Flutter 默认值以及未运行的设备行为统一交验收，不中途停顿。

## 阶段二门禁实证

`rg` 核对四包 5.1.0、podspec 5.1.0、SPM exact 5.1.0、Maven 5.1.0，各处一致。

```sh
printf '{}' | bash /Users/asterisk/Codes/zuoyu_flutter/.agents/skills/platform-sdk-porting-v2/hooks/porting_guard.sh gate flutter "$PWD"
```
实际 stdout/stderr：空；退出码：0。本次运行在依赖和四包版本 bump 后、分层代码实施前。
