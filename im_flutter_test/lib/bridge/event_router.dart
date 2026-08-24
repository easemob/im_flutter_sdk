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
    final event = normalizeNativeEvent(call.method, call.arguments);

    IMWebSocketBridge.instance.sendEvent(
      event['eventType']! as String,
      event['data']! as Map<String, dynamic>,
    );
    return null;
  }

  /// Converts native channel payloads into the stable WebSocket Case contract.
  ///
  /// Platform wrappers intentionally use raw lists for several callbacks. The
  /// test protocol names those lists semantically, so Cases do not depend on
  /// the transport fallback (`data.value`).
  static Map<String, dynamic> normalizeNativeEvent(
    String method,
    dynamic arguments,
  ) {
    var eventType = method;
    var data = _asMap(arguments);

    if (_typedChangeEvents.contains(method) && data['type'] != null) {
      eventType = data.remove('type').toString();
    } else if (arguments is Iterable) {
      final listField = _listFieldByEvent[method];
      if (listField != null) {
        final items = arguments.map(_asMap).toList();
        data = {
          listField: listField == 'messages'
              ? items.map(_canonicalMessage).toList()
              : items,
        };
      }
    } else if ((method == 'onMessageSuccess' || method == 'onMessageError') &&
        data.containsKey('message')) {
      data['msgId'] = data.remove('localId');
      data['msg'] = _canonicalMessage(data.remove('message'));
    }

    return {'eventType': eventType, 'data': data};
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) {
      return value.map(
        (key, dynamic item) => MapEntry(key.toString(), item),
      );
    }
    if (value == null) return <String, dynamic>{};
    return {'value': value};
  }

  static Map<String, dynamic> _canonicalMessage(dynamic value) {
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

  static const Set<String> _typedChangeEvents = {
    'onContactChanged',
    'onGroupChanged',
    'onChatRoomChanged',
  };

  static const Map<String, String> _listFieldByEvent = {
    'onMessagesReceived': 'messages',
    'onMessagesDelivered': 'messages',
    'onMessagesRead': 'messages',
    'onCmdMessagesReceived': 'messages',
    'onStreamMessagesReceived': 'messages',
    'onMessagesRecalled': 'messages',
    'onMessagesRecalledInfo': 'infos',
    'messageReactionDidChange': 'events',
    'onGroupMessageRead': 'acks',
  };
}
