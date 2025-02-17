import 'dart:core';
import 'package:flutter/services.dart';

import '../internal/inner_headers.dart';


/// ~english
/// The conversation class, indicating a one-to-one chat, a group chat, or a conversation chat. It contains the messages that are sent and received within the conversation.
///
/// The following code shows how to get the number of the unread messages from the conversation.
/// ```dart
///   // ConversationId can be the other party id, the group id, or the chat room id.
///   EMConversation? con = await EMClient.getInstance.chatManager.getConversation(conversationId);
///   int? unreadCount = con?.unreadCount;
/// ```
/// ~end
///
/// ~chinese
/// 会话类，用于定义单聊会话、群聊会话和聊天室会话。每类会话中包含发送和接收的消息。
///
/// 以下示例代码展示如何从会话中获取未读消息数：
/// ```dart
///   // The `ConversationId` can be the other party ID, the group ID, or the chat room ID.
///   EMConversation? con = await EMClient.getInstance.chatManager.getConversation(conversationId);
///   int? unreadCount = con?.unreadCount;
/// ```
/// ~end
class EMConversation {
  EMConversation._private(
    this.id,
    this.type,
    this._ext,
    this.isChatThread,
    this.isPinned,
    this.pinnedTime,
    this.marks,
  );

  factory EMConversation.fromJson(Map<String, dynamic> map) {
    Map<String, String>? ext = map["ext"]?.cast<String, String>();
    EMConversation ret = EMConversation._private(
      map["convId"],
      EMConversationType.values[map["type"]],
      ext,
      map["isThread"] ?? false,
      map["isPinned"] ?? false,
      map["pinnedTime"] ?? 0,
      map.getValue('marks', callback: (obj) {
        List<ConversationMarkType> marks = [];
        if (obj is List) {
          for (var mark in obj) {
            marks.add(ConversationMarkType.values[mark]);
          }
        }
        return marks;
      }),
    );

    return ret;
  }

  Map<String, dynamic> _toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["type"] = this.type.index;
    data["convId"] = this.id;
    data["isThread"] = this.isChatThread;
    if (marks?.isNotEmpty == true) {
      data['marks'] = this.marks!.map((e) => e.index).toList();
    }

    return data;
  }

  /// ~english
  /// The conversation ID.
  ///
  /// For one-to-one chat，the conversation ID is the username of the other party.
  /// For group chat, the conversation ID is the group ID, not the group name.
  /// For chat room, the conversation ID is the chat room ID, not the chat room name.
  /// For help desk, the conversation ID is the username of the other party.
  /// ~end
  ///
  /// ~chinese
  /// 获取会话 ID。
  ///
  /// 对于单聊类型，会话 ID 同时也是对方用户的名称。
  /// 对于群聊类型，会话 ID 同时也是群组的 ID，并不同于群组的名称。
  /// 对于聊天室类型，会话 ID 同时也是聊天室的 ID，并不同于聊天室的名称。
  /// 对于 HelpDesk 类型，会话 ID 与单聊类型相同，是对方用户的名称。
  ///
  /// **Return** 会话 ID。
  /// ~end
  final String id;

  /// ~english
  /// The conversation type.
  /// ~end
  ///
  /// ~chinese
  /// 会话类型。
  /// ~end
  final EMConversationType type;

  /// ~english
  /// Whether the conversation is a chat thread conversation.
  /// - `true`: Yes;
  /// - `false`: No.
  /// ~end
  ///
  /// ~chinese
  /// 是否为子区会话。
  /// - `true`：是；
  /// - `false`：否。
  /// ~end
  final bool isChatThread;

  /// ~english
  /// Whether the conversation is pinned:
  /// - `true`: Yes;
  /// - `false`: No.
  /// ~end
  ///
  /// ~chinese
  /// 是否为置顶会话：
  /// - `true`：是；
  /// - `false`：否。
  /// ~end
  final bool isPinned;

  /// ~english
  ///  The UNIX timestamp when the conversation is pinned. The unit is millisecond. This value is `0` when the conversation is not pinned.
  /// ~end
  ///
  /// ~chinese
  /// 会话置顶的 UNIX 时间戳，单位为毫秒。未置顶时值为 `0`。
  /// ~end
  final int pinnedTime;

  /// ~english
  /// The conversation marks.
  /// ~end
  ///
  /// ~chinese
  /// 会话标记。
  /// ~end
  final List<ConversationMarkType>? marks;

  Map<String, String>? _ext;

  static const MethodChannel _emConversationChannel =
      const MethodChannel('com.chat.im/chat_conversation', JSONMethodCodec());

  /// ~english
  /// The conversation extension attribute.
  ///
  /// This attribute is not available for thread conversations.
  /// ~end
  /// ~chinese
  /// 获取会话扩展属性。
  ///
  /// 子区功能目前版本暂不可设置。
  /// ~end
  Map<String, String>? get ext => _ext;

  /// ~english
  /// Sets the conversation extension attribute.
  ///
  /// This attribute is not available for thread conversations.
  /// ~end
  /// ~chinese
  /// 设置会话扩展属性。
  ///
  /// 子区功能目前版本暂不可设置。
  /// ~end
  Future<void> setExt(Map<String, String>? ext) async {
    Map req = this._toJson();
    req.putIfNotNull("ext", ext);
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.syncConversationExt, req);
    try {
      EMError.hasErrorFromResult(result);
      _ext = ext;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Gets the last message from the conversation.
  ///
  /// The operation does not affect the unread message count.
  ///
  /// The SDK gets the latest message from the local memory first. If no message is found, the SDK loads the message from the local database and then puts it in the memory.
  ///
  /// **Return** The message instance.
  /// ~end
  ///
  /// ~chinese
  /// 获取会话的最新一条消息。
  ///
  /// 不影响未读数统计。
  ///
  /// 会先从缓存中获取，如果没有则从本地数据库获取后存入缓存。
  ///
  /// **Return** 消息体实例。
  /// ~end
  Future<EMMessage?> latestMessage() async {
    Map req = this._toJson();
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.getLatestMessage, req);
    try {
      EMError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.getLatestMessage)) {
        return EMMessage.fromJson(result[ChatMethodKeys.getLatestMessage]);
      } else {
        return null;
      }
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Gets the latest message from the conversation.
  ///
  /// **Return** The message instance.
  /// ~end
  ///
  /// ~chinese
  /// 获取最近收到的一条消息。
  ///
  /// **Return** 消息体实例。
  /// ~end
  Future<EMMessage?> lastReceivedMessage() async {
    Map req = this._toJson();
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.getLatestMessageFromOthers, req);
    try {
      EMError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.getLatestMessageFromOthers)) {
        return EMMessage.fromJson(
            result[ChatMethodKeys.getLatestMessageFromOthers]);
      } else {
        return null;
      }
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Gets the unread message count of the conversation.
  ///
  /// **Return** The unread message count of the conversation.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 获取会话的消息未读数。
  ///
  /// **Return** 会话的消息未读数量。
  ///
  /// **Throws**  如果有异常会在此抛出，包含错误码和原因，详见 [EMError]。
  /// ~end
  Future<int> unreadCount() async {
    Map req = this._toJson();
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.getUnreadMsgCount, req);
    try {
      EMError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.getUnreadMsgCount)) {
        return result[ChatMethodKeys.getUnreadMsgCount];
      } else {
        return 0;
      }
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Marks a message as read.
  ///
  /// Param [messageId] The message ID.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 将消息标为已读。
  ///
  /// Param [messageId] 消息 ID。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<void> markMessageAsRead(String messageId) async {
    Map req = this._toJson();
    req['msg_id'] = messageId;
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.markMessageAsRead, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Marks all messages as read.
  /// ~end
  ///
  /// ~chinese
  /// 将所有消息标为已读。
  /// ~end
  Future<void> markAllMessagesAsRead() async {
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.markAllMessagesAsRead, this._toJson());
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Inserts a message to a conversation in the local database and the SDK will automatically update the last message.
  ///
  /// Make sure you set the conversation ID as that of the conversation where you want to insert the message.
  ///
  /// Param [message] The message instance.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 插入一条消息在 SDK 本地数据库，消息的 conversation ID 应该和会话的 conversation ID 一致，消息会根据消息里的时间戳被插入 SDK 本地数据库，并且更新会话的 `latestMessage` 等属性。
  ///
  /// Param [message] 消息体实例。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<void> insertMessage(EMMessage message) async {
    Map req = this._toJson();
    req['msg'] = message.toJson();
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.insertMessage, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Inserts a message to the end of a conversation in the local database.
  ///
  /// Make sure you set the conversation ID as that of the conversation where you want to insert the message.
  ///
  /// Param [message] The message instance.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 插入一条消息到会话尾部。
  ///
  /// @note
  /// 请确保消息的 conversation ID 与要插入的会话的 conversationId 一致，消息会被插入 SDK 本地数据库，并且更新会话的 `latestMessage` 等属性。
  /// Param [message] 消息体实例。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<void> appendMessage(EMMessage message) async {
    Map req = this._toJson();
    req['msg'] = message.toJson();
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.appendMessage, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Updates a message in the local database.
  ///
  /// The latestMessage of the conversation and other properties will be updated accordingly. The message ID of the message, however, remains the same.
  ///
  /// Param [message] The message to be updated.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 更新 SDK 本地数据库的消息。
  ///
  /// @note
  /// 不能更新消息 ID，消息更新后，会话的 `latestMessage` 等属性进行相应更新。
  /// Param [message] 要更新的消息。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<void> updateMessage(EMMessage message) async {
    Map req = this._toJson();
    req['msg'] = message.toJson();
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.updateConversationMessage, req);
    EMError.hasErrorFromResult(result);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Deletes a message in the local database.
  ///
  /// **Note**
  /// After this method is called, the message is deleted both from the memory and the local database.
  ///
  /// Param [messageId] The ID of message to be deleted.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 删除会话中的一条消息，同时清除内存和数据库中的消息。
  ///
  /// Param [messageId] 要删除的消息。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<void> deleteMessage(String messageId) async {
    Map req = this._toJson();
    req['msg_id'] = messageId;
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.removeMessage, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Deletes all the messages of the conversation from both the memory and local database.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 同时从内存和本地数据库中删除会话中的所有消息。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<void> deleteAllMessages() async {
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.clearAllMessages, this._toJson());
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Deletes messages sent or received in a certain period from the local database.
  ///
  /// Param [startTs] The starting UNIX timestamp for message deletion. The unit is millisecond.
  ///
  /// Param [endTs] The end UNIX timestamp for message deletion. The unit is millisecond.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  /// ~end
  ///
  /// ~chinese
  /// 从本地数据库中删除指定时间段内的消息。
  ///
  /// Param [startTs] 删除消息的起始时间。UNIX 时间戳，单位为毫秒。
  ///
  /// Param [endTs] 删除消息的结束时间。UNIX 时间戳，单位为毫秒。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<void> deleteMessagesWithTs(int startTs, int endTs) async {
    Map req = this._toJson();
    req['startTs'] = startTs;
    req['endTs'] = endTs;
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.deleteMessagesWithTs, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Gets the message with a specific message ID.
  ///
  /// If the message is already loaded into the memory cache, the message will be directly returned; otherwise, the message will be loaded from the local database and loaded in the memory.
  ///
  /// Param [messageId] The message ID.
  ///
  /// **Return** The message instance.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 获取指定 ID 的消息。
  ///
  /// 优先从内存中加载，如果内存中没有则从数据库中加载，并将其插入到内存中。
  ///
  /// Param [messageId] 消息 ID。
  ///
  /// **Return** 消息实例。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<EMMessage?> loadMessage(String messageId) async {
    Map req = this._toJson();
    req['msg_id'] = messageId;
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.loadMsgWithId, req);
    try {
      EMError.hasErrorFromResult(result);
      if (result[ChatMethodKeys.loadMsgWithId] != null) {
        return EMMessage.fromJson(result[ChatMethodKeys.loadMsgWithId]);
      } else {
        return null;
      }
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Retrieves messages from the database according to the following parameters: the message type, the Unix timestamp, max count, sender.
  ///
  /// **Note**
  /// Be cautious about the memory usage when the maxCount is large.
  ///
  /// Param [type] The message type, including TXT, VOICE, IMAGE, and so on.
  ///
  /// Param [timestamp] The Unix timestamp for the search.
  ///
  /// Param [count] The max number of messages to search.
  ///
  /// Param [sender] The sender of the message. The param can also be used to search in group chat or chat room.
  ///
  /// Param [direction]  The direction in which the message is loaded: [EMSearchDirection].
  /// - `EMSearchDirection.Up`: Messages are retrieved in the reverse chronological order of when the server received messages.
  /// - `EMSearchDirection.Down`: Messages are retrieved in the chronological order of when the server received messages.
  ///
  /// **Return** The message list.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 根据消息类型、搜索消息的时间点、搜索结果的最大条数、搜索来源和搜索方向从 SDK 本地数据库中搜索指定数量的消息。
  ///
  /// **Note** 当 maxCount 非常大时，需要考虑内存消耗。
  ///
  /// Param [type] 消息类型，文本、图片、语音等等。
  ///
  /// Param [timestamp] 搜索时间。
  ///
  /// Param [count] 搜索结果的最大条数。
  ///
  /// Param [sender] 搜索来自某人的消息，也可用于搜索群组或聊天室里的消息。
  ///
  /// Param [direction] 消息加载的方向。
  ///
  /// **Return** 消息列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<List<EMMessage>> loadMessagesWithMsgType({
    required MessageType type,
    int timestamp = -1,
    int count = 20,
    String? sender,
    EMSearchDirection direction = EMSearchDirection.Up,
  }) async {
    Map req = this._toJson();
    req['msgType'] = type.index;
    req['timestamp'] = timestamp;
    req['count'] = count;
    req['direction'] = direction.index;
    req.putIfNotNull("sender", sender);
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.loadMsgWithMsgType, req);
    try {
      EMError.hasErrorFromResult(result);
      List<EMMessage> list = [];
      result[ChatMethodKeys.loadMsgWithMsgType]?.forEach((element) {
        list.add(EMMessage.fromJson(element));
      });
      return list;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Loads multiple messages from the local database.
  ///
  /// Loads messages from the local database before the specified message.
  ///
  /// The loaded messages will also join the existing messages of the conversation stored in the memory.
  ///
  /// Param [startMsgId] The starting message ID. Message loaded in the memory before this message ID will be loaded. If the `startMsgId` is set as "" or null, the SDK will first load the latest messages in the database.
  ///
  /// Param [loadCount] The number of messages per page.
  ///
  /// Param [direction]  The direction in which the message is loaded: EMSearchDirection.
  /// - `EMSearchDirection.Up`: Messages are retrieved in the reverse chronological order of when the server received messages.
  /// - `EMSearchDirection.Down`: Messages are retrieved in the chronological order of when the server received messages.
  ///
  /// **Return** The message list.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 从本地数据库加载消息。
  ///
  /// 根据传入的参数从本地数据库加载 startMsgId 之前(存储顺序)指定数量的消息。
  ///
  /// Param [startMsgId] 加载这个 ID 之前的 message，如果传入 "" 或者 null，将从最近的消息开始加载。
  ///
  /// Param [loadCount] 加载的条数。
  ///
  /// Param [direction]  消息的加载方向。
  ///
  /// **Return** 消息列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<List<EMMessage>> loadMessages({
    String startMsgId = '',
    int loadCount = 20,
    EMSearchDirection direction = EMSearchDirection.Up,
  }) async {
    Map req = this._toJson();
    req["startId"] = startMsgId;
    req['count'] = loadCount;
    req['direction'] = direction.index;

    Map<String, dynamic> result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.loadMsgWithStartId, req);

    try {
      EMError.hasErrorFromResult(result);
      List<EMMessage> msgList = [];
      result[ChatMethodKeys.loadMsgWithStartId]?.forEach((element) {
        msgList.add(EMMessage.fromJson(element));
      });
      return msgList;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Loads messages from the local database by the following parameters: keywords, timestamp, the number of messages to retrieve, sender, search scope, and search direction.
  ///
  /// **Note** Pay attention to the memory usage when you retrieve a great number of messages.
  ///
  /// Param [keywords] The keywords in message.
  ///
  /// Param [sender] The message sender. If you do not set this parameter, the SDK ignores this parameter when retrieving messages.
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
  /// Param [sender] 消息发送方。若不设置该参数，SDK 搜索消息时会忽略该参数。
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
    Map req = this._toJson();
    req["keywords"] = keywords;
    req['count'] = count;
    req['timestamp'] = timestamp;
    req['searchScope'] = MessageSearchScope.values.indexOf(searchScope);
    req['direction'] = direction.index;
    req.putIfNotNull("from", sender);

    Map<String, dynamic> result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.loadMsgWithKeywords, req);

    try {
      EMError.hasErrorFromResult(result);
      List<EMMessage> msgList = [];
      result[ChatMethodKeys.loadMsgWithKeywords]?.forEach((element) {
        msgList.add(EMMessage.fromJson(element));
      });
      return msgList;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Loads messages from the local database according the following parameters: start timestamp, end timestamp, count.
  ///
  /// **Note** Pay attention to the memory usage when the maxCount is large.
  ///
  ///  Param [startTime] The starting Unix timestamp for search.
  ///
  ///  Param [endTime] The ending Unix timestamp for search.
  ///
  ///  Param [count] The maximum number of message to retrieve.
  ///
  /// **Returns** The list of searched messages.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 加载一个时间段内的消息，不超过最大数量。
  ///
  /// 注意：当 maxCount 非常大时，需要考虑内存消耗。
  ///
  ///  Param [startTime] 搜索的起始时间。
  ///
  ///  Param [endTime] 搜索的结束时间。
  ///
  ///  Param [count] 搜索结果的最大条数。
  ///
  /// **Return** 消息列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<List<EMMessage>> loadMessagesFromTime({
    required int startTime,
    required int endTime,
    int count = 20,
  }) async {
    Map req = this._toJson();
    req["startTime"] = startTime;
    req['endTime'] = endTime;
    req['count'] = count;

    Map<String, dynamic> result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.loadMsgWithTime, req);

    try {
      EMError.hasErrorFromResult(result);
      List<EMMessage> msgList = [];
      result[ChatMethodKeys.loadMsgWithTime]?.forEach((element) {
        msgList.add(EMMessage.fromJson(element));
      });
      return msgList;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Message count
  /// ~end
  ///
  /// ~chinese
  /// 会话中的消息数
  /// ~end
  Future<int> messagesCount() async {
    Map req = this._toJson();
    Map<String, dynamic> result = await _emConversationChannel.invokeMethod(
      ChatMethodKeys.messageCount,
      req,
    );

    try {
      EMError.hasErrorFromResult(result);
      int count = result[ChatMethodKeys.messageCount];
      return count;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Deletes messages with message ids.
  ///
  /// Param [messageIds]  The list of message ids.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 根据时间删除本地消息。
  ///
  /// Param [messageIds] 指定的消息id列表。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<void> deleteMessageByIds(List<String> messageIds) async {
    Map req = this._toJson();
    req['messageIds'] = messageIds;
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.deleteMessageByIds, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Gets the pinned messages in a local conversation.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 获取会话内的置顶消息列表。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  Future<List<EMMessage>> loadPinnedMessages() async {
    Map req = this._toJson();
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.pinnedMessages, req);
    try {
      EMError.hasErrorFromResult(result);
      List<EMMessage> msgList = [];
      result[ChatMethodKeys.pinnedMessages]?.forEach((element) {
        msgList.add(EMMessage.fromJson(element));
      });
      return msgList;
    } on EMError catch (e) {
      throw e;
    }
  }

  // 481

  /// ~english
  /// The conversation no disturb type. [ChatPushRemindType]
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 会话免打扰类型。[ChatPushRemindType]。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  /// ~end
  ///
  Future<ChatPushRemindType> remindType() async {
    Map req = this._toJson();
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.conversationRemindType, req);
    try {
      EMError.hasErrorFromResult(result);
      return ChatPushRemindType
          .values[result[ChatMethodKeys.conversationRemindType]];
    } on EMError catch (e) {
      throw e;
    }
  }

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
    Map req = this._toJson();
    req['ts'] = options.ts;
    req['count'] = options.count;
    req['direction'] = options.direction.index;
    req.putIfNotNull("from", options.from);
    req['types'] = options.types.map((e) => e.index).toList();
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.conversationSearchMsgsByOptions, req);
    try {
      EMError.hasErrorFromResult(result);
      List<EMMessage> messages = [];
      List list = result[ChatMethodKeys.conversationSearchMsgsByOptions];
      list.forEach((element) {
        messages.add(EMMessage.fromJson(element));
      });
      return messages;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Gets the local message count.
  /// The count of messages in the local database within the specified time range.
  ///
  /// Param [startMs] The start time of the time range.
  ///
  /// Param [endMs] The end time of the time range.
  ///
  /// **Returns** The count of messages in the local database within the specified time range.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  /// ~end
  ///
  /// ~chinese
  ///
  /// 获取本地消息数量。
  ///
  /// 获取指定时间范围内本地数据库中的消息数量。
  ///
  /// Param [startMs] 时间范围的开始时间。
  ///
  /// Param [endMs] 时间范围的结束时间。
  ///
  /// **Return** 指定时间范围内本地数据库中的消息数量。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  /// ~end
  Future<int> getLocalMessageCount({
    required int startMs,
    required int endMs,
  }) async {
    Map req = this._toJson();
    req.putIfNotNull("startMs", startMs);
    req.putIfNotNull("endMs", endMs);
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.conversationGetLocalMessageCount, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.conversationGetLocalMessageCount];
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  ///
  /// Removes local and server messages from the conversation by message ID.
  ///
  /// Param [msgIds] The message ids.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  ///
  /// ~chinese
  ///
  /// 通过消息 ID 从本地和服务器删除消息。
  ///
  /// Param [msgIds] 消息 ID。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  /// ~end
  Future<void> deleteLocalAndServerMessages(
      {required List<String> msgIds}) async {
    Map req = this._toJson();
    req.putIfNotNull("msgIds", msgIds);
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.conversationDeleteServerMessageWithIds, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.conversationGetLocalMessageCount];
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  ///
  /// Removes local and server messages from the conversation by timestamp.
  ///
  /// Param [beforeMs] The message ids.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  ///
  /// ~chinese
  ///
  /// 通过消息时间戳从本地和服务器删除消息。
  ///
  /// Param [beforeMs] UNIX 时间戳，单位为毫秒。若消息的 UNIX 时间戳小于设置的值，则会被删除。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  /// ~end
  Future<void> deleteLocalAndServerMessagesByTime(
      {required int beforeMs}) async {
    Map req = this._toJson();
    req.putIfNotNull("beforeMs", beforeMs);
    Map result = await _emConversationChannel.invokeMethod(
        ChatMethodKeys.conversationDeleteServerMessageWithTime, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.conversationGetLocalMessageCount];
    } on EMError catch (e) {
      throw e;
    }
  }
}
