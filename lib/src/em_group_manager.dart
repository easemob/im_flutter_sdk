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

  void loadAllGroups(){
    _emGroupManagerChannel.invokeMethod(EMSDKMethod.loadAllGroups);
  }

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

  void getPublicGroupsFromServer({
    @required String pageSize,
    @required String cursor,
    onSuccess(List<EMGroup> groups),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.getPublicGroupsFromServer);
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

  void acceptGroupInvitation({
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

  void declineGroupInvitation({
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

  void getBlockedUsers({
    @required String groupId,
    onSuccess(List<String> userNames),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.getBlockedUsers, {"groupId" : groupId});
    result.then((response){
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
  void changeOwner({
    @required String groupId,
    @required String newOwner,
    onSuccess(),
    onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.changeOwner, {"groupId" : groupId, "newOwner" : newOwner});
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

  void addGroupAdmin ({
    @required String groupId,
    @required String admin,
    onSuccess(),
    onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.addGroupAdmin, {"groupId" : groupId, "admin" : admin});
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

  void removeGroupAdmin({
    @required String groupId,
    @required String admin,
    onSuccess(),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.removeGroupAdmin, {"groupId" : groupId, "admin" : admin});
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
//  static const String fetchGroupMuteList = "fetchGroupMuteList";

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
//  static const String fetchGroupSharedFileList = "fetchGroupSharedFileList";
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

  void downloadGroupSharedFile({
    @required String groupId,
    @required String fileId,
    @required String savePath,
    onSuccess(),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.deleteGroupSharedFile, {"groupId" : groupId, "fileId" : fileId, "savePath" : savePath});
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

  void updateGroupExtension({
    @required String groupId,
    @required String extension,
    onSuccess(EMGroup group),
    onError(int errorCode, String desc)}){
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.deleteGroupSharedFile, {"groupId" : groupId, "extension" : extension});
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

  /// addMessageListener - Adds [listener] to be aware of message change events.
  void addGroupChangeListener(EMGroupChangeListener listener) {
    assert(listener != null);
    _groupChangeListeners.add(listener);
  }

  /// removeMessageListener - Remove [listener] from the listener list.
  void removeGroupChangeListener(EMGroupChangeListener listener) {
    assert(listener != null);
    _groupChangeListeners.remove(listener);
  }

  /// Listeners interface
  Future<void> _onInvitationReceived(Map map) async {
    String groupId = map['groupId'];
    String groupName = map['groupName'];
    String inviter = map['inviter'];
    String reason = map['reason'];

    for (var listener in _groupChangeListeners) {
      listener.onInvitationReceived(groupId, groupName, inviter, reason);
    }
  }

  Future<void> _onRequestToJoinReceived(Map map) async {
    String groupId = map['groupId'];
    String groupName = map['groupName'];
    String applicant = map['applicant'];
    String reason = map['reason'];

    for (var listener in _groupChangeListeners) {
      listener.onRequestToJoinReceived(groupId, groupName, applicant, reason);
    }
  }

  Future<void> _onRequestToJoinAccepted(Map map) async {
    String groupId = map['groupId'];
    String groupName = map['groupName'];
    String accepter = map['accepter'];

    for (var listener in _groupChangeListeners) {
      listener.onRequestToJoinAccepted(groupId, groupName, accepter);
    }
  }

  Future<void> _onRequestToJoinDeclined(Map map) async {
    String groupId = map['groupId'];
    String groupName = map['groupName'];
    String decliner = map['decliner'];
    String reason = map['reason'];

    for (var listener in _groupChangeListeners) {
      listener.onRequestToJoinDeclined(groupId, groupName, decliner, reason);
    }
  }

  Future<void> _onInvitationAccepted(Map map) async {
    String groupId = map['groupId'];
    String inviter = map['inviter'];
    String reason = map['reason'];

    for (var listener in _groupChangeListeners) {
      listener.onInvitationAccepted(groupId, inviter, reason);
    }
  }

  Future<void> _onInvitationDeclined(Map map) async {
    String groupId = map['groupId'];
    String inviter = map['inviter'];
    String reason = map['reason'];

    for (var listener in _groupChangeListeners) {
      listener.onInvitationDeclined(groupId, inviter, reason);
    }
  }

  Future<void> _onUserRemoved(Map map) async {
    String groupId = map['groupId'];
    String groupName = map['groupName'];

    for (var listener in _groupChangeListeners) {
      listener.onUserRemoved(groupId, groupName);
    }
  }

  Future<void> _onGroupDestroyed(Map map) async {
    String groupId = map['groupId'];
    String groupName = map['groupName'];

    for (var listener in _groupChangeListeners) {
      listener.onGroupDestroyed(groupId, groupName);
    }
  }

  Future<void> _onAutoAcceptInvitationFromGroup(Map map) async {
    String groupId = map['groupId'];
    String inviter = map['inviter'];
    String inviteMessage = map['inviteMessage'];

    for (var listener in _groupChangeListeners) {
      listener.onAutoAcceptInvitationFromGroup(groupId, inviter, inviteMessage);
    }
  }

  Future<void> _onMuteListAdded(Map map) async {
    String groupId = map['groupId'];
    List mutes = map['mutes'];
    int muteExpire = map['muteExpire'];

    for (var listener in _groupChangeListeners) {
      listener.onMuteListAdded(groupId, mutes, muteExpire);
    }
  }

  Future<void> _onMuteListRemoved(Map map) async {
    String groupId = map['groupId'];
    List mutes = map['mutes'];

    for (var listener in _groupChangeListeners) {
      listener.onMuteListRemoved(groupId, mutes);
    }
  }

  Future<void> _onAdminAdded(Map map) async {
    String groupId = map['groupId'];
    String administrator = map['administrator'];

    for (var listener in _groupChangeListeners) {
      listener.onAdminAdded(groupId, administrator);
    }
  }

  Future<void> _onAdminRemoved(Map map) async {
    String groupId = map['groupId'];
    String administrator = map['administrator'];

    for (var listener in _groupChangeListeners) {
      listener.onAdminRemoved(groupId, administrator);
    }
  }

  Future<void> _onOwnerChanged(Map map) async {
    String groupId = map['groupId'];
    String newOwner = map['newOwner'];
    String oldOwner = map['oldOwner'];

    for (var listener in _groupChangeListeners) {
      listener.onOwnerChanged(groupId, newOwner, oldOwner);
    }
  }

  Future<void> _onMemberJoined(Map map) async {
    String groupId = map['groupId'];
    String member = map['member'];

    for (var listener in _groupChangeListeners) {
      listener.onMemberJoined(groupId, member);
    }
  }

  Future<void> _onMemberExited(Map map) async {
    String groupId = map['groupId'];
    String member = map['member'];

    for (var listener in _groupChangeListeners) {
      listener.onMemberExited(groupId, member);
    }
  }

  Future<void> _onAnnouncementChanged(Map map) async {
    String groupId = map['groupId'];
    String announcement = map['announcement'];

    for (var listener in _groupChangeListeners) {
      listener.onAnnouncementChanged(groupId, announcement);
    }
  }

  Future<void> _onSharedFileAdded(Map map) async {
    String groupId = map['groupId'];
    EMMucSharedFile sharedFile = EMMucSharedFile.from(map['shareFile']);

    for (var listener in _groupChangeListeners) {
      listener.onSharedFileAdded(groupId, sharedFile);
    }
  }

  Future<void> _onSharedFileDeleted(Map map) async {
    String groupId = map['groupId'];
    String fileId = map['fileId'];

    for (var listener in _groupChangeListeners) {
      listener.onSharedFileDeleted(groupId, fileId);
    }
  }

}
