import '../tools/em_extension.dart';

enum EMGroupStyle {
  PrivateOnlyOwnerInvite, // 私有群，只有群主能邀请他人进群，被邀请人会收到邀请信息，同意后可入群；
  PrivateMemberCanInvite, // 私有群，所有人都可以邀请他人进群，被邀请人会收到邀请信息，同意后可入群；
  PublicJoinNeedApproval, // 公开群，可以通过获取公开群列表api取的，申请加入时需要管理员以上权限用户同意；
  PublicOpenJoin, // 公开群，可以通过获取公开群列表api取的，可以直接进入；
}

enum EMGroupPermissionType {
  None,
  Member,
  Admin,
  Owner,
}

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

  String get groupId => _groupId;
  String? get name => _name;
  String? get description => _description;
  String? get owner => _owner;
  String? get announcement => _announcement;
  int? get memberCount => _memberCount;
  List? get memberList => _memberList;
  List? get adminList => _adminList;
  List? get blockList => _blockList;
  List? get muteList => _muteList;
  bool? get noticeEnable => _noticeEnable;
  bool? get messageBlocked => _messageBlocked;
  bool? get isAllMemberMuted => _isAllMemberMuted;
  EMGroupOptions? get settings => _options;
  EMGroupPermissionType? get permissionType => _permissionType;

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
      .._permissionType = EMGroup.permissionTypeFromInt(map['permissionType']);
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
        "permissionType", EMGroup.permissionTypeToInt(_permissionType));
    return data;
  }

  static EMGroupPermissionType permissionTypeFromInt(int? type) {
    EMGroupPermissionType ret = EMGroupPermissionType.Member;
    switch (type) {
      case -1:
        {
          ret = EMGroupPermissionType.None;
        }
        break;
      case 0:
        {
          ret = EMGroupPermissionType.Member;
        }
        break;
      case 1:
        {
          ret = EMGroupPermissionType.Admin;
        }
        break;
      case 2:
        {
          ret = EMGroupPermissionType.Owner;
        }
        break;
    }
    return ret;
  }

  static int permissionTypeToInt(EMGroupPermissionType? type) {
    int ret = 0;
    if (type == null) return ret;
    switch (type) {
      case EMGroupPermissionType.None:
        {
          ret = -1;
        }
        break;
      case EMGroupPermissionType.Member:
        {
          ret = 0;
        }
        break;
      case EMGroupPermissionType.Admin:
        {
          ret = 1;
        }
        break;
      case EMGroupPermissionType.Owner:
        {
          ret = 2;
        }
        break;
    }
    return ret;
  }

  @override
  String toString() {
    return this.toJson().toString();
  }
}

class EMGroupOptions {
  EMGroupOptions._private();

  EMGroupOptions(
      {required EMGroupStyle style,
      int count = 200,
      bool inviteNeedConfirm = false,
      String extension = ''}) {
    _style = style;
    _maxCount = count;
    _inviteNeedConfirm = inviteNeedConfirm;
    _ext = extension;
  }

  EMGroupStyle? _style;
  int? _maxCount;
  bool? _inviteNeedConfirm;
  String? _ext;

  EMGroupStyle? get style => _style;
  int? get maxCount => _maxCount;
  bool? get inviteNeedConfirm => _inviteNeedConfirm;
  String? get ext => _ext;

  factory EMGroupOptions.fromJson(Map? map) {
    return EMGroupOptions._private()
      .._style = EMGroupOptions.styleTypeFromInt(map?['style'])
      .._maxCount = map?['maxCount']
      .._ext = map?['ext']
      .._inviteNeedConfirm = map?.boolValue('inviteNeedConfirm');
  }

  Map toJson() {
    Map data = Map();
    data['style'] = EMGroupOptions.styleTypeToInt(_style);
    data['maxCount'] = _maxCount;
    data['inviteNeedConfirm'] = _inviteNeedConfirm;
    data['ext'] = _ext;
    return data;
  }

  static EMGroupStyle styleTypeFromInt(int? type) {
    EMGroupStyle ret = EMGroupStyle.PrivateOnlyOwnerInvite;
    switch (type) {
      case 0:
        {
          ret = EMGroupStyle.PrivateOnlyOwnerInvite;
        }
        break;
      case 1:
        {
          ret = EMGroupStyle.PrivateMemberCanInvite;
        }
        break;
      case 2:
        {
          ret = EMGroupStyle.PublicJoinNeedApproval;
        }
        break;
      case 3:
        {
          ret = EMGroupStyle.PublicOpenJoin;
        }
        break;
    }
    return ret;
  }

  static int styleTypeToInt(EMGroupStyle? type) {
    int ret = 0;
    if (type == null) return ret;
    switch (type) {
      case EMGroupStyle.PrivateOnlyOwnerInvite:
        {
          ret = 0;
        }
        break;
      case EMGroupStyle.PrivateMemberCanInvite:
        {
          ret = 1;
        }
        break;
      case EMGroupStyle.PublicJoinNeedApproval:
        {
          ret = 2;
        }
        break;
      case EMGroupStyle.PublicOpenJoin:
        {
          ret = 3;
        }
        break;
    }
    return ret;
  }

  @override
  String toString() {
    return this.toJson().toString();
  }
}
