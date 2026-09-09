# 验收报告：im_flutter_sdk 4.24.0 平版（native 4.22.1 → 4.24.1）

- 日期：2026-09-08
- 目标仓库/分支：`im_flutter_sdk`，worktree `.worktree/4.24.0`，分支 `4.24.0`（从 `flutter2_stable` 切出）
- 源：iOS emclient-ios `4.22.1→4.24.1`；Android emclient-android `SDK_4.22.1→SDK_4.24.1`
- 全量变更清单：`docs/porting/4.24.0/01-api-diff.md`；契约：`02-contract.md`；实现：`03-implementation.md`；验证：`04-verification.md`
- **代码状态：未提交**（worktree 内全部改动待用户审查后决定提交范围；hooks 按第三档流程强制执行，各阶段 gate 均 exit=0，证据见各阶段产物）

## 一、二维对照表

| 变更项 | iOS 源 | Android 源 | Dart | Android Wrapper | iOS Wrapper | 状态 |
|---|---|---|---|---|---|---|
| `webhookEnv`（消息属性，4.23.0） | 有 | 有 | 已实现（`chat_message.dart:240`） | 已实现（`EMHelper.java:555/:624`） | 已实现（`MessageHelper.m:69/:123`） | ✅ 实机验证：发送+回读 `"webhookEnv":"api-test-env"` |
| 连接错误码 350–354（4.23.0） | 有 | 有（双端同值） | 原生透传，零改动 | - | - | ✅（`ChatError.code` int 透传实证） |
| `useAgoraChatDomain` 移除（4.23.0） | 已删 | 已删 | 从未暴露，无操作 | - | - | ✅ skip（grep 全仓实证无引用） |
| `searchMessagesFromServer`（4.24.0） | 有 | 有 | 已实现（`chat_manager.dart:2657`） | 已实现（`ChatManagerWrapper.java:175/:1384`） | 已实现（`ChatManagerWrapper.m:248/:1649`） | ✅ 实机验证：搜索命中+错误路径(110)+过滤条件 |
| `ChatMessageSearchOption`（新类型） | 有 | 有 | 已实现（新文件） | 解析已实现 | 构造已实现 | ✅ |
| `ChatKeywordListMatchType`（新枚举） | OR=0/AND=1 | OR,AND | 已实现（顺序一致） | `values()[i]` | 强转 | ✅ |
| `ChatSearchServerMessageResult`（新类型） | 有 | 有 | 已实现（新文件） | `SearchServerMessageResultHelper` | `SearchServerMessageResultHelper` | ✅ 实机验证：9 个契约 key 全部回传 |
| `ntpServers`（ChatOptions，4.24.0） | 有 | 有 | 已实现（`chat_options.dart:452`） | 已实现（门控块外） | 已实现 | ✅（编译级；init 配置项，实机未单独验证生效） |
| `groupMessageDidRead:` 新回调（4.24.1，iOS 单端） | 有 | 无变更 | 零改动 | 零改动 | 已迁移（删旧留新） | ✅ 编译级验证（决策 2：暂不回归）；事件实机未触发（需第二账号读群消息，脚本无法构造） |
| `asyncUpdateGroupExtension`（Android 补异步） | 早有 | 新增 | 已有 `updateGroupExtension` | 已迁移异步版（决策 5） | 已有 | ✅ |
| `asyncGetPushConfigsFromServer`（Android 补异步） | 早有 | 新增 | 已有 `getPushConfigsFromServer` | 已迁移异步版（决策 5） | 已有 | ✅ |

构建验证：Android apk ✅ / iOS CocoaPods ✅ / iOS SPM ✅（`04-verification.md` §3）。

## 二、未匹配清单（沿自 01-api-diff.md，现状标注）

1. **keywordList 约束双端不一致**（iOS 1–120/总 120/≤5；Android 1–512/总 1024/≤5，且 iOS 注释自相矛盾）→ 现状：Dart 不做校验，透传由服务端拒绝（实机验证：空列表返回 110 "keywordList must between 1 and 5"，服务端实际约束 1–5 个）。✅ 已决策（§四-1）：**以 iOS 为准**，注释已改，Dart 不加校验。
2. **iOS 4.24.1 `groupMessageDidRead:` 单端变更** → 已按契约迁移（删旧留新规避双发）；原生是否对新旧 delegate 双发未逐行核实；事件负载不变（本就只含 ack 数组）。✅ 已决策（§四-2）：**暂不回归**，仅编译级验证关闭。
3. **Android `EMConversation.getMessage(String, boolean)` Javadoc 语义改写**（`markAsRead=false` 从「不标已读」改为「更新为未读」）→ 未核实实现，Flutter 对应 API 注释未动。✅ 已决策（§四-3）：**不关注**（当前代码无调用）。
4. Android `EMClient.isAutoLogin()` 为 internal use only → 不平版。✅ 已决策（§四-4）：确认内部使用，忽略。
5. 服务端消息搜索为 Console 增值服务 → 本环境（easemob-demo#testngi02）已开通，实机验证通过；其他环境未开通时调用报错属预期。
6. iOS 搜索返回 `EMPageResult`（非 cursor）→ 复用 `ChatPageResult<T>`，无双端分歧，仅备注。
7. 无 API 变化的原生行为修复（sendMessage 失败置 FAIL、登录判断收紧、push token 清空、已读 ack 内存化等）→ 仅备注，无需 Flutter 改动。

## 三、问题清单

| # | 问题 | 处理 |
|---|---|---|
| 1 | 基线 native 依赖三处不一致（podspec 4.22.2 vs SPM/Android 4.22.1，KI-101 同类，known-issues 中"已修复"标注与 flutter2_stable 现状不符） | 本次三处统一 bump 4.24.1 已对齐；KI-101 状态需复盘（见下） |
| 2 | 实现期发现 `im_flutter_sdk_ios.podspec` 的 `s.version`（4.22.0）未随包版本走 | 已按 `1839a801` 先例对齐为 4.24.0；建议升规则：版本 bump 清单加入 podspec s.version |
| 3 | Android wrapper 对 `updateGroupExtension`/`getPushConfigsFromServer` 仍调 native 同步方法（4.24.0 已有异步版） | ✅ 已按决策 5 迁移到异步版（`GroupManagerWrapper.updateGroupExt` / `PushManagerWrapper.getImPushConfigFromServer`） |
| 4 | Dart `ChatSearchServerMessageResult` 的 body 解析复制了 `ChatMessage._bodyFromMap` dispatch（private 不可复用），双份维护点 | ✅ 已决策（§四-6）：**不抽取**，保持现状 |
| 5 | `example/ios/Runner.xcodeproj/project.pbxproj` 被 pod install 周期改动（UUID 噪声） | 已 revert；`Podfile.lock`（HyphenateChat 4.24.1）保留 |
| 6 | iOS `MethodKeys.h`/`ChatManagerWrapper.m` 中 4.24.0 版本段位置在 4.22.0 段之前（非单调） | 纯位置问题，无功能影响；如需调整告知即可 |
| 7 | `example/pubspec.lock` 随版本 bump 自动更新 | 保留（提交范围由用户决定） |

## 四、用户决策（2026-09-08 第二轮，全部闭环）

1. keywordList 双端约束不一致 → **以 iOS 为准**，已修改注释（`chat_message_search_option.dart` 双语注释与 example 注册描述改为「≤5 个，每个 1-120 字符、总共最大 120 字符」）；Dart 层不加校验。
2. `onGroupMessageRead` → **暂不回归**，仅编译级验证关闭。
3. Android `EMConversation.getMessage(String, boolean)` 语义疑点 → **不关注**（当前代码无调用），Dart 注释不动。
4. Android `EMClient.isAutoLogin()` → 确认内部使用，**忽略**不平版。
5. Android wrapper `updateGroupExtension` / `getPushConfigsFromServer` → **已迁移到 4.24.0 异步原生 API**（`asyncUpdateGroupExtension` / `asyncGetPushConfigsFromServer`，回调经 `EMValueWrapperCallBack` + `updateObject`，返回结构与 Dart 侧不变）。
6. body 解析双份维护点 → **不抽取**，保持现状。
7. `example/pubspec.lock` → 确认随编译自动更新，**纳入提交范围**。

## 五、已知问题复盘分流（验收闭环）

- KI-001（505 增值服务未开通）：本次环境已开通未命中，保持 active。
- KI-101（podspec/SPM 版本不一致）：标注"4.24 平版时已修复"但 flutter2_stable 仍复现 → 实际情况是 4.22 平版修了 worktree 分支但未沉淀回稳定分支或后续回退；本条保持 resolved，但**建议升规则**：references/flutter.md 的 bump 核对清单补充「podspec `s.version` 与四包版本对齐」（问题 2 同源）。
- 其余 KI 本次未命中。
