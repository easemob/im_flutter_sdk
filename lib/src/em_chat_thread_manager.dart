import 'package:flutter/services.dart';

import 'internal/inner_headers.dart';

///
/// The chat thread manager class.
///
class EMChatThreadManager {
  static const _channelPrefix = 'com.chat.im';
  static const MethodChannel _channel = const MethodChannel(
      '$_channelPrefix/chat_thread_manager', JSONMethodCodec());

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
  final List<EMChatThreadManagerListener> _listeners = [];

  ///
  /// Adds the chat thread manager listener. After calling this method, you can listen for new chat threads when they arrive.
  ///
  /// Param [listener] The chat thread manager listener that listens for new chat thread. See {@link EMChatThreadManagerListener}.
  ///
  void addChatThreadManagerListener(EMChatThreadManagerListener listener) {
    _listeners.remove(listener);
    _listeners.add(listener);
  }

  ///
  /// Removes the chat thread listener.
  ///
  /// After adding a chat thread manager listener, you can remove this listener if you do not want to listen for it.
  ///
  /// Param [listener] The chat thread listener to be removed. See {@link EMChatThreadManagerListener}.
  ///
  void removeChatThreadManagerListener(EMChatThreadManagerListener listener) {
    _listeners.remove(listener);
  }

  ///
  /// Removes all chat thread listeners.
  ///
  void clearAllChatThreadManagerListeners() {
    _listeners.clear();
  }

  ///
  /// Get Chat Thread details from server.
  ///
  /// Param [chatThreadId] Chat Thread ID.
  ///
  /// **Return** The chat thread object.
  ///
  /// **Throws** A description of the exception. See {@link EMError}.
  ///
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

  ///
  /// Paging to get the list of Chat Threads that the current user has joined from the server
  ///
  /// Param [cursor] The initial value can be empty or empty string.
  ///
  /// Param [limit] The number of fetches at one time. Value range (0, 50].
  ///
  /// **Return** Returns the result of {@link EMCursorResult}), including the cursor for getting data next time and the chat thread object list.
  ///
  /// **Throws** A description of the exception. See {@link EMError}.
  ///
  Future<EMCursorResult<EMChatThread>> fetchJoinedChatThreads({
    String? cursor,
    int limit = 20,
  }) async {
    Map req = {"pageSize": limit};
    req.setValueWithOutNull("cursor", cursor);
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

  ///
  /// Get the subareas under a group from the server
  ///
  /// Param [parentId] Parent ID, generally refers to group ID.
  ///
  /// Param [cursor] The initial value can be empty or empty string.
  ///
  /// Param [limit] The number of fetches at one time. Value range (0, 50].
  ///
  /// **Return** result of {@link EMCursorResult}), including the cursor for getting data next time and the chat thread object list.
  ///
  /// **Throws** A description of the exception. See {@link EMError}.
  ///
  Future<EMCursorResult<EMChatThread>> fetchChatThreadsWithParentId({
    required String parentId,
    String? cursor,
    int limit = 20,
  }) async {
    Map req = {
      "parentId": parentId,
      "pageSize": limit,
    };
    req.setValueWithOutNull("cursor", cursor);
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

  ///
  /// Paging to get the list of Chat Threads that the current user has joined the specified group from the server。
  ///
  /// Param [parentId] The session id of the upper level of the sub-area
  ///
  /// Param [cursor] The initial value can be empty or empty string.
  ///
  /// Param [limit] The number of fetches at one time. Value range (0, 50].
  ///
  /// **Return** The result of {@link EMCursorResult}), including the cursor for getting data next time and the chat thread object list.
  ///
  /// **Throws** A description of the exception. See {@link EMError}.
  ///
  Future<EMCursorResult<EMChatThread>> fetchJoinedChatThreadsWithParentId({
    required String parentId,
    String? cursor,
    int limit = 20,
  }) async {
    Map req = {
      "parentId": parentId,
      "pageSize": limit,
    };
    req.setValueWithOutNull("cursor", cursor);
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

  ///
  /// Paging to get Chat Thread members.
  ///
  /// The members of the group to which Chat Thread belongs have permission.
  ///
  /// Param [chatThreadId] Chat Thread ID.
  ///
  /// Param [cursor] The initial value can be empty or empty string.
  ///
  /// Param [limit] The number of fetches at one time. Value range (0, 50].
  ///
  /// **Return** The result of {@link EMCursorResult}), including the cursor for getting data next time and the chat thread member list.
  ///
  /// **Throws** A description of the exception. See {@link EMError}.
  ///
  Future<List<String>> fetchChatThreadMembers({
    required String chatThreadId,
    String? cursor,
    int limit = 20,
  }) async {
    Map req = {
      "pageSize": limit,
      "threadId": chatThreadId,
    };
    req.setValueWithOutNull("cursor", cursor);
    Map result = await _channel.invokeMethod(
      ChatMethodKeys.fetchChatThreadMember,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
      List<String> list = [];
      result[ChatMethodKeys.fetchChatThreadMember]?.forEach((element) {
        if (element is String) {
          list.add(element);
        }
      });
      return list;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Get the latest news of the specified Chat Thread list from the server.
  ///
  /// Param [chatThreadIds] Chat Thread id list. The list length is not greater than 20.
  ///
  /// **Return**  returns a Map collection, the key is the chat thread ID, and the value is the latest message object of the chat thread.
  ///
  /// **Throws** A description of the exception. See {@link EMError}.
  ///
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
      Map? map = result.getMapValue(
        ChatMethodKeys.fetchLastMessageWithChatThreads,
      );
      Map<String, EMMessage> ret = {};
      if (map == null) {
        return ret;
      }

      for (var key in map.keys) {
        Map<String, Object> msgMap = map[key].cast<Map<String, Object>>();
        ret[key] = EMMessage.fromJson(msgMap);
      }
      return ret;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Remove member from Chat Thread.
  ///
  /// Param [memberId] The ID of the member that was removed from Chat Thread.
  ///
  /// Param [chatThreadId] Chat Thread ID.
  ///
  /// **Throws** A description of the exception. See {@link EMError}.
  ///
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

  ///
  /// Change Chat Thread name.
  ///
  /// The group owner, group administrator and Thread creator have permission.
  /// After modifying chat thread name, members of the organization (group) to which chat thread belongs will receive the update notification event.
  /// You can set {@link EMChatThreadManagerListener} to listen on the event.
  ///
  /// Param [chatThreadId] Chat Thread ID.
  ///
  /// Param [newName]  New Chat Thread name. No more than 64 characters in length.
  ///
  /// **Throws** A description of the exception. See {@link EMError}.
  ///
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

  ///
  /// Create Chat Thread.
  ///
  /// Group members have permission.
  /// After chat thread is created, the following notices will appear:
  /// 1. Members of the organization (group) to which chat thread belongs will receive the created notification event,
  /// and can listen to related events by setting {@link EMChatThreadManagerListener}.
  /// The event callback function is {@link EMChatThreadManagerListener#onChatThreadCreated(EMChatThreadEvent)}.
  /// 2. Multiple devices will receive the notification event and you can set {@link com.hyphenate.EMMultiDeviceListener} to listen on the event.
  /// The event callback function is {@link EMMultiDeviceListener#onChatThreadEvent(EMMultiDevicesEvent, String, List)}, where the first parameter is the event,
  /// for example, {@link EMMultiDeviceListener#EMMultiDevicesEvent.CHAT_THREAD_CREATE} for the chat thread creation event.
  ///
  /// Param [name] Chat Thread name. No more than 64 characters in length.
  ///
  /// Param [messageId] Parent message ID, generally refers to group message ID.
  ///
  /// Param [parentId] Parent ID, generally refers to group ID.
  ///
  /// **Return** EMChatThread object
  ///
  /// **Throws** A description of the exception. See {@link EMError}.
  ///
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

  ///
  /// Join Chat Thread.
  ///
  /// Group members have permission.
  /// Join successfully, return the Chat Thread details {@link EMChatThread}, the details do not include the number of members.
  /// Repeated addition will throw an EMError.
  /// After joining chat thread, the multiple devices will receive the notification event.
  /// You can set {@link EMMultiDeviceListener} to listen on the event.
  /// The event callback function is {@link EMMultiDeviceListener#onChatThreadEvent(int, String, List),
  /// where the first parameter is the event, and chat thread join event is {@EMMultiDeviceListener#EMMultiDevicesEvent.CHAT_THREAD_JOIN}.
  ///
  /// Param [chatThreadId] Chat Thread ID.
  ///
  /// **Return** The joined chat thread object;
  ///
  /// **Throws** A description of the exception. See {@link EMError}.
  ///
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

  ///
  /// Leave Chat Thread.
  ///
  /// The operation is available to Chat Thread members.
  /// After leave chat thread, the multiple devices will receive the notification event.
  /// You can set {@EMMultiDeviceListener} to listen on the event.
  /// The event callback function is {@link EMMultiDeviceListener#onChatThreadEvent(int, String, List),
  /// where the first parameter is the event, and chat thread exit event is {@link EMMultiDeviceListener#EMMultiDevicesEvent.CHAT_THREAD_LEAVE}.
  ///
  /// Param [chatThreadId] Chat Thread ID.
  ///
  /// **Throws** A description of the exception. See {@link EMError}.
  ///
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

  ///
  /// Disband Chat Thread.
  ///
  /// Group owner and group administrator to which the Chat Thread belongs have permission.
  /// After chat thread is disbanded, there will be the following notification:
  /// 1. Members of the organization (group) to which chat thread belongs will receive the disbanded notification event,
  /// and can listen to related events by setting {@link EMChatThreadManagerListener}.
  /// The event callback function is {@link EMChatThreadManagerListener#onChatThreadDestroyed(EMChatThreadEvent)} .
  /// 2. Multiple devices will receive the notification event and you can set {@link EMMultiDeviceListener} to listen on the event.
  /// The event callback function is {@link EMMultiDeviceListener#onChatThreadEvent(int, String, List)}, where the first parameter is the event,
  /// for example, {@link com.hyphenate.EMMultiDeviceListener#EMMultiDevicesEvent.CHAT_THREAD_DESTROY} for the chat thread destruction event.
  ///
  /// Param [chatThreadId] Chat Thread ID.
  ///
  /// **Throws** A description of the exception. See {@link EMError}.
  ///
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
    _listeners.forEach((element) {
      element.onChatThreadCreate.call(EMChatThreadEvent.fromJson(event));
    });
  }

  Future<void> _onChatThreadUpdated(Map? event) async {
    if (event == null) {
      return;
    }
    _listeners.forEach((element) {
      element.onChatThreadUpdate.call(EMChatThreadEvent.fromJson(event));
    });
  }

  Future<void> _onChatThreadDestroyed(Map? event) async {
    if (event == null) {
      return;
    }
    _listeners.forEach((element) {
      element.onChatThreadDestroy.call(EMChatThreadEvent.fromJson(event));
    });
  }

  Future<void> _onChatThreadUserRemoved(Map? event) async {
    if (event == null) {
      return;
    }
    _listeners.forEach((element) {
      element.onUserKickOutOfChatThread.call(EMChatThreadEvent.fromJson(event));
    });
  }
}
