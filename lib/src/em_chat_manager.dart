// ignore_for_file: deprecated_member_use_from_same_package

import "dart:async";

import 'package:flutter/services.dart';
import 'internal/inner_headers.dart';

///
/// The chat manager class, responsible for sending and receiving messages, loading and deleting conversations, and downloading attachments.
///
/// The sample code for sending a text message:
///
/// ```dart
///    EMMessage msg = EMMessage.createTxtSendMessage(
///        username: toChatUsername, content: content);
///    await EMClient.getInstance.chatManager.sendMessage(msg);
/// ```
///
class EMChatManager {
  final Map<String, EMChatEventHandler> _eventHandlesMap = {};

  final List<EMChatManagerListener> _listeners = [];

  /// @nodoc
  EMChatManager() {
    ChatChannel.setMethodCallHandler((MethodCall call) async {
      if (call.method == ChatMethodKeys.onMessagesReceived) {
        return _onMessagesReceived(call.arguments);
      } else if (call.method == ChatMethodKeys.onCmdMessagesReceived) {
        return _onCmdMessagesReceived(call.arguments);
      } else if (call.method == ChatMethodKeys.onMessagesRead) {
        return _onMessagesRead(call.arguments);
      } else if (call.method == ChatMethodKeys.onGroupMessageRead) {
        return _onGroupMessageRead(call.arguments);
      } else if (call.method ==
          ChatMethodKeys.onReadAckForGroupMessageUpdated) {
        return _onReadAckForGroupMessageUpdated(call.arguments);
      } else if (call.method == ChatMethodKeys.onMessagesDelivered) {
        return _onMessagesDelivered(call.arguments);
      } else if (call.method == ChatMethodKeys.onMessagesRecalled) {
        return _onMessagesRecalled(call.arguments);
      } else if (call.method == ChatMethodKeys.onConversationUpdate) {
        return _onConversationsUpdate(call.arguments);
      } else if (call.method == ChatMethodKeys.onConversationHasRead) {
        return _onConversationHasRead(call.arguments);
      } else if (call.method == ChatMethodKeys.onMessageReactionDidChange) {
        return _messageReactionDidChange(call.arguments);
      }
      return null;
    });
  }

  ///
  /// Adds the chat event handler. After calling this method, you can handle for chat event when they arrive.
  ///
  /// Param [identifier] The custom handler identifier, is used to find the corresponding handler.
  ///
  /// Param [handler] The handler for chat event. See [EMChatEventHandler].
  ///
  void addEventHandler(
    String identifier,
    EMChatEventHandler handler,
  ) {
    _eventHandlesMap[identifier] = handler;
  }

  ///
  /// Remove the chat event handler.
  ///
  /// Param [identifier] The custom handler identifier.
  ///
  void removeEventHandler(String identifier) {
    _eventHandlesMap.remove(identifier);
  }

  ///
  /// Get the chat event handler.
  ///
  /// Param [identifier] The custom handler identifier.
  ///
  /// **Return** The chat event handler.
  ///
  EMChatEventHandler? getEventHandler(String identifier) {
    return _eventHandlesMap[identifier];
  }

  ///
  /// Clear all chat event handlers.
  ///
  void clearEventHandlers() {
    _eventHandlesMap.clear();
  }

  ///
  /// Sends a message.
  ///
  /// **Note**
  /// For attachment messages such as voice, image, or video messages, the SDK automatically uploads the attachment.
  /// You can set whether to upload the attachment to the chat sever using [EMOptions.serverTransfer].
  ///
  /// To listen for the status of sending messages, call [EMChatManager.addMessageEvent].
  ///
  /// Param [message] The message object to be sent: [EMMessage].
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<EMMessage> sendMessage(
    EMMessage message, {
    void Function(
      void Function(EMMessage)? onSuccess,
      void Function(EMMessage)? onError,
      void Function(int)? onProgress,
    )?
        callback,
  }) async {
    message.status = MessageStatus.PROGRESS;
    Map result = await ChatChannel.invokeMethod(
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

  ///
  /// Resend a message.
  ///
  /// Param [message] The message object to be resent: [EMMessage].
  ///
  Future<EMMessage> resendMessage(EMMessage message) async {
    message.status = MessageStatus.PROGRESS;
    Map result = await ChatChannel.invokeMethod(
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
  /// **Warning**
  /// This method only takes effect if you set [EMOptions.requireAck] as `true`.
  ///
  /// **Note**
  /// To send the group message read receipt, call [sendGroupMessageReadAck].
  ///
  /// We recommend that you call [sendConversationReadAck] when entering a chat page, and call this method to reduce the number of method calls.
  ///
  /// Param [message] The message body: [EMMessage].
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<bool> sendMessageReadAck(EMMessage message) async {
    Map req = {"to": message.from, "msg_id": message.msgId};
    Map result =
        await ChatChannel.invokeMethod(ChatMethodKeys.ackMessageRead, req);
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
  /// You can call the method only after setting the following method: [EMOptions.requireAck] and [EMMessage.needGroupAck].
  ///
  /// **Note**
  /// - This method takes effect only after you set [EMOptions.requireAck] and [EMMessage.needGroupAck] as `true`.
  /// - This method applies to group messages only. To send a one-to-one chat message receipt, call [sendMessageReadAck]; to send a conversation receipt, call [sendConversationReadAck].
  ///
  ///
  /// Param [msgId] The message ID.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [content] The extension information, which is a custom keyword that specifies a custom action or command.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<void> sendGroupMessageReadAck(
    String msgId,
    String groupId, {
    String? content,
  }) async {
    Map req = {
      "msg_id": msgId,
      "group_id": groupId,
    };
    req.add("content", content);

    Map result =
        await ChatChannel.invokeMethod(ChatMethodKeys.ackGroupMessageRead, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Sends the conversation read receipt to the server. This method is only for one-to-one chat conversations.
  ///
  /// This method informs the server to set the unread message count of the conversation to 0. In multi-device scenarios, all the devices receive the [EMChatEventHandler.onConversationRead] callback.
  ///
  /// **Note**
  /// This method applies to one-to-one chat conversations only. To send a group message read receipt, call [sendGroupMessageReadAck].
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<bool> sendConversationReadAck(String conversationId) async {
    Map req = {"con_id": conversationId};
    Map result =
        await ChatChannel.invokeMethod(ChatMethodKeys.ackConversationRead, req);
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
  /// Param [messageId] The message ID.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<void> recallMessage(String messageId) async {
    Map req = {"msg_id": messageId};
    Map result =
        await ChatChannel.invokeMethod(ChatMethodKeys.recallMessage, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Loads a message from the local database by message ID.
  ///
  /// Param [messageId] The message ID.
  ///
  /// **Return** The message object specified by the message ID. Returns null if the message does not exist.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<EMMessage?> loadMessage(String messageId) async {
    Map req = {"msg_id": messageId};
    Map<String, dynamic> result =
        await ChatChannel.invokeMethod(ChatMethodKeys.getMessage, req);
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
  /// Param [conversationId] The conversation ID.
  ///
  /// Param [type] The conversation type: [EMConversationType].
  ///
  /// Param [createIfNeed] Whether to create a conversation is the specified conversation is not found:
  /// - `true`: Yes.
  /// - `false`: No.
  ///
  /// **Return** The conversation object found according to the ID and type. Returns null if the conversation is not found.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<EMConversation?> getConversation(
    String conversationId, {
    EMConversationType type = EMConversationType.Chat,
    bool createIfNeed = true,
  }) async {
    Map req = {
      "con_id": conversationId,
      "type": conversationTypeToInt(type),
      "createIfNeed": createIfNeed
    };
    Map result =
        await ChatChannel.invokeMethod(ChatMethodKeys.getConversation, req);
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

  ///
  /// Gets the thread conversation by thread ID.
  ///
  /// Param [threadId] The thread ID.
  ///
  /// **Return** The conversation object.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<EMConversation> getThreadConversation(String threadId) async {
    Map result = await ChatChannel.invokeMethod(
      ChatMethodKeys.getThreadConversation,
      {"con_id", threadId},
    );

    try {
      EMError.hasErrorFromResult(result);
      return EMConversation.fromJson(
          result[ChatMethodKeys.getThreadConversation]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// Marks all messages as read.
  ///
  /// This method is for the local conversations only.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<void> markAllConversationsAsRead() async {
    Map result =
        await ChatChannel.invokeMethod(ChatMethodKeys.markAllChatMsgAsRead);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the count of the unread messages.
  ///
  /// **Return** The count of the unread messages.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<int> getUnreadMessageCount() async {
    Map result =
        await ChatChannel.invokeMethod(ChatMethodKeys.getUnreadMessageCount);
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
  /// The message will be updated both in the cache and local database.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<void> updateMessage(EMMessage message) async {
    Map req = {"message": message.toJson()};
    Map result =
        await ChatChannel.invokeMethod(ChatMethodKeys.updateChatMessage, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Imports messages to the local database.
  ///
  /// Before importing, ensure that the sender or receiver of the message is the current user.
  ///
  /// For each method call, we recommends to import less than 1,000 messages.
  ///
  /// Param [messages] The message list.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<void> importMessages(List<EMMessage> messages) async {
    List<Map> list = [];
    messages.forEach((element) {
      list.add(element.toJson());
    });
    Map req = {"messages": list};
    Map result =
        await ChatChannel.invokeMethod(ChatMethodKeys.importMessages, req);
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
  /// Param [message] The message with the attachment that is to be downloaded.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<void> downloadAttachment(EMMessage message) async {
    Map result = await ChatChannel.invokeMethod(
        ChatMethodKeys.downloadAttachment, {"message": message.toJson()});
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Downloads the thumbnail if the message has not been downloaded before or if the download fails.
  ///
  /// Param [message] The message object.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<void> downloadThumbnail(EMMessage message) async {
    Map result = await ChatChannel.invokeMethod(
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
  /// Conversations will be first loaded from the cache. If no conversation is found, the SDK loads from the local database.
  ///
  /// **Return** All the conversations from the cache or local database.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<List<EMConversation>> loadAllConversations() async {
    Map result =
        await ChatChannel.invokeMethod(ChatMethodKeys.loadAllConversations);
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
  /// Gets the conversation list from the server.
  ///
  /// To use this function, you need to contact our business manager to activate it. After this function is activated, users can pull 10 conversations within 7 days by default (each conversation contains the latest historical message). If you want to adjust the number of conversations or time limit, please contact our business manager.
  ///
  /// **Return** The conversation list of the current user.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<List<EMConversation>> getConversationsFromServer() async {
    Map result = await ChatChannel.invokeMethod(
        ChatMethodKeys.getConversationsFromServer);
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
  /// Deletes a conversation and its related messages from the local database.
  ///
  /// If you set [deleteMessages] to `true`, the local historical messages are deleted when the conversation is deleted.
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// Param [deleteMessages] Whether to delete the historical messages when deleting the conversation.
  /// - `true`: (default) Yes.
  /// - `false`: No.
  ///
  /// **Return** Whether the conversation is successfully deleted.
  /// - `true`: Yes;
  /// - `false`: No.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<bool> deleteConversation(
    String conversationId, {
    bool deleteMessages = true,
  }) async {
    Map req = {"con_id": conversationId, "deleteMessages": deleteMessages};
    Map result =
        await ChatChannel.invokeMethod(ChatMethodKeys.deleteConversation, req);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.deleteConversation);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets historical messages of the conversation from the server with pagination.
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// Param [type] The conversation type. See [EMConversationType].
  ///
  /// Param [pageSize] The number of messages per page.
  ///
  /// Param [startMsgId] The ID of the message from which you start to get the historical messages. If `null` is passed, the SDK gets messages in reverse chronological order.
  ///
  /// **Return** The obtained messages and the cursor for the next fetch action.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<EMCursorResult<EMMessage>> fetchHistoryMessages({
    required String conversationId,
    EMConversationType type = EMConversationType.Chat,
    int pageSize = 20,
    String startMsgId = '',
  }) async {
    Map req = Map();
    req['con_id'] = conversationId;
    req['type'] = conversationTypeToInt(type);
    req['pageSize'] = pageSize;
    req['startMsgId'] = startMsgId;
    Map result = await ChatChannel.invokeMethod(
        ChatMethodKeys.fetchHistoryMessages, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMCursorResult<EMMessage>.fromJson(
          result[ChatMethodKeys.fetchHistoryMessages],
          dataItemCallback: (value) {
        return EMMessage.fromJson(value);
      });
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Retrieves messages from the database according to the parameters.
  ///
  /// **Note**
  /// Pay attention to the memory usage when the maxCount is large. Currently, a maximum of 400 historical messages can be retrieved each time.
  ///
  /// Param [keywords] The keywords in message.
  ///
  /// Param [timestamp] The Unix timestamp for search, in milliseconds.
  ///
  /// Param [maxCount] The maximum number of messages to retrieve each time.
  ///
  /// Param [from] A username or group ID at which the retrieval is targeted.  Usually, it is the conversation ID.
  ///
  /// **Return** The list of messages.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<List<EMMessage>> searchMsgFromDB(
    String keywords, {
    int timestamp = -1,
    int maxCount = 20,
    String from = '',
    EMSearchDirection direction = EMSearchDirection.Up,
  }) async {
    Map req = Map();
    req['keywords'] = keywords;
    req['timestamp'] = timestamp;
    req['maxCount'] = maxCount;
    req['from'] = from;
    req['direction'] = direction == EMSearchDirection.Up ? "up" : "down";

    Map result =
        await ChatChannel.invokeMethod(ChatMethodKeys.searchChatMsgFromDB, req);
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
  /// Gets read receipts for group messages from the server with pagination.
  ///
  /// See also:
  /// For how to send read receipts for group messages, see [sendConversationReadAck].
  ///
  /// Param [msgId] The message ID.
  ///
  /// Param [startAckId] The starting read receipt ID for query. If you set it as null, the SDK retrieves the read receipts in the in reverse chronological order.
  ///
  /// Param [pageSize] The number of read receipts per page.
  ///
  /// **Return** The list of obtained read receipts and the cursor for next query.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<EMCursorResult<EMGroupMessageAck>> fetchGroupAcks(
    String msgId,
    String groupId, {
    String? startAckId,
    int pageSize = 0,
  }) async {
    Map req = {"msg_id": msgId, "group_id": groupId};
    req["pageSize"] = pageSize;
    req.add("ack_id", startAckId);

    Map result =
        await ChatChannel.invokeMethod(ChatMethodKeys.asyncFetchGroupAcks, req);

    try {
      EMError.hasErrorFromResult(result);
      EMCursorResult<EMGroupMessageAck> cursorResult = EMCursorResult.fromJson(
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
  /// Deletes the specified conversation and the related historical messages from the server.
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// Param [conversationType] The conversation type. See  [EMConversationType].
  ///
  /// Param [isDeleteMessage] Whether to delete the chat history when deleting the conversation.
  /// - `true`: (default) Yes.
  /// - `false`: No.
  ///
  ///
  /// **Throws** A description of the exception. See [EMError].
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

    Map data = await ChatChannel.invokeMethod(
        ChatMethodKeys.deleteRemoteConversation, req);
    try {
      EMError.hasErrorFromResult(data);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Deletes messages with timestamp that is before the specified one.
  ///
  /// Param [timestamp]  The specified Unix timestamp(milliseconds).
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<void> deleteMessagesBefore(int timestamp) async {
    Map result = await ChatChannel.invokeMethod(
        ChatMethodKeys.deleteMessagesBeforeTimestamp, {"timestamp": timestamp});
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  Future<void> _onMessagesReceived(List messages) async {
    List<EMMessage> messageList = [];
    for (var message in messages) {
      messageList.add(EMMessage.fromJson(message));
    }

    for (var item in _eventHandlesMap.values) {
      item.onMessagesReceived?.call(messageList);
    }

    // deprecated(3.9.5)
    for (var listener in _listeners) {
      listener.onMessagesReceived(messageList);
    }
  }

  Future<void> _onCmdMessagesReceived(List messages) async {
    List<EMMessage> list = [];
    for (var message in messages) {
      list.add(EMMessage.fromJson(message));
    }

    for (var item in _eventHandlesMap.values) {
      item.onCmdMessagesReceived?.call(list);
    }

    // deprecated(3.9.5)
    for (var listener in _listeners) {
      listener.onCmdMessagesReceived(list);
    }
  }

  Future<void> _onMessagesRead(List messages) async {
    List<EMMessage> list = [];
    for (var message in messages) {
      list.add(EMMessage.fromJson(message));
    }

    for (var item in _eventHandlesMap.values) {
      item.onMessagesRead?.call(list);
    }

    // deprecated(3.9.5)
    for (var listener in _listeners) {
      listener.onMessagesRead(list);
    }
  }

  Future<void> _onGroupMessageRead(List messages) async {
    List<EMGroupMessageAck> list = [];
    for (var message in messages) {
      list.add(EMGroupMessageAck.fromJson(message));
    }

    for (var item in _eventHandlesMap.values) {
      item.onGroupMessageRead?.call(list);
    }

    // deprecated(3.9.5)
    for (var listener in _listeners) {
      listener.onGroupMessageRead(list);
    }
  }

  Future<void> _onReadAckForGroupMessageUpdated(List messages) async {
    for (var item in _eventHandlesMap.values) {
      item.onReadAckForGroupMessageUpdated?.call();
    }

    // deprecated(3.9.5)
    for (var listener in _listeners) {
      listener.onReadAckForGroupMessageUpdated();
    }
  }

  Future<void> _onMessagesDelivered(List messages) async {
    List<EMMessage> list = [];
    for (var message in messages) {
      list.add(EMMessage.fromJson(message));
    }

    for (var item in _eventHandlesMap.values) {
      item.onMessagesDelivered?.call(list);
    }

    // deprecated(3.9.5)
    for (var listener in _listeners) {
      listener.onMessagesDelivered(list);
    }
  }

  Future<void> _onMessagesRecalled(List messages) async {
    List<EMMessage> list = [];
    for (var message in messages) {
      list.add(EMMessage.fromJson(message));
    }

    for (var item in _eventHandlesMap.values) {
      item.onMessagesRecalled?.call(list);
    }

    // deprecated(3.9.5)
    for (var listener in _listeners) {
      listener.onMessagesRecalled(list);
    }
  }

  Future<void> _onConversationsUpdate(dynamic obj) async {
    for (var item in _eventHandlesMap.values) {
      item.onConversationsUpdate?.call();
    }

    // deprecated(3.9.5)
    for (var listener in _listeners) {
      listener.onConversationsUpdate();
    }
  }

  Future<void> _onConversationHasRead(dynamic obj) async {
    String from = (obj as Map)['from'];
    String to = obj['to'];

    for (var item in _eventHandlesMap.values) {
      item.onConversationRead?.call(from, to);
    }

    // deprecated(3.9.5)
    for (var listener in _listeners) {
      listener.onConversationRead(from, to);
    }
  }

  Future<void> _messageReactionDidChange(List reactionChangeList) async {
    List<EMMessageReactionEvent> list = [];
    for (var reactionChange in reactionChangeList) {
      list.add(EMMessageReactionEvent.fromJson(reactionChange));
    }

    for (var item in _eventHandlesMap.values) {
      item.onMessageReactionDidChange?.call(list);
    }

    // deprecated(3.9.5)
    for (var listener in _listeners) {
      listener.onMessageReactionDidChange(list);
    }
  }

  ///
  /// Report violation message
  ///
  /// Param [messageId] Violation Message ID
  ///
  /// Param [tag] The report type (For example: involving pornography and terrorism).
  ///
  /// Param [reason] The reason for reporting.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<void> reportMessage({
    required String messageId,
    required String tag,
    required String reason,
  }) async {
    Map req = {"msgId": messageId, "tag": tag, "reason": reason};
    Map result =
        await ChatChannel.invokeMethod(ChatMethodKeys.reportMessage, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Adds a reaction.
  ///
  /// Param [messageId] The message ID.
  ///
  /// Param [reaction] The reaction content.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<void> addReaction({
    required String messageId,
    required String reaction,
  }) async {
    Map req = {"reaction": reaction, "msgId": messageId};
    Map result =
        await ChatChannel.invokeMethod(ChatMethodKeys.addReaction, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Deletes a reaction.
  ///
  /// Param [messageId] The message ID.
  ///
  /// Param [reaction] The reaction content.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<void> removeReaction({
    required String messageId,
    required String reaction,
  }) async {
    Map req = {"reaction": reaction, "msgId": messageId};
    Map result =
        await ChatChannel.invokeMethod(ChatMethodKeys.removeReaction, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the list of Reactions.
  ///
  /// Param [messageIds] The message IDs.
  ///
  /// Param [chatType] The chat type. Only one-to-one chat [ChatType.Chat] and group chat [ChatType.GroupChat] are allowed.
  ///
  /// Param [groupId] which is invalid only when the chat type is group chat.
  ///
  /// **Return** The Reaction list under the specified message ID（[EMMessageReaction.userList] is the summary data, which only contains the information of the first three users）.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<Map<String, List<EMMessageReaction>>> fetchReactionList({
    required List<String> messageIds,
    required ChatType chatType,
    String? groupId,
  }) async {
    Map req = {
      "msgIds": messageIds,
      "chatType": chatTypeToInt(chatType),
    };
    req.add("groupId", groupId);
    Map result = await ChatChannel.invokeMethod(
      ChatMethodKeys.fetchReactionList,
      req,
    );

    try {
      EMError.hasErrorFromResult(result);
      Map<String, List<EMMessageReaction>> ret = {};
      for (var info in result[ChatMethodKeys.fetchReactionList].entries) {
        List<EMMessageReaction> reactions = [];
        for (var item in info.value) {
          reactions.add(EMMessageReaction.fromJson(item));
        }
        ret[info.key] = reactions;
      }
      return ret;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the reaction details.
  ///
  /// Param [messageId] The message ID.
  ///
  /// Param [reaction] The reaction content.
  ///
  /// Param [cursor] The cursor position from which to get Reactions.
  ///
  /// Param [pageSize] The number of Reactions you expect to get on each page.
  ///
  /// **Return** The result callback, which contains the reaction list obtained from the server and the cursor for the next query. Returns null if all the data is fetched.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<EMCursorResult<EMMessageReaction>> fetchReactionDetail({
    required String messageId,
    required String reaction,
    String? cursor,
    int pageSize = 20,
  }) async {
    Map req = {
      "msgId": messageId,
      "reaction": reaction,
    };
    req.add("cursor", cursor);
    req.add("pageSize", pageSize);
    Map result =
        await ChatChannel.invokeMethod(ChatMethodKeys.fetchReactionDetail, req);

    try {
      EMError.hasErrorFromResult(result);
      return EMCursorResult<EMMessageReaction>.fromJson(
          result[ChatMethodKeys.fetchReactionDetail],
          dataItemCallback: (value) {
        return EMMessageReaction.fromJson(value);
      });
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Translate a message.
  ///
  /// Param [msg] The message object
  ///
  /// Param [languages] The target languages to translate
  ///
  /// **Return** Translated Message
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<EMMessage> translateMessage({
    required EMMessage msg,
    required List<String> languages,
  }) async {
    Map req = {};
    req["message"] = msg.toJson();
    req["languages"] = languages;
    Map result =
        await ChatChannel.invokeMethod(ChatMethodKeys.translateMessage, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMMessage.fromJson(result[ChatMethodKeys.translateMessage]);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Fetch all languages what the translate service support
  ///
  /// **Return** Supported languages
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<List<EMTranslateLanguage>> fetchSupportedLanguages() async {
    Map result =
        await ChatChannel.invokeMethod(ChatMethodKeys.fetchSupportLanguages);
    try {
      EMError.hasErrorFromResult(result);
      List<EMTranslateLanguage> list = [];
      result[ChatMethodKeys.fetchSupportLanguages]?.forEach((element) {
        list.add(EMTranslateLanguage.fromJson(element));
      });
      return list;
    } on EMError catch (e) {
      throw e;
    }
  }

  void addMessageEvent(String identifier, ChatMessageEvent event) {
    MessageCallBackManager.getInstance.addMessageEvent(identifier, event);
  }

  void removeMessageEvent(String identifier) {
    MessageCallBackManager.getInstance.removeMessageEvent(identifier);
  }

  void clearMessageEvent() {
    MessageCallBackManager.getInstance.clearAllMessageEvents();
  }
}

class ChatMessageEvent {
  ChatMessageEvent({
    this.onSuccess,
    this.onError,
    this.onProgress,
  });

  final void Function(String msgId, EMMessage msg)? onSuccess;
  final void Function(String msgId, EMMessage msg, EMError error)? onError;
  final void Function(String msgId, int progress)? onProgress;
}

extension ChatManagerDeprecated on EMChatManager {
  ///
  /// Adds the chat manager listener. After calling this method, you can listen for new messages when they arrive.
  ///
  /// Param [listener] The chat manager listener that listens for new messages. See [EMChatManagerListener].
  ///
  @Deprecated("Use addEventHandler to instead")
  void addChatManagerListener(EMChatManagerListener listener) {
    _listeners.remove(listener);
    _listeners.add(listener);
  }

  ///
  /// Removes the chat manager listener.
  ///
  /// After adding a chat manager listener, you can remove this listener if you do not want to listen for it.
  ///
  /// Param [listener] The chat manager listener to be removed. See [EMChatManagerListener].
  ///
  @Deprecated("Use #removeEventHandler to instead")
  void removeChatManagerListener(EMChatManagerListener listener) {
    _listeners.remove(listener);
  }

  ///
  /// Removes all chat manager listeners.
  ///
  @Deprecated("Use #clearEventHandlers to instead")
  void clearAllChatManagerListeners() {
    _listeners.clear();
  }
}

class MessageCallBackManager {
  static const _channelPrefix = 'com.chat.im';
  static const MethodChannel _emMessageChannel =
      const MethodChannel('$_channelPrefix/chat_message', JSONMethodCodec());
  Map<String, ChatMessageEvent> cacheHandleMap = {};
  static MessageCallBackManager? _instance;
  static MessageCallBackManager get getInstance =>
      _instance = _instance ?? MessageCallBackManager._internal();

  MessageCallBackManager._internal() {
    _emMessageChannel.setMethodCallHandler((MethodCall call) async {
      Map<String, dynamic> argMap = call.arguments;
      String? localId = argMap['localId'];
      if (localId == null) return;
      cacheHandleMap.forEach((key, value) {
        if (call.method == ChatMethodKeys.onMessageProgressUpdate) {
          int progress = argMap["progress"];
          value.onProgress?.call(localId, progress);
        } else if (call.method == ChatMethodKeys.onMessageError) {
          EMMessage msg = EMMessage.fromJson(argMap['message']);
          EMError err = EMError.fromJson(argMap['error']);
          value.onError?.call(localId, msg, err);
        } else if (call.method == ChatMethodKeys.onMessageSuccess) {
          EMMessage msg = EMMessage.fromJson(argMap['message']);
          value.onSuccess?.call(localId, msg);
        }
      });

      return null;
    });
  }

  void addMessageEvent(String key, ChatMessageEvent event) {
    cacheHandleMap[key] = event;
  }

  void removeMessageEvent(String key) {
    if (cacheHandleMap.containsKey(key)) {
      cacheHandleMap.remove(key);
    }
  }

  void clearAllMessageEvents() {
    cacheHandleMap.clear();
  }
}
