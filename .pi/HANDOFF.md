# HANDOFF — 环信 Flutter SDK 5.0 适配与测试

> 给下一个 coding agent 的工程交接文档。本文件 + 代码仓库应足以无缝继续。

---

## 1. 当前项目目标

环信 Flutter SDK（`im_flutter_sdk`）多版本适配与测试体系，**以 Android 5.0 为基线**（之后 5.1+ 只做增量差异）：

- **iOS 5.0 完整适配**：4.x wrapper 升级 5.0、协议名与 Android 对齐、ios.yaml 能力矩阵
- **5.0 测试 case 全量适配**（以 5.0 为准，放弃 4.23）+ 多端拓扑改造（sender_devices/recipient_devices 遍历）
- **iOS/Android 原生差异确认**：wrapper 全透传 → 跑 case 暴露原生真实行为 → 给研发建 Jira
- **group/chatroom/contact 全量验证**（iOS/Android 双端）+ 记录差异到 `ios-android-5-consistency.md`
- 验证发布 SDK（wrapper/原生）在 5.0 下的真实行为，为研发提供原生差异清单

## 2. 当前架构和关键模块

```
测试链路（【不经过 im_flutter_sdk Dart 层】）:
  Python 测试（native-auto-test）→ WS → im_flutter_test（测试 App）
  → interface（interface_router.dart）→ wrapper（原生 im_flutter_sdk_android/ios）
  → 原生 SDK（hyphenatechat 5.0 jar / HyphenateChat.xcframework）

三目录职责:
  im_flutter_sdk/（含 _android/_ios/_interface）: 发布 SDK（测试不改，仅版本升级）
  im_flutter_test/                          : 被测设备 App（桥接/事件转发/媒体素材）—— path 依赖 im_flutter_sdk
  native-auto-test/                         : Python 用例端（pytest + WS 驱动）

关键模块:
  - wrapper（原生）: ClientWrapper/GroupManagerWrapper/ChatManagerWrapper/ChatRoomManagerWrapper 等
    · Android 分发: Wrapper.java register（cmd → handler 表）+ onMethodCall 查表
    · iOS 分发: if-else 链（无 register 表）
  - 能力矩阵: native-auto-test/config/api_matrix/android.yaml / ios.yaml（协议名列表）
  - manifest: config/artifact_manifests/android-5.0.0.json（capabilities 从矩阵生成）
  - 映射文档: config/api_matrix/protocol-android-ios-5.0-pure-native-map.md（协议|Android|iOS 原生）
  - 一致性记录: native-auto-test/docs/spec/ios-android-5-consistency.md（原生差异）
  - 修复记录: native-auto-test/docs/spec/FIX_5.0_2026-08-13.md（按模块）
  - conftest.py: session 登录（token）、REST 建用户、capability 检查、_TEST_SUPPORT_CMDS 豁免
```

## 3. 已经完成的工作

**① wrapper 修复（Android + iOS）**：
- Android `acceptInvitationAlways` 误用 `setAutoAcceptGroupInvitation`（群邀请）→ 改 `setAcceptInvitationAlways`（好友邀请，对齐 iOS `autoAcceptFriendInvitation`）
- iOS `GroupHelper fromJson` 补 `allowInvites`（style>0）+ `joinApprovalRequired`（style==2）（group 大量失败根因）
- 群 toJson 补 `isPublic` + `joinApprovalRequired`（原生值，两端）
- `ChatRoomManagerWrapper` 编译修复（匿名类 `onSuccess` → `ChatRoomManagerWrapper.this.onSuccess`）
- `destroyGroup`/`removeMembers` → `@YES`（对齐 Android true）
- declined 事件补转发 `groupName`（Android 原生有，漏写）
- **OnceResult（全局防重复提交）**：Wrapper.java 分发层包装 MethodChannel.Result（只提交一次）—— 防 "Reply already submitted" App 崩溃（removeGroupSharedFile 等原生回调重复导致）
- EMWrapperCallBack/EMValueWrapperCallBack 内部 submitOnce（双保险）

**② 登录统一 token（5.0 关键）**：
- 5.0 `loginWithToken` 只接受 token，**直接传密码被拒 202**（连锁根因）
- `_switch_user`（group 3 文件 + chat）×4、conftest `_do_login`/`_login_one` else、friend_info_sync ×4、test_client 重新登录 → 全部 `fetch_user_token` + `loginWithToken(token)`

**③ 残留协议清理**（5.0 移除）：
- 矩阵删残留（android.yaml 289→284 / ios.yaml 263→258）
- case 残留 → 5.0 本地协议（getAllContactsFromDB/loadAllConversations/getJoinedGroups）/ REST（createChatRoom/destroyChatRoom/createAccount）/ skip（分页/公开群/reportMessage 等）
- manifest 同步（android-5.0.0.json capabilities 289→284，`generate_manifests.py` 自动生成）
- capability 豁免：conftest `_TEST_SUPPORT_CMDS = {"startCallback"}`（测试支撑 cmd 不参与检查，否则全 skip）

**④ 5.0 语义对齐（case 层面）**：
- 群事件单数→复数（5.0 只发 onGroupMembersJoined/Exited）—— 全 group 批量修
- `isMemberOnly` → `isPublic`（5.0 移除 isMemberOnly）
- `is_member_allow_to_invite` = style!=0（5.0 allowInvites 语义）
- mute 事件字段 `mutes`（两端 wrapper 一致）
- createGroup 边界：群名 256/512 字符 5.0 原生接受（期望成功，不再报 300）—— Android/iOS 都验证过
- joinPublicGroup：public-approval（style=2）5.0 允许加入（只测 private 0/1 拒绝 603）
- `getCurrentDeviceId` 改调原生 `getDeviceInfo()`（不再手动造 DeviceUuidFactory）
- uploadGroupSharedFile：桥接填默认素材 filePath（401 Invalid file）+ case 断言 dict

**⑤ SDK 替换（官网 5.0.0 新构建）**：
- Android jar ← `~/Documents/easemob5.0/easemob-sdk-5/libs/hyphenatechat_5.0.0.jar`（多 `EMClient.getDeviceInfo()`）
- iOS xcframework ← `~/Documents/easemob5.0/iOS_IM_SDK_V5.0.0/`（API 同，二进制更新）
- 适配：`onReadReceiptForGroupMessageUpdated` 新 jar 移除（删 @Override）
- 编译通过（Android + iOS）

**⑥ 验证结果（当前）**：
- shared_files 7 passed / client 相关 case passed / exceptions_lifecycle 34 passed / owner_removal 15 passed / style 25 passed / join_application 13 passed / chat 150 passed（1 偶发）

## 4. 当前正在做的事情

**chatroom 剩余失败分析**（3 failed / 9 passed）：
- `onRoomMemberJoined`/`onRoomMemberExited` 成员事件收不到（join/leave 后原生不触发成员事件 —— 只有房主建房时触发一次）
- `join_with_ext`：观察端收不到加入者带 ext 的加入事件（原生 join 后不触发）
- 结论：**原生行为**（不是 wrapper，wrapper 转发正常；不是缺设备，观察端有设备）—— 之前已记录"join 事件收不到（重新 join 无事件）"
- 待定：case 按原生改（不期待 join/leave 后成员事件）/ 记录给研发

**已确认待记录/给研发的原生问题**：
- 移除类空 members（removeChatRoomMembers/unMute/unBlock/removeWhiteList）原生无本地校验 → 发服务端 → 服务端不可达时慢响应（>60s）/300 —— 已记录 consistency.md

## 5. 已确定的重要设计决策及原因

| 决策 | 原因 |
|---|---|
| wrapper 全透传原生（不造 null/true/错误） | 测试要暴露原生真实行为（给研发差异清单）；造数据掩盖问题 |
| 协议名保留旧名 + wrapper 映射 5.0 原生 | 协议名 = SDK 协议（ChatMethodKeys 值）；原生改名由 wrapper 适配 |
| 登录统一 token（密码需先 REST 换 token） | 5.0 loginWithToken 只接受 token，传密码 202 |
| 残留协议 case 直接 skip | 5.0 原生没有 → 测"不存在的 API"无意义 |
| 分文件跑测试（避免全量连锁） | 全量 15 分钟跑 → Runner 崩溃/登录/服务端连锁（单文件正常） |
| OnceResult 全局防重复提交 | Flutter result 只提交一次，重复 → App 崩溃 → Runner 掉 → 连锁 |
| startCallback 矩阵不放 + capability 豁免 | 测试支撑 cmd（事件转发开关），非 SDK API |
| style 保留在协议层 + wrapper 转三布尔 | 协议层 4.x 兼容；原生 5.0 用 isPublic/joinApprovalRequired/allowInvites |
| manifest 从矩阵自动生成（generate_manifests.py） | 改矩阵 → 跑脚本 → manifest 同步（避免手改不一致） |
| 测试链路不经 im_flutter_sdk Dart 层 | 用户明确（测试直接调 wrapper cmd） |

## 6. 已发现的问题和未解决问题

**已确认原生差异（记录 consistency.md）**：
- deleteRemoteConversation("")：iOS 本地 107 vs Android 303
- joinChatRoom 不存在：两端 303
- count=0：iOS 归一 1 条
- 移除类空 members：原生无本地校验 → 发服务端 → 服务端不可达时 >60s/300（给研发）
- join/leave 后成员事件不触发（onRoomMemberJoined/Exited 收不到）
- getCurrentDeviceId 两端原生不同（Android getDeviceInfo{hid,os,os-version} / iOS getDeviceConfig{resource,deviceUUID,deviceName}）

**未解决/待办**：
- chatroom 成员事件 case（3 个）：按原生改 or 记录给研发
- chat thread 305（thread not open）：测试环境未开通 thread 功能（服务端配置）
- iOS 无防重复提交（result 直接调）—— 建议加（对齐 Android OnceResult）—— 用户未定
- protocol map Event 表漏 iOS-only 好友同步 3 事件（onFriendStartSync/onFriendSyncFailed/onFriendSyncFinished）
- 全量跑连锁（Runner 崩溃/登录/服务端）—— 分文件跑规避，根因：服务端不可达/长跑
- 空 members 移除类 4 个 case：原生修（补校验）后 case 期望应改 110

## 7. 修改过的重要文件及作用

**wrapper（原生）**：
- `im_flutter_sdk_android/android/src/main/java/.../Wrapper.java`：OnceResult（全局防重复提交）
- `im_flutter_sdk_android/android/src/main/java/.../ImFlutterSdkPlugin.java`：EMWrapperCallBack/EMValueWrapperCallBack submitOnce（防重复）
- `im_flutter_sdk_android/android/src/main/java/.../MethodKey.java`：cmd 常量
- `im_flutter_sdk_android/android/src/base500/java/.../ClientWrapper.java`：acceptInvitationAlways 修复、getCurrentDeviceId 改调原生 getDeviceInfo、登录
- `.../ChatManagerWrapper.java`：删 onReadReceiptForGroupMessageUpdated @Override（新 jar 移除）
- `.../GroupManagerWrapper.java`：destroyGroup/removeMembers @YES、declined 事件补 groupName
- `.../ChatRoomManagerWrapper.java`：编译修复、whiteList 透传 room
- `.../EMHelper.java` / iOS `GroupHelper.m`：群 toJson 补 isPublic/joinApprovalRequired、fromJson 补 allowInvites/joinApprovalRequired
- `.../GroupManagerWrapper.m`（iOS）：操作 @YES、GroupHelper 删 isMemberOnly 输出

**矩阵/配置**：
- `native-auto-test/config/api_matrix/android.yaml` / `ios.yaml`：删残留（284/258）
- `native-auto-test/config/artifact_manifests/android-5.0.0.json`：capabilities 同步（284）
- `native-auto-test/scripts/generate_manifests.py`：manifest 生成（改矩阵后跑）
- `native-auto-test/config/api_matrix/protocol-android-ios-5.0-pure-native-map.md`：getDeviceInfo 标注（Android 列）

**测试**：
- `native-auto-test/tests/conftest.py`：`_TEST_SUPPORT_CMDS`（capability 豁免）、登录 token、删 createAccount fallback
- `native-auto-test/tests/group/*.py`（10+ 文件）：单数事件、isPublic、style 语义、_switch_user token
- `native-auto-test/tests/chatroom/*.py`：createChatRoom/destroyChatRoom REST/skip、断言 dict
- `native-auto-test/tests/contact/*.py`：getAllContactsFromDB、token
- `native-auto-test/tests/chat/*.py`：loadAllConversations、token、skip 分页
- `im_flutter_test/lib/bridge/interface_router.dart`：uploadGroupSharedFile 填默认素材 filePath
- `im_flutter_test/lib/main.dart`：App 启动 init（未改，只读参考）

**文档**：
- `native-auto-test/docs/spec/ios-android-5-consistency.md`：原生差异记录（getCurrentDeviceId、移除类空 members 等）
- `native-auto-test/docs/spec/FIX_5.0_2026-08-13.md`：按模块修复记录

## 8. 当前代码状态

- **编译**：Android（assembleSdk500Debug）+ iOS（flutter build ios --simulator）**通过**
- **SDK**：已替换官网 5.0.0 新构建（Android jar 4c1cd0d8 / iOS 3597c821）；旧 jar 备份 `/tmp/hyphenatechat_5.0.0.jar.bak`
- **矩阵**：android.yaml 284 / ios.yaml 258（残留清完）；manifest 同步 284
- **wrapper**：防重复提交（OnceResult）+ 登录 token + 残留本地兜底保留（发布 SDK 兼容，测试不调）
- **case**：残留协议不再真实执行（skip/改 5.0 协议/REST）
- **未提交**：本轮改动量大（wrapper 多文件 + 矩阵 + case + 文档）—— 尚未 commit

## 9. 运行、测试、调试命令

```bash
# 跑测试（必须单行命令，终端换行会拆命令）:
cd /Users/andy_muyu/Documents/Project/im_flutter_sdk/native-auto-test
.venv/bin/python -m pytest --scenario android_500_multi_device_default tests/group/test_group_shared_files.py -q
# iOS 场景: --scenario ios_500_multi_device_default
# 单 case: "tests/xxx.py::test_xxx"（引号包住）或 -k 关键词（如 -k remove_shared_file_nonexistent）
# 重建（wrapper/桥接改动后）: 加 --build

# 编译:
cd /Users/andy_muyu/Documents/Project/im_flutter_sdk/im_flutter_test
flutter build apk --debug --flavor sdk500        # Android
flutter build ios --simulator                     # iOS（不带 flavor）

# manifest 同步（改矩阵后）:
python3 native-auto-test/scripts/generate_manifests.py --platform android

# 一致性校验:
python3 im_flutter_sdk/scripts/check_protocol_consistency.py

# WS 调试（看原生响应/事件流）: 加 --ws-debug
# 模拟器: Android emulator-5554/5556/5558/5560；iOS iosa/iosb/iosc/iosd
# 崩溃日志: adb -s emulator-5554 logcat -d | grep -E "FATAL|Reply already"
```

## 10. 下一步应该做什么

1. **chatroom 成员事件 3 个 case**：按原生改（不期待 join/leave 后成员事件）或记录给研发（原生不触发成员事件）
2. **iOS 加防重复提交**（wrapperCallBack 包装 result，对齐 Android OnceResult）—— 用户未定，建议加
3. **protocol map Event 表补 iOS-only 好友同步 3 事件**
4. **跑剩余模块**：presence/push/user_info（未跑过）+ chatroom 剩余文件验证
5. **全量重跑**（分文件汇总）确认最终状态
6. **给研发建 Jira**：原生差异清单（移除类空 members 校验缺失、join/leave 成员事件不触发、getCurrentDeviceId 两端不同、chat thread 305 需开通）
7. **commit**（本轮改动量大：wrapper 多文件 + 矩阵 + case + 文档 + SDK 替换）

## 11. 之前踩过的坑（避免重复犯错）

1. **终端换行拆命令**：多行/反斜杠命令会被 zsh 拆成独立命令（-k 参数丢失等）—— 必须单行
2. **pytest 参数化 ID 变化**：改 parametrize 后旧 ID 失效（如 expect_error2 → None）—— 用新 ID 或跑整个文件
3. **矩阵改动必须同步 manifest**：否则 CapabilityConfigurationError（全 case 报错）—— 改矩阵后跑 generate_manifests.py
4. **startCallback 从矩阵删会导致全 skip**：capability 检查发现 case 用 startCallback 但矩阵没有 → skip 全部—— 需要 _TEST_SUPPORT_CMDS 豁免
5. **登录密码 202**：5.0 loginWithToken 传密码被拒 202（连锁根因）—— 所有登录走 token
6. **App 崩溃（Reply already submitted）**：原生回调重复/双提交 → 崩溃 → Runner 掉 → 后续 "Runner is not registered" 连锁—— OnceResult 防
7. **全量长跑连锁**：15 分钟跑 Runner 崩/登录失效/服务端慢—— 分文件跑规避
8. **Python 字符串替换注释吞逗号**：`}  # 注释` 会把行尾逗号注释掉 → 语法错—— 注释放逗号后
9. **required_all 单数事件**：5.0 只发复数（onGroupMembersJoined）—— case 期待单数会挂
10. **wrapper 造假**：手动造数据（DeviceUuidFactory 等）是造假—— 改透传原生
11. **iOS wrapper 方法名大小写**（startCallBack capital B）—— grep 时注意
12. **SDK 替换后 API 变化**（onReadReceiptForGroupMessageUpdated 移除）—— 编译错需适配

## 12. 用户明确提出过的约束和偏好

- **测试链路不经过 im_flutter_sdk Dart 层**（用户不用 im_flutter_sdk；测试直接调 wrapper cmd）
- **wrapper 全透传原生**：不拦截/不造 null/不造 true/不造错误；wrapper 差异自己修（wrapper 是我们写的）
- **原生差异给研发**（静态确认 javap/strings/header + 运行时透传实测）
- **case 跨平台通用**（不能平台分支）；case 尽量不改，但按原生实际修正过时断言
- **错误 description 不比较**（code 一致即非差异）；"语义等价不算差异"；deprecated 不计入
- **case 返回 ≠ 服务端返回**（需抓包/后端日志才确认服务端）
- **分文件跑测试**（避免全量连锁）；Android 用 android-33 小镜像（Pixel_5_2/5_3/5_5/5_6）
- **矩阵/测试层面干净**（残留协议不测）；wrapper 残留本地兜底保留（发布 SDK 兼容，不归测试管）
- **先分析再改**（用户多次要求"别改，说下/分析下"）；改动前确认方向
- **修改后告诉用户改了什么**（明细）
- 用户偏好逐项确认（A/B 选项）后再动手
