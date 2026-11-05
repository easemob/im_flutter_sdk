import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:example/agent/command_service.dart';
import 'package:example/agent/control_server.dart';
import 'package:example/agent/evidence_store.dart';
import 'package:example/log/log_store.dart';

/// ControlServer HTTP tests over real loopback sockets: auth, routes,
/// command lifecycle, events pagination, finish, 413/410/405 (§10 smoke
/// list minus the SDK-dependent parts). The service logger writes to the
/// real LogStore — same channel as production, so the events endpoint sees
/// command/api sources.
void main() {
  late CommandService service;
  late EvidenceStore evidence;
  late ControlServer server;
  late HttpClient http;

  CommandService makeService(AgentExecutor execute) {
    return CommandService(
      executeApi: execute,
      initHandler: (params) async => {'success': true},
      logger: (s, p) => LogStore.instance.log(s, p),
      instanceId: 'test-instance',
    );
  }

  Future<(int, Map<String, Object?>)> send(
    String method,
    String path, {
    Object? body,
    String? token,
    List<int>? rawBody,
    int? contentLength,
  }) async {
    final req = await http.openUrl(
        method, Uri.parse('http://127.0.0.1:${server.port}$path'))
      ..followRedirects = false;
    if (token != null) {
      req.headers.set('Authorization', 'Bearer $token');
    }
    final bytes =
        rawBody ?? (body == null ? null : utf8.encode(jsonEncode(body)));
    if (bytes != null) {
      if (contentLength != null) req.contentLength = contentLength;
      req.add(bytes);
    }
    final res = await req.close();
    final text = await res.transform(utf8.decoder).join();
    final decoded = text.isEmpty
        ? <String, Object?>{}
        : Map<String, Object?>.from(jsonDecode(text) as Map);
    return (res.statusCode, decoded);
  }

  Future<void> until(bool Function() cond) async {
    for (var i = 0; i < 400 && !cond(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  setUp(() async {
    http = HttpClient();
    service = makeService(
        (api, params) async => {'success': true, 'data': 'ok'});
    evidence = EvidenceStore();
    server = await ControlServer.start(service: service, evidence: evidence);
  });

  tearDown(() async {
    await server.stop();
    evidence.dispose();
    http.close(force: true);
  });

  test('all /v1 routes require the bearer token', () async {
    final (status, _) = await send('GET', '/v1/info');
    expect(status, 401);
    final (status2, _) = await send('GET', '/v1/info', token: 'wrong-token');
    expect(status2, 401);
  });

  test('GET /v1/info returns handshake fields', () async {
    final (status, body) = await send('GET', '/v1/info', token: server.token);
    expect(status, 200);
    expect(body['version'], 2);
    expect(body['instanceId'], 'test-instance');
    expect(body['state'], 'accepting');
    expect(body['platform'], isA<String>());
  });

  test('unknown route -> 404; unsupported method -> 405', () async {
    final (status, _) = await send('GET', '/v1/nope', token: server.token);
    expect(status, 404);
    final (status2, _) =
        await send('PUT', '/v1/commands', token: server.token, body: {});
    expect(status2, 405);
  });

  test('command lifecycle: 202 accepted -> poll to done with envelope',
      () async {
    final (status, accepted) = await send('POST', '/v1/commands',
        token: server.token,
        body: {
          'commandId': 't-1',
          'api': 'ChatClient.isConnected',
          'params': {},
          'timeoutMs': 2000,
          // tolerated unknown fields
          'id': 'legacy',
          'whatever': [1, 2],
        });
    expect(status, 202);
    expect(accepted['commandId'], 't-1');
    expect(accepted['status'], 'accepted');

    await until(() => service.lookup('t-1')?.status != 'running');
    final (pollStatus, result) =
        await send('GET', '/v1/commands/t-1', token: server.token);
    expect(pollStatus, 200);
    expect(result['status'], 'done');
    expect(result['success'], true);
    expect(result['data'], 'ok');
    expect(result['evidence'], isA<Map>());
  });

  test('unregistered api -> 422 without side effects', () async {
    final (status, body) = await send('POST', '/v1/commands',
        token: server.token,
        body: {
          'commandId': 't-x',
          'api': 'NotAReal.api',
          'params': {},
        });
    expect(status, 422);
    expect(body['error'], isA<Map>());
  });

  test('unknown command id -> 404', () async {
    final (status, _) =
        await send('GET', '/v1/commands/nope', token: server.token);
    expect(status, 404);
  });

  test('events endpoint exposes command and api sources with cursor',
      () async {
    final before = evidence.lastSeq;
    await send('POST', '/v1/commands',
        token: server.token,
        body: {
          'commandId': 't-ev',
          'api': 'ChatClient.isConnected',
          'params': {},
          'timeoutMs': 2000,
        });
    await until(() => service.lookup('t-ev')?.status != 'running');

    final (status, body) =
        await send('GET', '/v1/events?afterSeq=$before', token: server.token);
    expect(status, 200);
    final events = (body['events'] as List).cast<Map>();
    final sources = events.map((e) => e['source']).toList();
    expect(sources, contains('agent.command'));
    expect(sources, contains('api.ChatClient.isConnected'));
    expect(events.first['seq'], greaterThan(before));
    expect(body['nextAfterSeq'], events.last['seq']);
  });

  test('empty events page keeps the cursor unchanged', () async {
    final (status, body) = await send(
        'GET', '/v1/events?afterSeq=${evidence.lastSeq}&waitMs=0',
        token: server.token);
    expect(status, 200);
    expect(body['events'], isEmpty);
    expect(body['nextAfterSeq'], evidence.lastSeq);
  });

  test('timeout -> uncertain state -> next business command 503', () async {
    final never = Completer<Map<String, dynamic>>();
    service = makeService((api, params) => never.future);
    await server.stop();
    server = await ControlServer.start(service: service, evidence: evidence);

    final (status, _) = await send('POST', '/v1/commands',
        token: server.token,
        body: {
          'commandId': 't-to',
          'api': 'ChatClient.isConnected',
          'params': {},
          'timeoutMs': 40,
        });
    expect(status, 202);
    await until(() => service.state.name == 'uncertain');

    final (status2, _) = await send('POST', '/v1/commands',
        token: server.token,
        body: {
          'commandId': 't-to-2',
          'api': 'ChatClient.isConnected',
          'params': {},
        });
    expect(status2, 503);
  });

  test('finish closes the service; later commands answer 410', () async {
    final (status, _) =
        await send('POST', '/v1/finish', token: server.token, body: {});
    expect(status, 200);

    final (status2, _) = await send('GET', '/v1/info', token: server.token);
    expect(status2, 200);

    final (status3, _) = await send('POST', '/v1/commands',
        token: server.token,
        body: {
          'commandId': 't-after',
          'api': 'ChatClient.isConnected',
          'params': {},
        });
    expect(status3, 410);
  });

  test('request body over 1 MiB -> 413', () async {
    final big = Uint8List(1024 * 1024 + 1);
    final (status, _) = await send('POST', '/v1/commands',
        token: server.token, rawBody: big, contentLength: big.length);
    expect(status, 413);
  });

  test('evidence overflow -> events older than firstAvailableSeq answer 410',
      () async {
    // Dedicated tiny store for this server instance.
    final tiny = EvidenceStore(maxEntries: 1);
    addTearDown(tiny.dispose);
    await server.stop();
    server = await ControlServer.start(service: service, evidence: tiny);

    for (var i = 0; i < 3; i++) {
      LogStore.instance.log('api.ChatManager.sendMessage', {'i': i});
    }
    await until(() => tiny.degraded);

    final (status, body) =
        await send('GET', '/v1/events?afterSeq=0', token: server.token);
    expect(status, 410);
    expect((body['error'] as Map)['code'], 'evidence_gap');
  });
}
