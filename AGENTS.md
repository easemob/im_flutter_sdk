# AGENTS.md

Easemob IM Flutter SDK, built on the Federated Plugin architecture. This document is intended for AI Agents: it describes the project structure, cross-layer call chains, and hard conventions; for code-level details, the actual repository code prevails.

Document split: this document defines agent conventions; [README.md](README.md) provides the project overview and directory map. Environment setup and CI procedures live in [CONTRIBUTING.md](CONTRIBUTING.md); testing entry points are listed below. `im_flutter_sdk/README.md` targets SDK users.

## Collaboration Conventions

- When the investigation direction is unclear, or the same problem has been stuck for more than a few minutes, first sync the symptoms and your hypotheses with the user before deciding the next direction — do not drill down silently. The user may hold context the AI lacks (environment, historical decisions, server-side state).

### Main/Subagent Execution and Model Assignment

- The main agent chooses the execution strategy based on task size and difficulty; use the main/subagent mode only for medium and large tasks — small tasks are executed directly by the main agent.
- Assign models by task profile: high-volume, mechanical, rule-clear tasks go to `deepseek-flash` (model and key configured in `~/.kimi-code/config.toml`; the key is filled in locally by the user and never committed); complex tasks requiring architectural understanding and trade-offs go to `k3`; a task that is both high-volume and complex may be split — deepseek executes in bulk, k3 or the main agent reviews.
- While a subagent runs in the background, the main agent checks its progress every 15 minutes (keep checking until done); if a task fails review or its output has serious problems, redo it with a stronger model (`deepseek-flash` → `k2.8` → `k3`) instead of patching it locally.
- Final quality responsibility rests with the main agent.

### Work Log

- After completing a task, making an important decision, or receiving a correction from the user, append an entry to `dailylog/<GitHub login>/YYYY-MM-DD.md` using the local date. Create the file if it does not exist.
- Append only; do not modify existing content. Format each entry as: `- HH:MM <what was done or decided>, reason: <...>`.
- Logs may record progress and process details.
- Track work logs under `dailylog/` in Git; do not add the directory to `.gitignore`. When making a user-authorized Git commit, include the log changes from the current work. Logging itself does not trigger a commit or push.

## Project Architecture

| Package | Responsibility |
|---|---|
| `im_flutter_sdk/` | Main package: public API, Models, Managers |
| `im_flutter_sdk_interface/` | Platform interface layer: MethodChannel abstraction |
| `im_flutter_sdk_android/` | Android platform implementation |
| `im_flutter_sdk_ios/` | iOS platform implementation |

Call chain: `Dart API → MethodChannel (interface) → Native Wrapper → HyphenateChat SDK`

Dependency direction: `im_flutter_sdk` → `im_flutter_sdk_android` / `im_flutter_sdk_ios` → `im_flutter_sdk_interface`. The interface is the contract shared by all platform packages; changing it affects every upper-layer package. Package pubspecs use hosted version dependencies for publishing. Run `make local-deps` to generate gitignored `pubspec_overrides.yaml` files for local development; `make deps` and CI do this automatically. Overrides belong to each resolution root, including the workbench and example apps, and are not inherited from dependency packages. See `CONTRIBUTING.md` for release validation.

## Verification Architecture

Test selection and design rules: [testing guide](docs/testing/README.md).

| Mode | Responsibility | Implementation and entry |
|---|---|---|
| CI tests | Protect basic SDK behavior, stability, and regression coverage | Flutter unit/contract tests in `im_flutter_sdk/test/` and device tests in `workbench/integration_test/`; workflows in `.github/workflows/`, local entry points in `ci/`. See [CONTRIBUTING.md](CONTRIBUTING.md#running-and-verification). |
| AI tests | Verify API additions, behavior changes, and interactions for SDK version ports | Single-device JSON scripts via `make auto-report` / `API_SCRIPT`; multi-device YAML flows and JSON commands via the standalone im-test-orchestrator repository (a separate repo checked out next to this one; entry through [workbench/multi/multi.sh](workbench/multi/multi.sh)). See the [workbench guide](workbench/README.md#script-mode-ai-friendly). |
| Manual mode | Allow free API spot checks and provide usable, extractable examples | Run the [workbench app](workbench/README.md) without `API_SCRIPT` or `API_CONTROL`; initialize, log in, and select APIs in the UI. |

- Keep CI and AI test architectures independent. Their case formats and execution engines are maintained separately; API coverage may overlap, and a pass in one mode does not replace verification in another. Manual mode is an interactive usage path, not an automated test suite.
- For each SDK version port, pass the relevant single-device and multi-device scenarios on the affected platforms. Then add CI regression tests for basic behavior, important boundaries, and fixed defects that need lasting protection; do not mechanically duplicate every AI script.
- AI scenarios are executed by the script runner. AI authors cases, initiates runs, and analyzes evidence; it does not control each step of a fixed workflow. Investigate failed cases and never weaken correct assertions to accommodate an SDK defect.
- Select the entry point that supports the case: multi-device execution goes through the standalone im-test-orchestrator repository (invoked via `workbench/multi/multi.sh`); single-device scripts use `make auto-report`. Changes to the multi-device tool must follow its own scope and collaboration rules (see the orchestrator repository's `multi/spec.md`).

## Development Environment Setup

Use Flutter 3.47.0 consistently for developing this repository (matching `FLUTTER_VERSION` in CI's `.github/workflows/ci.yml`). The dev dependency `flutter_lints 6` requires Dart >= 3.8 (Flutter >= 3.32); below that version the repository's dev dependencies cannot be resolved. The Flutter >= 3.3.0 declared in each package's `environment` is the minimum supported version for SDK users — do not confuse the two.

The project root has a `Makefile` providing one-step initialization:

```bash
make setup   # config + deps + pods
```

| target | Purpose |
|--------|---------|
| `make config` | Creates `workbench/config.local.json` and placeholder `workbench/lib/env.dart` (both gitignored) |
| `make env-gettoken` | Fetches a User Token for each account per `workbench/config.local.json` and generates `workbench/lib/env.dart` directly (the project configures only one environment; switching environments = editing this file) |
| `make auto-report PLATFORM=<android\|ios> [DEVICE=<id>] [SCRIPT=<json>]` | Runs the 5.0.0 auto script (defaults to the positive path `script_500_apis_positive.json`; use `SCRIPT=` to specify the negative script), explicitly boots the emulator, and produces sanitized events, crash evidence, and issue candidates under the Git-ignored `artifacts/single/<timestamp>/<platform>/` |
| `make auto-compare ANDROID=<run-dir> IOS=<run-dir>` | Compares two Android/iOS runs of the same path, writes `artifacts/single/comparison-<path>-<timestamp>.md`, and exits non-zero when steps diverge |
| `make local-deps` | Creates local dependency overrides for the main package, Android, iOS, and workbench; preserves existing override files |
| `make deps` | Creates local overrides, then runs `flutter pub get` in the workbench directory |
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

## Language and Documentation Conventions

All user-facing content in this repository must be in English: code comments, log and exception messages, documentation, and commit messages. Rationale: the SDK is whitelabeled for overseas (Agora) distribution, so only English content ships safely to pub.dev.

Exceptions to the English-only rule:

- Documentation comments on public APIs must be bilingual (Chinese + English) — see below.
- The CHANGELOG may keep bilingual sections (`### 中文` / `### English`, recommended) or be English-only; pick one style per line and stay consistent (the 5.x line currently uses English-only).
- Historical records (dailylog, archived porting/spec docs) are grandfathered — do not rewrite them; write all new content in English.
- Proper nouns (e.g. author names in file headers) may stay in their original language.

Ordinary comments in code (implementation notes, version annotations, etc.) must be in English.

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
- The CHANGELOG keeps one entry per version (bilingual `### 中文` / `### English` sections, or English-only on the 5.x line); new entries must follow the established style
- When adding an API: the main package's CHANGELOG records the new API entry; the interface / android / ios CHANGELOGs record their respective actual changes

## Git Branch Management (Iron Rules)

Branch roles:

| Branch | Role |
|---|---|
| `main` | Default branch, pointer to the current release line; always kept in sync with the current release line (renamed from `flutter2_stable` — historical references to it mean `main`) |
| `4.x` | 4 long-term line: integration target for 4.x version branches |
| `5.x` | 5 long-term line: integration target for 5.x version branches |
| `ohos` | HarmonyOS long-term line, evolved independently; HarmonyOS Flutter is incompatible with official Flutter — merging between `ohos` and other lines is forbidden |
| `4.25.0`, `5.1.0`, `ohos-1.16.0`, etc. | Version branches, created from their long-term line, carrying only that version's API porting and fixes |

Iron rules (one-directional flow, non-negotiable):

1. **Commit only to a working branch; merge forward, never backward**: fixes and changes are committed to the current version branch (or long-term line), verified, then merged in the order version branch → long-term line → `main`. Never commit code, test, or doc changes directly to `main`; never cherry-pick backward into an already-merged upstream branch (when a backport is explicitly needed, recommit on the target version branch and merge forward).
2. **4-line flow**: `4.25.0` → `4.x` → `main`. `main` follows the 4 line by default; every update to `4.x` is merged into `main`.
3. **5-line flow**: `5.1.0` → `5.x`. Do not merge `5.x` into `main` until the 5 line becomes the release line; switch the default branch semantics to the 5 line at that time.
4. **ohos line is independent**: `ohos-x.y.z` version branches are created from `ohos` and merged back after release; merging between `ohos` and `4.x`/`5.x`/`main` is forbidden.
5. **Test framework and SDK architecture changes land on the three long-term lines** (`4.x`/`5.x`/`ohos`); version branches carry only API porting and fixes. A new version branch inherits the latest architecture from its long-term line at creation time. Cross-line architecture porting uses "cover + adapt", not blind cherry-picks.
6. **Tags coexist with same-named branches, with different roles**: the version branch is the development vehicle; a tag is placed on the release commit only when publishing to pub.dev, named after the pub.dev version (following the historical convention `4.25.0`, `4.0.0+6`) to pin the exact published version. A branch and a tag may share a name — always use full namespaces (`refs/heads/4.25.0` / `refs/tags/4.25.0`) and push branches as `git push <remote> refs/heads/<branch>`.
7. **Confirm a clean working tree before switching or deleting branches** (`git status` shows no uncommitted changes); if it is not clean, stop and inform the user. **Always create worktrees under `.worktree/` in the repository root** (e.g. `git worktree add .worktree/agora-1.4.0 agora-1.4.0`), not outside the repository
8. **ci-dispatch.yml exists only on `main`**: the cross-line dispatcher for the daily device regression (see `.github/workflows/ci-dispatch.yml`). Never copy/merge it to other branches and never delete it. It is the deliberate exception to rule 1 (no direct commits to `main`) and is maintained directly on `main` — once it enters another branch's merge flow, that branch's merges would silently overwrite it (git merges always take the source branch's file content), losing the dispatch capability without any visible failure.
9. **CI triggers are bounded by the long-term lines**: `ci.yml` (quality gate) push triggers are whitelisted to `main`/`4.x`/`5.x` only, and doc-only paths (`dailylog/**`, `docs/**`, `*.md`) do not trigger it; pull requests trigger on every target branch. Pushes to version branches trigger no CI. `ci-device.yml` (device regression) runs only on the daily schedule plus manual dispatch — never on push/PR/merge. Dispatch it manually when same-day device validation is needed.

## Platform Support

iOS supports both CocoaPods and Swift Package Manager integration, sharing the same source (`ios/im_flutter_sdk_ios/Sources/`). The two integration paths must keep the same native SDK version: CocoaPods goes through `im_flutter_sdk_ios.podspec` (HyphenateChat 4.22.1, deployment target 13.0); SPM goes through `ios/im_flutter_sdk_ios/Package.swift` (HyphenateChat_iOS 4.22.1, deployment target 13.0).

| Platform | Minimum version |
|---|---|
| Android | minSdk 21 |
| iOS | 13.0 |
| Dart | >=3.3.0 <4.0.0 |
| Flutter | >=3.3.0 |
