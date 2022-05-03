import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk/src/models/em_presence.dart';
import 'internal/chat_method_keys.dart';

class EMPresenceManager {
  static const _channelPrefix = 'com.chat.im';
  static const MethodChannel _channel = const MethodChannel(
      '$_channelPrefix/chat_presence_manager', JSONMethodCodec());
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
  /// Registers a new presence manager listener.
  ///
  /// Param [listener] The presence manager listener to be registered: {@link EMPresenceManagerListener}.
  ///
  void addPresenceListener(EMPresenceManagerListener listener) {
    _listeners.add(listener);
  }

  ///
  /// Removes the contact listener.
  ///
  /// Param [listener] The presence manager listener to be removed.
  ///
  void removePresenceListener(EMPresenceManagerListener listener) {
    if (_listeners.contains(listener)) {
      _listeners.remove(listener);
    }
  }

  void publishPresenceWithDescription({
    required String description,
  }) async {
    Map req = {'desc': description};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.presenceWithDescription, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  Future<List<EMPresence>?> subscribe({
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

  void unSubscribe({
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

  Future<List<String>?> fetchSubscribedMembers({
    int pageNum = 0,
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
        list.add(element);
      });
      return list;
    } on EMError catch (e) {
      throw e;
    }
  }

  Future<List<EMPresence>?> fetchPresenceStatus({
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

    for (var listener in _listeners) {
      listener.onPresenceStatusChanged(pList);
    }
  }
}
