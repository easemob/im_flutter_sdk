import "dart:async";

import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/src/models/em_domain_terms.dart';
import "em_listeners.dart";

class EMChatRoomManager {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _channel = const MethodChannel(
      '$_channelPrefix/em_chat_room_manager', JSONMethodCodec());

  EMChatRoomManager() {
    _channel.setMethodCallHandler((MethodCall call) async {
      Map? argMap = call.arguments;
      if (call.method == EMSDKMethod.chatRoomChange) {
        return _chatRoomChange(argMap!);
      }
      return null;
    });
  }

  final List<EMChatRoomEventListener> _chatRoomEventListeners = [];

  /// 添加聊天室监听器
  void addChatRoomChangeListener(EMChatRoomEventListener listener) {
    _chatRoomEventListeners.add(listener);
  }

  /// 移除聊天室监听器
  void removeChatRoomListener(EMChatRoomEventListener listener) {
    if (_chatRoomEventListeners.contains(listener)) {
      _chatRoomEventListeners.remove(listener);
    }
  }

  /// @nodoc
  Future<void> _chatRoomChange(Map event) async {
    String? type = event['type'];
    for (EMChatRoomEventListener listener in _chatRoomEventListeners) {
      switch (type) {
        case EMChatRoomEvent.ON_CHAT_ROOM_DESTROYED:
          String roomId = event['roomId'];
          String? roomName = event['roomName'];
          listener.onChatRoomDestroyed(roomId, roomName);
          break;
        case EMChatRoomEvent.ON_MEMBER_JOINED:
          String roomId = event['roomId'];
          String participant = event['participant'];
          listener.onMemberJoinedFromChatRoom(roomId, participant);
          break;
        case EMChatRoomEvent.ON_MEMBER_EXITED:
          String roomId = event['roomId'];
          String? roomName = event['roomName'];
          String participant = event['participant'];
          listener.onMemberExitedFromChatRoom(roomId, roomName, participant);
          break;
        case EMChatRoomEvent.ON_REMOVED_FROM_CHAT_ROOM:
          String roomId = event['roomId'];
          String? roomName = event['roomName'];
          String participant = event['participant'];
          listener.onRemovedFromChatRoom(roomId, roomName, participant);
          break;
        case EMChatRoomEvent.ON_MUTE_LIST_ADDED:
          String roomId = event['roomId'];
          List<String> mutes = event['mutes'];
          String? expireTime = event['expireTime'];
          listener.onMuteListAddedFromChatRoom(roomId, mutes, expireTime);
          break;
        case EMChatRoomEvent.ON_MUTE_LIST_REMOVED:
          String roomId = event['roomId'];
          List<String> mutes = event['mutes'];
          listener.onMuteListRemovedFromChatRoom(roomId, mutes);
          break;
        case EMChatRoomEvent.ON_ADMIN_ADDED:
          String roomId = event['roomId'];
          String admin = event['admin'];
          listener.onAdminAddedFromChatRoom(roomId, admin);
          break;
        case EMChatRoomEvent.ON_ADMIN_REMOVED:
          String roomId = event['roomId'];
          String admin = event['admin'];
          listener.onAdminRemovedFromChatRoom(roomId, admin);
          break;
        case EMChatRoomEvent.ON_OWNER_CHANGED:
          String roomId = event['roomId'];
          String newOwner = event['newOwner'];
          String oldOwner = event['oldOwner'];
          listener.onOwnerChangedFromChatRoom(roomId, newOwner, oldOwner);
          break;
        case EMChatRoomEvent.ON_ANNOUNCEMENT_CHANGED:
          String roomId = event['roomId'];
          String announcement = event['announcement'];
          listener.onAnnouncementChangedFromChatRoom(roomId, announcement);
          break;
        case EMChatRoomEvent.ON_WHITE_LIST_ADDED:
          String roomId = event['roomId'];
          List<String> members = event["whitelist"];
          listener.onWhiteListAddedFromChatRoom(roomId, members);
          break;
        case EMChatRoomEvent.ON_WHITE_LIST_REMOVED:
          String roomId = event['roomId'];
          List<String> members = event["whitelist"];
          listener.onWhiteListRemovedFromChatRoom(roomId, members);
          break;
        case EMChatRoomEvent.ON_ALL_MEMBER_MUTE_STATE_CHANGED:
          String roomId = event['roomId'];
          bool isAllMuted = event['isMuted'];
          listener.onAllChatRoomMemberMuteStateChanged(roomId, isAllMuted);
          break;
      }
    }
  }

  /// 加入聊天室[roomId].
  Future<void> joinChatRoom(String roomId) async {
    Map result = await _channel
        .invokeMethod(EMSDKMethod.joinChatRoom, {"roomId": roomId});
    EMError.hasErrorFromResult(result);
  }

  /// 离开聊天室[roomId].
  Future<void> leaveChatRoom(String roomId) async {
    Map result = await _channel
        .invokeMethod(EMSDKMethod.leaveChatRoom, {"roomId": roomId});
    EMError.hasErrorFromResult(result);
  }

  /// 翻页从服务器获取聊天室 [pageNum] and [pageSize]
  Future<EMPageResult<EMChatRoom>> fetchPublicChatRoomsFromServer({
    int pageNum = 1,
    int pageSize = 200,
  }) async {
    Map result = await _channel.invokeMethod(
        EMSDKMethod.fetchPublicChatRoomsFromServer,
        {"pageNum": pageNum, "pageSize": pageSize});
    EMError.hasErrorFromResult(result);
    return EMPageResult<EMChatRoom>.fromJson(
        result[EMSDKMethod.fetchPublicChatRoomsFromServer],
        dataItemCallback: (map) {
      return EMChatRoom.fromJson(map);
    });
  }

  /// 获取聊天室详情[roomId].
  Future<EMChatRoom> fetchChatRoomInfoFromServer(String roomId) async {
    Map result = await _channel.invokeMethod(
        EMSDKMethod.fetchChatRoomInfoFromServer, {"roomId": roomId});
    EMError.hasErrorFromResult(result);
    return EMChatRoom.fromJson(result[EMSDKMethod.fetchChatRoomInfoFromServer]);
  }

  /// 从本地获取聊天室 [roomId].
  Future<EMChatRoom> getChatRoomWithId(String roomId) async {
    Map result = await _channel
        .invokeMethod(EMSDKMethod.getChatRoom, {"roomId": roomId});
    EMError.hasErrorFromResult(result);
    return EMChatRoom.fromJson(result[EMSDKMethod.fetchChatRoomInfoFromServer]);
  }

  /// 获取所有聊天室
  Future<List<EMChatRoom>> getAllChatRooms() async {
    Map result = await _channel.invokeMethod(EMSDKMethod.getAllChatRooms);
    EMError.hasErrorFromResult(result);
    List<EMChatRoom> list = [];
    result[EMSDKMethod.getAllChatRooms]
        ?.forEach((element) => list.add(EMChatRoom.fromJson(element)));
    return list;
  }

  Future<EMChatRoom> createChatRoom(
    String subject, {
    String? desc,
    String? welcomeMsg,
    int maxUserCount = 300,
    List<String>? members,
  }) async {
    Map req = Map();
    req['subject'] = subject;
    req['desc'] = desc;
    req['welcomeMsg'] = welcomeMsg;
    req['maxUserCount'] = maxUserCount;
    req['members'] = members;
    Map result = await _channel.invokeMethod(EMSDKMethod.createChatRoom, req);
    EMError.hasErrorFromResult(result);
    return EMChatRoom.fromJson(result[EMSDKMethod.createChatRoom]);
  }

  /// @nodoc 销毁聊天室，需要owner权限 [roomId]
  Future<void> destroyChatRoom(
    String roomId,
  ) async {
    Map req = {"roomId": roomId};
    Map result = await _channel.invokeMethod(EMSDKMethod.destroyChatRoom, req);
    EMError.hasErrorFromResult(result);
  }

  /// @nodoc 修改聊天室标题，需要owner权限[roomId] [subject]
  Future<void> changeChatRoomSubject(
    String roomId,
    String subject,
  ) async {
    Map req = {"roomId": roomId, "subject": subject};
    Map result =
        await _channel.invokeMethod(EMSDKMethod.changeChatRoomSubject, req);
    EMError.hasErrorFromResult(result);
  }

  /// @nodoc 修改聊天室描述信息，需要owner权限 [roomId] .[description]
  Future<void> changeChatRoomDescription(
    String roomId,
    String description,
  ) async {
    Map req = {"roomId": roomId, "description": description};
    Map result =
        await _channel.invokeMethod(EMSDKMethod.changeChatRoomDescription, req);
    EMError.hasErrorFromResult(result);
  }

  /// @nodoc 获取聊天室成员列表，[roomId] [cursor] [pageSize]
  Future<EMCursorResult<String?>> fetchChatRoomMembers(
    String roomId, {
    String cursor = '',
    int pageSize = 200,
  }) async {
    Map req = {"roomId": roomId, "cursor": cursor, "pageSize": pageSize};
    Map result =
        await _channel.invokeMethod(EMSDKMethod.fetchChatRoomMembers, req);
    EMError.hasErrorFromResult(result);
    return EMCursorResult<String?>.fromJson(
        result[EMSDKMethod.fetchChatRoomMembers],
        dataItemCallback: (obj) => obj);
  }

  /// @nodoc 禁止聊天室成员发言，需要聊天室拥有者或者管理员权限
  /// [roomId] 聊天室ID [duration] 禁言的时间，单位是毫秒 [muteMembers] 禁言的用户列表
  Future<void> muteChatRoomMembers(
    String roomId,
    List muteMembers, {
    int duration = -1,
  }) async {
    Map req = {
      "roomId": roomId,
      "muteMembers": muteMembers,
      "duration": duration
    };
    Map result =
        await _channel.invokeMethod(EMSDKMethod.muteChatRoomMembers, req);
    EMError.hasErrorFromResult(result);
  }

  /// @nodoc 取消禁言，需要聊天室拥有者或者管理员权限 [roomId].[muteMembers]
  Future<void> unMuteChatRoomMembers(
    String roomId,
    List unMuteMembers,
  ) async {
    Map req = {"roomId": roomId, "unMuteMembers": unMuteMembers};
    Map result =
        await _channel.invokeMethod(EMSDKMethod.unMuteChatRoomMembers, req);
    EMError.hasErrorFromResult(result);
  }

  /// @nodoc 转移聊天室的所有权，需要聊天室拥有者权限 [roomId] .[newOwner]
  /// @nodoc 如果转移成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  Future<void> changeOwner(
    String roomId,
    String newOwner,
  ) async {
    Map req = {"roomId": roomId, "newOwner": newOwner};
    Map result =
        await _channel.invokeMethod(EMSDKMethod.changeChatRoomOwner, req);
    EMError.hasErrorFromResult(result);
  }

  /// 为聊天室添加管理员，需要拥有者权限 [roomId].[admin]
  /// 如果添加成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  Future<void> addChatRoomAdmin(
    String roomId,
    String admin,
  ) async {
    Map req = {"roomId": roomId, "admin": admin};
    Map result = await _channel.invokeMethod(EMSDKMethod.addChatRoomAdmin, req);
    EMError.hasErrorFromResult(result);
  }

  /// 删除聊天室管理员，需要拥有着权限[roomId].[admin]
  /// 如果删除成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  Future<void> removeChatRoomAdmin(
    String roomId,
    String admin,
  ) async {
    Map req = {"roomId": roomId, "admin": admin};
    Map result =
        await _channel.invokeMethod(EMSDKMethod.removeChatRoomAdmin, req);
    EMError.hasErrorFromResult(result);
  }

  /// @nodoc 获取聊天室的禁言列表，需要拥有者或者管理员权限 [roomId].[pageNum].[pageSize]
  Future<List<String>?> fetchChatRoomMuteList(
    String roomId, {
    int pageNum = 1,
    int pageSize = 200,
  }) async {
    Map req = {"roomId": roomId, "pageNum": pageNum, "pageSize": pageSize};
    Map result =
        await _channel.invokeMethod(EMSDKMethod.fetchChatRoomMuteList, req);
    EMError.hasErrorFromResult(result);
    return result[EMSDKMethod.fetchChatRoomMuteList]?.cast<String>();
  }

  /// @nodoc 删除聊天室成员，需要拥有者或者管理员权限[roomId].[members].
  Future<void> removeChatRoomMembers(
    String roomId,
    List members,
  ) async {
    Map req = {"roomId": roomId, "members": members};
    Map result =
        await _channel.invokeMethod(EMSDKMethod.removeChatRoomMembers, req);
    EMError.hasErrorFromResult(result);
  }

  /// @nodoc 添加成员到黑名单，禁止成员继续加入聊天室，需要拥有者或者管理员权限[roomId].[members].
  Future<void> blockChatRoomMembers(
    String roomId,
    List members,
  ) async {
    Map req = {"roomId": roomId, "members": members};
    Map result =
        await _channel.invokeMethod(EMSDKMethod.blockChatRoomMembers, req);
    EMError.hasErrorFromResult(result);
  }

  /// @nodoc 将成员从黑名单种移除，需要拥有者或者管理员权限[roomId].[members].
  Future<void> unBlockChatRoomMembers(
    String roomId,
    List members,
  ) async {
    Map req = {"roomId": roomId, "members": members};
    Map result =
        await _channel.invokeMethod(EMSDKMethod.unBlockChatRoomMembers, req);
    EMError.hasErrorFromResult(result);
  }

  /// @nodoc 获取群组黑名单列表，分页显示，需要拥有者或者管理员权限 [roomId].[pageNum].[pageSize]
  Future<List<String>?> fetchChatRoomBlockList(
    String roomId, [
    int pageNum = 1,
    int pageSize = 200,
  ]) async {
    Map req = {"roomId": roomId, "pageNum": pageNum, "pageSize": pageSize};
    Map result =
        await _channel.invokeMethod(EMSDKMethod.fetchChatRoomBlockList, req);
    EMError.hasErrorFromResult(result);
    return result[EMSDKMethod.fetchChatRoomBlockList]?.cast<String>();
  }

  /// 更新聊天室公告[roomId].[announcement]
  Future<void> updateChatRoomAnnouncement(
    String roomId,
    String announcement,
  ) async {
    Map req = {"roomId": roomId, "announcement": announcement};
    Map result = await _channel.invokeMethod(
        EMSDKMethod.updateChatRoomAnnouncement, req);
    EMError.hasErrorFromResult(result);
  }

  /// 从服务器获取聊天室公告内容[roomId]
  Future<String?> fetchChatRoomAnnouncement(
    String roomId,
  ) async {
    Map req = {"roomId": roomId};
    Map result =
        await _channel.invokeMethod(EMSDKMethod.fetchChatRoomAnnouncement, req);
    EMError.hasErrorFromResult(result);
    return result[EMSDKMethod.fetchChatRoomAnnouncement];
  }

  /// 从服务器获取聊天室白名单列表 [roomId]: 聊天室id
  Future<List<String?>> fetchChatRoomWhiteListFromServer(String roomId) async {
    Map req = {"roomId": roomId};
    Map result = await _channel.invokeMethod(
        EMSDKMethod.fetchChatRoomWhiteListFromServer, req);
    EMError.hasErrorFromResult(result);
    List<String?> contacts = [];
    result[EMSDKMethod.fetchChatRoomWhiteListFromServer]?.forEach((element) {
      contacts.add(element);
    });
    return contacts;
  }

  /// 判断当前登录账号是否在聊天室白名单中 [roomId]: 聊天室id
  Future<bool> isMemberInChatRoomWhiteList(String roomId) async {
    Map req = {"roomId": roomId};
    Map result = await _channel.invokeMethod(
        EMSDKMethod.isMemberInChatRoomWhiteListFromServer, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.isMemberInChatRoomWhiteListFromServer);
  }

  /// 向聊天室白名单中添加用户[roomId]: 聊天室id, [members]: 需要添加到聊天室的用户id。
  Future<void> addMembersToChatRoomWhiteList(
      String roomId, List<String> members) async {
    Map req = {
      "roomId": roomId,
      "members": members,
    };
    Map result = await _channel.invokeMethod(
      EMSDKMethod.addMembersToChatRoomWhiteList,
      req,
    );

    EMError.hasErrorFromResult(result);
  }

  /// 从聊天室中移除白名单成员,[roomId]: 聊天室id, [members]: 需要移除的用户列表。
  Future<void> removeMembersFromChatRoomWhiteList(
    String roomId,
    List<String> members,
  ) async {
    Map req = {
      "roomId": roomId,
      "members": members,
    };
    Map result = await _channel.invokeMethod(
      EMSDKMethod.addMembersToChatRoomWhiteList,
      req,
    );
    EMError.hasErrorFromResult(result);
  }

  Future<bool> muteAllChatRoomMembers(String roomId) async {
    Map req = {"roomId": roomId};
    Map result = await _channel.invokeMethod(
      EMSDKMethod.muteAllChatRoomMembers,
      req,
    );
    EMError.hasErrorFromResult(result);
    return result.boolValue(
      EMSDKMethod.muteAllChatRoomMembers,
    );
  }

  Future<bool> unMuteAllChatRoomMembers(String roomId) async {
    Map req = {"roomId": roomId};
    Map result = await _channel.invokeMethod(
      EMSDKMethod.unMuteAllChatRoomMembers,
      req,
    );
    EMError.hasErrorFromResult(result);
    return result.boolValue(
      EMSDKMethod.unMuteAllChatRoomMembers,
    );
  }
}
