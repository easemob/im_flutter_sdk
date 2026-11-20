# 测试入口

设计与分类见 [测试指南](../docs/testing/README.md)。所有命令使用 Flutter 3.47.0 配套的 Dart。

| 目录 | 内容 | 入口 |
|---|---|---|
| `single/cases/` | 单设备平版 JSON 场景 | [单设备说明](single/README.md)；仓库根 `make auto-report` |
| `multi/cases/` | 多设备平版 YAML/JSON 场景 | [多设备说明](multi/README.md)；`scripts/multi.sh`（编排工具为独立仓 im-test-orchestrator） |
| `../im_flutter_sdk/test/` | SDK 单元与契约测试 | 仓库根 `bash tool/ci/run_quality.sh` |
| `../im_flutter_sdk/example/integration_test/` | CI 设备集成测试 | 仓库根 `bash tool/ci/{smoke,nightly}_local.sh <android|ios>` |

example 的 `lib/` 是共用执行端与人工界面；多设备编排工具为独立仓 im-test-orchestrator，经 `scripts/multi.sh` 调用。

## 全部非设备检查

在仓库根运行质量检查与单设备自检：

```bash
FORMAT_BASE_SHA=HEAD bash tool/ci/run_quality.sh
dart run testing/single/auto_report.dart --self-test
```

进入 `im_flutter_sdk/example/` 运行 `flutter test` 前，先完成依赖解析，再检查格式。

设备测试须另跑 CI 双端入口、所选单设备场景和多设备清单；不能用工具单测通过替代真实场景通过。本地配置、账号源码、日志与报告均保持 Git 忽略。
