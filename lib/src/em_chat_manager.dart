import "dart:async";

import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class EMChatManager implements EMMessageStatusListener {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _channel =
      const MethodChannel('$_channelPrefix/em_chat_manager', JSONMethodCodec());

  final List<EMChatManagerListener> _messageListeners = [];

  EMChatManager() {
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == EMSDKMethod.onMessagesReceived) {
        return _onMessagesReceived(call.arguments);
      } else if (call.method == EMSDKMethod.onCmdMessagesReceived) {
        return _onCmdMessagesReceived(call.arguments);
      } else if (call.method == EMSDKMethod.onMessagesRead) {
        return _onMessagesRead(call.arguments);
      } else if (call.method == EMSDKMethod.onGroupMessageRead) {
        return _onGroupMessageRead(call.arguments);
      } else if (call.method == EMSDKMethod.onMessagesDelivered) {
        return _onMessagesDelivered(call.arguments);
      } else if (call.method == EMSDKMethod.onMessagesRecalled) {
        return _onMessagesRecalled(call.arguments);
      } else if (call.method == EMSDKMethod.onConversationUpdate) {
        return _onConversationsUpdate(call.arguments);
      } else if (call.method == EMSDKMethod.onConversationHasRead) {
        return _onConversationHasRead(call.arguments);
      }
      return null;
    });
  }

  /// 发送消息 [message].
  Future<EMMessage> sendMessage(EMMessage message) async {
    if (message.listener == null) {
      message.listener = this;
    }
    message.status = EMMessageStatus.PROGRESS;
    Map result =
        await _channel.invokeMethod(EMSDKMethod.sendMessage, message.toJson());
    try {
      EMError.hasErrorFromResult(result);
      EMMessage msg = EMMessage.fromJson(result[EMSDKMethod.sendMessage]);
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
    if (message.listener == null) {
      message.listener = this;
    }
    message.status = EMMessageStatus.PROGRESS;
    Map result = await _channel.invokeMethod(
        EMSDKMethod.resendMessage, message.toJson());
    try {
      EMError.hasErrorFromResult(result);
      EMMessage msg = EMMessage.fromJson(result[EMSDKMethod.resendMessage]);
      message.from = msg.from;
      message.to = msg.to;
      message.status = msg.status;
      return message;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 发送消息已读 [message].
  Future<bool> sendMessageReadAck(EMMessage message) async {
    Map req = {"to": message.from, "msg_id": message.msgId};
    Map result = await _channel.invokeMethod(EMSDKMethod.ackMessageRead, req);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(EMSDKMethod.ackMessageRead);
    } on EMError catch (e) {
      throw e;
    }
  }

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
        await _channel.invokeMethod(EMSDKMethod.ackGroupMessageRead, req);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(EMSDKMethod.ackMessageRead);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 发送会话已读 [conversationId]为会话Id
  Future<bool> sendConversationReadAck(String conversationId) async {
    Map req = {"con_id": conversationId};
    Map result =
        await _channel.invokeMethod(EMSDKMethod.ackConversationRead, req);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(EMSDKMethod.ackConversationRead);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 撤回发送的消息(增值服务), 默认时效为2分钟，超过2分钟无法撤回.
  Future<bool> recallMessage(String messageId) async {
    Map req = {"msg_id": messageId};
    Map result = await _channel.invokeMethod(EMSDKMethod.recallMessage, req);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(EMSDKMethod.recallMessage);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 通过[messageId]从db获取消息.
  Future<EMMessage> loadMessage(String messageId) async {
    Map req = {"msg_id": messageId};
    Map<String, dynamic> result =
        await _channel.invokeMethod(EMSDKMethod.getMessage, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMMessage.fromJson(result[EMSDKMethod.getMessage]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 通过会话[conversationId], 会话类型[type]获取会话.
  Future<EMConversation?> getConversation(
    String conversationId, [
    EMConversationType type = EMConversationType.Chat,
    bool createIfNeed = true,
  ]) async {
    Map req = {
      "con_id": conversationId,
      "type": EMConversation.typeToInt(type),
      "createIfNeed": createIfNeed
    };
    Map result = await _channel.invokeMethod(EMSDKMethod.getConversation, req);
    try {
      EMError.hasErrorFromResult(result);
      EMConversation? ret;
      if (result[EMSDKMethod.getConversation] != null) {
        ret = EMConversation.fromJson(result[EMSDKMethod.getConversation]);
      }
      return ret;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 将所有对话标记为已读.
  Future<bool> markAllConversationsAsRead() async {
    Map result = await _channel.invokeMethod(EMSDKMethod.markAllChatMsgAsRead);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(EMSDKMethod.markAllChatMsgAsRead);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 获取未读消息的计数.
  Future<int?> getUnreadMessageCount() async {
    Map result = await _channel.invokeMethod(EMSDKMethod.getUnreadMessageCount);
    try {
      EMError.hasErrorFromResult(result);
      return result[EMSDKMethod.getUnreadMessageCount] as int?;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 更新消息[message].
  Future<EMMessage> updateMessage(EMMessage message) async {
    Map req = {"message": message.toJson()};
    Map result =
        await _channel.invokeMethod(EMSDKMethod.updateChatMessage, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMMessage.fromJson(result[EMSDKMethod.updateChatMessage]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 导入消息 [messages].
  Future<bool> importMessages(List<EMMessage> messages) async {
    List<Map> list = [];
    messages.forEach((element) {
      list.add(element.toJson());
    });
    Map req = {"messages": list};
    Map result = await _channel.invokeMethod(EMSDKMethod.importMessages, req);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(EMSDKMethod.importMessages);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 下载附件 [message].
  Future<EMMessage> downloadAttachment(EMMessage message) async {
    Map result = await _channel.invokeMethod(
        EMSDKMethod.downloadAttachment, {"message": message.toJson()});
    try {
      EMError.hasErrorFromResult(result);
      return EMMessage.fromJson(result[EMSDKMethod.downloadAttachment]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 下载缩略图 [message].
  Future<EMMessage> downloadThumbnail(EMMessage message) async {
    Map result = await _channel.invokeMethod(
        EMSDKMethod.downloadThumbnail, {"message": message.toJson()});
    try {
      EMError.hasErrorFromResult(result);
      return EMMessage.fromJson(result[EMSDKMethod.downloadThumbnail]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 获取所有会话
  Future<List<EMConversation>> loadAllConversations() async {
    Map result = await _channel.invokeMethod(EMSDKMethod.loadAllConversations);
    try {
      EMError.hasErrorFromResult(result);
      List<EMConversation> conversationList = [];
      result[EMSDKMethod.loadAllConversations]?.forEach((element) {
        conversationList.add(EMConversation.fromJson(element));
      });
      return conversationList;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 从服务器获取会话
  Future<List<EMConversation>> getConversationsFromServer() async {
    Map result =
        await _channel.invokeMethod(EMSDKMethod.getConversationsFromServer);
    try {
      EMError.hasErrorFromResult(result);
      List<EMConversation> conversationList = [];
      result[EMSDKMethod.getConversationsFromServer]?.forEach((element) {
        conversationList.add(EMConversation.fromJson(element));
      });
      return conversationList;
    } on EMError catch (e) {
      throw e;
    }
  }

  // 批量更新一组会话显示名称`Map`,`key`会话id, `value`对应名称,既conversation.name属性。
  // Future<bool> updateConversationsName(Map<String, String> nameMap) async {
  //   Map req = {"name_map": nameMap};
  //   Map result =
  //       await _channel.invokeMethod(EMSDKMethod.updateConversationsName, req);
  //   EMError.hasErrorFromResult(result);
  //   return result.boolValue(EMSDKMethod.updateConversationsName);
  // }

  /// 删除会话, 如果[deleteMessages]设置为true，则同时删除消息。
  Future<bool> deleteConversation(
    String conversationId, [
    bool deleteMessages = true,
  ]) async {
    Map req = {"con_id": conversationId, "deleteMessages": deleteMessages};
    Map result =
        await _channel.invokeMethod(EMSDKMethod.deleteConversation, req);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(EMSDKMethod.deleteConversation);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 添加消息监听 [listener]
  void addListener(EMChatManagerListener listener) {
    _messageListeners.add(listener);
  }

  /// 移除消息监听[listener]
  void removeListener(EMChatManagerListener listener) {
    if (_messageListeners.contains(listener)) {
      _messageListeners.remove(listener);
    }
  }

  /// 在会话[conversationId]中提取历史消息，按[type]筛选。
  /// 结果按每页[pageSize]分页，从[startMsgId]开始。
  Future<EMCursorResult<EMMessage?>> fetchHistoryMessages(
    String conversationId, {
    EMConversationType type = EMConversationType.Chat,
    int pageSize = 20,
    String startMsgId = '',
  }) async {
    Map req = Map();
    req['con_id'] = conversationId;
    req['type'] = EMConversation.typeToInt(type);
    req['pageSize'] = pageSize;
    req['startMsgId'] = startMsgId;
    Map result =
        await _channel.invokeMethod(EMSDKMethod.fetchHistoryMessages, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMCursorResult<EMMessage?>.fromJson(
          result[EMSDKMethod.fetchHistoryMessages], dataItemCallback: (value) {
        return EMMessage.fromJson(value);
      });
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 搜索包含[keywords]的消息，消息类型为[type]，起始时间[timeStamp]，条数[maxCount], 消息发送方[from]，方向[direction]。
  Future<List<EMMessage>> searchMsgFromDB(
    String keywords, {
    int timeStamp = -1,
    int maxCount = 20,
    String from = '',
    EMMessageSearchDirection direction = EMMessageSearchDirection.Up,
  }) async {
    Map req = Map();
    req['keywords'] = keywords;
    req['timeStamp'] = timeStamp;
    req['maxCount'] = maxCount;
    req['from'] = from;
    req['direction'] = direction == EMMessageSearchDirection.Up ? "up" : "down";

    Map result =
        await _channel.invokeMethod(EMSDKMethod.searchChatMsgFromDB, req);
    try {
      EMError.hasErrorFromResult(result);
      List<EMMessage> list = [];
      result[EMSDKMethod.searchChatMsgFromDB]?.forEach((element) {
        list.add(EMMessage.fromJson(element));
      });
      return list;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 从服务器获取群组已读回执。
  /// [msgId], 需要获取的群消息id。
  /// [startAckId], 起始的ackId, 用于分页。
  /// [pageSize], 返回的数量。
  Future<EMCursorResult<EMGroupMessageAck?>> asyncFetchGroupAcks(
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
        await _channel.invokeMethod(EMSDKMethod.asyncFetchGroupAcks, req);

    try {
      EMError.hasErrorFromResult(result);
      EMCursorResult<EMGroupMessageAck?> cursorResult = EMCursorResult.fromJson(
        result[EMSDKMethod.asyncFetchGroupAcks],
        dataItemCallback: (map) {
          return EMGroupMessageAck.fromJson(map);
        },
      );

      return cursorResult;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// @nodoc
  Future<void> _onMessagesReceived(List messages) async {
    List<EMMessage> messageList = [];
    for (var message in messages) {
      messageList.add(EMMessage.fromJson(message));
    }
    for (var listener in _messageListeners) {
      listener.onMessagesReceived(messageList);
    }
  }

  /// @nodoc
  Future<void> _onCmdMessagesReceived(List messages) async {
    List<EMMessage> list = [];
    for (var message in messages) {
      list.add(EMMessage.fromJson(message));
    }
    for (var listener in _messageListeners) {
      listener.onCmdMessagesReceived(list);
    }
  }

  /// @nodoc
  Future<void> _onMessagesRead(List messages) async {
    List<EMMessage> list = [];
    for (var message in messages) {
      list.add(EMMessage.fromJson(message));
    }
    for (var listener in _messageListeners) {
      listener.onMessagesRead(list);
    }
  }

  /// @nodoc
  Future<void> _onGroupMessageRead(List messages) async {
    List<EMGroupMessageAck> list = [];
    for (var message in messages) {
      list.add(EMGroupMessageAck.fromJson(message));
    }
    for (var listener in _messageListeners) {
      listener.onGroupMessageRead(list);
    }
  }

  /// @nodoc
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
      String? from = (obj as Map)['from'];
      String? to = obj['to'];
      listener.onConversationRead(from, to);
    }
  }

  @override
  void onDeliveryAck() {}

  @override
  void onError(EMError error) {}

  @override
  void onProgress(int progress) {}

  @override
  void onReadAck() {}

  @override
  void onStatusChanged() {}

  @override
  void onSuccess() {}
}

abstract class EMChatManagerListener {
  /// 收到消息[messages]
  void onMessagesReceived(List<EMMessage> messages) {}

  /// 收到cmd消息[messages]
  void onCmdMessagesReceived(List<EMMessage> messages) {}

  /// 收到[messages]消息已读
  void onMessagesRead(List<EMMessage> messages) {}

  /// 收到[groupMessageAcks]群消息已读回调
  void onGroupMessageRead(List<EMGroupMessageAck> groupMessageAcks) {}

  /// 收到[messages]消息已送达
  void onMessagesDelivered(List<EMMessage> messages) {}

  /// 收到[messages]消息被撤回
  void onMessagesRecalled(List<EMMessage> messages) {}

  /// 会话列表变化
  void onConversationsUpdate() {}

  /// 会话已读`from`是已读的发送方, `to`是已读的接收方
  void onConversationRead(String? from, String? to) {}
}
