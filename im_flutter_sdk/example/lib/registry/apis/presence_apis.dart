import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../api_entry.dart';

/// PresenceManager 相关条目（复验测试反馈的 presence 问题用）。
final presenceApis = <ApiEntry>[
  ApiEntry(
    name: 'ChatPresenceManager.subscribe',
    group: 'PresenceManager',
    description: '订阅指定用户的在线状态，返回 ChatPresence 数组（含 expiryTime）。'
        'expiry 单位秒，最长 2592000（30 天）。',
    paramsTemplate: '''{
  "members": ["userId1", "userId2"],
  "expiry": 2592000
}''',
    invoke: (p) async {
      return ChatClient.getInstance.presenceManager.subscribe(
        members: (p['members'] as List).cast<String>(),
        expiry: p['expiry'] as int,
      );
    },
  ),
  ApiEntry(
    name: 'ChatPresenceManager.unsubscribe',
    group: 'PresenceManager',
    description: '取消订阅指定用户的在线状态。',
    paramsTemplate: '''{
  "members": ["userId1", "userId2"]
}''',
    invoke: (p) async {
      return ChatClient.getInstance.presenceManager.unsubscribe(
        members: (p['members'] as List).cast<String>(),
      );
    },
  ),
  ApiEntry(
    name: 'ChatPresenceManager.publishPresence',
    group: 'PresenceManager',
    description: '发布自定义在线状态。desc 为扩展信息字符串，超长时服务端应返回 400。',
    paramsTemplate: '''{
  "desc": "自定义状态描述"
}''',
    invoke: (p) async {
      return ChatClient.getInstance.presenceManager.publishPresence(
        p['desc'] as String,
      );
    },
  ),
  ApiEntry(
    name: 'ChatPresenceManager.fetchSubscribedMembers',
    group: 'PresenceManager',
    description: '分页查询当前用户订阅了哪些用户的在线状态，返回用户 ID 数组。'
        'pageNum 从 1 开始；pageSize 为 0 时预期返回错误。',
    paramsTemplate: '''{
  "pageNum": 1,
  "pageSize": 20
}''',
    invoke: (p) async {
      return ChatClient.getInstance.presenceManager.fetchSubscribedMembers(
        pageNum: (p['pageNum'] as int?) ?? 1,
        pageSize: (p['pageSize'] as int?) ?? 20,
      );
    },
  ),
  ApiEntry(
    name: 'ChatPresenceManager.fetchPresenceStatus',
    group: 'PresenceManager',
    description: '查询指定用户的当前在线状态，返回 ChatPresence 数组（含 expiryTime、desc 等）。',
    paramsTemplate: '''{
  "members": ["userId1", "userId2"]
}''',
    invoke: (p) async {
      return ChatClient.getInstance.presenceManager.fetchPresenceStatus(
        members: (p['members'] as List).cast<String>(),
      );
    },
  ),
];
