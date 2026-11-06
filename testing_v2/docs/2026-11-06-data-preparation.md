# 数据准备

目标：通过辅助脚本生成包含测试所需数据的 Dart 源码。

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
- 数据准备不操作设备、不启动 App、不执行 SDK 初始化或登录，不擅自重置服务端业务状态。

## 文件命名与存放

- Dart 源码和辅助脚本按职责使用 `snake_case` 命名，例如 `scripts/generate_accounts.dart`，不带运行日期。
- 生成入口固定为 `lib/accounts.g.dart`；本轮实际使用的数据副本及临时数据放在 `tmp/<runId>/`，不覆盖其他轮次的数据。
- `runId` 遵循[执行用例的轮次规则](2026-11-06-test-execution-troubleshooting.md)。
