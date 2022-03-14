import 'dart:async';

import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class EMContactManager {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _channel = const MethodChannel(
      '$_channelPrefix/em_contact_manager', JSONMethodCodec());

  /// @nodoc
  EMContactManager() {
    _channel.setMethodCallHandler((MethodCall call) async {
      Map? argMap = call.arguments;
      if (call.method == EMSDKMethod.onContactChanged) {
        return _onContactChanged(argMap!);
      }
      return null;
    });
  }

  final List<EMContactEventListener> _contactChangeEventListeners = [];

  /// @nodoc
  Future<void> _onContactChanged(Map event) async {
    var type = event['type'];
    String? username = event['username'];
    String? reason = event['reason'];
    for (var listener in _contactChangeEventListeners) {
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

  /// 添加联系人[username] with [reason].
  Future<String?> addContact(
    String username, [
    String reason = '',
  ]) async {
    Map req = {'username': username, 'reason': reason};
    Map result = await _channel.invokeMethod(EMSDKMethod.addContact, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[EMSDKMethod.addContact];
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 删除联系人 [username]
  /// [keepConversation] true 保留会话和消息  false 不保留, 默认为false
  Future<String?> deleteContact(
    String username, [
    bool keepConversation = false,
  ]) async {
    Map req = {'username': username, 'keepConversation': keepConversation};
    Map result = await _channel.invokeMethod(EMSDKMethod.deleteContact, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[EMSDKMethod.deleteContact];
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 从服务器获取所有的好友
  Future<List<String>> getAllContactsFromServer() async {
    Map result =
        await _channel.invokeMethod(EMSDKMethod.getAllContactsFromServer);
    try {
      EMError.hasErrorFromResult(result);
      List<String> contacts = [];
      result[EMSDKMethod.getAllContactsFromServer]?.forEach((element) {
        // 此处做了一个适配，目前native 返回的都是String, 为了避免以后出现进一步扩展，flutter直接返回contact对象
        contacts.add(element);
      });
      return contacts;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 从本地获取所有的好友
  Future<List<String>> getAllContactsFromDB() async {
    Map result = await _channel.invokeMethod(EMSDKMethod.getAllContactsFromDB);
    try {
      EMError.hasErrorFromResult(result);
      List<String> contacts = [];
      result[EMSDKMethod.getAllContactsFromDB]?.forEach((element) {
        // 此处做了一个适配，目前native 返回的都是String, 为了避免以后出现进一步扩展，flutter直接返回contact对象
        contacts.add(element);
      });

      return contacts;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 把指定用户加入到黑名单中 [username] .
  Future<String?> addUserToBlockList(
    String username,
  ) async {
    Map req = {'username': username};
    Map result =
        await _channel.invokeMethod(EMSDKMethod.addUserToBlockList, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[EMSDKMethod.addUserToBlockList];
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 把用户从黑名单中移除 [username].
  Future<String?> removeUserFromBlockList(String username) async {
    Map req = {'username': username};
    Map result =
        await _channel.invokeMethod(EMSDKMethod.removeUserFromBlockList, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[EMSDKMethod.removeUserFromBlockList];
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 从服务器获取黑名单列表
  Future<List<String>> getBlockListFromServer() async {
    Map result =
        await _channel.invokeMethod(EMSDKMethod.getBlockListFromServer);
    try {
      EMError.hasErrorFromResult(result);
      List<String> blockList = [];
      result[EMSDKMethod.getBlockListFromServer]?.forEach((element) {
        // 此处做了一个适配，目前native 返回的都是String, 为了避免以后出现进一步扩展，flutter直接返回contact对象
        blockList.add(element);
      });
      return blockList;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 从本地数据库中获取黑名单列表
  Future<List<String>> getBlockListFromDB() async {
    Map result = await _channel.invokeMethod(EMSDKMethod.getBlockListFromDB);
    try {
      EMError.hasErrorFromResult(result);
      List<String> blockList = [];
      result[EMSDKMethod.getBlockListFromDB]?.forEach((element) {
        blockList.add(element);
      });
      return blockList;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 接受加好友的邀请[username].
  Future<String?> acceptInvitation(String username) async {
    Map req = {'username': username};
    Map result = await _channel.invokeMethod(EMSDKMethod.acceptInvitation, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[EMSDKMethod.acceptInvitation];
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 拒绝加好友的邀请 [username].
  Future<String?> declineInvitation(String username) async {
    Map req = {'username': username};
    Map result =
        await _channel.invokeMethod(EMSDKMethod.declineInvitation, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[EMSDKMethod.declineInvitation];
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 从服务器获取登录用户在其他设备上登录的ID
  Future<List<String>?> getSelfIdsOnOtherPlatform() async {
    Map result =
        await _channel.invokeMethod(EMSDKMethod.getSelfIdsOnOtherPlatform);
    try {
      EMError.hasErrorFromResult(result);
      List<String>? devices =
          result[EMSDKMethod.getSelfIdsOnOtherPlatform]?.cast<String>();
      return devices;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 设置好友监听器 [contactListener]
  void addContactListener(EMContactEventListener contactListener) {
    _contactChangeEventListeners.add(contactListener);
  }

  /// 移除好友监听器  [contactListener]
  void removeContactListener(EMContactEventListener contactListener) {
    if (_contactChangeEventListeners.contains(contactListener)) {
      _contactChangeEventListeners.remove(contactListener);
    }
  }
}

class EMContactChangeEvent {
  static const String CONTACT_ADD = 'onContactAdded';
  static const String CONTACT_DELETE = 'onContactDeleted';
  static const String INVITED = 'onContactInvited';
  static const String INVITATION_ACCEPTED = 'onFriendRequestAccepted';
  static const String INVITATION_DECLINED = 'onFriendRequestDeclined';
}
