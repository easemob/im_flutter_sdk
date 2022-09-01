import 'package:flutter/services.dart';
import 'event_handler/manager_event_handler.dart';
import 'internal/inner_headers.dart';

///
/// The Manager that defines how to manage presence states.
///
class EMPresenceManager {
  static const _channelPrefix = 'com.chat.im';
  static const MethodChannel _channel = const MethodChannel(
      '$_channelPrefix/chat_presence_manager', JSONMethodCodec());

  final Map<String, EMPresenceManagerEventHandle> _eventHandleMap = {};
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
  /// Adds the presence manager event handle. After calling this method, you can handle for new presence event when they arrive.
  ///
  /// Param [identifier] The custom handle identifier, is used to find the corresponding handle.
  ///
  /// Param [handle] The presence manager handle that handle for room event. See {@link EMPresenceManagerEventHandle}.
  ///
  void addEventHandle(
    String identifier,
    EMPresenceManagerEventHandle handle,
  ) {
    _eventHandleMap[identifier] = handle;
  }

  ///
  /// Remove the presence manager event handle.
  ///
  /// Param [identifier] The custom handle identifier.
  ///
  void removeEventHandle(String identifier) {
    _eventHandleMap.remove(identifier);
  }

  ///
  /// Get the presence manager event handle.
  ///
  /// Param [identifier] The custom handle identifier.
  ///
  /// **Return** The presence manager event handle.
  ///
  EMPresenceManagerEventHandle? getEventHandle(String identifier) {
    return _eventHandleMap[identifier];
  }

  ///
  /// Clear all presence manager event handles.
  ///
  void clearEventHandles() {
    _eventHandleMap.clear();
  }

  ///
  /// Publishes a custom presence state.
  ///
  /// Param [description] The extension information of the presence state. It can be set as nil.
  ///
  /// **Throws** A description of the exception. See {@link EMError}.
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
  /// Subscribes to a user's presence states. If the subscription succeeds, the subscriber will receive the callback when the user's presence state changes.
  ///
  /// Param [members] The list of IDs of users whose presence states you want to subscribe to.
  ///
  /// Param [expiry] The expiration time of the presence subscription.
  ///
  /// **Return** Which contains IDs of users whose presence states you have subscribed to.
  ///
  /// **Throws** A description of the exception. See {@link EMError}.
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
  /// Unsubscribes from a user's presence states.
  ///
  /// Param [members] The array of IDs of users whose presence states you want to unsubscribe from.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Uses pagination to get a list of users whose presence states you have subscribed to.
  ///
  /// Param [pageNum] The current page number, starting from 1.
  ///
  /// Param [pageSize] The number of subscribed users on each page.
  ///
  /// **Return** Which contains IDs of users whose presence states you have subscribed to. Returns null if you subscribe to no user's presence state.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Gets the current presence state of users.
  ///
  /// Param [members] The array of IDs of users whose current presence state you want to check.
  ///
  /// **Return** Which contains the users whose presence state you have subscribed to.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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

    for (var handle in _eventHandleMap.values) {
      handle.onPresenceStatusChanged?.call(pList);
    }

    // ignore: deprecated_member_use_from_same_package
    _forward(pList);
  }
}

extension PresenceDeprecated on EMPresenceManager {
  ///
  /// Registers a new presence manager listener.
  ///
  /// Param [listener] The presence manager listener to be registered: {@link EMPresenceManagerListener}.
  ///
  @Deprecated("Use EMPresenceManager#addEventHandle to instead.")
  void addPresenceManagerListener(EMPresenceManagerListener listener) {
    _listeners.remove(listener);
    _listeners.add(listener);
  }

  ///
  /// Removes the contact listener.
  ///
  /// Param [listener] The presence manager listener to be removed.
  ///
  @Deprecated("Use EMPresenceManager#removeEventHandle to instead.")
  void removePresenceManagerListener(EMPresenceManagerListener listener) {
    if (_listeners.contains(listener)) {
      _listeners.remove(listener);
    }
  }

  @Deprecated("Use EMPresenceManager#clearEventHandles to instead.")
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
