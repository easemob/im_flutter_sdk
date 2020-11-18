## 集成SDK

## 集成方式：

在flutter项目中的 pubspec.yaml 里面的 dependencies: 下添加
	
	im_flutter_sdk:  
		git:  
			url: https://github.com/easemob/im_flutter_sdk.git  
			ref: alpha

然后 Package get 

注意点: 在调试iOS时，将ios->podfile文件中的 #platform :ios, '9.0' 改成 platform :ios, '9.0'

## 本地方式：

可以先将SDK clone 或者 download 到本地项目中

在flutter项目中的 pubspec.yaml 里面的 dependencies: 下添加

	im_flutter_sdk:  
		path : /本地路径/im_flutter_sdk

执行 Package get 


## 使用SDK方法时导入SDK头文件即可： 
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

### SDK初始化：

	// 设置APPKey
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
	// 初始化sdk
	await EMClient.getInstance.init(options);
	
### 账号相关

	// 登录
	await EMClient.getInstance.login(username, password);
	
	// 注册
	EMClient.getInstance.createAccount(username, password);
	
	// 退出
	EMClient.getInstance.logout(true);	
	
### 设置链接状态监听
	class _MyAppState extends State<MyApp> implements EMConnectionListener

	EMClient.getInstance.addConnectionListener(this);
	abstract class EMConnectionListener {
		/// 网络已连接
	  	void onConnected();

  		/// 连接失败，原因是[errorCode]
 	 	void onDisconnected(int errorCode);
	}
	
### 获取会话列表	

	await EMClient.getInstance.chatManager.loadAllConversations();
	
### 构建消息
	// 文本消息
	EMMessage message = EMMessage.createTxtSendMessage(username: conversation.id, content: text);
	
	// 图片消息
	EMMessage.createImageSendMessage(username: conversation.id, filePath: imgPath);
	
	// 视频消息
	EMMessage.createVideoSendMessage(username: conversation.id, filePath: filePath);
	
	// 音频消息
	EMMessage.createVoiceSendMessage(username: conversation.id, filePath: filePath);
	
	// 位置消息
	EMMessage.createLocationSendMessage(username: conversation.id, latitude: latitude, longitude: longitude, address: address);
	
	// cmd消息
	EMMessage.createCmdSendMessage(username: conversation.id, action: action);
	
	// 自定义消息
	EMMessage.createCustomSendMessage(username: conversation.id, event: event);
	
### 发送消息

	try{
      await EMClient.getInstance.chatManager.sendMessage(message);
    } on EMError catch(e) {

    }
    
### 发起视频通话

     try{
        EMClient.getInstance.callManager.makeCall(EMCallType.Video, conversation.id);
      }on EMError catch(error) {

      }
      
### 接听视频通话

	await EMClient.getInstance.callManager.answerCall();
	
### 设置视频窗口

	 EMRTCLocalView((view, viewId) => EMClient.getInstance.callManager.setLocalSurfaceView(view)