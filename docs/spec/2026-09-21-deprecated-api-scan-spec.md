# 废弃 API 扫描规格（wrapper 层）

日期：2026-09-21
状态：已实施（5.0.0 分支工作区），验证结果见 §9.1
目标仓库：`/Users/asterisk/Codes/zuoyu_flutter/im_flutter_sdk/.worktree/5.0.0`，分支 `5.0.0`
参考实现：`react-native-chat-sdk/.worktree/5.0.0/scripts/scan-deprecated*.sh`、`parse-deprecated-*.sh`、`.github/workflows/ci.yml`

## 1. 背景与问题

wrapper 层（`im_flutter_sdk_android` 的 Java、`im_flutter_sdk_ios` 的 ObjC）直接调用 native 的 HyphenateChat API。native 把某个 API 标为废弃（Android `@Deprecated`、iOS `NS_DEPRECATED`）后，wrapper 的调用点会在编译期产生警告：

```
ChatManagerWrapper.java:502: warning: [deprecation] downloadAttachment(EMMessage) in EMChatManager has been deprecated
ChatroomHelper.m:23:29: warning: 'muteList' is deprecated: Use muteMembers instead [-Wdeprecated-declarations]
```

这些警告平时淹没在构建输出里，升级 native 版本时也没有清单可对。RN 侧已用脚本把警告提取成报告（`scan-deprecated.sh`），Flutter 侧目前没有对应机制，现状：

| 编号 | 问题 |
| --- | --- |
| S1 | 废弃调用没有清单：只能靠在构建日志里翻，或等 native 真的删掉 API 后编译失败 |
| S2 | 全量构建日志不保留：`flutter build` 的输出看完即弃，事后无法复盘当时有哪些警告 |
| S3 | Flutter 的非 verbose 构建**根本不输出**这些警告（Android 见 §4.1 说明，iOS 见 §4.2），照搬 RN"tee 构建日志"的做法拿不到数据 |
| S4 | 增量构建不重发警告：直接解析一次普通构建的日志多半是 0 条，且与"确实没有废弃调用"不可区分 |

## 2. 目标与非目标

目标：

- 一条命令产出 wrapper 层的废弃 API 调用清单（文件、行号、API、替代建议）。
- 日志留档，报告可复核：原始构建日志与解析结果一起落盘。
- 结果可信：区分"确实没有废弃调用"和"这次扫描没测到"。
- 沿用仓库既有约定（`tool/ci/*.sh` 编排、`im_flutter_sdk/tool/ci/check_*.dart` 纯函数 + 单测）。

非目标：

- **不接 CI**：本轮不新增 workflow、job、定时或手工触发；CI 复用方案在 §4.2 写清但不落地。
- **不做门禁**：发现废弃调用不让命令失败（与 RN 一致，RN 也只上传 artifact）。
- 不修改任何 wrapper 代码去消除已发现的调用。
- 不扫 Dart 侧 `@Deprecated`（`em_compat.dart` 与未来要废弃的公开 API），另开任务。

## 3. 术语

| 术语 | 含义 |
| --- | --- |
| 废弃调用（deprecated call） | wrapper 源码里调用 native 已标记废弃的 API，编译期产生 `[deprecation]` 或 `-Wdeprecated-declarations` 警告 |
| 全新编译（fresh compile） | 删掉编译产物后的完整重编译。只有全新编译会重发所有警告 |
| 复用编译（reused compile） | Gradle 判定任务 `UP-TO-DATE` / `FROM-CACHE` 而跳过编译，此时警告不会再出现 |
| 健全性检查（sanity check） | 用于区分"扫描没测到"和"确实没有"的判定：构建是否成功、日志是否显示复用编译 |

## 4. 日志来源与采集契约

### 4.1 本地扫描（本轮实现）

`make scan-deprecated [PLATFORM=android|ios]` → `tool/ci/scan_deprecated.sh`，两端各自先 `clean` 再编译，只编 wrapper 所在模块：

| 平台 | 命令（工作目录） | 为什么这样取日志 |
| --- | --- | --- |
| Android | `./gradlew :im_flutter_sdk_android:clean :im_flutter_sdk_android:compileDebugJavaWithJavac -I <repo>/tool/ci/enable_deprecation_lint.gradle --console=plain`（`im_flutter_sdk/example/android`） | AGP 默认**不开** `-Xlint:deprecation`，不开只有 `Note: Some input files use or override a deprecated API.`（无文件行号）；`-I` 注入不污染插件的 `build.gradle`。只编插件模块（不 `assembleDebug`），因为 wrapper 是唯一有我们源码的模块 |
| iOS | `xcodebuild -project Pods/Pods.xcodeproj -target im_flutter_sdk_ios -configuration Debug -sdk iphonesimulator -quiet clean build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO`（`im_flutter_sdk/example/ios`） | `-quiet` 官方语义就是"只打印 warning 和 error"，日志小且正好只剩我们要的行；clang 的 `-Wdeprecated-declarations` 默认开启，无需额外 flag |

实测的日志体积（2026-09-21）：Android 约 11 KB；iOS 约 690 KB / 5200 行——`-quiet` 并不等于"只剩我们的警告"，它会打印所有被编译 target 的警告，其中预编译的 HyphenateChat framework 头文件就贡献了 1300 多行文档/umbrella/nullability 警告。**路径标记（§5.1）是报告干净的唯一原因**，不依赖日志本身干净。

两端都先 `flutter pub get`（Gradle 需要 `.flutter-plugins-dependencies`，CocoaPods 需要 `Flutter/Generated.xcconfig`）；iOS 侧缺 `Pods.xcodeproj` 时先 `pod install`，并在编译前校验 `Pods.xcodeproj` 里存在 `im_flutter_sdk_ios` target（否则给出"iOS 侧可能已改为 SPM 集成"的提示后失败）。

构建失败即中止（退出码 1）：构建没跑通时"0 条"没有意义，不能与"确实没有废弃调用"混为一谈。

### 4.2 CI 复用方案（本轮不落地，留作 gate 阶段）

**CI 事实（2026-09-21 核对）**：`ci.yml` 的 `android-build` 与 `ios-build` 每次都是全量重建——

- runner 全新，仓库无编译产物（`**/build/` 已 gitignore）；
- 缓存只有依赖：`setup-java cache: gradle` → `~/.gradle/caches` + `~/.gradle/wrapper`；`flutter-action cache: true` → Flutter SDK；iOS job 另缓存 `example/vendor/bundle`、`example/ios/Pods`、`~/.cocoapods`（pod 源码，非编译产物）；
- Flutter 把 Xcode 产物写进工程内 `example/build/ios`，未被缓存；
- Gradle build cache 未启用（两个 `gradle.properties` 都没有 `org.gradle.caching`，仓库与工作流也没有 `--build-cache`）。

因此 CI 日志里**确实**包含全部警告，复用成立。但 Flutter 的取值方式有代价，二选一：

| 方案 | 做法 | 代价 |
| --- | --- | --- |
| A. verbose 直采 | 现有命令改 `flutter build apk --debug --verbose` / `flutter build ios --simulator --debug --no-codesign --verbose`，`tee` 原始日志 | Android verbose 把 Gradle 提到 `--info`，日志几十 MB；iOS verbose 才会打印被 tool 捕获的 xcodebuild 输出，且每行带 `[        ] ` / `[+123 ms] ` 前缀（解析器已剥离） |
| B. 模块级补采（推荐） | 在两个 job 末尾各加一个 1~3 分钟的"只编 wrapper"步骤，命令同 §4.1，复用同一份依赖缓存 | 多一次模块编译，但日志干净、体积小、不依赖 verbose 语义 |

接入形态（gate 阶段）：parse 步骤 `if: always()`（复用构建日志或补采日志）+ 上传 `*-deprecated-api.json`、`native-deprecated-api.md` 作为 artifact，**不新增 trigger**（现有 job 本来就跑 PR / push）。

**复用方案的最大风险**：全量重建是 fresh runner"白捡"的，不是显式 `clean`。一旦有人给 CI 加构建产物缓存、打开 `org.gradle.caching`、或换成 self-hosted runner，扫描会静默返回 0 条——比报错更危险。故 §4.3 的健全性检查是复用方案的前置条件，不是可选项。

### 4.3 全新编译前提与健全性检查

| 检查 | 时机 | 未通过时 |
| --- | --- | --- |
| 构建命令退出码为 0 | 采集时（脚本） | 脚本退出 1，打印日志尾部 |
| 日志未显示复用编译（`UP-TO-DATE` / `FROM-CACHE` / `NO-SOURCE`） | 解析时（解析器） | CLI 退出 1，明确提示需要 clean 后重跑 |
| 日志非空、文件存在 | 解析时（CLI） | CLI 退出 2 |

xcodebuild 在"没编译任何文件"时也会打印 `** BUILD SUCCEEDED **`，没有等价标记，所以 iOS 侧靠"脚本始终 `clean build` + 要求退出码 0"这一组合；如果将来改用 verbose 直采，可再加一条 `CompileC` 计数检查（本轮未实现）。

## 5. 解析契约

### 5.1 扫描范围

只扫 wrapper 源码，判定方式是"日志里的文件路径必须包含平台标记"：

| 平台 | 路径标记 |
| --- | --- |
| android | `im_flutter_sdk_android/android/src/main/java/` |
| ios | `im_flutter_sdk_ios/ios/` |

这一条同时完成三件事：排除 Pods / pub cache / example 的第三方警告、排除 example 自己的代码、把绝对路径归一成仓库相对路径（本机与 CI 报告一致，去重也稳定）。iOS 侧通过 CocoaPods 的 `.symlinks/plugins/im_flutter_sdk_ios/ios/...` 引用源码，同样包含标记。

### 5.2 匹配规则

| 平台 | 行格式 | 正则 |
| --- | --- | --- |
| Android | `<path>.java:<line>: warning: [deprecation] <api> in <class> has been deprecated` | `^(?<file>.+?\.java):(?<line>\d+): warning: \[deprecation\] (?<api>.+?) in (?<declaringClass>.+?) has been deprecated$` |
| iOS | `<path>.<m\|h>:<line>:<col>: warning: '<api>' is deprecated[: <reason>] [-Wdeprecated-declarations]` | `^(?<file>.+?\.[mh]):(?<line>\d+):(?<column>\d+): warning: '(?<api>[^']+)' is deprecated(?:: (?<reason>.*?))? \[-Wdeprecated-declarations\]$` |

附加规则：

- 匹配前剥离 Flutter verbose 的 trace 前缀（`^\[[^\]]*\]\s?`）与行尾 `\r`；
- Java 的废弃**字段**同样命中（`[deprecation] from in EMFetchMessageOption has been deprecated`，无括号）；
- iOS 的 `reason` 可缺省（`'foo' is deprecated [-Wdeprecated-declarations]`）；
- 去重键 `file:line:api`（同一头文件被多个编译单元包含时会重复输出）；排序 `file` → `line` → `api`。

### 5.3 必须不匹配的噪音（实测样本）

| 平台 | 样本 | 来源 |
| --- | --- | --- |
| Android | `warning: unknown enum constant AnnotationRetention.BINARY` | javac 遇到缺 Kotlin metadata 的注解 |
| Android | `Note: Some input files use or override a deprecated API.` / `Note: Recompile with -Xlint:deprecation for details.` | javac 摘要，无文件行号 |
| iOS | `warning: Building targets in manual order is deprecated - check ...` | xcodebuild 自身 |
| iOS | `... warning: incompatible pointer types sending 'NSString *' to parameter of type 'NSData * _Nonnull' [-Wincompatible-pointer-types]` | 真实存在但与废弃无关（`PushManagerWrapper.m:193`） |
| iOS | `-Wdocumentation`（516 行）、`-Wnullability-completeness`（106 行）、`-Wincomplete-umbrella`（96 行） | 预编译 HyphenateChat framework 头文件与插件 umbrella 头，占日志绝大多数 |
| iOS | 缩进的 `note:` 续行、`    \| `- warning: ...` 重复树、`'from' has been explicitly marked deprecated here` 声明点说明 | xcodebuild / clang 的说明树；同一警告在日志里出现两次，靠去重收敛 |
| 两端 | Pods / pub cache / example 路径下的任何警告 | 第三方与宿主 App |

结论：解析必须锚定 `[deprecation]` 与 `[-Wdeprecated-declarations]`，不能 grep `deprecated`。

## 6. 输出契约

### 6.1 目录与文件

`reports/<版本>/deprecated/`（根仓库 `/reports/` 已 gitignore）：版本取**当前分支名**（见 AGENTS.md「Git 分支管理」，`5.0.0` 分支 → `reports/5.0.0/deprecated/`），与 auto 报告 `reports/5.0.0/` 同处一层；HEAD 不在分支上时脚本报错退出，不猜测目录（§6.4）。

| 文件 | 内容 |
| --- | --- |
| `android-raw.log` / `ios-raw.log` | 完整构建日志，留档复核 |
| `android-deprecated-api.json` / `ios-deprecated-api.json` | 机器可读结果，供后续 gate 比对 |
| `native-deprecated-api.md` | 人读报告：汇总表 + 按平台的调用点清单 |

### 6.2 JSON

```json
{
  "platform": "android",
  "generatedAt": "2026-09-21 15:30:13",
  "rawLog": "/<repo>/reports/5.0.0/deprecated/android-raw.log",
  "skippedCompile": false,
  "findings": [
    {
      "file": "im_flutter_sdk_android/android/src/main/java/com/easemob/im_flutter_sdk/ChatManagerWrapper.java",
      "line": 502,
      "api": "downloadAttachment(EMMessage)",
      "declaringClass": "EMChatManager"
    }
  ]
}
```

iOS 的条目用 `reason` 取代 `declaringClass`（`"reason": "Use muteMembers instead"`）；字段为空时省略。`rawLog` 原样记录命令行传入的日志路径，由脚本驱动时即绝对路径。

### 6.3 Markdown 报告

中文报告：标题 + 生成时间 + 扫描范围说明 + 汇总表（各平台条数与合计）+ 分平台清单（每条给出 `路径:行号`、`API`、`声明于` / `替代`）。未扫描的平台显式标注"未扫描平台"，零发现时写"未发现废弃 API 调用。"

### 6.4 退出码

| 退出码 | 含义 |
| --- | --- |
| 0 | 解析完成（有发现也算成功：只报告不拦截） |
| 1 | 日志显示复用编译，结果不可信 |
| 2 | 参数错误、缺少 `dart` / `flutter` / `git`、HEAD 不在分支上、日志缺失或为空 |

## 7. 实现规格（文件清单）

| 文件 | 类型 | 职责 |
| --- | --- | --- |
| `im_flutter_sdk/tool/ci/deprecated_api_checker.dart` | 新增 | 纯函数：日志 → findings；含平台标记、两种正则、前缀剥离、去重排序、Markdown 渲染 |
| `im_flutter_sdk/tool/ci/check_deprecated_api.dart` | 新增 | 薄 CLI：`--out-dir` + `--android-raw-log` / `--ios-raw-log`，写 JSON 与 Markdown，打印摘要 |
| `im_flutter_sdk/test/ci/deprecated_api_checker_test.dart` | 新增 | 单测：真实日志片段（含 §5.3 全部噪音样本） |
| `tool/ci/scan_deprecated.sh` | 新增 | 编排：clean 编译两端 → 调解析器；构建失败即中止 |
| `tool/ci/enable_deprecation_lint.gradle` | 新增 | Gradle init script：`-Xlint:deprecation` 注入，不改插件 `build.gradle` |
| `Makefile` | 修改 | 新增 `scan-deprecated` 目标 |
| `CONTRIBUTING.md` | 修改 | "运行与验证"新增"废弃 API 扫描"小节 |

依赖：只用 Dart 标准库（`dart:convert`、`dart:io`），**不引入 jq**；解析器可被 `flutter test` 直接测。

## 8. 现状基线（2026-09-21 实测 9 处）

扫描报告只陈述事实，修复属另一个任务。

| 平台 | 位置 | 废弃 API | 编译器给的信息 |
| --- | --- | --- | --- |
| Android | `ChatManagerWrapper.java:502` | `downloadAttachment(EMMessage)` | in `EMChatManager` |
| Android | `ChatManagerWrapper.java:588` | `downloadAttachment(EMMessage)` | in `EMChatManager` |
| Android | `ChatManagerWrapper.java:545` | `downloadThumbnail(EMMessage)` | in `EMChatManager` |
| Android | `ChatManagerWrapper.java:632` | `downloadThumbnail(EMMessage)` | in `EMChatManager` |
| Android | `EMHelper.java:878` | `setThumbnailSecret(String)` | in `EMImageMessageBody` |
| Android | `EMHelper.java:915` | `getThumbnailSecret()` | in `EMImageMessageBody` |
| Android | `EMHelper.java:1567` | `setFrom(String)` | in `EMFetchMessageOption` |
| iOS | `ChatroomHelper.m:23` | `muteList` | Use muteMembers instead |
| iOS | `FetchServerMessagesOptionHelper.m:18` | `from` | Use fromIds instead |

iOS 的 `muteList`、`from` 与 RN 侧首扫命中的是同一批 native 变更，说明两端平版对 native 废弃的敏感度一致。

### 8.1 修复进展（2026-09-21 更新）

§8 表格是扫描器交付时的快照，下面是随后的清理进度（每次以重跑 `bash tool/ci/scan_deprecated.sh <platform>` 为准）：

| 项 | 状态 | 落点 |
| --- | --- | --- |
| Android `downloadAttachment` / `downloadThumbnail`（4 条） | 已修 | commit `5d49428e`，改用带 `EMCallBack` 的重载 |
| iOS `ChatroomHelper.m` `muteList` | 已修 | 改用 `muteMembers.allKeys`（native 5.0.0 的替代属性是 `NSDictionary<userId, 过期时间>`，只取 key，与 Android `getMuteList().keySet()` 同形；`muteList` 与 `muteMembers` 都是「仅聊天室所有者可取，否则 nil」），重跑后 iOS 由 2 条降为 1 条 |
| Android `EMHelper.java` `setThumbnailSecret` / `getThumbnailSecret` | 已修（图片 body 透传已删除） | 与 RN SDK 对齐：图片的 `thumbnailSecret` 字段（含 Dart 字段）与 native 透传一并移除，视频保留，见 §9.3 |
| Android `EMHelper.java:1567` `setFrom`、iOS `FetchServerMessagesOptionHelper.m:18` `from` | 已修（删除不可达分支） | Dart 侧已删除 `FetchMessageOptions.from`（见 `deprecated-apis.md`），native 替代分别是 `setFromIds` / `fromIds`，见 §9.3 |

## 9. 验收标准

- [x] `make scan-deprecated` 一条命令跑通两端，产出 §6.1 的 5 个文件
- [x] 解析器识别 javac 与 clang 两种格式；Java 字段废弃与 iOS 无 `reason` 的情况都命中
- [x] 路径归一为仓库相对路径；Pods / pub cache / example 的警告被排除
- [x] §5.3 的噪音样本全部不误报；重复行按 `file:line:api` 去重；结果按 `file`→`line`→`api` 排序
- [x] 复用编译（`UP-TO-DATE` / `FROM-CACHE`）被判定为扫描失败（退出码 1）
- [x] 单测覆盖上述规则；`flutter test` 全绿
- [x] `dart format`、`flutter analyze --fatal-infos` 通过
- [x] 报告内容与真实编译日志一致（Android 7 条、iOS 2 条）
- [x] 未改动 `.github/`（本轮不接 CI）

### 9.1 实施记录（2026-09-21）

改动文件：

| 层 | 文件 |
| --- | --- |
| 解析 | `im_flutter_sdk/tool/ci/deprecated_api_checker.dart`（新增）、`im_flutter_sdk/tool/ci/check_deprecated_api.dart`（新增） |
| 测试 | `im_flutter_sdk/test/ci/deprecated_api_checker_test.dart`（新增，10 个用例） |
| 编排 | `tool/ci/scan_deprecated.sh`（新增）、`tool/ci/enable_deprecation_lint.gradle`（新增） |
| 入口与文档 | `Makefile`（`scan-deprecated`）、`CONTRIBUTING.md`（"废弃 API 扫描"小节） |
| CI | 未改动 |

验证结果：

| 检查 | 命令 | 结果 |
| --- | --- | --- |
| 格式（CI 门禁） | `dart format --output=none --set-exit-if-changed <新文件>` | ✅ 0 changed |
| 静态检查 | `flutter analyze --fatal-infos`（`im_flutter_sdk`） | ✅ No issues found |
| 单元测试 | `flutter test`（`im_flutter_sdk`） | ✅ 50 个测试全部通过（新增 10 个） |
| 真实日志解析 | 用 javac（绝对路径）与 clang 探针日志跑 CLI | ✅ Android 7 条、iOS 2 条，与 §8 基线一致 |
| 端到端 | `bash tool/ci/scan_deprecated.sh all` | ✅ 退出码 0：`clean` + 模块级编译两端成功，日志 11 KB / 690 KB，报告 Android 7 条、iOS 2 条 |
| 健全性检查 | 用含 `compileDebugJavaWithJavac UP-TO-DATE` 的日志跑 CLI | ✅ 退出码 1 并提示需要 clean 后重跑 |
| 参数校验 | 日志缺失时跑 CLI | ✅ 退出码 2 |
| 既有门禁脚本 | `check_case_mapping` / `check_contracts` / `check_versions` | ✅ 三者输出一致（5.0.0） |

### 9.2 输出目录调整（2026-09-21）

初版把产物写在 `reports/deprecated/`，与 auto 报告的 `reports/5.0.0/` 并列在 `reports/` 顶层，缺了版本维度。现改为按**当前分支名**归档：`reports/<分支名>/deprecated/`（`5.0.0` 分支 → `reports/5.0.0/deprecated/`），与 auto 报告同处一层；HEAD 不在分支上时脚本报错退出（退出码 2），不猜测目录。§6.1 契约与 §6.4 退出码已同步；改动只涉及 `tool/ci/scan_deprecated.sh`、`CONTRIBUTING.md` 与本文件。2026-09-21 复跑 `bash tool/ci/scan_deprecated.sh` 验证：产物写入 `reports/5.0.0/deprecated/`，退出码 0。

### 9.3 遗留废弃调用清理（2026-09-21）

§8.1 的 4 条里，本轮只清理 `from` 的 2 条（Android 1 条 + iOS 1 条）；缩略图密钥的 2 条当时**明确保留不改**。

| # | 位置 | native 废弃声明 | 替代 | 本轮处理 |
| --- | --- | --- | --- | --- |
| 1 | `EMHelper.java` 图片 body `fromJson` | `EMImageMessageBody.setThumbnailSecret(String)` | `setSecret(String)` | 保留不改（见下） |
| 2 | `EMHelper.java` 图片 body `toJson` | `EMImageMessageBody.getThumbnailSecret()` | `getSecret()` | 保留不改（见下） |
| 3 | `EMHelper.java` `FetchHistoryOptionsHelper` | `EMFetchMessageOption.setFrom(String)` | `setFromIds(List<String>)` | 删除分支（不可达） |
| 4 | `FetchServerMessagesOptionHelper.m` | `EMFetchServerMessagesOption.from`（`__deprecated_msg("Use fromIds instead")`） | `fromIds` | 删除赋值（不可达） |

保留 1/2 的原因：native 5.0.0 里图片的原图、大图、缩略图共用一个密钥，改成 `getSecret()` 会让 Android 侧 `thumbnailSecret` 的取值发生变化（对外 JSON 的取值变化），使用方影响待确认，本轮先维持现状；iOS 侧 `thumbnailSecretKey` 本就未废弃，无需改动。

**2026-09-22 更新（1/2 已处理）**：React Native SDK 在 5.0.0 收尾中（commit `d8e0d71`）移除了图片 `thumbnailSecret` 的 native 透传，且此前已删除 TS 侧 `ChatImageMessageBody.thumbnailSecret` 字段（替代为 `secret`）。Flutter 侧按同一范围对齐：

- Dart 删除 `ChatImageMessageBody.thumbnailSecret` 字段及其 `fromJson`/`toJson` 读写；
- Android `EMHelper.java` 删除图片 body 的 `setThumbnailSecret` / `getThumbnailSecret` 透传（不再有废弃调用）；
- iOS `MessageHelper.m` 删除图片 body 的 `thumbnailSecretKey` 读写透传；
- 视频 body 的 `thumbnailSecret` 全部保留（`EMVideoMessageBody` 的对应 API 在 5.0.0 未废弃，RN 同样保留）。

判定依据（均取自 wrapper 实际编译的产物）：

- Android：`io.hyphenate:hyphenate-chat:5.0.0`（`im_flutter_sdk_android/android/build.gradle`）的 AAR 用 `javap -v` 确认 `EMImageMessageBody.setThumbnailSecret` / `getThumbnailSecret` 与 `EMFetchMessageOption.setFrom` 带 `Deprecated: true`；`EMFileMessageBody.getSecret()` 的 javadoc 写明「对于图片消息:原图、大图、缩略图共用一个密钥。对于视频消息：视频文件和缩略图共用一个密钥」——1/2 将来若要改，是等价替换。
- iOS：`Pods/HyphenateChat/.../EMFetchServerMessagesOption.h` 的 `from` 带 `__deprecated_msg("Use fromIds instead")`，替代是 `fromIds`。
- 3/4 的不可达性：Dart `FetchMessageOptions.toJson()` 只下发 `senders`（`im_flutter_sdk/lib/src/models/fetch_message_options.dart`），5.0.0 已删除 Dart 侧 `FetchMessageOptions.from`（见 `im_flutter_sdk/docs/deprecated-apis.md`），并由 `im_flutter_sdk/test/contracts/legacy_api_removal_contract_test.dart`（`sends senders only`、`containsKey('from') isFalse`）锁定。
- 未一并处理：Android video body 的 `EMVideoMessageBody.setThumbnailSecret` / `getThumbnailSecret` 与 `EMMessage.setFrom` 在 5.0.0 AAR 中均未标废弃，保持不动（2026-09-22 对齐 RN 后视频 `thumbnailSecret` 仍保留）。

改动文件：`im_flutter_sdk_ios/.../FetchServerMessagesOptionHelper.m`、`im_flutter_sdk_android/.../EMHelper.java`（仅 `from` 分支），以及两个包的 `CHANGELOG.md`（5.0.0 条目）；Dart 公开 API 与两端 JSON key 均未变化。

| 检查 | 命令 | 结果 |
| --- | --- | --- |
| 全新编译 + 扫描 | `bash tool/ci/scan_deprecated.sh` | ✅ 退出码 0，`skippedCompile: false`；Android 2 条（全部为保留项）、iOS 0 条 |
| 编译正确性 | 同上（Android `compileDebugJavaWithJavac`、iOS xcodebuild `clean build`） | ✅ 两端编译通过 |

保留项的后续验证（2026-09-22 已失效）：图片 `thumbnailSecret` 已按 RN 对齐删除字段与透传，原计划的 `getSecret()` / `getThumbnailSecret()` 取值对比探针不再需要。

## 10. 明确不做

| 项 | 原因 |
| --- | --- |
| 接入 CI（新增 workflow / job / 定时 / dispatch） | 只报告的工具不必占用 PR 时长；升级为 gate 时再按 §4.2 接 |
| 因发现废弃调用而失败（`--fail-on-findings` 之类） | 门禁语义属于 gate 阶段；现在加会凭空多出一个入口 |
| 扫描 example、Dart 侧 `@Deprecated` 清单 | 前者是宿主 App 代码会带噪音，后者与 native 废弃无关，另开任务 |
| 覆盖 javac 的 `[removal]`、`-Xlint:unchecked` 等其它分类 | 本轮只做"废弃"，其它分类按需再加（正则可扩展） |
| 覆盖 Kotlin 编译器的 `w: ... is deprecated` 格式 | Android wrapper 目前是纯 Java；引入 Kotlin 时再补 |
| 用 jq 生成 JSON | Dart 解析器可单测、无外部依赖，仓库已有 `tool/ci/check_*.dart` 约定 |
| 自动修复已发现的 9 处调用 | 属另一个任务；报告只给清单 |

## 附录 A：与 RN 实现的差异

| 项 | RN 5.0.0 | 本实现 |
| --- | --- | --- |
| 解析实现 | bash + `jq` | Dart 纯函数 + 薄 CLI（可单测、无外部依赖） |
| Android 命令 | `./gradlew clean assembleDebug`（整个 example）`+ -I` 注入 `-Xlint` | `:im_flutter_sdk_android:clean :im_flutter_sdk_android:compileDebugJavaWithJavac + -I`，只编 wrapper 模块 |
| iOS 命令 | `xcodebuild -workspace ... -scheme ChatSdkExample build OTHER_CFLAGS='$(inherited) -Wdeprecated-declarations'` | `xcodebuild -project Pods.xcodeproj -target im_flutter_sdk_ios -quiet clean build`，只编 wrapper target |
| 日志来源 | CI 构建日志 `tee` + parse-only 步骤 | 本地 clean 编译（CI 复用方案见 §4.2，未落地） |
| 复用编译检测 | 脚本注释里提醒 | 解析器判定并让 CLI 失败（§4.3） |
| 扫描范围 | `modules/java/`、`modules/objc/`、`android/`、`ios/` | 只 wrapper（§5.1） |
| 产物 | `build/reports/native-deprecated-api.md` + 两个 JSON | `reports/<版本>/deprecated/` 下两个 JSON + 汇总 Markdown + 原始日志 |
| 首扫结果 | iOS 4 条、Android 16 条 | iOS 2 条、Android 7 条 |

## 附录 B：探针记录（2026-09-21，macOS / Flutter 3.47.0）

目的：在写实现前确认"警告确实存在、格式可解析、噪音可控"。

| 探针 | 命令要点 | 结果 |
| --- | --- | --- |
| Android | `javac -Xlint:deprecation`，classpath = `hyphenate-chat-5.0.0.aar` 的 classes.jar + `android.jar`(34) + `flutter.jar` + `androidx.annotation`，编译 wrapper 的 20 个 Java 文件 | 0 error、**7 条** `[deprecation]`；不加 `-Xlint:deprecation` 时只剩 `Note: Some input files use or override a deprecated API.` |
| iOS | `clang -fsyntax-only -fobjc-arc -Wdeprecated-declarations`，`-F` Flutter.xcframework(simulator) + HyphenateChat.xcframework(simulator)，编译 wrapper 的 48 个 `.m` | 0 error、**2 条** `-Wdeprecated-declarations`，另有 1 条与废弃无关的 `-Wincompatible-pointer-types` |

沙箱限制：`xcodebuild` 驱动的完整 target 编译需要写工作区外的 `~/Library/Developer/Xcode/DerivedData` 与 clang module cache，本次探针阶段被文件策略挡下（`-derivedDataPath` 要求的 `-scheme` 与 `-target` 互斥），改在实现阶段用全权限跑端到端验证。
