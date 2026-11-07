import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flow_runner/agent_client.dart';
import 'package:flow_runner/parser.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:testing_v2/src/contracts.dart';
import 'package:testing_v2/src/core.dart';
import 'package:testing_v2/src/data.dart';
import 'package:testing_v2/src/execution.dart';

class FakeAgent implements AgentClient {
  final calls = <String>[];
  final events = <AgentEvent>[];
  final params = <JsonObject>[];
  Future<Envelope> Function(String, JsonObject)? command;
  Future<List<AgentEvent>> Function(int, int)? polling;
  Future<void> Function()? finishing;
  var finishes = 0;
  var released = false;

  @override
  Future<JsonObject> info() async => {
        'version': 2,
        'platform': 'ios',
        'instanceId': 'instance',
        'state': 'accepting'
      };
  @override
  Future<Envelope> runCommand(
      String api, JsonObject input, int timeoutMs) async {
    calls.add(api);
    params.add(input);
    return command == null
        ? const Envelope(success: true, status: 'ok', data: {'value': 'ok'})
        : await command!(api, input);
  }

  @override
  Future<List<AgentEvent>> pollEvents(int afterSeq,
      {int limit = 200, int waitMs = 1000}) async {
    if (polling != null) return polling!(afterSeq, waitMs);
    return events.where((event) => event.seq > afterSeq).take(limit).toList();
  }

  @override
  Future<void> finish() async {
    finishes++;
    await finishing?.call();
  }
}

void main() {
  late Directory root;
  late DataService data;
  late CaseLoader loader;
  late OperationContext context;
  late Map<String, FakeAgent> agents;
  late FileRef artifact;
  var sequence = 0;
  var claims = 0;
  var admissions = 0;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('testing-v2-execution-');
    data = DataService();
    loader = CaseLoader(data);
    context = OperationContext(
        runId: 'run-1',
        operationId: 'execute-1',
        tmpDirectory: root,
        redactor: SecretRedactor());
    agents = {'alice': FakeAgent(), 'bob': FakeAgent()};
    final file = File(p.join(root.path, 'artifact.app'));
    await file.writeAsString('build');
    artifact = await fileRef(file.path);
    claims = 0;
    admissions = 0;
  });
  tearDown(() async {
    await root.delete(recursive: true);
  });

  test(
      'published presence case freezes and declares publication plus callback evidence',
      () async {
    final loaded = await loader.freeze(
        p.absolute('data/5.0.0-multi-presence-positive.yaml'),
        Directory(p.join(root.path, 'cases')));
    expect(loaded.flow.agents.keys.toSet(), {'alice', 'bob'});
    expect(
        loaded.definition.requiredBindings,
        containsAll([
          'global.biz.result.publication',
          'global.biz.event.notification'
        ]));
    expect(loaded.flow.flowTimeoutMs, 120000);
  });

  Future<LoadedCase> makeCase(
      {List<JsonObject>? steps,
      List<JsonObject>? commands,
      List<String>? required,
      JsonObject? patch,
      JsonObject? metadataPatch,
      bool absoluteScript = false}) async {
    final dir = Directory(p.join(root.path, 'source-${sequence++}'));
    await dir.create();
    final basename = '5.0.0-multi-presence$sequence-positive';
    final yamlPath = p.join(dir.path, '$basename.yaml');
    final jsonPath = p.join(dir.path, '$basename.json');
    final command = <String, Object?>{
      'id': 'run',
      'api': 'Chat.test',
      'params': <String, Object?>{},
      'expect': {'success': true}
    };
    await File(jsonPath).writeAsString(jsonEncode({
      'requiredBindings': required ?? ['global.biz.result.done'],
      'steps': commands ?? [command],
      ...?metadataPatch,
    }));
    final script = absoluteScript ? jsonPath : '$basename.json';
    await File(yamlPath).writeAsString(jsonEncode({
      'name': 'presence-case',
      'flowTimeoutMs': 500,
      'agents': {
        'alice': {'script': script},
        'bob': {'script': script}
      },
      'steps': steps ??
          [
            {'cmd': 'run', 'agent': 'alice', 'as': 'global.biz.result.done'}
          ],
      ...?patch,
    }));
    return loader.freeze(yamlPath, Directory(p.join(root.path, 'cases')));
  }

  CaseData caseData(LoadedCase loaded, {int attempt = 1}) {
    final result = data.createCaseData(
        context: context,
        environment: {
          'appKey': 'org#app',
          'accounts': [
            {'id': 'user-a', 'token': 'secret-a'},
            {'id': 'user-b', 'token': 'secret-b'}
          ],
          'groups': <Object?>[],
          'rooms': <Object?>[]
        },
        caseName: loaded.definition.name,
        caseBasename: p.basenameWithoutExtension(loaded.definition.sourceYaml),
        attempt: attempt,
        roles: {
          'alice': {
            'accountId': 'user-a',
            'platform': 'ios',
            'instance': 'device-a'
          },
          'bob': {
            'accountId': 'user-b',
            'platform': 'ios',
            'instance': 'device-b'
          }
        },
        agentRoles: loaded.flow.agents.keys,
        metadata: loaded.metadata);
    expect(result.isSuccess, isTrue);
    return result.data!;
  }

  Map<String, DeviceResult> devices() => {
        for (final role in agents.keys)
          role: DeviceResult(
              platform: DevicePlatform.ios,
              instance: role == 'alice' ? 'device-a' : 'device-b',
              deviceId: role == 'alice' ? 'device-a' : 'device-b',
              observedState: 'Booted',
              checkedAt: DateTime.now(),
              ready: true),
      };

  OperationResult<LaunchResult> launch(LoadedCase loaded) => OperationResult(
      runId: 'run-1',
      operationId: 'launch-1',
      status: OperationStatus.success,
      errors: const [],
      evidence: const [],
      data: LaunchResult(caseName: loaded.definition.name, roles: {
        for (final entry in devices().entries)
          entry.key: Connection(
              deviceId: entry.value.deviceId!,
              applicationId: 'example.app',
              platform: DevicePlatform.ios,
              buildOperationId: 'build-1',
              artifact: artifact,
              endpoint: 'http://127.0.0.1:1234',
              token: 'control-secret',
              instanceId: 'instance-${entry.key}',
              version: 2,
              state: 'accepting',
              checkedAt: DateTime.now(),
              startedAt: DateTime.now(),
              processId: 1,
              forward: null,
              usedBy: null,
              invalidatedAt: null,
              invalidatedReason: null),
      }));

  Future<OperationResult<ExecutionResult>> execute(LoadedCase loaded,
      {CaseData? actual,
      CaseData? expected,
      OperationResult<LaunchResult>? started,
      Map<String, DeviceResult>? deviceMap,
      AdmissionCheck? admission,
      int? timeout,
      String? reportPath}) async {
    final input = expected ?? caseData(loaded);
    final service = ExecutionService(
        loader: loader,
        clients: (role, _) => agents[role]!,
        stopTimeout: const Duration(milliseconds: 20),
        finishTimeout: const Duration(milliseconds: 20),
        evidenceTimeout: const Duration(milliseconds: 30),
        release: (client) => (client as FakeAgent).released = true);
    return service.execute(
        context: context,
        definition: loaded.definition,
        caseData: actual ?? input,
        expectedCaseData: input,
        sourceOperations: {
          'caseData': 'data-1',
          'definition': 'inputs-1',
          'launch': 'launch-1',
          'device.alice': 'device-a-1',
          'device.bob': 'device-b-1'
        },
        devices: deviceMap ?? devices(),
        launch: started ?? launch(loaded),
        attemptDirectory:
            Directory(p.join(root.path, 'attempt-${input.attempt}')),
        reportPath: reportPath ??
            p.join(root.path, 'report-${input.attempt}', 'flow-report.json'),
        admission: () async {
          admissions++;
          if (admission != null) return admission();
          return data.preconditions(
              context: context,
              caseName: loaded.definition.name,
              environment: {
                'appKey': 'org#app',
                'accounts': [
                  {'id': 'user-a', 'token': 'secret-a'},
                  {'id': 'user-b', 'token': 'secret-b'}
                ],
                'groups': <Object?>[],
                'rooms': <Object?>[]
              },
              caseData: input,
              declarations: loaded.flow.preconditions,
              metadata: loaded.metadata,
              checkOutputPath: p.join(
                  root.path, 'attempt-${input.attempt}', 'preconditions.json'));
        },
        claimConnections: () async {
          claims++;
        },
        flowTimeoutMs: timeout);
  }

  group('fixed definitions', () {
    test(
        'same-name absolute scripts are relocated and source edits cannot change fixed execution',
        () async {
      final loaded = await makeCase(absoluteScript: true);
      final original = await File(loaded.definition.yaml.path).readAsString();
      expect(original, await File(loaded.definition.sourceYaml).readAsString());
      await File(loaded.definition.sourceJson)
          .writeAsString('broken after freeze');
      await File(loaded.definition.sourceYaml)
          .writeAsString('broken after freeze');
      final restored = await loader.load(loaded.definition);
      expect(restored.flow.agents['alice']!.scriptPath,
          loaded.definition.json.path);
      expect(restored.flow.scripts['alice']!.stepsById['run']!['api'],
          'Chat.test');
      final result = await execute(loaded);
      expect(result.data!.verdict, '是');
      expect(agents['alice']!.calls, ['Chat.test']);
    });

    test(
        'corrupt fixed copies are rejected even when original source remains valid',
        () async {
      final loaded = await makeCase();
      await File(loaded.definition.json.path).writeAsString('{}');
      final result = await execute(loaded);
      expect(result.data!.verdict, '未执行');
      expect(claims, 0);
      expect(admissions, 0);
      expect(agents.values.every((agent) => agent.calls.isEmpty), isTrue);
      expect(result.data!.report, isNull);
    });

    test(
        'valid fixed files from another run are not accepted as this run definition',
        () async {
      final loaded = await makeCase();
      final foreign = await loader.freeze(loaded.definition.sourceYaml,
          Directory(p.join(root.path, 'other-run', 'cases')));
      final result = await execute(foreign);
      expect(result.data!.verdict, '未执行');
      expect(result.errors.single.field, 'definition.files');
      expect(claims, 0);
    });

    test('required binding must be unique, present and outside loops',
        () async {
      for (final entry in <(List<JsonObject>, List<String>)>[
        (
          [
            {'cmd': 'run', 'agent': 'alice', 'as': 'done'}
          ],
          ['absent']
        ),
        (
          [
            {'cmd': 'run', 'agent': 'alice', 'as': 'done'},
            {'cmd': 'run', 'agent': 'bob', 'as': 'done'}
          ],
          ['done']
        ),
        (
          [
            {'cmd': 'run', 'agent': 'alice', 'as': 'done'}
          ],
          ['done', 'done']
        ),
        (
          [
            {
              'for': 'i in 1..2',
              'do': [
                {'cmd': 'run', 'agent': 'alice', 'as': 'done'}
              ]
            }
          ],
          ['done']
        ),
      ]) {
        await expectLater(makeCase(steps: entry.$1, required: entry.$2),
            throwsA(anyOf(isA<FormatException>(), isA<FlowParseError>())));
      }
      expect(agents.values.every((agent) => agent.calls.isEmpty), isTrue);
    });

    test(
        'read-only global writes, duplicate commands and hidden command delay are refused statically',
        () async {
      for (final step in <JsonObject>[
        {'cmd': 'run', 'agent': 'alice', 'as': 'global.account.alice'},
        {
          'set': {'global.account.alice': 'bad'}
        },
      ]) {
        await expectLater(makeCase(steps: [step]),
            throwsA(anyOf(isA<FormatException>(), isA<FlowParseError>())));
      }
      await expectLater(
          makeCase(commands: [
            {'id': 'run', 'api': 'Chat.test', 'params': <String, Object?>{}},
            {'id': 'run', 'api': 'Chat.test', 'params': <String, Object?>{}},
          ]),
          throwsA(anyOf(isA<FormatException>(), isA<FlowParseError>())));
      await expectLater(
          makeCase(commands: [
            {
              'id': 'run',
              'api': 'Chat.test',
              'params': <String, Object?>{},
              'delayAfterMs': 1
            }
          ]),
          throwsA(anyOf(isA<FormatException>(), isA<FlowParseError>())));
    });
  });

  group('admission', () {
    test(
        'actual DataService output is accepted; restored wrong account data is rejected before side effects',
        () async {
      final loaded = await makeCase();
      final expected = caseData(loaded);
      final wrong = CaseData.fromJson({
        ...expected.toJson(),
        'initConfig': {'appKey': 'other#app'}
      });
      final result = await execute(loaded, actual: wrong, expected: expected);
      expect(result.data!.verdict, '未执行');
      expect(result.errors.first.field, 'caseData.initConfig');
      final rejectionRef = result.evidence.singleWhere(
          (reference) => reference.path.endsWith('-acceptance.json'));
      final rejection = jsonDecode(await File(rejectionRef.path).readAsString())
          as JsonObject;
      expect(rejection['producer'], 'data');
      expect(rejection['consumer'], 'execution');
      expect(rejection['operationId'], 'data-1');
      expect(rejection['field'], 'caseData.initConfig');
      expect(rejection['rework'], 'data');
      expect(agents['alice']!.calls, isEmpty);
      expect(claims, 0);
      expect(admissions, 0);
    });

    test('wrong run and role grouping cannot borrow another launch', () async {
      final loaded = await makeCase();
      final good = launch(loaded);
      final wrongRun = OperationResult<LaunchResult>(
          runId: 'run-other',
          operationId: good.operationId,
          status: good.status,
          data: good.data,
          errors: good.errors,
          evidence: good.evidence);
      final result = await execute(loaded, started: wrongRun);
      expect(result.data!.verdict, '未执行');
      expect(result.errors.single.message, contains('launch -> execution'));
      expect(claims, 0);
    });

    test(
        'used, invalidated, incompatible and duplicate-device connections block dispatch',
        () async {
      final loaded = await makeCase();
      for (final patch in <JsonObject>[
        {
          'usedBy': {'caseName': 'old', 'attempt': 1}
        },
        {
          'invalidatedAt': DateTime.now().toUtc().toIso8601String(),
          'invalidatedReason': 'restarted'
        },
        {'version': 1},
        {'state': 'uncertain'},
      ]) {
        final good = launch(loaded);
        final connections = {
          ...good.data!.roles,
          'alice': Connection.fromJson(
              {...good.data!.roles['alice']!.toJson(), ...patch})
        };
        final result = await execute(loaded,
            started: OperationResult(
                runId: good.runId,
                operationId: good.operationId,
                status: good.status,
                data: LaunchResult(
                    caseName: loaded.definition.name, roles: connections),
                errors: const [],
                evidence: const []));
        expect(result.data!.verdict, '未执行');
      }
      expect(claims, 0);
      expect(agents['alice']!.calls, isEmpty);
    });

    test(
        'external recheck failure is preserved and does not claim or run commands',
        () async {
      final loaded = await makeCase();
      final result = await execute(loaded,
          admission: () async => throw StateError('device now stopped'));
      expect(result.data!.verdict, '未执行');
      expect(result.errors.single.message, contains('device now stopped'));
      expect(admissions, 1);
      expect(claims, 0);
    });

    test(
        'precondition delivery must belong to this attempt and match its evidence file',
        () async {
      final loaded = await makeCase();
      final input = caseData(loaded);
      final wrongFile = File(p.join(root.path, 'wrong-check.json'));
      await wrongFile.writeAsString('[]');
      var result = await execute(loaded,
          admission: () async => OperationResult(
              runId: 'run-1',
              operationId: 'check-1',
              status: OperationStatus.success,
              errors: const [],
              evidence: const [],
              data: PreconditionResult(
                  caseName: loaded.definition.name,
                  appKey: 'org#app',
                  checks: const [],
                  setup: null,
                  check: await fileRef(wrongFile.path))));
      expect(result.data!.verdict, '未执行');
      expect(result.errors.single.field, 'preconditions.check.path');
      expect(claims, 0);
      final checkPath = p.join(root.path, 'attempt-1', 'preconditions.json');
      result = await execute(loaded, admission: () async {
        final delivered = await data.preconditions(
            context: context,
            caseName: loaded.definition.name,
            environment: {
              'appKey': 'org#app',
              'accounts': [
                {'id': 'user-a', 'token': 'secret-a'},
                {'id': 'user-b', 'token': 'secret-b'}
              ],
              'groups': <Object?>[],
              'rooms': <Object?>[]
            },
            caseData: input,
            declarations: [],
            metadata: {},
            checkOutputPath: checkPath);
        await File(checkPath).writeAsString('[{}]');
        return delivered;
      });
      expect(result.data!.verdict, '未执行');
      expect(claims, 0);
      expect(agents.values.every((agent) => agent.calls.isEmpty), isTrue);
    });

    test('invalid incoming payload cannot escape as an invalid failed delivery',
        () async {
      final loaded = await makeCase();
      final expected = caseData(loaded);
      final invalid = CaseData(
          caseName: expected.caseName,
          attempt: 0,
          accounts: expected.accounts,
          initConfig: expected.initConfig,
          input: expected.input);
      final result = await execute(loaded, expected: expected, actual: invalid);
      expect(result.isSuccess, isFalse);
      expect(result.data, isNull);
      expect(() => result.validate(), returnsNormally);
      expect(claims, 0);
    });
  });

  group('lifecycle and verdict', () {
    test('expected SDK failure passes while an unrelated SDK failure fails',
        () async {
      agents['alice']!.command = (_, __) async => const Envelope(
          success: false,
          status: 'error',
          failureKind: 'sdk',
          error: {'code': 401, 'message': 'expected'});
      final positive = await makeCase();
      final failed = await execute(positive);
      expect(failed.data!.verdict, '否');
      expect(failed.isSuccess, isTrue);
      expect(failed.errors, isEmpty);
      expect(failed.data!.report, isNotNull);
      final negative = await makeCase(commands: [
        {
          'id': 'run',
          'api': 'Chat.test',
          'params': <String, Object?>{},
          'expect': {'success': false, 'errorCode': 401}
        }
      ]);
      final passed =
          await execute(negative, expected: caseData(negative, attempt: 2));
      expect(passed.data!.verdict, '是');
      expect(passed.isSuccess, isTrue);
    });

    test(
        'necessary unselected branch cannot pass using only successful executed steps',
        () async {
      final loaded = await makeCase(steps: [
        {
          'if': 'false',
          'then': [
            {'cmd': 'run', 'agent': 'alice', 'as': 'global.biz.result.done'}
          ]
        },
      ]);
      final result = await execute(loaded);
      expect(result.data!.verdict, '否');
      expect(result.data!.required.single.recordIndices, isEmpty);
      expect(agents['alice']!.calls, isEmpty);
    });

    test(
        'finish failure leaves valid business pass intact and finishes remaining device',
        () async {
      final loaded = await makeCase();
      agents['alice']!.finishing = () async => throw StateError('409 busy');
      final result = await execute(loaded);
      expect(result.data!.verdict, '是');
      expect(result.isSuccess, isFalse);
      expect(result.data!.finish['alice']!.success, isFalse);
      expect(result.data!.finish['bob']!.success, isTrue);
      expect(
          agents.values.every((agent) => agent.finishes == 1 && agent.released),
          isTrue);
    });

    test(
        'whole-flow timeout, bounded stop and finish preserve original errors and publish immutable report',
        () async {
      final loaded = await makeCase();
      final pending = Completer<Envelope>();
      agents['alice']!.command = (_, __) => pending.future;
      agents['alice']!.finishing = () => Completer<void>().future;
      final watch = Stopwatch()..start();
      final result = await execute(loaded, timeout: 10);
      expect(watch.elapsed, lessThan(const Duration(seconds: 2)));
      expect(result.data!.verdict, '未完成');
      expect(result.errors.map((e) => e.message).join(),
          contains('Whole-flow timeout'));
      expect(result.errors.map((e) => e.message).join(),
          contains('still pending'));
      expect(result.data!.finish['bob']!.success, isTrue);
      final report = File(result.data!.report!.path);
      final before = await report.readAsString();
      pending.complete(
          const Envelope(success: true, status: 'ok', data: 'late-result'));
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(await report.readAsString(), before);
      await verifyFileRef(result.data!.report!);
      expect(before, isNot(contains('late-result')));
      expect(agents.values.every((agent) => agent.released), isTrue);
    });

    test(
        'interpreter startup error still collects available evidence and finishes every device',
        () async {
      final loaded = await makeCase();
      agents['alice']!.polling =
          (_, __) async => throw StateError('poll transport broken');
      agents['bob']!.finishing =
          () async => throw StateError('finish also broken');
      final result = await execute(loaded);
      expect(result.data!.verdict, '未完成');
      final errors = result.errors.map((e) => e.message).join();
      expect(errors, contains('poll transport broken'));
      expect(errors, contains('finish also broken'));
      expect(result.data!.report, isNotNull);
      expect(
          agents.values.every((agent) => agent.finishes == 1 && agent.released),
          isTrue);
    });

    test(
        'step timeout and onFail abort are failed tests, not interpreter crashes',
        () async {
      final loaded = await makeCase(steps: [
        {
          'cmd': 'run',
          'agent': 'alice',
          'as': 'global.biz.result.done',
          'timeoutMs': 10,
          'onFail': 'abort_all'
        }
      ]);
      agents['alice']!.command = (_, __) => Completer<Envelope>().future;
      final result = await execute(loaded, timeout: 100);
      expect(result.data!.verdict, '否');
      expect(result.errors.map((e) => e.message).join(),
          isNot(contains('Whole-flow')));
    });

    test(
        'original reports cannot be overwritten and validation rejects changed identity and counts',
        () async {
      final loaded = await makeCase();
      final result = await execute(loaded);
      final reportPath = result.data!.report!.path;
      final raw = await File(reportPath).readAsString();
      final second = await execute(loaded,
          expected: caseData(loaded, attempt: 2), reportPath: reportPath);
      expect(second.data!.verdict, '未完成');
      expect(second.data!.report, isNull);
      expect(await File(reportPath).readAsString(), raw);
      final report = jsonDecode(raw) as JsonObject;
      expect(
          () => validateExecutionDelivery(result.data!, report, runId: 'run-1'),
          returnsNormally);
      expect(
          () => validateRawReport(
              {...report, 'runId': 'other'}, 'run-1', loaded.definition.name),
          throwsFormatException);
      expect(
          () => validateRawReport({
                ...report,
                'summary': {'total': 100}
              }, 'run-1', loaded.definition.name),
          throwsFormatException);
    });
  });

  group('event and secret evidence', () {
    Future<LoadedCase> eventCase() => makeCase(steps: [
          {'cmd': 'run', 'agent': 'bob'},
          {
            'wait_event': 'onPresenceUpdated',
            'agent': 'alice',
            'as': 'global.biz.event.received',
            'match': {
              'publisher': r'$global.account.bob.userId',
              'description': r'$global.biz.input.description'
            }
          },
        ], required: [
          'global.biz.event.received'
        ], metadataPatch: {
          'data': {
            'unique': {'description': 'presence-'}
          }
        });

    test(
        'matching raw event carries current instance identity and logs redact secrets without modifying assertions',
        () async {
      final loaded = await eventCase();
      final input = caseData(loaded);
      agents['bob']!.command = (_, __) async {
        agents['alice']!
            .events
            .add(AgentEvent(seq: 1, source: 'onPresenceUpdated', payload: {
              'publisher': 'user-b',
              'description': input.input['description'],
              'token': 'secret-b'
            }));
        return const Envelope(
            success: true, status: 'ok', data: {'token': 'secret-a'});
      };
      final result = await execute(loaded, expected: input);
      expect(result.data!.verdict, '是');
      expect(
          result.data!.required.single.evidence
              .any((ref) => ref.location == 'seq=1'),
          isTrue);
      final eventPath = p.join(root.path, 'attempt-1', 'alice-events.jsonl');
      final event = jsonDecode((await File(eventPath).readAsString()).trim())
          as JsonObject;
      expect(event['instanceId'], 'instance-alice');
      for (final entity in await root.list(recursive: true).toList()) {
        if (entity is File &&
            (entity.path.contains('attempt-') ||
                entity.path.contains('report-'))) {
          final text = await entity.readAsString();
          expect(text, isNot(contains('secret-a')), reason: entity.path);
          expect(text, isNot(contains('secret-b')), reason: entity.path);
          expect(text, isNot(contains('control-secret')), reason: entity.path);
        }
      }
    });

    test(
        'a passed event assertion without retained raw event evidence is unfinished',
        () async {
      final loaded = await eventCase();
      final input = caseData(loaded);
      agents['bob']!.command = (_, __) async {
        agents['alice']!.events.add(AgentEvent(
                seq: 1,
                source: 'onPresenceUpdated',
                payload: {
                  'publisher': 'user-b',
                  'description': input.input['description']
                }));
        return const Envelope(success: true, status: 'ok');
      };
      agents['alice']!.finishing = () async {
        agents['alice']!.events.clear();
      };
      final result = await execute(loaded, expected: input);
      expect(result.data!.required.single.passed, isTrue);
      expect(result.data!.verdict, '未完成');
      expect(result.errors.map((error) => error.message).join(),
          contains('Missing raw event evidence'));
    });
  });
}
