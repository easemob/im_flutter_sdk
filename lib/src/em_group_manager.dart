import "dart:async";

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'em_group.dart';
import 'em_log.dart';
import 'em_sdk_method.dart';
import 'em_domain_terms.dart';
import 'em_listeners.dart';

class EMGroupManager{
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emGroupManagerChannel =
  const MethodChannel('$_channelPrefix/em_group_manager', JSONMethodCodec());
  static EMGroupManager _instance;

  final EMLog log;

  final _groupChangeListeners = List<EMGroupChangeListener>();

  EMGroupManager._internal(EMLog log) : log = log {
    _addNativeMethodCallHandler();
  }

  factory EMGroupManager.getInstance({@required EMLog log}) {
    return _instance = _instance ?? EMGroupManager._internal(log);
  }

  void _addNativeMethodCallHandler() {
    _emGroupManagerChannel.setMethodCallHandler((MethodCall call) {
      Map argMap = call.arguments;
      if (call.method == EMSDKMethod.onInvitationReceived) {
        return _onInvitationReceived(argMap);
      } else if (call.method == EMSDKMethod.onRequestToJoinReceived) {
        return _onRequestToJoinReceived(argMap);
      }else if (call.method == EMSDKMethod.onRequestToJoinAccepted) {
        return _onRequestToJoinAccepted(argMap);
      }else if (call.method == EMSDKMethod.onRequestToJoinDeclined) {
        return _onRequestToJoinDeclined(argMap);
      }else if (call.method == EMSDKMethod.onInvitationAccepted) {
        return _onInvitationAccepted(argMap);
      }else if (call.method == EMSDKMethod.onInvitationDeclined) {
        return _onInvitationDeclined(argMap);
      }else if (call.method == EMSDKMethod.onUserRemoved) {
        return _onUserRemoved(argMap);
      }else if (call.method == EMSDKMethod.onGroupDestroyed) {
        return _onGroupDestroyed(argMap);
      }else if (call.method == EMSDKMethod.onAutoAcceptInvitationFromGroup) {
        return _onAutoAcceptInvitationFromGroup(argMap);
      }else if (call.method == EMSDKMethod.onMuteListAdded) {
        return _onMuteListAdded(argMap);
      }else if (call.method == EMSDKMethod.onMuteListRemoved) {
        return _onMuteListRemoved(argMap);
      }else if (call.method == EMSDKMethod.onAdminAdded) {
        return _onAdminAdded(argMap);
      }else if (call.method == EMSDKMethod.onAdminRemoved) {
        return _onAdminRemoved(argMap);
      }else if (call.method == EMSDKMethod.onOwnerChanged) {
        return _onOwnerChanged(argMap);
      }else if (call.method == EMSDKMethod.onMemberJoined) {
        return _onMemberJoined(argMap);
      }else if (call.method == EMSDKMethod.onMemberExited) {
        return _onMemberExited(argMap);
      }else if (call.method == EMSDKMethod.onAnnouncementChanged) {
        return _onAnnouncementChanged(argMap);
      }else if (call.method == EMSDKMethod.onSharedFileAdded) {
        return _onSharedFileAdded(argMap);
      }else if (call.method == EMSDKMethod.onSharedFileDeleted) {
        return _onSharedFileDeleted(argMap);
      }
    });
  }

  ///获取当前(内存)用户的所有群组
  Future<List<EMGroup>> getAllGroups() async{
    Map<String, dynamic> result = await _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.getAllGroups);
    if (result['success']) {
      var data = List<EMGroup>();
      if(result['value'] != null) {
        var groups = result['value'] as List<dynamic>;
        for (var group in groups) {
          data.add(EMGroup.from(group));
        }
        return data;
      }else{
        return data;
      }
    } else {
      return null;
    }
  }

  ///根据群组ID，获得群组对象
  Future<EMGroup> getGroup(String groupId) async{
    Map<String, dynamic> result = await _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.getGroup, {"groupId" : groupId});
    if (result['success']) {
      if(result['value'] != null) {
        return EMGroup.from(result['value']);
      }else{
        return null;
      }
    } else {
      return null;
    }
  }

  ///在IM服务器创建一个群组
  void createGroup({@required String groupName,
    @required String desc,
    @required List<String> members,
    @required String reason,
    @required EMGroupOptions options,
      onSuccess(EMGroup group),
      onError(int errorCode, String desc)}
      ) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.createGroup, {
          "groupName" : groupName,
          "desc" : desc,
          "members" : members,
          "reason" : reason,
          "maxUsers": options.maxUsers,
          "groupStyle" : convertEMGroupStyleToInt(options.style)
    });
    result.then((response){
      if (response['success']) {
        if (onSuccess != null) {
          if(response['value'] != null) {
            onSuccess(EMGroup.from(response['value']));
          }else{
            onSuccess(null);
          }
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///同步加载所有群组
  void loadAllGroups(){
    _emGroupManagerChannel.invokeMethod(EMSDKMethod.loadAllGroups);
  }

  ///解散群组
  void destroyGroup({@required String groupId,
    onSuccess(),
    onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.destroyGroup, {"groupId" : groupId});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///向群组中添加新的成员
  void addUsersToGroup({
    @required String groupId,
    @required List<String> members,
    onSuccess(),
    onError(int errorCode, String desc)
    }){
      Future<Map<String, dynamic>> result = _emGroupManagerChannel
          .invokeMethod(EMSDKMethod.addUsersToGroup, {"groupId" : groupId, "members" : members});
      result.then((response){
        if (response['success']) {
          if (onSuccess != null) {
            onSuccess();
          }
        } else {
          if (onError != null) onError(response['code'], response['desc']);
        }
      });
  }

  ///从群组中删除成员
  void removeUserFromGroup({
    @required String groupId,
    @required String userName,
    onSuccess(),
    onError(int errorCode, String desc)
  }){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.removeUserFromGroup, {"groupId" : groupId, "userName" : userName});
    result.then((response){
      if (response['success']) {
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///当前登录用户退出群组
  void leaveGroup({
    @required String groupId,
    onSuccess(),
    onError(int errorCode, String desc)
  }){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.leaveGroup, {"groupId" : groupId});
    result.then((response){
      if (response['success']) {
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///从服务器获取群组的详细信息
  void getGroupFromServer({
    @required String groupId,
    onSuccess(EMGroup group),
    onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.getGroupFromServer, {"groupId" : groupId});
    result.then((response){
      if (response['success']) {
        if (onSuccess != null) {
          if(response['value'] != null) {
            onSuccess(EMGroup.from(response['value']));
          }else{
            onSuccess(null);
          }
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///从服务器端获取当前用户的所有群组此操作只返回群组列表，并不获取群组的所有成员信息
  void getJoinedGroupsFromServer({
    onSuccess(List<EMGroup> groups),
    onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.getJoinedGroupsFromServer);
    result.then((response){
      if (response['success']) {

          if (onSuccess != null) {
            var data = List<EMGroup>();
            if(response['value'] != null) {
              var groups = response['value'] as List<dynamic>;
              for (var group in groups) {
                data.add(EMGroup.from(group));
              }
              onSuccess(data);
            }else{
              onSuccess(data);
            }
          }

      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///从服务器获取公开群组
  void getPublicGroupsFromServer({
    @required int pageSize,
    @required String cursor,
    onSuccess(EMCursorResult result),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.getPublicGroupsFromServer, {"pageSize" : pageSize, "cursor" : cursor});
    result.then((response){
      if (response['success']) {
          if (onSuccess != null) {
            if(response['value'] != null) {
              var groups = response['value'] as Map<String, dynamic>;
              onSuccess(EMCursorResult.from(groups));
            }else{
              onSuccess(null);
            }
          }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///当前登录用户加入公开群(如果是自由加入的公开群，直接进入群组)
  void joinGroup({
    @required String groupId,
    onSuccess(),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.joinGroup, {"groupId" : groupId});
    result.then((response){
      if (response['success']) {
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///改变群组的名称
  void changeGroupName({
    @required String groupId,
    @required String groupName,
    onSuccess(),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.changeGroupName, {"groupId" : groupId, "groupName" : groupName});
    result.then((response){
      if (response['success']) {
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///修改群描述
  void changeGroupDescription({
    @required String groupId,
    @required String desc,
    onSuccess(),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.changeGroupDescription, {"groupId" : groupId, "desc" : desc});
    result.then((response){
      if (response['success']) {
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///接受加入群的邀请
  void acceptInvitation({
    @required String groupId,
    @required String inviter,
    onSuccess(EMGroup group),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.acceptGroupInvitation, {"groupId" : groupId, "inviter" : inviter});
    result.then((response){
      if (response['success']) {
        if (onSuccess != null) {
          if(response['value'] != null) {
            onSuccess(EMGroup.from(response["value"]));
          }else{
            onSuccess(null);
          }
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///拒绝加入群的邀请
  void declineInvitation({
    @required String groupId,
    @required String inviter,
    @required String reason,
    onSuccess(),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.declineGroupInvitation, {"groupId" : groupId, "inviter" : inviter, "reason" : reason});
    result.then((response){
      if (response['success']) {
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///同意加群申请
  void acceptApplication({
    @required String userName,
    @required String groupId,
    onSuccess(),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.acceptApplication, {"userName" : userName, "groupId" : groupId});
    result.then((response){
      if (response['success']) {
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///拒绝加群申请
  void declineApplication({
    @required String userName,
    @required String groupId,
    @required String reason,
    onSuccess(),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.declineApplication, {"userName" : userName, "groupId" : groupId, "reason" : reason});
    result.then((response){
      if (response['success']) {
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///群成员邀请用户加入群组 （如果群组设置成开放群成员邀请，群组成员可以邀请其他用户加入）
  void inviteUser({
     @required String groupId,
     @required List<String> members,
     @required String reason,
     onSuccess(),
     onError(int errorCode, String desc)}){
     Future<Map<String, dynamic>> result = _emGroupManagerChannel
         .invokeMethod(EMSDKMethod.inviteUser, {"groupId" : groupId, "members" : members, "reason" : reason});
     result.then((response){
       if (response['success']) {
         if (onSuccess != null) {
           onSuccess();
         }
       } else {
         if (onError != null) onError(response['code'], response['desc']);
       }
     });
  }

  ///申请加入某个群（用于加入需要验证的公开群）
  void applyJoinToGroup({
    @required String groupId,
    @required String reason,
    onSuccess(),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.applyJoinToGroup, {"groupId" : groupId, "reason" : reason});
    result.then((response){
      if (response['success']) {
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///屏蔽群消息（还是群里面的成员，但不再接收群消息）
  void blockGroupMessage({
    @required String groupId,
    onSuccess(),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.blockGroupMessage, {"groupId" : groupId});
    result.then((response){
      if (response['success']) {
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///取消屏蔽群消息
  void unblockGroupMessage({
    @required String groupId,
    onSuccess(),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.unblockGroupMessage, {"groupId" : groupId});
    result.then((response){
      if (response['success']) {
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///将用户加到群组的黑名单，被加入黑名单的用户无法加入群，无法收发此群的消息
  void blockUser({
    @required String groupId,
    @required String userName,
    onSuccess(),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.blockUser, {"groupId" : groupId, "userName" : userName});
    result.then((response){
      if (response['success']) {
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///将用户从群组的黑名单移除
  void unblockUser({
    @required String groupId,
    @required String userName,
    onSuccess(),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.unblockUser, {"groupId" : groupId, "userName" : userName});
    result.then((response){
      if (response['success']) {
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///获取群组成员列表
  void fetchGroupMembers({
    @required String groupId,
    @required String cursor,
    @required int pageSize,
    onSuccess(EMCursorResult result),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.fetchGroupMembers, {"groupId" : groupId, "cursor" : cursor, "pageSize" : pageSize});
    result.then((response){
      if (response['success']) {
        if (onSuccess != null) {
          if(response['value'] != null) {
            var value = response['value'] as Map<String, dynamic>;
            onSuccess(EMCursorResult.from(value));
          }else{
            onSuccess(null);
          }
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///转让群组，群组所有权给他人
  void changeOwner({
    @required String groupId,
    @required String newOwner,
    onSuccess(EMGroup group),
    onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.changeOwner, {"groupId" : groupId, "newOwner" : newOwner});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          if(response['value'] != null) {
            onSuccess(EMGroup.from(response['value']));
          }else{
            onSuccess(null);
          }
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
     });
  }

  ///增加群组管理员，需要owner权限，admin无权限
  void addGroupAdmin ({
    @required String groupId,
    @required String admin,
    onSuccess(EMGroup group),
    onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.addGroupAdmin, {"groupId" : groupId, "admin" : admin});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          if(response['value'] != null) {
            onSuccess(EMGroup.from(response['value']));
          }else{
            onSuccess(null);
          }
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///删除群组管理员，需要owner权限
  void removeGroupAdmin({
    @required String groupId,
    @required String admin,
    onSuccess(EMGroup group),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.removeGroupAdmin, {"groupId" : groupId, "admin" : admin});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          if(response['value'] != null) {
            onSuccess(EMGroup.from(response['value']));
          }else{
            onSuccess(null);
          }
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///禁止某些群组成员发言
  void muteGroupMembers({
    @required String groupId,
    @required List<String> members,
    @required String duration,
    onSuccess(EMGroup group),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.muteGroupMembers, {"groupId" : groupId, "members" : members, "duration" : duration});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          if(response['value'] != null) {
            onSuccess(EMGroup.from(response['value']));
          }else{
            onSuccess(null);
          }
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///解除禁言
  void unMuteGroupMembers({
    @required String groupId,
    @required List<String> members,
    onSuccess(EMGroup group),
    onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(
        EMSDKMethod.unMuteGroupMembers, {"groupId": groupId, "members": members});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          if (response['value'] != null) {
            onSuccess(EMGroup.from(response['value']));
          } else {
            onSuccess(null);
          }
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///获取群组的禁言列表
  void fetchGroupMuteList({
    @required String groupId,
    @required int pageNum,
    @required int pageSize,
    onSuccess(Map map),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(
        EMSDKMethod.fetchGroupMuteList, {"groupId": groupId, "pageNum": pageNum, "pageSize" : pageSize});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          if (response['value'] != null) {
            var m = response['value'] as Map<String, dynamic>;
            onSuccess(m);
          } else {
            onSuccess(null);
          }
        }
      } else {
      if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///从服务器获分页获取群组黑名单
  void fetchGroupBlackList({
    @required String groupId,
    @required int pageNum,
    @required int pageSize,
    onSuccess(List list),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(
        EMSDKMethod.fetchGroupBlackList, {"groupId": groupId, "pageNum": pageNum, "pageSize" : pageSize});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          var data = List<String>();
          if(response['value'] != null) {
            var users = response['value'] as List<dynamic>;
            for (var user in users) {
              data.add(user);
            }
            onSuccess(data);
          }else{
            onSuccess(data);
          }
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///更新群公告
  void updateGroupAnnouncement({
    @required String groupId,
    @required String announcement,
    onSuccess(),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.updateGroupAnnouncement, {"groupId" : groupId, "announcement" : announcement});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///从服务器获取群公告
  void fetchGroupAnnouncement({
    @required String groupId,
    onSuccess(String announcement),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.fetchGroupAnnouncement, {"groupId" : groupId});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          if(response['value'] != null){
            onSuccess(response['value']);
          }else{
            onSuccess(null);
          }
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///上传共享文件至群组
  void uploadGroupSharedFile({
    @required String groupId,
    @required String filePath,
    onSuccess(),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
      .invokeMethod(EMSDKMethod.uploadGroupSharedFile, {"groupId" : groupId, "filePath" : filePath});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
            onSuccess();
          }
        } else {
          if (onError != null) onError(response['code'], response['desc']);
        }
    });
  }

  ///从服务器获取群组的共享文件列表
  void fetchGroupSharedFileList({
    @required String groupId,
    @required int pageNum,
    @required int pageSize,
    onSuccess(List<EMMucSharedFile> files),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.fetchGroupSharedFileList, {"groupId" : groupId, "pageNum" : pageNum, "pageSize" : pageSize});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          var data = List<EMMucSharedFile>();
          if(response['value'] != null) {
            var value = response['value'] as List<dynamic>;
            for(var file in value){
              data.add(EMMucSharedFile.from(file));
            }
            onSuccess(data);
          }else{
            onSuccess(null);
          }
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///从群组里删除这个共享文件
  void deleteGroupSharedFile({
    @required String groupId,
    @required String fileId,
    onSuccess(),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.deleteGroupSharedFile, {"groupId" : groupId, "fileId" : fileId});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///下载群里的某个共享文件
  void downloadGroupSharedFile({
    @required String groupId,
    @required String fileId,
    @required String savePath,
    onSuccess(),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.downloadGroupSharedFile, {"groupId" : groupId, "fileId" : fileId, "savePath" : savePath});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///更新群组扩展字段
  void updateGroupExtension({
    @required String groupId,
    @required String extension,
    onSuccess(EMGroup group),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.updateGroupExtension, {"groupId" : groupId, "extension" : extension});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          if(response['value'] != null) {
            onSuccess(EMGroup.from(response['value']));
          }else{
            onSuccess(null);
          }
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// addGroupChangeListener - Adds [listener] to be aware of group change events.
  void addGroupChangeListener(EMGroupChangeListener listener) {
    _groupChangeListeners.add(listener);
  }

  /// removeGroupChangeListener - Remove [listener] from the listener list.
  void removeGroupChangeListener(EMGroupChangeListener listener) {
    assert(listener != null);
    _groupChangeListeners.remove(listener);
  }

  /// Listeners interface
  ///当前用户收到加入群组邀请事件
  Future<void> _onInvitationReceived(Map map) async {
    String groupId = map['groupId'];
    String groupName = map['groupName'];
    String inviter = map['inviter'];
    String reason = map['reason'];

    for (var listener in _groupChangeListeners) {
      listener.onInvitationReceived(groupId, groupName, inviter, reason);
    }
  }

  ///用户申请加入群事件
  Future<void> _onRequestToJoinReceived(Map map) async {
    String groupId = map['groupId'];
    String groupName = map['groupName'];
    String applicant = map['applicant'];
    String reason = map['reason'];

    for (var listener in _groupChangeListeners) {
      listener.onRequestToJoinReceived(groupId, groupName, applicant, reason);
    }
  }

  ///加群申请被同意事件
  Future<void> _onRequestToJoinAccepted(Map map) async {
    String groupId = map['groupId'];
    String groupName = map['groupName'];
    String accepter = map['accepter'];

    for (var listener in _groupChangeListeners) {
      listener.onRequestToJoinAccepted(groupId, groupName, accepter);
    }
  }

  ///加群申请被拒绝事件
  Future<void> _onRequestToJoinDeclined(Map map) async {
    String groupId = map['groupId'];
    String groupName = map['groupName'];
    String decliner = map['decliner'];
    String reason = map['reason'];

    for (var listener in _groupChangeListeners) {
      listener.onRequestToJoinDeclined(groupId, groupName, decliner, reason);
    }
  }

  ///群组邀请被接受事件
  Future<void> _onInvitationAccepted(Map map) async {
    String groupId = map['groupId'];
    String invitee = map['invitee'];
    String reason = map['reason'];

    for (var listener in _groupChangeListeners) {
      listener.onInvitationAccepted(groupId, invitee, reason);
    }
  }

  ///群组邀请被拒绝事件
  Future<void> _onInvitationDeclined(Map map) async {
    String groupId = map['groupId'];
    String invitee = map['invitee'];
    String reason = map['reason'];

    for (var listener in _groupChangeListeners) {
      listener.onInvitationDeclined(groupId, invitee, reason);
    }
  }

  ///当前登录用户被管理员移除出群组事件
  Future<void> _onUserRemoved(Map map) async {
    String groupId = map['groupId'];
    String groupName = map['groupName'];

    for (var listener in _groupChangeListeners) {
      listener.onUserRemoved(groupId, groupName);
    }
  }

  ///群组被解散事件
  Future<void> _onGroupDestroyed(Map map) async {
    String groupId = map['groupId'];
    String groupName = map['groupName'];

    for (var listener in _groupChangeListeners) {
      listener.onGroupDestroyed(groupId, groupName);
    }
  }

  ///自动同意加入群组事件
  Future<void> _onAutoAcceptInvitationFromGroup(Map map) async {
    String groupId = map['groupId'];
    String inviter = map['inviter'];
    String inviteMessage = map['inviteMessage'];

    for (var listener in _groupChangeListeners) {
      listener.onAutoAcceptInvitationFromGroup(groupId, inviter, inviteMessage);
    }
  }

  ///成员被禁言事件
  Future<void> _onMuteListAdded(Map map) async {

    String groupId = map['groupId'];
    List mutes = map['mutes'];
    int muteExpire = map['muteExpire'];

    for (var listener in _groupChangeListeners) {
      print('[EMGroupChange:]_onMuteListAdded');
      listener.onMuteListAdded(groupId, mutes, muteExpire);
    }
  }

  ///成员从禁言列表中移除事件
  Future<void> _onMuteListRemoved(Map map) async {
    String groupId = map['groupId'];
    List mutes = map['mutes'];

    for (var listener in _groupChangeListeners) {
      print('[EMGroupChange:]_onMuteListRemoved');
      listener.onMuteListRemoved(groupId, mutes);
    }
  }

  ///添加成员管理员权限事件
  Future<void> _onAdminAdded(Map map) async {
    String groupId = map['groupId'];
    String administrator = map['administrator'];

    for (var listener in _groupChangeListeners) {
      listener.onAdminAdded(groupId, administrator);
    }
  }

  ///取消某管理员权限事件
  Future<void> _onAdminRemoved(Map map) async {
    String groupId = map['groupId'];
    String administrator = map['administrator'];

    for (var listener in _groupChangeListeners) {
      listener.onAdminRemoved(groupId, administrator);
    }
  }

  ///转移群组所有者权限事件
  Future<void> _onOwnerChanged(Map map) async {
    String groupId = map['groupId'];
    String newOwner = map['newOwner'];
    String oldOwner = map['oldOwner'];

    for (var listener in _groupChangeListeners) {
      listener.onOwnerChanged(groupId, newOwner, oldOwner);
    }
  }

  ///群组加入新成员事件
  Future<void> _onMemberJoined(Map map) async {
    String groupId = map['groupId'];
    String member = map['member'];

    for (var listener in _groupChangeListeners) {
      listener.onMemberJoined(groupId, member);
    }
  }

  ///群组成员主动退出事件
  Future<void> _onMemberExited(Map map) async {
    String groupId = map['groupId'];
    String member = map['member'];

    for (var listener in _groupChangeListeners) {
      listener.onMemberExited(groupId, member);
    }
  }

  ///群公告更改事件
  Future<void> _onAnnouncementChanged(Map map) async {
    String groupId = map['groupId'];
    String announcement = map['announcement'];

    for (var listener in _groupChangeListeners) {
      listener.onAnnouncementChanged(groupId, announcement);
    }
  }

  ///群组增加共享文件事件
  Future<void> _onSharedFileAdded(Map map) async {
    String groupId = map['groupId'];
    EMMucSharedFile sharedFile = EMMucSharedFile.from(map['sharedFile']);

    for (var listener in _groupChangeListeners) {
      listener.onSharedFileAdded(groupId, sharedFile);
    }
  }

  ///群组删除共享文件事件
  Future<void> _onSharedFileDeleted(Map map) async {
    String groupId = map['groupId'];
    String fileId = map['fileId'];

    for (var listener in _groupChangeListeners) {
      listener.onSharedFileDeleted(groupId, fileId);
    }
  }
}
