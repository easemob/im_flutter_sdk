import "dart:async";
import 'dart:collection';

import 'package:flutter/services.dart';

import "em_conversation.dart";
import 'em_domain_terms.dart';
import 'em_listeners.dart';
import 'em_log.dart';
import 'em_sdk_method.dart';

class EMChatManager {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emChatManagerChannel =
      const MethodChannel('$_channelPrefix/em_chat_manager', JSONMethodCodec());

  /// @nodoc
  static EMChatManager _instance;

  final _messageListeners = List<EMMessageListener>();
  final _messageStatusListeners = List<EMMessageStatus>();
  Function _conversationUpdateFunc;

  EMChatManager._internal() {
    _addNativeMethodCallHandler();
  }

  /// @nodoc
  factory EMChatManager.getInstance() {
    return _instance = _instance ?? EMChatManager._internal();
  }

  /// 发送消息 [message].
  void sendMessage(EMMessage message,
      { onSuccess(),
        onProgress(int progress),
      onError(int errorCode, String desc)}){
    Future<Map> result = _emChatManagerChannel.invokeMethod(
        EMSDKMethod.sendMessage, message.toDataMap());
    result.then((response){
      if (response["success"]) {
//        message.msgId = response['ServerMsgId'];
         message.msgId = EMMessage.from(response['message']).msgId;
         message.status = EMMessage.from(response['message']).status;
        if (onSuccess != null) onSuccess();
      }
    });
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
      } else if(call.method == EMSDKMethod.onMessageStatusOnProgress){
        return _messageStatus_onProgress(argMap);
      }
      return null;
    });
  }

  /// @nodoc ackMessageRead-> 用户[to] 确认已读取消息[messageId]。
  void ackMessageRead(
    String to,
    String messageId,
      {onError(int code, String desc)}) {
    Future<Map> result = _emChatManagerChannel
        .invokeMethod(EMSDKMethod.ackMessageRead, {"to": to, "id": messageId});
    result.then((response) {
      if (!response['success']) {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// @nodoc 调用以前发送的[message]消息。
  /// @nodoc 如果一切正常，则调用[onSuccess]，[onError]如果有任何错误，将[code]，[desc]设置为详细错误信息。
  void recallMessage(
    EMMessage message,
      {onSuccess(),
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

  /// 通过[messageId] 获取消息.
  Future<EMMessage> getMessage(String messageId) async {
    Map<String, dynamic> result = await _emChatManagerChannel
        .invokeMethod(EMSDKMethod.getMessage, {"id": messageId});
    if (result['success']) {
      return EMMessage.from(result['message']);
    } else {
      return null;
    }
  }

  /// 通过[id] 获取会话
  Future<EMConversation> getConversation(
    String id,
    EMConversationType type,
    bool createIfNotExists) async {
    Map<String, dynamic> result = await _emChatManagerChannel.invokeMethod(
        EMSDKMethod.getConversation,
        {"id": id, "type": toEMConversationType(type), "createIfNotExists": createIfNotExists});
    if (result['success']) {
      return EMConversation.from(result['conversation']);
    } else {
      return null;
    }
  }

  /// @nodoc 将所有对话标记为已读。
  void markAllConversationsAsRead() {
    _emChatManagerChannel.invokeMethod(EMSDKMethod.markAllChatMsgAsRead);
  }

  /// 获取未读消息的计数。
  Future<int> getUnreadMessageCount() async {
    Map<String, dynamic> result = await _emChatManagerChannel
        .invokeMethod(EMSDKMethod.getUnreadMessageCount);
    if (result['success']) {
      return result['count'];
    } else {
      return 0;
    }
  }

  /// @nodoc 保存消息[message].
  void saveMessage(EMMessage message) {
    _emChatManagerChannel.invokeMethod(
        EMSDKMethod.saveMessage, {"message": message.toDataMap()});
  }

  /// @nodoc 更新消息[message].
  void updateMessage(EMMessage message,
      {onSuccess(), onError(String desc)}) async {
    Map<String, dynamic> result = await _emChatManagerChannel.invokeMethod(
        EMSDKMethod.updateChatMessage,
        {"message": message.toDataMap()});
    if (result['success']) {
        if (onSuccess != null) onSuccess();
    } else {
        if (onError != null) onError(result['error']);
    }
  }

  /// @nodoc 下载附件 [message].
  void downloadAttachment(EMMessage message) {
    _emChatManagerChannel.invokeMethod(
        EMSDKMethod.downloadAttachment, {"message": message.toDataMap()});
  }

  /// @nodoc 下载缩略图 [message].
  void downloadThumbnail(EMMessage message) {
    _emChatManagerChannel.invokeMethod(
        EMSDKMethod.downloadThumbnail, {"message": message.toDataMap()});
  }


  /// @nodoc 导入消息 [messages].
  void importMessages(List<EMMessage> messages) {
    _emChatManagerChannel.invokeMethod(EMSDKMethod.importMessages,
        {"messages": messageListToMap(messages)});
  }

  List messageListToMap(List<EMMessage> messages) {
    var messageList = List();
    for (EMMessage message in messages) {
      messageList.add(message.toDataMap());
    }
    return messageList;
  }
  

  /// @nodoc 根据类型获取会话 [type].
  Future<List<EMConversation>> getConversationsByType(
      EMConversationType type) async {
    Map<String, dynamic> result = await _emChatManagerChannel
        .invokeMethod(EMSDKMethod.getConversationsByType, {"type": toEMConversationType(type)});
    if (result["success"]) {
      var conversations = result['conversations'] as List<dynamic>;
      List<EMConversation> list = new List<EMConversation>();
      for (var value in conversations) {
        print(value.toString()+"..xx...");
        list.add(EMConversation.from(value));
      }
      return list;
    } else {
      return null;
    }
  }

  /// @nodoc 下载文件 远程地址[remoteUrl],本地地址[localFilePath].
  void downloadFile(
    String remoteUrl,
    String localFilePath,
    Map<String, String> headers,
      {onSuccess(),
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

  /// 获取所有会话
  Future<Map<String, EMConversation>> getAllConversations() async {
    Map<String, dynamic> result = await _emChatManagerChannel
        .invokeMethod(EMSDKMethod.getAllConversations);
    if (result['success']) {
      var data = HashMap<String, EMConversation>();
      var conversations = result['conversations'] as List<dynamic>;
      for (var conversation in conversations) {
        data[conversation['id']] = EMConversation.from(conversation);
      }
      return data;
    } else {
      return null;
    }
  }

  /// 加载所有会话
  void loadAllConversations() {
    _emChatManagerChannel.invokeMethod(EMSDKMethod.loadAllConversations);
  }

  /// 删除与[userName] 的对话, 如果[deleteCoversations]设置为true，则还会删除消息。
  Future<bool> deleteConversation(
    String userName,
    bool deleteMessages
  ) async {
    Map<String, dynamic> result = await _emChatManagerChannel.invokeMethod(
        EMSDKMethod.deleteConversation,
        {"userName": userName, "deleteMessages": deleteMessages});
    if (result['success']) {
      return result['status'];
    } else {
      return false;
    }
  }

  /// 添加消息监听 [listener]
  void addMessageListener(EMMessageListener listener) {
    assert(listener != null);
    _messageListeners.add(listener);
    _emChatManagerChannel.invokeMethod("addMessageListener");
  }

  /// 移除消息监听[listener]
  void removeMessageListener(EMMessageListener listener) {
    assert(listener != null);
    _messageListeners.remove(listener);
  }

  ///  设置会话更新回调函数[onConversationUpdate].
  void onConversationUpdate(onConversationUpdate()) {
    _conversationUpdateFunc = onConversationUpdate;
  }

  /// @nodoc 设置语音消息监听 [message].
  void setVoiceMessageListened(EMMessage message) {
    _emChatManagerChannel.invokeMethod(
        EMSDKMethod.setVoiceMessageListened, {"message": message.toDataMap()});
  }

  /// @nodoc 将某个联系人相关信息[from]更新为另外一个联系人[changeTo]。
  Future<bool> updateParticipant(
    String from,
    String changeTo
  ) async {
    Map<String, dynamic> result = await _emChatManagerChannel.invokeMethod(
        EMSDKMethod.updateParticipant, {"from": from, "changeTo": changeTo});
    if (result['success']) {
      return result['status'];
    } else {
      return false;
    }
  }

  /// @nodoc 在会话[conversationId]中提取历史消息，按[type]筛选。
  /// @nodoc 结果按每页[pageSize]分页，从[startMsgId]开始。
  Future<EMCursorResults<EMMessage>> fetchHistoryMessages(
    String conversationId,
    EMConversationType type,
    int pageSize,
    String startMsgId,
  {onSuccess(),
    onError(int code, String desc)}) async {
    Map<String, dynamic> result = await _emChatManagerChannel
        .invokeMethod(EMSDKMethod.fetchHistoryMessages, {
      "id": conversationId,
      "type": toEMConversationType(type),
      "pageSize": pageSize,
      "startMsgId": startMsgId
    });
    if (result['success']) {
      return _EMCursorResults<EMMessage>(result['cursorId']);
    } else {
      return null;
    }
  }

  /// @nodoc 搜索以[keywords]为关键字的消息，[type]，时间戳设置为[timeStamp]，来自用户[from]，方向[direction]。
  /// @nodoc 结果返回到每个调用的最大值[maxCount]记录。
  Future<List<EMMessage>> searchMsgFromDB(
    String keywords,
    EMMessageType type,
    String timeStamp,
    int maxCount,
    String from,
    EMSearchDirection direction
  ) async {
    Map<String, dynamic> result = await _emChatManagerChannel
        .invokeMethod(EMSDKMethod.searchChatMsgFromDB, {
      "keywords": keywords,
      "type": toType(type),
      "timeStamp": timeStamp,
      "maxCount": maxCount,
      "from": from,
      "direction": toEMSearchDirection(direction)
    });
    if (result['success']) {
      var messages = result['messages'] as List<dynamic>;
      var data = List<EMMessage>();
      for (var message in messages) {
        data.add(EMMessage.from(message));
      }
      return data;
    } else {
      return null;
    }
  }

  /// @nodoc
  Future<void> _onMessageReceived(Map map) async {
    var list = map['messages'];
    var messageList = List<EMMessage>();
    for (var message in list) {
        messageList.add( EMMessage.from(message) );
    }
    for (var listener in _messageListeners) {
      listener.onMessageReceived(messageList);
    }
  }

  /// @nodoc
  Future<void> _onCmdMessageReceived(Map map) async {
    var list = map['messages'];
    var messages = List<EMMessage>();
    for (var message in list) {
      messages.add(EMMessage.from(message));
    }
    for (var listener in _messageListeners) {
      listener.onCmdMessageReceived(messages);
    }
  }

  /// @nodoc
  Future<void> _onMessageRead(Map map) async {
    var list = map['messages'];
    var messages = List<EMMessage>();
    for (var message in list) {
      messages.add(EMMessage.from(message));
    }
    for (var listener in _messageListeners) {
      listener.onMessageRead(messages);
    }
  }

  /// @nodoc
  Future<void> _onMessageDelivered(Map map) async {
    var list = map['messages'];
    var messages = List<EMMessage>();
    for (var message in list) {
      messages.add(EMMessage.from(message));
    }
    for (var listener in _messageListeners) {
      listener.onMessageDelivered(messages);
    }
  }

  Future<void> _onMessageRecalled(Map map) async {
    var list = map['messages'];
    var messages = List<EMMessage>();
    for (var message in list) {
      messages.add(EMMessage.from(message));
    }
    for (var listener in _messageListeners) {
      listener.onMessageRecalled(messages);
    }
  }

  /// @nodoc
  Future<void> _onMessageChanged(Map map) async {
    EMMessage message = EMMessage.from(map['message']);
    for (var listener in _messageListeners) {
      listener.onMessageChanged(message);
    }
  }

  void addMessageStatusListener(EMMessageStatus listener) {
    assert(listener != null);
    _messageStatusListeners.add(listener);
  }

  /// @nodoc
  Future<void>_messageStatus_onProgress(Map map) async{
    for (var listener in _messageStatusListeners) {
      listener.onProgress(map['progress'], map['status']);
    }
  }
}

/// _EMCursorResult - 内部EMCursorResult实现。
class _EMCursorResults<T> extends EMCursorResults<T> {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emChatManagerChannel =
      MethodChannel('$_channelPrefix/em_chat_manager');
  _EMCursorResults(String cursorId) : this._cursorId = cursorId;

  final String _cursorId;

  @override
  Future<T> getCursor() async {
    Map<String, Object> result = await _emChatManagerChannel
        .invokeMethod(EMSDKMethod.getCursor, {"id": _cursorId});
    if (result['success']) {
      var list = [];
      List messageList = result['message'] as List<dynamic>;
      for (var value in messageList) {
        list.add(EMMessage.from(value)) ;
      }
      return list as T;
    } else {
      return null;
    }
  }
}

abstract class EMMessageStatus{
  void onProgress(int progress, String status);
}
