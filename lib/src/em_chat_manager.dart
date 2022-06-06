import "dart:async";

import 'package:flutter/services.dart';

import 'internal/em_channel_manager.dart' show EMMethodChannel;
import 'internal/em_transform_tools.dart';

import 'tools/em_extension.dart';
import '../im_flutter_sdk.dart';
import 'internal/chat_method_keys.dart';

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
  final List<EMChatManagerListener> _messageListeners = [];

  /// @nodoc
  EMChatManager() {
    EMMethodChannel.ChatManager.setMethodCallHandler((MethodCall call) async {
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
  /// Sends a message.
  ///
  /// **Note**
  /// For attachment messages such as voice, image, or video messages, the SDK automatically uploads the attachment.
  /// You can set whether to upload the attachment to the chat sever using {@link EMOptions#serverTransfer(boolean)}.
  ///
  /// To listen for the status of sending messages, call {@link EMMessage#setMessageStatusListener(EMMessageStatusListener)}.
  ///
  /// Param [message] The message object to be sent: {@link EMMessage}.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<EMMessage> sendMessage(EMMessage message) async {
    message.status = MessageStatus.PROGRESS;
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
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
  /// Resends a message.
  ///
  /// Param [message] The message object to be resent: {@link EMMessage}.
  ///
  Future<EMMessage> resendMessage(EMMessage message) async {
    message.status = MessageStatus.PROGRESS;
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
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
  /// This method only takes effect if you set {@link EMOptions#requireAck(bool)} as `true`.
  ///
  /// **Note**
  /// To send the group message read receipt, call {@link #sendGroupMessageReadAck(String, String, String)}.
  ///
  /// We recommend that you call {@link #sendConversationReadAck(String)} when entering a chat page, and call this method to reduce the number of method calls.
  ///
  /// Param [message] The message body: {@link EMMessage}.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<bool> sendMessageReadAck(EMMessage message) async {
    Map req = {"to": message.from, "msg_id": message.msgId};
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.ackMessageRead, req);
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
  /// You can call the method only after setting the following method: {@link EMOptions#requireAck(bool)} and {@link EMMessage#needGroupAck(bool)}.
  ///
  /// **Note**
  /// - This method takes effect only after you set {@link EMOptions#requireAck} and {@link EMMessage#needGroupAck} as `true`.
  /// - This method applies to group messages only. To send a one-to-one chat message receipt, call `sendMessageReadAck`; to send a conversation receipt, call `sendConversationReadAck`.
  ///
  ///
  /// Param [msgId] The message ID.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [content] The extension information, which is a custom keyword that specifies a custom action or command.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.ackGroupMessageRead, req);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.ackMessageRead);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Sends the conversation read receipt to the server. This method is only for one-to-one chat conversations.
  ///
  /// This method informs the server to set the unread message count of the conversation to 0. In multi-device scenarios, all the devices receive the {@link EMChatManagerListener#onConversationRead(String, String)} callback.
  ///
  /// **Note**
  /// This method applies to one-to-one chat conversations only. To send a group message read receipt, call `sendGroupMessageReadAck`.
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<bool> sendConversationReadAck(String conversationId) async {
    Map req = {"con_id": conversationId};
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.ackConversationRead, req);
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
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> recallMessage(String messageId) async {
    Map req = {"msg_id": messageId};
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.recallMessage, req);
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
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<EMMessage?> loadMessage(String messageId) async {
    Map req = {"msg_id": messageId};
    Map<String, dynamic> result =
        await EMMethodChannel.ChatManager.invokeMethod(
            ChatMethodKeys.getMessage, req);
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
  /// Param [type] The conversation type: {@link EMConversationType}.
  ///
  /// Param [createIfNeed] Whether to create a conversation is the specified conversation is not found:
  /// - `true`: Yes.
  /// - `false`: No.
  ///
  /// **Return** The conversation object found according to the ID and type. Returns null if the conversation is not found.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.getConversation, req);
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
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> markAllConversationsAsRead() async {
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.markAllChatMsgAsRead);
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
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<int> getUnreadMessageCount() async {
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.getUnreadMessageCount);
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
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> updateMessage(EMMessage message) async {
    Map req = {"message": message.toJson()};
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.updateChatMessage, req);
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
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> importMessages(List<EMMessage> messages) async {
    List<Map> list = [];
    messages.forEach((element) {
      list.add(element.toJson());
    });
    Map req = {"messages": list};
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.importMessages, req);
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
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> downloadAttachment(EMMessage message) async {
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
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
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> downloadThumbnail(EMMessage message) async {
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
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
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<List<EMConversation>> loadAllConversations() async {
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.loadAllConversations);
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
  /// To use this function, you need to contact our business manager to activate it. After this function is activated, users can pull 10 conversations within 7 days by default (each convesation contains the latest historical message). If you want to adjust the number of conversations or time limit, please contact our business manager.
  ///
  /// **Return** The conversation list of the current user.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<List<EMConversation>> getConversationsFromServer() async {
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
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
  /// If you set `deleteMessages` to `true`, the local historical messages are deleted when the conversation is deleted.
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
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<bool> deleteConversation(
    String conversationId, [
    bool deleteMessages = true,
  ]) async {
    Map req = {"con_id": conversationId, "deleteMessages": deleteMessages};
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.deleteConversation, req);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.deleteConversation);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Adds the message listener. After calling this method, you can listen for new messages when they arrive.
  ///
  /// Param [listener] The message listener that listens for new messages. See {@link EMChatManagerListener}.
  ///
  void addChatManagerListener(EMChatManagerListener listener) {
    _messageListeners.add(listener);
  }

  ///
  /// Removes the message listener.
  ///
  /// After adding a chat manager listener, you can remove this listener if you do not want to listen for it.
  ///
  /// Param [listener] The message listener to be removed. See {@link EMChatManagerListener}.
  ///
  void removeChatManagerListener(EMChatManagerListener listener) {
    if (_messageListeners.contains(listener)) {
      _messageListeners.remove(listener);
    }
  }

  ///
  /// Gets historical messages of the conversation from the server with pagination.
  ///
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// Param [type] The conversation type. See {@link EMConversationType}.
  ///
  /// Param [pageSize] The number of messages per page.
  ///
  /// Param [startMsgId] The ID of the message from which you start to get the historical messages. If `null` is passed, the SDK gets messages in reverse chronological order.
  ///
  /// **Return** The obtained messages and the cursor for the next fetch action.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<EMCursorResult<EMMessage?>> fetchHistoryMessages({
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
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.fetchHistoryMessages, req);
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
  /// Retrieves messages from the database according to the parameters.
  ///
  /// **Note**
  /// Pay attention to the memory usage when the maxCount is large. Currently, a maximum of 400 historical messages can be retrieved each time.
  ///
  /// Param [keywords] The keywords in message.
  ///
  /// Param [timeStamp] The Unix timestamp for search, in milliseconds.
  ///
  /// Param [maxCount] The maximum number of messages to retrieve each time.
  ///
  /// Param [from] A username or group ID at which the retrieval is targeted.  Usually, it is the conversation ID.
  ///
  /// **Return** The list of messages.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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

    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.searchChatMsgFromDB, req);
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
  /// For how to send read receipts for group messages, see {@link {@link #sendConversationReadAck(String)}.
  ///
  /// Param [msgId] The message ID.
  ///
  /// Param [startAckId] The starting read receipt ID for query. If you set it as null, the SDK retrieves the read receipts in the in reverse chronological order.
  ///
  /// Param [pageSize] The number of read receipts per page.
  ///
  /// **Return** The list of obtained read receipts and the cursor for next query.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<EMCursorResult<EMGroupMessageAck?>> fetchGroupAcks(
    String msgId,
    String groupId, {
    String? startAckId,
    int pageSize = 0,
  }) async {
    Map req = {"msg_id": msgId, "group_id": groupId};
    req.setValueWithOutNull("ack_id", startAckId);
    req["pageSize"] = pageSize;

    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.asyncFetchGroupAcks, req);

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
  /// Deletes the specified conversation and the related historical messages from the server.
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// Param [conversationType] The conversation type. See  {@link EMConversationType}.
  ///
  /// Param [isDeleteMessage] Whether to delete the chat history when deleting the conversation.
  /// - `true`: (default) Yes.
  /// - `false`: No.
  ///
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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

    Map data = await EMMethodChannel.ChatManager.invokeMethod(
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

  Future<void> _onReadAckForGroupMessageUpdated(List messages) async {
    for (var listener in _messageListeners) {
      listener.onReadAckForGroupMessageUpdated();
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

  Future<void> _messageReactionDidChange(dynamic obj) async {
    for (var listener in _messageListeners) {
      String from = (obj as Map)['from'];
      String to = obj['to'];
      listener.onConversationRead(from, to);
    }
  }
}

extension EMThreadPlugin on EMChatManager {}
