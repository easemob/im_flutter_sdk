

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
  /// get chat room administrator list, if not fetch the chat room's detail specification, return result can be empty
  List getAdminList(){
     return _administratorList;
  }

  /// @nodoc 返回成员列表
  /// @nodoc return member list
  List getMemberList(){
     return _memberList;
  }

  /// @nodoc 返回聊天室黑名单
  /// return black list
  List getBlackList(){
     return _blockList;
  }

  /// @nodoc 返回禁言列表, Map.entry.key 是禁言的成员id，Map.entry.value是禁言动作存在的时间，单位是毫秒。
  /// @nodoc return mute list, Map.entry.key is username of mute action, Map.entry.value is expired time of banning post action, in milli-seconds
  List getMuteList(){
     return _muteList;
  }

  /// @nodoc 获取聊天室公告
  /// @nodoc get chatroom announcement
  String getAnnouncement(){
     return _announcement;
  }

  String getId(){
    return _roomId;
  }

  String getName(){
    return _roomName;
  }

  String getDescription(){
    return _description;
  }

  /// @nodoc 获取聊天室的所有者，如果没有获取聊天室详情，返回可能为空
  String getOwner(){
    return _owner;
  }

  /// @nodoc 返回在线成员人数
  /// @nodoc return online member count
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