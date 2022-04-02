import "dart:async";

import 'package:flutter/services.dart';
import 'internal/em_transform_tools.dart';
import 'tools/em_extension.dart';
import '../im_flutter_sdk.dart';
import 'internal/chat_method_keys.dart';
import 'tools/em_message_callback_manager.dart';

///
/// The chat manager. This class is responsible for managing conversations.
/// (such as: load, delete), sending messages, downloading attachments and so on.
///
/// Such as, send a text message:
///
/// ```dart
///    EMMessage msg = EMMessage.createTxtSendMessage(
///        username: toChatUsername, content: content);
///    await EMClient.getInstance.chatManager.sendMessage(msg);
/// ```
///
class EMChatManager {
  static const _channelPrefix = 'com.chat.im';
  static const MethodChannel _channel =
      const MethodChannel('$_channelPrefix/chat_manager', JSONMethodCodec());

  final List<EMChatManagerListener> _messageListeners = [];

  /// @nodoc
  EMChatManager() {
    MessageCallBackManager.getInstance;
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == ChatMethodKeys.onMessagesReceived) {
        return _onMessagesReceived(call.arguments);
      } else if (call.method == ChatMethodKeys.onCmdMessagesReceived) {
        return _onCmdMessagesReceived(call.arguments);
      } else if (call.method == ChatMethodKeys.onMessagesRead) {
        return _onMessagesRead(call.arguments);
      } else if (call.method == ChatMethodKeys.onGroupMessageRead) {
        return _onGroupMessageRead(call.arguments);
      } else if (call.method == ChatMethodKeys.onMessagesDelivered) {
        return _onMessagesDelivered(call.arguments);
      } else if (call.method == ChatMethodKeys.onMessagesRecalled) {
        return _onMessagesRecalled(call.arguments);
      } else if (call.method == ChatMethodKeys.onConversationUpdate) {
        return _onConversationsUpdate(call.arguments);
      } else if (call.method == ChatMethodKeys.onConversationHasRead) {
        return _onConversationHasRead(call.arguments);
      }
      return null;
    });
  }

  ///
  /// Sends a message.
  ///
  /// Reference:
  /// If the message is voice, picture and other message with attachment, the SDK will automatically upload the attachment.
  /// You can set whether to upload the attachment to the chat sever by {@link EMOptions#serverTransfer(boolean)}.
  ///
  /// To listen for the status of sending messages, call {@link EMMessage#setMessageStatusListener(StatusListener)}.
  ///
  /// Param [message] The message object to be sent
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<EMMessage> sendMessage(EMMessage message) async {
    message.status = MessageStatus.PROGRESS;
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.sendMessage, message.toJson());
    try {
      EMError.hasErrorFromResult(result);
      EMMessage msg = EMMessage.fromJson(result[ChatMethodKeys.sendMessage]);
      message.from = msg.from;
      message.to = msg.to;
      message.status = msg.status;
      return message;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 重发消息 [message].
  Future<EMMessage> resendMessage(EMMessage message) async {
    message.status = MessageStatus.PROGRESS;
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.resendMessage, message.toJson());
    try {
      EMError.hasErrorFromResult(result);
      EMMessage msg = EMMessage.fromJson(result[ChatMethodKeys.resendMessage]);
      message.from = msg.from;
      message.to = msg.to;
      message.status = msg.status;
      return message;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Sends the read receipt to the server.
  ///
  /// This method applies to one-to-one chats only.
  ///
  /// Precondition: set {@link EMOptions#requireAck(bool)}.
  ///
  /// Reference:
  /// To send the group message read receipt, call {@link #sendGroupMessageReadAck(String, String, String)}.
  ///
  /// We recommend that you call {@link #sendConversationReadAck(String)} when entering a chat page, and call this method in other cases to reduce the number of method calls.
  ///
  /// Param [message] The message.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<bool> sendMessageReadAck(EMMessage message) async {
    Map req = {"to": message.from, "msg_id": message.msgId};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.ackMessageRead, req);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.ackMessageRead);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Sends the group message receipt to the server.
  ///
  /// You can only call the method after setting the following method: {@link EMOptions#requireAck(bool)} and {@link EMMessage#needGroupAck(bool)}.
  ///
  /// Reference:
  /// To send the one-to-one chat message receipt to server, call {@link #sendMessageReadAck(EMMessage)};
  /// To send the conversation receipt to the server, call {@link #sendConversationReadAck(String)}.
  ///
  /// Param [msgId] The message ID.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [content] The extension information. Developer self-defined command string that can be used for specifying custom action/command.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<bool> sendGroupMessageReadAck(
    String msgId,
    String groupId, {
    String? content,
  }) async {
    Map req = {
      "msg_id": msgId,
      "group_id": groupId,
    };
    if (content != null) {
      req["content"] = content;
    }
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.ackGroupMessageRead, req);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.ackMessageRead);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Sends the conversation read receipt to the server. This method is only for one-to-one chat conversation.
  ///
  /// This method will inform the sever to set the unread message count of the conversation to 0, and conversation list (with multiple devices) will receive
  /// a callback method from {@link EMChatManagerListener#onConversationRead(String, String)}.
  ///
  /// Reference：
  /// To send the group message read receipt, call {@link #sendGroupMessageReadAck(String, String, String)}.
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<bool> sendConversationReadAck(String conversationId) async {
    Map req = {"con_id": conversationId};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.ackConversationRead, req);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.ackConversationRead);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Recalls the sent message.
  ///
  /// Param [messageId] The message id.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<bool> recallMessage(String messageId) async {
    Map req = {"msg_id": messageId};
    Map result = await _channel.invokeMethod(ChatMethodKeys.recallMessage, req);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.recallMessage);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Fetches message for local database by message ID.
  ///
  /// Param [messageId] The message ID.
  ///
  /// **return** The message object obtained by the specified ID. Returns null if the message doesn't exist.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<EMMessage?> loadMessage(String messageId) async {
    Map req = {"msg_id": messageId};
    Map<String, dynamic> result =
        await _channel.invokeMethod(ChatMethodKeys.getMessage, req);
    try {
      EMError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.getMessage)) {
        return EMMessage.fromJson(result[ChatMethodKeys.getMessage]);
      } else {
        return null;
      }
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the conversation by conversation ID and conversation type.
  ///
  /// The SDK wil return null if the conversation is not found.
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// Param [type] The conversation type, see {@link EMConversationType}.
  ///
  /// Param [createIfNeed] Whether to create a conversation if not find the specified conversation.
  ///
  /// `true` (default) means create one.
  /// `false` means not.
  ///
  /// **return** The conversation object found according to the ID and type. Returns null if the conversation is not found.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<EMConversation?> getConversation(
    String conversationId, [
    EMConversationType type = EMConversationType.Chat,
    bool createIfNeed = true,
  ]) async {
    Map req = {
      "con_id": conversationId,
      "type": conversationTypeToInt(type),
      "createIfNeed": createIfNeed
    };
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.getConversation, req);
    try {
      EMError.hasErrorFromResult(result);
      EMConversation? ret;
      if (result[ChatMethodKeys.getConversation] != null) {
        ret = EMConversation.fromJson(result[ChatMethodKeys.getConversation]);
      }
      return ret;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// Marks all messages as read.
  ///
  /// This method is for the local conversations only.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> markAllConversationsAsRead() async {
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.markAllChatMsgAsRead);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the unread message count.
  ///
  /// **return** The count of unread messages.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<int> getUnreadMessageCount() async {
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.getUnreadMessageCount);
    try {
      int ret = 0;
      EMError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.getUnreadMessageCount)) {
        ret = result[ChatMethodKeys.getUnreadMessageCount] as int;
      }
      return ret;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Updates the local message.
  ///
  /// Will update the memory and the local database at the same time.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> updateMessage(EMMessage message) async {
    Map req = {"message": message.toJson()};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.updateChatMessage, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Imports messages to the local database.
  ///
  /// Make sure the message's sender or receiver is the current user before option.
  ///
  /// Recommends import less than 1,000 messages per operation.
  ///
  /// Param [messages] The message list.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> importMessages(List<EMMessage> messages) async {
    List<Map> list = [];
    messages.forEach((element) {
      list.add(element.toJson());
    });
    Map req = {"messages": list};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.importMessages, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Downloads the attachment files from the server.
  ///
  /// You can call the method again if the attachment download fails.
  ///
  /// Param [message] The message to be download the attachment.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> downloadAttachment(EMMessage message) async {
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.downloadAttachment, {"message": message.toJson()});
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Downloads the thumbnail if the msg is not downloaded before or the download failed.
  ///
  /// Param [message] The message object.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> downloadThumbnail(EMMessage message) async {
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.downloadThumbnail, {"message": message.toJson()});
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets all conversations from the local database.
  ///
  /// Conversations will be loaded from memory first, if no conversation is found then the SDk loads from the local database.
  ///
  /// **return** Returns all the conversations from the memory or local database.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<List<EMConversation>> loadAllConversations() async {
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.loadAllConversations);
    try {
      EMError.hasErrorFromResult(result);
      List<EMConversation> conversationList = [];
      result[ChatMethodKeys.loadAllConversations]?.forEach((element) {
        conversationList.add(EMConversation.fromJson(element));
      });
      return conversationList;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Fetches the conversation list from the server.
  ///
  /// The default maximum return is 100.
  ///
  /// **return** Returns the conversation list of the current user.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<List<EMConversation>> getConversationsFromServer() async {
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.getConversationsFromServer);
    try {
      EMError.hasErrorFromResult(result);
      List<EMConversation> conversationList = [];
      result[ChatMethodKeys.getConversationsFromServer]?.forEach((element) {
        conversationList.add(EMConversation.fromJson(element));
      });
      return conversationList;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Deletes conversation and messages from the local database.
  ///
  /// If you set `deleteMessages` to `true`, delete the local chat history when delete the conversation.
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// Param [deleteMessages] Whether to delete the chat history when delete the conversation.
  ///
  /// `true`: (default) means delete the chat history when delete the conversation.
  /// `false`: means not.
  ///
  /// **return** The result of deleting. `True` means success, `false` means failure.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<bool> deleteConversation(
    String conversationId, [
    bool deleteMessages = true,
  ]) async {
    Map req = {"con_id": conversationId, "deleteMessages": deleteMessages};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.deleteConversation, req);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.deleteConversation);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Adds the message listener.
  ///
  /// Receives new messages and so on can set the method to listen, see {@link EMChatManagerListener}.
  ///
  /// Param [listener] The message listener which is used to listen the incoming messages, see {@link EMChatManagerListener}
  ///
  void addChatManagerListener(EMChatManagerListener listener) {
    _messageListeners.add(listener);
  }

  ///
  /// Removes the message listener.
  ///
  /// You should call this method after set {@link #addMessageListener(addChatManagerListener)} .
  ///
  /// Param [listener] The message listener to be removed.
  ///
  void removeChatManagerListener(EMChatManagerListener listener) {
    if (_messageListeners.contains(listener)) {
      _messageListeners.remove(listener);
    }
  }

  ///
  /// Fetches history messages of the conversation from the server.
  ///
  /// Fetches by page.
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// Param [type] The conversation type which select to fetch roam message, see {@link EMConversationType}
  ///
  /// Param [pageSize] The number of records per page.
  ///
  /// Param [startMsgId] The start search roam message, if the param is empty, fetches from the server latest message.
  ///
  /// **return** Returns the messages and the cursor for next fetch action.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<EMCursorResult<EMMessage?>> fetchHistoryMessages(
    String conversationId, {
    EMConversationType type = EMConversationType.Chat,
    int pageSize = 20,
    String startMsgId = '',
  }) async {
    Map req = Map();
    req['con_id'] = conversationId;
    req['type'] = conversationTypeToInt(type);
    req['pageSize'] = pageSize;
    req['startMsgId'] = startMsgId;
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.fetchHistoryMessages, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMCursorResult<EMMessage?>.fromJson(
          result[ChatMethodKeys.fetchHistoryMessages],
          dataItemCallback: (value) {
        return EMMessage.fromJson(value);
      });
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Searches messages from the database according to the parameters.
  ///
  /// Note: Cautious about the memory usage when the maxCount is large, currently the limited number is 400 entries at a time.
  ///
  /// Param [keywords] The keywords in message.
  ///
  /// Param [timeStamp] The timestamp for search, Unix timestamp, in milliseconds.
  ///
  /// Param [maxCount] The max number of message to search at a time.
  ///
  /// Param [from] A user ID or a group ID searches for messages, usually refers to the conversation ID.
  ///
  /// **return** The list of messages.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<List<EMMessage>> searchMsgFromDB(
    String keywords, {
    int timeStamp = -1,
    int maxCount = 20,
    String from = '',
    EMSearchDirection direction = EMSearchDirection.Up,
  }) async {
    Map req = Map();
    req['keywords'] = keywords;
    req['timeStamp'] = timeStamp;
    req['maxCount'] = maxCount;
    req['from'] = from;
    req['direction'] = direction == EMSearchDirection.Up ? "up" : "down";

    Map result =
        await _channel.invokeMethod(ChatMethodKeys.searchChatMsgFromDB, req);
    try {
      EMError.hasErrorFromResult(result);
      List<EMMessage> list = [];
      result[ChatMethodKeys.searchChatMsgFromDB]?.forEach((element) {
        list.add(EMMessage.fromJson(element));
      });
      return list;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Fetches the ack details for group messages from server.
  ///
  /// Fetches by page.
  ///
  /// Reference:
  /// If you want to send group message receipt, see {@link {@link #sendConversationReadAck(String)}.
  ///
  /// Param [msgId] The message ID.
  ///
  /// Param [startAckId] The start ID for fetch receipts, can be null. If you set it as null, the SDK will start from the server's latest receipt.
  ///
  /// Param [pageSize] The number of records per page.
  ///
  /// **return** The group acks cursor result.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<EMCursorResult<EMGroupMessageAck?>> fetchGroupAcks(
    String msgId, {
    String? startAckId,
    int pageSize = 0,
  }) async {
    Map req = Map();
    req["msg_id"] = msgId;
    if (startAckId != null) {
      req["ack_id"] = startAckId;
    }
    req["pageSize"] = pageSize;

    Map result =
        await _channel.invokeMethod(ChatMethodKeys.asyncFetchGroupAcks, req);

    try {
      EMError.hasErrorFromResult(result);
      EMCursorResult<EMGroupMessageAck?> cursorResult = EMCursorResult.fromJson(
        result[ChatMethodKeys.asyncFetchGroupAcks],
        dataItemCallback: (map) {
          return EMGroupMessageAck.fromJson(map);
        },
      );

      return cursorResult;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Deletes the conversation of a specified ID and it's chat records on the server.
  ///
  /// Param [conversationId] Conversation ID.
  ///
  /// Param [conversationType] Conversation type  {@link EMConversationType}
  ///
  /// Param [isDeleteMessage] Whether to delete the server chat records when delete conversation.
  ///
  /// `true`:(default) means to delete the chat history when delete the conversation;
  /// `false`: means not.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> deleteRemoteConversation(
    String conversationId, {
    EMConversationType conversationType = EMConversationType.Chat,
    bool isDeleteMessage = true,
  }) async {
    Map req = {};
    req["conversationId"] = conversationId;
    if (conversationType == EMConversationType.Chat) {
      req["conversationType"] = 0;
    } else if (conversationType == EMConversationType.GroupChat) {
      req["conversationType"] = 1;
    } else {
      req["conversationType"] = 2;
    }
    req["isDeleteRemoteMessage"] = isDeleteMessage;

    Map data = await _channel.invokeMethod(
        ChatMethodKeys.deleteRemoteConversation, req);

    EMError.hasErrorFromResult(data);
  }

  Future<void> _onMessagesReceived(List messages) async {
    List<EMMessage> messageList = [];
    for (var message in messages) {
      messageList.add(EMMessage.fromJson(message));
    }
    for (var listener in _messageListeners) {
      listener.onMessagesReceived(messageList);
    }
  }

  Future<void> _onCmdMessagesReceived(List messages) async {
    List<EMMessage> list = [];
    for (var message in messages) {
      list.add(EMMessage.fromJson(message));
    }
    for (var listener in _messageListeners) {
      listener.onCmdMessagesReceived(list);
    }
  }

  Future<void> _onMessagesRead(List messages) async {
    List<EMMessage> list = [];
    for (var message in messages) {
      list.add(EMMessage.fromJson(message));
    }
    for (var listener in _messageListeners) {
      listener.onMessagesRead(list);
    }
  }

  Future<void> _onGroupMessageRead(List messages) async {
    List<EMGroupMessageAck> list = [];
    for (var message in messages) {
      list.add(EMGroupMessageAck.fromJson(message));
    }
    for (var listener in _messageListeners) {
      listener.onGroupMessageRead(list);
    }
  }

  Future<void> _onMessagesDelivered(List messages) async {
    List<EMMessage> list = [];
    for (var message in messages) {
      list.add(EMMessage.fromJson(message));
    }
    for (var listener in _messageListeners) {
      listener.onMessagesDelivered(list);
    }
  }

  Future<void> _onMessagesRecalled(List messages) async {
    List<EMMessage> list = [];
    for (var message in messages) {
      list.add(EMMessage.fromJson(message));
    }
    for (var listener in _messageListeners) {
      listener.onMessagesRecalled(list);
    }
  }

  Future<void> _onConversationsUpdate(dynamic obj) async {
    for (var listener in _messageListeners) {
      listener.onConversationsUpdate();
    }
  }

  Future<void> _onConversationHasRead(dynamic obj) async {
    for (var listener in _messageListeners) {
      String from = (obj as Map)['from'];
      String to = obj['to'];
      listener.onConversationRead(from, to);
    }
  }
}
