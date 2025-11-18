import 'package:im_flutter_sdk_interface/src/interface/manager_mixin.dart';
import 'package:im_flutter_sdk_interface/src/interface/method_channel/default_channels.dart';

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
}

class ChatManager with ManagerMixin {}

class ContactManager with ManagerMixin {}

class ChatRoomManager with ManagerMixin {}

class GroupManager with ManagerMixin {}

class PushManager with ManagerMixin {}

class UserInfoManager with ManagerMixin {}

class PresenceManager with ManagerMixin {}

class ChatThreadManager with ManagerMixin {}
