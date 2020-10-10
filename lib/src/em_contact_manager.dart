import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'em_listeners.dart';
import 'em_sdk_method.dart';

class EMContactManager {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emContactManagerChannel = const MethodChannel('$_channelPrefix/em_contact_manager', JSONMethodCodec());


  static EMContactManager _instance;

  final List<EMContactEventListener> _contactChangeEventListeners = List<EMContactEventListener>();
  List<String> _blackList;

  /// 本地缓存的黑名单列表，在从服务器获取黑名单后有值
  List<String> get blackList => _blackList;

  /// @nodoc
  EMContactManager._internal() {
    _emContactManagerChannel.setMethodCallHandler((MethodCall call) {
      Map argMap = call.arguments;
      if (call.method == EMSDKMethod.onContactChanged) {
        return _onContactChanged(argMap);
      }
      return null;
    });
  }

  /// @nodoc
  factory EMContactManager.getInstance() => _instance = _instance ?? EMContactManager._internal();

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
  Future<String> addContact({@required String username, String reason = ''}) async {
    Map req = {'username': username, 'reason': reason};
    Map result = await _emContactManagerChannel.invokeMethod(EMSDKMethod.addContact, req);
    EMError.hasErrorFromResult(result);
    return result[EMSDKMethod.addContact];
  }

  /// 删除联系人 [userName]
  /// [keepConversation] true 保留会话和消息  false 不保留, 默认为false
  Future<String> deleteContact({@required String username, bool keepConversation = false}) async {
    Map req = {'username': username, 'keepConversation': keepConversation};
    Map result = await _emContactManagerChannel.invokeMethod(EMSDKMethod.deleteContact, req);
    EMError.hasErrorFromResult(result);
    return result[EMSDKMethod.deleteContact];
  }

  /// 从服务器获取所有的好友
  Future<List> getAllContactsFromServer() async {
    Map result = await _emContactManagerChannel.invokeMethod(EMSDKMethod.getAllContactsFromServer);
    EMError.hasErrorFromResult(result);
    List contacts = result[EMSDKMethod.getAllContactsFromServer];
    return contacts;
  }

  /// 把指定用户加入到黑名单中 [username] .
  Future<String> addUserToBlackList({@required String username}) async {
    Map req = {'username': username};
    Map result = await _emContactManagerChannel.invokeMethod(EMSDKMethod.addUserToBlackList, req);
    EMError.hasErrorFromResult(result);
    return result[EMSDKMethod.addUserToBlackList];
  }

  /// 把用户从黑名单中移除 [userName].
  Future<String> removeUserFromBlackList({@required String username}) async {
    Map req = {'username': username};
    Map result = await _emContactManagerChannel.invokeMethod(EMSDKMethod.removeUserFromBlackList, req);
    EMError.hasErrorFromResult(result);
    return result[EMSDKMethod.removeUserFromBlackList];
  }

  /// 从服务器获取黑名单中的用户的ID
  Future<List> getBlackListFromServer() async {
    Map result = await _emContactManagerChannel.invokeMethod(EMSDKMethod.getBlackListFromServer);
    EMError.hasErrorFromResult(result);
    List<String> blackList = result[EMSDKMethod.getBlackListFromServer];
    _blackList = blackList;
    return blackList;
  }

  /// 接受加好友的邀请[username].
  Future<String> acceptInvitation({@required String username}) async {
    Map req = {'username': username};
    Map result = await _emContactManagerChannel.invokeMethod(EMSDKMethod.acceptInvitation, req);
    EMError.hasErrorFromResult(result);
    return result[EMSDKMethod.acceptInvitation];
  }

  /// 拒绝加好友的邀请 [username].
  Future<String> declineInvitation({@required String username}) async {
    Map req = {'username': username};
    Map result = await _emContactManagerChannel.invokeMethod(EMSDKMethod.declineInvitation, req);
    EMError.hasErrorFromResult(result);
    return result[EMSDKMethod.declineInvitation];
  }

  /// @nodoc 从服务器获取登录用户在其他设备上登录的ID
  Future<List> getSelfIdsOnOtherPlatform() async {
    Map result = await _emContactManagerChannel.invokeMethod(EMSDKMethod.getSelfIdsOnOtherPlatform);
    EMError.hasErrorFromResult(result);
    List<String> devices = result[EMSDKMethod.getSelfIdsOnOtherPlatform];
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


/// @nodoc
class EMContactChangeEvent {
  static const String CONTACT_ADD = 'onContactAdded';
  static const String CONTACT_DELETE = 'onContactDeleted';
  static const String INVITED = 'onContactInvited';
  static const String INVITATION_ACCEPTED = 'onFriendRequestAccepted';
  static const String INVITATION_DECLINED = 'onFriendRequestDeclined';
}
