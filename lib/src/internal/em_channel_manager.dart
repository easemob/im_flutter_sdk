import 'package:flutter/services.dart';

class EMMethodChannel {
  static const channelPrefix = 'com.chat.im';

  static const MethodChannel ChatManager =
      const MethodChannel('$channelPrefix/chat_manager', JSONMethodCodec());
}
