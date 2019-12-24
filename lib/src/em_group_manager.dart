import "dart:async";

import 'package:flutter/services.dart';

import 'em_group.dart';
import 'em_sdk_method.dart';
import 'em_domain_terms.dart';
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

  /// 获取当前(内存)用户的所有群组
  Future<List<EMGroup>> getAllGroups() async {
    Map<String, dynamic> result =
        await _emGroupManagerChannel.invokeMethod(EMSDKMethod.getAllGroups);
    if (result['success']) {
      var data = List<EMGroup>();
      if (result['value'] != null) {
        var groups = result['value'] as List<dynamic>;
        for (var group in groups) {
          data.add(EMGroup.from(group));
        }
        return data;
      } else {
        return data;
      }
    } else {
      return null;
    }
  }

  /// 根据群组ID，获得群组对象
  Future<EMGroup> getGroup(String groupId) async {
    Map<String, dynamic> result = await _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.getGroup, {"groupId": groupId});
    if (result['success']) {
      if (result['value'] != null) {
        return EMGroup.from(result['value']);
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  /// 在IM服务器创建一个群组
  void createGroup(
      String groupName,
      String desc,
      List<String> members,
      String reason,
      EMGroupOptions options,
      {onSuccess(EMGroup group),
      onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result =
        _emGroupManagerChannel.invokeMethod(EMSDKMethod.createGroup, {
      "groupName": groupName,
      "desc": desc,
      "members": members,
      "reason": reason,
      "maxUsers": options.maxUsers,
      "groupStyle": convertEMGroupStyleToInt(options.style)
    });
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

  /// 同步加载所有群组
  void loadAllGroups() {
    _emGroupManagerChannel.invokeMethod(EMSDKMethod.loadAllGroups);
  }

  /// 解散群组
  void destroyGroup(String groupId,
      {onSuccess(), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.destroyGroup, {"groupId": groupId});
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

  /// 向群组中添加新的成员
  void addUsersToGroup(String groupId, List<String> members,
      {onSuccess(), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.addUsersToGroup, {"groupId": groupId, "members": members});
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

  /// 从群组中删除成员
  void removeUserFromGroup(String groupId, String userName,
      {onSuccess(), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.removeUserFromGroup,
        {"groupId": groupId, "userName": userName});
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

  /// 当前登录用户退出群组
  void leaveGroup(String groupId,
      {onSuccess(), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.leaveGroup, {"groupId": groupId});
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

  /// 从服务器获取群组的详细信息
  void getGroupFromServer(String groupId,
      {onSuccess(EMGroup group), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.getGroupFromServer, {"groupId": groupId});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          if (response['value'] != null) {
            print(response['value']);
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

  /// 从服务器端获取当前用户的所有群组此操作只返回群组列表，并不获取群组的所有成员信息
  void getJoinedGroupsFromServer(
      {onSuccess(List<EMGroup> groups), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.getJoinedGroupsFromServer);
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          var data = List<EMGroup>();
          if (response['value'] != null) {
            var groups = response['value'] as List<dynamic>;
            for (var group in groups) {
              data.add(EMGroup.from(group));
            }
            onSuccess(data);
          } else {
            onSuccess(data);
          }
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// 从服务器获取公开群组,EMCursorResult加泛型
  void getPublicGroupsFromServer(int pageSize, String cursor,
      {onSuccess(EMCursorResult<EMGroupInfo> result),
      onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.getPublicGroupsFromServer,
        {"pageSize": pageSize, "cursor": cursor});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          if (response['value'] != null) {
            print(response['value']);
            var data = List<EMGroupInfo>();
            EMCursorResult emCursorResult =
                EMCursorResult.from(response['value']);
            emCursorResult
                .getData()
                .forEach((item) => data.add(EMGroupInfo.from(item)));

            EMCursorResult<EMGroupInfo> cursorResult =
                EMCursorResult.from(Map());
            cursorResult.setCursor(emCursorResult.getCursor());
            cursorResult.setData(data);
            onSuccess(cursorResult);
          } else {
            onSuccess(null);
          }
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// 当前登录用户加入公开群(如果是自由加入的公开群，直接进入群组)
  void joinGroup(String groupId,
      {onSuccess(), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.joinGroup, {"groupId": groupId});
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

  /// 改变群组的名称
  void changeGroupName(String groupId, String groupName,
      {onSuccess(), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.changeGroupName,
        {"groupId": groupId, "groupName": groupName});
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

  /// 修改群描述
  void changeGroupDescription(String groupId, String desc,
      {onSuccess(), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.changeGroupDescription, {"groupId": groupId, "desc": desc});
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

  /// 接受加入群的邀请
  void acceptInvitation(String groupId, String inviter,
      {onSuccess(EMGroup group), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.acceptGroupInvitation,
        {"groupId": groupId, "inviter": inviter});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          if (response['value'] != null) {
            onSuccess(EMGroup.from(response["value"]));
          } else {
            onSuccess(null);
          }
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// 拒绝加入群的邀请
  void declineInvitation(
      String groupId, String inviter, String reason,
      {onSuccess(), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.declineGroupInvitation,
        {"groupId": groupId, "inviter": inviter, "reason": reason});
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

  /// 同意加群申请
  void acceptApplication(String userName, String groupId,
      {onSuccess(), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.acceptApplication,
        {"userName": userName, "groupId": groupId});
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

  /// 拒绝加群申请
  void declineApplication(
      String userName, String groupId, String reason,
      {onSuccess(), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.declineApplication,
        {"userName": userName, "groupId": groupId, "reason": reason});
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

  ///  群成员邀请用户加入群组 （如果群组设置成开放群成员邀请，群组成员可以邀请其他用户加入）
  void inviteUser(
      String groupId, List<String> members, String reason,
      {onSuccess(), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.inviteUser,
        {"groupId": groupId, "members": members, "reason": reason});
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

  /// 申请加入某个群
  void applyJoinToGroup(String groupId, String reason,
      {onSuccess(), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.applyJoinToGroup, {"groupId": groupId, "reason": reason});
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

  /// 屏蔽群消息（还是群里面的成员，但不再接收群消息）
  void blockGroupMessage(String groupId,
      {onSuccess(), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.blockGroupMessage, {"groupId": groupId});
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

  /// 取消屏蔽群消息
  void unblockGroupMessage(String groupId,
      {onSuccess(), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.unblockGroupMessage, {"groupId": groupId});
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

  /// 将用户加到群组的黑名单，被加入黑名单的用户无法加入群，无法收发此群的消息
  void blockUser(String groupId, String userName,
      {onSuccess(), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.blockUser, {"groupId": groupId, "userName": userName});
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

  /// 将用户从群组的黑名单移除
  void unblockUser(String groupId, String userName,
      {onSuccess(), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.unblockUser, {"groupId": groupId, "userName": userName});
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

  /// 获取群组成员列表
  void fetchGroupMembers(
      String groupId, String cursor, int pageSize,
      {onSuccess(EMCursorResult result), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.fetchGroupMembers,
        {"groupId": groupId, "cursor": cursor, "pageSize": pageSize});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          if (response['value'] != null) {
            List<String> list = [];
            var value = response['value'] as Map<String, dynamic>;
            EMCursorResult emCursorResult = EMCursorResult.from(value);
            emCursorResult.getData().forEach((item) => list.add(item));

            EMCursorResult<String> cursorResult = EMCursorResult.from(Map());
            cursorResult.setData(list);
            cursorResult.setCursor(emCursorResult.getCursor());
            onSuccess(cursorResult);
          } else {
            onSuccess(null);
          }
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// 转让群组，群组所有权给他人
  void changeOwner(String groupId, String newOwner,
      {onSuccess(EMGroup group), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.changeOwner, {"groupId": groupId, "newOwner": newOwner});
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

  /// 增加群组管理员，需要owner权限，admin无权限
  void addGroupAdmin(String groupId, String admin,
      {onSuccess(EMGroup group), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.addGroupAdmin, {"groupId": groupId, "admin": admin});
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

  /// 删除群组管理员，需要owner权限
  void removeGroupAdmin(String groupId, String admin,
      {onSuccess(EMGroup group), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.removeGroupAdmin, {"groupId": groupId, "admin": admin});
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

  /// 禁止某些群组成员发言
  void muteGroupMembers(
      String groupId, List<String> members, String duration,
      {onSuccess(EMGroup group), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.muteGroupMembers,
        {"groupId": groupId, "members": members, "duration": duration});
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

  /// 解除禁言
  void unMuteGroupMembers(String groupId, List<String> members,
      {onSuccess(EMGroup group), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.unMuteGroupMembers,
        {"groupId": groupId, "members": members});
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

  ///  获取群组的禁言列表
  void fetchGroupMuteList(
      String groupId, int pageNum, int pageSize,
      {onSuccess(List list), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.fetchGroupMuteList,
        {"groupId": groupId, "pageNum": pageNum, "pageSize": pageSize});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          var data = List<String>();
          if (response['value'] != null) {
            var list = response['value'] as List<dynamic>;
            list.forEach((item) => data.add(item));
            onSuccess(data);
          } else {
            onSuccess(data);
          }
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// 从服务器获分页获取群组黑名单
  void fetchGroupBlackList(
      String groupId, int pageNum, int pageSize,
      {onSuccess(List list), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.fetchGroupBlackList,
        {"groupId": groupId, "pageNum": pageNum, "pageSize": pageSize});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          var data = List<String>();
          if (response['value'] != null) {
            var users = response['value'] as List<dynamic>;
            users.forEach((user) => data.add(user));
            onSuccess(data);
          } else {
            onSuccess(data);
          }
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///  更新群公告
  void updateGroupAnnouncement(String groupId, String announcement,
      {onSuccess(), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.updateGroupAnnouncement,
        {"groupId": groupId, "announcement": announcement});
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

  /// 从服务器获取群公告
  void fetchGroupAnnouncement(String groupId,
      {onSuccess(String announcement), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel
        .invokeMethod(EMSDKMethod.fetchGroupAnnouncement, {"groupId": groupId});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          if (response['value'] != null) {
            onSuccess(response['value']);
          } else {
            onSuccess(null);
          }
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// 上传共享文件至群组
  void uploadGroupSharedFile(String groupId, String filePath,
      {onSuccess(), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.uploadGroupSharedFile,
        {"groupId": groupId, "filePath": filePath});
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

  /// 从服务器获取群组的共享文件列表
  void fetchGroupSharedFileList(
      String groupId, int pageNum, int pageSize,
      {onSuccess(List<EMMucSharedFile> files),
      onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.fetchGroupSharedFileList,
        {"groupId": groupId, "pageNum": pageNum, "pageSize": pageSize});
    result.then((response) {
      if (response['success']) {
        if (onSuccess != null) {
          var data = List<EMMucSharedFile>();
          if (response['value'] != null) {
            var value = response['value'] as List<dynamic>;
            for (var file in value) {
              data.add(EMMucSharedFile.from(file));
            }
            onSuccess(data);
          } else {
            onSuccess(data);
          }
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// 从群组里删除这个共享文件
  void deleteGroupSharedFile(String groupId, String fileId,
      {onSuccess(), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.deleteGroupSharedFile,
        {"groupId": groupId, "fileId": fileId});
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

  /// 下载群里的某个共享文件
  void downloadGroupSharedFile(
      String groupId, String fileId, String savePath,
      {onSuccess(), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.downloadGroupSharedFile,
        {"groupId": groupId, "fileId": fileId, "savePath": savePath});
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

  /// 更新群组扩展字段
  void updateGroupExtension(String groupId, String extension,
      {onSuccess(EMGroup group), onError(int errorCode, String desc)}) {
    Future<Map<String, dynamic>> result = _emGroupManagerChannel.invokeMethod(
        EMSDKMethod.updateGroupExtension,
        {"groupId": groupId, "extension": extension});
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
          EMMucSharedFile sharedFile = EMMucSharedFile.from(map['sharedFile']);
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
