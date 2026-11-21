import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:integration_test/integration_test.dart';

import 'modules/client_cases.dart';
import 'modules/conversation_cases.dart';
import 'modules/event_callback_cases.dart';
import 'modules/event_registration_cases.dart';
import 'modules/message_cases.dart';
import 'modules/presence_cases.dart';
import 'modules/push_cases.dart';
import 'support/env.dart';
import 'support/login.dart';
import 'support/rest_fixture.dart';
import 'support/session.dart';

/// Stable entry: token login with the base option set.
///
/// Covers authentication, the client facade, the local conversation database,
/// the message server path, presence, push settings, and the manager event
/// handler registry. Group, contact, room, and user-info entry points are
/// separate files with their own ChatOptions.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // The destructive message cases provision disposable peer accounts through
  // the REST fixture, so the base entry also needs the REST dart-defines.
  requireCiEnvironment(requirePeer: true, requireRest: true);

  final client = ChatClient.getInstance;
  final rest = CiRestFixture(
    restApi: ciRestApi,
    appKey: ciAppKey,
    appToken: ciAppToken,
  );

  setUpAll(() async {
    await initCiClient();
    await loginForCi(client);
    await clearPinnedConversationsForCi(client);
  });

  tearDownAll(() async {
    await logoutForCi(client);
  });

  group('logged in base', () {
    registerClientCases(client);
    registerConversationCases(client);
    registerMessageCases(client);
    registerPresenceCases(client);
    registerPushCases(client);
    registerManagerEventCases(client);
    registerEventCallbackCases(client, rest);
  });
}
