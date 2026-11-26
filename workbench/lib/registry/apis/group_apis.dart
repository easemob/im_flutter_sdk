import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../api_entry.dart';

/// GroupManager related entries.
final groupApis = <ApiEntry>[
  ApiEntry(
    name: 'ChatGroupManager.updateGroupName',
    group: 'GroupManager',
    description: '修改指定群组名称。',
    paramsTemplate: '{"groupId": "yourGroupId", "name": "new group name"}',
    invoke: (p) => ChatClient.getInstance.groupManager
        .updateGroupName(p['groupId'] as String, p['name'] as String),
  ),
  ApiEntry(
    name: 'ChatGroupManager.addMembers',
    group: 'GroupManager',
    description: '邀请成员入群；是否需要接受由群配置及受邀方设置决定。',
    paramsTemplate: '{"groupId": "yourGroupId", "members": ["userId"]}',
    invoke: (p) => ChatClient.getInstance.groupManager.addMembers(
      p['groupId'] as String,
      (p['members'] as List).cast<String>(),
      welcome: p['welcome'] as String?,
    ),
  ),
  ApiEntry(
    name: 'ChatGroupManager.acceptInvitation',
    group: 'GroupManager',
    description: '接受指定邀请人发出的群组邀请。',
    paramsTemplate: '{"groupId": "yourGroupId", "inviter": "ownerId"}',
    invoke: (p) async => (await ChatClient.getInstance.groupManager
            .acceptInvitation(p['groupId'] as String, p['inviter'] as String))
        .toJson(),
  ),
  ApiEntry(
    name: 'ChatGroupManager.fetchMemberListFromServer',
    group: 'GroupManager',
    description: '分页读取服务端群成员列表。',
    paramsTemplate: '{"groupId": "yourGroupId", "pageSize": 200}',
    invoke: (p) async {
      final result =
          await ChatClient.getInstance.groupManager.fetchMemberListFromServer(
        p['groupId'] as String,
        pageSize: p['pageSize'] as int? ?? 200,
        cursor: p['cursor'] as String?,
      );
      return {'list': result.data, 'cursor': result.cursor};
    },
  ),
  ApiEntry(
    name: 'ChatGroupManager.getJoinedGroups',
    group: 'GroupManager',
    description: '读取本地已加入群组；用于核对登录同步后的实际数据。',
    paramsTemplate: '{}',
    invoke: (_) => ChatClient.getInstance.groupManager.getJoinedGroups(),
  ),
  ApiEntry(
    name: 'ChatGroupManager.fetchGroupInfoFromServer',
    group: 'GroupManager',
    description: '读取服务端群详情，核对创建或修改后的 configs。',
    paramsTemplate: '{"groupId": "yourGroupId"}',
    invoke: (p) => ChatClient.getInstance.groupManager
        .fetchGroupInfoFromServer(p['groupId'] as String),
  ),
  ApiEntry(
    name: 'ChatGroupManager.createGroup',
    group: 'GroupManager',
    description: '创建群组。5.0.0 起使用 configs 描述群组配置。',
    paramsTemplate: '''{
  "groupName": "group name",
  "desc": "group description",
  "configs": {
    "maxCount": 200,
    "inviteNeedConfirm": false,
    "isPublic": false,
    "joinApprovalRequired": false,
    "allowInvites": true
  }
}''',
    invoke: (p) async {
      final inviteMembers = p['inviteMembers'];
      final result = await ChatClient.getInstance.groupManager.createGroup(
        groupName: p['groupName'] as String?,
        avatarUrl: p['avatarUrl'] as String?,
        desc: p['desc'] as String?,
        inviteMembers: inviteMembers is List
            ? inviteMembers.map((value) => value.toString()).toList()
            : null,
        inviteReason: p['inviteReason'] as String?,
        configs: ChatGroupConfigs.fromJson(p['configs'] as Map),
      );
      return result.toJson();
    },
  ),
  ApiEntry(
    name: 'ChatGroupManager.updateGroupConfigs',
    group: 'GroupManager',
    description: '按位掩码更新群组配置。types 使用 ChatGroupConfigsType 常量按位或组合。',
    paramsTemplate: '''{
  "groupId": "yourGroupId",
  "types": 16,
  "configs": {"isPublic": true}
}''',
    invoke: (p) async {
      final result =
          await ChatClient.getInstance.groupManager.updateGroupConfigs(
        groupId: p['groupId'] as String,
        types: p['types'] as int,
        configs: ChatGroupConfigs.fromJson(p['configs'] as Map),
      );
      return result.toJson();
    },
  ),
  ApiEntry(
    name: 'ChatGroupManager.joinPublicGroup',
    group: 'GroupManager',
    description: '加入无需审批的公开群组。',
    paramsTemplate: '{"groupId": "yourGroupId"}',
    invoke: (p) => ChatClient.getInstance.groupManager
        .joinPublicGroup(p['groupId'] as String),
  ),
  ApiEntry(
    name: 'ChatGroupManager.leaveGroup',
    group: 'GroupManager',
    description: '当前成员退出指定群组；群主应使用解散群组接口。',
    paramsTemplate: '{"groupId": "yourGroupId"}',
    invoke: (p) =>
        ChatClient.getInstance.groupManager.leaveGroup(p['groupId'] as String),
  ),
  ApiEntry(
    name: 'ChatGroupManager.destroyGroup',
    group: 'GroupManager',
    description: '解散群组，仅群主可调用；用于清理 createGroup 创建的测试群。',
    paramsTemplate: '{"groupId": "yourGroupId"}',
    invoke: (p) => ChatClient.getInstance.groupManager
        .destroyGroup(p['groupId'] as String),
  ),
  ApiEntry(
    name: 'ChatGroupManager.updateGroupNamecard',
    group: 'GroupManager',
    description: '更新当前用户的群名片（4.22 新增）。可选参数 "namecard"：字符串；'
        '不传或显式给 null 表示移除群名片。变更结果通过 '
        'ChatGroupEventHandler.onUserGroupNamecardChanged 回调验证。',
    paramsTemplate: '''{
  "groupId": "yourGroupId"
}''',
    invoke: (p) async {
      return ChatClient.getInstance.groupManager.updateGroupNamecard(
        groupId: p['groupId'] as String,
        namecard: p['namecard'] as String?,
      );
    },
  ),
  ApiEntry(
    name: 'ChatGroupManager.getGroupNamecard',
    group: 'GroupManager',
    description: '获取群成员的群名片（4.22 新增），返回名片字符串；成员未设置时返回 null（结果无 data 字段）。',
    paramsTemplate: '''{
  "groupId": "yourGroupId",
  "userId": "memberUserId"
}''',
    invoke: (p) async {
      return ChatClient.getInstance.groupManager.getGroupNamecard(
        groupId: p['groupId'] as String,
        userId: p['userId'] as String,
      );
    },
  ),
];
