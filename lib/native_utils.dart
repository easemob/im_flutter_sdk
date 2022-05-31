import 'package:flutter/services.dart';

const nativeUtilPlugin =
    MethodChannel('com.example/native_plugin');

Future<double> getRandom() async {
  return await nativeUtilPlugin.invokeMethod('getRandom');
}
