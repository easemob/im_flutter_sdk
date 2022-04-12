import '../internal/em_transform_tools.dart';

import '../tools/em_extension.dart';
import 'em_chat_enums.dart';
import 'em_group_options.dart';

///
/// The EMGroup class, which contains the information of the chat group.
///
class EMGroup {
  EMGroup._private();

  late String _groupId;
  String? _name;
  String? _description;
  String? _owner;
  String? _announcement;
  int? _memberCount;
  List<String>? _memberList;
  List<String>? _adminList;
  List<String>? _blockList;
  List<String>? _muteList;

  bool? _noticeEnable = true;
  bool? _messageBlocked = false;
  bool? _isAllMemberMuted = false;
  EMGroupOptions? _options;
  EMGroupPermissionType? _permissionType;

  ///
  /// Gets the group ID.
  ///
  String get groupId => _groupId;

  ///
  /// Gets the group name.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call {@link EMGroupManager#getGroupSpecificationFromServer(String groupId)} before calling this method.
  ///
  String? get name => _name;

  ///
  /// Gets the group description.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call {@link EMGroupManager#getGroupSpecificationFromServer(String groupId)} before calling this method.
  ///
  String? get description => _description;

  ///
  /// Gets the user ID of the group owner.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call {@link EMGroupManager#getGroupSpecificationFromServer(String groupId)} before calling this method.
  ///
  String? get owner => _owner;

  ///  The content of the group announcement.
  String? get announcement => _announcement;

  ///
  /// Gets the member count of the group.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call {@link EMGroupManager#getGroupSpecificationFromServer(String groupId)} before calling this method.
  ///
  int? get memberCount => _memberCount;

  ///
  /// Gets the member list of the group.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call {@link EMGroupManager#getGroupMemberListFromServer(String, int?, String?)} before calling this method.
  ///
  List? get memberList => _memberList;

  ///
  /// Gets the admin list of the group.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call {@link EMGroupManager#getGroupSpecificationFromServer(String)} before calling this method.
  ///
  List? get adminList => _adminList;

  ///
  /// Gets the block list of the group.
  ///
  /// If no block list is found from the server, the return may be empty.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call {@link EMGroupManager#getBlockListFromServer(String, int?, int?)} before calling this method.
  ///
  List? get blockList => _blockList;

  ///
  /// Gets the mute list of the group.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call {@link EMGroupManager#getMuteListFromServer(String, int?, int?)} before calling this method.
  ///
  List? get muteList => _muteList;

  @Deprecated("")
  bool? get noticeEnable => _noticeEnable;

  ///
  /// Gets whether the group message is blocked.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call {@link EMGroupManager#getGroupSpecificationFromServer(String)} before calling this method.
  ///
  bool? get messageBlocked => _messageBlocked;

  ///
  /// Gets Whether all members are muted.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call {@link EMGroupManager#getGroupSpecificationFromServer(String)} before calling this method.
  ///
  bool? get isAllMemberMuted => _isAllMemberMuted;

  @Deprecated(
      "Switch to using isMemberOnly | isMemberAllowToInvite | maxUserCount to instead.")
  EMGroupOptions? get settings => _options;

  ///
  /// Gets the current user's role in group.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call {@link EMGroupManager#getGroupSpecificationFromServer(String)} before calling this method.
  ///
  EMGroupPermissionType? get permissionType => _permissionType;

  ///
  /// Gets the maximum number of group members allowed in a group. The parameter is set when the group is created.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call {@link EMGroupManager#getGroupSpecificationFromServer(String)} before calling this method.
  ///
  int? get maxUserCount => _options?.maxCount;

  ///
  /// Checks whether users cannot join a chat group freely:
  /// - `true`: Yes. Needs the approval from the group owner(admin) or being invited by group members(PrivateOnlyOwnerInvite, PrivateMemberCanInvite, PublicJoinNeedApproval).
  /// - `false`: No. Users can join freely(PublicOpenJoin).
  ///
  /// **Note**
  /// There are four types of group properties used to define the style of a group: {@link EMGroupManager.EMGroupStyle}.
  ///
  /// **Return**
  /// Whether users can join a chat group with only the approval of the group owner(admin):
  /// - `true`: Yes. Needs the approval from the group owner(admin) or being invited by group members.
  /// - `false`: No.
  ///
  bool get isMemberOnly {
    if (_options == null) {
      return true;
    }

    if (_options?.style == EMGroupStyle.PrivateMemberCanInvite ||
        _options?.style == EMGroupStyle.PrivateOnlyOwnerInvite ||
        _options?.style == EMGroupStyle.PublicJoinNeedApproval) {
      return true;
    }
    return false;
  }

  ///
  /// Checks whether a group member is allowed to invite other users to join the group.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call {@link EMGroupManager#getGroupSpecificationFromServer(String)} before calling this method.
  ///
  /// **Return**
  /// - `true`: Yes;
  /// - `false`: No. Only the group owner or admin can invite others to join the group.
  ///
  bool get isMemberAllowToInvite {
    if (_options == null) {
      return true;
    }
    if (_options?.style == EMGroupStyle.PrivateMemberCanInvite) {
      return true;
    }

    return false;
  }

  /// @nodoc
  factory EMGroup.fromJson(Map map) {
    return EMGroup._private()
      .._groupId = map['groupId']
      .._name = map.stringValue("name")
      .._description = map.stringValue("desc")
      .._owner = map.stringValue("owner")
      .._announcement = map.stringValue("announcement")
      .._memberCount = map["memberCount"]
      .._memberList = map.listValue<String>("memberList")
      .._adminList = map.listValue<String>("adminList")
      .._blockList = map.listValue<String>("blockList")
      .._muteList = map.listValue<String>("muteList")
      .._noticeEnable = map.boolValue('noticeEnable')
      .._messageBlocked = map.boolValue('messageBlocked')
      .._isAllMemberMuted = map.boolValue('isAllMemberMuted')
      .._options = EMGroupOptions.fromJson(map['options'])
      .._permissionType = permissionTypeFromInt(map['permissionType']);
  }

  /// @nodoc
  Map toJson() {
    Map data = Map();
    data.setValueWithOutNull("id", _groupId);
    data.setValueWithOutNull("name", _name);
    data.setValueWithOutNull("desc", _description);
    data.setValueWithOutNull("owner", _owner);
    data.setValueWithOutNull("announcement", _announcement);
    data.setValueWithOutNull("memberCount", _memberCount);
    data.setValueWithOutNull("memberList", _memberList);
    data.setValueWithOutNull("adminList", _adminList);
    data.setValueWithOutNull("blockList", _blockList);
    data.setValueWithOutNull("muteList", _muteList);
    data.setValueWithOutNull("noticeEnable", _noticeEnable);
    data.setValueWithOutNull("messageBlocked", _messageBlocked);
    data.setValueWithOutNull("isAllMemberMuted", _isAllMemberMuted);
    data.setValueWithOutNull("options", _options?.toJson());
    data.setValueWithOutNull(
        "permissionType", permissionTypeToInt(_permissionType));
    return data;
  }

  @override
  String toString() {
    return this.toJson().toString();
  }
}
