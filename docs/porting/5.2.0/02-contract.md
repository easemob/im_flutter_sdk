# 02 - 基线调查与跨端契约（5.2.0）

日期：2026-11-25。目标仓库 worktree：`im_flutter_sdk/.worktree/5.2.0`，分支 `5.2.0`（从 `5.x` 切出，开工 HEAD `f42c7594`，开工 `git status --short` 无输出）。

## 基线结论

- 目标版本：四包 `5.2.0`；iOS native 5.2.0（podspec + Package.swift 双路径），Android native 5.2.1（与包同一 major.minor 线，KI-113 规则）。
- native 依赖 bump（阶段二第一步，已完成）：
  - `im_flutter_sdk_ios/ios/im_flutter_sdk_ios.podspec`：`HyphenateChat` 5.1.0 → 5.2.0；`s.version` 5.1.0 → 5.2.0（跟随包版本）
  - `im_flutter_sdk_ios/ios/im_flutter_sdk_ios/Package.swift`：`exact: "5.1.0"` → `"5.2.0"`（SPM tag 5.2.0 已确认存在：`git ls-remote` → `27af80f0`）
  - `im_flutter_sdk_android/android/build.gradle`：`io.hyphenate:hyphenate-chat:5.1.0` → `5.2.1`（maven 已确认有 5.2.1）
  - 四包 `pubspec.yaml`：5.1.0 → 5.2.0（随本阶段一起 bump，使 gate 版本门禁可判；CHANGELOG 在阶段三收尾）
  - 发布渠道核对：CocoaPods trunk 已有 HyphenateChat 5.2.0（2026-11-09）；SPM tag 存在；maven 5.2.1 存在。
- 关键基线事实：
  - `ChatClient.isConnected()` 已存在（`chat_client.dart:403`，key `isConnected` 三端一致）→ 本次仅加 `@Deprecated` 与新增 `getConnectionState`。
  - Dart 消息模型为单 `body`（`late ChatMessageBody body`），无 `bodies`/`appendBody`/`contentType`，无 `setBody`/`addBody` 公开方法。
  - `MessageType` 枚举（`chat_enums.dart`）顺序 TXT(0)…COMBINE(8)，通道按 `type.index` 整型序列化 → `MULTIBODY` 只能追加到末尾（index 9），两端 native 枚举亦在末尾（Android `MULTIBODY` ordinal 9；iOS `EMMessageBodyTypeMultiBody` 在枚举末尾），索引天然对齐。
  - 消息通道 JSON 现为单 `"body"` 键：Dart `toJson` 写 `body`；Android `EMHelper` / iOS `MessageHelper` 读写 `body`。
  - 连接状态无任何既有 Dart API/枚举；native 未新增连接事件回调（Android `EMConnectionListener` 仅文档变化）→ 本次无事件契约。
  - options 链路：Android `OptionsHelper.fromJson`（`ClientWrapper.java:293`）、iOS `OptionsHelper.m` 按 key 读取；Dart `ChatOptions.toJson` 固定键集合。
- known-issues 浏览结论：命中 KI-113（版本比对忽略 patch，已按此执行 bump 与门禁）；KI-101（podspec/SPM 同步 bump，已执行）；KI-110（SPM 优先，pod 5.2.0 已上架，双路径均可构建）；KI-112（wrapper 不得擅自加过滤，多消息体实现只做形态转换）；KI-003/KI-104（阶段四脚本验证时遵守）。KI-107（useAgoraChatDomain 对内开关不平版）与本次无关。
- hooks：`.codex/hooks.json` 已按 skill 模板渲染到 worktree 根（Codex 侧需用户 `/hooks` 信任）。本 harness 无 Codex hooks 机制，按 skill 第 3 档流程强制：每阶段手动跑 gate 并附输出；不主动执行 git 提交类命令。
- **gate 脚本修复（本阶段发现）**：`porting_guard.sh` 的 pubspec 查找用 `-not -path '*/.*'`，当目标仓库路径本身含点目录（`.worktree/` 标准布局）时全部结果被排除，版本检查静默跳过。已改为在 `$REPO` 内相对查找（`cd "$REPO" && find . …`），修复后门禁能正确抓到四包不一致（修复过程中实证：android 包漏改时被 block）。5.1.0 平版的 gate「空输出」亦受此缺陷影响，本记录作为复盘依据。
- gate 留痕（native bump + 四包版本 bump 后、分层实施前）：

```bash
echo '{}' | bash /Users/asterisk/Codes/zuoyu_flutter/.agents/skills/platform-sdk-porting-v2/hooks/porting_guard.sh gate flutter /Users/asterisk/Codes/zuoyu_flutter/im_flutter_sdk/.worktree/5.2.0
```
实际 stdout：空；退出码：0。

## 冻结契约

### A. 连接状态（client）

| 要素 | 契约 |
|---|---|
| Dart API | `ChatClient.getConnectionState()` → `Future<ChatConnectionState>` |
| Dart 枚举 | `ChatConnectionState { connected(0), disconnected(1), connecting(2) }`，定义于 `chat_enums.dart`，barrel 导出链同步检查 |
| 方法名 key | `getConnectionState`（Dart `ChatMethodKeys` / Android `MethodKey` / iOS `MethodKeys.h` 三端逐字一致） |
| 返回包装 | `{getConnectionState: <int>}`，int 为 Dart 枚举 index（遵循 `{<方法名 key>: object}` 包装约定） |
| iOS 映射 | `EMConnectionConnected→0`、`EMConnectionDisconnected→1`、`EMConnectionConnecting→2`。**显式 switch，不透传**（iOS native 值恰好同序，仍显式映射防漂移） |
| Android 映射 | `EMConnectionState.CONNECTED→0`、`DISCONNECTED→1`、`CONNECTING→2`（native ordinal 为 2/0/1，**必须显式 switch**） |
| `isConnected` | Dart 加 `@Deprecated('Use getConnectionState instead.')`，实现与通道不变（native 未删除，仅标记废弃） |

### B. 断开通知宽限（client/options）

| 要素 | 契约 |
|---|---|
| Dart | `ChatOptions.disconnectNotifyThreshold`，`int` 非空，默认 `10`；`toJson` 固定输出 key `disconnectNotifyThreshold`；双语注释语义对齐 native（可恢复断开的宽限秒数，≤0 关闭延迟） |
| Android | `OptionsHelper.fromJson` 读 `disconnectNotifyThreshold` → `options.setDisconnectNotifyThreshold(int)` |
| iOS | `OptionsHelper.m` 读 `disconnectNotifyThreshold` → `options.disconnectNotifyThreshold` |
| 缺 key 行为 | native 默认 10；Dart 始终下传（非空字段），无兼容分支 |

### C. 多消息体（chat）

| 要素 | 契约 |
|---|---|
| 枚举 | `MessageType` 末尾追加 `MULTIBODY`（index 9，既有索引不变）。Android `EnumTools` / iOS `EnumTools` 增加 9↔MULTIBODY 映射；该值只出现在消息级，单个 body 的 `type` 永远是具体类型 |
| Dart `ChatMessage.bodies` | `List<ChatMessageBody> get bodies`：完整有序列表，首元素即 `body`；单消息体时长度 1。内部以列表为唯一数据源，`body` getter 返回首元素（保持既有 `body` 可用语义） |
| Dart `ChatMessage.appendBody` | `void appendBody(ChatMessageBody body)`：本地追加到列表末尾，发送前调用；与 native 一致，空 body 不入列（Dart 类型非空，天然免疫） |
| Dart 工厂 | `ChatMessage.createMultiBodySendMessage({required String targetId, required List<ChatMessageBody> bodies, ChatType chatType = ChatType.Chat, Map<String, dynamic>? ext})`：形态对齐 iOS（带 ext）；`bodies` 为空时断言/抛异常（Dart 侧创建期校验，等同 native 返回 nil/null 的语义，⚠️ 形态按 Dart 惯例，报告中标注） |
| Dart `contentType` | `MessageType get contentType`：本地实时计算——多体 `MULTIBODY`、单体该体类型、无体兜底 `TXT`（与双端 native 计算规则逐字一致，无通道字段） |
| 通道 JSON（发送 Dart→native） | message toJson 同时输出 `"body"`（首个体，向后兼容）与 `"bodies"`（完整有序列表，每项为既有 body JSON 结构）。native fromJson：有 `"bodies"` 按列表构造，否则走原 `"body"` 单路径 |
| 通道 JSON（接收 native→Dart） | native toJson 输出 `"body"`（首个体）+ `"bodies"`（完整列表）。Dart fromJson：优先 `"bodies"`，缺失回退 `"body"` |
| Android 构造 | 多体：`EMMessage.createMultiBodySendMessage(to, bodies)`，再统一设置既有字段（attributes/chatType 等，与原 fromJson 流程一致）；单体：原路径不变 |
| iOS 构造 | 多体：`[[EMChatMessage alloc] initWithConversationID:to bodies:bodies ext:ext]`（ext 即 attributes）；单体：原路径不变 |
| 方法名 key | 无新增（构造与追加都在 Dart 本地完成，经既有 `sendMessage` 通道下发） |

### D. 注释同步（doc-only，不改签名）

| 项 | 契约 |
|---|---|
| `ChatOptions.enableChatroomConversation` | 双语注释按 native 新语义重写：控制"本地会话列表是否包含聊天室会话"，不控制创建/存储、不影响收发（对齐 5.2.0 双端文档） |
| `ChatManager` 下载/发送注释 | `sendMessage`（附件进度消息级聚合）、`downloadAttachment`、`downloadThumbnail`、`downloadBigImage` 双语注释补多消息体语义（适用类型、静默跳过、进度聚合、请求级单次回调），对齐 native 5.2.0 文档 |

### 版本注释与 CHANGELOG

- 新代码附近按现有风格标注 `// 5.2.0` / `#pragma mark 5.2.0`。
- CHANGELOG（5.x 线 English-only）：主包记 API 条目（connectionState、disconnectNotifyThreshold、多消息体、isConnected 废弃、注释语义修订）；android/ios 包记 native 依赖 bump 与 wrapper 改动；interface 包无改动则在阶段三确认是否需要版本条目（四包版本强一致 bump，条目可为空版本说明——按仓库既有先例处理，⚠️ 阶段三核对）。

## 待决策清单（不进契约，验收报告统一裁决）

1. `usePushInBackground`（Android-only，见 01-api-diff 未匹配清单 1/6）：是否作为 Android-only option 平版。
2. `isConnected` 废弃的对外口径：CHANGELOG 是否声明 deprecated（建议声明，native 双端均已标记）。

## 阶段二门禁自查

- [x] native 依赖 bump 完成，各处版本互核一致（gate 实证通过，输出空/exit 0）
- [x] 契约逐项定死，无"待猜"项（不定项已列入待决策清单）
- [x] 开工 `git status` 干净、分支正确（`5.2.0`，自 `5.x` 切出）；当前改动均为本阶段计划内产物
- [x] known-issues 已浏览，命中项已规避（见上）
- [x] hooks 已安装（`.codex/hooks.json` 已渲染；本 harness 按流程强制手动 gate）
