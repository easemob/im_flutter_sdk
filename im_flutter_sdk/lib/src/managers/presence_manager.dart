import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';

/// ~english
/// The Manager that defines how to manage presence states.
/// ~end
///
/// ~chinese
/// 用户在线状态管理类。
/// ~end
class EMPresenceManager {
  final Map<String, EMPresenceEventHandler> _eventHandlesMap = {};

  /// ~english
  /// Adds the presence event handler. After calling this method, you can handle for new presence event when they arrive.
  ///
  /// Param [identifier] The custom handler identifier, is used to find the corresponding handler.
  ///
  /// Param [handler] The handle for presence event. See [EMPresenceEventHandler].
  /// ~end
  ///
  /// ~chinese
  /// 添加用户状态变化监听器。
  ///
  /// Param [identifier] 事件 ID。
  ///
  /// Param [handler] Presence 事件。
  /// ~end
  void addEventHandler(
    String identifier,
    EMPresenceEventHandler handler,
  ) {
    _eventHandlesMap[identifier] = handler;
  }

  /// ~english
  /// Remove the presence event handler.
  ///
  /// Param [identifier] The custom handler identifier.
  /// ~end
  ///
  /// ~chinese
  /// 移除用户状态变化监听器。
  ///
  /// Param [identifier] 事件 ID。
  /// ~end
  void removeEventHandler(String identifier) {
    _eventHandlesMap.remove(identifier);
  }

  /// ~english
  /// Get the presence event handler.
  ///
  /// Param [identifier] The custom handler identifier.
  ///
  /// **Return** The presence event handler.
  /// ~end
  ///
  /// ~chinese
  /// 获取 Presence 事件句柄。
  ///
  /// Param [identifier] 事件对应 ID.
  ///
  /// **Return** Presence 事件。
  /// ~end
  EMPresenceEventHandler? getEventHandler(String identifier) {
    return _eventHandlesMap[identifier];
  }

  /// ~english
  /// Clear all presence event handlers.
  /// ~end
  ///
  /// ~chinese
  /// 清除所有 Presence 事件。
  /// ~end
  void clearEventHandlers() {
    _eventHandlesMap.clear();
  }

  /// ~english
  /// Publishes a custom presence state.
  ///
  /// Param [description] The extension information of the presence state. It can be set as nil.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 发布自定义用户在线状态。
  ///
  /// Param [description] 用户在线状态的扩展信息。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。参见 [EMError]。
  /// ~end

  Future<void> publishPresence(
    String description,
  ) async {
    try {
      Map req = {'desc': description};
      Map result = await Client.instance.presenceManager
          .callNativeMethod(ChatMethodKeys.presenceWithDescription, req);
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Subscribes to a user's presence states. If the subscription succeeds, the subscriber will receive the callback when the user's presence state changes.
  ///
  /// Param [members] The list of IDs of users whose presence states you want to subscribe to.
  ///
  /// Param [expiry] The expiration time of the presence subscription.
  ///
  /// **Return** Which contains IDs of users whose presence states you have subscribed to.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 订阅指定用户的在线状态。
  ///
  /// Param [members] 要订阅在线状态的用户 ID 数组。
  ///
  /// Param [expiry] 订阅时长，单位为秒。最长不超过 2,592,000 (30×24×3600) 秒，即 30 天。
  ///
  /// **Return** 返回被订阅用户的当前状态。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。参见 [EMError]。
  /// ~end

  Future<List<EMPresence>> subscribe({
    required List<String> members,
    required int expiry,
  }) async {
    try {
      Map req = {'members': members, "expiry": expiry};
      Map result = await Client.instance.presenceManager
          .callNativeMethod(ChatMethodKeys.presenceSubscribe, req);
      EMError.hasErrorFromResult(result);
      List<EMPresence> list = [];
      result[ChatMethodKeys.presenceSubscribe]?.forEach((element) {
        list.add(EMPresence.fromJson(element));
      });
      return list;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Unsubscribes from a user's presence states.
  ///
  /// Param [members] The array of IDs of users whose presence states you want to unsubscribe from.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 取消订阅指定用户的在线状态。
  ///
  /// Param [members] 要取消订阅在线状态的用户 ID 数组。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。参见 [EMError]。
  /// ~end

  Future<void> unsubscribe({
    required List<String> members,
  }) async {
    try {
      Map req = {'members': members};
      Map result = await Client.instance.presenceManager
          .callNativeMethod(ChatMethodKeys.presenceUnsubscribe, req);
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Uses pagination to get a list of users whose presence states you have subscribed to.
  ///
  /// Param [pageNum] The current page number, starting from 1.
  ///
  /// Param [pageSize] The number of subscribed users on each page.
  ///
  /// **Return** Which contains IDs of users whose presence states you have subscribed to. Returns null if you subscribe to no user's presence state.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 分页查询当前用户订阅了哪些用户的在线状态。
  ///
  /// Param [pageNum] 当前页码，从 1 开始。
  ///
  /// Param [pageSize] 每页显示的被订阅用户数量。
  ///
  /// **Return** 返回订阅的在线状态所属的用户 ID。若当前未订阅任何用户的在线状态，返回空列表。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。参见 [EMError]。
  /// ~end

  Future<List<String>> fetchSubscribedMembers({
    int pageNum = 1,
    int pageSize = 20,
  }) async {
    try {
      Map req = {'pageNum': pageNum, "pageSize": pageSize};
      Map result = await Client.instance.presenceManager.callNativeMethod(
          ChatMethodKeys.fetchSubscribedMembersWithPageNum, req);
      EMError.hasErrorFromResult(result);
      List<String> list = [];
      result[ChatMethodKeys.fetchSubscribedMembersWithPageNum]
          ?.forEach((element) {
        if (element is String) {
          list.add(element);
        }
      });
      return list;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the current presence state of users.
  ///
  /// Param [members] The array of IDs of users whose current presence state you want to check.
  ///
  /// **Return** Which contains the users whose presence state you have subscribed to.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 查询指定用户的当前在线状态。
  ///
  /// Param [members] 用户 ID 数组，指定要查询哪些用户的在线状态。
  ///
  /// **Return** 被订阅用户的当前状态。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。参见 [EMError]。
  /// ~end

  Future<List<EMPresence>> fetchPresenceStatus({
    required List<String> members,
  }) async {
    try {
      Map req = {'members': members};
      Map result = await Client.instance.presenceManager
          .callNativeMethod(ChatMethodKeys.fetchPresenceStatus, req);
      EMError.hasErrorFromResult(result);
      List<EMPresence> list = [];
      result[ChatMethodKeys.fetchPresenceStatus]?.forEach((element) {
        list.add(EMPresence.fromJson(element));
      });
      return list;
    } catch (e) {
      rethrow;
    }
  }
}
