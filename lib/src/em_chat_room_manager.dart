import "dart:async";

import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'internal/inner_headers.dart';

///
///  The chat room manager class, which manages user joining and exiting the chat room, retrieving the chat room list, and managing member privileges.
///  The sample code for joining a chat room:
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

  final Map<String, EMRoomEventHandler> _eventHandlesMap = {};
  // deprecated(3.9.5)
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
  /// Adds the room event handler. After calling this method, you can handle for new room event when they arrive.
  ///
  /// Param [identifier] The custom handler identifier, is used to find the corresponding handler.
  ///
  /// Param [handler] The handle for room event. See {@link EMRoomEventHandler}.
  ///
  void addEventHandler(
    String identifier,
    EMRoomEventHandler handler,
  ) {
    _eventHandlesMap[identifier] = handler;
  }

  ///
  /// Remove the room event handler.
  ///
  /// Param [identifier] The custom handler identifier.
  ///
  void removeEventHandler(String identifier) {
    _eventHandlesMap.remove(identifier);
  }

  ///
  /// Get the room event handler.
  ///
  /// Param [identifier] The custom handler identifier.
  ///
  /// **Return** The room event handler.
  ///
  EMRoomEventHandler? getEventHandler(String identifier) {
    return _eventHandlesMap[identifier];
  }

  ///
  /// Clear all room event handlers.
  ///
  void clearEventHandlers() {
    _eventHandlesMap.clear();
  }

  ///
  /// Joins the chat room.
  ///
  /// To exit the chat room, call {@link #leaveChatRoom(String)}.
  ///
  /// Param [roomId] The ID of the chat room to join.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Leaves the chat room.
  ///
  /// Param [roomId] The ID of the chat room to leave.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Gets chat room data from the server with pagination.
  ///
  /// Param [pageNum] The page number, starting from 1.
  ///
  /// Param [pageSize] The number of records per page.
  ///
  /// **Return** Chat room data. See {@link EMPageResult}.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Gets the details of the chat room from the server.
  /// By default, the details do not include the chat room member list.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// **Return** The chat room instance.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Gets the chat room in the cache.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// **Return** The chat room instance. Returns null if the chat room is not found in the cache.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Creates a chat room.
  ///
  /// Param [name] The chat room name.
  ///
  /// Param [desc] The chat room description.
  ///
  /// Param [welcomeMsg] A welcome message that invites users to join the chat room.
  ///
  /// Param [maxUserCount] The maximum number of members allowed to join the chat room.
  ///
  /// Param [members] The list of members invited to join the chat room.
  ///
  /// **Return** The chat room instance.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Destroys a chat room.
  ///
  /// Only the chat room owner can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Changes the chat room name.
  ///
  /// Only the chat room owner can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [name] The new name of the chat room.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Modifies the chat room description.
  ///
  /// Only the chat room owner can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [description] The new description of the chat room.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Gets the chat room member list.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [cursor] The cursor position from which to start getting data.
  ///
  /// Param [pageSize] The number of members per page.
  ///
  /// **Return** The list of chat room members. See {@link EMCursorResult}. If `EMCursorResult.cursor` is an empty string (""), all data is fetched.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Mutes the specified members in a chat room.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [muteMembers] The list of members to be muted.
  ///
  /// Param [duration] The mute duration in milliseconds.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Unmutes the specified members in a chat room.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [unMuteMembers] The list of members to be unmuted.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Transfers the chat room ownership.
  ///
  /// Only the chat room owner can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [newOwner] The ID of the new chat room owner.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Adds a chat room admin.
  ///
  /// Only the chat room owner can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [admin] The ID of the chat room admin to be added.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Removes privileges of a chat room admin.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [admin] The ID of admin whose privileges are to be removed.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Gets the list of members who are muted in the chat room from the server.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [pageNum] The page number, starting from 1.
  ///
  /// Param [pageSize] The number of muted members per page.
  ///
  /// **Return** The muted member list.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Removes the specified members from a chat room.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [members] The list of the members to be removed.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Adds the specified members to the block list of the chat room.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// **Note**
  /// - Chat room members added to the block list are removed from the chat room by the server, and cannot re-join the chat room.
  /// - The removed members receive the {@link EMChatRoomEventListener#onRemovedFromChatRoom(String, String?, String)} callback.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [members] The list of members to be added to block list.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Removes the specified members from the block list of the chat room.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [members] The list of members to be removed from the block list.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Gets the chat room block list with pagination.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [pageNum] The page number, starting from 1.
  ///
  /// Param [pageSize] The number of users on the block list per page.
  ///
  /// **Return** The list of the blocked chat room members.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Updates the chat room announcement.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [announcement] The announcement content.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Gets the chat room announcement from the server.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// **Return** The chat room announcement.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Gets the allow list from the server.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// **Return** The chat room allow list.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Checks whether the member is on the allow list.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// **Return** Whether the member is on the allow list.
  /// - `true`: Yes;
  /// - `false`: No.
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Adds members to the allowlist.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [members] The list of members to be added to the allow list.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Removes members from the allow list.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [members] The list of members to be removed from the allow list.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Mutes all members.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// This method does not work for the chat room owner, admin, and members added to the allow list.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Unmutes all members.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
}

extension ChatRoomManagerDeprecated on EMChatRoomManager {
  ///
  /// Registers a chat room manager listener.
  ///
  /// After registering the chat room manager listener, you can listen for events in {@link EMChatRoomManagerListener}, for example, users joining and exiting the chat room, adding the specified member to the chat group mute list, updating the chat room allow list, and destroying the chat room.
  ///
  /// To stop listening for chat room manager, call {@link #removeChatRoomManagerListener(EMChatRoomManagerListener)}.
  ///
  /// Param [listener] A chat room listener. See {@link EMChatRoomManagerListener}.
  ///
  @Deprecated("Use EMChatRoomManager#addEventHandler to instead.")
  void addChatRoomManagerListener(EMChatRoomManagerListener listener) {
    _listeners.remove(listener);
    _listeners.add(listener);
  }

  ///
  /// Removes a chat room manager listener.
  /// This method removes the chat room manager listener registered with {@link #addChatRoomManagerListener(EMChatRoomManagerListener)}.
  ///
  /// Param [listener] The chat room manager listener to be removed.
  ///
  @Deprecated("Use EMChatRoomManager#removeEventHandler to instead.")
  void removeChatRoomManagerListener(EMChatRoomManagerListener listener) {
    if (_listeners.contains(listener)) {
      _listeners.remove(listener);
    }
  }

  ///
  /// Removes all chat room manager listener.
  ///
  @Deprecated("Use EMChatRoomManager#clearEventHandlers to instead.")
  void clearAllChatRoomManagerListeners() {
    _listeners.clear();
  }
}
