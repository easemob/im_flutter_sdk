# 03 - 分层实现记录（5.2.0）

契约冻结后三层并行实施（Dart / Android / iOS 各一个实现 subagent，与主 agent 同级大模型），主 agent 负责收尾（CHANGELOG、example 注册、example 内 `isConnected` 迁移、格式与质量门禁）。

## 变更清单推进状态

### iOS 清单（01-api-diff.md）

| id | 决策 | 状态 | 落点 |
|---|---|---|---|
| `msg_body_type_multibody` | include | implemented | `EnumTools.m` 双向映射 9↔MultiBody；Dart `MessageType.MULTIBODY`（index 9） |
| `msg_bodies` | include | implemented | `MessageHelper.m` toJson 输出 `"bodies"`；fromJson 支持 `"bodies"` |
| `msg_content_type` | include | implemented | Dart `ChatMessage.contentType` 本地计算（规则与 native 逐字一致，无通道字段） |
| `msg_append_body` | include | implemented | Dart `ChatMessage.appendBody`（本地，经既有 sendMessage 通道） |
| `msg_init_with_bodies` | include | implemented | `MessageHelper.m` fromJson 多体路径 `initWithConversationID:bodies:ext:`；Dart 工厂 `createMultiBodySendMessage` |
| `client_is_connected_deprecated` | 见验收 | implemented | Dart `isConnected()` 加 `@Deprecated('Use getConnectionState instead.')`；native 未删除故通道保留 |
| `client_connection_state` | include | implemented | `MethodKeys.h` + `ClientWrapper.m` 分支，显式 switch 映射 |
| `connection_state_connecting` | include | implemented | 同上（映射含 Connecting→2） |
| `option_disconnect_notify_threshold` | include | implemented | `OptionsHelper.m` 读取下传；Dart `ChatOptions.disconnectNotifyThreshold`（默认 10） |
| `option_chatroom_conversation_doc` | include | implemented | Dart 双语注释按新语义重写（3 个构造与 copyWith 文档同步） |
| `chat_download_doc` | include | implemented | `chat_manager.dart` 四方法双语注释补多消息体语义 |

### Android 清单（01-api-diff.md）

| id | 决策 | 状态 | 落点 |
|---|---|---|---|
| `msg_type_multibody` | include | implemented | `EnumTools` 为 ordinal 透传实现，native MULTIBODY ordinal=9 与通道天然对齐，补说明注释（⚠️1） |
| `msg_get_type_changed` | include | implemented | Dart `contentType`/body 分发逻辑对齐；通道 bodies 契约 |
| `msg_get_content_type` | include | implemented | Dart 本地计算（同上） |
| `msg_get_bodies` | include | implemented | `EMHelper.java` toJson `"bodies"`（`message.getBodies()`） |
| `msg_create_multibody` | include | implemented | `EMHelper.java` fromJson 多体路径 `createMultiBodySendMessage(to, bodies)` |
| `msg_add_body_changed` | include | implemented | Dart 无对应既有 API；新 `appendBody` 为追加语义（与 native 新语义对齐），无旧行为残留 |
| `msg_set_bodies` | skip | skip | Dart 契约只做 `bodies` getter（有意收窄，⚠️2）；`body` setter 覆盖单体重置场景 |
| `msg_append_body` | include | implemented | Dart `appendBody` |
| `msg_set_body_doc` | include | implemented | Dart `body` setter 语义="替换首个消息体"（⚠️3，文档已写明） |
| `client_is_connected_deprecated` | 见验收 | implemented | 同 iOS 行 |
| `client_get_connection_state` | include | implemented | `MethodKey.java` + `ClientWrapper.java` 分支，`connectionStateToInt` 显式映射（无 ordinal 透传） |
| `connection_state_enum` | include | implemented | Dart `ChatConnectionState`（chat_enums.dart，barrel 已导出） |
| `option_disconnect_notify_threshold` | include | implemented | `OptionsHelper.fromJson`（EMHelper.java）读取下传 |
| `option_use_push_in_background` | 待决策 | deferred | 未实施，验收报告裁决 |
| `option_chatroom_conversation_doc` | include | implemented | 同 iOS 行 |
| `option_userinfo_doc_trim` | skip | skip | Flutter 侧无该段说明，无动作（01 已标注） |
| `chat_download_doc` | include | implemented | 同 iOS 行 |
| `version_5_2_1` | n/a | implemented | `build.gradle` → 5.2.1（maven 已验证存在） |

## 收尾项（主 agent）

- CHANGELOG×4（English-only，5.x 线风格）：主包记 API 条目与文档修订；android/ios 记 native bump 与 wrapper 改动；interface 记版本同步无接口变更。
- 四包 pubspec 5.2.0 + podspec `s.version` 5.2.0（阶段二已 bump，本阶段 gate 复核通过）。
- example 注册：`ChatClient.getConnectionState` 条目（返回 state index+name）；`ChatClient.isConnected` 条目保留并标注废弃引导（加 `// ignore: deprecated_member_use`）；`ChatManager.sendMessage` 描述补 `bodies` 用法（多体发送经既有条目 + `ChatMessage.fromJson` 的 bodies 解析，无需新条目）。
- **example / integration_test 迁移**（计划外但 CI 必需）：仓库质量门禁为 `flutter analyze --fatal-infos`，`isConnected` 废弃标注使 14 处既有调用全部成为 fatal info。已将 `integration_test/`（9 个文件）与 support 中的调用全部迁移到 `getConnectionState()`（语义一一对应：connected↔true / disconnected↔false），迁移后 example analyze 0 issue。

## ⚠️ / ❌ 汇总

1. ⚠️ Android `EnumTools` MULTIBODY 映射为 ordinal 透传，天然对齐 9，未加显式分支（契约意图是保证 9↔MULTIBODY 成立）。
2. ⚠️ Dart `bodies` 只提供 getter（返回不可修改视图），不提供 `setBodies`（native 有）；收窄为契约有意形态。
3. ⚠️ Dart `body` 由 `late` 字段改为 getter/setter（`_bodies` 列表为唯一数据源）：setter 语义="替换首个消息体"（native Android `setBody` 为"替换整个列表"，Flutter 因保留可赋值字段二选一，文档已写明）；空列表读 `body` 异常由 `LateError` 变 `StateError`（仅误用路径）。
4. ⚠️ `createMultiBodySendMessage` 空 bodies 抛 `ArgumentError`（Dart 惯例，等同 native 返回 nil/null）。
5. ⚠️ iOS fromJson 遇空 `"bodies"` 数组回退单 `"body"` 路径（未定义输入的保守处理）；多体路径中 `fromJson:` 返回 nil 的元素被跳过（NSArray 构造必需，非业务过滤）。
6. ⚠️ Android fromJson 多体路径未对 `createMultiBodySendMessage` 返回 null 加兜底（KI-112 不擅自加过滤；Dart 创建期已校验非空）。
7. ❌ 无。

## 构建副产物处理

- `example/pubspec.lock`、`example/ios/Podfile.lock`、`project.pbxproj` 的构建期改动已 `git checkout` 还原；SPM 构建产生的 `xcshareddata/swiftpm/`（未跟踪）已删除。
- 构建时按仓库 `make config` 等价流程生成了 gitignored 的 `env.dart`/`config.local.json`（example 构建前置，不入库）。

## 验证（静态部分，动态验证见 04）

- `flutter analyze`：主包 0 issue；example 0 issue（迁移后）（Flutter 3.47.0，PATH 默认 fork 不可用，统一用 `fvm versions/custom_official`）。
- `flutter test`（主包）：76 通过（含更新后的 `chat_message_send_contract_test.dart` 对 `"bodies"` 键的期望）。
- Android 构建：`flutter build apk --debug` ✅（真实解析 `hyphenate-chat:5.2.1`）。
- iOS 构建（SPM）：`flutter build ios --debug --no-codesign` ✅（SPM fetch HyphenateChat_iOS 5.2.0；iOS CocoaPods 路径构建见 04）。
- gate 留痕：

```bash
echo '{}' | bash /Users/asterisk/Codes/zuoyu_flutter/.agents/skills/platform-sdk-porting-v2/hooks/porting_guard.sh gate flutter /Users/asterisk/Codes/zuoyu_flutter/im_flutter_sdk/.worktree/5.2.0
```
stdout：空；退出码：0（实现完成、版本注释与 CHANGELOG 就位后）。
