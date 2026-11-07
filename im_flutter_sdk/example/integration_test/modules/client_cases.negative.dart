import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../support/ci_test.dart';
import '../support/login.dart';

void registerLoggedOutClientNegativeCases({required ChatClient client}) {
  Future<void> expectLoggedOut() async {
    expect(client.currentUserId, isNull);
    expect(await client.getCurrentUserId(), isNull);
    expect(await client.isConnected(), isFalse);
  }

  ciTestWidgets('FL-AUTH-004 negative rejects an empty login user', (_) async {
    await expectLoggedOut();
    // Android validates both required parameters as INVALID_PARAM; iOS uses
    // INVALID_USERNAME / INVALID_TOKEN. Assert one exact code per platform.
    await expectCiError(() => client.loginWithToken('', 'unused-token'),
        Platform.isAndroid ? 110 : 101);
    await expectLoggedOut();
  });

  ciTestWidgets('FL-AUTH-005 negative rejects an empty login token', (_) async {
    await expectLoggedOut();
    await expectCiError(() => client.loginWithToken('flutter-ci-peer', ''),
        Platform.isAndroid ? 110 : 104);
    await expectLoggedOut();
  });
}

void registerClientNegativeCases({
  required ChatClient client,
  required String userId,
  required String token,
}) {
  ciTestWidgets(
      'FL-AUTH-006 negative rejects login of the already logged in user',
      (_) async {
    expect(await client.getCurrentUserId(), userId);
    expect(await client.isConnected(), isTrue);
    addTearDown(() async {
      if (await client.getCurrentUserId() != userId ||
          !await client.isConnected()) {
        await client.logout(false);
        await loginForCi(client, userId, token);
      }
    });
    await expectCiError(() => client.loginWithToken(userId, token), 200);
    expect(client.currentUserId, userId);
    expect(await client.getCurrentUserId(), userId);
    expect(await client.isConnected(), isTrue);
  });
}
