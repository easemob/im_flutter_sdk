# 依赖切换规范（手动）

本规范说明 im_flutter_sdk 工程在 Android 与 iOS 侧如何“手动”切换本地依赖/远程依赖，并给出构建验证命令。注意：不再使用 `IM_USE_LOCAL_DEPS`、`IM_ANDROID_USE_LOCAL`、`IM_IOS_USE_LOCAL` 等开关，切换完全通过编辑构建文件完成。

- 约定
  - 本地依赖目录名不带版本号；JAR/Framework 文件名可带版本。
  - 本地依赖资产不纳入 Git：Android 的 `android/libs/easemob-sdk/` 整目录、iOS 的 `ios/HyphenateChat.xcframework/` 与 `ios/ShengwangInfra_iOS/` 由 `.gitignore` 忽略；请在本地放置后再构建。

- Android
  - 本地目录（不带版本号）: `im_flutter_sdk_android/android/libs/easemob-sdk/`
  - JAR 可带版本，例如: `hyphenatechat_4.20.0.jar`
  - 切换方式（手动编辑 `im_flutter_sdk_android/android/build.gradle`）
    - 默认本地依赖：
      - `sourceSets.main.jniLibs.srcDirs = ['./libs/easemob-sdk/libs']`
      - `implementation files('./libs/easemob-sdk/libs/hyphenatechat_4.20.0.jar')`
    - 远程依赖：将上面的本地 `implementation` 注释掉，取消注释下面一行：
      - `implementation 'io.hyphenate:hyphenate-chat:4.19.1'`

- iOS
  - 切换方式（手动编辑 `im_flutter_sdk_ios/ios/im_flutter_sdk_ios.podspec`）
    - 默认本地依赖：
      - `s.vendored_frameworks = 'HyphenateChat.xcframework', 'ShengwangInfra_iOS/aosl.xcframework'`
    - 远程依赖：注释掉上面的 `vendored_frameworks` 行，取消注释以下依赖：
      - `s.dependency 'HyphenateChat', '>= 4.19.1'`
      - `s.dependency 'ShengwangChat_iOS', '>= 1.3.2'`
  - 切换后执行：`cd im_flutter_sdk/example/ios && pod install`

- 构建辅助（speckit）
  - `im_flutter_sdk/scripts/speckit.sh android` → 构建 Android 示例
  - `im_flutter_sdk/scripts/speckit.sh ios` → 在 iOS 示例下执行 `pod install`
  - `im_flutter_sdk/scripts/speckit.sh build-all` → 依次执行两者
