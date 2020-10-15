import 'package:flutter/services.dart';
import 'em_client.dart';



class EMLog{

  static String TAG = 'EaseMob';

  static bool debuggable = EMClient.getInstance.options.debugModel;

  static void e(Object object, {String tag}) {
    _printLog(tag, ' | E | ', object);
  }

  static void v(Object object, {String tag}) {
    if (debuggable) {
      _printLog(tag, ' | V | ', object);
    }
  }

  static void _printLog(String tag, String stag, Object object) {
    StringBuffer sb = new StringBuffer();
    sb.write((tag == null || tag.isEmpty) ? TAG : tag);
    sb.write(stag);
    sb.write(object);
    print(sb.toString());
  }
}