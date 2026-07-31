import 'dart:async';

import 'package:flutter/material.dart';
import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';

import 'bridge/event_router.dart';
import 'bridge/im_websocket_bridge.dart';
import 'platform/interface_client.dart';
import 'platform/test_control.dart';
import 'runner/runner_info.dart';
import 'sdk_config_loader.dart';
import 'websocket_config_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  InterfaceClient.registerWith();

  final config = await SdkConfigLoader.load();
  await Client.instance.callNativeMethod('init', config.sdkOptions);
  final nativeInfo = await TestControl.invoke('getRunnerInfo', const {});
  final runnerInfo = RunnerInfo.fromNative(
    nativeInfo is Map ? nativeInfo : const <String, dynamic>{},
  );
  // ignore: avoid_print
  print('RunnerInfo: ${runnerInfo.toJson()}');

  EventRouter.instance.registerAllHandlers();
  runApp(IMTestApp(runnerInfo: runnerInfo));

  final baseUrl = runnerInfo.webSocketBaseUrl?.isNotEmpty == true
      ? runnerInfo.webSocketBaseUrl!
      : config.webSocketBaseUrl;
  final topic = runnerInfo.topic?.isNotEmpty == true
      ? runnerInfo.topic!
      : config.topicFor(runnerInfo.deviceName);
  unawaited(
    IMWebSocketBridge.instance.start(
      url: baseUrl,
      topic: topic,
      runnerInfo: runnerInfo,
      managed: runnerInfo.managedWebSocket,
    ),
  );
}

class IMTestApp extends StatelessWidget {
  const IMTestApp({required this.runnerInfo, super.key});

  final RunnerInfo runnerInfo;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IM Native Test Runner',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WebSocketConfigPage(runnerInfo: runnerInfo),
    );
  }
}
