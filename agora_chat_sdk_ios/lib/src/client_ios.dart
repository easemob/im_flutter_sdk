import 'package:agora_chat_sdk_interface/agora_chat_sdk_interface.dart';

class ClientIOS extends Client {
  static void registerWith() {
    Client.instance = ClientIOS();
  }

  ClientIOS() : super();

  final ChatManager _chatManager = ChatManagerIOS();
  final ChatRoomManager _chatRoomManager = ChatRoomManagerIOS();
  final ChatThreadManager _chatThreadManager = ChatThreadManagerIOS();
  final ContactManager _contactManager = ContactManagerIOS();
  final GroupManager _groupManager = GroupManagerIOS();
  final PresenceManager _presenceManager = PresenceManagerIOS();
  final PushManager _pushManager = PushManagerIOS();
  final UserInfoManager _userInfoManager = UserInfoManagerIOS();
  final ConversationManager _conversationManager = ConversationManagerIOS();
  final MessageManager _messageManager = MessageManagerIOS();
  // ignore: unused_field
  ProgressManager? _progressManager;

  @override
  ChatManager get chatManager => _chatManager;

  @override
  ChatRoomManager get chatRoomManager => _chatRoomManager;

  @override
  ChatThreadManager get chatThreadManager => _chatThreadManager;

  @override
  ContactManager get contactManager => _contactManager;

  @override
  GroupManager get groupManager => _groupManager;

  @override
  PresenceManager get presenceManager => _presenceManager;

  @override
  PushManager get pushManager => _pushManager;

  @override
  UserInfoManager get userInfoManager => _userInfoManager;

  @override
  ConversationManager get conversationManager => _conversationManager;

  @override
  MessageManager get messageManager => _messageManager;

  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return ClientChannel.invokeMethod(method, params);
  }
}

class ChatManagerIOS extends ChatManager {
  ChatManagerIOS() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return ChatChannel.invokeMethod(method, params);
  }
}

class ChatRoomManagerIOS extends ChatRoomManager {
  ChatRoomManagerIOS() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return ChatRoomChannel.invokeMethod(method, params);
  }
}

class ChatThreadManagerIOS extends ChatThreadManager {
  ChatThreadManagerIOS() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return ThreadChannel.invokeMethod(method, params);
  }
}

class ContactManagerIOS extends ContactManager {
  ContactManagerIOS() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return ContactChannel.invokeMethod(method, params);
  }
}

class GroupManagerIOS extends GroupManager {
  GroupManagerIOS() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return GroupChannel.invokeMethod(method, params);
  }
}

class PresenceManagerIOS extends PresenceManager {
  PresenceManagerIOS() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return PresenceChannel.invokeMethod(method, params);
  }
}

class PushManagerIOS extends PushManager {
  PushManagerIOS() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return PushChannel.invokeMethod(method, params);
  }
}

class UserInfoManagerIOS extends UserInfoManager {
  UserInfoManagerIOS() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return UserInfoChannel.invokeMethod(method, params);
  }
}

class ConversationManagerIOS extends ConversationManager {
  ConversationManagerIOS() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return ConversationChannel.invokeMethod(method, params);
  }
}

class MessageManagerIOS extends MessageManager {
  MessageManagerIOS() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return MessageChannel.invokeMethod(method, params);
  }
}
