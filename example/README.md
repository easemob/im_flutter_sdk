# easeim_flutter_demo

### 初次运行
执行
```Java
flutter clean
flutter pub get
```

Demo使用Appkey为` easemob-demo#easeui`
可以和环信iOS，Android Demo互通，使用前需要先在Demo中注册账号，并添加好友，其他平台Demo获sdk体验，请访问[下载页](https://www.easemob.com/download/im) 。

### Demo讲解

Demo中使用了环信 [im_flutter_sdk](https://github.com/easemob/im_flutter_sdk)实现了聊天功能，并使用[ease_call_kit](https://github.com/easemob/ease_call_kit)插件实现了语音通话功能， ease_call_kit是一套UI插件，其封装了环信的EaseCallKit，并使用[声网](https://www.agora.io/cn/)的sdk实现了音视频通话功能。

