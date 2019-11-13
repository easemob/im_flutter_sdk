import "dart:async";

import 'package:flutter/services.dart';
import "package:meta/meta.dart";

import "em_domain_terms.dart";
import "em_sdk_method.dart";

class EMConversation {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emConversationChannel =
      const MethodChannel('$_channelPrefix/em_conversation', JSONMethodCodec());
  final String _conversationId;
  String get conversationId => _conversationId;
  EMConversationType _type;
  EMConversationType get type => _type;

  String extField;

  EMConversation({@required String conversationId})
      : _conversationId = conversationId;

  EMConversation.from(Map data)
      : _conversationId = data['id'],
        _type = fromEMConversationType(data['type']),
        extField = data['ext'];

  /// getUnreadMsgCount - Gets count of unread messages.
  Future<int> getUnreadMsgCount() async {
    Map<String, dynamic> result = await _emConversationChannel
        .invokeMethod(EMSDKMethod.getUnreadMsgCount, {"id": _conversationId});
    if (result['success']) {
      return result['count'];
    }
    return -1; //-1 means error/unknown
  }

  /// markAllMessagesAsRead - Marks all messages as read.
  void markAllMessagesAsRead() {
    _emConversationChannel.invokeMethod(
        EMSDKMethod.markAllMessagesAsRead, {"id": _conversationId});
  }

  /// loadMoreMsgFromDB - Loads messages starts from [startMsgId], [pageSize] in total.
  Future<List<EMMessage>> loadMoreMsgFromDB(
      {@required String startMsgId, int pageSize = 10}) async {
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

  /// searchMsgFromDB - Searches messages from DB, of [type], matches [keywords], after [timeStamp], [maxCount] most messages returned, in [direction].
  Future<List<EMMessage>> searchMsgFromDB(
      {final EMMessageType type,
      final String keywords,
      @required final int timeStamp,
      final int maxCount = 10,
      final EMSearchDirection direction}) async {
    Map<String, dynamic> result = await _emConversationChannel
        .invokeMethod(EMSDKMethod.searchConversationMsgFromDB, {
      "id": _conversationId,
      "type": type,
      "keywords": keywords,
      "timeStamp": timeStamp,
      "maxCount": maxCount,
      "direction": direction
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

  /// searchMsgFromDB - Searches messages from DB, of [type], matches [keywords], after [timeStamp], [maxCount] most messages returned, in [direction].
  Future<List<EMMessage>> searchMsgFromDBByType(
      {final EMMessageType type,
      final String keywords,
      @required final int timeStamp,
      final int maxCount = 10,
      final EMSearchDirection direction}) async {
    Map<String, dynamic> result = await _emConversationChannel
        .invokeMethod(EMSDKMethod.searchConversationMsgFromDBByType, {
      "id": _conversationId,
      "type": type,
      "timeStamp": timeStamp,
      "maxCount": maxCount,
      "direction": direction
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

  // getMessage - Gets message by [mesasgeId], set it to read if [markAsRead].
  Future<EMMessage> getMessage(
      {@required final String messageId, final bool markAsRead = true}) async {
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

  /// loadMessages - Loads all messages presenting in list [msgIds].
  Future<List<EMMessage>> loadMessages(
      {@required final List<String> msgIds}) async {
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

  /// markMessageAsRead - Marks message [messageId] as read.
  void markMessageAsRead({@required final String messageId}) {
    _emConversationChannel.invokeMethod(EMSDKMethod.markMessageAsRead,
        {"id": _conversationId, "messageId": messageId});
  }

  /// removeMessage - Removes message [messageId] from the conversation.
  void removeMessage({@required String messageId}) {
    _emConversationChannel.invokeMethod(EMSDKMethod.removeMessage,
        {"id": _conversationId, "messageId": messageId});
  }

  /// getLastMessage - Gets last message of the conversation.
  Future<EMMessage> getLastMessage() async {
    Map<String, dynamic> result = await _emConversationChannel
        .invokeMethod(EMSDKMethod.getLastMessage, {"id": _conversationId});
    if (result['success']) {
      return EMMessage.from(result['message']);
    }
    return null;
  }

  /// getLatestMessageFromOthers - Gets latest messages sent from others.
  Future<EMMessage> getLatestMessageFromOthers() async {
    Map<String, dynamic> result = await _emConversationChannel.invokeMethod(
        EMSDKMethod.getLatestMessageFromOthers, {"id": _conversationId});
    if (result['success']) {
      return EMMessage.from(result['message']);
    }
    return null;
  }

  /// clear - Clears the conversation.
  void clear() {
    _emConversationChannel
        .invokeMethod(EMSDKMethod.clear, {"id": _conversationId});
  }

  /// clearAllMessages - Clears all messages in the conversation.
  void clearAllMessages() {
    _emConversationChannel
        .invokeMethod(EMSDKMethod.clearAllMessages, {"id": _conversationId});
  }

  /// isGroup - Is conversation is a group chat?
  bool isGroup() {
    return EMConversationType.GroupChat == type;
  }

  /// insertMessage - Inserts message [msg] into conversation.
  void insertMessage(EMMessage msg) {
    _emConversationChannel.invokeMethod(EMSDKMethod.insertMessage,
        {"id": _conversationId, "msg": msg.toDataMap()});
  }

  /// appendMessage - Appends message [msg] into conversation.
  void appendMessage(EMMessage msg) {
    _emConversationChannel.invokeMethod(EMSDKMethod.appendMessage,
        {"id": _conversationId, "msg": msg.toDataMap()});
  }

  /// updateMessage - Updates message with new content set.
  Future<bool> updateMessage(EMMessage msg) async {
    Map<String, dynamic> result = await _emConversationChannel.invokeMethod(
        EMSDKMethod.updateConversationMessage,
        {"id": _conversationId, "msg": msg.toDataMap()});
    if (result['success']) {
      return true;
    }
    return false;
  }

  /// getMessageAttachmentPath - Gets message's attachement path.
  Future<String> getMessageAttachmentPath() async {
    Map<String, dynamic> result = await _emConversationChannel.invokeMethod(
        EMSDKMethod.getMessageAttachmentPath, {"id": _conversationId});
    if (result['success']) {
      return result['path'];
    }
    return null;
  }
}

/// EMConversationType - Type of conversation enumeration.
enum EMConversationType {
  Chat,
  GroupChat,
  ChatRoom,
  DiscussionGroup,
  HelpDesk,
}
