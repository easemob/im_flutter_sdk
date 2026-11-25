# 04 - 一致性抽查与验证记录（5.2.0）

日期：2026-11-25。工具链：Flutter 3.47.0（`fvm versions/custom_official`，PATH 默认的 ohos fork 不可用于本仓库，见 03）。所有验证在 worktree `im_flutter_sdk/.worktree/5.2.0`（分支 5.2.0）内完成。

## 契约要素逐字抽查（grep 实证）

| 契约要素 | 结果 | 证据 |
|---|---|---|
| 方法名 key `getConnectionState` 三端一致 | ✅ | `chat_method_keys.dart:21` / `MethodKey.java:21` / `MethodKeys.h:27`，值均为 `"getConnectionState"` |
| options key `disconnectNotifyThreshold` 三端一致 | ✅ | Dart toJson `'disconnectNotifyThreshold'`（chat_options.dart:1456）↔ Android `getInt("disconnectNotifyThreshold")`（EMHelper.java:141-142）↔ iOS `aJson[@"disconnectNotifyThreshold"]`（OptionsHelper.m:88-89） |
| 消息 key `"bodies"` 三端一致 | ✅ | chat_message.dart（toJson/fromJson）/ EMHelper.java（4 处）/ MessageHelper.m（3 处） |
| 连接状态映射（显式，不透传） | ✅ | Android `connectionStateToInt`：CONNECTED→0 / DISCONNECTED→1 / CONNECTING→2（ClientWrapper.java:261-268）；iOS switch：Connected→0 / Disconnected→1 / Connecting→2（ClientWrapper.m:479-489）；Dart `ChatConnectionState.values[...]` 读取（chat_client.dart:451） |
| 返回包装 `{getConnectionState: <int>}` | ✅ | iOS `wrapperCallBack:channelName:object:@(state)`（ClientWrapper.m:490-493）；Android `onSuccess(result, channelName, ...)`（ClientWrapper.java:256） |
| 枚举索引 | ✅ | Dart `MessageType` 顺序 TXT(0)…COMBINE(8)、`MULTIBODY`(9)（chat_enums.dart:300）；iOS `EnumTools.m` 双向映射 MultiBody↔9；Android ordinal 透传对齐 9（native MULTIBODY ordinal=9，EnumTools.java:34 注释） |
| 新类型 barrel 导出 | ✅ | `chat_enums.dart`（含 `ChatConnectionState`、`MessageType.MULTIBODY`）被 `im_flutter_sdk.dart:12` 与 `inner_headers.dart:5` 导出 |
| 版本注释 | ✅ | `// 5.2.0` 分布于 Dart 8 处、Android 4 文件、iOS 5 文件 |

## 自检清单（references/flutter.md 验证小节）

- [x] 方法名常量与事件名三端一致（本次无新事件；native 未新增连接回调）
- [x] Dart 请求参数 key 与原生读取 key 一致
- [x] 枚举索引与原生映射一致
- [x] 返回结构可被 Dart 反序列化（int / body JSON 列表复用既有分发）
- [x] 新类型已进入 barrel 导出链
- [x] 四包版本号强一致（5.2.0×4，check_versions 实证）
- [x] iOS podspec 与 Package.swift major.minor 相同（均 5.2.0）；Android 依赖与包同一 major.minor 线（5.2.1 vs 包 5.2.0）；podspec `s.version` 5.2.0 跟随包版本
- [⏭️] 附件/下载类新 API 实机脚本验证：主 checkout 无 `example/scripts/config.json`（凭据不入库），跳过；多消息体收发实机验证建议由用户在可用环境补做

## 验证记录

| 验证项 | 结果 | 失败原因/备注 |
|---|---|---|
| `flutter analyze`（主包） | ✅ | 0 issue |
| `flutter analyze --fatal-infos`（五包，run_quality.sh） | ✅ | 含 example 与 integration_test；14 处 `isConnected` deprecated info 已通过迁移到 `getConnectionState` 消除 |
| `dart format` 检查（run_quality.sh，FORMAT_BASE_SHA=HEAD） | ✅ | |
| `flutter test`（主包） | ✅ | 76/76 通过；含更新后的发送契约测试（`"bodies"` 键期望） |
| `check_case_mapping` / `check_contracts` / `check_versions` | ✅ | 输出：`Versions are consistent: Flutter 5.2.0, Android Native 5.2.1, iOS Native 5.2.0` |
| example 构建（Android `flutter build apk --debug`） | ✅ | 真实解析 `io.hyphenate:hyphenate-chat:5.2.1` 编译（gradle 依赖输出确认） |
| example 构建（iOS SPM） | ✅ | SPM fetch HyphenateChat_iOS 5.2.0；`Built build/ios/iphoneos/Runner.app` |
| example 构建（iOS CocoaPods） | ✅ | 按已知修复序列执行：首次失败（specs 仓库过期 + Podfile.lock 锁 5.1.0）→ `pod install --repo-update` → `pod update HyphenateChat` 时 CDN 超时（网络抖动）→ `--no-repo-update` 重试成功（Installing HyphenateChat 5.2.0）→ 构建通过。SPM 全局开关已还原为 true（用户原配置即显式 true） |
| gate（porting_guard.sh） | ✅ | 输出空，exit 0（命令与此前各阶段留痕一致） |
| API 脚本功能回归 | ⏭️ | 缺 `example/scripts/config.json`（凭据不可用），未执行 |
| 设备冒烟 | ⏭️ | 同上；如需实机冒烟由用户另行安排 |

## 遗留与说明

- CocoaPods CDN（`cdn.cocoapods.org`）出现一次连接超时，属环境网络问题，`--no-repo-update` 绕过后通过；非 SDK 缺陷。
- 构建副产物处理：`example/pubspec.lock`（四包 5.1.0→5.2.0，与 5.1.0 平版提交先例一致，**保留**）、`example/ios/Podfile.lock`（HyphenateChat 5.2.0，先例同样随平版提交，**保留**）；SPM 构建产生的未跟踪 `xcshareddata/swiftpm/` 已删除。
- 本阶段结束后代码处于**未提交**状态（平版纪律：用户确认范围后再提交）。
