import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk/src/tools/em_extension.dart';
import 'package:im_flutter_sdk/src/tools/em_log.dart';
import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';

/// ~english
/// The group manager class, which manages group creation and deletion, user joining and exiting the group, etc.
/// ~end
///
/// ~chinese
/// 群组管理类，用于管理群组的创建，删除及成员管理等操作。
/// ~end
class EMGroupManager {
  final Map<String, EMGroupEventHandler> _eventHandlesMap = {};

  EMGroupManager() {
    Client.instance.groupManager.updateNativeHandler((MethodCall call) async {
      EMLog.d("${call.method}: arguments: ${call.arguments}");
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
        case EMGroupChangeEvent.ON_INVITATION_RECEIVED:
          String groupId = map['groupId'];
          String? groupName = map['groupName'];
          String inviter = map['inviter'];
          String? reason = map['reason'];
          element.onInvitationReceivedFromGroup
              ?.call(groupId, groupName, inviter, reason);
          break;
        case EMGroupChangeEvent.ON_INVITATION_ACCEPTED:
          String groupId = map['groupId'];
          String invitee = map['invitee'];
          String? reason = map['reason'];
          element.onInvitationAcceptedFromGroup?.call(groupId, invitee, reason);
          break;
        case EMGroupChangeEvent.ON_INVITATION_DECLINED:
          String groupId = map['groupId'];
          String invitee = map['invitee'];
          String? reason = map['reason'];
          element.onInvitationDeclinedFromGroup?.call(groupId, invitee, reason);
          break;
        case EMGroupChangeEvent.ON_AUTO_ACCEPT_INVITATION:
          String groupId = map['groupId'];
          String inviter = map['inviter'];
          String? inviteMessage = map['inviteMessage'];
          element.onAutoAcceptInvitationFromGroup
              ?.call(groupId, inviter, inviteMessage);
          break;
        case EMGroupChangeEvent.ON_USER_REMOVED:
          String groupId = map['groupId'];
          String? groupName = map['groupName'];
          element.onUserRemovedFromGroup?.call(groupId, groupName);
          break;
        case EMGroupChangeEvent.ON_REQUEST_TO_JOIN_RECEIVED:
          String groupId = map['groupId'];
          String? groupName = map['groupName'];
          String applicant = map['applicant'];
          String? reason = map['reason'];
          element.onRequestToJoinReceivedFromGroup
              ?.call(groupId, groupName, applicant, reason);
          break;
        case EMGroupChangeEvent.ON_REQUEST_TO_JOIN_DECLINED:
          String groupId = map['groupId'];
          String? groupName = map['groupName'];
          String? applicant = map['applicant'];
          String? reason = map['reason'];
          String? decliner = map['decliner'];
          element.onRequestToJoinDeclinedFromGroup
              ?.call(groupId, groupName, decliner, reason, applicant);
          break;
        case EMGroupChangeEvent.ON_REQUEST_TO_JOIN_ACCEPTED:
          String groupId = map['groupId'];
          String? groupName = map['groupName'];
          String accepter = map['accepter'];
          element.onRequestToJoinAcceptedFromGroup
              ?.call(groupId, groupName, accepter);
          break;
        case EMGroupChangeEvent.ON_GROUP_DESTROYED:
          String groupId = map['groupId'];
          String? groupName = map['groupName'];
          element.onGroupDestroyed?.call(groupId, groupName);
          break;
        case EMGroupChangeEvent.ON_MUTE_LIST_ADDED:
          String groupId = map['groupId'];
          List<String> mutes = List.from(map['mutes'] ?? []);
          int? muteExpire = map['muteExpire'];
          element.onMuteListAddedFromGroup?.call(groupId, mutes, muteExpire);
          break;
        case EMGroupChangeEvent.ON_MUTE_LIST_REMOVED:
          String groupId = map['groupId'];
          List<String> mutes = List.from(map['mutes'] ?? []);
          element.onMuteListRemovedFromGroup?.call(groupId, mutes);
          break;
        case EMGroupChangeEvent.ON_ADMIN_ADDED:
          String groupId = map['groupId'];
          String administrator = map['administrator'];
          element.onAdminAddedFromGroup?.call(groupId, administrator);
          break;
        case EMGroupChangeEvent.ON_ADMIN_REMOVED:
          String groupId = map['groupId'];
          String administrator = map['administrator'];
          element.onAdminRemovedFromGroup?.call(groupId, administrator);
          break;
        case EMGroupChangeEvent.ON_OWNER_CHANGED:
          String groupId = map['groupId'];
          String newOwner = map['newOwner'];
          String oldOwner = map['oldOwner'];
          element.onOwnerChangedFromGroup?.call(groupId, newOwner, oldOwner);
          break;
        case EMGroupChangeEvent.ON_MEMBER_JOINED:
          String groupId = map['groupId'];
          String member = map['member'];
          element.onMemberJoinedFromGroup?.call(groupId, member);
          break;
        case EMGroupChangeEvent.ON_MEMBER_EXITED:
          String groupId = map['groupId'];
          String member = map['member'];
          element.onMemberExitedFromGroup?.call(groupId, member);
          break;
        case EMGroupChangeEvent.ON_ANNOUNCEMENT_CHANGED:
          String groupId = map['groupId'];
          String? announcement = map['announcement'];
          element.onAnnouncementChangedFromGroup?.call(groupId, announcement);
          break;
        case EMGroupChangeEvent.ON_SHARED_FILE_ADDED:
          String groupId = map['groupId'];
          EMGroupSharedFile sharedFile =
              EMGroupSharedFile.fromJson(map['sharedFile']);
          element.onSharedFileAddedFromGroup?.call(groupId, sharedFile);
          break;
        case EMGroupChangeEvent.ON_SHARED_FILE__DELETED:
          String groupId = map['groupId'];
          String fileId = map['fileId'];
          element.onSharedFileDeletedFromGroup?.call(groupId, fileId);
          break;
        case EMGroupChangeEvent.ON_WHITE_LIST_ADDED:
          String groupId = map["groupId"];
          List<String> members = List.from(map['whitelist'] ?? []);
          element.onAllowListAddedFromGroup?.call(groupId, members);
          break;
        case EMGroupChangeEvent.ON_WHITE_LIST_REMOVED:
          String groupId = map["groupId"];
          List<String> members = List.from(map['whitelist'] ?? []);
          element.onAllowListRemovedFromGroup?.call(groupId, members);
          break;
        case EMGroupChangeEvent.ON_ALL_MEMBER_MUTE_STATE_CHANGED:
          String groupId = map["groupId"];
          bool isAllMuted = map["isMuted"] as bool;
          element.onAllGroupMemberMuteStateChanged?.call(groupId, isAllMuted);
          break;
        case EMGroupChangeEvent.ON_SPECIFICATION_DID_UPDATE:
          EMGroup group = EMGroup.fromJson(map["group"]);
          element.onSpecificationDidUpdate?.call(group);
          break;
        case EMGroupChangeEvent.ON_STATE_CHANGED:
          String groupId = map["groupId"];
          bool isDisable = map["isDisabled"] as bool;
          element.onDisableChanged?.call(groupId, isDisable);
          break;
        case EMGroupChangeEvent.ON_ATTRIBUTES_CHANGED_OF_MEMBER:
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
      }
    }
  }

  /// ~english
  /// Adds the group event handler. After calling this method, you can handle for new group event when they arrive.
  ///
  /// Param [identifier] The custom handler identifier, is used to find the corresponding handler.
  ///
  /// Param [handler] The handle for group event. See [EMGroupEventHandler].
  /// ~end
  ///
  /// ~chinese
  /// 添加群组事件监听。
  ///
  /// Param [identifier] 自定义监听对应 ID，可用于查找或删除监听。
  ///
  /// Param [handler] 群组事件监听，请见 [EMGroupEventHandler].
  /// ~end
  void addEventHandler(
    String identifier,
    EMGroupEventHandler handler,
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
  EMGroupEventHandler? getEventHandler(String identifier) {
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

  Future<EMGroup?> getGroupWithId(String groupId) async {
    try {
      Map req = {'groupId': groupId};
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.getGroupWithId, req);
      EMError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.getGroupWithId)) {
        return EMGroup.fromJson(result[ChatMethodKeys.getGroupWithId]);
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<EMGroup>> getJoinedGroups() async {
    try {
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.getJoinedGroups);
      EMError.hasErrorFromResult(result);
      List<EMGroup> list = [];
      result[ChatMethodKeys.getJoinedGroups]
          ?.forEach((element) => list.add(EMGroup.fromJson(element)));
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<EMGroup>> fetchJoinedGroupsFromServer({
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.getJoinedGroupsFromServer, req);
      EMError.hasErrorFromResult(result);
      List<EMGroup> list = [];
      result[ChatMethodKeys.getJoinedGroupsFromServer]
          ?.forEach((element) => list.add(EMGroup.fromJson(element)));
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<EMCursorResult<EMGroupInfo>> fetchPublicGroupsFromServer({
    int pageSize = 200,
    String? cursor,
  }) async {
    try {
      Map req = {'pageSize': pageSize};
      req.putIfNotNull("cursor", cursor);
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.getPublicGroupsFromServer, req);
      EMError.hasErrorFromResult(result);
      return EMCursorResult<EMGroupInfo>.fromJson(
          result[ChatMethodKeys.getPublicGroupsFromServer],
          dataItemCallback: (value) {
        return EMGroupInfo.fromJson(value);
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<EMGroup> createGroup({
    String? groupName,
    String? avatarUrl,
    String? desc,
    List<String>? inviteMembers,
    String? inviteReason,
    required EMGroupOptions options,
  }) async {
    try {
      Map req = {'options': options.toJson()};
      req.putIfNotNull("groupName", groupName);
      req.putIfNotNull("avatarUrl", avatarUrl);
      req.putIfNotNull("desc", desc);
      req.putIfNotNull("inviteMembers", inviteMembers);
      req.putIfNotNull("inviteReason", inviteReason);

      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.createGroup, req);
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.createGroup]);
    } catch (e) {
      rethrow;
    }
  }

  Future<EMGroup> fetchGroupInfoFromServer(
    String groupId, {
    @Deprecated('') bool? fetchMembers,
  }) async {
    Map req = {"groupId": groupId};
    req.putIfNotNull("fetchMembers", fetchMembers);
    Map result = await Client.instance.groupManager
        .callNativeMethod(ChatMethodKeys.getGroupSpecificationFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(
          result[ChatMethodKeys.getGroupSpecificationFromServer]);
    } catch (e) {
      rethrow;
    }
  }

  Future<EMCursorResult<String>> fetchMemberListFromServer(
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
      Map result = await Client.instance.groupManager.callNativeMethod(
        ChatMethodKeys.getGroupMemberListFromServer,
        req,
      );
      EMError.hasErrorFromResult(result);
      return EMCursorResult<String>.fromJson(
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.getGroupBlockListFromServer, req);
      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.getGroupMuteListFromServer, req);
      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.getGroupWhiteListFromServer, req);
      List<String> list = [];
      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.isMemberInWhiteListFromServer, req);
      EMError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.isMemberInWhiteListFromServer);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<EMGroupSharedFile>> fetchGroupFileListFromServer(
    String groupId, {
    int pageSize = 200,
    int pageNum = 1,
  }) async {
    try {
      Map req = {'groupId': groupId, 'pageNum': pageNum, 'pageSize': pageSize};
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.getGroupFileListFromServer, req);
      EMError.hasErrorFromResult(result);
      List<EMGroupSharedFile> list = [];
      result[ChatMethodKeys.getGroupFileListFromServer]?.forEach((element) {
        list.add(EMGroupSharedFile.fromJson(element));
      });
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> fetchAnnouncementFromServer(String groupId) async {
    try {
      Map req = {'groupId': groupId};
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.getGroupAnnouncementFromServer, req);
      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.addMembers, req);
      EMError.hasErrorFromResult(result);
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

      Map result = await Client.instance.groupManager.callNativeMethod(
        ChatMethodKeys.inviterUser,
        req,
      );

      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.removeMembers, req);
      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.blockMembers, req);
      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.unblockMembers, req);
      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.updateGroupSubject, req);
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateGroupName(
    String groupId,
    String name,
  ) async {
    Map req = {'name': name, 'groupId': groupId};
    Map result = await Client.instance.groupManager
        .callNativeMethod(ChatMethodKeys.updateGroupSubject, req);
    try {
      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.updateDescription, req);
      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.updateDescription, req);
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> leaveGroup(String groupId) async {
    try {
      Map req = {'groupId': groupId};
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.leaveGroup, req);
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> destroyGroup(String groupId) async {
    try {
      Map req = {'groupId': groupId};
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.destroyGroup, req);
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> blockGroup(String groupId) async {
    try {
      Map req = {'groupId': groupId};
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.blockGroup, req);
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unblockGroup(String groupId) async {
    try {
      Map req = {'groupId': groupId};
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.unblockGroup, req);
      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.updateGroupOwner, req);
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addAdmin(
    String groupId,
    String memberId,
  ) async {
    Map req = {'groupId': groupId, 'admin': memberId};
    Map result = await Client.instance.groupManager
        .callNativeMethod(ChatMethodKeys.addAdmin, req);
    try {
      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.removeAdmin, req);
      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.muteMembers, req);
      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.unMuteMembers, req);
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> muteAllMembers(String groupId) async {
    try {
      Map req = {'groupId': groupId};
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.muteAllMembers, req);
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unMuteAllMembers(String groupId) async {
    try {
      Map req = {'groupId': groupId};
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.unMuteAllMembers, req);
      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.addWhiteList, req);
      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.removeWhiteList, req);
      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.uploadGroupSharedFile, req);
      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.downloadGroupSharedFile, req);
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeGroupSharedFile(
    String groupId,
    String fileId,
  ) async {
    Map req = {'groupId': groupId, 'fileId': fileId};
    Map result = await Client.instance.groupManager
        .callNativeMethod(ChatMethodKeys.removeGroupSharedFile, req);
    try {
      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.updateGroupAnnouncement, req);
      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.updateGroupExt, req);
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> joinPublicGroup(
    String groupId,
  ) async {
    try {
      Map req = {'groupId': groupId};
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.joinPublicGroup, req);
      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.requestToJoinPublicGroup, req);
      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.acceptJoinApplication, req);
      EMError.hasErrorFromResult(result);
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

      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.declineJoinApplication, req);
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  Future<EMGroup> acceptInvitation(
    String groupId,
    String inviter,
  ) async {
    try {
      Map req = {'groupId': groupId, 'inviter': inviter};
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.acceptInvitationFromGroup, req);
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.acceptInvitationFromGroup]);
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.declineInvitationFromGroup, req);
      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.setMemberAttributesFromGroup, req);
      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager.callNativeMethod(
          ChatMethodKeys.removeMemberAttributesFromGroup, req);
      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.fetchMemberAttributesFromGroup, req);
      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager.callNativeMethod(
          ChatMethodKeys.fetchMembersAttributesFromGroup, req);
      EMError.hasErrorFromResult(result);
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
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.fetchJoinedGroupCount);
      EMError.hasErrorFromResult(result);
      int count = result[ChatMethodKeys.fetchJoinedGroupCount];
      return count;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isMemberInGroupMuteList(String groupId) async {
    try {
      Map req = {'groupId': groupId};
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.isMemberInGroupMuteList, req);
      EMError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.isMemberInGroupMuteList);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearAllGroupsFromLocal() async {
    Map result = await Client.instance.groupManager
        .callNativeMethod(ChatMethodKeys.clearAllGroupsFromDB);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  Future<EMCursorResult<GroupMemberInfo>> fetchGroupMembersInfo({
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

      Map result = await Client.instance.groupManager.callNativeMethod(
        ChatMethodKeys.fetchGroupMembersInfo,
        req,
      );
      EMError.hasErrorFromResult(result);
      return EMCursorResult<GroupMemberInfo>.fromJson(
          result[ChatMethodKeys.fetchGroupMembersInfo],
          dataItemCallback: (value) {
        return GroupMemberInfo.fromJson(value);
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<EMGroup> updateGroupAvatar({
    required String groupId,
    required String avatarUrl,
  }) async {
    try {
      Map req = {
        "groupId": groupId,
        "avatarUrl": avatarUrl,
      };
      Map result = await Client.instance.groupManager
          .callNativeMethod(ChatMethodKeys.updateGroupAvatar, req);
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.updateGroupAvatar]);
    } catch (e) {
      rethrow;
    }
  }
}
