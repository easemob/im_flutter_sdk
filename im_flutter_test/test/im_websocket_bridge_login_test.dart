import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';
import 'package:im_flutter_test/bridge/im_websocket_bridge.dart';
import 'package:im_flutter_test/runner/runner_info.dart';

class _FakeClient extends Client {
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    if (method == 'login') {
      return {'login': (params as Map)['userId']};
    }
    throw UnsupportedError('Unexpected client method: $method');
  }
}

void main() {
  test('bridge routes a JSON request through Client.instance', () async {
    final originalClient = Client.instance;
    Client.instance = _FakeClient();
    final bridge = IMWebSocketBridge.instance;
    HttpServer? server;
    WebSocket? peer;

    try {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final peerFuture = server.first.then(WebSocketTransformer.upgrade);
      await bridge.start(
        url: 'ws://127.0.0.1:${server.port}',
        runnerInfo: const RunnerInfo(
          runnerId: 'runner-a',
          deviceName: 'deviceA',
          platform: 'android',
          sdkVersion: '4.10.0',
          appVersion: '1.0.0',
          capabilities: {'Client.login'},
          runId: 'run-test',
          logicalDevice: 'device_a',
          artifactId: 'android-4.10.0-test',
          managedWebSocket: true,
        ),
      );
      peer = await peerFuture;
      final responses = StreamIterator<dynamic>(peer);

      expect(await responses.moveNext(), isTrue);
      final hello = jsonDecode(responses.current as String) as Map;
      expect(hello['type'], 'hello');
      expect(hello['sdkVersion'], '4.10.0');
      expect(hello['runId'], 'run-test');

      peer.add(jsonEncode({
        'type': 'request',
        'protocolVersion': 1,
        'runId': 'run-test',
        'caseId': 'case-test',
        'requestId': 'login-1',
        'targetRunnerId': 'runner-a',
        'manager': 'Client',
        'cmd': 'login',
        'info': {
          'userId': 'new-user',
          'pwdOrToken': 'pwd',
          'isPassword': true,
        },
        'id': 'login-1',
        'device': 'deviceA',
      }));

      expect(await responses.moveNext(), isTrue);
      final response = jsonDecode(responses.current as String) as Map;
      expect(response['manager'], 'Client');
      expect(response['cmd'], 'login');
      expect(response['type'], 'response');
      expect(response['requestId'], 'login-1');
      expect(response['result'], 'new-user');
      expect(response.containsKey('info'), isFalse);
      await responses.cancel();
    } finally {
      await peer?.close();
      await bridge.stop();
      await server?.close(force: true);
      Client.instance = originalClient;
    }
  });
}
