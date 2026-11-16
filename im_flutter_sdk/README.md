# 环信即时通讯 IM Flutter SDK

环信 IM 的 Flutter 插件，基于 Federated Plugin 架构，通过本插件可以在 Flutter 应用中快速集成单聊、群聊、聊天室等即时通讯能力。当前 `ohos` 分支（鸿蒙线）版本为 `1.16.0-ohos`，主包只声明 HarmonyOS 平台。仓库共 5 个包：**2 个发布包**——`im_flutter_sdk`（主包，按 Git tag 分发）、`im_flutter_sdk_ohos`（HarmonyOS 实现包，发布到 pub.dev）；**3 个复用包**——`im_flutter_sdk_interface`、`im_flutter_sdk_android`、`im_flutter_sdk_ios`（使用 pub.dev 已发布 **4.25.0**，**不发布新版本**）。

## 平台支持

| 平台 | 最低版本 | 原生 SDK |
|---|---|---|
| HarmonyOS | HarmonyOS 5.0.0 (API 12) | @easemob/chatsdk 1.16.0 |

环境要求：Flutter >= 3.3.0，Dart >= 3.3.0 且 < 4.0.0。HarmonyOS 构建/运行需使用鸿蒙版 Flutter `3.41.9+ohos`（见[鸿蒙支持](#鸿蒙支持)）。Android/iOS 集成请使用 pub.dev 官方发布线（`im_flutter_sdk` 4.25.0 / 5.0.0）。

## 前提条件

- 有效的环信 IM 开发者账号和 App Key，可在 [环信即时通讯云控制台](https://console.easemob.com/user/login) 注册获取。
- Flutter 开发环境配置问题请参考 [Flutter 官方文档](https://docs.flutter.dev/get-started/install)。

## 集成 SDK

Android/iOS 可继续使用 pub.dev 上的主线版本：

```bash
flutter pub add im_flutter_sdk
```

鸿蒙线（当前 `1.16.0-ohos`）按 Git tag 依赖主包，实现包由主包自动带入，无需逐个声明：

```yaml
dependencies:
  im_flutter_sdk:
    git:
      url: https://github.com/easemob/im_flutter_sdk.git
      ref: 1.16.0-ohos   # 以仓库实际发布的 tag 为准
      path: im_flutter_sdk
```

- `im_flutter_sdk_interface`（接口包）与 `im_flutter_sdk_ohos`（鸿蒙实现包）由主包自动引入，无需显式添加；interface 为 pub.dev 已发布 4.25.0。
- `im_flutter_sdk_ohos` 需先发布 `1.16.0-ohos` 到 pub.dev，主包 `pub get` 才能解析；主包本身不发布到 pub.dev。
- `im_flutter_sdk_android` / `im_flutter_sdk_ios` 为 4.25.0 复用包，**不随鸿蒙线发布**，无需显式依赖。
- 主包按版本号解析上述子包。若对应版本的子包尚未发布到 pub.dev，`pub get` 会解析失败；此时需等待子包发布，或用 `dependency_overrides` 将这些包指向同一 tag 下的对应路径。
- 鸿蒙构建请使用鸿蒙版 Flutter，并确认 `pub get` 后 `.flutter-plugins-dependencies` 中包含 `plugins.ohos` 段。

> 以下 Android/iOS 配置仅适用于 pub.dev 官方发布线；本仓库鸿蒙线主包只支持 HarmonyOS。

### Android 配置

1. 在 `android/app/build.gradle` 中确认最低版本：

```gradle
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

2. 在 `android/app/proguard-rules.pro` 中添加免混淆规则：

```pro
-keep class com.hyphenate.** {*;}
-dontwarn com.hyphenate.**
```

### iOS 配置

1. 在 `ios/Runner.xcodeproj` 中将 `TARGETS > Runner > General > Deployment Info` 的最低版本设置为 `iOS 13.0`。
2. iOS 同时支持 CocoaPods 与 Swift Package Manager 两种集成方式，按你的 Flutter 项目配置选择即可，无需额外操作。

## 快速上手

以下代码覆盖「初始化 → 登录 → 收发文本消息 → 退出」的最小流程：

```dart
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

// 1. 初始化（app 启动时执行一次）
Future<void> initSDK() async {
  ChatOptions options = ChatOptions(
    appKey: "你的 AppKey",
    autoLogin: false,
  );
  await ChatClient.getInstance.init(options);
  // 通知 SDK UI 已准备好，执行后才会收到事件回调
  await ChatClient.getInstance.startCallback();
}

// 2. 登录（生产环境建议使用 token 登录，token 由你的应用服务器下发）
Future<void> signIn(String userId, String password) async {
  try {
    await ChatClient.getInstance.login(userId, password);
  } on ChatError catch (e) {
    // 登录失败：e.code / e.description
  }
}

// 3. 添加收消息监听（key 需唯一，页面销毁时用同一 key 移除）
void addChatListener() {
  ChatClient.getInstance.chatManager.addEventHandler(
    "UNIQUE_HANDLER_ID",
    ChatEventHandler(
      onMessagesReceived: (messages) {
        for (var msg in messages) {
          if (msg.body.type == MessageType.TXT) {
            var body = msg.body as ChatTextMessageBody;
            // 收到文本消息：body.content，发送方：msg.from
          }
        }
      },
    ),
  );

  // 消息发送状态回调
  ChatClient.getInstance.chatManager.addMessageEvent(
    "UNIQUE_HANDLER_ID",
    ChatMessageEvent(
      onSuccess: (msgId, msg) {
        // 发送成功
      },
      onProgress: (msgId, progress) {
        // 附件上传进度
      },
      onError: (msgId, msg, error) {
        // 发送失败：error.code / error.description
      },
    ),
  );
}

// 4. 发送文本消息
void sendTextMessage(String targetId, String content) {
  var msg = ChatMessage.createTxtSendMessage(
    targetId: targetId,
    content: content,
  );
  ChatClient.getInstance.chatManager.sendMessage(msg);
}

// 5. 退出登录
Future<void> signOut() async {
  try {
    await ChatClient.getInstance.logout(true);
  } on ChatError catch (e) {
    // 退出失败：e.code / e.description
  }
}

// 6. 页面销毁时移除监听（key 与添加时一致）
void dispose() {
  ChatClient.getInstance.chatManager.removeMessageEvent("UNIQUE_HANDLER_ID");
  ChatClient.getInstance.chatManager.removeEventHandler("UNIQUE_HANDLER_ID");
}
```

> 注意：注册账号（`ChatClient.getInstance.createAccount`）仅建议在 demo 中使用，生产环境应由你的应用服务器调用环信 REST API 完成注册。

> 说明：4.22.0 起公开 API 统一为 `Chat` 前缀命名（如 `ChatClient`、`ChatOptions`）。旧 `EM` 前缀名字仍可通过 `em_compat.dart` 中的 `@Deprecated` typedef 使用，建议新代码使用新名字。

## 示例应用

仓库内 `example/` 目录提供了一个可视化 API 测试应用，覆盖初始化、登录及常用 API 的调用与结果查看，可用于集成参考和功能验证。

## 鸿蒙支持

从 `1.15.0-ohos` 起，HarmonyOS 支持由本仓库的 `im_flutter_sdk_ohos` 实现包提供，使用鸿蒙版 Flutter 构建。版本号跟随 HarmonyOS native chatsdk `@easemob/chatsdk`，当前为 `1.16.0-ohos`（1.x 规则 + `-ohos` 预发布后缀）。

### 环境与依赖

- Flutter：鸿蒙版 `3.41.9+ohos`（fvm 版本名 `custom_ohos`）。官方 Flutter 3.47.0 仅用于 Android/iOS 构建与质量门禁，不要用于鸿蒙构建。
- HarmonyOS：5.0.0 (API 12) 及以上；已在 DevEco Studio 模拟器（OpenHarmony 5.0.2.125 / API 14）验证，真机需配置签名。
- 依赖写法见上方[集成 SDK](#集成-sdk) 的 Git tag 示例，`ref: 1.16.0-ohos`，只需依赖主包。

### 构建与运行

```bash
fvm flutter pub get
fvm flutter build hap --debug --no-codesign
# 产物：build/ohos/hap/entry-default-unsigned.hap
hdc install build/ohos/hap/entry-default-unsigned.hap
```

本地无签名模拟器可设 `OHOS_SKIP_CODESIGN=1`；项目已有真实签名配置时设为 `0`。开发环境初始化、fvm 项目级锁定、`hdc` 常用命令及验证脚本见 [CONTRIBUTING.md](../CONTRIBUTING.md)。

### 已知限制

- 不支持 Thread API。
- 悬浮附件面板隐藏（`file_picker` 暂无鸿蒙实现）。
- 聊天室回执、翻译、语音转文字、服务端消息搜索等依赖服务端增值服务。
- 部分多设备用例需要两台设备验证。

## 更多资源

- [环信 IM 官方文档](https://docs-im.easemob.com/)
- [环信即时通讯云控制台](https://console.easemob.com/user/login)
- 版本变更记录见 [CHANGELOG.md](CHANGELOG.md)
