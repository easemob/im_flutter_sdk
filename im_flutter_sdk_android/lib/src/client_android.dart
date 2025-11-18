import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';

class ClientAndroid extends Client {
  static void registerWith() {
    Client.instance = ClientAndroid();
  }

  ClientAndroid() : super();

  final ChatManager _chatManager = ChatManagerAndroid();
  final ChatRoomManager _chatRoomManager = ChatRoomManagerAndroid();
  final ChatThreadManager _chatThreadManager = ChatThreadManagerAndroid();
  final ContactManager _contactManager = ContactManagerAndroid();
  final GroupManager _groupManager = GroupManagerAndroid();
  final PresenceManager _presenceManager = PresenceManagerAndroid();
  final PushManager _pushManager = PushManagerAndroid();
  final UserInfoManager _userInfoManager = UserInfoManagerAndroid();
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
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return ClientChannel.invokeMethod(method, params);
  }
}

class ChatManagerAndroid extends ChatManager {
  ChatManagerAndroid() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return ChatChannel.invokeMethod(method, params);
  }
}

class ChatRoomManagerAndroid extends ChatRoomManager {
  ChatRoomManagerAndroid() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return ChatRoomChannel.invokeMethod(method, params);
  }
}

class ChatThreadManagerAndroid extends ChatThreadManager {
  ChatThreadManagerAndroid() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return ThreadChannel.invokeMethod(method, params);
  }
}

class ContactManagerAndroid extends ContactManager {
  ContactManagerAndroid() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return ContactChannel.invokeMethod(method, params);
  }
}

class GroupManagerAndroid extends GroupManager {
  GroupManagerAndroid() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return GroupChannel.invokeMethod(method, params);
  }
}

class PresenceManagerAndroid extends PresenceManager {
  PresenceManagerAndroid() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return PresenceChannel.invokeMethod(method, params);
  }
}

class PushManagerAndroid extends PushManager {
  PushManagerAndroid() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return PushChannel.invokeMethod(method, params);
  }
}

class UserInfoManagerAndroid extends UserInfoManager {
  UserInfoManagerAndroid() : super();
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return UserInfoChannel.invokeMethod(method, params);
  }
}
