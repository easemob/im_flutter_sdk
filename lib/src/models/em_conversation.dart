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
  Map<String, dynamic> toJson() {
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
    Map req = this.toJson();
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

  Future<EMMessage?> latestMessage() async {
    Map req = this.toJson();
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

  Future<EMMessage?> lastReceivedMessageMessage() async {
    Map req = this.toJson();
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

  Future<int> unreadCount() async {
    Map req = this.toJson();
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

  /// 根据消息id设置消息已读，如果消息不属于当前会话则设置无效
  Future<void> markMessageAsRead(String messageId) async {
    Map req = this.toJson();
    req['msg_id'] = messageId;
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.markMessageAsRead, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 设置当前会话中所有消息为已读
  Future<void> markAllMessagesAsRead() async {
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.markAllMessagesAsRead, this.toJson());
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 插入消息，插入的消息会根据消息时间插入到对应的位置
  Future<void> insertMessage(EMMessage message) async {
    Map req = this.toJson();
    req['msg'] = message.toJson();
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.insertMessage, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 添加消息，添加的消息会添加到最后一条消息的位置
  Future<void> appendMessage(EMMessage message) async {
    Map req = this.toJson();
    req['msg'] = message.toJson();
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.appendMessage, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 更新消息
  Future<void> updateMessage(EMMessage message) async {
    Map req = this.toJson();
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

  /// 根据消息id [messageId] 删除消息
  Future<void> deleteMessage(String messageId) async {
    Map req = this.toJson();
    req['msg_id'] = messageId;
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.removeMessage, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  // 删除当前会话中所有消息
  Future<void> deleteAllMessages() async {
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.clearAllMessages, this.toJson());
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 根据消息id获取消息，如果消息id不属于当前会话，则无法获取到
  Future<EMMessage?> loadMessage(String messageId) async {
    Map req = this.toJson();
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

  /// 根据类型获取当前会话汇总的消息
  Future<List<EMMessage>?> loadMessagesWithMsgType({
    required MessageType type,
    int timestamp = -1,
    int count = 20,
    String? sender,
    EMSearchDirection direction = EMSearchDirection.Up,
  }) async {
    Map req = this.toJson();
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

  /// 根据起始消息id获取消息
  Future<List<EMMessage>?> loadMessages({
    String startMsgId = '',
    int loadCount = 20,
    EMSearchDirection direction = EMSearchDirection.Up,
  }) async {
    Map req = this.toJson();
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

  Future<List<EMMessage>> loadMessagesWithKeyword(
    String keywords, {
    String? sender,
    int timestamp = -1,
    int count = 20,
    EMSearchDirection direction = EMSearchDirection.Up,
  }) async {
    Map req = this.toJson();
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

  Future<List<EMMessage>> loadMessagesFromTime({
    required int startTime,
    required int endTime,
    int count = 20,
  }) async {
    Map req = this.toJson();
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
