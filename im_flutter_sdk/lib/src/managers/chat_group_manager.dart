import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk/src/tools/chat_extension.dart';
import 'package:im_flutter_sdk/src/tools/chat_log.dart';
import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart' as platform_interface;

/// ~english
/// The group manager class, which manages group creation and deletion, user joining and exiting the group, etc.
/// ~end
///
/// ~chinese
/// 群组管理类，用于管理群组的创建，删除及成员管理等操作。
/// ~end
class ChatGroupManager {
  final Map<String, ChatGroupEventHandler> _eventHandlesMap = {};

  ChatGroupManager() {
    platform_interface.Client.instance.groupManager.updateNativeHandler((MethodCall call) async {
      ChatLog.d("${call.method}: arguments: ${call.arguments}");
      Map? argMap = call.arguments;
      if (call.method == ChatMethodKeys.onGroupChanged) {
        return _onGroupChanged(argMap);
      }
    });
  }

  Future<void> _onGroupChanged(Map? map) async {
    var type = map!['type'];
    for (var element in _eventHandlesMap.values) {
      switch (type) {
        case ChatGroupChangeEvent.ON_INVITATION_RECEIVED:
          String groupId = map['groupId'];
          String? groupName = map['groupName'];
          String inviter = map['inviter'];
          String? reason = map['reason'];
          element.onInvitationReceivedFromGroup
              ?.call(groupId, groupName, inviter, reason);
          break;
        case ChatGroupChangeEvent.ON_INVITATION_ACCEPTED:
          String groupId = map['groupId'];
          String invitee = map['invitee'];
          String? reason = map['reason'];
          element.onInvitationAcceptedFromGroup?.call(groupId, invitee, reason);
          break;
        case ChatGroupChangeEvent.ON_INVITATION_DECLINED:
          String groupId = map['groupId'];
          String invitee = map['invitee'];
          String? reason = map['reason'];
          element.onInvitationDeclinedFromGroup?.call(groupId, invitee, reason);
          break;
        case ChatGroupChangeEvent.ON_AUTO_ACCEPT_INVITATION:
          String groupId = map['groupId'];
          String inviter = map['inviter'];
          String? inviteMessage = map['inviteMessage'];
          element.onAutoAcceptInvitationFromGroup
              ?.call(groupId, inviter, inviteMessage);
          break;
        case ChatGroupChangeEvent.ON_USER_REMOVED:
          String groupId = map['groupId'];
          String? groupName = map['groupName'];
          element.onUserRemovedFromGroup?.call(groupId, groupName);
          break;
        case ChatGroupChangeEvent.ON_REQUEST_TO_JOIN_RECEIVED:
          String groupId = map['groupId'];
          String? groupName = map['groupName'];
          String applicant = map['applicant'];
          String? reason = map['reason'];
          element.onRequestToJoinReceivedFromGroup
              ?.call(groupId, groupName, applicant, reason);
          break;
        case ChatGroupChangeEvent.ON_REQUEST_TO_JOIN_DECLINED:
          String groupId = map['groupId'];
          String? groupName = map['groupName'];
          String? applicant = map['applicant'];
          String? reason = map['reason'];
          String? decliner = map['decliner'];
          element.onRequestToJoinDeclinedFromGroup
              ?.call(groupId, groupName, decliner, reason, applicant);
          break;
        case ChatGroupChangeEvent.ON_REQUEST_TO_JOIN_ACCEPTED:
          String groupId = map['groupId'];
          String? groupName = map['groupName'];
          String accepter = map['accepter'];
          element.onRequestToJoinAcceptedFromGroup
              ?.call(groupId, groupName, accepter);
          break;
        case ChatGroupChangeEvent.ON_GROUP_DESTROYED:
          String groupId = map['groupId'];
          String? groupName = map['groupName'];
          element.onGroupDestroyed?.call(groupId, groupName);
          break;
        case ChatGroupChangeEvent.ON_MUTE_LIST_ADDED:
          String groupId = map['groupId'];
          List<String> mutes = List.from(map['mutes'] ?? []);
          int? muteExpire = map['muteExpire'];
          element.onMuteListAddedFromGroup?.call(groupId, mutes, muteExpire);
          break;
        case ChatGroupChangeEvent.ON_MUTE_LIST_REMOVED:
          String groupId = map['groupId'];
          List<String> mutes = List.from(map['mutes'] ?? []);
          element.onMuteListRemovedFromGroup?.call(groupId, mutes);
          break;
        case ChatGroupChangeEvent.ON_ADMIN_ADDED:
          String groupId = map['groupId'];
          String administrator = map['administrator'];
          element.onAdminAddedFromGroup?.call(groupId, administrator);
          break;
        case ChatGroupChangeEvent.ON_ADMIN_REMOVED:
          String groupId = map['groupId'];
          String administrator = map['administrator'];
          element.onAdminRemovedFromGroup?.call(groupId, administrator);
          break;
        case ChatGroupChangeEvent.ON_OWNER_CHANGED:
          String groupId = map['groupId'];
          String newOwner = map['newOwner'];
          String oldOwner = map['oldOwner'];
          element.onOwnerChangedFromGroup?.call(groupId, newOwner, oldOwner);
          break;
        case ChatGroupChangeEvent.ON_MEMBER_JOINED:
          String groupId = map['groupId'];
          String member = map['member'];
          element.onMemberJoinedFromGroup?.call(groupId, member);
          break;
        case ChatGroupChangeEvent.ON_MEMBER_EXITED:
          String groupId = map['groupId'];
          String member = map['member'];
          element.onMemberExitedFromGroup?.call(groupId, member);
          break;
        case ChatGroupChangeEvent.ON_ANNOUNCEMENT_CHANGED:
          String groupId = map['groupId'];
          String? announcement = map['announcement'];
          element.onAnnouncementChangedFromGroup?.call(groupId, announcement);
          break;
        case ChatGroupChangeEvent.ON_SHARED_FILE_ADDED:
          String groupId = map['groupId'];
          ChatGroupSharedFile sharedFile =
              ChatGroupSharedFile.fromJson(map['sharedFile']);
          element.onSharedFileAddedFromGroup?.call(groupId, sharedFile);
          break;
        case ChatGroupChangeEvent.ON_SHARED_FILE__DELETED:
          String groupId = map['groupId'];
          String fileId = map['fileId'];
          element.onSharedFileDeletedFromGroup?.call(groupId, fileId);
          break;
        case ChatGroupChangeEvent.ON_WHITE_LIST_ADDED:
          String groupId = map["groupId"];
          List<String> members = List.from(map['whitelist'] ?? []);
          element.onAllowListAddedFromGroup?.call(groupId, members);
          break;
        case ChatGroupChangeEvent.ON_WHITE_LIST_REMOVED:
          String groupId = map["groupId"];
          List<String> members = List.from(map['whitelist'] ?? []);
          element.onAllowListRemovedFromGroup?.call(groupId, members);
          break;
        case ChatGroupChangeEvent.ON_ALL_MEMBER_MUTE_STATE_CHANGED:
          String groupId = map["groupId"];
          bool isAllMuted = map["isMuted"] as bool;
          element.onAllGroupMemberMuteStateChanged?.call(groupId, isAllMuted);
          break;
        case ChatGroupChangeEvent.ON_SPECIFICATION_DID_UPDATE:
          ChatGroup group = ChatGroup.fromJson(map["group"]);
          element.onSpecificationDidUpdate?.call(group);
          break;
        case ChatGroupChangeEvent.ON_STATE_CHANGED:
          String groupId = map["groupId"];
          bool isDisable = map["isDisabled"] as bool;
          element.onDisableChanged?.call(groupId, isDisable);
          break;
        case ChatGroupChangeEvent.ON_ATTRIBUTES_CHANGED_OF_MEMBER:
          String groupId = map["groupId"];
          String userId = map["userId"];
          Map<String, String>? attributes =
              map["attributes"].cast<String, String>();
          String? operatorId = map["operatorId"];
          element.onAttributesChangedOfGroupMember?.call(
            groupId,
            userId,
            attributes,
            operatorId,
          );
        case "onGroupMembersJoined":
          String groupId = map["groupId"];
          List<String> members = List.from(map['userIds'] ?? []);
          element.onMembersJoinedFromGroup?.call(groupId, members);
          break;
        case "onGroupMembersExited":
          String groupId = map["groupId"];
          List<String> members = List.from(map['userIds'] ?? []);
          element.onMembersExitedFromGroup?.call(groupId, members);
          break;
        case ChatGroupChangeEvent.ON_USER_GROUP_NAMECARD_CHANGED:
          String groupId = map["groupId"];
          String userId = map["userId"];
          String? namecard = map["namecard"];
          element.onUserGroupNamecardChanged?.call(groupId, userId, namecard);
          break;
      }
    }
  }

  /// ~english
  /// Adds the group event handler. After calling this method, you can handle for new group event when they arrive.
  ///
  /// Param [identifier] The custom handler identifier, is used to find the corresponding handler.
  ///
  /// Param [handler] The handle for group event. See [ChatGroupEventHandler].
  /// ~end
  ///
  /// ~chinese
  /// 添加群组事件监听。
  ///
  /// Param [identifier] 自定义监听对应 ID，可用于查找或删除监听。
  ///
  /// Param [handler] 群组事件监听，请见 [ChatGroupEventHandler].
  /// ~end
  void addEventHandler(
    String identifier,
    ChatGroupEventHandler handler,
  ) {
    _eventHandlesMap[identifier] = handler;
  }

  /// ~english
  /// Remove the group event handler.
  ///
  /// Param [identifier] The custom handler identifier.
  /// ~end
  ///
  /// ~chinese
  /// 移出群组事件监听
  ///
  /// Param [identifier] 需要移除监听对应的 ID。
  /// ~end
  void removeEventHandler(String identifier) {
    _eventHandlesMap.remove(identifier);
  }

  /// ~english
  /// Get the group event handler.
  ///
  /// Param [identifier] The custom handler identifier.
  ///
  /// **Return** The group event handler.
  /// ~end
  ///
  /// ~chinese
  /// 获取群组事件监听
  ///
  /// Param [identifier] 需要获取监听对应的 ID。
  ///
  /// **Return** ID 对应的监听。
  /// ~end
  ChatGroupEventHandler? getEventHandler(String identifier) {
    return _eventHandlesMap[identifier];
  }

  /// ~english
  /// Clear all group event handlers.
  /// ~end
  ///
  /// ~chinese
  /// 清除所有事件监听。
  /// ~end
  void clearEventHandlers() {
    _eventHandlesMap.clear();
  }

  /// ~english
  /// Gets the group instance, creates it if it does not exist.
  ///
  /// Param [groupId]  The group ID.
  ///
  /// **Returns** The group instance.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 获取群组实例，如果不存在则创建。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// **Return** 群组实例。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<ChatGroup?> getGroupWithId(String groupId) async {
    try {
      Map req = {'groupId': groupId};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.getGroupWithId, req);
      ChatError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.getGroupWithId)) {
        return ChatGroup.fromJson(result[ChatMethodKeys.getGroupWithId]);
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets all group information of the current user from the local cache.
  ///
  /// **Returns** The list of groups.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 获取本地缓存中当前用户的所有群组信息。
  ///
  /// **Return** 群组列表。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<List<ChatGroup>> getJoinedGroups() async {
    try {
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.getJoinedGroups);
      ChatError.hasErrorFromResult(result);
      List<ChatGroup> list = [];
      result[ChatMethodKeys.getJoinedGroups]
          ?.forEach((element) => list.add(ChatGroup.fromJson(element)));
      return list;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the groups joined by the current user from the server with pagination.
  ///
  /// Param [pageNum]        The current page number, starting from 0. The SDK queries in reverse order of group joining.
  /// Param [pageSize]       The number of groups to get per page. Value range: [1,20].
  /// Param [needMemberCount] Whether to get the group member count.
  /// Param [needRole]       Whether to get the role of the current user in the group.
  ///
  /// **Returns** The list of retrieved groups.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器分页获取当前用户加入的群组。
  ///
  /// Param [pageNum]        当前页码，从 0 开始，SDK 按照加入群组逆序查询。
  /// Param [pageSize]       每页获取的群组数量，取值范围 [1,20]。
  /// Param [needMemberCount] 是否需要群组成员数。
  /// Param [needRole]       是否需要当前用户在群组内的角色。
  ///
  /// **Return** 获取到的群组列表。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<List<ChatGroup>> fetchJoinedGroupsFromServer({
    int pageSize = 20,
    int pageNum = 0,
    bool needMemberCount = false,
    bool needRole = false,
  }) async {
    try {
      Map req = {
        'pageSize': pageSize,
        'pageNum': pageNum,
        "needMemberCount": needMemberCount,
        "needRole": needRole,
      };
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.getJoinedGroupsFromServer, req);
      ChatError.hasErrorFromResult(result);
      List<ChatGroup> list = [];
      result[ChatMethodKeys.getJoinedGroupsFromServer]
          ?.forEach((element) => list.add(ChatGroup.fromJson(element)));
      return list;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets public groups within the specified range from the server.
  ///
  /// Param [cursor]    The cursor for getting public groups, null for the first call.
  /// Param [pageSize]  The number of results expected to be returned.
  ///
  /// **Returns** The result of retrieved public groups.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取指定范围内的公开群。
  ///
  /// Param [cursor]    获取公开群的游标，首次调用传空。
  /// Param [pageSize]  期望返回结果的数量。
  ///
  /// **Return** 获取到的公开群结果。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<ChatCursorResult<ChatGroupInfo>> fetchPublicGroupsFromServer({
    int pageSize = 200,
    String? cursor,
  }) async {
    try {
      Map req = {'pageSize': pageSize};
      req.putIfNotNull("cursor", cursor);
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.getPublicGroupsFromServer, req);
      ChatError.hasErrorFromResult(result);
      return ChatCursorResult<ChatGroupInfo>.fromJson(
          result[ChatMethodKeys.getPublicGroupsFromServer],
          dataItemCallback: (value) {
        return ChatGroupInfo.fromJson(value);
      });
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Creates a group.
  ///
  /// Param [groupName]      The group name.
  /// Param [avatarUrl]      The group avatar URL.
  /// Param [desc]           The group description.
  /// Param [inviteMembers]  The group members to invite, not including the creator.
  /// Param [inviteReason]   The invitation message for joining the group.
  /// Param [options]        The group options, see [ChatGroupOptions].
  ///
  /// **Returns** The created group instance.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 创建群组。
  ///
  /// Param [groupName]      群组名称。
  /// Param [avatarUrl]      群组头像地址。
  /// Param [desc]           群组描述。
  /// Param [inviteMembers]  邀请的群成员，不包含创建者自己。
  /// Param [inviteReason]   加入群组的邀请消息。
  /// Param [options]        群组属性，详见 [ChatGroupOptions]。
  ///
  /// **Return** 创建的群组实例。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<ChatGroup> createGroup({
    String? groupName,
    String? avatarUrl,
    String? desc,
    List<String>? inviteMembers,
    String? inviteReason,
    required ChatGroupOptions options,
  }) async {
    try {
      Map req = {'options': options.toJson()};
      req.putIfNotNull("groupName", groupName);
      req.putIfNotNull("avatarUrl", avatarUrl);
      req.putIfNotNull("desc", desc);
      req.putIfNotNull("inviteMembers", inviteMembers);
      req.putIfNotNull("inviteReason", inviteReason);

      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.createGroup, req);
      ChatError.hasErrorFromResult(result);
      return ChatGroup.fromJson(result[ChatMethodKeys.createGroup]);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Fetches group details including group ID, name, description, basic settings, owner and admins.
  ///
  /// Param [groupId]  The group ID.
  ///
  /// **Returns** The group instance.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 获取群组详情，包含群组 ID、名称、描述、基本属性、群主和管理员。
  ///
  /// Param [groupId]  群组 ID。
  ///
  /// **Return** 群组实例。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<ChatGroup> fetchGroupInfoFromServer(
    String groupId, {
    @Deprecated('') bool? fetchMembers,
  }) async {
    Map req = {"groupId": groupId};
    req.putIfNotNull("fetchMembers", fetchMembers);
    Map result = await platform_interface.Client.instance.groupManager
        .callNativeMethod(ChatMethodKeys.getGroupSpecificationFromServer, req);
    try {
      ChatError.hasErrorFromResult(result);
      return ChatGroup.fromJson(
          result[ChatMethodKeys.getGroupSpecificationFromServer]);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the list of group members from the server with pagination.
  ///
  /// Param [groupId]   The group ID.
  /// Param [pageSize]  The number of members expected to be returned per page.
  /// Param [cursor]    The cursor for pagination, pass null for the first call.
  ///
  /// **Returns** The member list and cursor for next page.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取群组成员列表（分页获取）。
  ///
  /// Param [groupId]   群组 ID。
  /// Param [pageSize]  每页期望返回的成员数量。
  /// Param [cursor]    分页游标，首次调用传空。
  ///
  /// **Return** 成员列表和下一页游标。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<ChatCursorResult<String>> fetchMemberListFromServer(
    String groupId, {
    int pageSize = 200,
    String? cursor,
  }) async {
    try {
      Map req = {
        'groupId': groupId,
        'pageSize': pageSize,
      };
      req.putIfNotNull("cursor", cursor);
      Map result = await platform_interface.Client.instance.groupManager.callNativeMethod(
        ChatMethodKeys.getGroupMemberListFromServer,
        req,
      );
      ChatError.hasErrorFromResult(result);
      return ChatCursorResult<String>.fromJson(
          result[ChatMethodKeys.getGroupMemberListFromServer],
          dataItemCallback: (value) => value);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the group blocklist from the server.
  /// Only the group owner and admins can call this method.
  ///
  /// Param [groupId]   The group ID.
  /// Param [pageNum]   The page number.
  /// Param [pageSize]  The number of results expected per page.
  ///
  /// **Returns** The group blocklist.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 获取群组黑名单列表。
  /// 仅群主和管理员有权限调用。
  ///
  /// Param [groupId]   群组 ID。
  /// Param [pageNum]   获取第几页。
  /// Param [pageSize]  每页获取的数量。
  ///
  /// **Return** 群组黑名单列表。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<List<String>> fetchBlockListFromServer(
    String groupId, {
    int pageSize = 200,
    int pageNum = 1,
  }) async {
    try {
      Map req = {'groupId': groupId, 'pageNum': pageNum, 'pageSize': pageSize};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.getGroupBlockListFromServer, req);
      ChatError.hasErrorFromResult(result);
      return result[ChatMethodKeys.getGroupBlockListFromServer]
              ?.cast<String>() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the group mute list from the server.
  /// Only the group owner and admins can call this method.
  ///
  /// Param [groupId]   The group ID.
  /// Param [pageNum]   The page number.
  /// Param [pageSize]  The number of results per page.
  ///
  /// **Returns** The group mute list map.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 获取群组禁言列表。
  /// 仅群主和管理员有权限调用。
  ///
  /// Param [groupId]   群组 ID。
  /// Param [pageNum]   获取第几页。
  /// Param [pageSize]  每页获取的数量。
  ///
  /// **Return** 群组禁言列表 Map。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<Map<String, int>> fetchMuteListFromServer(
    String groupId, {
    int pageSize = 200,
    int pageNum = 1,
  }) async {
    try {
      Map req = {'groupId': groupId, 'pageNum': pageNum, 'pageSize': pageSize};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.getGroupMuteListFromServer, req);
      ChatError.hasErrorFromResult(result);
      Map? tmpMap = result[ChatMethodKeys.getGroupMuteListFromServer];
      Map<String, int> ret = {};
      if (tmpMap != null) {
        for (var item in tmpMap.entries) {
          if (item.key is String && item.value is int) {
            ret[item.key] = item.value;
          }
        }
      }
      return ret;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the group allowlist from the server.
  ///
  /// Param [groupId]  The group ID.
  ///
  /// **Returns** The group allowlist.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取群组白名单列表。
  ///
  /// Param [groupId]  群组 ID。
  ///
  /// **Return** 群组白名单列表。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<List<String>> fetchAllowListFromServer(String groupId) async {
    try {
      Map req = {'groupId': groupId};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.getGroupWhiteListFromServer, req);
      List<String> list = [];
      ChatError.hasErrorFromResult(result);
      result[ChatMethodKeys.getGroupWhiteListFromServer]?.forEach((element) {
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
  /// Checks whether the current user is on the group allowlist.
  ///
  /// Param [groupId]  The group ID.
  ///
  /// **Returns** True if the current user is in the allowlist, false otherwise.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 查看当前用户是否在群组白名单中。
  ///
  /// Param [groupId]  群组 ID。
  ///
  /// **Return** 是否在白名单中：true 是，false 否。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<bool> isMemberInAllowListFromServer(String groupId) async {
    try {
      Map req = {'groupId': groupId};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.isMemberInWhiteListFromServer, req);
      ChatError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.isMemberInWhiteListFromServer);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the group shared file list from the server.
  ///
  /// Param [groupId]   The group ID.
  /// Param [pageNum]   The page number.
  /// Param [pageSize]  The number of results expected per page.
  ///
  /// **Returns** The group shared file list.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 获取群共享文件列表。
  ///
  /// Param [groupId]   群组 ID。
  /// Param [pageNum]   获取第几页。
  /// Param [pageSize]  每页获取的数量。
  ///
  /// **Return** 群共享文件列表。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<List<ChatGroupSharedFile>> fetchGroupFileListFromServer(
    String groupId, {
    int pageSize = 200,
    int pageNum = 1,
  }) async {
    try {
      Map req = {'groupId': groupId, 'pageNum': pageNum, 'pageSize': pageSize};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.getGroupFileListFromServer, req);
      ChatError.hasErrorFromResult(result);
      List<ChatGroupSharedFile> list = [];
      result[ChatMethodKeys.getGroupFileListFromServer]?.forEach((element) {
        list.add(ChatGroupSharedFile.fromJson(element));
      });
      return list;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the group announcement from the server.
  ///
  /// Param [groupId]  The group ID.
  ///
  /// **Returns** The group announcement, returns null if failed.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取群公告。
  ///
  /// Param [groupId]  群组 ID。
  ///
  /// **Return** 群公告，失败返回空值。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<String?> fetchAnnouncementFromServer(String groupId) async {
    try {
      Map req = {'groupId': groupId};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.getGroupAnnouncementFromServer, req);
      ChatError.hasErrorFromResult(result);
      return result[ChatMethodKeys.getGroupAnnouncementFromServer];
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Invites users to join a group.
  ///
  /// Param [groupId]   The group ID.
  /// Param [members]   The list of users to be invited.
  /// Param [welcome]   The welcome message.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 邀请用户加入群组。
  ///
  /// Param [groupId]   群组 ID。
  /// Param [members]   被邀请的用户列表。
  /// Param [welcome]   欢迎消息。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> addMembers(
    String groupId,
    List<String> members, {
    String? welcome,
  }) async {
    try {
      Map req = {'groupId': groupId, 'members': members};
      req.putIfNotNull("welcome", welcome);
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.addMembers, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Invites users to join a group.
  ///
  /// Param [groupId]   The group ID.
  /// Param [members]   The list of users to be invited.
  /// Param [reason]    The reason for inviting the user.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 邀请用户加入群组。
  ///
  /// Param [groupId]   群组 ID。
  /// Param [members]   被邀请的用户列表。
  /// Param [reason]    邀请用户的原因。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> inviterUser(
    String groupId,
    List<String> members, {
    String? reason,
  }) async {
    try {
      Map req = {
        'groupId': groupId,
        'members': members,
      };
      req.putIfNotNull("reason", reason);

      Map result = await platform_interface.Client.instance.groupManager.callNativeMethod(
        ChatMethodKeys.inviterUser,
        req,
      );

      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Removes members from the group.
  /// Only the group owner can call this method.
  ///
  /// Param [groupId]   The group ID.
  /// Param [members]   The list of members to be removed from the group.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 将群成员移出群组。
  /// 仅群主有权限调用。
  ///
  /// Param [groupId]   群组 ID。
  /// Param [members]   要移出群组的用户列表。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> removeMembers(
    String groupId,
    List<String> members,
  ) async {
    try {
      Map req = {'groupId': groupId, 'members': members};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.removeMembers, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Adds users to the group blocklist.
  /// Only the group owner can call this method.
  ///
  /// Param [groupId]   The group ID.
  /// Param [members]   The list of users to be added to the blocklist.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 将用户加入群组黑名单。
  /// 仅群主有权限调用。
  ///
  /// Param [groupId]   群组 ID。
  /// Param [members]   要加入黑名单的用户列表。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> blockMembers(
    String groupId,
    List<String> members,
  ) async {
    try {
      Map req = {'groupId': groupId, 'members': members};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.blockMembers, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Removes users from the group blocklist.
  /// Only the group owner can call this method.
  ///
  /// Param [groupId]   The group ID.
  /// Param [members]   The list of users to be removed from the blocklist.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从群组黑名单中移除用户。
  /// 仅群主有权限调用。
  ///
  /// Param [groupId]   群组 ID。
  /// Param [members]   要从黑名单中移除的用户列表。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> unblockMembers(
    String groupId,
    List<String> members,
  ) async {
    try {
      Map req = {'groupId': groupId, 'members': members};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.unblockMembers, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @Deprecated('Use [updateGroupName] instead')
  Future<void> changeGroupName(
    String groupId,
    String name,
  ) async {
    try {
      Map req = {'name': name, 'groupId': groupId};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.updateGroupSubject, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Changes the group name.
  /// Only the group owner can call this method.
  ///
  /// Param [groupId]   The group ID.
  /// Param [name]      The new group name.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 修改群组名称。
  /// 仅群主有权限调用。
  ///
  /// Param [groupId]   群组 ID。
  /// Param [name]      新的群组名称。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> updateGroupName(
    String groupId,
    String name,
  ) async {
    Map req = {'name': name, 'groupId': groupId};
    Map result = await platform_interface.Client.instance.groupManager
        .callNativeMethod(ChatMethodKeys.updateGroupSubject, req);
    try {
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @Deprecated('Use [updateGroupDesc] instead')
  Future<void> changeGroupDescription(
    String groupId,
    String desc,
  ) async {
    try {
      Map req = {'desc': desc, 'groupId': groupId};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.updateDescription, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Changes the group description.
  /// Only the group owner can call this method.
  ///
  /// Param [groupId]   The group ID.
  /// Param [desc]      The new group description.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 修改群组说明信息。
  /// 仅群主有权限调用。
  ///
  /// Param [groupId]   群组 ID。
  /// Param [desc]      新的群组说明信息。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> updateGroupDesc(
    String groupId,
    String desc,
  ) async {
    try {
      Map req = {'desc': desc, 'groupId': groupId};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.updateDescription, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Leaves a group. The group owner cannot leave, only can destroy the group.
  ///
  /// Param [groupId]  The group ID.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 退出群组，群主不能退出群，只能销毁群。
  ///
  /// Param [groupId]  群组 ID。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> leaveGroup(String groupId) async {
    try {
      Map req = {'groupId': groupId};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.leaveGroup, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Destroys a group.
  /// Only the group owner can call this method.
  ///
  /// Param [groupId]  The group ID.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 解散群组。
  /// 仅群主有权限调用。
  ///
  /// Param [groupId]  群组 ID。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> destroyGroup(String groupId) async {
    try {
      Map req = {'groupId': groupId};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.destroyGroup, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Blocks group messages. The server will no longer send messages from this group to the user.
  /// The group owner cannot block group messages.
  ///
  /// Param [groupId]  The ID of the group to block.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 屏蔽群消息，服务器不再发送此群的消息给用户，群主不能屏蔽群消息。
  ///
  /// Param [groupId]  要屏蔽的群组 ID。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> blockGroup(String groupId) async {
    try {
      Map req = {'groupId': groupId};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.blockGroup, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Unblocks group messages.
  ///
  /// Param [groupId]  The ID of the group to unblock.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 取消屏蔽群消息。
  ///
  /// Param [groupId]  要取消屏蔽的群组 ID。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> unblockGroup(String groupId) async {
    try {
      Map req = {'groupId': groupId};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.unblockGroup, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Changes the group owner.
  /// Only the group owner can call this method.
  ///
  /// Param [groupId]    The group ID.
  /// Param [newOwner]   The new group owner.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 转让群主。
  /// 仅群主有权限调用。
  ///
  /// Param [groupId]    群组 ID。
  /// Param [newOwner]   新群主。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> changeOwner(
    String groupId,
    String newOwner,
  ) async {
    try {
      Map req = {'groupId': groupId, 'owner': newOwner};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.updateGroupOwner, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Adds a group administrator.
  /// Only the group owner can call this method.
  ///
  /// Param [groupId]    The group ID.
  /// Param [memberId]   The user ID to be added as admin.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 添加群组管理员。
  /// 仅群主有权限调用。
  ///
  /// Param [groupId]    群组 ID。
  /// Param [memberId]   要设为管理员的用户 ID。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> addAdmin(
    String groupId,
    String memberId,
  ) async {
    Map req = {'groupId': groupId, 'admin': memberId};
    Map result = await platform_interface.Client.instance.groupManager
        .callNativeMethod(ChatMethodKeys.addAdmin, req);
    try {
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Removes a group administrator.
  /// Only the group owner can call this method.
  ///
  /// Param [groupId]   The group ID.
  /// Param [adminId]   The administrator ID to be removed.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 移除群组管理员。
  /// 仅群主有权限调用。
  ///
  /// Param [groupId]   群组 ID。
  /// Param [adminId]   要移除的管理员 ID。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> removeAdmin(
    String groupId,
    String adminId,
  ) async {
    try {
      Map req = {'groupId': groupId, 'admin': adminId};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.removeAdmin, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Mutes group members.
  /// Only the group owner and admins can call this method.
  ///
  /// Param [groupId]   The group ID.
  /// Param [members]   The list of members to be muted.
  /// Param [duration]  The mute duration in milliseconds.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 将群成员禁言。
  /// 仅群主和管理员有权限调用。
  ///
  /// Param [groupId]   群组 ID。
  /// Param [members]   要禁言的成员列表。
  /// Param [duration]  禁言时长，单位毫秒。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> muteMembers(
    String groupId,
    List<String> members, {
    int duration = -1,
  }) async {
    try {
      Map req = {'groupId': groupId, 'members': members, 'duration': duration};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.muteMembers, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Unmutes group members.
  /// Only the group owner and admins can call this method.
  ///
  /// Param [groupId]   The group ID.
  /// Param [members]   The list of members to be unmuted.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 解除群成员禁言。
  /// 仅群主和管理员有权限调用。
  ///
  /// Param [groupId]   群组 ID。
  /// Param [members]   要解除禁言的成员列表。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> unMuteMembers(
    String groupId,
    List<String> members,
  ) async {
    try {
      Map req = {'groupId': groupId, 'members': members};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.unMuteMembers, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Mutes all group members.
  /// Only the group owner and admins can call this method.
  ///
  /// Param [groupId]  The group ID.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 设置全员禁言。
  /// 仅群主和管理员有权限调用。
  ///
  /// Param [groupId]  群组 ID。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> muteAllMembers(String groupId) async {
    try {
      Map req = {'groupId': groupId};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.muteAllMembers, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Unmutes all group members.
  /// Only the group owner and admins can call this method.
  ///
  /// Param [groupId]  The group ID.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 解除全员禁言。
  /// 仅群主和管理员有权限调用。
  ///
  /// Param [groupId]  群组 ID。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> unMuteAllMembers(String groupId) async {
    try {
      Map req = {'groupId': groupId};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.unMuteAllMembers, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Adds members to the group allowlist.
  /// Only the group owner and admins can call this method.
  ///
  /// Param [groupId]   The group ID.
  /// Param [members]   The list of members to be added to the allowlist.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 添加群成员到白名单。
  /// 仅群主和管理员有权限调用。
  ///
  /// Param [groupId]   群组 ID。
  /// Param [members]   要添加到白名单的成员列表。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> addAllowList(
    String groupId,
    List<String> members,
  ) async {
    try {
      Map req = {'groupId': groupId, 'members': members};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.addWhiteList, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Removes members from the group allowlist.
  /// Only the group owner and admins can call this method.
  ///
  /// Param [groupId]   The group ID.
  /// Param [members]   The list of members to be removed from the allowlist.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从白名单中移除群成员。
  /// 仅群主和管理员有权限调用。
  ///
  /// Param [groupId]   群组 ID。
  /// Param [members]   要从白名单中移除的成员列表。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> removeAllowList(
    String groupId,
    List<String> members,
  ) async {
    try {
      Map req = {'groupId': groupId, 'members': members};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.removeWhiteList, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Uploads group shared files.
  ///
  /// Param [groupId]    The group ID.
  /// Param [filePath]   The local path of the file to upload.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 上传群共享文件。
  ///
  /// Param [groupId]    群组 ID。
  /// Param [filePath]   要上传的文件本地路径。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> uploadGroupSharedFile(
    String groupId,
    String filePath,
  ) async {
    try {
      Map req = {'groupId': groupId, 'filePath': filePath};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.uploadGroupSharedFile, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Downloads group shared files.
  ///
  /// Param [groupId]   The group ID.
  /// Param [fileId]    The shared file ID.
  /// Param [savePath]  The local save path of the file.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 下载群共享文件。
  ///
  /// Param [groupId]   群组 ID。
  /// Param [fileId]    共享文件 ID。
  /// Param [savePath]  文件本地保存路径。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> downloadGroupSharedFile({
    required String groupId,
    required String fileId,
    required String savePath,
  }) async {
    try {
      Map req = {'groupId': groupId, 'fileId': fileId, 'savePath': savePath};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.downloadGroupSharedFile, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Removes group shared files.
  ///
  /// Param [groupId]   The group ID.
  /// Param [fileId]    The shared file ID to be removed.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 删除群共享文件。
  ///
  /// Param [groupId]   群组 ID。
  /// Param [fileId]    要删除的共享文件 ID。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> removeGroupSharedFile(
    String groupId,
    String fileId,
  ) async {
    Map req = {'groupId': groupId, 'fileId': fileId};
    Map result = await platform_interface.Client.instance.groupManager
        .callNativeMethod(ChatMethodKeys.removeGroupSharedFile, req);
    try {
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Updates the group announcement.
  /// Only the group owner and admins can call this method.
  ///
  /// Param [groupId]        The group ID.
  /// Param [announcement]   The new group announcement.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 修改群公告。
  /// 仅群主和管理员有权限调用。
  ///
  /// Param [groupId]        群组 ID。
  /// Param [announcement]   新的群公告内容。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> updateGroupAnnouncement(
    String groupId,
    String announcement,
  ) async {
    try {
      Map req = {'groupId': groupId, 'announcement': announcement};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.updateGroupAnnouncement, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Updates group extension information.
  /// Only the group owner can call this method.
  ///
  /// Param [groupId]     The group ID.
  /// Param [extension]   The group extension content.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 修改群扩展信息。
  /// 仅群主有权限调用。
  ///
  /// Param [groupId]     群组 ID。
  /// Param [extension]   群扩展信息。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> updateGroupExtension(
    String groupId,
    String extension,
  ) async {
    try {
      Map req = {'groupId': groupId, 'ext': extension};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.updateGroupExt, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Joins a public group. The group style should be ChatGroupStylePublicOpenJoin.
  ///
  /// Param [groupId]   The ID of the public group to join.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 加入一个公开群组，群类型应该是 ChatGroupStylePublicOpenJoin。
  ///
  /// Param [groupId]   要加入的公开群组 ID。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> joinPublicGroup(
    String groupId,
  ) async {
    try {
      Map req = {'groupId': groupId};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.joinPublicGroup, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Requests to join a public group that requires approval.
  /// The group style should be PublicJoinNeedApproval.
  ///
  /// Param [groupId]   The public group ID.
  /// Param [reason]    The reason message for joining request.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 申请加入一个需批准的公开群组，群类型应该是 PublicJoinNeedApproval。
  ///
  /// Param [groupId]   公开群组的 ID。
  /// Param [reason]    请求加入的原因信息。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> requestToJoinPublicGroup(
    String groupId, {
    String? reason,
  }) async {
    try {
      Map req = {'groupId': groupId};
      req.putIfNotNull('reason', reason);
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.requestToJoinPublicGroup, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Approves a group join application.
  /// Only the group owner can call this method.
  ///
  /// Param [groupId]    The group ID.
  /// Param [username]   The applicant's username.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 批准入群申请。
  /// 仅群主有权限调用。
  ///
  /// Param [groupId]    所申请的群组 ID。
  /// Param [username]   申请人用户名。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> acceptJoinApplication(
    String groupId,
    String username,
  ) async {
    try {
      Map req = {'groupId': groupId, 'userId': username};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.acceptJoinApplication, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Declines a group join application.
  /// Only the group owner can call this method.
  ///
  /// Param [groupId]    The group ID.
  /// Param [username]   The applicant's username.
  /// Param [reason]     The reason for declining the application.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 拒绝入群申请。
  /// 仅群主有权限调用。
  ///
  /// Param [groupId]    被拒绝的群组 ID。
  /// Param [username]   申请人用户名。
  /// Param [reason]     拒绝理由。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> declineJoinApplication(
    String groupId,
    String username, {
    String? reason,
  }) async {
    try {
      Map req = {'groupId': groupId, 'userId': username};
      req.putIfNotNull('reason', reason);

      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.declineJoinApplication, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Accepts a group invitation.
  ///
  /// Param [groupId]   The group ID to accept.
  /// Param [inviter]   The user who sent the invitation.
  ///
  /// **Returns** The accepted group instance.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 接受入群邀请。
  ///
  /// Param [groupId]   接受的群组 ID。
  /// Param [inviter]   邀请者。
  ///
  /// **Return** 接受的群组实例。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<ChatGroup> acceptInvitation(
    String groupId,
    String inviter,
  ) async {
    try {
      Map req = {'groupId': groupId, 'inviter': inviter};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.acceptInvitationFromGroup, req);
      ChatError.hasErrorFromResult(result);
      return ChatGroup.fromJson(result[ChatMethodKeys.acceptInvitationFromGroup]);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Declines a group invitation.
  ///
  /// Param [groupId]   The group ID to decline.
  /// Param [inviter]   The user who sent the invitation.
  /// Param [reason]    The reason for declining the invitation.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 拒绝入群邀请。
  ///
  /// Param [groupId]   被拒绝的群组 ID。
  /// Param [inviter]   邀请人。
  /// Param [reason]    拒绝理由。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> declineInvitation({
    required String groupId,
    required String inviter,
    String? reason,
  }) async {
    try {
      Map req = {'groupId': groupId, 'inviter': inviter};
      req.putIfNotNull('reason', reason);
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.declineInvitationFromGroup, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Set group member custom attributes.
  ///
  /// Param [groupId]     Group ID
  /// Param [attributes]  Custom attributes map (key-value)
  /// Param [userId]      Target user ID to set attributes
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 设置群成员自定义属性。
  ///
  /// Param [groupId]     群组 ID
  /// Param [attributes]  自定义属性键值对
  /// Param [userId]      要设置属性的用户 ID
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> setMemberAttributes({
    required String groupId,
    required Map<String, String> attributes,
    String? userId,
  }) async {
    try {
      Map req = {
        'groupId': groupId,
      };
      req.putIfNotNull('userId', userId);
      req.putIfNotNull('attributes', attributes);
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.setMemberAttributesFromGroup, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Removes group member custom attributes.
  ///
  /// Param [groupId]     Group ID
  /// Param [keys]        The keys of the attributes to be removed.
  /// Param [userId]      Target user ID to remove attributes
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 删除群成员自定义属性。
  ///
  /// Param [groupId]     群组 ID
  /// Param [keys]        要删除的属性键列表
  /// Param [userId]      要设置属性的用户 ID
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError].
  /// ~end
  Future<void> removeMemberAttributes({
    required String groupId,
    required List<String> keys,
    String? userId,
  }) async {
    try {
      Map req = {
        'groupId': groupId,
      };
      req.putIfNotNull('userId', userId);
      req.putIfNotNull('keys', keys);
      Map result = await platform_interface.Client.instance.groupManager.callNativeMethod(
          ChatMethodKeys.removeMemberAttributesFromGroup, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets all custom attributes of a group member.
  ///
  /// Param [groupId]    The group ID.
  /// Param [userId]     The user ID of the target group member.
  ///
  /// **Returns** The custom attributes map of the group member.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 获取单个群成员所有自定义属性。
  ///
  /// Param [groupId]    群组 ID。
  /// Param [userId]     要获取属性的群成员用户 ID。
  ///
  /// **Return** 群成员自定义属性键值对。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<Map<String, String>> fetchMemberAttributes({
    required String groupId,
    String? userId,
  }) async {
    try {
      Map req = {'groupId': groupId};
      req.putIfNotNull('userId', userId);
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.fetchMemberAttributesFromGroup, req);
      ChatError.hasErrorFromResult(result);
      Map<String, String> ret = {};
      result[ChatMethodKeys.fetchMemberAttributesFromGroup]
          .forEach((key, value) {
        ret[key] = value;
      });
      return ret;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets custom attributes of multiple group members by attribute keys.
  ///
  /// Param [groupId]    The group ID.
  /// Param [userIds]    The list of user IDs of group members (max 10 users).
  /// Param [keys]       The list of attribute keys to retrieve.
  ///
  /// **Returns** Member attributes in format: { userId: { key: value } }.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 根据指定的属性 key 获取多个群成员的自定义属性。
  ///
  /// Param [groupId]    群组 ID。
  /// Param [userIds]    要获取属性的群成员用户 ID 列表（最多 10 个）。
  /// Param [keys]       要获取的自定义属性 key 列表。
  ///
  /// **Return** 群成员属性，格式为 { 用户ID: { 属性键值对 } }。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<Map<String, Map<String, String>>> fetchMembersAttributes({
    required String groupId,
    required List<String> userIds,
    List<String>? keys,
  }) async {
    try {
      Map req = {'groupId': groupId, 'userIds': userIds};
      req.putIfNotNull("keys", keys);
      Map result = await platform_interface.Client.instance.groupManager.callNativeMethod(
          ChatMethodKeys.fetchMembersAttributesFromGroup, req);
      ChatError.hasErrorFromResult(result);
      var map = result[ChatMethodKeys.fetchMembersAttributesFromGroup];
      Map<String, Map<String, String>> ret = {};
      if (map is Map) {
        for (var element in map.keys) {
          if (map[element] is Map) {
            Map<String, String> value =
                Map<String, String>.from(map[element] ?? {});
            ret[element] = value;
          }
        }
      }
      return ret;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the number of groups joined by the current user from the server.
  ///
  /// **Returns** The count of joined groups.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取当前用户已加入的群组数量。
  ///
  /// **Return** 已加入的群组数量。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<int> fetchJoinedGroupCount() async {
    try {
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.fetchJoinedGroupCount);
      ChatError.hasErrorFromResult(result);
      int count = result[ChatMethodKeys.fetchJoinedGroupCount];
      return count;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Checks whether the current user is in the group mute list.
  ///
  /// Param [groupId]   The group ID.
  ///
  /// **Returns** True if current user is muted, false otherwise.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 查看自己是否在群组禁言名单中。
  ///
  /// Param [groupId]   群组 ID。
  ///
  /// **Return** 若当前用户在禁言列表中返回 true，否则返回 false。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<bool> isMemberInGroupMuteList(String groupId) async {
    try {
      Map req = {'groupId': groupId};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.isMemberInGroupMuteList, req);
      ChatError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.isMemberInGroupMuteList);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Clears all groups of the current user from the local database.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 清理数据库中当前用户的所有群组。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<void> clearAllGroupsFromLocal() async {
    Map result = await platform_interface.Client.instance.groupManager
        .callNativeMethod(ChatMethodKeys.clearAllGroupsFromDB);
    try {
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the list of group members from the server.
  ///
  /// Param [groupId]   The group ID.
  /// Param [cursor]    The pagination cursor. Pass null for the first call.
  /// Param [limit]     The maximum number of members to fetch per page.
  ///
  /// **Returns** ChatCursorResult containing group member list and next page cursor.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 获取群组成员列表。
  ///
  /// Param [groupId]   群组 ID。
  /// Param [cursor]    分页游标，首次调用传空，下次使用上次返回的游标。
  /// Param [limit]     每页获取的成员数量，默认 20 条。
  ///
  /// **Return** 包含群成员信息列表和下一页游标的分页结果。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<ChatCursorResult<GroupMemberInfo>> fetchGroupMembersInfo({
    required String groupId,
    String? cursor,
    int limit = 20,
  }) async {
    try {
      Map req = {
        "groupId": groupId,
        "limit": limit,
      };

      req.putIfNotNull('cursor', cursor);

      Map result = await platform_interface.Client.instance.groupManager.callNativeMethod(
        ChatMethodKeys.fetchGroupMembersInfo,
        req,
      );
      ChatError.hasErrorFromResult(result);
      return ChatCursorResult<GroupMemberInfo>.fromJson(
          result[ChatMethodKeys.fetchGroupMembersInfo],
          dataItemCallback: (value) {
        return GroupMemberInfo.fromJson(value);
      });
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Changes the group avatar.
  /// Only the group owner can call this method.
  ///
  /// Param [groupId]     The group ID.
  /// Param [avatarUrl]   The new group avatar URL.
  ///
  /// **Returns** The updated group instance.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 更改群组头像。
  /// 仅群主有权限调用。
  ///
  /// Param [groupId]     群组 ID。
  /// Param [avatarUrl]   新的群组头像 URL。
  ///
  /// **Return** 更新后的群组实例。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<ChatGroup> updateGroupAvatar({
    required String groupId,
    required String avatarUrl,
  }) async {
    try {
      Map req = {
        "groupId": groupId,
        "avatarUrl": avatarUrl,
      };
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.updateGroupAvatar, req);
      ChatError.hasErrorFromResult(result);
      return ChatGroup.fromJson(result[ChatMethodKeys.updateGroupAvatar]);
    } catch (e) {
      rethrow;
    }
  }

  // 4.22.0

  /// ~english
  /// Updates the group namecard of the current user in a group.
  ///
  /// Param [groupId]   The group ID.
  ///
  /// Param [namecard]  The new group namecard. Pass `null` to remove the group namecard.
  ///
  /// **Returns** None.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 更新当前用户在群组中的群名片。
  ///
  /// Param [groupId]   群组 ID。
  ///
  /// Param [namecard]  新的群名片，传 `null` 表示移除群名片。
  ///
  /// **Return** 无。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<void> updateGroupNamecard({
    required String groupId,
    String? namecard,
  }) async {
    try {
      Map req = {'groupId': groupId};
      req.putIfNotNull('namecard', namecard);
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.updateGroupNamecard, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the group namecard of a member in a group.
  ///
  /// Param [groupId]   The group ID.
  ///
  /// Param [userId]    The user ID of the group member.
  ///
  /// **Returns** The group namecard of the member, `null` if the member has no group namecard.
  ///
  /// **Throws** Exception description, see [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 获取群成员的群名片。
  ///
  /// Param [groupId]   群组 ID。
  ///
  /// Param [userId]    群成员的用户 ID。
  ///
  /// **Return** 群成员的群名片，成员未设置群名片时返回 `null`。
  ///
  /// **Throws** 如果有异常会在这里抛出，包含错误码和错误描述，详见 [ChatError]。
  /// ~end
  Future<String?> getGroupNamecard({
    required String groupId,
    required String userId,
  }) async {
    try {
      Map req = {'groupId': groupId, 'userId': userId};
      Map result = await platform_interface.Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.getGroupNamecard, req);
      ChatError.hasErrorFromResult(result);
      return result[ChatMethodKeys.getGroupNamecard]?["namecard"];
    } catch (e) {
      rethrow;
    }
  }
}
