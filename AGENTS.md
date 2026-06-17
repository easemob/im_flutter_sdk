# Superpowers 主规范（总 Agent）

本仓库采用“总 Agent + 执行 Agent”结构：
- 总 Agent（本文件）：统一流程、命名、质量门槛和调用技能（skills）。
- 执行 Agent（三类）：
  1) 远程依赖更新与构建（Remote Deps Agent）
  2) 本地依赖更新与构建（Local Deps Agent）
  3) API/回调适配与一致性检查（API Adapt Agent）

通用规则
- 统一命名：若 Android/iOS/Dart 命名不一致，以 Android 为准；Dart 与 iOS 对齐。
- 依赖切换：不使用 IM_USE_LOCAL_DEPS 等开关；通过编辑构建文件进行“手动切换”，脚本仅在获得确认后代改。
- 文档先行：任何操作前先阅读/更新规范：
  - 依赖切换规范：docs/specs/dependency-spec.md
  - API 适配规范：docs/specs/api-adaptation-spec.md
  - 升级流程规范：docs/specs/upgrade-flow.md
  - speckit 使用：docs/skills/speckit.md
- 构建校验：自检通过 → Android assembleDebug → iOS pod install → iOS 模拟器 build。
- 交付标准：变更点列表、构建日志摘要（成功/失败）、必要的代码与文档补丁。

必用技能（在开始任何动作前先调用/遵循）
- using-superpowers：建立计划、清单与检查点（用户可在私有技能库中查看）。
- speckit：统一执行检查与构建（im_flutter_sdk/scripts/speckit.sh）。

执行 Agent 入口与职责
- Remote Deps Agent：docs/agents/remote-deps-agent.md，脚本 im_flutter_sdk/scripts/agents/remote_deps_agent.sh
- Local Deps Agent：docs/agents/local-deps-agent.md，脚本 im_flutter_sdk/scripts/agents/local_deps_agent.sh
- API Adapt Agent：docs/agents/api-adapt-agent.md，脚本 im_flutter_sdk/scripts/agents/api_adapt_agent.sh


---

## SDK 与测试端分离约定（重要）

为保证发布包干净，自动化测试的桥接逻辑与发布 SDK 已拆分。三个目录职责如下：

| 目录 | 职责 | 是否随发布 |
|---|---|---|
| `im_flutter_sdk/`（含 `_android`/`_ios`/`_interface`） | 发布层 SDK（联合插件本体）。**测试时不改动，仅版本升级**。 | 是 |
| `im_flutter_test/` | 被测设备 App：承载 WebSocket 桥接、事件转发、配置加载、媒体素材、连接 UI。`path` 依赖 `im_flutter_sdk`。 | 否（测试专用） |
| `native-auto-test/` | Python 用例端，通过同一 WebSocket + topic 驱动 `im_flutter_test`。 | 否 |

### 日常测试工作流
- 构建 `im_flutter_test` 装到设备/模拟器 → `native-auto-test` 跑 pytest 用例驱动。
- 桥接采用通用 `callNativeMethod(manager, cmd, info)` 转发：**新增用例通常无需改动 `im_flutter_sdk` 与 `im_flutter_test`**，只在 Python 侧发新的 manager/cmd 即可。

### 何时改 `im_flutter_test`
- 需要转发新的 SDK 事件回调 → `im_flutter_test/lib/bridge/event_bridge_handler.dart`。
- 需要新的发送便利 / 序列化辅助。

### 何时改 `im_flutter_sdk`
仅两种情况，均非"测试脚手架改动"：
1. SDK 版本升级。
2. 用例要测的能力，SDK/原生尚未暴露（全栈真功能，需 Dart + Android + iOS 同步实现，放不进 `im_flutter_test`）。判定标准：能映射到原生 SDK 真实能力、对 App 开发者有用、不设置时不改变行为 → 属 SDK 功能；仅服务测试桥接、脱离测试无意义 → 放 `im_flutter_test`。

### ⚠️ 升级 SDK 时必须保留的"测试支撑增量"
这些是本仓库相对官方 stable 的增量，`im_flutter_test` 的桥接依赖它们；**版本升级时务必一并迁移/保留，否则桥接编译不过或对应用例跑不了**：
- 公开 API：`EMChatManager.sendMessageWithType` + `buildOutgoingMessage` + `EMSendMessageType`（`em_chat_enums.dart`）；各 `sendXxxMessage` 经其分发。
- 内部符号（桥接通过 `package:im_flutter_sdk/src/...` 实现引用）：`EMLog`（`src/tools/em_log.dart`）。
- 公开导出：`ChatMethodKeys`（经 `src/internal/inner_headers.dart`）。
- 全栈功能（Dart + Android + iOS 三端）：`EMOptions.enableUserInfo` / `enableAutoSyncContacts` / `syncDataWebSocketServer/Port`；好友同步事件 `onFriendStartSync` / `onFriendSyncFinished` / `onFriendUserInfoDidUpdated`；`EMMessage.webhookEnv`；`downloadBigImage`；`EMContact.updatedAt/userInfo`；`EMCombineMessageBody` 接收侧 `messageList/compatibleText`；`group_member_info` 扩展字段。
- 11 个 model 的 `toJson/toString`（供事件序列化）：`em_cursor_result` / `em_page_result` / `em_presence` / `em_group_message_ack` / `em_message_reaction` / `reaction_operation` / `message_pin_info` / `login_extension_info` / `recall_message_info` / `em_chat_thread` / `em_push_configs`。

### 桥接对 SDK 的依赖边界
- 公开 API：`package:im_flutter_sdk/im_flutter_sdk.dart`。
- 接口包：`package:im_flutter_sdk_interface/...`（`Client.instance`、`ManagerMixin.callNativeMethod`）。
- 实现引用（lint 容忍）：`package:im_flutter_sdk/src/tools/em_log.dart`。
- 媒体素材：放在 `im_flutter_test/assets/media/`，由桥接 `_prepareDefaultMediaPath` 在用例未传 `filePath` 时从测试 App 自带 assets 加载（**不再打进 SDK 包**）。

### 构建校验
- 测试端：`cd im_flutter_test && flutter analyze && flutter build ios --simulator`（Android 用 `flutter build apk --debug`）。
- 发布 SDK 自检：`cd im_flutter_sdk && flutter analyze`。
