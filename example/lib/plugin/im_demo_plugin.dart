
import 'package:flutter/services.dart';

class ImDemoPlugin{
  static const MethodChannel _demoPluginChannel =
  const MethodChannel('com.easemob.demo/plugin',  JSONMethodCodec());

  /// 需要在进入主界面之后去调用，代表已经登录成功，通知native层可执行后续操作
  Future<Null> loginComplete() async {
    String result = await _demoPluginChannel.invokeMethod('loginComplete');
    print(result);
  }
}