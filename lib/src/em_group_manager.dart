import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';


import 'models/em_domain_terms.dart';
import 'em_sdk_method.dart';
//import 'em_domain_terms.dart';
import 'em_listeners.dart';

class EMGroupManager {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emGroupManagerChannel = const MethodChannel(
      '$_channelPrefix/em_group_manager', JSONMethodCodec());
  static EMGroupManager _instance;

  /// @nodoc
  final _groupChangeListeners = List<EMGroupChangeListener>();

  EMGroupManager._internal() {
    _addNativeMethodCallHandler();
  }

  /// @nodoc
  factory EMGroupManager.getInstance() {
    return _instance = _instance ?? EMGroupManager._internal();
  }

  /// @nodoc
  void _addNativeMethodCallHandler() {
    _emGroupManagerChannel.setMethodCallHandler((MethodCall call) {
      Map argMap = call.arguments;
      print('[EMGroupChange:]' + argMap.toString());
      if (call.method == EMSDKMethod.onGroupChanged) {
        return _onGroupChanged(argMap);
      }
      return null;
    });
  }

  /// 根据群组id获取群实例
  Future<EMGroup> getGroupWithId({@required String groupId}) async {
    Map req = {'groupId': groupId};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.getGroupWithId, req);
    EMError.hasErrorFromResult(result);
    return EMGroup.fromJson(result[EMSDKMethod.getGroupWithId]);
  }

  /// 从本地缓存中获取已加入的群组列表
  Future<List<EMGroup>> getJoinedGroups() async {
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.getJoinedGroups);
    EMError.hasErrorFromResult(result);
    var list = List();
    (result[EMSDKMethod.getJoinedGroups] as List).forEach((element) => list.add(EMGroup.fromJson(element)));
    return list;
  }

  /// 获取免打扰的群组列表id
  Future<List<String>> getGroupsWithoutNotice() async {
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.getGroupsWithoutPushNotification);
    EMError.hasErrorFromResult(result);
    var list = List();
    (result[EMSDKMethod.getGroupsWithoutPushNotification] as List).forEach((element) => list.add(element));
    return list;
  }

  /// 从服务器获取已加入的群组列表
  Future<List> getJoinedGroupsFromServer({int pageSize = 200, int pageNum = 1}) async {
    Map req = {'pageSize': pageSize, 'pageNum': pageNum};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.getJoinedGroupsFromServer, req);
    EMError.hasErrorFromResult(result);
    List<EMGroup> list = List();
    (result[EMSDKMethod.getJoinedGroupsFromServer] as List).forEach((element) => list.add(EMGroup.fromJson(element)));
    return list;
  }

  /// 从服务器获取公开群组列表
  Future<EMCursorResult> getPublicGroupsFromServer({int pageSize = 200, String cursor = ''}) async {
    Map req ={'pageSize': pageSize, 'cursor': cursor};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.getPublicGroupsFromServer, req);
    EMError.hasErrorFromResult(result);

    return EMCursorResult.fromJson(result[EMSDKMethod.getPublicGroupsFromServer], dataItemCallback: (value) {
      return EMGroup.fromJson(value);
    });
  }

  /// 创建群组
  Future<EMGroup> createGroup({@required String groupName, @required EMGroupOptions settings, String desc = '', List<String> inviteMembers, String inviteReason = ''}) async {
    Map req = {'groupName': groupName, 'desc': desc, 'inviteMembers': inviteMembers ?? [], 'inviteReason': inviteReason, 'options': settings.toJson()};
    Map result =  await _emGroupManagerChannel.invokeMethod(EMSDKMethod.createGroup, req);
    EMError.hasErrorFromResult(result);
    return EMGroup.fromJson(result[EMSDKMethod.createGroup]);
  }

  /// 获取群组详情
  Future<EMGroup> getGroupSpecificationFromServer({@required String groupId}) async {
    Map req = {'groupId': groupId};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.getGroupSpecificationFromServer, req);
    EMError.hasErrorFromResult(result);
    return EMGroup.fromJson(result[EMSDKMethod.getGroupSpecificationFromServer]);
  }

  /// 获取群组成员列表
  Future<EMCursorResult> getGroupMemberListFromServer({@required String groupId, int pageSize = 200, String cursor = ''}) async {
    Map req = {'groupId': groupId, 'cursor': cursor, 'pageSize': pageSize};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.getGroupMemberListFromServer, req);
    EMError.hasErrorFromResult(result);
    return EMCursorResult.fromJson(result[EMSDKMethod.getGroupSpecificationFromServer], dataItemCallback: (value) => value);
  }

  /// 获取黑名单列表
  Future<List> getGroupBlacklistFromServer({String groupId, int pageSize = 200, int pageNum = 1}) async {
    Map req = {'groupId': groupId, 'pageNum': pageNum, 'pageSize': pageSize};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.getGroupBlacklistFromServer, req);
    EMError.hasErrorFromResult(result);
    return result[EMSDKMethod.getGroupBlacklistFromServer];
  }

  /// 获取禁言列表
  Future<List> getGroupMuteListFromServer({String groupId, int pageSize = 200, int pageNum = 1}) async {
    Map req = {'groupId': groupId, 'pageNum': pageNum, 'pageSize': pageSize};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.getGroupMuteListFromServer, req);
    EMError.hasErrorFromResult(result);
    return result[EMSDKMethod.getGroupMuteListFromServer];
  }

  /// 获取白名单列表
  Future<List> getGroupWhiteListFromServer({String groupId}) async {
    Map req = {'groupId': groupId};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.getGroupWhiteListFromServer, req);
    EMError.hasErrorFromResult(result);
    return result[EMSDKMethod.getGroupWhiteListFromServer];
  }

  /// 判断自己是否在白名单中
  Future<bool> isMemberInWhiteListFromServer({String groupId}) async {
    Map req = {'groupId': groupId};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.isMemberInWhiteListFromServer, req);
    EMError.hasErrorFromResult(result);
    return result[EMSDKMethod.isMemberInWhiteListFromServer] as bool;
  }

  /// 获取群共享文件列表
  Future<List<EMGroupSharedFile>> getGroupFileListFromServer({String groupId, int pageSize = 200, int pageNum = 1}) async {
    Map req = {'groupId': groupId, 'pageNum': pageNum, 'pageSize': pageSize};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.getGroupFileListFromServer, req);
    EMError.hasErrorFromResult(result);
    List<EMGroupSharedFile> list = List();
    (result[EMSDKMethod.getGroupFileListFromServer] as List).forEach((element){
      list.add(EMGroupSharedFile.fromJson(element));
    });
    return list;
  }

  /// 从服务器获取群公告
  Future<String> getGroupAnnouncementFromServer({String groupId}) async {
    Map req = {'groupId': groupId};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.getGroupAnnouncementFromServer, req);
    EMError.hasErrorFromResult(result);
    return result[EMSDKMethod.getGroupAnnouncementFromServer];
  }

  /// 邀请用户加入私有群， 用于私有群: PrivateOnlyOwnerInvite / PrivateMemberCanInvite
  Future<Null> addMembers({@required String groupId, @required List<String> members, String welcome}) async {
    Map req = {'welcome': welcome, 'groupId': groupId, 'members': members};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.addMembers, req);
    EMError.hasErrorFromResult(result);
  }

  /// 从群组中移除用户
  Future<Null> removeMembers({@required String groupId, @required List<String> members}) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.removeMembers, req);
    EMError.hasErrorFromResult(result);
  }

  /// 将用户加入到群组黑名单中
  Future<Null> blockMembers({@required String groupId, @required List<String> members}) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.blockMembers, req);
    EMError.hasErrorFromResult(result);
  }

  /// 将用户从黑名单中移除
  Future<Null> unblockMembers({@required String groupId, @required List<String> members}) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.unblockMembers, req);
    EMError.hasErrorFromResult(result);
  }

  /// 更新群组名称
  Future<EMGroup> changeGroupName({@required String groupId, @required String name}) async {
    Map req = {'name': name, 'groupId': groupId};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.updateGroupSubject, req);
    EMError.hasErrorFromResult(result);
    return EMGroup.fromJson(result[EMSDKMethod.updateGroupSubject]);
  }

  /// 更新群描述
  Future<EMGroup> changeGroupDescription({@required String groupId, @required String desc}) async {
    Map req = {'desc': desc, 'groupId': groupId};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.updateDescription, req);
    EMError.hasErrorFromResult(result);
    return EMGroup.fromJson(result[EMSDKMethod.updateDescription]);
  }

  /// 退出群组
  Future<Null> leaveGroup({@required String groupId}) async {
    Map req = {'groupId': groupId};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.leaveGroup, req);
    EMError.hasErrorFromResult(result);
  }

  /// 解散群组
  Future<Null> destroyGroup({@required String groupId}) async {
    Map req = {'groupId': groupId};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.destroyGroup, req);
    EMError.hasErrorFromResult(result);
  }

  /// 不接收群消息
  Future<Null> blockGroup({@required String groupId}) async {
    Map req = {'groupId': groupId};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.blockGroup, req);
    EMError.hasErrorFromResult(result);
  }

  /// 恢复接收群消息
  Future<Null> unblockGroup({@required String groupId}) async {
    Map req = {'groupId': groupId};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.unblockGroup, req);
    EMError.hasErrorFromResult(result);
  }

  /// 将群转给其他人，需要群主调用
  Future<EMGroup> changeGroupOwner({@required String groupId, @required String username}) async {
    Map req = {'groupId': groupId, 'owner': username};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.updateGroupOwner, req);
    EMError.hasErrorFromResult(result);
    return EMGroup.fromJson(result[EMSDKMethod.updateGroupOwner]);
  }

  /// 添加管理员
  Future<EMGroup> addAdmin({@required String groupId, @required String username}) async {
    Map req = {'groupId': groupId, 'admin': username};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.addAdmin, req);
    EMError.hasErrorFromResult(result);
    return EMGroup.fromJson(result[EMSDKMethod.addAdmin]);
  }

  /// 移除管理员
  Future<EMGroup> removeAdmin({@required String groupId, @required String username}) async {
    Map req = {'groupId': groupId, 'admin': username};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.removeAdmin, req);
    EMError.hasErrorFromResult(result);
    return EMGroup.fromJson(result[EMSDKMethod.removeAdmin]);
  }

  /// 对群成员禁言，白名单中的用户不会被限制
  Future<EMGroup> muteMembers({@required String groupId, @required List<String> members, int duration = -1}) async {
    Map req = {'groupId': groupId, 'members': members, 'duration': duration};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.addAdmin, req);
    EMError.hasErrorFromResult(result);
    return EMGroup.fromJson(result[EMSDKMethod.addAdmin]);
  }

  /// 对群成员取消禁言
  Future<EMGroup> unMuteMembers({@required String groupId, @required List<String> members}) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.unMuteMembers, req);
    EMError.hasErrorFromResult(result);
    return EMGroup.fromJson(result[EMSDKMethod.unMuteMembers]);
  }

  /// 对所有群成员禁言，白名单中的用户不会被限制
  Future<Null> muteAllMembers({@required String groupId}) async {
    Map req = {'groupId': groupId};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.muteAllMembers, req);
    EMError.hasErrorFromResult(result);
    return EMGroup.fromJson(result[EMSDKMethod.muteAllMembers]);
  }

  /// 取消对所有群成员禁言
  Future<Null> unMuteAllMembers({@required String groupId}) async {
    Map req = {'groupId': groupId};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.unMuteAllMembers, req);
    EMError.hasErrorFromResult(result);
    return EMGroup.fromJson(result[EMSDKMethod.unMuteAllMembers]);
  }

  /// 将用户添加到白名单
  Future<EMGroup> addWhiteList({@required String groupId, @required List<String> members}) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.addWhiteList, req);
    EMError.hasErrorFromResult(result);
    return EMGroup.fromJson(result[EMSDKMethod.addWhiteList]);
  }

  /// 将用户移出白名单
  Future<EMGroup> removeWhiteList({@required String groupId, @required List<String> members}) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.removeWhiteList, req);
    EMError.hasErrorFromResult(result);
    return EMGroup.fromJson(result[EMSDKMethod.removeWhiteList]);
  }

  /// 上传群共享文件
  Future<EMGroupSharedFile> uploadGroupSharedFile({@required String groupId, @required String filePath}) async {
    Map req = {'groupId': groupId, 'filePath': filePath};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.uploadGroupSharedFile, req);
    EMError.hasErrorFromResult(result);
    return EMGroupSharedFile.fromJson(result[EMSDKMethod.uploadGroupSharedFile]);
  }

  /// 下载群共享文件
  Future<bool> downloadGroupSharedFile({@required String groupId, @required String fileId, @required String savePath}) async {
    Map req = {'groupId': groupId, 'fileId': fileId, 'savePath': savePath};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.downloadGroupSharedFile, req);
    EMError.hasErrorFromResult(result);
    return true;
  }

  /// 删除群共享文件
  Future<EMGroup> removeGroupSharedFile({@required String groupId, @required String fileId}) async {
    Map req = {'groupId': groupId, 'fileId': fileId};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.removeGroupSharedFile, req);
    EMError.hasErrorFromResult(result);
    return EMGroup.fromJson(result[EMSDKMethod.removeGroupSharedFile]);
  }

  /// 更新群公告
  Future<EMGroup> updateGroupAnnouncement({@required String groupId, @required String announcement}) async {
    Map req = {'groupId': groupId, 'announcement': announcement};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.updateGroupAnnouncement, req);
    EMError.hasErrorFromResult(result);
    return EMGroup.fromJson(result[EMSDKMethod.updateGroupAnnouncement]);
  }

  /// 更新群扩展
  Future<EMGroup> updateGroupExt({@required String groupId, @required String ext}) async {
    Map req = {'groupId': groupId, 'ext': ext};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.updateGroupExt, req);
    EMError.hasErrorFromResult(result);
    return EMGroup.fromJson(result[EMSDKMethod.updateGroupExt]);
  }

  /// 加入公开群，用于加入不需要群主/管理员同意的公开群: EMGroupStyle.PublicOpenJoin
  Future<EMGroup> joinPublicGroup({@required String groupId}) async {
    Map req = {'groupId': groupId};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.joinPublicGroup, req);
    EMError.hasErrorFromResult(result);
    return EMGroup.fromJson(result[EMSDKMethod.joinPublicGroup]);
  }

  /// 申请加入公开群，用于加入需要群主/管理员同意的公开群: EMGroupStyle.PublicJoinNeedApproval
  Future<EMGroup> requestToJoinPublicGroup({@required String groupId, String reason = ''}) async {
    Map req = {'groupId': groupId, 'reason': reason};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.requestToJoinPublicGroup, req);
    EMError.hasErrorFromResult(result);
    return EMGroup.fromJson(result[EMSDKMethod.requestToJoinPublicGroup]);
  }

  /// 同意公开群组申请，当群类型是EMGroupStyle.PublicJoinNeedApproval，
  /// 有人申请进群时，管理员和群主会收到申请，用该方法同意申请
  Future<EMGroup> acceptJoinApplication({@required String groupId, @required String username}) async {
    Map req = {'groupId': groupId, 'username': username};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.acceptJoinApplication, req);
    EMError.hasErrorFromResult(result);
    return EMGroup.fromJson(result[EMSDKMethod.acceptJoinApplication]);
  }

  /// 拒绝公开群组申请，当群类型是EMGroupStyle.PublicJoinNeedApproval，
  /// 有人申请进群时，管理员和群主会收到申请，用该方法拒绝申请
  Future<EMGroup> declineJoinApplication({@required String groupId, @required String username, String reason = ''}) async {
    Map req = {'groupId': groupId, 'username': username, 'reason': reason};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.declineJoinApplication, req);
    EMError.hasErrorFromResult(result);
    return EMGroup.fromJson(result[EMSDKMethod.declineJoinApplication]);
  }

  /// 同意群邀请，当群组是PrivateOnlyOwnerInvite / PrivateMemberCanInvite时，
  /// 有人添加您入群时您会收到群邀请，用该方法同意群邀请
  Future<EMGroup> acceptInvitationFromGroup({@required String groupId, @required String inviter}) async {
    Map req = {'groupId': groupId, 'inviter': inviter};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.acceptInvitationFromGroup, req);
    EMError.hasErrorFromResult(result);
    return EMGroup.fromJson(result[EMSDKMethod.acceptInvitationFromGroup]);
  }

  /// 拒绝群邀请，当群组是PrivateOnlyOwnerInvite / PrivateMemberCanInvite时，
  /// 有人添加您入群时您会收到群邀请，用该方法拒绝群邀请
  Future<EMGroup> declineInvitationFromGroup({@required String groupId, @required String inviter, String reason = ''}) async {
    Map req = {'groupId': groupId, 'inviter': inviter, 'reason': reason};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.declineInvitationFromGroup, req);
    EMError.hasErrorFromResult(result);
    return EMGroup.fromJson(result[EMSDKMethod.acceptInvitationFromGroup]);
  }

  /// 设置群组免打扰，设置后，当您不在线时您不会收到群推送
  Future<EMGroup> ignoreGroupPush({@required String groupId, bool enable = true}) async {
    Map req = {'groupId': groupId, 'enable': enable};
    Map result = await _emGroupManagerChannel.invokeMethod(EMSDKMethod.ignoreGroupPush, req);
    EMError.hasErrorFromResult(result);
    return EMGroup.fromJson(result[EMSDKMethod.ignoreGroupPush]);
  }

  /// @nodoc addGroupChangeListener - Adds [listener] to be aware of group change events.
  void addGroupChangeListener(EMGroupChangeListener listener) {
    _groupChangeListeners.add(listener);
  }

  /// @nodoc removeGroupChangeListener - Remove [listener] from the listener list.
  void removeGroupChangeListener(EMGroupChangeListener listener) {
    assert(listener != null);
    _groupChangeListeners.remove(listener);
  }

  /// @nodoc
  Future<void> _onGroupChanged(Map map) async {
    for (var listener in _groupChangeListeners) {
      print('[EMGroupChange:]_onGroupChanged');
      var type = map['type'];
      switch (type) {
        case EMGroupChangeEvent.ON_INVITATION_RECEIVED:
          String groupId = map['groupId'];
          String groupName = map['groupName'];
          String inviter = map['inviter'];
          String reason = map['reason'];
          listener.onInvitationReceived(groupId, groupName, inviter, reason);
          break;
        case EMGroupChangeEvent.ON_INVITATION_ACCEPTED:
          String groupId = map['groupId'];
          String invitee = map['invitee'];
          String reason = map['reason'];
          listener.onInvitationAccepted(groupId, invitee, reason);
          break;
        case EMGroupChangeEvent.ON_INVITATION_DECLINED:
          String groupId = map['groupId'];
          String invitee = map['invitee'];
          String reason = map['reason'];
          listener.onInvitationDeclined(groupId, invitee, reason);
          break;
        case EMGroupChangeEvent.ON_AUTO_ACCEPT_INVITATION:
          String groupId = map['groupId'];
          String inviter = map['inviter'];
          String inviteMessage = map['inviteMessage'];
          listener.onAutoAcceptInvitationFromGroup(
              groupId, inviter, inviteMessage);
          break;
        case EMGroupChangeEvent.ON_USER_REMOVED:
          String groupId = map['groupId'];
          String groupName = map['groupName'];
          listener.onUserRemoved(groupId, groupName);
          break;
        case EMGroupChangeEvent.ON_REQUEST_TO_JOIN_RECEIVED:
          String groupId = map['groupId'];
          String groupName = map['groupName'];
          String applicant = map['applicant'];
          String reason = map['reason'];
          listener.onRequestToJoinReceived(
              groupId, groupName, applicant, reason);
          break;
        case EMGroupChangeEvent.ON_REQUEST_TO_JOIN_DECLINED:
          String groupId = map['groupId'];
          String groupName = map['groupName'];
          String decliner = map['decliner'];
          String reason = map['reason'];
          listener.onRequestToJoinDeclined(
              groupId, groupName, decliner, reason);
          break;
        case EMGroupChangeEvent.ON_REQUEST_TO_JOIN_ACCEPTED:
          String groupId = map['groupId'];
          String groupName = map['groupName'];
          String accepter = map['accepter'];
          listener.onRequestToJoinAccepted(groupId, groupName, accepter);
          break;
        case EMGroupChangeEvent.ON_GROUP_DESTROYED:
          String groupId = map['groupId'];
          String groupName = map['groupName'];
          listener.onGroupDestroyed(groupId, groupName);
          break;
        case EMGroupChangeEvent.ON_MUTE_LIST_ADDED:
          String groupId = map['groupId'];
          List mutes = map['mutes'];
          int muteExpire = map['muteExpire'];
          listener.onMuteListAdded(groupId, mutes, muteExpire);
          break;
        case EMGroupChangeEvent.ON_MUTE_LIST_REMOVED:
          String groupId = map['groupId'];
          List mutes = map['mutes'];
          listener.onMuteListRemoved(groupId, mutes);
          break;
        case EMGroupChangeEvent.ON_ADMIN_ADDED:
          String groupId = map['groupId'];
          String administrator = map['administrator'];
          listener.onAdminAdded(groupId, administrator);
          break;
        case EMGroupChangeEvent.ON_ADMIN_REMOVED:
          String groupId = map['groupId'];
          String administrator = map['administrator'];
          listener.onAdminRemoved(groupId, administrator);
          break;
        case EMGroupChangeEvent.ON_OWNER_CHANGED:
          String groupId = map['groupId'];
          String newOwner = map['newOwner'];
          String oldOwner = map['oldOwner'];
          listener.onOwnerChanged(groupId, newOwner, oldOwner);
          break;
        case EMGroupChangeEvent.ON_MEMBER_JOINED:
          String groupId = map['groupId'];
          String member = map['member'];
          listener.onMemberJoined(groupId, member);
          break;
        case EMGroupChangeEvent.ON_MEMBER_EXITED:
          String groupId = map['groupId'];
          String member = map['member'];
          listener.onMemberExited(groupId, member);
          break;
        case EMGroupChangeEvent.ON_ANNOUNCEMENT_CHANGED:
          String groupId = map['groupId'];
          String announcement = map['announcement'];
          listener.onAnnouncementChanged(groupId, announcement);
          break;
        case EMGroupChangeEvent.ON_SHARED_FILE_ADDED:
          String groupId = map['groupId'];
          EMGroupSharedFile sharedFile = EMGroupSharedFile.fromJson(map['sharedFile']);
          listener.onSharedFileAdded(groupId, sharedFile);
          break;
        case EMGroupChangeEvent.ON_SHARED_FILE__DELETED:
          String groupId = map['groupId'];
          String fileId = map['fileId'];
          listener.onSharedFileDeleted(groupId, fileId);
          break;
      }
    }
  }
}
