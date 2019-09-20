import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'dart:async';

import 'em_chat_manager.dart';
import 'em_contact_manager.dart';
import 'em_domain_terms.dart';
import 'em_log.dart';
import 'em_listeners.dart';
import 'em_sdk_method.dart';



class EMClient {

  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emClientChannel =
  const MethodChannel('$_channelPrefix/em_client');


  static final EMLog _log = EMLog();
  final EMChatManager _chatManager = EMChatManager(log: _log);
  final EMContactManager _contactManager = EMContactManager(log: _log);

  final _connectionListenerList = List<EMConnectionListener>();
  static EMClient get instance => getInstance();
  static EMClient _instance;

  factory EMClient() => getInstance();

  EMClient._internal() {
    // 初始化
    _addNativeMethodCallHandler();
  }

  static EMClient getInstance() {
    if (_instance == null) {
      _instance = new EMClient._internal();
    }
    return _instance;
  }

  void init(EMOptions options) {
    _emClientChannel.invokeMethod(EMSDKMethod.init, {"appkey": options.appKey});
  }

  void _addNativeMethodCallHandler() {
    _emClientChannel.setMethodCallHandler((MethodCall call) {
      Map argMap = call.arguments;
      if(call.method == EMSDKMethod.onConnectionDidChanged) {
        _onConnectionChanged(argMap);
      }
      return;
    });
  }

  /// login - login server with username/password.
  void login(
      {@required String username, @required String password, onSuccess(), onError(
          int errorCode, String desc)}) {
    Future<String> result = _emClientChannel.invokeMethod(EMSDKMethod.login,
        {'username': username, 'password': password});
    result.then((response) {
      if (response == '') {
        if (onSuccess != null) onSuccess();
      } else {
        if (onError != null) onError(int.parse(response), "error");
      }
    });
  }

  /// add listeners
  void addConnectionListener(EMConnectionListener listener) {
    _connectionListenerList.add(listener);
  }

  void removeConnectionListener(EMConnectionListener listener) {
    _connectionListenerList.remove(listener);
  }

  /// private
  void _onConnectionChanged(Map map){
    bool isConnected = map["isConnected"];
    for (var listener in _connectionListenerList) {
      if (isConnected) {
        listener.onConnected();
      }else {
        listener.onDisconnected();
      }
    }
  }


  /// get - get instances
  EMChatManager chatManager() {
    return _chatManager;
  }

  EMContactManager contactManager() {
    return _contactManager;
  }
}