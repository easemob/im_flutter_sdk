import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../api_entry.dart';

/// ChatClient related entries (account lifecycle; init/login/logout stay page-specific).
final clientApis = <ApiEntry>[
  ApiEntry(
    name: 'ChatClient.createAccount',
    group: 'ChatClient',
    description: '注册新账号（用户名+密码）。账号已存在时报错；注册成功后即可用该账号登录。',
    paramsTemplate: '''{
  "userId": "newUser",
  "password": "123456"
}''',
    invoke: (p) async {
      await ChatClient.getInstance.createAccount(
        p['userId'] as String,
        p['password'] as String,
      );
      return {'registered': p['userId']};
    },
  ),
];
