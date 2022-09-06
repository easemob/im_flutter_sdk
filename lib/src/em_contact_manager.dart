// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';

import 'package:flutter/services.dart';
import 'internal/inner_headers.dart';

///
/// `EMContactManager` 是联系人管理类，用于记录、查询和修改用户的联系人列表。
///
class EMContactManager {
  static const _channelPrefix = 'com.chat.im';
  static const MethodChannel _channel = const MethodChannel(
      '$_channelPrefix/chat_contact_manager', JSONMethodCodec());

  /// @nodoc
  EMContactManager() {
    _channel.setMethodCallHandler((MethodCall call) async {
      Map? argMap = call.arguments;
      if (call.method == ChatMethodKeys.onContactChanged) {
        return _onContactChanged(argMap!);
      }
      return null;
    });
  }

  final Map<String, EMContactEventHandler> _eventHandlesMap = {};

  final List<EMContactManagerListener> _listeners = [];

  Future<void> _onContactChanged(Map event) async {
    var type = event['type'];
    String username = event['username'];
    String? reason = event['reason'];

    _eventHandlesMap.values.forEach((element) {
      switch (type) {
        case EMContactChangeEvent.CONTACT_ADD:
          element.onContactAdded?.call(username);
          break;
        case EMContactChangeEvent.CONTACT_DELETE:
          element.onContactDeleted?.call(username);
          break;
        case EMContactChangeEvent.INVITED:
          element.onContactInvited?.call(username, reason);
          break;
        case EMContactChangeEvent.INVITATION_ACCEPTED:
          element.onFriendRequestAccepted?.call(username);
          break;
        case EMContactChangeEvent.INVITATION_DECLINED:
          element.onFriendRequestDeclined?.call(username);
          break;
        default:
      }
    });

    // deprecated(3.9.5)
    for (var listener in _listeners) {
      switch (type) {
        case EMContactChangeEvent.CONTACT_ADD:
          listener.onContactAdded(username);
          break;
        case EMContactChangeEvent.CONTACT_DELETE:
          listener.onContactDeleted(username);
          break;
        case EMContactChangeEvent.INVITED:
          listener.onContactInvited(username, reason);
          break;
        case EMContactChangeEvent.INVITATION_ACCEPTED:
          listener.onFriendRequestAccepted(username);
          break;
        case EMContactChangeEvent.INVITATION_DECLINED:
          listener.onFriendRequestDeclined(username);
          break;
        default:
      }
    }
  }

  ///
  /// 添加 [EMContactEventHandler] 。
  ///
  /// Param [identifier] handler对应的id，可用于删除handler。
  ///
  /// Param [handler] 添加的 [EMContactEventHandler]。
  ///
  void addEventHandler(
    String identifier,
    EMContactEventHandler handler,
  ) {
    _eventHandlesMap[identifier] = handler;
  }

  ///
  /// 移除 [EMContactEventHandler] 。
  ///
  /// Param [identifier] 需要移除 handler 对应的 id。
  ///
  void removeEventHandler(String identifier) {
    _eventHandlesMap.remove(identifier);
  }

  ///
  /// 获取 [EMContactEventHandler] 。
  ///
  /// Param [identifier] 要获取 handler 对应的 id。
  ///
  /// **Return** 返回 id 对应的 handler 。
  ///
  EMContactEventHandler? getEventHandler(String identifier) {
    return _eventHandlesMap[identifier];
  }

  ///
  /// 清除所有的 [EMContactEventHandler] 。
  ///
  void clearEventHandlers() {
    _eventHandlesMap.clear();
  }

  ///
  /// 添加联系人。
  ///
  /// Param [userId] 要添加的好友的用户 ID。
  ///
  /// Param [reason] （可选）添加为好友的原因。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError] 。
  ///
  Future<void> addContact(
    String userId, {
    String? reason,
  }) async {
    Map req = {
      'username': userId,
    };
    req.setValueWithOutNull("reason", reason);

    Map result = await _channel.invokeMethod(ChatMethodKeys.addContact, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 删除联系人及其相关的会话。
  ///
  /// Param [username] 要删除的联系人用户 ID。
  ///
  /// Param [keepConversation] 是否保留要删除的联系人的会话。
  /// - `true`：是；
  /// - （默认）`false`：否。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。
  ///
  Future<void> deleteContact(
    String username, {
    bool keepConversation = false,
  }) async {
    Map req = {'username': username, 'keepConversation': keepConversation};
    Map result = await _channel.invokeMethod(ChatMethodKeys.deleteContact, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 从服务器获取联系人列表。
  ///
  /// **Return** 联系人列表。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError] 。
  ///
  Future<List<String>> getAllContactsFromServer() async {
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.getAllContactsFromServer);
    try {
      EMError.hasErrorFromResult(result);
      List<String> list = [];
      result[ChatMethodKeys.getAllContactsFromServer]?.forEach((element) {
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
  /// 从数据库获取好友列表。
  ///
  /// **Return** 调用成功会返回好友列表。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError] 。
  ///
  Future<List<String>> getAllContactsFromDB() async {
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.getAllContactsFromDB);
    try {
      EMError.hasErrorFromResult(result);
      List<String> list = [];
      result[ChatMethodKeys.getAllContactsFromDB]?.forEach((element) {
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
  /// 将指定用户加入黑名单。
  /// 你可以向黑名单中用户发消息，但是接收不到对方发送的消息。
  ///
  /// Param [username] 要加入黑名单的用户的用户 ID。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError] 。
  ///
  Future<void> addUserToBlockList(
    String username,
  ) async {
    Map req = {'username': username};
    Map result = await _channel.invokeMethod(
      ChatMethodKeys.addUserToBlockList,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 将指定用户移除黑名单。
  ///
  /// Param [username] 要在黑名单中移除的用户 ID。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError] 。
  ///
  Future<void> removeUserFromBlockList(String username) async {
    Map req = {'username': username};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.removeUserFromBlockList, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 从服务器获取黑名单列表。
  ///
  /// **Return** 该方法调用成功会返回黑名单列表。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError] 。
  ///
  Future<List<String>> getBlockListFromServer() async {
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.getBlockListFromServer);
    try {
      EMError.hasErrorFromResult(result);
      List<String> list = [];
      result[ChatMethodKeys.getBlockListFromServer]?.forEach((element) {
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
  /// 从本地数据库获取黑名单列表。
  ///
  /// **Return** 该方法调用成功会返回黑名单列表。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError] 。
  ///
  Future<List<String>> getBlockListFromDB() async {
    Map result = await _channel.invokeMethod(ChatMethodKeys.getBlockListFromDB);
    try {
      EMError.hasErrorFromResult(result);
      List<String> list = [];
      result[ChatMethodKeys.getBlockListFromDB]?.forEach((element) {
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
  /// 接受加好友的邀请。
  ///
  /// Param [username] 发起好友邀请的用户 ID。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError] 。
  ///
  Future<void> acceptInvitation(String username) async {
    Map req = {'username': username};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.acceptInvitation, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 拒绝加好友的邀请。
  ///
  /// Param [username] 发起好友邀请的用户 ID。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError] 。
  ///
  Future<void> declineInvitation(String username) async {
    Map req = {'username': username};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.declineInvitation, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 获取登录用户在其他登录设备上唯一 ID，该 ID 由 username + "/" + resource 组成。
  ///
  /// **Return** 该方法调用成功会返回 ID 列表。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError] 。
  ///
  Future<List<String>> getSelfIdsOnOtherPlatform() async {
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.getSelfIdsOnOtherPlatform);
    try {
      EMError.hasErrorFromResult(result);
      List<String> devices = [];
      result[ChatMethodKeys.getSelfIdsOnOtherPlatform]?.forEach((element) {
        devices.add(element);
      });
      return devices;
    } on EMError catch (e) {
      throw e;
    }
  }
}

extension EMContactManagerDeprecated on EMContactManager {
  ///
  /// 注册联系人监听器。
  ///
  /// Param [listener] 要注册的联系人监听器。
  ///
  @Deprecated("Use EMContactManager.addEventHandler to instead")
  void addContactManagerListener(EMContactManagerListener listener) {
    _listeners.remove(listener);
    _listeners.add(listener);
  }

  ///
  /// 移除联系人监听器。
  ///
  /// Param [listener] 要移除的联系人监听器。
  ///
  @Deprecated("Use EMContactManager.removeEventHandler to instead")
  void removeContactManagerListener(EMContactManagerListener listener) {
    _listeners.remove(listener);
  }

  ///
  /// 移除所有的联系人监听。
  ///
  @Deprecated("Use EMContactManager.clearEventHandlers to instead")
  void clearContactManagerListeners() {
    _listeners.clear();
  }
}
