# im_flutter_sdk_ohos

环信即时通讯 IM Flutter SDK 的 HarmonyOS（鸿蒙）平台实现包，属于 Federated Plugin 的 `ohos` 实现。

## 说明

- 原生层基于 HarmonyOS native chatsdk [`@easemob/chatsdk`](https://ohpm.openharmony.cn/) `1.16.0`，用 ArkTS 编写 Wrapper，通过 `com.chat.im/*` MethodChannel 与 Dart 侧通信。
- `pubspec.yaml` 中声明 `implements: im_flutter_sdk`；主包的 `flutter.plugin.platforms.ohos.default_package` 指向本包。**使用方只需依赖 `im_flutter_sdk`，接口包与本包会被自动引入，无需显式添加。** interface 为 pub.dev 已发布 4.25.0（复用，不随本线发版）；本包发布到 pub.dev 后，主包才能按版本号解析。
- 目录结构：`lib/` 为 Dart 侧插件入口（`ClientOhos`），`ohos/` 为 ArkTS 实现与 `@easemob/chatsdk` 依赖声明（`oh-package.json5`）。

## 平台要求

| 项 | 要求 |
|---|---|
| HarmonyOS | 5.0.0 (API 12) 及以上 |
| Flutter | 鸿蒙版 Flutter `3.41.9+ohos`（fvm `custom_ohos`） |
| 工具 | DevEco Studio、hdc（真机需配置签名；模拟器可用无签名 hap） |

构建与验证入口（`flutter build hap`、`hdc install`、`ohos_local.sh`、`smoke_local.harmony.sh`、`nightly_local.harmony.sh`）见 [CONTRIBUTING.md](../CONTRIBUTING.md)。

## 已知限制

- 不支持 Thread API。
- 悬浮附件面板隐藏：`file_picker` 暂无鸿蒙实现。
- 聊天室回执、翻译、语音转文字、服务端消息搜索等依赖服务端增值服务。
- 部分多设备用例需要两台设备验证。

## 版本

版本号与主包严格一致，当前 `1.16.0-ohos`（semver 预发布形式，跟随 native HarmonyOS chatsdk `1.16.0`，1.x 规则）。依赖 `im_flutter_sdk_interface ^4.25.0`（pub.dev 已发布，复用，不发布新版本）。本包发布到 pub.dev，主包按精确版本自动引入。

## 相关文档

- 集成方式、快速上手与平台配置：[im_flutter_sdk/README.md](../im_flutter_sdk/README.md)
- 开发环境、验证与发布流程：[CONTRIBUTING.md](../CONTRIBUTING.md)
- 版本变更记录：[CHANGELOG.md](CHANGELOG.md)
