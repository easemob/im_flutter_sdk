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

  bool _isMemberAllowToInvite;

  bool _isMemberOnly;

  int _maxUserCount;

  bool _isMsgBlocked;

  String _owner;

  List _members;

  int _memberCount;

  List _adminList;

  List _blackList;

  List _muteList;

  String _extension;

  String _announcement;

  List<EMMucSharedFile> _sharedFileList;

  List _occupants;

  EMGroupPermissionType _permissionType;

  bool _isPushNotificationEnabled;

  EMGroup.from(Map<String, dynamic> data){
    _groupId = data['groupId'];
    _groupName = data['groupName'];
    _description = data['description'];
    _isPublic = data['isPublic'];
    _isMemberAllowToInvite = data['isMemberAllowToInvite'];
    _isMemberOnly = data['isMemberOnly'];
    _maxUserCount = data['maxUserCount'];
    _isMsgBlocked = data['isMsgBlocked'];
    _owner = data['owner'];
    _members = data['members'];
    _memberCount = data['memberCount'];
    _adminList = data['adminList'];
    _blackList = data['blackList'];
    _muteList = data['muteList'];
    _extension = data['extension'];
    _announcement = data['announcement'];
    var files = data['sharedFileList'] as List;
    var fileList = List<EMMucSharedFile>();
    for(var file in files){
      fileList.add(EMMucSharedFile.from(file));
    }
    _sharedFileList = fileList;
    _occupants = data['occupants'];
    _permissionType = convertIntToEMGroupPermissionType(data['permissionType']);
    _isPushNotificationEnabled = data['isPushNotificationEnabled'];
  }

  /// 群id
  String getGroupId() {
    return _groupId;
  }

  /// 群名称
  String getGroupName(){
    return _groupName;
  }

  /// 群描述
  String getDescription(){
    return _description;
  }

  /// 是否是公开群
  bool isPublic(){
    return _isPublic;
  }

  /// 是否需要成员邀请
  bool isMemberAllowToInvite(){
    return _isMemberAllowToInvite;
  }

  /// @nodoc TODO: 需要明确这个在什么场景下生效
  bool isMemberOnly(){
    return _isMemberOnly;
  }

  /// 群人数上限
  int getMaxUserCount(){
    return _maxUserCount;
  }

  /// 是否免打扰
  bool isMsgBlocked(){
    return _isMsgBlocked;
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

  List<EMMucSharedFile> getSharedFileList(){
    return _sharedFileList;
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