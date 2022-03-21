import 'dart:async';

import 'package:flutter/services.dart';
import 'em_listeners.dart';
import 'models/em_cursor_result.dart';
import 'models/em_error.dart';
import 'models/em_group.dart';
import 'models/em_group_options.dart';
import 'models/em_group_shared_file.dart';
import 'tools/em_extension.dart';

import 'chat_method_keys.dart';

class EMGroupManager {
  static const _channelPrefix = 'com.chat.im';
  static const MethodChannel _channel = const MethodChannel(
      '$_channelPrefix/chat_group_manager', JSONMethodCodec());

  EMGroupManager() {
    _channel.setMethodCallHandler((MethodCall call) async {
      Map? argMap = call.arguments;
      print('[EMGroupChange:]' + argMap.toString());
      if (call.method == ChatMethodKeys.onGroupChanged) {
        return _onGroupChanged(argMap);
      }
      return null;
    });
  }

  final _groupChangeListeners = [];

  /// 根据群组id获取群实例
  Future<EMGroup> getGroupWithId(String groupId) async {
    Map req = {'groupId': groupId};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.getGroupWithId, req);
    EMError.hasErrorFromResult(result);
    return EMGroup.fromJson(result[ChatMethodKeys.getGroupWithId]);
  }

  /// 从本地缓存中获取已加入的群组列表
  Future<List<EMGroup>> getJoinedGroups() async {
    Map result = await _channel.invokeMethod(ChatMethodKeys.getJoinedGroups);
    EMError.hasErrorFromResult(result);
    List<EMGroup> list = [];
    result[ChatMethodKeys.getJoinedGroups]
        ?.forEach((element) => list.add(EMGroup.fromJson(element)));
    return list;
  }

  /// 获取免打扰的群组列表id
  Future<List<String>?> getGroupsWithoutNotice() async {
    Map result = await _channel
        .invokeMethod(ChatMethodKeys.getGroupsWithoutPushNotification);
    EMError.hasErrorFromResult(result);
    var list =
        result[ChatMethodKeys.getGroupsWithoutPushNotification]?.cast<String>();
    return list;
  }

  /// 从服务器获取已加入的群组列表
  Future<List<EMGroup>> getJoinedGroupsFromServer({
    int pageSize = 200,
    int pageNum = 1,
  }) async {
    Map req = {'pageSize': pageSize, 'pageNum': pageNum};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getJoinedGroupsFromServer, req);
    EMError.hasErrorFromResult(result);
    List<EMGroup> list = [];
    result[ChatMethodKeys.getJoinedGroupsFromServer]
        ?.forEach((element) => list.add(EMGroup.fromJson(element)));
    return list;
  }

  /// 从服务器获取公开群组列表
  Future<EMCursorResult<EMGroup>> getPublicGroupsFromServer({
    int pageSize = 200,
    String cursor = '',
  }) async {
    Map req = {'pageSize': pageSize, 'cursor': cursor};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getPublicGroupsFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMCursorResult<EMGroup>.fromJson(
          result[ChatMethodKeys.getPublicGroupsFromServer],
          dataItemCallback: (value) {
        return EMGroup.fromJson(value);
      });
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 创建群组
  Future<EMGroup> createGroup(String groupName,
      {required EMGroupOptions settings,
      String desc = '',
      List<String>? inviteMembers,
      String inviteReason = ''}) async {
    Map req = {
      'groupName': groupName,
      'desc': desc,
      'inviteMembers': inviteMembers ?? [],
      'inviteReason': inviteReason,
      'options': settings.toJson()
    };
    Map result = await _channel.invokeMethod(ChatMethodKeys.createGroup, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.createGroup]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 获取群组详情
  Future<EMGroup> getGroupSpecificationFromServer(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getGroupSpecificationFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(
          result[ChatMethodKeys.getGroupSpecificationFromServer]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 获取群组成员列表
  Future<EMCursorResult<String>> getGroupMemberListFromServer(
    String groupId, {
    int pageSize = 200,
    String cursor = '',
  }) async {
    Map req = {
      'groupId': groupId,
      'cursor': cursor,
      'pageSize': pageSize,
    };
    Map result = await _channel.invokeMethod(
      ChatMethodKeys.getGroupMemberListFromServer,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
      return EMCursorResult<String>.fromJson(
          result[ChatMethodKeys.getGroupMemberListFromServer],
          dataItemCallback: (value) => value);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 获取黑名单列表
  Future<List<String>?> getGroupBlockListFromServer(
    String groupId, {
    int pageSize = 200,
    int pageNum = 1,
  }) async {
    Map req = {'groupId': groupId, 'pageNum': pageNum, 'pageSize': pageSize};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getGroupBlockListFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.getGroupBlockListFromServer]?.cast<String>();
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 获取禁言列表
  Future<List<String>?> getGroupMuteListFromServer(
    String groupId, {
    int pageSize = 200,
    int pageNum = 1,
  }) async {
    Map req = {'groupId': groupId, 'pageNum': pageNum, 'pageSize': pageSize};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getGroupMuteListFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.getGroupMuteListFromServer]?.cast<String>();
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 获取白名单列表
  Future<List<String>?> getGroupWhiteListFromServer(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getGroupWhiteListFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.getGroupWhiteListFromServer]?.cast<String>();
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 判断自己是否在白名单中
  Future<bool> isMemberInWhiteListFromServer(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.isMemberInWhiteListFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.isMemberInWhiteListFromServer);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 获取群共享文件列表
  Future<List<EMGroupSharedFile>> getGroupFileListFromServer(
    String groupId, {
    int pageSize = 200,
    int pageNum = 1,
  }) async {
    Map req = {'groupId': groupId, 'pageNum': pageNum, 'pageSize': pageSize};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getGroupFileListFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      List<EMGroupSharedFile> list = [];
      result[ChatMethodKeys.getGroupFileListFromServer]?.forEach((element) {
        list.add(EMGroupSharedFile.fromJson(element));
      });
      return list;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 从服务器获取群公告
  Future<String?> getGroupAnnouncementFromServer(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getGroupAnnouncementFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.getGroupAnnouncementFromServer];
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 邀请用户加入私有群，用于公开群: PublicJoinNeedApproval / PublicOpenJoin
  Future<void> addMembers(
    String groupId,
    List<String> members, [
    String welcome = '',
  ]) async {
    Map req = {'welcome': welcome, 'groupId': groupId, 'members': members};
    Map result = await _channel.invokeMethod(ChatMethodKeys.addMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 邀请用户加入私有群，用于私有群: PrivateOnlyOwnerInvite / PrivateMemberCanInvite
  Future<void> inviterUser(
    String groupId,
    List<String> members, [
    String? reason,
  ]) async {
    Map req = {
      'groupId': groupId,
      'members': members,
    };
    if (reason != null) {
      req["reason"] = reason;
    }

    Map result = await _channel.invokeMethod(
      ChatMethodKeys.inviterUser,
      req,
    );

    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 从群组中移除用户
  Future<void> removeMembers(
    String groupId,
    List<String> members,
  ) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result = await _channel.invokeMethod(ChatMethodKeys.removeMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 将用户加入到群组黑名单中
  Future<void> blockMembers(
    String groupId,
    List<String> members,
  ) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result = await _channel.invokeMethod(ChatMethodKeys.blockMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 将用户从黑名单中移除
  Future<void> unblockMembers(
    String groupId,
    List<String> members,
  ) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.unblockMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 更新群组名称
  Future<EMGroup> changeGroupName(
    String groupId,
    String name,
  ) async {
    Map req = {'name': name, 'groupId': groupId};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.updateGroupSubject, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.updateGroupSubject]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 更新群描述
  Future<EMGroup> changeGroupDescription(
    String groupId,
    String desc,
  ) async {
    Map req = {'desc': desc, 'groupId': groupId};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.updateDescription, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.updateDescription]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 退出群组
  Future<void> leaveGroup(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await _channel.invokeMethod(ChatMethodKeys.leaveGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 解散群组
  Future<void> destroyGroup(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await _channel.invokeMethod(ChatMethodKeys.destroyGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 不接收群消息
  Future<void> blockGroup(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await _channel.invokeMethod(ChatMethodKeys.blockGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 恢复接收群消息
  Future<void> unblockGroup(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await _channel.invokeMethod(ChatMethodKeys.unblockGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 将群转给其他人，需要群主调用
  Future<EMGroup> changeGroupOwner(
    String groupId,
    String newOwner,
  ) async {
    Map req = {'groupId': groupId, 'owner': newOwner};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.updateGroupOwner, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.updateGroupOwner]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 添加管理员
  Future<EMGroup> addAdmin(
    String groupId,
    String memberId,
  ) async {
    Map req = {'groupId': groupId, 'admin': memberId};
    Map result = await _channel.invokeMethod(ChatMethodKeys.addAdmin, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.addAdmin]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 移除管理员
  Future<EMGroup> removeAdmin(
    String groupId,
    String adminId,
  ) async {
    Map req = {'groupId': groupId, 'admin': adminId};
    Map result = await _channel.invokeMethod(ChatMethodKeys.removeAdmin, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.removeAdmin]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 对群成员禁言，白名单中的用户不会被限制
  Future<EMGroup> muteMembers(
    String groupId,
    List<String> members, {
    int duration = -1,
  }) async {
    Map req = {'groupId': groupId, 'members': members, 'duration': duration};
    Map result = await _channel.invokeMethod(ChatMethodKeys.muteMembers, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.muteMembers]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 对群成员取消禁言
  Future<EMGroup> unMuteMembers(
    String groupId,
    List<String> members,
  ) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result = await _channel.invokeMethod(ChatMethodKeys.unMuteMembers, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.unMuteMembers]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 对所有群成员禁言，白名单中的用户不会被限制
  Future<void> muteAllMembers(String groupId) async {
    Map req = {'groupId': groupId};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.muteAllMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 取消对所有群成员禁言
  Future<void> unMuteAllMembers(String groupId) async {
    Map req = {'groupId': groupId};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.unMuteAllMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 将用户添加到白名单
  Future<EMGroup> addWhiteList(
    String groupId,
    List<String> members,
  ) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result = await _channel.invokeMethod(ChatMethodKeys.addWhiteList, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.addWhiteList]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 将用户移出白名单
  Future<EMGroup> removeWhiteList(
    String groupId,
    List<String> members,
  ) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.removeWhiteList, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.removeWhiteList]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 上传群共享文件
  Future<bool> uploadGroupSharedFile(
    String groupId,
    String filePath,
  ) async {
    Map req = {'groupId': groupId, 'filePath': filePath};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.uploadGroupSharedFile, req);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.uploadGroupSharedFile);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 下载群共享文件
  Future<bool> downloadGroupSharedFile(
    String groupId,
    String fileId,
    String savePath,
  ) async {
    Map req = {'groupId': groupId, 'fileId': fileId, 'savePath': savePath};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.downloadGroupSharedFile, req);
    try {
      EMError.hasErrorFromResult(result);
      return result.boolValue(ChatMethodKeys.downloadGroupSharedFile);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 删除群共享文件
  Future<EMGroup> removeGroupSharedFile(
    String groupId,
    String fileId,
  ) async {
    Map req = {'groupId': groupId, 'fileId': fileId};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.removeGroupSharedFile, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.removeGroupSharedFile]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 更新群公告
  Future<EMGroup> updateGroupAnnouncement(
    String groupId,
    String announcement,
  ) async {
    Map req = {'groupId': groupId, 'announcement': announcement};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.updateGroupAnnouncement, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.updateGroupAnnouncement]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 更新群扩展
  Future<EMGroup> updateGroupExt(
    String groupId,
    String ext,
  ) async {
    Map req = {'groupId': groupId, 'ext': ext};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.updateGroupExt, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.updateGroupExt]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 加入公开群，用于加入不需要群主/管理员同意的公开群: EMGroupStyle.PublicOpenJoin
  Future<EMGroup> joinPublicGroup(
    String groupId,
  ) async {
    Map req = {'groupId': groupId};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.joinPublicGroup, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.joinPublicGroup]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 申请加入公开群，用于加入需要群主/管理员同意的公开群: EMGroupStyle.PublicJoinNeedApproval
  Future<EMGroup> requestToJoinPublicGroup(
    String groupId, [
    String reason = '',
  ]) async {
    Map req = {'groupId': groupId, 'reason': reason};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.requestToJoinPublicGroup, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.requestToJoinPublicGroup]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 同意公开群组申请，当群类型是EMGroupStyle.PublicJoinNeedApproval，
  /// 有人申请进群时，管理员和群主会收到申请，用该方法同意申请
  Future<EMGroup> acceptJoinApplication(
    String groupId,
    String username,
  ) async {
    Map req = {'groupId': groupId, 'username': username};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.acceptJoinApplication, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.acceptJoinApplication]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 拒绝公开群组申请，当群类型是EMGroupStyle.PublicJoinNeedApproval，
  /// 有人申请进群时，管理员和群主会收到申请，用该方法拒绝申请
  Future<EMGroup> declineJoinApplication(
    String groupId,
    String username, [
    String reason = '',
  ]) async {
    Map req = {'groupId': groupId, 'username': username, 'reason': reason};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.declineJoinApplication, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.declineJoinApplication]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 同意群邀请，当群组是PrivateOnlyOwnerInvite / PrivateMemberCanInvite时，
  /// 有人添加您入群时您会收到群邀请，用该方法同意群邀请
  Future<EMGroup> acceptInvitationFromGroup(
    String groupId,
    String inviter,
  ) async {
    Map req = {'groupId': groupId, 'inviter': inviter};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.acceptInvitationFromGroup, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.acceptInvitationFromGroup]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 拒绝群邀请，当群组是PrivateOnlyOwnerInvite / PrivateMemberCanInvite时，
  /// 有人添加您入群时您会收到群邀请，用该方法拒绝群邀请
  Future<EMGroup> declineInvitationFromGroup(
    String groupId,
    String inviter, [
    String reason = '',
  ]) async {
    Map req = {'groupId': groupId, 'inviter': inviter, 'reason': reason};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.declineInvitationFromGroup, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.acceptInvitationFromGroup]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 设置群组免打扰，设置后，当您不在线时您不会收到群推送
  Future<EMGroup> ignoreGroupPush(
    String groupId, [
    bool enable = true,
  ]) async {
    Map req = {'groupId': groupId, 'enable': enable};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.ignoreGroupPush, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.ignoreGroupPush]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// @nodoc addGroupChangeListener - Adds [listener] to be aware of group change events.
  void addGroupChangeListener(EMGroupEventListener listener) {
    _groupChangeListeners.add(listener);
  }

  /// @nodoc removeGroupChangeListener - Remove [listener] from the listener list.
  void removeGroupChangeListener(EMGroupEventListener listener) {
    if (_groupChangeListeners.contains(listener)) {
      _groupChangeListeners.remove(listener);
    }
  }

  /// @nodoc
  Future<void> _onGroupChanged(Map? map) async {
    for (EMGroupEventListener listener in _groupChangeListeners) {
      var type = map!['type'];
      switch (type) {
        case EMGroupChangeEvent.ON_INVITATION_RECEIVED:
          String groupId = map['groupId'];
          String? groupName = map['groupName'];
          String inviter = map['inviter'];
          String? reason = map['reason'];
          listener.onInvitationReceivedFromGroup(
              groupId, groupName, inviter, reason);
          break;
        case EMGroupChangeEvent.ON_INVITATION_ACCEPTED:
          String groupId = map['groupId'];
          String invitee = map['invitee'];
          String? reason = map['reason'];
          listener.onInvitationAcceptedFromGroup(groupId, invitee, reason);
          break;
        case EMGroupChangeEvent.ON_INVITATION_DECLINED:
          String groupId = map['groupId'];
          String invitee = map['invitee'];
          String? reason = map['reason'];
          listener.onInvitationDeclinedFromGroup(groupId, invitee, reason);
          break;
        case EMGroupChangeEvent.ON_AUTO_ACCEPT_INVITATION:
          String groupId = map['groupId'];
          String inviter = map['inviter'];
          String? inviteMessage = map['inviteMessage'];
          listener.onAutoAcceptInvitationFromGroup(
              groupId, inviter, inviteMessage);
          break;
        case EMGroupChangeEvent.ON_USER_REMOVED:
          String groupId = map['groupId'];
          String? groupName = map['groupName'];
          listener.onUserRemovedFromGroup(groupId, groupName);
          break;
        case EMGroupChangeEvent.ON_REQUEST_TO_JOIN_RECEIVED:
          String groupId = map['groupId'];
          String? groupName = map['groupName'];
          String applicant = map['applicant'];
          String? reason = map['reason'];
          listener.onRequestToJoinReceivedFromGroup(
              groupId, groupName, applicant, reason);
          break;
        case EMGroupChangeEvent.ON_REQUEST_TO_JOIN_DECLINED:
          String groupId = map['groupId'];
          String? groupName = map['groupName'];
          String decliner = map['decliner'];
          String? reason = map['reason'];
          listener.onRequestToJoinDeclinedFromGroup(
              groupId, groupName, decliner, reason);
          break;
        case EMGroupChangeEvent.ON_REQUEST_TO_JOIN_ACCEPTED:
          String groupId = map['groupId'];
          String? groupName = map['groupName'];
          String accepter = map['accepter'];
          listener.onRequestToJoinAcceptedFromGroup(
              groupId, groupName, accepter);
          break;
        case EMGroupChangeEvent.ON_GROUP_DESTROYED:
          String groupId = map['groupId'];
          String? groupName = map['groupName'];
          listener.onGroupDestroyed(groupId, groupName);
          break;
        case EMGroupChangeEvent.ON_MUTE_LIST_ADDED:
          String groupId = map['groupId'];
          List<String> mutes = List.from(map['mutes']);
          int? muteExpire = map['muteExpire'];
          listener.onMuteListAddedFromGroup(groupId, mutes, muteExpire);
          break;
        case EMGroupChangeEvent.ON_MUTE_LIST_REMOVED:
          String groupId = map['groupId'];
          List<String> mutes = List.from(map['mutes']);
          listener.onMuteListRemovedFromGroup(groupId, mutes);
          break;
        case EMGroupChangeEvent.ON_ADMIN_ADDED:
          String groupId = map['groupId'];
          String administrator = map['administrator'];
          listener.onAdminAddedFromGroup(groupId, administrator);
          break;
        case EMGroupChangeEvent.ON_ADMIN_REMOVED:
          String groupId = map['groupId'];
          String administrator = map['administrator'];
          listener.onAdminRemovedFromGroup(groupId, administrator);
          break;
        case EMGroupChangeEvent.ON_OWNER_CHANGED:
          String groupId = map['groupId'];
          String newOwner = map['newOwner'];
          String oldOwner = map['oldOwner'];
          listener.onOwnerChangedFromGroup(groupId, newOwner, oldOwner);
          break;
        case EMGroupChangeEvent.ON_MEMBER_JOINED:
          String groupId = map['groupId'];
          String member = map['member'];
          listener.onMemberJoinedFromGroup(groupId, member);
          break;
        case EMGroupChangeEvent.ON_MEMBER_EXITED:
          String groupId = map['groupId'];
          String member = map['member'];
          listener.onMemberExitedFromGroup(groupId, member);
          break;
        case EMGroupChangeEvent.ON_ANNOUNCEMENT_CHANGED:
          String groupId = map['groupId'];
          String announcement = map['announcement'];
          listener.onAnnouncementChangedFromGroup(groupId, announcement);
          break;
        case EMGroupChangeEvent.ON_SHARED_FILE_ADDED:
          String groupId = map['groupId'];
          EMGroupSharedFile sharedFile =
              EMGroupSharedFile.fromJson(map['sharedFile']);
          listener.onSharedFileAddedFromGroup(groupId, sharedFile);
          break;
        case EMGroupChangeEvent.ON_SHARED_FILE__DELETED:
          String groupId = map['groupId'];
          String fileId = map['fileId'];
          listener.onSharedFileDeletedFromGroup(groupId, fileId);
          break;
        case EMGroupChangeEvent.ON_WHITE_LIST_ADDED:
          String groupId = map["groupId"];
          List<String> members = List.from(map['whitelist']);
          listener.onWhiteListAddedFromGroup(groupId, members);
          break;
        case EMGroupChangeEvent.ON_WHITE_LIST_REMOVED:
          String groupId = map["groupId"];
          List<String> members = List.from(map['whitelist']);
          listener.onWhiteListRemovedFromGroup(groupId, members);
          break;
        case EMGroupChangeEvent.ON_ALL_MEMBER_MUTE_STATE_CHANGED:
          String groupId = map["groupId"];
          bool isAllMuted = map["isMuted"] as bool;
          listener.onAllGroupMemberMuteStateChanged(groupId, isAllMuted);
          break;
      }
    }
  }
}
