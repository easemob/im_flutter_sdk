import "dart:async";

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import "em_listeners.dart";
import 'em_log.dart';
import 'em_sdk_method.dart';

class EMContactManager {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emContactManagerChannel =
      const MethodChannel('$_channelPrefix/em_contact_manager', JSONMethodCodec());
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
        {"userName": userName, "keepConversation" : keepConversation});
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
  void getAllContactsFromServer({
      onSuccess(List<String> contacts),
      onError(int code, String desc)}){
    Future<Map<String, dynamic>> result = _emContactManagerChannel
        .invokeMethod(EMSDKMethod.getAllContactsFromServer);
    result.then((response){
      if (response['success']) {
        if(onSuccess != null) {
          var contacts = List<String>();
          if (response['value'] != null) {
            for (var contact in response['value']) {
              contacts.add(contact);
              print('好友列表---$contacts');
            }
          }
          onSuccess(contacts);
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });

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
  void getBlackListFromServer(
      {onSuccess(List<String> blackList), onError(int code, String desc)}) {
    Future<Map<String, dynamic>> result = _emContactManagerChannel
        .invokeMethod(EMSDKMethod.getBlackListFromServer);
    result.then((response){
      if (response['success']) {
        if(onSuccess != null){
        var blackUsers = List<String>();
        if(response['value'] != null){
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
  void getSelfIdsOnOtherPlatform(
      {onSuccess(List<String> devices),
        onError(int code, String desc)}){
    Future<Map<String, dynamic>> result = _emContactManagerChannel
        .invokeMethod(EMSDKMethod.getSelfIdsOnOtherPlatform);
    result.then((response){
      if (response['success']) {
        if(onSuccess != null){
          var devices = List<String>();
          if(response['value'] != null){
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

  /// setContactListener - Sets listener [contactListener] to be aware of contact modification events.
  void addContactListener(EMContactEventListener contactListener) {
    _contactChangeEventListeners.add(contactListener);
  }

  /// removeContactListener - Removes listener [contactListener] from listener list.
  void removeContactListener(EMContactEventListener contactListener) {
    _contactChangeEventListeners.remove(contactListener);
  }
}
