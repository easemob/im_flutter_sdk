# 双端（多设备）E2E 测试验证全流程 Runbook

高频故障排查入口：[多设备协同测试调试与排查手册](2026-11-05-multi-device-test-troubleshooting.md)。本文保留运行步骤与早期实验背景；分类定位方法及证据边界以排查手册和后续专项记录为准。

> 日期：2026-11-05 ｜ 分支：`.worktree/5.0.0` ｜ 状态：Android×2 已全绿（10 passed / 0 failed / 0 timeout），iOS×2 进行中，mixed 待做
>
> 目的：完整记录多设备测试体系从零到跑通的全过程。后续的人或 AI 卡住时，先读本文档的"常见卡点决策树"和"踩坑大全"，再按"标准操作流程"执行。

> 双 iOS 后续记录：[三轮验证与排查细节](2026-11-05-dual-ios-contact-add-verification.md)。结果分别为 9 passed / 1 failed、5 passed / 2 timeout、10 passed，尚未稳定验收。该记录更正本文早期结论的适用范围：本次授权执行的 iOS 构建成功、`--prebuilt` 已实测；REST 重置与离线邀请不能据早期实验一概认定无回调。finish 后业务命令关闭，但当前 HTTP 事件仍可读取。

---

## 1. 体系架构（一图流）

```
prepare_data ──→ setup_devices ──→ run_flow ──→ flow-report.json
（REST 创建账号）  （构建+安装+启动     （flow_runner 编排    （每步 status/reason/result）
                   agent，捕获凭据，    parallel/barrier/
                   生成 agents.json）   wait_event/expect）

设备 app（example, API_CONTROL=true 模式）
  └─ ControlServer（绑 127.0.0.1:0 随机端口）
      ├─ /v1/info          存活探测
      ├─ /v1/commands      提交 SDK 命令（commandId/api/params/timeoutMs）
      ├─ /v1/commands/<id> 轮询结果（done/error/timeout）
      └─ /v1/events        事件缓存轮询（afterSeq/limit/waitMs，seq 单调递增）
```

三层 fixture 边界（重要设计决策，勿混淆）：

| 层 | 归属 | 通道 | 举例 |
|---|---|---|---|
| 存在 | `prepare_data`（数据准备） | REST | 创建账号 zuoyu01/zuoyu02、临时群 |
| 状态 | 用例前置 `preconditions`（YAML 声明 + REST 执行） | REST | 好友关系重置为 none |
| 变化 | 被测步骤本身 | SDK（设备上的 app） | addContact / acceptInvitation |

理由：复杂用例中好友/群成员关系是**变化的**（一会儿是好友一会儿不是），所以关系重置必须放用例前置，每次用例执行前恢复到声明的状态。preconditions 失败报告为 **blocked（≠ failed）**，产出独立报告文件。

---

## 2. 标准操作流程（复制即用）

### 2.0 环境前提

- bash ≥ 3.2（macOS 自带即满足；**勿用 sh/zsh 直接执行**，脚本头部有 `_compat.sh` 运行时守卫）
- Flutter 可用；Android 模拟器已启动（`adb devices` 可见）
- iOS 构建须在**用户终端**执行（见 §4.J 沙箱限制）
- 所有命令在 worktree 根目录执行：`cd /path/to/.worktree/5.0.0`

### 2.1 数据准备（REST 创建账号）

```bash
bash testing/scripts/prepare_data --run-id <run-id>          # 例：devtest-3-ios
# 可选 --groups <n> 额外建临时群
```

产物：`testing/tmp/<run-id>/main/environment.json`（含 User Token，不含 clientSecret）。
账号命名 zuoyu01、zuoyu02…（已存在的账号会复用并刷新 token）。

### 2.2 启动设备

```bash
# iOS：查可用设备 → 启动两台
xcrun simctl list devices available | grep iPhone
xcrun simctl boot <udid-1>
xcrun simctl boot <udid-2>

# Android：列出 AVD → 启动第二台（第一台 5554 通常已在跑）
emulator -list-avds
"$HOME/Library/Android/sdk/emulator/emulator" -avd <avd-name> -no-snapshot-load -netdelay none -netspeed full &
adb wait-for-device && adb shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 2; done; echo BOOTED'
```

注意：`adb wait-for-device` 只等 USB 连接不等开机完成，必须轮询 `sys.boot_completed=1`。
同一 AVD 不能起两个实例（会 exit 1），第二台要选不同 AVD。

### 2.3 构建

**Android（可全自动）：**

```bash
cd im_flutter_sdk/example
flutter build apk --debug --dart-define=API_CONTROL=true
# 产物 build/app/outputs/flutter-apk/app-debug.apk
```

**iOS（必须在用户终端）：**

```bash
cd im_flutter_sdk/example
flutter build ios --simulator --debug --dart-define=API_CONTROL=true
# 产物 build/ios/iphonesimulator/Runner.app
```

AI/CI 沙箱环境跑 iOS 构建必死在 `sandbox-exec: sandbox_apply: Operation not permitted`（flutter tool 用 sandbox-exec 包装 xcodebuild 的 SPM 包解析），此为宿主级 Seatbelt 限制，无法绕过。对策：外部构建完成后，用 `setup_devices --prebuilt`（**已实现、尚未实测**，2026-11-05 中断待验证；不可用时退回手动路径）：

```bash
bash testing/scripts/setup_devices --platform ios \
  --devices <udid-1>,<udid-2> --mode control --run-id <run-id> --roles alice,bob \
  --prebuilt ios="$PWD/im_flutter_sdk/example/build/ios/iphonesimulator/Runner.app"
```

手动兜底路径（`--prebuilt` 不可用时）：

```bash
testing/scripts/device/ios/install --device <udid> --mode control --app <Runner.app 路径>   # --app 跳过构建
testing/scripts/device/ios/launch --device <udid> --mode control --out <log>               # 拿 OK port=.. token=..
# 再手工拼 agents.json（结构见 §3.1）
```

### 2.4 设备准备（安装 + 启动 agent + 角色绑定）

```bash
bash testing/scripts/setup_devices --platform android \
  --devices emulator-5554,emulator-5556 --mode control --run-id <run-id> --roles alice,bob

# mixed 组合：--platform mixed --devices ios:<udid>,android:<serial>
```

要点：

- `--roles` 数量必须等于设备数；缺省 agent-1..N。角色名写入 agents.json，flow YAML 按它引用
- 设备序号 ↔ 账号序号绑定：设备 i 绑 `environment.json` 的 `accounts[i]`（alice=zuoyu01, bob=zuoyu02）
- 每平台只构建一次，后续设备 `--app` 复用产物
- 重跑 setup_devices 会自动 terminate/force-stop 残留实例再启动（对已运行实例 launch 拿不到新凭据且无报错——这是脚本内部处理好的，手动 launch 时要注意）
- **flow 跑完后 ControlServer 会关闭**（finish 即关），重跑 flow 前必须重新执行 setup_devices 拿新凭据

产物：`testing/tmp/<run-id>/agents.json`，每角色日志 `testing/tmp/<run-id>/<role>.log`。

### 2.5 执行 flow

```bash
bash testing/scripts/run_flow --flow contact-add-positive.yaml --run-id <run-id>
```

run_flow 自动注入 `--agents-file testing/tmp/<run-id>/agents.json` 并在流程前跑 preconditions（REST 关系重置）。

flow_runner 直接调用（调试用）：

```bash
dart run tool/flow_runner/bin/flow_runner.dart run testing/flows/<flow>.yaml \
  --agents-file testing/tmp/<run-id>/agents.json --report-dir <dir>
```

### 2.6 读报告

```bash
ls -t testing/reports/ | head -1   # 最新报告目录
python3 -c "
import json,sys
r=json.load(open(sys.argv[1]))
print(r['summary'])
for s in r['steps']:
    print(s.get('context',''),s.get('kind'),s.get('agent') or '-',s.get('name') or s.get('source') or '','->',s.get('status'),(s.get('reason') or '')[:80])
" testing/reports/<dir>/flow-report.json
```

status 取值：`passed` / `failed` / `timeout` / `blocked`（前置未满足）/ `skipped`（abort_flow 后未执行的步骤）。

---

## 3. 体系组成详解

### 3.1 agents.json 结构

```json
[{
  "role": "alice", "platform": "android", "udid": "emulator-5554",
  "endpoint": "http://127.0.0.1:52607", "token": "<hex>", "instanceId": "<id>",
  "env": {"userId": "zuoyu01", "userToken": "<jwt>", "initConfig": {…全量 environment.json…}},
  "log": "testing/tmp/<run-id>/alice.log"
}]
```

- endpoint 恒为**宿主可达**：iOS 模拟器与宿主共享网络（端口直达）；Android 经 `adb forward tcp:0 tcp:<app端口>`（forward 输出所选宿主端口）
- `applyAgentsFile`（parser.dart）按角色名覆盖 YAML agents 声明的 endpoint/token，env **浅合并**进 `$config` 命名空间
- agents-file 里 YAML 未声明的角色仅警告不报错（多 flow 复用场景）

### 3.2 flow YAML 结构（contact-add-positive 为例）

```yaml
name: contact-add-positive
preconditions:                       # 声明式前置，REST 执行，独立报告
  - contacts: {between: [alice, bob], state: none}
agents:
  alice: {script: scripts/contact_add_alice.json}   # 设备脚本（相对 flows/ 目录）
  bob:   {script: scripts/contact_add_bob.json}
defaults: {stepTimeoutMs: 20000}
steps:
  - parallel:
      alice_line:
        - {cmd: init, agent: alice, onFail: abort_flow}
        - {cmd: login, agent: alice, onFail: abort_flow}
        - barrier: both-online       # 双线汇合点：bob 登录完成后 alice 才发邀请
        - {cmd: add_contact, agent: alice, inputs: {peerId: '$agents.bob.userId', reason: '…'}}
        - {wait_event: onFriendRequestAccepted, agent: alice, match: {userId: '$agents.bob.userId'}, as: accepted_evt}
        - {cmd: get_contact_ids, agent: alice, as: alice_ids}
      bob_line:
        - …wait_event: onContactInvited → accept_invitation → get_contact_ids…
```

- `wait_event` 是 HTTP 轮询 agent 的 `/v1/events?afterSeq=<seq>`（带 seq 游标）
- 事件 source 用**裸名**（`onContactInvited`）——agent 端 EvidenceStore 已做全限定名→裸名转换（`ChatContactEventHandler.onContactInvited` → `onContactInvited`）
- `expect` 支持 `contains` 操作符（data 数组含指定项）
- params 命名空间：`$config.*`（**按当前 agent 的 env** 解析，不会串号）、`$inputs.*`（步骤输入）、`$agents.<role>.<path>`（跨角色引用，走 env，如 `$agents.bob.userId`）

### 3.3 设备脚本 JSON

每条步骤：`{id, api, params, expect?}`。api 形如 `ChatContactManager.addContact`，params 支持 `$config` / `$inputs` / `$agents` 引用（**与 YAML inputs 是两套 resolver，都覆盖到才算数**）。cmd-id 必须在脚本里存在，flow_runner 启动时静态校验（可用 `--no-verify-commands` 跳过）。

### 3.4 单设备冒烟（回归用）

```bash
bash testing/scripts/run_single --platform ios --script <path/to/script.json>
```

### 3.5 单测

```bash
cd tool/flow_runner && dart test    # 2026-11-05 时点 78/78
```

---

## 4. 踩坑大全（现象 → 根因 → 修复 → 预防）

### A. SDK 事件门闩：startCallback 从未被调用 ⭐ 最重要

- **现象**：addContact 返回成功，但对端 `wait_event` 超时；agent 事件缓存里根本没有 onContactInvited。
- **取证链**：① SDK 返回 success；② logcat tag `ONE SDK` 证明 REST 请求真实到达服务器（`POST /users/<u>/contacts/apply`）、对端**原生层**通过 MSYNC 收到 ROSTER 推送；③ Dart 层（`[APITEST]`）在同一时刻零输出 → 断点在原生→Dart 通道。
- **根因**：`ListenerHandle`（Android `.java` / iOS `.m` 同构）把联系人/群组/聊天室事件入队，只有 `hasReady=true` 才分发；`hasReady` 由 `startCallback()` 置位，但 example 重写后**没有任何地方调用** `ChatClient.startCallback()`。连接事件不走门闩，所以登录/同步一切"正常"，极具迷惑性。
- **修复**：example 三处 init 成功后补 `await ChatClient.getInstance.startCallback()`（agent_home_page.dart / auto_mode.dart / init_page.dart）。Dart 层修复，双平台同时生效。
- **预防**：任何"SDK 调用成功但事件不来"的问题，先查原生日志确认事件是否到达原生层，再查门闩。详见 docs 仓库 `2026-11-05-sdk-listener-handle-startcallback-event-gate.md`。

### B. Flutter print 不走 stdout

- iOS：print() 经引擎转发进 **os_log**，`simctl --console / --console-pty / --stdout=<path>` 全部收不到（重定向文件恒 0 字节）。正确通道：`xcrun simctl spawn <udid> log stream --predicate 'process == "Runner"'`。
- Android：print() 进 **logcat**，用 `adb logcat` 流式捕获（先 `-c` 清旧日志防陈旧凭据）。
- 凭据捕获链：ControlServer 绑 loopback:0 → 打印 `[AGENT_CONTROL] port/token` → log stream/logcat 捕获 → launch 脚本解析 → agents.json。

### C. package:args 的 command 解析域

- **现象**：`flow_runner run <flow> --agents-file …` 误报 usage。
- **根因**：command 后的选项进入 command 自己的解析域；选项挂在顶层 parser 时 command 内读不到，顶层 `results.rest` 恒空。
- **修复**：选项定义挪到 `addCommand('run')` 返回的 command parser 上，从 command 结果读取。

### D. `$agents.` 前缀 off-by-one

- **现象**：设备脚本里 `$agents.bob.userId` 解析为 null，expect 断言挂。
- **根因**：`interp.dart` 的 `$agents.` 分支 `substring(7)` 应为 `substring(8)`（`"$agents."` 共 8 字符）；前导点导致 role 为空串。
- **教训**：YAML `inputs` 与脚本 `params/expect` 是**两套 resolver**，单测只覆盖了前者所以漏网。回归测试要按实际调用路径设计。

### E. toybox grep 不支持 `\|` 交替（假阴性陷阱）

- 本机 grep 是 toybox shim，`grep "a\|b"` 静默返回空——曾造成两次误判（"没有 SDK 日志"、"ClientWrapper 没有 startCallback 分支"）。
- **规矩**：交替匹配一律 `grep -E "a|b"`；`grep` 返回空时先 `grep -c <肯定存在的词>` 自证 grep 可用。
- 另：ripgrep 默认跳过 `.worktree` 这类**点开头目录**，目录级搜索要用普通 grep 或显式文件路径。

### F. bash 3.2 兼容 + 特殊变量

- macOS 系统 bash 是 3.2：**禁用** mapfile、declare -A、`${var,,}` 等 4+ 特性。
- `GROUPS` 是 bash 特殊变量（用户组 ID 数组），赋值无效——循环会按主组 ID 数量跑错次数。改用 N_GROUPS 等普通名。
- 所有脚本头部声明最低版本并 source `_compat.sh`（非 bash 或 <3.2 即 exit 64）。

### G. Dart HttpClient 只认小写 http_proxy

- `findProxyFromEnvironment` 只认**小写** `http_proxy`；脚本导出大写 `HTTP_PROXY` 时 Dart 静默直连（挂代理环境下表现为连接超时）。
- 修复：测试工具一律用 `directHttpClient()`（`findProxy = DIRECT`）。

### H. Connection refused 报的是本地临时端口

- dry-run 假端点时，SocketException 显示的端口是**客户端本地套接字临时端口**，不是目标端口——每次运行都变，极易误判为"endpoint 注入没生效"。
- 正确判读法：在目标端口起个假 HTTP 服务，错误从 Connection refused 变 404 即证明 endpoint 注入正确。

### I. 联系人语义实测结论（2026-11-05，直接影响用例设计）

1. **REST 加好友 bypass 邀请**：`addContacts(owner, userId)` 直接双向成为好友，不发邀请事件。
2. **SDK deleteContact 幂等**：对非好友调用也返回成功。
3. **联系人事件只发对端**：操作方自己不收 onContactInvited/删除事件。
4. **离线邀请不补推**：对端未登录时发的邀请，对端登录后**不会**收到 onContactInvited。
   - → flow 必须 `barrier both-online` 保证接收方登录完成后发起方才操作。
   - → REST 重置关系（preconditions）不产生 SDK 事件，所以放在用例前置是安全的。

### J. sandbox-exec：iOS 构建的沙箱限制

- flutter tool 对 xcodebuild 的 SPM 包解析套 `sandbox-exec`；AI/CI 宿主进程被拒 `sandbox_apply` → `Could not resolve package dependencies: sandbox-exec: sandbox_apply: Operation not permitted`。
- **iOS 构建、且仅构建这一步**必须用户终端执行；模拟器启停/安装/launch/测试均可自动化。
- 对策：`setup_devices --prebuilt ios=<Runner.app>`（已实现待实测）或 §2.3 手动兜底。

### K. 其他

- flow finish 后 ControlServer 关闭：重跑 flow 前必须重跑 setup_devices。
- simctl 输出行尾带空白：grep 用 `$` 锚点会失配，去锚点并在 miss 时显式报错。
- 脚本传参含空格/与平台分隔符冲突：用临时文件 + `|` 分隔传参，不要拼 argv。

---

## 5. 常见卡点决策树

```
wait_event 超时？
├─ 对端 agent 事件缓存 (/v1/events) 里有该事件吗？
│   ├─ 有 → seq 游标/裸名/匹配条件问题（检查 afterSeq 起点、source 裸名、match 字段名）
│   └─ 没有 → 原生层收到推送了吗？（logcat tag "ONE SDK" / log stream 查 ROSTER）
│       ├─ 收到 → Dart 层零输出？→ startCallback 门闩（§4.A）
│       └─ 没收到 → 接收方真的登录完成了吗？（离线邀请不补推，§4.I-4；barrier 放对位置了吗）
└─ 连 agent 都连不上？→ /v1/info 探活；flow 是否跑完过（服务已关，重跑 setup_devices）

cmd 步骤 failed？
├─ reason 里 expected.contains 为 null → $agents 引用解析挂了（§4.D）
├─ result.success=false → 看 agent 日志里该 api 的真实报错
└─ usage 报错 → CLI 参数解析域（§4.C）

setup_devices 卡 ios/launch 30s 等不到 [AGENT_CONTROL]？
├─ 凭据通道对不对（必须是 log stream，§4.B）
├─ 残留实例没 terminate（对已运行实例 launch 无新凭据）
└─ 装的是不是新构建（旧构建无 contact_apis 注册会 422）

preconditions blocked？
└─ 独立报告文件看原因；blocked ≠ failed（账号未绑定/REST 不可达等环境问题）
```

## 6. 验证状态矩阵（2026-11-05 时点）

| 组合 | 状态 | 备注 |
|---|---|---|
| Android ×2（5554+5556） | ✅ 全绿 | 10 passed / 0 failed / 0 timeout，含事件链+双向断言 |
| iOS ×2（双 iPhone 16） | ⏳ 进行中 | 新构建已由用户产出（19:10），待 setup+run |
| iOS + Android mixed | ⏳ 待做 | 验证跨平台事件链（最终形态） |
| flow_runner 单测 | ✅ 78/78 | 含 $agents 回归测试 |

## 7. 关键文件索引

| 文件 | 职责 |
|---|---|
| `testing/scripts/prepare_data` | REST 建号，产 environment.json |
| `testing/scripts/setup_devices` | 编排 install/launch，产 agents.json（含 --roles/--prebuilt） |
| `testing/scripts/run_flow` | 注入 agents-file + 跑 preconditions + flow_runner |
| `testing/scripts/run_single` | 单设备冒烟 |
| `testing/scripts/device/{ios,android}/{boot,install,launch,list}` | 原子脚本 |
| `testing/tools/data/preconditions.dart` | YAML 声明式前置 → REST 执行 → 独立报告 |
| `testing/flows/*.yaml` + `scripts/*.json` | 用例与设备脚本 |
| `tool/flow_runner/` | 解释器（parser/interp/expect/report），单测在 test/ |
| `im_flutter_sdk/example/lib/agent/` | ControlServer/EvidenceStore/agent UI |
| `im_flutter_sdk/example/lib/registry/apis/` | SDK 命令注册（contact_apis 等） |
| `im_flutter_sdk/example/lib/listeners.dart` | 事件→LogStore 桥 |
| `im_flutter_sdk/example/tool/rest_resource_client.dart` | REST 杠杆（fetchContactIds/addContacts/removeContacts） |
| docs 仓库 `refs/troubleshooting/` | 按专题的深度排查文档（本 runbook 的展开版） |
