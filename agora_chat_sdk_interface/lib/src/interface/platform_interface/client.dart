import 'package:agora_chat_sdk_interface/src/event_handler/channel_manager.dart';
import 'package:agora_chat_sdk_interface/src/interface/manager_mixin.dart';
import 'package:agora_chat_sdk_interface/src/interface/method_channel/default_channels.dart';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class Client extends PlatformInterface with ManagerMixin {
  static final Object _token = Object();
  static Client _instance = ClientDefault();

  Client() : super(token: _token);
  static Client get instance => _instance;
  static set instance(Client instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  ChatManager get chatManager => ChatManager();
  ContactManager get contactManager => ContactManager();
  ChatRoomManager get chatRoomManager => ChatRoomManager();
  GroupManager get groupManager => GroupManager();
  PushManager get pushManager => PushManager();
  UserInfoManager get userInfoManager => UserInfoManager();
  PresenceManager get presenceManager => PresenceManager();
  ChatThreadManager get chatThreadManager => ChatThreadManager();
  ConversationManager get conversationManager => ConversationManager();
  MessageManager get messageManager => MessageManager();

  @override
  void updateNativeHandler(handler) {
    ClientChannel.setMethodCallHandler(handler);
  }
}

class ChatManager with ManagerMixin {
  @override
  void updateNativeHandler(handler) {
    ChatChannel.setMethodCallHandler(handler);
  }
}

class ContactManager with ManagerMixin {
  @override
  void updateNativeHandler(handler) {
    ContactChannel.setMethodCallHandler(handler);
  }
}

class ChatRoomManager with ManagerMixin {
  @override
  void updateNativeHandler(handler) {
    ChatRoomChannel.setMethodCallHandler(handler);
  }
}

class GroupManager with ManagerMixin {
  @override
  void updateNativeHandler(handler) {
    GroupChannel.setMethodCallHandler(handler);
  }
}

class PushManager with ManagerMixin {
  @override
  void updateNativeHandler(handler) {
    PushChannel.setMethodCallHandler(handler);
  }
}

class UserInfoManager with ManagerMixin {
  @override
  void updateNativeHandler(handler) {
    UserInfoChannel.setMethodCallHandler(handler);
  }
}

class PresenceManager with ManagerMixin {
  @override
  void updateNativeHandler(handler) {
    PresenceChannel.setMethodCallHandler(handler);
  }
}

class ChatThreadManager with ManagerMixin {
  @override
  void updateNativeHandler(handler) {
    ThreadChannel.setMethodCallHandler(handler);
  }
}

class ConversationManager with ManagerMixin {
  @override
  void updateNativeHandler(handler) {
    ConversationChannel.setMethodCallHandler(handler);
  }
}

class MessageManager with ManagerMixin {
  @override
  void updateNativeHandler(handler) {
    MessageChannel.setMethodCallHandler(handler);
  }
}
