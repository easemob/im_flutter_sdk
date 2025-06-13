import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';

class GroupManagerIOS extends GroupManager {
  @override
  Future<EMGroup?> getGroupWithId(String groupId) async {
    Map req = {'groupId': groupId};
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.getGroupWithId, req);
    try {
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

  @override
  Future<List<EMGroup>> getJoinedGroups() async {
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.getJoinedGroups);
    try {
      EMError.hasErrorFromResult(result);
      List<EMGroup> list = [];
      result[ChatMethodKeys.getJoinedGroups]
          ?.forEach((element) => list.add(EMGroup.fromJson(element)));
      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<EMGroup>> fetchJoinedGroupsFromServer({
    int pageSize = 20,
    int pageNum = 0,
    bool needMemberCount = false,
    bool needRole = false,
  }) async {
    Map req = {
      'pageSize': pageSize,
      'pageNum': pageNum,
      "needMemberCount": needMemberCount,
      "needRole": needRole,
    };
    Map result = await GroupChannel.invokeMethod(
        ChatMethodKeys.getJoinedGroupsFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      List<EMGroup> list = [];
      result[ChatMethodKeys.getJoinedGroupsFromServer]
          ?.forEach((element) => list.add(EMGroup.fromJson(element)));
      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<EMCursorResult<EMGroupInfo>> fetchPublicGroupsFromServer({
    int pageSize = 200,
    String? cursor,
  }) async {
    Map req = {'pageSize': pageSize};
    req.putIfNotNull("cursor", cursor);
    Map result = await GroupChannel.invokeMethod(
        ChatMethodKeys.getPublicGroupsFromServer, req);
    try {
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

  @override
  Future<EMGroup> createGroup({
    String? groupName,
    String? avatarUrl,
    String? desc,
    List<String>? inviteMembers,
    String? inviteReason,
    required EMGroupOptions options,
  }) async {
    Map req = {'options': options.toJson()};
    req.putIfNotNull("groupName", groupName);
    req.putIfNotNull("avatarUrl", avatarUrl);
    req.putIfNotNull("desc", desc);
    req.putIfNotNull("inviteMembers", inviteMembers);
    req.putIfNotNull("inviteReason", inviteReason);

    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.createGroup, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.createGroup]);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<EMGroup> fetchGroupInfoFromServer(
    String groupId, {
    bool fetchMembers = false,
  }) async {
    Map req = {"groupId": groupId, "fetchMembers": fetchMembers};
    Map result = await GroupChannel.invokeMethod(
        ChatMethodKeys.getGroupSpecificationFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(
          result[ChatMethodKeys.getGroupSpecificationFromServer]);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<EMCursorResult<String>> fetchMemberListFromServer(
    String groupId, {
    int pageSize = 200,
    String? cursor,
  }) async {
    Map req = {
      'groupId': groupId,
      'pageSize': pageSize,
    };
    req.putIfNotNull("cursor", cursor);
    Map result = await GroupChannel.invokeMethod(
      ChatMethodKeys.getGroupMemberListFromServer,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
      return EMCursorResult<String>.fromJson(
          result[ChatMethodKeys.getGroupMemberListFromServer],
          dataItemCallback: (value) => value);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<String>> fetchBlockListFromServer(
    String groupId, {
    int pageSize = 200,
    int pageNum = 1,
  }) async {
    Map req = {'groupId': groupId, 'pageNum': pageNum, 'pageSize': pageSize};
    Map result = await GroupChannel.invokeMethod(
        ChatMethodKeys.getGroupBlockListFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.getGroupBlockListFromServer]
              ?.cast<String>() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> fetchMuteListFromServer(
    String groupId, {
    int pageSize = 200,
    int pageNum = 1,
  }) async {
    Map req = {'groupId': groupId, 'pageNum': pageNum, 'pageSize': pageSize};
    Map result = await GroupChannel.invokeMethod(
        ChatMethodKeys.getGroupMuteListFromServer, req);
    try {
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

  @override
  Future<List<String>> fetchAllowListFromServer(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await GroupChannel.invokeMethod(
        ChatMethodKeys.getGroupWhiteListFromServer, req);
    try {
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

  @override
  Future<bool> isMemberInAllowListFromServer(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await GroupChannel.invokeMethod(
        ChatMethodKeys.isMemberInWhiteListFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.isMemberInWhiteListFromServer);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<EMGroupSharedFile>> fetchGroupFileListFromServer(
    String groupId, {
    int pageSize = 200,
    int pageNum = 1,
  }) async {
    Map req = {'groupId': groupId, 'pageNum': pageNum, 'pageSize': pageSize};
    Map result = await GroupChannel.invokeMethod(
        ChatMethodKeys.getGroupFileListFromServer, req);
    try {
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

  @override
  Future<String?> fetchAnnouncementFromServer(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await GroupChannel.invokeMethod(
        ChatMethodKeys.getGroupAnnouncementFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.getGroupAnnouncementFromServer];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addMembers(
    String groupId,
    List<String> members, {
    String? welcome,
  }) async {
    Map req = {'groupId': groupId, 'members': members};
    req.putIfNotNull("welcome", welcome);
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.addMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> inviterUser(
    String groupId,
    List<String> members, {
    String? reason,
  }) async {
    Map req = {
      'groupId': groupId,
      'members': members,
    };
    req.putIfNotNull("reason", reason);

    Map result = await GroupChannel.invokeMethod(
      ChatMethodKeys.inviterUser,
      req,
    );

    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeMembers(
    String groupId,
    List<String> members,
  ) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.removeMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> blockMembers(
    String groupId,
    List<String> members,
  ) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.blockMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> unblockMembers(
    String groupId,
    List<String> members,
  ) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.unblockMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @Deprecated('Use [updateGroupName] instead')
  @override
  Future<void> changeGroupName(
    String groupId,
    String name,
  ) async {
    Map req = {'name': name, 'groupId': groupId};
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.updateGroupSubject, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateGroupName(
    String groupId,
    String name,
  ) async {
    Map req = {'name': name, 'groupId': groupId};
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.updateGroupSubject, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @Deprecated('Use [updateGroupDesc] instead')
  @override
  Future<void> changeGroupDescription(
    String groupId,
    String desc,
  ) async {
    Map req = {'desc': desc, 'groupId': groupId};
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.updateDescription, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateGroupDesc(
    String groupId,
    String desc,
  ) async {
    Map req = {'desc': desc, 'groupId': groupId};
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.updateDescription, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> leaveGroup(String groupId) async {
    Map req = {'groupId': groupId};
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.leaveGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> destroyGroup(String groupId) async {
    Map req = {'groupId': groupId};
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.destroyGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> blockGroup(String groupId) async {
    Map req = {'groupId': groupId};
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.blockGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> unblockGroup(String groupId) async {
    Map req = {'groupId': groupId};
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.unblockGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> changeOwner(
    String groupId,
    String newOwner,
  ) async {
    Map req = {'groupId': groupId, 'owner': newOwner};
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.updateGroupOwner, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addAdmin(
    String groupId,
    String memberId,
  ) async {
    Map req = {'groupId': groupId, 'admin': memberId};
    Map result = await GroupChannel.invokeMethod(ChatMethodKeys.addAdmin, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeAdmin(
    String groupId,
    String adminId,
  ) async {
    Map req = {'groupId': groupId, 'admin': adminId};
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.removeAdmin, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> muteMembers(
    String groupId,
    List<String> members, {
    int duration = -1,
  }) async {
    Map req = {'groupId': groupId, 'members': members, 'duration': duration};
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.muteMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> unMuteMembers(
    String groupId,
    List<String> members,
  ) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.unMuteMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> muteAllMembers(String groupId) async {
    Map req = {'groupId': groupId};
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.muteAllMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> unMuteAllMembers(String groupId) async {
    Map req = {'groupId': groupId};
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.unMuteAllMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addAllowList(
    String groupId,
    List<String> members,
  ) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.addWhiteList, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeAllowList(
    String groupId,
    List<String> members,
  ) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.removeWhiteList, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> uploadGroupSharedFile(
    String groupId,
    String filePath,
  ) async {
    Map req = {'groupId': groupId, 'filePath': filePath};
    Map result = await GroupChannel.invokeMethod(
        ChatMethodKeys.uploadGroupSharedFile, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> downloadGroupSharedFile({
    required String groupId,
    required String fileId,
    required String savePath,
  }) async {
    Map req = {'groupId': groupId, 'fileId': fileId, 'savePath': savePath};
    Map result = await GroupChannel.invokeMethod(
        ChatMethodKeys.downloadGroupSharedFile, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeGroupSharedFile(
    String groupId,
    String fileId,
  ) async {
    Map req = {'groupId': groupId, 'fileId': fileId};
    Map result = await GroupChannel.invokeMethod(
        ChatMethodKeys.removeGroupSharedFile, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateGroupAnnouncement(
    String groupId,
    String announcement,
  ) async {
    Map req = {'groupId': groupId, 'announcement': announcement};
    Map result = await GroupChannel.invokeMethod(
        ChatMethodKeys.updateGroupAnnouncement, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateGroupExtension(
    String groupId,
    String extension,
  ) async {
    Map req = {'groupId': groupId, 'ext': extension};
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.updateGroupExt, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> joinPublicGroup(
    String groupId,
  ) async {
    Map req = {'groupId': groupId};
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.joinPublicGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> requestToJoinPublicGroup(
    String groupId, {
    String? reason,
  }) async {
    Map req = {'groupId': groupId};
    req.putIfNotNull('reason', reason);
    Map result = await GroupChannel.invokeMethod(
        ChatMethodKeys.requestToJoinPublicGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> acceptJoinApplication(
    String groupId,
    String username,
  ) async {
    Map req = {'groupId': groupId, 'userId': username};
    Map result = await GroupChannel.invokeMethod(
        ChatMethodKeys.acceptJoinApplication, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> declineJoinApplication(
    String groupId,
    String username, {
    String? reason,
  }) async {
    Map req = {'groupId': groupId, 'userId': username};
    req.putIfNotNull('reason', reason);

    Map result = await GroupChannel.invokeMethod(
        ChatMethodKeys.declineJoinApplication, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<EMGroup> acceptInvitation(
    String groupId,
    String inviter,
  ) async {
    Map req = {'groupId': groupId, 'inviter': inviter};
    Map result = await GroupChannel.invokeMethod(
        ChatMethodKeys.acceptInvitationFromGroup, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.acceptInvitationFromGroup]);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> declineInvitation({
    required String groupId,
    required String inviter,
    String? reason,
  }) async {
    Map req = {'groupId': groupId, 'inviter': inviter};
    req.putIfNotNull('reason', reason);
    Map result = await GroupChannel.invokeMethod(
        ChatMethodKeys.declineInvitationFromGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> setMemberAttributes({
    required String groupId,
    required Map<String, String> attributes,
    String? userId,
  }) async {
    Map req = {
      'groupId': groupId,
    };
    if (userId != null) {
      req.putIfNotNull('userId', userId);
    }
    req.putIfNotNull('attributes', attributes);
    Map result = await GroupChannel.invokeMethod(
        ChatMethodKeys.setMemberAttributesFromGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeMemberAttributes({
    required String groupId,
    required List<String> keys,
    String? userId,
  }) async {
    Map req = {
      'groupId': groupId,
    };
    if (userId != null) {
      req.putIfNotNull('userId', userId);
    }
    req.putIfNotNull('keys', keys);
    Map result = await GroupChannel.invokeMethod(
        ChatMethodKeys.removeMemberAttributesFromGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, String>> fetchMemberAttributes({
    required String groupId,
    String? userId,
  }) async {
    Map req = {'groupId': groupId};
    if (userId != null) {
      req.putIfNotNull('userId', userId);
    }
    Map result = await GroupChannel.invokeMethod(
        ChatMethodKeys.fetchMemberAttributesFromGroup, req);
    try {
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

  @override
  Future<Map<String, Map<String, String>>> fetchMembersAttributes({
    required String groupId,
    required List<String> userIds,
    List<String>? keys,
  }) async {
    Map req = {'groupId': groupId, 'userIds': userIds};
    req.putIfNotNull("keys", keys);
    Map result = await GroupChannel.invokeMethod(
        ChatMethodKeys.fetchMembersAttributesFromGroup, req);
    try {
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

  @override
  Future<int> fetchJoinedGroupCount() async {
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.fetchJoinedGroupCount);
    try {
      EMError.hasErrorFromResult(result);
      int count = result[ChatMethodKeys.fetchJoinedGroupCount];
      return count;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isMemberInGroupMuteList(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await GroupChannel.invokeMethod(
        ChatMethodKeys.isMemberInGroupMuteList, req);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.isMemberInGroupMuteList);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearAllGroupsFromLocal() async {
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.clearAllGroupsFromDB);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<EMCursorResult<GroupMemberInfo>> fetchGroupMembersInfo({
    required String groupId,
    String? cursor,
    int limit = 20,
  }) async {
    Map req = {
      "groupId": groupId,
      "limit": limit,
    };

    req.putIfNotNull('cursor', cursor);

    Map result = await GroupChannel.invokeMethod(
      ChatMethodKeys.fetchGroupMembersInfo,
      req,
    );
    try {
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

  @override
  Future<EMGroup> updateGroupAvatar({
    required String groupId,
    required String avatarUrl,
  }) async {
    Map req = {
      "groupId": groupId,
      "avatarUrl": avatarUrl,
    };
    Map result =
        await GroupChannel.invokeMethod(ChatMethodKeys.updateGroupAvatar, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.updateGroupAvatar]);
    } catch (e) {
      rethrow;
    }
  }
}
