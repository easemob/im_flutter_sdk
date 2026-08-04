import 'package:flutter/services.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:agora_chat_sdk/src/tools/chat_extension.dart';
import 'package:agora_chat_sdk/src/tools/chat_log.dart';
import 'package:agora_chat_sdk_interface/agora_chat_sdk_interface.dart' as platform_interface;

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
          element.onAllowListRemovedFromGroup?.call(groupId, members);
          break;
        case "onGroupMembersExited":
          String groupId = map["groupId"];
          List<String> members = List.from(map['userIds'] ?? []);
          element.onAllowListRemovedFromGroup?.call(groupId, members);
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

  Future<void> clearAllGroupsFromLocal() async {
    Map result = await platform_interface.Client.instance.groupManager
        .callNativeMethod(ChatMethodKeys.clearAllGroupsFromDB);
    try {
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

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
}
