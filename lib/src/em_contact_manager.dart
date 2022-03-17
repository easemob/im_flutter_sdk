import 'dart:async';

import 'package:flutter/services.dart';

import '../im_flutter_sdk.dart';
import 'chat_method_keys.dart';

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
    Map result = await _channel.invokeMethod(ChatMethodKeys.addContact, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.addContact];
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
    Map result = await _channel.invokeMethod(ChatMethodKeys.deleteContact, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.deleteContact];
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 从服务器获取所有的好友
  Future<List<String>> getAllContactsFromServer() async {
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.getAllContactsFromServer);
    try {
      EMError.hasErrorFromResult(result);
      List<String> contacts = [];
      result[ChatMethodKeys.getAllContactsFromServer]?.forEach((element) {
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
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.getAllContactsFromDB);
    try {
      EMError.hasErrorFromResult(result);
      List<String> contacts = [];
      result[ChatMethodKeys.getAllContactsFromDB]?.forEach((element) {
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
        await _channel.invokeMethod(ChatMethodKeys.addUserToBlockList, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.addUserToBlockList];
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 把用户从黑名单中移除 [username].
  Future<String?> removeUserFromBlockList(String username) async {
    Map req = {'username': username};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.removeUserFromBlockList, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.removeUserFromBlockList];
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 从服务器获取黑名单列表
  Future<List<String>> getBlockListFromServer() async {
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.getBlockListFromServer);
    try {
      EMError.hasErrorFromResult(result);
      List<String> blockList = [];
      result[ChatMethodKeys.getBlockListFromServer]?.forEach((element) {
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
    Map result = await _channel.invokeMethod(ChatMethodKeys.getBlockListFromDB);
    try {
      EMError.hasErrorFromResult(result);
      List<String> blockList = [];
      result[ChatMethodKeys.getBlockListFromDB]?.forEach((element) {
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
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.acceptInvitation, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.acceptInvitation];
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 拒绝加好友的邀请 [username].
  Future<String?> declineInvitation(String username) async {
    Map req = {'username': username};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.declineInvitation, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.declineInvitation];
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 从服务器获取登录用户在其他设备上登录的ID
  Future<List<String>?> getSelfIdsOnOtherPlatform() async {
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.getSelfIdsOnOtherPlatform);
    try {
      EMError.hasErrorFromResult(result);
      List<String>? devices =
          result[ChatMethodKeys.getSelfIdsOnOtherPlatform]?.cast<String>();
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
