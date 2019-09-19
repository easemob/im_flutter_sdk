import 'package:flutter/services.dart';

import 'em_chat_manager.dart';
import 'em_contact_manager.dart';
import 'em_domain_terms.dart';
import 'em_sdk_method.dart';

class EMClient {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emClientChannel =
      const MethodChannel('$_channelPrefix/em_client');

  final EMChatManager _chatManager = EMChatManager();
  final EMContactManager _contactManager = EMContactManager();

  static EMClient _instance;
  EMClient._internal() {
    //init event channel
    _clientEventChannel.receiveBroadcastStream().listen(_onMigrate2x);
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

  final _loginSuccessCallbacks = List<Success>();
  final _loginErrorCallbacks = List<Error>();
  final _loginProgressCallbacks = List<Progress>();
  final _loginCallbackEventChannel =
      EventChannel('$_channelPrefix/login_callback');

  /// login - login server with username/password.
  void login(final String id, final String password,
      {onSuccess: Success, onError: Error, onProgress: Progress}) {
    // only 1 login callback at once
    _loginSuccessCallbacks.add(onSuccess);
    _loginErrorCallbacks.add(onError);
    _loginProgressCallbacks.add(onProgress);

    _emClientChannel
        .invokeMethod(EMSDKMethod.Login, {id: id, password: password});
  }

  void _onLoginEvent(Object event) {
    if (event == 'success') {
      for (var callback in _loginSuccessCallbacks) {
        callback();
      }
    } else if (event == 'progress') {
      // TODO: get progess/status from event object.
      for (var callback in _loginProgressCallbacks) {
        callback(25, '%25');
      }
    }
  }

  void _onLoginError(Object error) {
    // TODO： get code/status from error object.
    for (var callback in _loginErrorCallbacks) {
      callback(1, 'error');
    }
  }

  EMChatManager chatManager() {
    return _chatManager;
  }

  EMContactManager contactManager() {
    return _contactManager;
  }

  /// Event handler methods.
  void _onMigrate2x(Object event) {
    if (event == 'migrate2x') {
      //TODO: onMigrate2X's variable from event
      for (var callback in _migrate2xCallbacks) {
        callback(true);
      }
    }
  }

  void _onConnectionEvent(Object event) {
    if (event == 'connected') {
      for (var callback in _connectionConnectedCallbacks) {
        callback();
      }
    } else if (event == 'disconnected') {
      // TODO: get error code variable from event
      for (var callback in _connectionDisconnectedCallbacks) {
        callback(1);
      }
    }
  }

  final _migrate2xCallbacks = List<Migrate2x>();
  final _clientEventChannel = EventChannel('$_channelPrefix/client_event');

  /// onMigrate2x - SDK EMClient.addClientListener().
  void onMigrate2x(final Migrate2x callback) {
    _migrate2xCallbacks.add(callback);
  }

  final _connectionConnectedCallbacks = List<Connected>();
  final _connectionDisconnectedCallbacks = List<Disconnected>();
  final _connectionEventChannel =
      EventChannel('$_channelPrefix/connection_event');
}

/// Migrate2x - SDK EMClientListener.onMigrate2x() function.
typedef void Migrate2x(bool success);

/// Connected - SDK EMConnectionListener.onConnected() to react upon connection connected.
typedef void Connected();

/// Disconnected - SDK EMConnectionListener.onDisconnected() to react upon conection disconnected.
typedef void Disconnected(int errorCode);

/// Success - SDK EMCallback.onSuccess() callback.
typedef void Success();

/// Error - SDK EMCallback.onError() callback.
typedef void Error(int code, String error);

/// Progress - SDK EMCallback.onProgress() callback.
typedef void Progress(int progress, String status);
