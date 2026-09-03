import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../api_entry.dart';

/// GroupManager related entries.
final groupApis = <ApiEntry>[
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
