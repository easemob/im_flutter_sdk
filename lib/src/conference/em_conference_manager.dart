import 'package:flutter/services.dart';

class EMConferenceManager {

  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _channel = const MethodChannel('$_channelPrefix/em_conference_manager', JSONMethodCodec());


}
