import 'package:flutter/services.dart';

class EMLog{

  static const MethodChannel _emLogChannel =
  const MethodChannel('com.easemob.im/em_log');

  EMLog(){
    _addNativeMethodCallHandler();
  }

  static void _addNativeMethodCallHandler() {
    _emLogChannel.setMethodCallHandler((MethodCall call){
      Map argMap = call.arguments;
      String log = argMap["log"];
      switch (call.method) {
        case 'debugLog':
          print("Debug: $log");
          break;
        case 'errorLog':
          print("Error: $log");
          break;
      }
      return;
    });
  }

}