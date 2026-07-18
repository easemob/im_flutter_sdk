import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';
import 'package:im_flutter_test/bridge/im_websocket_bridge.dart';

class _FakeClient extends Client {
  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    switch (method) {
      case 'login':
        final loginParams = params as Map;
        if (loginParams['pwdOrToken'] == '') {
          return {
            'error': {
              'code': 110,
              'description': 'username or token is null or empty!',
            },
          };
        }
        return {'login': loginParams['userId']};
      case 'loginWithAgoraToken':
        return {'loginWithAgoraToken': (params as Map)['userId']};
      case 'logout':
        return {'logout': true};
      case 'startCallback':
        return {'startCallback': null};
      default:
        throw UnsupportedError('Unexpected client method: $method');
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bridge login refreshes the Dart current user cache', () async {
    final originalClient = Client.instance;
    Client.instance = _FakeClient();
    final bridge = IMWebSocketBridge.instance;
    HttpServer? server;
    WebSocket? peer;

    try {
      await EMClient.getInstance.loginWithPassword('old-user', 'pwd');
      expect(EMClient.getInstance.currentUserId, 'old-user');

      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final peerFuture = server.first.then(WebSocketTransformer.upgrade);
      await bridge.start(url: 'ws://127.0.0.1:${server.port}');
      peer = await peerFuture;
      final responses = StreamIterator<dynamic>(peer);

      peer.add(jsonEncode({
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
      expect(response['result'], 'new-user');
      expect(EMClient.getInstance.currentUserId, 'new-user');
      final outgoing = EMChatManager.buildOutgoingMessage(
        EMSendMessageType.custom,
        {
          'targetId': 'receiver',
          'event': 'bridge-login-regression',
          'params': {'case': 'current-user'},
        },
      );
      expect(outgoing.from, 'new-user');

      peer.add(jsonEncode({
        'manager': 'Client',
        'cmd': 'logout',
        'info': {'unbindToken': false},
        'id': 'logout-1',
        'device': 'deviceA',
      }));
      expect(await responses.moveNext(), isTrue);
      final logoutResponse = jsonDecode(responses.current as String) as Map;
      expect(logoutResponse['result'], isTrue);
      expect(EMClient.getInstance.currentUserId, isNull);

      peer.add(jsonEncode({
        'manager': 'Client',
        'cmd': 'loginWithAgoraToken',
        'info': {
          'userId': 'invalid-user',
          'agora_token': '',
        },
        'id': 'invalid-token-1',
        'device': 'deviceA',
      }));
      expect(await responses.moveNext(), isTrue);
      final invalidTokenResponse =
          jsonDecode(responses.current as String) as Map;
      expect(invalidTokenResponse['result'], {
        'code': 110,
        'description': 'username or token is null or empty!',
      });
      expect(EMClient.getInstance.currentUserId, isNull);
      await responses.cancel();
    } finally {
      await peer?.close();
      await bridge.stop();
      await server?.close(force: true);
      if (EMClient.getInstance.currentUserId != null) {
        await EMClient.getInstance.logout(false);
      }
      Client.instance = originalClient;
    }
  });
}
