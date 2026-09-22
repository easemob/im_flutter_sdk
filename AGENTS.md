# AGENTS.md

Easemob IM Flutter SDK, built on the Federated Plugin architecture. This document is intended for AI Agents: it describes the project structure, cross-layer call chains, and hard conventions; for code-level details, the actual repository code prevails.

Document split: this document is the only must-read for AI. Procedural content such as environment setup, data preparation, and verification flows lives in `CONTRIBUTING.md` (read on demand only when the task involves it); `im_flutter_sdk/README.md` targets SDK users and AI does not need to read it.

## Collaboration Conventions

- When the investigation direction is unclear, or the same problem has been stuck for more than a few minutes, first sync the symptoms and your hypotheses with the user before deciding the next direction — do not drill down silently. The user may hold context the AI lacks (environment, historical decisions, server-side state).

## Project Architecture

| Package | Responsibility |
|---|---|
| `im_flutter_sdk/` | Main package: public API, Models, Managers |
| `im_flutter_sdk_interface/` | Platform interface layer: MethodChannel abstraction |
| `im_flutter_sdk_android/` | Android platform implementation |
| `im_flutter_sdk_ios/` | iOS platform implementation |

Call chain: `Dart API → MethodChannel (interface) → Native Wrapper → HyphenateChat SDK`

Dependency direction: `im_flutter_sdk` → `im_flutter_sdk_android` / `im_flutter_sdk_ios` → `im_flutter_sdk_interface`. The interface is the contract shared by all platform packages; changing it affects every upper-layer package. All inter-package dependencies are local `path:` dependencies, so cross-package changes take effect without publishing.

## Development Environment Setup

Use Flutter 3.47.0 consistently for developing this repository (matching `FLUTTER_VERSION` in CI's `.github/workflows/ci.yml`). The dev dependency `flutter_lints 6` requires Dart >= 3.8 (Flutter >= 3.32); below that version the repository's dev dependencies cannot be resolved. The Flutter >= 3.3.0 declared in each package's `environment` is the minimum supported version for SDK users — do not confuse the two.

The project root has a `Makefile` providing one-step initialization:

```bash
make setup   # config + deps + pods
```

| target | Purpose |
|--------|---------|
| `make config` | Creates the local `example/config.local.json` and placeholder `example/lib/env.dart` (both gitignored) |
| `make env-gettoken` | Fetches a User Token for each account per `config.local.json` and generates `example/lib/env.dart` directly (the project configures only one environment; switching environments = editing this file) |
| `make auto-report PLATFORM=<android\|ios> [DEVICE=<id>] [SCRIPT=<json>]` | Runs the 5.0.0 auto script (defaults to the positive path `script_500_apis_positive.json`; use `SCRIPT=` to specify the negative script), explicitly boots the emulator, and produces sanitized events, crash evidence, and issue candidates under the Git-ignored `reports/5.0.0/<run-id>/` |
| `make auto-compare ANDROID=<run-dir> IOS=<run-dir>` | Compares two Android/iOS runs of the same path, writes `reports/5.0.0/comparison-<path>-<timestamp>.md`, and exits non-zero when steps diverge |
| `make deps` | `flutter pub get` (in the example directory; resolves path dependencies automatically) |
| `make pods` | `pod install` (runs only when Podfile/podspec changed, detected via mtime) |
| `make clean` | Cleans build artifacts and Pods |

After changing a native dependency version in a podspec, you must run `make pods`; otherwise the iOS side keeps using the old native SDK, causing compilation errors. This is a known Flutter issue: `flutter run`'s Fingerprinter does not track podspec files and skips `pod install`.

## Naming Conventions

- Dart files use snake_case; Manager files are business name + `_manager`: `chat_manager.dart`
- Public Dart classes use the `Chat` prefix: `ChatClient`, `ChatMessage`, `ChatError` (consistent with the overseas agora_chat_sdk naming)
- Manager classes: `Chat{Business}Manager`, e.g. `ChatGroupManager`; event handlers: `Chat{Business}EventHandler`
- Native classes use the `*Wrapper` suffix: `ChatManagerWrapper.java` / `ChatManagerWrapper.m`; iOS data-conversion classes use the `*Helper` suffix
- Model files exist in two styles — with the `chat_` prefix (`chat_message.dart`) and without (e.g. `fetch_message_options.dart`); for new files, follow similar existing files and keep the `Chat` prefix on class names
- Legacy `EM*` names are uniformly shimmed by `@Deprecated` typedefs in `lib/em_compat.dart` (consolidated during the 4.22.0 rename, solely for compatibility with existing user code); **new code must not use `EM*` names**, and no new entries may be added to em_compat.dart
- MethodChannels use the unified prefix `com.chat.im`, in the format `com.chat.im/{manager_name}`: `com.chat.im/chat_manager`

## Code Style Essentials

- Import order: dart standard library → flutter → `im_flutter_sdk` → `im_flutter_sdk_interface`
- Managers must always be obtained via `ChatClient.getInstance`; direct instantiation is forbidden
- Models must implement a `fromJson` factory constructor and `toJson()`; the MethodChannel transport format is a JSON Map
- MethodChannel method names must use constants: `ChatMethodKeys` on the Dart side, `MethodKey.java` on Android, `MethodKeys.h` on iOS; hard-coding strings in code is forbidden. Native callback event names are uniformly defined in `chat_event_keys.dart`
- Event handlers are stored in a `Map<String, Handler>` keyed by a unique id, managed via `addEventHandler(id, handler)` / `removeEventHandler(id)`

## Documentation Comment Conventions

Ordinary comments in code (implementation notes, version annotations, etc.) must be in English; the only exception is documentation comments on public APIs, which must be bilingual (Chinese + English).

Public APIs must use bilingual comments split by `~english` / `~chinese` / `~end` markers, with one blank line between the two language blocks:

```dart
/// ~english
/// The message class.
/// ~end
///
/// ~chinese
/// 消息对象类。
/// ~end
```

When adding or modifying a public API, both languages must be maintained in sync.

Generating single-language API docs: run `im_flutter_sdk/scripts/gen-apidoc.sh [cn|en]` (default `cn`). The script strips the other language block and the marker lines in a temporary copy, then generates HTML with `dart doc`, outputting to `im_flutter_sdk/output/apidoc-<lang>/` (gitignored).

## Standard Chain for Adding an API

Follow an existing API (e.g. `loadConversationMessagesWithKeyword`) and implement layer by layer along the chain below; skipping layers is not allowed:

| Layer | File | Action |
|---|---|---|
| Dart implementation | `im_flutter_sdk/lib/src/managers/{business}_manager.dart` | Add the public method with bilingual comments; assemble the request Map for nullable parameters with `putIfNotNull`; handle errors via `ChatError.hasErrorFromResult(result)`; convert return values to strongly-typed objects |
| Dart constants | `im_flutter_sdk/lib/src/internal/chat_method_keys.dart` | Add a `static const String` method-name constant |
| Android constants | `im_flutter_sdk_android/android/src/main/java/com/easemob/im_flutter_sdk/MethodKey.java` | Add a constant with the same name and value |
| Android implementation | `{Business}Wrapper.java` in the same directory | Register a branch in `onMethodCall`; validate parameters and convert types/enums; call the Hyphenate Android SDK async API; return a serializable structure via `updateObject` in the callback |
| iOS constants | `im_flutter_sdk_ios/ios/im_flutter_sdk_ios/Sources/im_flutter_sdk_ios/include/im_flutter_sdk_ios/MethodKeys.h` | Add a constant with the same name and value |
| iOS implementation | `im_flutter_sdk_ios/ios/im_flutter_sdk_ios/Sources/im_flutter_sdk_ios/{Business}Wrapper.m` | Register a branch in `handleMethodCall`; validate parameters and convert types/enums; call the Hyphenate iOS SDK; return via `wrapperCallBack` in completion |

Also required:

- Add version annotations near new code in the existing style (e.g. `// 4.15.2`, `#pragma mark 4.15.2`)
- Update the CHANGELOG (see the next section)

Pre-commit self-check:

- [ ] Method-name constant values are identical across all three ends
- [ ] Dart request parameter keys exactly match the keys read natively
- [ ] Enum indexes match the native enum mapping
- [ ] Return structures can be correctly deserialized by Dart (watch generics such as `Map<String, List<String>>`)
- [ ] Routing branches are registered on both Android and iOS

Adding a Model: create a file under `im_flutter_sdk/lib/src/models/`, use the `Chat` prefix for the class name, implement `fromJson`/`toJson`, export it from `im_flutter_sdk/lib/im_flutter_sdk.dart`, and write bilingual comments.

Adding an event handler: define `Chat{Business}EventHandler` in `im_flutter_sdk/lib/src/handlers/manager_event_handler.dart`, implement `addEventHandler`/`removeEventHandler` in the corresponding Manager, and add the native event names to `lib/src/internal/chat_event_keys.dart`.

## Versioning and CHANGELOG

- The four sub-packages must keep identical version numbers; modifying only one of them is forbidden
- The CHANGELOG is bilingual: each version keeps a `## <version>` heading with a `### 中文` section and an `### English` section; new entries must be added in both languages
- When adding an API: the main package's CHANGELOG records the new API entry; the interface / android / ios CHANGELOGs record their respective actual changes

## Git Branch Management

- **Since 4.x, each release version corresponds to a branch with the same name** (e.g. `4.19.2`, `4.17.1`); tags are not used. To view or compare a version's code, use branch operations such as `git checkout 4.19.2` or `git diff 4.19.2..4.19.3`
- Tags left over from the 3.x era (`3.8.x`/`3.9.x`) are history only; 4.x has no tags
- The default branch is `flutter2_stable`; `alpha`, `dev`, `customMsg` etc. are feature or historical branches — do not do version development on them
- Releasing a new version: create a branch named after the version number
- **Before switching branches, confirm the working tree is clean** (`git status` shows no uncommitted changes); if it is not clean, stop and inform the user, letting the user decide how to proceed
- **When creating a worktree, always place it under the `.worktree/` folder in the repository root** (e.g. `git worktree add .worktree/agora-1.4.0 agora-1.4.0`), not outside the repository

## Platform Support

iOS supports both CocoaPods and Swift Package Manager integration, sharing the same source (`ios/im_flutter_sdk_ios/Sources/`). The two integration paths must keep the same native SDK version: CocoaPods goes through `im_flutter_sdk_ios.podspec` (HyphenateChat 4.22.1, deployment target 13.0); SPM goes through `ios/im_flutter_sdk_ios/Package.swift` (HyphenateChat_iOS 4.22.1, deployment target 13.0).

| Platform | Minimum version |
|---|---|
| Android | minSdk 21 |
| iOS | 13.0 |
| Dart | >=3.3.0 <4.0.0 |
| Flutter | >=3.3.0 |
