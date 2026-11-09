# iOS 模拟器启动时拒绝加载未签名动态库

- 日期：2026-11-07
- 状态：已修复；双 iOS Presence 完整验证通过
- 触发仓库：`im_flutter_sdk`，`testing` 分支
- 适用环境：Flutter 3.47.0、Xcode 26.2、arm64 iOS 18.2 模拟器

## 结论

`flutter build ios --simulator --debug --no-codesign` 可以编译成功，但本次生成的 HyphenateChat 动态库没有签名，App 在 Dart 入口前被 dyld 终止。本环境需要保留模拟器默认的本地 ad-hoc 签名，该签名不需要真机开发证书。

## 现象与根因

`simctl launch` 返回 PID 和退出码 0，随后进程立即退出；控制服务没有就绪日志。崩溃报告摘要为 `Library not loaded`，容易误判为动态库未打包。完整启动控制台指出实际原因是 `Trying to load an unsigned library`。

原始构建、自有副本及已安装 App 都包含该动态库，且均未签名；并非复制遗漏。Flutter 工具将 `--no-codesign` 转为 `CODE_SIGNING_ALLOWED=NO` 和 `CODE_SIGNING_REQUIRED=NO`。本机模拟器 SDK 默认允许 ad-hoc、签名标识为 `-`；另一台已有可运行 App 的对应库使用 ad-hoc 签名。

## 处理与排查命令

移除 `--no-codesign`，恢复模拟器默认本地签名；构建交付、导入及安装前检查整个 App 的签名。重新构建并登记新产物，不能修改旧产物后绕过摘要检查。

```bash
flutter build ios --simulator --debug --dart-define=API_CONTROL=true
codesign --verify --deep --verbose=2 <Runner.app>
codesign --verify --verbose=2 <Runner.app>/Frameworks/HyphenateChat.framework/HyphenateChat
codesign -dv <Runner.app>/Frameworks/HyphenateChat.framework/HyphenateChat
xcrun simctl launch --console <UDID> com.example.example
```

控制台可能含配对凭据，保存前须脱敏。失败证据：`tmp/20261107-101724-presence-c4c1eca8/diagnostic-launch-console.log`、同目录的 `launch-11-alice-host.json`；宿主崩溃记录 `~/Library/Logs/DiagnosticReports/Runner-2026-11-07-102232.ips`。

## 对照验证

1. 同一未签名 App 分别由 Dart、Bash 和原有启动脚本启动，均在 dyld 阶段失败；实际 Flutter、xcrun 路径及相关环境一致，排除了本次故障由调用方式差异引起的假设。
2. 仅去掉构建参数 `--no-codesign`，整个 App 签名校验通过，HyphenateChat 显示 `Signature=adhoc`、`TeamIdentifier=not set`。
3. 重新安装后，Dart 和 Bash 均能启动，HTTP 握手返回 `version: 2`、`platform: ios`、`state: accepting`，且实例 ID 不同。

对照证据位于 `tmp/20261107-launch-shell-probe/`：`results.json`、`existing-bash-result.json`、`build-default-signing.log`、`default-signing-results.json`。这些实验仅证明启动恢复；Presence 业务结果须另看完整用例报告。

## 完整用例验证

在 `testing/multi/` 执行：

```bash
dart run bin/cli.dart all --cases tmp/20261107-presence-input/cases-ios.json
```

轮次 `20261107-110031-presence-8a6c4bcb` 使用 iOS 18.2／18.1 两台 iPhone 16 模拟器，新建 `build-5` 产物并安装，CLI 退出码为 0；Presence 用例 16 步全部通过，无任务故障。A 的 `onPresenceStatusChanged` 原始事件 `seq=29` 与 B 发布的本轮唯一状态值匹配；取消订阅、恢复原状态、双方退出及 HTTP 收尾均成功。

- 汇总及统计：`reports/20261107-110031-presence-8a6c4bcb/summary.md`、同目录 `statistics.csv`。
- 步骤报告：同目录 `5.0.0-multi-presence-positive/1/flow-report.json`。
- 原始回调：`tmp/20261107-110031-presence-8a6c4bcb/5.0.0-multi-presence-positive/1/alice-events.jsonl`。

构建参数及签名验收的 5 项回归通过，完整测试共 137 项通过，`dart analyze` 通过。用例和 SDK 业务代码未修改。
