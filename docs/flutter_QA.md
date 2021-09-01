
# 常见问题


#### 1. 发送的图片/语音/视频/文件 等附件消息接收方无法解析；
可以尝试在发送方构造消息时将displayName设置为文件的名称和后缀，很多flutter解析文件的插件都是通过后缀判断的，如果没有后缀可能导致无法解析。


#### 2. App离线期间有好友申请，在线后无法收到回调；
离线的好友申请通知是在sdk和服务器建立长连接后就会下发的，此时如果没有完成好友通知的注册就会导致错过好友申请，可以把注册的时机提前。

```
  // 注册好友监听
  void initState() {
    super.initState();
    EMClient.getInstance.contactManager.addContactListener(this);
  }

  ......

  // 好友申请回调
  @override
  void onContactInvited(String userName, String reason) {
    ......
  }

  ......

  // 注销好友监听
  void dispose() {
    EMClient.getInstance.contactManager.removeContactListener(this);
    super.dispose();
  }
```



[安卓常见问题](https://github.com/easemob/im_flutter_sdk/blob/stable/docs/Android_QA.md)

[iOS常见问题](https://github.com/easemob/im_flutter_sdk/blob/stable/docs/iOS_QA.md)