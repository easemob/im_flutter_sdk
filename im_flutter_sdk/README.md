# EaseMob IM Flutter SDK

The Flutter plugin for EaseMob IM, built on the Federated Plugin architecture. With this plugin you can quickly integrate one-to-one chat, group chat, chat rooms, and other instant messaging capabilities into your Flutter app.

## Platform Support

| Platform | Minimum Version |
|---|---|
| Android | API 21 (Android 5.0) |
| iOS | 13.0 |
| HarmonyOS | See [HarmonyOS Support](#harmonyos-support) below |

Environment requirements: Flutter >= 3.3.0, Dart >= 3.3.0 and < 4.0.0.

## Prerequisites

- A valid EaseMob IM developer account and App Key, which you can obtain by registering at the [EaseMob IM Cloud Console](https://console.easemob.com/user/login).
- For Flutter development environment setup issues, see the [Flutter official documentation](https://docs.flutter.dev/get-started/install).

## Integrating the SDK

```bash
flutter pub add im_flutter_sdk
```

### Android Configuration

1. Confirm the minimum version in `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

2. Add keep rules to `android/app/proguard-rules.pro`:

```pro
-keep class com.hyphenate.** {*;}
-dontwarn com.hyphenate.**
```

### iOS Configuration

1. In `ios/Runner.xcodeproj`, set the minimum version under `TARGETS > Runner > General > Deployment Info` to `iOS 13.0`.
2. iOS supports both CocoaPods and Swift Package Manager integration. Choose according to your Flutter project configuration; no extra steps are required.

## Quick Start

The following code covers the minimal flow of "initialize → log in → send and receive text messages → log out":

```dart
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

// 1. Initialize (run once at app startup)
Future<void> initSDK() async {
  ChatOptions options = ChatOptions(
    appKey: "your AppKey",
  );
  await ChatClient.getInstance.init(options);
  // Notify the SDK that the UI is ready; event callbacks are only delivered after this call
  await ChatClient.getInstance.startCallback();
}

// 2. Log in (token login is recommended in production; the token is issued by your app server)
Future<void> signIn(String userId, String token) async {
  try {
    await ChatClient.getInstance.loginWithToken(userId, token);
  } on ChatError catch (e) {
    // Login failed: e.code / e.description
  }
}

// 3. Add a message listener (the key must be unique; remove it with the same key when the page is disposed)
void addChatListener() {
  ChatClient.getInstance.chatManager.addEventHandler(
    "UNIQUE_HANDLER_ID",
    ChatEventHandler(
      onMessagesReceived: (messages) {
        for (var msg in messages) {
          if (msg.body.type == MessageType.TXT) {
            var body = msg.body as ChatTextMessageBody;
            // Received a text message: body.content; sender: msg.from
          }
        }
      },
    ),
  );

  // Message sending status callbacks
  ChatClient.getInstance.chatManager.addMessageEvent(
    "UNIQUE_HANDLER_ID",
    ChatMessageEvent(
      onSuccess: (msgId, msg) {
        // Sent successfully
      },
      onProgress: (msgId, progress) {
        // Attachment upload progress
      },
      onError: (msgId, msg, error) {
        // Sending failed: error.code / error.description
      },
    ),
  );
}

// 4. Send a text message
void sendTextMessage(String targetId, String content) {
  var msg = ChatMessage.createTxtSendMessage(
    targetId: targetId,
    content: content,
  );
  ChatClient.getInstance.chatManager.sendMessage(msg);
}

// 5. Log out
Future<void> signOut() async {
  try {
    await ChatClient.getInstance.logout(true);
  } on ChatError catch (e) {
    // Logout failed: e.code / e.description
  }
}

// 6. Remove the listeners when the page is disposed (use the same keys as when adding)
void dispose() {
  ChatClient.getInstance.chatManager.removeMessageEvent("UNIQUE_HANDLER_ID");
  ChatClient.getInstance.chatManager.removeEventHandler("UNIQUE_HANDLER_ID");
}
```

> Note: Starting from 5.0.0, the client only supports token login. Account registration and token retrieval should be performed by your app server via the REST API.

> Note: Starting from 4.22.0, public APIs are uniformly named with the `Chat` prefix (e.g. `ChatClient`, `ChatOptions`). The old `EM`-prefixed names are still available through `@Deprecated` typedefs in `em_compat.dart`; new code should use the new names.

## Example App

The `example/` directory in the repository provides a visual API testing app that covers initialization, login, and invocation of common APIs with result viewing. It can be used as an integration reference and for feature verification.

## HarmonyOS Support

HarmonyOS is provided through a separate plugin. It requires the HarmonyOS version of Flutter (`https://gitee.com/harmonycommando_flutter/flutter`). Add the following to your `pubspec.yaml`:

```yaml
im_flutter_sdk: ^4.13.0
im_flutter_sdk_ohos:
  git:
    url: "https://github.com/easemob/im_flutter_sdk_oh.git"
    ref: 1.5.3
```

For the latest `ref`, see [im_flutter_sdk_oh releases](https://github.com/easemob/im_flutter_sdk_oh/releases).

## More Resources

- [EaseMob IM official documentation](https://docs-im.easemob.com/)
- [EaseMob IM Cloud Console](https://console.easemob.com/user/login)
- For version changes, see [CHANGELOG.md](CHANGELOG.md)
