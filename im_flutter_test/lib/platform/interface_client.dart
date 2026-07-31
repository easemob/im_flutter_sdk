import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';

/// 测试 Runner 的平台实现。
///
/// 它只把 interface 的 Client/Manager 调用转发到约定的 MethodChannel；
/// 业务 API 的具体实现位于各平台的版本 Adapter/Wrapper。
class InterfaceClient extends Client {
  InterfaceClient._();

  static void registerWith() {
    Client.instance = InterfaceClient._();
  }

  final ChatManager _chatManager = InterfaceChatManager();
  final ContactManager _contactManager = InterfaceContactManager();
  final ChatRoomManager _chatRoomManager = InterfaceChatRoomManager();
  final GroupManager _groupManager = InterfaceGroupManager();
  final PushManager _pushManager = InterfacePushManager();
  final UserInfoManager _userInfoManager = InterfaceUserInfoManager();
  final PresenceManager _presenceManager = InterfacePresenceManager();
  final ChatThreadManager _chatThreadManager = InterfaceChatThreadManager();
  final ConversationManager _conversationManager =
      InterfaceConversationManager();
  final MessageManager _messageManager = InterfaceMessageManager();

  @override
  ChatManager get chatManager => _chatManager;

  @override
  ContactManager get contactManager => _contactManager;

  @override
  ChatRoomManager get chatRoomManager => _chatRoomManager;

  @override
  GroupManager get groupManager => _groupManager;

  @override
  PushManager get pushManager => _pushManager;

  @override
  UserInfoManager get userInfoManager => _userInfoManager;

  @override
  PresenceManager get presenceManager => _presenceManager;

  @override
  ChatThreadManager get chatThreadManager => _chatThreadManager;

  @override
  ConversationManager get conversationManager => _conversationManager;

  @override
  MessageManager get messageManager => _messageManager;

  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) {
    return ClientChannel.invokeMethod<dynamic>(method, params);
  }
}

class InterfaceChatManager extends ChatManager {
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) {
    return ChatChannel.invokeMethod<dynamic>(method, params);
  }
}

class InterfaceContactManager extends ContactManager {
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) {
    return ContactChannel.invokeMethod<dynamic>(method, params);
  }
}

class InterfaceChatRoomManager extends ChatRoomManager {
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) {
    return ChatRoomChannel.invokeMethod<dynamic>(method, params);
  }
}

class InterfaceGroupManager extends GroupManager {
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) {
    return GroupChannel.invokeMethod<dynamic>(method, params);
  }
}

class InterfacePushManager extends PushManager {
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) {
    return PushChannel.invokeMethod<dynamic>(method, params);
  }
}

class InterfaceUserInfoManager extends UserInfoManager {
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) {
    return UserInfoChannel.invokeMethod<dynamic>(method, params);
  }
}

class InterfacePresenceManager extends PresenceManager {
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) {
    return PresenceChannel.invokeMethod<dynamic>(method, params);
  }
}

class InterfaceChatThreadManager extends ChatThreadManager {
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) {
    return ThreadChannel.invokeMethod<dynamic>(method, params);
  }
}

class InterfaceConversationManager extends ConversationManager {
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) {
    return ConversationChannel.invokeMethod<dynamic>(method, params);
  }
}

class InterfaceMessageManager extends MessageManager {
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) {
    return MessageChannel.invokeMethod<dynamic>(method, params);
  }
}
