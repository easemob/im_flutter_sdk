import 'dart:core';
import 'package:flutter/services.dart';

import '../tools/em_extension.dart';
import '../../im_flutter_sdk.dart';
import '../internal/chat_method_keys.dart';
import '../internal/em_transform_tools.dart';

///
/// 会话类，表示和一个用户/群组/聊天室的对话，包含发送和接收的消息。
///
/// 以下示例代码展示如何从会话中获取未读消息数：
/// ```dart
///   // The `ConversationId` can be the other party ID, the group ID, or the chat room ID.
///   EMConversation? con = await EMClient.getInstance.chatManager.getConversation(conversationId);
///   int? unreadCount = con?.unreadCount;
/// ```
///
class EMConversation {
  EMConversation._private(this.id, this.type, this._ext, this.isChatThread);

  /// @nodoc
  factory EMConversation.fromJson(Map<String, dynamic> map) {
    Map<String, String>? ext = map.getMapValue("ext")?.cast<String, String>();
    EMConversation ret = EMConversation._private(
      map["con_id"],
      conversationTypeFromInt(map["type"]),
      ext,
      map.getBoolValue("isThread", defaultValue: false)!,
    );

    return ret;
  }

  /// @nodoc
  Map<String, dynamic> _toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["type"] = conversationTypeToInt(this.type);
    data["con_id"] = this.id;
    data["isThread"] = this.isChatThread;
    return data;
  }

  ///
  /// 获取会话 ID。
  ///
  /// 对于单聊类型，会话 ID 同时也是对方用户的名称。
  /// 对于群聊类型，会话 ID 同时也是对方群组的 ID，并不同于群组的名称。
  /// 对于聊天室类型，会话 ID 同时也是聊天室的 ID，并不同于聊天室的名称。
  /// 对于 HelpDesk 类型，会话 ID 与单聊类型相同，是对方用户的名称。
  ///
  /// **Return** 会话 ID。
  ///
  final String id;

  ///
  /// 会话类型。
  ///
  final EMConversationType type;

  ///
  /// 是否为ChatThread会话
  ///
  final bool isChatThread;

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

  ///
  /// 获取会话的最新一条消息。
  ///
  /// 不影响未读数统计。
  ///
  /// 会先从缓存中获取，如果没有则从本地数据库获取后存入缓存。
  ///
  /// **Return** 消息体实例。
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
  /// 获取最近收到的一条消息。
  ///
  /// **Return** 消息体实例。
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
  /// 获取会话的消息未读数。
  ///
  /// **Return** 会话的消息未读数量。
  ///
  /// **Throws**  如果有异常会在此抛出，包含错误码和原因，详见 {@link EMError}。
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
  /// 将消息标为已读。
  ///
  /// Param [messageId] 消息 ID。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
  /// 将所有消息标为已读。
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
  /// 插入一条消息在 SDK 本地数据库，消息的 conversation ID 应该和会话的 conversation ID 一致，消息会根据消息里的时间戳被插入 SDK 本地数据库，并且更新会话的 `latestMessage` 等属性。
  ///
  /// Param [message] 消息体实例。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
  /// 插入一条消息到会话尾部。
  /// 请确保消息的 conversation ID 与要插入的会话的 conversationId 一致，消息会被插入 SDK 本地数据库，并且更新会话的 `latestMessage` 等属性。
  /// Param [message] 消息体实例。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
  /// 更新 SDK 本地数据库的消息。
  /// 不能更新消息 ID，消息更新后，会话的 `latestMessage` 等属性进行相应更新。
  /// Param [message] 要更新的消息。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
  /// 删除会话中的一条消息，同时清除内存和数据库中的消息。
  ///
  /// Param [messageId] 要删除的消息。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
  /// 同时从内存和本地数据库中删除会话中的所有消息。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
  /// 获取指定 ID 的消息。
  ///
  /// 优先从内存中加载，如果内存中没有则从数据库中加载，并将其插入到内存中。
  ///
  /// Param [messageId] 消息 ID。
  ///
  /// **Return** 消息实例。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
  /// 根据消息类型、搜索消息的时间点、搜索结果的最大条数、搜索来源和搜索方向从 SDK 本地数据库中搜索指定数量的消息。
  ///
  /// **Note** 当 maxCount 非常大时，需要考虑内存消耗。
  ///
  /// Param [type] 消息类型，文本、图片、语音等等。
  ///
  /// Param [timestamp] 搜索时间。
  ///
  /// Param [count] 搜索结果的最大条数。
  ///
  /// Param [sender] 搜索来自某人的消息，也可用于搜索群组或聊天室里的消息。
  ///
  /// Param [direction] 消息加载的方向。
  ///
  /// **Return** 消息列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
  ///
  Future<List<EMMessage>> loadMessagesWithMsgType({
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
    req['direction'] = direction == EMSearchDirection.Up ? "up" : "down";
    req.setValueWithOutNull("sender", sender);
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
  /// 从本地数据库加载消息。
  ///
  /// 根据传入的参数从本地数据库加载 startMsgId 之前(存储顺序)指定数量的消息。
  ///
  /// 加载到的 messages 也会加入到当前会话的缓存中，通过 {@link #getAllMessages()} 将会返回所有加载的消息。
  ///
  /// Param [startMsgId] 加载这个 ID 之前的 message，如果传入 "" 或者 null，将从最近的消息开始加载。
  ///
  /// Param [loadCount] 加载的条数。
  ///
  /// Param [direction]  消息的加载方向。
  ///
  /// **Return** 消息列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
  ///
  Future<List<EMMessage>> loadMessages({
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
  /// 根据消息中的关键词、搜索消息的时间点、搜索结果的最大条数、搜索来源和搜索方向从 SDK 本地数据库中搜索指定数量的消息。
  ///
  /// 注意：当 maxCount 非常大时，需要考虑内存消耗。
  ///
  /// Param [keywords] 搜索消息中的关键词。
  ///
  /// Param [sender] 消息发送方（用户、群组或聊天室）。
  ///
  /// Param [timestamp] 搜索消息的时间点。
  ///
  /// Param [count] 搜索结果的最大条数。
  ///
  /// Param [direction] 消息搜索方向。
  ///
  /// **Return** 消息列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
    req['timestamp'] = timestamp;
    req['direction'] = direction == EMSearchDirection.Up ? "up" : "down";
    req.setValueWithOutNull("sender", sender);

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
  /// 加载一个时间段内的消息，不超过最大数量。
  ///
  /// 注意：当 maxCount 非常大时，需要考虑内存消耗。
  ///
  ///  Param [startTime] 搜索的起始时间。
  ///
  ///  Param [endTime] 搜索的结束时间。
  ///
  ///  Param [count] 搜索结果的最大条数。
  ///
  /// **Return** 消息列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
