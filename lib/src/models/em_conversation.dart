import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk/src/models/em_error.dart';
import 'package:im_flutter_sdk/src/models/em_message.dart';

import '../em_sdk_method.dart';

enum EMConversationType {
  Chat, // 单聊消息
  GroupChat, // 群聊消息
  ChatRoom, // 聊天室消息
}

enum EMMessageSearchDirection {
  Up,
  Down,
}

class EMConversation {

  EMConversation();

  factory EMConversation.fromJson(Map <String, dynamic> map) {
      return EMConversation()
        ..type = typeFromInt(map['type'])
        ..id = map['id']
        .._unreadCount = map['unreadCount']
        .._ext = map['ext']
        .._latestMessage = EMMessage.fromJson(map['latestMessage'])
        .._lastReceivedMessage = EMMessage.fromJson(map['lastReceivedMessage']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = typeToInt(this.type);
    data['id'] = this.id;
    return data;
  }

  String id = '';
  EMConversationType type;

  int _unreadCount;
  Map _ext;
  EMMessage _latestMessage;
  EMMessage _lastReceivedMessage;

  static int typeToInt(EMConversationType type) {
    int ret = 0;
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

  static  EMConversationType typeFromInt(int type) {
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
  const MethodChannel('com.easemob.im/em_conversation', JSONMethodCodec());

  get unreadCount async {
    Map result = await _emConversationChannel.invokeMethod(EMSDKMethod.getUnreadMsgCount, this.toJson());

    EMError.hasErrorFromResult(result);

    this._unreadCount = result[EMSDKMethod.getUnreadMsgCount];

    return this._unreadCount;
  }

   get latestMessage async {
    // TODO: 去native 获取数据

    return this._latestMessage;
  }

  get lastReceivedMessage async {
    // TODO: 去native 获取数据
    return this._lastReceivedMessage;
  }

  get ext {
    // TODO: 从native获取，并同步到_ext;
    return this._ext;
  }

  set ext(Map map) {
    this._ext = map;
    // TODO: 同步到native
  }

  void insertMessage(EMMessage message) {

  }

  void appendMessage(EMMessage message) {

  }

  void deleteMessageWithId(String messageId) {

  }

  Future<Null> deleteAllMessages() async {
    Map result = await _emConversationChannel.invokeMethod(EMSDKMethod.clearAllMessages, this.toJson());
    EMError.hasErrorFromResult(result);
  }

  void updateMessage(EMMessage message) {

  }

  void markMessageAsRead({@required String messageId}) async {

  }

  Future<Null> markAllMessagesAsRead() async {
    Map result = await _emConversationChannel.invokeMethod(EMSDKMethod.markAllMessagesAsRead, this.toJson());
    EMError.hasErrorFromResult(result);
  }

  EMMessage loadMessageFromId(String messageId) {

    return null;
  }

  Future<List> loadMessagesWithType({
    @required EMMessageBodyType type,
    int timestamp = -1,
    int count = 20,
    String sender,
    EMMessageSearchDirection direction = EMMessageSearchDirection.Up,
  }) {
    return null;
  }

  Future<List> loadMessagesWithStartId (
      String startMsgId,
      [int loadCount = 20, EMMessageSearchDirection direction = EMMessageSearchDirection.Up,]
  ) async {

    Map req = this.toJson();
    req["startId"] = startMsgId;
    req['count'] = loadCount;

    Map<String, dynamic> result = await _emConversationChannel.invokeMethod(EMSDKMethod.loadMoreMsgFromDB, req);

    EMError.hasErrorFromResult(result);

    List<EMMessage> msgList = List();
    (result[EMSDKMethod.loadMoreMsgFromDB] as List).forEach((element) {
      msgList.add(EMMessage.fromJson(element));
    });
    return msgList;
  }

  Future<List> loadMessagesWithKeyword({
    @required String keyWord,
    int timestamp = -1,
    int count = 20,
    String sender,
    EMMessageSearchDirection direction = EMMessageSearchDirection.Up,
  }) {
    return null;
  }

  Future<List> loadMessagesFromTime({
    @required int startTime,
    @required int endTime,
    int count = 20,
  }) {
    return null;
  }

}