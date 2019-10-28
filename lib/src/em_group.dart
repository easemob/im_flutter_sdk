import 'package:flutter/services.dart';

import 'em_domain_terms.dart';

class EMGroup{
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emGroupChannel =
  const MethodChannel('$_channelPrefix/em_group', JSONMethodCodec());

  String _groupId;

  String _groupName;

  String _description;

  bool _isPublic;

  bool _memberAllowToInvite;

  bool _memberOnly;

  int _maxUserCount;

  bool _msgBlocked;

  String _owner;

  List _members;

  int _memberCount;

  List _adminList;

  List _blackList;

  List _muteList;

  String _extension;

  String _announcement;

  List<EMMucSharedFile> _shareFileList;

  List _occupants;

  EMGroupPermissionType _permissionType;

  bool _isPushNotificationEnabled;

  EMGroup.from(Map<String, dynamic> data){
    _groupId = data['groupId'];
    _groupName = data['groupName'];
    _description = data['description'];
    _isPublic = data['isPublic'];
    _memberAllowToInvite = data['memberAllowToInvite'];
    _memberOnly = data['memberOnly'];
    _maxUserCount = data['maxUserCount'];
    _msgBlocked = data['msgBlocked'];
    _owner = data['owner'];
    _members = data['members'];
    _memberCount = data['memberCount'];
    _adminList = data['adminList'];
    _blackList = data['blackList'];
    _muteList = data['muteList'];
    _extension = data['extension'];
    _announcement = data['announcement'];
    var files = data['shareFileList'] as List;
    var fileList = List<EMMucSharedFile>();
    for(var file in files){
      fileList.add(EMMucSharedFile.from(file));
    }
    _shareFileList = fileList;
    _occupants = data['occupants'];
    _permissionType = convertIntToEMGroupPermissionType(data['permissionType']);
    _isPushNotificationEnabled = data['isPushNotificationEnabled'];
  }

  String getGroupId() {
    return _groupId;
  }

  String getGroupName(){
    return _groupName;
  }

  String getDescription(){
    return _description;
  }

  bool isPublic(){
    return _isPublic;
  }

  bool isMemberAllowToInvite(){
    return _memberAllowToInvite;
  }

  bool isMemberOnly(){
    return _memberOnly;
  }

  int getMaxUserCount(){
    return _maxUserCount;
  }

  bool isMsgBlocked(){
    return _msgBlocked;
  }

  String getOwner(){
    return _owner;
  }

  List getMembers(){
    return _members;
  }

  int getMemberCount(){
    return _memberCount;
  }

  String toString(){
    String str = getGroupName();
    return str != null ? str : getGroupId();
  }

  List getAdminList(){
    return _adminList;
  }

  List getBlackList(){
    return _blackList;
  }

  List getMuteList(){
    return _muteList;
  }

  String getExtension(){
    return _extension;
  }

  String getAnnouncement(){
    return _announcement;
  }

  List<EMMucSharedFile> getShareFileList(){
    return _shareFileList;
  }

  List getOccupants(){
    return _occupants;
  }

  EMGroupPermissionType getPermissionType(){
    return _permissionType;
  }

  bool isPushNotificationEnabled(){
    return _isPushNotificationEnabled;
  }
}