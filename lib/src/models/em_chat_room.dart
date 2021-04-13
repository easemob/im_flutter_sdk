import 'package:im_flutter_sdk/src/models/em_domain_terms.dart';

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
    if (map == null) return null;
    return EMChatRoom._private()
      .._roomId = map['roomId'] as String
      .._name = map['name']
      .._description = map['desc']
      .._owner = map['owner']
      .._memberCount = map['memberCount']
      .._maxUsers = map['maxUsers']
      .._adminList = map['adminList']
      .._memberList = map['memberList']
      .._blockList = map['blockList']
      .._muteList = map['muteList']
      .._announcement = map['announcement']
      .._permissionType = EMChatRoom.permissionTypeFromInt(map['permissionType'])
      .._isAllMemberMuted = map.boolValue('isAllMemberMuted');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['roomId'] = _roomId;
    data['name'] = _name;
    data['desc'] = _description;
    data['owner'] = _owner;
    data['memberCount'] = _memberCount;
    data['maxUsers'] = _maxUsers;
    data['adminList'] = _adminList;
    data['memberList'] = _memberList;
    data['blockList'] = _blockList;
    data['muteList'] = _muteList;
    data['announcement'] = _announcement;
    data['permissionType'] = EMChatRoom.permissionTypeToInt(_permissionType);
    data['isAllMemberMuted'] = _isAllMemberMuted;

    return data;
  }

  // 房间id
  String _roomId = '';
  // 房间名称
  String _name = '';
  // 房间描述
  String _description = '';
  // 房主
  String _owner = '';
  //公告
  String _announcement = '';
  // 当前人数
  int _memberCount = 0;
  // 最大人数
  int _maxUsers = 0;
  // 管理员列表
  List _adminList;
  // 成员列表
  List _memberList;
  // 黑名单列表
  List _blockList;
  // 禁言列表
  List _muteList;
  // 是否全员禁言
  bool _isAllMemberMuted;
  // 在聊天室中的角色
  EMChatRoomPermissionType _permissionType = EMChatRoomPermissionType.None;

  get roomId => _roomId;
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

  static EMChatRoomPermissionType permissionTypeFromInt(int type) {
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
        return -1;
      case EMChatRoomPermissionType.Member:
        return 0;
      case EMChatRoomPermissionType.Admin:
        return 1;
      case EMChatRoomPermissionType.Owner:
        return 2;
    }
    return ret;
  }
}
