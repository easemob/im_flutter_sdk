# testing_v2 实现计划

依据：[执行规格](../spec/2026-11-06-testing-v2-spec.md)。契约调整须先确认；实现与测试均在 `testing/multi/`，不修改 SDK、example 或运行器的既有行为。

## 任务与验收

| 任务 | 交付 | 验收依据 | 状态 |
|---|---|---|---|
| P1 公共契约 | 严格类型、序列化、文件摘要、受限写入、脱敏、宿主命令接口 | §1.4、A19–A23 | 实现及自动化测试完成 |
| P2 数据 | 生成与加载账号、角色数据、声明式前置准备及核验 | A02、A13、A17、A18、A20 | 实现及自动化测试完成 |
| P3 设备与启动 | 模拟器管理、构建副本验收、日志发现、连接验收 | A03、A10、A14、A21 | 实现及自动化测试完成 |
| P4 执行 | 固定用例、必要绑定、直接调用解释器、超时收尾与证据 | A04、A11、A12、A15、A18、A22 | 实现及自动化测试完成 |
| P5 编排与 CLI | 轮次、互斥、阶段交接、故障及产物登记、分步与全流程入口 | A01、A05、A06、A09、A19 | 实现及自动化测试完成 |
| P6 汇报与清理 | 三类报告、对账、依赖保护、清理结果验收 | A07、A08、A16、A22、A23 | 实现及自动化测试完成 |
| P7 集成验收 | 上游实际产物交给下游；错误输入在副作用前拒收；使用说明 | A01–A23 | 自动化集成通过；真实双 iOS、双 Android Presence 用例通过 |

主代理验收各模块并组织集成；子代理交付不合格时退回修复。单元及模拟集成验证与实际设备验证分别记录，不以模拟结果代替实际设备结果。实现不自动提交。

## 必需实现约定

- 入口：`bin/cli.dart`；模块：`lib/src/`；测试：`test/`。
- 数据生成：`dart run scripts/generate_accounts.dart --input <JSON>`。加载时在私有临时目录生成只负责导入及序列化的 Dart 入口，捕获输出，不静态依赖生成源码。
- 设备：`devices list --platform <android|ios>`；`devices <inspect|start|stop|destroy> --platform <平台> --instance <实例>`；`install/uninstall` 显式指定同一目标，安装接收登记构建，卸载显式指定应用 ID。
- 构建：`build --platform <android|ios>`；`launch/all` 使用本轮登记的匹配构建，多个匹配结果须通过 `--build <操作标识>` 选择；外部构建通过 `--build-result <结果JSON>` 校验并复制到本轮。
- 同轮状态由编排层独占写入。专业模块不读写 `run.json`，只接收输入并返回结果。
- 有界操作使用可注入时限与宿主命令、HTTP 客户端；单元测试不操作真实设备或服务器账号。

## 任务依赖

- P1 → P2、P3、P4 的集成；模块内部实现可并行。
- P1–P4 → P5；P4、P5 → P6。
- P1–P6 → P7。

## 验证记录

- `dart test`：144 项通过，覆盖数据生成／加载、设备与构建、连接、执行生命周期、报告、清理及 CLI 交接，含 iOS 架构检测的 4 项、签名验收的 5 项及 Android 入口解析的 7 项回归；`dart analyze` 通过。
- 完整集成使用两个本地 HTTP 执行端及模拟宿主命令，实际组合各模块；覆盖全流程、重复汇报不重派命令、跨轮构建校验并复制。此结果不代替真实 SDK 验证。
- 实际宿主验证：iOS／Android 模拟器发现、iOS 就绪判据、两个平台的控制模式构建及自有副本验收通过。对应轮次在 `testing/multi/tmp/`：`20261106-224852-devices-5e56c889`、`20261106-225017-devices-56314e61`、`20261106-225403-build-1a68d406`、`20261106-225735-build-ad8398ea`、`20261106-230139-devices-61c4ca9a`。
- [Presence 正向用例](../../testing/multi/data/5.0.0-multi-presence-positive.yaml)双 iOS 完整验证通过：轮次 `20261107-110031-presence-8a6c4bcb`，iOS 18.2／18.1 两台 iPhone 16 模拟器，16 步全部通过，无任务故障。A 的原始事件 `seq=29` 证实收到 B 发布的本轮唯一状态值；查询验证、取消订阅、恢复状态、双方退出及 HTTP 收尾均成功。原始报告见 `testing/multi/reports/<runId>/`，事件与宿主日志见 `testing/multi/tmp/<runId>/`。本次验证一轮，不据此推断长期稳定率。
- 先前轮次 `20261107-101724-presence-c4c1eca8` 在业务执行前遇到架构检测及签名问题，保留失败记录；修复依据及对照实验见[架构检测记录](../../testing/multi/troubleshooting/2026-11-07-ios-simulator-architecture.md)、[签名故障记录](../../testing/multi/troubleshooting/2026-11-07-ios-unsigned-framework.md)。
- 双 Android 完整验证通过：轮次 `20261107-111925-presence-83fe79f6`，Android 15 / API 35 的 `Pixel_9`、`Pixel_9_2`，16 步全部通过，无任务故障。A 的原始事件 `seq=30` 与本轮发布值匹配，查询、业务恢复及双方收尾通过。前两轮在业务执行前分别被启动命令缺陷、模拟器连接无响应阻断，保留原结果；见 [Android 启动记录](../../testing/multi/troubleshooting/2026-11-07-android-launch-activity.md)及 [adb 连接排查](../../testing/multi/troubleshooting/2026-11-07-android-adb-transport-hang.md)。
- 使用入口：[testing/multi/README.md](../../testing/multi/README.md)。
