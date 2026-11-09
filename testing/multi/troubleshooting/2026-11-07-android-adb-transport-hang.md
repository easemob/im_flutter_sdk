# Android 模拟器显示 device，但 adb shell 与 HTTP 转发均无响应

- 日期：2026-11-07
- 状态：冷启动后恢复；底层失联原因未确定
- 触发仓库：`im_flutter_sdk`，`testing` 分支
- 适用环境：Android 15 / API 35、arm64 `Pixel_9` 模拟器

## 结论

`adb devices` 显示 `device` 不能证明连接仍然可用。HTTP 握手超时时先用有时限的 `adb shell echo` 区分设备连接故障与 App 服务故障；本次第一台 shell 同样超时，第二台正常，重连无效，指定设备冷启动后恢复。

## 现象与已确认边界

轮次 `20261107-111402-presence-3e6010e1` 中，App 显式启动成功，取得 PID、控制端口并建立 adb forward，但 HTTP 握手超时。同期无鉴权 HTTP 探测和该设备的 `adb shell echo` 均超时；另一台响应正常，模拟器控制台仍报告 running。

仅重连故障设备后，它变为 offline，未恢复。关闭该 AVD、使用 `-no-snapshot-load` 冷启动后，启动完成标志、shell 和后续完整用例均正常。可确认问题涉及该模拟器的 adb/guest 连接链路；没有足够证据断定是快照损坏或具体 emulator/adbd 缺陷，不应据此修改 SDK、用例或默认启动策略。

## 恢复与排查命令

所有探测须由调用方设置超时，不能让 adb shell 无限等待。先保留失败日志，再按顺序检查：

```bash
adb devices -l
adb -s <serial> shell echo diagnostic-alive
adb -s <serial> emu avd status
adb forward --list
adb -s <serial> reconnect
```

重连仍不可用时，停止受影响的执行，仅关闭对应模拟器后冷启动；不清除用户数据：

```bash
adb -s <serial> emu kill
emulator -avd <AVD名称> -no-snapshot-load
adb -s <serial> shell getprop sys.boot_completed
adb -s <serial> shell echo diagnostic-alive
```

恢复后重新发现设备、启动 App 并建立新连接，不能复用失联前的 HTTP 地址或继续未确认的业务命令。

## 证据与复验

失败证据位于 `tmp/20261107-111402-presence-3e6010e1/`：`launch-8-alice-host.json`、`diagnostic-connectivity.json`、`diagnostic-reconnect*.json`、`diagnostic-cold-boot.json` 和 `diagnostic-cold-boot.log`。该轮尚未发送业务命令。

恢复后的轮次 `20261107-111925-presence-83fe79f6` 双 Android HTTP 握手及 Presence 16 步全部通过，任务故障为 0。原始报告见 `reports/<runId>/`。这是恢复验证，不代表已确定底层失联原因或长期稳定率。
