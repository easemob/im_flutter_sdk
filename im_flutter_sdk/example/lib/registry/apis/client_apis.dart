import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../api_entry.dart';

/// ChatClient related entries.
final clientApis = <ApiEntry>[
  ApiEntry(
    name: 'ChatClient.getCurrentDeviceId',
    group: 'ChatClient',
    description: '获取本设备 UUID，用于与在线设备列表匹配，不能假定列表首项是本设备。',
    paramsTemplate: '{}',
    invoke: (_) => ChatClient.getInstance.getCurrentDeviceId(),
  ),
  ApiEntry(
    name: 'ChatClient.isConnected',
    group: 'ChatClient',
    description: '检查当前 SDK 连接状态。',
    paramsTemplate: '{}',
    invoke: (_) => ChatClient.getInstance.isConnected(),
  ),
  ApiEntry(
    name: 'ChatClient.logout',
    group: 'ChatClient',
    description: '退出当前账号。unbindDeviceToken 默认为 true。',
    paramsTemplate: '{"unbindDeviceToken": true}',
    invoke: (p) => ChatClient.getInstance.logout(
      p['unbindDeviceToken'] as bool? ?? true,
    ),
  ),
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
