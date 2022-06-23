import 'dart:async';

import 'package:flutter/services.dart';
import 'models/em_download_callback.dart';
import 'em_listeners.dart';
import 'internal/em_event_keys.dart';
import 'models/em_cursor_result.dart';
import 'models/em_error.dart';
import 'models/em_group.dart';
import 'models/em_group_info.dart';
import 'models/em_group_options.dart';
import 'models/em_group_shared_file.dart';
import 'tools/em_extension.dart';

import 'internal/chat_method_keys.dart';

///
/// 群组管理类, 用于管理群组的创建，删除及成员管理等操作。
///
class EMGroupManager {
  static const _channelPrefix = 'com.chat.im';
  static const MethodChannel _channel = const MethodChannel(
      '$_channelPrefix/chat_group_manager', JSONMethodCodec());

  /// @nodoc
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

  final List<EMGroupManagerListener> _listeners = [];

  ///
  /// 群文件下载回调
  ///
  EMDownloadCallback? downloadCallback;

  ///
  /// 根据群组 ID，从本地缓存中获取指定群组。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// **Return** 返回群组对象。如果群组不存在，返回 null。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<EMGroup?> getGroupWithId(String groupId) async {
    Map req = {'groupId': groupId};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.getGroupWithId, req);
    try {
      EMError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.getGroupWithId)) {
        return EMGroup.fromJson(result[ChatMethodKeys.getGroupWithId]);
      } else {
        return null;
      }
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 从本地缓存中获取当前用户的所有群组。
  ///
  /// **Return** 群组列表。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<List<EMGroup>> getJoinedGroups() async {
    Map result = await _channel.invokeMethod(ChatMethodKeys.getJoinedGroups);
    try {
      EMError.hasErrorFromResult(result);
      List<EMGroup> list = [];
      result[ChatMethodKeys.getJoinedGroups]
          ?.forEach((element) => list.add(EMGroup.fromJson(element)));
      return list;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 从服务器中获取当前用户加入的所有群组。
  ///
  /// 此操作只返回群组列表，不包含所有成员的信息。如果要更新某个群组包括成员的全部信息，需要再调用 {@link #fetchGroupInfoFromServer(String groupId)}。
  ///
  /// **Return** 当前用户加入的群组的列表。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。

  Future<List<EMGroup>> fetchJoinedGroupsFromServer({
    int pageSize = 200,
    int pageNum = 1,
  }) async {
    Map req = {'pageSize': pageSize, 'pageNum': pageNum};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getJoinedGroupsFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      List<EMGroup> list = [];
      result[ChatMethodKeys.getJoinedGroupsFromServer]
          ?.forEach((element) => list.add(EMGroup.fromJson(element)));
      return list;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 以分页方式从服务器获取当前用户的所有公开群组。
  ///
  /// Param [pageSize] 每页返回的群组数。
  ///
  /// Param [cursor] 从这个游标位置开始取数据，首次获取数据时传 null 即可。
  ///
  /// **Return** 包含用于下次获取数据的 cursor 以及群组列表。返回的结果中，当 `EMCursorResult.getCursor()` 为空字符串 ("") 时，表示没有更多数据。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<EMCursorResult<EMGroupInfo>> fetchPublicGroupsFromServer({
    int pageSize = 200,
    String? cursor,
  }) async {
    Map req = {'pageSize': pageSize};
    req.setValueWithOutNull("cursor", cursor);
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getPublicGroupsFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMCursorResult<EMGroupInfo>.fromJson(
          result[ChatMethodKeys.getPublicGroupsFromServer],
          dataItemCallback: (value) {
        return EMGroupInfo.fromJson(value);
      });
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 创建群组。
  ///
  /// 群组创建成功后，会更新内存及数据库中的数据，多端多设备会收到相应的通知事件，将群组更新到内存及数据库中。
  /// 可通过设置 {@link com.EMMultiDeviceListener} 监听相关事件，事件回调函数为 {@link com.EMMultiDeviceListener#onGroupEvent(int, String, List)}，第一个参数为事件，创建群组事件为 {@link com.EMMultiDeviceListener#GROUP_CREATE}。
  ///
  /// Param [groupName] 群组名称。
  ///
  /// Param [desc] 群组描述。
  ///
  /// Param [inviteMembers] 群成员数组。群主 ID 可选。
  ///
  /// Param [inviteReason] 用户入群邀请信息。
  ///
  /// Param [options] 群组的其他选项。请参见 {@link EMGroupOptions}。
  /// 群组的其他选项。
  /// - 群最大成员数，默认值为 200；
  /// - 群组类型，详见 {@link EMGroupManager.EMGroupStyle}，默认为 {@link EMGroupStyle#EMGroupStylePrivateOnlyOwnerInvite}；
  /// - 邀请进群是否需要对方同意，默认为 false，即邀请后直接进群；
  /// - 群组详情扩展。
  ///
  /// **Return** 创建成功的群对象。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<EMGroup> createGroup({
    String? groupName,
    String? desc,
    List<String>? inviteMembers,
    String? inviteReason,
    required EMGroupOptions options,
  }) async {
    Map req = {'options': options.toJson()};
    req.setValueWithOutNull("groupName", groupName);
    req.setValueWithOutNull("desc", desc);
    req.setValueWithOutNull("inviteMembers", inviteMembers);
    req.setValueWithOutNull("inviteReason", inviteReason);

    Map result = await _channel.invokeMethod(ChatMethodKeys.createGroup, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMGroup.fromJson(result[ChatMethodKeys.createGroup]);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 从服务器获取群组的详细信息。
  ///
  /// 该方法不获取成员。如需获取成员，使用 {@link #getGroupMemberListFromServer(String, int?, String?)}。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// **Return** 群组描述。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<EMGroup> fetchGroupInfoFromServer(
    String groupId, {
    bool fetchMembers = false,
  }) async {
    Map req = {"groupId": groupId, "fetchMembers": fetchMembers};
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

  ///
  /// 以分页方式获取群组成员列表。
  ///
  /// 例如:
  ///   ```dart
  ///     EMCursorResult<String> result = await EMClient.getInstance.groupManager.fetchMemberListFromServer(groupId); // search 1
  ///     result = await EMClient.getInstance.groupManager.fetchMemberListFromServer(groupId, cursor: result.cursor); // search 2
  ///   ```
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [pageSize] 每页返回的群组成员数。
  ///
  /// Param [cursor] 从这个游标位置开始取数据，首次获取数据时传 null 即可。
  ///
  /// **Return** 分页获取结果 {@link EMCursorResult}，包含用于下次获取数据的 cursor 以及群组成员列表。返回的结果中，当 `EMCursorResult.getCursor()` 为空字符串 ("") 时，表示没有更多数据。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<EMCursorResult<String>> fetchMemberListFromServer(
    String groupId, {
    int pageSize = 200,
    String? cursor,
  }) async {
    Map req = {
      'groupId': groupId,
      'pageSize': pageSize,
    };
    req.setValueWithOutNull("cursor", cursor);
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

  ///
  /// 以分页方式获取群组的黑名单。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [pageSize] 每页返回的群组数。
  ///
  /// Param [pageNum] 当前页码，从 1 开始。
  ///
  /// **Return** 返回的黑名单列表。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<List<String>> fetchBlockListFromServer(
    String groupId, {
    int pageSize = 200,
    int pageNum = 1,
  }) async {
    Map req = {'groupId': groupId, 'pageNum': pageNum, 'pageSize': pageSize};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getGroupBlockListFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      return result[ChatMethodKeys.getGroupBlockListFromServer]
              ?.cast<String>() ??
          [];
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 获取群组的禁言列表。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [pageSize] 每页返回的禁言成员数。
  ///
  /// Param [pageNum] 当前页码，从 1 开始。
  ///
  /// **Return** 群组的禁言列表。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<Map<String, int>> fetchMuteListFromServer(
    String groupId, {
    int pageSize = 200,
    int pageNum = 1,
  }) async {
    Map req = {'groupId': groupId, 'pageNum': pageNum, 'pageSize': pageSize};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getGroupMuteListFromServer, req);
    try {
      EMError.hasErrorFromResult(result);
      Map? tmpMap = result[ChatMethodKeys.getGroupMuteListFromServer];
      Map<String, int> ret = {};
      if (tmpMap != null) {
        for (var item in tmpMap.entries) {
          if (item.key is String && item.value is int) {
            ret[item.key] = item.value;
          }
        }
      }
      return ret;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 获取群组白名单列表。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// **Return** 群组的白名单。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<List<String>> fetchAllowListFromServer(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.getGroupWhiteListFromServer, req);
    try {
      List<String> list = [];
      EMError.hasErrorFromResult(result);
      result[ChatMethodKeys.getGroupWhiteListFromServer]?.forEach((element) {
        if (element is String) {
          list.add(element);
        }
      });
      return list;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 检查当前用户是否在群组白名单中。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// **Return** 是否在群组白名单。
  /// - `true`: 是；
  /// - `false`: 否。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<bool> isMemberInAllowListFromServer(String groupId) async {
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

  ///
  /// 从服务器获取群组的共享文件列表。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [pageSize] 每页返回的共享文件数量。
  ///
  /// Param [pageNum] 当前页码，从 1 开始。
  ///
  /// **Return** 返回共享文件列表。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<List<EMGroupSharedFile>> fetchGroupFileListFromServer(
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

  ///
  /// 从服务器获取群组公告。
  ///
  /// 群成员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// **Return** 群组公告。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<String?> fetchAnnouncementFromServer(String groupId) async {
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

  ///
  /// 向群组中添加新成员。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [members] 要添加的新成员数组。
  ///
  /// Param [welcome] 欢迎消息。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<void> addMembers(
    String groupId,
    List<String> members, {
    String? welcome,
  }) async {
    Map req = {'groupId': groupId, 'members': members};
    req.setValueWithOutNull("welcome", welcome);
    Map result = await _channel.invokeMethod(ChatMethodKeys.addMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 邀请用户加入群组。
  ///
  /// 群类型为 PrivateOnlyOwnerInvite、PrivateMemberCanInvite 和 PublicJoinNeedApproval 的群组可以邀请用户加入。
  ///
  /// 该方法仅适用于私有群。对于 PrivateOnlyOwnerInvite 属性的群组，仅群主可邀请用户入群；对于 PrivateMemberCanInvite 属性的群组，群成员可邀请用户入群。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [members] 要邀请的新成员数组。
  ///
  /// Param [reason] 邀请原因。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<void> inviterUser(
    String groupId,
    List<String> members, {
    String? reason,
  }) async {
    Map req = {
      'groupId': groupId,
      'members': members,
    };
    req.setValueWithOutNull("reason", reason);

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

  ///
  /// 将群成员移出群组。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID.
  ///
  /// Param [members] 要删除的成员的用户名。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
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

  ///
  /// 将用户加入群组黑名单。
  ///
  /// 先将用户移出群，再加入黑名单。加入黑名单的用户无法加入群。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [members] 要加入黑名单的用户名。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
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

  ///
  /// 将用户从群组黑名单中移除。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [members] 要从黑名单中移除的用户。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
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

  ///
  /// 修改群组名称。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [name] 修改后的群组名称。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<void> changeGroupName(
    String groupId,
    String name,
  ) async {
    Map req = {'name': name, 'groupId': groupId};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.updateGroupSubject, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 修改群描述。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [desc] 修改后的群描述。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<void> changeGroupDescription(
    String groupId,
    String desc,
  ) async {
    Map req = {'desc': desc, 'groupId': groupId};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.updateDescription, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 当前登录用户退出群组。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<void> leaveGroup(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await _channel.invokeMethod(ChatMethodKeys.leaveGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 解散群组。
  ///
  /// 仅群主可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<void> destroyGroup(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await _channel.invokeMethod(ChatMethodKeys.destroyGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 屏蔽群消息。
  ///
  /// 屏蔽群消息的用户仍是群成员，但不会收到群消息。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<void> blockGroup(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await _channel.invokeMethod(ChatMethodKeys.blockGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 取消屏蔽群消息。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<void> unblockGroup(String groupId) async {
    Map req = {'groupId': groupId};
    Map result = await _channel.invokeMethod(ChatMethodKeys.unblockGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 转让群组所有权。
  ///
  /// 仅群主可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [newOwner] 新的群主。
  ///
  /// **Return** 返回新群主。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<void> changeOwner(
    String groupId,
    String newOwner,
  ) async {
    Map req = {'groupId': groupId, 'owner': newOwner};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.updateGroupOwner, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 添加群组管理员。
  ///
  /// 仅群主可调用此方法，管理员无权限。
  ///
  /// Param [groupId]   群组 ID。
  ///
  /// Param [memberId]  要添加的管理员的 ID。
  ///
  /// **Return**  返回更新后的群组对象。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<void> addAdmin(
    String groupId,
    String memberId,
  ) async {
    Map req = {'groupId': groupId, 'admin': memberId};
    Map result = await _channel.invokeMethod(ChatMethodKeys.addAdmin, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 删除群组管理员。
  ///
  /// 仅群主可调用此方法。
  ///
  /// Param [groupId]  群组 ID。
  ///
  /// Param [adminId] 要移除的群组管理员的用户名。
  ///
  /// **Return** 返回更新后的群组对象。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<void> removeAdmin(
    String groupId,
    String adminId,
  ) async {
    Map req = {'groupId': groupId, 'admin': adminId};
    Map result = await _channel.invokeMethod(ChatMethodKeys.removeAdmin, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 将指定成员禁言
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [members] 要禁言的成员列表。
  ///
  /// Param [duration] 禁言时长，单位为毫秒。
  ///
  /// **Return** 返回更新后的群组对象。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<void> muteMembers(
    String groupId,
    List<String> members, {
    int duration = -1,
  }) async {
    Map req = {'groupId': groupId, 'members': members, 'duration': duration};
    Map result = await _channel.invokeMethod(ChatMethodKeys.muteMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 取消禁言指定用户。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [members] 要解除禁言的成员列表。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<void> unMuteMembers(
    String groupId,
    List<String> members,
  ) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result = await _channel.invokeMethod(ChatMethodKeys.unMuteMembers, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 开启全员禁言。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
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

  ///
  /// 关闭全员禁言。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
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

  ///
  /// 将成员添加至群组白名单。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [members] 要添加至白名单的成员列表。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<void> addAllowList(
    String groupId,
    List<String> members,
  ) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result = await _channel.invokeMethod(ChatMethodKeys.addWhiteList, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 将成员移除群组白名单。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [members] 要移除白名单的成员列表。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<void> removeAllowList(
    String groupId,
    List<String> members,
  ) async {
    Map req = {'groupId': groupId, 'members': members};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.removeWhiteList, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 上传共享文件至群组。
  ///
  /// 上传共享文件会触发上传进度回调。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [filePath] 共享文件的本地路径。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<void> uploadGroupSharedFile(
    String groupId,
    String filePath,
  ) async {
    Map req = {'groupId': groupId, 'filePath': filePath};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.uploadGroupSharedFile, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 下载指定的群组共享文件。
  ///
  /// 注意：callback 只做进度回调用。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [fileId]  共享文件的 ID。
  ///
  /// Param [savePath] 共享文件的本地路径。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<void> downloadGroupSharedFile({
    required String groupId,
    required String fileId,
    required String savePath,
  }) async {
    Map req = {'groupId': groupId, 'fileId': fileId, 'savePath': savePath};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.downloadGroupSharedFile, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 删除指定的群组共享文件。
  ///
  /// 群成员可删除自己上传的文件，群主或者管理员可删除所有共享文件。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [fileId] 共享文件的 ID。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<void> removeGroupSharedFile(
    String groupId,
    String fileId,
  ) async {
    Map req = {'groupId': groupId, 'fileId': fileId};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.removeGroupSharedFile, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 更新群公告。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [announcement] 群组公告。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<void> updateGroupAnnouncement(
    String groupId,
    String announcement,
  ) async {
    Map req = {'groupId': groupId, 'announcement': announcement};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.updateGroupAnnouncement, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 更新群组扩展字段。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [extension] 群组扩展字段。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<void> updateGroupExtension(
    String groupId,
    String extension,
  ) async {
    Map req = {'groupId': groupId, 'ext': extension};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.updateGroupExt, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 当前登录用户加入公开群。
  ///
  /// 若是自由加入的公开群，直接进入群组；若公开群需验证，群主同意后才能入群。详见 {@link EMGroupStyle}。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<void> joinPublicGroup(
    String groupId,
  ) async {
    Map req = {'groupId': groupId};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.joinPublicGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 申请加入群组。
  ///
  /// 该方法仅适用于需要验证的公开群组，即类型为 {@link EMGroupStyle#EMGroupStylePublicJoinNeedApproval} 的群组。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [reason] 申请入群的原因。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<void> requestToJoinPublicGroup(
    String groupId, {
    String? reason,
  }) async {
    Map req = {'groupId': groupId};
    req.setValueWithOutNull('reason', reason);
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.requestToJoinPublicGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 批准入群申请。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [username] 申请人的用户名。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<void> acceptJoinApplication(
    String groupId,
    String username,
  ) async {
    Map req = {'groupId': groupId, 'username': username};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.acceptJoinApplication, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 拒绝入群申请。
  ///
  /// 仅群主和管理员可调用此方法。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [username] 申请人的用户名。
  ///
  /// Param [reason] 拒绝理由。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<void> declineJoinApplication(
    String groupId,
    String username, {
    String? reason,
  }) async {
    Map req = {'groupId': groupId, 'username': username};
    req.setValueWithOutNull('reason', reason);

    Map result =
        await _channel.invokeMethod(ChatMethodKeys.declineJoinApplication, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 接受入群邀请。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [inviter] 邀请者的用户名。
  ///
  /// **Return** 用户已接受邀请的群组对象。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<EMGroup> acceptInvitation(
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

  ///
  /// 拒绝入群邀请。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [inviter] 邀请者的用户名。
  ///
  /// Param [reason] 拒绝理由。
  ///
  /// **Throws**  如果有异常会在此抛出，包括错误码和错误信息，详见 {@link EMError}。
  ///
  Future<void> declineInvitation({
    required String groupId,
    required String inviter,
    String? reason,
  }) async {
    Map req = {'groupId': groupId, 'inviter': inviter};
    req.setValueWithOutNull('reason', reason);
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.declineInvitationFromGroup, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 注册群变动事件监听器。
  ///
  /// 如需删除群变动事件监听器，可调用 {@link #removeGroupManagerListener(EMGroupManagerListener)}。
  ///
  /// Param [listener] 要注册的群组事件监听器。
  ///
  void addGroupManagerListener(EMGroupManagerListener listener) {
    _listeners.remove(listener);
    _listeners.add(listener);
  }

  ///
  /// 移除群组变化监听器。
  ///
  /// 该方法在注册 {@link #addGroupManagerListener(EMGroupManagerListener)}后调用。
  ///
  /// Param [listener] 要移除的群组监听器。
  ///
  void removeGroupManagerListener(EMGroupManagerListener listener) {
    _listeners.remove(listener);
  }

  ///
  /// 移除所有群组变化监听器。
  ///
  void clearAllGroupManagerListeners() {
    _listeners.clear();
  }

  Future<void> _onGroupChanged(Map? map) async {
    for (var listener in _listeners) {
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
          listener.onAllowListAddedFromGroup(groupId, members);
          break;
        case EMGroupChangeEvent.ON_WHITE_LIST_REMOVED:
          String groupId = map["groupId"];
          List<String> members = List.from(map['whitelist']);
          listener.onAllowListRemovedFromGroup(groupId, members);
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
