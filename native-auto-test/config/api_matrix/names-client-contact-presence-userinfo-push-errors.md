# iOS / Android 原生 SDK 5.0 名称映射与错误差异（精简版）

事实源仅为 `/Users/andy_muyu/Documents/5.0` 中 Android 5.0 JAR/so/Javadocs 与 iOS 5.0 Headers/framework 二进制。分类：`SAME`、`SIGNATURE_DIFFERENCE`、`IOS_ONLY`、`ANDROID_ONLY`。同一能力的同步/异步 overload 已合并；`SIGNATURE_DIFFERENCE` 也包括“名字相同但参数、返回值或 callback 载荷不同”。

## 1. 方法名映射

| 模块/能力 | iOS 名 | Android 名 | 分类 |
|---|---|---|---|
| Client / SDK 版本 | `version` | `VERSION` | `SIGNATURE_DIFFERENCE` |
| Client / 单例 | `sharedClient` | `getInstance` | `SIGNATURE_DIFFERENCE` |
| Client / 当前用户 | `currentUsername` | `getCurrentUser` | `SIGNATURE_DIFFERENCE` |
| Client / Options | `options` | `getOptions` | `SIGNATURE_DIFFERENCE` |
| Client / ChatManager | `chatManager` | `chatManager` | `SIGNATURE_DIFFERENCE` |
| Client / ContactManager | `contactManager` | `contactManager` | `SIGNATURE_DIFFERENCE` |
| Client / GroupManager | `groupManager` | `groupManager` | `SIGNATURE_DIFFERENCE` |
| Client / ThreadManager | `threadManager` | `chatThreadManager` | `SIGNATURE_DIFFERENCE` |
| Client / ChatroomManager | `roomManager` | `chatroomManager` | `SIGNATURE_DIFFERENCE` |
| Client / PushManager | `pushManager` | `pushManager` | `SIGNATURE_DIFFERENCE` |
| Client / UserInfoManager | `userInfoManager` | `userInfoManager` | `SIGNATURE_DIFFERENCE` |
| Client / PresenceManager | `presenceManager` | `presenceManager` | `SIGNATURE_DIFFERENCE` |
| Client / 是否已登录 | `isLoggedIn` | `isLoggedIn` | `SAME` |
| Client / 是否已连接 | `isConnected` | `isConnected` | `SAME` |
| Client / access token | `accessUserToken` | `getAccessToken` | `SIGNATURE_DIFFERENCE` |
| Client / 注册连接回调 | `addDelegate` | `addConnectionListener` | `SIGNATURE_DIFFERENCE` |
| Client / 移除连接回调 | `removeDelegate` | `removeConnectionListener` | `SIGNATURE_DIFFERENCE` |
| Client / 注册多设备回调 | `addMultiDevicesDelegate` | `addMultiDeviceListener` | `SIGNATURE_DIFFERENCE` |
| Client / 移除多设备回调 | `removeMultiDevicesDelegate` | `removeMultiDeviceListener` | `SIGNATURE_DIFFERENCE` |
| Client / 初始化 | `initializeSDKWithOptions` | `init` | `SIGNATURE_DIFFERENCE` |
| Client / 修改 AppKey | `changeAppkey` | `changeAppkey` | `SIGNATURE_DIFFERENCE` |
| Client / 修改 AppId | `changeAppId` | `changeAppId` | `SIGNATURE_DIFFERENCE` |
| Client / token 登录 | `loginWithUsername:token:completion:` | `loginWithToken` | `SIGNATURE_DIFFERENCE` |
| Client / 更新 token | `renewToken` | `renewToken` | `SIGNATURE_DIFFERENCE` |
| Client / 登出 | `logout` | `logout` | `SIGNATURE_DIFFERENCE` |
| Client / 注入 token 过期响应 | — | `notifyTokenExpired` | `ANDROID_ONLY` |
| Client / debug mode | — | `setDebugMode` | `ANDROID_ONLY` |
| Client / SDK 是否初始化 | — | `isSdkInited` | `ANDROID_ONLY` |
| Client / 数据库是否打开 | — | `isDatabaseOpened` | `ANDROID_ONLY` |
| Client / 是否自动登录 | — | `isAutoLogin` | `ANDROID_ONLY` |
| Client / RTC token | `getRTCTokenWithChannel` | `asyncGetRTCTokenInfoWithChannelName` | `SIGNATURE_DIFFERENCE` |
| Client / RTC UID→用户 ID | `getUserIdByRTCUIds` | `asyncGetUserIdsWithRTCUids` | `SIGNATURE_DIFFERENCE` |
| Client / 上传日志 | `uploadLogToServer` / `uploadDebugLogToServerWithCompletion` | `uploadLog` | `SIGNATURE_DIFFERENCE` |
| Client / 压缩日志 | `getLogFilesPath` / `getLogFilesPathWithCompletion` | `compressLogs` | `SIGNATURE_DIFFERENCE` |
| Client / 写 SDK 日志 | `log` | — | `IOS_ONLY` |
| Client / 注册日志回调 | `addLogDelegate` | `addLogListener` | `SIGNATURE_DIFFERENCE` |
| Client / 移除日志回调 | `removeLogDelegate` | `removeLogListener` | `SIGNATURE_DIFFERENCE` |
| Client / 获取已登录设备 | `getLoggedInDevicesFromServerWithUserId` | `fetchLoggedInDevicesFromServerWithToken` | `SIGNATURE_DIFFERENCE` |
| Client / 踢指定设备 | `kickDeviceWithUserId` | `kickDeviceWithToken` | `SIGNATURE_DIFFERENCE` |
| Client / 踢全部设备 | `kickAllDevicesWithUserId` | `kickAllDevicesWithToken` | `SIGNATURE_DIFFERENCE` |
| Client / 当前设备信息 | `getDeviceConfig` | — | `IOS_ONLY` |
| Contact / 注册回调 | `addDelegate` | `setContactListener` | `SIGNATURE_DIFFERENCE` |
| Contact / 移除回调 | `removeDelegate` | `removeContactListener` | `SIGNATURE_DIFFERENCE` |
| Contact / 本地好友 ID | `getContacts` | `getContactsFromLocal` | `SIGNATURE_DIFFERENCE` |
| Contact / 本地好友对象列表 | `getAllContacts` | `asyncFetchAllContactsFromLocal` | `SIGNATURE_DIFFERENCE` |
| Contact / 设置备注 | `setContactRemark` | `asyncSetContactRemark` | `SIGNATURE_DIFFERENCE` |
| Contact / 本地单个好友 | `getContact` | `fetchContactFromLocal` | `SIGNATURE_DIFFERENCE` |
| Contact / 添加好友 | `addContact` | `addContact` / `asyncAddContact` | `SIGNATURE_DIFFERENCE` |
| Contact / 删除好友 | `deleteContact` | `deleteContact` / `asyncDeleteContact` | `SIGNATURE_DIFFERENCE` |
| Contact / 同意申请 | `approveFriendRequestFromUser` | `acceptInvitation` / `asyncAcceptInvitation` | `SIGNATURE_DIFFERENCE` |
| Contact / 拒绝申请 | `declineFriendRequestFromUser` | `declineInvitation` / `asyncDeclineInvitation` | `SIGNATURE_DIFFERENCE` |
| Contact / 服务端黑名单 | `getBlackListFromServerWithCompletion` | `getBlackListFromServer` / `asyncGetBlackListFromServer` | `SIGNATURE_DIFFERENCE` |
| Contact / 本地黑名单 | `getBlackList` | `getBlackListUsernames` | `SIGNATURE_DIFFERENCE` |
| Contact / 加入黑名单 | `addUserToBlackList` | `addUserToBlackList` / `asyncAddUserToBlackList` | `SIGNATURE_DIFFERENCE` |
| Contact / 批量保存黑名单 | `saveBlackList` | `saveBlackList` / `asyncSaveBlackList` | `SIGNATURE_DIFFERENCE` |
| Contact / 移出黑名单 | `removeUserFromBlackList` | `removeUserFromBlackList` / `asyncRemoveUserFromBlackList` | `SIGNATURE_DIFFERENCE` |
| Contact / 其他平台自身 ID | `getSelfIdsOnOtherPlatformWithCompletion` | `getSelfIdsOnOtherPlatform` / `asyncGetSelfIdsOnOtherPlatform` | `SIGNATURE_DIFFERENCE` |
| Presence / 发布状态 | `publishPresenceWithDescription` | `publishPresence` | `SIGNATURE_DIFFERENCE` |
| Presence / 订阅 | `subscribe` | `subscribePresences` | `SIGNATURE_DIFFERENCE` |
| Presence / 取消订阅 | `unsubscribe` | `unsubscribePresences` | `SIGNATURE_DIFFERENCE` |
| Presence / 分页取订阅成员 | `fetchSubscribedMembersWithPageNum` | `fetchSubscribedMembers` | `SIGNATURE_DIFFERENCE` |
| Presence / 查询状态 | `fetchPresenceStatus` | `fetchPresenceStatus` | `SIGNATURE_DIFFERENCE` |
| Presence / 注册回调 | `addDelegate` | `addListener` | `SIGNATURE_DIFFERENCE` |
| Presence / 移除回调 | `removeDelegate` | `removeListener` | `SIGNATURE_DIFFERENCE` |
| Presence / 清空回调 | — | `clearListeners` | `ANDROID_ONLY` |
| UserInfo / 注册回调 | `addDelegate` | `addUserInfoManagerListener` | `SIGNATURE_DIFFERENCE` |
| UserInfo / 移除回调 | `removeDelegate` | `removeUserInfoManagerListener` | `SIGNATURE_DIFFERENCE` |
| UserInfo / 更新全部自身属性 | `updateOwnUserInfo` | `updateOwnInfo` | `SIGNATURE_DIFFERENCE` |
| UserInfo / 更新单个自身属性 | `updateOwnUserInfo:withType:completion:` | `updateOwnInfoByAttribute` | `SIGNATURE_DIFFERENCE` |
| UserInfo / 按 ID 拉全部属性 | `fetchUserInfoById` | `fetchUserInfoByUserId` | `SIGNATURE_DIFFERENCE` |
| UserInfo / 按 ID+类型拉取 | `fetchUserInfoById:type:completion:` | `fetchUserInfoByAttribute` | `SIGNATURE_DIFFERENCE` |
| UserInfo / 本地批量获取 | `getUserInfoByIds` | `getUserInfoWithUserIds` | `SIGNATURE_DIFFERENCE` |
| UserInfo / 本地单个获取 | — | `getUserInfoWithUserId` | `ANDROID_ONLY` |
| UserInfo / 订阅陌生人属性 | `subscribeUsersInfo` | `subscribeUsersInfo` | `SIGNATURE_DIFFERENCE` |
| UserInfo / 取消订阅 | `unsubscribeUsersInfo` | `unsubscribeUsersInfo` | `SIGNATURE_DIFFERENCE` |
| UserInfo / 拉已订阅用户 | `fetchSubscribedUsers` | `fetchSubscribedUsers` | `SIGNATURE_DIFFERENCE` |
| Push / 本地配置 | `pushOptions` | `getPushConfigs` | `SIGNATURE_DIFFERENCE` |
| Push / 服务端配置 | `getPushNotificationOptionsFromServerWithCompletion` | `getPushConfigsFromServer` / `asyncGetPushConfigsFromServer` | `SIGNATURE_DIFFERENCE` |
| Push / 设置显示昵称 | `updatePushDisplayName` | `updatePushNickname` / `asyncUpdatePushNickname` | `SIGNATURE_DIFFERENCE` |
| Push / 设置显示样式 | `updatePushDisplayStyle` | `updatePushDisplayStyle` / `asyncUpdatePushDisplayStyle` | `SIGNATURE_DIFFERENCE` |
| Push / 设置全局免打扰 | `setSilentModeForAll` | `setSilentModeForAll` | `SIGNATURE_DIFFERENCE` |
| Push / 获取全局免打扰 | `getSilentModeForAllWithCompletion` | `getSilentModeForAll` | `SIGNATURE_DIFFERENCE` |
| Push / 同步会话免打扰 | `syncSilentModeConversationsFromServerCompletion` | `syncSilentModeConversationsFromServer` | `SIGNATURE_DIFFERENCE` |
| Push / 设置单会话免打扰 | `setSilentModeForConversation` | `setSilentModeForConversation` | `SIGNATURE_DIFFERENCE` |
| Push / 获取单会话免打扰 | `getSilentModeForConversation` | `getSilentModeForConversation` | `SIGNATURE_DIFFERENCE` |
| Push / 清除会话提醒类型 | `clearRemindTypeForConversation` | `clearRemindTypeForConversation` | `SIGNATURE_DIFFERENCE` |
| Push / 批量获取会话免打扰 | `getSilentModeForConversations` | `getSilentModeForConversations` | `SIGNATURE_DIFFERENCE` |
| Push / 设置通知翻译语言 | `setPreferredNotificationLanguage` | `setPreferredNotificationLanguage` | `SIGNATURE_DIFFERENCE` |
| Push / 获取通知翻译语言 | `getPreferredNotificationLanguageCompletion` | `getPreferredNotificationLanguage` | `SIGNATURE_DIFFERENCE` |
| Push / 设置离线推送模板 | `setPushTemplate` | `setPushTemplate` | `SIGNATURE_DIFFERENCE` |
| Push / 获取离线推送模板 | `getPushTemplate` | `getPushTemplate` | `SIGNATURE_DIFFERENCE` |

### 平台系统方法

| 模块/能力 | iOS 名 | Android 名 | 分类 |
|---|---|---|---|
| Client / PushKit 绑定、注册、解绑 | `bindPushKitToken` / `registerPushKitToken` / `unBindPushKitToken` / `unRegisterPushKitTokenWithCompletion` | — | `IOS_ONLY` |
| Client / APNs token | `bindDeviceToken` / `registerForRemoteNotificationsWithDeviceToken` / `registerForRemoteNotificationsWithCertName` | — | `IOS_ONLY` |
| Client / FCM token | `bindFCMToken` | `sendFCMTokenToServer` | `SIGNATURE_DIFFERENCE` |
| Client / HMS token | — | `sendHMSPushTokenToServer` | `ANDROID_ONLY` |
| Client / Honor token | — | `sendHonorPushTokenToServer` | `ANDROID_ONLY` |
| Client / FCM 可用性 | — | `isFCMAvailable` | `ANDROID_ONLY` |
| Push / Android 厂商 token | — | `bindDeviceToken` | `ANDROID_ONLY` |
| Push / Android 推送动作回报 | — | `reportPushAction` | `ANDROID_ONLY` |
| Client / iOS App 生命周期 | `applicationDidEnterBackground` / `applicationWillEnterForeground` / `application:didReceiveRemoteNotification:` | — | `IOS_ONLY` |

## 2. Callback / event 名称映射

| 模块/能力 | iOS 名 | Android 名 | 分类 |
|---|---|---|---|
| Client / 连接状态 | `connectionStateDidChange` | `onConnected` / `onDisconnected` | `SIGNATURE_DIFFERENCE` |
| Client / 其他设备登录 | `userAccountDidLoginFromOtherDeviceWithInfo` | `onLogout` | `SIGNATURE_DIFFERENCE` |
| Client / 服务端删除账号 | `userAccountDidRemoveFromServer` | `onLogout` | `SIGNATURE_DIFFERENCE` |
| Client / 账号禁用 | `userDidForbidByServer` | `onLogout` | `SIGNATURE_DIFFERENCE` |
| Client / 强制登出 | `userAccountDidForcedToLogout` | `onLogout` | `SIGNATURE_DIFFERENCE` |
| Client / token 将过期 | `tokenWillExpire` | `onTokenWillExpire` | `SIGNATURE_DIFFERENCE` |
| Client / token 已过期 | `tokenDidExpire` | `onTokenExpired` | `SIGNATURE_DIFFERENCE` |
| Client / 离线消息同步开始 | `onOfflineMessageSyncStart` | `onOfflineMessageSyncStart` | `SAME` |
| Client / 离线消息同步完成 | `onOfflineMessageSyncFinish` | `onOfflineMessageSyncFinish` | `SAME` |
| Client / 数据同步开始 | `syncDataStartWithType` | `onDataSyncStart` | `SIGNATURE_DIFFERENCE` |
| Client / 数据同步完成 | `syncDataFinished` | `onDataSyncFinish` | `SIGNATURE_DIFFERENCE` |
| Client / 数据库打开 | `onDatabaseOpened` | `onDatabaseOpened` | `SIGNATURE_DIFFERENCE` |
| Client / 多设备联系人事件 | `multiDevicesContactEventDidReceive` | `onContactEvent` | `SIGNATURE_DIFFERENCE` |
| Client / 多设备群组事件 | `multiDevicesGroupEventDidReceive` | `onGroupEvent` | `SIGNATURE_DIFFERENCE` |
| Client / 多设备 Thread 事件 | `multiDevicesChatThreadEventDidReceive` | `onChatThreadEvent` | `SIGNATURE_DIFFERENCE` |
| Client / 多设备旧免打扰事件 | `multiDevicesUndisturbEventNotifyFormOtherDeviceData` | — | `IOS_ONLY` |
| Client / 多设备漫游消息删除 | `multiDevicesMessageBeRemoved` | `onMessageRemoved` | `SIGNATURE_DIFFERENCE` |
| Client / 多设备会话事件 | `multiDevicesConversationEvent` | `onConversationEvent` | `SIGNATURE_DIFFERENCE` |
| Client / 日志输出 | `logDidOutput` | `onLog` | `SIGNATURE_DIFFERENCE` |
| Contact / 申请被同意 | `friendRequestDidApproveByUser` | `onFriendRequestAccepted` | `SIGNATURE_DIFFERENCE` |
| Contact / 申请被拒绝 | `friendRequestDidDeclineByUser` | `onFriendRequestDeclined` | `SIGNATURE_DIFFERENCE` |
| Contact / 好友删除 | `friendshipDidRemoveByUser` | `onContactDeleted` | `SIGNATURE_DIFFERENCE` |
| Contact / 好友添加 | `friendshipDidAddByUser` | `onContactAdded` | `SIGNATURE_DIFFERENCE` |
| Contact / 收到好友申请 | `friendRequestDidReceiveFromUser` | `onContactInvited` | `SIGNATURE_DIFFERENCE` |
| Contact / 好友信息更新 | `onFriendInfoChanged` | `onContactInfoUpdate` | `SIGNATURE_DIFFERENCE` |
| Presence / 状态更新 | `presenceStatusDidChanged` | `onPresenceUpdated` | `SIGNATURE_DIFFERENCE` |
| UserInfo / 自身属性更新 | `onSelfUserInfoUpdate` | `onSelfUserInfoUpdate` | `SAME` |
| UserInfo / 其他用户批量更新 | `onUserInfoUpdate` | `onUserInfoUpdate` | `SIGNATURE_DIFFERENCE` |
| Push | — | — | 无公开 callback/event |

## 3. 原生本地校验可确认的 code / description 差异

| 场景 | iOS code / description | Android code / description |
|---|---|---|
| `sendMessage`：已构造的 image/video body 使用非空但不存在的本地路径 | `401 / <path> not exist` | `401 / File not exists or can not be read` |
| `sendMessage`：已构造的 file/voice body 使用非空但不存在的本地路径 | `401 / <path> not exist` | `401 / File movement error.` |

这些都是上传前的原生本地校验。此结论要求消息 body 已成功构造且路径进入发送预检，不代表工厂方法直接接收空路径时也返回同样错误。

## 4. 已确认相同的原生错误

| 场景 | iOS code / description | Android code / description |
|---|---|---|
| `addReaction` / `removeReaction` 的 `messageId` 为空 | `110 / 'messageId' can not be null` | `110 / 'messageId' can not be null` |
| `addReaction` / `removeReaction` 的 `reaction` 为空 | `110 / 'reaction' can not be null` | `110 / 'reaction' can not be null` |

## 5. 需原生直调确认

| 场景 | 已能从原生包确定 | 仍需确认 |
|---|---|---|
| pin/unpin 空 `messageId` | 两端 code 均为 `110`；Android description 为 `messageId is empty` | iOS 最终默认 description；静态包不能把枚举注释当作运行时 description |
| 空消息集合的已读回执 | iOS 为 `110 / messages is empty`；Android 会进入原生核心，Javadocs 定义无合格消息时为 no-op | Android 最终 callback 的 code/description |
| 媒体工厂直接接收空路径 | Android 工厂返回 `null` 且只写日志 | iOS 按具体 body 类型的最终公开结果 |
| 翻译非文本消息 | iOS 为 `1 / message type is not text` | Android 最终 callback 的 code/description |
| 删除服务端会话时 ID 为空 | iOS 为 `107 / InvalidConversation` | Android 空字符串路径的最终 code/description |

结论：只有表 3 的媒体发送场景能静态确认为两端原生 description 差异；表 5 的项目不能预先定性为跨端差异。
