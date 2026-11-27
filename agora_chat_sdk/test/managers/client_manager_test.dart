import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:agora_chat_sdk_interface/agora_chat_sdk_interface.dart';

import '../support/recording_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Client originalClient;
  late RecordingClient recordingClient;

  setUp(() {
    originalClient = Client.instance;
    recordingClient = RecordingClient((manager, method, arguments) async {
      return switch (method) {
        'getCurrentUser' => <String, Object>{'getCurrentUser': 'unit-user'},
        'isConnected' => <String, Object>{'isConnected': true},
        'getToken' => <String, Object>{'getToken': 'token-value'},
        _ => <String, Object>{},
      };
    });
    Client.instance = recordingClient;
  });

  tearDown(() {
    Client.instance = originalClient;
  });

  Future<List<String>> captureLogs(Future<void> Function() action) async {
    final logs = <String>[];
    await runZoned(
      action,
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) => logs.add(line),
      ),
    );
    return logs;
  }

  test('loginWithToken sends a token login request', () async {
    await ChatClient.getInstance.loginWithToken('unit-user', 'token');

    final call = recordingClient.calls.single;
    expect(call.method, 'login');
    expect(call.arguments, <String, Object>{
      'userId': 'unit-user',
      'token': 'token',
    });
    expect(ChatClient.getInstance.currentUserId, 'unit-user');
  });

  test('client state APIs preserve native values', () async {
    expect(await ChatClient.getInstance.getCurrentUserId(), 'unit-user');
    expect(await ChatClient.getInstance.isConnected(), isTrue);
    expect(await ChatClient.getInstance.getAccessToken(), 'token-value');
  });

  test('logout forwards unbind flag and clears current user', () async {
    await ChatClient.getInstance.loginWithToken('unit-user', 'token');
    recordingClient.calls.clear();

    await ChatClient.getInstance.logout(false);

    expect(recordingClient.calls.single.method, 'logout');
    expect(recordingClient.calls.single.arguments, <String, Object>{
      'unbindToken': false,
    });
    expect(ChatClient.getInstance.currentUserId, isNull);
  });

  test('client logs never expose credentials or app keys', () async {
    const token = 'ci-super-secret-token';
    const appKey = 'ci#super-secret-app-key';

    final logs = await captureLogs(() async {
      await ChatClient.getInstance.init(ChatOptions.withAppKey(appKey));
      await ChatClient.getInstance.loginWithToken('unit-user', token);
      await ChatClient.getInstance.changeAppKey(newAppKey: appKey);
    });

    expect(logs, isNotEmpty);
    expect(logs.join('\n'), isNot(contains(token)));
    expect(logs.join('\n'), isNot(contains(appKey)));
  });
}
