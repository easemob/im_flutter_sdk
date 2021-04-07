import 'dart:async';

import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'em_listeners.dart';
import 'em_sdk_method.dart';
import 'models/em_domain_terms.dart';

class EMContactManager {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _channel = const MethodChannel('$_channelPrefix/em_contact_manager', JSONMethodCodec());

  /// @nodoc
  EMContactManager() {
    _channel.setMethodCallHandler((MethodCall call) {
      Map argMap = call.arguments;
      if (call.method == EMSDKMethod.onContactChanged) {
        return _onContactChanged(argMap);
      }
      return null;
    });
  }

  final List<EMContactEventListener> _contactChangeEventListeners = List<EMContactEventListener>();
  List<String> _blackList;

  /// 本地缓存的黑名单列表，在从服务器获取黑名单后有值
  List<String> get blackList => _blackList;

  /// @nodoc
  Future<void> _onContactChanged(Map event) async {
    var type = event['type'];
    String username = event['username'];
    String reason = event['reason'];
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
  Future<String> addContact(
    String username, [
    String reason = '',
  ]) async {
    Map req = {'username': username, 'reason': reason};
    Map result = await _channel.invokeMethod(EMSDKMethod.addContact, req);
    EMError.hasErrorFromResult(result);
    return result[EMSDKMethod.addContact];
  }

  /// 删除联系人 [username]
  /// [keepConversation] true 保留会话和消息  false 不保留, 默认为false
  Future<String> deleteContact(
    String username, [
    bool keepConversation = false,
  ]) async {
    Map req = {'username': username, 'keepConversation': keepConversation};
    Map result = await _channel.invokeMethod(EMSDKMethod.deleteContact, req);
    EMError.hasErrorFromResult(result);
    return result[EMSDKMethod.deleteContact];
  }

  /// 从服务器获取所有的好友
  Future<List<EMContact>> getAllContactsFromServer() async {
    Map result = await _channel.invokeMethod(EMSDKMethod.getAllContactsFromServer);
    EMError.hasErrorFromResult(result);
    List<EMContact> contacts = List();
    result[EMSDKMethod.getAllContactsFromServer]?.forEach((element) {
      // 此处做了一个适配，目前native 返回的都是String, 为了避免以后出现进一步扩展，flutter直接返回contact对象
      contacts.add(EMContact.fromJson({'eid': element}));
    });

    return contacts;
  }

  /// 从本地获取所有的好友 `only ios now.`
  Future<List<EMContact>> getAllContactsFromDB() async {
    Map result = await _channel.invokeMethod(EMSDKMethod.getAllContactsFromDB);
    EMError.hasErrorFromResult(result);
    List<EMContact> contacts = List();
    result[EMSDKMethod.getAllContactsFromDB]?.forEach((element) {
      // 此处做了一个适配，目前native 返回的都是String, 为了避免以后出现进一步扩展，flutter直接返回contact对象
      contacts.add(EMContact.fromJson({'eid': element}));
    });

    return contacts;
  }

  /// 把指定用户加入到黑名单中 [username] .
  Future<String> addUserToBlackList(String username) async {
    Map req = {'username': username};
    Map result = await _channel.invokeMethod(EMSDKMethod.addUserToBlackList, req);
    EMError.hasErrorFromResult(result);
    return result[EMSDKMethod.addUserToBlackList];
  }

  /// 把用户从黑名单中移除 [username].
  Future<String> removeUserFromBlackList(String username) async {
    Map req = {'username': username};
    Map result = await _channel.invokeMethod(EMSDKMethod.removeUserFromBlackList, req);
    EMError.hasErrorFromResult(result);
    return result[EMSDKMethod.removeUserFromBlackList];
  }

  /// 从服务器获取黑名单中的用户的ID
  Future<List<EMContact>> getBlackListFromServer() async {
    Map result = await _channel.invokeMethod(EMSDKMethod.getBlackListFromServer);
    EMError.hasErrorFromResult(result);
    List<EMContact> blackList = List();
    result[EMSDKMethod.getAllContactsFromServer]?.forEach((element) {
      // 此处做了一个适配，目前native 返回的都是String, 为了避免以后出现进一步扩展，flutter直接返回contact对象
      blackList.add(EMContact.fromJson({'eid': element}));
    });
    return blackList;
  }

  /// 接受加好友的邀请[username].
  Future<String> acceptInvitation(String username) async {
    Map req = {'username': username};
    Map result = await _channel.invokeMethod(EMSDKMethod.acceptInvitation, req);
    EMError.hasErrorFromResult(result);
    return result[EMSDKMethod.acceptInvitation];
  }

  /// 拒绝加好友的邀请 [username].
  Future<String> declineInvitation(String username) async {
    Map req = {'username': username};
    Map result = await _channel.invokeMethod(EMSDKMethod.declineInvitation, req);
    EMError.hasErrorFromResult(result);
    return result[EMSDKMethod.declineInvitation];
  }

  /// 从服务器获取登录用户在其他设备上登录的ID
  Future<List<String>> getSelfIdsOnOtherPlatform() async {
    Map result = await _channel.invokeMethod(EMSDKMethod.getSelfIdsOnOtherPlatform);
    EMError.hasErrorFromResult(result);
    List<String> devices = result[EMSDKMethod.getSelfIdsOnOtherPlatform]?.cast<String>();
    return devices;
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

class EMContactChangeEvent {
  static const String CONTACT_ADD = 'onContactAdded';
  static const String CONTACT_DELETE = 'onContactDeleted';
  static const String INVITED = 'onContactInvited';
  static const String INVITATION_ACCEPTED = 'onFriendRequestAccepted';
  static const String INVITATION_DECLINED = 'onFriendRequestDeclined';
}
