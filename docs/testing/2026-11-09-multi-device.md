# 多设备平版测试

目标需要另一运行中客户端时使用：消息接收与回执、好友申请与接受、群通知、Presence、用户资料订阅及同账号多端同步。使用完成目标所需的最少设备。

## 设计规则

- YAML 表达流程，配对 JSON 保存命令、数据和必要验证；用例位于 `testing/multi/data/`。
- 账号与设备分别映射，不硬编码账号、Token 或模拟器。不同账号交互和同账号多端同步必须明确区分。
- 按业务因果组织步骤，以本轮消息 ID、群 ID、申请理由等关联事件。批量事件必须在同一元素内匹配关联条件。
- 目标包含通知时检查实际通知，发起端成功或查询结果不能替代。目标包含本地状态时可以查询本地列表。
- 好友申请经对方接受后，仅检查双方本地联系人列表包含对方；不额外要求添加前或删除后本地列表状态。
- 准备不能替代被测业务，例如不能通过 REST 预建好友再声称验证了好友申请。
- 业务收尾与工具收尾分别核查；保留失败与复验证据。消息撤回当前暂停，不能计为通过或自动恢复。

## 使用

`all`、单场景 `run` 和 `report` 都在 `testing/multi/reports/<runId>/` 自动生成 Git 忽略的正式报告 `upgrade-report.md/json`，终端打印完整路径。以完整协同场景统计，步骤和尝试次数另计；报告包含角色、核心断言、设备会话收尾、业务资源销毁/登出操作与原始证据链接。多次运行及单设备结果可显式合并，规则见[测试报告](2026-11-09-reports.md)。

进入 `testing/multi/`，生成账号输入、账号源码与场景选择，再执行：

```bash
dart run bin/cli.dart all --cases config/cases.json --data-input config/accounts-input.json
```

`all` 是执行全部环节，实际用例范围由选择文件决定。详细配置与命令见 [多设备工具](../../testing/multi/README.md)，语法见 [用例编写](../../testing/multi/docs/2026-11-06-test-case-authoring.md) 和 [flow_runner](../../tool/flow_runner/README.md)。查看 `reports/<runId>/summary.md` 和 `statistics.csv`，再按步骤报告定位失败。
