# 升级流程（本地/远程依赖新版本 + 构建 + API 适配）

适用范围：当 Hyphenate/声网聊天 SDK 发布新版本，需要在插件中更新“远程依赖”或替换“本地依赖”资产，并同步适配 Dart 与原生 Wrapper 的新增/修改 API 与回调。

- 前置规范
  - 依赖切换规范：docs/specs/dependency-spec.md
  - API 适配规范：docs/specs/api-adaptation-spec.md
  - speckit 使用说明：docs/skills/speckit.md

- 步骤 1：确定依赖形态（本地 or 远程）
  - Android 本地：当前 checkout 的 jar、so 和 Wrapper 分别位于 `im_flutter_sdk_android/android/src/main/libs/`、`.../jniLibs/`、`.../java/`。
  - Android 远程：通过当前版本分支/tag 的 `im_flutter_sdk_android/android/build.gradle` 切换依赖，不能在同一 checkout 并行保留多个版本。
  - iOS 本地：在 `im_flutter_sdk_ios/ios/` 下替换 `HyphenateChat.xcframework` 与 `ShengwangInfra_iOS/aosl.xcframework`，podspec 使用 `s.vendored_frameworks`。
  - iOS 远程：podspec 取消 `s.dependency 'HyphenateChat', '>= <ver>'` 与 `s.dependency 'ShengwangChat_iOS', '>= <ver>'` 注释，注释掉 `vendored_frameworks`。

- 步骤 2：更新版本号与资产（Git 分支/tag）
  - 当前 5.0：所有 Android Wrapper、JAR、so 都在 `src/main/`，iOS Wrapper 都在 `ios/Classes/`。
  - 新版本：从 `v5.0.0` 创建独立分支，替换当前单版本目录中的原生资产和 Wrapper；完成后创建新的版本 tag。
  - API Matrix：新版本分支直接以自身版本作为 `base.version`，不在 5.0 checkout 中维护旧版本增量表。
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

- 步骤 3.5：事件核对（回调/事件的删除是静默的，编译不报错，必须人工核对）
  - `javap` diff 原生 Listener 接口方法（Android）/ delegate 头文件（iOS）
  - 对照 wrapper 转发：新事件要不要转发、旧事件是否被忽略/改名
  - 决策：wrapper 补转发（映射到协议名）or 记录忽略（matrix 不需要）
  - 参考：`docs/native-api/<ver>/android-api.json`（javap 基线）、`ios-api.json`

- 步骤 4：自检与构建
  - 协议名五方一致性：`python3 im_flutter_sdk/scripts/check_protocol_consistency.py`
  - 命名规范：`docs/specs/naming-convention.md`
  - 规范自检：`im_flutter_sdk/scripts/speckit.sh check`
  - Android 构建：`im_flutter_sdk/scripts/speckit.sh android`（或 `flutter build apk --flavor sdkXXX`）
  - iOS：当前 checkout 直接使用 `Classes/` 单版本 Wrapper；切换 5.1 时通过 Git 分支/tag 替换同一目录，不生成临时 Wrapper。
  - iOS 构建（模拟器）：`im_flutter_sdk/scripts/speckit.sh ios-build`
  - wrapper 差异检查：`im_flutter_sdk/scripts/check_wrapper_diffs.sh`（Android 冗余文件）

- 步骤 4.5：matrix 与映射更新
  - `android.yaml` / `ios.yaml`：versions.<新版本>.removed/added（链式记录相对上一版）
  - 映射文件：重跑 `extract_api_mapping.py`（Android）、`extract_ios_mapping.py`（iOS）

- 步骤 5：完成与提交
  - 变更清单、版本号与 CHANGELOG 更新；
  - 示例工程可启动（必要时在 example 里加最小调用用例验证新 API）。
