## 4.2.0

#### 新增

- 增加 设置好友备注功能。
- 增加 `EMContactManager#fetchContacts` 和 `EMContactManager#fetchAllContacts` 方法分别从服务器一次性和分页获取好友列表，每个好友对象包含好友的用户 ID 和好友备注。
- 增加 `EMContactManager#getContact` 方法从本地获取单个好友的用户 ID 和好友备注。
- 增加 `EMContactManager#getAllContacts` 方法从本地分页获取好友列表，每个好友对象包含好友的用户 ID 和好友备注。
- 增加 `EMMessage#isBroadcast` 属性用于判断通过该消息是否为聊天室全局广播消息。可通过调用 REST API 发送聊天室全局广播消息。
- 增加 `EMGroupManager#fetchJoinedGroupCount` 方法用于从服务器获取当前用户已加入的群组数量。
- 增加 错误码 `706` 表示聊天室所有者不允许离开聊天室。若初始化时，`EMOptions#isChatRoomOwnerLeaveAllowed` 参数设置为 false，聊天室所有者调用 `EMChatRoomManager#leaveChatroom` 方法离开聊天室时会提示该错误。
- 增加 `EMOptions#enableEmptyConversation` 属性用于在初始化时配置获取会话列表时是否允许返回空会话。
- 增加 申请入群被拒绝的回调 `EMGroupEventHandler#onRequestToJoinDeclinedFromGroup` 中新增 decliner 和 applicant 参数表示申请者和拒绝者的用户 ID。

#### 优化

- 统一 Agora Token 和 EaseMob Token 登录方式，原 `EMClient#login` 方法废弃，使用 `EMClient#loginWithToken` 和 `EMClient#loginWithPassword` 方法代替。此外，新增 EaseMob Token 即将过期及已过期的回调，即 EaseMob Token 已过期或有效期过半时也返回 `EMConnectionEventHandler#onTokenDidExpire` 和 `EMClientDelegate#onTokenWillExpire` 回调。

#### 修复

- 修复网络恢复时重连 2 次的问题。
- 修复未登录时调用 leaveChatroom 方法返回的错误提示不准确。

## 4.1.3

#### 新增

- 支持 安卓 14;
- 新增 开启 荣耀推送开关 `EMOptions#enableHonorPush` 方法；

#### 修复

- 修复调用 `EMChatManager#getThreadConversation` 报错；
- 修复 `EMMessage#chatThread` 方法报错;
- 修复 `EMChatRoomEventHandler#onSpecificationChanged` 回调不执行。
- 修复 `EMChatThreadManager#fetchChatThreadMembers` 崩溃。
- 修复特殊场景下，安卓平台退出后再登录会丢失聊天室监听事件问题。
- 修复修改消息后，离线用户上线后拉取历史消息，消息体中缺乏 from 属性的问题。

## 4.1.0

#### 新增：
- 增加 `EMOptions#osType`属性和`EMOptions#deviceName`属性，用户设置设备类型和设备名称；
- 增加 `Combine` 消息类型，用于合并转发消息；
- 增加 `EMChatManager#fetchCombineMessageDetail` 方法;
- 增加 `EMChatManager#modifyMessage` 方法用户修改已发送的消息，目前只支持文本消息消息;
- 增加 `EMChatEventHandler#onMessageContentChanged` 回调，用户监听消息编辑实现；
- 增加 `EMClient#fetchLoggedInDevices` 方法，可是使用token获取已登录的设备列表；
- 增加 `EMClient#kickDevice` 方法，可以使用 token 踢掉指定设备；
- 增加 `EMClient#kickAllDevices` 方法，可以使用 token 踢掉所有已登录设备；
- 增加 `EMChatManager#fetchConversation` 方法，获取服务器会话列表，原方法 `EMChatManager#getConversationsFromServer` 作废；
- 增加 `EMChatManager#pinConversation` 方法，实现在服务器会话列表中 置顶/取消置顶 会话；
- 增加 `hatManager#fetchPinnedConversations` 方法，从服务器获取已置顶会话；
- 增加 `EMMessage#receiverList` 属性，用于在群组/聊天室中发送定向消息；

#### 修复：
- 修复 ios 中无法收到 `EMConnectionEventHandler#onConnected` 和 `EMConnectionEventHandler#onDisconnected` 的问题；
- 修复 安卓消息中，发送方`attributes` 中包含string类型，接收方变为int类型的问题；

#### 优化：
- 离开聊天室 `EMChatRoomEventHandler#onRemovedFromChatRoom` 回调中增加离开原因;
- 被其他设备踢下线 `EMConnectionEventHandler#onUserDidLoginFromOtherDevice` 回调中增加操作人deviceName;


## 4.0.2

#### 新增：
- 增加 `EMGroupManager#setMemberAttributes` 方法，用于设置群成员属性；
- 增加 `EMGroupManager#fetchMemberAttributes` 和 `GroupManager#fetchMembersAttributes` 方法用户获取群成员属性；
- 增加 `EMGroupEventHandler#onAttributesChangedOfGroupMember` 群成员属性变更回调;
- 增加 `EMChatManager#fetchHistoryMessagesByOption` 方法；
- 增加 `EMConversation#deleteMessagesWithTs` 方法；
- 增加 `EMMessage#deliverOnlineOnly` 属性用于设置只向在线用户投递消息；

#### 修复：
- 修复安卓 hot reload 后回调多次的问题；
- 修复iOS 获取聊天室属性key传null导致的崩溃问题；

#### 优化：
- 为`ChatManager#fetchHistoryMessages` 方法增加获取方向；

## 4.0.0+7

#### 修复
- 修复初始化无返回的问题。

## 4.0.0+6

#### 修复
- 修复下载附件结束后状态不准确的问题。

## 4.0.0+7
- 修复初始化问题。

## 4.0.0+6
- 修复下载附件结束后状态不准确的问题。

## 4.0.0+5

#### 修复
- 修复下载附件回调不执行。

## 4.0.0+4

#### 修复
- 安卓构建视频消息崩溃的问题。

## 4.0.0+3

#### 修复
- 安卓 `onRemovedFromChatRoom` 不回调。

## 4.0.0+2

#### 修复

- 修复List<String>? 转换失败；
- 修复图片消息和视频消息转换失败；

## 4.0.0

#### 新增特性

- 依赖的原生平台 `iOS` 和 `Android` 的 SDK 升级为 v4.0.0 版本。
- 新增 `EMChatManager#fetchConversationListFromServer` 方法实现从服务器分页获取会话列表。
- 新增 `EMMessage#chatroomMessagePriority` 属性实现聊天室消息优先级功能，确保高优先级消息优先处理。

#### 优化

修改发送消息结果的回调由 `EMMessage#setMessageStatusCallBack` 修改为 `EMChatManager#addMessageEvent`。

#### 修复

修复 `EMChatManager#deleteMessagesBeforeTimestamp` 执行失败的问题。

# 3.9.9+1
修复：
1. 修复ios群已读回执不执行；

新增：
1. 增加会话根据时间删除服务器漫游消息api `EMConversation#removeServerMessageBeforeTimeStamp(timestamp)`。

# 3.9.9
修复：
1.修复极端情况下 SDK 崩溃的问题。

## 3.9.7+4
修复：
1. 安卓不执行onGroupDestroyed回调；
2. 构造位置消息时无法设置buildingName；

## 3.9.7+3
修复：
1. 安卓不会执行 onAutoAcceptInvitationFromGroup 回调；

## 3.9.7+2

修复：
1. 修复 StartCallback() 不会回调的问题；
2. 修复 iOS 根据时间获取消息失败的问题；

## 3.9.7+1

修复:
  1. 修复 安卓 fcm send id偶现为空的问题；
  2. 修复 安卓 `SilentModeResult` expireTs 为空的问题；

## 3.9.7

新增特性:
  1. 新增聊天室自定义属性功能。
  2. 新增 `areaCode` 方法限制连接边缘节点的范围。
  3. `EMGroup` 中增加 `isDisabled` 属性显示群组禁用状态，需要开发者在服务端设置。该属性在调用 `EMGroupManager` 中的 `fetchGroupInfoFromServer` 方法获取群组详情时返回。

优化：
  1. 移除 SDK 一部分冗余日志。

修复
  1. 修复极少数场景下，从服务器获取较大数量的消息时失败的问题。
  2. 修复数据统计不正确的问题。
  3. 修复极少数场景下打印日志导致的崩溃。

## 3.9.5

- 将 AddManagerListener 方法标为过期；
- 增加 customEventHandler；
- 添加 EventHandler；
- 增加 PushTemplate 方法；
- 增加 Group isDisabled 属性；
- 增加 PushConfigs displayName 属性；
- 修改 Api referances;
- 升级原生依赖为 3.9.5

## 3.9.4+3

- 修复 安卓端 `loadAllConversations` crash.

## 3.9.4+2

- 修复 `EMClient.getInstance.startCallback()` 执行时安卓偶现崩溃；

## 3.9.4+1
- 增加ChatSilentMode;

## 3.9.4
- 移除过期Api；

## 3.9.3
- 新增thread实现；
- 修复部分bug；
- 依赖原生sdk版本为3.9.3

## 3.9.2
- 增加Reaction实现；
- 增加举报功能；
- 增加获取群组已读api；
- 添加下载群文件进度回调；
- 修复下载视频偶现失败；
- 修复获取群免打扰详情失败；
- 修复 startCallback是 ios 偶现 crash;



## 3.9.1
- 增加 用户在线状态 (Presence) 订阅功能；
- 增加 翻译 功能更新，增加自动翻译接口。用户可以按需翻译，和发消息自动翻译。

## 3.9.0+2

- 修改用户退出/离线回调;
  - EMConnectionListener#onConnected: 长连接恢复;
  - EMConnectionListener#onDisconnected: 长连接断开;
  - EMConnectionListener#onUserDidLoginFromOtherDevice: 当前账号在其他设备登录;
  - EMConnectionListener#onUserDidRemoveFromServer: 当前账号被服务器删除;
  - EMConnectionListener#onUserDidForbidByServer: 当前账号登录被服务器拒绝;
  - EMConnectionListener#onUserDidChangePassword: 当前账号密码变更;
  - EMConnectionListener#onUserDidLoginTooManyDevice: 当前账号登录太多设备;
  - EMConnectionListener#onUserKickedByOtherDevice: 当前账号被登录的其他设备设置下线;
  - EMConnectionListener#onUserAuthenticationFailed: 当前账号鉴权失败;
- 依赖原生sdk版本为3.9.2.1；
- 修复ios group ack 问题；

## 3.9.0+1

- 修复message.attribute不准;

- 增加 EMClient.getInstance.startCallback() 方法
  
  ```dart
  EMClient.getInstance.startCallback();
  ```
  
  只有调用该方法后，`EMContactManagerListener`、 `EMGroupEventListener` 、 `EMChatRoomEventListener` 回调才会开始执行;

- 修复删除聊天室白名单成员失败;

## 3.9.0

- 增加单人推送免打扰接口；

- 增加api referance;

- 增加renewToken api;

- 修改消息callback方式；

- iOS移除自动绑定deviceToken，如需使用，需要在iOS端单独增加；

- android移除多余权限；

- 修改已知bug；

## 3.8.9

- 增加单聊消息免打扰；
- 去除不必要的信息收集；
- 修复安卓某些场景下数据库损坏导致崩溃；
- 移除对FCM11.4.0的依赖；
- 修复安卓WAKE_LOCK权限导致的崩溃；
- 增加用户被全局禁言时发消息错误码；
- 增强数据传输安全性；
- 增强本地数据存储安全性；
- 新增使用Token登录时，Token过期的回调；
- 修复拉取历史漫游消息不全的bug；
- 默认使用https；
- 优化登录速度；

## 3.8.3+9

- 将设置推送相关操作从EMPushConfigs中移到EMPushManager中；
- 修复已知bug；

## 3.8.3+8

- 修复ios使用token登录失败；
- 修改Login方法和Logout方法返回值；

## 3.8.3+6

- 修改EMImPushConfig为EMPushConfigs;
- 删除EMOptions中的EMPushConfig.设置推送证书时直接调用EMOptions即可;
- EMGroup中移除ShareFiles，如果需要获取共享文件，请调用Api:
  `EMClient.getInstance.groupManager.getGroupFileListFromServer(groupId)` 
- 将isConnected和isLoginBefore、Token改为从原生获取；
- 修复安卓设置群组免打扰失效的问题；
- 修复获取公开群crash的问题；
- 修改throw error的逻辑；
- 修改构造文本消息时的方法，需要传入参数名；
- 修改部分原生方法逻辑；
- 调整项目目录结构；
- 将`onConversationRead`回调方法参数改为必选；
- 

## 3.8.3+5

- 更新安卓依赖原生sdk版本；
- 修复获取本地群组crash；

## 3.8.3+4

* 修复消息attribute类型变为bool类型；
* 修复群组免打扰属性不准；
* 修复ios importMessages方法bug；
* 修复群、聊天室禁言时不执行回调的bug；
* 修复下载方法不执行callback；
* 构造文件消息提供设置文件大小属性；
* 修改`EMGroupChangeListener` 为 `EMGroupEventListener`

## 3.8.3+3

* 修复安卓下resendMessage方法发送失败时不回调onError；
* 修复fetchChatRoomMembers返回类型错误；

## 3.8.3+2

* 增加群组已读回执；
* 不在提供EMContact类，直接返回String类型username;

## 3.8.3

* 增加用户属性；
* 修复已知bug；

## 1.0.0

* 用户管理；
* 群组管理；
* 聊天室管理；
* 会话管理；
* 通讯录管理；
* 推送管理；
