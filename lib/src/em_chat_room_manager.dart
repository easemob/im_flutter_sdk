// ignore_for_file: deprecated_member_use_from_same_package

import "dart:async";

import 'package:flutter/services.dart';
import 'internal/inner_headers.dart';

///
///  聊天室管理类，负责聊天室加入和退出、聊天室列表获取以及成员权限管理等。
///  比如，加入聊天室：
///   ```dart
///     try {
///         await EMClient.getInstance.chatRoomManager.joinChatRoom(chatRoomId);
///     } on EMError catch (e) {
///         debugPrint(e.toString());
///     }
///   ```
class EMChatRoomManager {
  static const _channelPrefix = 'com.chat.im';
  static const MethodChannel _channel = const MethodChannel(
      '$_channelPrefix/chat_room_manager', JSONMethodCodec());

  /// @nodoc
  EMChatRoomManager() {
    _channel.setMethodCallHandler((MethodCall call) async {
      Map? argMap = call.arguments;
      if (call.method == ChatMethodKeys.chatRoomChange) {
        return _chatRoomChange(argMap!);
      }
      return null;
    });
  }

  final Map<String, EMChatRoomEventHandler> _eventHandlesMap = {};

  final List<EMChatRoomManagerListener> _listeners = [];

  Future<void> _chatRoomChange(Map event) async {
    String? type = event['type'];

    for (var item in _eventHandlesMap.values) {
      switch (type) {
        case EMChatRoomEvent.ON_CHAT_ROOM_DESTROYED:
          String roomId = event['roomId'];
          String? roomName = event['roomName'];
          item.onChatRoomDestroyed?.call(roomId, roomName);
          break;
        case EMChatRoomEvent.ON_MEMBER_JOINED:
          String roomId = event['roomId'];
          String participant = event['participant'];
          item.onMemberJoinedFromChatRoom?.call(roomId, participant);
          break;
        case EMChatRoomEvent.ON_MEMBER_EXITED:
          String roomId = event['roomId'];
          String? roomName = event['roomName'];
          String participant = event['participant'];
          item.onMemberExitedFromChatRoom?.call(roomId, roomName, participant);
          break;
        case EMChatRoomEvent.ON_REMOVED_FROM_CHAT_ROOM:
          String roomId = event['roomId'];
          String? roomName = event['roomName'];
          String participant = event['participant'];
          item.onRemovedFromChatRoom?.call(roomId, roomName, participant);
          break;
        case EMChatRoomEvent.ON_MUTE_LIST_ADDED:
          String roomId = event['roomId'];
          List<String> mutes = List.from(event['mutes']);
          String? expireTime = event['expireTime'];
          item.onMuteListAddedFromChatRoom?.call(roomId, mutes, expireTime);
          break;
        case EMChatRoomEvent.ON_MUTE_LIST_REMOVED:
          String roomId = event['roomId'];
          List<String> mutes = List.from(event['mutes']);
          item.onMuteListRemovedFromChatRoom?.call(roomId, mutes);
          break;
        case EMChatRoomEvent.ON_ADMIN_ADDED:
          String roomId = event['roomId'];
          String admin = event['admin'];
          item.onAdminAddedFromChatRoom?.call(roomId, admin);
          break;
        case EMChatRoomEvent.ON_ADMIN_REMOVED:
          String roomId = event['roomId'];
          String admin = event['admin'];
          item.onAdminRemovedFromChatRoom?.call(roomId, admin);
          break;
        case EMChatRoomEvent.ON_OWNER_CHANGED:
          String roomId = event['roomId'];
          String newOwner = event['newOwner'];
          String oldOwner = event['oldOwner'];
          item.onOwnerChangedFromChatRoom?.call(roomId, newOwner, oldOwner);
          break;
        case EMChatRoomEvent.ON_ANNOUNCEMENT_CHANGED:
          String roomId = event['roomId'];
          String announcement = event['announcement'];
          item.onAnnouncementChangedFromChatRoom?.call(roomId, announcement);
          break;
        case EMChatRoomEvent.ON_WHITE_LIST_ADDED:
          String roomId = event['roomId'];
          List<String> members = List.from(event["whitelist"]);
          item.onAllowListAddedFromChatRoom?.call(roomId, members);
          break;
        case EMChatRoomEvent.ON_WHITE_LIST_REMOVED:
          String roomId = event['roomId'];
          List<String> members = List.from(event["whitelist"]);
          item.onAllowListRemovedFromChatRoom?.call(roomId, members);
          break;
        case EMChatRoomEvent.ON_ALL_MEMBER_MUTE_STATE_CHANGED:
          String roomId = event['roomId'];
          bool isAllMuted = event['isMuted'];
          item.onAllChatRoomMemberMuteStateChanged?.call(roomId, isAllMuted);
          break;
        case EMChatRoomEvent.ON_SPECIFICATION_CHANGED:
          EMChatRoom room = EMChatRoom.fromJson(event["room"]);
          item.onSpecificationChanged?.call(room);
          break;
        case EMChatRoomEvent.ON_ATTRIBUTES_UPDATED:
          String roomId = event['roomId'];
          Map<String, String> attributes =
              event["attributes"].cast<String, String>();
          String fromId = event["fromId"];
          item.onAttributesUpdated?.call(
            roomId,
            attributes,
            fromId,
          );
          break;
        case EMChatRoomEvent.ON_ATTRIBUTES_REMOVED:
          String roomId = event['roomId'];
          List<String> keys = event["keys"].cast<String>();
          String fromId = event["fromId"];
          item.onAttributesRemoved?.call(
            roomId,
            keys,
            fromId,
          );
          break;
      }
    }
    // deprecated (3.9.5)
    for (var listener in _listeners) {
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
          List<String> mutes = List.from(event['mutes']);
          String? expireTime = event['expireTime'];
          listener.onMuteListAddedFromChatRoom(roomId, mutes, expireTime);
          break;
        case EMChatRoomEvent.ON_MUTE_LIST_REMOVED:
          String roomId = event['roomId'];
          List<String> mutes = List.from(event['mutes']);
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
          List<String> members = List.from(event["whitelist"]);
          listener.onAllowListAddedFromChatRoom(roomId, members);
          break;
        case EMChatRoomEvent.ON_WHITE_LIST_REMOVED:
          String roomId = event['roomId'];
          List<String> members = List.from(event["whitelist"]);
          listener.onAllowListRemovedFromChatRoom(roomId, members);
          break;
        case EMChatRoomEvent.ON_ALL_MEMBER_MUTE_STATE_CHANGED:
          String roomId = event['roomId'];
          bool isAllMuted = event['isMuted'];
          listener.onAllChatRoomMemberMuteStateChanged(roomId, isAllMuted);
          break;
      }
    }
  }

  ///
  /// 添加 [EMChatRoomEventHandler] 。
  ///
  /// Param [identifier] handler对应的id，可用于删除 handler。
  ///
  /// Param [handler] 添加的 [EMChatRoomEventHandler]。
  ///
  void addEventHandler(
    String identifier,
    EMChatRoomEventHandler handler,
  ) {
    _eventHandlesMap[identifier] = handler;
  }

  ///
  /// 移除 [EMChatRoomEventHandler] 。
  ///
  /// Param [identifier] 需要移除 handler 对应的 id。
  ///
  void removeEventHandler(String identifier) {
    _eventHandlesMap.remove(identifier);
  }

  ///
  /// 获取 [EMChatRoomEventHandler] 。
  ///
  /// Param [identifier] 要获取 handler 对应的 id。
  ///
  /// **Return** 返回 id 对应的 handler 。
  ///
  EMChatRoomEventHandler? getEventHandler(String identifier) {
    return _eventHandlesMap[identifier];
  }

  ///
  /// 清除所有的 [EMChatRoomEventHandler] 。
  ///
  void clearEventHandlers() {
    _eventHandlesMap.clear();
  }

  ///
  /// 加入聊天室。
  ///
  /// 退出聊天室调用 [leaveChatRoom]。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<void> joinChatRoom(String roomId) async {
    Map result = await _channel
        .invokeMethod(ChatMethodKeys.joinChatRoom, {"roomId": roomId});
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 离开聊天室。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<void> leaveChatRoom(String roomId) async {
    Map result = await _channel
        .invokeMethod(ChatMethodKeys.leaveChatRoom, {"roomId": roomId});
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 以分页的方式从服务器获取聊天室数据。
  ///
  /// Param [pageNum] 当前页码，从 1 开始。
  ///
  /// Param [pageSize] 每页返回的记录数。
  ///
  /// **Return** 分页获取结果，详见 [EMPageResult]。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<EMPageResult<EMChatRoom>> fetchPublicChatRoomsFromServer({
    int pageNum = 1,
    int pageSize = 200,
  }) async {
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.fetchPublicChatRoomsFromServer,
        {"pageNum": pageNum, "pageSize": pageSize});
    try {
      EMError.hasErrorFromResult(result);
      return EMPageResult<EMChatRoom>.fromJson(
          result[ChatMethodKeys.fetchPublicChatRoomsFromServer],
          dataItemCallback: (map) {
        return EMChatRoom.fromJson(map);
      });
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 从服务器获取聊天室详情，默认不取成员列表。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// **Return** 返回聊天室对象。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<EMChatRoom> fetchChatRoomInfoFromServer(
    String roomId, {
    bool fetchMembers = false,
  }) async {
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.fetchChatRoomInfoFromServer,
        {"roomId": roomId, "fetchMembers": fetchMembers});
    try {
      EMError.hasErrorFromResult(result);
      return EMChatRoom.fromJson(
          result[ChatMethodKeys.fetchChatRoomInfoFromServer]);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 从内存中获取聊天室。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// **Return** 返回聊天室对象。如果内存中不存在聊天室对象，返回 null。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<EMChatRoom?> getChatRoomWithId(String roomId) async {
    Map result = await _channel
        .invokeMethod(ChatMethodKeys.getChatRoom, {"roomId": roomId});
    try {
      EMError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.getChatRoom)) {
        return EMChatRoom.fromJson(result[ChatMethodKeys.getChatRoom]);
      } else {
        return null;
      }
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 创建聊天室。
  ///
  /// Param [name] 聊天室名称。
  ///
  /// Param [desc] 聊天室描述。
  ///
  /// Param [welcomeMsg] 邀请成员加入聊天室的消息。
  ///
  /// Param [maxUserCount] 允许加入聊天室的最大成员数。
  ///
  /// Param [members] 邀请加入聊天室的成员列表。
  ///
  /// **Return** 创建成功的聊天室对象。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<EMChatRoom> createChatRoom(
    String name, {
    String? desc,
    String? welcomeMsg,
    int maxUserCount = 300,
    List<String>? members,
  }) async {
    Map req = Map();
    req['subject'] = name;
    req['maxUserCount'] = maxUserCount;
    req.setValueWithOutNull("desc", desc);
    req.setValueWithOutNull("welcomeMsg", welcomeMsg);
    req.setValueWithOutNull("members", members);
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.createChatRoom, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMChatRoom.fromJson(result[ChatMethodKeys.createChatRoom]);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 销毁聊天室。
  ///
  /// 仅聊天室所有者可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<void> destroyChatRoom(
    String roomId,
  ) async {
    Map req = {"roomId": roomId};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.destroyChatRoom, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 修改聊天室标题。
  ///
  /// 仅聊天室所有者可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [name] 新的聊天室名称。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<void> changeChatRoomName(
    String roomId,
    String name,
  ) async {
    Map req = {"roomId": roomId, "subject": name};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.changeChatRoomSubject, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 修改聊天室描述信息。
  ///
  /// 仅聊天室所有者可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [description] 聊天室描述信息。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<void> changeChatRoomDescription(
    String roomId,
    String description,
  ) async {
    Map req = {"roomId": roomId, "description": description};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.changeChatRoomDescription, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 获取聊天室成员列表。
  ///
  /// 返回的结果中，当 [EMCursorResult.cursor] 为空字符串 ("") 时，表示没有更多数据。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [cursor] 从这个游标位置开始取数据。
  ///
  /// Param [pageSize] 每页返回的成员数。
  ///
  /// **Return** 分页获取结果 [EMCursorResult]。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<EMCursorResult<String>> fetchChatRoomMembers(
    String roomId, {
    String? cursor,
    int pageSize = 200,
  }) async {
    Map req = {"roomId": roomId, "pageSize": pageSize};
    req.setValueWithOutNull("cursor", cursor);
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.fetchChatRoomMembers, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMCursorResult<String>.fromJson(
          result[ChatMethodKeys.fetchChatRoomMembers],
          dataItemCallback: (obj) => obj);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 禁止聊天室成员发言。
  ///
  /// 仅聊天室所有者和管理员可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [muteMembers] 禁言的用户列表。
  ///
  /// Param [duration] 禁言时长，单位是毫秒。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<void> muteChatRoomMembers(
    String roomId,
    List<String> muteMembers, {
    int duration = -1,
  }) async {
    Map req = {
      "roomId": roomId,
      "muteMembers": muteMembers,
      "duration": duration
    };
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.muteChatRoomMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 解除禁言。
  ///
  /// 仅聊天室所有者和管理员可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [unMuteMembers] 解除禁言的用户列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<void> unMuteChatRoomMembers(
    String roomId,
    List<String> unMuteMembers,
  ) async {
    Map req = {"roomId": roomId, "unMuteMembers": unMuteMembers};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.unMuteChatRoomMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 转移聊天室的所有权。
  ///
  /// 仅聊天室所有者可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [newOwner] 新的聊天室所有者 ID。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<void> changeOwner(
    String roomId,
    String newOwner,
  ) async {
    Map req = {"roomId": roomId, "newOwner": newOwner};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.changeChatRoomOwner, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 添加聊天室管理员。
  ///
  /// 仅聊天室所有者可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [admin] 要设置的管理员 ID。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<void> addChatRoomAdmin(
    String roomId,
    String admin,
  ) async {
    Map req = {"roomId": roomId, "admin": admin};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.addChatRoomAdmin, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 移除聊天室管理员权限。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [admin] 要移除管理员权限的 ID。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<void> removeChatRoomAdmin(
    String roomId,
    String admin,
  ) async {
    Map req = {"roomId": roomId, "admin": admin};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.removeChatRoomAdmin, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 获取聊天室禁言列表。
  ///
  /// 仅聊天室所有者和管理员可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [pageNum] 当前页码，从 1 开始。
  ///
  /// Param [pageSize] 每页返回的禁言成员数。
  ///
  /// **Return** 返回的包含禁言成员 ID 列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<List<String>> fetchChatRoomMuteList(
    String roomId, {
    int pageNum = 1,
    int pageSize = 200,
  }) async {
    Map req = {"roomId": roomId, "pageNum": pageNum, "pageSize": pageSize};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.fetchChatRoomMuteList, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.fetchChatRoomMuteList]?.cast<String>() ?? [];
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 将成员移出聊天室。
  ///
  /// 仅聊天室所有者和管理员可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [members] 要移出聊天室的用户列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<void> removeChatRoomMembers(
    String roomId,
    List<String> members,
  ) async {
    Map req = {"roomId": roomId, "members": members};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.removeChatRoomMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 将成员添加到聊天室黑名单。
  ///
  /// 仅聊天室所有者和管理员可调用此方法。
  ///
  /// 对于添加到聊天室黑名单的成员，请注意以下几点：
  /// 1. 成员添加到黑名单的同时，将被服务器移出聊天室。
  /// 2. 可通过 [EMChatRoomEventHandler.onRemovedFromChatRoom] 回调通知。
  /// 3. 添加到黑名单的成员禁止再次加入到聊天室。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [members] 要加入黑名单的成员列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<void> blockChatRoomMembers(
    String roomId,
    List members,
  ) async {
    Map req = {"roomId": roomId, "members": members};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.blockChatRoomMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 从聊天室黑名单中移除成员。
  ///
  /// 仅聊天室所有者和管理员可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [members] 要移除黑名单的成员列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<void> unBlockChatRoomMembers(
    String roomId,
    List members,
  ) async {
    Map req = {"roomId": roomId, "members": members};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.unBlockChatRoomMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 以分页的形式获取聊天室黑名单列表。
  ///
  /// 仅聊天室所有者和管理员可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [pageNum] 当前页码，从 1 开始。
  ///
  /// Param [pageSize] 每页返回的黑名单中的用户数。
  ///
  /// **Return** 返回聊天室黑名单列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<List<String>> fetchChatRoomBlockList(
    String roomId, {
    int pageNum = 1,
    int pageSize = 200,
  }) async {
    Map req = {"roomId": roomId, "pageNum": pageNum, "pageSize": pageSize};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.fetchChatRoomBlockList, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.fetchChatRoomBlockList]?.cast<String>() ??
          [];
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 更新聊天室公告。
  ///
  /// 仅聊天室所有者和管理员可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [announcement] 公告内容。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<void> updateChatRoomAnnouncement(
    String roomId,
    String announcement,
  ) async {
    Map req = {"roomId": roomId, "announcement": announcement};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.updateChatRoomAnnouncement, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 从服务器获取聊天室公告内容。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// **Return** 聊天室公告。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<String?> fetchChatRoomAnnouncement(
    String roomId,
  ) async {
    Map req = {"roomId": roomId};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.fetchChatRoomAnnouncement, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.fetchChatRoomAnnouncement];
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 从服务器获取白名单列表。
  ///
  /// 仅聊天室所有者和管理员可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// **Return** 聊天室白名单列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<List<String>> fetchChatRoomAllowListFromServer(String roomId) async {
    Map req = {"roomId": roomId};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.fetchChatRoomWhiteListFromServer, req);

    try {
      EMError.hasErrorFromResult(result);
      List<String> list = [];
      result[ChatMethodKeys.fetchChatRoomWhiteListFromServer]
          ?.forEach((element) {
        if (element is String) {
          list.add(element);
        }
      });
      return list;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 检查成员自己是否加入了白名单。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// **Return** 返回是否在白名单中：
  /// - `true`: 是；
  /// - `false`: 否。
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<bool> isMemberInChatRoomAllowList(String roomId) async {
    Map req = {"roomId": roomId};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.isMemberInChatRoomWhiteListFromServer, req);

    try {
      EMError.hasErrorFromResult(result);
      return result
          .boolValue(ChatMethodKeys.isMemberInChatRoomWhiteListFromServer);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 将成员添加到白名单。
  ///
  /// 仅聊天室所有者和管理员可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [members] 要加入白名单的成员列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<void> addMembersToChatRoomAllowList(
    String roomId,
    List<String> members,
  ) async {
    Map req = {
      "roomId": roomId,
      "members": members,
    };
    Map result = await _channel.invokeMethod(
      ChatMethodKeys.addMembersToChatRoomWhiteList,
      req,
    );

    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 将成员从白名单移除。
  ///
  /// 仅聊天室所有者和管理员可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [members] 移除白名单的用户列表。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<void> removeMembersFromChatRoomAllowList(
    String roomId,
    List<String> members,
  ) async {
    Map req = {
      "roomId": roomId,
      "members": members,
    };
    Map result = await _channel.invokeMethod(
      ChatMethodKeys.removeMembersFromChatRoomWhiteList,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 设置全员禁言。
  ///
  /// 仅聊天室所有者和管理员可调用此方法。
  ///
  /// 聊天室所有者、管理员及加入白名单的用户不受影响。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<void> muteAllChatRoomMembers(String roomId) async {
    Map req = {"roomId": roomId};
    Map result = await _channel.invokeMethod(
      ChatMethodKeys.muteAllChatRoomMembers,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 解除所有成员的禁言状态。
  ///
  /// 仅聊天室所有者和管理员可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// **Throws**  如果有异常会在这里抛出，包含错误码和错误描述，详见 [EMError]。
  ///
  Future<void> unMuteAllChatRoomMembers(String roomId) async {
    Map req = {"roomId": roomId};
    Map result = await _channel.invokeMethod(
      ChatMethodKeys.unMuteAllChatRoomMembers,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// Gets the list of custom chat room attributes based on the attribute key list.
  /// Param [roomId] The chat room ID.
  /// Param [keys] The key list of attributes to get. If you set it as `null` or leave it empty, this method retrieves all custom attributes.
  /// **Return** The chat room attributes in key-value pairs.
  /// **Throws** A description of the exception. See [EMError].
  Future<Map<String, String>?> fetchChatRoomAttributes(
    String roomId,
    List<String>? keys,
  ) async {
    Map req = {
      "roomId": roomId,
      "keys": keys,
    };

    Map result = await _channel.invokeMethod(
      ChatMethodKeys.fetchChatRoomAttributes,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.fetchChatRoomAttributes]
          ?.cast<String, String>();
    } on EMError catch (e) {
      throw e;
    }
  }

  /// Sets custom chat room attributes.
  /// Param [roomId] The chat room ID.
  /// Param [attributes] The chat room attributes to add. The attributes are in key-value format.
  /// Note:
  /// In a key-value pair, the key is the attribute name that can contain 128 characters at most; the value is the attribute value that cannot exceed 4096 characters.
  /// A chat room can have a maximum of 100 custom attributes and the total length of custom chat room attributes cannot exceed 10 GB for each app. Attribute keys support the following character sets:
  /// * - 26 lowercase English letters (a-z)
  /// * - 26 uppercase English letters (A-Z)
  /// * - 10 numbers (0-9)
  /// * - "_", "-", "."
  ///
  /// Param [deleteWhenLeft] Whether to delete the chat room attributes set by the member when he or she exits the chat room.
  /// Param [overwrite] Whether to overwrite the attributes with same key set by others.
  /// **Return** `failureKeys map` is returned in key-value format, where the key is the attribute key and the value is the reason for the failure.
  /// **Throws** A description of the exception. See [EMError].
  Future<Map<String, int>?> addAttributes(
    String roomId, {
    required Map<String, String> attributes,
    bool deleteWhenLeft = false,
    bool overwrite = false,
  }) async {
    Map req = {
      "roomId": roomId,
      "attributes": attributes,
      "autoDelete": deleteWhenLeft,
      "forced": overwrite,
    };

    Map result = await _channel.invokeMethod(
      ChatMethodKeys.setChatRoomAttributes,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.setChatRoomAttributes]?.cast<String, int>();
    } on EMError catch (e) {
      throw e;
    }
  }

  /// Removes custom chat room attributes.
  /// Param [roomId] The chat room ID.
  /// Param [keys] The keys of the custom chat room attributes to remove.
  /// Param [force] Whether to remove the attributes with same key set by others.
  /// **Return** `failureKeys map` is returned in key-value format, where the key is the attribute key and the value is the reason for the failure.
  /// **Throws** A description of the exception. See [EMError].
  Future<Map<String, int>?> removeAttributes(
    String roomId, {
    required List<String> keys,
    bool force = false,
  }) async {
    Map req = {
      "roomId": roomId,
      "keys": keys,
      "forced": force,
    };

    Map result = await _channel.invokeMethod(
      ChatMethodKeys.removeChatRoomAttributes,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.removeChatRoomAttributes]
          ?.cast<String, int>();
    } on EMError catch (e) {
      throw e;
    }
  }
}

extension ChatRoomManagerDeprecated on EMChatRoomManager {
  ///
  /// 注册聊天室事件监听对象。
  ///
  /// 聊天室被销毁、成员的加入和退出、禁言和加入白名单等操作均可通过设置 [EMChatRoomManagerListener] 进行监听。
  ///
  /// 利用本方法注册聊天室事件监听对象后，可调用 [removeChatRoomManagerListener] 移除。
  ///
  /// Param [listener] 聊天室事件监听对象，详见 [EMChatRoomManagerListener]。
  ///
  @Deprecated("Use EMChatRoomManager#addEventHandler to instead")
  void addChatRoomManagerListener(EMChatRoomManagerListener listener) {
    _listeners.remove(listener);
    _listeners.add(listener);
  }

  ///
  /// 移除聊天室事件监听对象。
  ///
  /// 调用 [addChatRoomManagerListener] 注册聊天室事件监听对象后，
  ///
  /// Param [listener] 要移除的聊天室监听对象。
  ///
  @Deprecated("Use EMChatRoomManager#removeEventHandler to instead")
  void removeChatRoomManagerListener(EMChatRoomManagerListener listener) {
    if (_listeners.contains(listener)) {
      _listeners.remove(listener);
    }
  }

  ///
  /// 移除所有聊天室事件监听对象。
  ///
  @Deprecated("Use EMChatRoomManager.clearEventHandlers to instead")
  void clearAllChatRoomManagerListeners() {
    _listeners.clear();
  }
}
