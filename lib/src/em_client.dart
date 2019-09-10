import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/src/em_sdk_method.dart';

import 'em_chat_manager.dart';
import 'em_domain_terms.dart';

class EMClient {
  static const MethodChannel _channel =
      const MethodChannel('im_flutter_sdk');

  static void init(EMOptions options) {
    _channel.invokeMethod(EMSDKMethod.Init);
  }

  static void login() {
    _channel.invokeMethod(EMSDKMethod.Login);
  }

  static EMChatManager chatManager() {
    _channel.invokeMethod(EMSDKMethod.ChatManager);
  }
}
