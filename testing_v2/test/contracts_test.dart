import 'dart:convert';

import 'package:test/test.dart';
import 'package:testing_v2/src/contracts.dart';

void main() {
  test('account slots and device roles have independent admission rules', () {
    expect(readAccountSelection({'account1': 'a'}), {'account1': 'a'});
    final selected = {
      for (final role in ['first', 'second', 'third'])
        role: {'platform': 'android', 'instance': role}
    };
    expect(readDeviceSelection(selected, selected.keys), hasLength(3));
    for (final patch in [
      {'first': selected['first']},
      {...selected, 'second': selected['first']},
      {
        ...selected,
        'first': {...selected['first']!, 'accountId': 'a'}
      },
      {
        ...selected,
        'first': {'platform': 'web', 'instance': 'first'}
      },
    ]) {
      expect(() => readDeviceSelection(patch, selected.keys),
          throwsFormatException);
    }
    for (final invalid in [
      <String, Object?>{},
      {'account2': 'a'},
      {'account0': 'a'},
      {'account1': 'a', 'account3': 'b'},
      {'account1': 'a', 'account2': 'a'},
      {'account1': ''},
      {'account1': 1},
      {'sender': 'a'},
    ]) {
      expect(() => readAccountSelection(invalid), throwsFormatException);
    }
  });

  final digest = 'a' * 64;
  FileRef ref(String name) => FileRef(path: '/tmp/$name', sha256: digest);
  CaseDefinition definition() => CaseDefinition(
      name: 'presence',
      sourceYaml: '/source/case.yaml',
      sourceJson: '/source/case.json',
      yaml: ref('case.yaml'),
      json: ref('case.json'),
      requiredBindings: ['global.biz.event.received']);
  Connection connection() => Connection(
      deviceId: 'ios-1',
      applicationId: 'test.app',
      platform: DevicePlatform.ios,
      buildOperationId: 'build-1',
      artifact: ref('app'),
      endpoint: 'http://127.0.0.1:1234',
      token: 'private-token',
      instanceId: 'instance-1',
      version: 2,
      state: 'accepting',
      checkedAt: DateTime.utc(2026),
      startedAt: DateTime.utc(2026),
      processId: null,
      forward: null,
      usedBy: null,
      invalidatedAt: null,
      invalidatedReason: null);

  final samples = <String, (JsonContract, JsonContract Function(Object?))>{
    'error': (
      const OperationError(message: 'missing input'),
      OperationError.fromJson
    ),
    'evidence': (
      const EvidenceRef(path: '/tmp/evidence.log'),
      EvidenceRef.fromJson
    ),
    'file': (ref('artifact'), FileRef.fromJson),
    'account': (
      const AccountData(environment: {'appKey': 'org#app'}),
      AccountData.fromJson
    ),
    'definition': (definition(), CaseDefinition.fromJson),
    'data': (
      const CaseData(caseName: 'presence', attempt: 1, accounts: {
        'account1': {'userId': 'a', 'userToken': 'token'}
      }, initConfig: {
        'appKey': 'org#app'
      }, input: {}),
      CaseData.fromJson
    ),
    'precheck': (
      PreconditionCheck(
          users: ['a', 'b'],
          expected: ContactState.none,
          actual: {'a': false, 'b': false},
          satisfied: true,
          checkedAt: DateTime.utc(2026)),
      PreconditionCheck.fromJson
    ),
    'preconditions': (
      PreconditionResult(
          caseName: 'presence',
          appKey: 'org#app',
          checks: [],
          setup: null,
          check: ref('preconditions')),
      PreconditionResult.fromJson
    ),
    'device': (
      DeviceResult(
          platform: DevicePlatform.ios,
          instance: 'ios-1',
          deviceId: 'ios-1',
          observedState: 'Booted',
          checkedAt: DateTime.utc(2026),
          ready: true),
      DeviceResult.fromJson
    ),
    'build': (
      BuildResult(
          platform: DevicePlatform.ios,
          architectures: ['arm64'],
          applicationId: 'test.app',
          mode: 'debug',
          arguments: ['--debug'],
          artifact: ref('app')),
      BuildResult.fromJson
    ),
    'forward': (
      const ForwardMapping(
          serial: 'emulator-5554', hostPort: 1234, devicePort: 4321),
      ForwardMapping.fromJson
    ),
    'connection': (connection(), Connection.fromJson),
    'launch': (
      LaunchResult(caseName: 'presence', roles: {'alice': connection()}),
      LaunchResult.fromJson
    ),
    'required': (
      const RequiredCheck(
          binding: 'global.biz.event.received',
          recordIndices: [0],
          passed: true,
          evidence: []),
      RequiredCheck.fromJson
    ),
    'finish': (
      const FinishResult(success: false, error: 'busy'),
      FinishResult.fromJson
    ),
    'attempt': (
      const AttemptRef(caseName: 'presence', attempt: 1),
      AttemptRef.fromJson
    ),
    'execution': (
      ExecutionResult(
          caseName: 'presence',
          attempt: 1,
          definition: definition(),
          launchOperationId: 'launch-1',
          verdict: '否',
          report: ref('report'),
          required: [],
          finish: {}),
      ExecutionResult.fromJson
    ),
    'dependency': (
      const ReportDependency(
          report: '/tmp/report',
          evidence: EvidenceRef(path: '/tmp/log', location: 'line 1')),
      ReportDependency.fromJson
    ),
    'reporting': (
      ReportingResult(
          summary: ref('summary'),
          statistics: ref('stats'),
          process: [],
          attempts: [],
          dependencies: []),
      ReportingResult.fromJson
    ),
    'reason': (
      const PathReason(path: '/tmp/keep', reason: 'unresolved'),
      PathReason.fromJson
    ),
    'cleanup': (
      const CleanupResult(deleted: ['/tmp/deleted'], kept: [], failed: []),
      CleanupResult.fromJson
    ),
  };

  for (final sample in samples.entries) {
    test('${sample.key} round trip and rejects each missing field', () {
      final (model, parse) = sample.value;
      final encoded = model.toJson();
      expect(parse(jsonDecode(jsonEncode(encoded))).toJson(), encoded);
      model.validate();
      for (final field in encoded.keys) {
        final missing = Map<String, Object?>.from(encoded)..remove(field);
        expect(() => parse(missing), throwsFormatException,
            reason: '${sample.key}.$field must exist, including null fields');
      }
    });
  }

  test('rejects coercion, malformed hashes, paths, enums and timestamps', () {
    expect(() => AttemptRef.fromJson({'caseName': 'x', 'attempt': '1'}),
        throwsFormatException);
    expect(() => AttemptRef.fromJson({'caseName': 'x', 'attempt': 0}),
        throwsFormatException);
    expect(() => FileRef.fromJson({'path': 'relative', 'sha256': digest}),
        throwsFormatException);
    expect(
        () => FileRef.fromJson(
            {'path': '/tmp/x', 'sha256': digest.toUpperCase()}),
        throwsFormatException);
    final device = samples['device']!.$1.toJson();
    expect(() => DeviceResult.fromJson({...device, 'ready': 1}),
        throwsFormatException);
    expect(() => DeviceResult.fromJson({...device, 'platform': 'web'}),
        throwsFormatException);
    expect(
        () => DeviceResult.fromJson(
            {...device, 'checkedAt': '2026-11-06T12:00:00'}),
        throwsFormatException);
    expect(() => DeviceResult.fromJson({...device, 'deviceId': null}),
        throwsFormatException);
    expect(() => readObject({'bad': double.nan}), throwsFormatException);
  });

  test('rejects relationally invalid nested contracts', () {
    final pc = samples['precheck']!.$1.toJson();
    expect(
        () => PreconditionCheck.fromJson({
              ...pc,
              'users': ['a', 'a']
            }),
        throwsFormatException);
    expect(() => PreconditionCheck.fromJson({...pc, 'actual': null}),
        throwsFormatException);
    expect(
        () => PreconditionCheck.fromJson({
              ...pc,
              'actual': {'a': false}
            }),
        throwsFormatException);
    expect(() => FinishResult.fromJson({'success': false, 'error': null}),
        throwsFormatException);
    expect(
        () => CleanupResult.fromJson({
              'deleted': ['/tmp/x'],
              'kept': [
                {'path': '/tmp/x', 'reason': 'retained'}
              ],
              'failed': <Object?>[]
            }),
        throwsFormatException);
    final c = connection().toJson();
    expect(() => Connection.fromJson({...c, 'platform': 'android'}),
        throwsFormatException);
    expect(() => Connection.fromJson({...c, 'invalidatedReason': 'restarted'}),
        throwsFormatException);
  });

  test('operation status does not erase a valid failed test delivery', () {
    final payload = samples['execution']!.$1 as ExecutionResult;
    final result = OperationResult<ExecutionResult>(
        runId: 'run-1',
        operationId: 'execute-1',
        status: OperationStatus.success,
        data: payload,
        errors: [],
        evidence: []);
    expect(
        acceptOperation(result,
                runId: 'run-1',
                producer: 'execution',
                consumer: 'reporting',
                rework: 'execution')
            .verdict,
        '否');
    expect(
        OperationResult<ExecutionResult>.fromJson(
                result.toJson(), ExecutionResult.fromJson)
            .data!
            .verdict,
        '否');
  });

  test('operation rejects malformed state and ownership before consumption',
      () {
    final result = OperationResult<AccountData>(
        runId: 'wrong-run',
        operationId: 'load-1',
        status: OperationStatus.success,
        data: const AccountData(environment: {}),
        errors: [],
        evidence: []);
    var dispatched = false;
    try {
      acceptOperation(result,
          runId: 'expected-run',
          producer: 'data',
          consumer: 'execution',
          rework: 'data');
      dispatched = true;
      fail('acceptance should reject');
    } on ContractViolation catch (error) {
      expect(error.field, 'runId');
      expect(error.expected, 'expected-run');
      expect(error.actual, 'wrong-run');
      expect(error.producer, 'data');
      expect(error.consumer, 'execution');
      expect(error.operationId, 'load-1');
      expect(error.rework, 'data');
    }
    expect(dispatched, false);
    expect(
        () => OperationResult<AccountData>.fromJson(
            {...result.toJson(), 'data': null}, AccountData.fromJson),
        throwsFormatException);
    expect(
        () => OperationResult<AccountData>.fromJson(
            {...result.toJson(), 'status': 'failure'}, AccountData.fromJson),
        throwsFormatException);
    expect(
        () => OperationResult<AccountData>.fromJson({
              ...result.toJson(),
              'errors': [
                {
                  'message': 'failure',
                  'field': null,
                  'expected': null,
                  'actual': null
                }
              ]
            }, AccountData.fromJson),
        throwsFormatException);
  });
}
