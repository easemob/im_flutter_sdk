// ignore_for_file: deprecated_member_use_from_same_package

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
  final Map<String, EMChatEventHandler> _eventHandlesMap = {};

  final List<EMChatEventHandler> _listeners = [];

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
  /// 添加 [EMChatEventHandler] 。
  ///
  /// Param [identifier] handler对应的id，可用于删除handler。
  ///
  /// Param [handler] 添加的 [EMChatEventHandler]。
  ///
  void addEventHandler(
    String identifier,
    EMChatEventHandler handler,
  ) {
    _eventHandlesMap[identifier] = handler;
  }

  ///
  /// 移除 [EMChatEventHandler] 。
  ///
  /// Param [identifier] 需要移除 handler 对应的 id。
  ///
  void removeEventHandler(String identifier) {
    _eventHandlesMap.remove(identifier);
  }

  ///
  /// 获取 [EMChatEventHandler] 。
  ///
  /// Param [identifier] 要获取 handler 对应的 id。
  ///
  /// **Return** 返回 id 对应的 handler 。
  ///
  EMChatEventHandler? getEventHandler(String identifier) {
    return _eventHandlesMap[identifier];
  }

  ///
  /// 清除所有的 [EMChatEventHandler] 。
  ///
  void clearEventHandlers() {
    _eventHandlesMap.clear();
  }

  /// 发送消息。
  ///
  /// **Note**
  /// 如果是语音，图片类等有附件的消息，SDK 会自动上传附件。
  /// 可以通过 [EMOptions.serverTransfer] 设置是否上传到聊天服务器。
  ///
  /// 发送消息的状态，可以通过设置 [EMMessage.setMessageStatusCallBack] 进行监听。
  ///
  /// Param [message] 待发送消息对象，不能为空。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
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

  ///
  /// 重发消息。
  ///
  /// Param [message] 需要重发的消息。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
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
  /// Param [message] The message body.
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
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
  /// 发送群消息已读回执。
  ///
  /// 前提条件：设置了[EMOptions.requireAck] 和 [EMMessage.needGroupAck]。
  ///
  /// **Note**
  /// 发送单聊消息已读回执，详见 [sendMessageReadAck]；
  /// 会话已读回执，详见 [sendConversationReadAck]。
  ///
  /// Param [msgId] 消息 ID。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [content] 扩展信息。用户自己定义的关键字，接收后，解析出自定义的字符串，可以自行处理。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
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

    Map result =
        await ChatChannel.invokeMethod(ChatMethodKeys.ackGroupMessageRead, req);
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
  /// [EMChatEventHandler.onConversationRead]。
  ///
  /// **Note**
  /// 发送群组消息已读回执见 [sendGroupMessageReadAck]。
  ///
  /// Param [conversationId] 会话 ID。
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
  /// 撤回发送成功的消息。
  ///
  /// Param [messageId] 消息 ID。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
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
  /// 从本地数据库获取指定 ID 的消息对象。
  ///
  /// Param [messageId] 消息 ID。
  ///
  /// **Return** 根据指定 ID 获取的消息对象，如果消息不存在会返回空值。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
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
  /// 根据指定会话 ID 和会话类型获取会话对象。
  ///
  /// 没有找到会返回空值。
  ///
  /// Param [conversationId] 会话 ID。
  ///
  /// Param [type] 会话类型，详见 [EMConversationType]。
  ///
  /// Param [createIfNeed] 没找到相应会话时是否自动创建。
  ///                        - (Default)`true` 表示没有找到相应会话时会自动创建会话；
  ///                        - `false` 表示没有找到相应会话时不创建会话。
  ///
  /// **Return**  根据指定 ID 以及会话类型找到的会话对象，如果没有找到会返回空值。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
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
  /// 根据 threadId 获取 thread 会话。
  ///
  /// Param [threadId] thread ID.
  ///
  /// **Return** 对应的会话.
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
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

  /// 设置所有会话已读。
  ///
  /// 把所有的会话都设成已读。
  ///
  /// 这里针对的是本地会话。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
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
  /// 获取未读消息数。
  ///
  /// **Return** 未读消息数。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
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
  /// 更新本地消息。
  ///
  /// 会同时更新本地内存和数据库。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
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
  ///  将消息导入本地数据库。
  ///
  ///  只能将当前用户发送或接收的消息导入本地数据库。
  ///  已经对函数做过速度优化，推荐一次导入 1,000 条以内的数据。
  ///
  /// Param [messages] 需要导入数据库的消息。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
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
  /// 下载消息的附件。
  ///
  /// 若附件自动下载失败，也可以调用此方法下载。
  ///
  /// Param [message] 要下载附件的消息。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
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
  /// 下载消息的缩略图。
  ///
  /// Param [message] 要下载缩略图的消息，一般图片消息和视频消息有缩略图。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
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
  /// 获取本地数据库中所有会话。
  ///
  /// 会先从内存中获取，如果没有会从本地数据库获取。
  ///
  /// **Return**  返回获取的会话。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
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
  /// 从服务器获取会话列表。
  ///
  /// 该功能需联系商务开通，开通后，用户默认可拉取 7 天内的 10 个会话（每个会话包含最新一条历史消息），如需调整会话数量或时间限制请联系商务经理。
  ///
  /// **Return** 返回获取的会话列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
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
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
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
  /// 分页获取历史消息
  ///
  /// Param [conversationId] 会话 ID。
  ///
  /// Param [type] 会话类型. 详见 [EMConversationType].
  ///
  /// Param [pageSize] 每页获取的消息数量。
  ///
  /// Param [startMsgId] 获取历史消息的开始消息 ID，如果为空，从最新的消息向前开始获取。
  ///
  /// **Return** 返回消息列表和用于继续获取历史消息的 Cursor。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
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
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
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
  /// 从服务器获取群组消息回执详情。
  ///
  /// 分页获取。
  ///
  /// **Note**
  /// 发送群组消息回执，详见 [sendConversationReadAck]。
  ///
  /// Param [msgId] 消息 ID。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [startAckId] 已读回执的 ID，如果为空，从最新的回执向前开始获取。
  ///
  /// Param [pageSize] 每页获取群消息已读回执的条数。
  ///
  /// **Return** 返回回执列表和用于下次获取群消息回执的 cursor。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
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
  /// 删除某时间之前的消息；
  ///
  /// Param [timestamp]  Unix 时间戳，单位 毫秒。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
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
  /// 举报非法消息。
  ///
  /// Param [messageId] 非法消息的 ID。
  ///
  /// Param [tag] 非法消息标签，如涉政和恐怖相关。
  ///
  /// Param [reason] 举报原因。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError].
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
  /// 添加 Reaction。
  ///
  /// Param [messageId] 要添加 Reaction 的消息 ID。
  ///
  /// Param [reaction] Reaction 的内容。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError].
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
  /// 删除 Reaction。
  ///
  /// Param [messageId] 添加了该 Reaction 的消息 ID。
  ///
  /// Param [reaction] 要删除的 Reaction。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
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
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError].
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
  /// **Return** 若调用成功，返回 [EMMessageReaction] 详情。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError].
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
  /// 翻译一条文本消息。
  ///
  /// Param [msg] 要翻译的文本消息。
  ///
  /// Param [languages] 目标语言。
  ///
  /// **Return** 译文。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError].
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
  /// 查询翻译服务支持的语言。
  ///
  /// **Return** 翻译服务支持的语言列表。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError].
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
}

extension ChatManagerDeprecated on EMChatManager {
  ///
  /// 注册消息监听。
  ///
  /// 接收到新消息等回调可以通过设置此方法进行监听，详见 [EMChatManagerListener]。
  ///
  /// Param [listener] 要注册的消息监听。
  ///
  @Deprecated("Use EMChatManager.addEventHandler to instead")
  void addChatManagerListener(EMChatManagerListener listener) {
    _listeners.remove(listener);
    _listeners.add(listener);
  }

  ///
  /// 移除消息监听。
  ///
  /// 需要先添加 [addChatManagerListener] 监听，再调用本方法。
  ///
  /// Param [listener] 要移除的监听。
  ///
  @Deprecated("Use EMChatManager.removeEventHandler to instead")
  void removeChatManagerListener(EMChatManagerListener listener) {
    _listeners.remove(listener);
  }

  ///
  /// 移除所有消息监听。
  ///
  @Deprecated("Use EMChatManager.clearEventHandlers to instead")
  void clearAllChatManagerListeners() {
    _listeners.clear();
  }
}
