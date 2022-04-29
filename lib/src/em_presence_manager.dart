import 'package:flutter/services.dart';
import 'internal/chat_method_keys.dart';
import '../im_flutter_sdk.dart';

class EMPresenceManager {
  static const _channelPrefix = 'com.chat.im';
  static const MethodChannel _channel = const MethodChannel(
      '$_channelPrefix/chat_presence_manager', JSONMethodCodec());

  /// @nodoc
  EMPresenceManager() {
    _channel.setMethodCallHandler((MethodCall call) async {
      Map? argMap = call.arguments;
      if (call.method == ChatMethodKeys.onPresenceStatusChanged) {
        return _presenceChange(argMap!);
      }
      return null;
    });
  }

  Future<void> _presenceChange(Map event) async {
    List? type = event['presences'];
  }
}
