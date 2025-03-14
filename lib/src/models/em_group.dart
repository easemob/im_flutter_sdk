import '../internal/inner_headers.dart';

/// ~english
/// The EMGroup class, which contains the information of the chat group.
/// ~end
///
/// ~chinese
/// 群组信息类，包含内存中的群组相关信息。
///
/// **Note**
/// 如需最新数据，需先从服务器获取：[EMGroupManager.fetchGroupInfoFromServer]。
/// ~end
class EMGroup {
  EMGroup._private({
    required this.groupId,
    this.name,
    this.description,
    this.owner,
    this.announcement,
    this.memberCount,
    this.memberList,
    this.adminList,
    this.blockList,
    this.muteList,
    this.messageBlocked,
    this.isAllMemberMuted,
    this.permissionType,
    this.maxUserCount,
    this.isMemberOnly,
    this.isMemberAllowToInvite,
    this.extension,
    this.isDisabled = false,
  });

  /// ~english
  /// Gets the group ID.
  /// ~end
  ///
  /// ~chinese
  /// 群组 ID。
  /// ~end
  final String groupId;

  /// ~english
  /// Gets the group name.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMGroupManager.fetchGroupInfoFromServer] before calling this method.
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取群组名称。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取：[EMGroupManager.fetchGroupInfoFromServer]。
  ///
  /// **Return** 群组名称。
  /// ~end
  final String? name;

  /// ~english
  /// Gets the group description.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMGroupManager.fetchGroupInfoFromServer] before calling this method.
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取群组描述。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取：[EMGroupManager.fetchGroupInfoFromServer]。
  ///
  /// **Return** 群组描述。
  /// ~end
  final String? description;

  /// ~english
  /// Gets the user ID of the group owner.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMGroupManager.fetchGroupInfoFromServer] before calling this method.
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取群主用户 ID。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取：[EMGroupManager.fetchGroupInfoFromServer]。
  ///
  /// **Return** 群主用户 ID。
  /// ~end
  final String? owner;

  /// ~english
  ///  The content of the group announcement.
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取群公告内容。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取：[EMGroupManager.fetchGroupInfoFromServer]。
  /// ~end
  final String? announcement;

  /// ~english
  /// Gets the member count of the group.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMGroupManager.fetchGroupInfoFromServer] before calling this method.
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取群组成员数量。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取：[EMGroupManager.fetchGroupInfoFromServer]。
  ///
  /// **Return** 群组成员数量。
  /// ~end
  final int? memberCount;

  /// ~english
  /// Gets the member list of the group.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMGroupManager.fetchMemberListFromServer] before calling this method.
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取群组成员列表。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取：[EMGroupManager.fetchMemberListFromServer]。
  ///
  /// **Return** 群组成员列表。
  /// ~end
  final List<String>? memberList;

  /// ~english
  /// Gets the admin list of the group.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMGroupManager.fetchGroupInfoFromServer] before calling this method.
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取群组管理员列表。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取：[EMGroupManager.fetchGroupInfoFromServer]。
  ///
  /// **Return** 群组管理员列表。
  /// ~end
  final List<String>? adminList;

  /// ~english
  /// Gets the block list of the group.
  ///
  /// If no block list is found from the server, the return may be empty.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMGroupManager.fetchBlockListFromServer] before calling this method.
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取群组黑名单。
  ///
  /// 如果没有找到会返回空列表。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取：[EMGroupManager.fetchBlockListFromServer]。
  ///
  /// 只有群主和管理员可以调用该方法。
  ///
  /// **Return** 群组黑名单。
  /// ~end
  final List<String>? blockList;

  /// ~english
  /// Gets the mute list of the group.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMGroupManager.fetchMuteListFromServer] before calling this method.
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取群组禁言名单。
  ///
  /// 只有群主和管理员可以调用该方法。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取：[EMGroupManager.fetchMuteListFromServer]。
  ///
  /// **Return** 群组禁言名单。
  /// ~end
  final List<String>? muteList;

  /// ~english
  /// Gets whether the group message is blocked.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMGroupManager.fetchGroupInfoFromServer] before calling this method.
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取消息是否被屏蔽。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取： [EMGroupManager.fetchGroupInfoFromServer]。
  ///
  /// **Return** 消息是否被屏蔽。
  /// - `true`: 是；
  /// - `false`: 否。
  /// ~end
  final bool? messageBlocked;

  /// ~english
  /// Gets Whether all members are muted.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMGroupManager.fetchGroupInfoFromServer] before calling this method.
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取是否已经全员禁言。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取： [EMGroupManager.fetchGroupInfoFromServer]。
  ///
  /// **Return** 是否全员禁言。
  /// - `true`: 是；
  /// - `false`: 否。
  /// ~end
  final bool? isAllMemberMuted;

  EMGroupOptions? _options;

  /// ~english
  /// Gets the current user's role in group.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMGroupManager.fetchGroupInfoFromServer] before calling this method.
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取当前用户在群组中的角色。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取： [EMGroupManager.fetchGroupInfoFromServer]。
  ///
  /// **Return** 当前用户在群组中的角色。
  /// ~end
  final EMGroupPermissionType? permissionType;

  /// ~english
  /// Gets the maximum number of group members allowed in a group. The parameter is set when the group is created.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMGroupManager.fetchGroupInfoFromServer] before calling this method.
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取群组最大人数限制，创建时确定。
  //
  /// **Note**
  /// 如需最新数据，需先从服务器获取： [EMGroupManager.fetchGroupInfoFromServer]。
  ///
  /// **Return** 群组最大人数限制。
  /// ~end
  final int? maxUserCount;

  /// ~english
  /// Checks whether users cannot join a chat group freely:
  /// - `true`: Yes. Needs the approval from the group owner(admin) or being invited by group members(PrivateOnlyOwnerInvite, PrivateMemberCanInvite, PublicJoinNeedApproval).
  /// - `false`: No. Users can join freely [EMGroupStyle.PublicOpenJoin].
  ///
  /// **Note**
  /// There are four types of group properties used to define the style of a group: [EMGroupStyle].
  ///
  /// **Return**
  /// Whether users can join a chat group with only the approval of the group owner(admin):
  /// - `true`: Yes. Needs the approval from the group owner(admin) or being invited by group members.
  /// - `false`: No.
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取群组类型：成员是否能自由加入，还是需要申请或者被邀请。
  ///
  /// 群组有四个类型属性，`isMemberOnly`是除了 [EMGroupStyle.PublicOpenJoin] 之外的三种属性，表示该群不是自由加入的群组。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取： [EMGroupManager.fetchGroupInfoFromServer]。
  ///
  /// **Return**
  ///  - `true`：进群需要群主邀请，群成员邀请，或者群主和管理员同意入群申请；
  /// - `false`：意味着用户可以自由加入群，不需要申请和被邀请。
  /// ~end
  final bool? isMemberOnly;

  /// ~english
  /// Checks whether a group member is allowed to invite other users to join the group.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMGroupManager.fetchGroupInfoFromServer] before calling this method.
  ///
  /// **Return**
  /// - `true`: Yes;
  /// - `false`: No. Only the group owner or admin can invite others to join the group.
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取是否允许成员邀请他人进群。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取：[EMGroupManager.fetchGroupInfoFromServer]。
  ///
  /// **Return**
  /// - `true`: 允许;
  /// - `false`: 不允许。
  /// ~end
  final bool? isMemberAllowToInvite;

  /// ~english
  /// Group detail extensions which can be in the JSON format to contain more group information.
  /// ~end
  ///
  /// ~chinese
  /// 群组ext
  /// ~end
  final String? extension;

  /// ~english
  /// Whether the group is disabled. The default value for reading or pulling roaming messages from the database is NO
  /// ~end
  ///
  /// ~chinese
  /// 组是否被禁用。从数据库读取或提取漫游消息的默认值是false。
  /// ~end
  final bool isDisabled;

  @Deprecated(
      "Switch to using isMemberOnly | isMemberAllowToInvite | maxUserCount to instead")
  EMGroupOptions? get settings => _options;

  factory EMGroup.fromJson(Map map) {
    String groupId = map['groupId'];
    String? name = map["name"];
    String? description = map["desc"];
    String? owner = map["owner"];
    String? announcement = map["announcement"];
    int? memberCount = map["memberCount"];
    List<String>? memberList = map.getList("memberList");
    List<String>? adminList = map.getList("adminList");
    List<String>? blockList = map.getList("blockList");
    List<String>? muteList = map.getList("muteList");
    bool? messageBlocked = map["messageBlocked"];
    bool? isAllMemberMuted = map["isAllMemberMuted"];
    EMGroupPermissionType? permissionType =
        _EMGroupPermissionType.values(map['permissionType']);
    int? maxUserCount = map["maxUserCount"];
    bool? isMemberOnly = map["isMemberOnly"];
    bool? isMemberAllowToInvite = map["isMemberAllowToInvite"];
    bool? isDisabled = map["isDisabled"];
    String? extension = map["ext"];

    return EMGroup._private(
      groupId: groupId,
      name: name,
      description: description,
      owner: owner,
      announcement: announcement,
      memberCount: memberCount,
      memberList: memberList,
      adminList: adminList,
      blockList: blockList,
      muteList: muteList,
      messageBlocked: messageBlocked,
      isAllMemberMuted: isAllMemberMuted,
      permissionType: permissionType,
      maxUserCount: maxUserCount,
      isMemberOnly: isMemberOnly,
      isMemberAllowToInvite: isMemberAllowToInvite,
      extension: extension,
      isDisabled: isDisabled ?? false,
    );
  }

  Map toJson() {
    Map data = Map();
    data.putIfNotNull("groupId", groupId);
    data.putIfNotNull("name", name);
    data.putIfNotNull("desc", description);
    data.putIfNotNull("owner", owner);
    data.putIfNotNull("announcement", announcement);
    data.putIfNotNull("memberCount", memberCount);
    data.putIfNotNull("memberList", memberList);
    data.putIfNotNull("adminList", adminList);
    data.putIfNotNull("blockList", blockList);
    data.putIfNotNull("muteList", muteList);
    data.putIfNotNull("messageBlocked", messageBlocked);
    data.putIfNotNull("isDisabled", isDisabled);
    data.putIfNotNull("isAllMemberMuted", isAllMemberMuted);
    data.putIfNotNull("options", _options?.toJson());
    data.putIfNotNull("permissionType", permissionType?.index);
    return data;
  }

  @override
  String toString() {
    return this.toJson().toString();
  }
}

/// ~english
/// The class that defines basic information of chat groups.
/// ~end
///
/// ~chinese
/// ~end
class EMGroupInfo {
  /// ~english
  /// The group ID.
  /// ~end
  ///
  /// ~chinese
  /// ~end
  final String groupId;

  /// ~english
  /// The group name.
  /// ~end
  ///
  /// ~chinese
  /// ~end
  final String? name;

  EMGroupInfo._private({
    required this.groupId,
    required this.name,
  });

  factory EMGroupInfo.fromJson(Map map) {
    String groupId = map["groupId"];
    String? groupName = map["name"];
    return EMGroupInfo._private(
      groupId: groupId,
      name: groupName,
    );
  }
}

extension _EMGroupPermissionType on EMGroupPermissionType {
  static EMGroupPermissionType values(int type) {
    return EMGroupPermissionType.values[type + 1];
  }
}
