import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';

/// ~english
/// The group manager class, which manages group creation and deletion, user joining and exiting the group, etc.
/// ~end
///
/// ~chinese
/// 群组管理类，用于管理群组的创建，删除及成员管理等操作。
/// ~end
class EMGroupManager {
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
    return Client.instance.groupManager.addEventHandler(identifier, handler);
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
    return Client.instance.groupManager.removeEventHandler(identifier);
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
    return Client.instance.groupManager.getEventHandler(identifier);
  }

  /// ~english
  /// Clear all group event handlers.
  /// ~end
  ///
  /// ~chinese
  /// 清除所有事件监听。
  /// ~end
  void clearEventHandlers() {
    return Client.instance.groupManager.clearEventHandlers();
  }

  /// ~english
  /// Gets the group instance from the cache by group ID.
  ///
  /// Param [groupId] The group ID.
  ///
  /// **Return** The group instance. Returns null if the group does not exist.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 根据群组 ID，从本地缓存中获取指定群组。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// **Return** 返回群组对象。如果群组不存在，返回 null。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<EMGroup?> getGroupWithId(String groupId) async {
    return Client.instance.groupManager.getGroupWithId(groupId);
  }

  /// ~english
  /// Gets all groups of the current user from the cache.
  ///
  /// **Return** The group list.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 从本地缓存中获取当前用户加入的所有群组。
  ///
  /// **Return** 群组列表。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<List<EMGroup>> getJoinedGroups() async {
    return Client.instance.groupManager.getJoinedGroups();
  }

  /// ~english
  /// Gets all groups of the current user from the server.
  ///
  /// This method returns a group list which does not contain member information. If you want to update information of a group to include its member information, call [fetchGroupInfoFromServer].
  ///
  /// Param [pageSize] The size of groups per page.
  ///
  /// Param [pageNum] The page number.
  ///
  /// Param [needMemberCount] The return result contains the number of group members
  ///
  /// Param [needRole] The result contains the current user's role in the group
  ///
  /// **Return** The list of groups that the current user joins.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器中获取当前用户加入的所有群组。
  ///
  /// 此操作只返回群组列表，不包含所有成员的信息。如果要更新某个群组包括成员的全部信息，需要再调用 [EMGroupManager.fetchGroupInfoFromServer]。
  ///
  /// **Return** 当前用户加入的群组的列表。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<List<EMGroup>> fetchJoinedGroupsFromServer({
    int pageSize = 20,
    int pageNum = 0,
    bool needMemberCount = false,
    bool needRole = false,
  }) async {
    return Client.instance.groupManager.fetchJoinedGroupsFromServer(
      pageSize: pageSize,
      pageNum: pageNum,
      needMemberCount: needMemberCount,
      needRole: needRole,
    );
  }

  /// ~english
  /// Gets public groups from the server with pagination.
  ///
  /// Param [pageSize] The number of public groups per page.
  ///
  /// Param [cursor] The cursor position from which to start to get data next time. Sets the parameter as null for the first time.
  ///
  /// **Return** The result of [EMCursorResult], including the cursor for getting data next time and the group list.
  /// If [EMCursorResult.cursor] is an empty string (""), all data is fetched.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 以分页方式从服务器获取当前用户加入的所有公开群组。
  ///
  /// Param [pageSize] 每页返回的群组数。
  ///
  /// Param [cursor] 从这个游标位置开始取数据，首次获取数据时传 `null`，按照用户加入公开群组时间的顺序还是逆序获取数据。
  ///
  /// **Return** 包含用于下次获取数据的 cursor 以及群组列表。返回的结果中，当 `EMCursorResult.getCursor()` 为空字符串 ("") 时，表示没有更多数据。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<EMCursorResult<EMGroupInfo>> fetchPublicGroupsFromServer({
    int pageSize = 200,
    String? cursor,
  }) async {
    return Client.instance.groupManager.fetchPublicGroupsFromServer(
      pageSize: pageSize,
      cursor: cursor,
    );
  }

  /// ~english
  /// Creates a group instance.
  ///
  /// After the group is created, the data in the cache and database will be updated and multiple devices will receive the notification event and update the group data to the cache and database.
  /// You can set [EMMultiDeviceEventHandler] to listen for the event. If an event occurs, the callback function
  /// [EMMultiDeviceEventHandler.onGroupEvent] is triggered, where the first parameter is the event which is
  /// [EMMultiDevicesEvent.GROUP_CREATE] for a group creation event.
  ///
  /// Param [groupName] The group name.
  ///
  /// Param [desc] The group description.
  ///
  /// Param [inviteMembers] The group member array. The group owner ID is optional.
  ///
  /// Param [inviteReason] The group joining invitation.
  ///
  /// Param [options] The options for creating a group. See [EMGroupOptions].
  /// The options are as follows:
  /// - The maximum number of group members. The default value is 200.
  /// - The group style. See [EMGroupStyle]. The default value is [EMGroupStyle.PrivateOnlyOwnerInvite].
  /// - Whether to ask for permission when inviting a user to join the group. The default value is `false`, indicating that invitees are automatically added to the group without their permission.
  /// - The group detail extensions.
  ///
  /// **Return** The created group instance.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 创建群组。
  ///
  /// 群组创建成功后，会更新内存及数据库中的数据，多端多设备会收到相应的通知事件，将群组更新到内存及数据库中。
  /// 可通过设置 [EMClient.addMultiDeviceEventHandler] 监听相关事件，事件回调函数为 [EMMultiDeviceEventHandler.onGroupEvent]，第一个参数为事件，创建群组事件为 [EMMultiDevicesEvent.GROUP_CREATE]。
  ///
  /// Param [groupName] 群组名称。
  ///
  /// Param [desc] 群组描述。
  ///
  /// Param [inviteMembers] 群成员数组。群主 ID 可选。
  ///
  /// Param [inviteReason] 用户入群邀请信息。
  ///
  /// Param [options] 群组的其他选项。请参见 [EMGroupOptions]。
  /// 群组的其他选项。
  /// - 群最大成员数，默认值为 200；
  /// - 群组类型，详见 [EMGroupStyle]，默认为 [EMGroupStyle.PrivateOnlyOwnerInvite]；
  /// - 邀请进群是否需要对方同意，默认为 false，即邀请后直接进群；
  /// - 群组详情扩展。
  ///
  /// **Return** 创建成功的群对象。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<EMGroup> createGroup({
    String? groupName,
    String? avatar,
    String? desc,
    List<String>? inviteMembers,
    String? inviteReason,
    required EMGroupOptions options,
  }) async {
    return Client.instance.groupManager.createGroup(
      groupName: groupName,
      avatar: avatar,
      desc: desc,
      inviteMembers: inviteMembers,
      inviteReason: inviteReason,
      options: options,
    );
  }

  /// ~english
  /// Gets the group information from the server.
  ///
  /// This method does not get member information. If member information is required, call [fetchMemberListFromServer].
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [fetchMembers] Whether to get group members. By default, a list of 200 members is fetched.
  ///
  /// **Return** The group instance.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取群组的详细信息。
  ///
  /// 该方法不获取成员。如需获取成员，使用 [fetchMemberListFromServer]。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// **Return** 群组描述。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<EMGroup> fetchGroupInfoFromServer(
    String groupId, {
    bool fetchMembers = false,
  }) async {
    return Client.instance.groupManager.fetchGroupInfoFromServer(
      groupId,
      fetchMembers: fetchMembers,
    );
  }

  /// ~english
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
  /// **Return** The result of [EMCursorResult], including the cursor for getting data next time and the group member list.
  /// If [EMCursorResult.cursor] is an empty string (""), all data is fetched.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 以分页方式获取群组成员列表。
  ///
  /// 例如:
  ///   ```dart
  ///     EMCursorResult<String> result = await EMClient.getInstance.groupManager.fetchMemberListFromServer(groupId); // search 1
  ///     result = await EMClient.getInstance.groupManager.fetchMemberListFromServer(groupId, cursor: result.cursor); // search 2
  ///   ```
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [pageSize] 每页返回的群组成员数。
  ///
  /// Param [cursor] 从这个游标位置开始取数据，首次获取数据时传 null 即可。
  ///
  /// **Return** 分页获取结果 [EMCursorResult]，包含用于下次获取数据的 cursor 以及群组成员列表。返回的结果中，当 [EMCursorResult.cursor] 为空字符串 ("") 时，表示没有更多数据。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<EMCursorResult<String>> fetchMemberListFromServer(
    String groupId, {
    int pageSize = 200,
    String? cursor,
  }) async {
    return Client.instance.groupManager.fetchMemberListFromServer(
      groupId,
      pageSize: pageSize,
      cursor: cursor,
    );
  }

  /// ~english
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
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 以分页方式获取群组的黑名单。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [pageSize] 每页返回的群组黑名单成员数量。
  ///
  /// Param [pageNum] 当前页码，从 1 开始。
  ///
  /// **Return** 返回的黑名单列表。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<List<String>> fetchBlockListFromServer(
    String groupId, {
    int pageSize = 200,
    int pageNum = 1,
  }) async {
    return Client.instance.groupManager.fetchBlockListFromServer(
      groupId,
      pageSize: pageSize,
      pageNum: pageNum,
    );
  }

  /// ~english
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
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 获取群组的禁言列表。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [pageSize] 每页返回的禁言成员数。
  ///
  /// Param [pageNum] 当前页码，从 1 开始。
  ///
  /// **Return** 群组的禁言列表。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<Map<String, int>> fetchMuteListFromServer(
    String groupId, {
    int pageSize = 200,
    int pageNum = 1,
  }) async {
    return Client.instance.groupManager.fetchMuteListFromServer(
      groupId,
      pageSize: pageSize,
      pageNum: pageNum,
    );
  }

  /// ~english
  /// Gets the allow list of the group from the server.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// **Return** The allow list of the group.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 获取群组白名单列表。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// **Return** 群组的白名单。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<List<String>> fetchAllowListFromServer(String groupId) async {
    return Client.instance.groupManager.fetchAllowListFromServer(groupId);
  }

  /// ~english
  /// Gets whether the member is on the allow list of the group.
  ///
  /// Param [groupId] The group ID.
  ///
  /// **Return** A Boolean value to indicate whether the current user is on the allow list of the group;
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 检查当前用户是否在群组白名单中。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// **Return** 是否在群组白名单。
  /// - `true`: 是；
  /// - `false`: 否。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<bool> isMemberInAllowListFromServer(String groupId) async {
    return Client.instance.groupManager.isMemberInAllowListFromServer(groupId);
  }

  /// ~english
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
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取群组的共享文件列表。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [pageSize] 每页返回的共享文件数量。
  ///
  /// Param [pageNum] 当前页码，从 1 开始。
  ///
  /// **Return** 返回共享文件列表。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<List<EMGroupSharedFile>> fetchGroupFileListFromServer(
    String groupId, {
    int pageSize = 200,
    int pageNum = 1,
  }) async {
    return Client.instance.groupManager.fetchGroupFileListFromServer(
      groupId,
      pageSize: pageSize,
      pageNum: pageNum,
    );
  }

  /// ~english
  /// Gets the group announcement from the server.
  ///
  /// Group members can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// **Return** The group announcement.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取群组公告。
  ///
  /// 群成员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// **Return** 群组公告。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<String?> fetchAnnouncementFromServer(String groupId) async {
    return Client.instance.groupManager.fetchAnnouncementFromServer(groupId);
  }

  /// ~english
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
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 向群组中添加新成员。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [members] 要添加的新成员数组。
  ///
  /// Param [welcome] 欢迎消息。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> addMembers(
    String groupId,
    List<String> members, {
    String? welcome,
  }) async {
    return Client.instance.groupManager.addMembers(
      groupId,
      members,
      welcome: welcome,
    );
  }

  /// ~english
  /// Invites users to join the group.
  ///
  /// This method works only for groups with the style of [EMGroupStyle.PrivateOnlyOwnerInvite], [EMGroupStyle.PrivateMemberCanInvite], or [EMGroupStyle.PublicJoinNeedApproval].
  /// For a group with the [EMGroupStyle.PrivateOnlyOwnerInvite] style, only the group owner can invite users to join the group;
  /// For a group with the [EMGroupStyle.PrivateMemberCanInvite] style, each group member can invite users to join the group.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [members] The array of new members to invite.
  ///
  /// Param [reason] The invitation reason.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 邀请用户加入群组。
  ///
  /// 群类型为 [EMGroupStyle.PrivateOnlyOwnerInvite]、[EMGroupStyle.PrivateMemberCanInvite] 和 [EMGroupStyle.PublicJoinNeedApproval] 的群组可以邀请用户加入。
  ///
  /// - 对于 [EMGroupStyle.PrivateOnlyOwnerInvite] 属性的群组，仅群主可邀请用户入群。
  /// - 对于 [EMGroupStyle.PrivateMemberCanInvite] 属性的群组，群成员可邀请用户入群。
  /// - 对于 [EMGroupStyle.PublicJoinNeedApproval] 属性的群组，仅群主可邀请用户加入。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [members] 要邀请的新成员数组。
  ///
  /// Param [reason] 邀请原因。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> inviterUser(
    String groupId,
    List<String> members, {
    String? reason,
  }) async {
    return Client.instance.groupManager.inviterUser(
      groupId,
      members,
      reason: reason,
    );
  }

  /// ~english
  /// Removes a member from the group.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [members] The username of the member to be removed.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 将群成员移出群组。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID.
  ///
  /// Param [members] 要删除的成员的用户 ID。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> removeMembers(
    String groupId,
    List<String> members,
  ) async {
    return Client.instance.groupManager.removeMembers(groupId, members);
  }

  /// ~english
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
  /// **Throws**  A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 将用户加入群组黑名单。
  ///
  /// 先将用户移出群，再加入黑名单。加入黑名单的用户无法加入群。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [members] 要加入黑名单的用户 ID。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> blockMembers(
    String groupId,
    List<String> members,
  ) async {
    return Client.instance.groupManager.blockMembers(groupId, members);
  }

  /// ~english
  /// Removes users from the group block list.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [members] The users to be removed from the group block list.
  ///
  /// **Throws**  A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 将用户从群组黑名单中移除。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [members] 要从黑名单中移除的用户。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> unblockMembers(
    String groupId,
    List<String> members,
  ) async {
    return Client.instance.groupManager.unblockMembers(groupId, members);
  }

  /// ~english
  /// Changes the group name.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [name] The new group name.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 修改群组名称。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [name] 修改后的群组名称。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 详见 [EMError]。
  /// ~end
  Future<void> changeGroupName(
    String groupId,
    String name,
  ) async {
    return Client.instance.groupManager.changeGroupName(groupId, name);
  }

  /// ~english
  /// Changes the group description.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [desc] The new group description.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 修改群描述。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [desc] 修改后的群描述。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> changeGroupDescription(
    String groupId,
    String desc,
  ) async {
    return Client.instance.groupManager.changeGroupDescription(groupId, desc);
  }

  /// ~english
  /// Leaves a group.
  ///
  /// Param [groupId] The group ID.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 当前登录用户退出群组。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> leaveGroup(String groupId) async {
    return Client.instance.groupManager.leaveGroup(groupId);
  }

  /// ~english
  /// Destroys the group instance.
  ///
  /// Only the group owner can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 解散群组。
  ///
  /// 仅群主可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> destroyGroup(String groupId) async {
    return Client.instance.groupManager.destroyGroup(groupId);
  }

  /// ~english
  /// Blocks group messages.
  ///
  /// The user that blocks group messages is still a group member, but can't receive group messages.
  ///
  /// Param [groupId] The group ID.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 屏蔽群消息。
  ///
  /// 屏蔽群消息的用户仍是群成员，但不会收到群消息。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> blockGroup(String groupId) async {
    return Client.instance.groupManager.blockGroup(groupId);
  }

  /// ~english
  /// Unblocks group messages.
  ///
  /// Param [groupId] The group ID.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 取消屏蔽群消息。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> unblockGroup(String groupId) async {
    return Client.instance.groupManager.unblockGroup(groupId);
  }

  /// ~english
  /// Transfers the group ownership.
  ///
  /// Only the group owner can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [newOwner] The new owner ID.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 转让群组所有权。
  ///
  /// 仅群主可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [newOwner] 新的群主。
  ///
  /// **Return** 返回新群主。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> changeOwner(
    String groupId,
    String newOwner,
  ) async {
    return Client.instance.groupManager.changeOwner(groupId, newOwner);
  }

  /// ~english
  /// Adds a group admin.
  ///
  /// Only the group owner can call this method and group admins cannot.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [memberId] The username of the admin to add.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 添加群组管理员。
  ///
  /// 仅群主可调用此方法，管理员无权限。
  ///
  /// Param [groupId]   群组 ID。
  ///
  /// Param [memberId]  要添加的管理员的用户 ID。
  ///
  /// **Return**  返回更新后的群组对象。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> addAdmin(
    String groupId,
    String memberId,
  ) async {
    return Client.instance.groupManager.addAdmin(groupId, memberId);
  }

  /// ~english
  /// Removes a group admin.
  ///
  /// Only the group owner can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [adminId] The username of the admin to remove.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 删除群组管理员。
  ///
  /// 仅群主可调用此方法。
  ///
  /// Param [groupId]  群组 ID。
  ///
  /// Param [adminId] 要移除的群组管理员的用户 ID。
  ///
  /// **Return** 返回更新后的群组对象。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> removeAdmin(
    String groupId,
    String adminId,
  ) async {
    return Client.instance.groupManager.removeAdmin(groupId, adminId);
  }

  /// ~english
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
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 将指定群成员禁言。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [members] 要禁言的成员列表。
  ///
  /// Param [duration] 禁言时长，单位为毫秒。
  ///
  /// **Return** 返回更新后的群组对象。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> muteMembers(
    String groupId,
    List<String> members, {
    int duration = -1,
  }) async {
    return Client.instance.groupManager.muteMembers(
      groupId,
      members,
      duration: duration,
    );
  }

  /// ~english
  /// Unmutes group members.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [members] The list of members to be muted.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 取消禁言指定用户。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [members] 要解除禁言的成员列表。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> unMuteMembers(
    String groupId,
    List<String> members,
  ) async {
    return Client.instance.groupManager.unMuteMembers(groupId, members);
  }

  /// ~english
  /// Mutes all members.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 开启全员禁言。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> muteAllMembers(String groupId) async {
    return Client.instance.groupManager.muteAllMembers(groupId);
  }

  /// ~english
  /// Unmutes all members.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 关闭全员禁言。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> unMuteAllMembers(String groupId) async {
    return Client.instance.groupManager.unMuteAllMembers(groupId);
  }

  /// ~english
  /// Adds members to the allow list of the group.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [members] The members to be added to the allow list of the group.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 将成员添加至群组白名单。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [members] 要添加至白名单的成员列表。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> addAllowList(
    String groupId,
    List<String> members,
  ) async {
    return Client.instance.groupManager.addAllowList(groupId, members);
  }

  /// ~english
  /// Removes members from the allow list of the group.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [members] The members to be removed from the allow list of the group.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 将成员移除群组白名单。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [members] 要移除白名单的成员列表。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> removeAllowList(
    String groupId,
    List<String> members,
  ) async {
    return Client.instance.groupManager.removeAllowList(groupId, members);
  }

  /// ~english
  /// Uploads the shared file to the group.
  ///
  /// When a shared file is uploaded, the upload progress callback will be triggered.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [filePath] The local path of the shared file.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 上传共享文件至群组。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [filePath] 共享文件的本地路径。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> uploadGroupSharedFile(
    String groupId,
    String filePath,
  ) async {
    return Client.instance.groupManager.uploadGroupSharedFile(
      groupId,
      filePath,
    );
  }

  /// ~english
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
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 下载指定的群组共享文件。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [fileId]  共享文件的 ID。
  ///
  /// Param [savePath] 共享文件的本地路径。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> downloadGroupSharedFile({
    required String groupId,
    required String fileId,
    required String savePath,
  }) async {
    return Client.instance.groupManager.downloadGroupSharedFile(
      groupId: groupId,
      fileId: fileId,
      savePath: savePath,
    );
  }

  /// ~english
  /// Removes a shared file of the group.
  ///
  /// Group members can delete their own uploaded files. The group owner or admin can delete all shared files.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [fileId] The ID of the shared file.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 删除指定的群组共享文件。
  ///
  /// 群成员可删除自己上传的文件，群主或者管理员可删除所有共享文件。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [fileId] 共享文件的 ID。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> removeGroupSharedFile(
    String groupId,
    String fileId,
  ) async {
    return Client.instance.groupManager.removeGroupSharedFile(
      groupId,
      fileId,
    );
  }

  /// ~english
  /// Updates the group announcement.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [announcement] The group announcement.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 更新群公告。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [announcement] 群组公告。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> updateGroupAnnouncement(
    String groupId,
    String announcement,
  ) async {
    return Client.instance.groupManager.updateGroupAnnouncement(
      groupId,
      announcement,
    );
  }

  /// ~english
  /// Updates the group extension field.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [extension] The group extension field.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 更新群组扩展字段。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [extension] 群组扩展字段。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> updateGroupExtension(
    String groupId,
    String extension,
  ) async {
    return Client.instance.groupManager.updateGroupExtension(
      groupId,
      extension,
    );
  }

  /// ~english
  /// Joins a public group.
  ///
  /// For a group that requires no authentication，users can join it freely without obtaining permissions from the group owner.
  /// For a group that requires authentication, users need to wait for the group owner to agree before joining the group. For details, See [EMGroupStyle].
  ///
  /// Param [groupId] The group ID.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 当前登录用户加入公开群。
  ///
  /// 若是自由加入的公开群[EMGroupStyle.PublicOpenJoin] ，直接进入群组；若公开群需验证，群主同意后才能入群，使用 [requestToJoinPublicGroup] 方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> joinPublicGroup(
    String groupId,
  ) async {
    return Client.instance.groupManager.joinPublicGroup(groupId);
  }

  /// ~english
  /// Requests to join a group.
  ///
  /// This method works only for public groups requiring authentication, i.e., groups with the style of [EMGroupStyle.PublicJoinNeedApproval].
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [reason] The reason for requesting to join the group.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 申请加入群组。
  ///
  /// 该方法仅适用于需要验证的公开群组，即类型为 [EMGroupStyle.PublicJoinNeedApproval] 的群组。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [reason] 申请入群的原因。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> requestToJoinPublicGroup(
    String groupId, {
    String? reason,
  }) async {
    return Client.instance.groupManager.requestToJoinPublicGroup(
      groupId,
      reason: reason,
    );
  }

  /// ~english
  /// Approves a group request.
  ///
  /// Only the group owner or admin can call this method.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [username] The username of the user who sends a request to join the group.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 批准入群申请。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [username] 申请人的用户 ID。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> acceptJoinApplication(
    String groupId,
    String username,
  ) async {
    return Client.instance.groupManager.acceptJoinApplication(
      groupId,
      username,
    );
  }

  /// ~english
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
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 拒绝入群申请。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [userId] 申请人的用户 ID。
  ///
  /// Param [reason] 拒绝理由。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> declineJoinApplication(
    String groupId,
    String username, {
    String? reason,
  }) async {
    return Client.instance.groupManager.declineJoinApplication(
      groupId,
      username,
      reason: reason,
    );
  }

  /// ~english
  /// Accepts a group invitation.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [inviter] The user who initiates the invitation.
  ///
  /// **Return** The group instance which the user has accepted the invitation to join.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 接受入群邀请。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [inviter] 邀请者的用户 ID。
  ///
  /// **Return** 用户已接受邀请的群组对象。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<EMGroup> acceptInvitation(
    String groupId,
    String inviter,
  ) async {
    return Client.instance.groupManager.acceptInvitation(
      groupId,
      inviter,
    );
  }

  /// ~english
  /// Declines a group invitation.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [inviter] The username of the inviter.
  ///
  /// Param [reason] The reason of declining.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 拒绝入群邀请。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [inviter] 邀请者的用户 ID。
  ///
  /// Param [reason] 拒绝理由。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> declineInvitation({
    required String groupId,
    required String inviter,
    String? reason,
  }) async {
    return Client.instance.groupManager.declineInvitation(
      groupId: groupId,
      inviter: inviter,
      reason: reason,
    );
  }

  /// ~english
  /// Sets custom attributes of a group member.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [userId] The user ID of the group member for whom the custom attributes are set. The default value is the current user ID.
  ///
  /// Param [attributes] The map of custom attributes in key-value format.
  /// In a key-value pair, if the value is set to an empty string, the custom attribute will be deleted.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 设置群成员自定义属性。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [userId] 要设置自定义属性的群成员的用户 ID，默认为当前用户。
  ///
  /// Param [attributes] 要设置的群成员自定义属性的 map，为 key-value 格式。对于一个 key-value 键值对，若 value 设置空字符串即删除该自定义属性。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> setMemberAttributes({
    required String groupId,
    required Map<String, String> attributes,
    String? userId,
  }) async {
    return Client.instance.groupManager.setMemberAttributes(
      groupId: groupId,
      attributes: attributes,
      userId: userId,
    );
  }

  /// ~english
  /// Removes custom attributes of a group member.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [keys] The keys of custom attributes to remove.
  ///
  /// Param [userId] The user ID of the group member for whom the custom attributes are removed. The default value is the current user ID.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 设置群成员自定义属性。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [keys] 要删除群成员自定义属性对应的 key。
  ///
  /// Param [userId] 要设置自定义属性的群成员的用户 ID，默认为当前用户 ID。
  ///
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> removeMemberAttributes({
    required String groupId,
    required List<String> keys,
    String? userId,
  }) async {
    return Client.instance.groupManager.removeMemberAttributes(
      groupId: groupId,
      keys: keys,
      userId: userId,
    );
  }

  /// ~english
  /// Gets all custom attributes of a group member.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [userId] The user ID of the group member whose all custom attributes are retrieved. The default value is the current user ID.
  ///
  /// **Return** The user attributes of the group member.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 获取单个群成员所有自定义属性。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [userId] 要获取的自定义属性的群成员的用户 ID, 默认为当前用户 ID。
  ///
  /// **Return** 需要查询的用户属性。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<Map<String, String>> fetchMemberAttributes({
    required String groupId,
    String? userId,
  }) async {
    return Client.instance.groupManager.fetchMemberAttributes(
      groupId: groupId,
      userId: userId,
    );
  }

  /// ~english
  /// Gets custom attributes of multiple group members by attribute key.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [userIds] The array of user IDs of group members whose custom attributes are retrieved. You can pass in a maximum of 10 user IDs.
  ///
  /// Param [keys] The array of keys of custom attributes to be retrieved.
  ///
  /// **Return** The users attributes.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  /// ~end
  ///
  /// ~chinese
  /// 根据指定的属性 key 获取多个群成员的自定义属性。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [userIds] 要获取自定义属性的群成员的用户 ID 数组。最多可传 10 个用户 ID。
  ///
  /// Param [keys] 要获取自定义属性的 key 的数组。
  ///
  /// **Return** 需要查询的用户属性。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<Map<String, Map<String, String>>> fetchMembersAttributes({
    required String groupId,
    required List<String> userIds,
    List<String>? keys,
  }) async {
    return Client.instance.groupManager.fetchMembersAttributes(
      groupId: groupId,
      userIds: userIds,
      keys: keys,
    );
  }

  /// ~english
  /// Gets groups count of the current user joined from the server.
  ///
  /// **Return** The count of groups joined by the current user.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取当前用户已加入的群组数量。
  ///
  /// **Return** 加入的群组数量。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<int> fetchJoinedGroupCount() async {
    return Client.instance.groupManager.fetchJoinedGroupCount();
  }

  Future<bool> isMemberInGroupMuteList(String groupId) async {
    return Client.instance.groupManager.isMemberInGroupMuteList(groupId);
  }

  /// ~english
  /// Clears the information of all groups in the local database.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 清理数据库中当前用户的所有群组。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> clearAllGroupsFromLocal() async {
    return Client.instance.groupManager.clearAllGroupsFromLocal();
  }

  ///
  ///  \~chinese
  ///  获取群组成员列表。
  ///  这里需要注意的是：
  ///  - 每次调用只返回一页的数据。首次调用传空值，会从最新的第一条开始取；
  ///  - aPageSize 是这次接口调用期望返回的列表数据个数，如当前在最后一页，返回的数据会是 count < aPageSize；
  ///  - 列表页码 aPageNum 是方便服务器分页查询返回，对于数据量未知且很大的情况，分页获取，服务器会根据每次的页数和每次的pagesize 返回数据，直到返回所有数据。
  ///
  ///  Param [groupId]         群组 ID。
  ///  Param [cursor]         游标，首次调用传空。下次传上次返回的值。
  ///  Param [limit]        获取多少条。
  ///
  ///  ~end
  ///
  ///
  ///  \~english
  ///  Gets the list of group members from the server.
  ///
  ///  Param [groupId]  The group ID.
  ///  Param [cursor] The cursor when joins the group. Sets the parameter as nil for the first time. Next time, pass the value returned last time.
  ///  Param [limit ] The page size.
  ///
  ///  ~end
  ///
  Future<EMCursorResult<GroupMemberInfo>> fetchGroupMembersInfo({
    required String groupId,
    String? cursor,
    int limit = 20,
  }) async {
    return Client.instance.groupManager.fetchGroupMembersInfo(
      groupId: groupId,
      cursor: cursor,
      limit: limit,
    );
  }
}
