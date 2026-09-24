import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../api_entry.dart';

/// PushManager related entries (PushKit is new in 4.25, iOS only).
final pushApis = <ApiEntry>[
  ApiEntry(
    name: 'ChatPushManager.bindDeviceToken',
    group: 'PushManager',
    description: '绑定设备推送 token。iOS 上 notifierName 为 APNs 证书名，非空时优先级高于 '
        'ChatOptions.apnsCertName；Android 上 notifierName 为厂商推送凭据（FCM Sender ID、'
        '华为/荣耀 App ID、小米/魅族 App ID、OPPO App Key、vivo appId#appKey），不能为空，'
        '否则原生返回参数非法错误。',
    paramsTemplate: '''{
  "notifierName": "",
  "deviceToken": ""
}''',
    invoke: (p) async {
      return ChatClient.getInstance.pushManager.bindDeviceToken(
        notifierName: p['notifierName'] as String,
        deviceToken: p['deviceToken'] as String,
      );
    },
  ),
  ApiEntry(
    name: 'ChatPushManager.bindPushKitToken',
    group: 'PushManager',
    description: '绑定苹果 PushKit token，用于 VoIP 推送（4.25 新增，仅 iOS 生效）。'
        'deviceToken 为 PKPushRegistry 回调返回的十六进制字符串；证书名需在初始化时通过 '
        'ChatOptions.pushKitCertName 配置，未配置时原生返回证书名为空的非法参数错误。'
        '未登录时调用会抛错但 token 已缓存，下次登录成功后自动绑定。',
    paramsTemplate: '''{
  "deviceToken": ""
}''',
    invoke: (p) async {
      return ChatClient.getInstance.pushManager.bindPushKitToken(
        deviceToken: p['deviceToken'] as String,
      );
    },
  ),
  ApiEntry(
    name: 'ChatPushManager.unbindPushKitToken',
    group: 'PushManager',
    description: '解绑 bindPushKitToken 绑定的苹果 PushKit token（4.25 新增，仅 iOS 生效）。'
        'ChatClient.logout 且 unbindDeviceToken 为 true 时已经会同时解绑，'
        '因此只在保持登录状态下需要单独解绑时调用。',
    paramsTemplate: '{}',
    invoke: (p) async {
      return ChatClient.getInstance.pushManager.unbindPushKitToken();
    },
  ),
];
