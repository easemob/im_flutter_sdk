import '../im_flutter_sdk.dart';

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
