# 测试目录整理验证

- 日期：2026-11-09
- 分支：5.1.0；基线提交：`5e6bc2b2`，验证对象为本次未提交目录调整。
- 工具链：Flutter 3.47.0、Dart 3.13.0；Flutter 包、Android Native、iOS Native 依赖仍为 5.0.0。
- 状态：本轮全量验证完成；非设备检查通过，设备失败与暂停项如下保留，不能宣称全绿。

## 修改边界

`testing_v2/` → `testing/multi/`；example 单设备脚本 → `testing/single/cases/`；报告工具 → `testing/single/auto_report.dart`。修正仓库定位、path 依赖、Makefile、脚本覆盖测试和文档链接；CI 入口与业务断言保持。31 个迁移的 YAML/JSON 文件逐字节一致。

## 非设备验证

| 检查 | 结果 | 日志 |
|---|---|---|
| 全部包分析、SDK 测试、映射／契约／版本检查 | 通过，66 项测试 | `/tmp/510-reorg-quality.log` |
| example 全部测试 | 112 项通过 | `/tmp/510-reorg-example.log` |
| flow_runner 分析及全部测试 | 91 项通过 | `/tmp/510-reorg-flow.log` |
| multi 分析及全部测试 | 243 项通过 | `/tmp/510-reorg-multi.log` |
| single 报告工具分析及自检 | 通过 | `/tmp/510-reorg-single.log` |
| Markdown 本地链接、迁移场景内容、忽略规则与 diff 空白检查 | 通过 | 本次本地检查 |

共 512 项自动化测试通过；不包含设备业务场景。

## CI 设备验证

双端分别执行 `bash tool/ci/smoke_local.sh <平台>` 和 `bash tool/ci/nightly_local.sh <平台>`；Nightly 使用已有测试应用配置，由脚本获取新 Token。

| 平台 | 未登录 17 项 | 登录态 30 项 | 证据 |
|---|---|---|---|
| Android / Pixel_9 | 16 通过、FL-MSG-006 失败 | 29 通过、FL-MSG-007 失败 | `artifacts/android-no-login-smoke.log`、`artifacts/android-single-account.log` |
| iOS / Simulator | 16 通过、FL-MSG-006 失败 | 29 通过、FL-MSG-007 失败 | `artifacts/ios-no-login-smoke.log`、`artifacts/ios-single-account.log` |

两端相同：未登录返回错误 201；登录后空接收人返回错误 500。错误码符合预期，但最终回调消息仍为 `PROGRESS`，正确断言要求 `FAIL`。与此前已知现象一致；本次未修改 SDK 版本或发送实现，保留断言。两端 Nightly 均记录 `CI suite cleanup: verified`。

## 平版设备验证

已执行全部 7 份现存单设备脚本的双端验证，以及双端各 11 个未暂停多设备场景。消息撤回按既有决定暂停，负向脚本中 missing-message 群回执崩溃场景保持停用，均不计为通过。

### iOS 多设备

- 首轮：`20261109-141848-batch-127e26b1`，11 例完成，10 通过、1 未通过；除用户资料订阅外均通过。
- 用户资料订阅复验：`20261109-143444-user-info-subscribe-cf735883`，相同结果。
- 两轮 `capture_profile` 均成功，数据只有 `userId`、`gender`，没有 `nickName`。YAML 要求存在可恢复昵称后才进入订阅和更新；条件不满足，核心操作未执行。已执行的初始化、登录、查询、退出共 9 步通过，但必要绑定缺失，所以整例未通过。
- 保留既有条件，不将缺失昵称转为空字符串，不修改账号资料来绕过失败。该例历史三轮通过记录来自 Android，不能据此宣称 iOS 已经通过。
- 原始报告在 `testing/multi/reports/<runId>/`，输入和原始事件在 `testing/multi/tmp/<runId>/`。

### Android 多设备

`20261109-143734-batch-6ddee280`：11/11 全部通过，任务故障 0。资料订阅 15/15，原昵称为合法空字符串，执行完毕后恢复成功。与 iOS 的返回差异见 [排查记录](../../refs/troubleshooting/2026-11-09-user-info-empty-nickname-platform-difference.md)。

用户确认：4.22、4.24 旧脚本的失败先不处理，仅保留执行结果，不作为本次目录整理的修复范围。

## 单设备脚本双端结果

全部通过 `make auto-report PLATFORM=<平台> DEVICE=<实例> SCRIPT=testing/single/cases/<文件>` 执行。以下统计按实际步骤，失败没有被忽略或改写预期。

| 脚本 | Android | iOS | 说明 |
|---|---|---|---|
| script_500_apis_positive | 20/20 | 20/20 | 通过 |
| script_500_apis_negative | 10/10 | 10/10 | 通过；已停用的 native 崩溃项不计入 |
| script_presence_detail | 4/4 | 4/4 | 通过 |
| script_422_apis | 14 通过、2 失败 | 14 通过、2 失败 | 语音转文字未开通，505；按用户决定先不处理 |
| script_424_apis | 1 通过、3 失败 | 1 通过、3 失败 | 搜索服务未开通、参数边界错误；按用户决定先不处理 |
| script_presence_issues | 8 通过、4 失败 | 8 通过、4 失败 | 超长状态／101 人订阅及退订返回 1100；无效消息翻译 Android 500、iOS 1。旧探查脚本没有配置错误预期，默认要求成功 |
| script_translate_fix | 0 通过、1 失败 | 0 通过、1 失败 | 无效消息翻译 Android 500、iOS 1；旧探查脚本没有配置错误预期 |

5.0.0 正向和负向报告分别执行 `make auto-compare`，两次均退出 0，双端结果一致。所有单设备运行均生成 `script.done` 和报告，无崩溃证据；原始结果保留在 Git 忽略的 `reports/5.0.0/`。

| 平台 | 脚本 | 报告 runId |
|---|---|---|
| android | script_422_apis.json | `20261109065044-android-emulator-5554` |
| android | script_424_apis.json | `20261109065116-android-emulator-5554` |
| android | script_500_apis_negative.json | `20261109065143-android-emulator-5554` |
| android | script_500_apis_positive.json | `20261109065206-android-emulator-5554` |
| android | script_presence_detail.json | `20261109065232-android-emulator-5554` |
| android | script_presence_issues.json | `20261109065302-android-emulator-5554` |
| android | script_translate_fix.json | `20261109065331-android-emulator-5554` |
| ios | script_422_apis.json | `20261109065355-ios-041C09C7-1870-407E-9DE9-B49F40A4AAF8` |
| ios | script_424_apis.json | `20261109065441-ios-041C09C7-1870-407E-9DE9-B49F40A4AAF8` |
| ios | script_500_apis_negative.json | `20261109065514-ios-041C09C7-1870-407E-9DE9-B49F40A4AAF8` |
| ios | script_500_apis_positive.json | `20261109065546-ios-041C09C7-1870-407E-9DE9-B49F40A4AAF8` |
| ios | script_presence_detail.json | `20261109065621-ios-041C09C7-1870-407E-9DE9-B49F40A4AAF8` |
| ios | script_presence_issues.json | `20261109065658-ios-041C09C7-1870-407E-9DE9-B49F40A4AAF8` |
| ios | script_translate_fix.json | `20261109065734-ios-041C09C7-1870-407E-9DE9-B49F40A4AAF8` |

## 结论与范围

目录迁移后的依赖解析、构建、安装、CI 入口、单／多设备执行和报告对比已验证。未发现由路径调整引入的失败，业务代码和所有场景断言保持原样。

保留问题为：CI 的 FL-MSG-006/007 回调状态、iOS 用户资料场景原昵称缺失、旧探查脚本与服务能力／默认预期不匹配，以及用户明确暂不处理的 4.22／4.24 失败。暂停场景未执行。目录任务完成不等于全部 SDK／历史用例无问题。

未创建新 skill，未新增业务用例；代码、文档与验证记录随本次提交保存，原始日志保持本地忽略，未推送。
