# im_flutter_sdk

## 集成SDK

## 远程方式：

在flutter项目中的 pubspec.yaml 里面的 dependencies: 下添加

  im_flutter_sdk:  
      git:  
         url: https://github.com/easemob/im_flutter_sdk.git  
         ref: dev

然后 Package get 一下

注意点: 在调试iOS时，将ios->podfile文件中的 #platform :ios, '9.0' 改成 platform :ios, '9.0'

## 本地方式：

可以先将SDK clone 或者 download 到本地项目中

在flutter项目中的 pubspec.yaml 里面的 dependencies: 下添加

im_flutter_sdk:  
    path : /本地路径/im_flutter_sdk

然后 Package get 一下


## 使用SDK方法时导入SDK头文件即可： 
import 'package:im_flutter_sdk/im_flutter_sdk.dart';  

SDK的方法说明文档见：[Easemob IM Flutter SDK API文档](https://easemob.github.io/im_flutter_sdk):

##  Android使用音视频功能（单人，多人）

1、先下载一份im_flutter_sdk源码：https://github.com/easemob/im_flutter_sdk

2、导入Android Studio，将im_flutter_sdk/example/android项目里的call、conference、model、receiver、utils、widget目录、BaseActivity、以及res下的所有资源都去复制导入到你的android项目里，检索项目里的com.easemob.im_flutter_sdk_example去替换为自己的包名。

3、在AndroidManifest.xml里去配置权限及注册activity

	<uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="com.android.launcher.permission.READ_SETTINGS" />
    <uses-permission android:name="android.permission.BROADCAST_STICKY" />
    <uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
    <!-- 悬浮窗权限 -->
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />

    <application
    	android:usesCleartextTraffic="true"
    >
    <uses-library android:name="org.apache.http.legacy" android:required="false"/>

    <!-- 视频通话 -->
        <activity
            android:name=".call.VideoCallActivity"
            android:configChanges="orientation|keyboardHidden|screenSize"
            android:excludeFromRecents="true"
            android:launchMode="singleTask"
            android:screenOrientation="portrait"
            android:theme="@style/horizontal_slide" />

        <!-- 语音通话 -->
        <activity
            android:name=".call.VoiceCallActivity"
            android:configChanges="orientation|keyboardHidden|screenSize"
            android:excludeFromRecents="true"
            android:launchMode="singleTask"
            android:screenOrientation="portrait"
            android:theme="@style/horizontal_slide" />
        <activity
            android:name=".conference.ConferenceActivity"
            android:configChanges="orientation|keyboardHidden|screenSize"
            android:excludeFromRecents="true"
            android:launchMode="singleInstance"
            android:screenOrientation="portrait"
            android:theme="@style/horizontal_slide" />

        <!-- 会议成员邀请 -->
        <activity
            android:name=".conference.ConferenceInviteActivity"
            android:configChanges="orientation|keyboardHidden|screenSize"
            android:screenOrientation="portrait"
            android:theme="@style/nornal_style"
            android:windowSoftInputMode="adjustPan"/>

    </application>

4、有几个类是使用的kotlin需要配置下

	在project下的build.gradle里配置
	
	buildscript {
	    ext.kotlin_version = '1.3.10'
	    
	    dependencies {
	        	classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
	    	}
	}

	在app的build.gradle里配置
	apply plugin: 'kotlin-android'
	apply plugin: 'kotlin-android-extensions'

	dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
	}

5、在MainActivity里去重写configureFlutterEngine方法，注册音视频plugin

	@Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        flutterEngine.getPlugins().add(new EMCallPlugin());
        flutterEngine.getPlugins().add(new EMConferencePlugin());
    }
6、flutter项目中，在调用初始化环信SDK方法之后，添加这个方法： EMClient.getInstance().callManager().registerCallReceiver();

## iOS使用音视频功能（单人，多人）

先下载一份im_flutter_sdk源码：https://github.com/easemob/im_flutter_sdk

然后到 /自己本地路径/im_flutter_sdk/example/ios/Runner/ ,拿到Calls文件（环信原生iOS音视频相关UI文件），加到自己iOS项目中，这样可以自己在修改Calls中的原生iOS音视频相关UI文件，不会因为更新im_flutter_sdk，导致自己修改的UI部分也被更新。

注意点：如果是OC项目，flutter默认帮生成的iOS项目是swift的，所以是appdelegate.swift，需要将appdelegate.swift删除，自己创建个appdelegate类，然后添加下 main.m 文件，不然会报错

然后在appdelegate.m中，添加 #import "EMCallPlugin.h" 头文件，在 didFinishLaunchingWithOptions 中添加 [EMCallPlugin registerWithRegistrar:[self registrarForPlugin:@"EMCallPlugin"]]; 注册plugin即可

如果是swift项目，按照OC的方式向 appdelegate.swift 添加头文件和注册plugin的方法即可

需要向自己iOS项目的 .plist 文件中添加权限：

Privacy - Camera Usage Description          相机

Privacy - Photo Library Usage Description   相册

Privacy - Microphone Usage Description      麦克风

flutter项目中，在调用初始化环信SDK方法之后，添加下面两个方法：

如果使用1V1音视频通话请添加：EMClient.getInstance().callManager().registerCallSharedManager();

如果使用多人音视频通话请添加：EMClient.getInstance().conferenceManager().registerConferenceSharedManager();

## Getting Started

## 生成文档

SDK API文档由以下命令生成,线上文档请参看[Easemob IM Flutter SDK API文档](https://easemob.github.io/im_flutter_sdk):

```shell

dartdoc --exclude dart:io,dart:async,dart:ui,dart:math,dart:collection,dart:convert,dart:core,dart:developer,dart:isolate,dart:typed_data --output doc
```


## SDK主要方法介绍

## 初始化SDK：

EMOptions options = new EMOptions(appKey: "appkey");

EMClient.getInstance().init(options);

## 登录：

/// 账号密码登录[id]/[password].

/// 如果登录成功，请调用[onSuccess]，如果出现错误，请调用[onError]。

void login(String userName, String password,{onSuccess(String username), onError(int errorCode, String desc)})

EMClient.getInstance().login('id', 'password', onSuccess:(username) {

  print('登录成功 --- ');
  
},onError: (code, desc) {

  print('登录错误 --- $desc');
  
});

## 退出登录:

/// [unbindToken] true 解除推送绑定 ： false 不解除绑定

/// 如果退出登录成功，请调用[onSuccess]，如果出现错误，请调用[onError]。

void logout(bool unbindToken, {onSuccess(), onError(int code, String desc)})

EMClient.getInstance().logout(true ,onSuccess:() {

    print('退出登录成功 --- ');
    
}, onError:(int code, String desc){

    print('退出登录失败 --- $desc');

});


## 发起1v1音视频通话：

/// @nodoc [type] 通话类型，[remoteName] 被呼叫的用户（不能与自己通话），[isRecord] 是否开启服务端录制，[isMerge] 录制时是否合并数据流，

[ext] 通话扩展信息，会传给被呼叫方

/// @nodoc 如果发起实时会话成功，请调用[onSuccess]，如果出现错误，请调用[onError]。

void startCall(EMCallType callType,String remoteName,bool isRecord,bool isMerge,String ext,{onSuccess(),onError(int code, 

String desc)})
        
EMClient.getInstance().callManager().startCall(EMCallType.Video, 'remoteName', false, false, "ext",onSuccess:() {

    print('拨打通话成功');
  
} ,
    
onError:(code, desc){
  
    print('拨打通话失败 --- $desc');
    
});

## 发起多人会议（多人音视频通话）：

/// @nodoc [aType] 会议类型，[password ] 会议密码，[isRecord ] 是否开启服务端录制，[isMerge ] 录制时是否合并数据流

/// @nodoc 如果创建并加入会议成成功，请调用[onSuccess]，如果出现错误，请调用[onError]。

void createAndJoinConference(EMConferenceType conferenceType,String password,bool isRecord,bool isMerge{onSuccess(EMConference 

conf),onError(int code, String desc)})
        
EMClient.getInstance().conferenceManager().createAndJoinConference(EMConferenceType.EMConferenceTypeCommunication,

'123',false, false,

onSuccess:(EMConference conf){
    
    print('发起会议成功');

}, onError:(code,desc){

    print('发起会议失败 --- $desc');
    
} );

## 加入多人会议（加入多人音视频通话）：

/// @nodoc [ConfId] 会议ID，[password ] 会议密码

/// @nodoc 如果加入已有会议成功，请调用[onSuccess]，如果出现错误，请调用[onError]。

void joinConference(String confId,String password,{onSuccess(EMConference conf),onError(int code, String desc)})

EMClient.getInstance().conferenceManager().joinConference('ConfId', 'password',

onSuccess:(EMConference conf){
      
    print('加入会议成功');
      
} ,onError:(code,desc){

    print('加入会议失败 --- $desc');
       
});

其他方法请参考文档：[Easemob IM Flutter SDK API文档](https://easemob.github.io/im_flutter_sdk):
