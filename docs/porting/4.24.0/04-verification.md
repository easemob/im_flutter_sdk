# 阶段四：一致性抽查与验证（Flutter 4.24.0）

## 1. 契约要素逐字 grep 抽查（全过）

- 方法名 key `searchMessagesFromServer` 三端逐字一致：
  - `chat_method_keys.dart:459` / `MethodKey.java:397` / `MethodKeys.h:421`，值均为 `"searchMessagesFromServer"`。
- 请求 key：Dart 下发 `option`/`pageSize`/`pageNum`（`chat_manager.dart:2697-2699`）；option 子 key `keywordList`/`keywordMatchType`/`conversationId`/`msgTypes`/`startTime`/`endTime`/`searchScope`（`chat_message_search_option.dart:79-90`）与 Android（`ChatManagerWrapper.java:1386-1429`）、iOS（`ChatManagerWrapper.m:1655-1692`）读取 key 逐字一致。
- 返回元素 key `msgId`/`body`/`attributes`/`from`/`to`/`convId`/`chatType`/`timestamp`/`highlightTexts` 三端逐字一致（Dart `chat_search_server_message_result.dart:20-41`；Android `EMHelper.java` SearchServerMessageResultHelper；iOS `SearchServerMessageResultHelper.m`）。
- `webhookEnv` 三端 key 一致（`chat_message.dart:966/:994`；`EMHelper.java:555-556/:624`；`MessageHelper.m:69/:123-124`）。
- `ntpServers` 三端均落位（`chat_options.dart`；`EMHelper.java:164-172` 在 `!enableDNSConfig` 门控块外；`OptionsHelper.m:105-108`）。
- iOS `groupMessageDidRead`：旧双参数签名已删，仅剩新单参数实现（`ChatManagerWrapper.m:1481`）；事件名 `onGroupMessageRead` 与负载不变。
- 枚举顺序：`ChatKeywordListMatchType` OR=0/AND=1 与 iOS `EMKeywordListMatchTypeOR/AND`（`EMMessageSearchOption.h`，4.24.1 tag 核实）、Android `EMKeywordListMatchType{OR,AND}`（SDK_4.24.1 核实）一致。

## 2. 自检清单逐项

| 项 | 结果 |
|---|---|
| 方法名常量与事件名三端一致 | ✅（见上） |
| Dart 请求参数 key 与原生读取 key 一致 | ✅（见上） |
| 枚举索引与原生映射一致 | ✅（keywordMatchType 双端核实；searchScope/msgTypes 复用既有已验证映射） |
| 返回结构可被 Dart 反序列化 | ✅（PageResult `count`+`list` 复用；`highlightTexts` 为 `List<String>?`，`.cast<String>()`） |
| 新类型进入 barrel 导出链 | ✅（`im_flutter_sdk.dart:15-16`、`inner_headers.dart:24-25`） |
| 四包版本号一致 | ✅（4.24.0 × 4） |
| 三处 native 依赖版本一致 | ✅（podspec / Package.swift / build.gradle 均 4.24.1，上游可用性已核） |
| 错误码 350–354 透传 | ✅ 零改动：`ChatError.code` 为 `final int code` 原生透传，无白名单（`chat_error.dart:18`） |
| 附件/下载/转写类新 API 实机验证 | N/A（本次无此类新 API）；新增 API 实机验证见第 4 节 |

## 3. 构建验证

| 构建 | 命令 | 结果 |
|---|---|---|
| Android example | `flutter build apk --debug` | ✅ `✓ Built build/app/outputs/flutter-apk/app-debug.apk`（38.9s；仅 Java 8 obsolete 等既有告警） |
| iOS example（CocoaPods） | `flutter build ios --debug --no-codesign` | ✅ `✓ Built build/ios/iphoneos/Runner.app`（37.7s）；前置需 `pod install --repo-update` + `pod update HyphenateChat`（Podfile.lock 锁 4.22.2、本地 specs 过期——常规 bump 后操作，非代码问题） |
| iOS example（SPM） | `flutter config --enable-swift-package-manager` 后同上，构建后恢复原配置 | ✅ `✓ Built build/ios/iphoneos/Runner.app`（33.2s；HyphenateChat_iOS 经 SPM 从 GitHub 拉取 4.24.1；构建后已执行 `--no-enable-swift-package-manager` 恢复原配置） |

## 4. 实机验证（可选档，已执行）

- 环境：iPhone 16 模拟器（iOS，CocoaPods 模式），config.json 从主 checkout 拷贝（gitignored，不入库）。
- 验证脚本：`example/scripts/script_424_apis.json`，运行方式 `flutter run --dart-define=API_SCRIPT=... --dart-define=API_CONFIG=...`。
- 结果（`script.done`：total=4, failed=1，failed 为预期的错误路径步骤）：

| 步骤 | 结果 |
|---|---|
| `sendMessage` 带 `webhookEnv: "api-test-env"` | ✅ 发送成功，返回消息 JSON 含 `"webhookEnv":"api-test-env"`——属性全链路（Dart→native→事件回读）验证通过 |
| `searchMessagesFromServer` 关键词 `["webhookEnv"]` | ✅ 成功：`count=1`，命中刚发送的消息，list 元素含全部契约 key（msgId/body/from/to/convId/chatType/timestamp/highlightTexts），高亮为 `4.24 API auto test: <em>webhookEnv</em> message`——该 appKey 已开通增值服务，KI-001 未命中 |
| 错误路径：空 `keywordList` | ✅ 符合预期：返回 `error {code:110, "keywordList must between 1 and 5"}`，错误正常透传、无崩溃 |
| 带 `msgTypes:[0]` + `conversationId` 过滤搜索 | ✅ 成功：`count=1`，结果同上 |

- 完整日志：`[APITEST]` 记录共 18 条（seq 1–18），无 native 崩溃、无超时挂死。
- 未覆盖项：`onGroupMessageRead` 事件（触发需第二账号读群消息，脚本模式无法构造）——iOS 回调迁移仅做编译级验证 + 负载不变论证，实机事件未触发，记入验收报告。

## 5. 门禁 gate 实证（最终）

```text
$ echo '{}' | bash hooks/porting_guard.sh gate flutter <worktree>
exit=0
```
