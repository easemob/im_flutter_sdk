import 'package:flutter/services.dart';

import 'em_chat_manager.dart';
import 'em_contact_manager.dart';
import 'em_domain_terms.dart';
import 'em_sdk_method.dart';

class EMClient {
  static const channelPrefix = 'com.easemob.im';
  static const MethodChannel _emClientChannel =
      const MethodChannel('$channelPrefix/em_client');

  final EMChatManager _chatManager = EMChatManager();
  final EMContactManager _contactManager = EMContactManager();

  static EMClient _instance;
  EMClient._internal() {
    //init event channel
    _clientEventChannel.receiveBroadcastStream().listen(_onClientEvent);
    _connectionEventChannel.receiveBroadcastStream().listen(_onConnectionEvent);
    _loginCallbackEventChannel
        .receiveBroadcastStream()
        .listen(_onLoginEvent, onError: _onLoginError);
  }

  factory EMClient.getInstance() {
    return _instance ?? EMClient._internal();
  }

  void init(EMOptions options) {
    _emClientChannel.invokeMethod(EMSDKMethod.Init, {"appkey": options.appKey});
  }

  final _loginCallback = List<EMCallback>();
  final _loginCallbackEventChannel =
      EventChannel('$channelPrefix/login_callback');

  /// login - login server with username/password.
  void login(
      final String id, final String password, final EMCallback callback) {
    // only 1 login callback at once
    _loginCallback.clear();
    _loginCallback.add(callback);
    _emClientChannel.invokeMethod(EMSDKMethod.Login, {id: id, password: password});
  }

  void _onLoginEvent(Object event) {
    if (event == 'success') {
      _loginCallback.forEach((callback) => callback.onSuccess());
    } else if (event == 'progress') {
      // TODO: get progess/status from event object.
      _loginCallback.forEach((callback) => callback.onProgress(25, '%25'));
    }
  }

  void _onLoginError(Object error) {
    // TODO： get code/status from error object.
    _loginCallback.forEach((callback) => callback.onError(1, 'error'));
  }

  EMChatManager chatManager() {
    return _chatManager;
  }

  EMContactManager contactManager() {
    return _contactManager;
  }

  /// Event handler methods.
  void _onClientEvent(Object event) {
    if (event == 'migrate2x') {
      //TODO: onMigrate2X's variable from event
      _clientListeners.forEach((listener) => listener.onMigrate2x(true));
    }
  }

  void _onConnectionEvent(Object event) {
    if (event == 'connected') {
      _connectionListeners.forEach((listener) => listener.onConnected());
    } else if (event == 'disconnected') {
      // TODO: get error code variable from event
      _connectionListeners.forEach((listener) => listener.onDisconnected(1));
    }
  }

  final _clientListeners = List<EMClientListener>();
  final _clientEventChannel = EventChannel('$channelPrefix/client');

  /// addClientListener - add [EMClientListener] into listners list.
  void addClientListener(final EMClientListener listener) {
    _clientListeners.add(listener);
  }

  /// removeClientListener - remove [EMClientLister] from list.
  void removeClientListener(final EMClientListener listener) {
    var idx = _clientListeners.indexOf(listener);
    if (idx != -1) {
      _clientListeners.removeAt(idx);
    }
  }

  final _connectionListeners = List<EMConnectionListener>();
  final _connectionEventChannel = EventChannel('$channelPrefix/connection');

  /// addConnectionListener - add [EMConnectionListener] into listners list.
  void addConnectionListener(final EMConnectionListener listener) {
    _connectionListeners.add(listener);
  }

  /// removeConnectionListener - remove [EMConnectionLister] from list.
  void removeConnectionListener(final EMConnectionListener listener) {
    var idx = _connectionListeners.indexOf(listener);
    if (idx != -1) {
      _connectionListeners.removeAt(idx);
    }
  }
}

/// EMClientListener - listener receiving client migration events.
abstract class EMClientListener {
  void onMigrate2x(final bool success);
}

/// EMConnectionListener - listener receiving connect/disconnect events.
abstract class EMConnectionListener {
  void onConnected();
  void onDisconnected(final int errorCode);
}

/// EMCallback - callback functions.
abstract class EMCallback {
  void onSuccess();
  void onError(final int code, final String error);
  void onProgress(final int progress, final String status);
}
