import 'package:flutter/services.dart';

import 'internal/inner_headers.dart';

///
/// 子区管理类。
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
  /// 注册子区监听。
  ///
  /// 接收到子区等回调可以通过设置此方法进行监听，详见 {@link EMChatThreadManagerListener}。
  ///
  /// Param [listener] 要注册的消息监听，详见 {@link EMChatThreadManagerListener}。
  ///
  void addChatThreadManagerListener(EMChatThreadManagerListener listener) {
    _listeners.remove(listener);
    _listeners.add(listener);
  }

  ///
  /// 移除子区监听。
  ///
  /// 该方法移除的是通过{@link #addChatThreadManagerListener(EMChatThreadManagerListener)} 方法添加的监听。
  ///
  /// Param [listener] 要移除的监听。
  ///
  void removeChatThreadManagerListener(EMChatThreadManagerListener listener) {
    _listeners.remove(listener);
  }

  ///
  /// 移除所有子区监听。
  ///
  void clearAllChatThreadManagerListeners() {
    _listeners.clear();
  }

  ///
  /// 从服务器获取子区详情。
  ///
  /// Param [chatThreadId] 子区 ID。
  ///
  /// **Return** 若调用成功，返回子区详情；失败则抛出异常。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}.
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
  /// 分页从服务器获取当前用户加入的子区列表。
  ///
  /// Param [cursor] 开始获取数据的游标位置。首次调用方法时可以不传，按用户加入子区时间的倒序获取数据。
  ///
  /// Param [limit] 每页期望返回的子区数。取值范围为 [1,50]。
  ///
  /// **Return** 若调用成功，返回子区列表；失败则抛出异常。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}.
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
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}.
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
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}.
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
  /// 分页获取子区成员。
  ///
  /// **注意**
  /// 子区所属群组的所有成员均可调用该方法。
  ///
  /// Param [chatThreadId] 子区 ID。
  ///
  /// Param [cursor] 开始获取数据的游标位置，首次调用方法时传 `null` 或空字符串，按成员加入子区时间的正序获取数据。
  ///
  /// Param [limit] 每页期望返回的成员数。取值范围为 [1,50]。
  ///
  /// **Return** 若调用成功，返回子区成员列表；失败则抛出异常。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}.
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
  /// 从服务器批量获取指定子区中的最新一条消息。
  ///
  /// Param [chatThreadIds] 要查询的子区 ID 列表，每次最多可传 20 个子区。
  ///
  /// **Return** 若调用成功，返回子区的最新一条消息列表；失败则抛出异常。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}.
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
  /// 移除子区成员。
  ///
  /// **注意**
  /// 只有子区所属群主、群管理员及子区创建者可调用该方法。
  ///
  /// 被移出的成员会收到 {@link EMChatThreadManagerListener#onUserKickOutOfChatThread} 回调。
  ///
  /// Param [memberId] 被移出子区的成员的用户 ID。
  ///
  /// Param [chatThreadId] 子区 ID。
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
  /// 修改子区名称。
  ///
  /// **注意**
  /// 只有子区所属群主、群管理员及子区创建者可调用该方法。
  ///
  /// 子区所属群组的所有成员均会收到  {@link EMChatThreadManagerListener#onChatThreadUpdated(EMChatThreadEvent)}.
  ///
  /// Param [chatThreadId] 子区 ID。
  ///
  /// Param [newName] 子区的新名称。长度不超过 64 个字符。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
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
  /// 创建子区。
  ///
  /// **注意**
  /// 所有群成员都可以调用。
  /// 子区创建成功后，会出现如下情况：
  ///
  /// - 单设备登录时，子区所属群组的所有成员均会收到  {@link EMChatThreadManagerListener#onChatThreadCreated(EMChatThreadEvent)}.
  ///
  /// - 多端多设备登录时，各设备会收到 {@link EMMultiDeviceListener#onChatThreadEvent(EMMultiDevicesEvent, String, List)} 回调。
  ///
  /// Param [name] 要创建的子区的名称。长度不超过 64 个字符。
  ///
  /// Param [messageId] 父消息 ID。
  ///
  /// Param [parentId] 群组 ID。
  ///
  /// **Return** 调用成功时，返回创建的子区对象；失败则抛出异常。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}.
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
  /// 加入子区。
  ///
  /// **注意**
  /// 子区所属群组的所有成员均可调用该方法。
  ///
  /// 加入成功后，多端多设备登录情况下，其他设备会收到 {@link EMMultiDeviceListener#onChatThreadEvent(int, String, List) 回调，Event 的值为 {@EMMultiDeviceListener#EMMultiDevicesEvent.CHAT_THREAD_JOIN}。
  ///
  /// Param [chatThreadId] 子区 ID。
  ///
  /// **Return** 若调用成功，返回子区详情 {@link ChatMessageThread}，详情中不含成员数量；失败则抛出异常。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}.
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
  /// 退出子区。
  ///
  /// **注意**
  /// 子区中的所有成员均可调用该方法。
  /// 多端多设备登录情况下，其他设备会收到 {@link EMMultiDeviceListener#onChatThreadEvent(int, String, List) 回调，Event 的值为 {@link EMMultiDeviceListener#EMMultiDevicesEvent.CHAT_THREAD_LEAVE}。
  ///
  /// Param [chatThreadId] 要退出的子区 ID。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}.
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
  /// 解散子区。
  ///
  /// **注意**
  /// 只有子区所属群组的群主及管理员可调用该方法。
  /// 单设备登录时，子区所在群的所有成员均会收到 {@link EMChatThreadManagerListener#onChatThreadDestroyed(EMChatThreadEvent)} 。
  /// 多端多设备登录时，其他设备会收到 {@link EMMultiDeviceListener#onChatThreadEvent(int, String, List) 回调，Event 的值为 {@EMMultiDeviceListener#EMMultiDevicesEvent.CHAT_THREAD_DESTROY}。
  ///
  /// Param [chatThreadId] 子区 ID。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}.
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
