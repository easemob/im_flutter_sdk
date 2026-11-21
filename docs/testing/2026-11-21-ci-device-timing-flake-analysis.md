# ci-device 时序类失败详细记录：联系人同步 / 消息下行投递

- 日期：2026-11-21
- 状态：已定位（服务端同步/投递链路时序，环境侧 D 级）；待 rerun 复验闭环
- 适用范围：ci-device 四 lane（ci.yml 不受影响）；5.1.0 / 4.25.0 / flutter2_stable 三个分支均观察到
- 关联：差异登记表 D5/D6（`2026-11-20-migration-issue-register.md`）；本文是 D6 同类问题的扩展立案，证据达可提交工单标准

## 结论速览

ci-device 存在两类**结果不稳定**的失败，根因均指向**服务端同步/投递链路时序抖动**，与代码、测试用例、SDK 版本、账号无关：

- **问题 A：登录后 roster 同步不落地**——FL-CONTACT-001 / FL-CONTACT-011
- **问题 B：REST 真实消息的下行投递不落地**——FL-CONV-016 / FL-MSG-010（同基类还有 FL-CONV-002、FL-AUTH-003、FL-ROOM-001）

核心证据：三个不同 native 版本的 SDK（5.1.0 = native 5.x；4.25.0 与 flutter2_stable 为同一 commit、SDK 零 diff）+ 不同的用例代码（5.1.0 为迁移源头，与 4.25.0 用例相互独立）出现**完全相同的失败模式**，且失败用例集合每次 run 轮换、同一 run 内反向平台通过。共享变量只有账号池与服务端。

确定性失败（不在本文范围，勿混淆）：FL-MSG-006/007（native bug HIM-24173）、FL-GROUP-014（native bug HIM-24170），签名稳定、双平台一致复现，已另行登记。

## 证据基础

### 代码同一性

```bash
# 4.25.0 分支 HEAD(3d4ff77c) 与 stable 合并点(6c4ddecc) SDK 零 diff
git diff 3d4ff77c 6c4ddecc -- im_flutter_sdk/lib im_flutter_sdk_android im_flutter_sdk_ios
# 输出为空
```

integration_test 整树在合并时取自 4.25.0（冲突解决记录见合并提交 6c4ddecc），故 stable 与 4.25.0 分支测试代码亦相同。

### 账号隔离（排除 lane 互踢）

ci-device.yml 约定：logged-in lane 账号派生自 `E2E_USER_SUFFIX`（`_flutter_android` / `_flutter_ios` 各自独立），peer 为 `<effective id>_ci_peer`；logged-out smoke 用独立账号 `flutter-ci-peer`。四 lane 账号无交集；`concurrency: flutter-ci-device-${{ github.ref }}` + 时刻表核对，事发时段本仓库无第二个在跑 run。

### 涉及 run / job 清单（复验入口）

| run | 触发 | 分支 | 开始（UTC） | 相关 job |
|---|---|---|---|---|
| 44684282021 ~ 44714741201 | dispatch | 5.1.0 | 11-20 05:55 ~ 09:55 | 见下表 |
| 44723629285 | dispatch | 4.25.0 | 11-20 10:58 | Android logged-in 136245430655 |
| 44729802560 | dispatch | 4.25.0 | 11-20 11:42 | Android logged-in 136281732762（D6；attempt 2 为 rerun 通过） |
| 44746230976 | dispatch | flutter2_stable | 11-20 13:39 | Android logged-in 136322156441；iOS logged-in 136322156575 |
| 44794920641 | **schedule（stable 合并后首轮 cron）** | flutter2_stable | 11-20 18:40 | Android logged-in 136491855483；iOS logged-in 136491855453 |

拉取原始日志（日志在 GitHub 保留 90 天）：

```bash
gh run view --repo easemob/im_flutter_sdk --job <job_id> --log
# D6 的 rerun 通过日志：job 136281732762（run_attempt=2；attempt 1 日志 API 不可拉，细节以登记表 D6 为准）
```

## 问题 A：登录后 roster 同步时序（FL-CONTACT-001 / FL-CONTACT-011）

### 探测机制

`integration_test/modules/contact_cases.dart`：

- `reloadRelation`（contact_cases.dart:38-47）：REST 变更好友关系 → `logout(false)` → `loginForCi` 重登 → 调 `observeContact`
- `observeContact`（contact_cases.dart:16-36）：轮询 `contactManager.getAllContactIds()` + `getAllContacts()`（均为读本地库），最多 30s，直到两路都含/都不含 peer

4.25.0 的 `getAllContactIds/getAllContacts` 读的是**本地库**，本地库在登录时由**服务端 roster 同步推送**填充。推送在观察窗内没到达 → 列表恒空 → 超时。这是「登录同步时序」探测器，不是业务逻辑断言。

### 失败签名（原始日志摘录）

稳定签名：`CI contacts observe: ids=[] records=[]` 之后 30s 内无第二次观察（waitForCi 仅在观察值变化时打印），超时行 `last observation: [false, false]`。

stable cron 首轮 run 44794920641：

- Android（job 136491855483）
  - 18:49:59Z FL-CONTACT-001：`TimeoutException after 0:00:30.000000: SDK contact lists contain ***_flutter_android_ci_peer = true; last observation: [false, false]`
  - 18:50:41Z FL-CONTACT-011：同签名
- iOS（job 136491855453）
  - 19:08:37Z FL-CONTACT-011：`... contain ***_flutter_ios_ci_peer = true; last observation: [false, false]`（注：iOS 日志 debugPrint 成块缓冲，时刻戳以整段落为准）

stable dispatch run 44746230976：

- Android（job 136322156441）13:51:46Z FL-CONTACT-001、13:52:32Z FL-CONTACT-011：同签名；iOS 同 run 两用例通过

4.25.0 分支（登记表 D6，run 44729802560 Android job 136281732762 attempt 1）：FL-CONTACT-001/011 + FL-ROOM-001 同轮失败，rerun（attempt 2）全过。

### 通过对照（同代码）

- 4.25.0 run 44729802560 Android rerun attempt（12:24:22Z）：好友关系重登后**首次观察**即 `ids=[***_flutter_android_ci_peer] records=[***_flutter_android_ci_peer]`，contact suite 6/6 通过
- stable cron 首轮 iOS 同 run 的 FL-CONTACT-001 通过：第一次观察为空、紧接着第二次观察 `ids=[***_flutter_ios_ci_peer]`——正常时序下同步毫秒~秒级到达

### 出现历史汇总

| run | 分支 | 平台 | FL-CONTACT-001 | FL-CONTACT-011 |
|---|---|---|---|---|
| 44729802560 attempt 1 | 4.25.0 | Android | ❌ | ❌ |
| 44729802560 attempt 2（rerun） | 4.25.0 | Android | ✅ | ✅ |
| 44746230976 | stable | Android | ❌ | ❌ |
| 44746230976 | stable | iOS | ✅ | ✅ |
| 44794920641 | stable | Android | ❌ | ❌ |
| 44794920641 | stable | iOS | ✅ | ❌ |

6 个样本中 4 个失败、2 个全过；失败集中在 Android（4/6），iOS 仅 011 失败 1 次。代码完全相同。

## 问题 B：REST 真实消息下行投递时序（FL-CONV-016 / FL-MSG-010）

### 探测机制

- FL-CONV-016（conversation_cases.dart:534-589）：REST 以 peer 身份给当前账号发 2 条单聊消息 → 轮询 `getConversation(peerId, createIfNeed: false)` 的 `unreadCount()` 直到等于 2（30s）。会话对象由消息到达时创建；消息没到 → 会话恒 null → 观察值恒 -1
- FL-MSG-010（message_cases.dart:560-588）：REST 以 peer 身份给测试群发 1 条文本 → `ChatEventHandler.onMessagesReceived` 的 Completer 等待在线投递（30s，message_cases.dart:588 `received.future.timeout`）

两个用例探测同一链路：**服务端 → 设备长连接的下行消息推送**。REST 发送均返回成功（消息已落服务端），失败时设备端 30s 内完全未收到。

### 失败签名（原始日志摘录）

- stable cron 首轮 Android（job 136491855483）18:44:48Z FL-CONV-016：
  `TimeoutException after 0:00:30.000000: conversation ***_flutter_android_ci_peer unread reaches 2; last observation: -1`
- stable cron 首轮 iOS（job 136491855453）18:58:12Z FL-MSG-010：
  `TimeoutException after 0:00:30.000000: Future not completed`，栈顶 `registerMessageCases.<anonymous closure> (message_cases.dart:588)`
- 5.1.0 run 44705911061（native 5.x、用例代码独立）：
  - Android（job 136185350292）08:56:07Z FL-CONV-016 ❌
  - iOS（job 136185349860）09:07:50Z FL-CONV-016 ❌
- 5.1.0 run 44714741201 Android（job 136215133961）：FL-AUTH-003（登出/重登时序）❌——同基类
- 4.25.0 run 44723629285 Android（job 136245430655）11:03:31Z FL-CONV-002（本地插入/读回时序）❌——同基类

### 通过对照（同代码同账号池）

- stable cron 首轮：iOS FL-CONV-016 ✅（同 run 反向平台）；Android FL-MSG-010 ✅
- stable dispatch 44746230976：Android FL-CONV-016 ✅、iOS FL-MSG-010 ✅
- 同 suite 内 FL-MSG-001（app 主动发消息 + 收 final server callback）在失败 run 中双平台均 ✅——连接本身可用，丢的是**下行推送方向**

### 出现历史汇总

| run | 分支/平台 | 时序类失败 |
|---|---|---|
| 44705911061 | 5.1.0 Android / iOS | FL-CONV-016（双平台） |
| 44714741201 | 5.1.0 Android | FL-AUTH-003 |
| 44723629285 | 4.25.0 Android | FL-CONV-002 |
| 44729802560 | 4.25.0 Android | FL-ROOM-001（attempt 1，rerun 过） |
| 44746230976 | stable Android | FL-ROOM-001 |
| 44794920641 | stable Android / iOS | FL-CONV-016（A）/ FL-MSG-010（i） |

失败组合每次轮换、从不重复，叠加在恒定的 2 个 native bug（MSG-007/GROUP-014）之上。

## 排除项（均已验证）

1. **代码/SDK 差异**：4.25.0 与 stable 同一 commit 树、SDK 零 diff（见上 git diff）；5.1.0 与 4.25.0 是两套独立 SDK + 独立用例代码，却出现相同模式
2. **账号互踢**：四 lane 账号隔离；事发窗口本仓库无并发 run（concurrency group + 时刻表核对）
3. **`convertIntToChatMultiDevicesEvent: unsupported value: 34` 噪音**：曾疑为排查锚点，**已证伪**——Android 通过 run（44729802560 rerun、44746230976）该错误为 0，但 44746230976 联系人失败；iOS 通过 run（44746230976）有 22 条该错误。与失败无稳定关联，属 4.25.0 多端枚举缺口（T1-13）的预期兜底日志（T1-16）
4. **用例断言错误**：排除——通过 run 中同步/投递毫秒级到达，30s 窗口在非抖动窗口充足；失败 run 中是真 30s 无数据

## 复验方法

```bash
# 1. 拉原始日志
gh run view --repo easemob/im_flutter_sdk --job <job_id> --log
# 2. rerun 失败 lane（D6 先例：rerun 即过，证明瞬态）
gh run rerun <run_id> --failed
# 3. 每天 18:37 UTC cron 自动跑（stable）；5.1.0/4.25.0 用 workflow_dispatch
gh workflow run ci-device.yml --repo easemob/im_flutter_sdk --ref <branch>
```

判定规则（建议）：

-  rerun 即过 / 失败组合继续轮换 → 维持 D 级环境项，本文持续补充样本
- **同一用例在相同代码上连续 3 次失败** → 升级为待裁决项，按 C 级流程用户裁决（改用例 or SDK）

## 工单草稿

> **标题**：IM CI 服务端同步/投递链路时序抖动：登录 roster 同步与下行消息推送偶发 30s+ 不落地（影响 Flutter SDK 5.1.0 / 4.25.0 两个 native 版本）
>
> **现象**（2026-11-20，6 个 ci-device run 样本）：
> 1. 账号 REST 变更好友关系后重新登录，roster 同步推送 30s 内未落到设备本地库，`getAllContactIds/getAllContacts` 恒空（Flutter 用例 FL-CONTACT-001/011 探测；4/6 样本失败，Android 居多）
> 2. REST 以好友身份向在线设备发消息（单聊/群聊均现），设备长连接 30s 内未收到下行推送，在线监听与离线补拉均未触发（Flutter 用例 FL-CONV-016/FL-MSG-010 探测；5.1.0 双平台、stable Android/iOS 均现）
>
> **排除**：三个分支代码/用例/SDK 差异（5.1.0 与 4.25.0 相互独立，4.25.0 与 stable 零 diff）、账号互踢（四 lane 账号隔离、无并发 run）、用例断言（通过样本毫秒级到达）
>
> **影响**：设备集成测试假阴性，失败组合随机轮换（CONV-002/016、MSG-010、AUTH-003、ROOM-001、CONTACT-001/011），每次 rerun 损失 30+ 分钟且掩盖真实 native bug 信号
>
> **复现**：easemob/im_flutter_sdk ci-device workflow（日志保留 90 天，样本 run/job 清单见仓库 `docs/testing/2026-11-21-ci-device-timing-flake-analysis.md`）；rerun 通常即过
>
> **诉求**：服务端排查 11-20 全天下行推送/登录同步链路的延迟与丢失（重点窗口 08:50–09:10、13:39–13:53、18:40–19:09 UTC），确认是否存在队列积压或连接级丢消息
