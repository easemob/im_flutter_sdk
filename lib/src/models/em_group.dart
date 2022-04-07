import '../internal/em_transform_tools.dart';

import '../tools/em_extension.dart';
import 'em_chat_enums.dart';
import 'em_group_options.dart';

///
/// The group class.
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
  /// To get the correct value, ensure that you call {@ link EMGroupManager#getGroupSpecificationFromServer(String groupId)} before calling this method.
  ///
  String? get name => _name;

  ///
  /// Gets the group description.
  ///
  /// To get the correct value, ensure that you call {@ link EMGroupManager#getGroupSpecificationFromServer(String groupId)} before calling this method.
  ///
  String? get description => _description;

  ///
  /// Gets the user ID of the group owner.
  ///
  /// To get the correct value, ensure that you call {@ link EMGroupManager#getGroupSpecificationFromServer(String groupId)} before calling this method.
  ///
  String? get owner => _owner;

  ///  The content of the group announcement.
  String? get announcement => _announcement;

  ///
  /// Get the member count of the group.
  ///
  /// To get the correct value, ensure that you call {@ link EMGroupManager#getGroupSpecificationFromServer(String groupId)} before calling this method.
  ///
  int? get memberCount => _memberCount;

  ///
  /// Get the member list of the group.
  ///
  /// To get the correct value, ensure that you call {@ link EMGroupManager#getGroupMemberListFromServer(String, int?, String?)} before calling this method.
  ///
  List? get memberList => _memberList;

  ///
  /// Get the admin list of the group.
  ///
  /// To get the correct value, ensure that you call {@ link EMGroupManager#getGroupSpecificationFromServer(String)} before calling this method.
  ///
  List? get adminList => _adminList;

  ///
  /// Get the block list of the group.
  ///
  /// If no block list is found from the server, the return may be empty.
  ///
  /// Reference:
  /// To get the correct value, ensure that you call {@link EMGroupManager#getBlockListFromServer(String, int?, int?)} before calling this method.
  ///
  List? get blockList => _blockList;

  ///
  /// Get the mute list of the group.
  ///
  /// To get the correct value, ensure that you call {@link EMGroupManager#getMuteListFromServer(String, int?, int?)} before calling this method.
  ///
  List? get muteList => _muteList;

  @Deprecated("")
  bool? get noticeEnable => _noticeEnable;

  ///
  /// Gets whether the group message is blocked.
  ///
  /// To get the correct value, ensure that you call {@link EMGroupManager#getGroupSpecificationFromServer(String)} before calling this method.
  ///
  bool? get messageBlocked => _messageBlocked;

  ///
  /// Gets Whether all members are muted.
  ///
  /// To get the correct value, ensure that you call {@link EMGroupManager#getGroupSpecificationFromServer(String)} before calling this method.
  ///
  bool? get isAllMemberMuted => _isAllMemberMuted;

  @Deprecated(
      "Switch to using isMemberOnly | isMemberAllowToInvite | maxUserCount to instead.")
  EMGroupOptions? get settings => _options;

  ///
  /// Get the current user's role in group.
  ///
  /// To get the correct value, ensure that you call {@link EMGroupManager#getGroupSpecificationFromServer(String)} before calling this method.
  ///
  EMGroupPermissionType? get permissionType => _permissionType;

  ///
  /// Get the max number of group members allowed in a group. The param is set when the group is created.
  ///
  /// To get the correct value, ensure that you call {@link EMGroupManager#getGroupSpecificationFromServer(String)} before calling this method.
  ///
  int? get maxUserCount => _options?.maxCount;

  ///
  /// Fetches the group property: whether users can auto join the group VS need requesting or invitation from a group member to join the group.
  ///
  ///
  /// To get the correct value, ensure that you call {@link EMGroupManager#getGroupSpecificationFromServer(String)} before calling this method.
  ///
  /// There are four types of group properties used to define the style of a group,
  /// and `isMemberOnly` contains three types including:
  /// PrivateOnlyOwnerInvite,
  /// PrivateMemberCanInvite,
  /// PublicJoinNeedApproval.
  /// And do not include {@link EMGroupManager.EMGroupStyle#PublicOpenJoin}.
  ///
  /// **return**
  /// `true`: Users can not join the group freely. Needs the invitation from the group owner or members, or the application been approved by the group owner or admins.
  /// `false`: Users can join freely without the group owner or member‘s invitation or the new joiner’s application been approved.
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
  /// Gets whether the group member is allowed to invite other users to join the group.
  ///
  ///
  /// To get the correct value, ensure that you call {@link EMGroupManager#getGroupSpecificationFromServer(String)} before calling this method.
  ///
  /// **return**
  /// `true`: The group member can invite other users to join the group;
  /// `false`: Do not allow the group member invite other users to join the group.
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
      .._memberCount = map['memberCount']
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
    data.setValueWithOutNull("owner", _owner);
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
