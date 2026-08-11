import 'package:flutter/services.dart' show rootBundle;
import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';

import '../platform/test_control.dart';

/// 统一的 Manager 路由。Python 只声明 manager/cmd，平台选择由
/// [Client.instance] 的启动注册完成。
class InterfaceRouter {
  const InterfaceRouter();

  /// 测试支撑：用例未传 filePath 的媒体消息，用测试 App 自带素材补默认路径
  /// （assets/media/，经 TestControl.prepareDefaultMediaPath 拷贝到文档目录）。
  Future<void> _fillDefaultMediaPath(Map info) async {
    final body = info['body'];
    if (body is! Map) return;
    final type = body['type'];
    if (type is! int || type < 1 || type > 5 || type == 3) return; // 媒体: image(1)/video(2)/voice(4)/file(5)
    final localPath = body['localPath'];
    if (localPath != null && localPath.toString().isNotEmpty) return;
    final displayName = (body['displayName'] ?? '').toString();
    final String mediaType;
    if (type == 1) {
      mediaType = displayName.toUpperCase().endsWith('.HEIC') ? 'image_heic' : 'image';
    } else if (type == 2) {
      mediaType = 'video';
    } else if (type == 4) {
      mediaType = 'voice';
    } else {
      mediaType = 'file';
    }
    final r = await TestControl.invoke('prepareDefaultMediaPath', {'type': mediaType});
    if (r is String && r.isNotEmpty) {
      body['localPath'] = r;
      // 用例未给 displayName 时用素材文件名（媒体消息需要）
      if (displayName.isEmpty) {
        body['displayName'] = r.split('/').last;
      }
    }
  }

  Future<dynamic> invokeSdkMethod({
    required String manager,
    required String cmd,
    dynamic info,
  }) {
    switch (manager) {
      case 'Client':
        return Client.instance.callNativeMethod(cmd, info);
      case 'ChatManager':
        if (cmd == 'sendMessage' && info is Map) {
          return _fillDefaultMediaPath(info).then(
            (_) => Client.instance.chatManager.callNativeMethod(cmd, info),
          );
        }
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
