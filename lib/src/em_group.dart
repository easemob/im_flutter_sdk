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

  List _occupants ;

  EMGroupPermissionType _permissionType;

  bool _isPushNotificationEnabled;

  EMGroup():
        _groupId = '',
        _groupName = 'groupName',
        _description = '',
        _isPublic = false,
        _isMemberAllowToInvite = false,
        _isMemberOnly = false,
        _maxUserCount = 200,
        _isMsgBlocked = false,
        _owner = '',
        _members = [],
        _memberCount = 0,
        _adminList = [],
        _blackList = [],
        _muteList = [],
        _extension = '',
        _announcement = '',
        _sharedFileList = [],
        _occupants = [],
        _permissionType = EMGroupPermissionType.EMGroupPermissionTypeNone,
        _isPushNotificationEnabled = false;

  /// @nodoc
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

  /// 是否不接收群消息
  bool isMsgBlocked(){
    return _isMsgBlocked;
  }

  /// 获取群创建者
  String getOwner(){
    return _owner;
  }

  /// 获取群成员
  List getMembers(){
    return _members;
  }

  /// 获取群人数上限
  int getMemberCount(){
    return _memberCount;
  }

  /// @nodoc
  String toString(){
    String str = getGroupName();
    return str != null ? str : getGroupId();
  }

  /// 获取群管理员列表
  List getAdminList(){
    return _adminList;
  }

  /// 获取群黑名单列表
  List getBlackList(){
    return _blackList;
  }

  /// 获取群禁言列表
  List getMuteList(){
    return _muteList;
  }

  /// 获取群扩展信息
  String getExtension(){
    return _extension;
  }

  /// 获取群公告
  String getAnnouncement(){
    return _announcement;
  }

  /// 获取群文件列表
  List<EMMucSharedFile> getSharedFileList(){
    return _sharedFileList;
  }

  /// 获取群所有人员
  List getOccupants(){
    return _occupants;
  }

  /// 获取群组类型
  EMGroupPermissionType getPermissionType(){
    return _permissionType;
  }

  /// 是否免打扰
  bool isPushNotificationEnabled(){
    return _isPushNotificationEnabled;
  }
}