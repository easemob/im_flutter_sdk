#### 集成SDK

注册环信请访问[环信官网](!https://www.easemob.com/)

通过git集成
1. 修改 `pubspec.yaml`

```dart
dependencies:
	im_flutter_sdk:  
		git:  
			url: https://github.com/easemob/im_flutter_sdk.git 
			ref: alpha
```

2. 执行`flutter pub get`
3. 导入头文件:
``` dart
import 'package:im_flutter_sdk/im_flutter_sdk.dart'
```

本地集成
1. 先将SDK clone 或者 download 到本地项目中;
2. 修改 `pubspec.yaml`;

```dart
dependencies:
	im_flutter_sdk:  
		path : /本地路径/im_flutter_sdk
```
3. 执行`flutter pub get`
4. 导入头文件

``` dart
import 'package:im_flutter_sdk/im_flutter_sdk.dart'
```

#### 平台说明
Android

*todo*

iOS

*todo*

#### SDK讲解

- `EMClient` 用于管理sdk各个模块和一些账号相关的操作，如注册，登录，退出;
- `EMChatManager`用于管理聊天相关操作，如发送消息，接收消息，发送已读回执，获取会话列表等;
- `EMGroupManager`用于群组相关操作，如获取群组列表，加入群组，离开群组等;
- `EMChatRoomManager`用于管理聊天室，如获取聊天室列表;
- `EMPushManager`用于管理推送配置，如设置推送昵称，推送免打扰时间段等;
- `EMCallManager`用于管理1v1通话，如呼叫，挂断等;
- `EMConferenceManager`用于管理多人通话;



##### 初始化
```dart
	EMOptions options = EMOptions(appKey: 'easemob-demo#chatdemoui');
	EMPushConfig config = EMPushConfig();
	// 配置推送信息
	config
        ..enableAPNs("chatdemoui_dev")
        ..enableHWPush()
        ..enableFCM('')
        ..enableMeiZuPush('', '')
        ..enableMiPush('', '');
	options.pushConfig = config;        
	await EMClient.getInstance.init(options);
```

推送证书申请上传，安卓端请参考文档[第三方推送集成](!http://docs-im.easemob.com/im/android/push/thirdpartypush#%E7%AC%AC%E4%B8%89%E6%96%B9%E6%8E%A8%E9%80%81%E9%9B%86%E6%88%90),iOS请参考文档[APNs推送](!http://docs-im.easemob.com/im/ios/apns/deploy)；


##### 注册
```dart
EMClient.getInstance.createAccount('test1', 'password');
```
(客户端注册，需要将注册方式设置为`开放注册`，具体说明请参考文档[用户管理](!http://docs-im.easemob.com/im/server/ready/user#%E7%94%A8%E6%88%B7%E7%AE%A1%E7%90%86))

##### 登录
```dart
await EMClient.getInstance.login('test1', 'password');
```

##### 退出
```
EMClient.getInstance.logout(true);	
```

注册环信id详细说明请参考文档[用户体系集成](!http://docs-im.easemob.com/im/server/ready/user)


##### 监听服务器链接状态
```dart
class _MyAppState extends State<MyApp> implements EMConnectionListener{
	
	@override
	void initState() {
		super.initState();
		EMClient.getInstance.addConnectionListener(this);
	}

	...

	/// 网络已连接
	@override
	void onConnected() {
	
	}

  	/// 连接失败，原因是[errorCode]
	@override
	void onDisconnected(int errorCode) {
	
	}
}

```
	
##### 获取会话列表	

```dart
await EMClient.getInstance.chatManager.loadAllConversations();
```
	
##### 构建消息
```dart
// 文本消息
EMMessage.createTxtSendMessage(username: '接收方id', content: '消息内容');
	
// 图片消息
EMMessage.createImageSendMessage(username: '接收方id', filePath: '图片路径');
	
// 视频消息
EMMessage.createVideoSendMessage(username: '接收方id', filePath: '视频路径');
	
// 音频消息
EMMessage.createVoiceSendMessage(username: '接收方id', filePath: '语音路径');
	
// 位置消息
EMMessage.createLocationSendMessage(username: '接收方id', latitude: '纬度', longitude: '经度', address: '地址名称');
	
// cmd消息
EMMessage.createCmdSendMessage(username: '接收方id', action: '自定义事件');
	
// 自定义消息
EMMessage.createCustomSendMessage(username: '接收方id', event: '自定义事件');
```
	
##### 发送消息

```dart
try{
	await EMClient.getInstance.chatManager.sendMessage(message);
} on EMError catch(e) {

}
```
    
##### 监听消息发送状态

```dart
class ChatItemState extends State<ChatItem> implements EMMessageStatusListener {

	EMMessage msg;
	...	
			
	void initState() {
		super.initState();
		msg.setMessageListener(this);
	}

	...
	
	/// 消息进度
	@override
	void onProgress(int progress) {}

	/// 消息发送失败
	@override
	void onError(EMError error) {}

	/// 消息发送成功
	@override
	void onSuccess() {}
  
	/// 消息已读
	@override
	void onReadAck() {}

	/// 消息已送达
	@override
	void onDeliveryAck() {}
  
	/// 消息状态发生改变
	@override
	void onStatusChanged() {}
}


```
	
##### 收消息监听
_todo_
	
##### 发起视频通话

```dart
await EMClient.getInstance.callManager.makeCall(EMCallType.Video,conversation.id);
```
      
##### 接听视频通话
```dart
await EMClient.getInstance.callManager.answerCall();
```
##### 设置自己视频窗口
```dart
EMRTCLocalView((view, viewId) {
	EMClient.getInstance.callManager.setLocalSurfaceView(view);
});
```
##### 设置对方视频窗口
```dart
EMRTCRemoteView((view, viewId) {
	EMClient.getInstance.callManager.setRemoteSurfaceView(view);
});
```