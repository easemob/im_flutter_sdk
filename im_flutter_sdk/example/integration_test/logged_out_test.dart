import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'package:integration_test/integration_test.dart';

import 'modules/client_cases.dart';
import 'modules/client_cases.negative.dart';
import 'modules/presence_cases.negative.dart';
import 'modules/contact_cases.negative.dart';
import 'modules/group_cases.negative.dart';
import 'modules/message_cases.negative.dart';

const _publicAppKey = String.fromEnvironment(
  'E2E_APP_KEY',
  defaultValue: 'easemob#easeim',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final client = ChatClient.getInstance;

  setUpAll(() async {
    await client
        .init(ChatOptions.withAppKey(
          _publicAppKey,
          debugMode: false,
          dataSyncType: ChatDataSyncType.conversations,
          autoLoadConversations: true,
          enableChatroomConversation: false,
          enableUserInfo: false,
        ))
        .timeout(const Duration(seconds: 30));
  });

  registerLoggedOutClientCases(client: client);
  registerLoggedOutPresenceCases(client: client);
  registerLoggedOutClientNegativeCases(client: client);
  registerLoggedOutContactNegativeCases(client: client);
  registerLoggedOutGroupNegativeCases(client: client);
  registerLoggedOutMessageNegativeCases(client: client);
}
