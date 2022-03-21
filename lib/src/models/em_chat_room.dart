import '../../src/tools/em_extension.dart';

enum EMChatRoomPermissionType {
  None,
  Member,
  Admin,
  Owner,
}

class EMChatRoom {
  EMChatRoom._private();

  String toString() => toJson().toString();

  factory EMChatRoom.fromJson(Map<String, dynamic> map) {
    return EMChatRoom._private()
      .._roomId = map['roomId'] as String
      .._name = map.stringValue("name")
      .._description = map.stringValue("desc")
      .._owner = map.stringValue("owner")
      .._memberCount = map.intValue("memberCount")
      .._maxUsers = map.intValue("maxUsers")
      .._adminList = map.listValue<String>("adminList")
      .._memberList = map.listValue<String>("memberList")
      .._blockList = map.listValue<String>("blockList")
      .._muteList = map.listValue<String>("muteList")
      .._announcement = map.stringValue("announcement")
      .._permissionType =
          EMChatRoom.permissionTypeFromInt(map['permissionType'])
      .._isAllMemberMuted = map.boolValue('isAllMemberMuted');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['roomId'] = _roomId;
    data.setValueWithOutNull("name", _name);
    data.setValueWithOutNull("desc", _description);
    data.setValueWithOutNull("owner", owner);
    data.setValueWithOutNull("memberCount", _memberCount);
    data.setValueWithOutNull("maxUsers", _maxUsers);
    data.setValueWithOutNull("adminList", _adminList);
    data.setValueWithOutNull("memberList", _memberList);
    data.setValueWithOutNull("blockList", _blockList);
    data.setValueWithOutNull("muteList", _muteList);
    data.setValueWithOutNull("announcement", _announcement);
    data.setValueWithOutNull("isAllMemberMuted", _isAllMemberMuted);
    data['permissionType'] = EMChatRoom.permissionTypeToInt(_permissionType);

    return data;
  }

  // 房间id
  late String _roomId;
  // 房间名称
  String? _name = '';
  // 房间描述
  String? _description = '';
  // 房主
  String? _owner = '';
  //公告
  String? _announcement = '';
  // 当前人数
  int? _memberCount = 0;
  // 最大人数
  int? _maxUsers = 0;
  // 管理员列表
  List? _adminList;
  // 成员列表
  List? _memberList;
  // 黑名单列表
  List? _blockList;
  // 禁言列表
  List? _muteList;
  // 是否全员禁言
  bool? _isAllMemberMuted;
  // 在聊天室中的角色
  EMChatRoomPermissionType _permissionType = EMChatRoomPermissionType.None;

  String get roomId => _roomId;
  get name => _name;
  get description => _description;
  get owner => _owner;
  get announcement => _announcement;
  get memberCount => _memberCount;
  get maxUsers => _maxUsers;
  get adminList => _adminList;
  get memberList => _memberList;
  get blockList => _blockList;
  get muteList => _muteList;
  get isAllMemberMuted => _isAllMemberMuted;
  get permissionType => _permissionType;

  static EMChatRoomPermissionType permissionTypeFromInt(int? type) {
    EMChatRoomPermissionType ret = EMChatRoomPermissionType.Member;
    switch (type) {
      case -1:
        return EMChatRoomPermissionType.None;
      case 0:
        return EMChatRoomPermissionType.Member;
      case 1:
        return EMChatRoomPermissionType.Admin;
      case 2:
        return EMChatRoomPermissionType.Owner;
    }
    return ret;
  }

  static int permissionTypeToInt(EMChatRoomPermissionType type) {
    int ret = 0;
    switch (type) {
      case EMChatRoomPermissionType.None:
        ret = -1;
        break;
      case EMChatRoomPermissionType.Member:
        ret = 0;
        break;
      case EMChatRoomPermissionType.Admin:
        ret = 1;
        break;
      case EMChatRoomPermissionType.Owner:
        ret = 2;
        break;
    }
    return ret;
  }
}
