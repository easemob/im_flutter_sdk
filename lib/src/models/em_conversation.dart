import 'package:flutter/foundation.dart';
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

enum EMMessageSearchDirection { Up, Down }

class EMConversation {

  EMConversation();

  factory EMConversation.fromJson(Map <String, dynamic> map) {
    if(map == null) return null;
    return EMConversation()
      ..type = typeFromInt(map['type'])
      ..id = map['con_id']
      .._unreadCount = map['unreadCount']
      .._ext = map['ext']
      .._latestMessage = EMMessage.fromJson(map['latestMessage'])
      .._lastReceivedMessage = EMMessage.fromJson(map['lastReceivedMessage']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = typeToInt(this.type);
    data['con_id'] = this.id;
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

  static EMConversationType typeFromInt(int type) {
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

  Future<int> get unreadCount async {
    EMLog.v('unreadCount: ' + this.id);
    Map result = await _emConversationChannel.invokeMethod(EMSDKMethod.getUnreadMsgCount, this.toJson());
    EMError.hasErrorFromResult(result);
    _unreadCount = result[EMSDKMethod.getUnreadMsgCount];
    return _unreadCount;
  }

  Future<EMMessage> get latestMessage async {
    EMLog.v('latestMessage: ' + this.id);
    Map result = await _emConversationChannel.invokeMethod(EMSDKMethod.getLatestMessage, this.toJson());
    EMError.hasErrorFromResult(result);
    _latestMessage = EMMessage.fromJson(result[EMSDKMethod.getLatestMessage]);
    return _latestMessage;
  }

  Future<EMMessage> get lastReceivedMessage async {
    EMLog.v('lastReceivedMessage: ' + this.id);
    Map result = await _emConversationChannel.invokeMethod(EMSDKMethod.getLatestMessageFromOthers, this.toJson());
    EMError.hasErrorFromResult(result);
    this._lastReceivedMessage = EMMessage.fromJson(result[EMSDKMethod.getLatestMessageFromOthers]);
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

  /// 根据消息id设置消息已读，如果消息不属于当前会话则设置无效
  Future<bool>  markMessageAsRead(String messageId) async {
    Map req = this.toJson();
    req['msg_id'] = messageId;
    Map result = await _emConversationChannel.invokeMethod(EMSDKMethod.markMessageAsRead, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.markMessageAsRead);
  }

  /// 设置当前会话中所有消息为已读
  Future<Null> markAllMessagesAsRead() async {
    Map result = await _emConversationChannel.invokeMethod(EMSDKMethod.markAllMessagesAsRead, this.toJson());
    EMError.hasErrorFromResult(result);
  }

  /// 插入消息，插入的消息会根据消息时间插入到对应的位置
  Future<bool> insertMessage(EMMessage message) async {
    Map req = this.toJson();
    req['msg'] = message.toJson();
    Map result = await _emConversationChannel.invokeMethod(EMSDKMethod.insertMessage, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.insertMessage);
  }

  /// 添加消息，添加的消息会添加到最后一条消息的位置
  Future<bool> appendMessage(EMMessage message) async{
    Map req = this.toJson();
    req['msg'] = message.toJson();
    Map result = await _emConversationChannel.invokeMethod(EMSDKMethod.appendMessage, req);
    return result.boolValue(EMSDKMethod.appendMessage);
  }

  /// 更新消息
  Future<bool> updateMessage(EMMessage message) async {
    Map req = this.toJson();
    req['msg'] = message.toJson();
    Map result = await _emConversationChannel.invokeMethod(EMSDKMethod.updateConversationMessage, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.updateConversationMessage);
  }

  /// 根据消息id [messageId] 删除消息
  Future<bool> deleteMessage(String messageId) async{
    Map req = this.toJson();
    req['msg_id'] = messageId;
    Map result = await _emConversationChannel.invokeMethod(EMSDKMethod.removeMessage, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.removeMessage);
  }
  // 删除当前会话中所有消息
  Future<bool> deleteAllMessages() async {
    Map result = await _emConversationChannel.invokeMethod(EMSDKMethod.clearAllMessages, this.toJson());
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.clearAllMessages);
  }

  /// 根据消息id获取消息，如果消息id不属于当前会话，则无法获取到
  Future<EMMessage> loadMessage(String messageId) async {
    Map req = this.toJson();
    req['msg_id'] = messageId;
    Map result = await _emConversationChannel.invokeMethod(EMSDKMethod.loadMsgWithId, req);
    EMError.hasErrorFromResult(result);
    return EMMessage.fromJson(result[EMSDKMethod.loadMsgWithId]);
  }

  /// 根据类型获取当前会话汇总的消息
  Future<List> loadMessagesWithMsgType({
    @required EMMessageBodyType type,
    int timestamp = -1,
    int count = 20,
    String sender,
    EMMessageSearchDirection direction = EMMessageSearchDirection.Up,
  }) async {
    Map req = this.toJson();
    req['type'] = EMMessageBody.bodyTypeToTypeStr(type);
    req['timestamp'] = timestamp;
    req['count'] = count;
    req['sender'] = sender;
    req['direction'] = direction == EMMessageSearchDirection.Up ? "up" : "down";

    Map result = await _emConversationChannel.invokeMethod(EMSDKMethod.loadMsgWithMsgType, req);
    EMError.hasErrorFromResult(result);

    List<EMMessage> list = List();
    (result[EMSDKMethod.loadMsgWithMsgType] as List).forEach((element) {
        list.add(EMMessage.fromJson(element));
    });
    return list;
  }

  /// 根据起始消息id获取消息
  Future<List> loadMessagesWithStartId (
      String startMsgId,
      [int loadCount = 20, EMMessageSearchDirection direction = EMMessageSearchDirection.Up,]
  ) async {
    Map req = this.toJson();
    req["startId"] = startMsgId;
    req['count'] = loadCount;
    req['direction'] = direction == EMMessageSearchDirection.Up ? "up" : "down";

    Map<String, dynamic> result = await _emConversationChannel.invokeMethod(EMSDKMethod.loadMsgWithStartId, req);

    EMError.hasErrorFromResult(result);

    List<EMMessage> msgList = List();
    (result[EMSDKMethod.loadMsgWithStartId] as List).forEach((element) {
      msgList.add(EMMessage.fromJson(element));
    });
    return msgList;
  }

  Future<List> loadMessagesWithKeyword({
    String keywords,
    int timestamp = -1,
    int count = 20,
    String sender,
    EMMessageSearchDirection direction = EMMessageSearchDirection.Up,
  }) async {
    Map req = this.toJson();
    req["keywords"] = keywords;
    req['count'] = count;
    req['sender'] = sender;
    req['timestamp'] = timestamp;
    req['direction'] = direction == EMMessageSearchDirection.Up ? "up" : "down";

    Map<String, dynamic> result = await _emConversationChannel.invokeMethod(EMSDKMethod.loadMsgWithKeywords, req);

    EMError.hasErrorFromResult(result);

    List<EMMessage> msgList = List();
    (result[EMSDKMethod.loadMsgWithKeywords] as List).forEach((element) {
      msgList.add(EMMessage.fromJson(element));
    });
    return msgList;
  }

  Future<List> loadMessagesFromTime({
    @required int startTime,
    @required int endTime,
    int count = 20,
  }) async {

    Map req = this.toJson();
    req["startTime"] = startTime;
    req['endTime'] = endTime;
    req['count'] = count;

    Map<String, dynamic> result = await _emConversationChannel.invokeMethod(EMSDKMethod.loadMsgWithTime, req);

    EMError.hasErrorFromResult(result);

    List<EMMessage> msgList = List();
    (result[EMSDKMethod.loadMsgWithTime] as List).forEach((element) {
      msgList.add(EMMessage.fromJson(element));
    });
    return msgList;
  }

}