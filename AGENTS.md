# AGENTS.md

环信 IM Flutter SDK，采用 Federated Plugin 架构。本文档面向 AI Agent，说明项目结构、跨层链路与硬性约定；具体代码细节以仓库实际代码为准。

## 项目架构

| 包 | 职责 |
|---|---|
| `im_flutter_sdk/` | 主包：公开 API、Model、Manager |
| `im_flutter_sdk_interface/` | 平台接口层：MethodChannel 抽象 |
| `im_flutter_sdk_android/` | Android 平台实现 |
| `im_flutter_sdk_ios/` | iOS 平台实现 |

调用链：`Dart API → MethodChannel (interface) → Native Wrapper → HyphenateChat SDK`

依赖方向：`im_flutter_sdk` → `im_flutter_sdk_android` / `im_flutter_sdk_ios` → `im_flutter_sdk_interface`。interface 是各平台包共享的契约，改动它会波及所有上层包。包间依赖均为本地 `path:` 依赖，跨包改动无需发布即可生效。

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
| iOS 常量 | `im_flutter_sdk_ios/ios/Classes/MethodKeys.h` | 新增同名同值常量 |
| iOS 实现 | `im_flutter_sdk_ios/ios/Classes/{业务}Wrapper.m` | `handleMethodCall` 注册分支；参数校验与类型/枚举转换；调用 Hyphenate iOS SDK；completion 中经 `wrapperCallBack` 返回 |

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

## 平台支持

| 平台 | 最低版本 |
|---|---|
| Android | minSdk 21 |
| iOS | 12.0 |
| Dart | >=3.3.0 <4.0.0 |
| Flutter | >=3.3.0 |
