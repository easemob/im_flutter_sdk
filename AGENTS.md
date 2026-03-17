# AGENTS.md

This project is the EaseMob IM Flutter SDK, adopting a Federated Plugin architecture and including multiple sub-packages. The following are the conventions and specifications that AI Agents must follow when working on this project.

## Project Architecture

```
im_flutter_sdk/              → Main SDK package (public APIs, models, managers)
im_flutter_sdk_interface/    → Platform interface layer (MethodChannel abstraction)
im_flutter_sdk_android/      → Android platform implementation
im_flutter_sdk_ios/          → iOS platform implementation
```

Call chain: `Dart API → MethodChannel (interface) → Native Wrapper → HyphenateChat SDK`

## Naming Conventions

### File Naming

- All Dart files use **snake_case**: `chat_manager.dart`, `em_message.dart`
- Model files uniformly use the `em_` prefix: `em_error.dart`, `em_group.dart`, `em_options.dart`
- Manager files use business name + `_manager` suffix: `chat_manager.dart`, `group_manager.dart`
- Android native classes use the `*Wrapper` suffix: `ClientWrapper.java`, `ChatManagerWrapper.java`
- iOS native classes use the `*Wrapper` suffix (`.m/.h`): `ClientWrapper.m`, `ChatManagerWrapper.m`
- iOS Helper classes use the `*Helper` suffix: `MessageHelper.m`, `OptionsHelper.h`

### Class Naming

- All public Dart classes use the **EM** prefix: `EMClient`, `EMMessage`, `EMError`, `EMOptions`
- Manager classes: `EM` + business name + `Manager`, e.g., `EMChatManager`, `EMGroupManager`
- Event handlers: `EM` + business name + `EventHandler`, e.g., `EMConnectionEventHandler`, `EMChatEventHandler`
- Platform implementation classes use platform name as suffix: `ClientIOS`, `ClientAndroid`, `ChatManagerIOS`

### MethodChannel Naming

- Unified prefix `com.chat.im`
- Format: `com.chat.im/{manager_name}`, e.g., `com.chat.im/chat_manager`, `com.chat.im/chat_client`

## Code Style

### Import Order

```dart
import 'dart:xxx';                          // 1. Dart standard library
import 'package:flutter/xxx';               // 2. Flutter framework
import 'package:im_flutter_sdk/xxx';        // 3. This SDK package
import 'package:im_flutter_sdk_interface/xxx';  // 4. Interface package
```

### Singleton Pattern

Manager classes are obtained via `EMClient.getInstance`, not instantiated directly:

```dart
EMClient.getInstance.chatManager
EMClient.getInstance.groupManager
```

### Model Serialization

- Deserialization uses factory constructor: `EMMessage.fromJson(Map map)`
- Serialization uses instance method: `toJson()`
- Data format is JSON Map for MethodChannel transmission

### Event Handling

- Event handlers are stored in `Map<String, Handler>` with unique ID as key
- Registration: `addEventHandler(String id, Handler handler)`
- Unregistration: `removeEventHandler(String id)`
- Native events are distributed via `updateNativeHandler((MethodCall call) => ...)`

### Method Key Constants

- All method names for MethodChannel calls are defined in `ChatMethodKeys`
- All native callback event names are defined in `em_event_keys.dart`
- Hardcoding method name strings in code is prohibited

## Documentation Comment Specifications

All public APIs must use **bilingual comment** format (English + Chinese):

```dart
/// ~english
/// The message class.
///
/// For example:
/// ```dart
/// EMMessage msg = EMMessage.createTxtSendMessage(
///   targetId: 'targetId',
///   content: 'content',
/// );
/// ```
/// ~end
///
/// ~chinese
/// 消息对象类。
///
/// 示例：
/// ```dart
/// EMMessage msg = EMMessage.createTxtSendMessage(
///   targetId: 'targetId',
///   content: 'content',
/// );
/// ```
/// ~end
```

- `~english` and `~end` mark the English documentation block
- `~chinese` and `~end` mark the Chinese documentation block
- Separate the two blocks with a blank line
- Both languages must be maintained when adding or modifying public APIs

## New Feature Specifications

### Adding New Models

1. Create `em_xxx.dart` file under `im_flutter_sdk/lib/src/models/`
2. Class name uses `EM` prefix
3. Implement `fromJson()` factory constructor and `toJson()` method
4. Export in `im_flutter_sdk.dart` barrel file
5. Write bilingual documentation comments

### Adding New Manager Methods

1. Add method in the corresponding Manager class
2. Add method name to `ChatMethodKeys`
3. Define platform interface in `im_flutter_sdk_interface`
4. Implement native bridging in `im_flutter_sdk_android` and `im_flutter_sdk_ios`
5. Android: Handle in the corresponding `*Wrapper.java`
6. iOS: Handle in the corresponding `*Wrapper.m`

### Adding New APIs Based on Existing APIs (Refer to `loadConversationMessagesWithKeyword`)

When adding a new API, implement it step by step according to the following "Dart to cross-platform native" chain, no skipping steps:

1. **Dart Manager Implementation (Entry)**
   - File: `im_flutter_sdk/lib/src/managers/chat_manager.dart` (or corresponding business manager)
   - Add public method, clarify parameter default values, nullable parameters and return types
   - Add corresponding API documentation comments according to the new method name, parameters and return values
   - Assemble request `Map req`, use `putIfNotNull` for nullable parameters
   - Call `Client.instance.xxxManager.callNativeMethod(methodKey, req)`
   - Uniformly call `EMError.hasErrorFromResult(result)` to handle errors
   - Convert returned `Map/List` to strongly typed objects and return

2. **Dart Method Name Constants**
   - File: `im_flutter_sdk/lib/src/internal/chat_method_keys.dart`
   - Add `static const String` method name constant with exactly the same value as native
   - Hardcoding strings in manager methods is prohibited

3. **Android Method Name Constants**
   - File: `im_flutter_sdk_android/android/src/main/java/com/easemob/im_flutter_sdk/MethodKey.java`
   - Add corresponding `static final String` constant with the same name and value as Dart/iOS

4. **Android Routing Distribution + Specific Implementation**
   - File: `im_flutter_sdk_android/android/src/main/java/com/easemob/im_flutter_sdk/ChatManagerWrapper.java` (or corresponding business ManagerWrapper)
   - Register new branch in `onMethodCall`'s `else if` chain
   - Add private processing method (e.g., `private void xxx(JSONObject params, String channelName, Result result)`)
   - Parse parameters (null check/type conversion/enum conversion)
   - Call corresponding asynchronous API of Hyphenate Android SDK
   - Convert results to serializable structures (`Map/List/basic types`) in callback and return via `updateObject`

5. **iOS Method Name Constants**
   - File: `im_flutter_sdk_ios/ios/Classes/MethodKeys.h`
   - Add `static NSString *const` constant with exactly the same string value as Dart/Android

6. **iOS Routing Distribution + Specific Implementation**
   - File: `im_flutter_sdk_ios/ios/Classes/ChatManagerWrapper.m` (or corresponding business ManagerWrapper)
   - Register new API in `handleMethodCall` branch
   - Add instance method `- (void)xxx:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result`
   - Complete parameter null check, type and enum conversion
   - Call corresponding API of Hyphenate iOS SDK
   - Return result object via `wrapperCallBack` in completion

7. **Version Comments and Change Records**
   - Add version comments near the new code following existing style (e.g., `// 4.15.2`, `#pragma mark 4.15.2`)
   - Update `CHANGELOG.md` of the following packages to add "Added xxx API" entry:
     - `im_flutter_sdk/CHANGELOG.md`
     - `im_flutter_sdk_android/CHANGELOG.md`
     - `im_flutter_sdk_ios/CHANGELOG.md`

8. **Joint Debugging Self-Checklist (Before Submission)**
   - Method names are consistent in 4 constant files: Dart/Android/iOS (including calling side)
   - Dart request parameter keys are exactly the same as cross-platform native reading keys
   - Enum indexes are consistent with cross-platform enum mappings
   - Return structure can be correctly deserialized by Dart side (especially generics like `Map<String, List<String>>`)
   - Routing distribution branches are added for both Android and iOS
   - CHANGELOG of three sub-packages are updated synchronously ( `im_flutter_sdk_ios/CHANGELOG.md` does not need to be updated)

### Adding New Event Handlers

1. Define new EventHandler class in `manager_event_handler.dart`
2. Class name format: `EM{Business}EventHandler`
3. Implement `addEventHandler` / `removeEventHandler` in the corresponding Manager
4. Add native event key to `em_event_keys.dart`

## Version and Changelog

- Version numbers of each sub-package are kept in sync
- CHANGELOG.md is written in Chinese
- Format: `## Version Number` title + `- Fixed...` / `- Added...` / `- Optimized...` entries

## Platform Support

| Platform | Minimum Version |
|----------|-----------------|
| Android  | minSdk 21       |
| iOS      | 12.0+           |
| Dart     | >=3.3.0 <4.0.0  |
| Flutter  | >=3.3.0         |

## Prohibited Items

- **Prohibited** to hardcode MethodChannel method names in Dart code; must use `ChatMethodKeys` constants
- **Prohibited** to directly instantiate Manager classes; must obtain via `EMClient.getInstance`
- **Prohibited** to omit documentation comments in public APIs
- **Prohibited** to modify the version number of a single sub-package without synchronizing other sub-packages
- **Prohibited** to omit `fromJson` / `toJson` serialization methods in model classes

### How to Save to a Document
1. Create a new text file (e.g., `AGENTS_EN.md`)
2. Copy all the above content into the file
3. Save the file (ensure the encoding is UTF-8 to avoid garbled characters)
