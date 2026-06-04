import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';

import '../internal/chat_method_keys.dart';
import '../managers/client.dart';
import '../models/em_chat_enums.dart';
import '../tools/em_log.dart';

/// Default WebSocket server base URL (without query). Used with [topic] to build full URL.
const String kDefaultBridgeWebSocketBaseUrl =
    'ws://140.143.132.6:2000/iov/websocket/dual';

/// Default topic when using [kDefaultBridgeWebSocketBaseUrl].
const String kDefaultBridgeWebSocketTopic = 'adc';

/// Callback for each request/response pair for UI logging.
typedef OnBridgeLog = void Function(String request, String response);

/// WebSocket bridge: im_flutter_sdk connects to the same WebSocket server as cases.
/// Request format: { "manager", "cmd", "info", "id"?, "sequence"? }.
class IMWebSocketBridge {
  IMWebSocketBridge._();

  static final IMWebSocketBridge instance = IMWebSocketBridge._();

  WebSocket? _socket;
  StreamSubscription<dynamic>? _subscription;
  static const String _tag = 'IMWebSocketBridge';

  OnBridgeLog? onLog;

  static bool _isLoginMethod(String? method) {
    return method == ChatMethodKeys.login ||
        method == ChatMethodKeys.loginWithAgoraToken;
  }

  dynamic _getManager(String managerName) {
    switch (managerName) {
      case 'Client':
        return Client.instance;
      case 'ChatManager':
        return Client.instance.chatManager;
      case 'ContactManager':
        return Client.instance.contactManager;
      case 'GroupManager':
        return Client.instance.groupManager;
      case 'ChatRoomManager':
        return Client.instance.chatRoomManager;
      case 'PushManager':
        return Client.instance.pushManager;
      case 'UserInfoManager':
        return Client.instance.userInfoManager;
      case 'PresenceManager':
        return Client.instance.presenceManager;
      case 'ChatThreadManager':
        return Client.instance.chatThreadManager;
      case 'ConversationManager':
        return Client.instance.conversationManager;
      case 'MessageManager':
        return Client.instance.messageManager;
      default:
        return null;
    }
  }

  Future<void> start({String? url, String? topic}) async {
    if (_socket != null) {
      EMLog.v('WebSocket bridge already connected', tag: _tag);
      return;
    }
    final String connectUrl = url ??
        '$kDefaultBridgeWebSocketBaseUrl?topic=${Uri.encodeComponent(topic ?? kDefaultBridgeWebSocketTopic)}';
    final uri = Uri.parse(connectUrl);
    try {
      _socket = await WebSocket.connect(uri.toString());
      EMLog.v('WebSocket bridge connected to $uri', tag: _tag);
      _subscription = _socket!.listen(
        _onMessage,
        onError: (e) => EMLog.e('WebSocket error: $e', tag: _tag),
        onDone: () {
          EMLog.v('WebSocket connection closed', tag: _tag);
          _cleanup();
        },
        cancelOnError: false,
      );
    } catch (e, st) {
      EMLog.e('WebSocket connect failed: $e\n$st', tag: _tag);
      rethrow;
    }
  }

  void _cleanup() {
    _subscription?.cancel();
    _subscription = null;
    _socket = null;
  }

  Future<void> _onMessage(dynamic raw) async {
    final String text = raw is String
        ? raw
        : (raw is List<int> ? utf8.decode(raw) : raw?.toString() ?? '');
    if (text.isEmpty) return;

    final ws = _socket;
    if (ws == null || ws.closeCode != null) return;

    Map<String, dynamic>? request;
    EMLog.v('cmd request: $text', tag: _tag);
    try {
      request = jsonDecode(text) as Map<String, dynamic>?;
    } catch (e) {
      final resp = _errorResponse(null, -1, 'Invalid JSON: $e');
      _send(ws, resp);
      onLog?.call(text, jsonEncode(resp));
      return;
    }

    if (request == null) {
      final resp = _errorResponse(null, -1, 'Empty request');
      _send(ws, resp);
      onLog?.call(text, jsonEncode(resp));
      return;
    }

    final id = request['id'] ?? request['sequence'];
    final managerName = request['manager'] as String?;
    final method = request['cmd'] as String?;
    dynamic args = request['info'];
    if (managerName == null || method == null) {
      final resp = _errorResponse(id, -1, 'Missing manager or cmd');
      EMLog.v('cmd request: ${jsonEncode(resp)}', tag: _tag);
      _send(ws, resp);
      onLog?.call(text, jsonEncode(resp));
      return;
    }

    final manager = _getManager(managerName);
    if (manager == null) {
      final resp = _errorResponse(id, -1, 'Unknown manager: $managerName');
      _send(ws, resp);
      onLog?.call(text, jsonEncode(resp));
      return;
    }

    Map<String, dynamic> response = {};
    try {
      // sendMessageWithType 仅在 Dart 封装 EMMessage 后调 sendMessage，无原生 method，不可走 callNativeMethod
      final dynamic result = (managerName == 'ChatManager' &&
              method == 'sendMessageWithType')
          ? await _invokeSendMessageWithType(args)
          : await manager.callNativeMethod(method, args);
      //返回的result是map格式，key是method，value是结果json字符串，通过websocket发送回去的，可以将reqeust中的info字段去掉，把返回的值放到result属性中
      if (result is Map<String, dynamic>) {
        final String resultFieldKey = (method == 'sendMessageWithType')
            ? ChatMethodKeys.sendMessage
            : method;
        response = _successResponse(request, result, resultFieldKey);
      }
      // 登录成功后触发 startCallback，使 ListenerHandle 中的 contact/group 等回调下发到 Flutter
      if (managerName == 'Client' && _isLoginMethod(method)) {
        try {
          await EMClient.getInstance.startCallback();
        } catch (e, st) {
          EMLog.e('startCallback after login: $e\n$st', tag: _tag);
        }
      }
      EMLog.v('cmd response: ${jsonEncode(response)}', tag: _tag);
      _send(ws, response);
    } catch (e, st) {
      EMLog.e('callNativeMethod error: $e\n$st', tag: _tag);
      response = _errorResponse(id, -1, e.toString());
      _send(ws, response);
    }
    onLog?.call(text, jsonEncode(response));
  }

  /// 与原生 [ChatMethodKeys.sendMessage] 返回结构一致：`{ sendMessage: message.toJson() }`
  Future<Map<String, dynamic>> _invokeSendMessageWithType(dynamic args) async {
    if (args is! Map) {
      throw ArgumentError.value(args, 'info', 'sendMessageWithType requires a Map');
    }
    final map = Map<String, dynamic>.from(args);
    final typeStr = map['type'] as String?;
    final payloadRaw = map['payload'];
    if (typeStr == null || payloadRaw is! Map) {
      throw ArgumentError(
        'sendMessageWithType requires "type" and "payload" (see EMSendMessageType + payload keys)',
      );
    }
    final payload = Map<String, dynamic>.from(payloadRaw);
    final chatTypeTop = map['chatType'];
    if (chatTypeTop != null) {
      payload['chatType'] = chatTypeTop;
    }
    final type = EMSendMessageType.values.byName(typeStr);
    final msg = await EMClient.getInstance.chatManager.sendMessageWithType(
      type,
      payload,
    );
    return {ChatMethodKeys.sendMessage: msg.toJson()};
  }

  static dynamic _toJsonSafe(dynamic value) {
    if (value == null) return null;
    if (value is num || value is bool || value is String) return value;
    if (value is Map) {
      return value.map((k, v) => MapEntry(k?.toString(), _toJsonSafe(v)));
    }
    if (value is List) return value.map(_toJsonSafe).toList();
    return value.toString();
  }

  void _send(WebSocket ws, Map<String, dynamic> payload) {
    if (ws.closeCode != null) {
      EMLog.v('WebSocket closed, payload not sent', tag: _tag);
      return;
    }
    try {
      final encoded = jsonEncode(payload);
      ws.add(encoded);
    } catch (e) {
      EMLog.e('Failed to send payload: $e', tag: _tag);
    }
  }

  Map<String, dynamic> _successResponse(Map<String, dynamic> request,
      Map<String, dynamic> result, String method) {
    final data = Map<String, dynamic>.from(request);
    if (result.containsKey('error')) {
      data['result'] = result['error'];
    } else {
      data['result'] = result[method];
    }
    data.remove('info');
    return data;
  }

  Map<String, dynamic> _errorResponse(
      dynamic id, int code, String description) {
    final map = <String, dynamic>{
      'success': false,
      'error': {'code': code, 'description': description},
    };
    if (id != null) map['id'] = id;
    return map;
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    await _socket?.close();
    _cleanup();
    EMLog.v('WebSocket bridge disconnected', tag: _tag);
  }

  bool get isConnected => _socket != null && _socket!.closeCode == null;

  /// Send event data to WebSocket server (e.g. contact/group events from EventBridgeHandler).
  void sendEvent(String eventType, Map<String, dynamic> data) {
    final ws = _socket;
    if (ws == null || ws.closeCode != null) {
      EMLog.v('WebSocket not connected, event $eventType not sent', tag: _tag);
      return;
    }
    try {
      final payload = {
        'type': 'event',
        'eventType': eventType,
        'data': _toJsonSafe(data),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      _send(ws, payload);
      EMLog.v('Sent payload: ${jsonEncode(payload)}', tag: _tag);
      onLog?.call('Event: $eventType', jsonEncode(payload));
    } catch (e, st) {
      EMLog.e('sendEvent $eventType failed: $e\n$st', tag: _tag);
    }
  }
}
