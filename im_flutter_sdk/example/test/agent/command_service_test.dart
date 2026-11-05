import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:example/agent/command_service.dart';

/// CommandService unit tests: validation, dedup, single in-flight, timeout
/// -> uncertain, late completion, init special case, expect compat channel,
/// unknown-field tolerance. Executors are injected (agent-service §10).
void main() {
  late CommandService service;
  late List<(String, Object?)> logged;

  CommandService make({
    AgentExecutor execute = _okExecutor,
    AgentInitHandler init = _okInit,
  }) {
    logged = [];
    return CommandService(
      executeApi: execute,
      initHandler: init,
      logger: (s, p) => logged.add((s, p)),
      instanceId: 'test-instance',
    );
  }

  Future<void> until(bool Function() cond) async {
    for (var i = 0; i < 400 && !cond(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  setUp(() {
    service = make();
  });

  group('validation', () {
    test('missing commandId -> 400', () async {
      await expectLater(
        service.submit({'api': 'ChatClient.isConnected', 'params': {}}),
        throwsA(isA<AgentCommandError>()
            .having((e) => e.statusCode, 'status', 400)),
      );
    });

    test('missing api -> 400', () async {
      await expectLater(
        service.submit({'commandId': 'c1'}),
        throwsA(isA<AgentCommandError>()
            .having((e) => e.statusCode, 'status', 400)),
      );
    });

    test('unregistered api -> 422', () async {
      await expectLater(
        service.submit({
          'commandId': 'c1',
          'api': 'NotAReal.api',
          'params': {},
        }),
        throwsA(isA<AgentCommandError>()
            .having((e) => e.statusCode, 'status', 422)),
      );
    });

    test('ChatClient.init bypasses the registry check', () async {
      var initCalled = false;
      service = make(init: (params) async {
        initCalled = true;
        return {'success': true};
      });
      await service.submit({
        'commandId': 'c-init',
        'api': 'ChatClient.init',
        'params': {'config': {}, 'overrides': {}},
        // Unknown fields must be tolerated (protocol v2 forward compat).
        'id': 'legacy-step-id',
        'futureField': 42,
      });
      await until(() => initCalled);
      expect(initCalled, isTrue);
    });
  });

  group('execution', () {
    test('terminal result carries the actual envelope and evidence range',
        () async {
      final record = await service.submit({
        'commandId': 'c1',
        'api': 'ChatClient.isConnected',
        'params': {},
        'timeoutMs': 1000,
      });
      await until(() => record.status != 'running');
      expect(record.status, 'done');
      final result = record.result!;
      expect(result['success'], true);
      expect(result['status'], 'done');
      expect(result['data'], 'ok');
      expect(result['evidence'], isA<Map>());
      // api.* channel mirrors AutoMode's log source naming.
      expect(
        logged.any((e) => e.$1 == 'api.ChatClient.isConnected'),
        isTrue,
      );
    });

    test('error envelope passes through as status done (judgment is host-side)',
        () async {
      service = make(execute: (api, params) async => {
            'success': false,
            'failureKind': 'sdk',
            'error': {'code': 110, 'message': 'x'},
          });
      final record = await service.submit({
        'commandId': 'c-err',
        'api': 'ChatClient.isConnected',
        'params': {},
      });
      await until(() => record.status != 'running');
      expect(record.status, 'done');
      expect(record.result!['success'], false);
      expect((record.result!['error'] as Map)['code'], 110);
    });
  });

  group('dedup / in-flight', () {
    test('same id + same content returns the existing record', () async {
      final gate = Completer<void>();
      service = make(execute: (api, params) => gate.future
          .then((_) => {'success': true, 'data': 'ok'}));
      final cmd = {
        'commandId': 'c1',
        'api': 'ChatClient.isConnected',
        'params': {},
      };
      final first = await service.submit(cmd);
      final again = await service.submit(Map<String, dynamic>.from(cmd));
      expect(identical(first, again), isTrue);

      gate.complete();
      await until(() => first.status != 'running');
      expect(first.status, 'done');
    });

    test('same id + different content -> 409', () async {
      final gate = Completer<void>();
      service = make(execute: (api, params) => gate.future
          .then((_) => {'success': true}));
      await service.submit({
        'commandId': 'c1',
        'api': 'ChatClient.isConnected',
        'params': {},
      });
      await expectLater(
        service.submit({
          'commandId': 'c1',
          'api': 'ChatClient.isConnected',
          'params': {'extra': 1},
        }),
        throwsA(isA<AgentCommandError>()
            .having((e) => e.statusCode, 'status', 409)),
      );
      gate.complete();
    });

    test('in-flight rejects a different command -> 409', () async {
      final gate = Completer<void>();
      service = make(execute: (api, params) => gate.future
          .then((_) => {'success': true}));
      await service.submit({
        'commandId': 'c1',
        'api': 'ChatClient.isConnected',
        'params': {},
      });
      await expectLater(
        service.submit({
          'commandId': 'c2',
          'api': 'ChatClient.isConnected',
          'params': {},
        }),
        throwsA(isA<AgentCommandError>()
            .having((e) => e.statusCode, 'status', 409)),
      );
      gate.complete();
    });
  });

  group('timeout / uncertain', () {
    test('timeout -> status timeout, service uncertain, next command 503',
        () async {
      final never = Completer<Map<String, dynamic>>();
      service = make(execute: (api, params) => never.future);
      final record = await service.submit({
        'commandId': 'c1',
        'api': 'ChatClient.isConnected',
        'params': {},
        'timeoutMs': 30,
      });
      await until(() => record.status != 'running');
      expect(record.status, 'timeout');
      expect(record.result!['failureKind'], 'timeout');
      expect(service.state, AgentServiceState.uncertain);

      await expectLater(
        service.submit({
          'commandId': 'c2',
          'api': 'ChatClient.isConnected',
          'params': {},
        }),
        throwsA(isA<AgentCommandError>()
            .having((e) => e.statusCode, 'status', 503)),
      );
    });

    test('late completion becomes an ordinary event, terminal state kept',
        () async {
      final gate = Completer<Map<String, dynamic>>();
      service = make(execute: (api, params) => gate.future);
      final record = await service.submit({
        'commandId': 'c1',
        'api': 'ChatClient.isConnected',
        'params': {},
        'timeoutMs': 30,
      });
      await until(() => record.status != 'running');
      expect(record.status, 'timeout');

      gate.complete({'success': true, 'data': 'late-value'});
      await until(() => logged.any((e) =>
          e.$1 == 'api.ChatClient.isConnected' &&
          (e.$2 as Map)['late'] == true));
      // First terminal state is never overwritten.
      expect(record.status, 'timeout');
      expect(record.result!['data'], isNull);
    });
  });

  group('expect compat channel', () {
    test('carried expect is evaluated and returned as expectMatched',
        () async {
      final record = await service.submit({
        'commandId': 'c1',
        'api': 'ChatClient.isConnected',
        'params': {},
        'expect': {'success': true},
      });
      await until(() => record.status != 'running');
      expect(record.result!['expectMatched'], true);
    });

    test('errorCode expectation matches a failed sdk call', () async {
      service = make(execute: (api, params) async => {
            'success': false,
            'failureKind': 'sdk',
            'error': {'code': 110, 'message': 'x'},
          });
      final record = await service.submit({
        'commandId': 'c1',
        'api': 'ChatClient.isConnected',
        'params': {},
        'expect': {'errorCode': 110},
      });
      await until(() => record.status != 'running');
      expect(record.result!['expectMatched'], true);
    });

    test('unknown expect fields do not crash the agent', () async {
      final record = await service.submit({
        'commandId': 'c1',
        'api': 'ChatClient.isConnected',
        'params': {},
        'expect': {'totallyUnknownField': 1},
      });
      await until(() => record.status != 'running');
      expect(record.result!['expectMatched'], false);
    });
  });

  group('finish', () {
    test('finish closes the service; later commands answer 410', () async {
      service.finish();
      expect(service.state, AgentServiceState.closed);
      expect(service.info()['state'], 'closed');
      await expectLater(
        service.submit({
          'commandId': 'c1',
          'api': 'ChatClient.isConnected',
          'params': {},
        }),
        throwsA(isA<AgentCommandError>()
            .having((e) => e.statusCode, 'status', 410)),
      );
    });

    test('finish with an in-flight command -> 409', () async {
      final gate = Completer<void>();
      service = make(execute: (api, params) => gate.future
          .then((_) => {'success': true}));
      await service.submit({
        'commandId': 'c1',
        'api': 'ChatClient.isConnected',
        'params': {},
      });
      expect(
        () => service.finish(),
        throwsA(isA<AgentCommandError>()
            .having((e) => e.statusCode, 'status', 409)),
      );
      gate.complete();
    });
  });
}

Future<Map<String, dynamic>> _okExecutor(
    String api, Map<String, dynamic> params) async {
  return {'success': true, 'data': 'ok'};
}

Future<Map<String, dynamic>> _okInit(Map<String, dynamic> params) async {
  return {'success': true};
}
