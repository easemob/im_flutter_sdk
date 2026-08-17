import 'package:flutter/services.dart';
import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';

typedef MethodResponder = Future<dynamic> Function(
  String manager,
  String method,
  dynamic arguments,
);

final class RecordedCall {
  const RecordedCall(this.manager, this.method, this.arguments);

  final String manager;
  final String method;
  final dynamic arguments;
}

final class RecordingClient extends Client {
  RecordingClient(this.responder);

  final MethodResponder responder;
  final List<RecordedCall> calls = <RecordedCall>[];

  late final _RecordingManager _chat = _RecordingManager(this, 'chat');
  late final _RecordingPresenceManager _presence =
      _RecordingPresenceManager(this);
  late final _RecordingManager _conversation =
      _RecordingManager(this, 'conversation');

  @override
  ChatManager get chatManager => _chat;

  @override
  PresenceManager get presenceManager => _presence;

  @override
  ConversationManager get conversationManager => _conversation;

  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) {
    return record('client', method, params);
  }

  Future<dynamic> record(String manager, String method, dynamic params) {
    calls.add(RecordedCall(manager, method, params));
    return responder(manager, method, params);
  }
}

final class _RecordingManager extends ChatManager
    implements ConversationManager {
  _RecordingManager(this.client, this.managerName);

  final RecordingClient client;
  final String managerName;

  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) {
    return client.record(managerName, method, params);
  }

  @override
  void updateNativeHandler(
      Future<dynamic> Function(MethodCall call)? handler) {}
}

final class _RecordingPresenceManager extends PresenceManager {
  _RecordingPresenceManager(this.client);

  final RecordingClient client;

  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) {
    return client.record('presence', method, params);
  }

  @override
  void updateNativeHandler(
      Future<dynamic> Function(MethodCall call)? handler) {}
}
