import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../api_entry.dart';

/// UserInfoManager 相关条目（4.22 新增，需 EMOptions.enableUserInfo=true）。
final userInfoApis = <ApiEntry>[
  ApiEntry(
    name: 'EMUserInfoManager.subscribeUsersInfo',
    group: 'UserInfoManager',
    description:
        '订阅指定用户的用户属性（4.22 新增，需 enableUserInfo=true）。'
        '订阅成功后被订阅用户属性更新时收到 EMUserInfoEventHandler.onUserInfoUpdate 回调。',
    paramsTemplate: '''{
  "userIds": ["userId1", "userId2"]
}''',
    invoke: (p) async {
      return EMClient.getInstance.userInfoManager
          .subscribeUsersInfo((p['userIds'] as List).cast<String>());
    },
  ),
  ApiEntry(
    name: 'EMUserInfoManager.unsubscribeUsersInfo',
    group: 'UserInfoManager',
    description: '取消订阅指定用户的用户属性（4.22 新增，需 enableUserInfo=true）。',
    paramsTemplate: '''{
  "userIds": ["userId1", "userId2"]
}''',
    invoke: (p) async {
      return EMClient.getInstance.userInfoManager
          .unsubscribeUsersInfo((p['userIds'] as List).cast<String>());
    },
  ),
  ApiEntry(
    name: 'EMUserInfoManager.fetchSubscribedUsers',
    group: 'UserInfoManager',
    description: '获取当前用户已订阅用户属性的用户列表（4.22 新增），返回 EMUserInfo 数组。',
    paramsTemplate: '{}',
    invoke: (p) async {
      return EMClient.getInstance.userInfoManager.fetchSubscribedUsers();
    },
  ),
  ApiEntry(
    name: 'EMUserInfoManager.getLocalUserInfoByIds',
    group: 'UserInfoManager',
    description: '从本地数据库获取指定用户的用户属性（4.22 新增），返回 {userId: EMUserInfo} 的 Map。',
    paramsTemplate: '''{
  "userIds": ["userId1", "userId2"]
}''',
    invoke: (p) async {
      return EMClient.getInstance.userInfoManager
          .getLocalUserInfoByIds((p['userIds'] as List).cast<String>());
    },
  ),
];
