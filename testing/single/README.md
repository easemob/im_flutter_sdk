# 单设备平版测试入口

场景在 `cases/`，执行与报告工具为 `auto_report.dart`，共用 example 的 API 注册和脚本引擎。设计规则见 [单设备指南](../../docs/testing/2026-11-09-single-device.md)，JSON 语法和配置见 [example](../../im_flutter_sdk/example/README.md#script-mode-ai-friendly)。

所有命令从仓库根执行：

```bash
make config
make env-gettoken
make auto-report PLATFORM=android SCRIPT=testing/single/cases/script_500_apis_positive.json
make auto-report PLATFORM=ios SCRIPT=testing/single/cases/script_500_apis_negative.json
dart run testing/single/auto_report.dart --self-test
```

执行 `env-gettoken` 前填写 Git 忽略的 `im_flutter_sdk/example/config.local.json`。`DEVICE=<id>` 可指定模拟器，`SCRIPT=<json>` 可选择其他场景。不传脚本时运行 5.0.0 正向场景；报告固定在 Git 忽略的 `reports/5.0.0/<run-id>/`，复用脚本不等于覆盖当前版本所有变更。

先看 `summary.md`、`steps.json`、`issues.md`，再查 `events.jsonl` 和 `crash.log`。`make auto-compare ANDROID=<run-dir> IOS=<run-dir>` 比较相同脚本路径的双端结果。

负向 5.0.0 脚本中的 missing-message 群回执场景因已知 Android native 崩溃停用，报告会保留 candidate；不能把它计作通过。
