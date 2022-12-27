/// @nodoc
import 'package:flutter/services.dart';

const channelPrefix = 'com.chat.im';

const MethodChannel ChatChannel = const MethodChannel(
  '$channelPrefix/chat_manager',
  JSONMethodCodec(),
);

const MethodChannel ProgressChannel = const MethodChannel(
  "$channelPrefix/file_progress_manager",
  JSONMethodCodec(),
);

const MethodChannel ClientChannel = const MethodChannel(
  '$channelPrefix/chat_client',
  JSONMethodCodec(),
);

const MethodChannel PushChannel = const MethodChannel(
  '$channelPrefix/chat_push_manager',
  JSONMethodCodec(),
);
