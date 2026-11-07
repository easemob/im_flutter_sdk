# Example 测试体系 v2

**请记住并遵守 spec.md 文档规则。这是最高优先级。**

基于 Dart 的独立测试工具工程。目标包括数据准备、设备准备、多设备协同执行、日志报告和清理；单设备执行暂缓。

入口见[执行流程](docs/2026-11-06-test-execution-flow.md)及[执行规格](../docs/spec/2026-11-06-testing-v2-spec.md)。

## 目录

```text
testing_v2/
├── README.md
├── spec.md               # 规则与边界
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
├── .gitignore
├── bin/
│   └── cli.dart          # 命令行入口
├── lib/                  # Dart 源码；生成的 accounts.g.dart 保存账号数据，Git 忽略
├── scripts/              # 账号数据生成脚本，纳入 Git
├── data/                 # YAML 流程、JSON 命令等静态数据
├── docs/                 # 项目文档
├── troubleshooting/      # 故障排查与修复记录，纳入 Git
├── tmp/                  # 运行临时数据，Git 忽略
├── build/                # 构建产物与缓存，Git 忽略
└── reports/              # 每次运行的报告，Git 忽略
```

## 使用

在本目录运行 `dart pub get`，通过 `dart run bin/cli.dart --help` 查看操作及参数。各操作支持 `--help`。

先准备私有 JSON，包含 `appKey`、`accounts: [{"id": "账号"}]`、`restApi`、`clientId`、`clientSecret` 及需要的 SDK 初始化参数，再生成账号源码：

```bash
dart run scripts/generate_accounts.dart --input tmp/accounts-input.json
```

用例由 `data/` 中同名 YAML、JSON 组成。角色与设备在独立选择文件中绑定，例如 `tmp/cases.json`：

```json
{
  "cases": [{
    "yaml": "../data/5.0.0-multi-presence-positive.yaml",
    "roles": {
      "alice": {"accountId": "user_a", "platform": "ios", "instance": "<UDID-A>"},
      "bob": {"accountId": "user_b", "platform": "ios", "instance": "<UDID-B>"}
    }
  }]
}
```

Presence 场景使用两个不同账号。Android 的 `instance` 使用 AVD 名称。完整执行与结果查看：

```bash
dart run bin/cli.dart all --cases tmp/cases.json
dart run bin/cli.dart report --run-id <runId>
```

需要准备或核验联系人前置状态的用例另传 `--data-input tmp/accounts-input.json`。输入账号、用例副本和角色映射在建轮时固定；更换数据或用例后新建轮次。

分环节调试：

```bash
dart run bin/cli.dart prepare data/5.0.0-multi-presence-positive.yaml --cases tmp/cases.json
dart run bin/cli.dart devices start --platform ios --instance <UDID-A> --run-id <runId>
dart run bin/cli.dart devices start --platform ios --instance <UDID-B> --run-id <runId>
dart run bin/cli.dart build --platform ios --run-id <runId>
dart run bin/cli.dart launch data/5.0.0-multi-presence-positive.yaml --run-id <runId>
dart run bin/cli.dart run data/5.0.0-multi-presence-positive.yaml --run-id <runId> --launch <launchId>
```

每次执行须重新 `launch`；复验保留原结果并增加执行序号。多个兼容构建通过 `--build <构建操作ID>` 选择；`--build-result <结果JSON>` 导入已有构建时先校验并复制到本轮。

结果位于 `reports/<runId>/`：`summary.md` 汇总，`statistics.csv` 每行对应一次用例尝试，`process.json` 引用过程证据。`tmp/<runId>/run.log` 记录阶段进度，`run.json` 保存私有状态。分享报告时不复制私有输入、生成源码或 `run.json`。

```bash
dart run bin/cli.dart clean --run-id <runId> --type logs --type build
```

清理只处理登记产物；保留运行中的资源、未解决故障证据及保留报告的依赖。账号源码始终保留。退出码 0 表示本次操作成功且用例通过；非零时分别检查用例结论与任务故障。

## 开发检查

```bash
dart analyze
dart test
```
