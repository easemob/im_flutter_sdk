# iOS 模拟器架构查询失败

- 日期：2026-11-07
- 状态：已修复；真实设备架构验收及自动化回归通过
- 触发仓库：`im_flutter_sdk`，`testing` 分支
- 适用环境：macOS arm64、Xcode 26.2、iOS 18.1／18.2 模拟器

## 结论

`simctl spawn <UDID> uname -m` 在本次模拟器环境返回找不到命令，不能用于判断 App 架构兼容性。查询目标的 `SIMULATOR_ARCHS`，与构建切片取交集，再使用指定架构启动模拟器内的只读工具验证可执行性。

## 现象与根因

安装前检查返回 `NSPOSIXErrorDomain code=2`、`No such file or directory`。App 文件和模拟器均存在，失败对象是 `uname` 命令。改为绝对路径 `/usr/bin/uname` 也不可靠：本机实测得到 `x86_64`，不能据此把支持 arm64 的模拟器判为不兼容。

## 修复与验证

构建模块读取目标声明，只探测与 App 切片相交的架构；没有交集或全部探测失败则拒收，保留命令证据。两台设备的 arm64、x86_64 探测通过；回归覆盖兼容、不兼容、空架构、候选探测失败和全部不可执行。

```bash
xcrun simctl getenv <UDID> SIMULATOR_ARCHS
xcrun lipo -archs <Runner.app>/Runner
xcrun simctl spawn --arch=arm64 <UDID> launchctl print-disabled system
```

证据位于 `tmp/20261107-101724-presence-c4c1eca8/`：`launch-8-*-artifact-host.json` 为原失败，`launch-11-*-artifact-host.json` 为修复后的实际验收。此结论只证明架构检查通过，不代表 App 已启动或业务用例通过。
