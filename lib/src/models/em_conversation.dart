import 'dart:core';
import 'package:flutter/services.dart';

import '../tools/em_extension.dart';
import '../../im_flutter_sdk.dart';
import '../internal/chat_method_keys.dart';
import '../internal/em_transform_tools.dart';

///
/// The conversation class, which represents a conversation with a user/group/chat room and contains the messages that are sent and received.
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
    Map<String, String>? ext = map['ext']?.cast<String, String>();
    EMConversation ret = EMConversation._private(
      map.getValueWithOutNull<String>("con_id", ""),
      conversationTypeFromInt(map['type']),
      ext,
    );

    return ret;
  }

  /// @nodoc
  Map<String, dynamic> _toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = conversationTypeToInt(this.type);
    data['con_id'] = this.id;
    return data;
  }

  ///
  /// The conversation ID.
  ///
  /// For one-to-one chat，the conversation ID is the same with the other side's name.
  /// For group chat, the conversation ID is the group ID, different with group name.
  /// For chat room, the conversation ID is the chatroom ID, different with chat room name.
  /// For help desk, it is the same with one-to-one chat, the conversation ID is also the other chat user's name.
  ///
  /// The conversation ID.
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
  /// Gets the last message from the conversation.
  ///
  /// The operation does not change the unread message count.
  ///
  /// Gets from the cache first, if no message is found, loads from the local database and then put it in the cache.
  ///
  /// **return** The message instance.
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
  /// **return** The message instance.
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
  /// Gets the number of unread messages of the conversation.
  ///
  /// **return** The unread message count of the conversation.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
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
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
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
  /// Inserts a message to a conversation in local database and SDK will update the last message automatically.
  ///
  /// The conversation ID of the message should be the same as conversation ID of the conversation in order to insert the message into the conversation correctly. The inserting message will be inserted based on timestamp.
  ///
  /// Param [message] The message instance.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
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
  /// The `conversationId` of the message should be the same as the `conversationId` of the conversation in order to insert the message into the conversation correctly. And the `latestMessage` and other properties of the session should be updated.
  ///
  /// Param [message] The message instance.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
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
  /// Uses this method to update a message in local database. Changing properties will affect data in database.
  ///
  /// The latestMessage of the conversation and other properties will be updated accordingly. The messageID of the message cannot be updated.
  ///
  /// Param [message] The message to be updated.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
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
  /// Note: Operates only on the local database.
  ///
  /// Param [messageId] The message id to be deleted.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
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
  /// Deletes all the messages of the conversation from the memory cache and local database.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
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
  /// Gets the message with message ID.
  ///
  /// If the message already loaded into the memory cache, the message will be directly returned,
  /// otherwise the message will be loaded from the local database, and be set into the cache.
  ///
  /// Param [messageId] The message ID.
  ///
  /// **return** The message instance.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
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
  /// Searches messages from the local database according the following parameters: the message type, the Unix timestamp, max count, sender.
  ///
  /// Note:
  /// Be cautious about the memory usage when the maxCount is large.
  ///
  /// Param [type] The message type, including TXT、VOICE、IMAGE and so on.
  ///
  /// Param [timestamp] The Unix timestamp for search.
  ///
  /// Param [count] The max number of message to search.
  ///
  /// Param [sender] The sender of the message. The param can also be used to search in group chat.
  ///
  /// Param [direction]  The direction in which the message is loaded: EMSearchDirection.
  /// `EMSearchDirection.Up`: get aCount of messages before the timestamp of the specified message ID;
  /// `EMSearchDirection.Down`: get aCount of messages after the timestamp of the specified message ID.
  ///
  /// **return** The message list.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<List<EMMessage>?> loadMessagesWithMsgType({
    required MessageType type,
    int timestamp = -1,
    int count = 20,
    String? sender,
    EMSearchDirection direction = EMSearchDirection.Up,
  }) async {
    Map req = this._toJson();
    req['type'] = messageTypeToTypeStr(type);
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
  /// Loads more messages from the local database.
  ///
  /// Loads messages from the local database before the specified message.
  ///
  /// The messages will also be stored in to current conversation's memory cache.
  /// So when next time calling {@link #getAllMessages()}, the result will contain those messages.
  ///
  /// Param [startMsgId] The specified message ID. If the `startMsgId` is set as "" or null, the SDK will load latest messages in database.
  ///
  /// Param [loadCount] The number of records in a page.
  ///
  /// Param [direction]  The direction in which the message is loaded: EMSearchDirection.
  /// `EMSearchDirection.Up`: get aCount of messages before the timestamp of the specified message ID;
  /// `EMSearchDirection.Down`: get aCount of messages after the timestamp of the specified message ID.
  ///
  /// **return** The message list.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
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
  /// Searches messages from the local database by the following parameters: keywords, timestamp, max count, sender, search direction.
  ///
  /// Note: Be cautious about memory usage when the maxCount is large.
  ///
  /// Param [keywords] The keywords in message.
  ///
  /// Param [sender] The message sender. The param can also be used to search in group chat.
  ///
  /// Param [timestamp] The timestamp for search.
  ///
  /// Param [count] The max number of message to search.
  ///
  /// Param [direction] The direction in which the message is loaded: EMSearchDirection.
  /// `EMSearchDirection.Up`: get aCount of messages before the timestamp of the specified message ID;
  /// `EMSearchDirection.Down`: get aCount of messages after the timestamp of the specified message ID.
  ///
  /// **returns** The list of searched messages.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
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
  /// Searches messages from the local database according the following parameters.
  ///
  /// Note: Be cautious about the memory usage when the maxCount is large.
  ///
  ///  Param [startTime] The start Unix timestamp to search.
  ///
  ///  Param [endTime] The end Unix timestamp to search.
  ///
  ///  Param [count] The max number of message to search.
  ///
  /// **returns** The list of searched messages.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
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
