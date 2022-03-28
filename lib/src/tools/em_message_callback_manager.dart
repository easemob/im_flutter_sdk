import 'package:flutter/services.dart';
import '../internal/em_message_state_handle.dart';

import '../internal/chat_method_keys.dart';

class MessageCallBackManager {
  static const _channelPrefix = 'com.chat.im';
  static const MethodChannel _emMessageChannel =
      const MethodChannel('$_channelPrefix/chat_message', JSONMethodCodec());
  Map<String, EMMessageStateHandle> cacheHandleMap = {};
  static MessageCallBackManager? _instance;
  static MessageCallBackManager get getInstance =>
      _instance = _instance ?? MessageCallBackManager._internal();

  MessageCallBackManager._internal() {
    _emMessageChannel.setMethodCallHandler((MethodCall call) async {
      Map<String, dynamic> argMap = call.arguments;
      int? localTime = argMap['localTime'];
      EMMessageStateHandle? handle = cacheHandleMap[localTime.toString()];

      if (call.method == ChatMethodKeys.onMessageProgressUpdate) {
        return handle?.onMessageProgressChanged?.call(argMap);
      } else if (call.method == ChatMethodKeys.onMessageError) {
        return handle?.onMessageError?.call(argMap);
      } else if (call.method == ChatMethodKeys.onMessageSuccess) {
        return handle?.onMessageSuccess?.call(argMap);
      } else if (call.method == ChatMethodKeys.onMessageReadAck) {
        return handle?.onMessageReadAck?.call(argMap);
      } else if (call.method == ChatMethodKeys.onMessageDeliveryAck) {
        return handle?.onMessageDeliveryAck?.call(argMap);
      } else if (call.method == ChatMethodKeys.onMessageStatusChanged) {
        return handle?.onMessageStatusChanged?.call(argMap);
      }
      return null;
    });
  }

  addMessage(String key, EMMessageStateHandle message) {
    cacheHandleMap[key] = message;
  }

  removeMessage(String key) {
    cacheHandleMap.remove(key);
  }
}
