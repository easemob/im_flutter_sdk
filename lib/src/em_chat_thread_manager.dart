// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/services.dart';
import 'internal/inner_headers.dart';

/// ~english
/// The chat thread manager class.
/// ~end
///
/// ~chinese
/// 子区管理类。
/// ~end
class EMChatThreadManager {
  static const _channelPrefix = 'com.chat.im';
  static const MethodChannel _channel = const MethodChannel(
      '$_channelPrefix/chat_thread_manager', JSONMethodCodec());

  final Map<String, EMChatThreadEventHandler> _eventHandlesMap = {};

  EMChatThreadManager() {
    _channel.setMethodCallHandler((MethodCall call) async {
      Map? argMap = call.arguments;
      if (call.method == ChatMethodKeys.onChatThreadCreate) {
        _onChatThreadCreated(argMap);
      } else if (call.method == ChatMethodKeys.onChatThreadUpdate) {
        _onChatThreadUpdated(argMap);
      } else if (call.method == ChatMethodKeys.onChatThreadDestroy) {
        _onChatThreadDestroyed(argMap);
      } else if (call.method == ChatMethodKeys.onUserKickOutOfChatThread) {
        _onChatThreadUserRemoved(argMap);
      }
      return null;
    });
  }

  /// ~english
  /// Adds the chat thread event handler. After calling this method, you can handle for chat thread event when they arrive.
  ///
  /// Param [identifier] The custom handler identifier, is used to find the corresponding handler.
  ///
  /// Param [handler] The handle for chat thread event. See [EMChatThreadEventHandler].
  /// ~end
  ///
  /// ~chinese
  /// 添加 Thread 事件监听。
  ///
  /// Param [identifier] 自定义事件 ID，用于查找事件监听。
  ///
  /// Param [handler] 事件监听. 请见 [EMChatThreadEventHandler].
  /// ~end
  void addEventHandler(
    String identifier,
    EMChatThreadEventHandler handler,
  ) {
    _eventHandlesMap[identifier] = handler;
  }

  /// ~english
  /// Remove the chat thread event handler.
  ///
  /// Param [identifier] The custom handler identifier.
  /// ~end
  ///
  /// ~chinese
  /// 移除 Thread 事件。
  ///
  /// Param [identifier] 需要移除事件监听的 ID。
  /// ~end
  void removeEventHandler(String identifier) {
    _eventHandlesMap.remove(identifier);
  }

  /// ~english
  /// Get the chat thread event handler.
  ///
  /// Param [identifier] The custom handler identifier.
  ///
  /// **Return** The chat thread event handler.
  /// ~end
  ///
  /// ~chinese
  /// 获取指定 ID 的事件监听。
  ///
  /// Param [identifier] 需要获取的事件监听 ID。
  ///
  /// **Return** Thread 事件监听。
  /// ~end
  EMChatThreadEventHandler? getEventHandler(String identifier) {
    return _eventHandlesMap[identifier];
  }

  /// ~english
  /// Clear all chat thread event handlers.
  /// ~end
  ///
  /// ~chinese
  /// 清除所有 Thread 监听。
  /// ~end
  void clearEventHandlers() {
    _eventHandlesMap.clear();
  }

  /// ~english
  /// Get Chat Thread details from server.
  ///
  /// Param [chatThreadId] Chat Thread ID.
  ///
  /// **Return** The chat thread object.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取子区详情。
  ///
  /// Param [chatThreadId] 子区 ID。
  ///
  /// **Return** 若调用成功，返回子区详情；失败则抛出异常。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<EMChatThread?> fetchChatThread({
    required String chatThreadId,
  }) async {
    Map req = {"threadId": chatThreadId};
    Map result = await _channel.invokeMethod(
      ChatMethodKeys.fetchChatThreadDetail,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
      return EMChatThread.fromJson(
          result[ChatMethodKeys.fetchChatThreadDetail]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Paging to get the list of Chat Threads that the current user has joined from the server
  ///
  /// Param [cursor] The initial value can be empty or empty string.
  ///
  /// Param [limit] The number of fetches at one time. Value range [1, 50].
  ///
  /// **Return** Returns the result of [EMCursorResult], including the cursor for getting data next time and the chat thread object list.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 分页从服务器获取当前用户加入的子区列表。
  ///
  /// Param [cursor] 开始获取数据的游标位置。首次调用方法时可以不传，按用户加入子区时间的倒序获取数据。
  ///
  /// Param [limit] 每页期望返回的子区数。取值范围为 [1,50]。
  ///
  /// **Return** 若调用成功，返回子区列表；失败则抛出异常。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<EMCursorResult<EMChatThread>> fetchJoinedChatThreads({
    String? cursor,
    int limit = 20,
  }) async {
    Map req = {"pageSize": limit};
    req.putIfNotNull("cursor", cursor);
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.fetchJoinedChatThreads, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMCursorResult.fromJson(
          result[ChatMethodKeys.fetchJoinedChatThreads],
          dataItemCallback: (map) {
        return EMChatThread.fromJson(map);
      });
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Get the subareas under a group from the server
  ///
  /// Param [parentId] Parent ID, generally refers to group ID.
  ///
  /// Param [cursor] The initial value can be empty or empty string.
  ///
  /// Param [limit] The number of fetches at one time. Value range [1, 50].
  ///
  /// **Return** result of [EMCursorResult], including the cursor for getting data next time and the chat thread object list.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 分页从服务器端获取指定群组的子区列表。
  ///
  /// Param [parentId] 群组 ID。
  ///
  /// Param [cursor] 开始取数据的游标位置。首次获取数据时可以不传，按子区创建时间的倒序获取数据。
  ///
  /// Param [limit] 每页期望返回的子区数。取值范围为 [1,50]。
  ///
  /// **Return** 若调用成功，返回子区列表；失败则抛出异常。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<EMCursorResult<EMChatThread>> fetchChatThreadsWithParentId({
    required String parentId,
    String? cursor,
    int limit = 20,
  }) async {
    Map req = {
      "parentId": parentId,
      "pageSize": limit,
    };
    req.putIfNotNull("cursor", cursor);
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.fetchChatThreadsWithParentId, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMCursorResult.fromJson(
          result[ChatMethodKeys.fetchChatThreadsWithParentId],
          dataItemCallback: (map) {
        return EMChatThread.fromJson(map);
      });
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Paging to get the list of Chat Threads that the current user has joined the specified group from the server。
  ///
  /// Param [parentId] The session id of the upper level of the sub-area
  ///
  /// Param [cursor] The initial value can be empty or empty string.
  ///
  /// Param [limit] The number of fetches at one time. Value range [1, 50].
  ///
  /// **Return** The result of [EMCursorResult], including the cursor for getting data next time and the chat thread object list.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 分页从服务器获取当前用户加入指定群组的子区列表。
  ///
  /// Param [parentId] 群组 ID。
  ///
  /// Param [cursor] 开始取数据的游标位置。首次调用方法时可以不传，按用户加入子区时间的倒序获取数据。
  ///
  /// Param [limit] 每页期望返回的子区数。取值范围为 [1,50]。
  ///
  /// **Return** 若调用成功，返回子区列表；失败则抛出异常。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<EMCursorResult<EMChatThread>> fetchJoinedChatThreadsWithParentId({
    required String parentId,
    String? cursor,
    int limit = 20,
  }) async {
    Map req = {
      "parentId": parentId,
      "pageSize": limit,
    };
    req.putIfNotNull("cursor", cursor);
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.fetchJoinedChatThreadsWithParentId, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMCursorResult.fromJson(
          result[ChatMethodKeys.fetchJoinedChatThreadsWithParentId],
          dataItemCallback: (map) {
        return EMChatThread.fromJson(map);
      });
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Paging to get Chat Thread members.
  ///
  /// The members of the group to which Chat Thread belongs have permission.
  ///
  /// Param [chatThreadId] Chat Thread ID.
  ///
  /// Param [cursor] The initial value can be empty or empty string.
  ///
  /// Param [limit] The number of fetches at one time. Value range [1, 50].
  ///
  /// **Return** The result of [EMCursorResult], including the cursor for getting data next time and the chat thread member list.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 分页获取子区成员。
  ///
  /// @note
  /// 子区所属群组的所有成员均可调用该方法。
  ///
  /// Param [chatThreadId] 子区 ID。
  ///
  /// Param [cursor] 开始获取数据的游标位置，首次调用方法时传 `null` 或空字符串，按成员加入子区时间的正序获取数据。
  ///
  /// Param [limit] 每页期望返回的成员数。取值范围为 [1,50]。
  ///
  /// **Return** 若调用成功，返回子区成员 [EMCursorResult]；失败则抛出异常。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<EMCursorResult<String>> fetchChatThreadMembers({
    required String chatThreadId,
    String? cursor,
    int limit = 20,
  }) async {
    Map req = {
      "pageSize": limit,
      "threadId": chatThreadId,
    };
    req.putIfNotNull("cursor", cursor);
    Map result = await _channel.invokeMethod(
      ChatMethodKeys.fetchChatThreadMember,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
      return EMCursorResult<String>.fromJson(
          result[ChatMethodKeys.fetchChatThreadMember],
          dataItemCallback: (obj) => obj);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Get the latest news of the specified Chat Thread list from the server.
  ///
  /// Param [chatThreadIds] Chat Thread id list. The list length is not greater than 20.
  ///
  /// **Return** returns a Map collection, the key is the chat thread ID, and the value is the latest message object of the chat thread.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器批量获取指定子区中的最新一条消息。
  ///
  /// Param [chatThreadIds] 要查询的子区 ID 列表，每次最多可传 20 个子区。
  ///
  /// **Return** 若调用成功，返回子区的最新一条消息列表；失败则抛出异常。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<Map<String, EMMessage>> fetchLatestMessageWithChatThreads({
    required List<String> chatThreadIds,
  }) async {
    Map req = {
      "threadIds": chatThreadIds,
    };
    Map result = await _channel.invokeMethod(
      ChatMethodKeys.fetchLastMessageWithChatThreads,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
      Map? map = result[ChatMethodKeys.fetchLastMessageWithChatThreads];
      Map<String, EMMessage> ret = {};
      if (map == null) {
        return ret;
      }

      for (var key in map.keys) {
        Map<String, dynamic> msgMap = map[key];
        ret[key] = EMMessage.fromJson(msgMap);
      }
      return ret;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Remove member from Chat Thread.
  ///
  /// Param [memberId] The ID of the member that was removed from Chat Thread.
  ///
  /// Param [chatThreadId] Chat Thread ID.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 移除子区成员。
  ///
  /// @note
  /// 只有子区所属群主、群管理员及子区创建者可调用该方法。
  ///
  /// 被移出的成员会收到 [EMChatThreadEventHandler.onUserKickOutOfChatThread] 回调。
  ///
  /// Param [memberId] 被移出子区的成员的用户 ID。
  ///
  /// Param [chatThreadId] 子区 ID。
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  Future<void> removeMemberFromChatThread({
    required String memberId,
    required String chatThreadId,
  }) async {
    Map req = {
      "memberId": memberId,
      "threadId": chatThreadId,
    };
    Map result = await _channel.invokeMethod(
      ChatMethodKeys.removeMemberFromChatThread,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Change Chat Thread name.
  ///
  /// The group owner, group administrator and Thread creator have permission.
  /// After modifying chat thread name, members of the organization (group) to which chat thread belongs will receive the update notification event.
  /// You can set [EMChatThreadEventHandler.onChatThreadUpdate] to listen on the event.
  ///
  /// Param [chatThreadId] Chat Thread ID.
  ///
  /// Param [newName]  New Chat Thread name. No more than 64 characters in length.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 修改子区名称。
  ///
  /// @note
  /// 只有子区所属群主、群管理员及子区创建者可调用该方法。
  ///
  /// 子区所属群组的所有成员均会收到 [EMChatThreadEventHandler.onChatThreadUpdate]。
  ///
  /// Param [chatThreadId] 子区 ID。
  ///
  /// Param [newName] 子区的新名称。长度不超过 64 个字符。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> updateChatThreadName({
    required String chatThreadId,
    required String newName,
  }) async {
    Map req = {
      "name": newName,
      "threadId": chatThreadId,
    };
    Map result = await _channel.invokeMethod(
      ChatMethodKeys.updateChatThreadSubject,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Create Chat Thread.
  ///
  /// Group members have permission.
  /// After chat thread is created, the following notices will appear:
  /// 1. Members of the organization (group) to which chat thread belongs will receive the created notification event,
  /// and can listen to related events by setting [EMChatThreadEventHandler].
  /// The event callback function is [EMChatThreadEventHandler.onChatThreadCreate].
  /// 2. Multiple devices will receive the notification event and you can set [EMMultiDeviceEventHandler] to listen on the event.
  /// The event callback function is [EMMultiDeviceEventHandler.onChatThreadEvent], where the first parameter is the event,
  /// for example, [EMMultiDevicesEvent.CHAT_THREAD_CREATE] for the chat thread creation event.
  ///
  /// Param [name] Chat Thread name. No more than 64 characters in length.
  ///
  /// Param [messageId] Parent message ID, generally refers to group message ID.
  ///
  /// Param [parentId] Parent ID, generally refers to group ID.
  ///
  /// **Return** EMChatThread object
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 创建子区。
  ///
  /// @note
  /// 所有群成员都可以调用。
  /// 子区创建成功后，会出现如下情况：
  ///
  /// - 单设备登录时，子区所属群组的所有成员均会收到 [EMChatThreadEventHandler.onChatThreadCreate] 。
  ///
  /// - 多端多设备登录时，各设备会收到 [EMMultiDeviceEventHandler.onChatThreadEvent] 回调。
  ///
  /// Param [name] 要创建的子区的名称。长度不超过 64 个字符。
  ///
  /// Param [messageId] 父消息 ID。
  ///
  /// Param [parentId] 群组 ID。
  ///
  /// **Return** 调用成功时，返回创建的子区对象；失败则抛出异常。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<EMChatThread> createChatThread({
    required String name,
    required String messageId,
    required String parentId,
  }) async {
    Map req = {
      "name": name,
      "messageId": messageId,
      "parentId": parentId,
    };
    Map result = await _channel.invokeMethod(
      ChatMethodKeys.createChatThread,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
      return EMChatThread.fromJson(result[ChatMethodKeys.createChatThread]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Join Chat Thread.
  ///
  /// Group members have permission.
  /// Join successfully, return the Chat Thread details [EMChatThread], the details do not include the number of members.
  /// Repeated addition will throw an EMError.
  /// After joining chat thread, the multiple devices will receive the notification event.
  /// You can set [EMMultiDeviceEventHandler] to listen on the event.
  /// The event callback function is [EMMultiDeviceEventHandler.onChatThreadEvent],
  /// where the first parameter is the event, and chat thread join event is [EMMultiDevicesEvent.CHAT_THREAD_JOIN].
  ///
  /// Param [chatThreadId] Chat Thread ID.
  ///
  /// **Return** The joined chat thread object;
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 加入子区。
  ///
  /// @note
  /// 子区所属群组的所有成员均可调用该方法。
  ///
  /// 加入成功后，多端多设备登录情况下，其他设备会收到 [EMMultiDeviceEventHandler.onChatThreadEvent]，Event 的值为 [EMMultiDevicesEvent.CHAT_THREAD_JOIN]。
  ///
  /// Param [chatThreadId] 子区 ID。
  ///
  /// **Return** 若调用成功，返回子区详情 [EMChatThread]，详情中不含成员数量；失败则抛出异常。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<EMChatThread> joinChatThread({
    required String chatThreadId,
  }) async {
    Map req = {
      "threadId": chatThreadId,
    };
    Map result = await _channel.invokeMethod(
      ChatMethodKeys.joinChatThread,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
      return EMChatThread.fromJson(result[ChatMethodKeys.joinChatThread]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Leave Chat Thread.
  ///
  /// The operation is available to Chat Thread members.
  /// After leave chat thread, the multiple devices will receive the notification event.
  /// You can set {@EMMultiDeviceEventHandler} to listen on the event.
  /// The event callback function is [EMMultiDeviceEventHandler.onChatThreadEvent],
  /// where the first parameter is the event, and chat thread exit event is [EMMultiDevicesEvent.CHAT_THREAD_LEAVE].
  ///
  /// Param [chatThreadId] Chat Thread ID.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 退出子区。
  ///
  /// @note
  /// 子区中的所有成员均可调用该方法。
  /// 多端多设备登录情况下，其他设备会收到 [EMMultiDeviceEventHandler.onChatThreadEvent] 回调，Event 的值为 [EMMultiDevicesEvent.CHAT_THREAD_LEAVE]。
  ///
  /// Param [chatThreadId] 要退出的子区 ID。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> leaveChatThread({
    required String chatThreadId,
  }) async {
    Map req = {
      "threadId": chatThreadId,
    };
    Map result = await _channel.invokeMethod(
      ChatMethodKeys.leaveChatThread,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Disband Chat Thread.
  ///
  /// Group owner and group administrator to which the Chat Thread belongs have permission.
  /// After chat thread is disbanded, there will be the following notification:
  /// 1. Members of the organization (group) to which chat thread belongs will receive the disbanded notification event,
  /// and can listen to related events by setting [EMChatThreadEventHandler].
  /// The event callback function is [EMChatThreadEventHandler.onChatThreadDestroy].
  /// 2. Multiple devices will receive the notification event and you can set [EMMultiDeviceEventHandler] to listen on the event.
  /// The event callback function is [EMMultiDeviceEventHandler.onChatThreadEvent], where the first parameter is the event,
  /// for example, [EMMultiDevicesEvent.CHAT_THREAD_DESTROY] for the chat thread destruction event.
  ///
  /// Param [chatThreadId] Chat Thread ID.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 解散子区。
  ///
  /// @note
  /// 只有子区所属群组的群主及管理员可调用该方法。
  /// 单设备登录时，子区所在群的所有成员均会收到 [EMChatThreadEventHandler.onChatThreadDestroy] 。
  /// 多端多设备登录时，其他设备会收到 [EMMultiDeviceEventHandler.onChatThreadEvent] 回调，Event 的值为 [EMMultiDevicesEvent.CHAT_THREAD_DESTROY]。
  ///
  /// Param [chatThreadId] 子区 ID。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> destroyChatThread({
    required String chatThreadId,
  }) async {
    Map req = {
      "threadId": chatThreadId,
    };
    Map result = await _channel.invokeMethod(
      ChatMethodKeys.destroyChatThread,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  Future<void> _onChatThreadCreated(Map? event) async {
    if (event == null) {
      return;
    }
    _eventHandlesMap.values.forEach((element) {
      element.onChatThreadCreate?.call(EMChatThreadEvent.fromJson(event));
    });
  }

  Future<void> _onChatThreadUpdated(Map? event) async {
    if (event == null) {
      return;
    }
    _eventHandlesMap.values.forEach((element) {
      element.onChatThreadUpdate?.call(EMChatThreadEvent.fromJson(event));
    });
  }

  Future<void> _onChatThreadDestroyed(Map? event) async {
    if (event == null) {
      return;
    }
    _eventHandlesMap.values.forEach((element) {
      element.onChatThreadDestroy?.call(EMChatThreadEvent.fromJson(event));
    });
  }

  Future<void> _onChatThreadUserRemoved(Map? event) async {
    if (event == null) {
      return;
    }

    _eventHandlesMap.values.forEach((element) {
      element.onUserKickOutOfChatThread?.call(
        EMChatThreadEvent.fromJson(event),
      );
    });
  }
}
