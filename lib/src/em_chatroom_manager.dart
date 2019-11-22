import "dart:async";

import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/src/em_domain_terms.dart';
import 'package:meta/meta.dart';

import 'em_chatroom.dart';
import "em_listeners.dart";
import 'em_sdk_method.dart';

class EMChatRoomManager{
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emChatRoomManagerChannel =
  const MethodChannel('$_channelPrefix/em_chat_room_manager', JSONMethodCodec());

  static EMChatRoomManager _instance;

  final List<EMChatRoomEventListener> _chatRoomEventListeners =  List<EMChatRoomEventListener>();

  factory EMChatRoomManager.getInstance() {
    return _instance = _instance ?? EMChatRoomManager._internal();
  }

  EMChatRoomManager._internal(){
    _addNativeMethodCallHandler();
  }

  void _addNativeMethodCallHandler() {
    _emChatRoomManagerChannel.setMethodCallHandler((MethodCall call) {
      Map argMap = call.arguments;
      if (call.method == EMSDKMethod.chatRoomChange) {
        return _chatRoomChange(argMap);
      }
      return null;
    });
  }

  /// addChatRoomChangeListener
  void addChatRoomChangeListener(EMChatRoomEventListener listener) {
    assert(listener != null);
    _chatRoomEventListeners.add(listener);
  }
  /// removeChatRoomListener
   void removeChatRoomListener(EMChatRoomEventListener listener) {
     _chatRoomEventListeners.remove(listener);
  }


  Future<void> _chatRoomChange(Map event) async{
    String type = event['chatRoomChange'];
    for (var listener in _chatRoomEventListeners) {
      switch(type){
        case EMChatRoomEvent.ON_CHAT_ROOM_DESTROYED:
          String roomId = event['roomId'];
          String roomName = event['roomName'];
          listener.onChatRoomDestroyed(roomId,roomName);
          break;
        case EMChatRoomEvent.ON_MEMBER_JOINED:
          String roomId = event['roomId'];
          String participant = event['participant'];
          listener.onMemberJoined(roomId,participant);
          break;
        case EMChatRoomEvent.ON_MEMBER_EXITED:
          String roomId = event['roomId'];
          String roomName = event['roomName'];
          String participant = event['participant'];
          listener.onMemberExited(roomId,roomName,participant);
          break;
        case EMChatRoomEvent.ON_REMOVED_FROM_CHAT_ROOM:
          int    reason = event['reason'];
          String roomId = event['roomId'];
          String roomName = event['roomName'];
          String participant = event['participant'];
          listener.onRemovedFromChatRoom(reason,roomId,roomName,participant);
          break;
        case EMChatRoomEvent.ON_MUTE_LIST_ADDED:
          String roomId = event['roomId'];
          List mutes = event['mutes'];
          String expireTime = event['expireTime'];
          listener.onMuteListAdded(roomId,mutes,expireTime);
          break;
        case EMChatRoomEvent.ON_MUTE_LIST_REMOVED:
          String roomId = event['roomId'];
          List mutes = event['mutes'];
          listener.onMuteListRemoved(roomId,mutes);
          break;
        case EMChatRoomEvent.ON_ADMIN_ADDED:
          String roomId = event['roomId'];
          String admin = event['admin'];
          listener.onAdminAdded(roomId,admin);
          break;
        case EMChatRoomEvent.ON_ADMIN_REMOVED:
          String roomId = event['roomId'];
          String admin = event['admin'];
          listener.onAdminRemoved(roomId,admin);
          break;
        case EMChatRoomEvent.ON_OWNER_CHANGED:
          String roomId = event['roomId'];
          String newOwner = event['newOwner'];
          String oldOwner = event['oldOwner'];
          listener.onOwnerChanged(roomId,newOwner,oldOwner);
          break;
        case EMChatRoomEvent.ON_ANNOUNCEMENT_CHANGED:
          String roomId = event['roomId'];
          String announcement = event['announcement'];
          listener.onAnnouncementChanged(roomId,announcement);
          break;
      }
    }
  }


  /// joinChatRoom - add contact of [roomId].
  /// Call [onSuccess] if contact added successfully, [onError] once error occured.
  void joinChatRoom({
    @required String roomId,
    onSuccess(),
    onError(int code, String desc)}){
    Future<Map> result = _emChatRoomManagerChannel.invokeMethod(
        EMSDKMethod.joinChatRoom, {"roomId": roomId });
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess();
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// leaveChatRoom - add contact of [roomId].
  /// Call [onSuccess] if contact added successfully, [onError] once error occured.
  void leaveChatRoom({
    @required String roomId,
    onSuccess(),
    onError(int code, String desc)}){
    Future<Map> result = _emChatRoomManagerChannel.invokeMethod(
        EMSDKMethod.leaveChatRoom, {"roomId": roomId });
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess();
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// fetchPublicChatRoomsFromServer - add contact of [pageNum] and [pageSize]
  /// Call [onSuccess] if contact added successfully, [onError] once error occured.
  void fetchPublicChatRoomsFromServer({
    @required int pageNum,
    @required int pageSize,
      onSuccess(EMPageResult<EMChatRoom> res),
      onError(int code, String desc)}){
      Future<Map> result = _emChatRoomManagerChannel.invokeMethod(
        EMSDKMethod.fetchPublicChatRoomsFromServer, {"pageNum": pageNum ,"pageSize": pageSize });
      result.then((response) {
        if (response["success"]) {
          if (onSuccess != null) {
              var data = List<EMChatRoom>();
              EMPageResult emPageResult = EMPageResult.from(response['value']);
              emPageResult.getData().forEach((page) => data.add(EMChatRoom.from(page)));

              EMPageResult<EMChatRoom> pageResult = EMPageResult.from(Map());
              pageResult.setPageCount(emPageResult.getPageCount());
              pageResult.setData(data);
              onSuccess(pageResult);
          }
        } else {
          if (onError != null) onError(response['code'], response['desc']);
        }
      });
  }

  /// @nodoc fetchChatRoomFromServer - add contact of [roomId].
  /// Call [onSuccess] if contact added successfully, [onError] once error occured.
  void fetchChatRoomFromServer({
    @required String roomId,
    onSuccess(Map<String,Object> chatRoom),
    onError(int code, String desc)}){
    Future<Map> result = _emChatRoomManagerChannel.invokeMethod(
        EMSDKMethod.fetchChatRoomFromServer, {"roomId": roomId });
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess(response['value']);
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// @nodoc getChatRoom - add contact of [roomId].
  /// Call [onSuccess] if contact added successfully, [onError] once error occured.
  Future<EMChatRoom> getChatRoom(String roomId) async{
    Map result = await _emChatRoomManagerChannel.invokeMethod(
        EMSDKMethod.getChatRoom,{"roomId": roomId });
    if (result['success']) {
      return EMChatRoom.from(result['value']);
    } else {
      return null;
    }
  }

  /// @nodoc getAllChatRooms .
  /// Call [onSuccess] if contact added successfully, [onError] once error occured.
  Future<List> getAllChatRooms() async {
    Map result = await _emChatRoomManagerChannel
        .invokeMethod(EMSDKMethod.getAllChatRooms);
    if (result['success']) {
      List list = result['value'];
      List res = new List();
      list.forEach((data)=>
          res.add(EMChatRoom.from(data))
      );
      return res;
    } else {
      return null;
    }
  }

  /// @nodoc createChatRoom - add contact of [subject].[description].[welcomeMessage].[maxUserCount].[members]
  /// @nodoc Call [onSuccess] if contact added successfully, [onError] once error occured.
  void createChatRoom({
    @required String subject,
    @required String description,
    @required String welcomeMessage,
    @required int maxUserCount,
    @required List members,
    onSuccess(Map emChatRoom),
    onError(int code, String desc)}){
    Future<Map> result = _emChatRoomManagerChannel.invokeMethod(
        EMSDKMethod.createChatRoom, {"subject": subject ,"description": description ,"welcomeMessage": welcomeMessage
        ,"maxUserCount": maxUserCount ,"members" : members});
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess(response['value']);
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// @nodoc destroyChatRoom - add contact of [roomId]
  /// @nodoc Call [onSuccess] if contact added successfully, [onError] once error occured.
  void destroyChatRoom({
    @required String roomId,
    onSuccess(),
    onError(int code, String desc)}){
    Future<Map> result = _emChatRoomManagerChannel.invokeMethod(
        EMSDKMethod.destroyChatRoom, {"roomId": roomId });
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess();
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// @nodoc changeChatRoomSubject - add contact of [roomId]
  /// @nodoc Call [onSuccess] if contact added successfully, [onError] once error occured.
  void changeChatRoomSubject({
    @required String roomId,
    @required String newSubject,
    onSuccess(Map map),
    onError(int code, String desc)}){
    Future<Map> result = _emChatRoomManagerChannel.invokeMethod(
        EMSDKMethod.changeChatRoomSubject, {"roomId": roomId ,"newSubject":newSubject});
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess(response['value']);
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// @nodoc changeChatRoomDescription - add contact of [roomId] .[newDescription]
  /// @nodoc Call [onSuccess] if contact added successfully, [onError] once error occured.
  void changeChatRoomDescription({
    @required String roomId,
    @required String newDescription,
    onSuccess(Map map),
    onError(int code, String desc)}){
    Future<Map> result = _emChatRoomManagerChannel.invokeMethod(
        EMSDKMethod.changeChatRoomDescription, {"roomId": roomId ,"newDescription" : newDescription });
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess(response['value']);
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// @nodoc fetchChatRoomMembers - add contact of [roomId].[cursor].[pageSize]
  /// @nodoc Call [onSuccess] if contact added successfully, [onError] once error occured.
  void fetchChatRoomMembers({
    @required String roomId,
    @required String cursor,
    int pageSize,
    onSuccess(Map map),
    onError(int code, String desc)}){
    Future<Map> result = _emChatRoomManagerChannel.invokeMethod(
        EMSDKMethod.fetchChatRoomMembers, {"roomId": roomId ,"cursor" : cursor ,"pageSize" : pageSize});
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess(response['value']);
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
}

  /// @nodoc muteChatRoomMembers - add contact of [roomId].[duration].[muteMembers]
  /// @nodoc Call [onSuccess] if contact added successfully, [onError] once error occured.
  void muteChatRoomMembers({
    @required String roomId,
    List muteMembers,
    @required String duration,
    onSuccess(Map map),
    onError(int code, String desc)}){
    Future<Map> result = _emChatRoomManagerChannel.invokeMethod(
        EMSDKMethod.muteChatRoomMembers, {"roomId": roomId  ,"muteMembers" : muteMembers ,"duration" : duration});
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess(response['value']);
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// @nodoc unMuteChatRoomMembers - add contact of [roomId].[muteMembers]
  /// @nodoc Call [onSuccess] if contact added successfully, [onError] once error occured.
  void unMuteChatRoomMembers({
    @required String roomId,
    List<String> muteMembers,
    onSuccess(Map map),
    onError(int code, String desc)}){
    Future<Map> result = _emChatRoomManagerChannel.invokeMethod(
        EMSDKMethod.unMuteChatRoomMembers, {"roomId": roomId ,"muteMembers" : muteMembers});
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess(response['value']);
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// @nodoc changeOwner - add contact of [roomId] .[newOwner]
  /// @nodoc Call [onSuccess] if contact added successfully, [onError] once error occured.
  void changeOwner({
    @required String roomId,
    @required String newOwner,
    onSuccess(Map map),
    onError(int code, String desc)}){
    Future<Map> result = _emChatRoomManagerChannel.invokeMethod(
        EMSDKMethod.changeChatRoomOwner, {"roomId": roomId ,"newOwner" : newOwner});
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess(response['value']);
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// @nodoc addChatRoomAdmin - add contact of [roomId].[admin]
  /// @nodoc Call [onSuccess] if contact added successfully, [onError] once error occured.
  void addChatRoomAdmin({
    @required String roomId,
    @required String admin,
    onSuccess(Map map),
    onError(int code, String desc)}){
    Future<Map> result = _emChatRoomManagerChannel.invokeMethod(
        EMSDKMethod.addChatRoomAdmin, {"roomId": roomId ,"admin" : admin});
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess(response['value']);
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// @nodoc removeChatRoomAdmin - add contact of [roomId].[admin]
  /// @nodoc Call [onSuccess] if contact added successfully, [onError] once error occured.
  void removeChatRoomAdmin({
    @required String roomId,
    @required String admin,
    onSuccess(Map map),
    onError(int code, String desc)}){
    Future<Map> result = _emChatRoomManagerChannel.invokeMethod(
        EMSDKMethod.removeChatRoomAdmin, {"roomId": roomId ,"admin" : admin});
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess(response['value']);
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// @nodoc fetchChatRoomMuteList - add contact of [roomId].[pageNum].[pageSize]
  /// @nodoc Call [onSuccess] if contact added successfully, [onError] once error occured.
  void fetchChatRoomMuteList({
    @required String roomId,
    int pageNum,
    int pageSize,
    onSuccess(Map map),
    onError(int code, String desc)}){
    Future<Map> result = _emChatRoomManagerChannel.invokeMethod(
        EMSDKMethod.fetchChatRoomMuteList, {"roomId": roomId ,"pageNum" : pageNum ,"pageSize": pageSize});
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess(response['value']);
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// @nodoc removeChatRoomMembers - add contact of [roomId].[members].
  /// @nodoc Call [onSuccess] if contact added successfully, [onError] once error occured.
  void removeChatRoomMembers({
    @required String roomId,
    List members,
    onSuccess(Map map),
    onError(int code, String desc)}){
    Future<Map> result = _emChatRoomManagerChannel.invokeMethod(
        EMSDKMethod.removeChatRoomMembers, {"roomId": roomId ,"members" : members });
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess(response['value']);
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// @nodoc blockChatRoomMembers - add contact of [roomId].[members].
  /// @nodoc Call [onSuccess] if contact added successfully, [onError] once error occured.
  void blockChatRoomMembers({
    @required String roomId,
    List members,
    onSuccess(Map map),
    onError(int code, String desc)}){
    Future<Map> result = _emChatRoomManagerChannel.invokeMethod(
        EMSDKMethod.blockChatRoomMembers, {"roomId": roomId ,"members" : members });
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess(response['value']);
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// @nodoc unBlockChatRoomMembers - add contact of [roomId].[members].
  /// @nodoc Call [onSuccess] if contact added successfully, [onError] once error occured.
  void unBlockChatRoomMembers({
    @required String roomId,
    List members,
    onSuccess(Map map),
    onError(int code, String desc)}){
    Future<Map> result = _emChatRoomManagerChannel.invokeMethod(
        EMSDKMethod.unBlockChatRoomMembers, {"roomId": roomId ,"members" : members });
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess(response['value']);
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// @nodoc fetchChatRoomBlackList - add contact of [roomId].[pageNum].[pageSize]
  /// @nodoc Call [onSuccess] if contact added successfully, [onError] once error occured.
  void fetchChatRoomBlackList({
    @required String roomId,
    int pageNum,
    int pageSize,
    onSuccess(List list),
    onError(int code, String desc)}){
    Future<Map> result = _emChatRoomManagerChannel.invokeMethod(
        EMSDKMethod.fetchChatRoomBlackList, {"roomId": roomId ,"pageNum" : pageNum ,"pageSize": pageSize});
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess(response['value']);
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }


  /// @nodoc updateChatRoomAnnouncement - add contact of [roomId].[announcement]
  /// @nodoc Call [onSuccess] if contact added successfully, [onError] once error occured.
  void updateChatRoomAnnouncement({
    @required String roomId,
    @required String announcement,
    onSuccess(),
    onError(int code, String desc)}){
    Future<Map> result = _emChatRoomManagerChannel.invokeMethod(
        EMSDKMethod.updateChatRoomAnnouncement, {"roomId": roomId ,"announcement": announcement});
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess();
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// @nodoc fetchChatRoomAnnouncement - add contact of [roomId]
  /// @nodoc Call [onSuccess] if contact added successfully, [onError] once error occured.
  void fetchChatRoomAnnouncement({
    @required String roomId,
    onSuccess(String res),
    onError(int code, String desc)}){
    Future<Map> result = _emChatRoomManagerChannel.invokeMethod(
        EMSDKMethod.fetchChatRoomAnnouncement, {"roomId": roomId });
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess(response['value']);
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  EMChatRoomManager chatRoomManager(){
      return _instance;
  }
}
