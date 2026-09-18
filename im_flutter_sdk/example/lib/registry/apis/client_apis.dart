import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../api_entry.dart';

/// ChatClient related entries.
final clientApis = <ApiEntry>[
  ApiEntry(
    name: 'ChatClient.fetchLoggedInDevices',
    group: 'ChatClient',
    description: '使用用户 Token 获取指定账号的在线设备列表。',
    paramsTemplate: '{"userId": "userId", "token": "userToken"}',
    invoke: (p) => ChatClient.getInstance.fetchLoggedInDevices(
      userId: p['userId'] as String,
      token: p['token'] as String,
    ),
  ),
  ApiEntry(
    name: 'ChatClient.renewToken',
    group: 'ChatClient',
    description: '更新当前登录会话的用户 Token。',
    paramsTemplate: '{"token": "userToken"}',
    invoke: (p) => ChatClient.getInstance.renewToken(p['token'] as String),
  ),
  ApiEntry(
    name: 'ChatClient.kickDevice',
    group: 'ChatClient',
    description: '使用用户 Token 将指定账号的一个设备踢下线。',
    paramsTemplate:
        '{"userId": "userId", "token": "userToken", "resource": "resource"}',
    invoke: (p) => ChatClient.getInstance.kickDevice(
      userId: p['userId'] as String,
      token: p['token'] as String,
      resource: p['resource'] as String,
    ),
  ),
  ApiEntry(
    name: 'ChatClient.kickAllDevices',
    group: 'ChatClient',
    description: '使用用户 Token 将指定账号的全部设备踢下线；脚本中应放在最后。',
    paramsTemplate: '{"userId": "userId", "token": "userToken"}',
    invoke: (p) => ChatClient.getInstance.kickAllDevices(
      userId: p['userId'] as String,
      token: p['token'] as String,
    ),
  ),
];
