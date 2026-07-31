# AGENTS.md

环信 IM Flutter SDK，采用 Federated Plugin 架构。本文档面向 AI Agent，说明项目结构、跨层链路与硬性约定；具体代码细节以仓库实际代码为准。

文档分工：本文档是 AI 的唯一必读文档。环境搭建、数据准备、验证流程等过程性内容见 `CONTRIBUTING.md`（仅当任务涉及时按需阅读）；`im_flutter_sdk/README.md` 面向 SDK 使用者，AI 无需阅读。

## 协作约定

- 排查方向不确定、或同一问题卡住超过几分钟时，先把现象和自己的假设同步给用户，再决定排查方向，不闷头钻到底——用户可能掌握 AI 不知道的背景（环境、历史决策、服务端状态）。

## 项目架构

| 包 | 职责 |
|---|---|
| `im_flutter_sdk/` | 主包：公开 API、Model、Manager |
| `im_flutter_sdk_interface/` | 平台接口层：MethodChannel 抽象 |
| `im_flutter_sdk_android/` | Android 平台实现 |
| `im_flutter_sdk_ios/` | iOS 平台实现 |

调用链：`Dart API → MethodChannel (interface) → Native Wrapper → HyphenateChat SDK`

依赖方向：`im_flutter_sdk` → `im_flutter_sdk_android` / `im_flutter_sdk_ios` → `im_flutter_sdk_interface`。interface 是各平台包共享的契约，改动它会波及所有上层包。包间依赖均为本地 `path:` 依赖，跨包改动无需发布即可生效。

## 开发环境初始化

项目根目录有 `Makefile`，提供一键初始化：

```bash
make setup   # config + deps + pods
```

| target | 作用 |
|--------|------|
| `make config` | 拷贝 `example/templates/config.example.json` → `example/scripts/config.json`（含敏感信息，已 gitignore） |
| `make deps` | `flutter pub get`（example 目录，自动解析 path 依赖） |
| `make pods` | `pod install`（仅 Podfile/podspec 变更时执行，通过 mtime 检测） |
| `make clean` | 清理 build 产物和 Pods |

修改 podspec 中 native 依赖版本后必须执行 `make pods`，否则 iOS 侧会使用旧版本 native SDK 导致编译错误。这是 Flutter 的已知问题：`flutter run` 的 Fingerprinter 不追踪 podspec 文件，会跳过 `pod install`。

## 命名约定

- Dart 文件统一 snake_case；Manager 文件为业务名 + `_manager`：`chat_manager.dart`
- 公开 Dart 类统一 `EM` 前缀：`EMClient`、`EMMessage`、`EMError`
- Manager 类：`EM{业务}Manager`，如 `EMChatManager`；事件处理器：`EM{业务}EventHandler`
- 原生类统一 `*Wrapper` 后缀：`ChatManagerWrapper.java` / `ChatManagerWrapper.m`；iOS 数据转换类用 `*Helper` 后缀
- Model 文件历史上存在 `em_` 前缀（`em_message.dart`）与无前缀（`em_message_stream_chunk.dart` 之外的如 `fetch_message_options.dart`）两种风格，新增时参考同类文件、保持类名 `EM` 前缀即可
- MethodChannel 统一前缀 `com.chat.im`，格式 `com.chat.im/{manager_name}`：`com.chat.im/chat_manager`

## 代码风格要点

- import 顺序：dart 标准库 → flutter → `im_flutter_sdk` → `im_flutter_sdk_interface`
- Manager 一律通过 `EMClient.getInstance` 获取，禁止直接实例化
- Model 必须实现 `fromJson` 工厂构造与 `toJson()`；MethodChannel 传输格式为 JSON Map
- MethodChannel 方法名必须使用常量：Dart 侧 `ChatMethodKeys`、Android 侧 `MethodKey.java`、iOS 侧 `MethodKeys.h`，禁止在代码中硬编码字符串；原生回调事件名统一定义在 `em_event_keys.dart`
- 事件处理器以唯一 id 为 key 存于 `Map<String, Handler>`，通过 `addEventHandler(id, handler)` / `removeEventHandler(id)` 管理

## 文档注释规范

公开 API 必须使用中英双语注释，以 `~english` / `~chinese` / `~end` 标记分块，两语言块之间空一行：

```dart
/// ~english
/// The message class.
/// ~end
///
/// ~chinese
/// 消息对象类。
/// ~end
```

新增或修改公开 API 时，两种语言必须同步维护。

## 新增 API 的标准链路

参照已有 API（如 `loadConversationMessagesWithKeyword`）按以下链路逐层实现，不可跨层跳过：

| 层 | 文件 | 动作 |
|---|---|---|
| Dart 实现 | `im_flutter_sdk/lib/src/managers/{业务}_manager.dart` | 新增公开方法与双语注释；可空参数用 `putIfNotNull` 组装请求 Map；用 `EMError.hasErrorFromResult(result)` 处理错误；返回值转为强类型对象 |
| Dart 常量 | `im_flutter_sdk/lib/src/internal/chat_method_keys.dart` | 新增 `static const String` 方法名常量 |
| Android 常量 | `im_flutter_sdk_android/android/src/main/java/com/easemob/im_flutter_sdk/MethodKey.java` | 新增同名同值常量 |
| Android 实现 | 同目录下 `{业务}Wrapper.java` | `onMethodCall` 注册分支；参数校验与类型/枚举转换；调用 Hyphenate Android SDK 异步 API；回调中经 `updateObject` 返回可序列化结构 |
| iOS 常量 | `im_flutter_sdk_ios/ios/im_flutter_sdk_ios/Sources/im_flutter_sdk_ios/include/im_flutter_sdk_ios/MethodKeys.h` | 新增同名同值常量 |
| iOS 实现 | `im_flutter_sdk_ios/ios/im_flutter_sdk_ios/Sources/im_flutter_sdk_ios/{业务}Wrapper.m` | `handleMethodCall` 注册分支；参数校验与类型/枚举转换；调用 Hyphenate iOS SDK；completion 中经 `wrapperCallBack` 返回 |

同时还需：

- 按现有风格在新代码附近标注版本注释（如 `// 4.15.2`、`#pragma mark 4.15.2`）
- 更新 CHANGELOG（见下节）

提交前自检：

- [ ] 三端方法名常量的值完全一致
- [ ] Dart 请求参数 key 与原生读取 key 完全一致
- [ ] 枚举索引与原生枚举映射一致
- [ ] 返回结构可被 Dart 正确反序列化（注意 `Map<String, List<String>>` 等泛型）
- [ ] Android 与 iOS 的路由分支均已注册

新增 Model：在 `im_flutter_sdk/lib/src/models/` 建文件，类名 `EM` 前缀，实现 `fromJson`/`toJson`，在 `im_flutter_sdk/lib/im_flutter_sdk.dart` 导出，写双语注释。

新增事件处理器：在 `im_flutter_sdk/lib/src/handlers/manager_event_handler.dart` 定义 `EM{业务}EventHandler`，在对应 Manager 实现 `addEventHandler`/`removeEventHandler`，原生事件名加入 `lib/src/internal/em_event_keys.dart`。

## 版本与 CHANGELOG

- 四个子包的版本号保持一致，禁止只修改其中某一个
- CHANGELOG 使用中文，格式为 `## 版本号` 标题 + `- 新增…` / `- 修复…` / `- 优化…` 条目
- 新增 API 时：主包 CHANGELOG 记录新 API 条目；interface / android / ios 的 CHANGELOG 按各自实际改动记录

## Git 分支管理

- **4.x 起，每个发布版本对应一个同名分支**（如 `4.19.2`、`4.17.1`），不使用 tag；查看或对比某版本代码用 `git checkout 4.19.2`、`git diff 4.19.2..4.19.3` 等分支操作
- 3.x 时代遗留的 tag（`3.8.x`/`3.9.x`）仅属历史，4.x 无 tag
- 默认分支为 `flutter2_stable`；`alpha`、`dev`、`customMsg` 等为特性或历史分支，勿在其上做版本开发
- 发布新版本：新建与版本号同名的分支
- **切换分支前先确认工作区干净**（`git status` 无未提交改动）；不干净则停止操作并告知用户，由用户决定如何处理

## 平台支持

iOS 同时支持 CocoaPods 与 Swift Package Manager 两种集成，共用同一份源码（`ios/im_flutter_sdk_ios/Sources/`），两条链路的原生 SDK 版本保持一致：CocoaPods 走 `im_flutter_sdk_ios.podspec`（HyphenateChat 4.22.1，部署目标 13.0），SPM 走 `ios/im_flutter_sdk_ios/Package.swift`（HyphenateChat_iOS 4.22.1，部署目标 13.0）。

| 平台 | 最低版本 |
|---|---|
| Android | minSdk 21 |
| iOS | 13.0 |
| Dart | >=3.3.0 <4.0.0 |
| Flutter | >=3.3.0 |
