# 多设备协同测试用例

本目录保存多设备多账号测试用例：每个场景一个 YAML（流程与角色定义）配一个同名 JSON（命令、数据与断言），文件名格式 `<引入版本>-multi-<场景>-positive`。

用例由独立仓 **im-test-orchestrator**（与本仓库同级的单独 git 仓库）编排执行，本仓库经薄封装入口调用：

```bash
scripts/multi.sh generate --platform android   # 生成场景选择配置
scripts/multi.sh all --cases <选择配置>          # 全流程执行
```

账号准备、设备要求、场景清单与排查记录见 im-test-orchestrator 仓的 `multi/README.md`；用例编写语法见其 `docs/case-authoring.md`。执行报告默认生成在 orchestrator 仓的 `multi/reports/<runId>/` 下。
