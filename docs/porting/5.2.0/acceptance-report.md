# 验收报告：im_flutter_sdk 5.2.0（官方线）

日期：2026-11-25。目标版本：Flutter 四包 5.2.0；native iOS 5.2.0 / Android 5.2.1。全量变更清单见同目录 [01-api-diff.md](01-api-diff.md)，契约见 [02-contract.md](02-contract.md)，实现备注见 [03-implementation.md](03-implementation.md)，验证证据见 [04-verification.md](04-verification.md)。

## 二维对照表

| 变更项 | iOS 源 | Android 源 | Dart | Android Wrapper | iOS Wrapper | 状态 |
|---|---|---|---|---|---|---|
| `getConnectionState`（连接状态三态） | 有（`connectionState`） | 有（`getConnectionState()`） | 已实现（`ChatConnectionState` + `getConnectionState()`） | 已实现（显式映射） | 已实现（显式映射） | ✅ |
| `EMConnectionState` 枚举（含 Connecting） | 有（值 0/1/2） | 有（ordinal 2/0/1，与 iOS 不同序） | 已实现（自有枚举 + 双端显式映射，不透传） | 已实现 | 已实现 | ✅ |
| `isConnected` 废弃 | 标记废弃未删除 | 标记废弃未删除 | 已加 `@Deprecated`，实现保留；CHANGELOG 已声明 | 通道保留 | 通道保留 | ✅ |
| `disconnectNotifyThreshold` | 有（property，默认 10） | 有（set/get，默认 10） | 已实现（`ChatOptions` 非空 int 默认 10，始终下传） | 已实现 | 已实现 | ✅ |
| 多消息体：`bodies` 列表 | 有（property） | 有（`getBodies()`） | 已实现（`bodies` getter，列表为数据源） | 已实现（toJson/fromJson `"bodies"`） | 已实现（toJson/fromJson `"bodies"`） | ✅ |
| 多消息体：创建入口 | `initWithConversationID:bodies:ext:`（带 ext） | `createMultiBodySendMessage(to, bodies)`（不带 ext） | 已实现（`createMultiBodySendMessage`，形态对齐 iOS 带 ext；Android 侧 ext 经共享字段段设置） | 已实现 | 已实现 | ✅ |
| 多消息体：`appendBody` | 有 | 有 | 已实现（本地追加，经既有 sendMessage 通道） | 无通道改动（Dart 本地能力） | 同左 | ✅ |
| 多消息体：`contentType` | 有（property） | 有（`getContentType()`） | 已实现（本地实时计算，规则与双端 native 逐字一致） | 无通道改动 | 同左 | ✅ |
| `MessageType.MULTIBODY` 枚举 | 有（枚举末尾） | 有（ordinal 9） | 已实现（index 9，追加末尾） | 已实现（ordinal 对齐） | 已实现（显式映射 9） | ✅ |
| `setBodies` | 有（`bodies` readwrite） | 有（`setBodies`） | **未实施**（有意收窄为只读 getter，见待决策 3） | - | - | ⚠️ |
| `body` 赋值语义 | `body` 为首元素 | `setBody` = 替换整个列表 | Dart setter = 替换首个消息体（保留可赋值字段的兼容性取舍，文档已写明） | - | - | ⚠️ |
| `addBody` 行为变更 | - | 由"替换"改为"追加" | Dart 无同名既有 API；新 `appendBody` 即追加语义 | - | - | ✅ |
| `enableChatroomConversation` 文档语义修订 | 有（doc-only） | 有（doc-only） | 已实现（双语注释重写） | - | - | ✅ |
| 下载/发送方法多消息体文档 | 有（doc-only） | 有（doc-only） | 已实现（四方法注释） | - | - | ✅ |
| `usePushInBackground` | 无 | 有（Android-only） | 未实施 | 未实施 | - | ⚠️ 待决策 1 |
| `isPushTokenBound`（push/，diff 范围外发现） | 无 | 有 | 未实施 | 未实施 | - | ⚠️ 待决策 1 |
| `option_userinfo_doc_trim` | - | doc 删减 | 无动作（Flutter 无该段说明） | - | - | ✅ |
| `version_5_2_1`（SDK_5.2.0→5.2.1 仅版本字符串） | - | 有 | - | 依赖 bump 5.2.1 | - | ✅ |

## 未匹配清单（01 节录，含处置结论）

1. `usePushInBackground`（Android 独有）→ **待决策 1**。
2. `isConnected` 废弃处理 → 已处置：Dart 同步标记 `@Deprecated` 并引导 `getConnectionState`，CHANGELOG 声明；native 未删除故通道保留。请用户确认该口径。
3. 连接状态枚举取值两端不一致 → 已处置：Dart 自有枚举（connected=0/disconnected=1/connecting=2，跟随 iOS 序），双端 wrapper 显式映射。
4. 复合消息创建入口形态不一致 → 已处置：Dart 工厂对齐 iOS 形态（targetId + bodies + ext）。
5. `bodies` 取值形态（iOS property / Android getter+setter）→ 已处置：Dart getter 返回有序列表。
6. `isPushTokenBound`（push/ 包）→ 与待决策 1 合并。

## 问题清单

1. **gate 脚本缺陷（已修复）**：`porting_guard.sh` 的 pubspec 查找在目标仓库路径含点目录（`.worktree/` 标准布局）时静默跳过全部版本检查。已在 skill 脚本修复（改为 `$REPO` 内相对查找）。**影响面**：5.1.0 平版的 gate「空输出」证据同样受此缺陷影响，建议按修复后脚本复核 5.1.0 分支（或直接依赖其 `check_versions.dart` CI 结果）。复盘分流建议：入 known-issues 并标 resolved（修复落点：skill 工作区）。
2. CocoaPods CDN 超时一次（网络抖动），`--no-repo-update` 绕过后构建通过，非缺陷。
3. Android `SDK_5.2.0→SDK_5.2.1` 仅 `VERSION` 字符串变更，无 API 影响。

## 待用户决策项

1. **`usePushInBackground`（Android-only）是否平版**：native 5.2.0 新增"App 退后台且推送通道有效时断开 IM 长连接、离线消息走推送"开关（含配套 `EMPushHelper.isPushTokenBound()`）。iOS 无对应 API。选项：a) 不平版（本次不暴露，用户需要时再补）；b) 作为 Android-only 的 `ChatOptions` 字段平版（iOS 侧忽略，文档标注平台差异）。**我的建议**：a) 不平版——平台专属能力且无 iOS 对应，暴露后契约不对称；有实际需求再补成本低。
2. **`isConnected` 废弃口径确认**：当前已在 Dart 标注 `@Deprecated` + CHANGELOG 声明，请确认（native 双端均未删除，短期内不会有移除压力）。
3. **Dart `bodies` 收窄为只读 getter 确认**：native 提供 `setBodies`/可写 `bodies`，Flutter 侧只暴露 getter + `appendBody` + 工厂；`body` setter 语义为"替换首个消息体"（与 Android `setBody` 的"替换整个列表"不同，文档已写明）。如需对齐 native 的 setBodies 能力，可后续追加。

## 状态声明

- 代码处于**未提交**状态（worktree `im_flutter_sdk/.worktree/5.2.0`，分支 `5.2.0`）；提交范围与用户决策项确认后再定。
- 五份阶段产物齐备：`01-api-diff.md`、`02-contract.md`、`03-implementation.md`、`04-verification.md`、本报告。
