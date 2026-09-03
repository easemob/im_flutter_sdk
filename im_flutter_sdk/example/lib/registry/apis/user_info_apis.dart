import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../api_entry.dart';

/// UserInfoManager related entries (new in 4.22, requires ChatOptions.enableUserInfo=true).
final userInfoApis = <ApiEntry>[
  ApiEntry(
    name: 'ChatUserInfoManager.subscribeUsersInfo',
    group: 'UserInfoManager',
    description: '订阅指定用户的用户属性（4.22 新增，需 enableUserInfo=true）。'
        '订阅成功后被订阅用户属性更新时收到 ChatUserInfoEventHandler.onUserInfoUpdate 回调。',
    paramsTemplate: '''{
  "userIds": ["userId1", "userId2"]
}''',
    invoke: (p) async {
      return ChatClient.getInstance.userInfoManager
          .subscribeUsersInfo((p['userIds'] as List).cast<String>());
    },
  ),
  ApiEntry(
    name: 'ChatUserInfoManager.unsubscribeUsersInfo',
    group: 'UserInfoManager',
    description: '取消订阅指定用户的用户属性（4.22 新增，需 enableUserInfo=true）。',
    paramsTemplate: '''{
  "userIds": ["userId1", "userId2"]
}''',
    invoke: (p) async {
      return ChatClient.getInstance.userInfoManager
          .unsubscribeUsersInfo((p['userIds'] as List).cast<String>());
    },
  ),
  ApiEntry(
    name: 'ChatUserInfoManager.fetchSubscribedUsers',
    group: 'UserInfoManager',
    description: '获取当前用户已订阅用户属性的用户列表（4.22 新增），返回 ChatUserInfo 数组。',
    paramsTemplate: '{}',
    invoke: (p) async {
      return ChatClient.getInstance.userInfoManager.fetchSubscribedUsers();
    },
  ),
  ApiEntry(
    name: 'ChatUserInfoManager.getLocalUserInfoByIds',
    group: 'UserInfoManager',
    description: '从本地数据库获取指定用户的用户属性（4.22 新增），返回 {userId: ChatUserInfo} 的 Map。',
    paramsTemplate: '''{
  "userIds": ["userId1", "userId2"]
}''',
    invoke: (p) async {
      return ChatClient.getInstance.userInfoManager
          .getLocalUserInfoByIds((p['userIds'] as List).cast<String>());
    },
  ),
  ApiEntry(
    name: 'ChatUserInfoManager.updateUserInfo',
    group: 'UserInfoManager',
    description: '更新当前用户的用户属性（需 enableUserInfo=true），所有字段可选，只传要更新的字段。'
        'gender：0 默认/1 男/2 女。返回更新后的 ChatUserInfo。',
    paramsTemplate: '''{
  "gender": 1
}''',
    invoke: (p) async {
      return ChatClient.getInstance.userInfoManager.updateUserInfo(
        nickname: p['nickname'] as String?,
        avatarUrl: p['avatarUrl'] as String?,
        mail: p['mail'] as String?,
        phone: p['phone'] as String?,
        gender: p['gender'] as int?,
        sign: p['sign'] as String?,
        birth: p['birth'] as String?,
        ext: p['ext'] as String?,
      );
    },
  ),
  ApiEntry(
    name: 'ChatUserInfoManager.fetchUserInfoById',
    group: 'UserInfoManager',
    description: '从服务器获取指定用户的用户属性，返回 {userId: ChatUserInfo} 的 Map。'
        'expireTime：缓存有效期（秒），0 表示不走本地缓存、强制拉取服务器数据。',
    paramsTemplate: '''{
  "userIds": ["userId1"],
  "expireTime": 0
}''',
    invoke: (p) async {
      return ChatClient.getInstance.userInfoManager.fetchUserInfoById(
        (p['userIds'] as List).cast<String>(),
        expireTime: (p['expireTime'] as int?) ?? 0,
      );
    },
  ),
];
