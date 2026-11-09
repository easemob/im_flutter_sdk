import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';
import 'package:testing_v2/src/http_client.dart';

void main() {
  test(
      'releasing the owned transport aborts an indefinitely stalled HTTP request',
      () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final arrived = Completer<void>();
    server.listen((request) {
      expect(request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer private-token');
      arrived.complete();
      // Deliberately never send response headers.
    });
    final client = OwnedAgentClient(
        endpoint: Uri.parse('http://127.0.0.1:${server.port}'),
        actor: 'alice',
        token: 'private-token');
    try {
      final pending = client
          .info()
          .then<Object?>((value) => value, onError: (Object error) => error);
      await arrived.future.timeout(const Duration(seconds: 2));
      client.close();
      final outcome = await pending.timeout(const Duration(seconds: 2));
      expect(outcome, isA<Exception>());
    } finally {
      client.close();
      await server.close(force: true);
    }
  });
}
