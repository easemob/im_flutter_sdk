# 环信 im flutter sdk 项目介绍

1. 使用联合插件的方式开发，支持安卓，iOS，鸿蒙 三个平台;
2. sdk readme 在 [README](/im_flutter_sdk/README.md);

## 开发环境初始化

在项目根目录执行：

```bash
make setup
```

依次完成三步（也可单独执行）：

| 步骤 | 命令 | 说明 |
|------|------|------|
| config | `make config` | 拷贝 `example/templates/config.example.json` → `example/scripts/config.json`（已存在则跳过）。该文件含 appKey 等敏感信息，已被 gitignore，需手动填写 |
| deps | `make deps` | 在 example 目录执行 `flutter pub get`，自动解析 4 个子包的 path 依赖 |
| pods | `make pods` | 在 `example/ios` 执行 `pod install`，仅在 Podfile 或 podspec 变更时才运行 |

> **重要**：修改 `im_flutter_sdk_ios.podspec` 中的 native 依赖版本（如 HyphenateChat）后，必须执行 `make pods`。直接 `flutter run` 不会触发 pod install，会导致 iOS 使用旧版本 native SDK，引发编译错误或运行时崩溃。`make pods` 会自动检测 podspec 变更并按需执行。

其他命令：`make clean`（清理 build 产物和 Pods）、`make help`（查看所有命令）。

## 如何添加鸿蒙支持


1. 使用鸿蒙版 flutter `https://gitee.com/harmonycommando_flutter/flutter`

2. 在项目 pubspec.yaml 中添加：
```dart
im_flutter_sdk: ^4.13.0
im_flutter_sdk_ohos:
  git:
    url: "https://github.com/easemob/im_flutter_sdk_oh.git"
    ref: 1.5.3
```
其中具体的 `ref` 可以去 `https://github.com/easemob/im_flutter_sdk_oh/releases` 查看最新版本号;

1. 执行 `flutter pub get`;