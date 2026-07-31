import 'package:flutter/services.dart';
import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';

import 'im_websocket_bridge.dart';

/// 将各 interface Channel 的原生 Map/JSON 事件标准化后转发到 WebSocket。
class EventRouter {
  EventRouter._();

  static final EventRouter instance = EventRouter._();

  void registerAllHandlers() {
    Client.instance.updateNativeHandler(_forward);
    Client.instance.chatManager.updateNativeHandler(_forward);
    Client.instance.contactManager.updateNativeHandler(_forward);
    Client.instance.groupManager.updateNativeHandler(_forward);
    Client.instance.chatRoomManager.updateNativeHandler(_forward);
    Client.instance.pushManager.updateNativeHandler(_forward);
    Client.instance.userInfoManager.updateNativeHandler(_forward);
    Client.instance.presenceManager.updateNativeHandler(_forward);
    Client.instance.chatThreadManager.updateNativeHandler(_forward);
    Client.instance.conversationManager.updateNativeHandler(_forward);
    Client.instance.messageManager.updateNativeHandler(_forward);
  }

  void unregisterAllHandlers() {
    Client.instance.updateNativeHandler(null);
    Client.instance.chatManager.updateNativeHandler(null);
    Client.instance.contactManager.updateNativeHandler(null);
    Client.instance.groupManager.updateNativeHandler(null);
    Client.instance.chatRoomManager.updateNativeHandler(null);
    Client.instance.pushManager.updateNativeHandler(null);
    Client.instance.userInfoManager.updateNativeHandler(null);
    Client.instance.presenceManager.updateNativeHandler(null);
    Client.instance.chatThreadManager.updateNativeHandler(null);
    Client.instance.conversationManager.updateNativeHandler(null);
    Client.instance.messageManager.updateNativeHandler(null);
  }

  Future<dynamic> _forward(MethodCall call) async {
    var eventType = call.method;
    var data = _asMap(call.arguments);

    if ((call.method == 'onContactChanged' ||
            call.method == 'onGroupChanged' ||
            call.method == 'chatRoomChange') &&
        data['type'] != null) {
      eventType = data.remove('type').toString();
    } else if (_messageListEvents.contains(call.method) &&
        call.arguments is Iterable) {
      data = {
        'messages': (call.arguments as Iterable)
            .map(_canonicalMessage)
            .toList(),
      };
    } else if (call.method == 'onMessageSuccess' &&
        data.containsKey('message')) {
      data['msgId'] = data.remove('localId');
      data['msg'] = _canonicalMessage(data.remove('message'));
    }

    IMWebSocketBridge.instance.sendEvent(eventType, data);
    return null;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) {
      return value.map(
        (key, dynamic item) => MapEntry(key.toString(), item),
      );
    }
    if (value == null) return <String, dynamic>{};
    return {'value': value};
  }

  Map<String, dynamic> _canonicalMessage(dynamic value) {
    final message = _asMap(value);
    message.putIfAbsent('deliverOnlineOnly', () => false);
    // These native-only diagnostic fields were not part of the existing
    // Python Case contract. Raw events are still retained by the WS transport.
    message.remove('broadcast');
    message.remove('onlineState');
    final body = message['body'];
    if (body is Map) {
      final normalizedBody = _asMap(body);
      if (normalizedBody['targetLanguages'] is Iterable &&
          (normalizedBody['targetLanguages'] as Iterable).isEmpty) {
        normalizedBody.remove('targetLanguages');
      }
      message['body'] = normalizedBody;
    }
    return message;
  }

  static const Set<String> _messageListEvents = {
    'onMessagesReceived',
    'onMessagesDelivered',
    'onMessagesRead',
    'onCmdMessagesReceived',
    'onStreamMessagesReceived',
  };
}
