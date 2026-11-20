# 4.25.0 测试体系迁移差异登记表

日期：2026-11-20
来源：`im_flutter_sdk/.worktree/5.1.0` → `im_flutter_sdk/.worktree/4.25.0`
规则：API 不存在 → A 移除用例；可适配 → B 改用例；SDK 行为差异 → C 登记待裁决（改 SDK / 改用例）；环境/服务端 → D 单独处理。迁移引入的问题直接修复但留痕。

## T1 单测迁移

| # | 级别 | 文件 | 问题 | 处置 | 归因/契约依据 |
|---|---|---|---|---|---|
| T1-1 | B | test/models/chat_cursor_result_test.dart | `totalCount` 为 5.x 新增字段 | 移除相关断言，保留 cursor/data 契约 | 4.25.0 `chat_cursor_result.dart` 无该字段 |
| T1-2 | B | test/models/chat_options_test.dart | `dataSyncType`/`ChatDataSyncType` 为 5.x 独有 | 移除该用例及断言 | 4.25.0 全 lib 无此符号 |
| T1-3 | B | test/models/chat_options_test.dart | 5.x `copyWith` 支持会话选项参数 | 移除 copyWith 用例 | 4.25.0 `chat_options.dart:1693` copyWith 无这两个参数 |
| T1-4 | B | test/models/chat_thread_test.dart | 5.x `ChatThread.toJson` | 改写为 fromJson 契约测试 | 4.25.0 `chat_thread.dart` 无 toJson |
| T1-5 | B | test/models/recall_message_info_test.dart | 5.x `RecallMessageInfo.toJson` | 改写为显式 map + fromJson 断言 | 4.25.0 `recall_message_info.dart` 无 toJson |
| T1-6 | B | test/models/chat_presence_test.dart | 5.x `ChatPresence.toJson` | 改写为 fromJson 契约测试 | 4.25.0 `chat_presence.dart` 无 toJson |
| T1-7 | B | test/managers/chat_manager_test.dart | `loadAllConversations(isSort:)` 为 5.x 参数 | 移除 isSort 变体 | 4.25.0 `chat_manager.dart:991` 无参 |
| T1-8 | B | test/managers/chat_manager_test.dart | `getConversationsFromDB` 为 5.x 方法名 | 改用 `fetchConversationsFromDB`（method key `getConversationsFromDBWithCursor`）；`ChatConversation.name` 为 5.x 字段，移除该断言 | 4.25.0 `chat_manager.dart:2069` |
| T1-9 | B | test/managers/client_manager_test.dart | 5.x login 请求体为 `{userId, token}` | 改回 4.25.0 实际 `{userId, pwdOrToken, isPassword: false}` | 4.25.0 `chat_client.dart:628` login 实现 |
| T1-10 | B | test/contracts/chat_message_send_contract_test.dart | 5.x 消息字段重命名 isRead/isPeerRead/isNeedReadReceipt | 改回 hasRead/hasReadAck/needGroupAck | 4.25.0 `chat_message.dart:950-953` |
| T1-11 | B | test/models/em_message_test.dart | 同上 + 5.x 图片 body 丢弃 thumbnailSecret | 改回 hasRead；图片断言改为「保留 secret 与 thumbnailSecret」 | 4.25.0 图片 body 保留 thumbnailSecret（版本差异，非缺陷） |
| T1-12 | B | test/handlers/connection_event_test.dart | 5.x 统一 `onDisconnected(errorCode, info)` + `ChatDisconnectErrorCode` | 整体改写为 4.25.0 分散回调模型（含 other-device LoginExtensionInfo、onUserAuthenticationFailed→onDisconnected） | 4.25.0 `chat_client.dart:24-121`、`manager_event_handler.dart:41-130` |
| T1-13 | B | test/handlers/multi_device_event_test.dart | 5.x 事件集（34 GROUP_UPDATE、30-33 投递、99/null 兜底） | 事件集按 4.25.0 枚举声明（无 34 GROUP_UPDATE、65/66 成员）；44/45 语义断言、30-33 投递用例、UnKnow 兜底线用例已恢复并钉住修复（见 T1-14/15/16 裁决） | 4.25.0 `chat_transform_tools.dart`（修复后） |
| T1-14 | C→已修复 | lib SDK | 多端 group 事件 30-33（白名单/全员禁言）在转换层无映射，且 `chat_client.dart` 对 null 转换结果用 `!` 直接抛异常 | 用户裁决（2026-11-20）：改 SDK。转换层补 case 30-33 映射，移植 5.1.0 修复 | 枚举已声明 GROUP_ADD_USER_ALLOW_LIST 等（`chat_enums.dart`），转换层原缺 case 30-33 |
| T1-15 | C→已修复 | lib SDK | 44/45 映射疑似 swapped：4.25.0 为 44→KICK、45→UPDATE；5.1.0 修复为 44→UPDATE、45→KICK | 用户裁决：改 SDK。44→CHAT_THREAD_UPDATE、45→CHAT_THREAD_KICK，与 5.1.0 修复一致 | 4.25.0 `chat_transform_tools.dart` vs 5.1.0 修复说明 |
| T1-16 | C→已修复 | lib SDK | 未映射多端事件值（如 99）无 UnKnow 兜底，handler 抛 "Null check operator" | 用户裁决：改 SDK。未映射值/ null 记录 ChatLog 并兜底返回 UnKnow，移植 5.1.0 修复 | 同 T1-14 |
| T1-17 | B | test/contracts/legacy_api_removal_contract_test.dart | pushConfig 移除为 5.x 行为 | 移除该用例，其余契约（ChatGroup name/desc、FetchMessageOptions senders、loadMessagesWithKeyword senders）4.25.0 均通过，保留 | 4.25.0 `chat_options.dart` 仍发送 pushConfig（版本差异） |
| T1-18 | B | test/ci/version_checker_test.dart + tool/ci/version_checker.dart | 4.25.0 版本检查器比 5.1.0 新（含 SPM Package.swift 对齐、major.minor 比较） | 保留 4.25.0 原实现与原测试，不做覆盖 | 4.25.0 检查器为超集，覆盖会丢失 SPM 检查 |
| T1-19 | B | tool/ci/ | 5.1.0 `deprecated_api_checker.dart`/`check_deprecated_api.dart` 为新增 | 随单测一并迁入（T3 的 tool/ci 覆盖范围提前落地，T3 不再重复处理） | deprecated_api_checker_test 依赖 |

## T2 integration_test 迁移

| # | 级别 | 文件 | 问题 | 处置 | 归因/契约依据 |
|---|---|---|---|---|---|
| T2-1 | B | support/login.dart | 5.x dataSyncType 门控 + 2 参 onDisconnected | 改写为 onConnected + isConnected 方案（保留 45s 预算与先注册 handler 的顺序） | 4.25.0 `manager_event_handler.dart:41-130` 无 sync 事件参数化模型（仅有无参 onOfflineMessageSyncStart/Finish） |
| T2-2 | B | logged_out_test.dart + 4 个 logged_in 入口 + conversation_config_test.dart | init 的 dataSyncType 参数 | 删除该参数（perl 批量，已查无残留） | 同上 |
| T2-3 | B | modules/client_sync_cases.dart FL-AUTH-007 | 用例整体围绕 5.x sync 事件 | 改写为 4.25.0 等价：断言 offline message sync start/finish 触发 + connected + userId（用例 ID 保留） | 4.25.0 有 onOfflineMessageSyncStart/Finish（`manager_event_handler.dart:159/168`） |
| T2-4 | A | modules/group_cases.dart FL-GROUP-008 | inviteNeedConfirm 服务端/本地读回在 4.25.0 无法表达 | 移除用例并留注释指针 | 4.25.0 `chat_group.dart` fromJson 不解析 options，`settings` 已废弃且服务端获取的为 null；无替代读取路径 |
| T2-5 | A | modules/group_cases.dart FL-GROUP-015 | `updateGroupConfigs`+类型掩码为 5.x 新能力 | 移除整个用例 | 4.25.0 `chat_group_manager.dart` 仅有 updateGroupName/Desc/Announcement/Extension/Avatar 等单字段 API，无部分更新语义 |
| T2-6 | B | modules/group_cases.dart createOwnedGroup（22 个用例共享） | `ChatGroupConfigs`→`ChatGroupOptions`（无 allowInvites/isPublic/joinApprovalRequired） | helper 改 options 参数；服务端详情断言改用 maxUserCount/isMemberOnly/isMemberAllowToInvite；ext 读回断言移除 | 4.25.0 `chat_group_options.dart` 仅 style/maxCount/inviteNeedConfirm/ext |
| T2-7 | B | modules/conversation_cases.dart FL-CONV-002/016 | `clearConversationUnreadMessageCount` 不存在 | 改会话级 `markAllMessagesAsRead()`；FL-CONV-016 的 code-110 前置改为 getConversation null 判断 | 4.25.0 `chat_conversation.dart:340` |
| T2-8 | B | modules/conversation_cases.dart FL-CONV-008 | `deleteConversations` 批量不存在 | 循环单条 `deleteConversation(id)` | 4.25.0 `chat_manager.dart:1248` 仅单条 |
| T2-9 | B | modules/conversation_cases.dart FL-CONV-010 | `loadAllConversations(isSort:)` 为 5.x 参数 | 移除 isSort 三变体，保留默认排序断言 | 4.25.0 `chat_manager.dart:991` 无参 |
| T2-10 | B | modules/conversation_cases.dart ×4 + negative ×1 | `getConversationsFromDB` 方法名 | 改名 `fetchConversationsFromDB`（native key 不变） | 4.25.0 `chat_manager.dart:2069` |
| T2-11 | B | modules/group_cases.dart FL-GROUP-028 | `ChatGroupManager.downloadCallback` 不存在 | 改为 await download + 轮询 savePath 文件落盘 | 4.25.0 无下载进度回调接线（`ChatDownloadCallback` 仅余 em_compat 废弃 typedef） |
| T2-12 | B | example/tool/ | `rest_resource_client.dart`、`env_tool.dart` 缺失 | 从 5.1.0 复制（rest_resource_client 为 integration_test 依赖；env_tool 为 T5 账号机制前置） | message_cases/rest_fixture 依赖 |
| T2-13 | B | example/templates/ | `env.example.dart` 缺失 | 从 5.1.0 复制（ensure_example_env.sh 依赖） | run_quality.sh → ensure_example_env.sh |
| T2-14 | B | 旧入口 | no_login_presence_test.dart / single_account_local_test.dart | 整体移除（用户决策①） | 5.1.0 logged_out_test 已等价覆盖（agent-0 事实①：仅缺 isLoginBefore 断言与防御性 logout，属断言级差异） |

## T3 tool/ci 与 workflows 迁移

| # | 级别 | 文件 | 问题 | 处置 | 归因/契约依据 |
|---|---|---|---|---|---|
| T3-1 | B | tool/ci/ 8 个脚本 + report.sh/report.py/test_report*.py + patches/ | 5.1.0 版引用 logged_out_test 与报告机制 | 整体覆盖 4.25.0 旧版（旧版引用已删除的 no_login_presence_test，必须换） | smoke/nightly/runner 脚本与 ci-device.yml 配套 |
| T3-2 | B | .github/workflows/ci.yml | 5.1.0 版含 SPM 缓存步（"no CocoaPods in this repo"不适用） | 删除 SPM 缓存步；保留 ensure_example_env 步（T5 引入 env.dart 机制后必需）与 artifacts/ci 上传 | 4.25.0 example/ios 走 CocoaPods（存在 Podfile/Pods） |
| T3-3 | B | .github/workflows/ci-device.yml | 注释引用 5.1.0/5.0.0 专属表述 | 两处注释改中性表述；runner 标签（macos-26/Xcode 26.3）与 4.25.0 旧 workflow 一致，不动 | — |
| T3-4 | B | 旧 workflows | device-smoke.yml、single-account-nightly.yml | 删除，由 ci-device.yml 四 lane 取代 | 用户决策与 plan T3 |

## T7 多设备静态迁移（部分，实跑在 T10）

| # | 级别 | 文件 | 问题 | 处置 | 归因/契约依据 |
|---|---|---|---|---|---|
| T7-1 | A | testing/multi/cases/ 5.0.0-multi-message-read-receipt-positive.{yaml,json} | 4.25.0 无已读回执 API（`sendMessageReadReceipts` 等全 lib 零命中） | 场景对移除 | 5.x 新能力；4.25.0 `chat_manager.dart` 无任何 readReceipt 方法。若 4.25.0 应补该能力请用户裁决 |
| T7-2 | B | testing/ 整树 + scripts/multi.sh | 5.1.0 版整树迁入 | 覆盖式复制（4.25.0 原本无 testing/ 与 scripts/）；`flow_runner` 不迁——其源码住在独立仓 im-test-orchestrator（agent-0 事实⑥），不随 SDK 分支迁移 | 13 场景 API 名静态核对通过（除 T7-1）；multi-tool.json 占位符保留，本地走 `$IMTO_PATH`/邻近 checkout |
| T7-3 | B | testing/multi/README.md | 场景清单含已读回执行 | 更新清单状态（场景已移除） | 同 T7-1 |

## 设备实跑发现（smoke 早验）

| # | 级别 | 文件 | 问题 | 处置 | 归因/契约依据 |
|---|---|---|---|---|---|
| D1 | C→已裁决 | modules/message_cases.negative.dart FL-MSG-006 | 登出态发消息：onError 回调 201 正常到达，但消息状态保持 PROGRESS 而非 FAIL | 用户裁决（2026-11-20）：用例不改、SDK 不改，等 native 修复 | 与 5.1.0 用例内注释记录一致：native bug HIM-24173（5.0.0 已观察，修复基于 native 5.1.0 进行中）；4.25.0 native 4.22 同样表现。早验 17 例 16 过，仅此 1 例失败 |
| D2 | C→已裁决（同类 D1） | modules/message_cases.negative.dart FL-MSG-007 | 登录态发空收件人：onError 回调 500 正常到达，但消息状态保持 PROGRESS 而非 FAIL | 用例不改、SDK 不改，等 native 修复（同 D1 裁决） | 用例注释已注明与 FL-MSG-006 同为 native bug HIM-24173；ci-device 双平台（Android+iOS logged-in）一致复现 |
| D3 | C→登记 | modules/group_cases.dart FL-GROUP-014 | 清除自己群名片后，getGroupNamecard 在 5s 轮询内仍返回旧值 | 用例不改、SDK 不改，等 native 修复 | 用例注释已注明 native bug HIM-24170（群成员名片更新时间秒/毫秒截断，旧缓存胜过删除更新）；5.1.0 与 4.25.0 用例代码完全一致，非迁移引入；ci-device 双平台一致复现 |
| D4 | B→已适配 | modules/conversation_cases.dart FL-CONV-002 | 本地插入 2 条接收消息后 unreadCount 为 2 而非 0（用例假设为 5.x 行为「本地插入不增加未读」） | 已适配：断言改为插入后 unread=2（4.25.0 native 语义：本地插入的接收消息计未读），markAllMessagesAsRead 两轮归零验证幂等 | ci-device 双平台一致 Actual: 2；4.25.0 无 clearConversationUnreadMessageCount，T2-7 已适配为 markAllMessagesAsRead |
| D5 | D | ci-device Android lane 基础设施 | ①logged-out smoke：Gradle 解析 kotlin-stdlib:2.2.21 在 plugins.gradle.org 404（第二轮自行恢复，属瞬时仓库同步问题）；②logged_in_user_info_test：Failed to start Dart Development Service；③conversation_config_test：模拟器离线（前两者的级联） | 不改代码，重跑验证 | iOS lane 无此现象；失败均发生在用例执行之前 |
| D6 | D | ci-device 第二轮 Android logged-in 时序 flake | FL-ROOM-001（fetchChatRoomInfoFromServer 成功后 getChatRoomWithId 本地缓存未就绪返回 null）、FL-CONTACT-001/011（REST 变更后重新登录同步，联系人列表 30s 内仍为空）——三个用例在 Android 第一轮通过、iOS 第二轮通过，仅 Android 第二轮失败 | 不改代码，rerun 验证；再复现才升级为待查项 | 失败模式均为同步/缓存时序；用例代码与 5.1.0 一致 |

## T5 example 与账号机制

| # | 级别 | 文件 | 问题 | 处置 | 归因/契约依据 |
|---|---|---|---|---|---|
| T5-1 | B | example/lib/ 整树 | 5.1.0 版覆盖（agent/、auto 三模块、client/contact/chat_thread registry、listeners 等） | 合并式覆盖；保留 4.25.0 独有 `push_apis.dart` 并重新接入 registry（PushKit 为 4.25 新增） | 用户决策② |
| T5-2 | B | example/lib/listeners.dart | 2 参 onDisconnected + ChatDisconnectErrorCode + onDataSync*/onDatabaseOpened（均 5.x） | connection 块改写为 4.25.0 分散回调；删除已读回执监听块（API 不存在） | 4.25.0 handler 无这些成员 |
| T5-3 | B | lib/registry/apis/chat_apis.dart | name/avatar 会话字段、isSort、getConversationsFromDB、已读回执/清未读 5 条目 | 会话 JSON 只留 id/type；isSort 移除；改名 fetchConversationsFromDB（条目名同步改）；5 条目移除 | 4.25.0 API 面 |
| T5-4 | B | lib/registry/apis/client_apis.dart | fetchLoggedInDevices/kickDevice/kickAllDevices 参数名 token → pwdOrToken+isPwd:false；renewToken → renewAgoraToken | 仅 invoke 适配，条目名不变（脚本兼容） | 4.25.0 `chat_client.dart:977/1020/1066/761` |
| T5-5 | B | lib/registry/apis/group_apis.dart | createGroup configs → options（手动构造 ChatGroupOptions，无 fromJson）；updateGroupConfigs 条目移除 | 改写 | 4.25.0 `chat_group_options.dart` |
| T5-6 | B | lib/registry/apis/chat_thread_apis.dart | ChatThread.toJson / totalCount | 输出改手工字段映射，去掉 totalCount | 4.25.0 无 toJson/totalCount |
| T5-7 | B | lib/options_codec.dart | dataSyncType 编码键与模板 | 删除 | 5.x-only |
| T5-8 | B | lib/tools/attachment_picker.dart | file_picker 13.x API（pubspec 锁定 ^8.0.0 不动） | 改回 8.x 的 pickFiles/file.size | agent-0 事实③；依赖版本保持不变 |
| T5-9 | B | 账号机制 | scripts/config.json 旧机制 | 移除 example/scripts/ 与 config.example.json；引入 env_tool + config.local.json + env.dart（5.1.0 模板），从 5.1.0 配置转换（去 dataSyncType）并重新取 token 生成 env.dart | 用户决策② |
| T5-10 | B | .gitignore（根 + im_flutter_sdk 包） | config.local.json/env.dart/artifacts 等忽略规则 | 以 5.1.0 版为准覆盖（根），包级 .gitignore 同步（凭据文件已确认被忽略） | ensure_example_env.sh 等依赖 |

## T6 单设备迁移

| # | 级别 | 文件 | 问题 | 处置 | 归因/契约依据 |
|---|---|---|---|---|---|
| T6-1 | A | script_510_apis_positive.json | 整脚本围绕 inviteNeedConfirm 配置读回 + updateGroupConfigs（5.x 能力） | 整文件移除 | 同 T2-4/T2-5，4.25.0 无法表达 |
| T6-2 | B | script_510_apis_negative.json | init dataSyncType；api 名 | 删 dataSyncType；改名 fetchConversationsFromDB | — |
| T6-3 | B | script_500_apis_positive.json | 20 步中 8 步 5.x-only（清未读×2、updateGroupConfigs、已读回执链×5） | 移除；createGroup configs→options；group_message 去 isNeedReadReceipt | 4.25.0 无这些 API |
| T6-4 | B | script_500_apis_negative.json | 10 步中 4 步 5.x-only（updateGroupConfigs、清未读、已读回执×2） | 移除；createGroup configs→options | 同上 |
| T6-5 | B | testing/single/auto_report.dart | initOptions 元数据白名单含 dataSyncType | 从白名单删除 | 4.25.0 脚本不再使用该键 |
| T6-6 | B | testing/single/cases/ | 4.25.0 旧 example/scripts 下 script_425_apis.json | 保留迁入 testing/single/cases/（4.25 原生脚本） | 4.25.0 独有资产 |
| T6-7 | — | 校验 | 9 个脚本 api 名 100% 可在 registry 解析（TestUtil.writeBase64File 由 auto_mode 内建处理） | 通过 | — |
| T6-8 | D | script_424_apis.json searchMessagesFromServer ×2 | 服务端未开通搜索服务，返回 100 | 不改用例不改 SDK，登记环境项 | "application is not registered in the search service"，属 app 级服务开关 |
| T6-9 | B | script_424_apis.json 空 keywordList 步 | 逆向校验步未声明负向期望，默认期望成功导致误报 | 补 `expect: {"errorCode": 110}`，复跑通过 | 该步本意即参数校验 |
| T6-10 | — | 实跑 | script_424 两轮实跑：引擎/env/登录/收发/离线同步事件全通，报告产出 | 通过（余 2 个 D 级环境失败） | artifacts/single/20261120102645 |

## T8 文档迁移

| # | 级别 | 文件 | 问题 | 处置 | 归因/契约依据 |
|---|---|---|---|---|---|
| T8-1 | B | docs/testing/README.md | 引用不存在的 ../porting/5.1.0/ 覆盖表 | 改为指向 docs/porting/<版本>/ 与本次迁移差异登记表 | 4.25.0 porting 目录只有 4.24.0/4.25.0 |
| T8-2 | B | docs/ | testing 指南、testing-v2 spec/plan、ci-basic-api-tests spec 与 refs、batch 记录 | 从 5.1.0 迁入；历史验证记录中的 5.0.0/5.1.0 表述为当时执行记录，保留原文 | 历史文档不修订事实 |
| T8-3 | B | im_flutter_sdk/docs/ci/native-case-mapping.json | 4.25.0 旧表 13 例全部指向已删除的旧入口文件 | 以 5.1.0 版（94 例）覆盖，并移除本迁移删除的 FL-GROUP-008/015 两条（92 例）；check_case_mapping 通过 | run_quality 检查项 |




