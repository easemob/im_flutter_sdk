// ignore_for_file: constant_identifier_names

import 'package:flutter/services.dart';

const channelPrefix = 'com.chat.im';

const MethodChannel ChatChannel = MethodChannel(
  '$channelPrefix/chat_manager',
  JSONMethodCodec(),
);

const MethodChannel ChatRoomChannel = MethodChannel(
  '$channelPrefix/chat_room_manager',
  JSONMethodCodec(),
);

const MethodChannel ThreadChannel = MethodChannel(
  '$channelPrefix/chat_thread_manager',
  JSONMethodCodec(),
);

const MethodChannel ContactChannel = MethodChannel(
  '$channelPrefix/chat_contact_manager',
  JSONMethodCodec(),
);

const MethodChannel GroupChannel = MethodChannel(
  '$channelPrefix/chat_group_manager',
  JSONMethodCodec(),
);

const MethodChannel PresenceChannel = MethodChannel(
  '$channelPrefix/chat_presence_manager',
  JSONMethodCodec(),
);

const MethodChannel ProgressChannel = MethodChannel(
  "$channelPrefix/file_progress_manager",
  JSONMethodCodec(),
);

const MethodChannel ClientChannel = MethodChannel(
  '$channelPrefix/chat_client',
  JSONMethodCodec(),
);

const MethodChannel PushChannel = MethodChannel(
  '$channelPrefix/chat_push_manager',
  JSONMethodCodec(),
);

const MethodChannel UserInfoChannel = MethodChannel(
  '$channelPrefix/chat_userInfo_manager',
  JSONMethodCodec(),
);

const MethodChannel ConversationChannel = MethodChannel(
  '$channelPrefix/chat_conversation',
  JSONMethodCodec(),
);

const MethodChannel MessageChannel = MethodChannel(
  '$channelPrefix/chat_message',
  JSONMethodCodec(),
);
