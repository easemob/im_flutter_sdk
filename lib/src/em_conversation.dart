import "dart:async";

import 'package:flutter/services.dart';

import "em_domain_terms.dart";
import "em_sdk_method.dart";

class EMConversation {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emConversationChannel =
      const MethodChannel('$_channelPrefix/em_conversation', JSONMethodCodec());
  final String _conversationId;

  /// 会话id
  String get conversationId => _conversationId;
  EMConversationType _type;

  /// 会话类型
  EMConversationType get type => _type;

  /// 会话扩展
  String extField;

  /// @nodoc
  EMConversation(String conversationId) : _conversationId = conversationId;

  /// @nodoc
  EMConversation.from(Map data)
      : _conversationId = data['id'],
        _type = fromEMConversationType(data['type']),
        extField = data['ext'];

  /// 获取此对话中未读取的消息数量.
  Future<int> getUnreadMsgCount() async {
    Map<String, dynamic> result = await _emConversationChannel
        .invokeMethod(EMSDKMethod.getUnreadMsgCount, {"id": _conversationId});
    if (result['success']) {
      return result['count'];
    }
    return -1; //-1 means error/unknown
  }

  /// 将所有未读消息设置为已读.
  void markAllMessagesAsRead() {
    _emConversationChannel.invokeMethod(
        EMSDKMethod.markAllMessagesAsRead, {"id": _conversationId});
  }

  /// 根据传入的参数从db加载startMsgId之前(存储顺序)指定数量的message[startMsgId], [pageSize]
  Future<List<EMMessage>> loadMoreMsgFromDB(
      String startMsgId, int pageSize) async {
    Map<String, dynamic> result = await _emConversationChannel.invokeMethod(
        EMSDKMethod.loadMoreMsgFromDB, {
      "id": _conversationId,
      "startMsgId": startMsgId,
      "pageSize": pageSize
    });
    if (result['success']) {
      var messages = List<EMMessage>();
      var _messages = result['messages'];
      for (var message in _messages) {
        messages.add(EMMessage.from(message));
      }
      return messages;
    }
    return null;
  }

  /// 根据传入的参数从本地存储中搜索指定数量的消息
  /// [keywords], 搜索消息中的关键词
  /// [timeStamp],搜索消息的时间点
  /// [maxCount] 搜索结果的最大条数
  /// [from] 搜索来自某人的消息，适用于搜索群组里的消息
  /// [direction]. 方向
  Future<List<EMMessage>> searchMsgFromDB(String keywords,
      int timeStamp, int maxCount, String from, EMSearchDirection direction) async {
    Map<String, dynamic> result = await _emConversationChannel
        .invokeMethod(EMSDKMethod.searchConversationMsgFromDB, {
      "id": _conversationId,
      "keywords": keywords,
      "timeStamp": timeStamp,
      "maxCount": maxCount,
      "from" : from,
      "direction": toEMSearchDirection(direction)
    });
    if (result['success']) {
      var messages = List<EMMessage>();
      var _messages = result['messages'];
      for (var message in _messages) {
        messages.add(EMMessage.from(message));
      }
      return messages;
    }
    return null;
  }

  /// 搜索来自DB的消息，类型为[type]，在[timeStamp]之后，[maxCount]返回的大多数消息，[from] 搜索来自某人的消息，适用于搜索群组里的消息,方向为[direction]。
  Future<List<EMMessage>> searchMsgFromDBByType(
      EMMessageType type,
      int timeStamp,
      int maxCount,
      String from,
      EMSearchDirection direction) async {
    Map<String, dynamic> result = await _emConversationChannel
        .invokeMethod(EMSDKMethod.searchConversationMsgFromDBByType, {
      "id": _conversationId,
      "type": toType(type),
      "timeStamp": timeStamp,
      "maxCount": maxCount,
      "from" : from,
      "direction": toEMSearchDirection(direction)
    });
    if (result['success']) {
      var messages = List<EMMessage>();
      var _messages = result['messages'];
      for (var message in _messages) {
        messages.add(EMMessage.from(message));
      }
      return messages;
    }
    return null;
  }

  /// 通过[mesasgeId]获取消息，[markAsRead] 将其设置为已读.
  Future<EMMessage> getMessage(String messageId,
      {bool markAsRead = true}) async {
    Map<String, dynamic> result = await _emConversationChannel.invokeMethod(
        EMSDKMethod.getMessage, {
      "id": _conversationId,
      "messageId": messageId,
      "markAsRead": markAsRead
    });
    if (result['success']) {
      return EMMessage.from(result['message']);
    }
    return null;
  }

  /// @nodoc 加载列表[msgIds]中显示的所有消息。
  Future<List<EMMessage>> loadMessages(List<String> msgIds) async {
    Map<String, dynamic> result = await _emConversationChannel.invokeMethod(
        EMSDKMethod.loadMessages, {"id": _conversationId, "msgIds": msgIds});
    if (result['success']) {
      var messages = List<EMMessage>();
      var _messages = result['messages'];
      for (var message in _messages) {
        messages.add(EMMessage.from(message));
      }
      return messages;
    }
    return null;
  }

  /// 将id是[messageId]的消息标记为已读。
  void markMessageAsRead(String messageId) {
    _emConversationChannel.invokeMethod(EMSDKMethod.markMessageAsRead,
        {"id": _conversationId, "messageId": messageId});
  }

  /// 从对话中删除id是[messageId]的消息。
  void removeMessage(String messageId) {
    _emConversationChannel.invokeMethod(EMSDKMethod.removeMessage,
        {"id": _conversationId, "messageId": messageId});
  }

  /// 获取对话的最后一条消息
  Future<EMMessage> getLastMessage() async {
    Map<String, dynamic> result = await _emConversationChannel
        .invokeMethod(EMSDKMethod.getLastMessage, {"id": _conversationId});
    if (result['success']) {
      return EMMessage.from(result['message']);
    }
    return null;
  }

  /// 获取其他人发送的最新消息。
  Future<EMMessage> getLatestMessageFromOthers() async {
    Map<String, dynamic> result = await _emConversationChannel.invokeMethod(
        EMSDKMethod.getLatestMessageFromOthers, {"id": _conversationId});
    if (result['success']) {
      return EMMessage.from(result['message']);
    }
    return null;
  }

  /// 清除对话中的所有消息，只清除内存的，不清除db的消息 在退出会话的时候清除内存缓存，减小内存消耗
  void clear() {
    _emConversationChannel
        .invokeMethod(EMSDKMethod.clear, {"id": _conversationId});
  }

  /// 删除该会话所有消息，同时清除内存和数据库中的消息
  void clearAllMessages() {
    _emConversationChannel
        .invokeMethod(EMSDKMethod.clearAllMessages, {"id": _conversationId});
  }

  /// 群组和聊天室类型都会返回true
  bool isGroup() {
    return EMConversationType.GroupChat == type;
  }

  /// 插入一条消息[msg]
  void insertMessage(EMMessage msg) {
    print('插入消息-------------');
    _emConversationChannel.invokeMethod(EMSDKMethod.insertMessage,
        {"id": _conversationId, "msg": msg.toDataMap()});
  }

  /// 插入一条消息到会话尾部[msg]
  void appendMessage(EMMessage msg) {
    _emConversationChannel.invokeMethod(EMSDKMethod.appendMessage,
        {"id": _conversationId, "msg": msg.toDataMap()});
  }

  /// 更新本地的消息[msg]
  void updateMessage(EMMessage msg,
      {onSuccess(), onError(String desc)}) async {
    Map<String, dynamic> result = await _emConversationChannel.invokeMethod(
        EMSDKMethod.updateConversationMessage,
        {"id": _conversationId, "msg": msg.toDataMap()});
    if (result['success']) {
        if (onSuccess != null) onSuccess();
    }
        if (onError != null) onError(result['error']);
  }

  /// @nodoc 返回会话对应的附件存储路径.
  Future<String> getMessageAttachmentPath() async {
    Map<String, dynamic> result = await _emConversationChannel.invokeMethod(
        EMSDKMethod.getMessageAttachmentPath, {"id": _conversationId});
    if (result['success']) {
      return result['path'];
    }
    return null;
  }
}

/// @nodoc EMConversationType - 会话枚举的类型。
enum EMConversationType {
  Chat,
  GroupChat,
  ChatRoom,
  DiscussionGroup,
  HelpDesk,
}
