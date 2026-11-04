# Example 测试体系

集中管理 example 人工／AI 测试相关的规范、skill、工具、脚本和运行产物。

已沉淀审查确认的规则和设计样例，工具和脚本尚未迁移；目标结构及样例不代表功能已实现。

- [Example 测试脚本与工具体系规格（已按审查结论更新）](../docs/spec/2026-11-04-example-testing-spec.md)
- [Example 测试体系实施计划（尚未实施）](../docs/plan/example-testing/2026-11-04-example-testing-plan.md)
- [多代理协同协议与脚本样例](../docs/spec/2026-11-04-example-testing-coordination.md)
- [现有 example 使用说明](../im_flutter_sdk/example/README.md)
- [现有环境准备与验证流程](../CONTRIBUTING.md)

实施分为四阶段：实现并由 AI 实际执行、复验和分析 → 用户亲自人工抽验 → 另议旧 AI 内容清理与 CI 关系 → 根据已跑通流程编写并验证新测试 skill（名称待定）。

执行铁律：不得因 SDK 缺陷修改正确用例、放宽断言或跳过失败；仅暂停受影响的执行链，无关用例继续，逐项复验分析并保留证据。
