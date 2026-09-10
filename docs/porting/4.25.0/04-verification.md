# 04 - 一致性抽查与验证记录（Flutter 4.25.0）

## 契约要素逐字抽查（grep 实证）

### 方法名 key 三端一致

```
im_flutter_sdk/lib/src/internal/chat_method_keys.dart:127: 'getConversationsFromDBWithCursor'
im_flutter_sdk_android/.../MethodKey.java:107: "getConversationsFromDBWithCursor"
im_flutter_sdk_ios/.../MethodKeys.h:119: @"getConversationsFromDBWithCursor"
```
✅ 值逐字一致。

### Options JSON key 三端一致

| key | Dart toJson | Android EMHelper | iOS OptionsHelper | 结果 |
|---|---|---|---|---|
| `enableChatroomConversation` | `putIfNotNull`（chat_options.dart `// 4.25.0` 段） | `json.has` → `setEnableChatroomConversation` | 直接赋值 | ✅ |
| `autoLoadConversations` | `putIfNotNull`（同上） | `json.has` → `setAutoLoadAllConversations` | 直接赋值 | ✅ |
| ~~`useAgoraChatDomain`~~ | 评审后移除（KI-107，对内品牌开关不暴露） | 已移除 | 已移除 | ✅ 不移植 |

### 请求参数 key（C1）
Dart 发送 `{"cursor", "pageSize"}`；Android `optString("cursor")/optInt("pageSize")`；iOS `param[@"cursor"]/param[@"pageSize"]`。✅

### 返回结构
双端均返回 `EMCursorResult<EMConversation>` 经 `CursorResultHelper.toJson` / `[ret toJson]`，Dart `ChatCursorResult.fromJson` + `ChatConversation.fromJson` 反序列化——与既有 `getPinnedConversationsFromServerWithCursor` 同构。✅

### 版本与依赖
- 四包 pubspec：4.25.0 一致（gate 实证）。
- native 依赖声明三处 4.25.0 一致（podspec/Package.swift/build.gradle，本地覆盖层注释行中保留为注释）。
- podspec s.version 4.25.0 与包版本一致（gate 实证）。

## 验证记录

| 验证项 | 结果 | 失败原因/备注 |
|---|---|---|
| `flutter analyze`（主包） | ✅ | No issues found! |
| `flutter analyze`（example） | ✅ | No issues found! |
| example 构建 Android APK（debug，本地 jar+so） | ✅ | 21.9s；实证 APK 内 3 ABI（arm64-v8a/armeabi-v7a/x86_64）含 libaosl.so + libhyphenate.so（stub，官网包特征，编译期正常） |
| example 构建 iOS CocoaPods（debug，本地 xcframework） | ✅ | pod install：HyphenateChat 远程消失、ShengwangInfra_iOS 1.3.5 出现；Runner.app/Frameworks 含 HyphenateChat.framework + aosl.framework |
| example 构建 iOS SPM（debug，本地 binaryTarget） | ✅ | 远程拉取仅 ShengwangInfra_iOS（cached）；Runner.app/Frameworks 含 HyphenateChat.framework + aosl.framework；构建后已恢复 flutter SPM 全局配置为默认 |
| API 脚本回归（Android 模拟器，emulator-5554，3 步） | ✅ | 首次运行因模拟器无外网 login 308 止步（环境限制）；用户恢复网络后重跑通过：init 注入 `autoLoadConversations:false` 成功、login 成功；page1/page2 返回结构正确（新装模拟器本地无会话，list 为空属预期）；无效 cursor 返回 code 110 INVALID_PARAM "invalid cursor for getConversationsFromDB"（错误路径符合预期，script.done 的 failed=1 即该用例）。日志见 `/tmp/android_425_run.log` |
| API 脚本回归（iOS 模拟器，iPhone 16 Pro，3 步） | ✅ | init 注入 `autoLoadConversations:false` 成功（验证 options 链路端到端）、login 成功；page1 返回 1 会话（tst01）cursor=""；page2 以 page1 cursor 翻页正常；无效 cursor 用例返回 code 110 INVALID_PARAM "invalid cursor for getConversationsFromDB"（错误路径符合预期，script.done 的 failed=1 即该用例）。日志见 `/tmp/ios_425_run.log` |

## 评审后修订复验（2026-09-10）

| 验证项 | 结果 | 备注 |
|---|---|---|
| `flutter analyze`（主包，修订后） | ✅ | No issues found! |
| `flutter analyze`（example，修订后） | ✅ | No issues found! |
| 全仓 grep `useAgoraChatDomain`（排除 docs/porting） | ✅ | 仅存于本地依赖二进制头文件与 build 产物（LOCAL-DEP-TEST 覆盖层），代码侧零残留 |

说明：本次修订（移除 useAgoraChatDomain、copyWith 透传、ChatConversation.toJson、注释补充）均为 Dart 模型/工具层改动，不影响 native 调用链路；此前的构建与双端功能回归结论不受影响（移除的 key 原本就未被测试脚本下发）。

## 阶段四门禁 gate 输出

命令：`echo '{}' | bash /Users/asterisk/Codes/zuoyu_flutter/.agents/skills/platform-sdk-porting-v2/hooks/porting_guard.sh gate flutter .`（cwd = worktree 根）

```
无输出 = 通过（exit=0）
```

## 本地依赖覆盖层（LOCAL-DEP-TEST，未提交、待人工还原）

- 接入命令：`LOCAL_DEPS_ALLOW_DIRTY=1 bash .agents/skills/platform-sdk-porting-v2/scripts/flutter-local-deps.sh apply --repo <worktree> --ios .../HyphenateChat.xcframework --android .../libs`
- 涉及文件（全部带 `LOCAL-DEP-TEST` 注释标记）：`im_flutter_sdk_android/android/build.gradle`、`im_flutter_sdk_ios/ios/im_flutter_sdk_ios.podspec`、`im_flutter_sdk_ios/ios/im_flutter_sdk_ios/Package.swift`
- 拷贝目录（已入 .git/info/exclude）：`im_flutter_sdk_android/android/libs/`（含 symbolLibs 真实 so 替换 stub，仅运行时验证用）、`im_flutter_sdk_ios/ios/im_flutter_sdk_ios/framework/`
- **注意**：脚本 `restore` 的 `git checkout` 会把这三个文件中的 4.25.0 bump 一并回退（bump 本身未提交），人工还原时需从 git diff 中剔除 LOCAL-DEP-TEST 注释段而非直接 checkout。
- 为支持 worktree 流程，脚本本身做了三处兼容性修改（git 检测 rev-parse 化、exclude 路径 `--git-path` 化、dirty guard 增加 `LOCAL_DEPS_ALLOW_DIRTY=1` 放行开关）——脚本属工作区 `.agents/` 资产，此修改可提交。
