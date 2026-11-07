import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:integration_test/integration_test.dart';

import 'modules/client_cases.dart';
import 'modules/contact_cases.dart';
import 'modules/conversation_cases.dart';
import 'modules/group_cases.dart';
import 'modules/message_cases.dart';
import 'support/login.dart';
import 'support/rest_fixture.dart';

const _appKey = String.fromEnvironment('E2E_APP_KEY');
const _userId = String.fromEnvironment('E2E_USER_ID');
const _token = String.fromEnvironment('E2E_USER_TOKEN');
const _peerId = String.fromEnvironment('E2E_PEER_ID');
const _restApi = String.fromEnvironment('E2E_REST_API');
const _appToken = String.fromEnvironment('E2E_APP_TOKEN');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final required = <String, String>{
    'E2E_APP_KEY': _appKey,
    'E2E_USER_ID': _userId,
    'E2E_USER_TOKEN': _token,
    'E2E_PEER_ID': _peerId,
    'E2E_REST_API': _restApi,
    'E2E_APP_TOKEN': _appToken,
  };
  final missing = required.entries
      .where((entry) => entry.value.isEmpty)
      .map((entry) => entry.key);
  if (missing.isNotEmpty) {
    throw StateError('Missing dart-defines: ${missing.join(', ')}');
  }
  if (_peerId == _userId) {
    throw StateError('E2E_PEER_ID must differ from E2E_USER_ID');
  }

  final client = ChatClient.getInstance;
  final rest = CiRestFixture(
    restApi: _restApi,
    appKey: _appKey,
    appToken: _appToken,
  );
  var initialized = false;

  setUpAll(() async {
    debugPrint('CI suite prepare: initialize with contacts and groups sync');
    await client
        .init(ChatOptions.withAppKey(
          _appKey,
          debugMode: false,
          dataSyncType:
              ChatDataSyncType.contacts | ChatDataSyncType.joinedGroups,
        ))
        .timeout(const Duration(seconds: 30));
    initialized = true;
    await loginForCi(client, _userId, _token);
    debugPrint('CI suite prepare: verified');
  });

  tearDownAll(() async {
    try {
      if (initialized) {
        debugPrint('CI suite cleanup: logout');
        await client.logout(false).timeout(const Duration(seconds: 30));
        expect(client.currentUserId, isNull);
        expect(
            await client
                .getCurrentUserId()
                .timeout(const Duration(seconds: 10)),
            isNull);
        await waitForCi('SDK disconnected after logout', client.isConnected,
            (connected) => !connected);
        debugPrint('CI suite cleanup: verified');
      }
    } finally {
      rest.close();
    }
  });

  registerClientCases(client: client, userId: _userId, token: _token);
  registerContactCases(
      client: client,
      userId: _userId,
      token: _token,
      peerId: _peerId,
      rest: rest);
  registerGroupCases(
      client: client, userId: _userId, peerId: _peerId, rest: rest);
  registerConversationCases(client: client, userId: _userId);
  registerMessageCases(
      client: client, userId: _userId, peerId: _peerId, rest: rest);
}
