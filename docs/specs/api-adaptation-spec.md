# 原生 Wrapper 与 Dart API 适配规范（依据 Changelog）

目标：当上游 SDK 或 Dart 侧 API/回调新增或变更时，原生 Wrapper 与 Dart 层保持一致；如两端命名不一致，以 Android 命名为准。

- 适配流程
  - 1) 阅读变更：以 `CHANGELOG.md` 为准，提取“新增/变更”的 API、回调、事件、枚举与字段。
  - 2) 命名统一：以 Android 端命名为基准统一 Dart 与 iOS；保持 `MethodKey`/`Channel`/`Event` 三侧一致。
  - 3) Wrapper 修改：
    - Android：在 `im_flutter_sdk_android/android/src/.../Wrapper*.java` 增加/调整对应方法与回调派发；确保序列化字段与 Dart 模型一致。
    - iOS：在 `im_flutter_sdk_ios/ios/Classes/*Helper.m` 或 `*Wrapper.m` 同步实现，使用与 Android 一致的方法名和参数键。
  - 4) Dart 对齐：
    - 方法 key：`lib/src/internal/chat_method_keys.dart` 与原生保持一一对应。
    - 事件 key：`lib/src/internal/em_event_keys.dart` 对齐原生派发事件。
    - 模型/枚举：在 `lib/src/models/` 新增或补充字段，构造与 `fromJson`/`toJson` 一致。
  - 5) 端到端验证：
    - 示例工程运行基础用例；新增/变更 API 写最小调用样例（可临时置于 example）。
    - Android 与 iOS 分别完成本地构建验证（参见 `docs/specs/dependency-spec.md`）。

- 命名与兼容性
  - 若 Android/iOS/Dart 命名不一致：统一改为 Android 命名；如需兼容旧名，在 Dart 层提供过渡别名，并标注弃用。
  - 回调/事件：事件名与负载字段名保持一致，避免大小写和下划线差异；数组/分页结果统一使用 `EMCursorResult`/`EMPageResult` 等约定模型。

- 代码位置清单
  - Android：`im_flutter_sdk_android/android/src/main/java/com/easemob/im_flutter_sdk/`
  - iOS：`im_flutter_sdk_ios/ios/Classes/`
  - Dart：`im_flutter_sdk/lib/src/`

- 提交前自检清单
  - [ ] 三端方法/事件 key 集合一致，且大小写一致
  - [ ] Dart 模型字段、`fromJson`/`toJson` 与原生序列化一致
  - [ ] 示例工程可编译（Android assembleDebug；iOS pod install + xcodebuild）
  - [ ] 依赖切换规范符合 `docs/specs/dependency-spec.md`（目录名不带版本，jar 可带版本）

## 自动化 Runner 的 interface 直连边界

- `im_flutter_test` 只依赖 `im_flutter_sdk_interface`，通过
  `Client.instance` 和各 Manager 的 `callNativeMethod` 路由。
- Android 4.23 Runner 直接注册 `im_flutter_sdk_android`，不复制正式
  Wrapper 的业务 API，也不经过 `im_flutter_sdk` Dart 业务层。
- 若某个公开 Dart API 原先由 Dart 组合多个原生调用实现，而 interface 直连
  缺少对应命令，只有当该命令本身代表真实 SDK 能力时才允许补到平台 Wrapper。
  Android MVP 的 `UserInfoManager.fetchOwnInfo` 按“当前登录用户 ID +
  fetchUserInfoByUserId”实现。
- `TestControlChannel` 只能承载 Runner 信息、网络/进程控制和升级快照；不得
  承载登录、联系人、消息、群组等业务 API。
- Android MVP 新增的正式 Wrapper 命令在进入发布版本前，仍须按本规范补齐
  iOS、Dart key/导出和跨端构建验收。
