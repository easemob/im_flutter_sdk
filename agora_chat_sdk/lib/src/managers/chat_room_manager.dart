import 'package:flutter/services.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:agora_chat_sdk/src/tools/chat_extension.dart';
import 'package:agora_chat_sdk/src/tools/chat_log.dart';
import 'package:agora_chat_sdk_interface/agora_chat_sdk_interface.dart' as platform_interface;

/// ~english
/// The chat room manager class, which manages user joining and exiting the chat room, retrieving the chat room list, and managing member privileges.
/// The sample code for joining a chat room:
/// ```dart
///   try {
///       await ChatClient.getInstance.chatRoomManager.joinChatRoom(chatRoomId);
///   } on ChatError catch (e) {
///       debugPrint(e.toString());
///   }
/// ```
/// ~end
///
/// ~chinese
///  聊天室管理类，负责聊天室加入和退出、聊天室列表获取以及成员权限管理等。
///  比如，加入聊天室：
///   ```dart
///     try {
///         await ChatClient.getInstance.chatRoomManager.joinChatRoom(chatRoomId);
///     } on ChatError catch (e) {
///         debugPrint(e.toString());
///     }
///   ```
/// ~end
class ChatRoomManager {
  final Map<String, ChatRoomEventHandler> _eventHandlesMap = {};

  ChatRoomManager() {
    platform_interface.Client.instance.chatRoomManager
        .updateNativeHandler((MethodCall call) async {
      ChatLog.d("${call.method}: arguments: ${call.arguments}");
      Map? argMap = call.arguments;
      if (call.method == ChatMethodKeys.chatRoomChange) {
        return _chatRoomChange(argMap!);
      }
    });
  }

  Future<void> _chatRoomChange(Map event) async {
    String? type = event['type'];

    for (var item in _eventHandlesMap.values) {
      switch (type) {
        case ChatRoomEvent.ON_CHAT_ROOM_DESTROYED:
          String roomId = event['roomId'];
          String? roomName = event['roomName'];
          item.onChatRoomDestroyed?.call(roomId, roomName);
          break;
        case ChatRoomEvent.ON_MEMBER_JOINED:
          String roomId = event['roomId'];
          String participant = event['participant'];
          String? ext = event['ext'];
          item.onMemberJoinedFromChatRoom?.call(roomId, participant, ext);
          break;
        case ChatRoomEvent.ON_MEMBER_EXITED:
          String roomId = event['roomId'];
          String? roomName = event['roomName'];
          String participant = event['participant'];
          item.onMemberExitedFromChatRoom?.call(roomId, roomName, participant);
          break;
        case ChatRoomEvent.ON_REMOVED_FROM_CHAT_ROOM:
          String roomId = event['roomId'];
          String? roomName = event['roomName'];
          String participant = event['participant'];
          LeaveReason? reason;
          int iReason = event['reason'] ?? -1;
          if (iReason == 0) {
            reason = LeaveReason.Kicked;
          } else if (iReason == 2) {
            reason = LeaveReason.Offline;
          }
          item.onRemovedFromChatRoom
              ?.call(roomId, roomName, participant, reason);
          break;
        case ChatRoomEvent.ON_MUTE_LIST_ADDED:
          String roomId = event['roomId'];
          if (event["mutes"] is Map<String, dynamic>) {
            Map<String, dynamic> mutesDynamic = event["mutes"];
            Map<String, int> mutes = {};
            mutesDynamic.forEach((key, value) {
              if (value is int) {
                mutes[key] = value; // 只添加 int 类型的值
              }
            });
            item.onMuteListAddedFromChatRoom?.call(roomId, mutes);
          }
          break;
        case ChatRoomEvent.ON_MUTE_LIST_REMOVED:
          String roomId = event['roomId'];
          List<String> mutes = List.from(event['mutes'] ?? []);
          item.onMuteListRemovedFromChatRoom?.call(roomId, mutes);
          break;
        case ChatRoomEvent.ON_ADMIN_ADDED:
          String roomId = event['roomId'];
          String admin = event['admin'];
          item.onAdminAddedFromChatRoom?.call(roomId, admin);
          break;
        case ChatRoomEvent.ON_ADMIN_REMOVED:
          String roomId = event['roomId'];
          String admin = event['admin'];
          item.onAdminRemovedFromChatRoom?.call(roomId, admin);
          break;
        case ChatRoomEvent.ON_OWNER_CHANGED:
          String roomId = event['roomId'];
          String newOwner = event['newOwner'];
          String oldOwner = event['oldOwner'];
          item.onOwnerChangedFromChatRoom?.call(roomId, newOwner, oldOwner);
          break;
        case ChatRoomEvent.ON_ANNOUNCEMENT_CHANGED:
          String roomId = event['roomId'];
          String? announcement = event['announcement'];
          item.onAnnouncementChangedFromChatRoom?.call(roomId, announcement);
          break;
        case ChatRoomEvent.ON_WHITE_LIST_ADDED:
          String roomId = event['roomId'];
          List<String> members = List.from(event["whitelist"] ?? []);
          item.onAllowListAddedFromChatRoom?.call(roomId, members);
          break;
        case ChatRoomEvent.ON_WHITE_LIST_REMOVED:
          String roomId = event['roomId'];
          List<String> members = List.from(event["whitelist"] ?? []);
          item.onAllowListRemovedFromChatRoom?.call(roomId, members);
          break;
        case ChatRoomEvent.ON_ALL_MEMBER_MUTE_STATE_CHANGED:
          String roomId = event['roomId'];
          bool isAllMuted = event['isMuted'];
          item.onAllChatRoomMemberMuteStateChanged?.call(roomId, isAllMuted);
          break;
        case ChatRoomEvent.ON_SPECIFICATION_CHANGED:
          ChatRoom room = ChatRoom.fromJson(event["room"]);
          item.onSpecificationChanged?.call(room);
          break;
        case ChatRoomEvent.ON_ATTRIBUTES_UPDATED:
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
        case ChatRoomEvent.ON_ATTRIBUTES_REMOVED:
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
  }

  /// ~english
  /// Adds the room event handler. After calling this method, you can handle for new room event when they arrive.
  ///
  /// Param [identifier] The custom handler identifier, is used to find the corresponding handler.
  ///
  /// Param [handler] The handle for room event. See [ChatRoomEventHandler].
  /// ~end
  ///
  /// ~chinese
  /// 添加房间事件处理程序。调用此方法后，您可以在新的房间事件到达时处理它们。
  ///
  /// Param [identifier] 自定义聊天室事件 ID，用于查找相应的处理程序。
  ///
  /// Param [handler] 聊天室事件 请参见 [ChatRoomEventHandler].
  /// ~end
  void addEventHandler(
    String identifier,
    ChatRoomEventHandler handler,
  ) {
    _eventHandlesMap[identifier] = handler;
  }

  /// ~english
  /// Remove the room event handler.
  ///
  /// Param [identifier] The custom handler identifier.
  /// ~end
  ///
  /// ~chinese
  /// 移除聊天室事件
  ///
  /// Param [identifier] 聊天室事件 ID。
  /// ~end
  void removeEventHandler(String identifier) {
    _eventHandlesMap.remove(identifier);
  }

  /// ~english
  /// Get the room event handler.
  ///
  /// Param [identifier] The custom handler identifier.
  ///
  /// **Return** The room event handler.
  /// ~end
  ///
  /// ~chinese
  /// 获取聊天室事件。
  ///
  /// Param [identifier] 要获取的事件 ID。
  ///
  /// **Return** 聊天室事件。
  /// ~end
  ChatRoomEventHandler? getEventHandler(String identifier) {
    return _eventHandlesMap[identifier];
  }

  /// ~english
  /// Clear all room event handlers.
  /// ~end
  ///
  /// ~chinese
  /// 清除所有聊天室事件。
  /// ~end
  void clearEventHandlers() {
    _eventHandlesMap.clear();
  }

  /// Joins the chat room.
  ///
  /// To exit the chat room, call [leaveChatRoom].
  ///
  /// Param [roomId] The ID of the chat room to join.
  ///
  /// Param [leaveOtherRooms] Whether to leave all the currently joined chat rooms when joining a chat room.
  ///
  /// Param [ext] The extension information.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 加入聊天室
  ///
  /// 退出聊天室，调用 [leaveChatRoom].
  ///
  /// Param [roomId] 要加入的聊天室ID。
  ///
  /// Parm [leaveOtherRooms] 加入聊天室时候，是否退出已加入的聊天室。
  ///
  /// Param [ext] 扩展信息。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<void> joinChatRoom(
    String roomId, {
    bool leaveOtherRooms = false,
    String? ext,
  }) async {
    try {
      Map req = {
        "roomId": roomId,
        "leaveOtherRooms": leaveOtherRooms,
      };
      req.putIfNotNull("ext", ext);

      Map result = await platform_interface.Client.instance.chatRoomManager
          .callNativeMethod(ChatMethodKeys.joinChatRoom, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Leaves the chat room.
  ///
  /// Param [roomId] The ID of the chat room to leave.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 离开聊天室。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<void> leaveChatRoom(String roomId) async {
    try {
      Map result = await platform_interface.Client.instance.chatRoomManager
          .callNativeMethod(ChatMethodKeys.leaveChatRoom, {"roomId": roomId});
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets chat room data from the server with pagination.
  ///
  /// Param [pageNum] The page number, starting from 1.
  ///
  /// Param [pageSize] The number of records per page.
  ///
  /// **Return** Chat room data. See [ChatPageResult].
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 以分页的方式从服务器获取聊天室数据。
  ///
  /// Param [pageNum] 当前页码，从 1 开始。
  ///
  /// Param [pageSize] 每页返回的记录数。
  ///
  /// **Return** 分页获取结果，详见 [ChatPageResult]。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<ChatPageResult<ChatRoom>> fetchPublicChatRoomsFromServer({
    int pageNum = 1,
    int pageSize = 200,
  }) async {
    try {
      Map result = await platform_interface.Client.instance.chatRoomManager.callNativeMethod(
          ChatMethodKeys.fetchPublicChatRoomsFromServer,
          {"pageNum": pageNum, "pageSize": pageSize});
      ChatError.hasErrorFromResult(result);
      return ChatPageResult<ChatRoom>.fromJson(
          result[ChatMethodKeys.fetchPublicChatRoomsFromServer],
          dataItemCallback: (map) {
        return ChatRoom.fromJson(map);
      });
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the details of the chat room from the server.
  /// By default, the details do not include the chat room member list.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// **Return** The chat room instance.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取聊天室详情，默认不取成员列表。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// **Return** 返回聊天室对象。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<ChatRoom> fetchChatRoomInfoFromServer(
    String roomId, {
    @Deprecated('') bool? fetchMembers,
  }) async {
    try {
      Map result = await platform_interface.Client.instance.chatRoomManager.callNativeMethod(
          ChatMethodKeys.fetchChatRoomInfoFromServer,
          {"roomId": roomId, "fetchMembers": fetchMembers});
      ChatError.hasErrorFromResult(result);
      return ChatRoom.fromJson(
          result[ChatMethodKeys.fetchChatRoomInfoFromServer]);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the chat room in the cache.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// **Return** The chat room instance. Returns null if the chat room is not found in the cache.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取聊天室。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// **Return** 返回聊天室对象。如果内存中不存在聊天室对象，返回 null。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<ChatRoom?> getChatRoomWithId(String roomId) async {
    try {
      Map result = await platform_interface.Client.instance.chatRoomManager
          .callNativeMethod(ChatMethodKeys.getChatRoom, {"roomId": roomId});
      ChatError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.getChatRoom)) {
        return ChatRoom.fromJson(result[ChatMethodKeys.getChatRoom]);
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
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
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
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
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<ChatRoom> createChatRoom(
    String name, {
    String? desc,
    String? welcomeMsg,
    int maxUserCount = 300,
    List<String>? members,
  }) async {
    try {
      Map req = {};
      req['subject'] = name;
      req['maxUserCount'] = maxUserCount;
      req.putIfNotNull("desc", desc);
      req.putIfNotNull("welcomeMsg", welcomeMsg);
      req.putIfNotNull("members", members);
      Map result = await platform_interface.Client.instance.chatRoomManager
          .callNativeMethod(ChatMethodKeys.createChatRoom, req);
      ChatError.hasErrorFromResult(result);
      return ChatRoom.fromJson(result[ChatMethodKeys.createChatRoom]);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Destroys a chat room.
  ///
  /// Only the chat room owner can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 销毁聊天室。
  ///
  /// 仅聊天室所有者可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<void> destroyChatRoom(
    String roomId,
  ) async {
    try {
      Map req = {"roomId": roomId};
      Map result = await platform_interface.Client.instance.chatRoomManager
          .callNativeMethod(ChatMethodKeys.destroyChatRoom, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Changes the chat room name.
  ///
  /// Only the chat room owner can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [name] The new name of the chat room.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 修改聊天室标题。
  ///
  /// 仅聊天室所有者可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [name] 新的聊天室名称。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<void> changeChatRoomName(
    String roomId,
    String name,
  ) async {
    try {
      Map req = {"roomId": roomId, "subject": name};
      Map result = await platform_interface.Client.instance.chatRoomManager
          .callNativeMethod(ChatMethodKeys.changeChatRoomSubject, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Modifies the chat room description.
  ///
  /// Only the chat room owner can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [description] The new description of the chat room.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 修改聊天室描述信息。
  ///
  /// 仅聊天室所有者可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [description] The new description of the chat room.
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<void> changeChatRoomDescription(
    String roomId,
    String description,
  ) async {
    try {
      Map req = {"roomId": roomId, "description": description};
      Map result = await platform_interface.Client.instance.chatRoomManager
          .callNativeMethod(ChatMethodKeys.changeChatRoomDescription, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the chat room member list.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [cursor] The cursor position from which to start getting data.
  ///
  /// Param [pageSize] The number of members per page.
  ///
  /// **Return** The list of chat room members. See [ChatCursorResult]. If [ChatCursorResult.cursor] is an empty string (""), all data is fetched.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 获取聊天室成员列表。
  ///
  /// 返回的结果中，当 ChatCursorResult.cursor 为空字符串 ("") 时，表示没有更多数据。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [cursor] 从这个游标位置开始取数据。
  ///
  /// Param [pageSize] 每页返回的成员数。
  ///
  /// **Return** 分页获取结果 [ChatCursorResult]。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<ChatCursorResult<String>> fetchChatRoomMembers(
    String roomId, {
    String? cursor,
    int pageSize = 200,
  }) async {
    try {
      Map req = {"roomId": roomId, "pageSize": pageSize};
      req.putIfNotNull("cursor", cursor);
      Map result = await platform_interface.Client.instance.chatRoomManager
          .callNativeMethod(ChatMethodKeys.fetchChatRoomMembers, req);
      ChatError.hasErrorFromResult(result);
      return ChatCursorResult<String>.fromJson(
          result[ChatMethodKeys.fetchChatRoomMembers],
          dataItemCallback: (obj) => obj);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
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
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
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
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<void> muteChatRoomMembers(
    String roomId,
    List<String> muteMembers, {
    int duration = -1,
  }) async {
    try {
      Map req = {
        "roomId": roomId,
        "muteMembers": muteMembers,
        "duration": duration
      };
      Map result = await platform_interface.Client.instance.chatRoomManager
          .callNativeMethod(ChatMethodKeys.muteChatRoomMembers, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Unmutes the specified members in a chat room.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [unMuteMembers] The list of members to be unmuted.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 解除禁言。
  ///
  /// 仅聊天室所有者和管理员可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [unMuteMembers] 解除禁言的用户列表。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<void> unMuteChatRoomMembers(
    String roomId,
    List<String> unMuteMembers,
  ) async {
    try {
      Map req = {"roomId": roomId, "unMuteMembers": unMuteMembers};
      Map result = await platform_interface.Client.instance.chatRoomManager
          .callNativeMethod(ChatMethodKeys.unMuteChatRoomMembers, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Transfers the chat room ownership.
  ///
  /// Only the chat room owner can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [newOwner] The ID of the new chat room owner.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 转移聊天室的所有权。
  ///
  /// 仅聊天室所有者可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [newOwner] 新的聊天室所有者 ID。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<void> changeOwner(
    String roomId,
    String newOwner,
  ) async {
    try {
      Map req = {"roomId": roomId, "newOwner": newOwner};
      Map result = await platform_interface.Client.instance.chatRoomManager
          .callNativeMethod(ChatMethodKeys.changeChatRoomOwner, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Adds a chat room admin.
  ///
  /// Only the chat room owner can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [admin] The ID of the chat room admin to be added.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 添加聊天室管理员。
  ///
  /// 仅聊天室所有者可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [admin] 要设置的管理员 ID。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<void> addChatRoomAdmin(
    String roomId,
    String admin,
  ) async {
    try {
      Map req = {"roomId": roomId, "admin": admin};
      Map result = await platform_interface.Client.instance.chatRoomManager
          .callNativeMethod(ChatMethodKeys.addChatRoomAdmin, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Removes privileges of a chat room admin.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [admin] The ID of admin whose privileges are to be removed.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 移除聊天室管理员权限。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [admin] 要移除管理员权限的 ID。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<void> removeChatRoomAdmin(
    String roomId,
    String admin,
  ) async {
    try {
      Map req = {"roomId": roomId, "admin": admin};
      Map result = await platform_interface.Client.instance.chatRoomManager
          .callNativeMethod(ChatMethodKeys.removeChatRoomAdmin, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
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
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
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
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<List<String>> fetchChatRoomMuteList(
    String roomId, {
    int pageNum = 1,
    int pageSize = 200,
  }) async {
    try {
      Map req = {"roomId": roomId, "pageNum": pageNum, "pageSize": pageSize};
      Map result = await platform_interface.Client.instance.chatRoomManager
          .callNativeMethod(ChatMethodKeys.fetchChatRoomMuteList, req);
      ChatError.hasErrorFromResult(result);
      return result[ChatMethodKeys.fetchChatRoomMuteList]?.cast<String>() ?? [];
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Removes the specified members from a chat room.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [members] The list of the members to be removed.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 将成员移出聊天室。
  ///
  /// 仅聊天室所有者和管理员可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [members] 要移出聊天室的用户列表。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<void> removeChatRoomMembers(
    String roomId,
    List<String> members,
  ) async {
    try {
      Map req = {"roomId": roomId, "members": members};
      Map result = await platform_interface.Client.instance.chatRoomManager
          .callNativeMethod(ChatMethodKeys.removeChatRoomMembers, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Adds the specified members to the block list of the chat room.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// **Note**
  /// - Chat room members added to the block list are removed from the chat room by the server, and cannot re-join the chat room.
  /// - The removed members receive the [ChatRoomEventHandler.onRemovedFromChatRoom] callback.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [members] The list of members to be added to block list.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 将成员添加到聊天室黑名单。
  ///
  /// 仅聊天室所有者和管理员可调用此方法。
  ///
  /// 对于添加到聊天室黑名单的成员，请注意以下几点：
  /// 1. 成员添加到黑名单的同时，将被服务器移出聊天室。
  /// 2. 可通过 [ChatRoomEventHandler.onRemovedFromChatRoom] 回调通知。
  /// 3. 添加到黑名单的成员禁止再次加入到聊天室。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [members] 要加入黑名单的成员列表。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<void> blockChatRoomMembers(
    String roomId,
    List<String> members,
  ) async {
    try {
      Map req = {"roomId": roomId, "members": members};
      Map result = await platform_interface.Client.instance.chatRoomManager
          .callNativeMethod(ChatMethodKeys.blockChatRoomMembers, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Removes the specified members from the block list of the chat room.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [members] The list of members to be removed from the block list.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从聊天室黑名单中移除成员。
  ///
  /// 仅聊天室所有者和管理员可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [members] 要移除黑名单的成员列表。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<void> unBlockChatRoomMembers(
    String roomId,
    List<String> members,
  ) async {
    try {
      Map req = {"roomId": roomId, "members": members};
      Map result = await platform_interface.Client.instance.chatRoomManager
          .callNativeMethod(ChatMethodKeys.unBlockChatRoomMembers, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
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
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
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
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<List<String>> fetchChatRoomBlockList(
    String roomId, {
    int pageNum = 1,
    int pageSize = 200,
  }) async {
    try {
      Map req = {"roomId": roomId, "pageNum": pageNum, "pageSize": pageSize};
      Map result = await platform_interface.Client.instance.chatRoomManager
          .callNativeMethod(ChatMethodKeys.fetchChatRoomBlockList, req);
      ChatError.hasErrorFromResult(result);
      return result[ChatMethodKeys.fetchChatRoomBlockList]?.cast<String>() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Updates the chat room announcement.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [announcement] The announcement content.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 更新聊天室公告。
  ///
  /// 仅聊天室所有者和管理员可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [announcement] 公告内容。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<void> updateChatRoomAnnouncement(
    String roomId,
    String announcement,
  ) async {
    try {
      Map req = {"roomId": roomId, "announcement": announcement};
      Map result = await platform_interface.Client.instance.chatRoomManager
          .callNativeMethod(ChatMethodKeys.updateChatRoomAnnouncement, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the chat room announcement from the server.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// **Return** The chat room announcement.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取聊天室公告内容。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// **Return** 聊天室公告。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<String?> fetchChatRoomAnnouncement(
    String roomId,
  ) async {
    try {
      Map req = {"roomId": roomId};
      Map result = await platform_interface.Client.instance.chatRoomManager
          .callNativeMethod(ChatMethodKeys.fetchChatRoomAnnouncement, req);
      ChatError.hasErrorFromResult(result);
      return result[ChatMethodKeys.fetchChatRoomAnnouncement];
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the allow list from the server.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// **Return** The chat room allow list.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取白名单列表。
  ///
  /// 仅聊天室所有者和管理员可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// **Return** 聊天室白名单列表。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<List<String>> fetchChatRoomAllowListFromServer(String roomId) async {
    try {
      Map req = {"roomId": roomId};
      Map result = await platform_interface.Client.instance.chatRoomManager.callNativeMethod(
          ChatMethodKeys.fetchChatRoomWhiteListFromServer, req);
      ChatError.hasErrorFromResult(result);
      List<String> list = [];
      result[ChatMethodKeys.fetchChatRoomWhiteListFromServer]
          ?.forEach((element) {
        if (element is String) {
          list.add(element);
        }
      });
      return list;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Checks whether the member is on the allow list.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// **Return** Whether the member is on the allow list.
  /// - `true`: Yes;
  /// - `false`: No.
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 检查成员自己是否加入了白名单。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// **Return** 返回是否在白名单中：
  /// - `true`: 是；
  /// - `false`: 否。
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<bool> isMemberInChatRoomAllowList(String roomId) async {
    try {
      Map req = {"roomId": roomId};
      Map result = await platform_interface.Client.instance.chatRoomManager.callNativeMethod(
          ChatMethodKeys.isMemberInChatRoomWhiteListFromServer, req);
      ChatError.hasErrorFromResult(result);
      return result
          .boolValue(ChatMethodKeys.isMemberInChatRoomWhiteListFromServer);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Adds members to the allowlist.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [members] The list of members to be added to the allow list.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 将成员添加到白名单。
  ///
  /// 仅聊天室所有者和管理员可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [members] 要加入白名单的成员列表。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<void> addMembersToChatRoomAllowList(
    String roomId,
    List<String> members,
  ) async {
    try {
      Map req = {
        "roomId": roomId,
        "members": members,
      };
      Map result = await platform_interface.Client.instance.chatRoomManager.callNativeMethod(
        ChatMethodKeys.addMembersToChatRoomWhiteList,
        req,
      );
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Removes members from the allow list.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [members] The list of members to be removed from the allow list.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 将成员从白名单移除。
  ///
  /// 仅聊天室所有者和管理员可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [members] 移除白名单的用户列表。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<void> removeMembersFromChatRoomAllowList(
    String roomId,
    List<String> members,
  ) async {
    try {
      Map req = {
        "roomId": roomId,
        "members": members,
      };
      Map result = await platform_interface.Client.instance.chatRoomManager.callNativeMethod(
        ChatMethodKeys.removeMembersFromChatRoomWhiteList,
        req,
      );
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Mutes all members.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// This method does not work for the chat room owner, admin, and members added to the allow list.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 设置全员禁言。
  ///
  /// 仅聊天室所有者和管理员可调用此方法。
  ///
  /// 聊天室所有者、管理员及加入白名单的用户不受影响。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<void> muteAllChatRoomMembers(String roomId) async {
    try {
      Map req = {"roomId": roomId};
      Map result = await platform_interface.Client.instance.chatRoomManager.callNativeMethod(
        ChatMethodKeys.muteAllChatRoomMembers,
        req,
      );
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Unmutes all members.
  ///
  /// Only the chat room owner or admin can call this method.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 解除所有成员的禁言状态。
  ///
  /// 仅聊天室所有者和管理员可调用此方法。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<void> unMuteAllChatRoomMembers(String roomId) async {
    try {
      Map req = {"roomId": roomId};
      Map result = await platform_interface.Client.instance.chatRoomManager.callNativeMethod(
        ChatMethodKeys.unMuteAllChatRoomMembers,
        req,
      );
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the list of custom chat room attributes based on the attribute key list.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [keys] The key list of attributes to get. If you set it as `null` or leave it empty, this method retrieves all custom attributes.
  ///
  /// **Return** The chat room attributes in key-value pairs.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 根据属性键列表获取自定义聊天室属性的列表。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [keys] 要获取的属性的键列表。如果将其设置为“null”或留空，此方法将检索所有自定义属性。
  ///
  /// **Return** 键值对应的聊天室属性。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end

  Future<Map<String, String>?> fetchChatRoomAttributes({
    required String roomId,
    List<String>? keys,
  }) async {
    try {
      Map req = {
        "roomId": roomId,
      };
      req.putIfNotNull("keys", keys);
      Map result = await platform_interface.Client.instance.chatRoomManager.callNativeMethod(
        ChatMethodKeys.fetchChatRoomAttributes,
        req,
      );
      ChatError.hasErrorFromResult(result);
      return result[ChatMethodKeys.fetchChatRoomAttributes]
          ?.cast<String, String>();
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Sets custom chat room attributes.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [attributes] The chat room attributes to add. The attributes are in key-value format.
  ///
  /// Note:
  /// In a key-value pair, the key is the attribute name that can contain 128 characters at most; the value is the attribute value that cannot exceed 4096 characters.
  /// A chat room can have a maximum of 100 custom attributes and the total length of custom chat room attributes cannot exceed 10 GB for each app. Attribute keys support the following character sets:
  /// * - 26 lowercase English letters (a-z)
  /// * - 26 uppercase English letters (A-Z)
  /// * - 10 numbers (0-9)
  /// * - "_", "-", "."
  ///
  /// Param [deleteWhenLeft] Whether to delete the chat room attributes set by the member when he or she exits the chat room.
  ///
  /// Param [overwrite] Whether to overwrite the attributes with same key set by others.
  ///
  /// **Return** `failureKeys map` is returned in key-value format, where the key is the attribute key and the value is the reason for the failure.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 设置自定义聊天室属性。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [attributes] 要添加的聊天室属性。属性采用键值格式。
  ///
  /// Param [deleteWhenLeft] 退出聊天室时是否删除该成员设置的聊天室属性。
  ///
  /// Param [overwrite] 是否覆盖其他人设置的相同键的属性。
  ///
  /// **Return** ' failureKeys map '以键值格式返回，其中键是属性键，值是失败的原因。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  ///
  /// ~end

  Future<Map<String, int>?> addAttributes(
    String roomId, {
    required Map<String, String> attributes,
    bool deleteWhenLeft = false,
    bool overwrite = false,
  }) async {
    try {
      Map req = {
        "roomId": roomId,
        "attributes": attributes,
        "autoDelete": deleteWhenLeft,
        "forced": overwrite,
      };

      Map result = await platform_interface.Client.instance.chatRoomManager.callNativeMethod(
        ChatMethodKeys.setChatRoomAttributes,
        req,
      );
      ChatError.hasErrorFromResult(result);
      return result[ChatMethodKeys.setChatRoomAttributes]?.cast<String, int>();
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Removes custom chat room attributes.
  ///
  /// Param [roomId] The chat room ID.
  ///
  /// Param [keys] The keys of the custom chat room attributes to remove.
  ///
  /// Param [force] Whether to remove the attributes with same key set by others.
  ///
  /// **Return** `failureKeys map` is returned in key-value format, where the key is the attribute key and the value is the reason for the failure.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  ///
  /// ~end
  ///
  /// ~chinese
  /// 删除自定义聊天室属性。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [keys] 要删除的自定义聊天室属性的键。
  ///
  /// Param [force] 是否删除其他人设置的键值相同的属性。
  ///
  /// **Return** 'failureKeys map'以键值格式返回，其中键是属性键，值是失败的原因。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  ///
  /// ~end

  Future<Map<String, int>?> removeAttributes(
    String roomId, {
    required List<String> keys,
    bool force = false,
  }) async {
    try {
      Map req = {
        "roomId": roomId,
        "keys": keys,
        "forced": force,
      };

      Map result = await platform_interface.Client.instance.chatRoomManager.callNativeMethod(
        ChatMethodKeys.removeChatRoomAttributes,
        req,
      );
      ChatError.hasErrorFromResult(result);
      return result[ChatMethodKeys.removeChatRoomAttributes]
          ?.cast<String, int>();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isMemberInChatRoomMuteList(String roomId) async {
    try {
      Map req = {"roomId": roomId};
      Map result = await platform_interface.Client.instance.chatRoomManager.callNativeMethod(
        ChatMethodKeys.isMemberInChatRoomMuteList,
        req,
      );
      ChatError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.isMemberInChatRoomMuteList);
    } catch (e) {
      rethrow;
    }
  }
}
