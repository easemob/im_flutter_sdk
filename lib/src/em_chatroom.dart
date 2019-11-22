

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

  /// @nodoc 返回成员列表
  List getMemberList(){
     return _memberList;
  }

  /// @nodoc 返回聊天室黑名单
  List getBlackList(){
     return _blockList;
  }

  /// @nodoc return mute list, Map.entry.key is username of mute action, Map.entry.value is expired time of banning post action, in milli-seconds
  List getMuteList(){
     return _muteList;
  }

  /// @nodoc 获取聊天室公告
  String getAnnouncement(){
     return _announcement;
  }

  /// @nodoc 获取聊天室ID
  String getId(){
    return _roomId;
  }

  /// @nodoc 获取聊天室名称
  String getName(){
    return _roomName;
  }

  /// @nodoc 获取聊天室详情
  String getDescription(){
    return _description;
  }

  /// @nodoc 获取聊天室的所有者，如果没有获取聊天室详情，返回可能为空
  String getOwner(){
    return _owner;
  }

  /// @nodoc 返回在线成员人数
  int getMemberCount(){
    return _affiliationsCount;
  }

  int getMaxUsers(){
    return _maxUserCount;
  }

  getPermissionType(){
    return _permissionType;
  }

  @override
  String toString() =>
      '[EMChatRoom],{ roomId: $_roomId, roomName: $_roomName, description: $_description'
          ' owner: $_owner, announcement: $_announcement, affiliationsCount: $_affiliationsCount'
          ' administratorList: $_administratorList, maxUserCount: $_maxUserCount, memberList: $_memberList'
          ' blockList: $_blockList, muteList: $_muteList}';

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

enum EMChatRoomPermissionType{
  EMChatRoomPermissionTypeNone,
  EMChatRoomPermissionMember,
  EMChatRoomPermissionAdmin,
  EMChatRoomPermissionOwner,
}