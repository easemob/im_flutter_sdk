# 数据准备

目标：生成测试所需的账号数据源码，并为用例准备、核验已确认的业务前置状态。

## 生成文件

路径：`lib/accounts.g.dart`，不纳入 Git。导出 `environment` 常量，包含初始化参数、账号及用例所需资源。

结构示例（值仅作示意）：

```dart
const Map<String, Object?> environment = <String, Object?>{
  'appKey': 'org#app',
  'debugMode': true,
  'dataSyncType': 7,
  'enableUserInfo': true,
  'accounts': <Map<String, Object?>>[
    <String, Object?>{'id': 'user_a', 'token': 'user-token-a'},
    <String, Object?>{'id': 'user_b', 'token': 'user-token-b'},
  ],
  'groups': <Map<String, Object?>>[],
  'rooms': <Map<String, Object?>>[],
};
```

| 数据 | 规则 |
|---|---|
| `appKey` | 必填，与账号 Token 所属应用一致。 |
| 初始化参数 | 使用 SDK 初始化字段名，如 `debugMode`、`dataSyncType`、`enableUserInfo`；按实际配置生成，示例值不是固定默认值。 |
| `accounts` | 账号列表，每项包含 `id`、`token`；账号数量按用例需要准备，不固定为两个，不在此绑定物理设备。 |
| `groups` | 群组资源列表，每项包含 `id`，按需包含 `owner`、`name`；不需要时为空列表。 |
| `rooms` | 聊天室资源列表，每项包含 `id`，按需包含 `name`；不需要时为空列表。 |
| 私有部署参数 | 需要时生成 `enableDNSConfig: false`、`restServer`、`imServer`、`webSocketServer`，以及配置中指定的 `imPort`、`webSocketPort`。 |

生成文件不包含管理端凭据（`clientId`、`clientSecret`、应用 Token）、设备信息、API 返回值或监听事件。

## 辅助脚本边界

- 辅助脚本放在 `scripts/`，纳入 Git；负责读取生成输入、获取账号 Token、校验数据并生成 Dart 文件。
- 保持既有脚本及其使用方式不变，不覆盖 example 的配置或生成文件。
- 必要数据全部获取、校验成功后整体写入；失败须明确报错，不生成半成品，也不能将旧文件视为本次准备成功。
- 账号生成脚本不操作设备、不启动 App、不执行 SDK 初始化或登录，不重置服务端业务状态。

## 输入与交接

- 生成脚本显式读取本地 JSON，包含账号 ID、初始化及资源配置、REST 地址和管理凭据；不搜索其他工程配置，不自动创建账号、群组或聊天室。
- CLI 按需加载生成源码并固定本轮数据；帮助、设备操作、构建、已有报告及清理不依赖该源码。已有轮次读取快照，不混入重新生成的数据。
- 编排层将账号、设备、业务输入组织为 `$global`，命令结果和匹配事件由解释器分别绑定；生成脚本不预填运行结果。
- `initConfig` 包含 `appKey`、SDK 初始化及私有部署参数，不包含账号列表和 Token；Token 问题按证据归因，不自动改写用例断言结论。

## 业务前置准备

- YAML `preconditions` 声明所需状态，JSON `data.prepare` 列出允许自动准备的部分；场景和改动范围在用例设计时确认，不要求逐轮人工审批文件。
- 数据模块只处理声明涉及的账号和资源；已满足则不写入，准备后重新查询确认。准备动作不能提前完成被测业务行为。
- `prepare` 可独立调用，`all` 逐用例调用同一模块；`run` 只重新核验，不隐式修复状态。失败阻断受影响用例，准备与核验记录分开保存。
- 输入、CLI 参数及交接契约见[执行规格 §1–2](../../docs/spec/2026-11-06-testing-v2-spec.md#1-系统边界与编排)。

## 文件命名与存放

- Dart 源码和辅助脚本按职责使用 `snake_case` 命名，例如 `scripts/generate_accounts.dart`，不带运行日期。
- 生成入口固定为 `lib/accounts.g.dart`；本轮数据副本保存在 `tmp/<runId>/run.json`，仅当前用户可读写，不直接作为日志或报告分享。
- `runId` 遵循[执行用例的轮次规则](2026-11-06-test-execution-troubleshooting.md)。
