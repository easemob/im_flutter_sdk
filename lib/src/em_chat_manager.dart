import "dart:async";

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'em_domain_terms.dart';
import 'em_listeners.dart';
import 'em_log.dart';
import 'em_sdk_method.dart';

class EMChatManager {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emChatManagerChannel =
      const MethodChannel('$_channelPrefix/em_chat_manager');
  static EMChatManager _instance;

  final EMLog log;

  EMChatManager._internal(EMLog log) : log = log;

  factory EMChatManager.getInstance({@required EMLog log}) {
    return _instance = _instance ?? EMChatManager._internal(log);
  }

  /// sendMessage - Sends message [msg].
  void sendMessage(final EMMessage msg) {
    _emChatManagerChannel.invokeMethod(EMSDKMethod.sendMessage, msg);
  }

  ///  ackMessageRead - Acknowledgs [to] user that message [messageId] has been read.
  void ackMessageRead(
      {@required String to,
      @required String messageId,
      onError(int code, String desc)}) {
    Future<Map> result = _emChatManagerChannel
        .invokeMethod(EMSDKMethod.ackMessageRead, {"to": to, "id": messageId});
    result.then((response) {
      if (!response['success']) {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// recallMessage - Recalls [message] sent before.
  /// Calls [onSuccess] if everything runs ok, [onError] if anything wrong, with [code], [desc] set as detail error information.
  void recallMessage(
      {@required EMMessage message,
      onSuccess(),
      onError(int code, String desc)}) {
    Future<Map> result = _emChatManagerChannel.invokeMethod(
        EMSDKMethod.recallMessage, message.toDataMap());
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) onSuccess();
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// getMessage - Gets message identified by [messageId].
  Future<EMMessage> getMessage(String messageId) async {
    Map<String, dynamic> result = await _emChatManagerChannel
        .invokeMethod(EMSDKMethod.getMessage, {"messageId": messageId});
    if (result['success']) {
      return EMMessage.from(result['message']);
    } else {
      return null;
    }
  }

  /// getConverstion - Gets conversation form [id].
  Future<EMConversation> getConversation(
      {@required String id,
      EMConversationType type,
      bool createIfNotExists}) async {
    return null;
  }

  /// markAllConversationAsRead - Marks all conversation as read.
  void markAllConversationsAsRead() {}

  /// getUnreadMessageCount - Gets count number of messages unread.
  int getUnreadMessageCount() {
    return 0;
  }

  /// saveMessage - Saves [message].
  void saveMessage(EMMessage message) {}

  /// updateMessage - Updates [message].
  Future<bool> updateMessage(EMMessage message) async {
    return false;
  }

  /// downloadAttachment - Downloads attachment of [message].
  void downloadAttachment(final EMMessage message) {}

  /// downloadThumbnail - Downloads thumbnail of [message].
  void downloadThumbnail(final EMMessage message) {}

  ///  importMessages - Imports list of [messages].
  void importMessages(List<EMMessage> messages) {}

  /// getConversationsByType - Gets all conversations of [type].
  Future<List<EMConversation>> getConversationsByType(
      EMConversationType type) async {
    return null;
  }

  /// downloadFile - Downloads file, specified by [remoteUrl], to store locally at [localFilePath].
  void downloadFile(
      {@required final String remoteUrl,
      @required final String localFilePath,
      final Map<String, String> headers,
      onSuccess(),
      onError(int code, String desc)}) {}

  /// getAllConversations - Gets all conversations.
  Future<Map<String, EMConversation>> getAllConversations() async {
    return null;
  }

  /// loadAllConversations - Loads all conversations.
  void loadAllConversations() {}

  /// deleteConversation - Deletes conversations with [userName], deletes also messages if [deleteMessages] set to true.
  Future<bool> deleteConversation(
      {@required final String userName, @required bool deleteMessages}) async {
    return null;
  }

  /// addMessageListener - Adds [listener] to be aware of message change events.
  void addMessageListener(EMMessageListener listener) {}

  /// removeMessageListener - Remove [listener] from the listener list.
  void removeMessageListener(EMMessageListener listener) {}

  ///  onConversationUpdate - Sets conversation update callback function [onConversationUpdate].
  void onConversationUpdate(onConversationUpdate()) {}

  /// setMessageListened - Sets [message] as listened.
  void setMessageListened(EMMessage message) {}

  /// setVoiceMessageListened - Sets voice [message] as listened.
  void setVoiceMessageListened(EMMessage message) {}

  /// updateParticipant - Updates participant from [from] to [changeTo].
  Future<bool> updateParticipant(String from, String changeTo) async {
    return null;
  }

  /// fetchHistoryMessages - Fetches history messages in conversation [conversationId], filtered by [type].
  /// Result painated by [pageSize] per page, started from [startMsgId].
  Future<EMCursorResult<EMMessage>> fetchHistoryMessages(
      {@required final String conversationId,
      @required final EMConversationType type,
      int pageSize = 10,
      String startMsgId,
      onSuccess(),
      onError(int code, String desc)}) async {
    return null;
  }

  /// searchMsgFromDB - Searches messages with [keywords] as keyword, of [type], timestamp set at [timeStamp], from user [from], in [direction].
  /// Result paginated to return maximize [maxCount] records per call.
  List<EMMessage> searchMsgFromDB(
      {String keywords,
      EMMessageType type,
      int timeStamp,
      int maxCount,
      String from,
      EMSearchDirection direction}) {
    return null;
  }
}
