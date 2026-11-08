# 多设备协同用例验证记录

规格见[场景契约](2026-11-07-multi-device-cases-spec.md)。验收要求为每例在一个平台连续完整执行三轮；阻塞例保留实际轮次并暂停。本次使用双 Android 模拟器。未执行与未通过分别记录，不以其他场景或平台通过替代。

## 结果

| 场景 | 状态 | 证据 |
|---|---|---|
| 消息送达 | Android 三轮通过；iOS 另有一轮通过 | [送达回执记录](../troubleshooting/2026-11-07-delivery-receipt-read-flag.md) |
| 消息已读 | Android 连续三轮通过，每轮 13/13，任务故障 0 | 见轮次表 |
| 联系人申请与接受 | Android 连续三轮通过，每轮 13/13，任务故障 0 | 见轮次表 |
| 公开群入群 | Android 连续三轮通过，每轮 12/12，任务故障 0 | 见轮次表 |
| Presence | Android 连续三轮通过；iOS 全流程和分环节各通过一轮，均 16/16、任务故障 0 | 见轮次表及 README 实操验证 |
| 同账号双设备消息同步 | Android 连续三轮通过，每轮 13/13，任务故障 0 | 见轮次表 |
| 消息内容编辑 | Android 连续三轮通过，每轮 12/12，任务故障 0 | 见轮次表 |
| 消息撤回 | 按用户要求暂停执行；累计 1 轮通过、2 轮返回 505，未完成连续三轮 | 见轮次表及问题记录 |
| 群成员退出 | Android 连续三轮通过，每轮 14/14，任务故障 0 | 见轮次表 |
| 用户资料订阅 | Android 连续三轮通过，每轮 15/15，任务故障 0 | 见轮次表 |
| 群名片更新 | Android 连续三轮通过，每轮 14/14，任务故障 0 | 见轮次表 |
| 同账号双设备建群同步 | Android 连续三轮通过，每轮 14/14，任务故障 0 | 见轮次表 |

每轮完整结果在 `reports/<runId>/summary.md`、`statistics.csv`、`process.json`；步骤报告在 `reports/<runId>/<用例名>/1/flow-report.json`。原始事件在 `tmp/<runId>/<用例名>/1/<角色>-events.jsonl`。私有命令输入、账号及 Token 不随本记录提交。

## 轮次

| 场景／轮次 | runId | 关键关联证据 |
|---|---|---|
| 已读 1 | `20261107-234145-message-read-receipt-228474b3` | 消息 `1617061155077882268`；接收 seq 24，已读 seq 27 |
| 已读 2 | `20261107-234325-message-read-receipt-24e6db4e` | 消息 `1617061581173031320`；接收 seq 23，已读 seq 26 |
| 已读 3 | `20261107-234509-message-read-receipt-6fc557b6` | 消息 `1617062025064616356`；接收 seq 23，已读 seq 26 |
| 联系人 1 | `20261107-234911-contact-add-e2f7bc76` | 本轮理由匹配邀请 seq 24，接受通知 seq 28 |
| 联系人 2 | `20261107-235056-contact-add-d60d5b0e` | 本轮理由匹配邀请 seq 23，接受通知 seq 26 |
| 联系人 3 | `20261107-235235-contact-add-fd235101` | 本轮理由匹配邀请 seq 23，接受通知 seq 26 |
| 公开群入群 1 | `20261108-095550-group-member-join-8283997c` | 群 `329991732658177`；B 入群通知 seq 27，成员含 A |
| 公开群入群 2 | `20261108-095749-group-member-join-376e4ebf` | 群 `329991853244420`；B 入群通知 seq 26，成员含 A |
| 公开群入群 3 | `20261108-095937-group-member-join-3e97d844` | 群 `329991967539201`；B 入群通知 seq 26，成员含 A |
| Presence 1 | `20261107-235443-presence-0aa54619` | 通知 seq 29 匹配本轮描述，原空描述恢复成功 |
| Presence 2 | `20261107-235642-presence-8a2e035c` | 通知 seq 29 匹配本轮描述，原空描述恢复成功 |
| Presence 3 | `20261107-235827-presence-999e0675` | 通知 seq 29 匹配本轮描述，原空描述恢复成功 |
| 同账号同步 1 | `20261108-000042-message-device-sync-fa7b84c7` | 消息 `1617066041618203036`；a2 同步 seq 26 |
| 同账号同步 2 | `20261108-000236-message-device-sync-38d7189b` | 消息 `1617066530309144992`；a2 同步 seq 25 |
| 同账号同步 3 | `20261108-000429-message-device-sync-d22f3560` | 消息 `1617067019952193948`；a2 同步 seq 26 |
| 消息编辑 1 | `20261108-103516-message-edit-84d9fa27` | 消息 `1617229550863778200`；B 编辑通知 seq 24 |
| 消息编辑 2 | `20261108-103708-message-edit-ab8c2cf4` | 消息 `1617230030193033632`；B 编辑通知 seq 24 |
| 消息编辑 3 | `20261108-103850-message-edit-58e162da` | 消息 `1617230469231804828`；B 编辑通知 seq 24 |
| 消息撤回 1 | `20261108-104037-message-recall-13e2ff9a` | 消息 `1617230928671670684`；B 接收 seq 23，撤回返回 505 |
| 撤回复验 1 | `20261108-105535-message-recall-b5389872` | 消息 `1617234815998755232`；B 撤回事件 seq 24，12/12 通过 |
| 撤回复验 2 | `20261108-105732-message-recall-608ffec9` | 消息 `1617235312927310236`；B 接收 seq 23，撤回再次返回 505 |
| 群退出 1 | `20261108-101743-group-member-leave-e776a0b0` | 群 `329993101049860`；B 退出事件 seq 27，成员含 A |
| 群退出 2 | `20261108-101958-group-member-leave-abdad007` | 群 `329993240510466`；B 退出事件 seq 27，成员含 A |
| 群退出 3 | `20261108-102153-group-member-leave-4aa27f1b` | 群 `329993361096706`；B 退出事件 seq 27，成员含 A |
| 用户资料 1 | `20261108-104315-user-info-subscribe-c6d3383f` | A 资料事件 seq 29，匹配 B 与本轮昵称；原空昵称恢复成功 |
| 用户资料 2 | `20261108-104505-user-info-subscribe-63240b15` | A 资料事件 seq 29，匹配 B 与本轮昵称；原空昵称恢复成功 |
| 用户资料 3 | `20261108-104652-user-info-subscribe-c01bb617` | A 资料事件 seq 29，匹配 B 与本轮昵称；原空昵称恢复成功 |
| 群名片 1 | `20261108-102348-group-namecard-065bc3a4` | 群 `329993482731521`；B 名片事件 seq 27，值等于本群 ID |
| 群名片 2 | `20261108-102543-group-namecard-d7768215` | 群 `329993603317761`；B 名片事件 seq 27，值等于本群 ID |
| 群名片 3 | `20261108-102734-group-namecard-aaf9e9cf` | 群 `329993718661125`；B 名片事件 seq 27，值等于本群 ID |
| 建群同步 1 | `20261108-102928-group-create-device-sync-5a80999e` | 群 `329993840295940`；a2 `GROUP_CREATE` seq 53 |
| 建群同步 2 | `20261108-103117-group-create-device-sync-5db0d4c9` | 群 `329993954590725`；a2 `GROUP_CREATE` seq 28 |
| 建群同步 3 | `20261108-103304-group-create-device-sync-d67f47d9` | 群 `329994067836930`；a2 `GROUP_CREATE` seq 28 |

已读三轮的发送、接收端加载和回执均关联同一服务器消息 ID；回执 `conversationId` 为 B、`isPeerReceipt=true`。两端退出通过，三轮间未修改用例和断言。

联系人三轮均先匹配 A 与本轮唯一 reason，再接受并匹配 B 的接受通知；解除关系、双方退出全部通过。首轮按声明准备非好友前置，后两轮前置直接满足；没有把删除后的本地同步或会话状态加入断言。

公开群三轮均由 B 创建无审批公开群，不邀请 A；A 主动调用 `joinPublicGroup`，B 的原始 `onMembersJoinedFromGroup` 同时匹配本轮群 ID 和成员 A。每轮解散本轮群、双方退出及 HTTP finish 均成功。三轮使用同一份 YAML、JSON 和 APK（构建轮次 `20261108-095442-build-fbcc45ff`），实际 SHA-256 分别一致；用例选择及构建引用保存在 `tmp/20261108-group-join-input/`。

Presence 三轮均在同一事件元素内匹配 B 与本轮唯一描述；辅助查询、恢复原描述、退订及双方退出均通过。原描述是合法空字符串，恢复命令实际传入空字符串，未将缺通知或查询成功混同为通过。

同账号同步三轮均核验两个不同 SDK UUID 同时属于账号 A 的在线设备，第二端登录后双方仍连接；a2 收到的消息 ID、from、to、正文与本轮发送结果一致，双方退出通过。私有副本位于 `tmp/20261107-device-sync-input/`，与跟踪文件相比只填写了 `recipientId`。

前六例中，除已单独记录的送达场景外，其余五例共 15 轮全部通过，无失败重跑或未完成清理；未继续验证其他平台。三轮结果不表示长期稳定率已经达到 99%。

群退出和群名片均先核验本轮入群通知，再触发对应操作；退出事件关联本群和 A，名片事件额外关联本轮名片值。两例各三轮的解散、双方退出及 HTTP finish 均成功。

建群同步三轮均确认同账号两个不同 SDK UUID 同时在线；a2 的 `onGroupEvent` 精确匹配 `GROUP_CREATE` 与本轮群 ID。解散和双方 logout、finish 成功；不依赖通知序号相同，也不以普通群通知替代多设备通知。

消息编辑三轮均先在 B 确认原消息，再由 A 修改正文和扩展属性。B 的 `onMessageContentChanged` 同时匹配服务器消息 ID、发送／接收者、文本类型、新正文、`attributes.testRun` 和修改者 A；两端 logout、finish 均成功。

资料订阅三轮均先读取 B 的原资料；昵称是合法空字符串，性别为 0。A 的资料事件同一元素匹配 B、本轮唯一昵称和原性别。恢复命令明确传入原空字符串并返回原值，退订、两端 logout 和 finish 均成功；未将缺失/null 转为空字符串，未预置或对调账号。

新增六例中，消息编辑、群退出、用户资料、群名片、建群同步共 15 轮全部通过，未修改用例重跑。消息撤回累计 3 轮：开通前返回 505，用户确认后台开通后 1 轮通过、下一轮再次 505，仍暂停验收；详见问题记录。新增场景均未验证 iOS。

## 用例审查与回归

剩余五例的契约经同模型子代理审查；已读／联系人由主代理验收，联系人、Presence、同账号同步另做交叉代码审查。新增针对性回归：已读／联系人 9 项、Presence 7 项、同账号同步 13 项，均通过；既有执行模块 25 项回归与静态分析通过。回归覆盖错误事件关联、前置失败阻断和失败收尾，不能代替设备执行。

主代理核对四例各三轮冻结副本的 SHA-256：每例的 YAML、JSON 在三轮间分别一致；本轮唯一正文／理由／描述由运行数据生成。

公开群入口和用例经子代理实现、独立审查及主代理验收；10 项针对性回归通过，覆盖错误群／成员事件、早于命令响应的通知、前置失败阻断、入群失败和通知超时后的解散、解散失败后的双方退出。涉及文件静态分析与 Android 构建通过；主代理核对三轮原始事件、必要绑定和清理，子代理交叉核对前两轮及三轮产物哈希。

新增六例经同模型子代理实施和独立审查：消息／资料 22 项场景回归、群场景 15 项回归通过。example 新增 `recallMessage`、`leaveGroup`、`fetchOwnInfo` 入口及撤回通知结构化输出，10 项新增回归与既有 4 项发送回归通过；相关静态分析通过。

新增五个通过场景的 15 轮均完成独立原始证据验收；各例冻结 YAML、JSON、实际 APK 的 SHA-256 在三轮间分别一致。六例共享构建轮次 `20261108-101531-build-b4541dd6`，选择文件与构建引用位于 `tmp/20261108-collaboration-input/`。撤回失败轮次单独核验了错误来源与双方收尾，未记作通过；复验成功轮的 12 个必要绑定、目标撤回事件、双方 logout 和 HTTP finish 均由主代理核验。

## README 实操验证（2026-11-08）

按 README 的命令操作，只替换私有账号、模拟器 ID 和选择文件路径。使用 Flutter 3.47.0 / Dart 3.13.0；从已有私有配置重新生成账号源码，由 CLI 构建并安装 App。

| 路径 | 轮次 | 结果 |
|---|---|---|
| 双 iOS Presence，`all` | `20261108-112905-presence-ea6aa6cc` | 16/16；任务故障 0 |
| 双 iOS Presence，`prepare → devices start → build → launch → run → report` | `20261108-113158-presence-c68e7aba` | 16/16；任务故障 0 |
| 双 Android 批量：联系人申请 → 同账号消息同步 | `20261108-113714-batch-01e697f9` | 两例各 13/13；任务故障 0 |

四次用例执行均核验退出及双方 HTTP finish 成功。批量轮次验证 `--data-input`、不同账号到同账号的角色切换，以及 `tmp/` 用例副本的 `recipientId` 配置；撤回场景未执行。

`dart pub get`、账号生成、双平台设备列表、`dart analyze` 和 `dart test` 均成功，单元测试 224 项通过。命令输出、原 README 副本及验收摘要保存在 `tmp/20261108-readme-check/`；用例报告按上述 runId 查询。

文档缺项已修正：分环节 `run` 后只存在 `flow-report.json`，还须执行 `report` 才会生成汇总、CSV 和过程索引；`report` 成功时终端无输出。清理实操发现下述过程证据引用问题，未修改工具代码；后两轮未清理，保留完整证据。

## 已记录问题

### 清理后过程记录引用失效（待修复）

- 触发：按 README 完成双 iOS Presence 轮次 `20261108-112905-presence-ea6aa6cc`，生成报告后执行 `clean --run-id 20261108-112905-presence-ea6aa6cc --type logs --type build`。命令返回 0，删除 17 项、保留 12 项、删除失败 0 项。
- 问题：保留的 `process.json` 中，`operations[*].result.evidence` 有 15 个引用指向已删除文件，涉及准备、设备、构建和启动环节。`summary.md`、CSV、过程记录文件本身、用例必要断言证据及账号源码均保留；本次用例通过结论不受影响，受影响的是完整过程追溯。
- 原因：[reporting.dart](../lib/src/reporting.dart) 的 `generate()` 仅从用例行的 `row.evidence` 登记报告依赖，却同时把全部 `snapshot.operations` 写入 `process.json`；上述 15 项均未进入 `reportDependencies`。[cleanup.dart](../lib/src/cleanup.dart) 按登记依赖计算保护范围，因此允许删除这些仍被过程记录引用的日志。
- 处理边界：问题位于报告依赖登记与验收，未修改工具代码或降低清理保护要求。修复应补齐过程记录的证据依赖并验证“真实报告 → 清理 → 引用仍可读取”；需要保留完整过程时暂缓日志清理。
- 复核证据：`tmp/20261108-readme-check/14-clean-ios.log`、`cleanup-reference-audit.json` 和该轮 `reports/<runId>/process.json`；原始执行事件及 `flow-report.json` 仍可读取。

### 消息撤回：后台开通后仍出现 505（按用户要求暂停执行）

- 轮次：`20261108-104037-message-recall-13e2ff9a`。发送和 B 接收均成功，A 的 `recallMessage(messageId, ext)` 返回 SDK `505: Service is not enabled`；没有执行依赖该结果的撤回通知等待。
- 结果：执行的 11 步中 10 步通过、1 步失败；报告保留 `issue-1`，用例未通过。双方 logout 和 HTTP finish 成功，未盲目重发或重试撤回。
- 用户于 2026-11-08 确认 505 是服务未开通，并已在后台开通。复验 1 通过 12/12，B 的撤回通知同一元素准确匹配服务器消息 ID、操作者 A 和本轮 `ext`；复验 2 的撤回再次返回相同 505，执行的 11 步中 10 步通过。两轮双方 logout、finish 均成功。
- 输入核验：两轮环境数据、初始化参数、登录参数相同，冻结 YAML／JSON 与原失败用例一致；实际 APK SHA-256 均为 `976bc3c3504d2e5ae4c6ea81069a273cab47907ae066750d713296abb5babdad`。撤回参数仅本轮消息 ID 和唯一 `ext` 不同，未修改用例、断言、代码或服务配置。
- 源码核对：`emclient-linux` 的 `SDK_5.0.0` 标签（`2f4d2094c`）中，`src/emchatmanager.cpp:5574` 的 `asyncRecallMessage` 经本地登录、连接、消息有效性检查后发送请求并等待响应（5616–5627）；1649–1651 将服务响应原因 `message recall disabled` 映射为 505。该路径未发现本地服务开关判断，`ext` 作为请求扩展字段透传。
- 证据边界：工程声明 native 5.0.0，未逐项核对 APK 内 native 二进制的构建身份；实跑日志记录了 505，未保存原始 Sync reason 或服务节点。尚不能确定配置生效延迟、节点差异或其他服务端原因，也不能认定仅 `ext` 引起。
- 处理：2026-11-08 用户明确要求该场景暂不执行。保留用例、正确断言及全部成功／失败证据，不再主动复验；待用户明确通知恢复后再执行。该场景未通过稳定性验收，不记作问题已解决。
- 证据：上述三轮 `flow-report.json`、`alice-events.jsonl` 的 `api.ChatManager.recallMessage`、`bob-events.jsonl` 的接收／撤回事件；失败轮保留各自的 `tmp/<runId>/issue-1.md`。

### 撤回事件的结构化记录（已补齐）

历史设备轮次使用 example 特化输出的 `recallMessageId/recallBy/conversationId/recallMessage/ext`，复验 1 确认字段关联正确。当前由 SDK `RecallMessageInfo.toJson()` 输出 `recallMsgId/recallBy/convId/msg/ext`，与 `fromJson()` 一致，保留合法 null；用例字段引用已同步。历史报告保留原样，不代表当前序列化实现已完成设备验证；撤回场景仍暂停。

2026-11-08 序列化回归通过：SDK 模型 16 项、example API 注册与输出 18 项、模拟事件驱动的消息／资料／Presence 流程 29 项；相关文件静态分析通过。覆盖 JSON 编解码、嵌套消息、null 与空值，以及消息 ID／操作者／ext 必须匹配同一事件元素的断言。

### 公开群入群：执行端缺少命令（已解决）

- 原因：SDK [ChatGroupManager](../../im_flutter_sdk/lib/src/managers/chat_group_manager.dart) 已提供 `joinPublicGroup`，example 注册表缺少对应入口；建群时邀请 A 不能替代 A 主动入群。
- 处理：2026-11-08 经用户确认，在 [example 注册表](../../im_flutter_sdk/example/lib/registry/apis/group_apis.dart) 补充直接调用 `joinPublicGroup(groupId)` 的入口，重新构建 App；未新增 SDK API、解释器语法或辅助脚本。
- 验证：[公开群入群用例](../data/5.0.0-multi-group-member-join-positive.yaml) 双 Android 连续三轮通过，见轮次表；iOS 未验证。

### 同账号同步：无设备收件人的输入（历史记录）

以下为此前轮次的输入方式；当前使用独立账号编号，见下方验证记录。

- 事实：`$global.account` 只包含 YAML 设备角色；a1/a2 均为 A 时，已生成的 B 不自动进入该映射。
- 处理：沿用现有 JSON `data.input.recipientId`，在 `tmp/` 私有用例副本填入 B，再交给 CLI 冻结。跟踪文件默认为 null，未填写禁止发送、不能通过；不变更数据模块契约、不伪造角色映射。
- 边界：若要求自动从生成账号中选择无设备收件人，需要单独确认数据交付规则；本次不增加该能力。


## 2026-11-08 账号与设备独立映射验证

[账号与设备独立管理规格](2026-11-08-account-device-separation-spec.md)已完成实现验证。配置分别保存 `accounts/devices`；命令使用 `account1` 至 `accountN`，YAML 选择执行设备。生成器直接引用 `data/` 源用例，不生成持久化用例副本，不要求 `selection.accounts`。

### 双 Android 稳定性

模拟器：`Pixel_9`、`Pixel_9_2`。三个场景通过 `all --cases config/cases.json` 串行执行；第 2、3 轮使用 `--build-result tmp/account-device-build.json` 导入首轮 APK。三轮账号设备映射、冻结 YAML/JSON 摘要及 APK 摘要一致，期间未调整用例。

| 轮次 | Presence | 同账号建群同步 | 同账号消息同步 | 任务故障 |
|---|---|---|---|---|
| `20261108-141700-batch-d9b97504` | 16/16 | 14/14 | 13/13 | 0 |
| `20261108-142142-batch-357b0106` | 16/16 | 14/14 | 13/13 | 0 |
| `20261108-142615-batch-c0eda987` | 16/16 | 14/14 | 13/13 | 0 |

共 9 次执行通过。逐轮核对：Presence 发布者与本轮唯一状态一致；建群通知关联本轮群 ID；消息同步通知在同一消息元素内匹配服务器消息 ID、发送者、无设备收件人及本轮正文。匹配事件的序号和内容均可在设备原始事件记录中定位。退订、原状态恢复、解散群、双方 logout 及 HTTP finish 均成功。

本次设备验证仅覆盖上述三个 Android 场景；其余 8 个未暂停场景通过静态装载、数据契约及既有回归检查，未重新实跑。消息撤回仍暂停。

### 自动化检查与证据

- `testing_v2` 241 项、`flow_runner` 91 项测试通过，两包静态分析通过。
- 覆盖独立账号/设备选择、一账号多设备、三账号两设备、无设备账号参与故障隔离、分环节读取固定输入、无效映射拒收、缺失账号不派发命令、暂停用例拒绝执行。全部 11 个未暂停源用例通过生成和数据交接校验。
- 配置生成不改写源用例；12 份 JSON 的命令参数和核心断言与原内容对照，仅调整账号引用、联系人前置引用及移除收件账号占位值。账号配置和生成源码未改变。
- 汇总、统计及过程索引：`reports/<runId>/summary.md`、`statistics.csv`、`process.json`；原始报告：`reports/<runId>/<用例名>/1/flow-report.json`；原始事件和设备日志：`tmp/<runId>/<用例名>/1/`。
- 执行日志：`tmp/account-device-validation-1.log` 至 `-3.log`；回归日志：`tmp/account-device-tests.log`、`tmp/account-device-flow-tests-host.log`。

### 按 README 双 iOS 抽验

轮次 `20261108-145740-presence-c18371f2`：按 README 依次执行 `dart pub get`、`generate_accounts_input.dart`、`generate_accounts.dart --input config/accounts-input.json`、`generate_cases.dart --platform ios --case 5.0.0-multi-presence-positive`、`all --cases config/cases.json`。已有账号输入保留，Token 重新获取，选择文件直接引用源用例。

- 设备：自动选中的 iPad (A16)／iOS 18.6 与 iPad Air 11-inch (M2)／iOS 18.2；Flutter 3.47.0。
- 结果：设备准备、重新构建、安装启动及执行成功，CLI 退出码 0；Presence 16/16 步通过，任务故障 0。A 的 `onPresenceStatusChanged`（`seq=30`）同时匹配 B 与本轮唯一发布值；退订、恢复原状态、双方 logout 和 HTTP finish 成功。
- 产物：`reports/<runId>/summary.md`、`statistics.csv`、`process.json` 自动生成；步骤报告及原始事件位置同上。过程记录的 33 个阶段证据引用均可读取，未清理产物。
- 本轮抽验未发现 README 操作或场景执行问题，未修改代码和用例；仅验证一个场景的一轮，不代表全部 iOS 场景或多轮稳定性验证。
