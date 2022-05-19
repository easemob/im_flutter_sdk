import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'em_listeners.dart';
import 'tools/em_extension.dart';
import 'internal/chat_method_keys.dart';
import 'models/em_chat_thread.dart';

class EMChatThreadManager {
  static const _channelPrefix = 'com.chat.im';
  static const MethodChannel _channel = const MethodChannel(
      '$_channelPrefix/chat_thread_manager', JSONMethodCodec());

  final List<EMChatThreadManagerListener> _listeners = [];

  void addChatThreadManagerListener(EMChatThreadManagerListener listener) {
    _listeners.add(listener);
  }

  void removeChatThreadManagerListener(EMChatThreadManagerListener listener) {
    _listeners.remove(listener);
  }

  Future<EMChatThread?> fetchChatThread({
    required String chatThreadId,
  }) async {
    Map req = {"threadId": chatThreadId};
    Map result = await _channel.invokeMethod(
      ChatMethodKeys.fetchChatThread,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
      return EMChatThread.fromJson(result[ChatMethodKeys.fetchChatThread]);
    } on EMError catch (e) {
      throw e;
    }
  }

  Future<EMChatThread?> fetchChatThreadDetail({
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

  Future<EMCursorResult<EMChatThread>> fetchChatThreadsWithParentId({
    required String parentId,
    String? cursor,
    int pageSize = 20,
  }) async {
    Map req = {"pageSize": pageSize};
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

  Future<Map<String, EMMessage>?> fetchLastMessageWithChatThreads({
    required List<String> threadIds,
  }) async {
    Map req = {
      "threadIds": threadIds,
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

  Future<void> removeMemberFromChatThread({
    required String memberId,
    required String threadId,
  }) async {
    Map req = {
      "memberId": memberId,
      "threadId": threadId,
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

  Future<void> updateChatThreadName({
    required String newName,
    required String threadId,
  }) async {
    Map req = {
      "name": newName,
      "threadId": threadId,
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

  Future<EMChatThread> joinChatThread({
    required String threadId,
  }) async {
    Map req = {
      "threadId": threadId,
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

  Future<void> leaveChatThread({
    required String threadId,
  }) async {
    Map req = {
      "threadId": threadId,
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

  Future<void> destroyChatThread({
    required String threadId,
  }) async {
    Map req = {
      "threadId": threadId,
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
}
