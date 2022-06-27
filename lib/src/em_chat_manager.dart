import "dart:async";

import 'package:flutter/services.dart';

import 'internal/inner_headers.dart';

///
/// 聊天管理类，该类负责管理会话（加载，删除等）、发送消息、下载消息附件等。
///
/// 比如，发送一条文本消息：
///
/// ```dart
///    EMMessage msg = EMMessage.createTxtSendMessage(
///        targetId: toChatUsername, content: content);
///    await EMClient.getInstance.chatManager.sendMessage(msg);
/// ```
///
class EMChatManager {
  final List<EMChatManagerListener> _listeners = [];

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
  /// 发送消息。
  ///
  /// **Note**
  /// 如果是语音，图片类等有附件的消息，SDK 会自动上传附件。
  /// 可以通过 {@link EMOptions#serverTransfer(boolean)} 设置是否上传到聊天服务器。
  ///
  /// 发送消息的状态，可以通过设置 {@link EMMessage#setMessageStatusListener(EMMessageStatusListener)} 进行监听。
  ///
  /// Param [message] 待发送消息对象，不能为空。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
  /// 重发消息。
  ///
  /// Param [message] 需要重发的消息。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
  /// 发送消息的已读回执，该方法只针对单聊会话。
  ///
  /// **Warning**
  /// 该方法只有在 {@link EMOptions#requireAck(bool)} 为 `true` 时才生效。
  ///
  /// **Note**
  /// 群消息已读回执，详见 {@link #sendGroupMessageReadAck(String, String, String)}。
  ///
  /// 推荐进入会话页面时调用 {@link #sendConversationReadAck(String)}，其他情况下调用该方法以减少调用频率。
  ///
  /// Param [message] The message body.
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
  /// 发送群消息已读回执。
  ///
  /// 前提条件：设置了{@link EMOptions#requireAck(bool)} 和 {@link EMMessage#needGroupAck(bool)}。
  ///
  /// **Note**
  /// 发送单聊消息已读回执，详见 {@link #sendMessageReadAck(EMMessage)}；
  /// 会话已读回执，详见 {@link #sendConversationReadAck(String)}。
  ///
  /// Param [msgId] 消息 ID。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [content] 扩展信息。用户自己定义的关键字，接收后，解析出自定义的字符串，可以自行处理。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
    req.setValueWithOutNull("content", content);

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
  /// 发送会话的已读回执，该方法只针对单聊会话。
  ///
  /// 该方法会通知服务器将此会话未读数设置为 0，对话方（包含多端多设备）将会在下面这个回调方法中接收到回调：
  /// {@link EMChatManagerListener#onConversationRead(String, String)}。
  ///
  /// **Note**
  /// 发送群组消息已读回执见 {@link #sendGroupMessageReadAck(String, String, String)}。
  ///
  /// Param [conversationId] 会话 ID。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
  /// 撤回发送成功的消息。
  ///
  /// Param [messageId] 消息 ID。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
  /// 从本地数据库获取指定 ID 的消息对象。
  ///
  /// Param [messageId] 消息 ID。
  ///
  /// **Return** 根据指定 ID 获取的消息对象，如果消息不存在会返回空值。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
  /// 根据指定会话 ID 和类型的会话对象。
  ///
  /// 没有找到会返回空值。
  ///
  /// Param [conversationId] 会话 ID。
  ///
  /// Param [type] 会话类型，详见 {@link EMConversationType}。
  ///
  /// Param [createIfNeed] 没找到相应会话时是否自动创建。
  ///                        - （Default)`true` 表示没有找到相应会话时会自动创建会话；
  ///                        - `false` 表示没有找到相应会话时不创建会话。
  ///
  ///
  /// **Return**  根据指定 ID 以及会话类型找到的会话对象，如果没有找到会返回空值。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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

  ///
  /// 把所有的会话都设成已读。
  ///
  /// 这里针对的是本地会话。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
  /// 获取未读消息数。
  ///
  /// **Return** 未读消息数。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
  /// 更新本地消息。
  ///
  /// 会同时更新本地内存和数据库。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
  ///  向消息数据库导入多条聊天记录。
  ///  在调用此函数时要保证，消息的发送方或者接收方是当前用户。
  ///  已经对函数做过速度优化，推荐一次导入 1,000 条以内的数据。
  ///
  /// Param [messages] 需要导入数据库的消息。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
  /// 下载消息的附件。
  ///
  /// 未成功下载的附件，可调用此方法再次下载。
  ///
  /// Param [message] 要下载附件的消息。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
  /// 下载消息的缩略图。
  ///
  /// Param [message] 要下载缩略图的消息，一般图片消息和视频消息有缩略图。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
  /// 获取本地数据库中所有会话。
  ///
  /// 会先从内存中获取，如果没有会从本地数据库获取。
  ///
  /// **Return**  返回获取的会话。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
  /// 从服务器获取会话列表。
  ///
  /// 该功能需联系商务开通，开通后，用户默认可拉取 7 天内的 10 个会话（每个会话包含最新一条历史消息），如需调整会话数量或时间限制请联系商务经理。
  ///
  /// **Return** 返回获取的会话列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
  /// 删除指定 ID 的对话和本地的聊天记录。
  ///
  /// Param [conversationId] 会话 ID。
  ///
  /// Param [deleteMessages] 删除会话时是否同时删除本地的聊天记录。
  ///                         - `true` 表示删除；
  ///                         - `false` 表示不删除。
  ///
  /// **Return** 删除会话结果。
  ///                        - `true` 代表删除成功；
  ///                        - `false` 代表删除失败。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
  ///
  Future<bool> deleteConversation(
    String conversationId, {
    bool deleteMessages = true,
  }) async {
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
  /// 注册消息监听。
  ///
  /// 接受到新消息等回调可以通过设置此方法进行监听，详见 {@link EMChatManagerListener}。
  ///
  /// Param [listener] 要注册的消息监听，详见 {@link EMChatManagerListener}。
  ///
  void addChatManagerListener(EMChatManagerListener listener) {
    _listeners.remove(listener);
    _listeners.add(listener);
  }

  ///
  /// 移除消息监听。
  ///
  /// 需要先添加 {@link #addMessageListener(addChatManagerListener)} 监听，再调用本方法。
  ///
  /// Param [listener] 要移除的监听。
  ///
  void removeChatManagerListener(EMChatManagerListener listener) {
    _listeners.remove(listener);
  }

  ///
  /// 移除所有消息监听。
  ///
  void clearAllChatManagerListeners() {
    _listeners.clear();
  }

  ///
  /// 从服务器获取指定会话的消息历史记录。
  ///
  /// 分页获取。
  ///
  /// Param [conversationId] 会话 ID。
  ///
  /// Param [type] 会话类型，详见 {@link EMConversationType}。
  ///
  /// Param [pageSize] 每页获取的消息数量。
  ///
  /// Param [startMsgId] 获取历史消息的开始消息 ID，如果为空，从最新的消息向前开始获取。
  ///
  /// **Return** 返回消息列表和用于继续获取历史消息的 Cursor。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
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
  /// 根据传入的参数从本地存储中搜索指定数量的消息。
  ///
  /// 注意：当 maxCount 非常大时，需要考虑内存消耗，目前限制一次最多搜索 400 条数据。
  ///
  /// Param [keywords] 关键词。
  ///
  /// Param [timeStamp] 搜索消息的时间点，Unix 时间戳。
  ///
  /// Param [maxCount] 搜索结果的最大条数。
  ///
  /// Param [from] 搜索来自某人或者某群的消息，一般是指会话 ID。
  ///
  /// **Return**  获取的消息列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
  /// 从服务器获取群组消息回执详情。
  ///
  /// 分页获取。
  ///
  /// **Note**
  /// 发送群组消息回执，详见 {@link {@link #sendConversationReadAck(String)}。
  ///
  /// Param [msgId] 消息 ID。
  ///
  /// Param [startAckId] 已读回执的 ID，如果为空，从最新的回执向前开始获取。
  ///
  /// Param [pageSize] 每页获取群消息已读回执的条数。
  ///
  /// **Return** 返回回执列表和用于下次获取群消息回执的 cursor。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
  ///
  Future<EMCursorResult<EMGroupMessageAck>> fetchGroupAcks(
    String msgId,
    String groupId, {
    String? startAckId,
    int pageSize = 0,
  }) async {
    Map req = {"msg_id": msgId, "group_id": groupId};
    req["pageSize"] = pageSize;
    req.setValueWithOutNull("ack_id", startAckId);

    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.asyncFetchGroupAcks, req);

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
  /// 删除服务端的指定 ID 的会话和聊天记录。
  ///
  /// Param [conversationId] 会话 ID。
  ///
  /// Param [conversationType] 会话类型，详见 {@link EMConversationType}。
  ///
  /// Param [isDeleteMessage] 删除会话时是否同时删除历史消息记录。
  ///
  /// - `true`:(default)：是；
  /// - `false`: 否。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 {@link EMError}。
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
    for (var listener in _listeners) {
      listener.onMessagesReceived(messageList);
    }
  }

  Future<void> _onCmdMessagesReceived(List messages) async {
    List<EMMessage> list = [];
    for (var message in messages) {
      list.add(EMMessage.fromJson(message));
    }
    for (var listener in _listeners) {
      listener.onCmdMessagesReceived(list);
    }
  }

  Future<void> _onMessagesRead(List messages) async {
    List<EMMessage> list = [];
    for (var message in messages) {
      list.add(EMMessage.fromJson(message));
    }
    for (var listener in _listeners) {
      listener.onMessagesRead(list);
    }
  }

  Future<void> _onGroupMessageRead(List messages) async {
    List<EMGroupMessageAck> list = [];
    for (var message in messages) {
      list.add(EMGroupMessageAck.fromJson(message));
    }
    for (var listener in _listeners) {
      listener.onGroupMessageRead(list);
    }
  }

  Future<void> _onReadAckForGroupMessageUpdated(List messages) async {
    for (var listener in _listeners) {
      listener.onReadAckForGroupMessageUpdated();
    }
  }

  Future<void> _onMessagesDelivered(List messages) async {
    List<EMMessage> list = [];
    for (var message in messages) {
      list.add(EMMessage.fromJson(message));
    }
    for (var listener in _listeners) {
      listener.onMessagesDelivered(list);
    }
  }

  Future<void> _onMessagesRecalled(List messages) async {
    List<EMMessage> list = [];
    for (var message in messages) {
      list.add(EMMessage.fromJson(message));
    }
    for (var listener in _listeners) {
      listener.onMessagesRecalled(list);
    }
  }

  Future<void> _onConversationsUpdate(dynamic obj) async {
    for (var listener in _listeners) {
      listener.onConversationsUpdate();
    }
  }

  Future<void> _onConversationHasRead(dynamic obj) async {
    for (var listener in _listeners) {
      String from = (obj as Map)['from'];
      String to = obj['to'];
      listener.onConversationRead(from, to);
    }
  }

  Future<void> _messageReactionDidChange(List reactionChangeList) async {
    List<EMMessageReactionEvent> list = [];
    for (var reactionChange in reactionChangeList) {
      list.add(EMMessageReactionEvent.fromJson(reactionChange));
    }
    for (var listener in _listeners) {
      listener.onMessageReactionDidChange(list);
    }
  }

  ///// Moderation

  ///
  /// Report violation message
  ///
  /// Param [messageId] Violation Message ID
  ///
  /// Param [tag] The report type (For example: involving pornography and terrorism).
  ///
  /// Param [reason] The reason for reporting.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> reportMessage({
    required String messageId,
    required String tag,
    required String reason,
  }) async {
    Map req = {"msgId": messageId, "tag": tag, "reason": reason};
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.reportMessage, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  //// Reaction

  ///
  /// Adds a reaction.
  ///
  /// Param [messageId] The message ID.
  ///
  /// Param [reaction] The reaction content.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> addReaction({
    required String messageId,
    required String reaction,
  }) async {
    Map req = {"reaction": reaction, "msgId": messageId};
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.addReaction, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Deletes a reaction.
  ///
  /// This is a synchronous method and blocks the current thread.
  ///
  /// Param [messageId] The message ID.
  ///
  /// Param [reaction] The reaction content.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> removeReaction({
    required String messageId,
    required String reaction,
  }) async {
    Map req = {"reaction": reaction, "msgId": messageId};
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.removeReaction, req);
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
  /// Param [chatType] The chat type. Only one-to-one chat ({@link EMMessage.ChatType#Chat} and group chat ({@link EMMessage.ChatType#GroupChat}) are allowed.
  ///
  /// Param [groupId] which is invalid only when the chat type is group chat.
  ///
  /// **Return** The Reaction list under the specified message ID（The UserList of EMMessageReaction is the summary data, which only contains the information of the first three users）.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
    req.setValueWithOutNull("groupId", groupId);
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.fetchReactionList, req);

    try {
      EMError.hasErrorFromResult(result);
      Map<String, List<EMMessageReaction>> ret = {};
      for (var info in result.entries) {
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
  /// **Throws**  A description of the exception. See {@link EMError}.
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
    req.setValueWithOutNull("cursor", cursor);
    req.setValueWithOutNull("pageSize", pageSize);
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.fetchReactionDetail, req);

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
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<EMMessage> translateMessage({
    required EMMessage msg,
    required List<String> languages,
  }) async {
    Map req = {};
    req["message"] = msg.toJson();
    req["languages"] = languages;
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.translateMessage, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMMessage.fromJson(result["message"]);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Fetch all languages what the translate service support
  ///
  /// **Return** Supported languages
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<List<EMTranslateLanguage>> fetchSupportedLanguages() async {
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.fetchSupportLanguages);
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
}
