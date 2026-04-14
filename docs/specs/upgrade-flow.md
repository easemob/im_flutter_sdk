# 升级流程（本地/远程依赖新版本 + 构建 + API 适配）

适用范围：当 Hyphenate/声网聊天 SDK 发布新版本，需要在插件中更新“远程依赖”或替换“本地依赖”资产，并同步适配 Dart 与原生 Wrapper 的新增/修改 API 与回调。

- 前置规范
  - 依赖切换规范：docs/specs/dependency-spec.md
  - API 适配规范：docs/specs/api-adaptation-spec.md
  - speckit 使用说明：docs/skills/speckit.md

- 步骤 1：确定依赖形态（本地 or 远程）
  - Android 本地：将 so 与 jar 置于 `im_flutter_sdk_android/android/libs/easemob-sdk/libs/`（目录不带版本；jar 可带版本号）。
  - Android 远程：`im_flutter_sdk_android/android/build.gradle` 取消 `implementation 'io.hyphenate:hyphenate-chat:<ver>'` 注释，注释掉本地 `implementation files(...)`。
  - iOS 本地：在 `im_flutter_sdk_ios/ios/` 下替换 `HyphenateChat.xcframework` 与 `ShengwangInfra_iOS/aosl.xcframework`，podspec 使用 `s.vendored_frameworks`。
  - iOS 远程：podspec 取消 `s.dependency 'HyphenateChat', '>= <ver>'` 与 `s.dependency 'ShengwangChat_iOS', '>= <ver>'` 注释，注释掉 `vendored_frameworks`。

- 步骤 2：更新版本号与资产
  - Android：
    - `im_flutter_sdk_android/android/build.gradle`
      - `jniLibs.srcDirs = ['./libs/easemob-sdk/libs']`
      - `implementation files('./libs/easemob-sdk/libs/hyphenatechat_<ver>.jar')`
  - iOS：
    - 本地：替换 `.xcframework` 目录；
    - 远程：更新 `podspec` 中的 `>= <ver>` 约束。

- 步骤 3：依据 CHANGELOG 适配 API/回调（若有）
  - 从 `im_flutter_sdk_android/CHANGELOG.md`、`im_flutter_sdk_ios/CHANGELOG.md` 提取“新增/修改”的 API/事件。
  - 按 `docs/specs/api-adaptation-spec.md` 执行三端对齐：
    - Dart：`lib/src/internal/chat_method_keys.dart`、`lib/src/internal/em_event_keys.dart`、`lib/src/managers/*.dart`、`lib/src/models/*.dart`
    - Android：`im_flutter_sdk_android/android/src/main/java/com/easemob/im_flutter_sdk/*.java`
    - iOS：`im_flutter_sdk_ios/ios/Classes/*.m`、`*.h`
  - 快速核对命令（示例）：
    - `rg -n "getCurrentDeviceId|loadConversationMessagesWithKeyword|loadMessagesWithIds|onStreamMessagesReceived" im_flutter_sdk im_flutter_sdk_android im_flutter_sdk_ios`

- 步骤 4：自检与构建
  - 规范自检：`im_flutter_sdk/scripts/speckit.sh check`
  - Android 构建：`im_flutter_sdk/scripts/speckit.sh android`
  - iOS 安装 Pods：`im_flutter_sdk/scripts/speckit.sh ios`
  - iOS 构建（模拟器）：`im_flutter_sdk/scripts/speckit.sh ios-build`

- 步骤 5：完成与提交
  - 变更清单、版本号与 CHANGELOG 更新；
  - 示例工程可启动（必要时在 example 里加最小调用用例验证新 API）。
