# Flutter 5.1.0 平版验收报告

日期：2026-11-09。目标 worktree：`im_flutter_sdk/.worktree/5.1.0`；分支 `5.1.0`，基线 `33cfc60a`。验收时代码未提交；用户现已授权将本轮改动提交，未 push。

本轮将 iOS `5.0.0 → 5.1.0`、Android `SDK_5.0.0 → SDK_5.1.0` 的公开 API 增量平版至 Flutter。原分支已有 `loadAllConversations(isSort)` 保留。新增本地会话分页和必要初始化配置，修正 Android 群邀请确认配置读取；五份升级产物齐全后可作为后续测试覆盖 skill 输入。

- [变更清单与源码定位](01-api-diff.md)
- [跨端契约](02-contract.md)
- [实施与阶段三门禁](03-implementation.md)
- [验证证据与限制](04-verification.md)

## 二维对照

✅ 表示接口/映射一致且已完成对应静态或编译核查，不等于真实设备业务场景已通过。⚠️ 为保留差异、范围处理或待复核项。

| 变更 ID | iOS 源 | Android 源 | Dart | Android Wrapper | iOS Wrapper | 状态 |
|---|---|---|---|---|---|---|
| chat_get_conversations_from_db | 新增异步分页 | 新增异步分页 | getConversationsFromDB、cursor/pageSize、类型化结果 | 异步路由与游标序列化 | completion 路由与游标序列化 | ✅ |
| options_enable_chatroom_conversation | 新增，默认 false | 新增，默认 false | 构造/复制/序列化 | 初始化映射 | 初始化映射和序列化 | ✅ |
| options_auto_load_conversations | 既有，默认 true | 既有，默认 true | 为分页补齐初始化前置 | setAutoLoadAllConversations | autoLoadConversations | ⚠️ 必要依赖补齐 |
| options_remove_sync_ws_host | 已删除 | 已删除 | 原本未暴露 | 无遗留引用 | 无遗留引用 | ✅ skip，无需删除 |
| options_remove_sync_ws_port | 已删除 | 已删除 | 原本未暴露 | 无遗留引用 | 无遗留引用 | ✅ skip，无需删除 |
| options_agora_domain | 新增 | 新增 | 不暴露 | 不设置 | 不设置 | ✅ skip，KI-107 |
| image_thumbnail_secret_deprecated | 新增废弃标记 | 5.0.0 已废弃 | 5.0.0 已删除图片字段 | 无图片旧字段桥接 | 无图片旧字段桥接 | ⚠️ defer，维持既有迁移 |
| multi_device_group_update | 既有值 34 | 新增值 34 | 复用 GROUP_UPDATE 并修正文档 | 既有整数透传 | 既有整数透传 | ✅；实际跨设备触发未测 |
| group_invite_need_confirm | 既有 settings 属性 | 新增 getter | 复用 configs.inviteNeedConfirm | 原生真实值替代固定 false | 既有属性序列化 | ✅ |
| search_keyword_limits | 既有 120/120/5 | 文档追齐 | 既有文档已符合 | 不加过滤 | 不加过滤 | ✅ |
| options_data_sync_default | 既有 conversations 默认 | 默认从 none 改为 conversations | null 不下传，文档明确 5.1.0 默认 | 继承新默认 | 继承既有默认 | ✅ |
| android_http_timeout_units | 无对应 | 底层 utility 文档改为毫秒 | 不新增 API | 无直接映射 | 不适用 | ⚠️ skip，低层工具不平版 |

## 待复核的取舍与未匹配项

1. 自动加载会话配置：不属于本次 native 新增，但分页明确要求先关闭；Flutter 原本缺少设置入口，因此补齐 `autoLoadConversations`，默认 true 保持既有行为。分页 `pageSize=20` 是 Flutter 既有分页习惯，不是 native 默认值。
2. 图片缩略图密钥：保持 5.0.0 已完成的图片字段删除与 secret 迁移；不恢复废弃接口，也不删除仍有效的视频 thumbnailSecret。
3. Android HTTP utility：仅记录公开文档变化，不把 native 内部网络工具暴露为 Flutter 新 API。
4. 群更新值 34 已双端对齐；值 52 仍是独立的成员属性事件，不混并。真实跨设备事件触发范围留后续多设备场景验证。

上述取舍按用户授权持续执行并集中列于本报告，未在过程中暂停，未擅自增加 API 输入过滤或错误码兜底。

## 验证与交接

验证结果以 [04-verification.md](04-verification.md) 为准。本轮验证 SDK/桥接/文档与构建；未运行 CI 设备 smoke/nightly、单设备 JSON 或多设备业务场景，没有声称历史 FL-MSG-006/007 或其他既有设备失败已修复。

后续 `flutter-sdk-test-coverage` 输入：当前 worktree、目标版本 `5.1.0` 和本目录五份产物；应覆盖原清单 12 个 ID，并区分 `options_auto_load_conversations` 必要补齐、原有映射修正和 skip/defer 理由。先出变更到测试的覆盖表，补齐并验证 CI/单设备，再将有效的多设备场景交用户二次确认。

## 后续测试覆盖

升级后的用例补充与实际执行证据另见[覆盖表](2026-11-09-test-coverage.md)及[验证统计](2026-11-09-test-verification.md)。上述升级阶段未运行设备的历史结论保持原义；后续测试失败与多设备确认状态以新增报告为准。
