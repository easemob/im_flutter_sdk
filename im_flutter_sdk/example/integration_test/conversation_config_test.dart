import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:integration_test/integration_test.dart';

import 'modules/conversation_cases.dart';
import 'modules/conversation_cases.negative.dart';
import 'support/login.dart';
import 'support/rest_fixture.dart';

const _appKey = String.fromEnvironment('E2E_APP_KEY');
const _userId = String.fromEnvironment('E2E_USER_ID');
const _token = String.fromEnvironment('E2E_USER_TOKEN');
const _restApi = String.fromEnvironment('E2E_REST_API');
const _appToken = String.fromEnvironment('E2E_APP_TOKEN');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final required = <String, String>{
    'E2E_APP_KEY': _appKey,
    'E2E_USER_ID': _userId,
    'E2E_USER_TOKEN': _token,
    'E2E_REST_API': _restApi,
    'E2E_APP_TOKEN': _appToken,
  };
  final missing = required.entries
      .where((entry) => entry.value.isEmpty)
      .map((entry) => entry.key);
  if (missing.isNotEmpty) {
    throw StateError('Missing dart-defines: ${missing.join(', ')}');
  }

  final client = ChatClient.getInstance;
  final rest = CiRestFixture(
    restApi: _restApi,
    appKey: _appKey,
    appToken: _appToken,
  );
  var initialized = false;

  setUpAll(() async {
    debugPrint(
        'CI conversation-config suite prepare: initialize with contacts and groups sync');
    await client
        .init(ChatOptions.withAppKey(
          _appKey,
          debugMode: false,
          autoLoadConversations: false,
          enableChatroomConversation: true,
          enableUserInfo: false,
          dataSyncType:
              ChatDataSyncType.contacts | ChatDataSyncType.joinedGroups,
        ))
        .timeout(const Duration(seconds: 30));
    initialized = true;
    await loginForCi(client, _userId, _token);
    debugPrint('CI conversation-config suite prepare: verified');
  });

  tearDownAll(() async {
    try {
      if (initialized) {
        debugPrint('CI conversation-config suite cleanup: logout');
        await client.logout(false).timeout(const Duration(seconds: 30));
        expect(client.currentUserId, isNull);
        expect(
            await client
                .getCurrentUserId()
                .timeout(const Duration(seconds: 10)),
            isNull);
        await waitForCi('SDK disconnected after logout', client.isConnected,
            (connected) => !connected);
        debugPrint('CI conversation-config suite cleanup: verified');
      }
    } finally {
      rest.close();
    }
  });

  registerConversationPaginationCases(client: client, userId: _userId);
  registerConversationPaginationNegativeCases(client: client);
  registerChatroomConversationCases(
      client: client, userId: _userId, rest: rest);
}
