# 多设备协同测试用例

本目录是 Flutter 仓的多设备多账号测试用例集：每个场景一对同名文件——YAML 定义流程与角色，JSON 保存命令、数据与断言。文件名格式 `<引入版本>-multi-<场景>-positive.yaml/.json`，已有场景跨版本复用，新场景以首次引入的 SDK 版本冠名。

用例本身没有运行能力，由独立仓 **im-test-orchestrator**（与本仓库同级的单独 git 仓库，Dart 实现）编排执行；本仓库经薄封装 `scripts/multi.sh` 调用它。契约与协议两端（Flutter/RN）通用，RN 仓持有逐字节一致的同名副本（`example/multi_cases/`）。

## 0. 工具仓在哪里

`scripts/multi.sh` 按以下顺序解析 im-test-orchestrator 的位置：

1. 环境变量 `IMTO_PATH` 指向的 checkout（最高优先级）；
2. 本地固定路径 `/Users/asterisk/Codes/zuoyu/im-test-orchestrator`；
3. 按 `testing/multi-tool.json` 里的 `repo`/`ref` 克隆到 `testing/.im-test-orchestrator/`（gitignored；填上真实 URL 和 ref 后才生效）。

下文用 `<IMTO>` 表示解析到的工具仓目录。报告、运行状态、账号产物都写在 `<IMTO>/multi/` 下，**不写本仓库**。

## 1. 输入文件从哪来

一次执行需要三类输入，来源各不相同：

| 输入 | 位置 | 怎么来 |
|---|---|---|
| 用例 YAML/JSON | 本目录 | 人工按规范编写，见下文"编写新用例" |
| 账号配置 `accounts-input.json` | `<IMTO>/multi/config/`（gitignored） | 由 `generate_accounts_input.dart` 从 `im_flutter_sdk/example/config.local.json` 生成 |
| 账号 Token 源码 `accounts.g.dart` | `<IMTO>/multi/lib/`（gitignored） | 由 `generate_accounts.dart` 经 REST 换取 Token 后生成 |
| 场景选择配置 `cases.json` | `<IMTO>/multi/config/`（gitignored） | 由 `generate` 命令自动生成，不要手写 |

### 1.1 准备账号（每个工具仓 checkout 只需做一次，Token 过期后重做）

前置：已执行 `make config` 生成 `im_flutter_sdk/example/config.local.json`，并填入真实 appKey、账号等（见仓库根 CONTRIBUTING.md）。

```bash
cd <IMTO>/multi
dart pub get
dart run scripts/generate_accounts_input.dart            # 读取 config.local.json → 生成 config/accounts-input.json
dart run scripts/generate_accounts.dart --input config/accounts-input.json   # REST 换 Token → 生成 lib/accounts.g.dart
```

两个脚本只在工具仓内运行，本仓库没有封装入口。已有输出默认保留，重跑加 `--force`。账号须已存在于目标应用，脚本不创建账号。

### 1.2 生成场景选择配置

在本仓库根执行：

```bash
# 跑全部未暂停的场景（推荐先全量跑通）
scripts/multi.sh generate --platform android

# 或只选指定场景（主文件名，不含 .yaml，可重复）
scripts/multi.sh generate --platform ios --case 5.0.0-multi-presence-positive
```

脚本扫描本目录（`--cases-dir` 默认 `testing/multi/cases`），从 `config/accounts-input.json` 读账号、自动发现模拟器，生成 `<IMTO>/multi/config/cases.json`：账号按顺序编号为 `account1..N`，设备按 YAML 的 `agents` 角色分配。常用可选参数：

| 参数 | 作用 |
|---|---|
| `--case <主名>` | 指定场景，可重复，按传入顺序执行；不传则全量 |
| `--account <id>` | 指定账号池及顺序，可重复；不传用配置内顺序 |
| `--instance <名>` | 指定设备及顺序，可重复；不传按发现排序。先查询可用设备：`scripts/multi.sh devices list --platform android` |
| `--target testing/target-flutter.yaml` | 从 target yaml 读取 `casesDir` 等默认值 |

每次成功生成后替换 `cases.json`，失败保留旧文件；不启动设备、不执行测试。

## 2. 执行

### 2.1 全流程（推荐）

```bash
scripts/multi.sh all --cases <IMTO>/multi/config/cases.json
```

`all` 依次完成数据准备、设备准备、构建、安装启动、执行、报告。`--app-dir` 默认 `im_flutter_sdk/example`，`--target testing/target-flutter.yaml` 可集中提供构建参数。终端首先输出 `runId=...`——这是找结果的钥匙。

联系人申请场景（contact-add）需要业务数据核验，命令追加：

```bash
scripts/multi.sh all --cases <IMTO>/multi/config/cases.json \
  --data-input <IMTO>/multi/config/accounts-input.json
```

### 2.2 分环节执行（调试用）

```bash
scripts/multi.sh prepare testing/multi/cases/5.0.0-multi-presence-positive.yaml \
  --cases <IMTO>/multi/config/cases.json          # 输出新的 runId
scripts/multi.sh devices start --platform ios --instance <UDID> --run-id <runId>   # 每个角色一台
scripts/multi.sh build --platform ios --run-id <runId>
scripts/multi.sh launch testing/multi/cases/5.0.0-multi-presence-positive.yaml --run-id <runId>   # 输出 launch=...
scripts/multi.sh run testing/multi/cases/5.0.0-multi-presence-positive.yaml --run-id <runId> --launch <launchId>
scripts/multi.sh report --run-id <runId>
```

每次复验须重新 `launch`；账号、设备映射在建轮（prepare）时固定，改了要重新建轮。相对路径参数由 `multi.sh` 自动换算为本仓库根的绝对路径。

## 3. 输出结果在哪里

所有产物默认在工具仓 `<IMTO>/multi/` 下（gitignored）：

| 路径 | 内容 |
|---|---|
| `reports/<runId>/upgrade-report.md` | **先看这个**：正式汇总报告，按场景统计通过/失败/未执行/未完成，含角色、步骤、证据链接 |
| `reports/<runId>/summary.md` | 本轮用例数、执行/通过/失败次数、任务故障 |
| `reports/<runId>/statistics.csv` | 每次执行一行，可用表格软件打开 |
| `reports/<runId>/upgrade-report.json` | 正式报告的结构化版本，可核对可重建 |
| `reports/<runId>/<用例名>/<执行序号>/flow-report.json` | 该用例每一步的执行结果 |
| `tmp/<runId>/run.log` | 阶段进度与错误，排查先看这里 |

跨多次运行或合并单设备证据时汇总（在本仓库根执行，可重复传入、按旧到新排列）：

```bash
python3 testing/report_upgrade.py --version 5.1.0 \
  --single artifacts/single/<时间戳>/<平台> --multi <IMTO>/multi/reports/<runId> \
  --output artifacts/multi/<时间戳>/
```

## 4. 场景清单

| 场景 | 主名 | 备注 |
|---|---|---|
| 单聊消息送达确认 | message-delivery | |
| ~~单聊消息已读回执~~ | ~~message-read-receipt~~ | 4.25.0 无已读回执 API，场景已移除（见 docs/testing/2026-11-20-migration-issue-register.md T7-1） |
| 联系人申请与接受 | contact-add | 需 `--data-input` |
| 公开群入群通知 | group-member-join | |
| Presence 订阅与发布 | presence | |
| 同账号双设备消息同步 | message-device-sync | 两台设备同一账号 |
| 消息内容编辑通知 | message-edit | |
| 消息撤回通知 | message-recall | **暂停执行**，选择文件自动跳过 |
| 群成员退出通知 | group-member-leave | |
| 用户资料订阅更新 | user-info-subscribe | |
| 群名片更新通知 | group-namecard | 已知问题见工具仓验证记录 |
| 同账号双设备建群及群名称同步 | group-create-device-sync | |
| 群邀请接收、接受与成员关系 | group-invite-confirm | |

前置条件、平台验证状态与历史问题证据见 im-test-orchestrator 仓 `multi/docs/2026-11-07-multi-device-cases-spec.md` 和 `multi/docs/2026-11-07-multi-device-cases-verification.md`。

## 5. 编写新用例

属于执行前的准备工作，不是每轮执行步骤。流程：

1. 与维护者确认场景、前置条件、允许的准备动作和通过标准（准备动作不能提前完成被测业务行为）。
2. 在本目录新增 `<版本>-multi-<场景>-positive.yaml` 和同名 `.json`，两端目录逐字节一致；格式与语法见 im-test-orchestrator 仓 `docs/case-authoring.md` 和 `flow_runner/README.md`（YAML 表达流程与角色，JSON 的 `data` 声明输入、`steps` 保存命令、`requiredBindings` 声明必要验证）。
3. 核对 example 执行端是否支持用例用到的命令；缺支持先补 agent，不能把无法执行的用例当可用产物。
4. 用 `generate --case` 单选新用例跑通后再加入全量。

端间对账（核对 Flutter/RN 副本一致）：

```bash
scripts/multi.sh cases diff testing/multi/cases <RN仓>/example/multi_cases
```

退出码：0 一致，1 有差异，2 用法错误。确因一端 SDK 能力缺失需要差异时，必须显式声明并在本 README 记录例外。

## 6. 清理

```bash
scripts/multi.sh clean --run-id <runId> --type logs --type build
```

已知限制：清理会保留用例执行证据，但部分准备、设备、构建、启动日志可能删除；需要完整过程追溯时不要清理。账号源码始终保留。详见工具仓 `multi/README.md`。
