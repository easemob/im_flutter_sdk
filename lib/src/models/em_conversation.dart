import 'dart:core';
import 'package:flutter/services.dart';

import '../tools/em_extension.dart';
import '../../im_flutter_sdk.dart';
import '../internal/chat_method_keys.dart';
import '../internal/em_transform_tools.dart';

///
/// The conversation class, indicating a one-to-one chat, a group chat, or a converation chat. It contains the messages that are sent and received within the converation.
///
/// The following code shows how to get the number of the unread messages from the conversation.
/// ```dart
///   // ConversationId can be the other party id, the group id, or the chat room id.
///   EMConversation? con = await EMClient.getInstance.chatManager.getConversation(conversationId);
///   int? unreadCount = con?.unreadCount;
/// ```
///
class EMConversation {
  EMConversation._private(
    this.id,
    this.type,
    this._ext,
  );

  /// @nodoc
  factory EMConversation.fromJson(Map<String, dynamic> map) {
    Map<String, String>? ext = map.getMapValue("ext")?.cast<String, String>();
    EMConversation ret = EMConversation._private(
      map["con_id"],
      conversationTypeFromInt(map["type"]),
      ext,
    );

    return ret;
  }

  /// @nodoc
  Map<String, dynamic> _toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["type"] = conversationTypeToInt(this.type);
    data["con_id"] = this.id;
    return data;
  }

  ///
  /// The conversation ID.
  ///
  /// For one-to-one chat，the conversation ID is the username of the other party.
  /// For group chat, the conversation ID is the group ID, not the group name.
  /// For chat room, the conversation ID is the chat room ID, not the chat room name.
  /// For help desk, the conversation ID is the username of the other party.
  ///
  final String id;

  ///
  /// The conversation type.
  ///
  final EMConversationType type;

  Map<String, String>? _ext;
}

extension EMConversationExtension on EMConversation {
  static const MethodChannel _emConversationChannel =
      const MethodChannel('com.chat.im/chat_conversation', JSONMethodCodec());

  Map<String, String>? get ext => _ext;

  Future<void> setExt(Map<String, String>? ext) async {
    Map req = this._toJson();
    req.setValueWithOutNull("ext", ext);
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.syncConversationExt, req);
    try {
      EMError.hasErrorFromResult(result);
      _ext = ext;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the lastest message from the conversation.
  ///
  /// The operation does not change the unread message count.
  ///
  /// The SDK gets the latest message from the local memory first. If no message is found, the SDK loads the message from the local database and then puts it in the memory.
  ///
  /// **Return** The message instance.
  ///
  Future<EMMessage?> latestMessage() async {
    Map req = this._toJson();
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.getLatestMessage, req);
    try {
      EMError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.getLatestMessage)) {
        return EMMessage.fromJson(result[ChatMethodKeys.getLatestMessage]);
      } else {
        return null;
      }
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the latest message from the conversation.
  ///
  /// **Return** The message instance.
  ///
  Future<EMMessage?> lastReceivedMessage() async {
    Map req = this._toJson();
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.getLatestMessageFromOthers, req);
    try {
      EMError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.getLatestMessageFromOthers)) {
        return EMMessage.fromJson(
            result[ChatMethodKeys.getLatestMessageFromOthers]);
      } else {
        return null;
      }
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the unread message count of the conversation.
  ///
  /// **Return** The unread message count of the conversation.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<int> unreadCount() async {
    Map req = this._toJson();
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.getUnreadMsgCount, req);
    try {
      EMError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.getUnreadMsgCount)) {
        return result[ChatMethodKeys.getUnreadMsgCount];
      } else {
        return 0;
      }
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Marks a message as read.
  ///
  /// Param [messageId] The message ID.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> markMessageAsRead(String messageId) async {
    Map req = this._toJson();
    req['msg_id'] = messageId;
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.markMessageAsRead, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Marks all messages as read.
  ///
  Future<void> markAllMessagesAsRead() async {
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.markAllMessagesAsRead, this._toJson());
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Inserts a message to a conversation in the local database and the SDK will automatically update the lastest message.
  ///
  /// Make sure you set the conversation ID as that of the conversation where you want to insert the message.
  ///
  /// Param [message] The message instance.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> insertMessage(EMMessage message) async {
    Map req = this._toJson();
    req['msg'] = message.toJson();
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.insertMessage, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Inserts a message to the end of a conversation in the local database.
  ///
  /// Make sure you set the conversation ID as that of the conversation where you want to insert the message.
  ///
  /// Param [message] The message instance.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> appendMessage(EMMessage message) async {
    Map req = this._toJson();
    req['msg'] = message.toJson();
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.appendMessage, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Updates a message in the local database.
  ///
  /// The latestMessage of the conversation and other properties will be updated accordingly. The message ID of the message, however, remains the same.
  ///
  /// Param [message] The message to be updated.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> updateMessage(EMMessage message) async {
    Map req = this._toJson();
    req['msg'] = message.toJson();
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.updateConversationMessage, req);
    EMError.hasErrorFromResult(result);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Deletes a message in the local database.
  ///
  /// **Note**
  /// After this method is called, the message is only deleted both from the memory and the local database.
  ///
  /// Param [messageId] The ID of message to be deleted.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> deleteMessage(String messageId) async {
    Map req = this._toJson();
    req['msg_id'] = messageId;
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.removeMessage, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Deletes all the messages of the conversation from both the memory and local database.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> deleteAllMessages() async {
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.clearAllMessages, this._toJson());
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the message with a specific message ID.
  ///
  /// If the message is already loaded into the memory cache, the message will be directly returned; otherwise, the message will be loaded from the local database and loaded in the memory.
  ///
  /// Param [messageId] The message ID.
  ///
  /// **Return** The message instance.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<EMMessage?> loadMessage(String messageId) async {
    Map req = this._toJson();
    req['msg_id'] = messageId;
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.loadMsgWithId, req);
    try {
      EMError.hasErrorFromResult(result);
      if (result[ChatMethodKeys.loadMsgWithId] != null) {
        return EMMessage.fromJson(result[ChatMethodKeys.loadMsgWithId]);
      } else {
        return null;
      }
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Retrieves messages from the database according to the following parameters: the message type, the Unix timestamp, max count, sender.
  ///
  /// **Note**
  /// Be cautious about the memory usage when the maxCount is large.
  ///
  /// Param [type] The message type, including TXT, VOICE, IMAGE, and so on.
  ///
  /// Param [timestamp] The Unix timestamp for the search.
  ///
  /// Param [count] The max number of messages to search.
  ///
  /// Param [sender] The sender of the message. The param can also be used to search in group chat or chat room.
  ///
  /// Param [direction]  The direction in which the message is loaded: EMSearchDirection.
  /// - `EMSearchDirection.Up`: Messages are retrieved in the reverse chronological order of when the server received messages.
  /// - `EMSearchDirection.Down`: Messages are retrieved in the chronological order of when the server received messages.
  ///
  /// **Return** The message list.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<List<EMMessage>?> loadMessagesWithMsgType({
    required MessageType type,
    int timestamp = -1,
    int count = 20,
    String? sender,
    EMSearchDirection direction = EMSearchDirection.Up,
  }) async {
    Map req = this._toJson();
    req['msgType'] = messageTypeToTypeStr(type);
    req['timestamp'] = timestamp;
    req['count'] = count;
    req['sender'] = sender;
    req['direction'] = direction == EMSearchDirection.Up ? "up" : "down";

    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.loadMsgWithMsgType, req);
    try {
      EMError.hasErrorFromResult(result);
      List<EMMessage> list = [];
      result[ChatMethodKeys.loadMsgWithMsgType]?.forEach((element) {
        list.add(EMMessage.fromJson(element));
      });
      return list;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Loads multiple messages from the local database.
  ///
  /// Loads messages from the local database before the specified message.
  ///
  /// The loaded messages will also join the existing messages of the conversation stored in the memory.
  /// The {@link #getAllMessages()} method returns all messages of the conversation loaded in the memory.
  ///
  /// Param [startMsgId] The starting message ID. Message loaded in the memory before this message ID will be loaded. If the `startMsgId` is set as "" or null, the SDK will first load the latest messages in the database.
  ///
  /// Param [loadCount] The number of messages per page.
  ///
  /// Param [direction]  The direction in which the message is loaded: EMSearchDirection.
  /// - `EMSearchDirection.Up`: Messages are retrieved in the reverse chronological order of when the server received messages.
  /// - `EMSearchDirection.Down`: Messages are retrieved in the chronological order of when the server received messages.
  ///
  /// **Return** The message list.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<List<EMMessage>?> loadMessages({
    String startMsgId = '',
    int loadCount = 20,
    EMSearchDirection direction = EMSearchDirection.Up,
  }) async {
    Map req = this._toJson();
    req["startId"] = startMsgId;
    req['count'] = loadCount;
    req['direction'] = direction == EMSearchDirection.Up ? "up" : "down";

    Map<String, dynamic> result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.loadMsgWithStartId, req);

    try {
      EMError.hasErrorFromResult(result);
      List<EMMessage> msgList = [];
      result[ChatMethodKeys.loadMsgWithStartId]?.forEach((element) {
        msgList.add(EMMessage.fromJson(element));
      });
      return msgList;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Loads messages from the local database by the following parameters: keywords, timestamp, max count, sender, search direction.
  ///
  /// **Note** Pay attention to the memory usage when the maxCount is large.
  ///
  /// Param [keywords] The keywords in message.
  ///
  /// Param [sender] The message sender. The param can also be used to search in group chat.
  ///
  /// Param [timestamp] The timestamp for search.
  ///
  /// Param [count] The maximum number of messages to search.
  ///
  /// Param [direction] The direction in which the message is loaded: EMSearchDirection.
  /// `EMSearchDirection.Up`: Gets the messages loaded before the timestamp of the specified message ID.
  /// `EMSearchDirection.Down`: Gets the messages loaded after the timestamp of the specified message ID.
  ///
  /// **Returns** The list of retrieved messages.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<List<EMMessage>> loadMessagesWithKeyword(
    String keywords, {
    String? sender,
    int timestamp = -1,
    int count = 20,
    EMSearchDirection direction = EMSearchDirection.Up,
  }) async {
    Map req = this._toJson();
    req["keywords"] = keywords;
    req['count'] = count;
    if (sender != null) {
      req['sender'] = sender;
    }
    req['timestamp'] = timestamp;
    req['direction'] = direction == EMSearchDirection.Up ? "up" : "down";

    Map<String, dynamic> result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.loadMsgWithKeywords, req);

    try {
      EMError.hasErrorFromResult(result);
      List<EMMessage> msgList = [];
      result[ChatMethodKeys.loadMsgWithKeywords]?.forEach((element) {
        msgList.add(EMMessage.fromJson(element));
      });
      return msgList;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Loads messages from the local database according the following parameters: start timestamp, end timestamp, count.
  ///
  /// **Note** Pay attention to the memory usage when the maxCount is large.
  ///
  ///  Param [startTime] The starting Unix timestamp for search.
  ///
  ///  Param [endTime] The ending Unix timestamp for search.
  ///
  ///  Param [count] The maximum number of message to retrieve.
  ///
  /// **Returns** The list of searched messages.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<List<EMMessage>> loadMessagesFromTime({
    required int startTime,
    required int endTime,
    int count = 20,
  }) async {
    Map req = this._toJson();
    req["startTime"] = startTime;
    req['endTime'] = endTime;
    req['count'] = count;

    Map<String, dynamic> result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.loadMsgWithTime, req);

    try {
      EMError.hasErrorFromResult(result);
      List<EMMessage> msgList = [];
      result[ChatMethodKeys.loadMsgWithTime]?.forEach((element) {
        msgList.add(EMMessage.fromJson(element));
      });
      return msgList;
    } on EMError catch (e) {
      throw e;
    }
  }
}
