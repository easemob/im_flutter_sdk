# Example 测试体系

集中管理 example 人工／自动化测试相关的规范、skill、工具、脚本和运行产物。

## 文档索引

- [测试体系规格](../docs/spec/2026-11-04-example-testing-spec.md) — 生命周期、目录、脚本规范、失败铁律（2026-11-05 重写）
- [实施计划](../docs/plan/2026-11-04-example-testing-plan.md) — P1–P7 任务清单与依赖
- [控制流解释器规格](../docs/spec/2026-11-05-flow-interpreter-spec.md) — 多设备 YAML 流程语言与宿主运行器
- [HTTP 控制协议](spec/2026-11-04-phase-control.md) — 设备 agent 会话、命令与事件接口
- [覆盖映射](spec/2026-11-04-coverage.md) — 旧 30 步脚本到新用例的去向
- [HTTP 方案审查记录](spec/2026-11-04-http-review.md) — 历史审查背景
- [现有 example 使用说明](../im_flutter_sdk/example/README.md) · [环境准备流程](../CONTRIBUTING.md)

实施分为四阶段：实现并实际执行、复验和分析 → 用户亲自人工抽验 → 另议旧内容清理与 CI 关系 → 根据已跑通流程沉淀三个 skill（用例生成、用例执行、问题排查）并复跑验证。

执行铁律：不得因 SDK 缺陷修改正确用例、放宽断言或跳过失败；仅暂停受影响的执行链，无关用例继续，逐项复验分析并保留证据。

## 当前可用入口

以下命令从 `5.0.0` 工作树根目录运行：

```bash
make config                    # 生成 testing/config/environment.local.json（首次从旧 example 配置导入）
make env-gettoken              # 换取 Token 写 example/lib/env.dart
make env-gettoken RUN_ID=x     # 额外生成隔离运行环境 tmp/<run-id>/main/environment.json
dart run testing/tools/data/resources.dart prepare-group <run-id>   # 创建临时群并记录归属
dart run testing/tools/data/resources.dart cleanup-group <run-id>   # 清理本次创建的群

make auto-report PLATFORM=android [DEVICE=...] [SCRIPT=...]         # 单设备直跑 + 报告（现有路径，保留）
make auto-compare ANDROID=<run-dir> IOS=<run-dir>                   # 双端结果对比
```

- 配置位于 `testing/config/environment.local.json`；首次 `make config` 从旧 `example/config.local.json` 导入一次、不覆盖，之后编辑新位置。旧工具保留至第三阶段清理，不要同时编辑两份配置。
- `RUN_ID` 环境含 User Token、不含 clientSecret/App Token，仅供运行时使用。资源工具只清理本次创建且归属明确的临时群；创建状态未知时停止重试并要求检查。
- `tmp/`、`reports/`、本地配置被 Git 忽略。证据归档到 reports 后才可删除对应 tmp；当前尚无自动归档工具，不应删除唯一的资源归属记录。
- 人工使用保持 `cd im_flutter_sdk/example && flutter run -d <device>`。新增可搜索 API 入口：`loadMessage`、`getJoinedGroups`、`fetchGroupInfoFromServer`、`getCurrentDeviceId`、`isConnected`。

## 当前进度（2026-11-05）

多设备编排已定由宿主端控制流解释器承担（AI 主／子代理方案废弃，coordination 文档已移除）。

| 模块 | 状态 |
|---|---|
| 数据工具（environment / resources 薄入口） | ✅ 可用；本地配置导入、运行环境 JSON、资源归属测试通过 |
| 单设备断言增强（checks / failureKind / skip） | ✅ 已实现；example flutter test 25/25 |
| registry 新增 5 个 API 入口 | ✅ 可用（人工与脚本共用） |
| 控制流解释器 `tool/flow_runner` | ✅ v0.1 实现完成；48 个单测全绿，尚未接真实设备 |
| 设备 agent（App 内 HTTP 服务） | ❌ 未实现（phase-control 协议已定稿） |
| 设备批量管理 / 端口转发 | ❌ 未实现（复用 auto_report 能力扩展） |
| 单设备用例迁移（scripts/5.0.0/single） | ❌ 未开始（覆盖映射已就绪） |
| 多设备用例（flows/：M2 单聊回执 → M3 群回执 → M1 数据同步） | ❌ 未开始 |
| 设备验证 | ❌ 未开展 |

本轮基础检查（2026-11-04）：example `flutter test` 25/25；`auto_report --self-test` 通过；数据工具及报告 `dart analyze` 无问题；`FORMAT_BASE_SHA=HEAD bash tool/ci/run_quality.sh` 通过。以上不是第一阶段整体验收。
