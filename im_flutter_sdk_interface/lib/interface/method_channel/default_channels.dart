import 'package:im_flutter_sdk_interface/interface/platform_interface/chat_manager.dart';
import 'package:im_flutter_sdk_interface/interface/platform_interface/chat_room_manager.dart';
import 'package:im_flutter_sdk_interface/interface/platform_interface/chat_thread_manager.dart';
import 'package:im_flutter_sdk_interface/interface/platform_interface/contact_manager.dart';
import 'package:im_flutter_sdk_interface/interface/platform_interface/group_manager.dart';
import 'package:im_flutter_sdk_interface/interface/platform_interface/presence_manager.dart';
import 'package:im_flutter_sdk_interface/interface/platform_interface/push_manager.dart';
import 'package:im_flutter_sdk_interface/interface/platform_interface/user_info_manager.dart';

import '../platform_interface/client.dart';
import '../platform_interface/progress_manager.dart';

class ClientDefault extends Client {
  @override
  void initHandler() {}
}

class ChatManagerDefault extends ChatManager {}

class ChatRoomManagerDefault extends ChatRoomManager {}

class ChatThreadManagerDefault extends ChatThreadManager {}

class ContactManagerDefault extends ContactManager {}

class GroupManagerDefault extends GroupManager {}

class PresenceManagerDefault extends PresenceManager {}

class PushManagerDefault extends PushManager {}

class UserInfoManagerDefault extends UserInfoManager {}

class ProgressManagerDefault extends ProgressManager {}
