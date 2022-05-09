import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'em_download_callback.dart';
import 'em_listeners.dart';
import 'internal/em_event_keys.dart';
import 'models/em_cursor_result.dart';
import 'models/em_error.dart';
import 'models/em_group.dart';
import 'models/em_group_info.dart';
import 'models/em_group_options.dart';
import 'models/em_group_shared_file.dart';
import 'tools/em_extension.dart';

import 'internal/chat_method_keys.dart';

///
/// The group manager class, which manages group creation and deletion, user joining and exiting the group, etc.
///
class EMGroupManager {
  static const _channelPrefix = 'com.chat.im';
  static const MethodChannel _channel = const MethodChannel(
      '$_channelPrefix/chat_group_manager', JSONMethodCodec());

  /// @nodoc
  EMGroupManager() {
    _channel.setMethodCallHandler((MethodCall call) async {
      Map? argMap = call.arguments;
      print('[EMGroupChange:]' + argMap.toString());
      if (call.method == ChatMethodKeys.onGroupChanged) {
        return _onGroupChanged(argMap);
      }
      return null;
    });
  }

  final _groupChangeListeners = [];

  ///
  /// Gets the group instance from the cache by group ID.
  ///
  /// Param [groupId] The group ID.
  ///
  /// **Return** The group instance. Returns null if the group does not exist.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<EMGroup?> getGroupWithId(String groupId) async {
    Map req = {'groupId': groupId};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.getGroupWithId, req);
    try {
      EMError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.getGroupWithId)) {
        return EMGroup.fromJson(result[ChatMethodKeys.getGroupWithId]);
      } else {
        return null;
      }
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets all groups of the current user from the cache.
  ///
  /// **Return** The group list.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<List<EMGroup>> getJoinedGroups() async {
    Map result = await _channel.invokeMethod(ChatMethodKeys.getJoinedGroups);
    EMError.hasErrorFromResult(result);
    List<EMGroup> list = [];
    result[ChatMethodKeys.getJoinedGroups]
        ?.forEach((element) => list.add(EMGroup.fromJson(element)));
    return list;
  }

  @Deprecated("Switch to using EMPushConfig#noDisturbGroupsFromServer instead.")
  Future<List<String>?> getGroupsWithoutNotice() async {
    Map result = await _channel
        .invokeMethod(ChatMethodKeys.getGroupsWithoutPushNotification);
    EMError.hasErrorFromResult(result);
    var list =
        result[ChatMethodKeys.getGroupsWithoutPushNotification]?.cast<String>();
    return list;
  }

  ///
  /// Gets all groups of the current user from the server.
  ///
  /// This method returns a group list which does not contain member information. If you want to update information of a group to include its member information, call {@link #fetchGroupInfoFromServer(String groupId)}.
  ///
  /// **Return** The list of groups that the current user joins.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<List<EMGroup>> fetchJoinedGroupsFromServer({
    int pageSize = 200,
    int pageNum = 1,
  }) async {
    Map req = {'pageSize': pageSize, 'pageNum': pageNum};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getJoinedGroupsFromServer, req);
    EMError.hasErrorFromResult(result);
    List<EMGroup> list = [];
    result[ChatMethodKeys.getJoinedGroupsFromServer]
        ?.forEach((element) => list.add(EMGroup.fromJson(element)));
    return list;
  }

  ///
  /// Gets public groups from the server with pagination.
  ///
  /// Param [pageSize] The number of public groups per page.
  ///
  /// Param [cursor] The cursor position from which to start to get data next time. Sets the parameter as null for the first time.
  ///
  /// **Return** The result of {@link EMCursorResult}, including the cursor for getting data next time and the group list.
  /// If `EMCursorResult.cursor` is an empty string (""), all data is fetched.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<EMCursorResult<EMGroupInfo>> fetchPublicGroupsFromServer({
    int pageSize = 200,
    String? cursor,
  }) async {
    Map req = {'pageSize': pageSize};
    req.setValueWithOutNull("cursor", cursor);
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getPublicGroupsFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMCursorResult<EMGroupInfo>.fromJson(
          result[ChatMethodKeys.getPublicGroupsFromServer],
          dataItemCallback: (value) {
        return EMGroupInfo.fromJson(value);
      });
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Creates a group instance.
  ///
  /// After the group is created, the data in the cache and database will be updated and multiple devices will receive the notification event and update the group data to the cache and database.
  /// You can set {@link com.EMMultiDeviceListener} to listen for the event. If an event occurs, the callback function
  /// {@link EMMultiDeviceListener#onGroupEvent(int, String, List)} is triggered, where the first parameter is the event which is
  /// {@link EMContactGroupEvent#GROUP_CREATE} for a group creation event.
  ///
  /// Param [groupName] The group name.
  ///
  /// Param [desc] The group description.
  ///
  /// Param [inviteMembers] The group member array. The group owner ID is optional.
  ///
  /// Param [inviteReason] The group joining invitation.
  ///
  /// Param [options] The options for creating a group. See {@link EMGroupOptions}.
  /// The options are as follows:
  /// - The maximum number of group members. The default value is 200.
  /// - The group style. See {@link EMGroupManager.EMGroupStyle}. The default value is {@link EMGroupStyle#PrivateOnlyOwnerInvite}.
  /// - Whether to ask for permission when inviting a user to join the group. The default value is `false`, indicating that invitees are automatically added to the group without their permission.
  /// - The group detail extensions.
  ///
  /// **Return** The created group instance.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<EMGroup> createGroup({
    String? groupName,
    String? desc,
    List<String>? inviteMembers,
    String? inviteReason,
    required EMGroupOptions options,
  }) async {
    Map req = {'options': options.toJson()};
    req.setValueWithOutNull("groupName", groupName);
    req.setValueWithOutNull("desc", desc);
    req.setValueWithOutNull("inviteMembers", inviteMembers);
    req.setValueWithOutNull("inviteReason", inviteReason);

    Map result = await _channel.invokeMethod(ChatMethodKeys.createGroup, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.createGroup]);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the group information from the server.
  ///
  /// This method does not get member information. If member information is required, call {@link #fetchMemberListFromServer(String, int?, String?)}.
  ///
  /// Param [groupId] The group ID.
  ///
  /// **Return** The group instance.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<EMGroup> fetchGroupInfoFromServer(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getGroupSpecificationFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(
          result[ChatMethodKeys.getGroupSpecificationFromServer]);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the member list of the group with pagination.
  ///
  /// For example:
  ///   ```dart
  ///     EMCursorResult<String> result = await EMClient.getInstance.groupManager.fetchMemberListFromServer(groupId); // search 1
  ///     result = await EMClient.getInstance.groupManager.fetchMemberListFromServer(groupId, cursor: result.cursor); // search 2
  ///   ```
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [pageSize] The number of group members per page.
  ///
  /// Param [cursor] The cursor position from which to start to get data next time. Sets the parameter as null for the first time.
  ///
  /// **Return** The result of {@link EMCursorResult}, including the cursor for getting data next time and the group member list.
  /// If `EMCursorResult.cursor` is an empty string (""), all data is fetched.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<EMCursorResult<String>> fetchMemberListFromServer(
    String groupId, {
    int pageSize = 200,
    String? cursor,
  }) async {
    Map req = {
      'groupId': groupId,
      'pageSize': pageSize,
    };
    req.setValueWithOutNull("cursor", cursor);
    Map result = await _channel.invokeMethod(
      ChatMethodKeys.getGroupMemberListFromServer,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
      return EMCursorResult<String>.fromJson(
          result[ChatMethodKeys.getGroupMemberListFromServer],
          dataItemCallback: (value) => value);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the group block list from server with pagination.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [pageSize] The number of groups per page.
  ///
  /// Param [pageNum] The page number, starting from 1.
  ///
  /// **Return** The group block list.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<List<String>?> fetchBlockListFromServer(
    String groupId, {
    int pageSize = 200,
    int pageNum = 1,
  }) async {
    Map req = {'groupId': groupId, 'pageNum': pageNum, 'pageSize': pageSize};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getGroupBlockListFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.getGroupBlockListFromServer]?.cast<String>();
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the mute list of the group from the server.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [pageSize] The number of muted members per page.
  ///
  /// Param [pageNum] The page number, starting from 1.
  ///
  /// **Return** The group mute map, key is memberId and value is mute time.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<Map<String, int>?> fetchMuteListFromServer(
    String groupId, {
    int pageSize = 200,
    int pageNum = 1,
  }) async {
    Map req = {'groupId': groupId, 'pageNum': pageNum, 'pageSize': pageSize};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getGroupMuteListFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.getGroupMuteListFromServer]
          ?.cast<Map<String, int>>();
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the allow list of the group from the server.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// **Return** The allow list of the group.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<List<String>?> fetchWhiteListFromServer(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getGroupWhiteListFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.getGroupWhiteListFromServer]?.cast<String>();
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets whether the member is on the allow list of the group.
  ///
  /// Param [groupId] The group ID.
  ///
  /// **Return** A Boolean value to indicate whether the current user is on the allow list of the group;
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<bool> isMemberInWhiteListFromServer(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.isMemberInWhiteListFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.isMemberInWhiteListFromServer);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the shared files of the group from the server.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [pageSize] The number of shared files per page.
  ///
  /// Param [pageNum] The page number, starting from 1.
  ///
  /// **Return** The shared files.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<List<EMGroupSharedFile>> fetchGroupFileListFromServer(
    String groupId, {
    int pageSize = 200,
    int pageNum = 1,
  }) async {
    Map req = {'groupId': groupId, 'pageNum': pageNum, 'pageSize': pageSize};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getGroupFileListFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      List<EMGroupSharedFile> list = [];
      result[ChatMethodKeys.getGroupFileListFromServer]?.forEach((element) {
        list.add(EMGroupSharedFile.fromJson(element));
      });
      return list;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the group announcement from the server.
  ///
  /// Group members can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// **Return** The group announcement.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<String?> fetchAnnouncementFromServer(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getGroupAnnouncementFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.getGroupAnnouncementFromServer];
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Adds users to the group.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [members] The array of new members to add.
  ///
  /// Param [welcome] The welcome message.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> addMembers(
    String groupId,
    List<String> members, [
    String? welcome,
  ]) async {
    Map req = {'groupId': groupId, 'members': members};
    req.setValueWithOutNull("welcome", welcome);
    Map result = await _channel.invokeMethod(ChatMethodKeys.addMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Invites users to join the group.
  ///
  /// This method works only for groups with the style of `PrivateOnlyOwnerInvite`, `PrivateMemberCanInvite`, or `PublicJoinNeedApproval`.
  /// For a group with the PrivateOnlyOwnerInvite style, only the group owner can invite users to join the group;
  /// For a group with the PrivateMemberCanInvite style, each group member can invite users to join the group.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [members] The array of new members to invite.
  ///
  /// Param [reason] The invitation reason.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> inviterUser(
    String groupId,
    List<String> members, [
    String? reason,
  ]) async {
    Map req = {
      'groupId': groupId,
      'members': members,
    };
    if (reason != null) {
      req["reason"] = reason;
    }

    Map result = await _channel.invokeMethod(
      ChatMethodKeys.inviterUser,
      req,
    );

    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Removes a member from the group.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [members] The username of the member to be removed.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> removeMembers(
    String groupId,
    List<String> members,
  ) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result = await _channel.invokeMethod(ChatMethodKeys.removeMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Adds the user to the block list of the group.
  ///
  /// Users will be first removed from the group they have joined before being added to the block list of the group. The users on the group block list cannot join the group again.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [members] The list of users to be added to the block list.
  ///
  /// **Throws**   A description of the exception. See {@link EMError}.
  ///
  Future<void> blockMembers(
    String groupId,
    List<String> members,
  ) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result = await _channel.invokeMethod(ChatMethodKeys.blockMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Removes users from the group block list.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [members] The users to be removed from the group block list.
  ///
  /// **Throws**   A description of the exception. See {@link EMError}.
  ///
  Future<void> unblockMembers(
    String groupId,
    List<String> members,
  ) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.unblockMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Changes the group name.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [name] The new group name.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> changeGroupName(
    String groupId,
    String name,
  ) async {
    Map req = {'name': name, 'groupId': groupId};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.updateGroupSubject, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Changes the group description.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [desc] The new group description.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> changeGroupDescription(
    String groupId,
    String desc,
  ) async {
    Map req = {'desc': desc, 'groupId': groupId};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.updateDescription, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Leaves a group.
  ///
  /// Param [groupId] The group ID.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> leaveGroup(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await _channel.invokeMethod(ChatMethodKeys.leaveGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Destroys the group instance.
  ///
  /// Only the group owner can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> destroyGroup(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await _channel.invokeMethod(ChatMethodKeys.destroyGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Blocks group messages.
  ///
  /// The user that blocks group messages is still a group member, but can't receive group messages.
  ///
  /// Param [groupId] The group ID.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> blockGroup(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await _channel.invokeMethod(ChatMethodKeys.blockGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Unblocks group messages.
  ///
  /// Param [groupId] The group ID.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> unblockGroup(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await _channel.invokeMethod(ChatMethodKeys.unblockGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Transfers the group ownership.
  ///
  /// Only the group owner can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [newOwner] The new owner ID.
  ///
  /// **Return** The updated group instance.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> changeOwner(
    String groupId,
    String newOwner,
  ) async {
    Map req = {'groupId': groupId, 'owner': newOwner};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.updateGroupOwner, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Adds a group admin.
  ///
  /// Only the group owner can call this method and group admins cannot.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [memberId] The username of the admin to add.
  ///
  /// **Return** The updated group instance.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> addAdmin(
    String groupId,
    String memberId,
  ) async {
    Map req = {'groupId': groupId, 'admin': memberId};
    Map result = await _channel.invokeMethod(ChatMethodKeys.addAdmin, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Removes a group admin.
  ///
  /// Only the group owner can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [adminId] The username of the admin to remove.
  ///
  /// **Return** The updated group instance.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> removeAdmin(
    String groupId,
    String adminId,
  ) async {
    Map req = {'groupId': groupId, 'admin': adminId};
    Map result = await _channel.invokeMethod(ChatMethodKeys.removeAdmin, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Mutes group members.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [members] The list of members to be muted.
  ///
  /// Param [duration] The mute duration in milliseconds.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> muteMembers(
    String groupId,
    List<String> members, {
    int duration = -1,
  }) async {
    Map req = {'groupId': groupId, 'members': members, 'duration': duration};
    Map result = await _channel.invokeMethod(ChatMethodKeys.muteMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Unmutes group members.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [members] The list of members to be muted.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> unMuteMembers(
    String groupId,
    List<String> members,
  ) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result = await _channel.invokeMethod(ChatMethodKeys.unMuteMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Mutes all members.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> muteAllMembers(String groupId) async {
    Map req = {'groupId': groupId};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.muteAllMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Unmutes all members.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> unMuteAllMembers(String groupId) async {
    Map req = {'groupId': groupId};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.unMuteAllMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Adds members to the allow list of the group.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [members] The members to be added to the allow list of the group.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> addWhiteList(
    String groupId,
    List<String> members,
  ) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result = await _channel.invokeMethod(ChatMethodKeys.addWhiteList, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Removes members from the allow list of the group.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [members] The members to be removed from the allow list of the group.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> removeWhiteList(
    String groupId,
    List<String> members,
  ) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.removeWhiteList, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Uploads the shared file to the group.
  ///
  /// When a shared file is uploaded, the upload progress callback will be triggered.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [filePath] The local path of the shared file.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> uploadGroupSharedFile(
    String groupId,
    String filePath,
  ) async {
    Map req = {'groupId': groupId, 'filePath': filePath};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.uploadGroupSharedFile, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Downloads the shared file of the group.
  ///
  /// Note: The callback is only used for progress callback.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [fileId] The ID of the shared file.
  ///
  /// Param [savePath] The local path of the shared file.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> downloadGroupSharedFile({
    required String groupId,
    required String fileId,
    required String savePath,
    EMDownloadCallback? callback,
  }) async {
    Map req = {'groupId': groupId, 'fileId': fileId, 'savePath': savePath};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.downloadGroupSharedFile, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Removes a shared file of the group.
  ///
  /// Group members can delete their own uploaded files. The group owner or admin can delete all shared files.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [fileId] The ID of the shared file.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> removeGroupSharedFile(
    String groupId,
    String fileId,
  ) async {
    Map req = {'groupId': groupId, 'fileId': fileId};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.removeGroupSharedFile, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Updates the group announcement.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [announcement] The group announcement.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> updateGroupAnnouncement(
    String groupId,
    String announcement,
  ) async {
    Map req = {'groupId': groupId, 'announcement': announcement};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.updateGroupAnnouncement, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Updates the group extension field.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [extension] The group extension field.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> updateGroupExtension(
    String groupId,
    String extension,
  ) async {
    Map req = {'groupId': groupId, 'ext': extension};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.updateGroupExt, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Joins a public group.
  ///
  /// For a group that requires no authentication，users can join it freely without obtaining permissions from the group owner.
  /// For a group that requires authentication, users need to wait for the group owner to agree before joining the group. For details, see {@link EMGroupStyle}.
  ///
  /// Param [groupId] The group ID.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> joinPublicGroup(
    String groupId,
  ) async {
    Map req = {'groupId': groupId};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.joinPublicGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Requests to join a group.
  ///
  /// This method works only for public groups requiring authentication, i.e., groups with the style of {@link EMGroupStyle#PublicJoinNeedApproval}.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [reason] The reason for requesting to join the group.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> requestToJoinPublicGroup(
    String groupId, [
    String? reason,
  ]) async {
    Map req = {'groupId': groupId};
    req.setValueWithOutNull('reason', reason);
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.requestToJoinPublicGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Approves a group request.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [username] The username of the user who sends a request to join the group.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> acceptJoinApplication(
    String groupId,
    String username,
  ) async {
    Map req = {'groupId': groupId, 'username': username};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.acceptJoinApplication, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Declines a group request.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [username] The username of the user who sends a request to join the group.
  ///
  /// Param [reason] The reason of declining.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> declineJoinApplication(
    String groupId,
    String username, [
    String? reason,
  ]) async {
    Map req = {'groupId': groupId, 'username': username};
    req.setValueWithOutNull('reason', reason);

    Map result =
        await _channel.invokeMethod(ChatMethodKeys.declineJoinApplication, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Accepts a group invitation.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [inviter] The user who initiates the invitation.
  ///
  /// **Return** The group instance which the user has accepted the invitation to join.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<EMGroup> acceptInvitation(
    String groupId,
    String inviter,
  ) async {
    Map req = {'groupId': groupId, 'inviter': inviter};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.acceptInvitationFromGroup, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.acceptInvitationFromGroup]);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Declines a group invitation.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [inviter] The username of the inviter.
  ///
  /// Param [reason] The reason of declining.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> declineInvitation(
    String groupId,
    String inviter, [
    String? reason,
  ]) async {
    Map req = {'groupId': groupId, 'inviter': inviter};
    req.setValueWithOutNull('reason', reason);
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.declineInvitationFromGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Registers a group event listener.
  ///
  /// The registered listener needs to be used together with {@link #removeGroupChangeListener(EMGroupEventListener)}.
  ///
  /// Param [listener] The group event listener to be registered.
  ///
  void addGroupChangeListener(EMGroupEventListener listener) {
    _groupChangeListeners.add(listener);
  }

  ///
  /// Removes a group event listener.
  ///
  /// This method removes a group event listener registered with {@link #addGroupChangeListener(EMGroupEventListener)}.
  ///
  /// Param [listener] The group event listener to be removed.
  ///
  void removeGroupChangeListener(EMGroupEventListener listener) {
    if (_groupChangeListeners.contains(listener)) {
      _groupChangeListeners.remove(listener);
    }
  }

  ///
  /// Gets the group information from the server.
  ///
  /// This method does not get member information. If member information is required, call {@link #fetchMemberListFromServer(String, int?, String?)}.
  ///
  /// Param [groupId] The group ID.
  ///
  /// **Return** The group instance.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  @Deprecated("Switch to using fetchGroupInfoFromServer instead.")
  Future<EMGroup> getGroupSpecificationFromServer(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getGroupSpecificationFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(
          result[ChatMethodKeys.getGroupSpecificationFromServer]);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets all groups of the current user from the server.
  ///
  /// This method returns a group list which does not contain member information. If you want to update information of a group to include its member information, call {@link #fetchGroupInfoFromServer(String groupId)}.
  ///
  /// **Return** The list of groups that the current user joins.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  @Deprecated("Switch to using fetchJoinedGroupsFromServer instead.")
  Future<List<EMGroup>> getJoinedGroupsFromServer({
    int pageSize = 200,
    int pageNum = 1,
  }) async {
    Map req = {'pageSize': pageSize, 'pageNum': pageNum};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getJoinedGroupsFromServer, req);
    EMError.hasErrorFromResult(result);
    List<EMGroup> list = [];
    result[ChatMethodKeys.getJoinedGroupsFromServer]
        ?.forEach((element) => list.add(EMGroup.fromJson(element)));
    return list;
  }

  ///
  /// Gets public groups from the server with pagination.
  ///
  /// Param [pageSize] The number of public groups per page.
  ///
  /// Param [cursor] The cursor position from which to start to get data next time. Sets the parameter as null for the first time.
  ///
  /// **Return** The result of {@link EMCursorResult}, including the cursor for getting data next time and the group list.
  /// If `EMCursorResult.cursor` is an empty string (""), all data is fetched.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  @Deprecated("Switch to using fetchPublicGroupsFromServer instead.")
  Future<EMCursorResult<EMGroup>> getPublicGroupsFromServer({
    int pageSize = 200,
    String? cursor,
  }) async {
    Map req = {'pageSize': pageSize};
    req.setValueWithOutNull("cursor", cursor);
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getPublicGroupsFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMCursorResult<EMGroup>.fromJson(
          result[ChatMethodKeys.getPublicGroupsFromServer],
          dataItemCallback: (value) {
        return EMGroup.fromJson(value);
      });
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the group block list from server with pagination.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [pageSize] The number of groups per page.
  ///
  /// Param [pageNum] The page number, starting from 1.
  ///
  /// **Return** The group block list.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  @Deprecated("Switch to using fetchBlockListFromServer instead.")
  Future<List<String>?> getBlockListFromServer(
    String groupId, {
    int pageSize = 200,
    int pageNum = 1,
  }) async {
    Map req = {'groupId': groupId, 'pageNum': pageNum, 'pageSize': pageSize};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getGroupBlockListFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.getGroupBlockListFromServer]?.cast<String>();
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the group announcement from the server.
  ///
  /// Group members can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// **Return** The group announcement.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  @Deprecated("Switch to using fetchAnnouncementFromServer instead.")
  Future<String?> getGroupAnnouncementFromServer(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getGroupAnnouncementFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.getGroupAnnouncementFromServer];
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the shared files of the group from the server.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [pageSize] The number of shared files per page.
  ///
  /// Param [pageNum] The page number, starting from 1.
  ///
  /// **Return** The shared files.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  @Deprecated("Switch to using fetchGroupFileListFromServer instead.")
  Future<List<EMGroupSharedFile>?> getGroupFileListFromServer(
    String groupId, {
    int pageSize = 200,
    int pageNum = 1,
  }) async {
    Map req = {'groupId': groupId, 'pageNum': pageNum, 'pageSize': pageSize};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getGroupFileListFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      List<EMGroupSharedFile> list = [];
      result[ChatMethodKeys.getGroupFileListFromServer]?.forEach((element) {
        list.add(EMGroupSharedFile.fromJson(element));
      });
      return list;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the member list of the group with pagination.
  ///
  /// For example:
  ///   ```dart
  ///     EMCursorResult<String> result = await EMClient.getInstance.groupManager.fetchMemberListFromServer(groupId); // search 1
  ///     result = await EMClient.getInstance.groupManager.fetchMemberListFromServer(groupId, cursor: result.cursor); // search 2
  ///   ```
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [pageSize] The number of group members per page.
  ///
  /// Param [cursor] The cursor position from which to start to get data next time. Sets the parameter as null for the first time.
  ///
  /// **Return** The result of {@link EMCursorResult}, including the cursor for getting data next time and the group member list.
  /// If `EMCursorResult.cursor` is an empty string (""), all data is fetched.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  @Deprecated("Switch to using fetchMemberListFromServer instead.")
  Future<EMCursorResult<String>> getGroupMemberListFromServer(
    String groupId, {
    int pageSize = 200,
    String? cursor,
  }) async {
    Map req = {
      'groupId': groupId,
      'pageSize': pageSize,
    };
    req.setValueWithOutNull("cursor", cursor);
    Map result = await _channel.invokeMethod(
      ChatMethodKeys.getGroupMemberListFromServer,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
      return EMCursorResult<String>.fromJson(
          result[ChatMethodKeys.getGroupMemberListFromServer],
          dataItemCallback: (value) => value);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the mute list of the group from the server.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [pageSize] The number of muted members per page.
  ///
  /// Param [pageNum] The page number, starting from 1.
  ///
  /// **Return** The group mute list.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  @Deprecated("Switch to using fetchMuteListFromServer instead.")
  Future<List<String>?> getMuteListFromServer(
    String groupId, {
    int pageSize = 200,
    int pageNum = 1,
  }) async {
    Map req = {'groupId': groupId, 'pageNum': pageNum, 'pageSize': pageSize};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getGroupMuteListFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.getGroupMuteListFromServer]?.cast<String>();
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the allow list of the group from the server.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// **Return** The allow list of the group.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  @Deprecated("Switch to using fetchWhiteListFromServer instead.")
  Future<List<String>?> getWhiteListFromServer(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getGroupWhiteListFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.getGroupWhiteListFromServer]?.cast<String>();
    } on EMError catch (e) {
      throw e;
    }
  }

  Future<void> _onGroupChanged(Map? map) async {
    for (EMGroupEventListener listener in _groupChangeListeners) {
      var type = map!['type'];
      switch (type) {
        case EMGroupChangeEvent.ON_INVITATION_RECEIVED:
          String groupId = map['groupId'];
          String? groupName = map['groupName'];
          String inviter = map['inviter'];
          String? reason = map['reason'];
          listener.onInvitationReceivedFromGroup(
              groupId, groupName, inviter, reason);
          break;
        case EMGroupChangeEvent.ON_INVITATION_ACCEPTED:
          String groupId = map['groupId'];
          String invitee = map['invitee'];
          String? reason = map['reason'];
          listener.onInvitationAcceptedFromGroup(groupId, invitee, reason);
          break;
        case EMGroupChangeEvent.ON_INVITATION_DECLINED:
          String groupId = map['groupId'];
          String invitee = map['invitee'];
          String? reason = map['reason'];
          listener.onInvitationDeclinedFromGroup(groupId, invitee, reason);
          break;
        case EMGroupChangeEvent.ON_AUTO_ACCEPT_INVITATION:
          String groupId = map['groupId'];
          String inviter = map['inviter'];
          String? inviteMessage = map['inviteMessage'];
          listener.onAutoAcceptInvitationFromGroup(
              groupId, inviter, inviteMessage);
          break;
        case EMGroupChangeEvent.ON_USER_REMOVED:
          String groupId = map['groupId'];
          String? groupName = map['groupName'];
          listener.onUserRemovedFromGroup(groupId, groupName);
          break;
        case EMGroupChangeEvent.ON_REQUEST_TO_JOIN_RECEIVED:
          String groupId = map['groupId'];
          String? groupName = map['groupName'];
          String applicant = map['applicant'];
          String? reason = map['reason'];
          listener.onRequestToJoinReceivedFromGroup(
              groupId, groupName, applicant, reason);
          break;
        case EMGroupChangeEvent.ON_REQUEST_TO_JOIN_DECLINED:
          String groupId = map['groupId'];
          String? groupName = map['groupName'];
          String decliner = map['decliner'];
          String? reason = map['reason'];
          listener.onRequestToJoinDeclinedFromGroup(
              groupId, groupName, decliner, reason);
          break;
        case EMGroupChangeEvent.ON_REQUEST_TO_JOIN_ACCEPTED:
          String groupId = map['groupId'];
          String? groupName = map['groupName'];
          String accepter = map['accepter'];
          listener.onRequestToJoinAcceptedFromGroup(
              groupId, groupName, accepter);
          break;
        case EMGroupChangeEvent.ON_GROUP_DESTROYED:
          String groupId = map['groupId'];
          String? groupName = map['groupName'];
          listener.onGroupDestroyed(groupId, groupName);
          break;
        case EMGroupChangeEvent.ON_MUTE_LIST_ADDED:
          String groupId = map['groupId'];
          List<String> mutes = List.from(map['mutes']);
          int? muteExpire = map['muteExpire'];
          listener.onMuteListAddedFromGroup(groupId, mutes, muteExpire);
          break;
        case EMGroupChangeEvent.ON_MUTE_LIST_REMOVED:
          String groupId = map['groupId'];
          List<String> mutes = List.from(map['mutes']);
          listener.onMuteListRemovedFromGroup(groupId, mutes);
          break;
        case EMGroupChangeEvent.ON_ADMIN_ADDED:
          String groupId = map['groupId'];
          String administrator = map['administrator'];
          listener.onAdminAddedFromGroup(groupId, administrator);
          break;
        case EMGroupChangeEvent.ON_ADMIN_REMOVED:
          String groupId = map['groupId'];
          String administrator = map['administrator'];
          listener.onAdminRemovedFromGroup(groupId, administrator);
          break;
        case EMGroupChangeEvent.ON_OWNER_CHANGED:
          String groupId = map['groupId'];
          String newOwner = map['newOwner'];
          String oldOwner = map['oldOwner'];
          listener.onOwnerChangedFromGroup(groupId, newOwner, oldOwner);
          break;
        case EMGroupChangeEvent.ON_MEMBER_JOINED:
          String groupId = map['groupId'];
          String member = map['member'];
          listener.onMemberJoinedFromGroup(groupId, member);
          break;
        case EMGroupChangeEvent.ON_MEMBER_EXITED:
          String groupId = map['groupId'];
          String member = map['member'];
          listener.onMemberExitedFromGroup(groupId, member);
          break;
        case EMGroupChangeEvent.ON_ANNOUNCEMENT_CHANGED:
          String groupId = map['groupId'];
          String announcement = map['announcement'];
          listener.onAnnouncementChangedFromGroup(groupId, announcement);
          break;
        case EMGroupChangeEvent.ON_SHARED_FILE_ADDED:
          String groupId = map['groupId'];
          EMGroupSharedFile sharedFile =
              EMGroupSharedFile.fromJson(map['sharedFile']);
          listener.onSharedFileAddedFromGroup(groupId, sharedFile);
          break;
        case EMGroupChangeEvent.ON_SHARED_FILE__DELETED:
          String groupId = map['groupId'];
          String fileId = map['fileId'];
          listener.onSharedFileDeletedFromGroup(groupId, fileId);
          break;
        case EMGroupChangeEvent.ON_WHITE_LIST_ADDED:
          String groupId = map["groupId"];
          List<String> members = List.from(map['whitelist']);
          listener.onWhiteListAddedFromGroup(groupId, members);
          break;
        case EMGroupChangeEvent.ON_WHITE_LIST_REMOVED:
          String groupId = map["groupId"];
          List<String> members = List.from(map['whitelist']);
          listener.onWhiteListRemovedFromGroup(groupId, members);
          break;
        case EMGroupChangeEvent.ON_ALL_MEMBER_MUTE_STATE_CHANGED:
          String groupId = map["groupId"];
          bool isAllMuted = map["isMuted"] as bool;
          listener.onAllGroupMemberMuteStateChanged(groupId, isAllMuted);
          break;
      }
    }
  }
}
