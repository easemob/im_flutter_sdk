import "dart:async";

import 'package:flutter/services.dart';

import "em_listeners.dart";
import 'em_sdk_method.dart';

class EMContactManager {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emContactManagerChannel = const MethodChannel(
      '$_channelPrefix/em_contact_manager', JSONMethodCodec());
  static EMContactManager _instance;

  final List<EMContactEventListener> _contactChangeEventListeners =
      List<EMContactEventListener>();
  List<String> _blackList;

  /// @nodoc
  EMContactManager._internal() {
    _addNativeMethodCallHandler();
  }

  /// @nodoc
  factory EMContactManager.getInstance() {
    return _instance = _instance ?? EMContactManager._internal();
  }

  /// @nodoc
  void _addNativeMethodCallHandler() {
    _emContactManagerChannel.setMethodCallHandler((MethodCall call) {
      Map argMap = call.arguments;
      if (call.method == EMSDKMethod.onContactChanged) {
        return _onContactChanged(argMap);
      }
      return null;
    });
  }

  /// @nodoc
  Future<void> _onContactChanged(Map event) async {
    var type = event['type'];
    String userName = event['userName'];
    String reason = event['reason'];
    for (var listener in _contactChangeEventListeners) {
      switch (type) {
        case EMContactChangeEvent.CONTACT_ADD:
          listener.onContactAdded(userName);
          break;
        case EMContactChangeEvent.CONTACT_DELETE:
          listener.onContactDeleted(userName);
          break;
        case EMContactChangeEvent.INVITED:
          listener.onContactInvited(userName, reason);
          break;
        case EMContactChangeEvent.INVITATION_ACCEPTED:
          listener.onFriendRequestAccepted(userName);
          break;
        case EMContactChangeEvent.INVITATION_DECLINED:
          listener.onFriendRequestDeclined(userName);
          break;
        default:
      }
    }
  }

  /// 添加联系人[userName] with [reason].
  /// 如果添加成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void addContact(String userName, String reason,
      {onSuccess(), onError(int code, String desc)}) {
    Future<Map> result = _emContactManagerChannel.invokeMethod(
        EMSDKMethod.addContact, {"userName": userName, "reason": reason});
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess();
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// 删除联系人 [userName]
  /// [keepConversation] true 保留会话和消息  false 不保留
  /// 如果添加成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void deleteContact(String userName, bool keepConversation,
      {onSuccess(), onError(int code, String desc)}) {
    Future<Map> result = _emContactManagerChannel.invokeMethod(
        EMSDKMethod.deleteContact,
        {"userName": userName, "keepConversation": keepConversation});
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess();
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// 从服务器获取所有的好友
  /// 如果获取成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void getAllContactsFromServer(
      {onSuccess(List<String> contacts), onError(int code, String desc)}) {
    Future<Map<String, dynamic>> result = _emContactManagerChannel
        .invokeMethod(EMSDKMethod.getAllContactsFromServer);
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          var contacts = List<String>();
          if (response['value'] != null) {
            for (var contact in response['value']) {
              contacts.add(contact);
            }
          }
          onSuccess(contacts);
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// 把指定用户加入到黑名单中 [userName] .
  /// 如果[both]设置为true，则双方都无法向对方发送消息。否则，[userName]仍然可以接收消息。
  /// 如果加入成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void addUserToBlackList(String userName, bool both,
      {onSuccess(), onError(int code, String desc)}) {
    Future<Map> result = _emContactManagerChannel.invokeMethod(
        EMSDKMethod.addUserToBlackList, {"userName": userName, "both": both});
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess();
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// 把用户从黑名单中移除 [userName].
  /// 如果移除成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void removeUserFromBlackList(String userName,
      {onSuccess(), onError(int code, String desc)}) {
    Future<Map> result = _emContactManagerChannel.invokeMethod(
        EMSDKMethod.removeUserFromBlackList, {"userName": userName});
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess();
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// 从本地获取黑名单中的用户的ID
  List<String> getBlackListUserNames() {
    return _blackList;
  }

  /// 从服务器获取黑名单中的用户的ID
  /// 如果获取成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void getBlackListFromServer(
      {onSuccess(List<String> blackList), onError(int code, String desc)}) {
    Future<Map<String, dynamic>> result = _emContactManagerChannel
        .invokeMethod(EMSDKMethod.getBlackListFromServer);
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          var blackUsers = List<String>();
          if (response['value'] != null) {
            for (var user in response['value']) {
              blackUsers.add(user);
            }
          }
          _blackList = blackUsers;
          onSuccess(blackUsers);
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// 接受加好友的邀请[userName].
  /// 如果添加成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void acceptInvitation(String userName,
      {onSuccess(), onError(int code, String desc)}) {
    Future<Map> result = _emContactManagerChannel
        .invokeMethod(EMSDKMethod.acceptInvitation, {"userName": userName});
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess();
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// 拒绝加好友的邀请 [userName].
  /// 如果添加成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void declineInvitation(String userName,
      {onSuccess(), onError(int code, String desc)}) {
    Future<Map> result = _emContactManagerChannel
        .invokeMethod(EMSDKMethod.declineInvitation, {"userName": userName});
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess();
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// @nodoc 从服务器获取登录用户在其他设备上登录的ID
  /// @nodoc 如果获取成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void getSelfIdsOnOtherPlatform(
      {onSuccess(List<String> devices), onError(int code, String desc)}) {
    Future<Map<String, dynamic>> result = _emContactManagerChannel
        .invokeMethod(EMSDKMethod.getSelfIdsOnOtherPlatform);
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          var devices = List<String>();
          if (response['value'] != null) {
            for (var device in response['value']) {
              devices.add(device);
            }
          }
          onSuccess(devices);
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// 设置好友监听器 [contactListener]
  void addContactListener(EMContactEventListener contactListener) {
    _contactChangeEventListeners.add(contactListener);
  }

  /// 移除好友监听器  [contactListener]
  void removeContactListener(EMContactEventListener contactListener) {
    _contactChangeEventListeners.remove(contactListener);
  }
}
