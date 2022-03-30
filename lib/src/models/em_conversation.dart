import 'dart:core';
import 'package:flutter/services.dart';

import '../tools/em_extension.dart';
import '../../im_flutter_sdk.dart';
import '../internal/chat_method_keys.dart';
import '../internal/em_enum_transform_tools.dart';

enum EMMessageSearchDirection { Up, Down }

class EMConversation {
  EMConversation._private();

  factory EMConversation.fromJson(Map<String, dynamic> map) {
    Map<String, String>? ext = map['ext']?.cast<String, String>();
    String? name;
    if (ext != null) {
      if (ext.containsKey("con_name")) {
        name = ext['con_name']!;
        ext.remove('con_name');
      }
    }

    EMConversation ret = EMConversation._private();
    ret.type = typeFromInt(map['type']);
    ret.id = map['con_id'];
    ret._unreadCount = map['unreadCount'];
    ret._ext = ext;
    ret._name = name ?? '';
    if (map['latestMessage'] != null) {
      ret._latestMessage = EMMessage.fromJson(map['latestMessage']);
    }
    if (map['lastReceivedMessage'] != null) {
      ret._lastReceivedMessage = EMMessage.fromJson(map['lastReceivedMessage']);
    }
    return ret;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = typeToInt(this.type);
    data['con_id'] = this.id;
    return data;
  }

  late String id;
  late EMConversationType type;

  int _unreadCount = 0;
  Map<String, String>? _ext;
  String? _name;
  EMMessage? _latestMessage;
  EMMessage? _lastReceivedMessage;

  static int typeToInt(EMConversationType? type) {
    int ret = 0;
    if (type == null) return ret;
    switch (type) {
      case EMConversationType.Chat:
        ret = 0;
        break;
      case EMConversationType.GroupChat:
        ret = 1;
        break;
      case EMConversationType.ChatRoom:
        ret = 2;
        break;
    }
    return ret;
  }

  static EMConversationType typeFromInt(int? type) {
    EMConversationType ret = EMConversationType.Chat;
    switch (type) {
      case 0:
        ret = EMConversationType.Chat;
        break;
      case 1:
        ret = EMConversationType.GroupChat;
        break;
      case 2:
        ret = EMConversationType.ChatRoom;
        break;
    }
    return ret;
  }
}

extension EMConversationExtension on EMConversation {
  static const MethodChannel _emConversationChannel =
      const MethodChannel('com.chat.im/chat_conversation', JSONMethodCodec());

  int get unreadCount {
    return _unreadCount;
  }

  EMMessage? get latestMessage {
    return _latestMessage;
  }

  EMMessage? get lastReceivedMessage {
    return _lastReceivedMessage;
  }

  String get name {
    if (this._name != null && this._name!.length > 0)
      return this._name!;
    else
      return this.id;
  }

  set name(String name) {
    this._name = name;
    _syncNameToNative();
  }

  Map<String, String>? get ext {
    return this._ext;
  }

  set ext(Map<String, String>? map) {
    this._ext = map;
    _syncExtToNative();
  }

  Future<void> _syncNameToNative() async {
    Map req = this.toJson();
    req['con_name'] = this._name ?? '';
    await _emConversationChannel.invokeMethod(
        ChatMethodKeys.syncConversationName, req);
  }

  Future<void> _syncExtToNative() async {
    Map req = this.toJson();
    req['ext'] = this._ext ?? '';
    await _emConversationChannel.invokeMethod(
        ChatMethodKeys.syncConversationExt, req);
  }

  /// 根据消息id设置消息已读，如果消息不属于当前会话则设置无效
  Future<bool> markMessageAsRead(String messageId) async {
    Map req = this.toJson();
    req['msg_id'] = messageId;
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.markMessageAsRead, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(ChatMethodKeys.markMessageAsRead);
  }

  /// 设置当前会话中所有消息为已读
  Future<void> markAllMessagesAsRead() async {
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.markAllMessagesAsRead, this.toJson());
    EMError.hasErrorFromResult(result);
  }

  /// 插入消息，插入的消息会根据消息时间插入到对应的位置
  Future<bool> insertMessage(EMMessage message) async {
    Map req = this.toJson();
    req['msg'] = message.toJson();
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.insertMessage, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(ChatMethodKeys.insertMessage);
  }

  /// 添加消息，添加的消息会添加到最后一条消息的位置
  Future<bool> appendMessage(EMMessage message) async {
    Map req = this.toJson();
    req['msg'] = message.toJson();
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.appendMessage, req);
    return result.boolValue(ChatMethodKeys.appendMessage);
  }

  /// 更新消息
  Future<bool> updateMessage(EMMessage message) async {
    Map req = this.toJson();
    req['msg'] = message.toJson();
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.updateConversationMessage, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(ChatMethodKeys.updateConversationMessage);
  }

  /// 根据消息id [messageId] 删除消息
  Future<bool> deleteMessage(String messageId) async {
    Map req = this.toJson();
    req['msg_id'] = messageId;
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.removeMessage, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(ChatMethodKeys.removeMessage);
  }

  // 删除当前会话中所有消息
  Future<bool> deleteAllMessages() async {
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.clearAllMessages, this.toJson());
    EMError.hasErrorFromResult(result);
    return result.boolValue(ChatMethodKeys.clearAllMessages);
  }

  /// 根据消息id获取消息，如果消息id不属于当前会话，则无法获取到
  Future<EMMessage?> loadMessage(String messageId) async {
    Map req = this.toJson();
    req['msg_id'] = messageId;
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.loadMsgWithId, req);
    EMError.hasErrorFromResult(result);
    if (result[ChatMethodKeys.loadMsgWithId] != null) {
      return EMMessage.fromJson(result[ChatMethodKeys.loadMsgWithId]);
    } else {
      return null;
    }
  }

  /// 根据类型获取当前会话汇总的消息
  Future<List<EMMessage?>> loadMessagesWithMsgType({
    required MessageType type,
    int timestamp = -1,
    int count = 20,
    String? sender,
    EMMessageSearchDirection direction = EMMessageSearchDirection.Up,
  }) async {
    Map req = this.toJson();
    req['type'] = messageTypeToTypeStr(type);
    req['timestamp'] = timestamp;
    req['count'] = count;
    req['sender'] = sender;
    req['direction'] = direction == EMMessageSearchDirection.Up ? "up" : "down";

    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.loadMsgWithMsgType, req);
    EMError.hasErrorFromResult(result);

    List<EMMessage?> list = [];
    result[ChatMethodKeys.loadMsgWithMsgType]?.forEach((element) {
      list.add(EMMessage.fromJson(element));
    });
    return list;
  }

  /// 根据起始消息id获取消息
  Future<List<EMMessage>> loadMessages({
    String startMsgId = '',
    int loadCount = 20,
    EMMessageSearchDirection direction = EMMessageSearchDirection.Up,
  }) async {
    Map req = this.toJson();
    req["startId"] = startMsgId;
    req['count'] = loadCount;
    req['direction'] = direction == EMMessageSearchDirection.Up ? "up" : "down";

    Map<String, dynamic> result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.loadMsgWithStartId, req);

    EMError.hasErrorFromResult(result);

    List<EMMessage> msgList = [];
    result[ChatMethodKeys.loadMsgWithStartId]?.forEach((element) {
      msgList.add(EMMessage.fromJson(element));
    });
    return msgList;
  }

  Future<List<EMMessage>> loadMessagesWithKeyword(
    String keywords, {
    String? sender,
    int timestamp = -1,
    int count = 20,
    EMMessageSearchDirection direction = EMMessageSearchDirection.Up,
  }) async {
    Map req = this.toJson();
    req["keywords"] = keywords;
    req['count'] = count;
    if (sender != null) {
      req['sender'] = sender;
    }
    req['timestamp'] = timestamp;
    req['direction'] = direction == EMMessageSearchDirection.Up ? "up" : "down";

    Map<String, dynamic> result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.loadMsgWithKeywords, req);

    EMError.hasErrorFromResult(result);

    List<EMMessage> msgList = [];
    result[ChatMethodKeys.loadMsgWithKeywords]?.forEach((element) {
      msgList.add(EMMessage.fromJson(element));
    });
    return msgList;
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

    EMError.hasErrorFromResult(result);

    List<EMMessage> msgList = [];
    result[ChatMethodKeys.loadMsgWithTime]?.forEach((element) {
      msgList.add(EMMessage.fromJson(element));
    });
    return msgList;
  }
}
