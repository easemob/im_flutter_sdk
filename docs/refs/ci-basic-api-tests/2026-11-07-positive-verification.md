# CI 基础 API 正向用例验证

日期：2026-11-07。分支：`testing`。状态：删除用例已收敛为 API 成功返回，本轮 Android、iOS 正向套件各 22/22 通过；新增逆向用例尚未开始。

依据：[规格](../../spec/2026-11-07-ci-basic-api-tests-spec.md)、[筛选范围](2026-11-07-api-selection.md)、[用例映射](../../../im_flutter_sdk/docs/ci/native-case-mapping.json)。

## 实现范围

保留两个主入口，按客户端、联系人、群组、会话、消息分模块注册。共 28 个用例：22 个登录后正向用例、1 个冷启动初始化用例、5 个既有未登录 Presence 逆向用例。保留原 13 个编号，新增 15 个编号。

测试输入通过本轮临时 dart-define JSON 传递；Token 通过 REST 自动获取，客户端密钥不进入测试 App。

登录准备显式配置 `contacts | joinedGroups`，登录前注册同步监听，等待两类同步完成及连接可用。联系人查询用例在 REST 关系准备和恢复后重新登录同步；删除用例只准备好友关系并等待删除 API 成功返回，不等待本地列表、通知或会话变化。资源恢复失败会使该例及整轮失败。前期验证创建的 16 个群、`20261107-1950` 复验的 6 个群及参数修复后复验的 2 个群，均已逐个经 REST 核验不存在；临时 Token 配置已删除，日志未检出原始 Token。

## 设备结果

Flutter 3.47.0；Android `emulator-5554`；iPhone 16 Pro `4BEA133B-4B24-430F-96FC-924632C2CF53`，最新复验 runtime 为 iOS 18.2。登录执行端串行运行。前期结果：

| 平台与轮次 | 结果 | 边界 |
|---|---|---|
| Android 正向 r2、r3 | 每轮 22/22 通过 | 最终准备流程；关系、黑名单和群资源清理核验通过 |
| iOS 正向 r4 | 20 通过、2 准备失败 | `FL-CONTACT-002/003` 检测到已有 peer 消息，在执行删除 API 前停止；其余用例及清理通过 |
| Android 未登录基线、r2 | 每轮 6/6 通过 | 初始化及既有 5 个 Presence 逆向 |
| iOS 未登录基线、r2 | 每轮 6/6 通过 | 初始化及既有 5 个 Presence 逆向 |

逐例预期、实际结果、阶段和日志位置见 [CSV](2026-11-07-positive-case-results.csv)。日志在工作树 `artifacts/ci-basic-*.log`，不纳入 Git。实际执行编号按日志核对映射，不仅依赖映射检查。

### 复验：20261107-1950

| 平台与轮次 | 结果 | 原始日志（相对工作树根目录） |
|---|---|---|
| Android 未登录 | 6/6 通过 | `artifacts/ci-basic-android-smoke-20261107-1950.log` |
| iOS 未登录 | 6/6 通过 | `artifacts/ci-basic-ios-smoke-20261107-1950.log` |
| Android 正向首轮 | 21 通过、1 收尾失败 | `artifacts/ci-basic-android-positive-20261107-1950.log` |
| iOS 正向 | 20 通过、2 准备失败 | `artifacts/ci-basic-ios-positive-20261107-1950.log` |
| Android 正向复验 | 22/22 通过 | `artifacts/ci-basic-android-positive-20261107-1950-r2.log` |

- Android 首轮 `FL-CONTACT-003` 删除断言通过，恢复关系后重新登录的联系人同步返回 `type=2, errorCode=300`，导致收尾失败。复验未重现，根因尚未确认，原失败保留。
- iOS `FL-CONTACT-002/003` 检测到 2 条带 `ciCase: FL-MSG-001` 的已有发送消息，准备阶段保护性停止，未调用 `deleteContact`。
- 本轮通过临时命令获取 Token 并补齐运行配置，再调用既有 Bash 执行脚本；这是本地设备验证，未验证完整 Nightly 准备链路，也未运行云端 CI。
- CSV 追加本轮 78 条，合计 168 条。6 个群的销毁核验及日志凭据检查证据保存在 `reports/ci-basic-api/20261107-1950/cleanup-verification.json`，不纳入 Git。

### 参数修复后复验：20261107-delete-fixed

用户将 iOS wrapper 的参数改为 `!keepConversation` 后重新编译，以独立临时 peer 运行；正式用例代码和断言未修改。

| 范围 | 结果 | 日志（相对工作树根目录） |
|---|---|---|
| 两个参数的专项诊断 | 2/2 通过，关系、会话及本地联系人均符合预期 | `artifacts/delete-contact-fixed-ios-20261107-probe.log` |
| iOS 正向套件 | 20 通过、2 验证失败 | `artifacts/ci-basic-ios-positive-20261107-delete-fixed.log` |

`FL-CONTACT-002/003` 均准备成功并执行了删除 API，服务端关系删除核验通过，`true` 正确保留会话及消息，`false` 正确删除会话；随后本地联系人 ID／记录在 30 秒后仍存在，故记为 `failed / verify / targetExecuted=true`。整轮收尾通过，2 个临时群及临时 peer 已回收、原好友集合恢复。CSV 追加正式套件 22 条，合计 190 条；专项结果与清理证据位于 `reports/ci-basic-api/20261107-delete-contact-fixed/`。旧失败保留，不以本轮替换。

### 范围调整后复验：20261107-delete-api-success

使用配置中的已有测试账号及新获取的 Token，经原有 `tool/ci/run_*_test.sh` 串行执行完整正向入口。

| 平台 | 结果 | 日志（相对工作树根目录） |
|---|---|---|
| Android | 22/22 通过 | `artifacts/ci-basic-android-positive-20261107-delete-api-success.log` |
| iOS 18.2 | 22/22 通过 | `artifacts/ci-basic-ios-positive-20261107-delete-api-success.log` |

两端 `FL-CONTACT-002/003` 均成功返回，好友关系与黑名单恢复通过；本轮 4 个临时群的清理断言通过。未创建新账号，临时 Token 文件已删除，日志未检出原始 Token。结果汇总位于 `reports/ci-basic-api/20261107-delete-api-success/results.json`；CSV 追加 44 条，合计 234 条。静态分析、用例映射及差异格式检查通过。

这是调整后各一轮的实际结果，不代表本地同步异常已修复，也不据此推算长期稳定率。

## 当前范围与待完成事项

经用户确认，`FL-CONTACT-002/003` 只验证删除 API 成功返回，保留两个参数取值及原编号；不准备会话和消息，不核验 REST 删除结果、本地联系人、通知或会话。原好友关系和黑名单仍恢复并核验，删除用例收尾不再重新登录等待本地同步。其他联系人用例保留原验证范围。

iOS wrapper 参数取反已专项验证。旧用例因历史消息准备失败及本地同步超时失败的记录继续保留，范围调整不意味着这些异常已修复；本地同步异常也曾在 Android 诊断中出现，最终原因未闭环。

现有 Nightly 凭据文件仍不足以运行扩充后的入口，云端准备链路未验证；本次不修改该链路，不将本地设备通过等同于完整云端验收。

## 已处理的测试侧问题

- 集成测试的绑定由 Flutter 启动器创建；超时在每例显式设置，不能在入口重复构造绑定。
- 群不存在的实际响应为 HTTP 404、`service_resource_not_found`，描述须匹配指定群 ID；鉴权、网络、未知 404 均不能证明销毁成功。收尾先查询，已不存在不重复 DELETE。
- 两个消息更新用例原先附带了未确认的“省略属性即删除”假设；改为提交完整属性表、修改旧值并新增字段，再精确重读。省略属性的 Android 合并／iOS 替换差异保留为未裁定行为。
- 分页已验证精确集合、游标排除、末页和无重复；两端实测各页均按时间升序返回。检索方向与返回排序的文档含义仍需区分，本轮不宣称返回排序契约已裁定。

同步前提和历史隔离的排查细节见 [踩坑记录](../troubleshooting/2026-11-07-ci-contact-fixture-sync.md)。

## 本地复验

从工作树根目录执行，前提是已准备并核验完整的临时 dart-define JSON；现有 Bash 准备链路尚待补齐。复验时通过脚本第二个参数指定不同日志名，避免覆盖前轮记录：

```bash
E2E_CONFIG_PATH="$PWD/reports/ci-basic-api/local/e2e-config.json" \
  bash tool/ci/run_android_emulator_test.sh \
  integration_test/single_account_local_test.dart android-basic-r1.log
```

iOS 将执行脚本替换为 `run_ios_simulator_test.sh`。使用受控测试账号，运行结束删除含 Token 的本地配置，保留脱敏日志。

此前 21 项 CI 检查器测试及 38 项 REST fixture 测试通过；本轮静态与设备验证见上表。云端准备链路未验收，新增逆向阶段尚未开始。
