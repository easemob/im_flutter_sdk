# ohos multi 场景 API 可行性核对表（T0）

日期：2026-11-21
关联：docs/spec/2026-11-21-ohos-testing-alignment-spec.md、docs/plan/2026-11-21-ohos-testing-alignment-plan.md
核查基线：4.x `testing/multi/cases/` 12 个场景 × ohos 分支（native @easemob/chatsdk 1.15.0）

## 结论速览

- 清单实际 **31 个 API**（原估计 29）：**30 个 runnable，1 个 skip**
- 唯一阻断：`ChatClient.fetchLoggedInDevices` 已从 ohos Dart 层物理删除（chatsdk 1.15.0 无多端设备管理，连带 `kickDevice`/`kickAllDevices` 一并移除，gap 台账 §17），导致 **2 个 device-sync 场景 skip**，其余 **10 个场景 runnable**
- `ChatManager.modifyMessage`（首要疑点）**存在且可用**：chatsdk 1.15.0 支持，仅可编辑 Text/Custom 消息体；multi-message-edit 场景编辑的正是文本消息，不受影响
- 场景 `wait_event` 依赖的 14 种事件（群成员进出、多设备 onGroupEvent、presence、userInfo、送达/撤回/编辑等）ArkTS 侧全部已接线，**无事件层阻断**

## API 核对表

路径前缀：Dart = `im_flutter_sdk/lib/src/managers/`；ets = `im_flutter_sdk_ohos/ohos/src/main/ets/components/plugin/`；台账 = `docs/porting/ohos-4.25.0/02-gap-ledger.md`

| API | Dart 层 | 鸿蒙实现 | 台账处置 | 判定 | 依据 |
|---|---|---|---|---|---|
| ChatClient.fetchLoggedInDevices | ❌ 已删除 | ❌ | 缺失→移除（§1.1 L87-89、§16-B#19、§17） | **skip** | 台账 §17；chat_client.dart 无命中；MethodKeys.ets 无此 key |
| ChatClient.getCurrentDeviceId | ✅ | ✅ | 一致（deviceName/resource 恒空） | runnable | chat_client.dart:467；ClientWrapper.ets:73/:190-203；台账 L92 |
| ChatClient.init | ✅ | ✅ | 签名差异→接受（§16.1-A#1） | runnable | chat_client.dart:491；ClientWrapper.ets:53；台账 L78 |
| ChatClient.isConnected | ✅ | ✅ | 一致 | runnable | chat_client.dart:396；ClientWrapper.ets:75/:207；台账 L94 |
| ChatClient.loginWithToken | ✅ | ✅ | 一致（key `login`） | runnable | chat_client.dart:650；ClientWrapper.ets:57；台账 L80 |
| ChatClient.logout | ✅ | ✅ | 一致 | runnable | chat_client.dart:740；ClientWrapper.ets:61/:154；台账 L83 |
| ChatContactManager.acceptInvitation | ✅ | ✅ | 一致 | runnable | chat_contact_manager.dart:559；ContactManagerWrapper.ets:72；台账 L150 |
| ChatContactManager.addContact | ✅ | ✅ | 一致 | runnable | chat_contact_manager.dart:157；ContactManagerWrapper.ets:56；台账 L142 |
| ChatContactManager.deleteContact | ✅ | ✅ | 一致 | runnable | chat_contact_manager.dart:198；ContactManagerWrapper.ets:58；台账 L143 |
| ChatContactManager.getAllContactIds | ✅ | ✅ | 一致（key `getAllContactsFromDB`） | runnable | chat_contact_manager.dart:330；ContactManagerWrapper.ets:62；台账 L145 |
| ChatGroupManager.acceptInvitation | ✅ | ✅ | 一致（inviter 参数鸿蒙忽略） | runnable | chat_group_manager.dart:1899；GroupManagerWrapper.ets:156/:721-730；台账 L423 |
| ChatGroupManager.addMembers | ✅ | ✅ | 一致 | runnable | chat_group_manager.dart:821；GroupManagerWrapper.ets:98/:409；台账 L394 |
| ChatGroupManager.createGroup | ✅ | ✅ | 一致 | runnable | chat_group_manager.dart:454；GroupManagerWrapper.ets:80/:248；台账 L385 |
| ChatGroupManager.destroyGroup | ✅ | ✅ | 一致 | runnable | chat_group_manager.dart:1150；GroupManagerWrapper.ets:114/:490；台账 L402 |
| ChatGroupManager.fetchGroupInfoFromServer | ✅ | ✅ | 一致 | runnable | chat_group_manager.dart:498；GroupManagerWrapper.ets:82/:265；台账 L386 |
| ChatGroupManager.fetchMemberListFromServer | ✅ | ✅ | 一致（owner 首页补齐适配） | runnable | chat_group_manager.dart:538；GroupManagerWrapper.ets:84/:277；台账 L387 |
| ChatGroupManager.joinPublicGroup | ✅ | ✅ | 一致（无本地 603 预检，服务端裁决） | runnable | chat_group_manager.dart:1749；GroupManagerWrapper.ets:148/:679-688；台账 L419 |
| ChatGroupManager.leaveGroup | ✅ | ✅ | 一致 | runnable | chat_group_manager.dart:1118；GroupManagerWrapper.ets:112/:481；台账 L401 |
| ChatGroupManager.updateGroupName | ✅ | ✅ | 一致（key `updateGroupSubject`） | runnable | chat_group_manager.dart:1033；GroupManagerWrapper.ets:108/:461；台账 L399 |
| ChatGroupManager.updateGroupNamecard | ✅ | ✅ | 一致 | runnable | chat_group_manager.dart:2291；GroupManagerWrapper.ets:176/:844；台账 L434 |
| ChatManager.modifyMessage | ✅ | ✅ | 一致（仅 Text/Custom 消息体） | runnable | chat_manager.dart:2022；ChatManagerWrapper.ets:194/:970-1006；台账 L218 |
| ChatManager.recallMessage | ✅ | ✅ | 一致（传 id，wrapper 先 getMessage） | runnable | chat_manager.dart:551；ChatManagerWrapper.ets:132/:556-569；台账 L183 |
| ChatManager.sendMessage | ✅ | ✅ | 签名差异→接受（§16.1-A#5 两步语义） | runnable | chat_manager.dart:353；ChatManagerWrapper.ets:122/:241-286；台账 L178 |
| ChatPresenceManager.fetchPresenceStatus | ✅ | ✅ | 一致 | runnable | chat_presence_manager.dart:278；PresenceManagerWrapper.ets:47/:94；台账 L531 |
| ChatPresenceManager.publishPresence | ✅ | ✅ | 一致（key `publishPresenceWithDescription`） | runnable | chat_presence_manager.dart:126；PresenceManagerWrapper.ets:39；台账 L527 |
| ChatPresenceManager.subscribe | ✅ | ✅ | 一致（key `presenceSubscribe`） | runnable | chat_presence_manager.dart:163；PresenceManagerWrapper.ets:41；台账 L528 |
| ChatPresenceManager.unsubscribe | ✅ | ✅ | 一致（key `presenceUnsubscribe`） | runnable | chat_presence_manager.dart:198；PresenceManagerWrapper.ets:43；台账 L529 |
| ChatUserInfoManager.fetchOwnInfo | ✅ | ✅ | 签名差异→接受（expireTime 鸿蒙忽略） | runnable | chat_user_info_manager.dart:226；UserInfoManagerWrapper.ets:61；台账 L507 |
| ChatUserInfoManager.subscribeUsersInfo | ✅ | ✅ | 一致 | runnable | chat_user_info_manager.dart:342；UserInfoManagerWrapper.ets:65/:155；台账 L509 |
| ChatUserInfoManager.unsubscribeUsersInfo | ✅ | ✅ | 一致 | runnable | chat_user_info_manager.dart:368；UserInfoManagerWrapper.ets:67/:165；台账 L510 |
| ChatUserInfoManager.updateUserInfo | ✅ | ✅ | 一致（key `updateOwnUserInfo`） | runnable | chat_user_info_manager.dart:173；UserInfoManagerWrapper.ets:57；台账 L505 |

## 场景判定表

| 场景 | 用到 API 数 | 阻断 API | 判定 |
|---|---|---|---|
| 5.0.0-multi-contact-add-positive | 8 | — | runnable |
| 5.0.0-multi-group-create-device-sync-positive | 10 | ChatClient.fetchLoggedInDevices | **skip（平台永久）** |
| 5.0.0-multi-group-member-join-positive | 7 | — | runnable |
| 5.0.0-multi-group-member-leave-positive | 8 | — | runnable |
| 5.0.0-multi-group-namecard-positive | 8 | — | runnable |
| 5.0.0-multi-message-delivery-positive | 5 | — | runnable |
| 5.0.0-multi-message-device-sync-positive | 7 | ChatClient.fetchLoggedInDevices | **skip（平台永久）** |
| 5.0.0-multi-message-edit-positive | 6 | — | runnable |
| 5.0.0-multi-message-recall-positive | 6 | — | runnable |
| 5.0.0-multi-presence-positive | 8 | — | runnable |
| 5.0.0-multi-user-info-subscribe-positive | 8 | — | runnable |
| 5.1.0-multi-group-invite-confirm-positive | 9 | — | runnable |

两个 device-sync 场景鸿蒙无任何替代 API（fetchLoggedInDevices/kickDevice/kickAllDevices 全部移除），标记平台永久 skip，迁移时保留文件 + skip 标注 + 台账依据。

## 实现注意（T4 适配要点）

1. **sendMessage 两步语义**（台账 §16.1-A#5）：channel 立即返回消息对象，成败经 `onMessageSuccess`/`onMessageError` 异步送达；执行器不得以 Future 完成当作发送成功（android 同为两步，4.x 执行器若已正确处理则无碍，移植时核对）
2. **fetchOwnInfo 的 expireTime 被忽略**：user-info 场景断言不得依赖 expireTime 语义
3. **acceptInvitation 的 inviter 被忽略**：invite-confirm 场景断言不得依赖 inviter 校验
4. **joinPublicGroup 无本地 603 预检**：若场景断言错误码 603 会失败（正向场景无影响，迁移时核对 json 断言）
5. **fetchMemberListFromServer owner 仅首页补齐**：分页断言注意
6. **getCurrentDeviceId 的 deviceName/resource 恒空字符串**：device-sync 类断言需放宽（两个 skip 场景已不涉及）

核查方式：三层源码核查（Dart 公开 API → ArkTS Wrapper 实现 → gap 台账），辅以 ohos 自有集成用例的实证（modules/*.dart 中对应 API 的 skip/通过记录）。无设备实跑，结论以源码与台账为准。
