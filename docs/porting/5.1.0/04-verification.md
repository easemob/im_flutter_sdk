# 5.1.0 验证记录

日期：2026-11-09。读取 [03-implementation.md](03-implementation.md) 后执行。结论：静态、单元/契约、Android 与 iOS 两种集成构建均通过；设备业务场景未运行，不能据此断言排序、实时同步或跨设备事件已验收。

## 环境与依赖

- Flutter 3.47.0 / Dart 3.13.0；Xcode 26.2（17C52）；CocoaPods 1.16.2。
- 开始时 `flutter config --list` 的 `enable-swift-package-manager: false`；CocoaPods 先构建，再启用 SPM、clean、pub get、构建；EXIT trap 恢复 false，最终再次查询确认 false。
- 四包 5.1.0；Android Maven 5.1.0；iOS CocoaPods 5.1.0；SPM 5.1.0 revision `2aacd520c3890e3b09d949ace6711db41f11931d`。
- SPM 与 CocoaPods 解析到 ShengwangInfra_iOS 1.3.16。未使用本地 native 包替换。
- 构建切换生成的 Xcode 工程修改和 Package.resolved 已清理；恢复的是本轮 CocoaPods 5.1.0 构建通过后的工程快照，保留应更新的 Podfile.lock。最后 `flutter pub get`、`pod install` 恢复可继续使用的 CocoaPods 环境。

## 执行证据

以下日志路径均相对 worktree 根，原始日志在 Git ignored 的 `reports/5.1.0/porting/`；此表长期保留结论。命令在对应包目录执行，不在管理工作区根执行。

| 验证项/命令 | 结果 | 证据/原因 |
|---|---|---|
| 根 `FORMAT_BASE_SHA=33cfc60af9c0683afbb12422230fb994e459ac8c bash tool/ci/run_quality.sh` | ✅ | `quality-r2.log`：5 包 analyze 无问题；SDK **74/74**；mapping、contracts、versions 通过 |
| example `flutter test` | ✅ **114/114** | `example-tests.log`，含新增 options codec 两项回归 |
| example `flutter build apk --debug` | ✅ | `android-build.log`：assembleDebug 27.7s，Built app-debug.apk；仅旧 Java 8/unchecked 编译警告 |
| example `flutter build ios --debug --no-codesign`（SPM=false） | ✅ | `ios-cocoapods-build.log`：Xcode build 36.2s，Built Runner.app |
| example `flutter config --enable-swift-package-manager` → `flutter clean` → `flutter pub get` → `flutter build ios --debug --no-codesign` | ✅ | `ios-spm-build.log`：Xcode build 23.6s，Built Runner.app；解析证据 `spm-Package.resolved`；Flutter 提示可移除 CocoaPods 属优化建议，本项目保留双集成 |
| 主包 `bash scripts/gen-apidoc.sh cn` | ✅，27 个警告、0 错误 | `apidoc-cn.log`；既有 unresolved doc references，新增三个 API 页面存在，无新增接口相关解析警告 |
| 主包 `bash scripts/gen-apidoc.sh en` | ✅，26 个警告、0 错误 | `apidoc-en.log`；同上 |
| 三端方法 key、路由、请求/返回字段逐字抽查 | ✅ | 见下表；quality 的契约检查也通过 |
| 四包版本、native 双集成、podspec 版本 | ✅ | `Versions are consistent: Flutter 5.1.0, Android Native 5.1.0, iOS Native 5.1.0.` |
| `git diff --check` | ✅ | 无输出 |
| CI 设备 smoke/nightly、单设备 JSON、多设备 YAML | ⏭️ 未执行 | 本轮完成平版构建门禁与契约测试，设备场景留后续覆盖 skill；没有触碰或重判历史失败 |

首次 quality 新增测试用了相对 lib import，触发 avoid_relative_lib_imports；改成 package import 后完整重跑通过，首轮日志 `quality.log` 保留。首次 `pod install --repo-update` 因旧 lock 固定 5.0.0 失败；`pod update HyphenateChat` 成功解析 5.1.0，再进行 CocoaPods 构建。两个问题均已解决，不计为遗留失败。

## 契约逐字抽查

| 要素 | Dart | Android | iOS | 结果 |
|---|---|---|---|---|
| 方法 key | chat_method_keys.dart: `getConversationsFromDB` | MethodKey.java 同值，onMethodCall 注册 | MethodKeys.h 同值，handleMethodCall 注册 | ✅ |
| 入参 | `pageSize` 固定下传；`cursor` 仅非 null 下传 | getInt(pageSize)，可空 cursor | integerValue(pageSize)，缺值/NSNull cursor→nil | ✅ 无裁剪、校验兜底或重排 |
| 返回 | 读取 `getConversationsFromDB`，ChatCursorResult 读 cursor/list | EMValueWrapperCallBack 包装，CursorResultHelper 支持 EMConversation | wrapperCallBack 包装，CursorResultHelper 调 Conversation.toJson | ✅ |
| 初始化配置 | autoLoadConversations=true、enableChatroomConversation=false；所有构造/copyWith/toJson | 同名 JSON key → native setters；缺 key 保留 native 默认 | 同名 JSON key → native 属性，toJson 同步 | ✅ |
| 群配置 | configs.inviteNeedConfirm 既有 bool | GroupConfigsHelper → isInviteNeedConfirm() | settings.IsInviteNeedConfirm | ✅ |
| 事件 | 34→GROUP_UPDATE、52→既有成员属性事件 | 原事件整数透传 | 原事件整数透传 | ✅ 未新增事件负载 |
| 搜索限制 | 120/120/5 既有双语文档 | 本次文档追齐 | 既有文档 | ✅ 未添加过滤 |
| 删除/品牌字段 | SDK 与双端 wrapper 搜索旧 syncDataWSHost/Port、syncDataWebSocket、useAgoraChatDomain 均无匹配 | 同左 | 同左 | ✅ |

SDK 新增 8 项测试覆盖分页默认/显式参数、空末页、非法输入 native 错误透传、会话元数据/顺序，以及 Options 默认/各构造/复制/显式 dataSyncType。它们使用模拟平台响应，只证明 Dart 契约；本轮真实 native 证据为发布依赖的编译通过。

## 阶段四门禁与限制

```sh
printf '{}' | bash /Users/asterisk/Codes/zuoyu_flutter/.agents/skills/platform-sdk-porting-v2/hooks/porting_guard.sh gate flutter "$PWD"
```
实际 stdout/stderr：空；退出码：0。

- SDK 核心列表排序、分页连续性/数据同步、聊天室消息创建会话、群邀请确认字段的服务端往返、多设备值 34 回调，仍需后续设备用例验证。
- 未运行历史 CI FL-MSG-006/007，因此没有更改其失败结论；4.22/4.24 历史脚本及用户暂停的场景均未执行。
- 未执行 publish dry-run，也未声称新版本的 hosted 四包已经发布；开发与构建使用本地 overrides。
- `.codex/hooks.json` 已安装但未替用户确认 UI 信任状态，各阶段已手动执行同一 guard，代码未提交。
