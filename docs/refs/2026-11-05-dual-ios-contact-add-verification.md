# 双 iOS 联系人用例：验证过程与排查记录

日期：2026-11-05。对象：`5.0.0` 工作树中的 `contact-add-positive.yaml`。

**结论：三轮原样运行分别为 9 passed / 1 failed、5 passed / 2 timeout、10 passed。存在通过记录，但重复执行稳定性和事件归属未通过验证。尚未确认 SDK 缺陷。** 本次未修改用例、断言或业务代码。

本文记录实际执行过程及可复用的排查方法；总体操作入口见 [双端测试 Runbook](2026-11-05-dual-device-e2e-testing-runbook.md)。后文明确区分观察事实、推断和未实施的建议。


> 后续进展：[事件归属与延后投递深入排查](2026-11-05-contact-flow-instability-investigation.md) 已通过原生消息 ID/生成时间确认第一、三轮使用历史通知，并用真实解释器完成定向复现；本文保留最初三轮验证时的观察与判断。

## 1. 环境与用例

所有命令均从工作树根目录执行：

```bash
cd /Users/asterisk/Codes/zuoyu_flutter/im_flutter_sdk/.worktree/5.0.0
```

| 角色 | 模拟器 | 系统 | UDID | 测试账号 |
|---|---|---|---|---|
| alice | iPhone 16 | iOS 18.1 | 5AEB6771-C566-4E06-BA98-A5230C0AA1C2 | zuoyu01 |
| bob | iPhone 16 | iOS 18.2 | 14BDE43F-F2E8-4755-A81D-2EDD72D525C0 | zuoyu02 |

- 用例：[contact-add-positive.yaml](../../testing/flows/contact-add-positive.yaml)。命令库为同目录 `scripts/contact_add_alice.json`、`scripts/contact_add_bob.json`。
- REST 前置将双方关系重置为非好友；Alice 发邀请，Bob 收到 `onContactInvited` 后接受，Alice 等待 `onFriendRequestAccepted`，最后断言双方本地好友列表包含对方。
- 两端先完成 `init`、`login`，在 `barrier: both-online` 汇合。此屏障实际等待的是命令完成，不额外等待登录后的数据同步完成。
- 使用当时含未提交修改的工作树构建，不能只凭分支名或 HEAD 精确复原该构建。首轮走构建安装入口，后两轮复用同一个 `Runner.app`。
- 三轮均未增加延时、放宽断言、跳过失败或更换测试账号；本次只验证 iOS 模拟器，未验证 iOS 真机。

## 2. 实际执行步骤

### 2.1 检查设备与执行权限

```bash
xcrun simctl list devices available
```

最初在受限沙箱内执行时，出现 `CoreSimulatorService connection became invalid`、日志文件 `Operation not permitted`、`Connection refused`。在获得执行权限后，同一命令成功列出模拟器，选取已启动的两台设备。

**排查要点：先区分权限限制与模拟器自身故障。** 此处没有通过重装 Xcode、删除模拟器或清理缓存解决；也不能根据该报错断言 CoreSimulator 已损坏。本次授权执行的构建安装脚本成功，不支持“所有 AI 环境都无法构建 iOS”的绝对结论。

### 2.2 准备账号数据

```bash
bash testing/scripts/prepare_data --run-id contact-ios-20261105-1918
```

本次复用两个已有账号，输出两条 `token ok`，生成忽略文件 `im_flutter_sdk/example/lib/env.dart` 及 `testing/tmp/contact-ios-20261105-1918/main/environment.json`。未创建测试群。

### 2.3 构建、安装、启动与角色绑定

```bash
bash testing/scripts/setup_devices \
  --platform ios \
  --devices 5AEB6771-C566-4E06-BA98-A5230C0AA1C2,14BDE43F-F2E8-4755-A81D-2EDD72D525C0 \
  --roles alice,bob --mode control \
  --run-id contact-ios-20261105-1918 \
  > testing/tmp/contact-ios-20261105-1918/setup.log 2>&1
```

脚本内部以 `flutter build ios --simulator --debug --dart-define=API_CONTROL=true` 构建，再安装到两台模拟器并启动。产物为 `im_flutter_sdk/example/build/ios/iphonesimulator/Runner.app`。

`agents.json` 含角色、设备、随机 HTTP 端点、控制凭据、实例 ID、账号环境和日志路径。角色按 `--roles` 和设备顺序对应，账号按环境文件顺序绑定。检查映射即可，不要将整个文件输出到共享报告。

注意：当时 `setup_devices` 用命令替换及 `tail -1` 接收构建输出，外层 `setup.log` 可能长时间只有设备信息。可以查看构建进程判断进展；无日志刷新不等于卡死，也不要因此重复启动构建。

### 2.4 执行指定用例

```bash
bash testing/scripts/run_flow \
  --flow contact-add-positive.yaml \
  --run-id contact-ios-20261105-1918 \
  > testing/tmp/contact-ios-20261105-1918/run.log 2>&1
```

脚本先执行 REST 前置，再注入 `agents.json` 调用 flow_runner。三轮前置均成功。第一、二轮退出码为 1，第三轮为 0。

**报告目录有两个 ID，不能混淆：** `--run-id` 选择设备环境及前置报告目录；当前 YAML 未指定 `runId`，flow_runner 会另外生成 `flow-时间戳` 目录。以 `run.log` 中 `report written to ...` 为准，不要用“最新目录”猜测，尤其存在其他并行测试时。

### 2.5 独立复验

第二轮运行目录为 `contact-ios-20261105-1922`，第三轮为 `contact-ios-20261105-r3`。这些是目录标识，不是精确执行时间。

每轮都新建 `main/` 目录，复制首轮仍有效的 `environment.json`，然后重新执行 setup，使用：

```bash
# 将 ios_rerun 替换为本轮唯一标识；以下是复验命令模板。
ios_rerun=contact-ios-rerun
mkdir -p "testing/tmp/$ios_rerun/main"
cp testing/tmp/contact-ios-20261105-1918/main/environment.json \
  "testing/tmp/$ios_rerun/main/environment.json"
bash testing/scripts/setup_devices \
  --platform ios \
  --devices 5AEB6771-C566-4E06-BA98-A5230C0AA1C2,14BDE43F-F2E8-4755-A81D-2EDD72D525C0 \
  --roles alice,bob --mode control --run-id "$ios_rerun" \
  --prebuilt "ios=$PWD/im_flutter_sdk/example/build/ios/iphonesimulator/Runner.app"
bash testing/scripts/run_flow --flow contact-add-positive.yaml --run-id "$ios_rerun"
```

跨日或 Token 失效时应重新 `prepare_data`，不要继续复制旧环境。本次 `--prebuilt` 在两次复验中均成功。重启 App 会得到新凭据和新事件缓冲，但**不会清空服务端历史通知或本地 SDK 数据库**。flow 结束会调用 `finish`，不能直接在同一已结束实例上重跑业务命令。

## 3. 三轮证据与判断

`seq` 仅在同一 App 实例内有序；不能比较 Alice 的 seq 与 Bob 的 seq 来建立跨设备先后关系。

### 第一轮：好友列表断言失败，存在历史事件干扰

报告：`testing/reports/flow-2026-11-05T19-19-41-297497/flow-report.json`。

报告显示初始化、登录、邀请、接受和两个等待步骤通过；Alice 查询结果为 `[]`，未包含 `zuoyu02`；Bob 查询包含 `zuoyu01`。

Alice HTTP 事件流的关键顺序：

| seq | 观察 |
|---|---|
| 20 | 接受本轮 addContact 命令 |
| 21 | onFriendRequestAccepted，报告匹配了这一条 |
| 22–34 | 多次添加、删除、接受通知；seq=28 的邀请 reason 为 `reverse probe`，不是本用例文本 |
| 35–36 | addContact 成功返回、命令结束 |
| 37–39 | getAllContactIds 执行，seq=38 返回空列表 |
| 40–41 | 再次收到 onFriendRequestAccepted、onContactAdded |

**已确认：** 本轮事件流含本用例未发起的操作通知，仅按用户 ID 匹配不能证明 seq=21 属于本轮邀请。

**推断：** 历史操作通知使流程提前通过等待并查询，能解释本轮失败。seq=40/41 更可能与本次接受有关，但没有业务关联 ID，尚不能精确归因。不能据此认定 iOS SDK 接受好友后不更新本地数据库。

### 第二轮：邀请通知超时

报告：`testing/reports/flow-2026-11-05T19-21-22-378236/flow-report.json`。

- 两端初始化和登录成功；Alice addContact 成功。
- Bob 等待 `onContactInvited` 20 秒超时，Alice 等待 `onFriendRequestAccepted` 也超时。
- 后续接受及好友查询步骤未执行，报告仅 7 条叶子记录；`skipped: 0` 不代表所有步骤均已执行。
- 事件快照显示两端均有 `onConnected` 和数据同步事件，并收到联系人删除通知。
- 随后只读查询服务端：

```bash
dart run testing/tools/data/contact_state_probe.dart zuoyu01 zuoyu02
```

双方 contacts 均为 `[]`。这支持结束时双方非好友，但**不证明没有待处理邀请或历史事件**。

**未定位：** 邀请未在窗口内送达的具体原因。没有完成本轮原生 SDK 收包到 Dart 回调的逐层对账，不能认定是服务端未推送、原生漏回调或监听门闩问题。Alice 接受通知超时是 Bob 未接受的下游结果，不应算作另一个已证实 SDK 缺陷。

### 第三轮：报告全绿，但通知归属仍不明确

报告：`testing/reports/flow-2026-11-05T19-23-12-282728/flow-report.json`。

10 条记录全部通过，双方本地好友列表均包含对方。但 Bob 事件流显示：

| seq | 观察 |
|---|---|
| 9 | login 命令结束 |
| 10–12 | onConnected、数据同步开始、离线消息同步开始 |
| 15 | onContactInvited，报告匹配此条 |
| 16 | 接受 acceptInvitation 命令 |
| 17 | onOfflineMessageSyncFinish |
| 19 | 又一条相同 userId、相同 reason 的 onContactInvited |
| 20、23 | onContactAdded、acceptInvitation 成功 |
| 27 | getAllContactIds 返回包含 zuoyu01 的列表 |

Alice 匹配接受通知 seq=21，seq=26 查询包含 `zuoyu02`。

**已确认：** 本轮最终关系正确；Bob 有两条相同邀请，且第一条在登录后的同步期间到达。

**待查：** 两条是历史邀请补发、本轮重复通知，还是其他来源。现有匹配字段无法区分。因此既不能把这次通过当作前三轮失败已解决，也不能仅凭此证明“离线邀请一定补推”。

## 4. 如何取证，避免误判

1. 先看 `flow-report.json` 的具体步骤与 `result`，区分 SDK 返回失败、业务断言失败和等待超时。第一轮 `success: true`、`expectMatched: false`，不是 API 调用报错。
2. 在重启 App 前取 `/v1/events`。报告只保留匹配事件和步骤结果，不包含全部前后文。当前实现 finish 后仍可读取事件；本次即如此取证，业务命令则已关闭。
3. iOS 日志用 `simctl spawn <udid> log stream --predicate 'process == "Runner"'`，不能依靠 App stdout。本次首轮 Alice 的采集文件停在启动阶段，但 HTTP 缓冲中有完整流程事件；日志文件没有某条事件，不等于 SDK 未回调。
4. 分别建立每台设备的命令生命周期、回调、查询结果顺序；结合时间戳及业务关联信息判断跨设备因果。
5. 检查 REST 状态，并明确它只证明关系状态，不证明本地缓存、推送队列或登录同步已清空。

以下为读取当前实例事件的取证模板，凭据只从本地文件读取：

```bash
python3 - <<'PY'
import json
from pathlib import Path
from urllib.request import Request, ProxyHandler, build_opener

root = Path('testing/tmp/contact-ios-20261105-r3')  # 改为当前运行目录
opener = build_opener(ProxyHandler({}))  # 本机端点不走代理
for agent in json.loads((root / 'agents.json').read_text()):
    cursor, events = 0, []
    while True:
        req = Request(
            agent['endpoint'] + f'/v1/events?afterSeq={cursor}&limit=200&waitMs=0',
            headers={'Authorization': 'Bearer ' + agent['token']})
        with opener.open(req, timeout=5) as response:
            page = json.load(response)
        batch = page['events']
        events.extend(batch)
        if not batch or len(batch) < 200:
            break
        cursor = batch[-1]['seq']
    (root / (agent['role'] + '-events-export.json')).write_text(
        json.dumps(events, indent=2))
PY
```

本次每台均不足 200 条，使用单页快照足够；模板支持分页，但仍是读取时点的快照，不保证包含以后才到达的事件。遇到 `410 evidence_gap` 应记录证据缺口，不能忽略。取证文件可能含登录参数等敏感数据，只存 Git 忽略的临时目录；共享文档只保留经过筛选的证据。本次 App 已终止，上述旧端点不能继续使用。

## 5. 后续排查顺序与边界

以下为建议，**本次未实施**：

1. 先确认是否有其他设备或任务使用相同账号，记录在线设备；本次 Presence 事件中还出现另一 Android 在线端，但未证实它参与了联系人操作。不要将外部干预当成既定根因，也不要擅自退出其他会话。
2. 研究账号历史通知及同步完成的可靠隔离方式。当前 `_initEventCursors()` 在业务步骤前取末尾游标，只能排除已经进入 App 缓冲的旧事件；登录后补到的通知仍会被匹配。新进程、新 runId、REST 删除关系都不能独自解决这一点。
3. 对可携带标识的邀请 reason 考虑使用本轮唯一值并匹配，以便取证；接受通知只有 userId，不能假设同样可以关联，仍需独立处理隔离问题。改变用例前先确认 SDK 契约和方案。
4. 第二轮应继续对照服务端、原生 SDK、Flutter 监听、agent 缓冲四层证据，定位事件停在哪里；仅有 HTTP 命令成功不足以证明对端已收推送。
5. 建立隔离条件后保留原有业务断言，复验首轮空列表和第二轮通知超时。不得因 SDK 缺陷削弱正确测试，也不得通过固定 sleep 或不断重跑直到绿来宣称修复。

原用例注释和早期 Runbook 中“REST 重置不产生 SDK 事件”“离线邀请不补推”不能作为本次排查的绝对前提：本次重置后观察到删除通知，登录同步期间观察到邀请；其精确来源仍需额外证据。

## 6. 产物与收尾

归档根目录：`testing/reports/contact-ios-verification-20261105/`（Git 忽略）。

- `summary.md`：本次概要。
- `round-1/`、`round-2/`、`round-3/`：原 flow 报告、前置报告、无凭据设备映射、筛选后的联系人事件及命令生命周期。
- 原始运行目录：`testing/tmp/contact-ios-20261105-1918/`、`testing/tmp/contact-ios-20261105-1922/`、`testing/tmp/contact-ios-20261105-r3/`，保留环境、凭据、运行输出和事件快照。

结束时两台测试 App 均成功 terminate，模拟器和安装产物保留；未重置最终好友关系，第三轮留下的好友关系由下一次用例前置处理。尝试按本次 `.log.pid` 核对并停止日志采集进程，没有匹配到可终止项，因此不声称已逐一确认所有采集子进程退出。临时证据未删除，未提交代码。

本文件保留了主要证据事实，即使本机忽略目录后来被删除，也能作为排查入口；重新复现时需生成新的凭据、设备映射和运行证据。
