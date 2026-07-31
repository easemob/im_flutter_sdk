# 贡献者指南

本文档面向 im_flutter_sdk 的开发与维护者，说明仓库结构、环境准备、验证方式与发布流程。SDK 使用者请阅读 [im_flutter_sdk/README.md](im_flutter_sdk/README.md)。

## 仓库结构

Federated Plugin 架构，四个包通过本地 `path:` 依赖关联：

| 包 | 职责 |
|---|---|
| `im_flutter_sdk/` | 主包：公开 API、Model、Manager，含 `example/` 测试应用 |
| `im_flutter_sdk_interface/` | 平台接口层：MethodChannel 抽象 |
| `im_flutter_sdk_android/` | Android 平台实现 |
| `im_flutter_sdk_ios/` | iOS 平台实现 |

调用链：`Dart API → MethodChannel (interface) → Native Wrapper → HyphenateChat SDK`。改动 interface 会波及所有上层包。

## 环境准备

需要 Flutter（>= 3.3.0）、Xcode + CocoaPods（iOS）、Android Studio（Android）。

项目根目录提供了 Makefile，一键初始化：

```bash
make setup   # 依次执行 config + deps + pods
```

| target | 作用 |
|--------|------|
| `make config` | 拷贝 `im_flutter_sdk/example/templates/config.example.json` → `im_flutter_sdk/example/scripts/config.json`（已存在则跳过） |
| `make deps` | 在 example 目录执行 `flutter pub get`，解析 4 个子包的 path 依赖 |
| `make pods` | 在 `example/ios` 执行 `pod install`（仅 Podfile/podspec 变更时执行，mtime 检测） |
| `make clean` | 清理 build 产物和 Pods |
| `make help` | 查看所有命令 |

> **重要**：修改 `im_flutter_sdk_ios.podspec` 中的 native 依赖版本（如 HyphenateChat）后，必须执行 `make pods`。`flutter run` 不会追踪 podspec 变更，会跳过 pod install，导致 iOS 使用旧版本 native SDK 引发编译错误。

## 测试数据准备

example 应用的运行需要真实测试数据，配置在 `im_flutter_sdk/example/scripts/config.json`（含 appKey、测试账号等敏感信息，已 gitignore，不入库）：

1. `make config` 生成模板副本；
2. 按 `templates/config.example.json` 中的占位符填写真实 appKey、测试账号、群组/聊天室 id 等。

## 运行与验证

example 是一个可视化 API 测试应用，支持两种模式：

- **人工模式**：初始化 → 登录 → 搜索 API → 填 JSON 参数调用，结果和监听器回调在悬浮日志中查看。
- **脚本模式**（适合 AI / 自动化）：通过 `--dart-define=API_SCRIPT=...` 传入 JSON 脚本顺序执行一批 API，日志以 `[APITEST]` 前缀单行 JSON 输出到 stdout 和日志文件。

详细用法见 [im_flutter_sdk/example/README.md](im_flutter_sdk/example/README.md)；覆盖 4.22 新增 API 的完整脚本示例见 `example/scripts/script_422_apis.json`。

## 编码规范

命名约定、双语注释规范、新增 API 的标准链路（Dart → 常量 → Android → iOS）与提交前自检清单，统一维护在 [AGENTS.md](AGENTS.md) 中，人类开发者同样适用，不再重复列举。

## 版本号与 CHANGELOG

- 四个子包的版本号保持一致，禁止只改其中一个。
- CHANGELOG 使用中文，格式为 `## 版本号` 标题 + `- 新增…` / `- 修复…` / `- 优化…` 条目。
- 新增 API 时：主包 CHANGELOG 记录新 API 条目；interface / android / ios 的 CHANGELOG 按各自实际改动记录。

## 分支与发布流程

- **4.x 起每个发布版本对应一个同名分支**（如 `4.22.0`），不使用 tag；3.x 遗留 tag 仅属历史。
- 默认分支为 `flutter2_stable`；`alpha`、`dev` 等为特性或历史分支，不在其上做版本开发。
- 版本开发流程：
  1. 确认当前工作区干净后，从 `flutter2_stable` 新建与目标版本同名的分支；
  2. 在该分支上完成开发与验证（双端编译运行 + example 脚本验证）；
  3. 验证测试通过后，合并回 `flutter2_stable`。
- 版本升级（对齐 native SDK 新版本的公开 API）有专门的工作流与验收报告模板，见团队工作区的 `platform-sdk-porting-v2` skill 及历次升级报告。
