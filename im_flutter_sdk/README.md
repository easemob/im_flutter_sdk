# 环信即时通讯 IM Flutter SDK

环信 IM 的 Flutter 插件，基于 Federated Plugin 架构，通过本插件可以在 Flutter 应用中快速集成单聊、群聊、聊天室等即时通讯能力。

## 平台支持

| 平台 | 最低版本 |
|---|---|
| Android | API 21 (Android 5.0) |
| iOS | 13.0 |
| 鸿蒙 | 见下方[鸿蒙支持](#鸿蒙支持) |

环境要求：Flutter >= 3.3.0，Dart >= 3.3.0 且 < 4.0.0。

## 前提条件

- 有效的环信 IM 开发者账号和 App Key，可在 [环信即时通讯云控制台](https://console.easemob.com/user/login) 注册获取。
- Flutter 开发环境配置问题请参考 [Flutter 官方文档](https://docs.flutter.dev/get-started/install)。

## 集成 SDK

```bash
flutter pub add im_flutter_sdk
```

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

鸿蒙平台通过独立插件提供，需使用鸿蒙版 Flutter（`https://gitee.com/harmonycommando_flutter/flutter`），并在 `pubspec.yaml` 中添加：

```yaml
im_flutter_sdk: ^4.13.0
im_flutter_sdk_ohos:
  git:
    url: "https://github.com/easemob/im_flutter_sdk_oh.git"
    ref: 1.5.3
```

最新 `ref` 请查看 [im_flutter_sdk_oh releases](https://github.com/easemob/im_flutter_sdk_oh/releases)。

## 更多资源

- [环信 IM 官方文档](https://docs-im.easemob.com/)
- [环信即时通讯云控制台](https://console.easemob.com/user/login)
- 版本变更记录见 [CHANGELOG.md](CHANGELOG.md)
