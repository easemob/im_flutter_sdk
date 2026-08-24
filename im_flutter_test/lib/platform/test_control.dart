import 'package:flutter/services.dart';

class TestControl {
  const TestControl._();

  static const MethodChannel _channel = MethodChannel(
    'com.chat.im/test_control',
  );

  static Future<dynamic> invoke(String method, [dynamic arguments]) {
    return _channel.invokeMethod<dynamic>(method, arguments);
  }
}
