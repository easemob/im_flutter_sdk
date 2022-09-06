// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/services.dart';
import 'internal/inner_headers.dart';

///
/// 用户在线状态管理类。
///
class EMPresenceManager {
  static const _channelPrefix = 'com.chat.im';
  static const MethodChannel _channel = const MethodChannel(
      '$_channelPrefix/chat_presence_manager', JSONMethodCodec());

  final Map<String, EMPresenceEventHandler> _eventHandlesMap = {};
  // will deprecated
  final List<EMPresenceManagerListener> _listeners = [];

  /// @nodoc
  EMPresenceManager() {
    _channel.setMethodCallHandler((MethodCall call) async {
      Map? argMap = call.arguments;
      if (call.method == ChatMethodKeys.onPresenceStatusChanged) {
        return _presenceChange(argMap!);
      }
      return null;
    });
  }

  ///
  /// 添加 [EMPresenceEventHandler] 。
  ///
  /// Param [identifier] handler对应的id，可用于删除handler。
  ///
  /// Param [handler] 添加的 [EMChatEventHandler]。
  ///
  void addEventHandler(
    String identifier,
    EMPresenceEventHandler handler,
  ) {
    _eventHandlesMap[identifier] = handler;
  }

  ///
  /// 移除 [EMPresenceEventHandler] 。
  ///
  /// Param [identifier] 需要移除 handler 对应的 id。
  ///
  void removeEventHandler(String identifier) {
    _eventHandlesMap.remove(identifier);
  }

  ///
  /// 获取 [EMPresenceEventHandler] 。
  ///
  /// Param [identifier] 要获取 handler 对应的 id。
  ///
  /// **Return** 返回 id 对应的 handler 。
  ///
  EMPresenceEventHandler? getEventHandler(String identifier) {
    return _eventHandlesMap[identifier];
  }

  ///
  /// 清除所有的 [EMPresenceEventHandler] 。
  ///
  void clearEventHandlers() {
    _eventHandlesMap.clear();
  }

  ///
  /// 发布自定义用户在线状态。
  ///
  /// Param [description] 用户在线状态的扩展信息。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。参见 [EMError]。
  ///
  Future<void> publishPresence(
    String description,
  ) async {
    Map req = {'desc': description};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.presenceWithDescription, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 订阅指定用户的在线状态。
  ///
  /// Param [members] 要订阅在线状态的用户 ID 数组。
  ///
  /// Param [expiry] 订阅时长，单位为秒。最长不超过 2,592,000 (30×24×3600) 秒，即 30 天。
  ///
  /// **Return** 返回被订阅用户的当前状态。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。参见 [EMError]。
  ///
  Future<List<EMPresence>> subscribe({
    required List<String> members,
    required int expiry,
  }) async {
    Map req = {'members': members, "expiry": expiry};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.presenceSubscribe, req);
    try {
      EMError.hasErrorFromResult(result);
      List<EMPresence> list = [];
      result[ChatMethodKeys.presenceSubscribe]?.forEach((element) {
        list.add(EMPresence.fromJson(element));
      });
      return list;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 取消订阅指定用户的在线状态。
  ///
  /// Param [members] 要取消订阅在线状态的用户 ID 数组。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。参见 [EMError]。
  ///
  Future<void> unsubscribe({
    required List<String> members,
  }) async {
    Map req = {'members': members};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.presenceUnsubscribe, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 分页查询当前用户订阅了哪些用户的在线状态。
  ///
  /// Param [pageNum] 当前页码，从 1 开始。
  ///
  /// Param [pageSize] 每页显示的被订阅用户数量。
  ///
  /// **Return** 返回订阅的在线状态所属的用户 ID。若当前未订阅任何用户的在线状态，返回空列表。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。参见 [EMError]。
  ///
  Future<List<String>> fetchSubscribedMembers({
    int pageNum = 1,
    int pageSize = 20,
  }) async {
    Map req = {'pageNum': pageNum, "pageSize": pageSize};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.fetchSubscribedMembersWithPageNum, req);
    try {
      EMError.hasErrorFromResult(result);
      List<String> list = [];
      result[ChatMethodKeys.fetchSubscribedMembersWithPageNum]
          ?.forEach((element) {
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
  /// 查询指定用户的当前在线状态。
  ///
  /// Param [members] 用户 ID 数组，指定要查询哪些用户的在线状态。
  ///
  /// **Return** 被订阅用户的当前状态。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。参见 [EMError]。
  ///
  Future<List<EMPresence>> fetchPresenceStatus({
    required List<String> members,
  }) async {
    Map req = {'members': members};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.fetchPresenceStatus, req);
    try {
      EMError.hasErrorFromResult(result);
      List<EMPresence> list = [];
      result[ChatMethodKeys.fetchPresenceStatus]?.forEach((element) {
        list.add(EMPresence.fromJson(element));
      });
      return list;
    } on EMError catch (e) {
      throw e;
    }
  }

  Future<void> _presenceChange(Map event) async {
    List? mapList = event['presences'];
    if (mapList == null) {
      return;
    }
    List<EMPresence> pList = [];
    for (var item in mapList) {
      pList.add(EMPresence.fromJson(item));
    }

    for (var handle in _eventHandlesMap.values) {
      handle.onPresenceStatusChanged?.call(pList);
    }

    _forward(pList);
  }
}

extension PresenceDeprecated on EMPresenceManager {
  ///
  /// 添加用户状态变化监听器。
  ///
  /// Param [listener] 状态变化监听类 [EMPresenceManagerListener]。
  ///
  @Deprecated("Use EMPresenceManager.addEventHandler to instead")
  void addPresenceManagerListener(EMPresenceManagerListener listener) {
    _listeners.remove(listener);
    _listeners.add(listener);
  }

  ///
  /// 移除用户状态变化监听器。
  ///
  /// Param [listener] 状态变化监听类。
  ///
  @Deprecated("Use EMPresenceManager.removeEventHandler to instead")
  void removePresenceManagerListener(EMPresenceManagerListener listener) {
    if (_listeners.contains(listener)) {
      _listeners.remove(listener);
    }
  }

  /// 移除所有用户状态监听器。
  @Deprecated("Use EMPresenceManager.clearEventHandlers to instead")
  void clearAllPresenceManagerListener() {
    _listeners.clear();
  }

  @deprecated
  void _forward(List<EMPresence> pList) {
    for (var listener in _listeners) {
      listener.onPresenceStatusChanged(pList);
    }
  }
}
