import "dart:async";
import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import "em_conversation.dart";
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

  final _messageListeners = List<EMMessageListener>();
  Function _conversationUpdateFunc;

  EMChatManager._internal(EMLog log) : log = log {
    _addNativeMethodCallHandler();
  }

  factory EMChatManager.getInstance({@required EMLog log}) {
    return _instance = _instance ?? EMChatManager._internal(log);
  }

  /// sendMessage - Sends message [message].
  void sendMessage(final EMMessage message) {
    _emChatManagerChannel.invokeMethod(
        EMSDKMethod.sendMessage, message.toDataMap());
  }

  void _addNativeMethodCallHandler() {
    _emChatManagerChannel.setMethodCallHandler((MethodCall call) {
      Map argMap = call.arguments;
      if (call.method == EMSDKMethod.onMessageReceived) {
        return _onMessageReceived(argMap);
      } else if (call.method == EMSDKMethod.onCmdMessageReceived) {
        return _onCmdMessageReceived(argMap);
      } else if (call.method == EMSDKMethod.onMessageRead) {
        return _onMessageRead(argMap);
      } else if (call.method == EMSDKMethod.onMessageDelivered) {
        return _onMessageDelivered(argMap);
      } else if (call.method == EMSDKMethod.onMessageRecalled) {
        return _onMessageRecalled(argMap);
      } else if (call.method == EMSDKMethod.onMessageChanged) {
        return _onMessageChanged(argMap);
      } else if (call.method == EMSDKMethod.onConversationUpdate) {
        return _conversationUpdateFunc();
      }
      return null;
    });
  }

  ///  ackMessageRead - Acknowledges [to] user that message [messageId] has been read.
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
        .invokeMethod(EMSDKMethod.getMessage, {"id": messageId});
    if (result['success']) {
      return EMMessage.from(result['message']);
    } else {
      return null;
    }
  }

  /// getConversation - Gets conversation form [id].
  Future<EMConversation> getConversation(
      {@required String id,
      EMConversationType type,
      bool createIfNotExists}) async {
    Map<String, dynamic> result = await _emChatManagerChannel.invokeMethod(
        EMSDKMethod.markAllChatMsgAsRead,
        {"id": id, "type": type, "createIfNotExists": createIfNotExists});
    if (result['success']) {
      return EMConversation.from(result['conversation']);
    } else {
      return null;
    }
  }

  /// markAllConversationAsRead - Marks all conversation as read.
  void markAllConversationsAsRead() {
    _emChatManagerChannel.invokeMethod(EMSDKMethod.markAllChatMsgAsRead);
  }

  /// getUnreadMessageCount - Gets count number of messages unread.
  Future<int> getUnreadMessageCount() async {
    Map<String, dynamic> result = await _emChatManagerChannel
        .invokeMethod(EMSDKMethod.getUnreadMessageCount);
    if (result['success']) {
      return result['count'];
    } else {
      return 0;
    }
  }

  /// saveMessage - Saves [message].
  void saveMessage(EMMessage message) {
    _emChatManagerChannel.invokeMethod(
        EMSDKMethod.saveMessage, {"message": message.toDataMap()});
  }

  /// updateMessage - Updates [message].
  Future<bool> updateMessage(EMMessage message) async {
    Map<String, dynamic> result = await _emChatManagerChannel.invokeMethod(
        EMSDKMethod.updateChatMessage,
        {"message": message.toDataMap()}); //TODO: only message id needed?
    if (result['success']) {
      return result['status'];
    } else {
      return false;
    }
  }

  /// downloadAttachment - Downloads attachment of [message].
  void downloadAttachment(final EMMessage message) {
    _emChatManagerChannel.invokeMethod(
        EMSDKMethod.downloadAttachment, {"message": message.toDataMap()});
  }

  /// downloadThumbnail - Downloads thumbnail of [message].
  void downloadThumbnail(final EMMessage message) {
    _emChatManagerChannel.invokeMethod(
        EMSDKMethod.downloadThumbnail, {"message": message.toDataMap()});
  }

  ///  importMessages - Imports list of [messages].
  void importMessages(List<EMMessage> messages) {
    _emChatManagerChannel.invokeMethod(EMSDKMethod.importMessages,
        {"messages": messages.map((message) => message.toDataMap())});
  }

  /// getConversationsByType - Gets all conversations of [type].
  Future<List<EMConversation>> getConversationsByType(
      EMConversationType type) async {
    Map<String, dynamic> result = await _emChatManagerChannel
        .invokeMethod(EMSDKMethod.getConversationsByType, {"type": type});
    if (result["success"]) {
      var conversations = result['conversations'] as List<Map<String, Object>>;
      return conversations
          .map((conversation) => EMConversation.from(conversation));
    } else {
      return null;
    }
  }

  /// downloadFile - Downloads file, specified by [remoteUrl], to store locally at [localFilePath].
  void downloadFile(
      {@required final String remoteUrl,
      @required final String localFilePath,
      final Map<String, String> headers,
      onSuccess(),
      onError(int code, String desc)}) {
    Future<Map> result = _emChatManagerChannel.invokeMethod(
        EMSDKMethod.downloadFile, {
      "remoteUrl": remoteUrl,
      "localFilePath": localFilePath,
      "headers": headers
    });
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) onSuccess();
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// getAllConversations - Gets all conversations.
  Future<Map<String, EMConversation>> getAllConversations() async {
    Map<String, dynamic> result = await _emChatManagerChannel
        .invokeMethod(EMSDKMethod.getAllConversations);
    if (result['success']) {
      var data = HashMap<String, EMConversation>();
      var conversations = result['conversations'] as List<Map<String, dynamic>>;
      for (var conversation in conversations) {
        data[conversation['id']] = EMConversation.from(conversation);
      }
      return data;
    } else {
      return null;
    }
  }

  /// loadAllConversations - Loads all conversations.
  void loadAllConversations() {
    _emChatManagerChannel.invokeMethod(EMSDKMethod.loadAllConversations);
  }

  /// deleteConversation - Deletes conversations with [userName], deletes also messages if [deleteMessages] set to true.
  Future<bool> deleteConversation(
      {@required final String userName, @required bool deleteMessages}) async {
    Map<String, dynamic> result = await _emChatManagerChannel.invokeMethod(
        EMSDKMethod.deleteConversation,
        {"userName": userName, "deleteMessages": deleteMessages});
    if (result['success']) {
      return result['status'];
    } else {
      return false;
    }
  }

  /// addMessageListener - Adds [listener] to be aware of message change events.
  void addMessageListener(EMMessageListener listener) {
    assert(listener != null);
    _messageListeners.add(listener);
  }

  /// removeMessageListener - Remove [listener] from the listener list.
  void removeMessageListener(EMMessageListener listener) {
    assert(listener != null);
    _messageListeners.remove(listener);
  }

  ///  onConversationUpdate - Sets conversation update callback function [onConversationUpdate].
  void onConversationUpdate(onConversationUpdate()) {
    _conversationUpdateFunc = onConversationUpdate;
  }

  /// setMessageListened - Sets [message] as listened.
  void setMessageListened(EMMessage message) {
    _emChatManagerChannel.invokeMethod(
        EMSDKMethod.setMessageListened, {"message": message.toDataMap()});
  }

  /// setVoiceMessageListened - Sets voice [message] as listened.
  void setVoiceMessageListened(EMMessage message) {
    _emChatManagerChannel.invokeMethod(
        EMSDKMethod.setVoiceMessageListened, {"message": message.toDataMap()});
  }

  /// updateParticipant - Updates participant from [from] to [changeTo].
  Future<bool> updateParticipant(String from, String changeTo) async {
    Map<String, dynamic> result = await _emChatManagerChannel.invokeMethod(
        EMSDKMethod.updateParticipant, {"from": from, "changeTo": changeTo});
    if (result['success']) {
      return result['status'];
    } else {
      return false;
    }
  }

  /// fetchHistoryMessages - Fetches history messages in conversation [conversationId], filtered by [type].
  /// Result paginated by [pageSize] per page, started from [startMsgId].
  Future<EMCursorResult<EMMessage>> fetchHistoryMessages(
      {@required final String conversationId,
      @required final EMConversationType type,
      int pageSize = 10,
      String startMsgId,
      onSuccess(),
      onError(int code, String desc)}) async {
    Map<String, dynamic> result = await _emChatManagerChannel
        .invokeMethod(EMSDKMethod.fetchHistoryMessages, {
      "id": conversationId,
      "type": type,
      "pageSize": pageSize,
      "startMsgId": startMsgId
    });
    if (result['success']) {
      return _EMCursorResult<EMMessage>(result['cursorId']);
    } else {
      return null;
    }
  }

  /// searchMsgFromDB - Searches messages with [keywords] as keyword, of [type], timestamp set at [timeStamp], from user [from], in [direction].
  /// Result paginated to return maximize [maxCount] records per call.
  Future<List<EMMessage>> searchMsgFromDB(
      {String keywords,
      EMMessageType type,
      int timeStamp,
      int maxCount,
      String from,
      EMSearchDirection direction}) async {
    Map<String, dynamic> result = await _emChatManagerChannel
        .invokeMethod(EMSDKMethod.searchChatMsgFromDB, {
      "keywords": keywords,
      "type": type,
      "timeStamp": timeStamp,
      "maxCount": maxCount,
      "from": from,
      "direction": direction
    });
    if (result['success']) {
      var messages = result['messages'] as List<Map<String, dynamic>>;
      var data = List<EMMessage>();
      for (var message in messages) {
        data.add(EMMessage.from(message));
      }
      return data;
    } else {
      return null;
    }
  }

  /// Listeners interface
  Future<void> _onMessageReceived(Map map) async {
    List<Map<String, Object>> list = map['messages'];
    var messages = List<EMMessage>();
    for (var message in list) {
      messages.add(EMMessage.from(message));
    }
    for (var listener in _messageListeners) {
      listener.onMessageReceived(messages);
    }
  }

  Future<void> _onCmdMessageReceived(Map map) async {
    List<Map<String, Object>> list = map['messages'];
    var messages = List<EMMessage>();
    for (var message in list) {
      messages.add(EMMessage.from(message));
    }
    for (var listener in _messageListeners) {
      listener.onCmdMessageReceived(messages);
    }
  }

  Future<void> _onMessageRead(Map map) async {
    List<Map<String, Object>> list = map['messages'];
    var messages = List<EMMessage>();
    for (var message in list) {
      messages.add(EMMessage.from(message));
    }
    for (var listener in _messageListeners) {
      listener.onMessageRead(messages);
    }
  }

  Future<void> _onMessageDelivered(Map map) async {
    List<Map<String, Object>> list = map['messages'];
    var messages = List<EMMessage>();
    for (var message in list) {
      messages.add(EMMessage.from(message));
    }
    for (var listener in _messageListeners) {
      listener.onMessageDelivered(messages);
    }
  }

  Future<void> _onMessageRecalled(Map map) async {
    List<Map<String, Object>> list = map['messages'];
    var messages = List<EMMessage>();
    for (var message in list) {
      messages.add(EMMessage.from(message));
    }
    for (var listener in _messageListeners) {
      listener.onMessageRecalled(messages);
    }
  }

  Future<void> _onMessageChanged(Map map) async {
    EMMessage message = EMMessage.from(map['message']);
    Object change = map['change'];
    for (var listener in _messageListeners) {
      listener.onMessageChanged(message, change);
    }
  }
}

// _EMCursorResult - internal EMCursorResult implementation.
class _EMCursorResult<T> extends EMCursorResult<T> {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emChatManagerChannel =
      MethodChannel('$_channelPrefix/em_chat_manager');
  _EMCursorResult(String cursorId) : this._cursorId = cursorId;

  final String _cursorId;

  @override
  Future<T> getCursor() async {
    Map<String, Object> result = await _emChatManagerChannel
        .invokeMethod(EMSDKMethod.getCursor, {"id": _cursorId});
    if (result['success']) {
      EMMessage message = EMMessage.from(result['message']);
      return message as T;
    } else {
      return null;
    }
  }
}
