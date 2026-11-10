# 5.1.0 升级测试覆盖

> 2026-11-10 入口归类更新：下文旧入口名称、初始化矩阵和执行证据保留为历史记录。当前五个稳定入口及特殊配置迁移状态见 [CI 设计规则](../../testing/2026-11-09-ci.md) 和 [操作说明](../../../tool/ci/README.md)；历史通过结果不代表新入口已验证。

- 日期：2026-11-09。
- 目标：`im_flutter_sdk/.worktree/5.1.0`，分支 `5.1.0`，本轮基线 `adf9764b`；开工工作区干净。本轮测试与文档改动未提交。
- 阶段：按用户确认的初始化分批方案迁移 CI 与单设备用例，迁移后定向验证完成：CI 4批10次用例执行全部通过、单设备正向5步/逆向1步通过；先前结果保留为历史证据。已知失败继续记录并跳过。多设备 M1 首次 17/17、M3 首次 15/15 步骤通过（含清理），本次不改多设备场景；M2 免打扰同步暂缓。
- 验证记录：[执行统计与问题表](2026-11-09-test-verification.md)。统计、尝试次数、最新结果以该报告为准。

## 输入核验

| 文件/章节 | 版本与实质内容核验 | 提取用途/冲突处理 |
|---|---|---|
| [01-api-diff.md](01-api-diff.md) | 5.0.0→5.1.0，12 个 ID，双端清单和源码定位均在正文 | 全量输入；逐行核算 include 7、skip 4、defer 1 |
| [02-contract.md](02-contract.md) | 分页参数/游标/排序、初始化默认、事件与群配置契约明确 | 定义预期；分页 invalid cursor 明确 110，但不擅自推断所有越界 pageSize 的错误码 |
| [03-implementation.md](03-implementation.md) | 12 ID 的最终落点与未实施项明确 | 区分新封装、既有映射修正、native 默认继承 |
| [04-verification.md](04-verification.md) | 有真实静态/单测/构建证据，设备行为明确未执行 | 历史 74/114 等通过数只作背景，不计本轮通过 |
| [acceptance-report.md](acceptance-report.md) | 双维度验收、原有 isSort、defer/skip 取舍与测试交接齐全 | 用户已审阅并授权提交；历史阶段“未提交”不改变本轮基线 |
| [主包 CHANGELOG 5.1.0](../../../im_flutter_sdk/CHANGELOG.md) | 公开 API 之外还有 native 修复/默认行为变化 | 补入 `supp-*`；不把发布说明的笼统修复描述当作已具备稳定复现条件 |

五份必需文档均存在且包含实质内容；总清单没有额外拆分清单需要追读。03 中“双语 CHANGELOG”是实施阶段历史描述，用户随后要求英文并手改，实际提交中的英文说明为最终版本；该差异不影响测试契约。

## 既有组织方式与已批准边界

CI 业务断言继续放在 `im_flutter_sdk/example/integration_test/modules/`，准备与清理复用 `support/`。用户已确认：初始化参数只有重启应用后重新初始化才生效，因此允许特殊配置保留独立设备套件；初始化兼容的用例合并到既有模块。`history_last_message_test.dart` 的 FL-MSG-010 已移入 `modules/message_cases.dart`，不再保留独立历史消息入口。不得因业务模块不同任意增设套件，不改执行器或断言框架。

`tool/ci/nightly_local.sh` 保持总入口，以四批循环调用现有平台运行脚本，每批冷启动；本地和 hosted CI 共用该入口，不保留 `run_nightly_suites.sh` 调度层。所有相关选项显式指定，避免 SDK 默认值变化改变前置条件：

| 批次入口（integration_test/） | autoLoadConversations | enableChatroomConversation | enableUserInfo | dataSyncType | 运行范围 |
|---|---|---|---|---|---|
| `single_account_local_test.dart` | true | false | false | contacts + joinedGroups（6） | 常规模块及迁入的 FL-MSG-010；FL-CONV-013 验证 false |
| `native_defaults_test.dart` | true | false | false | conversations（1） | FL-AUTH-007；沿用文件名，验证显式配置后的同步，不再验证省略参数的 native 默认 |
| `user_info_subscription_test.dart` | true | false | true | contacts + joinedGroups（6） | FL-USERINFO-001 |
| `conversation_config_test.dart` | false | true | false | contacts + joinedGroups（6） | 模块注册 FL-CONV-011/012/013；分页及聊天室 true |

单设备沿用 5.0.0 正逆向分文件方式：`script_510_apis_positive.json` 保留群配置原五步，`script_510_apis_negative.json` 保留非法 cursor 原一步，断言与清理不变，替代混合文件。两者各自初始化并可独立执行；均显式指定 `dataSyncType=6`、`enableUserInfo=false`、`enableChatroomConversation=false`，正向 `autoLoadConversations=true`，逆向 `false`。迁移后的设备结果以验证报告为准，当前处于验证阶段。

迁移后的验证见验证报告“当前布局”节：常规批次 Android 5/5、会话配置 Android 3/3、显式同步 Android 1/1、订阅 iOS 1/1；正向 JSON Android 5/5 步、逆向 JSON iOS 1/1 步。旧证据索引仅用于追溯；本轮未重跑已跳过失败或多设备场景。

## 变更到用例的覆盖表

路径以仓库根为基准。表中注明当前用例落点与尚缺覆盖。下列 S-A/S-I、N-A/N-I 和独立套件日志是迁移前布局的历史证据；旧混合 JSON 六步曾在双端通过，不能据此宣布拆分后的两个脚本已通过。迁移会改变入口、初始化或注册位置，须按当前布局复验。其余单设备建议尚未实施，不能将单元结果当作 native 行为结果。

迁移前证据索引（原始日志均在忽略目录，U 为暂停前批次结果；迁移后结果另见验证报告）：

- S-A：`reports/5.0.0/20261109093008-android-emulator-5554/summary.md`，Android六步通过、0失败/阻塞，含destroy_group成功。
- S-I：`reports/5.0.0/20261109093201-ios-4BEA133B-4B24-430F-96FC-924632C2CF53/summary.md`，iOS六步通过、0失败/阻塞，含destroy_group成功。报告目录5.0.0为工具既有输出位置，本轮实际验证5.1.0。
- U：`reports/5.1.0/test-coverage/quality-r2.log`：quality通过，SDK76项、mapping/contracts/versions通过；`example-tests.log`：123项通过（含本轮9项工具测试）；`flow-tests.log`：91项通过；`multi-tests.log`：243项工具单测通过，不是多设备SDK业务场景；`single-self-test.log`：报告器self-test通过。

- N-A：`reports/5.1.0/test-coverage/nightly-android-r2.log`，33通过、2失败；失败为FL-CONV-006与FL-MSG-007（FL-MSG-006属于no-login/smoke，不能混入本nightly计数）。新增FL-CONV-010/011/012/013(false)及FL-GROUP-008均通过。
- N-I：`reports/5.1.0/test-coverage/nightly-ios.log`，33通过、2失败；FL-MSG-007回调状态PROGRESS，首轮FL-CONV-006被诊断loadMessage抛code=3中断；后续 `conv006-ios-diagnostic.log` 已到达原断言并确认count=1、ids=[]。该问题后续跳过。

| 行为 ID | 来源变更 ID 及文档章节 | Flutter 修改与预期（含平台） | 现有覆盖及缺口 | CI 动作/用例定位/理由 | 单设备动作/用例定位/理由 | 多设备候选及确认状态/理由 | 执行证据 |
|---|---|---|---|---|---|---|---|
| conv-db-pagination | `chat_get_conversations_from_db`；02 冻结契约 | 双端关闭 auto-load 后，从 DB 分页；null/空 cursor 首页，空结果 cursor 表示末页；置顶、最新服务器时间、忽略大小写 ID 依次倒序 | `im_flutter_sdk/test/managers/chat_manager_test.dart` 的 `getConversationsFromDB` 四项检查参数/解析/模拟错误；未验证 native 连续性和排序 | 复用四项单测；新增 `im_flutter_sdk/example/integration_test/modules/conversation_cases.dart` FL-CONV-011：pageSize=2 有界遍历、无重复、本轮 fixture 全部出现并核查顺序；FL-CONV-012（`modules/conversation_cases.negative.dart`）：有效初始化下 invalid cursor=110；两例现由 `conversation_config_test.dart` 注册，常规批次不再注册。已包含同时间fixture的忽略大小写ID倒序检查；置顶优先级仍缺独立可控fixture，不能由未置顶排序通过推算 | 新增 `testing/single/cases/script_510_apis_negative.json` / `invalid_conversation_cursor`，精确断言110；正向分页本轮由CI FL-CONV-011执行，single不重复建设动态断言/循环能力，缺口如实保留 | 不适用：数据库分页无需其他在线客户端 | U契约通过；S-A/S-I非法cursor=110通过；N-A正向分页及invalid cursor通过，N-I相同新增用例通过 |
| options-auto-load | `options_auto_load_conversations`；02 配置契约 | 双端默认 true，显式 false 可达分页前置；设置时机为 SDK 初始化 | `im_flutter_sdk/test/models/chat_options_test.dart` 覆盖构造/copyWith/toJson；`im_flutter_sdk/example/test/options_codec_test.dart` 覆盖 JSON 解析；无重启后加载行为实测 | 复用模型/codec；FL-CONV-011/012 由 `conversation_config_test.dart` 显式 autoLoadConversations=false 后执行；常规入口显式 true，不能仅改 Dart 对象 | 新增 `script_510_apis_negative.json` init.autoLoadConversations=false；与invalid_conversation_cursor配套，不能声称同时证明所有内存加载语义 | 不适用：初始化与本地数据库可单设备完成 | U与S-A/S-I通过；N-A分页前置false通过；FL-CONV-006计数不一致在不同autoLoad条件表现不稳定，见已知失败；不外推内存自动加载全语义 |
| options-chatroom-list | `options_enable_chatroom_conversation`；01/02 与 CHANGELOG Breaking Changes | 双端默认列表排除聊天室；初始化 true 时包含 | 模型/codec 覆盖默认 false 与显式 true，未验证真实列表；现有单设备 5.0 `conversations` 只有 success | 已新增 `im_flutter_sdk/example/integration_test/modules/conversation_cases.dart` FL-CONV-013：REST创建本轮room→join→真实send，关联最终SUCCESS回调，显式false排除/显式true包含一次；同一模块注册函数分别由常规入口（false）与 `conversation_config_test.dart`（true）调用，每批重启并显式初始化。CiRestFixture新增room创建/读取/删除/核查，独立teardown清理监听、退房、远端room及本地会话；新增工具单测随example123项通过 | 暂缓single重复建设：本轮由FL-CONV-013验证；脚本只有containsItem，无否定成员断言，不扩语法或删除账号历史数据 | 不适用：可由REST准备本轮聊天室并由唯一在线客户端真实发送形成会话；不把任意本地insert结果外推真实聊天室列表行为 | U通过；N-A默认false通过；首轮清理REST判据问题已修复，未弱化列表断言；`chatroom-true-android.log` 与 `chatroom-true-ios.log` 均通过；N-I默认false通过 |
| group-invite-confirm-field | `group_invite_need_confirm`；02 群配置 | Android 返回真实 inviteNeedConfirm；iOS 既有值应一致 | `im_flutter_sdk/example/integration_test/modules/group_cases.dart` FL-GROUP-001/002 只读 false，不能发现原先硬编码 false；single `script_500_apis_positive.json` group/group_update 只 success | 新增同模块 FL-GROUP-008：本轮自建群，true/false 写入后服务端读取并断言字段，REST 收尾；不依赖被邀请者在线 | 新增 `testing/single/cases/script_510_apis_positive.json`：create_group/fetch_confirm_true/update_confirm_false/fetch_confirm_false/destroy_group；核心断言configs.inviteNeedConfirm为静态true/false | 此行仅字段桥接；邀请业务另列下一行 M3，不能由字段通过关闭业务缺口 | S-A/S-I五步通过并完成destroy；N-A FL-GROUP-008通过，N-I相同新增用例通过 |
| group-invite-confirm-flow | `group_invite_need_confirm`；用户明确要求邀请确认按多设备分类 | A 创建需确认的新群并邀请 B；B 接收本轮邀请、接受，双方查询本轮成员列表包含 B | FL-GROUP-008 和单设备配置回读均不覆盖邀请业务；既有 member-join 是公开群主动加入，也不能替代 | 不适用：核心断言需要另一在线客户端 | 不适用：一个客户端不能完成双方交互 | 已批准 M3，Android 群主 A、iOS 被邀请人 B；补已有 API 注册及配对 YAML/JSON，无引擎改动 | M3 Android群主/iOS受邀人首次15/15步骤通过，含本轮邀请、接受、双方成员列表与清理；证据见验证报告 |
| group-update-event | `multi_device_group_update`；01/02 | 双端 native 34→GROUP_UPDATE；52 保持独立事件 | `im_flutter_sdk/test/handlers/multi_device_event_test.dart` `conversion covers every value...`、`delivers the group allow list, all-ban, and update events` 模拟分发 34；既有 multi group-create 本轮已补 GROUP_UPDATE 与更新后名称断言 | 复用映射单测；必要时补 34 与 52 明确区分，但模拟事件不证明 native 下发 | 不适用：一个客户端无法观察“同账号另一设备操作”事件 | 已批准 M1：复用 group-create 同账号双端框架，增加新群名称更新与关联 GROUP_UPDATE | U映射通过；M1 iOS发起/Android观察首次17/17步骤通过，含关联GROUP_UPDATE、群名详情与清理；证据见验证报告 |
| search-keyword-limits | `search_keyword_limits`；01 120/120/5 | 双端每词 1–120，总计≤120，最多5个；本次 Android 文档追齐，不新增 wrapper 校验 | `im_flutter_sdk/example/lib/registry/apis/chat_apis.dart` 有 server search；CI FL-MSG-003/004/005 是本地搜索，不能计为服务端关键词边界；旧424脚本不作为本轮通过 | 暂缓服务端边界：需开通搜索服务和明确非法参数错误契约；不以本地 search 或任意错误代替 | 暂缓；用户此前允许忽略424旧脚本，本轮不机械恢复；如环境具备，另选120字符/5词合法边界，无需第二客户端 | 不适用：搜索无需另一在线客户端 | 未执行/前置待核验 |
| sync-native-default | `options_data_sync_default`；02/CHANGELOG | null 不下传；Android 默认从 NONE→CONVERSATIONS，iOS 默认保持 | options 单测验证省略；共享 login 显式 contacts/groups，不能用于证明默认 | 保留 `im_flutter_sdk/example/integration_test/native_defaults_test.dart` FL-AUTH-007：依用户决定冷启动显式 dataSyncType=ChatDataSyncType.conversations（1），监听先于登录，断言同步 start/finish 类型为 conversations 且无错误、连接成功、登出清理。验证显式配置，不再覆盖 native 省略参数的默认选择；该设备覆盖缺口保留，不声称覆盖历史内容同步 | 不重复新增 JSON：现有脚本事件日志不能替代核心断言；显式同步配置由独立 CI 覆盖，省略参数的 native 默认行为当前不纳入设备验证 | 不适用：唯一在线客户端足够 | 迁移前 `default-sync-android.log`、`default-sync-ios.log` 各1例通过、清理通过，属于旧省略参数用例；当前显式配置 Android 1/1 通过（`artifacts/relocation-explicit-sync-android.log`），不沿用旧通过结论 |
| image-secret-compat | `image_thumbnail_secret_deprecated`；01/03 | 保留5.0图片secret迁移；视频thumbnailSecret仍有效 | `im_flutter_sdk/test/models/em_message_test.dart`已新增图片/视频secret对照，补齐旧基础往返的缺口 | 已新增 `image round trip uses secret and drops legacy thumbnailSecret`、`video round trip keeps distinct original and thumbnail secrets`：图片忽略旧字段，视频原图/缩略图密钥独立保留；无需调用已删接口 | 不适用：该项未新增 native 行为，纯数据契约优先 CI；附件真实行为另行列项 | 不适用：序列化无需多设备 | U：两项新增模型测试通过 |
| supp-load-all-sort | 验收报告首段、CHANGELOG New Features | loadAllConversations 默认/true 排序；false 关闭排序，但不保证结果与 true 不同 | `im_flutter_sdk/test/managers/chat_manager_test.dart` 三个 isSort 单测覆盖透传及不改 native 顺序；single500 `conversations` 仅 success | 新增同 conversation 模块 FL-CONV-010：本轮不同时间 fixture，默认/true 时间倒序；false 同集合，不要求不同顺序 | 暂缓single独立排序脚本：本轮由CI FL-CONV-010覆盖；任意历史列表与动态集合比较工具不支持，不扩展语法 | 不适用：本地行为 | U契约通过；N-A FL-CONV-010通过，N-I相同新增用例通过 |
| supp-ntp-token-expiry | CHANGELOG Native Fixes 第1项；01末段内部修复说明 | 双端启用NTP时按校准时间判断token到期 | 现有 renew/login 不制造设备时钟偏差，不覆盖此修复 | 暂缓：需要可控时钟偏差、NTP及token时序；不得修改共享宿主时钟 | 暂缓同因，普通登录只作回归 | 不适用：多设备不能替代受控时钟条件 | 未执行/专项环境缺失 |
| supp-wal-concurrency | CHANGELOG Native Fixes 第1项 | 双端启用WAL改善数据库并发 | 现有顺序CRUD不证明并发修复 | 暂缓：无发布说明对应复现/并发oracle；本轮会话CRUD可回归，不能宣称WAL性能/竞态已覆盖 | 暂缓：现有顺序脚本不能制造受控并发 | 不适用：客户端数量不等于单库并发 | 未执行/复现条件缺失 |
| supp-network-timeouts | CHANGELOG Native Fixes 第2项 | Android login70秒，TCP/WS20秒，非附件HTTP20秒，send重连/DNS20秒 | 普通在线API不能检验故障超时 | 暂缓：需网络黑洞/可控DNS或服务端；本轮不会改架构或共享网络设置 | 暂缓同因；不能用脚本自身30秒超时断言native70秒契约 | 不适用：需故障注入而非对端设备 | 未执行/环境缺失 |
| supp-attachment-final-callback | CHANGELOG Native Fixes 第3项 | iOS关闭自动附件传输且remotePath空、Android远端附件路径无效时，仍应有发送最终回调 | CI FL-MSG-006/007 是未登录/空target文本失败，不能证明此附件修复；example send注册已等待最终回调，但error只输出ChatError，丢失失败消息状态 | 暂缓本轮实施；建议下一步核对native错误/回调契约，再在message_cases中新增独立进程用例：autoTransferMessageAttachments=false、有定义的附件、先监听关联localId再发送，断言有终态回调。精确错误码尚需依据，不能猜或以任意异常通过 | 待确认核心观测：单设备success=false只能证明错误，若目标同时包含FAIL状态须补观测字段；没有该字段不能宣称状态正确 | 不适用：发送端最终回调可单设备完成 | 未执行/场景与错误契约核验中 |
| supp-event-ordering | CHANGELOG Native Fixes 第4项 | 双端修复消息/群事件顺序 | 现有多设备 delivery/group-member 场景验证到达，不定义笼统“顺序” | 暂缓：需具体前后事件因果与复现，不能按日志时间任意断言 | 暂缓：缺精确定义 | 待确认触发细节后再决定；不额外建立泛化多设备压力场景 | 未执行/预期不足 |
| supp-private-server-reconfigure | CHANGELOG Native Fixes 第4项 | 双端重复配置私有部署地址生效 | 无可用多套私有部署地址及预期行为输入 | 暂缓：需私有部署环境和配置顺序；不改当前公有云环境 | 暂缓同因 | 不适用：配置问题不天然依赖多设备 | 未执行/环境缺失 |
| supp-subscribed-users-list | CHANGELOG iOS Fixes | iOS subscribe 后 fetchSubscribedUsers 应含被订阅用户 | 既有 multi user-info 验证通知，不证明列表修复 | 已新增 `im_flutter_sdk/example/integration_test/user_info_subscription_test.dart` FL-USERINFO-001：显式 enableUserInfo=true、autoLoadConversations=true、enableChatroomConversation=false、dataSyncType=6；REST 创建本轮唯一离线非好友 peer→subscribe→列表恰含一次→unsubscribe→列表不含→删除并确认本轮 peer 不存在；独立资源 fixture 有单测。首测 iOS | 不重复新增 JSON：动态 ID 在 CI 直接比较，避免新增断言语法 | 不适用：被订阅者无需在线，不修改其资料，不使用旧关系 | iOS 1/1 通过，订阅后包含、取消后不含及临时账号清理均成功；`artifacts/resume-userinfo-ios.log`；Android 未选 |
| supp-conversation-dnd-sync | CHANGELOG iOS Fixes | iOS同账号多设备同步后会话免打扰状态正确 | 无现成针对该修复的场景；SDK有silent-mode API，但example注册与本地缓存观测未落实 | 暂缓：仅mock模型无法证明多端解析 | 不适用：目标必须另一客户端改变状态 | M2 已确认暂缓：须先确认可观察的本地状态；fetchConversationSilentMode是服务端读取，不能单独证明同步修复 | 未执行/观测契约缺失 |
| supp-history-last-message | CHANGELOG Android Fixes | Android 拉取并保存服务端历史后更新会话 lastMessage | FL-CONV-002 本地 insert 不能覆盖；需已有旧缓存，不能仅从空缓存读库 | 已新增 `im_flutter_sdk/example/integration_test/modules/message_cases.dart` FL-MSG-010（由原独立入口迁入）：本轮 REST 群+离线 peer 发消息，先消耗关联在线投递，再只删该本地消息、插入旧 sentinel 并预热 latest 缓存；fetchHistoryMessagesByOption(needSave:true) 返回该服务器 msgId 且 latest 更新；拒绝期间重复在线投递，独立清理群和会话。首测 Android | 不重复新增 JSON：由 CI 比较动态 msgId，未扩展执行器 | 不适用：peer 为 REST 离线发送方，不需要另一运行中客户端 | Android 1/1 通过，保存历史后 latest 更新，远端群与本地会话清理成功；`artifacts/resume-history-android.log`；iOS 未选 |
| supp-empty-message-filter | CHANGELOG Android Fixes | Android空内容入站消息不落库、不投递消息回调 | 发送空文本被拒不等于入站空消息过滤；无有效注入该服务端消息的fixture | 暂缓：需native修复对应消息类型/空内容定义、可注入源与有限观察窗口 | 暂缓同因 | 可能需要接收端，但当前无法证明服务端会投递该非法消息，先明确复现，暂不建场景 | 未执行/触发条件缺失 |
| supp-attachment-http-timeout | CHANGELOG Android Fixes | Android附件上传超时秒→毫秒换算正确 | 正常小附件上传不证明过短超时修复 | 暂缓：需可控慢速上传和具体native超时值；不能以一次成功代替故障回归 | 暂缓同因 | 不适用：上传端与网络条件即可 | 未执行/专项环境缺失 |

## 不纳入实施的变更

| 变更 ID | 升级决策 | 本次结论及证据 |
|---|---|---|
| options_remove_sync_ws_host | skip | 不适用：Flutter原本未暴露被移除sync WS host；01/04已做三端残留检查，普通webSocketServer仍有效，不混删 |
| options_remove_sync_ws_port | skip | 不适用：同上port；静态残留/构建是合适验证，不写已删除API运行用例 |
| options_agora_domain | skip | 不适用：KI-107明确国内品牌不暴露，未发生公共行为变更 |
| android_http_timeout_units | skip | 不适用：低层HttpClientConfig utility无Flutter映射；实际附件超时修复单独以supp-attachment-http-timeout评估，不因skip漏掉行为 |

## 完整性核对

- 原始变更：12；include 7、skip 4、defer 1。8个原始ID关联行为行，4个关联排除行。
- 追加变更：12个 `supp-*` 行，来自验收报告原有isSort和最终CHANGELOG Native Fixes；不混入原始12项。
- 行为行：21（群邀请字段与业务拆成两行，仍关联同一原始 ID）；不是用例数，也不是通过数。同一行为可由CI契约与设备测试共同覆盖。
- 未关联的原始ID：无。
- 迁移范围：初始化兼容的 FL-MSG-010 归入消息模块，特殊初始化套件按上表分批；原六步单设备用例拆分正逆向。当前复验进行中，历史通过不代替最终落点验证。
- 语义限制：FL-AUTH-007 按用户要求固定 conversations=1，当前设备用例不再覆盖省略 dataSyncType 的默认选择；pageSize有效区间明确，但除invalid cursor外不猜错误码；GROUP_UPDATE的具体触发采用“更新群组信息”，不把成员属性52当34；历史FL-MSG-006/007、暂停撤回及缺失消息回执崩溃场景不自动重判/恢复。

## 本轮已知失败与用户决定

用户明确“这俩问题先记录吧，跳过，继续”。本轮按主代理明确解释，对以下两类问题停止进一步修复/根因扩展，保留正确断言与失败证据，继续不受影响的测试；不删除用例、不把失败改为通过，也不将此决定扩展为忽略新的严重问题。

| 问题/范围 | 本轮证据与归因边界 | 本轮处理 |
|---|---|---|
| FL-CONV-006：删除全部消息后计数不一致 | Android N-A中deleteAllMessages后`count=1`，而`ids=[]`、`lastId=null`；原预期count=0失败。`conv006-android-autoload-false.log`独立一次通过，`conv006-android-autoload-true.log`独立失败，N-A的false全量运行也失败，说明不能简单归因某个开关；SDK计数/缓存不一致为当前嫌疑，根因尚未定。iOS首轮N-I的诊断loadMessage抛code=3中断；后续 `conv006-ios-diagnostic.log` 已确认 count=1、ids=[]，与Android计数现象一致，根因仍未知 | 用户决定记录并跳过深入处理。诊断调用改catch仅记录、原count/list断言保持；后续单例复验已完成，现已停止此问题后续执行 |
| FL-MSG-006/007：发送失败回调消息状态仍PROGRESS | 本轮N-A与N-I确认FL-MSG-007空target返回错误500，但回调消息状态PROGRESS而非FAIL；FL-MSG-006是未登录路径，smoke结果独立记录，不能用007或历史结果代替本轮006。发送错误与最终消息状态是不同观察点，附件回调修复也不能替代本项结论 | 用户决定记录并跳过修复/深入排查，正确FAIL断言保留；`smoke-android.log`、`smoke-ios.log` 均为16通过/1失败，006返回201但状态PROGRESS；停止此问题后续执行 |
| FL-CONV-013首轮清理失败 | 初轮REST缺失room的判据与实际返回不匹配，属于测试清理判断问题；已修正严格清理判据，N-A本例业务及清理通过 | 已修复用例/工具并复验，不归因SDK，不据此放宽真实发送或列表包含/排除断言 |

上述复验结果分别保留，单例偶然成功不覆盖全量失败。原始证据均位于`reports/5.1.0/test-coverage/`；完整命令、平台结果与归因进度由验证记录汇总。

## 迁移前恢复选测记录

以下记录属于组织迁移前的恢复批次：当时仅补验两个独立 CI 场景，各一次通过。当前 FL-MSG-010 已迁入模块，其他套件改为显式初始化，不能沿用这两项结果代替迁移后验证；本轮实际选测清单见验证报告。其余暂缓项保留缺口。

| 用例 | 首测平台 | 目标与理由 | 未选平台/补测条件 | 清理 |
|---|---|---|---|---|
| FL-USERINFO-001 | iOS | 发布说明明确 iOS 订阅列表修复；唯一离线 peer 的订阅→列表→取消链路 | Android 暂不选；仅在 iOS 异常且跨端有助归因时考虑 | 取消本轮订阅、删除本轮 peer、核查不存在、登出 |
| FL-MSG-010 | Android | 发布说明明确 Android 历史拉取后 lastMessage 缓存修复；needSave=true | iOS 暂不选；仅明确跨端差异或用户要求时补测 | 销毁本轮 REST 群、删除本轮本地会话、移除监听、登出 |

同一问题累计3次实际未通过即停止并跳过；已要求跳过的 FL-CONV-006、FL-MSG-006/007 不进入恢复选测。迁移前的新文件及 fixture 工具/单元补验已完成；当前布局复验进行中。执行次数、失败归因和批次结果见验证报告。

## 单设备工具边界与待确认项

1. `im_flutter_sdk/example/lib/auto/script_values.dart`目前支持`equals/gte/notEmpty/containsItem/length`，无否定成员、列表投影、集合比较、任意游标循环。可以用本轮可控固定fixture与静态预期验证小规模场景；不能删除历史会话以简化断言。
2. `im_flutter_sdk/example/lib/auto/auto_mode.dart`只对params解析`$config/$step/$prev`，`stepResultMatchesExpectation`接收原始expect；host `testing/single/auto_report.dart`也按原始expect判定。因此动态expect引用尚不可执行，直接写入会按字面字符串比较。该问题属于工具能力缺口，不能归因SDK。
3. `conversationToScriptJson`目前只输出id/type/name/avatar，排序需要的isPinned/pinnedTime等观测字段未暴露。补充已有模型的观测字段属于skill授权范围；新增断言语法/执行能力仍须先确认方案。
4. 单设备sendMessage注册确实执行发送并等待最终事件，但onError仅抛ChatError；若验证失败时消息状态，需要保留回调消息的观测结果，不能用创建消息状态替代。
5. 多个选项只初始化生效；切换true/false/default用独立应用进程，不假定二次init会重设native singleton。

## 多设备第二轮确认

用户批准多设备时，旧布局的单设备S-A/S-I六步及双端新增会话/群配置/默认同步CI已通过；两类已知失败依用户决定记录跳过，恢复后的两个单端CI也已通过。用户已回复“你的建议合理，继续”，批准 M1、M3 按下列最小组合各验证一次，并同意暂缓 M2。当前 M1、M3 场景及必要注册已实施；M1 首次 17/17、M3 首次 15/15 步骤均通过（含清理）；不增加其他场景或遍历设备组合。

### M1：同账号另一设备接收群信息更新事件（已批准）

- 覆盖行为：`group-update-event`（原始 `multi_device_group_update`）。
- 必须多设备：GROUP_UPDATE描述的是当前用户在另一设备修改群信息；一个客户端无法形成该观察点。
- 处理：修改既有 `testing/multi/data/5.0.0-multi-group-create-device-sync-positive.yaml` 与配对 `.json`，在创建后的最小流程增加更新步骤；沿用跨版本用例，不复制整套。
- 平台与角色：同账号A，a1/a2两个不同deviceId且同时在线；首测 iOS 发起、Android 接收的一组组合，Android 是本次新增事件能力端，服务端须允许同账号两设备。
- 前置：沿用device_id、online_devices、connected检查；新群由本轮创建且A为群主，独有groupId；必须提前注册/启动回调监听。`ChatGroupManager.updateGroupName`公共API已存在，本轮仅补 example 中已有 API 的透传注册。

| 顺序 | 执行角色 | 操作/等待 | 核心断言与关联数据 |
|---|---|---|---|
| 1 | a1/a2 | 初始化并同账号登陆，核对不同deviceId与两端在线 | 两个设备ID均在fetchLoggedInDevices结果；连接为true |
| 2 | a1→a2 | 创建本轮独有群；a2等GROUP_CREATE | event=GROUP_CREATE且groupId=本轮返回ID，保留既有断言 |
| 3 | a1 | updateGroupName(groupId,本轮新名称) | 调用成功，更新对象严格为本轮群 |
| 4 | a2 | 等onGroupEvent | event=GROUP_UPDATE且groupId=本轮群；不得以GROUP_CREATE/52替代 |
| 5 | a2 | fetchGroupInfoFromServer | groupId和新名称一致，辅助确认更新值；不能替代第4步事件 |
| 6 | a1/a2 | destroyGroup后登出 | 本轮群销毁、两端登出均执行 |

- 监听/等待：沿用事件缓冲机制，触发前监听就绪；单步30秒、整体300秒上限，无固定sleep。事件关联groupId，名称读取关联本轮新值。
- 必需结果：原requiredBindings全部保留，新增update、GROUP_UPDATE事件、detail三项，防止分支跳过还通过。
- 清理：创建确认后即使update/事件失败，也必须走destroy路径；已核对现有parallel+abort_flow仅终止当前业务分支，后续清理继续执行，并由工具回归验证。
- 稳定性：先运行上述最小组合一次，单次通过仅代表本轮通过；只有具体稳定性疑点才追加独立复验，不默认换向或遍历双端组合。失败遵守同一问题三次上限。
- 限制：本场景只证明群名称更新触发34，不外推所有群信息字段、事件全序或52。
- 用户决定及范围：已批准按本节范围实施及验证，iOS 发起、Android 观察，各一台设备；本轮首次 17/17 步骤通过（含 destroy、双方 logout），仅代表本轮成功，证据见验证报告。

### M2：会话免打扰跨设备同步（已确认暂缓）

- 覆盖行为：`supp-conversation-dnd-sync`，iOS发布说明修复。
- 必须多设备：a1同账号改变会话免打扰，a2 iOS观察同步后的本地状态。
- 现状：SDK有set/fetch/removeConversationSilentMode和syncConversationsSilentMode，但example未注册相关API，且“服务端fetch成功”无法区分a2本地同步解析是否正确。
- 暂缓理由：需先从native/公开契约定位a2可观察的本地同步结果，再定义操作、字段、事件/有限等待与恢复原值流程。当前缺oracle，给出可运行YAML只会制造伪覆盖。
- 后续候选位置：待契约明确后拟新增 `testing/multi/data/5.1.0-multi-conversation-dnd-sync-positive.{yaml,json}`；不在本轮未经确认时创建。
- 用户决定及范围：已确认暂缓；未实施、未执行。

不把`fetchSubscribedUsers`列表修复升级为多设备，也不为笼统事件顺序/空消息过滤提前建没有明确预期的场景。

### M3：群邀请接收并接受后确认成员关系（已批准）

- 覆盖行为：`group-invite-confirm-flow`，与字段回读分开；验证目标是实际邀请确认业务。
- 必须多设备：A 邀请 B，B 必须作为另一在线客户端接收并接受。REST 直接加成员、公开群主动加入及配置回读均不能替代。
- 已新增：`testing/multi/data/5.1.0-multi-group-invite-confirm-positive.{yaml,json}`。复用既有 group-member-join 的双账号登录、事件等待和失败收尾结构，不改写其主动加入目标。
- 最小组合：Android 群主 A、iOS 被邀请人 B，各一台客户端；不默认再换向跑一遍。
- 前置：A/B 均已连接，B 的 `autoAcceptGroupInvitation=false` 在初始化设置；监听在邀请前就绪。A 创建本轮唯一私有群，`inviteNeedConfirm=true`，创建时不传 B 为成员。仅作用于新群，不触碰历史群。

| 顺序 | 角色 | 操作 | 核心断言 |
|---|---|---|---|
| 1 | A/B | 初始化、分别登录并监听 | 两端连接就绪 |
| 2 | A | 创建本轮唯一群、再通过 addMembers 邀请 B | 新 groupId 有值；邀请调用成功 |
| 3 | B | 等待 onInvitationReceivedFromGroup | 同一事件同时匹配本轮 groupId 与 inviter=A |
| 4 | B | 调用 acceptInvitation(groupId, inviter=A) | 接受调用成功 |
| 5 | A/B | 各自 fetchMemberListFromServer(groupId, pageSize:200) 读取本轮群成员列表 | 两端查询结果均包含 B，不额外扩展拒绝/取消/其他群事件场景 |
| 6 | A/B | A 销毁本轮群；两端登出 | 清理必需绑定完整，业务失败仍执行收尾 |

- 已有能力：邀请接收事件已在 `example/lib/listeners.dart` 输出 groupId/groupName/inviter/reason。公共 SDK 已有 `addMembers`、`acceptInvitation` 和 `fetchMemberListFromServer` API，本轮已补齐 `group_apis.dart` 注册/返回字段；不新增执行器能力。
- 关联与等待：本轮唯一 groupId + inviter 关联；单步30秒、流程240秒有界等待。成员读取允许在现有工具支持范围内有限等待；若工具不能表达则先报告最小缺口，不用固定 sleep 或放宽成员断言。
- 清理：记录成功创建的 groupId；中间失败仍由 A 销毁，并分别登出，业务与清理失败分列。
- 稳定性限制：本轮仅选上述组合执行一次；单次通过不声称长期稳定。同一问题三次未通过后跳过。
- 用户决定及范围：已批准按本节范围实施及验证，Android 群主、iOS 受邀人，各一台设备；本轮首次 15/15 步骤通过（含邀请事件、接受、双方成员列表、destroy 与双方 logout），仅代表本轮成功，证据见验证报告。
