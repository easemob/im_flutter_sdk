# 空昵称返回差异会阻断用户资料订阅场景

- 日期：2026-11-09
- 状态：双端差异已复现；未修改 SDK 或用例
- 触发仓库：im_flutter_sdk，5.1.0 worktree
- 适用环境：Flutter 3.47.0、native 5.0.0，测试账号未设置昵称

## 结论

同一账号 `fetchOwnInfo` 在 Android 返回 `nickName: ""`，iOS 返回中缺少 `nickName`。资料订阅场景要求先获得可恢复的原昵称；iOS 因前置条件不满足而跳过核心步骤。步骤报告中的 9/9 通过只统计实际执行步骤，不能代表整例通过，必须同时检查必要验证和汇总结果。

## 现象与根因

iOS 两轮均只执行初始化、登录、连接、原资料查询和退出；查询数据含 `userId`、`gender`，没有 `nickName`。YAML 判断 `original_profile.nickName != null`，因此未执行订阅、更新、通知验证和恢复，必要绑定缺失，整例判定为否。

Android 同账号返回合法空字符串，完成 15/15 步并恢复空昵称。Dart `ChatUserInfo.toJson()` 只输出非 null 的 nickName；iOS `UserInfoHelper.m` 直接传递 native nickname，未补空字符串。观察确认当前双端返回有差异，不能据此推断其他 native 版本也相同。

## 处理方式

保留正确的恢复条件；不要把字段缺失强行变为空字符串，或把仅退出成功当作订阅验证成功。需要另行确认支持缺失昵称的业务契约或提供具备可恢复原昵称的测试账号后，再验证 iOS 的核心订阅流程。本轮目录整理不修改此行为。

## 排查命令备忘

在 `testing/multi/` 查看：

- `reports/<runId>/summary.md`：整例结论。
- `reports/<runId>/5.0.0-multi-user-info-subscribe-positive/1/flow-report.json`：`capture_profile.result.data` 与实际执行步骤。
- `tmp/<runId>/run.json`：必要绑定判定和故障记录，含私有数据，不提交。

轮次：iOS `20261109-141848-batch-127e26b1`、复验 `20261109-143444-user-info-subscribe-cf735883`；Android `20261109-143734-batch-6ddee280`。完整目录整理验证结果保留于历史提交 `33cfc60a`。
