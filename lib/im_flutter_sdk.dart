import 'dart:async';

import 'package:flutter/services.dart';

class ImFlutterSdk {
  static const MethodChannel _channel =
      const MethodChannel('im_flutter_sdk');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
