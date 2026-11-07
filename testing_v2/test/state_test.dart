import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:testing_v2/src/contracts.dart';
import 'package:testing_v2/src/core.dart';
import 'package:testing_v2/src/state.dart';

void main() {
  late Directory root;
  late RunStore store;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('testing-v2-state-');
    store = RunStore(root);
  });
  tearDown(() async {
    await root.delete(recursive: true);
  });

  test('run identity, private persistence, and independent restoration',
      () async {
    final a = await store.create('presence'),
        b = await store.create('presence');
    expect(a.id, isNot(b.id));
    a.json['environment'] = {
      'accounts': [
        {'id': 'alice', 'token': 'secret'}
      ]
    };
    await a.save();
    expect((await store.load(a.id)).json['environment'], a.json['environment']);
    expect((await File(a.path).stat()).mode & 0x1ff, 0x180);
    await expectLater(store.load('missing'), throwsFormatException);
    expect(() => store.directory('../escape'), throwsFormatException);
  });

  test(
      'failed operation with null payload remains a recoverable terminal record',
      () async {
    final run = await store.create('devices');
    final id = run.allocateOperation('devices');
    await run.begin(id, 'devices');
    final result = OperationResult<DeviceResult>(
        runId: run.id,
        operationId: id,
        status: OperationStatus.failure,
        data: null,
        errors: [
          OperationError(
              message: 'emulator did not start',
              field: 'ready',
              expected: true,
              actual: false)
        ],
        evidence: []);
    await run.complete(result, 'devices');
    final restored = await store.load(run.id);
    expect(restored.operations.single['state'], 'completed');
    expect((restored.operations.single['result'] as Map)['data'], isNull);
    expect(restored.allocateOperation('build'), 'build-2');
  });

  test('report evidence is not registered as disposable logs', () async {
    final run = await store.create('presence');
    final path = p.join(root.path, 'reports', run.id, 'flow-report.json');
    await writePrivateJson(path, {'failed': true});
    await run.begin('execute-1', 'execute');
    await run.complete(
        OperationResult(
            runId: run.id,
            operationId: 'execute-1',
            status: OperationStatus.success,
            data: {'done': true},
            errors: [],
            evidence: [EvidenceRef(path: path, location: 'steps[0]')]),
        'execute');
    expect(run.artifacts.single['type'], 'reports');
    expect(() => run.register(path, 'logs', 'execute', 'execute-1'),
        throwsFormatException);
  });

  test(
      'attempt allocation survives restarts and does not consume prepare operations',
      () async {
    final run = await store.create('presence');
    final yaml = p.join(root.path, 'case.yaml'),
        json = p.join(root.path, 'case.json');
    await File(yaml).writeAsString('name: presence');
    await File(json).writeAsString('{}');
    final definition = CaseDefinition(
        name: 'presence',
        sourceYaml: yaml,
        sourceJson: json,
        yaml: await fileRef(yaml),
        json: await fileRef(json),
        requiredBindings: ['answer']);
    final entry = <String, Object?>{
      'definition': definition.toJson(),
      'roles': <String, Object?>{}
    };
    run.cases.add(entry);
    final first = await run.newAttempt(entry);
    first['state'] = 'completed';
    await run.save();
    final recovered = await store.load(run.id);
    expect((await recovered.newAttempt(recovered.cases.single))['attempt'], 2);
    expect(recovered.attempts.length, 2);
    expect(recovered.caseBySource(yaml)['definition'], definition.toJson());
  });

  test('issue persists sanitized detail and explicit protection state',
      () async {
    final run = await store.create('presence');
    await run.issue(
        'data', 'accessToken=secret-123', SecretRedactor(['secret-123']),
        caseName: 'presence', attempt: 1);
    final issue = run.issues.single;
    expect(issue['status'], 'unresolved');
    expect(await File(issue['detail'] as String).readAsString(),
        isNot(contains('secret-123')));
    expect(jsonDecode(await File(run.path).readAsString()), contains('issues'));
  });

  test('same-process resource overlap is rejected and release permits reuse',
      () async {
    final first = await store.lock('device:ios:sim');
    await expectLater(RunStore(root).lock('device:ios:sim'), throwsStateError);
    await first.release();
    final second = await store.lock('device:ios:sim');
    await second.release();
  });

  test('issue resolution requires explicit conclusion and real verification',
      () async {
    final run = await store.create('presence');
    final redactor = SecretRedactor();
    await run.issue('execute', 'unknown external outcome', redactor);
    await expectLater(
        run.resolveIssue('issue-1',
            conclusion: '', verification: [], redactor: redactor),
        throwsFormatException);
    expect(run.issues.single['status'], 'unresolved');
    final evidence = p.join(run.directory.path, 'verified.json');
    await writePrivateJson(evidence, {'externalOutcome': 'confirmed'});
    await run.resolveIssue('issue-1',
        conclusion: 'Confirmed external outcome',
        verification: [EvidenceRef(path: evidence, location: null)],
        redactor: redactor);
    expect((await store.load(run.id)).issues.single['status'], 'resolved');
  });
}
