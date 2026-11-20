# CI 基础 API 统计与筛选

日期：2026-11-07。代码基线：`testing` / `34646c52`。状态：筛选取舍已确认，正向实现与部分设备验证完成；验收状态见[验证记录](2026-11-07-positive-verification.md)。

依据：[测试规格](../../spec/2026-11-07-ci-basic-api-tests-spec.md)。以下范围依据源码和现有测试筛选，不表示已验证运行稳定。

逆向逐项核对、用例编号和验证结果见[逆向用例记录](2026-11-07-negative-verification.md)。

## 1. 结论与统计口径

本轮范围包括客户端、消息发送、会话、本地消息、联系人与黑名单、群组生命周期和既有未登录 Presence：**58 个方法，其中 35 个已有设备用例调用，新增触达 23 个**。另有 5 个方法待核实验证方式，178 个本轮不纳入独立验证。

| 用途 | 方法数 | 验证边界 |
|---|---:|---|
| 正向行为相关 | 52 | 包含 2 个仅保留既有零未读边界的方法，不扩量、不计为完整未读／清零功能覆盖 |
| 保留的 Presence 逆向 | 5 | 未登录返回 201，继续回归；不代表已覆盖发布、订阅成功 |
| 基础准备 | 1 | `startCallback`，不计为独立业务覆盖 |

后续新增逆向按明确契约选择，不以方法数预设用例数。

本轮仅考虑单设备用例；保留现有两个测试文件作为主入口，组织方式见 §6。明确不做：多设备协同、Thread、Room、Push，以及 `renewToken`、`getUnreadMessageCount`、`clearAllConversationUnreadMessageCount`。当前方案未实现并验证可控的设备断网模拟，本轮不支持主动断网测试。

统计范围是主包公开导出的 9 个管理器，以及 `ChatConversation`、`ChatMessage` 的公开 `Future` 方法，共 **241 个**。同名方法按所属类分别计数；不重复计算 `EM*` 兼容别名，不计私有方法、构造器、属性、枚举、同步模型转换及事件处理器注册方法。因此 241 是公开异步操作数，不是全部公开成员数。

“已有调用”按两个集成测试文件中去除注释后的实际调用去重，包含准备和清理，**不等于行为已充分覆盖**。方法数也不等于用例数；当前设备集成测试为 13 例。

| 模块／类 | 异步方法 | 已有调用 | 本轮涉及 | 待核实 | 本轮不纳入 |
|---|---:|---:|---:|---:|---:|
| [ChatClient](../../../im_flutter_sdk/lib/src/managers/chat_client.dart) | 27 | 7 | 8 | 0 | 19 |
| [ChatManager](../../../im_flutter_sdk/lib/src/managers/chat_manager.dart) | 50 | 4 | 13 | 1 | 36 |
| [ChatConversation](../../../im_flutter_sdk/lib/src/models/chat_conversation.dart) | 23 | 19 | 19 | 0 | 4 |
| [ChatPresenceManager](../../../im_flutter_sdk/lib/src/managers/chat_presence_manager.dart) | 5 | 5 | 5 | 0 | 0 |
| [ChatContactManager](../../../im_flutter_sdk/lib/src/managers/chat_contact_manager.dart) | 13 | 0 | 8 | 0 | 5 |
| [ChatGroupManager](../../../im_flutter_sdk/lib/src/managers/chat_group_manager.dart) | 54 | 0 | 5 | 0 | 49 |
| [ChatRoomManager](../../../im_flutter_sdk/lib/src/managers/chat_room_manager.dart) | 30 | 0 | 0 | 0 | 30 |
| [ChatThreadManager](../../../im_flutter_sdk/lib/src/managers/chat_thread_manager.dart) | 12 | 0 | 0 | 0 | 12 |
| [ChatUserInfoManager](../../../im_flutter_sdk/lib/src/managers/chat_user_info_manager.dart) | 7 | 0 | 0 | 4 | 3 |
| [ChatPushManager](../../../im_flutter_sdk/lib/src/managers/chat_push_manager.dart) | 17 | 0 | 0 | 0 | 17 |
| [ChatMessage](../../../im_flutter_sdk/lib/src/models/chat_message.dart) | 3 | 0 | 0 | 0 | 3 |
| **合计** | **241** | **35** | **58** | **5** | **178** |

可在仓库根目录复核异步方法清单；下列提取针对本基线的类成员声明格式，同时处理跨行返回类型：

```bash
python3 - <<'PY'
from pathlib import Path
import re
total = 0
for path in sorted(Path('im_flutter_sdk/lib/src').rglob('*.dart')):
    names = re.findall(r'^  Future(?:<[^;]+?>)?\s+([A-Za-z_]\w*)\s*\(',
                       path.read_text(), re.M)
    names = [name for name in names if not name.startswith('_')]
    if names:
        total += len(names)
        print(path.name, len(names), ', '.join(names))
print('Total:', total)
PY
```

## 2. 现有覆盖与缺口

| 用例 | 当前验证 | 需要补足或限定的内容 |
|---|---|---|
| `FL-APP-001` | 冷安装后初始化，当前用户为空 | 保留冷安装条件，不能将上轮账号残留误判为初始化问题 |
| `FL-PRESENCE-001`～`005` | 5 个 Presence 方法未登录时返回错误码 201 | 保留；只证明未登录边界，不代表订阅、发布和通知链路已覆盖 |
| `FL-AUTH-001` | 登录后用户、连接状态、Token | 退出只在清理中调用，缺少退出后的状态断言；设备 ID 未覆盖 |
| `FL-CONV-001` | 创建、列出、设置扩展、删除会话 | 扩展只读取原 Dart 对象；应重新获取会话核对原生返回值。增加不自动创建、删除时保留消息等边界 |
| `FL-CONV-002` | 消息数量、最新消息、最近接收消息、零未读清零 | 注释记录本地插入不增加未读数；现有 `0 → 0` 只能验证零值和幂等性，不能声称验证非零清零 |
| `FL-CONV-003`、`006` | 本地更新及多种删除操作 | 删除后加载不存在消息的断言被注释；应逐次核对剩余消息集合和数量，不能仅靠最后一次清空证明前面删除有效 |
| `FL-CONV-004` | 双向分页包含预期消息 | 补精确数量、起点排除和跨页无重复；返回顺序按明确契约核实后断言 |
| `FL-CONV-005` | 关键字、类型、选项、时间查询 | 增加不匹配数据，核验排除项、空结果和范围，避免仅 `contains` 掩盖过滤失效 |

源码：[未登录测试](../../../im_flutter_sdk/example/integration_test/no_login_presence_test.dart)、[登录与本地数据库测试](../../../im_flutter_sdk/example/integration_test/single_account_local_test.dart)。

`ChatConversation.loadMessage` 的不存在消息行为需单独核实：现有注释记录 iOS 抛错、Android 返回 null；iOS wrapper 转发原生 `loadMessageWithId:error:` 的错误，Android wrapper 在消息缺失时返回 null。本次未实测确认错误码，也不据此新定义平台差异契约。删除行为可用剩余集合和数量独立验证，不应因此取消删除断言；缺失消息的返回契约仍须保留为待核实边界。

纯 Dart 模型转换、错误映射、Presence 注册管理、连接和多设备事件分发已有 [单元／契约测试](../../../im_flutter_sdk/test/)；这些证据不代表原生业务已通过，也不需要全部重写为设备用例。

## 3. 本轮验证范围

### 3.1 客户端：8 个方法

| 方法 | 拟验证行为 | 前提与收尾 | 现有情况 |
|---|---|---|---|
| `init`、`startCallback` | 冷安装初始化后无当前登录用户；`startCallback` 作为需要回调的基础准备，不单独宣称回调能力已覆盖 | 每进程初始化一次；未登录初始化不需要账号 | 已调用；沿用 `FL-APP-001` |
| `loginWithToken`、`getCurrentUserId`、`isConnected`、`getAccessToken`、`logout` | 登录身份和状态正确；退出后缓存用户与原生用户为空、连接已断开；同进程重新登录仍可使用 | 一个有效账号及网络；连接状态有条件等待和超时；清理退出 | 已调用；补退出及重新登录断言，Token 不写日志 |
| `getCurrentDeviceId` | 已登录时取得非空设备 ID，同一运行会话重复读取一致；不假定卸载后仍不变 | 复用登录前提 | **新增** |

8 个包含 1 个仅作准备的 `startCallback`，不为它机械新增独立用例。异步连接状态不能假定方法返回瞬间已经完成变化。

### 3.2 ChatManager：13 个方法

登录和消息发送需要网络，发送对象使用受控账号，无需启动接收端；其余所选操作使用本地数据库。每例使用可识别的本轮会话和消息数据；本地查询使用确定时间戳，只清理本例资源。

消息和会话不要求全局回收，相关用例及已有本地清理保留；删除 API 自身仍须验证删除行为，不将本地删除视为服务端或其他账号记录已清除。

| 方法 | 拟验证行为 | 现有情况 |
|---|---|---|
| `sendMessage` | 先注册监听，关联本次消息的异步成功／失败回调及超时；成功回调验证服务器确认发送，不声称接收方已收到 | **新增**；使用受控收件人和本轮消息标识，方法返回不替代最终回调 |
| `getConversation`、`loadAllConversations`、`deleteConversation` | 创建、重新获取、列表包含本例会话；补充发送消息后产生会话的路径；`createIfNeed: false` 不创建；删除及 `deleteMessages` 两种行为，保留的消息用消息 API 验证 | 已调用，补关键边界；列表不能要求全局只含本例数据 |
| `deleteConversations` | 删除指定的多个本地会话，未指定会话保持不变；不存在 ID 按公开说明忽略 | **新增**；仅传入本例会话 ID |
| `importMessages`、`loadMessage`、`loadMessagesWithIds`、`updateMessage` | 导入当前用户发送／接收的少量消息；按 ID 单条及批量读取，核对正文、属性、归属；更新后 ID 不变且内容可读取 | **新增 4 个**；不测试批量性能，不把导入当作真实接收或未读增长 |
| `loadMessagesWithKeyword`、`searchMsgsByOptions`、`loadConversationMessagesWithKeyword` | 使用唯一关键字、发送方及混合类型数据验证匹配与排除；会话聚合结果的 key 和消息 ID 对应正确 | **新增 3 个**；跨会话搜索通过本例唯一数据限定范围 |
| `clearConversationUnreadMessageCount` | 本例会话零未读时重复清零仍为零 | 只保留既有零值边界，不新增用例，不计为完整清零功能覆盖 |

`sendMessage` 的完成语义已由两端 wrapper 确认：普通方法结果返回当前消息，最终结果通过消息通道发送。证据：[Android](../../../im_flutter_sdk_android/android/src/main/java/com/easemob/im_flutter_sdk/ChatManagerWrapper.java)、[iOS](../../../im_flutter_sdk_ios/ios/im_flutter_sdk_ios/Sources/im_flutter_sdk_ios/ChatManagerWrapper.m)。其服务器确认作为发送用例的验证依据。

### 3.3 ChatConversation：19 个方法

准备和清理同 §3.2；全部已有调用，重点是提高断言的有效性。

| 方法 | 拟验证行为 |
|---|---|
| `setExt` | 设置、替换扩展后重新获取会话核对内容；不通过原对象的 `_ext` 赋值证明原生保存成功 |
| `insertMessage`、`appendMessage`、`loadMessage`、`updateMessage` | 插入和追加后核对消息归属、正文、属性；更新后 ID 不变且重新加载内容正确；缺失 ID 的精确返回规则见 §2 |
| `latestMessage`、`lastReceivedMessage`、`messagesCount` | 构造不同时间的本地收／发消息，核对最新消息、最近接收消息及数量；不宣称验证了网络收消息 |
| `unreadCount` | 只保留既有零值检查，不新增用例，不计为完整未读功能覆盖 |
| `loadMessages` | 上下翻页、精确数量、起点排除、页间无重复、末页与无更多结果；不使用恰好整页的数据掩盖边界 |
| `loadMessagesWithKeyword`、`loadMessagesWithMsgType`、`loadMessagesFromTime`、`searchMsgsByOptions`、`getLocalMessageCount` | 核对命中及不命中集合、筛选条件和时间范围内数量；精确端点是否包含先查明契约，不凭实现猜测 |
| `deleteMessage`、`deleteMessageByIds`、`deleteMessagesWithTs`、`deleteAllMessages` | 每次删除后核对剩余集合和数量、未选消息仍在；清空后为空。按时间删除先使用明确位于区间内部／外部的数据 |

### 3.4 Presence：5 个方法

`publishPresence`、`fetchPresenceStatus`、`subscribe`、`unsubscribe`、`fetchSubscribedMembers`：保留现有未登录返回 201 的独立用例。前提是冷安装、初始化成功且未登录，无账号或服务器业务数据准备。

本轮不新增“已登录发布、订阅成功”的覆盖承诺；它们与已保留的未登录边界是不同的行为。

### 3.5 联系人：8 个方法

| 方法 | 准备、断言及清理 |
|---|---|
| `getAllContactIds`、`getAllContacts`、`getContact` | 准备受控好友及非好友账号，独立核验服务端好友关系；SDK 列表须在有限等待内包含指定好友、排除非好友，详情对应正确账号；结束后恢复本轮修改的关系 |
| `deleteContact` | REST 建立并核验好友关系；分别传入 `keepConversation: true/false`，仅验证 API 成功返回；不准备会话和消息，不追加 REST、本地列表、监听通知或会话断言；结束后恢复原好友关系 |
| `addUserToBlockList`、`removeUserFromBlockList`、`fetchBlockIds`、`getBlockIds` | 保存目标的原始黑名单状态；SDK 添加后核对远端、本地列表包含目标，移除后两处均排除目标，未指定账号不受影响；结束后恢复原状态并核验。不宣称验证了对方消息被拦截 |

八个方法均为新增验证目标。准备方式须能在单设备执行条件下建立关系；不能将发出好友邀请或等待固定时间视为准备成功。

`deleteContact` 的 iOS 封装错误已通过独立数据实测确认：[wrapper](../../../im_flutter_sdk_ios/ios/im_flutter_sdk_ios/Sources/im_flutter_sdk_ios/ContactManagerWrapper.m) 修复前将 `keepConversation` 原样传给 native 的 `isDeleteConversation`，两个取值的保留／删除行为均与公开契约相反。用户修正取反后，专项验证 2/2 通过；旧正式用例曾因本地联系人更新超时失败，Android 诊断也出现过同类异常，见[专项排查](2026-11-07-delete-contact-investigation.md)。经用户确认，`FL-CONTACT-002/003` 的范围收敛为删除 API 成功返回；两个参数取值均执行，但不宣称覆盖会话语义或本地同步。旧失败保留，同步问题不因范围调整而视为修复。

### 3.6 群组：5 个方法

| 方法 | 准备、断言及清理 |
|---|---|
| `createGroup`、`fetchGroupInfoFromServer`、`destroyGroup` | 受控群主通过 SDK 创建唯一名称的群，指定成员及无需邀请确认的配置；按返回 ID 远端读取并核对群主、名称、描述和配置，成员使用明确的成员查询核验；通过 SDK 销毁并核验远端不存在。查询超时、鉴权失败等不能当成群已销毁 |
| `getGroupWithId`、`getJoinedGroups` | 明确 SDK 本地数据填充步骤，再核对指定群组内容及已加入列表；本地对象非空不能证明服务端群存在。查询用例自行准备和回收资源，不依赖另一个用例先创建群 |

五个方法均为新增验证目标，无需启动成员客户端。群详情不保证携带完整成员列表，不能仅凭创建参数或详情对象认定成员已就绪；iOS 本地 `getGroupWithId` 可构造群对象，应明确本地与远端的观察边界。

本轮新建群在成功或失败后均须回收。销毁失败时记录群 ID 和错误，可进行必要补救清理，但不能覆盖被测销毁接口的原始失败。群名和描述修改本轮暂缓，优先保护创建、查询、销毁链路。所用准备和清理 API 须列明，不能仅因被调用就宣称其全部业务语义已覆盖。

### 3.7 现有数据准备能力

以下为保留的数据准备入口；配置和服务端资源的实际状态在运行时验收。临时群组准备与回收见 [CI 资源夹具](../../../im_flutter_sdk/example/integration_test/support/rest_fixture.dart)。

| 入口或工具 | 已有能力与使用边界 |
|---|---|
| [Makefile：env-gettoken](../../../Makefile) → [env_tool.dart](../../../im_flutter_sdk/example/tool/env_tool.dart) | 获取 App Token，再为配置中的账号获取 User Token；账号 ID 保持不变，将账号和配置中的 `groups`、`rooms` 写入 `example/lib/env.dart`。群组 ID 只透传，不创建或核验群组 |
| [rest_resource_client.dart](../../../im_flutter_sdk/example/tool/rest_resource_client.dart) | 提供好友列表查询、直接建立好友关系、双向删除；添加前只查询一个方向，增删后仍需补充双向核验，不能将无异常返回当成关系已核验 |

CI 参考这些基础能力，不因此接入 AI 测试编排或改变既有入口。复用已有群组时先验证资源及成员，只删除本轮创建的群；既有关系按修改前状态恢复。上述生成入口不会强制创建 Room 或 Thread，本轮也不调用这些能力。

## 4. 待核实：5 个方法

以下需核实数据准备与可靠断言方式，不能仅以“当前没有准备工具”为由排除。若确实无法验证则不纳入，不降低断言要求。

| 模块与方法 | 未满足的条件 | 转为候选的条件 |
|---|---|---|
| ChatManager：`getAllMessageCount`（1） | 可用原始数量 `N` 验证增删，无需清空历史数据；已有离线同步结束事件，但零离线消息时的事件行为及并发入库隔离尚待核实 | 使用受控独占账号，确认同步就绪后记录 `N`；插入本轮 `k` 条消息验证 `N+k`，删除后回到 `N`。固定等待或连续两次计数相同不能代替同步就绪证据 |
| UserInfo：`updateUserInfo`、`fetchOwnInfo`、`fetchUserInfoById`（3） | `clearUserInfoCache()` 可清除 Dart 缓存；`expireTime: 0` 同毫秒仍可能命中。待核实的是完整原值恢复，尤其原字段为空时；传 `null` 会省略字段，不能直接当成清空 | 每次验证读取前清理 Dart 缓存，保存完整原属性快照，确认写入影响范围及原值可恢复，恢复后独立重读核验 |
| UserInfo：`getLocalUserInfoByIds`（1） | 独立调用 native，不读取上述 Dart 缓存；原生本地缓存的填充条件和完成时机尚未明确 | 用受控远端值验证明确的本地缓存填充过程，再精确核对本地结果；不能把缺失数据当作通过，也不宣称已证明磁盘持久化 |

更新方法返回的对象不能自证服务端保存成功。以上待核实项尚不进入当前开发范围。

依据：[UserInfo 实现](../../../im_flutter_sdk/lib/src/managers/chat_user_info_manager.dart)、[iOS 属性转换](../../../im_flutter_sdk_ios/ios/im_flutter_sdk_ios/Sources/im_flutter_sdk_ios/UserInfoHelper.m)、[消息计数](../../../im_flutter_sdk/lib/src/managers/chat_manager.dart)、[离线同步事件](../../../im_flutter_sdk/lib/src/handlers/manager_event_handler.dart)。

## 5. 本轮不纳入独立验证的范围

下表涵盖各类扣除 §3、§4 后的全部剩余方法；其中明确排除项本轮不做，其余未选为独立验证目标，不代表接口不稳定。联系人、群组的必要准备与清理按 §3.5、§3.6 执行。

| 模块 | 剩余数 | 理由 |
|---|---:|---|
| Client | 19 | `renewToken` 明确不做；AppKey／AppId 切换、踢设备、设备列表、日志压缩及运行设置等本轮不设独立用例，优先登录基础链路 |
| ChatManager | 36 | `getUnreadMessageCount`、`clearAllConversationUnreadMessageCount` 明确不做；重发、回执、撤回、远端历史与搜索、附件、Reaction、置顶、翻译、语音转文字及全局删除等本轮不设独立用例 |
| Conversation | 4 | `loadPinnedMessages`、`remindType` 需要对应状态；两种 `deleteLocalAndServerMessages*` 涉及远端历史 |
| Contact | 5 | 好友邀请、接受／拒绝邀请、其他平台身份查询及备注暂缓；本轮优先联系人查询／删除和黑名单增删 |
| Group | 49 | 群名／描述等属性、成员管理、权限及共享文件等暂缓；本轮优先创建、远端／本地查询和销毁，成员准备及核验仍须完成 |
| Room | 30 | 明确不做 Room 模块用例 |
| Thread | 12 | 明确不做 Thread 模块用例 |
| UserInfo | 3 | `subscribeUsersInfo`、`unsubscribeUsersInfo`、`fetchSubscribedUsers` 属于用户资料订阅场景，本轮先核实基础资料读写 |
| Push | 17 | 明确不做 Push 模块用例 |
| Message | 3 | `pinInfo`、`reactionList`、`chatThread` 需对应业务状态；消息本体持久化已由会话和消息管理操作验证 |
| **合计** | **178** | |

## 6. 开发时的必要衔接

- `no_login_presence_test.dart` 保留为未登录用例主入口，`single_account_local_test.dart` 保留为单账号登录用例主入口。
- 先补充并验证正向用例，完成后再新增逆向用例；现有逆向用例继续回归。正向阶段须在 Android、iOS 各完整执行两轮，选定正向及既有回归用例通过，准备和清理无未处理故障。
- 用例实现按客户端、消息、会话、Presence、联系人、群组模块组织；必要时拆分文件，由对应主入口注册执行。
- 正向、逆向用例均按[规格 §4](../../spec/2026-11-07-ci-basic-api-tests-spec.md#4-用例设计方法)设计：合法输入验证业务结果，受控非法输入或业务前置条件不满足时验证规定行为；意外断网等执行故障不能计作逆向通过。
- 沿用已有登录凭据准备、冷安装和 Android／iOS 串行执行；每次只有一个登录执行端，允许准备其他账号作为收件人、好友或群成员。同一登录账号不能同时被其他任务使用。
- 两个设备 workflow 及 `tool/ci/smoke_local.sh`、`nightly_local.sh` 继续使用这两个入口路径；按实际执行编号核对选定清单，不能仅凭映射检查通过认定模块已执行。
- 保留已有 `FL-*` 编号，同步 [用例映射](../../../im_flutter_sdk/docs/ci/native-case-mapping.json)。该映射仍有 `EM*` 别名，核对时对应当前 `Chat*` API；本次未修改。
- 测试失败先复现并核对证据：设计问题修用例，数据问题修准备，设备或网络问题修环境；疑似 SDK 缺陷提交用户确认，不因 SDK 或环境问题改变正确设计、放宽断言或跳过检查。
- 按规格的资源回收范围执行清理：消息、会话不要求全局销毁，本轮创建的群及修改的关系须清理或恢复并核验。业务断言通过但应执行的清理失败时，分别记录结果且整轮失败；准备、验证或清理失败均使 CI 返回非零并自动结束，人工确认在排查阶段进行。每轮日志独立保留，复验不覆盖原记录，卸载 App 不替代清理核验。

已确认范围见 §3，剩余 5 个方法按 §4 核实后再确认。用例数量以正向、逆向的独立断言目标拆分后为准，不按方法数预设数量；实现与验证结果见[正向验证记录](2026-11-07-positive-verification.md)。
