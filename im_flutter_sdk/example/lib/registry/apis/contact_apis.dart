import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../api_entry.dart';

/// ChatContactManager related entries (friend lifecycle, block list).
final contactApis = <ApiEntry>[
  ApiEntry(
    name: 'ChatContactManager.addContact',
    group: 'ChatContactManager',
    description: '向指定用户发出好友邀请（对方收到 onContactInvited）。',
    paramsTemplate: '{"userId": "userId", "reason": "hello"}',
    invoke: (p) => ChatClient.getInstance.contactManager.addContact(
      p['userId'] as String,
      reason: p['reason'] as String?,
    ),
  ),
  ApiEntry(
    name: 'ChatContactManager.acceptInvitation',
    group: 'ChatContactManager',
    description: '接受指定用户的好友邀请（发起方收到 onFriendRequestAccepted）。',
    paramsTemplate: '{"userId": "userId"}',
    invoke: (p) =>
        ChatClient.getInstance.contactManager.acceptInvitation(p['userId'] as String),
  ),
  ApiEntry(
    name: 'ChatContactManager.declineInvitation',
    group: 'ChatContactManager',
    description: '拒绝指定用户的好友邀请（发起方收到 onFriendRequestDeclined）。',
    paramsTemplate: '{"userId": "userId"}',
    invoke: (p) =>
        ChatClient.getInstance.contactManager.declineInvitation(p['userId'] as String),
  ),
  ApiEntry(
    name: 'ChatContactManager.deleteContact',
    group: 'ChatContactManager',
    description: '删除好友（可保留会话）；keepConversation 默认 false。',
    paramsTemplate: '{"userId": "userId", "keepConversation": false}',
    invoke: (p) => ChatClient.getInstance.contactManager.deleteContact(
      p['userId'] as String,
      keepConversation: p['keepConversation'] as bool? ?? false,
    ),
  ),
  ApiEntry(
    name: 'ChatContactManager.getAllContactIds',
    group: 'ChatContactManager',
    description: '从本地数据库获取好友 userId 列表（好友状态断言用）。',
    paramsTemplate: '{}',
    invoke: (_) => ChatClient.getInstance.contactManager.getAllContactIds(),
  ),
  ApiEntry(
    name: 'ChatContactManager.getAllContacts',
    group: 'ChatContactManager',
    description: '从本地数据库获取好友详情列表（含备注等字段）。',
    paramsTemplate: '{}',
    invoke: (_) => ChatClient.getInstance.contactManager.getAllContacts(),
  ),
  ApiEntry(
    name: 'ChatContactManager.getContact',
    group: 'ChatContactManager',
    description: '按 userId 获取单个联系人信息；非好友返回 null。',
    paramsTemplate: '{"userId": "userId"}',
    invoke: (p) =>
        ChatClient.getInstance.contactManager.getContact(userId: p['userId'] as String),
  ),
  ApiEntry(
    name: 'ChatContactManager.setContactRemark',
    group: 'ChatContactManager',
    description: '设置联系人备注。',
    paramsTemplate: '{"userId": "userId", "remark": "remark"}',
    invoke: (p) => ChatClient.getInstance.contactManager.setContactRemark(
      userId: p['userId'] as String,
      remark: p['remark'] as String,
    ),
  ),
  ApiEntry(
    name: 'ChatContactManager.addUserToBlockList',
    group: 'ChatContactManager',
    description: '将指定用户加入黑名单。',
    paramsTemplate: '{"userId": "userId"}',
    invoke: (p) => ChatClient.getInstance.contactManager
        .addUserToBlockList(p['userId'] as String),
  ),
  ApiEntry(
    name: 'ChatContactManager.removeUserFromBlockList',
    group: 'ChatContactManager',
    description: '将指定用户移出黑名单。',
    paramsTemplate: '{"userId": "userId"}',
    invoke: (p) => ChatClient.getInstance.contactManager
        .removeUserFromBlockList(p['userId'] as String),
  ),
  ApiEntry(
    name: 'ChatContactManager.fetchBlockIds',
    group: 'ChatContactManager',
    description: '从服务器获取黑名单 userId 列表。',
    paramsTemplate: '{}',
    invoke: (_) => ChatClient.getInstance.contactManager.fetchBlockIds(),
  ),
];
