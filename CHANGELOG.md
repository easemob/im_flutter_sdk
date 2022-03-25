## NEXT

## 3.8.3+7

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
