import 'dart:io';

import 'package:flow_runner/agent_client.dart';
import 'package:flow_runner/interp.dart';
import 'package:flow_runner/parser.dart';
import 'package:flow_runner/report.dart';
import 'package:test/test.dart';

import '../../tool/flow_runner/test/mock_agent.dart';
import '../tools/data/declaration.dart';
import '../tools/data/roles.dart';
import '../tools/runner/context.dart';
import 'package:flow_runner/global_data.dart';

// Run from the worktree root: dart test testing/tests.
final flowFile = File('testing/flows/5.0.0-multi-presence-positive.yaml');
const marker = 'presence-current-run';

class PresenceScenario {
  final alice = MockAgent();
  final bob = MockAgent();
  final calls = <String>[];
  final report = ReportCollector();
  String current = 'original-status';
  bool subscribed = false;

  Map<String, Object?> presence(String publisher, String description) => {
        'publisher': publisher,
        'statusDescription': description,
        'lastTime': 123,
        'expiryTime': 456,
        'statusDetails': {'ios': 1},
      };

  Future<void> run({
    bool deliver = true,
    bool stale = false,
    bool targetSecond = false,
    bool splitFields = false,
    bool failSubscribe = false,
    bool failPublish = false,
  }) async {
    for (final entry in {'alice': alice, 'bob': bob}.entries) {
      final agent = entry.value;
      agent.onOk('ChatClient.init', null);
      agent.on('ChatClient.loginWithToken', (params) async {
        calls.add('${entry.key}:login');
        if (stale && entry.key == 'alice') {
          alice.emit('onPresenceStatusChanged', {
            'list': [presence('bob-user', 'previous-run')],
          });
        }
        return const Envelope(success: true, status: 'ok');
      });
      agent.onOk('ChatClient.isConnected', true);
      agent.onOk('ChatClient.logout', null);
      agent.on('ChatPresenceManager.fetchPresenceStatus', (params) async {
        return Envelope(success: true, status: 'ok', data: [
          presence('bob-user', current),
        ]);
      });
    }
    alice.on('ChatPresenceManager.unsubscribe', (params) async {
      subscribed = false;
      calls.add('unsubscribe');
      return const Envelope(success: true, status: 'ok');
    });
    alice.on('ChatPresenceManager.subscribe', (params) async {
      expect(calls, containsAll(['alice:login', 'bob:login']));
      expect(params['members'], ['bob-user']);
      calls.add('subscribe');
      subscribed = true;
      return Envelope(success: true, status: 'ok', data: [
        presence('bob-user', current),
      ]);
    });
    if (failSubscribe) {
      alice.onFail('ChatPresenceManager.subscribe', 'subscription rejected');
    }
    bob.on('ChatPresenceManager.publishPresence', (params) async {
      final description = params['desc'] as String;
      calls.add('publish:$description');
      if (description == marker) {
        expect(subscribed, isTrue, reason: 'publish must follow subscribe');
        if (failPublish) {
          return const Envelope(
              success: false,
              status: 'error',
              failureKind: 'sdk',
              error: {'code': 500});
        }
      }
      current = description;
      if (deliver && description == marker) {
        // Emit before the publisher's command response: legitimate fast callback.
        alice.emit('onPresenceStatusChanged', {
          'list': [
            if (targetSecond || splitFields) presence('other-user', marker),
            presence('bob-user', splitFields ? 'wrong-status' : marker),
          ],
        });
      }
      return const Envelope(success: true, status: 'ok');
    });
    final spec = parseFlow(
      flowFile
          .readAsStringSync()
          .replaceFirst('stepTimeoutMs: 20000', 'stepTimeoutMs: 100'),
      sourcePath: flowFile.path,
    );
    final initial = <String, Object?>{
      'device': {
        'alice': {'platform': 'ios'},
        'bob': {'platform': 'ios'}
      },
      'account': {
        for (final role in ['alice', 'bob'])
          role: {'userId': '$role-user', 'userToken': 'fake'},
      },
      'biz': {
        'config': {'initConfig': <String, Object?>{}},
        'input': {'presenceDescription': marker},
        'result': <String, Object?>{},
        'event': <String, Object?>{},
      },
    };
    validateGlobalContract(spec, initial);
    final global = GlobalData(initial, outputRoots: outputRoots);
    await Interpreter(
            spec: spec,
            global: global,
            agents: {'alice': alice, 'bob': bob},
            report: report)
        .run();
  }
}

void main() {
  test('real flow accepts a fast current callback and restores state',
      () async {
    final scenario = PresenceScenario();
    await scenario.run();
    expect(scenario.report.summary(),
        {'passed': 16, 'failed': 0, 'timeout': 0, 'skipped': 0});
    expect(scenario.current, 'original-status');
    expect(scenario.subscribed, isFalse);
  });
  test('old event during login cannot satisfy missing current notification',
      () async {
    final scenario = PresenceScenario();
    await scenario.run(stale: true, deliver: false);
    expect(scenario.report.summary()['timeout'], 1);
    expect(scenario.current, 'original-status');
    expect(scenario.alice.calls.last, 'ChatClient.logout');
  });
  test('no notification fails even when a query sees the published state',
      () async {
    final scenario = PresenceScenario();
    await scenario.run(deliver: false);
    expect(scenario.report.summary()['timeout'], 1);
    expect(
        scenario.report.records
            .singleWhere((r) => r.name == 'verify_presence')
            .status,
        'passed');
  });
  test('a matching publisher can be second in a batched callback', () async {
    final scenario = PresenceScenario();
    await scenario.run(stale: true, targetSecond: true);
    expect(scenario.report.summary()['failed'], 0);
    expect(scenario.report.summary()['timeout'], 0);
  });
  test('publisher and description must belong to the same list element',
      () async {
    final scenario = PresenceScenario();
    await scenario.run(splitFields: true);
    expect(scenario.report.summary()['timeout'], 1);
  });
  test('failed subscription prevents publishing', () async {
    final scenario = PresenceScenario();
    await scenario.run(failSubscribe: true);
    expect(scenario.report.summary()['failed'], 1);
    expect(scenario.bob.calls,
        isNot(contains('ChatPresenceManager.publishPresence')));
  });
  test('publish failure is retained and cleanup still runs', () async {
    final scenario = PresenceScenario();
    await scenario.run(failPublish: true);
    expect(scenario.report.summary()['failed'], greaterThanOrEqualTo(1));
    expect(scenario.report.summary()['timeout'], 1);
    expect(scenario.current, 'original-status');
    expect(scenario.subscribed, isFalse);
  });
  test('data preparation creates fresh shared inputs before device setup', () {
    final environment = <String, dynamic>{
      'appKey': 'test',
      'accounts': [
        {'id': 'a', 'token': 'ta'},
        {'id': 'b', 'token': 'tb'}
      ],
    };
    final declaration = loadDataDeclaration(flow: flowFile);
    final first = globalDataFromRoles(
        buildRoleData(environment, ['alice', 'bob'], declaration));
    final second = globalDataFromRoles(
        buildRoleData(environment, ['alice', 'bob'], declaration));
    expect((first['account'] as Map)['alice']['userId'], 'a');
    expect((first['biz'] as Map)['input']['presenceDescription'],
        isNot((second['biz'] as Map)['input']['presenceDescription']));
    expect((first['biz'] as Map)['config']['initConfig'], {'appKey': 'test'});
    final same = {
      ...declaration,
      'accounts': {'alice': 0, 'bob': 0}
    };
    expect(() => buildRoleData(environment, ['alice', 'bob'], same),
        throwsFormatException);
    same['distinctAccounts'] = false;
    expect(buildRoleData(environment, ['alice', 'bob'], same), hasLength(2));
  });
}
