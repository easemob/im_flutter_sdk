import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/src/em_sdk_method.dart';

import 'em_chat_manager.dart';
import 'em_domain_terms.dart';

class EMClient {

  static const MethodChannel _channel = const MethodChannel('im_flutter_sdk');

  static EMClient _instance;
  EMClient._internal() {
    // 初始化
  }
  static EMClient getInstance() {
    if (_instance == null) {
      _instance = new EMClient._internal();
    }
    return _instance;
  }

  void init(EMOptions options) {
    _channel.invokeMethod(EMSDKMethod.Init, {"appkey": options.appKey});
  }

  static void login() {
    _channel.invokeMethod(EMSDKMethod.Login);
  }

  static EMChatManager chatManager() {
    _channel.invokeMethod(EMSDKMethod.ChatManager);
  }
}
