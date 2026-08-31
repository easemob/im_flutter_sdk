# 依赖切换规范（手动）

本规范说明 im_flutter_sdk 工程在 Android 与 iOS 侧如何“手动”切换本地依赖/远程依赖，并给出构建验证命令。注意：不再使用 `IM_USE_LOCAL_DEPS`、`IM_ANDROID_USE_LOCAL`、`IM_IOS_USE_LOCAL` 等开关，切换完全通过编辑构建文件完成。

- 约定
  - 本地依赖目录名不带版本号；JAR/Framework 文件名可带版本。
  - 本地依赖资产不纳入 Git：Android 的 `android/libs/easemob-sdk/` 整目录、iOS 的 `ios/HyphenateChat.xcframework/` 与 `ios/ShengwangInfra_iOS/` 由 `.gitignore` 忽略；请在本地放置后再构建。

- Android（单版本 checkout）
  - Wrapper：`android/src/main/java/`
  - JAR：`android/src/main/libs/`
  - so：`android/src/main/jniLibs/`
  - 当前 checkout 只编译 Android 5.0，不使用 product flavor 或 Wrapper 合并任务。
  - 新版本通过 Git 分支/tag 替换 `src/main` 内容，不在同一个 checkout 保留多个 SDK。

- iOS（单版本 checkout）
  - Wrapper：`im_flutter_sdk_ios/ios/Classes/`
  - 当前 checkout 只编译 iOS 5.0；不保留 `base500/`、`sdkXXX/` 或临时合并目录。
  - 其他 SDK 版本通过 Git 分支/tag 切换，不在同一 checkout 中生成临时 Wrapper。
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
