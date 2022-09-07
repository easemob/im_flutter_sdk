## NEXT

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
