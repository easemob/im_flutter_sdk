import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:testing_v2/src/cleanup.dart';
import 'package:testing_v2/src/contracts.dart';
import 'package:testing_v2/src/core.dart';

void main() {
  late Directory root;
  late CleanupService service;
  late JsonObject snapshot;
  const runId = '20261106-120000-clean-a123';
  OperationContext context() => OperationContext(
      runId: runId,
      operationId: 'clean-1',
      tmpDirectory: Directory(p.join(root.path, 'tmp', runId)),
      redactor: SecretRedactor());
  setUp(() async {
    root = await Directory.systemTemp.createTemp('testing-v2-clean-');
    await Process.run('git', ['init', '-q', root.path]);
    await File(p.join(root.path, '.gitignore'))
        .writeAsString('/tmp/\n/build/\n/reports/\n/lib/accounts.g.dart\n');
    service = CleanupService(root: root);
    snapshot = {
      'runId': runId,
      'status': 'stopped',
      'artifacts': <Object?>[],
      'issues': <Object?>[],
      'cases': <Object?>[],
      'reportDependencies': <Object?>[]
    };
  });
  tearDown(() async {
    await root.delete(recursive: true);
  });

  Future<String> artifact(String relative, String type) async {
    final path = p.join(root.path, relative);
    await File(path).parent.create(recursive: true);
    await File(path).writeAsString('evidence');
    (snapshot['artifacts'] as List).add({
      'path': path,
      'type': type,
      'stage': type,
      'operationId': 'old-1',
      'caseName': null,
      'attempt': null
    });
    return path;
  }

  test('cleans only selected owned artifacts and preserves account source',
      () async {
    final log = await artifact('tmp/$runId/device.log', 'logs');
    final build = await artifact('build/$runId/app.apk', 'build');
    final source = await artifact('lib/accounts.g.dart', 'cache');
    final result = await service.clean(context(), snapshot, {'all'});
    expect(result.data!.deleted, containsAll([log, build]));
    expect(result.data!.failed.single.path, source);
    expect(await File(source).exists(), true);
    expect(result.isSuccess, false);
    expect((snapshot['artifacts'] as List).length, 3,
        reason: 'cleanup never writes registry');
  });

  test('running and unresolved states retain evidence', () async {
    final log = await artifact('tmp/$runId/device.log', 'logs');
    snapshot['status'] = 'unknown';
    final unknown = await service.clean(context(), snapshot, {'logs'});
    expect(unknown.data!.kept.single.path, log);
    snapshot['status'] = 'stopped';
    snapshot['issues'] = [
      {
        'id': 'issue-1',
        'status': 'unresolved',
        'detail': log,
        'evidence': <Object?>[],
        'caseName': null,
        'attempt': null
      }
    ];
    final unresolved = await service.clean(context(), snapshot, {'all'});
    expect(unresolved.data!.kept.single.path, log);
    expect(await File(log).exists(), true);
  });

  test(
      'retained reports protect evidence and all selection removes owner first',
      () async {
    final log = await artifact('tmp/$runId/deep/evidence.log', 'logs');
    final report = await artifact('reports/$runId/summary.md', 'reports');
    snapshot['reportDependencies'] = [
      ReportDependency(report: report, evidence: EvidenceRef(path: log))
          .toJson()
    ];
    final logsOnly = await service.clean(context(), snapshot, {'logs'});
    expect(logsOnly.data!.kept.single.path, log);
    final all = await service.clean(context(), snapshot, {'all'});
    expect(all.data!.deleted, [report, log]);
    expect(all.isSuccess, true);
  });

  test('failed report deletion retains its evidence', () async {
    final log = await artifact('tmp/$runId/evidence.log', 'logs');
    final invalidOwner = await artifact('outside/report.md', 'reports');
    snapshot['reportDependencies'] = [
      ReportDependency(report: invalidOwner, evidence: EvidenceRef(path: log))
          .toJson()
    ];
    final result = await service.clean(context(), snapshot, {'all'});
    expect(result.isSuccess, false);
    expect(result.data!.failed.single.path, invalidOwner);
    expect(result.data!.kept.single.path, log);
    expect(await File(log).exists(), true);
  });

  test('missing protection index retains selected paths', () async {
    final log = await artifact('tmp/$runId/evidence.log', 'logs');
    snapshot.remove('issues');
    final result = await service.clean(context(), snapshot, {'all'});
    expect(result.data!.kept.single.path, log);
    expect(await File(log).exists(), true);
  });

  test('symbolic links and tracked files cannot be cleaned', () async {
    final tracked = await artifact('tmp/$runId/tracked.log', 'logs');
    await Process.run('git', ['add', '-f', tracked],
        workingDirectory: root.path);
    final outside =
        await File(p.join(root.path, 'outside')).writeAsString('keep');
    final link = p.join(root.path, 'tmp', runId, 'alias');
    await Link(link).create(outside.path);
    (snapshot['artifacts'] as List).add({'path': link, 'type': 'logs'});
    final result = await service.clean(context(), snapshot, {'logs'});
    expect(result.data!.failed.map((item) => item.path),
        containsAll([tracked, link]));
    expect(await outside.readAsString(), 'keep');
  });

  test('consumer rejects omitted paths and fabricated deletion', () async {
    final log = await artifact('tmp/$runId/evidence.log', 'logs');
    await expectLater(
        () => service.validate(
            const CleanupResult(deleted: [], kept: [], failed: []), {log}),
        throwsFormatException);
    await expectLater(
        () => service.validate(
            CleanupResult(deleted: [log], kept: [], failed: []), {log}),
        throwsFormatException);
  });
}
