// ignore_for_file: deprecated_member_use_from_same_package

import "dart:async";

import 'package:flutter/services.dart';
import 'internal/inner_headers.dart';
import 'models/conversation_fetch_options.dart';
import 'models/fetch_message_options.dart';

/// ~english
/// The chat manager class, responsible for sending and receiving messages, loading and deleting conversations, and downloading attachments.
///
/// The sample code for sending a text message:
///
/// ```dart
///    EMMessage msg = EMMessage.createTxtSendMessage(
///        username: toChatUsername, content: content);
///    await EMClient.getInstance.chatManager.sendMessage(msg);
/// ```
/// ~end
///
/// ~chinese
/// 聊天管理类，该类负责管理会话（加载，删除等）、发送消息、下载消息附件等。
///
/// 比如，发送一条文本消息：
///
/// ```dart
///    EMMessage msg = EMMessage.createTxtSendMessage(
///        targetId: toChatUsername, content: content);
///    await EMClient.getInstance.chatManager.sendMessage(msg);
/// ```
/// ~end
class EMChatManager {
  final Map<String, EMChatEventHandler> _eventHandlesMap = {};

  EMChatManager() {
    ChatChannel.setMethodCallHandler((MethodCall call) async {
      EMLog.d("${call.method}: arguments: ${call.arguments}");
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
      } else if (call.method == ChatMethodKeys.onMessageContentChanged) {
        return _onMessageContentChanged(call.arguments);
      } else if (call.method == ChatMethodKeys.onMessagePinChanged) {
        return _onMessagePinChanged(call.arguments);
      } else if (call.method == ChatMethodKeys.onMessagesRecalledInfo) {
        return _onMessagesRecalledInfo(call.arguments);
      }
      return null;
    });
  }

  /// ~english
  /// Adds the chat event handler. After calling this method, you can handle for chat event when they arrive.
  ///
  /// Param [identifier] The custom handler identifier, is used to find the corresponding handler.
  ///
  /// Param [handler] The handler for chat event. See [EMChatEventHandler].
  /// ~end
  ///
  /// ~chinese
  /// 添加事件监听。
  ///
  /// Param [identifier] 事件监听对应的 ID。
  ///
  /// Param [handler] 事件监听. 请见 [EMChatEventHandler].
  /// ~end
  void addEventHandler(
    String identifier,
    EMChatEventHandler handler,
  ) {
    _eventHandlesMap[identifier] = handler;
  }

  /// ~english
  /// Remove the chat event handler.
  ///
  /// Param [identifier] The custom handler identifier.
  /// ~end
  ///
  /// ~chinese
  /// 移除事件监听。
  ///
  /// Param [identifier] 要移除监听对应的 ID。
  /// ~end
  void removeEventHandler(String identifier) {
    _eventHandlesMap.remove(identifier);
  }

  /// ~english
  /// Get the chat event handler.
  ///
  /// Param [identifier] The custom handler identifier.
  ///
  /// **Return** The chat event handler.
  /// ~end
  ///
  /// ~chinese
  /// 获取事件监听。
  ///
  /// Param [identifier] 要获取监听对应的 ID。
  ///
  /// **Return** 事件监听。
  /// ~end
  EMChatEventHandler? getEventHandler(String identifier) {
    return _eventHandlesMap[identifier];
  }

  /// ~english
  /// Clear all chat event handlers.
  /// ~end
  ///
  /// ~chinese
  /// 清除所有事件监听。
  /// ~end
  void clearEventHandlers() {
    _eventHandlesMap.clear();
  }

  /// ~english
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
  /// ~end
  ///
  /// ~chinese
  /// 发消息
  ///
  /// **Note**
  /// 对于语音、图片、视频等附件消息，SDK会自动上传附件。
  /// 可以使用 [EMOptions.serverTransfer] 设置是否将附件上传到聊天服务器。
  ///
  /// 添加发送状态监听使用 [EMChatManager.addMessageEvent].
  ///
  /// Param [message] 需要发送的消息 [EMMessage].
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<EMMessage> sendMessage(EMMessage message) async {
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

  /// ~english
  /// Resends a message.
  ///
  /// Param [message] The message object to be resent: [EMMessage].
  /// ~end
  ///
  /// ~chinese
  /// 重发消息。
  ///
  /// Param [message] 需要重发的消息。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
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

  /// ~english
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
  /// ~end
  ///
  /// ~chinese
  /// 发送消息的已读回执，该方法只针对单聊会话。
  ///
  /// **Warning**
  /// 该方法只有在 [EMOptions.requireAck] 为 `true` 时才生效。
  ///
  /// **Note**
  /// 群消息已读回执，详见 [sendGroupMessageReadAck]。
  ///
  /// 推荐进入会话页面时调用 [sendConversationReadAck]，其他情况下调用该方法以减少调用频率。
  ///
  /// Param [message] 需要发送已读回执的消息。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
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

  /// ~english
  /// Sends the group message receipt to the server.
  ///
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
  /// ~end
  ///
  /// ~chinese
  /// 发送群消息已读回执。
  ///
  /// **Note**
  /// 1. 使用该方法前，需将 [EMOptions.requireAck] 和 [EMMessage.needGroupAck] 设置为 `true`。
  /// 2. 发送单聊消息已读回执，详见 [sendMessageReadAck]。
  /// 3. 会话已读回执，详见 [sendConversationReadAck]。
  ///
  /// Param [msgId] 消息 ID。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [content] 扩展信息。用户自己定义的关键字，接收后，解析出自定义的字符串，可以自行处理。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<void> sendGroupMessageReadAck(
    String msgId,
    String groupId, {
    String? content,
  }) async {
    Map req = {
      "msg_id": msgId,
      "group_id": groupId,
    };
    req.putIfNotNull("content", content);

    Map result =
        await ChatChannel.invokeMethod(ChatMethodKeys.ackGroupMessageRead, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
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
  /// ~end
  ///
  /// ~chinese
  /// 发送会话的已读回执，该方法只针对单聊会话。
  ///
  /// 该方法会通知服务器将此会话未读数设置为 0，对话方（包含多端多设备）将会在下面这个回调方法中接收到回调：
  /// [EMChatEventHandler.onConversationRead]。
  ///
  /// **Note**
  /// 发送群组消息已读回执见 [sendGroupMessageReadAck]。
  ///
  /// Param [conversationId] 会话 ID。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<void> sendConversationReadAck(String conversationId) async {
    Map req = {"convId": conversationId};
    Map result =
        await ChatChannel.invokeMethod(ChatMethodKeys.ackConversationRead, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Recalls the sent message.
  ///
  /// Param [messageId] The message ID.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 撤回发送成功的消息。
  ///
  /// Param [messageId] 消息 ID。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<void> recallMessage(String messageId, {String? ext}) async {
    Map req = {
      "msg_id": messageId,
    };
    req.putIfNotNull('ext', ext);
    Map result =
        await ChatChannel.invokeMethod(ChatMethodKeys.recallMessage, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Loads a message from the local database by message ID.
  ///
  /// Param [messageId] The message ID.
  ///
  /// **Return** The message object specified by the message ID. Returns null if the message does not exist.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 从本地数据库获取指定 ID 的消息对象。
  ///
  /// Param [messageId] 消息 ID。
  ///
  /// **Return** 根据指定 ID 获取的消息对象，如果消息不存在会返回空值。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
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

  /// ~english
  /// Gets the conversation by conversation ID and conversation type.
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// Param [type] The conversation type: [EMConversationType].
  ///
  /// Param [createIfNeed] Whether to create the conversation if the conversation is not found:
  /// - （Default) `true`: Yes.
  /// - `false`: No.
  ///
  /// **Return** The conversation object found according to the conversation ID and type. The SDK returns null if the conversation is not found.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 根据指定会话 ID 和会话类型获取会话对象。
  ///
  /// 没有找到会返回空值。
  ///
  /// Param [conversationId] 会话 ID。
  ///
  /// Param [type] 会话类型，详见 [EMConversationType]。
  ///
  /// Param [createIfNeed] 没找到相应会话时是否自动创建。
  ///   - （默认）`true` 表示自动创建会话。
  ///   - `false` 表示不创建会话。
  ///
  ///
  /// **Return**  根据指定 ID 以及会话类型找到的会话对象，如果没有找到会返回空值。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<EMConversation?> getConversation(
    String conversationId, {
    EMConversationType type = EMConversationType.Chat,
    bool createIfNeed = true,
  }) async {
    Map req = {
      "convId": conversationId,
      "type": type.index,
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

  /// ~english
  /// Gets the thread conversation by thread ID.
  ///
  /// Param [threadId] The thread ID.
  ///
  /// **Return** The conversation object.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 根据 thread ID 获取 thread 会话。
  ///
  /// Param [threadId] Thread ID.
  ///
  /// **Return** 会话对象.
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<EMConversation?> getThreadConversation(String threadId) async {
    Map result = await ChatChannel.invokeMethod(
      ChatMethodKeys.getThreadConversation,
      {"convId": threadId},
    );

    try {
      EMConversation? ret;
      EMError.hasErrorFromResult(result);
      if (result[ChatMethodKeys.getThreadConversation] != null) {
        ret = EMConversation.fromJson(
            result[ChatMethodKeys.getThreadConversation]);
      }
      return ret;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Marks all conversations as read.
  ///
  /// This method is for the local conversations only.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 把所有的会话都设成已读。
  ///
  /// 这里针对的是本地会话。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<void> markAllConversationsAsRead() async {
    Map result =
        await ChatChannel.invokeMethod(ChatMethodKeys.markAllChatMsgAsRead);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Gets the count of the unread messages.
  ///
  /// **Return** The count of the unread messages.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 获取未读消息数。
  ///
  /// **Return** 未读消息数。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
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

  /// ~english
  /// Updates the local message.
  ///
  /// The message will be updated both in the cache and local database.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 更新本地消息。
  ///
  /// 会同时更新本地内存和数据库。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
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

  /// ~english
  /// Imports messages to the local database.
  ///
  /// Before importing, ensure that the sender or recipient of the message is the current user.
  ///
  /// It is recommended that you import at most 1,000 messages each time.
  ///
  /// Param [messages] The message list.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 将消息导入本地数据库。
  ///
  /// 只能将当前用户发送或接收的消息导入本地数据库。
  /// 已经对函数做过速度优化，推荐一次导入 1,000 条以内的数据。
  ///
  /// Param [messages] 需要导入数据库的消息。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
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

  /// ~english
  /// Downloads the attachment files from the server.
  ///
  /// You can call the method again if the attachment download fails.
  ///
  /// Param [message] The message with the attachment that is to be downloaded.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 下载消息的附件。
  ///
  /// 若附件自动下载失败，也可以调用此方法下载。
  ///
  /// Param [message] 要下载附件的消息。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<void> downloadAttachment(EMMessage message) async {
    Map result = await ChatChannel.invokeMethod(
        ChatMethodKeys.downloadAttachment, {"message": message.toJson()});
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Downloads the thumbnail if the message has not been downloaded before or if the download fails.
  ///
  /// Param [message] The message object.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 下载消息的缩略图。
  ///
  /// Param [message] 要下载缩略图的消息，一般图片消息和视频消息有缩略图。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<void> downloadThumbnail(EMMessage message) async {
    Map result = await ChatChannel.invokeMethod(
        ChatMethodKeys.downloadThumbnail, {"message": message.toJson()});
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Downloads the attachment files from the server.
  ///
  /// You can call the method again if the attachment download fails.
  ///
  /// Param [message] The message with the attachment that is to be downloaded.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 下载消息的附件。
  ///
  /// 若附件自动下载失败，也可以调用此方法下载。
  ///
  /// Param [message] 要下载附件的消息。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<void> downloadMessageAttachmentInCombine(EMMessage message) async {
    Map result = await ChatChannel.invokeMethod(
        ChatMethodKeys.downloadMessageAttachmentInCombine,
        {"message": message.toJson()});
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Downloads the thumbnail if the message has not been downloaded before or if the download fails.
  ///
  /// Param [message] The message object.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 下载消息的缩略图。
  ///
  /// Param [message] 要下载缩略图的消息，一般图片消息和视频消息有缩略图。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<void> downloadMessageThumbnailInCombine(EMMessage message) async {
    Map result = await ChatChannel.invokeMethod(
        ChatMethodKeys.downloadMessageThumbnailInCombine,
        {"message": message.toJson()});
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Gets all conversations from the local database.
  ///
  /// Conversations will be first loaded from the cache. If no conversation is found, the SDK loads from the local database.
  ///
  /// **Return** All the conversations from the cache or local database.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 获取本地数据库中所有会话。
  ///
  /// 会先从内存中获取，如果没有会从本地数据库获取。
  ///
  /// **Return**  返回获取的会话。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
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

  @Deprecated('Use [fetchConversationsByOptions] instead')

  /// ~english
  /// Gets the conversation list from the server.
  ///
  /// **Return** The conversation list of the current user.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取会话列表。
  ///
  /// **Return** 返回获取的会话列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
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

  @Deprecated('Use [fetchConversationsByOptions] instead')

  /// ~english
  /// Gets the list of conversations from the server.
  ///
  /// Param [pageNum] The current page number.
  ///
  /// Param [pageSize] The number of conversations to get on each page.
  ///
  /// **Return** The conversation list of the current user.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 获取服务器会话列表。
  ///
  /// Param [pageNum] 当前页码。
  ///
  /// Param [pageSize] 每页期望返回的会话数量。
  ///
  /// **Return** 当前用户的会话列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<List<EMConversation>> fetchConversationListFromServer({
    int pageNum = 1,
    int pageSize = 20,
  }) async {
    Map request = {
      "pageNum": pageNum,
      "pageSize": pageSize,
    };
    Map result = await ChatChannel.invokeMethod(
      ChatMethodKeys.fetchConversationsFromServerWithPage,
      request,
    );
    try {
      EMError.hasErrorFromResult(result);
      List<EMConversation> conversationList = [];
      result[ChatMethodKeys.fetchConversationsFromServerWithPage]
          ?.forEach((element) {
        conversationList.add(EMConversation.fromJson(element));
      });
      return conversationList;
    } on EMError catch (e) {
      throw e;
    }
  }

  @Deprecated('Use fetchConversationsByOptions instead')

  /// ~english
  /// Get the list of conversations from the server with pagination.
  ///
  /// The SDK retrieves the list of conversations in the reverse chronological order of their active time (the timestamp of the last message).
  /// If there is no message in the conversation, the SDK retrieves the list of conversations in the reverse chronological order of their creation time.
  ///
  /// Param [cursor] The position from which to start getting data. The SDK retrieves conversations from the latest active one if this parameter is not set.
  ///
  /// Param [pageSize] The number of conversations that you expect to get on each page. The value range is [1,50].
  ///
  /// **Return** The conversation list of the current user.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器分页获取会话列表。
  ///
  /// SDK 按照会话活跃时间（会话的最后一条消息的时间戳）倒序返回会话列表。
  /// 若会话中没有消息，则 SDK 按照会话创建时间的倒序返回会话列表。
  ///
  /// Param [cursor] 查询的开始位置，如不传， SDK 从最新活跃的会话开始获取。
  ///
  /// Param [pageSize] 每页期望返回的会话数量。取值范围为 [1,50]。
  ///
  /// **Return** 当前用户的会话列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<EMCursorResult<EMConversation>> fetchConversation({
    String? cursor,
    int pageSize = 20,
  }) async {
    Map map = {
      "pageSize": pageSize,
    };
    map.putIfNotNull('cursor', cursor);
    Map result = await ChatChannel.invokeMethod(
      ChatMethodKeys.getConversationsFromServerWithCursor,
      map,
    );
    try {
      EMError.hasErrorFromResult(result);
      return EMCursorResult.fromJson(
          result[ChatMethodKeys.getConversationsFromServerWithCursor],
          dataItemCallback: (map) {
        return EMConversation.fromJson(map);
      });
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Unidirectionally removes historical message by message ID from the server.
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// Param [type] The conversation type.
  ///
  /// Param [msgIds] The list of IDs of messages to be removed.
  /// ~end
  ///
  /// ~chinese
  /// 根据消息ID 单向删除服务器会话中的消息和本地消息。
  ///
  /// Param [conversationId] 会话 ID。
  ///
  /// Param [type] 会话类型。
  ///
  /// Param [msgIds] 需要删除的消息 ID。
  /// ~end
  Future<void> deleteRemoteMessagesWithIds(
      {required String conversationId,
      required EMConversationType type,
      required List<String> msgIds}) async {
    Map request = {
      "convId": conversationId,
      "type": type.index,
      "msgIds": msgIds,
    };
    Map result = await ChatChannel.invokeMethod(
      ChatMethodKeys.removeMessagesFromServerWithMsgIds,
      request,
    );
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Unidirectionally removes historical message by timestamp from the server.
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// Param [type] The conversation type.
  ///
  /// Param [timestamp] The UNIX timestamp in millisecond. Messages with a timestamp smaller than the specified one will be removed.
  /// ~end
  ///
  /// ~chinese
  /// 根据时间 单向删除服务器会话中的消息和本地消息。
  /// Param [conversationId] 会话 ID。
  ///
  /// Param [type] 会话类型。
  ///
  /// Param [timestamp] 以毫秒为单位的UNIX时间戳。时间戳小于指定时间戳的消息将被删除。
  /// ~end
  Future<void> deleteRemoteMessagesBefore(
      {required String conversationId,
      required EMConversationType type,
      required int timestamp}) async {
    Map request = {
      "convId": conversationId,
      "type": type.index,
      "timestamp": timestamp,
    };
    Map result = await ChatChannel.invokeMethod(
      ChatMethodKeys.removeMessagesFromServerWithTs,
      request,
    );
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
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
  /// ~end
  ///
  /// ~chinese
  /// 删除本地会话。
  ///
  /// Param [deleteMessages] 删除会话时是否同时删除本地的聊天记录。
  ///                         - `true` 表示删除；
  ///                         - `false` 表示不删除。
  ///
  /// **Return** 删除会话结果。
  ///                        - `true` 代表删除成功；
  ///                        - `false` 代表删除失败。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<bool> deleteConversation(
    String conversationId, {
    bool deleteMessages = true,
  }) async {
    Map req = {"convId": conversationId, "deleteMessages": deleteMessages};
    Map result =
        await ChatChannel.invokeMethod(ChatMethodKeys.deleteConversation, req);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.deleteConversation);
    } on EMError catch (e) {
      throw e;
    }
  }

  @Deprecated('Use [fetchHistoryMessagesByOption] instead')

  /// ~english
  /// Gets historical messages of the conversation from the server with pagination.
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// Param [type] The conversation type. See [EMConversationType].
  ///
  /// Param [pageSize] The number of messages per page.
  ///
  /// Param [direction] The message search direction. See [EMSearchDirection].
  ///
  /// Param [startMsgId] The ID of the message from which you start to get the historical messages. If `null` is passed, the SDK gets messages in the reverse chronological order.
  ///
  /// **Return** The obtained messages and the cursor for the next query.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器分页获取历史消息。
  ///
  /// Param [conversationId] 会话 ID。
  ///
  /// Param [type] 会话类型，详见[EMConversationType]。
  ///
  /// Param [pageSize] 每页获取的消息数量。
  ///
  /// Param [direction] 要搜索的消息方向. 见 [EMSearchDirection].
  ///
  /// Param [startMsgId] 获取历史消息的开始消息 ID，如果为空，从最新的消息向前开始获取。
  ///
  /// **Return** 返回消息列表和用于继续获取历史消息的 [EMCursorResult]
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<EMCursorResult<EMMessage>> fetchHistoryMessages({
    required String conversationId,
    EMConversationType type = EMConversationType.Chat,
    int pageSize = 20,
    EMSearchDirection direction = EMSearchDirection.Up,
    String startMsgId = '',
  }) async {
    Map req = Map();
    req['convId'] = conversationId;
    req['type'] = type.index;
    req['pageSize'] = pageSize;
    req['startMsgId'] = startMsgId;
    req['direction'] = direction.index;
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

  /// ~english
  /// Gets historical messages of a conversation from the server according to [FetchMessageOptions].
  ///
  /// Param [conversationId] The conversation ID, which is the user ID of the peer user for one-to-one chat, but the group ID for group chat.
  ///
  /// Param [type] The conversation type. See [EMConversationType].
  ///
  /// Param [options] The parameter configuration class for pulling historical messages from the server. See [FetchMessageOptions].
  ///
  /// Param [cursor] The cursor position from which to start querying data.
  ///
  /// Param [pageSize] The number of messages that you expect to get on each page. The value range is [1,50].
  /// ~end
  ///
  /// ~chinese
  /// 根据 [FetchMessageOptions] 从服务器分页获取指定会话的历史消息。
  ///
  /// Param [conversationId] 会话 ID。
  ///
  /// Param [type] 会话类型，详见 [EMConversationType]
  ///
  /// Param [options] 查询历史消息的参数配置接口，详见 [FetchMessageOptions]。
  ///
  /// Param [cursor] 查询的起始游标位置。
  ///
  /// Param [pageSize] 每页期望获取的消息条数。取值范围为 [1,50]。
  /// ~end
  Future<EMCursorResult<EMMessage>> fetchHistoryMessagesByOption(
    String conversationId,
    EMConversationType type, {
    FetchMessageOptions? options,
    String? cursor,
    int pageSize = 50,
  }) async {
    Map req = Map();
    req.putIfNotNull('convId', conversationId);
    req.putIfNotNull('type', type.index);
    req.putIfNotNull('pageSize', pageSize);
    req.putIfNotNull('cursor', cursor);
    req.putIfNotNull('options', options?.toJson());
    Map result = await ChatChannel.invokeMethod(
        ChatMethodKeys.fetchHistoryMessagesByOptions, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMCursorResult<EMMessage>.fromJson(
          result[ChatMethodKeys.fetchHistoryMessagesByOptions],
          dataItemCallback: (value) {
        return EMMessage.fromJson(value);
      });
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Loads messages from the local database by the following parameters: keywords, timestamp, the number of messages to retrieve, message sender, search scope, and search direction.
  ///
  /// **Note** Pay attention to the memory usage when you retrieve a great number of messages.
  ///
  /// Param [keywords] The keywords in message.
  ///
  /// Param [sender] The user ID of the message sender. If you do not set this parameter, the SDK ignores this parameter when retrieving messages.
  ///
  /// Param [timestamp] The starting message timestamp for search.
  ///
  /// Param [count] The number of messages to retrieve.
  ///
  /// Param [searchScope] The message search scope. See [MessageSearchScope].
  ///
  /// Param [direction] The direction in which the message is loaded: EMSearchDirection.
  /// `EMSearchDirection.Up`: Gets the messages loaded before the timestamp of the specified message ID.
  /// `EMSearchDirection.Down`: Gets the messages loaded after the timestamp of the specified message ID.
  ///
  /// **Returns** The list of retrieved messages.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 根据消息中的关键词、消息时间戳、要搜索的消息条数、搜索范围和搜索方向从 SDK 本地数据库中搜索指定数量的消息。
  ///
  /// 注意：若搜索的消息条数非常大，需要考虑内存消耗。
  ///
  /// Param [keywords] 搜索消息中的关键词。
  ///
  /// Param [sender] 消息发送方的用户 ID。若不设置该参数，SDK 搜索消息时会忽略该参数。
  ///
  /// Param [timestamp] 搜索的起始消息时间戳。
  ///
  /// Param [count] 搜索的消息条数。
  ///
  /// Param [searchScope] 消息搜索范围，详见 [MessageSearchScope]。
  ///
  /// Param [direction] 消息搜索方向。
  ///
  /// **Return** 消息列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<List<EMMessage>> loadMessagesWithKeyword(
    String keywords, {
    String? sender,
    int timestamp = -1,
    int count = 20,
    MessageSearchScope searchScope = MessageSearchScope.All,
    EMSearchDirection direction = EMSearchDirection.Up,
  }) async {
    Map req = Map();
    req["keywords"] = keywords;
    req['count'] = count;
    req['timestamp'] = timestamp;
    req['searchScope'] = MessageSearchScope.values.indexOf(searchScope);
    req['direction'] = direction.index;
    req.putIfNotNull("from", sender);

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

  @Deprecated('Use [EMChatManager.loadMessagesWithKeyword] instead.')

  /// ~english
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
  /// Param [from] A user ID or group ID at which the retrieval is targeted. Usually, it is the conversation ID.
  ///
  /// **Return** The list of messages.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 根据传入的参数从本地存储中搜索指定数量的消息。
  ///
  /// 注意：当 maxCount 非常大时，需要考虑内存消耗，目前限制一次最多搜索 400 条数据。
  ///
  /// Param [keywords] 关键词。
  ///
  /// Param [timestamp] 搜索消息的时间点，Unix 时间戳。
  ///
  /// Param [maxCount] 搜索结果的最大条数。
  ///
  /// Param [from] 搜索来自某人或者某群的消息，一般是指会话 ID。
  ///
  /// **Return**  获取的消息列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
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
    req['direction'] = direction.index;

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

  /// ~english
  /// Gets read receipts for group messages from the server with pagination.
  ///
  /// For how to send read receipts for group messages, see [sendConversationReadAck].
  ///
  /// Param [msgId] The message ID.
  ///
  /// Param [startAckId] The starting read receipt ID for query. If you set it as null, the SDK retrieves the read receipts in the in reverse chronological order.
  ///
  /// Param [pageSize] The number of read receipts to retrieve per page.
  ///
  /// **Return** The list of obtained read receipts and the cursor for the next query.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取群组消息回执详情。
  ///
  /// 分页获取。
  ///
  /// **Note**
  /// 发送群组消息回执，详见 [sendConversationReadAck]。
  ///
  /// Param [msgId] 消息 ID。
  ///
  /// Param [startAckId] 已读回执的 ID，如果为空，从最新的回执向前开始获取。
  ///
  /// Param [pageSize] 每页获取群消息已读回执的条数。
  ///
  /// **Return** 返回回执列表和用于下次获取群消息回执的 [EMCursorResult]
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<EMCursorResult<EMGroupMessageAck>> fetchGroupAcks(
    String msgId,
    String groupId, {
    String? startAckId,
    int pageSize = 0,
  }) async {
    Map req = {"msg_id": msgId, "group_id": groupId};
    req["pageSize"] = pageSize;
    req.putIfNotNull("ack_id", startAckId);

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

  /// ~english
  /// Deletes the specified conversation and the related historical messages from the server.
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// Param [conversationType] The conversation type. See  [EMConversationType].
  ///
  /// Param [isDeleteMessage] Whether to delete the chat history when deleting the conversation.
  /// - (default) `true`: Yes.
  /// - `false`: No.
  ///
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 删除服务端的指定 ID 的会话和聊天记录。
  ///
  /// Param [conversationId] 会话 ID。
  ///
  /// Param [conversationType] 会话类型，详见 [EMConversationType]。
  ///
  /// Param [isDeleteMessage] 删除会话时是否同时删除历史消息记录。
  ///
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
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

  /// ~english
  /// Deletes messages with the timestamp that is before the specified one.
  ///
  /// Param [timestamp]  The specified Unix timestamp(milliseconds).
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 根据时间删除本地消息。
  ///
  /// Param [timestamp] 指定的Unix时间戳(毫秒)。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<void> deleteMessagesBefore(int timestamp) async {
    Map result = await ChatChannel.invokeMethod(
        ChatMethodKeys.deleteMessagesBeforeTimestamp, {"timestamp": timestamp});
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  ///  Reports an inappropriate message.
  ///
  /// Param [messageId] The ID of the message to report.
  ///
  /// Param [tag] The tag of the inappropriate message. You need to type a custom tag, like `porn` or `ad`.
  ///
  /// Param [reason] The reporting reason. You need to type a specific reason.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 举报消息。
  ///
  /// Param [messageId] 要举报的消息 ID。
  ///
  /// Param [tag] 非法消息的标签。你需要填写自定义标签，例如`涉政`或`广告`。
  ///
  /// Param [reason] 举报原因。你需要自行填写举报原因。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
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

  /// ~english
  /// Adds a Reaction.
  ///
  /// Param [messageId] The message ID.
  ///
  /// Param [reaction] The Reaction content.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 添加 Reaction。
  ///
  /// Param [messageId] 要添加 Reaction 的消息 ID。
  ///
  /// Param [reaction] Reaction 的内容。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 详见 [EMError]。
  /// ~end
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

  /// ~english
  /// Deletes a Reaction.
  ///
  /// Param [messageId] The message ID.
  ///
  /// Param [reaction] The Reaction content.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 删除 Reaction。
  ///
  /// Param [messageId] 添加了该 Reaction 的消息 ID。
  ///
  /// Param [reaction] 要删除的 Reaction。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
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

  /// ~english
  /// Gets the list of Reactions.
  ///
  /// Param [messageIds] The message IDs.
  ///
  /// Param [chatType] The chat type. Only one-to-one chat [ChatType.Chat] and group chat [ChatType.GroupChat] are allowed.
  ///
  /// Param [groupId] The group ID. This parameter is valid only when the chat type is group chat.
  ///
  /// **Return** The Reaction list under the specified message ID（[EMMessageReaction.userList] is the summary data, which only contains the information of the first three users）.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 获取 Reaction 列表。
  ///
  /// Param [messageIds] 消息 ID 列表。
  ///
  /// Param [chatType] 会话类型。
  ///
  /// Param [groupId] 群组 ID，该参数仅在会话类型为群聊时有效。
  ///
  /// **Return** 若调用成功，返回 Reaction 列表；失败则抛出异常。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<Map<String, List<EMMessageReaction>>> fetchReactionList({
    required List<String> messageIds,
    required ChatType chatType,
    String? groupId,
  }) async {
    Map req = {
      "msgIds": messageIds,
      "chatType": chatType.index,
    };
    req.putIfNotNull("groupId", groupId);
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

  /// ~english
  /// Gets the Reaction details.
  ///
  /// Param [messageId] The message ID.
  ///
  /// Param [reaction] The Reaction content.
  ///
  /// Param [cursor] The cursor position from which to get Reactions.
  ///
  /// Param [pageSize] The number of Reactions you expect to get on each page.
  ///
  /// **Return** The result callback, which contains the reaction list obtained from the server and the cursor for the next query. Returns null if all the data is fetched.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 获取 Reaction 详情。
  ///
  /// Param [messageId] 消息 ID。
  ///
  /// Param [reaction] Reaction 内容。
  ///
  /// Param [cursor] 开始获取 Reaction 的游标位置, 首次可以不传。
  ///
  /// Param [pageSize] 每页期望返回的 Reaction 数量。
  ///
  /// **Return** 若调用成功，返回 Reaction 详情。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
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
    req.putIfNotNull("cursor", cursor);
    req.putIfNotNull("pageSize", pageSize);
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

  /// ~english
  /// Translates a text message.
  ///
  /// Param [msg] The message object for translation.
  ///
  /// Param [languages] The list of target language codes.
  ///
  /// **Return** The translated message.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 翻译一条文本消息。
  ///
  /// Param [msg] 要翻译的文本消息。
  ///
  /// Param [languages] 目标语言代码列表。
  ///
  /// **Return** 译文。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
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

  /// ~english
  /// Gets all languages supported by the translation service.
  ///
  /// **Return** The supported languages.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 查询翻译服务支持的语言。
  ///
  /// **Return** 翻译服务支持的语言列表。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
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

  @Deprecated('Use [fetchConversationsByOptions] instead')

  /// ~english
  /// Gets the list of pinned conversations from the server with pagination.
  ///
  /// The SDK returns the pinned conversations in the reverse chronological order of their pinning.
  ///
  /// Param [cursor] The position from which to start getting data. If this parameter is not set, the SDK retrieves conversations from the latest pinned one.
  ///
  /// Param [pageSize] The number of conversations that you expect to get on each page. The value range is [1,50].
  ///
  /// **Return** The pinned conversation list of the current user.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 分页从服务器获取置顶会话。
  ///
  /// SDK 按照会话的置顶时间的倒序返回会话列表。
  ///
  /// Param [cursor] 查询的开始位置，如不传， SDK 从最新置顶的会话开始查询。
  ///
  /// Param [pageSize] 每页期望返回的会话数量。取值范围为 [1,50]。
  ///
  /// **Return** 当前用户的置顶会话列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<EMCursorResult<EMConversation>> fetchPinnedConversations({
    String? cursor,
    int pageSize = 20,
  }) async {
    Map map = {
      "pageSize": pageSize,
    };
    map.putIfNotNull('cursor', cursor);
    Map result = await ChatChannel.invokeMethod(
      ChatMethodKeys.getPinnedConversationsFromServerWithCursor,
      map,
    );
    try {
      EMError.hasErrorFromResult(result);
      return EMCursorResult.fromJson(
          result[ChatMethodKeys.getPinnedConversationsFromServerWithCursor],
          dataItemCallback: (map) {
        return EMConversation.fromJson(map);
      });
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Sets whether to pin a conversation.
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// Param [isPinned]  Whether to pin a conversation:
  /// - true: Pin the conversation.
  /// - false: Unpin the conversation.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 设置是否置顶会话。
  ///
  /// Param [conversationId] 会话 ID。
  ///
  /// Param [isPinned] 是否置顶会话：
  /// - true: 置顶会话。
  /// - false: 取消置顶会话。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<void> pinConversation(
      {required String conversationId, required bool isPinned}) async {
    Map map = {
      'convId': conversationId,
      'isPinned': isPinned,
    };

    Map result = await ChatChannel.invokeMethod(
      ChatMethodKeys.pinConversation,
      map,
    );
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Modifies a message.
  ///
  /// After this method is called to modify a message, both the local message and the message on the server are modified.
  ///
  /// This method can only modify a text message in one-to-one chats or group chats, but not in chat rooms.
  ///
  /// Param [messageId] The ID of the message to modify.
  ///
  /// Param [msgBody]  The modified message body [EMTextMessageBody].
  ///
  /// **Return** The modified message.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 修改消息内容。
  ///
  /// 调用该方法修改消息内容后，本地和服务端的消息均会修改。
  ///
  /// 只能调用该方法修改单聊和群聊中的文本消息，不能修改聊天室消息。
  ///
  /// Param [messageId] 消息实例 ID。
  ///
  /// Param [msgBody] 文本消息体实例 [EMTextMessageBody]。
  ///
  /// **Return** 修改后的消息实例。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<EMMessage> modifyMessage({
    required String messageId,
    required EMTextMessageBody msgBody,
  }) async {
    Map map = {
      'msgId': messageId,
      'body': msgBody.toJson(),
    };

    Map result = await ChatChannel.invokeMethod(
      ChatMethodKeys.modifyMessage,
      map,
    );
    try {
      EMError.hasErrorFromResult(result);
      return EMMessage.fromJson(result[ChatMethodKeys.modifyMessage]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Gets the details of a combined message.
  ///
  /// Param [message] The combined message.
  ///
  /// **Return** The list of original messages included in the combined message.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 获取合并消息的详情。
  ///
  /// Param [message] 合并消息。
  ///
  /// **Return** 合并消息包含的原始消息列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<List<EMMessage>> fetchCombineMessageDetail({
    required EMMessage message,
  }) async {
    Map map = {
      'message': message.toJson(),
    };

    Map result = await ChatChannel.invokeMethod(
      ChatMethodKeys.downloadAndParseCombineMessage,
      map,
    );

    try {
      EMError.hasErrorFromResult(result);
      List<EMMessage> messages = [];
      List list = result[ChatMethodKeys.downloadAndParseCombineMessage];
      list.forEach((element) {
        messages.add(EMMessage.fromJson(element));
      });
      return messages;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// ~english
  /// Marks conversations.
  ///
  /// This method marks conversations both locally and on the server.
  ///
  /// Param [conversationIds] The list of conversation IDs to mark.
  ///
  /// Param [mark] The mark to add for the conversations. See [ConversationMarkType].
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  /// ~end
  ///
  /// ~chinese
  /// 标记会话。
  ///
  /// 调用该方法会同时为本地和服务器端的会话添加标记。
  ///
  /// Param [conversationIds] 要标记的会话 ID 列表。
  ///
  /// Param [mark] 要添加的会话标记，详见 [ConversationMarkType]。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  /// ~end
  Future<void> addRemoteAndLocalConversationsMark({
    required List<String> conversationIds,
    required ConversationMarkType mark,
  }) async {
    Map map = {
      'convIds': conversationIds,
      'mark': mark.index,
    };

    Map result = await ChatChannel.invokeMethod(
      ChatMethodKeys.addRemoteAndLocalConversationsMark,
      map,
    );
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Unmarks conversations.
  ///
  /// This method unmarks conversations both locally and on the server.
  ///
  /// Param [conversationIds] The list of conversation IDs to unmark.
  /// Param [mark] The conversation mark to remove. See [ConversationMarkType].
  /// ~end
  ///
  /// ~chinese
  /// 取消标记会话。
  ///
  /// 本地和服务端取消标记会话。
  ///
  /// Param [conversationIds] 要取消标记的会话 ID 列表。
  /// Param [mark] 要移除的会话标记，详见 [ConversationMarkType]。
  /// ~end
  Future<void> deleteRemoteAndLocalConversationsMark({
    required List<String> conversationIds,
    required ConversationMarkType mark,
  }) async {
    Map map = {
      'convIds': conversationIds,
      'mark': mark.index,
    };

    Map result = await ChatChannel.invokeMethod(
      ChatMethodKeys.deleteRemoteAndLocalConversationsMark,
      map,
    );
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Gets conversations from the server by conversation filter options.
  ///
  /// Param [options] The conversation filter options. See [ConversationFetchOptions].
  /// Returns The list of retrieved conversations.
  /// Throws A description of the exception. See [EMError].
  /// ~end
  /// ~chinese
  /// 根据会话过滤选项获取服务端的会话。
  /// Param [options] 会话过滤选项, 详见 [ConversationFetchOptions]。
  /// Returns 会话列表。
  /// Throws 如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<EMCursorResult<EMConversation>> fetchConversationsByOptions({
    required ConversationFetchOptions options,
  }) async {
    Map req = options.toJson();
    Map result = await ChatChannel.invokeMethod(
        ChatMethodKeys.fetchConversationsByOptions, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMCursorResult<EMConversation>.fromJson(
          result[ChatMethodKeys.fetchConversationsByOptions],
          dataItemCallback: (value) {
        return EMConversation.fromJson(value);
      });
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Clears all conversations and all messages in them.
  /// Param [clearServerData] Whether to clear all conversations and all messages in them on the server.
  /// - true: Yes. All conversations and all messages in them will be cleared on the server side.
  ///   The current user cannot retrieve messages and conversations from the server, while this has no impact on other users.
  /// - (Default) false：No. All local conversations and all messages in them will be cleared, while those on the server remain.
  /// ~end
  ///
  /// ~chinese
  /// 清空所有会话和会话中的所有消息。
  /// Param [clearServerData] 是否删除服务端所有会话及其消息：
  /// - true: 是。服务端的所有会话及其消息会被清除，当前用户无法再从服务端拉取消息和会话，其他用户不受影响。
  /// - （默认）false: 否。只清除本地所有会话及其消息，服务端的会话及其消息仍保留。
  /// ~end
  Future<void> deleteAllMessageAndConversation(
      {bool clearServerData = false}) async {
    Map result = await ChatChannel.invokeMethod(
        ChatMethodKeys.deleteAllMessageAndConversation, {
      'clearServerData': clearServerData,
    });
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Pins a message.
  /// Param [messageId] The message ID.
  ///
  /// Throws A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 置顶消息。
  /// Param [messageId] 消息 ID。
  ///
  /// Throws 如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<void> pinMessage({required String messageId}) async {
    Map map = {'msgId': messageId};

    Map result = await ChatChannel.invokeMethod(
      ChatMethodKeys.pinMessage,
      map,
    );
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Unpins a message.
  ///
  /// Param [messageId] The message ID.
  ///
  /// Throws A description of the exception. See [EMError].
  /// ~end
  /// ~chinese
  /// 取消置顶消息。
  ///
  /// Param [messageId] 消息 ID。
  ///
  /// Throws 如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<void> unpinMessage({required String messageId}) async {
    Map map = {'msgId': messageId};

    Map result = await ChatChannel.invokeMethod(
      ChatMethodKeys.unpinMessage,
      map,
    );
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Gets the list of pinned messages from the server.
  ///
  /// Param [conversationId] The conversation ID.
  /// Returns The list of pinned messages.
  /// Throws A description of the exception. See [EMError].
  /// ~end
  /// ~chinese
  /// 从服务端获取置顶消息。
  ///
  /// Param [conversationId] 会话 ID。
  /// Returns 置顶消息列表。
  /// Throws 如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<List<EMMessage>> fetchPinnedMessages(
      {required String conversationId}) async {
    Map map = {'convId': conversationId};
    Map result = await ChatChannel.invokeMethod(
      ChatMethodKeys.fetchPinnedMessages,
      map,
    );
    try {
      EMError.hasErrorFromResult(result);
      List<EMMessage> messages = [];
      List list = result[ChatMethodKeys.fetchPinnedMessages];
      list.forEach((element) {
        messages.add(EMMessage.fromJson(element));
      });
      return messages;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Adds a message status listener.
  ///
  /// Param [identifier] The ID of the message status listener. The ID is required when you delete a message status listener.
  ///
  /// Param [event] The message status event.
  /// ~end
  ///
  /// ~chinese
  /// 添加消息状态监听。
  ///
  /// Param [identifier] 消息状态监听 ID, 删除监听时需提供。
  ///
  /// Param [event] 消息状态事件。
  /// ~end
  void addMessageEvent(String identifier, ChatMessageEvent event) {
    MessageCallBackManager.getInstance.addMessageEvent(identifier, event);
  }

  /// ~english
  /// Removes a message status listener.
  ///
  /// Param [identifier] The ID of the message status listener. The ID is set when you add a message status listener.
  /// ~end
  ///
  /// ~chinese
  /// 移除消息状态监听。
  ///
  /// Param [identifier] 消息状态监听 ID, 在添加时设置。
  /// ~end
  void removeMessageEvent(String identifier) {
    MessageCallBackManager.getInstance.removeMessageEvent(identifier);
  }

  /// ~english
  /// Clears all message status listeners.
  /// ~end
  ///
  /// ~chinese
  /// 清空所有消息状态监听。
  /// ~end
  void clearMessageEvent() {
    MessageCallBackManager.getInstance.clearAllMessageEvents();
  }

  Future<void> _onMessagesReceived(List messages) async {
    List<EMMessage> messageList = [];
    for (var message in messages) {
      messageList.add(EMMessage.fromJson(message));
    }

    for (var item in _eventHandlesMap.values) {
      item.onMessagesReceived?.call(messageList);
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
  }

  Future<void> _onMessagesRead(List messages) async {
    List<EMMessage> list = [];
    for (var message in messages) {
      list.add(EMMessage.fromJson(message));
    }

    for (var item in _eventHandlesMap.values) {
      item.onMessagesRead?.call(list);
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
  }

  Future<void> _onReadAckForGroupMessageUpdated(List messages) async {
    for (var item in _eventHandlesMap.values) {
      item.onReadAckForGroupMessageUpdated?.call();
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
  }

  Future<void> _onMessagesRecalled(List messages) async {
    List<EMMessage> list = [];
    for (var message in messages) {
      list.add(EMMessage.fromJson(message));
    }

    for (var item in _eventHandlesMap.values) {
      item.onMessagesRecalled?.call(list);
    }
  }

  Future<void> _onMessagesRecalledInfo(List infos) async {
    List<RecallMessageInfo> list = [];
    for (var info in infos) {
      list.add(RecallMessageInfo.fromJson(info));
    }

    for (var item in _eventHandlesMap.values) {
      item.onMessagesRecalledInfo?.call(list);
    }
  }

  Future<void> _onConversationsUpdate(dynamic obj) async {
    for (var item in _eventHandlesMap.values) {
      item.onConversationsUpdate?.call();
    }
  }

  Future<void> _onConversationHasRead(dynamic obj) async {
    String from = (obj as Map)['from'];
    String to = obj['to'];

    for (var item in _eventHandlesMap.values) {
      item.onConversationRead?.call(from, to);
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
  }

  Future<void> _onMessageContentChanged(dynamic obj) async {
    EMMessage msg = EMMessage.fromJson(obj["message"]);
    String operator = obj["operator"] ?? "";
    int operationTime = obj["operationTime"] ?? 0;
    for (var item in _eventHandlesMap.values) {
      item.onMessageContentChanged?.call(msg, operator, operationTime);
    }
  }

  Future<void> _onMessagePinChanged(dynamic obj) async {
    String messageId = obj["messageId"] ?? "";
    String conversationId = obj["conversationId"] ?? "";
    MessagePinOperation pinOperation =
        MessagePinOperation.values[obj["pinOperation"]];
    MessagePinInfo pinInfo = MessagePinInfo.fromJson(obj["pinInfo"]);
    for (var item in _eventHandlesMap.values) {
      item.onMessagePinChanged
          ?.call(messageId, conversationId, pinOperation, pinInfo);
    }
  }

  // 481

  /// ~english
  /// Loads messages with the specified keyword from the local database.
  ///
  /// Param [options]  search options, see [MessageSearchOptions].
  ///
  /// **Returns** The list of retrieved messages.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 通过类型从数据库获取消息。
  ///
  /// Param [options] 搜索配置项, 详情查看 [MessageSearchOptions].
  ///
  /// **Return** 消息列表。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<List<EMMessage>> searchMsgsByOptions(
      MessageSearchOptions options) async {
    Map req = {};
    req['ts'] = options.ts;
    req['count'] = options.count;
    req['direction'] = options.direction.index;
    req.putIfNotNull("from", options.from);
    req['types'] = options.types.map((e) => e.index).toList();
    Map result =
        await ChatChannel.invokeMethod(ChatMethodKeys.searchMsgsByOptions, req);
    try {
      EMError.hasErrorFromResult(result);
      List<EMMessage> messages = [];
      List list = result[ChatMethodKeys.searchMsgsByOptions];
      list.forEach((element) {
        messages.add(EMMessage.fromJson(element));
      });
      return messages;
    } on EMError catch (e) {
      throw e;
    }
  }

  Future<int> getAllMessageCount() async {
    Map result = await ChatChannel.invokeMethod(ChatMethodKeys.getMessageCount);
    try {
      EMError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.getMessageCount)) {
        return result[ChatMethodKeys.getMessageCount];
      } else {
        return 0;
      }
    } on EMError catch (e) {
      throw e;
    }
  }
}

/// ~english
/// The message status event class.
/// During message delivery, the message ID will be changed from a local uuid to a global unique ID that is generated by the server to uniquely identify a message on all devices using the SDK.
/// This API should be implemented in the chat page widget to listen for message status changes.
/// ~end
///
/// ~chinese
/// 消息状态事件类。
/// ~end
class ChatMessageEvent {
  ChatMessageEvent({
    this.onSuccess,
    this.onError,
    this.onProgress,
  });

  /// ~english
  /// Occurs when a message is successfully sent or downloaded.
  ///
  /// Param [msgId] The pre-sending message ID or the ID of the message that is successfully downloaded.
  ///
  /// Param [msg] The message that is successfully sent or downloaded.
  /// ~end
  ///
  /// ~chinese
  /// 消息发送或下载成功回调。
  /// ~end
  final void Function(String msgId, EMMessage msg)? onSuccess;

  /// ~english
  /// Occurs when a message fails to be sent or downloaded.
  ///
  /// Param [msgId] The pre-sending message ID or the ID of the message that fails to be downloaded.
  ///
  /// Param [msg] The message that fails to be sent or downloaded.
  /// ~end
  ///
  /// ~chinese
  /// 消息发送或下载失败回调。
  ///
  /// Param [msgId] 发送前或下载失败的消息 ID。
  ///
  /// Param [msg] 发送或下载失败的消息。
  /// ~end
  final void Function(String msgId, EMMessage msg, EMError error)? onError;

  /// ~english
  /// Occurs when there is a progress for message upload or download. This event is triggered when a message is being uploaded or downloaded.
  ///
  /// Param [msgId] The ID of the message that is being uploaded or downloaded.
  ///
  /// Param [progress] The upload or download progress.
  /// ~end
  ///
  /// ~chinese
  /// 消息上传或下载进度的回调。
  ///
  /// Param [msgId] 正在上传或下载的消息的 ID。
  ///
  /// Param [progress] 上传或下载进度。
  /// ~end
  final void Function(String msgId, int progress)? onProgress;
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
