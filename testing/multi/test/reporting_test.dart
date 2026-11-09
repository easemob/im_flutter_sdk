import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:testing_v2/src/contracts.dart';
import 'package:testing_v2/src/core.dart';
import 'package:testing_v2/src/data.dart';
import 'package:testing_v2/src/execution.dart';
import 'package:testing_v2/src/reporting.dart';

void main() {
  late Directory root;
  late CaseLoader loader;
  late CaseDefinition definition;
  late ReportingService service;
  late JsonObject snapshot;
  const runId = '20261106-120000-sample-a123';
  const caseName = '5.0.0-multi-sample-positive';
  const binding = 'global.biz.result.check';
  OperationContext context() => OperationContext(
      runId: runId,
      operationId: 'report-1',
      tmpDirectory: Directory(p.join(root.path, 'tmp', runId)),
      redactor: SecretRedactor());
  Directory reportDirectory() => Directory(p.join(root.path, 'reports', runId));

  setUp(() async {
    root = await Directory.systemTemp.createTemp('testing-v2-report-');
    loader = CaseLoader(DataService());
    service = ReportingService(loader: loader);
    final source = p.join(root.path, '$caseName.yaml');
    await File(source).writeAsString('''name: $caseName
flowTimeoutMs: 1000
agents:
  alice: {script: $caseName.json}
  bob: {script: $caseName.json}
steps:
  - cmd: check
    agent: alice
    as: $binding
''');
    await File(p.setExtension(source, '.json')).writeAsString(jsonEncode({
      'requiredBindings': [binding],
      'steps': [
        {
          'id': 'check',
          'api': 'ChatClient.check',
          'params': <String, Object?>{'input': 'full-command-input-marker'},
          'expect': {'success': true}
        }
      ],
    }));
    definition = (await loader.freeze(
            source, Directory(p.join(root.path, 'tmp', runId, 'cases'))))
        .definition;
    snapshot = {
      'runId': runId,
      'status': 'stopped',
      'environment': {'token': 'private-secret'},
      'cases': [
        {'definition': definition.toJson(), 'roles': <String, Object?>{}}
      ],
      'attempts': <Object?>[],
      'operations': <Object?>[],
      'issues': <Object?>[],
    };
  });
  tearDown(() async {
    await root.delete(recursive: true);
  });

  Future<ExecutionResult> attempt(int number,
      {String verdict = '是',
      bool finishFailure = false,
      bool event = false}) async {
    final path =
        p.join(reportDirectory().path, caseName, '$number', 'flow-report.json');
    final status = verdict == '否' ? 'failed' : 'passed';
    final result = <String, Object?>{
      'binding': binding,
      'success': verdict == '是',
      'status': 'completed',
      'expectMatched': verdict == '是',
      'data': {'detail': 'full-command-output-marker'}
    };
    if (event)
      result.addAll({
        'seq': 3,
        'payload': {'publisher': 'bob'}
      });
    final raw = <String, Object?>{
      'runId': runId,
      'flow': caseName,
      'startedAt': '2026-11-06T12:00:00Z',
      'finishedAt': '2026-11-06T12:00:01Z',
      'steps': [
        {
          'kind': event ? 'wait_event' : 'cmd',
          'context': 'flow',
          'status': status,
          'durationMs': 1,
          'agent': 'alice',
          'name': event ? 'presence' : 'check',
          if (status == 'failed') 'reason': 'failure ' * 80,
          'result': result
        }
      ],
      'summary': {
        'total': 1,
        'passed': status == 'passed' ? 1 : 0,
        'failed': status == 'failed' ? 1 : 0,
        'timeout': 0,
        'skipped': 0
      },
    };
    await writePrivateJson(path, raw);
    final evidence = [EvidenceRef(path: path, location: 'steps[0]')];
    if (event) {
      final eventPath = p.join(
          root.path, 'tmp', runId, caseName, '$number', 'alice-events.jsonl');
      await writePrivateFile(
          eventPath,
          '${jsonEncode({
                'instanceId': 'instance-a',
                'seq': 3,
                'source': 'presence',
                'payload': {'publisher': 'bob'}
              })}\n');
      evidence.add(EvidenceRef(path: eventPath, location: 'seq=3'));
    }
    final execution = ExecutionResult(
        caseName: caseName,
        attempt: number,
        definition: definition,
        launchOperationId: 'launch-$number',
        verdict: verdict,
        report: await fileRef(path),
        required: [
          RequiredCheck(
              binding: binding,
              recordIndices: [0],
              passed: status == 'passed',
              evidence: evidence)
        ],
        finish: {
          'alice': FinishResult(
              success: !finishFailure, error: finishFailure ? 'busy' : null)
        });
    final operation = OperationResult<ExecutionResult>(
        runId: runId,
        operationId: 'execute-$number',
        status:
            finishFailure ? OperationStatus.failure : OperationStatus.success,
        data: execution,
        errors:
            finishFailure ? [const OperationError(message: 'finish busy')] : [],
        evidence: evidence);
    (snapshot['attempts'] as List<Object?>).add({
      'caseName': caseName,
      'attempt': number,
      'definition': definition.toJson(),
      'roles': {
        'alice': {'platform': 'ios'},
        'bob': {'platform': 'ios'}
      },
      'launchOperationId': 'launch-$number',
      'state': 'completed',
      'result': operation.toJson(),
    });
    (snapshot['operations'] as List<Object?>)
        .add({'stage': 'execution', 'result': operation.toJson()});
    return execution;
  }

  test(
      'reports a failed test and its revalidation without erasing either attempt',
      () async {
    await attempt(1, verdict: '否');
    await attempt(2);
    final result =
        await service.generate(context(), snapshot, reportDirectory());
    expect(result.isSuccess, true,
        reason: '${result.errors.map((e) => e.message)}');
    final rows = parseStatistics(
        await File(result.data!.statistics.path).readAsString());
    expect(rows.length, 3);
    expect(rows[1][9], '否');
    expect(rows[2][9], '是');
    expect(await File(result.data!.summary.path).readAsString(),
        contains('用例数：1'));
    await service.validate(result.data!, snapshot);
    expect(result.data!.dependencies, isNotEmpty);
  });

  test(
      'finish failure remains a task fault without changing established verdict',
      () async {
    await attempt(1, finishFailure: true);
    final result =
        await service.generate(context(), snapshot, reportDirectory());
    expect(result.isSuccess, true);
    final rows = parseStatistics(
        await File(result.data!.statistics.path).readAsString());
    expect(rows[1][9], '是');
    expect(rows[1][10], contains('finish'));
    expect(await File(result.data!.summary.path).readAsString(),
        contains('任务故障：1'));
    expect(await File(result.data!.process.single.path).readAsString(),
        isNot(contains('private-secret')));
  });

  test(
      'replaced report and missing raw event retain rows with incomplete verdict',
      () async {
    await attempt(1);
    final second = await attempt(2, event: true);
    final evidence = second.required.single.evidence.last;
    await File(evidence.path).delete();
    final first = readObject((snapshot['attempts'] as List).first);
    final firstResult = readObject(readObject(first['result'])['data']);
    await File(readObject(firstResult['report'])['path'] as String)
        .writeAsString('{}');
    final result =
        await service.generate(context(), snapshot, reportDirectory());
    expect(result.isSuccess, false);
    expect(result.data, isNotNull);
    final rows = parseStatistics(
        await File(result.data!.statistics.path).readAsString());
    expect(rows.skip(1).map((row) => row[9]), ['未完成', '未完成']);
    expect(
        result.data!.dependencies
            .any((item) => item.evidence.path == evidence.path),
        true);
  });

  test('earlier report cannot be registered as a later attempt', () async {
    final first = await attempt(1);
    await attempt(2);
    final second = readObject((snapshot['attempts'] as List).last);
    final operation = readObject(second['result']);
    final data = readObject(operation['data']);
    data['report'] = first.report!.toJson();
    operation['data'] = data;
    second['result'] = operation;
    (snapshot['attempts'] as List)[1] = second;
    final result =
        await service.generate(context(), snapshot, reportDirectory());
    expect(result.isSuccess, false);
    final rows = parseStatistics(
        await File(result.data!.statistics.path).readAsString());
    expect(rows[2][9], '未完成');
  });

  test(
      'summary and duplicate CSV rows fail acceptance even with updated file hashes',
      () async {
    await attempt(1);
    final result =
        await service.generate(context(), snapshot, reportDirectory());
    final original = result.data!;
    final text = await File(original.statistics.path).readAsString();
    final rows = parseStatistics(text);
    String quote(String value) => '"${value.replaceAll('"', '""')}"';
    await writePrivateFile(
        original.statistics.path, '$text${rows[1].map(quote).join(',')}\r\n');
    final changed = ReportingResult(
        summary: original.summary,
        statistics: await fileRef(original.statistics.path),
        process: original.process,
        attempts: original.attempts,
        dependencies: original.dependencies);
    await expectLater(
        () => service.validate(changed, snapshot), throwsFormatException);
  });

  test('evidence sequence and unknown location cannot silently pass', () async {
    final path = p.join(root.path, 'events.jsonl');
    await File(path).writeAsString('${jsonEncode({'seq': 7})}\n');
    await validateEvidence(EvidenceRef(path: path, location: 'seq=7'));
    await expectLater(
        () => validateEvidence(EvidenceRef(path: path, location: 'seq=8')),
        throwsFormatException);
    await expectLater(
        () => validateEvidence(EvidenceRef(path: path, location: 'made-up')),
        throwsFormatException);
  });

  test(
      'shared verdict validation rejects contradictory failure and duplicate required checks',
      () async {
    final passed = await attempt(1);
    final report =
        readObject(jsonDecode(await File(passed.report!.path).readAsString()));
    final inconsistent =
        ExecutionResult.fromJson({...passed.toJson(), 'verdict': '否'});
    expect(() => validateExecutionDelivery(inconsistent, report, runId: runId),
        throwsFormatException);
    final flowTimeout = readObject(jsonDecode(jsonEncode(report)));
    (flowTimeout['steps'] as List).add({
      'kind': 'flow',
      'context': 'flow',
      'status': 'timeout',
      'durationMs': 1
    });
    flowTimeout['summary'] = {
      'total': 2,
      'passed': 1,
      'failed': 0,
      'timeout': 1,
      'skipped': 0
    };
    expect(() => validateExecutionDelivery(passed, flowTimeout, runId: runId),
        throwsFormatException);
  });
  test('evidence resolves operation identities in JSON arrays and JSONL',
      () async {
    final path = p.join(root.path, 'host.json');
    await File(path).writeAsString(jsonEncode([
      {'operationId': 'execute-10-device', 'event': 'start'},
      {'operationId': 'execute-10-device', 'event': 'end'}
    ]));
    await validateEvidence(
        EvidenceRef(path: path, location: 'execute-10-device'));
    await expectLater(
        () => validateEvidence(
            EvidenceRef(path: path, location: 'missing-operation')),
        throwsFormatException);
    await File(path).writeAsString('${jsonEncode({
          'operationId': 'run-1'
        })}\n${jsonEncode({'operationId': 'run-2'})}\n');
    await validateEvidence(EvidenceRef(path: path, location: 'run-2'));
  });
  test(
      'consumer rejects changed expected text even when counts and file hashes match',
      () async {
    await attempt(1);
    final result =
        await service.generate(context(), snapshot, reportDirectory());
    final original = result.data!;
    final rows =
        parseStatistics(await File(original.statistics.path).readAsString());
    rows[1][7] = 'forged expected condition';
    String quote(String value) => '"${value.replaceAll('"', '""')}"';
    await writePrivateFile(original.statistics.path,
        '${rows.map((row) => row.map(quote).join(',')).join('\r\n')}\r\n');
    final changed = ReportingResult(
        summary: original.summary,
        statistics: await fileRef(original.statistics.path),
        process: original.process,
        attempts: original.attempts,
        dependencies: original.dependencies);
    await expectLater(
        () => service.validate(changed, snapshot), throwsFormatException);
  });
  test(
      'CSV shows compact expectations and failure summaries, not source or payloads',
      () async {
    final execution = await attempt(1, verdict: '否');
    final result =
        await service.generate(context(), snapshot, reportDirectory());
    expect(result.isSuccess, true);
    final rows = parseStatistics(
        await File(result.data!.statistics.path).readAsString());
    final expected = readObject(jsonDecode(rows[1][7]));
    expect(expected['requiredBindings'], [binding]);
    expect(expected['commands'], [
      {
        'id': 'check',
        'expect': {'success': true}
      }
    ]);
    expect(rows[1][7], isNot(contains('flowTimeoutMs')));
    expect(rows[1][7], isNot(contains('ChatClient.check')));
    expect(rows[1][7], isNot(contains('full-command-input-marker')));
    final actual = readObject(jsonDecode(rows[1][8]));
    expect(actual.containsKey('steps'), false);
    expect(actual['summary'], containsPair('failed', 1));
    final failure = readObject((actual['failures'] as List).single);
    expect(failure['name'], 'check');
    expect(failure['status'], 'failed');
    expect((failure['reason'] as String).length, lessThanOrEqualTo(160));
    expect(rows[1][8], isNot(contains('full-command-output-marker')));
    expect(await File(execution.report!.path).readAsString(),
        contains('full-command-output-marker'));
    await service.validate(result.data!, snapshot);
  });
}
