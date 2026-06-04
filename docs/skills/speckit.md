# speckit 使用说明（构建与检查）

- 位置：`im_flutter_sdk/scripts/speckit.sh`
- 用法：
  - `speckit android`：构建 Android 示例 App（依赖切换请手动编辑 plugin 的 `build.gradle`）
  - `speckit ios`：在 iOS 示例下执行 `pod install`
  - `speckit build-all`：依次执行 `android` 与 `ios`
  - `speckit check`：运行规范检查脚本（见下）。

- 依赖切换请参考：`docs/specs/dependency-spec.md`

- 检查脚本：`im_flutter_sdk/scripts/spec_check.sh`
  - Android：
    - 校验本地目录是否为不带版本名的 `android/libs/easemob-sdk/`
    - 校验 `jniLibs.srcDirs` 指向 `./libs/easemob-sdk/libs`
    - 校验 `hyphenatechat_*.jar` 存在；避免本地与远程实现同时启用
  - iOS：
    - 校验 podspec 仅启用本地 vendored 或远程依赖之一
    - 如为本地，校验 `HyphenateChat.xcframework` 与 `ShengwangInfra_iOS/aosl.xcframework` 存在
