# 依赖切换规范（手动）

本规范说明 im_flutter_sdk 工程在 Android 与 iOS 侧如何“手动”切换本地依赖/远程依赖，并给出构建验证命令。注意：不再使用 `IM_USE_LOCAL_DEPS`、`IM_ANDROID_USE_LOCAL`、`IM_IOS_USE_LOCAL` 等开关，切换完全通过编辑构建文件完成。

- 约定
  - 本地依赖目录名不带版本号；JAR/Framework 文件名可带版本。
  - 本地依赖资产不纳入 Git：Android 的 `android/libs/easemob-sdk/` 整目录、iOS 的 `ios/HyphenateChat.xcframework/` 与 `ios/ShengwangInfra_iOS/` 由 `.gitignore` 忽略；请在本地放置后再构建。

- Android（多版本 flavor 拓扑，main 不含 wrapper）
  - 基线：`im_flutter_sdk_android/android/src/base500/` = 5.0 全部资产（`java/` 全套 wrapper + `libs/` jar + `jniLibs/` so，唯一基线，不随版本复制）；flavor `sdk500` 仅是构建入口，资产全在 base500
  - 差异：`src/<flavor>/java/` 只放相对基线的差异 wrapper（同名文件）；构建时由 build.gradle 的 merge 任务将「基线复制 + 差异覆盖」合并到 `build/mergedSrc/<flavor>/java/` 再编译
  - jar / jniLibs：`src/<flavor>/libs/`、`src/<flavor>/jniLibs/`（jar 可带版本，如 `hyphenatechat_5.0.0.jar`）
  - 新增 SDK 版本（如 5.1）：
    1. 放 jar + jniLibs 到 `src/sdk501/{libs,jniLibs}`
    2. `src/sdk501/java/` 只写相对 5.0 基线的差异 wrapper（不变的不要复制）
    3. `build.gradle` 加 `productFlavors.sdk501` 与 `sourceSets.sdk501`（复用 `mergeWrapperSrc`）
    4. 验证：`flutter build apk --debug --flavor sdk501` + `scripts/check_wrapper_diffs.sh`
  - 远程依赖（改为远程时，注释掉 `files(...)`，取消注释 `sdkXXXApi 'io.hyphenate:hyphenate-chat:<ver>'`）

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
