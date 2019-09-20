import 'package:flutter/services.dart';

import 'em_domain_terms.dart';
import 'em_log.dart';
import 'em_sdk_method.dart';



class EMChatManager {




  static const MethodChannel _chatManagerChannel =
    const MethodChannel('em_chat_manager');

  EMChatManager({this.log});
  EMLog log;

  void sendMessage(EMMessage message) {
    // todo flutter message to string.
    _chatManagerChannel.invokeMethod(EMSDKMethod.SendMessage);
  }

//  static Function(Message msg, int left) onMessageReceived;
}