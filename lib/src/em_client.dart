import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk/src/em_sdk_method.dart';

import 'em_chat_manager.dart';
import 'em_domain_terms.dart';

class EMClient {

  static const MethodChannel _emclientChannel = const MethodChannel('em_client');

  EMChatManager _chatManager = new EMChatManager();
  EMContactManager _contactManager = new EMContactManager();

  static EMClient _instance;
  EMClient._internal() {
    // 日志?
  }
  static EMClient getInstance() {
    if (_instance == null) {
      _instance = new EMClient._internal();
    }
    return _instance;
  }

  void init(EMOptions options) {
    _emclientChannel.invokeMethod(EMSDKMethod.Init, {"appkey": options.appKey});
  }

  static void login() {
    _emclientChannel.invokeMethod(EMSDKMethod.Login);
  }

  EMChatManager chatManager() {
    return _chatManager;
  }

  EMContactManager contactManager() {
    return _contactManager;
  }
}
