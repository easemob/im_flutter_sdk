import '../im_flutter_sdk.dart';


/// EMDeviceInfo - device info.
class EMDeviceInfo {
  /// 设备资源描述
  final String resource;

  /// 设备的UUID
  final String deviceUUID;

  /// 设备名称
  final String deviceName;

  /// nodoc
  EMDeviceInfo(String resource, String deviceUUID, String deviceName)
      : resource = resource,
        deviceUUID = deviceUUID,
        deviceName = deviceName;
}

/// @nodoc EMCheckType - check type enumeration.
enum EMCheckType {
  ACCOUNT_VALIDATION,
  GET_DNS_LIST_FROM_SERVER,
  GET_TOKEN_FROM_SERVER,
  DO_LOGIN,
  DO_MSG_SEND,
  DO_LOGOUT,
}

/// @nodoc EMSearchDirection - Search direction.
enum EMSearchDirection { Up, Down }

//class EMGroupOptions {
//  /// GroupOptions
//  EMGroupOptions({
//    this.maxUsers = 200,
//    this.style = EMGroupStyle.EMGroupStylePrivateOnlyOwnerInvite,
//  });
//
//  /// 群人数上限
//  int maxUsers;
//
//  /// 群类型
//  EMGroupStyle style;
//}

///// 群组类型
//enum EMGroupStyle {
//  /// 私有群，只有群主可邀请
//  EMGroupStylePrivateOnlyOwnerInvite,
//
//  /// 私有群，成员都可邀请
//  EMGroupStylePrivateMemberCanInvite,
//
//  /// 共有群，加入需要申请
//  EMGroupStylePublicJoinNeedApproval,
//
//  /// 共有群，任何人可加入
//  EMGroupStylePublicOpenJoin,
//}
//
///// @nodoc
//int convertEMGroupStyleToInt(EMGroupStyle style) {
//  if (style == EMGroupStyle.EMGroupStylePrivateOnlyOwnerInvite) {
//    return 0;
//  }
//  if (style == EMGroupStyle.EMGroupStylePrivateMemberCanInvite) {
//    return 1;
//  }
//  if (style == EMGroupStyle.EMGroupStylePublicJoinNeedApproval) {
//    return 2;
//  }
//  if (style == EMGroupStyle.EMGroupStylePublicOpenJoin) {
//    return 3;
//  }
//  return 0;
//}

class EMMucSharedFile {
  String _fileId;
  String _fileName;
  String _fileOwner;
  int _updateTime;
  int _fileSize;

  /// 获取文件id
  String getFileId() {
    return _fileId;
  }

  /// 获取文件文件
  String getFileName() {
    return _fileName;
  }

  /// 获取文件上传者
  String getFileOwner() {
    return _fileOwner;
  }

  /// 获取文件更新时间
  int getFileUpdateTime() {
    return _updateTime;
  }

  /// 获取文件大小
  int getFileSize() {
    return _fileSize;
  }

  /// @nodoc
  EMMucSharedFile.from(Map<String, dynamic> data)
      : _fileId = data['fileId'],
        _fileName = data['fileName'],
        _fileOwner = data['fileOwner'],
        _updateTime = data['updateTime'],
        _fileSize = data['fileSize'];

  /// @nodoc
  String toString() {
    return 'fileId:' +
        _fileId +
        "--" +
        'fileName:' +
        _fileName +
        "--" +
        'fileOwner:' +
        _fileOwner +
        "--" +
        'updateTime:' +
        _updateTime.toString() +
        "--" +
        'fileSize:' +
        _fileSize.toString();
  }
}
//
///// 群组详情
//class EMGroupInfo {
//  String _groupId;
//  String _groupName;
//
//  /// 获取群id
//  String getGroupId() {
//    return _groupId;
//  }
//
//  /// 获取群名称
//  String getGroupName() {
//    return _groupName;
//  }
//
//  /// @nodoc
//  EMGroupInfo.from(Map<String, dynamic> data)
//      : _groupId = data['groupId'],
//        _groupName = data['groupName'];
//}

///// 群成员权限
//enum EMGroupPermissionType {
//  /// none
//  EMGroupPermissionTypeNone,
//
//  /// 群成员
//  EMGroupPermissionTypeMember,
//
//  /// 群管理员
//  EMGroupPermissionTypeAdmin,
//
//  /// 群拥有者
//  EMGroupPermissionTypeOwner,
//}
//
///// @nodoc
//EMGroupPermissionType convertIntToEMGroupPermissionType(int i) {
//  if (i == -1) {
//    return EMGroupPermissionType.EMGroupPermissionTypeNone;
//  }
//  if (i == 0) {
//    return EMGroupPermissionType.EMGroupPermissionTypeMember;
//  }
//  if (i == 1) {
//    return EMGroupPermissionType.EMGroupPermissionTypeAdmin;
//  }
//  if (i == 2) {
//    return EMGroupPermissionType.EMGroupPermissionTypeOwner;
//  }
//  return EMGroupPermissionType.EMGroupPermissionTypeNone;
//}

/// @nodoc 会话类型 EMConversationType 数据类型转 int
toEMConversationType(EMConversationType type) {
  switch (type) {
    case EMConversationType.Chat:
      return 0;
    case EMConversationType.GroupChat:
      return 1;
    case EMConversationType.ChatRoom:
      return 2;
    default:
      return 0;
  }
}


/// @nodoc 搜索方向 EMSearchDirection 数据类型转 int
toEMSearchDirection(EMSearchDirection direction) {
  if (direction == EMSearchDirection.Up) {
    return 0;
  } else if (direction == EMSearchDirection.Down) {
    return 1;
  }
}

/// 推送消息的显示风格
enum EMPushDisplayStyle {
  /// 简单显示"您有一条新消息
  EMPushDisplayStyleSimpleBanner,

  /// 显示消息内容
  EMPushDisplayStyleMessageSummary,
}

/// @nodoc 推送消息的显示风格 int 数据类型转 EMPushDisplayStyle
fromEMPushDisplayStyle(int type) {
  if (type == 0) {
    return EMPushDisplayStyle.EMPushDisplayStyleSimpleBanner;
  } else {
    return EMPushDisplayStyle.EMPushDisplayStyleMessageSummary;
  }
}

toEMPushDisplayStyle(EMPushDisplayStyle style) {
  if (style == EMPushDisplayStyle.EMPushDisplayStyleSimpleBanner) {
    return 0;
  } else if (style == EMPushDisplayStyle.EMPushDisplayStyleMessageSummary) {
    return 1;
  }
}


/// 消息推送设置
class EMPushConfigs {
  String _displayNickname;
  EMPushDisplayStyle _displayStyle;
  bool _noDisturbOn;
  int _noDisturbStartHour;
  int _noDisturbEndHour;

  /// 设置推送昵称
  String getDisplayNickname() {
    return _displayNickname;
  }

  /// 获取消息推送的显示风格 （目前只支持iOS）
  EMPushDisplayStyle getDisplayStyle() {
    return _displayStyle;
  }

  /// 是否开启消息推送免打扰
  bool isNoDisturbOn() {
    return _noDisturbOn;
  }

  /// 消息推送免打扰开始时间，小时，暂时只支持整点（小时）
  int getNoDisturbStartHour() {
    return _noDisturbStartHour;
  }

  /// 消息推送免打扰结束时间，小时，暂时只支持整点（小时）
  int getNoDisturbEndHour() {
    return _noDisturbEndHour;
  }

  EMPushConfigs.from(Map<String, dynamic> data)
      : _displayNickname = data['nickName'],
        _displayStyle = fromEMPushDisplayStyle(data['displayStyle']),
        _noDisturbOn = data['noDisturbOn'],
        _noDisturbStartHour = data['startHour'],
        _noDisturbEndHour = data['endHour'];
}

enum EMConferenceType {
  /// 普通通信会议
  EMConferenceTypeCommunication // 10
}

/// @nodoc 会议类型 int 数据类型转 EMConferenceType
fromEMConferenceType(int type) {
  if (type == 10) {
    return EMConferenceType.EMConferenceTypeCommunication;
  }
}

/// @nodoc 会议类型 EMConferenceType 数据类型转 int
toEMConferenceType(EMConferenceType type) {
  if (type == EMConferenceType.EMConferenceTypeCommunication) {
    return 10;
  }
}

enum EMConferenceRole {
  NoType,   // 0
  Audience, // 1
  Talker,   // 3
  Admin,    // 7
}

toEMConferenceRole(EMConferenceRole emConferenceRole) {
  if (emConferenceRole == EMConferenceRole.Admin) {
    return 7;
  } else if (emConferenceRole == EMConferenceRole.Talker) {
    return 3;
  } else if (emConferenceRole == EMConferenceRole.Audience) {
    return 1;
  } else if (emConferenceRole == EMConferenceRole.NoType) {
    return 0;
  }
}

fromEMConferenceRole(int role) {
  if (role == 7) {
    return EMConferenceRole.Admin;
  } else if (role == 3) {
    return EMConferenceRole.Talker;
  } else if (role == 1) {
    return EMConferenceRole.Audience;
  } else if (role == 0) {
    return EMConferenceRole.NoType;
  }
}


class EMConference {
  String _conferenceId;
  String _password;
  EMConferenceType _conferenceType;
  EMConferenceRole _conferenceRole;
  int _memberNum;
  var _admins = List<String>();
  var _speakers = List<String>();
  bool _isRecordOnServer = false;


  String getConferenceId() {
    return _conferenceId;
  }

  void setConferenceId(String conferenceId) {
    _conferenceId = conferenceId;
  }

  String getPassword() {
    return _password;
  }

  void setPassword(String password) {
    _password = password;
  }

  EMConferenceType getConferenceType() {
    return _conferenceType;
  }

  void setConferenceType(EMConferenceType conferenceType) {
    _conferenceType = conferenceType;
  }

  EMConferenceRole getConferenceRole() {
    return _conferenceRole;
  }

  void setConferenceRole(EMConferenceRole conferenceRole) {
    _conferenceRole = conferenceRole;
  }

  int getMemberNum() {
    return _memberNum;
  }

  void setMemberNum(int memberNum) {
    _memberNum = memberNum;
  }

  List<String> getAdmins() {
    return _admins;
  }

  void setAdmins(List<String> admins) {
    _admins = admins;
  }

  List<String> getSpeakers() {
    return _speakers;
  }

  void setSpeakers(List<String> speakers) {
    _speakers = speakers;
  }

  bool isRecordOnServer() {
    return _isRecordOnServer;
  }

  void setRecordOnServer(bool isRecordOnServer) {
    _isRecordOnServer = isRecordOnServer;
  }

  void reset() {
    _conferenceId = "";
    _password = "";
    _conferenceType = null;
    _conferenceRole = null;
    _memberNum = 0;
    _admins = null;
    _speakers = null;
  }

  EMConference.from(Map<String, dynamic> data){
    _conferenceId = data["conferenceId"];
    _password = data["password"];
    _conferenceType = fromEMConferenceType(data["conferenceType"]);
    _conferenceRole = fromEMConferenceRole(data["conferenceRole"]);
    _memberNum = data["memberNum"];
    var admins = new List<String>();
    
    for(var s in data["admins"]){
      admins.add(s);
    }
    _admins = admins;
    var speakers = new List<String>();
    for(var s in data["speakers"]){
      speakers.add(s);
    }
    _speakers = speakers;
    _isRecordOnServer = data["isRecordOnServer"];
  }
}
