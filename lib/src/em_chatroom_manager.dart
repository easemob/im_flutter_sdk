import "dart:async";

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:im_flutter_sdk/src/em_domain_terms.dart';

import 'em_chatroom.dart';
import "em_listeners.dart";
import 'em_sdk_method.dart';

class EMChatRoomManager{
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emChatRoomManagerChannel =
  const MethodChannel('$_channelPrefix/em_chat_room_manager', JSONMethodCodec());

  /// @nodoc
  static EMChatRoomManager _instance;

  /// @nodoc
  final List<EMChatRoomEventListener> _chatRoomEventListeners =  List<EMChatRoomEventListener>();

  /// @nodoc
  factory EMChatRoomManager.getInstance() {
    return _instance = _instance ?? EMChatRoomManager._internal();
  }

  /// @nodoc
  EMChatRoomManager._internal(){
    _addNativeMethodCallHandler();
  }

  /// @nodoc
  void _addNativeMethodCallHandler() {
    _emChatRoomManagerChannel.setMethodCallHandler((MethodCall call) {
      Map argMap = call.arguments;
      if (call.method == EMSDKMethod.chatRoomChange) {
        return _chatRoomChange(argMap);
      }
      return null;
    });
  }

  /// 添加聊天室监听器
  void addChatRoomChangeListener(EMChatRoomEventListener listener) {
    assert(listener != null);
    _chatRoomEventListeners.add(listener);
  }
  /// 移除聊天室监听器
   void removeChatRoomListener(EMChatRoomEventListener listener) {
     _chatRoomEventListeners.remove(listener);
  }

  /// @nodoc
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


  /// 加入聊天室[roomId].
  /// 如果添加成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void joinChatRoom(
    String roomId,
      {onSuccess(),
    onError(int code, String desc)
  }){
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

  /// 退出聊天室[roomId].
  /// 如果退出成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void leaveChatRoom(
    String roomId,
      {onSuccess(),
    onError(int code, String desc)
  }){
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

  /// 翻页从服务器获取聊天室 [pageNum] and [pageSize]
  /// 如果获取成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void fetchPublicChatRoomsFromServer(
    int pageNum,
    int pageSize,
      {onSuccess(EMPageResult<EMChatRoom> res),
    onError(int code, String desc)
  }){
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

  /// @nodoc 从服务器获取聊天室详情 [roomId].
  /// 如果获取成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void fetchChatRoomFromServer(
      String roomId,{
      onSuccess(Map<String,Object> chatRoom),
      onError(int code, String desc)
  }){
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

  /// 获取聊天室 [roomId].
  /// 如果获取成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  Future<EMChatRoom> getChatRoom(String roomId) async{
    Map result = await _emChatRoomManagerChannel.invokeMethod(
        EMSDKMethod.getChatRoom,{"roomId": roomId });
    if (result['success']) {
      return EMChatRoom.from(result['value']);
    } else {
      return null;
    }
  }

  /// 获取当前内存的聊天室 .
  /// 如果获取成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
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

  /// @nodoc 创建聊天室（目前只有环信demo可以使用）[subject].[description].[welcomeMessage].[maxUserCount].[members]
  /// @nodoc 如果创建成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void createChatRoom(
    String subject,
    String description,
    String welcomeMessage,
    int maxUserCount,
    List members,
      {onSuccess(Map emChatRoom),
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

  /// @nodoc 销毁聊天室，需要owner权限 [roomId]
  /// @nodoc 如果销毁成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void destroyChatRoom(
    String roomId,
      {onSuccess(),
    onError(int code, String desc)
  }){
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

  /// @nodoc 修改聊天室标题，需要owner权限[roomId]
  /// @nodoc 如果修改成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void changeChatRoomSubject(
    String roomId,
    String newSubject,
      {onSuccess(Map map),
    onError(int code, String desc)
  }){
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

  /// @nodoc 修改聊天室描述信息，需要owner权限 [roomId] .[newDescription]
  /// @nodoc 如果修改成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void changeChatRoomDescription(
    String roomId,
    String newDescription,
      {onSuccess(Map map),
    onError(int code, String desc)
  }){
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

  /// 获取聊天室成员列表
  /// [roomId] 聊天室ID.[cursor] 游标.[pageSize] 每页数量
  /// 如果获取成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void fetchChatRoomMembers(
    String roomId,
    String cursor,
    int pageSize,
      {onSuccess(EMCursorResult<String> result),
    onError(int code, String desc)}){
    Future<Map> result = _emChatRoomManagerChannel.invokeMethod(
        EMSDKMethod.fetchChatRoomMembers, {"roomId": roomId ,"cursor" : cursor ,"pageSize" : pageSize});
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) {
          List<String> list = [];
          var value = response['value'] as Map<String, dynamic>;
          EMCursorResult emCursorResult = EMCursorResult.from(value);
          emCursorResult.getData().forEach((item) => list.add(item));

          EMCursorResult<String> cursorResult = EMCursorResult.from(Map());
          cursorResult.setData(list);
          cursorResult.setCursor(emCursorResult.getCursor());
          if (onSuccess != null) onSuccess(cursorResult);
        }else{
          onSuccess(null);
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
}

  /// @nodoc 禁止聊天室成员发言，需要聊天室拥有者或者管理员权限
  /// [roomId] 聊天室ID [duration] 禁言的时间，单位是毫秒 [muteMembers] 禁言的用户列表
  /// @nodoc 如果禁言成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void muteChatRoomMembers(
    String roomId,
    List muteMembers,
    String duration,
      {onSuccess(Map map),
    onError(int code, String desc)
  }){
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

  /// @nodoc 取消禁言，需要聊天室拥有者或者管理员权限 [roomId].[muteMembers]
  /// @nodoc 如果取消禁言成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void unMuteChatRoomMembers(
    String roomId,
    List<String> muteMembers,
      {onSuccess(Map map),
    onError(int code, String desc)
  }){
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

  /// @nodoc 转移聊天室的所有权，需要聊天室拥有者权限 [roomId] .[newOwner]
  /// @nodoc 如果转移成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void changeOwner(
    String roomId,
    String newOwner,
      {onSuccess(Map map),
    onError(int code, String desc)
  }){
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

  /// 为聊天室添加管理员，需要拥有者权限 [roomId].[admin]
  /// 如果添加成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void addChatRoomAdmin(
    String roomId,
    String admin,
      {onSuccess(Map map),
    onError(int code, String desc)
  }){
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

  /// 删除聊天室管理员，需要拥有着权限[roomId].[admin]
  /// 如果删除成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void removeChatRoomAdmin(
    String roomId,
    String admin,
      {onSuccess(Map map),
    onError(int code, String desc)
  }){
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

  /// @nodoc 获取聊天室的禁言列表，需要拥有者或者管理员权限 [roomId].[pageNum].[pageSize]
  /// @nodoc 如果获取成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void fetchChatRoomMuteList(
    String roomId,
    int pageNum,
    int pageSize,
      {onSuccess(Map map),
    onError(int code, String desc)
  }){
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

  /// @nodoc 删除聊天室成员，需要拥有者或者管理员权限[roomId].[members].
  /// @nodoc 如果删除成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void removeChatRoomMembers(
    String roomId,
    List members,
      {onSuccess(Map map),
    onError(int code, String desc)
  }){
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

  /// @nodoc 添加成员到黑名单，禁止成员继续加入聊天室，需要拥有者或者管理员权限[roomId].[members].
  /// @nodoc 如果添加成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void blockChatRoomMembers(
    String roomId,
    List members,
      {onSuccess(Map map),
    onError(int code, String desc)
  }){
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

  /// @nodoc 将成员从黑名单种移除，需要拥有者或者管理员权限[roomId].[members].
  /// @nodoc 如果移除成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void unBlockChatRoomMembers(
    String roomId,
    List members,
      {onSuccess(Map map),
    onError(int code, String desc)
  }){
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

  /// @nodoc 获取群组黑名单列表，分页显示，需要拥有者或者管理员权限 [roomId].[pageNum].[pageSize]
  /// @nodoc 如果获取成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void fetchChatRoomBlackList(
    String roomId,
    int pageNum,
    int pageSize,
      {onSuccess(List list),
    onError(int code, String desc)
  }){
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


  /// 更新聊天室公告[roomId].[announcement]
  /// 如果更新成功，回调[onSuccess]，如果出现错误，回调[onError]。
  void updateChatRoomAnnouncement(
    String roomId,
    String announcement,
      {onSuccess(),
    onError(int code, String desc)
  }){
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

  /// 从服务器获取聊天室公告内容[roomId]
  /// 如果获取成功，回调[onSuccess]，如果出现错误，回调[onError]。
  void fetchChatRoomAnnouncement(
    String roomId,
      {onSuccess(String res),
    onError(int code, String desc)
  }){
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
