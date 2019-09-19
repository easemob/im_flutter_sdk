import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/src/em_sdk_method.dart';

import 'em_domain_terms.dart';

class EMChatManager {
  static const MethodChannel _chatManagerChannel =
    const MethodChannel('em_chat_manager');


  void sendMessage(EMMessage message) {
    // todo flutter message to string.
    _chatManagerChannel.invokeMethod(EMSDKMethod.SendMessage);
  }

//  static Function(Message msg, int left) onMessageReceived;
}