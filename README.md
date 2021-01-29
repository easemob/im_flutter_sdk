## 集成SDK

注册环信请访问[环信官网](!https://www.easemob.com/)。

#### 通过git集成  

1. 修改 `pubspec.yaml`;

```dart
dependencies:
  im_flutter_sdk:  
    git:  
      url: https://github.com/easemob/im_flutter_sdk.git 
      ref: alpha
```

2. 执行`flutter pub get`;
3. 导入头文件:

```dart
import 'package:im_flutter_sdk/im_flutter_sdk.dart'
```

#### 本地集成  

1. 先将SDK clone 或者 download 到本地项目中;
2. 修改 `pubspec.yaml`;

```dart
dependencies:
  im_flutter_sdk:  
    path : /本地路径/im_flutter_sdk
```
3. 执行`flutter pub get`;
4. 导入头文件:

``` dart
import 'package:im_flutter_sdk/im_flutter_sdk.dart'
```
## SDK讲解

- `EMClient` 用于管理sdk各个模块和一些账号相关的操作，如注册，登录，退出;
- `EMChatManager`用于管理聊天相关操作，如发送消息，接收消息，发送已读回执，获取会话列表等;
- `EMContactManager` 用于管理通讯录相关操作，如获取通讯录列表，添加好友，删除好友等;
- `EMGroupManager`用于群组相关操作，如获取群组列表，加入群组，离开群组等;
- `EMChatRoomManager`用于管理聊天室，如获取聊天室列表;
- `EMPushManager`用于管理推送配置，如设置推送昵称，推送免打扰时间段等;

> SDK依赖环信Lite SDK，不支持音视频。


### EMClient

#### 初始化

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

>环信的推送只针对离线设备，如果您的app只是后台且没有被系统挂起，此时客户端的长连接仍然还在，这时消息仍然会直接走收消息的方法，并不会触发推送，这就要求您在收消息时判断App的状态，并实现本地推送。  
>推送证书申请上传，安卓端请参考文档[第三方推送集成](!http://docs-im.easemob.com/im/android/push/thirdpartypush#%E7%AC%AC%E4%B8%89%E6%96%B9%E6%8E%A8%E9%80%81%E9%9B%86%E6%88%90)，iOS请参考文档[APNs推送](!http://docs-im.easemob.com/im/ios/apns/deploy)。

#### 注册

```dart
try {
  await EMClient.getInstance.createAccount(username, password);
} on EMError catch (e) {
  print('操作失败，原因是: $e');
}
```

>客户端注册需要将注册方式设置为`开放注册`，具体说明请参考文档[用户管理](!http://docs-im.easemob.com/im/server/ready/user#%E7%94%A8%E6%88%B7%E7%AE%A1%E7%90%86)。

#### 登录

```dart
try {
  await EMClient.getInstance.login(username, password);
} on EMError catch (e) {
  print('操作失败，原因是: $e');
}
```

#### 获取当前登录环信id

```dart
EMClient.getInstance.currentUsername;
```

#### 退出

```dart
try {
  // true: 是否解除deviceToken绑定。
  await EMClient.getInstance.logout(true);
} on EMError catch (e) {
  print('操作失败，原因是: $e');
}

```

>退出也有失败的情况，需要确定是否失败。  
>注册环信id详细说明请参考文档[用户体系集成](!http://docs-im.easemob.com/im/server/ready/user)。


#### 监听服务器连接状态

```dart
class _MyAppState extends State<MyApp> implements EMConnectionListener{
	
  @override
  void initState() {
    super.initState();
    // 添加连接监听
    EMClient.getInstance.addConnectionListener(this);
  }

	...

  @override
  void onConnected() {
    // 网络已连接
  }


  @override
  void onDisconnected(int errorCode) {
    // 连接失败，原因是[errorCode]	
  }
	
	...
	
  @override
  void dispose() {
    // 移除连接监听
    EMClient.getInstance.removeConnectionListener(this);
    super.dispose();
  }
}

```

#### 获取当前连接状态

```dart
EMClient.getInstance.connected;
```

#### 获取flutter sdk版本号

```dart
EMClient.getInstance.flutterSDKVersion;
```

### EMChatManager

#### 获取会话列表	

```dart
try {
  List<EMConversation> conList = await EMClient.getInstance.chatManager.loadAllConversations();
} on EMError catch (e) {
  print('操作失败，原因是: $e');
}
```

>会话列表是存在本地的一种消息管理对象，如果您会话中没有消息，则表示会话不存在。


#### 创建会话

```dart
try {
  // emId: 会话对应环信id, 如果是群组或者聊天室，则为群组id或者聊天室id
  EMConversation conv = await EMClient.getInstance.chatManager.getConversation(emId);
} on EMError catch (e) {
  print('操作失败，原因是: $e');
}

```

#### 获取会话中的消息

```dart
try {
  List<EMMessage> msgs = con.loadMessages();
} on EMError catch (e) {
  print('操作失败，原因是: $e');
}
```
#### 获取会话中未读消息数

```dart
con.unreadCount;
```

#### 设置单条消息为已读

```dart
try {
  con.markMessageAsRead(msg.msgId);
} on EMError catch (e) {
  print('操作失败，原因是: $e');
}
```

#### 设置所有消息为已读

```dart
try {
  con.markAllMessagesAsRead();
} on EMError catch (e) {
  print('操作失败，原因是: $e');
}
```

#### 发送消息已读状态

```dart
try {
  await EMClient.getInstance.chatManager.sendMessageReadAck(msg);
} on EMError catch (e) {
  print('操作失败，原因是: $e');
}
```

#### 删除会话中的消息

```dart
try{
  // 删除会话中所有消息
  await conv.deleteAllMessages();
} on EMError catch (e) {
  print('操作失败，原因是: $e');
}

```

#### 插入消息

```dart
try{
  // 向会话中插入一条消息
  await conv.insertMessage(msg);
} on EMError catch (e) {
  print('操作失败，原因是: $e');
}

```

> SDK在您发送和接收消息(_cmd类型消息除外_)后会自动将消息插入数据库中，并不需要您自己将消息插入数据库，但如果您需要自己插入一条消息时可以调用该api。  

#### 更新消息

```dart
try{
  await conv.updateMessage(msg);
} on EMError catch (e) {
  print('操作失败，原因是: $e');
}

```



```dart
try{
  // 删除会话中某一条消息
  await conv.deleteMessage(msg.msgId);
} on EMError catch (e) {
  print('操作失败，原因是: $e');
}

```

#### 删除会话

```dart
try {
  await EMClient.getInstance.chatManager.deleteConversation(conversation.id);
} on EMError catch (e) {
  print('操作失败，原因是: $e');
}

```
​	
#### 构建要发送的消息

```dart
// 文本消息
EMMessage msg = EMMessage.createTxtSendMessage(username: '接收方id', content: '消息内容');
	
// 图片消息
EMMessage msg = EMMessage.createImageSendMessage(username: '接收方id', filePath: '图片路径');
	
// 视频消息
EMMessage msg = EMMessage.createVideoSendMessage(username: '接收方id', filePath: '视频路径');
	
// 音频消息
EMMessage msg = EMMessage.createVoiceSendMessage(username: '接收方id', filePath: '语音路径');
	
// 位置消息
EMMessage msg = EMMessage.createLocationSendMessage(username: '接收方id', latitude: '纬度', longitude: '经度', address: '地址名称');
	
// cmd消息
EMMessage msg = EMMessage.createCmdSendMessage(username: '接收方id', action: '自定义事件');
	
// 自定义消息
EMMessage msg = EMMessage.createCustomSendMessage(username: '接收方id', event: '自定义事件');
```

> 如果您是要构建群组或者聊天室消息，需要修改消息的`chatType`属性, 如:   
> `msg.chatType = EMMessageChatType.GroupChat;`

#### 发送消息

```dart
try{
  await EMClient.getInstance.chatManager.sendMessage(msg);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 监听消息发送状态

```dart
class ChatItemState extends State<ChatItem> implements EMMessageStatusListener {

  EMMessage msg;
  ...	
			
  void initState() {
    super.initState();
    // 添加监听
    msg.setMessageListener(this);
  }

	...
	
  // 消息进度
  @override
  void onProgress(int progress) {
  }

  // 消息发送失败
  @override
  void onError(EMError error) {
  }

  // 消息发送成功
  @override
  void onSuccess() {
	}
  
  // 消息已读
  @override
  void onReadAck() {
  }

  // 消息已送达
  @override
  void onDeliveryAck() {
  }
  
  // 消息状态发生改变
  @override
  void onStatusChanged() {
  }
	
  dispose(){
    msg.setMessageListener(null);
    super.dispose();
  }
	
}

```

#### 重发消息

```dart
try{
  await EMClient.getInstance.chatManager.resendMessage(message);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```
#### 撤回消息

```dart
try{
  await EMClient.getInstance.chatManager.recallMessage(msg.msgId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}

```

>消息撤回为增值服务，您只能撤回2分钟内的消息，如需开通，请[咨询商务](https://www.easemob.com/pricing/im#p08)。


#### 收消息监听

```dart

class _ChatPageState extends State<ChatPage> implements EMChatManagerListener {

  @override
  void initState() {
    super.initState();
    // 添加收消息监听
    EMClient.getInstance.chatManager.addListener(this);
  }

 
  // 收到cmd消息回调
  @override
  onCmdMessagesReceived(List<EMMessage> messages) {
  }

  // 会话列表数量变更
  @override
  onConversationsUpdate() {
  }

  // 消息已送达回调
  @override
  onMessagesDelivered(List<EMMessage> messages) {
  }

  // 消息已读回调
  @override
  onMessagesRead(List<EMMessage> messages) {
  }

  // 消息被撤回回调
  @override
  onMessagesRecalled(List<EMMessage> messages) {
  }

  // 收消息回调
  @override
  onMessagesReceived(List<EMMessage> messages) {
  }
  
  @override
  void dispose() {
    // 移除收消息监听
    EMClient.getInstance.chatManager.removeListener(this);
    super.dispose();
  }
}

```

### EMContactManager

#### 从服务器获取通讯录中的用户列表

```dart
try{
  List<EMContact> contactsList = await EMClient.getInstance.contactManager.getAllContactsFromServer();
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>环信收发消息并不需要对方是您通讯录中的成员，只要知道对方的环信id就可以发送消息。


#### 发送添加申请

```dart
try{
  await EMClient.getInstance.contactManager.addContact(friendEmId, reason: '您好，我想添加您为好友');
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>添加申请不会发推送，如果用户不在线，等上线后会收到。

#### 删除通讯录中的成员

```dart
try{
  await EMClient.getInstance.contactManager.deleteContact(friendEmId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 从服务器获取黑名单

```dart
try{
  List<EMContact> contactsList = await EMClient.getInstance.contactManager.getBlackListFromServer();
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```


#### 添加用户到黑名单中

```dart
try{
  await EMClient.getInstance.contactManager.addUserToBlackList(emId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>黑名单和通讯录是独立的，被添加人不需要在您的通讯录中，如果是通讯录中成员被加入到黑名单后，他仍然会出现在您的通讯录名单中，同时他也会出现在您的黑名单中。被添加到黑名单后，您双方均无法收发对方的消息。

#### 将用户从黑名单中删除

```dart
try{
  await EMClient.getInstance.contactManager.removeUserFromBlackList(emId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```


#### 通讯录监听

```dart
class _ContactPageState extends State<ContactPage> implements EMContactEventListener {

  @override
  void initState() {
    super.initState();
    // 添加通讯录监听
    EMClient.getInstance.contactManager.addContactListener(this);
  }


  // [userName]添加您为好友
  @override
  onContactAdded(String userName) {
  }

  // [userName]将您从好友中删除
  @override
  onContactDeleted(String userName) {
  }
  
  // 收到[userName]的好友申请，原因是[reason]
  @override
  onContactInvited(String userName, String reason) {
  }
  
  // 发出的好友申请被[userName]同意
  @override
  onFriendRequestAccepted(String userName) {
  }
  
  // 发出的好友申请被[userName]拒绝
  @override
  onFriendRequestDeclined(String userName) {
  }

  @override
  void dispose() {
    // 移除通讯录监听
    EMClient.getInstance.contactManager.removeContactListener(this);
    super.dispose();
  }
}
```

#### 同意添加申请

```dart
try{
  await EMClient.getInstance.contactManager.acceptInvitation(emId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 拒绝添加申请

```dart
try{
  await EMClient.getInstance.contactManager.declineInvitation(emId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

### EMGroupManager

#### 从服务器获取已加入群组列表

```dart
try{
  List<EMGroup> groupsList = await EMClient.getInstance.groupManager.getJoinedGroupsFromServer();
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}

```

#### 从缓存中获取已加入群组列表

```dart
try{
  List<EMGroup> groupsList = await EMClient.getInstance.groupManager.getJoinedGroups();
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}

```

#### 从服务器获取公开群组列表

```dart
try{
  List<EMGroup> groupsList = await EMClient.getInstance.groupManager.getPublicGroupsFromServer();
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 创建群组

```dart
try{
  EMGroup group = await EMClient.getInstance.groupManager.createGroup('群组名称', settings: EMGroupOptions());
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

> EMGroupOptions可以对群类型`EMGroupStyle`等参数进行设置，群组有四种，分别是:      
> `PrivateOnlyOwnerInvite`私有群，只有群主和管理员能邀请他人进群，被邀请人会收到邀请信息，同意后可入群;    
> `PrivateMemberCanInvite`私有群，所有人都可以邀请他人进群，被邀请人会收到邀请信息，同意后可入群;    
> `PublicJoinNeedApproval`公开群，可以通过获取公开群列表api取的，申请加入时需要群主或管理员同意;    
> `PublicOpenJoin`公开群，可以通过获取公开群列表api取，可以直接进入;    


#### 获取群组详情

```dart
try{
  EMGroup group = await EMClient.getInstance.groupManager.getGroupSpecificationFromServer(group.groupId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 获取群成员列表

```dart
try{
  EMCursorResult result = await EMClient.getInstance.groupManager.getGroupMemberListFromServer(group.groupId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 加入公开群组

```dart
try{
  await EMClient.getInstance.groupManager.joinPublicGroup(groupId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>需要群组类型是`PublicOpenJoin `,调用后直接加入群组。

#### 申请加入公开群

```dart
try{
  await EMClient.getInstance.groupManager.requestToJoinPublicGroup(groupId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>需要群组类型是`PublicJoinNeedApproval`,申请后，群主和管理员会收到加群邀请，同意后入群。

#### 邀请用户入群

```dart
try{
  await EMClient.getInstance.groupManager.addMembers(groupId, inviteMembers);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>需要群组类型是`PrivateOnlyOwnerInvite`或`PrivateMemberCanInvite`,     
>`PrivateOnlyOwnerInvite`时，群主和管理员可以调用；     
>`PrivateMemberCanInvite `是，群中任何人都可以调用；    
>被邀请方会收到邀请通知，同意后进群。邀请通知并不会以推送的形式发出，如果用户不在线，等上线后会收到，用户同意后入群。

#### 从群组中移除用户

```dart
try{
  await EMClient.getInstance.groupManager.removeMembers(groupId, inviteMembers);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>群主和管理员可以调用。

#### 添加管理员

```dart
try{
  await EMClient.getInstance.groupManager.addAdmin(groupId, memberId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>群主可以调用。被操作人会收到被添加为管理员回调，该回调无推送，如用户不在线，上线后会收到。


#### 移除管理员

```dart
try{
  await EMClient.getInstance.groupManager.removeAdmin(groupId, memberId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>群主可以调用。被操作人会收到被移除管理员回调，该回调无推送，如用户不在线，上线后会收到。

#### 退出群组

```dart
try{
  await EMClient.getInstance.groupManager.leaveGroup(groupId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 解散群组

```dart
try{
  await EMClient.getInstance.groupManager.destroyGroup(groupId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>只有群主可以调用。

#### 转移群组

```dart
try{
  await EMClient.getInstance.groupManager.changeGroupOwner(groupId, newOwner);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>只有群主可以调用。

#### 获取群组黑名单列表

```dart
try{
  List blockList = await EMClient.getInstance.groupManager.getGroupBlacklistFromServer(group.groupId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 将群成员添加到群黑名单

```dart
try{
  await EMClient.getInstance.groupManager.blockMembers(group.groupId, blackList);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>该方法只有群主和管理员可以调用，被操作用户当前必须是群成员，当用户被加入到群黑名单后，该用户将从群成员中移除并加入到当前群的黑名单中。同时该用户将无法再进入该群。

#### 将用户从黑名单移除

```dart
try{
  await EMClient.getInstance.groupManager.unblockMembers(group.groupId, unBlackList);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>该方法只有群主和管理员可以调用，当账号从黑名单中移除后可以再允许申请加群。

#### 获取群禁言列表

```dart
try{
  List mutesList = await EMClient.getInstance.groupManager.getGroupMuteListFromServer(group.groupId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 对成员禁言

```dart
try{
  await EMClient.getInstance.groupManager.muteMembers(group.groupId, mutesList);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>该方法只有群主和管理员可以调用，被禁言的用户仍然可以收到群中的消息，但是无法发出消息， 白名单中的用户即使被加入到禁言列表中也不受影响。

#### 对成员解除禁言

```dart
try{
  await EMClient.getInstance.groupManager.unMuteMembers(group.groupId, unMutesList);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>该方法只有群主和管理员可以调用。

#### 对所有成员禁言

```dart
try{
  await EMClient.getInstance.groupManager.muteAllMembers(group.groupId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>该方法只有群主和管理员可以调用，对群主，管理员，白名单中的成员无效，且针对所有人的`禁言`操作与`muteMembers`、`unMuteMembers`接口不冲突，该接口的操作并不会导致`getGroupMuteListFromServer`接口的返回的数据变化。

#### 对所有成员解除禁言

```dart
try{
  await EMClient.getInstance.groupManager.unMuteAllMembers(group.groupId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>该方法只有群主和管理员可以调用，且针对所有人的`解除禁言`操作与`muteMembers`、`unMuteMembers`接口不冲突，该接口的操作并不会导致`getGroupMuteListFromServer`接口的返回的数据变化。当调用该方法后，之前在禁言列表中的用户仍在禁言列表中，且仍处于禁言状态。

#### 获取白名单列表

```dart
try{
  List whiteList = await EMClient.getInstance.groupManager.getGroupWhiteListFromServer(group.groupId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 将用户添加到白名单中

```dart
try{
  await EMClient.getInstance.groupManager.addWhiteList(group.groupId, whiteList);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>该方法只有群主和管理员可以调用，当用户被加入到白名单后，当群组全部禁言或者被添加到禁言列表后仍可以发言。

#### 将用户从白名单中移除

```dart
try{
  await EMClient.getInstance.groupManager.removeWhiteList(group.groupId, whiteList);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>该方法只有群主和管理员可以调用。

#### 判断自己是否在白名单中

```dart
try{
  bool inWhiteList = await EMClient.getInstance.groupManager.isMemberInWhiteListFromServer(group.groupId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 不接收群消息

```dart
try{
  await EMClient.getInstance.groupManager.blockGroup(group.groupId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>设置后群组中的所有消息都无法收到，用户不在线时也不会有推送告知。

#### 恢复接收群消息

```dart
try{
  await EMClient.getInstance.groupManager.unblockGroup(group.groupId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 消息免打扰

```dart
try{
  await EMClient.getInstance.groupManager.ignoreGroupPush(group.groupId, true);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>设置后用户在线时可以正常接收群消息，当用户不在线时，该群组有新消息时不会有推送告知。

#### 更新群名称

```dart
try{
  await EMClient.getInstance.groupManager.changeGroupName(group.groupId, newName);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>群主或管理员可以调用。

#### 更新群描述

```dart
try{
  await EMClient.getInstance.groupManager.changeGroupDescription(group.groupId, newDescription);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>群主或管理员可以调用。


#### 获取群组公告

```dart
try{
  String announcement = await EMClient.getInstance.groupManager.getGroupAnnouncementFromServer(group.groupId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 更新群公告

```dart
try{
  await EMClient.getInstance.groupManager.updateGroupAnnouncement(group.groupId, announcement);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>群主或管理员可以调用。

#### 获取群共享文件列表

```dart
try{
  List<EMGroupSharedFile> filesList = await EMClient.getInstance.groupManager.getGroupFileListFromServer(group.groupId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 上传群共享文件

```dart
try{
  await EMClient.getInstance.groupManager.uploadGroupSharedFile(group.groupId, filePath);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 下载群共享文件

```dart
try{
  await EMClient.getInstance.groupManager.uploadGroupSharedFile(group.groupId, groupSharedFile.fileId, savePath: path);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 删除群共享文件

```dart
try{
  await EMClient.getInstance.groupManager.removeGroupSharedFile(group.groupId, groupSharedFile.fileId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>群主，管理员，文件上传者可以调用。

#### 群回调监听

```dart
class _GroupPageState extends State<GroupPage> implements EMGroupChangeListener {

  @override
  void initState() {
    super.initState();
    // 添加群组监听
    EMClient.getInstance.groupManager.addGroupChangeListener(this);
  }

	...

  // id是[groupId], 名称是[groupName]的群邀请被[inviter]拒绝,理由是[reason]
  void onInvitationReceived(String groupId, String groupName, String inviter, String reason) {
  }

  // 收到用户[applicant]申请加入id是[groupId], 名称是[groupName]的群，原因是[reason]
  void onRequestToJoinReceived(String groupId, String groupName, String applicant, String reason) {
  }

  // 入群申请被同意
  void onRequestToJoinAccepted(String groupId, String groupName, String accepter) {
  }

  // 入群申请被拒绝
  void onRequestToJoinDeclined(String groupId, String groupName, String decliner, String reason) {
  }

  // 入群邀请被同意
  void onInvitationAccepted(String groupId, String invitee, String reason) {
  }

  // 入群邀请被拒绝
  void onInvitationDeclined(String groupId, String invitee, String reason) {
  }

  // 被移出群组
  void onUserRemoved(String groupId, String groupName) {
  }

  // 群组解散
  void onGroupDestroyed(String groupId, String groupName) {
  }

  // 自动同意加群
  void onAutoAcceptInvitationFromGroup(String groupId, String inviter, String inviteMessage) {
  }

  // 群禁言列表增加
  void onMuteListAdded(String groupId, List mutes, int muteExpire) {
  }

  // 群禁言列表减少
  void onMuteListRemoved(String groupId, List mutes) {
  }

  // 群管理增加
  void onAdminAdded(String groupId, String administrator) {
  }

  // 群管理被移除
  void onAdminRemoved(String groupId, String administrator) {
  }

  // 群所有者变更
  void onOwnerChanged(String groupId, String newOwner, String oldOwner) {
  }

  // 有用户加入群
  void onMemberJoined(String groupId, String member) {
  }

  // 有用户离开群
  void onMemberExited(String groupId, String member) {
  }

  // 群公告变更
  void onAnnouncementChanged(String groupId, String announcement) {
  }

  // 群共享文件增加
  void onSharedFileAdded(String groupId, EMGroupSharedFile sharedFile) {
  }

  // 群共享文件被删除
  void onSharedFileDeleted(String groupId, String fileId) {
  }

	...
   
  @override
  void dispose() {
    // 移除群组监听
    EMClient.getInstance.groupManager.removeGroupChangeListener(this);
    super.dispose();
  }
}

```

#### 同意加群申请

```dart
try{
  await EMClient.getInstance.groupManager.acceptJoinApplication(group.groupId, username);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>群主和管理员可以调用。

#### 拒绝加群申请

```dart
try{
  await EMClient.getInstance.groupManager.declineJoinApplication(group.groupId, username);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>群主和管理员可以调用。

#### 同意加群邀请

```dart
try{
  await EMClient.getInstance.groupManager.declineJoinApplication(group.groupId, inviter);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 拒绝加群邀请

```dart
try{
  await EMClient.getInstance.groupManager.declineInvitationFromGroup(group.groupId, inviter);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

### EMChatRoomManager

#### 从服务器获取聊天室列表

```dart
try{
  EMPageResult result = await EMClient.getInstance.roomManager.fetchPublicChatRoomsFromServer();
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 获取本地缓存聊天室列表

```dart
try{
  List<EMChatRoom> list = await EMClient.getInstance.roomManager.getAllChatRooms();
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 创建聊天室

```dart
try{
  EMChatRoom room = await EMClient.getInstance.roomManager.createChatRoom('聊天室名称');
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>聊天室创建需要单独拥有权限，具体可以参考文档[聊天室管理](http://docs-im.easemob.com/im/server/basics/chatroom)。

#### 加入聊天室

```dart
try{
  await EMClient.getInstance.roomManager.joinChatRoom(roomId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 离开聊天室

```dart
try{
  await EMClient.getInstance.roomManager.leaveChatRoom(roomId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 销毁聊天室

```dart
try{
  await EMClient.getInstance.roomManager.destroyChatRoom(roomId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>聊天室销毁需要单独拥有权限，具体可以参考文档[聊天室管理](http://docs-im.easemob.com/im/server/basics/chatroom)。

#### 转移聊天室

```dart
try{
  await EMClient.getInstance.roomManager.changeOwner(roomId, newOwner);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>聊天室转移需要单独拥有权限，具体可以参考文档[聊天室管理](http://docs-im.easemob.com/im/server/basics/chatroom)。

#### 获取聊天室详情

```dart
try{
  await EMClient.getInstance.roomManager.fetchChatRoomInfoFromServer(roomId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 获取聊天室成员

```dart
try{
  EMCursorResult result = await EMClient.getInstance.roomManager.fetchChatRoomMembers(roomId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 移除聊天室成员

```dart
try{
  await EMClient.getInstance.roomManager.removeChatRoomMembers(roomId, membersList);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

> 创建者或管理员调用。

#### 添加管理员

```dart
try{
  await EMClient.getInstance.roomManager.addChatRoomAdmin(roomId, memberId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>创建者调用，被操作者会收到回调。

#### 移除管理员

```dart
try{
  await EMClient.getInstance.roomManager.removeChatRoomAdmin(roomId, adminId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>创建者调用，被操作者会收到回调。

#### 获取禁言列表

```dart
try{
  List<String> mutesList = await EMClient.getInstance.roomManager.fetchChatRoomMuteList(roomId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 设置禁言

```dart
try{
  await EMClient.getInstance.roomManager.muteChatRoomMembers(roomId, membersList);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>创建者或者管理员调用。

#### 解除禁言

```dart
try{
  await EMClient.getInstance.roomManager.unMuteChatRoomMembers(roomId, membersList);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>创建者或者管理员调用。

#### 获取黑名单列表

```dart
try{
  List<String> blockList = await EMClient.getInstance.roomManager.fetchChatRoomBlackList(roomId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 添加黑名单

```dart
try{
  List<String> blockList = await EMClient.getInstance.roomManager.blockChatRoomMembers(roomId, membersList);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>创建者或管理员调用。

#### 移除黑名单

```dart
try{
  List<String> blockList = await EMClient.getInstance.roomManager.unBlockChatRoomMembers(roomId, membersList);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>创建者或管理员调用。


#### 修改聊天室标题

```dart
try{
  await EMClient.getInstance.roomManager.changeChatRoomSubject(roomId, subject);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>创建者或管理员调用。

#### 修改聊天室描述

```dart
try{
  await EMClient.getInstance.roomManager.changeChatRoomDescription(roomId, desc);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>创建者或管理员调用。

#### 获取聊天室公告

```dart
try{
  String announcement = await EMClient.getInstance.roomManager.fetchChatRoomAnnouncement(roomId);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 修改聊天室公告

```dart
try{
  await EMClient.getInstance.roomManager.updateChatRoomAnnouncement(roomId, announcement);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>创建者或管理员调用

#### 添加聊天室监听

```dart

class _RoomPageState extends State<RoomPage> implements EMChatRoomEventListener {

  @override
  void initState() {
    super.initState();
    // 添加聊天室监听
    EMClient.getInstance.roomManager.addChatRoomChangeListener(this);
  }
  
  /// id是[roomId],名称是[roomName]的聊天室被销毁
  void onChatRoomDestroyed(String roomId, String roomName) {
  }

  /// 有用户[participant]加入id是[roomId]的聊天室
  void onMemberJoined(String roomId, String participant) {
  }

  /// 有用户[participant]离开id是[roomId]，名字是[roomName]的聊天室
  void onMemberExited(String roomId, String roomName, String participant) {
  }

  /// 用用户[participant]被id是[roomId],名称[roomName]的聊天室删除，删除原因是[reason]
  void onRemovedFromChatRoom(int reason, String roomId, String roomName, String participant) {
  }

  /// id是[roomId]的聊天室禁言列表[mutes]有增加
  void onMuteListAdded(String roomId, List mutes, String expireTime) {
  }

  /// id是[roomId]的聊天室禁言列表[mutes]有减少
  void onMuteListRemoved(String roomId, List mutes) {
  }

  /// id是[roomId]的聊天室增加id是[admin]管理员
  void onAdminAdded(String roomId, String admin) {
  }

  /// id是[roomId]的聊天室移除id是[admin]管理员
  void onAdminRemoved(String roomId, String admin) {
  }

  /// id是[roomId]的聊天室所有者由[oldOwner]变更为[newOwner]
  void onOwnerChanged(String roomId, String newOwner, String oldOwner) {
  }

  /// id是[roomId]的聊天室公告变为[announcement]
  void onAnnouncementChanged(String roomId, String announcement) {
  }

   @override
  void dispose() {
    // 移除聊天室监听
    EMClient.getInstance.roomManager.removeChatRoomListener(this);
    super.dispose();
  }
}

```

### 推送

#### 设置推送昵称

```dart
try{
  String announcement = await EMClient.getInstance.pushManager.updatePushNickname(pushName);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>推送昵称是指当前账号给其他用户发消息，对方不在线，收到推送时显示在推送中的名字，如果没设置，将显示环信id。


#### 从服务器获取推送配置

```dart
try{
  EMImPushConfig pushManager = await EMClient.getInstance.pushManager.getImPushConfigFromServer();
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 从本地缓存获取推送配置

```dart
try{
  EMImPushConfig pushConfig = await EMClient.getInstance.pushManager.getImPushConfig();
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 设置推送显示样式

```dart
try{
  await pushConfig.setPushStyle(EMImPushStyle.Simple);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>`EMImPushStyle`是收推送时样式，目前有两种样式：    
>`Simple`显示“您有一条新消息”;     
>`Summary`显示推送详情;  


#### 设置消息免打扰

```dart
try{
  await pushConfig.setNoDisturb(true, 10, 22);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

>10点到22点之间不接收消息推送。如果是全天不想接收推送，可以设置时间为`0`到`24`。

#### 关闭消息免打扰

```dart
try{
  await pushConfig.setNoDisturb(false);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 设置群组免打扰

```dart
try{
  await pushConfig.setGroupToDisturb(groupId, true);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

#### 获取免打扰群组列表

```dart
try{
  List groupIdsList = await pushConfig.noDisturbGroupsFromServer();
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

