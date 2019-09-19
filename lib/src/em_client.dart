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

  Future<void> init(EMOptions options) {
    return _emClientChannel
        .invokeMethod<void>(EMSDKMethod.init, {"appkey": options.appKey});
  }

  final _loginSuccessCallbacks = List<Success>();
  final _loginErrorCallbacks = List<Error>();
  final _loginProgressCallbacks = List<Progress>();
  final _loginCallbackEventChannel =
      EventChannel('$_channelPrefix/login_callback');

  /// login - login server with username/password.
  Future<void> login(final String id, final String password,
      {onSuccess: Success, onError: Error, onProgress: Progress}) {
    // only 1 login callback at once
    _loginSuccessCallbacks.add(onSuccess);
    _loginErrorCallbacks.add(onError);
    _loginProgressCallbacks.add(onProgress);

    return _emClientChannel
        .invokeMethod<void>(EMSDKMethod.login, {id: id, password: password});
  }

  Future<void> loginWithToken(String userName, String token,
      {onSuccess: Success, onError: Error, onProgress: Progress}) {
    //TODO: set callback accordingly
    return _emClientChannel.invokeMethod<void>(
        EMSDKMethod.loginWithToken, {userName: userName, token: token});
  }

  Future<void> logout(bool unbindToken,
      {onSuccess: Success, onError: Error, onProgress: Progress}) {
    //TODO: set callback accordingly
    return _emClientChannel
        .invokeMethod<void>(EMSDKMethod.logout, {unbindToken: unbindToken});
  }

  Future<void> changeAppkey(String appKey) {
    return _emClientChannel
        .invokeMethod<void>(EMSDKMethod.changeAppKey, {appKey: appKey});
  }

  Future<String> getCurrentUser() {
    return _emClientChannel.invokeMethod<String>(EMSDKMethod.getCurrentUser);
  }

  Future<void> getUserTokenFromServer(
      final String userName, final String password,
      {onSuccess: Success, onError: Error, onProgress: Progress}) {
    return _emClientChannel.invokeMethod<void>(
        EMSDKMethod.getUserTokenFromServer,
        {userName: userName, password: password});
  }

  Future<void> setDebugMode(bool debugMode) {
    return _emClientChannel
        .invokeMethod<void>(EMSDKMethod.setDebugMode, {debugMode: debugMode});
  }

  Future<bool> updateCurrentUserNick(String nickName) {
    return _emClientChannel.invokeMethod<bool>(
        EMSDKMethod.updateCurrentUserNick, {nickName: nickName});
  }

  void _onLoginEvent(event) {
    if (event.type == 'success') {
      for (var callback in _loginSuccessCallbacks) {
        callback();
      }
    } else if (event.type == 'progress') {
      for (var callback in _loginProgressCallbacks) {
        callback(event.progress, event.status);
      }
    }
  }

  void _onLoginError(error) {
    for (var callback in _loginErrorCallbacks) {
      callback(error.code, error.error);
    }
  }

  EMChatManager chatManager() {
    return _chatManager;
  }

  EMContactManager contactManager() {
    return _contactManager;
  }

  /// Event handler methods.
  void _onMigrate2x(event) {
    if (event.type == 'migrate2x') {
      for (var callback in _migrate2xCallbacks) {
        callback(event.status);
      }
    }
  }

  void _onConnectionEvent(event) {
    if (event.type == 'connected') {
      for (var callback in _connectionConnectedCallbacks) {
        callback();
      }
    } else if (event.type == 'disconnected') {
      for (var callback in _connectionDisconnectedCallbacks) {
        callback(event.errorCode);
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
