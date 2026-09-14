import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'env_config.dart';
import 'websocket_config_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 环境配置来自外部注入文件（run.sh adb push）；缺失或 appkey 为空时跳过 SDK 初始化，
  // 仅启动桥接 UI，保证首次启动仍能创建 App 外部目录并等待配置注入。
  final result = await EnvConfigLoader.loadOptions();
  if (result.options != null) {
    await EMClient.getInstance.init(result.options!);
    debugPrint('[im_flutter_test] SDK 已初始化（配置来源: ${result.source}）');
  } else {
    debugPrint('[im_flutter_test] 跳过 SDK 初始化: ${result.reason}');
  }

  runApp(const IMTestApp());
}

class IMTestApp extends StatelessWidget {
  const IMTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IM Flutter Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WebSocketConfigPage(),
    );
  }
}
