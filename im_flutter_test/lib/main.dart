import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'sdk_config_loader.dart';
import 'websocket_config_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 从 assets/config.yaml（软链 native-auto-test/config.yaml）读取并初始化 SDK。
  final EMOptions options = await SdkConfigLoader.loadOptions();
  await EMClient.getInstance.init(options);

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
