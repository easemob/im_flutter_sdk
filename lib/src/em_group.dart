import 'package:flutter/services.dart';
import "package:meta/meta.dart";

import 'em_sdk_method.dart';

class EMGroup{
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emGroupChannel =
  const MethodChannel('$_channelPrefix/em_group', JSONMethodCodec());

  String _groupId;

  String _groupName;


  EMGroup.from(Map<String, dynamic> data)
      : _groupId = data['groupId'],
        _groupName = data['groupName'];

//  static const String getDescription = 'getDescription';
//  static const String isPublic = 'isPublic';
//  static const String isAllowInvites = 'isAllowInvites';
//  static const String isMemberAllowToInvite = 'isMemberAllowToInvite';
//  static const String isMembersOnly = 'isMembersOnly';
//  static const String getMaxUserCount = 'getMaxUserCount';
//  static const String isMsgBlocked = 'isMsgBlocked';
//  static const String getOwner = 'getOwner';
//  static const String groupSubject = 'groupSubject';
//  static const String getMembers = 'getMembers';
//  static const String getMemberCount = 'getMemberCount';
//  static const String toString = 'toString';
//  static const String getAdminList = 'getAdminList';
//  static const String getBlackList = 'getBlackList';
//  static const String getMuteList = 'getMuteList';
//  static const String getExtension = 'getExtension';
//  static const String getAnnouncement = 'getAnnouncement';
//  static const String getShareFileList = 'getShareFileList';

  String getGroupId() {
    return _groupId;
  }

  String getGroupName(){
    return _groupName;
  }

}