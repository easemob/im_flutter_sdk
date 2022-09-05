import '../internal/inner_headers.dart';

///
/// The EMGroup class, which contains the information of the chat group.
///
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
    this.isDisabled: false,
  });

  ///
  /// Gets the group ID.
  ///
  final String groupId;

  ///
  /// Gets the group name.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMGroupManager.fetchGroupInfoFromServer] before calling this method.
  ///

  final String? name;

  ///
  /// Gets the group description.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMGroupManager.fetchGroupInfoFromServer] before calling this method.
  ///

  final String? description;

  ///
  /// Gets the user ID of the group owner.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMGroupManager.fetchGroupInfoFromServer] before calling this method.
  ///
  final String? owner;

  ///
  ///  The content of the group announcement.
  ///
  final String? announcement;

  ///
  /// Gets the member count of the group.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMGroupManager.fetchGroupInfoFromServer] before calling this method.
  ///
  final int? memberCount;

  ///
  /// Gets the member list of the group.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMGroupManager.fetchMemberListFromServer] before calling this method.
  ///

  final List<String>? memberList;

  ///
  /// Gets the admin list of the group.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMGroupManager.fetchGroupInfoFromServer] before calling this method.
  ///

  final List<String>? adminList;

  ///
  /// Gets the block list of the group.
  ///
  /// If no block list is found from the server, the return may be empty.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMGroupManager.fetchBlockListFromServer] before calling this method.
  ///
  final List<String>? blockList;

  ///
  /// Gets the mute list of the group.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMGroupManager.fetchMuteListFromServer] before calling this method.
  ///
  final List<String>? muteList;

  ///
  /// Gets whether the group message is blocked.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMGroupManager.fetchGroupInfoFromServer] before calling this method.
  ///
  final bool? messageBlocked;

  ///
  /// Gets Whether all members are muted.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMGroupManager.fetchGroupInfoFromServer] before calling this method.
  ///
  final bool? isAllMemberMuted;

  ///
  EMGroupOptions? _options;

  ///
  /// Gets the current user's role in group.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMGroupManager.fetchGroupInfoFromServer] before calling this method.
  ///
  final EMGroupPermissionType? permissionType;

  ///
  /// Gets the maximum number of group members allowed in a group. The parameter is set when the group is created.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMGroupManager.fetchGroupInfoFromServer] before calling this method.
  ///
  final int? maxUserCount;

  ///
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
  ///
  final bool? isMemberOnly;

  ///
  /// Checks whether a group member is allowed to invite other users to join the group.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMGroupManager.fetchGroupInfoFromServer] before calling this method.
  ///
  /// **Return**
  /// - `true`: Yes;
  /// - `false`: No. Only the group owner or admin can invite others to join the group.
  ///
  final bool? isMemberAllowToInvite;

  ///
  /// Group detail extensions which can be in the JSON format to contain more group information.
  ///
  final String? extension;

  ///
  /// Whether the group is disabled. The default value for reading or pulling roaming messages from the database is NO
  ///
  final bool isDisabled;

  @Deprecated(
      "Switch to using isMemberOnly | isMemberAllowToInvite | maxUserCount to instead.")
  EMGroupOptions? get settings => _options;

  /// @nodoc
  factory EMGroup.fromJson(Map map) {
    String groupId = map['groupId'];
    String? name = map.stringValue("name");
    String? description = map.stringValue("desc");
    String? owner = map.stringValue("owner");
    String? announcement = map.stringValue("announcement");
    int? memberCount = map["memberCount"];
    List<String>? memberList = map.listValue<String>("memberList");
    List<String>? adminList = map.listValue<String>("adminList");
    List<String>? blockList = map.listValue<String>("blockList");
    List<String>? muteList = map.listValue<String>("muteList");
    bool? messageBlocked = map.getBoolValue('messageBlocked');
    bool? isAllMemberMuted = map.getBoolValue('isAllMemberMuted');
    EMGroupPermissionType? permissionType =
        permissionTypeFromInt(map['permissionType']);
    int? maxUserCount = map.intValue("maxUserCount");
    bool? isMemberOnly = map.getBoolValue('isMemberOnly');
    bool? isMemberAllowToInvite = map.getBoolValue('isMemberAllowToInvite');
    bool? isDisabled = map.getBoolValue("isDisabled");
    String? extension = map.getStringValue("ext");

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

  /// @nodoc
  Map toJson() {
    Map data = Map();
    data.setValueWithOutNull("groupId", groupId);
    data.setValueWithOutNull("name", name);
    data.setValueWithOutNull("desc", description);
    data.setValueWithOutNull("owner", owner);
    data.setValueWithOutNull("announcement", announcement);
    data.setValueWithOutNull("memberCount", memberCount);
    data.setValueWithOutNull("memberList", memberList);
    data.setValueWithOutNull("adminList", adminList);
    data.setValueWithOutNull("blockList", blockList);
    data.setValueWithOutNull("muteList", muteList);
    data.setValueWithOutNull("messageBlocked", messageBlocked);
    data.setValueWithOutNull("isDisabled", isDisabled);
    data.setValueWithOutNull("isAllMemberMuted", isAllMemberMuted);
    data.setValueWithOutNull("options", _options?.toJson());
    data.setValueWithOutNull(
        "permissionType", permissionTypeToInt(permissionType));
    return data;
  }

  @override
  String toString() {
    return this.toJson().toString();
  }
}

///
/// The class that defines basic information of chat groups.
///
class EMGroupInfo {
  /// The group ID.
  final String groupId;

  /// The group name.
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
