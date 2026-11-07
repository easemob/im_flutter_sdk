# Android 已安装 App 无法通过包名启动

- 日期：2026-11-07
- 状态：已修复；双 Android Presence 完整验证通过
- 触发仓库：`im_flutter_sdk`，`testing` 分支
- 适用环境：Android 15 / API 35 模拟器，example targetSdk 36

## 结论

启动工具不能仅用 `am start -p <包名>` 启动 Launcher Activity。应先查询指定设备上该包的实际入口，校验组件属于目标应用，再通过 `-n <组件>` 显式启动。

## 现象与根因

APK 构建、安装和 `pm path` 均成功，但启动命令退出码为 1，错误位于 stdout：

```text
Error: Activity not started, unable to resolve Intent
```

example 的入口声明了 `MAIN/LAUNCHER`，未声明 `DEFAULT`。普通入口查询能够找到 `.MainActivity`，但按 `MATCH_DEFAULT_ONLY`（65536）查询没有匹配项；原启动命令依赖隐式 Intent 解析，因而失败。显式指定相同组件后启动成功，取得 App 进程 ID，证明无需修改 APK 或 SDK。

## 修法与排查命令

在启动模块查询、校验并显式启动入口；缺失、无效或属于其他包的解析结果须拒绝。不能硬编码 `.MainActivity`，也无需给被测应用添加 `DEFAULT` 来迁就工具。启动失败时同时检查 stdout 和 stderr。

```bash
adb -s <serial> shell cmd package resolve-activity --brief \
  -a android.intent.action.MAIN -c android.intent.category.LAUNCHER -p <包名>
adb -s <serial> shell cmd package resolve-activity --brief --query-flags 65536 \
  -a android.intent.action.MAIN -c android.intent.category.LAUNCHER -p <包名>
adb -s <serial> shell am start -W -n <查询得到的组件> \
  -a android.intent.action.MAIN -c android.intent.category.LAUNCHER
adb -s <serial> shell pidof <包名>
```

## 证据

失败轮次 `20261107-110848-presence-a39b0dc0` 尚未执行业务命令。证据位于 `testing_v2/tmp/<runId>/`：

- `launch-8-alice-install-host.json`：安装及产物检查成功。
- `launch-8-alice-host.json`：实际失败命令和 stdout 原文。
- `diagnostic-android-launch.json`：默认匹配无结果、隐式启动失败、显式启动成功的对照。

## 验证结果

启动模块已改为查询实际入口后显式启动；7 项回归覆盖入口类名变化、拒绝无效解析及错误原文保留。完整测试 144 项、静态检查通过。

完整复验命令（在 `testing_v2/` 执行）：

```bash
dart run bin/cli.dart all --cases tmp/20261107-presence-input/cases-android.json
```

轮次 `20261107-111925-presence-83fe79f6` 使用 Android 15 的 `Pixel_9` 和 `Pixel_9_2`，CLI 退出码 0，16 步全部通过；A 的原始事件 `seq=30` 命中 B 发布的本轮唯一状态值，查询、业务恢复、双方退出及 HTTP 收尾均成功。报告位于 `reports/<runId>/`，原始事件位于 `tmp/<runId>/5.0.0-multi-presence-positive/1/alice-events.jsonl`。

中间轮次 `20261107-111402-presence-3e6010e1` 遇到独立的 [adb 连接无响应](2026-11-07-android-adb-transport-hang.md)，保留该轮“未执行”结果；不能将它与入口解析缺陷混为一因。
