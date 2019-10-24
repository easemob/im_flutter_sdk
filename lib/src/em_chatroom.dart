

class EMChatRoom{
  String roomId;
  String roomName;
  String description;
  String owner;
  String announcement;
  int affiliationsCount;
  int maxUserCount;
  List administratorList;
  List memberList;
  List blockList;
  Map muteList;


  EMChatRoom.from(Map data)
      : roomId = data['roomId'],
        roomName = data['roomName'],
        description = data['description'],
        owner = data['owner'],
        affiliationsCount = data['affiliationsCount'],
        maxUserCount = data['maxUserCount'],
        administratorList = data['administratorList'],
        memberList = data['memberList'],
        blockList = data['blockList'],
        muteList = data['muteList'],
        announcement = data['announcement'];


  ///获取聊天室的管理员列表，如果没有获取聊天室详情，返回可能为空
  ///get chat room administrator list, if not fetch the chat room's detail specification, return result can be empty
  List getAdminList(){
     return administratorList;
  }

  ///返回成员列表
  ///return member list
  List getMemberList(){
     return memberList;
  }

  ///返回聊天室黑名单
  ///return black list
  List getBlackList(){
     return blockList;
  }

  ///返回禁言列表, Map.entry.key 是禁言的成员id，Map.entry.value是禁言动作存在的时间，单位是毫秒。
  ///return mute list, Map.entry.key is username of mute action, Map.entry.value is expired time of banning post action, in milli-seconds
  Map getMuteList(){
     return muteList;
  }

  String getAnnouncement(){
     return announcement;
  }

  String getId(){
    return roomId;
  }

  String getName(){
    return roomName;
  }

  String getDescription(){
    return description;
  }

  /// 获取聊天室的所有者，如果没有获取聊天室详情，返回可能为空
  String getOwner(){
    return owner;
  }

  int getMemberCount(){
    return affiliationsCount;
  }
  int getMaxUsers(){
    return maxUserCount;
  }

  String toString(){
    return  "----roomId---->" + roomId + "----roomName---->" + roomName +
            "----description---->" + description + "----owner---->" + owner +
            "----announcement---->" + announcement + "----affiliationsCount---->" + affiliationsCount.toString() +
            "----administratorList---->" + administratorList.toString() + "----maxUserCount---->" + maxUserCount.toString() +
            "----memberList---->" + memberList.toString() + "----blockList---->" + blockList.toString() +
            "----muteList---->" + muteList.toString();
  }
}