import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../support/ci_test.dart';

void registerConversationSyncCase({
  required ChatClient client,
  required String userId,
  required String token,
}) {
  // Test: After cold initialization, register connection/sync listeners and
  // log in with a valid token.
  // Expected: Within 75 seconds, the offline message sync start/finish events
  // both fire, and the client is connected as the requested user. Cleanup logs
  // out and removes the listener.
  // This checks sync events, not server-history contents. Other baseline cases
  // log in independently through their own group setup.
  ciTestWidgets('FL-AUTH-007 offline message sync completes successfully',
      (_) async {
    final started = <String>[];
    final finished = <String>[];
    final syncDone = Completer<void>();
    final connected = Completer<void>();
    final watch = Stopwatch()..start();
    const budget = Duration(seconds: 75);
    Duration remaining() {
      final value = budget - watch.elapsed;
      if (value <= Duration.zero) {
        throw TimeoutException(
            'Offline message sync timed out: starts=$started '
            'finishes=$finished',
            budget);
      }
      return value;
    }

    expect(await client.getCurrentUserId().timeout(remaining()), isNull,
        reason: 'Offline message sync verification requires a cold app');

    final handler =
        'ci_conversation_sync_${DateTime.now().microsecondsSinceEpoch}';
    client.addConnectionEventHandler(
        handler,
        ConnectionEventHandler(
          onConnected: () {
            if (!connected.isCompleted) connected.complete();
          },
          onOfflineMessageSyncStart: () {
            started.add('start');
            debugPrint('CI FL-AUTH-007 offline sync start');
          },
          onOfflineMessageSyncFinish: () {
            finished.add('finish');
            debugPrint('CI FL-AUTH-007 offline sync finish');
            if (!syncDone.isCompleted) syncDone.complete();
          },
        ));
    addTearDown(() => client.removeConnectionEventHandler(handler));
    addTearDown(() async {
      await client.logout(false).timeout(const Duration(seconds: 30));
      expect(client.currentUserId, isNull);
      expect(
          await client.getCurrentUserId().timeout(const Duration(seconds: 10)),
          isNull);
      expect(await client.isConnected().timeout(const Duration(seconds: 10)),
          isFalse);
      debugPrint('CI FL-AUTH-007 cleanup verified: logged out');
    });

    await client.startCallback().timeout(remaining());
    await client.loginWithToken(userId, token).timeout(remaining());
    await syncDone.future.timeout(remaining(), onTimeout: () {
      throw TimeoutException(
          'No offline message sync finish: starts=$started '
          'finishes=$finished',
          budget);
    });
    if (!await client.isConnected().timeout(remaining())) {
      await connected.future.timeout(remaining());
    }
    expect(started, isNotEmpty);
    expect(finished, isNotEmpty);
    expect(await client.isConnected().timeout(remaining()), isTrue);
    expect(await client.getCurrentUserId().timeout(remaining()), userId);
    debugPrint(
        'CI FL-AUTH-007 verify passed: offline message sync start/finish fired; '
        'server history contents are not asserted');
  });
}
