import '../internal/em_transform_tools.dart';

import '../tools/em_extension.dart';
import 'em_chat_enums.dart';
import 'em_group_options.dart';

/// The group class.
class EMGroup {
  EMGroup._private();

  late String _groupId;
  String? _name;
  String? _description = '';
  String? _owner = '';
  String? _announcement = '';
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

  /// The group ID.
  String get groupId => _groupId;

  /// The group name.
  String? get name => _name;

  /// The group description.
  String? get description => _description;

  /// The user ID of the group owner.
  String? get owner => _owner;

  ///  The content of the group announcement.
  String? get announcement => _announcement;

  /// The member count of the group.
  int? get memberCount => _memberCount;
  List? get memberList => _memberList;

  ///
  /// The admin list of the group.
  ///
  /// Be sure to fetch the detail specification of the group from the server first, see {@link EMGroupManager#getGroupSpecificationFromServer(String)}.
  ///
  List? get adminList => _adminList;

  ///
  /// The block list of the group.
  ///
  /// If no block list is found from the server, the return may be empty.
  ///
  /// Reference:
  /// To fetch the block list, call {@link EMGroupManager#getBlockListFromServer(String, int?, int?)}
  ///
  /// Only the group owner or admin can call this method.
  ///
  List? get blockList => _blockList;

  ///
  /// The mute list of the group.
  ///
  /// Reference:
  /// You can also fetch the mute list by calling {@link}
  ///
  /// And only the group owner or admin can call this method.
  ///
  List? get muteList => _muteList;

  @Deprecated("")
  bool? get noticeEnable => _noticeEnable;

  ///
  /// Gets whether the group message is blocked.
  ///
  bool? get messageBlocked => _messageBlocked;

  ///
  /// Whether all members are muted.
  ///
  /// This method has limitations and is recommended to be used with caution.
  ///
  /// The state is updated when a all-muted/all-unmuted callback is received, but only for the in-memory object.
  /// After the in-memory object is collected and pulled again from the database or server, the state becomes unreliable.
  ///
  bool? get isAllMemberMuted => _isAllMemberMuted;

  @Deprecated(
      "Switch to using isMemberOnly | isMemberAllowToInvite | maxUserCount to instead.")
  EMGroupOptions? get settings => _options;

  /// The current user's role in group.
  EMGroupPermissionType? get permissionType => _permissionType;

  ///
  /// The max number of group members allowed in a group. The param is set when the group is created.
  ///
  /// Be sure to fetch the detail specification of the group from the server first, see {@link EMGroupManager#getGroupSpecificationFromServer(String)}. If not, the SDK returns nil.
  ///
  /// **return** The allowed max number of group members.
  ///
  int? get maxUserCount => _options?.maxCount;

  ///
  /// Fetches the group property: whether users can auto join the group VS need requesting or invitation from a group member to join the group.
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
