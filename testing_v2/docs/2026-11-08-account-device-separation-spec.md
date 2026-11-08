# 账号与设备独立管理规格

状态：已确认。本文定义账号选择、设备选择及其交接契约；其他执行规则沿用[执行规格](../../docs/spec/2026-11-06-testing-v2-spec.md)，协作遵循[规则与边界](../spec.md)。

## 1. 核心规则

1. 账号和设备分别选择、校验；数量和名称不要求相同。账号统一使用 `account1`、`account2` 等编号，用例不另行声明账号别名或数量。
2. YAML 的 `agents` 表示逻辑设备；`agent` 决定命令在哪台设备执行。账号由 JSON 命令参数选择，设备配置不携带账号。
3. 同一账号可以在多台设备登录，也可以只作为收件人等业务对象而不登录设备。工具不因选择了账号而自动登录。
4. 命令与参数保存在同一个 JSON 对象中；顺序、并发、等待及失败处理属于 YAML。解释器不分析 SDK API 含义或推断登录关系。
5. 实际账号、设备标识保存在 Git 忽略的 `config/`；`data/` 中的用例使用逻辑引用。配置生成器不改写用例，不生成包含实际账号的用例副本。
6. 账号配置与生成的 Dart 源码保持现有职责：前者提供生成输入，后者提供执行所需的账号与 Token；设备信息不进入账号源码。

## 2. 配置与引用

### 2.1 场景选择文件

`config/cases.json` 的每个用例独立包含账号映射和设备映射。例如同账号双设备消息同步：

```json
{
  "cases": [
    {
      "yaml": "../data/5.0.0-multi-message-device-sync-positive.yaml",
      "accounts": {
        "account1": "user_a",
        "account2": "user_b"
      },
      "devices": {
        "a1": {"platform": "android", "instance": "Pixel_9"},
        "a2": {"platform": "android", "instance": "Pixel_9_2"}
      }
    }
  ]
}
```

| 字段 | 契约 |
|---|---|
| `cases` | 有序、非空列表；按列表顺序执行。用例名和规范化源路径不得重复。 |
| `yaml` | 指向 `data/` 中的源用例；相对路径以选择文件所在目录为基准。 |
| `accounts` | `{account1: 实际账号ID, account2: 实际账号ID, ...}`；非空，编号从 1 连续递增，不限定数量。ID 须存在于执行时固定的账号数据中；不保存 Token。 |
| `devices` | `{设备别名: {platform, instance}}`；键集合与 YAML `agents` 完全一致。`platform` 为 `android` 或 `ios`，`instance` 为 AVD 名或 iOS UDID。 |

账号编号与设备别名是两个独立命名空间。设备别名遵循 `[A-Za-z_][A-Za-z0-9_]*`；即使与账号编号同名也不建立绑定。每个账号编号对应不同的实际账号；同一账号被多个步骤或设备使用时，引用同一个编号。同一用例不同设备别名必须对应不同的 `(platform, instance)`。

映射仅在当前用例内生效；多个用例可以复用账号和设备。手工调整配置后仍须通过相同校验，运行时不按列表位置补齐缺失映射。

### 2.2 用例 JSON

命令直接引用账号编号，无需账号声明：

```json
{
  "data": {
    "unique": {"messageContent": "device-sync-"}
  },
  "steps": [
    {
      "id": "login_account1",
      "api": "ChatClient.loginWithToken",
      "params": {
        "userId": "$global.account.account1.userId",
        "token": "$global.account.account1.userToken"
      }
    },
    {
      "id": "send",
      "api": "ChatManager.sendMessage",
      "params": {
        "to": "$global.account.account2.userId",
        "chatType": 0,
        "isNeedReadReceipt": true,
        "body": {"type": 0, "content": "$global.biz.input.messageContent"}
      },
      "expect": {"success": true, "checks": [{"path": "msgId", "notEmpty": true}]}
    }
  ]
}
```

上例为命令节选，完整用例保留初始化、连接和设备身份核验、退出以及 `requiredBindings`。

- 账号由 `cases.json` 提供，命令直接使用；账号不经由 `data.input` 注入，业务常量、唯一值及准备声明仍使用既有 `data` 结构。
- `selection` 为可选项，仅接受非空的 `disabledReason` 暂停原因，普通用例无需此项。生成清单时默认跳过暂停用例并输出原因，显式选择则报错；执行入口同样拒绝已暂停用例。消息撤回场景继续保持暂停。

生成器提供选定的全部账号，不分析命令来裁剪账号列表，也不根据设备数量推断账号需求。用例可以只使用其中一部分；读取不存在的账号编号时，按 §4 拒收。

### 2.3 YAML 使用

以下为已完成设备初始化后的流程节选，展示同一个登录命令在两台设备执行；不是完整测试用例：

```yaml
agents:
  a1: {script: 5.0.0-multi-message-device-sync-positive.json}
  a2: {script: 5.0.0-multi-message-device-sync-positive.json}
steps:
  - cmd: login_account1
    agent: a1
    as: global.biz.result.a1_login
    onFail: abort_flow
  - cmd: login_account1
    agent: a2
    as: global.biz.result.a2_login
    onFail: abort_flow
  - cmd: send
    agent: a1
    as: global.biz.result.sent
    onFail: abort_flow
  - wait_event: onMessagesReceived
    agent: a2
    checks:
      - path: messages
        containsItem:
          msgId: '$global.biz.result.sent.data.msgId'
          from: '$global.account.account1.userId'
          to: '$global.account.account2.userId'
          body.type: 0
          body.content: '$global.biz.input.messageContent'
    as: global.biz.event.synced
```

这里 `a1/a2` 均执行 `login_account1`，因此登录同一个账号；`account2` 只提供收件账号 ID，不要求第三台设备。不同账号分别登录两台设备时，YAML 在各设备执行引用相应编号的登录命令即可。

运行时引用规则：

| 引用 | 来源与含义 |
|---|---|
| `$global.account.accountN` | `N` 从 1 开始；数据模块按本用例的 `accounts` 选取 `{userId, userToken}`，只读。 |
| `$global.device.<设备别名>` | 设备及启动结果提供 `platform/instance/deviceId/instanceId`；只读，不包含账号或登录状态。 |
| `$global.biz.*` | 沿用既有初始化配置、业务输入、命令结果及事件绑定规则。 |

登录成功不会改写账号或设备映射；当前登录状态以 SDK 调用结果和事件为依据。引用缺失时明确报错，不退回其他账号或设备，不发送参数未解析完整的命令。

## 3. 配置生成

保持两个配置生成入口：

| 入口 | 输入 | 输出与职责 |
|---|---|---|
| `scripts/generate_accounts_input.dart` | example 配置或显式来源 | 生成 `config/accounts-input.json`；保留已有配置及显式覆盖规则。 |
| `scripts/generate_cases.dart --platform <platform>` | 账号配置、设备发现结果、`data/` 用例；平台为 `android` 或 `ios` | 生成 `config/cases.json`；只选择资源，不获取 Token、启动设备或执行 SDK 操作。 |

`generate_cases.dart` 的分配规则：

1. `--case` 可重复，不传则遍历 `data/` 并按文件主名排序；传入时按指定顺序选择。暂停规则按 §2.2 执行。
2. `--account` 可重复，用于选择和排列账号池；不传则沿用账号配置顺序。按所选顺序生成 `account1` 至 `accountN`，将完整账号映射写入每个用例；不需要用例提供账号声明。
3. `--instance` 可重复，用于选择和排列设备池；不传则复用设备模块发现指定平台的模拟器，按 `instance` 排序。每个用例独立按 YAML `agents` 声明顺序分配设备。
4. 账号池必须非空，设备池必须足够分配 YAML 的全部 `agents`；不限定为两个。重复或指定值不存在时失败，不循环复用资源来凑数。多余设备不写入该用例的映射；账号全部保留，引用是否存在按 §4 校验。
5. 全部所选用例及映射校验通过后，原子替换 `config/cases.json`；失败保留原文件并返回非零退出码。重复生成不会读取旧映射来隐式合并。
6. 生成期间不写入 `data/`，不创建 `config/case-data/` 或其他持久化用例副本；查询日志留在 `tmp/`，静态校验的临时副本在结束时删除。配置不参与运行清理。

`scripts/generate_accounts.dart` 继续负责获取 Token 并生成 `lib/accounts.g.dart`。配置生成成功不代表账号凭据或设备已就绪，运行前仍须验收。

## 4. 模块交接与拒收

| 交接 | 上游交付 | 接收方必须校验 |
|---|---|---|
| 配置 → 编排层 | `yaml/accounts/devices` | 字段和路径有效；账号编号连续，设备键集合等于 `agents`；两类集合分别校验，互不比较；配置及映射验收通过后才能开始设备或业务操作。 |
| 编排层 → 数据模块 | 固定账号数据、账号映射、用例定义、执行序号 | 账号 ID 存在且不重复，ID/Token 为非空字符串且与本轮数据一致；交付 `CaseData.accounts`，键为 `account1` 至 `accountN`。数据模块不接收或校验设备选择。 |
| 编排层 → 设备模块 | 平台及 `instance` | 设备存在且可操作，交付实际 `deviceId`；构建与启动沿用既有契约，不接收账号。 |
| 数据/设备/启动 → 执行模块 | `CaseData`、设备结果、`LaunchResult` | 轮次与用例归属一致；账号与固定映射一致；设备及连接集合等于 `agents`；设备不同、连接可用。禁止要求账号集合等于设备集合。 |
| 前置声明 → 数据模块 | YAML `preconditions`、JSON `data.prepare` | `contacts.between` 使用账号编号，例如 `[account1, account2]`，须存在且解析为两个不同账号；准备授权、状态核验及重复/冲突检查沿用既有规则。 |
| 数据引用 → 求值及命令派发 | `$global.account.accountN` | 读取时检查编号和字段存在；缺失属于配置错误，终止依赖步骤，拒绝发送未解析完整的命令，不记录为 SDK 调用失败。 |

`flow_runner` 对前置声明只校验结构、名称格式及支持的状态，不将账号编号当作 `agents` 校验。实际账号及前置声明引用的校验由 `testing_v2` 数据模块在业务准备或执行前完成；解释器不承担账号管理或 REST 操作。生成成功只说明清单和映射合格，不表示所有运行时引用已被求值。

建轮时，编排层将两份映射连同账号数据和用例定义固定到现有 `tmp/<runId>/` 状态中；分环节操作读取同一份数据，不重新分配。运行用例副本仍用于固定本轮定义，不向其中写入实际账号。修改配置或用例后须新建轮次。

资源故障隔离使用设备映射中的实际设备，以及账号映射中的全部实际账号，包含未登录账号；不能再从设备推导账号集合。拒收时记录用例、阶段、字段、预期、实际及返工环节，凭据脱敏；保留报告和安全收尾能力。

## 5. 实施边界

涉及现有配置生成器、`testing_v2` 的数据模块、CLI 编排、执行准入、相关测试和用例引用；`tool/flow_runner` 仅涉及前置声明的校验职责及配套测试、文档。设备操作、构建安装、HTTP 协议、控制流调度和 SDK 公开接口沿用现有实现。

不新增辅助脚本或目录。用例只调整账号引用及必要的登录命令复用，移除额外的账号声明；保留场景目标、事件关联、核心断言和业务清理。同步 README、数据准备、用例编写及执行规格中的相关契约。

新建轮次只接受本文配置形状；混合 `roles` 结构、`selection.accounts` 或 `accountInputs` 的输入明确拒收，提示按本文规则调整，不隐式转换。既有轮次保留报告和清理入口；执行及复验使用新建轮次，不在旧快照中补写新映射。未被本次生成器使用的本地文件不自动删除。

## 6. 验收

| 验证项 | 通过条件 |
|---|---|
| 不同账号、不同设备 | 两账号分别登录两设备，Presence 发布与通知断言保持通过。 |
| 同账号、多设备 | 一账号在两设备登录，同账号建群同步场景通过；不要求补一个账号。 |
| 未登录账号参与业务 | 两设备登录 `account1`，发送给 `account2` 并收到同步事件；无第三设备、无收件账号占位值或用例副本。 |
| 数量及名称独立 | 自动化测试覆盖三账号两设备、一账号三设备，以及账号编号与设备别名完全不同；允许配置包含用例未使用的账号。 |
| 生成与拒收 | 覆盖默认和显式顺序、设备不足、账号为空/重复/不存在、编号不连续、前置引用错误、暂停用例、旧格式拒收；生成失败不覆盖已有配置，交接失败不启动依赖操作。 |
| 运行时账号缺失 | 命令引用未配置的 `accountN` 时报告配置错误，不发送该命令、不替换账号、不计作 SDK 失败。 |
| 轮次与隔离 | 修改源配置不影响已固定数据；未登录账号同样参与故障隔离；分环节与全流程使用相同映射。 |
| 回归与证据 | 相关 Dart 静态检查、`testing_v2` 和 `flow_runner` 测试通过；全部未暂停用例完成静态装载和数据契约校验。前三类真实场景各选择一个平台连续验证三轮，保留原始结果与清理证据。 |

验证失败须区分配置、用例、工具、环境及 SDK 原因，不放宽正确断言。消息撤回场景不参与设备验证。
