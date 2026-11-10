import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:integration_test/integration_test.dart';

import 'modules/user_info_cases.dart';
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
  var initialized = false;

  setUpAll(() async {
    await client
        .init(ChatOptions.withAppKey(
          _appKey,
          debugMode: false,
          enableUserInfo: true,
          autoLoadConversations: true,
          enableChatroomConversation: false,
          dataSyncType: ChatDataSyncType.conversations,
        ))
        .timeout(const Duration(seconds: 30));
    initialized = true;
    await loginForCi(client, _userId, _token);
  });

  tearDownAll(() async {
    if (initialized) {
      await client.logout(false).timeout(const Duration(seconds: 30));
      expect(await client.getCurrentUserId(), isNull);
      await waitForCi('User info suite disconnected after logout',
          client.isConnected, (connected) => !connected);
    }
  });

  registerUserInfoCases(
    client: client,
    restApi: _restApi,
    appKey: _appKey,
    appToken: _appToken,
  );
}
