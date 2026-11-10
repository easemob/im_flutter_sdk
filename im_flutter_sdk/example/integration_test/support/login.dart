import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'rest_fixture.dart';

Future<void> loginForCi(ChatClient client, String userId, String token) async {
  final requiredTypes = client.options?.dataSyncType;
  const supportedTypes = ChatDataSyncType.conversations |
      ChatDataSyncType.contacts |
      ChatDataSyncType.joinedGroups;
  if (requiredTypes == null ||
      requiredTypes == ChatDataSyncType.none ||
      (requiredTypes & ~supportedTypes) != 0) {
    throw StateError('CI login requires an explicit supported data sync mask');
  }

  const budget = Duration(seconds: 45);
  final watch = Stopwatch()..start();
  final handlerId = 'ci_login_${DateTime.now().microsecondsSinceEpoch}';
  final finished = Completer<ChatError?>();
  var startedTypes = ChatDataSyncType.none;
  var completedTypes = ChatDataSyncType.none;
  ChatError? syncFailure;

  Duration remaining() {
    final value = budget - watch.elapsed;
    if (value <= Duration.zero) {
      throw TimeoutException(
        'CI login not ready: required=$requiredTypes, started=$startedTypes, '
        'completed=$completedTypes',
        budget,
      );
    }
    return value;
  }

  // Native callbacks can arrive before login's method result. Register first;
  // store errors as values so an early event cannot create an unhandled Future.
  client.addConnectionEventHandler(
    handlerId,
    ConnectionEventHandler(
      onConnected: () => debugPrint('CI login connected'),
      onDisconnected: (code, _) =>
          debugPrint('CI login disconnected: code=$code'),
      onDataSyncStart: (type) {
        startedTypes |= type & requiredTypes;
        debugPrint('CI login data sync start: type=$type');
      },
      onDataSyncFinish: (type, error) {
        debugPrint('CI login data sync finish: type=$type, '
            'errorCode=${error?.code}');
        if ((type & requiredTypes) == 0) return;
        if (error != null) {
          syncFailure ??= error;
          if (!finished.isCompleted) finished.complete(error);
          return;
        }
        completedTypes |= type & requiredTypes;
        if (completedTypes == requiredTypes && !finished.isCompleted) {
          finished.complete(null);
        }
      },
    ),
  );

  try {
    await client.loginWithToken(userId, token).timeout(remaining());
    await client.startCallback().timeout(remaining());
    final error = await finished.future.timeout(
      remaining(),
      onTimeout: () => throw TimeoutException(
        'CI data sync incomplete: required=$requiredTypes, '
        'started=$startedTypes, completed=$completedTypes',
        budget,
      ),
    );
    if (error != null) throw error;
    await waitForCi(
      'CI connected after data sync',
      () async {
        if (syncFailure != null) throw syncFailure!;
        return client.isConnected();
      },
      (connected) => connected,
      timeout: remaining(),
    );
    if (syncFailure != null) throw syncFailure!;
    debugPrint('CI login prepare verified: connected and data sync '
        'completed for mask=$requiredTypes');
  } finally {
    client.removeConnectionEventHandler(handlerId);
  }
}
