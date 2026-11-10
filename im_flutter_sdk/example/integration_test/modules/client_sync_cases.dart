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
  // Test: After cold initialization with only conversation sync explicitly
  // enabled, register connection/sync listeners and log in with a valid token.
  // Expected: Within 75 seconds, sync start/finish events report only the
  // conversation mask, finish without errors, and the client is connected as
  // the requested user. Cleanup logs out and removes the listener.
  // This checks sync events, not server-history contents. Other baseline cases
  // log in independently through their own group setup.
  ciTestWidgets('FL-AUTH-007 explicit conversation sync completes successfully',
      (_) async {
    final started = <int>[];
    final finished = <int>[];
    final syncErrors = <ChatError>[];
    final syncDone = Completer<void>();
    final connected = Completer<void>();
    final watch = Stopwatch()..start();
    const budget = Duration(seconds: 75);
    Duration remaining() {
      final value = budget - watch.elapsed;
      if (value <= Duration.zero) {
        throw TimeoutException(
            'Conversation sync timed out: starts=$started '
            'finishes=$finished errors=${syncErrors.map((error) => error.code).toList()}',
            budget);
      }
      return value;
    }

    final options = client.options!;
    expect(options.dataSyncType, ChatDataSyncType.conversations);
    expect(options.toJson()['dataSyncType'], ChatDataSyncType.conversations);
    expect(await client.getCurrentUserId().timeout(remaining()), isNull,
        reason: 'Explicit conversation-sync verification requires a cold app');

    final handler =
        'ci_conversation_sync_${DateTime.now().microsecondsSinceEpoch}';
    client.addConnectionEventHandler(
        handler,
        ConnectionEventHandler(
          onConnected: () {
            if (!connected.isCompleted) connected.complete();
          },
          onDataSyncStart: (type) {
            started.add(type);
            debugPrint('CI FL-AUTH-007 sync start: type=$type');
          },
          onDataSyncFinish: (type, error) {
            finished.add(type);
            if (error != null) syncErrors.add(error);
            debugPrint(
                'CI FL-AUTH-007 sync finish: type=$type error=${error?.code}');
            // Complete with a value so an early failure cannot become an unhandled
            // future error before the login method itself has completed.
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
          'No conversation sync finish: starts=$started '
          'finishes=$finished',
          budget);
    });
    if (!await client.isConnected().timeout(remaining())) {
      await connected.future.timeout(remaining());
    }
    expect(started, isNotEmpty);
    expect(finished, isNotEmpty);
    expect(started, everyElement(ChatDataSyncType.conversations));
    expect(finished, everyElement(ChatDataSyncType.conversations));
    expect(syncErrors, isEmpty,
        reason:
            'Explicit conversation synchronization must finish without error');
    expect(await client.isConnected().timeout(remaining()), isTrue);
    expect(await client.getCurrentUserId().timeout(remaining()), userId);
    debugPrint(
        'CI FL-AUTH-007 verify passed: explicit conversation sync mask=1; '
        'server history contents are not asserted');
  });
}
