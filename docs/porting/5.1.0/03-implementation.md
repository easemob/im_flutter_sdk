# 5.1.0 实施记录

日期：2026-11-09。按 [02-contract.md](02-contract.md) 实施；本次无架构调整，未提交。

| ID | 最终处理 | 实现与检查 |
|---|---|---|
| chat_get_conversations_from_db | implemented | Dart manager/key → Android/iOS key、路由、异步 API → CursorResultHelper；example 注册入口，分页结果保留 cursor/list |
| options_enable_chatroom_conversation | implemented | ChatOptions 三个公开构造、私有构造、copyWith、toJson；两端 options helper；example codec，默认 false |
| options_auto_load_conversations | implemented | 同上，默认 true，允许显式 false；公开文档明确分页初始化前置 |
| options_remove_sync_ws_host | skip（已核对） | SDK 公共层与 wrapper 无被删除字段引用，无需修改 |
| options_remove_sync_ws_port | skip（已核对） | 同上，普通 webSocketServer/webSocketPort 仍存在，不能混删 |
| options_agora_domain | skip | KI-107 国内 SDK 不设置、不新增公开项 |
| image_thumbnail_secret_deprecated | defer | 图片字段及桥接已在 5.0.0 删除；保留视频 thumbnailSecret；仅 iOS 本次新增废弃标记，待验收确认 |
| multi_device_group_update | implemented | 复用既有值 34 映射，修改双语说明及旧测试注释；52 仍映射独立 GROUP_MEMBER_ATTRIBUTES_CHANGED |
| group_invite_need_confirm | implemented | Android GroupConfigsHelper 改调 group.isInviteNeedConfirm()；Dart configs 与 iOS settings 复用 |
| search_keyword_limits | implemented（基线已覆盖） | Dart ChatMessageSearchOption 与 example 文档均已为每词/总计 120、最多 5 个，不新增过滤 |
| options_data_sync_default | implemented | 更新 ChatOptions 双语说明/CHANGELOG；null 仍不下传，native 5.1 双端默认 conversations |
| android_http_timeout_units | skip | 无 Flutter 公共 HTTP utility，不新增封装 |

四包版本、主包平台依赖、CocoaPods/SPM/Maven 版本均 5.1.0；四包 CHANGELOG 已补双语说明，保留本分支既有 loadAllConversations(isSort)。example pubspec.lock/Podfile.lock 同步依赖解析；CocoaPods 更新同时将其传递依赖 ShengwangInfra_iOS 从 1.3.5 解析至 1.3.16（符合 native ~>1.3.0）。

## 阶段三门禁

- `FORMAT_BASE_SHA=33cfc60af9c0683afbb12422230fb994e459ac8c bash tool/ci/run_quality.sh`：通过。五包 analyze --fatal-infos 无问题、SDK 74 项测试通过、case mapping/MethodChannel contracts/versions 全通过。
- 首次 quality 发现新增 example 测试相对 lib import 的 lint，改为 package import 后完整重跑通过。原始日志：`reports/5.1.0/porting/quality.log` 与 `quality-r2.log`（Git ignored）。
- 新增 8 项 SDK 契约测试验证默认/显式分页参数、末页空结果、错误透传、反序列化，及 Options 所有构造/复制/序列化；不把 mock 返回视为真实 native 行为已验证。
- 新增 example codec 两项回归，留阶段四执行。
- `git diff --check`：通过。

```sh
printf '{}' | bash /Users/asterisk/Codes/zuoyu_flutter/.agents/skills/platform-sdk-porting-v2/hooks/porting_guard.sh gate flutter "$PWD"
```
实际 stdout/stderr：空；退出码：0。

## 遗留与下一步

语义疑问保持在 01/02，未增加未批准的过滤、默认兜底或新模型。下一步：example 单测、双端原生构建（iOS CocoaPods 与 SPM 串行）、逐字契约抽查和验收报告。当前所有代码未提交。
