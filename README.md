## 环信im flutter sdk

文章主要讲解环信im flutter sdk如何使用。

[环信官网](https://www.easemob.com/)

[环信iOS集成文档](http://docs-im.easemob.com/im/ios/sdk/prepare)

[环信Android集成文档](http://docs-im.easemob.com/im/android/sdk/import)

源码地址: [Github](https://github.com/easemob/im_flutter_sdk)  
任何问题可以通过 [Github Issues](https://github.com/easemob/im_flutter_sdk/issues) 提问

[常见问题](FlutterQA.md)

## 前期准备

如果您还没有Appkey，可以前往[环信官网](https://www.easemob.com/)注册[即时通讯云](https://console.easemob.com/user/register)。

进入console -> 添加应用 -> Appkey 获取`Appkey`。

#### 通过pubdev集成

1. 修改 `pubspec.yaml`;
   
   ```dart
   dependencies:
   im_flutter_sdk: ^3.9.0
   ```

2. 执行`flutter pub get`;

3. 导入头文件:

```dart
import 'package:im_flutter_sdk/im_flutter_sdk.dart'
```

#### 通过git集成

1. 修改 `pubspec.yaml`;

```dart
dependencies:
  im_flutter_sdk:  
    git:  
      url: https://github.com/easemob/im_flutter_sdk.git 
      ref: flutter2_stable
```

2. 执行`flutter pub get`;
3. 导入头文件:

```dart
import 'package:im_flutter_sdk/im_flutter_sdk.dart'
```

## SDK讲解

- `EMClient` 用于管理sdk各个模块和一些账号相关的操作，如注册，登录，退出;
- `EMChatManager`用于管理聊天相关操作，如发送消息，接收消息，发送已读回执，获取会话列表等;
- `EMContactManager` 用于管理通讯录相关操作，如获取通讯录列表，添加好友，删除好友等;
- `EMGroupManager`用于群组相关操作，如获取群组列表，加入群组，离开群组等;
- `EMChatRoomManager`用于管理聊天室，如获取聊天室列表;
- `EMPushManager`用于管理推送配置，如设置推送昵称，推送免打扰时间段等;
- `EMUserInfoManager`用于更新自己的用户属性，设置用户属性，获取其他用户的用户属性等;

### EMClient

#### 初始化

```dart
var options = EMOptions(appKey: "easemob-demo#easeim");
await EMClient.getInstance.init(options);
```

> 环信的推送只针对离线设备，如果您的app只是后台且没有被系统挂起，此时客户端的长连接仍然还在，这时消息仍然会直接走收消息的方法，并不会触发推送，这就要求您在收消息时判断App的状态，并实现本地推送。  
> 推送证书申请上传，安卓端请参考文档[第三方推送集成](http://docs-im.easemob.com/im/android/push/thirdpartypush#%E7%AC%AC%E4%B8%89%E6%96%B9%E6%8E%A8%E9%80%81%E9%9B%86%E6%88%90)，iOS请参考文档[APNs推送](http://docs-im.easemob.com/im/ios/apns/deploy)。

#### 注册

```dart
try {
  await EMClient.getInstance.createAccount(username, password);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 客户端注册需要将注册方式设置为`开放注册`，具体说明请参考文档[用户管理](http://docs-im.easemob.com/im/server/ready/user#%E7%94%A8%E6%88%B7%E7%AE%A1%E7%90%86)。

#### 登录

```dart
try {
  await EMClient.getInstance.login(username, password);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 获取当前登录环信id

```dart
String? currentUsername = await EMClient.getInstance.getCurrentUsername();
```

#### 退出

```dart
try {
  await EMClient.getInstance.logout(true);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 退出也有失败的情况，需要确定是否失败。  
> 注册环信id详细说明请参考文档[用户体系集成](http://docs-im.easemob.com/im/server/ready/user)。

#### UI 监听


> 当UI已经准备好后，需要主动调用该方法，调用之后，`EMContactManagerListener`、 `EMGroupEventListener` 、 `EMChatRoomEventListener` 回调才会开始执行。

```dart
EMClient.getInstance.startCallback();
```


#### 监听服务器连接状态

```dart
class _PageState extends State<Page> implements EMConnectionListener {
  @override
  void initState() {
    super.initState();
    EMClient.getInstance.addConnectionListener(this);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void onConnected() {}

  @override
  void onDisconnected(int? errorCode) {}

  @override
  void onTokenDidExpire() {}

  @override
  void onTokenWillExpire() {}

  @override
  void dispose() {
    EMClient.getInstance.removeConnectionListener(this);
    super.dispose();
  }
}
```

#### 获取当前连接状态

```dart
bool isConnected = await EMClient.getInstance.isConnected();
```

### EMChatManager

#### 获取会话列表

```dart
List<EMConversation> conversations = await EMClient.getInstance.chatManager.loadAllConversations();
```

> 会话列表是存在本地的一种消息管理对象，如果您会话中没有消息，则表示会话不存在。

#### 获取会话

```dart
EMConversation? conversation = await EMClient.getInstance.chatManager.getConversation(conversationId);
```

> 获取会话，如果会话目前不存在会创建。

#### 获取会话中的消息

```dart
List<EMMessage>? messages = await conversation.loadMessages();
```

#### 获取会话中未读消息数

```dart
int unreadCount = await conversation.unreadCount();
```

#### 设置单条消息为已读

```dart
await conversation.markMessageAsRead(messageId);
```

#### 设置所有消息为已读

```dart
await conversation.markAllMessagesAsRead();
```

#### 发送消息已读状态

```dart
try {
  await EMClient.getInstance.chatManager.sendMessageReadAck(message);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 删除会话中的消息

```dart
await conversation.deleteAllMessages();
```

#### 插入消息

```dart
await conversation.insertMessage(message);
```

> SDK在您发送和接收消息(_cmd类型消息除外_)后会自动将消息插入数据库中，并不需要您自己将消息插入数据库，但如果您需要自己插入一条消息时可以调用该api。  

#### 更新消息

```dart
await conversation.updateMessage(message);
```

#### 删除消息

```dart
await conversation.deleteMessage(messageId);
```

#### 删除会话

```dart
await EMClient.getInstance.chatManager.deleteConversation(conversationId);
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
try {
  await EMClient.getInstance.chatManager.sendMessage(message);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 监听消息发送状态

```dart
message.setMessageStatusCallBack(MessageStatusCallBack(
  onError: (error) => {},
  onProgress: (progress) => {},
  onSuccess: () => {},
));
```

#### 重发消息

```dart
try {
  await EMClient.getInstance.chatManager.resendMessage(message);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 撤回消息

```dart
try {
  await EMClient.getInstance.chatManager.recallMessage(messageId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 消息撤回为增值服务，您只能撤回2分钟内的消息，如需开通，请[咨询商务](https://www.easemob.com/pricing/im#p08)。

#### 收消息监听

```dart
class _PageState extends State<Page> implements EMChatManagerListener {
  @override
  void initState() {
    super.initState();
    EMClient.getInstance.chatManager.addChatManagerListener(this);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void dispose() {
    EMClient.getInstance.chatManager.removeChatManagerListener(this);
    super.dispose();
  }

  @override
  void onCmdMessagesReceived(List<EMMessage> messages) {}

  @override
  void onConversationRead(String from, String to) {}

  @override
  void onConversationsUpdate() {}

  @override
  void onGroupMessageRead(List<EMGroupMessageAck> groupMessageAcks) {}

  @override
  void onMessagesDelivered(List<EMMessage> messages) {}

  @override
  void onMessagesRead(List<EMMessage> messages) {}

  @override
  void onMessagesRecalled(List<EMMessage> messages) {}

  @override
  void onMessagesReceived(List<EMMessage> messages) {}
}
```

#### 从服务器拉取会话列表

```dart
try {
  List<EMConversation>? conversations = await EMClient.getInstance.chatManager.getConversationsFromServer();
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 会话列表漫游为增值服务，需要单独开通。

#### 从服务器拉取消息

```dart
try {
  EMCursorResult<EMMessage?> result = await EMClient.getInstance.chatManager.fetchHistoryMessages(conversationId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 消息漫游为增值服务，需要单独开通。

### EMContactManager

#### 从服务器获取通讯录中的用户列表

```dart
try {
  List<String> contacts =
      await EMClient.getInstance.contactManager.getAllContactsFromServer();
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 环信收发消息并不需要对方是您通讯录中的成员，只要知道对方的环信id就可以发送消息。

#### 发送添加申请

```dart
try {
  await EMClient.getInstance.contactManager.addContact(userId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 添加申请不会发推送，如果用户不在线，等上线后会收到。

#### 删除通讯录中的成员

```dart
try {
  await EMClient.getInstance.contactManager.deleteContact(userId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 从服务器获取黑名单

```dart
try {
  List<String>blockList = await EMClient.getInstance.contactManager.getBlockListFromServer();
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 添加用户到黑名单中

```dart
try {
  await EMClient.getInstance.contactManager.addUserToBlockList(userId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 黑名单和通讯录是独立的，被添加人不需要在您的通讯录中，如果是通讯录中成员被加入到黑名单后，他仍然会出现在您的通讯录名单中，同时他也会出现在您的黑名单中。被添加到黑名单后，您双方均无法收发对方的消息。

#### 将用户从黑名单中删除

```dart
try {
  await EMClient.getInstance.contactManager.removeUserFromBlockList(userId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 通讯录监听

> 如果想要收到 `EMContactManagerListener` 回调,需要先调用 `EMClient.getInstance.startCallback();` 方法。

```dart
class _PageState extends State<Page> implements EMContactManagerListener {
  @override
  void initState() {
    super.initState();
    EMClient.getInstance.contactManager.addContactListener(this);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void dispose() {
    EMClient.getInstance.contactManager.removeContactListener(this);
    super.dispose();
  }

  @override
  void onContactAdded(String userName) {

  }

  @override
  void onContactDeleted(String? userName) {

  }

  @override
  void onContactInvited(String userName, String? reason) {

  }

  @override
  void onFriendRequestAccepted(String userName) {

  }

  @override
  void onFriendRequestDeclined(String userName) {

  }
}
```

#### 同意添加申请

```dart
try {
  await EMClient.getInstance.contactManager.acceptInvitation(userId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 拒绝添加申请

```dart
try {
  await EMClient.getInstance.contactManager.declineInvitation(userId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

### EMGroupManager

#### 从服务器获取已加入群组列表

```dart
try {
  List<EMGroup> groups = await EMClient.getInstance.groupManager.fetchJoinedGroupsFromServer();
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 从缓存中获取已加入群组列表

```dart
try {
  List<EMGroup> groups = await EMClient.getInstance.groupManager.getJoinedGroups();
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 从服务器获取公开群组列表

```dart
try {
  EMCursorResult<EMGroup> groups = await EMClient.getInstance.groupManager.fetchPublicGroupsFromServer();
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 创建群组

```dart
try {
  EMGroup group = await EMClient.getInstance.groupManager
      .createGroup(options: EMGroupOptions(), groupName: groupName);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> EMGroupOptions可以对群类型`EMGroupStyle`等参数进行设置，群组有四种，分别是:      
> `PrivateOnlyOwnerInvite`私有群，只有群主和管理员能邀请他人进群，被邀请人会收到邀请信息，同意后可入群;    
> `PrivateMemberCanInvite`私有群，所有人都可以邀请他人进群，被邀请人会收到邀请信息，同意后可入群;    
> `PublicJoinNeedApproval`公开群，可以通过获取公开群列表api取的，申请加入时需要群主或管理员同意;    
> `PublicOpenJoin`公开群，可以通过获取公开群列表api取，可以直接进入;    

#### 获取群组详情

```dart
try {
  EMGroup group = await EMClient.getInstance.groupManager.fetchGroupInfoFromServer(groupId)
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 获取群成员列表

```dart
try {
  EMCursorResult<String> result = await EMClient.getInstance.groupManager.fetchMemberListFromServer(groupId)
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 加入公开群组

```dart
try {
  await EMClient.getInstance.groupManager.joinPublicGroup(groupId)
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 需要群组类型是`PublicOpenJoin `,调用后直接加入群组。

#### 申请加入公开群

```dart
try {
  await EMClient.getInstance.groupManager.requestToJoinPublicGroup(groupId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 需要群组类型是`PublicJoinNeedApproval`,申请后，群主和管理员会收到加群邀请，同意后入群。

#### 邀请用户入群

```dart
try {
  await EMClient.getInstance.groupManager.inviterUser(groupId, members);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 需要群组类型是`PrivateOnlyOwnerInvite`或`PrivateMemberCanInvite`,     
> `PrivateOnlyOwnerInvite`时，群主和管理员可以调用`；`     
> `PrivateMemberCanInvite 时，群中任何人都可以调用；    
> 被邀请方会收到邀请通知，同意后进群。邀请通知并不会以推送的形式发出，如果用户不在线，等上线后会收到，用户同意后入群。

```dart
try {
  await EMClient.getInstance.groupManager.addMembers(groupId, members);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 需要群组类型是PublicJoinNeedApproval 或 PublicOpenJoin，
> 
> `PublicJoinNeedApproval`时,被邀请人同意后会进群；

#### 从群组中移除用户

```dart
try {
  await EMClient.getInstance.groupManager.removeMembers(groupId, members);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 群主和管理员可以调用。

#### 添加管理员

```dart
try {
  await EMClient.getInstance.groupManager.addAdmin(groupId, memberId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 群主可以调用。被操作人会收到被添加为管理员回调，该回调无推送，如用户不在线，上线后会收到。

#### 移除管理员

```dart
try {
  await EMClient.getInstance.groupManager.removeAdmin(groupId, memberId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 群主可以调用。被操作人会收到被移除管理员回调，该回调无推送，如用户不在线，上线后会收到。

#### 退出群组

```dart
try {
  await EMClient.getInstance.groupManager.leaveGroup(groupId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 解散群组

```dart
try {
  await EMClient.getInstance.groupManager.destroyGroup(groupId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 只有群主可以调用。

#### 转移群组

```dart
try {
  await EMClient.getInstance.groupManager.changeOwner(groupId, newOwnerId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 只有群主可以调用。

#### 获取群组黑名单列表

```dart
try {
  List<String>? blockList = await EMClient.getInstance.groupManager.fetchBlockListFromServer(groupId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 将群成员添加到群黑名单

```dart
try {
  await EMClient.getInstance.groupManager.blockMembers(groupId, members);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 该方法只有群主和管理员可以调用，被操作用户当前必须是群成员，当用户被加入到群黑名单后，该用户将从群成员中移除并加入到当前群的黑名单中。同时该用户将无法再进入该群。

#### 将用户从黑名单移除

```dart
try {
  await EMClient.getInstance.groupManager.unblockMembers(groupId, members);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 该方法只有群主和管理员可以调用，当账号从黑名单中移除后可以再允许申请加群。

#### 获取群禁言列表

```dart
try {
  List<String>? list = await EMClient.getInstance.groupManager
      .fetchMuteListFromServer(groupId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 对成员禁言

```dart
try {
  await EMClient.getInstance.groupManager.muteMembers(groupId, members);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 该方法只有群主和管理员可以调用，被禁言的用户仍然可以收到群中的消息，但是无法发出消息， 白名单中的用户即使被加入到禁言列表中也不受影响。

#### 对成员解除禁言

```dart
try {
  await EMClient.getInstance.groupManager.unMuteMembers(groupId, members);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 该方法只有群主和管理员可以调用。

#### 对所有成员禁言

```dart
try {
  await EMClient.getInstance.groupManager.muteAllMembers(groupId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 该方法只有群主和管理员可以调用，对群主，管理员，白名单中的成员无效，且针对所有人的`禁言`操作与`muteMembers`、`unMuteMembers`接口不冲突，该接口的操作并不会导致`getGroupMuteListFromServer`接口的返回的数据变化。

#### 对所有成员解除禁言

```dart
try {
  await EMClient.getInstance.groupManager.unMuteAllMembers(groupId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 该方法只有群主和管理员可以调用，且针对所有人的`解除禁言`操作与`muteMembers`、`unMuteMembers`接口不冲突，该接口的操作并不会导致`getGroupMuteListFromServer`接口的返回的数据变化。当调用该方法后，之前在禁言列表中的用户仍在禁言列表中，且仍处于禁言状态。

#### 获取白名单列表

```dart
try {
  List<String>? list = await EMClient.getInstance.groupManager.fetchWhiteListFromServer(groupId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 将用户添加到白名单中

```dart
try {
  await EMClient.getInstance.groupManager.addWhiteList(groupId, members);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 该方法只有群主和管理员可以调用，当用户被加入到白名单后，当群组全部禁言或者被添加到禁言列表后仍可以发言。

#### 将用户从白名单中移除

```dart
try {
  await EMClient.getInstance.groupManager.removeWhiteList(groupId, members);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 该方法只有群主和管理员可以调用。

#### 判断自己是否在白名单中

```dart
try {
  bool inWhiteList = await EMClient.getInstance.groupManager.isMemberInWhiteListFromServer(groupId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 不接收群消息

```dart
try {
  await EMClient.getInstance.groupManager.blockGroup(groupId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 设置后群组中的所有消息都无法收到，用户不在线时也不会有推送告知。

#### 恢复接收群消息

```dart
try {
  await EMClient.getInstance.groupManager.unblockGroup(groupId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 消息免打扰

```dart
try {
  await EMClient.getInstance.pushManager.updatePushServiceForGroup(
      groupIds: groupIds, enablePush: false);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 设置后用户在线时可以正常接收群消息，当用户不在线时，该群组有新消息时不会有推送告知。

#### 更新群名称

```dart
try {
  await EMClient.getInstance.groupManager.changeGroupName(groupId, newName);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 群主或管理员可以调用。

#### 更新群描述

```dart
try {
  await EMClient.getInstance.groupManager.changeGroupDescription(groupId, newDesc);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 群主或管理员可以调用。

#### 获取群组公告

```dart
try {
  String? announcement =await EMClient.getInstance.groupManager.fetchAnnouncementFromServer(groupId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 更新群公告

```dart
try {
  await EMClient.getInstance.groupManager.updateGroupAnnouncement(groupId, newAnnouncement);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 群主或管理员可以调用。

#### 获取群共享文件列表

```dart
try {
  List<EMGroupSharedFile> fileList =await EMClient.getInstance.groupManager.fetchGroupFileListFromServer(groupId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 上传群共享文件

```dart
try {
  await EMClient.getInstance.groupManager.uploadGroupSharedFile(groupId, filePath);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 下载群共享文件

```dart
try {
  await EMClient.getInstance.groupManager.downloadGroupSharedFile(groupId, filePath, savePath);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 删除群共享文件

```dart
try {
  await EMClient.getInstance.groupManager.removeGroupSharedFile(groupId, fileId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 群主，管理员，文件上传者可以调用。

#### 群回调监听

> 如果想要收到 `EMGroupEventListener` 回调,需要先调用 `EMClient.getInstance.startCallback();` 方法。

```dart
class _PageState extends State<Page> implements EMGroupEventListener {
  @override
  void initState() {
    super.initState();
    EMClient.getInstance.groupManager.addGroupChangeListener(this);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void dispose() {
    EMClient.getInstance.groupManager.removeGroupChangeListener(this);
    super.dispose();
  }

  @override
  void onAdminAddedFromGroup(String groupId, String admin) {}

  @override
  void onAdminRemovedFromGroup(String groupId, String admin) {}

  @override
  void onAllGroupMemberMuteStateChanged(String groupId, bool isAllMuted) {}

  @override
  void onAnnouncementChangedFromGroup(String groupId, String announcement) {}

  @override
  void onAutoAcceptInvitationFromGroup(
      String groupId, String inviter, String? inviteMessage) {}

  @override
  void onGroupDestroyed(String groupId, String? groupName) {}

  @override
  void onInvitationAcceptedFromGroup(
      String groupId, String invitee, String? reason) {}

  @override
  void onInvitationDeclinedFromGroup(
      String groupId, String invitee, String? reason) {}

  @override
  void onInvitationReceivedFromGroup(
      String groupId, String? groupName, String inviter, String? reason) {}

  @override
  void onMemberExitedFromGroup(String groupId, String member) {}

  @override
  void onMemberJoinedFromGroup(String groupId, String member) {}

  @override
  void onMuteListAddedFromGroup(
      String groupId, List<String> mutes, int? muteExpire) {}

  @override
  void onMuteListRemovedFromGroup(String groupId, List<String> mutes) {}

  @override
  void onOwnerChangedFromGroup(
      String groupId, String newOwner, String oldOwner) {}

  @override
  void onRequestToJoinAcceptedFromGroup(
      String groupId, String? groupName, String accepter) {}

  @override
  void onRequestToJoinDeclinedFromGroup(
      String groupId, String? groupName, String decliner, String? reason) {}

  @override
  void onRequestToJoinReceivedFromGroup(
      String groupId, String? groupName, String applicant, String? reason) {}

  @override
  void onSharedFileAddedFromGroup(
      String groupId, EMGroupSharedFile sharedFile) {}

  @override
  void onSharedFileDeletedFromGroup(String groupId, String fileId) {}

  @override
  void onUserRemovedFromGroup(String groupId, String? groupName) {}

  @override
  void onWhiteListAddedFromGroup(String groupId, List<String> members) {}

  @override
  void onWhiteListRemovedFromGroup(String groupId, List<String> members) {}
}
```

#### 同意加群申请

```dart
try {
  await EMClient.getInstance.groupManager.acceptJoinApplication(groupId, userId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 群主和管理员可以调用。

#### 拒绝加群申请

```dart
try {
  await EMClient.getInstance.groupManager.declineJoinApplication(groupId, userId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 群主和管理员可以调用。

#### 同意加群邀请

```dart
try {
  await EMClient.getInstance.groupManager.acceptInvitation(groupId, userId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 拒绝加群邀请

```dart
try {
  await EMClient.getInstance.groupManager.declineInvitation(groupId, userId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

### EMChatRoomManager

#### 从服务器获取聊天室列表

```dart
try {
  EMPageResult<EMChatRoom> result = await EMClient.getInstance.chatRoomManager.fetchPublicChatRoomsFromServer();
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 创建聊天室

```dart
try {
  EMChatRoom room = await EMClient.getInstance.chatRoomManager.createChatRoom(subject);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 聊天室创建需要单独拥有权限，具体可以参考文档[聊天室管理](http://docs-im.easemob.com/im/server/basics/chatroom)。

#### 加入聊天室

```dart
try {
  await EMClient.getInstance.chatRoomManager.joinChatRoom(roomId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 离开聊天室

```dart
try {
  await EMClient.getInstance.chatRoomManager.leaveChatRoom(roomId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 销毁聊天室

```dart
try {
  await EMClient.getInstance.chatRoomManager.destroyChatRoom(roomId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 聊天室销毁需要单独拥有权限，具体可以参考文档[聊天室管理](http://docs-im.easemob.com/im/server/basics/chatroom)。

#### 转移聊天室

```dart
try {
  await EMClient.getInstance.chatRoomManager.changeOwner(roomId, newOwnerId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 聊天室转移需要单独拥有权限，具体可以参考文档[聊天室管理](http://docs-im.easemob.com/im/server/basics/chatroom)。

#### 获取聊天室详情

```dart
try {
  EMChatRoom room =await EMClient.getInstance.chatRoomManager.fetchChatRoomInfoFromServer(roomId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 获取聊天室成员

```dart
try {
  EMCursorResult<String> result = await EMClient.getInstance.chatRoomManager.fetchChatRoomMembers(roomId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
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
try {
  await EMClient.getInstance.chatRoomManager.addChatRoomAdmin(roomId, memberId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 创建者调用，被操作者会收到回调。

#### 移除管理员

```dart
try {
  await EMClient.getInstance.chatRoomManager.removeChatRoomAdmin(roomId, AdminId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 创建者调用，被操作者会收到回调。

#### 获取禁言列表

```dart
try {
  List<String>? list =await EMClient.getInstance.chatRoomManager.fetchChatRoomMuteList(roomId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 设置禁言

```dart
try {
  await EMClient.getInstance.chatRoomManager.muteChatRoomMembers(roomId, memberIds);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 创建者或者管理员调用。

#### 解除禁言

```dart
try {
  await EMClient.getInstance.chatRoomManager.unMuteChatRoomMembers(roomId, memberIds);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 创建者或者管理员调用。

#### 获取黑名单列表

```dart
try {
  List<String>? list = await EMClient.getInstance.chatRoomManager.fetchChatRoomBlockList(roomId);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 添加黑名单

```dart
try {
  await EMClient.getInstance.chatRoomManager.blockChatRoomMembers(roomId, memberIds);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 创建者或管理员调用。

#### 移除黑名单

```dart
try {
  await EMClient.getInstance.chatRoomManager.unBlockChatRoomMembers(roomId, memberIds);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 创建者或管理员调用。

#### 修改聊天室标题

```dart
try {
  await EMClient.getInstance.chatRoomManager.changeChatRoomSubject(roomId, newSubject);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 创建者或管理员调用。

#### 修改聊天室描述

```dart
try{
  await EMClient.getInstance.roomManager.changeChatRoomDescription(roomId, desc);
} on EMError catch(e) {
  print('操作失败，原因是: $e');
}
```

> 创建者或管理员调用。

#### 获取聊天室公告

```dart
try {
  await EMClient.getInstance.chatRoomManager.changeChatRoomDescription(omId, newDesc);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 修改聊天室公告

```dart
try {
  await EMClient.getInstance.chatRoomManager.updateChatRoomAnnouncement(chatRoomId, newAnnouncement);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 创建者或管理员调用

#### 添加聊天室监听

> 如果想要收到 `EMChatRoomEventListener` 回调,需要先调用 `EMClient.getInstance.startCallback();` 方法。


```dart
class _PageState extends State<Page> implements EMChatRoomEventListener {
  @override
  void initState() {
    super.initState();
    EMClient.getInstance.chatRoomManager.addChatRoomChangeListener(this);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void dispose() {
    EMClient.getInstance.chatRoomManager.removeChatRoomListener(this);
    super.dispose();
  }

  @override
  void onAdminAddedFromChatRoom(String roomId, String admin) {}

  @override
  void onAdminRemovedFromChatRoom(String roomId, String admin) {}

  @override
  void onAllChatRoomMemberMuteStateChanged(String roomId, bool isAllMuted) {}

  @override
  void onAnnouncementChangedFromChatRoom(String roomId, String announcement) {}

  @override
  void onChatRoomDestroyed(String roomId, String? roomName) {}

  @override
  void onMemberExitedFromChatRoom(
      String roomId, String? roomName, String participant) {}

  @override
  void onMemberJoinedFromChatRoom(String roomId, String participant) {}

  @override
  void onMuteListAddedFromChatRoom(
      String roomId, List<String> mutes, String? expireTime) {}

  @override
  void onMuteListRemovedFromChatRoom(String roomId, List<String> mutes) {}

  @override
  void onOwnerChangedFromChatRoom(
      String roomId, String newOwner, String oldOwner) {}

  @override
  void onRemovedFromChatRoom(
      String roomId, String? roomName, String? participant) {}

  @override
  void onWhiteListAddedFromChatRoom(String roomId, List<String> members) {}

  @override
  void onWhiteListRemovedFromChatRoom(String roomId, List<String> members) {}
}
```

### 推送

#### 设置推送昵称

```dart
try {
  await EMClient.getInstance.pushManager.updatePushNickname(pushDisplayName);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 推送昵称是指当前账号给其他用户发消息，对方不在线，收到推送时显示在推送中的名字，如果没设置，将显示环信id。

#### 从服务器获取推送配置

```dart
try {
  EMPushConfigs configs = await EMClient.getInstance.pushManager.fetchPushConfigsFromServer();
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 从本地缓存获取推送配置

```dart
EMPushConfigs? configs = await EMClient.getInstance.pushManager.getPushConfigsFromCache();
```

#### 设置推送显示样式

```dart
try {
  await EMClient.getInstance.pushManager.updatePushDisplayStyle(DisplayStyle.Simple);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> `DisplayStyle`是收推送时样式，目前有两种样式：    
> `Simple`显示“您有一条新消息”;     
> `Summary`显示推送详情;  

#### 设置消息免打扰

```dart
try {
  await EMClient.getInstance.pushManager.disableOfflinePush(start: 10, end: 22);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

> 10点到22点之间不接收消息推送。如果是全天不想接收推送，可以设置时间为`0`到`24`。

#### 关闭消息免打扰

```dart
try {
  await EMClient.getInstance.pushManager.enableOfflinePush();
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 设置群组免打扰

```dart
try {
  await EMClient.getInstance.pushManager.updatePushServiceForGroup(groupIds: groupIds, enablePush: false);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 获取免打扰群组列表

```dart
List<String> list = await EMClient.getInstance.pushManager.getNoPushGroupsFromCache();
```

#### 设置用户免打扰

```dart
try {
  await EMClient.getInstance.pushManager.updatePushServiceFroUsers(userIds: userIds, enablePush: false);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 获取免打扰用户列表

```dart
List<String> list = await EMClient.getInstance.pushManager.getNoPushUsersFromCache();
```

### EMUserInfoManager

#### 更新自己的用户属性

```dart
String? currentUser = await EMClient.getInstance.getCurrentUsername();
if (currentUser == null) {
  return;
}
try {
  EMUserInfo userInfo = EMUserInfo(currentUser);
  userInfo = userInfo.copyWith(nickName: nickname, avatarUrl: avatarUrl);
  await EMClient.getInstance.userInfoManager.updateOwnUserInfo(userInfo);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```

#### 获取多用户的用户属性

```dart
try {
  Map<String, EMUserInfo> map = await EMClient.getInstance.userInfoManager.fetchUserInfoById(userIds);
} on EMError catch (e) {
  debugPrint("error code: ${e.code}, desc: ${e.description}");
}
```
