import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

Future<void> loginForCi(ChatClient client, String userId, String token) async {
  const budget = Duration(seconds: 45);
  final watch = Stopwatch()..start();
  final handlerId = 'ci_login_${DateTime.now().microsecondsSinceEpoch}';
  final finished = Completer<void>();

  Duration remaining() {
    final value = budget - watch.elapsed;
    if (value <= Duration.zero) {
      throw TimeoutException('CI login not connected', budget);
    }
    return value;
  }

  // Native callbacks can arrive before login's method result. Register first
  // so an early event is not missed.
  client.addConnectionEventHandler(
    handlerId,
    ConnectionEventHandler(
      onConnected: () {
        debugPrint('CI login connected');
        if (!finished.isCompleted) finished.complete();
      },
      onDisconnected: () => debugPrint('CI login disconnected'),
    ),
  );

  try {
    await client.loginWithToken(userId, token).timeout(remaining());
    await client.startCallback().timeout(remaining());
    // onConnected may have fired before we started awaiting; treat an
    // already-connected client as ready instead of waiting for the next event.
    if (!await client.isConnected()) {
      await finished.future.timeout(
        remaining(),
        onTimeout: () =>
            throw TimeoutException('CI login not connected', budget),
      );
    }
    debugPrint('CI login prepare verified: connected');
  } finally {
    client.removeConnectionEventHandler(handlerId);
  }
}
