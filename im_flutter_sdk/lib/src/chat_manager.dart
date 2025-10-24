import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';

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
    return Client.instance.chatManager.addEventHandler(identifier, handler);
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
    return Client.instance.chatManager.removeEventHandler(identifier);
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
    return Client.instance.chatManager.getEventHandler(identifier);
  }

  /// ~english
  /// Clear all chat event handlers.
  /// ~end
  ///
  /// ~chinese
  /// 清除所有事件监听。
  /// ~end
  void clearEventHandlers() {
    return Client.instance.chatManager.clearEventHandlers();
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
    return Client.instance.chatManager.addMessageEvent(identifier, event);
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
    return Client.instance.chatManager.removeMessageEvent(identifier);
  }

  /// ~english
  /// Clears all message status listeners.
  /// ~end
  ///
  /// ~chinese
  /// 清空所有消息状态监听。
  /// ~end
  void clearMessageEvent() {
    return Client.instance.chatManager.clearMessageEvent();
  }

  /// ~english
  /// Sends a message.
  ///
  /// **Note**
  /// For attachment messages such as voice, image, or video messages, the SDK automatically uploads the attachment.
  /// You can set whether to upload the attachment to the chat sever using [EMOptions.serverTransfer].
  ///
  /// To listen for the status of sending messages, call [ChatManager.addMessageEvent].
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
  /// 添加发送状态监听使用 [ChatManager.addMessageEvent].
  ///
  /// Param [message] 需要发送的消息 [EMMessage].
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end

  Future<EMMessage> sendMessage(EMMessage message) async {
    return Client.instance.chatManager.sendMessage(message);
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
    return Client.instance.chatManager.resendMessage(message);
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
    return Client.instance.chatManager.sendMessageReadAck(message);
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
    return Client.instance.chatManager
        .sendGroupMessageReadAck(msgId, groupId, content: content);
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
    return Client.instance.chatManager.sendConversationReadAck(conversationId);
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
    return Client.instance.chatManager.recallMessage(messageId, ext: ext);
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
    return Client.instance.chatManager.loadMessage(messageId);
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
    return Client.instance.chatManager.getConversation(conversationId,
        type: type, createIfNeed: createIfNeed);
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
    return Client.instance.chatManager.getThreadConversation(threadId);
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
    return Client.instance.chatManager.markAllConversationsAsRead();
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
    return Client.instance.chatManager.getUnreadMessageCount();
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
    return Client.instance.chatManager.updateMessage(message);
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
    return Client.instance.chatManager.importMessages(messages);
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
    return Client.instance.chatManager.downloadAttachment(message);
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
    return Client.instance.chatManager.downloadThumbnail(message);
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
    return Client.instance.chatManager
        .downloadMessageAttachmentInCombine(message);
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
    return Client.instance.chatManager
        .downloadMessageThumbnailInCombine(message);
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
    return Client.instance.chatManager.loadAllConversations();
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
    return Client.instance.chatManager.getConversationsFromServer();
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
    return Client.instance.chatManager
        .fetchConversationListFromServer(pageNum: pageNum, pageSize: pageSize);
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
    return Client.instance.chatManager
        .fetchConversation(cursor: cursor, pageSize: pageSize);
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

  Future<void> deleteRemoteMessagesWithIds({
    required String conversationId,
    required EMConversationType type,
    required List<String> msgIds,
  }) async {
    return Client.instance.chatManager.deleteRemoteMessagesWithIds(
        conversationId: conversationId, type: type, msgIds: msgIds);
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

  Future<void> deleteRemoteMessagesBefore({
    required String conversationId,
    required EMConversationType type,
    required int timestamp,
  }) async {
    return Client.instance.chatManager.deleteRemoteMessagesBefore(
        conversationId: conversationId, type: type, timestamp: timestamp);
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
    return Client.instance.chatManager
        .deleteConversation(conversationId, deleteMessages: deleteMessages);
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
    return Client.instance.chatManager.fetchHistoryMessages(
        conversationId: conversationId,
        type: type,
        pageSize: pageSize,
        direction: direction,
        startMsgId: startMsgId);
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
    return Client.instance.chatManager.fetchHistoryMessagesByOption(
        conversationId, type,
        options: options, cursor: cursor, pageSize: pageSize);
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
    return Client.instance.chatManager.loadMessagesWithKeyword(keywords,
        sender: sender,
        timestamp: timestamp,
        count: count,
        searchScope: searchScope,
        direction: direction);
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
    return Client.instance.chatManager.searchMsgFromDB(keywords,
        timestamp: timestamp,
        maxCount: maxCount,
        from: from,
        direction: direction);
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
    return Client.instance.chatManager.fetchGroupAcks(msgId, groupId,
        startAckId: startAckId, pageSize: pageSize);
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
    return Client.instance.chatManager.deleteRemoteConversation(conversationId,
        conversationType: conversationType, isDeleteMessage: isDeleteMessage);
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
    return Client.instance.chatManager.deleteMessagesBefore(timestamp);
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
    return Client.instance.chatManager
        .reportMessage(messageId: messageId, tag: tag, reason: reason);
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
    return Client.instance.chatManager
        .addReaction(messageId: messageId, reaction: reaction);
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
    return Client.instance.chatManager
        .removeReaction(messageId: messageId, reaction: reaction);
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
    return Client.instance.chatManager.fetchReactionList(
        messageIds: messageIds, chatType: chatType, groupId: groupId);
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
    return Client.instance.chatManager.fetchReactionDetail(
        messageId: messageId,
        reaction: reaction,
        cursor: cursor,
        pageSize: pageSize);
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
    return Client.instance.chatManager
        .translateMessage(msg: msg, languages: languages);
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
    return Client.instance.chatManager.fetchSupportedLanguages();
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
    return Client.instance.chatManager
        .fetchPinnedConversations(cursor: cursor, pageSize: pageSize);
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

  Future<void> pinConversation({
    required String conversationId,
    required bool isPinned,
  }) async {
    return Client.instance.chatManager
        .pinConversation(conversationId: conversationId, isPinned: isPinned);
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
  /// Param [msgBody]  The modified message body [EMMessageBody], only [EMTextMessageBody] and [EMCustomMessageBody] are supported.
  ///
  /// Param [attributes] The custom attributes of the message.
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
  /// Param [msgBody] 息体实例 [EMMessageBody], 只支持 [EMTextMessageBody], [EMCustomMessageBody]。
  ///
  /// Param [attributes] 消息的扩展字段
  ///
  /// **Return** 修改后的消息实例。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<EMMessage> modifyMessage({
    required String messageId,
    EMMessageBody? msgBody,
    Map<String, dynamic>? attributes,
  }) async {
    assert(
      msgBody == null ||
          msgBody.type == MessageType.TXT ||
          msgBody.type == MessageType.CUSTOM,
      'Only support EMTextMessageBody and EMCustomMessageBody',
    );
    return Client.instance.chatManager.modifyMessage(
      messageId: messageId,
      msgBody: msgBody,
      attributes: attributes,
    );
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
    return Client.instance.chatManager
        .fetchCombineMessageDetail(message: message);
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
    return Client.instance.chatManager.addRemoteAndLocalConversationsMark(
        conversationIds: conversationIds, mark: mark);
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
    return Client.instance.chatManager.deleteRemoteAndLocalConversationsMark(
        conversationIds: conversationIds, mark: mark);
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
    return Client.instance.chatManager
        .fetchConversationsByOptions(options: options);
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

  Future<void> deleteAllMessageAndConversation({
    bool clearServerData = false,
  }) async {
    return Client.instance.chatManager
        .deleteAllMessageAndConversation(clearServerData: clearServerData);
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
    return Client.instance.chatManager.pinMessage(messageId: messageId);
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
    return Client.instance.chatManager.unpinMessage(messageId: messageId);
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

  Future<List<EMMessage>> fetchPinnedMessages({
    required String conversationId,
  }) async {
    return Client.instance.chatManager
        .fetchPinnedMessages(conversationId: conversationId);
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
    return Client.instance.chatManager.searchMsgsByOptions(options);
  }

  Future<int> getAllMessageCount() async {
    return Client.instance.chatManager.getAllMessageCount();
  }

  /// ~english
  /// Loads conversation messages with the specified keyword from the local database.
  ///
  /// Returns a map of conversation IDs and their corresponding message ID lists.
  /// The message ID list is sorted according to the `direction` parameter.
  ///
  /// Param [keyword] The search keyword. Set it to `null` to ignore this parameter.
  ///
  /// Param [timestamp] The starting Unix timestamp for the search, in milliseconds.
  /// If the timestamp is negative, the SDK retrieves messages from the latest one.
  ///
  /// Param [sender] The message sender. Set it to `null` to ignore this parameter.
  ///
  /// Param [direction] The message search direction. See [EMSearchDirection].
  /// - (Default) `Up`: Retrieve messages in the reverse chronological order of the timestamp.
  /// - `Down`: Retrieve messages in the chronological order of the timestamp.
  ///
  /// Param [scope] The message search scope. See [MessageSearchScope].
  ///
  /// **Return** A map where the key is the conversation ID and the value is the list of message IDs.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 通过关键词从本地数据库中获取消息，返回会话 ID 及消息 ID 列表的映射关系。
  ///
  /// 消息ID列表按 `direction` 设置的方向排列。
  ///
  /// Param [keyword] 搜索关键词，设为 `null` 表示忽略该参数。
  ///
  /// Param [timestamp] 搜索开始的 Unix 时间戳。单位为毫秒。如果该参数设置的时间戳为负数，则从最新消息向前获取。
  ///
  /// Param [sender] 消息发送方。设为 `null` 表示忽略该参数。
  ///
  /// Param [direction] 消息搜索方向。详见 [EMSearchDirection]。
  /// - （默认）`Up`：按消息时间戳的逆序获取。
  /// - `Down`：按消息时间戳的顺序获取。
  ///
  /// Param [scope] 消息搜索范围。详见 [MessageSearchScope]。
  ///
  /// **Return** 会话 ID 及消息 ID 列表的映射关系。键为会话 ID，值为消息 ID 列表。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<Map<String, List<String>>> loadConversationMessagesWithKeyword({
    String? keyword,
    int timestamp = -1,
    String? sender,
    EMSearchDirection direction = EMSearchDirection.Up,
    MessageSearchScope scope = MessageSearchScope.All,
  }) async {
    return Client.instance.chatManager.loadConversationMessagesWithKeyword(
      keyword: keyword,
      timestamp: timestamp,
      sender: sender,
      direction: direction,
      scope: scope,
    );
  }
}
