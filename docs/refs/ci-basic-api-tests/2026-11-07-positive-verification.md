# CI 基础 API 正向用例验证

日期：2026-11-07。分支：`testing`。状态：正向用例已实现，验收未完成；账号隔离方案待确认，新增逆向用例尚未开始。

依据：[规格](../../spec/2026-11-07-ci-basic-api-tests-spec.md)、[筛选范围](2026-11-07-api-selection.md)、[用例映射](../../../im_flutter_sdk/docs/ci/native-case-mapping.json)。

## 实现范围

保留两个主入口，按客户端、联系人、群组、会话、消息分模块注册。共 28 个用例：22 个登录后正向用例、1 个冷启动初始化用例、5 个既有未登录 Presence 逆向用例。保留原 13 个编号，新增 15 个编号。

测试输入通过本轮临时 dart-define JSON 传递；Token 通过 REST 自动获取，客户端密钥不进入测试 App。

登录准备显式配置 `contacts | joinedGroups`，登录前注册同步监听，等待两类同步完成及连接可用。REST 关系准备和恢复后重新登录同步；SDK 删除操作后的结果验证保持同一登录会话。资源恢复失败会使该例及整轮失败。前期验证创建的 16 个群及下述最新复验创建的 6 个群，均已在收尾后逐个经 REST 核验不存在；临时 Token 配置已删除，日志未检出原始 Token。

## 设备结果

Flutter 3.47.0；Android `emulator-5554`；iPhone 16 Pro `4BEA133B-4B24-430F-96FC-924632C2CF53`，最新复验 runtime 为 iOS 18.2。登录执行端串行运行。前期结果：

| 平台与轮次 | 结果 | 边界 |
|---|---|---|
| Android 正向 r2、r3 | 每轮 22/22 通过 | 最终准备流程；关系、黑名单和群资源清理核验通过 |
| iOS 正向 r4 | 20 通过、2 准备失败 | `FL-CONTACT-002/003` 检测到已有 peer 消息，在执行删除 API 前停止；其余用例及清理通过 |
| Android 未登录基线、r2 | 每轮 6/6 通过 | 初始化及既有 5 个 Presence 逆向 |
| iOS 未登录基线、r2 | 每轮 6/6 通过 | 初始化及既有 5 个 Presence 逆向 |

逐例预期、实际结果、阶段和日志位置见 [CSV](2026-11-07-positive-case-results.csv)。日志在工作树 `artifacts/ci-basic-*.log`，不纳入 Git。实际执行编号按日志核对映射，不仅依赖映射检查。

### 最新复验：20261107-1950

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

## 当前阻塞

`FL-MSG-001` 向固定 peer 发送真实消息。iOS 后续登录时读到了前轮带有 `ciCase: FL-MSG-001` 的消息；即使本轮未开启 conversations 自动同步，也不能保证 peer 会话为空。删除用例不能删掉不属于本例的消息，因此保留保护并失败。

待确认的数据方案：每轮创建并回收临时 peer；或给联系人删除分配独立的固定账号，与消息收件人分开。当前尚未接入新账号生命周期，也未改 nightly 的凭据准备步骤；现有 nightly 凭据文件不足以运行扩充后的入口，不能将本分支作为已完成的 CI 配置发布。

iOS wrapper 将 `keepConversation` 原样传入 native `isDeleteConversation`，仍是静态疑点。最新轮次没有执行到删除操作，不能宣称已设备复现。早期轮次删除后的本地列表异常也应保留证据；补足隔离前，不做 SDK 归因或修改。

用户确认相关删除行为属于 SDK 5.0 已知问题，预计 5.1 修复，并决定保持用例现状、iOS 失败留待后续处理。该版本信息来自用户；本轮两项实际失败仍归为准备失败，未跳过用例，也未修改 SDK。

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

iOS 将执行脚本替换为 `run_ios_simulator_test.sh`。未解决隔离问题前，准备失败应保留，不手工删除历史绕过保护。运行结束删除含 Token 的本地配置，保留脱敏日志。

静态检查、用例映射检查、21 项 CI 检查器测试及 38 项 REST fixture 测试通过。SDK 代码未修改；正向验收未完成，新增逆向阶段尚未开始。
