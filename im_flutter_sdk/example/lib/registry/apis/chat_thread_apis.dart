import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../api_entry.dart';

/// ChatThreadManager related entries.
final chatThreadApis = <ApiEntry>[
  ApiEntry(
    name: 'ChatThreadManager.createChatThread',
    group: 'ChatThreadManager',
    description: '创建子区。messageId 为群消息 ID，parentId 为群组 ID。',
    paramsTemplate:
        '{"name": "name", "messageId": "messageId", "parentId": "parentId"}',
    invoke: (p) => ChatClient.getInstance.chatThreadManager.createChatThread(
      parentId: p['parentId'] as String,
      name: p['name'] as String,
      messageId: p['messageId'] as String,
    ),
  ),
  ApiEntry(
    name: 'ChatThreadManager.destroyChatThread',
    group: 'ChatThreadManager',
    description: '解散子区，仅子区所属群组的群主或管理员可调用。',
    paramsTemplate: '{"chatThreadId": "threadId"}',
    invoke: (p) => ChatClient.getInstance.chatThreadManager.destroyChatThread(
      chatThreadId: p['chatThreadId'] as String,
    ),
  ),
  ApiEntry(
    name: 'ChatThreadManager.joinChatThread',
    group: 'ChatThreadManager',
    description: '加入子区，调用者必须是子区所属群组的成员。',
    paramsTemplate: '{"chatThreadId": "threadId"}',
    invoke: (p) => ChatClient.getInstance.chatThreadManager.joinChatThread(
      chatThreadId: p['chatThreadId'] as String,
    ),
  ),
  ApiEntry(
    name: 'ChatThreadManager.leaveChatThread',
    group: 'ChatThreadManager',
    description: '退出子区。',
    paramsTemplate: '{"chatThreadId": "threadId"}',
    invoke: (p) => ChatClient.getInstance.chatThreadManager.leaveChatThread(
      chatThreadId: p['chatThreadId'] as String,
    ),
  ),
  ApiEntry(
    name: 'ChatThreadManager.fetchJoinedChatThreadsWithParentId',
    group: 'ChatThreadManager',
    description: '分页获取当前用户加入的指定群组子区列表。limit 取值范围为 1 到 50。',
    paramsTemplate: '{"parentId": "groupId", "cursor": "", "limit": 20}',
    invoke: (p) async {
      final result = await ChatClient.getInstance.chatThreadManager
          .fetchJoinedChatThreadsWithParentId(
        parentId: p['parentId'] as String,
        cursor: p['cursor'] as String?,
        limit: p['limit'] as int? ?? 20,
      );
      return {
        'cursor': result.cursor,
        'list': result.data.map((thread) => thread.toJson()).toList(),
        'totalCount': result.totalCount,
      };
    },
  ),
  ApiEntry(
    name: 'ChatThreadManager.updateChatThreadName',
    group: 'ChatThreadManager',
    description: '更新子区名称。',
    paramsTemplate: '{"chatThreadId": "threadId", "newName": "new name"}',
    invoke: (p) =>
        ChatClient.getInstance.chatThreadManager.updateChatThreadName(
      chatThreadId: p['chatThreadId'] as String,
      newName: p['newName'] as String,
    ),
  ),
  ApiEntry(
    name: 'ChatThreadManager.removeMemberFromChatThread',
    group: 'ChatThreadManager',
    description: '从子区中移除指定成员。',
    paramsTemplate: '{"chatThreadId": "threadId", "memberId": "userId"}',
    invoke: (p) =>
        ChatClient.getInstance.chatThreadManager.removeMemberFromChatThread(
      memberId: p['memberId'] as String,
      chatThreadId: p['chatThreadId'] as String,
    ),
  ),
];
