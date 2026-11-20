# deleteContact 与 keepConversation 排查

- 日期：2026-11-07
- 状态：iOS 参数取反已修正并专项验证；基础 CI 删除用例仅检查 API 成功返回。旧本地联系人更新失败保留，通知链路根因未闭环。
- 基线：`testing` 分支 `10fc186c`，Flutter 3.47.0，Android/iOS Native SDK 5.0.0；Android `emulator-5554`、iOS 18.2 / iPhone 16 Pro。

## 结论

| 问题 | 结论 |
|---|---|
| iOS 保留／删除会话相反 | Flutter iOS wrapper 错误。两端原生参数语义相反，封装漏了取反；不是用例预期错误 |
| 正式 CI 两个删除用例准备失败 | 固定 peer 被消息用例复用，已有消息触发保护。数据隔离不足，未执行删除 API，不能当作参数缺陷的复现 |
| 删除成功后本地联系人仍存在 | 专项诊断中 Android 也复现过，不能归为 iOS 特有；与参数取反独立。已定位到原生状态与服务端不一致，尚未确定通知为何未更新本地状态 |

## 参数契约与调用链

[Dart API](../../../im_flutter_sdk/lib/src/managers/chat_contact_manager.dart) 定义 `keepConversation=true` 保留会话，`false` 删除会话，默认 `false`。

| 层 | 参数语义及传递 |
|---|---|
| Android 原生 `deleteContact(username, keepConversation)` | `true` 保留，`false` 删除；[Android wrapper](../../../im_flutter_sdk_android/android/src/main/java/com/easemob/im_flutter_sdk/ContactManagerWrapper.java) 原样传递正确 |
| iOS 原生 `deleteContact:isDeleteConversation:completion:` | `YES` 删除，`NO` 保留；[iOS wrapper](../../../im_flutter_sdk_ios/ios/im_flutter_sdk_ios/Sources/im_flutter_sdk_ios/ContactManagerWrapper.m) 修复前原样传入 `keepConversation` |
| iOS 原生实现 → C++ core | 原生实现将 `!aIsDeleteConversation` 作为 core 的 `keepConversation`，core 在 `!keepConversation` 时删除会话及消息 |

因此，Flutter iOS 的正确映射应为 `isDeleteConversation:!keepConversation`。原生 API 的命名差异本身成立，Flutter 封装需要适配。该传递行可通过 `git blame` 追溯到 `d870627ee`（2019-11-01），不是本次补充用例或 5.0.0 平版新引入。

原生源码依据：`emclient-ios` 的 `5.0.0`（`f8f506cc`），`ContactManager/IEMContactManager.h` 与 `EMContactManager.mm`；Android 的 `SDK_5.0.0`，`EMContactManager.java`；core 的 `SDK_5.0.0`（`2f4d2094`），`src/emcontactmanager.cpp`。

## 修复前独立数据复现

使用已有登录账号及本轮新建的临时 peer，不复用正式用例的消息接收方。每例 REST 建立并双向核验好友关系，登录并等待联系人／群同步完成，确认本地好友存在且目标会话无历史消息，再插入一条本地消息。调用删除后分别检查服务端关系、本地联系人和会话，在约 0、1、3、30 秒记录状态；期间不重新登录、不远端刷新 SDK 列表。

| 平台 | keepConversation | 预期会话 | 实际会话 | 30 秒时本地好友 | 总结果 |
|---|---|---|---|---|---|
| iOS | `true` | 保留 | 已删除 | 已移除 | 参数行为失败 |
| iOS | `false` | 删除 | 保留，消息数 1 | 已移除 | 参数行为失败 |
| Android | `true` | 保留 | 保留，消息数 1 | 已移除 | 通过 |
| Android | `false` | 删除 | 已删除 | 仍存在 | 本地联系人更新失败，参数行为通过 |

四例的删除 API 均成功返回，REST 均确认双方好友关系解除。iOS 两例及 Android `true` 例观察到 `onContactDeleted`；Android `false` 例在 30 秒内未观察到该通知。不能把 Android 本轮写成 2/2 全部通过。

core 5.0.0 的 `deleteContact` 在 REST 成功后只按参数处理会话，没有直接移除本地联系人；本地数据库及 ID 缓存在 `doHandleRosterEvent(REMOVE)`、`handleMultiDevicesContactEvent(REMOVE)` 等通知路径更新。这说明本地更新依赖通知，但本轮证据不足以区分服务端未发送、传输未交付或 native 未处理。Dart 未观察到通知也不等于网络层没有收到数据包。

两端二进制的 core 构建标识不同：Android 为 `SDK_4.24.0-87-g9d4670b2-dirty`，iOS 为 `SDK_4.24.0-159-g2f4d2094`。这是内部构建标识，不是对外版本号；Android 的准确源码未由该标识还原，不能直接把 iOS 对应源码当作 Android 二进制实现。版本号相同不足以证明平台行为差异来自操作系统。

## 证据与后续处理

- iOS 日志：`artifacts/delete-contact-probe-ios-20261107-r2.log`。
- Android 日志：`artifacts/delete-contact-probe-android-20261107.log`。
- 结构化结果、实际执行源码、二进制基线及清理核验：`reports/ci-basic-api/20261107-delete-contact-probe/` 中的 `results.json`、`executed-probe.dart`、`baseline.json`、`cleanup.json`。
- 临时 peer 已删除并通过 REST 404 核验；原账号好友集合恢复，临时 Token 配置及测试入口已删除，日志未检出原始 Token。上述原始产物不纳入 Git。

首轮临时入口放在包外 `reports/`，被 Flutter 当作宿主机测试执行，在初始化处报 `UnimplementedError`；该日志 `delete-contact-probe-ios-20261107.log` 不算 SDK 复现。诊断测试应临时放在 example 的 `integration_test/` 内执行，结束后归档源码并删除入口。

用户将 iOS wrapper 修改为 `isDeleteConversation:!keepConversation`，修复后、用例调整前的结果见下节。关于 Native SDK 5.1 修复的信息尚未实测；升级 native 版本本身不会改变 Flutter wrapper 的参数映射。

## 修复后 iOS 复验

重新编译用户修改后的代码，使用新的独立临时 peer，先执行同一专项诊断，再执行未修改的 `single_account_local_test.dart` 全部 22 例。

| 执行范围 | 结果 |
|---|---|
| 专项诊断两例 | 2/2 通过：`true` 保留会话及消息，`false` 删除会话；两例服务端关系、本地联系人更新及清理均通过 |
| 正式正向套件 | 20 通过、2 验证失败；`FL-CONTACT-002/003` 均完成准备和删除调用，服务端关系解除、会话行为符合参数，但本地联系人 ID／记录 30 秒后仍存在 |

两项正式失败均为 `failureStage=verify`、`targetExecuted=true`，区别于此前历史消息保护产生的准备失败。本轮正式套件的收尾均通过；专项成功不能替代完整套件验收，也不能证明本地更新问题已经解决。

日志：`artifacts/delete-contact-fixed-ios-20261107-probe.log`、`artifacts/ci-basic-ios-positive-20261107-delete-fixed.log`。结构化结果、源码与修复基线、群回收及账号回收证据在 `reports/ci-basic-api/20261107-delete-contact-fixed/`。本轮 2 个临时群和临时 peer 均确认删除，原好友集合恢复，Token 配置及临时测试入口已删除。正式结果已追加至[逐例 CSV](2026-11-07-positive-case-results.csv)。

## 原生日志补充与 CI 边界

iOS 原生日志中，`20:58:50.335` 发起删除、`.492` 服务端返回成功；当前登录会话内 30 秒未处理对应 REMOVE。失败收尾重新登录后，`20:59:21.368` 才获取并处理该 REMOVE，事件时间对应原删除时间。该证据说明删除完成与本地联系人更新是不同阶段，仍不足以判定通知延迟归属服务端、传输还是 SDK。日志及执行源码保存在 `reports/ci-basic-api/20261107-delete-native-source/`；临时账号、Token 文件和测试入口已清理。

用户确认 `FL-CONTACT-002/003` 只测试删除 API 成功返回，分别传入 `keepConversation: true/false`。不创建会话和消息，不追加 REST 删除结果、本地联系人、监听通知或会话断言；保留好友关系准备及原状态恢复。该范围不覆盖会话参数效果和本地同步，也不表示历史异常已修复。

不要用某轮 Android 通过推断“Android 没问题”，也不要把 API 成功与异步同步完成混为同一个断言。可复用的排查方法见[踩坑记录](../troubleshooting/2026-11-07-ci-contact-fixture-sync.md)。
