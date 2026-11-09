# 多设备平版测试

**请记住并遵守 spec.md 文档规则。这是最高优先级。**

基于 Dart 的独立测试工具工程。负责数据准备、设备准备、多设备协同执行、日志报告和清理。单设备入口见 [single](../single/README.md)，测试分类见 [测试指南](../../docs/testing/README.md)。

入口见[执行流程](docs/2026-11-06-test-execution-flow.md)及[执行规格](../../docs/spec/2026-11-06-testing-v2-spec.md)。

场景与验收要求见[多设备协同测试用例规格](docs/2026-11-07-multi-device-cases-spec.md)，结果与待处理问题见[验证记录](docs/2026-11-07-multi-device-cases-verification.md)。

## 目录

```text
testing/multi/
├── README.md
├── spec.md               # 规则与边界
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
├── .gitignore
├── bin/
│   └── cli.dart          # 命令行入口
├── lib/                  # Dart 源码；生成的 accounts.g.dart 保存账号数据，Git 忽略
├── scripts/              # 配置及账号源码生成脚本，纳入 Git
├── config/               # 本地持久配置，Git 忽略，不参与运行清理
├── data/                 # YAML 流程、JSON 命令等静态数据
├── docs/                 # 项目文档
├── troubleshooting/      # 故障排查与修复记录，纳入 Git
├── tmp/                  # 运行临时数据，Git 忽略
├── build/                # 构建产物与缓存，Git 忽略
└── reports/              # 每次运行的报告，Git 忽略
```

## 用例

以下均为双模拟器正向用例，每个 YAML 对应同名 JSON。文件名使用 `<引入版本>-multi-<场景>-positive`，已有场景跨版本复用。

| 场景 | YAML 入口 |
|---|---|
| 单聊消息送达确认 | [message-delivery](data/5.0.0-multi-message-delivery-positive.yaml) |
| 单聊消息已读回执 | [message-read-receipt](data/5.0.0-multi-message-read-receipt-positive.yaml) |
| 联系人申请与接受 | [contact-add](data/5.0.0-multi-contact-add-positive.yaml) |
| 公开群入群通知 | [group-member-join](data/5.0.0-multi-group-member-join-positive.yaml) |
| Presence 订阅与发布 | [presence](data/5.0.0-multi-presence-positive.yaml) |
| 同账号双设备消息同步 | [message-device-sync](data/5.0.0-multi-message-device-sync-positive.yaml) |
| 消息内容编辑通知 | [message-edit](data/5.0.0-multi-message-edit-positive.yaml) |
| 消息撤回通知（暂停执行） | [message-recall](data/5.0.0-multi-message-recall-positive.yaml) |
| 群成员退出通知 | [group-member-leave](data/5.0.0-multi-group-member-leave-positive.yaml) |
| 用户资料订阅更新 | [user-info-subscribe](data/5.0.0-multi-user-info-subscribe-positive.yaml) |
| 群名片更新通知 | [group-namecard](data/5.0.0-multi-group-namecard-positive.yaml) |
| 同账号双设备建群及群名称更新同步 | [group-create-device-sync](data/5.0.0-multi-group-create-device-sync-positive.yaml) |
| 群邀请接收、接受与成员关系 | [group-invite-confirm](data/5.1.0-multi-group-invite-confirm-positive.yaml) |

消息撤回场景按用户要求暂停，暂不加入执行选择文件；恢复须明确确认。各场景前置条件见上方规格链接，平台验证与问题证据见验证记录。5.1.0 的群更新、群邀请确认场景及本轮结果见[覆盖与场景定义](../../docs/porting/5.1.0/2026-11-09-test-coverage.md#多设备第二轮确认)和[执行统计](../../docs/porting/5.1.0/2026-11-09-test-verification.md)。

## 首次执行一个场景

以下命令均在 `testing/multi/` 目录执行，使用 Flutter 3.47.0 配套的 Dart；宿主工具链与 example 依赖准备见[项目开发说明](../../CONTRIBUTING.md)。以双 iOS Presence 场景为例：

```bash
dart pub get
```

### 1. 准备账号输入

先自动生成账号输入配置：

```bash
dart run scripts/generate_accounts_input.dart
```

默认读取 `im_flutter_sdk/example/config.local.json`，将账号、资源和应用凭据写入 **`config/accounts-input.json`**，并展开 `chatOptions`。可用 `--source <路径>` 指定来源；源文件不存在时生成占位模板，由用户补齐。已有输出默认保留，明确指定 `--force` 才重新导入覆盖。

输入文件结构如下，账号列表支持任意数量；账号须已存在于目标应用中，生成脚本不会创建账号：

```json
{
  "appKey": "<org>#<app>",
  "restApi": "https://<REST服务域名>",
  "clientId": "<应用的Client ID>",
  "clientSecret": "<应用的Client Secret>",
  "accounts": [{"id": "user_a"}, {"id": "user_b"}],
  "debugMode": true
}
```

将占位内容和 `user_a/user_b` 换成实际值。`restApi` 填服务基础地址，工具根据 `appKey` 拼接组织和应用路径；SDK 初始化参数（如 `debugMode`）与 `appKey` 放在同一层。

然后运行：

```bash
dart run scripts/generate_accounts.dart --input config/accounts-input.json
```

脚本通过 REST 获取账号 Token，生成 **`lib/accounts.g.dart`**，成功时输出 `Generated .../lib/accounts.g.dart`。JSON 配置和 Dart 产物均不纳入 Git、不随运行清理；Token 失效后重新生成 Dart 源码，再建立新轮次。

### 2. 选择场景、账号和模拟器

生成当前平台的场景选择配置，无需手写 JSON：

```bash
dart run scripts/generate_cases.dart --platform ios --case 5.0.0-multi-presence-positive
```

也可只指定平台，自动遍历 `data/`，选中全部未暂停的场景。以下为可选方式，会重新生成选择配置：

```bash
dart run scripts/generate_cases.dart --platform android
```

脚本从 `config/accounts-input.json` 读取账号，复用设备模块查询模拟器，分别生成账号编号和设备映射，写入 **`config/cases.json`**。每次成功生成后替换该文件，失败保留旧文件；不改账号配置，不启动设备或执行测试。消息撤回场景自动跳过，显式选择也会拒绝。

| 参数 | 规则 |
|---|---|
| `--platform` | 必填，`android` 或 `ios`。 |
| `--case` | 文件主名，不含 `.yaml`；可重复，按传入顺序选择。不传则按文件主名排序。 |
| `--account` | 可重复，指定账号池及顺序，ID 必须存在于账号配置。不传则使用配置内顺序。 |
| `--instance` | 可重复，指定设备及顺序；不传则按发现的 `instance` 字符串排序。按 YAML `agents` 的声明顺序分配，不同角色使用不同设备。 |

账号按所选顺序编号为 `account1` 至 `accountN`，全部写入每个用例；设备按 YAML `agents` 分配。两者数量独立，不限定两个；账号为空、设备不足、资源重复或指定值不存在时失败。默认设备列表包含未启动的模拟器，启动及就绪检查由后续执行环节完成。

需要指定模拟器时，先查询 `instance`：

```bash
dart run bin/cli.dart devices list --platform ios
# 使用 Android 时执行：
dart run bin/cli.dart devices list --platform android
```

例如指定 Android 设备和账号顺序（替换为查询及配置中的实际值）：

```bash
dart run scripts/generate_cases.dart --platform android \
  --case 5.0.0-multi-presence-positive \
  --instance Pixel_9 --instance Pixel_9_2 \
  --account user_a --account user_b
```

首次 iOS Presence 命令的生成结果示例：

```json
{
  "cases": [{
    "yaml": "../data/5.0.0-multi-presence-positive.yaml",
    "accounts": {"account1": "user_a", "account2": "user_b"},
    "devices": {
      "alice": {"platform": "ios", "instance": "<UDID-A>"},
      "bob": {"platform": "ios", "instance": "<UDID-B>"}
    }
  }]
}
```

- `yaml`：用例文件；相对路径以 `cases.json` 所在目录为起点。
- `alice/bob`：该 YAML 的 `agents` 角色名。
- `accounts`：编号对应账号输入中的 `accounts[].id`；命令通过 `$global.account.account1.userId`、`.userToken` 读取。登录账号由命令选择，与设备名称无关。
- `platform/instance`：平台及模拟器标识；iOS 使用 UDID，Android 使用 AVD 名称。

上面的清单只包含 Presence，因此只执行这一个场景。生成器固定写入 `config/` 下的两份配置；CLI 的 `--input`、`--cases` 仍可读取另存的配置。

### 3. 全流程执行

```bash
dart run bin/cli.dart all --cases config/cases.json
```

**`all` 表示执行全部环节，场景范围由 `cases.json` 决定。** 它完成前置数据准备、设备准备、构建、安装启动、用例执行和报告生成；账号源码须先按第 1 步生成。

终端首先输出 `runId=...`，这是本轮结果目录的名字。清单只有一项就只跑一例，多项则按清单顺序执行。更换场景时重新运行配置生成命令，再建立新轮次。清单包含联系人申请场景时，执行命令加上 `--data-input config/accounts-input.json`。

### 4. 打开结果

把命令输出的 `runId` 填入下面的路径，先看汇总：

```bash
cat reports/<runId>/summary.md
```

| 文件 | 查看内容 |
|---|---|
| `reports/<runId>/summary.md` | 本轮用例数、执行次数、通过／失败次数及任务故障；当前以“是／否”表示用例是否通过。 |
| `reports/<runId>/statistics.csv` | 场景明细，每行一次执行，含用例编号、预期、实际、是否通过及原因；可用表格软件打开。 |
| `reports/<runId>/process.json` | 各环节结果及证据引用，用于追溯。 |
| `reports/<runId>/<用例名>/<执行序号>/flow-report.json` | 该用例每一步的执行结果。 |
| `tmp/<runId>/run.log` | 阶段进度与错误；其他日志按过程记录中的路径查找。 |

`all` 已自动生成汇总。需要重新生成时执行 `dart run bin/cli.dart report --run-id <runId>`；此命令成功时终端无输出，仍需打开文件查看。`tmp/<runId>/run.json` 是私有状态，不随报告分享。

## 分环节执行同一个场景

使用上面准备好的两个 JSON。`prepare` 输出新的 `runId`，后续命令均使用它；`launch` 输出 `launch=...`，将该值传给 `run --launch`：

```bash
dart run bin/cli.dart prepare data/5.0.0-multi-presence-positive.yaml --cases config/cases.json
dart run bin/cli.dart devices start --platform ios --instance <UDID-A> --run-id <runId>
dart run bin/cli.dart devices start --platform ios --instance <UDID-B> --run-id <runId>
dart run bin/cli.dart build --platform ios --run-id <runId>
dart run bin/cli.dart launch data/5.0.0-multi-presence-positive.yaml --run-id <runId>
dart run bin/cli.dart run data/5.0.0-multi-presence-positive.yaml --run-id <runId> --launch <launchId>
dart run bin/cli.dart report --run-id <runId>
```

`run` 只执行参数指定的场景，并生成原始报告；最后的 `report` 生成汇总、CSV 和过程索引，仍按“打开结果”一节查看。

每次复验须重新 `launch`，原结果保留并增加执行序号。输入账号、用例副本、账号及设备映射在建轮时固定；修改后重新建轮。多个兼容构建通过 `--build <构建操作ID>` 选择；`--build-result <结果JSON>` 可导入已有构建，导入时校验并复制到本轮。

## 其他场景的配置

- **联系人申请**：需准备及核验双方非好友，全流程命令增加 `--data-input config/accounts-input.json`；分环节时在 `prepare` 和 `run` 上均传入该参数。
- **同账号同步**：两台设备的登录命令均引用 `account1`，设备仍分别使用 `a1/a2`。
- **同账号消息同步**：收件人直接使用 `account2`，无需第三台设备；选择文件始终指向 `data/` 中的原始 YAML。

完整格式和校验规则见[账号与设备独立管理规格](docs/2026-11-08-account-device-separation-spec.md)。

## 清理

清理存在[过程证据依赖遗漏](docs/2026-11-07-multi-device-cases-verification.md#清理后过程记录引用失效待修复)：用例执行证据会保留，但部分准备、设备、构建和启动日志仍可能被删除。需要完整过程追溯时，暂不执行以下清理命令。

```bash
dart run bin/cli.dart clean --run-id <runId> --type logs --type build
```

清理只处理登记产物，账号源码始终保留。退出码 0 表示操作成功，涉及用例执行时还要求用例通过；非零时检查用例结论与任务故障。

通过 `dart run bin/cli.dart --help` 查看操作列表，各操作也支持 `--help`。

## 开发检查

```bash
dart analyze
dart test
```
