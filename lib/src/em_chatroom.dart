

class EMChatRoom{
  String _roomId;
  String _roomName;
  String _description;
  String _owner;
  String _announcement;
  int _affiliationsCount;
  int _maxUserCount;
  List _administratorList;
  List _memberList;
  List _blockList;
  List _muteList;
  EMChatRoomPermissionType _permissionType;


  /// @nodoc
  EMChatRoom.from(Map data)
      : _roomId = data['roomId'],
        _roomName = data['roomName'],
        _description = data['description'],
        _owner = data['owner'],
        _affiliationsCount = data['affiliationsCount'],
        _maxUserCount = data['maxUserCount'],
        _administratorList = data['administratorList'],
        _memberList = data['memberList'],
        _blockList = data['blockList'],
        _muteList = data['muteList'],
        _permissionType = toPermissionType(data['permissionType']),
        _announcement = data['announcement'];


  /// 获取聊天室的管理员列表，如果没有获取聊天室详情，返回可能为空
  List getAdminList(){
     return _administratorList;
  }

  /// 返回成员列表
  List getMemberList(){
     return _memberList;
  }

  /// @nodoc 返回聊天室黑名单
  List getBlackList(){
     return _blockList;
  }

  /// @nodoc 返回mute列表
  List getMuteList(){
     return _muteList;
  }

  /// 获取聊天室公告
  String getAnnouncement(){
     return _announcement;
  }

  /// 获取聊天室ID
  String getId(){
    return _roomId;
  }

  /// 获取聊天室名称
  String getName(){
    return _roomName;
  }

  /// 获取聊天室详情
  String getDescription(){
    return _description;
  }

  /// 获取聊天室的所有者，如果没有获取聊天室详情，返回可能为空
  String getOwner(){
    return _owner;
  }

  /// @nodoc 返回在线成员人数
  int getMemberCount(){
    return _affiliationsCount;
  }

  /// 获取聊天室最大用户数
  int getMaxUsers(){
    return _maxUserCount;
  }

  /// 获取权限
  getPermissionType(){
    return _permissionType;
  }

  @override
  /// @nodoc
  String toString() =>
      '[EMChatRoom],{ roomId: $_roomId, roomName: $_roomName, description: $_description'
          ' owner: $_owner, announcement: $_announcement, affiliationsCount: $_affiliationsCount'
          ' administratorList: $_administratorList, maxUserCount: $_maxUserCount, memberList: $_memberList'
          ' blockList: $_blockList, muteList: $_muteList}';

  /// @nodoc
 static EMChatRoomPermissionType toPermissionType(int type){
      switch(type){
        case 0:
          return EMChatRoomPermissionType.EMChatRoomPermissionMember;
        case 1:
          return EMChatRoomPermissionType.EMChatRoomPermissionAdmin;
        case 2:
          return EMChatRoomPermissionType.EMChatRoomPermissionOwner;
      }
      return EMChatRoomPermissionType.EMChatRoomPermissionTypeNone;
  }
}

/// 聊天室权限
enum EMChatRoomPermissionType{
  /// none
  EMChatRoomPermissionTypeNone,

  /// 成员
  EMChatRoomPermissionMember,

  /// 管理员
  EMChatRoomPermissionAdmin,

  /// 创建者
  EMChatRoomPermissionOwner,
}