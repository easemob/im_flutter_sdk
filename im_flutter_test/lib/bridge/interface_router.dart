import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';

import '../platform/test_control.dart';

/// 统一的 Manager 路由。Python 只声明 manager/cmd，平台选择由
/// [Client.instance] 的启动注册完成。
class InterfaceRouter {
  const InterfaceRouter();

  Future<dynamic> invokeSdkMethod({
    required String manager,
    required String cmd,
    dynamic info,
  }) {
    switch (manager) {
      case 'Client':
        return Client.instance.callNativeMethod(cmd, info);
      case 'ChatManager':
        return Client.instance.chatManager.callNativeMethod(cmd, info);
      case 'ContactManager':
        return Client.instance.contactManager.callNativeMethod(cmd, info);
      case 'GroupManager':
        return Client.instance.groupManager.callNativeMethod(cmd, info);
      case 'ChatRoomManager':
        return Client.instance.chatRoomManager.callNativeMethod(cmd, info);
      case 'PushManager':
        return Client.instance.pushManager.callNativeMethod(cmd, info);
      case 'UserInfoManager':
        return Client.instance.userInfoManager.callNativeMethod(cmd, info);
      case 'PresenceManager':
        return Client.instance.presenceManager.callNativeMethod(cmd, info);
      case 'ChatThreadManager':
        return Client.instance.chatThreadManager.callNativeMethod(cmd, info);
      case 'ConversationManager':
        return Client.instance.conversationManager.callNativeMethod(cmd, info);
      case 'MessageManager':
        return Client.instance.messageManager.callNativeMethod(cmd, info);
      case 'TestControl':
        return TestControl.invoke(cmd, info);
      default:
        throw UnsupportedError('Unsupported manager: $manager');
    }
  }
}
