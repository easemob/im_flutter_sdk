## 2.0.0

Synced with im_flutter_sdk 5.2.0@3989d6b2. Includes all features and fixes up to that version.

### Changes since the previous sync (7abddf49 (easemob/4.16.0), 55 commits)

- ae15b11c feat: add dohVendor option to ChatOptions across Dart/Android/iOS wrappers
- 242d0538 fix: restore from/to when rebuilding multi-body messages on iOS
- d503710a feat: port native SDK 5.2.0 APIs to Flutter (iOS 5.2.0 / Android 5.2.1)
- c7af3b40 docs: record the iOS deleteContact keepConversation fix in 5.1.0 changelogs
- 85b890b6 build: require im_flutter_sdk_interface ^5.1.0 across federated packages
- dc2676a2 build: require im_flutter_sdk_interface ^5.1.0 across federated packages
- ca6bf3ef docs: enforce English-only content on the 5.x line for Agora overseas whitelabel
- b1de0dd3 test: capture full device log in single-device auto-report
- f65cacff refactor: unify console log control under debugMode
- 5c8eddd4 iOS: bridge native SDK logs to unified log, disable core cout
- 48a34dd5 fix: wire group shared file download events to Dart
- 90b68b0d fix: restore iOS group extension serialization
- adf9764b feat: port native SDK 5.1.0 APIs to Flutter
- 347a8c10 feat: add optional sorting to local conversation loading
- d83b93f5 fix(ios): correct deleteContact mapping and scope CI assertions
- 52a5b656 build: separate release dependencies from local SDK overrides
- eee49684 [HIM-23835] fix: align iOS thread callback target
- 41d2cf17 feat(push): add iOS PushKit APIs and make iOS certificate names init options
- 7c38b298 refactor: remove dead method keys and unreachable native wrapper routes
- e907e30c docs: translate the platform package changelogs to English
- 5684b07f fix(ios): emit video thumbnail secret under the thumbnailSecret key
- dc0c4d36 fix: clean up 5.0.0 leftovers and fix the iOS onRequestToJoinDeclined nil crash
- 8294991a feat: add ChatManager.deleteConversations for batch local conversation deletion
- 14b4992f fix(android,ios): drop the deprecated fetch-history sender fallback
- 3d9dd092 docs: expand the 5.0.0 changelog from the porting commits
- bbe3670b fix(ios): use muteMembers instead of the deprecated muteList
- fb201114 feat(sdk)!: unify the disconnection callbacks into onDisconnected(errorCode, info)
- 6358b143 chore: align package dependencies and migrate the example to file_picker 13
- 5c2c6124 fix: let native decide 5.0.0 receipt batch results
- 3066c03c fix: harden 5.0.0 regression verification
- dbab80b3 feat: port native SDK 5.0.0 APIs to Flutter
- c64bdb36 feat: port native SDK 4.22.1-4.24.1 public APIs to Flutter 4.24.0
- 6b2885c8 chore: update ios version to  4.22.2
- 1839a801 fix(ios): align podspec version with Flutter package version 4.22.0
- b77bfeff ci: add standalone Flutter CI stages
- 40fcd106 fix: correct method-result key extraction and iOS init error propagation
- 659f2718 feat: upgrade to 4.22.0 (iOS 4.22.1 / Android 4.22.1)
- f7013574 chore: update
- 1458955d feat: add iOS Swift Package Manager support
- c21a4419 update changelog
- 778c4a26 update version to 4.19.2
- 3d7fc2ad update changelog for 4.19.1
- 600d8ea7 update version to 4.19.1
- 0a466da9 update changelog
- e7698fb0 update dependent ios and android to 4.19.1
- f688ae5f add stream message related code.
- 001e8d05 update version to 4.19.0
- 97c1127b update version to 4.18.0 for ios, android and interface.
- bcaae0d8 update changelogs.
- b1bde911 update dependent ios and android to 4.18.1
- 7fcdbed7 set user_agent for flutter on ios and android.
- 0b3a08bc update CHANGELOG.md files.
- 2e31593b Add webSocketServer and webSocketPort in EMOptions for private deploy.
- 47d77fb2 update ios and android dependents.
- f28786b4 update version from 4.16.0 to 4.17.0

## 1.4.0
- Basing on im_flutter_sdk_ios 4.16.0
