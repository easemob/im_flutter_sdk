import "dart:async";

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import "em_listeners.dart";
import 'em_log.dart';
import 'em_sdk_method.dart';

class EMContactManager {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emContactManagerChannel =
      const MethodChannel('$_channelPrefix/em_contact_manager');
  static EMContactManager _instance;

  final EMLog log;
  final List<EMContactEventListener> _contactChangeEventListeners =
      List<EMContactEventListener>();
  List<String> _blackList;

  EMContactManager._internal(EMLog log) : log = log {
    _addNativeMethodCallHandler();
  }

  factory EMContactManager.getInstance({@required EMLog log}) {
    return _instance = _instance ?? EMContactManager._internal(log);
  }

  void _addNativeMethodCallHandler() {
    _emContactManagerChannel.setMethodCallHandler((MethodCall call) {
      Map argMap = call.arguments;
      if (call.method == EMSDKMethod.onContactChanged) {
        return _onContactChanged(argMap);
      }
      return null;
    });
  }

  Future<void> _onContactChanged(Map event) async {
    var type = event['type'] as EMContactChangeEvent;
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

  /// addContact - add contact of [userName] with [reason].
  /// Call [onSuccess] if contact added successfully, [onError] once error occured.
  void addContact(
      {@required String userName,
      @required String reason,
      onSuccess(),
      onError(int code, String desc)}) {
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

  /// deleteContact - delete contact [userName] while keep the conversation existing if [keepConversation] set to true.
  /// Call [onSuccess] if contact added successfully, [onError] once error occured.
  void deleteContact(
      {@required String userName,
      bool keepConversation = false,
      onSuccess(),
      onError(int code, String desc)}) {
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

  /// getAllContactsFromServer - get contact list.
  /// If anything wrong, [onError] is called with error [code] and [desc] as args.
  Future<List<String>> getAllContactsFromServer(
      {onError(int code, String desc)}) async {
    Map<String, dynamic> result = await _emContactManagerChannel
        .invokeMethod(EMSDKMethod.getAllContactsFromServer);
    if (result['success']) {
      return result['contacts'];
    } else {
      if (onError != null) onError(result['code'], result['desc']);
      return null;
    }
  }

  /// addUserToBlackList - Adds user [userName] into black list.
  /// If [both] set to true, both sides couldn't send message to counterpart. Otherwise, [userName] still can receive messages.
  /// Call [onError] if error occured, with [code] and [desc] as the specific error information.
  void addUserToBlackList(
      {@required String userName,
      bool both = false,
      onSuccess(),
      onError(int code, String desc)}) {
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

  /// removeUserFromBlackList - Removes [userName] from black list.
  /// Call [onSuccess] if contact added successfully, [onError] once error occured.
  void removeUserFromBlackList(
      {@required String userName,
      onSuccess(),
      onError(int code, String desc)}) {
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

  /// getBlackListUserNames - Returns local stored black-listed user names.
  List<String> getBlackListUserNames() {
    return _blackList;
  }

  /// getBlackListFromServer - Gets black list from server and stores locally for next call to [getBlackListUserNames].
  /// Call [onSuccess] if contact added successfully, [onError] once error occured.
  Future<List<String>> getBlackListFromServer(
      {onSuccess(), onError(int code, String desc)}) async {
    Map<String, dynamic> result = await _emContactManagerChannel
        .invokeMethod(EMSDKMethod.getBlackListFromServer);
    if (result['success']) {
      _blackList = result['black_list'];
      return result['black_list'];
    } else {
      if (onError != null) onError(result['code'], result['desc']);
      return null;
    }
  }

  /// saveBlackList - Tells server to save black-listed contact in [blackList].
  /// Call [onSuccess] if contact added successfully, [onError] once error occured.
  void saveBlackList(
      {@required List<String> blackList,
      onSuccess(),
      onError(int code, String desc)}) {
    Future<Map> result = _emContactManagerChannel
        .invokeMethod(EMSDKMethod.saveBlackList, {"blackList": blackList});
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess();
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// acceptInvitation - Accepts invitation from [userName].
  /// Call [onSuccess] if contact added successfully, [onError] once error occured.
  void acceptInvitation(
      {@required String userName,
      onSuccess(),
      onError(int code, String desc)}) {
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

  /// declineInvitation - Declines invitation from [userName].
  /// Call [onSuccess] if contact added successfully, [onError] once error occured.
  void declineInvitation(
      {@required String userName,
      onSuccess(),
      onError(int code, String desc)}) {
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

  /// getSelfIdsOnOtherPlatform - Gets self ids on other platform.
  /// Call [onError] if error occured, with [code], [desc] set with detail error information.
  Future<List<String>> getSelfIdsOnOtherPlatform(
      {onError(int code, String desc)}) async {
    Map<String, dynamic> result = await _emContactManagerChannel
        .invokeMethod(EMSDKMethod.getSelfIdsOnOtherPlatform);
    if (result['success']) {
      return result['ids'];
    } else {
      if (onError != null) onError(result['code'], result['desc']);
      return null;
    }
  }

  /// setContactListner - Sets listener [contactListner] to be aware of contact modification events.
  void setContactListener(EMContactEventListener contactListener) {
    _contactChangeEventListeners.add(contactListener);
  }

  /// removeContactListner - Removes listener [contactListner] from listner list.
  void removeContactListener(EMContactEventListener contactListener) {
    _contactChangeEventListeners.remove(contactListener);
  }
}
