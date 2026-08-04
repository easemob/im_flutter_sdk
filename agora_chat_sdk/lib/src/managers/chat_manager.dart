import 'package:flutter/services.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:agora_chat_sdk/src/tools/chat_extension.dart';
import 'package:agora_chat_sdk/src/tools/chat_log.dart';

import 'package:agora_chat_sdk_interface/agora_chat_sdk_interface.dart' as platform_interface;

/// ~english
/// The chat manager class, responsible for sending and receiving messages, loading and deleting conversations, and downloading attachments.
///
/// The sample code for sending a text message:
///
/// ```dart
///    ChatMessage msg = ChatMessage.createTxtSendMessage(
///        username: toChatUsername, content: content);
///    await ChatClient.getInstance.chatManager.sendMessage(msg);
/// ```
/// ~end
///
/// ~chinese
/// 聊天管理类，该类负责管理会话（加载，删除等）、发送消息、下载消息附件等。
///
/// 比如，发送一条文本消息：
///
/// ```dart
///    ChatMessage msg = ChatMessage.createTxtSendMessage(
///        targetId: toChatUsername, content: content);
///    await ChatClient.getInstance.chatManager.sendMessage(msg);
/// ```
/// ~end
class ChatManager {
  final Map<String, ChatEventHandler> _eventHandlesMap = {};

  ChatManager() {
    platform_interface.Client.instance.chatManager.updateNativeHandler((MethodCall call) {
      ChatLog.d("${call.method}: arguments: ${call.arguments}");
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
      return Future.value();
    });
  }
  Future<void> _onMessagesReceived(List messages) async {
    List<ChatMessage> messageList = [];
    for (var message in messages) {
      messageList.add(ChatMessage.fromJson(message));
    }

    for (var item in _eventHandlesMap.values) {
      item.onMessagesReceived?.call(messageList);
    }
  }

  Future<void> _onCmdMessagesReceived(List messages) async {
    List<ChatMessage> list = [];
    for (var message in messages) {
      list.add(ChatMessage.fromJson(message));
    }

    for (var item in _eventHandlesMap.values) {
      item.onCmdMessagesReceived?.call(list);
    }
  }

  Future<void> _onMessagesRead(List messages) async {
    List<ChatMessage> list = [];
    for (var message in messages) {
      list.add(ChatMessage.fromJson(message));
    }

    for (var item in _eventHandlesMap.values) {
      item.onMessagesRead?.call(list);
    }
  }

  Future<void> _onGroupMessageRead(List messages) async {
    List<ChatGroupMessageAck> list = [];
    for (var message in messages) {
      list.add(ChatGroupMessageAck.fromJson(message));
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
    List<ChatMessage> list = [];
    for (var message in messages) {
      list.add(ChatMessage.fromJson(message));
    }

    for (var item in _eventHandlesMap.values) {
      item.onMessagesDelivered?.call(list);
    }
  }

  Future<void> _onMessagesRecalled(List messages) async {
    List<ChatMessage> list = [];
    for (var message in messages) {
      list.add(ChatMessage.fromJson(message));
    }

    for (var item in _eventHandlesMap.values) {
      // ignore: deprecated_member_use_from_same_package
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
    List<ChatMessageReactionEvent> list = [];
    for (var reactionChange in reactionChangeList) {
      list.add(ChatMessageReactionEvent.fromJson(reactionChange));
    }

    for (var item in _eventHandlesMap.values) {
      item.onMessageReactionDidChange?.call(list);
    }
  }

  Future<void> _onMessageContentChanged(dynamic obj) async {
    ChatMessage msg = ChatMessage.fromJson(obj["message"]);
    String operator = obj["operator"] ?? "";
    int operationTime = obj["operationTime"] ?? 0;
    for (var item in _eventHandlesMap.values) {
      item.onMessageContentChanged?.call(msg, operator, operationTime);
    }
  }

  Future<void> _onMessagePinChanged(dynamic obj) async {
    String messageId = obj["msgId"] ?? "";
    String conversationId = obj["convId"] ?? "";
    MessagePinOperation pinOperation =
        MessagePinOperation.values[obj["pinOperation"]];
    MessagePinInfo pinInfo = MessagePinInfo.fromJson(obj["pinInfo"]);
    for (var item in _eventHandlesMap.values) {
      item.onMessagePinChanged
          ?.call(messageId, conversationId, pinOperation, pinInfo);
    }
  }

  /// ~english
  /// Adds the chat event handler. After calling this method, you can handle for chat event when they arrive.
  ///
  /// Param [identifier] The custom handler identifier, is used to find the corresponding handler.
  ///
  /// Param [handler] The handler for chat event. See [ChatEventHandler].
  /// ~end
  ///
  /// ~chinese
  /// 添加事件监听。
  ///
  /// Param [identifier] 事件监听对应的 ID。
  ///
  /// Param [handler] 事件监听. 请见 [ChatEventHandler].
  /// ~end
  void addEventHandler(
    String identifier,
    ChatEventHandler handler,
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
  ChatEventHandler? getEventHandler(String identifier) {
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

  /// ~english
  /// Sends a message.
  ///
  /// **Note**
  /// For attachment messages such as voice, image, or video messages, the SDK automatically uploads the attachment.
  /// You can set whether to upload the attachment to the chat sever using [ChatOptions.serverTransfer].
  ///
  /// To listen for the status of sending messages, call [ChatManager.addMessageEvent].
  ///
  /// Param [message] The message object to be sent: [ChatMessage].
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 发消息
  ///
  /// **Note**
  /// 对于语音、图片、视频等附件消息，SDK会自动上传附件。
  /// 可以使用 [ChatOptions.serverTransfer] 设置是否将附件上传到聊天服务器。
  ///
  /// 添加发送状态监听使用 [ChatManager.addMessageEvent].
  ///
  /// Param [message] 需要发送的消息 [ChatMessage].
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<ChatMessage> sendMessage(ChatMessage message) async {
    try {
      message.status = MessageStatus.PROGRESS;
      Map result = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.sendMessage, message.toJson());
      ChatError.hasErrorFromResult(result);
      ChatMessage msg = ChatMessage.fromJson(result[ChatMethodKeys.sendMessage]);
      message.from = msg.from;
      message.to = msg.to;
      message.status = msg.status;
      return message;
    } catch (e) {
      message.status = MessageStatus.FAIL;
      rethrow;
    }
  }

  /// ~english
  /// Resends a message.
  ///
  /// Param [message] The message object to be resent: [ChatMessage].
  /// ~end
  ///
  /// ~chinese
  /// 重发消息。
  ///
  /// Param [message] 需要重发的消息。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<ChatMessage> resendMessage(ChatMessage message) async {
    try {
      message.status = MessageStatus.PROGRESS;
      Map result = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.resendMessage, message.toJson());
      ChatError.hasErrorFromResult(result);
      ChatMessage msg = ChatMessage.fromJson(result[ChatMethodKeys.resendMessage]);
      message.from = msg.from;
      message.to = msg.to;
      message.status = msg.status;
      return message;
    } catch (e) {
      message.status = MessageStatus.FAIL;
      rethrow;
    }
  }

  /// ~english
  /// Sends the read receipt to the server.
  ///
  /// This method applies to one-to-one chats only.
  ///
  /// **Warning**
  /// This method only takes effect if you set [ChatOptions.requireAck] as `true`.
  ///
  /// **Note**
  /// To send the group message read receipt, call [sendGroupMessageReadAck].
  ///
  /// We recommend that you call [sendConversationReadAck] when entering a chat page, and call this method to reduce the number of method calls.
  ///
  /// Param [message] The message body: [ChatMessage].
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 发送消息的已读回执，该方法只针对单聊会话。
  ///
  /// **Warning**
  /// 该方法只有在 [ChatOptions.requireAck] 为 `true` 时才生效。
  ///
  /// **Note**
  /// 群消息已读回执，详见 [sendGroupMessageReadAck]。
  ///
  /// 推荐进入会话页面时调用 [sendConversationReadAck]，其他情况下调用该方法以减少调用频率。
  ///
  /// Param [message] 需要发送已读回执的消息。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<void> sendMessageReadAck(ChatMessage message) async {
    try {
      Map req = {"to": message.from, "msgId": message.msgId};
      Map result = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.ackMessageRead, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Sends the group message receipt to the server.
  ///
  ///
  /// **Note**
  /// - This method takes effect only after you set [ChatOptions.requireAck] and [ChatMessage.needGroupAck] as `true`.
  /// - This method applies to group messages only. To send a one-to-one chat message receipt, call [sendMessageReadAck]; to send a conversation receipt, call [sendConversationReadAck].
  ///
  ///
  /// Param [msgId] The message ID.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [content] The extension information, which is a custom keyword that specifies a custom action or command.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 发送群消息已读回执。
  ///
  /// **Note**
  /// 1. 使用该方法前，需将 [ChatOptions.requireAck] 和 [ChatMessage.needGroupAck] 设置为 `true`。
  /// 2. 发送单聊消息已读回执，详见 [sendMessageReadAck]。
  /// 3. 会话已读回执，详见 [sendConversationReadAck]。
  ///
  /// Param [msgId] 消息 ID。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [content] 扩展信息。用户自己定义的关键字，接收后，解析出自定义的字符串，可以自行处理。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<void> sendGroupMessageReadAck(
    String msgId,
    String groupId, {
    String? content,
  }) async {
    try {
      Map req = {
        "msgId": msgId,
        "group_id": groupId,
      };
      req.putIfNotNull("content", content);
      Map result = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.ackGroupMessageRead, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Sends the conversation read receipt to the server. This method is only for one-to-one chat conversations.
  ///
  /// This method informs the server to set the unread message count of the conversation to 0. In multi-device scenarios, all the devices receive the [ChatEventHandler.onConversationRead] callback.
  ///
  /// **Note**
  /// This method applies to one-to-one chat conversations only. To send a group message read receipt, call [sendGroupMessageReadAck].
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 发送会话的已读回执，该方法只针对单聊会话。
  ///
  /// 该方法会通知服务器将此会话未读数设置为 0，对话方（包含多端多设备）将会在下面这个回调方法中接收到回调：
  /// [ChatEventHandler.onConversationRead]。
  ///
  /// **Note**
  /// 发送群组消息已读回执见 [sendGroupMessageReadAck]。
  ///
  /// Param [conversationId] 会话 ID。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<void> sendConversationReadAck(String conversationId) async {
    try {
      Map req = {"convId": conversationId};
      Map result = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.ackConversationRead, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Recalls the sent message.
  ///
  /// Param [messageId] The message ID.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 撤回发送成功的消息。
  ///
  /// Param [messageId] 消息 ID。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<void> recallMessage(String messageId, {String? ext}) async {
    try {
      Map req = {"msgId": messageId};
      req.putIfNotNull('ext', ext);
      Map result = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.recallMessage, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Loads a message from the local database by message ID.
  ///
  /// Param [messageId] The message ID.
  ///
  /// **Return** The message object specified by the message ID. Returns null if the message does not exist.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从本地数据库获取指定 ID 的消息对象。
  ///
  /// Param [messageId] 消息 ID。
  ///
  /// **Return** 根据指定 ID 获取的消息对象，如果消息不存在会返回空值。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<ChatMessage?> loadMessage(String messageId) async {
    try {
      Map req = {"msgId": messageId};
      Map<String, dynamic> result = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.getMessage, req);
      ChatError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.getMessage)) {
        return ChatMessage.fromJson(result[ChatMethodKeys.getMessage]);
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Loads messages from the local database by message IDs.
  ///
  /// Param [messageIds] The list of message IDs.
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// **Return** The list of message objects specified by the message IDs.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 根据消息 ID 列表从本地数据库加载消息。
  ///
  /// Param [messageIds] 消息 ID 列表。
  ///
  /// Param [conversationId] 会话 ID。
  ///
  /// **Return** 根据消息 ID 列表获取的消息对象列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<List<ChatMessage>> loadMessagesWithIds(
    List<String> messageIds,
    String conversationId,
  ) async {
    try {
      Map req = {
        "messageIds": messageIds,
        "conversationId": conversationId,
      };
      Map result = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.loadMessagesWithIds, req);
      ChatError.hasErrorFromResult(result);
      List<ChatMessage> messageList = [];
      if (result.containsKey(ChatMethodKeys.loadMessagesWithIds)) {
        List messages = result[ChatMethodKeys.loadMessagesWithIds];
        for (var message in messages) {
          messageList.add(ChatMessage.fromJson(message));
        }
      }
      return messageList;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the conversation by conversation ID and conversation type.
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// Param [type] The conversation type: [ChatConversationType].
  ///
  /// Param [createIfNeed] Whether to create the conversation if the conversation is not found:
  /// - （Default) `true`: Yes.
  /// - `false`: No.
  ///
  /// **Return** The conversation object found according to the conversation ID and type. The SDK returns null if the conversation is not found.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 根据指定会话 ID 和会话类型获取会话对象。
  ///
  /// 没有找到会返回空值。
  ///
  /// Param [conversationId] 会话 ID。
  ///
  /// Param [type] 会话类型，详见 [ChatConversationType]。
  ///
  /// Param [createIfNeed] 没找到相应会话时是否自动创建。
  ///   - （默认）`true` 表示自动创建会话。
  ///   - `false` 表示不创建会话。
  ///
  ///
  /// **Return**  根据指定 ID 以及会话类型找到的会话对象，如果没有找到会返回空值。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<ChatConversation?> getConversation(
    String conversationId, {
    ChatConversationType type = ChatConversationType.Chat,
    bool createIfNeed = true,
  }) async {
    try {
      Map req = {
        "convId": conversationId,
        "type": type.index,
        "createIfNeed": createIfNeed
      };
      Map result = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.getConversation, req);
      ChatError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.getConversation)) {
        return ChatConversation.fromJson(result[ChatMethodKeys.getConversation]);
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the thread conversation by thread ID.
  ///
  /// Param [threadId] The thread ID.
  ///
  /// **Return** The conversation object.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 根据 thread ID 获取 thread 会话。
  ///
  /// Param [threadId] Thread ID.
  ///
  /// **Return** 会话对象.
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<ChatConversation?> getThreadConversation(String threadId) async {
    try {
      Map req = {"convId": threadId};
      Map result = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.getThreadConversation, req);
      ChatError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.getThreadConversation)) {
        return ChatConversation.fromJson(
            result[ChatMethodKeys.getThreadConversation]);
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Marks all conversations as read.
  ///
  /// This method is for the local conversations only.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 把所有的会话都设成已读。
  ///
  /// 这里针对的是本地会话。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<void> markAllConversationsAsRead() async {
    try {
      Map result = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.markAllChatMsgAsRead);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the count of the unread messages.
  ///
  /// **Return** The count of the unread messages.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 获取未读消息数。
  ///
  /// **Return** 未读消息数。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<int> getUnreadMessageCount() async {
    try {
      Map result = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.getUnreadMessageCount);
      int ret = 0;
      ChatError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.getUnreadMessageCount)) {
        ret = result[ChatMethodKeys.getUnreadMessageCount] as int;
      }
      return ret;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Updates the local message.
  ///
  /// The message will be updated both in the cache and local database.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 更新本地消息。
  ///
  /// 会同时更新本地内存和数据库。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<void> updateMessage(ChatMessage message) async {
    try {
      Map req = {"message": message.toJson()};
      Map result = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.updateChatMessage, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
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
  /// **Throws** A description of the exception. See [ChatError].
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
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<void> importMessages(List<ChatMessage> messages) async {
    try {
      List<Map> list = [];
      for (var element in messages) {
        list.add(element.toJson());
      }
      Map req = {"messages": list};
      Map result = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.importMessages, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Downloads the attachment files from the server.
  ///
  /// You can call the method again if the attachment download fails.
  ///
  /// Param [message] The message with the attachment that is to be downloaded.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 下载消息的附件。
  ///
  /// 若附件自动下载失败，也可以调用此方法下载。
  ///
  /// Param [message] 要下载附件的消息。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<void> downloadAttachment(ChatMessage message) async {
    try {
      Map result = await platform_interface.Client.instance.chatManager.callNativeMethod(
          ChatMethodKeys.downloadAttachment, {"message": message.toJson()});
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Downloads the thumbnail if the message has not been downloaded before or if the download fails.
  ///
  /// Param [message] The message object.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 下载消息的缩略图。
  ///
  /// Param [message] 要下载缩略图的消息，一般图片消息和视频消息有缩略图。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<void> downloadThumbnail(ChatMessage message) async {
    try {
      Map result = await platform_interface.Client.instance.chatManager.callNativeMethod(
          ChatMethodKeys.downloadThumbnail, {"message": message.toJson()});
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Downloads the attachment files from the server.
  ///
  /// You can call the method again if the attachment download fails.
  ///
  /// Param [message] The message with the attachment that is to be downloaded.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 下载消息的附件。
  ///
  /// 若附件自动下载失败，也可以调用此方法下载。
  ///
  /// Param [message] 要下载附件的消息。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<void> downloadMessageAttachmentInCombine(ChatMessage message) async {
    try {
      Map result = await platform_interface.Client.instance.chatManager.callNativeMethod(
          ChatMethodKeys.downloadMessageAttachmentInCombine,
          {"message": message.toJson()});
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Downloads the thumbnail if the message has not been downloaded before or if the download fails.
  ///
  /// Param [message] The message object.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 下载消息的缩略图。
  ///
  /// Param [message] 要下载缩略图的消息，一般图片消息和视频消息有缩略图。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<void> downloadMessageThumbnailInCombine(ChatMessage message) async {
    try {
      Map result = await platform_interface.Client.instance.chatManager.callNativeMethod(
          ChatMethodKeys.downloadMessageThumbnailInCombine,
          {"message": message.toJson()});
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets all conversations from the local database.
  ///
  /// Conversations will be first loaded from the cache. If no conversation is found, the SDK loads from the local database.
  ///
  /// **Return** All the conversations from the cache or local database.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 获取本地数据库中所有会话。
  ///
  /// 会先从内存中获取，如果没有会从本地数据库获取。
  ///
  /// **Return**  返回获取的会话。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<List<ChatConversation>> loadAllConversations() async {
    try {
      Map result = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.loadAllConversations);
      ChatError.hasErrorFromResult(result);
      List<ChatConversation> conversationList = [];
      result[ChatMethodKeys.loadAllConversations]?.forEach((element) {
        conversationList.add(ChatConversation.fromJson(element));
      });
      return conversationList;
    } catch (e) {
      rethrow;
    }
  }

  @Deprecated('Use [fetchConversationsByOptions] instead')

  /// ~english
  /// Gets the conversation list from the server.
  ///
  /// **Return** The conversation list of the current user.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取会话列表。
  ///
  /// **Return** 返回获取的会话列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<List<ChatConversation>> getConversationsFromServer() async {
    try {
      Map result = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.getConversationsFromServer);
      ChatError.hasErrorFromResult(result);
      List<ChatConversation> conversationList = [];
      result[ChatMethodKeys.getConversationsFromServer]?.forEach((element) {
        conversationList.add(ChatConversation.fromJson(element));
      });
      return conversationList;
    } catch (e) {
      rethrow;
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
  /// **Throws** A description of the exception. See [ChatError].
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
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<List<ChatConversation>> fetchConversationListFromServer({
    int pageNum = 1,
    int pageSize = 20,
  }) async {
    try {
      Map request = {
        "pageNum": pageNum,
        "pageSize": pageSize,
      };
      Map result = await platform_interface.Client.instance.chatManager.callNativeMethod(
          ChatMethodKeys.fetchConversationsFromServerWithPage, request);
      ChatError.hasErrorFromResult(result);
      List<ChatConversation> conversationList = [];
      result[ChatMethodKeys.fetchConversationsFromServerWithPage]
          ?.forEach((element) {
        conversationList.add(ChatConversation.fromJson(element));
      });
      return conversationList;
    } catch (e) {
      rethrow;
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
  /// **Throws** A description of the exception. See [ChatError].
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
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<ChatCursorResult<ChatConversation>> fetchConversation({
    String? cursor,
    int pageSize = 20,
  }) async {
    try {
      Map map = {
        "pageSize": pageSize,
      };
      map.putIfNotNull('cursor', cursor);
      Map result = await platform_interface.Client.instance.chatManager.callNativeMethod(
          ChatMethodKeys.getConversationsFromServerWithCursor, map);
      ChatError.hasErrorFromResult(result);
      return ChatCursorResult.fromJson(
          result[ChatMethodKeys.getConversationsFromServerWithCursor],
          dataItemCallback: (map) {
        return ChatConversation.fromJson(map);
      });
    } catch (e) {
      rethrow;
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
      required ChatConversationType type,
      required List<String> msgIds}) async {
    try {
      Map request = {
        "convId": conversationId,
        "type": type.index,
        "msgIds": msgIds,
      };
      Map result = await platform_interface.Client.instance.chatManager.callNativeMethod(
          ChatMethodKeys.removeMessagesFromServerWithMsgIds, request);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
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
      required ChatConversationType type,
      required int timestamp}) async {
    try {
      Map request = {
        "convId": conversationId,
        "type": type.index,
        "timestamp": timestamp,
      };
      Map result = await platform_interface.Client.instance.chatManager.callNativeMethod(
          ChatMethodKeys.removeMessagesFromServerWithTs, request);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
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
  /// **Throws** A description of the exception. See [ChatError].
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
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<bool> deleteConversation(
    String conversationId, {
    bool deleteMessages = true,
  }) async {
    try {
      Map req = {"convId": conversationId, "deleteMessages": deleteMessages};
      Map result = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.deleteConversation, req);
      ChatError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.deleteConversation);
    } catch (e) {
      rethrow;
    }
  }

  @Deprecated('Use [fetchHistoryMessagesByOption] instead')

  /// ~english
  /// Gets historical messages of the conversation from the server with pagination.
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// Param [type] The conversation type. See [ChatConversationType].
  ///
  /// Param [pageSize] The number of messages per page.
  ///
  /// Param [direction] The message search direction. See [ChatSearchDirection].
  ///
  /// Param [startMsgId] The ID of the message from which you start to get the historical messages. If `null` is passed, the SDK gets messages in the reverse chronological order.
  ///
  /// **Return** The obtained messages and the cursor for the next query.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器分页获取历史消息。
  ///
  /// Param [conversationId] 会话 ID。
  ///
  /// Param [type] 会话类型，详见[ChatConversationType]。
  ///
  /// Param [pageSize] 每页获取的消息数量。
  ///
  /// Param [direction] 要搜索的消息方向. 见 [ChatSearchDirection].
  ///
  /// Param [startMsgId] 获取历史消息的开始消息 ID，如果为空，从最新的消息向前开始获取。
  ///
  /// **Return** 返回消息列表和用于继续获取历史消息的 [ChatCursorResult]
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<ChatCursorResult<ChatMessage>> fetchHistoryMessages({
    required String conversationId,
    ChatConversationType type = ChatConversationType.Chat,
    int pageSize = 20,
    ChatSearchDirection direction = ChatSearchDirection.Up,
    String startMsgId = '',
  }) async {
    try {
      Map req = {};
      req['convId'] = conversationId;
      req['type'] = type.index;
      req['pageSize'] = pageSize;
      req['startMsgId'] = startMsgId;
      req['direction'] = direction.index;
      Map result = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.fetchHistoryMessages, req);
      ChatError.hasErrorFromResult(result);
      return ChatCursorResult<ChatMessage>.fromJson(
          result[ChatMethodKeys.fetchHistoryMessages],
          dataItemCallback: (value) {
        return ChatMessage.fromJson(value);
      });
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets historical messages of a conversation from the server according to [FetchMessageOptions].
  ///
  /// Param [conversationId] The conversation ID, which is the user ID of the peer user for one-to-one chat, but the group ID for group chat.
  ///
  /// Param [type] The conversation type. See [ChatConversationType].
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
  /// Param [type] 会话类型，详见 [ChatConversationType]
  ///
  /// Param [options] 查询历史消息的参数配置接口，详见 [FetchMessageOptions]。
  ///
  /// Param [cursor] 查询的起始游标位置。
  ///
  /// Param [pageSize] 每页期望获取的消息条数。取值范围为 [1,50]。
  /// ~end

  Future<ChatCursorResult<ChatMessage>> fetchHistoryMessagesByOption(
    String conversationId,
    ChatConversationType type, {
    FetchMessageOptions? options,
    String? cursor,
    int pageSize = 50,
  }) async {
    try {
      Map req = {};
      req.putIfNotNull('convId', conversationId);
      req.putIfNotNull('type', type.index);
      req.putIfNotNull('pageSize', pageSize);
      req.putIfNotNull('cursor', cursor);
      req.putIfNotNull('options', options?.toJson());
      Map result = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.fetchHistoryMessagesByOptions, req);
      ChatError.hasErrorFromResult(result);
      return ChatCursorResult<ChatMessage>.fromJson(
          result[ChatMethodKeys.fetchHistoryMessagesByOptions],
          dataItemCallback: (value) {
        return ChatMessage.fromJson(value);
      });
    } catch (e) {
      rethrow;
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
  /// Param [direction] The direction in which the message is loaded: ChatSearchDirection.
  /// `ChatSearchDirection.Up`: Gets the messages loaded before the timestamp of the specified message ID.
  /// `ChatSearchDirection.Down`: Gets the messages loaded after the timestamp of the specified message ID.
  ///
  /// **Returns** The list of retrieved messages.
  ///
  /// **Throws** A description of the exception. See [ChatError].
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
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<List<ChatMessage>> loadMessagesWithKeyword(
    String keywords, {
    String? sender,
    int timestamp = -1,
    int count = 20,
    MessageSearchScope searchScope = MessageSearchScope.All,
    ChatSearchDirection direction = ChatSearchDirection.Up,
  }) async {
    try {
      Map req = {};
      req["keywords"] = keywords;
      req['count'] = count;
      req['timestamp'] = timestamp;
      req['searchScope'] = MessageSearchScope.values.indexOf(searchScope);
      req['direction'] = direction.index;
      req.putIfNotNull("from", sender);

      Map result = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.searchChatMsgFromDB, req);
      ChatError.hasErrorFromResult(result);
      List<ChatMessage> list = [];
      result[ChatMethodKeys.searchChatMsgFromDB]?.forEach((element) {
        list.add(ChatMessage.fromJson(element));
      });
      return list;
    } catch (e) {
      rethrow;
    }
  }

  @Deprecated('Use [ChatManager.loadMessagesWithKeyword] instead.')

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
  /// **Throws** A description of the exception. See [ChatError].
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
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<List<ChatMessage>> searchMsgFromDB(
    String keywords, {
    int timestamp = -1,
    int maxCount = 20,
    String from = '',
    ChatSearchDirection direction = ChatSearchDirection.Up,
  }) async {
    try {
      Map req = {};
      req['keywords'] = keywords;
      req['timestamp'] = timestamp;
      req['maxCount'] = maxCount;
      req['from'] = from;
      req['direction'] = direction.index;

      Map result = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.searchChatMsgFromDB, req);
      ChatError.hasErrorFromResult(result);
      List<ChatMessage> list = [];
      result[ChatMethodKeys.searchChatMsgFromDB]?.forEach((element) {
        list.add(ChatMessage.fromJson(element));
      });
      return list;
    } catch (e) {
      rethrow;
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
  /// **Throws** A description of the exception. See [ChatError].
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
  /// **Return** 返回回执列表和用于下次获取群消息回执的 [ChatCursorResult]
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<ChatCursorResult<ChatGroupMessageAck>> fetchGroupAcks(
    String msgId,
    String groupId, {
    String? startAckId,
    int pageSize = 0,
  }) async {
    try {
      Map req = {"msgId": msgId, "group_id": groupId};
      req["pageSize"] = pageSize;
      req.putIfNotNull("ack_id", startAckId);

      Map result = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.asyncFetchGroupAcks, req);
      ChatError.hasErrorFromResult(result);
      ChatCursorResult<ChatGroupMessageAck> cursorResult = ChatCursorResult.fromJson(
        result[ChatMethodKeys.asyncFetchGroupAcks],
        dataItemCallback: (map) {
          return ChatGroupMessageAck.fromJson(map);
        },
      );

      return cursorResult;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Deletes the specified conversation and the related historical messages from the server.
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// Param [conversationType] The conversation type. See  [ChatConversationType].
  ///
  /// Param [isDeleteMessage] Whether to delete the chat history when deleting the conversation.
  /// - (default) `true`: Yes.
  /// - `false`: No.
  ///
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 删除服务端的指定 ID 的会话和聊天记录。
  ///
  /// Param [conversationId] 会话 ID。
  ///
  /// Param [conversationType] 会话类型，详见 [ChatConversationType]。
  ///
  /// Param [isDeleteMessage] 删除会话时是否同时删除历史消息记录。
  ///
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<void> deleteRemoteConversation(
    String conversationId, {
    ChatConversationType conversationType = ChatConversationType.Chat,
    bool isDeleteMessage = true,
  }) async {
    try {
      Map req = {};
      req["convId"] = conversationId;
      if (conversationType == ChatConversationType.Chat) {
        req["conversationType"] = 0;
      } else if (conversationType == ChatConversationType.GroupChat) {
        req["conversationType"] = 1;
      } else {
        req["conversationType"] = 2;
      }
      req["isDeleteRemoteMessage"] = isDeleteMessage;

      Map data = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.deleteRemoteConversation, req);
      ChatError.hasErrorFromResult(data);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Deletes messages with the timestamp that is before the specified one.
  ///
  /// Param [timestamp]  The specified Unix timestamp(milliseconds).
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 根据时间删除本地消息。
  ///
  /// Param [timestamp] 指定的Unix时间戳(毫秒)。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<void> deleteMessagesBefore(int timestamp) async {
    try {
      Map result = await platform_interface.Client.instance.chatManager.callNativeMethod(
          ChatMethodKeys.deleteMessagesBeforeTimestamp,
          {"timestamp": timestamp});
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
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
  /// **Throws** A description of the exception. See [ChatError].
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
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [ChatError]。
  /// ~end

  Future<void> reportMessage({
    required String messageId,
    required String tag,
    required String reason,
  }) async {
    try {
      Map req = {"msgId": messageId, "tag": tag, "reason": reason};
      Map result = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.reportMessage, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Adds a Reaction.
  ///
  /// Param [messageId] The message ID.
  ///
  /// Param [reaction] The Reaction content.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 添加 Reaction。
  ///
  /// Param [messageId] 要添加 Reaction 的消息 ID。
  ///
  /// Param [reaction] Reaction 的内容。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 详见 [ChatError]。
  /// ~end
  Future<void> addReaction({
    required String messageId,
    required String reaction,
  }) async {
    try {
      Map req = {"reaction": reaction, "msgId": messageId};
      Map result = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.addReaction, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Deletes a Reaction.
  ///
  /// Param [messageId] The message ID.
  ///
  /// Param [reaction] The Reaction content.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 删除 Reaction。
  ///
  /// Param [messageId] 添加了该 Reaction 的消息 ID。
  ///
  /// Param [reaction] 要删除的 Reaction。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [ChatError]。
  /// ~end

  Future<void> removeReaction({
    required String messageId,
    required String reaction,
  }) async {
    try {
      Map req = {"reaction": reaction, "msgId": messageId};
      Map result = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.removeReaction, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
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
  /// **Return** The Reaction list under the specified message ID（[ChatMessageReaction.userList] is the summary data, which only contains the information of the first three users）.
  ///
  /// **Throws** A description of the exception. See [ChatError].
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
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [ChatError]。
  /// ~end

  Future<Map<String, List<ChatMessageReaction>>> fetchReactionList({
    required List<String> messageIds,
    required ChatType chatType,
    String? groupId,
  }) async {
    try {
      Map req = {
        "msgIds": messageIds,
        "chatType": chatType.index,
      };
      req.putIfNotNull("groupId", groupId);
      Map result = await platform_interface.Client.instance.chatManager.callNativeMethod(
        ChatMethodKeys.fetchReactionList,
        req,
      );
      ChatError.hasErrorFromResult(result);
      Map<String, List<ChatMessageReaction>> ret = {};
      for (var info in result[ChatMethodKeys.fetchReactionList].entries) {
        List<ChatMessageReaction> reactions = [];
        for (var item in info.value) {
          reactions.add(ChatMessageReaction.fromJson(item));
        }
        ret[info.key] = reactions;
      }
      return ret;
    } catch (e) {
      rethrow;
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
  /// **Throws** A description of the exception. See [ChatError].
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
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [ChatError]。
  /// ~end

  Future<ChatCursorResult<ChatMessageReaction>> fetchReactionDetail({
    required String messageId,
    required String reaction,
    String? cursor,
    int pageSize = 20,
  }) async {
    try {
      Map req = {
        "msgId": messageId,
        "reaction": reaction,
      };
      req.putIfNotNull("cursor", cursor);
      req.putIfNotNull("pageSize", pageSize);
      Map result = await platform_interface.Client.instance.chatManager.callNativeMethod(
        ChatMethodKeys.fetchReactionDetail,
        req,
      );
      ChatError.hasErrorFromResult(result);
      final data = result[ChatMethodKeys.fetchReactionDetail];
      if (data != null) {
        return ChatCursorResult<ChatMessageReaction>.fromJson(data,
            dataItemCallback: (value) {
          return ChatMessageReaction.fromJson(value);
        });
      } else {
        return ChatCursorResult<ChatMessageReaction>(null, []);
      }
    } catch (e) {
      rethrow;
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
  /// **Throws** A description of the exception. See [ChatError].
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
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [ChatError]。
  /// ~end

  Future<ChatMessage> translateMessage({
    required ChatMessage msg,
    required List<String> languages,
  }) async {
    try {
      Map req = {};
      req["message"] = msg.toJson();
      req["languages"] = languages;
      Map result = await platform_interface.Client.instance.chatManager
          .callNativeMethod(ChatMethodKeys.translateMessage, req);
      ChatError.hasErrorFromResult(result);
      return ChatMessage.fromJson(result[ChatMethodKeys.translateMessage]);
    } catch (e) {
      rethrow;
    }
  }


/// ~english
/// Gets all languages supported by the translation service.
///
/// **Return** The supported languages.
///
/// **Throws** A description of the exception. See [ChatError].
/// ~end
///
/// ~chinese
/// 查询翻译服务支持的语言。
///
/// **Return** 翻译服务支持的语言列表。
///
/// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [ChatError]。
/// ~end

Future<List<ChatTranslateLanguage>> fetchSupportedLanguages() async {
  try {
    Map result = await platform_interface.Client.instance.chatManager
        .callNativeMethod(ChatMethodKeys.fetchSupportLanguages);
    ChatError.hasErrorFromResult(result);
    List<ChatTranslateLanguage> list = [];
    result[ChatMethodKeys.fetchSupportLanguages]?.forEach((element) {
      list.add(ChatTranslateLanguage.fromJson(element));
    });
    return list;
  } catch (e) {
    rethrow;
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
/// **Throws** A description of the exception. See [ChatError].
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
/// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
/// ~end
Future<ChatCursorResult<ChatConversation>> fetchPinnedConversations({
  String? cursor,
  int pageSize = 20,
}) async {
  try {
    Map map = {
      "pageSize": pageSize,
    };
    map.putIfNotNull('cursor', cursor);
    Map result = await platform_interface.Client.instance.chatManager.callNativeMethod(
      ChatMethodKeys.getPinnedConversationsFromServerWithCursor,
      map,
    );
    ChatError.hasErrorFromResult(result);
    return ChatCursorResult.fromJson(
        result[ChatMethodKeys.getPinnedConversationsFromServerWithCursor],
        dataItemCallback: (map) {
      return ChatConversation.fromJson(map);
    });
  } catch (e) {
    rethrow;
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
/// **Throws** A description of the exception. See [ChatError].
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
/// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
/// ~end

Future<void> pinConversation(
    {required String conversationId, required bool isPinned}) async {
  try {
    Map map = {
      'convId': conversationId,
      'isPinned': isPinned,
    };

    Map result = await platform_interface.Client.instance.chatManager.callNativeMethod(
      ChatMethodKeys.pinConversation,
      map,
    );
    ChatError.hasErrorFromResult(result);
  } catch (e) {
    rethrow;
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
/// Param [msgBody]  The modified message body [ChatMessageBody], only [ChatTextMessageBody] and [ChatCustomMessageBody] are supported.
///
/// Param [attributes] The custom attributes of the message.
///
/// **Return** The modified message.
///
/// **Throws** A description of the exception. See [ChatError].
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
/// Param [msgBody] 息体实例 [ChatMessageBody], 只支持 [ChatTextMessageBody], [ChatCustomMessageBody]。
///
/// Param [attributes] 消息的扩展字段
///
/// **Return** 修改后的消息实例。
///
/// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
/// ~end

Future<ChatMessage> modifyMessage({
  required String messageId,
  ChatMessageBody? msgBody,
  Map<String, dynamic>? attributes,
}) async {
  try {
    Map map = {'msgId': messageId};
    map.putIfNotNull('msgBody', msgBody?.toJson());
    map.putIfNotNull('attributes', attributes);

    Map result = await platform_interface.Client.instance.chatManager.callNativeMethod(
      ChatMethodKeys.modifyMessage,
      map,
    );
    ChatError.hasErrorFromResult(result);
    return ChatMessage.fromJson(result[ChatMethodKeys.modifyMessage]);
  } catch (e) {
    rethrow;
  }
}

/// ~english
/// Gets the details of a combined message.
///
/// Param [message] The combined message.
///
/// **Return** The list of original messages included in the combined message.
///
/// **Throws** A description of the exception. See [ChatError].
/// ~end
///
/// ~chinese
/// 获取合并消息的详情。
///
/// Param [message] 合并消息。
///
/// **Return** 合并消息包含的原始消息列表。
///
/// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
/// ~end

Future<List<ChatMessage>> fetchCombineMessageDetail({
  required ChatMessage message,
}) async {
  try {
    Map map = {
      'message': message.toJson(),
    };

    Map result = await platform_interface.Client.instance.chatManager.callNativeMethod(
      ChatMethodKeys.downloadAndParseCombineMessage,
      map,
    );

    ChatError.hasErrorFromResult(result);
    List<ChatMessage> messages = [];
    List list = result[ChatMethodKeys.downloadAndParseCombineMessage];
    for (var element in list) {
      messages.add(ChatMessage.fromJson(element));
    }
    return messages;
  } catch (e) {
    rethrow;
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
/// **Throws** A description of the exception. See [ChatError].
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
/// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
///
/// ~end

Future<void> addRemoteAndLocalConversationsMark({
  required List<String> conversationIds,
  required ConversationMarkType mark,
}) async {
  try {
    Map map = {
      'convIds': conversationIds,
      'mark': mark.index,
    };

    Map result = await platform_interface.Client.instance.chatManager.callNativeMethod(
      ChatMethodKeys.addRemoteAndLocalConversationsMark,
      map,
    );
    ChatError.hasErrorFromResult(result);
  } catch (e) {
    rethrow;
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
  try {
    Map map = {
      'convIds': conversationIds,
      'mark': mark.index,
    };

    Map result = await platform_interface.Client.instance.chatManager.callNativeMethod(
      ChatMethodKeys.deleteRemoteAndLocalConversationsMark,
      map,
    );

    ChatError.hasErrorFromResult(result);
  } catch (e) {
    rethrow;
  }
}

/// ~english
/// Gets conversations from the server by conversation filter options.
///
/// Param [options] The conversation filter options. See [ConversationFetchOptions].
/// Returns The list of retrieved conversations.
/// Throws A description of the exception. See [ChatError].
/// ~end
/// ~chinese
/// 根据会话过滤选项获取服务端的会话。
/// Param [options] 会话过滤选项, 详见 [ConversationFetchOptions]。
/// Returns 会话列表。
/// Throws 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
/// ~end

Future<ChatCursorResult<ChatConversation>> fetchConversationsByOptions({
  required ConversationFetchOptions options,
}) async {
  try {
    Map req = options.toJson();
    Map result = await platform_interface.Client.instance.chatManager
        .callNativeMethod(ChatMethodKeys.fetchConversationsByOptions, req);
    ChatError.hasErrorFromResult(result);
    return ChatCursorResult<ChatConversation>.fromJson(
        result[ChatMethodKeys.fetchConversationsByOptions],
        dataItemCallback: (value) {
      return ChatConversation.fromJson(value);
    });
  } catch (e) {
    rethrow;
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
  try {
    Map result = await platform_interface.Client.instance.chatManager
        .callNativeMethod(ChatMethodKeys.deleteAllMessageAndConversation, {
      'clearServerData': clearServerData,
    });
    ChatError.hasErrorFromResult(result);
  } catch (e) {
    rethrow;
  }
}

/// ~english
/// Pins a message.
/// Param [messageId] The message ID.
///
/// Throws A description of the exception. See [ChatError].
/// ~end
///
/// ~chinese
/// 置顶消息。
/// Param [messageId] 消息 ID。
///
/// Throws 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
/// ~end

Future<void> pinMessage({required String messageId}) async {
  try {
    Map map = {'msgId': messageId};
    Map result = await platform_interface.Client.instance.chatManager.callNativeMethod(
      ChatMethodKeys.pinMessage,
      map,
    );
    ChatError.hasErrorFromResult(result);
  } catch (e) {
    rethrow;
  }
}

/// ~english
/// Unpins a message.
///
/// Param [messageId] The message ID.
///
/// Throws A description of the exception. See [ChatError].
/// ~end
/// ~chinese
/// 取消置顶消息。
///
/// Param [messageId] 消息 ID。
///
/// Throws 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
/// ~end

Future<void> unpinMessage({required String messageId}) async {
  try {
    Map map = {'msgId': messageId};
    Map result = await platform_interface.Client.instance.chatManager.callNativeMethod(
      ChatMethodKeys.unpinMessage,
      map,
    );
    ChatError.hasErrorFromResult(result);
  } catch (e) {
    rethrow;
  }
}

/// ~english
/// Gets the list of pinned messages from the server.
///
/// Param [conversationId] The conversation ID.
/// Returns The list of pinned messages.
/// Throws A description of the exception. See [ChatError].
/// ~end
/// ~chinese
/// 从服务端获取置顶消息。
///
/// Param [conversationId] 会话 ID。
/// Returns 置顶消息列表。
/// Throws 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
/// ~end

Future<List<ChatMessage>> fetchPinnedMessages(
    {required String conversationId}) async {
  try {
    Map map = {'convId': conversationId};
    Map result = await platform_interface.Client.instance.chatManager.callNativeMethod(
      ChatMethodKeys.fetchPinnedMessages,
      map,
    );
    ChatError.hasErrorFromResult(result);
    List<ChatMessage> messages = [];
    List list = result[ChatMethodKeys.fetchPinnedMessages];
    for (var element in list) {
      messages.add(ChatMessage.fromJson(element));
    }
    return messages;
  } catch (e) {
    rethrow;
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
/// **Throws** A description of the exception. See [ChatError].
/// ~end
///
/// ~chinese
/// 通过类型从数据库获取消息。
///
/// Param [options] 搜索配置项, 详情查看 [MessageSearchOptions].
///
/// **Return** 消息列表。
///
/// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
/// ~end

Future<List<ChatMessage>> searchMsgsByOptions(
    MessageSearchOptions options) async {
  try {
    Map req = {};
    req['ts'] = options.ts;
    req['count'] = options.count;
    req['direction'] = options.direction.index;
    req.putIfNotNull("from", options.from);
    req['types'] = options.types.map((e) => e.index).toList();
    Map result = await platform_interface.Client.instance.chatManager
        .callNativeMethod(ChatMethodKeys.searchMsgsByOptions, req);
    ChatError.hasErrorFromResult(result);
    List<ChatMessage> messages = [];
    List list = result[ChatMethodKeys.searchMsgsByOptions];
    for (var element in list) {
      messages.add(ChatMessage.fromJson(element));
    }
    return messages;
  } catch (e) {
    rethrow;
  }
}
}

Future<int> getAllMessageCount() async {
  try {
    Map result = await platform_interface.Client.instance.chatManager
        .callNativeMethod(ChatMethodKeys.getMessageCount);
    ChatError.hasErrorFromResult(result);
    if (result.containsKey(ChatMethodKeys.getMessageCount)) {
      return result[ChatMethodKeys.getMessageCount];
    } else {
      return 0;
    }
  } catch (e) {
    rethrow;
  }
}

Future<Map<String, List<String>>> loadConversationMessagesWithKeyword({
  String? keyword,
  int timestamp = -1,
  String? sender,
  ChatSearchDirection direction = ChatSearchDirection.Up,
  MessageSearchScope scope = MessageSearchScope.All,
}) async {
  try {
    Map req = {};
    req.putIfNotNull("keyword", keyword);
    req["timestamp"] = timestamp;
    req.putIfNotNull("sender", sender);
    req["direction"] = direction.index;
    req["scope"] = scope.index;
    Map result = await platform_interface.Client.instance.chatManager.callNativeMethod(
        ChatMethodKeys.loadConversationMessagesWithKeyword, req);
    ChatError.hasErrorFromResult(result);
    Map<String, List<String>> resultMap = {};
    Map? data = result[ChatMethodKeys.loadConversationMessagesWithKeyword];
    if (data != null) {
      data.forEach((key, value) {
        resultMap[key] = List<String>.from(value);
      });
    }
    return resultMap;
  } catch (e) {
    rethrow;
  }
}

class MessageCallBackManager {
  static const _channelPrefix = 'com.chat.im';
  static const MethodChannel _emMessageChannel =
      MethodChannel('$_channelPrefix/chat_message', JSONMethodCodec());
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
          ChatMessage msg = ChatMessage.fromJson(argMap['message']);
          ChatError err = ChatError.fromJson(argMap['error']);
          value.onError?.call(localId, msg, err);
        } else if (call.method == ChatMethodKeys.onMessageSuccess) {
          ChatMessage msg = ChatMessage.fromJson(argMap['message']);
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
