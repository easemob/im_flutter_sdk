import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk/src/models/em_chat_thread_event.dart';

import 'tools/em_extension.dart';
import 'internal/chat_method_keys.dart';
import 'models/em_chat_thread.dart';

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
      } else if (call.method == ChatMethodKeys.onUserKickOutOfChatThread) {}
      _onChatThreadUserRemoved(argMap);
      return null;
    });
  }
  final List<EMChatThreadManagerListener> _listeners = [];

  void addChatThreadManagerListener(EMChatThreadManagerListener listener) {
    _listeners.add(listener);
  }

  void removeChatThreadManagerListener(EMChatThreadManagerListener listener) {
    _listeners.remove(listener);
  }

  ///
  /// Get the thread detail
  ///
  /// Param [chatThreadId] The id of the subarea to get
  ///
  /// **Return**
  ///
  /// **Throws**
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
  /// Get the subareas the user has joined from the server
  ///
  /// Param [cursor] The position cursor of the last fetch
  ///
  /// Param [pageSize] Number of single requests, limit 50
  ///
  /// **Return**
  ///
  /// **Throws**
  ///
  Future<EMCursorResult<EMChatThread>> fetchJoinedChatThreads({
    String? cursor,
    int pageSize = 20,
  }) async {
    Map req = {"pageSize": pageSize};
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
  /// Param [parentId] The session id of the upper level of the sub-area
  ///
  /// Param [cursor] The position cursor of the last fetch
  ///
  /// Param [pageSize] Number of single requests, limit 50
  ///
  /// **Return**
  ///
  /// **Throws**
  ///
  Future<EMCursorResult<EMChatThread>> fetchChatThreadsWithParentId({
    required String parentId,
    String? cursor,
    int pageSize = 20,
  }) async {
    Map req = {
      "parentId": parentId,
      "pageSize": pageSize,
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
  /// Get the mine subareas under a group from the server
  ///
  /// Param [parentId] The session id of the upper level of the sub-area
  ///
  /// Param [cursor] The position cursor of the last fetch
  ///
  /// Param [pageSize] Number of single requests, limit 50
  ///
  /// **Return**
  ///
  /// **Throws**
  ///
  Future<EMCursorResult<EMChatThread>> fetchJoinedChatThreadsWithParentId({
    required String parentId,
    String? cursor,
    int pageSize = 20,
  }) async {
    Map req = {
      "parentId": parentId,
      "pageSize": pageSize,
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
  /// Get a list of members in a subsection
  ///
  /// Param [chatThreadId] The id of the subarea to get members
  ///
  /// Param [cursor] The position cursor of the last fetch
  ///
  /// Param [pageSize] Number of single requests, limit 50
  ///
  /// **Return**
  ///
  /// **Throws**
  ///
  Future<List<String>?> fetchChatThreadMember({
    required String chatThreadId,
    String? cursor,
    int pageSize = 20,
  }) async {
    Map req = {
      "pageSize": pageSize,
      "threadId": chatThreadId,
    };
    req.setValueWithOutNull("cursor", cursor);
    Map result = await _channel.invokeMethod(
      ChatMethodKeys.fetchChatThreadMember,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.fetchChatThreadMember]?.cast<String>();
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  ///
  /// Param [chatThreadIds] The ids of the subarea to get(No more than 20 ids for a single request)
  ///
  /// **Return**  return a map key is the sub-area id, value is the EMMessage object
  ///
  /// **Throws**
  ///
  Future<Map<String, EMMessage>?> fetchLastMessageWithChatThreads({
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
      if (map == null) {
        return null;
      }
      Map<String, EMMessage> ret = {};
      for (var key in map.keys) {
        Map<String, Object> msgMap = map[key].cast<Map<String, Object>>();
        ret[key] = EMMessage.fromJson(msgMap);
      }
      return ret.keys.length > 0 ? ret : null;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Remove sub-zone members (only available for group management)
  ///
  /// Param [memberId] To remove the user's ease id
  ///
  /// Param [chatThreadId] subarea id to operate
  ///
  /// **Throws**
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
  /// Update subarea name (only available for group managers or creators)
  ///
  /// Param [newName] the name you want to change（limit 64 character）
  ///
  /// Param [chatThreadId] subarea id to operate
  ///
  /// **Throws**
  ///
  Future<void> updateChatThreadName({
    required String newName,
    required String chatThreadId,
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
  /// Create a subsection
  ///
  /// Param [name] The id of the subarea to get（limit 64 character）
  ///
  /// Param [messageId] The message id of the operation to create the sub-area
  ///
  /// Param [parentId] The session id where the message of the operation creates the sub-area is also the to of that message
  ///
  /// **Return** EMChatThread object
  ///
  /// **Throws**
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
  /// join a subsection
  ///
  /// Param [chatThreadId] The id of the subarea to join
  ///
  /// **Return** EMChatThread object
  ///
  /// **Throws**
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
  /// leave a subsection
  ///
  /// Param [chatThreadId] The id of the subarea to leave
  ///
  /// **Throws**
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
  /// destroy a subsection
  ///
  /// Param [chatThreadId] The id of the subarea to destroy
  ///
  /// **Throws**
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
