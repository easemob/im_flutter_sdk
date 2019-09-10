import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/src/em_sdk_method.dart';

import 'em_domain_terms.dart';

class EMChatManager {
  static const MethodChannel _channel =
  const MethodChannel('im_flutter_sdk');



  static void sendMessage(EMMessage message) {
    _channel.invokeMethod(EMSDKMethod.SendMessage);
  }


}